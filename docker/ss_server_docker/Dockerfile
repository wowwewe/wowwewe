FROM ubuntu:22.04
MAINTAINER wowaqly
ENV APP_VERSION=1.18.3
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV PASSWROD=password
ENV DNS=223.5.5.5
ENV METHOD=aes-256-gcm
COPY start.sh /root/start.sh

RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install wget xz-utils -y
RUN mkdir /root/ss && cd /root/ss && wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v${APP_VERSION}/shadowsocks-v${APP_VERSION}.x86_64-unknown-linux-gnu.tar.xz && tar -xf shadowsocks-v${APP_VERSION}.x86_64-unknown-linux-gnu.tar.xz && cp ssserver /root && cd /root && rm -rf /root/ss 
RUN cd /root && mv ssserver sd
CMD bash /root/start.sh
