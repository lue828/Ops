#!/bin/bash

#Usage: ./curl_time.sh | awk '{if($3 == 000 || $4 > 10)print $0}'

#echo "time	http_code	time_connnect	time_starttransfre	time_total" >> curl_time.log
#while sleep 5;do echo "`date "+%Y:%m:%d %H:%M:%S"``curl -o /dev/null -s -w "\t%{http_code}\t%{time_connect}\t%{time_starttransfer}\t%{time_total}\t" "http://cms.optimad.cn"`" >> curl_time.log;done

hostname=114.80.118.86

while sleep 1;do echo "`date "+%Y:%m:%d %H:%M:%S"``curl -o /dev/null -s -w "\t%{http_code}\t%{time_connect}\t%{time_starttransfer}\t%{time_total}\t" -H "Host:dist.sigmad.net" "http://${hostname}/services/transferSendClk?Y2FtcGFpZ25faWQ9NWF2Q0FsV01BWW1mck9IMCZjaGFubmVsX2lkPTAwMDAxJnRhcmdldD1hSFIwY0RvdkwzZDNkeTVpWVdsa2RTNWpiMjA9"`";done