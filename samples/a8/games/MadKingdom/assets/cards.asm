
; ********************** card list (count:32 size:256 bytes)

cards_list
	dta a(card_give_gold_bishop)
	dta a(card_give_gold_general)
	dta a(card_give_gold_medic)
	dta a(card_crime_rises_executioner)
	dta a(card_crime_rises_stargazer)
	dta a(card_crime_rises_treasurer)
	dta a(card_luck_check_jester)
	dta a(card_enemy_approach_knight)
	dta a(card_give_gold_peasant)
	dta a(card_betrayal_jester)
	dta a(card_luck_check_bishop)
	dta a(card_betrayal_stargazer)
	dta a(card_luck_check_stargazer)
	dta a(card_luck_check_treasurer)
	dta a(card_give_gold_knight)
	dta a(card_luck_check_medic)
	dta a(card_enemy_approach_general)
	dta a(card_dragon_peasant)
	dta a(card_betrayal_executioner)
	dta a(card_betrayal_bishop)
	dta a(card_luck_check_executioner)
	dta a(card_crime_rises_general)
	dta a(card_dragon_jester)
	dta a(card_dragon_knight)
	dta a(card_disease_medic)
	dta a(card_disease_peasant)
	dta a(card_betrayal_treasurer)
	dta a(card_neardeath_death)
	dta a(card_trade_devil)
	dta a(card_welcome_angel)
	dta a(card_bigarmy_general)
	dta a(card_unhappy_bishop)

; ********************** static strings list (count:52 size:128 bytes)

.align $100,$00
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
	dta a(txt_14)
	dta a(txt_15)
	dta a(txt_16)
	dta a(txt_17)
	dta a(txt_18)
	dta a(txt_19)
	dta a(txt_20)
	dta a(txt_21)
	dta a(txt_22)
	dta a(txt_23)
	dta a(txt_24)
	dta a(txt_25)
	dta a(txt_26)
	dta a(txt_27)
	dta a(txt_28)
	dta a(txt_29)
	dta a(txt_30)
	dta a(txt_31)
	dta a(txt_32)
	dta a(txt_33)
	dta a(txt_34)
	dta a(txt_35)
	dta a(txt_36)
	dta a(txt_37)
	dta a(txt_38)
	dta a(txt_39)
	dta a(txt_40)
	dta a(txt_41)
	dta a(txt_42)
	dta a(txt_43)
	dta a(txt_44)
	dta a(txt_45)
	dta a(txt_46)
	dta a(txt_47)
	dta a(txt_48)
	dta a(txt_49)
	dta a(txt_50)
	dta a(txt_51)

; ********************** static images list


.align $80,$00
	dta a(frame) ; 0
	dta a(logo) ; 1
	dta a(face_jester) ; 2
	dta a(face_vox_regis) ; 3
	dta a(tak_sprite) ; 4
	dta a(nie_sprite) ; 5
	dta a(status_bar) ; 6

; ********************** static strings

txt_0	dta c'Zarz',1,'dzaj dumnie swym kr',15,'lestwem!',0
txt_1	dta c'Dokonuj tylko m',1,'drych wybor',15,'w,',0
txt_2	dta c'u',26,'ywajac joysticka lub klawiszy.',0
txt_3	dta c'Gdy b',5,'dziesz got',15,'w, aby spotka',3,' si',5,0
txt_4	dta c'z pierwszym kr',15,'lewskim doradc',1,',',0
txt_5	dta c'naci',19,'nij dowolny klawisz lub fire.',0
txt_6	dta c'Wiosna',0
txt_7	dta c'Lato',0
txt_8	dta c'Jesie',14,0
txt_9	dta c'Zima',0
txt_10	dta c'Wieki ',19,'rednie',0
txt_11	dta c'LEGENDA:',0
txt_12	dta c'Umar',12,' kr',15,'l, niech ',26,'yje kr',15,'l!',0
txt_13	dta c'skarb pa',14,'stwa',0
txt_14	dta c'populacja',0
txt_15	dta c'si',12,'a armii',0
txt_16	dta c'zdrowie kr',15,'la',0
txt_17	dta c'szcz',5,'scie ludu',0
txt_18	dta c'religijno',19,3,0
txt_19	dta c'Co rok Twoi poddani p',12,'ac',1,' podatek.',0
txt_20	dta c'Wykorzystaj dobra aby rosn',1,3,' w si',12,5,'.',0
txt_21	dta c'Nigdy nie zapominaj o zdrowiu!',0
txt_22	dta c'pomys',12,' gry, kod, grafika: bocianu',0
txt_23	dta c'muzyka: LiSU',0
txt_24	dta c'ca',12,'o',19,3,' napisano w j',5,'zyku MadPascal',0
txt_25	dta c'narz',5,'dzia: mads, g2f, rmt, bin2c',0
txt_26	dta c'thx: TeBe za ciepliwo',19,3,' i pomoc',0
txt_27	dta c'P.H.A.T. za motywacj',5,0
txt_28	dta c'WAPniak 2k17',0
txt_29	dta c'Koniec Roku ',0
txt_30	dta c'przych',15,'d z podatku',0
txt_31	dta c'wydatki na armi',5,0
txt_32	dta c'inne wydarzenia:',0
txt_33	dta c'Bankructwo. Twoje kr',15,'lestwo upad',12,'o...',0
txt_34	dta c'Zmar',12,'e',19,' z przyczyn naturalnych...',0
txt_35	dta c'Rewolucja! T',12,'um podpali',12,' tw',15,'j zamek..',0
txt_36	dta c'Oto koniec Twojego kr',15,'lestwa.',0
txt_37	dta c'Uzyska',12,'e',19,' ',0
txt_38	dta c' punkt',15,'w.',0
txt_39	dta c'Otrzyma',12,'e',19,' nieoczekiwany spadek:',0
txt_40	dta c'Wydatki reprezentacyjne:',0
txt_41	dta c'Niebywa',12,'y przyrost naturalny: ',0
txt_42	dta c'Czarna ospa! Umarli na ulicach: ',0
txt_43	dta c'W kr',15,'lestwie urodzi',12,' si',5,' prorok: ',0
txt_44	dta c'W kr',15,'lestwie szaleje inkwizycja: ',0
txt_45	dta c'Nowe szlaki handlowe: ',0
txt_46	dta c'Masowa dezercja w armii:',0
txt_47	dta c'Wzi',1,12,'e',19,' ',19,'lub, najwy',26,'szy czas: ',0
txt_48	dta c'Urodzi',12,' Ci si',5,' syn: ',0
txt_49	dta c'Podupad',12,'e',19,' na zdrowiu w',12,'adco: ',0
txt_50	dta c'Panie! Zdrowiejesz w oczach: ',0
txt_51	dta c'Barbarzy',14,'cy najechali Twoje kr',15,'lestwo.',0
; strings size: 1255 bytes

; ********************** card strings

txt_desc_betrayal
	dta c'Mam wra',26,'enie Panie, ',26,'e kto',19,' spiskuje',0
txt_desc_bigarmy
	dta c'Nasza armia jest ju',26,' pot',5,26,'na,',0
txt_desc_crime_rises
	dta c'Przest',5,'pczo',19,3,' ro',19,'nie Ja',19,'niepanie',0
txt_desc_disease
	dta c'Wybuch',12,'a zaraza, czarna ',19,'mier',3,' w kraju',0
txt_desc_dragon
	dta c'W kr',15,'lestwie grasuje okrutny smok!',0
txt_desc_enemy_approach
	dta c'Wrogowie stoj',1,' u bram miasta!',0
txt_desc_give_gold
	dta c'Najja',19,'niejszy Panie, potrzeba nam z',12,'ota',0
txt_desc_luck_check
	dta c'Zobaczmy czy sprzyja w',12,'adcy szcz',5,19,'cie',0
txt_desc_neardeath
	dta c'Podupad',12,'e',19,' na zdrowiu ja',19,'niepanie.',0
txt_desc_trade
	dta c'Witam najja',19,'niejszego, pohandlujemy?',0
txt_desc_unhappy
	dta c'Lud niespokojny ostatnimi czasy,',0
txt_desc_welcome
	dta c'Witam sprawiedliwego ja',19,'niepana.',0
txt_no_go_away
	dta c'Precz!',0
txt_no_no_chance
	dta c'Nie ma szans',0
txt_no_no_way
	dta c'Wykluczone!',0
txt_no_overstatement
	dta c'Bez przesady.',0
txt_no_rather_no
	dta c'Raczej nie bardzo...',0
txt_quote_betrayal_bishop
	dta c'Wyp',5,'d',11,'my wrog',15,'w ko',19,'cio',12,'a z kraju.',0
txt_quote_betrayal_executioner
	dta c'Mo',26,'e zetniemy na pokaz kilku zdrajc',15,'w?',0
txt_quote_betrayal_jester
	dta c'powinni',19,'my ograniczy',3,' wp',12,'ywy ko',19,'cio',12,'a.',0
txt_quote_betrayal_stargazer
	dta c'Gwiazdy m',15,'wi',1,', aby inwestowa',3,' w armi',5,'.',0
txt_quote_betrayal_treasurer
	dta c'A mo',26,'e czas zbudowa',3,' sie',3,' wywiadowcz',1,'?',0
txt_quote_bigarmy_general
	dta c'mo',26,'e z',12,'upimy s',1,'siedni kraj?',0
txt_quote_crime_rises_executioner
	dta c'mo',26,'e jakie',19,' publiczne wieszanko?',0
txt_quote_crime_rises_general
	dta c'Zwi',5,'kszmy patrole! Wi',5,'cej wojska!',0
txt_quote_crime_rises_stargazer
	dta c'gwiazdy m',15,'wi',1,' igrzysk! ',0
txt_quote_crime_rises_treasurer
	dta c'Zbudujmy wi',5,'cej wi',5,'zie',14,'!',0
txt_quote_disease_medic
	dta c'Potrzeba pieni',5,'dzy na nowe szpitale.',0
txt_quote_disease_peasant
	dta c'Chcemy schroni',3,' si',5,' w murach miasta.',0
txt_quote_dragon_jester
	dta c'Najlepszy moment by pozby',3,' si',5,' dziewic!',0
