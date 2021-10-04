#!/bin/bash

#   It will be installed at these locations:
#
#    - the daemon     at /usr/sbin/netdata
#    - config files   in /etc/netdata
#    - web files      in /usr/share/netdata
#    - plugins        in /usr/libexec/netdata
#    - cache files    in /var/cache/netdata
#    - db files       in /var/lib/netdata
#    - log files      in /var/log/netdata
#    - pid file       at /var/run/netdata.pid
#    - logrotate file at /etc/logrotate.d/netdata
#
# /usr/libexec/netdata/netdata-uninstaller.sh

bash <(curl -Ss https://my-netdata.io/kickstart.sh)
