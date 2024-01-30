#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
fhome=/usr/share/fbp_bot/
chat_id=$1



function init() 
{
logger "init start"
bui=$(sed -n 5"p" $fhome"sett.conf" | tr -d '\r')
max_time=$(sed -n 6"p" $fhome"sett.conf" | tr -d '\r')

[ "$max_time" -le "10" ] && max_time=10
max_nop=$(((max_time)/10))	#макс кол-во проверок
logger "init max_time="$max_time
logger "init max_nop="$max_nop
}


function logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S')
echo $date1" ntracker_"$bui"_"$chat_id": "$1
}


cover_your_tracks ()
{
rm -f $fhome"find_db_otv/"$chat_id"_1.txt"
rm -f $fhome"find_db_otv/"$chat_id"_2.txt"
rm -f $fhome"find_db_otv/"$chat_id"_3.txt"
rm -f $fhome"find_db_sh/"$chat_id".sh"
		
rm -f $fhome"find_db/"$chat_id".txt"
logger "cover_your_tracks end"
}


watcher ()
{
logger "watcher start"

if ! [ -f $fhome"find_db_pid/"$chat_id".pid" ]; then
logger "watcher "$fhome"find_db_pid/"$chat_id".pid not found"
	for (( i5=1;i5<4;i5++)); do
	logger "watcher test i5="$i5
	if [ -f $fhome"find_db_otv/"$chat_id"_"$i5".txt" ]; then
		endstr=$(cat $fhome"find_db_otv/"$chat_id"_"$i5".txt" |tail -2| head -n1 | awk '{print $1}'| sed 's/(/ /g' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\r')
		logger "watcher endstr="$endstr"<"
		if [ -z "$endstr" ] || [ "$endstr" == "0" ]; then
			logger "watcher "$fhome"find_db_otv/"$chat_id"_"$i5".txt is NULL"
		else
			logger "watcher "$fhome"find_db_otv/"$chat_id"_"$i5".txt - OK - endstr="$endstr
			echo $(sed -n 1"p" $fhome"find_db/"$chat_id".txt" | tr -d '\r') > $fhome"find_db_otv1/"$chat_id".txt"
			cat $fhome"find_db_otv/"$chat_id"_"$i5".txt" >> $fhome"find_db_otv1/"$chat_id".txt"
			cover_your_tracks;
			exit 0
		fi
	fi
	done
	logger "watcher end"
	echo $(sed -n 1"p" $fhome"find_db/"$chat_id".txt" | tr -d '\r') > $fhome"find_db_otv1/"$chat_id".txt"
	echo "ERR: not found" >> $fhome"find_db_otv1/"$chat_id".txt"
	cover_your_tracks;
	exit 0
else
	logger "watcher "$fhome"find_db_pid/"$chat_id".pid present"
fi

}


#START
logger " "
logger "start"
init;

nop=0
while true
do
logger "sleep 10"
sleep 10
logger "---->"
nop=$((nop+1))
watcher;

if [ "$nop" -gt "$max_nop" ]; then
	logger "ERROR: time is over"
	cpid=$(sed -n 1"p" $fhome"find_db_pid/"$chat_id".pid" | tr -d '\r')
	killall $chat_id".sh"
	kill -9 $cpid
	rm -f $fhome"find_db_pid/"$chat_id".pid" #$fhome"find_db_pid/"$chat_id".pid.old"
	echo $(sed -n 1"p" $fhome"find_db/"$chat_id".txt" | tr -d '\r') > $fhome"find_db_otv1/"$chat_id".txt"
	echo "ERR: end of time" >> $fhome"find_db_otv1/"$chat_id".txt"
	cover_your_tracks;
	exit 0
fi

done
