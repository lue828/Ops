#! /usr/bin/env bash
#version=1.1
#1.1 add MediaError
#1.2 add mpt msg 
unknow=3
ok=0
warning=1
critical=2
exitstatus=$unknow
host=""
msg=""
raid_type=""
megacli="/opt/MegaRAID/MegaCli/MegaCli"
mpt="/usr/alisys/dragoon/libexec/raidtool/mpt-status"
hpacucli="/usr/sbin/hpacucli"
megarc="/usr/alisys/dragoon/libexec/raidtool/megarc.bin"
smartctl="/usr/sbin/smartctl"
os_type_fun(){
        os_type=`uname -s`
}
smart_fun(){
        disk=`ls /dev/rdsk/`
}
is_vm(){
        if test -f /proc/xen/capabilities;then
                grep -iq control_d /proc/xen/capabilities
                if test $? -eq 0;then
                        exitstatus=0
                        return
                else
                        echo "this host is xen host"
                        exit 0
                fi
        else
                exitstatus=0
        fi
# /usr/sbin/dmidecode 2>/dev/null|grep -qi Vendor 
# if [ $? -eq 1 ];then
# echo " this host is xen host"
# exit 0

                fi
        else
                exitstatus=0
        fi
# /usr/sbin/dmidecode 2>/dev/null|grep -qi Vendor 
# if [ $? -eq 1 ];then
# echo " this host is xen host"
# exit 0
# else
# exitstatus=0
# fi
}
read_write(){
        exitstatus=$unknow
        rm -rf test.txt
        touch test.txt > /dev/null
        if [ -r test.txt -a -w test.txt ];then
                msg="$msg disk rw is ok"
                exitstatus=$ok
        else
                msg="$msg disk rw is error!!"
                exit 2
        fi
}
raid_type(){
        lsmod=`/sbin/lsmod`
        echo $lsmod|egrep -qw "mptsas|mptbase"
        if test $? -eq 0;then
                raidtype="mptSAS"
        fi
        echo $lsmod|egrep -qw "megaraid_mbox|megaraid2"
        if test $? -eq 0;then
                raidtype="megaRAIDSCSI"
        fi
        echo $lsmod|egrep -qw "megaraid_sas"
        if test $? -eq 0;then
                raidtype="megaRAIDSAS"
        fi
        echo $lsmod|egrep -qw "megaraid_sas,mptsas"
        if test $? -eq 0;then
                raidtype="mptSAS"
                if test -c /dev/mptctl;then
                aa="bb"
                else
                mknod /dev/mptctl c 10 220
                fi
                        /sbin/modprobe mptctl
        fi
        lspci|grep -q "Hewlett-Packard"
        if test $? -eq 0;then
                raidtype="hpraid"
        fi
        if [ -z $raidtype ];then
                raidtype="unknow"
        # echo "this host raid is unknow raid"
                return

        fi
}
checkmegasas(){
        exitstatus=$unknow
        if test "$os_type" = "Linux";then
        rpm -aq|grep -q MegaCli-8.00.29-1
        if [ $? -eq 0 ];then
                if [ -e /opt/MegaRAID/MegaCli/MegaCli64 ];then
                        mv /opt/MegaRAID/MegaCli/{MegaCli64,MegaCli}
                fi
        else
                               rpm -Uhv http://10.23.230.161/zds/Lib_Utils-1.00-08.noarch.rpm 
               rpm -Uhv http://10.23.230.161/zds/MegaCli-8.00.29-1.i386.rpm 
               exit 3
        fi
        if test "$os_type" = "SunOS";then
                megacli = '/usr/alisys/dragoon/libexec/raidtool/MegaCli_sol'
        fi
                ctrlCount=`$megacli -adpCount|grep -i "Controller Count"|sed 's/.*:.*\([0-9]\)\./\1/'`
                if test $ctrlCount -eq 0;then
                         diskname=`awk '{print $NF}' /proc/partitions |grep sd|grep -v ssd|grep -v "[0-9]\+"`
                        for t in $diskname
                        do
                                $smartctl -H /dev/$t|egrep -iq "not an ATA/ATAPI device|Input/output error"
                                if test $? -ne 0;then
                                        $smartctl -H /dev/$t|egrep -iq "ok|PASSED"
                                        if test $? -ne 0;then
                                         exitstatus=$critical
                                        msg="$msg smartctl check disk $t is fail!"
                                        return
                                else
                                        exitstatus=$ok
                                        msg="$msg Smartctl: Device Read Identity Failed"
                                        return
                                fi
                                else
                                        exitstatus=$ok
                                        msg="$msg Smartctl: Device Read Identity Failed"
                                        return
                                fi
                        done
                fi
                i=0
                j=0
                        $megacli -AdpAllInfo -aall|grep -i bbu|head -n 1|egrep -iq "Present|absent|not Present"
                        if test $? -ne 0;then
                                badbbustatus=`$megacli -AdpAllInfo -a0|grep -i bbu|head -n 1|sed 's/.*:\(.*\)/\1/'`
                                        exitstatus=$critical
                                        msg="$msg raid bbu status is $badbbustatus!"
                                        return
                        fi
# bbustatus=`$megacli -AdpAllInfo -aall|grep -i bbu|head -n 1|sed 's/.*: \(.*\)/\1/' `
# if test $bbustatus = "Present";then
# capacity=`$megacli -AdpBbuCmd -getbbucapacityinfo -aall|grep "Remaining Capacity:"|sed -e 's/.* \([0-9]*\) .*/\1/g'`
# if test $capacity -lt 50;then
# exitstatus=$critical
# msg="$msg DELL bbu Remaining Capacity is $capacity low!"
# return
# fi
# fi

                while test $i -lt $ctrlCount
                do
                        #i=$(($i+1))
                        NUM_DEGRADED=`$megacli -AdpAllInfo -a$i |grep "Degrade"|cut -d: -f2|tr -d ' '`
                        NUM_FAILED=`$megacli -AdpAllInfo -a$i |grep "Failed Disks"|cut -d: -f2|tr -d ' '`
                        NUM_Critical=`$megacli -AdpAllInfo -a$i |grep "Critical Disks"|cut -d: -f2|tr -d ' '`
                        NUM_Offline=`$megacli -AdpAllInfo -a0 |grep "Offline.*:.*[0-9]"|cut -d: -f2|tr -d " "`
                        MediaError=`$megacli PdList -a$i|grep -i "Media Error Count"|awk '{ print $4 }'`
                        for u in $MediaError
                        do
                                if test $u -ge 100;then
                                        MediaErrorcount=$u
                                        MediaErrornumber=`$megacli -PdList -a$i|grep -i "Media Error Count"|grep -n "$u"|awk -F: '{ print $1 }'`
                                        msg="$msg MediaError disk number is $MediaErrornumber ,Media Error Count is $u ,"
                                        break
                                fi
                        done
                        #error=`$megacli -AdpAllInfo -a0| grep -i "Device Present" -A 12|egrep -i "Degraded|Offline|Critical Disks|Failed disks"|awk -F: '{ print $2 }'`
                        #for r in $error
                        #do
                        # if test $r -ne 0;then
                        # msg=`$megacli -AdpAllInfo -a0| grep -i "Device Present" -A 12`
                        # exitstatus=$critical
                        # return
                        # fi
                        #done
                        if [[ "$NUM_DEGRADED" -ne 0 || "$NUM_FAILED" -ne 0 || "$NUM_Critical" -ne 0 || "$NUM_Offline" -ne 0 || "$MediaErrorcount" -ge 100 ]]; then
                                msg="$msg ctrl $ctrlCount:$NUM_DEGRADED VD degraded,$NUM_Offline VD offilne, $NUM_FAILED PD failed ,$NUM_Critical PD Critical"
                                exitstatus=$critical
                                return
                        fi
                        LD_NUM=`$megacli -LdGetNum -a$i|grep -i 'Number of Virtual'|cut -d: -f2|tr -d " "`
                        #for((j=0;j<$LD_NUM;j++))
                        #j=0
                        while test $j -lt $LD_NUM
                        do
                                #$j=$(($j+1))
                                readlevel=`$megacli -LdInfo -L$j -a$i|grep -i "RAID Level" |grep -o "Primary-[0-9]"|cut -d- -f2`
                                ldstatus=`$megacli -LdInfo -L$j -a$i|grep -i "State"|cut -d: -f 2|tr -d ' '`
                                disknumber=`$megacli -pdlist -a$i|grep -i "Slot Number"|wc -l`
                                if [ $ldstatus != "Optimal" ];then
                                        msg="$msg megacli -LdInfo is critical!"
                                        exitstatus=$critical
                                        return
                                fi
                                onlinenu=`$megacli -PdList -a$i|grep -i "Firmware state:"|egrep -i "online|Hotspare|good"|wc -l`
                                if [ $disknumber -ne $onlinenu ];then
                                        errordisknumber=`$megacli -pdlist -a$i|grep "Firmware state"|grep -nvi "online"|awk -F: '{print $1}'`
                                        msg="$msg this host total have $disknumber disks,raidlevel $readlevel,failed disk number is $errordisknumber"
                                        exitstatus=$critical
                                else
                                        exitstatus=$ok
                                # msg="$msg this host raidlevel is $readlevel,total disk $disknumber,online disk is $onlinenu"
                                fi
                                j=`expr $j + 1`

                        done
                        i=`expr $i + 1`
                done
                msg="$msg this host raidlevel is $readlevel,total disk $disknumber,online disk is $onlinenu"

        #else
        # rpm -Uhv http://10.23.230.161/zds/Lib_Utils-1.00-08.noarch.rpm 
        # rpm -Uhv http://10.23.230.161/zds/MegaCli-8.00.29-1.i386.rpm 
        fi
}
check_log(){
        now_date=`date +"%b %d" |sed -e 's/\([^0]\+\)0\(.*\)/\1 \2/'`
        yester_date=`date --date "1 days ago" +"%b %d" |sed -e 's/\([^0]\+\)0\(.*\)/\1 \2/'`
        logsize=`du -m /var/log/messages |awk '{print $1}'`
        if test $logsize -ge 100;then
                exitstatus=$ok
                msg="$msg /var/log/message too big!!"
                return
        else
                errorlog=`egrep -i "$now_date|$yester_date" /var/log/messages|egrep -i "offline|medium|I/O error.*"`
                if test -n $errorlog;then
                        exitstatus=$ok
                else
                        errorcount=`egrep -i "$now_date|$yester_date" /var/log/messages|egrep -i "offline|medium|I/O error.*"|wc -l`
                        if test $errorcount -ge 10;then
                        exitstatus=$critical
                        msg="$msg $errorlog"
                        return
                        else
                                exitstatus=$ok
                        fi
                fi
        fi

}
check_sunlog(){
        now_date=`date +"%b %d" |sed -e 's/\([^0]\+\)0\(.*\)/\1 \2/'`
        logsizesun=`du -k /var/adm/messages|awk '{print $1}'`
        if test $logsizesun -ge 434400;then
                exitstatus=$ok
                msg="$msg /var/adm/messages too big !!"
                return
        else
                        errorcountsun=`egrep -i "$now_date" /var/adm/messages|egrep -i "offline|medium|I/O error."|wc -l`
                        if test $errorcountsun -ge 10;then
                        exitstatus=$critical
                        msg="$msg $errorlog2"
                        return
                        else
                                 exitstatus=$ok
                                msg="$msg all disk is ok!"
                        return
                        fi
        fi
}
hpraidcheck(){
        exitstatus=$unknow
    rpm -aq|grep -qi hpacucli-8
    if test $? -eq 0 ;then
        Slotnu=`$hpacucli ctrl all show status|grep -i "Smart Array"|cut -d" " -f6`
        ctrlstatus=`$hpacucli ctrl all show status|grep -i "Controller Status"|cut -d: -f2|tr -d ' '`
        if test "$ctrlstatus" != "OK";then
            exitstatus=$critical
            msg="$msg Controller Status:$ctrlstatus"
            return
        fi
        for l in $Slotnu
        do
            raidlevel=`$hpacucli ctrl slot=$l show config|grep -i logicaldrive|sed -e "s/^ * //g" -e "s/,//g"|cut -d" " -f6`
            totaldisknu=`$hpacucli ctrl slot=$l show config|grep -c physicaldrive`
            onlinedisknu=`$hpacucli ctrl slot=$l show config|grep physicaldrive|grep -ic ok`
            if test $totaldisknu -eq $onlinedisknu;then
                msg="$msg this host raidlevel is $raidlevel,total disk is $totaldisknu,all disk is ok"
                exitstatus=$ok
            else
                errordisk=`expr $totaldisknu - $onlinedisknu`
                errordiskhpnumber=`$hpacucli ctrl slot=$l show config|grep -i "physicaldrive"|grep -inv "ok"|awk -F: '{ print $1 }'`
                #msg="$msg this host raidlevel is $raidlevel,total disk is $totaldisknu,fail disk is $errordisk,number $errordiskhpnumber is fail!"
                msg="$msg this host total have $totaldisknu disks,raidlevel $raidlevel,failed disk number is $errordiskhpnumber"
                exitstatus=$critical
                return
            fi

                hpacucli ctrl slot=${l} show status|grep -i "Battery"
                if test $? -eq 0;then
                        #ba_log=`hpacucli ctrl slot=${i} show status|grep Battery|awk '$NF!~/OK/||$NF!~/Recharging/ {printf ("Battery Status is %s", $3) }'`
                        $hpacucli ctrl slot=${l} show status|grep -i Battery|egrep -iq "OK|Recharging"
                        if test $? -ne 0 ;then
                                exitstatus=$critical
                                bbuhpstatus=`$hpacucli ctrl slot=${l} show status|grep -i Battery|sed 's/.*:\(.*\)/\1/'`
                                msg="$msg HP Raidcard bbu $bbuhpstatus"
                                return
                        fi

                fi
        done
    else
        rpm -Uhv http://10.23.230.161/zds/hpacucli-8.50-6.0.noarch.rpm 
    fi

}
check_megaRAIDSCSI(){
        exitstatus=$unknow
        failedscsi=0
        non_optimal_arrays=0
        number_arrays=0
        $megarc -AllAdpInfo |grep -q "No Adapters Found"
        if test $? -eq 0;then
                dmidecode |grep -iq 1850
                if test $? -eq 0;then
                echo "$msg this host is dell1850"
                exit 0
                else
                        diskname=`awk '{print $NF}' /proc/partitions |grep sd|grep -v ssd|grep -v "[0-9]\+"`
                        for q in $diskname
                        do
                                $smartctl -H /dev/$q|egrep -iq "not an ATA/ATAPI device|Input/output error"
                                if test $? -ne 0;then
                                        $smartctl -H /dev/$q|egrep -iq "ok|PASSED"
                                        if test $? -ne 0;then
                                                exitstatus=$critical
                                                msg="$msg smartctl check disk $q is fail!"
                                                return
                                        else
                                                exitstatus=$ok
                                                msg="$msg Smartctl: Device Read Identity Failed"
                                        fi
                                else
                                exitstatus=$ok
                                        msg="$msg Smartctl: Device Read Identity Failed"
                                fi
                        done
                fi

        else
                $megarc -dispcfg -a0 |grep -i "Logical Drive.*status"|grep -qi "OPTIMAL"
                if test $? -ne 0;then
                        contstatus=`$megarc -dispcfg -a0 |grep -i "Logical Drive.*status"|sed 's/.*Status: \(.*\)/\1/'`
                        echo "this host raid control is $contstatus"
                        exit 2
                else
                        raidscsilevel=`$megarc -dispcfg -a0 |grep -oi "raidlevel: [0-9]*"`
                        scsidisknu=`$megarc -dispcfg -a0 |grep -c "0x00000000"`
                        scsionlinenu=`$megarc -dispcfg -a0 |grep -c "ONLINE"`
                        if test $scsidisknu -eq $scsionlinenu;then
                                msg="$msg this host $raidscsilevel,total disk is $scsidisknu.all disk is ok!"
                                exitstatus=$ok
                                return
                        else
                                failscsidisk=`expr $scsidisknu - $scsionlinenu`
                                failscsidisknumber=`$megarc -dispcfg -a0 |grep "0x00000"|grep -inv "ONLINE"|awk -F: '{ print $1 }'`
                                #msg="$msg this host $raidscsilevel,total disk is $scsidisknu ,fail disk is $failscsidisk,number $failscsidisknumber is fail!!"
                                msg="$msg this host total have $scsidisknu disks,raillevel $raidscsilevel,failed $failscsidisk,failed disk number is $failscsidisknumber!"
                                exitstatus=$critical
                        fi
                fi
        fi
}
check_mptSAS(){
        if test -e /dev/mptctl;then
        $mpt -p|grep -qi "No such device"
        if test $? -eq 0;then
                checkmegasas
            return
        else
                 $mpt -p|grep -qi "Nothing found"
                if test $? -ne 0;then
            mptnumber=`$mpt -p|grep -o "\-i [0-9]*"`
            disknumber=`$mpt $mptnumber|grep -co "phy [0-9]*"`
            okdiskun=`$mpt $mptnumber|grep -i "phy [0-9]*"|grep -ci "online"`
            if test $disknumber -ne $okdiskun;then
                exitstatus=$critical
                mpterror=`expr $disknumber - $okdiskun`
                errormptum=`$mpt $mptnumber|grep -i "phy [0-9]*"|grep -vin "online"|awk -F: '{ print $1 }'`
                #msg="$msg total disk is $disknumber,fail $mpterror,fail disk number is $errormptum "
                msg="$msg this host total have $disknumber disks,failed $mpterror,fail disk number is $errormptum!"
                return
            else
                $mpt $mptnumber|grep vol|grep -iq "OPTIMAL"
                if test $? -ne 0;then
                    exitstatus=$critical
                        msg=`$mpt $mptnumber`
                    msg="this host volume status is critical! $msg"
                    return
                else
                    exitstatus=$ok
                    msg="$msg this host total disk is $disknumber,all disk is ok"
                fi
            fi
                else
                        diskname=`awk '{print $NF}' /proc/partitions |grep sd|grep -v ssd|grep -v "[0-9]\+"`
                        for m in $diskname
                        do
                                $smartctl -H /dev/$m|egrep -iq "not an ATA/ATAPI device"
                                if test $? -ne 0;then

                                $smartctl -H /dev/$m|egrep -iq "ok|PASSED"
                                if test $? -ne 0;then
                                        exitstatus=$critical
                                        msg="$msg smartctl check disk $m is fail!"
                                        return
                                else
                                        exitstatus=$ok
                                # msg="$msg this host no raid,smartctl check all disk is ok"
                                fi
                                else
                                        exitstatus=$ok
                                        msg="Smartctl: Device Read Identity Failed"
                                fi
                        done
                        if test $exitstatus -eq 0;then
                                 msg=" this host no raid,smartctl check all disk is ok"
                        fi
                fi
        fi
        else
                /sbin/modprobe mptctl
        fi
}
smarctl_check(){
        disknamesmart=`awk '{print $NF}' /proc/partitions |grep sd|grep -v ssd|grep -v "[0-9]\+"`
        for n in $disknamesmart
        do
                $smartctl -H /dev/$n|egrep -iq "not an ATA/ATAPI device"
                if test $? -ne 0;then
                $smartctl -H /dev/$n|egrep -iq "ok|PASSED"
                if test $? -ne 0;then
                        exitstatus=$critical
                         msg="$msg smartctl check disk $n is fail!"
                        return
                else
                        exitstatus=$ok
                        msg="this host no raid,smartctl check all disk is ok"
                fi
                else
                        msg="Smartctl: Device Read Identity Failed "
                        exitstatus=$ok
                fi
        done
}
main_fun(){
        os_type_fun
        if test "$os_type" = "SunOS";then
                check_sunlog
                #checkmegasas()
                if test $exitstatus -eq 2;then
                        echo "$msg"
                        exit $exitstatus
                else
                        echo "$msg "
                        exit $exitstatus
                fi
        elif test "$os_type" = "Linux";then
                #is_vm
                #check_log
        # if test $exitstatus -eq 0;then
                uname -a|grep -iq "2.4"
                if test $? -eq 0;then
                        megacli="/usr/alisys/dragoon/libexec/raidtool/MegaCli"
                fi
                dmidecode |grep -iq "Tecal BH28"
                if test $? -eq 0;then
                        if test -c /dev/mptctl;then
                                aa="bb"
                        else
                         mknod /dev/mptctl c 10 220
                        fi
                        /sbin/modprobe mptctl
                                                check_log
                                if test $exitstatus -eq 2;then
                                        echo $msg
                                        exit $exitstatus
                                fi
                        echo "mptSAS"
                        check_mptSAS
                        echo $msg
                        exit $exitstatus
                fi
                is_vm
                if test $exitstatus -eq 0 ;then
                        raid_type
                        echo $raidtype
                        if test "$raidtype" = "megaRAIDSAS";then
                                check_log
                                if test $exitstatus -eq 2;then
                                        echo $msg
                                        exit $exitstatus
                                fi
                                checkmegasas
                                echo $msg
                                exit $exitstatus
                        elif test "$raidtype" = "hpraid";then
                                check_log
                                if test $exitstatus -eq 2;then
                                        echo $msg
                                        exit $exitstatus
                                fi
                                hpraidcheck
                                echo $msg
                                exit $exitstatus
                        elif test $raidtype = "megaRAIDSCSI";then
                                check_log
                                if test $exitstatus -eq 2;then
                                        echo $msg
                                        exit $exitstatus
                                fi
                                check_megaRAIDSCSI
                                echo $msg
                                exit $exitstatus
                        elif test $raidtype = "mptSAS";then
                                check_log
                                if test $exitstatus -eq 2;then
                                        echo $msg
                                        exit $exitstatus
                                fi
                                check_mptSAS
                                echo $msg
                                exit $exitstatus
                        elif test $raidtype = "unknow";then
                                check_log
                                if test $exitstatus -eq 2;then
                                        echo $msg
                                        exit $exitstatus
                                fi
                                smarctl_check
                                echo $msg
                                exit $exitstatus

                        fi
                fi
                else
                        echo $msg
                        exit $exitstatus
                fi

}
main_fun