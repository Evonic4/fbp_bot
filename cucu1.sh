#!/bin/bash

ftb=/usr/share/fbp_bot/
fPID=$ftb"cu1_pid.txt"

Z1=$1

if ! [ -f $fPID ]; then	
	PID=$$
	echo $PID > $fPID
	ssec=5
	token=$(sed -n 1"p" $ftb"sett.conf" | tr -d '\r')
	proxy=$(sed -n 3"p" $ftb"sett.conf" | tr -d '\r')
	ssec=4
	
	! [ -z "$Z1" ] && Z1="?offset="$Z1
	if [ -z "$proxy" ]; then
		curl -k -s -L -m $ssec https://api.telegram.org/bot$token/getUpdates$Z1 1>$ftb"in0.txt" 2>$ftb"in0_err.txt"
	else
		curl -k -s -m $ssec --proxy $proxy -L https://api.telegram.org/bot$token/getUpdates$Z1 1>$ftb"in0.txt" 2>$ftb"in0_err.txt"
	fi
	
	mv $ftb"in0.txt" $ftb"in.txt"
	mv $ftb"in0_err.txt" $ftb"in_err.txt"

fi
rm -f $fPID
