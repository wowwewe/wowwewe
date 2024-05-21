#!/bin/sh
echo [General] > /tmp/setting
echo download_path=/Downloads/115download       >> /tmp/setting
echo download_speed=0                           >> /tmp/setting
echo download_tasks=5                           >> /tmp/setting
echo last_download_path=/Downloads/115download/ >> /tmp/setting
echo upload_tasks=5                             >> /tmp/setting


if [ ! -d '/Downloads/115download' ]
then
    mkdir -p '/Downloads/115download'
    chmod a+w '/Downloads/115download'
else
    echo "Path /Downloads/115download is Ready!"
fi
if [ ! -d '/config/xdg/data/115/User Data' ]
then
    mkdir -p '/config/xdg/data/115/User Data'
    chmod a+w '/config/xdg/data/115/User Data'
else
    echo "Path /config/xdg/data/115/User Data is Ready!"
fi
cp -f /tmp/setting "/config/xdg/data/115/User Data/setting"
export LC_ALL=zh_CN.UTF-8
exec /usr/local/115/115
