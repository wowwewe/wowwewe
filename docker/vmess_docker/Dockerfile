FROM ubuntu
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV UUID=password
ENV DNS=127.0.0.1
ENV PORT=8388
COPY start.sh /root/start.sh


RUN apt-get update && apt-get install wget unzip -y

RUN cd /root && wget https://github.com/XTLS/Xray-core/releases/download/v25.3.31/Xray-linux-64.zip && unzip Xray-linux-64.zip && rm -f Xray-linux-64.zip

CMD ["bash","/root/start.sh"]
