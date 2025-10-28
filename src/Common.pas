unit Common;

{$I Defines.inc}

interface

uses Classes, SysUtils, CommonTypes, CompilerTypes, Datatypes, FileIO, Memory, StringUtilities,
  Targets, Tokens;

const
  title = '1.7.5-Test';



const
  SYSTEM_UNIT_NAME = 'SYSTEM';

const
  SYSTEM_UNIT_FILE_NAME = 'system.pas';

const
  SYSTEM_UNIT_INDEX = 1;

var
  target: TTarget;

var

  // Command line parameters
  CODEORIGIN_BASE: Integer = -1;
  DATA_BASE: Integer = -1;
  ZPAGE_BASE: Integer = -1;
  STACK_BASE: Integer = -1;

  OutFile: ITextFile;

  PROGRAM_NAME: String = 'Program';
  LIBRARY_NAME: String;

  AsmBlockIndex: Integer;
  AsmBlock: array [0..4095] of String;

  _DataSegment: TWordMemory;
  _VarDataSize: Integer;
  StaticStringData: TWordMemory;

  AddDefines: Integer = 1;
  NumDefines: Integer = 1;  // NumDefines = AddDefines
  Defines: array [1..MAXDEFINES] of TDefine;

  NumTypes: Integer;
  _TypeArray: array [1..MAXTYPES] of TType;

  TokenList: TTokenList;

  // This is current index in the list, not the size of the list.
  NumIdent_: Integer;
  IdentifierList: TIdentifierList;

  SourceFileList: TSourceFileList;

  IFTmpPosStack: array of Integer;

  BreakPosStackTop: Integer;
  BreakPosStack: array [0..MAXPOSSTACK] of TPosStack;

  CodePosStackTop: Integer;
  CodePosStack: array [0..MAXPOSSTACK] of Word;

type
  TBlockStackIndex = Integer;

var
  BlockStackTop: TBlockStackIndex;
  BlockIndexStack: array [0..MAXBLOCKS - 1] of TBlockIndex;

  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;  // For dead code elimination

  OldConstValType: TDataType;

  NumPredefIdent, NumStaticStrChars, NumBlocks, run_func, NumProc, CodeSize, NumStaticStrCharsTmp,
  IfCnt, CaseCnt, IfdefLevel: Integer;

  ShrShlCnt: Integer; // Counter, used only for label generation

  pass: TPass;

  ActiveSourceFile: TSourceFile; // Initialized in Scanner.TokenizeProgramInitialization

  FastMul: Integer;
  // Initialized in Scanner.TokenizeProgramInitialization to -1, updated to page address from {$F [page address]}

  resArray: array of TResource;

  optyA, optyY, optyBP2, optyFOR0, optyFOR1, optyFOR2, optyFOR3: TString; // Initialized in ResetOpty

  msgLists: record
    msgWarning: TStringList;
    msgNote: TStringList;
    msgUser: TStringList;
    end;

  LinkObj: TStringArray;
  unitPathList: TPathList;

  WithName: TStringArray;

  // Optimizer Settings
  iOut: Integer;
  outTmp: TString;
  OptimizeBuf: TStringArray;

  optimize: record
    use: Boolean;
    SourceFile: TSourceFile;
    line, oldLine: Integer;
    end;

  codealign: record
    proc, loop, link: Integer;
    end;


  PROGRAMTOK_USE, INTERFACETOK_USE, LIBRARYTOK_USE, LIBRARY_USE, RCLIBRARY, OutputDisabled: Boolean;

  _isConst, _isError: Boolean;

function IsConst: Boolean;
function isError: Boolean;

var
  isInterrupt, IOCheck, Macros: Boolean;

  DataSegmentUse: Boolean; // Initialized in Scanner.TokenizeProgramInitialization

  LoopUnroll: Boolean;
  // Initialized in Scanner.TokenizeProgramInitialization, updated with {$OPTIMIZATION LOOPUNROLL|NOLOOPUNROLL }

  PublicSection: Boolean;  // Initialized in Scanner.TokenizeProgramInitialization

{$IFDEF USEOPTFILE}

  OptFile: ITextFile;

{$ENDIF}

  // ----------------------------------------------------------------------------

function NumTok: Integer;
function TokenAt(tokenIndex: TTokenIndex): TToken;

function NumIdent: Integer;
function IdentifierAt(identifierIndex: TIdentifierIndex): TIdentifier;

function Hex(a:cardinal; b:shortint): string;

procedure AddDefine(const defineName: TDefineName);
function SearchDefine(const defineName: TDefineName): TDefineIndex;

