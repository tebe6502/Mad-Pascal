unit Common;

{$I Defines.inc}

interface

uses Classes, SysUtils, CommonTypes, CompilerTypes, Datatypes, FileIO, Memory, StringUtilities, Targets, Tokens;

const
  title = '1.7.2';


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

  Data, DataSegment, StaticStringData: TWordMemory;

  AddDefines: Integer = 1;
  NumDefines: Integer = 1;  // NumDefines = AddDefines
  Defines: array [1..MAXDEFINES] of TDefine;

  NumTypes: Integer;
  TypeArray: array [1..MAXTYPES] of TType;

  TokenList: TTokenList;
  Tok: TTokenList.TTokenArray;

  NumIdent: Integer;
  Ident: array [1..MAXIDENTS] of TIdentifier;

  UnitList: TSourceFileList;


  IFTmpPosStack: array of Integer;

  BreakPosStackTop: Integer;
  BreakPosStack: array [0..MAXPOSSTACK] of TPosStack;

  CodePosStackTop: Integer;
  CodePosStack: array [0..MAXPOSSTACK] of Word;

  BlockStackTop: Integer;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;

  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;  // For dead code elimination

  OldConstValType: TDataType;

  i, NumPredefIdent, NumStaticStrChars, NumBlocks, run_func, NumProc, CodeSize, VarDataSize,
  NumStaticStrCharsTmp, IfCnt, CaseCnt, IfdefLevel: Integer;

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

  // Optimizer Settings
  iOut: Integer;
  outTmp: TString;
  OptimizeBuf: TStringArray;

  optimize: record
    use: Boolean;
    SourceFile: TSourceFile;
    line, old: Integer;
    end;

  codealign: record
    proc, loop, link: Integer;
    end;


  PROGRAMTOK_USE, INTERFACETOK_USE, LIBRARYTOK_USE, LIBRARY_USE, RCLIBRARY, OutputDisabled,
  isConst, isError, isInterrupt, IOCheck, Macros: Boolean;

  DataSegmentUse: Boolean; // Initialized in Scanner.TokenizeProgramInitialization

  LoopUnroll: Boolean;
  // Initialized in Scanner.TokenizeProgramInitialization, updated with {$OPTIMIZATION LOOPUNROLL|NOLOOPUNROLL }

  PublicSection: Boolean;  // Initialized in Scanner.TokenizeProgramInitialization
{$IFDEF USEOPTFILE}

  OptFile: ITextFile;

{$ENDIF}

// ----------------------------------------------------------------------------
function NumUnits: Integer;
function NumTok: Integer;

procedure AddDefine(const defineName: TDefineName);
function SearchDefine(const defineName: TDefineName): TDefineIndex;

procedure AddPath(folderPath: TFolderPath);
function GetSourceFile(const UnitIndex: TSourceFileIndex): TSourceFile;

procedure CheckArrayIndex(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex; ArrayIndexType: TDataType);

procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex;
  ArrayIndexType: TDataType);

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: TTokenKind; DataType: TDataType;
  RightType: TDataType = TTokenKind.UNTYPETOK);

procedure CheckTok(i: TTokenIndex; ExpectedTokenCode: TTokenKind);

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);

procedure DefineFilename(StrTokenIndex: TTokenIndex; StrValue: String);

function FindFile(Name: String; ftyp: TString): TFilePath; overload;

function GetCommonConstType(ErrTokenIndex: TTokenIndex; DstType, SrcType: TDataType; err: Boolean = True): Boolean;

function GetCommonType(ErrTokenIndex: TTokenIndex; LeftType, RightType: TDataType): TDataType;

function GetEnumName(IdentIndex: TIdentIndex): TString;


function GetVAL(a: String): Integer;

function LowBound(const i: TTokenIndex; const DataType: TDataType): TInteger;
function HighBound(const i: TTokenIndex; const DataType: TDataType): TInteger;

// ----------------------------------------------------------------------------

implementation

uses Messages, Utilities;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function FindFile(Name: String; ftyp: TString): TFilePath; overload;
var
  msg: IMessage;
begin
  Result := unitPathList.FindFile(Name);
  if Result = '' then
  begin
    if ftyp = 'unit' then
    begin
      msg := TMessage.Create(TErrorCode.FileNotFound,
        'Can''t find unit ''{0}'' used by program ''{1}'' in unit path ''{2}''.',
        ChangeFileExt(Name, ''), PROGRAM_NAME, unitPathList.ToString);

    end
    else
    begin
      msg := TMessage.Create(TErrorCode.FileNotFound,
        'Can''t find {0} ''{1}'' used by program ''{2}'' in unit path ''{3}''.', ftyp,
        Name, PROGRAM_NAME, unitPathList.ToString);
    end;
    Error(NumTok, msg);
  end;
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
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


