---
name: tor-integration
description: Tor hidden service integration for Haven relay including start.sh entrypoint logic, torrc configuration, and data volume persistence. Use when enabling Tor, debugging hidden service issues, or modifying the container entrypoint.
---

# Tor Integration

Haven can expose the relay as a Tor hidden service, running inside the same container.

## How It Works

The entrypoint `start.sh` checks the `TOR_ENABLED` env var:

```bash
#!/usr/bin/env bash
if [[ "$TOR_ENABLED" == 1 ]]; then
    echo "HiddenServiceDir /var/lib/tor/haven/" >> /etc/tor/torrc
    echo "HiddenServicePort 80 ${RELAY_BIND_ADDRESS}:${RELAY_PORT}" >> /etc/tor/torrc
    tor &
fi
cd /haven
./haven
```

When `TOR_ENABLED=1`:
1. Appends hidden service config to `/etc/tor/torrc`
2. Starts `tor` in the background
3. Haven binds on `RELAY_BIND_ADDRESS:RELAY_PORT` (default `0.0.0.0:3355`)
4. Tor maps port 80 of the `.onion` address to Haven's port

## Persistent State

Tor keys are persisted via the volume mount:

```yaml
- ./data/tor:/var/lib/tor
```

This ensures the `.onion` address survives container restarts. The hidden service hostname is stored at `/var/lib/tor/haven/hostname`.

## Usage

### Enable Tor

Set in `.env`:
```
TOR_ENABLED=1
```

### Start and get the .onion address

```bash
docker compose up -d
docker compose exec haven cat /var/lib/tor/haven/hostname
```

The relay is then available at `ws://<address>.onion`.

## Tor Installation in Dockerfile

Tor is installed from the official Tor Project apt repository (not Debian's package). The Dockerfile adds the Tor Project GPG key and apt source to get the latest stable version.
