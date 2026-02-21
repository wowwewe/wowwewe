FROM debian
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV psk=password
ENV dns=localhost
ENV port=8388
COPY start.sh /root/start.sh


RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    uuid-runtime \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 Xray
ARG XRAY_VER=v26.2.6
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip
#arm64
#RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-arm64-v8a.zip \
#    && unzip /tmp/xray.zip -d /usr/local/bin/ \
#    && chmod +x /usr/local/bin/xray \
#    && rm /tmp/xray.zip
    

# 创建默认目录
RUN mkdir -p /etc/xray

# 拷贝 entrypoint 脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 默认监听端口
EXPOSE 8388

CMD ["bash","/root/start.sh"]

