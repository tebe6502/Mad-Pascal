// 25515
// 139372
// 112864

program YoshBench;

uses crt, sysutils;

var i: cardinal;
var rt1: PByte absolute $e0;

begin
	pause;
	poke($12, 0);
	poke($13, 0);
	poke($14, 0);

	while byte(GetTickCount) <= 100 do Inc(i);
	WriteLn('GetTickCount: ', i);

	i := 0;
	pause;
	poke(20, 0);
	while peek(20) <= 100 do Inc(i);
	WriteLn('Peek: ', i);

	i := 0;
	pause;
	rt1 := pointer(20);
	rt1[0] := 0;
	while rt1[0] <= 100 do Inc(i);
	WriteLn('Pointer : ', i);

	ReadKey;
end.
