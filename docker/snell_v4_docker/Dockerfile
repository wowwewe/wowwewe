FROM ubuntu:22.04
MAINTAINER wowaqly
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV PSK=password
COPY start.sh /root/start.sh


RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install wget vim unzip upx-ucl -y

RUN wget https://dl.nssurge.com/snell/snell-server-v4.0.1-linux-amd64.zip && unzip snell-server-v4.0.1-linux-amd64.zip && rm snell-server-v4.0.1-linux-amd64.zip && upx -9 -o sn snell-server cp sn /root && rm snell-server && rm sn


CMD bash /root/start.sh

