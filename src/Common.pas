unit Common;

{$I Defines.inc}

interface

uses SysUtils, CommonTypes, Datatypes, FileIO, Memory, StringUtilities, Targets, Tokens;

// ----------------------------------------------------------------------------


// Passes
  {$SCOPEDENUMS ON}
type
  TPass = (NONE, CALL_DETERMINATION, CODE_GENERATION);


// Parameter passing
type
  TParameterPassingMethod = (
    UNDEFINED,
    VALPASSING,   // By value, modifiable
    CONSTPASSING, // By const, unodifiable
    VARPASSING    // By reference, modifiable
    );

const

  title = '1.7.2';


const

  // Identifier kind codes

  CONSTANT = TTokenKind.CONSTTOK;
  USERTYPE = TTokenKind.TYPETOK;
  VARIABLE = TTokenKind.VARTOK;
  //  PROC      = TTokenKind.PROCEDURETOK;
  //  FUNC      = TTokenKind.FUNCTIONTOK;
  LABELTYPE = TTokenKind.LABELTOK;
  UNITTYPE = TTokenKind.UNITTOK;

  ENUMTYPE = TTokenKind.ENUMTOK;

  // Compiler parameters

  MAXNAMELENGTH = 32;
  MAXTOKENNAMES = 200;
  MAXSTRLENGTH = 255;
  MAXFIELDS = 256;
  MAXTYPES = 1024;
  //  MAXTOKENS    = 32768;
  MAXPOSSTACK = 512;
  MAXIDENTS = 16384;
  MAXBLOCKS = 16384;  // Maximum number of blocks
  MAXPARAMS = 8;    // Maximum number of parameters for PROC, FUNC
  MAXVARS = 256;    // Maximum number of parameters for VAR
  MAXUNITS = 2048;
  MAXALLOWEDUNITS = 256;
  MAXDEFINES = 256;    // Max number of $DEFINEs

  CODEORIGIN = $100;
  DATAORIGIN = $8000;


  // Indirection levels

  ASVALUE = 0;
  ASPOINTER = 1;
  ASPOINTERTOPOINTER = 2;
  ASPOINTERTOARRAYORIGIN = 3;  // + GenerateIndexShift
  ASPOINTERTOARRAYORIGIN2 = 4;  // - GenerateIndexShift
  ASPOINTERTORECORD = 5;
  ASPOINTERTOARRAYRECORD = 6;
  ASSTRINGPOINTERTOARRAYORIGIN = 7;
  ASSTRINGPOINTER1TOARRAYORIGIN = 8;
  ASPOINTERTODEREFERENCE = 9;
  ASPOINTERTORECORDARRAYORIGIN = 10;
  ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN = 11;
  ASPOINTERTOARRAYRECORDTOSTRING = 12;

  ASCHAR = 6;  // GenerateWriteString
  ASBOOLEAN_ = 7;   // TODO Remove _, tempoary solution to prevent formatting
  ASREAL = 8;
  ASSHORTREAL = 9;
  ASHALFSINGLE = 10;
  ASSINGLE = 11;
  ASPCHAR = 12;

  fBlockRead_ParamType: array [1..3] of TTokenKind = (TTokenKind.UNTYPETOK, TTokenKind.WORDTOK, TTokenKind.POINTERTOK);


