```shell
docker run -d --name=ss --restart=always -e port=8388 -p 8388:8388 -e 8388:8388/udp -e dns=1.1.1.1  -v /configdata:/data wowaqly/ss
```
```shell
docker run -d --name=ss --restart=always -e port=8388 -p 8388:8388 -e 8388:8388/udp -e dns=1.1.1.1  -v /configdata:/data wowaqly/ss:arm64
```
```shell
docker logs ss
```
check the certificate



ipv6 " -e network=host "
