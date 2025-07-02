// https://wiki.freepascal.org/Using_INI_Files

{

 program testowy
 1536
 FALSE

}

uses crt, inifiles;

var

 ini: TINIFile;

 a: String;

 b: integer;

 c: Boolean;

begin

{$IFDEF ATARI}
 ini.Create('D:TEST.INI');
{$ELSE}
 ini := TIniFile.Create('TEST.INI');
{$ENDIF}

a:=ini.readstring('MAIN', 'NAME', 'nul');

b:=ini.readinteger('ASSEmbly', 'ini', 11);

c:=ini.ReadBool('Assembly', 'run', true);

ini.free;


writeln(a);
writeln(b);
writeln(c);

repeat until keypressed;

end.
