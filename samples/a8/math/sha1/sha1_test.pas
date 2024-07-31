{

ad8885c523eeea069e0db3c471dc81b7ae585224
ce7357b79bd006c581e6479ad914092eb654a9a1

FALSE

27 ticks

}

// ATARI Power without the Price
// sha1: ad8885c523eeea069e0db3c471dc81b7ae585224

// POWER WITHOUT THE PRICE
// sha1: ce7357b79bd006c581e6479ad914092eb654a9a1

// http://www.sha1-online.com/

uses crt, sysutils, sha1;

var ticks: cardinal;

    d, e: TSHA1Digest;

begin

 ticks:=GetTickCount;

 { ------------------------- }

 d:=SHA1String('ATARI Power without the Price');

 GotoXY(1,1);
 writeln(SHA1Print(d));

 e:=SHA1String('POWER WITHOUT THE PRICE');

 GotoXY(1,2);
 writeln(SHA1Print(e));

 writeln(SHA1Match(d,e));

 { ------------------------- }

 ticks:=GetTickCount-ticks;

 writeln;
 writeln(ticks,' TICKS');

 repeat until keypressed;

end.

// 5570