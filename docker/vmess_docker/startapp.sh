rm -f /root/config_tcp.json
cat > /root/config_tcp.json<<-EOF
{
  "inbound": {
    "port": $PORT,
    "listen":"0.0.0.0",
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$PASSWORD",
          "alterId": 0
        }
      ]
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
    "servers": ["$DNS"]
  }
}
EOF
cd /root
./v2ray run -c /root/config_tcp.json
