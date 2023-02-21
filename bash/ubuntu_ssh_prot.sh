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

function update_ssh_port(){
	green "======================="
	blue "请更改文件中的Port字段为你需要ssh的端口号"
	blue "请注意不要用重复端口号"
	sleep 5s
	sudo vim /etc/ssh/sshd_config
	green "======================="
	blue "请输入你刚才改动后的端口号"
	green "======================="
	read port
	sudo ufw allow $port
	sudo ufw reload
	sudo /etc/init.d/ssh restart
	sudo systemctl restart ssh.service
	blue "完成,请使用$port进行ssh连接"
}
update_ssh_port