procedure AddPath(folderPath: TFolderPath);
begin
  unitPathList.AddFolder(folderPath);
end;

function GetSourceFile(const UnitIndex: TSourceFileIndex): TSourceFile;
begin
  Result := UnitList.GetSourceFile(UnitIndex);
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetEnumName(IdentIndex: Integer): TString;
var
  IdentTtemp: Integer;


  function Search(Num: Cardinal): Integer;
  var
    IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    // Search all nesting levels from the current one to the most outer one
    for BlockStackIndex := BlockStackTop downto 0 do
      for IdentIndex := 1 to NumIdent do
        if (Ident[IdentIndex].DataType = ENUMTYPE) and (Ident[IdentIndex].NumAllocElements = Num) and
          (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
          exit(IdentIndex);
  end;

begin

  Result := '';

  if Ident[IdentIndex].NumAllocElements > 0 then
  begin
    IdentTtemp := Search(Ident[IdentIndex].NumAllocElements);

    if IdentTtemp > 0 then
      Result := Ident[IdentTtemp].Name;
  end
  else
    if Ident[IdentIndex].DataType = ENUMTYPE then
    begin
      IdentTtemp := Search(Ident[IdentIndex].NumAllocElements);

      if IdentTtemp > 0 then
        Result := Ident[IdentTtemp].Name;
    end;

end;  //GetEnumName

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: TTokenKind; DataType: TDataType;
  RightType: TDataType = TTokenKind.UNTYPETOK);
begin

  //writeln(tok[ErrTokenIndex].Name,',', op,',',DataType);

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
    or ((DataType = TTokenKind.CHARTOK) and not (op in [TTokenKind.GTTOK, TTokenKind.GETOK,
    TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK, TTokenKind.INTOK]))
    // Operators for Boolean
    or ((DataType = TTokenKind.BOOLEANTOK) and not (op in [TTokenKind.ANDTOK, TTokenKind.ORTOK,
    TTokenKind.XORTOK, TTokenKind.NOTTOK, TTokenKind.GTTOK, TTokenKind.GETOK, TTokenKind.EQTOK,
    TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK]))
    // Operators for Pointers
    or ((DataType in Pointers) and not (op in [TTokenKind.GTTOK, TTokenKind.GETOK,
    TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK, TTokenKind.PLUSTOK,
    TTokenKind.MINUSTOK])) then
  begin
    if DataType = RightType then
      Error(ErrTokenIndex, TMessage.Create(TErrorCode.OperatorNotOverloaded, 'Operator is not overloaded: ' +
        '"' + InfoAboutToken(DataType) + '" ' + InfoAboutToken(op) + ' "' + InfoAboutToken(RightType) + '"'))
    else
      Error(ErrTokenIndex, TMessage.Create(TErrorCode.OperationNotSupportedForTypes,
        'Operation "' + InfoAboutToken(op) + '" not supported for types "' + InfoAboutToken(DataType) +
        '" and "' + InfoAboutToken(RightType) + '"'));
  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex(i: TTokenIndex; IdentIndex: Integer; ArrayIndex: TArrayIndex; ArrayIndexType: TDataType);
begin

  if (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> TTokenKind.RECORDTOK) then
    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements - 1 +
      Ord(Ident[IdentIndex].DataType = TTokenKind.STRINGPOINTERTOK)) then
      if Ident[IdentIndex].NumAllocElements <> 1 then WarningForRangeCheckError(i, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TArrayIndex;
  ArrayIndexType: TDataType);
begin

  if Ident[IdentIndex].NumAllocElements_ > 0 then
    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements_ - 1 +
      Ord(Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK)) then
      if Ident[IdentIndex].NumAllocElements_ <> 1 then
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
    TDataType.CARDINALTOK: Result := High(Cardinal);
    TDataType.STRINGTOK: Result := 255;

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


procedure CheckTok(i: TTokenIndex; ExpectedTokenCode: TTokenKind);
var
  Token: TToken;
  found, expected: String;
