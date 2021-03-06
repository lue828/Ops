#!/usr/bin/env python
#-*- coding:utf-8 -*-
#by@taobao_ip_Library

import httplib2
import sys
import socket
import re

try:
    scrpit, _addr =  sys.argv
except ValueError:
    print "...\n......\n\n没有获取到IP地址 退出程序!!!\n........Done!"
    sys.exit()

def net_addr():
    try:
        return socket.getaddrinfo(_addr, None)
    except Exception:
        print '抱歉！ 网络或服务不可用。'
        sys.exit()

if re.search(r'^([1-2][0-5]?[0-4]?)', _addr):
    net_addr()
else:
    if re.search(r'(\w+\.)?(\w+|\d+)\.(\D){2,3}', _addr):
        net_addr()
    else:
        print '域名获取失败。'
        sys.exit()

def vul_info(vule):
    return _ip_key["data"][vule]

def St_dic(arg):
    return eval(arg)

if __name__ == '__main__':

    url =  "http://ip.taobao.com/service/getIpInfo.php?ip=" + net_addr()[0][4][0]
    Hc =  httplib2.Http(".cache")
    resp, content =  Hc.request(url, "GET")

    if resp["status"] == "200" or "302":
        if St_dic(content)["code"] == 0:
            conn =  content.decode("unicode_escape")
            _ip_key =  St_dic(conn)
            print vul_info("country"),vul_info("region"),vul_info("city"),vul_info("isp"),vul_info("ip")
        else:
            print St_dic(content)["data"]
    else:
        print "抱歉！ 服务不可用。",resp["status"]