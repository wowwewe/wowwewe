#!/usr/bin/env bash

set -e

CONFIG_FILE="/data/config.json"
# 使用一个隐藏文件存放生成的 UUID，确保容器重启时可以读取打印
UUID_FILE="/data/.vmess_uuid"

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

    # 自动生成一个标准的 UUIDv4 作为 VMess 的 id
    # 优先尝试使用 xray 内置命令生成，如果找不到则使用系统内核的 random uuid
    if command -v xray >/dev/null 2>&1; then
        VMESS_UUID=$(xray uuid)
    else
        VMESS_UUID=$(cat /proc/sys/kernel/random/uuid)
    fi

    # 存储生成的 UUID 以便容器重启时可以直接在 log 中打印
    echo "VMESS_UUID=\"$VMESS_UUID\"" > "$UUID_FILE"

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
            "id": "$VMESS_UUID"
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
    # 容器如果重启，直接从备份的文件中读取 UUID 变量用来展示
    if [ -f "$UUID_FILE" ]; then
        source "$UUID_FILE"
    else
        VMESS_UUID="[Unknown - Check config.json]"
    fi
fi

########################################
# 2. Print Configuration Details
########################################
# 打印在控制台，可通过 docker logs <容器名> 查看
echo "=================================================="
echo " VMess Server Configuration"
echo "=================================================="
echo " Protocol   : VMess"
echo " Port       : $port"
echo " UUID (id)  : $VMESS_UUID"
echo " Network    : tcp"
echo " Security   : aes-128-gcm (客户端请配置此加密方式)"
echo "--------------------------------------------------"
echo " [Client Setup Note]"
echo " 请在您的客户端中选择 vmess 协议，填入上述 Port 和 UUID，"
echo " 并将加密方式 (Security) 设置为 aes-128-gcm。"
echo "=================================================="

echo "[INFO] $(date '+%F %T') Initialization complete."

# 启动 xray 服务
exec vm run -config "$CONFIG_FILE"
