#!/bin/sh
set -e

CONFIG_PATH="/etc/xray/config.json"
DATA_DIR="/etc/xray"
UUID_FILE="$DATA_DIR/uuid"
REALITY_PRIV_FILE="$DATA_DIR/reality_private.key"
REALITY_PUB_FILE="$DATA_DIR/reality_public.key"
SHORTID_FILE="$DATA_DIR/shortid"

# 必填变量检查
[ -z "$tlshost" ] && echo "ERROR: tlshost is required" && exit 1
[ -z "$privatekey" ] && echo "ERROR: privatekey is required" && exit 1
[ -z "$wgip" ] && echo "ERROR: wgip is required" && exit 1
[ -z "$publickey" ] && echo "ERROR: publickey is required" && exit 1
[ -z "$wgserver" ] && echo "ERROR: wgserver is required" && exit 1

mkdir -p "$DATA_DIR"

# shortId 生成（仅第一次）
if [ ! -f "$SHORTID_FILE" ]; then
    head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$SHORTID_FILE"
fi

REALITY_SHORTID=$(cat "$SHORTID_FILE")

# 安全校验（必须是1-8位十六进制）
if ! echo "$REALITY_SHORTID" | grep -Eq '^[0-9a-fA-F]{1,8}$'; then
    echo "ERROR: Invalid generated shortId"
    exit 1
fi
# UUID 生成（第一次启动）
if [ ! -f "$UUID_FILE" ]; then
    cat /proc/sys/kernel/random/uuid > "$UUID_FILE"
fi
UUID=$(cat "$UUID_FILE")

# Reality 密钥生成（仅第一次）
if [ ! -f "$REALITY_PRIV_FILE" ]; then

    KEY_OUTPUT="$(xray x25519 2>/dev/null)"

    REALITY_PRIVATE="$(echo "$KEY_OUTPUT" | grep -i '^PrivateKey:' | cut -d ':' -f2 | tr -d '[:space:]')"
    REALITY_PUBLIC="$(echo "$KEY_OUTPUT" | grep -i '^Password:'   | cut -d ':' -f2 | tr -d '[:space:]')"

    if [ -z "$REALITY_PRIVATE" ] || [ -z "$REALITY_PUBLIC" ]; then
        echo "ERROR: Failed to generate Reality key pair"
        echo "Raw output:"
        echo "$KEY_OUTPUT"
        exit 1
    fi

    echo "$REALITY_PRIVATE" > "$REALITY_PRIV_FILE"
    echo "$REALITY_PUBLIC"  > "$REALITY_PUB_FILE"

fi

# 每次启动都从文件读取
REALITY_PRIVATE="$(cat "$REALITY_PRIV_FILE")"
REALITY_PUBLIC="$(cat "$REALITY_PUB_FILE")"

echo "===== XRAY RUNTIME INFO ====="
echo "UUID: $UUID"
echo "Reality PublicKey: $REALITY_PUBLIC"
echo "Reality ShortID: $REALITY_SHORTID"
echo "TLS Host: $tlshost"
echo "=============================="

# 生成 config.json（可重建）
cat > "$CONFIG_PATH" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$tlshost:443",
          "xver": 0,
          "serverNames": [
            "$tlshost"
          ],
          "privateKey": "$REALITY_PRIVATE",
          "shortIds": [
           "$REALITY_SHORTID"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "wireguard",
      "settings": {
        "secretKey": "$privatekey",
        "address": [
          "$wgip/32"
        ],
        "peers": [
          {
            "publicKey": "$publickey",
            "endpoint": "$wgserver"
          }
        ],
        "mtu": 1420
      },
      "tag": "wg-out"
    },
    {
      "protocol": "freedom",
      "tag": "direct"
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "outboundTag": "wg-out",
        "network": "tcp,udp"
      }
    ]
  }
}
EOF

# 启动 Xray
exec xray run -config "$CONFIG_PATH"
