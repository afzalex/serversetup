#!/bin/bash

sudo ufw default allow outgoing
sudo ufw default deny incoming

cat /etc/default/ufw | grep IPV6
read -p "Please verify that above output is 'IPV6=yes', otherwise exit this script ..."

sudo ufw allow ssh
sudo ufw limit ssh

sudo ufw enable
sudo systemctl status ufw.service

read -p "Enable DNS Port (y/n): " INPUT; if [[ "$INPUT" == [yY] ]]; then 
    sudo ufw allow 53/tcp comment 'Open port DNS tcp port 53'
    sudo ufw allow 53/udp comment 'Open port DNS udp port 53'
fi

read -p "Enable CUPS Port (y/n): " INPUT; if [[ "$INPUT" == [yY] ]]; then 
    sudo ufw allow CUPS
fi

sudo ufw status numbered

read -p "Continue ..."

sudo ufw reload