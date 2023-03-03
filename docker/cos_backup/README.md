# 腾讯云cos-backup
把文件夹加密ZIP后上传到cos。
默认每天备份一次，重启容器立即备份一次，长期使用会在cos中累计存储很多数据，记得定时手动清理cos

``` shell
docker run -d --restart=unless-stopped \
--name cosdav \
-e BUCKETNAME_APPID=123 \
-e SECRETID=123id \
-e SECRETKEY=123key \
-e PASSWORD=123 \
-e PASSWORD_PROMPT=123 \
-e REGION=ap-nanjing \
-v /xxx/xxx:/root/data \
wowaqly/cos_webdav
```
## 参数
|名称               |说明                                                   |
|:-                 |:-                                                     |
|BUCKETNAME_APPID |存储桶名称|
|SECRETID | 腾讯云账号密钥ID 建议使用子账号 最小权限|
|SECRETKEY | 腾讯云账号密钥KEY 建议使用子账号 最小权限|
|REGION |地域简称 默认ap-nanjing|
|PASSWORD |zip加密密码|
|PASSWORD_PROMPT |密码提示|

*参数设置，请参考：<https://cloud.tencent.com/document/product/436/10976>*

