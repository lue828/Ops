#!/bin/bash


#ping $1 | awk '{ now=strftime( "%Y-%m-%d %H:%M:%S", systime() ); printf("%s : %s\n",now,$0);fflush();}' >> $1.log

for ip in `seq 206 230`
do 
ping -c 3 211.136.105.${ip} | awk '{ now=strftime( "%Y-%m-%d %H:%M:%S", systime() ); printf("%s : %s\n",now,$0);fflush();}'
done