#!/bin/bash

v=`grep -E -o 'vmx|svm' /proc/cpuinfo | uniq`
ip=172.16.27.85
mask=255.255.255.224
gw=172.16.27.94
int=eth0
br=br0
vm_name=test
vm_ip=172.16.27.68

#read -p "Enter a ip address:" ip

if [ ${v} == vmx ]
then
    #Set host
    echo '172.16.27.78 puppet.madhouse.cn' >> /etc/hosts

    #Disabled selinux
    sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

    #Install virtual component
    yum -y groupinstall 'Virtualization' 'Virtualization Client' 'Virtualization Platform' 'Virtualization Tools'
    yum -y install bridge-utils libguestfs-tools-c wget vim

    #Set autostart
    service libvirtd start
    chkconfig libvirtd on
    
    #Create bridge
    cat << EOF > /etc/sysconfig/network-scripts/ifcfg-${br}
DEVICE="${br}"
NM_CONTROLLED="yes"
ONBOOT=yes
TYPE=Bridge
BOOTPROTO=static
IPADDR=${ip}
NETMASK=${mask}
GATEWAY=${gw}
DNS1=8.8.8.8
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
NAME="${br}"
EOF

    cat << EOF > /etc/sysconfig/network-scripts/ifcfg-${int}
DEVICE="${int}"
NM_CONTROLLED="yes"
ONBOOT="yes"
BRIDGE="${br}"
EOF

    #Restart network service
    service network restart

else
    echo "Please enable virtualization in bios."
    exit 0
fi


#Download vm template
if [ ! -f /services/vms/Optimad.img ]
then
    wget http://puppet.madhouse.cn/Optimad.img.bz2 -O /services/vms/Optimad.img.bz2
    bzip2 -d /services/vms/Optimad.img.bz2
fi

if [ ! -f /services/vms/Optimad.xml ]
then
    wget http://puppet.madhouse.cn/Optimad.xml -O /etc/libvirt/qemu/Optimad.xml
fi

#Clone vm from template.
virt-clone -o Optimad -n ${vm_name} -f /services/vms/${vm_name}.img

#If config hava IPADDR,then replace
#virt-edit -d ${vm_name} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s/IPADDR=.*/IPADDR=${vm_ip}/"

#virt-edit -d test /etc/sysconfig/network-scripts/ifcfg-eth0 -e '$_="" if /^HWADDR.*/'
#virt-edit -d ${vm_name} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s/ONBOOT=no/ONBOOT=yes/"
#virt-edit -d ${vm_name} /etc/sysconfig/network-scripts/ifcfg-eth0 -e "s/BOOTPROTO=dhcp/BOOTPROTO=static/"

#virt-edit -d test /etc/udev/rules.d/70-persistent-net.rules -e '$_="" if /^# PCI.*/'
#virt-edit -d test /etc/udev/rules.d/70-persistent-net.rules -e '$_="" if /^SUBSYSTEM.*/'

#virt-edit -d test /etc/sysconfig/network-scripts/ifcfg-eth0 -e '$_="BOOTPROTO=static\nIPADDR=172.16.27.68\nNETMASK=255.255.255.224\nGATEWAY=172.16.27.94" if /^BOOTPROTO.*(\r?\n)?$/'

virsh start ${vm_name}