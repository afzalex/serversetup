#!/bin/bash

cp fz-recovery-setup-rc.sh /etc/init.d/fz-recovery-setup
cp fz-recovery-setup.sh /usr/bin/fz-recovery-setup.sh
rm -f /etc/rc2.d/S01fz-recovery-setup
ln -s ../init.d/fz-recovery-setup /etc/rc2.d/S01fz-recovery-setup

mkdir -p /var/log/fz-recovery-setup
chmod -R 777 /var/log/fz-recovery-setup

touch /var/log/fz-recovery-setup/RECOVERY_MODE_FLAG_0_COPYME

