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
echo "">/var/log/wtmp
echo ""> /var/log/btmp
echo ""> ./.bash_history
rm -rf ~/.bash_history
history -c
sleep 1s
lastb
last
green "======================="
    blue "已清除历史登陆IP及历史命令"
    blue "请输入 lastb 和 last 查看是否有登陆IP信息，若没有则成功了"
green "======================="
