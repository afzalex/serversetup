#!/bin/bash
# Reference: https://docs.docker.com/engine/install/debian/

# Remove old docker installations
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

# Ask user if they want to use docker without sudo
echo ""
read -p "Do you want to use Docker without sudo? (y/n): " USE_DOCKER_WITHOUT_SUDO
if [ "$USE_DOCKER_WITHOUT_SUDO" = "y" ] || [ "$USE_DOCKER_WITHOUT_SUDO" = "Y" ]; then
    echo "Adding user '$USER' to docker group..."
    sudo usermod -aG docker $USER
    echo "User '$USER' has been added to the docker group."
    echo ""
    echo "Note: You may need to log out and log back in for the changes to take effect."
    echo "Alternatively, you can run 'newgrp docker' in your current session."
else
    echo "Skipping docker group configuration. You will need to use 'sudo docker' for docker commands."
fi
