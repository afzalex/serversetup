
# MusicBox - HTTP and HTTPS reverse proxy

map $http_upgrade $mopidy_connection_upgrade {
    default upgrade;
    ''      close;
}

# --------------------------------------------------
# HTTP - Fallback for any hostname
# --------------------------------------------------

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;
    absolute_redirect off;

    location = / {
        return 302 /iris/;
    }

    location = /iris {
        return 308 /iris/;
    }

    location = /youtube {
        return 308 /youtube/;
    }

    location / {
        proxy_pass http://127.0.0.1:6680;
        proxy_http_version 1.1;

        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $mopidy_connection_upgrade;

        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}

# --------------------------------------------------
# HTTP - Redirect certificate-covered hostnames
# --------------------------------------------------

server {
    listen 80;
    listen [::]:80;

    server_name
        fzbox
        fzbox.local
        fzbox.com
        *.fzbox.com
        fzbox.afzalex.com
        *.fzbox.afzalex.com;

    return 308 https://$host$request_uri;
}

# --------------------------------------------------
# HTTPS - Any hostname, one certificate
# --------------------------------------------------

server {
    listen 443 ssl default_server;
    listen [::]:443 ssl default_server;

    server_name _;
    absolute_redirect off;

    ssl_certificate /etc/nginx/tls/musicbox/fzbox.crt;
    ssl_certificate_key /etc/nginx/tls/musicbox/fzbox.key;

    ssl_protocols TLSv1.2 TLSv1.3;

    location = / {
        return 302 /iris/;
    }

    location = /iris {
        return 308 /iris/;
    }

    location = /youtube {
        return 308 /youtube/;
    }

    location / {
        proxy_pass http://127.0.0.1:6680;
        proxy_http_version 1.1;

        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $mopidy_connection_upgrade;

        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}

