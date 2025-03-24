unit Common;

{$I Defines.inc}

interface

uses SysUtils, CommonTypes, FileIO, StringUtilities;

// ----------------------------------------------------------------------------


// Passes
  {$SCOPEDENUMS ON}
type
  TPass = (NONE, CALL_DETERMINATION, CODE_GENERATION);


// Parameter passing
type
  TParameterPassingMethod = (
    UNDEFINED,
    VALPASSING, // By value, modifiable
    CONSTPASSING , // By const, unodifiable
    VARPASSING // By reference, modifiable
    );

const

  title = '1.7.2';

type TTokenKind = (
  UNTYPETOK,

  CONSTTOK		= 1,     // !!! Don't change
  TYPETOK		= 2,     // !!!
  VARTOK		= 3,     // !!!
  PROCEDURETOK		= 4,     // !!!
  FUNCTIONTOK		= 5,     // !!!
  LABELTOK		= 6,	 // !!!
  UNITTOK		= 7,	 // !!!


  GETINTVECTOK		= 10,
  SETINTVECTOK		= 11,
  CASETOK		= 12,
  BEGINTOK		= 13,
  ENDTOK		= 14,
  IFTOK			= 15,
  THENTOK		= 16,
  ELSETOK		= 17,
  WHILETOK		= 18,
  DOTOK			= 19,
  REPEATTOK		= 20,
  UNTILTOK		= 21,
  FORTOK		= 22,
  TOTOK			= 23,
  DOWNTOTOK		= 24,
  ASSIGNTOK		= 25,
  WRITETOK		= 26,
  READLNTOK		= 27,
  HALTTOK		= 28,
  USESTOK		= 29,
  ARRAYTOK		= 30,
  OFTOK			= 31,
  STRINGTOK		= 32,
  INCTOK		= 33,
  DECTOK		= 34,
  ORDTOK		= 35,
  CHRTOK		= 36,
  ASMTOK		= 37,
  ABSOLUTETOK		= 38,
  BREAKTOK		= 39,
  CONTINUETOK		= 40,
  EXITTOK		= 41,
  RANGETOK		= 42,

  EQTOK			= 43,
  NETOK			= 44,
  LTTOK			= 45,
  LETOK			= 46,
  GTTOK			= 47,
  GETOK			= 48,
  LOTOK			= 49,
  HITOK			= 50,

  DOTTOK		= 51,
  COMMATOK		= 52,
  SEMICOLONTOK		= 53,
  OPARTOK		= 54,
  CPARTOK		= 55,
  DEREFERENCETOK	= 56,
  ADDRESSTOK		= 57,
  OBRACKETTOK		= 58,
  CBRACKETTOK		= 59,
  COLONTOK		= 60,

  PLUSTOK		= 61,
  MINUSTOK		= 62,
  MULTOK		= 63,
  DIVTOK		= 64,
  IDIVTOK		= 65,
  MODTOK		= 66,
  SHLTOK		= 67,
  SHRTOK		= 68,
  ORTOK			= 69,
  XORTOK		= 70,
  ANDTOK		= 71,
  NOTTOK		= 72,

  ASSIGNFILETOK		= 73,
  RESETTOK		= 74,
  REWRITETOK		= 75,
  APPENDTOK		= 76,
  BLOCKREADTOK		= 77,
  BLOCKWRITETOK		= 78,
  CLOSEFILETOK		= 79,
  GETRESOURCEHANDLETOK	= 80,
  SIZEOFRESOURCETOK     = 81,

  WRITELNTOK		= 82,
  SIZEOFTOK		= 83,
  LENGTHTOK		= 84,
  HIGHTOK		= 85,
  LOWTOK		= 86,
  INTTOK		= 87,
  FRACTOK		= 88,
  TRUNCTOK		= 89,
  ROUNDTOK		= 90,
  ODDTOK		= 91,

  PROGRAMTOK		= 92,
  LIBRARYTOK		= 93,
  EXPORTSTOK		= 94,
  EXTERNALTOK		= 95,
  INTERFACETOK		= 96,
  IMPLEMENTATIONTOK     = 97,
  INITIALIZATIONTOK     = 98,
  CONSTRUCTORTOK	= 99,
  DESTRUCTORTOK		= 100,
  OVERLOADTOK		= 101,
  ASSEMBLERTOK		= 102,
  FORWARDTOK		= 103,
  REGISTERTOK		= 104,
  INTERRUPTTOK		= 105,
  PASCALTOK		= 106,
  STDCALLTOK		= 107,
  INLINETOK		= 108,
  KEEPTOK		= 109,

  SUCCTOK		= 110,
  PREDTOK		= 111,
  PACKEDTOK		= 112,
  GOTOTOK		= 113,
  INTOK			= 114,
  VOLATILETOK		= 115,
  STRIPEDTOK		= 116,


  SETTOK		= 127,	// Size = 32 SET OF

  BYTETOK		= 128,	// Size = 1 BYTE
  WORDTOK		= 129,	// Size = 2 WORD
  CARDINALTOK		= 130,	// Size = 4 CARDINAL
  SHORTINTTOK		= 131,	// Size = 1 SHORTINT
  SMALLINTTOK		= 132,	// Size = 2 SMALLINT
  INTEGERTOK		= 133,	// Size = 4 INTEGER
  CHARTOK		= 134,	// Size = 1 CHAR
  BOOLEANTOK		= 135,	// Size = 1 BOOLEAN
  POINTERTOK		= 136,	// Size = 2 POINTER
  STRINGPOINTERTOK	= 137,	// Size = 2 POINTER to STRING
  FILETOK		= 138,	// Size = 2/12 FILE
  RECORDTOK		= 139,	// Size = 2/???
  OBJECTTOK		= 140,	// Size = 2/???
  SHORTREALTOK		= 141,	// Size = 2 SHORTREAL			Fixed-Point Q8.8
  REALTOK		= 142,	// Size = 4 REAL			Fixed-Point Q24.8
  SINGLETOK		= 143,	// Size = 4 SINGLE / FLOAT		IEEE-754 32-bit
  HALFSINGLETOK		= 144,	// Size = 2 HALFSINGLE / FLOAT16	IEEE-754 16-bit
  PCHARTOK		= 145,	// Size = 2 POINTER TO ARRAY OF CHAR
  ENUMTOK		= 146,	// Size = 1 BYTE
  PROCVARTOK		= 147,	// Size = 2
  TEXTFILETOK		= 148,	// Size = 2/12 TEXTFILE
  FORWARDTYPE		= 149,	// Size = 2

  SHORTSTRINGTOK	= 150,	// We change into STRINGTOK
  FLOATTOK		= 151,	// We change into SINGLETOK
  FLOAT16TOK		= 152,	// We change into HALFSINGLETOK
  TEXTTOK		= 153,	// We change into TEXTFILETOK

  DEREFERENCEARRAYTOK	= 154,	// For ARRAY pointers


  DATAORIGINOFFSET	= 160,
  CODEORIGINOFFSET	= 161,

  IDENTTOK		= 170,
  INTNUMBERTOK		= 171,
  FRACNUMBERTOK		= 172,
  CHARLITERALTOK	= 173,
  STRINGLITERALTOK	= 174,

  EVALTOK		= 184,
  LOOPUNROLLTOK		= 185,
  NOLOOPUNROLLTOK	= 186,
  LINKTOK		= 187,
  MACRORELEASE		= 188,
  PROCALIGNTOK		= 189,
  LOOPALIGNTOK		= 190,
  LINKALIGNTOK		= 191,
  INFOTOK		= 192,
  WARNINGTOK		= 193,
  ERRORTOK		= 194,
  UNITBEGINTOK		= 195,
  UNITENDTOK		= 196,
  IOCHECKON		= 197,
  IOCHECKOFF		= 198,
  EOFTOK		= 199     // MAXTOKENNAMES = 200
);

