; you can use this file to define all your strings in one file 
; it's always useful to do that if you plan to translate your work later

strings_list
    dta a(txt_0)
    dta a(txt_1)
    dta a(txt_2)
    dta a(txt_3)
    ;dta a(txt_2)

strings

txt_0         
    dta 15,c'Hello MadStrap!'
txt_1
    dta 24,c'Press any key to exit...'
txt_2         
    dta 15,d'Hello MadStrap!'
txt_3
    dta 24,d'Press any key to exit...'
;txt_4         


 .print "STRINGS SIZE: ", *-strings_list
 .print "STRINGS : ", strings_list, "..", * 
    
