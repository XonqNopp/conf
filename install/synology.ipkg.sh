#!/bin/sh
mkdir /opt
cd /opt
feed=http://ipkg.nslu2-linux.org/feeds/optware/cs08q1armel/cross/unstable
echo " feed=$feed"
ipk_name=`wget -qO- $feed/Packages | awk '/^Filename: ipkg-opt/ {print $2}'`
echo " ipk_name=$ipk_name"
wget $feed/$ipk_name
tar -xOvzf $ipk_name ./data.tar.gz | tar -C / -xzvf -
mkdir -p /opt/etc/ipkg
echo "src cross $feed" > /opt/etc/ipkg/feeds.conf
rm -v $feed/$ipk_name
vi /root/.profile
wget http://ipkg.nslu2-linux.org/feeds/optware/cs08q1armel/cross/unstable/wget_1.12-2_arm.ipk
ipkg install wget_1.12-2_arm.ipk
rm -v wget_1.12-2_arm.ipk
ipkg update
#ipkg install vim bash python python3 python27 openssl

## not done
#mkdir /volume1/@optware
#mkdir /opt
#mount -o bind /volume1/@optware /opt

## Source: https://github.com/trepmag/ds213j-optware-bootstrap
