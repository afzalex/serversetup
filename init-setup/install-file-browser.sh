#!/bin/bash

sudo apt-get install filebrowser -y

cat <<EOF > /usr/lib/systemd/system/filebrowser.service
# FileBrowser Service Unit file
[Unit]
Description=FileBrowser

[Service]
ExecStart=/usr/local/bin/filebrowser -r / 
# ExecStart=/usr/local/bin/filebrowser -r /home/pi
# WorkingDirectory=/home/pi
# User=pi
# Group=pi

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload
sudo systemctl enable filebrowser
sudo systemctl start filebrowser
