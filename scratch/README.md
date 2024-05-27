fz-portable-speaker id : 78:2B:64:FC:CF:33


sudo vim /etc/systemd/system/mopidy.service
sudo vim /lib/systemd/system/mopidy.service

[Unit]
Description=Mopidy music server
After=avahi-daemon.service
After=dbus.service
After=network-online.target
Wants=network-online.target
After=nss-lookup.target
After=pulseaudio.service
After=remote-fs.target
After=sound.target

[Service]
#User=mopidy
User=afzalex
PermissionsStartOnly=true
Environment="PULSE_SERVER=/run/user/1000/pulse/native"
ExecStartPre=/bin/mkdir -p /var/cache/mopidy
ExecStartPre=/bin/chown mopidy:audio /var/cache/mopidy
#ExecStart=/usr/bin/mopidy --config /usr/share/mopidy/conf.d:/etc/mopidy/mopidy.conf
ExecStart=mopidy

[Install]
WantedBy=multi-user.target



sudo systemctl daemon-reload
sudo systemctl enable mopidy
sudo systemctl start mopidy

sudo systemctl status mopidy


Instead of using pactl pulseaudio and bluez use pipewire, pipewire-pulse


gstreamer1.0-python3-plugin-loader
gstreamer1.0-tools
sudo apt-get install gir1.2-playerctl-2.0

sudo python3 -m pip install --break-system-packages Mopidy-Mobile


sudo apt update
sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-tools

pactl list short sinks  # Find the index or name of your Bluetooth device
pactl set-default-sink [sink_name_or_index]



----


Install Bluetooth Tools and Bluez:
First, ensure you have the necessary Bluetooth packages installed.

bash
Copy code
sudo apt update
sudo apt install bluetooth bluez
Enable and Start Bluetooth Service:
Ensure that the Bluetooth service is enabled and running.

bash
Copy code
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
Set Up Bluetooth Device:
Use bluetoothctl to pair and connect to your Bluetooth device.

bash
Copy code
sudo bluetoothctl
In the bluetoothctl shell, execute the following commands:

text
Copy code
power on
agent on
default-agent
scan on
Wait for your device to appear in the list, then note its MAC address (e.g., XX:XX:XX:XX:XX:XX).

text
Copy code
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
After these steps, your device should be connected. Exit bluetoothctl by typing exit.

Auto-connect Script:
Create a script to automatically connect to the Bluetooth device on boot.

bash
Copy code
sudo vim /usr/local/bin/auto-connect-bluetooth.sh
Press i to enter insert mode and add the following script content:

bash
Copy code
#!/bin/bash
bluetoothctl << EOF
power on
connect XX:XX:XX:XX:XX:XX
EOF
Replace XX:XX:XX:XX:XX:XX with your Bluetooth device's MAC address. Press Esc, then type :wq and hit Enter to save and exit.

Make the script executable:

bash
Copy code
sudo chmod +x /usr/local/bin/auto-connect-bluetooth.sh
Systemd Service:
Create a systemd service to run the script at boot.

bash
Copy code
sudo vim /etc/systemd/system/auto-connect-bluetooth.service
Press i to enter insert mode and add the following content:

ini
Copy code
[Unit]
Description=Auto Connect Bluetooth Device
After=bluetooth.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-connect-bluetooth.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
Press Esc, then type :wq and hit Enter to save and exit.

Enable and start the service:

bash
Copy code
sudo systemctl daemon-reload
sudo systemctl enable auto-connect-bluetooth.service
sudo systemctl start auto-connect-bluetooth.service
This setup ensures that your Ubuntu server connects to the Bluetooth device automatically on boot and maintains the connection without requiring an active user session.



