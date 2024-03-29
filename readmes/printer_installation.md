# Installation of printer driver in raspberry pi
Install cups and lsb, add lpadmin group to your user

```sh
sudo apt-get install cups -y
sudo apt-get install lsb -y
sudo usermod -a -G lpadmin pi
```

Make cups ui accessible from remote machines
```sh
sudo cupsctl --remote-admin
sudo cupsctl --remote-any
#sudo cupsctl --share-printers
```


Install printer drivers
```sh
sudo apt-get install printer-driver-escpr
```

Install and configure samba
```sh
sudo apt-get install samba
```
Add a user to allow for printing.
```sh
sudo useradd sheikhs
sudo smbpasswd -a sheikhs
```
Update printers section in /etc/samba/smb.conf
```sh
[printers]
   comment = All Printers
   browseable = yes
   path = /var/tmp
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700
```

# Printer installation and sharing via Samba

Download software :
https://download.ebz.epson.net/dsc/search/01/search/?OSC=LX
https://download.ebz.epson.net/dsc/search/01/search/searchModule

To add printer in mac :
1. Go to "Printer and Scanner" from "System Preferences"
2. Add "Advanced" tab by right clicking and selecting "Customize Toolbar" and then adding "Advanced" icon
3. Go to "Advanced" tab 
4. Now enter following values in prompted fields :
    - Type: Windows printer via spoolss
    - Device: Another Device
    - URL: smb://<ip_address>/<printer_name> 
        e.g. smb://192.168.29.205/EPSON_L3100_Series
    - Name: Any name that you want
        e.g. Epson Printer
    - Location: Any location name that you want
        e.g. raspi
    - Use: "Select Software" > "L3100"
