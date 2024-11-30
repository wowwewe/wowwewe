FROM linuxserver/wireguard:latest
ENV TZ=Asia/Shanghai
RUN apk update && apk add tar wget && cd /root && wget https://github.com/go-gost/gost/releases/download/v3.0.0-nightly.20241122/gost_3.0.0-nightly.20241122_linux_amd64.tar.gz && tar -zxvf gost_3.0.0-nightly.20241122_linux_amd64.tar.gz && rm gost_3.0.0-nightly.20241122_linux_amd64.tar.gz
CMD cd /root && ./gost -C /root/gost.yaml

