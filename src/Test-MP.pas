program test;
uses Crt;


procedure Assert(b: Boolean; s: String);
begin
 if (b) then
 begin
   Write('OK: ');
 end
 else
 begin
   Write('ERROR:');
 end;
 Writeln(s);
end;

var i: Integer;
begin
  i:=1;
  Writeln(i);
  Inc(i);
  Writeln(i);
  Assert(i=2, 'I=2');
  Assert(1+1=2, '1+1=2');
  Writeln('Test completed. Press any key');
  repeat
  until KeyPressed;
end.
