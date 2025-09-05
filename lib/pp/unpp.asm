
	// struktura dla zmiennych na stronie zerowej,
	// dzieki ktorej wymusimy relokowalnosc dla wiekszej liczby zmiennych

	.struct		zp

	src	.word 	; 2 - strumien danych spakowanych
	dst	.word 	; 2 - adres ostatniego bajtu do rozpakowania
	offset	.word 	; 2 - adres offsetu
	bytes	.word 	; 2 - ilosc bajtow do przepisania

	ofs	.dword 	; tablica offsetow - 4 bajty

	cnt	.byte 	; licznik bitow
	bit	.byte 	; bity do rotacji
	tmp	.byte 	; zmienna tymczasowa

	.ends


eax	ext	.byte

.public	unpp

	.reloc

; PowerPacker decruncher v. 1.0
; Swiety/Zelax

UNPP
; wlasciwy depacker

	stx @sp

; tworzenie tablicy offsetow (4 bajty z 4 bajtu od poczatku spakowanych danych)

 ldy #7
 ldx #3
d_tbof lda (eax+zp.src),y
 sta eax+zp.ofs,x
 dey
 dex
 bpl d_tbof

; ldx #3
;d_tbof lda pack+4,x
; sta ofs,x
; dex
; bpl d_tbof

	ldy #0
	lda eax+zp.dst
	sta dst_l
	add (eax+zp.src),y	; < [length unpacked data - 1]
	sta eax+zp.dst
	iny
	lda eax+zp.dst+1
	sta dst_h
	adc (eax+zp.src),y	; > [length unpacked data - 1]
	sta eax+zp.dst+1

; lda <dest  	; adres ostatnigo bajtu rozpakowanych danych
; sta dst
; lda >dest
; sta dst+1

	iny
	lda (eax+zp.src),y	; < length packed data - 4
	add eax+zp.src
	pha
	iny
	lda (eax+zp.src),y	; > length packed data - 4
	adc eax+zp.src+1
	sta eax+zp.src+1
	pla
	sta eax+zp.src


; lda <tbp	; ostatni bajt spakowanych danych -4
; sta src
; lda >tbp
; sta src+1


	lda #$80
	sta eax+zp.cnt


; ldy #3		; pomin n bajtow
 lda (eax+zp.src),y
 ldy #0
; sty eax+zp.cnt
 tax
 beq d_dep
 jsr d_setoff

d_dep jsr d_getb	; wlasciwe depakowanie - pobierz 1 bit
 bcs d_offs		; 1 - offset , 0 - niespakowany ciag

 sty eax+zp.bytes	; ustal dlugosc ciagu bajtow (nie spakowanych)
 sty eax+zp.bytes+1	; bytes = 0

d_lpad tya		; pobierz 2 bity
 jsr d_get2bits
 jsr d_addb		; dodaj to do licznika bajtow

 cpx #3			; oba bity ustawione - pobierz jeszcze raz
 beq d_lpad

; kopiuj z src -> dst ciag bajtow

d_lpcopy jsr d_get4b    ; wez 4 bity \
 jsr d_get4b		; wez 4 bity / razem 8 bitow
 jsr d_putdest		; wpisz do rozpakowanych danych i zmniejsz licznik
 bcs d_lpcopy

d_offs tya
 jsr d_get2bits		; pobierz index (2 bity)

 lda eax+zp.ofs,x	; ustal offset z tablicy
 inx
 stx eax+zp.bytes
 sty eax+zp.bytes+1	; ilosc bajtow z tablicy offsetow
 cpx #4			; x+1 , x=4 - ilosc bajtow z tablicy i taka sama dlugosc offsetu
 bne d_xd

 jsr d_getb		; pobierz kolejny bit
 bcs d_bigofs 		; bit = 1 - dlugosc offsetu z tablicy
 lda #7			; bit = 0 - offset o dlugosci 7 bitow

d_bigofs jsr d_setoff	; pobierz offset

d_byte tya		; pobierz ilosc bajtow
 jsr d_get3b		; wez 3 bity

 jsr d_addb		; dodaj do ilosci bajtow

 cpx #7			; wszystkie bity ustawione - jeszcze raz
 beq d_byte

 bne d_offmov

d_xd jsr d_setoff	; pobierz offset

d_offmov jsr d_readoff	; kopiuj sekwencje z offset -> dest

.nowarn dew eax+zp.offset

 bcs d_offmov

	lda eax+zp.dst+1
	cmp dst_h: #$00
	bne skp
	lda eax+zp.dst
	cmp dst_l: #$00
skp
	bcs d_dep


; lda eax+zp.dst+1
; cmp dst_h: #$00	; starszy bajt adresu konca ciagu rozpakowanego
; bcs d_dep


	ldx @sp: #$00
	rts			; koniec dekompresji


d_get4b jsr d_getb	; pobierz 4 bity
 rol @

d_get3b jsr d_getb	; pobierz 3 bity
 rol @

d_get2bits jsr d_getb   ; pobierz 2 bity
 rol @
 jsr d_getb
 rol @
 tax
 rts

d_setoff tax	        ; pobierz offset i go oblicz - adres danych do skopiowania
 tya
 sta eax+zp.offset+1

d_lpgoff jsr d_getb
 rol @
 rol eax+zp.offset+1
 dex
 bne d_lpgoff

 sec
 adc eax+zp.dst
 sta eax+zp.offset

 lda eax+zp.offset+1
 adc eax+zp.dst+1
 sta eax+zp.offset+1
 rts

d_readoff lda (eax+zp.offset),y	; odczytaj dane z offsetu

; tax
;.nowarn dew offset
; txa

d_putdest sta (eax+zp.dst),y	; wpisz bajt do dst

; sta $d01a

.nowarn dew eax+zp.dst		; dst = dst -1

 lda eax+zp.bytes		; bytes=bytes-1
 sec
 sbc #1
 sta eax+zp.bytes
 scs
 dec eax+zp.bytes+1

; lda eax+zp.bytes+1
; sbc #0
; sta eax+zp.bytes+1

 rts

d_addb
 adc eax+zp.bytes	; dodaj do licznika bajtow
 sta eax+zp.bytes
 bcc d_jmp2
 inc eax+zp.bytes+1

d_jmp2 rts

d_getb
 asl eax+zp.cnt		; pobierz kolejny bit z ciagu src
 bcc d_lsr

; dec eax+zp.cnt
; bpl d_lsr

 sta eax+zp.tmp

; lda #7
; sta eax+zp.cnt
 rol eax+zp.cnt

.nowarn dew eax+zp.src

 lda (eax+zp.src),y
 sta eax+zp.bit

 lda eax+zp.tmp
d_lsr lsr eax+zp.bit
 rts
