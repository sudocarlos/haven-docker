#!/usr/bin/env bash

LATEST_TAG=$(curl -s "https://api.github.com/repos/bitvora/haven/tags" | jq -r '.[0].name')
MASTER_COMMIT=$(curl -s "https://api.github.com/repos/bitvora/haven/commits" | jq -r '.[0].sha'[:7])

echo LATEST_TAG: $LATEST_TAG
echo MASTER_COMMIT: $MASTER_COMMIT

docker build --load --build-arg TAG=$LATEST_TAG -t haven:latest -t haven:$LATEST_TAG .
docker build --load --build-arg TAG=$MASTER_COMMIT -t haven:master-$MASTER_COMMIT .

wget -q https://raw.githubusercontent.com/bitvora/haven/refs/heads/master/.env.example -O .env.example
wget -q https://raw.githubusercontent.com/bitvora/haven/refs/heads/master/relays_blastr.example.json -O relays_blastr.example.json
wget -q https://raw.githubusercontent.com/bitvora/haven/refs/heads/master/relays_import.example.json -O relays_import.example.json
