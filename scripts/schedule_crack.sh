#!/bin/bash
# ─────────────────────────────────────────────────────────
# Agendador do crack_doc_password
# Roda o script apenas entre 00:00 e 07:00
# Uso: bash schedule_crack.sh
# ─────────────────────────────────────────────────────────

SCRIPT="/home/maykon/.openclaw/workspace/scripts/crack_doc_password_claude.py"
DOC="/media/Documentos/MIDNIGHT RIDER/arquivos/Letras/Black Cherub.doc"
LOG="/media/Documentos/MIDNIGHT RIDER/arquivos/Letras/Black Cherub_progress.log"
SCHED_LOG="/media/Documentos/MIDNIGHT RIDER/arquivos/Letras/agendador.log"
PID_FILE="/tmp/crack_doc.pid"

HORA_INICIO=0   # meia-noite
HORA_FIM=7      # 7h da manhã

# ─── Funções ───────────────────────────────────────────────

# Log no arquivo do crack (detalhado)
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

# Log no arquivo do agendador (limpo, fácil de ler no dia seguinte)
slog() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$SCHED_LOG"
}

hora_atual() {
    date '+%H' | sed 's/^0//'  # remove zero à esquerda (08 → 8)
}

dentro_do_horario() {
    local h=$(hora_atual)
    if [ "$h" -ge "$HORA_INICIO" ] && [ "$h" -lt "$HORA_FIM" ]; then
        return 0
    else
        return 1
    fi
}

crack_rodando() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

iniciar_crack() {
    python3 "$SCRIPT" "$DOC" &
    echo $! > "$PID_FILE"
    local pid=$(cat "$PID_FILE")
    slog "▶  INICIADO  — PID $pid"
    log  "▶  Crack iniciado pelo agendador (PID $pid)"
}

parar_crack() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        kill "$pid" 2>/dev/null
        sleep 2
        kill -9 "$pid" 2>/dev/null
        rm -f "$PID_FILE"
        slog "⏸  PARADO   — PID $pid (checkpoint salvo)"
        log  "⏸  Crack parado pelo agendador (PID $pid)"
    fi
}

# ─── Verificar se senha já foi encontrada ──────────────────

RESULTADO="${DOC%.doc}_senha_encontrada.txt"
if [ -f "$RESULTADO" ]; then
    echo ""
    echo "✅ Senha já encontrada! Veja: $RESULTADO"
    cat "$RESULTADO"
    echo ""
    exit 0
fi

# ─── Cabeçalho nos logs ────────────────────────────────────

{
    echo ""
    echo "════════════════════════════════════════════════════"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AGENDADOR INICIADO"
    echo "  Janela de execução: ${HORA_INICIO}h às ${HORA_FIM}h"
    echo "  Arquivo: $DOC"
    echo "════════════════════════════════════════════════════"
} | tee -a "$SCHED_LOG" "$LOG"

# ─── CTRL+C encerra tudo limpo ─────────────────────────────

trap '{
    slog "🛑  AGENDADOR ENCERRADO pelo usuário"
    log  "Agendador encerrado pelo usuário"
    parar_crack
    exit 0
}' SIGINT SIGTERM

# ─── Loop principal ────────────────────────────────────────

_ultimo_status=""

while true; do
    if dentro_do_horario; then
        if ! crack_rodando; then
            iniciar_crack
        else
            # Loga "ainda rodando" apenas uma vez por hora
            hora=$(date '+%H')
            status="rodando_${hora}"
            if [ "$status" != "$_ultimo_status" ]; then
                slog "⏳ EM EXECUÇÃO (PID $(cat $PID_FILE 2>/dev/null))"
                _ultimo_status="$status"
            fi
        fi
    else
        if crack_rodando; then
            parar_crack
        else
            hora=$(date '+%H')
            status="dormindo_${hora}"
            if [ "$status" != "$_ultimo_status" ]; then
                slog "😴 AGUARDANDO — fora do horário (${hora}h)"
                _ultimo_status="$status"
            fi
        fi
    fi

    # Verifica se senha foi encontrada
    if [ -f "$RESULTADO" ]; then
        slog "✅  SENHA ENCONTRADA! Veja: $RESULTADO"
        slog "$(cat "$RESULTADO")"
        log  "✅  Senha encontrada. Agendador encerrando."
        parar_crack
        exit 0
    fi

    sleep 60
done
