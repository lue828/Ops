#!/usr/bin/env python
#-*-conding:utf-8-*-

import time
import email
import smtplib
import mimetypes
from email.MIMEMultipart import MIMEMultipart
from email.mime.text import MIMEText
from email import Utils,Encoders

mail_host="smtp.qq.com"
mail_sub="Error Code"
mail_from="lue_liu@qq.com"
mail_to="lue_liu@qq.com"
mail_user="97576340"
mail_pass="******"

file = '/var/log/nginx/smlog.madhouse.cn-access.log'
key = '404'

def sendmail(mail_to,mail_content):
  msg = MIMEMultipart()
  msg['Subject'] = email.Header.Header(mail_sub,'gb2312')
  msg['From'] = mail_from
  msg['To'] = mail_to
  msg['Date'] = Utils.formatdate(localtime = 1)
  msg.set_charset('gb2312')
  msgText = MIMEText(mail_content,_subtype='plain',_charset='gb2312')
  msg.attach(msgText)

  try:
    s = smtplib.SMTP()
    s.connect(mail_host)
    s.login(mail_user,mail_pass)
    s.sendmail(mail_from, mail_to, msg.as_string())
    s.quit()

  except Exception,e:
    print e

def tail(f):
    f.seek(0,2)
    while True:
        line = f.readline()
        if not line:
            time.sleep(0.1)
            continue
        yield line

log = tail(open(file))
for line in log:
    if key in line:
#        print line,
        mail_content = line
        sendmail(mail_to,mail_content)