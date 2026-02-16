---
name: docker-packaging
description: Dockerfile multi-stage build, compose.yml service config, image tagging, volume mounts, and resource limits for the haven-docker project. Use when modifying the Docker build, changing volumes, updating compose settings, or troubleshooting container issues.
---

# Docker Packaging

## Dockerfile

Multi-stage build in `Dockerfile`:

1. **Builder stage** (`golang` base):
   - Clones `bitvora/haven`, checks out the `TAG` arg
   - Runs `go install -v`

2. **Runtime stage** (`debian:stable-slim`):
   - Installs curl, gpg, ca-certificates, build-essential, Tor
   - Copies built Go binary and Haven source from builder
   - Copies `start.sh` as entrypoint
   - Exposes port `3355`

### Version pinning

```dockerfile
ARG TAG=v1.2.0-rc2
ARG COMMIT=986c21b79c93779a449a52f6414ea267c83428bb
```

To update Haven version: change `TAG` and `COMMIT` at the top of the `Dockerfile`.

## compose.yml

Single service `haven`:

```yaml
services:
  haven:
    container_name: haven
    image: sudocarlos/haven:main
    build: .
    env_file: .env
    ports:
      - 3355:3355
    volumes:
      - ./data/blossom:/haven/blossom   # Media storage
      - ./data/db:/haven/db             # Database files
      - ./relays_blastr.json:/haven/relays_blastr.json
      - ./relays_import.json:/haven/relays_import.json
      - ./data/tor:/var/lib/tor         # Tor hidden service state
    restart: unless-stopped
    init: true
    deploy:
      resources:
        limits:
          memory: 2GB
```

### Key details

- `init: true` ensures proper PID 1 signal handling
- Memory limit is 2 GB — increase if using lmdb with large datasets
- All persistent data lives under `./data/` on the host
- Relay JSON files are bind-mounted directly (not inside `data/`)

## Common Tasks

### Rebuild after Dockerfile changes

```bash
docker compose build --no-cache
docker compose up -d
```

### View container resource usage

```bash
docker stats haven
```

## Testing

Run the full image test suite:

```bash
make test
```

Tests are in `tests/test-image.sh` (TAP output). They validate:
- Image builds successfully
- Required binaries exist (`haven`, `curl`, `tor`, `bash`)
- `start.sh` entrypoint is executable
- Env validation rejects missing `OWNER_NPUB` / `RELAY_URL`
- Haven process starts and port 3355 responds
- Docker healthcheck passes
- Container shuts down gracefully

Tests use `.env.test` (minimal config) and clean up containers on exit.
