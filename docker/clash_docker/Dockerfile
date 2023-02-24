FROM ubuntu:22.04
MAINTAINER wowaqly
ENV CLASH_REV "2023.02.16"
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install nginx unzip wget gzip -y
RUN mkdir -p /root/clash && cd /root/clash && wget https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-${CLASH_REV}.gz && gzip -d clash-linux-amd64-${CLASH_REV}.gz && mv clash-linux-amd64-${CLASH_REV} clash-linux-amd64 && chmod +x clash-linux-amd64 && rm -rf /var/www/html/* && cd /var/www/html && wget https://github.com/Dreamacro/clash-dashboard/archive/refs/heads/gh-pages.zip && unzip gh-pages.zip && rm -f gh-pages.zip && /var/www/html/clash-dashboard-gh-pages && cp * /var/www/html && rm -rf /var/www/html/clash-dashboard-gh-pages 

COPY startapp.sh /root/clash/startapp.sh

CMD bash /root/clash/startapp.sh
