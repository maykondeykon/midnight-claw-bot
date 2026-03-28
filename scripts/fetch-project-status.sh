#!/bin/bash
# Script para buscar status atualizado dos projetos do GitHub
# Usa as URLs completas (com token embutido) de memory/project_urls.json

PROJECT_URLS_FILE="$HOME/.openclaw/workspace/memory/project_urls.json"
OUTPUT_FILE="$HOME/.openclaw/workspace/memory/project-status.json"

if [ ! -f "$PROJECT_URLS_FILE" ]; then
    echo "Erro: Arquivo project_urls.json não encontrado"
    exit 1
fi

# Cria o arquivo de output com timestamp
echo "{" > "$OUTPUT_FILE"
echo "  \"fetched_at\": \"$(date -Iseconds)\"," >> "$OUTPUT_FILE"
echo "  \"projects\": {" >> "$OUTPUT_FILE"

# Lê o JSON e processa cada projeto
# Usa jq para extrair pares chave-valor
projects=$(cat "$PROJECT_URLS_FILE" | jq -r 'to_entries[] | "\(.key)|\(.value)"')

FIRST=true
while IFS='|' read -r project url; do
    if [ -z "$project" ] || [ -z "$url" ]; then
        continue
    fi
    
    # Busca o arquivo do GitHub usando a URL completa (já tem o token)
    content=$(curl "$url" 2>/dev/null)
    
    if [ -z "$content" ] || echo "$content" | grep -q "404"; then
        echo "Aviso: Não foi possível buscar $project" >&2
        continue
    fi
    
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo "," >> "$OUTPUT_FILE"
    fi
    
    echo "    \"$project\": $content" >> "$OUTPUT_FILE"
    
done <<< "$projects"

echo "" >> "$OUTPUT_FILE"
echo "  }" >> "$OUTPUT_FILE"
echo "}" >> "$OUTPUT_FILE"

echo "Status dos projetos salvo em $OUTPUT_FILE"
