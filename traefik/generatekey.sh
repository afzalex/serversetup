#!/bin/bash
# This script is used to generate a SSL key that is encrypted with a password
# and then decrypt it using the password
#
# Usage:
# ./generatekey.sh
#
# This will generate a SSL key in the current directory
# 
# To create the encrypted file, run the following command:
# openssl aes-256-cbc -e -in fzbox.local.key -out fzbox.local.key.enc -iter 1000 -a
#

openssl aes-256-cbc -d -in fzbox.local.key.enc -iter 1000 -a -out fzbox.local.key