unit Messages;

interface

{$I Defines.inc}

uses Common, CommonTypes, Tokens;

{$SCOPEDENUMS ON}
type
  TErrorCode =
    (
    UnknownIdentifier, OParExpected, IdentifierExpected, IncompatibleTypeOf, UserDefined,
    IdNumExpExpected, IncompatibleTypes, IncompatibleEnum, OrdinalExpectedFOR, CantAdrConstantExp,
    VariableExpected, WrongNumberOfParameters, OrdinalExpExpected, RangeCheckError,
    VariableNotInit, ShortStringLength, StringTruncated, TypeMismatch, CantReadWrite,
    SubrangeBounds, TooManyParameters, CantDetermine, UpperBoundOfRange, HighLimit,
    IllegalTypeConversion, IncompatibleTypesArray, IllegalExpression, AlwaysTrue, AlwaysFalse,
    UnreachableCode, IllegalQualifier, LoHi, StripedAllowed, FileNotFound, WrongParameterList,
    OperatorNotOverloaded, OperationNotSupportedForTypes, NotAllDeclarationsOverloaded, SyntaxError,
    CantAsignValuesToAnAddress, UndefinedResourceType, ResourceFileNotFound, DuplicateResource,
    OutOfResources, WrongSwitchToggle, IllegalOptimizationSpecified, IllegalAlignmentDirective,
    FilePathNotSpecified, ElseWithoutIf,
    EndifWithoutIf, TooManyFormalParameters, DuplicateIdentifier, IllegalCompilerDirective,
    UnexpectedCharacter, ConstantStringTooLong, ParameterMissing, UnitExpected, StringExceedsLine,
    ConstantExpressionExpected, RecursionInMacro, InvalidVariableAddress,
    ConstantExpected, CantTakeAddressOfIdentifier, DivisionByZero, IdentifierAlreadyDefined,
    FormalParameterNameExpected, TypeIdentifierExpected, FileParameterMustBeVAR, ReservedWordUserAsIdentifier,
    FunctionDirectiveForwardNotAllowedInInterfaceSection, ProcedureDirectiveForwardNotAllowedInInterfaceSection,
    CannotCombineRegisterWithPascal, CannotCombineInlineWithPascal, CannotCombineInlineWithInterrupt,
    CannotCombineInlineWithExternal, IllegalTypeDeclarationOfSetElements, FieldAfterMethodOrProperty,
    RecordSizeExceedsLimit,
    StringLengthNotInRange, InvalidTypeDefinition, ArrayLowerBoundNotInteger, ArrayLowerBoundNotZero,
    ArrayUpperBoundNotInteger, InvalidArrayOfPointers, ArraySizeExceedsRAMSize,
    MultiDimensionalArrayOfTypeNotSupported,
    ArrayOfTypeNotSupported, OnlyArrayOfTypeSupported, IdentifierIdentsNoMember, Unassigned,
    VariableConstantOrFunctionExpectedButProcedureFound, UnderConstruction, TypeIdentifierNotAllowed
    );

(*
// TODO Test for structured text constants
type
  TMessageDefinition = record
    Text: String;
  end;

const
  UnderConstruction2: TMessageDefinition = (Text: 'Under Construction');
*)

type
  IMessage = interface
    function GetErrorCode: TErrorCode;
    function GetText: String;
  end;

type
  TMessage = class(TInterfacedObject, IMessage)
    constructor Create(const errorCode: TErrorCode; const Text: String; const variable0: String = '';
      const variable1: String = '');
    function GetErrorCode: TErrorCode;
    function GetText: String;
  private
  var
    ErrorCode: TErrorCode;
    Text: String;
  end;

// ----------------------------------------------------------------------------


procedure Error(const tokenIndex: TTokenIndex; const msg: String); overload;
procedure Error(const tokenIndex: TTokenIndex; const msg: IMessage); overload;
procedure Error(const tokenIndex: TTokenIndex; const errorCode: TErrorCode); overload;
procedure ErrorForIdentifier(const tokenIndex: TTokenIndex; const errorCode: TErrorCode;
  const identIndex: TTokenIndex);

