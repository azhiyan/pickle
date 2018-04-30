#!/usr/bin/python

import time
import serial
 
modem = serial.Serial('/dev/ttyS0', timeout=5)

modem.write('AT\r')
out = ''
while 'OK' not in out:
    out = modem.readline()
    print out

modem.write("AT+CMGF=1\r")
out = ''
while 'OK' not in out:
    out = modem.readline()
    print out

modem.write('AT+CMGS="{}"\r\n'.format("7406044415"))
time.sleep(2)
modem.write("message text")
modem.write(chr(26))

out = ''
while 'OK' not in out:
    out = modem.readline()
    print out

modem.close()
