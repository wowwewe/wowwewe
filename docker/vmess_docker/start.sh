rm -f /root/config.json
cat > /root/config.json <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "::0",
      "port": ${PORT},
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${UUID}"
          }
        ]
      },
     "dns":
        {
         "servers": ["${DNS}"]
        }
    }
  ],
  
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {
        "domainStrategy": "UseIP" 
      }
     },
    {
      "tag": "block",
      "protocol": "blackhole",
      "response": {
       "type": "none"
      }
     }
  ]
}
EOF
cd /root && ./xray -c /root/config.json
