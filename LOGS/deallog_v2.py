#!/usr/bin/env python
#-*- coding:utf-8 -*-

import re
import MySQLdb
import datetime
from ftplib import FTP

#Yesterday's date.
now_time = datetime.datetime.now()
yes_time = now_time + datetime.timedelta(days=-1)
dt = yes_time.strftime("%g%m%d")

def ftpdown():  
    ftphost = '172.16.30.217'  
    ftpuser = 'smlog'  
    ftppass = 'smlog'  
    filename = 'SmartMAD2_error_%s.log' %dt
    localpath = './SmartMAD2_error_%s.log' %dt  
    bufsize = 1024
    ftp=FTP()  
    ftp.connect(ftphost,21) 
    ftp.login(ftpuser,ftppass)
    fp = open(localpath,'wb')
    ftp.retrbinary('RETR ' + filename,fp.write,bufsize)
    fp.close()  
    ftp.quit()

def mysqlconn(dt, pe, dmod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua):
    dbhost = 'localhost'
    dbuser = 'ops'
    dbpass = 'madhouse'
    dbname = 'madhouse'
    conn = MySQLdb.connect(host=dbhost, user=dbuser, passwd=dbpass, db=dbname, charset='utf8')
    cur = conn.cursor()
    sql = "insert into deallog_deallog(`dt`, `pe`, `dmod`, `dos`, `osv`, `cpu`, `ram`, `rom`, `jb`, `de`, `apn`, `av`, `mem`, `pv`, `ua`) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
    cur.execute(sql, (dt, pe, dmod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua))
    conn.commit()
    cur.close()
    conn.close()

def logformat(log):
    l = log.replace('%20',' ').replace('%21','!').replace('%22','"').replace('%23','#').replace('%24','$').replace('%25','%').replace('%26','&').replace('%27','\'').replace('%28','(').replace('%29',')').replace('%2A','*').replace('%2B','+').replace('%2C',',').replace('%2D','-').replace('%2E','.').replace('%2F','/').replace('%5B','[').replace('%5C','\\').replace('%5D',']').replace('%5E','^').replace('%5F','_').replace('%3A',':').replace('%3B',';').replace('%3C','<').replace('%3D','=').replace('%3E','>').replace('%3F','?').replace('%40','@').replace('%0D%0A','<br/>').replace('%0D','<br/>').replace('%0A','<br/>')
    return l


def deallog():
    ftpdown()
    log_file = 'SmartMAD2_error_%s.log' %dt
    f = open(log_file)

    for log in f:
        line = logformat(log)

        rpe= re.compile(r'pe=.*').findall(line)
        if rpe:
            for e in rpe:
                pe = e.split('&')[0].split('pe=')[1].split()[0]
        else:
            pe = None

        rmod = re.compile(r'mod=.*').findall(line)
        if rmod:
            for m in rmod:
                dmod = m.split('&')[0].split('mod=')[1]
        else:
            dmod = None
        
        ros = re.compile(r'os=.*').findall(line)
        if ros:
            for s in ros:
                dos = s.split('&')[0].split('os=')[1]
        else:
            dos = None 
        
        rosv = re.compile(r'osv=.*').findall(line)
        if rosv:
            for v in rosv:
                osv = v.split('&')[0].split('osv=')[1]
        else:
            osv = None
        
        rcpu = re.compile(r'cpu=.*').findall(line)
        if rcpu:
            for u in rcpu:
                cpu = u.split('&')[0].split('cpu=')[1]
        else:
            cpu = None
        
        rram = re.compile(r'ram=.*').findall(line)
        if rram:
            for am in rram:
                ram = am.split('&')[0].split('ram=')[1]
        else:
            ram = None

        rrom = re.compile(r'rom=.*').findall(line)
        if rrom:
            for om in rrom:
                rom = om.split('&')[0].split('rom=')[1]
        else:
            rom = None
        
        rjb = re.compile(r'jb=.*').findall(line)
        if rjb:
            for b in rjb:
                jb = b.split('&')[0].split('jb=')[1]
        else:
            jb = None
   
        rde = re.compile(r'de=.*').findall(line)
        if rde:
            for d in rde:
                de = d.split('&')[0].split('de=')[1]
        else:
            de = None
    
        rapn = re.compile(r'apn=.*').findall(line)
        if rapn:
            for pn in rapn:
                apn = pn.split('&')[0].split('apn=')[1]
        else:
            apn = None

        rav = re.compile(r'av=.*').findall(line)
        if rav:
            for a in rav:
                 av = a.split('&')[0].split('av=')[1]
        else:
            av = None

        rmem = re.compile(r'mem=.*').findall(line)
        if rmem:
            for em in rmem:
                 mem = em.split('&')[0].split('mem=')[1]
        else:
            mem = None
        
        rpv = re.compile(r'pv=.*').findall(line)
        if rpv:
            for p in rpv:
                pv = p.split('&')[0].split('pv=')[1].split()[0]
        else:
            pv = None

        rua = re.compile(r'ua=.*').findall(line)
        if rua:
            for u in rua:
                ua = u.split('&')[0].split('ua=')[1]
        else:
            ua = None

        #Insert into database. 
        mysqlconn(dt, pe, dmod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua)
        
deallog()