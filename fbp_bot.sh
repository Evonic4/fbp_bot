#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
ver="v0.1"

fhome=/usr/share/fbp_bot/
fhsender=$fhome"sender/"
fhsender1=$fhsender"1/"
fhsender2=$fhsender"2/"
qchat_file=$fhome"qchat.txt"	#файл с содержимым по номеру вопроса и чата чат:номер вопроса
qchat_file1=$fhome"qchat1.txt"
! [ -f $fhome"sett.conf" ] && cp -f $fhome"settings.conf" $fhome"sett.conf"
lev_log=$(sed -n 7"p" $fhome"sett.conf" | tr -d '\r')
starten=1
fPID=$fhome"fbp_bot_pid.txt"



function Init2() 
{
[ "$lev_log" == "1" ] && logger "Start Init"

ttoken=$(sed -n 1"p" $fhome"sett.conf" | tr -d '\r')
ttime=$(sed -n 2"p" $fhome"sett.conf" | tr -d '\r')
proxy=$(sed -n 3"p" $fhome"sett.conf" | tr -d '\r')
bui=$(sed -n 5"p" $fhome"sett.conf" | tr -d '\r')
progons=$(sed -n 6"p" $fhome"sett.conf" | tr -d '\r')

zammad_endpoint=$(sed -n 8"p" $fhome"sett.conf" | tr -d '\r')
zammad_user=$(sed -n 9"p" $fhome"sett.conf" | tr -d '\r')
zammad_pass=$(sed -n 10"p" $fhome"sett.conf" | tr -d '\r')
zammad_btocken=$(sed -n 11"p" $fhome"sett.conf" | tr -d '\r')


col_qw=$(grep -c "" $fhome"questions.txt")
kkik=0
tinp_ok=0
tinp_err=0
i=0
}


function logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S')
echo $date1" fbp-bot_"$bui": "$1
}



to-config ()
{
logger "roborob to-config mi_num="$mi_num
local i1=0
local str_col1=0
local test1=""
str_col1=$(grep -c "" $qchat_file)
logger "roborob to-config str_col1="$str_col1
rm -f $qchat_file1
touch $qchat_file1

for (( i1=1;i1<=$str_col1;i1++)); do
test1=$(sed -n $i1"p" $qchat_file)
logger "roborob to-config i1="$i1" test1="$test1
if [ "$i1" -eq "$mi_num" ]; then
	echo $chat_id":"$req >> $qchat_file1
	logger "roborob to-config add "$chat_id":"$req" i1="$i1" test1="$test1
else
	echo $test1 >> $qchat_file1
	logger "roborob to-config add i1="$i1" test1="$test1
fi
done
cp -f $qchat_file1 $qchat_file
}



del-to-config ()
{
logger "roborob del-to-config mi_num="$mi_num
local i2=0
local str_col2=0
local test2=""
str_col2=$(grep -c "" $qchat_file)
logger "roborob del-to-config str_col2="$str_col2
rm -f $qchat_file1
touch $qchat_file1

for (( i2=1;i2<=$str_col2;i2++)); do
test2=$(sed -n $i2"p" $qchat_file)
logger "roborob del-to-config i2="$i2" test2="$test2
if [ "$i2" -ne "$mi_num" ]; then
	echo $test2 >> $qchat_file1
	logger "roborob del-to-config add test2="$test2
fi
done

cp -f $qchat_file1 $qchat_file
}


min-col-str ()
{
#local ksvs=0
local min_col_str=0
local max_col_str=0
go2="ok"

min_col_str=$(sed -n $req"p" $fhome"otv_min_str_col.txt" | tr -d '\r')
max_col_str=$(sed -n $req"p" $fhome"otv_max_str_col.txt" | tr -d '\r')
logger "roborob min-col-str min_col_str="$min_col_str"< max_col_str="$max_col_str"<"
logger "ksvs="$ksvs"<"

if [ "$ksvs" -lt "$min_col_str" ]; then
	go2="no"
	echo "Количество символов должно быть не меньше "$((min_col_str-1))" ("$((ksvs-1))"). Повторите пожалуйста ввод." > $fhome"mcs.txt"
	otv=$fhome"mcs.txt"
	send;
fi
if [ "$ksvs" -gt "$max_col_str" ]; then
	go2="no"
	echo "Количество символов должно быть не более "$((max_col_str-1))" ("$((ksvs-1))"). Повторите пожалуйста ввод." > $fhome"mcs.txt"
	otv=$fhome"mcs.txt"
	send;
fi

}

