entryPoints:
  web:
    address: ":80"

  websecure:
    address: ":443"
    http:
      tls: {}

providers:
  file:
    directory: "${TRAEFIK_LOC}/dynamic"
    watch: true


http:
  middlewares:
    redirect-to-https:
      redirectScheme:
        scheme: https
        permanent: true

log:
  level: DEBUG
  # filePath: "stdout"

accessLog:
  # filePath: "stdout"
  format: "common"