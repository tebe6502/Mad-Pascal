
// SDX, BWDOS, DOS II+/D

var
	i: byte;

begin

 Writeln (paramstr(0),' Got ',ParamCount,' command-line parameters: ');
  For i:=1 to ParamCount do
    Writeln (ParamStr (i));

end.
