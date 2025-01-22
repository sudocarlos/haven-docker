# HAVEN unofficial docker repo

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

### Import notes

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
    2025/01/22 04:41:01 📦 imported 12345 tagged notes
    2025/01/22 04:41:01 ✅ tagged import complete. please restart the relay
    ```

1. Exit, stop and start the container

    ```bash
    # Ctrl + C to exit the container

    docker compose down
    docker compose up -d --remove-orphans
    ```
