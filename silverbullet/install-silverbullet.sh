#!/bin/bash

ARCH=$(uname -m)
case "$ARCH" in
  x86_64)
    FILE="silverbullet-server-linux-x86_64.zip"
    ;;
  aarch64)
    FILE="silverbullet-server-linux-aarch64.zip"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Download the zip file
wget "https://github.com/silverbulletmd/silverbullet/releases/download/2.3.0/$FILE"

# Extract the zip file
unzip -o "$FILE"

# Create notes directory
mkdir -p $PWD/notes

# Create systemd service file
sudo tee /etc/systemd/system/silverbullet.service > /dev/null <<EOF
[Unit]
Description=SilverBullet server
After=network-online.target
Wants=network-online.target

[Service]
User=$USER
Group=$(id -gn)
WorkingDirectory=$PWD
Environment=SB_URL_PREFIX=/notes
Environment=SB_HOSTNAME=0.0.0.0
Environment=SB_FOLDER=$PWD/notes
ExecStart=$PWD/silverbullet
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable/start the service
sudo systemctl daemon-reload
sudo systemctl enable silverbullet
sudo systemctl start silverbullet
sudo systemctl status silverbullet
