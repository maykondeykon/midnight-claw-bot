#!/bin/bash
# Sincroniza project-flow.json dos repositórios com o Notion
# Uso: ./scripts/sync-notion-projects.sh

# Não usar set -e para não parar em erros
# set -e

NOTION_KEY=$(cat ~/.config/notion/api_key 2>/dev/null)
GITHUB_TOKEN=$(cat ~/.config/github/pat_deykonsolutions 2>/dev/null)
DATABASE_ID="30e38d59-393c-8125-90ee-f86fadeafc13"

if [ -z "$NOTION_KEY" ] || [ -z "$GITHUB_TOKEN" ]; then
    echo "Erro: NOTION_KEY ou GITHUB_TOKEN não configurados"
    exit 1
fi

# Mapeamento de repositórios para projetos no Notion
declare -A REPO_PROJECT_MAP=(
    ["corteclub-api"]="CorteClub"
    ["gopdv-backend"]="GoPDV"
    ["gopdv-frontend"]="GoPDV"
    ["gopdv-infra"]="GoPDV"
)

# Mapeamento de prioridades
map_priority() {
    case $1 in
        critical|high) echo "Alta" ;;
        normal) echo "Média" ;;
        low) echo "Baixa" ;;
        *) echo "Média" ;;
    esac
}

# Mapeamento de status
map_status() {
    case $1 in
        todo) echo "A Fazer" ;;
        doing|in-progress) echo "Em Andamento" ;;
        done) echo "Feito" ;;
        blocked) echo "A Fazer" ;;
        *) echo "A Fazer" ;;
    esac
}

# Buscar tarefas existentes no Notion
fetch_notion_tasks() {
    local project="$1"
    curl -s -X POST "https://api.notion.com/v1/databases/$DATABASE_ID/query" \
        -H "Authorization: Bearer $NOTION_KEY" \
        -H "Notion-Version: 2022-06-28" \
        -H "Content-Type: application/json" \
        -d "{\"filter\": {\"property\": \"Projeto\", \"select\": {\"equals\": \"$project\"}}}" | \
        jq -r '.results[] | "\(.properties.Tarefa.title[0].plain_text)|\(.id)|\(.properties.Status.select.name)"'
}

# Criar tarefa no Notion
create_notion_task() {
    local title="$1"
    local project="$2"
    local priority="$3"
    local status="$4"
    
    curl -s -X POST "https://api.notion.com/v1/pages" \
        -H "Authorization: Bearer $NOTION_KEY" \
        -H "Notion-Version: 2022-06-28" \
        -H "Content-Type: application/json" \
        -d "{
            \"parent\": { \"database_id\": \"$DATABASE_ID\" },
            \"properties\": {
                \"Tarefa\": { \"title\": [{\"text\": {\"content\": \"$title\"}}] },
                \"Projeto\": { \"select\": { \"name\": \"$project\" } },
                \"Prioridade\": { \"select\": { \"name\": \"$priority\" } },
                \"Status\": { \"select\": { \"name\": \"$status\" } }
            }
        }" > /dev/null
}

# Atualizar status da tarefa no Notion
update_notion_task() {
    local page_id="$1"
    local status="$2"
    
    curl -s -X PATCH "https://api.notion.com/v1/pages/$page_id" \
        -H "Authorization: Bearer $NOTION_KEY" \
        -H "Notion-Version: 2022-06-28" \
        -H "Content-Type: application/json" \
        -d "{\"properties\": {\"Status\": {\"select\": {\"name\": \"$status\"}}}}" > /dev/null
}

echo "=== Sincronização Notion <-> Project Flow ==="
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Lista de repositórios em ordem específica
REPOS=("corteclub-api" "gopdv-backend" "gopdv-frontend" "gopdv-infra")

# Processar cada repositório
for repo in "${REPOS[@]}"; do
    project="${REPO_PROJECT_MAP[$repo]}"
    echo "--- Processando $repo -> $project ---"
    
    # Buscar project-flow.json do repositório
    project_flow=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/deykonsolutions/$repo/contents/project-flow.json" 2>/dev/null | \
        jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null) || true
    
    if [ -z "$project_flow" ] || [ "$project_flow" = "null" ]; then
        echo "  ⚠️  project-flow.json não encontrado ou inválido"
        continue
    fi
    
    # Verificar se o JSON é válido
    if ! echo "$project_flow" | jq empty 2>/dev/null; then
        echo "  ⚠️  JSON inválido no project-flow.json"
        continue
    fi
    
    # Extrair tarefas do project-flow.json
    tasks=$(echo "$project_flow" | jq -r '.tasks[]? | "\(.id)|\(.title)|\(.priority)|\(.status)"' 2>/dev/null) || true
    
    if [ -z "$tasks" ]; then
        echo "  ℹ️  Nenhuma tarefa encontrada"
        continue
    fi
    
    # Buscar tarefas existentes no Notion para este projeto
    declare -A notion_tasks
    while IFS='|' read -r title page_id status; do
        notion_tasks["$title"]="$page_id|$status"
    done < <(fetch_notion_tasks "$project")
    
    # Processar cada tarefa do project-flow
    created=0
    updated=0
    
    while IFS='|' read -r task_id task_title task_priority task_status; do
        [ -z "$task_id" ] && continue
        
        # Formatar título com ID
        full_title="$task_id - $task_title"
        
        # Mapear prioridade e status
        notion_priority=$(map_priority "$task_priority")
        notion_status=$(map_status "$task_status")
        
        # Verificar se tarefa já existe no Notion
        if [ -n "${notion_tasks[$full_title]}" ]; then
            # Tarefa existe - verificar se precisa atualizar status
            existing_data="${notion_tasks[$full_title]}"
            existing_page_id=$(echo "$existing_data" | cut -d'|' -f1)
            existing_status=$(echo "$existing_data" | cut -d'|' -f2)
            
            if [ "$existing_status" != "$notion_status" ]; then
                update_notion_task "$existing_page_id" "$notion_status"
                echo "  🔄 Atualizado: $full_title ($existing_status -> $notion_status)"
                ((updated++))
            fi
        else
            # Tarefa não existe - criar
            create_notion_task "$full_title" "$project" "$notion_priority" "$notion_status"
            echo "  ✅ Criado: $full_title [$notion_priority] [$notion_status]"
            ((created++))
        fi
    done <<< "$tasks"
    
    echo "  📊 Resumo: $created criadas, $updated atualizadas"
    unset notion_tasks
    echo ""
done

echo "=== Sincronização concluída ==="
