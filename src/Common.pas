unit Common;

{$I Defines.inc}

interface

uses SysUtils, FileIO, Types, StringUtilities;

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



  // Token codes

  UNTYPETOK		= 0;

  CONSTTOK		= 1;     // !!! Don't change
  TYPETOK		= 2;     // !!!
  VARTOK		= 3;     // !!!
  PROCEDURETOK		= 4;     // !!!
  FUNCTIONTOK		= 5;     // !!!
  LABELTOK		= 6;	 // !!!
  UNITTOK		= 7;	 // !!!


  GETINTVECTOK		= 10;
  SETINTVECTOK		= 11;
  CASETOK		= 12;
  BEGINTOK		= 13;
  ENDTOK		= 14;
  IFTOK			= 15;
  THENTOK		= 16;
  ELSETOK		= 17;
  WHILETOK		= 18;
  DOTOK			= 19;
  REPEATTOK		= 20;
  UNTILTOK		= 21;
  FORTOK		= 22;
  TOTOK			= 23;
  DOWNTOTOK		= 24;
  ASSIGNTOK		= 25;
  WRITETOK		= 26;
  READLNTOK		= 27;
  HALTTOK		= 28;
  USESTOK		= 29;
  ARRAYTOK		= 30;
  OFTOK			= 31;
  STRINGTOK		= 32;
  INCTOK		= 33;
  DECTOK		= 34;
  ORDTOK		= 35;
  CHRTOK		= 36;
  ASMTOK		= 37;
  ABSOLUTETOK		= 38;
  BREAKTOK		= 39;
  CONTINUETOK		= 40;
  EXITTOK		= 41;
  RANGETOK		= 42;

  EQTOK			= 43;
  NETOK			= 44;
  LTTOK			= 45;
  LETOK			= 46;
  GTTOK			= 47;
  GETOK			= 48;
  LOTOK			= 49;
  HITOK			= 50;

  DOTTOK		= 51;
  COMMATOK		= 52;
  SEMICOLONTOK		= 53;
  OPARTOK		= 54;
  CPARTOK		= 55;
  DEREFERENCETOK	= 56;
  ADDRESSTOK		= 57;
  OBRACKETTOK		= 58;
  CBRACKETTOK		= 59;
  COLONTOK		= 60;

  PLUSTOK		= 61;
  MINUSTOK		= 62;
  MULTOK		= 63;
  DIVTOK		= 64;
  IDIVTOK		= 65;
  MODTOK		= 66;
  SHLTOK		= 67;
  SHRTOK		= 68;
  ORTOK			= 69;
  XORTOK		= 70;
  ANDTOK		= 71;
  NOTTOK		= 72;

  ASSIGNFILETOK		= 73;
  RESETTOK		= 74;
  REWRITETOK		= 75;
  APPENDTOK		= 76;
  BLOCKREADTOK		= 77;
  BLOCKWRITETOK		= 78;
  CLOSEFILETOK		= 79;
  GETRESOURCEHANDLETOK	= 80;
  SIZEOFRESOURCETOK     = 81;

  WRITELNTOK		= 82;
  SIZEOFTOK		= 83;
  LENGTHTOK		= 84;
  HIGHTOK		= 85;
  LOWTOK		= 86;
  INTTOK		= 87;
  FRACTOK		= 88;
  TRUNCTOK		= 89;
  ROUNDTOK		= 90;
  ODDTOK		= 91;

  PROGRAMTOK		= 92;
  LIBRARYTOK		= 93;
  EXPORTSTOK		= 94;
  EXTERNALTOK		= 95;
  INTERFACETOK		= 96;
  IMPLEMENTATIONTOK     = 97;
  INITIALIZATIONTOK     = 98;
  CONSTRUCTORTOK	= 99;
  DESTRUCTORTOK		= 100;
  OVERLOADTOK		= 101;
  ASSEMBLERTOK		= 102;
  FORWARDTOK		= 103;
  REGISTERTOK		= 104;
  INTERRUPTTOK		= 105;
  PASCALTOK		= 106;
  STDCALLTOK		= 107;
  INLINETOK		= 108;
  KEEPTOK		= 109;

  SUCCTOK		= 110;
  PREDTOK		= 111;
  PACKEDTOK		= 112;
  GOTOTOK		= 113;
  INTOK			= 114;
  VOLATILETOK		= 115;
  STRIPEDTOK		= 116;


  SETTOK		= 127;	// Size = 32 SET OF

  BYTETOK		= 128;	// Size = 1 BYTE
  WORDTOK		= 129;	// Size = 2 WORD
  CARDINALTOK		= 130;	// Size = 4 CARDINAL
  SHORTINTTOK		= 131;	// Size = 1 SHORTINT
  SMALLINTTOK		= 132;	// Size = 2 SMALLINT
  INTEGERTOK		= 133;	// Size = 4 INTEGER
  CHARTOK		= 134;	// Size = 1 CHAR
  BOOLEANTOK		= 135;	// Size = 1 BOOLEAN
  POINTERTOK		= 136;	// Size = 2 POINTER
  STRINGPOINTERTOK	= 137;	// Size = 2 POINTER to STRING
  FILETOK		= 138;	// Size = 2/12 FILE
  RECORDTOK		= 139;	// Size = 2/???
  OBJECTTOK		= 140;	// Size = 2/???
  SHORTREALTOK		= 141;	// Size = 2 SHORTREAL			Fixed-Point Q8.8
  REALTOK		= 142;	// Size = 4 REAL			Fixed-Point Q24.8
  SINGLETOK		= 143;	// Size = 4 SINGLE / FLOAT		IEEE-754 32-bit
  HALFSINGLETOK		= 144;	// Size = 2 HALFSINGLE / FLOAT16	IEEE-754 16-bit
  PCHARTOK		= 145;	// Size = 2 POINTER TO ARRAY OF CHAR
  ENUMTOK		= 146;	// Size = 1 BYTE
  PROCVARTOK		= 147;	// Size = 2
  TEXTFILETOK		= 148;	// Size = 2/12 TEXTFILE
  FORWARDTYPE		= 149;	// Size = 2

  SHORTSTRINGTOK	= 150;	// We change into STRINGTOK
  FLOATTOK		= 151;	// We change into SINGLETOK
  FLOAT16TOK		= 152;	// We change into HALFSINGLETOK
  TEXTTOK		= 153;	// We change into TEXTFILETOK

  DEREFERENCEARRAYTOK	= 154;	// For ARRAY pointers


  DATAORIGINOFFSET	= 160;
  CODEORIGINOFFSET	= 161;

  IDENTTOK		= 170;
  INTNUMBERTOK		= 171;
  FRACNUMBERTOK		= 172;
  CHARLITERALTOK	= 173;
  STRINGLITERALTOK	= 174;

  EVALTOK		= 184;
  LOOPUNROLLTOK		= 185;
  NOLOOPUNROLLTOK	= 186;
  LINKTOK		= 187;
  MACRORELEASE		= 188;
  PROCALIGNTOK		= 189;
  LOOPALIGNTOK		= 190;
  LINKALIGNTOK		= 191;
  INFOTOK		= 192;
  WARNINGTOK		= 193;
  ERRORTOK		= 194;
  UNITBEGINTOK		= 195;
  UNITENDTOK		= 196;
  IOCHECKON		= 197;
  IOCHECKOFF		= 198;
  EOFTOK		= 199;     // MAXTOKENNAMES = 200

  UnsignedOrdinalTypes	= [BYTETOK, WORDTOK, CARDINALTOK];
  SignedOrdinalTypes	= [SHORTINTTOK, SMALLINTTOK, INTEGERTOK];
  RealTypes		= [SHORTREALTOK, REALTOK, SINGLETOK, HALFSINGLETOK];

  IntegerTypes		= UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes		= IntegerTypes + [CHARTOK, BOOLEANTOK, ENUMTOK];

  Pointers		= [POINTERTOK, PROCVARTOK, STRINGPOINTERTOK, PCHARTOK];

  AllTypes		= OrdinalTypes + RealTypes + Pointers;

  StringTypes		= [STRINGPOINTERTOK, STRINGLITERALTOK, PCHARTOK];

  // Identifier kind codes

  CONSTANT		= CONSTTOK;
  USERTYPE		= TYPETOK;
  VARIABLE		= VARTOK;
