FROM ubuntu
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV PSK=password
ENV DNS=127.0.0.1
ENV PORT=8388
COPY start.sh /root/start.sh


RUN apt-get update && apt-get install wget unzip -y
RUN apt --fix-broken install wireguard -y
RUN apt install iproute2 -y

RUN wget https://dl.nssurge.com/snell/snell-server-v5.0.1-linux-amd64.zip && unzip snell-server-v5.0.1-linux-amd64.zip && rm snell-server-v5.0.1-linux-amd64.zip && cp snell-server /root && rm snell-server


CMD ["bash","/root/start.sh"]
