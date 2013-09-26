#!/usr/bin/env python
#****************************************************************#
# ScriptName: file_seek.py
# Author: Lue
# Create Date: 2013-09-23 17:30
# Modify Author: Lue
# Modify Date: 2013-09-23 17:30
# Function: 
#***************************************************************#
import sys
import time
 
files='/var/log/secure'

def get_file_end(files="/var/log/secure"):
    f=file(files,'r')
    f.seek(0,2)
    file_size=f.tell()
    f.close()
    return file_size


def get_content(files,file_size,last_file_size):
    f=file(files,'r')
    f.seek(last_file_size,0)
    lines=f.readlines()
    for line in lines:
#        if line.lower().startswith('Sep'):
#            print line
        print line,
    f.close()
 
 
file_size=get_file_end()
last_file_size=file_size
while True:
    file_size=get_file_end()
    if(file_size>last_file_size):
#        print "size is change"
        get_content(files,file_size,last_file_size)
    else:
        print "size is not change"
     
    last_file_size=file_size
    print "time to sleep"
    time.sleep(5)