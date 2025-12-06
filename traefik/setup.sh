#!/bin/bash
export TRAEFIK_BASE_DIR="$PWD/.build"
export TRAEFIK_CERTS_DIR="$PWD/.build/certs"

set -e

mkdir -p ${TRAEFIK_BASE_DIR}

# Download Traefik if not installed
if test ! -f ${TRAEFIK_BASE_DIR}/traefik; then
    echo "Traefik not installed"
    
    export TRAEFIK_DOWNLOAD_URL='https://github.com/traefik/traefik/releases/download/v3.6.4/traefik_v3.6.4_linux_arm64.tar.gz' 
    filename=$(basename "$TRAEFIK_DOWNLOAD_URL")
    if test ! -f "$filename"; then
        wget "$TRAEFIK_DOWNLOAD_URL"
    fi

    tar -xzvf "$filename" -C ${TRAEFIK_BASE_DIR} "traefik"
else
    echo "Traefik already installed"
fi

# Generate Traefik configuration if not exists
if test ! -f ${TRAEEFIK_BASE_DIR}/traefik.yaml; then
    envsubst '${TRAEFIK_BASE_DIR} ${TRAEFIK_CERTS_DIR}' < ./templates/traefik.yaml.tpl > ${TRAEFIK_BASE_DIR}/traefik.yaml
fi

# Copy example yml files to dynamic directory if not exists
export TRAEFIK_DYNAMIC_CONFIGS_DIR="${TRAEFIK_BASE_DIR}/dynamic"
if test ! -d ${TRAEFIK_DYNAMIC_CONFIGS_DIR}; then
    # Create dynamic directory if it doesn't exist
    mkdir -p "${TRAEFIK_DYNAMIC_CONFIGS_DIR}"
    # Add common.yml and other example config files if config directory is empty
    if ! ls "${TRAEFIK_DYNAMIC_CONFIGS_DIR}"/*.yml >/dev/null 2>&1; then
        cp config/commons.yml "${TRAEFIK_DYNAMIC_CONFIGS_DIR}/commons.yml"
        for file in config/*.example.yml; do
            cp "${file}" "${TRAEFIK_DYNAMIC_CONFIGS_DIR}/$(basename "${file/.example/}")"
        done
    fi
fi

# Generate Traefik service file if not exists
if test ! -f .build/traefik.service; then
    envsubst '${TRAEFIK_LOC}' < ./templates/traefik.service.tpl > .build/traefik.service

    # Ask user to copy traefik.service to /etc/systemd/system
    read -p "Do you want to copy traefik.service to /etc/systemd/system? (y/n) :  " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo cp ${TRAEFIK_BASE_DIR}/traefik.service /etc/systemd/system/traefik.service
        sudo systemctl daemon-reload
        sudo systemctl enable traefik
        sudo systemctl start traefik
    fi
fi

# Install setup SSL key and cert if exists in the /etc/traefik/certs directory
mkdir -p ${TRAEFIK_CERTS_DIR}
export SSL_KEY_FILE=$(ls "${TRAEFIK_CERTS_DIR}"/*.key 2>/dev/null | head -n 1)
export SSL_CERT_FILE=$(ls "${TRAEFIK_CERTS_DIR}"/*.crt 2>/dev/null | head -n 1)

if [ -z "${SSL_KEY_FILE}" ]; then
    export SSL_KEY_FILE="/etc/traefik/certs/${HOSTNAME}.key"
    echo "No SSL key file found, using ${HOSTNAME}.key, defaulting to ${SSL_KEY_FILE}"
    echo "Please put the SSL key file in the ${TRAEFIK_CERTS_DIR} directory"
else 
    echo "SSL key file found, using ${SSL_KEY_FILE}"
fi
if [ -z "${SSL_CERT_FILE}" ]; then
    export SSL_CERT_FILE="/etc/traefik/certs/${HOSTNAME}.crt"
    echo "No SSL crt file found, using ${HOSTNAME}.crt, defaulting to ${SSL_CERT_FILE}"
    echo "Please put the SSL crt file in the ${TRAEFIK_CERTS_DIR} directory"
else 
    echo "SSL crt file found, using ${SSL_CERT_FILE}"
fi
if test ! -f ${TRAEFIK_DYNAMIC_CONFIGS_DIR}/ssl_certificates.yml; then
    envsubst '${SSL_KEY_FILE} ${SSL_CERT_FILE}' < templates/ssl_certificates.yml.tpl > ${TRAEFIK_DYNAMIC_CONFIGS_DIR}/ssl_certificates.yml
fi

echo "Traefik setup complete"