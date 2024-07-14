#!/bin/bash

curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

sudo tee /usr/lib/systemd/system/filebrowser.service <<EOF
# FileBrowser Service Unit file
[Unit]
Description=FileBrowser

[Service]
ExecStart=/usr/local/bin/filebrowser -b /browser -r /home/afzalex
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
