#!/bin/bash

sudo apt-get update

sudo apt-get install -y cockpit

# Optional: Install common Cockpit plugins
read -p "Install Cockpit plugins (docker, networkmanager, etc.)? (y/n): " INSTALL_PLUGINS
if [[ "$INSTALL_PLUGINS" == [yY] ]]; then
    sudo apt-get install -y \
        cockpit-docker \
        cockpit-networkmanager \
        cockpit-packagekit \
        cockpit-storaged \
        cockpit-system
fi

# Enable and start Cockpit service
sudo systemctl enable cockpit.socket
sudo systemctl start cockpit.socket
sudo systemctl status cockpit.socket

echo ""
echo "Cockpit is now installed and running."
echo "Access it at: https://$(hostname -I | awk '{print $1}'):9090"
echo "or: https://localhost:9090"
echo ""
echo "Note: You may need to allow port 9090 in your firewall:"
echo "  sudo ufw allow 9090/tcp"
