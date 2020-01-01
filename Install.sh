#!/bin/bash
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }
function Colorset() {
  #顏色配置
  echo=echo
  for cmd in echo /bin/echo; do
    $cmd >/dev/null 2>&1 || continue
    if ! $cmd -e "" | grep -qE '^-e'; then
      echo=$cmd
      break
    fi
  done
  CSI=$($echo -e "\033[")
  CEND="${CSI}0m"
  CDGREEN="${CSI}32m"
  CRED="${CSI}1;31m"
  CGREEN="${CSI}1;32m"
  CYELLOW="${CSI}1;33m"
  CBLUE="${CSI}1;34m"
  CMAGENTA="${CSI}1;35m"
  CCYAN="${CSI}1;36m"
  CSUCCESS="$CDGREEN"
  CFAILURE="$CRED"
  CQUESTION="$CMAGENTA"
  CWARNING="$CYELLOW"
  CMSG="$CCYAN"
}

function Logprefix() {
  #輸出log
  echo -n 'WitMantoBot >> '
}

system_setting(){
clear
Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Setting DNS!'
 > /etc/resolv.conf
echo "nameserver 168.95.192.1">>/etc/resolv.conf
echo "nameserver 8.8.8.8">>/etc/resolv.conf
echo "nameserver 1.1.1.1">>/etc/resolv.conf
chattr +i /etc/resolv.conf
Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install wget, git!'
yum -y install git wget
Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install Development Tools'
yum -y groupinstall "Development Tools"
Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' System setting complete!'
}
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
	Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' libsodium inatall complete!'
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install python-setuptools, pip!'
	yum -y install python-setuptools && easy_install pip
	Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' python-setuptools, pip inatall complete!'
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install python-devel, libffi-devel, openssl-devel!'
	yum install python-devel libffi-devel openssl-devel -y
	Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' python-devel, libffi-devel, openssl-devel inatall complete!'
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Clone shadowsocksr!'
  	git clone -b master https://github.com/BrownRhined/SSRInstallScript.git && mv SSRInstallScript shadowsocksr && cd shadowsocksr && chmod +x ./initcfg.sh && ./initcfg.sh
  	Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' Shadowsocksr clone complete!'
	#pip install shadowsocks
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install urllib3==1.20!'
	pip install urllib3==1.20
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install cymysql==0.8.9!'
	pip install cymysql==0.8.9
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install requests==2.13.0!'
	pip install requests==2.13.0
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install pyOpenSSL==17.5.0!'
	pip install pyOpenSSL==17.5.0
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install ndg-httpsclient==0.4.2!'
	pip install ndg-httpsclient==0.4.2
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Install pyasn1==0.2.2!'
	pip install pyasn1==0.2.2
	#pip install requests==2.9
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' IPv4 over IPv6 !'
	echo "precedence ::ffff:0:0/96 100">>/etc/gai.conf
	
	rm -rf Install.sh
	cd /root/
	iptables -I INPUT -p tcp -m tcp --dport 0-65535 -j ACCEPT
	iptables -I INPUT -p udp -m udp --dport 0-65535 -j ACCEPT
	iptables-save
	service iptables reload
	service iptables stop
	service firewalld stop
	systemctl stop firewalld.service
	systemctl disable firewalld.service
	chkconfig iptables off
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Stop iptables、firewalld!'
	Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' SSR inatall complete!'
}

install_supervisord(){
	clear
	cd /root/
	rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm --quiet
	yum install supervisor python-pip -y
	pip install supervisor==3.1
	chkconfig supervisord on
	wget https://github.com/glzjin/ssshell-jar/raw/master/supervisord.conf -O /etc/supervisord.conf
	wget https://github.com/glzjin/ssshell-jar/raw/master/supervisord -O /etc/init.d/supervisord
	Logprefix;echo ${CYELLOW}'[INFO]'${CEND}' Setting supervisord!'
echo "[program:ssr]
command=python /root/shadowsocksr/server.py 
autorestart=true
autostart=true
user=root" > /etc/supervisord.conf
echo "ulimit -n 1024000" >> /etc/init.d/supervisord
service supervisord restart
Logprefix;echo ${CGREEN}'[SUCCESS]'${CEND}' supervisord inatall complete!'
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
	echo 'setting every day restart SSR node'
	stty erase '^H' && read -p " hour(0-23):" hour
	stty erase '^H' && read -p " minute(0-59):" minute
	chmod +x /etc/rc.d/rc.local
	echo /sbin/service crond start >> /etc/rc.d/rc.local
	echo "/root/shadowsocksr/run.sh" >> /etc/rc.d/rc.local
	echo 'setting power on run SSR'
	echo "$minute $hour * * * root /sbin/reboot" >> /etc/crontab
	service crond start
}
 AliYunServicesClear(){
	clear
	cd
	bash -c "$(curl -sS https://raw.githubusercontent.com/BrownRhined/AliYunServicesClear/master/uninstall.sh)"
}

Colorset
echo ' Note: This script is written based on centos7, other systems may have problems'
echo ' 1. System setting'
echo ' 2. Install SSR'
echo ' 3. Install BBR'
echo ' 4. Install Supervisord'
echo ' 5. Set scheduled restart'
echo ' 6. AliYunServicesClear'
stty erase '^H' && read -p " Please Input Number [1-6]:" num
case "$num" in
	1)
	system_setting
	;;
	2)
	install_ssr
	;;
	3)
	open_bbr
	;;
	4)
	install_supervisord
	;;
	5)
	auto_reboot
	;;
	6)
	AliYunServicesClear
	;;
	*)
	echo 'Please Input Number[1-6]'
	;;
esac