const
  UnsignedOrdinalTypes	= [TTokenKind.BYTETOK, TTokenKind.WORDTOK, TTokenKind.CARDINALTOK];
  SignedOrdinalTypes	= [TTokenKind.SHORTINTTOK, TTokenKind.SMALLINTTOK, TTokenKind.INTEGERTOK];
  RealTypes		= [TTokenKind.SHORTREALTOK, TTokenKind.REALTOK, TTokenKind.SINGLETOK, TTokenKind.HALFSINGLETOK];

  IntegerTypes		= UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes		= IntegerTypes + [TTokenKind.CHARTOK, TTokenKind.BOOLEANTOK, TTokenKind.ENUMTOK];

  Pointers		= [TTokenKind.POINTERTOK, TTokenKind.PROCVARTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.PCHARTOK];

  AllTypes		= OrdinalTypes + RealTypes + Pointers;

  StringTypes		= [TTokenKind.STRINGPOINTERTOK, TTokenKind.STRINGLITERALTOK, TTokenKind.PCHARTOK];

  // Identifier kind codes

  CONSTANT		= TTokenKind.CONSTTOK;
  USERTYPE		= TTokenKind.TYPETOK;
  VARIABLE		= TTokenKind.VARTOK;
//  PROC			= TTokenKind.PROCEDURETOK;
//  FUNC			= TTokenKind.FUNCTIONTOK;
  LABELTYPE		= TTokenKind.LABELTOK;
  UNITTYPE		= TTokenKind.UNITTOK;

  ENUMTYPE		= TTokenKind.ENUMTOK;

  // Compiler parameters

  MAXNAMELENGTH		= 32;
  MAXTOKENNAMES		= 200;
  MAXSTRLENGTH		= 255;
  MAXFIELDS		= 256;
  MAXTYPES		= 1024;
