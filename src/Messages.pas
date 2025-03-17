unit Messages;

interface

{$I Defines.inc}

uses Common, StringUtilities, Types;

type
  TErrorCode =
    (
    UnknownIdentifier, OParExpected, IdentifierExpected, IncompatibleTypeOf, UserDefined,
    IdNumExpExpected, IncompatibleTypes, IncompatibleEnum, OrdinalExpectedFOR, CantAdrConstantExp,
    VariableExpected, WrongNumParameters, OrdinalExpExpected, RangeCheckError, RangeCheckError_,
    VariableNotInit, ShortStringLength, StringTruncated, TypeMismatch, CantReadWrite,
    SubrangeBounds, TooManyParameters, CantDetermine, UpperBoundOfRange, HighLimit,
    IllegalTypeConversion, IncompatibleTypesArray, IllegalExpression, AlwaysTrue, AlwaysFalse,
    UnreachableCode, IllegalQualifier, LoHi, StripedAllowed
    );

// ----------------------------------------------------------------------------

procedure Error(errorTokenIndex: TTokenIndex; msg: String); overload;
procedure Error(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TTokenIndex = 0;
  srcType: Int64 = 0; DstType: Int64 = 0); overload;

procedure Note(NoteTokenIndex: TTokenIndex; identIndex: TTokenIndex); overload;
procedure Note(NoteTokenIndex: TTokenIndex; msg: String); overload;

procedure Warning(warningTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TTokenIndex = 0;
  srcType: Int64 = 0; DstType: Int64 = 0);

procedure WritelnMsg;

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Console, FileIO, Utilities;

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


function ErrorMessage(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TTokenIndex = 0;
  srcType: Int64 = 0; DstType: Int64 = 0): String;
