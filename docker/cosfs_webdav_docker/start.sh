#!/bin/bash
if [ ! -d '/mnt/cos' ]
then
    mkdir -p '/mnt/cos'
    chmod a+w '/mnt/cos'
else
    echo "Path /mnt/cos is Ready"
fi
rm -f /root/webdavserver/webdav_config.yaml
cat >/root/webdavserver/webdav_config.yaml <<EOF
address: 0.0.0.0
port: 8080
auth: true
tls: false
prefix: /

scope: /mnt/cos
modify: true
rules: []

cors:
  enabled: true
  credentials: true
  allowed_headers:
    - Depth
  allowed_hosts:
    - http://localhost:8080
  allowed_methods:
    - GET
  exposed_headers:
    - Content-Length
    - Content-Range

users:
 - username: $DAV_USER
   password: $DAV_PWD
scope: /mnt/cos
modify: true
EOF