txt_quote_dragon_knight
	dta c'Pozw',15,'l Panie, ',26,'e spr',15,'buje ubi',3,' gada.',0
txt_quote_dragon_peasant
	dta c'Panie wy',19,'lij armi',5,', chro',14,' nasz dobytek.',0
txt_quote_enemy_approach_general
	dta c'Panie, og',12,'o',19,'my powszechn',1,' mobilizacj',5,'!',0
txt_quote_enemy_approach_knight
	dta c'Pozw',15,'l Panie, ',26,'e wzmocnimy stra',26,'e.',0
txt_quote_give_gold_bishop
	dta c'Katedra popada w ruin',5,', wspom',15,26,'...',0
txt_quote_give_gold_general
	dta c'Musimy doposa',26,'y',3,' nowych rekrut',15,'w.',0
txt_quote_give_gold_knight
	dta c'Zorganizujmy turniej rycerski!',0
txt_quote_give_gold_medic
	dta c'w szpitalach brak medykament',15,'w.',0
txt_quote_give_gold_peasant
	dta c'Plony s',12,'abe, susza, ',26,'y',3,' nie ma za co...',0
txt_quote_luck_check_bishop
	dta c'Hojna ofiara pomo',26,'e uzyska',3,' ',12,'aski...',0
txt_quote_luck_check_executioner
	dta c'Zetnijmy kogo',19,' na chybi',12,' trafi',12,'!',0
txt_quote_luck_check_jester
	dta c'Mo',26,'e zagramy partyjk',5,' Wista?',0
txt_quote_luck_check_medic
	dta c'Mam dla Pana nowy lek z dalekiego kraju',0
txt_quote_luck_check_stargazer
	dta c'Czy postawi',3,' najja',19,'niejszemu horoskop?',0
txt_quote_luck_check_treasurer
	dta c'Zainwestujmy w drogocenne kruszce!',0
txt_quote_neardeath_death
	dta c'Mo',26,'esz po',19,'wi',5,'ci',3,' ',26,'ycie kilku poddanych.',0
txt_quote_trade_devil
	dta c'Za Tw',1,' dusze, bogactwa oddam wielkie.',0
txt_quote_unhappy_bishop
	dta c'mo',26,'e trzeba urz',1,'dzi',3,' wielk',1,' procesj',5,'?',0
txt_quote_welcome_angel
	dta c'Oferuj',5,' swe ',12,'aski za hojn',1,' ofiar',5,'.',0
txt_yes_generosity
	dta c'Znaj m',1,' hojno',19,3,'!',0
txt_yes_great_idea
	dta c'Wspania',12,'y pomys',12,'!',0
txt_yes_let_it_be
	dta c'Niech ci b',5,'dzie',0
txt_yes_ofc
	dta c'Oczywi',19,'cie!',0
txt_yes_yes
	dta c'Niech tak b',5,'dzie',0
; strings size: 1702 bytes

; ********************** actors (count:12)

actor_bishop
	dta a(face_bishop)
	dta c'Arcybiskup Jan Rzygo',14,0
actor_stargazer
	dta a(face_stargazer)
	dta c'Astronom ',24,'yros',12,'aw Lupa',0
actor_treasurer
	dta a(face_trasurer)
	dta c'Skarbnik Jutrowuj ',24,'y',12,'ak',0
actor_executioner
	dta a(face_executioner)
	dta c'Kat Lubomir Ucieszek',0
actor_jester
	dta a(face_jester)
	dta c'B',12,'azen M',19,'cigniew Ponur',0
actor_medic
	dta a(face_medic)
	dta c'Medyk Cz',5,'stogoj Szczyka',12,0
actor_general
	dta a(face_general)
	dta c'Genera',12,' Siemirad Zajad',12,'o',0
actor_peasant
	dta a(face_peasant)
	dta c'Gospodarz Czes',12,'aw Sporysz',0
actor_death
	dta a(face_death)
	dta c'Nieub',12,'agana i Ostateczna Pani ',4,'mier',3,0
actor_devil
	dta a(face_devil)
	dta c'Okrutny Arcyksi',1,26,'e Piekie',12,' Zenon',0
actor_angel
	dta a(face_angel)
	dta c'Starszy Archanio',12,' Konstaty Gardzi',12,12,'o',0
actor_knight
	dta a(face_knight)
	dta c'Rycerz Zawiesza Szwarny',0
; actors size: 344 bytes

; ********************** cards

card_give_gold_bishop
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_bishop) ; actor pointer
	dta a(txt_desc_give_gold) ; common description / question
	; NajjaĹ›niejszy Panie, potrzeba nam zĹ‚ota
	dta a(txt_quote_give_gold_bishop) ; actor sentence
	; Katedra popada w ruinÄ™, wspomĂłĹĽ...
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(140) ; 0b10001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-100) ; money
	dta b(2,2) ; happines
	dta b(5,10) ; church

	;resource change for no
	dta b(12) ; 0b1100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(-1,-1) ; happines
	dta b(-2,-5) ; church

	;requirements
	dta 0 ; requirement count (max 2)

card_give_gold_general
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_general) ; actor pointer
	dta a(txt_desc_give_gold) ; common description / question
	; NajjaĹ›niejszy Panie, potrzeba nam zĹ‚ota
	dta a(txt_quote_give_gold_general) ; actor sentence
	; Musimy doposaĹĽyÄ‡ nowych rekrutĂłw.
	dta a(txt_yes_ofc) ; yes response
	dta a(txt_no_no_chance) ; No response

	;resource change for yes
	dta b(168) ; 0b10101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-100) ; money
	dta a(10,10) ; army
	dta b(2,3) ; happines

	;resource change for no
	dta b(8) ; 0b1000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(-1,-1) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_give_gold_medic
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_medic) ; actor pointer
	dta a(txt_desc_give_gold) ; common description / question
	; NajjaĹ›niejszy Panie, potrzeba nam zĹ‚ota
	dta a(txt_quote_give_gold_medic) ; actor sentence
	; w szpitalach brak medykamentĂłw.
	dta a(txt_yes_yes) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(136) ; 0b10001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-100) ; money
	dta b(2,5) ; happines

	;resource change for no
	dta b(80) ; 0b1010000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-5) ; population
	dta b(-1,-1) ; health

	;requirements
	dta 0 ; requirement count (max 2)

card_crime_rises_executioner
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_executioner) ; actor pointer
	dta a(txt_desc_crime_rises) ; common description / question
	; PrzestÄ™pczoĹ›Ä‡ roĹ›nie JaĹ›niepanie
	dta a(txt_quote_crime_rises_executioner) ; actor sentence
	; moĹĽe jakieĹ› publiczne wieszanko?
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_no_way) ; No response

	;resource change for yes
	dta b(76) ; 0b1001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-20) ; population
	dta b(-1,-3) ; happines
	dta b(-2,2) ; church

	;resource change for no
	dta b(128) ; 0b10000000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-150,-50) ; money

	;requirements
	dta 0 ; requirement count (max 2)

card_crime_rises_stargazer
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_stargazer) ; actor pointer
	dta a(txt_desc_crime_rises) ; common description / question
	; PrzestÄ™pczoĹ›Ä‡ roĹ›nie JaĹ›niepanie
	dta a(txt_quote_crime_rises_stargazer) ; actor sentence
	; gwiazdy mĂłwiÄ… igrzysk!
	dta a(txt_yes_let_it_be) ; yes response
	dta a(txt_no_no_way) ; No response

	;resource change for yes
	dta b(200) ; 0b11001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-100) ; money
	dta a(5,10) ; population
	dta b(1,3) ; happines

	;resource change for no
	dta b(136) ; 0b10001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-150,-50) ; money
	dta b(-1,-5) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_crime_rises_treasurer
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_treasurer) ; actor pointer
	dta a(txt_desc_crime_rises) ; common description / question
	; PrzestÄ™pczoĹ›Ä‡ roĹ›nie JaĹ›niepanie
	dta a(txt_quote_crime_rises_treasurer) ; actor sentence
	; Zbudujmy wiÄ™cej wiÄ™zieĹ„!
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_no_chance) ; No response

	;resource change for yes
	dta b(168) ; 0b10101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-100) ; money
	dta a(2,10) ; army
	dta b(0,3) ; happines

	;resource change for no
	dta b(216) ; 0b11011000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-150,-50) ; money
	dta a(-2,-10) ; population
	dta b(-1,0) ; health
	dta b(0,-3) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_luck_check_jester
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_jester) ; actor pointer
	dta a(txt_desc_luck_check) ; common description / question
	; Zobaczmy czy sprzyja wĹ‚adcy szczÄ™Ĺ›cie
	dta a(txt_quote_luck_check_jester) ; actor sentence
	; MoĹĽe zagramy partyjkÄ™ Wista?
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(128) ; 0b10000000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,100) ; money

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 0 ; requirement count (max 2)

card_enemy_approach_knight
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_knight) ; actor pointer
	dta a(txt_desc_enemy_approach) ; common description / question
	; Wrogowie stojÄ… u bram miasta!
	dta a(txt_quote_enemy_approach_knight) ; actor sentence
	; PozwĂłl Panie, ĹĽe wzmocnimy straĹĽe.
	dta a(txt_yes_ofc) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(168) ; 0b10101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-60) ; money
	dta a(5,10) ; army
	dta b(1,3) ; happines

	;resource change for no
	dta b(120) ; 0b1111000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-30) ; population
	dta a(-2,-5) ; army
	dta b(-1,-1) ; health
	dta b(-1,-1) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_give_gold_peasant
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_peasant) ; actor pointer
	dta a(txt_desc_give_gold) ; common description / question
	; NajjaĹ›niejszy Panie, potrzeba nam zĹ‚ota
	dta a(txt_quote_give_gold_peasant) ; actor sentence
	; Plony sĹ‚abe, susza, ĹĽyÄ‡ nie ma za co...
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_go_away) ; No response

	;resource change for yes
	dta b(200) ; 0b11001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-40) ; money
	dta a(0,30) ; population
	dta b(0,10) ; happines

	;resource change for no
	dta b(72) ; 0b1001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(0,-50) ; population
	dta b(0,-5) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_betrayal_jester
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_jester) ; actor pointer
	dta a(txt_desc_betrayal) ; common description / question
	; Mam wraĹĽenie Panie, ĹĽe ktoĹ› spiskuje
	dta a(txt_quote_betrayal_jester) ; actor sentence
	; powinniĹ›my ograniczyÄ‡ wpĹ‚ywy koĹ›cioĹ‚a.
	dta a(txt_yes_yes) ; yes response
	dta a(txt_no_no_way) ; No response

	;resource change for yes
	dta b(204) ; 0b11001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(0,50) ; money
	dta a(0,-20) ; population
	dta b(0,-5) ; happines
	dta b(-2,-8) ; church

	;resource change for no
	dta b(4) ; 0b100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(0,3) ; church

	;requirements
	dta 0 ; requirement count (max 2)

