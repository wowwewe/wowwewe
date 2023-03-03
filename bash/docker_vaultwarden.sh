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
function start_menu(){
    clear
    green " ==============================================="
    green " 只支持使用Ubuntu22.04的机器 "
    green " 使用root账号运行 " 
    green " 请把SSL证书以域名命名并放入/root/ssl "
    green " 例如 xxx.xxxx.com.pem   xxx.xxxx.com.key "
    green " 如果是有备份的情况下重新安装，先新建文件夹/mypassword/vaultwarden，然后把备份文件解压后的所有文件cp到/mypassword/vaultwarden "
     green " 安装完成后默认每12小时备份一次到指定文件夹，如果需要手动备份请执行 备份库 "
     green " 默认关闭了web页面，只能通过app链接，需要web页面请把脚本中的-e WEB_VAULT_ENABLED=false 改为 -e WEB_VAULT_ENABLED=true "
    green " ==============================================="
    echo
    green " 1. 备份库"
    green " 2. 更新vaultwarden"
    green " 3. 更新ssl证书"
    green " 8. 安装vaultwarden"
    yellow " 0. 退出"
    echo
    read -p "Pls enter a number:" num
    case "$num" in
    1)
    backup-data
    ;;
    2)
    update_vaultwarden
    ;;
    3)
    update-ssl
    ;;
    8)
    install_vaultwarden
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
#backup-data
function backup-data(){
bash /mypassword/vaultwarden-backup.sh
green "======================="
blue " 备份完成，请去备份文件夹查看 "
green "======================="
}

#update-ssl
function update-ssl(){
    green "======================="
    blue " 请使用PEM格式的SSL证书 "
    blue " 请把SSL证书以域名命名并放入/root/ssl "
    blue " 例如 xxx.xxxx.com.pem   xxx.xxxx.com.key "
    blue "如果没有放好证书请ctrl+c退出安装"
    blue "如果放好了证书请输入绑定的域名"
    blue "例如 xxx.xxxx.com"
    green "======================="
    read domainupdatessl
    docker stop vaultwarden-nginx
    cd /mypassword/vaultwarden-nginx/ssl && rm -f *.pem && rm -f *.key
    cp /root/ssl/$domainupdatessl.* /mypassword/vaultwarden-nginx/ssl
    docker restart vaultwarden-nginx
}
#update
function update_vaultwarden(){
    docker stop vaultwarden-nginx
    docker stop vaultwarden
    docker rm vaultwarden
    docker rmi $(docker images -q)
    docker run -d \
      --name vaultwarden \
      -e WEB_VAULT_ENABLED=false \
      -v /mypassword/vaultwarden/:/data/ \
      --network=vaultwarden-network \
      --ip 192.88.88.11 \
      vaultwarden/server:latest
    docker restart vaultwarden-nginx
}
#install_vaultwarden
function install_vaultwarden(){
    green "如果只是更新请选择更新，脚本会等待20秒，如果不是要安装请ctrl+c退出"
    green " 默认关闭了web页面，只能通过app链接，需要web页面请把脚本中的-e WEB_VAULT_ENABLED=false 改为 -e WEB_VAULT_ENABLED=true "
    green "sleep 20"
    sleep 20
    green "======================="
    blue "请输用于连接的端口"
    green "======================="
    read port
    green "======================="
    blue " 请使用PEM格式的SSL证书 "
    blue " 请把SSL证书以域名命名并放入/root/ssl "
    blue " 例如 xxx.xxxx.com.pem   xxx.xxxx.com.key "
    blue "如果没有放好证书请ctrl+c退出安装"
    blue "如果放好了证书请输入绑定的域名"
    blue "例如 xxx.xxxx.com"
    green "======================="
    read domain
    green "======================="
    blue "请输入用于存放备份的文件夹路径"
    blue "例如 /mnt/xxx/xxx"
    green "======================="
    read backupway
    green "======================="
    blue "请输入备份文件的打包密码"
    green "======================="
    read backup_password
   green "======================="
    blue "请输入备份文件的打包密码的秘密提示"
   blue "不要输入密码本身，输入提示即可"
    green "======================="
    read backup_password_prompt
    blue "开始安装"
    sleep 3s
    apt-get update
    apt-get install -y zip unzip vim
    docker stop vaultwarden-nginx
    docker stop vaultwarden
    docker rm vaultwarden
    docker rm vaultwarden-nginx
    docker rmi $(docker images -q)
    rm -rf /mypassword/vaultwarden-nginx
    rm -f /mypassword/vaultwarden-backup.sh
   mkdir /mypassword
   mkdir /mypassword/vaultwarden
   mkdir /mypassword/vaultwarden-nginx
   mkdir /mypassword/vaultwarden-nginx/ssl
   cp /root/ssl/$domain.* /mypassword/vaultwarden-nginx/ssl
   
cat > /mypassword/vaultwarden-nginx/default.conf<<-EOF
server {
    listen $port ssl http2;
    server_name $domain;
    server_tokens off;
    proxy_intercept_errors on;
    location / {
        proxy_pass http://192.88.88.11:80;
    }
    ssl_certificate /home/$domain.pem; 
    ssl_certificate_key /home/$domain.key;
    ssl_protocols TLSv1.3;
    ssl_early_data off;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security "max-age=31536000";
  }
EOF

cat > /mypassword/vaultwarden-backup.sh<<-EOF
#!/bin/bash
cd $backupway
zip -q -r -P $backup_password vaultwarden_backup_"\$(date +"%Y_%m_%d_%H_%M")"_"$backup_password_prompt".zip /mypassword/vaultwarden
EOF

chmod +x /mypassword/vaultwarden-backup.sh

docker network rm vaultwarden-network
docker network create --subnet=192.88.88.0/24 vaultwarden-network

#关闭web界面访问添加 -e WEB_VAULT_ENABLED=false
#开启admin管理界面添加 -e ADMIN_TOKEN=密码 然后访问http(s)://ip:port/admin
#关闭新用户注册 SIGNUPS_ALLOWED=false
docker run -d \
--restart=always \
--name vaultwarden \
-v /mypassword/vaultwarden/:/data/ \
--network=vaultwarden-network \
--ip 192.88.88.11 \
-e DISABLE_ICON_DOWNLOAD=true \
-e ICON_CACHE_TTL=0 \
-e ICON_CACHE_NEGTTL=0 \
vaultwarden/server:latest
   
 docker run -d \
  --restart=always \
  --name vaultwarden-nginx \
  -v /mypassword/vaultwarden-nginx/default.conf:/etc/nginx/conf.d/default.conf \
  -v /mypassword/vaultwarden-nginx/ssl:/home \
  --net=host \
  nginx
  
  
    
green "=============================="
green "         安装已经完成"
blue "请自行修改crontab以自动备份，操作如下"
blue "crontab -e               如果让选择编辑器选择vim"
blue "在最后一行加入   0 */12 * * * /mypassword/vaultwarden-backup.sh    "
blue " service cron reload && service cron restart "
green "=============================="
}
start_menu
