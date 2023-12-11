rm -f /root/sn.conf
cat > /root/sn.conf <<EOF
{
[snell-server]
listen = 0.0.0.0:8388
psk = ${PSK}
ipv6 = true
obfs = off
}
EOF
cd /root && ./sn -c /root/sn.conf
