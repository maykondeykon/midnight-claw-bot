#!/bin/bash
# Verifica mensagens do Solar Claw a cada 15 min

MESSAGING_SCRIPT="$HOME/.openclaw/workspace/scripts/supabase-messaging.sh"
INBOX_FILE="$HOME/.openclaw/workspace/memory/solar-inbox.json"

# Busca mensagens pendentes
MESSAGES=$($MESSAGING_SCRIPT read)

# Se há mensagens, salva na inbox
if [ "$MESSAGES" != "[]" ] && [ -n "$MESSAGES" ]; then
    echo "$MESSAGES" > "$INBOX_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Nova(s) mensagem(ns) do Solar" >> "$HOME/.openclaw/workspace/memory/solar-messages.log"
fi
