// 28036
// mpas 47 ticks
// cc65	83 ticks

uses crt, sysutils;

const
	rom = $e000;

var	i, b: byte;
	ticks: word;


function sum: word;
var i, page: byte;
    p: PByte absolute $e0;
begin

    Result := 0;

    p := pointer(rom);

    for page:=31 downto 0 do begin

	for i:=0 to 255 do inc(Result, p[i]);

	inc(p, 256);
    end;

end;


begin

 pause;
 ticks := GetTickCount;

 for i:=0 to 5 do writeln(sum);

 ticks:=word(GetTickCount)-ticks;
 writeln(ticks, ' ticks');

 repeat until keypressed;

end.
