#!/bin/bash

sudo apt-get update

sudo apt-get install -y ttyd

# Remove the TTYD_OPTIONS line from the /etc/default/ttyd file
sudo sed -i '/^TTYD_OPTIONS=/d' /etc/default/ttyd

UID=$(id -u)
GID=$(id -g)
# Add the TTYD_OPTIONS line to the /etc/default/ttyd file
echo "TTYD_OPTIONS=\"-u ${UID} -g ${GID} -i lo -p 7681 -b /ttyd --writable /bin/bash\"" \
    | sudo tee -a /etc/default/ttyd >/dev/null

sudo systemctl restart ttyd
sudo systemctl status ttyd
sudo systemctl enable ttyd