#!/bin/bash

if ! command -v sshpass > /dev/null
then 
    brew install hudochenkov/sshpass/sshpass
fi

if [ -z $host ]; then read -p "Host : " host; fi;
if [ -z $user ]; then read -p "Login username : " user; fi;
if [ -z $pass ]; then read -s -p "Login password : " pass; fi;

sshpass -p "${pass}" ssh-copy-id ${user}@${host} > /dev/null

if [ -z "`ssh ${user}@${host} 'ls serversetup'`" ]
then 
    pushd .
    cd ..
    tar -czvf /tmp/serversetup.tar.gz ./
    popd 
    scp /tmp/serversetup.tar.gz ${user}@${host}:./

    ssh ${user}@${host} 'tar -xzvf serversetup.tar.gz --transform "s/./serversetup/"; rm serversetup.tar.gz' 
fi

ssh -t ${user}@${host} "cd ./serversetup; bash --login"

