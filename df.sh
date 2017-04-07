#!/bin/bash
cd /root/myshell
today=`date +"%Y-%m-%d"`
touch $today.txt
df -h >$today.txt
