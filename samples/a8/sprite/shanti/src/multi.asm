//MULTI
//multiplekser


.local multi

animuj
		lda tim
		sta _em2+1

		ldx #MAX_SPRITES-1
@		lda sprite_x,x
		bne @+
next		dex
		bpl @-
		rts
@
_em2		lda #$ff
		and sprite_anim_speed,x
		bne next
		lda sprite_anim,x
		beq next
		eor #255
		sta _em1-1
		eor #255

		and sprite_shape,x
		sta _em1+1
		inc sprite_shape,x		;animacja przeciwnikow
		lda sprite_shape,x
		and #$ff			;odwrotnosc maski
_em1		ora #$ff
		sta sprite_shape,x
		jmp next


//inicjalizacja spritów
init_sprite
		mva #MAX_SPRITES-1 start+1

init_sprite2
		lda #0
		tax
@		sta sprites+$300,x		;wyczysc duszki
		sta sprites+$400,x
		sta sprites+$500,x
		sta sprites+$600,x
		sta sprites+$700,x
		inx
		bne @-

		ldx #31
@		sta blok_status,x		;wyczysc tablice
		sta blok_x01,x
		sta blok_x23,x
		sta blok_c0,x
		sta blok_c1,x
		sta blok_c2,x
		sta blok_c3,x
		dex
		bpl @-

		ldx #MAX_SPRITES-1
@		sta sprite_x,x
		sta sprite_y,x
		sta sprite_shape,x
		sta sprite_c0,x
		sta sprite_c1,x
		sta sprite_anim,x
		sta sprite_anim_speed,x
		dex
		bpl @-

		rts


//narysuj wszystkie duszki
show_sprites
		ldy #0
		sty spr_flag
		lda sprite_x
		beq *+5
		jsr print_sprite		;gracz
		ldy start+1

@		lda sprite_x,y
		beq @+
		jsr print_sprite
@		dey
		bne *+4
		ldy #MAX_SPRITES-1

start		cpy #MAX_SPRITES-1
		bne @-1


		lda spr_flag
		beq @+
		sta start+1

@		lda blok_x01+1			;player 0 i 1
		sta hposp1
		sta hposp0
		lda blok_c0+1
		sta colpm0
		lda blok_c1+1
		sta colpm1
		lda blok_x23+1			;player 2 i 3
		sta hposp3
		sta hposp2
		lda blok_c2+1
		sta colpm2
		lda blok_c3+1
		sta colpm3

		lda #0
		sta blok_x01+1
		sta blok_x23+1
		sta blok_status+1
		sta blok_status+28
		rts


//narysuj sprite nr w Y
print_sprite
		lda sprite_y,y			;juz odczytane
		cmp #POSY_MIN
		bcc quit
		cmp #POSY_MAX
		bcs quit

		sta poz_y
		:3 lsr
		tax				;nr pierwszego bloku
		lda poz_y
		and #%111
		sta duch_dy

		bne *+3
		dex				;jesli dy=0 to zmniejsz nr pierwszego bloku

		lda blok_status,x
		ora blok_status+1,x
		ora blok_status+2,x
		lsr
		bcc @+
		lsr
		jcc @+1

		lda spr_flag
		bne *+4
		sty spr_flag
quit		rts				;nie można narysować duszka


@		inc blok_status,x
		inc blok_status+2,x

//ustawienie pozycji i koloru duszków w bloku
		lda blok_x01+3,x
		bne *+5
		inc blok_x01+3,x

		lda sprite_x,y			;sprite 0 i 1
		sta blok_x01,x

		lda sprite_c0,y
		sta blok_c0,x
		lda sprite_c1,y
		sta blok_c1,x

psp1b		lda sprite_shape,y
		asl @
		sta _psp1+1

		;sty nr_duszka
		ldx poz_y

_psp1		jmp (shape_tab01)

ret01		;ldy nr_duszka

		lda duch_dy
		asl @

		;ldy nr_duszka

		sta l01+1
		lda #0

l01		jmp (tab_skok01)

@		lda #2
		ora blok_status,x		;zajmij wybranego duszka w statusie
		sta blok_status,x
		lda #2
		ora blok_status+2,x
		sta blok_status+2,x


		lda blok_x23+3,x
		bne *+5
		inc blok_x23+3,x

		lda sprite_x,y			;sprite 2 i 3
		sta blok_x23,x

		lda sprite_c0,y
		sta blok_c2,x
		lda sprite_c1,y
		sta blok_c3,x

psp2b		lda sprite_shape,y
		asl @
		sta _psp2+1

		;sty nr_duszka
		ldx poz_y

_psp2		jmp (shape_tab23)

ret23		;ldy nr_duszka

		lda duch_dy
		asl @
		ora #%10000			;+16

		;ldy nr_duszka

		sta l23+1
		lda #0

l23		jmp (tab_skok23)


dy0
		sta sprites+$400+$10,x
		sta sprites+$500+$10,x

		sta sprites+$400-8,x
		sta sprites+$400-7,x
		sta sprites+$400-6,x
		sta sprites+$400-5,x
		sta sprites+$400-4,x
		sta sprites+$400-3,x
		sta sprites+$400-2,x
		sta sprites+$400-1,x

		sta sprites+$500-8,x
		sta sprites+$500-7,x
		sta sprites+$500-6,x
		sta sprites+$500-5,x
		sta sprites+$500-4,x
		sta sprites+$500-3,x
		sta sprites+$500-2,x
		sta sprites+$500-1,x

		rts

