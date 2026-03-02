#!/bin/sh
set -e

# --- 路径配置 (已修改为 /data) ---
CONFIG_PATH="/data/config.json"
DATA_DIR="/data"
ASSET_DIR="/usr/bin"
UUID_FILE="$DATA_DIR/uuid"
REALITY_PRIV_FILE="$DATA_DIR/reality_private.key"
REALITY_PUB_FILE="$DATA_DIR/reality_public.key"
SHORTID_FILE="$DATA_DIR/shortid"

# --- 环境变量/必填检查 ---
[ -z "$tlshost" ] && echo "ERROR: tlshost is required" && exit 1
[ -z "$privatekey" ] && echo "ERROR: privatekey is required" && exit 1
[ -z "$wgip" ] && echo "ERROR: wgip is required" && exit 1
[ -z "$publickey" ] && echo "ERROR: publickey is required" && exit 1
[ -z "$wgserver" ] && echo "ERROR: wgserver is required" && exit 1

mkdir -p "$DATA_DIR"
chmod 700 "$DATA_DIR"

# --- 1. 下载 Geo 资源文件 (强制重新下载) ---
echo "[INFO] 正在强制更新 Geo 资源文件..."

# -f: 失败时不输出错误页面
# -s: 静默模式，不显示进度条
# -S: 仅在出错时显示错误信息
# -L: 跟随重定向
# -o: 明确指定输出到文件，防止溢出到日志

if curl -fsSL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o "$ASSET_DIR/geoip.dat"; then
    echo "[SUCCESS] geoip.dat 强制下载完成"
else
    echo "[ERROR] geoip.dat 下载失败" && exit 1
fi

if curl -fsSL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o "$ASSET_DIR/geosite.dat"; then
    echo "[SUCCESS] geosite.dat 强制下载完成"
else
    echo "[ERROR] geosite.dat 下载失败" && exit 1
fi
ls -lh "$ASSET_DIR"/geo*.dat | awk '{print "[VERIFIED] " $9 " 最后更新时间: " $6 " " $7 " " $8}'


# --- 2. 身份凭证生成 ---

# ShortID 生成及校验
if [ ! -f "$SHORTID_FILE" ]; then
    head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$SHORTID_FILE"
    chmod 600 "$SHORTID_FILE"
fi
REALITY_SHORTID=$(cat "$SHORTID_FILE")

if ! echo "$REALITY_SHORTID" | grep -Eq '^[0-9a-fA-F]{1,8}$'; then
    echo "ERROR: Invalid generated shortId"
    exit 1
fi

# UUID 生成
if [ ! -f "$UUID_FILE" ]; then
    cat /proc/sys/kernel/random/uuid > "$UUID_FILE"
    chmod 600 "$UUID_FILE"
fi
UUID=$(cat "$UUID_FILE")

# Reality 密钥生成 (采用您提供的兼容逻辑)
if [ ! -f "$REALITY_PRIV_FILE" ]; then
    echo "[INFO] 正在生成 Reality 密钥对..."
    KEY_OUTPUT="$(xray x25519 2>/dev/null)"

    REALITY_PRIVATE="$(echo "$KEY_OUTPUT" | grep -Ei 'Private[[:space:]]?Key' | cut -d ':' -f2 | tr -d '[:space:]')"
    REALITY_PUBLIC="$(echo "$KEY_OUTPUT" | grep -Ei 'Public[[:space:]]?Key|Password' | cut -d ':' -f2 | tr -d '[:space:]')"

    if [ -z "$REALITY_PRIVATE" ] || [ -z "$REALITY_PUBLIC" ]; then
        echo "ERROR: Failed to generate Reality key pair"
        exit 1
    fi

    echo "$REALITY_PRIVATE" > "$REALITY_PRIV_FILE"
    echo "$REALITY_PUBLIC"  > "$REALITY_PUB_FILE"
    chmod 600 "$REALITY_PRIV_FILE" "$REALITY_PUB_FILE"
fi

REALITY_PRIVATE="$(cat "$REALITY_PRIV_FILE")"
REALITY_PUBLIC="$(cat "$REALITY_PUB_FILE")"

echo "===== XRAY RUNTIME INFO ====="
echo "UUID: $UUID"
echo "Reality PublicKey: $REALITY_PUBLIC"
echo "Reality ShortID: $REALITY_SHORTID"
echo "serverName: $tlshost"
echo "=============================="
echo " "
echo "===== 每日自动更新定时任务 (请在宿主机执行 crontab -e 添加) ====="
echo "0 5 * * * docker restart 你的容器NAME"
echo "====执行以下让cron生效===="
echo "service cron reload && service cron restart"
echo "==============================================================="
echo " "
# --- 3. 生成 config.json (带防覆盖判断) ---
if [ ! -f "$CONFIG_PATH" ]; then
    echo "[INFO] 配置文件不存在，正在生成默认配置..."
    cat > "$CONFIG_PATH" <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "dns": {
    "servers": [
      "8.8.8.8",
      "1.1.1.1",
      "https://dns.google/dns-query",
      "localhost"
    ]
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "vless",
      "tag": "vless_in",
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
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "target": "$tlshost:443",
          "xver": 0,
          "serverNames": ["$tlshost"],
          "privateKey": "$REALITY_PRIVATE",
          "shortIds": ["$REALITY_SHORTID"]
        },
        "sockopt": {
          "tcpKeepAliveInterval": 15,
          "tcpKeepAliveIdle": 30,
          "tcpFastOpen": false
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "wireguard",
      "settings": {
        "secretKey": "$privatekey",
        "address": ["$wgip/32"],
        "peers": [
          {
            "publicKey": "$publickey",
            "endpoint": "$wgserver",
            "keepAlive": 15
          }
        ],
        "mtu": 1420
      },
      "tag": "wg-out"
    },
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {
        "domainStrategy": "UseIP"
      }
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "outboundTag": "direct",
        "port": "53",
        "port": "22",
        "port": "18956"
      },
      {
        "outboundTag": "wg-out",
        "domain": ["geosite:apple", "geosite:google", "geosite:microsoft","geosite:steam","geosite:paypal","geosite:github"]
      },
      {
        "outboundTag": "block",
        "domain": ["geosite:cn", "geosite:private"]
      },
      {
        "outboundTag": "block",
        "ip": ["geoip:cn", "geoip:private"]
      },
      {
        "outboundTag": "wg-out",
        "network": "tcp,udp"
      }
    ]
  }
}
EOF
else
    echo "[INFO] 配置文件 $CONFIG_PATH 已存在，跳过自动生成以保留手动修改。"
fi

# --- 4. 运行 ---
export XRAY_LOCATION_ASSET=$ASSET_DIR
exec xray run -config "$CONFIG_PATH"

