# ssl_certificates.yml
# This file is used to store the SSL certificates for the Traefik server.
# Simply add the certificates to the certs directory and update the paths below.

tls:
  certificates:
    - certFile: "${SSL_CERT_FILE}"
      keyFile: "${SSL_KEY_FILE}"

  stores:
    default:
      defaultCertificate:
        certFile: "${SSL_CERT_FILE}"
        keyFile: "${SSL_KEY_FILE}"