type

  // Here the prefixes are kept because otherwise the identifiers collide with the Pascal keywords.
  TModifierCode = (mInline, mStdCall, mPascal, mForward, mAssembler, mRegister, mInterrupt, mOverload, mKeep);
  TModifierBits = Word;

  TInterruptCode = (DLI, VBLD, VBLI, TIM1, TIM2, TIM4);

  TIOCode = (OpenRead, ReadRecord, Read, OpenWrite, Append, WriteRecord, Write, OpenReadWrite, FileMode, Close);
  TIOBits = Byte;

  TCode65 =
    (

    je, jne,
    //  jg, jge, jl, jle,
    putCHAR, putEOL,
    addBX, subBX, movaBX_Value,
    imulECX,
    //  notaBX, negaBX, notBOOLEAN,
    addAL_CL, addAX_CX, addEAX_ECX,
    shlAL_CL, shlAX_CL, shlEAX_CL,
    subAL_CL, subAX_CX, subEAX_ECX,
    cmpSTRING, cmpSTRING2CHAR, cmpCHAR2STRING,
    shrAL_CL, shrAX_CL, shrEAX_CL

    //  cmpINT, cmpEAX_ECX, cmpAX_CX, cmpSMALLINT, cmpSHORTINT,
    //  andEAX_ECX, andAX_CX, andAL_CL,
    //  orEAX_ECX, orAX_CX, orAL_CL,
    //  xorEAX_ECX, xorAX_CX xorAL_CL

    );

  TString = String;
  TName = String;


  TDefineIndex = TInteger; // 0 means not found
  TDefineParams = array [1..MAXPARAMS] of TString;

  TDefineName = TName;

  TDefine = record
    Name: TDefineName;
    Macro: String;
    Line: Integer;
    Param: TDefineParams;
  end;

  TParameterName = TName;

  TParam = record
    Name: TParameterName;
    DataType: TDataType;
    NumAllocElements: Cardinal;
    AllocElementType: TDataType;
    PassMethod: TParameterPassingMethod;
    i, i_: Integer;
  end;

  TParamList = array [1..MAXPARAMS] of TParam;


  TIdentifierName = String;

  TVariableList = array [1..MAXVARS] of TParam;
  TFieldName = TName;

  TFieldKind = (UNTYPETOK, OBJECTVARIABLE, RECORDVARIABLE);

  TField = record
    Name: TFieldName;
    Value: Int64;
    DataType: TDataType;
    NumAllocElements: Cardinal;
    AllocElementType: TDataType;
    Kind: TFieldKind;
  end;


  TType = record
    Block: Integer;
    NumFields: Integer;
    Size: Integer;
    Field: array [0..MAXFIELDS] of TField;
  end;

  TToken = record
    UnitIndex, Column: Smallint;
    Line: Integer;
    Kind: TTokenKind;
    // For Kind=IDENTTOK:
    Name: TIdentifierName;
    // For Kind=INTNUMBERTOK:
    Value: TInteger;
    // For Kind=FRACNUMBERTOK:
    FracValue: Single;
    // For Kind=STRINGLITERALTOK:
    StrAddress: Word;
    StrLength: Word;
  end;


  TIdentifier = record
    Name: TIdentifierName;
    Value: Int64;      // Value for a constant, address for a variable, procedure or function
    Block: Integer;      // Index of a block in which the identifier is defined
    UnitIndex: Integer;
    Alias: TString;      // EXTERNAL alias 'libraries'
    Libraries: Integer;    // EXTERNAL alias 'libraries'
    DataType: TDataType;
    IdType: TTokenKind; // TODO Have TIdenfierType
    PassMethod: TParameterPassingMethod;
    Pass: TPass;

    NestedNumAllocElements: Cardinal;
    NestedAllocElementType: TDataType;
    NestedDataType: TDataType;

    NestedFunctionNumAllocElements: Cardinal;
    NestedFunctionAllocElementType: TDataType;
    isNestedFunction: Boolean;

    LoopVariable,
    isAbsolute,
    isInit,
    isUntype,
    isInitialized,
    Section: Boolean;

    Kind: TTokenKind;

    //  For kind=PROCEDURETOK, FUNCTIONTOK:
    NumParams: Word;
    Param: TParamList;
    ProcAsBlock: Integer;
    ObjectIndex: Integer;

    IsUnresolvedForward,
    updateResolvedForward,
    isOverload,
    isRegister,
    isInterrupt,
    isRecursion,
    isStdCall,
    isPascal,
    isInline,
    isAsm,
    isExternal,
    isKeep,
    isVolatile,
    isStriped,
    IsNotDead: Boolean;

    //  For kind=VARIABLE, USERTYPE:
    NumAllocElements, NumAllocElements_: Cardinal;
    AllocElementType: TDataType
  end;


  TCallGraphNode = record
    ChildBlock: array [1..MAXBLOCKS] of Integer;
    NumChildren: Word;
  end;

  TUnitName = TName;

  TUnit = record
    Name: TUnitName;
    Path: String;
    Units: Integer;
    Allow: array [1..MAXALLOWEDUNITS] of TString;
  end;

  TResource = record
    resStream: Boolean;
    resName, resType, resFile: TString;
    resValue: Integer;
    resFullName: String;
    resPar: array [1..MAXPARAMS] of TString;
  end;

  TCaseLabel = record
    left, right: Int64;
    equality: Boolean;
  end;

  TPosStack = record
    ptr: Word;
    brk, cnt: Boolean;
  end;

  TForLoop = record
    begin_value, end_value: Int64;
    begin_const, end_const: Boolean;
  end;

  TCaseLabelArray = array of TCaseLabel;

