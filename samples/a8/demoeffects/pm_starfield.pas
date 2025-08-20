uses crt, atari;

var
	i: byte;
	tab, add: array [0..255] of byte;

begin

 for i:=0 to 255 do begin
  tab[i]:=peek($d20a);
  add[i]:=peek($d20a) and 3 + 1;
 end;

 sizep0:=0;
 grafp0:=1;

 repeat

  i:=vcount;

  wsync:=0;

  hposp0:=tab[i];

  inc(tab[i], add[i]);


 until keypressed;

end.