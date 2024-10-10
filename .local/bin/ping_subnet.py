import os
import re
import time
import sys
from threading import Thread

"""Threading demo to test out all 254 possible hosts on a
class C network via ping, with up to 15 running at a time.
As threads complete, they're reaped and others started"""

# Differs from our other examples - this one harvests
# completed threads quickly (and out of order) to give
# faster performance on a network with a significant
# number of live systems

class testit(Thread):
   def __init__ (self,ip):
      Thread.__init__(self)
      self.ip = ip
      self.status = -1
   def run(self):
      pingaling = os.popen("ping -q -c2 "+self.ip,"r")
      while 1:
        line = pingaling.readline()
        if not line: break
        igot = re.findall(testit.lifeline,line)
        if igot:
           self.status = int(igot[0])

testit.lifeline = re.compile(r"(\d) received")
report = ("No response","Partial Response","Alive")

MAX_PARALLEL = 15

print time.ctime()

pinglist = []
top = 254

for host in range(1,top+1):
   ip = "192.168.50."+str(host)
   current = testit(ip)
   pinglist.append(current)
   current.start()

# Can we keep creating threads?
# Or are we maxed out or done with creation?

   waitfor = 0
   if len(pinglist) > MAX_PARALLEL: waitfor = 1
   if host == top: waitfor = len(pinglist)

# Can we reap any pings that have responded quickly?

   if waitfor == 1:
      posn = 0
      while posn < len(pinglist):
        also = pinglist[posn]
        if also.status > -1:
           also.join(1.0)
           print "Status from ",also.ip,"is",report[also.status]
           del pinglist[posn]
           waitfor -= 1
        else:
           posn += 1

# Reap any threads necessary

   for reap in range(waitfor):
       pingle = pinglist[0]
       pinglist = pinglist[1:]
       print "Waiting for ",pingle.ip
       pingle.join(5.0)
       print "Status from ",pingle.ip,"is",report[pingle.status]

print time.ctime()
sys.exit(0)

""" This program runs individual and parallel pings.
Since ping is implemented differently on different
versions of Linux and Unix, you may need to change
your ping options and the regular expression that it
matches to get the correct results """

