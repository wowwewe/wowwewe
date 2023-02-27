#!/bin/bash
service cron start && service cron reload && service cron restart
cd /root/webdavserver && ./webdav -c /root/webdavserver/webdav_config.yaml
