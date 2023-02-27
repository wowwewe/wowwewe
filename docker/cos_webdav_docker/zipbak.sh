cd /root/zipbak
zip -q -r pwd-backup-"$(date +"%Y-%m-%d-%H-%M")" /root/pwdbak
coscmd upload -rs /root/zipbak
rm -f /root/zipbak/*
