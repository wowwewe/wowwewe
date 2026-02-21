```shell
docker run -d --name=tj --restart=always -e psk=passwd -e port=8388 -p 8388:8388 -e d=1.1.1.1  -v /configdata:/etc/xray wowaqly/tj
```
```shell
docker run -d --name=tj --restart=always -e psk=passwd -e port=8388 -p 8388:8388 -e d=1.1.1.1  -v /configdata:/etc/xray wowaqly/tj:arm64
```
```shell
docker logs tj
```
check the certificate



ipv6 " -e network=host "
