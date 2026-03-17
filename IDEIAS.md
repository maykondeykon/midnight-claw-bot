# IDEIAS.md — Repositório de Ideias

_Coisas que surgem durante o dia e merecem ser lembradas._

---

## 📌 Como funciona

- Ideias são adicionadas aqui com data
- Periodicamente (heartbeat), reviso e lembro das pendentes
- Quando uma ideia é implementada ou descartada, marco

---

## 💡 Ideias Pendentes

### 2026-03-16 — Serviço automático de envio de e-mail para filhos
**Status:** Nova
**Descrição:** Usar o servidor do Solar Claw (GCP free tier) para criar um serviço automático de envio de e-mail. Objetivo: enviar vídeos e mensagens aos filhos em datas especiais, mesmo após a partida. O serviço leria um repositório GitHub para links de vídeos não listados no YouTube, um arquivo de configuração com links, e-mail e mensagens, e dispararia o e-mail.
**Próximos passos:**
- Detalhar arquitetura do serviço
- Definir formato do arquivo de configuração
- Implementar serviço no GCP
- Criar repositório GitHub para configurações

---

## ✅ Ideias Implementadas

| Data | Ideia | Resultado |
|------|-------|-----------|
| 2026-03-08 | Integração Google Calendar + Tasks | Script Python criado, lê eventos e tarefas, salva em JSON; incluído no resumo diário |
| 2026-03-03 | Reorganizar tarefas CorteClub no Notion | 20 tarefas recriadas em ordem lógica de implementação FSM |
| 2026-03-03 | Personalidade do Solar Claw | Criado SOUL.md com vibe jovial e empolgado |
| 2026-03-03 | Resumo diário via heartbeat | Gerar resumo diário de notícias (tech, IA, dev, mercado, câmbio) às 08:00 via heartbeat |

---

## ❌ Ideias Descartadas

| Data | Ideia | Motivo |
|------|-------|--------|
| 2026-03-16 | API de comunicação entre Midnight e Solar Claw | Cancelada pelo Maykon |

---

## 📝 Notas

- Adicionar novas ideias no topo da seção "Pendentes"
- Revisar semanalmente no heartbeat
- Mover para "Implementadas" ou "Descartadas" quando resolvido
