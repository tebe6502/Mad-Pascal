program mic2shp;

{$IFDEF FPC}

{$APPTYPE CONSOLE}

uses
  SysUtils;

type
  tpmg = record p0,p1,p2,p3,m: byte end;

var
  pmg: array of tpmg;

const
  _width = 40;

  _ofset = 0;

procedure save_pmg(p0,p1,p2,p3, m: byte);
var i: integer;
begin

 i:=High(pmg);

 pmg[i].p0:=p0;
 pmg[i].p1:=p1;
 pmg[i].p2:=p2;
 pmg[i].p3:=p3;

 pmg[i].m:=m;


 SetLength(pmg, i+2);

end;


procedure cnv(fnam: string);
var f, i: integer;
    buf: array [0..47] of byte;
    m, p0,p1,p2,p3: byte;
    vgap: byte;
begin

 vgap:=0;

 f:= FileOpen(fnam, fmOpenRead);
 FileSeek(f, 0, 0);

 while true do begin

  i:=FileRead(f, buf, _width);

  if i<>_width then Break;

// Player 0
  p0:=0;

  if buf[_ofset + vgap] and $40<>0 then p0:=p0 or $80;
  if buf[_ofset + vgap] and $10<>0 then p0:=p0 or $40;
  if buf[_ofset + vgap] and $04<>0 then p0:=p0 or $20;
  if buf[_ofset + vgap] and $01<>0 then p0:=p0 or $10;

  if buf[_ofset + vgap + 1] and $40<>0 then p0:=p0 or 8;
  if buf[_ofset + vgap + 1] and $10<>0 then p0:=p0 or 4;
  if buf[_ofset + vgap + 1] and $04<>0 then p0:=p0 or 2;
  if buf[_ofset + vgap + 1] and $01<>0 then p0:=p0 or 1;

// Player 1
  p1:=0;

  if buf[_ofset + vgap] and $80<>0 then p1:=p1 or $80;
  if buf[_ofset + vgap] and $20<>0 then p1:=p1 or $40;
  if buf[_ofset + vgap] and $08<>0 then p1:=p1 or $20;
  if buf[_ofset + vgap] and $02<>0 then p1:=p1 or $10;

  if buf[_ofset + vgap + 1] and $80<>0 then p1:=p1 or 8;
  if buf[_ofset + vgap + 1] and $20<>0 then p1:=p1 or 4;
  if buf[_ofset + vgap + 1] and $08<>0 then p1:=p1 or 2;
  if buf[_ofset + vgap + 1] and $02<>0 then p1:=p1 or 1;

   p2:=0;
   p3:=0;
   m:=0;

{
// Player 2
  p2:=0;

  if buf[_ofset + vgap+2] and $40<>0 then p2:=p2 or $80;
  if buf[_ofset + vgap+2] and $10<>0 then p2:=p2 or $40;
  if buf[_ofset + vgap+2] and $04<>0 then p2:=p2 or $20;
  if buf[_ofset + vgap+2] and $01<>0 then p2:=p2 or $10;

  if buf[_ofset + vgap+3] and $40<>0 then p2:=p2 or 8;
  if buf[_ofset + vgap+3] and $10<>0 then p2:=p2 or 4;
  if buf[_ofset + vgap+3] and $04<>0 then p2:=p2 or 2;
  if buf[_ofset + vgap+3] and $01<>0 then p2:=p2 or 1;

// Player 3
  p3:=0;

  if buf[_ofset + vgap+2] and $80<>0 then p3:=p3 or $80;
  if buf[_ofset + vgap+2] and $20<>0 then p3:=p3 or $40;
  if buf[_ofset + vgap+2] and $08<>0 then p3:=p3 or $20;
  if buf[_ofset + vgap+2] and $02<>0 then p3:=p3 or $10;

  if buf[_ofset + vgap+3] and $80<>0 then p3:=p3 or 8;
  if buf[_ofset + vgap+3] and $20<>0 then p3:=p3 or 4;
  if buf[_ofset + vgap+3] and $08<>0 then p3:=p3 or 2;
  if buf[_ofset + vgap+3] and $02<>0 then p3:=p3 or 1;

// Missiles
  m:=0;

  if buf[_ofset + vgap+4] and $40<>0 then m:=m or $02;
  if buf[_ofset + vgap+4] and $10<>0 then m:=m or $01;

  if buf[_ofset + vgap+4] and $80<>0 then m:=m or $08;
  if buf[_ofset + vgap+4] and $20<>0 then m:=m or $04;

  if buf[_ofset + vgap+4] and $04<>0 then m:=m or $20;
  if buf[_ofset + vgap+4] and $01<>0 then m:=m or $10;

  if buf[_ofset + vgap+4] and $08<>0 then m:=m or $80;
  if buf[_ofset + vgap+4] and $02<>0 then m:=m or $40;
}
  save_pmg(p0,p1,p2,p3, m);

 end;

 FileClose(f);
