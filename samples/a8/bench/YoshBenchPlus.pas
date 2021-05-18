// 42686	WHILE DO
// 41933	DO WHILE
// 41933	cc65

program YoshBenchPlus;

uses crt;

{$define FAST}

{$ifdef FAST}
	var i	: word absolute $e0;
	var a	: word absolute $e2;
	var b	: word absolute $e4;
{$else}
	var i	: word;
	var a	: word;
	var b	: word;
{$endif}

var rtClock : byte absolute 20;

begin
	i:=0;a:=0;b:=0;

	Pause;
	rtClock := 0;

	while rtClock < 100 do begin
		Inc(a); b := a;
		Inc(b); a := b;
		Inc(i);
	end;

	WriteLn('YoshPlus - iterations in 100 frames.');
	{$ifdef FAST}
		Writeln('Mad Pascal 1.6.4 opt');
	{$else}
		Writeln('Mad Pascal 1.6.4');
	{$endif}
	Writeln('Counter = ', i);
	ReadKey;
end.
