#!/usr/bin/env python
# -*- coding:utf-8 -*-

import urllib2
import re
import sys
from threading import Thread
import time
#from datetime import *
import random
import hashlib
import os
 
class tieba(object):
    url = None
    dirPath = None
    __md5 = None
    html = None
    lz = None

    def __init__(self,link):
        self.url = link
        self.dirPath = sys.path[0] + "/tieba/"
        self.__md5 = hashlib.md5()
        self.getHtml(link)

    def getHtml(self,link):
        req = urllib2.Request(link)
        res = urllib2.urlopen(link)
        self.html = res.read()

    def getImages(self):
        rc1 = '<img\s+class="BDE_Image".*?src="([^"]*)".*?>'
        rc2 = '<img\s+src="([^"]*)".*?class="BDE_Image".*?>'
        #rc = '<img src="[^"]*" original="[^"]*"  bpic="([^"]*)"[^>]*\/>'
        images1 = re.findall(rc1, self.html)
        images2 = re.findall(rc2, self.html)
        images = images1+images2
        return images

    def saveImg(self):   
        images = self.getImages()   
        path = self.getLZdir()   
        for i in images:   
            self.__md5.update(i)   
            fname = self.__md5.hexdigest()   
            fextention = os.path.splitext(i)   
            fname = path + fname + fextention[1]   
            if os.path.exists(fname)==False:   
                req = urllib2.Request(i)   
                res = urllib2.urlopen(i)   
                pic = res.read()   
                f = open(fname, "wb");   
                f.write(pic);   
                f.close()
      
    def getAll(self):   
        baseurl = "http://tieba.baidu.com"   
        rc = '<a\s+href="(/p/[^"]*)">\d+</a>'   
        allpage = re.findall(rc,self.html,re.MULTILINE|re.DOTALL)   
        allpage = list(set(allpage))   
        if len(allpage)>0:   
            for i in allpage:   
                self.getHtml(baseurl+i)   
                self.saveImg()
   
    def getLZdir(self):   
        username = self.getLz()   
        path = self.dirPath+username+"_"   
        #if os.path.exists(path)==False:  
        #   os.makedirs(path)   
        return path
   
    def getLz(self):   
        rc = '<a\s+alog-group="p_author".*class="p_author_name.*?"\s+href="[^"]*"\s+target="_blank">([^"]*)</a>'   
        username = re.findall(rc,self.html,re.MULTILINE|re.DOTALL)   
        if len(username)>0:   
            self.lz = username[0].decode('GBK')   
        else:   
            self.lz = "unknow"   
        return self.lz
   
class catchLinks(Thread):   
    baseurl = "http://tieba.baidu.com"   
    url = None   
    startPage = None   
    endPage = None
   
    def __init__(self):   
        Thread.__init__(self)   
        self.url = "http://tieba.baidu.com/f?kw=%BD%E3%CD%D1&tp=0&pn="
   
    def getLinks(self, page):   
        url = self.url + str(page*50)   
        req = urllib2.Request(url)   
        res = urllib2.urlopen(url)   
        html = res.read()   
        rc = '<a href="([^"]*)" title="[^"]*" target="_blank" class="j_th_tit">[^"]*</a>'   
        #rc = '<img src="[^"]*" original="[^"]*"  bpic="([^"]*)"[^>]*\/>'   
        links = re.findall(rc, html, re.MULTILINE | re.DOTALL)   
        return links
   
    def run(self):   
        for i in range(0,1):   
            #t = tieba()   
            links = self.getLinks(i)   
            for l in links:   
                heihei = catchImages(self.baseurl+l+"?see_lz=1")   
                heihei.start()   
            #t.saveImg(imgs)   
            print "get page %d start" % i   
            sys.stdout.flush()
   
class catchImages(Thread):   
    url = None   
    def __init__(self, link):   
        Thread.__init__(self)   
        self.url = link
              
    def run(self):   
        t = tieba(self.url)   
        t.saveImg()   
        t.getAll()   
        print "get page %s ok" % self.url   
        sys.stdout.flush()
               
if __name__ == '__main__':      
    c = catchLinks()   
    c.start()   
    #t = tieba("http://tieba.baidu.com/p/2501985154?see_lz=1")   
    #t.saveImg()
    #t.getAll()