//  PROC			= PROCEDURETOK;
//  FUNC			= FUNCTIONTOK;
  LABELTYPE		= LABELTOK;
  UNITTYPE		= UNITTOK;

  ENUMTYPE		= ENUMTOK;

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

  OBJECTVARIABLE	= 1;
  RECORDVARIABLE	= 2;


  // Data sizes

  DataSize: array [BYTETOK..FORWARDTYPE] of Byte = (
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

  fBlockRead_ParamType: array [1..3] of Byte = (UNTYPETOK, WORDTOK, POINTERTOK);


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

  TDefinesParam = array [1..MAXPARAMS] of TString;

  TDefines = record
    Name: TName;
    Macro: String;
    Line: Integer;
    Param: TDefinesParam;
  end;

  TParam = record
    Name: TString;
    DataType: Byte;
    NumAllocElements: Cardinal;
    AllocElementType: Byte;
    PassMethod: TParameterPassingMethod;
    i, i_: Integer;
   end;

  TParamList = array [1..MAXPARAMS] of TParam;

  TVariableList = array [1..MAXVARS] of TParam;

  TField = record
    Name: TName;
    Value: Int64;
    DataType: Byte;
    NumAllocElements: Cardinal;
    AllocElementType: Byte;
    Kind: Byte;
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
    Kind: Byte;
    // For Kind=IDENTTOK:
    Name: TString;
    // For Kind=INTNUMBERTOK:
    Value: Int64;
    // For Kind=FRACNUMBERTOK:
    FracValue: Single;
    // For Kind=STRINGLITERALTOK:
    StrAddress: Word;
    StrLength: Word;
    end;

  TIdentifier = record
    Name: TString;
    Value: Int64;			// Value for a constant, address for a variable, procedure or function
    Block: Integer;			// Index of a block in which the identifier is defined
    UnitIndex : Integer;
    Alias : TString;			// EXTERNAL alias 'libraries'
    Libraries : Integer;		// EXTERNAL alias 'libraries'
    DataType: Byte;
    IdType: Byte;
    PassMethod: TParameterPassingMethod;
    Pass: TPass;

    NestedNumAllocElements: Cardinal;
    NestedAllocElementType: Byte;
    NestedDataType: Byte;

    NestedFunctionNumAllocElements: Cardinal;
    NestedFunctionAllocElementType: Byte;
    isNestedFunction: Boolean;

    LoopVariable,
    isAbsolute,
    isInit,
    isUntype,
    isInitialized,
    Section: Boolean;

    Kind: Byte;

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
    AllocElementType: Byte
    end;


  TCallGraphNode = record
     ChildBlock: array [1..MAXBLOCKS] of Integer;
     NumChildren: Word;
    end;

  TUnit = record
     Name: TString;
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

var

  PROGRAM_NAME: String = 'Program';
  LIBRARY_NAME: String;

  AsmBlock: array [0..4095] of String;

  Data, DataSegment, StaticStringData: TWordMemory;

  TypeArray: array [1..MAXTYPES] of TType;
  Tok: array of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  TokenSpelling: array [1..MAXTOKENNAMES] of TString;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;	// {$include ...} -> UnitName[MAXUNITS..]
  Defines: array [1..MAXDEFINES] of TDefines;
  IFTmpPosStack: array of Integer;
  BreakPosStack: array [0..MAXPOSSTACK] of TPosStack;
  CodePosStack: array [0..MAXPOSSTACK] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;	// For dead code elimination

  OldConstValType: Byte;

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

  msgWarning, msgNote, msgUser, OptimizeBuf, LinkObj: TStringArray;
  unitPathList: TPathList;


  optimize : record
	      use: Boolean;
    unitIndex, line, old: Integer;
	     end;

  codealign : record
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

procedure AddDefine(X: String);

procedure AddPath(s: String);

procedure CheckArrayIndex(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);

procedure CheckArrayIndex_(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);

procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: Byte; DataType: Byte; RightType: Byte = 0);

