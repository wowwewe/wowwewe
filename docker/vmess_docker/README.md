只支持最基本的vmess-tcp,默认开启AEAD

PASSWORD 必须为 UUID格式

```shell
docker run -d --restart=always -p 1111:8388 -e PASSWORD=uuid --name vmess wowaqly/vmess
```