// PasIntro v2.2 (Tebe / Madteam)
// changes: 21-04-2018
// https://github.com/tebe6502/PasIntro

uses crt;

type
	t256 = array [0..255] of byte;

const
	buf = $4000;
	buf2 = $6000;

	pmg = $0400;

	rmt_player = $e000;
	rmt_modul = $c000;

	height = 192;		// screen height

	kstep = 6;		// kefren step
	kheight = 192 div kstep;

	width = 32;		// screen width
	width2 = width shl 1;	// kefren screen width
	cx = 4;			// twister horizontal position offset

	kefren_grid = $40;

	time_limit = 155;

	aSine = 60;		// sine amplitude

	bmp = $9000;

	status_step = 40 / 512;		// real

	dlist = bmp + 192*width;	// Twister DList
	dlist2 = dlist+$400;		// Kefrens DList1
	dlist3 = dlist2+$400;		// Kefrens DList2

var
	sine: t256 absolute $d800;
	ladr: t256 absolute $d900;
	hadr: t256 absolute $da00;
	ladr2: t256 absolute $db00;

	hadr2: t256 absolute $cd00;
	lscr: t256 absolute $ce00;
	hscr: t256 absolute $cf00;

	tmp1, tmp2: array [0..kheight-1] of byte;    // kefrens

	twColor0: byte = $26;
	twColor1: byte = $46;
	twColor2: byte = $66;

	kfColor0: byte = $22;
	kfColor1: byte = $24;
	kfColor2: byte = $26;

	LineAdr, status: word;

	dl_idx, times: word;

{$r 'pasintro.rc'}

procedure DLByte(a: byte);
begin

 Poke(dl_idx, a);
 inc(dl_idx);

end;

procedure DLWord(a: word);
begin

 DPoke(dl_idx, a);
 inc(dl_idx, 2);

end;

procedure InitDlist(dl, bmp: word);
var i: byte;
begin

 dl_idx:=dl;

 DLByte($70); DLByte($70); DLByte($70);

 for i:=0 to height-1 do begin
  DLByte($4e); DLWord(bmp); inc(bmp, width);
 end;

 DLByte($41); DLWord(dl);

end;


procedure InitDlistKefrens(dl, bmp: word);
var i, j: byte;
begin

 dl_idx:=dl;

 DLByte($70); DLByte($70); DLByte($70);

 for i:=0 to kheight-1 do begin

  for j:=0 to kstep-1 do begin DLByte($4e); DLWord(bmp) end;

  inc(bmp, width2);
 end;

 DLByte($41); DLWord(dl);

end;


procedure InitPMG;
begin

asm
{	ldx #0
	txa
	sta:rpl $d000,x-

	mva #scr40 559

	mva #0 pmbase
	mva #$03 gractl

	lda #3
	:4 sta sizep0+#

	lda #8
	:4 sta 704+#

	:4 mva #64+#*32 hposp0+#
};
 Poke(623, 4);

 fillchar(pointer(pmg), $400, 0);

end;


procedure Initialize;
var i: word;
    x: byte;
begin

 fillchar(pointer(buf), 16384, 0);
 fillchar(tmp1, sizeof(tmp1), 0);
 fillchar(tmp2, sizeof(tmp2), 0);

 for x:=0 to 255 do begin
  i:=buf + x * width;

  ladr[x]:=lo(i);
  hadr[x]:=hi(i);

  inc(i,$2000);

  ladr2[x]:=lo(i);
  hadr2[x]:=hi(i);

  i:=bmp + x * width;

  lscr[x]:=lo(i);
  hscr[x]:=hi(i);
 end;

asm
{	ldy #0
mov	mva tsin,y adr.sine,y
	iny
	bne mov

	jmp stop

tsin	dta sin(aSine,aSine,256)

stop
};
end;


procedure Pixel(x0: byte; c: byte); assembler;
asm
{	txa:pha

	mwa LineAdr ztmp

	lda x0
	and #3
	tay

	ldx c
	lda mask,y
	sta _msk
	eor #$ff
	and color,x
;	and mask,y
	sta _col

	lda x0
	:2 lsr @
	tay

	lda (ztmp),y
	and #0
_msk	equ *-1
	ora #0
_col	equ *-1
	sta (ztmp),y

	jmp exit

mask	dta %00111111
	dta %11001111
	dta %11110011
	dta %11111100

color	dta %00000000
	dta %01010101
	dta %10101010
	dta %11111111

exit
	pla:tax
};
end;


procedure HLine(x1,x2,c: byte);
var x: byte;
begin

 Pixel(x1, 0);

 for x:=x1+1 to x2-1 do Pixel(x, c);

 Pixel(x2,0);

end;


procedure TwisterPrecalc(buf: word; fil: byte);
var x1,x2,x3,x4: byte;
    a: byte;
