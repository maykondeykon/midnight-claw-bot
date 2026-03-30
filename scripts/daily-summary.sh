#!/bin/bash
# Resumo Diário - Executado às 08:00 via cron
# Envia resumo para o Telegram com: notícias, tarefas, backup, cotação

WORKSPACE="/home/maykon/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
STATE_FILE="$MEMORY_DIR/heartbeat-state.json"
NOTION_KEY=$(cat ~/.config/notion/api_key 2>/dev/null)

# Criar diretório de memória se não existir
mkdir -p "$MEMORY_DIR"

echo "=== Gerando Resumo Diário ==="
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"

# Inicializar estado se não existir
if [ ! -f "$STATE_FILE" ]; then
    echo '{"lastResumoSent": "", "lastChecks": {}}' > "$STATE_FILE"
fi

# Verificar se já foi enviado hoje
LAST_SENT=$(jq -r '.lastResumoSent' "$STATE_FILE" 2>/dev/null)
TODAY=$(date '+%Y-%m-%d')

if [[ "$LAST_SENT" == "$TODAY"* ]]; then
    echo "Resumo já enviado hoje: $LAST_SENT"
    exit 0
fi

# ============================================
# 1. STATUS DO BACKUP
# ============================================
echo "Verificando backup..."
BACKUP_LOG="$WORKSPACE/backup.log"
if [ -f "$BACKUP_LOG" ]; then
    LAST_BACKUP=$(grep -o "Backup iniciado em [0-9-]* [0-9:]*" "$BACKUP_LOG" | tail -1)
    BACKUP_STATUS=$(grep "Backup concluído" "$BACKUP_LOG" | tail -1 | grep -c "sucesso")
    
    if [ "$BACKUP_STATUS" -eq 1 ]; then
        BACKUP_MSG="✅ Backup OK - $LAST_BACKUP"
    else
        BACKUP_MSG="❌ Backup falhou"
    fi
else
    BACKUP_MSG="⚠️ Log de backup não encontrado"
fi

# ============================================
# 2. TAREFAS DO NOTION
# ============================================
echo "Buscando tarefas do Notion..."

