
/*
	@COMMAND
	@GRAPHICS
*/

;----------------------------;
; Biblioteka procedur        ;
; graficznych                ;
;----------------------------;
; Autorzy:                   ;
;  Slawomir 'SERO' Ritter,   ;
;  Jakub Cebula,             ;
;  Winfried Hofacker         ;
;----------------------------;
; Wersja:1.1 DATA:09.01.2008 ;
;----------------------------;

@open	= $03		; Otworz kanal
; $05 read line - Input
@close	= $0c		; Zamknij kanal

@IDget	= $07		; Odczytaj punkt
; $09 write line - Print
@IDput	= $0b		; Narysuj punkt
; $0c channel status - Status
@IDdraw	= $11		; Narysuj linie
@IDfill	= $12		; Wypelnij obszar


;------------------------;
;Wy:.Y-numer bledu (1-OK);
;   f(N)=1-wystapil blad ;
;------------------------;
.proc	@COMMAND

	ldx	#$00
scrchn	equ *-1

	sta	iccmd,x

	lda	#$00
colscr	equ *-1
	sta	atachr
	
	jmp	ciov
.endp

;------------------------;
; Ustaw tryb ekranu      ;
;------------------------;
;We:.X-numer kanalu      ;
;      (normalnie 0)     ;
;   .Y-numer trybu (O.S.);
;   .A-Ustawiony bit nr :;
;     5-Nie kasowanie    ;
;       pamieci ekranu   ;
;     4-Obecnosc okna    ;
;       tekstowego       ;
;     2-Odczyt z ekranu  ;
;------------------------;
;Wy:SCRCHN-numer kanalu  ;
;  .Y-numer bledu (1-OK) ;
;   f(N)=1 wystapil blad ;
;------------------------;
@GRAPHICS .proc (.byte x,y,a) .reg

	sta	byte1
	sty	byte2

	stx	@COMMAND.scrchn

	lda	#@close
	jsr	xcio

	lda	#0		; =opcje
byte1	equ	*-1
	ora	#8		; +zapis na ekranie
	sta	icax1,x

	lda	#0
byte2	equ	*-1
	sta	icax2,x		;=nr.trybu

	mwa	#sname	icbufa,x

	lda	#@open

xcio	sta iccmd,x
	jmp ciov

sname	dta c'S:',$9b

	.endp
