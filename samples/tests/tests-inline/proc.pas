uses crt;


procedure pok(a: word; b:byte); inline;
begin

 poke(a,b);

end;


begin

 pok(710,100);

 repeat until keypressed;

end.