yes-or-no ()
{
go1="k"

if [ "$(echo $text | grep -c "да" )" -gt "0" ] || [ "$(echo $text | grep -c "Да" )" -gt "0" ] || [ "$(echo $text | grep -c "ДА" )" -gt "0" ]; then
	go1="yes"
fi
if [ "$(echo $text | grep -c "нет" )" -gt "0" ] || [ "$(echo $text | grep -c "Нет" )" -gt "0" ] || [ "$(echo $text | grep -c "НЕТ" )" -gt "0" ]; then
	if [ "$go1" == "yes" ]; then
		go1="k"
	else
		go1="no"
	fi
fi

if [ "$go1" == "k" ]; then
	echo "Только да или нет, пожалуйста" > $fhome"yon.txt"
	otv=$fhome"yon.txt"
	send;
fi
logger "roborob yes-or-no go1="$go1
}

next-qwery ()
{
logger "roborob next-qwery req="$req" chat_id="$chat_id
echo $(sed -n $req"p" $fhome"questions.txt" | tr -d '\r') >> $fhome"/qw/"$chat_id".txt"
echo $text >> $fhome"/qw/"$chat_id".txt"
req=$((req+1))
to-config
echo $(sed -n $req"p" $fhome"questions.txt" | tr -d '\r') > $fhome"qw.txt"
otv=$fhome"qw.txt"
send;
}

after-yes-or-no ()
{
logger "roborob after-yes-or-no req="$req" chat_id="$chat_id
if [ "$go1" == "yes" ]; then
	if [ "$req" -eq "1" ]; then
		next-qwery;
	fi
	if [ "$req" -eq "3" ]; then
		echo $(sed -n $req"p" $fhome"questions.txt" | tr -d '\r') >> $fhome"/qw/"$chat_id".txt"
		echo $text >> $fhome"/qw/"$chat_id".txt"
		del-to-config
		mv -f $fhome"/qw/"$chat_id".txt" $fhome"/qw_old/"$chat_id".txt"
		otv=$fhome"blagodarochka.txt"
		send;
	fi
fi
if [ "$go1" == "no" ]; then
	if [ "$req" -eq "1" ]; then
		del-to-config
		echo "Рекомендуем обратиться и вернуться к нам с обратной связью по результату обращения." > $fhome"qw.txt"
		otv=$fhome"qw.txt"
		send;
	fi
	if [ "$req" -eq "3" ]; then
		next-qwery;
	fi
fi
}


roborob ()  	
{
local go=""
local str_col3=0
date1=$(date '+ %d.%m.%Y %H:%M:%S')
[ "$lev_log" == "1" ] && logger "text="$text
otv=""

if [ "$text" = "/help" ] ; then
	logger "roborob help, chat_id="$chat_id"<==================================="
	otv=$fhome"help.txt"
	send;
	go="go"
fi

if [ "$text" = "/start" ] ; then
	mi_num=$(cat $qchat_file | grep -n $chat_id":" | awk -F":" '{print $1}' | tr -d '\r')
	logger "roborob start, chat_id="$chat_id" mi_num="$mi_num"<==================================="
	rm -f $fhome"start1.txt"
	if ! [[ $mi_num =~ ^[0-9]+$ ]]; then
		echo $chat_id":1" >> $qchat_file
		rm -f $fhome"/qw/"$chat_id".txt"
		username=$(cat $fhome"in.txt" | jq ".result[$i].message.chat.username" | sed 's/\"//g' | tr -d '\r')
		logger "roborob start, username="$username" mi_num="$mi_num
		echo "Здравствуйте "$username"!" > $fhome"start1.txt"
	fi
	echo $(sed -n 1"p" $fhome"questions.txt" | tr -d '\r') >> $fhome"start1.txt"
	otv=$fhome"start1.txt"
	send;
	go="go"
fi

#клиент что-то пишет
if [ -z "$go" ]; then
	logger "roborob writing, chat_id="$chat_id"<==================================="
	mi_num=$(cat $qchat_file | grep -n $chat_id":" | awk -F":" '{print $1}' | tr -d '\r')
	if ! [ -z "$mi_num" ]; then
		req=$(sed -n $mi_num"p" $qchat_file| awk -F":" '{print $2}' | tr -d '\r')
		logger "roborob OK qchat_file mi_num="$mi_num" req="$req
		
		if [ "$req" -eq "$col_qw" ]; then	#последний вопрос
			min-col-str;
			if [ "$go2" == "ok" ]; then
			echo $(sed -n $req"p" $fhome"questions.txt" | tr -d '\r') >> $fhome"/qw/"$chat_id".txt"
			echo $text >> $fhome"/qw/"$chat_id".txt"
			echo "chat="$chat_id >> $fhome"/qw/"$chat_id".txt"
			username=$(cat $fhome"in.txt" | jq ".result[$i].message.chat.username" | sed 's/\"//g' | tr -d '\r')
			echo "username="$username >> $fhome"/qw/"$chat_id".txt"
			
			del-to-config
			otv=$fhome"blagodarochka2.txt"
			send;
			#zammad
			zammad-create-ticket;
			mv -f $fhome"/qw/"$chat_id".txt" $fhome"/qw_old/"$chat_id".txt"
			fi
		fi
		
		if [ "$(cat $fhome"otv_yes_or_no.txt"| grep -c $req":" | tr -d '\r')" -gt "0" ]; then
			if [ "$req" -ne "$col_qw" ]; then
				yes-or-no;
				after-yes-or-no;
			fi
		else
			if [ "$req" -ne "$col_qw" ]; then
				min-col-str;
				[ "$go2" == "ok" ] && next-qwery;
			fi
		fi
		
		
	fi
fi


logger "roborob otv="$otv
}

