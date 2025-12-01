#!/bin/bash

DOCKER_HOST="ssh://ali@server.local" docker logs jupyter-server 2>&1 | \
        grep -o 'http://127.0.0.1:8888/lab?token=[a-zA-Z0-9]*' | \
        tail -n 1 | \
        sed 's/.*token=//'