unit misc;
(*
 @type: unit
 @author: Tomasz Biela, Konrad Kokoszkiewicz, Guillermo Fuenzalida, Sebastian Igielski
 @name: Miscellaneous procedures for detect additional hardware
 @version: 1.1

 @description:
*)


{

DetectAntic
DetectBASIC
DetectCPU
DetectCPUSpeed
DetectEvie
DetectHighMem
DetectMapRam
DetectMem
DetectOS
DetectStereo
DetectVBXE

}

interface

var	banks: array [0..63] of byte absolute __PORTB_BANKS;	// array with code of banks PORTB

var	DetectOS: byte absolute $fff7;
(*
@description:
Detect OS

1   'XL/XE OS Rev.1'
2   'XL/XE OS Rev.2'
3   'XL/XE OS Rev.3'
4   'XL/XE/XEGS OS Rev.4'
10  'XL/XE OS Rev.10'
11  'XL/XE OS Rev.11'
59  'XL/XE OS Rev.3B'
64  'QMEG+OS 4.04'
253 'QMEG+OS RC01'
*)

	function DetectANTIC: Boolean; assembler;
	function DetectBASIC: byte; assembler;
	function DetectCPU: byte; assembler;
	function DetectCPUSpeed: real;
	function DetectEvie: Boolean; assembler;
	function DetectHighMem: word;
	function DetectMapRam: Boolean; assembler;
	function DetectMem: byte; assembler;
	function DetectStereo: Boolean; assembler;
	function DetectVBXE(var p: word): Boolean; assembler; register;


implementation


function DetectANTIC: Boolean; assembler;
(*
@description:
Detect ANTIC PAL/NTSC

@returns: TRUE = PAL
@returns: FALSE = NTSC
*)
asm

// ANTIC PAL Test for Atari 8-bits
// (C) 2019 Guillermo Fuenzalida

antic_loop1
	lda vcount
	cmp #100
	bcc antic_loop1		// wait till scanline 200
	sta scanline
antic_loop2
	lda vcount
	cmp #10
	bmi antic_loop2_fin
	cmp scanline
	bmi antic_loop2
	sta scanline
	bpl antic_loop2

antic_loop2_fin
	ldy #$00
	lda #0
scanline equ *-1
	cmp #135
	bmi ntsc
	iny
ntsc
	sty Result

end;


function DetectVBXE(var p: word): Boolean; assembler; register;
(*
@description:
Detect VBXE card

@param: word variable

@returns: TRUE present, FALSE otherwise
@returns: bit 0..6 variable: VBXE CORE
@returns: bit 7 variable: =1 RAMBO
@returns: bit 8..15 variable: VBXE PAGE
*)
asm
	txa:pha

	jsr @vbxe_detect

	ldy #0		; core
	sta (p),y

	lda fxptr+1
	sta Result

	iny		; page
	sta (p),y

	pla:tax

end;


function DetectEvie: Boolean; assembler;
(*
@description:
Detect EVIE card

@returns: TRUE present, FALSE otherwise
*)

asm
	ldy #3
lp	lda $d2fa,y
	cmp _evie,y
	bne _no
	dey
	bpl lp

_yes	lda #true
	dta $2c

_no	lda #false
	sta Result

	jmp stop

_evie	dta c'Evie'

stop

end;


{
function DetectStereo: Boolean; assembler;
(*
@description:
Second POKEY detect routine

<http://atariki.krap.pl/index.php/Programowanie:_Detekcja_stereo>

author:
Seban/SLIGHT

(c) 1995,96

@returns: TRUE present, FALSE otherwise

*)
asm

pokey1	= $d200
pokey2	= $d210

	txa:pha

	sei
	inc nmien

	lda #$03
	sta pokey2+$0f
	sta pokey2
	ldx #$00
	stx pokey2+$01
	inx
	stx pokey2+$0e

	ldx:rne vcount

	stx pokey2+$09
loop	ldx vcount
	bmi stop
	lda #$01
	bit irqen
	bne loop

stop	lda $10
	sta irqen

	dec nmien
	cli

	stx Result

	pla:tax
end;
}


function DetectStereo: Boolean; assembler;
(*
@description:
Second POKEY detect routine

<http://atariki.krap.pl/index.php/Programowanie:_Detekcja_stereo>

author: KMK

@returns: X = 0 mono
@returns: X = 1 stereo

*)
asm
	txa:pha

	ldx #$00
	stx $d20f	;halt pokey 0
	stx $d21f	;halt pokey 1
	ldy #$03
	sty $d21f	;release pokey 1

	sta $d40a	;delay necessary for
	sta $d40a	;accelerator boards

	lda #$ff
