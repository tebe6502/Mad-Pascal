// Working directory must be the project directory

program TestUnits;

{$I Defines.inc}
{$MODESWITCH NESTEDPROCVARS}

uses
  Assembler,
  Crt,
  Common,
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
    Assert(actual = expected, 'The actual value ''' + IntToStr(actual) +
      ''' is not equal to the expected value ''' + IntToStr(expected) + '''.');
  end;

  procedure AssertEquals(actual, expected: TDataType); overload;
  begin
    Assert(actual = expected, 'The actual value ''' + GetDataTypeName(actual) +
      ''' is not equal to the expected value ''' + GetDataTypeName(expected) + '''.');
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
      global:=0;
      Assert(f(1)= True);
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
  var
    ShrShlCnt: Integer;
  type
    TListingIndex = Integer;
    TListing = array [0..1023] of String;
    TListing_tmp = array [0..127] of String;
    TString0_3_Array = array [0..3] of String;
  var

    listing: TListing;

    s: array [0..15] of TString0_3_Array;
  var
    l: Integer;
    x: Integer;
    t: String;

    function GetString(const a: String): String; overload;
    var
      i: Integer;
    begin

      Result := '';
      i := 6;

      if a <> '' then
        while not (a[i] in [' ', #9]) and (i <= length(a)) do
        begin
          Result := Result + a[i];
          Inc(i);
        end;

    end;


    function GetString(j: TListingIndex): String; overload;
    var
      i: Integer;
      a: String;
    begin

      Result := '';
      i := 6;

      a := listing[j];

      if a <> '' then
        while (i <= length(a)) and not (a[i] in [' ', #9]) do
        begin
          Result := Result + a[i];
          Inc(i);
        end;

    end;


    function GetStringLast(j: TListingIndex): String; overload;
    var
      i: Integer;
      a: String;
    begin

      Result := '';

      a := listing[j];

      if a <> '' then
      begin
        i := length(a);

        while not (a[i] in [' ', #9]) and (i > 0) do Dec(i);

        Result := copy(a, i + 1, 256);
      end;

    end;  //GetStringLast

    function GetBYTE(i: Integer): Integer;
    begin
      Result := GetVAL(copy(listing[i], 6, 4));
    end;

    function GetWORD(i, j: Integer): Integer;
    begin
      Result := GetVAL(copy(listing[i], 6, 4)) + GetVAL(copy(listing[j], 6, 4)) shl 8;
    end;

    function GetTRIPLE(i, j, k: Integer): Integer;
    begin
      Result := GetVAL(copy(listing[i], 6, 4)) + GetVAL(copy(listing[j], 6, 4)) shl 8 +
        GetVAL(copy(listing[k], 6, 4)) shl 16;
    end;

    function GetDWORD(i, j, k, l: Integer): Integer;
    begin
      Result := GetVAL(copy(listing[i], 6, 4)) + GetVAL(copy(listing[j], 6, 4)) shl 8 +
        GetVAL(copy(listing[k], 6, 4)) shl 16 + GetVAL(copy(listing[l], 6, 4)) shl 24;
    end;


    function GetARG(const n: Byte; const x: Shortint; reset: Boolean = True): String;
    var
      i: Integer;
      a: String;
    begin

      Result := '';

      if x < 0 then exit;

      a := s[x][n];

      if (a = '') then
      begin

        Result := IntToStr(Shortint(x + 8));

        case n of
          0: Result := ':STACKORIGIN+' + Result;
          1: Result := ':STACKORIGIN+STACKWIDTH+' + Result;
          2: Result := ':STACKORIGIN+STACKWIDTH*2+' + Result;
          3: Result := ':STACKORIGIN+STACKWIDTH*3+' + Result;
        end;

      end
      else
      begin

        i := 6;

        while a[i] in [' ', #9] do Inc(i);

        while (i <= length(a)) and not (a[i] in [' ', #9]) do
        begin
          Result := Result + a[i];
          Inc(i);
        end;

        if reset then s[x][n] := '';

      end;

    end;  //GetARG

    {$i include/cmd_listing.inc}

    function SKIP(i: TListingIndex): Boolean;
    begin

      if (i < 0) or (listing[i] = '') then
        Result := False
      else
        Result := seq(i) or sne(i) or spl(i) or smi(i) or scc(i) or scs(i) or jeq(i) or
          jne(i) or jpl(i) or jmi(i) or jcc(i) or jcs(i) or beq(i) or bne(i) or bpl(i) or bmi(i) or bcc(i) or bcs(i);
    end;

    function argMatch(i, j: TListingIndex): Boolean;
    begin
      Result := copy(listing[i], 6, 256) = copy(listing[j], 6, 256);
    end;


    procedure Expand(i, e: TListingIndex);
    var
      k: Integer;
    begin

      for k := l - 1 downto i do
      begin

        listing[k + e] := listing[k];

      end;

      Inc(l, e);

    end;

    procedure TestOptimizeASM;
    {$i OptimizeASM.inc}
    procedure opt_TEST(const i: TListingIndex);
    begin

    end;

    var
      OptimizerStepList: TOptimizerStepList;
    begin
      OptimizerStepList := TOptimizerStepList.Create;
      // InitializeOptimizerSteps(OptimizerStepList);
      OptimizerStepList.AddOptimizerStep('TestStep', @opt_TEST);
      t := '';
      OptimizerStepList.Optimize(1);
      FreeAndNil(OptimizerStepList);
    end;

  begin
    StartTest('TestUnitOptimizer');

    TestOptimizeASM;

    TraceFile := TFileSystem.CreateTextFile;
    traceFile.Assign('..\samples\tests\tests-debug\debug-trace.log');
    traceFile.Rewrite();
    Debugger.debugger := TDebugger.Create;
    pass := TPass.CODE_GENERATION;
    // OutFile.Flush;
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
