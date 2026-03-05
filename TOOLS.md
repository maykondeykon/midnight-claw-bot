# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Docker Containers (EXTREMIS)

| Container | Porta | Propósito |
|-----------|-------|-----------|
| **n8n** | 5678 | Playground pessoal |
| **n8n_main_bia** | 5679 | CorteClub v3 (será desativado) |
| **evolution_api** | 8080 | Evolution API |
| **evolution_bia** | 8081 | Evolution API (Bia/CorteClub) |
| **postgres_bia** | 5432 | PostgreSQL (Bia) |
| **postgres_evo** | 5433 | PostgreSQL (Evolution) |
| **redis_bia** | - | Redis (Bia) |
| **redis_evo** | - | Redis (Evolution) |
| **jellyfin** | 8097, 7359, 8921, 1901 | Media server |
| **qbittorrent** | 8181, 6881/udp | Torrent client |

### Notas
- **CorteClub v4**: Nova implementação com API em Python (em desenvolvimento)
- **CorteClub v3**: n8n_main_bia será desativado quando v4 estiver pronta

---

Add whatever helps you do your job. This is your cheat sheet.
