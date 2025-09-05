// 28036
// mpas	47 ticks
// cc65 83 ticks


uses crt, sysutils;

const
	rom = $e000;

var	i, b: byte;
	ticks: word;


function sum: word;
var p: PByte absolute $70;
begin

    Result := 0;

    for p := rom to $FFFF do inc(Result, p[0]);

end;


begin

 pause;
 ticks := GetTickCount;

 for i:=0 to 5 do writeln(sum);

 ticks:=word(GetTickCount)-ticks;
 writeln(ticks, ' ticks');

 repeat until keypressed;

end.
