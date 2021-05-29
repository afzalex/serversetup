#!/bin/bash

sdalist=`sudo lsblk | grep -E 'sda[0-9]'`

ls -1 /dev/sda* | grep -E 'sda[0-9]' |
    while read line
    do
        mountDir="/media/`echo $line | grep -oE 'sda[0-1]'`"
        sudo mkdir -p "${mountDir}"
        # TODO: Only mount if not already mounted
        sudo mount "${line}" "${mountDir}" -o umask=000
    done

