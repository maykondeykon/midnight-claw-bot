# HEARTBEAT.md

## Resumo Diário (08:00 - Horário de Lisboa)

Se estiver entre 07:55 e 08:15 e ainda não foi enviado o resumo hoje, gerar e enviar:

### Conteúdo do Resumo:
1. 📰 **Tecnologia Geral** — 5 notícias relevantes
2. 🤖 **IA** — 5 novidades de inteligência artificial
3. 💻 **Desenvolvimento** — 5 atualizações do mundo dev
4. 📊 **Mercado Tech** — panorama rápido
5. 💰 **Cotação** — EUR → BRL atualizada
6. 🌙 **Backup GitHub** — status do backup automático da madrugada
7. 💡 **Ideias Pendentes** — resumo das ideias em IDEIAS.md (se houver)
8. 📅 **Compromissos** — eventos do Google Calendar (próximos 2 dias)
9. ✅ **Tarefas** — tarefas pendentes do Google Tasks

### Controle:
- Registrar em `memory/heartbeat-state.json` a data/hora do último resumo enviado
- Só enviar uma vez por dia

### Verificação de Tarefas Noturnas:
- Backup automático para GitHub (último commit, arquivos sincronizados)
- Outras tarefas agendadas (verificar logs/systemd)
- Reportar sucesso ou falha

### Verificação de Ideias:
- Ler `IDEIAS.md` e reportar ideias pendentes
- Se houver ideias novas desde último resumo, destacar

---

# Outras verificações (durante o dia)

- Verificar se há tarefas próximas do prazo
- Verificar calendário para compromissos nas próximas 24h
- **Verificar mensagens do Solar Claw** na inbox (`memory/solar-inbox.json`)
  - Se houver mensagens, processar e responder
  - Marcar como processadas no Supabase
