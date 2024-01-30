#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
ver="v0.2"

fhome=/usr/share/fbp_bot/
fhsender=$fhome"sender/"
fhsender1=$fhsender"1/"
fhsender2=$fhsender"2/"
qchat_file=$fhome"qchat.txt"		#файл с содержимым по номеру вопроса и чата чат:номер вопроса
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

customer=$(sed -n 15"p" $fhome"sett.conf" | tr -d '\r')
[ "$(echo $customer | sed 's/^[ \t]*//;s/[ \t]*$//' )" == "" ] && customer="tg_fbp_bot@yandex.ru"

zammad_endpoint=$(sed -n 8"p" $fhome"sett.conf" | tr -d '\r')
zammad_user=$(sed -n 9"p" $fhome"sett.conf" | tr -d '\r')
zammad_pass=$(sed -n 10"p" $fhome"sett.conf" | tr -d '\r')
zammad_btocken=$(sed -n 11"p" $fhome"sett.conf" | tr -d '\r')

	smtp_hostname=$(sed -n 16"p" $fhome"sett.conf" | tr -d '\r')
	smtp_sport=$(sed -n 17"p" $fhome"sett.conf" | tr -d '\r')
	smtp_user=$(sed -n 18"p" $fhome"sett.conf" | tr -d '\r')
	smtp_pass=$(sed -n 19"p" $fhome"sett.conf" | tr -d '\r')

#col_qw=$(grep -c "" $fhome"questions.txt")

tinp_ok=0
tinp_err=0
i=0
}


function logger()
{
local date4=$(date '+ %Y-%m-%d %H:%M:%S')
echo $date4" fbp-bot_"$bui": "$1
}



to-config ()
{
logger "to-config chat_id="$chat_id" config="$config" mi_num_str="$mi_num_str" new_qw_num="$new_qw_num
local i1=0
local str_col1=0
local test1=""
local config1=$fhome"config1_tmp.txt"

str_col1=$(grep -c "" $config)
logger "to-config str_col1="$str_col1
rm -f $config1
touch $config1

for (( i1=1;i1<=$str_col1;i1++)); do
test1=$(sed -n $i1"p" $config)
logger "to-config i1="$i1" test1="$test1
if [ "$i1" -eq "$mi_num_str" ]; then
	echo $chat_id":"$new_qw_num >> $config1
	logger "to-config add "$chat_id":"$new_qw_num" i1="$i1" test1="$test1
else
	echo $test1 >> $config1
	logger "to-config add i1="$i1" test1="$test1
fi
done
cp -f $config1 $config
}



del-to-config ()
{
logger "del-to-config mi_num_str="$mi_num_str
local i2=0
local str_col2=0
local test2=""
local config1=$fhome"config1_tmp.txt"

str_col2=$(grep -c "" $config)
logger "del-to-config str_col2="$str_col2
rm -f $config1
touch $config1

for (( i2=1;i2<=$str_col2;i2++)); do
test2=$(sed -n $i2"p" $config)
logger "del-to-config i2="$i2" test2="$test2
if [ "$i2" -ne "$mi_num_str" ]; then
	echo $test2 >> $config1
	logger "del-to-config add test2="$test2
fi
done

cp -f $config1 $config
}


