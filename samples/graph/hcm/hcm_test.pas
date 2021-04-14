// HCM2 - Hard Color Map

uses crt, hcm2;

var i,j: byte;

begin

 Palette[0] := $b8;			// 704
 Palette[2] := $b8;			// 706

 Palette[1] := $44;			// 705
 Palette[3] := $44;			// 707


 HCMInit(HiRes);			// HCM Hires (224 x 200)
					// HCM LoRes (112 x 200)

 for i:=0 to 27 do begin
  Position(i, 0); PutColor(3);
  Position(i, 24); PutColor(3);
 end;


 for i:=0 to 24 do begin
  Position(0, i); PutColor(3);		// Put Color Map #3 at X = 0 ; Y = i
  Position(27, i); PutColor(3);		// X = 27 ; Y = i

  Position(i, i); PutColor(2);

  Position(27-i, i); PutColor(1);

 end;

 MapH(2);				// Height Color Map = 2

 for j:=0 to 15 do begin

  MapY(90 + j shl 1);			// Map Color Position Y

  for i:=0 to 27 do begin
   MapX(i);				// Map Color Position X
   PutColor((i+j) and 3);
  end;

 end;


 creg[0]:=$18;				// change register $d018 at row #0
 cval[0]:=$72;				// value = $72

 creg[11]:=$18;				// at row #11
 cval[11]:=$00;

 creg[15]:=$18;				// at row 15
 cval[15]:=$86;


 for i:=11 to 14 do			// change PMG Colors ($d012 + $d014) at row #i
  cpmg[i]:=$18 + i shl 6;


repeat until keypressed;

end.
