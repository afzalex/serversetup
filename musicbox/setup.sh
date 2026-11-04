
#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------
# Project configuration
# --------------------------------------------------

APP_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$APP_DIR"

# Run setup as a normal user, not root
if [[ "$EUID" -eq 0 ]]; then
    echo "Error: Run setup.sh as a normal user, not with sudo."
    exit 1
fi

SERVICE_USER="$(id -un)"
SERVICE_HOME="$(getent passwd "$SERVICE_USER" | cut -d: -f6)"

if [[ -z "$SERVICE_HOME" ]]; then
    echo "Error: Could not determine the user's home directory."
    exit 1
fi

export APP_DIR SERVICE_USER SERVICE_HOME

# --------------------------------------------------
# Install Ubuntu dependencies
# --------------------------------------------------

sudo apt-get update

grep -vE '^[[:space:]]*(#|$)' apt-packages.txt |
    xargs -r sudo apt-get install -y

# --------------------------------------------------
# Set up Python virtual environment
# --------------------------------------------------

if [[ ! -d .venv ]]; then
    python3 -m venv --system-site-packages .venv
fi

# Install Python dependencies
.venv/bin/python -m pip install -r requirements.txt

# Validate Python dependencies
.venv/bin/python -m pip check

echo "MusicBox dependencies installed successfully."

# --------------------------------------------------
# Validate required files
# --------------------------------------------------

SYSTEMD_TEMPLATE="$APP_DIR/templates/systemd/mopidy.service.tpl"
NGINX_TEMPLATE="$APP_DIR/templates/nginx/mopidy.conf.tpl"

for template in "$SYSTEMD_TEMPLATE" "$NGINX_TEMPLATE"; do
    if [[ ! -f "$template" ]]; then
        echo "Error: Missing template: $template"
        exit 1
    fi
done

if [[ ! -x "$APP_DIR/run.sh" ]]; then
    echo "Error: run.sh is missing or not executable."
    exit 1
fi

if ! command -v envsubst >/dev/null 2>&1; then
    echo "Error: envsubst not found. Install gettext-base."
    exit 1
fi

# --------------------------------------------------
# Configure Mopidy systemd service
# --------------------------------------------------

SERVICE_FILE="/etc/systemd/system/mopidy.service"

TEMP_SERVICE="$(mktemp)"
trap 'rm -f "$TEMP_SERVICE"' EXIT

# Render systemd template
envsubst '${APP_DIR} ${SERVICE_USER} ${SERVICE_HOME}' \
    < "$SYSTEMD_TEMPLATE" > "$TEMP_SERVICE"

# Install systemd service
sudo install -m 0644 "$TEMP_SERVICE" "$SERVICE_FILE"

sudo systemctl daemon-reload
sudo systemctl enable mopidy.service

echo "Mopidy systemd service installed successfully."

# --------------------------------------------------
# Configure NGINX reverse proxy
# --------------------------------------------------

NGINX_AVAILABLE="/etc/nginx/sites-available/musicbox.conf"
NGINX_ENABLED="/etc/nginx/sites-enabled/musicbox.conf"
NGINX_DEFAULT="/etc/nginx/sites-enabled/default"

# The NGINX template is hostname-independent,
# so envsubst is not required.

sudo install -m 0644 "$NGINX_TEMPLATE" "$NGINX_AVAILABLE"

# Enable MusicBox site
sudo ln -sfn "$NGINX_AVAILABLE" "$NGINX_ENABLED"

# Disable the packaged Ubuntu default site, if present.
# MusicBox uses "default_server" to accept any hostname.
# Do not modify unrelated NGINX sites.
if [[ -L "$NGINX_DEFAULT" ]] &&
   [[ "$(readlink -f "$NGINX_DEFAULT")" == "/etc/nginx/sites-available/default" ]]; then
    sudo rm "$NGINX_DEFAULT"
    echo "Disabled the default Ubuntu NGINX site."
fi

# --------------------------------------------------
# Validate TLS certificates
# --------------------------------------------------

TLS_DIR="/etc/nginx/tls/musicbox"

if ! sudo test -s "$TLS_DIR/fzbox.crt" ||
   ! sudo test -s "$TLS_DIR/fzbox.key"; then
    echo "Error: Missing TLS certificate or private key in $TLS_DIR"
    exit 1
fi

# Validate NGINX configuration
sudo nginx -t

# Enable and start NGINX
sudo systemctl enable --now nginx.service
sudo systemctl reload nginx.service

echo "NGINX reverse proxy configured successfully."

# --------------------------------------------------
# Setup completed
# --------------------------------------------------

echo
echo "MusicBox setup completed successfully."
echo
echo "Service user: $SERVICE_USER"
echo "Application directory: $APP_DIR"
echo
echo "Local URLs:"
echo "  http://fzbox.local/iris/"
echo "  http://fzbox.local/youtube/"
echo
echo "Other hostnames resolving to this server:"
echo "  http://fzbox.afzalex.com/iris/"
echo "  http://fzbox.afzalex.com/youtube/"
echo
echo "Mopidy service:"
echo "  sudo systemctl start mopidy"
echo "  sudo systemctl status mopidy"
echo
echo "NGINX service:"
echo "  sudo systemctl status nginx"

