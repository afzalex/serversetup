#!/bin/bash

sudo apt-get update

sudo apt-get install nginx-light -y

sites_available_dir="${PWD}/sites-available"

sudo mv /etc/nginx/sites-available /etc/nginx/sites-available.bak
sudo ln -s "${sites_available_dir}" /etc/nginx/sites-available

for f in /etc/nginx/sites-available/*; do
  [ -f "$f" ] || continue
  sudo ln -sf "$f" "/etc/nginx/sites-enabled/$(basename "$f")"
done

sudo systemctl reload nginx
