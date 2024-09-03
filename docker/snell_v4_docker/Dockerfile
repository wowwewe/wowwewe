FROM ubuntu:22.04
MAINTAINER wowaqly
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV PSK=password
ENV DNS=127.0.0.1
COPY start.sh /root/start.sh


RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install wget vim unzip -y

RUN wget https://dl.nssurge.com/snell/snell-server-v4.1.0-linux-amd64.zip && unzip snell-server-v4.1.0-linux-amd64.zip && rm snell-server-v4.1.0-linux-amd64.zip && cp snell-server /root && rm snell-server


CMD bash /root/start.sh

