#!/usr/bin/env python

import re
import time
import MySQLdb

dt = time.strftime("%Y-%m-%d", time.localtime(time.time()))

f = open('SmartMAD2_error_130724.log')

for line in f:
    rpe= re.compile(r'pe=.*').findall(line)
    for e in rpe:
        cpe = e.split('&')[0].split('pe=')[1]
        if cpe:
            pe = cpe
        else:
            pe = None

    rmod = re.compile(r'mod=.*').findall(line)
    for m in rmod:
        cmod = m.split('&')[0].split('mod=')[1]
        if cmod:
            mod = cmod
        else:
            mod = None
        
        
    ros = re.compile(r'os=.*').findall(line)
    for o in ros:
        cos = o.split('&')[0].split('os=')[1]
        if cos:
            dos = cos
        else:
            dos = None 
        
    rosv = re.compile(r'osv=.*').findall(line)
    for sv in rosv:
        cosv = sv.split('&')[0].split('osv=')[1]
        if cosv:
            osv = cosv
        else:
            osv = None
        
    rcpu = re.compile(r'cpu=.*').findall(line)
    for c in rcpu:
        ccpu = c.split('&')[0].split('cpu=')[1]
        if ccpu:
            cpu = ccpu
        else:
            cpu = None
        
    rram = re.compile(r'ram=.*').findall(line)
    for ra in rram:
        cram = ra.split('&')[0].split('ram=')[1]
        if cram:
            ram = cram
        else:
            ram = None

    rrom = re.compile(r'rom=.*').findall(line)
    for ro in rrom:
        crom = ro.split('&')[0].split('rom=')[1]
        if crom:
            rom = crom
        else:
            rom = None
        
    rjb = re.compile(r'jb=.*').findall(line)
    for j in rjb:
        cjb = j.split('&')[0].split('jb=')[1]
        if cjb:
            jb = cjb
        else:
            jb = None
   
    rde = re.compile(r'de=.*').findall(line)
    for d in rde:
        cde = d.split('&')[0].split('de=')[1]
        if cde:
            de = cde
        else:
            de = None
    
    rapn = re.compile(r'apn=.*').findall(line)
    for ap in rapn:
        capn = ap.split('&')[0].split('apn=')[1]
        if capn:
            apn = cpan
        else:
            apn = None

    rav = re.compile(r'av=.*').findall(line)
    for rv in rav:
        cav = rv.split('&')[0].split('av=')[1]
        if cav:
            av = cav
        else:
            av = None

    rmem = re.compile(r'mem=.*').findall(line)
    for me in rmem:
        cmem = me.split('&')[0].split('mem=')[1]
        if cmem:
            mem = cmem
        else:
            mem = None
        
    rpv = re.compile(r'pv=.*').findall(line)
    for v in rpv:
        cpv = v.split('&')[0].split('pv=')[1]
        if cpv:
            pv = cpv
        else:
            pv = None

    rua = re.compile(r'ua=.*').findall(line)
    for a in rua:
        cua = a.split('&')[0].split('ua=')[1]
        if cua:
            ua = cua
        else:
            ua = None


    #Insert into database. 
    conn = MySQLdb.connect(host='172.16.27.6', user='ops', passwd='madhouse', db='madhouse', charset='utf8')
    cur = conn.cursor()
    cur.execute("insert into deallog_deallog(dt, pe, mod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua) value(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (dt, pe, mod, os, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua))
    conn.commit()
    cur.close()
    conn.close()