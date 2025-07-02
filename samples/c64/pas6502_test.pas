// https://bitbucket.org/paul_nicholls/pas6502/src/master/projects/pas6502_test.dpr

program Test;
const
  cScreen0 = 1024;
  cColor   = $d800;

var
  border     : Byte absolute $D020;
  background : Byte absolute $D021;

  screen0    : array[0..1000-1] of Byte absolute cScreen0;
  color0     : array[0..1000-1] of Byte absolute cColor;
  i          : Integer;
begin
  i := 0;
  while i < 1000 do begin
    // fill screen with all screen codes (wrapping around).
    screen0[i] := i;

    // fill color RAM with all colors
    color0 [i] := i;

    Inc(i);
  end;
end.