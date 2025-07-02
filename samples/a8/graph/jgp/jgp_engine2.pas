uses crt, graph, atari;

{$r engine.res}

const
	width = 32;
	mode = 4;

	fnt1	= $a000;
	fnt2	= $a400;

	jgpfnt	= fnt1-6;

type
	TLineDisplay = record
	                      cmd: byte;
			      adr: word;
	               end;

var	scr: array [0..11, 0..15] of word;


procedure VBL; interrupt; assembler;
asm
{	mva #scr32 dmactl

	lda >fnt1
	sta chbase

	mva #$02 color0
	mva #$06 color1
	mva #$0a color2
	mva #$0e color3

	mwa #MAIN.DLI.r0 vdslst

	jmp xitvbv
};
end;


procedure DLI; interrupt; assembler;
asm
{	?fnt = fnt1

	.rept 24,#,#+1

	?fnt = ?fnt ^ [fnt1^fnt2]

r%%1	.local
	pha

fnt	lda >?fnt
	sta wsync
	sta chbase

c0	lda #$02+:2*2
	sta color0

c1	lda #$06+:2*2
	sta color1

c2	lda #$0a+:2*2
	sta color2

c3	lda #$0e+:2*2
	sta color3

/*
p0	lda #$00
	sta hposp0
	lda #$00
	sty colpm0

p1	lda #$00
	sta hposp1
	lda #$00
	sty colpm1

p2	lda #$00
	sta hposp2
	lda #$00
	sty colpm2

p3	lda #$00
	sta hposp3
	lda #$00
	sty colpm3

m0	lda #$00
	sta hposm0

m1	lda #$00
	sta hposm1

m2	lda #$00
	sta hposm2

m3	lda #$00
	sta hposm3
*/
	ift %%1<>23
	mwa #r%%2 vdslst
	eif

	pla
	rti
	.endl

	.endr
};
end;


procedure InitJGP;
var a: ^TLineDisplay;
    i: byte;
    w: word;
begin

 InitGraph(7 + 16);

 a:=pointer(dpeek(560));

 a^.cmd:=$70;
 a^.adr:=$7070;

 w := dpeek(88);

 scr:=pointer(w);

 for i:=0 to 11 do begin

  inc(a);
  a^.cmd:=$40 or mode or $80;
  a^.adr:=w;

  inc(a);
  a^.cmd:=$40 or mode or $80;
  a^.adr:=w;

  inc(w, width);

 end;

 a^.cmd := $40 or mode;

 inc(a);
 a^.cmd := $41;
 a^.adr := dpeek(560);


 scr[1,1]:=$0302;

 {
 w:=dpeek(88);

 for i:=0 to 127 do poke(w + i, i);

 move(pointer(w), pointer(w+128), 128);
 move(pointer(w), pointer(w+256), 128);
}

 SetIntVec(iVBL, @vbl);
 SetIntVec(iDLI, @dli);

 nmien := $c0;

end;



begin

 InitJGP;


 repeat until keypressed;

end.