card_luck_check_bishop
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_bishop) ; actor pointer
	dta a(txt_desc_luck_check) ; common description / question
	; Zobaczmy czy sprzyja wĹ‚adcy szczÄ™Ĺ›cie
	dta a(txt_quote_luck_check_bishop) ; actor sentence
	; Hojna ofiara pomoĹĽe uzyskaÄ‡ Ĺ‚aski...
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_no_chance) ; No response

	;resource change for yes
	dta b(212) ; 0b11010100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-100) ; money
	dta a(-10,10) ; population
	dta b(0,3) ; health
	dta b(2,8) ; church

	;resource change for no
	dta b(12) ; 0b1100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(0,-3) ; happines
	dta b(-5,-10) ; church

	;requirements
	dta 0 ; requirement count (max 2)

card_betrayal_stargazer
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_stargazer) ; actor pointer
	dta a(txt_desc_betrayal) ; common description / question
	; Mam wraĹĽenie Panie, ĹĽe ktoĹ› spiskuje
	dta a(txt_quote_betrayal_stargazer) ; actor sentence
	; Gwiazdy mĂłwiÄ…, aby inwestowaÄ‡ w armiÄ™.
	dta a(txt_yes_ofc) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(168) ; 0b10101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-50,-100) ; money
	dta a(5,10) ; army
	dta b(-2,2) ; happines

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 0 ; requirement count (max 2)

card_luck_check_stargazer
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_stargazer) ; actor pointer
	dta a(txt_desc_luck_check) ; common description / question
	; Zobaczmy czy sprzyja wĹ‚adcy szczÄ™Ĺ›cie
	dta a(txt_quote_luck_check_stargazer) ; actor sentence
	; Czy postawiÄ‡ najjaĹ›niejszemu horoskop?
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(220) ; 0b11011100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-30,-80) ; money
	dta a(-20,20) ; population
	dta b(-2,2) ; health
	dta b(-5,5) ; happines
	dta b(-1,-3) ; church

	;resource change for no
	dta b(4) ; 0b100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(2,5) ; church

	;requirements
	dta 0 ; requirement count (max 2)

card_luck_check_treasurer
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_treasurer) ; actor pointer
	dta a(txt_desc_luck_check) ; common description / question
	; Zobaczmy czy sprzyja wĹ‚adcy szczÄ™Ĺ›cie
	dta a(txt_quote_luck_check_treasurer) ; actor sentence
	; Zainwestujmy w drogocenne kruszce!
	dta a(txt_yes_yes) ; yes response
	dta a(txt_no_no_way) ; No response

	;resource change for yes
	dta b(140) ; 0b10001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-200,200) ; money
	dta b(-3,3) ; happines
	dta b(-1,-3) ; church

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 0 ; requirement count (max 2)

card_give_gold_knight
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_knight) ; actor pointer
	dta a(txt_desc_give_gold) ; common description / question
	; NajjaĹ›niejszy Panie, potrzeba nam zĹ‚ota
	dta a(txt_quote_give_gold_knight) ; actor sentence
	; Zorganizujmy turniej rycerski!
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(236) ; 0b11101100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-70,-120) ; money
	dta a(5,20) ; population
	dta a(10,20) ; army
	dta b(2,5) ; happines
	dta b(1,3) ; church

	;resource change for no
	dta b(40) ; 0b101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-5,-10) ; army
	dta b(-3,-8) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_luck_check_medic
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_medic) ; actor pointer
	dta a(txt_desc_luck_check) ; common description / question
	; Zobaczmy czy sprzyja wĹ‚adcy szczÄ™Ĺ›cie
	dta a(txt_quote_luck_check_medic) ; actor sentence
	; Mam dla Pana nowy lek z dalekiego kraju
	dta a(txt_yes_yes) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(144) ; 0b10010000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,0) ; money
	dta b(-5,5) ; health

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 0 ; requirement count (max 2)

card_enemy_approach_general
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_general) ; actor pointer
	dta a(txt_desc_enemy_approach) ; common description / question
	; Wrogowie stojÄ… u bram miasta!
	dta a(txt_quote_enemy_approach_general) ; actor sentence
	; Panie, ogĹ‚oĹ›my powszechnÄ… mobilizacjÄ™!
	dta a(txt_yes_ofc) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(160) ; 0b10100000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-60) ; money
	dta a(10,15) ; army

	;resource change for no
	dta b(120) ; 0b1111000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-30,-100) ; population
	dta a(0,-10) ; army
	dta b(0,-3) ; health
	dta b(0,-2) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_dragon_peasant
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_peasant) ; actor pointer
	dta a(txt_desc_dragon) ; common description / question
	; W krĂłlestwie grasuje okrutny smok!
	dta a(txt_quote_dragon_peasant) ; actor sentence
	; Panie wyĹ›lij armiÄ™, chroĹ„ nasz dobytek.
	dta a(txt_yes_ofc) ; yes response
	dta a(txt_no_go_away) ; No response

	;resource change for yes
	dta b(104) ; 0b1101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(0,10) ; population
	dta a(-10,-20) ; army
	dta b(0,5) ; happines

	;resource change for no
	dta b(72) ; 0b1001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-50) ; population
	dta b(-2,-5) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_betrayal_executioner
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_executioner) ; actor pointer
	dta a(txt_desc_betrayal) ; common description / question
	; Mam wraĹĽenie Panie, ĹĽe ktoĹ› spiskuje
	dta a(txt_quote_betrayal_executioner) ; actor sentence
	; MoĹĽe zetniemy na pokaz kilku zdrajcĂłw?
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(76) ; 0b1001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-50) ; population
	dta b(-1,-5) ; happines
	dta b(0,5) ; church

	;resource change for no
	dta b(144) ; 0b10010000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-100,-10) ; money
	dta b(-2,-5) ; health

	;requirements
	dta 0 ; requirement count (max 2)

card_betrayal_bishop
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_bishop) ; actor pointer
	dta a(txt_desc_betrayal) ; common description / question
	; Mam wraĹĽenie Panie, ĹĽe ktoĹ› spiskuje
	dta a(txt_quote_betrayal_bishop) ; actor sentence
	; WypÄ™dĹşmy wrogĂłw koĹ›cioĹ‚a z kraju.
	dta a(txt_yes_let_it_be) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(204) ; 0b11001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(0,10) ; money
	dta a(-10,-100) ; population
	dta b(-5,-10) ; happines
	dta b(5,10) ; church

	;resource change for no
	dta b(164) ; 0b10100100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-50) ; money
	dta a(3,8) ; army
	dta b(-2,-5) ; church

	;requirements
	dta 0 ; requirement count (max 2)

card_luck_check_executioner
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_executioner) ; actor pointer
	dta a(txt_desc_luck_check) ; common description / question
	; Zobaczmy czy sprzyja wĹ‚adcy szczÄ™Ĺ›cie
	dta a(txt_quote_luck_check_executioner) ; actor sentence
	; Zetnijmy kogoĹ› na chybiĹ‚ trafiĹ‚!
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(204) ; 0b11001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-50,50) ; money
	dta a(-1,-5) ; population
	dta b(-5,5) ; happines
	dta b(-3,3) ; church

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 0 ; requirement count (max 2)

card_crime_rises_general
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_general) ; actor pointer
	dta a(txt_desc_crime_rises) ; common description / question
	; PrzestÄ™pczoĹ›Ä‡ roĹ›nie JaĹ›niepanie
	dta a(txt_quote_crime_rises_general) ; actor sentence
	; ZwiÄ™kszmy patrole! WiÄ™cej wojska!
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_no_way) ; No response

	;resource change for yes
	dta b(232) ; 0b11101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(40,120) ; money
	dta a(0,10) ; population
	dta a(3,10) ; army
	dta b(1,5) ; happines

	;resource change for no
	dta b(232) ; 0b11101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-80) ; money
	dta a(-5,-30) ; population
	dta a(-1,-5) ; army
	dta b(-1,-3) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_dragon_jester
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_jester) ; actor pointer
	dta a(txt_desc_dragon) ; common description / question
	; W krĂłlestwie grasuje okrutny smok!
	dta a(txt_quote_dragon_jester) ; actor sentence
	; Najlepszy moment by pozbyÄ‡ siÄ™ dziewic!
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(76) ; 0b1001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-20) ; population
	dta b(-1,-3) ; happines
	dta b(-2,-5) ; church

	;resource change for no
	dta b(232) ; 0b11101000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-50,-10) ; money
	dta a(-50,-150) ; population
	dta a(-5,-20) ; army
	dta b(0,-5) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_dragon_knight
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_knight) ; actor pointer
	dta a(txt_desc_dragon) ; common description / question
	; W krĂłlestwie grasuje okrutny smok!
	dta a(txt_quote_dragon_knight) ; actor sentence
	; PozwĂłl Panie, ĹĽe sprĂłbuje ubiÄ‡ gada.
	dta a(txt_yes_ofc) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(184) ; 0b10111000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(100,300) ; money
	dta a(-10,-50) ; army
	dta b(-1,-1) ; health
	dta b(2,5) ; happines

	;resource change for no
	dta b(200) ; 0b11001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-50) ; money
	dta a(-30,-100) ; population
	dta b(-2,-5) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_disease_medic
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_medic) ; actor pointer
	dta a(txt_desc_disease) ; common description / question
	; WybuchĹ‚a zaraza, czarna Ĺ›mierÄ‡ w kraju
	dta a(txt_quote_disease_medic) ; actor sentence
	; Potrzeba pieniÄ™dzy na nowe szpitale.
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_no_chance) ; No response

	;resource change for yes
	dta b(136) ; 0b10001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-50,-150) ; money
	dta b(2,5) ; happines

	;resource change for no
	dta b(124) ; 0b1111100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-100) ; population
	dta a(-2,-5) ; army
	dta b(-1,-5) ; health
	dta b(-1,-5) ; happines
	dta b(3,8) ; church

	;requirements
	dta 0 ; requirement count (max 2)

