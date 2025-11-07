//PROFILE-NO
procedure Syntax(ExitCode: Byte);
begin
  (* Keep in sync with https://mads.atari8.info/doc/en/usage/ *)
  WriteLn('');
  WriteLn('Syntax: mp <inputfile>.pas [options]');
  WriteLn('');
  Writeln('-ipath:<folder>    Add the folder <folder> to the unit include path');
  Writeln('-define:<symbol>   Define the symbol <symbol>');
  Writeln('-target:<platform> Specify the target platform: a8 (default), c4p, c64, neo, raw, x16');
  Writeln('-cpu:<cpu>         Specify the CPU mode: 6502 (default), 65c02, 65816');
  WriteLn('-code:<address>    Specify the memory start address for the code');
  WriteLn('-data:<address>    Specify the memory start address for variables and arrays');
  WriteLn('-stack:<address>   Specify the memory start address for the software stack (64 bytes required)');
  WriteLn('-zpage:<address>   Specify the memory start address of variables in the zero page (26 bytes required)');
  Writeln('-o:<outputfile>    Specify the output file path (default <inputfile>.a65)');
  WriteLn('-diag              Activate diagnostics mode');
  {$IFDEF DEBUG}
  WriteLn('-pause             Wait for a key press after completion');
  {$ENDIF}
  RaiseHaltException(ExitCode);

end;

procedure ParameterError(const index: Longint; const message: String);
var
  i: Longint;
begin

  Write('Options: ');
  for i := 1 to TEnvironment.GetParameterCount do
  begin

    if i < index then
    begin
      Console.TextColor(Console.LightGreen);
    end
    else if i = index then
      begin
        Console.TextColor(Console.LightRed);
      end
      else
      begin
        Console.NormVideo;
      end;

    Write(TEnvironment.GetParameterString(i));
    Write(' ');
  end;
  Writeln('');


  Console.TextColor(Console.LightRed);
  WriteLn('ERROR: Check option number ' + IntToStr(index) + '. ' + message);
  Console.NormVideo;
  Syntax(EHaltException.COMPILING_NOT_STARTED);
end;

procedure ParameterValueError(index: Longint; parameterValue: String; message: String);
begin
  ParameterError(index, 'Invalid parameter value ''' + parameterValue + '''. ' + message);
end;

function ParseHexParameter(const index: Longint; const parameterValue: String): Integer;
var
  err: Integer;
begin
  val('$' + parameterValue, Result, err);
  if (err <> 0) then ParameterValueError(index, parameterValue, 'Value is no hexadeciment number.');
  if (Result < 0) or (Result > $10000) then
    ParameterValueError(index, parameterValue, 'Value must be between $0000-$FFFF.');
end;

function ParseCPUParameter(const index: Longint; const parameterValue: String): TCPU;
begin
  Result := TCPU.NONE;
  if parameterValue <> '' then
    if parameterValue = '6502' then Result := TCPU.CPU_6502
    else
      if parameterValue = '65C02' then Result := TCPU.CPU_65C02
      else
        if parameterValue = '65816' then Result := TCPU.CPU_65816
        else
          ParameterError(index, 'Invalid CPU ''' + parameterValue +
 '''. Use on of ''6502, 65C02, 65816''.');
end;

function ParseTargetParameter(const index: Longint; const parameterValue: String): TTargetID;
begin
  Result := TTargetID.NONE;
  if parameterValue = 'A8' then Result := TTargetID.A8
  else if parameterValue = 'C64' then Result := TTargetID.C64
    else if parameterValue = 'C4P' then Result := TTargetID.C4P
      else if parameterValue = 'NEO' then Result := TTargetID.NEO
        else if parameterValue = 'RAW' then Result := TTargetID.RAW
          else if parameterValue = 'X16' then Result := TTargetID.X16
            else
              ParameterError(index, 'Invalid target ''' + parameterValue +
 '''. Use on of ''A8, C64, C4P, NEO, RAW, X16''.');
end;
//PROFILE-YES
