#!/bin/bash

if [ "$MODE" = "server"]; then
    echo "Starting server"
    exec /app/caddy run --environ --config /app/Caddyfile
elif [ "$MODE" = "client" ]; then
    echo "Starting client"
    exec /app/naive --listen=$LISTEN_ADDR --proxy=$PROXY_SERVER --log
else
    echo "Unknown mode"
    exit 1
fi