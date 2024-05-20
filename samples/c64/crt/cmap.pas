uses crt, c64;

var
	cmap : array [0..0] of byte absolute $d800;


begin

clrscr;

writeln ('Atari');


cmap[0]:=light_grey;

cmap[1]:=cyan;

repeat until keypressed;


end.

