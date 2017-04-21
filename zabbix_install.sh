#!/bin/bash
##zabbix一键安装
#定义变量
YUMNUM=`yum repolist 2>/dev/null|grep repolist: |sed 's/[^0-9]//g'`
ZABBIXgz=zabbix-2.2.1.tar.gz
ZABBIX=zabbix-2.2.1
phpbcmath=php-bcmath-5.3.3-22.el6.x86_64.rpm
phpmbstring=php-mbstring-5.3.3-22.el6.x86_64.rpm
#定义yum源是否可用脚本
YUMREPO (){
        echo -ne "\033[34m正在检测yum源\033[0m"
        sleep 3
        if [ $YUMNUM -eq 0 ];then
        echo -e "\033[32myum源不可用，请先配置yum源\033[0m"
        exit 10
        else
        echo -e "\033[34myum源检测通过!\033[0m"
        fi
}
#定义菜单
menu (){
           echo "  ##############----一键安装菜单----##############"
           echo "# 1. 安装zabbix 监控端"
           echo "# 2. 安装agent被监控端"
           echo "# 3. 退出 "
           read -p "请输入菜单【1-3】" select
}
yilai_install (){
        echo "----------正在安装依赖包"
        case $select in
        1)
                yum install -y gcc gcc-c++ make mysql-server mysql-devel libcurl-devel net-snmp-devel php php-ldap php-gd php-xml php-mysql php-mbstring php-bcmath httpd fping &>/dev/null
	        ;;
        2)
                yum install -y gcc* &>/dev/null
                ;;
        esac
        echo "----------依赖安装完成"   

}
#定义configure时是否出错
configure_err(){
        if [ $? -ne 0 ];then
        echo "cofigure失败"
        exit 11
        fi
}
#定义make时是否出错
make_err(){
        if [ $? -ne 0 ];then
        echo "make失败"
        exit 12
        fi
}
#定义make install 安装时是否出错
make_install_err(){
        if [ $? -ne 0 ];then
        echo "make install失败"
        exit 13
        fi
}
zabbix_install(){
	YUMREPO
	yilai_install		
	echo "-----------zabbix_server安装中"	
	useradd zabbix -s /sbin/nologin &>/dev/null
	/etc/init.d/mysqld start &>/dev/null
	mysql -e 'create database zabbix character set utf8;'
	mysql -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'"
	ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
	rpm -ivh $phpmbstring  --force --nodeps &>/dev/null
	rpm -ivh $phpbcmath  --force --nodeps	  &>/dev/null
	tar zxf $ZABBIXgz &>/dev/null
	cd $ZABBIX
	./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql --with-net-snmp --with-libcurl  &>/dev/null	
	configure_err
	make install &>/dev/null
	make_install_err
	echo "-----------安装完成"
	sleep 3
	echo "-----------正在导入zabbix数据库"
	mysql zabbix <database/mysql/schema.sql
	mysql zabbix <database/mysql/images.sql
	mysql zabbix <database/mysql/data.sql	
	sed -i '/^DBUser=/s/DBUser=root/DBUser=zabbix/' /usr/local/zabbix/etc/zabbix_server.conf
	sed -i '/^# DBPassword=/s/# DBPassword=/DBPassword=zabbix/' /usr/local/zabbix/etc/zabbix_server.conf
	cp -r frontends/php/ /var/www/html/zabbix
	cp misc/init.d/fedora/core/zabbix_server /etc/init.d/
	cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
	sed -i 's/BASEDIR=\/usr\/local/BASEDIR=\/usr\/local\/zabbix/g' /etc/init.d/zabbix_agentd
	sed -i 's/BASEDIR=\/usr\/local/BASEDIR=\/usr\/local\/zabbix/g' /etc/init.d/zabbix_server
	sed -i '/^;date.timezone/cdate.timezone =Asia/Shanghai' /etc/php.ini		
	sed -i '/^post_max_size/cpost_max_size = 16M' /etc/php.ini
	sed -i '/^max_execution_time/cmax_execution_time = 300' /etc/php.ini
	sed -i '/^max_input_time/cmax_input_time = 300' /etc/php.ini
	chkconfig zabbix_server on
	chkconfig zabbix_agentd on
	chkconfig httpd on
	/etc/init.d/zabbix_server restart   &>/dev/null
	/etc/init.d/zabbix_agentd start	&>/dev/null
	/etc/init.d/httpd start	 &>/dev/null		
	mv /var/www/html/zabbix/fonts/DejaVuSans.ttf /var/www/html/zabbix/fonts/DejaVuSans.ttf.bak	
	cd ..
	cp simsun.ttc  /var/www/html/zabbix/fonts/DejaVuSans.ttf
	/etc/init.d/httpd restart
	echo "你的机器已成功安装zabbix，在初始化时下载并cp到/var/www/html/zabbix/conf/zabbix.conf.php"
	echo "按回车继续"
        read

}
zabbix_agentd_install (){
	YUMREPO
        yilai_install
        echo "-----------zabbix_agentd安装中"   
        useradd zabbix -s /sbin/nologin &>/dev/null	
	tar zxf $ZABBIXgz &>/dev/null
        cd $ZABBIX
        ./configure --prefix=/usr/local/zabbix --enable-agent &>/dev/null
	 configure_err
        make install &>/dev/null
        make_install_err
        echo "-----------安装完成"
	cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
	sed -i 's/BASEDIR=\/usr\/local/BASEDIR=\/usr\/local\/zabbix/g' /etc/init.d/zabbix_agentd
	read -p "请输入监控端ip ：" ipip
	sed -i "81cServer=$ipip" /usr/local/zabbix/etc/zabbix_agentd.conf	
	sed -i "122cServerActive=$ipip" /usr/local/zabbix/etc/zabbix_agentd.conf	
	/etc/init.d/zabbix_agentd start &>/dev/null
	 chkconfig zabbix_agentd on
	echo -e "\033[32m安装完成，按回车继续\033[0m"
	read	
}
while :
do
clear
menu
	case $select in
	1)
		zabbix_install
		;;
	2)
		zabbix_agentd_install
		;;
	3)
		exit 0
		;;				
	4)
		echo "输入有误！"
		echo "按回车继续！"
		read 
		;;
	esac
done


