#!/bin/bash
set -e
mkdir -p .build/dynamic

traefik_url='https://github.com/traefik/traefik/releases/download/v3.0.4/traefik_v3.0.4_linux_arm64.tar.gz'
filename=$(basename "$traefik_url")
if test ! -f "$filename"; then
    wget "$traefik_url"
fi

tar -xzvf "$filename" -C .build "traefik"

export TRAEFIK_LOC="$PWD/.build"
export TRAEFIK_SSL_LOC="$PWD/ssl"

envsubst '$TRAEFIK_LOC $TRAEFIK_SSL_LOC' < traefik.toml.tpl > .build/traefik.toml
cp *.toml .build/dynamic/
envsubst '$TRAEFIK_LOC' < traefik.service.tpl > .build/traefik.service

sudo cp .build/traefik.service /etc/systemd/system/traefik.service

sudo systemctl daemon-reload
sudo systemctl enable traefik
sudo systemctl start traefik
sudo systemctl status traefik --no-pager