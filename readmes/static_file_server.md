Will use npm for static file server

```bash
curl -sL deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install nodejs
sudo apt-get install npm
```

Now serve the content through below command
```
npx serve /home/ubuntu/media/
```
Here conent of `/home/ubuntu/media/` will be served on `5000` port


To access conent at port 80 use below command
```
sudo iptables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-port 5000
```
This command will redirect all traffic from 5000 to port 80


To persist above iptables rules use below commands
```
sudo apt-get install iptables-persistent
sudo mkdir -p /etc/iptables
sudo /sbin/iptables-save | sudo tee /etc/iptables/rules.v4
```
Reference: https://www.cyberciti.biz/faq/how-to-save-iptables-firewall-rules-permanently-on-linux/


