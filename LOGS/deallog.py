#!/usr/bin/env python

import re
import time
import MySQLdb

f = open('SmartMAD2_error_130724.log')

for line in f:
    rpe= re.compile(r'pe=.*').findall(line)
    for e in rpe:
        pe = e.split('&')[0].split('pe=')[1]

    rmod = re.compile(r'mod=.*').findall(line)
    for m in rmod:
        mod = m.split('&')[0].split('mod=')[1]
        
    ros = re.compile(r'os=.*').findall(line)
    for o in ros:
        os = o.split('&')[0].split('os=')[1]
        
    rosv = re.compile(r'osv=.*').findall(line)
    for sv in rosv:
        osv = sv.split('&')[0].split('osv=')[1]
        
    rcpu = re.compile(r'cpu=.*').findall(line)
    for c in rcpu:
        cpu = c.split('&')[0].split('cpu=')[1]
        
    rram = re.compile(r'ram=.*').findall(line)
    for ra in rram:
        ram = ra.split('&')[0].split('ram=')[1]

    rrom = re.compile(r'rom=.*').findall(line)
    for ro in rrom:
        rom = ro.split('&')[0].split('rom=')[1]
        
    rjb = re.compile(r'jb=.*').findall(line)
    for j in rjb:
        jb = j.split('&')[0].split('jb=')[1]
   
    rde = re.compile(r'de=.*').findall(line)
    for d in rde:
        de = d.split('&')[0].split('de=')[1]
    
    rapn = re.compile(r'apn=.*').findall(line)
    for ap in rapn:
        apn = ap.split('&')[0].split('apn=')[1]

    rav = re.compile(r'av=.*').findall(line)
    for rv in rav:
        av = rv.split('&')[0].split('av=')[1]

    rmem = re.compile(r'mem=.*').findall(line)
    for me in rmem:
        mem = me.split('&')[0].split('mem=')[1]
        
    rpv = re.compile(r'pv=.*').findall(line)
    for v in rpv:
        pv = v.split('&')[0].split('pv=')[1]

    rua = re.compile(r'ua=.*').findall(line)
    for a in rua:
        ua = a.split('&')[0].split('ua=')[1]


dt = time.strftime("%Y-%m-%d", time.localtime(time.time()))

#Insert into database. 
conn = MySQLdb.connect(host='172.16.27.6', user='ops', passwd='madhouse', db='madhouse', charset='utf8')
cur = conn.cursor()
cur.execute("insert into deallog_deallog(dt, pe, mod, dos, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua) value(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (dt, pe, mod, os, osv, cpu, ram, rom, jb, de, apn, av, mem, pv, ua))
conn.commit()
cur.close()
conn.close()