procedure CheckArrayIndex(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex; ArrayIndexType: TDataType);

procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex;
  ArrayIndexType: TDataType);

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: TTokenKind; DataType: TDataType;
  RightType: TDataType = TDataType.UNTYPETOK);

procedure CheckTok(const i: TTokenIndex; const ExpectedTokenCode: TTokenKind); overload;
procedure CheckTok(const Token: TToken; const ExpectedTokenCode: TTokenKind); overload;

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);

procedure DefineFilename(tokenIndex: TTokenIndex; StrValue: String);

function FindFile(FileName: String; ftyp: TString): TFilePath; overload;

procedure CheckCommonConstType(const tokenIndex: TTokenIndex; const DstType: TDataType; const SrcType: TDataType);

function GetCommonConstType(const tokenIndex: TTokenIndex; const DstType: TDataType;
  const SrcType: TDataType; const err: Boolean = True): Boolean;


procedure CheckCommonType(const tokenIndex: TTokenIndex; const LeftType: TDataType; const RightType: TDataType);

function GetCommonType(const tokenIndex: TTokenIndex; const LeftType: TDataType;
  const RightType: TDataType): TDataType;

function GetEnumName(IdentIndex: TIdentIndex): TString;


function GetVAL(a: String): Integer;

function LowBound(const i: TTokenIndex; const DataType: TDataType): TInteger;
function HighBound(const i: TTokenIndex; const DataType: TDataType): TInteger;


function GetVarDataSize: Integer;
procedure SetVarDataSize(const tokenIndex: TTokenIndex; const size: Integer);
procedure IncVarDataSize(const tokenIndex: TTokenIndex; const size: Integer);

function GetTypeAtIndex(const typeIndex: TTypeIndex): TType;

var
  DiagMode: Boolean;
  PauseMode: Boolean;
  TraceFile: ITextFile;

procedure LogTrace(message: String);

// ----------------------------------------------------------------------------

implementation

uses Messages, Utilities;

procedure LogTrace(message: String);
begin
  {$IFDEF USETRACEFILE}
       traceFile.Writeln(message);
  {$ENDIF}
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function GetVarDataSize: Integer;
begin
  Result := _VarDataSize;
end;


procedure SetVarDataSize(const tokenIndex: TTokenIndex; const size: Integer);
//var
//  token: TToken;
begin
  _VarDataSize := size;
  // token := TokenAt(tokenIndex);
  // LogTrace(Format('SetVarDataSize: TokenIndex=%d: %s %s VarDataSize=%d',
  //  [tokenIndex, token.GetSourceFileLocationString, 'TODO' {*token.GetSpelling*}, _VarDataSize]));
end;


procedure IncVarDataSize(const tokenIndex: TTokenIndex; const size: Integer);
begin
  SetVarDataSize(tokenIndex, _VarDataSize + size);
end;


function GetTypeAtIndex(const typeIndex: TTypeIndex): TType;
begin
  Result := _TypeArray[typeIndex];
end;

function FindFile(FileName: String; ftyp: TString): TFilePath; overload;
var
  unitPathText: String;
  msg: IMessage;
