// 498

program MonteCarloPi;

uses crt;

var
	rtClock1              : byte absolute 19;
	rtClock2              : byte absolute 20;
	rndNumber             : byte absolute $D20A;
	stop, i, r, x, y      : word;
	bingo, probe, foundPi : word;

begin
	bingo := 0;
	r := 255 * 255;
	probe := 10000;

	Pause;	
	rtClock1 := 0; rtClock2 := 0;
	
	for i := 0 to probe do begin
		x := rndNumber; x := x * x;
		y := rndNumber; y := y * y;
		if (x + y) <= r then Inc(bingo);
	end;
	
	foundPi := 4 * bingo;
	stop := (rtClock1 * 256) + rtClock2;
	
	WriteLn('Probe size ', probe);
	WriteLn('Points in circle ', bingo);
	WriteLn('Found pi approximation ', foundPi / probe);
	WriteLn('Frames counter = ', stop);
	ReadKey;
end.

