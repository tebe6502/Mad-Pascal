// This program calls all "Test" procedures of all "...Test.pas" units.
// The working directory during execution must be the project directory.

program TestUnits;

{$I Defines.inc}

uses
  AssemblerTest,
  Crt,
  Common,
  CommonTest,
  DataTypesTest,
  FileIOTest,
  LanguageTest,
  MathEvaluateTest,
  MessagesTest,
  OptimizerTest,
  OptimizeTemporaryTest,
  StringUtilitiesTest,
  SysUtils;

begin
  try
    LanguageTest.Test;
    FileIOTest.Test;
    AssemblerTest.Test;
    CommonTest.Test;
    DataTypesTest.Test;
    MathEvaluateTest.Test;
    MessagesTest.Test;
    StringUtilitiesTest.Test;
    OptimizerTest.Test;
    OptimizeTemporaryTest.Test;
  except
    on e: Exception do
    begin
      ShowException(e, ExceptAddr);
    end;
  end;

  Writeln('Main completed. Press any key.');
  repeat
  until keypressed;
end.
