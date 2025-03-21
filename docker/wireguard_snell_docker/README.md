# 使用wireguard作为出口，提供snell连接，必须要设置docker固定ip
```shell
docker run -d \
  --name=wgsn \
  --cap-add=NET_ADMIN \
  --cap-add=SYS_MODULE \
  -e TZ=Asia/Shanghai \
  --network=proxynetwork \
  --ip=10.1.1.18 \
  -e PSK=password \
  -e DNS=8.8.8.8 \
  -e PORT=port \
  -p port:port \
  -v /docker/wg/wg0.conf:/etc/wireguard/wg0.conf \
  --restart unless-stopped \
  -v /lib/modules:/lib/modules  \
  --sysctl="net.ipv4.conf.all.src_valid_mark=1" \
  wowaqly/wgsn
```
## wireguard conf必须命名为wg0.conf,删除conf中的dns配置行,替换PostUp和PostDown中的ip为docker容器的固定ip
```conf
[Interface]
Address = 
PrivateKey = 
PostUp = ip -4 rule add from 10.1.1.18 lookup main
PostDown = ip -4 rule delete from 10.1.1.18 lookup main
[Peer]
PublicKey = 
AllowedIPs = 0.0.0.0/0
Endpoint = 
```
