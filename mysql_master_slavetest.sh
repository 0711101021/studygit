#!/bin/bash

DBuser=root
DBpasswd=123456
Mail="wang@163.com"

Result=/tmp/mysql.txt

State=`netstat -lnpt|grep 3306`
if [-z "$Result"]
	then
		echo "Can't connect to Mysql database" 
	else
		mysql -u$DBuser -p$DBpasswd -e "show slave status\G" >$Result 2>/dev/null
	Slave_IO_Running=`grep -i slave_io_running $Result | cut -d : -f 2`
	Slave_SQL_Running=`grep -i slave_sql_running $Result |cut -d : -f 2`
	if ["$Slave_IO_Running" != 'Yes' -o "$Slave_SQL_Running" != 'Yes'] then
		echo "Mysql replication has stopped"
	fi
fi
