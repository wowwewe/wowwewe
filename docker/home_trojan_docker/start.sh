#!/usr/bin/env bash

set -e

CONFIG_FILE="/data/config.json"
CERT_FILE="/data/server.crt"
KEY_FILE="/data/server.key"

echo "[INFO] $(date '+%F %T') Starting initialization..."

########################################
# 1. Generate config.json (only once)
########################################
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[INFO] $(date '+%F %T') config.json not found, generating..."

    if [ -z "$dns" ] || [ -z "$port" ] || [ -z "$psk" ]; then
        echo "[ERROR] $(date '+%F %T') Environment variables dns, port, psk must be set."
        exit 1
    fi

    mkdir -p /data

    cat > "$CONFIG_FILE" <<EOF
{
  "dns": {
    "servers": [
      "$dns"
    ]
  },
  "inbounds": [
    {
      "listen": "::0",
      "port": $port,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$psk"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "alpn": [],
          "minVersion": "1.3",
          "certificates": [
            {
              "certificateFile": "/data/server.crt",
              "keyFile": "/data/server.key"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    }
  ]
}
EOF

    echo "[INFO] $(date '+%F %T') config.json generated."
else
    echo "[INFO] $(date '+%F %T') config.json already exists, skipping."
fi

########################################
# 2. Generate ECC SSL certificate (only once)
########################################
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "[INFO] $(date '+%F %T') SSL certificate not found, generating ECC certificate..."

    mkdir -p /etc/xray

    # 使用 secp384r1（高安全级别）
    openssl ecparam -genkey -name secp384r1 -out "$KEY_FILE"

    # CN 改为 PrivateService
    openssl req -new -x509 -days 3650 \
        -key "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/CN=PrivateService" \
        -sha384

    chmod 600 "$KEY_FILE"
    chmod 644 "$CERT_FILE"

    echo "[INFO] $(date '+%F %T') ECC SSL certificate generated."
fi

# 每次启动都输出 TLS-CERT-SHA256 到控制台
TLS_SHA256=$(openssl x509 -noout -fingerprint -sha256 -in "$CERT_FILE" | sed 's/://g' | cut -d'=' -f2)
echo "[INFO] $(date '+%F %T') TLS-CERT-SHA256: $TLS_SHA256"

echo "[INFO] $(date '+%F %T') Initialization complete."
exec tj run -config /data/config.json
