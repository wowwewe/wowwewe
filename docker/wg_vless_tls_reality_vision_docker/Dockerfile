# 基于 Debian 精简版
FROM debian
ENV TZ=Asia/Shanghai
ENV tlshost=test
ENV privatekey=test
ENV wgip=test
ENV publickey=test
ENV wgserver=test
# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    unzip \
    uuid-runtime \
    && rm -rf /var/lib/apt/lists/*
# 设置环境变量
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

# 安装 tzdata 并配置时区
RUN apt-get update && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# 下载并安装 Xray
ARG XRAY_VER=v26.2.6
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip

# 创建默认目录
RUN mkdir -p /etc/xray

# 拷贝 entrypoint 脚本
COPY start.sh /start.sh
RUN chmod +x /start.sh


ENTRYPOINT ["/start.sh"]
