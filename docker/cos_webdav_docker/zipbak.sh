if [ ! -d '/root/zipbak' ]
then
    mkdir -p '/root/zipbak'
fi
cd /root/zipbak
zip -q -r pwd-backup-"$(date +"%Y-%m-%d-%H-%M")" /root/data
coscmd upload -rs /root/zipbak > /dev/null 2>&1
rm -f /root/zipbak/*
