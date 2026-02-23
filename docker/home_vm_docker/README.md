```shell
docker run -d --name=vm --restart=always -e psk=passwd -e port=8388 -p 8388:8388 -e dns=1.1.1.1  wowaqly/vm
```
```shell
docker run -d --name=vm --restart=always -e psk=passwd -e port=8388 -p 8388:8388 -e dns=1.1.1.1  wowaqly/vm:arm64
```
```shell
docker logs vm
```
check the certificate



ipv6 " -e network=host "
