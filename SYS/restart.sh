#!/bin/sh

WARN=15
DANGER=18
LOAD=`uptime | awk '{print $(NF-2)}' | sed 's/,//'`

echo $(date +"%y-%m-%d") `uptime`
if [ `echo "$LOAD > $MAX"|bc` -eq 1 ]
then
    pkill php
    sleep 10
    /usr/local/etc/rc.d/phpfpm start
fi

if [ `pgrep redis | wc -l` -le 0 ]
then
    chown -R redis:redis /var/log/redis
    /usr/local/etc/rc.d/redis start
fi

if [ `pgrep mysql | wc -l` -le 0 ]
then
    /usr/local/etc/rc.d/mysql start
fi

if [ `pgrep memcache | wc -l` -le 0 ]
then
    /usr/local/etc/rc.d/memcached start
fi