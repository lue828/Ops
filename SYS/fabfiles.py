#!/usr/bin/env python

import getpass
from fabric.api import *
from fabric.colors import *
from fabric.context_managers import *

passwd = getpass.getpass('Enter password: ')

env.hosts=['172.16.27.68']
env.roledefs={'namenode':['172.16.26.202', '172.16.26.203'],
              'datanode':['172.16.26.204', '172.16.26.205'],
             }

env.passwords = {'lue@172.16.27.202:22':'passwd',
                 'lue@172.16.27.203:22':'passwd',                 
                }

env.username='lue'
env.password=passwd
#env.password='madhouse'
#env.shell = '/bin/csh -c'
#env.sudo_prefix = '/usr/local/bin/sudo'
#env.sudo_prompt = 'Password:'

@roles('namenode')
@parallel
def task1():
    with cd('/home/lue'):
        run('touch hahaha.txt')
        run('echo "hahaha" > hahaha.txt')
    run('cat /home/lue/hahaha.txt')
    sudo('service sshd restart')

@roles('datanode')
def task2():
    print(green("I'm fabric"))

def task3():
    open_shell()

@hosts('172.16.26.202', '172.16.26.203')
def task4(cmd):
    #Usage: fab -f fabfiles.py task4:cmd="ifconfig eth0 | grep 'inet addr' | sed 's/:/ /g' | awk '{print \$3}'" 
    #print(green("I'm fabric"))
    run('%s' % cmd)

@hosts('172.16.26.202')
def upload():
    local('tar cvzf distlogs.tar.gz ./distlogs/*')
    put('distlogs.tar.gz', '/tmp/')
    with cd('/tmp'):
        run('tar zvxf distlogs.tar.gz')
        run('ls -lrth distlogs')
        run('rm -rvf distlogs')

def nginx_start():
    ''' nginx start '''
    sudo('/etc/init.d/nginx start')

def deploy():
    execute(task1)
    execute(task2)
    execute(task3)
    execute(upload)