dy1
		sta sprites+$400+$13,x
		sta sprites+$500+$13,x
		sta sprites+$400+$14,x
		sta sprites+$500+$14,x
		sta sprites+$400+$15,x
		sta sprites+$500+$15,x
		sta sprites+$400+$16,x
		sta sprites+$500+$16,x
		sta sprites+$400+$17,x
		sta sprites+$500+$17,x
		sta sprites+$400+$18,x
		sta sprites+$500+$18,x
		jmp dy7+36

dy2
		sta sprites+$400+$13,x
		sta sprites+$500+$13,x
		sta sprites+$400+$14,x
		sta sprites+$500+$14,x
		sta sprites+$400+$15,x
		sta sprites+$500+$15,x
		sta sprites+$400+$16,x
		sta sprites+$500+$16,x
		sta sprites+$400+$17,x
		sta sprites+$500+$17,x
		jmp dy7+30

dy3
		sta sprites+$400+$13,x
		sta sprites+$500+$13,x
		sta sprites+$400+$14,x
		sta sprites+$500+$14,x
		sta sprites+$400+$15,x
		sta sprites+$500+$15,x
		sta sprites+$400+$16,x
		sta sprites+$500+$16,x
		jmp dy7+24

dy4
		sta sprites+$400+$13,x
		sta sprites+$500+$13,x
		sta sprites+$400+$14,x
		sta sprites+$500+$14,x
		sta sprites+$400+$15,x
		sta sprites+$500+$15,x
		jmp dy7+18

dy5
		cpx #POSY_MAX-32
		bcs dy7+12
		sta sprites+$400+$13,x
		sta sprites+$500+$13,x
		sta sprites+$400+$14,x
		sta sprites+$500+$14,x
		jmp dy7+12

dy6
		sta sprites+$400+$13,x
		sta sprites+$500+$13,x
		jmp dy7+6

dy7
		sta sprites+$400-7,x
		sta sprites+$500-7,x
		sta sprites+$400-6,x
		sta sprites+$500-6,x
		sta sprites+$400-5,x
		sta sprites+$500-5,x
		sta sprites+$400-4,x
		sta sprites+$500-4,x
		sta sprites+$400-3,x
		sta sprites+$500-3,x
		sta sprites+$400-2,x
		sta sprites+$500-2,x
		sta sprites+$400-1,x
		sta sprites+$500-1,x

		sta sprites+$400+$10,x
		sta sprites+$400+$11,x
		sta sprites+$400+$12,x
		sta sprites+$500+$10,x
		sta sprites+$500+$11,x
		sta sprites+$500+$12,x
		rts


dy0b
		sta sprites+$600+$11,x
		sta sprites+$700+$11,x

		sta sprites+$600+$10,x
		sta sprites+$700+$10,x

		sta sprites+$600-8,x
		sta sprites+$600-7,x
		sta sprites+$600-6,x
		sta sprites+$600-5,x
		sta sprites+$600-4,x
		sta sprites+$600-3,x
		sta sprites+$600-2,x
		sta sprites+$600-1,x

		sta sprites+$700-8,x
		sta sprites+$700-7,x
		sta sprites+$700-6,x
		sta sprites+$700-5,x
		sta sprites+$700-4,x
		sta sprites+$700-3,x
		sta sprites+$700-2,x
		sta sprites+$700-1,x

		rts

dy1b
		sta sprites+$600+$13,x
		sta sprites+$700+$13,x
		sta sprites+$600+$14,x
		sta sprites+$700+$14,x
		sta sprites+$600+$15,x
		sta sprites+$700+$15,x
		sta sprites+$600+$16,x
		sta sprites+$700+$16,x
		sta sprites+$600+$17,x
		sta sprites+$700+$17,x
		sta sprites+$600+$18,x
		sta sprites+$700+$18,x
		jmp dy7b+36


dy2b
		sta sprites+$600+$13,x
		sta sprites+$700+$13,x
		sta sprites+$600+$14,x
		sta sprites+$700+$14,x
		sta sprites+$600+$15,x
		sta sprites+$700+$15,x
		sta sprites+$600+$16,x
		sta sprites+$700+$16,x
		sta sprites+$600+$17,x
		sta sprites+$700+$17,x
		jmp dy7b+30

dy3b
		sta sprites+$600+$13,x
		sta sprites+$700+$13,x
		sta sprites+$600+$14,x
		sta sprites+$700+$14,x
		sta sprites+$600+$15,x
		sta sprites+$700+$15,x
		sta sprites+$600+$16,x
		sta sprites+$700+$16,x
		jmp dy7b+24

dy4b
		sta sprites+$600+$13,x
		sta sprites+$700+$13,x
		sta sprites+$600+$14,x
		sta sprites+$700+$14,x
		sta sprites+$600+$15,x
		sta sprites+$700+$15,x
		jmp dy7b+18

dy5b
		sta sprites+$600+$13,x
		sta sprites+$700+$13,x
		sta sprites+$600+$14,x
		sta sprites+$700+$14,x
		jmp dy7b+12


dy6b
		sta sprites+$600+$13,x
		sta sprites+$700+$13,x
		jmp dy7b+6

dy7b
		sta sprites+$600-7,x
		sta sprites+$700-7,x
		sta sprites+$600-6,x
		sta sprites+$700-6,x
		sta sprites+$600-5,x
		sta sprites+$700-5,x
		sta sprites+$600-4,x
		sta sprites+$700-4,x
		sta sprites+$600-3,x
		sta sprites+$700-3,x
		sta sprites+$600-2,x
		sta sprites+$700-2,x
		sta sprites+$600-1,x
		sta sprites+$700-1,x

		sta sprites+$600+$10,x
		sta sprites+$600+$11,x
		sta sprites+$600+$12,x
		sta sprites+$700+$10,x
		sta sprites+$700+$11,x
		sta sprites+$700+$12,x
		rts

.endl
