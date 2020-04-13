// 28036
// mpas 73 ticks
// cc65	83 ticks

uses crt, sysutils;

const
	rom = $e000;
	
var	i, b: byte;
	ticks: word;
	
	tb: array [0..0] of byte;

	
function sum: word;
var i, page: byte;
    p: PByte absolute $e0;
begin

    Result := 0;

    p := pointer(rom);

    for page:=0 to 31 do begin
    
	i:=0;
	repeat 
		inc(Result, p[i]);
		
		inc(i);
	until i=0;

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
