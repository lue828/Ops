#!/bin/bash

echo `curl iframe.ip138.com/ic.asp | awk -F '<center>|</center>' '{print $2}'` > curl_time.log
echo "time	http_code	time_connnect	time_starttransfre	time_total" >> curl_time.log

while sleep 5;do echo "`date "+%Y:%m:%d %H:%M:%S"``curl -o /dev/null -s -w "\t%{http_code}\t%{time_connect}\t%{time_starttransfer}\t%{time_total}\t" "http://cms.optimad.cn"`" >> curl_time.log;done