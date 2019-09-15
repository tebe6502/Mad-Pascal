
(*

Sub-Pascal 32-bit real mode compiler for 80386+ processors v. 2.0 by Vasiliy Tereshkov, 2009

Mad-Pascal cross compiler for 6502 (Atari XE/XL) by Tomasz Biela, 2015-2019

Contributors:

+ Bocianu Boczansky :
	- BLIBS
	- XBIOS
	- MADSTRAP
	- PASDOC

+ Bostjan Gorisek :
	- ZXLIB

+ David Schmenk :
	- IEEE-754 (32bit) single

+ DMSC :
	- conditional directives {$IFDEF}, {$ELSE}, {$DEFINE} ...
	- fast SIN/COS (IEEE754-32 precision)
	- DrawChar (unit GRAPHICS)


# rejestr X uzywany jest do przekazywania parametrow przez programowy stos :STACKORIGIN
# stos programowy sluzy tez do tymczasowego przechowywania wyrazen, wynikow operacji itp.

# typ REAL Fixed-Point Q16.16 przekracza 32 bity dla MUL i DIV, czêsty OVERFLOW

# uzywaj asm65('') zamiast #13#10, POS bedzie wlasciwie zwracalo indeksu

# wystepuja tylko skoki w przod @+ (@- nie istnieje)

# edx+2, edx+3 nie wystepuje

# wartosc dla typu POINTER zwiekszana jest o CODEORIGIN

# BP  tylko przy adresowaniu bajtu
# BP2 przy adresowaniu wiecej niz 1 bajtu (WORD, CARDINAL itd.)

# indeks dla jednowymiarowej tablicy [0..x] = a * DataSize[AllocElementType]
# indeks dla dwuwymiarowej tablicy [0..x, 0..y] = a * ((y+1) * DataSize[AllocElementType]) + b * DataSize[AllocElementType]

# tablice typu RECORD, OBJECT sa tylko jendowymiarowe [0..x], OBJECT nie testowane

# dla typu OBJECT przekazywany jest poczatkowy adres alokacji danych pamieci (HI = regY, LO = regA), potem sa obliczane kolejne adresy w naglowku procedury/funkcji

# optymalizator usuwa odwolania do :STACKORIGIN+STACKWIDTH*2+9 gdy operacja ADC, SBC konczy sie na takim odwolaniu

*)


program MADPASCAL;

//{$DEFINE USEOPTFILE}

{$DEFINE OPTIMIZECODE}

{$I+}

uses
  SysUtils;

const

  title = '1.6.1';

  TAB = ^I;		// Char for a TAB
  CR  = ^M;		// Char for a CR
  LF  = ^J;		// Char for a LF

  AllowDirectorySeparators : set of char = ['/','\'];

  AllowWhiteSpaces	: set of char = [' ',TAB,CR,LF];
  AllowQuotes		: set of char = ['''','"'];
  AllowLabelFirstChars	: set of char = ['A'..'Z','_'];
  AllowLabelChars	: set of char = ['A'..'Z','0'..'9','_','.'];
  AllowDigitFirstChars	: set of char = ['0'..'9','%','$'];
  AllowDigitChars	: set of char = ['0'..'9','A'..'F'];


  // Token codes

  UNTYPETOK		= 0;

  CONSTTOK		= 1;     // !!! nie zmieniac
  TYPETOK		= 2;     // !!!
  VARTOK		= 3;     // !!!
  PROCEDURETOK		= 4;     // !!!
  FUNCTIONTOK		= 5;     // !!!
  LABELTOK		= 6;	 // !!!
  UNITTOK		= 7;	 // !!!
  ENUMTOK		= 8;	 // !!!

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

  WRITELNTOK		= 80;
  SIZEOFTOK		= 81;
  LENGTHTOK		= 82;
  HIGHTOK		= 83;
  LOWTOK		= 84;
  INTTOK		= 85;
  FRACTOK		= 86;
  TRUNCTOK		= 87;
  ROUNDTOK		= 88;
  ODDTOK		= 89;

  PROGRAMTOK		= 90;
  INTERFACETOK		= 91;
  IMPLEMENTATIONTOK     = 92;
  INITIALIZATIONTOK     = 93;
  OVERLOADTOK		= 94;
  ASSEMBLERTOK		= 95;
  FORWARDTOK		= 96;
  REGISTERTOK		= 97;
  INTERRUPTTOK		= 98;

  SUCCTOK		= 100;
  PREDTOK		= 101;
  PACKEDTOK		= 102;
  GOTOTOK		= 104;
  INTOK			= 105;

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
  SHORTREALTOK		= 141;	// Size = 2 SHORTREAL		Fixed-Point Q8.8
  REALTOK		= 142;	// Size = 4 REAL		Fixed-Point Q24.8
  SINGLETOK		= 143;	// Size = 4 SINGLE/FLOAT	IEEE-754

  FLOATTOK		= 144;	// zamieniamy na SINGLETOK

  DATAORIGINOFFSET	= 150;
  CODEORIGINOFFSET	= 151;

  IDENTTOK		= 180;
  INTNUMBERTOK		= 181;
  FRACNUMBERTOK		= 182;
  CHARLITERALTOK	= 183;
  STRINGLITERALTOK	= 184;
//  UNKNOWNIDENTTOK	= 185;

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
  RealTypes		= [SHORTREALTOK, REALTOK, SINGLETOK];

  IntegerTypes		= UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes		= IntegerTypes + [CHARTOK, BOOLEANTOK];

  Pointers		= [POINTERTOK, STRINGPOINTERTOK];

  AllTypes		= OrdinalTypes + RealTypes + Pointers;

  StringTypes		= [STRINGLITERALTOK, STRINGTOK];

  // Identifier kind codes

  CONSTANT		= 1;
  USERTYPE		= 2;
  VARIABLE		= 3;
  PROC			= 4;
  FUNC			= 5;
  LABELTYPE		= 6;
  UNITTYPE		= 7;
  ENUMTYPE		= 8;

  // Compiler parameters

  MAXNAMELENGTH		= 32;
  MAXTOKENNAMES		= 200;
  MAXSTRLENGTH		= 255;
  MAXFIELDS		= 256;
  MAXTYPES		= 1024;
//  MAXTOKENS		= 32768;
  MAXIDENTS		= 16384;
  MAXBLOCKS		= 16384;	// maksymalna liczba blokow
  MAXPARAMS		= 8;		// maksymalna liczba parametrow dla PROC, FUNC
  MAXVARS		= 256;		// maksymalna liczba parametrów dla VAR
  MAXUNITS		= 128;
  MAXDEFINES		= 256;		// maksymalna liczba $DEFINE
  MAXALLOWEDUNITS	= 16;

  CODEORIGIN		= $100;
  DATAORIGIN		= $8000;

  CALLDETERMPASS	= 1;
  CODEGENERATIONPASS	= 2;

  // Indirection levels

  ASVALUE		 = 0;
  ASPOINTER		 = 1;
  ASPOINTERTOPOINTER	 = 2;
  ASPOINTERTOARRAYORIGIN = 3;
  ASPOINTERTOARRAYORIGIN2= 4;
  ASPOINTERTORECORD	 = 5;
  ASPOINTERTOARRAYRECORD = 6;
  //ASPOINTERTOARRAYRECORDORIGIN = 7;

  ASCHAR		= 6;	// GenerateWriteString
  ASBOOLEAN		= 7;
  ASREAL		= 8;
  ASSHORTREAL		= 9;
  ASSINGLE		= 10;
  ASPCHAR		= 11;

  OBJECTVARIABLE	= 1;
  RECORDVARIABLE	= 2;

  // Fixed-point 32-bit real number storage

  FRACBITS		= 8;	// Float Fixed Point
  TWOPOWERFRACBITS	= 256;

  // Parameter passing

  VALPASSING		= 1;
  CONSTPASSING		= 2;
  VARPASSING		= 3;


  // Data sizes

  DataSize: array [BYTETOK..SINGLETOK] of Byte = (1,2,4,1,2,4,1,1,2,2,2,2,2,2,4,4);

  fBlockRead_ParamType : array [1..3] of byte = (POINTERTOK, WORDTOK, POINTERTOK);

type

  ModifierCode = (mOverload= $80, mInterrupt = $40, mRegister = $20, mAssembler = $10, mForward = $08);

  irCode = (iDLI, iVBL);

  ioCode = (ioOpenRead = 4, ioRead = 7, ioOpenWrite = 8, ioOpenAppend = 9, ioWrite = $0b, ioOpenReadWrite = $0c, ioFileMode = $f0, ioClose = $ff);

  ErrorCode =
  (
  UnknownIdentifier, OParExpected, IdentifierExpected, IncompatibleTypeOf, UserDefined,
  IdNumExpExpected, IncompatibleTypes, IncompatibleEnum, OrdinalExpectedFOR,
  VariableExpected, WrongNumParameters, OrdinalExpExpected, RangeCheckError, RangeCheckError_,
  VariableNotInit, ShortStringLength, StringTruncated, TypeMismatch, CantReadWrite,
  SubrangeBounds, TooManyParameters, CantDetermine, UpperBoundOfRange, HighLimit,
  IllegalTypeConversion, IncompatibleTypesArray, IllegalExpression, AlwaysTrue, AlwaysFalse,
  UnreachableCode, IllegalQualifier, LoHi
  );

  code65 =
  (
  __je, __jne, __jg, __jge, __jl, __jle,
  __putCHAR, __putEOL,
  __addBX, __subBX, __movaBX_Value,
  __imulECX,
  __notaBX, __negaBX, __notBOOLEAN,
  __addAL_CL, __addAX_CX, __addEAX_ECX,
  __shlAL_CL, __shlAX_CL, __shlEAX_CL,
  __subAL_CL, __subAX_CX, __subEAX_ECX,
  __cmpAX_CX, __cmpEAX_ECX, __cmpINT, __cmpSHORTINT, __cmpSMALLINT,
  __cmpSTRING, __cmpSTRING2CHAR, __cmpCHAR2STRING,
  __shrAL_CL, __shrAX_CL, __shrEAX_CL,
  __andEAX_ECX, __andAX_CX, __andAL_CL,
  __orEAX_ECX, __orAX_CX, __orAL_CL,
  __xorEAX_ECX, __xorAX_CX, __xorAL_CL

  );

  TString = string [MAXSTRLENGTH];
  TName   = string [MAXNAMELENGTH];

  TParam = record
    Name: TString;
    DataType: Byte;
    NumAllocElements: Cardinal;
    AllocElementType: Byte;
    PassMethod: Byte;
    end;

  TFloat = array [0..1] of integer;

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
    Field: array [0..MAXFIELDS] of TField;
  end;

  TToken = record
    UnitIndex: Integer;
    Line, Column: Integer;
    case Kind: Byte of
      IDENTTOK:
	(Name: ^TString);
      INTNUMBERTOK:
	(Value: Int64);
      FRACNUMBERTOK:
	(FracValue: Single);
      STRINGLITERALTOK:
	(StrAddress: Word;
	 StrLength: Word);
    end;

  TIdentifier = record
    Name: TString;
    Value: Int64;			// Value for a constant, address for a variable, procedure or function
    Block: Integer;			// Index of a block in which the identifier is defined
    UnitIndex : Integer;
    DataType: Byte;
    IdType: Byte;
    PassMethod: Byte;
    Pass: Byte;

    NestedFunctionNumAllocElements: cardinal;
    NestedFunctionAllocElementType: Byte;
    isNestedFunction: Boolean;

    LoopVariable,
    isAbsolute,
    isInit,
    isInitialized,
    Section: Boolean;

    case Kind: Byte of
      PROC, FUNC:
	(NumParams: Word;
	 Param: TParamList;
	 ProcAsBlock: Integer;
	 ObjectIndex: Integer;
	 IsUnresolvedForward: Boolean;
	 isOverload: Boolean;
	 isRegister: Boolean;
	 isInterrupt: Boolean;
	 isRecursion: Boolean;
	 isAsm: Boolean;
	 IsNotDead: Boolean;);

      VARIABLE, USERTYPE:
	(NumAllocElements, NumAllocElements_: Cardinal;
	 AllocElementType: Byte);
    end;


  TCallGraphNode =
    record
     ChildBlock: array [1..MAXBLOCKS] of Integer;
     NumChildren: Word;
    end;

  TUnit =
    record
     Name: TString;
     Path: String;
     Units: byte;
     Allow: array [1..MAXALLOWEDUNITS] of TString;
    end;

  TOptimizeBuf =
    record
     line, comment: string;
    end;

  TResource =
    record
     resName, resType, resFile: TString;
     resFullName: string;
     resPar: array [1..MAXPARAMS] of TString;
    end;

  TCaseLabel =
    record
     left, right: Int64;
     equality: Boolean;
    end;

  TCaseLabelArray = array of TCaseLabel;

  TArrayString = array of string;

var

  PROGRAM_NAME: string = 'Program';

  AsmBlock: array [0..4095] of string;

  DataSegment, StaticStringData: array [0..$FFFF] of Word;

  Types: array [1..MAXTYPES] of TType;
  Tok: array of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  Spelling: array [1..MAXTOKENNAMES] of TString;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;
  Defines: array [1..MAXDEFINES] of TName;
  CodePosStack, BreakPosStack: array [0..1023] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;	// For dead code elimination

  OldConstValType: byte;

  NumTok: integer = 0;

  i, NumIdent, NumTypes, NumPredefIdent, NumStaticStrChars, NumUnits, NumBlocks,
  BlockStackTop, CodeSize, CodePosStackTop, BreakPosStackTop, VarDataSize, Pass,
  NumStaticStrCharsTmp, AsmBlockIndex, IfCnt, CaseCnt, NumDefines, IfdefLevel: Integer;

  start_time: QWord;

  CODEORIGIN_Atari: integer = $2000;

   DATA_Atari: integer = -1;
  ZPAGE_Atari: integer = -1;
  STACK_Atari: integer = -1;

  UnitNameIndex: Integer = 1;

  FastMul: Integer = -1;

  CPUMode: Integer = 6502;

  OutFile: TextFile;

  asmLabels: array of integer;

  OptimizeBuf, TemporaryBuf: array of TOptimizeBuf;

  resArray: array of TResource;

  MainPath, FilePath, optyA, optyY, optyBP2: string;
  optyFOR0, optyFOR1, optyFOR2, optyFOR3: string;

  msgWarning, msgNote, msgUser, UnitPath: TArrayString;

  optimize : record
	      use, assign: Boolean;
	      unitIndex, line: integer;
	     end;


  PROGRAMTOK_USE, INTERFACETOK_USE: Boolean;
  OutputDisabled, isConst, isError, IOCheck: Boolean;

  DiagMode: Boolean = false;
  DataSegmentUse: Boolean = false;

  PublicSection : Boolean = true;


{$IFDEF USEOPTFILE}

  OptFile: TextFile;

{$ENDIF}



function StrToInt(const a: string): Int64;
(*----------------------------------------------------------------------------*)
(*----------------------------------------------------------------------------*)
var i: integer;
begin
 val(a,Result, i);
end;


function IntToStr(const a: Int64): string;
(*----------------------------------------------------------------------------*)
(*----------------------------------------------------------------------------*)
begin
 str(a, Result);
end;


function Min(a,b: integer): integer;
begin

 if a < b then
  Result := a
 else
  Result := b;

end;


procedure FreeTokens;
var i: Integer;
begin

 for i := 1 to NumTok do
  if (Tok[i].Kind = IDENTTOK) and (Tok[i].Name <> nil) then Dispose(Tok[i].Name);

 SetLength(Tok, 0);
end;


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


function ErrTokenFound(ErrTokenIndex: Integer): string;
begin

 Result:=' expected but ''' + GetSpelling(ErrTokenIndex) + ''' found';

end;


function InfoAboutToken(t: Byte): string;
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

 STRINGPOINTERTOK: Result := 'STRING';

  SHORTREALTOK: Result := 'SHORTREAL';
       REALTOK: Result := 'REAL';
     SINGLETOK: Result := 'SINGLE';
	SETTOK: Result := 'SET';
       FILETOK: Result := 'FILE';
 else
  Result := 'UNTYPED'
 end;

end;


procedure WritelnMsg;
var i: integer;
begin

 for i := 0 to High(msgWarning) - 1 do writeln(msgWarning[i]);

 for i := 0 to High(msgNote) - 1 do writeln(msgNote[i]);

end;


function GetEnumName(IdentIndex: integer): TString;
var IdentTtemp: integer;


  function Search(Num: cardinal): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
    for IdentIndex := 1 to NumIdent do
      if (Ident[IdentIndex].DataType = ENUMTYPE) and (Ident[IdentIndex].NumAllocElements = Num) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
	exit(IdentIndex);
  end;


begin

 Result := '';

 if Ident[IdentIndex].NumAllocElements > 0 then begin
  IdentTtemp := Search(Ident[IdentIndex].NumAllocElements);

  if IdentTtemp > 0 then
   Result := Ident[IdentTtemp].Name;
 end else
  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   IdentTtemp := Search(Ident[IdentIndex].NumAllocElements);

   if IdentTtemp > 0 then
    Result := Ident[IdentTtemp].Name;
  end;

end;


function LowBound(i: integer; DataType: Byte): Int64; forward;
function HighBound(i: integer; DataType: Byte): Int64; forward;


function ErrorMessage(ErrTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0; SrcType: Int64 = 0; DstType: Int64 = 0): string;
begin

 Result := '';

 case err of

	UserDefined: Result := 'User defined: ' + msgUser[Tok[ErrTokenIndex].Value];

  UnknownIdentifier: Result := 'Identifier not found ''' + Tok[ErrTokenIndex].Name^ + '''';
 IncompatibleTypeOf: Result := 'Incompatible type of ' + Ident[IdentIndex].Name;
   IncompatibleEnum: if DstType < 0 then
   			Result := 'Incompatible types: got "'+GetEnumName(SrcType)+'" expected "'+InfoAboutToken(abs(DstType))+ '"'
		     else
   		     if SrcType < 0 then
   			Result := 'Incompatible types: got "'+InfoAboutToken(abs(SrcType))+'" expected "'+GetEnumName(DstType)+ '"'
		     else
   	   		Result := 'Incompatible types: got "'+GetEnumName(SrcType)+'" expected "'+GetEnumName(DstType)+ '"';

 WrongNumParameters: Result := 'Wrong number of parameters specified for call to ' + Ident[IdentIndex].Name;

       OParExpected: Result := '''(''' + ErrTokenFound(ErrTokenIndex);

  IllegalExpression: Result := 'Illegal expression';
   VariableExpected: Result := 'Variable identifier expected';
 OrdinalExpExpected: Result := 'Ordinal expression expected';
 OrdinalExpectedFOR: Result := 'Ordinal expression expected as ''FOR'' loop counter value';
  IncompatibleTypes: Result := 'Incompatible types: got "'+InfoAboutToken(SrcType)+'" expected "'+InfoAboutToken(DstType)+ '"';
 IdentifierExpected: Result := 'Identifier' + ErrTokenFound(ErrTokenIndex);
   IdNumExpExpected: Result := 'Identifier, number or expression' + ErrTokenFound(ErrTokenIndex);

	       LoHi: Result := 'lo/hi(dword/qword) returns the upper/lower word/dword';

     IllegalTypeConversion, IncompatibleTypesArray:
		     begin

		      if err = IllegalTypeConversion then
     		       Result := 'Illegal type conversion: "Array[0..'
		      else begin
		       Result := 'Incompatible types: got ';
		       if Ident[IdentIndex].NumAllocElements > 0 then Result := Result + '"Array[0..';
		      end;


     		      if Ident[IdentIndex].NumAllocElements_ > 0 then
		       Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements-1)+'] Of Array[0..'+IntToStr(Ident[IdentIndex].NumAllocElements_-1)+'] Of '+InfoAboutToken(Ident[IdentIndex].AllocElementType)+'" '
       		      else
		       if Ident[IdentIndex].NumAllocElements = 0 then begin

			if Ident[IdentIndex].AllocElementType <> UNTYPETOK then
			 Result := Result + '"^'+InfoAboutToken(Ident[IdentIndex].AllocElementType)+'" '
			else
			 Result := Result + '"'+InfoAboutToken(POINTERTOK)+'" ';

		       end else
			Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements-1)+'] Of '+InfoAboutToken(Ident[IdentIndex].AllocElementType)+'" ';

		      if err = IllegalTypeConversion then
		       Result := Result + 'to "'+InfoAboutToken(SrcType)+'"'
		      else
		       if SrcType < 0 then begin

       			Result := Result + 'expected "Array[0..';

			if Ident[abs(SrcType)].NumAllocElements_ > 0 then
			 Result := Result + IntToStr(Ident[abs(SrcType)].NumAllocElements-1)+'] Of Array[0..'+IntToStr(Ident[abs(SrcType)].NumAllocElements_-1)+'] Of '+InfoAboutToken(Ident[IdentIndex].AllocElementType)+'" '
       			else
			 Result := Result + IntToStr(Ident[abs(SrcType)].NumAllocElements-1)+'] Of '+InfoAboutToken(Ident[abs(SrcType)].AllocElementType)+'" ';

		       end else
			Result := Result + 'expected "'+InfoAboutToken(SrcType)+'"';

		     end;

	 AlwaysTrue: Result := 'Comparison might be always true due to range of constant and expression';

	AlwaysFalse: Result := 'Comparison might be always false due to range of constant and expression';

    RangeCheckError: begin
   		      Result := 'Range check error while evaluating constants ('+IntToStr(SrcType)+' must be between '+IntToStr(LowBound(ErrTokenIndex, DstType))+' and ';

		      if IdentIndex > 0 then
		       Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements-1)+')'
		      else
		       Result := Result + IntToStr(HighBound(ErrTokenIndex, DstType))+')';

		     end;

   RangeCheckError_: begin
		      Result := 'Range check error while evaluating constants ('+IntToStr(SrcType)+' must be between '+IntToStr(LowBound(ErrTokenIndex, DstType))+' and ';

		      if IdentIndex > 0 then
		       Result := Result + IntToStr(Ident[IdentIndex].NumAllocElements_-1)+')'
		      else
		       Result := Result + IntToStr(HighBound(ErrTokenIndex, DstType))+')';

		     end;

    VariableNotInit: Result := 'Variable '''+Ident[IdentIndex].Name+''' does not seem to be initialized';
  ShortStringLength: Result := 'String literal has more characters than short string length';
    StringTruncated: Result := 'String constant truncated to fit STRING['+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+']';
      CantReadWrite: Result := 'Can''t read or write variables of this type';
       TypeMismatch: Result := 'Type mismatch';
    UnreachableCode: Result := 'Unreachable code';
   IllegalQualifier: Result := 'Illegal qualifier';
     SubrangeBounds: Result := 'Constant expression violates subrange bounds';
  TooManyParameters: Result := 'Too many formal parameters in ' + Ident[IdentIndex].Name;
      CantDetermine: Result := 'Can''t determine which overloaded function '''+ Ident[IdentIndex].Name +''' to call';
  UpperBoundOfRange: Result := 'Upper bound of range is less than lower bound';
	  HighLimit: Result := 'High range limit > '+IntToStr(High(word));

 end;

end;


procedure iError(ErrTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0; SrcType: Int64 = 0; DstType: Int64 = 0);
var Msg: string;
begin

 if not isConst then begin

 WritelnMsg;

 Msg:=ErrorMessage(ErrTokenIndex, err, IdentIndex, SrcType, DstType);

 if ErrTokenIndex > NumTok then ErrTokenIndex := NumTok;
 WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) + ',' + IntToStr(Succ(Tok[ErrTokenIndex - 1].Column)) + ')'  + ' Error: ' + Msg);

 FreeTokens;

 CloseFile(OutFile);
 Erase(OutFile);

 Halt(2);

 end;

 isError := true;

end;


procedure Error(ErrTokenIndex: Integer; Msg: string);
begin

 if not isConst then begin

 WritelnMsg;

 if ErrTokenIndex > NumTok then ErrTokenIndex := NumTok;
 WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) + ',' + IntToStr(Succ(Tok[ErrTokenIndex - 1].Column)) + ')'  + ' Error: ' + Msg);

 FreeTokens;

 CloseFile(OutFile);
 Erase(OutFile);

 Halt(2);

 end;

 isError := true;

end;


procedure Warning(WarnTokenIndex: Integer; err: ErrorCode; IdentIndex: Integer = 0; SrcType: Int64 = 0; DstType: Int64 = 0);
var i: integer;
    Msg, a: string;
    Yes: Boolean;
begin

 if Pass = CODEGENERATIONPASS then begin

  Msg:=ErrorMessage(WarnTokenIndex, err, IdentIndex, SrcType, DstType);

  a := UnitName[Tok[WarnTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[WarnTokenIndex].Line) + ')' + ' Warning: ' + Msg;

  Yes := false;

  for i := High(msgWarning)-1 downto 0 do
   if msgWarning[i] = a then begin Yes:=true; Break end;

  if not Yes then begin
   i := High(msgWarning);
   msgWarning[i] := a;
   SetLength(msgWarning, i+2);
  end;

 end;

end;


procedure newMsg(var msg: TArrayString; var a: string);
var i: integer;
begin

    i:=High(msg);
    msg[i] := a;

    SetLength(msg, i+2);

end;


procedure Note(NoteTokenIndex: Integer; IdentIndex: Integer); overload;
var a: string;
begin

 if Pass = CODEGENERATIONPASS then
  if pos('.', Ident[IdentIndex].Name)=0 then begin

   a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) + ')' + ' Note: Local ';

   if Ident[IdentIndex].Kind <> UNITTYPE then begin

    case Ident[IdentIndex].Kind of
      CONSTANT: a := a + 'const';
      USERTYPE: a := a + 'type';
     LABELTYPE: a := a + 'label';

      VARIABLE: if Ident[IdentIndex].isAbsolute then
		 a := a + 'absolutevar'
		else
		 a := a + 'variable';

	  PROC: a := a + 'proc';
	  FUNC: a := a + 'func';
    end;

    a := a +' ''' + Ident[IdentIndex].Name + '''' + ' not used';

    newMsg(msgNote, a);

   end;

  end;

end;


procedure Note(NoteTokenIndex: Integer; Msg: string); overload;
var a: string;
begin

 if Pass = CODEGENERATIONPASS then begin

   a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) + ')' + ' Note: ';

   a := a + Msg;

   newMsg(msgNote, a);

 end;

end;


function GetStandardToken(S: TString): Integer;
var
  i: Integer;
begin
Result := 0;

if (S = 'LONGWORD') or (S = 'DWORD') or (S = 'UINT32') then S := 'CARDINAL' else
 if S = 'LONGINT' then S := 'INTEGER';

for i := 1 to MAXTOKENNAMES do
  if S = Spelling[i] then
    begin
    Result := i;
    Break;
    end;
end;


function GetIdentResult(ProcAsBlock: integer): integer;
var IdentIndex, BlockStackIndex: Integer;
begin

Result := 0;

for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Name = 'RESULT') and (Ident[IdentIndex].Block = ProcAsBlock) then begin

	Result := IdentIndex;
	exit;
      end;

end;


function GetLocalName(IdentIndex: integer; a: string =''): string;
begin

 if (Ident[IdentIndex].UnitIndex > 1) and (Ident[IdentIndex].UnitIndex <> UnitNameIndex) and Ident[IdentIndex].Section then
  Result := UnitName[Ident[IdentIndex].UnitIndex].Name + '.' + a + Ident[IdentIndex].Name
 else
  Result := a + Ident[IdentIndex].Name;

end;


procedure asm65(a: string; comment : string =''); forward;


function GetIdent(S: TString): Integer;
var TempIndex: integer;

  function UnitAllowedAccess(IdentIndex, Index: integer): Boolean;
  var i: integer;
  begin

   Result := false;

   if Ident[IdentIndex].Section then
    for i := 1 to MAXALLOWEDUNITS do
      if UnitName[Index].Allow[i] = UnitName[Ident[IdentIndex].UnitIndex].Name then begin Result := true; Break end;

  end;


  function Search(X: TString; UnitIndex: integer): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
    for IdentIndex := 1 to NumIdent do
      if (X = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
	if (Ident[IdentIndex].UnitIndex = UnitIndex) {or Ident[IdentIndex].Section} or (Ident[IdentIndex].UnitIndex = 1) or (UnitName[Ident[IdentIndex].UnitIndex].Name = 'SYSTEM') or UnitAllowedAccess(IdentIndex, UnitIndex) then begin
	  Result := IdentIndex;
	  Ident[IdentIndex].Pass := Pass;

	  if pos('.', X) > 0 then GetIdent(copy(X, 1, pos('.', X)-1));

	  if (Ident[IdentIndex].UnitIndex = UnitIndex) or (Ident[IdentIndex].UnitIndex = 1) or (UnitName[Ident[IdentIndex].UnitIndex].Name = 'SYSTEM') then exit;
	end

  end;


  function SearchCurrentUnit(X: TString; UnitIndex: integer): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
    for IdentIndex := 1 to NumIdent do
      if (X = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
	if (Ident[IdentIndex].UnitIndex = UnitIndex) or UnitAllowedAccess(IdentIndex, UnitIndex) then begin
	  Result := IdentIndex;
	  Ident[IdentIndex].Pass := Pass;

	  if pos('.', X) > 0 then GetIdent(copy(X, 1, pos('.', X)-1));

	  if (Ident[IdentIndex].UnitIndex = UnitIndex) then exit;
	end

  end;



begin

  Result := Search(S, UnitNameIndex);

  if (Result = 0) and (pos('.', S) > 0) then begin   // potencjalnie odwolanie do unitu / obiektu

    TempIndex := Search(copy(S, 1, pos('.', S)-1), UnitNameIndex);

//    writeln(S,',',Ident[TempIndex].Kind,' - ', Ident[TempIndex].DataType, ' / ',Ident[TempIndex].AllocElementType);

    if TempIndex > 0 then
     if (Ident[TempIndex].Kind = UNITTYPE) or (Ident[TempIndex].DataType = ENUMTYPE) then
       Result := SearchCurrentUnit(copy(S, pos('.', S)+1, length(S)), Ident[TempIndex].UnitIndex)
     else
      if Ident[TempIndex].DataType = OBJECTTOK then
       Result := SearchCurrentUnit(Types[Ident[TempIndex].NumAllocElements].Field[0].Name + copy(S, pos('.', S), length(S)), Ident[TempIndex].UnitIndex)
      ;{else
       if ( (Ident[TempIndex].DataType in Pointers) and (Ident[TempIndex].AllocElementType = RECORDTOK) ) then
	Result := TempIndex;}

  end;

end;


{
function GetField(i: integer; RecType: Byte; const S: TName): Integer;
var FieldIndex: Integer;
begin

 Result := 0;

 FieldIndex := 0;
 while (FieldIndex < High(Fields) ) and (Result = 0) do begin
  if Fields[FieldIndex].Name = S then Result := FieldIndex;
  Inc(FieldIndex);
 end;// while

 if Result = 0 then
   Error(i, 'Unknown identifier ''' + S + '''');
end;
}


function GetRecordField(i: integer; field: string): Byte;
var j: integer;
begin

 Result:=0;

 for j:=1 to Types[i].NumFields do
  if Types[i].Field[j].Name = field then begin Result:=Types[i].Field[j].DataType; Break end;

 if Result = 0 then
  Error(0, 'Record field not found');

end;


function GetIdentProc(S: TString; Param: TParamList; NumParams: integer): integer;
var IdentIndex, BlockStackIndex, i, k, b: Integer;
    cnt: byte;
    hits, m: word;
    best: array of record
		    IdentIndex, b: integer;
		    hit: word;
		   end;

const
    mask : array [0..15] of word = ($01,$02,$04,$08,$10,$20,$40,$80,$0100,$0200,$0400,$0800,$1000,$2000,$4000,$8000);

begin

Result := 0;

SetLength(best, 1);

for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK]) and
       (S = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) and
       (Ident[IdentIndex].NumParams = NumParams) then
      begin

      hits := 0;
      cnt:= 0;

      if Ident[IdentIndex].Name = 'TTT' then
       for i := 1 to NumParams do begin
        writeln(Ident[IdentIndex].Param[i].Name,',',Ident[IdentIndex].Param[i].DataType,',',Ident[IdentIndex].Param[i].AllocElementType ,' / ', Param[i].Name,',', Param[i].DataType,',',Param[i].AllocElementType  );
       end;

      for i := 1 to NumParams do
       if (
	  ( ((Ident[IdentIndex].Param[i].DataType in UnsignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and
	  (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

	  ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in SignedOrdinalTypes) ) and
	  (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

	  ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and	// smallint > byte
	  (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

	  (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) ) or

	  ( (Param[i].DataType in Pointers) and (Ident[IdentIndex].Param[i].DataType = Param[i].AllocElementType) ) or		// dla parametru VAR

	  ( (Ident[IdentIndex].Param[i].DataType = UNTYPETOK) and (Ident[IdentIndex].Param[i].PassMethod = VARPASSING) and (Param[i].DataType in IntegerTypes + [CHARTOK]) )

	 then begin

	   hits := hits or mask[cnt];		  // z grubsza spelnia warunek
	   inc(cnt);

	   if (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) then begin   // dodatkowe punkty jesli idealnie spelnia warunek
	     hits := hits or mask[cnt];
	     inc(cnt);
	   end;

	 end;

	k:=High(best);

	best[k].IdentIndex := IdentIndex;
	best[k].hit	   := hits;
	best[k].b	   := Ident[IdentIndex].Block;

	SetLength(best, k+2);
      end;

  end;// for

 m:=0;
 b:=0;

 if High(best) = 1 then
  Result := best[0].IdentIndex
 else
  for i := 0 to High(best) - 1 do
   if (best[i].hit > m) and (best[i].b >= b) then begin m := best[i].hit; b := best[i].b; Result := best[i].IdentIndex end;

 SetLength(best, 0);

end;


procedure TestIdentProc(x: integer; S: TString);
var IdentIndex, BlockStackIndex: Integer;
    k, m: integer;
    ok: Boolean;

    ov: array of record
		  i,j,u,b: integer;
	end;

    l: array of record
		  u,b: integer;
		  Param: TParamList;
		  NumParams: word;
       end;


procedure addOverlay(UnitIndex, Block: integer; ovr: Boolean);
var i: integer;
    yes: Boolean;
begin

 yes:=true;

 for i:=High(ov)-1 downto 0 do
  if (ov[i].u = UnitIndex) and (ov[i].b = Block) then begin
   inc(ov[i].i, ord(ovr));
   inc(ov[i].j);

   yes:=false;
   Break;
  end;

 if yes then begin
  i:=High(ov);

  ov[i].u := UnitIndex;
  ov[i].b := Block;
  ov[i].i := ord(ovr);
  ov[i].j := 1;

  SetLength(ov, i+2);
 end;

end;


begin

SetLength(ov, 1);
SetLength(l, 1);

for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK]) and
       (S = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
    begin

     for k := 0 to High(l)-1 do
      if (Ident[IdentIndex].NumParams = l[k].NumParams) and (Ident[IdentIndex].UnitIndex = l[k].u) and (Ident[IdentIndex].Block = l[k].b)  then begin

       ok := true;

       for m := 1 to l[k].NumParams do
	if (Ident[IdentIndex].Param[m].DataType <> l[k].Param[m].DataType) then begin ok := false; Break end;

       if ok then
	Error(x, 'Overloaded functions ''' + Ident[IdentIndex].Name + ''' have the same parameter list');

      end;

     k:=High(l);

     l[k].NumParams := Ident[IdentIndex].NumParams;
     l[k].Param     := Ident[IdentIndex].Param;
     l[k].u	    := Ident[IdentIndex].UnitIndex;
     l[k].b	    := Ident[IdentIndex].Block;

     SetLength(l, k+2);

     addOverlay(Ident[IdentIndex].UnitIndex, Ident[IdentIndex].Block, Ident[IdentIndex].isOverload);
    end;

  end;// for

 for i:=0 to High(ov)-1 do
  if ov[i].j > 1 then
   if ov[i].i <> ov[i].j then
    Error(x, 'Not all declarations of '+Ident[NumIdent].Name+' are declared with OVERLOAD');

 SetLength(l, 0);
 SetLength(ov, 0);
end;


procedure omin_spacje (var i:integer; var a:string);
(*----------------------------------------------------------------------------*)
(*  omijamy tzw. "biale spacje" czyli spacje, tabulatory		      *)
(*----------------------------------------------------------------------------*)
begin

 if a<>'' then
  while (i<=length(a)) and (a[i] in AllowWhiteSpaces) do inc(i);

end;


function get_digit(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobierz ciag zaczynajaca sie znakami '0'..'9','%','$'		     *)
(*----------------------------------------------------------------------------*)
begin
 Result:='';

 if a<>'' then begin

  omin_spacje(i,a);

  if UpCase(a[i]) in AllowDigitFirstChars then begin

   Result:=UpCase(a[i]);
   inc(i);

   while UpCase(a[i]) in AllowDigitChars do begin Result:=Result+UpCase(a[i]); inc(i) end;

  end;

 end;

end;


function get_label(var i:integer; var a:string; up: Boolean = true): string;
(*----------------------------------------------------------------------------*)
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_'		     *)
(*----------------------------------------------------------------------------*)
begin
 Result:='';

 if a<>'' then begin

  omin_spacje(i,a);

  if UpCase(a[i]) in AllowLabelFirstChars then
   while UpCase(a[i]) in AllowLabelChars + AllowDirectorySeparators do begin

    if up then
     Result:=Result+UpCase(a[i])
    else
     Result:=Result + a[i];

    inc(i);
   end;

 end;

end;


function get_string(var i:integer; var a:string; up: Boolean = true): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag znakow, ograniczony znakami '' lub ""			*)
(*  podwojny '' oznacza literalne '					   *)
(*  podwojny "" oznacza literalne "					   *)
(*----------------------------------------------------------------------------*)
var len: integer;
    znak, gchr: char;
begin
 Result:='';

 omin_spacje(i,a);

 if a[i] = '%' then begin

   while UpCase(a[i]) in ['A'..'Z','%'] do begin Result:=Result + Upcase(a[i]); inc(i) end;

 end else
 if not(a[i] in AllowQuotes) then begin

  Result := get_label(i, a, up);

 end else begin

  gchr:=a[i]; len:=length(a);

  while i<=len do begin
   inc(i);	 // omijamy pierwszy znak ' lub "

   znak:=a[i];

   if znak=gchr then begin inc(i); Break end;
{    inc(i);
    if a[i]=gchr then znak:=gchr;
   end;}

   Result:=Result+znak;
  end;

 end;

end;


procedure AddResource(fnam: string);
var i, j: integer;
    t: textfile;
    res: TResource;
    s, tmp: string;
begin

 AssignFile(t, fnam); FileMode:=0; Reset(t);

  while not eof(t) do begin

    readln(t, s);

    i:=1;
    omin_spacje(i, s);

    if (length(s) > i-1) and (not (s[i] in ['#',';'])) then begin

     res.resName := get_label(i, s);
     res.resType := get_label(i, s);
     res.resFile := get_string(i, s, false);  // nie zmieniaj wielkosci liter

     for j := 1 to MAXPARAMS do begin

      if s[i] in ['''','"'] then
       tmp := get_string(i, s)
      else
       tmp := get_digit(i, s);

      if tmp = '' then tmp:='0';

      res.resPar[j]  := tmp;
     end;

//     writeln(res.resName,',',res.resType,',',res.resFile);

     for j := High(resArray)-1 downto 0 do
      if resArray[j].resName = res.resName then
       Error(NumTok, 'Duplicate resource: Type = '+res.resType+', Name = '+res.resName);

     j:=High(resArray);
     resArray[j] := res;

     SetLength(resArray, j+2);

    end;

  end;

 CloseFile(t);

end;


procedure AddToken(Kind: Byte; UnitIndex, Line, Column: Integer; Value: Int64);
begin

 Inc(NumTok);

 if NumTok > High(Tok) then
  SetLength(Tok, NumTok+1);

// if NumTok > MAXTOKENS then
//    Error(NumTok, 'Out of resources, TOK');

 Tok[NumTok].UnitIndex := UnitIndex;
 Tok[NumTok].Kind := Kind;
 Tok[NumTok].Value := Value;

 if NumTok = 1 then
  Column := 1
 else begin

  if Tok[NumTok - 1].Line <> Line then
//   Column := 1
  else
    Column := Column + Tok[NumTok - 1].Column;

 end;

// if Tok[NumTok- 1].Line <> Line then writeln;

 Tok[NumTok].Line := Line;
 Tok[NumTok].Column := Column;

 //if line=46 then  writeln(Kind,',',Column);

end;


function Elements(IdentIndex: integer): cardinal;
begin

 if Ident[IdentIndex].DataType = ENUMTYPE then
  Result := 0
 else

 if (Ident[IdentIndex].NumAllocElements_ = 0) or (Ident[IdentIndex].AllocElementType in [RECORDTOK,OBJECTTOK]) then
  Result := Ident[IdentIndex].NumAllocElements
 else
  Result := Ident[IdentIndex].NumAllocElements * Ident[IdentIndex].NumAllocElements_;

end;


procedure DefineIdent(ErrTokenIndex: Integer; Name: TString; Kind: Byte; DataType: Byte; NumAllocElements: Cardinal; AllocElementType: Byte; Data: Int64; IdType: Byte = IDENTTOK);
var
  i: Integer;
  NumAllocElements_ : Cardinal;
begin

i := GetIdent(Name);

if (i > 0) and (not (Ident[i].Kind in [PROCEDURETOK, FUNCTIONTOK])) and (Ident[i].Block = BlockStack[BlockStackTop]) and (Ident[i].isOverload = false) and (Ident[i].UnitIndex = UnitNameIndex) then
  Error(ErrTokenIndex, 'Identifier ' + Name + ' is already defined')
else
  begin

  Inc(NumIdent);

  if NumIdent > High(Ident) then
    Error(NumTok, 'Out of resources, IDENT');

  Ident[NumIdent].Name := Name;
  Ident[NumIdent].Kind := Kind;
  Ident[NumIdent].DataType := DataType;
  Ident[NumIdent].Block := BlockStack[BlockStackTop];
  Ident[NumIdent].NumParams := 0;
  Ident[NumIdent].isAbsolute := false;
  Ident[NumIdent].PassMethod := VALPASSING;
  Ident[NumIdent].IsUnresolvedForward := false;

  Ident[NumIdent].Section := PublicSection;

  Ident[NumIdent].UnitIndex := UnitNameIndex;

  Ident[NumIdent].IdType := IdType;

  if (Kind = VARIABLE) and (Data <> 0) then begin
   Ident[NumIdent].isAbsolute := true;
   Ident[NumIdent].isInit := true;
  end;

  NumAllocElements_ := NumAllocElements shr 16;		// , yy]
  NumAllocElements  := NumAllocElements and $FFFF;	// [xx,

  if (NumIdent > NumPredefIdent + 1) and (UnitNameIndex = 1) and (Pass = CODEGENERATIONPASS) then
    if not ( (Ident[NumIdent].Pass in [CALLDETERMPASS , CODEGENERATIONPASS]) or (Ident[NumIdent].IsNotDead) ) then
      Note(ErrTokenIndex, NumIdent);

  case Kind of

    PROC, FUNC, UNITTYPE:
      begin
      Ident[NumIdent].Value := CodeSize;			// Procedure entry point address
//      Ident[NumIdent].Section := true;
      end;

    VARIABLE:
      begin

      if Ident[NumIdent].isAbsolute then
       Ident[NumIdent].Value := Data - 1
      else
       Ident[NumIdent].Value := DATAORIGIN + VarDataSize;	// Variable address

      if not OutputDisabled then
	VarDataSize := VarDataSize + DataSize[DataType];

      Ident[NumIdent].NumAllocElements := NumAllocElements;	// Number of array elements (0 for single variable)
      Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

      Ident[NumIdent].AllocElementType := AllocElementType;

      if not OutputDisabled then begin

       if (DataType in [RECORDTOK, OBJECTTOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 0
       else
       if (DataType = FILETOK) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 12
       else
	VarDataSize := VarDataSize + integer(Elements(NumIdent) * DataSize[AllocElementType]);

       if NumAllocElements > 0 then dec(VarDataSize, DataSize[DataType]);

      end;

      end;

    CONSTANT, ENUMTYPE:
      begin
      Ident[NumIdent].Value := Data;				// Constant value

      if DataType in Pointers then begin
       Ident[NumIdent].NumAllocElements := NumAllocElements;
       Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

       Ident[NumIdent].AllocElementType := AllocElementType;
      end;

      Ident[NumIdent].isInit := true;
      end;

    USERTYPE:
      begin
       Ident[NumIdent].NumAllocElements := NumAllocElements;
       Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

       Ident[NumIdent].AllocElementType := AllocElementType;
      end;

    LABELTYPE:
      begin
       Ident[NumIdent].isInit := false;
      end;

  end;// case
  end;// else
end;



procedure DefineStaticString(StrTokenIndex: Integer; StrValue: TString);
var
  i, j, k: Integer;
  yes: Boolean;

  Data: array [0..MAXSTRLENGTH + 1] of Word;
begin

Fillchar(Data, sizeof(Data), 0);

Data[0]:=Length(StrValue);
for i:=1 to Data[0] do Data[i] := ord(StrValue[i]);

i:=0;
j:=0;
yes:=false;

while (i < NumStaticStrChars) and (yes=false) do begin

 j:=0;
 k:=i;
 while (Data[j] = StaticStringData[k+j]) and (j < Data[0]+2) and (k+j < NumStaticStrChars) do inc(j);

 if j = Data[0]+2 then begin yes:=true; Break end;

 inc(i);
end;

Tok[StrTokenIndex].StrLength := Data[0];

if yes then begin
 Tok[StrTokenIndex].StrAddress := CODEORIGIN + i;
 exit;
end;

Tok[StrTokenIndex].StrAddress := CODEORIGIN + NumStaticStrChars;

StaticStringData[NumStaticStrChars] := length(StrValue);
Inc(NumStaticStrChars);

for i := 1 to Length(StrValue) do
  begin
  StaticStringData[NumStaticStrChars] := ord(StrValue[i]);
  Inc(NumStaticStrChars);
  end;

StaticStringData[NumStaticStrChars] := 0;
Inc(NumStaticStrChars);

end;


procedure CheckOperator(ErrTokenIndex: Integer; op: Byte; DataType: Byte; RightType: Byte = 0);
begin

//writeln(tok[ErrTokenIndex].Name^,',', op,',',datatype);

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
       not (op in [GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK]))
then
  Error(ErrTokenIndex, 'Operator is not overloaded: ' + '"' + InfoAboutToken(DataType) + '" ' + InfoAboutToken(op) + ' "' + InfoAboutToken(RightType) + '"');

end;


function GetCommonConstType(ErrTokenIndex: Integer; DstType, SrcType: Byte; err: Boolean = true): Boolean;
begin

  Result := false;

  if (DataSize[DstType] < DataSize[SrcType]) or
     ( (DstType = REALTOK) and (SrcType <> REALTOK) ) or
     ( (DstType <> REALTOK) and (SrcType = REALTOK) ) or

     ( (DstType = SINGLETOK) and (SrcType <> SINGLETOK) ) or
     ( (DstType <> SINGLETOK) and (SrcType = SINGLETOK) ) or

     ( (DstType = SHORTREALTOK) and (SrcType <> SHORTREALTOK) ) or
     ( (DstType <> SHORTREALTOK) and (SrcType = SHORTREALTOK) ) or

     ( (DstType in IntegerTypes) and (SrcType in [CHARTOK, BOOLEANTOK, POINTERTOK, DATAORIGINOFFSET, CODEORIGINOFFSET, STRINGPOINTERTOK]) ) or
     ( (SrcType in IntegerTypes) and (DstType in [CHARTOK, BOOLEANTOK]) ) then

     if err then
      iError(ErrTokenIndex, IncompatibleTypes, 0, SrcType, DstType)
     else
      Result := true;

end;


function GetCommonType(ErrTokenIndex: Integer; LeftType, RightType: Byte): Byte;
begin

 Result := 0;

 if LeftType = RightType then		 // General rule

  Result := LeftType

 else
  if (LeftType in IntegerTypes) and (RightType in IntegerTypes) then
    Result := LeftType;

  if (LeftType in Pointers) and (RightType in Pointers) then
    Result := LeftType;

 if LeftType = UNTYPETOK then Result := RightType;

// if LeftType in Pointers then Result :in Pointers;

 if Result = 0 then
   iError(ErrTokenIndex, IncompatibleTypes, 0, RightType, LeftType);

end;


procedure AddCallGraphChild(ParentBlock, ChildBlock: Integer);
begin

 if ParentBlock <> ChildBlock then begin

  Inc(CallGraph[ParentBlock].NumChildren);
  CallGraph[ParentBlock].ChildBlock[CallGraph[ParentBlock].NumChildren] := ChildBlock;

 end;

end;


procedure SaveAsmBlock(a: char);
begin

 AsmBlock[AsmBlockIndex]:=AsmBlock[AsmBlockIndex] + a;

end;


function GetVAL(a: string): integer;
var err: integer;
begin

 Result := -1;

 if a<>'' then
  if a[1] = '#' then begin
   val(copy(a, 2, length(a)), Result, err);

   if err > 0 then Result := -1;

  end;
{
 if (a = '#$00') then Result:=0 else
  if (a = '#$01') then Result:=1 else
   if (a = '#$02') then Result:=2 else
    if (a = '#$03') then Result:=3 else
     if (a = '#$04') then Result:=4 else
      if (a = '#$05') then Result:=5 else
       if (a = '#$06') then Result:=6 else
	if (a = '#$07') then Result:=7 else
	 if (a = '#$08') then Result:=8 else
	  if (a = '#$10') then Result:=16 else
	   if (a = '#$18') then Result:=24 else
	    Result := -1;
}
end;


procedure ResetOpty;
begin

 optyA := '';
 optyY := '';
 optyBP2 := '';

end;


procedure OptimizeASM;
(* -------------------------------------------------------------------------- *)
(* optymalizacja powiodla sie jesli na wyjsciu X=0
(* peephole optimization
(* -------------------------------------------------------------------------- *)
type
    TListing = array [0..4095] of string;

var i, l, k, m: integer;
    x: integer;
    a, t, arg, arg0, arg1: string;
    inxUse, ifTmp: Boolean;
    t0, t1, t2, t3: string;
    listing, listing_tmp: TListing;
    cnt: array [0..7, 0..3] of integer;
    s: array [0..15,0..3] of string;

// -----------------------------------------------------------------------------

   function ADD_SUB_STACK(i: integer): Boolean;
   begin
     Result := (pos('add :STACK', listing[i]) > 0) or (pos('sub :STACK', listing[i]) > 0);
   end;

   function ADD_SUB(i: integer): Boolean;
   begin
     Result := (pos('add ', listing[i]) > 0) or (pos('sub ', listing[i]) > 0);
   end;

   function ADC_SBC_STACK(i: integer): Boolean;
   begin
     Result := (pos('adc :STACK', listing[i]) > 0) or (pos('sbc :STACK', listing[i]) > 0);
   end;

   function ADC_SBC(i: integer): Boolean;
   begin
     Result := (pos('adc ', listing[i]) > 0) or (pos('sbc ', listing[i]) > 0);
   end;

   function AND_ORA_EOR_STACK(i: integer): Boolean;
   begin
     Result := (pos('and :STACK', listing[i]) > 0) or (pos('ora :STACK', listing[i]) > 0) or (pos('eor :STACK', listing[i]) > 0);
   end;

   function AND_ORA_EOR(i: integer): Boolean;
   begin
     Result := (pos('and ', listing[i]) > 0) or (pos('ora ', listing[i]) > 0) or (pos('eor ', listing[i]) > 0);
   end;

   function SKIP(i: integer): Boolean;
   begin

     if i<0 then
      Result:=False
     else
      Result :=	(listing[i] = #9'seq') or (listing[i] = #9'sne') or
		(listing[i] = #9'spl') or (listing[i] = #9'smi') or
		(listing[i] = #9'scc') or (listing[i] = #9'scs') or
		(pos('bne ', listing[i]) > 0) or (pos('beq ', listing[i]) > 0) or
		(pos('bcc ', listing[i]) > 0) or (pos('bcs ', listing[i]) > 0) or
		(pos('bmi ', listing[i]) > 0) or (pos('bpl ', listing[i]) > 0);
   end;


// -----------------------------------------------------------------------------

   procedure Rebuild;
   var k, i, n: integer;
       s: string;
   begin

    for i:=0 to High(listing_tmp)-1 do listing_tmp[i] := '';

    k:=0;
    for i := 0 to l - 1 do
     if (listing[i] <> '') and (listing[i][1] <> ';') then begin

      s:='';
      n:=1;
      while n <= length(listing[i]) do begin

       if not(listing[i][n] in [#13, #10]) then
	s:=s + listing[i][n];

       if listing[i][n] = #13 then begin
	listing_tmp[k] := s;
	inc(k);

	s:='';
       end;

       inc(n);
      end;

      if s<>'' then begin
       listing_tmp[k] := s;
       inc(k);
      end;

     end;

    listing := listing_tmp;

    l := k;
   end;


   procedure Clear;
   var i, k: integer;
   begin

    for i := 0 to High(s) do
     for k := 0 to 3 do s[i][k] := '';

    fillchar(cnt, sizeof(cnt), 0);

   end;


   function GetString(a:string): string;
   var i: integer;
   begin

    Result := '';
    i:=6;

    if a<>'' then
     while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
      Result := Result + a[i];
      inc(i);
     end;

   end;


  function GetARG(n: byte; x: shortint; reset: Boolean = true): string;
  var i: integer;
      a: string;
  begin

   Result:='';

   if x < 0 then exit;

   a := s[x][n];

   if (a='') then begin

    case n of
     0: Result := ':STACKORIGIN+'+IntToStr(shortint(x+8));
     1: Result := ':STACKORIGIN+STACKWIDTH+'+IntToStr(shortint(x+8));
     2: Result := ':STACKORIGIN+STACKWIDTH*2+'+IntToStr(shortint(x+8));
     3: Result := ':STACKORIGIN+STACKWIDTH*3+'+IntToStr(shortint(x+8));
    end;

   end else begin

    i := 6;

    while a[i] in [' ',#9] do inc(i);

    while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
     Result := Result + a[i];
     inc(i);
    end;

    if reset and (not ifTmp) then s[x][n] := '';

   end;

  end;


  function Num(i: integer): integer;
  var j, k: integer;
  begin

    Result := 0;
    arg:='';

    for j := 0 to 6 do
     for k := 0 to 3 do
      if pos(GetARG(k, j, false), listing[i]) > 0 then begin
       arg:=GetARG(k, j, false);
       Result := cnt[j, k];
       Break;
      end;

  end;


  procedure RemoveUnusedSTACK;
  type
      TStackBuf = record
		   name: string;
		   line: integer;
		  end;

  var i,j,k: integer;
      stackBuf: array of TStackBuf;
      yes: Boolean;


      procedure Remove(i: integer);
      var k: integer;
      begin

	listing[i] := '';

	if (listing[i-1] = #9'rol @') then begin
	 listing[i-1] := '';

	 for k := i-1 downto 0 do begin

	  if (pos('lda #$00', listing[k]) > 0) then begin
	   listing[k] := '';

	   if (pos('adc #$00', listing[k+1]) > 0) or (pos('sbc #$00', listing[k+1]) > 0) then listing[k+1] := '';

	   Break;
	  end;

	  if (pos('rol @', listing[k]) > 0) then listing[k] := '';
	 end;

	end;

      end;


  begin
 // szukamy pojedynczych odwolan do :STACKORIGIN+N

  Rebuild;

  Clear;

  SetLength(stackBuf, 1);

  for i := 0 to l - 1 do	       // zliczamy odwolania do :STACKORIGIN+N
   for j := 0 to 6 do
    for k := 0 to 3 do
     if pos(GetARG(k, j, false), listing[i]) > 0 then inc( cnt[j, k] );


//  for i := 0 to l - 1 do
//   if Num(i) <> 0 then listing[i] := listing[i] + #9'; '+IntToStr( Num(i) );


  for i := 1 to l - 1 do begin

   if (pos('sta :STACK', listing[i]) > 0) or (pos('sty :STACK', listing[i]) > 0) then begin

    yes:=true;
    for j:=0 to High(stackBuf)-1 do
      if stackBuf[j].name = listing[i] then begin

       Remove(stackBuf[j].line);	// usun dotychczasowe odwolanie

       stackBuf[j].line := i;		// nadpisz nowym

       yes:=false;
       Break;
      end;

    if yes then begin		// dodaj nowy wpis
     k:=High(stackBuf);
     stackBuf[k].name := listing[i];
     stackBuf[k].line := i;
     SetLength(stackBuf, k+2);
    end;

   end;


   if ((pos('sta :STACK', listing[i]) = 0) and (pos('sty :STACK', listing[i]) = 0)) and
      (pos(' :STACK', listing[i]) > 0) then
   begin

    for j:=0 to High(stackBuf)-1 do	// odwolania inne niz STA|STY resetuja wpisy
      if copy(stackBuf[j].name, 6, 256) = copy(listing[i], 6, 256) then begin
       stackBuf[j].name := '';		// usun wpis
       Break;
      end;

   end;


  if Num(i) = 1 then
   if (listing[i-1] = #9'rol @') then

    Remove(i)			// pojedyncze odwolanie do :STACKORIGIN+N jest eliminowane

   else begin

    a := listing[i];		// zamieniamy na 'illegal instruction'
    k:=pos(' :STACK', a);
    delete(a, k, length(a));
    insert(' #$00', a, k);

    if (pos('ldy #$00', a) > 0) or (pos('lda #$00', a) > 0) then
     listing[i] := ''
    else
     listing[i] := a;

   end;

  end;    // for

   Rebuild;

   SetLength(stackBuf, 0);

   end;


 function OptimizeStack: Boolean;
 var i, p, q: integer;
     tmp: string;
 begin

  Result := true;

  Rebuild;

  tmp:='';

  for i := 0 to l - 1 do begin

   if (pos('jsr ', listing[i])  > 0) or (pos('cmp ', listing[i]) > 0) or
      (pos('bne ', listing[i]) > 0) or (pos('beq ', listing[i]) > 0) or
      (pos('bcc ', listing[i]) > 0) or (pos('bcs ', listing[i]) > 0) or
      (pos('bmi ', listing[i]) > 0) or (pos('bpl ', listing[i]) > 0) or
      (listing[i] = #9'spl') or (listing[i] = #9'smi') or
      (listing[i] = #9'seq') or (listing[i] = #9'sne') then Break;

   if (pos('mwa ', listing[i]) > 0) and (pos(' :bp2', listing[i]) > 0) then
    if tmp = listing[i] then
     listing[i] := ''
    else
     tmp := listing[i];

  end;

  Rebuild;

  for i := 0 to l - 1 do begin

    if (listing[i] <> '' ) and (listing[i][1] = ';') and (listing[i][2] <> TAB) then begin
     Result := false;
    end;


    if (listing[i] = #9'dex') and (listing[i+1] = #9'inx') then					// dex
     begin											// inx
       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and (listing[i+1] = #9'dex') then					// inx
     begin											// dex
       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos('lda :STACK', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) then	// lda :STACKORIGIN+9
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin			// sta :STACKORIGIN+9
       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos('mva ', listing[i]) > 0) and (listing[i-1] = #9'inx') and				// mva A	; -2
       (pos('mva ', listing[i-2]) > 0) then							// inx		; -1
     if listing[i] = listing[i-2] then begin							// mva A	; 0
       listing[i] := #9'sta ' + copy(listing[i], pos(':STACK', listing[i]), 256);		// inx		; 1
       if (listing[i+1] = #9'inx') and (listing[i-2] = listing[i+2]) then			// mva A	; 2
	listing[i+2] := #9'sta ' + copy(listing[i+2], pos(':STACK', listing[i+2]), 256);

       Result:=false;
     end;


    if (pos('mva ', listing[i]) > 0) and 							// mva aa :STACKORIGIN,x		; 0
       (listing[i+1] = #9'ldy #1') and								// ldy #1				; 1
       (listing[i+2] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 2
       (listing[i+3] = #9'cmp :STACKORIGIN,x') then						// cmp :STACKORIGIN,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+3] := #9'cmp ' + copy(listing[i], 6, pos(':STACK', listing[i])-7 );
       listing[i]   := '';

       Result:=false;
     end;


    if (pos('mva ', listing[i]) > 0) and 							// mva aa :STACKORIGIN,x		; 0
       (listing[i+1] = #9'inx') and								// inx					; 1
       (listing[i+2] = #9'ldy #1') and								// ldy #1				; 2
       (listing[i+3] = #9'lda :STACKORIGIN-1,x') then						// lda :STACKORIGIN-1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+3] := #9'lda ' + copy(listing[i], 6, pos(':STACK', listing[i])-7 );
       listing[i]   := '';

       Result:=false;
     end;


    if (pos('mva ', listing[i]) > 0) and 							// mva aa :STACKORIGIN,x		; 0
       (listing[i+1] = #9'jsr andAL_CL') and							// jst andAL_CL				; 1
       (listing[i+2] = #9'ldy #1') and								// ldy #1				; 2
       (listing[i+3] = #9'lda :STACKORIGIN-1,x') then						// lda :STACKORIGIN-1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+1] := listing[i+2];
       listing[i+2] := listing[i+3];

       listing[i+3] := #9'and ' + copy(listing[i], 6, pos(':STACK', listing[i])-7 );
       listing[i]   := '';

       Result:=false;
     end;


    if (listing[i] = #9'cmp #$00') and								// cmp #$00				; 0
       (listing[i+1] = #9'bne @+') and								// bne @+				; 1
       (listing[i+2] = #9'dey') and								// lda :STACKORIGIN-1,x			; 2
       (listing[i+3] = '@') and									// @					; 3
       (pos('sty :STACK', listing[i+4]) > 0) then						// sty :STACK				; 4
     begin
       listing[i] := '';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva aa :STACKORIGIN,x		; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('add :STACK', listing[i+4]) > 0) and		// mva bb :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+5] = #9'tay') and								// lda					; 3
       (pos('lda ', listing[i+6]) > 0) and (pos('adc :STACK', listing[i+7]) > 0) and		// add :STACKORIGIN,x			; 4
       (listing[i+8] = #9'sta :bp+1') and							// tay					; 5
       (listing[i+9] = #9'lda (:bp),y') then							// lda					; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// adc :STACKORIGIN+STACKWIDTH,x	; 7
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and						// sta :bp+1				; 8
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and				// lda (:bp),y				; 9
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin
       listing[i+4]  := #9'add ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+7]  := #9'adc ' + copy(listing[i+2], 6, pos(':STACK', listing[i+2])-6 );

       listing[i+1] := '';
       listing[i+2] := '';

       if pos('adc #$00', listing[i+7]) > 0 then
	if copy(listing[i+3], 6, 256)+'+1' = copy(listing[i+6], 6, 256) then begin
	 listing[i+3] := #9'mwa ' + copy(listing[i+3], 6, 256) + ' :bp2';
	 listing[i+4] := #9'ldy ' + copy(listing[i+4], 6, 256);
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda (:bp2),y';
	end;

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva aa :STACKORIGIN,x		; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('add :STACK', listing[i+4]) > 0) and		// mva bb :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('sta ', listing[i+5]) > 0) and							// lda					; 3
       (pos('lda ', listing[i+6]) > 0) and (pos('adc :STACK', listing[i+7]) > 0) and		// add :STACKORIGIN,x			; 4
       (pos('sta ', listing[i+8]) > 0) then							// sta					; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// lda					; 6
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and						// adc :STACKORIGIN+STACKWIDTH,x	; 7
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and				// sta					; 8
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin
       listing[i+4]  := #9'add ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+7]  := #9'adc ' + copy(listing[i+2], 6, pos(':STACK', listing[i+2])-6 );

       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva aa :STACKORIGIN,x		; 1
       (pos('sta :STACK', listing[i+3]) > 0) and (pos('sta :STACK', listing[i+4]) > 0) and	// mva bb :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('lda :STACK', listing[i+5]) > 0) and (pos('lda :STACK', listing[i+7]) > 0) and	// sta :STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('lda :STACK', listing[i+9]) > 0) and (pos('lda :STACK', listing[i+11]) > 0) and	// sta :STACKORIGIN+STACKWIDTH*3,x	; 4
       (listing[i+6] = #9'sta :ecx') and (listing[i+8] = #9'sta :ecx+1') and			// lda :STACKORIGIN,x			; 5
       (listing[i+10] = #9'sta :ecx+2') and (listing[i+12] = #9'sta :ecx+3') then		// sta :ecx				; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// lda :STACKORIGIN+STACKWIDTH,x	; 7
	(pos(':STACKORIGIN,x', listing[i+5]) > 0) and						// sta :ecx+1				; 8
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and				// lda :STACKORIGIN+STACKWIDTH*2,	; 9
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) and				// sta :ecx+2				; 10
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 11
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+9]) > 0) and				// sta :ecx+3				; 12
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+11]) > 0) then
     begin
       listing[i+7]  := listing[i+2];
       listing[i+8]  := listing[i+3];
       listing[i+9]  := listing[i+4];
       listing[i+10] := #9'sta :ecx+1';
       listing[i+11] := #9'sta :ecx+2';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// mva xx :STACKORIGIN,x		; 1
       (pos('ldy :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) > 0) then		// ldy :STACKORIGIN,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y :STACKORIGIN,x		; 4
	(pos(':STACKORIGIN,x', listing[i+3]) > 0) and						// mva adr.__,y :STACKORIGIN+STACKWIDTH,x; 5
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva xx :STACKORIGIN,x		; 1
       (pos('ldy :STACK', listing[i+3]) > 0) and						// mva yy :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) > 0) then		// ldy :STACKORIGIN,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y :STACKORIGIN,x		; 4
	(pos(':STACKORIGIN,x', listing[i+3]) > 0) and						// mva adr.__,y :STACKORIGIN+STACKWIDTH,x; 5
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and 							// mva xx :STACKORIGIN,x		; 1
       (pos('ldy :STACK', listing[i+2]) > 0) and						// ldy :STACKORIGIN,x			; 2
       (pos('mva adr.', listing[i+3]) > 0) and (pos('mva adr.', listing[i+4]) = 0) then		// mva adr.__,y :STACKORIGIN,x		; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+3]) > 0) then
     begin
       listing[i+2] := #9'ldy ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// mva xx :STACKORIGIN,x		; 1
       (pos('ldy :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) = 0) then		// ldy :STACKORIGIN,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y :STACKORIGIN,x		; 4
	(pos(':STACKORIGIN,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva xx :STACKORIGIN,x		; 1
       (pos('ldy :STACK', listing[i+3]) > 0) and						// mva yy :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) = 0) then		// ldy :STACKORIGIN,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y :STACKORIGIN,x		; 4
	(pos(':STACKORIGIN,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('ldy ', listing[i+1]) > 0) and 							// ldy 					; 1
       (pos('mva adr.', listing[i+2]) > 0) and							// mva adr.	.STACKORIGIN,x		; 2
       (listing[i+3] = #9'inx') and								// inx					; 3
       (pos('ldy ', listing[i+4]) > 0) and 							// ldy 					; 4
       (pos('mva adr.', listing[i+5]) > 0) then							// mva adr.	.STACKORIGIN,x		; 5
     if (listing[i+1] = listing[i+4]) and
	(pos(':STACKORIGIN,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+5]) > 0) then
     begin
       listing[i+4] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva xx :STACKORIGIN,x		; 1
       (pos('mva ', listing[i+3]) > 0) and (pos('mva ', listing[i+4]) > 0) and			// mva yy :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('ldy :STACK', listing[i+5]) > 0) and						// mva zz :STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('mva adr.', listing[i+6]) > 0) and (pos('mva adr.', listing[i+7]) = 0) then		// mva qq :STACKORIGIN+STACKWIDTH*3,x	; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and						// ldy :STACKORIGIN,x			; 5
     	(pos(':STACKORIGIN,x', listing[i+5]) > 0) and						// mva adr.__,y :STACKORIGIN,x		; 6
	(pos(':STACKORIGIN,x', listing[i+6]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # :STACKORIGIN,x			; 1
       (listing[i+2] = #9'inx') and								// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # :STACKORIGIN,x			; 3
       (listing[i+4] = #9'jsr subAL_CL') then							// jsr subAL_CL				; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+3]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4));
       q := GetVAL(copy(listing[i+3], 6, 4));

       p:=p - q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' :STACKORIGIN,x';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := #9'inx';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # :STACKORIGIN,x			; 1
       (listing[i+2] = #9'inx') and								// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # :STACKORIGIN,x			; 3
       (listing[i+4] = #9'jsr addAL_CL') then							// jsr addAL_CL				; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+3]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4));
       q := GetVAL(copy(listing[i+3], 6, 4));

       p:=p + q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' :STACKORIGIN,x';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := #9'inx';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # :STACKORIGIN,x			; 1
       (listing[i+2] = #9'inx') and								// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # :STACKORIGIN,x			; 3
       (pos('mva #', listing[i+4]) > 0) and							// mva # :STACKORIGIN-1+STACKWIDTH,x	; 4
       (pos('mva #', listing[i+5]) > 0) and 							// mva # :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'jsr subAX_CX') then							// jsr subAX_CX				; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) + GetVAL(copy(listing[i+4], 6, 4)) shl 8;
       q := GetVAL(copy(listing[i+3], 6, 4)) + GetVAL(copy(listing[i+5], 6, 4)) shl 8;

       p:=p - q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' :STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' :STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # :STACKORIGIN,x			; 1
       (pos('mva #', listing[i+2]) > 0) and							// mva # :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+3] = #9'inx') and								// inx					; 3
       (pos('mva #', listing[i+4]) > 0) and							// mva # :STACKORIGIN,x			; 4
       (pos('mva #', listing[i+5]) > 0) and 							// mva # :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'jsr subAX_CX') then							// jsr subAX_CX				; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) + GetVAL(copy(listing[i+2], 6, 4)) shl 8;
       q := GetVAL(copy(listing[i+4], 6, 4)) + GetVAL(copy(listing[i+5], 6, 4)) shl 8;

       p:=p - q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' :STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' :STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # :STACKORIGIN,x			; 1
       (pos('mva #', listing[i+2]) > 0) and							// mva # :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+3] = #9'inx') and								// inx					; 3
       (pos('mva #', listing[i+4]) > 0) and							// mva # :STACKORIGIN,x			; 4
       (pos('mva #', listing[i+5]) > 0) and 							// mva # :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'jsr addAX_CX') then							// jsr addAX_CX				; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) + GetVAL(copy(listing[i+2], 6, 4)) shl 8;
       q := GetVAL(copy(listing[i+4], 6, 4)) + GetVAL(copy(listing[i+5], 6, 4)) shl 8;

       p:=p + q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' :STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' :STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # :STACKORIGIN,x			; 1
       (listing[i+2] = #9'inx') and								// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # :STACKORIGIN,x			; 3
       (listing[i+4] = #9'jsr imulBYTE') and							// jsr imulBYTE				; 4
       (listing[i+5] = #9'jsr movaBX_EAX') and							// jsr movaBX_EAX			; 5
       (listing[i+6] = #9'dex') then								// dex					; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+3]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) * GetVAL(copy(listing[i+3], 6, 4));

       listing[i]   := #9'inx';
       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' :STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' :STACKORIGIN+STACKWIDTH,x';
       listing[i+3] := '';//#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x';
       listing[i+4] := '';//#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x';
       listing[i+5] := #9'inx';

       Result:=false;
     end;


    if (listing[i] = #9'inx') and								// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and							// mva  :STACKORIGIN,x			; 1
       (pos('mva ', listing[i+2]) > 0) and							// mva  :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva ', listing[i+3]) > 0) and							// mva  :STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('mva ', listing[i+4]) > 0) and							// mva  :STACKORIGIN+STACKWIDTH*3,x	; 4
       (listing[i+5] = #9'inx') and								// inx					; 5
       (pos('mva ', listing[i+6]) > 0) and							// mva  :STACKORIGIN,x			; 6
       (pos('mva ', listing[i+7]) > 0) and 							// mva  :STACKORIGIN+STACKWIDTH,x	; 7
       (pos('mva ', listing[i+8]) > 0) and							// mva  :STACKORIGIN+STACKWIDTH*2,x	; 8
       (pos('mva ', listing[i+9]) > 0) and 							// mva  :STACKORIGIN+STACKWIDTH*3,x	; 9
       ((listing[i+10] = #9'jsr addEAX_ECX') or							// jsr addEAX_ECX|subEAX_ECX		; 10
       (listing[i+10] = #9'jsr subEAX_ECX')) then
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+6]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+8]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+9]) > 0) then
     begin

	if (listing[i+10] = #9'jsr addEAX_ECX') then
	       tmp := #9'm@addEAX_ECX '
	else
	       tmp := #9'm@subEAX_ECX ';

	listing[i+1] := tmp +
	       		copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 ) +
       			copy(listing[i+6], 6, pos(':STACK', listing[i+6])-6 ) +
			copy(listing[i+2], 6, pos(':STACK', listing[i+2])-6 ) +
			copy(listing[i+7], 6, pos(':STACK', listing[i+7])-6 ) +
			copy(listing[i+3], 6, pos(':STACK', listing[i+3])-6 ) +
			copy(listing[i+8], 6, pos(':STACK', listing[i+8])-6 ) +
			copy(listing[i+4], 6, pos(':STACK', listing[i+4])-6 ) +
			copy(listing[i+9], 6, pos(':STACK', listing[i+9])-6 );


       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       listing[i+10] := #9'inx';

       Result:=false;
     end;


    if (pos('mva ', listing[i]) > 0) and (pos('mva :STACK', listing[i]) = 0) and		// mva YY+3 :STACKORIGIN+STACKWIDTH*3,x	; 0
       (pos(' :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*3,x	; 1
       (pos('lda :STACK', listing[i+1]) > 0) and						// and|ora|eor				; 2
       and_ora_eor(i+2) and									// sta :STACKORIGIN+STACKWIDTH*3,x	; 3
       (pos('sta :STACK', listing[i+3]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
	(pos(copy(listing[i+1], 6, 256), listing[i]) > 0 ) then
      begin
	listing[i]   := #9'lda ' + copy(listing[i], 6, pos(' :STACK', listing[i])-7);
	listing[i+1] := '';

	Result:=false;
      end;


    if (listing[i] = #9'bne *+5') and								// bne *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jeq ' + copy(listing[i+1], 6, 256);

       Result:=false;
     end;


    if (listing[i] = #9'beq *+5') and								// beq *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jne ' + copy(listing[i+1], 6, 256);

       Result:=false;
     end;


    if Result and
       (pos('mva #$', listing[i]) > 0) and							// mva #$xx		; 0
       (pos('mva #$', listing[i+1]) > 0) and							// mva #$xx		; 1
       (pos('mva #$', listing[i+2]) = 0) then							// ~mva #$		; 2
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) then
     begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);

       Result:=false;
     end;


    if Result and
       (pos('mva #$', listing[i]) > 0) and							// mva #$xx		; 0
       (pos('mva #$', listing[i+1]) > 0) and							// mva #$xx		; 1
       (pos('mva #$', listing[i+2]) > 0) then							// mva #$yy		; 2
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and
        (copy(listing[i+1], 6, 4) <> copy(listing[i+2], 6, 4)) then
     begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);

       Result:=false;
     end;

{
    if (pos('mva #$', listing[i]) > 0) and (pos(' :STACK', listing[i]) > 0) and			// mva #$xx STACKORIGN,x		; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (listing[i+2] = #9'inx') and			// sta :STACKORIGIN+STACKWIDTH,x		; 1
       (pos('mva #$', listing[i+3]) > 0) and (pos(' :STACK', listing[i+3]) > 0) then		// inx					; 2
     if copy(listing[i], 6, 4) = copy(listing[i+3], 6, 4) then					// mva #$xx STACKORIGN,x		; 3
     begin
       listing[i+3] := #9'sta ' + copy(listing[i+3], pos(':STACK', listing[i+3]), 256 );
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos(' :STACK', listing[i]) > 0) and			// mva #$xx STACKORIGN,x		; 0
       (listing[i+1] = #9'inx') and								// inx					; 1
       (pos('mva #$', listing[i+2]) > 0) and (pos(' :STACK', listing[i+2]) > 0) then		// mva #$xx STACKORIGN,x		; 2
     if copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4) then
     begin
       listing[i+2] := #9'sta ' + copy(listing[i+2], pos(':STACK', listing[i+2]), 256 );
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos(' :STACK', listing[i]) > 0) and			// mva #$xx STACKORIGN			; 0
       (pos('mva #$', listing[i+1]) > 0) and (pos(' :STACK', listing[i+1]) > 0) and		// mva #$yy STACKORIGN			; 1
       (listing[i+2] = #9'inx') and								// inx					; 2
       (pos('mva #$', listing[i+3]) > 0) and (pos(' :STACK', listing[i+3]) > 0) then		// mva #$xx STACKORIGN			; 3
     if copy(listing[i], 6, 4) = copy(listing[i+3], 6, 4) then
     begin
       tmp:=listing[i];
       listing[i]   := listing[i+1];
       listing[i+1] := tmp;
       Result:=false;
     end;
}

{	!!! takie optymalizacje na stosie nie dzialaja prawidlowo !!!

    if (listing[i] = #9'inx') and											// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and						// mva aa STACKORIGN,x			; 1
       (pos('mva ', listing[i+3]) > 0) and (pos('mva ', listing[i+4]) > 0) and						// mva bb STACKORIGN+STACKWIDTH,x	; 2
       (listing[i+5] = #9'inx') and											// mva cc :STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('mva ', listing[i+6]) > 0) and (pos('mva ', listing[i+7]) > 0) and						// mva dd :STACKORIGIN+STACKWIDTH*3,x	; 4
       (pos('mva ', listing[i+8]) > 0) and (pos('mva ', listing[i+9]) > 0) and						// inx					; 5
       (pos(':STACKORIGIN,', listing[i+1]) > 6) and (pos(':STACKORIGIN+STACKWIDTH,', listing[i+2]) > 6) and		// mva aa STACKORIGN,x			; 6
       (pos(':STACKORIGIN+STACKWIDTH*2,', listing[i+3]) > 6) and (pos(':STACKORIGIN+STACKWIDTH*3,', listing[i+4]) > 6) and// mva bb STACKORIGN+STACKWIDTH,x	; 7
       (pos(':STACKORIGIN', listing[i+6]) > 6) and (pos(':STACKORIGIN+STACKWIDTH,', listing[i+7]) > 6) and		// mva cc :STACKORIGIN+STACKWIDTH*2,x	; 8
       (pos(':STACKORIGIN+STACKWIDTH*2,', listing[i+8]) > 6) and (pos(':STACKORIGIN+STACKWIDTH*3,', listing[i+9]) > 6) and// mva dd :STACKORIGIN+STACKWIDTH*3,x	; 9
       (listing[i+10] = #9'jsr mulREAL') then										// jsr mulREAL				; 10
     begin
       listing[i+1] := #9'mva ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6 ) + ':eax';
       listing[i+2] := #9'mva ' + copy(listing[i+2], 6, pos(':STACK', listing[i+2])-6 ) + ':eax+1';
       listing[i+3] := #9'mva ' + copy(listing[i+3], 6, pos(':STACK', listing[i+3])-6 ) + ':eax+2';
       listing[i+4] := #9'mva ' + copy(listing[i+4], 6, pos(':STACK', listing[i+4])-6 ) + ':eax+3';

       listing[i+6] := #9'mva ' + copy(listing[i+6], 6, pos(':STACK', listing[i+6])-6 ) + 'mulREAL.ecx0';
       listing[i+7] := #9'mva ' + copy(listing[i+7], 6, pos(':STACK', listing[i+7])-6 ) + 'mulREAL.ecx1';
       listing[i+8] := #9'mva ' + copy(listing[i+8], 6, pos(':STACK', listing[i+8])-6 ) + 'mulREAL.ecx2';
       listing[i+9] := #9'mva ' + copy(listing[i+9], 6, pos(':STACK', listing[i+9])-6 ) + 'mulREAL.ecx3';

       listing[i+10] := #9'jsr mulREAL.main';
       Result:=false;
     end;
}

  end;

 end;


 procedure OptimizeAssignment;
 // sprawdzamy odwolania do STACK, czy nastapil zapis STA
 // jesli pierwsze odwolanie do STACK to LDA (MVA) zastepujemy przez #$00

 var i, j, k: integer;
     a: string;
     v, emptyStart, emptyEnd: integer;


   function PeepholeOptimization_END: Boolean;
   var i, p: integer;
       old: string;
   begin

   Result:=true;

   Rebuild;

   for i := 0 to l - 1 do
    if listing[i] <> '' then begin

    p:=i;

    old := listing[p];

    while (pos('lda #', old) > 0) and (pos('sta ', listing[p+1]) > 0) and (pos('lda #', listing[p+2]) > 0) and (p<l-2) do begin	// lda #

     if (copy(old, 6, 256) = copy(listing[p+2], 6, 256)) then
      listing[p+2] := ''					       // sta
     else
      old:=listing[p+2];

     inc(p, 2);								// lda #
    end;

   end;


   end;



   function PeepholeOptimization_STA: Boolean;
   var i, p: integer;
       tmp, old: string;
       yes: Boolean;
   begin

   tmp:='';
   old:='';

   Result:=true;

   Rebuild;

   for i := 0 to l - 1 do
    if listing[i] <> '' then begin

     if ADD_SUB_STACK(i) or ADC_SBC_STACK(i) then					// add|sub|adc|sbc STACK
      begin

	tmp:=copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (pos('sta ', listing[p]) > 0) and (pos('lda ', listing[p-1]) > 0) then begin

	   listing[i]   := copy(listing[i], 1, 5) +  copy(listing[p-1], 6, 256);

	   listing[p-1] := '';
	   listing[p] := '';

	   Result:=false;
	   Break;
	  end else
	   Break;

	 end else
	  if (pos('ldy ', listing[p]) > 0) or (pos(#9'.if', listing[p]) > 0) or (pos(#9'jsr', listing[p]) > 0) or
	     (listing[p] = #9'iny') or (listing[p] = #9'dey') or (listing[p] = #9'eif') or
	     (listing[p] = #9'tya') or (listing[p] = #9'tay') then Break;

      end;


     if (pos('lda :STACK', listing[i]) > 0) and						// lda :STACK
        ( (pos('adc ', listing[i+1]) > 0) or (pos('add ', listing[i+1]) > 0) ) then	// add|adc
      begin

	tmp:=copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if pos(tmp, listing[p]) > 0 then begin

	  if (pos('sta ', listing[p]) > 0) and (pos('lda ', listing[p-1]) > 0) and (pos('sta ', listing[p+1]) = 0) then begin

	   listing[i]   := #9'lda ' + copy(listing[p-1], 6, 256);

	   listing[p-1] := '';
	   listing[p]   := '';

	   Result:=false;
	   Break;
	  end else
	   Break;

	 end else
	  if (listing[p] = '@') or (pos(copy(listing[i+1], 6, 256), listing[p]) > 0) or
	     (pos('ldy ', listing[p]) > 0) or (pos(#9'.if', listing[p]) > 0) or (pos(#9'jsr', listing[p]) > 0) or
	     (listing[p] = #9'iny') or (listing[p] = #9'dey') or (listing[p] = #9'eif') or
	     (listing[p] = #9'tya') or (listing[p] = #9'tay') then Break;

      end;


     if Result and									// lda :STACKORIGIN		; 0
	(pos('lda :STACK', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and	// sta				; 1
	(pos('sta ', listing[i+2]) = 0) and						// ~sta				; 2
	( copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256) ) then
       begin

	tmp:=#9'sta ' + copy(listing[i], 6, 256);

	for p:=i-1 downto 0 do
	 if listing[p] = tmp then begin
	  listing[p]   := listing[i+1];
	  listing[i]   := '';
	  listing[i+1] := '';

	  Result:=false;
	  Break;
	 end else
	 if (pos(copy(listing[i+1], 6, 256), listing[p]) > 0) or

	not ( (pos('lda ', listing[p]) > 0) or (pos('sta ', listing[p]) > 0) or
	    (listing[p] = #9'iny') or (listing[p] = #9'dey') or
	    (listing[p] = #9'tya') or (listing[p] = #9'tay') or
	    adc_sbc(p) or and_ora_eor(p) ) then Break;

       end;


     if (pos('lda ', listing[i]) > 0) and 						// lda				; 0
	(pos('add :STACK', listing[i+1]) > 0) and 					// add :STACKORIGIN+9		; 1
	(listing[i+2] = #9'tay') and							// tay				; 2
	(pos('lda ', listing[i+3]) > 0) and						// lda				; 3
	(pos('adc :STACK', listing[i+4]) > 0) and 					// adc :STACKORIGIN+STACKWIDTH	; 4
	(listing[i+5] = #9'sta :bp+1') then 						// sta :bp+1			; 5
      begin

	tmp:=#9'sta ' + copy(listing[i+1], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (pos('lda ', listing[p-2]) > 0) and		// lda :STACKORIGIN+9			; p-2
	     add_sub(p-1) and					// add #$80				; p-1
	     (pos('sta :STACK', listing[p]) > 0) and		// sta :STACKORIGIN+9			; p
	     (pos('lda ', listing[p+1]) > 0) and		// lda :STACKORIGIN+STACKWIDTH+9	; p+1
	     adc_sbc(p+2) and					// adc #$03				; p-1
	     (pos('sta :STACK', listing[p+3]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+9	; p+3
	     (pos('lda ', listing[p+4]) > 0) and		// lda :STACKORIGIN+STACKWIDTH*2+9	; p+4
	     adc_sbc(p+5) and					// adc #$03				; p-1
	     (pos('sta :STACK', listing[p+6]) > 0) and		// sta :STACKORIGIN+STACKWIDTH*2+9	; p+6
	     (pos('lda ', listing[p+7]) > 0) and		// lda :STACKORIGIN+STACKWIDTH*3+9	; p+7
	     adc_sbc(p+8) and					// adc #$03				; p-1
	     (pos('sta :STACK', listing[p+9]) > 0) then begin	// sta :STACKORIGIN+STACKWIDTH*3+9	; p+9

	   listing[p+4] := '';
	   listing[p+5] := '';
	   listing[p+6] := '';
	   listing[p+7] := '';
	   listing[p+8] := '';
	   listing[p+9] := '';

	   Result:=false;
	   Break;
	  end else
	   Break;

	 end else
	  if (listing[p] = '@') or (pos(#9'.if', listing[p]) > 0) or
	     (pos(#9'jsr', listing[p]) > 0) or (listing[p] = #9'eif') then Break;

      end;


    if (pos('lda ', listing[i]) > 0) and						// lda				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+9		; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda 				; 2
       (pos('asl :STACK', listing[i+3]) > 0) and					// asl :STACKORIGIN+9		; 3
       (listing[i+4] = #9'rol @') then							// rol @			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then			// ...
       begin										// sta :STACKORIGIN+STACKWIDTH+9

	yes:=false;
	for p:=i+4 to l-1 do
	 if (pos('sta :STACK', listing[p]) > 0) and (listing[p-1] = #9'rol @')  then begin
	  tmp:=copy(listing[p], 6, 256);

	  if (pos('lda ', listing[p+1]) > 0) and (pos('add ', listing[p+2]) > 0) and	// lda
	     (copy(listing[p+2], 6, 256) = copy(listing[i+1], 6, 256)) then		// add :STACKORIGIN+9
	       yes:=true;

	  Break;
	 end;

	if yes then begin

	 old:=listing[i+2];
	 listing[i+2]:=listing[i];
	 listing[i]:=old;
	 listing[i+1] := #9'sta ' + tmp;

	 p:=i+3;

	 old:=copy(listing[p], 6, 256);

	 while true do begin
	  if (pos('asl :STACK', listing[p]) > 0) then listing[p] := #9'asl @';
	  if (listing[p] = #9'rol @') then listing[p] := #9'rol ' + tmp;
	  if (pos('sta :STACK', listing[p]) > 0) then begin listing[p] := #9'sta ' + old; Break end;

	  inc(p);
	 end;

	 Result:=false;
	end;

       end;


    if (pos('lda :STACK', listing[i]) > 0) and						// lda :STACKORIGIN+9		; 0
       (listing[i+1] = #9'sta (:bp2),y') then						// sta (:bp2),y			; 1
       begin

 	tmp:=#9'sta ' + copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (listing[p] = tmp) and (pos('lda ', listing[p-1]) > 0) and (pos(',y', listing[p-1]) = 0) then begin
	  listing[i]   := listing[p-1];

//	  listing[p-1] := '';		!!! zachowac 'lda'
//	  listing[p]   := '';

	  Result:=false;
	  Break;
	 end;

       end;


    if (pos('lda :STACK', listing[i]) > 0) and						// lda :STACKORIGIN+9		; 0
       (listing[i+1] = #9'sta :bp2') and						// sta :bp2			; 1
       (pos('lda :STACK', listing[i+2]) > 0) and					// lda :STACKORIGIN+STAWCKWIDTH	; 2
       (listing[i+3] = #9'sta :bp2+1') then						// sta :bp2+1			; 3
       begin

 	tmp:='sta ' + copy(listing[i], 6, 256);

	for p:=i-1 downto 0 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (pos('sta :STACK', listing[p]) > 0) and				// sta :STACKORIGIN+9			; 0
	     (pos('lda ', listing[p+1]) > 0) and				// lda :STACKORIGIN+STACKWIDTH+9	; 1
	     adc_sbc(p+2) and							// adc :STACKORIGIN+STACKWIDTH+11	; 2
	     (pos('sta :STACK', listing[p+3]) > 0) and				// sta :STACKORIGIN+STACKWIDTH+9	; 3
	     (pos('lda ', listing[p+4]) > 0) and				// lda :STACKORIGIN+STACKWIDTH*2+9	; 4
	     adc_sbc(p+5) and							// adc #$00				; 5
	     (pos('sta :STACK', listing[p+6]) > 0) and				// sta :STACKORIGIN+STACKWIDTH*2+9	; 6
	     (pos('lda ', listing[p+7]) > 0) and				// lda :STACKORIGIN+STACKWIDTH*3+9	; 7
	     adc_sbc(p+8) and							// adc #$00				; 8
	     (pos('sta :STACK', listing[p+9]) > 0) then 			// sta :STACKORIGIN+STACKWIDTH*3+9	; 9
	  if copy(listing[i+2], 6, 256) = copy(listing[p+3], 6, 256) then
	  begin

	   listing[p+4] := '';
	   listing[p+5] := '';
	   listing[p+6] := '';
	   listing[p+7] := '';
	   listing[p+8] := '';
	   listing[p+9] := '';

	   Result:=false;
	   Break;
	  end;

	 end else
	  if listing[p] = #9'eif' then Break;

       end;


    if (pos('lda :STACK', listing[i]) > 0) and						// lda :STACKORIGIN+9		; 0
       (listing[i+2] = #9'sta (:bp2),y') and						// add|sub|and|ora|eor		; 1
       (add_sub(i+1) or adc_sbc(i+1) or and_ora_eor(i+1)) then				// sta (:bp2),y			; 2
       begin

 	tmp:=copy(listing[i], 6, 256);

	yes:=false;
	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (pos('sta '+tmp, listing[p]) > 0) and (pos('lda ', listing[p-1]) > 0) and (pos(',y', listing[p-1]) = 0) then begin
	   listing[i]   := listing[p-1];
	   listing[p-1] := '';
	   listing[p]   := '';

	   Result:=false;
	  end else
	   Break;

	 end;
//	  else
//	  if (listing[p] = '@') or (pos(#9'jsr', listing[p]) > 0) then Break;

       end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+9		; 0
       (pos('ldy ', listing[i+1]) > 0) and						// ldy				; 1
       (pos('mva :STACK', listing[i+2]) > 0) then					// mva :STACKORIGIN+9 ...	; 2
     if pos(copy(listing[i], 6, 256), listing[i+2]) > 0 then
       begin
	tmp:=copy(listing[i], 6, 256);

	listing[i+2] := #9'sta' + copy(listing[i+2], 6 + length(tmp), 256);

	listing[i] := '';

	Result:=false;
       end;


    if add_sub(i) and									// add|sub				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       (pos('sta :STACK', listing[i+4]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+5]) > 0) and						// lda					; 5
       adc_sbc(i+6) and									// adc|sbc				; 6
       (pos('sta :STACK', listing[i+7]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+9	; 7
       (pos('lda ', listing[i+8]) > 0) and						// lda					; 8
       adc_sbc(i+9) and									// adc|sbc				; 9
       (pos('sta :STACK', listing[i+10]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*3+9	; 10
       (pos('lda :STACK', listing[i+11]) > 0) and					// lda :STACKORIGIN+9			; 11
       and_ora_eor(i+12) and								// and|ora|eor				; 12
       (pos('sta ', listing[i+13]) > 0)	and (pos('lda ', listing[i+14]) = 0) then	// sta					; 13
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) then			// ~lda					; 14
       begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false;
       end;


    if add_sub(i) and									// add|sub				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       (pos('sta :STACK', listing[i+4]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+5]) > 0) and						// lda					; 5
       adc_sbc(i+6) and									// adc|sbc				; 6
       (pos('sta :STACK', listing[i+7]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+9	; 7
       (pos('lda ', listing[i+8]) > 0) and						// lda					; 8
       adc_sbc(i+9) and									// adc|sbc				; 9
       (pos('sta :STACK', listing[i+10]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*3+9	; 10
       (pos('lda :STACK', listing[i+11]) > 0) and					// lda :STACKORIGIN+9			; 11
       and_ora_eor(i+12) and								// and|ora|eor				; 12
       (pos('ldy ', listing[i+13]) > 0) and						// ldy					; 13
       (pos('sta ', listing[i+14]) > 0)	and (pos('lda ', listing[i+15]) = 0) then	// sta ,y				; 14
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) then			// ~lda 				; 15
       begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false;
       end;


    if add_sub(i) and									// add|sub				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       (pos('sta :STACK', listing[i+4]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+5]) > 0) and						// lda					; 5
       adc_sbc(i+6) and									// adc|sbc				; 6
       (pos('sta :STACK', listing[i+7]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+9	; 7
       (pos('lda ', listing[i+8]) > 0) and						// lda					; 8
       adc_sbc(i+9) and									// adc|sbc				; 9
       (pos('sta :STACK', listing[i+10]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*3+9	; 10
       (pos('lda :STACK', listing[i+11]) > 0) and					// lda :STACKORIGIN+9			; 11
       add_sub(i+12) and								// add|sub				; 12
       (pos('sta ', listing[i+13]) > 0) and						// sta					; 13
       (pos('lda :STACK', listing[i+14]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 14
       adc_sbc(i+15) and								// adc|sbc				; 15
       (pos('sta ', listing[i+16]) > 0) and						// sta					; 16
       (pos('lda :STACK', listing[i+17]) = 0) then					// ~lda :STACK				; 17
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+9			; 0
       (pos('sty :STACK', listing[i+1]) > 0) and					// sty :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('sty :STACK', listing[i+2]) > 0) and					// sty :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('sty :STACK', listing[i+3]) > 0) and					// sty :STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       add_sub(i+5) and									// add|sub :STACKORIGIN+9		; 5
       (pos('sta ', listing[i+6]) > 0) and						// sta					; 6
       (pos('lda ', listing[i+7]) > 0) and						// lda					; 7
       adc_sbc(i+8) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 8
       (pos('sta ', listing[i+9]) > 0) and						// sta					; 9
       (pos('lda ', listing[i+10]) = 0) then						// ~lda					; 10
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 0
       (pos('sty :STACK', listing[i+1]) > 0) and					// sty :STACKORIGIN+STACKWIDTH*2+9	; 1
       (pos('sty :STACK', listing[i+2]) > 0) and					// sty :STACKORIGIN+STACKWIDTH*3+9	; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       add_sub(i+4) and									// add|sub :STACKORIGIN+9		; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta					; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda					; 6
       adc_sbc(i+7) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta					; 8
       (pos('lda ', listing[i+9]) = 0) then						// ~lda					; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+9	; 0
       (pos('lda :STACK', listing[i+3]) > 0) and					// mwa SCRN bp2		; 1
       (pos('mwa ', listing[i+1]) > 0) and (pos('ldy ', listing[i+2]) > 0) then		// ldy #$00		; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin		// lda :STACKORIGIN+9	; 3
	listing[i]   := '';
	listing[i+3] := '';

	listing[i+1] := #9'mwy '+copy(listing[i+1], 6, 256);

	Result:=false;
     end;


    if (pos('lda :STACK', listing[i]) > 0) and						// lda :STACKORIGIN+9		; 0
       add_sub(i+1) and									// add|sub			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9		; 2
       (pos('lda :STACK', listing[i+3]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9; 3
       adc_sbc(i+4) and									// adc|sbc			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9; 5
       (pos('lda :STACK', listing[i+6]) > 0) and					// lda :STACKORIGIN+9		; 6
       add_sub(i+7) and									// add|sub			; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta				; 8
       (pos('lda ', listing[i+9]) = 0) then						// ~lda				; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda					; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       (pos('sta ', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and					// lda :STACKORIGIN+9			; 12
       add_sub(i+13) and								// add|sub				; 13
       (pos('sta :STACK', listing[i+14]) > 0) then					// sta					; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and			// ~lda :STACKORIGIN+STACKWIDTH+9	; 15
	(copy(listing[i+5], 6, 256) <> copy(listing[i+15], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda :STACK', listing[i+6]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 6
       (listing[i+7] = #9'sta :bp+1') and						// sta :bp+1				; 7
       (pos('ldy :STACK', listing[i+8]) > 0) and					// ldy :STACKORIGIN+9			; 8
       (pos('lda :STACK', listing[i+9]) > 0) and					// lda :STACKORIGIN+10			; 9
       (listing[i+10] = #9'sta (:bp),y') then						// sta (:bp),y				; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+8], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda					; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       (pos('sta ', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda ', listing[i+12]) > 0) and						// lda					; 12
       add_sub(i+13) and								// add|sub				; 13
       add_sub(i+14) and								// add|sub				; 14
       (pos('sta :STACK', listing[i+15]) > 0) and					// sta :STACKORIGIN+10			; 15
       (pos('lda :STACK', listing[i+16]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 16
       (listing[i+17] = #9'sta :bp+1') and						// sta :bp+1				; 17
       (pos('ldy :STACK', listing[i+18]) > 0) and					// ldy :STACKORIGIN+9			; 18
       (pos('lda :STACK', listing[i+19]) > 0) and					// lda :STACKORIGIN+10			; 19
       (listing[i+20] = #9'sta (:bp),y') then						// sta (:bp),y				; 20
     if (copy(listing[i+2], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+19], 6, 256)) then
       begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda					; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       (pos('sta ', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda ', listing[i+12]) > 0) and						// lda					; 12
       add_sub(i+13) and								// add|sub				; 13
       (pos('sta :STACK', listing[i+14]) > 0) and					// sta :STACKORIGIN+10			; 14
       (pos('lda :STACK', listing[i+15]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 15
       (listing[i+16] = #9'sta :bp+1') and						// sta :bp+1				; 16
       (pos('ldy :STACK', listing[i+17]) > 0) and					// ldy :STACKORIGIN+9			; 17
       (pos('lda :STACK', listing[i+18]) > 0) and					// lda :STACKORIGIN+10			; 18
       (listing[i+19] = #9'sta (:bp),y') then						// sta (:bp),y				; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+14], 6, 256) = copy(listing[i+18], 6, 256)) then
       begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda					; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       (pos('sta ', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and					// lda :STACKORIGIN+9			; 12
       add_sub(i+13) and								// add|sub				; 13
       (listing[i+14] = #9'tay') and							// tay					; 14
       (pos('lda :STACK', listing[i+15]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_sbc(i+16) and								// adc|sbc				; 16
       (listing[i+17] = #9'sta :bp+1') and						// sta :bp+1				; 17
       (pos('lda ', listing[i+18]) > 0) and						// lda 					; 18
       (listing[i+19] = #9'sta (:bp),y') then						// sta (:bp),y				; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) then
       begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and						// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (listing[i+3] = #9'asl @') and							// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and						// rol :eax+1				; 4
       (listing[i+5] = #9'asl @') and							// asl @				; 5
       (listing[i+6] = #9'rol :eax+1') and						// rol :eax+1				; 6
       (pos('add ', listing[i+7]) > 0) and						// add					; 7
       (listing[i+8] = #9'sta :eax') and						// sta :eax				; 8
       (listing[i+9] = #9'lda :eax+1') and						// lda :eax+1				; 9
       (listing[i+10] = #9'adc #$00') and						// adc #$00				; 10
       (listing[i+11] = #9'sta :eax+1') and						// sta :eax+1				; 11
       (listing[i+12] = #9'asl :eax') and						// asl :eax				; 12
       (listing[i+13] = #9'rol :eax+1') and						// rol :eax+1				; 13
       (listing[i+14] = #9'lda :eax') and						// lda :eax				; 14
       add_sub(i+15) and								// add|sub 				; 15
       ((listing[i+16] = #9'tay') or							// tay|sta :STACK			; 16
       ((pos('sta :STACK', listing[i+16]) > 0) and (pos(' :eax+1', listing[i+17]) = 0) )) then
       begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';
	listing[i+6] := '';

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	listing[i+14] := #9'asl @';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and						// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (listing[i+3] = #9'asl @') and							// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and						// rol :eax+1				; 4
       (listing[i+5] = #9'asl @') and							// asl @				; 5
       (listing[i+6] = #9'rol :eax+1') and						// rol :eax+1				; 6
       (pos('add ', listing[i+7]) > 0) and						// add					; 7
       (listing[i+8] = #9'sta :eax') and						// sta :eax				; 8
       (listing[i+9] = #9'lda :eax+1') and						// lda :eax+1				; 9
       (listing[i+10] = #9'adc #$00') and						// adc #$00				; 10
       (listing[i+11] = #9'sta :eax+1') and						// sta :eax+1				; 11
       (listing[i+12] = #9'asl :eax') and						// asl :eax				; 12
       (listing[i+13] = #9'rol :eax+1') and						// rol :eax+1				; 13
       (pos('lda ', listing[i+14]) > 0) and 						// lda 					; 14
       add_sub(i+15) and								// add|sub 				; 15
       ((listing[i+16] = #9'add :eax') or (listing[i+16] = #9'sub :eax')) and		// add|sub :eax				; 16
       (listing[i+17] = #9'tay') then							// tay					; 17
       begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';
	listing[i+6] := '';

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := #9'asl @';
	listing[i+13] := #9'sta :eax';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and						// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (listing[i+3] = #9'asl @') and							// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and						// rol :eax+1				; 4
       (listing[i+5] = #9'asl @') and							// asl @				; 5
       (listing[i+6] = #9'rol :eax+1') and						// rol :eax+1				; 6
       (pos('add ', listing[i+7]) > 0) and						// add					; 7
       (listing[i+8] = #9'sta :eax') and						// sta :eax				; 8
       (listing[i+9] = #9'lda :eax+1') and						// lda :eax+1				; 9
       (listing[i+10] = #9'adc #$00') and						// adc #$00				; 10
       (listing[i+11] = #9'sta :eax+1') and						// sta :eax+1				; 11
       (listing[i+12] = #9'asl :eax') and						// asl :eax				; 12
       (listing[i+13] = #9'rol :eax+1') and						// rol :eax+1				; 13
       (listing[i+14] = #9'lda :eax') and						// lda :eax				; 14
       (pos('sta ', listing[i+15]) > 0) and						// sta 					; 15
       (pos(' :eax+1', listing[i+16]) = 0) and						// ~ :eax+1				; 16
       (pos(' :eax+1', listing[i+17]) = 0) then						// ~ :eax+1				; 17
       begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';
	listing[i+6] := '';

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	listing[i+12] := #9'asl @';
	listing[i+13] := #9'sta :eax';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and						// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (listing[i+3] = #9'asl @') and							// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and						// rol :eax+1				; 4
       (listing[i+5] = #9'asl @') and							// asl @				; 5
       (listing[i+6] = #9'rol :eax+1') and						// rol :eax+1				; 6
       (pos('add ', listing[i+7]) > 0) and						// add					; 7
       (listing[i+8] = #9'sta :eax') and						// sta :eax				; 8
       (listing[i+9] = #9'lda :eax+1') and						// lda :eax+1				; 9
       (listing[i+10] = #9'adc #$00') and						// adc #$00				; 10
       (listing[i+11] = #9'sta :eax+1') and						// sta :eax+1				; 11
       (listing[i+12] = #9'asl :eax') and						// asl :eax				; 12
       (listing[i+13] = #9'rol :eax+1') and						// rol :eax+1				; 13
       (listing[i+14] = #9'lda :eax') and						// lda :eax				; 14
       add_sub(i+15) and								// add|sub 				; 15
       (pos('sta ', listing[i+16]) > 0) and						// sta					; 16
       (pos(' :eax+1', listing[i+17]) = 0) and						// ~ :eax+1				; 17
       (pos(' :eax+1', listing[i+18]) = 0) then						// ~ :eax+1				; 18
       begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';
	listing[i+6] := '';

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	listing[i+12] := #9'asl @';
	listing[i+13] := #9'sta :eax';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and						// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (listing[i+3] = #9'asl @') and							// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and						// rol :eax+1				; 4
       (pos('add ', listing[i+5]) > 0) and						// add					; 5
       (listing[i+6] = #9'sta :eax') and						// sta :eax				; 6
       (listing[i+7] = #9'lda :eax+1') and						// lda :eax+1				; 7
       (listing[i+8] = #9'adc #$00') and						// adc #$00				; 8
       (listing[i+9] = #9'sta :eax+1') and						// sta :eax+1				; 9
       (listing[i+10] = #9'lda :eax') and						// lda :eax				; 10
       (pos('sta ', listing[i+11]) > 0) and						// sta					; 11
       (pos(' :eax+1', listing[i+12]) = 0) and						// ~ :eax+1				; 12
       (pos(' :eax+1', listing[i+13]) = 0) then						// ~ :eax+1				; 13
       begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and						// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (listing[i+3] = #9'asl @') and							// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and						// rol :eax+1				; 4
       (pos('add ', listing[i+5]) > 0) and						// add					; 5
       (listing[i+6] = #9'sta :eax') and						// sta :eax				; 6
       (listing[i+7] = #9'lda :eax+1') and						// lda :eax+1				; 7
       (listing[i+8] = #9'adc #$00') and						// adc #$00				; 8
       (listing[i+9] = #9'sta :eax+1') and						// sta :eax+1				; 9
       (listing[i+10] = #9'lda :eax') and						// lda :eax				; 10
       add_sub(i+11) and								// add|sub				; 11
       (pos('sta ', listing[i+12]) > 0) and						// sta					; 12
       (pos(' :eax+1', listing[i+13]) = 0) and						// ~ :eax+1				; 13
       (pos(' :eax+1', listing[i+14]) = 0) then						// ~ :eax+1				; 14
       begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false;
       end;


// add !!!
    if (pos('lda :STACK', listing[i]) > 0) and						// lda :STACKORIGIN+10			; 0
       (pos('add ', listing[i+1]) > 0) and						// add					; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+10			; 2
       (pos('lda :STACK', listing[i+3]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('adc #$00', listing[i+4]) > 0) and						// adc #$00				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda :STACK', listing[i+6]) > 0) and					// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       (pos('adc #$00', listing[i+7]) > 0) and						// adc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda :STACK', listing[i+9]) > 0) and					// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       (pos('adc #$00', listing[i+10]) > 0) and						// adc #$00				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and					// lda :STACKORIGIN+10			; 12
       (pos('sta ', listing[i+13]) > 0) and						// sta ADDR				; 13
       (pos('lda ', listing[i+14]) > 0) and (pos(' :STACK', listing[i+14]) = 0) and	// lda #$A0				; 14
       (pos('add :STACK', listing[i+15]) > 0) and					// add :STACKORIGIN+STACKWIDTH+10	; 15
       (pos('sta ', listing[i+16]) > 0) and						// sta ADDR+1				; 16
       (pos('lda ', listing[i+17]) = 0) then
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
	(listing[i] = listing[i+12]) then
       begin
        listing[i+2] := listing[i+13];
	listing[i+4] := #9'adc ' + copy(listing[i+14], 6, 256);
	listing[i+5] := listing[i+16];

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';

	Result:=false;
       end;


    if (pos('asl :STACK', listing[i]) > 0) and						// asl :STACKORIGIN+10			; 0
       (pos('rol :STACK', listing[i+1]) > 0) and					// rol :STACKORIGIN+STACKWIDTH+10	; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       add_sub_stack(i+3) and								// add|sub :STACKORIGIN+10		; 3
       (pos('sta ', listing[i+4]) > 0) and						// sta					; 4
       (pos('lda ', listing[i+5]) = 0) then						// ~lda					; 5
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i+1] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda 					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('asl :STACK', listing[i+6]) > 0) and					// asl :STACKORIGIN+10			; 6
       (pos('lda ', listing[i+7]) > 0) and						// lda					; 7
       add_sub_stack(i+8) and								// add|sub :STACKORIGIN+10		; 8
       (pos('sta ', listing[i+9]) > 0) and						// sta					; 9
       (pos('lda ', listing[i+10]) = 0) then						// ~lda					; 10
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00			; 0
       (pos('cmp :STACK', listing[i+1]) > 0) and					// cmp :STACKORIGIN+9		; 1
       (listing[i+2] = #9'bne @+') then							// bne @+			; 2
     begin
       listing[i] := '';
       listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256) ;

       Result:=false;
      end;


    if (listing[i] = #9'lda :eax+1') and						// lda :eax+1			; 0
       adc_sbc(i+1) and									// adc|sbc			; 1
       (listing[i+2] = #9'sta :eax+1') and						// sta :eax+1			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda 				; 3
       add_sub(i+4) and	(pos(' :eax', listing[i+4]) > 0) and 				// add|sub :eax			; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta				; 5
       (pos('lda ', listing[i+6]) = 0) then						// ~lda				; 6
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('asl :STACK', listing[i]) > 0) and						// asl :STACKORIGIN+9 			; 0
       (pos('rol :STACK', listing[i+1]) > 0) and					// rol :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('rol :STACK', listing[i+2]) > 0) and					// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol :STACK', listing[i+3]) > 0) and					// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('lda :STACK', listing[i+4]) > 0) and					// lda :STACKORIGIN+9 			; 4
       add_sub(i+5) and									// add|sub 				; 5
       (pos('sta ', listing[i+6]) > 0) and						// sta					; 6
       (pos('lda :STACK', listing[i+7]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 7
       adc_sbc(i+8) and									// adc|sbc				; 8
       (pos('sta ', listing[i+9]) > 0) and						// sta					; 9
       (pos('lda :STACK', listing[i+10]) = 0) then					// ~lda :STACKORIGIN+STACKWIDTH*2+9 	; 10
      if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda DX 			; 0
       (pos('add ', listing[i+1]) > 0) and						// add DX			; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta DX			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda DX+1			; 3
       (pos('adc ', listing[i+4]) > 0) and						// adc DX+1			; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta DX+1			; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda DX+2			; 6
       (pos('adc ', listing[i+7]) > 0) and						// adc DX+2			; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta DX+2			; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda DX+3			; 9
       (pos('adc ', listing[i+10]) > 0) and						// adc DX+3			; 10
       (pos('sta ', listing[i+11]) > 0) then						// sta DX+3			; 11
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+7], 6, 256)) and
	 (copy(listing[i+7], 6, 256) = copy(listing[i+8], 6, 256)) and
	 (copy(listing[i+9], 6, 256) = copy(listing[i+10], 6, 256)) and
	 (copy(listing[i+10], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'rol ' + copy(listing[i+3], 6, 256);
	listing[i+2] := #9'rol ' + copy(listing[i+6], 6, 256);
	listing[i+3] := #9'rol ' + copy(listing[i+9], 6, 256);

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda DX 			; 0
       (pos('add ', listing[i+1]) > 0) and						// add DX			; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta DX			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda DX+1			; 3
       (pos('adc ', listing[i+4]) > 0) and						// adc DX+1			; 4
       (pos('sta ', listing[i+5]) > 0) then						// sta DX+1			; 5
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'rol ' + copy(listing[i+3], 6, 256);

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda DX 			; 0
       (pos('add ', listing[i+1]) > 0) and						// add DX			; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta DX			; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda TT+1 			; 0
       (pos('sta ', listing[i+1]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda TT			; 2
       (listing[i+3] = #9'asl @') and							// asl @			; 3
       (pos('rol ', listing[i+4]) > 0) and						// rol :STACKORIGIN+STACKWIDTH+9; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta TT			; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9; 6
       (pos('sta ', listing[i+7]) > 0) then						// lda TT+1			; 7
      if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) and
	 (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+6] := #9'asl ' + copy(listing[i+2], 6, 256);
	listing[i+7] := #9'rol ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda TT 			; 0
       (listing[i+1] = #9'asl @') and							// asl @			; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta TT			; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := #9'asl ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===				IMUL.					  === //
// -----------------------------------------------------------------------------

    if (pos('lda #$', listing[i]) > 0) and						// lda #$			; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx			; 1
       (pos('lda #$', listing[i+2]) > 0) and						// lda #$			; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax			; 3
       (listing[i+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit		; 4
       (listing[i+5] = #9'fmulu_8') and							// fmulu_8			; 5
       (listing[i+6] = #9'els') and							// els				; 6
       (listing[i+7] = #9'imulCL') and 							// imulCL			; 7
       (listing[i+8] = #9'eif') then		 					// eif				; 8
       begin
	p:=GetVal(copy(listing[i], 6, 256)) * GetVal(copy(listing[i+2], 6, 256));

	listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
	listing[i+1] := #9'sta :eax';
	listing[i+2] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
	listing[i+3] := #9'sta :eax+1';
	listing[i+4] := '';//#9'lda #$00';
	listing[i+5] := '';//#9'sta :eax+2';
	listing[i+6] := '';//#9'lda #$00';
	listing[i+7] := '';//#9'sta :eax+3';

	listing[i+8] := '';

	Result:=false;
       end;


    if (pos('lda #$', listing[i]) > 0) and						// lda #$			; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx			; 1
       (pos('lda #$', listing[i+2]) > 0) and						// lda #$			; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax			; 3
       (listing[i+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit		; 4
       (listing[i+5] = #9'fmulu_8') and							// fmulu_8			; 5
       (listing[i+6] = #9'els') and							// els				; 6
       (listing[i+7] = #9'imulCL') and 							// imulCL			; 7
       (listing[i+8] = #9'eif') then		 					// eif				; 8
       begin
	p:=GetVal(copy(listing[i], 6, 256)) * GetVal(copy(listing[i+2], 6, 256));

	listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
	listing[i+1] := #9'sta :eax';
	listing[i+2] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
	listing[i+3] := #9'sta :eax+1';
	listing[i+4] := '';//#9'lda #$00';
	listing[i+5] := '';//#9'sta :eax+2';
	listing[i+6] := '';//#9'lda #$00';
	listing[i+7] := '';//#9'sta :eax+3';

	listing[i+8] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda #$00') and							// lda #$00	; 0
       (listing[i+1] = #9'sta :eax+2') and						// sta :eax+2	; 1
       (listing[i+2] = #9'lda #$00') and						// lda #$00	; 2
       (listing[i+3] = #9'sta :eax+3') and						// sta :eax+3	; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda #$80	; 4
       (listing[i+5] = #9'sta :ecx') and						// sta :ecx	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda #$01	; 6
       (listing[i+7] = #9'sta :ecx+1') and						// sta :ecx+1	; 7
       (listing[i+8] = #9'lda #$00') and						// lda #$00	; 8
       (listing[i+9] = #9'sta :ecx+2') and						// sta :ecx+2	; 9
       (listing[i+10] = #9'lda #$00') and						// lda #$00	; 10
       (listing[i+11] = #9'sta :ecx+3') and						// sta :ecx+3	; 11
       (listing[i+12] = #9'jsr imulECX') then						// jsr imulECX	; 12
      begin
	listing[i]   := listing[i+4];
	listing[i+1] := listing[i+5];
	listing[i+2] := listing[i+6];
	listing[i+3] := listing[i+7];

	listing[i+4] := #9'.ifdef fmulinit';
	listing[i+5] := #9'fmulu_16';
	listing[i+6] := #9'els';
	listing[i+7] := #9'imulCX';
	listing[i+8] := #9'eif';

	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp9		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda 			; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+2') and						// sta :eax+2		; 4
       (pos('lda ', listing[i+5]) > 0) and						// lda 			; 5
       (pos('sbc ', listing[i+6]) > 0) and						// sbc			; 6
       (listing[i+7] = #9'sta :eax+3') and 						// sta :eax+3		; 7
       (listing[i+8] = '@') and								//@			; 8
       (listing[i+9] = #9'lda :eax') and 						// lda :eax		; 9
       (pos('sta ', listing[i+10]) > 0) and 						// sta 			; 10
       (listing[i+11] = #9'lda :eax+1') and 						// lda :eax+1		; 11
       (pos('sta ', listing[i+12]) > 0) and 						// sta 			; 12
       (pos('lda :eax', listing[i+13]) = 0) then					// ~lda			; 13
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp9		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda 			; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+2') and						// sta :eax+2		; 4
       (pos('lda ', listing[i+5]) > 0) and						// lda 			; 5
       (pos('sbc ', listing[i+6]) > 0) and						// sbc			; 6
       (listing[i+7] = #9'sta :eax+3') and 						// sta :eax+3		; 7
       (listing[i+8] = '@') and								//@			; 8
       (pos('mwa ', listing[i+9]) > 0) and (pos(' :bp2', listing[i+9]) > 0) and		// mwa BASE :bp2	; 9
       (listing[i+10] = #9'ldy #$00') and 						// ldy #$00		; 10
       (listing[i+11] = #9'lda :eax') and 						// lda :eax		; 11
       add_Sub(i+12) and (pos(' (:bp2),y', listing[i+12]) > 0) and   			// add (:bp2),y		; 12
       (listing[i+13] = #9'iny') and							// iny			; 13
       (pos('sta ', listing[i+14]) > 0) and 						// sta			; 14
       (listing[i+15] = #9'lda :eax+1') and 						// lda :eax+1		; 15
       adc_sbc(i+16) and (pos(' (:bp2),y', listing[i+16]) > 0) and 			// adc (:bp2),y		; 16
       (pos('sta ', listing[i+17]) > 0) and 						// sta			; 17
       (pos('lda ', listing[i+18]) = 0) then						// ~lda			; 18

     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp9		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda 			; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+2') and						// sta :eax+2		; 4
       (pos('lda ', listing[i+5]) > 0) and						// lda 			; 5
       (pos('sbc ', listing[i+6]) > 0) and						// sbc			; 6
       (listing[i+7] = #9'sta :eax+3') and 						// sta :eax+3		; 7
       (listing[i+8] = '@') and								//@			; 8
       (pos('lda :STACK', listing[i+9]) > 0) and 					// lda :STACK		; 9
       add_sub(i+10) and (pos(' :eax', listing[i+10]) > 0) and 				// add|sub :eax		; 10
       (pos('sta ', listing[i+11]) > 0) and 						// sta			; 11
       (pos('lda :STACK', listing[i+12]) > 0) and 					// lda :STACK		; 12
       adc_sbc(i+13) and (pos(' :eax+1', listing[i+13]) > 0) and			// adc|sbc :eax+1	; 13
       (pos('sta ', listing[i+14]) > 0) and 						// sta			; 14
       (pos('lda ', listing[i+15]) = 0) then 						// ~lda			; 15
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp8		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda  		; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+1') and						// sta :eax+1		; 4
       (listing[i+5] = '@') and								//@			; 5
       (pos('lda :STACK', listing[i+6]) > 0) and 					// lda :STACK		; 6
       ((listing[i+7] = #9'add :eax') or						// add|sub :eax		; 7
	(pos('sub :eax', listing[i+7]) > 0)) and 					// sta :STACK		; 8
       (pos('sta :STACK', listing[i+8]) > 0) and 					// lda			; 9
       (pos('lda ', listing[i+9]) = 0) then
     if (copy(listing[i+4], 6, 256) <> copy(listing[i+7], 6, 256)) then
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp11		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (listing[i+2] = #9'lda :eax+2') and						// lda :eax+2 		; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+2') and						// sta :eax+2		; 4
       (listing[i+5] = #9'lda :eax+3') and						// lda :eax+3 		; 5
       (pos('sbc ', listing[i+6]) > 0) and						// sbc 			; 6
       (listing[i+7] = #9'sta :eax+3') and						// sta :eax+3		; 7
       (listing[i+8] = '@') and								//@			; 8
       (listing[i+9] = #9'lda :eax+1') and 						// lda :eax+1		; 9
       ((pos('sta ', listing[i+10]) > 0) or						// sta			; 10
	(listing[i+11] = #9'lda :eax')) then 						// lda :eax		; 11
     if (copy(listing[i+4], 6, 256) <> copy(listing[i+11], 6, 256)) and
	(copy(listing[i+7], 6, 256) <> copy(listing[i+11], 6, 256)) then
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp11		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (listing[i+2] = #9'lda :eax+2') and						// lda :eax+2 		; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+2') and						// sta :eax+2		; 4
       (listing[i+5] = #9'lda :eax+3') and						// lda :eax+3 		; 5
       (pos('sbc ', listing[i+6]) > 0) and						// sbc 			; 6
       (listing[i+7] = #9'sta :eax+3') and						// sta :eax+3		; 7
       (listing[i+8] = '@') and								//@			; 8
       (listing[i+9] = #9'lda :eax') and 						// lda :eax		; 9
       (pos(':eax+2', listing[i+10]) = 0) and
       (pos(':eax+2', listing[i+11]) = 0) and
       (pos(':eax+2', listing[i+12]) = 0) and
       (pos(':eax+2', listing[i+13]) = 0) and
       (pos(':eax+2', listing[i+14]) = 0) and
       (pos(':eax+2', listing[i+15]) = 0) and
       (pos(':eax+2', listing[i+16]) = 0) and
       (pos(':eax+2', listing[i+17]) = 0) and
       (pos(':eax+2', listing[i+18]) = 0) then
     if (copy(listing[i+4], 6, 256) <> copy(listing[i+9], 6, 256)) and
	(copy(listing[i+7], 6, 256) <> copy(listing[i+9], 6, 256)) then
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda ztmp11		; 0
       (listing[i+1] = #9'bpl @+') and							// bpl @+		; 1
       (listing[i+2] = #9'lda :eax+1') and						// lda :eax+1 		; 2
       (pos('sub ', listing[i+3]) > 0) and						// sub 			; 3
       (listing[i+4] = #9'sta :eax+1') and						// sta :eax+1		; 4
       (listing[i+5] = '@') and								//@			; 5
       (listing[i+6] = #9'lda :eax') and 						// lda :eax		; 6
       (pos(':eax+1', listing[i+7]) = 0) and
       (pos(':eax+1', listing[i+8]) = 0) and
       (pos(':eax+1', listing[i+9]) = 0) and
       (pos(':eax+1', listing[i+10]) = 0) and
       (pos(':eax+1', listing[i+11]) = 0) and
       (pos(':eax+1', listing[i+12]) = 0) and
       (pos(':eax+1', listing[i+13]) = 0) and
       (pos(':eax+1', listing[i+14]) = 0) and
       (pos(':eax+1', listing[i+15]) = 0) then
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) <> copy(listing[i+6], 6, 256)) then
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	Result:=false;
     end;


    if (pos('asl :STACK', listing[i]) > 0) and						// asl :STACKORIGIN+10	; 0
       (listing[i+1] = #9'rol @') and							// rol @		; 1
       (listing[i+2] = #9'sta :eax+1') and						// sta :eax+1		; 2
       (pos('lda :STACK', listing[i+3]) > 0) and					// lda :STACKORIGIN+10	; 3
       (listing[i+4] = #9'sta :eax') and						// sta :eax		; 4
       (listing[i+5] = #9'lda #$00') and						// lda #$00		; 5
       (listing[i+6] = #9'sta :eax+2') and						// sta :eax+2		; 6
       (listing[i+7] = #9'lda #$00') and						// lda #$00		; 7
       (listing[i+8] = #9'sta :eax+3') then 						// sta :eax+3		; 8
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin

	tmp:=#9'sta ' + copy(listing[i+3], 6, 256);
	insert('STACKWIDTH+', tmp, pos(':STACKORIGIN+', listing[i+3])+13);

	yes:=false;
	for p:=i+3 to l-1 do
	 if pos(':eax+1', listing[p]) > 0 then begin yes:=true; Break end;

	if not yes then listing[i+2] := tmp;

	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda 					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda					; 6
       add_sub(i+7) and									// add|sub				; 7
       (listing[i+8] = #9'sta :ecx') and 						// sta :ecx				; 8
       (pos('sta ', listing[i+9]) > 0) and 						// sta					; 9
       (pos('lda ', listing[i+10]) > 0) and 						// lda					; 10
       adc_sbc(i+11) and								// adc|sbc				; 11
       (listing[i+12] = #9'sta :ecx+1') and 						// sta :ecx+1				; 12
       (pos('sta ', listing[i+13]) > 0) and 						// sta					; 13
       (pos('lda :STACK', listing[i+14]) > 0) and 					// lda :STACKORIGIN+9			; 14
       (listing[i+15] = #9'sta :eax') and 						// sta :eax				; 15
       (pos('sta ', listing[i+16]) > 0) and 						// sta					; 16
       (pos('lda :STACK', listing[i+17]) > 0) and 					// lda :STACKORIGIN+STACKWIDTH+9	; 17
       (listing[i+18] = #9'sta :eax+1') and 						// sta :eax+1				; 18
       (pos('sta ', listing[i+19]) > 0) then 						// sta					; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) then
     begin

      listing_tmp[0]  := listing[i];
      listing_tmp[1]  := listing[i+1];
      listing_tmp[2]  := listing[i+15];
      listing_tmp[3]  := listing[i+16];

      listing_tmp[4]  := listing[i+3];
      listing_tmp[5]  := listing[i+4];
      listing_tmp[6]  := listing[i+18];
      listing_tmp[7]  := listing[i+19];

      listing_tmp[8]  := listing[i+6];
      listing_tmp[9]  := listing[i+7];
      listing_tmp[10] := listing[i+8];
      listing_tmp[11] := listing[i+9];
      listing_tmp[12] := listing[i+10];
      listing_tmp[13] := listing[i+11];
      listing_tmp[14] := listing[i+12];
      listing_tmp[15] := listing[i+13];

      listing[i+16] := '';
      listing[i+17] := '';
      listing[i+18] := '';
      listing[i+19] := '';

      for p:=0 to 15 do listing[i+p] := listing_tmp[p];

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda #$', listing[i]) = 0) and		// lda 					; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (pos('lda ', listing[i+2]) > 0) and (pos('lda #$', listing[i+2]) = 0) and	// lda 					; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda #$', listing[i+4]) > 0) and						// lda #$				; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda #$00', listing[i+6]) > 0) and 						// lda #$00				; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin

      tmp := listing[i];
      listing[i]   := listing[i+4];
      listing[i+4] := tmp;

      tmp := listing[i+2];
      listing[i+2] := listing[i+6];
      listing[i+6] := tmp;

      Result:=false;
     end;


    if (listing[i] = #9'lda #$02') and							// lda #$02				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda					; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin

      listing[i]   := listing[i+6];
      listing[i+1] := listing[i+7];
      listing[i+2] := listing[i+4];

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'rol :eax+1';
      listing[i+5] := #9'sta :eax';

      listing[i+6]  := '';
      listing[i+7]  := '';
      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$04') and							// lda #$04				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda					; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin

      listing[i]   := listing[i+6];
      listing[i+1] := listing[i+7];
      listing[i+2] := listing[i+4];

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'rol :eax+1';
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'rol :eax+1';
      listing[i+7] := #9'sta :eax';

      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda					; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin

      listing[i]   := listing[i+6];
      listing[i+1] := listing[i+7];
      listing[i+2] := listing[i+4];

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'rol :eax+1';
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'rol :eax+1';
      listing[i+7] := #9'asl @';
      listing[i+8] := #9'rol :eax+1';
      listing[i+9] := #9'sta :eax';

      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$10') and							// lda #$10				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda					; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin

      listing[i]   := listing[i+6];
      listing[i+1] := listing[i+7];
      listing[i+2] := listing[i+4];

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'rol :eax+1';
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'rol :eax+1';
      listing[i+7] := #9'asl @';
      listing[i+8] := #9'rol :eax+1';
      listing[i+9] := #9'asl @';
      listing[i+10]:= #9'rol :eax+1';
      listing[i+11] := #9'sta :eax';

      listing[i+12] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and							// lda #$00				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$01') and						// lda #$01				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda 					; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin

      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';

      listing[i+6] := listing[i+4];
      listing[i+4] := #9'lda #$00';

      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda 					; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda 					; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (listing[i+4] = #9'lda #$00') and						// lda #$00				; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (listing[i+6] = #9'lda #$01') and 						// lda #$01				; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') then 							// eif					; 12
     begin
      listing[i+6] := listing[i];
      listing[i+4] := #9'lda #$00';

      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';

      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
       (listing[i+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and 						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (listing[i+6] = #9'lda #$00') and 						// lda #$00				; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') and 							// eif					; 12
       (listing[i+13] = #9'lda :eax') and 						// lda :eax				; 13
       add_sub(i+14) and								// add|sub				; 14
       (listing[i+15] = #9'tay') then  							// tay					; 15
     begin

      listing[i]   := listing[i+4];
      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
      listing[i+4] := #9'asl @';

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';
      listing[i+13] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
       (listing[i+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and 						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (listing[i+6] = #9'lda #$00') and 						// lda #$00				; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[i+8] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 8
       (listing[i+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[i+10] = #9'els') and 							// els					; 10
       (listing[i+11] = #9'imulCX') and 						// imulCX				; 11
       (listing[i+12] = #9'eif') and 							// eif					; 12
       (pos('lda ', listing[i+13]) > 0) and 						// lda 					; 13
       add_sub(i+14) and								// add|sub				; 14
       ((listing[i+15] = #9'add :eax') or (listing[i+15] = #9'sub :eax')) and		// add|sub :eax				; 15
       (listing[i+16] = #9'tay') then 							// tay					; 16
     begin

      listing[i]   := listing[i+4];
      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
      listing[i+4] := #9'asl @';
      listing[i+5] := #9'sta :eax';

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
       (listing[i+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and 						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       (listing[i+4] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 4
       (listing[i+5] = #9'fmulu_16') and						// fmulu_16				; 5
       (listing[i+6] = #9'els') and 							// els					; 6
       (listing[i+7] = #9'imulCX') and 							// imulCX				; 7
       (listing[i+8] = #9'eif') and 							// eif					; 8
       (listing[i+9] = #9'lda :eax') and 						// lda :eax				; 9
       add_sub(i+10) and								// add|sub				; 10
       (listing[i+11] = #9'tay') then 							// tay					; 11
     begin

      listing[i]   := #9'lda :eax';
      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add :eax';
      listing[i+4] := #9'asl @';

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
       (listing[i+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$00') and 						// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       (listing[i+4] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 4
       (listing[i+5] = #9'fmulu_16') and						// fmulu_16				; 5
       (listing[i+6] = #9'els') and 							// els					; 6
       (listing[i+7] = #9'imulCX') and 							// imulCX				; 7
       (listing[i+8] = #9'eif') and 							// eif					; 8
       (pos('lda ', listing[i+9]) > 0) and 						// lda 					; 9
       AND_ORA_EOR(i+10) and								// and|ora|eor				; 10
       ((listing[i+11] = #9'add :eax') or (listing[i+11] = #9'sub :eax')) and		// add|sub :eax				; 11
       ((listing[i+12] = #9'tay') or (pos('sta :STACK', listing[i+12]) > 0)) then	// tay|sta :STACK			; 12
     begin

      listing[i]   := #9'lda :eax';
      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add :eax';
      listing[i+4] := #9'asl @';
      listing[i+5] := #9'sta :eax';

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';

      Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and 							// ldy #$00				; 0
       (pos('lda ', listing[i+1]) > 0) and 						// lda 					; 1
       (listing[i+2] = #9'spl') and 							// spl					; 2
       (listing[i+3] = #9'dey') and 							// dey					; 3
       (listing[i+4] = #9'sty :eax+1') and 						// sty :eax+1				; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (listing[i+6] = #9'lda #$0A') and 						// lda #$0a				; 6
       (listing[i+7] = #9'sta :ecx') and 						// sta :ecx				; 7
       (listing[i+8] = #9'lda #$00') and 						// lda #$00				; 8
       (listing[i+9] = #9'sta :ecx+1') and 						// sta :ecx+1				; 9
       (listing[i+10] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 10
       (listing[i+11] = #9'fmulu_16') and						// fmulu_16				; 11
       (listing[i+12] = #9'els') and 							// els					; 12
       (listing[i+13] = #9'imulCX') and 						// imulCX				; 13
       (listing[i+14] = #9'eif') and 							// eif					; 14
       (pos('lda ', listing[i+15]) > 0) and 						// lda 					; 15
       ((listing[i+16] = #9'add :eax') or (listing[i+16] = #9'sub :eax')) and		// add|sub :eax				; 16
       (listing[i+17] = #9'tay') then							// tay					; 17
     begin
      listing[i] := '';

      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'sta :eax';

      listing[i+7]  := '';
      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';

      if listing[i+16] = #9'add :eax' then begin
	listing[i+15] := #9'add ' + copy(listing[i+15], 6, 256);

	listing[i+6] := '';
	listing[i+16] := '';
      end;

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda 					; 0
       ((listing[i+1] = #9'sta :eax') or (listing[i+1] = #9'sta :ecx')) and		// sta :eax|:ecx			; 1
       (pos('sta ztmp', listing[i+2]) > 0) and						// sta ztmp...				; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       ((listing[i+4] = #9'sta :eax+1') or (listing[i+4] = #9'sta :ecx+1')) and		// sta :eax+1|:ecx+1			; 4
       (pos('sta ztmp', listing[i+5]) > 0) and 						// sta ztmp...				; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda :STACKORIGIN+10			; 6
       ((listing[i+7] = #9'sta :ecx') or (listing[i+7] = #9'sta :eax')) and 		// sta :ecx|:eax			; 7
       (pos('sta ztmp', listing[i+8]) > 0) and						// sta ztmp...				; 8
       (pos('lda ', listing[i+9]) > 0) and 						// lda					; 9
       ((listing[i+10] = #9'sta :ecx+1') or (listing[i+10] = #9'sta :eax+1')) and	// sta :ecx+1|:eax+1			; 10
       (pos('sta ztmp', listing[i+11]) > 0) and 					// sta ztmp...				; 11
       (listing[i+12] = #9'.ifdef fmulinit') and					// .ifdef fmulinit			; 12
       (listing[i+13] = #9'fmulu_16') and						// fmulu_16				; 13
       (listing[i+14] = #9'els') and							// els					; 14
       (listing[i+15] = #9'imulCX') and 						// imulCX				; 15
       (listing[i+16] = #9'eif') and							// eif					; 16
       (pos('lda ztmp', listing[i+17]) = 0) then 					// ~lda ztmp...				; 17
     begin
      listing[i+2]  := '';
      listing[i+5]  := '';
      listing[i+8]  := '';
      listing[i+11] := '';

      Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 0
       (pos('lda ', listing[i+1]) > 0) and						// lda 					; 1
       (listing[i+2] = #9'sta :ecx') and						// sta :ecx				; 2
       (pos('sta ', listing[i+3]) > 0) and						// sta ztmp8				; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda					; 4
       (listing[i+5] = #9'sta :ecx+1') and 						// sta :ecx+1				; 5
       (pos('sta ', listing[i+6]) > 0) and 						// sta ztmp9				; 6
       (pos('lda :STACK', listing[i+7]) > 0) and 					// lda :STACKORIGIN+10			; 7
       (listing[i+8] = #9'sta :eax') and 						// sta :eax				; 8
       (pos('sta ', listing[i+9]) > 0) and						// sta ztmp10				; 9
       (pos('lda :STACK', listing[i+10]) > 0) and 					// lda :STACKORIGIN+STACKWIDTH+10	; 10
       (listing[i+11] = #9'sta :eax+1') and 						// sta :eax+1				; 11
       (pos('sta ', listing[i+12]) > 0) then 						// sta ztmp11				; 12
     if copy(listing[i], 6, 256) = copy(listing[i+10], 6, 256) then
     begin
      listing_tmp[0]  := listing[i+7];
      listing_tmp[1]  := listing[i+8];
      listing_tmp[2]  := listing[i+9];
      listing_tmp[3]  := listing[i+10];
      listing_tmp[4]  := listing[i+11];
      listing_tmp[5]  := listing[i+12];

      listing_tmp[6]  := listing[i+1];
      listing_tmp[7]  := listing[i+2];
      listing_tmp[8]  := listing[i+3];
      listing_tmp[9]  := listing[i+4];
      listing_tmp[10] := listing[i+5];
      listing_tmp[11] := listing[i+6];

      for p:=0 to 11 do listing[i+1+p] := listing_tmp[p];

      Result:=false;
     end;

   end;

   end;


   function PeepholeOptimization: Boolean;
   var i, p, err: integer;
       old, tmp: string;
       btmp: array [0..15] of string;
       yes: Boolean;
   begin

   Result:=true;

   Rebuild;

  for i := 0 to l - 1 do
   if listing[i] <> '' then begin

// -----------------------------------------------------------------------------
// ===				optymalizacja LDA.			  === //
// -----------------------------------------------------------------------------

    if (pos('lda #$', listing[i]) > 0) and (pos('sta @FORTMP_', listing[i+1]) > 0) then	// zamiana na MVA aby zadzialala optymalizacja OPTYFOR
    begin
     listing[i+1] := #9'mva ' + copy(listing[i], 6, 4) + ' ' +  copy(listing[i+1], 6, 256);
     listing[i] := '';
     Result:=false;
    end;

  if pos('@FORTMP_', listing[i]) = 0 then begin						// !!! @FORTMP_ bez optymalizacji !!!


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and 	// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) and (pos('mva #$', listing[i+3]) > 0) and	// mva #$xx	; 1
       (pos('sta ', listing[i+4]) = 0) then						// mva #$xx	; 2
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and 			// mva #$xx	; 3
	(copy(listing[i+1], 6, 4) = copy(listing[i+2], 6, 4)) and
	(copy(listing[i+2], 6, 4) = copy(listing[i+3], 6, 4)) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       listing[i+3] := #9'sta' + copy(listing[i+3], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and	// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) and (pos('mva #$', listing[i+3]) > 0) and	// mva #$yy	; 1
       (pos('sta ', listing[i+4]) = 0) then						// mva #$zz	; 2
     if (copy(listing[i], 6, 4) = copy(listing[i+3], 6, 4)) and				// mva #$xx	; 3
	(copy(listing[i], 6, 4) <> copy(listing[i+1], 6, 4)) and
	(copy(listing[i+1], 6, 4) <> copy(listing[i+2], 6, 4)) and
	(copy(listing[i+2], 6, 4) <> copy(listing[i+3], 6, 4)) then begin

       tmp := listing[i];

       listing[i]   := listing[i+1];
       listing[i+1] := listing[i+2];
       listing[i+2] := tmp;

       listing[i+3] := #9'sta' + copy(listing[i+3], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and 	// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) = 0) then	// mva #$xx	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and 			// mva #$xx	; 2
	(copy(listing[i+1], 6, 4) = copy(listing[i+2], 6, 4)) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and	// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) = 0) then	// mva #$yy	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4)) and				// mva #$xx	; 2
	(copy(listing[i], 6, 4) <> copy(listing[i+1], 6, 4)) then begin

       tmp := listing[i];

       listing[i]   := listing[i+1];
       listing[i+1] := tmp;

       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and		// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) = 0) then	// sta		; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4)) then begin			// mva #$xx	; 2

       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and	// mva #$xx	; 0
       (pos('sta ', listing[i+2]) = 0) then						// mva #$xx	; 1
     if copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       Result:=false;
     end;


  end;  // @FORTMP_


    if (listing[i] = #9'lda #$00') and								// lda #$00	; 0
       ((pos('sta ', listing[i+1]) > 0) or (pos('ldy ', listing[i+1]) > 0)) and			// sta|ldy	; 1
       (pos('mva #$00 ', listing[i+2]) > 0) then						// mva #$00	; 2
//       (pos('sta ', listing[i+3]) > 0) then							// sta		; 3
     begin
	listing[i+2] := #9'sta ' + copy(listing[i+2], 11, 256);
	Result:=false;
     end;


    if (pos('lda #', listing[i]) = 0) and (pos('lda #', listing[i+2]) = 0) and			// lda TEMP	; 0
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// sta		; 1
       (pos('lda ', listing[i+2]) > 0) then							// lda TEMP	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then begin
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// lda XI	; 0
       (pos('sta ', listing[i+2]) > 0) and							// sta :ecx	; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('sta ', listing[i+4]) > 0) and			// sta ztmp8	; 2
       (pos('sta ', listing[i+5]) > 0) and							// lda XI+1	; 3
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) and			// sta :ecx+1	; 4
       (pos('sta ', listing[i+8]) > 0) and							// sta ztmp9	; 5
       (pos('lda ', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and			// lda XI	; 6
       (pos('sta ', listing[i+11]) > 0) then							// sta :eax	; 7
     if (listing[i] = listing[i+6]) and								// sta ztmp10	; 8
	(listing[i+3] = listing[i+9]) and							// lda XI+1	; 9
	(copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and				// sta :eax+1	; 10
	(copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) and				// sta ztmp11	; 11
	(copy(listing[i+3], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i+4], 6, 256) <> copy(listing[i+5], 6, 256)) and
	(copy(listing[i+6], 6, 256) <> copy(listing[i+7], 6, 256)) and
	(copy(listing[i+7], 6, 256) <> copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) <> copy(listing[i+10], 6, 256)) and
	(copy(listing[i+10], 6, 256) <> copy(listing[i+11], 6, 256)) then
      begin
	tmp:=listing[i+4];

	listing[i+4]:=listing[i+7];
	listing[i+7]:=tmp;

	tmp:=listing[i+5];
	listing[i+5]:=listing[i+8];
	listing[i+8]:=tmp;

	listing[i+6]:=listing[i+9];

	listing[i+3] := '';
	listing[i+9] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// lda A	; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and			// sta :ecx	; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// lda A+1	; 2
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) then			// sta :ecx+1	; 3
     if (listing[i] = listing[i+4]) and								// lda A	; 4
	(listing[i+2] = listing[i+6]) and							// sta :eax	; 5
	(copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and				// lda A+1	; 6
	(copy(listing[i+2], 6, 256) <> copy(listing[i+3], 6, 256)) and				// sta :eax+1	; 7
	(copy(listing[i+4], 6, 256) <> copy(listing[i+5], 6, 256)) and
	(copy(listing[i+6], 6, 256) <> copy(listing[i+7], 6, 256)) then
      begin
	listing[i+4] := listing[i+2];

	listing[i+2] := listing[i+5];

	listing[i+5] := '';
	listing[i+6] := listing[i+3];

	listing[i+3] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// lda 		; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and			// sta A	; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// lda 		; 2 --
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) then			// sta A+1	; 3  |
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and 				// lda A	; 4  | <> !!!
	(copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta		; 5 --
	(copy(listing[i+2], 6, 256) <> copy(listing[i+5], 6, 256)) then				// lda A+1	; 6
     begin											// sta		; 7
	listing[i+4] := listing[i];
	listing[i+6] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

      	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('ldy ', listing[i+3]) > 0) and							// ldy					; 3
       (pos('lda :STACK', listing[i+4]) > 0) and						// lda :STACKORIGIN+10			; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta					; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 6
       (pos('sta ', listing[i+7]) > 0) then							// sta					; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i+4] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and 							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// add|sub				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+10			; 6
       (pos('sta ', listing[i+7]) > 0) and							// sta					; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta					; 8
       (pos('lda ', listing[i+9]) > 0) then							// lda					; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i+6] := listing[i+5];
	listing[i+5] := listing[i+4];
	listing[i+4] := listing[i+3];

	listing[i+2] := listing[i+7];
	listing[i+3] := listing[i+8];

	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false;
      end;


// -----------------------------------------------------------------------------
// ===				optymalizacja regY.			  === //
// -----------------------------------------------------------------------------

    if (pos('ldy #$', listing[i]) > 0) and 						// ldy #$				; 0
       (pos('lda adr.', listing[i+1]) > 0) and 						// lda adr.				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and 					// sta :STACKORIGIN+10			; 2
       (pos('lda :STACK', listing[i+3]) > 0) and 					// lda :STACKORIGIN+10			; 3
       (listing[i+4] = #9'sta :ecx') and 						// sta :ecx				; 4
       (listing[i+5] = #9'lda #$03') and 						// lda #$03				; 5
       (listing[i+6] = #9'sta :eax') and 						// sta :ecx				; 6
       (listing[i+7] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 7
       (listing[i+8] = #9'fmulu_8') and							// fmulu_8				; 8
       (listing[i+9] = #9'els') and 							// els					; 9
       (listing[i+10] = #9'imulCL') and 						// imulCL				; 10
       (listing[i+11] = #9'eif') then 							// eif					; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin

	delete(listing[i+1], pos(',y', listing[i+1]), 2);
	listing[i+2] := listing[i+1] + '+' + copy(listing[i], 6+1, 256);

	listing[i]   := #9'lda #$00';
	listing[i+1] := #9'sta :eax+1';

	listing[i+3] := #9'asl @';
	listing[i+4] := #9'rol :eax+1';

	listing[i+5] := #9'add ' + copy(listing[i+2], 6, 256);
	listing[i+6] := #9'sta :eax';
	listing[i+7] := #9'lda :eax+1';
	listing[i+8] := #9'adc #$00';
	listing[i+9] := #9'sta :eax+1';

	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
     end;


    if (pos('ldy ', listing[i]) > 0) and (pos('ldy #$', listing[i]) = 0) and		// ldy 					; 0
       (pos('lda ', listing[i+1]) > 0) and						// lda ,y				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and 					// sta :STACKORIGIN+10			; 2
       (pos('lda :STACK', listing[i+3]) > 0) and 					// lda :STACKORIGIN+10			; 3
       (listing[i+4] = #9'sta :ecx') and 						// sta :ecx				; 4
       (listing[i+5] = #9'lda #$03') and 						// lda #$03				; 5
       (listing[i+6] = #9'sta :eax') and 						// sta :ecx				; 6
       (listing[i+7] = #9'.ifdef fmulinit') and 					// .ifdef fmulinit			; 7
       (listing[i+8] = #9'fmulu_8') and							// fmulu_8				; 8
       (listing[i+9] = #9'els') and 							// els					; 9
       (listing[i+10] = #9'imulCL') and 						// imulCL				; 10
       (listing[i+11] = #9'eif') then 							// eif					; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i+2] := listing[i];
	listing[i+3] := listing[i+1];

	listing[i]   := #9'lda #$00';
	listing[i+1] := #9'sta :eax+1';

	listing[i+4] := #9'asl @';
	listing[i+5] := #9'rol :eax+1';

	listing[i+6] := #9'add ' + copy(listing[i+3], 6, 256);
	listing[i+7] := #9'sta :eax';
	listing[i+8] := #9'lda :eax+1';
	listing[i+9] := #9'adc #$00';
	listing[i+10] := #9'sta :eax+1';

	listing[i+11] := '';

	Result:=false;
     end;


    if Result and									// "samotna" instrukcja na koncu bloku
       ((pos('ldy ', listing[i]) > 0) or (pos('lda ', listing[i]) > 0)) and
       (listing[i+1] = '') then begin

	listing[i] := '';

	optyY := '';

	Result:=false;
       end;


    if ((listing[i] = #9'iny') or (listing[i] = #9'dey')) and				// iny|dey
       ((pos('ldy ', listing[i+1]) > 0) or (pos('mvy ', listing[i+1]) > 0)) then	// ldy|mvy
       begin
	listing[i] := '';

	optyY := '';

	Result:=false;
       end;


    if (pos('ldy ', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) then		// ldy
       begin										// sty
	listing[i] := #9'lda ' + copy(listing[i], 6, 256);

	k:=i+1;
	while pos('sty ',listing[k]) > 0 do begin
	 listing[k] := #9'sta ' + copy(listing[k], 6, 256);
	 inc(k);
	end;

	optyY := '';

	Result:=false;
       end;


    if (pos('ldy #$', listing[i]) > 0) and (pos(' adr.', listing[i+1]) > 0) and		// ldy #$
       (pos('mva #', listing[i+1]) > 0) and (pos(',y', listing[i+1]) > 0) then		// mva #$xx adr.xxx,y
       begin
	delete(listing[i+1], pos(',y', listing[i+1]), 2);
	listing[i+1] := listing[i+1] + '+' + copy(listing[i], 6+1, 256);

	tmp := listing[i];

	listing[i]   := listing[i+1];
	listing[i+1] := tmp;

	optyY := '';

	Result:=false;
       end;


//	ldy #$08
//	lda adr.PAC_SPRITES,y
//	sta :STACKORIGIN+10
//	lda adr.PAC_SPRITES+1,y
//	sta :STACKORIGIN+STACKWIDTH+10

    if (pos('ldy #$', listing[i]) > 0) and						// ldy #
       (pos('a adr.', listing[i+1]) > 0) and (pos(',y', listing[i+1]) > 0) then		// lda|sta adr.xxx,y
       begin

	yes := false;

	p:=i+1;
	while p < l do begin

	if (pos('cmp ', listing[p]) > 0) or (pos('bne ', listing[p]) > 0) or (pos('beq ', listing[p]) > 0) or	// wyjatki dla ktorych
	   (pos('bcc ', listing[p]) > 0) or (pos('bcs ', listing[p]) > 0) or (listing[p] = #9'tya') or		// musimy zachowac ldy #$xx
	   (listing[p] = #9'dey') or (listing[p] = #9'iny') or
	   (pos('bpl ', listing[p]) > 0) or (pos('bmi ', listing[p]) > 0) or
	   (listing[p] = #9'spl') or (listing[p] = #9'smi') or
	   (listing[p] = #9'seq') or (listing[p] = #9'sne')
	then begin
	 yes:=true; Break
	end;

	if not( (pos('lda ', listing[p]) > 0) or (pos('sta ', listing[p]) > 0) or
	        AND_ORA_EOR(p) or ADD_SUB(p) or ADC_SBC(p) ) then Break;

	if (pos('a adr.', listing[p]) > 0) and (pos(',y', listing[p]) > 0) then begin
	 delete(listing[p], pos(',y', listing[p]), 2);
	 listing[p] := listing[p] + '+' + copy(listing[i], 6+1, 256);

	 optyY := '';
	end;

	inc(p);
       end;

       if not yes then listing[i] := '';

       Result:=false;
       end;


//	ldy #$08
//	lda :STACKORIGIN+10
//	sta adr.PAC_SPRITES,y
//	lda :STACKORIGIN+STACKWIDTH+10
//	sta adr.PAC_SPRITES+1,y

    if (pos('ldy #$', listing[i]) > 0) and (pos(',y', listing[i+1]) = 0) and
       (pos('a adr.', listing[i+2]) > 0) and (pos(',y', listing[i+2]) > 0) then
       begin

	yes := false;

	p:=i+2;
	while p < l do begin

	if (pos('cmp ', listing[p]) > 0) or (pos('bne ', listing[p]) > 0) or (pos('beq ', listing[p]) > 0) or		// wyjatki dla ktorych
	   (pos('bcc ', listing[p]) > 0) or (pos('bcs ', listing[p]) > 0) or (listing[p] = #9'tya') or			// musimy zachowac ldy #$xx
	   (listing[p] = #9'dey') or (listing[p] = #9'iny') or
	   (pos('bpl ', listing[p]) > 0) or (pos('bmi ', listing[p]) > 0) or
	   (listing[p] = #9'spl') or (listing[p] = #9'smi') or
	   (listing[p] = #9'seq') or (listing[p] = #9'sne')
	then begin
	 yes:=true; Break
	end;

	if not( (pos('lda ', listing[p]) > 0) or (pos('sta ', listing[p]) > 0) or
	        AND_ORA_EOR(p) or ADD_SUB(p) or ADC_SBC(p) ) then Break;

	if (pos('a adr.', listing[p]) > 0) and (pos(',y', listing[p]) > 0) then begin
	 delete(listing[p], pos(',y', listing[p]), 2);
	 listing[p] := listing[p] + '+' + copy(listing[i], 6+1, 256);

	 optyY := '';
	end;

	inc(p);
       end;

       if not yes then listing[i] := '';

       Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and (pos(',y', listing[i]) = 0) and		// lda 	~,y	; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and (pos(',y', listing[i+2]) = 0) and	// sta A	; 1
       (pos('lda ', listing[i+5]) > 0) and (pos('sta ', listing[i+6]) > 0) and						// lda 	~,y	; 2
       (pos('lda ', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and						// sta A+1	; 3
       (pos('ldy ', listing[i+4]) > 0)  then										// ldy 		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and 							// lda A	; 5
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then							// sta		; 6
     begin														// lda A+1	; 7
	listing[i+5] := listing[i];											// sta		; 8
	listing[i+7] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

      	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and						// lda
       (pos('ldy ', listing[i+1]) > 0) and (pos('cmp ', listing[i+2]) > 0) then						// ldy #
       begin														// cmp
	tmp := listing[i];
	listing[i] := listing[i+1];
	listing[i+1] := tmp;
	Result:=false;
       end;


    if (pos('ldy ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and	// ldy I		; 0
       (pos('ldy ', listing[i+3]) > 0) then										// lda			; 1
      if listing[i] = listing[i+3] then											// sta :STACKORIGIN+9	; 2
       begin														// ldy I		; 3
	listing[i+3] := '';
	Result:=false;
       end;


    if (pos('ldy ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) and	// ldy I
       (pos('ldy ', listing[i+2]) > 0) then										// lda adr...,y
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin						// ldy I
	listing[i+2] := '';												// sta adr...,y
	Result:=false;
       end;


    if (pos('ldy ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and (pos('sta ', listing[i+4]) > 0) and	// ldy I		; 0
       add_sub(i+2) and													// lda adr...,y		; 1
       (pos('ldy ', listing[i+3]) > 0) then										// add|subadd|sub	; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin						// ldy I		; 3
	listing[i+3] := '';												// sta adr...,y		; 4
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'add #$01') and 						// lda I
       (pos('sta :STACK', listing[i+2]) > 0) then									// add #$01
     if (pos('ldy ', listing[i+3]) > 0) and (pos('lda ', listing[i+4]) > 0) and 					// sta :STACKORIGIN+9
	(pos('ldy :STACK', listing[i+5]) > 0) then									// ldy I
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and							// lda
	 (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then begin						// ldy :STACKORIGIN+9
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+5] := #9'iny';
	Result:=false;
       end;


    if (pos('ldy ', listing[i]) > 0) and (listing[i+1] = #9'iny') and (pos('ldy ', listing[i+3]) > 0) and		// ldy I
       ( (pos('lda ', listing[i+2]) > 0) or (pos('sta ', listing[i+2]) > 0)) then					// iny
       if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then begin						// lda|sta xxx
	listing[i+3] := #9'dey';											// ldy I
	Result:=false;
       end;


// -----------------------------------------------------------------------------

//	lda adr.L_BLOCK,y		; 0
//	sta :STACKORIGIN+9		; 1
//	lda adr.H_BLOCK,y		; 2
//	sta :STACKORIGIN+STACKWIDTH+10	; 3
//	lda #$00			; 4
//	add :STACKORIGIN+9		; 5
//	sta TB				; 6
//	lda #$00			; 7
//	adc :STACKORIGIN+STACKWIDTH+10	; 8
//	sta TB+1			; 9

    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('add :STACK', listing[i+5]) > 0)  then
       if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+2]) = 0) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+3]) = 0) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+4]) = 0) then
       begin
	listing[i+5] := #9'add '+copy(listing[i], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('adc :STACK', listing[i+6]) > 0)  then
       if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+2]) = 0) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+3]) = 0) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+4]) = 0) and
	  (pos(copy(listing[i+1], 6, 256), listing[i+5]) = 0) then
       begin
	listing[i+6] := #9'adc '+copy(listing[i], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda :STACK', listing[i+1]) > 0) and	// sta :STACKORIGIN+10			; 0
       adc_sbc(i+2) and										// lda :STACKORIGIN+STACKWIDTH+10	; 1
       (pos('sta :STACK', listing[i+3]) > 0) and						// adc|sbc				; 2
       (pos('ldy :STACK', listing[i+4]) > 0) and (pos('lda :STACK', listing[i+5]) > 0) and	// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('sta adr.', listing[i+6]) > 0) and							// ldy :STACKORIGIN+9			; 4
       (pos('lda :STACK', listing[i+7]) > 0) and						// lda :STACKORIGIN+10			; 5
       (pos('sta adr.', listing[i+8]) > 0) then							// sta adr.MXD,y			; 6
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and 				// lda :STACKORIGIN+STACKWIDTH+10	; 7
	(copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and				// sta adr.MXD+1,y			; 8
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
	listing[i+3] := listing[i+1];

	listing[i]   := listing[i+4];
	listing[i+1] := listing[i+6];

	listing[i+4] := listing[i+2];

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

      	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and			// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+9			; 1
       (pos('ldy ', listing[i+2]) > 0) and							// ldy					; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       (pos('ldy :STACK', listing[i+4]) > 0) then						// ldy :STACKORIGIN+9			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+4] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

      	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (listing[i+1] = #9'asl @') and								// asl @				; 1
       (listing[i+2] = #9'tay') and								// tay					; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       add_sub(i+4) and										// add|sub				; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta					; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta					; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda					; 9
       (listing[i+10] = #9'asl @') and								// asl @				; 10
       (listing[i+11] = #9'tay') then								// tay					; 11
     if listing[i] = listing[i+9] then
     begin
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

      	Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===				FILL.					  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and							// lda :STACKORIGIN+9			; 0
       add_sub(i+1) and										// add :STACKORIGIN+10			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda :STACKORIGIN+STACKWIDTH+9	; 3
       adc_sbc(i+4) and										// adc :STACKORIGIN+STACKWIDTH+10	; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*2+9	; 6
       adc_sbc(i+7) and										// adc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*3+9	; 9
       adc_sbc(i+10) and									// adc #$00				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta :edx') and		// lda :STACKORIGIN+9			; 12
       (pos('lda :STACK', listing[i+14]) > 0) and (listing[i+15] = #9'sta :edx+1') then		// sta :edx				; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+9	; 14
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then				// sta :edx+1				; 15
       begin
	listing[i+2] := listing[i+13];
	listing[i+5] := listing[i+15];

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===				MOVE.					  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       ((listing[i+1] = #9'add :eax') or (listing[i+1] = #9'sub :eax')) and			// add|sub :eax				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda 					; 3
       ((listing[i+4] = #9'adc :eax+1') or (listing[i+4] = #9'sbc :eax+1')) and			// adc|sbc :eax+1			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       ((listing[i+7] = #9'adc :eax+2') or (listing[i+7] = #9'sbc :eax+2')) and			// adc|sbc :eax+2			; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda 					; 9
       ((listing[i+10] = #9'adc :eax+3') or (listing[i+10] = #9'sbc :eax+3')) and		// adc|sbc :eax+3			; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and						// lda :STACKORIGIN+10			; 12
       add_sub(i+13) and									// add|sub 				; 13
       (pos('sta ', listing[i+14]) > 0) and							// sta 					; 14
       (pos('lda :STACK', listing[i+15]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 15
       adc_sbc(i+16) and									// adc|sbc 				; 16
       (pos('sta ', listing[i+17]) > 0) and							// sta 					; 17
       (pos('lda ', listing[i+18]) > 0) then							// lda :STACKORIGIN+9			; 18
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+8], 6, 256) <> copy(listing[i+18], 6, 256)) then			// <>
       begin

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda #$00				; 0
       ((listing[i+1] = #9'add :eax') or (listing[i+1] = #9'sub :eax')) and			// add|sub :eax				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda #$A8				; 3
       ((listing[i+4] = #9'adc :eax+1') or (listing[i+4] = #9'sbc :eax+1')) and			// adc|sbc :eax+1			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda #$00				; 6
       adc_sbc(i+7) and										// adc|sbc #$00				; 7
       (listing[i+8] = #9'sta :eax+2') and							// sta :eax+2				; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda #$00				; 9
       adc_sbc(i+10) and									// adc|sbc #$00				; 10
       (listing[i+11] = #9'sta :eax+3') and							// sta :eax+3				; 11
       (pos('lda :STACK', listing[i+12]) > 0) and						// lda :STACKORIGIN+10			; 12
       (pos('add ', listing[i+13]) > 0) and							// add #$A1				; 13
       (pos('sta :STACK', listing[i+14]) > 0) and						// sta :STACKORIGIN+10			; 14
       (pos('lda :STACK', listing[i+15]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 15
       (pos('adc ', listing[i+16]) > 0) and							// adc #$00				; 16
       (pos('sta :STACK', listing[i+17]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 17
       (pos('lda :STACK', listing[i+18]) = 0) then						// lda #$28				; 18
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+12], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+10			; 0
       add_sub(i+1) and										// add|sub #$35				; 1
       (listing[i+2] = #9'sta :edx') and							// sta :edx				; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc(i+4) and										// adc|sbc #$00				; 4
       (listing[i+5] = #9'sta :edx+1') and							// sta :edx+1				; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_sbc(i+7) and										// adc|sbc #$00				; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_sbc(i+10) and									// adc|sbc #$00				; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
      begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;

{ !!! fiu fiu

    if (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+9			; 0
       ((pos('add :STACK', listing[i+1]) > 0) or (pos('sub :STACK', listing[i+1]) > 0)) and	// add|sub :STACKORIGIN+10		; 1
       (listing[i+2] = #9'sta :edx') and							// sta :edx				; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 3
       ((pos('adc :STACK', listing[i+4]) > 0) or (pos('sbc :STACK', listing[i+4]) > 0)) and	// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 4
       (listing[i+5] = #9'sta :edx+1') then							// sta :edx+1				; 5
      if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+3], 6, 256) <> copy(listing[i+4], 6, 256)) then
      begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;
}

    if (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+10			; 0
       add_sub(i+1) and										// add|sub #$35				; 1
       (listing[i+2] = #9'sta :ecx') and							// sta :ecx				; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc(i+4) and										// adc|sbc #$00				; 4
       (listing[i+5] = #9'sta :ecx+1') and							// sta :ecx+1				; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_sbc(i+7) and										// adc|sbc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_sbc(i+10) and									// adc|sbc #$00				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda ', listing[i+12]) > 0) and							// lda #$B3				; 12
       (listing[i+13] = #9'sta :edx') and							// sta :edx				; 13
       (pos('lda ', listing[i+14]) > 0) and							// lda #$20				; 14
       (listing[i+15] = #9'sta :edx+1') then							// sta :edx+1				; 15
     if (copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and								// ldy #$00				; 0
       (pos('lda :STACK', listing[i+1]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+11	; 1
       (listing[i+2] = #9'spl') and								// spl					; 2
       (listing[i+3] = #9'dey') and								// dey					; 3
       (pos('sta :STACK', listing[i+4]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+11	; 4
       (pos('sty :STACK', listing[i+5]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*2+11	; 5
       (pos('sty :STACK', listing[i+6]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*3+11	; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda 					; 7
       add_sub_stack(i+8) and									// add|sub :STACKORIGIN+11		; 8
       (listing[i+9] = #9'sta :ecx') and							// sta :ecx				; 9
       (pos('lda ', listing[i+10]) > 0) and							// lda 					; 10
       adc_sbc_stack(i+11) and									// adc|sbc :STACKORIGIN+STACKWIDTH+11	; 11
       (listing[i+12] = #9'sta :ecx+1') and							// sta :ecx+1				; 12
       (pos('lda ', listing[i+13]) = 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+5] := '';
	listing[i+6] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub :STACKORIGIN+11		; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc :STACKORIGIN+STACKWIDTH+11	; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda 					; 6
       adc_sbc(i+7) and 									// adc|sbc :STACKORIGIN+STACKWIDTH*2+11	; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda					; 9
       adc_sbc(i+10) and									// adc|sbc :STACKORIGIN+STACKWIDTH*3+11	; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta :edx') and		// lda :STACKORIGIN+9			; 12
       (pos('lda :STACK', listing[i+14]) > 0) and (listing[i+15] = #9'sta :edx+1') and		// sta :edx				; 13
       (pos('lda :STACK', listing[i+16]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 14
       (listing[i+17] = #9'sta :ecx') and							// sta :edx+1				; 15
       (pos('lda :STACK', listing[i+18]) > 0) and						// lda :STACKORIGIN+10			; 16
       (listing[i+19] = #9'sta :ecx+1') then							// sta :ecx				; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+16], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+10	; 18
	(copy(listing[i+5], 6, 256) = copy(listing[i+18], 6, 256)) then				// sta :ecx+1				; 19
       begin
	listing[i+2] := listing[i+17];
	listing[i+5] := listing[i+19];

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda :STACKORIGIN+10			; 0
       add_sub(i+1) and										// add|sub :STACKORIGIN+11		; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc(i+4) and										// adc|sbc :STACKORIGIN+STACKWIDTH+11	; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_sbc(i+7) and										// adc|sbc :STACKORIGIN+STACKWIDTH*2+11	; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_sbc(i+10) and									// adc|sbc :STACKORIGIN+STACKWIDTH*3+11	; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('mwa ', listing[i+12]) > 0) and (pos(' :bp2', listing[i+12]) > 0) and		// mwa xx bp2				; 12
       (pos('ldy ', listing[i+13]) > 0) and							// ldy #$0A				; 13
       (listing[i+14] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+15]) > 0) and	// lda (:bp2),y				; 14
       (pos('lda :STACK', listing[i+16]) > 0) and (listing[i+17] = #9'sta :edx') and		// sta :STACKORIGIN+11			; 15
       (pos('lda :STACK', listing[i+18]) > 0) and (listing[i+19] = #9'sta :edx+1') and		// lda :STACKORIGIN+9			; 16
       (pos('lda :STACK', listing[i+20]) > 0) and 						// sta :edx				; 17
       (listing[i+21] = #9'sta :ecx') and							// lda :STACKORIGIN+STACKWIDTH+9	; 18
       (pos('lda :STACK', listing[i+22]) > 0) and						// sta :edx+1				; 19
       (listing[i+23] = #9'sta :ecx+1') then							// lda :STACKORIGIN+10			; 20
     if (copy(listing[i+2], 6, 256) = copy(listing[i+20], 6, 256)) and				// sta :ecx				; 21
	(copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) then				// lda :STACKORIGIN+STACKWIDTH+10	; 22
       begin											// sta :ecx+1				; 23
	listing[i+2] := listing[i+21];
	listing[i+5] := listing[i+23];

	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+9			; 1
       (listing[i+2] = #9'iny') and								// iny					; 2
       (listing[i+3] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 3
       (pos('sta :STACK', listing[i+4]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+5]) > 0) and							// lda #$80				; 5
       (pos('add ', listing[i+6]) > 0) and							// add PAC.SY				; 6
       (listing[i+7] = #9'sta :ecx') and							// sta :ecx				; 7
       (pos('lda ', listing[i+8]) > 0) and							// lda #$C1				; 8
       (pos('adc ', listing[i+9]) > 0) and							// adc PAC.SY+1				; 9
       (listing[i+10] = #9'sta :ecx+1') and							// sta :ecx+1				; 10
       (pos('lda :STACK', listing[i+11]) > 0) and (listing[i+12] = #9'sta :edx') and		// lda :STACKORIGIN+9			; 11
       (pos('lda :STACK', listing[i+13]) > 0) and (listing[i+14] = #9'sta :edx+1') then		// sta :edx				; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+9	; 13
	(copy(listing[i+4], 6, 256) = copy(listing[i+13], 6, 256)) then				// sta :edx+1				; 14
       begin
	listing[i+1] := listing[i+12];
	listing[i+4] := listing[i+14];

	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+9			; 1
       (listing[i+2] = #9'iny') and								// iny					; 2
       (listing[i+3] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 3
       (pos('sta :STACK', listing[i+4]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda :STACK', listing[i+5]) > 0) and						// lda :STACKORIGIN+9			; 5
       (pos('sta ', listing[i+6]) > 0) and							// sta					; 6
       (pos('lda :STACK', listing[i+7]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 7
       (pos('sta ', listing[i+8]) > 0) then							// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+1] := listing[i+6];
	listing[i+4] := listing[i+8];

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda K				; 0
       add_sub(i+1) and										// add #$15				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda K+1				; 3
       adc_sbc(i+4) and										// adc #$00				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda Q				; 6
       add_sub(i+7) and										// sub #$05				; 7
       (listing[i+8] = #9'sta :ecx') and							// sta :ecx				; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda Q+1				; 9
       adc_sbc(i+10) and									// sbc #$00				; 10
       (listing[i+11] = #9'sta :ecx+1') and							// sta :ecx+1				; 11
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta :edx') and		// lda :STACKORIGIN+9			; 12
       (pos('lda :STACK', listing[i+14]) > 0) and (listing[i+15] = #9'sta :edx+1') then		// sta :edx				; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+9	; 14
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then				// sta :edx+1				; 15
       begin
	listing[i+2] := listing[i+13];
	listing[i+5] := listing[i+15];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub PAC.SY			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc PAC.SY+1			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and (listing[i+7] = #9'sta :edx') and			// lda :STACKORIGIN+9			; 6
       (pos('lda ', listing[i+8]) > 0) and  (listing[i+9] = #9'sta :edx+1') and			// sta :edx				; 7
       (pos('lda :STACK', listing[i+10]) > 0) and (listing[i+11] = #9'sta :ecx') and		// lda :STACKORIGIN+STACKWIDTH+9	; 8
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta :ecx+1') then		// sta :edx+1				; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+10], 6, 256)) and				// lda :STACKORIGIN+10			; 10
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) then				// sta :ecx				; 11
       begin											// lda :STACKORIGIN+STACKWIDTH+10	; 12
												// sta :ecx+1				; 13
	listing[i+2] := listing[i+11];
	listing[i+5] := listing[i+13];

	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda $0058				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+10			; 1
       (pos('lda :STACK', listing[i+4]) > 0) and (listing[i+5] = #9'sta :edx') and		// lda $0058+1				; 2
       (pos('lda :STACK', listing[i+6]) > 0) and  (listing[i+7] = #9'sta :edx+1') and		// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('lda :STACK', listing[i+8]) > 0) and (listing[i+9] = #9'sta :ecx') and		// lda :STACKORIGIN+9			; 4
       (pos('lda :STACK', listing[i+10]) > 0) and (listing[i+11] = #9'sta :ecx+1') then		// sta :edx				; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+9	; 6
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then				// sta :edx+1				; 7
       begin											// lda :STACKORIGIN+10			; 8
	listing[i+8]  := listing[i];								// sta :ecx				; 9
	listing[i+10] := listing[i+2];								// lda :STACKORIGIN+STACKWIDTH+10	; 10
	listing[i]    := '';									// sta :ecx+1				; 11
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';

	Result:=false;
       end;


    if (i>0) and
       (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+9			; 0
       (listing[i+1] = #9'sta :edx') and							// sta :edx				; 1
       (pos('lda :STACK', listing[i+2]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 2
       (listing[i+3] = #9'sta :edx+1') and							// sta :edx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       (listing[i+5] = #9'sta :ecx') and							// sta :ecx				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       (listing[i+7] = #9'sta :ecx+1') then							// sta :ecx+1				; 7
     begin

	tmp:='sta ' + copy(listing[i], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (listing[p] = #9'eif') or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta :edx'; Break end;
	end;

	if yes then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 Result:=false;
	end;

	tmp:='sta ' + copy(listing[i+2], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (listing[p] = #9'eif') or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta :edx+1'; Break end;
	end;

	if yes then begin
	 listing[i+2] := '';
	 listing[i+3] := '';
	 Result:=false;
	end;

     end;


    if (i>0) and
       (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+9			; 0
       (listing[i+1] = #9'sta :edx') and							// sta :edx				; 1
       (pos('lda :STACK', listing[i+2]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 2
       (listing[i+3] = #9'sta :edx+1') and							// sta :edx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       (listing[i+5] = #9'sta :eax') and							// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then							// sta :eax+1				; 7
     begin

	tmp:='sta ' + copy(listing[i], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (listing[p] = #9'eif') or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta :edx'; Break end;
	end;

	if yes then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 Result:=false;
	end;

	tmp:='sta ' + copy(listing[i+2], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (listing[p] = #9'eif') or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta :edx+1'; Break end;
	end;

	if yes then begin
	 listing[i+2] := '';
	 listing[i+3] := '';
	 Result:=false;
	end;

     end;


    if (i>0) and
       (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+9			; 0
       (listing[i+1] = #9'sta :ecx') and							// sta :ecx				; 1
       (pos('lda :STACK', listing[i+2]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 2
       (listing[i+3] = #9'sta :ecx+1') and							// sta :ecx+1				; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       (listing[i+5] = #9'sta :eax') and							// sta :eax				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then							// sta :eax+1				; 7
     begin

	tmp:='sta ' + copy(listing[i], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (listing[p] = #9'eif') or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta :ecx'; Break end;
	end;

	if yes then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 Result:=false;
	end;

	tmp:='sta ' + copy(listing[i+2], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (listing[p] = #9'eif') or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta :ecx+1'; Break end;
	end;

	if yes then begin
	 listing[i+2] := '';
	 listing[i+3] := '';
	 Result:=false;
	end;

     end;


// -----------------------------------------------------------------------------
// ===				LSR.					  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda C				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and		// lda C+1				; 2
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and		// sta :STACKORIGIN+STACKWIDTH		; 3
       (pos('lsr :STACK', listing[i+8]) > 0) and						// lda C+2				; 4
       (pos('ror :STACK', listing[i+9]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2	; 5
       (pos('ror :STACK', listing[i+10]) > 0) and						// lda C+3				; 6
       (pos('ror :STACK', listing[i+11]) > 0) then						// sta :STACKORIGIN+STACKWIDTH*3	; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and				// lsr :STACKORIGIN+STACKWIDTH*3	; 8
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) and				// ror :STACKORIGIN+STACKWIDTH*2	; 9
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) and				// ror :STACKORIGIN+STACKWIDTH		; 10
	(copy(listing[i+7], 6, 256) = copy(listing[i+8], 6, 256)) then 				// ror :STACKORIGIN+9			; 11
       begin

	p:=0;
	while (listing[i+8] = listing[i+8+p*4]) and (listing[i+9] = listing[i+9+p*4]) and
	      (listing[i+10] = listing[i+10+p*4]) and (listing[i+11] = listing[i+11+p*4]) do inc(p);

	listing[i+7+p*4] := listing[i+7];
	dec(p);

	while p>=0 do begin
	 listing[i+7+p*4] := #9'lsr @';
	 listing[i+8+p*4] := #9'ror ' + copy(listing[i+5], 6, 256) ;
	 listing[i+9+p*4] := #9'ror ' + copy(listing[i+3], 6, 256) ;
	 listing[i+10+p*4] := #9'ror ' + copy(listing[i+1], 6, 256) ;
	 dec(p);
	end;

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and 							// lda					; 0
       adc_sbc(i+1) and										// adc|sbc				; 1
       (pos('lsr :STACK', listing[i+2]) > 0) and						// lsr :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('ror :STACK', listing[i+3]) > 0) and						// ror :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('ror :STACK', listing[i+4]) > 0) and						// ror :STACKORIGIN+9			; 4
       (pos('lda :STACK', listing[i+5]) > 0) then						// lda :STACKORIGIN+9			; 5
     if (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
      listing[i]   := '';
      listing[i+1] := '';

      Result:=false;
     end;


    if (listing[i] = #9'lsr @') and 								// lsr @				; 0
       (pos('ror :STACK', listing[i+1]) > 0) and						// ror :STACKORIGIN+STACKWIDTH*3	; 1
       (pos('ror :STACK', listing[i+2]) > 0) and						// ror :STACKORIGIN+STACKWIDTH*2	; 2
       (pos('ror :STACK', listing[i+3]) > 0) and						// ror :STACKORIGIN+STACKWIDTH*1	; 3
       (listing[i+4] = #9'sta #$00') then							// sta #$00				; 4
     begin

	p:=0;
	while (listing[i] = listing[i-p*4]) and (listing[i+1] = listing[i+1-p*4]) and
	      (listing[i+2] = listing[i+2-p*4]) and (listing[i+3] = listing[i+3-p*4]) do inc(p);

	if (pos('lda ', listing[i+3-p*4]) > 0) or (listing[i+3-p*4] = #9'tya') then begin
	 if (pos(',y', listing[i+3-p*4]) > 0) and ((pos('ldy ', listing[i+2-p*4]) > 0) or (listing[i+2-p*4] = #9'iny')) then listing[i+2-p*4]:='';
	 listing[i+3-p*4] := '';
	end;

	dec(p);
	while p>=0 do begin
	 listing[i-p*4] := '';
	 listing[i+1-p*4] := #9'lsr ' + copy(listing[i+1-p*4], 6, 256) ;
	 dec(p);
	end;

	listing[i+4] := '';
	Result:=false;
     end;


    if (listing[i] = #9'lsr @') and 								// lsr @				; 0
       (pos('ror :STACK', listing[i+1]) > 0) and						// ror :STACKORIGIN+STACKWIDTH*3	; 1
       (pos('ror :STACK', listing[i+2]) > 0) and						// ror :STACKORIGIN+STACKWIDTH*2	; 2
       (listing[i+3] = #9'sta #$00') then							// sta #$00				; 3
     begin

	p:=0;
	while (listing[i] = listing[i-p*3]) and (listing[i+1] = listing[i+1-p*3]) and
	      (listing[i+2] = listing[i+2-p*3]) do inc(p);

	if (pos('lda ', listing[i+2-p*3]) > 0) or (listing[i+2-p*3] = #9'tya') then begin
	 if (pos(',y', listing[i+2-p*3]) > 0) and ((pos('ldy ', listing[i+1-p*3]) > 0) or (listing[i+1-p*3] = #9'iny')) then listing[i+1-p*3]:='';
	 listing[i+2-p*3] := '';
	end;

	dec(p);
	while p>=0 do begin
	 listing[i-p*3] := '';
	 listing[i+1-p*3] := #9'lsr ' + copy(listing[i+1-p*3], 6, 256) ;
	 dec(p);
	end;

	listing[i+3] := '';
	Result:=false;
     end;


    if (listing[i] = #9'lsr @') and 								// lsr @				; 0
       (pos('ror :STACK', listing[i+1]) > 0) and						// ror :STACKORIGIN+STACKWIDTH*3	; 1
       (listing[i+2] = #9'sta #$00') then							// sta #$00				; 2
     begin

	p:=0;
	while (listing[i] = listing[i-p*2]) and (listing[i+1] = listing[i+1-p*2]) do inc(p);

	if (pos('lda ', listing[i+1-p*2]) > 0) or (listing[i+1-p*2] = #9'tya') then begin
	 if (pos(',y', listing[i+1-p*2]) > 0) and ((pos('ldy ', listing[i-p*2]) > 0) or (listing[i-p*2] = #9'iny')) then listing[i-p*2]:='';
	 listing[i+1-p*2] := '';
	end;

	dec(p);
	while p>=0 do begin
	 listing[i-p*2] := '';
	 listing[i+1-p*2] := #9'lsr ' + copy(listing[i+1-p*2], 6, 256) ;
	 dec(p);
	end;

	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda					; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH		; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2	; 5
       (pos('lsr :STACK', listing[i+6]) > 0) and						// lsr :STACKORIGIN+STACKWIDTH*2	; 6
       (pos('ror :STACK', listing[i+7]) > 0) and						// ror :STACKORIGIN+STACKWIDTH		; 7
       (pos('ror :STACK', listing[i+8]) > 0) then						// ror :STACKORIGIN			; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	tmp := listing[i+4];
	listing[i+4] := listing[i];
	listing[i] := tmp;

	tmp := listing[i+5];
	listing[i+5] := listing[i+1];
	listing[i+1] := tmp;

	p:=i+6;
	while (listing[p]=listing[p+3]) and (listing[p+1]=listing[p+4]) and (listing[p+2]=listing[p+5]) do inc(p, 3);

	if (pos('lda :STACK', listing[p+3]) > 0) and
	   (copy(listing[p+2], 6, 256) = copy(listing[p+3], 6, 256)) then begin

		listing[p+3] := '';
		listing[i+5] := '';

		p:=i+6;
		while (listing[p]=listing[p+3]) and (listing[p+1]=listing[p+4]) and (listing[p+2]=listing[p+5]) do begin
		 listing[p+2] := #9'ror @';
		 inc(p, 3);
		end;

		listing[p+2] := #9'ror @';
	end;

	Result:=false;
     end;


    if (pos('ldy #', listing[i]) > 0) and							// ldy #				; 0
       (listing[i+1] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN			; 2
       (listing[i+3] = #9'iny') and								// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH		; 5
       (listing[i+6] = #9'iny') and								// iny					; 6
       (listing[i+7] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2	; 8
       (pos('lsr :STACK', listing[i+9]) > 0) and						// lsr :STACKORIGIN+STACKWIDTH*2	; 9
       (pos('ror :STACK', listing[i+10]) > 0) and						// ror :STACKORIGIN+STACKWIDTH		; 10
       (pos('ror :STACK', listing[i+11]) > 0) then						// ror :STACKORIGIN			; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
	tmp := listing[i+8];
	listing[i+8] := listing[i+2];
	listing[i+2] := tmp;

	listing[i+3] := #9'dey';
	listing[i+6] := #9'dey';

	listing[i] := listing[i] + '+2';

	p:=i+9;
	while (listing[p]=listing[p+3]) and (listing[p+1]=listing[p+4]) and (listing[p+2]=listing[p+5]) do inc(p, 3);

	if (pos('lda :STACK', listing[p+3]) > 0) and
	   (copy(listing[p+2], 6, 256) = copy(listing[p+3], 6, 256)) then begin

		listing[p+3] := '';
		listing[i+8] := '';

		p:=i+9;
		while (listing[p]=listing[p+3]) and (listing[p+1]=listing[p+4]) and (listing[p+2]=listing[p+5]) do begin
		 listing[p+2] := #9'ror @';
		 inc(p, 3);
		end;

		listing[p+2] := #9'ror @';
	end;

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGN+STACKWIDTH		; 0
       (pos('sty :STACK', listing[i+1]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*2	; 1
       (pos('lsr :STACK', listing[i+2]) > 0) and						// lsr :STACKORIGIN+STACKWIDTH*2	; 2
       (pos('ror :STACK', listing[i+3]) > 0) and						// ror :STACKORIGIN+STACKWIDTH		; 3
       (pos('ror :STACK', listing[i+4]) > 0) and						// ror :STACKORIGIN			; 4
       (pos('lda :STACK', listing[i+5]) > 0) and						// lda :STACKORIGIN			; 5
       (pos('sta ', listing[i+6]) > 0) and							// sta					; 6
       (pos('lda ', listing[i+7]) = 0) then							// ~lda					; 7
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
	listing[i+1]:='';
	listing[i+2]:='';

	listing[i+3] := #9'lsr ' + copy(listing[i+3], 6, 256);

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda					; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH		; 3
       (pos('lsr :STACK', listing[i+4]) > 0) and						// lsr :STACKORIGIN+STACKWIDTH		; 4
       (pos('ror :STACK', listing[i+5]) > 0) and						// ror :STACKORIGIN			; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN			; 6
       (pos('sta ', listing[i+7]) > 0) then							// sta					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+1] := listing[i+3];
	listing[i+3] := listing[i];
	listing[i]   := listing[i+2];
	listing[i+2] := '';

	listing[i+5] := #9'ror @';
	listing[i+6] := '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH		; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2	; 8
       (pos('lsr :STACK', listing[i+9]) > 0) and						// lsr :STACKORIGIN+STACKWIDTH*2	; 9
       (pos('ror :STACK', listing[i+10]) > 0) and						// ror :STACKORIGIN+STACKWIDTH		; 10
       (pos('ror :STACK', listing[i+11]) > 0) and						// ror :STACKORIGIN			; 11
       (pos('lda :STACK', listing[i+12]) > 0) and						// lda :STACKORIGIN			; 12
       (pos('sta ', listing[i+13]) > 0) and							// sta 					; 13
       (pos('lda :STACK', listing[i+14]) = 0) then						// ~lda :STACKORIGIN+STACKWIDTH		; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	listing[i+10] := #9'lsr ' + copy(listing[i+10], 6, 256);

	Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and								// lda #$00				; 0
       (pos('sta :STACKORIGIN+STACKWIDTH*2', listing[i+1]) > 0) and				// sta :STACKORIGIN+STACKWIDTH*2	; 1
       (listing[i+2] = #9'lsr @') and								// lsr @				; 2
       (pos('ror :STACKORIGIN+STACKWIDTH*2', listing[i+3]) > 0) and				// ror :STACKORIGIN+STACKWIDTH*2	; 3
       (pos('ror :STACK', listing[i+4]) > 0) and						// ror :STACKORIGIN+STACKWIDTH		; 4
       (pos('ror :STACK', listing[i+5]) > 0) and						// ror :STACKORIGIN			; 5
       (pos('sta ', listing[i+6]) > 0) then							// sta					; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i]   := #9'lsr ' + copy(listing[i+4], 6, 256);
	listing[i+1] := listing[i+5];
	listing[i+2] := #9'lda #$00';
	listing[i+3] := #9'sta ' + copy(listing[i+3], 6, 256);
	listing[i+4] := #9'lda #$00';
	listing[i+5] := listing[i+6];
	listing[i+6] := '';

	Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and								// lda #$00				; 0
       (pos('sta :STACKORIGIN+STACKWIDTH*2', listing[i+1]) > 0) and				// sta :STACKORIGIN+STACKWIDTH*2	; 1
       (pos('lsr :STACKORIGIN+STACKWIDTH*2', listing[i+2]) > 0) and				// lsr :STACKORIGIN+STACKWIDTH*2	; 2
       (pos('ror :STACK', listing[i+3]) > 0) and						// ror :STACKORIGIN+STACKWIDTH		; 3
       (pos('ror :STACK', listing[i+4]) > 0) then						// ror :STACKORIGIN			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := #9'lsr ' + copy(listing[i+3], 6, 256);
	listing[i+1] := listing[i+4];

	listing[i+3] := #9'lda #$00';
	listing[i+4] := #9'sta ' + copy(listing[i+2], 6, 256);

	listing[i+2] := '';

	Result:=false;
     end;


    if (pos('lsr :STACKORIGIN+STACKWIDTH*2', listing[i]) > 0) and				// lsr :STACKORIGIN+STACKWIDTH*2	; 0
       (pos('ror :STACKORIGIN+STACKWIDTH', listing[i+1]) > 0 ) and				// ror :STACKORIGIN+STACKWIDTH		; 1
       (listing[i+2] = #9'ror @') and								// ror @				; 2
       (pos('ora ', listing[i+3]) > 0) and							// ora					; 3
       (pos('sta ', listing[i+4]) > 0) and							// sta 					; 4
       (pos('lda ', listing[i+5]) = 0) then							// ~lda 				; 5
     begin
        listing[i]   := '';
	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	Result:=false;
     end;


    if (pos('lsr :STACKORIGIN+STACKWIDTH*2', listing[i]) > 0) and				// lsr :STACKORIGIN+STACKWIDTH*2	; 0
       (pos('ror :STACKORIGIN+STACKWIDTH', listing[i+1]) > 0 ) and				// ror :STACKORIGIN+STACKWIDTH		; 1
       (listing[i+2] = #9'ror @') and								// ror @				; 2
       (pos('lsr :STACKORIGIN+STACKWIDTH', listing[i+3]) > 0 ) and				// lsr :STACKORIGIN+STACKWIDTH		; 3
       (listing[i+4] = #9'ror @') then								// ror @				; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
        listing[i]   := '';
	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda TEMP				; 0
       (listing[i+1] = #9'lsr @') and								// lsr @				; 1
       (pos('sta ', listing[i+2]) > 0 ) then							// sta TEMP				; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i] := #9'lsr ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+STACKWIDTH		; 0
       (pos('lsr :STACK', listing[i+1]) > 0 ) and						// lsr :STACKORIGIN+STACKWIDTH		; 1
       (listing[i+2] <> #9'ror @') and								// ~ror @				; 2
       (listing[i+3] <> #9'ror @') and								// ~ror @				; 3
       (listing[i+4] <> #9'ror @') then								// ~ror @				; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
     begin
        listing[i+1] := listing[i];
	listing[i]   := #9'lsr @';

	Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===				ASL.					  === //
// -----------------------------------------------------------------------------

    if (pos('asl :STACK', listing[i]) > 0) and							// asl :STACKORIGIN+9			; 0
       (pos('rol :STACK', listing[i+1]) > 0) and						// rol :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('rol :STACK', listing[i+2]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol :STACK', listing[i+3]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       add_sub_stack(i+5) and									// add|sub :STACKORIGIN+9		; 5
       (pos('sta ', listing[i+6]) > 0) and							// sta					; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       (pos('sta ', listing[i+9]) > 0) and							// sta					; 9
       (pos('lda ', listing[i+10]) = 0) then
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then begin

	yes:=(pos(' :STACK', listing[i+8]) > 0);

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 if not yes then listing[k-4+1] := '';

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	if not yes then listing[i+1] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('asl :STACK', listing[i]) > 0) and							// asl :STACKORIGIN+9			; 0
       (pos('rol :STACK', listing[i+1]) > 0) and						// rol :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('rol :STACK', listing[i+2]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol :STACK', listing[i+3]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('lda ', listing[i+4]) > 0) and (listing[i+5] = #9'asl @') and			// lda					; 4
       (listing[i+6] = #9'tay') and								// asl @				; 5
       (pos('lda :STACK', listing[i+7]) > 0) and						// tay					; 6
       add_sub(i+8) and										// lda :STACKORIGIN+9			; 7
       (pos('sta ', listing[i+9]) > 0) and							// add|sub				; 8
       (pos('lda ', listing[i+10]) > 0) and							// sta					; 9
       adc_sbc(i+11) and									// lda :STACKORIGIN+STACKWIDTH+9	; 10
       (pos('sta ', listing[i+12]) > 0) and							// adc|sbc				; 11
       (pos('lda :STACK', listing[i+13]) = 0) then						// sta					; 12
     if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) {and
	(copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256))} then begin

	yes:=(pos(' :STACK', listing[i+10]) > 0);

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 if not yes then listing[k-4+1] := '';

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	 if not yes then listing[i+1] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('asl :STACK', listing[i]) > 0) and							// asl :STACKORIGIN+9			; 0
       (pos('rol :STACK', listing[i+1]) > 0) and						// rol :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('rol :STACK', listing[i+2]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol :STACK', listing[i+3]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('lda :STACK', listing[i+4]) > 0) and						// lda :STACKORIGIN+9			; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta					; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 6
       (pos('sta ', listing[i+7]) > 0) and							// sta					; 7
       (pos('lda :STACK', listing[i+8]) = 0) then						// ~lda :STACKORIGIN+STACKWIDTH*2+9	; 8
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// sub adr.VEL,y			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// sbc adr.VEL+1,y			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// sbc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and (listing[i+10] = #9'asl @') and			// lda I				; 9
       (listing[i+11] = #9'tay') and								// asl @				; 10
       (pos('lda :STACK', listing[i+12]) > 0) and						// tay					; 11
       add_sub(i+13) and									// lda :STACKORIGIN+9			; 12
       (pos('sta ', listing[i+14]) > 0) and							// sub adr.BALL,y			; 13
       (pos('lda :STACK', listing[i+15]) > 0) and						// sta T				; 14
       adc_sbc(i+16) and									// lda :STACKORIGIN+STACKWIDTH+9	; 15
       (pos('sta ', listing[i+17]) > 0) and							// sbc adr.BALL+1,y			; 16
       (pos('lda :STACK', listing[i+18]) = 0) then						// sta T+1				; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) then begin

	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false;
       end;


    if (pos('asl :STACK', listing[i]) > 0) and							// asl :STACKORIGIN+9			; 0
       (pos('rol :STACK', listing[i+1]) > 0) and						// rol :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('rol :STACK', listing[i+2]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol :STACK', listing[i+3]) > 0) and						// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('mwa ', listing[i+4]) > 0) and (pos(' :bp2', listing[i+4]) > 0) and			// mwa XX bp2				; 4
       (pos('ldy ', listing[i+5]) > 0) and							// ldy					; 5
       (pos('lda :STACK', listing[i+6]) > 0) and (listing[i+7] = #9'sta (:bp2),y') and		// lda :STACKORIGIN+9			; 6
       (listing[i+8] = #9'iny') and								// sta (:bp2),y				; 7
       (pos('lda :STACK', listing[i+9]) > 0) and (listing[i+10] = #9'sta (:bp2),y') and		// iny					; 8
       (pos(#9'iny', listing[i+11]) = 0) then							// lda :STACKORIGIN+STACKWIDTH+9	; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta (:bp2),y				; 10
	(copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda				; 0
       (pos('asl :STACK', listing[i+1]) > 0) and						// asl :STACKORIGIN+9		; 1
       (pos('lda ', listing[i+2]) > 0) then							// lda				; 2
      begin
	listing[i] := '';

	Result:=false;
      end;


    if (pos('sta ', listing[i]) > 0) and (pos('asl ', listing[i+1]) > 0) and			// sta :STACKORIGIN+9		; 0
       (listing[i+2] = #9'sta #$00') then							// asl :STACKORIGIN+9		; 1
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then				// sta #$00			; 2
       begin
	listing[i+1] := listing[i];
	listing[i]   := #9'asl @';
	listing[i+2] := '';
	Result:=false;
       end;


    if (pos('sta ', listing[i]) > 0) and (pos('asl ', listing[i+1]) > 0) and			// sta :STACKORIGIN+9		; 0
       (pos('asl ', listing[i+2]) > 0) and							// asl :STACKORIGIN+9		; 1
       (listing[i+3] = #9'sta #$00') then							// asl :STACKORIGIN+9		; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and				// sta #$00			; 3
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i+2] := listing[i];
	listing[i]   := #9'asl @';
	listing[i+1] := #9'asl @';
	listing[i+3] := '';
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and 							// lda				; 0
       ( (pos('lda ', listing[i+3]) > 0) or (pos('mwa ', listing[i+3]) > 0) ) and		// sta :STACKORIGIN		; 1
       (pos('sta :STACK', listing[i+1]) > 0) and						// asl :STACKORIGIN		; 2
       (pos('asl :STACK', listing[i+2]) > 0) then						// lda|mwa			; 3
      if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i+2] := listing[i+1];
	listing[i+1] := #9'asl @';
	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+9		; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda				; 1
       adc_sbc(i+2) and										// adc|sbc			; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9; 3
       (pos('asl :STACK', listing[i+4]) > 0) and						// asl :STACKORIGIN+9		; 4
       (pos('asl :STACK', listing[i+5]) > 0) then						// asl :STACKORIGIN+9		; 5
      if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false; ;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda U			; 0
       (listing[i+1] = #9'asl @') and								// asl @			; 1
       (listing[i+2] = #9'tay') and								// tay				; 2
       (pos('lda ', listing[i+5]) > 0) and							// lda adr.MX,y			; 3
       (listing[i+6] = #9'asl @') and								// sta :STACKORIGIN+9		; 4
       (listing[i+7] = #9'tay') and								// lda U			; 5
       (pos('lda adr.', listing[i+3]) > 0) and							// asl @			; 6
       (pos('sta :STACK', listing[i+4]) > 0) and						// tay				; 7
       (pos('lda :STACK', listing[i+8]) > 0) and						// lda :STACKORIGIN+9		; 8
       (pos('sta ', listing[i+10]) > 0) and							// sub adr.MY,y			; 9
       ((pos('add adr.', listing[i+9]) > 0) or (pos('sub adr.', listing[i+9]) > 0)) then	// sta U			; 10
     if (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false;
       end;


// add !!!
    if (listing[i] = #9'sta :eax+1') and							// sta :eax+1			; 0
       (listing[i+1] = #9'asl :eax') and							// asl :eax			; 1
       (listing[i+2] = #9'rol :eax+1') and							// rol :eax+1			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda 				; 3
       (listing[i+4] = #9'add :eax+1') and							// add :eax+1			; 4
       (pos('sta :STACK', listing[i+5]) > 0) then						// sta :STACK			; 5
      begin
	listing[i+2] := #9'rol @';
	listing[i+3] := #9'add ' + copy(listing[i+3], 6, 256);
	listing[i+4] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and							// lda I			; 0
       (listing[i+1] = #9'asl @') and								// asl @			; 1
       (listing[i+2] = #9'tay') and								// tay				; 2
       (pos('lda ', listing[i+7]) > 0) and							// lda adr.BALL,y		; 3
       (listing[i+8] = #9'asl @') and								// sta :STACKORIGIN+9		; 4
       (listing[i+9] = #9'tay') and								// lda adr.BALL+1,y		; 5
       (pos('lda adr.', listing[i+3]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9; 6
       (pos('sta :STACK', listing[i+4]) > 0) and						// lda I			; 7
       (pos('lda adr.', listing[i+5]) > 0) and							// asl @			; 8
       (pos('sta :STACK', listing[i+6]) > 0) and						// tay				; 9
       (pos('lda :STACK', listing[i+10]) > 0) and						// lda :STACKORIGIN+9		; 10
       add_sub(i+11) and									// add adr.VEL,y		; 11
       (pos('sta ', listing[i+12]) > 0) and							// sta T			; 12
       (pos('lda :STACK', listing[i+13]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9; 13
       adc_sbc(i+14) and									// adc adr.VEL+1,y		; 14
       (pos('sta ', listing[i+15]) > 0) then							// sta T+1			; 15
     if (copy(listing[i+4], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+10] := listing[i+3];
	listing[i+13] := listing[i+5];

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda ', listing[i+2]) > 0) and			// lda I			; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and	// sta :STACKORIGIN+9		; 1
       (pos('asl :STACK', listing[i+4]) > 0) and (pos('rol :STACK', listing[i+5]) > 0) then	// lda I+1			; 2
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// sta :STACKORIGIN+STACKWIDTH+9; 3
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then				// asl :STACKORIGIN+9		; 4
       begin											// rol :STACKORIGIN+STACKWIDTH+9; 5

	p:=0;
	while (listing[i+4] = listing[i+4+p*2]) and (listing[i+5] = listing[i+5+p*2]) do inc(p);

	yes:=true;										// zamien ':STACKORIGIN+STACKWIDTH+9' na '@'

	if (pos('lda :STACK', listing[i+4+p*2]) > 0) then
	 yes := (copy(listing[i+4+p*2], 6, 256) = copy(listing[i+5], 6, 256))
	else
	if (pos('lda ', listing[i+4+p*2]) > 0) and (pos('add :STACK', listing[i+5+p*2]) > 0) then begin
	 yes := (copy(listing[i+5+p*2], 6, 256) = copy(listing[i+5], 6, 256));

	 tmp:=listing[i+4+p*2];
	 listing[i+4+p*2] := #9'lda ' + copy(listing[i+5+p*2], 6, 256);
	 listing[i+5+p*2] := #9'add ' + copy(tmp, 6, 256);
	end;

	if yes then begin
	 tmp:=copy(listing[i+4], 6, 256);

	 listing[i+3+p*2] := #9'sta ' + copy(listing[i+5], 6, 256);
	 dec(p);
	 while p>=0 do begin
	  listing[i+3+p*2] := #9'asl ' + tmp;
	  listing[i+4+p*2] := #9'rol @';
	  dec(p);
	 end;

	end else begin
	 tmp:=listing[i];
	 listing[i] := listing[i+2];
	 listing[i+2] := tmp;

	 listing[i+1] := listing[i+3];

	 tmp:=copy(listing[i+5], 6, 256);

	 listing[i+3+p*2] := #9'sta ' + copy(listing[i+4], 6, 256);
	 dec(p);
	 while p>=0 do begin
	  listing[i+3+p*2] := #9'asl @';
	  listing[i+4+p*2] := #9'rol ' + tmp;
	  dec(p);
	 end;

	end;

	Result:=false;
       end;


    if (pos('asl :STACK', listing[i]) > 0) and							// asl :STACKORIGIN+11			; 0
       (listing[i+1] = #9'rol @') and								// rol @				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+11	; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+9			; 3
       add_sub_stack(i+4) and									// add :STACKORIGIN+11			; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta YOFF				; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 6
       adc_sbc_stack(i+7) then									// adc :STACKORIGIN+STACKWIDTH+11	; 7
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin

	tmp:=copy(listing[i+3], 6, 256);
	p:=i+2;
	yes:=false;
	while p > 0 do begin
	 if copy(listing[p], 6, 256) = tmp then begin yes:=true; Break end;
	 dec(p);
	end;

	if yes then
	 if (pos('sta :STACK', listing[p]) > 0) and (pos('lda ', listing[p-1]) >0) then begin
	  listing[i+3] := listing[p-1];

	  Result:=false;
	 end;


	tmp:=copy(listing[i+6], 6, 256);
	p:=i+2;
	yes:=false;
	while p > 0 do begin
	 if copy(listing[p], 6, 256) = tmp then begin yes:=true; Break end;
	 dec(p);
	end;

	if yes then
	 if (pos('sta :STACK', listing[p]) > 0) and (pos('lda ', listing[p-1]) >0) then begin
	  listing[i+6] := listing[p-1];

	  Result:=false;
	 end;

       end;


// wspolna procka dla Nx ASL

    if (add_sub(i) or
	(pos('lda ', listing[i]) > 0) or (pos('and ', listing[i]) > 0) or			// add|sub|lda|and|ora|eor	; 0
	(pos('ora ', listing[i]) > 0) or (pos('eor ', listing[i]) > 0)) and			// sta :STACKORIGIN+9		; 1
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('asl :STACK', listing[i+2]) > 0) then	// asl :STACKORIGIN+9		; 2
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then				// lda :STACKORIGIN+9		; 3
       begin

	p:=0;
	while listing[i+2] = listing[i+2+p] do inc(p);

	if (p>0) and (pos('lda ', listing[i+2+p]) > 0) then begin

	   // if (copy(listing[i+2], 6, 256) = copy(listing[i+2+p], 6, 256)) then

	    if p>1 then
	     listing[i+1] := #9':'+IntToStr(p)+' asl @'
	    else
	     listing[i+1] := #9'asl @';

	    tmp := #9'sta ' + copy(listing[i+2], 6, 256);

	    while p>0 do begin
	     dec(p);
	     listing[i+2+p] := '';
	    end;

	    listing[i+2] := tmp;

	   Result := false;
	end;

       end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda ', listing[i+3]) > 0) and			// lda I			; 0
       (listing[i+1] = #9'asl @') and (listing[i+4] = #9'asl @') and				// asl @			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and (listing[i+5] = #9'tay') then			// sta :STACKORIGIN+9		; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// lda 	I			; 3
       begin											// asl @			; 4
	listing[i+2] := '';									// tay				; 5
	listing[i+3] := '';
	listing[i+4] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda U			; 0
       (listing[i+1] = #9'asl @') and								// asl @			; 1
       (listing[i+2] = #9'tay') and								// tay				; 2
       (pos('lda ', listing[i+5]) > 0) and							// lda adr.MX,y			; 3
       (listing[i+6] = #9'asl @') and								// sta :STACKORIGIN+9		; 4
       (listing[i+7] = #9'tay') and								// lda U			; 5
       (pos('lda adr.', listing[i+3]) > 0) and							// asl @			; 6
       (pos('sta :STACK', listing[i+4]) > 0) and						// tay				; 7
       (pos('lda adr.', listing[i+8]) > 0) and							// lda adr.MY,y			; 8
       (pos('sta ', listing[i+10]) > 0) and							// add :STACKORIGIN+9		; 9
       add_sub_stack(i+9) then									// sta U			; 10
     if (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := copy(listing[i+9], 1, 5) + copy(listing[i+8], 6, 256);
	listing[i+9] := '';

	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta :STACKORIGIN+10		; 0
       adc_sbc(i+2) and										// lda				; 1
       ((pos('asl :STACK', listing[i+3]) > 0) or (pos('lsr :STACK', listing[i+3]) > 0)) and	// adc|sbc			; 2
       ((pos('rol ', listing[i+4]) = 0) and (pos('ror ', listing[i+4]) = 0)) then		// asl|lsr :STACKORIGIN+10	; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// <> rol|ror			; 4
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta :STACKORIGIN+STACK	; 0
       adc_sbc(i+2) and										// lda				; 1
       ((pos('asl ', listing[i+3]) > 0) or (pos('lsr ', listing[i+3]) > 0)) and			// adc|sbc			; 2
       (listing[i+4] = #9'sta #$00') and 							// asl|lsr			; 3
       ((pos('ror :STACK', listing[i+5]) > 0) or (pos('rol :STACK', listing[i+5]) > 0)) then	// sta #$00			; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then begin			// ror|rol :STACKORIGIN+STACK	; 5
	listing[i+4] := '';

	Result:=false;
     end;


    if (pos('asl :STACKORIGIN', listing[i]) > 0) and						// asl :STACKORIGIN		; 0
       (pos('rol :STACKORIGIN+STACKWIDTH', listing[i+1]) > 0) and				// rol :STACKORIGIN+STACKWIDTH	; 1
       (pos('rol :STACKORIGIN+STACKWIDTH*2', listing[i+2]) > 0) and				// rol :STACKORIGIN+STACKWIDTH*2; 2
       (listing[i+3] = #9'rol #$00')  then							// rol #$00			; 3
     begin
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;


    if (pos('asl :STACK', listing[i]) > 0) and (listing[i+1] = #9'rol #$00') then		// asl :STACKORIGIN+9
     begin											// rol #$00
	listing[i+1] := '';

	Result:=false;
     end;


    if (pos('rol :STACK', listing[i]) > 0) and (listing[i+1] = #9'rol #$00') then		// rol :STACKORIGIN
     begin											// rol #$00
	listing[i+1] := '';

	Result:=false;
     end;


    if (listing[i] = #9'asl @') and (listing[i+1] = #9'sta #$00') then				// asl @
     begin											// sta #$00
	listing[i+1] := '';

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+9		; 0
       (pos('asl :STACK', listing[i+1]) > 0) and (pos('asl :STACK', listing[i+2]) > 0) and	// asl :STACKORIGIN+9		; 1
       (pos('ldy :STACK', listing[i+3]) > 0) then						// asl :STACKORIGIN+9		; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and				// ldy :STACKORIGIN+9		; 3
	(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';

	Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta :STACKORIGIN+9		; 0
       (pos('asl :STACK', listing[i+2]) > 0) and (pos('asl :STACK', listing[i+3]) > 0) and	// lda				; 1
       (pos('ldy :STACK', listing[i+4]) > 0) then						// asl :STACKORIGIN+9		; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// asl :STACKORIGIN+9		; 3
	(copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and				// ldy :STACKORIGIN+9 | lda	; 4
	(copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'asl @';
	listing[i+4] := #9'tay';

	Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('asl :STACK', listing[i+1]) > 0) and	// sta :STACKORIGIN+9		; 0
       (pos('ldy :STACK', listing[i+2]) > 0) then						// asl :STACKORIGIN+9		; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and				// ldy :STACKORIGIN+9		; 2
	(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'tay';

	Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta :STACKORIGIN+9		; 0
       (pos('asl :STACK', listing[i+2]) > 0) and (pos('ldy :STACK', listing[i+3]) > 0) then	// lda				; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// asl :STACKORIGIN+9		; 2
	(copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// ldy :STACKORIGIN+9		; 3
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda 				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN		; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and		// lda 				; 2
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and		// sta :STACKORIGIN+STACKWIDTH	; 3
       (pos('asl :STACK', listing[i+8]) > 0) and (pos('rol :STACK', listing[i+9]) > 0) and	// lda				; 4
       (pos('rol :STACK', listing[i+10]) > 0) and (pos('rol :STACK', listing[i+11]) > 0) and	// sta :STACKORIGIN+STACKWIDTH*2; 5
       (pos('lda :STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and		// lda 				; 6
       (pos('lda :STACK', listing[i+14]) > 0) and (pos('sta ', listing[i+15]) > 0) and		// sta :STACKORIGIN+STACKWIDTH*3; 7
       (pos('lda :STACK', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and		// asl :STACKORIGIN		; 8
       (pos('lda :STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then		// rol :STACKORIGIN+STACKWIDTH	; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and				// rol :STACKORIGIN+STACKWIDTH*2; 10
	(copy(listing[i+8], 6, 256) = copy(listing[i+12], 6, 256)) and				// rol :STACKORIGIN+STACKWIDTH*3; 11
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and				// lda :STACKORIGIN		; 12
	(copy(listing[i+9], 6, 256) = copy(listing[i+14], 6, 256)) and				// sta				; 13
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH	; 14
	(copy(listing[i+10], 6, 256) = copy(listing[i+16], 6, 256)) and				// sta 				; 15
	(copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH*2; 16
	(copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then			// sta 				; 17
     begin											// lda :STACKORIGIN+STACKWIDTH*3; 18
	listing[i+1] := listing[i+13];								// sta				; 19
	listing[i+3] := listing[i+15];
	listing[i+5] := listing[i+17];
	listing[i+7] := listing[i+19];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

	listing[i+8]  := #9'asl ' + copy(listing[i+1], 6, 256);
	listing[i+9]  := #9'rol ' + copy(listing[i+3], 6, 256) ;
	listing[i+10] := #9'rol ' + copy(listing[i+5], 6, 256) ;
	listing[i+11] := #9'rol ' + copy(listing[i+7], 6, 256) ;

      	Result:=false;
     end;


    if (listing[i] = #9'lda :eax') and								// lda :eax			; 0
       (pos('sta ', listing[i+1]) > 0) and							// sta B			; 1
       (listing[i+2] = #9'lda :eax+1') and							// lda :eax+1			; 2
       (pos('sta ', listing[i+3]) > 0) and							// sta B+1			; 3
       (listing[i+4] = #9'lda :eax+2') and							// lda :eax+2			; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta B+2			; 5
       (listing[i+6] = #9'lda :eax+3') and							// lda :eax+3			; 6
       (pos('sta ', listing[i+7]) > 0) and							// sta B+3			; 7
       (pos('asl ', listing[i+8]) > 0) and							// asl B			; 8
       (pos('rol ', listing[i+9]) > 0) and							// rol B+1			; 9
       (pos('rol ', listing[i+10]) > 0) and							// rol B+2			; 10
       (pos('rol ', listing[i+11]) > 0) then							// rol B+3			; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
	listing[i]   := #9'asl :eax';
	listing[i+1] := #9'rol :eax+1';
	listing[i+2] := #9'rol :eax+2';
	listing[i+3] := #9'rol :eax+3';

	listing[i+4] := #9'lda :eax';
	listing[i+5] := #9'sta ' + copy(listing[i+8], 6, 256);
	listing[i+6] := #9'lda :eax+1';
	listing[i+7] := #9'sta ' + copy(listing[i+9], 6, 256);
	listing[i+8] := #9'lda :eax+2';
	listing[i+9] := #9'sta ' + copy(listing[i+10], 6, 256);
	listing[i+10] := #9'lda :eax+3';
	listing[i+11] := #9'sta ' + copy(listing[i+11], 6, 256);

      	Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (listing[i] = #9'tay')) and				// tay|ldy A			; 0
       (pos('lda adr.', listing[i+1]) > 0) and							// lda adr.???,y		; 1
       (pos('sta :STACK', listing[i+2]) > 0) and (pos('ldy ', listing[i+3]) > 0) and		// sta :STACKORIGIN+9		; 2
       (pos('lda adr.', listing[i+4]) > 0) and							// ldy B			; 3
       ((pos('ora :STACK', listing[i+5]) > 0) or						// lda adr.???,y		; 4
	(pos('and :STACK', listing[i+5]) > 0) or						// ora|and|eor :STACKORIGIN+9	; 5
	(pos('eor :STACK', listing[i+5]) > 0)) then
     if copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
	listing[i+2] := '';
	listing[i+4] := copy(listing[i+5], 1, 5) + copy(listing[i+4], 6, 256);
	listing[i+5] := '';

	Result:=false;
      end;


    if ((pos('ldy ', listing[i]) > 0) or (listing[i] = #9'tay')) and				// tay|ldy A			; 0
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and	// lda adr.???,y		; 1
       (pos('ldy ', listing[i+3]) > 0) and							// sta :STACKORIGIN+9		; 2
       (pos('lda adr.', listing[i+4]) > 0) and							// ldy B			; 3
       (pos('sta :STACK', listing[i+5]) > 0) and						// lda adr.???,y		; 4
       (pos('lda :STACK', listing[i+6]) > 0) and						// sta :STACKORIGIN+10		; 5
       ((pos('ora :STACK', listing[i+7]) > 0) or						// lda :STACKORIGIN+9		; 6
	(pos('and :STACK', listing[i+7]) > 0) or						// ora|and|eor :STACKORIGIN+10	; 7
	(pos('eor :STACK', listing[i+7]) > 0)) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+2] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+4] := copy(listing[i+7], 1, 5) + copy(listing[i+4], 6, 256);
	listing[i+7] := '';

	Result:=false;
      end;


    if ((pos('ldy ', listing[i]) > 0) or (listing[i] = #9'tay')) and				// tay|ldy A			; 0
       (pos('lda adr.', listing[i+1]) > 0) and							// lda adr.???,y		; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN		; 2
       (pos('lda adr.', listing[i+3]) > 0) and							// lda adr.???+1,y		; 3
       (pos('sta :STACK', listing[i+4]) > 0) and						// sta :STACKORIGIN+STACKWIDTH	; 4
       (pos('lda :STACK', listing[i+5]) > 0) and						// lda :STACKORIGIN		; 5
       (add_sub(i+6) or AND_ORA_EOR(i+6)) and							// add|sub			; 6
       (pos('sta ', listing[i+7]) > 0) and (pos('lda :STACK', listing[i+8]) > 0) and		// sta				; 7
       (adc_sbc(i+9) or AND_ORA_EOR(i+9)) then							// lda :STACKORIGIN+STACKWIDTH	; 8
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and				// adc|sbc			; 9
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+2] := '';
	listing[i+5] := listing[i+1];
	listing[i+8] := listing[i+3];
	listing[i+1] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	Result:=false;
      end;


    if ((pos('ldy ', listing[i]) > 0) or							// tay|ldy A				; 0
    	(listing[i] = #9'tay')) and								// lda adr.???,y			; 1
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and	// sta :STACKORIGIN			; 2
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta :STACK', listing[i+4]) > 0) and	// lda adr.???+1,y			; 3
       (pos('lda ', listing[i+5]) > 0) and							// sta :STACKORIGIN+STACKWIDTH		; 4
       add_sub_stack(i+6) and									// lda					; 5
       (pos('sta ', listing[i+7]) > 0) and (pos('lda ', listing[i+8]) > 0) and			// add|sub :STACKORIGIN			; 6
       adc_sbc_stack(i+9) then									// sta					; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda					; 8
	(copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then				// adc|sbc :STACKORIGIN+STAWCKWIDTH	; 9
      begin
	listing[i+2] := '';
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+9] := copy(listing[i+9], 1, 5) + copy(listing[i+3], 6, 256);
	listing[i+1] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	Result:=false;
      end;


    if ((pos('ldy ', listing[i]) > 0) or (listing[i] = #9'tay')) and
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and	// tay|ldy A			; 0
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta :STACK', listing[i+4]) > 0) and	// lda adr.???,y		; 1
       (pos('lda :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+9		; 2
       add_sub_stack(i+6) and									// lda adr.???+1,y		; 3
       (pos('sta ', listing[i+7]) > 0) and							// sta :STACKORIGIN+10		; 4
       ((pos('adc :STACK', listing[i+9]) = 0) and (pos('sbc :STACK', listing[i+9]) = 0)) then	// lda :STACKORIGIN+9		; 5
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and				// add|sub :STACKORIGIN+10	; 6
	(copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) then				// sta				; 7
      begin
	listing[i+5] := copy(listing[i+5], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i+3], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda				; 0
       (pos('lda :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10		; 1
       add_sub_stack(i+3) then									// lda :STACKORIGIN+9		; 2
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// add|sub :STACKORIGIN+10	; 3
	listing[i+3] := copy(listing[i+3], 1, 5) + copy(listing[i], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (listing[i] = #9'tay')) and				// tay|ldy B			; 0
       (pos('lda adr.', listing[i+1]) > 0) and							// lda adr.MY,y			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and (pos('ldy ', listing[i+3]) > 0) and		// sta :STACKORIGIN+9		; 2
       (pos('lda adr.', listing[i+4]) > 0) and (listing[i+5] = #9'tay') then			// ldy B			; 3
     if (listing[i] = listing[i+3]) and (listing[i+1] = listing[i+4]) then			// lda adr.MY,y			; 4
      begin											// tay				; 5
	listing[i+3] := '';
	listing[i+4] := '';

	Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and (listing[i+1] = #9'iny') and			// sta :STACKORIGIN		; 0
       (pos('lda :STACK', listing[i+2]) > 0) then						// iny				; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then				// lda :STACKORIGIN		; 2
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 0
       (pos('sty :STACK', listing[i+1]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*2+9	; 1
       (pos('sty :STACK', listing[i+2]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*3+9	; 2
       (pos('asl :STACK', listing[i+3]) > 0) and						// asl :STACKORIGIN+9			; 3
       (pos('rol :STACK', listing[i+4]) > 0) and						// rol :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('rol :STACK', listing[i+5]) = 0) then						// ~rol :STACKORIGIN+STACKWIDTH*2+9	; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
      end;


    if (listing[i] = #9'lda #$00') and								// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and							// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda					; 2
       (listing[i+3] = #9'asl @') and								// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and							// rol :eax+1				; 4
       (listing[i+5] = #9'asl @') and								// asl @				; 5
       (listing[i+6] = #9'rol :eax+1') and							// rol :eax+1				; 6
       (listing[i+7] = #9'asl @') and								// asl @				; 7
       (listing[i+8] = #9'rol :eax+1') and							// rol :eax+1				; 8
       (listing[i+9] = #9'tay') then								// tay					; 9
      begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';
	listing[i+6] := '';
	listing[i+8] := '';

	Result:=false;
      end;


    if (listing[i] = #9'lda #$00') and								// lda #$00				; 0
       (listing[i+1] = #9'sta :eax+1') and							// sta :eax+1				; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda					; 2
       (listing[i+3] = #9'asl @') and								// asl @				; 3
       (listing[i+4] = #9'rol :eax+1') and							// rol :eax+1				; 4
       (listing[i+5] = #9'asl @') and								// asl @				; 5
       (listing[i+6] = #9'rol :eax+1') and							// rol :eax+1				; 6
       (listing[i+7] = #9'asl @') and								// asl @				; 7
       (listing[i+8] = #9'rol :eax+1') and							// rol :eax+1				; 8
       add_sub(i+9) and										// add|sub				; 9
       (listing[i+10] = #9'tay') then								// tay					; 10
      begin
	listing[i]   := '';
	listing[i+1] := '';

	listing[i+4] := '';
	listing[i+6] := '';
	listing[i+8] := '';

	Result:=false;
      end;


// -----------------------------------------------------------------------------
// ===			SPL. konwersja liczby ze znakiem	  	  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'ldy #$00') and (pos('lda #$', listing[i+1]) > 0) and			// ldy #$00	; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') then				// lda #$	; 1
     begin											// spl		; 2
	val(copy(listing[i+1], 7, 256), p, err);						// dey		; 3

	listing[i+2] := '';
	listing[i+3] := '';

	if p > 127 then listing[i] := #9'ldy #$FF';

	Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda			; 1
       (listing[i+4] = #9'sty #$00') and							// spl			; 2
       (pos('sta ', listing[i+5]) = 0) then							// dey			; 3
     begin											// sty #$00		; 4
       listing[i]   := '';									// ~sta			; 5

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       Result:=false;
     end;


    if (pos('sty :STACK', listing[i]) > 0) and (listing[i+1] = #9'sty #$00') then		// sty STACK	; 0
     begin											// sty #$00	; 1
       listing[i+1] := '';

       Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda			; 1
       (pos('sta :STACKORIGIN', listing[i+4]) > 0) and						// spl			; 2
       (listing[i+5] = #9'sty #$00') then							// dey			; 3
     begin											// sta :STACKORIGIN	; 4
       listing[i+5] := '';									// sty #$00		; 5
       err:=0;
       if pos('sty #$00', listing[i+6]) > 0 then begin listing[i+6] := ''; inc(err) end;
       if pos('sty #$00', listing[i+7]) > 0 then begin listing[i+7] := ''; inc(err) end;

       if err = 2 then begin
	listing[i]   := '';
	listing[i+2] := '';
	listing[i+3] := '';
       end;

       Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda			; 1
       (listing[i+4] = #9'sty #$00') and							// spl			; 2
       (pos('sta :STACKORIGIN', listing[i+5]) > 0) then						// dey			; 3
     begin											// sty #$00		; 4
       listing[i]   := '';									// sta :STACKORIGIN	; 5

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       Result:=false;
     end;


     if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda A		; 1
       (listing[i+4] = #9'sty #$00') and							// spl			; 2
       add_sub(i+5) then									// dey			; 3
     begin											// sty #$00		; 4
      listing[i]   := '';									// add|sub		; 5

      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';

      Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda A		; 1
       (listing[i+4] = #9'sty #$00') and							// spl			; 2
       ((pos('lda ', listing[i+5]) > 0) or (pos('sta ', listing[i+5]) > 0)) then		// dey			; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then begin			// sty #$00		; 4
      listing[i]   := '';									// lda|sta A		; 5

      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';

      Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda			; 1
       (pos('sta ', listing[i+4]) > 0) and (pos('sty ', listing[i+5]) = 0) then			// spl			; 2
     begin											// dey			; 3
	listing[i]   := '';									// sta			; 4
	listing[i+2] := '';									// <> sty		; 5
	listing[i+3] := '';

	Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda			; 1
       (listing[i+4] = #9'sta #$00') then							// spl			; 2
     begin											// dey			; 3
	listing[i]   := '';									// sta #$00		; 4

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	if (pos('sty ', listing[i+5]) > 0) and (pos('sty ', listing[i+6]) > 0) and (pos('sty ', listing[i+7]) > 0) then begin
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	end else
	if (pos('sty ', listing[i+5]) > 0) and (pos('sty ', listing[i+6]) > 0) then begin
	 listing[i+5] := '';
	 listing[i+6] := '';
	end else
	if (pos('sty ', listing[i+5]) > 0) then
	 listing[i+5] := '';

	Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda ', listing[i+1]) > 0) and			// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda			; 1
       (pos('sty :STACK', listing[i+4]) > 0) and (listing[i+5] = #9'sta #$00') then		// spl			; 2
     begin											// dey			; 3
	listing[i+5] := '';									// sty :STACKORIGIN	; 4
	Result:=false; 										// sta #$00		; 5
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda :STACK', listing[i+1]) > 0) and		// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda :STACKORIGIN+9	; 1
       (pos('sty :STACK', listing[i+4]) > 0) and						// spl			; 2
       ((pos('sta :STACK', listing[i+5]) > 0) or (pos('lda :STACK', listing[i+5]) > 0)) then	// dey			; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then begin			// sty :STACKORIGIN+STA	; 4
	listing[i+5] := '';									// lda|sta :STACKORN+9	; 5
	Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and (pos('lda :STACK', listing[i+1]) > 0) and		// ldy #$00		; 0
       (listing[i+2] = #9'spl') and (listing[i+3] = #9'dey') and				// lda :STACKORIGIN+9	; 1
       (pos('lda :STACK', listing[i+4]) > 0) then						// spl			; 2
     if listing[i+1] = listing[i+4] then begin							// dey			; 3
	listing[i]   := '';									// lda :STACKORIGIN+9	; 4
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;


    if (pos('sty :STACK', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and		// sty :STACKORIGIN	; 0
       (pos('sta ', listing[i+2]) > 0) and (pos('lda :STACK', listing[i+3]) > 0) then		// add			; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// sta			; 2
	listing[i]   := '';									// lda :STACKORIGIN	; 3
	listing[i+3] := #9'tya';

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (listing[i+1] = #9'ldy #$00') and		// sta :STACKORIGIN+STACKWIDTH+9	; 0
       (pos('lda :STACK', listing[i+2]) > 0) and						// ldy #$00				; 1
       (listing[i+3] = #9'spl') and (listing[i+4] = #9'dey') and				// lda :STACKORIGIN+9			; 2
       (pos('sta :STACK', listing[i+5]) > 0) and (pos('sty :STACK', listing[i+6]) > 0) then	// spl					; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+6], 6, 256)) and				// dey					; 4
	(copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and 				// sta :STACKORIGIN+9			; 5
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then begin			// sty :STACKORIGIN+STACKWIDTH+9	; 6

	listing[i]  := '';

	Result:=false;
     end;


    if (pos('ldy ', listing[i]) > 0) and							// ldy					; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda 					; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 2
       (listing[i+3] = #9'sty #$00') and							// sty #$00				; 3
       (listing[i+4] = #9'sty #$00') then							// sty #$00				; 4
     begin
	listing[i]   := '';
	listing[i+3] := '';
	listing[i+4] := '';

	Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and							// lda #				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+9			; 1
       (pos('lda #', listing[i+2]) > 0) and							// lda #				; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (listing[i+4] = #9'ldy #$00') and							// ldy #$00				; 4
       (pos('lda :STACK', listing[i+5]) > 0) and						// lda :STACKORIGIN+9			; 5
       (listing[i+6] = #9'spl') and (listing[i+7] = #9'dey') and				// spl					; 6
       (pos('sty :STACK', listing[i+8]) > 0) then						// dey					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sty :STACKORIGIN+STACKWIDTH+9	; 8
	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';

	Result:=false;
       end;


    if (listing[i] = #9'spl') and								// spl					; 0
       (listing[i+1] = #9'dey') and								// dey					; 1
       (pos('sty :STACK', listing[i+2]) > 0) and						// sty :STACKORIGIN+STACKWIDTH+9	; 2
       (listing[i+3] = #9'sta :eax') and							// sta :eax				; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda 					; 4
       (listing[i+5] = #9'sta :ecx') and							// sta :ecx				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       (listing[i+7] = #9'sta :ecx+1') and							// sta :ecx+1				; 7
       (pos('lda :STACK', listing[i+8]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 8
       (listing[i+9] = #9'sta :eax+1') then							// sta :eax+1				; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+2] := #9'sty :eax+1';

	listing[i+8]  := '';
	listing[i+9]  := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda 					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda 					; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (listing[i+4] = #9'ldy #$00') and							// ldy #$00				; 4
       (pos('lda ', listing[i+5]) > 0) and							// lda					; 5
       (listing[i+6] = #9'spl') and								// spl					; 6
       (listing[i+7] = #9'dey') and								// dey					; 7
       add_sub_stack(i+8) and									// add|sub :STACKORIGIN+9		; 8
       (pos('sta ', listing[i+9]) > 0) and							// sta					; 9
       (listing[i+10] = #9'tya') and								// tya					; 10
       adc_sbc_stack(i+11) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 11
       (pos('sta ', listing[i+12]) > 0) then							// sta :STACKORIGIN+STACKWIDTH+9	; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin

	if pos('add :STACK', listing[i+8]) > 0 then
	 listing[i+8] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+8] := #9'sub ' + copy(listing[i], 6, 256);

	if pos('adc :STACK', listing[i+11]) > 0 then
	 listing[i+11] := #9'adc ' + copy(listing[i+2], 6, 256)
	else
	 listing[i+11] := #9'sbc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and								// ldy #$00				; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda					; 1
       (listing[i+2] = #9'spl') and								// spl					; 2
       (listing[i+3] = #9'dey') and								// dey					; 3
       add_sub(i+4) and										// add|sub				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+9			; 5
       (listing[i+6] = #9'tya') and								// tya					; 6
       (pos('ldy :STACK', listing[i+7]) > 0) and						// ldy :STACKORIGIN+9			; 7
       ((pos('lda ', listing[i+8]) > 0) or (pos('mva ', listing[i+8]) > 0)) then		// lda|mva				; 8
     if (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := '';

	Result:=false;
       end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+9			; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda 					; 4
       adc_sbc(i+5) and										// adc|sbc				; 5
       (pos('sta :STACK', listing[i+6]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda 					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       (pos('sta :STACK', listing[i+9]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 9
       (listing[i+10] = #9'ldy #$00') and							// ldy #$00				; 10
       (pos('lda :STACK', listing[i+11]) > 0) and						// lda :STACKORIGIN+9			; 11
       (listing[i+12] = #9'spl') and (listing[i+13] = #9'dey') and				// spl					; 12
       (pos('sta :STACK', listing[i+14]) > 0) and						// dey					; 13
       (pos('sty :STACK', listing[i+15]) > 0) and						// sta :STACKORIGIN+9			; 14
       (pos('sty :STACK', listing[i+16]) > 0) and						// sty :STACKORIGIN+STACKWIDTH+9	; 15
       (pos('sty :STACK', listing[i+17]) > 0) then						// sty :STACKORIGIN+STACKWIDTH*2+9	; 16
     if (copy(listing[i], 6, 256) = copy(listing[i+11], 6, 256)) and				// sty :STACKORIGIN+STACKWIDTH*3+9	; 17
	(copy(listing[i+11], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and								// ldy #$00				; 0
       (pos('lda :STACK', listing[i+1]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+11	; 1
       (listing[i+2] = #9'spl') and								// spl					; 2
       (listing[i+3] = #9'dey') and								// dey 					; 3
       (pos('sta :STACK', listing[i+4]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+11	; 4
       (pos('sty :STACK', listing[i+5]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*2+11	; 5
       (pos('sty :STACK', listing[i+6]) > 0) and						// sty :STACKORIGIN+STACKWIDTH*3+11	; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda :STACKORIGIN+10			; 7
       add_sub(i+8) and										// add|sub :STACKORIGIN+11		; 8
       (pos('sta ', listing[i+9]) > 0) and							// sta 					; 9
       (pos('lda ', listing[i+10]) > 0) and							// lda :STACKORIGIN+STACKWIDTH+10	; 10
       adc_sbc(i+11) and									// adc|sbc :STACKORIGIN+STACKWIDTH+11	; 11
       (pos('sta ', listing[i+12]) > 0) then							// sta					; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// ~lda					; 13
	(copy(listing[i+4], 6, 256) = copy(listing[i+11], 6, 256)) and				// ~adc|sbc :STACKORIGIN+STACKWIDTH*2+11; 14
	(copy(listing[i+5], 6, 256) <> copy(listing[i+14], 6, 256)) then
       begin
	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';

	Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===			optymalizacja BP2.				  === //
// -----------------------------------------------------------------------------

    if (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+9		; 0
       (pos('add ', listing[i+1]) > 0) and							// add I			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and 						// sta :STACKORIGIN+9		; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH	; 3
       (listing[i+4] = #9'adc #$00') and 							// adc #$00			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and 						// sta :STACKORIGIN+STACKWIDTH	; 5
       (pos('lda ', listing[i+6]) > 0) and 							// lda CHARSET			; 6
       (pos('add :STACK', listing[i+7]) > 0) and 						// add :STACKORIGIN+9		; 7
       (listing[i+8] = #9'tay') and 								// tay				; 8
       (pos('lda ', listing[i+9]) > 0) and 							// lda CHARSET+1		; 9
       (pos('adc :STACK', listing[i+10]) > 0) and 						// adc :STACKORIGIN+STACKWIDTH	; 10
       (listing[i+11] = #9'sta :bp+1') and 							// sta :bp+1			; 11
       (pos('lda ', listing[i+12]) > 0) and 							// lda				; 12
       (listing[i+13] = #9'sta (:bp),y') then 							// sta (:bp),y			; 13
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	tmp:=listing[i+1];

	listing[i+1] := #9'add ' + copy(listing[i+6], 6, 256);
	listing[i+2] := #9'sta :bp2';

	listing[i+4] := #9'adc ' + copy(listing[i+9], 6, 256);
	listing[i+5] := #9'sta :bp2+1';
	listing[i+6] := #9'ldy ' + copy(tmp, 6, 256);
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	listing[i+13] := #9'sta (:bp2),y';

	optyBP2:='';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (listing[i+1] = #9'add #$00') and							// add #$00		; 1
       (listing[i+2] = #9'tay') and 								// tay			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda			; 3
       (listing[i+4] = #9'adc #$00') and 							// adc #$00		; 4
       (listing[i+5] = #9'sta :bp+1') then 							// sta :bp+1		; 5
       begin
	listing[i] := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+4] := '';

	Result:=false;
       end;


    if (pos('lda #', listing[i]) > 0) and (listing[i+1] = #9'sta :bp+1') and			// lda #		; 0
       (pos('ldy #', listing[i+2]) > 0) and 							// sta :bp+1		; 1
       (pos('lda ', listing[i+3]) > 0) and							// ldy #		; 2
       (listing[i+4] = #9'sta (:bp),y') then 							// lda			; 3
       begin											// sta (:bp),y		; 4
	p := GetVAL(copy(listing[i], 6, 256)) shl 8 + GetVAL(copy(listing[i+2], 6, 256));

	listing[i+4] := #9'sta $'+IntToHex(p, 4);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (l=4) and
       (pos('mwa ', listing[i]) > 0) and (pos(' :bp2', listing[i]) > 0) and			// mwa P0 :bp2		; 0
       (listing[i+1] = #9'ldy #$00') and 							// ldy #$00		; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda TMP		; 2
       (listing[i+3] = #9'sta (:bp2),y') then 							// sta (:bp2),y		; 3
       begin
	tmp:=copy(listing[i], 6, pos(' :bp2', listing[i])-6);

	listing[i]   := #9'mva '+tmp+'+1 :bp+1';
	listing[i+1] := #9'ldy '+tmp;
	listing[i+3] := #9'sta (:bp),y';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9			; 1
       (pos('mwa ', listing[i+4]) > 0) and (pos(' :bp2', listing[i+4]) > 0) and			// lda 					; 2
       (listing[i+5] = #9'ldy #$00') and 							// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('lda :STACK', listing[i+6]) > 0) and (listing[i+7] = #9'sta (:bp2),y') and		// mwa X :bp2				; 4
       (listing[i+8] = #9'iny') and								// ldy #$00				; 5
       (pos('lda :STACK', listing[i+9]) > 0) then 						// lda  :STACKORIGIN+9			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta (:bp2),y				; 7
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) then				// iny					; 8
       begin											// lda :STACKORIGIN+STACKWIDTH+9	; 9
	listing[i+6] := listing[i];
	listing[i+9] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9			; 1
       (pos('mwa ', listing[i+4]) > 0) and (pos(' :bp2', listing[i+4]) > 0) and			// lda 					; 2
       (listing[i+5] = #9'ldy #$00') and 							// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('lda :STACK', listing[i+6]) > 0) and						// mwa X :bp2				; 4
       (listing[i+7] = #9'add (:bp2),y') and							// ldy #$00				; 5
       (listing[i+8] = #9'iny') and								// lda  :STACKORIGIN+9			; 6
       (pos('sta ', listing[i+9]) > 0) and 							// add (:bp2),y				; 7
       (pos('lda :STACK', listing[i+10]) > 0) and						// iny					; 8
       (listing[i+11] = #9'adc (:bp2),y') then							// sta					; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+9	; 10
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then				// adc (:bp2),y				; 11
       begin
	listing[i+6] := listing[i];
	listing[i+10] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda :eax				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and		// lda :eax+1				; 2
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('mwa ', listing[i+8]) > 0) and (pos(' :bp2', listing[i+8]) > 0) and			// lda :eax+2				; 4
       (listing[i+9] = #9'ldy #$00') and							// sta :STACKORIGIN+STACKWIDTH*2+9	; 5
       (pos('lda :STACK', listing[i+10]) > 0) and						// lda :eax+3				; 6
       (listing[i+11] = #9'add (:bp2),y') and							// sta :STACKORIGIN+STACKWIDTH*3+9	; 7
       (listing[i+12] = #9'iny') and								// mwa BASE :bp2			; 8
       (pos('sta ', listing[i+13]) > 0) and							// ldy #$00				; 9
       (pos('lda :STACK', listing[i+14]) > 0) and						// lda :STACKORIGIN+9			; 10
       (listing[i+15] = #9'adc (:bp2),y') and							// add (:bp2),y				; 11
       (pos('sta ', listing[i+16]) > 0) and							// iny					; 12
       (pos('lda :STACK', listing[i+17]) > 0) and						// sta LPOS				; 13
       (pos('adc ', listing[i+18]) > 0) and							// lda :STACKORIGIN+STACKWIDTH+9	; 14
       (pos('sta ', listing[i+19]) > 0) and							// adc (:bp2),y				; 15
       (pos('lda :STACK', listing[i+20]) > 0) and						// sta LPOS+1				; 16
       (pos('adc ', listing[i+21]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*2+9	; 17
       (pos('sta ', listing[i+22]) > 0) then							// adc #$00				; 18
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and				// sta LPOS+2				; 19
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH*3+9	; 20
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) and				// adc #$00				; 21
	(copy(listing[i+7], 6, 256) = copy(listing[i+20], 6, 256)) then				// sta LPOS+3				; 22
       begin
	listing[i+10] := listing[i];
	listing[i+14] := listing[i+2];
	listing[i+17] := listing[i+4];
	listing[i+20] := listing[i+6];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9			; 1
       (pos('mwa ', listing[i+4]) > 0) and (pos(' :bp2', listing[i+4]) > 0) and			// lda 					; 2
       (listing[i+5] = #9'ldy #$00') and 							// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('lda ', listing[i+6]) > 0) and (listing[i+7] = #9'sta (:bp2),y') and		// mwa X bp2				; 4
       (listing[i+8] = #9'iny') and								// ldy #$00				; 5
       (pos('lda ', listing[i+9]) > 0) and (listing[i+10] = #9'sta (:bp2),y') and 		// lda					; 6
       (listing[i+11] = #9'iny') and								// sta (:bp2),y				; 7
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta (:bp2),y') and 	// iny					; 8
       (listing[i+14] = #9'iny') and								// lda					; 9
       (pos('lda :STACK', listing[i+15]) > 0) and (listing[i+16] = #9'sta (:bp2),y') then	// sta (:bp2),y				; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and				// iny					; 11
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) then				// lda :STACKORIGIN+9			; 12
       begin											// sta (:bp2),y				; 13
	listing[i+12] := listing[i];								// iny					; 14
	listing[i+15] := listing[i+2];								// lda :STACKORIGIN+STACKWIDTH+9	; 15

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and								// ldy #$00				; 0
       (listing[i+1] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN			; 2
       (listing[i+3] = #9'iny') and								// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH		; 5
       (listing[i+6] = #9'iny') and								// iny					; 6
       (listing[i+7] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2	; 8
       (listing[i+9] = #9'iny') and								// iny					; 9
       (listing[i+10] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3	; 11
       (pos('lda ', listing[i+12]) > 0) and add_sub(i+13) and					// lda SCRL				; 12
       (pos('sta ', listing[i+14]) > 0) and							// add|sub :STACKORIGIN			; 13
       (pos('lda ', listing[i+15]) > 0) and adc_sbc(i+16) and					// sta X				; 14
       (pos('sta ', listing[i+17]) > 0) and							// lda SCRL+1				; 15
       (pos('lda ', listing[i+18]) > 0) and adc_sbc(i+19) and					// adc|sbc :STACKORIGIN+STACKWIDTH	; 16
       (pos('sta ', listing[i+20]) > 0) and							// sta X+1				; 17
       (pos('lda ', listing[i+21]) > 0) and adc_sbc(i+22) and					// lda SCRL+2				; 18
       (pos('sta ', listing[i+23]) > 0) then							// adc|sbc :STACKORIGIN+STACKWIDTH*2	; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and				// sta X+2				; 20
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and				// lda SCRL+3				; 21
	(copy(listing[i+8], 6, 256) = copy(listing[i+19], 6, 256)) and				// adc|sbc :STACKORIGIN+STACKWIDTH*3	; 22
	(copy(listing[i+11], 6, 256) = copy(listing[i+22], 6, 256)) then			// sta X+3				; 23
       begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	if pos('add ', listing[i+13]) > 0 then begin
	 listing[i+13] := #9'add (:bp2),y+';
	 listing[i+16] := #9'adc (:bp2),y+';
	 listing[i+19] := #9'adc (:bp2),y+';
	 listing[i+22] := #9'adc (:bp2),y';
	end else begin
	 listing[i+13] := #9'sub (:bp2),y+';
	 listing[i+16] := #9'sbc (:bp2),y+';
	 listing[i+19] := #9'sbc (:bp2),y+';
	 listing[i+22] := #9'sbc (:bp2),y';
	end;

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('adc ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('adc ', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and
       (pos('lda', listing[i+9]) > 0) and (pos('adc ', listing[i+10]) > 0) and (pos('sta ', listing[i+11]) > 0) and
       (pos('lda ', listing[i+12]) > 0) and (pos('add ', listing[i+13]) > 0) and (listing[i+14] = #9'sta :bp2') and
       (pos('lda ', listing[i+15]) > 0) and (pos('adc ', listing[i+16]) > 0) and (listing[i+17] = #9'sta :bp2+1') and
       (listing[i+18] = #9'ldy #$00') and (pos('lda ', listing[i+19]) > 0) and (listing[i+20] = #9'sta (:bp2),y') and
       (listing[i+21] = #9'iny') and (pos('lda ', listing[i+22]) > 0) and (listing[i+23] = #9'sta (:bp2),y') and
       (listing[i+24] = #9'iny') and (pos('lda ', listing[i+25]) > 0) and (listing[i+26] = #9'sta (:bp2),y') and
       (listing[i+27] = #9'iny') and (pos('lda ', listing[i+28]) > 0) and (listing[i+29] = #9'sta (:bp2),y') then
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+13], 6, 256)) and

	(copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+25], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+28], 6, 256)) then
       begin
{
	lda :STACKORIGIN+10		; 0
	add :eax			; 1
	sta :STACKORIGIN+10		; 2
	lda :STACKORIGIN+STACKWIDTH+10	; 3
	adc :eax+1			; 4
	sta :STACKORIGIN+STACKWIDTH+10	; 5
	lda :STACKORIGIN+STACKWIDTH*2+10; 6
	adc :eax+2			; 7
	sta :STACKORIGIN+STACKWIDTH*2+10; 8
	lda :STACKORIGIN+STACKWIDTH*3+10; 9
	adc :eax+3			; 10
	sta :STACKORIGIN+STACKWIDTH*3+10; 11
	lda SINLOGO			; 12
	add :STACKORIGIN+9		; 13
	sta :bp2			; 14
	lda SINLOGO+1			; 15
	adc :STACKORIGIN+STACKWIDTH+9	; 16
	sta :bp2+1			; 17
	ldy #$00			; 18
	lda :STACKORIGIN+10		; 19
	sta (:bp2),y			; 20
	iny				; 21
	lda :STACKORIGIN+STACKWIDTH+10	; 22
	sta (:bp2),y			; 23
	iny				; 24
	lda :STACKORIGIN+STACKWIDTH*2+10; 25
	sta (:bp2),y			; 26
	iny				; 27
	lda :STACKORIGIN+STACKWIDTH*3+10; 28
	sta (:bp2),y			; 29
}
	listing_tmp[0]  := listing[i+12];
	listing_tmp[1]  := listing[i+13];
	listing_tmp[2]  := listing[i+14];
	listing_tmp[3]  := listing[i+15];
	listing_tmp[4]  := listing[i+16];
	listing_tmp[5]  := listing[i+17];

	listing_tmp[6]  := listing[i+18];

	listing_tmp[7]  := listing[i];
	listing_tmp[8]  := listing[i+1];
	listing_tmp[9]  := listing[i+20];

	listing_tmp[10] := listing[i+21];

	listing_tmp[11] := listing[i+3];
	listing_tmp[12] := listing[i+4];
	listing_tmp[13] := listing[i+20];

	listing_tmp[14] := listing[i+21];

	listing_tmp[15] := listing[i+6];
	listing_tmp[16] := listing[i+7];
	listing_tmp[17] := listing[i+20];

	listing_tmp[18] := listing[i+21];

	listing_tmp[19] := listing[i+9];
	listing_tmp[20] := listing[i+10];
	listing_tmp[21] := listing[i+20];

	for p:=0 to 21 do
	 listing[i+p] := listing_tmp[p];

	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';
	listing[i+29] := '';

	Result:=false;
       end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and
       (pos('lda #', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and
       (pos('lda #', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and
       (pos('lda #', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('add ', listing[i+9]) > 0) and (listing[i+10] = #9'sta :bp2') and
       (pos('lda ', listing[i+11]) > 0) and (pos('adc ', listing[i+12]) > 0) and (listing[i+13] = #9'sta :bp2+1') and
       (listing[i+14] = #9'ldy #$00') and
       (pos('lda ', listing[i+15]) > 0) and (pos('add ', listing[i+16]) > 0) and (listing[i+17] = #9'sta (:bp2),y') and
       (listing[i+18] = #9'iny') and
       (pos('lda ', listing[i+19]) > 0) and (pos('adc ', listing[i+20]) > 0) and (listing[i+21] = #9'sta (:bp2),y') and
       (listing[i+22] = #9'iny') and
       (pos('lda ', listing[i+23]) > 0) and (pos('adc ', listing[i+24]) > 0) and (listing[i+25] = #9'sta (:bp2),y') and
       (listing[i+26] = #9'iny') and
       (pos('lda ', listing[i+27]) > 0) and (pos('adc ', listing[i+28]) > 0) and (listing[i+29] = #9'sta (:bp2),y') then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+20], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+24], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+28], 6, 256)) then
       begin
{
	lda #$00			; 0
	sta :eax			; 1
	lda #$18			; 2
	sta :eax+1			; 3
	lda #$00			; 4
	sta :eax+2			; 5
	lda #$00			; 6
	sta :eax+3			; 7
	lda SINSCROL			; 8
	add :STACKORIGIN+9		; 9
	sta :bp2			; 10
	lda SINSCROL+1			; 11
	adc :STACKORIGIN+STACKWIDTH+9	; 12
	sta :bp2+1			; 13
	ldy #$00			; 14
	lda :STACKORIGIN+10		; 15
	add :eax			; 16
	sta (:bp2),y			; 17
	iny				; 18
	lda :STACKORIGIN+STACKWIDTH+10	; 19
	adc :eax+1			; 20
	sta (:bp2),y			; 21
	iny				; 22
	lda :STACKORIGIN+STACKWIDTH*2+10; 23
	adc :eax+2			; 24
	sta (:bp2),y			; 25
	iny				; 26
	lda :STACKORIGIN+STACKWIDTH*3+10; 27
	adc :eax+3			; 28
	sta (:bp2),y			; 29
}
	listing[i+16] := #9'add ' + copy(listing[i], 6, 256);
	listing[i+20] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i+24] := #9'adc ' + copy(listing[i+4], 6, 256);
	listing[i+28] := #9'adc ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and							// ldy #$00				; 0
       (listing[i+1] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (listing[i+3] = #9'iny') and							// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda OFFSET				; 6
       (listing[i+7] = #9'sta :bp2') and						// sta :bp2				; 7
       (pos('lda ', listing[i+8]) > 0) and						// lda OFFSET+1				; 8
       (listing[i+9] = #9'sta :bp2+1') and						// sta :bp2+1				; 9
       (listing[i+10] = #9'ldy #$00') and						// ldy #$00				; 10
       (pos('lda ', listing[i+11]) > 0) and						// lda :STACKORIGIN+10			; 11
       (listing[i+12] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 12
       (listing[i+13] = #9'iny') and							// iny					; 13
       (pos('lda ', listing[i+14]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 14
       (listing[i+15] = #9'sta (:bp2),y') then						// sta (:bp2),y				; 15
     if (copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i]   := listing[i+6];
	listing[i+1] := #9'sta :TMP';
	listing[i+2] := listing[i+8];
	listing[i+3] := #9'sta :TMP+1';

	listing[i+4] := #9'ldy #$00';
	listing[i+5] := #9'lda (:bp2),y';
	listing[i+6] := #9'sta (:TMP),y';
	listing[i+7] := #9'iny';
	listing[i+8] := #9'lda (:bp2),y';
	listing[i+9] := #9'sta (:TMP),y';

	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and							// ldy #$00				; 0
       (listing[i+1] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (listing[i+3] = #9'iny') and							// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('mwa ', listing[i+6]) > 0) and (pos(' :bp2', listing[i+6]) > 0) and		// mwa XXX :bp2				; 6
       (listing[i+7] = #9'ldy #$00') and						// ldy #$00				; 7
       (pos('lda :STACK', listing[i+8]) > 0) and					// lda :STACKORIGIN+10			; 8
       (listing[i+9] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 9
       (listing[i+10] = #9'iny') and							// iny					; 10
       (listing[i+11] = #9'lda #$00') and						// lda #$00				; 11
       (listing[i+12] = #9'sta (:bp2),y') then						// sta (:bp2),y				; 12
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i]   := copy(listing[i+6], 1, pos(':bp2', listing[i+6])) + 'TMP';	// :TMP

	listing[i+1] := #9'ldy #$00';
	listing[i+2] := #9'lda (:bp2),y';
	listing[i+3] := #9'sta (:TMP),y';
	listing[i+4] := #9'iny';
	listing[i+5] := #9'lda #$00';
	listing[i+6] := #9'sta (:TMP),y';

	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	Result:=false;
       end;


    if (listing[i] = #9'ldy #$00') and							// ldy #$00				; 0
       (listing[i+1] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (listing[i+3] = #9'iny') and							// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and 						// lda OUTCODE				; 6
       add_sub(i+7) and									// add|sub				; 7
       (listing[i+8] = #9'tay') and							// tay					; 8
       (pos('lda ', listing[i+9]) > 0) and 						// lda OUTCODE+1			; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       (listing[i+11] = #9'sta :bp+1') and						// sta :bp+1				; 11
       (pos('lda ', listing[i+12]) > 0) then 						// lda :STACKORIGIN+10			; 12
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	Result:=false;
       end;


    if add_sub(i) and									// add|sub				; 0
       (listing[i+1] = #9'sta :bp2') and						// sta :bp2				; 1
       (pos('lda ', listing[i+2]) > 0) and 						// lda 					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       (listing[i+4] = #9'sta :bp2+1') and						// sta :bp2+1				; 4
       (listing[i+5] = #9'ldy #$00') and						// ldy #$00				; 5
       (listing[i+6] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 6
       (pos('sta ', listing[i+7]) > 0) and 						// sta 					; 7
       (listing[i+8] <> #9'iny') then							// ~iny					; 8
      begin
	listing[i+1]  := #9'tay';

	listing[i+4]  := #9'sta :bp+1';
	listing[i+5]  := '';
	listing[i+6]  := #9'lda (:bp),y';

	Result:=false;
      end;


    if (listing[i] = #9'ldy #$00') and							// ldy #$00				; 0
       (listing[i+1] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (listing[i+3] = #9'iny') and							// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (listing[i+6] = #9'iny') and							// iny					; 6
       (listing[i+7] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (listing[i+9] = #9'iny') and							// iny					; 9
       (listing[i+10] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 10
       (pos('sta ', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda ', listing[i+12]) > 0) and						// lda OFFSET				; 12
       add_sub(i+13) and								// add|sub				; 13
       (listing[i+14] = #9'sta :bp2') and						// sta :bp2				; 14
       (pos('lda ', listing[i+15]) > 0) and						// lda OFFSET+1				; 15
       adc_sbc(i+16) and								// add|sub				; 16
       (listing[i+17] = #9'sta :bp2+1') and						// sta :bp2+1				; 17
       (listing[i+18] = #9'ldy #$00') and						// ldy #$00				; 18
       (pos('lda ', listing[i+19]) > 0) and						// lda :STACKORIGIN+10			; 19
       (listing[i+20] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 20
       (listing[i+21] = #9'iny') and							// iny					; 21
       (pos('lda ', listing[i+22]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 22
       (listing[i+23] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 23
       (listing[i+24] = #9'iny') and							// iny					; 24
       (pos('lda ', listing[i+25]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+10	; 25
       (listing[i+26] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 26
       (listing[i+27] = #9'iny') and							// iny					; 27
       (pos('lda ', listing[i+28]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+10	; 28
       (listing[i+29] = #9'sta (:bp2),y') then						// sta (:bp2),y				; 29
     if (copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+25], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+28], 6, 256)) and

	(copy(listing[i+2], 6, 256) <> copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+13], 6, 256)) then
       begin
	listing[i]   := listing[i+12];
	listing[i+1] := listing[i+13];
	listing[i+2] := #9'sta :TMP';
	listing[i+3] := listing[i+15];
	listing[i+4] := listing[i+16];
	listing[i+5] := #9'sta :TMP+1';

	listing[i+6]  := #9'ldy #$00';
	listing[i+7]  := #9'lda (:bp2),y';
	listing[i+8]  := #9'sta (:TMP),y';
	listing[i+9]  := #9'iny';
	listing[i+10] := #9'lda (:bp2),y';
	listing[i+11] := #9'sta (:TMP),y';
	listing[i+12] := #9'iny';
	listing[i+13] := #9'lda (:bp2),y';
	listing[i+14] := #9'sta (:TMP),y';
	listing[i+15] := #9'iny';
	listing[i+16] := #9'lda (:bp2),y';
	listing[i+17] := #9'sta (:TMP),y';

	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';
	listing[i+29] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda :STACKORIGIN+9			; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+9	; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+9	; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('mwa ', listing[i+12]) > 0) and						// mwa  :bp2				; 12
       (pos('ldy #', listing[i+13]) > 0) and						// ldy #				; 13
       (pos('lda :STACK', listing[i+14]) > 0) and					// lda :STACKORIGIN+9			; 14
       (listing[i+15] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 15
       (listing[i+16] = #9'iny') and							// iny					; 16
       (pos('lda :STACK', listing[i+17]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 17
       (listing[i+18] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 18
       (pos(#9'iny', listing[i+19]) = 0) then						// ~ iny				; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('mwa ', listing[i+6]) > 0) and						// mwa  :bp2				; 6
       (pos('ldy #', listing[i+7]) > 0) and						// ldy #				; 7
       (pos('lda :STACK', listing[i+8]) > 0) and					// lda :STACKORIGIN+9			; 8
       (listing[i+9] = #9'sta (:bp2),y') and						// sta (:bp2),y				; 9
       (listing[i+10] = #9'iny') and							// iny					; 10
       (pos('lda :STACK', listing[i+11]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 11
       (listing[i+12] = #9'sta (:bp2),y') then						// sta (:bp2),y				; 12
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	btmp[0] := listing[i+6];
	btmp[1] := listing[i+7];
	btmp[2] := listing[i];
	btmp[3] := listing[i+1];
	btmp[4] := listing[i+9];
	btmp[5] := listing[i+10];
	btmp[6] := listing[i+3];
	btmp[7] := listing[i+4];
	btmp[8] := listing[i+9];

	for p:=0 to 8 do listing[i+p]:=btmp[p];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda					; 2
       (pos('sta :STACK', listing[i+3]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('mwa ', listing[i+4]) > 0) and						// mwa  :bp2				; 4
       (pos('ldy #', listing[i+5]) > 0) and						// ldy #				; 5
       (listing[i+6] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 6
       (pos('sta :STACK', listing[i+7]) > 0) and					// sta :STACKORIGIN+10			; 7
       (pos('lda :STACK', listing[i+8]) > 0) and					// lda :STACKORIGIN+STACKWIDTH+9	; 8
       (listing[i+9] = #9'sta :bp+1') and						// sta :bp+1				; 9
       (pos('ldy :STACK', listing[i+10]) > 0) and					// ldy :STACKORIGIN+9			; 10
       (pos('lda :STACK', listing[i+11]) > 0) and					// lda :STACKORIGIN+10			; 11
       (listing[i+12] = #9'sta (:bp),y') then						// sta (:bp),y				; 12
     if (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+8]  := listing[i+2];
	listing[i+10] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda					; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('mwa ', listing[i+4]) > 0) and							// mwa  :bp2				; 4
       (pos('ldy #', listing[i+5]) > 0) and							// ldy #				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN+9		; 7
       (listing[i+8] = #9'sta (:bp2),y') and							// sta (:bp2),y				; 8
       (listing[i+9] = #9'iny') and								// iny					; 9
       (pos('lda ', listing[i+10]) > 0) and							// lda 					; 10
       adc_sbc_stack(i+11) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 11
       (listing[i+12] = #9'sta (:bp2),y') then							// sta (:bp2),y				; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin

	if (pos('add :STACK', listing[i+7]) > 0) then
 	 listing[i+7]  := #9'add ' + copy(listing[i], 6, 256)
	else
 	 listing[i+7]  := #9'sub ' + copy(listing[i], 6, 256);

	if (pos('adc :STACK', listing[i+11]) > 0) then
 	 listing[i+11]  := #9'adc ' + copy(listing[i+2], 6, 256)
	else
 	 listing[i+11]  := #9'sbc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda #$', listing[i]) > 0) and							// lda #$			; 0
       (listing[i+1] = #9'sta :bp2') and							// sta :bp2			; 1
       (pos('lda #$', listing[i+2]) > 0) and							// lda #$			; 2
       (listing[i+3] = #9'sta :bp2+1') and							// sta :bp2+1			; 3
       (listing[i+4] = #9'ldy #$00') and							// ldy #$00			; 4
       (pos('lda :STACK', listing[i+5]) > 0) and						// lda :STACKORIGIN+10		; 5
       (listing[i+6] = #9'sta (:bp2),y') and							// sta (:bp2),y			; 6
       (listing[i+7] = #9'iny') and 								// iny				; 7
       (pos('lda :STACK', listing[i+8]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+	; 8
       (listing[i+9] = #9'sta (:bp2),y') and							// sta (:bp2),y			; 9
       (pos(#9'iny', listing[i+10]) = 0) then							// ~iny				; 10
       begin
	p:=GetVal(copy(listing[i], 6, 256)) + GetVal(copy(listing[i+2], 6, 256)) shl 8;

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+6] := #9'sta $' + IntToHex(p, 4);
	listing[i+7] := '';

	listing[i+9] := #9'sta $' + IntToHex(p+1, 4);

	Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===			optymalizacja ORA.				  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'ora #$00') and			// lda			; 0
       (pos('sta ', listing[i+2]) > 0) then							// ora #$00		; 1
     begin											// sta			; 2
	listing[i+1] := '';

	Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and (pos('ora ', listing[i+1]) > 0) and			// lda #$00		; 0
       (pos('sta ', listing[i+2]) > 0) then							// ora 			; 1
     begin											// sta			; 2
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256) ;
	listing[i+1] := '';

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and 							// sta :STACKORIGIN+10	; 0
       (pos('lda ', listing[i+1]) > 0) and 							// lda 			; 1
       (pos('ora :STACK', listing[i+2]) > 0) then						// ora :STACKORIGIN+10	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := '';
	listing[i+2] := '';
	listing[i+1] := #9'ora ' + copy(listing[i+1], 6, 256);

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and	// sta :STACKORIGIN+9			; 1
       (pos('lda :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 2
       (pos('ora ', listing[i+4]) > 0) and 							// lda :STACKORIGIN+9			; 3
       (pos('sta ', listing[i+5]) > 0) and							// ora					; 4
       (pos('lda :STACK', listing[i+6]) > 0) and						// sta					; 5
       (pos('ora ', listing[i+7]) > 0) then 							// lda  :STACKORIGIN+STACKWIDTH+9	; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and				// ora					; 7
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+3] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('ora :STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('ora :STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('ora :STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('ora :STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda :eax			; 0
	sta :STACKORIGIN+10		; 1
	lda :eax+1			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda :eax+2			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	lda :eax+3			; 6
	sta :STACKORIGIN+STACKWIDTH*3+10; 7
	lda ERROR			; 8
	ora :STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	ora :STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	ora :STACKORIGIN+STACKWIDTH*2+10;  15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	ora :STACKORIGIN+STACKWIDTH*3+10; 18
	sta ERROR+3			; 19
}
	listing[i+9]  := #9'ora ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'ora ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'ora ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'ora ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
	end;


    if (pos('ldy ', listing[i]) > 0) and						// ldy #$00				; 0
       (listing[i+1] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and					// sta :STACKORIGIN+10			; 2
       (listing[i+3] = #9'iny') and							// iny					; 3
       (listing[i+4] = #9'lda (:bp2),y') and						// lda (:bp2),y				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda :STACKORIGIN+9			; 6
       (pos('ora :STACK', listing[i+7]) > 0) and					// ora :STACKORIGIN+10			; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta C				; 8
       (pos('lda ', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 9
       (pos('ora :STACK', listing[i+10]) > 0) and					// ora :STACKORIGIN+STACKWIDTH+10	; 10
       (pos('sta ', listing[i+11]) > 0) then						// sta C+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) <> copy(listing[i+9], 6, 256)) then
	begin

	  listing[i+1] := listing[i+6];
	  listing[i+2] := #9'ora (:bp2),y';
	  listing[i+3] := listing[i+8];
	  listing[i+4] := #9'iny';
	  listing[i+5] := listing[i+9];
	  listing[i+6] := #9'ora (:bp2),y';
	  listing[i+7] := listing[i+11];

	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10] := '';
	  listing[i+11] := '';

	  Result:=false;
	end;


// -----------------------------------------------------------------------------
// ===			optymalizacja EOR.				  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('eor :STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('eor :STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('eor :STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('eor :STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda :eax			; 0
	sta :STACKORIGIN+10		; 1
	lda :eax+1			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda :eax+2			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	lda :eax+3			; 6
	sta :STACKORIGIN+STACKWIDTH*3+10; 7
	lda ERROR			; 8
	eor :STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	eor :STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	eor :STACKORIGIN+STACKWIDTH*2+10; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	eor :STACKORIGIN+STACKWIDTH*3+10; 18
	sta ERROR+3			; 19
}
	listing[i+9]  := #9'eor ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'eor ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'eor ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'eor ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
	end;


// -----------------------------------------------------------------------------
// ===			optymalizacja ADD.				  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and						// lda			; 0
       (pos('add ', listing[i+1]) > 0) and						// add			; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda			; 3
       (listing[i+4] = #9'adc #$00') and						// adc #$00		; 4
       (pos('add ', listing[i+5]) > 0) then						// add			; 5
     begin
	listing[i+4] := #9'adc ' + copy(listing[i+5], 6, 256);
	listing[i+5] := '';

	Result:=false;
     end;


    if (l = 3) and (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and	// lda X 		; 0
       (listing[i+1] = #9'add #$01') and (pos(',y', listing[i]) = 0) and		// add #$01		; 1
       (pos('sta ', listing[i+2]) > 0) and (pos(',y', listing[i+2]) = 0) then		// sta Y		; 2
     if copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256) then
     begin
	listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
	listing[i+1] := #9'iny';
	listing[i+2] := #9'sty '+copy(listing[i+2], 6, 256);

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+9	; 0
       (pos('lda :STACK', listing[i+1]) > 0) and					// lda :STACKORIGIN+10	; 1
       (pos('add :STACK', listing[i+2]) > 0) then					// add :STACKORIGIN+9	; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
	listing[i]   := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and						// sta :STACKORIGIN+9	; 0
       (pos('add :STACK', listing[i+1]) > 0) and					// add :STACKORIGIN+9	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta			; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin
	listing[i]   := #9'add ' + copy(listing[i+2], 6, 256);
	listing[i+1] := '';

	Result:=false;
     end;


    if (l = 3) and
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda W		; 0
       (listing[i+1] = #9'add #$01') then						// add #$01		; 1
      if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then			// sta W		; 2
       begin
	listing[i]   := #9'inc '+copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	Result := false;
       end;


    if (pos('sta ', listing[i]) > 0) and						// sta :eax		; 0
       (pos('lda ', listing[i+1]) > 0) and						// lda			; 1
       (listing[i+2] = #9'add #$01') and						// add #$01		; 2
       (pos('add ', listing[i+3]) > 0) and						// add :eax		; 3
       (listing[i+4] = #9'tay') then							// tay			; 4
      if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then
       begin
	listing[i] := '';

	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := #9'tay';
	listing[i+3] := #9'iny';

	listing[i+4] := '';

	Result := false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda			; 0
       add_sub(i+1) and 								// add|sub		; 1
       (pos('lda ', listing[i+2]) > 0) and						// lda			; 2
       ((pos('adc ', listing[i+3]) = 0) and (pos('sbc ', listing[i+3]) = 0)) then	// ~adc|sbc		; 3
       begin
	listing[i]   := '';
	listing[i+1] := '';

	Result := false;
       end;


    if (listing[i] = #9'clc') and							// clc			; 0
       (pos('lda ', listing[i+1]) > 0) and 						// lda			; 1
       (pos('adc ', listing[i+2]) > 0) then						// adc			; 2
       begin
	listing[i]   := '';
	listing[i+2] := #9'add ' + copy(listing[i+2], 6, 256);

	Result := false;
       end;


    if (listing[i] = #9'clc') and							// clc			; 0
       (pos('lda ', listing[i+1]) > 0) and						// lda			; 1
       (pos('add ', listing[i+2]) > 0) then						// add			; 2
     begin
	listing[i] := '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 						// lda			; 0	!!! zadziala tylko dla ADD|ADC !!!
       (listing[i+1] = #9'add #$00') and						// add #$00		; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta			; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda			; 3
       (pos('adc ', listing[i+4]) > 0) then						// adc			; 4
     begin
      listing[i+1] := '';
      listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

      Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and							// lda #$00		; 0	!!! zadziala tylko dla ADD|ADC !!!
       (pos('add ', listing[i+1]) > 0) and						// add			; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta			; 2
       (pos('lda ', listing[i+3]) > 0) and 						// lda 			; 3
       (pos('adc ', listing[i+4]) > 0) then						// adc			; 4
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

	Result:=false;
     end;


    if Result and
       (pos('lda ', listing[i]) > 0) and 						// lda			; 0
       (listing[i+1] = #9'add #$00') and						// add #$00		; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta			; 2
       (pos(#9'iny', listing[i+3]) = 0) and						// ~iny			; 3
       (pos('adc ', listing[i+4]) = 0) then						// ~adc			; 4
     begin
      listing[i+1] := '';

      Result:=false;
     end;


    if Result and
       (listing[i] = #9'lda #$00') and 							// lda #$00		; 0
       (pos('add ', listing[i+1]) > 0) and						// add			; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta			; 2
       (pos(#9'iny', listing[i+3]) = 0) and						// ~iny			; 3
       (pos('adc ', listing[i+4]) = 0) then						// ~adc			; 4
     begin
      listing[i] := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 						// lda 			; 0
       (listing[i+1] = #9'add #$00') and						// add #$00		; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta			; 2
       (listing[i+3] = #9'iny') and							// iny			; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda 			; 4
       (pos('adc ', listing[i+5]) > 0) then						// adc			; 5
     begin
      listing[i+1] := '';
      listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

      Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and 							// lda #$00		; 0
       (pos('add ', listing[i+1]) > 0) and						// add			; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta			; 2
       (listing[i+3] = #9'iny') and							// iny			; 3
       (pos('lda ', listing[i+4]) > 0) and						// lda 			; 4
       (pos('adc ', listing[i+5]) > 0) then						// adc			; 5
     begin
      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

      Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and							// sta :eax+1				; 0
       (pos('lda :STACK', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+3]) > 0) and							// sta D				; 2
       (pos('add ', listing[i+4]) > 0) and							// lda 					; 3
       (pos('sta ', listing[i+5]) > 0) and							// add :eax+1				; 4
       (pos('lda ', listing[i+6]) = 0) and							// sta D+1				; 5
       (pos('adc ', listing[i+7]) = 0) then							// ~lda					; 6
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and				// ~adc					; 7
	(pos(listing[i+2], listing[i+5]) > 0) then						// !!! zadziala tylko dla ADD !!!
       begin
	listing[i] := #9'add ' + copy(listing[i+3], 6, 256);

	listing[i+3] := listing[i+1];
	listing[i+4] := listing[i+2];

	listing[i+1] := listing[i+5];

	listing[i+2] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('sta ', listing[i]) > 0) and							// sta :eax+1				; 0
       (pos('lda :STACK', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+3]) > 0) and							// sta D				; 2
       add_sub(i+4) and										// lda :eax+1				; 3
       (pos('sta ', listing[i+5]) > 0) and							// add|sub				; 4
       (pos('lda ', listing[i+6]) = 0) and							// sta D+1				; 5
       (pos('adc ', listing[i+7]) = 0) and							// ~lda					; 6
       (pos('sbc ', listing[i+7]) = 0) then							// ~adc|sbc				; 7
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
	(pos(listing[i+2], listing[i+5]) > 0) then
       begin
	listing[i] := listing[i+4];

	listing[i+3] := listing[i+1];
	listing[i+4] := listing[i+2];

	listing[i+1] := listing[i+5];

	listing[i+2] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda 					; 6
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN+10		; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta					; 8
       (pos('lda ', listing[i+9]) = 0) then							// ~lda					; 9
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and	// sta :STACKORIGIN+9			; 1
       (pos('lda ', listing[i+3]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 2
       add_sub_stack(i+4) and								 	// lda 					; 3
       (pos('sta ', listing[i+5]) > 0) and							// add|sub :STACKORIGIN+9		; 4
       (pos('lda ', listing[i+6]) > 0) and							// sta					; 5
       adc_sbc_stack(i+7) then									// lda 					; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 7
	(copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+4] := copy(listing[i+4], 1, 5) + copy(listing[i], 6, 256);
	listing[i+7] := copy(listing[i+7], 1, 5) + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and	// sta :STACKORIGIN+9			; 1
       (pos('lda :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 2
       add_sub(i+4) and 									// lda :STACKORIGIN+9			; 3
       (pos('sta ', listing[i+5]) > 0) and							// add|sub				; 4
       (pos('lda :STACK', listing[i+6]) > 0) and						// sta					; 5
       adc_sbc(i+7) then 									// lda :STACKORIGIN+STACKWIDTH+9	; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and				// adc|sbc 				; 7
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+3] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda				; 0
       add_sub(i+1) and										// add|sub			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10		; 2
       (pos('lda ', listing[i+3]) > 0) and 							// lda				; 3
       adc_sbc(i+4) and										// adc|sbc			; 4
       (listing[i+5] = #9'sta :bp+1') and							// sta :bp+1			; 5
       (pos('ldy :STACK', listing[i+6]) > 0) and 						// ldy :STACKORIGIN+10		; 6
       (pos('lda ', listing[i+7]) > 0) and 	 						// lda 				; 7
       (listing[i+8] = #9'sta (:bp),y') then	 						// sta (:bp),y			; 8
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+2]  := #9'tay';
	listing[i+6]  := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda				; 0
       add_sub(i+1) and										// add|sub			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10		; 2
       (pos('lda ', listing[i+3]) > 0) and 							// lda				; 3
       adc_sbc(i+4) and										// adc|sbc			; 4
       (listing[i+5] = #9'sta :bp+1') and							// sta :bp+1			; 5
       (pos('ldy :STACK', listing[i+6]) > 0) and 						// ldy :STACKORIGIN+10		; 6
       (listing[i+7] = #9'lda (:bp),y') then 							// lda (:bp),y			; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+2]  := #9'tay';
	listing[i+6]  := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda GD				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda GD+1				; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       add_sub(i+5) and										// add|sub				; 5
       (pos('sta :STACK', listing[i+6]) > 0) and						// sta :STACKORIGIN+10			; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       (pos('sta :STACK', listing[i+9]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 9
       (pos('lda ', listing[i+10]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*2+10	; 10
       adc_sbc(i+11) and									// adc|sbc				; 11
       (pos('sta :STACK', listing[i+12]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 12
       (pos('lda ', listing[i+13]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*3+10	; 13
       adc_sbc(i+14) and									// adc|sbc				; 14
       (pos('sta :STACK', listing[i+15]) > 0) then						// sta :STACKORIGIN+STACKWIDTH*3+10	; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+13], 6, 256)) then
       begin
	listing[i+10] := listing[i];
	listing[i+13] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda P				; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda P+1				; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+9			; 9
       add_sub(i+10) and									// add|sub H				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+9			; 11
       (pos('lda :STACK', listing[i+12]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 12
       adc_sbc(i+13) and									// adc|sbc				; 13
       (pos('sta :STACK', listing[i+14]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 14
       (pos('lda :STACK', listing[i+15]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+9	; 15
       adc_sbc(i+16) and									// adc|sbc				; 16
       (pos('sta :STACK', listing[i+17]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 17
       (pos('lda :STACK', listing[i+18]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+9	; 18
       adc_sbc(i+19) and									// adc|sbc				; 19
       (pos('sta :STACK', listing[i+20]) > 0) then						// sta :STACKORIGIN+STACKWIDTH*3+9	; 20
     if (copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+12], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+18], 6, 256) = copy(listing[i+20], 6, 256)) and
	(listing[i+2] = listing[i+11]) and
	(listing[i+5] = listing[i+14]) and
	(listing[i+8] = listing[i+17]) then
       begin
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';

	Result:=false;
       end;


    if (pos('sty :STACK', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and		// sty :STACKORIGIN+10	; 0
       (pos('sta ', listing[i+2]) > 0) and (pos('lda ', listing[i+3]) > 0) and			// add			; 1
       (pos('adc :STACK', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) then		// sta			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then				// lda			; 3
       begin											// adc :STACKORIGIN+10	; 4
												// sta			; 5
	listing[i]   := '';
	listing[i+4] := #9'adc ' + copy(listing[i+3], 6, 256);
	listing[i+3] := #9'tya';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda 					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+10			; 1
       (pos('lda :STACK', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and		// lda					; 2
       (pos('sta :STACK', listing[i+6]) > 0) then						// sta :STACKORIGIN+STACKWIDTH+10	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// lda :STACKORIGIN+10			; 4
	(copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// add  				; 5
	(copy(listing[i+3], 6, 256) <> copy(listing[i+7], 6, 256)) then				// sta :STACKORIGIN+10			; 6
       begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda 					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda 					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda 					; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and						// lda :STACKORIGIN+10			; 12
       add_sub(i+13) and									// add|sub				; 13
       (pos('sta ', listing[i+14]) > 0) and							// sta 					; 14
       (pos('lda :STACK', listing[i+15]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 15
       adc_sbc(i+16) and									// adc|sbc				; 16
       (pos('lda :STACK', listing[i+17]) = 0) and						// ~lda :STACKORIGIN+STACKWIDTH*2+10	; 17
       (pos('adc ', listing[i+18]) = 0) and (pos('sbc ', listing[i+18]) = 0) then		// ~adc|sbc				; 18
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda 					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda 					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda 					; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and						// lda :STACKORIGIN+10			; 12
       add_sub(i+13) and									// add|sub				; 13
       (pos('sta ', listing[i+14]) > 0) and							// sta 					; 14
       (pos('lda :STACK', listing[i+15]) = 0) and						// ~lda :STACKORIGIN+STACKWIDTH+10	; 15
       (pos('adc ', listing[i+16]) = 0) and (pos('sbc ', listing[i+16]) = 0) then		// ~adc|sbc				; 16
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+10			; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       (pos('lda ', listing[i+12]) > 0) and (listing[i+13] = #9'sta :bp+1') and			// lda :STACKORIGIN+STACKWIDTH+9	; 12
       (pos('ldy ', listing[i+14]) > 0) and							// sta :bp+1				; 13
       (pos('lda :STACK', listing[i+15]) > 0) and (listing[i+16] = #9'sta (:bp),y') then	// ldy :STACKORIGIN+9			; 14
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// lda :STACKORIGIN+10			; 15
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and				// sta (:bp),y				; 16
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+15], 6, 256)) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda :STACK', listing[i]) > 0) and							// lda :STACKORIGIN+9			; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+9	; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+9	; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta :bp+1') and		// lda :STACKORIGIN+STACKWIDTH+9	; 12
       (pos('ldy :STACK', listing[i+14]) > 0) and						// sta :bp+1				; 13
       (pos('lda ', listing[i+15]) > 0) and (listing[i+16] = #9'sta (:bp),y') then		// ldy :STACKORIGIN+9			; 14
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// lda #$70				; 15
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and				// sta (:bp),y				; 16
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda P				; 0
       (listing[i+1] = #9'add #$01') and							// add #$01				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+11			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda P+1				; 3
       (listing[i+4] = #9'adc #$00') and							// adc #$00				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+11	; 5
       (pos('lda ', listing[i+6]) > 0) and (pos('add :STACK', listing[i+7]) > 0) and		// lda LEVELDATA			; 6
       (listing[i+8] = #9'tay') and								// add :STACKORIGIN+11			; 7
       (pos('lda ', listing[i+9]) > 0) and (pos('adc :STACK', listing[i+10]) > 0) and		// tay					; 8
       (listing[i+11] = #9'sta :bp+1') then							// lda LEVELDATA+1			; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and				// adc :STACKORIGIN+STACKWIDTH+11	; 10
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then				// sta :bp+1				; 11
       begin
	listing[i+7]  := #9'sec:adc ' + copy(listing[i], 6, 256);
	listing[i+10] := #9'adc ' + copy(listing[i+3], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda XR				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+STACKWIDTH*2+11	; 1
       (pos('lda ', listing[i+4]) > 0) and							// lda XR+1				; 2
       (pos('sta ', listing[i+5]) > 0) and							// sta :STACKORIGIN+STACKWIDTH*3+11	; 3
       (pos('lda ', listing[i+6]) > 0) and							// lda YR				; 4
       (pos('sta ', listing[i+7]) > 0) and							// sta 					; 5
       (listing[i+8] = #9'clc') and								// lda YR+1				; 6
       (pos('lda ', listing[i+9]) > 0) and							// sta 					; 7
       (pos('adc :STACK', listing[i+10]) > 0) and						// clc					; 8
       (pos('sta ', listing[i+11]) > 0) and							// lda #$00				; 9
       (pos('lda ', listing[i+12]) > 0) and							// adc :STACKORIGIN+STACKWIDTH*2+11	; 10
       (pos('adc :STACK', listing[i+13]) > 0) and						// sta					; 11
       (pos('sta ', listing[i+14]) > 0) then							// lda #$00				; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and				// adc :STACKORIGIN+STACKWIDTH*3+11	; 13
	(copy(listing[i+3], 6, 256) = copy(listing[i+13], 6, 256)) then				// sta					; 14
       begin
	listing[i+10] := #9'adc ' + copy(listing[i], 6, 256);
	listing[i+13] := #9'adc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda :eax			; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN		; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda :eax+1			; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH	; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda 				; 4
       (listing[i+5] = #9'asl @') and								// asl @			; 5
       (listing[i+6] = #9'tay') and								// tay 				; 6
       (pos('lda :STACK', listing[i+7]) > 0) and						// lda :STACKORIGIN		; 7
       (pos('add ', listing[i+8]) > 0) and							// add				; 8
       (pos('sta ', listing[i+9]) > 0) and							// sta				; 9
       (pos('lda :STACK', listing[i+10]) > 0) and						// lda :STACKORIGIN+STACKWIDTH	; 10
       (pos('adc ', listing[i+11]) > 0) and							// adc				; 11
       (pos('sta ', listing[i+12]) > 0) then							// sta 				; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
        listing[i+7]  := listing[i];
	listing[i+10] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+10			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH		; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda					; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and (pos('ldy ', listing[i+12]) > 0) and		// sta :STACKORIGIN+STACKWIDTH*3	; 11
       (pos('lda :STACK', listing[i+13]) > 0) and (pos('sta adr.', listing[i+14]) > 0) and	// ldy :STACKORIGIN+9			; 12
       (pos('lda :STACK', listing[i+15]) > 0) and (pos('sta adr.', listing[i+16]) > 0) and	// lda :STACKORIGIN+10			; 13
       (pos('lda :STACK', listing[i+17]) = 0) then						// sta adr.SPAWNERS,y			; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH		; 15
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) then				// sta adr.SPAWNERS+1,y			; 16
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('ldy :STACK', listing[i+6]) > 0) and						// ldy :STACKORIGIN+9			; 6
       (pos(' adr.', listing[i+7]) > 0) and							// mva V adr.BUF,y			; 7
       (listing[i+8] = '') then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda V				; 6
       AND_ORA_EOR(i+7) and									// ora|and|eor				; 7
       (pos('ldy :STACK', listing[i+8]) > 0) and						// ldy :STACKORIGIN+9			; 8
       (pos(' adr.', listing[i+9]) > 0) and							// sta adr.BUF,y			; 9
       (listing[i+10] = '') then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[i+2] := #9'tay';
	listing[i+8] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda					; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('lda :STACK', listing[i+12]) > 0) and (listing[i+13] = #9'sta :bp2') and		// lda :STACKORIGIN+9			; 12
       (pos('lda :STACK', listing[i+14]) > 0) and (listing[i+15] = #9'sta :bp2+1') and		// sta :bp2				; 13
       (listing[i+16] = #9'ldy #$00') then							// lda :STACKORIGIN+STACKWIDTH+9	; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and				// sta :bp2+1				; 15
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then				// ldy #$00				; 16
       begin
	listing[i+2] := listing[i+13];
	listing[i+5] := listing[i+15];

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+10			; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and		// lda 					; 2
       (pos('lda :STACK', listing[i+6]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('add ', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and			// lda 					; 4
       (pos('lda :STACK', listing[i+9]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       (pos('adc ', listing[i+10]) > 0) and (pos('sta ', listing[i+11]) > 0) and		// lda :STACKORIGIN+10			; 6
       (pos('lda :STACK', listing[i+12]) > 0) and						// add					; 7
       (pos('adc ', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) then		// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda :STACKORIGIN+STACKWIDTH+10	; 9
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and				// adc 					; 10
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) then				// sta					; 11
       begin											// lda :STACKORIGIN+STACKWIDTH*2+10	; 12
	listing[i+6]  := listing[i];								// adc					; 13
	listing[i+9]  := listing[i+2];								// sta					; 14
	listing[i+12] := listing[i+4];								// ?lda :STACKORIGIN+STACKWIDTH*3+	; 15
												// ?adc					; 16
	listing[i]   := '';									// ?sta					; 17
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	if (pos('lda :STACKORIGIN+STACKWIDTH*3+', listing[i+15]) > 0) and
	   (pos('adc ', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) then
	begin
	 listing[i+15] := '';
	 listing[i+16] := '';
	 listing[i+17] := '';
	end;

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('add :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('sta :STACK', listing[i+2]) > 0) and						// add :STACKORIGIN+10			; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('adc :STACK', listing[i+4]) > 0) and		// sta :STACKORIGIN+9			; 2
       (pos('sta :STACK', listing[i+5]) > 0) and						// lda					; 3
       (pos('mwa ', listing[i+6]) > 0) and (pos(' :bp2', listing[i+6]) > 0) and			// adc :STACKORIGIN+STACKWIDTH+10	; 4
       (pos('ldy ', listing[i+7]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda :STACK', listing[i+8]) > 0) and (listing[i+9] = #9'sta (:bp2),y') and		// mwa xxx bp2				; 6
       (listing[i+10] = #9'iny') and								// ldy					; 7
       (pos('lda :STACK', listing[i+11]) > 0) and (listing[i+12] = #9'sta (:bp2),y') then	// lda :STACKORIGIN+9			; 8
     if {(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and}				// sta (:bp2),y				; 9
	(copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and				// iny 					; 10
	{(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and}				// lda :STACKORIGIN+STACKWIDTH+9 	; 11
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then				// sta (:bp2),y				; 12
       begin

	btmp[0]  := listing[i+6];
	btmp[1]  := listing[i+7];
	btmp[2]  := listing[i];
	btmp[3]  := listing[i+1];
	btmp[4]  := listing[i+9];
	btmp[5]  := listing[i+10];
	btmp[6]  := listing[i+3];
	btmp[7]  := listing[i+4];
	btmp[8]  := listing[i+12];

	listing[i]   := btmp[0];
	listing[i+1] := btmp[1];
	listing[i+2] := btmp[2];
	listing[i+3] := btmp[3];
	listing[i+4] := btmp[4];
	listing[i+5] := btmp[5];
	listing[i+6] := btmp[6];
	listing[i+7] := btmp[7];
	listing[i+8] := btmp[8];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+1]) > 0) and		// lda (:bp2),y				; 0
       (listing[i+2] = #9'iny') and								// sta :STACKORIGIN+9			; 1
       (listing[i+3] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+4]) > 0) and		// iny					; 2
       (pos('lda ', listing[i+5]) > 0) and (pos('add :STACK', listing[i+6]) > 0) and		// lda (:bp2),y				; 3
       (pos('sta ', listing[i+7]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+8]) > 0) and (pos('adc :STACK', listing[i+9]) > 0) and		// lda 					; 5
       (pos('sta ', listing[i+10]) > 0) then							// add :STACKORIGIN+9			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta					; 7
	(copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then				// lda 					; 8
	begin											// adc :STACKORIGIN+STACKWIDTH+9	; 9
	  listing[i]    := '';									// sta					; 10
	  listing[i+1]  := '';
	  listing[i+2]  := '';
	  listing[i+3]  := '';

	  listing[i+4] := listing[i+5];
	  listing[i+5] := #9'add (:bp2),y';
	  listing[i+6] := #9'iny';

	  listing[i+9] := #9'adc (:bp2),y';

	  Result:=false;
	end;


    if (listing[i] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+1]) > 0) and		// lda (:bp2),y				; 0
       (listing[i+2] = #9'iny') and								// sta :STACKORIGIN+9			; 1
       (listing[i+3] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+4]) > 0) and		// iny					; 2
       (pos('lda :STACK', listing[i+5]) > 0) and (pos('add ', listing[i+6]) > 0) and		// lda (:bp2),y				; 3
       (pos('sta ', listing[i+7]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda :STACK', listing[i+8]) > 0) and (pos('adc ', listing[i+9]) > 0) and		// lda :STACKORIGIN+9			; 5
       (pos('sta ', listing[i+10]) > 0) then							// add					; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sta					; 7
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then				// lda :STACKORIGIN+STACKWIDTH+9	; 8
	begin											// adc					; 9
	  listing[i+1] := '';									// sta					; 10
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';

	  listing[i+8] := listing[i];

	  Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and							// lda YR				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+10			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda YR+1				; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda FLOODFILLSTACK			; 4
       (pos('add ', listing[i+5]) > 0) and							// add :STACKORIGIN+9			; 5
       (listing[i+6] = #9'sta :bp2') and							// sta :bp2				; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda FLOODFILLSTACK+1			; 7
       (pos('adc', listing[i+8]) > 0) and							// adc :STACKORIGIN+STACKWIDTH+9	; 8
       (listing[i+9] = #9'sta :bp2+1') and							// sta :bp2+1				; 9
       (listing[i+10] = #9'ldy #$00') and							// ldy #$00				; 10
       (pos('lda :STACK', listing[i+11]) > 0) and						// lda :STACKORIGIN+10			; 11
       (listing[i+12] = #9'sta (:bp2),y') and							// sta (:bp2),y				; 12
       (listing[i+13] = #9'iny') and								// iny					; 13
       (pos('lda :STACK', listing[i+14]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 14
       (listing[i+15] = #9'sta (:bp2),y') then							// sta (:bp2),y				; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+11] := listing[i];
	listing[i+14] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and
       (listing[i+6] = #9'sta :bp2') and
       (pos('lda ', listing[i+7]) > 0) and (pos('adc', listing[i+8]) > 0) and
       (listing[i+9] = #9'sta :bp2+1') and
       (listing[i+10] = #9'ldy #$00') and
       (pos('lda ', listing[i+11]) > 0) and (listing[i+12] = #9'sta (:bp2),y') and
       (listing[i+13] = #9'iny') and
       (pos('lda ', listing[i+14]) > 0) and (listing[i+15] = #9'sta (:bp2),y') and
       (listing[i+16] = #9'iny') and
       (pos('lda :STACK', listing[i+17]) > 0) and (listing[i+18] = #9'sta (:bp2),y') and
       (listing[i+19] = #9'iny') and
       (pos('lda :STACK', listing[i+20]) > 0) and (listing[i+21] = #9'sta (:bp2),y') then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+20], 6, 256)) then
	begin
{
	lda XR				; 0
	sta :STACKORIGIN+STACKWIDTH*2+10; 1
	lda XR+1			; 2
	sta :STACKORIGIN+STACKWIDTH*3+10; 3
	lda FLOODFILLSTACK		; 4
	add :STACKORIGIN+9		; 5
	sta :bp2			; 6
	lda FLOODFILLSTACK+1		; 7
	adc :STACKORIGIN+STACKWIDTH+9	; 8
	sta :bp2+1			; 9
	ldy #$00			; 10
	lda YR				; 11
	sta (:bp2),y			; 12
	iny				; 13
	lda YR+1			; 14
	sta (:bp2),y			; 15
	iny				; 16
	lda :STACKORIGIN+STACKWIDTH*2+10; 17
	sta (:bp2),y			; 18
	iny				; 19
	lda :STACKORIGIN+STACKWIDTH*3+10; 20
	sta (:bp2),y			; 21
}
	listing[i+17] := listing[i];
	listing[i+20] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
	end;


    if (pos('mwa ', listing[i]) > 0) and (pos(' :bp2', listing[i]) > 0) and			// mwa ...	:bp2			; 0
       (pos('ldy ', listing[i+1]) > 0) and							// ldy #$05				; 1
       (listing[i+2] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 2
       (listing[i+3] = #9'iny') and								// iny					; 3
       add_sub(i+4) and										// add #$01				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+9			; 5
       (listing[i+6] = #9'lda (:bp2),y') and							// lda (:bp2),y				; 6
       adc_sbc(i+7) and										// adc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 8
       (pos('mwa ', listing[i+9]) > 0) and (pos(' :bp2', listing[i+9]) > 0) and			// mwa ...	:bp2			; 9
       (pos('ldy ', listing[i+10]) > 0) and							// ldy #$05				; 10
       (pos('lda :STACK', listing[i+11]) > 0) and						// lda :STACKORIGIN+9			; 11
       (listing[i+12] = #9'sta (:bp2),y') and							// sta (:bp2),y				; 12
       (listing[i+13] = #9'iny') and								// iny					; 13
       (pos('lda :STACK', listing[i+14]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 14
       (listing[i+15] = #9'sta (:bp2),y') then							// sta (:bp2),y				; 15
     if (listing[i] = listing[i+9]) and
     	(listing[i+1] = listing[i+10]) and
     	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+3] := listing[i+4];
	listing[i+4] := listing[i+12];
	listing[i+5] := listing[i+13];

	listing[i+8] := listing[i+12];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('add ', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('adc ', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('adc ', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('adc ', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda :eax			; 0
	sta :STACKORIGIN+10		; 1
	lda :eax+1			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda :eax+2			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	lda :eax+3			; 6
	sta :STACKORIGIN+STACKWIDTH*3+10; 7
	lda ERROR			; 8
	add :STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	adc :STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	adc :STACKORIGIN+STACKWIDTH*2+10; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	adc :STACKORIGIN+STACKWIDTH*3+10; 18
	sta ERROR+3			; 19
}
	listing[i+9]  := #9'add ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'adc ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'adc ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and
       (pos('sta ', listing[i+6]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and (pos('add ', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) and
       (pos('lda ', listing[i+10]) > 0) and (pos('adc ', listing[i+11]) > 0) and (pos('sta ', listing[i+12]) > 0) and
       (pos('lda ', listing[i+13]) > 0) and (pos('adc ', listing[i+14]) > 0) and (pos('sta ', listing[i+15]) > 0) and
       (pos('lda ', listing[i+16]) > 0) and (pos('adc ', listing[i+17]) > 0) and (pos('sta ', listing[i+18]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+17], 6, 256)) then
	begin
{
	lda :eax			; 0
	sta :STACKORIGIN+10		; 1
	lda :eax+1			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda :eax+2			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	sta :STACKORIGIN+STACKWIDTH*3+10; 6
	lda ERROR			; 7
	add :STACKORIGIN+10		; 8
	sta ERROR			; 9
	lda ERROR+1			; 10
	adc :STACKORIGIN+STACKWIDTH+10	; 11
	sta ERROR+1			; 12
	lda ERROR+2			; 13
	adc :STACKORIGIN+STACKWIDTH*2+10; 14
	sta ERROR+2			; 15
	lda ERROR+3			; 16
	adc :STACKORIGIN+STACKWIDTH*3+10; 17
	sta ERROR+3			; 18
}
	listing[i+8]  := #9'add ' + copy(listing[i], 6, 256);
	listing[i+11] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i+14] := #9'adc ' + copy(listing[i+4], 6, 256);
	listing[i+17] := #9'adc ' + copy(listing[i+4], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and							// lda #$00			; 0
       (listing[i+1] = #9'sta :eax+2') and							// sta :eax+2			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda #$00			; 2
       (listing[i+3] = #9'sta :eax+3') and							// sta :eax+3			; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda #$80			; 4
       (listing[i+5] = #9'add :eax') and							// add :eax			; 5
       (pos('sta ', listing[i+6]) > 0) and							// sta W			; 6
       (pos('lda ', listing[i+7]) > 0) and							// lda #$B0			; 7
       (listing[i+8] = #9'adc :eax+1') and							// adc :eax+1			; 8
       (pos('sta ', listing[i+9]) > 0) and							// sta W+1			; 9
       (pos('lda ', listing[i+10]) = 0) and (pos('adc ', listing[i+11]) = 0) then
       begin
	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and
       (pos('lda :STACK', listing[i+8]) > 0) and (pos('add ', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda :STACK', listing[i+11]) > 0) and (pos('adc ', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda :STACK', listing[i+14]) > 0) and (pos('adc ', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda :STACK', listing[i+17]) > 0) and (pos('adc ', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+17], 6, 256)) then
	begin
{
	lda :eax			; 0
	sta :STACKORIGIN+10		; 1
	lda :eax+1			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda :eax+2			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	lda :eax+3			; 6
	sta :STACKORIGIN+STACKWIDTH*3+10; 7
	lda :STACKORIGIN+10		; 8
	add 				; 9
	sta ERROR			; 10
	lda :STACKORIGIN+STACKWIDTH+10	; 11
	adc 				; 12
	sta ERROR+1			; 13
	lda :STACKORIGIN+STACKWIDTH*2+10; 14
	adc 				; 15
	sta ERROR+2			; 16
	lda :STACKORIGIN+STACKWIDTH*3+10; 17
	adc 				; 18
	sta ERROR+3			; 19
}
	listing[i+8]  := #9'lda ' + copy(listing[i], 6, 256);
	listing[i+11] := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+14] := #9'lda ' + copy(listing[i+4], 6, 256);
	listing[i+17] := #9'lda ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9			; 1
       (pos('lda :STACK', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and		// lda					; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda :STACK', listing[i+7]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('adc ', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then			// lda :STACKORIGIN+9			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// add					; 5
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then begin			// sta					; 6
	listing[i+4] := listing[i];								// lda :STACKORIGIN+STACKWIDTH+9	; 7
	listing[i+7] := listing[i+2];								// adc					; 8
	listing[i]   := '';									// sta					; 9
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda :STACK', listing[i+2]) > 0) and (pos('add ', listing[i+3]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('sta ', listing[i+4]) > 0) and (pos('lda :STACK', listing[i+5]) > 0) and		// lda :STACKORIGIN+9			; 2
       (pos('adc ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) then			// add					; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then				// sta					; 4
      begin											// lda :STACKORIGIN+STACKWIDTH+9	; 5
	listing[i+5] := listing[i];								// adc					; 6
	listing[i]   := '';									// sta					; 7
	listing[i+1] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and							// sta :eax			; 1
       (pos('add ', listing[i+3]) > 0) and							// lda 				; 2
       (pos('sta ', listing[i+4]) > 0) then							// add :eax			; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then				// sta				; 4
      begin
	listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) = 0) and							// ~lda 			; 0
       (pos('sta ', listing[i+1]) > 0) and							// sta :eax			; 1
       (pos('lda ', listing[i+2]) > 0) and							// lda 				; 2
       (pos('add ', listing[i+3]) > 0) and							// add :eax			; 3
       (pos('sta ', listing[i+4]) > 0) then							// sta				; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
      begin
	listing[i+3] := #9'add ' + copy(listing[i+2], 6, 256);
	listing[i+1]   := '';
	listing[i+2] := '';

	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and			// sta :eax			; 1
       (pos('lda ', listing[i+4]) > 0) and							// lda				; 2
       (pos('add ', listing[i+5]) > 0) and							// sta :eax+1			; 3
       (pos('sta ', listing[i+6]) > 0) and							// lda				; 4
       (pos('lda ', listing[i+7]) > 0) and							// add :eax			; 5
       (pos('adc ', listing[i+8]) > 0) then							// sta				; 6
       //(pos('sta ', listing[i+9]) > 0) then							// lda				; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// adc :eax+1			; 8
	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then				// sta				; 9
      begin
	listing[i+5] := #9'add ' + copy(listing[i], 6, 256);
	listing[i+8] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
      end;


    if (pos('lda :STACK', listing[i]) > 0) and (listing[i+1] = #9'sta :eax') and		// lda :STACKORIGIN+9			; 0
       (pos('lda :STACK', listing[i+2]) > 0) and (listing[i+3] = #9'sta :eax+1') and		// sta :eax				; 1
       (pos('lda ', listing[i+4]) > 0) and (listing[i+5] = #9'add :eax') and			// lda :STACKORIGIN+STACKWIDTH+9	; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) = 0) then			// sta :eax+1				; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then				// lda					; 4
      begin											// add :eax				; 5
	listing[i+5] := #9'add ' + copy(listing[i], 6, 256);					// sta					; 6
	listing[i]   := '';									// ~lda					; 7
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
      end;


    if add_sub(i) and										// add|sub				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('lda ', listing[i+2]) > 0) and		// sta :STACKORIGIN+9			; 1
       adc_sbc(i+3) and										// lda					; 2
       (pos('sta :STACK', listing[i+4]) > 0) and						// adc|sbc				; 3
       (pos('lda :STACK', listing[i+5]) > 0) and (pos('sta ', listing[i+6]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda :STACK', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) then		// lda :STACKORIGIN+9			; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sta					; 6
	(copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then				// lda :STACKORIGIN+STACKWIDTH+9	; 7
      begin											// sta					; 8
	listing[i+1] := listing[i+6];
	listing[i+4] := listing[i+8];

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false;
      end;


    if (pos('lda #', listing[i]) > 0) and							// lda #				; 0
       (pos('add #', listing[i+1]) > 0) and							// add #				; 1
       (pos('sta ', listing[i+2]) > 0) and							// sta :STACKORIGIN+10			; 2
       (pos('lda #', listing[i+3]) > 0) and							// lda #				; 3
       (pos('adc #', listing[i+4]) > 0) and							// adc #$00				; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda #', listing[i+6]) > 0) and							// lda #				; 6
       (pos('adc #', listing[i+7]) > 0) and							// adc #$00				; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda #', listing[i+9]) > 0) and							// lda #				; 9
       (pos('adc #', listing[i+10]) > 0) and							// adc #$00				; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
      begin
	p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16 + GetVAL(copy(listing[i+9], 6, 256)) shl 24;
	err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;

	p:=p + err;

	listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
	listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
	listing[i+6] := #9'lda #$' + IntToHex(byte(p shr 16), 2);
	listing[i+9] := #9'lda #$' + IntToHex(byte(p shr 24), 2);

	listing[i+1] := '';
	listing[i+4] := '';
	listing[i+7] := '';
	listing[i+10] := '';

	Result:=false;
       end;


    if (listing[i] = #9'clc') and								// clc		; 0
       (pos('lda #', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) and			// lda #$	; 1
       (pos('lda #', listing[i+4]) > 0) and (pos('sta ', listing[i+6]) > 0) and			// adc #$	; 2
       (pos('adc #', listing[i+2]) > 0) and (pos('adc #', listing[i+5]) > 0) and		// sta 		; 3
       (pos('lda #', listing[i+7]) = 0) and (pos('adc ', listing[i+8]) = 0) then		// lda #$	; 4
     begin											// adc #$	; 5
												// sta 		; 6
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;
      err := GetVAL(copy(listing[i+2], 6, 256)) + GetVAL(copy(listing[i+5], 6, 256)) shl 8;

      p:=p + err;

      listing[i]   := '';
      listing[i+1] := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+2] := '';
      listing[i+4] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+5] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// lda #$	; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// add #$	; 1
       (pos('add #', listing[i+1]) > 0) and (pos('adc #', listing[i+4]) > 0) and		// sta 		; 2
       (pos('lda #', listing[i+6]) = 0)  and (pos('adc ', listing[i+7]) = 0) then		// lda #$	; 3
     begin											// adc #$	; 4
												// sta 		; 5
      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8;
      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;

      p:=p + err;

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';
      listing[i+3]   := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+4] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// lda #$	; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// add #$	; 1
       (pos('lda #', listing[i+6]) > 0) and (pos('sta ', listing[i+8]) > 0) and			// sta 		; 2
       (pos('add #', listing[i+1]) > 0) and							// lda #$	; 3
       (pos('adc #', listing[i+4]) > 0) and							// adc #$	; 4
       (pos('adc #', listing[i+7]) > 0) and							// sta 		; 5
       (pos('lda #', listing[i+9]) = 0) and (pos('adc ', listing[i+10]) = 0) then		// lda #$	; 6
     begin											// adc #$	; 7
												// sta 		; 8
      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16;
      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16;

      p:=p + err;

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';
      listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+4] := '';
      listing[i+6] := #9'lda #$' + IntToHex(byte(p shr 16), 2);
      listing[i+7] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and							// lda #$80			; 0
       (pos('add ', listing[i+1]) > 0) and							// add :eax			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9		; 2
       (pos('lda #', listing[i+3]) > 0) and							// lda #$B0			; 3
       (pos('adc ', listing[i+4]) > 0) and							// adc :eax+1			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+9		; 6
       (pos('add #', listing[i+7]) > 0) and							// add #$03			; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta P			; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9; 9
       (pos('adc #', listing[i+10]) > 0) and							// adc #$00			; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta P+1			; 11
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin

      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8;
      err :=  GetVAL(copy(listing[i+7], 6, 256)) + GetVAL(copy(listing[i+10], 6, 256)) shl 8;

      p:=p + err;

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+2] := listing[i+8];
      listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda W			; 0
       (pos('add #', listing[i+1]) > 0) and							// add #$00			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9		; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda W+1			; 3
       (pos('adc #', listing[i+4]) > 0) and							// adc #$04			; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+9		; 6
       (pos('sub #', listing[i+7]) > 0) and							// sub #$36			; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta 				; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9; 9
       (pos('sbc #', listing[i+10]) > 0) and							// sbc #$00			; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta 				; 11
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;
      err :=  GetVAL(copy(listing[i+7], 6, 256)) + GetVAL(copy(listing[i+10], 6, 256)) shl 8;

      p:=p - err;

      listing[i+1] := #9'add #$' + IntToHex(p and $ff, 2);
      listing[i+4] := #9'adc #$' + IntToHex(byte(p shr 8), 2);

      listing[i+2] := listing[i+8];
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('add #', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('adc #', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('adc #', listing[i+7]) > 0) and (pos('sta :STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('adc #', listing[i+10]) > 0) and (pos('sta :STACK', listing[i+11]) > 0) and
       (pos('lda :STACK', listing[i+12]) > 0) and (pos('add #', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) and
       (pos('lda :STACK', listing[i+15]) > 0) and (pos('adc #', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda :STACK', listing[i+18]) > 0) and (pos('adc #', listing[i+19]) > 0) and (pos('sta ', listing[i+20]) > 0) and
       (pos('lda :STACK', listing[i+21]) > 0) and (pos('adc #', listing[i+22]) > 0) and (pos('sta ', listing[i+23]) > 0) then
      if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	 (copy(listing[i+8], 6, 256) = copy(listing[i+18], 6, 256)) and
	 (copy(listing[i+11], 6, 256) = copy(listing[i+21], 6, 256)) and
	 (copy(listing[i], 6, 256) = copy(listing[i+14], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+17], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+20], 6, 256)) and
	 (copy(listing[i+9], 6, 256) = copy(listing[i+23], 6, 256)) then
     begin
{
	lda W				; 0
	add #$00			; 1
	sta :STACKORIGIN+9		; 2
	lda W+1				; 3
	adc #$04			; 4
	sta :STACKORIGIN+STACKWIDTH+9	; 5
	lda W+2				; 6
	adc #$00			; 7
	sta :STACKORIGIN+STACKWIDTH*2+9	; 8
	lda W+3				; 9
	adc #$00			; 10
	sta :STACKORIGIN+STACKWIDTH*3+9	; 11
	lda :STACKORIGIN+9		; 12
	add #$36			; 13
	sta W				; 14
	lda :STACKORIGIN+STACKWIDTH+9	; 15
	adc #$00			; 16
	sta W+1				; 17
	lda :STACKORIGIN+STACKWIDTH*2+9	; 18
	adc #$00			; 19
	sta W+2				; 20
	lda :STACKORIGIN+STACKWIDTH*3+9	; 21
	adc #$00			; 22
	sta W+3				; 23
}
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;
      err :=  GetVAL(copy(listing[i+13], 6, 256)) + GetVAL(copy(listing[i+16], 6, 256)) shl 8 + GetVAL(copy(listing[i+19], 6, 256)) shl 16 + GetVAL(copy(listing[i+22], 6, 256)) shl 24;

      p:=p+err;

      listing[i+1] := #9'add #$' + IntToHex(p and $ff, 2);
      listing[i+4] := #9'adc #$' + IntToHex(byte(p shr 8), 2);
      listing[i+7] := #9'adc #$' + IntToHex(byte(p shr 16), 2);
      listing[i+10] := #9'adc #$' + IntToHex(byte(p shr 24), 2);

      listing[i+2] := listing[i+14];
      listing[i+5] := listing[i+17];
      listing[i+8] := listing[i+20];
      listing[i+11] := listing[i+23];

      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';
      listing[i+15] := '';
      listing[i+16] := '';
      listing[i+17] := '';
      listing[i+18] := '';
      listing[i+19] := '';
      listing[i+20] := '';
      listing[i+21] := '';
      listing[i+22] := '';
      listing[i+23] := '';

      Result:=false;
     end;


   if (pos('lda ', listing[i]) > 0) and								// lda W			; 0
      (pos('add #', listing[i+1]) > 0) and							// add #$00			; 1
      (pos('sta :STACK', listing[i+2]) > 0) and							// sta :STACKORIGIN+9		; 2
      (pos('lda ', listing[i+3]) > 0) and							// lda W+1			; 3
      (pos('adc #', listing[i+4]) > 0) and							// adc #$04			; 4
      (pos('sta :STACK', listing[i+5]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9; 5
      (pos('lda :STACK', listing[i+6]) > 0) and							// lda :STACKORIGIN+9		; 6
      (pos('add #', listing[i+7]) > 0) and							// add #$36			; 7
      (pos('sta ', listing[i+8]) > 0) and							// sta W			; 8
      (pos('lda :STACK', listing[i+9]) > 0) and							// lda :STACKORIGIN+STACKWIDTH+9; 9
      (pos('adc #', listing[i+10]) > 0) and							// adc #$00			; 10
      (pos('sta ', listing[i+11]) > 0) then							// sta W+1			; 11
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;
      err :=  GetVAL(copy(listing[i+7], 6, 256)) + GetVAL(copy(listing[i+10], 6, 256)) shl 8;

      p:=p + err;

      listing[i+1] := #9'add #$' + IntToHex(p and $ff, 2);
      listing[i+2] := listing[i+8];
      listing[i+4] := #9'adc #$' + IntToHex(byte(p shr 8), 2);
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      Result:=false;
     end;


    if (pos('lda :STACK', listing[i]) = 0) and
       (pos('lda ', listing[i]) > 0) and							// lda K			; 0
       (listing[i+1] = #9'add #$01') and							// add #$01			; 1
       (pos('sta ', listing[i+2]) > 0) and							// sta K			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda K+1			; 3
       (listing[i+4] = #9'adc #$00') and							// adc #$00			; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta K+1			; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda K+2			; 6
       (listing[i+7] = #9'adc #$00') and							// adc #$00			; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta K+2			; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda K+3			; 9
       (listing[i+10] = #9'adc #$00') and							// adc #$00			; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta K+3			; 11
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	 (copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
	listing[i] := #9'ind ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
    end;


    if (l = 6) and
       (pos('lda :STACK', listing[i]) = 0) and
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// lda W		; 0
       (pos('lda ', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// add #$01..$ff	; 1
       (pos('add #$', listing[i+1]) > 0) and (listing[i+4] = #9'adc #$00') and			// sta W		; 2
       (pos('add #$00', listing[i+1]) = 0) then							// lda W+1		; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// adc #$00		; 4
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then				// sta W+1		; 5
     begin

	if copy(listing[i+1], 6, 256) = '#$01' then begin
	 listing[i]   := #9'inw '+copy(listing[i], 6, 256);
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	end else begin
	 listing[i+3] := #9'scc';
	 listing[i+4] := #9'inc '+copy(listing[i+5], 6, 256);
	 listing[i+5] := '';
	end;

	Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and (pos('sta :STACK', listing[i+1]) > 0) and		// lda #$00		; 0
       (pos('add :STACK', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) then		// sta :STACKORIGIN+10	; 1
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then begin			// add :STACKORIGIN+10	; 2
	listing[i+1] := '';									// sta			; 3
	listing[i+2] := #9'add #$00';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and			// lda			; 0
       (pos('ldy ', listing[i+2]) > 0) and (pos('lda ', listing[i+3]) > 0) then			// add			; 1
     begin											// ldy			; 2
	listing[i]   := '';									// lda 			; 3
	listing[i+1] := '';

	Result := false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'add #$01') and			// lda I		; 0
       (listing[i+2] = #9'tay') and (pos(',y', listing[i]) = 0) and				// add #$01		; 1
       ( (pos(' adr.', listing[i+3]) > 0) and (pos(',y', listing[i+3]) > 0) ) then		// tay			; 2
     begin											// lda adr.TAB,y	; 3
	listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
	listing[i+1] := #9'iny';
	listing[i+2] := '';

	Result := false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos(',y', listing[i+2]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos(',y', listing[i+4]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos(',y', listing[i+6]) > 0) and
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and
       (pos('sta :STACK', listing[i+5]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('lda ', listing[i+11]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('lda ', listing[i+17]) > 0) and
       (pos('sta ', listing[i+10]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('sta ', listing[i+16]) > 0) and (pos('sta ', listing[i+19]) > 0) and
       (pos('add :STACK', listing[i+9]) > 0) and (pos('adc :STACK', listing[i+12]) > 0) and
       (pos('adc :STACK', listing[i+15]) > 0) and (pos('adc :STACK', listing[i+18]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then begin
{
	lda adr.MY,y			; 0
	sta :STACKORIGIN+10		; 1
	lda adr.MY+1,y			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda adr.MY+2,y			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	lda adr.MY+3,y			; 6
	sta :STACKORIGIN+STACKWIDTH*3+10; 7
	lda X				; 8
	add :STACKORIGIN+10		; 9
	sta A				; 10
	lda X+1				; 11
	adc :STACKORIGIN+STACKWIDTH+10	; 12
	sta A+1				; 13
	lda X+2				; 14
	adc :STACKORIGIN+STACKWIDTH*2+10; 15
	sta A+2				; 16
	lda X+3				; 17
	adc :STACKORIGIN+STACKWIDTH*3+10; 18
	sta A+3				; 19
}
	 listing[i+9]  := #9'add ' + copy(listing[i], 6, 256);
	 listing[i+12] := #9'adc ' + copy(listing[i+2], 6, 256);
	 listing[i+15] := #9'adc ' + copy(listing[i+4], 6, 256);
	 listing[i+18] := #9'adc ' + copy(listing[i+6], 6, 256);

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';

	 Result := false;
	end;


    if (i=0) and										// lda TB		; 0
       (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'add #$00') and			// add #$00		; 1
       (listing[i+2] = #9'tay') and 								// tay			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda TB+1		; 3
       (listing[i+4] = #9'adc #$00') and (listing[i+5] = #9'sta :bp+1') and			// adc #$00		; 4
       (listing[i+6] = #9'lda (:bp),y') then							// sta :bp+1		; 5
      begin											// lda (:bp),y		; 6
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+4] := '';

	Result := false;
      end;


    if (listing[i] = #9'lda (:bp2),y') and (listing[i+3] = #9'lda (:bp2),y') and
       (listing[i+6] = #9'lda (:bp2),y') and (listing[i+9] = #9'lda (:bp2),y') and
       (pos('sta :STACK', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+4]) > 0) and
       (pos('sta :STACK', listing[i+7]) > 0) and (pos('sta :STACK', listing[i+10]) > 0) and
       (listing[i+2] = #9'iny') and (listing[i+5] = #9'iny') and (listing[i+8] = #9'iny') and
       (pos('lda :STACK', listing[i+11]) > 0) and (pos('lda :STACK', listing[i+14]) > 0) and
       (pos('lda :STACK', listing[i+17]) > 0) and (pos('lda :STACK', listing[i+20]) > 0) and
       (pos('sta ', listing[i+13]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('sta ', listing[i+19]) > 0) and (pos('sta ', listing[i+22]) > 0) and
       (pos('add :STACK', listing[i+12]) > 0) and (pos('adc :STACK', listing[i+15]) > 0) and
       (pos('adc :STACK', listing[i+18]) > 0) and (pos('adc :STACK', listing[i+21]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+10], 6, 256) = copy(listing[i+21], 6, 256)) then begin
{
	lda (:bp2),y			; 0
	sta :STACKORIGIN+10		; 1
	iny				; 2
	lda (:bp2),y			; 3
	sta :STACKORIGIN+STACKWIDTH+10	; 4
	iny				; 5
	lda (:bp2),y			; 6
	sta :STACKORIGIN+STACKWIDTH*2+10; 7
	iny				; 8
	lda (:bp2),y			; 9
	sta :STACKORIGIN+STACKWIDTH*3+10; 10
	lda :STACKORIGIN+9		; 11
	add :STACKORIGIN+10		; 12
	sta X				; 13
	lda :STACKORIGIN+STACKWIDTH+9	; 14
	adc :STACKORIGIN+STACKWIDTH+10	; 15
	sta X+1				; 16
	lda :STACKORIGIN+STACKWIDTH*2+9	; 17
	adc :STACKORIGIN+STACKWIDTH*2+10; 18
	sta X+2				; 19
	lda :STACKORIGIN+STACKWIDTH*3+9	; 20
	adc :STACKORIGIN+STACKWIDTH*3+10; 21
	sta X+3				; 22
}
	 listing[i+12] := #9'add (:bp2),y+';
	 listing[i+15] := #9'adc (:bp2),y+';
	 listing[i+18] := #9'adc (:bp2),y+';
	 listing[i+21] := #9'adc (:bp2),y';

	 listing[i]    := '';
	 listing[i+1]  := '';
	 listing[i+2]  := '';
	 listing[i+3]  := '';
	 listing[i+4]  := '';
	 listing[i+5]  := '';
	 listing[i+6]  := '';
	 listing[i+7]  := '';
	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';

	 Result := false;
	end;


    if (pos('ldy ', listing[i]) > 0) and (pos('ldy ', listing[i+3]) > 0) and			// ldy				; 0	0=3 mnemonic
       (pos('lda adr.', listing[i+1]) > 0) and (pos('lda adr.', listing[i+4]) > 0) and		// lda adr.???,y		; 1	1=4 arg
       (pos(',y', listing[i+1]) > 0) and (pos(',y', listing[i+4]) > 0) and			// sta :STACKORIGIN+10		; 2	2=6 arg
       (pos('sta :STACK', listing[i+2]) > 0) and (pos('lda :STACK', listing[i+6]) > 0) and	// ldy				; 3
       (pos('sta :STACK', listing[i+5]) > 0) and						// lda adr.???,y		; 4
       add_sub_stack(i+7) then									// sta :STACKORIGIN+11		; 5	5=7 arg
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda :STACKORIGIN+10		; 6
	(copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then 				// add|sub :STACKORIGIN+11	; 7
       begin
	listing[i+2] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+4] := copy(listing[i+7], 1, 5) + copy(listing[i+4], 6, 256);
	listing[i+7] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and 							// lda :STACKORIGIN+9			; 0
       add_sub(i+1) and										// add :STACKORIGIN+10			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and 						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and 							// lda :STACKORIGIN+STACKWIDTH+9	; 3
       adc_sbc(i+4) and										// adc :STACKORIGIN+STACKWIDTH+10	; 4
       (pos('sta :STACK', listing[i+5]) > 0) and 						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('ldy :STACK', listing[i+6]) > 0) and 						// ldy :STACKORIGIN+9			; 6
       (pos('lda adr.', listing[i+7]) > 0) then							// lda adr.BOARD,y			; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and 							// lda 					; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+10			; 1
       (pos('lda ', listing[i+2]) > 0) and 							// lda					; 2
       add_sub(i+3) and	 									// add|sub				; 3
       (pos('ldy ', listing[i+4]) > 0) and							// ldy :STACKORIGIN+9			; 4
       (pos('sta ', listing[i+5]) > 0) and 							// sta					; 5
       (pos('lda :STACK', listing[i+6]) > 0) and 						// lda :STACKORIGIN+10			; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       (pos('sta ', listing[i+8]) > 0) then							// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
        (copy(listing[i+1], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda #', listing[i]) = 0)	and			// lda M				; 0
       (pos('add ', listing[i+1]) > 0) and							// add #$10				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (listing[i+3] = #9'lda #$00') and							// lda #$00				; 3
       (listing[i+4] = #9'adc #$00') and							// adc #$00				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (listing[i+6] = #9'lda #$00') and							// lda #$00				; 6
       (listing[i+7] = #9'adc #$00') and							// adc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (listing[i+9] = #9'lda #$00') and							// lda #$00				; 9
       (listing[i+10] = #9'adc #$00') and							// adc #$00				; 10
       (pos('sta :STACK', listing[i+11]) > 0) then						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
     begin
      listing[i+7]  := '';
      listing[i+10] := '';

      Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===			optymalizacja SUB.				  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and							// lda			; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda			; 1
       add_sub(i+2) then									// add|sub		; 2
      begin
	listing[i] := '';

	Result := false;
      end;


    if (l = 3) and (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and		// lda X 		; 0
       (listing[i+1] = #9'sub #$01') and							// sub #$01		; 1
       (pos('sta ', listing[i+2]) > 0) and (pos(',y', listing[i+2]) = 0) then			// sta Y		; 2
      if copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256) then
     begin

       if (pos('lda #', listing[i]) > 0) then begin
	p := GetVAL(copy(listing[i], 6, 256));

	listing[i]   := #9'lda #$' + IntToHex((p-1) and $ff, 2);
	listing[i+1] := '';
       end else begin
	listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
	listing[i+1] := #9'dey';
	listing[i+2] := #9'sty '+copy(listing[i+2], 6, 256);
       end;

	Result:=false;
     end;


    if (l = 3) and
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// lda W		; 0
       (listing[i+1] = #9'sub #$01') then							// sub #$01		; 1
       if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then				// sta W		; 2
       begin
	 listing[i]   := #9'dec '+copy(listing[i], 6, 256);
	 listing[i+1] := '';
	 listing[i+2] := '';

	 Result := false;
       end;


    if (pos('sta ', listing[i]) > 0) and							// sta :eax		; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda			; 1
       (listing[i+2] = #9'sub #$01') and							// sub #$01		; 2
       (pos('add ', listing[i+3]) > 0) and							// add :eax		; 3
       (listing[i+4] = #9'tay') then								// tay			; 4
      if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then
       begin
	listing[i] := '';

	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := #9'tay';
	listing[i+3] := #9'dey';

	listing[i+4] := '';

	Result := false;
       end;


    if (listing[i] = #9'sec') and								// sec			; 0
       (pos('lda ', listing[i+1]) > 0) and 							// lda			; 1
       (pos('sbc ', listing[i+2]) > 0) then							// sbc			; 2
       begin
	listing[i]   := '';
	listing[i+2] := #9'sub ' + copy(listing[i+2], 6, 256);

	Result := false; ;
       end;


    if (listing[i] = #9'sec') and								// sec			; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda			; 1
       (pos('sub ', listing[i+2]) > 0) then							// sub			; 2
     begin
	listing[i] := '';

	Result:=false; ;
     end;


    if (pos('lda ', listing[i]) > 0) and 							// lda			; 0
       (listing[i+1] = #9'sub #$00') and							// sub #$00		; 1
       (pos('sta ', listing[i+2]) > 0) and 							// sta			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda			; 3
       (pos('sbc ', listing[i+4]) > 0) then							// sbc			; 4
     begin
      listing[i+1] := '';
      listing[i+4] := #9'sub ' + copy(listing[i+4], 6, 256);

      Result:=false; ;
     end;



    if Result and
       (pos('lda ', listing[i]) > 0) and 							// lda			; 0
       (listing[i+1] = #9'sub #$00') and							// sub #$00		; 1
       (pos('sta ', listing[i+2]) > 0) and 							// sta			; 2
       (pos('lda ', listing[i+3]) = 0) and							// ~lda			; 3
       (pos('sbc ', listing[i+4]) = 0) then							// ~sbc			; 4
     begin
      listing[i+1] := '';

      Result:=false; ;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sub :STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('sta :STACK', listing[i+2]) > 0) and						// sub :STACKORIGIN+10			; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc :STACK', listing[i+4]) > 0) and		// sta :STACKORIGIN+9			; 2
       (pos('sta :STACK', listing[i+5]) > 0) and						// lda					; 3
       (pos('mwa ', listing[i+6]) > 0) and (pos(' :bp2', listing[i+6]) > 0) and			// sbc :STACKORIGIN+STACKWIDTH+10	; 4
       (pos('ldy ', listing[i+7]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda :STACK', listing[i+8]) > 0) and (listing[i+9] = #9'sta (:bp2),y') and		// mwa xxx bp2				; 6
       (listing[i+10] = #9'iny') and								// ldy					; 7
       (pos('lda :STACK', listing[i+11]) > 0) and (listing[i+12] = #9'sta (:bp2),y') then	// lda :STACKORIGIN+9			; 8
     if {(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and}				// sta (:bp2),y				; 9
	(copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and				// iny 					; 10
	{(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and}				// lda :STACKORIGIN+STACKWIDTH+9 	; 11
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then				// sta (:bp2),y				; 12
       begin

	btmp[0]  := listing[i+6];
	btmp[1]  := listing[i+7];
	btmp[2]  := listing[i];
	btmp[3]  := listing[i+1];
	btmp[4]  := listing[i+9];
	btmp[5]  := listing[i+10];
	btmp[6]  := listing[i+3];
	btmp[7]  := listing[i+4];
	btmp[8]  := listing[i+12];

	listing[i]   := btmp[0];
	listing[i+1] := btmp[1];
	listing[i+2] := btmp[2];
	listing[i+3] := btmp[3];
	listing[i+4] := btmp[4];
	listing[i+5] := btmp[5];
	listing[i+6] := btmp[6];
	listing[i+7] := btmp[7];
	listing[i+8] := btmp[8];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	Result:=false;
       end;


    if (listing[i] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+1]) > 0) and		// lda (:bp2),y			; 0
       (listing[i+2] = #9'iny') and								// sta :STACKORIGIN+9		; 1
       (listing[i+3] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+4]) > 0) and		// iny				; 2
       (pos('lda ', listing[i+5]) > 0) and (pos('sub :STACK', listing[i+6]) > 0) and		// lda (:bp2),y			; 3
       (pos('sta ', listing[i+7]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9; 4
       (pos('lda ', listing[i+8]) > 0) and (pos('sbc :STACK', listing[i+9]) > 0) and		// lda 				; 5
       (pos('sta ', listing[i+10]) > 0) then							// sub :STACKORIGIN+9		; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta				; 7
	(copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then				// lda 				; 8
												// sbc :STACKORIGIN+STACKWIDTH+9; 9
												// sta				; 10
	begin
	  listing[i]    := '';
	  listing[i+1]  := '';
	  listing[i+2]  := '';
	  listing[i+3]  := '';

	  listing[i+4] := listing[i+5];
	  listing[i+5] := #9'sub (:bp2),y';
	  listing[i+6] := #9'iny';

	  listing[i+9] := #9'sbc (:bp2),y';

	  Result:=false;
	end;


    if (listing[i] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+1]) > 0) and		// lda (:bp2),y			; 0
       (listing[i+2] = #9'iny') and								// sta :STACKORIGIN+9		; 1
       (listing[i+3] = #9'lda (:bp2),y') and (pos('sta :STACK', listing[i+4]) > 0) and		// iny				; 2
       (pos('lda :STACK', listing[i+5]) > 0) and (pos('sub ', listing[i+6]) > 0) and		// lda (:bp2),y			; 3
       (pos('sta ', listing[i+7]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9; 4
       (pos('lda :STACK', listing[i+8]) > 0) and (pos('sbc ', listing[i+9]) > 0) and		// lda :STACKORIGIN+9		; 5
       (pos('sta ', listing[i+10]) > 0) then							// sub				; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sta				; 7
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then				// lda :STACKORIGIN+STACKWIDTH+9; 8
	begin											// sbc				; 9
												// sta				; 10
	  listing[i+1] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';

	  listing[i+8] := listing[i];

	  Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta :STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('sub :STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('sbc :STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('sbc :STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('sbc :STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda :eax			; 0
	sta :STACKORIGIN+10		; 1
	lda :eax+1			; 2
	sta :STACKORIGIN+STACKWIDTH+10	; 3
	lda :eax+2			; 4
	sta :STACKORIGIN+STACKWIDTH*2+10; 5
	lda :eax+3			; 6
	sta :STACKORIGIN+STACKWIDTH*3+10; 7
	lda ERROR			; 8
	sub :STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	sbc :STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	sbc :STACKORIGIN+STACKWIDTH*2+10; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	sbc :STACKORIGIN+STACKWIDTH*3+10; 18
	sta ERROR+3			; 19
}
	listing[i+9]  := #9'sub ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'sbc ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'sbc ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'sbc ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sub ', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc ', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sbc ', listing[i+7]) > 0) and (pos('sta :STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('sbc ', listing[i+10]) > 0) and (pos('sta :STACK', listing[i+11]) > 0) and
       (pos('lda :STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda :STACK', listing[i+14]) > 0) and (pos('sta ', listing[i+15]) > 0) and
       (pos('lda :STACK', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda :STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda Y				; 0
	sub #$01			; 1
	sta :STACKORIGIN+11		; 2
	lda Y+1				; 3
	sbc #$00			; 4
	sta :STACKORIGIN+STACKWIDTH+11	; 5
	lda #$00			; 6
	sbc #$00			; 7
	sta :STACKORIGIN+STACKWIDTH*2+11; 8
	lda #$00			; 9
	sbc #$00			; 10
	sta :STACKORIGIN+STACKWIDTH*3+11; 11
	lda :STACKORIGIN+11		; 12
	sta :ecx			; 13
	lda :STACKORIGIN+STACKWIDTH+11	; 14
	sta :ecx+1			; 15
	lda :STACKORIGIN+STACKWIDTH*2+11; 16
	sta :ecx+2			; 17
	lda :STACKORIGIN+STACKWIDTH*3+11; 18
	sta :ecx+3			; 19
}
	listing[i+2]  := listing[i+13];
	listing[i+5]  := listing[i+15];
	listing[i+8]  := listing[i+17];
	listing[i+11] := listing[i+19];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9		; 1
       (pos('lda :STACK', listing[i+4]) > 0) and (pos('sub ', listing[i+5]) > 0) and		// lda				; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda :STACK', listing[i+7]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+9; 3
       (pos('sbc ', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then			// lda :STACKORIGIN+9		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// sub				; 5
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then begin			// sta				; 6
	listing[i+4] := listing[i];								// lda :STACKORIGIN+STACKWIDTH+9; 7
	listing[i+7] := listing[i+2];								// sbc				; 8
	listing[i]   := '';									// sta				; 9
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+9		; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sub :STACK', listing[i+5]) > 0) and		// lda				; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) > 0) and			// sta :STACKORIGIN+STACKWIDTH+9; 3
       (pos('sbc :STACK', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then		// lda				; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sub :STACKORIGIN+9		; 5
	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin			// sta				; 6
	listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);					// lda				; 7
	listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);					// sbc :STACKORIGIN+STACKWIDTH+9; 8
	listing[i]   := '';									// sta				; 9
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;


    if (pos('sty :STACK', listing[i]) > 0) and (pos('sub ', listing[i+1]) > 0) and		// sty :STACKORIGIN+10		; 0
       (pos('sta ', listing[i+2]) > 0) and (pos('lda :STACK', listing[i+3]) > 0) and		// sub				; 1
       (pos('sbc ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) then			// sta				; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// lda :STACKORIGIN+10		; 3
       begin											// sbc				; 4
												// sta				; 5
	listing[i]   := '';
	listing[i+3] := #9'tya';

	Result:=false;
       end;


    if (l = 6) and (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and	// lda W			; 0
       (pos('lda ', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// sub #$01..$ff		; 1
       (pos('sub #$', listing[i+1]) > 0) and (listing[i+4] = #9'sbc #$00') and			// sta W			; 2
       (pos('sub #$00', listing[i+1]) = 0) then							// lda W+1			; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// sbc #$00			; 4
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then				// sta W+1			; 5
     begin

	if copy(listing[i+1], 6, 256) = '#$01' then begin
	 listing[i]   := #9'dew '+copy(listing[i], 6, 256);
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	end else begin
	 listing[i+3] := #9'scs';
	 listing[i+4] := #9'dec '+copy(listing[i+5], 6, 256);
	 listing[i+5] := '';
	end;

	Result:=false;
     end;


    if (listing[i] = #9'sec') and								// sec			; 0
       (pos('lda #', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) and			// lda #$		; 1
       (pos('lda #', listing[i+4]) > 0) and (pos('sta ', listing[i+6]) > 0) and			// sbc #$		; 2
       (pos('sbc #', listing[i+2]) > 0) and (pos('sbc #', listing[i+5]) > 0) and		// sta 			; 3
       (pos('lda #', listing[i+7]) = 0) and (pos('sbc ', listing[i+8]) = 0) then		// lda #$		; 4
     begin											// sbc #$		; 5
												// sta 			; 6
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;
      err := GetVAL(copy(listing[i+2], 6, 256)) + GetVAL(copy(listing[i+5], 6, 256)) shl 8;

      p:=p - err;

      listing[i]   := '';
      listing[i+1] := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+2] := '';
      listing[i+4] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+5] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// lda #$		; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// sub #$		; 1
       (pos('sub #', listing[i+1]) > 0) and (pos('sbc #', listing[i+4]) > 0) and		// sta 			; 2
       (pos('lda #', listing[i+6]) = 0)  and (pos('sbc ', listing[i+7]) = 0) then		// lda #$		; 3
     begin											// sbc #$		; 4
												// sta 			; 5
      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8;
      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;

      p:=p - err;

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';
      listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+4] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sub #', listing[i+1]) > 0) and			// lda #$		; 0
       (pos('sta ', listing[i+2]) > 0) and							// sub #$		; 1
       (pos('lda #', listing[i+3]) = 0)  and (pos('sbc ', listing[i+4]) = 0) then		// sta 			; 2
     begin
      p := GetVAL(copy(listing[i], 6, 256));
      err := GetVAL(copy(listing[i+1], 6, 256));

      p:=p - err;

      listing[i] := '';

      listing[i+1] := #9'lda #$' + IntToHex(p and $ff, 2);

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// lda #$		; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and			// sub #$		; 1
       (pos('lda #', listing[i+6]) > 0) and (pos('sta ', listing[i+8]) > 0) and			// sta 			; 2
       (pos('sub #', listing[i+1]) > 0) and							// lda #$		; 3
       (pos('sbc #', listing[i+4]) > 0) and							// sbc #$		; 4
       (pos('sbc #', listing[i+7]) > 0) and							// sta 			; 5
       (pos('lda #', listing[i+9]) = 0) and (pos('sbc ', listing[i+10]) = 0) then		// lda #$		; 6
     begin											// sbc #$		; 7
												// sta 			; 8
      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16;
      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16;

      p:=p - err;

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';
      listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+4] := '';
      listing[i+6] := #9'lda #$' + IntToHex(byte(p shr 16), 2);
      listing[i+7] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda W				; 0
       (pos('sub #', listing[i+1]) > 0) and							// sub #$00				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda W+1				; 3
       (pos('sbc #', listing[i+4]) > 0) and							// sbc #$04				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda :STACK', listing[i+6]) > 0) and						// lda :STACKORIGIN+9			; 6
       (pos('sub #', listing[i+7]) > 0) and							// sub #$36				; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta W				; 8
       (pos('lda :STACK', listing[i+9]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 9
       (pos('sbc #', listing[i+10]) > 0) and							// sbc #$00				; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta W+1				; 11
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) and
	 (copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;
      err :=  GetVAL(copy(listing[i+7], 6, 256)) + GetVAL(copy(listing[i+10], 6, 256)) shl 8;

      p:=p+err;

      listing[i+1] := #9'sub #$' + IntToHex(p and $ff, 2);
      listing[i+4] := #9'sbc #$' + IntToHex(byte(p shr 8), 2);

      listing[i+2] := listing[i+8];
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and							// lda #				; 0
       (pos('sub #', listing[i+1]) > 0) and							// sub #				; 1
       (pos('sta ', listing[i+2]) > 0) and							// sta :STACKORIGIN+10			; 2
       (pos('lda #', listing[i+3]) > 0) and							// lda #				; 3
       (pos('sbc #', listing[i+4]) > 0) and							// sbc #$00				; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda #', listing[i+6]) > 0) and							// lda #				; 6
       (pos('sbc #', listing[i+7]) > 0) and							// sbc #$00				; 7
       (pos('sta ', listing[i+8]) > 0) and							// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       (pos('lda #', listing[i+9]) > 0) and							// lda #				; 9
       (pos('sbc #', listing[i+10]) > 0) and							// sbc #$00				; 10
       (pos('sta ', listing[i+11]) > 0) then							// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
      begin
	p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16 + GetVAL(copy(listing[i+9], 6, 256)) shl 24;
	err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;

	p:=p - err;

	listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
	listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
	listing[i+6] := #9'lda #$' + IntToHex(byte(p shr 16), 2);
	listing[i+9] := #9'lda #$' + IntToHex(byte(p shr 24), 2);

	listing[i+1] := '';
	listing[i+4] := '';
	listing[i+7] := '';
	listing[i+10] := '';

	Result:=false;
       end;


    if (pos('lda #', listing[i]) > 0) and							// lda #				; 0
       (pos('sub #', listing[i+1]) > 0) and							// sub #				; 1
       (pos('sta ', listing[i+2]) > 0) and							// sta :STACKORIGIN+10			; 2
       (pos('lda #', listing[i+3]) > 0) and							// lda #				; 3
       (pos('sbc #', listing[i+4]) > 0) and							// sbc #$00				; 4
       (pos('sta ', listing[i+5]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+10	; 5
       (pos('lda #', listing[i+6]) > 0) and							// lda #				; 6
       (pos('sbc #', listing[i+7]) > 0) and							// sbc #$00				; 7
       (pos('sta ', listing[i+8]) > 0) then							// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
      begin
	p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16;
	err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16;
	p:=p - err;

	listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
	listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
	listing[i+6] := #9'lda #$' + IntToHex(byte(p shr 16), 2);

	listing[i+1] := '';
	listing[i+4] := '';
	listing[i+7] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sub #', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc #', listing[i+4]) > 0) and (pos('sta :STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sbc #', listing[i+7]) > 0) and (pos('sta :STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('sbc #', listing[i+10]) > 0) and (pos('sta :STACK', listing[i+11]) > 0) and
       (pos('lda :STACK', listing[i+12]) > 0) and (pos('sub #', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) and
       (pos('lda :STACK', listing[i+15]) > 0) and (pos('sbc #', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda :STACK', listing[i+18]) > 0) and (pos('sbc #', listing[i+19]) > 0) and (pos('sta ', listing[i+20]) > 0) and
       (pos('lda :STACK', listing[i+21]) > 0) and (pos('sbc #', listing[i+22]) > 0) and (pos('sta ', listing[i+23]) > 0) then
      if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	 (copy(listing[i+8], 6, 256) = copy(listing[i+18], 6, 256)) and
	 (copy(listing[i+11], 6, 256) = copy(listing[i+21], 6, 256)) and
	 (copy(listing[i], 6, 256) = copy(listing[i+14], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+17], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+20], 6, 256)) and
	 (copy(listing[i+9], 6, 256) = copy(listing[i+23], 6, 256)) then
     begin
{
	lda W				; 0
	sub #$00			; 1
	sta :STACKORIGIN+9		; 2
	lda W+1				; 3
	sbc #$04			; 4
	sta :STACKORIGIN+STACKWIDTH+9	; 5
	lda W+2				; 6
	sbc #$00			; 7
	sta :STACKORIGIN+STACKWIDTH*2+9	; 8
	lda W+3				; 9
	sbc #$00			; 10
	sta :STACKORIGIN+STACKWIDTH*3+9	; 11
	lda :STACKORIGIN+9		; 12
	sub #$36			; 13
	sta W				; 14
	lda :STACKORIGIN+STACKWIDTH+9	; 15
	sbc #$00			; 16
	sta W+1				; 17
	lda :STACKORIGIN+STACKWIDTH*2+9	; 18
	sbc #$00			; 19
	sta W+2				; 20
	lda :STACKORIGIN+STACKWIDTH*3+9	; 21
	sbc #$00			; 22
	sta W+3				; 23
}
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;
      err :=  GetVAL(copy(listing[i+13], 6, 256)) + GetVAL(copy(listing[i+16], 6, 256)) shl 8 + GetVAL(copy(listing[i+19], 6, 256)) shl 16 + GetVAL(copy(listing[i+22], 6, 256)) shl 24;

      p:=p+err;

      listing[i+1] := #9'sub #$' + IntToHex(p and $ff, 2);
      listing[i+4] := #9'sbc #$' + IntToHex(byte(p shr 8), 2);
      listing[i+7] := #9'sbc #$' + IntToHex(byte(p shr 16), 2);
      listing[i+10] := #9'sbc #$' + IntToHex(byte(p shr 24), 2);

      listing[i+2] := listing[i+14];
      listing[i+5] := listing[i+17];
      listing[i+8] := listing[i+20];
      listing[i+11] := listing[i+23];

      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';
      listing[i+15] := '';
      listing[i+16] := '';
      listing[i+17] := '';
      listing[i+18] := '';
      listing[i+19] := '';
      listing[i+20] := '';
      listing[i+21] := '';
      listing[i+22] := '';
      listing[i+23] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and			// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and			// sta :eax			; 1
       (pos('lda ', listing[i+4]) > 0) and 							// lda				; 2
       (pos('sub ', listing[i+5]) > 0) and							// sta :eax+1			; 3
       (pos('sta ', listing[i+6]) > 0) and							// lda				; 4
       (pos('lda ', listing[i+7]) > 0) and							// sub :eax			; 5
       (pos('sbc ', listing[i+8]) > 0) and							// sta				; 6
       (pos('sta ', listing[i+9]) > 0) then							// lda				; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sbc :eax+1			; 8
	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then				// sta				; 9
     begin
	listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);
	listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;

{
    if (listing[i] = #9'lda :eax') and (pos('sta :STACK', listing[i+1]) > 0) and		// lda :eax			; 0
       (listing[i+2] = #9'lda :eax+1') and (pos('sta :STACK', listing[i+3]) > 0) and		// sta :STACKORIGIN+10		; 1
       (pos('lda :STACK', listing[i+4]) > 0) and (pos('sub :STACK', listing[i+5]) > 0) and	// lda :eax+1			; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda :STACK', listing[i+7]) > 0) and		// sta :STACKORIGIN+STACKWIDTH+10; 3
       (pos('sbc :STACK', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then		// lda :STACKORIGIN+9		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sub :STACKORIGIN+10		; 5
	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin			// sta				; 6
	listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);					// lda :STACKORIGIN+STACKWIDTH+9; 7
	listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);					// sbc :STACKORIGIN+STACKWIDTH+10; 8
	listing[i]   := '';									// sta				; 9
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;
}

    if (pos('lda :STACK', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and		// lda :STACKORIGIN+9		; 0
       (pos('lda :STACK', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and		// sta :eax			; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sub ', listing[i+5]) > 0) and			// lda :STACKORIGIN+STACKWIDTH+9; 2
       (pos('sta ', listing[i+6]) > 0) and							// sta :eax+1			; 3
       (pos('lda ', listing[i+7]) = 0) then							// lda				; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and				// sub :eax			; 5
	(pos(listing[i+1], listing[i+3]) > 0) then						// sta				; 6
      begin											// ~lda				; 7
	listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
      end;


    if (pos('lda :STACK', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and		// lda :STACKORIGIN+9	; 0
       (pos('lda ', listing[i+2]) > 0) and							// sta :eax		; 1
       (pos('sub ', listing[i+3]) > 0) and							// lda 			; 2
       (pos('sta ', listing[i+4]) > 0) then							// sub :eax		; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then				// sta			; 4
      begin
	listing[i+3] := #9'sub ' + copy(listing[i], 6, 256);
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
      end;


// -----------------------------------------------------------------------------
// ===		     optymalizacja STA #$00.				  === //
// -----------------------------------------------------------------------------

    if (i=0) and (listing[i] = #9'sta #$00') then begin						// jedno linijkowy sta #$00
       listing[i] := '';
       Result:=false;
     end;


    if (i>0) and (listing[i] = #9'sta #$00') then						// lda 			; -2
     if adc_sbc(i-1) then begin									// adc|sbc		; -1
												// sta #$00		; 0
       if adc_sbc(i-1) and (pos('lda ', listing[i-2]) > 0) then listing[i-2] := '';

       listing[i-1] := '';
       listing[i]   := '';
       Result:=false;
     end;


    if add_sub(i) and										// add|sub		; 0
       (listing[i+1] = #9'sta #$00') then							// sta #$00		; 1
     begin
	listing[i+1] := '';
	Result:=false;
     end;


    if (listing[i] = #9'sta #$00') and (i>0) then						// iny			; -2
     if (listing[i-1] = #9'lda (:bp2),y') then							// lda (:bp2),y		; -1
      begin											// sta #$00		; 0

	if  (listing[i-2] = #9'iny') then listing[i-2] := '';

	listing[i-1] := '';
	listing[i]   := '';
	Result:=false;
      end;


    if ( (pos('ora ', listing[i]) > 0) or							// ora|and|eor		; 0
	 (pos('and ', listing[i]) > 0) or 							// sta #$00		; 1
	 (pos('eor ', listing[i]) > 0) ) and (listing[i+1] = #9'sta #$00') then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('adc :STACK', listing[i]) > 0) and (listing[i+1] = #9'sta #$00') then		// adc STACK
     begin											// sta #$00
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos(' adr.', listing[i]) = 0) and			// lda
       (listing[i+1] = #9'sta #$00') then							// sta #$00
     begin
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda adr.', listing[i]) > 0) and (listing[i+1] = #9'sta #$00') and			// lda adr.		; 0
       ((pos('lda adr.', listing[i+2]) > 0) or (pos('mwa ', listing[i+2]) > 0)) then		// sta #$00		; 1
     begin											// lda adr.||mwa	; 2
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda adr.', listing[i]) > 0) and							// lda adr.		; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN	; 1
       (pos('lda adr.', listing[i+2]) > 0) and (listing[i+3] = #9'sta #$00') then		// lda adr.		; 2
     begin											// sta #$00		; 3
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and (listing[i+1] = #9'sta #$00') then			// sta
     begin											// sta #$00
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('scc', listing[i]) > 0) and (pos('inc #$00', listing[i+1]) > 0) then		// scc
     begin											// inc #$00
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('scs', listing[i]) > 0) and (pos('dec #$00', listing[i+1]) > 0) then		// scs
     begin											// dec #$00
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) then			// lda :STACKORIGIN+9
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin			// sta :STACKORIGIN+9

       if (pos('sta #$00', listing[i+1]) = 0) then listing[i] := '';

       listing[i+1] := '';
       Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and								// lda #$00		; 0
       ((listing[i+1] = #9'adc #$00') or (listing[i+1] = #9'sbc #$00')) and			// adc|sbc #$00		; 1
       (listing[i+2] = #9'sta #$00') then							// sta #$00		; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===		     optymalizacja LDA.			  	  	  === //
// -----------------------------------------------------------------------------

    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta :STACKORIGIN+10
       (pos('add :STACK', listing[i+2]) > 0) and						// lda
       ( (pos('sta ', listing[i+3]) > 0) or (listing[i+3] = #9'tay') ) then			// add :STACKORIGIN+10
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin			// sta | tay
	listing[i]   := '';
	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256) ;
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('ora :STACK', listing[i+2]) > 0) and	// sta :STACKORIGIN+10
       (pos('lda ', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) then			// lda B
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// ora :STACKORIGIN+10
	(copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// sta B
	listing[i]   := '';
	listing[i+2] := '';

	listing[i+1] := #9'ora '+copy(listing[i+1], 6, 256);
	Result:=false;
     end;


    if (pos('ldy ', listing[i-1]) = 0) and (pos(#9'tay ', listing[i-1]) = 0) and		// sta :STACKORIGIN+9	; 0
       (pos('sta ', listing[i]) > 0) and (pos('lda ', listing[i+2]) > 0) and 			// clc|sec		; 1
       ((listing[i+1] = #9'clc') or (listing[i+1] = #9'sec')) then				// lda :STACKORIGIN+9	; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin
	listing[i]   := '';
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('ldy ', listing[i-1]) = 0) and (pos(#9'tay ', listing[i-1]) = 0) and		// sta :STACKORIGIN+9	; 0
       (pos('sta ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and 			// lda :STACKORIGIN+9	; 1
       ((pos('add ', listing[i+2]) = 0) or (pos('sub ', listing[i+2]) = 0)) then		// add|sub		; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda
       ((pos('lda ', listing[i+2]) > 0) or (pos('ldy ', listing[i+2]) > 0) or			// adc|sbc STACK
       (pos('mwa ', listing[i+2]) > 0)) and							// lda | ldy | mwa
       adc_sbc_stack(i+1) then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
    end;


    if ((listing[i] = #9'sbc #$00') or (listing[i] = #9'adc #$00')) and				// sbc #$00 | adc #$00
       ((pos('lda ', listing[i+1]) > 0) or (pos('ldy ', listing[i+1]) > 0) or			// lda | ldy | mwa
       (pos('mwa ', listing[i+1]) > 0)) then
     begin
	listing[i]   := '';
	Result:=false;
    end;


    if (pos('ldy #$', listing[i]) > 0) and (pos('lda #$', listing[i+1]) > 0) and 		// ldy #$xx		; 0
       (pos('sta ', listing[i+2]) > 0) and (listing[i+3] = '') then				// lda #$xx		; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then				// sta			; 2
     begin
	listing[i+1] := #9'tya';
	Result:=false;
     end;


    if (listing[i] = #9'lda (:bp2),y') and (listing[i+1] = #9'iny') and				// lda (:bp2),y
       (listing[i+2] = #9'lda (:bp2),y') then begin						// iny
	listing[i] := '';									// lda (:bp2),y
	Result:=false;
    end;


    if (listing[i] = #9'iny') and (listing[i+1] = #9'lda (:bp2),y') and				// iny
       (listing[i+2] = #9'iny') then begin							// lda (:bp2),y
	listing[i]   := '';									// iny
	listing[i+1] := '';
	listing[i+2] := '';
	Result:=false;
    end;


    if (listing[i] = #9'lda (:bp2),y') and (pos('lda ', listing[i+1]) > 0) then			// iny			; -1
     begin											// lda (:bp2),y		; 0
     												// lda			; 1
      listing[i] := '';
      if (listing[i-1] = #9'iny') then listing[i-1] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and 			// lda			; 0
       (pos(',y', listing[i]) = 0) then								// lda			; 1
     begin
      listing[i] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('mwa ', listing[i+1]) > 0) then 			// lda			; 0
     begin											// mwa			; 1
      listing[i] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('ldy ', listing[i+1]) > 0) and			// lda			; 0
       (pos('mva ', listing[i+2]) > 0) then							// ldy			; 1
     begin											// mva			; 2
      listing[i] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('mva ', listing[i+1]) > 0) then 			// lda			; 0
     begin											// mva			; 1
      listing[i] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('mwa ', listing[i+2]) > 0) then 			// lda			; 0
     if (pos(#9'tay', listing[i+1]) = 0) and (pos('sta ', listing[i+1]) = 0) then		// ~sta|tay		; 1
     begin											// mwa			; 2
      listing[i]   := '';
      listing[i+1] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (listing[i+1] = #9'and #$00') and							// and #$00		; 1
       (pos('sta ', listing[i+2]) > 0) then							// sta 			; 2
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$00';
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACK		; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda			; 1
       (pos('and :STACK', listing[i+2]) > 0) then						// and :STACK		; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'and ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (listing[i+1] = #9'ora #$00') and							// ora #$00		; 1
       (pos('sta ', listing[i+2]) > 0) then							// sta 			; 2
     begin
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (listing[i+1] = #9'eor #$00') and							// eor #$00		; 1
       (pos('sta ', listing[i+2]) > 0) then							// sta 			; 2
     begin
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (pos('and #$FF', listing[i+1]) > 0) and							// and #$FF		; 1
       (pos('sta ', listing[i+2]) > 0) then							// sta 			; 2
     begin
	listing[i+1] := '';
	Result:=false;
     end;

    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (pos('ora #$FF', listing[i+1]) > 0) and							// ora #$FF		; 1
       (pos('sta ', listing[i+2]) > 0) then							// sta 			; 2
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$FF';
	Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and							// lda #		; 0
       (pos('eor #', listing[i+1]) > 0) and							// eor #		; 1
       (pos('sta ', listing[i+2]) > 0) then							// sta 			; 2
     begin

	p := GetVAL(copy(listing[i], 6, 256)) xor GetVAL(copy(listing[i+1], 6, 256));

	listing[i]   := #9'lda #$'+IntToHex(p, 2);;
	listing[i+1] := '';
	Result:=false;
     end;


{  !!! ta optymalizacja nie sprawdzila sie !!!

    if ((pos('lda ', listing[i]) > 0) or (pos('sbc ', listing[i]) > 0) or (pos('sub ', listing[i]) > 0) or (pos('adc ', listing[i]) > 0) or (pos('add ', listing[i]) > 0)) and	// lda|sub|sbc|add|adc
       ((pos('lda ', listing[i+1]) > 0) or (pos('mwa ', listing[i+1]) > 0) or (pos('mva ', listing[i+1]) > 0) ) then begin   							// lda|mva|mwa
	listing[i] := '';
	Result:=false;
       end;
}

    if Result and				// mamy pewnosc ze jest to pierwszy test sposrod wszystkich
       (pos('add ', listing[i+1]) = 0) and (pos('adc ', listing[i+1]) = 0) and		// clc		; 0
       (pos('add ', listing[i+2]) = 0) and (pos('adc ', listing[i+2]) = 0) then 	// <> add|adc	; 1
    if (listing[i] = #9'clc') then							// <> add|adc	; 2
    begin
	listing[i] := '';
	Result:=false;
    end;


    if (pos('sta :STACKORIGIN+STACKWIDTH', listing[i]) > 0) and				// sta :STACKORIGIN+STACKWIDTH	; 0
       (pos('lda :STACKORIGIN+STACKWIDTH*2', listing[i+1]) > 0) and			// lda :STACKORIGIN+STACKWIDTH*2; 1
       adc_sbc(i+2) and									// adc|sbc			; 2
       (pos('sta :STACKORIGIN+STACKWIDTH*2', listing[i+3]) > 0) and			// sta :STACKORIGIN+STACKWIDTH*2; 3
       (pos('lda :STACKORIGIN+STACKWIDTH*3', listing[i+4]) = 0) then			// ~lda :STACKORIGIN+STACKWIDTH*3; 4	skracamy do dwoch bajtow
     begin
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       Result:=false;
     end;


    if (i>0) and
       (pos('lda :STACKORIGIN+STACKWIDTH*3', listing[i]) > 0) and			// lda :STACKORIGIN+STACKWIDTH*3; 0	wczesniej musi wystapic zapis do ':STACKORIGIN+STACKWIDTH*3'
       adc_sbc(i+1) and									// adc|sbc			; 1
       (pos('sta :STACKORIGIN+STACKWIDTH*3', listing[i+2]) > 0) then			// sta :STACKORIGIN+STACKWIDTH*3; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin

       yes:=false;
       for p:=i-1 downto 0 do
	if copy(listing[p], 6, 256) = copy(listing[i+2], 6, 256) then begin yes:=true; Break end;

       if not yes then begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;

     end;


    if (listing[i] = #9'lsr #$00') and (listing[i+1] = #9'ror @')  then			// lsr #$00
     begin										// ror @
	listing[i]   := #9'lsr @';
	listing[i+1] := '';
	Result:=false;
     end;


    if (listing[i] = #9'lsr #$00') and (pos('ror :STACK', listing[i+1]) > 0) then	// lsr #$00
     begin										// ror :STACKORIGIN+STACKWIDTH*2+9
	listing[i]   := '';
	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);
	Result:=false;
     end;


    if (listing[i] = #9'bne @+') and (listing[i+1] = #9'bne @+') then begin		// bne @+
	listing[i]   := '';								// bne @+
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 						// lda #$00	; 0
       (listing[i+1] = #9'sta (:bp2),y') and 						// sta (:bp2),y	; 1
       (listing[i+2] = #9'iny') and							// iny		; 2 5 8
       (pos('lda ', listing[i+3]) > 0) and 						// lda #$00	; 3 6 9
       (listing[i+4] = #9'sta (:bp2),y') then						// sta (:bp2),y ; 4 7 10
      if listing[i] = listing[i+3] then begin

	listing[i+3] := '';

	if (listing[i+5] = #9'iny') and (pos('lda ', listing[i+6]) > 0) and (listing[i+7] = #9'sta (:bp2),y') then
	  if listing[i] = listing[i+6] then begin

	   listing[i+6] := '';

	   if (listing[i+8] = #9'iny') and (pos('lda ', listing[i+9]) > 0) and (listing[i+10] = #9'sta (:bp2),y') then
	     if listing[i] = listing[i+9] then listing[i+9] := '';

	  end;

	Result:=false;
      end;


    if (listing[i] = #9'lsr #$00') and (listing[i+1] = #9'ror #$00') and
       (pos('ror :STACK', listing[i+2]) > 0) and (pos('ror :STACK', listing[i+3]) > 0) then begin
	listing[i]   := '';								// lsr #$00
	listing[i+1] := '';								// ror #$00
	listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);				// ror :STACKORIGIN+STACKWIDTH+9
	listing[i+3] := #9'ror ' + copy(listing[i+3], 6, 256);				// ror :STACKORIGIN+9
	Result:=false;
     end;


    if (pos('sty :STACK', listing[i]) > 0) and 						// sty :STACKORIGIN+10
       (pos('lda :STACK', listing[i+1]) > 0) then					// lda :STACKORIGIN+10
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin
	listing[i]   := #9'tya';
	listing[i+1] := '';
	Result:=false;
     end;


    if (listing[i] = #9'tya') and (pos('sta ', listing[i+1]) > 0) and			// tya
       (pos(',y', listing[i+1]) = 0) and (pos('sta ', listing[i+2]) = 0) then		// sta xxx
     begin										// st?   ? <> a
	listing[i]   := #9'sty '+copy(listing[i+1], 6, 256);
	listing[i+1] := '';
	Result:=false;
     end;


    if (listing[i] = #9'tya') and							// tya
       (pos('lda ', listing[i+1]) > 0) and						// lda
       (pos('sta ', listing[i+2]) > 0) then						// sta
     begin
	listing[i] := '';
	Result:=false;
     end;


    if (pos('sty :STACK', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) and	// sty :STACKORIGIN+10	; 0
       (pos('lda :STACK', listing[i+2]) > 0) then					// sty			; 1
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin		// lda :STACKORIGIN+10	; 2
	old := listing[i];
	listing[i]   := listing[i+1];
	listing[i+1] := old;
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) and	// sta :STACKORIGIN+10	; 0
       (pos('sty ', listing[i+2]) > 0) and (pos('lda :STACK', listing[i+3]) > 0) then	// sty			; 1
     if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then begin		// sty			; 2
	listing[i]   := '';								// lda :STACKORIGIN+10	; 3
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) and	// sta :STACKORIGIN+10
       (pos('lda :STACK', listing[i+2]) > 0) then					// sty
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin		// lda :STACKORIGIN+10
	listing[i]   := '';
	listing[i+2] := '';
	Result:=false;
     end;


    if (listing[i] = #9'lda :eax') and (listing[i+1] = #9'tay') then			// lda :eax
     begin										// tay
	listing[i]   := #9'ldy :eax';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and (pos('ldy ', listing[i+1]) > 0) then		// sta :STACKORIGIN+10
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin		// ldy :STACKORIGIN+10
	listing[i]   := #9'tay';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and		// lda
       (listing[i+1] = #9'tay') and (pos(',y', listing[i+2]) > 0) then			// tay
     begin										// lda|sta xxx,y
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('ldy ', listing[i+1]) > 0) and		// lda
       ((pos('mwa ', listing[i+2]) > 0) or (pos('lda ', listing[i+2]) > 0)) then	// ldy
     begin										// mwa | lda
	listing[i] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda		; 0
       (listing[i+1] = #9'sub #$01') and						// sub #$01	; 1
       (listing[i+2] = #9'tay') and 							// tay		; 2
       (pos('sbc ', listing[i+4]) = 0) then						// lda		; 3
     begin										// ~sbc		; 4
	if (pos('lda #', listing[i]) > 0) then begin
	 p := GetVAL(copy(listing[i], 6, 256));

	 listing[i]   := #9'ldy #' + IntToHex((p-1) and $ff, 2);
	 listing[i+1] := '';
	 listing[i+2] := '';

	end else begin
	 listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
	 listing[i+1] := #9'dey';
	 listing[i+2] := '';
	end;

	Result:=false;
     end;


    if (listing[i] = #9'ldy #$00') and							// ldy #$00
       (listing[i+1] = #9'iny') then							// iny
     begin
	listing[i]   := #9'ldy #$01';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('ldy #', listing[i]) > 0) and (pos('lda #', listing[i+1]) > 0) and		// ldy #$ff
       (pos('sty ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) then		// lda #$ff
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then begin		// sty
	listing[i+1] := '';								// sta
	listing[i+3] := #9'sty '+copy(listing[i+3], 6, 256);
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and
       (pos('lda :STACK', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and	// sta :STACK+WIDTH+10	; 0
       (pos('lda :STACK', listing[i+3]) > 0) and (pos('sta ', listing[i+4]) > 0) and	// lda :STACK+10	; 1
       (pos('ldy ', listing[i+5]) > 0) and (pos('lda ', listing[i+6]) > 0) and		// sta :eax		; 2
       (pos('sta ', listing[i+7]) > 0) and (pos('lda ', listing[i+8]) > 0) and		// lda :STACK+WIDTH+10	; 3
       (pos('sta ', listing[i+9]) > 0) then						// sta :eax+1		; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and 			// ldy :eax		; 5
	(copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then			// lda			; 6
     begin										// sta ,y		; 7
     	//listing[i]   := '';								// lda 			; 8
	listing[i+2] := #9'tay';							// sta ,y		; 9
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

      	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta STACK+9		; 0
       (pos(',y', listing[i+1]) = 0) and (pos(',y', listing[i+3]) = 0) and			// lda 			; 1
       (pos('lda ', listing[i+1]) > 0) and (pos('sta :STACK', listing[i+2]) > 0) and		// sta STACK+10		; 2
       (pos('lda ', listing[i+3]) > 0) and (pos('sta :STACK', listing[i+4]) > 0) and		// lda 			; 3
       (pos('ldy :STACK', listing[i+5]) > 0) and (pos('lda :STACK', listing[i+6]) > 0) and	// sta STACK+WIDTH+10	; 4
       (pos('sta ', listing[i+7]) > 0) and (pos('lda :STACK', listing[i+8]) > 0) and		// ldy STACK+9		; 5
       (pos('sta ', listing[i+9]) > 0) then							// lda STACK+10		; 6
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and 				// sta			; 7
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda STACK+WIDTH+10	; 8
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then				// sta			; 9
     begin
	listing[i+6] := listing[i+1];
	listing[i+8] := listing[i+3];
	listing[i]   := #9'tay';

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

      	Result:=false;
     end;


{
    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda :STACK', listing[i+1]) > 0) and	// sta :STACKORIGIN+STACKWIDTH+11	// optymalizacje byte = byte * ? psuje
       (listing[i+2] = #9'sta :eax') and (pos('lda :STACK', listing[i+3]) > 0) and		// lda :STACKORIGIN+11
       (listing[i+4] = #9'sta :eax+1') then 							// sta :eax
    if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// lda :STACKORIGIN+STACKWIDTH+11
     begin											// sta :eax+1
      	listing[i] := listing[i+4];
	listing[i+3] := '';
	listing[i+4] := '';
	Result:=false;
     end;
}

    if (pos('mwa ', listing[i]) > 0) and (pos(' :bp2', listing[i]) > 0) and			// mva FIRST bp2		; 0
       (pos('mwa ', listing[i+7]) > 0) and (pos(' :bp2', listing[i+7]) > 0) and			// ldy #			; 1
       (listing[i+1] = listing[i+8]) and (listing[i+4] = listing[i+11]) and			// lda (:bp2),y			; 2
       (listing[i+2] = #9'lda (:bp2),y') and (listing[i+5] = #9'lda (:bp2),y') and		// sta :STACKORIGIN+9		; 3
       (listing[i+10] = #9'sta (:bp2),y') and (listing[i+13] = #9'sta (:bp2),y') and		// iny				; 4
       (pos('sta :STACK', listing[i+3]) > 0) and (pos('sta :STACK', listing[i+6]) > 0) and	// lda (:bp2),y			; 5
       (pos('lda :STACK', listing[i+9]) > 0) and (pos('lda :STACK', listing[i+12]) > 0) then	// sta :STACKORIGIN+STACKWIDTH+9; 6
     if (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and				// mwa LAST bp2			; 7
	(copy(listing[i+6], 6, 256) = copy(listing[i+12], 6, 256)) then begin			// ldy #			; 8
												// lda :STACKORIGIN+9		; 9
	delete(listing[i+7], pos(' :bp2', listing[i+7]), 256);					// sta (:bp2),y			; 10
												// iny				; 11
	listing[i+1] := listing[i+7] + ' ztmp';							// lda :STACKORIGIN+STACKWIDTH+9; 12
	listing[i+2] := listing[i+8];								// sta (:bp2),y			; 13
	listing[i+3] := #9'lda (:bp2),y';
	listing[i+4] := #9'sta (ztmp),y';
	listing[i+5] := #9'iny';
	listing[i+6] := #9'lda (:bp2),y';
	listing[i+7] := #9'sta (ztmp),y';

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===			optymalizacja :eax.			 	  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda :eax') and (pos('sta :STACKORIGIN', listing[i+1]) > 0) and		// lda :eax			; 0
       (listing[i+2] = #9'lda :eax+1') and							// sta :STACKORIGIN		; 1
       (pos('sta :STACKORIGIN+STACKWIDTH', listing[i+3]) > 0) and				// lda :eax+1			; 2
       (listing[i+4] = #9'lda :eax+2') and							// sta :STACKORIGIN+STACKWIDTH	; 3
       (pos('sta :STACKORIGIN+STACKWIDTH*2', listing[i+5]) > 0) and				// lda :eax+2			; 4
       (listing[i+6] = #9'lda :eax+3') and							// sta :STACKORIGIN+STACKWIDTH*2; 5
       (pos('sta :STACKORIGIN+STACKWIDTH*3', listing[i+7]) > 0) and				// lda :eax+3			; 6
       (pos('lda :STACKORIGIN', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3; 7
       (pos('sta ', listing[i+9]) > 0) and							// lda :STACKORIGIN		; 8
       (listing[i+10] = '') then								// sta				; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
     begin
      listing[i+8] := listing[i];
      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';

      Result:=false;
     end;


     if (pos('lda :STACK', listing[i]) > 0) and (listing[i+1] = #9'sta :eax') and		// lda STACK	; 0
       (pos('lda :STACK', listing[i+2]) > 0) and (listing[i+3] = #9'sta :eax+1') and		// sta :eax	; 1
       (listing[i+4] = #9'lda :eax') and (pos('sta :STACK', listing[i+5]) > 0) and		// lda STACK+	; 2
       (pos('lda :eax+1', listing[i+6]) = 0) then						// sta :eax+1	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and 				// lda :eax	; 4
	(copy(listing[i+3], 6, 256) <> copy(listing[i+6], 6, 256)) then				// sta STACK	; 5
     begin											// lda Y	; 6
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

      	Result:=false;
     end;


    if (pos('lda :STACK', listing[i]) > 0) and (listing[i+1] = #9'sta :eax+1') and		// lda STACK	; 0
       (listing[i+2] = #9'lda #$00') and (listing[i+3] = #9'sta :eax+2') and			// sta :eax+1	; 1
       (listing[i+4] = #9'sta :eax+3') then 							// lda #$00	; 2
     begin											// sta :eax+2	; 3
//     	listing[i+2] := '';									// sta :eax+3	; 4
	listing[i+3] := '';
	listing[i+4] := '';

      	Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and (pos('mva ', listing[i+1]) > 0) and			// sta :eax
       (pos(copy(listing[i], 6, 256), listing[i+1]) = 6) then					// mva :eax v
     begin
	tmp := copy(listing[i], 6, 256);
	delete( listing[i+1], pos(tmp, listing[i+1]), length(tmp) + 1 );
	listing[i]   := #9'sta ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';

	Result:=false;
     end;


    if (pos('lda :STACK', listing[i]) > 0) and (listing[i+1] = #9'sta :eax+1') and		// lda STACK		// byte = byte * ?
       (pos('mva :eax ', listing[i+2]) > 0) and (pos('mva :eax+1 ', listing[i+3]) = 0) then	// sta :eax+1
     begin											// mva :eax v
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
     end;


    if (pos('lda :STACK', listing[i]) > 0) and (listing[i+1] = #9'sta :eax') and		// word = byte * ?
       (pos('lda :STACK', listing[i+2]) > 0) and (listing[i+3] = #9'sta :eax+1') and
       (pos('mva :eax ', listing[i+4]) > 0) and (pos('mva :eax+1 ', listing[i+5]) > 0) then
     begin
{
	lda :STACKORIGIN+10		; 0
	sta :eax			; 1
	lda :STACKORIGIN+STACKWIDTH+10	; 2
	sta :eax+1			; 3
	mva :eax V			; 4
	mva :eax+1 V+1			; 5
}
	delete( listing[i+4], pos(':eax', listing[i+4]), 4);
	delete( listing[i+5], pos(':eax+1', listing[i+5]), 6);
	listing[i+1] := #9'mva ' + copy(listing[i], 6, 256) + copy(listing[i+4], 6, 256);
	listing[i]   := #9'mva ' + copy(listing[i+2], 6, 256) + copy(listing[i+5], 6, 256);

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false;
     end;


// y:=256; while word(y)>=100  -> nie zadziala dla n/w optymalizacji
//
//    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$00') and			// lda	   tylko dla <>0 lub =0
//       ((pos('beq ', listing[i+2]) > 0) or (pos('bne ', listing[i+2]) > 0)) then		// cmp #$00
//     begin											// beq | bne
//	listing[i+1] := '';
//     end;


  end;


{  if optimize.assign then} RemoveUnusedSTACK;
   end;


 begin


 Rebuild;

 Clear;

 // czy zmienna STACK... zostala zaincjowana poprzez zapis wartosci ( = numer linii)
  for i := 0 to l - 1 do begin
    a := listing[i];

    if pos(':STACK', a) > 0 then begin

      if (pos('sta :STACK', a) > 0) or (pos('sty :STACK', a) > 0) then		// z 'ldy ' CIRCLE wygeneruje bledny kod
       v:=i
      else
       v:=-1;

      for j := 0 to 6 do
       for k := 0 to 3 do
	if pos(GetARG(k, j, false), a) > 0 then
	 if cnt[j, k] = 0 then cnt[j, k] := v else
	  if (cnt[j, k] > 0) and (v>0) then cnt[j, k] := v;

    end;

  end;


 // podglad
//  for i := 0 to l - 1 do
//   if Num(i) <> 0 then listing[i] := listing[i] + #9'; '+IntToStr( Num(i) );


 // jesli CNT < 0 podstawiamy #$00

  emptyStart := 0;
  emptyEnd := -1;

  //optimize.assign := false;

 if optimize.assign then

  for i := 0 to l - 1 do begin
     a := listing[i];

     if (pos('rol @', listing[i-1])=0) and (pos('ror @', listing[i-1])=0) then

     if pos(':STACK', a) = 6 then begin
      v := Num(i);

      if v < 0 then begin
	k:=pos(arg, a);
	delete(a, k, length(arg));
	insert('#$00', a, k);

// zostawiamy 'illegal instruction' aby eliminowac je podczas optymalizacji

//       if (pos('sta #$00', a) > 0) or (pos('sty #$00', a) > 0) or (pos('rol #$00', a) > 0) or (pos('ror #$00', a) > 0) then
//	listing[i] := ''
//       else

	listing[i] := a;

      end;


      if pos('mva :STACK', a) > 0 then begin

       if v+1 > emptyStart then emptyStart := v + 1;


       if (pos('(:bp2),y', a) > 0) then begin	// indexed mode (:bp2),y

	if emptyEnd<0 then emptyEnd := i - 2;

       end else
       if (pos(' adr.', a) > 0) and (pos(',y', a) > 0) then begin	// indexed mode  adr.NAME,y

	if emptyEnd<0 then emptyEnd := i - 1;

	listing[v] := listing[i-1] + #13#10+copy(listing[v], 1, pos(arg, listing[v])-1) + copy(a, pos(arg, a) + length(arg) + 1, 256);   // na ostatniej znanej pozycji podmieniamy
	listing[i-1] := ';' + listing[i - 1];
	listing[i] := ';' + listing[i];

       end else begin

	if emptyEnd<0 then emptyEnd := i;

	listing[v] := copy(listing[v], 1, pos(arg, listing[v])-1) + copy(a, pos(arg, a) + length(arg) + 1, 256);   // na ostatniej znanej pozycji podmieniamy
	listing[i] := ';' + listing[i];

       end;

      end;

     end;//if pos(':STACK',

  end;//for //if


  for i := emptyStart to emptyEnd-1 do		// usuwamy wszystko co nie jest potrzebne
   listing[i] := ';' + listing[i];


  repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_STA;
  repeat until PeepholeOptimization_END;

  repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_STA;
  repeat until PeepholeOptimization_END;

  repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_STA;
  repeat until PeepholeOptimization_END;

  repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_STA;
  repeat until PeepholeOptimization_END;

 end;



 function OptimizeRelation: Boolean;
 var i, j: integer;
     a: string;
 begin
  // optymalizacja warunku

  Result := true;

  Rebuild;

  for i := 0 to l - 1 do
   if (listing[i] = #9'ldy #1') or (pos('cmp ', listing[i]) > 0) then begin optimize.assign := false; Break end;


  // usuwamy puste '@'
  for i := 0 to l - 1 do begin
   if (pos('@+', listing[i]) > 0) then Break;
   if listing[i] = '@' then listing[i] := '';
  end;

  Rebuild;


  if not optimize.assign then
   for i := 0 to l - 1 do
    if listing[i] <> '' then begin

    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'ldy #1') and		// lda		; 0
       (listing[i+2] = #9'and #$00') and (listing[i+3] = #9'bne @+') and		// ldy #1	; 1
       (pos('lda ', listing[i+4]) > 0) then						// and #$00	; 2
     begin										// bne @+	; 3
	listing[i] := '';								// lda		; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('and #$00', listing[i]) > 0) and (i>0) then					// lda #$00	; -1
     if pos('lda #$00', listing[i-1]) > 0 then begin					// and #$00	; 0
	listing[i] := '';
	Result:=false;
     end;


    if (listing[i] = #9'lda #$00') and							// lda #$00	; 0
       (pos('bne ', listing[i+1]) > 0) and						// bne		; 1
       (pos('lda ', listing[i+2]) > 0) then						// lda		; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda :STACK', listing[i+1]) > 0) and	// sta :STACKORIGIN+N1		; 0
       AND_ORA_EOR_STACK(i+2) and 								// lda :STACKORIGIN+N0		; 1
       (pos('sta :STACK', listing[i+3]) > 0) then						// ora|and|eor :STACKORIGIN+N1	; 2
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// sta :STACKORIGIN+N0		; 3
          (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false;
       end;


    if (pos('sty :STACK', listing[i]) > 0) and (pos('lda :STACK', listing[i+1]) > 0) and	// sty :STACKORIGIN+N1		; 0
       AND_ORA_EOR_STACK(i+2) and								// lda :STACKORIGIN+N0		; 1
       (pos('sta :STACK', listing[i+3]) > 0) then						// ora|and|eor :STACKORIGIN+N1	; 2
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// sta :STACKORIGIN+N0		; 3
          (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$80') and			// lda			; 0	>= 128
       (listing[i+2] = #9'bcs @+') and (listing[i+3] = #9'dey') then				// cmp #$80		; 1
     begin											// bcs @+		; 2
	listing[i+1] := #9'bmi @+';								// dey			; 3
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$7F') and			// lda			; 0	> 127
       (listing[i+2] = #9'seq') and (listing[i+3] = #9'bcs @+') and				// cmp #$7F		; 1
       (listing[i+4] = #9'dey') then								// seq			; 2
     begin											// bcs @+		; 3
	listing[i+1] := #9'bmi @+';								// dey			; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$7F') and			// lda			; 0	<= 127
       (listing[i+2] = #9'bcc @+') and (listing[i+3] = #9'beq @+') and				// cmp #$7F		; 1
       (listing[i+4] = #9'dey') then								// bcc @+		; 2
     begin											// beq @+		; 3
	listing[i+1] := #9'bpl @+';								// dey			; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$7F') and			// lda			; 0	<= 127	FOR
       (listing[i+2] = #9'bcc *+7') and (listing[i+3] = #9'beq *+5') then			// cmp #$7F		; 1
     begin											// bcc *+7		; 2
	listing[i+1] := #9'bpl *+5';								// beq *+5		; 3
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$00') and			// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (listing[i+3] = #9'dey') and								// cmp #$00		; 1	!!! to oznacza krotki test !!!
       ((pos('beq ', listing[i+2]) > 0) or (pos('bne ', listing[i+2]) > 0) or			// beq|bne|seq|sne	; 2
	(listing[i+2] = #9'seq') or (listing[i+2] = #9'sne')) then				// dey			; 3
     begin
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$00') and			// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (listing[i+2] = '@') and									// cmp #$00		; 1
       (listing[i+4] = #9'dey') and								// @			; 2	!!! to oznacza krotki test !!!
       ((pos('beq ', listing[i+3]) > 0) or (pos('bne ', listing[i+3]) > 0)) then		// beq|bne		; 3
     begin											// dey			; 4
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (listing[i+1] = #9'cmp #$00') and							// cmp #$00		; 1
       ((pos('beq ', listing[i+2]) > 0) or (pos('bne ', listing[i+2]) > 0)) and			// beq|bne		; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda			; 3
       (listing[i+4] = '@') and									// @			; 4
       ((pos('beq ', listing[i+5]) > 0) or (pos('bne ', listing[i+5]) > 0)) and			// beq|bne		; 5
       (listing[i+6] = #9'dey') then								// dey			; 6
     begin
	listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (listing[i+1] = #9'cmp #$00') and			// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (listing[i+2] = '@') and									// cmp #$00		; 1
       (listing[i+5] = #9'dey') and								// @			; 2	!!! to oznacza krotki test !!!
       (listing[i+3] = #9'seq') and								// seq			; 3
       ((pos('bpl ', listing[i+4]) > 0) or (pos('bcs ', listing[i+4]) > 0)) then		// bpl|bcs		; 4
     begin											// dey			; 5
	listing[i+1] := '';
	Result:=false;
     end;


     if (listing[i] = #9'lda #$00') and (listing[i+1] = #9'cmp #$00') and			// lda #$00		; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       	(pos('bne ', listing[i+2]) > 0) then							// cmp #$00		; 1
     begin											// bne 			; 2	!!! to oznacza krotki test !!!
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	Result:=false;
     end;


    if and_ora_eor(i) and 									// and|ora|eor #	; 0
       (pos(',y', listing[i]) = 0) and								// ldy #1		; 1
       (listing[i+1] = #9'ldy #1') and (listing[i+2] = #9'cmp #$00') and			// cmp #$00		; 2
       ((pos('beq ', listing[i+3]) > 0) or (pos('bne ', listing[i+3]) > 0) ) then		// beq|bne		; 3
     begin
	a := listing[i];
	listing[i]   := listing[i+1];
	listing[i+1] := a;
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('lda :STACK', listing[i+1]) > 0) then	// sta :STACKORIGIN+9	; 0
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin			// lda :STACKORIGIN+9	; 1
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false;
     end;


    if and_ora_eor(i) and									// and|ora|eor		; 0
       (pos('sta :STACK', listing[i+1]) > 0) and (listing[i+2] = #9'ldy #1') and		// sta :STACKORIGIN+N	; 1
       (pos('lda :STACK', listing[i+3]) > 0) and 						// ldy #1		; 2
       ((listing[i+4] = #9'bne @+') or (listing[i+4] = #9'beq @+')) then			// lda :STACKORIGIN+N	; 3
     if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then begin			// beq @+|bneQ+		; 4
       listing[i+1] := '';
       listing[i+3] := #9'cmp #$00';
       Result:=false;
      end;


    if (listing[i] = #9'ldy #1') and (pos('lda ', listing[i+1]) > 0) and 			// ldy #1		; 0
       (pos('sta :STACK', listing[i+2]) > 0) and (pos(',y', listing[i+1]) > 0) and		// lda ,y		; 1
       (pos('lda ', listing[i+3]) > 0) and (pos(',y', listing[i+3]) = 0) and			// sta :STACKORIGIN+N	; 2
       (pos('cmp :STACK', listing[i+4]) > 0) then			 			// lda 			; 3
     if copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256) then begin			// cmp :STACKORIGIN+N	; 4
       listing[i+4] := #9'cmp ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and (listing[i+1] = #9'ldy #1') and			// sta :STACKORIGIN+N	; 0
       (pos('lda :STACK', listing[i+2]) > 0) and						// ldy #1		; 1
       ((pos('cmp ', listing[i+3]) > 0) or (pos('and ', listing[i+3]) > 0) or			// lda :STACKORIGIN+N	; 2
	(pos('ora ', listing[i+3]) > 0) or (pos('eor ', listing[i+3]) > 0)) then		// cmp|and|ora|eor	; 3
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin
       listing[i]   := '';
       listing[i+2] := '';
       Result:=false;
      end;


    if (pos(',y', listing[i]) = 0) and (pos(',y', listing[i+2]) = 0) and		// lda :eax				; 0
       (pos(',y', listing[i+4]) = 0) and (pos(',y', listing[i+6]) = 0) and		// sta :STACKORIGIN+10			; 1
       (pos('lda ', listing[i]) > 0) and						// lda :eax+1				; 2
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('lda ', listing[i+2]) > 0) and						// lda :eax+2				; 4
       (pos('sta :STACK', listing[i+3]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       (pos('lda ', listing[i+4]) > 0) and						// lda :eax+3				; 6
       (pos('sta :STACK', listing[i+5]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       (pos('lda ', listing[i+6]) > 0) and						// ldy #1				; 8
       (pos('sta :STACK', listing[i+7]) > 0) and					// lda					; 9
       (listing[i+8] = #9'ldy #1') and							// cmp :STACKORIGIN+STACKWIDTH*3+10	; 10
       (pos('lda ', listing[i+9]) > 0) and (pos('cmp :STACK', listing[i+10]) > 0) and	// bne|beq				; 11
       (pos('lda ', listing[i+12]) > 0) and (pos('cmp :STACK', listing[i+13]) > 0) and	// lda					; 12
       (pos('lda ', listing[i+15]) > 0) and (pos('cmp :STACK', listing[i+16]) > 0) and	// cmp :STACKORIGIN+STACKWIDTH*2+10	; 13
       (pos('lda ', listing[i+18]) > 0) and (pos('cmp :STACK', listing[i+19]) > 0) then	// bne|beq				; 14
     if (copy(listing[i+1], 6, 256) = copy(listing[i+19], 6, 256)) and			// lda					; 15
	(copy(listing[i+3], 6, 256) = copy(listing[i+16], 6, 256)) and			// cmp :STACKORIGIN+STACKWIDTH+10	; 16
	(copy(listing[i+5], 6, 256) = copy(listing[i+13], 6, 256)) and			// bne|beq				; 17
	(copy(listing[i+7], 6, 256) = copy(listing[i+10], 6, 256)) then			// lda					; 18
     begin										// cmp :STACKORIGIN+10			; 19
	listing[i+10] := #9'cmp ' + copy(listing[i+6], 6, 256);
	listing[i+13] := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+16] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+19] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
     end;


    if (pos(',y', listing[i]) = 0) and (pos(',y', listing[i+2]) = 0) and		// lda :eax				; 0
       (pos(',y', listing[i+4]) = 0) and						// sta :STACKORIGIN+10			; 1
       (pos('lda ', listing[i]) > 0) and						// lda :eax+1				; 2
       (pos('sta :STACK', listing[i+1]) > 0) and					// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('lda ', listing[i+2]) > 0) and						// lda :eax+2				; 4
       (pos('sta :STACK', listing[i+3]) > 0) and					// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       (pos('lda ', listing[i+4]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 6
       (pos('sta :STACK', listing[i+5]) > 0) and					// ldy #1				; 7
       (pos('sta :STACK', listing[i+6]) > 0) and					// lda					; 8
       (listing[i+7] = #9'ldy #1') and							// cmp :STACKORIGIN+STACKWIDTH*3+10	; 9
       (pos('lda ', listing[i+8]) > 0) and (pos('cmp :STACK', listing[i+9]) > 0) and	// bne|beq				; 10
       (pos('lda ', listing[i+11]) > 0) and (pos('cmp :STACK', listing[i+12]) > 0) and	// lda					; 11
       (pos('lda ', listing[i+14]) > 0) and (pos('cmp :STACK', listing[i+15]) > 0) and	// cmp :STACKORIGIN+STACKWIDTH*2+10	; 12
       (pos('lda ', listing[i+17]) > 0) and (pos('cmp :STACK', listing[i+18]) > 0) then	// bne|beq				; 13
     if (copy(listing[i+1], 6, 256) = copy(listing[i+18], 6, 256)) and			// lda					; 14
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) and			// cmp :STACKORIGIN+STACKWIDTH+10	; 15
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and			// bne|beq				; 16
	(copy(listing[i+6], 6, 256) = copy(listing[i+9], 6, 256)) then			// lda					; 17
     begin										// cmp :STACKORIGIN+10			; 18
	listing[i+9]  := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+12] := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+15] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+18] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	Result:=false;
     end;


    if (pos(',y', listing[i]) = 0) and (pos(',y', listing[i+2]) = 0) and		// lda :eax				; 0
       (pos('lda ', listing[i]) > 0) and						// sta :STACKORIGIN+10			; 1
       (pos('sta :STACK', listing[i+1]) > 0) and					// lda :eax+1				; 2
       (pos('lda ', listing[i+2]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (pos('sta :STACK', listing[i+3]) > 0) and					// ldy #1				; 4
       (listing[i+4] = #9'ldy #1') and							// lda					; 5
       (pos('lda ', listing[i+5]) > 0) and (pos('cmp :STACK', listing[i+6]) > 0) and	// cmp :STACKORIGIN+STACKWIDTH+10	; 6
       (pos('lda ', listing[i+8]) > 0) and (pos('cmp :STACK', listing[i+9]) > 0) then	// bne|beq				; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and			// lda					; 8
	(copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then			// cmp :STACKORIGIN+10			; 9
     begin
	listing[i+6] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+9] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
     end;


    if (pos(',y', listing[i]) = 0) and
       (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// lda ~,y		; 0
       (listing[i+2] = #9'ldy #1') and								// sta :STACKORIGIN+N	; 1
       (pos('lda ', listing[i+3]) > 0) and							// ldy #1		; 2
       (pos('cmp :STACK', listing[i+4]) > 0) then						// lda 			; 3
     if copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256) then begin			// cmp :STACKORIGIN+N	; 4

       listing[i+4] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
      end;


    if (pos(',y', listing[i]) = 0) and								// lda ~,y		; 0
       (pos('lda ', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and		// sta :STACKORIGIN+N	; 1
       (pos('ldy ', listing[i+2]) > 0) and							// ldy			; 2
       (pos('lda ', listing[i+3]) > 0) and (pos(',y', listing[i+3]) > 0) and			// lda ,y		; 3
       (pos('sta :STACK', listing[i+4]) > 0) and						// sta STACK		; 4
       (listing[i+5] = #9'ldy #1') and								// ldy #1		; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda :STACKORIGIN+N	; 6
       (pos('cmp :STACK', listing[i+7]) > 0) then						// cmp STACK		; 7
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then begin

       listing[i+6] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and							// lda			; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+11	; 1
       (listing[i+2] = #9'ldy #1') and								// ldy #1		; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda 			; 3
       (pos('cmp :STACK', listing[i+4]) > 0) and						// cmp :STACKORIGIN+11	; 4
       (listing[i+5] = #9'beq @+') and								// beq @+		; 5
       (listing[i+6] = #9'dey') then								// dey			; 6
     if copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256) then begin

       listing[i+3] := #9'cmp ' + copy(listing[i+3], 6, 256);

       listing[i+1]   := '';
       listing[i+4] := '';
       Result:=false;
      end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+9	; 0
       (listing[i+1] = #9'ldy #1') and								// ldy #1		; 1
       (pos('lda :STACK', listing[i+2]) > 0) and						// lda :STACKORIGIN+9	; 2
       (listing[i+3] = #9'beq @+') and								// beq @+		; 3
       (listing[i+4] = #9'dey') then								// dey			; 4
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin

       listing[i] := '';
       listing[i+2] := #9'cmp #$00';

       Result:=false;
      end;


    if (pos('sty :STACK', listing[i]) > 0) and							// sty :STACKORIGIN+9	; 0
       (pos('.ifdef IFTMP_', listing[i+1]) > 0) and						// .ifdef IFTMP_29	; 1
       (pos('lda :STACK', listing[i+2]) > 0) and						// lda :STACKORIGIN+9	; 2
       (pos('sta IFTMP_', listing[i+3]) > 0) and						// sta IFTMP_29		; 3
       (listing[i+4] = #9'eif') and (pos('lda :STACK', listing[i+5]) > 0) then			// eif			; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// lda :STACKORIGIN+9	; 5
	(copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then				// bne *+5		; 6
     begin											// jmp l_030F		; 7
       listing[i]   := '';
       listing[i+2] := '';
       listing[i+3] := #9'sty '+copy(listing[i+3], 6, 256);
       listing[i+5] := #9'tya';
       Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and (pos('.ifdef IFTMP_', listing[i+1]) > 0) and	// sta :STACKORIGIN+9	; 0
       (pos('lda :STACK', listing[i+2]) > 0) and (pos('sta IFTMP_', listing[i+3]) > 0) and	// .ifdef iftmp_26	; 1
       (listing[i+4] = #9'eif') and (pos('lda :STACK', listing[i+5]) > 0) then			// lda :STACKORIGIN+9	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// sta iftmp_26		; 3
	(copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then				// eif			; 4
     begin											// lda :STACKORIGIN+9	; 5
       listing[i]   := '';
       listing[i+2] := '';
       listing[i+5] := '';
       Result:=false;
     end;


    if (pos('sty :STACK', listing[i]) > 0) and							// sty :STACKORIGIN+9	; 0
       (pos('lda :STACK', listing[i+1]) > 0) and						// lda :STACKORIGIN+9	; 1
       (pos('jmp l_', listing[i+3]) > 0) then							// bne *+5		; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then begin			// jmp l_0087		; 3

       listing[i]   := #9'tya';
       listing[i+1] := '';

       if (pos('ldy #1', listing[0]) > 0) and (listing[i-2] = #9'dey') then begin

	listing[i-2] := listing[i+3];

	listing[0] := '';
	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
       end;

       Result:=false;
     end;


    if (pos('cmp ', listing[i]) > 0) and							// cmp			; 0
       (listing[i+1] = #9'beq @+') and								// beq @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = '@') then								// @			; 3
     begin
       listing[i+1] := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false;
     end;


    if (pos('cmp ', listing[i]) > 0) and							// cmp			; 0
       (listing[i+1] = #9'bcc @+') and								// bcc @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = '@') then								// @			; 3
     begin
       listing[i+1] := #9'jcs ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false;
     end;


    if (listing[i] = #9'.ENDL') and								// .ENDL		; 0
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       (listing[i+2] = #9'beq @+') and								// beq @+		; 2
       (pos('jmp l_', listing[i+3]) > 0) and							// jmp l_		; 3
       (listing[i+4] = '@') then								//@			; 4
      begin
       listing[i+2] := #9'jne ' + copy(listing[i+3], 6, 256);
       listing[i+3] := '';

       Result:=false;
      end;

{ !@!@!@!
    if (listing[i] = #9'.ENDL') and								// .ENDL		; 0
       (listing[i+1] = #9'bmi *+7') and								// bmi *+7		; 1
       (listing[i+2] = #9'beq *+5') and								// beq *+5		; 2
       (pos('jmp l_', listing[i+3]) > 0) then							// jmp l_		; 3
      begin
       listing[i+1] := #9'smi';
       listing[i+2] := #9'jne ' + copy(listing[i+3], 6, 256);
       listing[i+3] := '';

       Result:=false;
      end;
}

    if (listing[i] = #9'.ENDL') and								// .ENDL		; 0
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = '@') then								//@			; 3
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false;
      end;


    if (listing[i] = #9'.ENDL') and								// .ENDL		; 0
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = '@') then								//@			; 3
      begin
       listing[i+1] := #9'jpl ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false;
      end;


    if (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       (listing[i+1] = #9'beq @+') and								// beq @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = '@') then								//@			; 3
      begin
       listing[i+1] := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';

       Result:=false;
      end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bne @+') and								// bne @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = '@') then								// @			; 2
     begin
       listing[i]   := #9'jeq ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcs @+') and								// bcs @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = '@') then								// @			; 2
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = '@') then								// @			; 2
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'beq @+') and								// beq @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = '@') then								// @			; 2
     begin
       listing[i]   := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bne *+5') and								// bne *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jeq ' + copy(listing[i+1], 6, 256);

       Result:=false;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'beq *+5') and								// beq *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jne ' + copy(listing[i+1], 6, 256);

       Result:=false;
     end;


    if (listing[i] = #9'seq') and								// seq			; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
      begin
       listing[i] := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       Result:=false;
      end;


    if (pos('lda :STACK', listing[i]) > 0) and (pos('sta :STACK', listing[i+1]) > 0) and	// lda :STACKORIGIN+10	; 0
       (pos('lda :STACK', listing[i+2]) > 0) then						// sta :STACKORIGIN+10	; 1
       if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and				// lda :STACKORIGIN+10	; 2
	  (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';
	Result:=false;
       end;


    if (listing[i] = #9'ldy #1') and								// ldy #1	; 0
       (listing[i+1] = #9'.LOCAL') and								// .LOCAL	; 1
       (listing[i+2] = #9'lda #$00') and							// lda #$00	; 2
       (listing[i+3] = #9'sub #$00') and							// sub #$00	; 3
       (listing[i+4] = #9'bne L4') then								// bne L4	; 4
      begin
	listing[i+2] := #9'clv:sec';
	listing[i+3] := '';
	listing[i+4] := '';
	Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and							// lda		; 0
       (listing[i+1] = #9'ldy #1') and								// ldy #1	; 1
       (listing[i+2] = #9'.LOCAL') and								// .LOCAL	; 2
       (pos('lda ', listing[i+3]) > 0) then							// lda		; 3
      begin
	listing[i] := '';
	Result:=false;
      end;


    if (pos('lda #', listing[i]) > 0) and							// lda #				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+10			; 1
       (pos('lda #', listing[i+2]) > 0) and							// lda #				; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 3
       (listing[i+4] = #9'ldy #1') and								// ldy #1				; 4
       (listing[i+5] = #9'.LOCAL') and								// .LOCAL				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda					; 6
       (pos('sub :STACK', listing[i+7]) > 0) and						// sub :STACKORIGIN+STACKWIDTH+10	; 7
       (listing[i+8] = #9'bne L4') and								// bne L4				; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda					; 9
       (pos('cmp :STACK', listing[i+10]) > 0) then						// cmp :STACKORIGIN+10			; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
       listing[i+7]  := #9'sub ' + copy(listing[i+2], 6, 256);
       listing[i+10] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and							// lda #				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+10			; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 2
       (listing[i+3] = #9'ldy #1') and								// ldy #1				; 3
       (listing[i+4] = #9'.LOCAL') and								// .LOCAL				; 4
       (pos('lda ', listing[i+5]) > 0) and							// lda					; 5
       (pos('sub :STACK', listing[i+6]) > 0) and						// sub :STACKORIGIN+STACKWIDTH+10	; 6
       (listing[i+7] = #9'bne L4') and								// bne L4				; 7
       (pos('lda ', listing[i+8]) > 0) and							// lda					; 8
       (pos('cmp :STACK', listing[i+9]) > 0) then						// cmp :STACKORIGIN+10			; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
       listing[i+6] := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+9] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda #				; 0
       (pos('sta :STACK', listing[i+1]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 3
       (listing[i+4] = #9'ldy #1') and								// ldy #1				; 4
       (listing[i+5] = #9'.LOCAL') and								// .LOCAL				; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*3+9	; 6
       (listing[i+7] = #9'clv:sec') and								// clv:sec				; 7
       (listing[i+8] = #9'bne L4') and								// bne L4				; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda :STACKORIGIN+STACKWIDTH*2+9	; 9
       (listing[i+10] = #9'bne L1') and								// bne L1				; 10
       (pos('lda ', listing[i+11]) > 0) then							// lda :STACKORIGIN+STACKWIDTH+9	; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
       listing[i+6]  := #9'clv:sec';
       listing[i+7]  := #9'lda ' + copy(listing[i], 6, 256);
       listing[i+9]  := #9'lda ' + copy(listing[i], 6, 256);
       listing[i+11] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+9	; 0
       (listing[i+1] = #9'ldy #1') and								// ldy #1				; 1
       (listing[i+2] = #9'.LOCAL') and								// .LOCAL				; 2
       (pos('lda :STACK', listing[i+3]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 3
       (pos('sub ', listing[i+4]) > 0) and							// sub					; 4
       (listing[i+5] = #9'bne L4') then								// bne L4				; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
       listing[i]   := '';
       listing[i+3] := '';

       Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda #', listing[i]) = 0)	and			// lda M				; 0
       (pos('add ', listing[i+1]) > 0) and							// add #$10				; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (listing[i+3] = #9'lda #$00') and							// lda #$00				; 3
       (listing[i+4] = #9'adc #$00') and							// adc #$00				; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (listing[i+6] = #9'lda #$00') and							// lda #$00				; 6
       (listing[i+7] = #9'adc #$00') and							// adc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (listing[i+9] = #9'lda #$00') and							// lda #$00				; 9
       (listing[i+10] = #9'adc #$00') and							// adc #$00				; 10
       (pos('sta :STACK', listing[i+11]) > 0) then						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
     begin
      listing[i+7]  := '';
      listing[i+10] := '';

      Result:=false;
     end;


    if (pos('sta :STACK', listing[i]) > 0) and							// sta :STACKORIGIN+STACKWIDTH+10	; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda 					; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+10	; 2
       (pos('sta :STACK', listing[i+3]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+10	; 3
       (listing[i+4] = #9'ldy #$00') and							// ldy #$00				; 4
       (pos('lda :STACK', listing[i+5]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+10	; 5
       (listing[i+6] = #9'spl') and (listing[i+7] = #9'dey') and				// spl					; 6
       (pos('sta :STACK', listing[i+8]) > 0) and						// dey					; 7
       (pos('sty :STACK', listing[i+9]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+10	; 8
       (pos('sty :STACK', listing[i+10]) > 0) then						// sty :STACKORIGIN+STACKWIDTH*2+10	; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and				// sty :STACKORIGIN+STACKWIDTH*3+10	; 10
	(copy(listing[i+5], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda 					; 0
       add_sub(i+1) and										// add 					; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda 					; 3
       adc_sbc(i+4) and										// adc 					; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (pos('lda ', listing[i+6]) > 0) and							// lda 					; 6
       adc_sbc(i+7) and										// adc 					; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (pos('lda ', listing[i+9]) > 0) and							// lda 					; 9
       adc_sbc(i+10) and									// adc 					; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (pos('ldy :STACK', listing[i+12]) > 0) and						// ldy :STACKORIGIN+9			; 12
       (pos('lda adr.', listing[i+13]) > 0) then						// lda adr.				; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) then				// sty :STACKORIGIN+STACKWIDTH*3+10	; 10
     begin
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda 					; 0
       (pos('sub ', listing[i+1]) > 0) and							// sub 					; 1
       (pos('sta :STACK', listing[i+2]) > 0) and						// sta :STACKORIGIN+9			; 2
       (listing[i+3] = #9'lda #$00') and							// lda #$00				; 3
       (pos('sbc ', listing[i+4]) > 0) and							// sbc					; 4
       (pos('sta :STACK', listing[i+5]) > 0) and						// sta :STACKORIGIN+STACKWIDTH+9	; 5
       (listing[i+6] = #9'lda #$00') and							// lda #$00				; 6
       (listing[i+7] = #9'sbc #$00') and							// sbc #$00				; 7
       (pos('sta :STACK', listing[i+8]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       (listing[i+9] = #9'lda #$00') and							// lda #$00				; 9
       (listing[i+10] = #9'sbc #$00') and							// sbc #$00				; 10
       (pos('sta :STACK', listing[i+11]) > 0) and						// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       (listing[i+12] = #9'ldy #1') and								// ldy #1				; 12
       (pos('lda :STACK', listing[i+13]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*3+9	; 13
       (listing[i+14] = #9'bne @+') and								// bne @+				; 14
       (pos('lda :STACK', listing[i+15]) > 0) and						// lda :STACKORIGIN+STACKWIDTH*2+9	; 15
       (listing[i+16] = #9'bne @+') and								// bne @+				; 16
       (pos('lda :STACK', listing[i+17]) > 0) and						// lda :STACKORIGIN+STACKWIDTH+9	; 17
       (listing[i+18] = #9'bne @+') and								// bne @+				; 18
       (pos('lda ', listing[i+19]) > 0) and							// lda					; 19
       (pos('cmp :STACK', listing[i+20]) > 0) then						// cmp :STACKORIGIN+9			; 20
     if (copy(listing[i+2], 6, 256) = copy(listing[i+20], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      listing[i+13] := '';
      listing[i+14] := '';
      listing[i+15] := '';
      listing[i+16] := '';

      Result:=false;
     end;


    if ((pos('sty :STACKORIGIN+9', listing[i]) > 0) or (pos('sta :STACKORIGIN+9', listing[i]) > 0)) and		// sty|sta :STACKORIGIN+9	; 0
       (pos('mva :STACKORIGIN+9', listing[i+1]) > 0) then begin							// mva :STACKORIGIN+9 STOP	; 1
	listing[i+1] := copy(listing[i], 1, 5) + copy(listing[i+1], pos(':STACK', listing[i+1]) + 15, 256);
	listing[i]   := '';
	Result:=false;
    end;

   end;   // for


   Rebuild;


   for i := 0 to l - 1 do begin

    if (listing[i] = #9'ldy #1') then begin
{
	ldy #$01
  	mwa ptr bp2
	lda (:bp2),y
	ldy #1
}
     for j := i-1 downto 0 do
       if (pos('mwy ', listing[j]) > 0) or (pos(#9'iny', listing[j]) > 0) or (pos(#9'dey', listing[j]) > 0) or ( (pos('ldy ', listing[j]) > 0) and (pos('ldy #$01', listing[j]) = 0) ) then Break else
	if (pos('ldy #$01', listing[j]) > 0) then begin

	 listing[j] := listing[i];
	 listing[i] := '';

	 Result:=false;

	 Break;

	end;

    end;

   end;   // for


   Rebuild;

 end;


 procedure index(k, x: integer);
 var m: integer;
 begin

	listing[l]   := #9'lda ' + GetARG(0, x);
	listing[l+1] := #9'sta ' + GetARG(0, x);
	listing[l+2] := #9'lda ' + GetARG(1, x);

	inc(l, 3);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'asl ' + GetARG(0, x);
	listing[l+1] := #9'rol @';

	inc(l, 2);
       end;

       listing[l]   := #9'sta ' + GetARG(1, x);
       listing[l+1] := #9'lda ' + GetARG(0, x);
       listing[l+2] := #9'sta ' + GetARG(0, x);
       listing[l+3] := #9'lda ' + GetARG(1, x);
       listing[l+4] := #9'sta ' + GetARG(1, x);

       inc(l, 5);
 end;


begin

 l:=0;
 x:=0;

 arg := '';
 arg0 := '';
 arg1 := '';

 inxUse := false;
 ifTmp  := false;

 for i := 0 to High(s) do
  for k := 0 to 3 do s[i][k] := '';

 for i := 0 to High(listing) do listing[i]:='';


 for i := 0 to High(OptimizeBuf) - 1 do begin
  a := OptimizeBuf[i].line;
//  c :=  OptimizeBuf[i].comment;

  if (a<>'') and (pos(';', a) = 0) then begin

   t:=a;

   if pos(#9'inx', a) > 0 then begin inc(x); inxUse:=true; t:='' end;
   if pos(#9'dex', a) > 0 then begin dec(x); t:='' end;


   if {(pos('.LOCAL', a) > 0) or (pos('.ENDL', a) > 0) or
      (pos('@exit', a) > 0) or (pos('@halt' , a) > 0) or    }
      (pos('@cmpFor_SMALLINT', a) > 0) or (pos('@cmpFor_INT', a) > 0) or (pos('@cmpFor_CARD', a) > 0) or
      (pos('@print', a) > 0) then begin x:=100; Break end;    // zakoncz optymalizacje niepowodzeniem

   if pos('.ifdef IFTMP_', a) > 0 then ifTmp := true;
   if pos('sta IFTMP_', a) > 0 then ifTmp := false;

{      if pos('@pushWORD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]   := #9'lda '+arg0;
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta :bp2';
       listing[l+3] := #9'lda '+arg0+'+1';
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta :bp2+1';
       listing[l+6] := #9'ldy #$00';
       listing[l+7] := #9'lda (:bp2),y';
       listing[l+8] := #9'sta '+GetARG(0, x);
       listing[l+9] := #9'iny';
       listing[l+10]:= #9'lda (:bp2),y';
       listing[l+11]:= #9'sta '+GetARG(1, x);

       inc(l, 12);
      end;


      if pos('@pushCARD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]   := #9'lda '+arg0;
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta :bp2';
       listing[l+3] := #9'lda '+arg0+'+1';
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta :bp2+1';
       listing[l+6] := #9'ldy #$00';
       listing[l+7] := #9'lda (:bp2),y';
       listing[l+8] := #9'sta '+GetARG(0, x);
       listing[l+9] := #9'iny';
       listing[l+10]:= #9'lda (:bp2),y';
       listing[l+11]:= #9'sta '+GetARG(1, x);
       listing[l+12]:= #9'iny';
       listing[l+13]:= #9'lda (:bp2),y';
       listing[l+14]:= #9'sta '+GetARG(2, x);
       listing[l+15]:= #9'iny';
       listing[l+16]:= #9'lda (:bp2),y';
       listing[l+17]:= #9'sta '+GetARG(3, x);

       inc(l, 18);
      end;


      if pos('@pullWORD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]    := #9'lda '+arg0;
       listing[l+1]  := #9'add '+GetARG(0, x-1);
       listing[l+2]  := #9'sta :bp2';
       listing[l+3]  := #9'lda '+arg0+'+1';
       listing[l+4]  := #9'adc '+GetARG(1, x-1);
       listing[l+5]  := #9'sta :bp2+1';
       listing[l+6]  := #9'ldy #$00';
       listing[l+7]  := #9'lda '+GetARG(0, x);
       listing[l+8]  := #9'sta (:bp2),y';
       listing[l+9]  := #9'iny';
       listing[l+10] := #9'lda '+GetARG(1, x);
       listing[l+11] := #9'sta (:bp2),y';

       inc(l, 12);
      end;


      if pos('@pullCARD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]    := #9'lda '+arg0;
       listing[l+1]  := #9'add '+GetARG(0, x-1);
       listing[l+2]  := #9'sta :bp2';
       listing[l+3]  := #9'lda '+arg0+'+1';
       listing[l+4]  := #9'adc '+GetARG(1, x-1);
       listing[l+5]  := #9'sta :bp2+1';
       listing[l+6]  := #9'ldy #$00';
       listing[l+7]  := #9'lda '+GetARG(0, x);
       listing[l+8]  := #9'sta (:bp2),y';
       listing[l+9]  := #9'iny';
       listing[l+10] := #9'lda '+GetARG(1, x);
       listing[l+11] := #9'sta (:bp2),y';
       listing[l+12] := #9'iny';
       listing[l+13] := #9'lda '+GetARG(2, x);
       listing[l+14] := #9'sta (:bp2),y';
       listing[l+15] := #9'iny';
       listing[l+16] := #9'lda '+GetARG(3, x);
       listing[l+17] := #9'sta (:bp2),y';

       inc(l, 18);
      end;
 }

     if (pos('jsr', a) > 0) or (pos('m@', a) > 0) then begin

      if (pos('jsr', a) > 0) then
       arg0 := copy(a, 6, 256)
      else
       arg0 := copy(a, 2, 256);


      if arg0='@expandSHORT2SMALL1' then begin
       t:='';

       listing[l]   := #9'ldy #$00';
       listing[l+1] := #9'lda '+GetARG(0, x-1);
       listing[l+2] := #9'spl';
       listing[l+3] := #9'dey';
       listing[l+4] := #9'sty '+GetARG(1, x-1);
       listing[l+5] := #9'sta '+GetARG(0, x-1);

       inc(l, 6);
      end else
      if arg0='@expandSHORT2SMALL' then begin
       t:='';

       listing[l]   := #9'ldy #$00';
       listing[l+1] := #9'lda '+GetARG(0, x);
       listing[l+2] := #9'spl';
       listing[l+3] := #9'dey';
       listing[l+4] := #9'sty '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(0, x);

       inc(l, 6);
      end else
      if arg0 = '@expandToCARD.SHORT' then begin
	t:='';

	if (s[x][1]='') and (s[x][2]='') and (s[x][3]='') then begin

	listing[l]   := #9'ldy #$00';
	listing[l+1] := #9'lda '+GetARG(0, x);
	listing[l+2] := #9'spl';
	listing[l+3] := #9'dey';
	listing[l+4] := #9'sta '+GetARG(0, x);
	listing[l+5] := #9'sty '+GetARG(1, x);
	listing[l+6] := #9'sty '+GetARG(2, x);
	listing[l+7] := #9'sty '+GetARG(3, x);

	inc(l, 8);
	end;

      end else
      if arg0 = '@expandToCARD1.SHORT' then begin
	t:='';

	if (s[x-1][1]='') and (s[x-1][2]='') and (s[x-1][3]='') then begin

	listing[l]   := #9'ldy #$00';
	listing[l+1] := #9'lda '+GetARG(0, x-1);
	listing[l+2] := #9'spl';
	listing[l+3] := #9'dey';
	listing[l+4] := #9'sta '+GetARG(0, x-1);
	listing[l+5] := #9'sty '+GetARG(1, x-1);
	listing[l+6] := #9'sty '+GetARG(2, x-1);
	listing[l+7] := #9'sty '+GetARG(3, x-1);

	inc(l, 8);
	end;

      end else
      if arg0 = '@expandToCARD.SMALL' then begin
	t:='';

	if (s[x][2]='') and (s[x][3]='') then begin

	listing[l]   := #9'lda '+GetARG(0, x);
	listing[l+1] := #9'sta '+GetARG(0, x);
	listing[l+2] := #9'ldy #$00';
	listing[l+3] := #9'lda '+GetARG(1, x);
	listing[l+4] := #9'spl';
	listing[l+5] := #9'dey';
	listing[l+6] := #9'sta '+GetARG(1, x);
	listing[l+7] := #9'sty '+GetARG(2, x);
	listing[l+8] := #9'sty '+GetARG(3, x);

	inc(l, 9);
	end;

      end else
      if arg0 = '@expandToCARD1.SMALL' then begin
	t:='';

	if (s[x-1][2]='') and (s[x-1][3]='') then begin

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'ldy #$00';
	listing[l+3] := #9'lda '+GetARG(1, x-1);
	listing[l+4] := #9'spl';
	listing[l+5] := #9'dey';
	listing[l+6] := #9'sta '+GetARG(1, x-1);
	listing[l+7] := #9'sty '+GetARG(2, x-1);
	listing[l+8] := #9'sty '+GetARG(3, x-1);

	inc(l, 9);
	end;

      end else
      if arg0 = 'm@index4 1' then begin
       t:='';
       index(2, x-1);
      end else
      if arg0 = 'm@index4 0' then begin
       t:='';
       index(2, x);
      end else
      if arg0 = 'm@index2 1' then begin
       t:='';
       index(1, x-1);
      end else
      if arg0 = 'm@index2 0' then begin
       t:='';
       index(1, x);
      end else
      if arg0 = 'cmpINT' then begin
       t:='';

       listing[l] := #9'.LOCAL';

       listing[l+1] := #9'lda '+GetARG(3, x-1);

       arg1 := GetARG(3, x);

       if arg1 <> '#$00' then
	listing[l+2] := #9'sub '+arg1		// SBC ustawi znacznik V
       else
	listing[l+2] := #9'clv:sec';		// kasujemy znacznik V (lda sub #$00 -> V = 0)
						// jesli tego nie zrobimy znacznik V bedzie mial stan z wczesniejszych operacji
       listing[l+3] := #9'bne L4';
       listing[l+4] := #9'lda '+GetARG(2, x-1);

       arg1 := GetARG(2, x);

       if arg1 <> '#$00' then
	listing[l+5] := #9'cmp '+arg1
       else
	listing[l+5] := '';

       listing[l+6] := #9'bne L1';
       listing[l+7] := #9'lda '+GetARG(1, x-1);

       arg1 := GetARG(1, x);

       if arg1 <> '#$00' then
	listing[l+8] := #9'cmp '+arg1
       else
	listing[l+8] := '';

       listing[l+9] := #9'bne L1';
       listing[l+10]:= #9'lda '+GetARG(0, x-1);

       arg1 := GetARG(0, x);

       if arg1 <> '#$00' then
	listing[l+11]:= #9'cmp '+arg1
       else
	listing[l+11]:= '';

       listing[l+12]:= 'L1'#9'beq L2';
       listing[l+13]:= #9'bcs L3';
       listing[l+14]:= #9'lda #$FF';
       listing[l+15]:= 'L2'#9'jmp L5';
       listing[l+16]:= 'L3'#9'lda #$01';
       listing[l+17]:= #9'jmp L5';
       listing[l+18]:= 'L4'#9'bvc L5';
       listing[l+19]:= #9'eor #$FF';
       listing[l+20]:= #9'ora #$01';
       listing[l+21]:= 'L5';
       listing[l+22]:= #9'.ENDL';

       inc(l, 23);

      end else
      if arg0 = 'cmpSMALLINT' then begin
       t:='';

       listing[l]   := #9'.LOCAL';
       listing[l+1] := #9'lda '+GetARG(1, x-1);		// lda label     -> zastepujemy sub #$00 przez SEC !!!
							// sub #$00
       arg1 := GetARG(1, x);

       if arg1 <> '#$00' then
	listing[l+2] := #9'sub '+arg1
       else
	listing[l+2] := #9'clv:sec';

       listing[l+3] := #9'bne L4';
       listing[l+4] := #9'lda '+GetARG(0, x-1);

       arg1 := GetARG(0, x);

       if arg1 <> '#$00' then
	listing[l+5] := #9'cmp '+arg1
       else
	listing[l+5] := '';

       listing[l+6] := 'L1'#9'beq L5';
       listing[l+7] := #9'bcs L3';
       listing[l+8] := #9'lda #$FF';
       listing[l+9] := #9'jmp L5';
       listing[l+10]:= 'L3'#9'lda #$01';
       listing[l+11]:= #9'jmp L5';
       listing[l+12]:= 'L4'#9'bvc L5';
       listing[l+13]:= #9'eor #$FF';
       listing[l+14]:= #9'ora #$01';
       listing[l+15]:= 'L5';
       listing[l+16]:= #9'.ENDL';

       inc(l, 17);

      end else
      if arg0 = 'cmpSHORTINT' then begin
       t:='';

       listing[l]   := #9'.LOCAL';
       listing[l+1] := #9'lda '+GetARG(0, x-1);

       arg1 := GetARG(0, x);

       if arg1 <> '#$00' then
	listing[l+2] := #9'sub '+arg1
       else
	listing[l+2] := #9'clv:sec';

       listing[l+3] := #9'bne L4';

       listing[l+4] := 'L1'#9'beq L2';
       listing[l+5] := #9'bcs L3';
       listing[l+6] := #9'lda #$FF';
       listing[l+7] := 'L2'#9'jmp L5';
       listing[l+8] := 'L3'#9'lda #$01';
       listing[l+9] := #9'jmp L5';
       listing[l+10]:= 'L4'#9'bvc L5';
       listing[l+11]:= #9'eor #$FF';
       listing[l+12]:= #9'ora #$01';
       listing[l+13]:= 'L5';
       listing[l+14]:= #9'.ENDL';

       inc(l, 15);

      end else
      if arg0 = 'negBYTE' then begin
       t:='';

       listing[l]   := #9'lda #$00';
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x);

       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x);
       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x);
       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x);

       inc(l, 3+9);
      end else
      if arg0 = 'negWORD' then begin
       t:='';

       listing[l]   := #9'lda #$00';
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x);
       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x);

       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x);
       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x);

       inc(l, 6+6);
      end else
      if arg0 = 'notBOOLEAN' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x);
       listing[l+1] := #9'bne @+';
       listing[l+2] := #9'lda #true';
       listing[l+3] := #9'sne';
       listing[l+4] := '@'#9'lda #false';
       listing[l+5] := #9'sta '+GetARG(0, x);

       inc(l, 6);
      end else
      if arg0 = 'negCARD' then begin
       t:='';

       listing[l]   := #9'lda #$00';
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x);
       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x);
       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x);
       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc '+GetARG(3, x);
       listing[l+11] := #9'sta '+GetARG(3, x);

       inc(l, 12);
      end else
      if arg0 = 'hiBYTE' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x);
       listing[l+1] := #9':4 lsr @';
       listing[l+2] := #9'sta '+GetARG(0, x);

       inc(l, 3);
      end else
      if arg0 = 'hiWORD' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(1, x);
       s[x][0] := '';
       listing[l+1] := #9'sta '+GetARG(0, x);

       inc(l, 2);
      end else
      if arg0 = 'hiCARD' then begin
       t:='';

       s[x][0] := '';
       s[x][1] := '';

       listing[l]   := #9'lda '+GetARG(3, x);
       listing[l+1] := #9'sta '+GetARG(1, x);

       listing[l+2] := #9'lda '+GetARG(2, x);
       listing[l+3] := #9'sta '+GetARG(0, x);

       inc(l, 4);
      end else

      if arg0 = 'movZTMP_aBX' then begin
	t:='';

	s[x-1, 0] := '';
	s[x-1, 1] := '';
	s[x-1, 2] := '';
	s[x-1, 3] := '';

	listing[l]   := #9'lda ztmp8';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda ztmp9';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda ztmp10';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda ztmp11';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

      end else

      if arg0 = 'movaBX_EAX' then begin
	t:='';

	s[x-1, 0] := '';
	s[x-1, 1] := '';
	s[x-1, 2] := '';
	s[x-1, 3] := '';

	listing[l]   := #9'lda :eax';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda :eax+1';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda :eax+2';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda :eax+3';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

      end else

      if (arg0 = 'imodBYTE') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(0, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) then begin

	  k:=GetVal(t1) mod GetVal(t0);

	  listing[l]    := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1]  := #9'sta ztmp8';

	  s[x-1, 1] := #9'lda #$00';
	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 2);
	end else begin
	  listing[l]   := #9'lda ' + t1;
	  listing[l+1] := #9'sta al';
	  listing[l+2] := #9'lda ' + t0;
	  listing[l+3] := #9'sta cl';
	  listing[l+4] := #9'jsr idivAL_CL';

	  inc(l, 5);
	end;

      end else

      if (arg0 = 'idivBYTE') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(0, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) then begin

	  k:=GetVal(t1) div GetVal(t0);

	  listing[l]   := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :eax';

	  s[x-1, 1] := #9'lda #$00';
	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 2);
	end else begin
	  listing[l]   := #9'lda ' + t1;
	  listing[l+1] := #9'sta al';
	  listing[l+2] := #9'lda ' + t0;
	  listing[l+3] := #9'sta cl';
	  listing[l+4] := #9'jsr idivAL_CL';

	  inc(l, 5);
	end;

      end else

      if (arg0 = 'imodWORD') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(1, x);

	t2 := GetArg(0, x-1);
	t3 := GetArg(1, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) and (pos('#$', t2) > 0) and (pos('#$', t3) > 0) then begin

	  k:=(GetVal(t2) + GetVal(t3) shl 8) mod (GetVal(t0) + GetVal(t1) shl 8);

	  listing[l]    := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1]  := #9'sta ztmp8';
	  listing[l+2]  := #9'lda #$'+IntToHex(byte(k shr 8), 2);
	  listing[l+3]  := #9'sta ztmp9';

	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 4);
	end else begin
	  listing[l]   := #9'lda ' + t2;
	  listing[l+1] := #9'sta ax';
	  listing[l+2] := #9'lda ' + t3;
	  listing[l+3] := #9'sta ax+1';
	  listing[l+4] := #9'lda ' + t0;
	  listing[l+5] := #9'sta cx';
	  listing[l+6] := #9'lda ' + t1;
	  listing[l+7] := #9'sta cx+1';
	  listing[l+8] := #9'jsr idivAX_CX';

	  inc(l, 9);
	end;

      end else

      if (arg0 = 'idivWORD') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(1, x);

	t2 := GetArg(0, x-1);
	t3 := GetArg(1, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) and (pos('#$', t2) > 0) and (pos('#$', t3) > 0) then begin

	  k:=(GetVal(t2) + GetVal(t3) shl 8) div (GetVal(t0) + GetVal(t1) shl 8);

	  listing[l]   := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda #$'+IntToHex(byte(k shr 8), 2);
	  listing[l+3] := #9'sta :eax+1';

	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 4);
	end else begin
	  listing[l]   := #9'lda ' + t2;
	  listing[l+1] := #9'sta ax';
	  listing[l+2] := #9'lda ' + t3;
	  listing[l+3] := #9'sta ax+1';
	  listing[l+4] := #9'lda ' + t0;
	  listing[l+5] := #9'sta cx';
	  listing[l+6] := #9'lda ' + t1;
	  listing[l+7] := #9'sta cx+1';
	  listing[l+8] := #9'jsr idivAX_CX';

	  inc(l, 9);
	end;

      end else

      if (arg0 = 'imulBYTE') or (arg0 = 'mulSHORTINT') then begin
	t:='';

	m:=l;

	listing[l]    := #9'lda '+GetARG(0, x);
	listing[l+1]  := #9'sta :ecx';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+2] := #9'sta ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(0, x-1);
	listing[l+3]  := #9'sta :eax';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+4] := #9'sta ztmp10';
	 inc(l);
	end;

	listing[l+4] := #9'.ifdef fmulinit';
	listing[l+5] := #9'fmulu_8';
	listing[l+6] := #9'els';
	listing[l+7] := #9'imulCL';
	listing[l+8] := #9'eif';

	k := GetVAL(copy(listing[l], 6, 256));

	if (l>0) and (arg0 = 'imulBYTE') and (k in [0,1,2,4,8,16,32]) and (pos('#$', listing[l+2]) = 0) then begin

	s[x][0] := #9'lda ' + copy(listing[l+2], 6, 256);
	s[x][1] := #9'lda #$00';
	s[x][2] := #9'lda #$00';
	s[x][3] := #9'lda #$00';

	 case k of
	   2: index(1, x);
	   4: index(2, x);
	   8: index(3, x);
	  16: index(4, x);
	  32: index(5, x);
	 end;


	 if k in [0,1] then begin

	  if k=0 then
	   listing[l] := #9'lda #$00'
	  else
	   listing[l] := #9'lda ' + GetARG(0, x);

	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda #$00';
	  listing[l+3] := #9'sta :eax+1';

	  inc(l, 4);

	 end else begin

	  listing[l]   := #9'lda ' + GetARG(0, x);
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + GetARG(1, x);
	  listing[l+3] := #9'sta :eax+1';
	  listing[l+4] := #9'lda ' + GetARG(2, x);
	  listing[l+5] := #9'sta :eax+2';
	  listing[l+6] := #9'lda ' + GetARG(3, x);
	  listing[l+7] := #9'sta :eax+3';

	  inc(l, 8);

	 end;

	end else
	 inc(l, 9);

	if arg0 = 'mulSHORTINT' then begin

	listing[l]   := #9'lda ztmp10';
	listing[l+1] := #9'bpl @+';
	listing[l+2] := #9'sec';
	listing[l+3] := #9'lda :eax+1';
	listing[l+4] := #9'sbc ztmp8';
  	listing[l+5] := #9'sta :eax+1';

	listing[l+6] := '@';

	listing[l+7]  := #9'lda ztmp8';
	listing[l+8]  := #9'bpl @+';
	listing[l+9]  := #9'sec';
	listing[l+10] := #9'lda :eax+1';
	listing[l+11] := #9'sbc ztmp10';
	listing[l+12] := #9'sta :eax+1';

	listing[l+13] := '@';

	listing[l+14] := #9'lda :eax';
	listing[l+15] := #9'sta '+GetARG(0, x-1);
	listing[l+16] := #9'lda :eax+1';
	listing[l+17] := #9'sta '+GetARG(1, x-1);
	listing[l+18] := #9'lda #$00';
	listing[l+19] := #9'sta '+GetARG(2, x-1);
	listing[l+20] := #9'lda #$00';
	listing[l+21] := #9'sta '+GetARG(3, x-1);

	inc(l, 22);
	end;


    if (l=9) and			// !!! tylko pierwsza poczatkowa czesc
					// !!! dla 'lda :STACK' zle optymalizuje
       (pos('lda ', listing[m]) > 0) and (pos('lda :STACK', listing[m]) = 0) and	// lda					; 0
       ( ((listing[m+1] = #9'sta :ecx') and (listing[m+3] = #9'sta :eax')) or		// sta :ecx|:eax			; 1
         ((listing[m+1] = #9'sta :eax') and (listing[m+3] = #9'sta :ecx')) ) and
       ((listing[m+2] = #9'lda #$00') or (listing[m+2] = #9'lda #$01') or
        (listing[m+2] = #9'lda #$02') or (listing[m+2] = #9'lda #$04') or
        (listing[m+2] = #9'lda #$08') or (listing[m+2] = #9'lda #$10') or
	(listing[m+2] = #9'lda #$20') or (listing[m+2] = #9'lda #$40') or
	(listing[m+2] = #9'lda #$80')) and						// lda #$00;01;02;04;08;10;20;40;80	; 2
       (listing[m+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 4
       (listing[m+5] = #9'fmulu_8') and							// fmulu_8				; 5
       (listing[m+6] = #9'els') and 							// els					; 6
       (listing[m+7] = #9'imulCL') and		 					// imulCL				; 7
       (listing[m+8] = #9'eif') then 							// eif					; 8
     begin
      k:=GetVal(copy(listing[m+2], 6, 256));

      if k in [0,1] then begin

	if k=0 then listing[m] := #9'lda #$00';

	listing[m+1] := #9'sta :eax';
	listing[m+2] := #9'lda #$00';
	listing[m+3] := #9'sta :eax+1';

	l:=m+4;

      end else begin

	case k of
	 $02: k:=1;
	 $04: k:=2;
	 $08: k:=3;
	 $10: k:=4;
	 $20: k:=5;
	 $40: k:=6;
	 $80: k:=7;
	end;

	listing[m+2] := listing[m];

	listing[m]   := #9'lda #$00';
	listing[m+1] := #9'sta :eax+1';

	l:=m+3;

	while k>0 do begin
	 listing[l]   := #9'asl @';
	 listing[l+1] := #9'rol :eax+1';

	 inc(l, 2);
	 dec(k);
	end;

	listing[l] := #9'sta :eax';

	inc(l);
     end;    // if k in [0,1]

     end;


    if (l=9) and
       ((listing[m] = #9'lda #$00') or (listing[m] = #9'lda #$01') or
        (listing[m] = #9'lda #$02') or (listing[m] = #9'lda #$04') or
        (listing[m] = #9'lda #$08') or (listing[m] = #9'lda #$10') or
	(listing[m] = #9'lda #$20') or (listing[m] = #9'lda #$40') or			// lda #$00;01;02;04;08;10;20;40;80	; 0
	(listing[m] = #9'lda #$80')) and
       ( ((listing[m+1] = #9'sta :ecx') and (listing[m+3] = #9'sta :eax')) or		// sta :ecx|:eax			; 1
         ((listing[m+1] = #9'sta :eax') and (listing[m+3] = #9'sta :ecx')) ) and
       (pos('lda ', listing[m+2]) > 0) and (pos('lda :STACK', listing[m+2]) = 0) and	// lda 					; 2
       (listing[m+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 4
       (listing[m+5] = #9'fmulu_8') and							// fmulu_8				; 5
       (listing[m+6] = #9'els') and 							// els					; 6
       (listing[m+7] = #9'imulCL') and		 					// imulCL				; 7
       (listing[m+8] = #9'eif') then 							// eif					; 8
     begin
      k:=GetVal(copy(listing[m], 6, 256));

      if k in [0,1] then begin

	if k=0 then
	 listing[m] := #9'lda #$00'
	else
	 listing[m] := listing[m+2];

	listing[m+1] := #9'sta :eax';
	listing[m+2] := #9'lda #$00';
	listing[m+3] := #9'sta :eax+1';

	l:=m+4;

      end else begin

	case k of
	 $02: k:=1;
	 $04: k:=2;
	 $08: k:=3;
	 $10: k:=4;
	 $20: k:=5;
	 $40: k:=6;
	 $80: k:=7;
	end;

	listing[m]   := #9'lda #$00';
	listing[m+1] := #9'sta :eax+1';

	l:=m+3;

	while k>0 do begin
	 listing[l]   := #9'asl @';
	 listing[l+1] := #9'rol :eax+1';

	 inc(l, 2);
	 dec(k);
	end;

	listing[l] := #9'sta :eax';

	inc(l);

     end;    // if k in [0,1]

     end;


    if (l=9) and			// !!! tylko pierwsza poczatkowa czesc
					// !!! dla 'lda :STACK' zle optymalizuje
       (listing[m] = #9'lda #$0A') and							// lda #$0A				; 0
       (listing[m+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (pos('lda ', listing[m+2]) > 0) and (pos('lda :STACK', listing[m+2]) = 0) and	// lda					; 2
       (listing[m+3] = #9'sta :eax') and 						// sta :eax				; 3
       (listing[m+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 4
       (listing[m+5] = #9'fmulu_8') and							// fmulu_8				; 5
       (listing[m+6] = #9'els') and 							// els					; 6
       (listing[m+7] = #9'imulCL') and		 					// imulCL				; 7
       (listing[m+8] = #9'eif') then 							// eif					; 8
     begin

	listing[m]   := #9'lda #$00';
	listing[m+1] := #9'sta :eax+1';

	listing[m+3] := #9'asl @';
	listing[m+4] := #9'rol :eax+1';
	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol :eax+1';

	listing[m+7]  := #9'add ' + copy(listing[m+2], 6, 256);
	listing[m+8] := #9'sta :eax';
	listing[m+9] := #9'lda :eax+1';
	listing[m+10] := #9'adc #$00';
	listing[m+11] := #9'sta :eax+1';

	listing[m+12] := #9'asl :eax';
	listing[m+13] := #9'rol :eax+1';

	l:=m+14;
     end;


    if (l=9) and			// !!! tylko pierwsza poczatkowa czesc
					// !!! dla 'lda :STACK' zle optymalizuje
       (pos('lda ', listing[m]) > 0) and (pos('lda :STACK', listing[m]) = 0) and	// lda 					; 0
       (listing[m+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[m+2] = #9'lda #$03') and						// lda #$03				; 2
       (listing[m+3] = #9'sta :eax') and						// sta :eax				; 3
       (listing[m+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 4
       (listing[m+5] = #9'fmulu_8') and							// fmulu_8				; 5
       (listing[m+6] = #9'els') and 							// els					; 6
       (listing[m+7] = #9'imulCL') and		 					// imulCL				; 7
       (listing[m+8] = #9'eif') then 							// eif					; 8
     begin

	listing[m+1] := #9'lda #$00';
	listing[m+2] := #9'sta :eax+1';
	listing[m+3] := listing[m];

	listing[m+4] := #9'asl @';
	listing[m+5] := #9'rol :eax+1';

	listing[m+6]  := #9'add ' + copy(listing[m], 6, 256);
	listing[m+7] := #9'sta :eax';
	listing[m+8] := #9'lda :eax+1';
	listing[m+9] := #9'adc #$00';
	listing[m+10] := #9'sta :eax+1';

	listing[m] := '';

	l:=m+11;

     end;


    if (l=9) and			// !!! tylko pierwsza poczatkowa czesc
					// !!! dla 'lda :STACK' zle optymalizuje
       (listing[m] = #9'lda #$03') and							// lda #$03				; 0
       (listing[m+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (pos('lda ', listing[m+2]) > 0) and (pos('lda :STACK', listing[m+2]) = 0) and	// lda 					; 2
       (listing[m+3] = #9'sta :eax') and						// sta :eax				; 3
       (listing[m+4] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 4
       (listing[m+5] = #9'fmulu_8') and							// fmulu_8				; 5
       (listing[m+6] = #9'els') and 							// els					; 6
       (listing[m+7] = #9'imulCL') and		 					// imulCL				; 7
       (listing[m+8] = #9'eif') then 							// eif					; 8
     begin

	listing[m]   := #9'lda #$00';
	listing[m+1] := #9'sta :eax+1';

	listing[m+3] := #9'asl @';
	listing[m+4] := #9'rol :eax+1';

	listing[m+5]  := #9'add ' + copy(listing[m+2], 6, 256);
	listing[m+6] := #9'sta :eax';
	listing[m+7] := #9'lda :eax+1';
	listing[m+8] := #9'adc #$00';
	listing[m+9] := #9'sta :eax+1';

	l:=m+10;

     end;

      end else

      if (arg0 = 'imulWORD') or (arg0 = 'mulSMALLINT') then begin
	t:='';

	m:=l;

	listing[l]    := #9'lda '+GetARG(0, x);		t0 := listing[l];
	listing[l+1]  := #9'sta :ecx';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+2] := #9'sta ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(1, x);		t1 := listing[l+2];
	listing[l+3]  := #9'sta :ecx+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+4] := #9'sta ztmp9';
	 inc(l);
	end;

	listing[l+4]  := #9'lda '+GetARG(0, x-1);	t2 := listing[l+4];
	listing[l+5]  := #9'sta :eax';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+6] := #9'sta ztmp10';
	 inc(l);
	end;

	listing[l+6]  := #9'lda '+GetARG(1, x-1);	t3 :=listing[l+6];
	listing[l+7]  := #9'sta :eax+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+8] := #9'sta ztmp11';
	 inc(l);
	end;

	listing[l+8]  := #9'.ifdef fmulinit';
	listing[l+9]  := #9'fmulu_16';
	listing[l+10] := #9'els';
	listing[l+11] := #9'imulCX';
	listing[l+12] := #9'eif';

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) and (pos('#$', t2) > 0) and (pos('#$', t3) > 0) then begin

	   k:=(GetVal(copy(t0, 6, 255)) + GetVal(copy(t1, 6, 255)) shl 8) * (GetVal(copy(t2, 6, 255)) + GetVal(copy(t3, 6, 255)) shl 8);

	   listing[l]    := #9'lda #$'+IntToHex(k and $ff, 2);
	   listing[l+1]  := #9'sta :eax';
	   listing[l+2]  := #9'lda #$'+IntToHex(byte(k shr 8), 2);
	   listing[l+3]  := #9'sta :eax+1';
	   listing[l+4]  := #9'lda #$'+IntToHex(byte(k shr 16), 2);
	   listing[l+5]  := #9'sta :eax+2';
	   listing[l+6]  := #9'lda #$'+IntToHex(byte(k shr 24), 2);
	   listing[l+7]  := #9'sta :eax+3';

	   inc(l, 8);

	end else
	 inc(l, 13);

	if arg0 = 'mulSMALLINT' then begin

	listing[l]   := #9'lda ztmp11';
	listing[l+1] := #9'bpl @+';
	listing[l+2] := #9'sec';
	listing[l+3] := #9'lda :eax+2';
	listing[l+4] := #9'sbc ztmp8';
  	listing[l+5] := #9'sta :eax+2';
	listing[l+6] := #9'lda :eax+3';
	listing[l+7] := #9'sbc ztmp9';
	listing[l+8] := #9'sta :eax+3';

	listing[l+9] := '@';

	listing[l+10] := #9'lda ztmp9';
	listing[l+11] := #9'bpl @+';
	listing[l+12] := #9'sec';
	listing[l+13] := #9'lda :eax+2';
	listing[l+14] := #9'sbc ztmp10';
	listing[l+15] := #9'sta :eax+2';
	listing[l+16] := #9'lda :eax+3';
	listing[l+17] := #9'sbc ztmp11';
	listing[l+18] := #9'sta :eax+3';

	listing[l+19] := '@';

	listing[l+20] := #9'lda :eax';
	listing[l+21] := #9'sta '+GetARG(0, x-1);
	listing[l+22] := #9'lda :eax+1';
	listing[l+23] := #9'sta '+GetARG(1, x-1);
	listing[l+24] := #9'lda :eax+2';
	listing[l+25] := #9'sta '+GetARG(2, x-1);
	listing[l+26] := #9'lda :eax+3';
	listing[l+27] := #9'sta '+GetARG(3, x-1);

	inc(l, 28);
	end;


    if (l=13) and			// !!! tylko pierwsza poczatkowa czesc
					// !!! dla 'lda :STACK' zle optymalizuje
       (pos('lda ', listing[m]) > 0) and (pos('lda :STACK', listing[m]) = 0) and	// lda					; 0
       (listing[m+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       (pos('lda ', listing[m+2]) > 0) and (pos('lda :STACK', listing[m+2]) = 0) and	// lda 					; 2
       (listing[m+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       (listing[m+4] = #9'lda #$0A') and						// lda #$0A				; 4
       (listing[m+5] = #9'sta :eax') and						// sta :eax				; 5
       (listing[m+6] = #9'lda #$00') and						// lda #$00				; 6
       (listing[m+7] = #9'sta :eax+1') and						// sta :eax+1				; 7
       (listing[m+8] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 8
       (listing[m+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[m+10] = #9'els') and 							// els					; 10
       (listing[m+11] = #9'imulCX') and		 					// imulCX				; 11
       (listing[m+12] = #9'eif') then 							// eif					; 12
      begin
       listing[m+4] := listing[m];
       listing[m+6] := listing[m+2];

       listing[m]   := #9'lda #$0A';
       listing[m+2] := #9'lda #$00';
      end;				// zamieniamy miejscami aby zadzialala optymalizacja *10


    if (l=13) and			// !!! tylko pierwsza poczatkowa czesc
					// !!! dla 'lda :STACK' zle optymalizuje
       (listing[m] = #9'lda #$0A') and							// lda #$0A				; 0
       (listing[m+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[m+2] = #9'lda #$00') and						// lda #$00				; 2
       (listing[m+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       (pos('lda ', listing[m+4]) > 0) and (pos('lda :STACK', listing[m+4]) = 0) and	// lda					; 4
       (listing[m+5] = #9'sta :eax') and 						// sta :eax				; 5
       (pos('lda ', listing[m+6]) > 0) and (pos('lda :STACK', listing[m+6]) = 0) and	// lda 					; 6
       (listing[m+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7
       (listing[m+8] = #9'.ifdef fmulinit') and						// .ifdef fmulinit			; 8
       (listing[m+9] = #9'fmulu_16') and						// fmulu_16				; 9
       (listing[m+10] = #9'els') and 							// els					; 10
       (listing[m+11] = #9'imulCX') and		 					// imulCX				; 11
       (listing[m+12] = #9'eif') then 							// eif					; 12
     begin

      if listing[m+6] = #9'lda #$00' then begin

	listing[m]   := #9'lda #$00';
	listing[m+1] := #9'sta :eax+1';
	listing[m+2] := listing[m+4];

	listing[m+3] := #9'asl @';
	listing[m+4] := #9'rol :eax+1';
	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol :eax+1';

	listing[m+7]  := #9'add ' + copy(listing[m+2], 6, 256);
	listing[m+8] := #9'sta :eax';
	listing[m+9] := #9'lda :eax+1';
	listing[m+10] := #9'adc #$00';
	listing[m+11] := #9'sta :eax+1';

	listing[m+12] := #9'asl :eax';
	listing[m+13] := #9'rol :eax+1';

	l:=m+14;

      end else begin

	listing[m]   := listing[m+4];
	listing[m+1] := #9'sta :eax';
	listing[m+2] := listing[m+6];
	listing[m+3] := #9'sta :eax+1';

	listing[m+4] := #9'asl :eax';
	listing[m+5] := #9'rol :eax+1';
	listing[m+6] := #9'asl :eax';
	listing[m+7] := #9'rol :eax+1';

	listing[m+8]  := listing[m];
	listing[m+9]  := #9'add :eax';
	listing[m+10] := #9'sta :eax';
	listing[m+11] := listing[m+2];
	listing[m+12] := #9'adc :eax+1';
	listing[m+13] := #9'sta :eax+1';

	listing[m+14] := #9'asl :eax';
	listing[m+15] := #9'rol :eax+1';

	l:=m+16;

      end;

     end;


      end else

      if (arg0 = 'imulCARD') or (arg0 = 'mulINTEGER') then begin
	t:='';

	listing[l]    := #9'lda '+GetARG(0, x);
	listing[l+1]  := #9'sta :ecx';
	listing[l+2]  := #9'lda '+GetARG(1, x);
	listing[l+3]  := #9'sta :ecx+1';
	listing[l+4]  := #9'lda '+GetARG(2, x);
	listing[l+5]  := #9'sta :ecx+2';
	listing[l+6]  := #9'lda '+GetARG(3, x);
	listing[l+7]  := #9'sta :ecx+3';

	listing[l+8]  := #9'lda '+GetARG(0, x-1);
	listing[l+9]  := #9'sta :eax';
	listing[l+10] := #9'lda '+GetARG(1, x-1);
	listing[l+11] := #9'sta :eax+1';
	listing[l+12] := #9'lda '+GetARG(2, x-1);
	listing[l+13] := #9'sta :eax+2';
	listing[l+14] := #9'lda '+GetARG(3, x-1);
	listing[l+15] := #9'sta :eax+3';

	listing[l+16] := #9'jsr imulECX';

	inc(l, 17);

	if arg0 = 'mulINTEGER' then begin
	listing[l]   := #9'lda :eax';
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda :eax+1';
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda :eax+2';
	listing[l+5] := #9'sta '+GetARG(2, x-1);
	listing[l+6] := #9'lda :eax+3';
	listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);
	end;

      end else


      if pos('SYSTEM.MOVE', arg0) > 0 then begin
	t:='';

	listing[l]   := #9'lda '+GetARG(0, x-2);
	listing[l+1] := #9'sta :edx';
	listing[l+2] := #9'lda '+GetARG(1, x-2);
	listing[l+3] := #9'sta :edx+1';

	listing[l+4] := #9'lda '+GetARG(0, x-1);
	listing[l+5] := #9'sta :ecx';
	listing[l+6] := #9'lda '+GetARG(1, x-1);
	listing[l+7] := #9'sta :ecx+1';

	listing[l+8] := #9'lda '+GetARG(0, x);
	listing[l+9] := #9'sta :eax';
	listing[l+10]:= #9'lda '+GetARG(1, x);
	listing[l+11]:= #9'sta :eax+1';

	listing[l+12]:= #9'jsr @move';

	inc(l, 13);
	dec(x, 3);

      end else
      if (pos('SYSTEM.FILLCHAR', arg0) > 0) or (pos('SYSTEM.FILLBYTE', arg0) > 0) then begin
	t:='';

	listing[l]   := #9'lda '+GetARG(0, x-2);
	listing[l+1] := #9'sta :edx';
	listing[l+2] := #9'lda '+GetARG(1, x-2);
	listing[l+3] := #9'sta :edx+1';

	listing[l+4] := #9'lda '+GetARG(0, x-1);
	listing[l+5] := #9'sta :ecx';
	listing[l+6] := #9'lda '+GetARG(1, x-1);
	listing[l+7] := #9'sta :ecx+1';

	listing[l+8] := #9'lda '+GetARG(0, x);
	listing[l+9] := #9'sta :eax';

	listing[l+10]:= #9'jsr @fill';

	inc(l, 11);
	dec(x, 3);

      end else
      if arg0 = 'SYSTEM.PEEK' then begin
	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) then begin

	  listing[l]   := #9'lda '+GetARG(1, x);
	  listing[l+1] := #9'sta :bp+1';
	  listing[l+2] := #9'ldy '+GetARG(0, x);
	  listing[l+3] := #9'lda (:bp),y';
	  listing[l+4] := #9'sta '+GetARG(0, x);

	  inc(l,5);
	end else begin

	  k := GetVAL(GetARG(0, x)) + GetVAL(GetARG(1, x)) shl 8;
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l]   := #9'lda $'+IntToHex(k, 4);
	  listing[l+1] := #9'sta '+GetARG(0, x);

	  inc(l, 2);
	end;

      end else
      if arg0 = 'SYSTEM.POKE' then begin
	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(0, x-1, false)) < 0) or (GetVAL(GetARG(1, x-1, false)) < 0) then begin

	  listing[l]   := #9'lda '+GetARG(1, x-1);
	  listing[l+1] := #9'sta :bp+1';
	  listing[l+2] := #9'ldy '+GetARG(0, x-1);
	  listing[l+3] := #9'lda '+GetARG(0, x);
	  listing[l+4] := #9'sta (:bp),y';

	  inc(l,5);
	end else begin

	  k := GetVAL(GetARG(0, x));
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l]   := #9'lda #$'+IntToHex(k, 2);

	  k := GetVAL(GetARG(0, x-1)) + GetVAL(GetARG(1, x-1)) shl 8;
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l+1] := #9'sta $'+IntToHex(k, 4);

	  inc(l, 2);
	end;

	dec(x, 2);

      end else
      if arg0 = 'SYSTEM.DPEEK' then begin
	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) then begin

	  listing[l]   := #9'lda '+GetARG(0, x);
	  listing[l+1] := #9'sta :bp2';
	  listing[l+2] := #9'lda '+GetARG(1, x);
	  listing[l+3] := #9'sta :bp2+1';
	  listing[l+4] := #9'ldy #$00';
	  listing[l+5] := #9'lda (:bp2),y';
	  listing[l+6] := #9'sta '+GetARG(0, x);
	  listing[l+7] := #9'iny';
	  listing[l+8] := #9'lda (:bp2),y';
	  listing[l+9] := #9'sta '+GetARG(1, x);

	  inc(l, 10);
	end else begin

	  k := GetVAL(GetARG(0, x)) + GetVAL(GetARG(1, x)) shl 8;
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l]   := #9'lda $'+IntToHex(k, 4);
	  listing[l+1] := #9'sta '+GetARG(0, x);
	  listing[l+2] := #9'lda $'+IntToHex(k, 4)+'+1';
	  listing[l+3] := #9'sta '+GetARG(1, x);

	  inc(l, 4);
	end;

      end else
      if arg0 = 'SYSTEM.DPOKE' then begin
	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) or (GetVAL(GetARG(0, x-1, false)) < 0) or (GetVAL(GetARG(1, x-1, false)) < 0) then begin

	  listing[l]   := #9'lda '+GetARG(0, x-1);
	  listing[l+1] := #9'sta :bp2';
	  listing[l+2] := #9'lda '+GetARG(1, x-1);
	  listing[l+3] := #9'sta :bp2+1';
	  listing[l+4] := #9'ldy #$00';
	  listing[l+5] := #9'lda '+GetARG(0, x);
	  listing[l+6] := #9'sta (:bp2),y';
	  listing[l+7] := #9'iny';
	  listing[l+8] := #9'lda '+GetARG(1, x);
	  listing[l+9] := #9'sta (:bp2),y';

	  inc(l,10);
	end else begin

	  k := GetVAL(GetARG(0, x));
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;
	  listing[l]   := #9'lda #$'+IntToHex(k, 2);

	  k := GetVAL(GetARG(1, x));
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;
	  listing[l+2] := #9'lda #$'+IntToHex(k, 2);

	  k := GetVAL(GetARG(0, x-1)) + GetVAL(GetARG(1, x-1)) shl 8;
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l+1] := #9'sta $'+IntToHex(k, 4);
	  listing[l+3] := #9'sta $'+IntToHex(k, 4)+'+1';

	  inc(l, 4);
	end;

	dec(x, 2);

      end else
      if arg0 = 'shrAL_CL.BYTE' then begin	     // SHR BYTE
	t:='';

	k := GetVAL(GetARG(0, x));
	if (k > 7) or (k < 0) then begin x:=50; Break end;

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	inc(l);

	for m := 0 to k - 1 do begin
	 listing[l] := #9'lsr @';
	 inc(l);
	end;

	listing[l]   := #9'sta '+GetARG(0, x-1);

	inc(l);

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l, 6);

      end else
      if arg0 = 'shrAX_CL.WORD' then begin	     // SHR WORD
	t:='';

	k := GetVAL(GetARG(0, x));
	if (k > 8) or (k < 0) then begin x:=50; Break end;

     if k = 8 then begin
	listing[l]   := #9'lda ' + GetARG(1, x-1);
	s[x-1][0] := '';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);

	inc(l, 2);

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda ' + GetARG(0, x-1);

	inc(l, 3);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'lsr ' + GetARG(1, x-1);
	listing[l+1] := #9'ror @';

	inc(l, 2);
       end;

	listing[l]   := #9'sta ' + GetARG(0, x-1);
	listing[l+1] := #9'lda ' + GetARG(1, x-1);
	listing[l+2] := #9'sta ' + GetARG(1, x-1);

	inc(l, 3);

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta '+GetARG(2, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta '+GetARG(3, x-1);

	inc(l, 4);

     end;

     end else
      if arg0 = 'shrEAX_CL' then begin	     // SHR CARDINAL
	t:='';

	k := GetVAL(GetARG(0, x));
	if k < 0 then begin x:=50; Break end;

	m := k div 8;
	k := k mod 8;

	if m > 3 then begin

	 k:=0;

	 listing[l]   := #9'lda #$00';
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'sta ' + GetARG(1, x-1);
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);
	end else
	 case m of
	   1: begin
	       listing[l]   := #9'lda ' + GetARG(1, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	       s[x-1][1] := '';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);

	       listing[l+4]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][2] := '';
	       listing[l+5] := #9'sta ' + GetARG(2, x-1);

	       listing[l+6] := #9'lda #$00';
	       listing[l+7] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 8);
	      end;

	   2: begin
	       listing[l]   := #9'lda ' + GetARG(2, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       listing[l+2]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][1] := '';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);

	       listing[l+4] := #9'lda #$00';
	       listing[l+5] := #9'sta ' + GetARG(2, x-1);
	       listing[l+6] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 7);
	      end;

	   3: begin
	       listing[l]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       s[x-1][1] := '';
	       s[x-1][2] := '';
	       s[x-1][3] := '';

	       listing[l+2] := #9'lda #$00';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);
	       listing[l+4] := #9'sta ' + GetARG(2, x-1);
	       listing[l+5] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 6);
	      end;

	   end;

	if k > 0 then begin

	  if m = 0 then begin

	   listing[l]   := #9'lda ' + GetARG(0, x-1);
	   listing[l+1] := #9'sta ' + GetARG(0, x-1);
	   listing[l+2] := #9'lda ' + GetARG(1, x-1);
	   listing[l+3] := #9'sta ' + GetARG(1, x-1);
	   listing[l+4] := #9'lda ' + GetARG(2, x-1);
	   listing[l+5] := #9'sta ' + GetARG(2, x-1);
	   listing[l+6] := #9'lda ' + GetARG(3, x-1);
	   listing[l+7] := #9'sta ' + GetARG(3, x-1);

	   inc(l, 8);
	  end;

	  for m := 0 to k - 1 do begin

	    listing[l]   := #9'lsr ' + GetARG(3, x-1);
	    listing[l+1] := #9'ror ' + GetARG(2, x-1);
	    listing[l+2] := #9'ror ' + GetARG(1, x-1);
	    listing[l+3] := #9'ror ' + GetARG(0, x-1);

	    inc(l, 4);
	  end;

	  listing[l]   := #9'lda ' + GetARG(0, x-1);
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lda ' + GetARG(1, x-1);
	  listing[l+3] := #9'sta ' + GetARG(1, x-1);
	  listing[l+4] := #9'lda ' + GetARG(2, x-1);
	  listing[l+5] := #9'sta ' + GetARG(2, x-1);
	  listing[l+6] := #9'lda ' + GetARG(3, x-1);
	  listing[l+7] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 8);
	end;

     end else

      if arg0 = 'shlEAX_CL.BYTE' then begin	    // SHL BYTE
	t:='';

	k := GetVAL(GetARG(0, x));

	s[x-1][1] := '';				// !!! bez tego nie zadziala gdy 'lda adr.' !!!
	s[x-1][2] := '';
	s[x-1][3] := '';

	inc(l, 2);

	if k in [12..15] then begin			// shl 14 -> (shl 16) shr 2

	k:=16-k;

	listing[l]   := #9'lda #$00';			// shl 16
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
	listing[l+6] := #9'lda ' + GetARG(0, x-1);
	listing[l+7] := #9'sta ' + GetARG(2, x-1);
	listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

	inc(l, 10);

	  for m := 0 to k-1 do begin			// shr 2

	    listing[l]   := #9'lsr ' + GetARG(2, x-1);
	    listing[l+1] := #9'ror @';

	    inc(l, 2);
	  end;

	  listing[l]   := #9'sta ' + GetARG(1, x-1);
	  listing[l+1] := #9'lda ' + GetARG(2, x-1);
	  listing[l+2] := #9'sta ' + GetARG(2, x-1);

	  inc(l, 3);

	end else

	if k in [8,16,24] then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
	listing[l+6] := #9'lda ' + GetARG(0, x-1);

	 case k of
	  8: listing[l+7] := #9'sta ' + GetARG(1, x-1);
	 16: listing[l+7] := #9'sta ' + GetARG(2, x-1);
	 24: listing[l+7] := #9'sta ' + GetARG(3, x-1);
	 end;

	listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

	inc(l, 10);

	end else begin

	if (k > 7) or (k < 0) then begin x:=50; Break end;

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda #$00';

	inc(l, 3);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'asl ' + GetARG(0, x-1);
	listing[l+1] := #9'rol @';

	inc(l, 2);
       end;

       listing[l]   := #9'sta ' + GetARG(1, x-1);
       listing[l+1] := #9'lda ' + GetARG(0, x-1);
       listing[l+2] := #9'sta ' + GetARG(0, x-1);

       inc(l, 3);

       end;

      end else
      if arg0 = 'shlEAX_CL.WORD' then begin	    // SHL WORD
	t:='';

	k := GetVAL(GetARG(0, x));

	if k = 16 then begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(2, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(3, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(0, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(1, x-1);

	inc(l, 8);

	end else
	if k = 8 then begin

	listing[l]   := #9'lda ' + GetARG(2, x-1);
	listing[l+1] := #9'sta ' + GetARG(3, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda ' + GetARG(0, x-1);
	listing[l+5] := #9'sta ' + GetARG(1, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	end else begin

	if (k > 7) or (k < 0) then begin x:=50; Break end;

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(1, x-1);

	listing[l+4] := #9'lda #$00';

	inc(l, 5);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'asl ' + GetARG(0, x-1);
	listing[l+1] := #9'rol ' + GetARG(1, x-1);
	listing[l+2] := #9'rol @';

	inc(l, 3);
       end;

       listing[l]   := #9'sta ' + GetARG(2, x-1);
       listing[l+1] := #9'lda ' + GetARG(0, x-1);
       listing[l+2] := #9'sta ' + GetARG(0, x-1);
       listing[l+3] := #9'lda ' + GetARG(1, x-1);
       listing[l+4] := #9'sta ' + GetARG(1, x-1);

       inc(l, 5);

       end;

      end else
      if arg0 = 'shlEAX_CL.CARD' then begin	    // SHL CARD
       t:='';

       k := GetVAL(GetARG(0, x));
       if {(k > 7) or} (k < 0) then begin x:=50; Break end;

       m:=k div 8;
       k:=k mod 8;

       if m > 3 then begin

	k:=0;

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'sta ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'sta ' + GetARG(3, x-1);

	inc(l, 5);
       end else
	case m of
	 1: begin
	     listing[l]   := #9'lda ' + GetARG(1, x-1);
	     listing[l+1] := #9'sta ' + GetARG(1, x-1);
	     listing[l+2] := #9'lda ' + GetARG(2, x-1);
	     listing[l+3] := #9'sta ' + GetARG(2, x-1);
	     listing[l+4] := #9'lda ' + GetARG(3, x-1);
	     listing[l+5] := #9'sta ' + GetARG(3, x-1);

	     inc(l, 6);

	     listing[l]   := #9'lda ' + GetARG(2, x-1);
	     s[x-1, 3] := '';
	     listing[l+1] := #9'sta ' + GetARG(3, x-1);
	     listing[l+2] := #9'lda ' + GetARG(1, x-1);
	     s[x-1, 2] := '';
	     listing[l+3] := #9'sta ' + GetARG(2, x-1);
	     listing[l+4] := #9'lda ' + GetARG(0, x-1);
	     s[x-1, 1] := '';
	     listing[l+5] := #9'sta ' + GetARG(1, x-1);
	     listing[l+6] := #9'lda #$00';
	     s[x-1, 0] := '';
	     listing[l+7] := #9'sta ' + GetARG(0, x-1);

	     inc(l, 8);
	    end;

	 2: begin
	     listing[l]   := #9'lda ' + GetARG(2, x-1);
	     listing[l+1] := #9'sta ' + GetARG(2, x-1);
	     listing[l+2] := #9'lda ' + GetARG(3, x-1);
	     listing[l+3] := #9'sta ' + GetARG(3, x-1);

	     inc(l, 4);

	     listing[l]   := #9'lda ' + GetARG(1, x-1);
	     s[x-1, 3] := '';
	     listing[l+1] := #9'sta ' + GetARG(3, x-1);
	     listing[l+2] := #9'lda ' + GetARG(0, x-1);
	     s[x-1, 2] := '';
	     listing[l+3] := #9'sta ' + GetARG(2, x-1);
	     listing[l+4] := #9'lda #$00';
	     listing[l+5] := #9'sta ' + GetARG(0, x-1);
	     listing[l+6] := #9'sta ' + GetARG(1, x-1);

	     inc(l, 7);
	    end;

	 3: begin
	     listing[l]   := #9'lda ' + GetARG(3, x-1);
	     listing[l+1] := #9'sta ' + GetARG(3, x-1);

	     inc(l, 2);

	     listing[l]   := #9'lda ' + GetARG(0, x-1);
	     s[x-1, 3] := '';
	     listing[l+1] := #9'sta ' + GetARG(3, x-1);
	     listing[l+2] := #9'lda #$00';
	     listing[l+3] := #9'sta ' + GetARG(0, x-1);
	     listing[l+4] := #9'sta ' + GetARG(1, x-1);
	     listing[l+5] := #9'sta ' + GetARG(2, x-1);

	     inc(l, 6);
	    end;

	end;

       if k > 0 then begin

	 if m = 0 then begin

	  listing[l]   := #9'lda ' + GetARG(0, x-1);
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lda ' + GetARG(1, x-1);
	  listing[l+3] := #9'sta ' + GetARG(1, x-1);
	  listing[l+4] := #9'lda ' + GetARG(2, x-1);
	  listing[l+5] := #9'sta ' + GetARG(2, x-1);
	  listing[l+6] := #9'lda ' + GetARG(3, x-1);
	  listing[l+7] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 8);
	 end;

	 for m := 0 to k - 1 do begin

	  listing[l]   := #9'asl ' + GetARG(0, x-1);
	  listing[l+1] := #9'rol ' + GetARG(1, x-1);
	  listing[l+2] := #9'rol ' + GetARG(2, x-1);
	  listing[l+3] := #9'rol ' + GetARG(3, x-1);

	  inc(l, 4);
	 end;

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'lda ' + GetARG(1, x-1);
	 listing[l+3] := #9'sta ' + GetARG(1, x-1);
	 listing[l+4] := #9'lda ' + GetARG(2, x-1);
	 listing[l+5] := #9'sta ' + GetARG(2, x-1);
	 listing[l+6] := #9'lda ' + GetARG(3, x-1);
	 listing[l+7] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 8);
       end;

      end else

      if arg0 = 'andEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'and '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'and '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'and '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
      if arg0 = 'andAL_CL' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       inc(l, 3);
      end else
      if arg0 = 'andAX_CX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'and '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       inc(l, 6);
      end else
      if arg0 = 'andEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'and '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'and '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9]  := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'and '+GetARG(3, x);
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
      if arg0 = 'orAL_CL' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'ora '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       inc(l, 3);
      end else
      if arg0 = 'orAX_CX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'ora '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'ora '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       inc(l, 6);
      end else
      if arg0 = 'orEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'ora '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'ora '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'ora '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'ora '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
      if arg0 = 'xorAL_CL' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'eor '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       inc(l, 3);
      end else
      if arg0 = 'xorAX_CX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'eor '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'eor '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       inc(l, 6);
      end else
      if arg0 = 'xorEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'eor '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'eor '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'eor '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'eor '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
      if arg0 = 'notaBX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x);
       listing[l+1] := #9'eor #$ff';
       listing[l+2] := #9'sta '+GetARG(0, x);

       listing[l+3] := #9'lda '+GetARG(1, x);
       listing[l+4] := #9'eor #$ff';
       listing[l+5] := #9'sta '+GetARG(1, x);

       listing[l+6] := #9'lda '+GetARG(2, x);
       listing[l+7] := #9'eor #$ff';
       listing[l+8] := #9'sta '+GetARG(2, x);

       listing[l+9] := #9'lda '+GetARG(3, x);
       listing[l+10]:= #9'eor #$ff';
       listing[l+11]:= #9'sta '+GetARG(3, x);

       inc(l, 12);
      end else
      if arg0 = 'cmpEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda ' + GetARG(3, x-1);
       listing[l+1] := #9'cmp ' + GetARG(3, x);
       listing[l+2] := #9'bne @+';
       listing[l+3] := #9'lda ' + GetARG(2, x-1);
       listing[l+4] := #9'cmp ' + GetARG(2, x);
       listing[l+5] := #9'bne @+';
       listing[l+6] := #9'lda ' + GetARG(1, x-1);
       listing[l+7] := #9'cmp ' + GetARG(1, x);
       listing[l+8] := #9'bne @+';
       listing[l+9] := #9'lda ' + GetARG(0, x-1);
       listing[l+10]:= #9'cmp ' + GetARG(0, x);
       listing[l+11]:= '@';

       inc(l, 12);
      end else
      if arg0 = 'cmpEAX_ECX.AX_CX' then begin
       t:='';

       listing[l]   := #9'lda ' + GetARG(1, x-1);
       listing[l+1] := #9'cmp ' + GetARG(1, x);
       listing[l+2] := #9'bne @+';
       listing[l+3] := #9'lda ' + GetARG(0, x-1);
       listing[l+4] := #9'cmp ' + GetARG(0, x);
       listing[l+5] := '@';

       inc(l, 6);
      end else
      if arg0='@expandToCARD1.BYTE' then begin
       t:='';

       s[x-1][1] := #9'mva #$00';
       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';
      end else
      if arg0='@expandToCARD.BYTE' then begin
       t:='';

       s[x][1] := #9'mva #$00';
       s[x][2] := #9'mva #$00';
       s[x][3] := #9'mva #$00';
      end else
      if arg0='@expandToCARD.WORD' then begin
       t:='';

       s[x][2] := #9'mva #$00';
       s[x][3] := #9'mva #$00';
      end else
      if arg0='@expandToCARD1.WORD' then begin
       t:='';

       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';
      end else
      if (pos('add', arg0) > 0) or (pos('sub', arg0) > 0) then begin

      t:='';

      if (arg0 = 'subAL_CL') then begin
       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;

      if (arg0 = 'subAX_CX') then begin
       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;

      if (arg0 = 'subEAX_ECX') then begin
       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'sbc '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9]  := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'sbc '+GetARG(3, x);
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;

      if arg0 = 'addAL_CL' then begin

       if (pos(',y', s[x-1][0]) >0 ) or (pos(',y', s[x][0]) >0 ) then begin x:=30; Break end;

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'adc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'adc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'adc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;
      if arg0 = 'addAX_CX' then begin
       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'adc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'adc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;
      if (arg0 = 'addEAX_ECX') then begin

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'adc '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'adc '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;

      end else begin

{$IFDEF USEOPTFILE}

	writeln(arg0);

{$ENDIF}

	x:=51; Break;
      end;

     end;



   if (pos(':STACKORIGIN,', t) > 7) and (pos('(:bp),', t) = 0) then begin	// kiedy odczytujemy tablice
    s[x][0]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][0]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(0, x);
     listing[l+1] := #9'sta ' + GetARG(0, x);

     inc(l, 2);
    end;
   end;

   if (pos(':STACKORIGIN+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0) then begin
    s[x][1]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][1]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(1, x);
     listing[l+1] := #9'sta ' + GetARG(1, x);

     inc(l, 2);
    end;
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0) then begin
    s[x][2]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][2]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(2, x);
     listing[l+1] := #9'sta ' + GetARG(2, x);

     inc(l, 2);
    end;
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0) then begin
    s[x][3]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][3]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(3, x);
     listing[l+1] := #9'sta ' + GetARG(3, x);

     inc(l, 2);
    end;
   end;


{
   if (pos(':STACKORIGIN+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x][1]:=copy(a, 1, pos(' :STACK', a)); oldT:=t; t:='' end;
   if (pos(':STACKORIGIN,', oldt) > 7) and (pos('sta :STACKORIGIN+STACKWIDTH,', t) > 0) then begin s[x][1] := s[x][0]; oldT:=''; t:='' end;

   if (pos(':STACKORIGIN+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x][2]:=copy(a, 1, pos(' :STACK', a)); oldT:=t; t:=''end;
   if (pos(':STACKORIGIN+STACKWIDTH,', oldt) > 7) and (pos('sta :STACKORIGIN+STACKWIDTH*2,', t) > 0) then begin s[x][2] := s[x][1]; oldT:=''; t:='' end;

   if (pos(':STACKORIGIN+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x][3]:=copy(a, 1, pos(' :STACK', a)); oldT:=t; t:='' end;
   if (pos(':STACKORIGIN+STACKWIDTH*2,', oldt) > 7) and (pos('sta :STACKORIGIN+STACKWIDTH*3,', t) > 0) then begin s[x][3] := s[x][2]; oldT:=''; t:='' end;
}


   if (pos(':STACKORIGIN-1+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x-1][1]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN-1+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x-1][2]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN-1+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x-1][3]:=copy(a, 1, pos(' :STACK', a)); t:='' end;

   if (pos(':STACKORIGIN+1+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x+1][1]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN+1+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x+1][2]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN+1+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0) then begin s[x+1][3]:=copy(a, 1, pos(' :STACK', a)); t:='' end;



   if (pos(':STACKORIGIN,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 14);

    arg0 := GetARG(0, x);
    insert(arg0, t, k );
   end;

   if (pos(':STACKORIGIN+STACKWIDTH,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 25);

    arg0 := GetARG(1, x);
    insert(arg0, t, k );
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*2,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 27);

    arg0 := GetARG(2, x);
    insert(arg0, t, k );
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*3,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 27);

    arg0 := GetARG(3, x);
    insert(arg0, t, k );
   end;


   if (pos(':STACKORIGIN-1,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(0, x-1);

   if (pos(':STACKORIGIN-1+STACKWIDTH,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(1, x-1);

   if (pos(':STACKORIGIN-1+STACKWIDTH*2,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(2, x-1);

   if (pos(':STACKORIGIN-1+STACKWIDTH*3,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(3, x-1);



   if (pos(':STACKORIGIN+1,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(0, x+1);

   if (pos(':STACKORIGIN+1+STACKWIDTH,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(1, x+1);

   if (pos(':STACKORIGIN+1+STACKWIDTH*2,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(2, x+1);

   if (pos(':STACKORIGIN+1+STACKWIDTH*3,', t) = 6) then
     t:=copy(a, 1, pos(' :STACK', a)) + GetARG(3, x+1);


   if t<>'' then begin
    listing[l] := t;
    inc(l);
   end;

  end;

 end;

(* -------------------------------------------------------------------------- *)

 //if opt_func = false then

 if ((x = 0) and inxUse) then begin   // succesfull

  ifTmp := false;

  writeln(OutFile, #13#10'; optimize OK ('+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line)+#13#10);

{$IFDEF OPTIMIZECODE}

  repeat until OptimizeRelation;

  OptimizeAssignment;

  repeat until OptimizeRelation;

{$ENDIF}


(* -------------------------------------------------------------------------- *)
//				opty	FOR
(* -------------------------------------------------------------------------- *)

  Rebuild;

   for i := 0 to l - 1 do
    if (pos('mva #$', listing[i]) > 0) and (pos('@FORTMP_', listing[i]) > 0) then begin

     if pos('+3', listing[i]) > 0 then optyFOR3 := listing[i] else
     if pos('+2', listing[i]) > 0 then optyFOR2 := listing[i] else
     if pos('+1', listing[i]) > 0 then optyFOR1 := listing[i] else optyFOR0 := listing[i];

     listing[i] := '';
    end;


  Rebuild;

  for i := 0 to l - 1 do
   if (pos('cmp @FORTMP_', listing[i]) > 0) then begin

    if pos('+3', listing[i]) > 0 then begin
     if pos(copy(listing[i], 6, 256), optyFOR3) > 0 then listing[i] := #9'cmp ' + GetString(optyFOR3);
    end else
    if pos('+2', listing[i]) > 0 then begin
     if pos(copy(listing[i], 6, 256), optyFOR2) > 0 then listing[i] := #9'cmp ' + GetString(optyFOR2);
    end else
    if pos('+1', listing[i]) > 0 then begin
     if pos(copy(listing[i], 6, 256), optyFOR1) > 0 then listing[i] := #9'cmp ' + GetString(optyFOR1);
    end else
     if pos(copy(listing[i], 6, 256), optyFOR0) > 0 then listing[i] := #9'cmp ' + GetString(optyFOR0);

  end else
   if (pos('sbc @FORTMP_', listing[i]) > 0) then begin

    if pos('+3', listing[i]) > 0 then begin
     if pos(copy(listing[i], 6, 256), optyFOR3) > 0 then listing[i] := #9'sbc ' + GetString(optyFOR3);
    end else
    if pos('+2', listing[i]) > 0 then begin
     if pos(copy(listing[i], 6, 256), optyFOR2) > 0 then listing[i] := #9'sbc ' + GetString(optyFOR2);
    end else
    if pos('+1', listing[i]) > 0 then begin
     if pos(copy(listing[i], 6, 256), optyFOR1) > 0 then listing[i] := #9'sbc ' + GetString(optyFOR1);
    end else
     if pos(copy(listing[i], 6, 256), optyFOR0) > 0 then listing[i] := #9'sbc ' + GetString(optyFOR0);
  end;


(* -------------------------------------------------------------------------- *)
//				opty	REG A
(* -------------------------------------------------------------------------- *)

  Rebuild;

  arg0 := '';

  if l < 3 then
   for i := 0 to l - 1 do
    if (pos('mva #$', listing[i]) > 0) then begin

     arg0:=GetString(listing[i]);

     if arg0 = optyA then listing[i] := #9'sta ' + copy(listing[i], pos('mva #$', listing[i]) + 9, 256);

     optyA := arg0;

    end else
     if (pos('lda ', listing[i]) > 0) or (pos('mva ', listing[i]) > 0) or (pos('mwa ', listing[i]) > 0) or
	(listing[i] = #9'tya') then begin arg0 := ''; optyA := '' end;

  optyA := arg0;


(* -------------------------------------------------------------------------- *)
//				opty	BP2
(* -------------------------------------------------------------------------- *)

  Rebuild;

  for i := 0 to l - 1 do
   if listing[i]<>'' then						      // mwa a bp2
    if ((pos('mwa ', listing[i])>0) and (pos(' :bp2', listing[i])>0)) or
       ((pos('mwy ', listing[i])>0) and (pos(' :bp2', listing[i])>0)) then begin
	 arg0:=listing[i]; arg0[4]:='?';

	 if arg0 = optyBP2 then listing[i] := '';

	 optyBP2 := arg0;
       end;


(* -------------------------------------------------------------------------- *)
//				opty	REG Y
(* -------------------------------------------------------------------------- *)

  Rebuild;

   for i := 0 to l - 1 do
    if (pos('ldy ', listing[i]) > 0) and (pos(#9'tya', listing[i+1]) = 0) and (pos('cmp ', listing[i+1]) = 0) then begin

     for k:=i-1 downto 0 do
       if (pos('ldy ', listing[k]) > 0) then begin

	if listing[i] = listing[k] then listing[i] := '';

	Break;

       end else
	if (listing[k] = #9'iny') or (listing[k]=#9'dey') or (listing[k]=#9'tay') or (listing[k] = #9'eif') or
	   (pos('mvy ', listing[k]) > 0) or (pos('mwy ', listing[k]) > 0) then Break;

    end;


  Rebuild;

  arg0 := '';

 // if l < 3 then
   for i := 0 to l - 1 do
    if (pos('ldy ', listing[i]) > 0) then begin

     arg0:=GetString(listing[i]);

     if arg0 = optyY then listing[i] := '' else optyY := arg0;

    end else
     if (listing[i] = #9'iny') or (listing[i]=#9'dey') or (listing[i]=#9'tay')  or
	(pos('mvy ', listing[i]) > 0) or (pos('mwy ', listing[i]) > 0) or (pos('.ifdef ', listing[i]) > 0) or
	(pos('jsr ', listing[i]) > 0) or (pos('jmp ', listing[i]) > 0) then begin arg0 := ''; optyY := '' end;

  optyY := arg0;


(* -------------------------------------------------------------------------- *)

  Rebuild;

  for i := 0 to l - 1 do
    if listing[i]<>'' then Writeln(OutFile, listing[i]);


(* -------------------------------------------------------------------------- *)
(* -------------------------------------------------------------------------- *)


 end else begin

  resetOpty;

  if x = 51 then
   writeln(OutFile, #13#10'; optimize FAIL ('+''''+arg0+''''+ ', '+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line))
  else
   writeln(OutFile, #13#10'; optimize FAIL ('+IntToStr(x)+', '+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line));


  l := High(OptimizeBuf);
  for i := 0 to l - 1 do
   listing[i] := OptimizeBuf[i].line;

{$IFDEF OPTIMIZECODE}

  repeat until OptimizeStack;	     // optymalizacja lda :STACK... \ sta :STACK...

{$ENDIF}

  for i := 0 to l - 1 do
    {if listing[i]<>'' then} Writeln(OutFile, listing[i]);


//  for i := 0 to High(OptimizeBuf) - 1 do
//    Writeln(OutFile, OptimizeBuf[i].line);

 end;


{$IFDEF USEOPTFILE}

 writeln(OptFile, StringOfChar('-', 32));
 writeln(OptFile, 'SOURCE');
 writeln(OptFile, StringOfChar('-', 32));

  for i := 0 to High(OptimizeBuf) - 1 do
    Writeln(OptFile, OptimizeBuf[i].line+#9#9#9#9#9+OptimizeBuf[i].comment);

 writeln(OptFile, StringOfChar('-', 32));
 writeln(OptFile, 'OPTIMIZE ',((x = 0) and inxUse),', x=',x,', ('+UnitName[optimize.unitIndex].Name+') line = ',optimize.line);
 writeln(OptFile, StringOfChar('-', 32));

  for i := 0 to l - 1 do
    Writeln(OptFile, listing[i]);

 writeln(OptFile);
 writeln(OptFile, StringOfChar('-', 64));
 writeln(OptFile);

{$ENDIF}


 SetLength(OptimizeBuf, 1);

end;


procedure OptimizeTMP;
var i: integer;


  function SKIP(i: integer): Boolean;
  begin

     if i<0 then
      Result:=False
     else
      Result :=	(TemporaryBuf[i].line = #9'seq') or (TemporaryBuf[i].line = #9'sne') or
		(TemporaryBuf[i].line = #9'spl') or (TemporaryBuf[i].line = #9'smi') or
		(TemporaryBuf[i].line = #9'scc') or (TemporaryBuf[i].line = #9'scs') or
		(pos('bne ', TemporaryBuf[i].line) > 0) or (pos('beq ', TemporaryBuf[i].line) > 0) or
		(pos('bcc ', TemporaryBuf[i].line) > 0) or (pos('bcs ', TemporaryBuf[i].line) > 0) or
		(pos('bmi ', TemporaryBuf[i].line) > 0) or (pos('bpl ', TemporaryBuf[i].line) > 0);
  end;


  function TestBranch(i: integer): Boolean;
  var j: integer;
  begin

   Result:=true;

   for j:=i downto 0 do begin

    if pos(' @+', TemporaryBuf[j].line) > 0 then begin Result:=false; Break end;
    if pos('lda ', TemporaryBuf[j].line) > 0 then Break;

   end;

  end;


begin

 for i:=0 to High(TemporaryBuf)-1 do
  if TemporaryBuf[i].line <> '' then begin

   if (pos('jmp l_', TemporaryBuf[i].line) > 0) then					// jmp l_xxxx		; 0
    if TemporaryBuf[i+1].line = copy(TemporaryBuf[i].line, 6, 256) then			//l_xxxx		; 1
    begin
     TemporaryBuf[i].line   := '';
     TemporaryBuf[i+1].line := '';
    end;


   if (SKIP(i) = false) and								// beq *+5		; 1
      (pos('beq *+5', TemporaryBuf[i+1].line) > 0) and					// jmp l_xxxx		; 2
      (pos('jmp l_', TemporaryBuf[i+2].line) > 0) then
    begin
     TemporaryBuf[i+1].line := #9'jne ' + copy(TemporaryBuf[i+2].line, 6, 256);
     TemporaryBuf[i+2].line := '';
    end;


   if TestBranch(i) and									// beq @+		; 1
      (pos('beq @+', TemporaryBuf[i+1].line) > 0) and					// jmp l_xxxx		; 2
      (pos('jmp l_', TemporaryBuf[i+2].line) > 0) and
      (TemporaryBuf[i+3].line = '@') then
    begin
     TemporaryBuf[i+1].line := #9'jne ' + copy(TemporaryBuf[i+2].line, 6, 256);
     TemporaryBuf[i+2].line := '';
//     TemporaryBuf[i+3].line := '';
    end;


   if TestBranch(i) and									// bcs @+		; 1
      (pos('bcs @+', TemporaryBuf[i+1].line) > 0) and					// jmp l_xxxx		; 2
      (pos('jmp l_', TemporaryBuf[i+2].line) > 0) and
      (TemporaryBuf[i+3].line = '@') then
    begin
     TemporaryBuf[i+1].line := #9'jcc ' + copy(TemporaryBuf[i+2].line, 6, 256);
     TemporaryBuf[i+2].line := '';
//     TemporaryBuf[i+3].line := '';
    end;


   if TestBranch(i) and									// bcc @+		; 1
      (pos('bcc @+', TemporaryBuf[i+1].line) > 0) and					// jmp l_xxxx		; 2
      (pos('jmp l_', TemporaryBuf[i+2].line) > 0) and
      (TemporaryBuf[i+3].line = '@') then
    begin
     TemporaryBuf[i+1].line := #9'jcs ' + copy(TemporaryBuf[i+2].line, 6, 256);
     TemporaryBuf[i+2].line := '';
//     TemporaryBuf[i+3].line := '';
    end;


   if (TemporaryBuf[i].line = #9'seq') and
      (pos('jmp l_', TemporaryBuf[i+1].line) > 0) then
    begin
     TemporaryBuf[i].line   := #9'jne ' + copy(TemporaryBuf[i+1].line, 6, 256);
     TemporaryBuf[i+1].line := '';
    end;

 end;


 for i:=0 to High(TemporaryBuf)-1 do writeln(OutFile, TemporaryBuf[i].line );// +#9';--');

 SetLength(TemporaryBuf, 1);

end;



procedure asm65(a: string; comment : string ='');
var len, i: integer;
    optimize_code: Boolean;
    str: string;


 procedure WriteTemporary(s: string);
 var i: integer;
 begin
     i:=High(TemporaryBuf);
     TemporaryBuf[i].line := s;
     TemporaryBuf[i].comment := '';

     SetLength(TemporaryBuf, i+2);
 end;


begin

{$IFDEF OPTIMIZECODE}
 optimize_code := true;
{$ELSE}
 optimize_code := false;
{$ENDIF}

 if not OutputDisabled then

 if Pass = CODEGENERATIONPASS then begin

  if optimize_code and optimize.use then begin

   i:=High(OptimizeBuf);
   OptimizeBuf[i].line := a;
   OptimizeBuf[i].comment := comment;

   SetLength(OptimizeBuf, i+2);

  end else begin

   if High(OptimizeBuf) > 0 then begin

     if High(TemporaryBuf) > 0 then OptimizeTMP;

     OptimizeASM;
   end else begin

    str:=a;

    if comment<>'' then begin

     len:=0;

     for i := 1 to length(a) do
      if a[i] = #9 then
       inc(len, 8-(len mod 8))
      else
       if not(a[i] in [#13, #10]) then inc(len);

     while len<56 do begin str:=str+#9; inc(len, 8) end;

     str:=str + comment;

    end;

    WriteTemporary(str);

   end;

  end;

 end;

end;


function GetValueType(Value: Int64): byte;
begin

    if Value < 0 then begin

     if Value >= Low(shortint) then Result:=SHORTINTTOK else
      if Value >= Low(smallint) then Result := SMALLINTTOK else
       Result := INTEGERTOK;

    end else

    case Value of
	   0..255: Result := BYTETOK;
       256..$FFFF: Result := WORDTOK;
      else
       Result := CARDINALTOK
    end;

end;


procedure NormalizePath(var Name: string);
begin

  {$IFDEF UNIX}
   if Pos('\', Name) > 0 then
    Name := LowerCase(StringReplace(Name, '\', '/', [rfReplaceAll]));
  {$ENDIF}

  {$IFDEF LINUX}
    Name := LowerCase(Name);
  {$ENDIF}
end;


function FindFile(Name: string; ftyp: TString): string;
var i: integer;
begin

  NormalizePath(Name);

  i:=0;

  repeat

   Result :=  Name;

   if not FileExists( Result ) then begin
    Result := UnitPath[i] + Name;

     if not FileExists( Result ) and (i > 0) then begin
      Result := FilePath + UnitPath[i] + Name;
     end;

   end;

   inc(i);

  until (i > High(UnitPath)) or FileExists(Result);

  if not FileExists( Result ) then
   if ftyp = 'unit' then
    Error(NumTok, 'Can''t find unit '+ChangeFileExt(Name,'')+' used by '+PROGRAM_NAME)
   else
    Error(NumTok, 'Can''t open '+ftyp+' file '''+Result+'''');

end;


procedure CheckTok(i: integer; ExpectedTok: Byte);
var s: string;
begin

 if ExpectedTok < IDENTTOK then
  s := Spelling[ExpectedTok]
 else if ExpectedTok = IDENTTOK then
  s := 'identifier'
 else if (ExpectedTok = INTNUMBERTOK) then
  s := 'number'
 else if (ExpectedTok = CHARLITERALTOK) then
  s := 'literal'
 else
  s := 'unknown token';

 if Tok[i].Kind <> ExpectedTok then
   Error(i, 'Syntax error, ' + ''''+ s +'''' + ' expected but ''' + GetSpelling(i) + ''' found');

end;


procedure TokenizeProgram(UsesOn: Boolean = true);
var
  Text, Num, Frac: TString;
  OldNumTok, UnitIndex, IncludeIndex, Line, Err, cnt, Line2, Spaces: Integer;
  Tmp: Int64;
  AsmFound, UsesFound: Boolean;
  ch, ch2: Char;
  CurToken: Byte;


  procedure TokenizeUnit(a: integer); forward;


  procedure Tokenize(fnam: string);
  var InFile: file of char;
      _line: integer;
      _uidx: integer;


  procedure ReadUses;
  var i, j: integer;
      s, nam: string;
      _line: integer;
      _uidx: integer;
  begin

	 UsesFound := false;

	 i := NumTok-1;

	 while Tok[i].Kind <> USESTOK do begin

	 CheckTok(i, IDENTTOK);

	 nam := FindFile(Tok[i].Name^+'.pas', 'unit');

	 s:=AnsiUpperCase(Tok[i].Name^);

	 for j := 2 to NumUnits do		// kasujemy wczesniejsze odwolania
	   if UnitName[j].Name = s then UnitName[j].Name := '';

	  _line := Line;
	 _uidx := UnitIndex;

	 inc(NumUnits);
	 UnitIndex := NumUnits;

	 Line:=1;
  	 UnitName[UnitIndex].Name := s;
	 UnitName[UnitIndex].Path := nam;

	 TokenizeUnit( UnitIndex );

	 Line := _line;
	 UnitIndex := _uidx;

	 if Tok[i - 1].Kind = COMMATOK then
	  dec(i, 2)
	 else
	  dec(i);
	 end;

  end;

function SearchDefine(X: string): integer;
  var i: integer;
  begin
   for i:=1 to NumDefines do
    if X = Defines[i] then begin
     Exit(i);
    end;
   Result := 0;
  end;

  procedure AddDefine(X: string);
  var S: TName;
  begin
   S := X;
   if SearchDefine(S) = 0 then
   begin
    Inc(NumDefines);
    Defines[NumDefines] := S;
   end;
  end;

  procedure RemoveDefine(X: string);
  var i: integer;
  begin
   i := SearchDefine(X);
   if i <> 0 then
   begin
    Dec(NumDefines);
    for i := i to NumDefines do
     Defines[i] := Defines[i+1];
   end;
  end;

  function SkipCodeUntilDirective: string;
  var c: char;
      i: Byte;
  begin
   i := 1;
   Result := '';

   repeat
    Read(InFile, c);

    if c = #10 then Inc(Line);
    case i of
     1:
      case c of
      '(': i:= 2;
      '{': i:= 5;
      end;
     2:
      if c = '*' then i := 3 else i := 1;
     3:
      if c = '*' then i := 4;
     4:
      if c = ')' then i := 1 else i := 3;
     5:
      if c = '$' then i := 6 else begin i := 0+1; Result:='' end;
     6:
      if UpCase(c) in AllowLabelFirstChars then
      begin
       Result := UpCase(c);
       i := 7;
      end else begin i := 0+1; Result:='' end;
     7:
      if UpCase(c) in AllowLabelChars then
       Result := Result + UpCase(c)
      else if c = '}' then
       i := 9
      else
       i := 8;
     8:
      if c = '}' then i := 9;
    end;

   until i = 9;

  end;

  function SkipCodeUntilElseEndif: boolean;
  var dir: string;
      lvl: integer;
  begin
   lvl := 0;
   repeat
     dir := SkipCodeUntilDirective;
     if dir = 'ENDIF' then begin
      Dec(lvl);
      if lvl < 0 then
       Exit(false);
     end
     else if (lvl = 0) and (dir = 'ELSE') then
      Exit(true)
     else if dir = 'IFDEF' then
      Inc(lvl)
     else if dir = 'IFNDEF' then
      Inc(lvl);
   until false;
  end;

  procedure ReadDirective(d: string);
  var i, k: integer;
      cmd, s, nam: string;
      found: Boolean;

	procedure newMsgUser(Kind: Byte);
	var k: integer;
	begin

		k:=High(msgUser);

		AddToken(Kind, UnitIndex, Line, 1, k);  AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

		omin_spacje(i,d);

		msgUser[k]:=copy(d, i, length(d)-i);
		SetLength(msgUser, k+2);

	end;

  begin

    if UpCase(d[1]) in AllowLabelFirstChars then begin

     i:=1;
     cmd := get_label(i, d);

     if cmd='INCLUDE' then cmd:='I';
     if cmd='RESOURCE' then cmd:='R';

     if cmd = 'WARNING' then newMsgUser(WARNINGTOK) else
     if cmd = 'ERROR' then newMsgUser(ERRORTOK) else
     if cmd = 'INFO' then newMsgUser(INFOTOK) else

     if cmd = 'I' then begin					// {$i filename}
								// {$i+-} iocheck
      if d[i]='+' then begin AddToken(IOCHECKON, UnitIndex, Line, 1, 0); AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0) end else
       if d[i]='-' then begin AddToken(IOCHECKOFF, UnitIndex, Line, 1, 0); AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0) end else
	begin
//	 AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

	 s := LowerCase( get_string(i, d) );

	 if s = '%time%' then begin

	   s:=TimeToStr(Now);

	   AddToken(STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0); Spaces:=0;
	   DefineStaticString(NumTok, s);

	 end else
	 if s = '%date%' then begin

	   s:=DateToStr(Now);

	   AddToken(STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0); Spaces:=0;
	   DefineStaticString(NumTok, s);

	 end else begin

	  nam := FindFile(s, 'include');

	  _line := Line;
	  _uidx := UnitIndex;

	  Line:=1;
	  UnitName[IncludeIndex].Path := nam;
	  UnitIndex := IncludeIndex;
	  inc(IncludeIndex);

	  Tokenize( nam );

	  Line := _line;
	  UnitIndex := _uidx;

	 end;

	end;

     end else

      if (cmd = 'LIBRARYPATH') then begin			// {$librarypath path1;path2;...}
       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       repeat

       s := get_string(i, d);

       found:=false;
       for k:=1 to High(UnitPath)-1 do
	if UnitPath[k] = s then begin found:=true; Break end;

       if not found then begin
	NormalizePath( s );

	k:=High(UnitPath);
	UnitPath[k] := IncludeTrailingPathDelimiter ( s );

	SetLength(UnitPath, k + 2);
       end;

       if d[i] = ';' then
	inc(i)
       else
	Break;

       until d[i] = ';';

       dec(NumTok);
      end else

      if (cmd = 'R') and not (d[i] in ['+','-']) then begin	// {$r filename}
       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       s := LowerCase( get_string(i, d) );
       AddResource( FindFile(s, 'resource') );

       dec(NumTok);
      end else
(*
       if cmd = 'C' then begin					// {$c 6502|65816}
	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

	s := get_digit(i, d);

	val(s,CPUMode, Err);

	if Err > 0 then
	 iError(NumTok, OrdinalExpExpected);

	GetCommonConstType(NumTok, CARDINALTOK, GetValueType(CPUMode));

	dec(NumTok);
       end else
*)
       if cmd = 'F' then begin					// {$f address}
	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

	s := get_digit(i, d);

	val(s,FastMul, Err);

	if Err > 0 then
	 iError(NumTok, OrdinalExpExpected);

	GetCommonConstType(NumTok, BYTETOK, GetValueType(FastMul));

	dec(NumTok);
       end else

       if (cmd = 'IFDEF') or (cmd = 'IFNDEF') then begin
	found := 0 <> SearchDefine( get_label(i, d) );
	if cmd = 'IFNDEF' then found := not found;
	if not found then
	begin
	 if SkipCodeUntilElseEndif then
	  Inc(IfdefLevel);
	end else
	 Inc(IfdefLevel);
       end else
       if cmd = 'ELSE' then begin
	if (IfdefLevel = 0) or SkipCodeUntilElseEndif then
	 Error(NumTok, 'Found $ELSE without $IFXXX');
	if IfdefLevel > 0 then
	 Dec(IfdefLevel)
       end else
       if cmd = 'ENDIF' then begin
	if IfdefLevel = 0 then
	 Error(NumTok, 'Found $ENDIF without $IFXXX')
	else
	 Dec(IfdefLevel)
       end else
       if cmd = 'DEFINE' then begin
	nam := get_label(i, d);
	AddDefine(nam);
       end else
       if cmd = 'UNDEF' then begin
	nam := get_label(i, d);
	RemoveDefine(nam);
       end else
	Error(NumTok, 'Illegal compiler directive $' + cmd + d[i]);

    end;

  end;


  procedure ReadSingleLineComment;
  begin

   while (ch <> #10) do
     Read(InFile, ch);

  end;


  procedure ReadChar(var c: Char);
  var c2: Char;
      dir: Boolean;
      directive: string;
  begin

  Read(InFile, c);

   if c = '(' then begin
    Read(InFile, c2);

    if c2='*' then begin			// Skip comments (*   *)

     repeat
      c2:=c;
      Read(InFile, c);

      if c = #10 then Inc(Line);
     until (c2 = '*') and (c = ')');

     Read(InFile, c);

    end else
     Seek(InFile, FilePos(InFile) - 1);

   end;


   if c = '{' then begin

    dir:=false;
    directive:='';

    Read(InFile, c2);

    if c2='$' then
     dir:=true
    else
     Seek(InFile, FilePos(InFile) - 1);

    repeat					// Skip comments
      Read(InFile, c);

      if dir then directive := directive + c;

      if c <> '}' then
       if AsmFound then SaveAsmBlock(c);

      if c = #10 then Inc(Line);
    until c = '}';

    if dir then ReadDirective(directive);

    Read(InFile, c);

   end else
    if c = '/' then begin
     Read(InFile, c2);

     if c2 = '/' then
      ReadSingleLineComment
     else
      Seek(InFile, FilePos(InFile) - 1);

    end;

  if c = #10 then Inc(Line);			// Increment current line number
  end;


  procedure SafeReadChar(var c: Char);
  begin

  ReadChar(c);

  c := UpCase(c);

  if c=' ' then inc(Spaces);

  if not (c in ['''', ' ', '#', '~', '$', #9, #10, #13, '{', (*'}',*) 'A'..'Z', '_', '0'..'9', '=', '.', ',', ';', '(', ')', '*', '/', '+', '-', ':', '>', '<', '^', '@', '[', ']']) then
    begin
    CloseFile(InFile);
    Error(NumTok, 'Unknown character: ' + ch);
    end;
  end;


  procedure TextInvers;
  var i: integer;
  begin

   for i := 1 to length(Text) do
    if ord(Text[i]) < 128 then
     Text[i] := chr(ord(Text[i])+$80);

  end;


  procedure TextInternal;
  var i: integer;

  function ata2int(const a: byte): byte;
  (*----------------------------------------------------------------------------*)
  (*  zamiana znakow ATASCII na INTERNAL					*)
  (*----------------------------------------------------------------------------*)
  begin
   Result:=a;

   case (a and $7f) of
      0..31: inc(Result,64);
     32..95: dec(Result,32);
   end;

  end;

  begin

   for i := 1 to length(Text) do
    Text[i] := chr(ata2int(ord(Text[i])));

  end;


  procedure ReadNumber;
  var i, k, ln: integer;
  begin

    Num:='';

    if ch='%' then begin		  // binary

      SafeReadChar(ch);

      while ch in ['0', '1'] do
       begin
       Num := Num + ch;
       SafeReadChar(ch);
       end;

       if length(Num)=0 then
	 iError(NumTok, OrdinalExpExpected);

       //remove leading zeros
       i:=1;
       while Num[i]='0' do inc(i);

       tmp:=0;

       ln:=length(Num);

       //do the conversion
       for k:=ln downto i do
	if Num[k]='1' then
	 tmp:=tmp+(1 shl (ln-k));

       Num:=IntToStr(tmp);

    end else

    if ch='$' then begin		  // hexadecimal

      SafeReadChar(ch);

      while ch in AllowDigitChars do
       begin
       Num := Num + ch;
       SafeReadChar(ch);
       end;

       if length(Num)=0 then
	 iError(NumTok, OrdinalExpExpected);

       val('$'+Num, tmp, err);

       Num:=IntToStr(tmp);
    end else

      while ch in ['0'..'9'] do	   // Number suspected
	begin
	Num := Num + ch;
	SafeReadChar(ch);
	end;

  end;


  begin

  AssignFile(InFile, fnam );	      // UnitIndex = 1 main program

  Reset(InFile);

  Text := '';

  try
    while TRUE do
      begin
      OldNumTok := NumTok;

      repeat
	ReadChar(ch);

	if ch= ' ' then inc(Spaces);

      until not (ch in [' ', #9, #10, #13, '{'(*, '}'*)]);    // Skip space, tab, line feed, carriage return, comment braces


      ch := UpCase(ch);


      Num:='';
      if ch in ['0'..'9', '$', '%'] then ReadNumber;

      if Length(Num) > 0 then	     // Number found
	begin
	AddToken(INTNUMBERTOK, UnitIndex, Line, length(Num) + Spaces, StrToInt(Num)); Spaces:=0;

	if ch = '.' then		  // Fractional part suspected
	  begin
	  SafeReadChar(ch);
	  if ch = '.' then
	    Seek(InFile, FilePos(InFile) - 1)   // Range ('..') token
	  else
	    begin			 // Fractional part found
	    Frac := '.';

	    while ch in ['0'..'9'] do
	      begin
	      Frac := Frac + ch;
	      SafeReadChar(ch);
	      end;

	    Tok[NumTok].Kind := FRACNUMBERTOK;
	    Tok[NumTok].FracValue := StrToFloat(Num + Frac);
	    Tok[NumTok].Column := Tok[NumTok-1].Column + length(Num) + length(Frac) + Spaces; Spaces:=0;
	    end;
	  end;

	Num := '';
	Frac := '';
	end;


      if ch in ['A'..'Z', '_'] then	 // Keyword or identifier suspected
	begin
	Text := '';

	err:=0;
	repeat
	  Text := Text + ch;
	  ch2:=ch;
	  SafeReadChar(ch);

	  if (ch='.') and (ch2='.') then begin ch:=#0; Break end;

	  inc(err);
	until not (ch in ['A'..'Z', '_', '0'..'9','.']);

	if Text[length(Text)] = '.' then begin
	 SetLength(Text, length(Text)-1);
	 Seek(InFile, FilePos(InFile) - 2);
	 dec(err);
	end;

	if err > 255 then
	 Error(NumTok, 'Constant strings can''t be longer than 255 chars');

	if Length(Text) > 0 then
	  begin

	 CurToken := GetStandardToken(Text);
	 if CurToken = FLOATTOK then CurToken := SINGLETOK;

	 AddToken(0, UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;

	 if CurToken = ASMTOK then begin

	  Tok[NumTok].Kind := CurToken;

	  AsmFound:=true;

	  repeat
	   ReadChar(ch);

	   if ch=' ' then inc(Spaces);

	  until not (ch in [' ', #9, #10, #13, '{', '}']);    // Skip space, tab, line feed, carriage return, comment braces

	  AsmFound:=false;

	  inc(AsmBlockIndex);

	  if AsmBlockIndex > High(AsmBlock) then begin
	   Error(NumTok, 'Out of resources, ASMBLOCK');

	   halt(2);
	  end;

	 end else begin

	   if CurToken <> 0 then begin	    // Keyword found
	     Tok[NumTok].Kind := CurToken;

	     if CurToken = USESTOK then UsesFound := true;

	   end
	   else begin			     // Identifier found
	     Tok[NumTok].Kind := IDENTTOK;
	     New(Tok[NumTok].Name);
	     Tok[NumTok].Name^ := Text;
	   end;

	 end;

	 Text := '';
	end;

	end;


	if ch in ['''', '#'] then begin

	 Text := '';

	 repeat

	 case ch of

	  '''': begin

		 repeat
		  Read(InFile, ch);
		  if ch = #10 then // Inc(Line);
		   Error(NumTok, 'String exceeds line');

		  if ch <> '''' then
		   Text := Text + ch
		  else begin

		   Read(InFile, ch2);

		   if ch2='''' then begin
		    Text := Text + '''';
		    ch:=#0;
		   end else
		    Seek(InFile, FilePos(InFile) - 1);

		  end;

		 until ch = '''';

		 SafeReadChar(ch);

		 if ch='*' then begin
		  TextInvers;
		  SafeReadChar(ch);
		 end;

		if ch='~' then begin
		 TextInternal;
		 SafeReadChar(ch);
		end;

		end;

	   '#': begin
		 SafeReadChar(ch);

		 Num:='';
		 ReadNumber;

		 if Length(Num)>0 then
		  Text := Text + chr(StrToInt(Num))
		 else
		  Error(NumTok, 'Constant expression expected');

		end;
	 end;

	 until not (ch in ['#', '''']);

	 if ch='*' then begin
	  TextInvers;
	  SafeReadChar(ch);
	 end;

	 if ch='~' then begin
	  TextInternal;
	  SafeReadChar(ch);
	end;

	// if Length(Text) > 0 then
	  if Length(Text) = 1 then begin
	    AddToken(CHARLITERALTOK, UnitIndex, Line, 1 + Spaces, Ord(Text[1])); Spaces:=0;
	  end else begin
	    AddToken(STRINGLITERALTOK, UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;
	    DefineStaticString(NumTok, Text);
	  end;

	 Text := '';

	end;


      if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then begin
	AddToken(GetStandardToken(ch), UnitIndex, Line, 1 + Spaces, 0); Spaces:=0;

	  if UsesFound and (ch = ';') then
	    if UsesOn then ReadUses;
      end;


//      if ch in ['?','!','&','\','|','_','#'] then
//	AddToken(UNKNOWNIDENTTOK, UnitIndex, Line, 1, ord(ch));


      if ch in [':', '>', '<', '.'] then					// Double-character token suspected
	begin
	Line2:=Line;
	SafeReadChar(ch2);
	if (ch2 = '=') or
	   ((ch = '<') and (ch2 = '>')) or
	   ((ch = '.') and (ch2 = '.')) then begin				// Double-character token found
	  AddToken(GetStandardToken(ch + ch2), UnitIndex, Line, 2 + Spaces, 0); Spaces:=0;
	end else
	 if (ch='.') and (ch2 in ['0'..'9']) then begin

	   AddToken(INTNUMBERTOK, UnitIndex, Line, 0, 0);

	   Frac := '0.';		  // Fractional part found

	   while ch2 in ['0'..'9'] do begin
	    Frac := Frac + ch2;
	    SafeReadChar(ch2);
	   end;

	   Tok[NumTok].Kind := FRACNUMBERTOK;
	   Tok[NumTok].FracValue := StrToFloat(Frac);
	   Tok[NumTok].Column := Tok[NumTok-1].Column + length(Frac) + Spaces; Spaces:=0;

	   Frac := '';

	   Seek(InFile, FilePos(InFile) - 1);

	 end else
	  begin
	  Seek(InFile, FilePos(InFile) - 1);
	  Line:=Line2;

	  if ch in [':','>', '<', '.'] then begin				// Single-character token found
	    AddToken(GetStandardToken(ch), UnitIndex, Line, 1 + Spaces, 0); Spaces:=0;
	  end else
	    begin
	    CloseFile(InFile);
	    Error(NumTok, 'Unknown character: ' + ch);
	    end;
	  end;
	end;


      if NumTok = OldNumTok then	 // No token found
	begin
	CloseFile(InFile);
	Error(NumTok, 'Illegal character '''+ch+''' ($'+IntToHex(ord(ch),2)+')');
	end;

      end;// while

  except

   if Text <> '' then
    if Text='END.' then begin
     AddToken(ENDTOK, UnitIndex, Line, 3, 0);
     AddToken(DOTTOK, UnitIndex, Line, 1, 0);
    end else begin
     AddToken(GetStandardToken(Text), UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;
    end;

    CloseFile(InFile);
  end;// try

  end;


procedure TokenizeUnit(a: integer);
// Read input file and get tokens
begin

  UnitIndex := a;

  Line := 1;
  Spaces := 0;

  if UnitIndex > 1 then AddToken(UNITBEGINTOK, UnitIndex, Line, 0, 0);

//  writeln('>',UnitIndex,',',UnitName[UnitIndex].Name);

  Tokenize( UnitName[UnitIndex].Path );

  if UnitIndex > 1 then begin

    CheckTok(NumTok, DOTTOK);
    CheckTok(NumTok - 1, ENDTOK);

    dec(NumTok, 2);

    AddToken(UNITENDTOK, UnitIndex, Line, 0, 0);
  end else
   AddToken(EOFTOK, UnitIndex, Line, 0, 0);

end;


begin
// Token spelling definition

Spelling[CONSTTOK       ] := 'CONST';
Spelling[TYPETOK	] := 'TYPE';
Spelling[VARTOK		] := 'VAR';
Spelling[PROCEDURETOK   ] := 'PROCEDURE';
Spelling[FUNCTIONTOK    ] := 'FUNCTION';
Spelling[OBJECTTOK      ] := 'OBJECT';

Spelling[PROGRAMTOK     ] := 'PROGRAM';
Spelling[UNITTOK	] := 'UNIT';
Spelling[INTERFACETOK   ] := 'INTERFACE';
Spelling[IMPLEMENTATIONTOK] := 'IMPLEMENTATION';
Spelling[INITIALIZATIONTOK] := 'INITIALIZATION';
Spelling[OVERLOADTOK    ] := 'OVERLOAD';
Spelling[ASSEMBLERTOK   ] := 'ASSEMBLER';
Spelling[FORWARDTOK     ] := 'FORWARD';
Spelling[REGISTERTOK    ] := 'REGISTER';
Spelling[INTERRUPTTOK   ] := 'INTERRUPT';

Spelling[ASSIGNFILETOK  ] := 'ASSIGN';
Spelling[RESETTOK       ] := 'RESET';
Spelling[REWRITETOK     ] := 'REWRITE';
Spelling[APPENDTOK      ] := 'APPEND';
Spelling[BLOCKREADTOK   ] := 'BLOCKREAD';
Spelling[BLOCKWRITETOK  ] := 'BLOCKWRITE';
Spelling[CLOSEFILETOK   ] := 'CLOSE';

Spelling[FILETOK	] := 'FILE';
Spelling[SETTOK		] := 'SET';
Spelling[PACKEDTOK      ] := 'PACKED';
Spelling[LABELTOK       ] := 'LABEL';
Spelling[GOTOTOK	] := 'GOTO';
Spelling[INTOK		] := 'IN';
Spelling[RECORDTOK      ] := 'RECORD';
Spelling[CASETOK	] := 'CASE';
Spelling[BEGINTOK       ] := 'BEGIN';
Spelling[ENDTOK		] := 'END';
Spelling[IFTOK		] := 'IF';
Spelling[THENTOK	] := 'THEN';
Spelling[ELSETOK	] := 'ELSE';
Spelling[WHILETOK       ] := 'WHILE';
Spelling[DOTOK		] := 'DO';
Spelling[REPEATTOK      ] := 'REPEAT';
Spelling[UNTILTOK       ] := 'UNTIL';
Spelling[FORTOK		] := 'FOR';
Spelling[TOTOK		] := 'TO';
Spelling[DOWNTOTOK      ] := 'DOWNTO';
Spelling[ASSIGNTOK      ] := ':=';
Spelling[WRITETOK       ] := 'WRITE';
Spelling[WRITELNTOK     ] := 'WRITELN';
Spelling[SIZEOFTOK      ] := 'SIZEOF';
Spelling[LENGTHTOK      ] := 'LENGTH';
Spelling[HIGHTOK	] := 'HIGH';
Spelling[LOWTOK		] := 'LOW';
Spelling[INTTOK		] := 'INT';
Spelling[FRACTOK	] := 'FRAC';
Spelling[TRUNCTOK       ] := 'TRUNC';
Spelling[ROUNDTOK       ] := 'ROUND';
Spelling[ODDTOK		] := 'ODD';

Spelling[READLNTOK      ] := 'READLN';
Spelling[HALTTOK	] := 'HALT';
Spelling[BREAKTOK       ] := 'BREAK';
Spelling[CONTINUETOK    ] := 'CONTINUE';
Spelling[EXITTOK	] := 'EXIT';

Spelling[SUCCTOK	] := 'SUCC';
Spelling[PREDTOK	] := 'PRED';

Spelling[INCTOK		] := 'INC';
Spelling[DECTOK		] := 'DEC';
Spelling[ORDTOK		] := 'ORD';
Spelling[CHRTOK		] := 'CHR';
Spelling[ASMTOK		] := 'ASM';
Spelling[ABSOLUTETOK    ] := 'ABSOLUTE';
Spelling[USESTOK	] := 'USES';
Spelling[LOTOK		] := 'LO';
Spelling[HITOK		] := 'HI';
Spelling[GETINTVECTOK   ] := 'GETINTVEC';
Spelling[SETINTVECTOK   ] := 'SETINTVEC';
Spelling[ARRAYTOK       ] := 'ARRAY';
Spelling[OFTOK		] := 'OF';
Spelling[STRINGTOK      ] := 'STRING';

Spelling[RANGETOK       ] := '..';

Spelling[EQTOK		] := '=';
Spelling[NETOK		] := '<>';
Spelling[LTTOK		] := '<';
Spelling[LETOK		] := '<=';
Spelling[GTTOK		] := '>';
Spelling[GETOK		] := '>=';

Spelling[DOTTOK		] := '.';
Spelling[COMMATOK       ] := ',';
Spelling[SEMICOLONTOK   ] := ';';
Spelling[OPARTOK	] := '(';
Spelling[CPARTOK	] := ')';
Spelling[DEREFERENCETOK ] := '^';
Spelling[ADDRESSTOK     ] := '@';
Spelling[OBRACKETTOK    ] := '[';
Spelling[CBRACKETTOK    ] := ']';
Spelling[COLONTOK       ] := ':';

Spelling[PLUSTOK	] := '+';
Spelling[MINUSTOK       ] := '-';
Spelling[MULTOK		] := '*';
Spelling[DIVTOK		] := '/';
Spelling[IDIVTOK	] := 'DIV';
Spelling[MODTOK		] := 'MOD';
Spelling[SHLTOK		] := 'SHL';
Spelling[SHRTOK		] := 'SHR';
Spelling[ORTOK		] := 'OR';
Spelling[XORTOK		] := 'XOR';
Spelling[ANDTOK		] := 'AND';
Spelling[NOTTOK		] := 'NOT';

Spelling[INTEGERTOK     ] := 'INTEGER';
Spelling[CARDINALTOK    ] := 'CARDINAL';
Spelling[SMALLINTTOK    ] := 'SMALLINT';
Spelling[SHORTINTTOK    ] := 'SHORTINT';
Spelling[WORDTOK	] := 'WORD';
Spelling[BYTETOK	] := 'BYTE';
Spelling[CHARTOK	] := 'CHAR';
Spelling[BOOLEANTOK     ] := 'BOOLEAN';
Spelling[POINTERTOK     ] := 'POINTER';
Spelling[SHORTREALTOK   ] := 'SHORTREAL';
Spelling[REALTOK	] := 'REAL';
Spelling[SINGLETOK      ] := 'SINGLE';

Spelling[FLOATTOK       ] := 'FLOAT';

 AsmFound  := false;
 UsesFound := false;

 IncludeIndex := MAXUNITS;

 if UsesOn then
  TokenizeUnit( 1 )	   // main_file
 else
  for cnt := NumUnits downto 1 do
    if UnitName[cnt].Name <> '' then TokenizeUnit( cnt );

end;// TokenizeProgram



// The following procedures implement machine code patterns
// BX register serves as the expression stack top pointer


procedure asm65separator(a: Boolean = true);
begin
 if a then asm65('');
 asm65('; '+StringOfChar('-',59));
end;


function GetStackVariable(n: byte): TString;
begin

  case n of
   0: Result := ' :STACKORIGIN,x';
   1: Result := ' :STACKORIGIN+STACKWIDTH,x';
   2: Result := ' :STACKORIGIN+STACKWIDTH*2,x';
   3: Result := ' :STACKORIGIN+STACKWIDTH*3,x';
  else
   Result := ''
  end;

end;



procedure a65(code: code65; Value: Int64 = 0; Kind: Byte = CONSTANT; Size: Byte = 4; IdentIndex: integer = 0);
var v: byte;
    svar: string;
begin

  case code of

	 __putEOL: asm65(#9'@printEOL');
	__putCHAR: asm65(#9'jsr @printCHAR');

      __shlAL_CL: asm65(#9'jsr shlEAX_CL.BYTE');
      __shlAX_CL: asm65(#9'jsr shlEAX_CL.WORD');
      __shlEAX_CL: asm65(#9'jsr shlEAX_CL.CARD');

       __shrAL_CL: asm65(#9'jsr shrAL_CL.BYTE');
       __shrAX_CL: asm65(#9'jsr shrAX_CL.WORD');
      __shrEAX_CL: asm65(#9'jsr shrEAX_CL');

	     __je: asm65(#9'beq *+5', '; je');					// =
	    __jne: asm65(#9'bne *+5', '; jne');					// <>
	     __jg: begin asm65(#9'seq', '; jg'); asm65(#9'bcs *+5') end;	// >
	    __jge: asm65(#9'bcs *+5', '; jge');					// >=
	     __jl: asm65(#9'bcc *+5', '; jl');					// <
	    __jle: begin asm65(#9'bcc *+7', '; jle'); asm65(#9'beq *+5') end;	// <=

	  __addBX: asm65(#9'inx', '; add bx, 1');
	  __subBX: asm65(#9'dex', '; sub bx, 1');

       __addAL_CL: asm65(#9'jsr addAL_CL', '; add al, cl');
       __addAX_CX: asm65(#9'jsr addAX_CX', '; add ax, cx');
     __addEAX_ECX: asm65(#9'jsr addEAX_ECX', '; add :eax, :ecx');

       __subAL_CL: asm65(#9'jsr subAL_CL', '; sub al, cl');
       __subAX_CX: asm65(#9'jsr subAX_CX', '; sub ax, cx');
     __subEAX_ECX: asm65(#9'jsr subEAX_ECX', '; sub :eax, :ecx');

	__imulECX: asm65(#9'jsr imulECX', '; imul :ecx');

     __notBOOLEAN: asm65(#9'jsr notBOOLEAN', '; not BOOLEAN');
	 __notaBX: asm65(#9'jsr notaBX');

	 __negaBX: asm65(#9'jsr negaBX');

     __xorEAX_ECX: asm65(#9'jsr xorEAX_ECX', '; xor :eax, :ecx');
       __xorAX_CX: asm65(#9'jsr xorAX_CX', '; xor ax, cx');
       __xorAL_CL: asm65(#9'jsr xorAL_CL', '; xor al, cl');

     __andEAX_ECX: asm65(#9'jsr andEAX_ECX', '; and :eax, :ecx');
       __andAX_CX: asm65(#9'jsr andAX_CX', '; and ax, cx');
       __andAL_CL: asm65(#9'jsr andAL_CL', '; and al, cl');

      __orEAX_ECX: asm65(#9'jsr orEAX_ECX', '; or :eax, :ecx');
	__orAX_CX: asm65(#9'jsr orAX_CX', '; or ax, cx');
	__orAL_CL: asm65(#9'jsr orAL_CL', '; or al, cl');

     __cmpEAX_ECX: asm65(#9'jsr cmpEAX_ECX', '; cmp :eax, :ecx');
       __cmpAX_CX: asm65(#9'jsr cmpEAX_ECX.AX_CX', '; cmp ax, cx');
	 __cmpINT: asm65(#9'jsr cmpINT', '; cmp :eax, :ecx');
    __cmpSHORTINT: asm65(#9'jsr cmpSHORTINT', '; cmp :eax, :ecx');
    __cmpSMALLINT: asm65(#9'jsr cmpSMALLINT', '; cmp :eax, :ecx');

      __cmpSTRING: asm65(#9'jsr cmpSTRING');
 __cmpSTRING2CHAR: asm65(#9'jsr cmpSTRING2CHAR');
 __cmpCHAR2STRING: asm65(#9'jsr cmpCHAR2STRING');

   __movaBX_Value: begin
//		    asm65(#9'ldx sp', '; mov dword ptr [bx], Value');

		    if Kind=VARIABLE then begin		      // @label

		     svar := GetLocalName(IdentIndex);

		     asm65(#9'mva <'+svar+ GetStackVariable(0));
		     asm65(#9'mva >'+svar+ GetStackVariable(1));

		    end else begin

		     // Size:=4;

		     v:=byte(Value);
		     asm65(#9'mva #$'+IntToHex(byte(v), 2)+ GetStackVariable(0));

		     if Size in [2,4] then begin
		       v:=byte(Value shr 8);
		       asm65(#9'mva #$'+IntToHex(v, 2)+ GetStackVariable(1));
		     end;

		     if Size = 4 then begin
		       v:=byte(Value shr 16);
		       asm65(#9'mva #$'+IntToHex(v, 2)+ GetStackVariable(2));

		       v:=byte(Value shr 24);
		       asm65(#9'mva #$'+IntToHex(v, 2)+ GetStackVariable(3));
		     end;

		   end;

   end;

		   end;
end;


procedure Gen;
begin

 if not OutputDisabled then Inc(CodeSize);

end;


procedure ExpandParam(Dest, Source: Byte);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 i:=DataSize[Dest] - DataSize[Source];

 if i>0 then
  case i of
   1: if (Source in SignedOrdinalTypes) then	// to WORD
       asm65(#9'jsr @expandSHORT2SMALL')
      else
       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x', '; expand to WORD');

   2: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD.SMALL')
      else
       asm65(#9'jsr @expandToCARD.WORD');

   3: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD.SHORT')
      else
       asm65(#9'jsr @expandToCARD.BYTE');

  end;

end;


procedure ExpandParam_m1(Dest, Source: Byte);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 i:=DataSize[Dest] - DataSize[Source];

 if i>0 then
  case i of
   1: if (Source in SignedOrdinalTypes) then	// to WORD
       asm65(#9'jsr @expandSHORT2SMALL1')
      else
       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x', '; expand to WORD');

   2: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD1.SMALL')
      else
       asm65(#9'jsr @expandToCARD1.WORD');

   3: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD1.SHORT')
      else
       asm65(#9'jsr @expandToCARD1.BYTE');

  end;

end;


procedure ExpandExpression(var ValType: Byte; RightValType, VarType: Byte);
var m: Byte;
    sign: Boolean;
begin

 if (ValType in IntegerTypes) and (RightValType in IntegerTypes) then begin

    if (DataSize[ValType] < DataSize[RightValType]) and (DataSize[RightValType] >= DataSize[VarType]) then begin
      ExpandParam_m1(RightValType, ValType);		// -1
      ValType:=RightValType;				// przyjmij najwiekszy typ dla operacji
    end else begin

      if VarType in Pointers then VarType:=WORDTOK;

      m:=DataSize[ValType];
      if DataSize[RightValType] > m then m:=DataSize[RightValType];

      if VarType <> 0 then
       if DataSize[VarType] > m then m:=DataSize[VarType];	// okreslamy najwiekszy wspolny typ

      if (ValType in SignedOrdinalTypes) or (RightValType in SignedOrdinalTypes) then
       sign:=true
      else
       sign:=false;

      case m of
       1: if sign then VarType := SHORTINTTOK else VarType := BYTETOK;
       2: if sign then VarType := SMALLINTTOK else VarType := WORDTOK;
      else
	if sign then VarType := INTEGERTOK else VarType := CARDINALTOK
      end;

      ExpandParam_m1(VarType, ValType);
      ExpandParam(VarType, RightValType);

      ValType := VarType;

    end;

 end;

end;


procedure ExpandWord; //(regA: integer = -1);
begin
 Gen;	// Gen($C1); Gen($E0); Gen(16);			// shl :eax, 16
// Gen($66); Gen($C1); Gen($F8); Gen(16);		// sar :eax, 16
end;


procedure ExpandByte;
begin

Gen;							// cbw

ExpandWord;// (0);

end;



function ObjectRecordSize(i: cardinal): integer;
var j: integer;
    FieldType, AllocElementType: Byte;
    NumAllocElements: cardinal;
begin

 Result := 0;

 FieldType := 0;

 if i > 0 then begin

   for j := 1 to Types[i].NumFields do begin

    FieldType := Types[i].Field[j].DataType;
    NumAllocElements := Types[i].Field[j].NumAllocElements;
    AllocElementType :=  Types[i].Field[j].AllocElementType;

    if FieldType <> RECORDTOK then
     inc(Result, DataSize[FieldType]);

   end;

end;

end;


function RecordSize(IdentIndex: integer; field: string =''): integer;
var i, j: integer;
    name, base: TName;
    FieldType, AllocElementType: Byte;
    NumAllocElements: cardinal;
    yes: Boolean;
begin

 if Ident[IdentIndex].NumAllocElements_ > 0 then
  i:=Ident[IdentIndex].NumAllocElements_
 else
  i := Ident[IdentIndex].NumAllocElements;

 Result := 0;

 FieldType := 0;

 yes := false;

 if i > 0 then begin

   for j := 1 to Types[i].NumFields do begin

    FieldType := Types[i].Field[j].DataType;
    NumAllocElements := Types[i].Field[j].NumAllocElements;
    AllocElementType :=  Types[i].Field[j].AllocElementType;

    if Types[i].Field[j].Name = field then begin yes:=true; Break end;

    if FieldType <> RECORDTOK then
     if (FieldType in Pointers) and (NumAllocElements > 0) then
      inc(Result, NumAllocElements * DataSize[AllocElementType])
     else
      inc(Result, DataSize[FieldType]);

   end;

 end else begin

  name:=Ident[IdentIndex].Name;

  base:=copy(name, 1, pos('.',name)-1);

  IdentIndex := GetIdent(base);

  Result:=0;

  for i := 1 to Types[Ident[IdentIndex].NumAllocElements].NumFields do
   if pos(name, base+'.'+Types[Ident[IdentIndex].NumAllocElements].Field[i].Name) > 0 then
    if Types[Ident[IdentIndex].NumAllocElements].Field[i].DataType <> RECORDTOK then begin

     FieldType := Types[Ident[IdentIndex].NumAllocElements].Field[i].DataType;
     NumAllocElements := Types[Ident[IdentIndex].NumAllocElements].Field[i].NumAllocElements;
     AllocElementType := Types[Ident[IdentIndex].NumAllocElements].Field[i].AllocElementType;

     if Types[Ident[IdentIndex].NumAllocElements].Field[i].Name = field then begin yes:=true; Break end;

     if FieldType <> RECORDTOK then
      if (FieldType in Pointers) and (NumAllocElements > 0) then
       inc(Result, NumAllocElements * DataSize[AllocElementType])
      else
       inc(Result, DataSize[FieldType]);

    end;

 end;


 if field <> '' then
  if not yes then
   Result := -1
  else
   Result := Result + FieldType shl 16;

end;


function InfoAboutSize(Size: Byte): string;
begin

 case Size of
  1: Result := ' BYTE / CHAR / SHORTINT / BOOLEAN';
  2: Result := ' WORD / SMALLINT / SHORTREAL / POINTER';
  4: Result := ' CARDINAL / INTEGER / REAL / SINGLE';
 else
  Result := ' unknown'
 end;

end;


procedure GenerateIndexShift(ElementType: Byte; Ofset: Byte = 0);
begin

  asm65('');

  case DataSize[ElementType] of
    2: asm65(#9'm@index2 '+IntToStr(Ofset));
    4: asm65(#9'm@index4 '+IntToStr(Ofset));
  end;

end;

(*
procedure GenerateInterrupt(InterruptNumber: Byte);

 DLI     5  ($200)   Wektor przerwañ NMI listy displejowej
 VBI     6  ($222)   Wektor NMI natychmiastowego VBI
 VBL     7  ($224)   Wektor NMI opóŸnionego VBI
 RESET
 IRQ
 BRK

VDSLST $0200 $E7B3 Wektor przerwañ NMI listy displejowej
VPRCED $0202 $E7B3 Wektor IRQ procedury pryferyjnej
VINTER $0204 $E7B3 Wektor IRQ urz¹dzeñ peryferyjnych
VBREAK $0206 $E7B3 Wektor IRQ programowej instrukcji BRK
VKEYBD $0208 $EFBE Wektor IRQ klawiatury
VSERIN $020A $EB11 Wektor IRQ gotowoœci wejœcia szeregowego
VSEROR $020C $EA90 Wektor IRQ gotowoœci wyjœcia szeregowego
VSEROC $020E $EAD1 Wektor IRQ zakoñczenia przesy³ania szereg.
VTIMR1 $0210 $E7B3 Wektor IRQ licznika 1 uk³adu POKEY
VTIMR2 $0212 $E7B3 Wektor IRQ licznika 2 uk³adu POKEY
VTIMR4 $0214 $E7B3 Wektor IRQ licznika 4 uk³adu POKEY

VIMIRQ $0216 $E6F6 Wektor sterownika przerwañ IRQ
VVBLKI $0222 $E7D1 Wektor NMI natychmiastowego VBI
VVBLKD $0224 $E93E Wektor NMI opóŸnionego VBI
CDTMA1 $0226 $XXXX Adres JSR licznika systemowego 1
CDTMA2 $0228 $XXXX Adres JSR licznika systemowego 2
BRKKEY $0236 $E754 Wektor IRQ klawisza BREAK **

begin

end;// GenerateInterrupt
*)


procedure Push(Value: Int64; IndirectionLevel: Byte; Size: Byte; IdentIndex: integer = 0; par: byte = 0);
var Kind: byte;
    i: integer;
    NumAllocElements: cardinal;
    svar, svara: string;
begin

 if IdentIndex>0 then begin
  Kind := Ident[IdentIndex].Kind;

  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   Size := DataSize[Ident[IdentIndex].AllocElementType];
   NumAllocElements := 0;
  end else
   NumAllocElements := Elements(IdentIndex); //Ident[IdentIndex].NumAllocElements;

  svar := GetLocalName(IdentIndex);

 end else begin
  Kind := CONSTANT;
  NumAllocElements := 0;
  svar := '';
 end;

 svara := svar;
 if pos('.', svar) > 0 then
  svara:=GetLocalName(IdentIndex, 'adr.')
 else
  svara:='adr.'+svar;


 asm65separator;

 asm65(#13#10'; Push'+InfoAboutSize(Size));

case IndirectionLevel of

  ASVALUE:
    begin
    asm65('; as Value $'+IntToHex(Value, 8) + ' ('+IntToStr(Value)+')'+#13#10);

    //Gen($83); Gen($C3); Gen($04);					// add bx, 4
    a65(__addBX);

    Gen; //Gen($C7); Gen($07); GenDWord(Value);				// mov dword ptr [bx], Value
    a65(__movaBX_Value, Value, Kind, Size, IdentIndex);

    end;

  ASPOINTER:
    begin
    asm65('; as Pointer'+#13#10);

    a65(__addBX);
//    asm65(#9'ldx sp');

    case Size of
      1: begin
	 Gen; //Gen(Lo(Value)); Gen(Hi(Value));				// mov al, [Value]

	 asm65(#9'mva '+svar+ GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin
	 Gen; //Gen(Lo(Value)); Gen(Hi(Value));				// mov ax, [Value]

	 asm65(#9'mva '+svar+ GetStackVariable(0));
	 asm65(#9'mva '+svar+'+1' + GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin
	 Gen; //Gen($A1); Gen(Lo(Value)); Gen(Hi(Value));		// mov :eax, [Value]

	 asm65(#9'mva '+svar+ GetStackVariable(0));
	 asm65(#9'mva '+svar+'+1' + GetStackVariable(1));
	 asm65(#9'mva '+svar+'+2' + GetStackVariable(2));
	 asm65(#9'mva '+svar+'+3' + GetStackVariable(3));
	 end;
      end;

//    Gen($83); Gen($C3); Gen($04);					// add bx, 4
//    a65(__addBX);
//    Gen($66); Gen($89); Gen($07);					// mov [bx], :eax
//    a65(__movaBX_EAX);

    end;


  ASPOINTERTORECORD:
    begin
    asm65('; as Pointer to Record'+#13#10);

    Gen; //Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));			// mov bp, [Value]

    a65(__addBX);

    if pos('.', svar) > 0 then
     asm65(#9'lda #'+svar+'-DATAORIGIN')
    else
     asm65(#9'lda #$' + IntToHex(par, 2));

    if pos('.', svar) > 0 then begin
     asm65(#9'add '+copy(svar,1, pos('.', svar)-1));
     asm65(#9'sta'+GetStackVariable(0));
     asm65(#9'lda #$00');
     asm65(#9'adc '+copy(svar,1, pos('.', svar)-1)+'+1');
     asm65(#9'sta'+GetStackVariable(1));
    end else begin
     asm65(#9'add '+svar);
     asm65(#9'sta'+GetStackVariable(0));
     asm65(#9'lda #$00');
     asm65(#9'adc '+svar+'+1');
     asm65(#9'sta'+GetStackVariable(1));
    end;

//    Gen($83); Gen($C3); Gen($04);					// add bx, 4
//    a65(__addBX);
//    Gen($66); Gen($89); Gen($07);					// mov [bx], :eax
//    a65(__movaBX_EAX);
    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer'+#13#10);	   // ???

    Gen; //Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));			// mov bp, [Value]

    a65(__addBX);

    if pos('.', svar) > 0 then
     asm65(#9'mwa '+copy(svar,1, pos('.', svar)-1)+' :bp2')
    else
     asm65(#9'mwa '+svar+' :bp2');

    if pos('.', svar) > 0 then
     asm65(#9'ldy #'+svar+'-DATAORIGIN')
    else
     asm65(#9'ldy #$' + IntToHex(par, 2));

    case Size of
      1: begin
//	 Gen($8A); Gen($46); Gen($00);					// mov al, [bp]

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin
//	 Gen($8B); Gen($46); Gen($00);					// mov ax, [bp]

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin
//	 Gen($66); Gen($8B); Gen($46); Gen($00);			// mov :eax, [bp]

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(3));

	 end;
      end;

//   Gen($83); Gen($C3); Gen($04);					// add bx, 4
//   a65(__addBX);

//   Gen($66); Gen($89); Gen($07);					// mov [bx], :eax
//   a65(__movaBX_EAX);
    end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin'+#13#10);

    Gen; //Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));			// mov bp, [Value]
//    a65(__movBP_aAdr, Value);

//    Gen($8B); Gen($37);						// mov si, [bx]
//    a65(__movSI_aBX);

    case Size of
      1: begin
//	 Gen($8A); Gen($02);						// mov al, [bp + si]
//	 a65(__movAL_BPSI);

	 if (NumAllocElements>256) or (NumAllocElements=1) then begin

	 asm65(#9'lda '+svar);
	 asm65(#9'add :STACKORIGIN,x');
	 asm65(#9'tay');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta :bp+1');
	 asm65(#9'lda (:bp),y');
	 asm65(#9'sta :STACKORIGIN,x');

	 end else begin

	  asm65(#9'ldy :STACKORIGIN,x', '; si');

	  if Ident[IdentIndex].PassMethod = VARPASSING then begin
	   asm65(#9'mwa '+svar+' :bp2');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta'+ GetStackVariable(0));
	  end else
	   asm65(#9'mva '+svara+',y'+ GetStackVariable(0));

	 end;

	 ExpandByte;
	 end;

      2: begin
//	 Gen($C1); Gen($E6); Gen($01);				// shl si, 1
//	 Gen($8B); Gen($02);						// mov ax, [bp + si]
//	 a65(__movAX_BPSI);

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(WORDTOK);

	 asm65('');

	 if (NumAllocElements * 2>256) or (NumAllocElements=1) or (Ident[IdentIndex].PassMethod = VARPASSING) then begin

	  asm65(#9'lda '+svar);						// pushWORD
	  asm65(#9'add :STACKORIGIN,x');
	  asm65(#9'sta :bp2');
	  asm65(#9'lda '+svar+'+1');
	  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :bp2+1');

	  asm65(#9'ldy #$00');

	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta'+ GetStackVariable(0));
	  asm65(#9'iny');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta'+ GetStackVariable(1));

	 end else begin

	  asm65(#9'ldy :STACKORIGIN,x', '; si');
	  asm65(#9'mva '+svara+',y'+ GetStackVariable(0));
	  asm65(#9'mva '+svara+'+1,y'+ GetStackVariable(1));

	 end;

	 ExpandWord;
	 end;

      4: begin
//	 Gen($C1); Gen($E6); Gen($02);				// shl si, 2
//	 Gen($66); Gen($8B); Gen($02);				// mov :eax, [bp + si]

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(CARDINALTOK);

	 asm65('');

	 if (NumAllocElements * 4>256) or (NumAllocElements=1)  or (Ident[IdentIndex].PassMethod = VARPASSING) then begin

	  asm65(#9'lda '+svar);						// pushCARD
	  asm65(#9'add :STACKORIGIN,x');
	  asm65(#9'sta :bp2');
	  asm65(#9'lda '+svar+'+1');
	  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :bp2+1');

	  asm65(#9'ldy #$00');

	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta'+ GetStackVariable(0));
	  asm65(#9'iny');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta'+ GetStackVariable(1));
	  asm65(#9'iny');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta'+ GetStackVariable(2));
	  asm65(#9'iny');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta'+ GetStackVariable(3));

	 end else begin

	  asm65(#9'ldy :STACKORIGIN,x', '; si');
	  asm65(#9'mva '+svara+',y'+ GetStackVariable(0));
	  asm65(#9'mva '+svara+'+1,y'+ GetStackVariable(1));
	  asm65(#9'mva '+svara+'+2,y'+ GetStackVariable(2));
	  asm65(#9'mva '+svara+'+3,y'+ GetStackVariable(3));

	 end;

	 end;
      end;

//    Gen($66); Gen($89); Gen($07);					// mov [bx], :eax
//    a65(__movaBX_EAX);

    end;


ASPOINTERTOARRAYRECORD:
    begin
    asm65('; as Pointer to Array ^Record'+#13#10);

    Gen; //Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));			// mov bp, [Value]

//    a65(__addBX);

    asm65(#9'lda'+GetStackVariable(0));

    if pos('.', svar) > 0 then begin
     asm65(#9'add '+copy(svar,1, pos('.', svar)-1));
     asm65(#9'sta :TMP');
     asm65(#9'lda'+GetStackVariable(1));
     asm65(#9'adc '+copy(svar,1, pos('.', svar)-1)+'+1');
     asm65(#9'sta :TMP+1');
    end else begin
     asm65(#9'add '+svar);
     asm65(#9'sta :TMP');
     asm65(#9'lda '+GetStackVariable(1));
     asm65(#9'adc '+svar+'+1');
     asm65(#9'sta :TMP+1');
    end;

    asm65(#9'ldy #$00');
    asm65(#9'mva (:TMP),y :bp2');
    asm65(#9'iny');
    asm65(#9'mva (:TMP),y :bp2+1');

    if pos('.', svar) > 0 then
     asm65(#9'ldy #'+svar+'-DATAORIGIN')
    else
     asm65(#9'ldy #$' + IntToHex(par, 2));

    case Size of
      1: begin
//	 Gen($8A); Gen($46); Gen($00);				// mov al, [bp]

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin
//	 Gen($8B); Gen($46); Gen($00);				// mov ax, [bp]

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin
//	 Gen($66); Gen($8B); Gen($46); Gen($00);			// mov :eax, [bp]

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(3));

	 end;
      end;

//    Gen($83); Gen($C3); Gen($04);					// add bx, 4
//    a65(__addBX);
//    Gen($66); Gen($89); Gen($07);					// mov [bx], :eax
//    a65(__movaBX_EAX);
    end;

end;// case

end;


procedure StopOptimization(assign: Boolean = false);
begin

  optimize.use := false;
  optimize.assign := assign;

  if High(OptimizeBuf) > 0 then asm65('');

end;


procedure StartOptimization(i: integer);
begin

  StopOptimization;

  optimize.assign := false;
  optimize.use := true;
  optimize.unitIndex := Tok[i].UnitIndex;
  optimize.line:= Tok[i].Line;
end;


procedure SaveToSystemStack(cnt: integer);
begin

 asm65(#13#10'; Save conditional expression');		//at expression stack top onto the system :STACK');

 Gen; Gen; Gen;						// push dword ptr [bx]

 asm65(#9'.ifdef IFTMP_'+IntToStr(cnt));
 asm65(#9'lda :STACKORIGIN,x');
 asm65(#9'sta IFTMP_'+IntToStr(cnt));
 asm65(#9'eif');

end;


procedure RestoreFromSystemStack(cnt: integer);
begin

 asm65(#13#10'; Restore conditional expression');

 Gen; Gen; Gen;						// add bx, 4
// a65(__addBX);

 asm65(#9'lda IFTMP_'+IntToStr(Cnt));

 DefineIdent(NumTok, 'IFTMP_'+IntToStr(Cnt), VARIABLE, BOOLEANTOK, 0, 0, 0);
 GetIdent('IFTMP_'+IntToStr(Cnt));		       // zapobiega informacji o nieuzywaniu tej zmiennej

end;


procedure RemoveFromSystemStack;
begin
Gen; Gen;						// pop :eax
end;


procedure GenerateFileOpen(IdentIndex: Integer; Code: ioCode; NumParams: integer = 0);
begin

 ResetOpty;

 asm65('');
 asm65(#9'txa:pha');

 if IOCheck then
  asm65(#9'sec')
 else
  asm65(#9'clc');

 case Code of

   ioOpenRead,
   ioOpenWrite: asm65(#9'@openfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code)));

   ioFileMode: asm65(#9'@openfile '+Ident[IdentIndex].Name+', MAIN.SYSTEM.FileMode');

       ioRead,
       ioWrite: if NumParams = 3 then
		  asm65(#9'@readfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code) or $80))
		else
		  asm65(#9'@readfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code)));

       ioClose: asm65(#9'@closefile '+Ident[IdentIndex].Name);

//   ioOpenAppend: ;
 end;

 asm65(#9'pla:tax');
 asm65('');

end;


procedure GenerateIncOperation(IndirectionLevel: Byte; ExpressionType: Byte; Down: Boolean; IdentIndex: integer);
var b,c, svar, svara: string;
    NumAllocElements: cardinal;
begin

 svar := GetLocalName(IdentIndex);

 NumAllocElements := Elements(IdentIndex);

 svara := svar;
 if pos('.', svar) > 0 then
  svara:=GetLocalName(IdentIndex, 'adr.')
 else
  svara:='adr.'+svar;


 if Down then begin
  asm65(#13#10'; Dec(var X [ ; N: int ] ) -> '+InfoAboutToken(ExpressionType));

//  a:='sbb';
  b:='sub';
  c:='sbc';

 end else begin
  asm65(#13#10'; Inc(var X [ ; N: int ] ) -> '+InfoAboutToken(ExpressionType));

//  a:='adb';
  b:='add';
  c:='adc';

 end;

 case IndirectionLevel of

  ASPOINTER:
       begin

       asm65('; as Pointer'#13#10);

	     case DataSize[ExpressionType] of
	      1: begin
		  asm65(#9'lda '+svar);
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta '+svar);
		 end;

	      2: begin
		  asm65(#9'lda '+svar);
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta '+svar);

		  asm65(#9'lda '+svar+'+1');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta '+svar+'+1');
		 end;

	      4: begin
		  asm65(#9'lda '+svar);
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta '+svar);

		  asm65(#9'lda '+svar+'+1');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta '+svar+'+1');

		  asm65(#9'lda '+svar+'+2');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta '+svar+'+2');

		  asm65(#9'lda '+svar+'+3');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta '+svar+'+3');
	      end;

	     end;

       end;


  ASPOINTERTOPOINTER:
	begin

	   asm65('; as Pointer To Pointer'#13#10);

	   if pos('.', svar) > 0 then
	    asm65(#9'mwa '+copy(svar, 1, pos('.', svar)-1)+' :bp2')
	   else
	    asm65(#9'mwa '+svar+' :bp2');

	   if pos('.', svar) > 0 then
	    asm65(#9'ldy #'+svar+'-DATAORIGIN')
	   else
	    asm65(#9'ldy #$00');

	     case DataSize[ExpressionType] of
	      1: begin
		  asm65('');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      2: begin
		  asm65('');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      4: begin
		  asm65('');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta (:bp2),y');
	      end;

	     end;
	end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
	  begin

	  asm65('; as Pointer To Array Origin'#13#10);

	     case DataSize[ExpressionType] of
	      1: begin

		  if (NumAllocElements > 256) or (NumAllocElements = 1) then begin

		   asm65(#9'lda '+svar);
		   asm65(#9'add :STACKORIGIN-1,x');
		   asm65(#9'tay');

		   asm65(#9'lda '+svar+'+1');
		   asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		   asm65(#9'sta :bp+1');

		   asm65('');
		   asm65(#9'lda (:bp),y');
		   asm65(#9+b+' :STACKORIGIN,x');
		   asm65(#9'sta (:bp),y');

		  end else begin

		   asm65(#9'ldy :STACKORIGIN-1,x');

		   if Ident[IdentIndex].PassMethod = VARPASSING then begin
		    asm65(#9'mwa '+svar+' :bp2');
		    asm65(#9'lda (:bp2),y');
		    asm65(#9+b+' :STACKORIGIN,x');
		    asm65(#9'sta (:bp2),y');
		   end else begin
		    asm65(#9'lda '+svara+',y');
		    asm65(#9+b+' :STACKORIGIN,x');
		    asm65(#9'sta '+svara+',y');
		   end;

		  end;

		 end;

	      2: begin
		  asm65(#9'lda '+svar);
		  asm65(#9'add :STACKORIGIN-1,x');
		  asm65(#9'sta :bp2');

		  asm65(#9'lda '+svar+'+1');
		  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		  asm65(#9'sta :bp2+1');

		  asm65(#9'ldy #$00');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      4: begin
		  asm65(#9'lda '+svar);
		  asm65(#9'add :STACKORIGIN-1,x');
		  asm65(#9'sta :bp2');

		  asm65(#9'lda '+svar+'+1');
		  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		  asm65(#9'sta :bp2+1');

		  asm65(#9'ldy #$00');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	     end;

	   a65(__subBX);

	  end;

 end;

 a65(__subBX);
end;


procedure GenerateAssignment(IndirectionLevel: Byte; Size: Byte; IdentIndex: integer; Param: string = ''; ParamY: string = '');
var NumAllocElements: cardinal;
    svar, svara: string;
begin

 if IdentIndex > 0 then begin

  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   Size := DataSize[Ident[IdentIndex].AllocElementType];
   NumAllocElements := 0;
  end else
   NumAllocElements := Elements(IdentIndex);	//Ident[IdentIndex].NumAllocElements;

  svar := GetLocalName(IdentIndex);
 end else begin
  svar := Param;
  NumAllocElements := 0;
 end;

 svara := svar;

 if pos('.', svar) > 0 then
  svara:=GetLocalName(IdentIndex, 'adr.')
 else
  svara:='adr.'+svar;


 asm65separator;

 asm65(#13#10'; Generate Assignment for'+InfoAboutSize(Size));

 Gen; Gen; Gen;					// mov :eax, [bx]

case IndirectionLevel of

  ASPOINTERTOARRAYRECORD:
    begin
    asm65('; as Pointer to Array ^Record');

    if pos('.', svar) > 0 then begin
     asm65(#9'lda '+copy(svar, 1, pos('.', svar)-1));
     asm65(#9'add :STACKORIGIN-1,x');
     asm65(#9'sta :TMP');
     asm65(#9'lda '+copy(svar, 1, pos('.', svar)-1)+'+1');
     asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'sta :TMP+1');
    end else begin
     asm65(#9'lda '+svar);
     asm65(#9'add :STACKORIGIN-1,x');
     asm65(#9'sta :TMP');
     asm65(#9'lda '+svar+'+1');
     asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'sta :TMP+1');
    end;

    asm65(#9'ldy #$00');
    asm65(#9'mva (:TMP),y :bp2');
    asm65(#9'iny');
    asm65(#9'mva (:TMP),y :bp2+1');

    if ParamY<>'' then
     asm65(#9'ldy #'+ParamY)
    else
     if pos('.', svar) > 0 then
      asm65(#9'ldy #'+svar+'-DATAORIGIN')
     else
      asm65(#9'ldy #$00');

    case Size of
      1: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 end;

      2: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');
	 end;

      4: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	 asm65(#9'sta (:bp2),y');
	 end;

      end;

     a65(__subBX);
     a65(__subBX);

    end;

{
 ASPOINTERTOARRAYRECORDORIGIN:
    begin
    asm65('; as Pointer to Array Record Origin');

    case Size of

      2: begin

	 if (NumAllocElements * 2 > 256) or (NumAllocElements = 1) then begin

	 asm65(#9'lda '+svar);							// pullWORD
	 asm65(#9'add :STACKORIGIN-1,x');
	 asm65(#9'sta :bp2');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	 asm65(#9'sta :bp2+1');
	 asm65(#9'ldy #$00');
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');

	 end else begin

	 asm65(#9'ldy :STACKORIGIN-1,x','; si');

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  asm65(#9'mwa '+svar+' :bp2');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp2),y');
	  asm65(#9'iny');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta (:bp2),y');

	 end else begin

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta :edx');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :edx+1');
	  asm65(#9'lda '+svara+',y');
	  asm65(#9'sta :ecx');
	  asm65(#9'lda '+svara+'+1,y');
	  asm65(#9'sta :ecx+1');

	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);

	 end;

      end;

    end;
}

  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');

    case Size of
      1: begin

	 if NumAllocElements = 0 then begin

	 asm65(#9'lda '+svar);
	 asm65(#9'add :STACKORIGIN-1,x');
	 asm65(#9'tay');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc #0','; si+1');
	 asm65(#9'sta :bp+1');
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp),y');

	 end else

	 if (NumAllocElements > 256) or (NumAllocElements = 1) then begin

	 asm65(#9'lda '+svar);
	 asm65(#9'add :STACKORIGIN-1,x');
	 asm65(#9'tay');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	 asm65(#9'sta :bp+1');
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp),y');

	 end else begin

	 asm65(#9'ldy :STACKORIGIN-1,x','; si');

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin
	  asm65(#9'mwa '+svar+' :bp2');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp2),y');
	 end else begin
	  asm65(#9'mva :STACKORIGIN,x '+svara+',y');

//	  asm65(#9'lda :STACKORIGIN,x');
//	  asm65(#9'sta '+svara+',y');
	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);
	 end;

      2: begin

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(WORDTOK, 1);

	 if (NumAllocElements * 2 > 256) or (NumAllocElements = 1) then begin

	 asm65(#9'lda '+svar);							// pullWORD
	 asm65(#9'add :STACKORIGIN-1,x');
	 asm65(#9'sta :bp2');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	 asm65(#9'sta :bp2+1');
	 asm65(#9'ldy #$00');
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');

	 end else begin

	 asm65(#9'ldy :STACKORIGIN-1,x','; si');

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  asm65(#9'mwa '+svar+' :bp2');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp2),y');
	  asm65(#9'iny');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta (:bp2),y');

	 end else begin

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta '+svara+',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta '+svara+'+1,y');

	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);

	 end;

      4: begin

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	  GenerateIndexShift(CARDINALTOK, 1);

	 if (NumAllocElements * 4 > 256) or (NumAllocElements = 1) then begin

	 asm65(#9'lda '+svar);							// pullCARD
	 asm65(#9'add :STACKORIGIN-1,x');
	 asm65(#9'sta :bp2');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	 asm65(#9'sta :bp2+1');
	 asm65(#9'ldy #$00');
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	 asm65(#9'sta (:bp2),y');

	 end else begin

	 asm65(#9'ldy :STACKORIGIN-1,x','; si');

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  asm65(#9'mwa '+svar+' :bp2');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp2),y');
	  asm65(#9'iny');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta (:bp2),y');
	  asm65(#9'iny');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	  asm65(#9'sta (:bp2),y');
	  asm65(#9'iny');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	  asm65(#9'sta (:bp2),y');

	 end else begin

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta '+svara+',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta '+svara+'+1,y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	  asm65(#9'sta '+svara+'+2,y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	  asm65(#9'sta '+svara+'+3,y');

	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);

	 end;
      end;
    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer');		// ???

//    Gen; Gen; Gen;				// mov :eax, [bx]

    if pos('.', svar) > 0 then
     asm65(#9'mwa '+copy(svar, 1, pos('.', svar)-1)+' :bp2')
    else
     asm65(#9'mwa '+svar+' :bp2');

    if ParamY<>'' then
     asm65(#9'ldy #'+ParamY)
    else
     if pos('.', svar) > 0 then
      asm65(#9'ldy #'+svar+'-DATAORIGIN')
     else
      asm65(#9'ldy #$00');

    case Size of
      1: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 end;

      2: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');
	 end;

      4: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	 asm65(#9'sta (:bp2),y');
	 end;

      end;

     a65(__subBX);

    end;


  ASPOINTER:
    begin
    asm65('; as Pointer');

//    Gen; Gen; Gen;						// mov :eax, [bx]

     case Size of
      1: begin
	 asm65(#9'mva :STACKORIGIN,x '+svar);
	 end;

      2: begin
	 asm65(#9'mva :STACKORIGIN,x '+svar);
	 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x '+svar+'+1');
	 end;

      4: begin
	 asm65(#9'mva :STACKORIGIN,x '+svar);
	 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x '+svar+'+1');
	 asm65(#9'mva :STACKORIGIN+STACKWIDTH*2,x '+svar+'+2');
	 asm65(#9'mva :STACKORIGIN+STACKWIDTH*3,x '+svar+'+3');
	 end;
      end;

     a65(__subBX);

    end;

end;// case

StopOptimization(true);

end;


procedure GenerateCall(IdentIndex: integer);
var
  Name: string;
begin

 ResetOpty;

 Name := GetLocalName(IdentIndex);

 Gen;									// call Entry

 asm65('');

 if Ident[IdentIndex].isOverload then
  asm65(#9'jsr '+Name+'_'+IntToHex(Ident[IdentIndex].Value, 4), '; call Entry'#13#10)
 else
  asm65(#9'jsr '+Name, '; call Entry'#13#10);

 if Ident[IdentIndex].Kind <> FUNCTIONTOK then StopOptimization;

end;


procedure GenerateReturn(IsFunction, isInt: Boolean);
begin
 Gen;									// ret

 if not isInt then
  if not IsFunction then begin
   asm65('');
   asm65('@exit');

   asm65(#9'.ifdef @new');
   asm65(#9'@FreeMem #@VarData #@VarDataSize');
   asm65(#9'eif');
  end;

 if isInt then
  asm65(#9'rti', '; ret')
 else
  asm65(#9'rts', '; ret');

 asm65('.endl');
end;


procedure GenerateIfThenCondition;
begin
asm65(#13#10'; If Then Condition');

Gen; Gen; Gen;								// mov :eax, [bx]

a65(__subBX);
asm65(#9'lda :STACKORIGIN+1,x');

//Gen($75); Gen($03);							// jne +3
a65(__jne);
end;


procedure GenerateElseCondition;
begin
asm65(#13#10'; else condition');

Gen; Gen; Gen;								// mov :eax, [bx]

//Gen($74); Gen($03);							// je  +3
a65(__je);

end;


procedure GenerateWhileDoCondition;
begin
GenerateIfThenCondition;
end;


procedure GenerateRepeatUntilCondition;
begin
GenerateIfThenCondition;
end;


procedure GenerateRelationOperation(rel: Byte; ValType: Byte);
begin

 case rel of
  EQTOK:
    begin
    Gen; Gen;								// je +3   =
    asm65(#9'beq @+', '; =');
    end;

  NETOK, 0:
    begin
    Gen; Gen;								// jne +3  <>
    asm65(#9'bne @+', '; <>');
    end;

  GTTOK:
    begin
    Gen; Gen;								// jg +3   >

    asm65(#9'seq', '; >');

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+')
    else
     asm65(#9'bcs @+');

    end;

  GETOK:
    begin
    Gen; Gen;								// jge +3  >=

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+', '; >=')
    else
     asm65(#9'bcs @+', '; >=');

    end;

  LTTOK:
    begin
    Gen; Gen;								// jl +3   <

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bmi @+', '; <')
    else
     asm65(#9'bcc @+', '; <');

    end;

  LETOK:
    begin
    Gen; Gen;								// jle +3  <=

    if ValType in (RealTypes + SignedOrdinalTypes) then begin
     asm65(#9'bmi @+', '; <=');
     asm65(#9'beq @+');
    end else begin
     asm65(#9'bcc @+', '; <=');
     asm65(#9'beq @+');
    end;

    end;
 end;// case

end;


procedure SignedTest(ValType: Byte; var svar: string);
begin
       asm65(#9'bne L4');

       case ValType of

	SMALLINTTOK:
	   begin
	    asm65(#9'lda '+svar);
	    asm65(#9'cmp :STACKORIGIN+1,x');
	   end;

	INTEGERTOK:
	   begin
	    asm65(#9'lda '+svar+'+2');
	    asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
	    asm65(#9'bne L1');

	    asm65(#9'lda '+svar+'+1');
	    asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
	    asm65(#9'bne L1');

	    asm65(#9'lda '+svar);
	    asm65(#9'cmp :STACKORIGIN+1,x');
	   end;
       end;

       asm65('L1'#9'beq L5');
       asm65(#9'bcs L3');
       asm65(#9'lda #$FF');
       asm65(#9'jmp L5');
       asm65('L3'#9'lda #$01');
       asm65(#9'jmp L5');
       asm65('L4'#9'bvc L5');
       asm65(#9'eor #$FF');
       asm65(#9'ora #$01');
       asm65('L5');
       asm65(#9'.ENDL');
end;


procedure GenerateForToDoCondition(CounterSize: Byte; Down: Boolean; IdentIndex: integer);
var svar: string;
    ValType: Byte;
begin

svar    := GetLocalName(IdentIndex);
ValType := Ident[IdentIndex].DataType;

asm65(';'+InfoAboutSize(CounterSize));

Gen; Gen; Gen;							// mov :ecx, [bx]

a65(__subBX);

case CounterSize of

  1: begin
     ExpandByte;

     if ValType = SHORTINTTOK then begin
								// @cmpFor_SHORTINT
       asm65(#9'.LOCAL', '; @cmpFor_SHORTINT');
       asm65(#9'lda '+svar);
       asm65(#9'clv:sec');
       asm65(#9'sbc :STACKORIGIN+1,x');

       SignedTest(ValType, svar);
     end else begin
      asm65(#9'lda '+svar);
      asm65(#9'cmp :STACKORIGIN+1,x');
     end;

     end;

  2: begin
     ExpandWord;

     if ValType = SMALLINTTOK then begin
								// @cmpFor_SMALLINT
       asm65(#9'.LOCAL', '; @cmpFor_SMALLINT');
       asm65(#9'lda '+svar+'+1');
       asm65(#9'clv:sec');
       asm65(#9'sbc :STACKORIGIN+1+STACKWIDTH,x');

       SignedTest(ValType, svar);
     end else begin
//      asm65(#9'@cmpFor_WORD #'+svar);
      asm65(#9'lda '+svar+'+1');
      asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar);
      asm65(#9'cmp :STACKORIGIN+1,x');
      asm65('@');
     end;

     end;

  4: begin

     if ValType = INTEGERTOK then begin
								// @cmpFor_INT
       asm65(#9'.LOCAL', '; @cmpFor_INT');
       asm65(#9'lda '+svar+'+3');
       asm65(#9'clv:sec');
       asm65(#9'sbc :STACKORIGIN+1+STACKWIDTH*3,x');

       SignedTest(ValType, svar);
     end else begin
//      asm65(#9'@cmpFor_CARD #'+svar);
      asm65(#9'lda '+svar+'+3');
      asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*3,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar+'+2');
      asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar+'+1');
      asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar);
      asm65(#9'cmp :STACKORIGIN+1,x');
      asm65('@');
     end;

    end;

  end;


Gen; Gen; Gen;							// cmp :eax, :ecx

if Down then
  begin

  if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then
   asm65(#9'bpl *+5', '; >=')
  else
   asm65(#9'bcs *+5', '; >=');

  end

else
  begin

  if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then begin
   asm65(#9'bmi *+7', '; <=');
   asm65(#9'beq *+5');
  end else begin
   asm65(#9'bcc *+7', '; <=');
   asm65(#9'beq *+5');
  end;

  end;

end;


procedure GenerateIfThenProlog;
begin
Inc(CodePosStackTop);
CodePosStack[CodePosStackTop] := CodeSize;

Gen;								// nop   ; jump to the IF..THEN block end will be inserted here
Gen;								// nop
Gen;								// nop

asm65(#9'jmp l_'+IntToHex(CodeSize, 4));

end;


procedure GenerateCaseProlog;
begin
asm65(#13#10'; GenerateCaseProlog');

Gen; Gen;							// pop :ecx	   ; CASE switch value
Gen; Gen;							// mov al, 00h       ; initial flag mask

a65(__subBX);

end;


procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: Byte);
begin
asm65(#13#10'; GenerateCaseEqualityCheck');

Gen; Gen;	//Gen($F9); GenDWord(Value);			// cmp :ecx, Value

case DataSize[SelectorType] of
 1: begin
     asm65(#9'lda :STACKORIGIN+1,x');

     if Value <> 0 then asm65(#9'cmp #'+IntToStr(byte(Value)));
    end;

// 2: asm65(#9'cpw :STACKORIGIN,x #$'+IntToHex(Value, 4));
// 4: asm65(#9'cpd :STACKORIGIN,x #$'+IntToHex(Value, 4));
end;

asm65(#9'beq @+');

end;


procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: Byte);
begin
Gen; Gen;	//Gen($F9); GenDWord(Value1);			// cmp :ecx, Value1

 if (SelectorType in [BYTETOK, CHARTOK]) and (Value1 >= 0) and (Value2 >= 0) then begin

   asm65('');
   asm65(#9'lda :STACKORIGIN+1,x');
   asm65(#9'clc', '; clear carry for add');
   asm65(#9'adc #$FF-'+IntToStr(Value2), '; make m = $FF');
   asm65(#9'adc #'+IntToStr(Value2)+'-'+IntToStr(Value1)+'+1', '; carry set if in range n to m');
   asm65(#9'bcs @+');

 end else begin

  case DataSize[SelectorType] of
   1: begin
       asm65(#9'lda :STACKORIGIN+1,x');
       asm65(#9'cmp #'+IntToStr(byte(Value1)));
      end;

  end;

  GenerateRelationOperation(LTTOK, SelectorType);

  case DataSize[SelectorType] of
   1: begin
//       asm65(#9'lda :STACKORIGIN+1,x');
       asm65(#9'cmp #'+IntToStr(byte(Value2)));
      end;

  end;

  GenerateRelationOperation(GTTOK, SelectorType);

  asm65(#9'jmp *+6');
  asm65('@');

 end;

end;


procedure GenerateCaseStatementProlog(equality: Boolean);
begin
//asm65(#13#10'; GenerateCaseStatementProlog');

//Gen; Gen;							// and al, 40h    ; test zero flag

GenerateIfThenProlog;
{
Inc(CodePosStackTop);
CodePosStack[CodePosStackTop] := CodeSize;

Gen;								// nop   ; jump to the IF..THEN block end will be inserted here
Gen;								// nop
Gen;								// nop

if equality then
 asm65(#9'jne l_'+IntToHex(CodeSize, 4))
else
 asm65(#9'jcc l_'+IntToHex(CodeSize, 4));
}
end;


procedure GenerateIfElseEpilog;
begin
resetOpty;

asm65(#13#10'; GenerateIfElseEpilog');

Dec(CodePosStackTop);

Gen;								// jmp (IF..THEN block end)
end;


procedure GenerateCaseStatementEpilog(cnt: integer);
var StoredCodeSize: Integer;
begin
asm65(#13#10'; GenerateCaseStatementEpilog');

asm65(#9'jmp a_'+IntToHex(cnt,4));

StoredCodeSize := CodeSize;

Gen;								// nop   ; jump to the CASE block end will be inserted here
Gen;								// nop
Gen;								// nop

asm65('l_'+IntToHex(CodePosStack[CodePosStackTop] + 3, 4));

GenerateIfElseEpilog;

Inc(CodePosStackTop);
CodePosStack[CodePosStackTop] := StoredCodeSize;

end;


procedure GenerateCaseEpilog(NumCaseStatements: Integer; cnt: integer);
var i: Integer;
begin

asm65(#13#10'; GenerateCaseEpilog');

for i := 1 to NumCaseStatements do GenerateIfElseEpilog;

asm65('a_'+IntToHex(cnt, 4));

end;



procedure GenerateAsmLabels(l: integer);
var i: integer;
    ok: Boolean;
begin

if not OutputDisabled then

 if Pass = CODEGENERATIONPASS then begin

   ok:=false;
   for i:=0 to High(AsmLabels)-1 do
     if AsmLabels[i]=l then begin ok:=true; Break end;

   if not ok then begin
    i:=High(AsmLabels);
    AsmLabels[i] := l;

    SetLength(AsmLabels, i+2);

    asm65('l_'+IntToHex(l, 4));
  end;

 end;

end;


procedure GenerateIfThenEpilog;
var
  CodePos: Word;
begin

  ResetOpty;

//  asm65(#13#10'; IfThenEpilog');

  CodePos := CodePosStack[CodePosStackTop];
  Dec(CodePosStackTop);

  GenerateAsmLabels(CodePos+3);
end;


procedure GenerateWhileDoProlog;
begin
  GenerateIfThenProlog;
end;


procedure GenerateWhileDoEpilog;
var
  CodePos, ReturnPos: Word;
begin
//asm65(#13#10'; WhileDoEpilog');

CodePos := CodePosStack[CodePosStackTop];
Dec(CodePosStackTop);

ReturnPos := CodePosStack[CodePosStackTop];
Dec(CodePosStackTop);

Gen;								// jmp ReturnPos

asm65(#9'jmp l_'+IntToHex(ReturnPos, 4));

//asm65('l_'+IntToHex(CodePos+3, 4));
GenerateAsmLabels(CodePos+3);

end;


procedure GenerateRepeatUntilProlog;
begin

 Inc(CodePosStackTop);
 CodePosStack[CodePosStackTop] := CodeSize;

 GenerateAsmLabels(CodeSize);

end;


procedure GenerateRepeatUntilEpilog;
var
  ReturnPos: Word;
begin

 ResetOpty;

 ReturnPos := CodePosStack[CodePosStackTop];
 Dec(CodePosStackTop);

 Gen;

 asm65(#9'jmp l_'+IntToHex(ReturnPos , 4));

end;


procedure GenerateForToDoProlog;
begin

 GenerateWhileDoProlog;

end;


procedure GenerateForToDoEpilog (CounterSize: Byte; Down: Boolean; IdentIndex: integer = 0; Epilog: Boolean = true);
var svar: string;
    ValType: Byte;
begin

svar    := GetLocalName(IdentIndex);
ValType := Ident[IdentIndex].DataType;

case CounterSize of
  1: begin
     Gen;						// ... byte ptr ...
     end;
  2: begin
     Gen;						// ... word ptr ...
     end;
  4: begin
     Gen; Gen;						// ... dword ptr ...
     end;
  end;

if Down then begin
  Gen;							 // dec ...

  case CounterSize of
   1: asm65(#9'dec '+svar, '; dec ptr byte [CounterAddress]');
   2: asm65(#9'dew '+svar, '; dec ptr word [CounterAddress]');
   4: asm65(#9'ded '+svar, '; dec ptr dword [CounterAddress]');
  end;

end else begin
  Gen;							// inc ...

  case CounterSize of
   1: asm65(#9'inc '+svar, '; inc ptr byte [CounterAddress]');
   2: asm65(#9'inw '+svar, '; inc ptr word [CounterAddress]');
   4: asm65(#9'ind '+svar, '; inc ptr dword [CounterAddress]');
  end;

end;

Gen; Gen;						// ... [CounterAddress]

if Epilog then begin

 if not (ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK]) then
 if Down then begin					// for label = exp to max(type)

  case CounterSize of
   1: begin
       asm65('');
       asm65(#9'lda '+svar);
       asm65(#9'cmp #$ff');
       asm65(#9'seq');
      end;

   2: begin
       asm65('');
       asm65(#9'lda '+svar);
       asm65(#9'and '+svar+'+1');
       asm65(#9'cmp #$ff');
       asm65(#9'seq');
      end;

   4: begin
       asm65('');
       asm65(#9'lda '+svar);
       asm65(#9'and '+svar+'+1');
       asm65(#9'and '+svar+'+2');
       asm65(#9'and '+svar+'+3');
       asm65(#9'cmp #$ff');
       asm65(#9'seq');
      end;
  end;

 end else begin

  asm65('');
  asm65(#9'seq');

 end;

 GenerateWhileDoEpilog;
end;

end;


function CompilerTitle: string;
begin

 Result := 'Mad Pascal Compiler version '+title+' ['+{$I %DATE%}+'] for 6502';

end;


procedure GenerateProgramProlog;
var i, j: Integer;
    tmp: Boolean;
    a: string;
begin

if Pass = CODEGENERATIONPASS then begin

 tmp := optimize.use;
 optimize.use := false;

 Gen;

 asm65separator(false);
 asm65('; ' + CompilerTitle);
 asm65separator(false);
 asm65('');

// asm65(':STACKORIGIN'#9'= $98', '; zp free = $d8..$ff');
 asm65('STACKWIDTH'#9'= 16');

 asm65('CODEORIGIN'#9'= $'+IntToHex(CODEORIGIN_Atari, 4));

 asm65('');

// asm65('FRACBITS'#9'= '+IntToStr(FRACBITS));
// asm65('FRACMASK'#9'= '+IntToStr(TWOPOWERFRACBITS-1));
 asm65('TRUE'#9#9'= '+IntToStr(Ident[GetIdent('TRUE')].Value));
 asm65('FALSE'#9#9'= '+IntToStr(Ident[GetIdent('FALSE')].Value));

// asm65('');
// asm65(#9'.define :STACK0 inx:STA :STACKORIGIN,x');
// asm65(#9'.define :STACK1 STA :STACKORIGIN+STACkWIDTH,x');
// asm65(#9'.define :STACK2 STA :STACKORIGIN+STACkWIDTH*2,x');
// asm65(#9'.define :STACK3 STA :STACKORIGIN+STACkWIDTH*3,x');
// asm65(#9'.define @param .print %%1');

 asm65separator;
 asm65('');

 if ZPAGE_Atari > 0 then
  asm65(#9'org $'+IntToHex(ZPAGE_Atari, 2))
 else
  asm65(#9'org $80');

 asm65('');
 asm65('fxptr'#9'.ds 2');
 asm65('');

 asm65('eax'#9'.ds 4', ';8 bytes (aex + edx) -> divREAL');
 asm65('edx'#9'.ds 4');

 asm65('ecx'#9'.ds 4');

 asm65('bp'#9'.ds 2');
 asm65('bp2'#9'.ds 2');

 asm65('');

 asm65('ztmp');
 asm65('ztmp8'#9'.ds 1');
 asm65('ztmp9'#9'.ds 1');
 asm65('ztmp10'#9'.ds 1');
 asm65('ztmp11'#9'.ds 1');

 asm65(#13#10'TMP'#9'.ds 2');

 if STACK_Atari > 0 then asm65(#13#10#9'org $'+IntToHex(STACK_Atari, 4));

 asm65(#13#10'STACKORIGIN'#9'.ds STACKWIDTH*4');

// asm65('zfre');

 asm65(#13#10'.print ''ZPFREE: $0000..'',fxptr-1,'' ; '',*,''..'',$ff');

 asm65separator;
 asm65('');

 asm65('ax'#9'= eax');
 asm65('al'#9'= eax');
 asm65('ah'#9'= eax+1');

// asm65(#13#10'bx'#9'= ebx');
// asm65('bl'#9'= ebx');
// asm65('bh'#9'= ebx+1');

 asm65('');
 asm65('cx'#9'= ecx');
 asm65('cl'#9'= ecx');
 asm65('ch'#9'= ecx+1');

 asm65('');
 asm65('dx'#9'= edx');
 asm65('dl'#9'= edx');
 asm65('dh'#9'= edx+1');


 asm65('');
 asm65(#9'org eax');
 asm65('');
 asm65('FP1MAN0'#9'.ds 1');
 asm65('FP1MAN1'#9'.ds 1');
 asm65('FP1MAN2'#9'.ds 1');
 asm65('FP1MAN3'#9'.ds 1');

 asm65('');
 asm65(#9'org ztmp8');
 asm65('');
 asm65('FP1SGN'#9'.ds 1');
 asm65('FP1EXP'#9'.ds 1');

 asm65('');
 asm65(#9'org edx');
 asm65('');
 asm65('FP2MAN0'#9'.ds 1');
 asm65('FP2MAN1'#9'.ds 1');
 asm65('FP2MAN2'#9'.ds 1');
 asm65('FP2MAN3'#9'.ds 1');

 asm65('');
 asm65(#9'org ztmp10');
 asm65('');
 asm65('FP2SGN'#9'.ds 1');
 asm65('FP2EXP'#9'.ds 1');

 asm65('');
 asm65(#9'org ecx');
 asm65('');
 asm65('FPMAN0'#9'.ds 1');
 asm65('FPMAN1'#9'.ds 1');
 asm65('FPMAN2'#9'.ds 1');
 asm65('FPMAN3'#9'.ds 1');

 asm65('');
 asm65(#9'org bp2');
 asm65('');
 asm65('FPSGN'#9'.ds 1');
 asm65('FPEXP'#9'.ds 1');


 if High(resArray) > 0 then begin

  asm65('');
  asm65('.local'#9'RESOURCE');

  asm65(#9'icl ''res6502.asm''');

  asm65('');

  for i := 0 to High(resArray) - 1 do begin
   a:=#9+resArray[i].resType+' '''+resArray[i].resFile+''''+' ';

   a:=a+resArray[i].resFullName;

   for j := 1 to MAXPARAMS do a:=a+' '+resArray[i].resPar[j];

   asm65(a);
  end;

  asm65('.endl');
 end;

 asm65separator;

 asm65(#13#10#9'org CODEORIGIN');

// asm65(#13#10#9'jmp start');


// Build static string data table
 for i := 0 to NumStaticStrChars - 1 do Gen;			// db StaticStringData[i]

 asm65(#13#10#9'STATICDATA');
 //asm65('');

 asm65(#13#10'START');

 Gen; Gen; Gen;							// mov bx, :STACKORIGIN
// asm65(#9'mwa #:STACKORIGIN bx', '; mov bx, :STACKORIGIN');

 asm65(#9'tsx');
 asm65(#9'stx MAIN.@halt+1');
// asm65(#9'mva #$ff portb');


 asm65('');
 asm65(#9'.ifdef fmulinit');
 asm65(#9'fmulinit');
 asm65(#9'eif');


 asm65('');
 asm65(#9'ift DATAORIGIN+VARINITSIZE > $BFFF');
 asm65(#9'ert ''Invalid memory address range '',DATAORIGIN+VARINITSIZE');
 asm65(#9'els');
 asm65(#9'@fill #DATAORIGIN+VARINITSIZE #VARDATASIZE-VARINITSIZE #0');
 asm65(#9'eif');
 asm65('');

 asm65(#9'ldx #$0f');						// DOS II+/D ParamStr
 asm65(#9'mva:rpl $340,x MAIN.IOCB@COPY,x-');
 asm65('');

 asm65(#9'inx'#9#9'; X = 0 !!!');
 asm65(#9'stx bp'#9#9'; lo BP = 0');

 if CPUMode = 65816 then asm65(#9'opt c+');

 asm65('');
 asm65(#9'UNITINITIALIZATION');

 optimize.use := tmp;
end;

end;


procedure GenerateProgramEpilog(ExitCode: byte);
begin
Gen; Gen;							// mov ah, 4Ch

asm65(#9'lda #$'+IntToHex(ExitCode, 2));
asm65(#9'jmp @halt');
asm65('');
end;


procedure GenerateDeclarationProlog;
begin
Inc(CodePosStackTop);
CodePosStack[CodePosStackTop] := CodeSize;

Gen;								// nop   ; jump to the IF..THEN block end will be inserted here
Gen;								// nop
Gen;								// nop

//asm65(#9'ift l_'+IntToHex(CodeSize, 4)+'-*>3');     // !!!! infinite loop
asm65(#9'jmp l_'+IntToHex(CodeSize, 4));
//asm65(#9'eif');

end;


procedure GenerateDeclarationEpilog;
begin
GenerateIfThenEpilog;
end;


procedure GenerateRead;//(Value: Int64);
begin
Gen; Gen;							// mov bp, [bx]

asm65(#9'@getline');

end;// GenerateRead


procedure GenerateWriteString(Address: Word; IndirectionLevel: byte; ValueType: byte = INTEGERTOK);
begin

asm65('');

Gen; Gen;							// mov ah, 09h

case IndirectionLevel of

  ASBOOLEAN:
    begin
     asm65(#9'jsr @printBOOLEAN');

     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASCHAR:
    begin
     asm65(#9'@printCHAR');

     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASSHORTREAL:
    begin
     asm65(#9'jsr @printSHORTREAL');

     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASREAL:
    begin
     asm65(#9'jsr @printREAL');

     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASSINGLE:
    begin
     asm65(#9'jsr @ftoa');

     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASVALUE:
    begin

     case DataSize[ValueType] of
      1: if ValueType = SHORTINTTOK then
	  asm65(#9'jsr @printSHORTINT')
	 else
	  asm65(#9'jsr @printBYTE');

      2:  if ValueType = SMALLINTTOK then
	   asm65(#9'jsr @printSMALLINT')
	  else
	   asm65(#9'jsr @printWORD');

      4: if ValueType = INTEGERTOK then
	  asm65(#9'jsr @printINT')
	 else
	  asm65(#9'jsr @printCARD');
     end;

     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASPOINTER:
    begin
    Gen; //Gen(Lo(Address)); Gen(Hi(Address));			// mov dx, Address

    asm65(#9'@printSTRING #CODEORIGIN+$'+IntToHex(Address - CODEORIGIN, 4));

//    a65(__subBX);   !!!   bez DEX-a
    end;

  ASPOINTERTOPOINTER:
    begin
    Gen; Gen; //Gen(Lo(Address)); Gen(Hi(Address));		// mov dx, [Address]

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'jsr @printSTRING');
    a65(__subBX);
    end;


  ASPCHAR:
    begin
    Gen; Gen; //Gen(Lo(Address)); Gen(Hi(Address));		// mov dx, [Address]

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'jsr @printPCHAR');
    a65(__subBX);
    end;


  end;

//Gen; Gen;							// int 21h

end;// GenerateWriteString


procedure GenerateUnaryOperation(op: Byte; ValType: Byte = 0);
begin

case op of

  PLUSTOK:
    begin
    end;

  MINUSTOK:
    begin
    Gen; Gen; Gen;						// neg dword ptr [bx]

    if ValType = SINGLETOK then begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'eor #$80');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

    end else

    case DataSize[ValType] of
     1: asm65(#9'jsr negBYTE');
     2: asm65(#9'jsr negWORD');
    else
     asm65(#9'jsr negCARD');
    end;

//    a65(__negaBX);
    end;

  NOTTOK:
    begin
    Gen; Gen; Gen;						// not dword ptr [bx]

    if ValType = BOOLEANTOK then
     a65(__notBOOLEAN)
    else begin

     ExpandParam(INTEGERTOK, ValType);

     a65(__notaBX);

    end;

    end;

end;// case
end;


procedure GenerateBinaryOperation(op: Byte; ResultType: Byte);
begin

asm65(#13#10'; Generate Binary Operation for '+InfoAboutToken(ResultType));

Gen; Gen; Gen;							// mov :ecx, [bx]      :STACKORIGIN,x

case op of

  PLUSTOK:
    begin

     if ResultType = SINGLETOK then
       asm65(#9'jsr FSUB.FADD')
     else

     case DataSize[ResultType] of
       1: a65(__addAL_CL);
       2: a65(__addAX_CX);
       4: a65(__addEAX_ECX);
     end;

    end;

  MINUSTOK:
    begin

    if ResultType = SINGLETOK then
      asm65(#9'jsr FSUB')
    else

    case DataSize[ResultType] of
     1: a65(__subAL_CL);
     2: a65(__subAX_CX);
     4: a65(__subEAX_ECX);
    end;

    end;

  MULTOK:
    begin

    if ResultType in RealTypes then begin		// Real multiplication

      case ResultType of
       SHORTREALTOK: asm65(#9'jsr mulSHORTREAL');	// Q8.8 fixed-point
	    REALTOK: asm65(#9'jsr mulREAL'); 		// Q24.8 fixed-point
	  SINGLETOK: asm65(#9'jsr FMUL');		// IEEE754
      end;

    end else begin					// Integer multiplication

      if ResultType in SignedOrdinalTypes then begin

       case ResultType of
	SHORTINTTOK: asm65(#9'jsr mulSHORTINT');
	SMALLINTTOK: asm65(#9'jsr mulSMALLINT');
	 INTEGERTOK: asm65(#9'jsr mulINTEGER');
       end;

      end else begin

      case DataSize[ResultType] of
       1: asm65(#9'jsr imulBYTE');
       2: asm65(#9'jsr imulWORD');
       4: asm65(#9'jsr imulCARD');
      end;

      asm65(#9'jsr movaBX_EAX');
      end;

   //   StopOptimization;

      end;
    end;

  DIVTOK, IDIVTOK, MODTOK:
    begin

    if ResultType in RealTypes then begin	// Real division

      Gen; Gen; Gen;				// mov edx, :eax

      case ResultType of
       SHORTREALTOK: asm65(#9'jsr divmulSMALLINT.SHORTREAL');	// Q8.8 fixed-point
	    REALTOK: asm65(#9'jsr divmulINT.REAL');		// Q24.8 fixed-point
	  SINGLETOK: asm65(#9'jsr FDIV');			// IEEE754
      end;

    end

    else					// Integer division
      begin
      Gen; Gen;					// cdq

      if op = MODTOK then begin
	  Gen; Gen; Gen;			// mov :eax, edx		; save remainder
      end;


      if ResultType in SignedOrdinalTypes then begin

	case ResultType of
	 SHORTINTTOK: if op = MODTOK then
		       asm65(#9'jsr divmulSHORTINT.MOD')
		      else
		       asm65(#9'jsr divmulSHORTINT.DIV');

	 SMALLINTTOK: if op = MODTOK then
		       asm65(#9'jsr divmulSMALLINT.MOD')
		      else
		       asm65(#9'jsr divmulSMALLINT.DIV');

	  INTEGERTOK: if op = MODTOK then
		       asm65(#9'jsr divmulINT.MOD')
		      else
		       asm65(#9'jsr divmulINT.DIV')
	end;

      end else begin

	case DataSize[ResultType] of
	 1: if op = MODTOK then
	     asm65(#9'jsr_imodBYTE')
	    else
	     asm65(#9'jsr idivBYTE');

	 2: if op = MODTOK then
	     asm65(#9'jsr_imodWORD')
	    else
	     asm65(#9'jsr idivWORD');

	 4: if op = MODTOK then
	     asm65(#9'jsr_imodCARD')
	   else
	    asm65(#9'jsr idivCARD');

	end;

	if op = MODTOK then
	  asm65(#9'jsr movZTMP_aBX')
	else
	  asm65(#9'jsr movaBX_EAX');

      end;

//      StopOptimization;

      end;
    end;

  SHLTOK:
    begin

    if ResultType in SignedOrdinalTypes then begin

     case DataSize[ResultType] of
      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); asm65(#9'jsr shlEAX_CL.CARD') end;  //asm65(#9'jsr shlEAX_CL.SHORT');
      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); asm65(#9'jsr shlEAX_CL.CARD') end;  //asm65(#9'jsr shlEAX_CL.SMALL');
      4: asm65(#9'jsr shlEAX_CL.CARD');
     end;

    end else
     case DataSize[ResultType] of
      1: a65(__shlAL_CL);
      2: a65(__shlAX_CL);
      4: a65(__shlEAX_CL)
     end;

    end;

  SHRTOK:
    begin

    if ResultType in SignedOrdinalTypes then begin

     case DataSize[ResultType] of
      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); asm65(#9'jsr shrEAX_CL') end;  // asm65(#9'jsr shrAL_CL.SHORT');
      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); asm65(#9'jsr shrEAX_CL') end;  // asm65(#9'jsr shrAX_CL.SMALL');
      4: asm65(#9'jsr shrEAX_CL');
     end;

    end else
     case DataSize[ResultType] of
      1: a65(__shrAL_CL);
      2: a65(__shrAX_CL);
      4: a65(__shrEAX_CL)
     end;

    end;

  ANDTOK:
    begin

    case DataSize[ResultType] of
      1: a65(__andAL_CL);
      2: a65(__andAX_CX);
      4: a65(__andEAX_ECX)
    end;

    end;

  ORTOK:
    begin

    case DataSize[ResultType] of
      1: a65(__orAL_CL);
      2: a65(__orAX_CX);
      4: a65(__orEAX_ECX)
    end;

    end;

  XORTOK:
    begin

    case DataSize[ResultType] of
      1: a65(__xorAL_CL);
      2: a65(__xorAX_CX);
      4: a65(__xorEAX_ECX)
    end;

    end;

end;// case

a65(__subBX);

//StopOptimization;

end;


procedure GenerateRelationString(rel: Byte; LeftValType, RightValType: Byte);
begin
 asm65(#13#10'; relation STRING');

 Gen;

 asm65(#9'ldy #1', '; true');

 Gen;

 if (LeftValType = STRINGTOK) and (RightValType = STRINGTOK) then
  a65(__cmpSTRING)					// STRING ? STRING
 else
 if LeftValType = CHARTOK then
  a65(__cmpCHAR2STRING)					// CHAR ? STRING
 else
 if RightValType = CHARTOK then
  a65(__cmpSTRING2CHAR);				// STRING ? CHAR

 GenerateRelationOperation(rel, BYTETOK);

 Gen;

 asm65(#9'dey', '; false');
 asm65('@');

 asm65(#9'sty :STACKORIGIN-1,x');

 a65(__subBX);

end;


procedure GenerateRelation(rel: Byte; ValType: Byte);
begin
 asm65(#13#10'; relation');

 Gen;

 asm65(#9'ldy #1', '; true');

 Gen;

 case ValType of
     BYTETOK, CHARTOK, BOOLEANTOK:
	begin
	 asm65(#9'lda :STACKORIGIN-1,x');
	 asm65(#9'cmp :STACKORIGIN,x');
	end;

     SHORTINTTOK:
	a65(__cmpSHORTINT);

     SMALLINTTOK, SHORTREALTOK:
	a65(__cmpSMALLINT);

     SINGLETOK:
	asm65(#9'jsr FCMPL');

     REALTOK, INTEGERTOK:
	a65(__cmpINT);

     WORDTOK, POINTERTOK, STRINGPOINTERTOK:
	a65(__cmpAX_CX);
 else
   a65(__cmpEAX_ECX);					// CARDINALTOK
 end;

 GenerateRelationOperation(rel, ValType);

 Gen;

 asm65(#9'dey', '; false');
 asm65('@');

 asm65(#9'sty :STACKORIGIN-1,x');

 a65(__subBX);

end;


// The following functions implement recursive descent parser in accordance with Sub-Pascal EBNF
// Parameter i is the index of the first token of the current EBNF symbol, result is the index of the last one


function CompileConstExpression(i: Integer; out ConstVal: Int64; out ConstValType: Byte; VarType: Byte = INTEGERTOK; Err: Boolean = false; War: Boolean = true): Integer; forward;
function CompileExpression(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer; forward;


function LowBound(i: integer; DataType: Byte): Int64;
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
else
  iError(i, TypeMismatch);
end;// case
end;


function HighBound(i: integer; DataType: Byte): Int64;
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
else
  iError(i, TypeMismatch);
end;// case
end;



procedure InfoAboutArray(IdentIndex: Integer; c: Boolean = false);
var t: string;
begin

  if c then
   t:=' Const'
  else
   t:='';

  if Ident[IdentIndex].NumAllocElements_ > 0 then
   asm65(#13#10';'+t+' Array index '+Ident[IdentIndex].Name+'[0..'+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+', 0..'+IntToStr(Ident[IdentIndex].NumAllocElements_ - 1)+']')
  else
   asm65(#13#10';'+t+' Array index '+Ident[IdentIndex].Name+'[0..'+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+']');

end;


procedure CheckArrayIndex(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

 if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
  if Ident[IdentIndex].NumAllocElements <> 1 then warning(i, RangeCheckError, IdentIndex, ArrayIndex, ArrayIndexType);

end;


procedure CheckArrayIndex_(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

 if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements_-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
  if Ident[IdentIndex].NumAllocElements_ <> 1 then warning(i, RangeCheckError_, IdentIndex, ArrayIndex, ArrayIndexType);

end;


function CompileType(i: Integer; out DataType: Byte; out NumAllocElements: cardinal; out AllocElementType: Byte): Integer; forward;


procedure Int2Float(var ConstVal: Int64);
var ftmp: TFloat;
    fl: single;
begin

   fl := integer(ConstVal);

   ftmp[0] := round(fl * TWOPOWERFRACBITS);
   ftmp[1] := integer(fl);

   move(ftmp, ConstVal, sizeof(ftmp));

end;


procedure SaveToDataSegment(ConstDataSize: integer; ConstVal: Int64; ConstValType: Byte);
var ftmp: TFloat;
begin

ftmp[0]:=0;
ftmp[1]:=0;

	 case ConstValType of

	  SHORTINTTOK, BYTETOK, CHARTOK, BOOLEANTOK:
		       DataSegment[ConstDataSize] := byte(ConstVal);

	  SMALLINTTOK, WORDTOK, SHORTREALTOK, POINTERTOK, STRINGPOINTERTOK:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	   DATAORIGINOFFSET:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal) or $8000;
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8) or $4000;
		       end;

	   CODEORIGINOFFSET:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal) or $2000;
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8) or $1000;
		       end;

	   INTEGERTOK, CARDINALTOK, REALTOK:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
			DataSegment[ConstDataSize+2] := byte(ConstVal shr 16);
			DataSegment[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	    SINGLETOK: begin
			move(ConstVal, ftmp, sizeof(ftmp));

			ConstVal := ftmp[1];

			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
			DataSegment[ConstDataSize+2] := byte(ConstVal shr 16);
			DataSegment[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;
	 end;

 DataSegmentUse := true;

end;


function GetSizeof(i: integer; ValType: byte): Int64;
var IdentIndex: integer;
begin

     IdentIndex := GetIdent(Tok[i + 2].Name^);

     case ValType of

	ENUMTYPE: Result := DataSize[Ident[IdentIndex].AllocElementType];

	RECORDTOK: if (Ident[IdentIndex].DataType = POINTERTOK) and (Tok[i + 3].Kind = CPARTOK) then
	             Result := DataSize[POINTERTOK]
		   else
		     Result := RecordSize(IdentIndex);

      POINTERTOK, STRINGPOINTERTOK:
		  begin

		    if Ident[IdentIndex].AllocElementType = RECORDTOK then begin

		     if Ident[IdentIndex].NumAllocElements_ > 0 then begin

		       if Tok[i + 3].Kind = OBRACKETTOK then
			Result := DataSize[POINTERTOK]
		       else
			Result := Ident[IdentIndex].NumAllocElements * 2

		     end else
		      if Ident[IdentIndex].PassMethod = VARPASSING then
		       Result := RecordSize(IdentIndex)
		      else
		       Result := DataSize[POINTERTOK];

		    end else
		     if Elements(IdentIndex) > 0 then
		       Result := integer(Elements(IdentIndex) * DataSize[Ident[IdentIndex].AllocElementType])
		     else
		       Result := DataSize[POINTERTOK];

		  end;

      else

	if ValType = UNTYPETOK then
	 Result := 0
	else
	 Result := DataSize[ValType]

     end;

end;


function CompileConstFactor(i: Integer; out ConstVal: Int64; out ConstValType: Byte): Integer;
var IdentIndex, j: Integer;
    Kind, ArrayIndexType: Byte;
    ArrayIndex: Int64;
    ftmp: TFloat;
    fl: single;

    function GetStaticValue(x: byte): Int64;
    begin

      Result := StaticStringData[Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_Atari + ArrayIndex * DataSize[ConstValType] + x];

    end;

begin

 Result := i;
 ConstVal:=0;
 ConstValType:=0;

 ftmp[0]:=0;
 ftmp[1]:=0;

 fl:=0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 LOWTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in AllTypes then begin

      ConstValType := Tok[i + 2].Kind;

      inc(i, 2);

     end else begin

      i:=CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

     end;


     if ConstValType in Pointers then begin
       ConstVal := 0;
       ConstValType := GetValueType(ConstVal);
     end else
      ConstVal := LowBound(i, ConstValType);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 HIGHTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in AllTypes then begin

      ConstValType := Tok[i + 2].Kind;

      inc(i, 2);

     end else begin

      i:=CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

     end;

     if ConstValType in Pointers then begin
      IdentIndex := GetIdent(Tok[i].Name^);

      if Ident[IdentIndex].NumAllocElements > 0 then
       ConstVal := Ident[IdentIndex].NumAllocElements - 1
      else
       ConstVal := 0;

      ConstValType := GetValueType(ConstVal);
     end else
      ConstVal := HighBound(i, ConstValType);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 LENGTHTOK:
    begin
     CheckTok(i + 1, OPARTOK);

      ConstVal:=0;

      if Tok[i + 2].Kind = IDENTTOK then begin

	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	if Ident[IdentIndex].Kind in [VARIABLE, CONSTANT] then begin

	  if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0)) then begin

	   if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = CHARTOK) then begin

	   isError := true;
	   exit;

	   end else begin
	    ConstVal:=Ident[IdentIndex].NumAllocElements;

	    ConstValType := GetValueType(ConstVal);
	   end;

	  end else
	   iError(i+2, TypeMismatch);

	end else
	 iError(i + 2, IdentifierExpected);

	inc(i, 2);
      end else
       iError(i + 2, IdentifierExpected);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 SIZEOFTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in OrdinalTypes + RealTypes + [POINTERTOK] then begin

      ConstVal := DataSize[Tok[i + 2].Kind];
      ConstValType := BYTETOK;

      j:=i + 2;

     end else begin

      j:=CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;


      ConstVal := GetSizeof(i, ConstValType);

      ConstValType := GetValueType(ConstVal);

     end;

     CheckTok(j + 1, CPARTOK);

     Result:=j + 1;
    end;


  LOTOK:
    begin

    CheckTok(i + 1, OPARTOK);

    OldConstValType:=0;

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

    if OldConstValType in [DATAORIGINOFFSET, CODEORIGINOFFSET] then Error(i, 'Can''t take the address of variable');

    GetCommonConstType(i, INTEGERTOK, ConstValType);

    CheckTok(i + 1, CPARTOK);

    case ConstValType of
      INTEGERTOK, CARDINALTOK: ConstVal := ConstVal and $0000FFFF;
	 SMALLINTTOK, WORDTOK: ConstVal := ConstVal and $00FF;
	 SHORTINTTOK, BYTETOK: ConstVal := ConstVal and $0F;
    end;

    ConstValType := GetValueType(ConstVal);

    Result:=i + 1;
    end;


  HITOK:
    begin

    CheckTok(i + 1, OPARTOK);

    OldConstValType:=0;

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

    if OldConstValType in [DATAORIGINOFFSET, CODEORIGINOFFSET] then Error(i, 'Can''t take the address of variable');

    GetCommonConstType(i, INTEGERTOK, ConstValType);

    CheckTok(i + 1, CPARTOK);

    case ConstValType of
      INTEGERTOK, CARDINALTOK: ConstVal := ConstVal shr 16;
	 SMALLINTTOK, WORDTOK: ConstVal := ConstVal shr 8;
	 SHORTINTTOK, BYTETOK: ConstVal := ConstVal shr 4;
    end;

    ConstValType := GetValueType(ConstVal);
    Result:=i + 1;
    end;


  INTTOK, FRACTOK:
    begin

      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      if not (ConstValType in RealTypes) then
	iError(i, IncompatibleTypes, 0, ConstValType, REALTOK);

      CheckTok(i + 1, CPARTOK);

      if ConstValType = SINGLETOK then begin

    	move(ConstVal, ftmp, sizeof(ftmp));
	move(ftmp[1], fl, sizeof(fl));

	case Kind of
	  INTTOK: fl:=int(fl);
	 FRACTOK: fl:=frac(fl);
	end;

	ftmp[0] := round(fl * TWOPOWERFRACBITS);
	ftmp[1] := integer(fl);

	move(ftmp, ConstVal, sizeof(ftmp));

      end else

      case Kind of
	INTTOK: if ConstVal < 0 then
		  ConstVal := -(abs(ConstVal) and $ffffffffffffff00)
		else
		  ConstVal := ConstVal and $ffffffffffffff00;

       FRACTOK: if ConstVal < 0 then
		  ConstVal := -(abs(ConstVal) and $ff)
		else
		  ConstVal := ConstVal and $ff;
      end;

 //     ConstValType := REALTOK;
      Result:=i + 1;
    end;


  ROUNDTOK, TRUNCTOK:
    begin

      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, REALTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

      ConstVal := integer(ConstVal);

      case Kind of
	ROUNDTOK: if ConstVal < 0 then
		   ConstVal := -( abs(ConstVal) shr 8 + ord( abs(ConstVal) and $ff > 127) )
		  else
		   ConstVal := ConstVal shr 8 + ord( abs(ConstVal) and $ff > 127);

	TRUNCTOK: if ConstVal < 0 then
		   ConstVal := -( abs(ConstVal) shr 8)
		  else
		   ConstVal := ConstVal shr 8;
      end;

      ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;


  ODDTOK:
    begin

//      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, CARDINALTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

      ConstVal := ord(odd(ConstVal));

      ConstValType := BOOLEANTOK;

      Result:=i + 1;
    end;


  CHRTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, INTEGERTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

      ConstValType := CHARTOK;
      Result:=i + 1;
    end;


  ORDTOK:
    begin
      CheckTok(i + 1, OPARTOK);

      j := i + 2;

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if not(ConstValType in OrdinalTypes) then
	iError(i, OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, CPARTOK);

      if ConstValType in [CHARTOK, BOOLEANTOK] then
       ConstValType := BYTETOK;

      Result:=i + 1;
    end;


  PREDTOK, SUCCTOK:
    begin
      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if not(ConstValType in OrdinalTypes) then
	iError(i, OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, CPARTOK);

      if Kind = PREDTOK then
       dec(ConstVal)
      else
       inc(ConstVal);

      if not (ConstValType in [CHARTOK, BOOLEANTOK]) then
       ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;

{	!!! dla '= ^Float' powinien przyjac '= ^F' i zostawic 'loat' !!!
	!!! TokenizeProgram na to nie pozwoli bo wczyta caly ciag 'Float' !!!
  DEREFERENCETOK:
    begin

     if (Tok[i + 1].Kind = IDENTTOK) then
      ConstVal:=ord(Tok[i + 1].Name^[1]) + 64
     else
     if length(InfoAboutToken(Tok[i + 1].Kind)) = 1 then
      ConstVal:=ord(InfoAboutToken(Tok[i + 1].Kind)[1]) + 64
     else
     if Tok[i + 1].Kind = UNKNOWNIDENTTOK then
      ConstVal:=Tok[i + 1].Value + 64
     else
      iError(i + 1, IdNumExpExpected);

     ConstValType := CHARTOK;

     Result:= i + 1;
    end;
}


  IDENTTOK:
    begin
    IdentIndex := GetIdent(Tok[i].Name^);

    if IdentIndex > 0 then

	  if (Ident[IdentIndex].Kind = USERTYPE) and (Tok[i + 1].Kind = OPARTOK) then begin

		CheckTok(i + 1, OPARTOK);

		j := CompileConstExpression(i + 2, ConstVal, ConstValType);

		if isError then Exit;

		if not(ConstValType in AllTypes) then
		  iError(i, TypeMismatch);


		if (Ident[GetIdent(Tok[i].Name^)].DataType in RealTypes) and (ConstValType in RealTypes) then begin
		// ok
		end else
		if Ident[GetIdent(Tok[i].Name^)].DataType in Pointers then
		  Error(j, 'Illegal type conversion: "'+InfoAboutToken(ConstValType)+'" to "'+Tok[i].Name^+'"');

		ConstValType := Ident[GetIdent(Tok[i].Name^)].DataType;

		CheckTok(j + 1, CPARTOK);

		i := j + 1;

	  end else

      if not (Ident[IdentIndex].Kind in [CONSTANT, USERTYPE, ENUMTYPE]) then
	Error(i, 'Constant expected but ' + Ident[IdentIndex].Name + ' found')
      else
	if Tok[i + 1].Kind = OBRACKETTOK then					// Array element access
	  if  not (Ident[IdentIndex].DataType in Pointers) then
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin

	    j := CompileConstExpression(i + 2, ArrayIndex, ArrayIndexType);	// Array index

	    if isError then Exit;

	    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then begin
	     isConst := false;
	     iError(i, SubrangeBounds);
	    end;

	    CheckTok(j + 1, CBRACKETTOK);

	    InfoAboutArray(IdentIndex, true);

	    ConstValType := Ident[IdentIndex].AllocElementType;

	    case DataSize[ConstValType] of
	     1: ConstVal := GetStaticValue(0);
	     2: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8;
	     4: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8 + GetStaticValue(2) shl 16 + GetStaticValue(3) shl 24;
	    end;

	    if ConstValType = SINGLETOK then ConstVal := ConstVal shl 32;

	    i := j + 1;
	    end else

	begin

	ConstValType := Ident[IdentIndex].DataType;

//	if (ConstValType in Pointers) then iError(i, IllegalExpression);

	if (ConstValType in Pointers) or (Ident[IdentIndex].DataType = STRINGPOINTERTOK) then
	 ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	else
	 ConstVal := Ident[IdentIndex].Value;


	if ConstValType = ENUMTYPE then begin
	  CheckTok(i + 1, OPARTOK);

	  j := CompileConstExpression(i + 2, ConstVal, ConstValType);

	  if isError then exit;

	  CheckTok(j + 1, CPARTOK);

	  ConstValType := Tok[i].Kind;

	  i := j + 1;
	end;

	end
    else
      iError(i, UnknownIdentifier);

    Result := i;
    end;


  ADDRESSTOK:
    if Tok[i + 1].Kind <> IDENTTOK then
      iError(i + 1, IdentifierExpected)
    else begin
      IdentIndex := GetIdent(Tok[i + 1].Name^);

      if IdentIndex > 0 then begin

	case Ident[IdentIndex].Kind of
	  CONSTANT: if not( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
	   	      Error(i + 1, 'Can''t take the address of constant expressions')
		    else
		      ConstVal := Ident[IdentIndex].Value - CODEORIGIN;

	  VARIABLE: if Ident[IdentIndex].isAbsolute then 				// wyjatek gdy ABSOLUTE

	   	      ConstVal := Ident[IdentIndex].Value

		    else begin

		     if isConst then begin isError:=true; exit end;			// !!! koniecznie zamiast Error !!!

			ConstVal := Ident[IdentIndex].Value - DATAORIGIN;

			ConstValType := DATAORIGINOFFSET;

//        writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,' / ',ConstVal);

	if (Ident[IdentIndex].DataType in Pointers) and					// zadziala tylko dla ABSOLUTE
	   (Ident[IdentIndex].NumAllocElements > 0) and
	   (Tok[i + 2].Kind = OBRACKETTOK)  then
	   begin
		j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);			// Array index [xx,

		if isError then Exit;

		CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

		if Tok[j + 1].Kind = COMMATOK then begin
    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType] * Ident[IdentIndex].NumAllocElements_);

		 j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);		// Array index ,yy]

		 if isError then Exit;

		 CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);
		end else
		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);

		i := j;

		CheckTok(i + 1, CBRACKETTOK);
	   end;
			Result := i + 1;

			exit;

		    end;
	else

	  Error(i + 1, 'Can''t take the address of ' + InfoAboutToken(Ident[IdentIndex].Kind) );

	end;

	if (Ident[IdentIndex].DataType in Pointers) and					// zadziala tylko dla ABSOLUTE
	   (Ident[IdentIndex].NumAllocElements > 0) and
	   (Tok[i + 2].Kind = OBRACKETTOK)  then
	   begin
		j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);			// Array index [xx,

		if isError then Exit;

		CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

		if Tok[j + 1].Kind = COMMATOK then begin
    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType] * Ident[IdentIndex].NumAllocElements_);

		 j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);		// Array index ,yy]

		 if isError then Exit;

		 CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);
		end else
		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);

		i := j;

		CheckTok(i + 1, CBRACKETTOK);
	   end;

	ConstValType := POINTERTOK;

       end else
	iError(i + 1, UnknownIdentifier);

    Result := i + 1;
    end;


  INTNUMBERTOK:
    begin
    ConstVal := Tok[i].Value;
    ConstValType := GetValueType(ConstVal);
    Result := i;
    end;


  FRACNUMBERTOK:
    begin
    ftmp[0] := round( Tok[i].FracValue * TWOPOWERFRACBITS );
    ftmp[1] := integer( Tok[i].FracValue );

    move(ftmp, ConstVal, sizeof(ftmp));

    ConstValType := REALTOK;
    Result := i;
    end;


  STRINGLITERALTOK:
    begin
    ConstVal := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_Atari;
    ConstValType := STRINGPOINTERTOK;
    Result := i;
    end;


  CHARLITERALTOK:
    begin
    ConstVal := Tok[i].Value;
    ConstValType := CHARTOK;
    Result := i;
    end;


  OPARTOK:       // a whole expression in parentheses suspected
    begin
    j := CompileConstExpression(i + 1, ConstVal, ConstValType);

    if isError then Exit;

    CheckTok(j + 1, CPARTOK);

    Result := j + 1;
    end;


  NOTTOK:
    begin
    Result := CompileConstFactor(i + 1, ConstVal, ConstValType);

    if isError then Exit;

    if ConstValType = BOOLEANTOK then
     ConstVal := ord(not (ConstVal <> 0) )

    else begin
     ConstVal := not ConstVal;
     ConstValType := GetValueType(ConstVal);
    end;

    end;

{
  SHORTREALTOK:					// SHORTREAL	fixed-point	Q8.8
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    if ConstValType = SINGLETOK then begin
     isError := false;
     isConst := false;

     iError(i, IncompatibleTypes, 0, ConstValType, SHORTREALTOK);

    end else
    if not(ConstValType in RealTypes) then
      ConstVal := ConstVal * TWOPOWERFRACBITS;

    CheckTok(j + 1, CPARTOK);

    ConstValType := SHORTREALTOK;

    Result := j + 1;
    end;


  REALTOK:					// REAL		fixed-point	Q24.8
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    if ConstValType = SINGLETOK then begin
     isError := false;
     isConst := false;

     iError(i, IncompatibleTypes, 0, ConstValType, REALTOK);

    end else
    if not(ConstValType in RealTypes) then
      ConstVal := ConstVal * TWOPOWERFRACBITS;

    CheckTok(j + 1, CPARTOK);

    ConstValType := REALTOK;

    Result := j + 1;
    end;
}

  SHORTREALTOK, REALTOK, SINGLETOK:					// SINGLE	IEEE-754	Q32
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    if not(ConstValType in RealTypes) then Int2Float(ConstVal);

    CheckTok(j + 1, CPARTOK);

    ConstValType := Tok[i].Kind;

    Result := j + 1;

    end;


  INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK:   // type conversion operations
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    CheckTok(j + 1, CPARTOK);

    if ConstValType in [DATAORIGINOFFSET, CODEORIGINOFFSET] then OldConstValType := ConstValType;

    ConstValType := Tok[i].Kind;

    Result := j + 1;
    end;


else
  iError(i, IdNumExpExpected);
end;// case


end;// CompileConstFactor


function CompileConstTerm(i: Integer; out ConstVal: Int64; out ConstValType: Byte): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  ftmp, ftmp_: TFloat;
  fl, fl_: single;
begin

Result:=i;

j := CompileConstFactor(i, ConstVal, ConstValType);

if isError then exit;

ftmp[0]:=0;
ftmp[1]:=0;

ftmp_[0]:=0;
ftmp_[1]:=0;

fl:=0;
fl_:=0;

while Tok[j + 1].Kind in [MULTOK, DIVTOK, MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] do
  begin

  k := CompileConstFactor(j + 2, RightConstVal, RightConstValType);

  if isError then Break;


  if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then begin
   Int2Float(RightConstVal);
   RightConstValType := ConstValType;
  end;

  if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then begin
   Int2Float(ConstVal);
   ConstValType := RightConstValType;
  end;


  if (Tok[j + 1].Kind = DIVTOK) and (ConstValType in IntegerTypes) then begin
   Int2Float(ConstVal);
   ConstValType := REALTOK;
  end;

  if (Tok[j + 1].Kind = DIVTOK) and (RightConstValType in IntegerTypes) then begin
   Int2Float(RightConstVal);
   RightConstValType := REALTOK;
  end;


  case Tok[j + 1].Kind of

    MULTOK:  if ConstValType in RealTypes then begin
    		move(ConstVal, ftmp, sizeof(ftmp));
    		move(RightConstVal, ftmp_, sizeof(ftmp_));

		move(ftmp[1], fl, sizeof(fl));
		move(ftmp_[1], fl_, sizeof(fl_));

		fl := fl * fl_;

		ftmp[0] := round(fl * TWOPOWERFRACBITS);
		ftmp[1] := integer(fl);

		move(ftmp, ConstVal, sizeof(ftmp));
    	      end else
    		ConstVal := ConstVal * RightConstVal;

    DIVTOK:  begin
    		move(ConstVal, ftmp, sizeof(ftmp));
    		move(RightConstVal, ftmp_, sizeof(ftmp_));

		move(ftmp[1], fl, sizeof(fl));
		move(ftmp_[1], fl_, sizeof(fl_));

		if fl_ = 0 then begin
		  isError := false;
		  isConst := false;
		  Error(i, 'Division by zero');
		end;

		fl := fl / fl_;

		ftmp[0] := round(fl * TWOPOWERFRACBITS);
		ftmp[1] := integer(fl);

		move(ftmp, ConstVal, sizeof(ftmp));
    	     end;

    MODTOK:  ConstVal := ConstVal mod RightConstVal;
   IDIVTOK:  ConstVal := ConstVal div RightConstVal;
    SHLTOK:  ConstVal := ConstVal shl RightConstVal;
    SHRTOK:  ConstVal := ConstVal shr RightConstVal;
    ANDTOK:  ConstVal := ConstVal and RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes) then
   ConstValType := GetValueType(ConstVal);

  CheckOperator(i, Tok[j + 1].Kind, ConstValType, RightConstValType);

  j := k;
  end;

 Result := j;
end;// CompileConstTerm


function CompileSimpleConstExpression(i: Integer; out ConstVal: Int64; out ConstValType: Byte): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  ftmp, ftmp_: TFloat;
  fl, fl_: single;

begin

Result:=i;

if Tok[i].Kind in [PLUSTOK, MINUSTOK] then j := i + 1 else j := i;

j := CompileConstTerm(j, ConstVal, ConstValType);

if isError then exit;

ftmp[0]:=0;
ftmp[1]:=0;

ftmp_[0]:=0;
ftmp_[1]:=0;

fl:=0;
fl_:=0;

if Tok[i].Kind = MINUSTOK then begin

 if ConstValType in RealTypes then begin	// Unary minus (RealTypes)

  move(ConstVal, ftmp, sizeof(ftmp));
  move(ftmp[1], fl, sizeof(fl));

  fl := -fl;

  ftmp[0] := round(fl * TWOPOWERFRACBITS);
  ftmp[1] := integer(fl);

  move(ftmp, ConstVal, sizeof(ftmp));

 end else begin
  ConstVal := -ConstVal;     			// Unary minus (IntegerTypes)

  if ConstValType in IntegerTypes then
    ConstValType := GetValueType(ConstVal);

 end;

end;


 while Tok[j + 1].Kind in [PLUSTOK, MINUSTOK, ORTOK, XORTOK] do begin

  k := CompileConstTerm(j + 2, RightConstVal, RightConstValType);

  if isError then Break;


  if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then begin
   Int2Float(RightConstVal);
   RightConstValType := ConstValType;
  end;

  if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then begin
   Int2Float(ConstVal);
   ConstValType := RightConstValType;
  end;


  case Tok[j + 1].Kind of
    PLUSTOK:  if ConstValType in RealTypes then begin
    		move(ConstVal, ftmp, sizeof(ftmp));
    		move(RightConstVal, ftmp_, sizeof(ftmp_));

		move(ftmp[1], fl, sizeof(fl));
		move(ftmp_[1], fl_, sizeof(fl_));

		fl := fl + fl_;

		ftmp[0] := round(fl * TWOPOWERFRACBITS);
		ftmp[1] := integer(fl);

		move(ftmp, ConstVal, sizeof(ftmp));
    	      end else
    		ConstVal := ConstVal + RightConstVal;

    MINUSTOK: if ConstValType in RealTypes then begin
    		move(ConstVal, ftmp, sizeof(ftmp));
    		move(RightConstVal, ftmp_, sizeof(ftmp_));

		move(ftmp[1], fl, sizeof(fl));
		move(ftmp_[1], fl_, sizeof(fl_));

		fl := fl - fl_;

		ftmp[0] := round(fl * TWOPOWERFRACBITS);
		ftmp[1] := integer(fl);

		move(ftmp, ConstVal, sizeof(ftmp));

    	      end else
    		ConstVal := ConstVal - RightConstVal;

    ORTOK:    ConstVal := ConstVal  or RightConstVal;
    XORTOK:   ConstVal := ConstVal xor RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes) then
   ConstValType := GetValueType(ConstVal);

  CheckOperator(i, Tok[j + 1].Kind, ConstValType, RightConstValType);

  j := k;
 end;

Result := j;
end;// CompileSimpleConstExpression



function CompileConstExpression(i: Integer; out ConstVal: Int64; out ConstValType: Byte; VarType: Byte = INTEGERTOK; Err: Boolean = false; War: Boolean = True): Integer;
var
  j: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  Yes: Boolean;
begin

Result:=i;

i := CompileSimpleConstExpression(i, ConstVal, ConstValType);

if isError then exit;

if Tok[i + 1].Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
  begin

  j := CompileSimpleConstExpression(i + 2, RightConstVal, RightConstValType);
//  CheckOperator(i, Tok[j + 1].Kind, ConstValType);

  case Tok[i + 1].Kind of
    EQTOK: Yes := ConstVal =  RightConstVal;
    NETOK: Yes := ConstVal <> RightConstVal;
    LTTOK: Yes := ConstVal <  RightConstVal;
    LETOK: Yes := ConstVal <= RightConstVal;
    GTTOK: Yes := ConstVal >  RightConstVal;
    GETOK: Yes := ConstVal >= RightConstVal;
  else
   yes := false;
  end;

  if Yes then ConstVal := $ff else ConstVal := 0;
//  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  ConstValType := BOOLEANTOK;

  i := j;
  end;

 Result := i;

 if ConstValType in OrdinalTypes + Pointers then
 if VarType in OrdinalTypes + Pointers then begin

  case VarType of
   SHORTINTTOK: Yes := (ConstVal < Low(shortint)) or (ConstVal > High(shortint));
   SMALLINTTOK: Yes := (ConstVal < Low(smallint)) or (ConstVal > High(smallint));
    INTEGERTOK: Yes := (ConstVal < Low(integer)) or (ConstVal > High(integer));
  else
   Yes := (abs(ConstVal) > $FFFFFFFF) or (DataSize[ConstValType] > DataSize[VarType]) or ((ConstValType in SignedOrdinalTypes) and (VarType in UnsignedOrdinalTypes));
  end;

 if Yes then
  if Err then begin
   isConst := false;
   isError := false;
   iError(i, RangeCheckError, 0, ConstVal, VarType);
  end else
   if War then
   if VarType <> BOOLEANTOK then
    warning(i, RangeCheckError, 0, ConstVal, VarType);

 end;

end;// CompileConstExpression



function SafeCompileConstExpression(var i: Integer; out ConstVal: Int64; out ValType: Byte; VarType: Byte; Err: Boolean = false; War: Boolean = true): Boolean;
var j: integer;
begin

 j := i;

 isError := false;		 // dodatkowy test
 isConst := true;

 i := CompileConstExpression(i, ConstVal, ValType, VarType, Err, War);

 Result := not isError;

 isConst := false;
 isError := false;

 if not Result then i := j;

end;


function CompileArrayIndex(i: integer; IdentIndex: integer): integer;
var ConstVal: Int64;
    ActualParamType, ArrayIndexType, Size: Byte;
    NumAllocElements, NumAllocElements_: cardinal;
    j: integer;
    yes: Boolean;


  procedure MulArrayIndex(a: integer);
  begin

  end;


begin
	InfoAboutArray(IdentIndex);

	NumAllocElements := Ident[IdentIndex].NumAllocElements;
	NumAllocElements_ := Ident[IdentIndex].NumAllocElements_;

	Size:=DataSize[Ident[IdentIndex].AllocElementType];

	if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then begin
	 NumAllocElements_ := 0;
	// Size := RecordSize(IdentIndex);
	end;

	      if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) = 1) or (NumAllocElements_ > 0) then
	       ActualParamType := WORDTOK
	      else
	       ActualParamType := GetValueType(Elements(IdentIndex));

//writeln(Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,'/',Ident[IdentIndex].AllocElementType );

	      j := i + 2;

	      if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
		  i := j;

		  CheckArrayIndex(i, IdentIndex, ConstVal, ArrayIndexType);

		  ArrayIndexType := WORDTOK;

	      	  if NumAllocElements_ > 0 then
		   Push(ConstVal * NumAllocElements_ * Size, ASVALUE, DataSize[ArrayIndexType])
		  else
		   Push(ConstVal * Size, ASVALUE, DataSize[ArrayIndexType]);

		end else begin
		 i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	  // array index [x, ..]

		 GetCommonType(i, ActualParamType, ArrayIndexType);

		 if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) = 1) or (NumAllocElements_ > 0) then begin
		   ExpandParam(WORDTOK, ArrayIndexType);
		   ArrayIndexType := WORDTOK;
		 end;

		 if NumAllocElements_ > 0 then begin

		   Push(integer(NumAllocElements_ * Size), ASVALUE, DataSize[ArrayIndexType]);

		   GenerateBinaryOperation(MULTOK, ArrayIndexType);

		   asm65(#9'lda :STACKORIGIN,x');
		   asm65(#9'sta :STACKORIGIN,x');
		   asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

		 end else
		   GenerateIndexShift( Ident[IdentIndex].AllocElementType );

	      end;

	    yes:=false;

	    if NumAllocElements_ > 0 then begin

	     if Tok[i + 1].Kind = CBRACKETTOK then begin
	      inc(i);
	      CheckTok(i + 1, OBRACKETTOK);
	      yes:=true;
	     end else begin
	      CheckTok(i + 1, COMMATOK);
	      yes:=true;
	     end;

	    end else
	     CheckTok(i + 1, CBRACKETTOK);


	    if {Tok[i + 1].Kind = COMMATOK} yes then begin

	    	j := i + 2;

		if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
		  i := j;

		  CheckArrayIndex_(i, IdentIndex, ConstVal, ArrayIndexType);

		  ArrayIndexType := WORDTOK;

		  Push(ConstVal * Size, ASVALUE, DataSize[ArrayIndexType]);

		end else begin
		  i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	  // array index [.., y]

		  GetCommonType(i, ActualParamType, ArrayIndexType);

		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) = 1) or (NumAllocElements_ > 0) then begin
		    ExpandParam(WORDTOK, ArrayIndexType);
		    ArrayIndexType := WORDTOK;
		  end;

		  GenerateIndexShift( Ident[IdentIndex].AllocElementType );

		end;

		GenerateBinaryOperation(PLUSTOK, WORDTOK);

	    end;


	{if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then begin

	 inc(i, 2);

	 CheckTok(i, DOTTOK);

	end;}

 Result := i;
end;


function CompileAddress(i: integer; out ValType, AllocElementType: Byte; VarPass: Boolean = false): integer;
var IdentIndex: integer;
    Name, svar: string;
begin

    Result:=i;

    AllocElementType := 0;

    if Tok[i + 1].Kind <> IDENTTOK then
      iError(i + 1, IdentifierExpected)
    else
      begin
      IdentIndex := GetIdent(Tok[i + 1].Name^);

      if IdentIndex > 0 then
	begin

	if not(Ident[IdentIndex].Kind in [CONSTANT, VARIABLE, PROC, FUNC, ADDRESSTOK]) then
	 iError(i + 1, VariableExpected)
	else begin

 	  if Ident[IdentIndex].Kind = CONSTANT then
	   if not ( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
	     Error(i + 1, 'Can''t take the address of constant expressions');

	  asm65(#13#10'; address');

	  if Ident[IdentIndex].Kind in [PROC, FUNC] then begin

	    Name := GetLocalName(IdentIndex);

	    if Ident[IdentIndex].isOverload then Name:=Name+'_'+IntToHex(Ident[IdentIndex].Value, 4);

	    a65(__addBX);
	    asm65(#9'mva <'+Name+' :STACKORIGIN,x');
	    asm65(#9'mva >'+Name+' :STACKORIGIN+STACKWIDTH,x');

	    if Pass = CALLDETERMPASS then
	      AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);

	  end else

	  if (Ident[IdentIndex].DataType in Pointers) and
	     (Ident[IdentIndex].NumAllocElements > 0) and
	     (Tok[i + 2].Kind = OBRACKETTOK)  then
	  begin						// array index
	      inc(i);

 // asm65(#9'atari');	  // a := @tab[x,y]

	      i := CompileArrayIndex(i, IdentIndex);

 svar := GetLocalName(IdentIndex);

 asm65('');
 asm65(#9'lda '+svar);
 asm65(#9'add :STACKORIGIN,x');
 asm65(#9'sta :STACKORIGIN,x');
 asm65(#9'lda '+svar+'+1');
 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	     CheckTok(i + 1, CBRACKETTOK);

	     AllocElementType := Ident[IdentIndex].AllocElementType;

	     end else
	      if (Ident[IdentIndex].DataType in [FILETOK, RECORDTOK, OBJECTTOK] {+ Pointers}) or
	         ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType > 0)) or
		 (Ident[IdentIndex].PassMethod = VARPASSING) or
		 (VarPass and (Ident[IdentIndex].DataType in Pointers))  then begin

 //writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

		 if (Ident[IdentIndex].DataType in Pointers) and (Tok[i + 2].Kind = DEREFERENCETOK) then begin
		   AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   inc(i);
		 end;

		 if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
		    (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET) then begin
		   Push(Ident[IdentIndex].Value, ASPOINTERTORECORD, DataSize[POINTERTOK], IdentIndex)
		 end else
		   Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

	      end else
		 Push(Ident[IdentIndex].Value, ASVALUE, DataSize[POINTERTOK], IdentIndex);

	  ValType :=  POINTERTOK;

	  Result := i + 1;
	  end;

	end
      else
	iError(i + 1, UnknownIdentifier);
      end;
end;


function NumActualParameters(i: integer; IdentIndex: integer; out NumActualParams: integer): TParamList;
var ActualParamType, AllocElementType: byte;
    oldPass, oldCodeSize: integer;
begin

   oldPass := Pass;
   oldCodeSize := CodeSize;
   Pass := CALLDETERMPASS;

   NumActualParams := 0;
   AllocElementType := 0;
   ActualParamType := 0;

   if Tok[i + 1].Kind = OPARTOK then		    // Actual parameter list found
     begin
     repeat

       Inc(NumActualParams);

       if NumActualParams > MAXPARAMS then
	 iError(i, TooManyParameters, IdentIndex);


       if (Ident[IdentIndex].Param[NumActualParams].PassMethod = VARPASSING) then begin

	CompileExpression(i + 2, ActualParamType);

	Result[NumActualParams].AllocElementType := ActualParamType;

	i := CompileAddress(i + 1, ActualParamType, AllocElementType);

       end else
	 i := CompileExpression(i + 2, ActualParamType{, Ident[IdentIndex].Param[NumActualParams].DataType});  // Evaluate actual parameters and push them onto the stack

       Result[NumActualParams].DataType := ActualParamType;

     until Tok[i + 1].Kind <> COMMATOK;

     CheckTok(i + 1, CPARTOK);

//     inc(i);
     end;// if Tok[i + 1].Kind = OPARTOR

     Pass := oldPass;
     CodeSize := oldCodeSize;
end;


procedure CompileActualParameters(var i: integer; IdentIndex: integer);
var NumActualParams, IdentTemp, j: integer;
    ActualParamType, AllocElementType: byte;
    svar: string;
begin

   j := i;

   if Ident[IdentIndex].Kind = PROCEDURETOK then begin
    StopOptimization;
    StartOptimization(i);
   end;

   if Ident[IdentIndex].ProcAsBlock = BlockStack[BlockStackTop] then Ident[IdentIndex].isRecursion := true;

   NumActualParams := 0;
   IdentTemp := 0;

   if Tok[i + 1].Kind = OPARTOK then		    // Actual parameter list found
     begin
     repeat

       Inc(NumActualParams);

       if NumActualParams > Ident[IdentIndex].NumParams then
	iError(i, WrongNumParameters, IdentIndex);

       if Ident[IdentIndex].Param[NumActualParams].PassMethod = VARPASSING then begin

	i := CompileAddress(i + 1, ActualParamType, AllocElementType);

	if Tok[i].Kind = IDENTTOK then
	 IdentTemp := GetIdent(Tok[i].Name^)
	else
	 IdentTemp := 0;

	if IdentTemp > 0 then begin

//      writeln(' - ',Tok[i].Name^,',',ActualParamType,',',AllocElementType, ',', Ident[IdentTemp].NumAllocElements );
//      writeln(Ident[IdentTemp].DataType,',',Ident[IdentIndex].Param[NumActualParams].DataType);

	if Ident[IdentTemp].DataType in Pointers then
	  if Ident[IdentIndex].Param[NumActualParams].DataType <> FILETOK then begin

// writeln(Ident[IdentIndex].Param[NumActualParams].DataType,',', Ident[IdentTemp].DataType);
// writeln(Ident[IdentIndex].Param[NumActualParams].NumAllocElements,',', Ident[IdentTemp].NumAllocElements);
// writeln(Ident[IdentIndex].Param[NumActualParams].PassMethod,',', Ident[IdentTemp].PassMethod);

	     if Ident[IdentTemp].PassMethod <> VARPASSING then
	       GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	  end;

	 if (Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK]) {and (Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK])} then
	  if Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    iError(i, IncompatibleTypeOf, IdentTemp);

	 if Ident[IdentTemp].AllocElementType = UNTYPETOK then begin
	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	   if (Ident[IdentIndex].Param[NumActualParams].DataType <> UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType <> Ident[IdentTemp].DataType) then
	     iError(i, IncompatibleTypes, 0, Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].DataType);

	 end else
	  if Ident[IdentIndex].Param[NumActualParams].DataType in Pointers then begin

//	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].AllocElementType, Ident[IdentTemp].AllocElementType)

	   if (Ident[IdentIndex].Param[NumActualParams].NumAllocElements = 0) and (Ident[IdentTemp].NumAllocElements = 0) then
// ok ?
	   else
	   if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> Ident[IdentTemp].AllocElementType then
	     iError(i, IncompatibleTypes, 0, Ident[IdentTemp].AllocElementType, Ident[IdentIndex].Param[NumActualParams].AllocElementType);

	  end else
	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].AllocElementType);

	end else
	  if  Ident[IdentIndex].Param[NumActualParams].DataType <> UNTYPETOK then
	   if (Ident[IdentIndex].Param[NumActualParams].DataType <> AllocElementType)  then
	     iError(i, IncompatibleTypes, 0, AllocElementType, Ident[IdentIndex].Param[NumActualParams].DataType);

// writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].DataType,',',ActualParamType,' / ',IdentTemp);

       end else begin

	 i := CompileExpression(i + 2, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);  // Evaluate actual parameters and push them onto the stack

	if (ActualParamType in [RECORDTOK, OBJECTTOK]) and not (Ident[IdentIndex].Param[NumActualParams].DataType in Pointers) then
	 if Ident[GetIdent(Tok[i].Name^)].isNestedFunction then begin

	  if Ident[GetIdent(Tok[i].Name^)].NestedFunctionNumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    iError(i, IncompatibleTypeOf, GetIdent(Tok[i].Name^));

	 end else
	  if Ident[GetIdent(Tok[i].Name^)].NumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    iError(i, IncompatibleTypeOf, GetIdent(Tok[i].Name^));


	if ((ActualParamType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].Param[NumActualParams].DataType in Pointers)) or
	   ((ActualParamType in Pointers) and (Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK])) then
     //  jesli wymagany jest POINTER a przekazujemy RECORD (lub na odwrot) to OK
	else
	 GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);

	ExpandParam(Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);
       end;


     until Tok[i + 1].Kind <> COMMATOK;

     CheckTok(i + 1, CPARTOK);

     inc(i);
     end;// if Tok[i + 1].Kind = OPARTOR


   if NumActualParams <> Ident[IdentIndex].NumParams then
     iError(i, WrongNumParameters, IdentIndex);

   if Pass = CALLDETERMPASS then
     AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);


   if Ident[IdentIndex].ObjectIndex > 0 then begin
     IdentTemp := GetIdent(copy(Tok[j].Name^, 1, pos('.', Tok[j].Name^)-1 ));

     svar := GetLocalName(IdentTemp);

     asm65(#9'lda '+svar);
     asm65(#9'ldy '+svar+'+1');
   end;

   GenerateCall( IdentIndex );

end;


function CompileFactor(i: Integer; out isZero: Boolean; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var IdentTemp, IdentIndex, j, oldCodeSize: Integer;
    ActualParamType, AllocElementType,  Kind, oldPass: Byte;
    Value, ConstVal: Int64;
    Param: TParamList;
    ftmp: TFloat;
    fl: single;
begin

 isZero:=false;

 Result := i;

 ValType := 0;
 ConstVal := 0;

 ftmp[0]:=0;
 ftmp[1]:=0;

 fl:=0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 HIGHTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := CALLDETERMPASS;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;
{
      if ValType = ENUMTYPE then begin

       if Tok[j].Kind = IDENTTOK then
	IdentIndex := GetIdent(Tok[j].Name^)
       else
	 iError(i, TypeMismatch);

       if IdentIndex = 0 then iError(i, TypeMismatch);

       IdentTemp := GetIdent(Types[Ident[IdentIndex].NumAllocElements].Field[Types[Ident[IdentIndex].NumAllocElements].NumFields].Name);

       if Ident[IdentTemp].NumAllocElements = 0 then iError(i, TypeMismatch);

       Push(Ident[IdentTemp].Value, ASPOINTER, DataSize[POINTERTOK], IdentTemp);

       GenerateWriteString(Ident[IdentTemp].Value, ASPOINTERTOPOINTER, Ident[IdentTemp].DataType, IdentTemp)

      end else begin
}
      if ValType in Pointers then begin
       IdentIndex := GetIdent(Tok[i + 2].Name^);

       if Ident[IdentIndex].NumAllocElements > 0 then
	Value := Ident[IdentIndex].NumAllocElements - 1
       else
	Value := HighBound(j, Ident[IdentIndex].AllocElementType);

      end else
       Value := HighBound(j, ValType);

      ValType:=GetValueType(Value);

      Push(Value, ASVALUE, DataSize[ValType]);

//     end;

      CheckTok(j + 1, CPARTOK);

      Result := j + 1;
    end;


 LOWTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := CALLDETERMPASS;

//      j := i + 2;

      i:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

{
      if ValType = ENUMTYPE then begin

       if Tok[j].Kind = IDENTTOK then
	IdentIndex := GetIdent(Tok[j].Name^)
       else
	 iError(i, TypeMismatch);

       if IdentIndex = 0 then iError(i, TypeMismatch);

       IdentTemp := GetIdent(Types[Ident[IdentIndex].NumAllocElements].Field[1].Name);

       if Ident[IdentTemp].NumAllocElements = 0 then iError(i, TypeMismatch);

       ValType := ENUMTYPE;
       Push(Ident[IdentTemp].Value, ASPOINTER, DataSize[POINTERTOK], IdentTemp);

       GenerateWriteString(Ident[IdentTemp].Value, ASPOINTERTOPOINTER, Ident[IdentTemp].DataType, IdentTemp)

      end else begin
}
       if ValType in Pointers then begin
	Value := 0;
       end else
	Value := LowBound(i, ValType);

       ValType := GetValueType(Value);

       Push(Value, ASVALUE, DataSize[ValType]);

//      end;

      CheckTok(i + 1, CPARTOK);

      Result := i + 1;
    end;


 SIZEOFTOK:
    begin
      Value:=0;

      CheckTok(i + 1, OPARTOK);

      if Tok[i + 2].Kind in OrdinalTypes + RealTypes + [POINTERTOK] then begin

       Value := DataSize[Tok[i + 2].Kind];

       ValType := BYTETOK;

       j:=i + 2;

      end else begin

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := CALLDETERMPASS;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

      Value := GetSizeof(i, ValType);

      ValType := GetValueType(Value);

      end;  // if Tok[i + 2].Kind in


    Push(Value, ASVALUE, DataSize[ValType]);

    CheckTok(j + 1, CPARTOK);

    Result := j + 1;

    end;


 LENGTHTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      Value:=0;

      if Tok[i + 2].Kind = IDENTTOK then begin

	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	if Ident[IdentIndex].Kind in [VARIABLE, CONSTANT] then begin

	  if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0)) then begin

	   if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = CHARTOK) then begin

	    a65(__addBX);
	    asm65(#9'mwa '+Ident[IdentIndex].Name+' :bp2');
	    asm65(#9'ldy #0');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta :STACKORIGIN,x');

	    ValType:=BYTETOK;

	   end else begin
	    Value:=Ident[IdentIndex].NumAllocElements;

	    ValType := GetValueType(Value);
	    Push(Value, ASVALUE, DataSize[ValType]);
	   end;

	  end else
	   iError(i+2, TypeMismatch);

	end else
	 iError(i + 2, IdentifierExpected);

	inc(i, 2);
      end else
       iError(i + 2, IdentifierExpected);

    CheckTok(i + 1, CPARTOK);

    Result:=i + 1;
    end;


  LOTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, INTEGERTOK, ActualParamType);

     if DataSize[ActualParamType] > 2 then warning(i, LoHi);

     CheckTok(i + 1, CPARTOK);

     asm65(#13#10'; Lo(X)');

     case ActualParamType of
      SHORTINTTOK, BYTETOK:
		  begin
		    asm65(#9'lda :STACKORIGIN,x', '; lo BYTE');
		    asm65(#9'and #$0f');
		    asm65(#9'sta :STACKORIGIN,x');
		    asm65('');
		  end;
     end;

     if ActualParamType in [INTEGERTOK, CARDINALTOK] then
      ValType := WORDTOK
     else
      ValType:=BYTETOK;

     Result:=i + 1;
    end;


  HITOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, INTEGERTOK, ActualParamType);

     if DataSize[ActualParamType] > 2 then warning(i, LoHi);

     CheckTok(i + 1, CPARTOK);

     asm65(#13#10'; Hi(X)');

     case ActualParamType of
	 SHORTINTTOK, BYTETOK: asm65(#9'jsr hiBYTE');
	 SMALLINTTOK, WORDTOK: asm65(#9'jsr hiWORD');
      INTEGERTOK, CARDINALTOK: asm65(#9'jsr hiCARD');
     end;

     if ActualParamType in [INTEGERTOK, CARDINALTOK] then
       ValType := WORDTOK
     else
       ValType:=BYTETOK;

     Result:=i + 1;
    end;


  CHRTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, INTEGERTOK, ActualParamType);

     CheckTok(i + 1, CPARTOK);

     ValType := CHARTOK;
     Result:=i + 1;
    end;


  INTTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     if not (ActualParamType in RealTypes) then
       iError(i + 2, IncompatibleTypes, 0, ActualParamType, REALTOK);

     CheckTok(i + 1, CPARTOK);

     if ActualParamType = SINGLETOK then begin
      asm65(#9'jsr F2I');
      asm65(#9'jsr I2F');
     end else
      asm65(#9'jsr @int');

     ValType := ActualParamType;
     Result:=i + 1;
    end;


  FRACTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     if not (ActualParamType in RealTypes) then
       iError(i + 2, IncompatibleTypes, 0, ActualParamType, REALTOK);

     CheckTok(i + 1, CPARTOK);

     if ActualParamType = SINGLETOK then
      asm65(#9'jsr FFRAC')
     else
      asm65(#9'jsr @frac');

     ValType := ActualParamType;
     Result:=i + 1;
    end;


  TRUNCTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     CheckTok(i + 1, CPARTOK);

     if ActualParamType in IntegerTypes then
      ValType := ActualParamType
     else
     if ActualParamType in RealTypes then begin

     if ActualParamType = SINGLETOK then
      asm65(#9'jsr F2I')
     else
      asm65(#9'jsr @trunc');

     if ActualParamType = SHORTREALTOK then
      ValType := SHORTINTTOK
     else
      ValType := INTEGERTOK;

     end else
      GetCommonConstType(i, REALTOK, ActualParamType);

     Result:=i + 1;
    end;


  ROUNDTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     CheckTok(i + 1, CPARTOK);

     if ActualParamType in IntegerTypes then
      ValType := ActualParamType
     else
     if ActualParamType in RealTypes then begin

     if ActualParamType = SINGLETOK then begin
      asm65(#9'jsr FROUND');
      asm65(#9'jsr F2I');
     end else
      asm65(#9'jsr @round');

     if ActualParamType = SHORTREALTOK then
      ValType := SHORTINTTOK
     else
      ValType := INTEGERTOK;

     end else
      GetCommonConstType(i, REALTOK, ActualParamType);

     Result:=i + 1;
    end;


  ODDTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, CARDINALTOK, ActualParamType);

     CheckTok(i + 1, CPARTOK);

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'and #1');
     asm65(#9'sta :STACKORIGIN,x');

     ValType := BOOLEANTOK;
     Result:=i + 1;
    end;


  ORDTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     j := i + 2;

     i := CompileExpression(i + 2, ValType);

     if not(ValType in OrdinalTypes) then
	iError(i, OrdinalExpExpected);

     CheckTok(i + 1, CPARTOK);

     if ValType in [CHARTOK, BOOLEANTOK] then
       ValType := BYTETOK;

     Result:=i + 1;
    end;


  PREDTOK, SUCCTOK:
    begin
      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileExpression(i + 2, ValType);

      if not(ValType in OrdinalTypes) then
	iError(i, OrdinalExpExpected);

      CheckTok(i + 1, CPARTOK);

      Push(1, ASVALUE, DataSize[SHORTINTTOK]);

      if Kind = PREDTOK then
       GenerateBinaryOperation(MINUSTOK, ValType)
      else
       GenerateBinaryOperation(PLUSTOK, ValType);

//      if not (ConstValType in [CHARTOK, BOOLEANTOK]) then
//       ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;


  INTOK:
    begin

     writeln('IN');

{    CaseLocalCnt := CaseCnt;
    inc(CaseCnt);

    ResetOpty;

    StopOptimization;    // !!! potrzebujemy zachowac na stosie testowana wartosc

    i := CompileExpression(i + 1, SelectorType);

	if Tok[i].Kind = IDENTTOK then
	 EnumName := GetEnumName(GetIdent(Tok[i].Name^));


    if DataSize[SelectorType]<>1 then
     Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, OFTOK);

    GenerateCaseProlog;

    NumCaseStatements := 0;

    inc(i, 2);

    SetLength(CaseLabelArray, 1);

    repeat       // Loop over all cases

      repeat     // Loop over all constants for the current case
	i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

	GetCommonType(i, ConstValType, SelectorType);

	if (Tok[i].Kind = IDENTTOK) then
	 if ((EnumName = '') and (GetEnumName(GetIdent(Tok[i].Name^)) <> '')) or
  	    ((EnumName <> '') and (GetEnumName(GetIdent(Tok[i].Name^)) <> EnumName)) then
		Error(i, 'Constant and CASE types do not match');

	if Tok[i + 1].Kind = RANGETOK then				      // Range check
	  begin
	  i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

	  GetCommonType(i, ConstValType, SelectorType);

	  if ConstVal > ConstVal2 then
	   Error(i, 'Upper bound of case range is less than lower bound');

	  GenerateCaseRangeCheck(ConstVal, ConstVal2, SelectorType);

	  CaseLabel.left:=ConstVal;
	  CaseLabel.right:=ConstVal2;
	  end
	else begin
	  GenerateCaseEqualityCheck(ConstVal, SelectorType);		    // Equality check

	  CaseLabel.left:=ConstVal;
	  CaseLabel.right:=ConstVal;
	end;

	UpdateCaseLabels(i, CaseLabelArray, CaseLabel);

	inc(i);

	ExitLoop := FALSE;
	if Tok[i].Kind = COMMATOK then
	  inc(i)
	else
	  ExitLoop := TRUE;
      until ExitLoop;


      CheckTok(i, COLONTOK);

      GenerateCaseStatementProlog;

      ResetOpty;

      asm65('@');

      j := CompileStatement(i + 1);
      i := j + 1;
      GenerateCaseStatementEpilog(CaseLocalCnt);

      Inc(NumCaseStatements);

      ExitLoop := FALSE;
      if Tok[i].Kind <> SEMICOLONTOK then
	begin
	if Tok[i].Kind = ELSETOK then	      // Default statements
	  begin

	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	  end;
	ExitLoop := TRUE;
	end
      else
	begin
	inc(i);

	if Tok[i].Kind = ELSETOK then begin
	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	end;

	if Tok[i].Kind = ENDTOK then ExitLoop := TRUE;

	end

    until ExitLoop;

    CheckTok(i, ENDTOK);

    GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

    ResetOpty;
}
    Result := i;
    end;


  IDENTTOK:
    begin
    IdentIndex := GetIdent(Tok[i].Name^);

    if IdentIndex > 0 then

	  if (Ident[IdentIndex].Kind = USERTYPE) and (Tok[i + 1].Kind = OPARTOK) then begin

		CheckTok(i + 1, OPARTOK);

		j := CompileExpression(i + 2, ValType);

		if not(ValType in AllTypes) then
		  iError(i, TypeMismatch);


		if (ValType in IntegerTypes) and (Ident[GetIdent(Tok[i].Name^)].DataType = SHORTREALTOK) then begin

		  ExpandParam(SMALLINTTOK, ValType);

		  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'lda #$00');
		  asm65(#9'sta :STACKORIGIN,x');

		  ValType := SHORTREALTOK;
		end;


		if (ValType in IntegerTypes) and (Ident[GetIdent(Tok[i].Name^)].DataType = REALTOK) then begin

		  ExpandParam(INTEGERTOK, ValType);

		  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'lda #$00');
		  asm65(#9'sta :STACKORIGIN,x');

		  ValType := REALTOK;
		end;


		if (ValType in IntegerTypes) and (Ident[GetIdent(Tok[i].Name^)].DataType = SINGLETOK) then begin

		  ExpandParam(INTEGERTOK, ValType);

		  asm65(#9'jsr I2F');

		  ValType := SINGLETOK;
		end;


		if Ident[GetIdent(Tok[i].Name^)].DataType in Pointers then
		  Error(j, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+Tok[i].Name^+'"');

		ExpandParam(Ident[GetIdent(Tok[i].Name^)].DataType, ValType);

		ValType := Ident[GetIdent(Tok[i].Name^)].DataType;

		CheckTok(j + 1, CPARTOK);

		Result := j + 1;

	  end else

      if Ident[IdentIndex].Kind = PROC then
	Error(i, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found')
      else if Ident[IdentIndex].Kind = FUNC then       // Function call
	begin

	  Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc( Ident[IdentIndex].Name, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then
	      iError(i, CantDetermine, IdentIndex)
	     else
              iError(i, WrongNumParameters, IdentIndex);

	    IdentIndex := IdentTemp;

//	  end;

	CompileActualParameters(i, IdentIndex);

	ValType := Ident[IdentIndex].DataType;

	Result := i;
	end // FUNC
      else
	begin
	if (Tok[i + 1].Kind = DEREFERENCETOK) then
	  if (Ident[IdentIndex].Kind <> VARIABLE) or not (Ident[IdentIndex].DataType in Pointers) then
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin

	    ValType := Ident[IdentIndex].AllocElementType;

	    if (ValType in [RECORDTOK, OBJECTTOK]) then begin			// record^.

	    //optyBP2 := '';
//ritmo
	     if (Tok[i + 2].Kind = DOTTOK) then begin

	      IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

 	      if IdentTemp < 0 then
	       Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	      ValType := IdentTemp shr 16;

	      inc(i, 2);

	      Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex, IdentTemp and $ffff);  // record_lebel.field^

	     end else
	     // fake code, do nothing ;)
	      Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[ValType], IdentIndex);		       // record_label^

	    end else
	     Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex);

	    Result := i + 1;
	    end
	else if Tok[i + 1].Kind = OBRACKETTOK then		    // Array element access
	  if not (Ident[IdentIndex].DataType in Pointers) or (Ident[IdentIndex].NumAllocElements = 0) then
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin

 //asm65(#9'amstrad');

 // y:=item[3].price

	    i := CompileArrayIndex(i, IdentIndex);

	    ValType := Ident[IdentIndex].AllocElementType;


            if (Tok[i + 2].Kind = DOTTOK) and (ValType in [RECORDTOK, OBJECTTOK]) then begin

//	writeln(valType,' / ',Ident[IdentIndex].name,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Tok[i + 1].Kind );

		CheckTok(i + 1, CBRACKETTOK);

		IdentTemp:=GetIdent(Ident[IdentIndex].Name+ '.' + Tok[i + 3].Name^);

		if IdentTemp < 0 then
	          Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

		ValType := Ident[IdentTemp].AllocElementType;

		Push(Ident[IdentTemp].Value, ASPOINTERTOARRAYRECORD, DataSize[ValType], IdentTemp);

		inc(i, 2);

	{    end else
	    if ValType in [RECORDTOK, OBJECTTOK] then begin
	      ValType := POINTERTOK;

//		!@!@

		Push(Ident[IdentIndex].Value, ASPOINTERTOARRAYORIGIN2, DataSize[Ident[IdentIndex].AllocElementType], IdentIndex);

		CheckTok(i + 1, CBRACKETTOK);

}
	    end else
	    if (Tok[i + 2].Kind = OBRACKETTOK) and (ValType = STRINGPOINTERTOK) then begin

	     Error(i, '-- under construction --');

	     ValType := CHARTOK;
	     inc(i, 3);

	     Push(2, ASVALUE, 2);

	     GenerateBinaryOperation(PLUSTOK, WORDTOK);

	    end else begin

	        if ValType in [RECORDTOK, OBJECTTOK] then ValType := POINTERTOK;

		Push(Ident[IdentIndex].Value, ASPOINTERTOARRAYORIGIN2, DataSize[ValType], IdentIndex);

		CheckTok(i + 1, CBRACKETTOK);

	    end;


	    Result := i + 1;
	    end
	else							  // Usual variable or constant
	  begin

	  j:=i;

	  isError := false;
	  isConst := true;

	  i := CompileConstTerm(i, ConstVal, ValType);

	  if isError then begin
	   i:=j;

	  if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements = 0) then begin

	   ValType := Ident[IdentIndex].AllocElementType;
	   if ValType = UNTYPETOK then ValType := POINTERTOK;

	  end else
	   ValType := Ident[IdentIndex].DataType;

	  if (ValType = ENUMTYPE) and (Ident[IdentIndex].DataType = ENUMTYPE) then
	    ValType := Ident[IdentIndex].AllocElementType;


//	  if ValType in IntegerTypes then
//	    if DataSize[ValType] > DataSize[VarType] then ValType := VarType;     // skracaj typ danych    !!! niemozliwe skoro VarType = INTEGERTOK

	  if (Ident[IdentIndex].Kind = CONSTANT) and (ValType in Pointers) then
	   ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	  else
	   ConstVal := Ident[IdentIndex].Value;

	  if (ValType = SINGLETOK) or (VarType = SINGLETOK) then begin

	   if (ValType in IntegerTypes) and (Ident[IdentIndex].Kind = CONSTANT) then begin
	    Int2Float(ConstVal);
	    ValType := SINGLETOK;
	   end;

	   move(ConstVal, ftmp, sizeof(ftmp));
	   ConstVal:=ftmp[1];
	   //ValType := SINGLETOK;       !!!
	  end;


	  if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
	     (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET) then

	   Push(ConstVal, ASPOINTERTORECORD, DataSize[ValType], IdentIndex)
	  else
	  if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements = 0) then
	   Push(ConstVal, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex)
	  else
	   Push(ConstVal, Ord(Ident[IdentIndex].Kind = VARIABLE), DataSize[ValType], IdentIndex);


	  if (BLOCKSTACKTOP=1) then
	    if not (Ident[IdentIndex].isInit or Ident[IdentIndex].isInitialized or Ident[IdentIndex].LoopVariable) then
	      warning(i, VariableNotInit, IdentIndex);

	  end else begin	// isError

	   if (ValType = SINGLETOK) or (VarType = SINGLETOK) then begin

	    if ValType in IntegerTypes then Int2Float(ConstVal);

	    move(ConstVal, ftmp, sizeof(ftmp));
	    ConstVal:=ftmp[1];
	    ValType := SINGLETOK;
	   end;

	   Push(ConstVal, ASVALUE, DataSize[ValType]);

	  end;


	  isConst := false;
	  isError := false;

	  Result := i;
	  end;
	end
    else
      iError(i, UnknownIdentifier);
    end;


  ADDRESSTOK:
    Result := CompileAddress(i, ValType, AllocElementType);


  INTNUMBERTOK:
    begin
{
    j:=i;

    isError := false;
    isConst := true;

    i := CompileConstTerm(i, ConstVal, ValType);	// !!! nie zazdziala gdy wystapi laczenie wartosciowania VAR + CONST
							// day:=day mod 153 div 5   -> day mod 30 = 22 zamiast = 10 !!!
    if isError then begin
     i:=j;

     ConstVal := Tok[i].Value;
     ValType := GetValueType(ConstVal);
    end;

    if VarType in RealTypes then begin
     Int2Float(ConstVal);

     if VarType = SINGLETOK then begin
      move(ConstVal, ftmp, sizeof(ftmp));
      ConstVal := ftmp[1];
     end;

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, DataSize[ValType]);

    isConst := false;
    isError := false;
}
    ConstVal := Tok[i].Value;
    ValType := GetValueType(ConstVal);

    if VarType in RealTypes then begin
     Int2Float(ConstVal);

     if VarType = SINGLETOK then begin
      move(ConstVal, ftmp, sizeof(ftmp));
      ConstVal := ftmp[1];
     end;

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, DataSize[ValType]);

    isZero := (ConstVal = 0);

    Result := i;
    end;


  FRACNUMBERTOK:
    begin
{
    j:=i;

    isError := false;
    isConst := true;

    i := CompileConstTerm(i, ConstVal, ValType);

    if isError then begin
     i:=j;

     fl := Tok[i].FracValue;

     ftmp[0] := round(fl * TWOPOWERFRACBITS);
     ftmp[1] := integer(fl);

     move(ftmp, ConstVal, sizeof(ftmp));
    end;

    move(ConstVal, ftmp, sizeof(ftmp));

    if VarType in RealTypes then begin

     if VarType = SINGLETOK then
      ConstVal := ftmp[1]
     else
      ConstVal := ftmp[0];

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, DataSize[ValType]);

    isConst := false;
    isError := false;
}

    fl := Tok[i].FracValue;

    ftmp[0] := round(fl * TWOPOWERFRACBITS);
    ftmp[1] := integer(fl);

    move(ftmp, ConstVal, sizeof(ftmp));

    ValType := REALTOK;

    if VarType in RealTypes then begin

     if VarType = SINGLETOK then
      ConstVal := ftmp[1]
     else
      ConstVal := ftmp[0];

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, DataSize[ValType]);

    isZero := (ConstVal = 0);

    Result := i;
    end;


  STRINGLITERALTOK:
    begin
    Push(Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_Atari, ASVALUE, DataSize[STRINGPOINTERTOK]);
    ValType := STRINGPOINTERTOK;
    Result := i;
    end;


  CHARLITERALTOK:
    begin
    Push(Tok[i].Value, ASVALUE, DataSize[CHARTOK]);
    ValType := CHARTOK;
    Result := i;
    end;


  OPARTOK:       // a whole expression in parentheses suspected
    begin
    j := CompileExpression(i + 1, ValType, VarType);

    CheckTok(j + 1, CPARTOK);

    Result := j + 1;
    end;


  NOTTOK:
    begin
    Result := CompileFactor(i + 1, isZero, ValType, INTEGERTOK);
    CheckOperator(i, NOTTOK, ValType);
    GenerateUnaryOperation(NOTTOK, Valtype);
    end;


  SHORTREALTOK:					// SHORTREAL	fixed-point	Q8.8
    begin

//    CheckTok(i + 1, OPARTOK);

   if Tok[i + 1].Kind <> OPARTOK then
    Error(i, 'type identifier not allowed here');

    j := CompileExpression(i + 2, ValType);//, SHORTREALTOK);

    if not(ValType in RealTypes) then begin

     ExpandParam(SMALLINTTOK, ValType);

     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta :STACKORIGIN,x');

    end;

    CheckTok(j + 1, CPARTOK);

    ValType := SHORTREALTOK;

    Result := j + 1;
    end;


  REALTOK:					// REAL		fixed-point	Q24.8
    begin

//    CheckTok(i + 1, OPARTOK);

   if Tok[i + 1].Kind <> OPARTOK then
    Error(i, 'type identifier not allowed here');

    j := CompileExpression(i + 2, ValType);//, REALTOK);

    if not(ValType in RealTypes) then begin

     ExpandParam(INTEGERTOK, ValType);

     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta :STACKORIGIN,x');

    end;

    CheckTok(j + 1, CPARTOK);

    ValType := REALTOK;

    Result := j + 1;
    end;


  SINGLETOK:					// SINGLE	IEEE-754	Q32
    begin

//    CheckTok(i + 1, OPARTOK);

   if Tok[i + 1].Kind <> OPARTOK then
    Error(i, 'type identifier not allowed here');

 	j := i + 2;

	if SafeCompileConstExpression(j, ConstVal, ValType, SINGLETOK) then begin

	  if not(ValType in RealTypes) then Int2Float(ConstVal);

	  move(ConstVal, ftmp, sizeof(ftmp));
	  ConstVal := ftmp[1];

	  ValType := SINGLETOK;

	  Push(ConstVal, ASVALUE, DataSize[ValType]);

	end else begin
	  j := CompileExpression(i + 2, ValType);

	  if ValType in [SHORTREALTOK, REALTOK] then
	   Error(i + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(SINGLETOK)+'"');

	  if not(ValType in RealTypes) then begin

	    ExpandParam(INTEGERTOK, ValType);

	    asm65(#9'jsr I2F');

	  end;

	end;

    CheckTok(j + 1, CPARTOK);

    ValType := SINGLETOK;

    Result := j + 1;

    end;


  INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK:   // type conversion operations
    begin

   if Tok[i + 1].Kind <> OPARTOK then
    Error(i, 'type identifier not allowed here');


    j := CompileExpression(i + 2, ValType, Tok[i].Kind);

    if (ValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) and (Tok[i + 3].Kind <> OBRACKETTOK) then begin

      IdentIndex := GetIdent(Tok[i + 2].Name^);

      if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then
	iError(i + 2, IllegalTypeConversion, IdentIndex, Tok[i].Kind);

    end;

    if not(ValType in AllTypes) then
      iError(i, TypeMismatch);

    ExpandParam(Tok[i].Kind, ValType);

    CheckTok(j + 1, CPARTOK);

    ValType := Tok[i].Kind;

    Result := j + 1;

    end;

else
  iError(i, IdNumExpExpected);
end;// case


end;// CompileFactor


procedure ResizeType(var ValType: Byte);
// dla operacji SHL, MUL rozszerzamy typ dla wyniku operacji
begin


  if (ValType in IntegerTypes) then begin

     if ValType in [BYTETOK, WORDTOK, SHORTINTTOK, SMALLINTTOK] then inc(ValType);

  end;

{
  if not(ValType in RealTypes) then
    if ValType in IntegerTypes then begin

     if (VarType in IntegerTypes) and (DataSize[VarType] > DataSize[ValType]) then begin

//      ValType := VarType

    if ValType in SignedOrdinalTypes then begin

     if DataSize[VarType] = 1 then
       ValType := SMALLINTTOK
     else
       ValType := INTEGERTOK;

    end else

     if DataSize[VarType] = 1 then
       ValType := WORDTOK
     else
       ValType := CARDINALTOK;


    end else

    if ValType in SignedOrdinalTypes then begin

     if ValType = SHORTINTTOK then
       ValType := SMALLINTTOK
     else
       ValType := INTEGERTOK;

    end else
     if ValType = BYTETOK then
       ValType := WORDTOK
     else
       ValType := CARDINALTOK;

    end;
}
end;


procedure RealTypeConversion(var ValType, RightValType: Byte; Kind: Byte = 0);
begin

  If ((ValType = SINGLETOK) or (Kind = SINGLETOK)) and (RightValType in IntegerTypes) then begin

   ExpandParam(INTEGERTOK, RightValType);

   asm65(#9'jsr I2F');

   if (ValType <> SINGLETOK) and (Kind = SINGLETOK) then
    RightValType := Kind
   else
    RightValType := ValType;
  end;


  If (ValType in IntegerTypes) and ((RightValType = SINGLETOK) or (Kind = SINGLETOK)) then begin

   ExpandParam_m1(INTEGERTOK, ValType);

   asm65(#9'jsr I2F_m');

   if (RightValType <> SINGLETOK) and (Kind = SINGLETOK) then
    ValType := Kind
   else
    ValType := RightValType;
  end;


  If ((ValType in [REALTOK, SHORTREALTOK]) or (Kind in [REALTOK, SHORTREALTOK])) and (RightValType in IntegerTypes) then begin

   ExpandParam(INTEGERTOK, RightValType);

   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
   asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
   asm65(#9'lda :STACKORIGIN,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'lda #$00');
   asm65(#9'sta :STACKORIGIN,x');

   if not(ValType in [REALTOK, SHORTREALTOK]) and (Kind in [REALTOK, SHORTREALTOK]) then
    RightValType := Kind
   else
    RightValType := ValType;

  end;


  If (ValType in IntegerTypes) and ((RightValType in [REALTOK, SHORTREALTOK]) or (Kind in [REALTOK, SHORTREALTOK])) then begin

   ExpandParam_m1(INTEGERTOK, ValType);

   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
   asm65(#9'lda :STACKORIGIN-1,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'lda #$00');
   asm65(#9'sta :STACKORIGIN-1,x');

   if not(RightValType in [REALTOK, SHORTREALTOK]) and (Kind in [REALTOK, SHORTREALTOK]) then
    ValType := Kind
   else
    ValType := RightValType;

  end;

end;


function CompileTerm(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var
  j, k, oldCodeSize: Integer;
  RightValType, CastRealType, oldPass: Byte;
  isZero: Boolean;
begin

 oldPass := Pass;
 oldCodeSize := CodeSize;
 Pass := CALLDETERMPASS;

 j := CompileFactor(i, isZero, ValType, VarType);

 Pass := oldPass;
 CodeSize := oldCodeSize;

 if Tok[j + 1].Kind in [MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] then
  j := CompileFactor(i, isZero, ValType, INTEGERTOK)
 else
  j := CompileFactor(i, isZero, ValType, VarType);

while Tok[j + 1].Kind in [MULTOK, DIVTOK, MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] do
  begin

  if Tok[j + 1].Kind in [MULTOK, DIVTOK] then
   k := CompileFactor(j + 2, isZero, RightValType, VarType)
  else
   k := CompileFactor(j + 2, isZero, RightValType, INTEGERTOK);

  if (Tok[j + 1].Kind in [MODTOK, IDIVTOK]) and isZero then
   Error(j + 1, 'Division by zero');


  if ((ValType = SINGLETOK) and (RightValType in [SHORTREALTOK, REALTOK])) or
   ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType = SINGLETOK)) then
    Error(j + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(RightValType)+'"');

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  if VarType in RealTypes then
   CastRealType := VarType
  else
   CastRealType := REALTOK;

  RealTypeConversion(ValType, RightValType, ord(Tok[j + 1].Kind = DIVTOK) * CastRealType);

  ValType := GetCommonType(j + 1, ValType, RightValType);

  CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);

  if not ( Tok[j + 1].Kind in [SHLTOK, SHRTOK] ) then				// dla SHR, SHL nie wyrownuj typow parametrow
   ExpandExpression(ValType, RightValType, 0);

  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  case Tok[j + 1].Kind of							// !!! tutaj a nie przed ExpandExpression
   MULTOK: begin ResizeType(ValType); ExpandExpression(VarType, 0, 0) end;
   SHLTOK, SHRTOK: begin ResizeType(ValType); ResizeType(ValType) end;		// !!! Silly Intro lub "x(byte) shl 14" tego wymaga
  end;

  j := k;
  end;

Result := j;
end;// CompileTerm


function CompileSimpleExpression(i: Integer; out ValType: Byte; VarType: Byte): Integer;
var
  j, k: Integer;
  RightValType: Byte;
begin

if Tok[i].Kind in [PLUSTOK, MINUSTOK] then j := i + 1 else j := i;

j := CompileTerm(j, ValType, VarType);

if Tok[i].Kind = MINUSTOK then begin
 GenerateUnaryOperation(MINUSTOK, ValType);	// Unary minus

   if ValType in UnsignedOrdinalTypes then	// jesli odczytalismy typ bez znaku zamieniamy na 'ze znakiem'

     case ValType of
	  BYTETOK: ValType := SHORTINTTOK;
	  WORDTOK: ValType := SMALLINTTOK;
      CARDINALTOK: ValType := INTEGERTOK;
     end;

end;


while Tok[j + 1].Kind in [PLUSTOK, MINUSTOK, ORTOK, XORTOK] do
  begin

  k := CompileTerm(j + 2, RightValType, VarType);

  if ((ValType = SINGLETOK) and (RightValType in [SHORTREALTOK, REALTOK])) or
     ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType = SINGLETOK)) then
      Error(j + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(RightValType)+'"');

//  if (ValType = SINGLETOK) and (RightValType = REALTOK) then RightValType := SINGLETOK;
//  if (ValType = REALTOK) and (RightValType = SINGLETOK) then ValType := SINGLETOK;

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);

  ValType := GetCommonType(j + 1, ValType, RightValType);

  CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);

  if Tok[j + 1].Kind in [PLUSTOK, MINUSTOK] then
    ExpandExpression(ValType, RightValType, VarType)
  else
    ExpandExpression(ValType, RightValType, 0);

  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  if Tok[j + 1].Kind in [PLUSTOK, MINUSTOK] then ResizeType(ValType);		// dla PLUSTOK, MINUSTOK rozszerz typ wyniku

  j := k;
  end;

Result := j;
end;// CompileSimpleExpression


function CompileExpression(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType, ConstValType, isZero: Byte;
  sLeft, sRight, cRight: Boolean;
  ConstVal, ConstValRight: Int64;
  ftmp: TFloat;
begin

 ftmp[0]:=0;
 ftmp[1]:=0;

 isZero := INTEGERTOK;

 cRight:=false;

 if SafeCompileConstExpression(i, ConstVal, ValType, VarType, False) then begin

   if (VarType in RealTypes) and (ValType in IntegerTypes) then begin
    Int2Float(ConstVal);
    ValType := VarType;
   end;

   if (ValType = SINGLETOK) or ((VarType = SINGLETOK) and (ValType in RealTypes)) then begin
     move(ConstVal, ftmp, sizeof(ftmp));
     ConstVal := ftmp[1];
     ValType := SINGLETOK;
     VarType := SINGLETOK;
   end;

   if ConstVal = 0 then isZero := BYTETOK;
   if ConstVal < 0 then isZero := SHORTINTTOK;

   Push(ConstVal, ASVALUE, DataSize[ValType]);

   Result := i;
   exit;
 end;

ConstValRight := 0;

sLeft:=false;
sRight:=false;

i := CompileSimpleExpression(i, ValType, VarType);

if (Tok[i].Kind = STRINGLITERALTOK) or (ValType = STRINGPOINTERTOK) then sLeft:=true else
 if (ValType in Pointers) and (Tok[i].Kind = IDENTTOK) then
  if (Ident[GetIdent(Tok[i].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i].Name^)) > 0) then sLeft:=true;


if Tok[i + 1].Kind = INTOK then writeln('IN');


if Tok[i + 1].Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
  begin

  j := CompileSimpleExpression(i + 2, RightValType, VarType);

  k := i + 2;
  if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
   if ConstValType in IntegerTypes then begin

    if ConstVal = 0 then isZero := BYTETOK;

    if ConstValType in SignedOrdinalTypes then
     if ConstVal < 0 then isZero := SHORTINTTOK;

    cRight:=true; ConstValRight:=ConstVal;
    RightValType := ConstValType;
   end;


  if (Tok[i + 2].Kind = STRINGLITERALTOK) or (RightValType = STRINGPOINTERTOK) then sRight:=true else
   if (RightValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) then
    if (Ident[GetIdent(Tok[i + 2].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i + 2].Name^)) > 0) then sRight:=true;


//  if (ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [SHORTREALTOK, REALTOK]) then
//    RightValType := ValType;

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);


//  writeln(ValType,'/',RightValType,',',isZero,',',Tok[i + 1].Kind );

  if (isZero = BYTETOK) and (ValType in UnsignedOrdinalTypes) then
   case Tok[i + 1].Kind of
    LTTOK: warning(i + 2, AlwaysFalse);			// < 0
    GETOK: warning(i + 2, AlwaysTrue);			// >= 0
   end;

  if (isZero = SHORTINTTOK) and (ValType in UnsignedOrdinalTypes) then
   case Tok[i + 1].Kind of
    EQTOK: begin					// =
	    warning(i + 2, AlwaysFalse);
	    warning(i + 2, UnreachableCode);
	   end;
    LETOK, LTTOK: warning(i + 2, AlwaysFalse);		// < , <= -x
    GTTOK, GETOK: warning(i + 2, AlwaysTrue);		// > , >= -x
   end;


//  writeln(ValType,',',RightValType,' / ',ConstValRight);

  if sLeft or sRight then   else   GetCommonType(j, ValType, RightValType);


  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

// !!! wyjatek !!! porownanie typow tego samego rozmiaru, ale z roznymi znakami

   if ((ValType in SignedOrdinalTypes) and (RightValType in UnsignedOrdinalTypes)) or ((ValType in UnsignedOrdinalTypes) and (RightValType in SignedOrdinalTypes)) then
   if DataSize[ValType] = DataSize[RightValType] then
   { if ValType in UnsignedOrdinalTypes then} begin

     case DataSize[ValType] of
      1: begin

	  if cRight and ( (ConstValRight >= Low(shortint)) and (ConstValRight <= High(shortint)) ) then		// gdy nie przekracza zakresu dla typu SHORTINT
	   RightValType:=ValType
	  else begin
	   ExpandParam_m1(SMALLINTTOK, ValType);
	   ExpandParam(SMALLINTTOK, RightValType);
	   ValType:=SMALLINTTOK; RightValType:=SMALLINTTOK;
	  end;

	 end;

      2: begin

	  if cRight and ( (ConstValRight >= Low(smallint)) and (ConstValRight <= High(smallint)) ) then		// gdy nie przekracza zakresu dla typu SMALLINT
	   RightValType:=ValType
	  else begin
	   ExpandParam_m1(INTEGERTOK, ValType);
	   ExpandParam(INTEGERTOK, RightValType);
	   ValType:=INTEGERTOK; RightValType:=INTEGERTOK;
	  end;

	 end;
     end;
{
    end else begin

     case DataSize[ValType] of
      1: ExpandExpression(RightValType, SMALLINTTOK, 0);
      2: ExpandExpression(RightValType, INTEGERTOK, 0);
     end;
}
    end;

  ExpandExpression(ValType, RightValType, 0);

  if sLeft or sRight then begin

   if sLeft and sRight then
    GenerateRelationString(Tok[i + 1].Kind, STRINGTOK, STRINGTOK)
   else
   if ValType = CHARTOK then
    GenerateRelationString(Tok[i + 1].Kind, CHARTOK, STRINGTOK)
   else
   if RightValType = CHARTOK then
    GenerateRelationString(Tok[i + 1].Kind, STRINGTOK, CHARTOK)
   else
    GetCommonType(j, ValType, RightValType);

  end else
   GenerateRelation(Tok[i + 1].Kind, ValType);

  i := j;

  ValType:=BOOLEANTOK;
  end;

Result := i;
end;// CompileExpression


procedure SaveBreakAddress;
begin

  Inc(BreakPosStackTop);
  BreakPosStack[BreakPosStackTop] := CodeSize;

end;


procedure RestoreBreakAddress;
begin

  asm65('b_'+IntToHex(BreakPosStack[BreakPosStackTop], 4));
  dec(BreakPosStackTop);

  ResetOpty;

end;


function CompileBlockRead(var i: integer; IdentIndex: integer; IdentBlock: integer): integer;
var NumActualParams, idx: integer;
    ActualParamType, AllocElementType: byte;

begin

   NumActualParams := 0;
   AllocElementType := 0;

     repeat
       Inc(NumActualParams);

       StartOptimization(i);

       if NumActualParams > 3 then
	iError(i, WrongNumParameters, IdentBlock);

       if fBlockRead_ParamType[NumActualParams] in Pointers then begin

	if Tok[i + 2].Kind <> IDENTTOK then
	 iError(i + 2, VariableExpected)
	else begin
	 idx:=GetIdent(Tok[i + 2].Name^);


	if (Ident[idx].Kind = CONSTTOK)	then begin

	 if not (Ident[idx].DataType in Pointers) or (Elements(idx) = 0) then
	  iError(i + 2, VariableExpected);

	end else

	 if (Ident[idx].Kind <> VARTOK) then
	  iError(i + 2, VariableExpected);

	end;

	i := CompileAddress(i + 1, ActualParamType, AllocElementType, fBlockRead_ParamType[NumActualParams] in Pointers);

       end else
	i := CompileExpression(i + 2 , ActualParamType);  // Evaluate actual parameters and push them onto the stack

       GetCommonType(i, fBlockRead_ParamType[NumActualParams], ActualParamType);

       ExpandParam(fBlockRead_ParamType[NumActualParams], ActualParamType);

       case NumActualParams of
	1: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.buffer');	// VarPassing
	2: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.nrecord');	// VarPassing
	3: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.numread');
       end;

     until Tok[i + 1].Kind <> COMMATOK;

     if NumActualParams < 2 then
       iError(i, WrongNumParameters, IdentBlock);

     CheckTok(i + 1, CPARTOK);

     inc(i);

     Result := NumActualParams;
end;


procedure UpdateCaseLabels(j: integer; var tb: TCaseLabelArray; lab: TCaseLabel);
var i: integer;
begin

 for i := 0 to High(tb) - 1 do
  if ( (lab.left >= tb[i].left) and (lab.left <= tb[i].right) ) or
     ( (lab.right >= tb[i].left) and (lab.right <= tb[i].right) ) or
     ( (tb[i].left >= lab.left) and (tb[i].right <= lab.right) ) then
     Error(j, 'Duplicate case label');

 i:=High(tb);

 tb[i] := lab;

 SetLength(tb, i + 2);

end;


procedure CheckAssignment(i: integer; IdentIndex: integer);
begin

 if Ident[IdentIndex].PassMethod = CONSTPASSING then
   Error(i, 'Can''t assign values to const variable');

 if Ident[IdentIndex].LoopVariable then
   Error(i, 'Illegal assignment to for-loop variable '''+Ident[IdentIndex].Name+'''');

end;


function CompileStatement(i: Integer; isAsm: Boolean = false): Integer;
var
  j, k, IdentIndex, IdentTemp, NumActualParams, NumCharacters: Integer;
  IfLocalCnt, CaseLocalCnt, NumCaseStatements: integer;
  Param: TParamList;
  ExpressionType, IndirectionLevel, ActualParamType, ConstValType, VarType, SelectorType: Byte;
  Value, ConstVal, ConstVal2: Int64;
  Down, ExitLoop, yes: Boolean;			  // To distinguish TO / DOWNTO loops
  CaseLabelArray: TCaseLabelArray;
  CaseLabel: TCaseLabel;
  Name, EnumName, svar, par1, par2: string;
begin

Result:=i;

FillChar(Param, sizeof(Param), 0);

IdentIndex := 0;
ExpressionType := 0;

par1:='';
par2:='';

case Tok[i].Kind of
  IDENTTOK:
    begin
    IdentIndex := GetIdent(Tok[i].Name^);

    if (IdentIndex > 0) and (Ident[IdentIndex].Kind = FUNC)  and (BlockStackTop > 1) then
     for j:=1 to NumIdent do
      if (Ident[j].ProcAsBlock = NumBlocks) and (Ident[j].Kind = FUNC) then begin
	if Ident[j].Name = Ident[IdentIndex].Name then IdentIndex := GetIdentResult(NumBlocks);
	Break;
      end;


    if IdentIndex > 0 then

      case Ident[IdentIndex].Kind of

	CONSTTOK, TYPETOK, ENUMTOK:
	  begin

	    iError(i, VariableExpected);

	  end;

	LABELTYPE:
	  begin
	   CheckTok(i + 1, COLONTOK);

	   if Ident[IdentIndex].isInit then
	     Error(i , 'Label already defined');

	   Ident[IdentIndex].isInit := true;

	   asm65(Ident[IdentIndex].Name);

	   Result := i ;//+ 1;

	  end;

	VARIABLE:								// Variable or array element assignment
	  begin

	   StartOptimization(i + 1);

	   if Tok[i + 1].Kind = DEREFERENCETOK then				// With dereferencing '^'
	    begin
	    if not (Ident[IdentIndex].DataType in Pointers) then
	      iError(i + 1, IncompatibleTypeOf, IdentIndex);

	   // VarType := INTEGERTOK;
	    VarType := Ident[IdentIndex].AllocElementType;

	    IndirectionLevel := ASPOINTERTOPOINTER;

	    if Tok[i + 2].Kind = OBRACKETTOK then
	    begin

	    inc(i);
	    if not (Ident[IdentIndex].DataType in Pointers) then
	      iError(i + 1, IncompatibleTypeOf, IdentIndex);

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	    i := CompileArrayIndex(i, IdentIndex);

	    CheckTok(i + 1, CBRACKETTOK);

	   // VarType := Ident[IdentIndex].AllocElementType;

	    end else

	    if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin

	     IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);		// pp^.field :=
// !@!@
// writeln('xxx,',Tok[i+3].line);

	     if IdentTemp < 0 then
	      Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	     VarType := IdentTemp shr 16;
	     par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	     optyBP2 := '';

	     inc(i, 2);

	    end;

	    i := i + 1;
	    end
	  else if (Tok[i + 1].Kind = OBRACKETTOK) then				// With indexing
	    begin
	    if not (Ident[IdentIndex].DataType in Pointers) then
	      iError(i + 1, IncompatibleTypeOf, IdentIndex);

// asm65(#9'spectrum');       // tab[] := xxx

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	    i := CompileArrayIndex(i, IdentIndex);

	    VarType := Ident[IdentIndex].AllocElementType;
// !@!@
// 	    writeln(Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].Name,',',VarType,',',Ident[IdentIndex].DataType) ;

	    if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin
	       IndirectionLevel := ASPOINTERTOARRAYRECORD;

	       IdentTemp:=GetIdent(Ident[IdentIndex].Name+ '.' + Tok[i + 3].Name^);

	       if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	       VarType := Ident[IdentTemp].AllocElementType;
	       par2 := '$'+IntToHex(Ident[IdentTemp].Value-DATAORIGIN, 2);

	       optyBP2 := '';

	       inc(i, 2);

	    end else
	     if VarType in [RECORDTOK, OBJECTTOK] then VarType := POINTERTOK;

	    //CheckTok(i + 1, CBRACKETTOK);

	    inc(i);

	    end
	  else								// Without dereferencing or indexing
	    begin

	    if (Ident[IdentIndex].PassMethod = VARPASSING) then begin
	     IndirectionLevel := ASPOINTERTOPOINTER;

	     if Ident[IdentIndex].AllocElementType = UNTYPETOK then
	      VarType := POINTERTOK
	     else
	     VarType := Ident[IdentIndex].AllocElementType;

	    end else begin
	     IndirectionLevel := ASPOINTER;
	     VarType := Ident[IdentIndex].DataType;
	    end;

	    end;


	    CheckTok(i + 1, ASSIGNTOK);

	    if (Ident[IdentIndex].DataType in Pointers) and
	       (Ident[IdentIndex].AllocElementType = CHARTOK) and
	       (Ident[IdentIndex].NumAllocElements > 0) and
	       ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (Ident[IdentIndex].PassMethod = VARPASSING)) ) and
	       (Tok[i + 2].Kind in [STRINGLITERALTOK, CHARLITERALTOK, IDENTTOK]) then
	      begin

	      case Tok[i + 2].Kind of

 // Character assignment to pointer  f:='a'

		CHARLITERALTOK:
		begin

		 Ident[IdentIndex].isInit := true;

		 StopOptimization;

		 case IndirectionLevel of

		     ASPOINTERTOPOINTER:
		     begin
		       asm65(#9'ldy #$00');
		       asm65(#9'mwa '+Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'mva #$01 (:bp2),y');
		       asm65(#9'iny');
		       asm65(#9'mva #$'+IntToHex(Tok[i + 2].Value , 2)+' (:bp2),y');
		     end;

		     ASPOINTERTOARRAYORIGIN:
		     begin
		       asm65(#9'mwa '+Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'ldy :STACKORIGIN,x');
		       asm65(#9'mva #$'+IntToHex(Tok[i + 2].Value , 2)+' (:bp2),y');

		       a65(__subBX);
		     end;

		     ASPOINTER:
		     begin
		       asm65(#9'mva #1 '+GetLocalName(IdentIndex, 'adr.'));
		       asm65(#9'mva #$'+IntToHex(Tok[i + 2].Value , 2)+' '+GetLocalName(IdentIndex, 'adr.')+'+1');
		     end;

		 end;	    // case IndirectionLevel

		Result := i + 2;
		end;	     // case CHARLITERALTOK

 // String assignment to pointer  f:='string'

		STRINGLITERALTOK:
		begin

		Ident[IdentIndex].isInit := true;

		StopOptimization;

		ResetOpty;

		NumCharacters := Min(Tok[i + 2].StrLength, Ident[IdentIndex].NumAllocElements - 1);

		 case IndirectionLevel of

		   ASPOINTERTOPOINTER:

		   if Tok[i + 2].StrLength = 0 then begin
		     asm65(#9'ldy #$00');
		     asm65(#9'mwa '+Ident[IdentIndex].Name+' :bp2');
		     asm65(#9'mva #$00 (:bp2),y');
		   end else
		    if pos('.', Ident[IdentIndex].Name) > 0 then begin

		     asm65(#9'mwa #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' @move.src');
		     asm65(#9'adw '+copy(Ident[IdentIndex].Name,1, pos('.', Ident[IdentIndex].Name)-1) + ' #' +Ident[IdentIndex].Name +'-DATAORIGIN @move.dst');
		     asm65(#9'mwa #'+IntToStr(Succ(NumCharacters))+' @move.cnt');
		     asm65(#9'jsr @move');

		    end else
		     asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' '+Ident[IdentIndex].Name+' #'+IntToStr(Succ(NumCharacters)));

		   ASPOINTERTOARRAYORIGIN:
		   GetCommonType(i + 1, CHARTOK, POINTERTOK);

		   ASPOINTER:
		   begin

		     if Tok[i + 2].StrLength = 0 then
		      asm65(#9'mva #$00 '+GetLocalName(IdentIndex, 'adr.'))
		     else
		      if Ident[IdentIndex].DataType = POINTERTOK then
		       asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN + 1, 4)+' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(Succ(NumCharacters)))
		      else
		       asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(Succ(NumCharacters)));

		     if Succ(Tok[i + 2].StrLength) > Ident[IdentIndex].NumAllocElements then begin
		      Warning(i + 2, ShortStringLength);
		      asm65(#9'mva #'+IntToStr(NumCharacters)+' '+GetLocalName(IdentIndex, 'adr.'));    //adr.'+Ident[IdentIndex].Name);
		     end;

		   end;

		 end;	     // case IndirectionLevel

		Result := i + 2;
		end;	     // case STRINGLITERALTOK


		IDENTTOK:
		begin

		 Ident[IdentIndex].isInit := true;

		 StopOptimization;

		 Result := CompileExpression(i + 2, ExpressionType, VarType);      // Right-hand side expression

		 asm65('');

 // Character assignment to pointer  var f:=c

		if ExpressionType = CHARTOK then begin

		 case IndirectionLevel of

		   ASPOINTER:
		     begin

		      asm65(#9'mva :STACKORIGIN,x '+GetLocalName(IdentIndex, 'adr.')+'+1');
		      asm65(#9'mva #$01 '+GetLocalName(IdentIndex, 'adr.'));

		      a65(__subBX);
		     end;

		   ASPOINTERTOPOINTER:
		     begin

		       asm65(#9'ldy #$00');
		       asm65(#9'mwa '+Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'mva #$01 (:bp2),y');
		       asm65(#9'iny');
		       asm65(#9'mva :STACKORIGIN,x (:bp2),y');

		       a65(__subBX);
		     end;

		   ASPOINTERTOARRAYORIGIN:
		     begin

		      asm65(#9'mwa '+Ident[IdentIndex].Name+' :bp2');
		      asm65(#9'ldy :STACKORIGIN-1,x');
		      asm65(#9'lda :STACKORIGIN,x');
		      asm65(#9'sta (:bp2),y');

		      a65(__subBX);
		      a65(__subBX);
		     end;

		 else
		    GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex);
		 end;// case IndirectionLevel

		end else

 // String assignment to pointer  var f:=txt

		if ExpressionType in Pointers then begin

		  Ident[IdentIndex].isInit := true;

		  StopOptimization;

		  ResetOpty;

		  case IndirectionLevel of

		    ASPOINTER, ASPOINTERTOPOINTER:
		      begin

		       if Ident[IdentIndex].DataType = POINTERTOK then
			asm65(#9'@moveSTRING_1 '+Ident[IdentIndex].Name)
		       else
			asm65(#9'@moveSTRING '+Ident[IdentIndex].Name);

		       a65(__subBX);
		      end;

		  else
		   GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex);
		  end;// case IndirectionLevel

		end else
		 iError(i, IncompatibleTypes, 0, ExpressionType, VarType);

		end;


	      end; // case Tok[i + 2].Kind

	      end // if
	    else
	      begin							     // Usual assignment


	      if VarType = UNTYPETOK then
		Error(i, 'Assignments to formal parameters and open arrays are not possible');

	      Result := CompileExpression(i + 2, ExpressionType, VarType);      // Right-hand side expression

	      k := i + 2;

	      RealTypeConversion(VarType, ExpressionType);

	      if (VarType in [SHORTREALTOK, REALTOK]) and (ExpressionType in [SHORTREALTOK, REALTOK]) then
		ExpressionType := VarType;


	      if (VarType = POINTERTOK)	and (ExpressionType = STRINGPOINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType = CHARTOK) then begin		// +1
		  asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'add #$01');
		  asm65(#9'sta :STACKORIGIN,x');
		  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'adc #$00');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		end else
		 if Ident[IdentIndex].AllocElementType = UNTYPETOK then
		  iError(i + 1, IncompatibleTypes, IdentIndex, STRINGPOINTERTOK, POINTERTOK)
		 else
		  GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, STRINGPOINTERTOK);

	      end;

//       if  (Tok[k].Kind = IDENTTOK) then
//	  writeln(VarType,',', ExpressionType,' - ', Ident[IdentIndex].AllocElementType, ' - ', Ident[IdentIndex].DataType,'|',Ident[GetIdent(Tok[k].Name^)].DataType,' / ',IndirectionLevel);

	      CheckAssignment(i + 1, IdentIndex);

	      if IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2] then begin

	       if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then
		 GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType)
	       else
	         GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, ExpressionType);

	      end else
	       if (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) then begin
//c64
		  if (ExpressionType in Pointers) and (Tok[k].Kind = IDENTTOK) then begin

		    IdentTemp := GetIdent(Tok[k].Name^);

		    {if (Tok[i + 3].Kind <> OBRACKETTOK) and ((Elements(IdentTemp) <> Elements(IdentIndex)) or (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType)) then
		     halt//iError(k, IncompatibleTypesArray, GetIdent(Tok[k].Name^), ExpressionType )
		    else
		     if (Elements(IdentTemp) > 0) and (Tok[i + 3].Kind <> OBRACKETTOK) then
		      iError(k, IncompatibleTypesArray, IdentTemp, ExpressionType )
		    else}

		    if Ident[IdentTemp].AllocElementType = RECORDTOK then
		    // GetCommonType(i + 1, VarType, RECORDTOK)
		    else

		    if (Ident[IdentTemp].AllocElementType <> UNTYPETOK) and (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType) and (Tok[k + 1].Kind <> OBRACKETTOK) then begin

		     if (Ident[IdentTemp].NumAllocElements > 0) and ( Ident[IdentIndex].NumAllocElements > 0) then
		      iError(k, IncompatibleTypesArray, IdentTemp, -IdentIndex)
		     else
		      iError(k, IncompatibleTypesArray, IdentTemp, ExpressionType);

		    end;

		 end else
		   GetCommonType(i + 1, VarType, ExpressionType);

	       end else
			     if (VarType = ENUMTYPE) {and (Tok[k].Kind = IDENTTOK)} then begin

				  if (Tok[k].Kind = IDENTTOK) then
				    IdentTemp := GetIdent(Tok[k].Name^)
				  else
				    IdentTemp := 0;

				  if (IdentTemp > 0) and (Ident[IdentTemp].Kind = USERTYPE) and (Ident[IdentTemp].DataType = ENUMTYPE) then begin

				    if Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements then
				      iError(i, IncompatibleEnum, 0, IdentTemp, IdentIndex);

				  end else
				  if (IdentTemp > 0) and (Ident[IdentTemp].Kind = ENUMTYPE) then begin

				    if Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].NumAllocElements then
				      iError(i, IncompatibleEnum, 0, IdentTemp, IdentIndex);

				  end else
				  if (IdentTemp > 0) and (Ident[IdentTemp].DataType = ENUMTYPE) then begin

				    if Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].NumAllocElements then
				      iError(i, IncompatibleEnum, 0, IdentTemp, IdentIndex);

				  end else
 				   iError(i, IncompatibleEnum, 0, -ExpressionType, IdentIndex);

				 end else begin

				  if (Tok[k].Kind = IDENTTOK) then
				    IdentTemp := GetIdent(Tok[k].Name^)
				  else
				    IdentTemp := 0;

				  if (IdentTemp > 0) and ((Ident[IdentTemp].Kind = ENUMTYPE) or (Ident[IdentTemp].DataType = ENUMTYPE)) then
 				   iError(i, IncompatibleEnum, 0, IdentTemp, -ExpressionType)
				  else
				   GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);

				 end;


	      ExpandParam(VarType, ExpressionType);			     // :=

	      Ident[IdentIndex].isInit := true;


	      if (VarType in [RECORDTOK, OBJECTTOK]) then begin

	       IdentTemp := GetIdent(Tok[k].Name^);

	       if ExpressionType in [RECORDTOK, OBJECTTOK] then begin

		svar := Tok[k].Name^;

		if Ident[IdentTemp].DataType = RECORDTOK then
		  Name := 'adr.' + svar
		else
		  Name := svar;

		if Ident[IdentTemp].Kind = FUNCTIONTOK then begin
		  svar := GetLocalName(IdentTemp);

		  IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		  Name := svar + '.adr.result';
		  svar := svar + '.result';
		end;
// sick
//writeln( Ident[IdentIndex].Name,',', Ident[IdentIndex].NumAllocElements ,' / ', Ident[IdentTemp].Name,',', Ident[IdentTemp].NumAllocElements );
//writeln( '>', Ident[IdentTemp].Name,',', Ident[IdentTemp].DataType, ',', Ident[IdentTemp].AllocElementTYpe );
//writeln(Types[5].Field[0].Name);


		if Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements then	  // porownanie indeksow do tablicy TYPES
		  iError(i, IncompatibleTypeOf, IdentTemp);

		a65(__subBX);
		StopOptimization;

		ResetOpty;

		if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = RECORDTOK) and (RecordSize(IdentIndex) <= 4) then
		  asm65(#9':'+IntToStr(RecordSize(IdentIndex))+' mva '+Name+'+# '+GetLocalName(IdentIndex, 'adr.')+'+#')
		else
		 if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentTemp].DataType in Pointers) then
		  asm65(#9'@move '+Name+' '+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)))
		 else
		  if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType in Pointers) then begin

		   if RecordSize(IdentIndex) <= 8 then begin

		    asm65(#9'mwa '+Name+' :bp2');
		    asm65(#9'ldy #0');
		    asm65(#9'lda (:bp2),y');
		    asm65(#9'sta adr.'+Ident[IdentIndex].Name);

		    for k:=1 to RecordSize(IdentIndex)-1 do begin
		     asm65(#9'iny');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9'sta adr.'+Ident[IdentIndex].Name+'+'+IntToStr(k));
		    end;

		   end else
		    asm65(#9'@move '+Name+' #adr.'+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)));

 		  end else
		   asm65(#9'@move #'+Name+' '+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)));

     	       end else	   // ExpressionType <> RECORDTOK+OBJECTTOK
		 GetCommonType(i + 1, ExpressionType, RECORDTOK);

	      end else
		if (VarType in Pointers) and ( (ExpressionType in Pointers) and (Tok[k].Kind = IDENTTOK) ) and
		   ( not (Ident[IdentIndex].AllocElementType in Pointers + [RECORDTOK, OBJECTTOK]) and not (Ident[GetIdent(Tok[k].Name^)].AllocElementType in Pointers + [RECORDTOK, OBJECTTOK])  ) and
		   (({DataSize[Ident[IdentIndex].AllocElementType] *} Ident[IdentIndex].NumAllocElements > 1) and ({DataSize[Ident[GetIdent(Tok[k].Name^)].AllocElementType] *} Ident[GetIdent(Tok[k].Name^)].NumAllocElements > 1)) then begin

		j := Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType];

		IdentTemp := GetIdent(Tok[k].Name^);

		Name := 'adr.'+Tok[k].Name^;
		svar := Tok[k].Name^;

		if IdentTemp > 0 then begin

		  if Ident[IdentTemp].Kind = FUNCTIONTOK then begin

		   svar := GetLocalName(IdentTemp);

		   IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		   Name := svar+'.adr.result';
		   svar := svar+'.result';

		  end;


		 if Ident[IdentTemp].AllocElementType <> RECORDTOK then
		  if (j <> integer(Ident[IdentTemp].NumAllocElements * DataSize[Ident[IdentTemp].AllocElementType])) then
		    iError(i, IncompatibleTypesArray, IdentTemp, -IdentIndex);


	   	 a65(__subBX);
		 StopOptimization;

		 ResetOpty;

		 if (j <= 4) and (Ident[IdentTemp].AllocElementType <> RECORDTOK) then
		   asm65(#9':'+IntToStr(j)+' mva '+Name+'+# '+GetLocalName(IdentIndex, 'adr.')+'+#')
		 else
		   asm65(#9'@move '+svar+' '+Ident[IdentIndex].Name+' #'+IntToStr(j));

		end;

	       end else
		GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

	      end;

//	    StopOptimization;

	  end;// VARIABLE


	PROC, FUNC:						// Procedure, Function (without assignment) call
	  begin

//	  yes := (Ident[IdentIndex].Kind = FUNC);

	  if (Tok[i+1].Kind = OPARTOK) and (Tok[i+2].Kind=CPARTOK) then begin
	   inc(i, 2);
	   j := 0;
	  end else
	   Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc( Ident[IdentIndex].Name, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then
	      iError(i, CantDetermine, IdentIndex)
	     else
              iError(i, WrongNumParameters, IdentIndex);

	    IdentIndex := IdentTemp;

//	  end;

	  CompileActualParameters( i, IdentIndex);

	  if Ident[IdentIndex].Kind = FUNC then a65(__subBX);	// zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji

	  Result := i;
	  end;// PROC

      else
	Error(i, 'Assignment or procedure call expected but ' + Ident[IdentIndex].Name + ' found');
      end// case Ident[IdentIndex].Kind
    else
      iError(i, UnknownIdentifier)
    end;

  INFOTOK:
    begin

     writeln('info'); halt;

     Result := i;
    end;


  WARNINGTOK:
    begin

     writeln('warning'); halt;

     Result := i;
    end;


  ERRORTOK:
    begin

     writeln('error'); halt;

     Result := i;
    end;


  IOCHECKON:
    begin
     IOCheck := true;

     Result := i;
    end;


  IOCHECKOFF:
    begin
     IOCheck := false;

     Result := i;
    end;


  GOTOTOK:
    begin
     CheckTok(i + 1, IDENTTOK);

     IdentIndex := GetIdent(Tok[i + 1].Name^);

     if IdentIndex > 0 then begin

      if Ident[IdentIndex].Kind <> LABELTYPE then
	Error(i + 1, 'Identifier isn''t a label');

      asm65(#9'jmp '+Ident[IdentIndex].Name);

     end else
       iError(i + 1, UnknownIdentifier);

     Result := i + 1;
    end;


  BEGINTOK:
    begin

    if isAsm then
     CheckTok(i , ASMTOK);

    j := CompileStatement(i + 1);
    while (Tok[j + 1].Kind = SEMICOLONTOK) or ((Tok[j + 1].Kind = COLONTOK) and (Tok[j].Kind = IDENTTOK)) do j := CompileStatement(j + 2);

    CheckTok(j + 1, ENDTOK);

    Result := j + 1;
    end;


  CASETOK:
    begin
    CaseLocalCnt := CaseCnt;
    inc(CaseCnt);

    ResetOpty;

    EnumName := '';

    StopOptimization;    // !!! potrzebujemy zachowac na stosie testowana wartosc

    i := CompileExpression(i + 1, SelectorType);

	if Tok[i].Kind = IDENTTOK then
	 EnumName := GetEnumName(GetIdent(Tok[i].Name^));


    if DataSize[SelectorType]<>1 then
     Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, OFTOK);

    GenerateCaseProlog;

    NumCaseStatements := 0;

    inc(i, 2);

    SetLength(CaseLabelArray, 1);

    repeat       // Loop over all cases

      repeat     // Loop over all constants for the current case
	i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

//	 ConstVal:=ConstVal and $ff;
	//warning(i, RangeCheckError, 0, ConstValType, SelectorType);

	GetCommonType(i, ConstValType, SelectorType);

	if (Tok[i].Kind = IDENTTOK) then
	 if ((EnumName = '') and (GetEnumName(GetIdent(Tok[i].Name^)) <> '')) or
  	    ((EnumName <> '') and (GetEnumName(GetIdent(Tok[i].Name^)) <> EnumName)) then
		Error(i, 'Constant and CASE types do not match');

	if Tok[i + 1].Kind = RANGETOK then				      // Range check
	  begin
	  i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

//	  ConstVal2:=ConstVal2 and $ff;
	  //warning(i, RangeCheckError, 0, ConstValType, SelectorType);

	  GetCommonType(i, ConstValType, SelectorType);

	  if ConstVal > ConstVal2 then
	   Error(i, 'Upper bound of case range is less than lower bound');

	  GenerateCaseRangeCheck(ConstVal, ConstVal2, SelectorType);

	  CaseLabel.left:=ConstVal;
	  CaseLabel.right:=ConstVal2;
	  end
	else begin
	  GenerateCaseEqualityCheck(ConstVal, SelectorType);		    // Equality check

	  CaseLabel.left:=ConstVal;
	  CaseLabel.right:=ConstVal;
	end;

	UpdateCaseLabels(i, CaseLabelArray, CaseLabel);

	inc(i);

	ExitLoop := FALSE;
	if Tok[i].Kind = COMMATOK then
	  inc(i)
	else
	  ExitLoop := TRUE;
      until ExitLoop;


      CheckTok(i, COLONTOK);

      GenerateCaseStatementProlog(CaseLabel.equality);

      ResetOpty;

      asm65('@');

      j := CompileStatement(i + 1);
      i := j + 1;
      GenerateCaseStatementEpilog(CaseLocalCnt);

      Inc(NumCaseStatements);

      ExitLoop := FALSE;
      if Tok[i].Kind <> SEMICOLONTOK then
	begin
	if Tok[i].Kind = ELSETOK then	      // Default statements
	  begin

	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	  end;
	ExitLoop := TRUE;
	end
      else
	begin
	inc(i);

	if Tok[i].Kind = ELSETOK then begin
	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	end;

	if Tok[i].Kind = ENDTOK then ExitLoop := TRUE;

	end

    until ExitLoop;

    CheckTok(i, ENDTOK);

    GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

    ResetOpty;

    Result := i;
    end;


  IFTOK:
    begin
    ifLocalCnt := ifCnt;
    inc(ifCnt);

//    ResetOpty;

    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType, 0);	// ??? warunek jako INTEGER, zeby wyrazenia ze znakiem dzialaly poprawnie

    GetCommonType(j, BOOLEANTOK, ExpressionType);	// wywali blad jesli warunek bedzie typu IF A THEN

    CheckTok(j + 1, THENTOK);

    SaveToSystemStack(ifLocalCnt);		// Save conditional expression at expression stack top onto the system stack

    GenerateIfThenCondition;			// Satisfied if expression is not zero
    GenerateIfThenProlog;

    inc(CodeSize);				// !!! aby dzialaly petle WHILE, REPEAT po IF

    StopOptimization;				// !!! konczymy przed CompileStatement

    j := CompileStatement(j + 2);

    GenerateIfThenEpilog;
    Result := j;

      if Tok[j + 1].Kind = ELSETOK then
	begin

	RestoreFromSystemStack(ifLocalCnt);	// Restore conditional expression
	GenerateElseCondition;			// Satisfied if expression is zero
	GenerateIfThenProlog;

	optyBP2 := '';

	j := CompileStatement(j + 2);
	GenerateIfThenEpilog;
	Result := j;
	end
      else
	RemoveFromSystemStack;			// Remove conditional expression

    end;

  WHILETOK:
    begin
    inc(CodeSize);				// !!! aby dzialaly zagniezdzone WHILE

    asm65(#13#10'; --- WhileProlog');

    ResetOpty;

    GenerateRepeatUntilProlog;			// Save return address used by GenerateWhileDoEpilog

    SaveBreakAddress;

    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType);

    GetCommonType(j, BOOLEANTOK, ExpressionType);

    CheckTok(j + 1, DOTOK);

      asm65(#13#10'; --- WhileDoCondition');
      GenerateWhileDoCondition;			// Satisfied if expression is not zero

      asm65(#13#10'; --- WhileDoProlog');
      GenerateWhileDoProlog;

      StopOptimization;

      j := CompileStatement(j + 2);

      asm65(#13#10'; --- WhileDoEpilog');
      asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop], 4));

      GenerateWhileDoEpilog;

      RestoreBreakAddress;

      Result := j;

    end;

  REPEATTOK:
    begin
    inc(CodeSize);			    // !!! aby dzialaly zagniezdzone REPEAT

    asm65(#13#10'; --- RepeatUntilProlog');

    ResetOpty;

    GenerateRepeatUntilProlog;

    SaveBreakAddress;

    StartOptimization(i + 1);

    j := CompileStatement(i + 1);

    while Tok[j + 1].Kind = SEMICOLONTOK do
      j := CompileStatement(j + 2);

    CheckTok(j + 1, UNTILTOK);

    StartOptimization(j + 2);

    j := CompileExpression(j + 2, ExpressionType);

    GetCommonType(j, BOOLEANTOK, ExpressionType);

    asm65(#13#10'; --- RepeatUntilCondition');
    GenerateRepeatUntilCondition;

    asm65(#13#10'; --- RepeatUntilEpilog');
    asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop], 4));

    GenerateRepeatUntilEpilog;

    RestoreBreakAddress;

    Result := j;
    end;

  FORTOK:
    begin
    if Tok[i + 1].Kind <> IDENTTOK then
      iError(i + 1, IdentifierExpected)
    else
      begin
      IdentIndex := GetIdent(Tok[i + 1].Name^);

      inc(CodeSize);		      // !!! aby dzialaly zagniezdzone FOR

      if IdentIndex > 0 then
	if not ( (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].DataType in OrdinalTypes) ) then
	  Error(i + 1, 'Ordinal variable expected as ''FOR'' loop counter')
	 else
	 if (Ident[IdentIndex].isInitialized) or (Ident[IdentIndex].PassMethod <> VALPASSING) then
	  Error(i + 1, 'Simple local variable expected as FOR loop counter')
	 else
	    begin

	    CheckTok(i + 2, ASSIGNTOK);

	    Ident[IdentIndex].LoopVariable := true;

	    asm65('; For');

	    ResetOpty;

	    j := i + 3;

	    StartOptimization(j);


	    if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then
	      Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType])
	    else begin
	      j := CompileExpression(j, ExpressionType);
	      ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
	    end;

	    if not (ExpressionType in OrdinalTypes) then
	      iError(j, OrdinalExpectedFOR);


	    GenerateAssignment(ASPOINTER, DataSize[Ident[IdentIndex].DataType], IdentIndex);

	    if not (Tok[j + 1].Kind in [TOTOK, DOWNTOTOK]) then
	      Error(j + 1, '''TO'' or ''DOWNTO'' expected but ' + GetSpelling(j + 1) + ' found')
	    else
	      begin
	      Down := Tok[j + 1].Kind = DOWNTOTOK;


	      inc(j, 2);

	      StartOptimization(j);


	{$IFDEF OPTIMIZECODE}

	      if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin
		Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);
		DefineIdent(j, '@FORTMP_'+IntToStr(CodeSize), CONSTANT, Ident[IdentIndex].DataType, 0, 0, ConstVal, Tok[j].Kind);
	      end else begin
		j := CompileExpression(j, ExpressionType);
		ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
		DefineIdent(j, '@FORTMP_'+IntToStr(CodeSize), VARIABLE, Ident[IdentIndex].DataType, 0, 0, 0);
	      end;

	{$ELSE}

		j := CompileExpression(j, ExpressionType);
		ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
		DefineIdent(j, '@FORTMP_'+IntToStr(CodeSize), VARIABLE, Ident[IdentIndex].DataType, 0, 0, 0);

	{$ENDIF}


	      if not (ExpressionType in OrdinalTypes) then
		iError(j, OrdinalExpectedFOR);


	      IdentTemp := GetIdent('@FORTMP_'+IntToStr(CodeSize));
	      GenerateAssignment(ASPOINTER, DataSize[Ident[IdentTemp].DataType], IdentTemp);


	      asm65('; To');

	      GenerateRepeatUntilProlog;      // Save return address used by GenerateForToDoEpilog

	      SaveBreakAddress;

	      asm65(#13#10'; ForToDoCondition');

	      StartOptimization(j);

	      Push(Ident[IdentTemp].Value, ASPOINTER, DataSize[Ident[IdentTemp].DataType], IdentTemp);

	      GenerateForToDoCondition(DataSize[Ident[IdentIndex].DataType], Down, IdentIndex);  // Satisfied if counter does not reach the second expression value

	      StopOptimization;

	      CheckTok(j + 1, DOTOK);

		//asm65(#13#10'; ForToDoProlog');

		GenerateForToDoProlog;
		j := CompileStatement(j + 2);

		asm65(#13#10'; ForToDoEpilog');
		asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop], 4));

		GenerateForToDoEpilog(DataSize[Ident[IdentIndex].DataType], Down, IdentIndex);

		RestoreBreakAddress;

		Result := j;

	      end;

	    Ident[IdentIndex].LoopVariable := false;

	    end
      else
	iError(i + 1, UnknownIdentifier);
      end;
    end;


  ASSIGNFILETOK:
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	asm65('; AssignFile');

	if not((Ident[IdentIndex].DataType = FILETOK) or (Ident[IdentIndex].AllocElementType = FILETOK)) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, COMMATOK);

	StartOptimization(i + 4);

	if Tok[i + 4].Kind = STRINGLITERALTOK then
	 Note(i + 4, 'Only uppercase letters preceded by the drive symbol, like ''D:FILENAME.EXT'' or ''S:''');

	i := CompileExpression(i + 4, ActualParamType);
	GetCommonType(i, POINTERTOK, ActualParamType);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.pfname');

	StartOptimization(i);

	Push(0, ASVALUE, DataSize[BYTETOK]);

	GenerateAssignment(ASPOINTERTOPOINTER, 1, 0, Ident[IdentIndex].Name, 's@file.status');

	Result := i + 1;
	end;


  RESETTOK:
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	asm65('; Reset');

	if not((Ident[IdentIndex].DataType = FILETOK) or (Ident[IdentIndex].AllocElementType = FILETOK)) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	StartOptimization(i + 3);

	if Tok[i + 3].Kind <> COMMATOK then begin
	 if Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] = 0 then
	  Push(128, ASVALUE, 2)
	 else
	  Push(integer(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType]), ASVALUE, 2);    // predefined record by FILE OF (default =128)

	 inc(i, 3);
	end else begin
	 i := CompileExpression(i + 4, ActualParamType);	     // custom record size
	 GetCommonType(i, WORDTOK, ActualParamType);

	 ExpandParam(WORDTOK, ActualParamType);

	 inc(i);
	end;

	CheckTok(i, CPARTOK);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

	GenerateFileOpen(IdentIndex, ioFileMode);

	Result := i;
	end;


  REWRITETOK:
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	asm65('; Rewrite');

	if not((Ident[IdentIndex].DataType = FILETOK) or (Ident[IdentIndex].AllocElementType = FILETOK)) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	StartOptimization(i + 3);

	if Tok[i + 3].Kind <> COMMATOK then begin
	 if Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] = 0 then
	  Push(128, ASVALUE, 2)
	 else
	  Push(integer(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType]), ASVALUE, 2);    // predefined record by FILE OF (default =128)

	 inc(i, 3);
	end else begin
	 i := CompileExpression(i + 4, ActualParamType);	     // custom record size
	 GetCommonType(i, WORDTOK, ActualParamType);

	 ExpandParam(WORDTOK, ActualParamType);

	 inc(i);
	end;

	CheckTok(i, CPARTOK);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

	GenerateFileOpen(IdentIndex, ioOpenWrite);

	Result := i;
	end;


  BLOCKREADTOK:
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	asm65('; BlockRead');

	if not((Ident[IdentIndex].DataType = FILETOK) or (Ident[IdentIndex].AllocElementType = FILETOK)) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, COMMATOK);

	inc(i, 2);

	NumActualParams := CompileBlockRead(i, IdentIndex, GetIdent('BLOCKREAD'));

	GenerateFileOpen(IdentIndex, ioRead, NumActualParams);

	Result := i;
	end;


  BLOCKWRITETOK:
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	asm65('; BlockWrite');

	if not((Ident[IdentIndex].DataType = FILETOK) or (Ident[IdentIndex].AllocElementType = FILETOK)) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, COMMATOK);

	inc(i, 2);
	NumActualParams := CompileBlockRead(i, IdentIndex, GetIdent('BLOCKWRITE'));

	GenerateFileOpen(IdentIndex, ioWrite, NumActualParams);

	Result := i;
	end;


  CLOSEFILETOK:
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

	asm65('; CloseFile');

	if not((Ident[IdentIndex].DataType = FILETOK) or (Ident[IdentIndex].AllocElementType = FILETOK)) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, CPARTOK);

	GenerateFileOpen(IdentIndex, ioClose);

	Result := i + 3;
	end;


  READLNTOK:
    if Tok[i + 1].Kind <> OPARTOK then begin

      if Tok[i + 1].Kind = SEMICOLONTOK then begin
       GenerateRead;

       Result := i;
      end else
       iError(i + 1, OParExpected);

    end else
      if Tok[i + 2].Kind <> IDENTTOK then
	iError(i + 2, IdentifierExpected)
      else
	begin
	IdentIndex := GetIdent(Tok[i + 2].Name^);
	if IdentIndex > 0 then
	  if (Ident[IdentIndex].Kind <> VARIABLE) {or (Ident[IdentIndex].DataType <> CHARTOK)} then
	    iError(i + 2, IncompatibleTypeOf, IdentIndex)
	  else
	    begin
//	    Push(Ident[IdentIndex].Value, ASVALUE, DataSize[CHARTOK]);

	    GenerateRead;//(Ident[IdentIndex].Value);

	    ResetOpty;

	    if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType = CHARTOK) then begin     // string

		asm65(#9'@move #@buf #'+GetLocalName(IdentIndex, 'adr.')+' #'+IntToStr(Ident[IdentIndex].NumAllocElements));

	    end else
	     if (Ident[IdentIndex].DataType = CHARTOK) then
	      asm65(#9'mva @buf+1 '+Ident[IdentIndex].Name)
	     else
	      if (Ident[IdentIndex].DataType in IntegerTypes ) then begin

		asm65(#9'@StrToInt #@buf');

		case DataSize[Ident[IdentIndex].DataType] of

		 1: asm65(#9'mva :edx '+Ident[IdentIndex].Name);

		 2: begin
		     asm65(#9'mva :edx '+Ident[IdentIndex].Name);
		     asm65(#9'mva :edx+1 '+Ident[IdentIndex].Name+'+1');
		    end;

		 4: begin
		     asm65(#9'mva :edx '+Ident[IdentIndex].Name);
		     asm65(#9'mva :edx+1 '+Ident[IdentIndex].Name+'+1');
		     asm65(#9'mva :edx+2 '+Ident[IdentIndex].Name+'+2');
		     asm65(#9'mva :edx+3 '+Ident[IdentIndex].Name+'+3');
		    end;

		end;

	      end else
	       iError(i + 2, IncompatibleTypeOf, IdentIndex);

	    CheckTok(i + 3, CPARTOK);

	    Result := i + 3;
	    end
	else
	  iError(i + 2, UnknownIdentifier);
	end;

  WRITETOK, WRITELNTOK:
    begin

    yes := (Tok[i].Kind = WRITELNTOK);

    if Tok[i + 1].Kind = SEMICOLONTOK then begin

    end else begin

     CheckTok(i + 1, OPARTOK);

     inc(i);

      repeat

	case Tok[i + 1].Kind of

	  CHARLITERALTOK:
	       begin				   // #65#32#77
		 inc(i);

		 repeat
		   asm65(#9'@print #$'+IntToHex(Tok[i].Value ,2));
		   inc(i);
		 until Tok[i].Kind <> CHARLITERALTOK;

	       end;

	STRINGLITERALTOK:			      // 'text'
	       repeat
		 GenerateWriteString(Tok[i + 1].StrAddress, ASPOINTER);
		 inc(i, 2);
	       until Tok[i + 1].Kind <> STRINGLITERALTOK;

	else

	 begin

	  j:=i + 1;

	  i := CompileExpression(j, ExpressionType);

//	  if ExpressionType = ENUMTYPE then
//	    GenerateWriteString(Tok[i].Value, ASVALUE, INTEGERTOK)	    // Enumeration argument
//	  else

	  if (ExpressionType in IntegerTypes) then
		GenerateWriteString(Tok[i].Value, ASVALUE, ExpressionType)    // Integer argument
	  else if (ExpressionType = BOOLEANTOK) then
		GenerateWriteString(Tok[i].Value, ASBOOLEAN)		  // Boolean argument
	  else if (ExpressionType = CHARTOK) then
		GenerateWriteString(Tok[i].Value, ASCHAR)		     // Character argument
	  else if ExpressionType = REALTOK then
		GenerateWriteString(Tok[i].Value, ASREAL)		     // Real argument
	  else if ExpressionType = SHORTREALTOK then
		GenerateWriteString(Tok[i].Value, ASSHORTREAL)		      // ShortReal argument
	  else if ExpressionType = SINGLETOK then
		GenerateWriteString(Tok[i].Value, ASSINGLE)		   // Single argument
	  else if ExpressionType in Pointers then begin

		if Tok[j].Kind = ADDRESSTOK then
		 IdentIndex := GetIdent(Tok[j + 1].Name^)
		else
		 if Tok[j].Kind = IDENTTOK then
		  IdentIndex := GetIdent(Tok[j].Name^)
		 else
		  iError(i, CantReadWrite);

//		writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].idType);

		if (ExpressionType = STRINGPOINTERTOK) or
		   (Ident[IdentIndex].Kind = FUNC) then
		 GenerateWriteString(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, Ident[IdentIndex].DataType)
		else
		if (Ident[IdentIndex].AllocElementType in [CHARTOK, POINTERTOK]) {and (Ident[IdentIndex].NumAllocElements = 0)} then
		 GenerateWriteString(Ident[IdentIndex].Value, ASPCHAR, Ident[IdentIndex].DataType)
		else
		 iError(i, CantReadWrite);

	  end else
	   iError(i, CantReadWrite);

	  END;

	  inc(i);

	 end;

	j:=0;

	ActualParamType := ExpressionType;

	if Tok[i].Kind = COLONTOK then			// pomijamy formatowanie wyniku value:x:x
	 repeat
	  i := CompileExpression(i + 1, ExpressionType);
	  a65(__subBX);					// zdejmujemy ze stosu
	  inc(i);

	  inc(j);

	  if j > 2 - ord(ActualParamType in OrdinalTypes) then// Break;			// maksymalnie :x:x
	    Error(i + 1, 'Illegal use of '':''');

	 until Tok[i].Kind <> COLONTOK;


      until Tok[i].Kind <> COMMATOK;     // repeat

    CheckTok(i, CPARTOK);

    end; // if Tok[i + 1].Kind = SEMICOLONTOK

    if yes then a65(__putEOL);

    Result := i;

    end;


  ASMTOK:
    begin

     ResetOpty;

     StopOptimization;		       // takich blokow nie optymalizujemy

     asm65(#13#10'; ---------------------  ASM Block '+format('%.3d',[AsmBlockIndex])+'  ---------------------'#13#10);

     asm65(AsmBlock[AsmBlockIndex]);

     inc(AsmBlockIndex);


     if isAsm then begin

      CheckTok(i + 1, SEMICOLONTOK);
      inc(i);

      CheckTok(i + 1, ENDTOK);
      inc(i);

     end;

     Result:=i;

    end;


  INCTOK, DECTOK:
// dwie wersje
// krotka i szybka, jesli mamy jeden parametr, np. INC(VAR), DEC(VAR)
// d³uga i wolna, jesli mamy tablice lub dwa parametry, np. INC(TMP[1]), DEC(VAR, VALUE+12)
    begin

      Value := 0;
      ExpressionType := 0;
      NumActualParams := 0;

      Down := (Tok[i].Kind = DECTOK);

      CheckTok(i + 1, OPARTOK);

      inc(i,2);

	  if Tok[i].Kind = IDENTTOK then begin					// first parameter
	    IdentIndex := GetIdent(Tok[i].Name^);

	    CheckAssignment(i, IdentIndex);

	    if IdentIndex = 0 then
	     iError(i, UnknownIdentifier);

	    if Ident[IdentIndex].Kind = VARIABLE then begin

	       ExpressionType := Ident[IdentIndex].DataType;

	       if ExpressionType = CHARTOK then ExpressionType := BYTETOK;	// wyjatkowo CHARTOK -> BYTETOK

	       if {((Ident[IdentIndex].DataType in Pointers) and
		   (Ident[IdentIndex].NumAllocElements=0)) or}
		   (Ident[IdentIndex].DataType = REALTOK) then
		Error(i, 'Left side cannot be assigned to')
	       else begin
		Value := Ident[IdentIndex].Value;

		if ExpressionType in Pointers then begin			// Alloc Element Type
		 ExpressionType := WORDTOK;

		 if pos('mw? '+Tok[i].Name^, optyBP2) > 0 then optyBP2 := '';
		end;

	       end;

	    end else
	     Error(i, 'Left side cannot be assigned to');

	  end else
	     iError(i , IdentifierExpected);


	  StartOptimization(i);

	  IndirectionLevel := ASPOINTER;

	  if Ident[IdentIndex].DataType in Pointers then
	   ExpressionType := WORDTOK
	  else
	   ExpressionType := Ident[IdentIndex].DataType;


	  if Ident[IdentIndex].AllocElementType = REALTOK then
	   iError(i, OrdinalExpExpected);


	  if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements>0) and ( not(Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) ) then begin

	      if Tok[i + 1].Kind = OBRACKETTOK then begin			// array index

		ExpressionType := Ident[IdentIndex].AllocElementType;

		IndirectionLevel := ASPOINTERTOARRAYORIGIN;

		i := CompileArrayIndex(i, IdentIndex);

		CheckTok(i + 1, CBRACKETTOK);

		inc(i);

	      end else
	       if Tok[i + 1].Kind = DEREFERENCETOK then
		Error(i + 1, 'Illegal qualifier')
	       else
		iError(i + 1, IncompatibleTypes, IdentIndex, Ident[IdentIndex].DataType, ExpressionType);

	  end else

	  if Tok[i + 1].Kind = DEREFERENCETOK then
	   if Ident[IdentIndex].AllocElementType = 0 then
	    Error(i + 1, 'Can''t take the address of constant expressions')
	   else begin

	     ExpressionType := Ident[IdentIndex].AllocElementType;

	     IndirectionLevel := ASPOINTERTOPOINTER;

	     inc(i);

	   end;


	 if Tok[i + 1].Kind = COMMATOK then begin				// potencjalnie drugi parametr

	   j := i + 2;
	   yes:=false;

	   if SafeCompileConstExpression(j, ConstVal, ActualParamType, Ident[IdentIndex].DataType, true) then
	    yes:=true
	   else
	     j := CompileExpression(j, ActualParamType);

	   i := j;

//	   i := CompileExpression(i + 2, ActualParamType);
	   GetCommonType(i, ExpressionType, ActualParamType);

	   inc(NumActualParams);

	   if Ident[IdentIndex].PassMethod <> VARPASSING then begin

	    ExpandParam(ExpressionType, ActualParamType);

	    if  (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

	     if yes then
	      Push(ConstVal * RecordSize(IdentIndex), ASVALUE, 2)
	     else
	      Error(i, '-- under construction --');

	    end else
	    if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType in OrdinalTypes) and (IndirectionLevel <> ASPOINTERTOPOINTER) then begin	    // zwieksz o N * DATASIZE jesli to wskaznik ale nie tablica

	     if yes then
	      Push(ConstVal * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, DataSize[Ident[IdentIndex].DataType])
	     else
	      GenerateIndexShift( Ident[IdentIndex].AllocElementType );		// * DATASIZE

	    end else
	     if yes then Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	   end else begin

	    if yes then Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	    ExpressionType := Ident[IdentIndex].AllocElementType;

	    ExpandParam(ExpressionType, ActualParamType);
	   end;


	 end else
	   if (Ident[IdentIndex].PassMethod = VARPASSING) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in OrdinalTypes + [RECORDTOK, OBJECTTOK])) then

	     if (Ident[IdentIndex].PassMethod = VARPASSING) or (Ident[IdentIndex].NumAllocElements > 0) or (IndirectionLevel = ASPOINTERTOPOINTER) then begin

	       ExpressionType := Ident[IdentIndex].AllocElementType;

	       if ExpressionType in [RECORDTOK, OBJECTTOK] then
		Push(RecordSize(IdentIndex), ASVALUE, 2)
	       else
		Push(1, ASVALUE, DataSize[ExpressionType]);

	       inc(NumActualParams);
	     end else
	     if not(Ident[IdentIndex].AllocElementType in [BYTETOK, SHORTINTTOK]) then begin
	       Push(DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, 1);   // +/- DATASIZE

	       ExpandParam(ExpressionType, BYTETOK);

	       inc(NumActualParams);
	     end;


	 if Ident[IdentIndex].PassMethod = VARPASSING then IndirectionLevel := ASPOINTERTOPOINTER;


//       NumActualParams:=1;
//	 Value:=3;

	 if NumActualParams = 0 then begin

	  if Down then
	   asm65(#13#10'; Dec(var X) -> '+InfoAboutToken(ExpressionType)+#13#10)
	  else
	   asm65(#13#10'; Inc(var X) -> '+InfoAboutToken(ExpressionType)+#13#10);

	  GenerateForToDoEpilog(DataSize[ExpressionType], Down, IdentIndex, false)    // +1, -1
	 end else
	  GenerateIncOperation(IndirectionLevel, ExpressionType, Down, IdentIndex);   // +N, -N

	 StopOptimization;

	 inc(i);

      CheckTok(i, CPARTOK);

      Result := i;
    end;


  EXITTOK:
    begin

     if TOK[i + 1].Kind = OPARTOK then begin

      i := CompileExpression(i + 2, ActualParamType);

      CheckTok(i + 1, CPARTOK);

      inc(i);

      yes := false;

      for j:=1 to NumIdent do
       if (Ident[j].ProcAsBlock = NumBlocks) and (Ident[j].Kind = FUNC) then begin

	IdentIndex := GetIdentResult(NumBlocks);

	yes := true;
	Break;
       end;

      if not yes then
	Error(i, 'Procedures cannot return a value');

      GetCommonConstType(i, Ident[IdentIndex].DataType, ActualParamType);

      GenerateAssignment(ASPOINTER, DataSize[ActualParamType], 0, 'RESULT');

     end;

     asm65('');

     asm65(#9'jmp @exit', '; exit');

     ResetOpty;

     Result := i;
    end;


  BREAKTOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'BREAK not allowed');

     asm65('');
     asm65(#9'jmp b_'+IntToHex(BreakPosStack[BreakPosStackTop], 4), '; break');

     ResetOpty;

     Result := i;
    end;


  CONTINUETOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'CONTINUE not allowed');

     asm65('');
     asm65(#9'jmp c_'+IntToHex(BreakPosStack[BreakPosStackTop], 4), '; continue');

     Result := i;
    end;


  HALTTOK:
    begin
     if Tok[i + 1].Kind = OPARTOK then begin

      i := CompileConstExpression(i + 2, Value, ExpressionType);
      GetCommonConstType(i, BYTETOK, ExpressionType);

      CheckTok(i + 1, CPARTOK);

      inc(i, 2);

      GenerateProgramEpilog(Value);

     end else
      GenerateProgramEpilog(0);

    Result := i;
    end;


  GETINTVECTOK:
    begin
    CheckTok(i + 1, OPARTOK);

    i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
    GetCommonType(i, INTEGERTOK, ActualParamType);

    CheckTok(i + 1, COMMATOK);

    if not(byte(ConstVal) in [0..1]) then
      Error(i, 'Interrupt Number in [0..1]');

    CheckTok(i + 2, IDENTTOK);
    IdentIndex := GetIdent(Tok[i + 2].Name^);

    if IdentIndex = 0 then
      iError(i + 2, UnknownIdentifier);

    if not (Ident[IdentIndex].DataType in Pointers) then
      iError(i + 2, IncompatibleTypes, 0, Ident[IdentIndex].DataType , POINTERTOK);

    svar := GetLocalName(IdentIndex);

    inc(i, 2);

    case ConstVal of
     ord(iDLI): begin
		 asm65('');
		 asm65(#9'lda VDSLST');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VDSLST+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(iVBL): begin
		 asm65('');
		 asm65(#9'lda VVBLKD');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VVBLKD+1');
		 asm65(#9'sta '+svar+'+1');
		end;
    end;

    CheckTok(i + 1, CPARTOK);

//    GenerateInterrupt(InterruptNumber);
    Result := i + 1;
    end;


  SETINTVECTOK:
    begin
    CheckTok(i + 1, OPARTOK);

    i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
    GetCommonType(i, INTEGERTOK, ActualParamType);

    CheckTok(i + 1, COMMATOK);

    StartOptimization(i + 1);

    if not(byte(ConstVal) in [0..1]) then
      Error(i, 'Interrupt Number in [0..1]');

    i := CompileExpression(i + 2, ActualParamType);
    GetCommonType(i, POINTERTOK, ActualParamType);

    case ConstVal of
     ord(iDLI): begin
		 asm65(#9'mva :STACKORIGIN,x VDSLST');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VDSLST+1');
		 a65(__subBX);
		end;

     ord(iVBL): begin
		 asm65(#9'lda :STACKORIGIN,x');
		 asm65(#9'ldy #5');
		 asm65(#9'sta wsync');
		 asm65(#9'dey');
		 asm65(#9'rne');
		 asm65(#9'sta VVBLKD');
		 asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
		 asm65(#9'sty VVBLKD+1');
		 a65(__subBX);
		end;
    end;

    StopOptimization;

    CheckTok(i + 1, CPARTOK);

//    GenerateInterrupt(InterruptNumber);
    Result := i + 1;
    end;

else
  Result := i - 1;
end;// case

end;// CompileStatement


function DefineFunction(i, ForwardIdentIndex: integer; out isForward, isInt: Boolean; var IsNestedFunction: Boolean; out NestedFunctionResultType: Byte; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: Byte): integer;
var  VarOfSameType: TVariableList;
     NumVarOfSameType, VarOfSameTypeIndex: Integer;
     ListPassMethod, VarType, AllocElementType: Byte;
     NumAllocElements: cardinal;
begin

    if ForwardIdentIndex = 0 then begin

      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, 'Reserved word used as identifier');

      if Tok[i].Kind = PROCEDURETOK then
	begin
	DefineIdent(i + 1, Tok[i + 1].Name^, PROC, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i + 1, Tok[i + 1].Name^, FUNC, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;

      if (Tok[i + 2].Kind = OPARTOK) and (Tok[i + 3].Kind = CPARTOK) then inc(i, 2);

      if Tok[i + 2].Kind = OPARTOK then						// Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := VALPASSING;

	  if Tok[i + 1].Kind = CONSTTOK then
	    begin
	    ListPassMethod := CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = VARTOK then
	    begin
	    ListPassMethod := VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> IDENTTOK then
	      Error(i + 1, 'Formal parameter name expected but ' + GetSpelling(i + 1) + ' found')
	    else
	      begin
	      Inc(NumVarOfSameType);
	      VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name^;
	      end;
	    i := i + 2;
	    until Tok[i].Kind <> COMMATOK;


	  VarType := 0;								// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod = VARPASSING)  and (Tok[i].Kind <> COLONTOK) then begin

	   dec(i);

	  end else begin

	   CheckTok(i, COLONTOK);

	   if Tok[i + 1].Kind = DEREFERENCETOK then				// ^type
	     Error(i + 1, 'Type identifier expected');

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = FILETOK) and (ListPassMethod <> VARPASSING) then
	     Error(i, 'File types must be var parameters');

	  end;


	  for VarOfSameTypeIndex := 1 to NumVarOfSameType do
	    begin

//	    if NumAllocElements > 0 then
//	      Error(i, 'Structured parameters cannot be passed by value');

	    Inc(Ident[NumIdent].NumParams);
	    if Ident[NumIdent].NumParams > MAXPARAMS then
	      iError(i, TooManyParameters, NumIdent)
	    else
	      begin
	      VarOfSameType[VarOfSameTypeIndex].DataType			:= VarType;

	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].DataType		:= VarType;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].Name		:= VarOfSameType[VarOfSameTypeIndex].Name;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].NumAllocElements := NumAllocElements;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].AllocElementType := AllocElementType;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].PassMethod       := ListPassMethod;

	      end;
	    end;

	  i := i + 1;
	until Tok[i].Kind <> SEMICOLONTOK;

	CheckTok(i, CPARTOK);

	i := i + 1;
	end// if Tok[i + 2].Kind = OPARTOR
      else
	i := i + 2;

      NestedFunctionResultType := 0;
      NestedFunctionNumAllocElements := 0;
      NestedFunctionAllocElementType := 0;

      if IsNestedFunction then
	begin

	CheckTok(i, COLONTOK);

	if Tok[i + 1].Kind = ARRAYTOK then
	 Error(i + 1, 'Type identifier expected');

	i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	NestedFunctionResultType := VarType;
	Ident[NumIdent].DataType := NestedFunctionResultType;			// Result

	NestedFunctionNumAllocElements := NumAllocElements;
	Ident[NumIdent].NestedFunctionNumAllocElements := NumAllocElements;

	NestedFunctionAllocElementType := AllocElementType;
	Ident[NumIdent].NestedFunctionAllocElementType := AllocElementType;

	Ident[NumIdent].isNestedFunction := true;

	i := i + 1;
	end;// if IsNestedFunction


    end; //if ForwardIdentIndex = 0


    isForward := false;
    isInt := false;

	while Tok[i + 1].Kind in [OVERLOADTOK, ASSEMBLERTOK, FORWARDTOK, REGISTERTOK, INTERRUPTTOK] do begin

	  case Tok[i + 1].Kind of

	    OVERLOADTOK: begin
			   Ident[NumIdent].isOverload := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   ASSEMBLERTOK: begin
			   Ident[NumIdent].isAsm := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	     FORWARDTOK: begin

			   if INTERFACETOK_USE then
			    if IsNestedFunction then
			     Error(i, 'Function directive ''FORWARD'' not allowed in interface section')
			    else
			     Error(i, 'Procedure directive ''FORWARD'' not allowed in interface section');

			   isForward := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	    REGISTERTOK: begin
			   Ident[NumIdent].isRegister := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   INTERRUPTTOK: begin
			   isInt := true;
			   Ident[NumIdent].isInterrupt := true;
			   Ident[NumIdent].IsNotDead := true;		// zawsze wygeneruj kod dla przerwania
//			   Ident[NumIdent].isAsm := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;
	  end;

	  inc(i);
	end;// while

  if Ident[NumIdent].isInterrupt and (Ident[NumIdent].isAsm = false) then
    Note(i, 'Use assembler block instead pascal');

 Result := i;
end;


function CompileType(i: Integer; out DataType: Byte; out NumAllocElements: cardinal; out AllocElementType: Byte): Integer;
var
  NestedNumAllocElements: cardinal;
  LowerBound, UpperBound, ConstVal, IdentIndex: Int64;
  NumFieldsInList, FieldInListIndex, RecType, k: integer;
  NestedDataType, ExpressionType, NestedAllocElementType: Byte;
  FieldInListName: array [1..MAXFIELDS] of TField;
  ExitLoop: Boolean;

  Name: TString;

  NestedFunctionNumAllocElements: cardinal;
  isForward, isInt, IsNestedFunction: Boolean;
  NestedFunctionResultType, NestedFunctionAllocElementType: Byte;


  function BoundaryType: Byte;
  begin

    if (LowerBound < 0) or (UpperBound < 0) then begin

     if (LowerBound >= Low(shortint)) and (UpperBound <= High(shortint)) then Result := SHORTINTTOK else
      if (LowerBound >= Low(smallint)) and (UpperBound <= High(smallint)) then Result := SMALLINTTOK else
	Result := INTEGERTOK;

    end else begin

     if (LowerBound >= Low(byte)) and (UpperBound <= High(byte)) then Result := BYTETOK else
      if (LowerBound >= Low(word)) and (UpperBound <= High(word)) then Result := WORDTOK else
	Result := CARDINALTOK;

    end;

  end;


  procedure DeclareField(const Name: TName; FieldType: Byte; NumAllocElements: cardinal = 0; AllocElementType: Byte = 0; Data: Int64 = 0);
  var x: Integer;
  begin

   for x := 1 to Types[RecType].NumFields do
     if Types[RecType].Field[x].Name = Name then
       Error(i, 'Duplicate identifier '''+Name+'''');

   // Add new field
   Inc(Types[RecType].NumFields);

   x:=Types[RecType].NumFields;

   if x >= MAXFIELDS then
     Error(i, 'Out of resources, MAXFIELDS');

   // Add new field
   Types[RecType].Field[x].Name := Name;
   Types[RecType].Field[x].DataType := FieldType;
   Types[RecType].Field[x].Value := Data;
   Types[RecType].Field[x].AllocElementType := AllocElementType;
   Types[RecType].Field[x].NumAllocElements := NumAllocElements;

   Types[RecType].Field[x].Kind := 0;

//   writeln(name,',',AllocElementType,',',NumAllocElements,',', Data);

  end;


begin

if Tok[i].Kind = DEREFERENCETOK then begin				// ^type

 DataType := POINTERTOK;

 if Tok[i + 1].Kind = STRINGTOK then begin				// ^string
  NumAllocElements := 0;
  AllocElementType := CHARTOK;
  DataType := STRINGPOINTERTOK;
 end else
 if Tok[i + 1].Kind = IDENTTOK then begin

  IdentIndex := GetIdent(Tok[i + 1].Name^);

// writeln('= ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

  if (IdentIndex > 0) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) then begin
    NumAllocElements := Ident[IdentIndex].NumAllocElements;

    if Ident[IdentIndex].DataType in Pointers then begin
     AllocElementType := Ident[IdentIndex].AllocElementType;
     NumAllocElements := 1;
    end else begin
     AllocElementType := Ident[IdentIndex].DataType;
     NumAllocElements := Ident[IdentIndex].NumAllocElements;
    end;

  end;

 end else begin

  if not (Tok[i + 1].Kind in OrdinalTypes + RealTypes) then
   iError(i + 1, IdentifierExpected);

  NumAllocElements := 0;
  AllocElementType := Tok[i + 1].Kind;

 end;

  Result := i + 1;

end else

if Tok[i].Kind = OPARTOK then begin					// enumerated

    Name := Tok[i-2].Name^;

    inc(NumTypes);
    RecType := NumTypes;

    if NumTypes > MAXTYPES then
     Error(i, 'Out of resources, MAXTYPES');

    inc(i);

    Types[RecType].Field[0].Name := Name;
    Types[RecType].NumFields := 0;

    ConstVal := 0;
    LowerBound := 0;
    UpperBound := 0;
    NumFieldsInList := 0;

    repeat
      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name^;

      inc(i);

      if Tok[i].Kind in [ASSIGNTOK, EQTOK] then begin

	i := CompileConstExpression(i + 1, ConstVal, ExpressionType);
//	GetCommonType(i, ConstValType, SelectorType);

	inc(i);
      end;

      FieldInListName[NumFieldsInList].Value := ConstVal;

      if NumFieldsInList = 1 then begin

       LowerBound := ConstVal;
       UpperBound := ConstVal;

      end else begin

       if ConstVal < LowerBound then LowerBound := ConstVal;
       if ConstVal > UpperBound then UpperBound := ConstVal;

       if FieldInListName[NumFieldsInList].Value < FieldInListName[NumFieldsInList - 1].Value then
	 Note(i, 'Values in enumeration types have to be ascending');

      end;

      inc(ConstVal);

      if Tok[i].Kind = COMMATOK then inc(i);

    until Tok[i].Kind = CPARTOK;

    DataType := BoundaryType;

    for FieldInListIndex := 1 to NumFieldsInList do begin
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, ENUMTYPE, DataType, 0, 0, FieldInListName[FieldInListIndex].Value);
{
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, CONSTANT, POINTERTOK, length(FieldInListName[FieldInListIndex].Name)+1, CHARTOK, NumStaticStrChars + CODEORIGIN + CODEORIGIN_Atari , IDENTTOK);

      StaticStringData[NumStaticStrChars] := length(FieldInListName[FieldInListIndex].Name);

      for k:=1 to length(FieldInListName[FieldInListIndex].Name) do
       StaticStringData[NumStaticStrChars + k] := ord(FieldInListName[FieldInListIndex].Name[k]);

      inc(NumStaticStrChars, length(FieldInListName[FieldInListIndex].Name) + 1);
}
      Ident[NumIdent].NumAllocElements := RecType;
      Ident[NumIdent].Pass := CALLDETERMPASS;

      DeclareField(FieldInListName[FieldInListIndex].Name, DataType, 0, 0, FieldInListName[FieldInListIndex].Value);
    end;

    Types[RecType].Block := BlockStack[BlockStackTop];

    AllocElementType := DataType;

    DataType := ENUMTYPE;
    NumAllocElements := RecType;      // indeks do tablicy Types

    Result := i;

//    writeln('>',lowerbound,',',upperbound);

end else

if Tok[i].Kind = FILETOK then begin					// File

 if Tok[i + 1].Kind = OFTOK then
  i := CompileType(i + 2, DataType, NumAllocElements, AllocElementType)
 else begin
  AllocElementType := 0;//BYTETOK;
  NumAllocElements := 128;
 end;

 DataType := FILETOK;
 Result := i;

end else

if Tok[i].Kind = SETTOK then begin					// Set Of

 CheckTok(i + 1, OFTOK);

 if not (Tok[i + 2].Kind in [CHARTOK, BYTETOK]) then
  Error(i + 2, 'Illegal type declaration of set elements');

 DataType := POINTERTOK;
 NumAllocElements := 32;
 AllocElementType := Tok[i + 2].Kind;

 Result := i + 2;

end else


  if Tok[i].Kind = OBJECTTOK then					// Object
  begin

  Name := Tok[i-2].Name^;

  inc(NumTypes);
  RecType := NumTypes;

  if NumTypes > MAXTYPES then
   Error(i, 'Out of resources, MAXTYPES');

  inc(i);

  Types[RecType].NumFields := 0;
  Types[RecType].Field[0].Name := Name;

    if (Tok[i].Kind in [FUNCTIONTOK, PROCEDURETOK]) then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);

	  k := i;

	  i := DefineFunction(i, 0, isForward, isInt, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	  Inc(NumBlocks);
	  Ident[NumIdent].ProcAsBlock := NumBlocks;
	  Ident[NumIdent].IsUnresolvedForward := TRUE;

	  Ident[NumIdent].ObjectIndex := RecType;
	  Ident[NumIdent].Name := Name + '.' + Tok[k + 1].Name^;

     	  CheckTok(i, SEMICOLONTOK);

     	  inc(i);
    	end;

      if (Tok[i].Kind in [IDENTTOK]) then
	Error(i, 'Fields cannot appear after a method or property definition');

    end else

  repeat
    NumFieldsInList := 0;

    repeat

      if (Tok[i].Kind in [FUNCTIONTOK, PROCEDURETOK]) then
	Error(i, 'Fields cannot appear after a method or property definition');

      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name^;

      inc(i);

      ExitLoop := FALSE;

      if Tok[i].Kind = COMMATOK then
	 inc(i)
      else
	ExitLoop := TRUE;

    until ExitLoop;

    CheckTok(i, COLONTOK);

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);


    for FieldInListIndex := 1 to NumFieldsInList do
     DeclareField(FieldInListName[FieldInListIndex].Name, DataType, NumAllocElements, AllocElementType);

    if DataType in [RECORDTOK, OBJECTTOK] then
      for FieldInListIndex := 1 to NumFieldsInList do
       for k := 1 to Types[NumAllocElements].NumFields do begin
	DeclareField(FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name,
		     Types[NumAllocElements].Field[k].DataType//,
		     //Types[NumAllocElements].Field[k].NumAllocElements,
		     //Types[NumAllocElements].Field[k].AllocElementType
		     );

	Types[RecType].Field[ Types[RecType].NumFields ].Kind := OBJECTVARIABLE;

//	writeln('>> ',FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name,',', Types[NumAllocElements].Field[k].NumAllocElements);
       end;


    ExitLoop := FALSE;
    if Tok[i + 1].Kind <> SEMICOLONTOK then begin
      inc(i);
      ExitLoop := TRUE
    end else
      begin
      inc(i, 2);

      if Tok[i].Kind = ENDTOK then ExitLoop := TRUE else
       if Tok[i].Kind in [FUNCTIONTOK, PROCEDURETOK] then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);

	  k := i;

	  i := DefineFunction(i, 0, isForward, isInt, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	  Inc(NumBlocks);
	  Ident[NumIdent].ProcAsBlock := NumBlocks;
	  Ident[NumIdent].IsUnresolvedForward := TRUE;

	  Ident[NumIdent].ObjectIndex := RecType;
	  Ident[NumIdent].Name := Name + '.' + Tok[k + 1].Name^;

     	  CheckTok(i, SEMICOLONTOK);

     	  inc(i);
    	end;

	ExitLoop := TRUE;
       end;

      end;

  until ExitLoop;

  CheckTok(i, ENDTOK);

  Types[RecType].Block := BlockStack[BlockStackTop];

  DataType := OBJECTTOK;
  NumAllocElements := RecType;      // indeks do tablicy Types
  AllocElementType := 0;

  Result := i;
end else// if OBJECTTOK

  if Tok[i].Kind in [PACKEDTOK, RECORDTOK] then				// Record
  begin

  Name := Tok[i-2].Name^;

  if Tok[i].Kind = PACKEDTOK then begin
   CheckTok(i + 1, RECORDTOK);
   inc(i);
  end;

  inc(NumTypes);
  RecType := NumTypes;

  if NumTypes > MAXTYPES then
   Error(i, 'Out of resources, MAXTYPES');

  inc(i);

  Types[RecType].NumFields := 0;
  Types[RecType].Field[0].Name := Name;

  repeat
    NumFieldsInList := 0;
    repeat
      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name^;

      inc(i);

      ExitLoop := FALSE;

      if Tok[i].Kind = COMMATOK then
	inc(i)
      else
	ExitLoop := TRUE;

    until ExitLoop;

    CheckTok(i, COLONTOK);

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    //NumAllocElements:=0;		// ??? arrays not allowed, only pointers ???

    for FieldInListIndex := 1 to NumFieldsInList do
     DeclareField(FieldInListName[FieldInListIndex].Name, DataType, NumAllocElements, AllocElementType);

    if DataType = RECORDTOK then
      for FieldInListIndex := 1 to NumFieldsInList do
       for k := 1 to Types[NumAllocElements].NumFields do
	DeclareField(FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name, Types[NumAllocElements].Field[k].DataType);


    ExitLoop := FALSE;
    if Tok[i + 1].Kind <> SEMICOLONTOK then begin
      inc(i);
      ExitLoop := TRUE
    end else
      begin
      inc(i, 2);
      if Tok[i].Kind = ENDTOK then ExitLoop := TRUE;
      end

  until ExitLoop;

  CheckTok(i, ENDTOK);

  Types[RecType].Block := BlockStack[BlockStackTop];

  DataType := RECORDTOK;
  NumAllocElements := RecType;		// indeks do tablicy Types
  AllocElementType := 0;

  Result := i;
end else// if RECORDTOK

if Tok[i].Kind in AllTypes then
  begin
  DataType := Tok[i].Kind;
  NumAllocElements := 0;
  AllocElementType := 0;
  Result := i;
  end
else if Tok[i].Kind = STRINGTOK then					// String
  begin
  DataType := STRINGPOINTERTOK;
  AllocElementType := CHARTOK;

  if Tok[i + 1].Kind <> OBRACKETTOK then begin

   UpperBound:=255;			 // default string[255]

   Result:=i;

  end  else begin
 //   Error(i + 1, '[ expected but ' + GetSpelling(i + 1) + ' found');

  i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
  if not(ExpressionType in IntegerTypes) then
    Error(i, 'String length must be integer');

  CheckTok(i + 1, CBRACKETTOK);

  Result := i + 1;
  end;

  NumAllocElements := UpperBound + 1;

  if UpperBound>255 then
   iError(i, SubrangeBounds);

  end // if STRINGTOK
else if Tok[i].Kind = ARRAYTOK then					// Array
  begin
  DataType := POINTERTOK;

  CheckTok(i + 1, OBRACKETTOK);

  i := CompileConstExpression(i + 2, LowerBound, ExpressionType);
  if not(ExpressionType in IntegerTypes) then
    Error(i, 'Array lower bound must be integer');

  if LowerBound <> 0 then
    Error(i, 'Array lower bound is not zero');

  CheckTok(i + 1, RANGETOK);

  i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
  if not(ExpressionType in IntegerTypes) then
    Error(i, 'Array upper bound must be integer');

  if UpperBound < 0 then
    iError(i, UpperBoundOfRange);

  if UpperBound > High(word) then
    iError(i, HighLimit);

  NumAllocElements := UpperBound - LowerBound + 1;

  if Tok[i + 1].Kind = COMMATOK then begin				// [0..x, 0..y]

    i := CompileConstExpression(i + 2, LowerBound, ExpressionType);
    if not(ExpressionType in IntegerTypes) then
      Error(i, 'Array lower bound must be integer');

    if LowerBound <> 0 then
      Error(i, 'Array lower bound is not zero');

    CheckTok(i + 1, RANGETOK);

    i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
    if not(ExpressionType in IntegerTypes) then
      Error(i, 'Array upper bound must be integer');

    if UpperBound < 0 then
      iError(i, UpperBoundOfRange);

    if UpperBound > High(word) then
      iError(i, HighLimit);

    NumAllocElements := NumAllocElements or (UpperBound - LowerBound + 1) shl 16;

  end;

  CheckTok(i + 1, CBRACKETTOK);
  CheckTok(i + 2, OFTOK);

  i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

// sick3

 //writeln(NestedDataType,',',NestedAllocElementType);


  if NestedNumAllocElements > 0 then
//    Error(i, 'Multidimensional arrays are not supported');
   if NestedDataType in [RECORDTOK, OBJECTTOK] then begin			// !!! dla RECORD, OBJECT tablice nie zadzialaja !!!

    if NumAllocElements shr 16 > 0 then
      Error(i, 'Multidimensional arrays are not supported');

    Error(i, 'Only Array [0..'+IntToStr(NumAllocElements-1)+'] of ^RECORD supported');

//    NumAllocElements := NestedNumAllocElements;
//    NestedAllocElementType := NestedDataType;
//    NestedDataType := POINTERTOK;

//    NestedDataType := NestedAllocElementType;
    NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

   end else
   if not (NestedDataType in [STRINGPOINTERTOK, RECORDTOK, OBJECTTOK]) then begin

     if (NestedAllocElementType in [RECORDTOK, OBJECTTOK]) and (NumAllocElements shr 16 > 0) then
       Error(i, 'Multidimensional arrays are not supported');

     NestedDataType := NestedAllocElementType;
     NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);
   end;

  AllocElementType := NestedDataType;

  Result := i;
  end // if ARRAYTOK
else if (Tok[i].Kind = IDENTTOK) and (Ident[GetIdent(Tok[i].Name^)].Kind = USERTYPE) then
  begin
  IdentIndex := GetIdent(Tok[i].Name^);

  if IdentIndex = 0 then
    iError(i, UnknownIdentifier);

  if Ident[IdentIndex].Kind <> USERTYPE then
    Error(i, 'Type expected but ' + Tok[i].Name^ + ' found');

  DataType := Ident[IdentIndex].DataType;
  NumAllocElements := Ident[IdentIndex].NumAllocElements;
  AllocElementType := Ident[IdentIndex].AllocElementType;

// writeln('> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

  Result := i;
  end // if IDENTTOK
else begin

   i := CompileConstExpression(i, ConstVal, ExpressionType);
   LowerBound:=ConstVal;

   CheckTok(i+1, RANGETOK);

   i := CompileConstExpression(i+2, ConstVal, ExpressionType);
   UpperBound:=ConstVal;

   if UpperBound < LowerBound then
     iError(i, UpperBoundOfRange);

 // Error(i, 'Error in type definition');

  DataType := BoundaryType;
  NumAllocElements := 0;
  AllocElementType := 0;
  Result := i;

end;

end;// CompileType


procedure GenerateProcFuncAsmLabels(BlockIdentIndex: integer; VarSize: Boolean = false);
var IdentIndex, size: integer;
    emptyLine: Boolean;
    varbegin: TString;


   function Value(dorig: Boolean = false): string;
   const reg: array [1..3] of string = ('edx', 'ecx', 'eax');
   var ftmp: TFloat;
       v: integer;
   begin

    move(Ident[IdentIndex].Value, ftmp, sizeof(ftmp));

    case Ident[IdentIndex].DataType of
     SHORTREALTOK, REALTOK: v := ftmp[0];
		 SINGLETOK: v := ftmp[1];
    else
      v := Ident[IdentIndex].Value;
    end;

    if dorig then
     Result := #9'= DATAORIGIN+$'+IntToHex(Ident[IdentIndex].Value - DATAORIGIN, 4)
    else
     if Ident[IdentIndex].isAbsolute and (Ident[IdentIndex].Kind = VARIABLE) and (byte((Ident[IdentIndex].Value shr 24) and $7f) in [1..3]) then begin
      Result := #9'= '+reg[(Ident[IdentIndex].Value shr 24) and $7f];
      size := 0;
     end else
     if Ident[IdentIndex].isAbsolute then begin

      if Ident[IdentIndex].Value < 0 then
       Result := #9'= DATAORIGIN+$'+IntToHex(abs(Ident[IdentIndex].Value), 4)
      else
       Result := #9'= $'+IntToHex(Ident[IdentIndex].Value, 4)

     end else
      if Ident[IdentIndex].NumAllocElements > 0 then
	Result := #9'= CODEORIGIN+$'+IntToHex(Ident[IdentIndex].Value - CODEORIGIN_Atari - CODEORIGIN, 4)
      else
	Result := #9'= $'+IntToHex(v, 4);

   end;


begin

 if Pass = CODEGENERATIONPASS then begin

  StopOptimization;

  emptyLine:=true;
  size:=0;
  varbegin := '';

  for IdentIndex := 1 to NumIdent do
   if (Ident[IdentIndex].Block = Ident[BlockIdentIndex].ProcAsBlock) and (Ident[IdentIndex].UnitIndex = UnitNameIndex) then begin

    if emptyLine then begin
     asm65separator;
     asm65('');

     emptyLine:=false;
    end;


    case Ident[IdentIndex].Kind of

      VARIABLE: if Ident[IdentIndex].isAbsolute then begin		// ABSOLUTE = TRUE

		 if (Ident[IdentIndex].PassMethod <> VARPASSING) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		  asm65('adr.'+Ident[IdentIndex].Name + Value);
		  asm65('.var '+Ident[IdentIndex].Name+#9'= adr.' + Ident[IdentIndex].Name + ' .word');

		  if size = 0 then varbegin := Ident[IdentIndex].Name;
		  inc(size, Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] );

		 end else
		  if Ident[IdentIndex].DataType = FILETOK then
		   asm65('.var '+Ident[IdentIndex].Name + Value + ' .word')
		  else
		   asm65(Ident[IdentIndex].Name + Value);

		end else						// ABSOLUTE = FALSE

		 if (Ident[IdentIndex].PassMethod <> VARPASSING) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin


//		writeln(Ident[IdentIndex].Name,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].IdType);

		  if (Ident[IdentIndex].IdType <> ARRAYTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then

		    asm65(Ident[IdentIndex].Name + Value(true))

		  else begin

		   asm65('adr.'+Ident[IdentIndex].Name + Value(true));
		   asm65('.var '+Ident[IdentIndex].Name+#9'= adr.' + Ident[IdentIndex].Name + ' .word');

		  end;

		  if size = 0 then varbegin := Ident[IdentIndex].Name;
		  inc(size, Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] );

		 end else
		  if (Ident[IdentIndex].DataType = FILETOK) {and (Ident[IdentIndex].Block = 1)} then
		   asm65('.var '+Ident[IdentIndex].Name + Value(true) + ' .word')	// tylko wskaznik
		  else begin
		   asm65(Ident[IdentIndex].Name + Value(true));

		   if size = 0 then varbegin := Ident[IdentIndex].Name;

		   if Ident[IdentIndex].idType <> DATAORIGINOFFSET then			// indeksy do RECORD nie zliczaj
		     inc(size, DataSize[Ident[IdentIndex].DataType]);
		  end;

      CONSTANT: if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		 asm65('adr.'+Ident[IdentIndex].Name + Value);
		 asm65('.var '+Ident[IdentIndex].Name+#9'= adr.' + Ident[IdentIndex].Name + ' .word');

		end else
		 asm65(Ident[IdentIndex].Name + Value);
    end;

   end;

  if (BlockStack[BlockStackTop] <> 1) and VarSize and (size > 0) then begin
   asm65(#13#10'@VarData'#9'= '+varbegin);
   asm65('@VarDataSize'#9'= '+IntToStr(size)+#13#10);
  end;

 end;

end;


procedure SaveToStaticDataSegment(ConstDataSize: integer; ConstVal: Int64; ConstValType: Byte);
var ftmp: TFloat;
begin

ftmp[0]:=0;
ftmp[1]:=0;

	 case ConstValType of

	  SHORTINTTOK, BYTETOK, CHARTOK, BOOLEANTOK:
		       StaticStringData[ConstDataSize] := byte(ConstVal);

	  SMALLINTTOK, WORDTOK, SHORTREALTOK, POINTERTOK, STRINGPOINTERTOK:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	   DATAORIGINOFFSET:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal) or $8000;
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8) or $4000;
		       end;

	   CODEORIGINOFFSET:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal) or $2000;
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8) or $1000;
		       end;

	   INTEGERTOK, CARDINALTOK, REALTOK:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
			StaticStringData[ConstDataSize+2] := byte(ConstVal shr 16);
			StaticStringData[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	    SINGLETOK: begin
			move(ConstVal, ftmp, sizeof(ftmp));

			ConstVal := ftmp[1];

			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
			StaticStringData[ConstDataSize+2] := byte(ConstVal shr 16);
			StaticStringData[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	 end;
end;


function ReadDataArray(i: integer; ConstDataSize: integer; const ConstValType: Byte; NumAllocElements: cardinal; StaticData: Boolean = false): integer;
var ActualParamType: byte;
    NumActualParams, NumActualParams_, NumAllocElements_: cardinal;
    ConstVal: Int64;


procedure SaveDataSegment(DataType: Byte);
begin

   if StaticData then
    SaveToStaticDataSegment(ConstDataSize, ConstVal, DataType)
   else
    SaveToDataSegment(ConstDataSize, ConstVal, DataType);

   if DataType = DATAORIGINOFFSET then
    inc(ConstDataSize, DataSize[POINTERTOK] )
   else
    inc(ConstDataSize, DataSize[DataType] );

end;


procedure SaveData;
begin

  if (ConstValType in StringTypes + [CHARTOK, STRINGPOINTERTOK]) and (ActualParamType in IntegerTypes + RealTypes) then
    iError(i, IllegalExpression);


  if (ConstValType in StringTypes + [STRINGPOINTERTOK]) and (ActualParamType = CHARTOK) then
   iError(i, IncompatibleTypes, 0, ActualParamType, ConstValType);


  if (ConstValType = SINGLETOK) and (ActualParamType = REALTOK) then
   ActualParamType := SINGLETOK;

  if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then begin
   Int2Float(ConstVal);
   ActualParamType := ConstValType;
  end;

  if (ConstValType = SHORTREALTOK) and (ActualParamType = REALTOK) then
   ActualParamType := SHORTREALTOK;


  if ActualParamType = DATAORIGINOFFSET then

   SaveDataSegment(DATAORIGINOFFSET)

  else begin

   if ConstValType in IntegerTypes then begin

    if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes)) then
     warning(i, RangeCheckError, 0, ConstVal, ConstValType);

   end else
    GetCommonConstType(i, ConstValType, ActualParamType);

   SaveDataSegment(ConstValType);

  end;

end;


begin

 CheckTok(i, OPARTOK);

 NumActualParams := 0;
 NumActualParams_:= 0;

 NumAllocElements_ := NumAllocElements shr 16;
 NumAllocElements  := NumAllocElements and $ffff;

  repeat

  inc(NumActualParams);
  if NumActualParams > NumAllocElements then Break;

  if NumAllocElements_ > 0 then begin

   NumActualParams_ := 0;

   CheckTok(i + 1, OPARTOK);
   inc(i);

   repeat
    inc(NumActualParams_);
    if NumActualParams_ > NumAllocElements_ then Break;

    i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

    SaveData;

    inc(i);
   until Tok[i].Kind <> COMMATOK;

   CheckTok(i, CPARTOK);

   //inc(i);
  end else begin
   i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

//   writeln(ConstVal, ',',ActualParamType,' / ',ConstValType,' | ', StaticData);

   SaveData;
  end;

  inc(i);

 until Tok[i].Kind <> COMMATOK;

 CheckTok(i, CPARTOK);

 if NumActualParams < NumAllocElements then
  Error(i, 'Expected another '+IntToStr(NumAllocElements - NumActualParams)+' array elements');

 if NumActualParams_ < NumAllocElements_ then
  Error(i, 'Expected another '+IntToStr(NumAllocElements_ - NumActualParams_)+' array elements');

 Result := i;

end;


procedure GenerateLocal(BlockIdentIndex: integer; IsFunction: Boolean);
var info: string;
begin

 if IsFunction then
  info := '; FUNCTION'
 else
  info := '; PROCEDURE';

 if Ident[BlockIdentIndex].isAsm then info := info + ' | ASSEMBLER';
 if Ident[BlockIdentIndex].isOverload then info := info + ' | OVERLOAD';
 if Ident[BlockIdentIndex].isRegister then info := info + ' | REGISTER';
 if Ident[BlockIdentIndex].isInterrupt then info := info + ' | INTERRUPT';

 if Ident[BlockIdentIndex].isOverload then
   asm65(#13#10'.local'#9+Ident[BlockIdentIndex].Name+'_'+IntToHex(Ident[BlockIdentIndex].Value, 4), info)
 else
   asm65(#13#10'.local'#9+Ident[BlockIdentIndex].Name, info);

end;


procedure FormalParameterList(var i: integer; var NumParams: integer; var Param: TParamList; out Status: byte; IsNestedFunction: Boolean; out NestedFunctionResultType: Byte; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: Byte);
var ListPassMethod, NumVarOfSameType, VarTYpe, AllocElementType: byte;
    NumAllocElements: cardinal;
    VarOfSameTypeIndex: integer;
    VarOfSameType: TVariableList;
begin

{$PUSH}
{$HINTS OFF}
  FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
{$POP}

      NumParams := 0;

      if Tok[i + 2].Kind = OPARTOK then			   // Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := VALPASSING;

	  if Tok[i + 1].Kind = CONSTTOK then
	    begin
	    ListPassMethod := CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = VARTOK then
	    begin
	    ListPassMethod := VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> IDENTTOK then
	      Error(i + 1, 'Formal parameter name expected but ' + GetSpelling(i + 1) + ' found')
	    else
	      begin
	      Inc(NumVarOfSameType);
	      VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name^;
	      end;
	    i := i + 2;
	    until Tok[i].Kind <> COMMATOK;


	  VarType := 0;							  // UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod = VARPASSING)  and (Tok[i].Kind <> COLONTOK) then begin

	   dec(i);

	  end else begin

	   CheckTok(i, COLONTOK);

	   if Tok[i + 1].Kind = DEREFERENCETOK then			      // ^type
	     Error(i + 1, 'Type identifier expected');

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = FILETOK) and (ListPassMethod <> VARPASSING) then
	     Error(i, 'File types must be var parameters');

	  end;


	  for VarOfSameTypeIndex := 1 to NumVarOfSameType do
	    begin

//	    if NumAllocElements > 0 then
//	      Error(i, 'Structured parameters cannot be passed by value');

	    Inc(NumParams);
	    if NumParams > MAXPARAMS then
	      iError(i, TooManyParameters, NumIdent)
	    else
	      begin
//	      VarOfSameType[VarOfSameTypeIndex].DataType			:= VarType;

	      Param[NumParams].DataType	 := VarType;
	      Param[NumParams].Name	     := VarOfSameType[VarOfSameTypeIndex].Name;
	      Param[NumParams].NumAllocElements := NumAllocElements;
	      Param[NumParams].AllocElementType := AllocElementType;
	      Param[NumParams].PassMethod       := ListPassMethod;

	      end;
	    end;

	  i := i + 1;
	until Tok[i].Kind <> SEMICOLONTOK;

	CheckTok(i, CPARTOK);

	i := i + 1;
	end// if Tok[i + 2].Kind = OPARTOR
      else
	i := i + 2;

//      NestedFunctionResultType := 0;
//      NestedFunctionNumAllocElements := 0;
//      NestedFunctionAllocElementType := 0;

      Status := 0;

      if IsNestedFunction then
	begin

	CheckTok(i, COLONTOK);

	if Tok[i + 1].Kind = ARRAYTOK then
	  Error(i + 1, 'Type identifier expected');

	i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	NestedFunctionResultType := VarType;			   // Result
	NestedFunctionNumAllocElements := NumAllocElements;
	NestedFunctionAllocElementType := AllocElementType;

	i := i + 1;
	end;// if IsNestedFunction


	while Tok[i + 1].Kind in [OVERLOADTOK, ASSEMBLERTOK, FORWARDTOK, REGISTERTOK, INTERRUPTTOK] do begin

	  case Tok[i + 1].Kind of

	    OVERLOADTOK: begin
			   Status := Status or ord(mOverload);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   ASSEMBLERTOK: begin
			   Status := Status or ord(mAssembler);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

{	     FORWARDTOK: begin
			   Status := Status or ord(mForward);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;
 }
	    REGISTERTOK: begin
			   Status := Status or ord(mRegister);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   INTERRUPTTOK: begin
			   Status := Status or ord(mInterrupt);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;
	  end;

	  inc(i);
	end;// while

end;


function CompileBlock(i: Integer; BlockIdentIndex: Integer; NumParams: Integer; IsFunction: Boolean; FunctionResultType: Byte; FunctionNumAllocElements: cardinal = 0; FunctionAllocElementType: byte = 0): Integer;
var
  VarOfSameType: TVariableList;
  Param: TParamList;
  j, ParamIndex, NumVarOfSameType, VarOfSameTypeIndex, idx, tmpVarDataSize,  tmpVarDataSize_: Integer;
  ForwardIdentIndex, IdentIndex: integer;
  NumAllocElements, NestedFunctionNumAllocElements: cardinal;
  NumAllocTypes: word;
  ConstVal: Int64;
  IsNestedFunction, isAsm, isReg, isInt, isAbsolute, isForward, ImplementationUse: Boolean;
  iocheck_old, yes: Boolean;
  VarType, NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType: Byte;
  NestedFunctionAllocElementType, IdType, Tmp: Byte;
  TmpResult: byte;

  UnitList: array of TString;

begin

ResetOpty;

FillChar(VarOfSameType, sizeof(VarOfSameType), 0);

j:=0;
ConstVal:=0;

ImplementationUse:=false;

Param := Ident[BlockIdentIndex].Param;
isAsm := Ident[BlockIdentIndex].isAsm;
isReg := Ident[BlockIdentIndex].isRegister;
isInt := Ident[BlockIdentIndex].isInterrupt;

Inc(NumBlocks);
Inc(BlockStackTop);
BlockStack[BlockStackTop] := NumBlocks;
Ident[BlockIdentIndex].ProcAsBlock := NumBlocks;

GenerateLocal(BlockIdentIndex, IsFunction);

if (BlockStack[BlockStackTop] <> 1) and (NumParams > 0) and Ident[BlockIdentIndex].isRecursion then asm65('@new'#9'@AllocMem #@VarData #@VarDataSize');


if Ident[BlockIdentIndex].ObjectIndex > 0 then begin

//  if ParamIndex = 1 then begin
   asm65(#9'sta ' + Types[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name);
   asm65(#9'sty ' + Types[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name+'+1');

   DefineIdent(i, Types[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name, VARIABLE,  WORDTOK, 0 , 0, 0);
   Ident[NumIdent].PassMethod := VARPASSING;
   Ident[NumIdent].AllocElementType := WORDTOK;
//  end;

 NumAllocElements := 0;

 for ParamIndex := 1 to Types[Ident[BlockIdentIndex].ObjectIndex].NumFields do
  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Kind = 0 then begin

    if NumAllocElements > 0 then
     if NumAllocElements > 255 then begin
       asm65(#9'add <'+IntToStr(NumAllocElements));
       asm65(#9'pha');
       asm65(#9'tya');
       asm65(#9'adc >'+IntToStr(NumAllocElements));
       asm65(#9'tay');
       asm65(#9'pla');
      end else begin
       asm65(#9'add #'+IntToStr(NumAllocElements));
       asm65(#9'scc');
       asm65(#9'iny');
      end;

  asm65(#9'sta ' + Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name);
  asm65(#9'sty ' + Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name+'+1');

  if ParamIndex <> Types[Ident[BlockIdentIndex].ObjectIndex].NumFields then begin

   if (Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType = POINTERTOK) and
      (Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements > 0) then begin

      NumAllocElements := Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements and $ffff;

      if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements shr 16 > 0 then
       NumAllocElements:=(NumAllocElements * (Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements shr 16));

      NumAllocElements := NumAllocElements * DataSize[ Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType ];

   end else
    case Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType of
	      FILETOK: NumAllocElements := 12;
     STRINGPOINTERTOK: NumAllocElements := Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements;
	    RECORDTOK: NumAllocElements := ObjectRecordSize(Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements);
    else
      NumAllocElements := DataSize[ Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType];
    end;

  end;

 end;

 end;   // Ident[BlockIdentIndex].ObjectIndex

//writeln;
// Allocate parameters as local variables of the current block if necessary
for ParamIndex := 1 to NumParams do
  begin

//  write(Param[ParamIndex].Name,':',Param[ParamIndex].DataType,'/',Param[ParamIndex].NumAllocElements);

    if Param[ParamIndex].PassMethod = VARPASSING then begin

     if isReg and (ParamIndex in [1..3]) then begin
      tmpVarDataSize := VarDataSize;

      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      Ident[GetIdent(Param[ParamIndex].Name)].isAbsolute := true;
      Ident[GetIdent(Param[ParamIndex].Name)].Value := (byte(ParamIndex) shl 24) or $80000000;

      VarDataSize := tmpVarDataSize;

     end else
      if Param[ParamIndex].DataType in Pointers then
       DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, 0, Param[ParamIndex].DataType, 0)
      else
       DefineIdent(i, Param[ParamIndex].Name, VARIABLE, POINTERTOK, 0, Param[ParamIndex].DataType, 0);


     if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then begin

      tmpVarDataSize := VarDataSize;

      for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do begin

       DefineIdent(i, Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,
		   VARIABLE,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, DATAORIGINOFFSET);

       Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize;
       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;
       Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;	// Types[Param[ParamIndex].NumAllocElements].Field[j].DataType;

      end;

      VarDataSize := tmpVarDataSize;

     end else

      if Param[ParamIndex].DataType in Pointers then
	Ident[GetIdent(Param[ParamIndex].Name)].AllocElementType := Param[ParamIndex].AllocElementType
      else
	Ident[GetIdent(Param[ParamIndex].Name)].AllocElementType := Param[ParamIndex].DataType;

      Ident[GetIdent(Param[ParamIndex].Name)].NumAllocElements := Param[ParamIndex].NumAllocElements;

    end else begin
     if isReg and (ParamIndex in [1..3]) then begin
      tmpVarDataSize := VarDataSize;

      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      Ident[GetIdent(Param[ParamIndex].Name)].isAbsolute := true;
      Ident[GetIdent(Param[ParamIndex].Name)].Value := (byte(ParamIndex) shl 24) or $80000000;

      VarDataSize := tmpVarDataSize;

     end else
      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

     if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then
      for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do begin

	 DefineIdent(i, Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,
		   VARIABLE,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0);

       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;
      end;

    end;

    Ident[GetIdent(Param[ParamIndex].Name)].PassMethod := Param[ParamIndex].PassMethod;
  end;


// Allocate Result variable if the current block is a function
if IsFunction then   begin //DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, 0, 0, 0);
    DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, FunctionNumAllocElements, FunctionAllocElementType, 0);

    if FunctionResultType in [RECORDTOK, OBJECTTOK] then
     for j := 1 to Types[FunctionNumAllocElements].NumFields do begin

       DefineIdent(i, 'RESULT.'+Types[FunctionNumAllocElements].Field[j].Name,
		   VARIABLE,
		   Types[FunctionNumAllocElements].Field[j].DataType,
		   Types[FunctionNumAllocElements].Field[j].NumAllocElements,
		   Types[FunctionNumAllocElements].Field[j].AllocElementType, 0);

//       Ident[GetIdent(iname)].PassMethod := VALPASSING;
     end;

end;



// Load parameters from the stack
 for ParamIndex := NumParams downto 1 do begin

  if Param[ParamIndex].PassMethod = VARPASSING then
     GenerateAssignment(ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
  else
     GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);

  if (Param[ParamIndex].PassMethod <> VARPASSING) and (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Param[ParamIndex].NumAllocElements > 0) then // copy arrays
   if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then begin

    idx := RecordSize(GetIdent(Param[ParamIndex].Name));

    asm65(#9'@move '+Param[ParamIndex].Name+' #adr.'+Param[ParamIndex].Name+' #'+IntToStr(idx));
    asm65(#9'mwa #adr.'+Param[ParamIndex].Name+' '+Param[ParamIndex].Name);
   end else begin

    asm65(#9'@move '+Param[ParamIndex].Name+' #adr.'+Param[ParamIndex].Name+' #'+IntToStr(integer(Param[ParamIndex].NumAllocElements * DataSize[Param[ParamIndex].AllocElementType])));
    asm65(#9'mwa #adr.'+Param[ParamIndex].Name+' '+Param[ParamIndex].Name);
   end;

 end;


// Object variable definitions
if Ident[BlockIdentIndex].ObjectIndex > 0 then
 for ParamIndex := 1 to Types[Ident[BlockIdentIndex].ObjectIndex].NumFields do begin

  tmpVarDataSize := VarDataSize;

//  writeln(Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,',',Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType, ' / ' );

  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType = OBJECTTOK then Error(i, '-- under construction --');

  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType = RECORDTOK then ConstVal:=0;

  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType in [POINTERTOK, STRINGPOINTERTOK] then

  DefineIdent(i, Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,
	      VARIABLE, Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType,
	      Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,
	      Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType, 0)
  else

  DefineIdent(i, Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,
  	      VARIABLE, POINTERTOK,
	      Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,
	      Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType, 0);

  Ident[NumIdent].PassMethod := VARPASSING;

  VarDataSize := tmpVarDataSize + DataSize[POINTERTOK];

  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Kind = OBJECTVARIABLE then begin
   Ident[NumIdent].Value := ConstVal + DATAORIGIN;

   if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType <> UNTYPETOK then
    Ident[NumIdent].DataType := Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType;

   inc(ConstVal, DataSize[Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType]);

   VarDataSize := tmpVarDataSize;
  end;

 end;


asm65('');

if not isAsm then				// skaczemy do poczatku bloku procedury, wazne dla zagniezdzonych procedur / funkcji
  GenerateDeclarationProlog;


while Tok[i].Kind in
 [CONSTTOK, TYPETOK, VARTOK, LABELTOK, PROCEDURETOK, FUNCTIONTOK, PROGRAMTOK, USESTOK,
  UNITBEGINTOK, UNITENDTOK, IMPLEMENTATIONTOK, INITIALIZATIONTOK, IOCHECKON, IOCHECKOFF,
  INFOTOK, WARNINGTOK, ERRORTOK] do
  begin

  if Tok[i].Kind = INFOTOK then begin

      if Pass = CODEGENERATIONPASS then writeln('User defined: ' + msgUser[Tok[i].Value]);

      inc(i, 2);
  end;


  if Tok[i].Kind = WARNINGTOK then begin

      Warning(i, UserDefined);

      inc(i, 2);
  end;


  if Tok[i].Kind = ERRORTOK then begin

      if Pass = CODEGENERATIONPASS then iError(i, UserDefined);

      inc(i, 2);
  end;


  if Tok[i].Kind = IOCHECKON then begin
      IOCheck := true;

      inc(i, 2);
  end;


  if Tok[i].Kind = IOCHECKOFF then begin
      IOCheck := false;

      inc(i, 2);
  end;


  if Tok[i].Kind = UNITBEGINTOK then begin
   asm65separator;

   DefineIdent(i, UnitName[Tok[i].UnitIndex].Name, UNITTYPE, 0, 0, 0, 0);

   asm65(#13#10'.local'#9 + UnitName[Tok[i].UnitIndex].Name, '; UNIT');

   UnitNameIndex := Tok[i].UnitIndex;

   CheckTok(i + 1, UNITTOK);
   CheckTok(i + 2, IDENTTOK);

   if Tok[i + 2].Name^ <> UnitName[Tok[i].UnitIndex].Name then
    Error(i + 2, 'Illegal unit name: ' + Tok[i + 2].Name^);

   CheckTok(i + 3, SEMICOLONTOK);

   CheckTok(i + 4, INTERFACETOK);

   INTERFACETOK_USE := true;

   PublicSection := true;
   ImplementationUse := false;

   inc(i, 5);
  end;


  if Tok[i].Kind = UNITENDTOK then begin

   if not ImplementationUse then
    CheckTok(i, IMPLEMENTATIONTOK);

   GenerateProcFuncAsmLabels(BlockIdentIndex);

   asm65(#13#10'.endl', '; UNIT ' + UnitName[Tok[i].UnitIndex].Name);

   j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = UnitNameIndex) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROC, FUNC] then
       if Ident[j].IsUnresolvedForward then
	 Error(i, 'Unresolved forward declaration of ' + Ident[j].Name);

     Dec(j);
     end;

   UnitNameIndex := 1;

   PublicSection := true;
   ImplementationUse := false;

   inc(i);
  end;


  if Tok[i].Kind = IMPLEMENTATIONTOK then begin

   INTERFACETOK_USE := false;

   PublicSection := false;
   ImplementationUse := true;

   inc(i);
  end;


  if Tok[i].Kind = INITIALIZATIONTOK then begin

   if not ImplementationUse then
    CheckTok(i, IMPLEMENTATIONTOK);

   asm65separator;
   asm65separator(false);

   asm65('@UnitInit');

   j := CompileStatement(i + 1);
   while Tok[j + 1].Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

   asm65('');
   asm65(#9'rts');

   i := j + 1;
  end;


  if Tok[i].Kind = PROGRAMTOK then begin       // na samym poczatku listingu

   if PROGRAMTOK_USE then CheckTok(i, BEGINTOK);

   CheckTok(i + 1, IDENTTOK);

   PROGRAM_NAME := Tok[i + 1].Name^;

   inc(i);

   if Tok[i+1].Kind = OPARTOK then begin

    inc(i);

    repeat
     inc(i);
     CheckTok(i, IDENTTOK);

     if Tok[i+1].Kind = COMMATOK then inc(i);

    until Tok[i+1].Kind <> IDENTTOK;

    CheckTok(i+1, CPARTOK);

    inc(i);
   end;

   CheckTok(i + 1, SEMICOLONTOK);

   inc(i, 2);

   PROGRAMTOK_USE := true;
  end;


  if Tok[i].Kind = USESTOK then begin	  // co najwyzej po PROGRAM

  if PROGRAMTOK_USE then begin

   j:=i-1;

   while Tok[j].Kind in [SEMICOLONTOK, CPARTOK, OPARTOK, IDENTTOK, COMMATOK] do dec(j);

   if Tok[j].Kind <> PROGRAMTOK then
    CheckTok(i, BEGINTOK);

  end;

  if INTERFACETOK_USE then
   if Tok[i - 1].Kind <> INTERFACETOK then
    CheckTok(i, IMPLEMENTATIONTOK);

  if ImplementationUse then
   if Tok[i - 1].Kind <> IMPLEMENTATIONTOK then
    CheckTok(i, BEGINTOK);

  inc(i);

  idx:=i;

  SetLength(UnitList, 1);		// wstepny odczyt USES, sprawdzamy czy nie powtarzaja sie wpisy

  repeat

   CheckTok(i , IDENTTOK);

   for j:=0 to High(UnitList)-1 do
    if UnitList[j] = Tok[i].Name^ then
     Error(i, 'Duplicate identifier '''+Tok[i].Name^+'''');

   j:=High(UnitList);
   UnitList[j] := Tok[i].Name^;
   SetLength(UnitList, j+2);

   inc(i);

   if Tok[i].Kind = COMMATOK then inc(i);

  until Tok[i].Kind <> IDENTTOK;


  i:=idx;

  SetLength(UnitList, 0);		//  wlasciwy odczyt USES

  repeat

   CheckTok(i , IDENTTOK);

{   for j := 1 to UnitName[UnitNameIndex].Units do
    if (UnitName[UnitNameIndex].Allow[j] = Tok[i].Name^) or (Tok[i].Name^='SYSTEM') then
     Error(i, 'Duplicate-- identifier '''+Tok[i].Name^+'''');
}

   yes:=true;
   for j := 1 to UnitName[UnitNameIndex].Units do
    if (UnitName[UnitNameIndex].Allow[j] = Tok[i].Name^) or (Tok[i].Name^='SYSTEM') then
      yes:=false;

   if yes then begin

    inc(UnitName[UnitNameIndex].Units);

    if UnitName[UnitNameIndex].Units > MAXALLOWEDUNITS then
      Error(i, 'Out of resources, MAXALLOWEDUNITS');

    UnitName[UnitNameIndex].Allow[UnitName[UnitNameIndex].Units] := Tok[i].Name^;

   end;

   inc(i);

   if Tok[i].Kind = COMMATOK then inc(i);

  until Tok[i].Kind <> IDENTTOK;

  inc(i);

  end;


  if Tok[i].Kind = LABELTOK then begin

   inc(i);

   repeat

    CheckTok(i , IDENTTOK);

    DefineIdent(i, Tok[i].Name^, LABELTYPE, 0, 0, 0, 0);

    inc(i);

    if Tok[i].Kind = COMMATOK then inc(i);

   until Tok[i].Kind <> IDENTTOK;

   i := i + 1;
  end;// if LABELTOK


  if Tok[i].Kind = CONSTTOK then
    begin
    repeat

      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, 'Constant name expected but ' + GetSpelling(i + 1) + ' found')
      else
	if Tok[i + 2].Kind = EQTOK then begin

	  j := CompileConstExpression(i + 3, ConstVal, ConstValType);

	  if Tok[j].Kind in StringTypes then
	   DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, ConstValType, Tok[j].StrLength, CHARTOK, ConstVal + CODEORIGIN { - CODEORIGIN_Atari}, Tok[j].Kind)
	  else
   	   if (ConstValType in Pointers) then
	     iError(j, IllegalExpression)
	   else
	     DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, ConstValType, 0, 0, ConstVal, Tok[j].Kind);

	  i := j;
	end else
	if Tok[i + 2].Kind = COLONTOK then begin

	  j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

	  if (VarType in Pointers) and (NumAllocElements = 0) then
	   iError(j, IllegalExpression);

	  CheckTok(j + 1, EQTOK);


	  if NumAllocElements > 0 then begin
	   DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, POINTERTOK, NumAllocElements, AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_Atari, IDENTTOK);

	   j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true);

	   if NumAllocElements shr 16 > 0 then
	     inc(NumStaticStrChars, ((NumAllocElements and $ffff) * (NumAllocElements shr 16)) * DataSize[AllocElementType])
	   else
	     inc(NumStaticStrChars, NumAllocElements * DataSize[AllocElementType]);

	  end else begin
	   j := CompileConstExpression(j + 2, ConstVal, ConstValType, VarType, false);


	   if (VarType = SINGLETOK) and (ConstValType in [SHORTREALTOK, REALTOK]) then ConstValType := SINGLETOK;


	   if (VarType in RealTypes) and (ConstValType in IntegerTypes) then begin
	     Int2Float(ConstVal);
	     ConstValType := VarType;
	   end;

	   GetCommonType(i + 1, VarType, ConstValType);


	   DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, VarType, 0, 0, ConstVal, Tok[j].Kind);
	  end;

	  i := j;
	end else
	 CheckTok(i + 2, EQTOK);

      CheckTok(i + 1, SEMICOLONTOK);

      inc(i);
    until Tok[i + 1].Kind <> IDENTTOK;

    inc(i);
    end;// if CONSTTOK



  if Tok[i].Kind = TYPETOK then
    begin
    repeat
      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, 'Type name expected but ' + GetSpelling(i + 1) + ' found')
      else
	  begin

	  CheckTok(i + 2, EQTOK);

	  j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);
	  DefineIdent(i + 1, Tok[i + 1].Name^, USERTYPE, VarType, NumAllocElements, AllocElementType, 0, Tok[i + 3].Kind);
	  Ident[NumIdent].Pass := CALLDETERMPASS;

	  end;

      CheckTok(j + 1, SEMICOLONTOK);

      i := j + 1;
    until Tok[i + 1].Kind <> IDENTTOK;

    i := i + 1;
    end;// if TYPETOK


  if Tok[i].Kind = VARTOK then
    begin
    repeat
      NumVarOfSameType := 0;
      repeat
	if Tok[i + 1].Kind <> IDENTTOK then
	  Error(i + 1, 'Variable name expected but ' + GetSpelling(i + 1) + ' found')
	else
	  begin
	  Inc(NumVarOfSameType);

	  if NumVarOfSameType > High(VarOfSameType) then
	    Error(i, 'Too many formal parameters');

	  VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name^;
	  end;
	i := i + 2;
      until Tok[i].Kind <> COMMATOK;

      CheckTok(i, COLONTOK);

      IdType := Tok[i + 1].Kind;

      i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);


      isAbsolute := false;


      if Tok[i + 1].Kind = ABSOLUTETOK then begin

	isAbsolute := true;

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'ABSOLUTE can only be associated to one variable');


	if (VarType in [RECORDTOK, OBJECTTOK] + Pointers) and (NumAllocElements <= 0) then	 // brak mozliwosci identyfikacji dla takiego przypadku
	 Error(i + 1, 'not possible in this case');

	inc(i);

	if (Tok[i+1].Kind = IDENTTOK) and (Ident[GetIdent(Tok[i+1].Name^)].Kind = VARTOK) then begin
	 ConstVal := Ident[GetIdent(Tok[i+1].Name^)].Value - DATAORIGIN;

 	 if (ConstVal < 0) or (ConstVal > $FFFFFF) then
	  Error(i, 'Range check error while evaluating constants ('+IntToStr(ConstVal)+' must be between 0 and '+IntToStr($FFFFFF)+')');

	 ConstVal := -ConstVal;

	 inc(i);
	end else begin
	 i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

	 if VarType in Pointers then
	  GetCommonConstType(i, WORDTOK, ActualParamType)
	 else
	  GetCommonConstType(i, CARDINALTOK, ActualParamType);

	 if (ConstVal < 0) or (ConstVal > $FFFFFF) then
	  Error(i, 'Range check error while evaluating constants ('+IntToStr(ConstVal)+' must be between 0 and '+IntToStr($FFFFFF)+')');
	end;

	inc(ConstVal);   // wyjatkowo, aby mozna bylo ustawic adres $0000, DefineIdent zmniejszy wartosc -1

      end;


      tmpVarDataSize := VarDataSize;		// dla ABSOLUTE, RECORD

      for VarOfSameTypeIndex := 1 to NumVarOfSameType do begin

// sick2
//	writeln('> ', VarType,',',AllocElementType,',',NumAllocElements);

	if VarType = ENUMTYPE then begin

	  DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, AllocElementType, 0, 0, 0, IdType);

	  Ident[NumIdent].DataType := ENUMTYPE;
	  Ident[NumIdent].AllocElementType := AllocElementType;
	  Ident[NumIdent].NumAllocElements := NumAllocElements;

	end else
	  DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, VarType, NumAllocElements, AllocElementType, ord(isAbsolute) * ConstVal, IdType);

//	writeln(VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',Types[NumAllocElements].Block,' | ', AllocElementType);

	if ( (VarType in Pointers) and (AllocElementType = RECORDTOK) ) then begin

	tmpVarDataSize_ := VarDataSize;

	 if (NumAllocElements shr 16) > 0 then begin											// array [0..x] of record

//	  NumAllocTypes := NumAllocElements shr 16;
//	  NumAllocElements := NumAllocElements and $FFFF;

//  	   DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, POINTERTOK, NumAllocElements and $FFFF, AllocElementType);

	   Ident[NumIdent].NumAllocElements := NumAllocElements and $FFFF;

	   VarDataSize := tmpVarDataSize + (NumAllocElements and $FFFF) * DataSize[POINTERTOK];

//  	  DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name+'.@ALLOC', VARIABLE, BYTETOK, (NumAllocElements and $FFFF)*RecordSize(NumIdent), BYTETOK, 0,0);

	   tmpVarDataSize := VarDataSize;

	   NumAllocElements := NumAllocElements shr 16;

	 end else
	   if Ident[NumIdent].isAbsolute = false then inc(tmpVarDataSize, DataSize[POINTERTOK]);		// wskaznik dla ^record


//writeln(NumAllocElements);
//!@!@
	 for ParamIndex := 1 to Types[NumAllocElements].NumFields do									// label: ^record
	  if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//	    writeln(VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name);

	    DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,
	    VARIABLE,
	    Types[NumAllocElements].Field[ParamIndex].DataType,
	    Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
	    Types[NumAllocElements].Field[ParamIndex].AllocElementType, 0, DATAORIGINOFFSET);

	    Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize_;
	    Ident[NumIdent].PassMethod := VARPASSING;
	    Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;

	  end;

	  VarDataSize := tmpVarDataSize;

	end else

	if (VarType in [RECORDTOK, OBJECTTOK]) then											// label: record
	 for ParamIndex := 1 to Types[NumAllocElements].NumFields do
	  if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//	    writeln(VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,',',Types[NumAllocElements].Field[ParamIndex].DataType,',',Types[NumAllocElements].Field[ParamIndex].AllocElementType);

	    DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,
	    VARIABLE,
	    Types[NumAllocElements].Field[ParamIndex].DataType,
	    Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
	    Types[NumAllocElements].Field[ParamIndex].AllocElementType, ord(isAbsolute) * ConstVal);

	    if isAbsolute then
	      if not (Types[NumAllocElements].Field[ParamIndex].DataType in [RECORDTOK, OBJECTTOK]) then
		inc(ConstVal, DataSize[Types[NumAllocElements].Field[ParamIndex].DataType]);

	  end;

      end;


       if isAbsolute then

	VarDataSize := tmpVarDataSize

       else

       if Tok[i + 1].Kind = EQTOK then begin

	if VarType in [RECORDTOK, OBJECTTOK] then
	 Error(i + 1, 'Initialization for '+InfoAboutToken(VarType)+' not allowed');

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'Only one variable can be initialized');

	inc(i);

	idx := Ident[NumIdent].Value - DATAORIGIN;

	if not (VarType in Pointers) then begin

	 Ident[NumIdent].isInitialized := true;

	 i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

	 if (VarType in RealTypes) and (ActualParamType = REALTOK) then ActualParamType := VarType;

	 GetCommonConstType(i, VarType, ActualParamType);

	 SaveToDataSegment(idx, ConstVal, VarType);

	end else begin

	 Ident[NumIdent].isInit := true;

//	 if Ident[NumIdent].NumAllocElements = 0 then
//	  Error(i + 1, 'Illegal expression');

	  inc(i);


	  if Tok[i].Kind = ADDRESSTOK then begin

	    if Tok[i + 1].Kind <> IDENTTOK then
	      iError(i + 1, IdentifierExpected)
	    else begin
	      IdentIndex := GetIdent(Tok[i + 1].Name^);

	      if IdentIndex > 0 then begin

	       if (Ident[IdentIndex].Kind = CONSTANT) then begin

		if not ( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
		  Error(i + 1, 'Can''t take the address of constant expressions')
		else
		 SaveToDataSegment(idx, Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_Atari, CODEORIGINOFFSET);

	       end else
		 SaveToDataSegment(idx, Ident[IdentIndex].Value - DATAORIGIN, DATAORIGINOFFSET);

	       VarType := POINTERTOK;

	      end else
	       iError(i + 1, UnknownIdentifier);

	    end;

	    inc(i);

	  end else
	  if Tok[i].Kind = CHARLITERALTOK then begin

	   SaveToDataSegment(idx, 1, BYTETOK);
	   SaveToDataSegment(idx+1, Tok[i].Value, BYTETOK);

	   VarType := POINTERTOK;

	  end else
	  if Tok[i].Kind = STRINGLITERALTOK then begin

	   if Tok[i].StrLength > Ident[NumIdent].NumAllocElements then begin
	    Warning(i, StringTruncated, NumIdent);

	    ParamIndex := Ident[NumIdent].NumAllocElements;
	   end else
	    ParamIndex := Tok[i].StrLength + 1;

	   VarType := STRINGPOINTERTOK;

	   for j := 0 to ParamIndex-1 do		// string = ''
	    SaveToDataSegment(idx + j, ord( StaticStringData[ Tok[i].StrAddress - CODEORIGIN + j ] ), BYTETOK);

	  end else
	   if Ident[NumIdent].NumAllocElements = 0 then
	    iError(i, IllegalExpression)
	   else						// array [] of type = ( )
	    i := ReadDataArray(i, idx, Ident[NumIdent].AllocElementType, Ident[NumIdent].NumAllocElements or Ident[NumIdent].NumAllocElements_ shl 16 );

	end;

       end;

      CheckTok(i + 1, SEMICOLONTOK);

    i := i + 1;
    until Tok[i + 1].Kind <> IDENTTOK;

    i := i + 1;
    end;// if VARTOK



  if Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK] then
    if Tok[i + 1].Kind <> IDENTTOK then
      Error(i + 1, 'Procedure name expected but ' + GetSpelling(i + 1) + ' found')
    else
      begin

      IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);


      if INTERFACETOK_USE then
       ForwardIdentIndex := 0
      else
       ForwardIdentIndex := GetIdent(Tok[i + 1].Name^);


      if (ForwardIdentIndex <> 0) and (Ident[ForwardIdentIndex].isOverload) then begin     // !!! dla forward; overload;

       j:=i;
       FormalParameterList(j, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

       ForwardIdentIndex := GetIdentProc( Ident[ForwardIdentIndex].Name, Param, ParamIndex) ;

      end;


      if ForwardIdentIndex <> 0 then
       if (Ident[ForwardIdentIndex].IsUnresolvedForward) and (Ident[ForwardIdentIndex].Block = BlockStack[BlockStackTop]) then
	if Tok[i].Kind <> Ident[ForwardIdentIndex].Kind then
	 Error(i, 'Unresolved forward declaration of ' + Ident[ForwardIdentIndex].Name);


      if ForwardIdentIndex <> 0 then
       if not Ident[ForwardIdentIndex].IsUnresolvedForward or
	 (Ident[ForwardIdentIndex].Block <> BlockStack[BlockStackTop]) or
	 ((Tok[i].Kind = PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROC)) or
	 ((Tok[i].Kind = FUNCTIONTOK) and (Ident[ForwardIdentIndex].Kind <> FUNC)) then
	ForwardIdentIndex := 0;     // Found an identifier of another kind or scope, or it is already resolved


//    writeln(ForwardIdentIndex,',',tok[i].line,',',Ident[ForwardIdentIndex].isOverload,',',Ident[ForwardIdentIndex].IsUnresolvedForward,' / ',Tok[i].Kind = PROCEDURETOK,',',  ((Tok[i].Kind = PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROC)));

    i := DefineFunction(i, ForwardIdentIndex, isForward, isInt, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);


    // Check for a FORWARD directive (it is not a reserved word)
    if ((ForwardIdentIndex = 0) and isForward) or INTERFACETOK_USE then  // Forward declaration
      begin
      Inc(NumBlocks);
      Ident[NumIdent].ProcAsBlock := NumBlocks;
      Ident[NumIdent].IsUnresolvedForward := TRUE;

      //GenerateForwardReference;
      //NextTok;
      end
    else
      begin

      if ForwardIdentIndex = 0 then							// New declaration
	begin

	TestIdentProc(i, Ident[NumIdent].Name);

       // Inc(NumBlocks);
       // Ident[NumIdent].ProcAsBlock := NumBlocks;
      //  CompileBlock(NumIdent);

	if ((Pass = CODEGENERATIONPASS) and ( not Ident[NumIdent].IsNotDead) ) then	// Do not compile dead procedures and functions
	  begin
	  OutputDisabled := TRUE;
	  end;

	iocheck_old := IOCheck;

	j := CompileBlock(i + 1, NumIdent, Ident[NumIdent].NumParams, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	IOCheck := iocheck_old;

	i := j + 1;

	GenerateReturn(IsNestedFunction, isInt);

	if OutputDisabled then OutputDisabled := FALSE;

	end
      else											// Forward declaration resolution
	begin
      //  GenerateForwardResolution(ForwardIdentIndex);
      //  CompileBlock(ForwardIdentIndex);

	if ((Pass = CODEGENERATIONPASS) and ( not Ident[ForwardIdentIndex].IsNotDead) ) then	// Do not compile dead procedures and functions
	  begin
	  OutputDisabled := TRUE;
	  end;

	Ident[ForwardIdentIndex].Value := CodeSize;

	FormalParameterList(i, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	dec(i, 2);

	if ParamIndex > 0 then begin

	 if Ident[ForwardIdentIndex].NumParams <> ParamIndex then
	   Error(i, 'Wrong number of parameters specified for call to '+''''+Ident[ForwardIdentIndex].Name+'''');

//	   function header ”arg1” doesn’t match forward : var name changes arg2 = arg3

	 for ParamIndex := 1 to Ident[ForwardIdentIndex].NumParams do
	  if (Ident[ForwardIdentIndex].Param[ParamIndex].Name <> Param[ParamIndex].Name) then
	    Error(i, 'Function header '''+Ident[ForwardIdentIndex].Name+''' doesn''t match forward : '+  Ident[ForwardIdentIndex].Param[ParamIndex].Name +' <> ' + Param[ParamIndex].Name);

	 for ParamIndex := 1 to Ident[ForwardIdentIndex].NumParams do
	  if (Ident[ForwardIdentIndex].Param[ParamIndex].PassMethod <> Param[ParamIndex].PassMethod) then
	    Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');

	end;

	 Tmp := 0;

	 if Ident[ForwardIdentIndex].isOverload then Tmp := Tmp or ord(mOverload);
	 if Ident[ForwardIdentIndex].isAsm then Tmp := Tmp or ord(mAssembler);
	 if Ident[ForwardIdentIndex].isRegister then Tmp := Tmp or ord(mRegister);
	 if Ident[ForwardIdentIndex].isInterrupt then Tmp := Tmp or ord(mInterrupt);

	 if Tmp <> TmpResult then
	   Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');


	 if IsNestedFunction then
	   if (Ident[ForwardIdentIndex].DataType <> NestedFunctionResultType) or
	      (Ident[ForwardIdentIndex].NestedFunctionNumAllocElements <> NestedFunctionNumAllocElements) or
	      (Ident[ForwardIdentIndex].NestedFunctionAllocElementType <> NestedFunctionAllocElementType) then
	     Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');


	CheckTok(i + 2, SEMICOLONTOK);

	iocheck_old := IOCheck;

	j := CompileBlock(i + 3, ForwardIdentIndex, Ident[ForwardIdentIndex].NumParams, IsNestedFunction, Ident[ForwardIdentIndex].DataType, Ident[ForwardIdentIndex].NestedFunctionNumAllocElements, Ident[ForwardIdentIndex].NestedFunctionAllocElementType);

	IOCheck := iocheck_old;

	i := j + 1;

	GenerateReturn(IsNestedFunction, isInt);

	if OutputDisabled then OutputDisabled := FALSE;

	Ident[ForwardIdentIndex].IsUnresolvedForward := FALSE;

	end;

      end;


	CheckTok(i, SEMICOLONTOK);

	inc(i);

	end;// else
  end;// while


OutputDisabled := (Pass = CODEGENERATIONPASS) and (BlockStack[BlockStackTop] <> 1) and (not Ident[BlockIdentIndex].IsNotDead);


if not isAsm then begin
 GenerateDeclarationEpilog;  // Make jump to block entry point

 CheckTok(i, BEGINTOK);
end;


// Initialize array origin pointers if the current block is the main program body
{
if BlockStack[BlockStackTop] = 1 then begin

  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then
      begin
//      Push(Ident[IdentIndex].Value + SizeOf(Int64), ASVALUE, DataSize[POINTERTOK], Ident[IdentIndex].Kind);     // Array starts immediately after the pointer to its origin
//      GenerateAssignment(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
      asm65(#9'mwa #DATAORIGIN+$' + IntToHex(Ident[IdentIndex].Value - DATAORIGIN + DataSize[POINTERTOK], 4) + ' DATAORIGIN+$' + IntToHex(Ident[IdentIndex].Value - DATAORIGIN , 4), '; ' + Ident[IdentIndex].Name );

      end;

end;
}


Result := CompileStatement(i, isAsm);


j := NumIdent;

// Delete local identifiers and types from the tables to save space
while (j > 0) and (Ident[j].Block = BlockStack[BlockStackTop]) do
  begin
  // If procedure or function, delete parameters first
  if Ident[j].Kind in [PROC, FUNC] then
    if Ident[j].IsUnresolvedForward then
      Error(i, 'Unresolved forward declaration of ' + Ident[j].Name);

  Dec(j);
  end;


// Return Result value

if IsFunction then begin
// if FunctionNumAllocElements > 0 then
//  Push(Ident[GetIdent('RESULT')].Value, ASVALUE, DataSize[FunctionResultType], GetIdent('RESULT'))
// else
  asm65('');
  asm65('@exit');

  Push(Ident[GetIdent('RESULT')].Value, ASPOINTER, DataSize[FunctionResultType], GetIdent('RESULT'));

  asm65('');
  asm65(#9'.ifdef @new');
  asm65(#9'@FreeMem #@VarData #@VarDataSize');
  asm65(#9'eif');

end;

if Ident[BlockIdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK] then GenerateProcFuncAsmLabels(BlockIdentIndex, true);

Dec(BlockStackTop);

//Result := j;
end;// CompileBlock


procedure CompileProgram;
var i, j, DataSegmentSize, IdentIndex: Integer;
    tmp: string;
    yes: Boolean;
begin

IOCheck := true;

DataSegmentSize := 0;

AsmBlockIndex := 0;

SetLength(AsmLabels, 1);

DefineIdent(1, 'MAIN', PROC, 0, 0, 0, 0);

GenerateProgramProlog;

j := CompileBlock(1, NumIdent, 0, FALSE, 0);


if Tok[j].Kind = ENDTOK then CheckTok(j + 1, DOTTOK) else
 if Tok[NumTok].Kind = EOFTOK then
   Error(NumTok, 'Unexpected end of file');

j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = 1) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROC, FUNC] then
       if Ident[j].IsUnresolvedForward then
	 Error(j, 'Unresolved forward declaration of ' + Ident[j].Name);

     Dec(j);
     end;

StopOptimization;

asm65('');
asm65('@exit');
asm65('');
asm65('@halt'#9'ldx #0');
asm65(#9'txs');

asm65('');
asm65(#9'rts');

asm65('');
asm65('IOCB@COPY'#9':16 brk');

asm65('');
asm65('.local'#9'@DEFINES');

for j:=1 to MAXDEFINES do
 if Defines[j]<>'' then asm65(Defines[j]);

asm65('.endl');

asm65('');
asm65('.endl');
//GenerateReturn(false, false);

asm65separator;

asm65(#13#10#9'icl ''cpu6502.asm''');

asm65separator;

asm65('');
asm65('.macro UNITINITIALIZATION');

for j := NumUnits downto 2 do
 if UnitName[j].Name <> '' then begin

  asm65('');
  asm65(#9'.ifdef MAIN.'+UnitName[j].Name+'.@UnitInit');
  asm65(#9'jsr MAIN.'+UnitName[j].Name+'.@UnitInit');
  asm65(#9'eif');

 end;

asm65('.endm');


for j := NumUnits downto 2 do
 if UnitName[j].Name <> '' then begin
  asm65(#13#10#9'ift .SIZEOF(MAIN.'+UnitName[j].Name+') > 0');
  asm65(#9'.print '''+UnitName[j].Name+': '+''',MAIN.'+UnitName[j].Name+','+'''..'''+','+'MAIN.'+UnitName[j].Name+'+.SIZEOF(MAIN.'+UnitName[j].Name+')-1');
  asm65(#9'eif');
 end;

asm65(#13#10#9'.print ''CODE: '',CODEORIGIN,''..'',*-1');

if DATA_Atari > 0 then asm65(#13#10#9'org $'+IntToHex(DATA_Atari, 4));

asm65(#13#10'DATAORIGIN');

if DataSegmentUse then begin
 if Pass = CODEGENERATIONPASS then begin

// !!! musze zapisac wszystko, lacznie z 'zerami' !!! np. aby TextAtr dzialal

  for j := VarDataSize - 1 downto 0 do
   if DataSegment[j] <> 0 then begin DataSegmentSize := j+1; Break end;

  tmp:='';

  for j := 0 to DataSegmentSize-1 do begin

   if (j mod 24 = 0) then begin
    if tmp <> '' then asm65(tmp);
    tmp:='.by';
   end;

   if (j mod 8 = 0) then tmp:=tmp+' ';

   if DataSegment[j] and $c000 = $8000 then
    tmp:=tmp+' <[DATAORIGIN+$' + IntToHex(byte(DataSegment[j]) or byte(DataSegment[j+1]) shl 8, 4)+']'
   else
   if DataSegment[j] and $c000 = $4000 then
    tmp:=tmp+' >[DATAORIGIN+$' + IntToHex(byte(DataSegment[j-1]) or byte(DataSegment[j]) shl 8, 4)+']'
   else
   if DataSegment[j] and $3000 = $2000 then
    tmp:=tmp+' <[CODEORIGIN+$' + IntToHex(byte(DataSegment[j]) or byte(DataSegment[j+1]) shl 8, 4)+']'
   else
   if DataSegment[j] and $3000 = $1000 then
    tmp:=tmp+' >[CODEORIGIN+$' + IntToHex(byte(DataSegment[j-1]) or byte(DataSegment[j]) shl 8, 4)+']'
   else
    tmp:=tmp+' $' + IntToHex(DataSegment[j],2);

  end;

  if tmp <> '' then asm65(tmp);

 // asm65('');

//  asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',*');

 end;

end;{ else
 asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',DATAORIGIN+'+IntToStr(VarDataSize));
}

asm65('');
asm65('VARINITSIZE'#9'= *-DATAORIGIN');
asm65('VARDATASIZE'#9'= '+IntToStr(VarDataSize));

asm65(#13#10'PROGRAMSTACK'#9'= DATAORIGIN+VARDATASIZE');

asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',PROGRAMSTACK');


if FastMul > 0  then begin

 asm65separator;

 asm65(#13#10#9'icl ''6502\cpu6502_fmul.asm''', '; fast multiplication');

 asm65(#13#10#9'.print ''FMUL_INIT: '',fmulinit,''..'',*');

 asm65(#13#10#9'org $'+IntToHex(FastMul, 2)+'00');

 asm65(#13#10#9'.print ''FMUL_DATA: '',*,''..'',*+$0800');

 asm65('');
 asm65('square1_lo'#9'.ds $200');
 asm65('square1_hi'#9'.ds $200');
 asm65('square2_lo'#9'.ds $200');
 asm65('square2_hi'#9'.ds $200');

end;

asm65('');
asm65(#9'run START');

asm65separator;


asm65(#13#10'.macro'#9'STATICDATA');

 tmp:='';
 for i := 0 to NumStaticStrChars - 1 do begin

  if (i mod 24=0) then begin
   if i>0 then tmp:=tmp+#13#10;
   tmp:=tmp+'.by ';
  end else
   if (i>0) and (i mod 8=0) then tmp:=tmp+' ';

  if StaticStringData[i] and $c000 = $8000 then
   tmp:=tmp+' <[DATAORIGIN+$'+IntToHex(byte(StaticStringData[i]) or byte(StaticStringData[i+1]) shl 8, 4)+']'
  else
  if StaticStringData[i] and $c000 = $4000 then
   tmp:=tmp+' >[DATAORIGIN+$'+IntToHex(byte(StaticStringData[i-1]) or byte(StaticStringData[i]) shl 8, 4)+']'
  else
  if StaticStringData[i] and $3000 = $2000 then
   tmp:=tmp+' <[CODEORIGIN+$'+IntToHex(byte(StaticStringData[i]) or byte(StaticStringData[i+1]) shl 8, 4)+']'
  else
  if StaticStringData[i] and $3000 = $1000 then
   tmp:=tmp+' >[CODEORIGIN+$'+IntToHex(byte(StaticStringData[i-1]) or byte(StaticStringData[i]) shl 8, 4)+']'
  else
   tmp:=tmp+' $'+IntToHex(StaticStringData[i], 2);

 end;

 if tmp<>'' then asm65(tmp);

 asm65('.endm');


//asm65(#13#10'.macro'#9'RESOURCE');

 for i := 0 to High(resArray) - 1 do begin

  yes:=false;
  for IdentIndex := 1 to NumIdent do
    if (resArray[i].resName = Ident[IdentIndex].Name) and (Ident[IdentIndex].Block = 1) then begin

     if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then
      tmp := GetLocalName(IdentIndex, 'adr.')
     else
      tmp := GetLocalName(IdentIndex);

     yes:=true; Break;
    end;

  if not yes then
    Error(NumTok, 'Resource identifier not found: Type = '+resArray[i].resType+', Name = '+resArray[i].resName);

//  asm65(#9+resArray[i].resType+' '''+resArray[i].resFile+''''+','+resArray[i].resName);

  resArray[i].resFullName := tmp;

  Ident[IdentIndex].Pass := Pass;
 end;

//asm65('.endm');


asm65(#13#10#9'end');

OptimizeTMP;

end;// CompileProgram


procedure OptimizeProgram;

  procedure MarkNotDead(IdentIndex: Integer);
  var
    ChildIndex, ChildIdentIndex: Integer;
  begin

  Ident[IdentIndex].IsNotDead := TRUE;

  for ChildIndex := 1 to CallGraph[Ident[IdentIndex].ProcAsBlock].NumChildren do
    for ChildIdentIndex := 1 to NumIdent do
      if Ident[ChildIdentIndex].ProcAsBlock = CallGraph[Ident[IdentIndex].ProcAsBlock].ChildBlock[ChildIndex] then
	MarkNotDead(ChildIdentIndex);
  end;

begin
// Perform dead code elimination
 MarkNotDead(GetIdent('MAIN'));
end;


procedure Diagnostics;
var i, CharIndex, ChildIndex: Integer;
    DiagFile: textfile;
begin

  AssignFile(DiagFile, ChangeFileExt( UnitName[1].Name, '.dat') );
  Rewrite(DiagFile);

  WriteLn(DiagFile);
  WriteLn(DiagFile, 'Token list: ');
  WriteLn(DiagFile);
  WriteLn(DiagFile, '#': 6, 'Unit': 30, 'Line': 6, 'Token': 30);
  WriteLn(DiagFile);

  for i := 1 to NumTok do
    begin
    Write(DiagFile, i: 6, UnitName[Tok[i].UnitIndex].Name: 30, Tok[i].Line: 6, GetSpelling(i): 30);
    if Tok[i].Kind = INTNUMBERTOK then
      WriteLn(DiagFile, ' = ', Tok[i].Value)
    else if Tok[i].Kind = FRACNUMBERTOK then
      WriteLn(DiagFile, ' = ', Tok[i].FracValue: 8: 4)
    else if Tok[i].Kind = IDENTTOK then
      WriteLn(DiagFile, ' = ', Tok[i].Name^)
    else if Tok[i].Kind = CHARLITERALTOK then
      WriteLn(DiagFile, ' = ', Chr(Tok[i].Value))
    else if Tok[i].Kind = STRINGLITERALTOK then
      begin
      Write(DiagFile, ' = ');
      for CharIndex := 1 to Tok[i].StrLength do
	Write(DiagFile, StaticStringData[Tok[i].StrAddress - CODEORIGIN + (CharIndex - 1)]);
      WriteLn(DiagFile);
      end
    else
      WriteLn(DiagFile);
    end;// for

  WriteLn(DiagFile);
  WriteLn(DiagFile, 'Identifier list: ');
  WriteLn(DiagFile);
  WriteLn(DiagFile, '#': 6, 'Block': 6, 'Name': 30, 'Kind': 15, 'Type': 15, 'Items/Params': 15, 'Value/Addr': 15, 'Dead': 5);
  WriteLn(DiagFile);

  for i := 1 to NumIdent do
    begin
    Write(DiagFile, i: 6, Ident[i].Block: 6, Ident[i].Name: 30, Spelling[Ident[i].Kind]: 15);
    if Ident[i].DataType <> 0 then Write(DiagFile, Spelling[Ident[i].DataType]: 15) else Write(DiagFile, 'N/A': 15);
    Write(DiagFile, Ident[i].NumAllocElements: 15, IntToHex(Ident[i].Value, 8): 15);
    if ((Ident[i].Kind = PROC) or (Ident[i].Kind = FUNC)) and not Ident[i].IsNotDead then WriteLn(DiagFile, 'Yes': 5) else WriteLn(DiagFile, '': 5);
    end;

  WriteLn(DiagFile);
  WriteLn(DiagFile, 'Call graph: ');
  WriteLn(DiagFile);

  for i := 1 to NumBlocks do
    begin
    Write(DiagFile, i: 6, '  ---> ');
    for ChildIndex := 1 to CallGraph[i].NumChildren do
      Write(DiagFile, CallGraph[i].ChildBlock[ChildIndex]: 5);
    WriteLn(DiagFile);
    end;

  WriteLn(DiagFile);
  CloseFile(DiagFile);

end;


procedure Syntax(ExitCode: byte);
begin

  WriteLn('Syntax: mp <inputfile> [options]');
  WriteLn('-d'#9#9'Diagnostics mode');
  WriteLn('-code:address'#9'Code origin hex address');
  WriteLn('-data:address'#9'Data origin hex address');
  WriteLn('-stack:address'#9'Software stack hex address (size = 64 bytes)');
  WriteLn('-zpage:address'#9'Variables on the zero page hex address (size = 24 bytes)');

  Halt(ExitCode);

end;


procedure ParseParam;
var i, err: integer;
begin

 for i := 1 to ParamCount do begin

  if ParamStr(i)[1] = '-' then begin

   if AnsiUpperCase(ParamStr(i)) = '-O' then
//    OptimizeCode := TRUE
   else
   if AnsiUpperCase(ParamStr(i)) = '-D' then
    DiagMode := TRUE
   else
   if pos('-CODE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 7, 255), CODEORIGIN_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if pos('-DATA:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 7, 255), DATA_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if pos('-STACK:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 8, 255), STACK_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if pos('-ZPAGE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 8, 255), ZPAGE_Atari, err);
     if err<>0 then Syntax(3);

   end else
     Syntax(3);

  end else

   if not FileExists(ParamStr(i)) then begin
    writeln('Error: Can''t open file '''+ParamStr(i)+'''');
    FreeTokens;
    Halt(3);
   end else begin
    UnitName[1].Name := ParamStr(i);
    UnitName[1].Path := ParamStr(i);
   end;

 end;

end;


// Main program

begin
//WriteLn('Sub-Pascal 32-bit real mode compiler v. 2.0 by Vasiliy Tereshkov, 2009');

 WriteLn(CompilerTitle);

 SetLength(Tok, 1);

 Tok[NumTok].Line := 0;
 UnitName[1].Name := '';

 MainPath := ExtractFilePath(ParamStr(0));

 SetLength(UnitPath, 2);

 MainPath := IncludeTrailingPathDelimiter( MainPath );
 UnitPath[0] := IncludeTrailingPathDelimiter( MainPath + 'lib' );

 if (ParamCount = 0) then Syntax(3);

 NumUnits:=1;			     // !!! 1 !!!

 ParseParam;

 if (UnitName[1].Name='') then Syntax(3);

 if pos(MainPath, ExtractFilePath(UnitName[1].name)) > 0 then
  FilePath := ExtractFilePath(UnitName[1].Name)
 else
  FilePath := MainPath + ExtractFilePath(UnitName[1].Name);

 DefaultFormatSettings.DecimalSeparator := '.';

 SetLength(resArray, 1);


 {$IFDEF USEOPTFILE}

 AssignFile(OptFile, ChangeFileExt(UnitName[1].Name, '.opt') ); rewrite(OptFile);

 {$ENDIF}


 AssignFile(OutFile, ChangeFileExt(UnitName[1].Name, '.a65') ); rewrite(OutFile);

 Writeln('Compiling ', UnitName[1].Name);

 start_time:=GetTickCount64;

// Set defines for first pass
 NumDefines := 1; IfdefLevel := 0;
 Defines[1] := 'ATARI';

 TokenizeProgram;				// AsmBlockIndex = 0


 if NumTok=0 then Error(1, '');

 inc(NumUnits);
 UnitName[NumUnits].Name := 'SYSTEM';		// default UNIT 'system.pas'
 UnitName[NumUnits].Path := FindFile('system.pas', 'unit');


//if NumUnits > 2 then begin			// jeszcze raz tym razem z unitami

 fillchar(Ident, sizeof(Ident), 0);
 fillchar(DataSegment, sizeof(DataSegment), 0);
 fillchar(StaticStringData, sizeof(StaticStringData), 0);

 PublicSection := true;
 UnitNameIndex := 1;

 SetLength(resArray, 1);
 SetLength(msgUser, 1);

 BlockStackTop := 0; CodeSize := 0; CodePosStackTop := 0;
 VarDataSize := 0; NumStaticStrChars := 0;
 NumBlocks := 0; NumTypes := 0;
 CaseCnt :=0; IfCnt := 0;
 NumTok := 0; NumIdent := 0;
 NumDefines := 1; IfdefLevel := 0;
 Defines[1] := 'ATARI';
 AsmBlockIndex := 0;
 optyA := '';
 optyY := '';
 optyBP2 := '';
 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 for i := 0 to High(AsmBlock) do AsmBlock[i]:='';

 TokenizeProgram(false);

//end;

 NumStaticStrCharsTmp :=  NumStaticStrChars;

// Predefined constants
 DefineIdent(1, 'BLOCKREAD',      FUNC, INTEGERTOK, 0, 0, $00000000);
 DefineIdent(1, 'BLOCKWRITE',     FUNC, INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'NIL',      CONSTANT, POINTERTOK, 0, 0, CODEORIGIN);
 DefineIdent(1, 'EOL',      CONSTANT, CHARTOK, 0, 0, $0000009B);
 DefineIdent(1, 'TRUE',     CONSTANT, BOOLEANTOK, 0, 0, $00000001);
 DefineIdent(1, 'FALSE',    CONSTANT, BOOLEANTOK, 0, 0, $00000000);
 DefineIdent(1, 'FRACBITS', CONSTANT, INTEGERTOK, 0, 0, FRACBITS);
 DefineIdent(1, 'FRACMASK', CONSTANT, INTEGERTOK, 0, 0, TWOPOWERFRACBITS - 1);
 DefineIdent(1, 'PI',       CONSTANT, REALTOK, 0, 0, $40490FDB00000324);
 DefineIdent(1, 'NAN',      CONSTANT, SINGLETOK, 0, 0, $FFC00000FFC00000);
 DefineIdent(1, 'INFINITY', CONSTANT, SINGLETOK, 0, 0, $7F8000007F800000);
 DefineIdent(1, 'NEGINFINITY', CONSTANT, SINGLETOK, 0, 0, $FF800000FF800000);

// DefineIdent(1, 'TMEMORYSTREAM', USERTYPE, OBJECTTOK, 0, 0, 0);

// First pass: compile the program and build call graph
 NumPredefIdent := NumIdent;
 Pass := CALLDETERMPASS;
 CompileProgram;


// Visit call graph nodes and mark all procedures that are called as not dead
 OptimizeProgram;

// Second pass: compile the program and generate output (IsNotDead fields are preserved since the first pass)
 NumIdent := NumPredefIdent;

 fillchar(DataSegment, sizeof(DataSegment), 0);

 NumBlocks := 0; BlockStackTop := 0; CodeSize := 0; CodePosStackTop := 0;
 VarDataSize := 0; NumStaticStrChars := NumStaticStrCharsTmp;
 CaseCnt :=0; IfCnt := 0; NumTypes := 0;
 optyA := '';
 optyY := '';
 optyBP2 := '';
 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 PROGRAMTOK_USE := false;
 INTERFACETOK_USE := false;
 PublicSection := true;

 for i := 1 to MAXUNITS do UnitName[i].Units := 0;

 SetLength(TemporaryBuf, 1);
 SetLength(OptimizeBuf, 1);
 SetLength(msgWarning, 1);
 SetLength(msgNote, 1);

 Pass := CODEGENERATIONPASS;
 CompileProgram;

 Flush(OutFile);
 CloseFile(OutFile);

{$IFDEF USEOPTFILE}

 CloseFile(OptFile);

{$ENDIF}


// Diagnostics
 if DiagMode then Diagnostics;

 WritelnMsg;

 Writeln(Tok[NumTok].Line, ' lines compiled, ', ((GetTickCount64 - start_time + 500)/1000):2:2,' sec, ',
	 NumTok, ' tokens, ',NumIdent, ' idents, ',  NumBlocks, ' blocks, ', NumTypes, ' types');

 FreeTokens;

 if High(msgWarning) > 0 then Writeln(High(msgWarning), ' warning(s) issued');
 if High(msgNote) > 0 then Writeln(High(msgNote), ' note(s) issued');

end.
