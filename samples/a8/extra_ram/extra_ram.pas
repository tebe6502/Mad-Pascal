uses crt, objects;

var
   extra_ram: TMemoryStream;


begin

 extra_ram.Create;

 writeln('Extra RAM: ', extra_ram.Size);


 repeat until keypressed;

end.