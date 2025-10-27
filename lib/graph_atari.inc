
procedure SetActiveBuffer(var a: TDisplayBuffer);
(*
@description:

*)
begin

 VideoRAM := pointer(a.bp);
 savmsc := word(VideoRAM);

end;


procedure InitGraph(mode: byte); overload;
(*
@description:
Init graphics mode
*)
const
	tlshc: array [0..15] of byte = ($03,$02,$02,$01,$01,$02,$02,$03,$03,$03,$03,$03,$03,$03,$02,$03);	// $EE6D: Table Left SHift Columns
	tmccn: array [0..15] of byte = ($28,$14,$14,$28,$50,$50,$A0,$A0,$40,$50,$50,$50,$28,$28,$A0,$A0);	// $EE7D: Table Mode Column CouNts
	tmrcn: array [0..15] of byte = ($18,$18,$0C,$18,$30,$30,$60,$60,$C0,$C0,$C0,$C0,$18,$0C,$C0,$C0);	// $EE8D: Table Mode Row CouNts

begin

 asm
 dindex	equ $57

	txa:pha

	lda mode
	sta MAIN.SYSTEM.GraphMode
	and #$0f
	tay

	ldx #$60		; 6*16
	lda mode		; %00010000 with text window
	and #$10
	eor #$10
	ora #2			; read

	.nowarn @GRAPHICS

	sty GraphResult

	.ifdef MAIN.@DEFINES.ROMOFF
	inc portb
	.endif

	ldx dindex
	ldy adr.tlshc,x
	lda #5
shift	asl @
	dey
	bne shift

	sta SCANLINE_WIDTH

; Fox/TQA

	ldx dindex
	lda adr.tmccn,x
	ldy adr.tmrcn,x
	ldx #0
	cmp #<320
	sne:inx

; X:A = horizontal resolution
; Y = vertical resolution

	@SCREENSIZE

	.ifdef MAIN.@DEFINES.ROMOFF
	dec portb
	.endif

	pla:tax
 end;

 VideoRam:=pointer(savmsc);

end;


procedure InitGraph(driver, mode: byte; dev: PString); overload;
(*
@description:
Init graphics mode
*)
begin

InitGraph(mode);

asm
	lda driver
	bpl stop

	txa:pha

	jsr @vbxe_detect
	bcc ok

	ldx #grNoInitGraph
	bne status

ok	jsr @vbxe_init

	ldx #grOK
status	stx GraphResult

	pla:tax
stop
end;

end;


procedure SetDisplayBuffer(var a: TDisplayBuffer);
(*
@description:
Set video buffer which is displayed
*)
begin
	sdlstl := a.dl;
	dlistl := sdlstl;
end;


procedure ClrBuffer;
var x, y: pointer;
    l: word;
begin

 x:=Scanline(WIN_TOP);

 y:=Scanline(WIN_BOTTOM + 1);
 l:=word(y);

 dec(l, word(x));

 fillbyte(x, l, 0);

end;


function NewDisplayBuffer(var a: TDisplayBuffer; mode, bound: byte): TDisplayBuffer;
(*
@description:
Initialize new graphical buffer
*)
begin

 ramtop := bound;

 InitGraph(mode);

 a.dl := sdlstl;
 a.bp := savmsc;

 a.clr := @ClrBuffer;

end;


procedure SwitchDisplayBuffer(var a,b: TDisplayBuffer);
(*
@description:
Switch graphical buffer between A <> B
*)
var tmp: TDisplayBuffer;
begin

 tmp:=b;

 b:=a;
 a:=tmp;

 SetDisplayBuffer(a);
 SetActiveBuffer(b);

 b.clr;

end;


procedure SetBkColor(color: byte); assembler;
(*
@description:
Sets the background color to Color
*)
asm
	sta colbaks
end;


procedure SetColor(color: byte); assembler;
(*
@description:
Sets the foreground color to Color
*)
asm
	sta @COMMAND.colscr
	sta GetColor
end;


procedure PutPixel(x,y: smallint); assembler; overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
asm
	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	stx @sp

	lda RMARGN
	pha

	mwa x colcrs
	mva y rowcrs

;	lda #@IDput		; slower
;	jsr @COMMAND

	ldx @COMMAND.scrchn	; faster
	lda @COMMAND.colscr

	m@call	@putchar.main

	pla
	sta RMARGN

	ldx @sp: #$00
stop

end;


procedure PutPixel(x,y: smallint; color: byte); overload;
(*
@description:
Puts a point at (X,Y) using color Color
*)
begin

  asm
	mva color @COMMAND.colscr
  end;

  PutPixel(x,y);

end;


function GetPixel(x,y: smallint): byte; assembler;
(*
@description:
Return color of pixel
*)
asm
	txa:pha

	ldy #0

	lda y+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenHeight+1
	bne sk0
	lda y
	cmp MAIN.SYSTEM.ScreenHeight
sk0
	bcs stop

	lda x+1
	bmi stop
	cmp MAIN.SYSTEM.ScreenWidth+1
	bne sk1
	lda x
	cmp MAIN.SYSTEM.ScreenWidth
sk1
	bcs stop

	mwa x colcrs
	mva y rowcrs

	lda #@IDget

	jsr @COMMAND
	tay

stop	sty Result

	pla:tax

end;


procedure LineTo(x, y: smallint);
(*
@description:
Draw a line starting from current position to a given point
*)
begin

asm
	lda y+1
	bpl _0

	lda #0
	sta y
	sta y+1
_0
	lda x+1
	bpl _1

	lda #0
	sta x
	sta x+1
_1
	cpw y main.system.ScreenHeight
	bcc _2

	lda main.system.ScreenHeight
	ldy main.system.ScreenHeight+1
	sbc #1
	scs
	dey
	sta y
	sty y+1
_2
	cpw x main.system.ScreenWidth
	bcc _3

	lda main.system.ScreenWidth
	ldy main.system.ScreenWidth+1
	sbc #1
	scs
	dey
	sta x
	sty x+1
_3
	stx @sp

	lda RMARGN
	pha

	mwa CurrentX colcrs
	mva CurrentY rowcrs

;	lda #@IDput		; slower
;	jsr @COMMAND

	ldx @COMMAND.scrchn	; faster
	lda @COMMAND.colscr

	m@call	@putchar.main

	lda x
	sta colcrs
	sta CurrentX
	lda x+1
	sta colcrs+1
	sta CurrentX+1

	mva y rowcrs
	sta CurrentY
	lda y+1
	sta CurrentY+1

	lda #@IDdraw

	jsr @COMMAND

	pla
	sta RMARGN

	ldx @sp: #$00
end;

end;


procedure LineRel(dx, dy: smallint);
(*
@description:
LineRel draws a line starting from the current pointer position to the point(DX,DY),
relative to the current position, in the current line style and color.
The Current Position is set to the endpoint of the line.
*)
begin

 LineTo(CurrentX + dx, CurrentY + dy)

end;


{$i vbxe.inc}

