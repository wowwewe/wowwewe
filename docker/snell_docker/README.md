```shell
docker run -d -e PSK=password -e DNS=1.1.1.1 -e PORT=8388 -p 1231:8388 --name=snv5 --restart=always wowaqly/snv5
```
```shell
docker run -d -e PSK=password -e DNS=1.1.1.1 -e PORT=8388 -p 1231:8388 --name=snv5 --restart=always wowaqly/snv5:arm64
```
ipv6 " -e network=host "
