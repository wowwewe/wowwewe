#!/usr/bin/env bash

set -e

CONFIG_FILE="/data/config.json"
# 使用一个隐藏文件专门存放生成的密码，方便容器重启时读取打印，避免使用正则去解析 JSON
KEY_INFO_FILE="/data/.ss_keys"
METHOD="2022-blake3-aes-256-gcm"

echo "[INFO] $(date '+%F %T') Starting initialization..."

########################################
# 1. Generate config.json (only once)
########################################
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[INFO] $(date '+%F %T') config.json not found, generating..."

    # 仅保留 dns 和 port 作为强制要求传入的环境变量
    if [ -z "$dns" ] || [ -z "$port" ]; then
        echo "[ERROR] $(date '+%F %T') Environment variables 'dns' and 'port' must be set."
        exit 1
    fi

    mkdir -p /data

    # 针对 2022-blake3-aes-256-gcm，Xray 官方要求使用 32 字节且使用 Base64 编码的密钥 [cite: 307, 308]
    # Shadowsocks 2022 规范中，服务端需要配置 "Server Password" (用于防主动探测机制) 和 "User Password" (针对具体用户)
    SERVER_KEY=$(openssl rand -base64 32)
    # 存储生成的密钥以便容器重启时可以直接在 log 中打印
    echo "SERVER_KEY=\"$SERVER_KEY\"" > "$KEY_INFO_FILE"

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
      "protocol": "shadowsocks",
      "settings": {
        "network": "tcp,udp",
        "method": "$METHOD",
        "password": "$SERVER_KEY"
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
    # 容器如果重启，直接从备份的文件中读取密码变量用来展示
    if [ -f "$KEY_INFO_FILE" ]; then
        source "$KEY_INFO_FILE"
    else
        SERVER_KEY="[Unknown - Check config.json]"
    fi
fi

########################################
# 2. Print Configuration Details
########################################
# 打印在控制台，可通过 docker logs <容器名> 查看
echo "=================================================="
echo " Shadowsocks 2022 Server Configuration"
echo "=================================================="
echo " Method          : $METHOD"
echo " Server Password : $SERVER_KEY"
echo "--------------------------------------------------"
echo "=================================================="

echo "[INFO] $(date '+%F %T') Initialization complete."

# 启动 xray 服务
exec ss run -config "$CONFIG_FILE"
