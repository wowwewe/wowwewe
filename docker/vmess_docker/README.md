只支持最基本的vmess-tcp,默认开启AEAD

PASSWORD 必须为 UUID格式

DNS 可以是 1.1.1.1 或者 https://1.1.1.1/dns-query 或者 https+local://dns.google/dns-query 注意 第三种需要+local否则无法解析doh的域名

```shell
docker run -d --restart=always -p 1111:8388 -e PASSWORD=uuid -e DNS=localhost --name vmess wowaqly/vmess
```
