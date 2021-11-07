program hsc_example_send;
{$librarypath '..'}
uses crt, hsc_util;

const 
	GAMEID = 108;
	BUFFER_ADDRESS = $600; 
	
var buffer: array [0..79] of char absolute BUFFER_ADDRESS; // absolute is optional 
	score: cardinal;

begin
	score := 1000;
	if HSC_Send(GAMEID, score, buffer) = 1 then Writeln('OK - success')
	else Writeln('KO - error');
	ReadKey;
end.
