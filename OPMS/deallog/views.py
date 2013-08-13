from django.shortcuts import render_to_response
from deallog.models import deallog, report, smlog
import time

def errlog(request):
    curdate = time.strftime("%Y-%m-%d", time.localtime(time.time()))
    errors = deallog.objects.filter(dos = "IOS", pv__contains = '3.')
    return render_to_response('errlog.html', {'errors': errors})

def smlogs(request):
    curdate = time.strftime("%Y-%m-%d", time.localtime(time.time()))
    logs = smlog.objects.filter(dos = "IOS", pv__contains = '3.')
    return render_to_response('smlog.html', {'logs': logs})