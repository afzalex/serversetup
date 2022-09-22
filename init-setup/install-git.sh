#!/bin/bash

sudo apt-get install -y git

source environment.sh
git config --global user.email "${FZ_EMAIL}"
git config --global user.name "${FZ_NAME}"

git remote set-url origin git@github.com:afzalex/serversetup.git