card_disease_peasant
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_peasant) ; actor pointer
	dta a(txt_desc_disease) ; common description / question
	; WybuchĹ‚a zaraza, czarna Ĺ›mierÄ‡ w kraju
	dta a(txt_quote_disease_peasant) ; actor sentence
	; Chcemy schroniÄ‡ siÄ™ w murach miasta.
	dta a(txt_yes_let_it_be) ; yes response
	dta a(txt_no_go_away) ; No response

	;resource change for yes
	dta b(252) ; 0b11111100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(10,50) ; money
	dta a(-10,-40) ; population
	dta a(-1,-5) ; army
	dta b(0,-2) ; health
	dta b(2,8) ; happines
	dta b(2,5) ; church

	;resource change for no
	dta b(72) ; 0b1001000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-60) ; population
	dta b(-2,-5) ; happines

	;requirements
	dta 0 ; requirement count (max 2)

card_betrayal_treasurer
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_treasurer) ; actor pointer
	dta a(txt_desc_betrayal) ; common description / question
	; Mam wraĹĽenie Panie, ĹĽe ktoĹ› spiskuje
	dta a(txt_quote_betrayal_treasurer) ; actor sentence
	; A moĹĽe czas zbudowaÄ‡ sieÄ‡ wywiadowczÄ…?
	dta a(txt_yes_yes) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(236) ; 0b11101100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-20,-50) ; money
	dta a(-10,-50) ; population
	dta a(2,5) ; army
	dta b(-1,-1) ; happines
	dta b(2,5) ; church

	;resource change for no
	dta b(16) ; 0b10000 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(-2,-5) ; health

	;requirements
	dta 0 ; requirement count (max 2)

card_neardeath_death
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_death) ; actor pointer
	dta a(txt_desc_neardeath) ; common description / question
	; PodupadĹ‚eĹ› na zdrowiu jaĹ›niepanie.
	dta a(txt_quote_neardeath_death) ; actor sentence
	; MoĹĽesz poĹ›wiÄ™ciÄ‡ ĹĽycie kilku poddanych.
	dta a(txt_yes_yes) ; yes response
	dta a(txt_no_go_away) ; No response

	;resource change for yes
	dta b(92) ; 0b1011100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-50,-150) ; population
	dta b(10,20) ; health
	dta b(-5,-10) ; happines
	dta b(-3,-5) ; church

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 1 ; requirement count (max 2)
	dta 4 ; reqired_param - 0:none 1:money 2:population 3:army 4:health 5:happines 6:church 7:year
	dta 2 ; reqired_how - 0:equal 1:greater than 2:lower than 3:gte 4:lte
	dta f(20) ; required amount

card_trade_devil
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_devil) ; actor pointer
	dta a(txt_desc_trade) ; common description / question
	; Witam najjaĹ›niejszego, pohandlujemy?
	dta a(txt_quote_trade_devil) ; actor sentence
	; Za TwÄ… dusze, bogactwa oddam wielkie.
	dta a(txt_yes_let_it_be) ; yes response
	dta a(txt_no_no_way) ; No response

	;resource change for yes
	dta b(156) ; 0b10011100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(200,500) ; money
	dta b(0,-5) ; health
	dta b(0,-5) ; happines
	dta b(-3,-6) ; church

	;resource change for no
	dta b(0) ; 0b0 - bits 7:money 6:population 5:army 4:health 3:happines 2:church

	;requirements
	dta 1 ; requirement count (max 2)
	dta 6 ; reqired_param - 0:none 1:money 2:population 3:army 4:health 5:happines 6:church 7:year
	dta 2 ; reqired_how - 0:equal 1:greater than 2:lower than 3:gte 4:lte
	dta f(30) ; required amount

card_welcome_angel
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_angel) ; actor pointer
	dta a(txt_desc_welcome) ; common description / question
	; Witam sprawiedliwego jaĹ›niepana.
	dta a(txt_quote_welcome_angel) ; actor sentence
	; OferujÄ™ swe Ĺ‚aski za hojnÄ… ofiarÄ™.
	dta a(txt_yes_generosity) ; yes response
	dta a(txt_no_rather_no) ; No response

	;resource change for yes
	dta b(252) ; 0b11111100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-200,-300) ; money
	dta a(30,60) ; population
	dta a(10,20) ; army
	dta b(3,5) ; health
	dta b(1,5) ; happines
	dta b(5,10) ; church

	;resource change for no
	dta b(4) ; 0b100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(-10,-20) ; church

	;requirements
	dta 1 ; requirement count (max 2)
	dta 6 ; reqired_param - 0:none 1:money 2:population 3:army 4:health 5:happines 6:church 7:year
	dta 1 ; reqired_how - 0:equal 1:greater than 2:lower than 3:gte 4:lte
	dta f(70) ; required amount

card_bigarmy_general
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_general) ; actor pointer
	dta a(txt_desc_bigarmy) ; common description / question
	; Nasza armia jest juĹĽ potÄ™ĹĽna,
	dta a(txt_quote_bigarmy_general) ; actor sentence
	; moĹĽe zĹ‚upimy sÄ…siedni kraj?
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_overstatement) ; No response

	;resource change for yes
	dta b(236) ; 0b11101100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(200,500) ; money
	dta a(-10,-50) ; population
	dta a(-10,-30) ; army
	dta b(-3,-5) ; happines
	dta b(-1,-5) ; church

	;resource change for no
	dta b(4) ; 0b100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(2,5) ; church

	;requirements
	dta 1 ; requirement count (max 2)
	dta 3 ; reqired_param - 0:none 1:money 2:population 3:army 4:health 5:happines 6:church 7:year
	dta 1 ; reqired_how - 0:equal 1:greater than 2:lower than 3:gte 4:lte
	dta f(99) ; required amount

card_unhappy_bishop
	dta 0 ; type   0:resource_card 1:gamble_card
	dta a(actor_bishop) ; actor pointer
	dta a(txt_desc_unhappy) ; common description / question
	; Lud niespokojny ostatnimi czasy,
	dta a(txt_quote_unhappy_bishop) ; actor sentence
	; moĹĽe trzeba urzÄ…dziÄ‡ wielkÄ… procesjÄ™?
	dta a(txt_yes_great_idea) ; yes response
	dta a(txt_no_go_away) ; No response

	;resource change for yes
	dta b(140) ; 0b10001100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta a(-10,-50) ; money
	dta b(10,20) ; happines
	dta b(2,5) ; church

	;resource change for no
	dta b(4) ; 0b100 - bits 7:money 6:population 5:army 4:health 3:happines 2:church
	dta b(-1,-5) ; church

	;requirements
	dta 1 ; requirement count (max 2)
	dta 5 ; reqired_param - 0:none 1:money 2:population 3:army 4:health 5:happines 6:church 7:year
	dta 2 ; reqired_how - 0:equal 1:greater than 2:lower than 3:gte 4:lte
	dta f(30) ; required amount

; cards size: 984 bytes

; global data size: 4669 bytes

images_data
frame
; RLE compresed data. Size before 90 size after: 47
	dta $01,$2B,$0E,$00,$03,$AC,$A3,$0E,$AA,$03,$8F,$80,$0E,$00,$03,$03
	dta $F3,$0E,$FF,$03,$8F,$23,$0E,$00,$03,$8C,$A2,$0E,$AA,$03,$8F,$80
	dta $0E,$00,$03,$03,$F3,$0E,$FF,$03,$CF,$3F,$0E,$00,$01,$FC,$00
