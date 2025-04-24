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
    green " 2. 安装Snell-shadowtls"
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
    blue "请输入snell的密码"
    green "======================="
    read snell_password
######################################
######################################
    green "======================="
    blue "请输入snell的dns用’,‘分割多个dns"
    blue "如果需要Ipv6访问外网，需要输入一个Ipv6 dns"
    blue " Google Ipv6 dns : 2001:4860:4860::8888 "    
    green "======================="
    read snell_dns
######################################
    docker stop sn-v4
    docker stop shadow-tls
    docker rm sn-v4
    docker rm shadow-tls
    docker network rm proxynetwork
    docker network rm v2raynetwork
    docker rmi $(docker images -q)
    docker network create --ipv6 --subnet=10.1.1.0/24 proxynetwork
    ufw allow $shadowtls_port
    ufw allow $shadowtls_port/udp
 sudo docker run -d -e PSK=$snell_password -e DNS=$snell_dns --name=sn-v4 --restart=always --network=proxynetwork --ip 10.1.1.188  wowaqly/sn_v4
 sudo docker run  \
            -e MODE=server \
            -e LISTEN=::0:$shadowtls_port  \
            -e SERVER=10.1.1.188:8388 \
            -e TLS=$shadowtls_web \
            -e PASSWORD=$shadowtls_password \
	    -e STRICT=1 \
	    -e RUST_LOG=error \
            -e V3=1 \
            --network host \
            --name shadow-tls \
            --restart=always \
            -d ghcr.io/ihciah/shadow-tls:latest
######################################
    green "======================="
    blue  "snell-shadow-tls搭建完成"
    green "======================="
}

###############以下内容别删别改，且必须放在最后#################
start_menu
