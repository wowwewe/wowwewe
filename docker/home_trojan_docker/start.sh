#!/usr/bin/env bash

set -e

# --- 路径定义 ---
DATA_DIR="/data"
CONFIG_FILE="$DATA_DIR/config.json"
CERT_FILE="$DATA_DIR/server.crt"
KEY_FILE="$DATA_DIR/server.key"
PSK_FILE="$DATA_DIR/psk.txt"  # <--- 新增：专门用于存放密码的文件

echo "[INFO] $(date '+%F %T') Starting initialization..."

########################################
# 1. Generate config.json (only once)
########################################
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[INFO] $(date '+%F %T') config.json not found, generating..."

    # 检查必要环境变量
    if [ -z "$dns" ] || [ -z "$port" ]; then
        echo "[ERROR] 环境变量 dns 或 port 未设置，无法生成初始配置。"
        exit 1
    fi

    # 强制自动生成 39 位强随机密码
    echo "[INFO] 正在自动生成 38 位强随机密码..."
    FINAL_PSK=$(openssl rand -base64 128 | tr -dc 'A-Za-z0-9' | head -c 38)

    mkdir -p "$DATA_DIR"
    
    # --- 核心修改：将生成的密码存入独立文件 ---
    echo "$FINAL_PSK" > "$PSK_FILE"

    cat > "$CONFIG_FILE" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "servers": [ "$dns" ]
  },
  "inbounds": [
    {
      "listen": "::0",
      "port": $port,
      "protocol": "trojan",
      "settings": {
        "clients": [ { "password": "$FINAL_PSK" } ]
      },
      "streamSettings": {
        "network": "raw",
        "security": "tls",
        "tlsSettings": {
          "alpn": ["h2"],
          "minVersion": "1.3",
          "certificates": [
            {
              "certificateFile": "$CERT_FILE",
              "keyFile": "$KEY_FILE"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIP" 
      }
     },
    {
      "tag": "block",
      "protocol": "blackhole",
      "response": {
       "type": "none"
      }
     }
  ],
  "routing": {
    "domainStrategy": "IPOnDemand",
    "rules": [
      {
        "outboundTag": "direct",
        "port": "53"
      },
      {
        "ip": ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12"],
        "outboundTag": "direct"
      },
      {
        "network": "tcp,udp",
        "outboundTag": "block"
      }
    ]
  }
}
EOF
    echo "[INFO] 初始 config.json 已生成。"
else
    echo "[INFO] config.json 已存在，跳过生成过程。"
    
    # --- 核心修改：读取逻辑 ---
    if [ -f "$PSK_FILE" ]; then
        # 优先从专门的 psk.txt 读取，速度快且精准
        FINAL_PSK=$(cat "$PSK_FILE")
    else
        # 容错：如果 psk.txt 意外丢失但 config 还在，则从 JSON 提取一次并补写 psk.txt
        echo "[INFO] psk.txt 不存在，正在从 config.json 尝试提取..."
        FINAL_PSK=$(sed -n 's/.*"password": *"\([^"]*\)".*/\1/p' "$CONFIG_FILE" | head -n 1)
        echo "$FINAL_PSK" > "$PSK_FILE"
    fi
fi

########################################
# 2. Generate ECC SSL certificate (only once)
########################################
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
echo "[INFO] SSL certificate not found, generating ECC certificate..."
openssl genpkey -algorithm EC \
    -pkeyopt ec_paramgen_curve:P-384 \
    -out "$KEY_FILE"
openssl req -new -x509 -days 3650 \
    -key "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/" \
    -sha512 
chmod 600 "$KEY_FILE"
fi

# --- 关键信息确认输出 ---
echo " "
echo "==============================================================="
echo "[CONFIRM] Trojan 密码 (PSK): $FINAL_PSK"

# 提取并打印证书指纹 (SHA256)
TLS_SHA256=$(openssl x509 -noout -fingerprint -sha256 -in "$KEY_FILE" | sed 's/://g' | cut -d'=' -f2)
echo "[CONFIRM] TLS-CERT-SHA256: $TLS_SHA256"
echo "==============================================================="

echo "[INFO] Initialization complete. Starting Xray..."
exec tj run -config /data/config.json