//  MAXTOKENS		= 32768;
  MAXPOSSTACK		= 512;
  MAXIDENTS		= 16384;
  MAXBLOCKS		= 16384;	// Maximum number of blocks
  MAXPARAMS		= 8;		// Maximum number of parameters for PROC, FUNC
  MAXVARS		= 256;		// Maximum number of parameters for VAR
  MAXUNITS		= 2048;
  MAXALLOWEDUNITS	= 256;
  MAXDEFINES		= 256;		// Max number of $DEFINEs

  CODEORIGIN		= $100;
  DATAORIGIN		= $8000;


  // Indirection levels

  ASVALUE			= 0;
  ASPOINTER			= 1;
  ASPOINTERTOPOINTER		= 2;
  ASPOINTERTOARRAYORIGIN	= 3;	// + GenerateIndexShift
  ASPOINTERTOARRAYORIGIN2	= 4;	// - GenerateIndexShift
  ASPOINTERTORECORD		= 5;
  ASPOINTERTOARRAYRECORD	= 6;
  ASSTRINGPOINTERTOARRAYORIGIN	= 7;
  ASSTRINGPOINTER1TOARRAYORIGIN	= 8;
  ASPOINTERTODEREFERENCE	= 9;
  ASPOINTERTORECORDARRAYORIGIN	= 10;
  ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN = 11;
  ASPOINTERTOARRAYRECORDTOSTRING= 12;

  ASCHAR		= 6;	// GenerateWriteString
  ASBOOLEAN		= 7;
  ASREAL		= 8;
  ASSHORTREAL		= 9;
  ASHALFSINGLE		= 10;
  ASSINGLE		= 11;
  ASPCHAR		= 12;


  // Data sizes

  _DataSize: array [Ord(TTokenKind.BYTETOK)..Ord(TTokenKind.FORWARDTYPE)] of Byte = (
  	1,	// Size = 1 BYTE
  	2,	// Size = 2 WORD
  	4,	// Size = 4 CARDINAL
	1,	// Size = 1 SHORTINT
	2,	// Size = 2 SMALLINT
	4,	// Size = 4 INTEGER
	1,	// Size = 1 CHAR
	1,	// Size = 1 BOOLEAN
	2,	// Size = 2 POINTER
	2,	// Size = 2 POINTER to STRING
	2,	// Size = 2 FILE
	2,	// Size = 2 RECORD
	2,	// Size = 2 OBJECT
	2,	// Size = 2 SHORTREAL
	4,	// Size = 4 REAL
	4,	// Size = 4 SINGLE / FLOAT
	2,	// Size = 2 HALFSINGLE / FLOAT16
	2,	// Size = 2 PCHAR
	1,	// Size = 1 BYTE
	2,	// Size = 2 PROCVAR
	2,	// Size = 2 TEXTFILE
	2	// Size = 2 FORWARD
	);

  fBlockRead_ParamType: array [1..3] of TTokenKind = (TTokenKind.UNTYPETOK, TTokenKind.WORDTOK, TTokenKind.POINTERTOK);


