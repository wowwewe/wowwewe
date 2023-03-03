#!/bin/bash
rm -rf ~/.cos.conf && coscmd config -a ${SECRETID} -s ${SECRETKEY} -b ${BUCKETNAME_APPID} -r ${REGION}
cron
bash /root/zipbak.sh
