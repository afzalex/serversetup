[Unit]
Description=Traefik proxy server
After=network.target

[Service]
Type=simple
User=afzalex
ExecStart=${TRAEFIK_LOC} --configFile=${TRAEFIC_CONFIG_LOC}
Restart=always

[Install]
WantedBy=multi-user.target
