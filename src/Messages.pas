unit Messages;

interface

{$I Defines.inc}

uses Common;

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

// TODO Test for structured text constants
type
  TMessageDefinition = record
    Text: String;
  end;

const
  UnderConstruction2: TMessageDefinition = (Text: 'Under Construction');

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


procedure Error(errorTokenIndex: TTokenIndex; msg: String); overload;
procedure Error(errorTokenIndex: TTokenIndex; msg: IMessage); overload;
procedure Error(errorTokenIndex: TTokenIndex; errorCode: TErrorCode); overload;
procedure ErrorForIdentifier(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TTokenIndex);


procedure ErrorForIdentifierIncompatibleTypes(errorTokenIndex: TTokenIndex; identIndex: TTokenIndex;
  srcType: Int64); overload;
procedure ErrorForIdentifierIncompatibleTypes(errorTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64; dstType: Int64); overload;
procedure ErrorForIncompatibleTypes(errorTokenIndex: TTokenIndex; srcType: Int64; dstType: Int64);

procedure ErrorForIncompatibleEnum(errorTokenIndex: TTokenIndex; srcType: Int64; dstType: Int64);

procedure ErrorForIdentifierIllegalTypeConversion(errorTokenIndex: TTokenIndex;
  identIndex: TIdentIndex; srcType: Int64);

procedure ErrorForIdentifierIncompatibleTypesArray(errorTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64);

procedure ErrorForIdentifierIncompatibleTypesArrayIdentifier(errorTokenIndex: TTokenIndex;
  identIndex: TIdentIndex; arrayIdentIndex: TIdentIndex);

procedure ErrorForRangeCheckError(warningTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64; dstType: Int64);

procedure Note(NoteTokenIndex: TTokenIndex; msg: String);
procedure NoteForIdentifierNotUsed(NoteTokenIndex: TTokenIndex; identIndex: TIdentIndex);

procedure Warning(warningTokenIndex: TTokenIndex; msg: IMessage); overload;
procedure Warning(warningTokenIndex: TTokenIndex; errorCode: TErrorCode); overload;

procedure WarningForIdentifier(warningTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TIdentIndex);
procedure WarningForRangeCheckError(warningTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64; DstType: Int64); overload;

procedure WritelnMsg;

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Console, FileIO, Utilities;

// -----------------------------------------------------------------------------
constructor TMessage.Create(const errorCode: TErrorCode; const Text: String; const variable0: String = '';
  const variable1: String = '');
var
  temp: String;
begin
  Self.errorCode := errorCode;
  temp := Text.Replace('{0}', variable0);
  temp := Text.Replace('{1}', variable1);
  Self.Text := temp;
end;

function TMessage.GetErrorCode: TErrorCode;
begin
  Result := ErrorCode;
end;

function TMessage.GetText: String;
begin
  Result := Text;
end;

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

