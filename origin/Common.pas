unit Common;

interface

{$i define.inc}

{$inline on}

// ----------------------------------------------------------------------------

const

  title = '1.7.5';

  TAB = ^I;   // Char for a TAB
  CR = ^M;    // Char for a CR
  LF = ^J;    // Char for a LF

  AllowDirectorySeparators: set of Char = ['/', '\'];

  AllowWhiteSpaces: set of Char = [' ', TAB, CR, LF];
  AllowQuotes: set of Char = ['''', '"'];
  AllowLabelFirstChars: set of Char = ['A'..'Z', '_'];
  AllowLabelChars: set of Char = ['A'..'Z', '0'..'9', '_', '.'];
  AllowDigitFirstChars: set of Char = ['0'..'9', '%', '$'];
  AllowDigitChars: set of Char = ['0'..'9', 'A'..'F'];

  tHex: array [0..15] of char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

  // Token codes

  UNTYPETOK = 0;

  CONSTTOK = 1;     // !!! nie zmieniac
  TYPETOK = 2;      // !!!
  VARTOK = 3;       // !!!
  PROCEDURETOK = 4; // !!!
  FUNCTIONTOK = 5;  // !!!
  LABELTOK = 6;     // !!!
  UNITTOK = 7;      // !!!


  GETINTVECTOK = 10;
  SETINTVECTOK = 11;
  CASETOK = 12;
  BEGINTOK = 13;
  ENDTOK = 14;
  IFTOK = 15;
  THENTOK = 16;
  ELSETOK = 17;
  WHILETOK = 18;
  DOTOK = 19;
  REPEATTOK = 20;
  UNTILTOK = 21;
  FORTOK = 22;
  TOTOK = 23;
  DOWNTOTOK = 24;
  ASSIGNTOK = 25;
  WRITETOK = 26;
  READLNTOK = 27;
  HALTTOK = 28;
  USESTOK = 29;
  ARRAYTOK = 30;
  OFTOK = 31;
  STRINGTOK = 32;
  INCTOK = 33;
  DECTOK = 34;
  ORDTOK = 35;
  CHRTOK = 36;
  ASMTOK = 37;
  ABSOLUTETOK = 38;
  BREAKTOK = 39;
  CONTINUETOK = 40;
  EXITTOK = 41;
  RANGETOK = 42;

  EQTOK = 43;
  NETOK = 44;
  LTTOK = 45;
  LETOK = 46;
  GTTOK = 47;
  GETOK = 48;
  LOTOK = 49;
  HITOK = 50;

  DOTTOK = 51;
  COMMATOK = 52;
  SEMICOLONTOK = 53;
  OPARTOK = 54;
  CPARTOK = 55;
  DEREFERENCETOK = 56;
  ADDRESSTOK = 57;
  OBRACKETTOK = 58;
  CBRACKETTOK = 59;
  COLONTOK = 60;

  PLUSTOK = 61;
  MINUSTOK = 62;
  MULTOK = 63;
  DIVTOK = 64;
  IDIVTOK = 65;
  MODTOK = 66;
  SHLTOK = 67;
  SHRTOK = 68;
  ORTOK = 69;
  XORTOK = 70;
  ANDTOK = 71;
  NOTTOK = 72;

  ASSIGNFILETOK = 73;
  RESETTOK = 74;
  REWRITETOK = 75;
  APPENDTOK = 76;
  BLOCKREADTOK = 77;
  BLOCKWRITETOK = 78;
  CLOSEFILETOK = 79;
  GETRESOURCEHANDLETOK = 80;
  SIZEOFRESOURCETOK = 81;

  WRITELNTOK = 82;
  SIZEOFTOK = 83;
  LENGTHTOK = 84;
  HIGHTOK = 85;
  LOWTOK = 86;
  INTTOK = 87;
  FRACTOK = 88;
  TRUNCTOK = 89;
  ROUNDTOK = 90;
  ODDTOK = 91;

  PROGRAMTOK = 92;
  LIBRARYTOK = 93;
  EXPORTSTOK = 94;
  EXTERNALTOK = 95;
  INTERFACETOK = 96;
  IMPLEMENTATIONTOK = 97;
  INITIALIZATIONTOK = 98;
  CONSTRUCTORTOK = 99;
  DESTRUCTORTOK = 100;
  OVERLOADTOK = 101;
  ASSEMBLERTOK = 102;
  FORWARDTOK = 103;
  REGISTERTOK = 104;
  INTERRUPTTOK = 105;
  PASCALTOK = 106;
  STDCALLTOK = 107;
  INLINETOK = 108;
  KEEPTOK = 109;

  SUCCTOK = 110;
  PREDTOK = 111;
  PACKEDTOK = 112;
  GOTOTOK = 113;
  INTOK = 114;
  VOLATILETOK = 115;
  STRIPEDTOK = 116;
  WITHTOK = 117;

  SETTOK = 127;              // Size = 32 SET OF

  BYTETOK = 128;             // Size = 1 BYTE
  WORDTOK = 129;             // Size = 2 WORD
  CARDINALTOK = 130;         // Size = 4 CARDINAL
  SHORTINTTOK = 131;         // Size = 1 SHORTINT
  SMALLINTTOK = 132;         // Size = 2 SMALLINT
  INTEGERTOK = 133;          // Size = 4 INTEGER
  CHARTOK = 134;             // Size = 1 CHAR
  BOOLEANTOK = 135;          // Size = 1 BOOLEAN
  POINTERTOK = 136;          // Size = 2 POINTER
  STRINGPOINTERTOK = 137;    // Size = 2 POINTER to STRING	^string
  FILETOK = 138;             // Size = 2/12 FILE
  RECORDTOK = 139;           // Size = 2/???
  OBJECTTOK = 140;           // Size = 2/???
  SHORTREALTOK = 141;        // Size = 2 SHORTREAL		Fixed-Point Q8.8
  REALTOK = 142;             // Size = 4 REAL			Fixed-Point Q24.8
  SINGLETOK = 143;           // Size = 4 SINGLE / FLOAT		IEEE-754 32bit
  HALFSINGLETOK = 144;       // Size = 2 HALFSINGLE / FLOAT16	IEEE-754 16bit
  PCHARTOK = 145;            // Size = 2 POINTER TO ARRAY OF CHAR
  ENUMTOK = 146;             // Size = AllocElementType (4)
  PROCVARTOK = 147;          // Size = 2
  TEXTFILETOK = 148;         // Size = 2/12 TEXTFILE
  SUBRANGETYPE = 149;        // Size = 0
  DEREFERENCEARRAYTOK = 150; // Size = 2 ARRAY pointers
  FORWARDTYPE = 151;         // Size = 2

  SHORTSTRINGTOK = 155;      // zamieniamy na STRINGTOK
  FLOATTOK = 156;            // zamieniamy na SINGLETOK
  FLOAT16TOK = 157;          // zamieniamy na HALFSINGLETOK
  TEXTTOK = 158;             // zamieniamy na TEXTFILETOK

  DATAORIGINOFFSET = 160;
  CODEORIGINOFFSET = 161;

  IDENTTOK = 170;
  INTNUMBERTOK = 171;
  FRACNUMBERTOK = 172;
  CHARLITERALTOK = 173;
  STRINGLITERALTOK = 174;

  EVALTOK = 184;
  LOOPUNROLLTOK = 185;
  NOLOOPUNROLLTOK = 186;
  LINKTOK = 187;
  MACRORELEASE = 188;
  PROCALIGNTOK = 189;
  LOOPALIGNTOK = 190;
  LINKALIGNTOK = 191;
  INFOTOK = 192;
  WARNINGTOK = 193;
  ERRORTOK = 194;
  UNITBEGINTOK = 195;
  UNITENDTOK = 196;
  IOCHECKON = 197;
  IOCHECKOFF = 198;
  EOFTOK = 199;              // MAXTOKENNAMES = 200


  UnsignedOrdinalTypes = [BYTETOK, WORDTOK, CARDINALTOK];
  SignedOrdinalTypes = [SHORTINTTOK, SMALLINTTOK, INTEGERTOK];
  RealTypes = [SHORTREALTOK, REALTOK, SINGLETOK, HALFSINGLETOK];

  IntegerTypes = UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes = IntegerTypes + [CHARTOK, BOOLEANTOK, ENUMTOK];

  Pointers = [POINTERTOK, PROCVARTOK, STRINGPOINTERTOK, PCHARTOK];

  FileTypes = [FILETOK, TEXTFILETOK];

  AllTypes = OrdinalTypes + RealTypes + Pointers;

  StringTypes = [STRINGPOINTERTOK, STRINGLITERALTOK, PCHARTOK];

  // Identifier kind codes

  CONSTANT = CONSTTOK;  // 1
  USERTYPE = TYPETOK;   // 2
  VARIABLE = VARTOK;    // 3
  //  PROC      = PROCEDURETOK;
  //  FUNC      = FUNCTIONTOK;
  LABELTYPE = LABELTOK;
  UNITTYPE = UNITTOK;
  ENUMTYPE = ENUMTOK;


  // Compiler parameters

  MAXNAMELENGTH = 32;
  MAXTOKENNAMES = 200;
  MAXSTRLENGTH = 255;
  MAXFIELDS = 256;
  MAXTYPES = 1024;
  //  MAXTOKENS    = 32768;
  MAXPOSSTACK = 512;
  MAXIDENTS = 16384;
  MAXBLOCKS = 16384;   // maksymalna liczba blokow
  MAXPARAMS = 8;       // maksymalna liczba parametrow dla PROC, FUNC
  MAXVARS = 256;       // maksymalna liczba parametrow dla VAR
  MAXUNITS = 2048;
  MAXALLOWEDUNITS = 256;
  MAXDEFINES = 256;    // maksymalna liczba $DEFINE

  CODEORIGIN = $100;
  DATAORIGIN = $8000;

  CALLDETERMPASS = 1;
  CODEGENERATIONPASS = 2;


  // Fixed-point 32-bit real number storage

  FRACBITS = 8;  // Float Fixed Point
  TWOPOWERFRACBITS = 256;


  // Data sizes

  DataSize: array [BYTETOK..FORWARDTYPE] of Byte = (
    1,  // Size = 1 BYTE
    2,  // Size = 2 WORD
    4,  // Size = 4 CARDINAL
    1,  // Size = 1 SHORTINT
    2,  // Size = 2 SMALLINT
    4,  // Size = 4 INTEGER
    1,  // Size = 1 CHAR
    1,  // Size = 1 BOOLEAN
    2,  // Size = 2 POINTER
    2,  // Size = 2 POINTER to STRING
    2,  // Size = 2 FILE
    2,  // Size = 2 RECORD
    2,  // Size = 2 OBJECT
    2,  // Size = 2 SHORTREAL
    4,  // Size = 4 REAL
    4,  // Size = 4 SINGLE / FLOAT
    2,  // Size = 2 HALFSINGLE / FLOAT16
    2,  // Size = 2 PCHAR
    4,  // Size = 1 ENUM
    2,  // Size = 2 PROCVAR
    2,  // Size = 2 TEXTFILE
    0,  // Size = 0 SUBRANGE
    2,  // Size = 2 DEREFERENCEARRAY
    2   // Size = 2 FORWARD
    );

  fBlockRead_ParamType: array [1..3] of Byte = (UNTYPETOK, WORDTOK, POINTERTOK);


{$i targets/type.inc}


type

  // Indirection levels

  TIndirectionLevel = (

    ASVALUE,    // Ord(Ident[IdentIndex].Kind = VARIABLE) -> 0 -> ASVALUE
    ASPOINTER,  // Ord(Ident[IdentIndex].Kind = VARIABLE) -> 1 -> ASPOINTER

    ASPOINTERTOPOINTER,
    ASPOINTERTOARRAYORIGIN,   // + GenerateIndexShift
    ASPOINTERTOARRAYORIGIN2,  // - GenerateIndexShift
    ASPOINTERTORECORD,
    ASPOINTERTOARRAYRECORD,
    ASSTRINGPOINTERTOARRAYORIGIN,
    ASSTRINGPOINTER1TOARRAYORIGIN,
    ASPOINTERTODEREFERENCE,
    ASPOINTERTORECORDARRAYORIGIN,
    ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN,
    ASPOINTERTOARRAYRECORDTOSTRING,

    ASCHAR,  // GenerateWriteString
    AsBoolean,
    ASREAL,
    ASSHORTREAL,
    ASHALFSINGLE,
    ASSINGLE,
    ASPCHAR
    );

  // Parameter passing

  TParameterPassingMethod = (

    UNDEFINED,
    VALPASSING,   // By value, modifiable
    CONSTPASSING, // By const, unmodifiable
    VARPASSING    // By reference, modifiable
    );


  ModifierCode = (mKeep = $100, mOverload = $80, mInterrupt = $40, mRegister = $20, mAssembler = $10, mForward = $08, mPascal = $04, mStdCall = $02, mInline = $01);

  irCode = (iDLI, iVBLD, iVBLI, iTIM1, iTIM2, iTIM4);

  ioCode = (ioOpenRead = 4, ioReadRecord = 5, ioRead = 7, ioOpenWrite = 8, ioAppend = 9, ioWriteRecord = 9, ioWrite = $0b, ioOpenReadWrite = $0c, ioFileMode = $f0, ioClose = $ff);


  code65 =
    (

    __putCHAR, __putEOL,
    __addBX, __subBX, __movaBX_Value,

    __imulECX,

    __addAL_CL, __addAX_CX, __addEAX_ECX,
    __shlAL_CL, __shlAX_CL, __shlEAX_CL,
    __subAL_CL, __subAX_CX, __subEAX_ECX,
    __shrAL_CL, __shrAX_CL, __shrEAX_CL

    );

  TString = String [MAXSTRLENGTH];
  TName = String [MAXNAMELENGTH];

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
    NumAllocElements, NumAllocElements_: Cardinal;
    AllocElementType: Byte;
    PassMethod: TParameterPassingMethod;
    i, i_: Integer;
  end;

  TFloat = array [0..1] of Integer;

  TParamList = array [1..MAXPARAMS] of TParam;

  TVariableList = array [1..MAXVARS] of TParam;

  TField = record
    Name: TName;
    Value: Int64;
    DataType: Byte;
    NumAllocElements: Cardinal;
    AllocElementType: Byte;
    ObjectVariable: Boolean;
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
    case Kind: Byte of
             IDENTTOK: (Name: ^TString);
         INTNUMBERTOK: (Value: Int64);
        FRACNUMBERTOK: (FracValue: Single);
     STRINGLITERALTOK: (StrAddress: Word; StrLength: Word);
  end;

  TIdentifier = record
    Name: TString;
    Value: Int64;         // Value for a constant, address for a variable, procedure or function
    Block: Integer;       // Index of a block in which the identifier is defined
    UnitIndex: Integer;
    Alias: TString;       // EXTERNAL alias 'libraries'
    Libraries: Integer;   // EXTERNAL alias 'libraries'
    DataType: Byte;
    IdType: Byte;
    PassMethod: TParameterPassingMethod;
    Pass: Byte;

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

    case Kind: Byte of
      PROCEDURETOK, FUNCTIONTOK: (NumParams: Word;
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
        IsNotDead: Boolean;);

      VARIABLE, USERTYPE: (NumAllocElements, NumAllocElements_: Cardinal;
        AllocElementType: Byte;
        ObjectVariable: Boolean;
      );
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

  TArrayString = array of String;


{$i targets/var.inc}


var

  PROGRAM_NAME: String = 'Program';
  LIBRARY_NAME: String;

  AsmBlock: array [0..4095] of String;

  Data, DataSegment, StaticStringData: array [0..$FFFF] of Word;

  Types: array [1..MAXTYPES] of TType;
  Tok: array of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  Spelling: array [1..MAXTOKENNAMES] of TString;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;  // {$include ...} -> UnitName[MAXUNITS..]
  Defines: array [1..MAXDEFINES] of TDefines;
  IFTmpPosStack: array of Integer;
  BreakPosStack: array [0..MAXPOSSTACK] of TPosStack;
  CodePosStack: array [0..MAXPOSSTACK] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;  // For dead code elimination

  OldConstValType: Byte;

  AddDefines: Integer = 1;
  NumDefines: Integer = 1;  // NumDefines = AddDefines

  NumTok, NumIdent, NumTypes, NumPredefIdent, NumStaticStrChars, NumUnits, NumBlocks, NumProc,
  BlockStackTop, CodeSize, CodePosStackTop, BreakPosStackTop, _VarDataSize, Pass, ShrShlCnt,
  NumStaticStrCharsTmp, AsmBlockIndex, IfCnt, CaseCnt, IfdefLevel, run_func: Integer;

  TemporaryBufIndex: Integer = -1;

  start_time: QWord;

  CODEORIGIN_BASE: Integer = -1;

  DATA_BASE: Integer = -1;
  ZPAGE_BASE: Integer = -1;
  STACK_BASE: Integer = -1;

  UnitNameIndex: Integer = 1;

  FastMul: Integer = -1;

  OutFile: TextFile;

  //AsmLabels: array of integer;

  resArray: array of TResource;

  MainPath, FilePath, optyA, optyY, optyBP2,
  optyFOR0, optyFOR1, optyFOR2, optyFOR3, LastTempBuf0, outputFile: TString;

  msgWarning, msgNote, msgUser, UnitPath, OptimizeBuf, LinkObj, WithName: TArrayString;


  optimize: record
    use: Boolean;
    unitIndex, line, old: Integer;
    end;

  codealign: record
    proc, loop, link: Integer;
    end;


  PROGRAMTOK_USE, INTERFACETOK_USE, LIBRARYTOK_USE, LIBRARY_USE,
  RCLIBRARY, OutputDisabled, isConst, isError, isInterrupt, IOCheck, Macros: Boolean;

  DiagMode: Boolean = False;
  DataSegmentUse: Boolean = False;

  LoopUnroll: Boolean = False;

  PublicSection: Boolean = True;


{$IFDEF USEOPTFILE}

  OptFile: TextFile;

{$ENDIF}

// ----------------------------------------------------------------------------

type
  TTokenIndex = Integer;

type
  TIdentifierIndex = Integer;

function Hex(Value: cardinal; nibbles: shortint): string;
function HexByte(Value: byte): string;
function HexWord(Value: word): string;

procedure AddDefine(const X: String);

procedure AddPath(s: String);

function GetDataSize(DataType: Byte): integer;

procedure CheckArrayIndex(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);

procedure CheckArrayIndex_(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);

procedure CheckOperator(ErrTokenIndex: Integer; op: Byte; DataType: Byte; RightType: Byte = 0);

procedure CheckTok(i: Integer; ExpectedTok: Byte);

procedure DefineStaticString(StrTokenIndex: Integer; const StrValue: String);

procedure DefineFilename(StrTokenIndex: Integer; const StrValue: String);

function FindFile(Name: String; const ftyp: TString): String; overload;

function FindFile(Name: String): Boolean; overload;

procedure FreeTokens;

function GetCommonConstType(ErrTokenIndex: Integer; DstType, SrcType: Byte; err: Boolean = True): Boolean;

function GetCommonType(ErrTokenIndex: Integer; LeftType, RightType: Byte): Byte;

function GetEnumName(IdentIndex: Integer): TString;

function GetSpelling(i: Integer): TString;

function GetVAL(const a: String): Integer;

function GetValueType(Value: Int64): Byte;

function HighBound(i: Integer; DataType: Byte): Int64;

function InfoAboutToken(t: Byte): String;

function IntToStr(const a: Int64): String;

function LowBound(i: Integer; DataType: Byte): Int64;

function Min(a, b: Integer): Integer;

function SearchDefine(const X: String): Integer;

function StrToInt(const a: String): Int64;


// ----------------------------------------------------------------------------

implementation

uses SysUtils, Messages;

// ----------------------------------------------------------------------------


function Hex(Value: cardinal; nibbles: shortint): string;
(*----------------------------------------------------------------------------*)
(*  zamiana na zapis hexadecymalny                                            *)
(*  'B' okresla maksymalna liczbe nibbli do zamiany                           *)
(*  jesli sa jeszcze jakies wartosci to kontynuuje zamiane                    *)
(*----------------------------------------------------------------------------*)
var v: byte;
begin

 Result := '';

 while (nibbles > 0) or (Value <> 0) do begin

  v := byte(Value);
  Result := tHex[v shr 4] + tHex[v and $0f] + Result;

  Value := Value shr 8;

  dec(nibbles, 2);
 end;

 Result := '$' + Result;

end;


// ----------------------------------------------------------------------------


function HexByte(Value: byte): string;
begin
  Result := '$' + tHex[Value shr 4] + tHex[Value and $0f];
end;


function HexWord(Value: word): string;
var v: byte;
begin
  v := Value;
  Result := tHex[v shr 4] + tHex[v and $0f];

  v := Value shr 8;
  Result := '$' + tHex[v shr 4] + tHex[v and $0f] + Result;
end;


// ----------------------------------------------------------------------------


function NormalizePath(var Name: String): String;
begin

  Result := Name;

  {$IFDEF UNIX}
   if Pos('\', Name) > 0 then
    Result := LowerCase(StringReplace(Name, '\', '/', [rfReplaceAll]));
  {$ENDIF}

  {$IFDEF LINUX}
    Result := LowerCase(Name);
  {$ENDIF}

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function FindFile(Name: String; const ftyp: TString): String; overload;
var
  i: Integer;
begin

  Name := NormalizePath(Name);

  i := 0;

  repeat

    Result := Name;

    if not FileExists(Result) then
    begin
      Result := UnitPath[i] + Name;

      if not FileExists(Result) and (i > 0) then
      begin
        Result := FilePath + UnitPath[i] + Name;
      end;

    end;

    Inc(i);

  until (i > High(UnitPath)) or FileExists(Result);

  if not FileExists(Result) then
    if ftyp = 'unit' then
      Error(NumTok, 'Can''t find unit ' + ChangeFileExt(Name, '') + ' used by ' + PROGRAM_NAME)
    else
      Error(NumTok, 'Can''t open ' + ftyp + ' file ''' + Result + '''');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function FindFile(Name: String): Boolean; overload;
var
  i: Integer;
  fnm: String;
begin

  Name := NormalizePath(Name);

  i := 0;

  repeat

    fnm := Name;

    if not FileExists(fnm) then
    begin
      fnm := UnitPath[i] + Name;

      if not FileExists(fnm) and (i > 0) then
      begin
        fnm := FilePath + UnitPath[i] + Name;
      end;

    end;

    Inc(i);

  until (i > High(UnitPath)) or FileExists(fnm);

  Result := FileExists(fnm);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function SearchDefine(const X: String): Integer;
var
  i: Integer;
begin
  for i := 1 to NumDefines do
    if X = Defines[i].Name then
    begin
      Exit(i);
    end;
  Result := 0;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddDefine(const X: String);
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
var
  k: Integer;
begin

  for k := 1 to High(UnitPath) - 1 do
    if UnitPath[k] = s then exit;
  							// https://github.com/tebe6502/Mad-Pascal/issues/113
  {$IFDEF UNIX}
   if Pos('\', s) > 0 then
    s := LowerCase(StringReplace(s, '\', '/', [rfReplaceAll]));
  {$ENDIF}

  k := High(UnitPath);
  UnitPath[k] := IncludeTrailingPathDelimiter(s);

  SetLength(UnitPath, k + 2);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetDataSize(DataType: Byte): integer;
begin

  if DataType in [BYTETOK..FORWARDTYPE] then
    Result := DataSize[ DataType ]
  else
    Result := 0;

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

    for BlockStackIndex := BlockStackTop downto 0 do	// search all nesting levels from the current one to the most outer one
      for IdentIndex := 1 to NumIdent do
        if (Ident[IdentIndex].DataType = ENUMTYPE) and (Ident[IdentIndex].NumAllocElements = Num) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
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


function StrToInt(const a: String): Int64;
  (*----------------------------------------------------------------------------*)
  (*----------------------------------------------------------------------------*)
var
  i: Integer;
begin
  val(a, Result, i);
end;


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


function Min(a, b: Integer): Integer;
begin

  if a < b then
    Result := a
  else
    Result := b;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure FreeTokens;
var
  i: Integer;
begin

  for i := 1 to NumTok do
    if (Tok[i].Kind = IDENTTOK) and (Tok[i].Name <> nil) then Dispose(Tok[i].Name);

  SetLength(Tok, 0);
  SetLength(IFTmpPosStack, 0);
  SetLength(UnitPath, 0);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetSpelling(i: Integer): TString;
begin

  if i > NumTok then
    Result := 'no token'
  else if (Tok[i].Kind > 0) and (Tok[i].Kind < IDENTTOK) then
    Result := Spelling[Tok[i].Kind]
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


procedure CheckOperator(ErrTokenIndex: Integer; op: Byte; DataType: Byte; RightType: Byte = 0);
begin

  //writeln(tok[ErrTokenIndex].Name^,',', op,',',DataType);

 if {(not (DataType in (OrdinalTypes + [REALTOK, POINTERTOK]))) or}
   ((DataType in RealTypes) and
       not (op in [MULTOK, DIVTOK, PLUSTOK, MINUSTOK, GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK])) or
   ((DataType in IntegerTypes) and
       not (op in [MULTOK, IDIVTOK, MODTOK, SHLTOK, SHRTOK, ANDTOK, PLUSTOK, MINUSTOK, ORTOK, XORTOK, NOTTOK, GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK, INTOK])) or
   ((DataType = CHARTOK) and
       not (op in [GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK, INTOK])) or
   ((DataType = BOOLEANTOK) and
       not (op in [ANDTOK, ORTOK, XORTOK, NOTTOK, GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK])) or
   ((DataType in Pointers) and
       not (op in [GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK, PLUSTOK, MINUSTOK]))
 then
  if DataType = RightType then
   Error(ErrTokenIndex, 'Operator is not overloaded: ' + '"' + InfoAboutToken(DataType) + '" ' + InfoAboutToken(op) + ' "' + InfoAboutToken(RightType) + '"')
  else
   Error(ErrTokenIndex, 'Operation "' + InfoAboutToken(op) + '" not supported for types "' +  InfoAboutToken(DataType) + '" and "' + InfoAboutToken(RightType) + '"');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

 if (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> RECORDTOK) then
  if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
   if Ident[IdentIndex].NumAllocElements <> 1 then warning(i, RangeCheckError, IdentIndex, ArrayIndex, ArrayIndexType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckArrayIndex_(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

 if Ident[IdentIndex].NumAllocElements_ > 0 then
  if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements_ - 1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
   if Ident[IdentIndex].NumAllocElements_ <> 1 then warning(i, RangeCheckError_, IdentIndex, ArrayIndex, ArrayIndexType);

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

    STRINGLITERALTOK: Result := 'Constant String';

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

end;  //InfoAboutToken


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function LowBound(i: Integer; DataType: Byte): Int64;
begin

  Result := 0;

  case DataType of

    UNTYPETOK: iError(i, CantReadWrite);
   INTEGERTOK: Result := Low(Integer);
  SMALLINTTOK: Result := Low(SmallInt);
  SHORTINTTOK: Result := Low(ShortInt);
      CHARTOK: Result := 0;
   BOOLEANTOK: Result := ord(Low(Boolean));
      BYTETOK: Result := Low(Byte);
      WORDTOK: Result := Low(Word);
  CARDINALTOK: Result := Low(Cardinal);
    STRINGTOK: Result := 1;
   POINTERTOK: Result := 0;

  else
    Error(i, TypeMismatch);

  end;// case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function HighBound(i: Integer; DataType: Byte): Int64;
begin

  Result := 0;

  case DataType of

    UNTYPETOK: iError(i, CantReadWrite);
   INTEGERTOK: Result := High(Integer);
  SMALLINTTOK: Result := High(SmallInt);
  SHORTINTTOK: Result := High(ShortInt);
      CHARTOK: Result := 255;
   BOOLEANTOK: Result := ord(High(Boolean));
      BYTETOK: Result := High(Byte);
      WORDTOK: Result := High(Word);
  CARDINALTOK: Result := High(Cardinal);
    STRINGTOK: Result := 255;
   POINTERTOK: Result := High(Word);

  else
    Error(i, TypeMismatch);

  end;// case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetVAL(const a: String): Integer;
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

    if Value >= Low(Shortint) then Result := SHORTINTTOK else
      if Value >= Low(Smallint) then Result := SMALLINTTOK else
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


procedure CheckTok(i: Integer; ExpectedTok: Byte);
var
  s: String;
begin

  if ExpectedTok < IDENTTOK then
   s := Spelling[ExpectedTok]
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

end;  //CheckTok


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetCommonConstType(ErrTokenIndex: Integer; DstType, SrcType: Byte; err: Boolean = True): Boolean;
begin

  Result := False;

  if (DataSize[DstType] < DataSize[SrcType]) or
     ( (DstType = REALTOK) and (SrcType <> REALTOK) ) or
     ( (DstType <> REALTOK) and (SrcType = REALTOK) ) or

     ( (DstType = SINGLETOK) and (SrcType <> SINGLETOK) ) or
     ( (DstType <> SINGLETOK) and (SrcType = SINGLETOK) ) or

     ( (DstType = HALFSINGLETOK) and (SrcType <> HALFSINGLETOK) ) or
     ( (DstType <> HALFSINGLETOK) and (SrcType = HALFSINGLETOK) ) or

     ( (DstType = SHORTREALTOK) and (SrcType <> SHORTREALTOK) ) or
     ( (DstType <> SHORTREALTOK) and (SrcType = SHORTREALTOK) ) or

     ( (DstType in IntegerTypes) and (SrcType in [CHARTOK, BOOLEANTOK, POINTERTOK, DATAORIGINOFFSET, CODEORIGINOFFSET, STRINGPOINTERTOK]) ) or
     ( (SrcType in IntegerTypes) and (DstType in [CHARTOK, BOOLEANTOK]) ) then

     if err then
      iError(ErrTokenIndex, IncompatibleTypes, 0, SrcType, DstType)
     else
      Result := true;

end;  //GetCommonConstType


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetCommonType(ErrTokenIndex: Integer; LeftType, RightType: Byte): Byte;
begin

  Result := 0;

  if LeftType = RightType then     // General rule

    Result := LeftType

  else
   if (LeftType in IntegerTypes) and (RightType in IntegerTypes) then
     Result := LeftType;

   if (LeftType in Pointers + [DEREFERENCEARRAYTOK]) and (RightType in Pointers + [DEREFERENCEARRAYTOK]) then
     Result := LeftType;

   if LeftType = UNTYPETOK then Result := RightType;

   if Result = 0 then
     Error(ErrTokenIndex, IncompatibleTypes, 0, RightType, LeftType);

end;  //GetCommonType


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure DefineFilename(StrTokenIndex: Integer; const StrValue: String);
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

end;  //DefineFilename


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure DefineStaticString(StrTokenIndex: Integer; const StrValue: String);
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
    writeln('DefineStaticString: ', len);
    halt;
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

end;  //DefineStaticString


end.
