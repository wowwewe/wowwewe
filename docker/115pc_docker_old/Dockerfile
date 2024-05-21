FROM jlesage/baseimage-gui:ubuntu-22.04
MAINTAINER wowaqly
ENV APP_NAME        "115pc"
ENV APP_VERSION     "V2.0.10.2"
ENV USER_ID         0
ENV GROUP_ID        0
ENV ENABLE_CJK_FONT 1
ENV DISPLAY_WIDTH   "1920"
ENV DISPLAY_HEIGHT  "1080"
ENV APT_SOURCE_HOST "mirrors.huaweicloud.com"

RUN sed -i "s@http://.*archive.ubuntu.com@https://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && sed -i "s@http://.*security.ubuntu.com@https://${APT_SOURCE_HOST}@g" /etc/apt/sources.list && apt-get update && apt-get upgrade -y && apt-get install -y curl locales && export LANG=zh_CN.UTF-8 && locale-gen zh_CN.UTF-8
RUN curl https://down.115.com/client/115pc/lin/115_${APP_VERSION}.deb -o /tmp/115_${APP_VERSION}.deb && dpkg -i /tmp/115_${APP_VERSION}.deb && rm -f /tmp/*.deb

COPY startapp.sh /startapp.sh
