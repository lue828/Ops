from django.db import models

# Create your models here.

class deallog(models.Model):
#    dt = models.DateField()
    dt = models.IntegerField()
    pe = models.CharField(max_length=10000, null=True)
    mod = models.CharField(max_length=100, null=True)
    dos = models.CharField(max_length=50, null=True)
    osv = models.CharField(max_length=100, null=True)
    cpu = models.CharField(max_length=50, null=True)
    ram = models.IntegerField(null=True)
    rom = models.IntegerField(null=True)
    jb = models.IntegerField(null=True)
    de = models.IntegerField(null=True)
    apn = models.CharField(max_length=100, null=True)
    av = models.CharField(max_length=100, null=True)
    mem = models.IntegerField(null=True)
    pv = models.CharField(max_length=100, null=True)
    ua = models.CharField(max_length=300, null=True)
    
    def __unicode__(self):
        return self.pe