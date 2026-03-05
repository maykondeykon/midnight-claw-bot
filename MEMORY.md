# MEMORY.md - Memória de Longo Prazo

## Configurações Importantes

### Resumo Diário (Heartbeat)
- **Horário**: 08:00 (Lisboa)
- **Conteúdo**: Tecnologia (5), IA (5), Desenvolvimento (5), Mercado Tech, EUR/BRL
- **Arquivo de controle**: `memory/heartbeat-state.json`
- **Instruções**: `HEARTBEAT.md`
- **Configurado em**: 2026-03-03
- **Nota**: Não usar cron — o gateway não estava rodando e o cron não disparou. Heartbeat é mais confiável.

### Backup GitHub (Automático)
- **Repositório**: https://github.com/maykondeykon/midnight-claw-bot.git
- **Horário**: 03:00 (madrugada)
- **Script**: `~/.openclaw/workspace/backup.sh`
- **Log**: `~/.openclaw/workspace/backup.log`
- **Cron**: `0 3 * * *`
- **Configurado em**: 2026-03-05
- **Nota**: Token de acesso já configurado no remote

### Comunicação Solar Claw (Supabase)
- **URL**: https://jkduxrrpsikxjcqnalzh.supabase.co
- **Tabela**: messages
- **Meu ID**: midnight-claw
- **Solar ID**: solar-claw
- **Config**: `~/.config/supabase/solar-messaging.json`
- **Script**: `~/.openclaw/workspace/scripts/supabase-messaging.sh`
- **Configurado em**: 2026-03-05

---

## Projetos Ativos

### CorteClub
- **Status**: Em desenvolvimento
- **v3**: n8n_main_bia (será descontinuado)
- **v4**: API Python em desenvolvimento
- **Repo**: https://github.com/deykonsolutions/corteclub-api.git
- **Notion Project ID**: 30f38d59-393c-8143-ac9a-ce783942a1c2

### GoPDV
- **Status**: Em andamento
- **Repos**: gopdv-landingpage, gopdv-backend, gopdv-frontend, gopdv-infra

---

## Notion

- **API Version**: 2025-09-03
- **API Key**: ~/.config/notion/api_key
- **Tasks Database (data_source_id)**: 30e38d59-393c-817b-bb75-000b3b2d267f
- **Projects Database (data_source_id)**: 30f38d59-393c-8193-b000-000b7636ea40
- **Projects Database**: 30f38d59-393c-818f-bd8c-e12ddbb78dd3
- **Status "A Fazer" ID**: 4c2e4866-4b3a-45f1-8b94-b6b9b37a0c6a
- **Status "Feito" ID**: 310c1664-4c44-406c-8e41-bee44a2951bb

---

## Infraestrutura Docker (EXTREMIS)

| Container | Porta | Propósito |
|-----------|-------|-----------|
| n8n | 5678 | Playground pessoal |
| n8n_main_bia | 5679 | CorteClub v3 (será desativado) |
| evolution_api | 8080 | Evolution API |
| evolution_bia | 8081 | Evolution API (Bia/CorteClub) |
| postgres_bia | 5432 | PostgreSQL (Bia) |
| postgres_evo | 5433 | PostgreSQL (Evolution) |
| redis_bia | - | Redis (Bia) |
| redis_evo | - | Redis (Evolution) |
| jellyfin | 8097, 7359, 8921, 1901 | Media server |
| qbittorrent | 8181, 6881/udp | Torrent client |
