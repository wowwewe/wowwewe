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
apt-get install -y ufw jq git curl vim unzip 
    green "======================="
    blue "请输用于连接的端口"
    green "======================="
   read proxyport
   ufw allow 22/tcp
   ufw allow $proxyport/tcp
   ufw allow $proxyport/udp
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
  function rm_start(){
  	sudo systemctl stop snell.service
  	sudo systemctl disable snell.service
  	rm -rf /lib/systemd/system/snell.service
  	rm -rf /snellproxy
  	start_install
  }
  	
  function start_install(){
    green "======================="
    blue "请到以下网址获取最新的版本的下载链接"
    blue " https://github.com/surge-networks/snell/releases "
    blue " 请输入下载链接"
    green "======================="
    read tagname
    mkdir /snellproxy
    cd /snellproxy
    wget $tagname
    unzip *.zip
    rm -rf *.zip
green "======================="
blue "请输入连接用密码"
green "======================="
read snellpassword
green "======================="
blue "请输入是否支持ipv6 "
blue "支持输入  true  "
blue "不支持输入  false  "
green "======================="
read snellipv6
green "======================="
blue "请输入obfs "
blue "可选项为 off  tls  http  "
blue "一般off即可 "
blue " 如果配置了http或tls，在客户端也需要有相应设置，并且要设置好混淆用的域名"
green "======================="
read snellobfs
cat > /snellproxy/snell-server.conf <<EOF
[snell-server]
listen = 0.0.0.0:$proxyport
psk = $snellpassword
ipv6 = $snellipv6
obfs = $snellobfs
EOF

sleep 2s
cat > /lib/systemd/system/snell.service <<EOF
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
LimitNOFILE=32768
ExecStart=/snellproxy/snell-server -c /snellproxy/snell-server.conf
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=snell-server

[Install]
WantedBy=multi-user.target
EOF
sleep 2s
sudo systemctl enable snell.service
sudo systemctl start snell.service
green "======================="
blue "安装完成,请使用 sudo systemctl status snell.service 查看是否运行"
blue "更新请重新运行脚本"
green "======================="
}
check_os
rm_start
