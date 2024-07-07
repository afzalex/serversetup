#!/bin/bash

source updateos.sh

sudo apt-get install nginx -y

sudo copy -r ../nginx/sites-available/* /etc/nginx/sites-available
sudo copy -r ../nginx/ssl /etc/nginx/

sudo ln -s /etc/nginx/sites-available/mopidy /etc/nginx/sites-enabled/mopidy

sudo systemctl reload nginx