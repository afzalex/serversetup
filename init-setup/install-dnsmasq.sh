#!/bin/bash
# Ref: https://phoenixnap.com/kb/raspberry-pi-dns-server
# Ref: https://stevessmarthomeguide.com/home-network-dns-dnsmasq/

sudo apt-get install dnsmasq -y
sudo apt-get install gettext-base -y

# Create DNS-only configuration for dnsmasq
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
# DNS-only configuration for dnsmasq
# Other features (DHCP, TFTP, PXE) are commented out

# Listen on this specific port instead of the standard DNS port (53).
# Setting this to zero completely disables DNS function.
#port=5353

# Never forward plain names (without a dot or domain part)
# domain-needed

# Never forward addresses in the non-routed address spaces.
bogus-priv

# DNSSEC validation and caching (commented out - requires dnsmasq built with DNSSEC)
#conf-file=%%PREFIX%%/share/dnsmasq/trust-anchors.conf
#dnssec
#dnssec-check-unsigned

# Filter useless windows-originated DNS requests (commented out)
#filterwin2k

# Don't read /etc/resolv.conf, use servers specified below
no-resolv

# Don't poll /etc/resolv.conf for changes
#no-poll

# Upstream DNS servers
server=8.8.8.8
server=8.8.4.4

# Local-only domains - queries answered from /etc/hosts or DHCP only
local=/home/

# Force domains to specific IP addresses (commented out)
#address=/double-click.net/127.0.0.1

# Read /etc/hosts
#no-hosts

# Cache size
cache-size=1000

# Disable negative caching (commented out)
#no-negcache

# DHCP features (all commented out - DNS only)
#dhcp-range=192.168.0.50,192.168.0.150,12h
#dhcp-host=11:22:33:44:55:66,192.168.0.60
#dhcp-option=3,1.2.3.4
#dhcp-authoritative
#dhcp-rapid-commit
#dhcp-script=/bin/echo
#dhcp-leasefile=/var/lib/misc/dnsmasq.leases

# TFTP features (all commented out - DNS only)
#enable-tftp
#tftp-root=/var/ftpd
#tftp-secure

# PXE boot features (all commented out - DNS only)
#dhcp-boot=pxelinux.0
#pxe-prompt="Press F8 for menu.", 60
#pxe-service=x86PC, "Install Linux", pxelinux

# Logging (commented out by default)
#log-queries
#log-dhcp
EOF

sudo systemctl restart dnsmasq
sudo systemctl enable dnsmasq
sudo systemctl status dnsmasq