# Buscar tarefas do CorteClub
CORTECLUB_TOTAL=$(curl -s -X POST "https://api.notion.com/v1/databases/30e38d59-393c-8125-90ee-f86fadeafc13/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d '{"filter": {"property": "Projeto", "select": {"equals": "CorteClub"}}}' | jq '.results | length')

CORTECLUB_DONE=$(curl -s -X POST "https://api.notion.com/v1/databases/30e38d59-393c-8125-90ee-f86fadeafc13/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d '{"filter": {"and": [{"property": "Projeto", "select": {"equals": "CorteClub"}}, {"property": "Status", "select": {"equals": "Feito"}}]}}' | jq '.results | length')

# Buscar tarefas do GoPDV
GOPDV_TOTAL=$(curl -s -X POST "https://api.notion.com/v1/databases/30e38d59-393c-8125-90ee-f86fadeafc13/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d '{"filter": {"property": "Projeto", "select": {"equals": "GoPDV"}}}' | jq '.results | length')

GOPDV_DONE=$(curl -s -X POST "https://api.notion.com/v1/databases/30e38d59-393c-8125-90ee-f86fadeafc13/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d '{"filter": {"and": [{"property": "Projeto", "select": {"equals": "GoPDV"}}, {"property": "Status", "select": {"equals": "Feito"}}]}}' | jq '.results | length')

# Buscar tarefas A Fazer (GoPDV - Alta prioridade)
GOPDV_TODO=$(curl -s -X POST "https://api.notion.com/v1/databases/30e38d59-393c-8125-90ee-f86fadeafc13/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d '{"filter": {"and": [{"property": "Projeto", "select": {"equals": "GoPDV"}}, {"property": "Status", "select": {"equals": "A Fazer"}}]}, "sorts": [{"property": "Prioridade", "direction": "descending"}]}' | jq -r '.results[:5] | .[] | "• \(.properties.Tarefa.title[0].plain_text)"')

# Buscar tarefas A Fazer (CorteClub)
CORTECLUB_TODO=$(curl -s -X POST "https://api.notion.com/v1/databases/30e38d59-393c-8125-90ee-f86fadeafc13/query" \
    -H "Authorization: Bearer $NOTION_KEY" \
    -H "Notion-Version: 2022-06-28" \
    -H "Content-Type: application/json" \
    -d '{"filter": {"and": [{"property": "Projeto", "select": {"equals": "CorteClub"}}, {"property": "Status", "select": {"equals": "A Fazer"}}]}, "sorts": [{"property": "Prioridade", "direction": "descending"}]}' | jq -r '.results[:5] | .[] | "• \(.properties.Tarefa.title[0].plain_text)"')

# ============================================
# 3. COTAÇÃO EUR/BRL
# ============================================
echo "Buscando cotação EUR/BRL..."
EXCHANGE_RATE=$(curl -s "https://api.exchangerate-api.com/v4/latest/EUR" | jq -r '.rates.BRL' 2>/dev/null)
if [ -n "$EXCHANGE_RATE" ] && [ "$EXCHANGE_RATE" != "null" ]; then
    COTACAO="💰 EUR → BRL: R$ $(echo "$EXCHANGE_RATE" | awk '{printf "%.2f", $1}')"
else
    COTACAO="💰 Cotação indisponível"
fi

# ============================================
# 4. SINCRONIZAR NOTION <-> PROJECT FLOW
# ============================================
echo "Sincronizando Notion <-> Project Flow..."
if [ -f "$WORKSPACE/scripts/sync-notion-projects.sh" ]; then
    bash "$WORKSPACE/scripts/sync-notion-projects.sh" > /dev/null 2>&1
    SYNC_MSG="✅ Sincronização OK"
else
    SYNC_MSG="⚠️ Script de sincronização não encontrado"
fi

# ============================================
# GERAR MENSAGEM
# ============================================
TOTAL=$((CORTECLUB_TOTAL + GOPDV_TOTAL))
DONE=$((CORTECLUB_DONE + GOPDV_DONE))
PENDING=$((TOTAL - DONE))

MESSAGE="🌅 **Resumo Diário** — $(date '+%d/%m/%Y')

---

## 📊 Tarefas

**CorteClub:** $CORTECLUB_DONE/$CORTECLUB_TOTAL ✅
**GoPDV:** $GOPDV_DONE/$GOPDV_TOTAL ✅

**Progresso Total:** $DONE/$TOTAL ($(( DONE * 100 / TOTAL ))%)

---

### 🔴 CorteClub — Pendentes:
$CORTECLUB_TODO

### 🟠 GoPDV — Pendentes:
$GOPDV_TODO

---

## 🌙 Sistema

$BACKUP_MSG
$SYNC_MSG
$COTACAO

---

_Olá Maykon! Tenha um excelente dia! 🌙_"

# ============================================
# ENVIAR PARA TELEGRAM
# ============================================
echo "Enviando para Telegram..."

# Usar o gateway do OpenClaw para enviar
GATEWAY_URL="http://127.0.0.1:18789"
GATEWAY_TOKEN=$(jq -r '.gateway.auth.token' ~/.openclaw/openclaw.json 2>/dev/null)

if [ -z "$GATEWAY_TOKEN" ]; then
    echo "Erro: Gateway token não encontrado"
    exit 1
fi

# Enviar mensagem via API do gateway
curl -s -X POST "$GATEWAY_URL/api/message/send" \
    -H "Authorization: Bearer $GATEWAY_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"channel\": \"telegram\",
        \"to\": \"8593227319\",
        \"message\": $(echo "$MESSAGE" | jq -Rs .)
    }" > /dev/null

# Atualizar estado
jq --arg today "$(date -Iseconds)" '.lastResumoSent = $today' "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

echo "✅ Resumo enviado com sucesso!"
