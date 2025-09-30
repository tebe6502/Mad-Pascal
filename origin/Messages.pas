unit Messages;

interface

{$i define.inc}

uses Common;

type
  ErrorCode =
    (
    UnknownIdentifier, OParExpected, IdentifierExpected, IncompatibleTypeOf, UserDefined,
    IdNumExpExpected, IncompatibleTypes, IncompatibleEnum, OrdinalExpectedFOR, CantAdrConstantExp,
    VariableExpected, WrongNumParameters, OrdinalExpExpected, RangeCheckError, RangeCheckError_,
    VariableNotInit, ShortStringLength, StringTruncated, TypeMismatch, CantReadWrite,
    SubrangeBounds, TooManyParameters, CantDetermine, UpperBoundOfRange, HighLimit,
    IllegalTypeConversion, IncompatibleTypesArray, IllegalExpression, AlwaysTrue, AlwaysFalse,
    UnreachableCode, IllegalQualifier, LoHi, StripedAllowed
    );

type
  TErrorCode = ErrorCode;

// ----------------------------------------------------------------------------

procedure Error(tokenIndex: TTokenIndex; const msg: String); overload;
procedure Error(const tokenIndex: TTokenIndex; const errorCode: TErrorCode); overload;

function ErrorMessage(ErrTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0;
  SrcType: Int64 = 0; DstType: Int64 = 0): String;

procedure iError(ErrTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0;
  SrcType: Int64 = 0; DstType: Int64 = 0);

procedure newMsg(var msg: TArrayString; var a: String);

procedure Note(NoteTokenIndex: Integer; IdentIndex: Integer); overload;

procedure Note(NoteTokenIndex: Integer; Msg: String); overload;

procedure Warning(WarnTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0;
  SrcType: Int64 = 0; DstType: Int64 = 0);

procedure WritelnMsg;

// ----------------------------------------------------------------------------

implementation

uses Crt;

// -----------------------------------------------------------------------------


procedure WritelnMsg;
var
  i: Integer;
begin

  TextColor(LIGHTGREEN);

  for i := 0 to High(msgWarning) - 1 do writeln(msgWarning[i]);

  TextColor(LIGHTCYAN);

  for i := 0 to High(msgNote) - 1 do writeln(msgNote[i]);

  NormVideo;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ErrorMessage(ErrTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0;
  SrcType: Int64 = 0; DstType: Int64 = 0): String;
