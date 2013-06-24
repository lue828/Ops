#!/usr/bin/env python
#-*-coding:utf-8-*-
#Author: by lue
#Time: 2013-06-24

import paramiko
    
hostname='192.168.122.10'
username='lue'
password='1iu1u3724'
         
if __name__=='__main__':    
        paramiko.util.log_to_file('paramiko.log')    
        s=paramiko.SSHClient()     
        s.set_missing_host_key_policy(paramiko.AutoAddPolicy())    
        s.connect(hostname = hostname,username=username, password=password)    
        stdin,stdout,stderr=s.exec_command('ifconfig;free;df -h')    
        print stdout.read()    
        s.close()
