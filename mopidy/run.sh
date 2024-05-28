#!/bin/bash
source venv/bin/activate

pulseaudio -k
pulseaudio --start
pactl info
mopidy --config mopidy.config
