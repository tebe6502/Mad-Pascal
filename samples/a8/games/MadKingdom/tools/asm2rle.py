# -*- coding: utf-8 -*-

# commandline tool for compresing asm data files using RLE algorithm
# usage python asm2rle.py inputFile.asm > otputFile.asm

# author: bocianu@gmail.com <Wojciech Bociański>

import sys
import re

OUTPUT_CHUNK_SIZE = 16;

data = []
output = []
saved = 0;
outsize = 0;

def saveStr(x):
    tmp = []
    i=0;
    while (x < len(data)) and (i<=127):
        a = data[x]
        tmp.append(a)
        if (x<(len(data)-2) and a==data[x+1] and a==data[x+2]):
            tmp.pop()
            break
        x+=1
        i+=1
    i-=1
    a = (i << 1) | 1
    output.append(a)
    output.extend(tmp)
    return x

def saveRle(a, ile):
    output.append((ile - 1)<<1)
    output.append(a)

def processData():
    x = 0
    while x < len(data):
        old = x
        a = data[x]
        licz = 1
        x += 1
        while (x<len(data)) and (a == data[x]):
            licz += 1
            x += 1
            if licz == 127:
                break;
        if licz>2:
            saveRle(a, licz)
        else:
            x = saveStr(old)
    output.append(0)

def showOutput():
    chunks = [output[x:x+OUTPUT_CHUNK_SIZE] for x in xrange(0, len(output), OUTPUT_CHUNK_SIZE)]
    for line in chunks:
        print "\tdta", ','.join('$'+hex(x)[2:].zfill(2).upper() for x in line)


if len(sys.argv)>1 :
    filename = sys.argv[1]
    dataread = False
    f = open(filename,'r')
    for line in f:
        if (not re.match("(\t*);(.*)",line)) and (line.strip()!=''):
            dta = re.match("([ \t]*)dta (.*)",line)
            if dta:
                dataread = True
                values = dta.group(2).split(',');
                for v in values:
                    ishex = re.match("\$(.*)",v.strip())
                    if ishex:
                        data.append(int(ishex.group(1),16))
                    else:
                        data.append(int(v,10))
            else:
                if dataread and len(data)>0:
                    # print data
                    processData()
                    print "; RLE compresed data. Size before", len(data) ,"size after:",len(output)
                    saved += len(data) - len(output)
                    outsize += len(output)
                    showOutput()
                    data = []
                    output = []
                print line.rstrip()
    f.close()
    print "; RLE SAVED: ",saved,"bytes"
    print "; RLE DATA TOTAL SIZE: ",outsize,"bytes"
else:
    print 'no input file'
