#!/bin/bash

declare -A cmd

cmd=([-add]=1, [-del]=1)

help_you() {
	echo "#usage: 
    command :
        -add   #add a batch of virtual apdater
               such as: -add eth 100
	
        -del   #delete all virtual apdater
               such as: -del eth 100

        --help or -h  #get help for use"
}

[ -z ${cmd[$1]} ] && {
	echo "001"
	help_you
	exit -1
}

ether_name=$2
ether_num=$3

check_int(){
        expr $1 + 0 &>/dev/null
        [ $? -ne 0 ] && help_you && exit -1
}

check_int $3

echo "ether name : $ether_name"
echo "eth_number : $ether_num"


add() {
	local ether_name=$1
	local ip=$2
	local mask=$3
	tunctl -t $ether_name	
	ifconfig $ether_name $ip netmask $mask
}

delete() {
	local ether_name=$1
	tunctl -d $ether_name
}

[[ $1 == "-add" ]] && {
	i=0
	upper=1
	lower=1
	while (($i<=$ether_num))
	do
		echo "$i"
		mask=255.255.0.0
		ip=172.16.$upper.$lower

		add $ether_name$i $ip $mask

		#tunctl -t $ether_name$i
		#ifconfig $ether_name$i 172.16.$upper.$lower netmask 255.255.0.0
		
		((lower=lower+1))
		[ $lower -ge 253 ] && {
			((lower=1))
			((upper=upper+1))
		}

		[ $upper -ge 255 ] && exit 0

		((i=i+1))
	done
} && exit  0

[[ $1 == '-del' ]] && {
	i=0
	echo "deleting"
	while (($i <= $ether_num))
	do
		delete $ether_name$i
		#tunctl -d $ether_name$i
		((i=i+1))	
	done
} && exit 0
