FROM debian
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV psk=password
ENV dns=localhost
ENV port=8388


RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    uuid-runtime \
    upx-ucl \
    binutils \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 Xray
ARG XRAY_VER=v26.2.6
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /tmp/xray \
    && strip --strip-all /tmp/xray/xray \
    && upx -9 /tmp/xray/xray -o /usr/local/bin/vm \
    && chmod +x /usr/local/bin/vm \
    && rm -rf /tmp/*

# arm64 
# RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-arm64-v8a.zip \
#    && unzip /tmp/xray.zip -d /tmp/xray \
#    && strip --strip-all /tmp/xray/xray \
#    && upx -9 /tmp/xray/xray -o /usr/local/bin/vm \
#    && chmod +x /usr/local/bin/vm \
#    && rm -rf /tmp/*

# 创建默认目录
RUN mkdir -p /data

# 拷贝 entrypoint 脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh


CMD ["bash","/start.sh"]

