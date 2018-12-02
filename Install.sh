#!/bin/bash
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
install_ssr(){
	clear
	cd /root/
  	wget https://github.com/jedisct1/libsodium/releases/download/1.0.16/libsodium-1.0.16.tar.gz
  	tar xf libsodium-1.0.16.tar.gz && cd libsodium-1.0.16
  	./configure && make -j2 && make install
  	echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
  	ldconfig
  	cd /root/
  	rm -rf libsodium-1.0.16.tar.gz
	echo 'libsodium inatall complete!'
	yum -y install python-setuptools && easy_install pip
	yum install python-devel libffi-devel openssl-devel -y
  	git clone -b master https://github.com/BrownRhined/SSRInstallScript.git && mv SSRInstallScript shadowsocksr && cd shadowsocksr && chmod +x ./initcfg.sh && ./initcfg.sh
	#pip install shadowsocks
	pip install urllib3==1.20
	pip install cymysql==0.8.9
	pip install requests==2.13.0
	pip install pyOpenSSL==17.5.0
	pip install ndg-httpsclient==0.4.2
	pip install pyasn1==0.2.2
	pip install requests==2.9
	
	rm -rf Install.sh
	echo 'ssr inatall complete!'
	cd /root/
	service iptables stop
	service firewalld stop
	systemctl disable firewalld.service
	systemctl stop firewalld.service
	chkconfig iptables off
	echo '已关闭iptables、firewalld，如有需要请自行配置。'
}

open_bbr(){
	clear
	cd
	wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
	chmod +x bbr.sh
	./bbr.sh
}

auto_reboot(){
	clear
	echo '设置每天几点几分重启节点'
	stty erase '^H' && read -p " 小时(0-23):" hour
	stty erase '^H' && read -p " 分钟(0-59):" minute
	chmod +x /etc/rc.d/rc.local
	echo /sbin/service crond start >> /etc/rc.d/rc.local
	echo "/root/shadowsocksr/run.sh" >> /etc/rc.d/rc.local
	echo '设置开机运行SSR'
	echo "$minute $hour * * * root /sbin/reboot" >> /etc/crontab
	service crond start
}

yum -y install git wget
yum -y groupinstall "Development Tools"
clear
echo ' 注意：此脚本基于centos7编写，其他系统可能会出问题'
echo ' 1. Install SSR'
echo ' 2. Install BBR'
echo ' 3. 设置定时重启（测试中）'
stty erase '^H' && read -p " Please Input Number [1-3]:" num
case "$num" in
	1)
	install_ssr
	;;
	2)
	open_bbr
	;;
	3)
	auto_reboot
	;;
	*)
	echo 'Please Input Number[1-3]'
	;;
esac
