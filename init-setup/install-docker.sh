#!/bin/bash

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

read -rp "Portainer-CE (y/n): " PTAIN

if [[ "$PTAIN" == [yY] ]]; then
    echo ""
    echo ""
    PS3="Please choose either Portainer-CE or just Portainer Agent: "
    select _ in \
        " Full Portainer-CE (Web GUI for Docker, Swarm, and Kubernetes)" \
        " Portainer Agent - Remote Agent to Connect from Portainer-CE" \
        " Nevermind -- I don't need Portainer after all."
    do
        PORT="$REPLY"
        case $REPLY in
            1) 
                sudo docker volume create portainer_data
                sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
                exit
                ;;
            2) 
                sudo docker volume create portainer_data
                sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
                exit
                ;;
            *) echo "Invalid selection, please try again..." ;;
        esac
        break
    done
fi