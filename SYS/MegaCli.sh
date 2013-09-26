#!/bin/bash
#check Raid card vd and pd state
HOSTNAME=`/bin/hostname`
CARD=`/opt/MegaRAID/MegaCli/MegaCli64  -adpallinfo -a0 | grep "Product Name" | cut -d ':' -f2`
VDSTATE1=`/opt/MegaRAID/MegaCli/MegaCli64 -cfgdsply -aALL | grep "State"`
VDSTATE2=`/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep "Degraded" | sed 's/  //'`
VDSTATE3=`/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep "  Offline" | sed 's/  //'`
PDSTATE1=`/opt/MegaRAID/MegaCli/MegaCli64 -cfgdsply -aALL | grep "Online" | wc -l | sed 's/        //'`
PDSTATE2=`/opt/MegaRAID/MegaCli/MegaCli64 -cfgdsply -aALL | grep "Rebuild" | wc -l | sed 's/       //'`
PDSTATE3=`/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep "Critical Disks" | sed 's/  //'`
PDSTATE4=`/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep "Disks" | sed 's/  //'`
PDSTATE5=`/opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -aALL | grep "Virtual"`
echo "############# Host Information ##############"
echo "Host         : $HOSTNAME"
echo "Raid Card    : $CARD"
echo ''''
echo "############ Virtual Disk State #############"
echo "VD Number: $PDSTATE5"
echo "Virtual Disk $VDSTATE1"
echo "$VDSTATE2"
echo "$VDSTATE3"
echo ""
echo "############ VD Disk State ##################"
echo "Online Disk        : $PDSTATE1"
echo "Rebuild Disk       : $PDSTATE2"
echo "$PDSTATE3"
echo ""
echo "############ Physical Disks State #############"
echo "$PDSTATE4"