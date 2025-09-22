uses crt;

var
    [striped] LUT_b2: array [0..255] of word absolute $a000;
    [striped] MUL_1: array [0..255] of word absolute $a000+$200;
    [striped] MUL_2: array [0..255] of word absolute $a000+$400;
    [striped] MUL_3: array [0..255] of word absolute $a000+$600;

    x: word;


procedure initLUT;
var i: byte;
begin

 for i:=0 to 255 do BEGIN

   LUT_b2[i] := i*i;

   MUL_1[i] := (i*2);

   MUL_2[i] := (i*2)*2;

   MUL_3[i] := (i*2)*3;

  end;

end;


function Square1023(x: Word): cardinal;
var
  a: byte;
  b: byte;
begin
  a := x shr 8;   // 0..3
  b := x and $FF; // 0..255

  case a of
   0: Result := 0;
   1: Result := 1 shl 16 + ( MUL_1[b] shl 8 );
   2: Result := 4 shl 16 + ( MUL_2[b] shl 8 );
   3: Result := 9 shl 16 + ( MUL_3[b] shl 8 );
  end;

{
  res := (a*a) shl 16;            // a^2 * 65536
  // (2*a*b << 8)
  res := res + ( (a * (b shl 1)) shl 8 );
  // + b^2 from LUT
}

  inc(Result, LUT_b2[b]);

end;


begin

 initLUT;

 x:=1023;

 writeln(Square1023(x));

 writeln(x*x);

 repeat until keypressed;

end.
