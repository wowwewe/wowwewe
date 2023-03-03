if [ ! -d '/root/backup' ]
then
    mkdir -p '/root/backup'
fi
cd /root/backup
zip -q -r -P $PASSWORD backup-"$(date +"%Y-%m-%d-%H-%M")"-"$PASSWORD_PROMPT".zip /root/data
coscmd upload -rs /root/backup / > /dev/null 2>&1
rm -f /root/backup/*
