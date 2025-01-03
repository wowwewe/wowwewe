# docker连接wireguard组网并且利用gost将端口转发出来
一般配置network以获得固定ip方便管理使用  

wireguard的配置文件放/xxx/xxx，例如/xxx/xxx/wg1.conf  
gost的配置文件放/xxx/xxx,例如/xxx/xxx/gost.yaml
```
docker run -d \
  --name=wg-gost \
  --cap-add=NET_ADMIN \
  -e TZ=Asia/Shanghai \
  --network=xxx \
  --ip=xxx.xxx.xxx.xxx \
  -v /xxx/xxx/gost.yaml:/root/gost.yaml \
  -v /xxx/xxx:/config \
  --restart unless-stopped \
  wowaqly/wg-gost
```

gost.yaml示例 更多示例参考 https://gost.run
```
services:
- name: ssh
  addr: 0.0.0.0:22
  handler:
    type: tcp
  listener:
    type: tcp
  forwarder:
    nodes:
    - name: ssh
      addr: 远端服务器wireguard内网ip:22
```