uses crt, atari;//, efast;

const

CHARSET_ADDRESS = $8000;

var i: byte;

    ch: array [0..255] of byte absolute CHARSET_ADDRESS;


begin

fillchar(ch, sizeof(ch), 0);

chbas:=hi(word(@ch));

lmargin:=0;

for i:=0 to 7 do ch[i+i*8]:=255;

repeat

 poke(690, 255);
 write(#32#33#34#35#36#37#38#39#38#37#36#35#34#33);

until keypressed;

end.
