program WriteNatural;

function mod_(x,y:integer):integer;
  begin
  mod_:=x-(x div y)*y;
  end;

procedure WriteNatural(i:integer);
  begin
  if i<10 then
    write(chr(i+ord('0')))
  else
    begin
    WriteNatural(i div 10);
    write(chr(mod_(i,10)+ord('0')));
    end
  end;
begin
  WriteNatural(12345);
  
  while true do;
end.

