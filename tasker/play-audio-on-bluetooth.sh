#!/bin/bash
# Ref: https://computingforgeeks.com/connect-to-bluetooth-device-from-linux-terminal/
# Ref: https://unix.stackexchange.com/questions/258074/error-when-trying-to-connect-to-bluetooth-speaker-org-bluez-error-failed


sudo apt-get install -y bluetooth bluez bluez-tools rfkill

sudo usermod -aG lp $USER

# TODO: Need to fix issue of running newgrp in bash
#newgrp lp

sudo apt-get install -y pulseaudio-module-bluetooth 

pulseaudio -k
pulseaudio --start

connectedDevicesCount=$(bluetoothctl -- devices | cut -f2 -d' ' | while read uuid; do bluetoothctl -- info "$uuid"; done | grep -oe "Connected: yes" | wc -l)

if [[ $connectedDevicesCount == 0 ]]; then

    bluetoothctl -- show
    bluetoothctl -- power on
    bluetoothctl -- scan on

    echo -e "\n"
    read -p "Device to connect: " DEVICETOCONNECT
    echo $DEVICETOCONNECT is selected

    bluetoothctl -- trust "$DEVICETOCONNECT"
    bluetoothctl -- pair "$DEVICETOCONNECT"
    bluetoothctl -- connect "$DEVICETOCONNECT"
    
fi

cat ../samples/music-sample.mp3 | ffplay -nodisp -

