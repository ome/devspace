#!/usr/bin/env bash

# SSL certificate dir
SSL_DIR="/etc/nginx/ssl"
mkdir -p "$SSL_DIR"


# Certificate subject
NGINX_SSL_CERTIFICATE_SUBJECT="/C=UK/ST=Scotland/L=Dundee/O=OME/CN=SPACENAME-ci.openmicroscopy.org"

# Certificate validity (days)
NGINX_SSL_CERTIFICATE_DAYS=365

# Server path to SSL certificate
NGINX_SSL_CERTIFICATE="$SSL_DIR/server.crt"

# Server path to SSL certificate key
NGINX_SSL_CERTIFICATE_KEY="$SSL_DIR/server.key"

openssl req -new -nodes -x509 -subj "$NGINX_SSL_CERTIFICATE_SUBJECT" -days $NGINX_SSL_CERTIFICATE_DAYS -keyout $NGINX_SSL_CERTIFICATE_KEY -out $NGINX_SSL_CERTIFICATE -extensions v3_ca
