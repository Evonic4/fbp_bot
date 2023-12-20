#!/bin/bash
export PATH="$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

fhome=/usr/share/fbp_bot/
zammad_endpoint=$(sed -n 8"p" $fhome"sett.conf" | tr -d '\r')
zammad_user=$(sed -n 9"p" $fhome"sett.conf" | tr -d '\r')
zammad_pass=$(sed -n 10"p" $fhome"sett.conf" | tr -d '\r')
zammad_btocken=$(sed -n 11"p" $fhome"sett.conf" | tr -d '\r')

