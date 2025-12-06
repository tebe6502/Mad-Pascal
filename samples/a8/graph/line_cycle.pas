uses crt, graph;

{$define forward}

var
	f, r, c, u,v: byte;

	i: word;

	x, y, z: real;

begin

 InitGraph(10);

 Palette[4] := $72;
 Palette[5] := $84;
 Palette[6] := $96;
 Palette[7] := $a8;


 FOR I:=0 TO 3000 do begin

  IF Z<=0 then begin
   F:=0;
   X:=Y/4;
   Y:=-8+Random*16;
   Z:=0.2;
  end;

  U:=round(40+X/Z);
  V:=round(96+Y/Z);

  IF (U<0) OR (U>79) OR (V<0) OR (V>191) THEN begin
   Z:=0;
  end else begin

   SetColor(c);

   IF F<>0 then LineTo(U,V) ELSE MoveTo(U,V);

   F:=1;
   C:=1+C MOD 8;
   Z:=Z-0.005;

  end;

 end;


 repeat

  delay(64);

{$ifdef forward}
  i:=palette[8];

  palette[8]:=palette[7];
  palette[7]:=palette[6];
  palette[6]:=palette[5];
  palette[5]:=palette[4];
  palette[4]:=palette[3];
  palette[3]:=palette[2];
  palette[2]:=palette[1];
  palette[1]:=i;
{$else}
  i:=palette[1];

  palette[1]:=palette[2];
  palette[2]:=palette[3];
  palette[3]:=palette[4];
  palette[4]:=palette[5];
  palette[5]:=palette[6];
  palette[6]:=palette[7];
  palette[7]:=palette[8];
  palette[8]:=i;
{$endif}

 until keypressed;

end.

{
0 GRAPHICS 10:DPOKE 708,$8472:DPOKE 710,$A896
1 FOR I=0 TO 3000:IF Z<=0:F=0:X=Y/4:Y=-8+RND*16:Z=0.2:ENDIF
3   U=40+X/Z:V=96+Y/Z:IF U<0 OR U>79 OR V<0 OR V>191 THEN Z=0:NEXT I
5 COLOR C:IF F:DRAWTO U,V:ELSE :PLOT U,V:ENDIF :F=1:C=1+C MOD 8:Z=Z-5.0E-03:NEXT I
7 DO :PAUSE 2:V=PEEK(712):-MOVE 705,706,7:POKE 705,V:LOOP
}