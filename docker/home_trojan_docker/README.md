```shell
docker run -d --name=tj --restart=always -e port=8388 -p 8388:8388 -e dns=1.1.1.1  -v /configdata:/data wowaqly/tj
```
```shell
docker run -d --name=tj --restart=always -e port=8388 -p 8388:8388 -e dns=1.1.1.1  -v /configdata:/data wowaqly/tj:arm64
```
```shell
docker logs tj
```
check the certificate



ipv6 " -e network=host "
