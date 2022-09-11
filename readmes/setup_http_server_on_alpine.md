# Setup

If using ipad or iphone install iSH from app store
https://apps.apple.com/us/app/ish-shell/id1436902243

Open shell and update apk
```sh
apk update
```

Setup ssh client
```sh
apk get openssh-client -y
ssh-keygen
```
Press enters for all prompts

Set ssh key in github
```sh
cat ~/.ssh/id_rsa.pub
```
Copy output of above command and add it as ssh key in github
https://github.com/settings/keys

Setup git and clone git repository
```sh
apk get git -y
git clone git@github.com:afzalex/about.git
```

Change directory to required place and serve data on http server
```sh
cd about
python -m http.server
```

### To setup file browser
```sh
apk add curl bash
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
filebrowser -r .
```

```sh
apk add openssh
ssh-keygen -A
adduser sshuser
addgroup sshuser root
exec /usr/sbin/sshd -D -e "$@"
```