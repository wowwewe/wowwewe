#!/bin/bash
rm -rf ~/.cos.conf && coscmd config -a ${SECRETID} -s ${SECRETKEY} -b ${BUCKETNAME_APPID} -r ${REGION}
rm -rf /root/webdavserver/webdav_config.yaml
cat >/root/webdavserver/webdav_config.yaml <<EOF
address: 0.0.0.0
port: 8080
auth: true
tls: false
prefix: /

scope: /root/pwdbak
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
scope: /root/pwdbak
modify: true
EOF
cron
cd /root/webdavserver && ./webdav -c /root/webdavserver/webdav_config.yaml
