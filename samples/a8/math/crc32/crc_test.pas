
// https://emn178.github.io/online-tools/crc32.html

// 997d78ad

uses crt, crc;

var s: string;

    c: cardinal;

begin

s:='freepascal.org';

c:=0;

c:=crc32(c, @s[1], length(s));

writeln(hexStr(c, 8));

repeat until keypressed;

end.

