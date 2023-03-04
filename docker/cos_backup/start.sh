#!/bin/bash
rm -f /root/sync.sh
cat > /root/sync.sh <<EOF
#!/bin/bash
coscmd upload -rs /root/data ${COS_PATH} > /dev/null 2>&1
EOF
rm -rf ~/.cos.conf && coscmd config -a ${SECRETID} -s ${SECRETKEY} -b ${BUCKETNAME_APPID} -r ${REGION}
chmod +x /root/sync.sh
cron
bash /root/sync.sh
tail -F /root/runing.txt
