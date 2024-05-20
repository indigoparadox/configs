#!/bin/bash

NG_URL="$1"
NG_PWD="`keyring get "$NG_URL" admin`"

if [ -z "$3" ]; then
   echo "usage: $0 <url> <port_number> [on|off]"
   exit 1
fi

if [ "on" = "$3" ]; then
   NG_POE_METHOD="POST"
   NG_POE_MODE="Enable"
elif [ "off" = "$3" ]; then
   NG_POE_METHOD="POST"
   NG_POE_MODE="Disable"
elif [ "status" = "$3" ]; then
   NG_POE_METHOD="GET"
fi
NG_POE_PORT="g$2"

NG_COOKIE="`curl -s -X POST \
   --data-urlencode "pwd=$NG_PWD" \
   -d "login.x=0" \
   -d "login.y=0" \
   -d "err_flag=0" \
   -d "err_msg=" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -c - \
   -o /dev/null \
   $NG_URL/base/main_login.html`"

#echo "$NG_COOKIE"

if [ "$NG_POE_METHOD" = "POST" ]; then
   # Perform login, then set power for port.
   NG_RESPONSE="`
   echo "$NG_COOKIE" | curl -s -X POST \
      -d "unit_no=1" \
      -d "java_port=" \
      -d "inputBox_interface1=" \
      -d "poeAdminMode=$NG_POE_MODE" \
      -d "poePriority=Low" \
      -d "poeDetectionMode=IEEEOnly_4Point" \
      -d "poe_timer_ctrl_list=1" \
      -d "poePowerLimitType=Class" \
      -d "poePowerLimit=15400" \
      -d "CBox_1=checkbox" \
      -d "inputBox_interface2=" \
      -d "err_flag=0" \
      -d "err_msg=" \
      -d "multiple_ports=0" \
      --data-urlencode "selectedPorts=$NG_POE_PORT;" \
      -d "submt=16" \
      -d "refrsh=" \
      -d "click_sched=" \
      -d "sched_id=" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -b - \
      -o /dev/null \
      -w "%{http_code}" \
      $NG_URL/base/poe/poe_port_cfg.html`"

   # Report success or failure based on HTTP response.
   if [ "200" = "$NG_RESPONSE" ]; then
      echo "Succeeded"
   else
      echo "Failed"
   fi

else
   # Perform login, then grab POE status page and filter for port.
   echo "$NG_COOKIE" | curl -s -X GET \
      -b - -o - \
      $NG_URL/base/poe/poe_port_cfg.html | \
   grep ">$NG_POE_PORT<" | sed 's/.*\(Enable\|Disable\).*/\1/g'

fi

# Logout of HTTP session.
echo "$NG_COOKIE" | curl -s -X GET \
   -b - -o /dev/null \
   $NG_URL/base/main_login.html

