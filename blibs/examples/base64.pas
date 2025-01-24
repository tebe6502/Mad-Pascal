program base64;
{$librarypath '..'}
uses crt, b_utils;
var s: string = 'Hello Atari !';
	e: string[40];
	d: string[40];
begin
	Base64Init;
	Writeln('starting string:');
	Writeln(s);Writeln;
	Base64Encode(s,e);
	Writeln('encoded:');
	Writeln(e);Writeln;
	Base64Decode(e,d);
	Writeln('decoded:');
	Writeln(d);Writeln;
	ReadKey;
end.