begin

 LineAdr:=buf;

 for a := 0 to 255 do begin

   fillchar(pointer(LineAdr), width, fil);

   x1 := cx + sine[a];
   x2 := cx + sine[byte(a+64)];
   x3 := cx + sine[byte(a+128)];
   x4 := cx + sine[byte(a+192)];

   if x1<x2 then HLine(x1,x2, 1);
   if x2<x3 then HLine(x2,x3, 2);
   if x3<x4 then HLine(x3,x4, 3);
   if x4<x1 then HLine(x4,x1, 2);

   inc(LineAdr, width);

   Poke(status+trunc(times * status_step), $80);

   inc(times);
 end;

end;


procedure Twister(mv, mv2, dx, dx2, dTmp, d2Tmp: byte);
var y: byte;
    tmp, tmp2: byte;
    fps: byte;
begin

 fillchar(pointer(pmg), $400, 0);

 DPoke(560, dlist);

 fps:=0;

 repeat

   dl_idx:=dlist+4;

   tmp:=mv;
   tmp2:=mv2;

   y:=0;

asm
{	ldy mv
	lda adr.sine,y
	sta sw
};

   pause;

   repeat

//    s:=sine[tmp] shr 1 + sine[tmp2] shr 1 + y;

asm
{	txa:pha

	mwa dl_idx ztmp

	ldy tmp
	lda adr.sine,y
	;lsr @

	ldy tmp2
	adc adr.sine,y
	lsr @

	adc y
	tax

	ldy #0

	lda #0
sw	equ *-1
	and #7
	beq h0

	lda adr.ladr2,x
	sta (ztmp),y
	iny
	lda adr.hadr2,x
	sta (ztmp),y

	bne skip

h0	lda adr.ladr,x
	sta (ztmp),y
	iny
	lda adr.hadr,x
	sta (ztmp),y

skip	inc sw

	pla:tax
};

    inc(dl_idx, 3);

    dec(tmp, dTmp);
    dec(tmp2, d2Tmp);

    inc(y);

   until y=height;


   inc(mv, dTmp);
   inc(mv2, d2Tmp shl 2);

   inc(fps);

 until fps>time_limit;

end;


procedure ClrBar(adr: pointer; ofset: byte); assembler;
asm
{	txa:pha

	mwa adr tmp

	ldx #kheight-1
loop
	lda ljmp,x
	sta _jmp
	lda hjmp,x
	sta _jmp+1

	lda $ffff,x
tmp	equ *-2

	:2 lsr @
	add ofset
	tay

	lda #kefren_grid

skp	jmp j0
_jmp	equ *-2

	.rept kheight,#
j%%1	sta bmp+#*width2,y
	sta bmp+#*width2+1,y
	.endr

	dex
	jpl loop

	jmp stop

ljmp	.rept kheight,kheight-1-#
	dta l(j%%1)
	.endr

hjmp	.rept kheight,kheight-1-#
	dta h(j%%1)
	.endr

stop	pla:tax
};
end;


procedure DrawBar(adr: pointer; ofset: byte); assembler;
asm
{	txa:pha

	mwa adr tmp

	mva #kheight-1 lp

loop	ldy #0
lp	equ *-1

	lda ljmp,y
	sta _jmp
	lda hjmp,y
	sta _jmp+1

	lda $ffff,y
tmp	equ *-2
	pha

mask	= ztmp
shape	= ztmp+2

	and #3
	asl @
	tax

	lda msk,x
	sta mask
	lda msk+1,x
	sta mask+1

	lda bar,x
	sta shape
	lda bar+1,x
	sta shape+1

	pla

	:2 lsr @
	add ofset
	tay

	jmp j0
_jmp	equ *-2

	.rept kheight,#
j%%1	lda bmp+#*width2,y
	and mask
	ora shape
	sta bmp+#*width2,y
	lda bmp+#*width2+1,y
	and mask+1
	ora shape+1
	sta bmp+#*width2+1,y
	.endr

	dec lp
	jpl loop

	jmp stop

ljmp	.rept kheight,kheight-1-#
	dta l(j%%1)
	.endr

hjmp	.rept kheight,kheight-1-#
	dta h(j%%1)
	.endr

bar	dta %01101110,%01000000
	dta %00011011,%10010000
	dta %00000110,%11100100
	dta %00000001,%10111001

msk	dta %11111111^$ff,%11000000^$ff
	dta %00111111^$ff,%11110000^$ff
	dta %00001111^$ff,%11111100^$ff
	dta %00000011^$ff,%11111111^$ff

stop	pla:tax
};
end;


