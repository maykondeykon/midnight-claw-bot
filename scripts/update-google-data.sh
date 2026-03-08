#!/bin/bash
# Atualiza dados do Google Calendar e Tasks

SCRIPT_DIR="$HOME/.openclaw/workspace/scripts"
LOG_FILE="$HOME/.openclaw/workspace/memory/google-update.log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Atualizando dados Google..." >> "$LOG_FILE"

cd "$HOME/.openclaw/workspace"
"$SCRIPT_DIR/google-integration.py" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ✅ Dados atualizados" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ❌ Erro ao atualizar" >> "$LOG_FILE"
fi
