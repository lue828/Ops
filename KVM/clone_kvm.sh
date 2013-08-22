#!/bin/bash

#vm_name=$1
#vm_ip=$2
#vm_mask=$3
#vm_gw=$4
#hostname=$5

read -p "Please enter vm name:" vm_name
read -p "Please enter vm ip:" vm_ip
read -p "Please enter vm mask:" vm_mask
read -p "Please enter vm gateway:" vm_gw
read -p "Please enter vm hostname:" hostname

#Download vm template
if [ ! -d /services/vms ]
then
    mkdir -p /services/vms
fi

if [ ! -f /services/vms/Optimad.img ]
then
    wget http://puppet.madhouse.cn/Optimad.img.bz2 -O /services/vms/Optimad.img.bz2
    bzip2 -d /services/vms/Optimad.img.bz2
fi

if [ ! -f /services/vms/Optimad.xml ]
then
    wget http://puppet.madhouse.cn/Optimad.xml -O /etc/libvirt/qemu/Optimad.xml
fi

#Define vm template.
virsh define /etc/libvirt/qemu/Optimad.xml

#Clone vm from template.
virt-clone -o Optimad -n ${vm_name} -f /services/vms/${vm_name}.img

#Config ip address
#1��ɾ�� /etc/udev/rules.d/70-persistent-net.rules�ļ�����������ֵ��
#2������ģ���ļ���ifcfg-eth0�ļ���ONBOOT=yes��BOOTPROTO=static.ɾ��HWADDR��UUID�����С�
#3����Ҫ��ģ���ļ���ifcfg-eth0�ļ������IPADDR=��NETMASK=��GATEWAY=���У���Ӧ��ֵ������㶨��.

virt-edit -d ${vm_name} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s/IPADDR=.*/IPADDR=${vm_ip}/"
virt-edit -d ${vm_name} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s/NETMASK=.*/NETMASK=${vm_mask}/"
virt-edit -d ${vm_name} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s/GATEWAY=.*/GATEWAY=${vm_gw}/"

#Config hostname.
virt-edit -d ${vm_name} /etc/sysconfig/network -e "s/HOSTNAME=.*/HOSTNAME=${hostname}/"

#Start vm.
virsh start ${vm_name}

#Config autostart.
virsh autostart ${vm_name}

#Display all vm.
virsh list --all