procedure KefrenSinus(adr: pointer; Add1, Add2: byte); assembler;
asm
{	txa:pha

	mva Add1 _Add1
	mva Add2 _Add2

	mwa adr tab

	mva #kheight-1 lp

loop	lda #0
lp	equ *-1
	:2 asl @

	adc #0
_Add2	equ *-1
	tay
	adc adr.sine,y

	adc #0
_Add1	equ *-1
	tax

	lda adr.sine,y
	;lsr @
	adc adr.sine,x
	lsr @

	ldx lp
	sta $ffff,x
tab	equ *-2

	dec lp
	bpl loop

	pla:tax
};
end;


procedure KefrenPMG; assembler;
asm
{	lda kfColor0
	eor #$f0
	:4 sta 704+#

	lda #0
ofs	equ *-1
	and #7
	tay

	.rept 192/8+1
	lda #$00
	sta pmg+#*8+24+1,y
	sta pmg+$100+#*8+24+1,y
	sta pmg+$200+#*8+24+1,y
	sta pmg+$300+#*8+24+1,y

	ift #<>0
	lda #$ff
	sta pmg+#*8+24,y
	sta pmg+$100+#*8+24,y
	sta pmg+$200+#*8+24,y
	sta pmg+$300+#*8+24,y
	eif
	.endr

	dec ofs
};
end;


procedure Kefrens(ad1, ad2: byte);
var fps, add1, add2: byte;

begin

 fillchar(pointer(bmp), kheight*width2, kefren_grid);

 add1:=random(128);
 add2:=random(128)+32;

 fps:=0;

repeat

  pause;
  DPoke(560, dlist3);
  DPoke($d402, dlist3);

  ClrBar(@tmp1, 0);
  KefrenSinus(@tmp1, Add1, Add2);
  DrawBar(@tmp1, 0);

  KefrenPMG;

  pause;
  DPoke(560, dlist2);
  DPoke($d402, dlist2);

  ClrBar(@tmp2, 32);
  KefrenSinus(@tmp2, Add1, Add2);
  DrawBar(@tmp2, 32);

  KefrenPMG;

  inc(add1, ad1);
  inc(add2, ad2);

  inc(fps);

until fps > time_limit shr 1;

end;


procedure MainLoop;
var mv, mv2, dx, dx2, dTmp, d2Tmp: byte;
begin

 mv:=0;
 mv2:=77;

 dx:=1;
 dx2:=-1;

 dTmp:=1;
 d2Tmp:=1;

 repeat

  Poke(708, twColor0);
  Poke(709, twColor1);
  Poke(710, twColor2);

  Twister(mv, mv2, dx, dx2, dTmp, d2Tmp);

  inc(dTmp, dx);
  inc(d2Tmp, dx2);

  if dTmp<byte(-2) then dx:=-dx else
   if dTmp>2 then dx:=-dx;

  if d2Tmp<byte(-2) then dx2:=-dx2 else
   if d2Tmp>2 then dx2:=-dx2;

  inc(twColor0, $30);
  inc(twColor1, $30);
  inc(twColor2, $30);

  Poke(708, kfColor0);
  Poke(709, kfColor1);
  Poke(710, kfColor2);

  Kefrens(random(5)+3, random(3)+5);

  inc(kfColor0, $30);
  inc(kfColor1, $30);
  inc(kfColor2, $30);

 until false;

end;


procedure SystemOff;
begin
	move(pointer($e000), pointer(bmp), 1024);
asm
{	txa:pha

	lda:cmp:req 20
	sei
	mva #0 nmien
	mva #$fe portb

	mva >bmp chbase

	mwa #nmi nmivec

	ldx <rmt_modul		;low byte of RMT module to X reg
	ldy >rmt_modul		;hi byte of RMT module to Y reg
	lda #0			;starting song line 0-255 to A reg
	jsr rmt_player		;Init

	mva #$40 nmien
	bne stop

nmi	bit nmist
	bpl vbl

	rti

vbl	sta regA
	stx regX
	sty regY

	inc rtclok+2

	mwa 560 dlptr
	mva 559 dmactl
	mva 623 gtictl

	:9 mva 704+# $d012+#

	jsr rmt_player+3

	lda #0
regA	equ *-1
	ldx #0
regX	equ *-1
	ldy #0
regY	equ *-1

	rti

stop	pla:tax
};
end;


begin

 writeln(eol,'Intro written in Turbo Pascal');
 writeln('cross compiler for 6502',eol);
 writeln('code: Tebe / Madteam');
 writeln('msx: Wieczor / Lamers');

 writeln(eol,'Glucholazy 2015',eol);

 SystemOff;

 times:=0;
 status:=dpeek(88)+WhereY*40;

 Initialize;
 InitPMG;

 InitDlist(dlist, bmp);

 InitDlistKefrens(dlist2, bmp);
 InitDlistKefrens(dlist3, bmp+32);

 TwisterPrecalc(buf, $3f);
 TwisterPrecalc(buf2, $c0);

 Poke(559, $3d);

 MainLoop;

 repeat until keypressed;

end.
