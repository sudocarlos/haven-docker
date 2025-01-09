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
