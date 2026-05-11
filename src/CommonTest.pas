unit CommonTest;

interface

procedure Test;

implementation

uses Asserts, Common, CompilerTypes, FileIO, Tokens, Utilities;

procedure Test;
var
  testFilePath: TFilePath;
  resultFilePath: TFilePath;
  sourceFileList: TSourceFileList;
  sourceFile: TSourceFile;
  token: TToken;
begin

  // Test Enums
  Assert(Ord(TParameterPassingMethod.UNDEFINED) = 0);
  Assert(Ord(TParameterPassingMethod.VALPASSING) = 1);
  Assert(Ord(TParameterPassingMethod.CONSTPASSING) = 2);
  Assert(Ord(TParameterPassingMethod.VARPASSING) = 3);

  // Unit Scanner
  Program_NAME := 'TestProgram';

  // Unit Common.tokenList, Common.TokenAt
  sourceFileList := TSourceFileList.Create();
  SourceFile := sourceFileList.AddUnit(TSourceFileType.PROGRAM_FILE, 'TEST_PROGRAM', 'TestProgram.pas');
  tokenList := TTokenList.Create;

  // Kind, SourceFile, Line, Column, Value
  token := tokenList.AddToken(TTokenKind.PROGRAMTOK, SourceFile, 1, 1, 0);
  TokenAt(1).Name := 'First';
  AssertEquals(token.Name, 'First');  // Ensure TokenAt() returns tokens "by reference"
  AssertEquals(tokenAt(1).Name, 'First');

  tokenList.Free;
  tokenList := nil;
  sourceFileList.Free;
  sourceFileList := nil;

  // Unit Common.unitPathList, Common.FindFile
  unitPathList := TPathList.Create;
  unitPathList.AddFolder('libnone');
  testFilePath := 'TestUnit.xyz';
  filePath := '';
  try
    resultFilePath := FindFile(testFilePath, 'unit');
  except
    on  ex: EHaltException do
    begin
      Assert(ex.GetExitCode = EHaltException.COMPILING_ABORTED);
    end;
  end;
  Assert(resultFilePath = '', 'Non-existing file ''' + testFilePath + ''' found at ''' + resultFilePath + '''.');

end;

end.
