#!/bin/bash

sudo apt-get update

sudo apt-get install -y ca-certificates curl gnupg

sudo curl -fsSL https://www.authelia.com/keys/authelia-security.gpg -o /usr/share/keyrings/authelia-security.gpg

gpg --no-default-keyring --keyring /usr/share/keyrings/authelia-security.gpg --list-keys --with-subkey-fingerprint

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/authelia-security.gpg] https://apt.authelia.com stable main" | \
  sudo tee /etc/apt/sources.list.d/authelia.list > /dev/null

sudo apt-get update

sudo apt-get install -y authelia

sudo systemctl status authelia
sudo systemctl enable authelia
sudo systemctl start authelia