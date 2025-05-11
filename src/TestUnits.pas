program TestUnits;

{$I Defines.inc}

uses
  Crt,
  Common,
  CommonTypes,
  CompilerTypes,
  Datatypes,
  FileIO,
  MathEvaluate,
  Messages,
  Scanner,
  Optimize,
  Tokens,
  Utilities,
  StringUtilities,
  SysUtils;

  procedure AssertEquals(actual, expected: String); overload;
  begin
    Assert(actual = expected, 'The actual string ''' + actual + ''' is not equal to the expected string ''' +
      expected + '''.');
  end;


  procedure AssertEquals(actual, expected: Longint); overload;
  begin
    Assert(actual = expected, 'The actual value ''' + IntToStr(actual) +
      ''' is not equal to the expected value ''' + IntToStr(expected) + '''.');
  end;

  procedure AssertEquals(actual, expected: TDatatype); overload;
  begin
    Assert(actual = expected, 'The actual value ''' + GetTokenKindName(actual) +
      ''' is not equal to the expected value ''' + GetTokenKindName(expected) + '''.');
  end;


  procedure StartTest(Name: String);
  begin
    WriteLn('Unit Test ' + Name + ' started.');
  end;

  procedure FailTest(msg: String);
  begin
    WriteLn('ERROR: ' + msg);
  end;


  procedure EndTest(Name: String);
  begin
    WriteLn('Unit Test ' + Name + ' ended.');
  end;


  procedure TestNative(filePath: TFilePath);
  var
    f: TextFile;
    s: String;
  begin
    StartTest('TestFileNative');

    AssignFile(f, filePath);

    try
      reset(f); // Open the file for reading
      readln(f, s);
      writeln('Text read from file: ', s)

    finally
      CloseFile(f);
    end;
    EndTest('TestFileNative');
  end;

  procedure TestFileIO(filePath: TFilePath);
  var
    binFile: IBinaryFile;
  var
    c: Char;
  begin
    StartTest('TestFileIO');

    binFile := TFileSystem.CreateBinaryFile;
    binFile.Assign(filePath);
    try
      binFile.Reset;

      while not binFile.EOF do
      begin
        c := ' ';
        binFile.Read(c);
        Write(c);
        // WriteLn(IntToStr(Ord(c)));
      end;
      //      binFile.Read(c);
      binFile.Close;
    except
      FailTest('Failed with Exception.');

    end;
    EndTest('TestFileIO');
  end;

  procedure TestUnitFileIO;
  const
    TEST_MP_FILE_PATH = '..\src\tests\TestMP.pas';
  var
    pathList: TPathList;

  begin
    StartTest('TestUnitFileIO');
    TestNative(TEST_MP_FILE_PATH);
    TestFileIO(TEST_MP_FILE_PATH);

    pathList := TPathList.Create;
    pathList.AddFolder('Folder1');
    pathList.AddFolder('Folder2');
    pathList.AddFolder('Folder2' + TFileSystem.PathDelim);
    Assert(pathList.GetSize() = 2);
    Assert(pathList.ToString() = 'Folder1' + TFileSystem.PathDelim + ';Folder2' + TFileSystem.PathDelim);
    pathList.Free;

    AssertEquals(SysUtils.ExtractFileName(''), '');
    AssertEquals(SysUtils.ExtractFileName('ABC.'), 'ABC.');
    AssertEquals(SysUtils.ExtractFileName('ABC.xyz'), 'ABC.xyz');
    AssertEquals(SysUtils.ExtractFileName('/a/b/ABC.xyz'), 'ABC.xyz');
    AssertEquals(SysUtils.ExtractFileName('\a\b\ABC.xyz'), 'ABC.xyz');
    AssertEquals(SysUtils.ExtractFileName('\a\b\c/d/ABC.xyz'), 'ABC.xyz');

    EndTest('TestUnitFileIO');
  end;

  procedure TestUnitCommon;
  var
    filePath: TFilePath;
    sourceFileList: TSourceFileList;
    sourceFile: TSourceFile;
    tokenList: TTokenList;
    token: TToken;
  begin

    StartTest('TestUnitCommon');

    // Test Enums
    Assert(Ord(TParameterPassingMethod.UNDEFINED) = 0);
    Assert(Ord(TParameterPassingMethod.VALPASSING) = 1);
    Assert(Ord(TParameterPassingMethod.CONSTPASSING) = 2);
    Assert(Ord(TParameterPassingMethod.VARPASSING) = 3);


    // Unit Scanner
    Program_NAME := 'TestProgram';

    sourceFileList := TSourceFileList.Create();
    SourceFile := sourceFileList.AddUnit(TSourceFileType.PROGRAM_FILE, 'TEST_PROGRAM', 'TestProgram.pas');
    tokenList := TTokenList.Create(Addr(tok));
    // Kind, UnitIndex, Line, Column, Value
    token := tokenList.AddToken(TTokenKind.PROGRAMTOK, SourceFile, 1, 1, 0);
    tokenList.Free;
    tokenList := nil;
    sourceFileList.Free;
    sourceFileList := nil;

    // Unit Common
    unitPathList := TPathList.Create;
    unitPathList.AddFolder('libnone');
    filePath := '';
    try
      filePath := FindFile('TestUnit', 'unit');
    except
      on  ex: THaltException do
      begin
        Assert(ex.GetExitCode = THaltException.COMPILING_ABORTED);
      end;
    end;
    Assert(filePath = '', 'Non-existing TestUnit found');

    EndTest('TestUnitCommon');
  end;


type
  TTestEvaluationContext = class(TInterfacedObject, IEvaluationContext)
  public
    constructor Create;
    function GetConstantName(const expression: String; var index: Integer): String;
    function GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  end;

  constructor TTestEvaluationContext.Create;
  begin
  end;

  function TTestEvaluationContext.GetConstantName(const expression: String; var index: Integer): String;
  const
    EXAMPLE = 'EXAMPLE';
  begin
    if (Copy(expression, index, Length(EXAMPLE)) = EXAMPLE) then
    begin
      Result := EXAMPLE;
      Inc(index, Length(EXAMPLE));
    end;
  end;

  function TTestEvaluationContext.GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  begin
    if constantName = 'EXAMPLE' then
    begin
      constantValue := 1;
      Result := True;
    end
    else
    begin
      constantValue := 0;
      Result := False;
    end;
  end;

  // ----------------------------------------------------------------------------
  // Unit Datatypes
  // ----------------------------------------------------------------------------
  procedure TestUnitDatatypes;
  begin
    AssertEquals(Datatypes.GetDataSize(TDataType.UNTYPETOK), 0);
    AssertEquals(Datatypes.GetDataSize(TDataType.BYTETOK), 1);
    AssertEquals(Datatypes.GetDataSize(TDataType.WORDTOK), 2);

    AssertEquals(Datatypes.GetValueType(0), TDataType.BYTETOK);
    AssertEquals(Datatypes.GetValueType(255), TDataType.BYTETOK);
    AssertEquals(Datatypes.GetValueType($ffff), TDataType.WORDTOK);
    AssertEquals(Datatypes.GetValueType(-1), TDataType.SHORTINTTOK);
  end;

  // ----------------------------------------------------------------------------
  // Unit MathEvaluate
  // ----------------------------------------------------------------------------
  procedure TestUnitMathEvaluate;

    procedure AssertValue(const expression: String; expectedValue: TEvaluationResult);
    var
      evaluationContext: IEvaluationContext;
      actualValue: TEvaluationResult;
    begin
      evaluationContext := TTestEvaluationContext.Create;
      actualValue := MathEvaluate.Evaluate(expression, evaluationContext);
      Assert(actualValue = expectedValue,
        'Expression ''' + expression + ''' was evaluated to value ' + FloatToStr(actualValue) +
        ' instead of ' + FloatToStr(expectedValue) + '.');
    end;

    procedure AssertException(const expression: String; expectedIndex: Integer; expectedMessage: String);
    var
      evaluationContext: IEvaluationContext;
    begin
      evaluationContext := TTestEvaluationContext.Create;
      try
        MathEvaluate.Evaluate(expression, evaluationContext);
        Assert(False, 'Expected exception ''' + expectedMessage + ''' for expression ''' +
          expression + ''' not raised.');
      except
        on ex: EEvaluationException do
        begin
          Assert(ex.Message = expectedMessage, 'Expected exception ''' + expectedMessage +
            ''' for expression ''' + expression + ''' raised with different text ''' + ex.Message + '''.');
          Assert(ex.Index = expectedIndex, 'Expected exception ''' + expectedMessage +
            ''' for expression ''' + expression + ''' raised with different index ' +
            IntToStr(ex.Index) + ' instead of ' + IntToStr(expectedIndex) + '.');

        end;
      end;

    end;

  begin

    StartTest('TestUnitMathEvaluate');

    AssertValue('', 0);
    AssertValue('(1+2)*3+1+100/10', 20);
    AssertValue('$1234+$2345', $1234 + $2345);
    AssertValue('%111011010', $1da);   // There is no binary in Delphi

    AssertException('(', 2, 'Parenthesis Mismatch');
    EndTest('TestUnitMathEvaluate');
  end;

  // ----------------------------------------------------------------------------
  // Unit Messages
  // ----------------------------------------------------------------------------
  procedure TestUnitMessages;
  var
    message: TMessage;
  begin

    StartTest('TestUnitMessages');
    Messages.Initialize;
    message := TMessage.Create(TErrorCode.IllegalExpression,
      'A={0} B={1} C={2} D={3} E={4} F={5} G={6} H={7} I={8} J={9}', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J');
    AssertEquals(message.GetText(), 'A=A B=B C=C D=D E=E F=F G=G H=H I=I J=J');
    Messages.WritelnMsg;
    EndTest('TestUnitMessages');
  end;

  // ----------------------------------------------------------------------------
  // Unit StringUtilities
  // ----------------------------------------------------------------------------
  procedure TestStringUtilities;
  var
    s: String;
    i: Integer;
  begin
    s := '   12345 67890';
    i := 1;
    AssertEquals(StringUtilities.GetNumber(s, i), '12345');

    s := 'danaBank extmem ''dana_bank.obx''';
    i := 32;
    AssertEquals(StringUtilities.GetNumber(s, i), '');
  end;

begin
  try
    TestUnitFileIO;
    TestUnitCommon;
    TestUnitDatatypes;
    TestUnitMathEvaluate;
    TestUnitMessages;
    TestStringUtilities;
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
