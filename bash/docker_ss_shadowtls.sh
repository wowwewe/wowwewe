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
#主菜单
function start_menu(){
    sudo apt-get install -y vim unzip git curl
    clear
    green " ==============================================="
    green " 只支持使用Ubuntu20.04以上的X86机器 "
    green " ==============================================="
    echo
    green " 1. 安装Docker"
    green " 2. 安装Shadowsocks-shadowtls"
    yellow " 0. 退出"
    echo
    read -p "Pls enter a number:" num
    case "$num" in
    1)
    curl -fsSL https://get.docker.com | bash -s docker
    green " Docker已安装"
    ;;
    2)
    install_shadowsocks
    ;;
    0)
    exit
    ;;
    *)
    clear
    red "Enter the correct number"
    sleep 2s
    start_menu
    ;;
    esac
}
function install_shadowsocks(){
######################################
    green "======================="
    blue "请输入用于shadow-tls的伪装网址,需要带端口号"
    blue "类似 bing.com:443"
    green "======================="
    read shadowtls_web
######################################
######################################
    green "======================="
    blue "请输入用于shadow-tls的端口号 范围1-65533"
    blue "推荐使用和伪装的网址同端口"
    green "======================="
    read shadowtls_port 
######################################
######################################
    green "======================="
    blue "请输入用于shadow-tls的密码"
    green "======================="
    read shadowtls_password
######################################
######################################
    green "======================="
    blue "请输入ss的密码"
    green "======================="
    read shadowsocks_password
######################################
######################################
    green "======================="
    blue "请输入用于ss的dns服务器"
    green "======================="
    read shadowsocks_dns
######################################
######################################
    green "======================="
    blue "请输入用于连接的加密方式"
    blue "一般情况用以下4个加密方式"
	blue "'aes-128-gcm' 'aes-256-gcm'"
	blue "'chacha20-ietf-poly1305' 'xchacha20-ietf-poly1305'"
    green "======================="
    read shadowsocks_method
######################################
    docker stop ss-server
    docker stop shadow-tls
    docker rm ss-server
    docker rm shadow-tls
    docker network rm proxynetwork
    docker network rm v2raynetwork
    docker rmi $(docker images -q)
    docker network create --subnet=192.1.1.0/24 proxynetwork
    ufw allow $shadowtls_port
    ufw allow $shadowtls_port/udp
sudo docker run -e PASSWORD=$shadowsocks_password \
             -e SERVER_ADDRS=::0 \
             -e DNS_ADDRS=$shadowsocks_dns \
             -e METHOD=$shadowsocks_method \
             --network=proxynetwork \
             --ip 192.1.1.195 \
             --name ss-server \
             --restart=always \
             -d shadowsocks/shadowsocks-libev
 sudo docker run  \
            -e MODE=server \
            -e LISTEN=0.0.0.0:$shadowtls_port  \
            -e SERVER=192.1.1.195:8388 \
            -e TLS=$shadowtls_web \
            -e PASSWORD=$shadowtls_password \
	    -e STRICT=1 \
            --network host \
            --name shadow-tls \
             --restart=always \
            -d ghcr.io/ihciah/shadow-tls:latest
######################################
    green "======================="
    blue  "ss-shadow-tls搭建完成"
    green "======================="
}

###############以下内容别删别改，且必须放在最后#################
start_menu