logo
; RLE compresed data. Size before 1600 size after: 881
	dta $24,$00,$03,$01,$40,$4A,$00,$03,$01,$40,$4A,$00,$03,$05,$50,$42
	dta $00,$13,$01,$50,$00,$00,$05,$50,$00,$00,$05,$40,$3A,$00,$13,$02
	dta $54,$00,$00,$55,$55,$00,$00,$15,$80,$3A,$00,$13,$03,$55,$50,$01
	dta $55,$55,$40,$05,$55,$C0,$3C,$00,$0F,$55,$54,$01,$55,$55,$40,$15
	dta $55,$3E,$00,$0F,$95,$55,$01,$A5,$5A,$40,$55,$56,$3E,$00,$0F,$D5
	dta $6A,$02,$F9,$6F,$80,$A9,$57,$3E,$00,$0F,$25,$BF,$03,$0D,$70,$C0
	dta $FE,$58,$3E,$00,$0F,$35,$C0,$00,$01,$40,$00,$03,$5C,$3E,$00,$0F
	dta $05,$40,$00,$05,$50,$00,$01,$50,$3E,$00,$0F,$09,$50,$00,$15,$54
	dta $00,$05,$60,$3E,$00,$0F,$0D,$55,$00,$55,$55,$00,$55,$70,$3E,$00
	dta $01,$01,$0A,$55,$01,$40,$3E,$00,$01,$01,$0A,$55,$01,$40,$3E,$00
	dta $01,$02,$0A,$55,$01,$80,$3E,$00,$0F,$03,$55,$56,$AA,$AA,$95,$55
	dta $C0,$40,$00,$0B,$AA,$AB,$FF,$FF,$EA,$AA,$42,$00,$0B,$FF,$FC,$00
	dta $00,$3F,$FF,$C2,$00,$0B,$05,$50,$00,$00,$01,$54,$14,$00,$07,$15
	dta $55,$55,$54,$24,$00,$23,$09,$50,$00,$00,$01,$58,$00,$55,$55,$50
	dta $00,$55,$00,$00,$05,$50,$00,$15,$04,$55,$1F,$00,$15,$55,$55,$54
	dta $00,$05,$55,$55,$00,$00,$54,$00,$15,$55,$55,$04,$00,$0D,$0D,$54
	dta $00,$00,$05,$5C,$05,$04,$55,$21,$00,$95,$40,$00,$15,$60,$00,$15
	dta $AA,$AA,$95,$40,$15,$55,$55,$54,$00,$04,$55,$07,$50,$00,$54,$00
	dta $04,$55,$A1,$40,$00,$00,$02,$54,$00,$00,$05,$60,$15,$55,$A5,$55
	dta $40,$E5,$50,$00,$55,$B0,$00,$15,$FF,$FF,$E5,$40,$16,$AA,$AA,$A8
	dta $01,$55,$6A,$95,$54,$00,$54,$01,$55,$AA,$95,$40,$00,$00,$03,$55
	dta $00,$00,$15,$70,$55,$AA,$FA,$A5,$50,$39,$54,$01,$56,$C0,$00,$15
	dta $00,$00,$35,$40,$17,$FF,$FF,$FC,$05,$5A,$BF,$EA,$55,$00,$54,$01
	dta $5A,$FF,$EA,$80,$04,$00,$2B,$95,$00,$00,$15,$81,$56,$FF,$0F,$F9
	dta $54,$0E,$55,$05,$5B,$00,$00,$15,$00,$00,$05,$40,$14,$04,$00,$17
	dta $15,$6F,$C0,$3F,$AA,$00,$54,$01,$5F,$00,$3F,$C0,$04,$00,$2B,$E5
	dta $40,$00,$56,$C1,$5B,$00,$00,$0E,$54,$03,$95,$55,$6C,$00,$00,$15
	dta $00,$00,$15,$40,$14,$04,$00,$11,$15,$B0,$00,$00,$FF,$00,$54,$01
	dta $55,$0A,$00,$21,$35,$50,$01,$57,$01,$5C,$00,$00,$03,$54,$00,$E5
	dta $55,$B0,$00,$00,$15,$04,$55,$0D,$40,$15,$55,$55,$40,$15,$C0,$06
	dta $00,$09,$54,$01,$55,$55,$54,$06,$00,$0B,$09,$50,$01,$58,$01,$50
	dta $04,$00,$0F,$54,$00,$35,$56,$C0,$00,$00,$15,$04,$55,$21,$80,$15
	dta $55,$55,$40,$15,$00,$00,$55,$55,$40,$54,$02,$95,$55,$55,$40,$04
	dta $00,$0B,$0D,$54,$05,$5C,$01,$50,$04,$00,$07,$54,$00,$15,$55,$04
	dta $00,$29,$15,$55,$55,$5A,$C0,$16,$AA,$AA,$80,$15,$00,$00,$55,$55
	dta $40,$54,$03,$EA,$A5,$55,$40,$04,$00,$49,$02,$55,$15,$60,$01,$50
	dta $00,$00,$01,$54,$00,$55,$95,$40,$00,$00,$15,$AA,$A5,$5F,$00,$17
	dta $FF,$FF,$C0,$15,$00,$00,$AA,$95,$80,$54,$00,$3F,$FA,$A5,$50,$04
	dta $00,$2B,$03,$95,$15,$B0,$01,$54,$00,$00,$01,$58,$01,$56,$E5,$50
	dta $00,$00,$15,$FF,$F9,$54,$00,$14,$04,$00,$17,$25,$40,$00,$FF,$55
	dta $C0,$54,$00,$00,$0F,$F9,$50,$06,$00,$29,$D5,$55,$C0,$02,$55,$40
	dta $00,$15,$5C,$05,$5B,$39,$54,$00,$00,$15,$00,$0E,$55,$00,$14,$04
	dta $00,$0D,$35,$54,$00,$01,$56,$00,$54,$04,$00,$03,$05,$50,$06,$00
	dta $09,$25,$56,$00,$03,$95,$04,$55,$21,$60,$15,$6C,$0E,$55,$00,$00
	dta $15,$00,$03,$95,$40,$15,$55,$55,$54,$09,$04,$55,$07,$57,$00,$54
	dta $05,$04,$55,$01,$60,$06,$00,$3F,$39,$5B,$00,$00,$E9,$55,$55,$56
	dta $B0,$55,$B0,$03,$95,$40,$00,$15,$00,$00,$E5,$40,$15,$55,$55,$54
	dta $0E,$95,$55,$55,$68,$00,$54,$05,$04,$55,$01,$B0,$06,$00,$47,$0E
	dta $6C,$00,$00,$3E,$95,$55,$6B,$C0,$56,$C0,$00,$E5,$40,$00,$15,$00
	dta $00,$35,$40,$15,$55,$55,$54,$03,$E9,$55,$56,$BC,$00,$54,$09,$55
	dta $55,$5A,$C0,$06,$00,$45,$03,$B0,$00,$00,$03,$EA,$AA,$BC,$00,$AB
	dta $00,$00,$3A,$80,$00,$2A,$00,$00,$0A,$80,$2A,$AA,$AA,$A8,$00,$3E
	dta $AA,$AB,$C0,$00,$A8,$0E,$AA,$AA,$AF,$0A,$00,$01,$C0,$04,$00,$3F
	dta $3F,$FF,$C0,$00,$FC,$00,$00,$0F,$C0,$00,$3F,$00,$00,$0F,$C0,$3F
	dta $FF,$FF,$FC,$00,$03,$FF,$FC,$00,$00,$FC,$03,$FF,$FF,$F0,$00,$00
	dta $00
tak_sprite
tak_s0  dta 192,192,249,249,249,249,249,249,249,249,249,249 ;XRLE
tak_s1  dta 62,60,252,248,249,249,243,243,240,224,231,231 ;XRLE
tak_s2  dta 252,124,124,60,60,60,156,156,28,12,204,204 ;XRLE
tak_s3  dta 243,227,199,143,31,63,63,31,143,199,227,243 ;XRLE
nie_sprite
nie_s0  dta 249,248,248,248,248,249,249,249,249,249,249,249 ;XRLE
nie_s1  dta 230,230,230,102,102,38,38,134,134,198,198,230 ;XRLE
nie_s2  dta 96,96,103,103,103,96,96,103,103,103,96,96 ;XRLE
nie_s3  dta 31,31,255,255,255,127,127,255,255,255,31,31 ;XRLE
status_bar
; RLE compresed data. Size before 58 size after: 29
	dta $03,$04,$40,$0A,$00,$03,$42,$40,$0A,$00,$03,$46,$40,$2A,$00,$03
	dta $48,$40,$0A,$00,$03,$4A,$40,$0A,$00,$03,$47,$40,$00
face_vox_regis
; RLE compresed data. Size before 320 size after: 264
	dta $14,$00,$03,$02,$C0,$0A,$00,$03,$01,$80,$06,$00,$7B,$18,$00,$19
	dta $A4,$00,$18,$00,$00,$15,$00,$55,$96,$00,$6C,$00,$00,$05,$40,$49
	dta $A2,$01,$A0,$00,$00,$06,$00,$01,$80,$00,$B0,$00,$00,$05,$80,$05
	dta $B0,$01,$B0,$00,$00,$01,$68,$15,$AC,$16,$80,$00,$00,$01,$55,$55
	dta $A9,$6A,$C0,$00,$00,$01,$55,$55,$AA,$AA,$C0,$04,$00,$07,$55,$56
	dta $EA,$AB,$06,$00,$07,$BF,$00,$00,$FF,$24,$00,$8B,$20,$02,$09,$60
	dta $80,$08,$00,$00,$10,$01,$27,$D8,$60,$24,$00,$00,$18,$09,$1C,$34
	dta $D8,$9C,$00,$00,$34,$07,$10,$04,$36,$70,$00,$00,$04,$04,$10,$04
	dta $09,$80,$00,$00,$06,$24,$10,$04,$27,$60,$00,$00,$0D,$1C,$10,$04
	dta $DC,$DC,$00,$00,$01,$90,$18,$24,$70,$34,$00,$00,$03,$70,$35,$5C
	dta $40,$04,$04,$00,$09,$C0,$0F,$F0,$C0,$0C,$20,$00,$AF,$05,$5C,$55
	dta $43,$54,$15,$35,$70,$07,$E4,$7F,$CD,$FD,$37,$1F,$D0,$04,$04,$40
	dta $07,$01,$04,$1C,$30,$04,$04,$40,$04,$00,$04,$36,$00,$05,$58,$55
	dta $04,$15,$04,$0D,$80,$07,$DC,$7F,$04,$3D,$04,$03,$60,$04,$18,$40
	dta $04,$01,$04,$00,$D0,$04,$34,$40,$06,$01,$04,$10,$10,$04,$04,$40
	dta $0D,$8D,$04,$18,$10,$04,$04,$55,$43,$57,$15,$35,$70,$0C,$0C,$FF
	dta $C0,$FC,$3F,$0F,$C0,$1E,$00,$00
