#!/usr/bin/env bash

set -e

CONFIG_FILE="/data/config.json"
KEY_INFO_FILE="/data/.ss_keys"
# 强制指定为 2022-blake3-aes-256-gcm 算法
METHOD="2022-blake3-aes-256-gcm"

echo "[INFO] $(date '+%F %T') Starting initialization..."

########################################
# 1. Generate config.json (only once)
########################################
if [ ! -f "$CONFIG_FILE" ]; then
    echo "[INFO] $(date '+%F %T') config.json not found, 生成config..."
    # ... 这里是生成文件的代码 (略) ...
else
    # ↓↓↓ 将这行代码添加在 else 下方 ↓↓↓
    echo -e "\033[1;32m[NOTICE] $(date '+%F %T') 发现已存在的 config.json，将直接使用该文件启动，不会覆盖你的手动修改！\033[0m"
    
    echo "[INFO] $(date '+%F %T') config.json already exists, skipping."
    # 容器如果重启，直接从备份的文件中读取密码变量用来展示
    if [ -f "$KEY_INFO_FILE" ]; then
        source "$KEY_INFO_FILE"
    else
        SERVER_KEY="[Unknown - Check config.json]"
    fi
fi


    mkdir -p /data

    # [span_1](start_span)针对 2022-blake3-aes-256-gcm，严格生成 32 字节的 Base64 密钥[span_1](end_span)
    SERVER_KEY=$(openssl rand -base64 32)
    echo "SERVER_KEY=\"$SERVER_KEY\"" > "$KEY_INFO_FILE"

    cat > "$CONFIG_FILE" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "servers": [
      "$dns"
    ]
  },
  "inbounds": [
    {
      "listen": "::",
      "port": $port,
      "protocol": "shadowsocks",
      "settings": {
        "method": "$METHOD",
        "password": "$SERVER_KEY",
        "network": "tcp,udp"
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

    echo "[INFO] $(date '+%F %T') config.json generated."
else
    echo "[INFO] $(date '+%F %T') config.json already exists, skipping."
    if [ -f "$KEY_INFO_FILE" ]; then
        source "$KEY_INFO_FILE"
    else
        SERVER_KEY="[Unknown - Check config.json]"
    fi
fi

########################################
# 2. Print Configuration Details
########################################
echo "=================================================="
echo " Shadowsocks 2022 Server Configuration"
echo "=================================================="
echo " Method          : $METHOD"
echo " Server Password : $SERVER_KEY"
echo " Port            : $port"
echo "--------------------------------------------------"
echo " UoT / sp.v2 is natively supported by the server."
echo " Just configure uot: true and UoTVersion: 2 on the client."
echo "=================================================="

echo "[INFO] $(date '+%F %T') Initialization complete."

# 启动 xray 服务（如果是基于 xray 官方镜像，命令一般是 xray run；如果是旧镜像可能使用 ss run，请根据您的 Dockerfile 调整）
exec s20 run -config /data/config.json
