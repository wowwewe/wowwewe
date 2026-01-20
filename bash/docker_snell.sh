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
######################################
    green "======================="
    blue "请输入用于snell的端口号 范围1-65533"
    green "======================="
    read snell_port 
######################################
docker stop sn
docker rm sn
docker run -d -e PSK=$snell_password -e DNS=$snell_dns -e PORT=$snell_port --name=snv5 --restart=always -p=$snell_port:$snell_port  wowaqly/snv5
######################################
    green "======================="
    blue  "snell-shadow-tls搭建完成"
    green "======================="
