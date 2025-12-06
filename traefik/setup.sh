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
export SSL_SETUP_KEY_FILE=$(compgen -G "${TRAEFIK_CERTS_DIR}/*.key" | head -n 1)
export SSL_SETUP_CERT_FILE=$(compgen -G "${TRAEFIK_CERTS_DIR}/*.crt" | head -n 1)

if [ "${SSL_SETUP_KEY_FILE}" ] && [ "${SSL_SETUP_CERT_FILE}" ]; then
    read -p "Do you want to install Setup SSL key and cert? (y/n) :  " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        DO_INSTALL_SSL=true
    fi
fi

if [ -z "${SSL_SETUP_KEY_FILE}" ]; then
    export SSL_KEY_FILE="/etc/traefik/certs/${HOSTNAME}.key"
    echo "No SSL key file found, using ${HOSTNAME}.key, defaulting to ${SSL_KEY_FILE}"
    echo "Please put the SSL key file in the ${TRAEFIK_CERTS_DIR} directory"
else 
    export SSL_KEY_FILE="/etc/traefik/certs/$(basename "${SSL_SETUP_KEY_FILE}")"

    if [ "${DO_INSTALL_SSL}" = true ]; then
        if [ -f "${SSL_KEY_FILE}" ]; then
            read -p "SSL key file with name ${SSL_KEY_FILE} already exists, do you want to overwrite it? (y/n) :  " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo cp ${SSL_SETUP_KEY_FILE} ${SSL_KEY_FILE}
            else
                echo "Skipping SSL key file installation"
            fi
        else
            sudo cp ${SSL_SETUP_KEY_FILE} ${SSL_KEY_FILE}
        fi
    else
        echo "Skipping SSL key file installation because either key and crt file does not exist or DO_INSTALL_SSL is false"
    fi
fi

if [ -z "${SSL_SETUP_CERT_FILE}" ]; then
    export SSL_CERT_FILE="/etc/traefik/certs/${HOSTNAME}.crt"
    echo "No SSL crt file found, using ${HOSTNAME}.crt, defaulting to ${SSL_CERT_FILE}"
    echo "Please put the SSL crt file in the ${TRAEFIK_CERTS_DIR} directory"
else 
    export SSL_CERT_FILE="/etc/traefik/certs/$(basename "${SSL_SETUP_CERT_FILE}")"

    if [ "${DO_INSTALL_SSL}" = true ]; then
        if [ -f "${SSL_CERT_FILE}" ]; then
            read -p "SSL key file with name ${SSL_CERT_FILE} already exists, do you want to overwrite it? (y/n) :  " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo cp ${SSL_SETUP_CERT_FILE} ${SSL_CERT_FILE}
            else
                echo "Skipping SSL crt file installation"
            fi
        else
            sudo cp ${SSL_SETUP_CERT_FILE} ${SSL_CERT_FILE}
        fi
    else
        echo "Skipping SSL crt file installation because either key and crt file does not exist or DO_INSTALL_SSL is false"
    fi
fi
if test ! -f ${TRAEFIK_DYNAMIC_CONFIGS_DIR}/ssl_certificates.yml; then
    envsubst '${SSL_KEY_FILE} ${SSL_CERT_FILE}' < templates/ssl_certificates.yml.tpl > ${TRAEFIK_DYNAMIC_CONFIGS_DIR}/ssl_certificates.yml
fi

echo "Traefik setup complete"