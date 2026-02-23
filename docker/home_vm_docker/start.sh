#!/usr/bin/env bash

set -e

CONFIG_FILE="/data/config.json"

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
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "$psk"
          }
        ]
      },
      "streamSettings": {
        "network": "raw"
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

echo "[INFO] $(date '+%F %T') Initialization complete."

exec vm run -config /data/config.json
