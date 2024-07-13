#!/bin/bash
set -e
traefik_url='https://github.com/traefik/traefik/releases/download/v3.0.4/traefik_v3.0.4_linux_arm64.tar.gz'
filename=$(basename "$traefik_url")
if test ! -f "$filename"; then
    wget "$traefik_url"
fi

tar -xzvf "$filename"  "traefik"


