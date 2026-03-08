# IDEIAS.md — Repositório de Ideias

_Coisas que surgem durante o dia e merecem ser lembradas._

---

## 📌 Como funciona

- Ideias são adicionadas aqui com data
- Periodicamente (heartbeat), reviso e lembro das pendentes
- Quando uma ideia é implementada ou descartada, marco

---

## 💡 Ideias Pendentes

### 2026-03-07 — Integração com Gmail para compromissos e tarefas
**Status:** Pendente
**Descrição:** Configurar o Midnight Claw para ler compromissos e lista de tarefas do Gmail do Maykon. Incluir no resumo diário e/ou heartbeat.
**Próximos passos:**
- Verificar API do Google Calendar
- Verificar API do Google Tasks
- Configurar OAuth/credenciais
- Implementar leitura no heartbeat

---

### 2026-03-03 — API de comunicação entre Midnight e Solar Claw
**Status:** Pendente
**Descrição:** Criar uma API no GCP (Solar Claw) pra permitir comunicação direta entre os dois agentes. REST simples com endpoints `/message`, `/status`, `/task`. Pode rodar no Cloud Run (free tier).
**Próximos passos:**
- Definir escopo mínimo (MVP)
- Decidir entre Cloud Run vs Compute Engine
- Especificar endpoints
- Solar Claw implementa

---

### 2026-03-03 — Resumo diário via heartbeat
**Status:** Implementado ✅
**Descrição:** Gerar resumo diário de notícias (tech, IA, dev, mercado, câmbio) às 08:00 via heartbeat ao invés de cron.
**Conclusão:** Gateway não estava rodando, cron falhou. Solução: heartbeat com controle em `memory/heartbeat-state.json`.

---

## ✅ Ideias Implementadas

| Data | Ideia | Resultado |
|------|-------|-----------|
| 2026-03-08 | Integração Google Calendar + Tasks | Script Python criado, lê eventos e tarefas, salva em JSON |
| 2026-03-03 | Reorganizar tarefas CorteClub no Notion | 20 tarefas recriadas em ordem lógica de implementação FSM |
| 2026-03-03 | Personalidade do Solar Claw | Criado SOUL.md com vibe jovial e empolgado |

---

## ❌ Ideias Descartadas

_Nenhuma por enquanto._

---

## 📝 Notas

- Adicionar novas ideias no topo da seção "Pendentes"
- Revisar semanalmente no heartbeat
- Mover para "Implementadas" ou "Descartadas" quando resolvido