face_angel
; RLE compresed data. Size before 320 size after: 309
	dta $12,$00,$07,$55,$55,$5A,$A0,$04,$00,$09,$05,$B0,$00,$00,$E6,$04
	dta $00,$01,$1B,$04,$00,$FF,$0E,$80,$00,$00,$18,$00,$56,$80,$02,$40
	dta $00,$00,$18,$05,$56,$A8,$02,$40,$28,$20,$04,$15,$5A,$AA,$09,$02
	dta $A8,$28,$00,$55,$5A,$AA,$80,$0A,$F8,$28,$00,$55,$5A,$AA,$80,$2B
	dta $E8,$1A,$01,$6A,$AF,$FA,$A0,$2F,$A8,$16,$01,$AF,$FF,$FE,$A0,$AE
	dta $AC,$16,$81,$AA,$BF,$FF,$A0,$BE,$FC,$15,$81,$A1,$B1,$FF,$E0,$BA
	dta $F8,$25,$80,$A5,$B5,$FF,$E2,$BB,$E8,$25,$A0,$AA,$BF,$FF,$C2,$EB
	dta $AC,$29,$60,$AA,$BF,$FF,$0A,$EF,$BC,$19,$68,$AA,$FF,$FF,$0A,$EE
	dta $BC,$1A,$58,$2A,$BF,$FC,$2A,$AA,$E8,$16,$A8,$2A,$BF,$FC,$2A,$AA
	dta $E8,$16,$A0,$2A,$03,$F0,$49,$00,$2A,$A8,$2A,$02,$0A,$BF,$C0,$FF
	dta $02,$A8,$28,$2A,$8A,$BF,$C3,$FF,$F0,$28,$20,$AA,$82,$BF,$0F,$AA
	dta $BF,$08,$02,$96,$A0,$00,$3E,$AA,$AB,$C8,$0A,$55,$04,$AA,$1D,$55
	dta $5A,$C0,$09,$55,$6A,$56,$A5,$55,$56,$B0,$25,$55,$55,$B1,$04,$55
	dta $09,$AC,$15,$55,$55,$B1,$04,$55,$09,$AC,$15,$55,$56,$BC,$04,$55
	dta $79,$A8,$15,$55,$56,$BC,$55,$56,$55,$68,$15,$55,$5A,$BC,$55,$55
	dta $95,$68,$15,$55,$5A,$BF,$D5,$55,$95,$68,$15,$55,$FA,$BF,$C1,$55
	dta $65,$68,$15,$5F,$5A,$BF,$D4,$D5,$65,$68,$17,$F5,$5A,$BF,$D5,$4D
	dta $55,$68,$15,$55,$5A,$BF,$D5,$57,$F5,$68,$15,$55,$5A,$BF,$04,$55
	dta $09,$A8,$15,$55,$56,$BF,$04,$55,$11,$AC,$15,$55,$55,$F5,$55,$55
	dta $5A,$BC,$0E,$00,$00
face_peasant
; RLE compresed data. Size before 320 size after: 250
	dta $72,$00,$07,$01,$10,$08,$80,$04,$00,$09,$01,$45,$55,$56,$88,$06
	dta $00,$07,$55,$6A,$AA,$A0,$04,$00,$09,$05,$56,$AA,$AB,$AA,$04,$00
	dta $09,$01,$5A,$AA,$AF,$E8,$04,$00,$09,$01,$6A,$AA,$BF,$FA,$06,$00
	dta $07,$6B,$FA,$FF,$F8,$06,$00,$07,$6A,$AF,$FF,$F8,$04,$00,$09,$02
	dta $69,$6B,$D7,$FB,$04,$00,$09,$02,$E9,$2B,$C7,$F3,$04,$00,$09,$02
	dta $EA,$AB,$FF,$F3,$06,$00,$07,$AA,$AB,$FF,$FC,$06,$00,$07,$3A,$A4
	dta $FF,$30,$06,$00,$07,$3E,$BC,$3C,$30,$06,$00,$07,$2F,$FC,$00,$F0
	dta $06,$00,$07,$2B,$FC,$03,$F0,$06,$00,$07,$2A,$11,$3F,$F0,$06,$00
	dta $07,$2A,$AB,$FF,$C0,$04,$00,$45,$05,$FA,$AB,$FF,$C2,$80,$00,$05
	dta $55,$7F,$AB,$FC,$06,$AA,$80,$15,$55,$5F,$FF,$C0,$55,$5A,$A8,$15
	dta $55,$57,$FC,$05,$55,$55,$68,$15,$55,$55,$7F,$04,$55,$09,$54,$15
	dta $55,$55,$5D,$04,$55,$09,$54,$15,$55,$59,$79,$04,$55,$19,$54,$15
	dta $55,$56,$79,$D5,$55,$55,$54,$15,$55,$55,$79,$04,$55,$09,$54,$19
	dta $55,$55,$E9,$04,$55,$29,$54,$25,$55,$65,$E9,$55,$55,$56,$54,$25
	dta $55,$59,$E9,$D5,$55,$56,$94,$15,$55,$55,$E9,$04,$55,$09,$A4,$15
	dta $55,$55,$E9,$04,$55,$01,$A4,$0E,$00,$00
face_devil
; RLE compresed data. Size before 320 size after: 283
	dta $42,$00,$07,$50,$00,$01,$60,$04,$00,$09,$05,$C0,$00,$00,$1B,$04
	dta $00,$01,$1B,$04,$00,$09,$06,$C0,$00,$00,$6C,$04,$00,$09,$06,$C0
	dta $00,$00,$6C,$04,$00,$41,$06,$F0,$00,$00,$6B,$01,$56,$AA,$06,$F0
	dta $00,$00,$1A,$D5,$56,$AA,$9B,$C0,$00,$00,$1A,$95,$55,$AA,$AF,$C0
	dta $00,$00,$06,$55,$57,$FA,$AF,$04,$00,$09,$0A,$56,$AB,$FF,$AC,$04
	dta $00,$09,$05,$56,$AA,$FF,$E8,$04,$00,$09,$05,$5A,$AA,$FF,$E8,$04
	dta $00,$09,$15,$5A,$EA,$FC,$E8,$04,$00,$09,$15,$5A,$12,$C4,$EA,$04
	dta $00,$AF,$15,$6A,$AA,$FF,$EA,$80,$00,$00,$15,$6A,$AA,$FF,$EA,$80
	dta $00,$00,$55,$6A,$AB,$FF,$EA,$A0,$00,$00,$55,$7A,$AA,$FF,$EA,$A0
	dta $00,$00,$55,$7A,$AA,$BF,$EA,$A8,$00,$01,$55,$BA,$B0,$0F,$FA,$AA
	dta $00,$01,$56,$BE,$AF,$FF,$3F,$AA,$00,$05,$5A,$FE,$AB,$FF,$0F,$FE
	dta $80,$15,$AB,$F3,$AF,$FF,$00,$FF,$F0,$16,$FF,$FC,$FF,$FC,$03,$FF
	dta $FC,$1F,$FF,$FF,$00,$00,$0F,$FF,$FC,$3F,$04,$FF,$13,$00,$FF,$C0
	dta $0C,$30,$00,$FF,$FF,$CF,$FC,$06,$00,$7B,$0F,$FA,$BF,$C0,$0F,$F0
	dta $0F,$FC,$03,$F8,$BF,$03,$FF,$FC,$3F,$FF,$C0,$FA,$BC,$3F,$FF,$FC
	dta $3F,$FF,$F0,$3F,$E0,$FF,$FF,$EC,$3F,$FF,$FC,$0F,$C2,$FF,$FE,$FC
	dta $3F,$FF,$FF,$03,$03,$EE,$EF,$FC,$3F,$FF,$FF,$30,$33,$FF,$FF,$FC
	dta $3F,$FF,$FF,$3F,$F3,$FF,$FF,$FC,$0E,$00,$00
face_death
; RLE compresed data. Size before 320 size after: 293
	dta $16,$00,$05,$05,$55,$5A,$06,$00,$09,$05,$5A,$AA,$AA,$A0,$04,$00
	dta $03,$56,$A8,$08,$00,$03,$15,$AA,$08,$00,$05,$01,$6A,$80,$08,$00
	dta $03,$06,$A8,$0A,$00,$03,$5A,$A0,$08,$00,$27,$05,$AA,$80,$00,$0A
	dta $AB,$00,$00,$1A,$AA,$00,$02,$AF,$FF,$F0,$00,$2E,$A8,$00,$2B,$04
	dta $FF,$09,$00,$0E,$A8,$00,$BF,$04,$FF,$07,$C0,$0B,$A0,$02,$06,$FF
	dta $07,$F0,$03,$80,$03,$06,$FF,$FF,$F0,$02,$C0,$0B,$FC,$00,$FF,$FF
	dta $FC,$00,$80,$0F,$C3,$F0,$FC,$FF,$FC,$00,$B0,$2C,$1F,$FC,$3F,$FF
	dta $FC,$00,$20,$20,$40,$F0,$0F,$3F,$FC,$00,$2C,$20,$84,$F1,$0F,$3F
	dta $FC,$00,$08,$20,$80,$30,$0F,$CF,$FC,$00,$08,$20,$2F,$FF,$C3,$CF
	dta $FC,$00,$0B,$20,$2A,$FF,$C3,$CF,$FC,$00,$02,$08,$6A,$0F,$F3,$FF
	dta $FC,$00,$02,$C8,$AB,$0F,$C3,$EF,$FC,$00,$00,$88,$0A,$F3,$03,$EF
	dta $FC,$00,$08,$83,$08,$88,$C3,$AF,$FC,$00,$2C,$23,$00,$00,$03,$BF
	dta $FC,$00,$BF,$2C,$C1,$A0,$03,$BF,$FC,$0A,$FF,$08,$F0,$BC,$0F,$BF
	dta $BC,$2F,$CF,$C8,$3C,$2C,$0E,$FF,$89,$BC,$3F,$CF,$CB,$0F,$00,$0E
	dta $FE,$BC,$3F,$F3,$C2,$33,$F0,$3F,$FE,$FC,$3F,$F3,$F2,$3C,$3F,$3B
	dta $FE,$FC,$3F,$FC,$F2,$CF,$C0,$FF,$FB,$FC,$3F,$FC,$F0,$8F,$F3,$BF
	dta $FB,$FC,$3F,$FF,$FC,$B3,$CF,$FF,$EF,$FC,$3F,$FF,$3C,$23,$3E,$FF
	dta $FF,$FC,$3F,$FF,$FF,$20,$FB,$FE,$FF,$FC,$3F,$FF,$FF,$30,$04,$FF
	dta $01,$FC,$0E,$00,$00