begin
  Result := unitPathList.FindFile(FileName);
  if Result = '' then
  begin
    if unitPathList.GetSize() = 0 then
    begin
      unitPathText :=
        'an empty unit path. Specify the folders for the unit path via the ''-ipath:<folder>'' command line parameter';
    end
    else
    begin
      unitPathText := 'unit path ''' + unitPathList.ToString + '''';
    end;
    if ftyp = 'unit' then
    begin
      msg := TMessage.Create(TErrorCode.FileNotFound, 'Cannot find {0} ''{1}'' used by program ''{2}'' in {3}.',
        ftyp, ChangeFileExt(FileName, ''), PROGRAM_NAME, unitPathText);

    end
    else
    begin
      msg := TMessage.Create(TErrorCode.FileNotFound, 'Cannot find {0} ''{1}'' used by program ''{2}'' in {3}.',
        ftyp, FileName, PROGRAM_NAME, unitPathText);
    end;
    Error(NumTok, msg);
  end;
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function Hex(a:cardinal; b:shortint): string;
(*----------------------------------------------------------------------------*)
(*  zamiana na zapis hexadecymalny                                            *)
(*  'B' okresla maksymalna liczbe nibbli do zamiany                           *)
(*  jesli sa jeszcze jakies wartosci to kontynuuje zamiane                    *)
(*----------------------------------------------------------------------------*)
var v: byte;

const
    tHex: array [0..15] of char =
    ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

begin
 Result := '';

 while (b > 0) or (a <> 0) do begin

  v := byte(a);
  Result := tHex[v shr 4] + tHex[v and $0f] + Result;

  a := a shr 8;

  dec(b,2);
 end;

 Result := '$' + Result;

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure AddDefine(const defineName: TDefineName);
begin
  if SearchDefine(defineName) = 0 then
  begin
    Inc(NumDefines);
    Defines[NumDefines].Name := defineName;

    Defines[NumDefines].Macro := '';
    Defines[NumDefines].Line := 0;
  end;
end;


function SearchDefine(const defineName: TDefineName): TDefineIndex;
var
  i: Integer;
begin
  for i := 1 to NumDefines do
    if Defines[i].Name = defineName then
    begin
      Exit(i);
    end;
  Result := 0;
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetEnumName(IdentIndex: Integer): TString;
var
  IdentTemp: Integer;


  function Search(Num: Cardinal): Integer;
  var
    IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    // Search all nesting levels from the current one to the most outer one
    for BlockStackIndex := BlockStackTop downto 0 do
      for IdentIndex := 1 to NumIdent do
        if (IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK) and
          (IdentifierAt(IdentIndex).NumAllocElements = Num) and (BlockIndexStack[BlockStackIndex] =
          IdentifierAt(IdentIndex).BlockIndex) then
          exit(IdentIndex);
  end;

begin

  Result := '';

  if IdentifierAt(IdentIndex).NumAllocElements > 0 then
  begin
    IdentTemp := Search(IdentifierAt(IdentIndex).NumAllocElements);

    if IdentTemp > 0 then
      Result := IdentifierAt(IdentTemp).Name;
  end
  else
    if IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK then
    begin
      IdentTemp := Search(IdentifierAt(IdentIndex).NumAllocElements);

      if IdentTemp > 0 then
        Result := IdentifierAt(IdentTemp).Name;
    end;

end;  //GetEnumName

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: TTokenKind; DataType: TDataType;
  RightType: TDataType = TDataType.UNTYPETOK);
begin

  //writeln(TokenAt(ErrTokenIndex].Name,',', op,',',DataType);

  if {(not (DataType in (OrdinalTypes + [REALTOK, POINTERTOK]))) or}
  // Operators for RealTypes
  ((DataType in RealTypes) and not (op in [TTokenKind.MULTOK, TTokenKind.DIVTOK, TTokenKind.PLUSTOK,
    TTokenKind.MINUSTOK, TTokenKind.GTTOK, TTokenKind.GETOK, TTokenKind.EQTOK, TTokenKind.NETOK,
    TTokenKind.LETOK, TTokenKind.LTTOK]))
    // Operators for IntegerTypes
    or ((DataType in IntegerTypes) and not (op in [TTokenKind.MULTOK, TTokenKind.IDIVTOK,
    TTokenKind.MODTOK, TTokenKind.SHLTOK, TTokenKind.SHRTOK, TTokenKind.ANDTOK, TTokenKind.PLUSTOK,
    TTokenKind.MINUSTOK, TTokenKind.ORTOK, TTokenKind.XORTOK, TTokenKind.NOTTOK, TTokenKind.GTTOK,
    TTokenKind.GETOK, TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK, TTokenKind.INTOK]))
    // Operators for Char
    or ((DataType = TDataType.CHARTOK) and not (op in [TTokenKind.GTTOK, TTokenKind.GETOK,
    TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK, TTokenKind.INTOK]))
    // Operators for Boolean
    or ((DataType = TDataType.BOOLEANTOK) and not (op in [TTokenKind.ANDTOK, TTokenKind.ORTOK,
    TTokenKind.XORTOK, TTokenKind.NOTTOK, TTokenKind.GTTOK, TTokenKind.GETOK, TTokenKind.EQTOK,
    TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK]))
    // Operators for Pointers
    or ((DataType in Pointers) and not (op in [TTokenKind.GTTOK, TTokenKind.GETOK,
    TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK, TTokenKind.PLUSTOK,
    TTokenKind.MINUSTOK])) then
  begin
    if DataType = RightType then
      Error(ErrTokenIndex, TMessage.Create(TErrorCode.OperatorNotOverloaded, 'Operator is not overloaded: ' +
        '"' + InfoAboutDataType(DataType) + '" ' + InfoAboutToken(op) + ' "' + InfoAboutDataType(RightType) + '"'))
    else
      Error(ErrTokenIndex, TMessage.Create(TErrorCode.OperationNotSupportedForTypes,
        'Operation "' + InfoAboutToken(op) + '" not supported for types "' + InfoAboutDataType(DataType) +
        '" and "' + InfoAboutDataType(RightType) + '"'));
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex(i: TTokenIndex; IdentIndex: Integer; ArrayIndex: TArrayIndex; ArrayIndexType: TDataType);
begin

  if (IdentifierAt(IdentIndex).NumAllocElements > 0) and (IdentifierAt(IdentIndex).AllocElementType <>
    TDataType.RECORDTOK) then
    if (ArrayIndex < 0) or (ArrayIndex > IdentifierAt(IdentIndex).NumAllocElements - 1 +
      Ord(IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK)) then
      if IdentifierAt(IdentIndex).NumAllocElements <> 1 then WarningForRangeCheckError(i, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TArrayIndex;
  ArrayIndexType: TDataType);
begin

  if IdentifierAt(IdentIndex).NumAllocElements_ > 0 then
    if (ArrayIndex < 0) or (ArrayIndex > IdentifierAt(IdentIndex).NumAllocElements_ - 1 +
      Ord(IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK)) then
      if IdentifierAt(IdentIndex).NumAllocElements_ <> 1 then
        WarningForRangeCheckError(i, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function LowBound(const i: TTokenIndex; const DataType: TDataType): TInteger;
begin

  Result := 0;

  case DataType of

    TDataType.UNTYPETOK: Error(i, TMessage.Create(TErrorCode.CantReadWrite,
        'Can''t read or write variables of this type'));
    TDataType.INTEGERTOK: Result := Low(Integer);
    TDataType.SMALLINTTOK: Result := Low(Smallint);
    TDataType.SHORTINTTOK: Result := Low(Shortint);
    TDataType.CHARTOK: Result := 0;
    TDataType.BOOLEANTOK: Result := Ord(Low(Boolean));
    TDataType.BYTETOK: Result := Low(Byte);
    TDataType.WORDTOK: Result := Low(Word);
    TDataType.CARDINALTOK: Result := Low(Cardinal);
    TDataType.STRINGTOK: Result := 1;
    TDataType.POINTERTOK: Result := 0;

    else
      Error(i, TMessage.Create(TErrorCode.TypeMismatch, 'Type mismatch'));
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function HighBound(const i: TTokenIndex; const DataType: TDataType): TInteger;
begin

  Result := 0;

  case DataType of

    TDataType.UNTYPETOK: Error(i, TMessage.Create(TErrorCode.CantReadWrite,
        'Can''t read or write variables of this type'));
    TDataType.INTEGERTOK: Result := High(Integer);
    TDataType.SMALLINTTOK: Result := High(Smallint);
    TDataType.SHORTINTTOK: Result := High(Shortint);
    TDataType.CHARTOK: Result := 255;
    TDataType.BOOLEANTOK: Result := Ord(High(Boolean));
    TDataType.BYTETOK: Result := High(Byte);
    TDataType.WORDTOK: Result := High(Word);
    {$IFNDEF PAS2JS}
    TDataType.CARDINALTOK: Result := High(Cardinal);
    {$ELSE}
    TDataType.CARDINALTOK: Result := 2147483647 ; // JAC!  Workaround until we can use BigInt instead of Integer
    {$ENDIF}
    TDataType.STRINGTOK: Result := 255;
    TDataType.POINTERTOK: Result := High(Word);

    else
      Error(i, TMessage.Create(TErrorCode.TypeMismatch, 'Type mismatch'));
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetVAL(a: String): Integer;
var
  err: Integer;
begin

  Result := -1;

  if a <> '' then
    if a[1] = '#' then
    begin
      val(copy(a, 2, length(a)), Result, err);

      if err > 0 then Result := -1;

    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckTok(const i: TTokenIndex; const ExpectedTokenCode: TTokenKind); overload;
var
  Token: TToken;
  found, expected: String;
begin

  Token := TokenAt(i);
  if Token.Kind <> ExpectedTokenCode then
  begin

    found := token.GetSpelling;
    expected := GetHumanReadbleTokenSpelling(ExpectedTokenCode);

    Error(Token.TokenIndex, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error, ' + '''' +
      expected + '''' + ' expected but ''' + found + ''' found.'));

  end;

end;

procedure CheckTok(const Token: TToken; const ExpectedTokenCode: TTokenKind); overload;
var
  found, expected: String;
begin
  if Token.Kind <> ExpectedTokenCode then
  begin

    found := token.GetSpelling;
    expected := GetHumanReadbleTokenSpelling(ExpectedTokenCode);

    Error(Token.TokenIndex, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error, ' + '''' +
      expected + '''' + ' expected but ''' + found + ''' found.'));

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
procedure CheckCommonConstType(const tokenIndex: TTokenIndex; const DstType: TDataType; const SrcType: TDataType);
begin
  GetCommonConstType(tokenIndex, DstType, SrcType, True);
end;

function GetCommonConstType(const tokenIndex: TTokenIndex; const DstType: TDataType;
  const SrcType: TDataType; const err: Boolean = True): Boolean;
begin

  Result := False;

  if IsCommonConstType(DstType, SrcType) then

    if err then
      ErrorIncompatibleTypes(tokenIndex, SrcType, DstType)
    else
      Result := True;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------



procedure CheckCommonType(const tokenIndex: TTokenIndex; const LeftType: TDataType; const RightType: TDataType);
begin
  GetCommonType(tokenIndex, LeftType, RightType);
end;

// TOO Move core to TDataType
function GetCommonType(const TokenIndex: TTokenIndex; const LeftType: TDataType;
  const RightType: TDataType): TDataType;
begin

  Result := TDataType.UNTYPETOK;

  if LeftType = RightType then     // General rule

    Result := LeftType

  else
    if (LeftType in IntegerTypes) and (RightType in IntegerTypes) then
      Result := LeftType;

  if (LeftType in Pointers) and (RightType in Pointers) then
    Result := LeftType;

  if LeftType = TDataType.UNTYPETOK then Result := RightType;

  if Result = TDataType.UNTYPETOK then
    ErrorIncompatibleTypes(TokenIndex, RightType, LeftType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure DefineFilename(tokenIndex: TTokenIndex; StrValue: String);
var
  i: Integer;
begin

  for i := 0 to High(linkObj) - 1 do
    if linkObj[i] = StrValue then
    begin
      TokenAt(tokenIndex).Value := i;
      exit;
    end;

  i := High(linkObj);
  linkObj[i] := StrValue;

  SetLength(linkObj, i + 2);

  TokenAt(tokenIndex).Value := i;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);
var
  i, len: Integer;
  Data: TWordMemory;
begin

  len := Length(StrValue);

  // TODO: Error?
  if len > 255 then
    Data[0] := 255
  else
    Data[0] := len;

  if (NumStaticStrChars + len > $FFFF) then
  begin
    writeln('DefineStaticString: ' + IntToStr(len));
    RaiseHaltException(EHaltException.COMPILING_ABORTED);
  end;

  // Writeln('DefineStaticString:  NumStaticStrChars=' + IntToStr(NumStaticStrChars) + ' Length=' +
  //   IntToStr(len) + ' Value=' + StrValue);
  for i := 1 to len do Data[i] := Ord(StrValue[i]);

  for i := 0 to NumStaticStrChars - len - 1 do
    if CompareWord(Data[0], StaticStringData[i], Len + 1) = 0 then
    begin

      TokenAt(StrTokenIndex).StrLength := len;
      TokenAt(StrTokenIndex).StrAddress := CODEORIGIN + i;

      exit;
    end;

  TokenAt(StrTokenIndex).StrLength := len;
  TokenAt(StrTokenIndex).StrAddress := CODEORIGIN + NumStaticStrChars;

  StaticStringData[NumStaticStrChars] := Data[0]; //length(StrValue);
  Inc(NumStaticStrChars);

  for i := 1 to len do
  begin
    StaticStringData[NumStaticStrChars] := Ord(StrValue[i]);
    Inc(NumStaticStrChars);
  end;

  //StaticStringData[NumStaticStrChars] := 0;
  //Inc(NumStaticStrChars);

end;

function IsConst: Boolean;
begin
  Result := _isConst;
end;

function isError: Boolean;
begin
  Result := _isError;
end;

// The function is currently kept for compatibility, simulating the previous global variable.
function NumTok: Integer;
begin
  Result := 0;
  if tokenList <> nil then
  begin
    Result := tokenList.Size;
  end;
end;

function TokenAt(tokenIndex: TTokenIndex): TToken;
begin
  // Result := TokenArrayPtr^[tokenIndex];
  Assert(TokenList <> nil, 'TokenList not yet created.');
  Result := TokenList.GetTokenAtIndex(tokenIndex);
end;

function NumIdent: Integer;
begin
  Result := NumIdent_;
end;

function IdentifierAt(identifierIndex: TIdentifierIndex): TIdentifier;
begin
  Assert(IdentifierList <> nil, 'IdentifierList not yet created.');
  Result := IdentifierList.GetIdentifierAtIndex(identifierIndex);
end;

end.