function GetExpectedButTokenFound(tokenIndex: TTokenIndex): String;
begin

  Result := ' expected but ''' + GetSpelling(tokenIndex) + ''' found';

end;


function GetRangeCheckText(tokenIndex: TTokenIndex; identIndex: TIdentIndex; srcType: Int64; dstType: Int64): String;
var
  msg: String;
begin
  msg := 'Range check error while evaluating constants (' + IntToStr(srcType) +
    ' must be between ' + IntToStr(LowBound(tokenIndex, DstType)) + ' and ';

  if identIndex > 0 then
    msg := msg + IntToStr(Ident[identIndex].NumAllocElements - 1) + ')'
  else
    msg := msg + IntToStr(HighBound(tokenIndex, DstType)) + ')';
  Result := msg;
end;

// ----------------------------------------------------------------------------
// Private Method
// ----------------------------------------------------------------------------


function GetErrorMessage(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TIdentIndex = 0): String;
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

    WrongNumberOfParameters:
    begin
      Result := 'Wrong number of parameters specified for call to "' + Ident[identIndex].Name + '"';
    end;

    CantAdrConstantExp:
    begin
      Result := 'Can''t take the address of constant expressions';
    end;

    OParExpected:
    begin
      Result := '''(''' + GetExpectedButTokenFound(errorTokenIndex);
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

    IdentifierExpected:
    begin
      Result := 'Identifier' + GetExpectedButTokenFound(errorTokenIndex);
    end;

    IdNumExpExpected: begin
      Result := 'Identifier, number or expression' + GetExpectedButTokenFound(errorTokenIndex);
    end;

    LoHi:
    begin
      Result := 'lo/hi(dword/qword) returns the upper/lower word/dword';
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

procedure Error(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TIdentIndex);
var
  msg: String;
begin

  if not isConst then
  begin
    msg := GetErrorMessage(errorTokenIndex, errorCode, identIndex);
    Error(errorTokenIndex, msg);
  end;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Error(errorTokenIndex: TTokenIndex; msg: String);
var
  token, previousToken: TToken;
begin

  if not isConst then
  begin

    //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

    WritelnMsg;

    if errorTokenIndex > NumTok then errorTokenIndex := NumTok;

    TextColor(LIGHTRED);
    if errorTokenIndex > 0 then
    begin
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

procedure Error(errorTokenIndex: TTokenIndex; msg: IMessage);
begin
  Error(errorTokenIndex, msg.GetText());
end;


procedure Error(errorTokenIndex: TTokenIndex; errorCode: TErrorCode);
begin
  ErrorForIdentifier(errorTokenIndex, errorCode, 0);
end;

procedure ErrorForIdentifierIncompatibleTypes(errorTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64; dstType: Int64);
var
  msg: String;
begin

  msg := 'Incompatible types: got "';

  if srcType < 0 then msg := msg + '^';

  msg := msg + InfoAboutToken(abs(srcType)) + '" expected "';

  if DstType < 0 then msg := msg + '^';

  msg := msg + InfoAboutToken(abs(DstType)) + '"';

  Error(errorTokenIndex, TMessage.Create(TErrorCode.IncompatibleTypes, msg));
end;

procedure ErrorForIdentifierIncompatibleTypes(errorTokenIndex: TTokenIndex; identIndex: TIdentIndex; srcType: Int64);
begin
  ErrorForIdentifierIncompatibleTypes(errorTokenIndex, identIndex, srcType, 0);
end;

procedure ErrorForIncompatibleTypes(errorTokenIndex: TTokenIndex; srcType: Int64; dstType: Int64);
begin
  ErrorForIdentifierIncompatibleTypes(errorTokenIndex, 0, srcType, 0);
end;

procedure ErrorForIncompatibleEnum(errorTokenIndex: TTokenIndex; srcType: Int64; dstType: Int64);
var
  msg: String;
begin
  if DstType < 0 then
    msg := 'Incompatible types: got "' + GetEnumName(srcType) + '" expected "' +
      InfoAboutToken(abs(DstType)) + '"'
  else
  if srcType < 0 then
    msg := 'Incompatible types: got "' + InfoAboutToken(abs(srcType)) + '" expected "' +
      GetEnumName(DstType) + '"'
  else
    msg := 'Incompatible types: got "' + GetEnumName(srcType) + '" expected "' + GetEnumName(DstType) + '"';
  Error(errorTokenIndex, TMessage.Create(TErrorCode.IncompatibleEnum, msg));
end;


procedure ErrorForIdentifierIllegalTypeConversionOrIncompatibleTypesArray(errorTokenIndex: TTokenIndex;
  errorCode: TErrorCode; identIndex: TIdentIndex; srcType: Int64; arrayIndexIndex: TIdentIndex);
var
  msg: String;
begin

  Assert((ErrorCode = IllegalTypeConversion) or (ErrorCode = IncompatibleTypesArray));

  if errorCode = IllegalTypeConversion then
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

    if Ident[identIndex].AllocElementType <> UNTYPETOK then
      msg := msg + '"^' + InfoAboutToken(Ident[identIndex].AllocElementType) + '" '
    else
      msg := msg + '"' + InfoAboutToken(POINTERTOK) + '" ';

  end
  else
  begin
    msg := msg + IntToStr(Ident[identIndex].NumAllocElements - 1) + '] Of ' +
      InfoAboutToken(Ident[identIndex].AllocElementType) + '" ';
  end;

  if errorCode = IllegalTypeConversion then
    msg := msg + 'to "' + InfoAboutToken(srcType) + '"'
  else
  if arrayIndexIndex > 0 then
  begin

    msg := msg + 'expected ';

    if Ident[arrayIndexIndex].NumAllocElements_ > 0 then
      msg := msg + '"Array[0..' + IntToStr(Ident[arrayIndexIndex].NumAllocElements - 1) +
        '] Of Array[0..' + IntToStr(Ident[arrayIndexIndex].NumAllocElements_ - 1) + '] Of ' +
        InfoAboutToken(Ident[identIndex].AllocElementType) + '"'
    else
    if Ident[arrayIndexIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then
      msg := msg + '"^' + TypeArray[Ident[abs(srcType)].NumAllocElements].Field[0].Name + '"'
    else
    begin

      if Ident[abs(srcType)].DataType in [RECORDTOK, OBJECTTOK] then
        msg := msg + '"' + TypeArray[Ident[abs(srcType)].NumAllocElements].Field[0].Name + '"'
      else
        msg := msg + '"Array[0..' + IntToStr(Ident[arrayIndexIndex].NumAllocElements - 1) +
          '] Of ' + InfoAboutToken(Ident[abs(srcType)].AllocElementType) + '"';

    end;

  end
  else
  begin
    msg := msg + 'expected "' + InfoAboutToken(srcType) + '"';
  end;

  Error(errorTokenIndex, TMessage.Create(errorCode, msg));
end;

procedure ErrorForIdentifierIllegalTypeConversion(errorTokenIndex: TTokenIndex;
  identIndex: TIdentIndex; srcType: Int64);
begin
  ErrorForIdentifierIllegalTypeConversionOrIncompatibleTypesArray(errorTokenIndex,
    TErrorCode.IllegalTypeConversion, IdentIndex, srcType, 0);
end;

procedure ErrorForIdentifierIncompatibleTypesArray(errorTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64);
begin
  ErrorForIdentifierIllegalTypeConversionOrIncompatibleTypesArray(errorTokenIndex,
    TErrorCode.IncompatibleTypesArray, IdentIndex, srcType, 0);
end;

procedure ErrorForIdentifierIncompatibleTypesArrayIdentifier(errorTokenIndex: TTokenIndex;
  identIndex: TIdentIndex; arrayIdentIndex: TIdentIndex);
begin
  ErrorForIdentifierIllegalTypeConversionOrIncompatibleTypesArray(errorTokenIndex,
    TErrorCode.IncompatibleTypesArray, IdentIndex, 0, arrayIdentIndex);
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure ErrorForIdentifier(errorTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TIdentIndex);
var
  msg: String;
begin

  if not isConst then
  begin
    msg := GetErrorMessage(errorTokenIndex, errorCode, identIndex);
    Error(errorTokenIndex, msg);
  end;
end;


procedure ErrorForRangeCheckError(warningTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64; dstType: Int64);
begin
  Warning(warningTokenIndex, TMessage.Create(TErrorCode.RangeCheckError,
    GetRangeCheckText(warningTokenIndex, identIndex, srcType, dstType)));
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure Warning(warningTokenIndex: TTokenIndex; msg: IMessage); overload;
var
  i: Integer;
  a: String;
begin

  if pass = TPass.CODE_GENERATION then
  begin

    a := UnitName[Tok[warningTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[warningTokenIndex].Line) +
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

procedure WarningInternal(warningTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TIdentIndex);
var

  msg: String;
begin
  case errorCode of
    AlwaysTrue:
    begin
      msg := 'Comparison might be always true due to range of constant and expression';
    end;

    AlwaysFalse:
    begin
      msg := 'Comparison might be always false due to range of constant and expression';
    end;

    VariableNotInit:
    begin
      msg := 'Variable ''' + Ident[identIndex].Name + ''' does not seem to be initialized';
    end;
    else
      Assert(False);
  end;

  Warning(warningTokenIndex, TMessage.Create(errorCode, msg));

end;

procedure Warning(warningTokenIndex: TTokenIndex; errorCode: TErrorCode); overload;
begin
  WarningInternal(warningTokenIndex, errorCode, 0);
end;

procedure WarningForIdentifier(warningTokenIndex: TTokenIndex; errorCode: TErrorCode; identIndex: TIdentIndex);
begin
  WarningInternal(warningTokenIndex, errorCode, identIndex);
end;


procedure WarningForRangeCheckError(warningTokenIndex: TTokenIndex; identIndex: TIdentIndex;
  srcType: Int64; dstType: Int64);
begin
  Warning(warningTokenIndex, TMessage.Create(TErrorCode.RangeCheckError,
    GetRangeCheckText(warningTokenIndex, identIndex, srcType, dstType)));
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddMessage(var msg: TStringArray; var a: String);
var
  i: Integer;
begin

  i := High(msg);
  msg[i] := a;

  SetLength(msg, i + 2);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure NoteForIdentifierNotUsed(NoteTokenIndex: TTokenIndex; identIndex: TIdentIndex);
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
          AddMessage(msgNote, a);

      end;

    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Note(NoteTokenIndex: TTokenIndex; msg: String);
var
  a: String;
begin

  if Pass = TPass.CODE_GENERATION then
  begin

    a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) + ')' + ' Note: ';

    a := a + msg;

    AddMessage(msgNote, a);

  end;

end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


end.
