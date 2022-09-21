#!/bin/bash

sudo apt-get install filebrowser -y

cat <<EOF > /usr/lib/systemd/system/filebrowser.service
[Unit]
Description=FileBrowser

[Service]
ExecStart=/usr/local/bin/filebrowser -a "0.0.0.0" -r /

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl enable filebrowser
sudo systemctl start filebrowser
