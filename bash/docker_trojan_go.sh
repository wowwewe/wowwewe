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
function check_os(){
green "系统支持检测"
sleep 3s
if   cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
    systemPackage="apt-get"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
    systemPackage="apt-get"
fi
    sleep 2s
    green "======================="
    blue "请输用于连接的端口(可以是443或其他未占用端口)"
    blue "不要用80，32400，28901，28902"
    green "======================="
    read proxyport
   apt-get update
   apt-get install -y ufw jq git curl vim openssl
   ufw allow 80/tcp
   ufw allow $proxyport/tcp
   ufw allow $proxyport/udp
   ufw allow 22/tcp
   ufw deny 32400
    red "==============="
    red "这里按Y开启防火墙"
    red "如果防火墙开启成功会显示现在的规则"
    red "要再添加，请百度ufw"
    red "==============="
    sleep 1s
    ufw enable
    sleep 2s
    ufw status
    sleep 5s
}
#安装环境监测
function check_env(){
green "安装环境监测"
sleep 3s
firewall_status=`firewall-cmd --state`
if [ "$firewall_status" == "running" ]; then
    green "检测到firewalld开启状态，添加放行80端口规则"
    firewall-cmd --zone=public --add-port=80/tcp --permanent
    firewall-cmd --reload
fi
$systemPackage -y install net-tools socat >/dev/null 2>&1
Port80=`netstat -tlpn | awk -F '[: ]+' '$1=="tcp"{print $5}' | grep -w 80`
if [ -n "$Port80" ]; then
    process80=`netstat -tlpn | awk -F '[: ]+' '$5=="80"{print $9}'`
    red "==========================================================="
    red "检测到80端口被占用，占用进程为：${process80}，本次安装结束"
    red "==========================================================="
    exit 1
fi
}
#start_install
function start_install(){
    green "======================="
    blue "请输入绑定到本VPS的域名"
    blue " 如果你的域名已经添加过Cloudflare的cdn，需要先去取消cdn(小黄云），安装完成后再打开cdn(小黄云) "
    green "======================="
    read your_domain
    real_addr=`ping ${your_domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
    local_addr=`curl ipv4.icanhazip.com`
    if [ $real_addr == $local_addr ] ; then
    green "=========================================="
	green "         域名解析正常，开始安装"
	green "=========================================="
        install_trojan-go
    else
    red "===================================="
	red "域名解析地址与本VPS IP地址不一致"
	red "若你确认解析成功你可强制脚本继续运行"
	red "===================================="
	read -p "是否强制运行 ?请输入 [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
            green "强制继续运行脚本"
	    sleep 1s
	    install_trojan-go
	else
	    exit 1
	fi
    fi
}
#rm
function rm_trojian(){
    docker stop trojan-go
    docker stop fb
    docker stop acme
    docker stop plex
    docker stop nginx
    docker stop v2ray
    docker rm nginx
    docker rm v2ray
    docker rm trojan-go
    docker rm fb
    docker rm acme
    docker rm plex
    docker network rm proxynetwork
    rm -rf /trojan-go
    docker network rm v2raynetwork
    rm -rf /v2ray
    docker rmi $(docker images -q)
}
#install
function install_trojan-go(){
    curl -fsSL https://get.docker.com | bash -s docker
    docker network create --subnet=192.1.1.0/24 proxynetwork
    mkdir /trojan-go
    mkdir /trojan-go/acme
    mkdir /trojan-go/trojan-go
    green "======================="
    blue "请输入密码（可以是uuid格式）"
    green "======================="
    read trojan_password
    green "======================="
    blue "请输入ws传输的path路径，必须带有/，例如/abc123"
    green "======================="
    read trojan_ws
    sleep 3s
cat > /trojan-go/update.sh <<EOF
docker stop trojan-go
docker rm trojan-go
docker rmi p4gefau1t/trojan-go
sleep 3s
docker exec acme --renew -d $your_domain --force
sleep 3s
docker run \
  -d \
  --network host \
  --name trojan-go \
  --restart=always \
  -v /trojan-go/trojan-go:/etc/trojan-go \
  -v /trojan-go/acme/ssl:/ssl \
  p4gefau1t/trojan-go
EOF
cat > /trojan-go/trojan-go/config.json <<EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": $proxyport,
    "remote_addr": "192.1.1.15",
    "remote_port": 32400,
    "password": [
        "$trojan_password"
    ],
    "disable_http_check": false,
    "udp_timeout": 120,
    "ssl": {
        "prefer_server_cipher": true,
        "cipher": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "fingerprint": "chrome",
        "verify": true,
        "verify_hostname": true,
        "cert": "/ssl/fullchain.cer",
        "key": "/ssl/$your_domain.key",
        "sni": "$your_domain",
        "alpn": [
           "http/1.1",
	   "h2"
        ],
        "session_ticket": true,
        "reuse_session": true
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "prefer_ipv4": false
    },
    "websocket": {
        "enabled": true,
        "path": "$trojan_ws",
        "host": "$your_domain"
    },
    "forward_proxy": {
    "enabled": false,
    "proxy_addr": "",
    "proxy_port": 0,
    "username": "",
    "password": ""
  }
}
EOF
chmod +x /trojan-go/update.sh
docker run -d  \
  -itd \
  --restart=always \
  -v /trojan-go/acme/conf:/acme.sh  \
  -v /trojan-go/acme/ssl:/home-ssl \
  --net=host \
  --name=acme \
  neilpang/acme.sh daemon
docker exec acme --set-default-ca  --server  letsencrypt
docker exec acme --issue  -d $your_domain  --standalone
docker exec acme mkdir /home-ssl
docker exec acme --install-cert -d  $your_domain   \
        --key-file   /home-ssl/$your_domain.key \
        --fullchain-file /home-ssl/fullchain.cer
        
#plex 端口32400
docker run \
  -d \
  --network=proxynetwork \
  --ip 192.1.1.15 \
  --name plex \
  --restart=always \
  plexinc/pms-docker
 
#emby 端口8096
#docker run -d \
#      --name emby \
#      --network=proxynetwork \
#      --ip 192.1.1.15 \
#      --restart=always \
#       emby/embyserver:latest

#filebrowser 端口80      
#docker run \
#   -d \
#   --restart=always \
#   --name fb \
#    --network=proxynetwork \
#    --ip 192.1.1.15 \
#    filebrowser/filebrowser
 docker run \
 -d \
 --network host \
 --name trojan-go \
 --restart=always \
 -v /trojan-go/trojan-go:/etc/trojan-go \
 -v /trojan-go/acme/ssl:/ssl \
 p4gefau1t/trojan-go
  
green "=============================="
green " 安装已经完成,请自行输入以下指令，添加自动更新ssl及trojan-go"
blue "crontab -e               如果让选择编辑器选择vim"
blue "在最后一行加入   0 12 1 * * /trojan-go/update.sh    "
blue " service cron reload && service cron restart "
blue "要设置前置代理把配置文件"forward_proxy":段的"enabled": false,改为true，proxy_addr=socks5代理地址，proxy_port=socks5代理端口，如果没有密码username password留空即可"
green "===========配置参数============"
green "地址：${your_domain}"
green "端口：$proxyport"
green "uuid：${trojan_password}"
green "ws路径：${trojan_ws}"
green 
 }
rm_trojian
check_os 
check_env
start_install
