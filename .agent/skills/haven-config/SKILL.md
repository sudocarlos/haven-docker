---
name: haven-config
description: Configuration reference for Haven relay including .env variables, relay JSON files, database engine selection, backup providers, and rate limiter tuning. Use when modifying relay settings, adding new config variables, or debugging configuration issues.
---

# Haven Configuration

All configuration is in `.env` (copy from `.env.example`). No config files are baked into the image.

## Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `OWNER_NPUB` | — | Owner's Nostr public key (npub format) |
| `RELAY_URL` | — | Public-facing relay hostname (no `wss://`) |
| `RELAY_PORT` | `3355` | Port Haven listens on |
| `RELAY_BIND_ADDRESS` | `0.0.0.0` | Bind address (empty string = all interfaces) |
| `DB_ENGINE` | `badger` | `badger` or `lmdb` (lmdb needs NVMe for stability) |
| `LMDB_MAPSIZE` | `0` | 0 = default (~273 GB), or size in bytes |
| `BLOSSOM_PATH` | `blossom/` | Media storage directory inside container |
| `TOR_ENABLED` | `0` | Set to `1` to start a Tor hidden service |

## Relay Sections

Haven runs four relay types, each with its own settings block:

| Relay | Prefix | Purpose |
|-------|--------|---------|
| Private | `PRIVATE_RELAY_*` | Owner drafts and ecash |
| Chat | `CHAT_RELAY_*` | Private messages, WoT-gated |
| Outbox | `OUTBOX_RELAY_*` | Public notes + Blossom media |
| Inbox | `INBOX_RELAY_*` | Interactions with owner's notes |

Each relay section has: `NAME`, `NPUB`, `DESCRIPTION`, `ICON`, and rate limiter vars.

### Rate Limiter Variables (per relay)

| Suffix | Description |
|--------|-------------|
| `EVENT_IP_LIMITER_TOKENS_PER_INTERVAL` | Tokens added per interval |
| `EVENT_IP_LIMITER_INTERVAL` | Interval in seconds |
| `EVENT_IP_LIMITER_MAX_TOKENS` | Burst capacity |
| `ALLOW_EMPTY_FILTERS` | Allow filters with no criteria |
| `ALLOW_COMPLEX_FILTERS` | Allow multi-criteria filters |
| `CONNECTION_RATE_LIMITER_TOKENS_PER_INTERVAL` | Connection tokens per interval |
| `CONNECTION_RATE_LIMITER_INTERVAL` | Connection interval in seconds |
| `CONNECTION_RATE_LIMITER_MAX_TOKENS` | Connection burst capacity |

### Chat-specific

| Variable | Description |
|----------|-------------|
| `CHAT_RELAY_WOT_DEPTH` | Web-of-trust traversal depth |
| `CHAT_RELAY_WOT_REFRESH_INTERVAL_HOURS` | WoT graph refresh interval |
| `CHAT_RELAY_MINIMUM_FOLLOWERS` | Min followers to pass WoT gate |

### Inbox-specific

| Variable | Description |
|----------|-------------|
| `INBOX_PULL_INTERVAL_SECONDS` | How often to pull from other relays |

## Relay JSON Files

- `relays_blastr.json` — list of relay URLs to blast public notes to
- `relays_import.json` — list of relay URLs to import notes from

Both are JSON arrays of relay URL strings. Copy from the `.example` versions.

## Import & Backup

| Variable | Description |
|----------|-------------|
| `IMPORT_START_DATE` | Start date for note import (YYYY-MM-DD) |
| `IMPORT_QUERY_INTERVAL_SECONDS` | Query interval during import |
| `IMPORT_SEED_RELAYS_FILE` | Path to import relays JSON |
| `BACKUP_PROVIDER` | `aws`, `gcp`, or `none` |
| `BACKUP_INTERVAL_HOURS` | Backup frequency |

### AWS backup vars
`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_BUCKET_NAME`

### GCP backup vars
`GCP_BUCKET_NAME`

## Blastr

| Variable | Description |
|----------|-------------|
| `BLASTR_RELAYS_FILE` | Path to blastr relays JSON (default: `relays_blastr.json`) |
