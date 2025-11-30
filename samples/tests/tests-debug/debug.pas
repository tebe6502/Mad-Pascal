// 7348446
// 5715458
// 2274519
// 2799408

// 1373 bytes

uses crt;

var
  p0: array [0..63] of cardinal;
  p1     : PCardinal;
  p2     : PCardinal absolute $e0;

  i      : byte;

begin


  p1:=@p0;
  p2:=@p0;

  i:=11;

  p1^ := p1[i+3] + p1[i+2]+ p1[i+1]+ p1[i+63];
  writeln(p1^);


end.
