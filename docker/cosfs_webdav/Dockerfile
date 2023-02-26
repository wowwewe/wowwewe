FROM ubuntu:20.04
MAINTAINER wowaqly
ENV COSFS_REV "1.0.20"
ENV WEBDAV_REV "4.2.0"
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

ENV BUCKETNAME_APPID=123
ENV SECRETID=123
ENV SECRETKEY=123
ENV REGION=ap-nanjing
ENV DAV_USER=admin
ENV DAV_PWD=admin

RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install wget automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config fuse fuse libfuse2 -y
RUN wget https://github.com/tencentyun/cosfs/releases/download/v${COSFS_REV}/cosfs_${COSFS_REV}-ubuntu20.04_amd64.deb && dpkg -i cosfs_${COSFS_REV}-ubuntu20.04_amd64.deb && rm -f cosfs_${COSFS_REV}-ubuntu20.04_amd64.deb
RUN mkdir /root/webdavserver && cd /root/webdavserver  && wget https://github.com/hacdias/webdav/releases/download/v${WEBDAV_REV}/linux-amd64-webdav.tar.gz && tar -zxvf linux-amd64-webdav.tar.gz && rm -f /root/webdavserver/linux-amd64-webdav.tar.gz
COPY start.sh /root/start.sh

CMD bash /root/start.sh && rm -rf /etc/passwd-cosfs && echo ${BUCKETNAME_APPID}:${SECRETID}:${SECRETKEY} > /etc/passwd-cosfs && chmod 640 /etc/passwd-cosfs && cosfs ${BUCKETNAME_APPID} /mnt/cos -ourl=http://cos.${REGION}.myqcloud.com -odbglevel=crit -onoxattr -oallow_other && cd /root/webdavserver && ./webdav -c /root/webdavserver/webdav_config.yaml
