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
