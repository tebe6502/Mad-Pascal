# -*- coding: utf-8 -*-

# tool for extracting/converting sqllite card database into asm data file
# probably not very useful for anyone else on the enitre world
# usage python extract_cards.py otputFile.asm

# author: bocianu@gmail.com <Wojciech Bociański>

import sqlite3
import codecs
import sys
UTF8Writer = codecs.getwriter('utf8')
sys.stdout = UTF8Writer(sys.stdout)

dbfilepath = 'assets/cardlib.db'

LANG_PL = 0
LANG_EN = 0

LANG = LANG_PL

FLAG_MONEY      = 0b10000000
FLAG_POPULATION = 0b01000000
FLAG_ARMY       = 0b00100000
FLAG_HEALTH     = 0b00010000
FLAG_HAPPINES   = 0b00001000
FLAG_CHURCH     = 0b00000100

flags = [ FLAG_MONEY, FLAG_POPULATION, FLAG_ARMY, FLAG_HEALTH, FLAG_HAPPINES, FLAG_CHURCH ];
reqnames = [ 'money', 'population', 'army', 'health', 'happines', 'church' ];
reqsize = [ 'a', 'a', 'a', 'b', 'b', 'b' ];


globalsize = 0
blocksize = 0

def getResources(card,index):
    rsize = 1;
    reqflags = 0;
    values = "";
    for i in range(0,len(flags)):
        flag = flags[i]
        vmin = card[index]
        index += 1
        vmax = card[index]
        index += 1
        if vmin!=0 or vmax!=0:
            rsize += 2
            if reqsize[i] == 'a':
                rsize +=  2
            reqflags = reqflags | flag;
            values += "\tdta " + reqsize[i] + "(" + str(vmin) + "," + str(vmax) + ") ; " + reqnames[i] + "\n";
    print "\tdta b(%s) ; %s - bits 7:money 6:population 5:army 4:health 3:happines 2:church\n%s" % (reqflags, bin(reqflags), values)
    return rsize

def getRequirements(card,index):
    rsize = 1;
    reqcount = 0
    values = "";
    for i in (0,1):
        rvalue = card[index + 0]
        rhow = card[index + 1]
        ramount = card[index + 2]
        index += 3
        if rvalue!=0:
            reqcount += 1
            rsize += 6
            values += "\tdta " + str(rvalue) + " ; reqired_param - 0:none 1:money 2:population 3:army 4:health 5:happines 6:church 7:year"
            values += "\n\tdta " + str(rhow) + " ; reqired_how - 0:equal 1:greater than 2:lower than 3:gte 4:lte"
            values += "\n\tdta f("+ str(ramount) +") ; required amount\n"
    print "\tdta %s ; requirement count (max 2)" % reqcount
    print values
    return rsize


conn = sqlite3.connect(dbfilepath)
c = conn.cursor()
cards = c.execute('SELECT * FROM cards').fetchall()
actors = c.execute('SELECT * FROM actors').fetchall()
strings = c.execute('SELECT * FROM strings order by label').fetchall()
static_txt = c.execute('SELECT * FROM static_txt order by ID').fetchall()
static_images = c.execute('SELECT * FROM static_images order by ID').fetchall()


blocksize = 0x100
globalsize += blocksize
print '\n; ********************** card list (count:%s size:%s bytes)\n\ncards_list' % (len(cards),blocksize)

for txt in cards:
    print ("\tdta a(%s)" % txt[0])


blocksize = 0x80
globalsize += blocksize
print '\n; ********************** static strings list (count:%s size:%s bytes) \n' % (len(static_txt),blocksize)
print '.align $100'

for txt in static_txt:
    print ("\tdta a(txt_%s)" % txt[0])

print '\n; ********************** static images list\n'
print ("\n.align $80")
for txt in static_images:
    print ("\tdta a(%s) ; %s" % (txt[1],txt[0]))

blocksize = 0
print '\n; ********************** static strings\n'

for txt in static_txt:
    print ("txt_%s\tdta c'%s',0" % (txt[0],txt[1]))
    blocksize += len(txt[1+LANG])+1;

print '; strings size: %s bytes' % blocksize
globalsize += blocksize

blocksize = 0
print '\n; ********************** card strings\n'

for txt in strings:
    print ("%s\n\tdta c'%s',0" % (txt[0],txt[1+LANG]))
    blocksize += len(txt[1])+1;

print '; strings size: %s bytes' % blocksize
globalsize += blocksize

blocksize = 0
print '\n; ********************** actors (count:%s) \n' % len(actors)

for txt in actors:
    print ("%s\n\tdta a(%s)\n\tdta c'%s',0" % (txt[0],txt[1],txt[2+LANG]))
    blocksize += len(txt[2])+3;

print '; actors size: %s bytes' % blocksize
globalsize += blocksize

blocksize = 0
print '\n; ********************** cards\n'

strdict = dict(map(lambda t: (t[0],t[1+LANG]),strings))

for txt in cards:
    print ("%s" % txt[0])
    print ("\tdta %s ; type   0:resource_card 1:gamble_card" % txt[1])
    print ("\tdta a(%s) ; actor pointer" % txt[2])
    print ("\tdta a(%s) ; common description / question" % txt[3])
    print ("\t; %s" % strdict[txt[3]])
    print ("\tdta a(%s) ; actor sentence" % txt[4])
    print ("\t; %s" % strdict[txt[4]])
    print ("\tdta a(%s) ; yes response" % txt[5])
    print ("\tdta a(%s) ; No response\n" % txt[6])
    blocksize += 11;
    print ("\t;resource change for yes")
    blocksize += getResources(txt,7)
    print ("\t;resource change for no")
    blocksize += getResources(txt,19)
    print ("\t;requirements")
    blocksize += getRequirements(txt,31)

print '; cards size: %s bytes' % blocksize
globalsize += blocksize
print '\n; global data size: %s bytes' % globalsize