face_knight
; RLE compresed data. Size before 320 size after: 288
	dta $14,$00,$03,$2A,$F0,$0A,$00,$03,$AB,$FC,$0A,$00,$03,$AF,$FF,$0A
	dta $00,$05,$AF,$FF,$C0,$08,$00,$05,$AF,$EF,$C0,$08,$00,$09,$2B,$CB
	dta $F0,$03,$C0,$04,$00,$09,$16,$C2,$FC,$0C,$B0,$04,$00,$45,$16,$C0
	dta $BC,$00,$30,$00,$00,$01,$55,$54,$3F,$00,$20,$00,$00,$15,$56,$AE
	dta $8F,$F0,$B0,$00,$00,$55,$A6,$AF,$F0,$FF,$C0,$00,$00,$56,$A6,$AF
	dta $F0,$06,$00,$07,$56,$A6,$AF,$F0,$04,$00,$09,$01,$56,$A6,$AF,$FC
	dta $04,$00,$0B,$55,$56,$A6,$AF,$FF,$F0,$06,$00,$01,$06,$08,$00,$09
	dta $03,$A8,$66,$CB,$FC,$04,$00,$09,$03,$A9,$66,$EB,$FC,$06,$00,$07
	dta $EA,$AA,$FF,$F0,$06,$00,$07,$EA,$A7,$FF,$F0,$06,$00,$FF,$EA,$A7
	dta $FF,$F0,$00,$00,$2A,$A0,$FB,$FF,$03,$00,$FA,$A8,$33,$38,$FF,$AA
	dta $F0,$03,$CC,$CC,$2A,$A8,$FF,$B0,$30,$03,$FF,$FC,$15,$54,$3F,$AA
	dta $F0,$0F,$AA,$A8,$15,$55,$0F,$FC,$00,$3E,$AA,$A8,$2A,$95,$43,$FC
	dta $00,$FA,$AF,$FC,$2A,$A9,$50,$FC,$03,$EA,$FF,$FC,$2A,$AA,$54,$00
	dta $0F,$AB,$FF,$FC,$2A,$AA,$95,$EA,$8F,$AF,$FF,$FC,$2A,$AA,$A5,$EA
	dta $8F,$BF,$FF,$A8,$16,$AA,$AF,$CA,$00,$FF,$FA,$A8,$15,$AA,$AE,$B0
	dta $3C,$FF,$EA,$BC,$25,$6A,$BE,$BA,$3C,$3F,$AA,$F8,$29,$5A,$BA,$FA
	dta $0F,$3E,$AB,$E8,$1A,$55,$7A,$EA,$8F,$2A,$AF,$A8,$16,$95,$1B,$7A
	dta $E5,$8F,$2A,$BE,$A8,$15,$A5,$7A,$EA,$8F,$2A,$FA,$A8,$0E,$00,$00
face_bishop
; RLE compresed data. Size before 320 size after: 226
	dta $24,$00,$01,$05,$0C,$00,$01,$06,$0C,$00,$03,$5A,$A0,$0A,$00,$03
	dta $6B,$F0,$0A,$00,$01,$0B,$0C,$00,$01,$0B,$0A,$00,$05,$09,$56,$A8
	dta $08,$00,$05,$14,$08,$03,$08,$00,$07,$10,$08,$00,$C0,$06,$00,$07
	dta $10,$08,$00,$C0,$06,$00,$07,$10,$08,$00,$C0,$06,$00,$07,$10,$0C
	dta $00,$C0,$06,$00,$07,$04,$0C,$03,$C0,$06,$00,$05,$07,$FF,$FF,$08
	dta $00,$05,$0E,$AA,$FF,$08,$00,$05,$0A,$AF,$FF,$08,$00,$07,$0A,$AF
	dta $FF,$C0,$06,$00,$07,$A9,$7D,$7F,$FC,$06,$00,$07,$A9,$2D,$3F,$F3
	dta $06,$00,$07,$AA,$AF,$FF,$C3,$06,$00,$07,$2A,$AF,$FF,$FC,$06,$00
	dta $07,$2A,$BF,$FF,$F0,$06,$00,$07,$2A,$AB,$FF,$C0,$04,$00,$55,$0A
	dta $2A,$C3,$FF,$CF,$C0,$00,$00,$AC,$2A,$BE,$FF,$C0,$FF,$00,$0A,$C0
	dta $2A,$AB,$FF,$00,$0F,$F0,$2F,$00,$0A,$AA,$AF,$00,$00,$FC,$3C,$00
	dta $00,$FF,$F0,$00,$00,$3C,$30,$00,$00,$58,$04,$00,$01,$0C,$04,$00
	dta $01,$58,$0C,$00,$01,$E8,$1C,$00,$01,$80,$1A,$00,$01,$02,$04,$00
	dta $01,$0C,$0C,$00,$01,$03,$04,$00,$01,$08,$04,$00,$03,$03,$C0,$0E
	dta $00,$00
face_general
; RLE compresed data. Size before 320 size after: 282
	dta $2A,$00,$03,$01,$C0,$0A,$00,$03,$07,$C0,$0A,$00,$03,$1B,$C0,$0A
	dta $00,$01,$6F,$04,$00,$1F,$2A,$AA,$AA,$C0,$BC,$00,$00,$02,$BF,$FF
	dta $FF,$FE,$F0,$00,$00,$0B,$06,$FF,$04,$00,$01,$2F,$06,$FF,$07,$C0
	dta $00,$00,$BF,$04,$FF,$63,$FC,$F0,$00,$00,$FF,$F0,$00,$00,$FC,$30
	dta $00,$00,$FF,$C3,$FF,$FC,$0C,$0C,$00,$00,$FF,$CA,$BF,$FF,$CF,$0C
	dta $00,$00,$3F,$0A,$AA,$BF,$C3,$0C,$00,$00,$0F,$3B,$FF,$FF,$F3,$30
	dta $00,$00,$03,$39,$6F,$5F,$33,$C0,$04,$00,$07,$3A,$2F,$3F,$30,$06
	dta $00,$07,$0A,$AF,$FF,$C0,$06,$00,$07,$2A,$9F,$FF,$C0,$06,$00,$07
	dta $2A,$9B,$FF,$C0,$04,$00,$FF,$01,$3A,$F0,$3C,$C4,$00,$00,$15,$01
	dta $2F,$F0,$03,$C5,$01,$54,$3E,$A5,$2A,$55,$6F,$C5,$AA,$FC,$2A,$BE
	dta $2A,$AA,$AF,$CB,$FE,$A8,$2B,$FE,$0A,$AA,$AF,$0B,$FF,$E8,$2F,$FF
	dta $82,$AA,$BC,$2F,$FF,$F8,$3F,$FF,$E0,$FF,$F0,$BF,$FF,$F8,$3F,$FF
	dta $F8,$00,$02,$FF,$FF,$F8,$3F,$FF,$FE,$A0,$AB,$FF,$FF,$FC,$3F,$FF
	dta $FF,$E0,$BF,$FF,$FF,$FC,$27,$AB,$9B,$E0,$BF,$FF,$FF,$FC,$27,$AB
	dta $9B,$E5,$BE,$E7,$96,$FC,$27,$AB,$9B,$DF,$7E,$69,$AE,$F8,$2F,$EF
	dta $EF,$DB,$7F,$FF,$FF,$E8,$2B,$DF,$9B,$EA,$FD,$D7,$7F,$AC,$2B,$57
	dta $57,$E2,$BF,$FF,$FE,$BC,$2F,$1D,$DF,$9B,$E0,$AF,$FF,$EA,$FC,$3F
	dta $FF,$FF,$E0,$EA,$FF,$AF,$FC,$0E,$00,$00
face_trasurer
; RLE compresed data. Size before 320 size after: 274
	dta $32,$00,$07,$06,$AA,$AA,$80,$06,$00,$07,$0B,$C0,$00,$C0,$06,$00
	dta $07,$0B,$C0,$00,$C0,$06,$00,$07,$0B,$C0,$00,$C0,$06,$00,$07,$0B
	dta $C0,$00,$C0,$06,$00,$07,$0B,$C0,$00,$C0,$06,$00,$07,$0B,$C0,$00
	dta $C0,$06,$00,$07,$0B,$C0,$00,$C0,$06,$00,$07,$0B,$C0,$00,$C0,$06
	dta $00,$07,$06,$BF,$FF,$C0,$06,$00,$07,$06,$BF,$FF,$C0,$04,$00,$0B
	dta $05,$55,$55,$AA,$AF,$C0,$04,$00,$07,$0A,$BF,$FF,$C0,$06,$00,$07
	dta $0A,$AA,$BF,$C0,$06,$00,$07,$3B,$FF,$FF,$F0,$06,$00,$07,$3A,$5D
	dta $7F,$30,$06,$00,$07,$3A,$1C,$7F,$30,$06,$00,$07,$0A,$AF,$FF,$C0
	dta $06,$00,$07,$0A,$AF,$FF,$C0,$06,$00,$07,$0A,$BF,$FF,$C0,$06,$00
	dta $07,$0A,$AA,$FF,$C0,$04,$00,$ED,$01,$4A,$AA,$BF,$CA,$C0,$00,$00
	dta $17,$8A,$95,$FF,$C3,$FF,$00,$01,$7E,$02,$AA,$BF,$00,$FF,$F0,$07
	dta $F8,$02,$AA,$BC,$00,$3F,$FC,$1F,$E0,$00,$AA,$FC,$00,$0F,$FC,$3F
	dta $80,$00,$FF,$F0,$00,$03,$FC,$3F,$FF,$FC,$00,$03,$FF,$FF,$FC,$3F
	dta $FD,$58,$30,$C2,$AB,$FF,$FC,$3F,$FF,$80,$30,$C0,$2F,$FF,$FC,$3F
	dta $FF,$E0,$30,$C0,$BF,$FF,$FC,$3F,$FF,$F8,$30,$C2,$FE,$FF,$FC,$3C
	dta $FF,$FC,$0F,$03,$F8,$3C,$FC,$3C,$BF,$FE,$0F,$0B,$E0,$0C,$BC,$3C
	dta $BF,$FF,$CF,$0F,$FF,$FC,$BC,$3C,$BF,$FF,$8F,$2F,$FF,$FC,$BC,$0E
	dta $00,$00
