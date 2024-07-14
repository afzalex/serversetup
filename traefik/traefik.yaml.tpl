entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
    http:
      tls:
        certificates:
          - certFile: "/home/afzalex/serversetup/traefik/ssl/fzbox.local.crt"
            keyFile: "/home/afzalex/serversetup/traefik/ssl/fzbox.local.key"

providers:
  file:
    directory: "${TRAEFIK_LOC}/dynamic"
    watch: true

log:
  level: DEBUG
  # filePath: "stdout"

accessLog:
  # filePath: "stdout"
  format: "common"