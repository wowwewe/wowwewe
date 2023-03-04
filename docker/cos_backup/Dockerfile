FROM ubuntu:22.04
MAINTAINER wowaqly
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
VOLUME ["/root/data"]
ENV BUCKETNAME_APPID=123
ENV SECRETID=123
ENV SECRETKEY=123
ENV REGION=ap-nanjing


COPY start.sh /root/start.sh
COPY sync.sh /root/sync.sh
RUN sed -i "s@http://.*archive.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@http://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update  && apt-get upgrade -y && apt-get install pip cron zip -y
RUN pip install coscmd -i https://repo.huaweicloud.com/repository/pypi/simple --trusted-host repo.huaweicloud.com
RUN chmod +x /root/*.sh && mkdir -p /root/data && echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' >> /etc/crontab && echo '*/10 * * * * root bash /root/sync.sh'  >> /etc/crontab && echo 'Runing' >> /root/runing.txt

CMD bash /root/start.sh
