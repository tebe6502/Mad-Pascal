uses crt, efast;

{$define romoff}

var i: byte;

begin

 for i:=0 to 23 do
  writeln('E: FAST HANDLER');

 repeat until keypressed;

end.