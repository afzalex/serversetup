#!/bin/bash

if [ $temp_isupdated == 'true' ]
then 
    echo updating apt-get ...
    sudo apt-get update
    sudo apt-get upgrade
fi
export temp_isupdated=true