begin

  Result := '';

  case errorCode of

    UserDefined:
    begin
      Result := 'User defined: ' + msgUser[Tok[errorTokenIndex].Value];
    end;

    UnknownIdentifier:
    begin
      if identIndex > 0 then
        Result := 'Identifier not found ''' + Ident[identIndex].Alias + ''''
      else
        Result := 'Identifier not found ''' + Tok[errorTokenIndex].Name + '''';
    end;

    IncompatibleTypeOf:
    begin
      Result := 'Incompatible type of ' + Ident[identIndex].Name;
    end;

    IncompatibleEnum:
    begin
      if DstType < 0 then
        Result := 'Incompatible types: got "' + GetEnumName(srcType) + '" expected "' +
          InfoAboutToken(abs(DstType)) + '"'
      else
      if srcType < 0 then
        Result := 'Incompatible types: got "' + InfoAboutToken(abs(srcType)) + '" expected "' +
          GetEnumName(DstType) + '"'
      else
        Result := 'Incompatible types: got "' + GetEnumName(srcType) + '" expected "' + GetEnumName(DstType) + '"';
    end;

    WrongNumParameters:
    begin
      Result := 'Wrong number of parameters specified for call to "' + Ident[identIndex].Name + '"';
    end;

    CantAdrConstantExp:
    begin
      Result := 'Can''t take the address of constant expressions';
    end;

    OParExpected:
    begin
      Result := '''(''' + ErrTokenFound(errorTokenIndex);
    end;

    IllegalExpression:
    begin
      Result := 'Illegal expression';
    end;

    VariableExpected: begin
      Result := 'Variable identifier expected';
    end;

    OrdinalExpExpected:
    begin
      Result := 'Ordinal expression expected';
    end;

    OrdinalExpectedFOR:
    begin
      Result := 'Ordinal expression expected as ''FOR'' loop counter value';
    end;

    IncompatibleTypes:
    begin
      Result := 'Incompatible types: got "';

      if srcType < 0 then Result := Result + '^';

      Result := Result + InfoAboutToken(abs(srcType)) + '" expected "';

      if DstType < 0 then Result := Result + '^';

      Result := Result + InfoAboutToken(abs(DstType)) + '"';
    end;

    IdentifierExpected:
    begin
      Result := 'Identifier' + ErrTokenFound(errorTokenIndex);
    end;

    IdNumExpExpected: begin
      Result := 'Identifier, number or expression' + ErrTokenFound(errorTokenIndex);
    end;

    LoHi:
    begin
      Result := 'lo/hi(dword/qword) returns the upper/lower word/dword';
    end;

    IllegalTypeConversion, IncompatibleTypesArray:
    begin

      if errorCode = IllegalTypeConversion then
        Result := 'Illegal type conversion: "Array[0..'
      else
      begin
        Result := 'Incompatible types: got ';
        if Ident[identIndex].NumAllocElements > 0 then Result := Result + '"Array[0..';
      end;


      if Ident[identIndex].NumAllocElements_ > 0 then
        Result := Result + IntToStr(Ident[identIndex].NumAllocElements - 1) + '] Of Array[0..' +
          IntToStr(Ident[identIndex].NumAllocElements_ - 1) + '] Of ' +
          InfoAboutToken(Ident[identIndex].AllocElementType) + '" '
      else
      if Ident[identIndex].NumAllocElements = 0 then
      begin

        if Ident[identIndex].AllocElementType <> UNTYPETOK then
          Result := Result + '"^' + InfoAboutToken(Ident[identIndex].AllocElementType) + '" '
        else
          Result := Result + '"' + InfoAboutToken(POINTERTOK) + '" ';

      end
      else
        Result := Result + IntToStr(Ident[identIndex].NumAllocElements - 1) + '] Of ' +
          InfoAboutToken(Ident[identIndex].AllocElementType) + '" ';

      if errorCode = IllegalTypeConversion then
        Result := Result + 'to "' + InfoAboutToken(srcType) + '"'
      else
      if srcType < 0 then
      begin

        Result := Result + 'expected ';

        if Ident[abs(srcType)].NumAllocElements_ > 0 then
          Result := Result + '"Array[0..' + IntToStr(Ident[abs(srcType)].NumAllocElements - 1) +
            '] Of Array[0..' + IntToStr(Ident[abs(srcType)].NumAllocElements_ - 1) + '] Of ' +
            InfoAboutToken(Ident[identIndex].AllocElementType) + '"'
        else
        if Ident[abs(srcType)].AllocElementType in [RECORDTOK, OBJECTTOK] then
          Result := Result + '"^' + TypeArray[Ident[abs(srcType)].NumAllocElements].Field[0].Name + '"'
        else
        begin

          if Ident[abs(srcType)].DataType in [RECORDTOK, OBJECTTOK] then
            Result := Result + '"' + TypeArray[Ident[abs(srcType)].NumAllocElements].Field[0].Name + '"'
          else
            Result := Result + '"Array[0..' + IntToStr(Ident[abs(srcType)].NumAllocElements - 1) +
              '] Of ' + InfoAboutToken(Ident[abs(srcType)].AllocElementType) + '"';

        end;

      end
      else
        Result := Result + 'expected "' + InfoAboutToken(srcType) + '"';

    end;

    AlwaysTrue:
    begin
      Result := 'Comparison might be always true due to range of constant and expression';
    end;

    AlwaysFalse:
    begin
      Result := 'Comparison might be always false due to range of constant and expression';
    end;

    RangeCheckError:
    begin
      Result := 'Range check error while evaluating constants (' + IntToStr(srcType) +
        ' must be between ' + IntToStr(LowBound(errorTokenIndex, DstType)) + ' and ';

      if identIndex > 0 then
        Result := Result + IntToStr(Ident[identIndex].NumAllocElements - 1) + ')'
      else
        Result := Result + IntToStr(HighBound(errorTokenIndex, DstType)) + ')';

    end;

    RangeCheckError_: begin
      Result := 'Range check error while evaluating constants (' + IntToStr(srcType) +
        ' must be between ' + IntToStr(LowBound(errorTokenIndex, DstType)) + ' and ';

      if identIndex > 0 then
        Result := Result + IntToStr(Ident[identIndex].NumAllocElements_ - 1) + ')'
      else
        Result := Result + IntToStr(HighBound(errorTokenIndex, DstType)) + ')';
    end;

    VariableNotInit:
    begin
      Result := 'Variable ''' + Ident[identIndex].Name + ''' does not seem to be initialized';
    end;

    ShortStringLength: begin
      Result := 'String literal has more characters than short string length';
    end;

    StringTruncated:
    begin
      Result := 'String constant truncated to fit STRING[' + IntToStr(Ident[identIndex].NumAllocElements - 1) + ']';
    end;

    CantReadWrite:
    begin
      Result := 'Can''t read or write variables of this type';
    end;

    TypeMismatch: begin
      Result := 'Type mismatch';
    end;

    UnreachableCode: begin
      Result := 'unreachable code';
    end;

    IllegalQualifier: begin
      Result := 'Illegal qualifier';
    end;

    SubrangeBounds: begin
      Result := 'Constant expression violates subrange bounds';
    end;

    TooManyParameters: begin
      Result := 'Too many formal parameters in ' + Ident[identIndex].Name;
    end;

    CantDetermine:
    begin
      Result := 'Can''t determine which overloaded function ''' + Ident[identIndex].Name + ''' to call';
    end;

    UpperBoundOfRange:
    begin
      Result := 'Upper bound of range is less than lower bound';
    end;

    HighLimit:
    begin
      Result := 'High range limit > ' + IntToStr(High(Word));
    end;

    StripedAllowed:
    begin
      Result := 'Striped array is allowed for maximum [0..255] size';
    end;
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Error(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TTokenIndex = 0;
  srcType: Int64 = 0; DstType: Int64 = 0);
var
  msg: String;
begin

  if not isConst then
  begin
    msg := ErrorMessage(errorTokenIndex, errorCode, identIndex, srcType, DstType);
    Error(errorTokenIndex, msg);
  end;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Error(errorTokenIndex: TTokenIndex; msg: String);
var
  token, previousToken: TToken;
begin

  Assert(NumTok > 0, 'No token in token list');

  if not isConst then
  begin

    //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

    WritelnMsg;

    if errorTokenIndex > NumTok then errorTokenIndex := NumTok;

    TextColor(LIGHTRED);
    token := Tok[errorTokenIndex];
    if (errorTokenIndex > 1) then
    begin
      previousToken := Tok[errorTokenIndex - 1];
      WriteLn(UnitName[token.UnitIndex].Path + ' (' + IntToStr(token.Line) + ',' +
        IntToStr(Succ(previousToken.Column)) + ')' + ' Error: ' + msg);
    end
    else
    begin
      WriteLn(UnitName[token.UnitIndex].Path + ' (' + IntToStr(token.Line) + ')' + ' Error: ' + msg);
    end;


    NormVideo;

    FreeTokens;

    if Outfile <> nil then
    begin
      OutFile.Close;
      OutFile.Erase;
    end;

    RaiseHaltException(THaltException.COMPILING_ABORTED);

  end;

  isError := True;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Warning(warningTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TTokenIndex = 0;
  srcType: Int64 = 0; DstType: Int64 = 0);
var
  i: Integer;
  msg, a: String;
begin

  if pass = TPass.CODE_GENERATION then
  begin

    msg := ErrorMessage(warningTokenIndex, errorCode, identIndex, srcType, DstType);

    a := UnitName[Tok[warningTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[warningTokenIndex].Line) +
      ')' + ' Warning: ' + msg;

    for i := High(msgWarning) - 1 downto 0 do
      if msgWarning[i] = a then exit;

    i := High(msgWarning);
    msgWarning[i] := a;
    SetLength(msgWarning, i + 2);

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure newMsg(var msg: TStringArray; var a: String);
var
  i: Integer;
begin

  i := High(msg);
  msg[i] := a;

  SetLength(msg, i + 2);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Note(NoteTokenIndex: TTokenIndex; identIndex: TTokenIndex); overload;
var
  a: String;
begin

  if Pass = TPass.CODE_GENERATION then
    if pos('.', Ident[identIndex].Name) = 0 then
    begin

      a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) +
        ')' + ' Note: Local ';

      if Ident[identIndex].Kind <> UNITTYPE then
      begin

        case Ident[identIndex].Kind of
          CONSTANT: a := a + 'const';
          USERTYPE: a := a + 'type';
          LABELTYPE: a := a + 'label';

          VARIABLE: if Ident[identIndex].isAbsolute then
              a := a + 'absolutevar'
            else
              a := a + 'variable';

          PROCEDURETOK: a := a + 'proc';
          FUNCTIONTOK: a := a + 'func';
        end;

        a := a + ' ''' + Ident[identIndex].Name + '''' + ' not used';

        if pos('@FN', Ident[identIndex].Name) = 1 then

        else
          newMsg(msgNote, a);

      end;

    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Note(NoteTokenIndex: TTokenIndex; msg: String); overload;
var
  a: String;
begin

  if Pass = TPass.CODE_GENERATION then
  begin

    a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) + ')' + ' Note: ';

    a := a + msg;

    newMsg(msgNote, a);

  end;

end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


end.
