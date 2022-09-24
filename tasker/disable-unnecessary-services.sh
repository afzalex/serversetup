#!/bin/bash

systemctl disable --now snapd.socket
systemctl disable --now snapd
systemctl disable --now snapd.seeded
systemctl disable --now snap.lxd.activate
systemctl disable --now snapd.apparmor.service
systemctl disable --now keyboard-setup.service
systemctl disable --now hciuart.service

systemctl disable --now cloud-init
systemctl disable --now cloud-init-local
systemctl disable --now cloud-config
systemctl disable --now cloud-final