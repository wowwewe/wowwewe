# 腾讯云COS-webdav

因为之前使用COSFS实现挂载时发现COS的请求次数过多，每分钟上千次，所以现在改用本地存储数据，cron每小时COSCMD同步到COS一次

使用 -v /xxx/xxx:/root/pwdbak 把数据储存在本地

``` shell
docker run -d --restart=unless-stopped \
--name cosdav \
-e BUCKETNAME_APPID=123 \
-e SECRETID=123id \
-e SECRETKEY=123key \
-e REGION=ap-nanjing \
-e DAV_USER=admin \
-e DAV_PWD=admin \
-p 8080:8080 \
-v /xxx/xxx:/root/pwdbak
wowaqly/cos_webdav
```
## 参数
|名称               |说明                                                   |
|:-                 |:-                                                     |
|BUCKETNAME_APPID |存储桶名称|
|SECRETID | 腾讯云账号密钥ID 建议使用子账号 最小权限|
|SECRETKEY | 腾讯云账号密钥KEY 建议使用子账号 最小权限|
|REGION |地域简称 默认ap-nanjing|
|DAV_USER |webdav的登录名 默认admin|
|DAV_PWD |webdav的登录密码  默认admin|

*参数设置，请参考：<https://cloud.tencent.com/document/product/436/10976>*

## Nginx反代webdav
```shell
location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
    }
 ```
## 感谢

[hacdias/webdav](https://github.com/hacdias/webdav)
