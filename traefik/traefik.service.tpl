[Unit]
Description=Traefik proxy server
After=network.target

[Service]
Type=simple
User=root
ExecStart=${TRAEFIK_LOC}/traefik --configFile=${TRAEFIK_LOC}/traefik.yaml
Restart=always

[Install]
WantedBy=multi-user.target
