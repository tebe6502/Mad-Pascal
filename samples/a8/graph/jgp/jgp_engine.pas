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

	TJGPBlock = object

		x, y: byte;

		procedure Put(a: byte);
	end;


var	scr: array [0..11, 0..15] of word;

	jgp: TJGPBlock;

	a,b: byte;


procedure TJGPBlock.Put(a: byte);
var tmp, inv: byte;
    w: word;
begin
	inv := a and $80;

	tmp := (a and $7f) * 2;
	w := tmp + (tmp or 1) shl 8;

	if inv<>0 then w:=w or $8080;

	scr[y,x] := w;

	inc(x);
	if x>15 then begin
		x:=0;
		inc(y);

		if y>11 then y:=0;
	end;

end;


procedure VBL; interrupt; assembler;
asm
{	mva #scr32 dmactl

	lda >fnt1
	sta chbase

	mva #$12 color0
	mva #$c2 color1
	mva #$7c color2
	mva #$fe color3

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

 SetIntVec(iVBL, @vbl);
 SetIntVec(iDLI, @dli);

 nmien := $c0;

end;



begin

 InitJGP;

 jgp.x := 0;
 jgp.y := 0;

 for b:=0 to 3 do
  for a:=0 to 15 do jgp.put(a+b*16);

 jgp.y := 5;

 for b:=0 to 3 do
  for a:=0 to 15 do jgp.put(a+b*16 + $80);


 repeat until keypressed;

end.
