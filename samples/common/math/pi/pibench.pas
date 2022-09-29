// PI bench

// 176	: 8
// 271	: 10
// 659	: 16

uses crt, sysutils;

const
	iter_max = 16;

var
	r: array [0..iter_max*14] of word;
	i,k,b,d,c, ticks: cardinal;


begin

writeln(iter_max,' iterations');
writeln;


ticks:=GetTickCount;


for i:=0 to iter_max*14 do r[i]:=2000;

k := iter_max * 14;

while k > 0 do begin

 d:=0;
 i:=k;

 while true do begin

  d := d+r[i] * 10000;

  b := i shl 1-1;

  r[i] := d mod b;

  d := d div b;

  dec(i);
  if i = 0 then Break;

  d := d*i;

 end;

 write(c+d div 10000);

 c:=d mod 10000;

 dec(k, 14);

 end;

ticks:=GetTickCount - ticks;

writeln;
writeln;

writeln(ticks, ' ticks');

repeat until keypressed;

end.
