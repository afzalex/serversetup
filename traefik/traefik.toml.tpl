[entryPoints]
   [entryPoints.web]
      address = ":80"
   
   [entryPoints.websecure]
      address = ":443"
   [entryPoints.websecure.http.tls]

[providers.file]
   directory = "${TRAEFIK_LOC}/dynamic"
   watch = true

# Global configuration
[log]
level = "DEBUG"
#filePath = "stdout"

# Access log configuration
[accessLog]
#filePath = "stdout"
format = "common"