loop	and $d20a	;see if pokey 0 is halted ($d20a = $ff)
	inx
	bne loop

	sty $d20f

	cmp #$ff
	bne mono

	inx
mono
	stx Result

	pla:tax
end;


function DetectCPU: byte; assembler;
(*
@description:
 How to detect on which CPU the assembler code is running

 (This information is from Konrad Kokoszkiewicz (drac030), the author of SYSINFO 2.0)

 You can test on plain 6502-Code if there is a 65c816 CPU, the 16-Bit processor avaible

 in some XLs as a turbo-board, avaible. Draco told me how to do this:

 First we make sure, whether we are running on NMOS-CPU (6502) or CMOS (65c02,65c816).

 I will just show the "official" way which doesn`t uses "illegal opcodes":

@returns: $00 - 6502
@returns: $01 - 65c02
@returns: $80 - 65816
*)
asm
	txa:pha

	opt c+

;detekcja zainstalowanego procesora
	lda #$99
	clc
	sed
	adc #$01
	cld
	beq DetectCPU_CMOS

DetectCPU_02
	lda #0
	jmp stop

DetectCPU_CMOS
	lda #0
	rep #%00000010		;wyzerowanie bitu Z
	bne DetectCPU_C816

DetectCPU_C02
	lda #1
	jmp stop

DetectCPU_C816
	lda #$80

stop	sta Result

	opt c-

	pla:tax

end;


function DetectCPUSpeed: real;
(*
@description:
Detect CPU speed in megahertz

author: Konrad Kokoszkiewicz

@returns: speed (REAL Q24.8)
*)
var clkm, fr0: word;
begin

asm
	stx @sp

	tsx
	stx	stk

	lda	vvblki
	sta	lvbl

	lda	vvblki+1
	sta	hvbl

	lda	portb
	sta	oldp

	lda	#$ff
	sta	portb

	sei

	ldx	<stop2
	ldy	>stop2

bogo2	lda	vcount
	cmp	#112
	bne	bogo2

	stx	vvblki
	sty	vvblki+1

	lda	#$00
	sta	fr0+1
	tax
	tay

	sta	wsync

loop2	iny
	bne	loop2
	inx
	bne	loop2
	clc
	adc	#$01
	bne	loop2

stop2
	pla
	sta	clkm
	pla
	sta	clkm+1
	pla
;	sta	clkm+2
	sta	fr0

	ldx	#0
stk	equ *-1
	txs

	lda	#0
lvbl	equ *-1
	sta vvblki

	lda	#0
hvbl	equ *-1
	sta vvblki+1

	lda	#0
oldp	equ *-1
	sta	portb

	cli

	ldx #0
@sp	equ *-1

end;

	Result := ((fr0 shl 16 + clkm) / 487) * 1.7734;
end;


function DetectMem: byte; assembler;
(*
@description:
Detect amount additional memory PORTB

@returns: amount of banks (0..255)
@returns: banks code PORTB = BANKS[0..63] at address $0101
*)
asm
	txa:pha

bsav	= @buf

ext_b	= $4000		;cokolwiek z zakresu $4000-$7FFF

	ldy #0
mov	mva copy,y detect,y
	iny
	cpy #.sizeof(detect)
	bne mov

	jsr detect

	jmp stop

copy

.local	detect,$0600

	lda portb
	pha

	lda:rne vcount

;	lda #$ff
;	sta portb

	lda ext_b
	pha

	ldx #$0f	;zapamiętanie bajtów ext (z 16 bloków po 64k)
_p0	jsr setpb
	lda ext_b
	sta bsav,x
	dex
	bpl _p0

	ldx #$0f	;wyzerowanie ich (w oddzielnej pętli, bo nie wiadomo
_p1	jsr setpb	;które kombinacje bitów PORTB wybierają te same banki)
	lda #$00
	sta ext_b
	dex
	bpl _p1

	stx portb	;eliminacja pamięci podstawowej
	stx ext_b
	stx $00		;niezbędne dla niektórych rozszerzeń do 256k

	ldy #$00	;pętla zliczająca bloki 64k
	ldx #$0f
_p2	jsr setpb
	lda ext_b	;jeśli ext_b jest różne od zera, blok 64k już zliczony
	bne _n2

	dec ext_b	;w przeciwnym wypadku zaznacz jako zliczony

	lda ext_b	;sprawdz, czy sie zaznaczyl; jesli nie -> cos nie tak ze sprzetem
	bpl _n2

	lda portb	;wpisz wartość PORTB do tablicy dla banku 0

	and #$fe

	sta adr.banks,y
	eor #%00000100	;uzupełnij wartości dla banków 1, 2, 3
	sta adr.banks+1,y
	eor #%00001100
	sta adr.banks+2,y
	eor #%00000100
	sta adr.banks+3,y
	iny
	iny
	iny
	iny

_n2	dex
	bpl _p2

	ldx #$0f	;przywrócenie zawartości ext
_p3	jsr setpb
	lda bsav,x
	sta ext_b
	dex
	bpl _p3

	stx portb	;X=$FF

	pla
	sta ext_b

	pla
	sta portb

	sty Result

	rts

; podprogramy
setpb	txa		;zmiana kolejności bitów: %0000dcba -> %cba000d0
	lsr
	ror
	ror
	ror
	adc #$01	;ustawienie bitu nr 1 w zaleznosci od stanu C
	ora #$01	;ustawienie bitu sterującego OS ROM na wartosc domyslna
	sta portb
	rts

.endl

stop	pla:tax

end;


function DetectMapRam: Boolean; assembler;
(*
@description:
Detect MapRAM

<http://xxl.atari.pl/mapram/>

@returns: TRUE present, FALSE otherwise
*)
asm

bsav	= DX
ext_b	= $5000		;cokolwiek z zakresu $5000-$57FF

	txa:pha

	ldy #.sizeof(detect)-1
	mva:rpl copy,y detect,y-

	jsr detect

	jmp stop

copy

.local	detect,@buf

	sei
	inc nmien

	mva #FALSE Result

	lda portb
	pha

	lda #$ff
	sta portb

	lda ext_b
	pha

_p0	jsr setb
	lda ext_b
	sta bsav

	lda #$00
	sta ext_b

	lda #$ff
	sta portb	;eliminacja pamięci podstawowej
	sta ext_b

_p2	jsr setb

	inc ext_b
	beq _p3

	mva #TRUE Result

_p3	lda bsav
	sta ext_b

	lda #$ff
	sta portb

	pla
	sta ext_b

	pla
	sta portb

	dec nmien
	cli

	rts

setb	lda portb
	and #%01001110	; !!!
	ora #%00110000  ; MAPRAM ON
	sta portb
	rts

.endl

stop	pla:tax

end;


function DetectBASIC: byte; assembler;
(*
@description:
Detect BASIC

@returns: 162 = 'Atari Basic Rev.A'
@returns: 96 = 'Atari Basic Rev.B'
@returns: 234 = 'Atari Basic Rev.C'
*)
asm

BASROM	= $a8e2

	lda PORTB
	sta old

	and #1
	beq stop

	lda #$fd
	sta PORTB

	lda BASROM
stop	sta Result

	lda #$ff
old	equ *-1
	sta PORTB

end;


function DetectHighMem: word;
(*
@description:
Detect 65816 linear memory

<http://atariki.krap.pl/index.php/Obliczenie_rozmiaru_pami%C4%99ci_liniowej>

@returns: amount of memory in KB
*)
begin

 Result:=0;

 if DetectCPU > $7f then

asm

adr	= eax
bcnt	= Result
bfirst	= Result+1

	opt c+

	stx @sp

	sei
	inc nmien

ramsize	stz adr
	stz adr+1
	lda #$01
	sta adr+2

	stz bfirst
	stz bcnt

?lp0	stz.w $0000

	lda [adr]
	eor #$ff
	sta [adr]
	cmp [adr]
	bne ?nx
	ldx.w $0000
	bne ?nx
	eor #$ff
	sta [adr]
	bra ?fnd

?nx	inc adr+2
	bne ?lp0

	bra ?abt

?fnd	lda adr+2
	sta bfirst

	inc adr+2
	inc bcnt

?lp1	stz.w $0000

	lda [adr]
	eor #$ff
	sta [adr]
	cmp [adr]
	bne ?abt
	ldx.w $0000
	bne ?abt
	eor #$ff
	sta [adr]
	inc bcnt
	inc adr+2
	bne ?lp1

        dec bcnt

?abt
	dec nmien
	cli

	ldx #0
@sp	equ *-1

	opt c-
end;

end;


end.
