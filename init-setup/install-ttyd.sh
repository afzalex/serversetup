#!/bin/bash

sudo apt-get update

sudo apt-get install -y ttyd

# Remove the TTYD_OPTIONS line from the /etc/default/ttyd file
sudo sed -i '/^TTYD_OPTIONS=/d' /etc/default/ttyd

# Add the TTYD_OPTIONS line to the /etc/default/ttyd file
echo "TTYD_OPTIONS=\"-i lo -p 7681 -b /ttyd --writable /bin/bash\"" \
    | sudo tee -a /etc/default/ttyd >/dev/null

sudo tee /etc/systemd/system/ttyd.service.d/override.conf > /dev/null <<EOF
[Service]
User=$USER
Group=$(id -gn)
WorkingDirectory=/home/$USER
Environment=HOME=/home/$USER
Environment=USER=$USER
Environment=LOGNAME=$USER
EOF

sudo systemctl daemon-reload
sudo systemctl restart ttyd
sudo systemctl status ttyd
sudo systemctl enable ttyd