face_medic
; RLE compresed data. Size before 320 size after: 237
	dta $84,$00,$03,$0A,$BC,$0A,$00,$05,$AA,$AF,$C0,$06,$00,$07,$02,$AA
	dta $AB,$F0,$06,$00,$07,$0A,$AA,$AB,$F0,$06,$00,$07,$09,$5F,$FF,$F0
	dta $06,$00,$07,$07,$F6,$AA,$FC,$06,$00,$07,$06,$27,$8B,$CC,$06,$00
	dta $07,$06,$A7,$FF,$FC,$06,$00,$07,$09,$5B,$FF,$E0,$06,$00,$07,$0A
	dta $AB,$FF,$A0,$06,$00,$07,$0A,$AF,$FF,$A0,$06,$00,$07,$02,$AA,$FF
	dta $A0,$06,$00,$07,$02,$AA,$FE,$80,$06,$00,$07,$A1,$B0,$3A,$8F,$04
	dta $00,$FF,$02,$01,$6A,$AA,$80,$C0,$00,$00,$08,$01,$55,$5A,$00,$30
	dta $00,$00,$08,$A0,$55,$6A,$28,$30,$00,$00,$0E,$A8,$55,$68,$2A,$F0
	dta $00,$02,$AF,$A8,$15,$A0,$AB,$EA,$80,$09,$5B,$EA,$00,$02,$AF,$AA
	dta $A0,$25,$55,$FA,$55,$6A,$BE,$55,$A8,$15,$55,$7E,$55,$6B,$F9,$55
	dta $68,$15,$55,$7E,$95,$AF,$D5,$55,$54,$15,$55,$5F,$95,$BD,$55,$55
	dta $54,$15,$55,$57,$D6,$F5,$55,$55,$54,$15,$55,$55,$D7,$D5,$55,$55
	dta $54,$15,$55,$55,$FF,$55,$69,$55,$54,$16,$55,$55,$7E,$55,$AA,$56
	dta $54,$16,$55,$55,$7E,$55,$AA,$56,$94,$16,$55,$55,$7E,$55,$69,$56
	dta $94,$16,$0D,$55,$55,$7E,$55,$55,$56,$94,$0E,$00,$00
face_executioner
; RLE compresed data. Size before 320 size after: 284
	dta $36,$00,$01,$5A,$0A,$00,$05,$05,$AA,$BC,$08,$00,$05,$1A,$AA,$FF
	dta $08,$00,$07,$6A,$AB,$FF,$C0,$04,$00,$09,$01,$AA,$AB,$F3,$F0,$04
	dta $00,$09,$06,$AA,$AA,$F0,$F0,$04,$00,$09,$1A,$AA,$AA,$BC,$3C,$04
	dta $00,$09,$1A,$AA,$AA,$BC,$0F,$04,$00,$09,$6A,$AA,$AA,$BF,$03,$04
	dta $00,$0F,$6A,$AA,$AA,$AF,$33,$C0,$00,$00,$04,$AA,$09,$AF,$0F,$C0
	dta $00,$01,$04,$AA,$FF,$AF,$C0,$00,$00,$01,$A0,$AA,$02,$BF,$C0,$00
	dta $00,$02,$A3,$EB,$F2,$BF,$C0,$00,$00,$02,$A1,$EB,$72,$BF,$C0,$00
	dta $00,$06,$AC,$28,$3E,$FF,$F0,$00,$00,$06,$AA,$AA,$AB,$FF,$F0,$00
	dta $00,$0A,$AA,$AF,$AF,$FF,$F3,$E0,$00,$1A,$AA,$BF,$FF,$FF,$F0,$F8
	dta $02,$DA,$A0,$00,$03,$FF,$FC,$F8,$37,$DA,$A3,$FF,$F0,$FF,$FC,$3C
	dta $37,$DA,$A3,$96,$FC,$FF,$FF,$3C,$3B,$DA,$83,$FF,$F0,$FF,$FF,$3C
	dta $37,$EA,$83,$FF,$C0,$FF,$FC,$3C,$3B,$EA,$80,$00,$00,$FF,$FC,$FC
	dta $3B,$EA,$8F,$00,$00,$FF,$F0,$F8,$3B,$FA,$8F,$C0,$3C,$3F,$C3,$F8
	dta $3A,$FA,$8F,$C0,$FF,$85,$3F,$0F,$EC,$3E,$FE,$8F,$F3,$FF,$3C,$FF
	dta $BC,$3E,$BF,$CF,$F3,$FF,$03,$FE,$FC,$3F,$AF,$FF,$C3,$FF,$FF,$EB
	dta $FC,$3F,$EF,$FF,$CF,$FF,$FE,$BF,$F0,$0F,$EB,$FF,$CF,$FF,$EB,$FF
	dta $CC,$03,$FA,$BF,$CF,$FA,$BF,$FF,$0C,$30,$FF,$AA,$AA,$AF,$FF,$FC
	dta $3C,$3C,$3F,$FF,$3F,$FF,$FF,$C0,$FC,$0E,$00,$00
face_jester
; RLE compresed data. Size before 320 size after: 288
	dta $16,$00,$01,$0F,$0C,$00,$03,$2E,$80,$0A,$00,$03,$BE,$40,$0A,$00
	dta $03,$B1,$10,$08,$00,$05,$02,$B0,$40,$04,$00,$07,$AB,$00,$02,$F0
	dta $04,$00,$09,$02,$FF,$E0,$0A,$F0,$04,$00,$09,$08,$03,$FE,$0A,$F0
	dta $04,$00,$09,$04,$00,$3F,$8B,$FC,$04,$00,$09,$11,$00,$2F,$FF,$FC
	dta $04,$00,$0B,$04,$00,$0B,$FF,$FF,$A8,$06,$00,$01,$06,$04,$FF,$01
	dta $A0,$04,$00,$09,$05,$BF,$FF,$FF,$FC,$04,$00,$03,$05,$AF,$04,$FF
	dta $04,$00,$57,$06,$AF,$FF,$F0,$0F,$C0,$00,$00,$0F,$FF,$FF,$C0,$00
	dta $C0,$00,$00,$0A,$AA,$F0,$00,$00,$40,$00,$00,$1A,$FF,$FF,$00,$01
	dta $10,$00,$00,$1A,$BE,$FF,$C0,$00,$40,$00,$00,$6A,$C2,$B0,$C0,$06
	dta $00,$07,$7A,$86,$B8,$C0,$06,$00,$07,$AA,$AA,$AF,$C0,$06,$00,$07
	dta $3A,$AA,$AF,$CF,$06,$00,$09,$0A,$AA,$FF,$C3,$FC,$04,$00,$6D,$42
	dta $AA,$AF,$C0,$FF,$00,$00,$05,$62,$AB,$FF,$00,$FF,$C0,$00,$16,$A0
	dta $AD,$5F,$00,$FF,$F0,$00,$5A,$A8,$AA,$BF,$00,$FF,$F0,$01,$6A,$A8
	dta $2A,$FC,$02,$FF,$F0,$05,$AA,$AA,$03,$F0,$0B,$FF,$F0,$06,$AA,$AA
	dta $A0,$00,$2F,$FF,$C0,$06,$04,$AA,$09,$A0,$2F,$FF,$08,$02,$04,$AA
	dta $3B,$A0,$3F,$FC,$2C,$10,$AA,$AA,$AF,$FC,$3F,$F0,$BC,$2C,$2A,$AB
	dta $FF,$FC,$0F,$00,$3C,$2F,$00,$FF,$FF,$FC,$00,$2C,$0C,$3F,$08,$04
	dta $00,$15,$02,$BF,$00,$3C,$2A,$FC,$2A,$FF,$0B,$FF,$C0,$0E,$00,$00
face_stargazer
; RLE compresed data. Size before 320 size after: 284
	dta $24,$00,$03,$55,$54,$08,$00,$69,$55,$FF,$FD,$56,$80,$00,$00,$05
	dta $EF,$FF,$FF,$CF,$EC,$00,$00,$1B,$EF,$FF,$FF,$CF,$03,$00,$00,$1B
	dta $FB,$FF,$FF,$3C,$00,$C0,$00,$1A,$FB,$FF,$FF,$3C,$00,$C0,$00,$0A
	dta $BE,$FF,$FC,$F0,$03,$00,$00,$02,$AE,$3F,$FC,$C0,$0C,$04,$00,$09
	dta $AB,$AA,$AA,$00,$30,$04,$00,$09,$2A,$AA,$AB,$C0,$C0,$04,$00,$07
	dta $1A,$AA,$AF,$FB,$06,$00,$07,$5A,$FF,$FF,$FE,$06,$00,$F9,$6A,$5A
	dta $97,$FF,$80,$00,$00,$01,$7A,$46,$47,$F3,$A0,$00,$00,$01,$6A,$AA
	dta $FF,$FF,$A8,$00,$00,$05,$5A,$AA,$FF,$EA,$A8,$00,$00,$15,$56,$AA
	dta $FE,$AA,$AA,$00,$00,$15,$56,$AF,$FD,$AA,$AA,$00,$00,$95,$55,$55
	dta $59,$AA,$BE,$00,$02,$AA,$55,$6F,$D5,$AA,$FF,$F0,$0A,$AA,$55,$BF
	dta $D6,$AB,$FF,$FC,$2A,$AA,$55,$55,$5A,$AF,$FF,$FC,$3F,$EA,$95,$55
	dta $AA,$BF,$FF,$00,$03,$FA,$95,$55,$AA,$BF,$F0,$00,$00,$3E,$95,$56
	dta $AA,$FF,$00,$00,$10,$0F,$D5,$56,$AA,$F0,$02,$00,$08,$03,$D5,$56
	dta $AA,$C0,$08,$C0,$20,$00,$D5,$5A,$AB,$00,$03,$04,$00,$05,$35,$56
	dta $A8,$06,$00,$09,$04,$01,$5A,$A0,$80,$04,$00,$09,$12,$01,$5A,$82
	dta $20,$04,$00,$09,$08,$00,$5A,$00,$80,$08,$00,$01,$20,$0C,$00,$07
	dta $30,$00,$00,$08,$06,$00,$23,$80,$00,$00,$23,$00,$10,$00,$80,$C0
	dta $20,$00,$0C,$00,$08,$02,$30,$C0,$88,$14,$00,$00
    .print "cards/actors size: ",(images_data - cards_list)
    .print "gfx size: ",(* - images_data)
    .print "global assets size: ",(* - cards_list)
    .print "assets data ends at: ",*
    .print "REMAINING SPACE: ",($9240 - *)
; RLE SAVED:  1389 bytes
; RLE DATA TOTAL SIZE:  4519 bytes
