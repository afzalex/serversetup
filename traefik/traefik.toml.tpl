[entryPoints]
   [entryPoints.web]
      address = ":80"
   
   [entryPoints.websecure]
      address = ":443"

[providers.file]
   directory = "${TRAEFIK_LOC}/dynamic"
   watch = true

[tls.stores]
[tls.stores.default]
[tls.stores.default.defaultCertificate]
certFile = "/home/afzalex/serversetup/traefik/ssl/fzbox.local.crt"
keyFile = "/home/afzalex/serversetup/traefik/ssl/fzbox.local.key"

# Global configuration
[log]
level = "DEBUG"
#filePath = "stdout"

# Access log configuration
[accessLog]
#filePath = "stdout"
format = "common"