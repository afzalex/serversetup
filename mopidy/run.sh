#!/bin/bash
source venv/bin/activate

pulseaudio --kill
pulseaudio --start
pactl info
mopidy --config mopidy.config
