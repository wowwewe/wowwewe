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
function rmload(){
apk update
apk upgrade
apk add docker
rc-update add docker boot
service docker start
ufw allow 443/tcp
ufw allow 443/udp
ufw allow 80/tcp
docker stop registry-hub
docker stop registry-ghcr
docker stop registry-k8s
docker stop acme-speedhub
docker stop nginx-speed
docker rm registry-hub
docker rm registry-ghcr
docker rm registry-k8s
docker rm acme-speedhub
docker rm nginx-speedhub
docker network rm hubnet
rm -rf /docker/speedhub
docker rmi $(docker images -q)
}
function install(){
    docker network create --subnet=192.168.219.0/24 hubnet
	mkdir -p /docker
    mkdir -p /docker/speedhub
    mkdir -p /docker/speedhub/acme
    mkdir -p /docker/speedhub/acme/ssl
    mkdir -p /docker/speedhub/acme/conf	
    mkdir -p /docker/speedhub/nginx  
    mkdir -p /docker/speedhub/registry-ghcr  
    mkdir -p /docker/speedhub/registry-hub  
    mkdir -p /docker/speedhub/registry-k8s
    mkdir -p /docker/speedhub/registry-ghcr/conf
    mkdir -p /docker/speedhub/registry-hub/conf
    mkdir -p /docker/speedhub/registry-k8s/conf
	green "======================="
    blue "请输入一级域名，例如abc.com"
	blue "IP需要DNS解析到@.abc.com和*.abc.com"
    green "======================="
    read your_domain
	sleep 2s
	#ghcr-conf
	cat > /docker/speedhub/registry-ghcr/conf/registry-ghcr.yml <<EOF 
version: 0.1
log:
  fields:
    service: registry
storage:
  filesystem:
    rootdirectory: /var/lib/registry
  #inmemory: #此存储驱动程序不会在运行期间保留任何数据,适合磁盘空间下的机器使用(但是会使用内存开销,只适合测试)
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
    blobdescriptorsize: 10000
  maintenance:
    uploadpurging:
      enabled: true
      age: 2h
      interval: 2h
      dryrun: false
    readonly:
      enabled: false
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept', 'Cache-Control']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']

health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3

proxy:
  remoteurl: https://ghcr.io
  username:
  password:
  ttl: 1h
EOF

sleep 3s
#dockerhub-conf    
   cat > /docker/speedhub/registry-hub/conf/registry-hub.yml <<EOF 
version: 0.1
log:
  fields:
    service: registry
storage:
  filesystem:
    rootdirectory: /var/lib/registry
  #inmemory: #此存储驱动程序不会在运行期间保留任何数据,适合磁盘空间下的机器使用(但是会使用内存开销,只适合测试)
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
    blobdescriptorsize: 10000
  maintenance:
    uploadpurging:
      enabled: true
      age: 2h
      interval: 2h
      dryrun: false
    readonly:
      enabled: false
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept', 'Cache-Control']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']

health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3

proxy:
  remoteurl: https://registry-1.docker.io
  username:
  password:
  ttl: 1h
EOF

sleep 3s
#k8s-conf
   cat > /docker/speedhub/registry-k8s/conf/registry-k8s.yml <<EOF
version: 0.1
log:
  fields:
    service: registry
storage:
  filesystem:
    rootdirectory: /var/lib/registry
  #inmemory: #此存储驱动程序不会在运行期间保留任何数据,适合磁盘空间下的机器使用(但是会使用内存开销,只适合测试)
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
    blobdescriptorsize: 10000
  maintenance:
    uploadpurging:
      enabled: true
      age: 2h
      interval: 2h
      dryrun: false
    readonly:
      enabled: false
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['HEAD', 'GET', 'OPTIONS', 'DELETE']
    Access-Control-Allow-Headers: ['Authorization', 'Accept', 'Cache-Control']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']

health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3

proxy:
  remoteurl: https://registry.k8s.io
  username:
  password:
  ttl: 1h
EOF

sleep 3s
#nginx-conf
cat > /docker/speedhub/nginx/default.conf <<EOF
server {
    listen       80;
    server_name  _;
    return 444;
    server_tokens off;
}
server {
    listen       80;
    server_name  shub.wewe.uk;
    server_tokens off;
    #return 444;
    rewrite ^(.*)$  https://\$host\$1 permanent;
    }
server {
    #禁止ip直接访问
    listen [::]:443 ssl;
    listen 443 ssl;
    http2 on;
    server_name  _;
    return 444;
    server_tokens off;
    ssl_certificate /home/$your_domain.pem;
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
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
    if (\$request_method !~ ^(GET)$ ) {
                    return 444;
    }
    if (\$http_user_agent ~* LWP::Simple|BBBike|wget|curl) {
               return 444;
    }
}
#反代docker hub镜像源

