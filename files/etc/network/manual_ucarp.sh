#!/bin/bash
# example:
#   # ucarp-vid-337 337
#   # ucarp-vip-337 10.51.10.178
#   # ucarp-password-337 1310740329289742659
#   # ucarp-advskew-337 2
#   # ucarp-advbase-337 1
#   # ucarp-facility-337 daemon
#   # ucarp-master-337 no
# manual_ucarp.sh no 2 1 daemon 337 10.51.10.178 1310740329289742659 337 eth0

ucarprunning=`ps ax|grep ucarp|grep -v grep|grep $6|wc -l`
if [ $ucarprunning -ne 1 ]; then
	IF_UCARP_MASTER=$1
	IF_UCARP_ADVSKEW=$2
	IF_UCARP_ADVBASE=$3
	IF_UCARP_FACILITY=$4
	IF_UCARP_VID=$5
	IF_UCARP_VIP=$6
	IF_UCARP_PASSWORD=$7
	IF_ALIAS=$8
	IFACE=$9
	MODE=start
	IF_ADDRESS=`/sbin/ifconfig $9 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

	source /etc/network/if-up.d/ucarp
fi
