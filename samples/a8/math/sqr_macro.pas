
uses crt;

{$define fsqr(par, res) :=

  case byte(par shr 8) of
   0: res := SQR_0[byte(par)];
   1: res := SQR_1[byte(par)];
   2: res := SQR_2[byte(par)];
   3: res := SQR_3[byte(par)];
  end;
}

var
    [striped] SQR_0: array [0..255] of word absolute $a000;
    [striped] SQR_1: array [0..255] of cardinal absolute $a000+$200;
    [striped] SQR_2: array [0..255] of cardinal absolute $a000+$600;
    [striped] SQR_3: array [0..255] of cardinal absolute $a000+$a00;


    c: cardinal;
    x: word;


procedure initLUT;
var i: byte;
    x: word;
begin

 for i:=0 to 255 do BEGIN

   SQR_0[i] := i*i;

   x:=i+256;
   SQR_1[i] := (x*x);

   x:=i+512;
   SQR_2[i] := (x*x);

   x:=i+768;
   SQR_3[i] := (x*x);

  end;

end;


begin

initLUT;

x:=1023;

fsqr(x, c);

writeln(x*x);

writeln(c);


repeat until keypressed;

end.

