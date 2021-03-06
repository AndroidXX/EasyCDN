#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Install Nginx via Oneinstack(https://github.com/lj2007331/oneinstack)
cd /root
wget https://github.com/lj2007331/oneinstack/archive/V1.4.tar.gz && tar -xf V1.4.tar.gz && cd oneinstack-1.4/
#wget http://mirrors.linuxeye.com/oneinstack.tar.gz && tar -xf oneinstack.tar.gz && cd oneinstack/
#rm -rf install.sh && wget http://download.ipatrick.cn/ghost/install.sh && chmod +x install.sh
#./install.sh


# get pwd
sed -i "s@^oneinstack_dir.*@oneinstack_dir=`pwd`@" ./options.conf

. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

mkdir -p $wwwroot_dir/default $wwwlogs_dir
[ -d /data ] && chmod 755 /data


# get the IP information
IPADDR=`./include/get_ipaddr.py`
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY_ISP=`./include/get_ipaddr_state.py $PUBLIC_IPADDR`
IPADDR_COUNTRY=`echo $IPADDR_COUNTRY_ISP | awk '{print $1}'`
[ "`echo $IPADDR_COUNTRY_ISP | awk '{print $2}'`"x == '1000323'x ] && IPADDR_ISP=aliyun

# check download src
. ./include/check_download.sh
checkDownload 2>&1 | tee $oneinstack_dir/install.log

# init
. ./include/memory.sh
if [ "$OS" == 'CentOS' ];then
    . include/init_CentOS.sh 2>&1 | tee -a $oneinstack_dir/install.log
    [ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ] && export CC="gcc44" CXX="g++44"
elif [ "$OS" == 'Debian' ];then
    . include/init_Debian.sh 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$OS" == 'Ubuntu' ];then
    . include/init_Ubuntu.sh 2>&1 | tee -a $oneinstack_dir/install.log
fi



    . include/nginx.sh
    Install_Nginx 2>&1 | tee -a $oneinstack_dir/install.log

# index example
    . include/demo.sh
    DEMO 2>&1 | tee -a $oneinstack_dir/install.log


mkdir /usr/local/nginx/conf/vhost/
cd /root

#Clean useless things.
#rm -rf /root/oneinstack
#rm -rf /root/oneinstack.tar.gz
rm -rf /root/oneinstack-1.4
rm -rf /root/V1.4.tar.gz
