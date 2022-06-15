procedure Syntax(ExitCode: byte);
begin

  WriteLn(Tab2Space('Syntax: mp <inputfile> [options]'));
  Writeln(Tab2Space('-o:filename'#9'Output file'));
  WriteLn(Tab2Space('-diag'#9#9'Diagnostics mode'));
  Writeln(Tab2Space('-define:symbol'#9'Defines the symbol'));
  Writeln(Tab2Space('-ipath:<x>'#9'Add <x> to include path'));
  Writeln(Tab2Space('-target:<x>'#9'Target system: a8 (default), c64, c4p, raw'));
  WriteLn(Tab2Space('-code:address'#9'Code origin hex address'));
  WriteLn(Tab2Space('-data:address'#9'Data origin hex address'));
  WriteLn(Tab2Space('-stack:address'#9'Software stack hex address (size = 64 bytes)'));
  WriteLn(Tab2Space('-zpage:address'#9'Variables on the zero page hex address (size = 26 bytes)'));

  Halt(ExitCode);

end;
