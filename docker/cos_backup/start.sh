#!/bin/bash
rm -f /root/sync.sh
echo '#!/bin/bash' > /root/sync.sh && echo 'coscmd upload -rs /root/data ${COS_PATH} > /dev/null 2>&1' >> /root/sync.sh
rm -rf ~/.cos.conf && coscmd config -a ${SECRETID} -s ${SECRETKEY} -b ${BUCKETNAME_APPID} -r ${REGION}
cron
bash /root/sync.sh
tail -F /root/runing.txt