end;


procedure SavePMG(fnam: string);
var i, j, y, s, k: integer;
    v: byte;
    t: textfile;
begin

 assignfile(t, ChangeFileExt(fnam,'.asm')); rewrite(t);

 writeln(t,'.extrn'#9'shanti.sprites, shanti.multi.ret01, shanti.multi.ret23, shanti.shape_tab01, shanti.shape_tab23'#9'.word');
 writeln(t,'.public'#9+ChangeFileExt(fnam,''));
 writeln(t);
 writeln(t,'.reloc');
 writeln(t);
 writeln(t,'.proc'#9+ChangeFileExt(fnam,'')+'(.byte a) .reg');

 writeln(t);
 writeln(t,#9'asl @');
 writeln(t,#9'tay');
 writeln(t);
 writeln(t,'  .rept 16,#');
 writeln(t,#9'.ifdef shp%%1');
 writeln(t,#9'mwa #shp%%1._01 shanti.shape_tab01,y');
 writeln(t,#9'mwa #shp%%1._23 shanti.shape_tab23,y');
 writeln(t,#9'iny');
 writeln(t,#9'iny');
 writeln(t,#9'.endif');
 writeln(t,'  .endr');
 writeln(t);
 writeln(t,#9'rts');
 writeln(t,'.endp');
 writeln(t);

 s:=0;

 for k:=0 to 15 do begin

	writeln(t);
	writeln(t,'.local'#9,'shp',k);

	writeln(t,#13#10'_01');


	for i:=0 to 255 do begin

		for j:=0 to 15 do
			if (pmg[s + j].p0 = i) or (pmg[s + j].p1 = i) then begin
				writeln(t,#9'lda #',i);

				for y:=0 to 15 do begin
					if (pmg[s + y].p0 = i) then writeln(t,#9'sta shanti.sprites+$400+',y,',x');
					if (pmg[s + y].p1 = i) then writeln(t,#9'sta shanti.sprites+$500+',y,',x');
				end;

				Break;
			end;

	end;

	writeln(t);
	writeln(t,#9'jmp shanti.multi.ret01');

	writeln(t,#13#10'_23');

	for i:=0 to 255 do begin

		for j:=0 to 15 do
			if (pmg[s + j].p0 = i) or (pmg[s + j].p1 = i) then begin
				writeln(t,#9'lda #',i);

				for y:=0 to 15 do begin
					if (pmg[s + y].p0 = i) then writeln(t,#9'sta shanti.sprites+$600+',y,',x');
					if (pmg[s + y].p1 = i) then writeln(t,#9'sta shanti.sprites+$700+',y,',x');
				end;

				Break;
			end;

	end;

	writeln(t);
	writeln(t,#9'jmp shanti.multi.ret23');

	writeln(t,'.endl');

	inc(s, 16);

	v:=0;
	for y:=0 to 15 do
	 v:=v or pmg[s+y].p0 or pmg[s+y].p1;

	if v=0 then Break;
 end;

 flush(t);
 closefile(t);
end;


procedure Syntax;
begin

 writeln('mic2shp v1.1');
 writeln('Syntax: mic2shp filename.mic shapename');

 halt;

end;


begin

 SetLength(pmg, 1);

 if ParamCount = 2 then
  cnv(ParamStr(1))
 else
  Syntax;

 SavePMG(ParamStr(2));

 SetLength(pmg, 1);

end.

{$ELSE}
begin
end.
{$ENDIF}