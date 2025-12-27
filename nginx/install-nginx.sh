#!/bin/bash

sudo apt-get update

sudo apt-get install nginx-light -y

sites_available_dir="${PWD}/sites-available"

sudo ln -s "${sites_available_dir}" /etc/nginx/sites-available

ls -l "/etc/nginx/sites-available" | while read -r line; do
    sudo ln -s "/etc/nginx/sites-available/${line}" "/etc/nginx/sites-enabled/${line}"
done

sudo systemctl reload nginx