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
    clear
    green " ==============================================="
    green " 只支持win10-linux子系统的Ubuntu版本 "
    green " 必须使用root权限执行" 
    green " clash配置文件在/root/.config/clash  替换后修改congif.yaml"
    green " 用脚本更新clash配置文件，把文件放到c盘ubuntu/clash，并重命名为congif.yaml后执行"
    green " 更新clash去https://github.com/Dreamacro/clash/releases/tag/premium下载最新版本解压后传到自己的GitHub中"
    green " 更新控制台去https://github.com/Dreamacro/clash-dashboard/archive/refs/heads/gh-pages.zip下载最新版本解压重后重新打包为yacd.zip传到自己的GitHub中 "
    green " 备用控制台https://github.com/haishanh/yacd/releases "
    green " ==============================================="
    echo
    green " 1. 启动/重启Clash"
    green " 2. 关闭Clash"
    green " 3. 更新GeoIP"
    green " 4. 更新Clash-config"
    green " 5. 更新Clash"
    green " 6. 安装Clash"
    green " 7. 更换国内源"
    yellow " 0. 退出"
    echo
    read -p "Pls enter a number:" num
    case "$num" in
    1)
    start_clash
    ;;
    2)
    stop_clash
    ;;
    3)
    update_geoip
    ;;
    4)
    update_clash_config
    ;;
    5)
    update_clash
    ;;
    6)
    install_clash
    ;;
    7)
    update_apt
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
#更换国内源
function update_apt(){
    sudo cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo sed -i "s@http://.*archive.ubuntu.com@https://repo.huaweicloud.com@g" /etc/apt/sources.list
    sudo sed -i "s@http://.*security.ubuntu.com@https://repo.huaweicloud.com@g" /etc/apt/sources.list
    sudo apt update
	sudo apt upgrade 
	green " 源已更新"
}
#安装Clash
function install_clash(){
	apt install nginx vim unzip wget upx -y
        cd /root
	mkdir clash
	cd /root/clash
	wget https://raw.wewe.uk/RxmyLudpaws/MyBackup/patch/App/Clash/clash-linux-amd64
	chmod +x clash-linux-amd64
	upx --brute clash-linux-amd64 -o pogo
	rm -f clash-linux-amd64
	chmod +x pogo
	rm -rf /var/www/html/*
	cd /var/www/html
	wget https://raw.wewe.uk/RxmyLudpaws/MyBackup/patch/App/Clash/yacd.zip
	unzip yacd.zip
	rm -f yacd.zip
	green " clash 已安装"
}
#更新Clash
function update_clash(){
	cd /root/clash
	rm -f pogo
	wget https://raw.wewe.uk/RxmyLudpaws/MyBackup/patch/App/Clash/clash-linux-amd64
	chmod +x clash-linux-amd64
        upx --brute clash-linux-amd64 -o pogo
	rm -f clash-linux-amd64
	chmod +x pogo
	cd /var/www/html
	rm -rf /var/www/html/*
	wget https://raw.wewe.uk/RxmyLudpaws/MyBackup/patch/App/Clash/yacd.zip
	unzip yacd.zip
	rm -f yacd.zip
	green " clash 已更新"
}
#启动Clash
function start_clash(){
    killall -9 nginx 
    killall -9 pogo
    rm -f /root/clash/nohup.out
    nginx
    cd /root/clash
    nohup ./pogo &
}
#关闭Clash
function stop_clash(){
    killall -9 nginx 
    killall -9 pogo
}
#更新config
function update_clash_config(){
    killall -9 nginx 
    killall -9 pogo
	rm -f /root/.config/clash/config.yaml
	cp /mnt/c/ubuntu/clash/config.yaml /root/.config/clash
}
#更新GeoIP
function update_geoip(){
   killall -9 nginx 
   killall -9 pogo
   cd /root/.config/clash
   rm -f /root/.config/clash/Country.mmdb
   wget https://raw.wewe.uk/Loyalsoldier/geoip/release/Country.mmdb
   }
start_menu
