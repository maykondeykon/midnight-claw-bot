#!/bin/bash
# Backup diário do workspace Midnight Claw para GitHub

WORKSPACE="$HOME/.openclaw/workspace"
LOG_FILE="$WORKSPACE/backup.log"
TOKEN_FILE="$HOME/.config/github/backup_token"

# Lê o token do arquivo
if [ -f "$TOKEN_FILE" ]; then
    TOKEN=$(cat "$TOKEN_FILE")
else
    echo "❌ Token não encontrado em $TOKEN_FILE" >> "$LOG_FILE"
    exit 1
fi

REPO="https://x-access-token:${TOKEN}@github.com/maykondeykon/midnight-claw-bot.git"

cd "$WORKSPACE" || exit 1

echo "=== Backup iniciado em $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"

# Adiciona todas as mudanças
git add -A >> "$LOG_FILE" 2>&1

# Verifica se há mudanças para commitar
if git diff --cached --quiet; then
    echo "Nenhuma mudança detectada." >> "$LOG_FILE"
    exit 0
fi

# Commit com timestamp
COMMIT_MSG="Backup automático - $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1

# Push
git push origin master >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Backup concluído com sucesso!" >> "$LOG_FILE"
else
    echo "❌ Erro no backup!" >> "$LOG_FILE"
    exit 1
fi

echo "=== Backup finalizado em $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
