; you can use this file to define all your strings in one file 
; it's always useful to do that if you plan to translate your work later

strings_list
    dta a(txt_0)
    dta a(txt_1)
    ;dta a(txt_2)

strings

txt_0         
    dta c'Hello MadStrap!',0
txt_1
    dta c'Press any key to exit...',0
;txt_2         


 .print "STRINGS SIZE: ", *-strings_list
 .print "STRINGS : ", strings_list, "..", * 
    
