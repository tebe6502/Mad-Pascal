// Shanti PM Multiplexer

		icl 'atari.hea'

sprites = $c000

MAX_SPRITES		equ 16

POSY_MIN		equ 16
POSY_MAX		equ 208

POSX_MIN		equ 64
POSX_MAX		equ 184

tim	equ $14			;zegar systemowy


	org $00			;strona zerowa

spr_flag	.ds 1		;bajty na stronie zerowej wykorzystywane przez MULTI
poz_y		.ds 1
duch_dy		.ds 1
dli_A		.ds 1
dli_X		.ds 1


.public	multi.animuj, multi.show_sprites, sprites, shape_tab01, shape_tab23
.public sprite_x, sprite_y, sprite_shape, sprite_c0, sprite_c1, sprite_anim, sprite_anim_speed
.public multi.init_engine, multi.ret01, multi.ret23, multi.init_sprite
.public charsets, tcolor, creg

	.reloc
;	org $c000

;sprites			:$0800 brk		;adres pamięci dla duszków

shape_tab01		= sprites		;adresy ksztaltow dla duszka 01
shape_tab23		= sprites+$100		;adresy ksztaltow dla duszka 23

blok_status		= sprites+$200+32*0	;tablica pomocnicza do ustalenia zajętości duszków
blok_x01		= sprites+$200+32*1	;pozycje pary duszków 0 i 1
blok_x23		= sprites+$200+32*2	;pozycje pary duszków 2 i 3
blok_c0			= sprites+$200+32*3	;kolor duszka 0
blok_c1			= sprites+$200+32*4	;kolor duszka 1
blok_c2			= sprites+$200+32*5	;kolor duszka 2
blok_c3			= sprites+$200+32*6	;kolor duszka 3

charsets		= sprites+$200+32*7	;starsze bajty adresu zestawu znakow w wierszu

	ert .lo(*) <> 0

tab_skok01	dta a(multi.dy0, multi.dy1, multi.dy2, multi.dy3, multi.dy4, multi.dy5, multi.dy6, multi.dy7)

tab_skok23	dta a(multi.dy0b, multi.dy1b, multi.dy2b, multi.dy3b, multi.dy4b, multi.dy5b, multi.dy6b, multi.dy7b)

tcolor			:32 brk

sprite_x		:MAX_SPRITES brk	;pozycja X obiektu
sprite_y		:MAX_SPRITES brk	;pozycja Y obiektu
sprite_shape		:MAX_SPRITES brk	;ksztalt obiektu
sprite_c0		:MAX_SPRITES brk	;kolor 0 obiektu
sprite_c1		:MAX_SPRITES brk	;kolor 1 obiektu
sprite_anim		:MAX_SPRITES brk	;liczba klatek animacji obiektu
sprite_anim_speed 	:MAX_SPRITES brk	;szybkość animacji obiektu


;.rept 26,#
;.public dli:1, dli:1.chrs, dli:1.col0, dli:1.col1, dli:1.reg0, dli:1.reg1
;.endr

; !!! koniecznie od poczatku strony pamieci przy linkowaniu

	;	.reloc

		icl 'przerwania.asm'

		icl 'multi.asm'


.local	multi

.proc	init_engine (.word yx) .reg

		sei
		mva #0 nmien
		sta irqen
		sta dmactl

		stx nmi.vbl_user+1
		sty nmi.vbl_user+2

		mva #$fe portb

		sta audctl		;inicjalizacja dźwięku
		mva #3 skctl

		;mva #2 chrctl		;włącz negatyw

		mwa #nmi nmivec

		mva #$40 nmien

		lda:cmp:req tim

//		mwa SDLSTL dlptr		;program antica

//		mva #scr40 dmactl
		mva #$c0 nmien			;wlacz dli+vblk

		mva #3 pmcntl			;włączamy duszki
		mva #>sprites pmbase
		mva #32+16+1 gtiactl		;kolorowe duszki, pociski w jednym kolorze

		jmp multi.init_sprite
.endp

.endl
