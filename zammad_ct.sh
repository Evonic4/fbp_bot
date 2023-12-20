#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

#переменные
fhome=/usr/share/fbp_bot/
fhsender1=$fhome"zammad/"
fhsender2=$fhome"zammad_old/"
fPID=$fhome"zammad_ct_pid.txt"
log=$fhome"zammad_ct_log.txt"
sender_list=$fhome"zammad_list.txt"
sendok=0
senderr=0
! [ -f $fhome"sett.conf" ] && cp -f $fhome"settings.conf" $fhome"sett.conf"


function Init2() 
{
logger "Init2"
token=$(sed -n "1p" $fhome"sett.conf" | tr -d '\r')
proxy=$(sed -n 3"p" $fhome"sett.conf" | tr -d '\r')
ssec1=$(sed -n 4"p" $fhome"sett.conf" | tr -d '\r')
bui=$(sed -n 5"p" $fhome"sett.conf" | tr -d '\r')
progons=$(sed -n 6"p" $fhome"sett.conf" | tr -d '\r')

kkik=0
}




function logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S')
echo $date1" zammad_ct_"$bui": "$1

}



function sender()
{
#logger "sender"

find $fhsender1 -maxdepth 1 -type f -name '*.sh' | sort > $sender_list
str_col=$(grep -c "" $sender_list)
#logger "sender str_col="$str_col

if [ "$str_col" -gt "0" ]; then
for (( i=1;i<=$str_col;i++)); do
test=$(sed -n $i"p" $sender_list | tr -d '\r')
logger "sender str_col="$str_col" test="$test
chmod +rx $test
rm -f $fhome"zammad/otv_zct.txt"

$test
zammad_numtick=$(cat $fhome"zammad/otv_zct.txt" | jq '.number' | sed 's/\"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\r')

if [[ $zammad_numtick =~ ^[0-9]+$ ]]; then
	echo $(date '+%Y-%m-%d_%H:%M:%S')":"$test":"$zammad_numtick >> $fhome"zammad_log.txt"
	mv -f $test $fhsender2
	logger "sender "$test" -> zammad_numtick="$zammad_numtick
else
	logger "sender error test="$test
fi

sleep $ssec1
done
fi

}


PID=$$
echo $PID > $fPID
logger "zammad_ct start"
Init2;

while true
do
sleep $ssec1
sender;
kkik=$(($kkik+1))
[ "$kkik" -ge "$progons" ] && Init2

done

rm -f $fPID

