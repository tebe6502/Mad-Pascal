{
 31411
 179
}

var w: cardinal;

procedure doit(var d);

begin
  Writeln('As integer: ',PInteger(@D)^);
  Writeln('As Byte   : ',PByte(@D)^);
end;


begin

w:=31411;

doit(w);

while true do;

end.
