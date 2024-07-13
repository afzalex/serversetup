#!/bin/bash
set -e
mkdir -p .build

traefik_url='https://github.com/traefik/traefik/releases/download/v3.0.4/traefik_v3.0.4_linux_arm64.tar.gz'
filename=$(basename "$traefik_url")
if test ! -f "$filename"; then
    wget "$traefik_url"
fi

tar -xzvf "$filename"  "traefik"

export TRAEFIK_LOC="$PWD/traefik"
export TRAEFIC_CONFIG_LOC="$PWD/traefik.toml"

envsubst '$TRAEFIK_LOC $TRAEFIC_CONFIG_LOC' < traefik.service.tpl > .build/traefik.service

sudo cp .build/traefik.service /etc/systemd/system/traefik.service

sudo systemctl enable traefik
sudo systemctl start traefik