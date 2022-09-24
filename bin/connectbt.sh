#!/bin/bash

if [[ "$(systemctl is-active hciuart)" != "active" ]]; then 
    sudo systemctl start hciuart
    sudo systemctl start bluetooth
fi

pulseaudio -k
pulseaudio --start
bluetoothctl -- connect 78:2B:64:FC:CF:33
