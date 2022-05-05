#!/bin/bash
# Ref: https://phoenixnap.com/kb/raspberry-pi-dns-server
# Ref: https://stevessmarthomeguide.com/home-network-dns-dnsmasq/

source updateos.sh

sudo apt-get install dnsmasq -y
sudo apt-get install gettext-base -y

/bin/cat ../templates/dnsmasq.conf | /usr/bin/envsubst | sudo tee /etc/dnsmasq.conf > /dev/null

sudo systemctl restart dnsmasq