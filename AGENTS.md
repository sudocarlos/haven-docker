# haven-docker — Agent Reference

Docker packaging layer for [bitvora/haven](https://github.com/bitvora/haven), a personal Nostr relay with private, chat, outbox, and inbox relay support.

## Repo Structure

```
haven-docker/
├── AGENTS.md                       # You are here
├── Dockerfile                      # Multi-stage build: Go builder → Debian slim + Tor
├── compose.yml                     # Single-service Docker Compose config
├── start.sh                        # Entrypoint — optional Tor, then run Haven
├── .env.example                    # All configuration (99 vars, env-only config)
├── relays_blastr.example.json      # Seed relay lists for blastr
├── relays_import.example.json      # Seed relay lists for import
├── Makefile                        # Dev, test, and release targets
├── data/                           # Runtime data (mounted volumes)
│   ├── blossom/                    #   Blossom media storage
│   ├── db/                         #   Database (badger or lmdb)
│   └── tor/                        #   Tor hidden service keys
└── .github/workflows/
    └── docker-publish.yml          # CI: build, push to GHCR, cosign
```

## Key Constraints

- **Upstream**: Haven source is [bitvora/haven](https://github.com/bitvora/haven). This repo only packages it — do not modify Haven's Go code here.
- **Config model**: All configuration flows through `.env` → container env vars. No config files inside the image.
- **Single container**: One service in `compose.yml`. Tor runs inside the same container when enabled.
- **Version pinning**: The Haven version is set via `ARG TAG=` and `ARG COMMIT=` in the `Dockerfile`.

## Skills

| Skill | Path | Purpose |
|-------|------|---------|
| docker-packaging | `.agent/skills/docker-packaging/` | Dockerfile, compose, builds, volumes |
| haven-config | `.agent/skills/haven-config/` | `.env` variables, relay JSONs, tuning |
| ci-cd | `.agent/skills/ci-cd/` | GitHub Actions, Makefile release, signing |
| tor-integration | `.agent/skills/tor-integration/` | Tor hidden service setup |
