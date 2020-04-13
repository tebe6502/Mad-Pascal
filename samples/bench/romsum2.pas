// 28036
// mpas	79 ticks
// cc65 83 ticks


uses crt, sysutils;

const
	rom = $e000;
	
var	i, b: byte;
	ticks: word;
	
	
function sum: word;
var page: byte;
    p: PByte absolute $e0;
begin

    Result := 0;

    p := pointer(rom);

    while p > pointer(0) do begin
	inc(Result, p[0]);

	inc(p);
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