zammad-create-ticket ()
{
local title=""
local subject=""
local body=""

logger "roborob zammad-create-ticket chat_id="$chat_id
cp -f $fhome"0.sh" $fhome$chat_id".sh"
title="Help "$(sed -n 10"p" $fhome"/qw/"$chat_id".txt"| sed 's/\"//g' | tr -d '\r')" chat:"$chat_id
subject=$(sed -n 5"p" $fhome"sett.conf" | tr -d '\r')
body=$(cat $fhome"/qw/"$chat_id".txt" | sed 's,$,\\n,'| sed 's/\"//g' | tr -d '\r\n')

echo "curl -k -s -m 13 --location '"$zammad_endpoint"' \\" >> $fhome$chat_id".sh"
echo "--header 'Content-Type: application/json' \\" >> $fhome$chat_id".sh"
echo "--header 'Authorization: "$zammad_btocken"' \\" >> $fhome$chat_id".sh"
echo "--data-raw '{" >> $fhome$chat_id".sh"
echo "   \"title\": \""$title"\"," >> $fhome$chat_id".sh"
echo "   \"group\": \"Support\"," >> $fhome$chat_id".sh"
echo "   \"customer\": \"tg_fbp_bot@yandex.ru\"," >> $fhome$chat_id".sh"
echo "   \"article\": {" >> $fhome$chat_id".sh"
echo "      \"subject\": \""$subject"\"," >> $fhome$chat_id".sh"
echo "      \"body\": \""$body"\"," >> $fhome$chat_id".sh"
echo "      \"type\": \"note\"," >> $fhome$chat_id".sh"
echo "      \"internal\": false" >> $fhome$chat_id".sh"
echo "   }" >> $fhome$chat_id".sh"
echo "}' | jq '.' > "$fhome"zammad/otv_zct.txt" >> $fhome$chat_id".sh"

chmod +rx $fhome$chat_id".sh"
mv -f $fhome$chat_id".sh" $fhome"zammad/"$chat_id".sh"

#$fhome"zammad/"$chat_id".sh"
#zammad_numtick=$(cat $fhome"zammad/otv_zct.txt" | jq '.number' | sed 's/\"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\r')
#в очередь отправки
}


sender_queue ()
{
snu=$(date +%s%N)
logger "sender_queue snu="$snu
}

send1 () 
{
[ "$lev_log" == "1" ] && logger "send1 start"
sender_queue

echo $fhsender2$snu".txt" > $fhome"sender.txt"
echo $chat_id >> $fhome"sender.txt"

cp -f $otv $fhsender2$snu".txt"
cp -f $fhome"sender.txt" $fhsender1$snu".txt"

}


send ()
{
[ "$lev_log" == "1" ] && logger "send start"

dl=$(wc -m $otv | awk '{ print $1 }')
logger "send dl="$dl
if [ "$dl" -gt "4000" ]; then
	sv=$(echo "$dl/4000" | bc)
	sv=$((sv+1))
	echo "sv="$sv
	$fhome"rex.sh" $otv
	logger "obrezka"
	for (( i5=1;i5<=$sv;i5++)); do
		otv=$fhome"rez"$i5".txt"
		logger "obrezka "$fhome"rez"$i5".txt"
		send1;
		logger "to obrezka "$fhome"rez"$i5".txt"
		rm -f $fhome"rez"$i5".txt"
	done
	
else
	send1;
fi

}




