{$r f8x6.rc}

uses crt, atari, m0pp;

const

DISPLAY_LIST_ADDRESS	= $b800;
CHARSET_RAM_ADDRESS	= $a000;
VIDEO_RAM_ADDRESS	= $a800;


var
  i: word;

begin

chbas := hi(CHARSET_RAM_ADDRESS);

gr0init(DISPLAY_LIST_ADDRESS, VIDEO_RAM_ADDRESS, 40, 0);


for i:=0 to 38 do writeln(i);


repeat until keypressed;

end.

