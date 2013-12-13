#!/bin/sh

hostname=`hostname`
hostip=`ifconfig | egrep "inet 10.10.8|inet 172.16.3" | awk 'NR==1{print $2}'`
jid=`jls | awk 'NR>1{print $1}' | tr "\n" " ";echo`
user=test
pass=madhouse

echo ${hostname} > ${hostip}.jail
for id in ${jid}
do
    host=`jexec ${id} hostname`
    ip=`jexec ${id} ifconfig | egrep "inet 10.10.8|inet 172.16.3" | awk 'NR==1{print $2}'`
    echo "${id} ${ip} ${host}"| column -t | tee -a ${hostip}.jail

    echo ${pass} | jexec ${id} pw mod user ${user} -h 0 -s /bin/sh
    if [ $? -ne 0 ]
    then
        echo ${pass} | jexec ${id} pw add user ${user} -h 0 -m -s /bin/sh
	jexec ${id} pw groupmod wheel -m ${user}
    fi
done