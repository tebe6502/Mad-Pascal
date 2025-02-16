unit m0pp;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>, Karolj Nadj, Daniel Serpell, tebe <tebe6502@gmail.com>
* @name: Graphics 0++ library, 40x40 mode
* @version: 1.0
* @description:
* Set of procedures to initialize, run, and use special graphics mode 0++.
* Resolution 40x39 chars, 2 colors
*
*)

interface
uses atari;

procedure Gr0Init(DListAddress: word; VRamAddress: word; lines: byte; blanks: byte);
(*
* @description:
* Turns on 0++ mode.
*
* @param: DListAddress - memory address of Display list
*
* @param: VRamAddress - video memory address
*
* @param: lines - number of horizontal lines (vertical resolution)
*
* @param: pixelHeight - height of a pixel in scanlines (between 2 and 6)
*
* @param: blanks - number of blanklines (8 x scanline) at top of the screen
*
*)

const
    DL_BLANK8 = %01110000; // 8 blank lines
    DL_DLI = %10000000; // Order to run DLI
    DL_LMS = %01000000; // Order to set new memory address
    DL_VSCROLL = %00100000; // Turn on vertical scroll on this line
    DL_MODE_320x192G2 = $F;
    DL_JVB = %01000001; // Jump to begining

implementation

uses crt;

var dList : PByteArray;


procedure vbl; assembler; interrupt;
asm
{
	mva #2	VS_Upper

	lda chbas
	sta chbase
	eor #4
	sta VS_chbase

	jmp xitvbv
};
end;


procedure G0Dli;interrupt;assembler;
asm {
dli
    pha

    sta WSYNC

    lda #0
.def :VS_Upper = *-1
    sta VSCROL

    eor #7
    sta VS_Upper

    lda #0
.def :VS_chbase = *-1
    sta chbase

    eor #4
    sta VS_chbase

    pla
};
end;

procedure SetFont; assembler;
asm
{	txa:pha

	lda chbas
	sta fontcopy1+2
	add #4
	sta fontcopy2+2

	lda #0
	sta fontcopy1+1
	lda #2
	sta fontcopy2+1

	ldx #127
fontcopy0  ldy #5
fontcopy1  lda $ff00,y
fontcopy2  sta $ff02,y-
           bpl fontcopy1

	adw fontcopy1+1 #8
	adw fontcopy2+1 #8

	dex
	bpl fontcopy0

	pla:tax
};
end;

procedure DLPoke(b: byte);
begin
    dList[0] := b;
    Inc(dList);
end;

procedure DLPokeW(w: word);
begin
    dList[0] := Lo(w);
    dList[1] := Hi(w);
    Inc(dList, 2);
end;

procedure BuildDisplayList(DListAddress: word; VRamAddress: word; lines: byte; blanks: byte);
begin
    dList := pointer(DListAddress);
    while blanks > 0 do begin
	DLPoke(DL_BLANK8);
        dec(blanks);
    end;
    DLPoke($a0);
    DLPoke($e2);
    DLPokeW(VRamAddress);

    lines:=lines shr 1 - 1;
    while (lines > 0) do begin
        DLPokeW($a282);
        dec(lines);
    end;
    DLPoke(DL_JVB);
    DLPokeW(DListAddress);
end;

procedure Gr0Init(DListAddress: word; VRamAddress: word; lines: byte; blanks: byte);
begin
    SetFont;
    BuildDisplayList(DListAddress, VRamAddress, lines, blanks);
    SDLSTL := DListAddress;
    savmsc := VRamAddress;
    SetIntVec(iVBL, @vbl);
    SetIntVec(iDLI, @G0Dli);
    nmien := $c0;
end;



initialization


