#!/bin/bash
source environment.sh

DEFAULT_SHARED_DIRECTORY=~/sambashare

sudo apt-get install samba

read -p "Shared Directory (${DEFAULT_SHARED_DIRECTORY}) : " sharedDirectory
if [ -z $sharedDirectory ]
then
    sharedDirectory="${DEFAULT_SHARED_DIRECTORY}"
fi
mkdir -p "${sharedDirectory}"

SAMBA_AUTO_INSTALLER_FLAG_LINE="##_SAMBA_AUTO_INSTALLER_FLAG_##"
sudo cat <<EOT >> /etc/samba/smb.cnf
${_SAMBA_AUTO_INSTALLER_FLAG_}
[sambashare]
    comment = Samba Directory
    path = ${sharedDirectory}
    read only = no
    browsable = yes
EOT

sudo smbpasswd -a ubuntu
