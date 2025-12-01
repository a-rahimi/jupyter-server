#!/bin/bash

while true; do
    TOKEN=$(DOCKER_HOST="ssh://ali@server.local" docker exec jupyter-server jupyter server list 2>&1 | \
        sed -nE '/token=/ { s/.*token=([a-z0-9]+).*/\1/p; q; }')

    if [ -n "$TOKEN" ]; then
        echo "$TOKEN"
        break
    fi
    echo "Waiting for token..."
    sleep 1
done