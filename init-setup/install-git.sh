#!/bin/bash

sudo apt-get install -y git

source environment.sh
git config --global user.email "${FZ_EMAIL}"
git config --global user.name "${FZ_NAME}"
git config --global pull.rebase false

git remote set-url origin git@github.com:afzalex/serversetup.git

curl https://www.afzalex.com/scripts/install-flog.sh | /bin/bash