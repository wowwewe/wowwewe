FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble
ENV PUDI 1000
ENV PGID 1000
ENV LC_ALL=zh_CN.UTF-8
ENV APP_VERSION     "v2.0.10.2"
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"
RUN sed -i "s@http://.*archive.ubuntu.com@https://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@https://${APT_SOURCE_HOST}@g" /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl locales && export LANG=zh_CN.UTF-8 && locale-gen zh_CN.UTF-8
RUN sudo apt install fonts-noto-cjk fontconfig -y && sudo dpkg-reconfigure fontconfig-config && sudo fc-cache -f -v
RUN curl https://down.115.com/client/115pc/lin/115_${APP_VERSION}.deb -o /tmp/115_${APP_VERSION}.deb && dpkg -i /tmp/115_${APP_VERSION}.deb && rm -f /tmp/*.deb
COPY /root /
COPY start.sh /config/start.sh