var
  target: TTarget;


type
  TTokenIndex = Integer;
  TIdentIndex = Integer;
  TArrayIndex = Integer;

var

  PROGRAM_NAME: String = 'Program';
  LIBRARY_NAME: String;

  AsmBlock: array [0..4095] of String;

  Data, DataSegment, StaticStringData: TWordMemory;

  TypeArray: array [1..MAXTYPES] of TType;
  Tok: array of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;  // {$include ...} -> UnitName[MAXUNITS..]
  Defines: array [1..MAXDEFINES] of TDefine;
  IFTmpPosStack: array of Integer;
  BreakPosStack: array [0..MAXPOSSTACK] of TPosStack;
  CodePosStack: array [0..MAXPOSSTACK] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;  // For dead code elimination

  OldConstValType: TDataType;

  NumTok: Integer = 0;

  AddDefines: Integer = 1;
  NumDefines: Integer = 1;  // NumDefines = AddDefines

  i, NumIdent, NumTypes, NumPredefIdent, NumStaticStrChars, NumUnits, NumBlocks, run_func,
  NumProc, BlockStackTop, CodeSize, CodePosStackTop, BreakPosStackTop, VarDataSize,
  NumStaticStrCharsTmp, AsmBlockIndex, IfCnt, CaseCnt, IfdefLevel: Integer;

  ShrShlCnt: Integer; // Counter, used only for label generation

  pass: TPass;

  iOut: Integer = -1;

  CODEORIGIN_BASE: Integer = -1;

  DATA_BASE: Integer = -1;
  ZPAGE_BASE: Integer = -1;
  STACK_BASE: Integer = -1;

  UnitNameIndex: Integer = 1;

  FastMul: Integer = -1;

  OutFile: ITextFile;

  //AsmLabels: array of integer;

  resArray: array of TResource;

  FilePath, optyA, optyY, optyBP2, optyFOR0, optyFOR1, optyFOR2, optyFOR3, outTmp, outputFile: TString;

  msgWarning, msgNote, msgUser: TStringArray;
  OptimizeBuf, LinkObj: TStringArray;
  unitPathList: TPathList;


  optimize: record
    use: Boolean;
    unitIndex, line, old: Integer;
    end;

  codealign: record
    proc, loop, link: Integer;
    end;


  PROGRAMTOK_USE, INTERFACETOK_USE, LIBRARYTOK_USE, LIBRARY_USE, RCLIBRARY, OutputDisabled,
  isConst, isError, isInterrupt, IOCheck, Macros: Boolean;

  DataSegmentUse: Boolean = False;

  LoopUnroll: Boolean = False;

  PublicSection: Boolean = True;


{$IFDEF USEOPTFILE}

  OptFile: ITextFile;

{$ENDIF}

// ----------------------------------------------------------------------------

procedure AddDefine(const defineName: TDefineName);
function SearchDefine(const defineName: TDefineName): TDefineIndex;

procedure AddPath(folderPath: TFolderPath);

procedure CheckArrayIndex(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex; ArrayIndexType: TDataType);

procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex;
  ArrayIndexType: TDataType);

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: TTokenKind; DataType: TDataType;
  RightType: TDataType = TTokenKind.UNTYPETOK);

procedure CheckTok(i: TTokenIndex; ExpectedTokenCode: TTokenKind);

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);

