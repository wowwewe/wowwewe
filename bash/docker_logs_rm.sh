#!/bin/sh 
echo "======== docker containers logs file list ========"

logs=$(find /var/lib/docker/containers/ -name *-json.log)

for log in $logs

do

ls -lh $log

done
sleep 1s

echo "======== start clean docker containers logs ========"  

logs=$(find /var/lib/docker/containers/ -name *-json.log)  

for log in $logs  
        do  
                echo "clean logs : $log"  
                cat /dev/null > $log  
        done  

echo "======== end clean docker containers logs ========"  
