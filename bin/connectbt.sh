#!/bin/bash

pulseaudio -k
pulseaudio --start
bluetoothctl -- connect 78:2B:64:FC:CF:33
