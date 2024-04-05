uses crt, x16_sysutils;

var
  n: byte;
  t: TDateTime;
  s, e: cardinal;

begin
  writeln;
  s:=CurrentSecondOfDay;

  for n:=0 to 2 do begin
    writeln('TIME = ', TimeToStr(Now()));
    writeln;
    pause(60);
  end;
  e:=(CurrentSecondOfDay - s);
  SecondsToTime(e, t.h, t.m, t.s);
  writeln('ELAPSED = ', e);
  writeln('TIME = ', TimeToStr(t));
  repeat until keypressed;

end.