procedure ErrorIncompatibleTypes(const tokenIndex: TTokenIndex; const srcType: TDataType;
  const dstType: TDataType; const dstPointer: Boolean = False);

procedure ErrorIncompatibleEnumIdentifiers(const tokenIndex: TTokenIndex; const srcEnumIdent: TIdentIndex;
  destEnumIdent: TIdentIndex);
procedure ErrorIncompatibleEnumTypeIdentifier(const tokenIndex: TTokenIndex; const srcType: TDataType;
  dstEnumIndex: TIdentIndex);
procedure ErrorIncompatibleEnumIdentifierType(const tokenIndex: TTokenIndex; const srcEnumIndex: TIdentIndex;
  const dstType: TDataType);

procedure ErrorIdentifierIllegalTypeConversion(const tokenIndex: TTokenIndex; const identIndex: TIdentIndex;
  const tokenKind: TTokenKind);

procedure ErrorIdentifierIncompatibleTypesArray(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const tokenKind: TTokenKind);

procedure ErrorIdentifierIncompatibleTypesArrayIdentifier(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const arrayIdentIndex: TIdentIndex);

procedure ErrorRangeCheckError(const tokenIndex: TTokenIndex; const Value: TInteger; const dstType: TDataType);

procedure Warning(const tokenIndex: TTokenIndex; const msg: IMessage);

procedure WarningAlwaysTrue(const tokenIndex: TTokenIndex);
procedure WarningAlwaysFalse(const tokenIndex: TTokenIndex);
procedure WarningUnreachableCode(const tokenIndex: TTokenIndex);
procedure WarningLoHi(const tokenIndex: TTokenIndex);
procedure WarningShortStringLength(const tokenIndex: TTokenIndex);
procedure WarningStripedAllowed(const tokenIndex: TTokenIndex);
procedure WarningUserDefined(const tokenIndex: TTokenIndex);
procedure WarningVariableNotInitialized(const tokenIndex: TTokenIndex; const identIndex: TIdentIndex);
procedure WarningForRangeCheckError(const tokenIndex: TTokenIndex; const Value: TInteger; const dstType: TDataType);

procedure Note(tokenIndex: TTokenIndex; const msg: String);
procedure NoteForIdentifierNotUsed(tokenIndex: TTokenIndex; const identIndex: TIdentIndex);

procedure WritelnMsg;

// ----------------------------------------------------------------------------

implementation

uses SysUtils, TypInfo, Console, FileIO, Utilities;

// -----------------------------------------------------------------------------
constructor TMessage.Create(const errorCode: TErrorCode; const Text: String; const variable0: String = '';
  const variable1: String = '');
var
  l: Integer;
  i: Integer;
  c: Char;