min-col-str ()
{
#local ksvs=0
local min_col_str=0
local max_col_str=0
go2="ok"

min_col_str=$1
max_col_str=$2
logger "min-col-str min_col_str="$min_col_str"< max_col_str="$max_col_str"<"
logger "min-col-str ksvs="$ksvs"<"

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

check_mail_in_txt ()
{
go4=""
echo $text > $fhome"text_tmp.txt"

if [ "$(cat $fhome"text_tmp.txt" | grep -c "@" )" -gt "0" ]; then
	go4="ok"
else
	echo "Вы не указали адрес электронной почты, повторите пожалуйста ввод." > $fhome"check_mail_in_txt.txt"
	otv=$fhome"check_mail_in_txt.txt"
	send;
fi
logger "check_mail_in_txt go4="$go4
}



next-qwery ()
{
logger "next-qwery new_qw_num="$new_qw_num" chat_id="$chat_id
echo "----" >> $fhome"/qw/"$chat_id".txt"
cat $fhome"questions/questions"$qw_num".txt" >> $fhome"/qw/"$chat_id".txt"		#запишем предыдущий вопрос
echo "----" >> $fhome"/qw/"$chat_id".txt"
echo $text >> $fhome"/qw/"$chat_id".txt"										#запишем предыдущий ответ
to-config
#cat $fhome"questions/questions"$new_qw_num".txt" >> $fhome"/qw/"$chat_id".txt"
otv=$fhome"questions/questions"$new_qw_num".txt"
send;
}


end_of_the_movie ()
{
logger "end_of_the_movie"
echo "----" >> $fhome"/qw/"$chat_id".txt"
username=$(cat $fhome"in.txt" | jq ".result[$i].message.chat.username" | sed 's/\"//g' | tr -d '\r')
echo "username="$username >> $fhome"/qw/"$chat_id".txt"
echo "chat="$chat_id >> $fhome"/qw/"$chat_id".txt"
echo $fhome"/qw_old/"$chat_id"_"$date1".txt" >> $fhome"/qw/"$chat_id".txt"
mv -f $fhome"/qw/"$chat_id".txt" $fhome"/qw_old/"$chat_id"_"$date1".txt"
del-to-config
}


roborob ()  	
{
local go=""
#local go3=""
local str_col3=0
date1=$(date '+%d.%m.%Y_%H-%M-%S')
date2=$(date '+%d%m%Y%H%M%S')
[ "$lev_log" == "1" ] && IFS=$'\x10' && logger "text="$text && unset IFS
otv=""

if [ "$text" = "/help" ] ; then
	logger "roborob help, chat_id="$chat_id"<==================================="
	otv=$fhome"help.txt"
	send;
	go="go"
fi

if [ "$text" = "/start" ] ; then
	qw_num=$(grep $chat_id":" $qchat_file | awk -F":" '{print $2}' | tr -d '\r')
	logger "roborob start, chat_id="$chat_id" qw_num="$qw_num"<==================================="
	rm -f $fhome"qw/"$chat_id".txt"
	if [ -z "$qw_num" ]; then
		echo $chat_id":1" >> $qchat_file
		username=$(cat $fhome"in.txt" | jq ".result[$i].message.chat.username" | sed 's/\"//g' | tr -d '\r')
		logger "roborob username="$username
		#echo "Здравствуйте "$username"!" > $fhome"start1.txt"
	else
		#почистим все
		mi_num_str=$(grep -n $chat_id":" $qchat_file | awk -F":" '{print $1}' | tr -d '\r')
		new_qw_num="1"
		config=$qchat_file
		to-config;
		#чистим 1_1_1_2.txt
		if [ "$(grep -c $chat_id":" $fhome"1_1_1_2.txt")" -gt "0" ]; then
			mi_num_str1=$(grep -n $chat_id":" $fhome"1_1_1_2.txt" | awk -F":" '{print $1}' | tr -d '\r')
			del-to-config-attempts;
		fi
	fi
	rm -f $fhome"find_db/"$chat_id".txt"
	otv=$fhome"questions/questions1.txt"
	send;
	go="go"
fi

#клиент что-то пишет
if [ -z "$go" ]; then
	logger "roborob writing, chat_id="$chat_id"<==================================="
	mi_num_str=$(cat $qchat_file | grep -n $chat_id":" | awk -F":" '{print $1}' | tr -d '\r')
	if ! [ -z "$mi_num_str" ]; then
		qw_num=$(sed -n $mi_num_str"p" $qchat_file| awk -F":" '{print $2}' | tr -d '\r')
		logger "roborob OK qchat_file mi_num_str="$mi_num_str" qw_num="$qw_num"<"
		
		if [ "$qw_num" == "1" ]; then
			min-col-str 1 2
			if [ "$go2" == "ok" ]; then
				if [ "$text" == "1" ] || [ "$text" == "2" ] || [ "$text" == "3" ]; then
					new_qw_num="1_"$text
					config=$qchat_file
					next-qwery;
					#go3="ok"
				fi
			fi
		fi
		if [ "$qw_num" == "1_1" ]; then
			min-col-str 1 2
			if [ "$go2" == "ok" ]; then
				if [ "$text" == "1" ]; then
					new_qw_num="1_1_1"
					config=$qchat_file
					next-qwery;
					#go3="ok"
				fi
				if [ "$text" == "2" ]; then		#кАнец фильмА
					new_qw_num="1_1_2"
					config=$qchat_file
					next-qwery;
					end_of_the_movie;
					#go3="ok"
				fi
			fi
		fi
		
		if [ "$qw_num" == "1_2" ]; then
			min-col-str 1 2
			if [ "$go2" == "ok" ]; then
				if [ "$text" == "1" ]; then		#кАнец фильмА
					new_qw_num="1_2_1"
					config=$qchat_file
					next-qwery;
					end_of_the_movie;
					#go3="ok"
				fi
				if [ "$text" == "2" ]; then
					new_qw_num="1_2_2"
					config=$qchat_file
					next-qwery;
					#go3="ok"
				fi
			fi
		fi
		if [ "$qw_num" == "1_2_2" ]; then
			min-col-str 4 300
			if [ "$go2" == "ok" ]; then
				check_mail_in_txt;
				if [ "$go4" == "ok" ]; then		#кАнец фильмА
					new_qw_num="1_2_2_1"
					config=$qchat_file
					next-qwery;
					end_of_the_movie;
					title="Help "$username" chat:"$chat_id
					zammad-create-ticket;
					#go3="ok"
				fi
			fi
		fi
		
		if [ "$qw_num" == "1_3" ]; then
			min-col-str 4 300
			if [ "$go2" == "ok" ]; then
				check_mail_in_txt;
				if [ "$go4" == "ok" ]; then		#кАнец фильмА
					new_qw_num="1_3_1"
					config=$qchat_file
					next-qwery;
					end_of_the_movie;
					MADDR=$(sed -n 20"p" $fhome"sett.conf" | tr -d '\r')
					MSUBJ="MIxVel_fbp_bot: Вопрос от пользователя "$username" chat:"$chat_id
					MBODY=$text
					smail;
					#go3="ok"
				fi
			fi
		fi
		
		if [ "$qw_num" == "1_1_1" ]; then
			min-col-str 1 2
			if [ "$go2" == "ok" ]; then
				if [ "$text" == "1" ] || [ "$text" == "2" ]; then
					new_qw_num="1_1_1_"$text
					config=$qchat_file
					next-qwery;
					#go3="ok"
				fi
			fi
		fi
		if [ "$qw_num" == "1_1_1_1" ]; then		#1-5
			min-col-str 1 2
			if [ "$go2" == "ok" ]; then
				if [ "$text" == "1" ] || [ "$text" == "2" ] || [ "$text" == "3" ] || [ "$text" == "4" ]; then
					new_qw_num="1_1_1_1_2"
					config=$qchat_file
					next-qwery;
					#go3="ok"
				fi
				if [ "$text" -eq "5" ]; then
					new_qw_num="1_1_1_1_1"
					config=$qchat_file
					next-qwery;
					end_of_the_movie;
					title="Review-5 "$username" chat:"$chat_id
					zammad-create-ticket;
					#go3="ok"
				fi
			fi
		fi
		if [ "$qw_num" == "1_1_1_1_2" ]; then
			min-col-str 4 300
			if [ "$go2" == "ok" ]; then			#кАнец фильмА
				new_qw_num="1_1_1_1_2_1"
				config=$qchat_file
				next-qwery;
				end_of_the_movie;
				title="Review "$username" chat:"$chat_id
				zammad-create-ticket;
				#go3="ok"
			fi
		fi
		
		if [ "$qw_num" == "1_1_1_2" ]; then		#----------------------------------поиск по номеру-------------------
			min-col-str 6 42
			if [ "$go2" == "ok" ]; then
				if ! [ -f $fhome"find_db/"$chat_id".txt" ] && [ "$(grep -c $chat_id $fhome"1_1_1_2.txt")" -eq "0" ]; then
					otv=$fhome"wait"$((RANDOM%3+1))".txt"
					send;
					find_db;
					#go3="ok"
				fi
			fi
		fi
		if [ "$qw_num" == "1_1_1_2_2" ]; then		#----------------------------попытки------------------
			min-col-str 6 42
			if [ "$go2" == "ok" ]; then
				if ! [ -f $fhome"find_db/"$chat_id".txt" ] && ! [ -f $fhome"find_db_otv1/"$chat_id".txt" ]; then
					otv=$fhome"wait"$((RANDOM%3+1))".txt"
					send;
					find_db;
					#go3="ok"
				fi
			fi
		fi
		if [ "$qw_num" == "1_1_1_2_1" ]; then
			min-col-str 4 400
			if [ "$go2" == "ok" ]; then
				check_mail_in_txt;
				if [ "$go4" == "ok" ]; then		#кАнец фильмА
					new_qw_num="1_1_1_2_1_1"
					config=$qchat_file
					next-qwery;
					end_of_the_movie;
					title="Help "$username" chat:"$chat_id
					zammad-create-ticket;
					zapushgateway;
					#go3="ok"
				fi
			fi
		fi
		

		#if [ -z "$go3" ]; then
			#+_1
			#min-col-str 1 2
			#[ "$go2" == "ok" ] && new_qw_num=$qw_num"_1" && next-qwery;
		#fi
		
	fi
fi


logger "roborob otv="$otv
}


zapushgateway ()
{
count=$(sed -n 1"p" $fhome"count_z.txt" | tr -d '\r')
count=$((count+1))
echo $count > $fhome"count_z.txt"
logger "zapushgateway count="$count
}



find_db ()
{

find1=$text
constructor_psql;
echo $text > $fhome"find_db/"$chat_id".txt"
rm -f $fhome"find_db_otv/"$chat_id".txt"

#заносим инфу о 1 попытках $fhome"1_1_1_2.txt"
mi_num_str1=$(grep -n $chat_id":" $fhome"1_1_1_2.txt" | awk -F":" '{print $1}' | tr -d '\r')
if [ -z "$mi_num_str1" ]; then
	#первак
	echo $chat_id":1" >> $fhome"1_1_1_2.txt"
	logger "find_db new 1_1_1_2 "$chat_id":1"
fi
logger "find_db chat_id="$chat_id" 1_1_1_2 mi_num_str1="$mi_num_str1"< find1="$find1

$fhome"find_db_sh/"$chat_id".sh" &
$fhome"ntracker.sh" $chat_id &
}




constructor_psql ()
{
logger "constructor_psql start"
host=$(sed -n 22"p" $fhome"sett.conf" | tr -d '\r')
port=$(sed -n 23"p" $fhome"sett.conf" | tr -d '\r')
hostp=$host":"$port
db=$(sed -n 24"p" $fhome"sett.conf" | tr -d '\r')
user=$(sed -n 25"p" $fhome"sett.conf" | tr -d '\r')
pass=$(sed -n 26"p" $fhome"sett.conf" | tr -d '\r')

cp -f $fhome"sendmail_tmp.sh" $fhome"find_db_sh/"$chat_id".sh"

echo "PID=\$\$" >> $fhome"find_db_sh/"$chat_id".sh"
echo "echo \$PID > "$fhome"find_db_pid/"$chat_id".pid" >> $fhome"find_db_sh/"$chat_id".sh"

echo "echo \"BookingRefs:\" > "$fhome"find_db_otv/"$chat_id"_1.txt" >> $fhome"find_db_sh/"$chat_id".sh"
echo "psql \"postgresql://"$user":"$pass"@"$hostp"/"$db"\" -c \"SELECT * FROM \\\"BookingRefs\\\" WHERE \\\"BookingId\\\"='"$find1"';\" >> "$fhome"find_db_otv/"$chat_id"_1.txt" >> $fhome"find_db_sh/"$chat_id".sh"
echo "echo \"Orders:\" > "$fhome"find_db_otv/"$chat_id"_2.txt" >> $fhome"find_db_sh/"$chat_id".sh"
echo "psql \"postgresql://"$user":"$pass"@"$hostp"/"$db"\" -c \"SELECT * FROM \\\"Orders\\\" WHERE \\\"MixvelId\\\"='"$find1"';\" >> "$fhome"find_db_otv/"$chat_id"_2.txt" >> $fhome"find_db_sh/"$chat_id".sh"
echo "echo \"Tickets:\" > "$fhome"find_db_otv/"$chat_id"_3.txt" >> $fhome"find_db_sh/"$chat_id".sh"
echo "psql \"postgresql://"$user":"$pass"@"$hostp"/"$db"\" -c \"SELECT * FROM \\\"Tickets\\\" WHERE \\\"Number\\\"='"$find1"';\" >> "$fhome"find_db_otv/"$chat_id"_3.txt" >> $fhome"find_db_sh/"$chat_id".sh"

echo "rm -f "$fhome"find_db_pid/"$chat_id".pid" >> $fhome"find_db_sh/"$chat_id".sh"

cd $fhome"find_db_sh/"
perl -pi -e "s/\r\n/\n/" ./*.sh
chmod +rx ./*.sh
cd $fhome
}


smail()
{
if ! [ "$smtp_hostname" == "" ] && ! [ "$smtp_sport" == "" ] && ! [ "$smtp_user" == "" ] && ! [ "$smtp_pass" == "" ]; then
	logger "smail"
	cp -f $fhome"sendmail_tmp.sh" $fhome"sendmail.sh"
	
		logger "smail send mail to "$MADDR
		echo "su monitoring -c 'cd; echo \""$MBODY"\" | mail -s \""$MSUBJ"\" "$MADDR"' -s /bin/bash" >> $fhome"sendmail.sh"
	
	chmod +rx $fhome"sendmail.sh"
	$fhome"sendmail.sh" 2>&1 &

else
	logger "smail FAIL"
fi
}


zammad-create-ticket ()
{
local subject=""
local body=""
logger "roborob zammad-create-ticket chat_id="$chat_id

cp -f $fhome"0.sh" $fhome$chat_id"_"$date2".sh"
#title="Help "$username" chat:"$chat_id
subject=$fhome"/qw_old/"$chat_id"_"$date1".txt"
body=$(cat $fhome"/qw_old/"$chat_id"_"$date1".txt" | sed 's,$,\\n,'| sed 's/\"//g' | tr -d '\r\n')

echo "curl -k -s -m 13 --location '"$zammad_endpoint"' \\" >> $fhome$chat_id"_"$date2".sh"
echo "--header 'Content-Type: application/json' \\" >> $fhome$chat_id"_"$date2".sh"
echo "--header 'Authorization: "$zammad_btocken"' \\" >> $fhome$chat_id"_"$date2".sh"
echo "--data-raw '{" >> $fhome$chat_id"_"$date2".sh"
echo "   \"title\": \""$title"\"," >> $fhome$chat_id"_"$date2".sh"
echo "   \"group\": \"Support\"," >> $fhome$chat_id"_"$date2".sh"
echo "   \"customer\": \""$customer"\"," >> $fhome$chat_id"_"$date2".sh"
echo "   \"article\": {" >> $fhome$chat_id"_"$date2".sh"
echo "      \"subject\": \""$subject"\"," >> $fhome$chat_id"_"$date2".sh"
echo "      \"body\": \""$body"\"," >> $fhome$chat_id"_"$date2".sh"
echo "      \"type\": \"note\"," >> $fhome$chat_id"_"$date2".sh"
echo "      \"internal\": false" >> $fhome$chat_id"_"$date2".sh"
echo "   }" >> $fhome$chat_id"_"$date2".sh"
echo "}' | jq '.' > "$fhome"zammad/otv_zct.txt" >> $fhome$chat_id"_"$date2".sh"

chmod +rx $fhome$chat_id"_"$date2".sh"
mv -f $fhome$chat_id"_"$date2".sh" $fhome"zammad/"$chat_id"_"$date2".sh"

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
#date1=$(date '+ %d.%m.%Y %H:%M:%S')
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


del-to-config-attempts ()
{
logger "del-to-config-attempts mi_num_str1="$mi_num_str1
#удаляем из попыток
config=$fhome"1_1_1_2.txt"
mi_num_str=$mi_num_str1
del-to-config;
rm -f $fhome"find_db_otv/"$chat_id".txt"
}


carriage_return ()
{
logger "carriage_return start"

for chat_id in $(cat $fhome"find_db_otv1.txt" | grep -v \#|tr -d '\r')
do
logger "find 1_1_1_2 otvet ================ chat_id="$chat_id
if [ "$(grep -c "ERR: " $fhome"find_db_otv1/"$chat_id".txt")" -gt "0" ]; then
	logger "find 1_1_1_2 chat_id="$chat_id" FAIL"
	mi_num_str1=$(cat $fhome"1_1_1_2.txt" | grep -n $chat_id":" | awk -F":" '{print $1}' | tr -d '\r')
	qw_num1=$(sed -n $mi_num_str1"p" $fhome"1_1_1_2.txt" | awk -F":" '{print $2}' | tr -d '\r')
	logger "find 1_1_1_2 mi_num_str1="$mi_num_str1" qw_num1="$qw_num1
	
	if [ "$qw_num1" -eq "3" ]; then
		#кАнец фильмА
		mi_num_str=$(grep -n $chat_id":" $qchat_file | awk -F":" '{print $1}' | tr -d '\r')
		qw_num="1_1_1_2_2";new_qw_num="1_1_1_2_2_2"; config=$qchat_file; text="";
		#IFS=$'\x10'; text=$(cat $fhome"find_db_otv1/"$chat_id".txt"); unset IFS;
		logger "find 1_1_1_2 new_qw_num="$new_qw_num
		next-qwery;
		cat $fhome"find_db_otv1/"$chat_id".txt" >> $fhome"/qw/"$chat_id".txt"
		date1=$(date '+%d.%m.%Y_%H-%M-%S')
		end_of_the_movie;
		#удаляем из попыток
		del-to-config-attempts;
	else
		#еще разок 1_1_1_2.txt
		new_qw_num=$((qw_num1+1))
		mi_num_str=$mi_num_str1
		config=$fhome"1_1_1_2.txt"
		to-config;
		#ответ и след попытка
		qw_num="1_1_1_2"; new_qw_num="1_1_1_2_2"; config=$qchat_file; text="";
		#IFS=$'\x10'; text=$(cat $fhome"find_db_otv1/"$chat_id".txt"); unset IFS;
		mi_num_str=$(grep -n $chat_id":" $qchat_file | awk -F":" '{print $1}' | tr -d '\r')
		logger "find 1_1_1_2 new_qw_num="$new_qw_num
		next-qwery;
		cat $fhome"find_db_otv1/"$chat_id".txt" >> $fhome"/qw/"$chat_id".txt"
	fi
	
else
	logger "find 1_1_1_2 chat_id="$chat_id" OK"
	#следующий вопрос
	qw_num="1_1_1_2"; new_qw_num="1_1_1_2_1"; config=$qchat_file; text="";
	#IFS=$'\x10'; text=$(cat $fhome"find_db_otv1/"$chat_id".txt"); unset IFS;
	mi_num_str=$(grep -n $chat_id":" $qchat_file | awk -F":" '{print $1}' | tr -d '\r')
	next-qwery;
	#ответ и поиск в лог чата
	cat $fhome"find_db_otv1/"$chat_id".txt" >> $fhome"/qw/"$chat_id".txt"
	#удаляем из попыток
	del-to-config-attempts;
fi
#тут надо еще по логу в чат с попытками подумать

rm -f $fhome"find_db_otv1/"$chat_id".txt"
done
}










PID=$$
echo $PID > $fPID

logger ""
logger "start fbp_bot "$bui" "$ver" lev_log="$lev_log
Init2;
starten_furer;

while true
do
sleep $ttime

tinp_ok1=$tinp_ok
input;
[ "$tinp_ok" -gt "$tinp_ok1" ] && parce;
[ "$i" -gt "50" ] && upd_id1=$upd_id


#возврат каретки
ls $fhome"find_db_otv1/" | sed 's/\.\///g' | sed 's/\.txt//g' > $fhome"find_db_otv1.txt"
[ "$(grep -c "" $fhome"find_db_otv1.txt")" -gt "0" ] && carriage_return;


done
rm -f $fPID