asm
{

;
; Fast E: accelerator
; -------------------
;
; Written by DMSC, loosely based on HYP.COM by Doug Wokoun and John Harris.
;

EDITRV	= $E400

ATCLR	= $7d
ATESC	= $1b

	txa:pha

	.ifdef MAIN.@DEFINES.ROMOFF
		inc portb
	.endif


	; Search E: handler in HATABS
	ldy	#<HATABS+1-3
	lda	#'E'
search_e:
	iny
	iny
	iny
	cmp	-1+(HATABS & $FF00),y
	bne	search_e

	; Check high-part of HATABS address
	lda	1+(HATABS & $FF00),y
	cmp	#>$C000
	bcs	install_ok

	ldy #130

	jmp handler_end

install_ok

	; copy EDITOR handler to new HATABS
	ldx	#$0F
copy_e: lda	EDITRV,x
	sta	handler_hatab,x
	dex
	bpl	copy_e

	; Patch E: HATABS position in out handler
	sty	hatabs_l+3
	iny
	sty	hatabs_h+3

	; Also patch real DOSINI and EDITOR PUT
;	lda	DOSINI
;	lda	DOSINI+1
;	ldy	EDITRV+6
;	ldx	EDITRV+7
;	iny
;	sne
;	inx
;	sty	jhand+1
;	stx	jhand+2

	; Patch new HATABS, stored in current MEMLO
	lda	<EFAST
	ldx	>EFAST

	sta	hatabs_l+1
	stx	hatabs_h+1

	; And store our new PUT
	; (note, C is set here, so adds 1 less)
	adc	#(handler_put-1 - handler_hatab) - 1
	scc
	inx
	sta	handler_hatab+6
	stx	handler_hatab+7

hatabs_l:
	lda	#$00
	sta	HATABS+1
hatabs_h:
	ldx	#$00
	stx	HATABS+2

	ldy #1

	jmp handler_end

EFAST

handler_hatab	.ds 16

stop	ldy #0
	rts

	; Handler PUT function
handler_put:
	; Don't handle wrap at last row!
	ldx	ROWCRS
	cpx	#39
	bcs	stop

	; And don't handle in graphics modes
	ldx	DINDEX
	bne	jhand

	; Check for control character:
	;  $1B, $1C, $1D, $1E, $1F, $7D, $7E, $7F
	;  $9B, $9C, $9D, $9E, $9F, $FD, $FE, $FF
	;
	; To ignore high bit, store in X the shifted character
	asl
	tay
	; Restore full value in A
	ror

	cmp	#$9b
	beq	_eol

	cpy	#2*ATCLR	; chars >= $7D are special chars
	bcs	jhand
	cpy	#$C0		; chars >= $60 don't need conversion
	bcs	conv_ok
	cpy	#$40		; chars >= $20 needs -$20 (upper case and numbers)
	bcs	normal_char
	cpy	#2*ATESC	; chars <= $1B needs +$40 (control chars)
	bcc	ctrl_char

	; Special character jump to old handler
jhand:	;jmp	$FFFF

	jmp stop


_eol	inc	ROWCRS
	lda	LMARGN
	sta	COLCRS

	; Reset ESC flag
	ldy	#$00
	sty	ESCFLG

	sty	LOGCOL

	; Return with Y = 1 (no error)
	iny
	rts

	; Convert ATASCII to screen codes
ctrl_char:
	adc	#$61		; Chars from $00 to $1F, add $40 (+$21, subtracted bellow)
normal_char:
	sbc	#$20		; Chars from $20 to $5F, subtract $20
conv_ok:

	; Check break and stop on START/STOP flag
wait_stop:
	ldy	BRKKEY
	beq	jhand
	ldy	SSFLAG
	bne	wait_stop
	; From here onwards, Y = 0 always!

	; Check if we need to recalculate cursor position
	cpx	OLDCOL
	bne	calc_adr
	ldx	ROWCRS
	cpx	OLDROW
	beq	skip_adr

	; Clear current cursor position and calculate new cursor address
calc_adr:
	pha			; Save character on STACK

	lda	OLDCHR		; Clear cursor
	sta	(OLDADR),y

	sty	OLDADR+1	; set OLDADR+1 to 0

	lda	ROWCRS		; max =  255
	sta	OLDROW

        ldx     #0              ; clear high-byte

        asl     @		; * 2
        bcc     mul4            ; high-byte affected?
        ldx     #2              ; this will be the 1st high-bit soon...

mul4:   asl     @               ; * 4
        bcc     mul5            ; high-byte affected?
        inx                     ; => yes, apply to 0 high-bit
        clc                     ; prepare addition

mul5:   adc     ROWCRS		; * 5
        bcc     mul10		; high-byte affected?
        inx			; yes, correct...

mul10:  stx     OLDADR+1	; continue with classic shifting...

        asl     @		; * 10
        rol     OLDADR+1

        asl     @		; * 20
        rol     OLDADR+1

        asl     @		; * 40
        rol     OLDADR+1

	adc	COLCRS		; max = 959
	bcc	@+
	inc	OLDADR+1
	clc
@
	adc	SAVMSC
	sta	OLDADR
	lda	OLDADR+1
	adc	SAVMSC+1
	sta	OLDADR+1

	pla

skip_adr:
	; Store new character
	sta	(OLDADR),y
	; Go to next column
	inc	OLDADR
	sne
	inc	OLDADR+1

	; Read new character under cursor
	lda	(OLDADR),y
	sta	OLDCHR

	ldx	CRSINH
	bne	no_cursor
	; Draw cursor
	eor	#$80
	sta	(OLDADR),y
no_cursor:

	; Update column
	ldx	COLCRS

	cpx	RMARGN
	bcc	@+

	inc	ROWCRS
	ldx	LMARGN
	dex
@
	inx

	stx	COLCRS
	stx	OLDCOL
	inc	LOGCOL

	; Reset ESC flag
	sty	ESCFLG

	; Return with Y = 1 (no error)
	iny
	rts

; End of resident handler
handler_end:

	.ifdef MAIN.@DEFINES.ROMOFF
		dec portb
	.endif

	mva #$ff OLDROW

	pla:tax
};

 TextMode(0);

end.
