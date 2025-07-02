// F73654DB8A587962996923D44A99D420

// 37 ticks

uses crt, sysutils, md5;

var

 ticks: cardinal;
 i, cnt: byte;
 md: TMD5;

begin

 pause;

 ticks:=GetTickCount;


 MD5File('D:BYTES512.DAT', md);


 writeln( MD5Print(md) );

 ticks:=GetTickCount-ticks;

 writeln(ticks,' TICKS');

 repeat until keypressed;

end.
