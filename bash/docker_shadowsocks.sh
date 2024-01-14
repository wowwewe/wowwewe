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
    green " 只支持使用Ubuntu20.04的国内AMD64机器 "
    green " 尽量使用非root账号运行 " 
    green " 如果aira2下载的文件，或者fb管理文件时遇到权限问题。请分别尝试root和非root账户安装 "
    green " 请分别尝试root和非root账户安装 "
    green " ==============================================="
    echo
    green " 1. 安装Docker"
    green " 2. 安装Shadowsocks"
    yellow " 0. 退出"
    echo
    read -p "Pls enter a number:" num
    case "$num" in
    1)
    curl -fsSL https://get.docker.com | bash -s docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
"ip":"127.0.0.1"
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
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
    blue "请输入用于连接的端口号 范围1-65533"
    blue "请注意不要重复使用端口"
    green "======================="
    read shadowsocks_port 
######################################
######################################
    green "======================="
    blue "请输入用于连接的密码"
    green "======================="
    read shadowsocks_password
######################################
######################################
    green "======================="
    blue "请输入用于连接DNS服务器"
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
######################################
    green "======================="
    blue "请输入服务器的IP"
    blue "可以是DNS域名"
	blue "此项是用来生成SS链接的"
    green "======================="
    read proxy_ip
######################################
sudo docker run -e PASSWORD=$shadowsocks_password \
            -e SERVER_ADDRS=::0 \
            -e DNS_ADDRS=$shadowsocks_dns \
            -e METHOD=$shadowsocks_method \
            -p $shadowsocks_port:8388 \
            -p $shadowsocks_port:8388/udp \
            --name ss-server \
             --restart=always \
            -d shadowsocks/shadowsocks-libev
urlsafe_base64(){
	date=$(echo -n "$1"|base64|sed ':a;N;s/\n/ /g;ta'|sed 's/ //g;s/=//g;s/+/-/g;s/\//_/g')
	echo -e "${date}"
}
SSbase64=$(urlsafe_base64 "${shadowsocks_method}:${shadowsocks_password}@${proxy_ip}:${shadowsocks_port}")
SSurl="ss://${SSbase64}"
######################################
    green "======================="
    blue  "SS链接：${SSurl}"
    green "======================="
}
###############以下内容别删别改，且必须放在最后#################
start_menu
