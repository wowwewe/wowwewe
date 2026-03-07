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
[ -z "$domain" ] && echo "ERROR: domain is required" && exit 1
[ -z "$privatekey" ] && echo "ERROR: privatekey is required" && exit 1
[ -z "$wgip" ] && echo "ERROR: wgip is required" && exit 1
[ -z "$publickey" ] && echo "ERROR: publickey is required" && exit 1
[ -z "$wgserver" ] && echo "ERROR: wgserver is required" && exit 1

mkdir -p "$DATA_DIR"
chmod 700 "$DATA_DIR"

# --- 1. 下载 Geo 资源文件 (强制重新下载) ---
echo "[INFO] 正在强制更新 Geo 资源文件..."

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
if [ ! -f "$SHORTID_FILE" ]; then
    head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$SHORTID_FILE"
    chmod 600 "$SHORTID_FILE"
fi
REALITY_SHORTID=$(cat "$SHORTID_FILE")

if ! echo "$REALITY_SHORTID" | grep -Eq '^[0-9a-fA-F]{1,8}$'; then
    echo "ERROR: Invalid generated shortId"
    exit 1
fi

if [ ! -f "$UUID_FILE" ]; then
    cat /proc/sys/kernel/random/uuid > "$UUID_FILE"
    chmod 600 "$UUID_FILE"
fi
UUID=$(cat "$UUID_FILE")

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

# --- 3. NGINX 与 ACME 自动化 ---

# 生成 /usr/local/bin/ssl.sh 供容器内手动或自动调用
cat > /usr/local/bin/ssl.sh << EOF
#!/bin/sh
echo "[INFO] 启动 ACME 更新进程 (Let's Encrypt 384ECC)..."
mkdir -p /data/ssl
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d "${domain}" --standalone --keylength ec-384 --force
~/.acme.sh/acme.sh --install-cert -d "${domain}" --ecc \\
  --key-file /data/ssl/server.key \\
  --fullchain-file /data/ssl/server.crt
echo "[SUCCESS] 证书申请完成"
EOF
chmod +x /usr/local/bin/ssl.sh

# 检查证书状态并按需触发生成
if [ ! -f "/data/ssl/server.crt" ]; then
    echo "[INFO] 未检测到证书，开始执行 ssl.sh 获取初始证书..."
    /usr/local/bin/ssl.sh
else
    echo "[INFO] SSL 证书已存在，跳过首次申请。"
fi

# 生成安全的 Nginx 配置 (完全禁用日志并搭载动态 Reference 401 页面)
if [ ! -f "/data/nginx.conf" ]; then
cat > /data/nginx.conf << 'EOF'
user root;
worker_processes auto;
pid /run/nginx.pid;
events {
    worker_connections 1024;
}
http {
    # 彻底关闭日志提高安全性
    access_log off;
    error_log /dev/null emerg;
    server_tokens off;

    # 强化安全响应头
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Frame-Options DENY;

    server {
        listen 20987 ssl;

        ssl_certificate /data/ssl/server.crt;
        ssl_certificate_key /data/ssl/server.key;
        ssl_protocols TLSv1.3;
        ssl_prefer_server_ciphers on;
        error_page 401 /401.html;
        # 直接全局返回 401
        location / {
            return 401;
        }

        # 动态伪装错误页，通过 $msec 和 $request_id 让每次访问的 Reference # 均不相同
        location = /401.html {
            internal;
            default_type text/html;
            return 401 "<!DOCTYPE html>\n<html>\n<head>\n<title>Unauthorized</title>\n<style>\nbody{font-family:-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;background-color:#141414;color:#e5e5e5;text-align:center;padding-top:12vh;}\nh1{font-size:26px;font-weight:400;margin-bottom:10px;}\np{color:#777;font-size:14px;}\n</style>\n</head>\n<body>\n<h1>An error occurred while processing your request.</h1>\n<p>Reference #$msec.$request_id</p>\n</body>\n</html>";
        }
    }
}
EOF
fi

# 启动 Nginx 与 Cron (以支持 acme.sh 自动续签计划任务)
nginx -c /data/nginx.conf || true
service cron start || true


echo "===== XRAY RUNTIME INFO ====="
echo "UUID: $UUID"
echo "Reality PublicKey: $REALITY_PUBLIC"
echo "Reality ShortID: $REALITY_SHORTID"
echo "serverName: $domain"
echo "=============================="
echo " "
echo "===== 每日自动更新定时任务 (请在宿主机执行 crontab -e 添加) ====="
echo "0 5 * * * docker restart 你的容器NAME"
echo "0 3 1 * * docker exec 你的容器NAME ssl.sh"
echo "====执行以下让cron生效===="
echo "service cron reload && service cron restart"
echo "==============================================================="
echo " "

# --- 4. 生成 config.json (带防覆盖判断) ---
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
          "target": "127.0.0.1:20987",
          "xver": 0,
          "serverNames": ["$domain"],
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
        "port": "18956,22,53"
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

# --- 5. 运行 ---
export XRAY_LOCATION_ASSET=$ASSET_DIR
exec xray run -config "$CONFIG_PATH"