begin
  Self.errorCode := errorCode;
  Self.Text := '';
  l := Length(Text);
  i := 1;
  repeat

    c := Text[i];
    if c = '{' then
    begin
      assert(i < l - 2, 'Invalid string pattern, too short ''' + Text + '''');
      assert(Text[i + 1] in ['0', '9'], 'Invalid string pattern, placeholder must be {0}..{9} ''' + Text + '''');
      assert(Text[i + 2] = '}', 'Invalid string pattern, missing } ''' + Text + '''');
      begin
        case Text[i] of
          '0': Self.Text := Self.Text + variable0;
          '1': Self.Text := Self.Text + variable1;
        end;
        i := i + 2;
      end;
    end;
    Inc(i);
  until i >= l;

end;

function TMessage.GetErrorCode: TErrorCode;
begin
  Result := ErrorCode;
end;

function TMessage.GetText: String;
begin
  Result := Text;
end;

// ----------------------------------------------------------------------------

procedure AddMessage(var msg: TStringArray; const a: String);
var
  i: Integer;
begin

  i := High(msg);
  msg[i] := a;

  SetLength(msg, i + 2);

end;

// ----------------------------------------------------------------------------

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

function GetExpectedButTokenFound(const tokenIndex: TTokenIndex): String;
begin

  Result := ' expected but ''' + GetTokenSpellingAtIndex(tokenIndex) + ''' found';

end;


function GetRangeCheckText(const tokenIndex: TTokenIndex; Value: TInteger; dstType: TDataType): String;
var
  msg: String;
begin
  msg := 'Range check error while evaluating constants. ' + IntToStr(Value) + ' must be between ' +
    IntToStr(LowBound(tokenIndex, dstType)) + ' and ' + IntToStr(HighBound(tokenIndex, dstType)) + ')';
  Result := msg;
end;

// ----------------------------------------------------------------------------
// Private Method
// ----------------------------------------------------------------------------


function GetUserDefinedText(const tokenIndex: TTokenIndex): String;
begin
  Result := 'User defined: ' + msgUser[Tok[tokenIndex].Value];
end;

function GetErrorMessage(const tokenIndex: TTokenIndex; const errorCode: TErrorCode;
  identIndex: TIdentIndex = 0): String;
begin

  Result := '';

  case errorCode of

    TErrorCode.UserDefined:
    begin
      Result := GetUserDefinedText(tokenIndex);
    end;

    TErrorCode.UnknownIdentifier:
    begin
      if identIndex > 0 then
        Result := 'Identifier not found ''' + Ident[identIndex].Alias + ''''
      else
        Result := 'Identifier not found ''' + Tok[tokenIndex].Name + '''';
    end;

    TErrorCode.IncompatibleTypeOf:
    begin
      Result := 'Incompatible type of ' + Ident[identIndex].Name;
    end;

    TErrorCode.WrongNumberOfParameters:
    begin
      Result := 'Wrong number of parameters specified for call to "' + Ident[identIndex].Name + '"';
    end;

    TErrorCode.CantAdrConstantExp:
    begin
      Result := 'Can''t take the address of constant expressions';
    end;

    TErrorCode.OParExpected:
    begin
      Result := '''(''' + GetExpectedButTokenFound(tokenIndex);
    end;

    TErrorCode.IllegalExpression:
    begin
      Result := 'Illegal expression';
    end;

    TErrorCode.VariableExpected: begin
      Result := 'Variable identifier expected';
    end;

    TErrorCode.OrdinalExpExpected:
    begin
      Result := 'Ordinal expression expected';
    end;

    TErrorCode.OrdinalExpectedFOR:
    begin
      Result := 'Ordinal expression expected as ''FOR'' loop counter value';
    end;

    TErrorCode.IdentifierExpected:
    begin
      Result := 'Identifier' + GetExpectedButTokenFound(tokenIndex);
    end;

    TErrorCode.IdNumExpExpected: begin
      Result := 'Identifier, number or expression' + GetExpectedButTokenFound(tokenIndex);
    end;

    TErrorCode.StringTruncated:
    begin
      Result := 'String constant truncated to fit STRING[' + IntToStr(Ident[identIndex].NumAllocElements - 1) + ']';
    end;

    TErrorCode.CantReadWrite:
    begin
      Result := 'Can''t read or write variables of this type';
    end;

    TErrorCode.TypeMismatch: begin
      Result := 'Type mismatch';
    end;


    TErrorCode.IllegalQualifier: begin
      Result := 'Illegal qualifier';
    end;

    TErrorCode.SubrangeBounds: begin
      Result := 'Constant expression violates subrange bounds';
    end;

    TErrorCode.TooManyParameters: begin
      Result := 'Too many formal parameters in ' + Ident[identIndex].Name;
    end;

    TErrorCode.CantDetermine:
    begin
      Result := 'Can''t determine which overloaded function ''' + Ident[identIndex].Name + ''' to call';
    end;

    TErrorCode.UpperBoundOfRange:
    begin
      Result := 'Upper bound of range is less than lower bound';
    end;

    TErrorCode.HighLimit:
    begin
      Result := 'High range limit > ' + IntToStr(High(Word));
    end;
  end;

end;

procedure Error(const tokenIndex: TTokenIndex; const errorCode: TErrorCode; identIndex: TIdentIndex); overload;
var
  msg: String;
begin

  if not isConst then
  begin
    msg := GetErrorMessage(tokenIndex, errorCode, identIndex);
    Error(tokenIndex, msg);
  end;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Error(const tokenIndex: TTokenIndex; const msg: String); overload;
var
  effectiveTokenIndex: TTokenIndex;
  token, previousToken: TToken;
begin

  if not isConst then
  begin

    //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

    WritelnMsg;

    if tokenIndex <= NumTok then effectiveTokenIndex := tokenIndex
    else
      effectiveTokenIndex := NumTok;

    TextColor(LIGHTRED);
    if tokenIndex > 0 then
    begin
      token := Tok[effectiveTokenIndex];
      if (effectiveTokenIndex > 1) then
      begin
        previousToken := Tok[effectiveTokenIndex - 1];
        WriteLn(UnitName[token.UnitIndex].Path + ' (' + IntToStr(token.Line) + ',' +
          IntToStr(Succ(previousToken.Column)) + ')' + ' Error: ' + msg);
      end
      else
      begin
        WriteLn(UnitName[token.UnitIndex].Path + ' (' + IntToStr(token.Line) + ')' + ' Error: ' + msg);
      end;
    end
    else
    begin
      WriteLn('Error: ' + msg);
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

procedure Error(const tokenIndex: TTokenIndex; const msg: IMessage); overload;
var
  enumValue: Integer;
  enumName: String;
begin
  enumValue := Ord(msg.GetErrorCode());
  WriteStr(enumName, msg.GetErrorCode());
  Error(tokenIndex, 'E' + IntToStr(enumValue) + ' - ' + enumName + ': ' + msg.GetText());
end;


procedure Error(const tokenIndex: TTokenIndex; const errorCode: TErrorCode); overload;
begin
  ErrorForIdentifier(tokenIndex, errorCode, 0);
end;

procedure ErrorIncompatibleTypes(const tokenIndex: TTokenIndex; const srcType: TDataType;
  const dstType: TDataType; const dstPointer: Boolean);
var
  msg: String;
begin

  msg := 'Incompatible types: got "';

  msg := msg + InfoAboutToken(srcType) + '" expected "';

  if dstPointer then msg := msg + '^';

  msg := msg + InfoAboutToken(DstType) + '"';

  Error(tokenIndex, TMessage.Create(TErrorCode.IncompatibleTypes, msg));
end;


procedure ErrorIncompatibleEnumIdentifiers(const tokenIndex: TTokenIndex; const srcEnumIdent: TIdentIndex;
  destEnumIdent: TIdentIndex);
var
  msg: String;
begin
  msg := 'Incompatible types: got "' + Common.GetEnumName(srcEnumIdent) + '" expected "' +
    Common.GetEnumName(destEnumIdent) + '"';
  Error(tokenIndex, TMessage.Create(TErrorCode.IncompatibleEnum, msg));
end;

procedure ErrorIncompatibleEnumTypeIdentifier(const tokenIndex: TTokenIndex; const srcType: TDataType;
  dstEnumIndex: TIdentIndex);
var
  msg: String;
begin

  msg := 'Incompatible types: got "' + InfoAboutToken(srcType) + '" expected "' +
    Common.GetEnumName(dstEnumIndex) + '"';

  Error(tokenIndex, TMessage.Create(TErrorCode.IncompatibleEnum, msg));
end;

procedure ErrorIncompatibleEnumIdentifierType(const tokenIndex: TTokenIndex; const srcEnumIndex: TIdentIndex;
  const dstType: TDataType);
var
  msg: String;
begin

  msg := 'Incompatible types: got "' + Common.GetEnumName(srcEnumIndex) + '" expected "' +
    InfoAboutToken(DstType) + '"';

  Error(tokenIndex, TMessage.Create(TErrorCode.IncompatibleEnum, msg));
end;


procedure ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(const tokenIndex: TTokenIndex;
  errorCode: TErrorCode; identIndex: TIdentIndex; tokenKind: TTokenKind; arrayIdentIndex: TIdentIndex);
var
  msg: String;
begin

  Assert((ErrorCode = TErrorCode.IllegalTypeConversion) or (ErrorCode = TErrorCode.IncompatibleTypesArray));

  if errorCode = TErrorCode.IllegalTypeConversion then
    msg := 'Illegal type conversion: "Array[0..'
  else
  begin
    msg := 'Incompatible types: got ';
    if Ident[identIndex].NumAllocElements > 0 then msg := msg + '"Array[0..';
  end;


  if Ident[identIndex].NumAllocElements_ > 0 then
    msg := msg + IntToStr(Ident[identIndex].NumAllocElements - 1) + '] Of Array[0..' +
      IntToStr(Ident[identIndex].NumAllocElements_ - 1) + '] Of ' +
      InfoAboutToken(Ident[identIndex].AllocElementType) + '" '
  else
  if Ident[identIndex].NumAllocElements = 0 then
  begin

    if Ident[identIndex].AllocElementType <> TTokenKind.UNTYPETOK then
      msg := msg + '"^' + InfoAboutToken(Ident[identIndex].AllocElementType) + '" '
    else
      msg := msg + '"' + InfoAboutToken(TTokenKind.POINTERTOK) + '" ';

  end
  else
  begin
    msg := msg + IntToStr(Ident[identIndex].NumAllocElements - 1) + '] Of ' +
      InfoAboutToken(Ident[identIndex].AllocElementType) + '" ';
  end;

  if errorCode = TErrorCode.IllegalTypeConversion then
    msg := msg + 'to "' + InfoAboutToken(tokenKind) + '"'
  else
  if arrayIdentIndex > 0 then
  begin

    msg := msg + 'expected ';

    if Ident[arrayIdentIndex].NumAllocElements_ > 0 then
      msg := msg + '"Array[0..' + IntToStr(Ident[arrayIdentIndex].NumAllocElements - 1) +
        '] Of Array[0..' + IntToStr(Ident[arrayIdentIndex].NumAllocElements_ - 1) + '] Of ' +
        InfoAboutToken(Ident[identIndex].AllocElementType) + '"'
    else
    if Ident[arrayIdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then
      msg := msg + '"^' + TypeArray[Ident[arrayIdentIndex].NumAllocElements].Field[0].Name + '"'
    else
    begin

      if Ident[arrayIdentIndex].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then
        msg := msg + '"' + TypeArray[Ident[arrayIdentIndex].NumAllocElements].Field[0].Name + '"'
      else
        msg := msg + '"Array[0..' + IntToStr(Ident[arrayIdentIndex].NumAllocElements - 1) +
          '] Of ' + InfoAboutToken(Ident[arrayIdentIndex].AllocElementType) + '"';

    end;

  end
  else
  begin
    msg := msg + 'expected "' + InfoAboutToken(tokenKind) + '"';
  end;

  Error(tokenIndex, TMessage.Create(errorCode, msg));
end;

procedure ErrorIdentifierIllegalTypeConversion(const tokenIndex: TTokenIndex; const identIndex: TIdentIndex;
  const tokenKind: TTokenKind);
begin
  ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(tokenIndex,
    TErrorCode.IllegalTypeConversion, identIndex, tokenKind, 0);
end;

procedure ErrorIdentifierIncompatibleTypesArray(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const tokenKind: TTokenKind);
begin
  ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(tokenIndex,
    TErrorCode.IncompatibleTypesArray, identIndex, tokenKind, 0);
end;

procedure ErrorIdentifierIncompatibleTypesArrayIdentifier(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const arrayIdentIndex: TIdentIndex);
begin
  ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(tokenIndex,
    TErrorCode.IncompatibleTypesArray, identIndex, TTokenKind.UNTYPETOK, arrayIdentIndex);
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure ErrorForIdentifier(const tokenIndex: TTokenIndex; const errorCode: TErrorCode;
  const identIndex: TIdentIndex);
var
  msg: String;
begin

  if not isConst then
  begin
    msg := GetErrorMessage(tokenIndex, errorCode, identIndex);
    Error(tokenIndex, msg);
  end;
end;


procedure ErrorRangeCheckError(const tokenIndex: TTokenIndex; const Value: TInteger; const dstType: TDataType);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.RangeCheckError, GetRangeCheckText(tokenIndex, Value, dstType)));
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure Warning(const tokenIndex: TTokenIndex; const msg: IMessage);
var
  i: Integer;
  a: String;
begin

  if pass = TPass.CODE_GENERATION then
  begin

    a := UnitName[Tok[tokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[tokenIndex].Line) +
      ')' + ' Warning: ' + msg.GetText();

    for i := High(msgWarning) - 1 downto 0 do
    begin
      if msgWarning[i] = a then exit;
    end;

    i := High(msgWarning);
    msgWarning[i] := a;
    SetLength(msgWarning, i + 2);

  end;

end;

procedure WarningAlwaysTrue(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.AlwaysTrue,
    'Comparison might be always true due to range of constant and expression'));
end;

procedure WarningAlwaysFalse(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.AlwaysFalse,
    'Comparison might be always false due to range of constant and expression'));
end;

procedure WarningUnreachableCode(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.UnreachableCode, 'Unreachable code'));
end;

procedure WarningLoHi(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.LoHi, 'lo/hi(dword/qword) returns the upper/lower word/dword'));
end;

procedure WarningShortStringLength(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.ShortStringLength,
    'String literal has more characters than short string length'));
end;

procedure WarningStripedAllowed(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.StripedAllowed,
    'Striped array is only allowed for maximum size of [0..255]'));
end;

procedure WarningUserDefined(const tokenIndex: TTokenIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.UserDefined,
    'Comparison might be always false due to range of constant and expression'));
end;

procedure WarningVariableNotInitialized(const tokenIndex: TTokenIndex; const identIndex: TIdentIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.VariableNotInit, 'Variable ''' +
    Ident[identIndex].Name + ''' does not seem to be initialized'));
end;


procedure WarningForRangeCheckError(const tokenIndex: TTokenIndex; const Value: TInteger; const dstType: TDataType);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.RangeCheckError, GetRangeCheckText(tokenIndex, Value, dstType)));
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure NoteForIdentifierNotUsed(tokenIndex: TTokenIndex; const identIndex: TIdentIndex);
var
  a: String;
begin

  if Pass = TPass.CODE_GENERATION then
    if pos('.', Ident[identIndex].Name) = 0 then
    begin

      a := UnitName[Tok[tokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[tokenIndex].Line) +
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

          TTokenKind.PROCEDURETOK: a := a + 'proc';
          TTokenKind.FUNCTIONTOK: a := a + 'func';
        end;

        a := a + ' ''' + Ident[identIndex].Name + '''' + ' not used';

        if pos('@FN', Ident[identIndex].Name) = 1 then

        else
          AddMessage(msgNote, a);

      end;

    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Note(tokenIndex: TTokenIndex; const msg: String);
var
  a: String;
begin

  if Pass = TPass.CODE_GENERATION then
  begin

    a := UnitName[Tok[tokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[tokenIndex].Line) + ')' + ' Note: ';
    a := a + msg;

    AddMessage(msgNote, a);

  end;

end;


end.
