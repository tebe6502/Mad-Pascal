procedure Syntax(ExitCode: byte);
begin

  WriteLn('Syntax: mp <inputfile> [options]');
  WriteLn('-diag'#9#9'Diagnostics mode');
  Writeln('-define:symbol'#9'Defines the symbol');
  Writeln('-ipath:<x>'#9'Add <x> to include path');
  Writeln('-target:<x>'#9'Target system: a8 (default), c64, c4p');
  WriteLn('-code:address'#9'Code origin hex address');
  WriteLn('-data:address'#9'Data origin hex address');
  WriteLn('-stack:address'#9'Software stack hex address (size = 64 bytes)');
  WriteLn('-zpage:address'#9'Variables on the zero page hex address (size = 26 bytes)');

  Halt(ExitCode);

end;
