```bash
docker run -d --restart=always --name=xr -p 80:80 -p 443:443 -v /xxxx/xr:/data -e domain=你的域名 -e privatekey=privatekey -e wgip=10.1.1.2 -e publickey=publickey -e wgserver=1.1.1.1:51820  wowaqly/xr
```
默认端口443
需要自己的域名
wgip是wireguard的内网ip不要输入子网段（/16 /32 这种）
 docker logs 查看配置信息
