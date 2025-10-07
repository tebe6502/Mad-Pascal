unit Messages;

{$I Defines.inc}

interface

uses Common, CompilerTypes, Datatypes, CommonTypes, Tokens;

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
      const variable1: String = ''; const variable2: String = ''; const variable3: String = '';
      const variable4: String = ''; const variable5: String = ''; const variable6: String = '';
      const variable7: String = ''; const variable8: String = ''; const variable9: String = '');
    function GetErrorCode: TErrorCode;
    function GetText: String;
  private
  var
    ErrorCode: TErrorCode;
    Text: String;
  end;

// ----------------------------------------------------------------------------

procedure Initialize;

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
 const dataType: TDataType);

procedure ErrorIdentifierIncompatibleTypesArray(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const dataType: TDataType);

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

uses Classes, SysUtils, TypInfo, Console, Utilities;

// -----------------------------------------------------------------------------
constructor TMessage.Create(const errorCode: TErrorCode; const Text: String; const variable0: String = '';
  const variable1: String = ''; const variable2: String = ''; const variable3: String = '';
  const variable4: String = ''; const variable5: String = ''; const variable6: String = '';
  const variable7: String = ''; const variable8: String = ''; const variable9: String = '');
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
      assert(i <= l - 2, 'Invalid string pattern, pattern ''' + Text + ''' is too short.');
      Inc(i);
      c := Text[i];
      assert(c in ['0' .. '9'], 'Invalid string pattern, placeholder ''' + c + ''' at index ' +
        IntToStr(i + 1) + ' of ''' + Text + ''' must be must a digit 0..9.');
      Inc(i);
      assert(Text[i] = '}', 'Invalid string pattern, missing } at index ' + IntToStr(i) + ' of ''' + Text + '''');
      begin
        case c of
          '0': Self.Text := Self.Text + variable0;
          '1': Self.Text := Self.Text + variable1;
          '2': Self.Text := Self.Text + variable2;
          '3': Self.Text := Self.Text + variable3;
          '4': Self.Text := Self.Text + variable4;
          '5': Self.Text := Self.Text + variable5;
          '6': Self.Text := Self.Text + variable6;
          '7': Self.Text := Self.Text + variable7;
          '8': Self.Text := Self.Text + variable8;
          '9': Self.Text := Self.Text + variable9;
          else
            Assert(False, 'Internal program error.');
        end;
      end;
    end
    else
    begin
      Self.Text := Self.Text + c;
    end;
    Inc(i);
  until i > l;

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

procedure Initialize;
begin
  msgLists.msgUser := TStringList.Create;
  msgLists.msgWarning := TStringList.Create;
  msgLists.msgNote := TStringList.Create;
end;

procedure WritelnMsg;
var
  i: Integer;
begin

  TextColor(LIGHTGREEN);

  for i := 0 to msgLists.msgWarning.Count - 1 do writeln(msgLists.msgWarning[i]);

  TextColor(LIGHTCYAN);

  for i := 0 to msgLists.msgNote.Count - 1 do writeln(msgLists.msgNote[i]);

  NormVideo;

end;


// ----------------------------------------------------------------------------

function GetExpectedButTokenFound(const tokenIndex: TTokenIndex): String;
begin

  Result := ' expected but ''' + tokenList.GetTokenSpellingAtIndex(tokenIndex) + ''' found';

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
  Result := 'User defined: ' + msgLists.msgUser[TokenAt(tokenIndex).Value];
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
        Result := 'Identifier not found ''' + IdentifierAt(identIndex).Alias + ''''
      else
        Result := 'Identifier not found ''' + TokenAt(tokenIndex).Name + '''';
    end;

    TErrorCode.IncompatibleTypeOf:
    begin
      Result := 'Incompatible type of ' + IdentifierAt(IdentIndex).Name;
    end;

    TErrorCode.WrongNumberOfParameters:
    begin
      Result := 'Wrong number of parameters specified for call to "' + IdentifierAt(IdentIndex).Name + '"';
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
      Result := 'String constant truncated to fit STRING[' +
        IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1) + ']';
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
      Result := 'Too many formal parameters in ' + IdentifierAt(IdentIndex).Name;
    end;

    TErrorCode.CantDetermine:
    begin
      Result := 'Can''t determine which overloaded function ''' + IdentifierAt(IdentIndex).Name + ''' to call';
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

// ----------------------------------------------------------------------------
// Write the previous tokens before the error position to see the tokenized context.
// ----------------------------------------------------------------------------

procedure WritePreviousTokens(const tokenIndex: TTokenIndex);
var
  fromTokenIndex, toTokenIndex: TTokenIndex;
  i: TTokenIndex;
  token: TToken;
begin
  fromTokenIndex := tokenIndex - 20;
  if fromTokenIndex < 1 then fromTokenIndex := 1;
  toTokenIndex := tokenIndex;
  for i := fromTokenIndex to toTokenIndex do
  begin
    token := TokenAt(i);
    WriteLn(Format('%s (line %d, column %d): kind=%s name=%s.',
      [token.SourceLocation.SourceFile.Path, token.SourceLocation.Line, token.SourceLocation.Column,
      GetTokenKindName(token.Kind), token.Name]));
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

    //TokenAt(NumTok-1].Column := TokenAt(NumTok].Column + TokenAt(NumTok-1].Column;

    if tokenIndex <= NumTok then effectiveTokenIndex := tokenIndex
    else
      effectiveTokenIndex := NumTok;

    TextColor(LIGHTRED);
    if tokenIndex > 0 then
    begin
      {$IFDEF DEBUG}
      WritePreviousTokens(effectiveTokenIndex);
      {$ENDIF}

      token := TokenAt(effectiveTokenIndex);
      if (effectiveTokenIndex > 1) then
      begin
        previousToken := TokenAt(effectiveTokenIndex - 1);
        WriteLn(Format('%s (line %d, column %d): Error: %s', [token.SourceLocation.SourceFile.Path,
          token.SourceLocation.Line, Succ(previousToken.SourceLocation.Column), msg]));
      end
      else
      begin
        WriteLn(Format('%s (line %d): Error: %s', [token.SourceLocation.SourceFile.Path,
          token.SourceLocation.Line, msg]));
      end;
    end
    else
    begin
      WriteLn('Error: ' + msg);
    end;



    NormVideo;

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

  msg := msg + InfoAboutDataType(srcType) + '" expected "';

  if dstPointer then msg := msg + '^';

  msg := msg + InfoAboutDataType(DstType) + '"';

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

  msg := 'Incompatible types: got "' + InfoAboutDataType(srcType) + '" expected "' +
    Common.GetEnumName(dstEnumIndex) + '"';

  Error(tokenIndex, TMessage.Create(TErrorCode.IncompatibleEnum, msg));
end;

procedure ErrorIncompatibleEnumIdentifierType(const tokenIndex: TTokenIndex; const srcEnumIndex: TIdentIndex;
  const dstType: TDataType);
var
  msg: String;
begin

  msg := 'Incompatible types: got "' + Common.GetEnumName(srcEnumIndex) + '" expected "' +
    InfoAboutDataType(DstType) + '"';

  Error(tokenIndex, TMessage.Create(TErrorCode.IncompatibleEnum, msg));
end;


procedure ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(const tokenIndex: TTokenIndex;
  errorCode: TErrorCode; identIndex: TIdentIndex; dataType: TDataType; arrayIdentIndex: TIdentIndex);
var
  identifier: TIdentifier;
  arrayIdentifier: TIdentifier;
  msg: String;
begin

  Assert((ErrorCode = TErrorCode.IllegalTypeConversion) or (ErrorCode = TErrorCode.IncompatibleTypesArray));

  identifier := IdentifierAt(IdentIndex);
  if errorCode = TErrorCode.IllegalTypeConversion then
    msg := 'Illegal type conversion: "Array[0..'
  else
  begin
    msg := 'Incompatible types: got ';
    if identifier.NumAllocElements > 0 then msg := msg + '"Array[0..';
  end;


  if identifier.NumAllocElements_ > 0 then
    msg := msg + IntToStr(identifier.NumAllocElements - 1) + '] Of Array[0..' +
      IntToStr(identifier.NumAllocElements_ - 1) + '] Of ' + InfoAboutDataType(identifier.AllocElementType) + '" '
  else
    if identifier.NumAllocElements = 0 then
    begin

      if identifier.AllocElementType <> TDataType.UNTYPETOK then
        msg := msg + '"^' + InfoAboutDataType(identifier.AllocElementType) + '" '
      else
        msg := msg + '"' + InfoAboutDataType(TDataType.POINTERTOK) + '" ';

    end
    else
    begin
      msg := msg + IntToStr(identifier.NumAllocElements - 1) + '] Of ' +
        InfoAboutDataType(identifier.AllocElementType) + '" ';
    end;

  if errorCode = TErrorCode.IllegalTypeConversion then
    msg := msg + 'to "' + InfoAboutDataType(dataType) + '"'
  else
    if arrayIdentIndex > 0 then
    begin
      arrayIdentifier := IdentifierAt(arrayIdentIndex);
      msg := msg + 'expected ';

      if IdentifierAt(arrayIdentIndex).NumAllocElements_ > 0 then
        msg := msg + '"Array[0..' + IntToStr(arrayIdentifier.NumAllocElements - 1) +
          '] Of Array[0..' + IntToStr(arrayIdentifier.NumAllocElements_ - 1) + '] Of ' +
          InfoAboutDataType(identifier.AllocElementType) + '"'
      else
        if arrayIdentifier.AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
          msg := msg + '"^' + GetTypeAtIndex(arrayIdentifier.NumAllocElements).Field[0].Name + '"'
        else
        begin

          if arrayIdentifier.DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
            msg := msg + '"' + GetTypeAtIndex(arrayIdentifier.NumAllocElements).Field[0].Name + '"'
          else
            msg := msg + '"Array[0..' + IntToStr(arrayIdentifier.NumAllocElements - 1) +
              '] Of ' + InfoAboutDataType(arrayIdentifier.AllocElementType) + '"';

        end;

    end
    else
    begin
      msg := msg + 'expected "' + InfoAboutDataType(dataType) + '"';
    end;

  Error(tokenIndex, TMessage.Create(errorCode, msg));
end;

procedure ErrorIdentifierIllegalTypeConversion(const tokenIndex: TTokenIndex; const identIndex: TIdentIndex;
  const dataType: TDataType);
begin
  ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(tokenIndex,
    TErrorCode.IllegalTypeConversion, identIndex, dataType, 0);
end;

procedure ErrorIdentifierIncompatibleTypesArray(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const dataType: TDataType);
begin
  ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(tokenIndex,
    TErrorCode.IncompatibleTypesArray, identIndex, dataType, 0);
end;

procedure ErrorIdentifierIncompatibleTypesArrayIdentifier(const tokenIndex: TTokenIndex;
  const identIndex: TIdentIndex; const arrayIdentIndex: TIdentIndex);
begin
  ErrorIdentifierIllegalTypeConversionOrIncompatibleTypesArray(tokenIndex,
    TErrorCode.IncompatibleTypesArray, identIndex, TDataType.UNTYPETOK, arrayIdentIndex);
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

  // Error flag must always be set.
  isError := True;
end;


procedure ErrorRangeCheckError(const tokenIndex: TTokenIndex; const Value: TInteger; const dstType: TDataType);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.RangeCheckError, GetRangeCheckText(tokenIndex, Value, dstType)));
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure Warning(const tokenIndex: TTokenIndex; const msg: IMessage);
var
  a: String;
begin

  if pass = TPass.CODE_GENERATION then
  begin

    a := TokenAt(tokenIndex).SourceLocation.SourceFile.Path + ' (' +
      IntToStr(TokenAt(tokenIndex).SourceLocation.Line) + ')' + ' Warning: ' + msg.GetText();

    // Add warning only once.
    if msgLists.msgWarning.IndexOf(a) < 0 then msgLists.msgWarning.Add(a);

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
  Warning(tokenIndex, TMessage.Create(TErrorCode.UserDefined, 'User defined: ' +
    msgLists.msgUser[TokenAt(tokenIndex).Value]));
end;

procedure WarningVariableNotInitialized(const tokenIndex: TTokenIndex; const identIndex: TIdentIndex);
begin
  Warning(tokenIndex, TMessage.Create(TErrorCode.VariableNotInit, 'Variable ''' +
    IdentifierAt(IdentIndex).Name + ''' does not seem to be initialized'));
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
    if pos('.', IdentifierAt(IdentIndex).Name) = 0 then
    begin

      a := TokenAt(tokenIndex).GetSourceFileLineString + ' Note: Local ';

      if IdentifierAt(IdentIndex).Kind <> TTokenKind.UNITTOK then
      begin

        case IdentifierAt(IdentIndex).Kind of
          TTokenKind.CONSTTOK: a := a + 'const';
          TTokenKind.TYPETOK: a := a + 'type';
          TTokenKind.LABELTOK: a := a + 'label';

          TTokenKind.VARTOK: if IdentifierAt(IdentIndex).isAbsolute then
              a := a + 'absolutevar'
            else
              a := a + 'variable';

          TTokenKind.PROCEDURETOK: a := a + 'proc';
          TTokenKind.FUNCTIONTOK: a := a + 'func';
        end;

        a := a + ' ''' + IdentifierAt(IdentIndex).Name + '''' + ' not used';

        if pos('@FN', IdentifierAt(IdentIndex).Name) = 1 then

        else
          msgLists.msgNote.Add(a);

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

    a := TokenAt(tokenIndex).GetSourceFileLineString + ' Note: ' + msg;

    msgLists.msgNote.Add(a);

  end;

end;


end.
