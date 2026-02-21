```bash
docker run -d --name=wgxr   \
-v /wgxr:/etc/xray  \
-e tlshost=偷证书的域名 \    
-e privatekey=privatekey \     
-e wgip=10.1.1.2 \
-e publickey=publickey \
-e wgserver=1.1.1.1:51820 \
 --network=host  \
 wowaqly/wgxr
```
 
 默认端口443，偷证书的域名需tls1.3+443端口，wgip是wireguard的内网ip不要输入子网段（/16 /32 这种）
 docker logs 查看配置信息
