#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

#переменные
fhome=/usr/share/fbp_bot/
fhsender=$fhome"sender/"
fhsender1=$fhsender"1/"
fhsender2=$fhsender"2/"
fPID=$fhome"sender_pid.txt"
log=$fhsender"sender_log.txt"
sender_id=$fhome"sender_id.txt"
sender_list=$fhome"sender_list.txt"
sendok=0
senderr=0



function Init2() 
{
logger "Init2"
#rm -rf $fhsender
mkdir -p $fhsender1
mkdir -p $fhsender2
echo 0 > $sender_id

token=$(sed -n "1p" $fhome"sett.conf" | tr -d '\r')
proxy=$(sed -n 3"p" $fhome"sett.conf" | tr -d '\r')
ssec1=$(sed -n 4"p" $fhome"sett.conf" | tr -d '\r')
bui=$(sed -n 5"p" $fhome"sett.conf" | tr -d '\r')
progons=$(sed -n 6"p" $fhome"sett.conf" | tr -d '\r')

kkik=0

integrity;		#только под рутом(
}



integrity ()
{
logger "integrity<<<<<<<<<<<<<<<<<<<"

local fbp=""
local trbp=""
#fbp=$(ps af | grep $(sed -n 1"p" $fhome"fbp_bot_pid.txt" | tr -d '\r') | grep abot3.sh | awk '{ print $1 }')
#trbp=$(ps af | grep $(sed -n 1"p" $fhome"zammad_ct_pid.txt" | tr -d '\r') | grep zammad_ct.sh | awk '{ print $1 }')
fbp=$(ps axu| awk '{ print $2 }' | grep $(sed -n 1"p" $fhome"fbp_bot_pid.txt"))
trbp=$(ps axu| awk '{ print $2 }' | grep $(sed -n 1"p" $fhome"zammad_ct_pid.txt"))

logger "fbp="$fbp
logger "trbp="$trbp

[ -z "$fbp" ] && logger "starter fbp_bot.sh" && $fhome"fbp_bot.sh" &
[ -z "$trbp" ] && logger "starter zammad_ct.sh" && $fhome"zammad_ct.sh" &

}



function logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S')
echo $date1" sender_"$bui": "$1

}



function sender()
{
#logger "sender"

find $fhsender1 -maxdepth 1 -type f -name '*.txt' | sort > $sender_list
str_col=$(grep -c "" $sender_list)
#logger "sender str_col="$str_col

if [ "$str_col" -gt "0" ]; then
for (( i=1;i<=$str_col;i++)); do
test=$(sed -n $i"p" $sender_list | tr -d '\r')
logger "sender str_col>0"

#logger "sender test="$test
Z1="0"
Z2="0"
code1=""
code2=""
mess_path=$(sed -n "1p" $test | tr -d '\r')							#путь к мессаджу
chat_id=$(sed -n "2p" $test | sed 's/z/-/g'| tr -d '\r')			#chat_id
#bic1=$(sed -n "2p" $test | tr -d '\r')				#спец картинок в уведомлениях 0-2
#styc1=$(sed -n "3p" $test | tr -d '\r')				#показ спец картинок severity 0-6
#url1=$(sed -n "4p" $test | tr -d '\r')				#урл
#muter=$(sed -n "5p" $test | tr -d '\r')				#mute
	
if ! [ -z "$test" ] && ! [ -z "$mess_path" ]; then
	logger "sender mess_path="$mess_path
	logger "sender test="$test
	
	directly
	
	#statistic
	if [ "$(cat $fhome"out2.txt" | grep "\"ok\":true,")" ]; then	
		sendok=$((sendok+1))
		logger "send OK "$sendok
		rm -f $test
		rm -f $mess_path
	else
		errc=$(grep "curl" $fhome"out2_err.txt")
		senderr=$((senderr+1))
		logger "send ERROR "$senderr":   "$errc
	fi
fi

sleep $ssec1
done

fi


}

#pravka_teg () 
#{
#"<b>" "</b>" " >" все конечные теги дб ОБЯЗАТЕЛЬНо!
#sed 's/ >/B000000000003/g' $mess_path > $fhome"sender_pravkateg_b3.txt"
#sed 's/<b>/B000000000001/g' $fhome"sender_pravkateg_b3.txt" > $fhome"sender_pravkateg_b1.txt"
#sed 's/<\/b>/B000000000002/g' $fhome"sender_pravkateg_b1.txt" > $fhome"sender_pravkateg_b2.txt"
#sed 's/</ /g' $fhome"sender_pravkateg_b2.txt" > $fhome"sender_pravkateg1.txt"
#sed 's/>/ /g' $fhome"sender_pravkateg1.txt" > $fhome"sender_pravkateg2.txt"
#sed 's/B000000000001/<b>/g' $fhome"sender_pravkateg2.txt" > $fhome"sender_pravkateg_b01.txt"
#sed 's/B000000000002/<\/b>/g' $fhome"sender_pravkateg_b01.txt" > $fhome"sender_pravkateg_b02.txt"
#sed 's/B000000000003/ >/g' $fhome"sender_pravkateg_b02.txt" > $fhome"sender_pravkateg_b03.txt"
#cp -f $fhome"sender_pravkateg_b03.txt" $mess_path
#}


directly () {
logger " "
logger "sender directly"
#[ "$(grep -c "<" $mess_path)" -gt "0" ] || [ "$(grep -c ">" $mess_path)" -gt "0" ] && pravka_teg

IFS=$'\x10'
text=$(cat $mess_path)
echo "token="$token
echo "chat_id="$chat_id
echo $text

if ! [ -z "$text" ]; then
	if [ -z "$proxy" ]; then
		curl -k -m 8 -L -X POST https://api.telegram.org/bot$token/sendMessage -d disable_notification=$muter -d chat_id="$chat_id" -d 'parse_mode=HTML' --data-urlencode "text="$text 1>$fhome"out2.txt" 2>$fhome"out2_err.txt"
	else
		curl -k -m 8 --proxy $proxy -L -X POST https://api.telegram.org/bot$token/sendMessage  -d disable_notification=$muter -d chat_id="$chat_id" -d 'parse_mode=HTML' --data-urlencode "text="$text 1>$fhome"out2.txt" 2>$fhome"out2_err.txt"
	fi
fi

unset IFS

cat $fhome"out2.txt"
cat $fhome"out2_err.txt"

}








PID=$$
echo $PID > $fPID

logger "sender start"
cp -f $fhome"settings.conf" $fhome"sett.conf"
sleep 1
Init2;


while true
do
sleep 1
sender;
kkik=$(($kkik+1))
[ "$kkik" -ge "$progons" ] && Init2

done



rm -f $fPID