begin

  Result := '';

  case err of

    UserDefined: Result := 'User defined: ' + msgUser[Tok[ErrTokenIndex].Value];

    UnknownIdentifier: if IdentIndex > 0 then
        Result := 'Identifier not found ''' + Ident[IdentIndex].Alias + ''''
      else
        Result := 'Identifier not found ''' + Tok[ErrTokenIndex].Name^ + '''';

    IncompatibleTypeOf: Result := 'Incompatible type of ' + Ident[IdentIndex].Name;
    IncompatibleEnum: if DstType < 0 then
        Result := 'Incompatible types: got "' + GetEnumName(SrcType) + '" expected "' + InfoAboutToken(abs(DstType)) + '"'
      else
        if SrcType < 0 then
          Result := 'Incompatible types: got "' + InfoAboutToken(abs(SrcType)) + '" expected "' + GetEnumName(DstType) + '"'
        else
          Result := 'Incompatible types: got "' + GetEnumName(SrcType) + '" expected "' + GetEnumName(DstType) + '"';

    WrongNumParameters: Result := 'Wrong number of parameters specified for call to "' + Ident[IdentIndex].Name + '"';

    CantAdrConstantExp: Result := 'Can''t take the address of constant expressions';

    OParExpected: Result := '''(''' + ErrTokenFound(ErrTokenIndex);

    IllegalExpression: Result := 'Illegal expression';
    VariableExpected: Result := 'Variable identifier expected';
    OrdinalExpExpected: Result := 'Ordinal expression expected';
    OrdinalExpectedFOR: Result := 'Ordinal expression expected as ''FOR'' loop counter value';

    IncompatibleTypes: begin
      Result := 'Incompatible types: got "';

      if SrcType < 0 then Result := Result + '^';

      Result := Result + InfoAboutToken(abs(SrcType)) + '" expected "';

      if DstType < 0 then Result := Result + '^';

      Result := Result + InfoAboutToken(abs(DstType)) + '"';
    end;

    IdentifierExpected: Result := 'Identifier' + ErrTokenFound(ErrTokenIndex);
    IdNumExpExpected: Result := 'Identifier, number or expression' + ErrTokenFound(ErrTokenIndex);

    LoHi: Result := 'lo/hi(dword/qword) returns the upper/lower word/dword';

    IllegalTypeConversion, IncompatibleTypesArray:
    begin

      if err = IllegalTypeConversion then
      begin
        Result := 'Illegal type conversion: ';

        if Ident[IdentIndex].NumAllocElements > 0 then Result := Result + '"Array[0..';
      end
      else
      begin
        Result := 'Incompatible types: got ';
        if Ident[IdentIndex].NumAllocElements > 0 then Result := Result + '"Array[0..';
      end;


      if Ident[IdentIndex].NumAllocElements_ > 0 then
        Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements - 1) + '] Of Array[0..' +
          IntToStr(Ident[IdentIndex].NumAllocElements_ - 1) + '] Of ' + InfoAboutToken(Ident[IdentIndex].AllocElementType) + '" '
      else
        if Ident[IdentIndex].NumAllocElements = 0 then
        begin

          if Ident[IdentIndex].AllocElementType <> UNTYPETOK then
            Result := Result + '"^' + InfoAboutToken(Ident[IdentIndex].AllocElementType) + '" '
          else
            Result := Result + '"' + InfoAboutToken(POINTERTOK) + '" ';

        end
        else
          Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements - 1) + '] Of ' + InfoAboutToken(
            Ident[IdentIndex].AllocElementType) + '" ';

      if err = IllegalTypeConversion then
        Result := Result + 'to "' + InfoAboutToken(SrcType) + '"'
      else
        if SrcType < 0 then
        begin

          Result := Result + 'expected ';

          if Ident[abs(SrcType)].NumAllocElements_ > 0 then
            Result := Result + '"Array[0..' + IntToStr(Ident[abs(SrcType)].NumAllocElements - 1) +
              '] Of Array[0..' + IntToStr(Ident[abs(SrcType)].NumAllocElements_ - 1) + '] Of ' + InfoAboutToken(
              Ident[IdentIndex].AllocElementType) + '"'
          else
            if Ident[abs(SrcType)].AllocElementType in [RECORDTOK, OBJECTTOK] then
              Result := Result + '"^' + Types[Ident[abs(SrcType)].NumAllocElements].Field[0].Name + '"'
            else
            begin

              if Ident[abs(SrcType)].DataType in [RECORDTOK, OBJECTTOK] then
                Result := Result + '"' + Types[Ident[abs(SrcType)].NumAllocElements].Field[0].Name + '"'
              else
                Result := Result + '"Array[0..' + IntToStr(Ident[abs(SrcType)].NumAllocElements - 1) +
                  '] Of ' + InfoAboutToken(Ident[abs(SrcType)].AllocElementType) + '"';

            end;

        end
        else
          Result := Result + 'expected "' + InfoAboutToken(SrcType) + '"';

    end;

    AlwaysTrue: Result := 'Comparison might be always true due to range of constant and expression';

    AlwaysFalse: Result := 'Comparison might be always false due to range of constant and expression';

    RangeCheckError: begin
      Result := 'Range check error while evaluating constants (' + IntToStr(SrcType) +
        ' must be between ' + IntToStr(LowBound(ErrTokenIndex, DstType)) + ' and ';

      if IdentIndex > 0 then
        Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements - 1) + ')'
      else
        Result := Result + IntToStr(HighBound(ErrTokenIndex, DstType)) + ')';

    end;

    RangeCheckError_: begin
      Result := 'Range check error while evaluating constants (' + IntToStr(SrcType) +
        ' must be between ' + IntToStr(LowBound(ErrTokenIndex, DstType)) + ' and ';

      if IdentIndex > 0 then
        Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements_ - 1) + ')'
      else
        Result := Result + IntToStr(HighBound(ErrTokenIndex, DstType)) + ')';

    end;

    VariableNotInit: Result := 'Variable ''' + Ident[IdentIndex].Name + ''' does not seem to be initialized';
    ShortStringLength: Result := 'String literal has more characters than short string length';
    StringTruncated: Result := 'String constant truncated to fit STRING[' + IntToStr(
        Ident[IdentIndex].NumAllocElements - 1) + ']';
    CantReadWrite: Result := 'Can''t read or write variables of this type';
    TypeMismatch: Result := 'Type mismatch';
    UnreachableCode: Result := 'unreachable code';
    IllegalQualifier: Result := 'Illegal qualifier';
    SubrangeBounds: Result := 'Constant expression violates subrange bounds';
    TooManyParameters: Result := 'Too many formal parameters in ' + Ident[IdentIndex].Name;
    CantDetermine: Result := 'Can''t determine which overloaded function ''' + Ident[IdentIndex].Name + ''' to call';
    UpperBoundOfRange: Result := 'Upper bound of range is less than lower bound';
    HighLimit: Result := 'High range limit > ' + IntToStr(High(Word));


    StripedAllowed: Result := 'Striped array is allowed for maximum [0..255] size';
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure iError(ErrTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0; SrcType: Int64 = 0;
  DstType: Int64 = 0);
var
  Msg: String;
begin

  if not isConst then
  begin

    //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

    WritelnMsg;

    Msg := ErrorMessage(ErrTokenIndex, err, IdentIndex, SrcType, DstType);

    if ErrTokenIndex > NumTok then ErrTokenIndex := NumTok;

    TextColor(LIGHTRED);

    WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) +
      ',' + IntToStr(Succ(Tok[ErrTokenIndex - 1].Column)) + ')' + ' Error: ' + Msg);

    NormVideo;

    FreeTokens;

    CloseFile(OutFile);
    Erase(OutFile);

    Halt(2);

  end;

  isError := True;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Error(tokenIndex: TTokenIndex; const msg: String);
begin

  if not isConst then
  begin

    //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

    WritelnMsg;

    if tokenIndex > NumTok then tokenIndex := NumTok;

    TextColor(LIGHTRED);

    WriteLn(UnitName[Tok[tokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[tokenIndex].Line) +
      ',' + IntToStr(Succ(Tok[tokenIndex - 1].Column)) + ')' + ' Error: ' + Msg);

    NormVideo;

    FreeTokens;

    CloseFile(OutFile);
    Erase(OutFile);

    Halt(2);

  end;

  isError := True;

end;

procedure Error(const tokenIndex: TTokenIndex; const errorCode: TErrorCode); overload;
begin
  iError(tokenIndex, errorCode);
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Warning(WarnTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0;
  SrcType: Int64 = 0; DstType: Int64 = 0);
var
  i: Integer;
  Msg, a: String;
begin

  if Pass = CODEGENERATIONPASS then
  begin

    Msg := ErrorMessage(WarnTokenIndex, err, IdentIndex, SrcType, DstType);

    a := UnitName[Tok[WarnTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[WarnTokenIndex].Line) +
      ')' + ' Warning: ' + Msg;

    for i := High(msgWarning) - 1 downto 0 do
      if msgWarning[i] = a then exit;

    i := High(msgWarning);
    msgWarning[i] := a;
    SetLength(msgWarning, i + 2);

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure newMsg(var msg: TArrayString; var a: String);
var
  i: Integer;
begin

  i := High(msg);
  msg[i] := a;

  SetLength(msg, i + 2);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Note(NoteTokenIndex: Integer; IdentIndex: Integer); overload;
var
  a: String;
begin

  if Pass = CODEGENERATIONPASS then
    if pos('.', Ident[IdentIndex].Name) = 0 then
    begin

      a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) +
        ')' + ' Note: Local ';

      if Ident[IdentIndex].Kind <> UNITTYPE then
      begin

        case Ident[IdentIndex].Kind of
          CONSTANT: a := a + 'const';
          USERTYPE: a := a + 'type';
          LABELTYPE: a := a + 'label';

          VARIABLE: if Ident[IdentIndex].isAbsolute then
              a := a + 'absolutevar'
            else
              a := a + 'variable';

          PROCEDURETOK: a := a + 'proc';
          FUNCTIONTOK: a := a + 'func';
        end;

        a := a + ' ''' + Ident[IdentIndex].Name + '''' + ' not used';

        if pos('@FN', Ident[IdentIndex].Name) = 1 then

        else
          newMsg(msgNote, a);

      end;

    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Note(NoteTokenIndex: Integer; Msg: String); overload;
var
  a: String;
begin

  if Pass = CODEGENERATIONPASS then
  begin

    a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) + ')' + ' Note: ';

    a := a + Msg;

    newMsg(msgNote, a);

  end;

end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


end.
