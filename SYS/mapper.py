#!/usr/bin/python
#-*-coding:UTF-8 -*-
import sys

debug = True

if debug:
    lzo = 0
else:
    lzo = 1

for line in sys.stdin:
    try:
        flags = line[:-1].split(' ')
        if len(flags) == 0:
            break
        if len(flags) != 14+lzo:
             continue
        stat_date=flags[7+lzo]
        stat_date_bar = stat_date[1:]
        if flags[2+lzo] == '-' and flags[4+lzo] == '-':
            continue
        elif flags[2+lzo] == '-' and flags[4+lzo] != '-':
            client = flags[4+lzo]
        else:
            client = flags[2+lzo]    
        url = flags[10+lzo]
        state = flags[12+lzo]
        print stat_date_bar+'\t'+client+'|'+url+'|'+state+'\t'+'%d' % 1
    except Exception,e:
        print e