{$i targets/type.inc}


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
  TDataType = TTokenKind;

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
  TIntegerNumber = Int64;

  TVariableList = array [1..MAXVARS] of TParam;
  TFieldName = TName;

  TFieldKind = ( UNTYPETOK,   OBJECTVARIABLE	= 1,
  RECORDVARIABLE	= 2);

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
    Value: TIntegerNumber;
    // For Kind=FRACNUMBERTOK:
    FracValue: Single;
    // For Kind=STRINGLITERALTOK:
    StrAddress: Word;
    StrLength: Word;
    end;


  TIdentifier = record
    Name: TIdentifierName;
    Value: Int64;			// Value for a constant, address for a variable, procedure or function
    Block: Integer;			// Index of a block in which the identifier is defined
    UnitIndex : Integer;
    Alias : TString;			// EXTERNAL alias 'libraries'
    Libraries : Integer;		// EXTERNAL alias 'libraries'
    DataType: TDataType;
    IdType: TTokenKind; // TODO Have TIdentierType
    PassMethod: TParameterPassingMethod;
    Pass: TPass;

    NestedNumAllocElements: Cardinal;
    NestedAllocElementType: Byte;
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


{$i targets/var.inc}

const
  MIN_MEMORY_ADDRESS = $0000;
  
const
  MAX_MEMORY_ADDRESS = $FFFF;

type
  TWordMemory = array [MIN_MEMORY_ADDRESS..MAX_MEMORY_ADDRESS] of Word;
  
type
  TTokenIndex = Integer;
  TIdentIndex = Integer;
  TArrayIndex = Integer;

  type TTokenSpelling = record
      tokenCode: TTokenKind;
      spelling: String;
  end;

var

  PROGRAM_NAME: String = 'Program';
  LIBRARY_NAME: String;

  AsmBlock: array [0..4095] of String;

  Data, DataSegment, StaticStringData: TWordMemory;

  TypeArray: array [1..MAXTYPES] of TType;
  Tok: array of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  TokenSpelling: array [1..MAXTOKENNAMES] of TTokenSpelling;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;	// {$include ...} -> UnitName[MAXUNITS..]
  Defines: array [1..MAXDEFINES] of TDefine;
  IFTmpPosStack: array of Integer;
  BreakPosStack: array [0..MAXPOSSTACK] of TPosStack;
  CodePosStack: array [0..MAXPOSSTACK] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;	// For dead code elimination

  OldConstValType: TDataType;

  NumTok: Integer = 0;

  AddDefines: Integer = 1;
  NumDefines: Integer = 1;  // NumDefines = AddDefines

  i, NumIdent, NumTypes, NumPredefIdent, NumStaticStrChars, NumUnits, NumBlocks, run_func,
  NumProc, BlockStackTop, CodeSize, CodePosStackTop, BreakPosStackTop, VarDataSize, ShrShlCnt,
  NumStaticStrCharsTmp, AsmBlockIndex, IfCnt, CaseCnt, IfdefLevel: Integer;
  pass: TPass;

  iOut: Integer = -1;

  start_time: QWord;

  CODEORIGIN_BASE: Integer = -1;

  DATA_BASE: Integer = -1;
  ZPAGE_BASE: Integer = -1;
  STACK_BASE: Integer = -1;

  UnitNameIndex: Integer = 1;

  FastMul: Integer = -1;

  OutFile: ITextFile;

  //AsmLabels: array of integer;

  resArray: array of TResource;

  MainPath, FilePath, optyA, optyY, optyBP2, optyFOR0, optyFOR1, optyFOR2, optyFOR3, outTmp, outputFile: TString;

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

  DiagMode: Boolean = False;
  DataSegmentUse: Boolean = False;

  LoopUnroll: Boolean = False;

  PublicSection: Boolean = True;


