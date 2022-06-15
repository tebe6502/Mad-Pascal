program hsc_example_show;
{$librarypath '..'}
uses atari, crt, hsc_util;

const GAMEID = 106;

begin
	HSC_Get_Formated(GAMEID,pointer(savmsc + 80));
	ReadKey;
end.
