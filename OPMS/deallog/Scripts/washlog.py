#!/usr/bin/env python
#-*- coding:utf-8 -*-
#author: lue
#time: 2013-08-13

import re
import os
import sys
import MySQLdb
import datetime
from ftplib import FTP

"""Yesterday's date."""
now_time = datetime.datetime.now()
yes_time = now_time + datetime.timedelta(days=-1)
#dt = yes_time.strftime("%g%m%d")
#dt = sys.argv[1] 

#filename = 'SmartMAD2_error_%s.log' %dt

def ftpdown():
    """Download log file from ftp server."""
    ftphost = '172.16.30.217'  
    ftpuser = 'smlog'  
    ftppass = 'smlog'  
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
    sql_report = "insert into deallog_report(`dt`, `pe`, `dmod`, `dos`, `osv`, `cpu`, `ram`, `rom`, `jb`, `de`, `apn`, `av`, `mem`, `pv`, `ua`) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
    sql_deallog = "insert into deallog_deallog(`dt`, `pe`, `dmod`, `dos`, `osv`, `cpu`, `ram`, `rom`, `jb`, `de`, `apn`, `av`, `mem`, `pv`, `ua`) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
    sql_smlog = "insert into deallog_smlog(`dt`, `pe`, `dmod`, `dos`, `osv`, `cpu`, `ram`, `rom`, `jb`, `de`, `apn`, `av`, `mem`, `pv`, `ua`) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"

    conn = MySQLdb.connect(host=dbhost, user=dbuser, passwd=dbpass, db=dbname, charset='utf8')
    cur = conn.cursor()

#    cur.execute("select pe from deallog_deallog where pe=%s", pe)
#    res = cur.fetchall()
#    if len(res) == 0:
#        cur.execute(sql_report, (dt, pe, dmod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua))
#    else:
#        pass

    cur.execute("select pe from deallog_deallog where pe=%s", pe)
    res = cur.fetchall()
    if len(res) == 0:
        cur.execute(sql_deallog, (dt, pe, dmod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua))
    else:
        pass

    conn.commit()
    cur.close()
    conn.close()

def logformat(log):
    """Decode urlcode and Replace models"""
    d = {
        '%20':' ',
        '%21':'!',
        '%22':'"',
        '%23':'#',
        '%24':'$',
        '%25':'%',
        '%26':'&',
        '%27':'\'',
        '%28':'(',
        '%29':')',
        '%2A':'*',
        '%2B':'+',
        '%2C':',',
        '%2D':'-',
        '%2E':'.',
        '%2F':'/',
        '%5B':'[',
        '%5C':'\\',
        '%5D':']',
        '%5E':'^',
        '%5F':'_',
        '%3A':':',
        '%3B':';',
        '%3C':'<',
        '%3D':'=',
        '%3E':'>',
        '%3F':'?',
        '%40':'@',
        '%0D%0A':'<br/>',
#        '%0D':'<br/>',
#        '%0A':'<br/>',
        'pos':'pps',
        'os=0':'os=Android',
        'os=1':'os=IOS',
        'os=2':'os=Windows Mobile',
        'os=3':'os=Windows Phone',
        'os=4':'os=Black Phone',
        'os=5':'os=Palm Webos',
    }

    for key in d:
        log = log.replace(key, d[key])

    l = log
    return l


def deallog():
#    ftpdown()    """Call ftpdown func to download log file."""
    f = open(filename)

    for log in f:
        line = logformat(log)

        rpe= re.compile(r'pe=.*').findall(line)
        if rpe:
            for e in rpe:
                ape = e.split('&')[0].split('pe=')[1].split('HTTP')[0]
#                trpe = re.compile(r'\d{1,4}[/.-]?\d{1,4}[/.-]?\d{1,4}.*').findall(ape)
#                if trpe:
#                    for tpe in trpe:
#                       pe = "<br/>".join(tpe.split('<br/>')[1:])
#                else:
#                    pe = ape
                pe = ape
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

        """Insert into database."""
        mysqlconn(dt, pe, dmod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua)

for f in os.popen("ls SmartMAD2_error_13*.log"):
    filename = f.split()[0]        
    dt = f.split('_')[2].split('.')[0]
    deallog()