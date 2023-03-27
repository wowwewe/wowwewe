rm -f /root/config_tcp.json
cat > /root/config_tcp.json<<-EOF
{
  "inbound": {
    "port": 8388,
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
    "settings": {}
  }
}
EOF
cd /root
./v2ray run -c /root/config_tcp.json