server {
 listen 443 ssl;
 server_name hub.$your_domain;

 ssl_certificate /home/$your_domain.pem;
    ssl_certificate_key /home/$your_domain.key;

#指定椭圆曲线，及时参考网络相关内容更换更安全的椭圆曲线
    ssl_ecdh_curve secp384r1;
    #TLS 版本控制
    ssl_protocols TLSv1.3; 
    location / {
    proxy_pass http://192.168.219.111:5000;
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_redirect off;
    proxy_buffering off;
    proxy_set_header        Host            \$host;
    proxy_set_header        X-Real-IP       \$remote_addr;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
server {
 listen 443 ssl;
 server_name ghcr.$your_domain;

 ssl_certificate /home/$your_domain.pem;
    ssl_certificate_key /home/$your_domain.key;

#指定椭圆曲线，及时参考网络相关内容更换更安全的椭圆曲线
    ssl_ecdh_curve secp384r1;
    #TLS 版本控制
    ssl_protocols TLSv1.3;
    location / {
    proxy_pass http://192.168.219.112:5000;
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_redirect off;
    proxy_buffering off;
    proxy_set_header        Host            \$host;
    proxy_set_header        X-Real-IP       \$remote_addr;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
server {
 listen 443 ssl;
 server_name k8s.$your_domain;

 ssl_certificate /home/$your_domain.pem;
    ssl_certificate_key /home/$your_domain.key;

#指定椭圆曲线，及时参考网络相关内容更换更安全的椭圆曲线
    ssl_ecdh_curve secp384r1;
    #TLS 版本控制
    ssl_protocols TLSv1.3;
    location / {
    proxy_pass http://192.168.219.113:5000;
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
    proxy_redirect off;
    proxy_buffering off;
    proxy_set_header        Host            \$host;
    proxy_set_header        X-Real-IP       \$remote_addr;
    proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
server {
        listen 443 ssl;
 server_name raw.$your_domain;

 ssl_certificate /home/$your_domain.pem;
    ssl_certificate_key /home/$your_domain.key;
    ssl_ecdh_curve secp384r1;
    ssl_protocols TLSv1.3;
location / {
    proxy_pass https://raw.githubusercontent.com;
    proxy_set_header Host raw.githubusercontent.com;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
}
server {
        listen 443 ssl;
 server_name git.$your_domain;

 ssl_certificate /home/$your_domain.pem;
    ssl_certificate_key /home/$your_domain.key;
    ssl_ecdh_curve secp384r1;
    ssl_protocols TLSv1.3;
location / {
    proxy_pass https://github.com;
    proxy_set_header Host github.com;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
}
}
EOF

#registry
docker run -d --restart=always --network=hubnet --ip=192.168.219.111 --name registry-hub -v /docker/speedhub/registry-hub/conf/registry-hub.yml:/etc/docker/registry/config.yml  -v /docker/speedhub/registry-hub/data:/var/lib/registry registry

docker run -d --restart=always --network=hubnet --ip=192.168.219.112 --name registry-ghcr -v /docker/speedhub/registry-ghcr/conf/registry-ghcr.yml:/etc/docker/registry/config.yml  -v /docker/speedhub/registry-ghcr/data:/var/lib/registry registry

docker run -d --restart=always --network=hubnet --ip=192.168.219.113 --name registry-k8s -v /docker/speedhub/registry-k8s/conf/registry-k8s.yml:/etc/docker/registry/config.yml  -v /docker/speedhub/registry-k8s/data:/var/lib/registry registry

#acme
	docker run -d  \
     -itd \
     --restart=always \
     -v /docker/speedhub/acme/conf:/acme.sh  \
     -v /docker/speedhub/acme/ssl:/nginx-ssl \
     --net=host \
     --name=acme-speedhub \
     neilpang/acme.sh daemon
    docker exec acme-speedhub --set-default-ca  --server  letsencrypt
    docker exec acme-speedhub --issue -d hub.$your_domain -d ghcr.$your_domain -d k8s.$your_domain -d git.$your_domain -d raw.$your_domain --standalone --keylength ec-384
    docker exec acme-speedhub mkdir /nginx-ssl
    docker exec acme-speedhub --install-cert -d hub.$your_domain -d ghcr.$your_domain -d k8s.$your_domain -d git.$your_domain -d raw.$your_domain   \
        --key-file   /nginx-ssl/$your_domain.key \
        --fullchain-file /nginx-ssl/$your_domain.pem
#nginx
docker run -d   --restart=always   --name nginx-speedhub   -v /docker/speedhub/nginx/default.conf:/etc/nginx/conf.d/default.conf   -v /docker/speedhub/acme/ssl:/home   --network=hubnet   --ip=192.168.219.2   -p 443:443   -p 443:443/udp   nginx
#clean.sh
cat > /docker/speedhub/clean.sh <<EOF 
#!/bin/bash
docker stop registry-ghcr
docker stop registry-hub
docker stop registry-k8s
rm -rf /docker/speedhub/registry-ghcr/data/*
rm -rf /docker/speedhub/registry-hub/data/*
rm -rf /docker/speedhub/registry-k8s/data/*
docker start registry-ghcr
docker start registry-hub
docker start registry-k8s
EOF

chmod +x /docker/speedhub/clean.sh
#sslupdate
cat > /docker/speedhub/sslupdate.sh <<EOF 
#!/bin/bash
docker exec acme-speedhub --renew -d hub.$your_domain -d ghcr.$your_domain -d k8s.$your_domain -d git.$your_domain -d raw.$your_domain --force --keylength ec-384
sleep 1s
docker restart nginx-speedhub
EOF

chmod +x /docker/speedhub/sslupdate.sh
green "安装完成,加速地址为hub/ghcr/k8s/raw/git.你的域名"
blue "crontab -e               如果让选择编辑器选择vim"
blue "加入   TZ="Asia/Shanghai" 0 3 * * * /docker/speedhub/clean.sh    "
blue "加入   TZ="Asia/Shanghai" 0 5 1 * * /docker/speedhub/sslupdate.sh    "
blue " service cron reload && service cron restart "
green 
}
rmload
install
