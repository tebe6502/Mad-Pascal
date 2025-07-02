// Twister

uses crt, fastgraph, fastmath;


var sine: array [0..255] of byte absolute $0600;

    mv, mv2: byte;

const
    height = 96 div 2;
    cx = 48;


procedure Twister(adY: byte);
var x1,x2,x3,x4: byte;
    minx, maxx, a, i: byte;
begin

 for a := 0 to height-1 do begin

   i:=sine[a + mv2] + sine[mv];

   x1 := cx + sine[i] shr 1;
   x2 := cx + sine[byte(i + 64)] shr 1;
   x3 := cx + sine[byte(i + 128)] shr 1;
   x4 := cx + sine[byte(i + 192)] shr 1;

   minx:=x1;

//   if x1<minx then minx:=x1;
   if x2<minx then minx:=x2;
   if x3<minx then minx:=x3;
   if x4<minx then minx:=x4;


   maxx:=x1;

//   if x1>=maxx then maxx:=x1;
   if x2>=maxx then maxx:=x2;
   if x3>=maxx then maxx:=x3;
   if x4>=maxx then maxx:=x4;

   dec(minx);
   inc(maxx);

   SetColor(0);
   HLine(minx-6, minx, adY);		// clear left/right twister border
   HLine(maxx, maxx+6, adY);


   if x1<x2 then begin SetColor(1); HLine(x1,x2, adY) end;

   if x2<x3 then begin SetColor(2); HLine(x2,x3, adY) end;

   if x3<x4 then begin SetColor(3); HLine(x3,x4, adY) end;

   if x4<x1 then begin SetColor(2); HLine(x4,x1, adY) end;

   inc(adY, 2);

 end;


end;



begin

 InitGraph(7+16);

 Poke(708, $c6);
 Poke(709, $76);
 Poke(710, $f6);

 FillSinLow(@sine);		// initialize SINUS table

 mv:=0;
 mv2:=65;


 repeat

   pause;

   Twister(0);

   inc(mv, 2);
   dec(mv2, 3);

   Twister(1);

   inc(mv, 3);
   dec(mv2, 2);

 until keypressed;

end.
