strings_list

    dta a(txt_0)
    dta a(txt_1)
    dta a(txt_2)
    dta a(txt_3)
    dta a(txt_4)
    dta a(txt_5)
    dta a(txt_6)
    dta a(txt_7)
    dta a(txt_8)
    dta a(txt_9)
    dta a(txt_10)
    dta a(txt_11)
    dta a(txt_12)
    dta a(txt_13)
;    dta a(txt_14)

strings

txt_0         dta d'Score:          Food:         Lives:'
txt_1         dta d'      game version: 1.0        '
txt_2         dta d'PRESS ',"FIRE"*," OR ","START"*
txt_12        dta d"SELECT"*," STARTING LEVEL: "
txt_4         dta d'"STINKY"'
txt_5         dta d'"KINKY"'
txt_6         dta d'"WANKY"'
txt_7         dta d'"ALAN"'
txt_3         dta  "code&gfx: BOCiANU   audio: LiSU"
txt_8         dta  "all rights violated twice"
txt_9         dta  "game written in MadPascal"
txt_10        dta  "special thanks to TeBe and P.H.A.T."
txt_11        dta  "Hi-Score:"

txt_13        dta  "Level:  "

    .print "STRINGS SIZE: ", *-strings_list
    .print "STRINGS : ", strings_list, "..", *
