procedure Syntax(ExitCode: byte);
begin
  (* Keep in sync with https://mads.atari8.info/doc/en/usage/ *)
  WriteLn('');
  WriteLn('Syntax: mp <inputfile>.pas [options]');
  WriteLn('');
  Writeln('-ipath:<folder>    Add the folder <folder> to the unit include path');
  Writeln('-define:<symbol>   Define the symbol <symbol>');
  Writeln('-cpu:<cpu>         Specify the CPU mode: 6502 (default), 65c02, 65816');
  Writeln('-target:<platform> Specify the target platform: a8 (default), c4p, c64, neo, raw, x16');
  WriteLn('-code:<address>    Specify the memory start address for the code');
  WriteLn('-data:<address>    Specify the memory start address for variables and arrays');
  WriteLn('-stack:<address>   Specify the memory start address for the software stack (64 bytes required)');
  WriteLn('-zpage:<address>   Specify the memory start address of variables in the zero page (26 bytes required)');
  Writeln('-o:<outputfile>    Specify the output file path (default <inputfile>.a65)');
  WriteLn('-diag              Activate diagnostics mode');

  RaiseHaltException(ExitCode);

end;
