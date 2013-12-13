#!/usr/bin/python
#-*-coding:UTF-8 -*-
import sys
import os
import string

res = {}

for line in sys.stdin:
    try:
        flags = line[:-1].split('\t')
        if len(flags) != 3:
            continue
        skey= flags[1]
        count=int(flags[2])
        if res.has_key(skey) == False:
             res[skey]=0
        res[skey] += count
    except Exception,e:
        pass

for key in res.keys():
    print key+'|'+'%s' % res[key]