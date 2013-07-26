#!/usr/bin/env python

import re
import time
import MySQLdb

dt = time.strftime("%Y-%m-%d", time.localtime(time.time()))

f = open('SmartMAD2_error_130724.log')

for line in f:
    rpe= re.compile(r'pe=.*').findall(line)
    if rpe:
        pe = rpe.split('&')[0].split('pe=')[1]
    else:
        pe = None

    rmod = re.compile(r'mod=.*').findall(line)
    if rmod:
        mod = rmom.split('&')[0].split('mod=')[1]
    else:
        mod = None
        
        
    ros = re.compile(r'os=.*').findall(line)
    if ros:
        dos = ros.split('&')[0].split('os=')[1]
    else:
        dos = None 
        
    rosv = re.compile(r'osv=.*').findall(line)
    if rosv:
        osv = rosv.split('&')[0].split('osv=')[1]
    else:
        osv = None
        
    rcpu = re.compile(r'cpu=.*').findall(line)
    if rcpu:
        cpu = rcpu.split('&')[0].split('cpu=')[1]
    else:
        cpu = None
        
    rram = re.compile(r'ram=.*').findall(line)
    if rram:
        ram = rram.split('&')[0].split('ram=')[1]
    else:
        ram = None

    rrom = re.compile(r'rom=.*').findall(line)
    if rrom:
        rom = rrom.split('&')[0].split('rom=')[1]
    else:
        rom = None
        
    rjb = re.compile(r'jb=.*').findall(line)
    if rjb:
        jb = rjb.split('&')[0].split('jb=')[1]
    else:
        jb = None
   
    rde = re.compile(r'de=.*').findall(line)
    if rde:
        de = rde.split('&')[0].split('de=')[1]
    else:
        de = None
    
    rapn = re.compile(r'apn=.*').findall(line)
    if rapn:
        apn = rapn.split('&')[0].split('apn=')[1]
    else:
        apn = None

    rav = re.compile(r'av=.*').findall(line)
    if rav:
        av = rav.split('&')[0].split('av=')[1]
    else:
        av = None

    rmem = re.compile(r'mem=.*').findall(line)
    if rmem:
        mem = rmem.split('&')[0].split('mem=')[1]
    else:
        mem = None
        
    rpv = re.compile(r'pv=.*').findall(line)
    if rpv:
        pv = rpv.split('&')[0].split('pv=')[1]
    else:
        pv = None

    rua = re.compile(r'ua=.*').findall(line)
    if rua:
        ua = rua.split('&')[0].split('ua=')[1]
    else:
        ua = None


    #Insert into database. 
    conn = MySQLdb.connect(host='192.168.200.200', user='ops', passwd='madhouse', db='madhouse', charset='utf8')
    cur = conn.cursor()
    cur.execute("insert into deallog_deallog(dt, pe, mod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua) value(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (dt, pe, mod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua))
    conn.commit()
    cur.close()
    conn.close()