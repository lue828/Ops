#!/usr/bin/env python
#coding:utf-8  
''' 
Created on 2013-11-23
'''
  
from genpy.flume import ThriftSourceProtocol  
from genpy.flume.ttypes import ThriftFlumeEvent  
  
  
from thrift.transport import TTransport, TSocket  
from thrift.protocol import TCompactProtocol  
  
  
class _Transport(object):  
    def __init__(self, thrift_host, thrift_port, timeout=None, unix_socket=None):  
        self.thrift_host = thrift_host  
        self.thrift_port = thrift_port  
        self.timeout = timeout  
        self.unix_socket = unix_socket  
          
        self._socket = TSocket.TSocket(self.thrift_host, self.thrift_port, self.unix_socket)  
        self._transport_factory = TTransport.TFramedTransportFactory()  
        self._transport = self._transport_factory.getTransport(self._socket)  
          
    def connect(self):  
        try:  
            if self.timeout:  
                self._socket.setTimeout(self.timeout)  
            if not self.is_open():  
                self._transport = self._transport_factory.getTransport(self._socket)  
                self._transport.open()  
        except Exception, e:  
            print(e)  
            self.close()  
      
    def is_open(self):  
        return self._transport.isOpen()  
      
    def get_transport(self):  
        return self._transport  
      
    def close(self):  
        self._transport.close()  
          
class FlumeClient(object):  
    def __init__(self, thrift_host, thrift_port, timeout=None, unix_socket=None):  
        self._transObj = _Transport(thrift_host, thrift_port, timeout=timeout, unix_socket=unix_socket)  
        self._protocol = TCompactProtocol.TCompactProtocol(trans=self._transObj.get_transport())  
        self.client = ThriftSourceProtocol.Client(iprot=self._protocol, oprot=self._protocol)  
        self._transObj.connect()  
          
    def send(self, event):  
        try:  
            self.client.append(event)  
        except Exception, e:  
            print(e)  
        finally:  
            self._transObj.connect()  
      
    def send_batch(self, events):  
        try:  
            self.client.appendBatch(events)  
        except Exception, e:  
            print(e)  
        finally:  
            self._transObj.connect()  
      
    def close(self):  
        self._transObj.close()  
      
if __name__ == '__main__':    
    import time
    import random
    
    server = "172.16.26.205"
    port = 41414
    flume_client = FlumeClient(server, port)  

    #event = ThriftFlumeEvent({'a':'hello', 'b':'world'}, 'event under hello world')  
    for i in range(10000):
        t = int(round(time.time() * 1000))
        ts = str(t)
        host = "opmgr.madhouse.cn"
        event = ThriftFlumeEvent({'timestamp':ts, 'host':host}, 'event under hello world')  
        flume_client.send(event)  
    
    #events = [ThriftFlumeEvent({'a':'hello', 'b':'world'}, 'events under hello world %s' % random.randint(0, 100000)) for _ in range(100000)]  
    #events = [ThriftFlumeEvent({'a':'hello', 'b':'world'}, '<%s> events under hello world!' % _) for _ in range(10000)]
    #flume_client.send_batch(events)  
    
    flume_client.close()