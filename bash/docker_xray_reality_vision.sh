#!/bin/bash
function blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
function green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
function red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
function key_xary(){
apt update && apt install wget vim python3 -y
mkdir -p /xray
cat > /xray/xraykey.py<<-EOF
#!/usr/bin/env python3
from cryptography.hazmat.primitives.asymmetric import x25519
from cryptography.hazmat.primitives import serialization
import base64
import uuid  # 新增 uuid 库

# 生成私钥
private_key = x25519.X25519PrivateKey.generate()

# 导出私钥字节
private_bytes = private_key.private_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PrivateFormat.Raw,
    encryption_algorithm=serialization.NoEncryption()
)

# 获取公钥
peer_public_key = private_key.public_key()

# 导出公钥字节
public_bytes = peer_public_key.public_bytes(
    encoding=serialization.Encoding.Raw,
    format=serialization.PublicFormat.Raw
)

# 转换成 xray 风格（Base64 URL-safe，去掉=号）
private_key_xray = base64.urlsafe_b64encode(private_bytes).decode().rstrip("=")
public_key_xray = base64.urlsafe_b64encode(public_bytes).decode().rstrip("=")

# 生成一个随机 UUID
random_uuid = str(uuid.uuid4())

print(private_key_xray)
print(public_key_xray)
print(random_uuid)

EOF
chmod +x /xray/xraykey.py
python3 /xray/xraykey.py
}

function check_xary(){
mapfile -t key_output < <(python3 /xray/xraykey.py)
    xrprivatekey="${key_output[0]}"
    xrpublickey="${key_output[1]}"
    uuid="${key_output[2]}"
sleep 2s
    blue "请输用于连接的端口(可以是443或其他未占用端口)"
    green "======================="
    read proxyport
    green "======================="
    blue "请输入伪装用的网站域名"
    blue " 网站必须支持tls1.3、h2链接"
    green "======================="
    read dest
    green "======================="
    blue "请输入伪装用的网站所用的端口，一般是443"
    green "======================="
    read destport
    green "======================="
    blue "请输入dns 用’,‘分割多个dns "
    blue "如果需要Ipv6访问外网，需要输入一个Ipv6 dns"
    blue " Google Ipv6 dns : 2001:4860:4860::8888 "  
    blue " 也可以使用DOH "  
    green "======================="
    read dnsserver
   ufw allow $proxyport/tcp
   ufw allow $proxyport/udp
    red "==============="
    red "这里按Y开启防火墙"
    red "如果防火墙开启成功会显示现在的规则"
    red "要再添加，请百度ufw"
    red "==============="
}
function rm_xray(){
     docker stop xray
    docker stop trojan-go
    docker stop fb
    docker stop acme
    docker stop plex
    docker stop nginx
    docker stop v2ray
    docker rm xray
    docker rm nginx
    docker rm v2ray
    docker rm trojan-go
    docker rm fb
    docker rm acme
    docker rm plex
    docker network rm proxynetwork
    docker network rm v2raynetwork
    rm -rf /xray
    docker rmi $(docker images -q)
}
function install_xray(){
curl -fsSL https://get.docker.com | bash -s docker
docker network create --ipv6 --subnet=10.1.1.0/24 proxynetwork
cat > /xray/config.json <<EOF
{
    "inbounds": [
        {
            "listen": "::0",
            "port": ${proxyport},
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "dns": {
              "servers": ["${dnsserver}"]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "dest": "${dest}:${destport}",
                    "serverNames": ["${dest}"],
                    "privateKey": "${xrprivatekey}",
                    "shortIds": [""]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

cat > /xray/update.sh <<EOF
docker stop xray
docker rm xray
docker rmi ghcr.io/xtls/xray-core
docker run -d --name=xray --restart=always -v /xray/config.json:/root/config.json -p $proxyport:$proxyport ghcr.io/xtls/xray-core -c /root/config.json
EOF

chmod +x /xray/update.sh
docker run -d --name=xray --restart=always -v /xray/config.json:/root/config.json -p $proxyport:$proxyport ghcr.io/xtls/xray-core -c /root/config.json
green "=============================="
green "         安装已经完成"
green "===========配置参数============"
red "UUID: ${uuid}"
red "PublicKey: ${xrpublickey}"
red "ServerName: ${dest}"
green "===========自动更新============"
blue "crontab -e        如果让选择编辑器选择vim"
blue "在最后一行加入   0 12 1 * * /xray/update.sh    "
blue " service cron reload && service cron restart "
}
rm_xray
key_xary
check_xary
install_xray
