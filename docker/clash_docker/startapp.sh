#!/bin/sh
if [ ! -d '/root/clash/config' ]
then
    mkdir -p '/root/clash/config'
    chmod a+w '/root/clash/config'
else
    echo "Path/root/clash/config is Read"
fi
cd /root/clash/config
rm -f /root/clash/config/Country.mmdb
#wget https://cdn.jsdelivr.net/gh/Loyalsoldier/geoip@release/Country-only-cn-private.mmdb
wget https://raw.githubusercontent.com/Loyalsoldier/geoip/release/Country-only-cn-private.mmdb
mv Country-only-cn-private.mmdb Country.mmdb
cd /root/clash
nginx
./clash-linux-amd64 -d /root/clash/config
