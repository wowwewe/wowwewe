# 腾讯云COS存储桶-webdav

``` shell
docker run -d --privileged \
--name cosdav \
-e BUCKETNAME_APPID=123 \
-e SECRETID=123id \
-e SECRETKEY=123key \
-e REGION=ap-nanjing \
-e DAV_USER=admin \
-e DAV_PWD=admin \
-p 8080:8080 \
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

*参数设置，请参考：<https://cloud.tencent.com/document/product/436/6883>*

## 感谢

[COSFS](https://cloud.tencent.com/document/product/436/6883)

[hacdias/webdav](https://github.com/hacdias/webdav)
