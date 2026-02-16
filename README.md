# HAVEN unofficial docker repo

[![Docker](https://github.com/sudocarlos/haven-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sudocarlos/haven-docker/actions/workflows/docker-publish.yml)

This repo is used to maintain a docker image of [bitvora/haven](https://github.com/bitvora/haven).


## Usage

1. Create copies of the example files in this repo

    ```bash
    cp relays_blastr.example.json relays_blastr.json
    cp relays_import.example.json relays_import.json
    cp .env.example .env
    ```

1. Change the values in `.env`
1. Start the relay with docker compose

    ```bash
    docker compose up -d
    docker logs -f haven # follow container logs
    ```


## Enabling Tor

1. Set `TOR_ENABLED=1` in `.env`
1. Start the relay with docker compose

    ```bash
    docker compose up -d
    docker logs -f haven # follow container logs
    ```

1. View your hidden service address

    ```bash
    docker compose exec haven cat /var/lib/tor/haven/hostname
    ```

1. Haven will be available at `ws://<hidden-service-address>.onion`


## Migrating from databases created in older versions of Haven

Haven versions 1.0.3 and earlier did not replace outdated notes. While this does not impact the relay's core 
functionality, it can lead to a bloated database, reduced performance, and bugs in certain clients. For this reason, it
is recommended to delete old databases and start fresh, optionally [re-importing](#import-notes) previous notes.


## Import notes

1. Stop the container

    ```bash
    docker compose down
    ```

1. Start the container with `docker compose run`

    ```bash
    docker compose run haven --import
    ```

1. Wait for the import process to complete

    ```bash
    2025/01/22 04:40:35 📦 importing notes
    2025/01/22 04:40:40 📦 imported 22 owner notes
    ...
    2025/01/22 04:41:01 ✅ owner note import complete! 
    2025/01/22 04:41:01 📦 importing inbox notes, please wait 2 minutes
    2025/01/22 04:41:01 📦 imported 2797 tagged notes
    2025/01/22 04:41:01 ✅ tagged import complete. please restart the relay
    ```

1. Exit, stop and start the container

    ```bash
    # Ctrl + C to exit the container

    docker compose down
    docker compose up -d --remove-orphans
    ```


## Development

A `Makefile` provides common shortcuts:

```bash
make help      # Show all available targets
make build     # Build the image
make dev       # Build (no cache), start, and tail logs
make up        # Start the container
make down      # Stop the container
make logs      # Tail container logs
make test      # Run the automated test suite
make clean     # Remove stopped containers and dangling images
make version   # Print the current Haven version
```


## Testing

The test suite validates the Docker image builds and runs correctly. No external dependencies — all tests are self-contained.

```bash
make test
```

This runs `tests/test-image.sh`, which verifies:

| Test | What it checks |
|------|----------------|
| Build | Image builds successfully |
| Binaries | `haven`, `curl`, `tor`, `bash` are present |
| Entrypoint | `start.sh` is executable |
| Env validation | Container rejects missing `OWNER_NPUB` / `RELAY_URL` |
| Process | Haven process starts inside the container |
| Port | Port 3355 responds to HTTP |
| Healthcheck | Docker healthcheck reports healthy |
| Shutdown | Container responds to SIGTERM gracefully |

Tests use `.env.test` (a minimal, unquoted copy of `.env.example`) and empty relay lists to avoid network calls. Containers and images are cleaned up automatically on exit.


## CI/CD

GitHub Actions (`.github/workflows/docker-publish.yml`) runs on pushes to `main`, tags, and PRs:

1. **Test job** — runs `make test` to validate the image
2. **Build job** — pushes to GHCR and signs with cosign (only if tests pass, skipped on PRs)


## Contributing

1. Fork and clone the repo
2. Copy the example files:
    ```bash
    cp .env.example .env
    cp relays_blastr.example.json relays_blastr.json
    cp relays_import.example.json relays_import.json
    ```
3. Make your changes
4. Run the tests: `make test`
5. Open a PR against `main`

### Project structure

```
haven-docker/
├── Dockerfile                  # Multi-stage build: Go builder → Debian slim + Tor
├── compose.yml                 # Single-service Docker Compose config
├── start.sh                    # Entrypoint — env validation, optional Tor, then Haven
├── Makefile                    # Dev/test/release shortcuts
├── .env.example                # All configuration variables
├── .env.test                   # Minimal env for automated tests
├── relays_*.example.json       # Seed relay lists
├── tests/
│   └── test-image.sh           # Automated image test suite
├── data/                       # Runtime data (mounted volumes)
└── .github/workflows/
    └── docker-publish.yml      # CI: test → build → push to GHCR → cosign
```

> **Note:** This repo only packages [bitvora/haven](https://github.com/bitvora/haven) — it does not modify Haven's Go source code. All configuration is done through environment variables in `.env`.
