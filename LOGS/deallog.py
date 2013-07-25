#!/usr/bin/env python

import re
import MySQLdb

f = open('SmartMAD2_error_130724.log')

for line in f:
    rp= re.compile(r'pe=.*').findall(line)
    for e in rp:
        pe = e.split('&')[0].split('pe=')[1]

    ra = re.compile(r'ua=.*').findall(line)
    for a in ra:
        ua = a.split('&')[0].split('ua=')[1]
 
    rv = re.compile(r'pv=.*').findall(line)
    for v in rv:
        pv = v.split('&')[0].split('pv=')[1]

    print pe,ua,pv


    conn = MySQLdb.connect(host='172.16.27.6', user='ops', passwd='madhouse', db='madhouse', charset='utf8')
    cur = conn.cursor()
    cur.execute("insert into deallog_deallog(pe, ua, pv) value(%s,%s,%s)", (pe, ua, pv))
    conn.commit()
    cur.close()
    conn.close()