input ()  		
{
logger "input start"
$fhome"cucu1.sh" $upd_id1

if [ "$(cat $fhome"in.txt" | grep "\"ok\":true,")" ]; then	
	tinp_ok=$((tinp_ok+1))
	logger "input OK "$tinp_ok
else
	tinp_err=$((tinp_err+1))
	logger "input ERROR "$tinp_err":   "$(grep "curl:" $fhome"in_err.txt")
fi

[ "$lev_log" == "1" ] && logger "input exit"
}


starten_furer ()  				
{
again2="yes"
while [ "$again2" = "yes" ]
do
$fhome"cucu1.sh"
if [ "$(cat $fhome"in.txt" | grep "\"ok\":true,")" ]; then	
	logger "start input OK"
	again2="no"
else
	logger "start input ERROR"
fi
sleep 1
done


if [ "$starten" -eq "1" ]; then
	[ "$lev_log" == "1" ] && logger "starten_furer"
	upd_id=$(cat $fhome"in.txt" | jq ".result[].update_id" | tail -1 | tr -d '\r')
	if ! [ -z "$upd_id" ]; then
		echo $upd_id > $fhome"lastid.txt"
		else
		echo "0" > $fhome"lastid.txt"
	fi
	logger "starten_furer upd_id="$upd_id
	starten=0
	upd_id1=$(sed -n 1"p" $fhome"lastid.txt" | tr -d '\r')
fi

}




parce ()
{
[ "$lev_log" == "1" ] && logger "parce"
mi=0
date1=$(date '+ %d.%m.%Y %H:%M:%S')
mi_col=$(cat $cuf"in.txt" | grep -c update_id | tr -d '\r')
logger "parce col mi_col="$mi_col
upd_id=$(sed -n 1"p" $fhome"lastid.txt" | tr -d '\r')
logger "parce upd_id="$upd_id

if [ "$mi_col" -gt "0" ]; then
for (( i=0;i<$mi_col;i++)); do
	mi=$(cat $fhome"in.txt" | jq ".result[$i].update_id" | tr -d '\r')
	[ "$lev_log" == "1" ] && logger "parce update_id=mi="$mi
	
	[ -z "$mi" ] && mi=0
	[ "$mi" == "null" ] && mi=0
	
	[ "$lev_log" == "1" ] && logger "parce cycle upd_id="$upd_id", i="$i", mi="$mi
	if [ "$upd_id" -ge "$mi" ] || [ "$mi" -eq "0" ]; then
		ffufuf=1
		else
		ffufuf=0
	fi
	[ "$lev_log" == "1" ] && logger "parce cycle ffufuf="$ffufuf
	
	if [ "$ffufuf" -eq "0" ]; then
		chat_id=$(cat $fhome"in.txt" | jq ".result[$i].message.chat.id" | sed 's/-/z/g' | tr -d '\r')
		text=$(cat $fhome"in.txt" | jq ".result[$i].message.text" | sed 's/\"/ /g' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\r')
		ksvs=$(echo $text | wc -c | tr -d '\r')
		
		if [ "$ksvs" -gt "0" ]; then
			logger "parce OK ksvs="$ksvs", chat_id="$chat_id
			roborob;
		else
			[ "$lev_log" == "1" ] && logger "parce FAIL ksvs="$ksvs", chat_id="$chat_id
		fi
	fi
	if [ "$ffufuf" -eq "1" ]; then
		logger "parce lastid >= mi"
	fi
done
[ "$ffufuf" -eq "0" ] && echo $mi > $fhome"lastid.txt" && logger "parce mi -> lastid.txt"
fi

[ "$lev_log" == "1" ] && logger "parce end"
}





PID=$$
echo $PID > $fPID

logger ""
logger "start fbp_bot "$bui" "$ver" lev_log="$lev_log
Init2;
starten_furer;
kkik=0

while true
do
sleep $ttime

tinp_ok1=$tinp_ok
input;
[ "$tinp_ok" -gt "$tinp_ok1" ] && parce;
[ "$i" -gt "50" ] && upd_id1=$upd_id

kkik=$(($kkik+1))
if [ "$kkik" -ge "$progons" ]; then
	Init2
fi

done
rm -f $fPID




