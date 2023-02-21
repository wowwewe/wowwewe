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

