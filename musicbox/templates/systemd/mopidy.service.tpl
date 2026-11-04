
[Unit]
Description=MusicBox - Mopidy Music Server
Wants=network-online.target bluetooth.service bluealsa.service
After=network-online.target bluetooth.service bluealsa.service

[Service]
Type=simple
User=${SERVICE_USER}
Environment=HOME=${SERVICE_HOME}
WorkingDirectory=${APP_DIR}
ExecStart=${APP_DIR}/run.sh

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

