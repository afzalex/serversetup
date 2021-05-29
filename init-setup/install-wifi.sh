#!/bin/bash
# Ref: https://huobur.medium.com/how-to-setup-wifi-on-raspberry-pi-4-with-ubuntu-20-04-lts-64-bit-arm-server-ceb02303e49b

source updateos.sh

sudo apt-get install net-tools

wifiCardName=`ls -1 /sys/class/net | grep 'wlan'`
sudo ifconfig "$wifiCardName" up

read -p "Wifi SSID : " wifiSsid
read -s -p "Wifi Password : " wifiPassword 

WIFI_AUTO_INSTALLER_FLAG_LINE="##_WIFI_AUTO_INSTALLER_FLAG_##"

sudo cat <<EOT >> /etc/netplan/50-cloud-init.yaml
${WIFI_AUTO_INSTALLER_FLAG_LINE}
    wifis:
        ${wifiCardName}:
            optional: true
            access-points:
                "${wifiSsid}":
                    password: "$wifiPassword"
            dhcp4: true
EOT