{$IFDEF USEOPTFILE}

  OptFile: ITextFile;

{$ENDIF}

// ----------------------------------------------------------------------------

procedure ClearWordMemory(anArray: TWordMemory);

function GetDataSize(datatype: TDataType): Byte;

procedure AddDefine(const defineName: TDefineName);
function SearchDefine(const defineName: TDefineName): TDefineIndex;

procedure AddPath(s: String);

procedure CheckArrayIndex(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex; ArrayIndexType: TDataType);

procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TIdentIndex; ArrayIndexType: TDataType);

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: TTokenKind; DataType: TDataType; RightType: TDataType = TTokenKind.UNTYPETOK);

procedure CheckTok(i: TTokenIndex; ExpectedTokenCode: TTokenKind);

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);

procedure DefineFilename(StrTokenIndex: TTokenIndex; StrValue: String);

function FindFile(Name: String; ftyp: TString): String; overload;

procedure FreeTokens;

function GetCommonConstType(ErrTokenIndex: TTokenIndex; DstType, SrcType: TDataType; err: Boolean = True): Boolean;

function GetCommonType(ErrTokenIndex: TTokenIndex; LeftType, RightType: TDataType): TDataType;

function GetEnumName(IdentIndex: TIdentIndex): TString;

function GetTokenSpelling(t: TTokenKind): TString;
function GetSpelling(i: TTokenIndex): TString;


function GetVAL(a: String): Integer;

function GetValueType(Value: TIntegerNumber): TDataType;

function LowBound(const i: TTokenIndex; const DataType: TDataType): TInteger;
function HighBound(const i: TTokenIndex; const DataType: TDataType): TInteger;

function InfoAboutToken(t: TTokenKind): String;

function IntToStr(const a: Int64): String;
function StrToInt(const a: String): TIntegerNumber;

procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);
function GetIOBits(const ioCode: TIOCode): TIOBits;

// ----------------------------------------------------------------------------

implementation

uses Messages, Utilities;

function GetDataSize(datatype: TDataType): Byte;
begin
 Result:=_DataSize[Ord(datatype)];
end;


// ----------------------------------------------------------------------------
// Map modifier codes to the bits in the method status.
// ----------------------------------------------------------------------------

procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);
begin
  bits := bits or (Word(1) shl Ord(modifierCode));
end;

