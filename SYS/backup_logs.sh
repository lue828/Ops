#!/usr/local/bin/bash
src=10.10.8
dest=220.189.221.51
dir=/services/http_logs
storage=datan01

for i in 91 92 93 94 95 96 97 98 237 238 239 240 241
do
    echo "IP:"${src}.${i}
    #To detect the directory exists
    ssh -p 40109 -o StrictHostKeyChecking=no madhouse@${dest} "if [ ! -d /${storage}/backup/${src}.${i}${dir} ];then 'Directory is not exist, and by created.';mkdir -p /${storage}/backup/${src}.${i}${dir};else echo 'Directory is exist, and syncing';fi"

    #Rsync data to a backup server
    ssh -o StrictHostKeychecking=no madhouse@${src}.${i} "/usr/local/bin/rsync -avzP --exclude "*.log" -e 'ssh -o UserKnownHostsFile=/dev/null,StrictHostKeyChecking=no' -e 'ssh -p 40109 ' ${dir}/  madhouse@${dest}:/${storage}/backup/${src}.${i}${dir}/"

    #Delete files before 10 days
    if [ $? -eq 0 ]
    then
        ssh -o StrictHostKeyChecking=no madhouse@${src}.${i} "sudo find $dir/ -ctime +10 -type f -exec rm {} \;"
    fi
done


#rsync -avzP --remove-source-files 可以删除源文件 