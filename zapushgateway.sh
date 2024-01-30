#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
fhome=/usr/share/fbp_bot/
name_metric="fbp_z_count"
fPID=$fhome"zapushgateway_pid.txt"


function init() 
{
logger "init start"
bui=$(sed -n 5"p" $fhome"sett.conf" | tr -d '\r')

pushg_ip=$(sed -n 12"p" $fhome"sett.conf" | tr -d '\r')
pushg_port=$(sed -n 13"p" $fhome"sett.conf" | tr -d '\r')
namejob=$(sed -n 14"p" $fhome"sett.conf" | tr -d '\r')

}


function logger()
{
local date1=$(date '+ %Y-%m-%d %H:%M:%S')
echo $date1" zapushgateway_"$bui": "$1
}

zapushgateway ()
{
logger "send pushgateway "$name_metric" "$count
count=$(sed -n 1"p" $fhome"count_z.txt" | tr -d '\r')
echo $name_metric" "$count | curl -m 10 --data-binary @- "http://"$pushg_ip":"$pushg_port"/metrics/job/"$namejob
}


#START
PID=$$
echo $PID > $fPID

logger " "
logger "start"
init;

while true
do
sleep 5m
zapushgateway;
done

rm -f $fPID