// ----------------------------------------------------------------------------
// Map I/O codes to the bits in the CIO block.

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
      msg := TMessage.Create(TErrorCode.FileNotFound, 'Can''t find unit ''' + ChangeFileExt(Name, '') +
        ''' used by program ''' + PROGRAM_NAME + ''' in unit path ''' + unitPathList.ToString + '''.');

    end
    else
    begin
      msg := TMessage.Create(TErrorCode.FileNotFound, 'Can''t find ' + ftyp + ' file ''' + Name +
        ''' used by program ''' + PROGRAM_NAME + ''' in unit path ''' + unitPathList.ToString + '''.');
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
   for i:=1 to NumDefines do
    if Defines[i].Name = defineName then
    begin
     Exit(i);
    end;
   Result := 0;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddPath(s: String);
begin
  unitPathList.AddFolder(s);
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

end;	//GetEnumName


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function StrToInt(const a: String): TIntegerNumber;
(*----------------------------------------------------------------------------*)
(*----------------------------------------------------------------------------*)
{$IFNDEF PAS2JS}
var
  i: Integer;
begin
 val(a,Result, i);
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


procedure FreeTokens;
begin

 SetLength(Tok, 0);
 SetLength(IFTmpPosStack, 0);
 unitPathList.Free;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function GetTokenSpelling(t: TTokenKind): TString;
begin
Result := TokenSpelling[Ord(t)].Spelling;
end;

function GetSpelling(i: TTokenIndex): TString;
var kind: TTokenKind;
var index: Byte;
begin

  if i > NumTok then
    Result := 'no token'
  else
  begin
   kind:=   Tok[i].Kind;
   index:=Ord( kind);
    if (index > 0) and (index< Ord(TTokenKind.IDENTTOK)) then
      Result :=GetTokenSpelling(kind)
    else if Kind = TTokenKind.IDENTTOK then
      Result := 'identifier'
    else if (Kind = TTokenKind.INTNUMBERTOK)
         or (Kind = TTokenKind.FRACNUMBERTOK) then
      Result := 'number'
    else if (Kind = TTokenKind.CHARLITERALTOK)
         or (Kind = TTokenKind.STRINGLITERALTOK) then
      Result := 'literal'
    else if Kind = TTokenKind.UNITENDTOK then
      Result := 'END'
    else if Kind = TTokenKind.EOFTOK then
      Result := 'end of file'
    else
      Result := 'unknown token';
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
    or ((DataType = TTokenKind.BOOLEANTOK) and not
    (op in [TTokenKind.ANDTOK, TTokenKind.ORTOK, TTokenKind.XORTOK, TTokenKind.NOTTOK,
    TTokenKind.GTTOK, TTokenKind.GETOK, TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LETOK, TTokenKind.LTTOK]))
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

if (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <>  TTokenKind.RECORDTOK) then
    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements - 1 +
      Ord(Ident[IdentIndex].DataType =  TTokenKind.STRINGPOINTERTOK)) then
  if Ident[IdentIndex].NumAllocElements <> 1 then WarningForRangeCheckError(i, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex_(i: TTokenIndex; IdentIndex: TIdentIndex; ArrayIndex: TArrayIndex; ArrayIndexType: TDataType);
begin

if Ident[IdentIndex].NumAllocElements_ > 0 then
    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements_ - 1 +
      Ord(Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK)) then
      if Ident[IdentIndex].NumAllocElements_ <> 1 then
        WarningForRangeCheckError(i, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


function GetValueType(Value: TIntegerNumber): TDataType;
begin

  if Value < 0 then
  begin

    if Value >= Low(Shortint) then Result := TDataType.SHORTINTTOK
    else
    if Value >= Low(Smallint) then Result := TDataType.SMALLINTTOK
    else
      Result := TDataType.INTEGERTOK;

  end
  else

    case Value of
      0..255: Result := TDataType.BYTETOK;
      256..$FFFF: Result := TDataType.WORDTOK;
      else
        Result := TDataType.CARDINALTOK
    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckTok(i: TTokenIndex; ExpectedTokenCode: TTokenKind);
var
  s: String;
begin

  if Ord(ExpectedTokenCode) < Ord(TTokenKind.IDENTTOK) then
    s := GetTokenSpelling(ExpectedTokenCode)
  else if ExpectedTokenCode = TTokenKind.IDENTTOK then
    s := 'identifier'
  else if (ExpectedTokenCode = TTokenKind.INTNUMBERTOK) then
    s := 'number'
  else if (ExpectedTokenCode = TTokenKind.CHARLITERALTOK) then
    s := 'literal'
  else if (ExpectedTokenCode = TTokenKind.STRINGLITERALTOK) then
    s := 'string'
  else
    s := 'unknown token';

  if Tok[i].Kind <> ExpectedTokenCode then
    Error(i, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error, ' + '''' + s + '''' +
      ' expected but ''' + GetSpelling(i) + ''' found'));

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

  if LeftType =  TDataType.UNTYPETOK then Result := RightType;

  if Result =  TDataType.UNTYPETOK  then
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

  SetLength(linkObj, i+2);

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

for i:=0 to NumStaticStrChars-len-1 do
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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure ClearWordMemory(anArray: TWordMemory);
begin
  for i := Low(anArray) to High(anArray) do
  begin
    anArray[i]:=0;
  end;
end;

end.
