#!/bin/bash
# Comunicação Midnight Claw <-> Solar Claw via Supabase

CONFIG_FILE="$HOME/.config/supabase/solar-messaging.json"

# Lê configuração
SUPABASE_URL=$(jq -r '.url' "$CONFIG_FILE")
SUPABASE_KEY=$(jq -r '.service_role_key' "$CONFIG_FILE")
MY_ID=$(jq -r '.my_id' "$CONFIG_FILE")
SOLAR_ID=$(jq -r '.solar_id' "$CONFIG_FILE")

# Enviar mensagem para Solar Claw
send_to_solar() {
    local message="$1"
    curl -s -X POST "$SUPABASE_URL/rest/v1/messages" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Authorization: Bearer $SUPABASE_KEY" \
        -H "Content-Type: application/json" \
        -H "Prefer: return=representation" \
        -d "{
            \"from\": \"$MY_ID\",
            \"to\": \"$SOLAR_ID\",
            \"payload\": {\"message\": \"$message\"},
            \"status\": \"pending\"
        }" | jq '.[0].id'
}

# Buscar mensagens pendentes para mim
get_pending_messages() {
    curl -s "$SUPABASE_URL/rest/v1/messages?to=eq.$MY_ID&status=eq.pending&select=*&order=created_at.asc" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Authorization: Bearer $SUPABASE_KEY" \
        -H "Content-Type: application/json"
}

# Marcar mensagem como processada
mark_processed() {
    local message_id="$1"
    curl -s -X PATCH "$SUPABASE_URL/rest/v1/messages?id=eq.$message_id" \
        -H "apikey: $SUPABASE_KEY" \
        -H "Authorization: Bearer $SUPABASE_KEY" \
        -H "Content-Type: application/json" \
        -d '{"status": "processed", "processed_at": "'$(date -u +%Y-%m-%dT%H:%M:%S)'"}' \
        -o /dev/null -w "%{http_code}"
}

case "$1" in
    send)
        send_to_solar "$2"
        ;;
    read)
        get_pending_messages
        ;;
    process)
        mark_processed "$2"
        ;;
    *)
        echo "Uso: $0 {send|read|process} [mensagem|id]"
        exit 1
        ;;
esac