procedure DefineFilename(StrTokenIndex: TTokenIndex; StrValue: String);

function FindFile(Name: String; ftyp: TString): String; overload;

function GetCommonConstType(ErrTokenIndex: TTokenIndex; DstType, SrcType: TDataType; err: Boolean = True): Boolean;

function GetCommonType(ErrTokenIndex: TTokenIndex; LeftType, RightType: TDataType): TDataType;

function GetEnumName(IdentIndex: TIdentIndex): TString;

function GetTokenSpellingAtIndex(i: TTokenIndex): String;

function GetVAL(a: String): Integer;

function LowBound(const i: TTokenIndex; const DataType: TDataType): TInteger;
function HighBound(const i: TTokenIndex; const DataType: TDataType): TInteger;

function InfoAboutToken(t: TTokenKind): String;

function IntToStr(const a: Int64): String;
function StrToInt(const a: String): TInteger;

procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);
function GetIOBits(const ioCode: TIOCode): TIOBits;

// ----------------------------------------------------------------------------

implementation

uses Messages, Utilities;


// ----------------------------------------------------------------------------
// Map modifier codes to the bits in the method status.
// ----------------------------------------------------------------------------

procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);
begin
  bits := bits or (Word(1) shl Ord(modifierCode));
end;

// ----------------------------------------------------------------------------
// Map I/O codes to the bits in the CIO block.
// ----------------------------------------------------------------------------

function GetIOBits(const ioCode: TIOCode): TIOBits;
begin
  case ioCode of
    TIOCode.OpenRead: Result := $04;
    TIOCode.ReadRecord: Result := $05;
    TIOCode.Read: Result := $07;
    TIOCode.OpenWrite: Result := $08;
    TIOCode.Append: Result := $09;
    TIOCode.WriteRecord: Result := $09;
    TIOCode.Write: Result := $0b;
    TIOCode.OpenReadWrite: Result := $0c;
    TIOCode.FileMode: Result := $f0;
    TIOCode.Close: Result := $ff;
    else
      Assert(False, 'Invalid ioCode.');
  end;
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function FindFile(Name: String; ftyp: TString): String; overload;
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


function StrToInt(const a: String): TInteger;
  (*----------------------------------------------------------------------------*)
  (*----------------------------------------------------------------------------*)
{$IFNDEF PAS2JS}
var
  i: Integer; // ##NEEDED
begin
  val(a, Result, i);
end;

{$ELSE}
// This code below should work the same in FPC, but this needs to be tested first.
var value: integer;
var i: integer;
begin
 val(a,value, i);
 Result := value;
end;
{$ENDIF}
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function IntToStr(const a: Int64): String;
  (*----------------------------------------------------------------------------*)
  (*----------------------------------------------------------------------------*)
begin
  str(a, Result);
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetTokenSpellingAtIndex(i: TTokenIndex): TString;
var
  kind: TTokenKind;
begin
  if i > NumTok then
    Result := 'no token'
  else
  begin
    kind := Tok[i].Kind;
    GetHumanReadbleTokenSpelling(kind);
  end;
end;


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


