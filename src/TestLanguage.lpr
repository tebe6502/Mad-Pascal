program TestLanguage;

{$ASSERTIONS ON}

uses
  Crt,
  SysUtils;

type
  ITextFile = interface
  end;

type
  TTextFile = class(TInterfacedObject, ITextFile)
  public
    constructor Create;
  end;

type
  TFileSystem = class
  public
    class function CreateTextFile: ITextFile; static;
  end;



  // TTextFile

  constructor TTextFile.Create;
  begin
    inherited;
  end;

  class function TFileSystem.CreateTextFile: ITextFile;

  begin
    Result := TTextFile.Create;
  end;


  procedure TestTextFile;
  var
    textFile: ITextFile;
  begin
    textFile := TFileSystem.CreateTextFile;
    // Interfaced objects are implicitly reference counted and freed.
  end;

  // https://en.wikipedia.org/wiki/Single-precision_floating-point_format
  procedure TestRound(fl: Single);
  var
    i: Longint; // 32 bit
  var
    j: Longint; // 32 bit
  begin
    i := Round(fl * 256);  // Round Next Even
    j := Longint(fl);

    Writeln(fl, ' i=', i: 11, ' ', IntToHex(i, 8), ' j=', j: 11, ' ', IntToHex(j, 8));
  end;


  procedure AssertEquals(actualValue: Longint; expectedValue: Longint; message: String); overload;
  begin
    if actualValue <> expectedValue then
    begin
      WriteLn('ERROR: Actual value ' + IntToStr(actualValue) + ' is different from expected value ' +
        IntToStr(expectedValue) + '. ' + message);
    end;
  end;

  procedure AssertEquals(actualValue: String; expectedValue: String; message: String = ''); overload;
  begin
    if actualValue <> expectedValue then
    begin
      WriteLn('ERROR: Actual value ' + actualValue + ' is different from expected value ' +
        expectedValue + '. ' + message);
    end;
  end;

  procedure TestRoundAll();
  begin

    TestRound(1);
    TestRound(2);
    TestRound(4);
    TestRound(8);

    TestRound(-1);
    TestRound(-2);
    TestRound(-4);
    TestRound(-8);

    TestRound(0.1);
    TestRound(0.5);
    TestRound(1.5);
    TestRound(1.9);

    TestRound(-0.1);
    TestRound(-0.5);
    TestRound(-1.1);
    TestRound(-1.5);
    TestRound(-1.9);

  end;

  procedure TestFloats;

  const
//  Float16 does not exist in standard FPC / Delphi.
//  See https://github.com/tebe6502/16bit-half-float-in-Pascal
//  FLOAT16_CONST: Float16 = 0.288675135;  { SQRT(3) / 6 }
//  FLOAT16_CONST_STRING: String = '0.2890';

    REAL_CONST: Real = 0.288675135;  { SQRT(3) / 6 }
    REAL_CONST_STRING: String = '0,288675135';

    SINGLE_CONST: Single = 0.288675135;  { SQRT(3) / 6 }
    SINGLE_CONST_STRING: String = '0,2886751294';

  begin
//  AssertEquals(FloatToStr(FLOAT16_CONST), FLOAT16_CONST_STRING);
    AssertEquals(FloatToStr(REAL_CONST), REAL_CONST_STRING);
    AssertEquals(FloatToStr(SINGLE_CONST), SINGLE_CONST_STRING);
  end;

begin
  TestRoundAll;
  TestFloats;
  TestTextFile;
  WriteLn('Press any key to continue.');
  repeat
  until KeyPressed;
end.
