#!/bin/bash
LOG_PATH=/usr/local/nginx/logs

Yesterday=`date -d "yesterday" +%Y-%m-%d`
mv ${LOG_PATH}/access.log ${LOG_PATH}/access_${Yesterday}.log

kill -USR1 $(cat /usr/local/nginx/nginx.pid) 
#重新加载服务

