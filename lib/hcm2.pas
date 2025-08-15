unit hcm2;
(*
* @type: unit
* @author: Sandor Teli, Tomasz Biela <tebe6502@gmail.com>
* @name: Hard Color Map
*
* @version: 1.0
*
* @description:
*
* <https://bitbucket.org/sandor-hard/reharden/src/master/HCM.md>
* <https://bitbucket.org/sandor-hard/hcm-converter/src/master/>
*
*)

interface
uses atari;

	procedure HCMInit(mode: byte);
	procedure Position(x,y: byte); assembler;
	function GetColor: byte; assembler;
	procedure PutColor(a: byte); assembler;
	procedure MapH(a: byte); assembler;
	procedure MapX(a: byte); assembler;
	procedure MapY(a: byte); assembler;

{$define romoff}

const
    HiRes = $0f;
    LoRes = $0e;

    HCMBASE = $d800;
    HCMVRAM = HCMBASE+$0800;

var
    cval: array [0..24] of byte absolute HCMBASE+$20;
    creg: array [0..24] of byte absolute HCMBASE+$40;
    cpmg: array [0..24] of byte absolute HCMBASE+$60;

    HCMPalette : array [0..4] of byte absolute HCMBASE;

implementation

uses crt;

const
    DL_BLANK8 = %01110000;	// 8 blank lines
    DL_BLANK4 = %00110000;	// 4 blanks lines
    DL_DLI = %10000000;		// Order to run DLI
    DL_LMS = %01000000;		// Order to set new memory address
    DL_VSCROLL = %00100000;	// Turn on vertical scroll on this line
    DL_MODE_LoRes = $e;
    DL_MODE_HiRes = $f;
    DL_JVB = %01000001;		// Jump to begining

    lines = 200;
    yofset = 28;

    PMGAddress = HCMBASE;
    VRamAddress = HCMVRAM;
    DListAddress = VRamAddress + lines * 32;


procedure PutColor(a: byte); assembler;
(*
@description:
*)
asm
	and #3
	tay
	lda Position.tcol0,y
msk0	and #0
	sta ora0+1

	lda Position.tcol1,y
msk1	and #0
	sta ora1+1

height	lda #1
	sta :eax

py	ldy #0

cm0	lda PMGAddress+$400,y
and0	and #0
ora0	ora #0
cm0_	sta PMGAddress+$400,y

cm1	lda PMGAddress+$500,y
and1	and #0
ora1	ora #0
cm1_	sta PMGAddress+$500,y

	iny
	asl :eax
	bne cm0
end;


function GetColor: byte; assembler;
(*
@description:
*)
asm
	lda #0
	sta Result

	lda PutColor.cm0+2
	sta cm0+2

	lda PutColor.cm1+2
	sta cm1+2

	ldy PutColor.py+1

cm0	lda PMGAddress+$400,y
	and PutColor.and0+1
	beq cm1

	lda #2
	sta Result

cm1	lda PMGAddress+$500,y
	and PutColor.and0+1
	seq

	inc Result
end;


procedure Position(x,y: byte); assembler;
(*
@description:
*)
asm
	lda x
	and #$1f
	cmp #28
	bcs exit

	tay
	lda tcm0,y
	sta PutColor.cm0+2
	sta PutColor.cm0_+2

	lda tcm1,y
	sta PutColor.cm1+2
	sta PutColor.cm1_+2

	lda tand0,y
	sta PutColor.and0+1
	eor #$ff
	sta PutColor.msk0+1

	lda tand1,y
	sta PutColor.and1+1
	eor #$ff
	sta PutColor.msk1+1

	ldy y
	cpy #25
	scc
	ldy #24

	lda tposy,y
	sta PutColor.py+1

exit	jmp stop

theight	dta $80,$40,$20,$10,$08,$04,$02,$01

tcol0	dta $00,$00,$ff,$ff
tcol1	dta $00,$ff,$00,$ff

tand0	dta %01111111
	dta %10111111
	dta %11011111
	dta %11101111
	dta %11110111
	dta %11111011
	dta %11111101
	dta %11111110

	dta %01111111
	dta %10111111
	dta %11011111
	dta %11101111
	dta %11110111
	dta %11111011
	dta %11111101
	dta %11111110

	dta %11111101
	dta %11111110
	dta %11011111
	dta %11101111

	dta %01111111
	dta %10111111
	dta %11011111
	dta %11101111
	dta %11110111
	dta %11111011
	dta %11111101
	dta %11111110

