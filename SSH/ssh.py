#!/usr/bin/env python
#-*-coding:utf-8-*-
#Author: by lue
#Time: 2013-06-24

import os
import paramiko

#host='192.168.122.10'
host='172.16.27.6'
user='madhouse'
pwd='madhouse'
cmd='pwd;df -h'
         
if __name__=='__main__':    
    paramiko.util.log_to_file('paramiko.log')    
    s=paramiko.SSHClient()     
    s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
#Use ssh key login    
#    privatekeyfile = os.path.expanduser('~/.ssh/id_rsa')
#    sshkey = paramiko.RSAKey.from_private_key_file(privatekeyfile)
#If ssh key have a password
#    sshkey = paramiko.RSAKey.from_private_key_file(privatekeyfile,password='12345678')
#    s.connect('192.168.1.2', username = 'vinod', pkey = sshkey)
    s.connect(host,username=user, password=pwd)    
    stdin,stdout,stderr=s.exec_command(cmd)    
    print stdout.readline()
    print stderr.readline()
    s.close()
