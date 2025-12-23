// Working directory must be the project directory

program TestUnits;

{$I Defines.inc}
{$MODESWITCH NESTEDPROCVARS}

uses
  Assembler,
  Crt,
  Common,
  CommonIO,
  CommonTypes,
  CompilerTypes,
  DataTypes,
  Debugger,
  FileIO,
  MathEvaluate,
  Messages,
  Optimizer,
  OptimizerTest,
  OptimizeTemporary,
  OptimizerTypes,
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
    Assert(actual = expected, Format('The actual value ''%d'' is not equal to the expected value ''%d''.',
      [actual, expected]));
  end;

  procedure AssertEquals(actual, expected: TDataType); overload;
  begin
    Assert(actual = expected, Format('The actual value ''%s'' is not equal to the expected value ''%s''.',
      [GetDataTypeName(actual), GetDataTypeName(expected)]));
  end;

  procedure AssertEquals(actual, expected: TStringArray); overload;
var i: Integer;
  begin
    Assert(Length(actual) = Length(expected),
      Format('The actual array length ''%d'' is not equal to the expected array length ''%d''.',
      [Length(actual), Length(expected)]));
    for i:=Low(actual) to High(actual) do
    begin
       AssertEquals(actual[i], expected[i]);
    end;
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

  procedure TestLanguage();


    procedure TestFor;
    var
      i, j: Integer;
    begin
      j := 1;
      for i := 1 to 10 do
      begin
        AssertEquals(i, j);
        j := j + 1;
      end;
      AssertEquals(i, 10);
    end;

    procedure TestVal(const s: String; const ExpectedValue: Integer; const ExpectedCode: Integer);
    var
      ActualValue, ActualCode: Integer;
    begin
      System.Val(s, ActualValue, ActualCode);
      AssertEquals(ActualValue, ExpectedValue);
      AssertEquals(ActualCode, ExpectedCode);
    end;

    // https://www.freepascal.org/docs-html/ref/refsu69.html
    procedure TestArrayOfConst;
    type
      TListing = array[1..12] of String;
    var
      Listing: TListing;

      procedure DisplayArrayOfConst(const Args: array of const);
      var
        I: Longint;
      begin
        if High(Args) < 0 then
        begin
          Writeln('No aguments');
          exit;
        end;
        Writeln('Got ', High(Args) + 1, ' arguments :');
        for i := 0 to High(Args) do
        begin
          Write('Argument ', i, ' has type ');
          case Args[i].vtype of
            vtinteger:
              Writeln('Integer, Value :', args[i].vinteger);
            vtboolean:
              Writeln('Boolean, Value :', args[i].vboolean);
            vtchar:
              Writeln('Char, value : ', args[i].vchar);
            vtextended:
              Writeln('Extended, value : ', args[i].VExtended^);
            vtString:
              Writeln('ShortString, value :', args[i].VString^);
            vtPointer:
              Writeln('Pointer, value : ', Longint(Args[i].VPointer));
            vtPChar:
              Writeln('PChar, value : ', Args[i].VPChar);
            vtObject:
              Writeln('Object, name : ', Args[i].VObject.ClassName);
            vtClass:
              Writeln('Class reference, name :', Args[i].VClass.ClassName);
            vtAnsiString:
              Writeln('AnsiString, value :', Ansistring(Args[I].VAnsiString));
            else
              Writeln('(Unknown) : ', args[i].vtype);
          end;
        end;
      end;

      function TestVarArgs(const fmt: String; args: array of const): String;
      begin
        Result := Format(fmt, args);
      end;

    begin
      AssertEquals(TestVarArgs('%d', [1]), '1');
      DisplayArrayOfConst([1, 'String', @listing]);
    end;


    procedure TestFunctionPointer;
    var
      global: Integer;

      function TestFunction(const i: Integer): Boolean;
      begin
        Result := (i > global);
      end;

    type
      TFunction = function(const i: Integer): Boolean;
    var
      f: TFunction;
    begin

      Assert(TestFunction(1) = True);
      f := @TestFunction;
      global := 0;
      Assert(f(1) = True);
    end;

  begin
    StartTest('TestLanguage');

    TestFor;

    TestVal('1234', 1234, 0);
    TestVal('$1234', $1234, 0);

    TestArrayofConst;

    TestFunctionPointer;

    EndTest('TestLanguage');
  end;

  procedure TestUnitAssembler;

    procedure TestGetVAL(const s: String; const ExpectedValue: Integer);
    var
      ActualValue: Integer;
    begin
      ActualValue := Assembler.GetVAL(s);
      AssertEquals(ActualValue, ExpectedValue);
    end;

  begin
    StartTest('TestUnitAssembler');

    AssertEquals(Assembler.HexByte(Byte($00)), '$00');
    AssertEquals(Assembler.HexByte(Byte($0f)), '$0F');
    AssertEquals(Assembler.HexByte(Byte($80)), '$80');
    AssertEquals(Assembler.HexByte(Byte($ff)), '$FF');


    AssertEquals(Assembler.HexWord(Word($0000)), '$0000');
    AssertEquals(Assembler.HexWord(Word($000f)), '$000F');
    AssertEquals(Assembler.HexWord(Word($8000)), '$8000');
    AssertEquals(Assembler.HexWord(Word($ffee)), '$FFEE');


    AssertEquals(Assembler.HexLongWord($00), '$00000000');
    AssertEquals(Assembler.HexLongWord($ffeeddcc), '$FFEEDDCC');


    AssertEquals(HexLongWord($00123456), '$00123456');

    TestGetVAL('', -1);
    TestGetVAL('1234', -1);
    TestGetVAL('$1234', -1);
    TestGetVAL('#1234', 1234);
    TestGetVAL('#$1234', $1234);
    TestGetVAL('#-1234', -1234);
    TestGetVAL('#-$1234', -$1234);

    EndTest('TestUnitAssembler');
  end;

  procedure TestUnitFileIO;


    procedure TestNativeIO(filePath: TFilePath);
    var
      f: TextFile;
      s: String;
    begin
      StartTest('TestFileNativeIO');

      AssignFile(f, filePath);

      try
        reset(f); // Open the file for reading
        readln(f, s);
        writeln('Text read from file: ', s)

      finally
        CloseFile(f);
      end;
      EndTest('TestFileNativeIO');
    end;

    procedure TestFileIO(filePath: TFilePath);
    var
      binFile: IBinaryFile;
      cachedBinFile: IBinaryFile;
    var
      c1, c2: Char;
    begin
      StartTest('TestFileIO');

      binFile := TFileSystem.CreateBinaryFile(False);
      binFile.Assign(filePath);

      cachedBinFile := TFileSystem.CreateBinaryFile(True);
      cachedBinFile.Assign(filePath);
      try
        binFile.Reset(1);
        cachedBinFile.Reset(1);

        AssertEquals(binFile.GetFileSize, cachedBinFile.GetFileSize);
        while not binFile.EOF do
        begin
          if cachedBinFile.EOF then FailTest('End of cached file reached.');
          c1 := ' ';
          binFile.Read(c1);
          Write(c1);

          c2 := ' ';
          cachedBinFile.Read(c2);
          if (c1 <> c2) then FailTest('Read "' + c2 + '" from cached file instead of "' + c1 + '".');

          // WriteLn(IntToStr(Ord(c)));
        end;
        if not cachedBinFile.EOF then FailTest('End of cached file not reached.');

        binFile.Close;
        cachedBinFile.Close;
      except
        FailTest('Failed with Exception.');

      end;
      EndTest('TestFileIO');
    end;

  const
    TEST_MP_FILE_PATH = '..\src\tests\TestMP.pas';
  var
    pathList: TPathList;
  begin
    StartTest('TestUnitFileIO');
    TestNativeIO(TEST_MP_FILE_PATH);
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

  // ----------------------------------------------------------------------------
  // Unit Common, CompilerTypes
  // ----------------------------------------------------------------------------
  procedure TestUnitCommon;
  var
    filePath: TFilePath;
    sourceFileList: TSourceFileList;
    sourceFile: TSourceFile;
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
    filePath := '';
    try
      filePath := FindFile('TestUnit', 'unit');
    except
      on  ex: EHaltException do
      begin
        Assert(ex.GetExitCode = EHaltException.COMPILING_ABORTED);
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
  // Unit DataTypes
  // ----------------------------------------------------------------------------
  procedure TestUnitDataTypes;
  begin
    AssertEquals(DataTypes.GetDataSize(TDataType.UNTYPETOK), 0);
    AssertEquals(DataTypes.GetDataSize(TDataType.BYTETOK), 1);
    AssertEquals(DataTypes.GetDataSize(TDataType.WORDTOK), 2);

    AssertEquals(DataTypes.GetValueType(0), TDataType.BYTETOK);
    AssertEquals(DataTypes.GetValueType(255), TDataType.BYTETOK);
    AssertEquals(DataTypes.GetValueType($ffff), TDataType.WORDTOK);
    AssertEquals(DataTypes.GetValueType(-1), TDataType.SHORTINTTOK);
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
  procedure TestUnitStringUtilities;
  var
    s: String;
    i: Integer;
  begin
    StartTest('TestUnitStringUtilities');
    s := '   12345 67890';
    i := 1;
    AssertEquals(StringUtilities.GetNumber(s, i), '12345');

    s := 'danaBank extmem ''dana_bank.obx''';
    i := 32;
    AssertEquals(StringUtilities.GetNumber(s, i), '');
    EndTest('TestUnitStringUtilities');
  end;


  procedure TestUnitOptimizer;


    procedure TestOptimizeASM;

      procedure opt_TEST(const i: TListingIndex);
      begin

      end;

    var
      OptimizerStepList: TOptimizerStepList;
    begin
      OptimizerStepList := TOptimizerStepList.Create;
      OptimizerStepList.AddOptimizerStep('TestStep', @opt_TEST);
      OptimizerStepList.Optimize(1);
      FreeAndNil(OptimizerStepList);
    end;

    procedure TestOptimizeTemporary;
    var
      AsmBlockArray: TAsmBlockArray;
      ActualWriter: TStringArrayWriter;
      OptimizeTemporary: IOptimizeTemporary;
      ExpectedWriter: TStringArrayWriter;
    begin
      AsmBlockArray := Default(TAsmBlockArray);
      ActualWriter := TStringArrayWriter.Create;
      OptimizeTemporary := TOptimizeTemporary.Create;
      OptimizeTemporary.Initialize(asmBlockArray, ActualWriter);
      OptimizeTemporary.WriteOut('; Test');
      OptimizeTemporary.Finalize;

      ExpectedWriter := TStringArrayWriter.Create;
      ExpectedWriter.WriteLn('; Test');

      AssertEquals(ActualWriter.GetLines(), ExpectedWriter.GetLines);
    end;

  begin
    StartTest('TestUnitOptimizer');

    TestOptimizeASM;
    TestOptimizeTemporary;

    TraceFile := TFileSystem.CreateTextFile;
    traceFile.Assign('..\samples\tests\tests-debug\debug-trace.log');
    traceFile.Rewrite();
    Debugger.debugger := TDebugger.Create;
    pass := TPass.CODE_GENERATION;
    OptimizerTest.Test;
    traceFile.Close;
    EndTest('TestUnitOptimizer');
  end;

begin
  try
    TestLanguage;
    TestUnitFileIO;
    TestUnitAssembler;
    TestUnitCommon;
    TestUnitDataTypes;
    TestUnitMathEvaluate;
    TestUnitMessages;
    TestUnitStringUtilities;
    TestUnitOptimizer;
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
