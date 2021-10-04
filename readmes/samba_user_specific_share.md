# Samba share user specific content

Create new user who can access samba share directory
```
sudo useradd -m afzal
```
Create samba password for newly created user
```
sudo smbpasswd -a afzal
```


Create the directory that will be shared
```
sudo -iu afzal mkdir shared
```
above command will create `shared` directory in home directory of `afzal` i.e. `/home/afzal/shared` will be created with user rights as `afzal:afzal` (User:Group)


Now edit smb.conf file
```
sudo vim /etc/samba/smb.conf
```
And add below content at the end of file
```
[afzal]
    comment = Afzal's content
    path = /home/afzal/shared
    read only = no
    writable = yes
    browsable = yes
    valid users = afzal
```
Specific group can also be provided by `valid groups` entry.



Now restart samba demon
```
sudo systemctl restart smbd
```

A drive could also be mounted to that shared, but user rights of that mounted should be given while mounting.  
See below commands :
```
sudo -iu afzal mkdir -p shared/myssd
sudo mount /dev/sda1 /home/afzal/shared/myssd -o defaults,uid=1001,gid=1001,umask=022
```
uid and gid could be fetched by below command.
```
id afzal
```

In the similar way that drive could be mounted on boot by adding below entry to fstab.
```

```



