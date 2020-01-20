# -*- coding: utf-8 -*-

# tool for adding cards to database
# probably not very useful for anyone else on the enitre world

# author: bocianu@gmail.com <Wojciech Bociański>

import sqlite3
import codecs
import sys

dbfilepath = '../assets/cardlib.db'

LANG_PL = 0
LANG_EN = 1
LANG = LANG_PL

resourceNames = [ 'money', 'population', 'army', 'health', 'happines', 'church' ]
requirementNames = [ 'none', 'money', 'population', 'army', 'health', 'happines', 'church', 'year' ]
requirementHow = [ 'equal','greater than','lower than','gte','lte' ]

conn = sqlite3.connect(dbfilepath)
c = conn.cursor()

def reloadDB():
    global cards, actors, strings
    cards = c.execute('SELECT * FROM cards').fetchall()
    actors = c.execute('SELECT * FROM actors').fetchall()
    strings = c.execute('SELECT * FROM strings order by label').fetchall()

def addActor():
    while True:
        actorName = raw_input('full name or L for list of actors       | max 40 chars\n')
        if actorName.upper() == 'L':
            for txt in actors:
                print ("%s\t%s\t%s" % (txt[0],txt[1],txt[2+LANG]))
        elif actorName != '':
            break
    shortName = raw_input('short name - no spaces allowed\n')
    faceName = raw_input('face name - empty for "%s"\n'%shortName)
    if faceName == '':
        faceName = shortName
    actorName = actorName.decode('cp852')
    actorLabel = getUniqueLabel(actors, 'actor_' + shortName)
    row = (actorLabel, 'face_'+faceName, actorName, None)
    c.execute('insert into actors values (?,?,?,?)', row)
    conn.commit()
    print "=== Actor Added!\n"
    print "\n"

def getResponse(prefix, selection):
    count = 0
    realcount = 0
    idx = [];
    print "\nResponse for %s" % selection
    for txt in strings:
        if txt[0].startswith( prefix ):
            print ("%s> %s" % (count,txt[1+LANG]))
            idx.append(realcount)
            count += 1
        realcount += 1
    respNum = raw_input('Select Response [0-%s] or type new :    | max 40 chars\n'% (count-1))
    if respNum.isdigit() and int(respNum)<count:
        yesResponse = strings[idx[int(respNum)]]
        respLabel = yesResponse[0]
    else:
        respName = raw_input('Select response short name - no spaces allowed : ')
        respLabel = getUniqueLabel(strings, prefix + respName)
        row = (respLabel, respNum.decode('cp852'), None)
        c.execute('insert into strings values (?,?,?)', row)
        conn.commit()
        print "=== Response Added!\n"
    return respLabel

def getChange(desc):
    change = raw_input(desc)
    if "," in change:
        chval = change.split(',')
        return (int(chval[0]),int(chval[1]))
    if change == "":
        return (0,0)
    return (int(change),int(change))

def getUniqueLabel(klist, proposal):
    if proposal in [i[0] for i in klist]:
        count = 2
        while True:
            ukey = proposal + '_' + str(count)
            if ukey in [i[0] for i in klist]:
                count += 1
            else:
                return ukey
    else:
        return proposal

