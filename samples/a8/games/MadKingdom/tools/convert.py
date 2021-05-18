# -*- coding: utf-8 -*-

# commandline tool for converting polish letters into ATASCII codes
# usage python convert.py inputFile.asm > otputFile.asm

# author: bocianu@gmail.com <Wojciech Bociański>
import sys
import re

def convertPL(newdata):
    newdata = newdata.replace("ą","',1,'")
    newdata = newdata.replace("ć","',3,'")
    newdata = newdata.replace("ę","',5,'")
    newdata = newdata.replace("ł","',12,'")
    newdata = newdata.replace("ń","',14,'")
    newdata = newdata.replace("ó","',15,'")
    newdata = newdata.replace("ś","',19,'")
    newdata = newdata.replace("ź","',11,'")
    newdata = newdata.replace("ż","',26,'")
    newdata = newdata.replace("Ą","',17,'")
    newdata = newdata.replace("Ć","',22,'")
    newdata = newdata.replace("Ę","',18,'")
    newdata = newdata.replace("Ł","',123,'")
    newdata = newdata.replace("Ń","',13,'")
    newdata = newdata.replace("Ó","',16,'")
    newdata = newdata.replace("Ś","',4,'")
    newdata = newdata.replace("Ź","',9,'")
    newdata = newdata.replace("Ż","',24,'")
    newdata = newdata.replace("'',",",")
    newdata = newdata.replace(",''",",")
    newdata = newdata.replace(",,",",")
    return newdata

if len(sys.argv)>1 :
    newdata = '';
    filename = sys.argv[1]
    f = open(filename,'r')
    for line in f:
        if (not re.match("(\t*);(.*)",line)) and (line.strip()!=''):
            line = convertPL(line)
        newdata += line
    f.close()

    print newdata
else:
    print 'no input file'
