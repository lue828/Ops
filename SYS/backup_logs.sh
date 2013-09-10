#!/bin/bash
src=172.16.27
dest=172.16.27.6
dport=22
dir=/home/madhouse/
storage=services

for i in 88
do
    echo "IP:"${src}.${i}
    #To detect the directory exists
    ssh -o StrictHostKeyChecking=no -p ${dport} madhouse@${dest} "if [ ! -d /${storage}/backup/${src}.${i}${dir} ];then echo 'Directory is not exist, and by created.';mkdir -p /${storage}/backup/${src}.${i}${dir};else echo 'Directory is exist, and syncing';fi"

    #Rsync data to a backup server
    ssh -o StrictHostKeyChecking=no madhouse@${src}.${i} "/usr/local/bin/rsync -avzP --exclude "*.log" -e 'ssh -o StrictHostKeyChecking=no -p 22' ${dir}/*  madhouse@${dest}:/${storage}/backup/${src}.${i}${dir}/"

    #Delete files before 10 days
    #Delete source files 
    #rsync -avzP --remove-source-files
    if [ $? -eq 0 ]
    then
        ssh -o StrictHostKeyChecking=no madhouse@${src}.${i} "sudo find $dir/ -ctime +10 -type f -exec rm {} \;"
    fi
done


#rsync -avzP --remove-source-files 可以删除源文件 