uses crt, atari;

var a: byte;

begin

 lmargin:=0;	// left margin

 POKE(622,1);	// E: vertical scroll enabled
 TextMode(0);	// reset E:


 repeat

  a:=6+rnd and 1;

  write(chr(a));


 until keypressed;

end.