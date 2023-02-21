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
    green " 只支持使用Ubuntu22.04+的AMD64机器 "
    green " 使用root账号运行 " 
    green " ==============================================="
    echo
    green " 1. 安装Plex"
    green " 2. 更新Plex"
    green " 3. 安装Docker"
    yellow " 0. 退出"
    echo
    read -p "Pls enter a number:" num
    case "$num" in
    1)
    plex_menu
    ;;
    2)
    update_plex
    ;;
    3)
    install_docker
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
function plex_menu(){
    clear
    green " ==============================================="
    green " 是否要删除之前plex的源数据 "
    green " 请注意删除后所有设置都会重置 "
    green "
==============================================="
    echo
    green " 1. 不删除"
    green " 2. 删除"
    echo
    read -p "Pls enter a number:" num
    case "$num" in
    1)
    install_plex
    ;;
    2)
    rm -rf /docker/plex
    install_plex
    ;;
    esac
}

function install_docker(){
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://mirror.ccs.tencentyun.com","http://hub-mirror.c.163.com"]
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
}
function install_plex(){
    green "======================="
    blue "请输入媒体文件的路径 需要带/"
    blue "例如 /mnt/nas"
    green "======================="
    read file
    green "======================="
    blue "https://www.plex.tv/claim/"
    blue "请打开以上网站,获取并复制Claim Code "
    green "======================="
    read claimcode
docker stop plex
docker rm plex
docker rmi $(docker images -q)
mkdir /docker
mkdir /docker/plex
mkdir /docker/plex/config
mkdir /docker/plex/transcode
docker run \
  -d \
  --name plex \
  --network=host \
  --restart=always \
  -e TZ="Asia/Shanghai" \
  -e PLEX_CLAIM="$claimcode" \
  -v /docker/plex/config:/config \
  -v /docker/plex/transcode:/transcode \
  -v $file:/data \
  --privileged=true \
  plexinc/pms-docker
    green "======================="
    blue "安装完成 plex配置文件在 /docker/plex"
    green "======================="
}
function update_plex(){
    green "======================="
    blue "请输入媒体文件的路径 需要带/"
    blue "例如 /mnt/nas"
    green "======================="
    read file
    green "======================="
    blue "https://www.plex.tv/claim/"
    blue "请打开以上网站,获取并复制Claim Code "
    green "======================="
    read claimcode

docker stop plex
docker rm plex
docker rmi $(docker images -q)
docker run \
  -d \
  --name plex \
  --network=host \
  --restart=always \
  -e TZ="Asia/Shanghai" \
  -e PLEX_CLAIM="$claimcode" \
  -v /docker/plex/config:/config \
  -v /docker/plex/transcode:/transcode \
  -v $file:/data \
  --privileged=true \
  plexinc/pms-docker
}
start_menu