begin

  Token := Tok[i];
  if Token.Kind <> ExpectedTokenCode then
  begin

    found := token.GetSpelling;
    expected := GetHumanReadbleTokenSpelling(ExpectedTokenCode);

    Error(i, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error, ' + '''' + expected +
      '''' + ' expected but ''' + found + ''' found.'));

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// TOO Move core to TDataType
function GetCommonConstType(ErrTokenIndex: TTokenIndex; DstType, SrcType: TDataType; err: Boolean = True): Boolean;
begin

  Result := False;

  if (GetDataSize(DstType) < GetDataSize(SrcType))
    // .
    or ((DstType = TDataType.REALTOK) and (SrcType <> TDataType.REALTOK))
    // .
    or ((DstType <> TDataType.REALTOK) and (SrcType = TDataType.REALTOK))
    // .
    or ((DstType = TDataType.SINGLETOK) and (SrcType <> TDataType.SINGLETOK))
    // .
    or ((DstType <> TDataType.SINGLETOK) and (SrcType = TDataType.SINGLETOK))
    // .
    or ((DstType = TDataType.HALFSINGLETOK) and (SrcType <> TDataType.HALFSINGLETOK))
    // .
    or ((DstType <> TDataType.HALFSINGLETOK) and (SrcType = TDataType.HALFSINGLETOK))
    // .
    or ((DstType = TDataType.SHORTREALTOK) and (SrcType <> TDataType.SHORTREALTOK))
    // .
    or ((DstType <> TDataType.SHORTREALTOK) and (SrcType = TDataType.SHORTREALTOK))
    // .
    or ((DstType in IntegerTypes) and (SrcType in [TDataType.CHARTOK, TDataType.BOOLEANTOK,
    TDataType.POINTERTOK, TDataType.DATAORIGINOFFSET, TDataType.CODEORIGINOFFSET, TDataType.STRINGPOINTERTOK]))
    // .
    or ((SrcType in IntegerTypes) and (DstType in [TDataType.CHARTOK, TDataType.BOOLEANTOK])) then

    if err then
      ErrorIncompatibleTypes(ErrTokenIndex, SrcType, DstType)
    else
      Result := True;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


// TOO Move core to TDataType
function GetCommonType(ErrTokenIndex: TTokenIndex; LeftType, RightType: TDataType): TDataType;
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
    ErrorIncompatibleTypes(ErrTokenIndex, RightType, LeftType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure DefineFilename(StrTokenIndex: TTokenIndex; StrValue: String);
var
  i: Integer;
begin

  for i := 0 to High(linkObj) - 1 do
    if linkObj[i] = StrValue then
    begin
      Tok[StrTokenIndex].Value := i;
      exit;
    end;

  i := High(linkObj);
  linkObj[i] := StrValue;

  SetLength(linkObj, i + 2);

  Tok[StrTokenIndex].Value := i;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);
var
  i, len: Integer;
begin

  len := Length(StrValue);

  if len > 255 then
    Data[0] := 255
  else
    Data[0] := len;

  if (NumStaticStrChars + len > $FFFF) then
  begin
    writeln('DefineStaticString: ' + IntToStr(len));
    RaiseHaltException(THaltException.COMPILING_ABORTED);
  end;

  for i := 1 to len do Data[i] := Ord(StrValue[i]);

  for i := 0 to NumStaticStrChars - len - 1 do
    if CompareWord(Data[0], StaticStringData[i], Len + 1) = 0 then
    begin

      Tok[StrTokenIndex].StrLength := len;
      Tok[StrTokenIndex].StrAddress := CODEORIGIN + i;

      exit;
    end;

  Tok[StrTokenIndex].StrLength := len;
  Tok[StrTokenIndex].StrAddress := CODEORIGIN + NumStaticStrChars;

  StaticStringData[NumStaticStrChars] := Data[0];//length(StrValue);
  Inc(NumStaticStrChars);

  for i := 1 to len do
  begin
    StaticStringData[NumStaticStrChars] := Ord(StrValue[i]);
    Inc(NumStaticStrChars);
  end;

  //StaticStringData[NumStaticStrChars] := 0;
  //Inc(NumStaticStrChars);

end;

// The function is currently kept for compatibility, simulating the previous global variable.
function NumUnits: Integer;
begin
  if unitList <> nil then
  begin
    Result := UnitList.Size;
  end;
end;

// The function is currently kept for compatibility, simulating the previous global variable.
function NumTok: Integer;
begin
  if tokenList <> nil then
  begin
    Result := tokenList.Size;
  end;
end;

end.
