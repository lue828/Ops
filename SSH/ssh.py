#!/usr/bin/env python
#-*-coding:utf-8-*-
#Author: by lue
#Time: 2013-06-24

import paramiko
    
host='192.168.122.10'
user='lue'
pwd='123456'
cmd='sudo ifconfig;df -h'
         
if __name__=='__main__':    
    paramiko.util.log_to_file('paramiko.log')    
    s=paramiko.SSHClient()     
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())    
    s.connect(host,username=user, password=pwd)    
    stdin,stdout,stderr=s.exec_command(cmd)    
    print stdout.read()    
    s.close()
