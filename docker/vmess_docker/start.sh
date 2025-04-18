rm -f /root/config.json
cat > /root/config.json <<EOF
{
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
      "protocol": "freedom"
    }
  ]
}
EOF
cd /root && ./xray -c /root/config.json