// TODO: Move to Tokens units
function InfoAboutToken(t: TTokenKind): String;
begin

  case t of

    TTokenKind.EQTOK: Result := '=';
    TTokenKind.NETOK: Result := '<>';
    TTokenKind.LTTOK: Result := '<';
    TTokenKind.LETOK: Result := '<=';
    TTokenKind.GTTOK: Result := '>';
    TTokenKind.GETOK: Result := '>=';

    TTokenKind.INTOK: Result := 'IN';

    TTokenKind.DOTTOK: Result := '.';
    TTokenKind.COMMATOK: Result := ',';
    TTokenKind.SEMICOLONTOK: Result := ';';
    TTokenKind.OPARTOK: Result := '(';
    TTokenKind.CPARTOK: Result := ')';
    TTokenKind.DEREFERENCETOK: Result := '^';
    TTokenKind.ADDRESSTOK: Result := '@';
    TTokenKind.OBRACKETTOK: Result := '[';
    TTokenKind.CBRACKETTOK: Result := ']';
    TTokenKind.COLONTOK: Result := ':';
    TTokenKind.PLUSTOK: Result := '+';
    TTokenKind.MINUSTOK: Result := '-';
    TTokenKind.MULTOK: Result := '*';
    TTokenKind.DIVTOK: Result := '/';

    TTokenKind.IDIVTOK: Result := 'DIV';
    TTokenKind.MODTOK: Result := 'MOD';
    TTokenKind.SHLTOK: Result := 'SHL';
    TTokenKind.SHRTOK: Result := 'SHR';
    TTokenKind.ORTOK: Result := 'OR';
    TTokenKind.XORTOK: Result := 'XOR';
    TTokenKind.ANDTOK: Result := 'AND';
    TTokenKind.NOTTOK: Result := 'NOT';
    TTokenKind.CONSTTOK: Result := 'CONST';
    TTokenKind.TYPETOK: Result := 'TYPE';
    TTokenKind.VARTOK: Result := 'VARIABLE';
    TTokenKind.PROCEDURETOK: Result := 'PROCEDURE';
    TTokenKind.FUNCTIONTOK: Result := 'FUNCTION';
    TTokenKind.CONSTRUCTORTOK: Result := 'CONSTRUCTOR';
    TTokenKind.DESTRUCTORTOK: Result := 'DESTRUCTOR';

    TTokenKind.LABELTOK: Result := 'LABEL';
    TTokenKind.UNITTOK: Result := 'UNIT';
    TTokenKind.ENUMTOK: Result := 'ENUM';

    TTokenKind.RECORDTOK: Result := 'RECORD';
    TTokenKind.OBJECTTOK: Result := 'OBJECT';
    TTokenKind.BYTETOK: Result := 'BYTE';
    TTokenKind.SHORTINTTOK: Result := 'SHORTINT';
    TTokenKind.CHARTOK: Result := 'CHAR';
    TTokenKind.BOOLEANTOK: Result := 'BOOLEAN';
    TTokenKind.WORDTOK: Result := 'WORD';
    TTokenKind.SMALLINTTOK: Result := 'SMALLINT';
    TTokenKind.CARDINALTOK: Result := 'CARDINAL';
    TTokenKind.INTEGERTOK: Result := 'INTEGER';
    TTokenKind.POINTERTOK,
    TTokenKind.DATAORIGINOFFSET,
    TTokenKind.CODEORIGINOFFSET: Result := 'POINTER';

    TTokenKind.PROCVARTOK: Result := '<Procedure Variable>';

    TTokenKind.STRINGPOINTERTOK: Result := 'STRING';

    TTokenKind.STRINGLITERALTOK: Result := 'literal';

    TTokenKind.SHORTREALTOK: Result := 'SHORTREAL';
    TTokenKind.REALTOK: Result := 'REAL';
    TTokenKind.SINGLETOK: Result := 'SINGLE';
    TTokenKind.HALFSINGLETOK: Result := 'FLOAT16';
    TTokenKind.SETTOK: Result := 'SET';
    TTokenKind.FILETOK: Result := 'FILE';
    TTokenKind.TEXTFILETOK: Result := 'TEXTFILE';
    TTokenKind.PCHARTOK: Result := 'PCHAR';

    TTokenKind.REGISTERTOK: Result := 'REGISTER';
    TTokenKind.PASCALTOK: Result := 'PASCAL';
    TTokenKind.STDCALLTOK: Result := 'STDCALL';
    TTokenKind.INLINETOK: Result := 'INLINE';
    TTokenKind.ASMTOK: Result := 'ASM';
    TTokenKind.INTERRUPTTOK: Result := 'INTERRUPT';

    else
      Result := 'UNTYPED'
  end;

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
  found, expected: String;
begin

  if Tok[i].Kind <> ExpectedTokenCode then
  begin

    found := GetTokenSpellingAtIndex(i);
    expected := GetHumanReadbleTokenSpelling(ExpectedTokenCode);

    Error(i, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error, ' + '''' + expected +
      '''' + ' expected but ''' + found + ''' found.'));

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


end.