tand1	dta %01111111
	dta %10111111
	dta %11011111
	dta %11101111
	dta %11110111
	dta %11111011
	dta %11111101
	dta %11111110

	dta %01111111
	dta %10111111
	dta %11011111
	dta %11101111
	dta %11110111
	dta %11111011
	dta %11111101
	dta %11111110

	dta %11110111
	dta %11111011
	dta %01111111
	dta %10111111

	dta %01111111
	dta %10111111
	dta %11011111
	dta %11101111
	dta %11110111
	dta %11111011
	dta %11111101
	dta %11111110

tposy	:25 dta l(#*8+yofset)

tcm0	:8 dta h(PMGAddress+$400)
	:8 dta h(PMGAddress+$600)
	:4 dta h(PMGAddress+$300)
	:8 dta h(PMGAddress+$100)

tcm1	:8 dta h(PMGAddress+$500)
	:8 dta h(PMGAddress+$700)
	:4 dta h(PMGAddress+$300)
	:8 dta h(PMGAddress+$200)

stop
end;


procedure MapH(a: byte); assembler;
(*
@description:
*)
asm
	and #7
	beq stop

	tay
	lda Position.theight-1,y
	sta PutColor.height+1
stop
end;


procedure MapX(a: byte); assembler;
(*
@description:
*)
asm
	and #$1f
	cmp #28
	bcs exit

	tay
	lda Position.tcm0,y
	sta PutColor.cm0+2
	sta PutColor.cm0_+2

	lda Position.tcm1,y
	sta PutColor.cm1+2
	sta PutColor.cm1_+2

	lda Position.tand0,y
	sta PutColor.and0+1
	eor #$ff
	sta PutColor.msk0+1

	lda Position.tand1,y
	sta PutColor.and1+1
	eor #$ff
	sta PutColor.msk1+1

exit
end;


procedure MapY(a: byte); assembler;
(*
@description:
*)
asm
	add #yofset
	sta PutColor.py+1
end;


procedure HCMDli; interrupt; assembler;
(*
@description:
*)
asm
	sta regA+1
	stx regX+1
	sty regY+1

	tsx
	stx stack+1

	ldx #$00
	txs

lineloop
b0	ldy adr.cval

	.rept 8, #

	.if :1==0
	;can spend 0 cycles in here (1st line of the group of 8 scanlines)

	.elseif :1==3
b1	lda adr.creg+1
	sta creg_+1
	cmp $ff

	.elseif :1==4
cpm	ldy adr.cpmg
	sty $d012
	cmp $ff

	.elseif :1==5
	inc cpm+1
	nop
	cmp $ff

	.elseif :1==6
	inc b0+1
	nop
	cmp $ff
	.elseif :1==7
	inc b1+1
	nop
	cmp $ff

	.else
	;can spend 11 cycles in here (any other line than the 1st one)
	nop ; use it for whatever you like
	nop
	nop
	nop
	cmp $ff ;just wasting 3 cycles of the 11, no op
	.endif

	sta wsync

	lda #$48 ;hpos
sthpos1_1_:1
	sta HPOSP2
	sta HPOSP0

	.if :1==0
creg_	sty $d01e
	nop

	.elseif :1==4
	sty $d014
	nop
	.else

	nop
	nop
	nop

	.endif

	ldy PMGAddress+$100+yofset,x
	lda PMGAddress+$200+yofset,x
	tax

	lda #$98
	sta HPOSP0
	sty GRAFP0
sthpos1_2_:1
	sta HPOSP2
stgraf1_:1
	stx GRAFP2

	tsx
	inx
	txs

	.endr

	cpx #lines
	jne lineloop

	lda adr.HCMPalette+1
	sta 704
	sta 706

	lda adr.HCMPalette+2
	sta 705
	sta 707

	lda adr.HCMPalette+3
	sta 708
	lda adr.HCMPalette+4
	sta 709
	lda adr.HCMPalette+5
	sta 710

	lda adr.HCMPalette+0
	sta 712

	mva <adr.cval b0+1
;	sta attract
	mva <adr.cpmg cpm+1
	mva <adr.creg+1 b1+1

	lda adr.creg
	sta creg_+1

stack	ldx #0
	txs

regA	lda #0
regX	ldx #0
regY	ldy #0
end;


procedure vbl; assembler; interrupt;
(*
@description:
*)
asm
	jmp xitvbv
end;


procedure BuildDisplayList(mode: byte);
(*
@description:
*)
var vram: word;
    i: byte;
    dList : PByteArray;


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


begin

    vram:=VRamAddress;

    dList := pointer(DListAddress);
    DLPoke(DL_BLANK8);
    DLPoke(DL_BLANK8);
    DLPoke(DL_BLANK4 + DL_DLI);

    for i:=0 to 199 do begin

        DLPoke(mode);
        DLPokeW(vram);

	inc(vram, 32);
    end;

    DLPoke(DL_JVB);
    DLPokeW(DListAddress);
end;


procedure HCMInit(mode: byte);
(*
@description:
*)
begin

asm
	ldy #$1f
	lda #0
	sta:rpl $d000,y-

	lda #$03
	sta SIZEP0
	sta SIZEP1
	sta SIZEP2
	sta SIZEP3
	lda #$ff
	sta SIZEM

	lda #$03
	sta GRACTL

	lda >PMGAddress
	sta PMBASE

	lda #scr32
	sta sdmctl

	ldy #$1f
@	lda #$00
	sta adr.cval,y
	lda #$1e
	sta adr.creg,y
	lda 704
	sta adr.cpmg,y
	dey
	bpl @-

	sta adr.HCMPalette+1
	lda 705
	sta adr.HCMPalette+2

	lda 708
	sta adr.HCMPalette+3
	lda 709
	sta adr.HCMPalette+4
	lda 710
	sta adr.HCMPalette+5

	lda 712
	sta adr.HCMPalette


	mwa #VRamAddress 88


;	lda mix
;	bne mix_on

	ldy #$21
	lda mode
	cmp #HiRes
	seq
	ldy #$24

	sty gtictls

	;mixing PM colors with each other in a fully homogenous way requires
	;a certain positioning of PMs (different from mode 0 above)

	lda #$48
	sta HPOSP0
	sta HPOSP1
	lda #$68
	sta HPOSP2
	sta HPOSP3
	lda #$88
	sta HPOSM0
	sta HPOSM1
	lda #$90
	sta HPOSM2
	sta HPOSM3

	lda #<HPOSP1
	.rept 8, #
	sta HCMDli.sthpos1_1_:1+1
	sta HCMDli.sthpos1_2_:1+1
	.endr
	lda #<GRAFP1
	.rept 8, #
	sta HCMDli.stgraf1_:1+1
	.endr
/*
	jmp stop

mix_on
	lda #$00
	sta gtictls

	;mixing PM colors with PF colors in a fully homogenous way requires
	;a certain positioning of PMs

	lda #$48
	sta HPOSP0
	sta HPOSP2
	lda #$68
	sta HPOSP1
	sta HPOSP3
	lda #$88
	sta HPOSM0
	sta HPOSM2
	lda #$90
	sta HPOSM1
	sta HPOSM3

	lda #<HPOSP2
	.rept 8, #
	sta HCMDli.sthpos1_1_:1+1
	sta HCMDli.sthpos1_2_:1+1
	.endr
	lda #<GRAFP2
	.rept 8, #
	sta HCMDli.stgraf1_:1+1
	.endr

stop
*/
end;

    BuildDisplayList(DL_LMS + mode);
    SDLSTL := DListAddress;
    savmsc := VRamAddress;
//    SetIntVec(iVBL, @vbl);
    SetIntVec(iDLI, @HCMDli);

    irqen:=$00;		// disable IRQ, Antic Display List (under ROM) crash when key is pressed
    irqens:=$00;

    nmien := $c0;
end;


procedure ClearHCM;
(*
@description:
*)
begin
 fillchar(pointer(HCMBase), $800 + lines*32, $00);
end;


initialization

 Position(0,0);
 PutColor(0);
 ClearHCM;

end.
