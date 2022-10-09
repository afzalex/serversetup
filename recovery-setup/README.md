Run install-fz-recovery-setup.sh when first time using it on a linux system.

To run a script on startup after n reboots, edit /var/log/fz-recovery-setup.sh file.   
This file will be called on boot with root user.

To trigger execution of /var/log/fz-recovery-setup.sh, Create a flag in /var/log/fz-recovery-setup/RECOVERY_MODE_FLAG_1.
In above example flag, execution will be done after 1 reboot.

General format is :
/var/log/fz-recovery-setup/RECOVERY_MODE_FLAG_<n>