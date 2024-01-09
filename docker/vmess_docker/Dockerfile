FROM ubuntu:22.04
MAINTAINER wowaqly
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV PASSWORD=password
ENV DNS=127.0.0.1
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ENV VMESS_REV "v5.12.1"
COPY startapp.sh /root/clash/startapp.sh
RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install unzip wget -y
RUN cd /root && wget https://github.wewe.uk/v2fly/v2ray-core/releases/download/${VMESS_REV}/v2ray-linux-64.zip && unzip v2ray-linux-64.zip && rm v2ray-linux-64.zip
CMD bash /root/clash/startapp.sh
