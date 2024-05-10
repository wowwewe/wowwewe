# /bin/bash
cd /root 
./sd -s "[::]:8388" -m "${METHOD}" -k "${PASSWORD}" -U --timeout "120" --udp-timeout "120" --dns "${DNS}:53"
