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

  for i:=0 to 63 do p0[i] := i*58321;

  p1:=@p0;
  p2:=@p0;

  i:=11;

  p0[i] := p0[i+30] + p0[i+31]+ p0[i+32]+ p0[i+63];
  writeln(p0[i]);

  p0[i+5] := p0[i+20] + p0[i+21]+ p0[i+24]+ p0[i+63];
  writeln(p0[i+5]);

  p1^ := p1[i+3] + p1[i+2]+ p1[i+1]+ p1[i+63];
  writeln(p1^);

  p2^ := p2[30] + p2[6]+ p2[90]+ p2[12];
  writeln(p2^);

 repeat until keypressed;

end.