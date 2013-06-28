from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns 

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),
    url(r'^admin/', include(admin.site.urls)),
)

urlpatterns += patterns('books.views',
    url(r'^search/$', 'search'),
    url(r'^book/$', 'archive')
)

urlpatterns += patterns('contact.views',
    url(r'^contact/$', 'contact'),                    
)

urlpatterns += staticfiles_urlpatterns()