#!/bin/bash
source environment.sh

sdalist=`sudo lsblk | grep -E 'sda[0-9]'`

ls -1 /dev/sda* | grep -E 'sda[0-9]' |
    while read line
    do
        mountDir="/media/`echo $line | grep -oE 'sda[0-1]'`"
        sudo mkdir "${mountDir}"
        sudo mount "${line}" "${mountDir}"
    done