def addCard():

    ######################################################### TYPE
    cardType = raw_input('Card Type (0 default) : ')
    if cardType == '':
        cardType = '0';
    if cardType.isdigit():
        cardType = int(cardType)
    else:
        print "bad choice... quitting\n\n\n"
        return
    print "< %s >" % cardType

    ######################################################### ACTOR
    count = 0;
    print "\nActors:"
    for txt in actors:
        print ("%s> %s" % (count,txt[2+LANG]))
        count += 1
    actorNum = raw_input('Select Actor [0-%s] : ' % (count-1))
    if actorNum.isdigit() and int(actorNum)<count:
        actor = actors[int(actorNum)]
        actorLabel = actor[0]
        actorName = actorLabel.replace('actor_','')
    else:
        print "bad choice... quitting\n\n\n"
        return
    print "< %s >" % actorLabel

    ######################################################### DESCRIPTION / NAME
    count = 0
    realcount = 0
    idx = [];
    print "\nDescriptions:"
    for txt in strings:
        if txt[0].startswith( 'txt_desc_' ):
            print ("%s> %s" % (count,txt[1+LANG]))
            idx.append(realcount)
            count += 1
        realcount += 1
    descNum = raw_input('Select Description [0-%s] or type new : | max 40 chars\n'% (count-1))
    if descNum.isdigit() and int(descNum)<count:
        description = strings[idx[int(descNum)]]
        descLabel = description[0]
        tempName = descLabel.replace('txt_desc_','')
        cardName = raw_input('Select card short name - no spaces allowed (default: %s) : ' % tempName)
        if cardName == '':
            cardName = tempName
    else:
        cardName = raw_input('Select card short name - no spaces allowed : ')
        descLabel = getUniqueLabel(strings, 'txt_desc_' + cardName)
        row = (descLabel, descNum.decode('cp852'), None)
        c.execute('insert into strings values (?,?,?)', row)
        conn.commit()
        print "=== Description Added!\n"
    print "< %s >" % descLabel
    cardLabel = getUniqueLabel(cards, "card_" + cardName + "_" + actorName)
    print "< %s >" % cardLabel

    ######################################################### SENTENCE
    sentence = raw_input('\nActor\'s sentence                       | max 40 chars\n')
    sentenceLabel = getUniqueLabel(strings, 'txt_quote_' + cardName + "_" + actorName)
    row = (sentenceLabel, sentence.decode('cp852'), None)
    c.execute('insert into strings values (?,?,?)', row)
    conn.commit()
    print "=== Sentence Added!\n"
    print "< %s >" % sentenceLabel

    ######################################################### YES / NO RESPONSE
    yesLabel = getResponse('txt_yes_','YES')
    print "< %s >" % yesLabel
    noLabel = getResponse('txt_no_','NO')
    print "< %s >" % noLabel

    ######################################################### RESOURCE CHANGES
    print "\nResource changes are represented by single integer or range min,max or empty for zero (no change)\n"
    resChangeYes = []
    resChangeNo = []
    for resName in resourceNames:
        resChangeYes += list(getChange("%s changes for Yes : " % resName.upper()))
        resChangeNo += list(getChange("%s changes for No : " % resName.upper()))
    print "< %s >" % resChangeYes
    print "< %s >" % resChangeNo

    ######################################################### REQUIREMENTS
    print "\nRequirements (max.2)"
    requirements = [0,0,0,0,0,0]
    for offset in [0,3]:
        count = 0
        for keyreqName in requirementNames:
            print "%s> %s" % (count,keyreqName)
            count += 1
        reqNum = raw_input('Select what is required : ')
        if reqNum != '' and reqNum != '0':
            requirements[offset] = int(reqNum);
            count = 0
            for keyHow in requirementHow:
                print "%s> %s" % (count,keyHow)
                count += 1
            reqHow = raw_input('Select how its required : ')
            requirements[offset+1] = int(reqHow);
            reqAmount = raw_input('Select how much is required : ')
            requirements[offset+2] = int(reqAmount);
        else:
            break
    print "< %s >" % requirements

    ######################################################### STORE CARD
    card = [ cardLabel, cardType, actorLabel, descLabel, sentenceLabel, yesLabel, noLabel ] + resChangeYes + resChangeNo + requirements
    var_string = ', '.join('?' * len(card))
    c.execute('insert into cards values (%s)' % var_string, card)
    conn.commit()
    print "=== Card Added!\n"
    print "< %s >" % card


    ######################################################### MAIN LOOP
while True:
    reloadDB();
    mkey = raw_input('\nC - new card       A - new actor       Q - quit\n')
    if mkey.upper() == 'Q':
        break;
    elif mkey.upper() == 'A':
        print('*********************************************** adding actor:')
        addActor()
    elif mkey.upper() == 'C':
        print('*********************************************** adding card:')
        addCard()
    else:
        print('unknown command: %s\n' % mkey)
