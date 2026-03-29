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
7. 📊 **Status dos Projetos** — buscar dados atualizados via `scripts/fetch-project-status.sh`
8. 💡 **Ideias Pendentes** — resumo das ideias em IDEIAS.md (se houver)
9. 📅 **Compromissos** — eventos do Google Calendar (próximos 2 dias)
10. ✅ **Tarefas** — tarefas pendentes do Google Tasks

### Controle:
- Registrar em `memory/heartbeat-state.json` a data/hora do último resumo enviado
- Só enviar uma vez por dia

### Sincronização Notion <-> Project Flow:
- Executar `scripts/sync-notion-projects.sh` para sincronizar tarefas
- Buscar dados do GitHub e atualizar Notion
- Reportar tarefas criadas/atualizadas

---

### Verificação do Backup GitHub:
- Verificar status do backup automático da madrugada:
  - Ler `backup.log` no workspace para ver o resultado
  - Verificar último commit no repositório: `git log -1 --oneline`
  - Confirmar que arquivos foram sincronizados
- Reportar no resumo:
  - ✅ Sucesso: "Backup OK - commit [hash] às [hora]"
  - ❌ Falha: "Backup FALHOU - [erro]"
  - Arquivos sincronizados (qtd de mudanças)

### Verificação de Google (07:00):
- Executar `scripts/update-google-data.sh`
- Ler `memory/google-data.json`
- Incluir compromissos e tarefas no resumo

### Verificação de Ideias:
- Ler `IDEIAS.md` e reportar ideias pendentes
- Se houver ideias novas desde último resumo, destacar

---

### Verificação do crack_letra.log:
- Ler `/media/Documentos/MIDNIGHT RIDER/arquivos/Letras/crack_letra.log`
- Reportar status da quebra de senha:
  - Senha encontrada? (destacar em caso positivo)
  - Progresso atual (fase, % completado, senhas testadas)
  - Próxima etapa prevista

---

### Verificação de Projetos:
- Buscar dados atualizados dos projetos via API do GitHub:
  ```bash
  curl -s -H "Authorization: token $(cat ~/.config/github/pat_deykonsolutions)" \
    "https://api.github.com/repos/deykonsolutions/corteclub-api/contents/project-flow.json" | jq -r '.content' | base64 -d
  ```
- Repetir para: `gopdv-backend`, `gopdv-frontend`, `gopdv-infra`
- Apresentar no resumo diário:
  - Progresso de cada projeto (features completas vs pendentes)
  - Tarefas críticas e de alta prioridade pendentes
  - Features em andamento
  - Comparar com resumo anterior (houve progresso?)
- Projetos a monitorar:
  - **CorteClub API** (ativo)
  - **GoPDV Backend** (pausado - priorizar Fluxo de Caixa e Backup)
  - **GoPDV Frontend** (quase completo - Customer Display pendente)
  - **GoPDV Infra** (ativo)

---

# Outras verificações (durante o dia)

- Verificar se há tarefas próximas do prazo
- Verificar calendário para compromissos nas próximas 24h
- **Verificar mensagens do Solar Claw** na inbox (`memory/solar-inbox.json`)
  - Se houver mensagens, processar e responder
  - Marcar como processadas no Supabase
