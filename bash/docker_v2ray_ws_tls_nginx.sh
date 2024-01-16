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
   ufw deny 28901
   ufw deny 28902
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
        install_v2ray_nginx
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
	    install_v2ray_nginx
	else
	    exit 1
	fi
    fi
}
#rm
function rm_v2ray_nginx(){
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
#install_v2ray_nginx
function install_v2ray_nginx(){
    curl -fsSL https://get.docker.com | bash -s docker
        sudo tee /etc/docker/daemon.json <<-'EOF'
{
"ip":"127.0.0.1"
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    docker network create --subnet=192.1.1.0/24 proxynetwork
    mkdir /v2ray
    mkdir /v2ray/nginx
    mkdir /v2ray/acme
    mkdir /v2ray/v2ray
    green "======================="
    blue "请输入密码（必须是uuid格式）"
    green "======================="
    read v2uuid
    green "======================="
    blue "请输入用于代理用WS传输的路径(注意要带上/)"
    blue "例如/mynewpath"
    green "======================="
    read newpath
    sleep 3s
cat > /v2ray/update.sh <<EOF
     docker stop nginx
     docker rm nginx
     docker rmi nginx
     docker stop v2ray
     docker rm v2ray 
     docker rmi v2fly/v2fly-core
     sleep 3s
     docker run -d \
          --restart=always \
          --name v2ray \
          --network=proxynetwork \
          --ip 192.1.1.13 \
          -v /v2ray/v2ray/config.json:/etc/v2ray/config.json \
          v2fly/v2fly-core run -c /etc/v2ray/config.json
    docker exec acme --renew -d $your_domain --force -k ec-384
    sleep 3s
    docker run -d \
         --restart=always \
         --name nginx \
         -v /v2ray/nginx/default.conf:/etc/nginx/conf.d/default.conf \
         -v /v2ray/acme/ssl:/home \
         --network=proxynetwork \
         --ip 192.1.1.113 \
         -p $proxyport:$proxyport \
         -p $proxyport:$proxyport/udp \
        nginx
    docker restart nginx
EOF
chmod +x /v2ray/update.sh
cat > /v2ray/nginx/default.conf<<-EOF
server { 
    listen       80;
    server_name  _;
    return 444;
    server_tokens off;
}
server { 
    listen       80;
    server_name  $your_domain;
    server_tokens off;
    #return 444;
    rewrite ^(.*)$  https://\$host\$1 permanent; 
}
server {
    listen [::]:$proxyport ssl;
    listen $proxyport ssl;
    listen  [::]:$proxyport quic reuseport;
    listen  $proxyport  quic reuseport;
    http2 on;
    add_header Alt-Svc 'h3=":8443";ma=2592000'
    server_name $your_domain;
    server_tokens off;
    proxy_intercept_errors on;
    error_page 400 = https://$your_domain:$proxyport;
    if (\$request_method !~ ^(GET)$ ) {
                    return 444;
    }
    if (\$http_user_agent ~* LWP::Simple|BBBike|wget|curl) {
               return 444;
    }
    #如果要设置成他人不能访问伪装的网站，先去cloud flare-dns设置一个error的解析并开启小黄云，然后去防火墙设置完整rul https://error.xxxx.xxx/ 为阻止。最后去掉#error_page 403 和 #deny all;这两行的注释
    #error_page 403 = https://error.xxxx.xxx;
    location / {
        #deny all;
        proxy_pass http://192.1.1.15:32400;
    }
    ssl_certificate /home/fullchain.cer; 
    ssl_certificate_key /home/$your_domain.key;
    #指定椭圆曲线，及时参考网络相关内容更换更安全的椭圆曲线
    ssl_ecdh_curve secp384r1;
    #TLS 版本控制
    ssl_protocols TLSv1.3;
    #如果要使用TLSv1.2,请在上一行的TLSv1.3前面加入TLSv1.2
    #  1.3 0-RTT
    ssl_early_data off;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security "max-age=31536000";
    #access_log /var/log/nginx/access.log combined;
    #v2ray
    location $newpath {
        proxy_redirect off;
	if (\$http_upgrade != "websocket") {
                return 444;
        }
        proxy_pass http://192.1.1.13:28901; 
	client_max_body_size 0;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        # Show real IP in v2ray access.log
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
  }
EOF
cat > /v2ray/v2ray/config.json<<-EOF
{
  "inbound": {
    "port": 28901,
    "listen":"0.0.0.0",
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$v2uuid",
          "alterId": 0
        }
      ]
    },
     "streamSettings": {
      "network": "ws",
      "wsSettings": {
     	 "path": "$newpath"
    	}
     }
  },
  "outbound": {
    "protocol": "freedom",
    "domainStrategy": "UseIP",
    "settings": {}
  },
  "log": {
    "loglevel": "error"
  },
  "dns": {
    "servers": ["localhost"]
  }
}
EOF
docker run -d  \
  -itd \
  --restart=always \
  -v /v2ray/acme/conf:/acme.sh  \
  -v /v2ray/acme/ssl:/nginx-ssl \
  --net=host \
  --name=acme \
  neilpang/acme.sh daemon
docker exec acme --set-default-ca  --server  letsencrypt
docker exec acme --issue  -d $your_domain  --standalone -k ec-384
docker exec acme mkdir /nginx-ssl
docker exec acme --install-cert -d  $your_domain   \
        --key-file   /nginx-ssl/$your_domain.key \
        --fullchain-file /nginx-ssl/fullchain.cer
  
docker run -d \
  --restart=always \
  --name v2ray \
  --network=proxynetwork \
  --ip 192.1.1.13 \
  -v /v2ray/v2ray/config.json:/etc/v2ray/config.json \
  v2fly/v2fly-core run -c /etc/v2ray/config.json
  
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
  
docker run -d \
  --restart=always \
  --name nginx \
  -v /v2ray/nginx/default.conf:/etc/nginx/conf.d/default.conf \
  -v /v2ray/acme/ssl:/home \
  --network=proxynetwork \
  --ip 192.1.1.113 \
  -p $proxyport:$proxyport \
  -p $proxyport:$proxyport/udp \
  nginx
  
green "=============================="
green "         安装已经完成"
blue "如果是使用了cloduflare works的反代，需要去/v2ray/nginx/default.conf把error_page 400 = 后面的网址改成反代后的网址,然后重启docker nginx"
green "===========配置参数============"
green "地址：${your_domain}"
green "端口：$proxyport"
green "uuid：${v2uuid}"
green "额外id：0"
green "加密方式：aes-128-gcm或auto"
green "传输协议：ws"
green "正常代理路径：${newpath}"
green "Tor代理路径：${torpath}"
green "底层传输：tls"
blue "crontab -e               如果让选择编辑器选择vim"
blue "在最后一行加入   0 12 1 * * /v2ray/update.sh    "
blue " service cron reload && service cron restart "
green 
 }
rm_v2ray_nginx
check_os 
check_env
start_install