procedure CheckTok(i: Integer; ExpectedTok: Byte);

procedure DefineStaticString(StrTokenIndex: TTokenIndex; StrValue: String);

procedure DefineFilename(StrTokenIndex: TTokenIndex; StrValue: String);

function ErrTokenFound(ErrTokenIndex: TTokenIndex): String;

function FindFile(Name: String; ftyp: TString): String; overload;

procedure FreeTokens;

function GetCommonConstType(ErrTokenIndex: TTokenIndex; DstType, SrcType: Byte; err: Boolean = True): Boolean;

function GetCommonType(ErrTokenIndex: TTokenIndex; LeftType, RightType: Byte): Byte;

function GetEnumName(IdentIndex: Integer): TString;

function GetSpelling(i: Integer): TString;

function GetVAL(a: String): Integer;

function GetValueType(Value: Int64): Byte;

function HighBound(i: Integer; DataType: Byte): Int64;

function InfoAboutToken(t: Byte): String;

function IntToStr(const a: Int64): String;

function LowBound(i: Integer; DataType: Byte): Int64;

function SearchDefine(X: String): Integer;

function StrToInt(const a: String): Int64;

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
begin
  Result := unitPathList.FindFile(Name);
  if Result = '' then
   if ftyp = 'unit' then
      Error(NumTok, 'Can''t find unit ''' + ChangeFileExt(Name, '') + ''' used by program ''' +
        PROGRAM_NAME + ''' in unit path ''' + unitPathList.ToString + '''.')
   else
      Error(NumTok, 'Can''t find ' + ftyp + ' file ''' + Name + ''' used by program ''' + PROGRAM_NAME +
        ''' in unit path ''' + unitPathList.ToString + '''.');
end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function SearchDefine(X: String): Integer;
var
  i: Integer;
begin
   for i:=1 to NumDefines do
    if X = Defines[i].Name then
    begin
     Exit(i);
    end;
   Result := 0;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddDefine(X: String);
var
  S: TName;
begin
   S := X;
   if SearchDefine(S) = 0 then
   begin
    Inc(NumDefines);
    Defines[NumDefines].Name := S;

    Defines[NumDefines].Macro := '';
    Defines[NumDefines].Line := 0;
   end;
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


function StrToInt(const a: String): Int64;
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


function GetSpelling(i: Integer): TString;
begin

if i > NumTok then
  Result := 'no token'
else if (Tok[i].Kind > 0) and (Tok[i].Kind < IDENTTOK) then
  Result := TokenSpelling[Tok[i].Kind]
else if Tok[i].Kind = IDENTTOK then
  Result := 'identifier'
else if (Tok[i].Kind = INTNUMBERTOK) or (Tok[i].Kind = FRACNUMBERTOK) then
  Result := 'number'
else if (Tok[i].Kind = CHARLITERALTOK) or (Tok[i].Kind = STRINGLITERALTOK) then
  Result := 'literal'
else if (Tok[i].Kind = UNITENDTOK) then
  Result := 'END'
else if (Tok[i].Kind = EOFTOK) then
  Result := 'end of file'
else
  Result := 'unknown token';

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ErrTokenFound(ErrTokenIndex: TTokenIndex): String;
begin

 Result:=' expected but ''' + GetSpelling(ErrTokenIndex) + ''' found';

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckOperator(ErrTokenIndex: TTokenIndex; op: Byte; DataType: Byte; RightType: Byte = 0);
begin

//writeln(tok[ErrTokenIndex].Name,',', op,',',DataType);

 if {(not (DataType in (OrdinalTypes + [REALTOK, POINTERTOK]))) or}
  ((DataType in RealTypes) and not (op in [MULTOK, DIVTOK, PLUSTOK, MINUSTOK, GTTOK,
    GETOK, EQTOK, NETOK, LETOK, LTTOK])) or ((DataType in IntegerTypes) and not
    (op in [MULTOK, IDIVTOK, MODTOK, SHLTOK, SHRTOK, ANDTOK, PLUSTOK, MINUSTOK, ORTOK, XORTOK,
    NOTTOK, GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK, INTOK])) or ((DataType = CHARTOK) and
       not (op in [GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK, INTOK])) or
    ((DataType = BOOLEANTOK) and not (op in [ANDTOK, ORTOK, XORTOK, NOTTOK, GTTOK, GETOK,
    EQTOK, NETOK, LETOK, LTTOK])) or ((DataType in Pointers) and not
    (op in [GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK, PLUSTOK, MINUSTOK])) then
 if DataType = RightType then
      Error(ErrTokenIndex, 'Operator is not overloaded: ' + '"' + InfoAboutToken(DataType) + '" ' +
        InfoAboutToken(op) + ' "' + InfoAboutToken(RightType) + '"')
 else
      Error(ErrTokenIndex, 'Operation "' + InfoAboutToken(op) + '" not supported for types "' +
        InfoAboutToken(DataType) + '" and "' + InfoAboutToken(RightType) + '"');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

if (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> RECORDTOK) then
    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements - 1 +
      Ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
  if Ident[IdentIndex].NumAllocElements <> 1 then warning(i, RangeCheckError, IdentIndex, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex_(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

if Ident[IdentIndex].NumAllocElements_ > 0 then
    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements_ - 1 +
      Ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
      if Ident[IdentIndex].NumAllocElements_ <> 1 then
        warning(i, RangeCheckError_, IdentIndex, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function InfoAboutToken(t: Byte): String;
begin

   case t of

	 EQTOK: Result := '=';
	 NETOK: Result := '<>';
	 LTTOK: Result := '<';
	 LETOK: Result := '<=';
	 GTTOK: Result := '>';
	 GETOK: Result := '>=';

	 INTOK: Result := 'IN';

	DOTTOK: Result := '.';
      COMMATOK: Result := ',';
  SEMICOLONTOK: Result := ';';
       OPARTOK: Result := '(';
       CPARTOK: Result := ')';
DEREFERENCETOK: Result := '^';
    ADDRESSTOK: Result := '@';
   OBRACKETTOK: Result := '[';
   CBRACKETTOK: Result := ']';
      COLONTOK: Result := ':';
       PLUSTOK: Result := '+';
      MINUSTOK: Result := '-';
	MULTOK: Result := '*';
	DIVTOK: Result := '/';

       IDIVTOK: Result := 'DIV';
	MODTOK: Result := 'MOD';
	SHLTOK: Result := 'SHL';
	SHRTOK: Result:= 'SHR';
	 ORTOK: Result := 'OR';
	XORTOK: Result := 'XOR';
	ANDTOK: Result := 'AND';
	NOTTOK: Result := 'NOT';

      CONSTTOK: Result := 'CONST';
       TYPETOK: Result := 'TYPE';
	VARTOK: Result := 'VARIABLE';
  PROCEDURETOK: Result := 'PROCEDURE';
   FUNCTIONTOK: Result := 'FUNCTION';
CONSTRUCTORTOK: Result := 'CONSTRUCTOR';
 DESTRUCTORTOK: Result := 'DESTRUCTOR';

      LABELTOK: Result := 'LABEL';
       UNITTOK: Result := 'UNIT';
      ENUMTYPE: Result := 'ENUM';

     RECORDTOK: Result := 'RECORD';
     OBJECTTOK: Result := 'OBJECT';
       BYTETOK: Result := 'BYTE';
   SHORTINTTOK: Result := 'SHORTINT';
       CHARTOK: Result := 'CHAR';
    BOOLEANTOK: Result := 'BOOLEAN';
       WORDTOK: Result := 'WORD';
   SMALLINTTOK: Result := 'SMALLINT';
   CARDINALTOK: Result := 'CARDINAL';
    INTEGERTOK: Result := 'INTEGER';
    POINTERTOK,
    DATAORIGINOFFSET,
    CODEORIGINOFFSET: Result := 'POINTER';

    PROCVARTOK: Result := '<Procedure Variable>';

 STRINGPOINTERTOK: Result := 'STRING';

 STRINGLITERALTOK: Result := 'literal';

  SHORTREALTOK: Result := 'SHORTREAL';
       REALTOK: Result := 'REAL';
     SINGLETOK: Result := 'SINGLE';
 HALFSINGLETOK: Result := 'FLOAT16';
	SETTOK: Result := 'SET';
       FILETOK: Result := 'FILE';
   TEXTFILETOK: Result := 'TEXTFILE';
      PCHARTOK: Result := 'PCHAR';

   REGISTERTOK: Result := 'REGISTER';
     PASCALTOK: Result := 'PASCAL';
    STDCALLTOK: Result := 'STDCALL';
     INLINETOK: Result := 'INLINE';
        ASMTOK: Result := 'ASM';
  INTERRUPTTOK: Result := 'INTERRUPT';

 else
  Result := 'UNTYPED'
 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function LowBound(i: Integer; DataType: Byte): Int64;
begin

 Result := 0;

 case DataType of

    UNTYPETOK: Error(i, CantReadWrite);
   INTEGERTOK: Result := Low(Integer);
    SMALLINTTOK: Result := Low(Smallint);
    SHORTINTTOK: Result := Low(Shortint);
      CHARTOK: Result := 0;
    BOOLEANTOK: Result := Ord(Low(Boolean));
      BYTETOK: Result := Low(Byte);
      WORDTOK: Result := Low(Word);
  CARDINALTOK: Result := Low(Cardinal);
    STRINGTOK: Result := 1;

 else
      Error(i, TypeMismatch);
 end;// case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function HighBound(i: TTokenIndex; DataType: Byte): Int64;
begin

 Result := 0;

 case DataType of

    UNTYPETOK: Error(i, CantReadWrite);
   INTEGERTOK: Result := High(Integer);
    SMALLINTTOK: Result := High(Smallint);
    SHORTINTTOK: Result := High(Shortint);
      CHARTOK: Result := 255;
    BOOLEANTOK: Result := Ord(High(Boolean));
      BYTETOK: Result := High(Byte);
      WORDTOK: Result := High(Word);
  CARDINALTOK: Result := High(Cardinal);
    STRINGTOK: Result := 255;

 else
      Error(i, TypeMismatch);
 end;// case

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


function GetValueType(Value: Int64): Byte;
begin

  if Value < 0 then
  begin

    if Value >= Low(Shortint) then Result := SHORTINTTOK
    else
    if Value >= Low(Smallint) then Result := SMALLINTTOK
    else
      Result := INTEGERTOK;

  end
  else

    case Value of
      0..255: Result := BYTETOK;
      256..$FFFF: Result := WORDTOK;
      else
        Result := CARDINALTOK
    end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckTok(i: TTokenIndex; ExpectedTok: Byte);
var
  s: String;
begin

  if ExpectedTok < IDENTTOK then
    s := TokenSpelling[ExpectedTok]
  else if ExpectedTok = IDENTTOK then
    s := 'identifier'
  else if (ExpectedTok = INTNUMBERTOK) then
    s := 'number'
  else if (ExpectedTok = CHARLITERALTOK) then
    s := 'literal'
  else if (ExpectedTok = STRINGLITERALTOK) then
    s := 'string'
  else
    s := 'unknown token';

  if Tok[i].Kind <> ExpectedTok then
    Error(i, 'Syntax error, ' + '''' + s + '''' + ' expected but ''' + GetSpelling(i) + ''' found');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetCommonConstType(ErrTokenIndex: TTokenIndex; DstType, SrcType: Byte; err: Boolean = True): Boolean;
begin

  Result := False;

  if (DataSize[DstType] < DataSize[SrcType]) or ((DstType = REALTOK) and (SrcType <> REALTOK)) or
    ((DstType <> REALTOK) and (SrcType = REALTOK)) or ((DstType = SINGLETOK) and (SrcType <> SINGLETOK)) or
    ((DstType <> SINGLETOK) and (SrcType = SINGLETOK)) or ((DstType = HALFSINGLETOK) and
    (SrcType <> HALFSINGLETOK)) or ((DstType <> HALFSINGLETOK) and (SrcType = HALFSINGLETOK)) or

     ( (DstType = SHORTREALTOK) and (SrcType <> SHORTREALTOK) ) or
     ( (DstType <> SHORTREALTOK) and (SrcType = SHORTREALTOK) ) or
    ((DstType in IntegerTypes) and (SrcType in [CHARTOK, BOOLEANTOK, POINTERTOK, DATAORIGINOFFSET,
    CODEORIGINOFFSET, STRINGPOINTERTOK])) or ((SrcType in IntegerTypes) and
    (DstType in [CHARTOK, BOOLEANTOK])) then

     if err then
      Error(ErrTokenIndex, IncompatibleTypes, 0, SrcType, DstType)
     else
      Result := True;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetCommonType(ErrTokenIndex: TTokenIndex; LeftType, RightType: Byte): Byte;
begin

  Result := 0;

  if LeftType = RightType then     // General rule

    Result := LeftType

  else
  if (LeftType in IntegerTypes) and (RightType in IntegerTypes) then
    Result := LeftType;

  if (LeftType in Pointers) and (RightType in Pointers) then
    Result := LeftType;

  if LeftType = UNTYPETOK then Result := RightType;

  if Result = 0 then
    Error(ErrTokenIndex, IncompatibleTypes, 0, RightType, LeftType);

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
