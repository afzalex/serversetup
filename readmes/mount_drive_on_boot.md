Commands helpful while playing with filesystems


```bash
# To know UUID and filetype of drive
sudo blkid 

# To List all block devices
sudo lsblk

# To know user id and group id to use in fstab
id -u
id -g
```



Output of above command should be like :

```
/dev/mmcblk0p1: LABEL_FATBOOT="system-boot" LABEL="system-boot" UUID="4D3B-86C0" TYPE="vfat" PARTUUID="4ec8ea53-01"
/dev/mmcblk0p2: LABEL="writable" UUID="79af43d1-801b-4c28-81d5-724c930bcc83" TYPE="ext4" PARTUUID="4ec8ea53-02"
/dev/sda1: UUID="B234-8EED" TYPE="exfat" PARTUUID="d3b54a10-01"
/dev/loop0: TYPE="squashfs"
/dev/loop1: TYPE="squashfs"
```


To know user id and group id to use in fstab

```
id -u
id -g
```


For normal distyps below entry in fstab should work

```
UUID=B234-8EED          /home/ubuntu/media/sda1 exfat defaults   0      2
```


If above does not work and writes to logged in user are not there, Using below entry will also specify user rights in fstab entry
```
UUID=B234-8EED          /home/ubuntu/media/sda1 exfat  rw,noauto,users,uid=1000,gid=1000,permissions     0      2
```

If that also does not work, umask could be specified.
```
UUID=B234-8EED		/home/ubuntu/media/sda1	exfat  defaults,uid=1000,gid=1000,umask=022	 0 	2
```