(*

Sub-Pascal 32-bit real mode compiler for 80386+ processors v. 2.0 by Vasiliy Tereshkov, 2009

https://atariage.com/forums/topic/240919-mad-pascal/
http://atarionline.pl/forum/comments.php?DiscussionID=4825&page=1

https://habr.com/en/post/440372/?fbclid=IwAR3SdW_HAqt6psraDj41UtNxFEXIgynOUKvS2d2cwPsJiF0kO_kDTNfYZg4

IDE WUDSN
https://atariage.com/forums/topic/145386-wudsn-ide-the-free-integrated-atari-8-bit-development-plugin-for-eclipse/page/25/?tab=comments#comment-4340150


Mad-Pascal cross compiler for 6502 (Atari XE/XL) by Tomasz Biela, 2015-2022

Contributors:

+ Artyom Beilis, Marek Mauder (https://github.com/artyom-beilis/float16) :
	- Float16 (half-single)

+ Bartosz Zbytniewski :
	- Bug Hunter
	- Commodore C4+/C64 minimal unit SYSTEM setup

+ Bostjan Gorisek :
	- unit PMG, ZXLIB

+ Chriss Hutt :
	- unit SMP

+ David Schmenk :
	- IEEE-754 (32bit) Single

+ Daniel Serpell (https://github.com/dmsc) :
	- conditional directives {$IFDEF}, {$ELSE}, {$DEFINE} ...
	- unit SYSTEM: fsincos, fast SIN/COS (IEEE754-32 precision)
	- unit GRAPHICS: TextOut
	- unit GRAPHICS: TextOut
	- unit EFAST
	- unit ZX2

+ Daniel Koźmiński :
	- unit STRINGUTILS
	- unit CIO

+ Guillermo Fuenzalida :
	- unit MISC: DetectANTIC

+ Janusz Chabowski :
	- unit SHANTI

+ Jeff Johnson :
	- opt_BYTE_DIV.inc (Unsigned Integer Division Routines)

+ Jerzy Kut :
	- {$DEFINE ROMOFF}

+ Joseph Zatarski (https://forums.atariage.com/topic/225063-full-color-ansi-vbxe-terminal-in-the-works/) :
	- base\atari\vbxeansi.asm

+ Konrad Kokoszkiewicz :
	- base\atari\cmdline.asm
	- base\atari\vbxedetect.asm
	- unit MISC: DetectCPU, DetectCPUSpeed, DetectMem, DetectHighMem, DetectStereo
	- unit S2 (VBXE handler)

+ Krzysztof Dudek (http://xxl.atari.pl/) :
	- unit XBIOS: BLIBS library
	- unit LZ4: unLZ4
	- unit aPLib: unAPL

+ Marcin Żukowski :
	- unit FASTGRAPH: fLine

+ Michael Jaskula :
	- {$DEFINE BASICOFF} (base\atari\basicoff.asm)

+ Piotr Fusik (https://github.com/pfusik) :
	- base\runtime\icmp.asm
	- unit GRAPH: detect X:Y graphics resolution (OS mode)
	- unit CRC
	- unit DEFLATE: unDEF

+ Sebastian Igielski :
	- unit MISC: DetectStereo

+ Steven Don (https://www.shdon.com/) :
	- unit IMAGE, VIMAGE: BMP, GIF, PCX

+ Ullrich von Bassewitz, Christian Krueger (https://github.com/cc65/cc65/libsrc/common/) :
	- base\common\memmove.asm
	- base\common\memset.asm

+ Ullrich von Bassewitz (https://github.com/cc65/cc65/libsrc/runtime/) :
	- 8x8 => 16 multiplication routine (base\common\byte.asm)
	- 16x8 => 24 multiplication routine (base\common\word.asm)
	- 16x16 => 32 multiplication routine (base\common\word.asm)

+ Wojciech Bociański (http://bocianu.atari.pl/) :
	- library BLIBS: B_CRT, B_DL, B_PMG, B_SYSTEM, B_UTILS, XBIOS
	- MADSTRAP
	- PASDOC


# rejestr X (=$FF) uzywany jest do przekazywania parametrow przez programowy stos :STACKORIGIN
# stos programowy sluzy tez do tymczasowego przechowywania wyrazen, wynikow operacji itp.

# typ REAL Fixed-Point Q16.16 przekracza 32 bity dla MUL i DIV, czesty OVERFLOW

# uzywaj asm65('') zamiast #13#10, POS bedzie wlasciwie zwracalo indeks

# parametry dla imulCL, imulCX w konkretnej kolejnosci 1: ECX, 2: EAX

# wystepuja tylko skoki w przod @+ (@- nie wystepuja)

# s[x][0..3] := '';            -> lda :STACKORIGIN+...
# s[x][0..3] := #9'mva #$00';  -> lda #$00

# :edx+2, :edx+3 nie wystepuje

# 'register' dla procedury/funkcji alokuje parametry na stronie zerowej 1: EDX, 2: ECX, 3: EAX
# 'register' dla zmiennych alokuje maksymalnie 16 bajtow zmniejszajac licznik 1: :TMP, 2: :ECX, 3: :EDX, 4: :EAX

# jeq, jne, jcc, jcs, jmi, jpl l_xxxx

# wartosc dla typu POINTER zwiekszana jest o CODEORIGIN

# :BP  tylko przy adresowaniu 1-go bajtu, :BP = $00 !!!, zmienia sie tylko :BP+1
# :BP2 przy adresowaniu wiecej niz 1-go bajtu (WORD, CARDINAL itd.)

# VAR RECORD
# DataType = RECORDTOK ; AllocElementType = 0 ; NumAllocElements = RecType

# VAR ^RECORD
# DataType = POINTERTOK ; AllocElementType = RECORDTOK ; NumAllocElements = RecType

# indeks dla jednowymiarowej tablicy [0..x] = a * DataSize[AllocElementType]
# indeks dla dwuwymiarowej tablicy [0..x, 0..y] = a * ((y+1) * DataSize[AllocElementType]) + b * DataSize[AllocElementType]

# tablice typu RECORD, OBJECT sa tylko jendowymiarowe [0..x], OBJECT nie testowane
# DataType = POINTERTOK ; AllocElementType = [RECORDTOK, OBJECTTOK] ; NumAllocElements = RecType ; NumAllocElements shl 16 = Array Size

# dla typu OBJECT przekazywany jest poczatkowy adres alokacji danych pamieci (HI = regY, LO = regA), potem sa obliczane kolejne adresy w naglowku procedury/funkcji

# podczas wartosciowania wyrazen typy sa roszerzane, w przypadku operacji '-' promowane do SIGNEDORDINALTYPES (BYTE -> SMALLINTTOK ; WORD -> INTEGERTOK)

# (Tok[ ].Kind = ASMTOK + Tok[ ].Value = 0) wersja z { }
# (Tok[ ].Kind = ASMTOK + Tok[ ].Value = 1) wersja bez { }

*)


program MADPASCAL;

//{$DEFINE WHILEDO}

//{$DEFINE USEOPTFILE}

{$DEFINE OPTIMIZECODE}

{$I+}

uses
  SysUtils,

{$IFDEF WINDOWS}
	windows,
{$ENDIF}
	crt;

const

  title = '1.6.7';

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
  SINGLETOK		= 143;	// Size = 4 SINGLE / FLOAT		IEEE-754 32bit
  HALFSINGLETOK		= 144;	// Size = 2 HALFSINGLE / FLOAT16	IEEE-754 16bit
  PCHARTOK		= 145;	// Size = 2 POINTER TO ARRAY OF CHAR
  ENUMTOK		= 146;	// Size = 1 BYTE
  PROCVARTOK		= 147;	// Size = 2
  TEXTFILETOK		= 148;	// Size = 2/12 FILE
  FORWARDTYPE		= 149;	// Size = 2

  SHORTSTRINGTOK	= 150;	// zamieniamy na STRINGTOK
  FLOATTOK		= 151;	// zamieniamy na SINGLETOK
  FLOAT16TOK		= 152;	// zamieniamy na HALFSINGLETOK
  TEXTTOK		= 153;	// zamieniamy na TEXTFILETOK

  DEREFERENCEARRAYTOK	= 154;	// dla wskaznika do tablicy


  DATAORIGINOFFSET	= 160;
  CODEORIGINOFFSET	= 161;

  IDENTTOK		= 180;
  INTNUMBERTOK		= 181;
  FRACNUMBERTOK		= 182;
  CHARLITERALTOK	= 183;
  STRINGLITERALTOK	= 184;

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

  Pointers		= [POINTERTOK, PROCVARTOK, STRINGPOINTERTOK];

  AllTypes		= OrdinalTypes + RealTypes + Pointers;

  StringTypes		= [STRINGLITERALTOK, STRINGTOK, PCHARTOK];

  // Identifier kind codes

  CONSTANT		= CONSTTOK;
  USERTYPE		= TYPETOK;
  VARIABLE		= VARTOK;
//  PROC			= PROCEDURETOK;
  FUNC			= FUNCTIONTOK;
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
  MAXIDENTS		= 16384;
  MAXBLOCKS		= 16384;	// maksymalna liczba blokow
  MAXPARAMS		= 8;		// maksymalna liczba parametrow dla PROC, FUNC
  MAXVARS		= 256;		// maksymalna liczba parametrow dla VAR
  MAXUNITS		= 512;
  MAXDEFINES		= 256;		// maksymalna liczba $DEFINE
  MAXALLOWEDUNITS	= 256;

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
  ASSTRINGPOINTERTOARRAYORIGIN = 7;
  ASPOINTERTODEREFERENCE = 8;

  ASCHAR		= 6;	// GenerateWriteString
  ASBOOLEAN		= 7;
  ASREAL		= 8;
  ASSHORTREAL		= 9;
  ASHALFSINGLE		= 10;
  ASSINGLE		= 11;
  ASPCHAR		= 12;

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

  DataSize: array [BYTETOK..FORWARDTYPE] of Byte = (1,2,4,1,2,4,1,1,2,2,2,2,2,2,4,4,2,2,1,2,2,2);

  fBlockRead_ParamType : array [1..3] of byte = (UNTYPETOK, WORDTOK, POINTERTOK);

{$i targets/type.inc}

type
  ModifierCode = (mKeep = $100, mOverload= $80, mInterrupt = $40, mRegister = $20, mAssembler = $10, mForward = $08, mPascal = $04, mStdCall = $02, mInline = $01);

  irCode = (iDLI, iVBLD, iVBLI, iTIM1, iTIM2, iTIM4);

  ioCode = (ioOpenRead = 4, ioReadRecord = 5, ioRead = 7, ioOpenWrite = 8, ioAppend = 9, ioWriteRecord = 9, ioWrite = $0b, ioOpenReadWrite = $0c, ioFileMode = $f0, ioClose = $ff);

  ErrorCode =
  (
  UnknownIdentifier, OParExpected, IdentifierExpected, IncompatibleTypeOf, UserDefined,
  IdNumExpExpected, IncompatibleTypes, IncompatibleEnum, OrdinalExpectedFOR, CantAdrConstantExp,
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


  TDefinesParam = array [1..MAXPARAMS] of TString;

  TDefines = record
    Name: TName;
    Macro: string;
    Line: integer;
    Param: TDefinesParam;
  end;

  TParam = record
    Name: TString;
    DataType: Byte;
    NumAllocElements: Cardinal;
    AllocElementType: Byte;
    PassMethod: Byte;
    i, i_: integer;
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
    Size: Integer;
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

    NestedNumAllocElements: cardinal;
    NestedAllocElementType: Byte;
    NestedDataType: Byte;

    NestedFunctionNumAllocElements: cardinal;
    NestedFunctionAllocElementType: Byte;
    isNestedFunction: Boolean;

    LoopVariable,
    isAbsolute,
    isInit,
    isInitialized,
    Section: Boolean;

    case Kind: Byte of
      PROCEDURETOK, FUNCTIONTOK:
	(NumParams: Word;
	 Param: TParamList;
	 ProcAsBlock: Integer;
	 ObjectIndex: Integer;
	 IsUnresolvedForward,
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
     Units: integer;
     Allow: array [1..MAXALLOWEDUNITS] of TString;
    end;

  TResource =
    record
     resStream: Boolean;
     resName, resType, resFile: TString;
     resValue: integer;
     resFullName: string;
     resPar: array [1..MAXPARAMS] of TString;
    end;

  TCaseLabel =
    record
     left, right: Int64;
     equality: Boolean;
    end;

  TPosStack =
    record
     ptr: word;
     brk, cnt: Boolean;
    end;

  TCaseLabelArray = array of TCaseLabel;

  TArrayString = array of string;

{$i targets/var.inc}

var

  PROGRAM_NAME: string = 'Program';

  AsmBlock: array [0..4095] of string;

  Data, DataSegment, StaticStringData: array [0..$FFFF] of Word;

  Types: array [1..MAXTYPES] of TType;
  Tok: array of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  Spelling: array [1..MAXTOKENNAMES] of TString;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;
  Defines: array [1..MAXDEFINES] of TDefines;
  IFTmpPosStack: array of integer;
  BreakPosStack: array [0..1023] of TPosStack;
  CodePosStack: array [0..1023] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;	// For dead code elimination

  OldConstValType: byte;

  NumTok: integer = 0;

  AddDefines: integer = 1;
  NumDefines: integer = 1;	// NumDefines = AddDefines

  i, NumIdent, NumTypes, NumPredefIdent, NumStaticStrChars, NumUnits, NumBlocks, run_func, NumProc,
  BlockStackTop, CodeSize, CodePosStackTop, BreakPosStackTop, VarDataSize, Pass, ShrShlCnt,
  NumStaticStrCharsTmp, AsmBlockIndex, IfCnt, CaseCnt, IfdefLevel, Debug: Integer;

  iOut: integer = -1;

  start_time: QWord;

  CODEORIGIN_BASE: integer = $2000;

   DATA_Atari: integer = -1;
  ZPAGE_Atari: integer = -1;
  STACK_Atari: integer = -1;

  UnitNameIndex: Integer = 1;

  FastMul: Integer = -1;

  CPUMode: Integer = 6502;

  OutFile: TextFile;

  asmLabels: array of integer;

  TemporaryBuf: array [0..255] of string;

  resArray: array of TResource;

  MainPath, FilePath, optyA, optyY, optyBP2: string;
  optyFOR0, optyFOR1, optyFOR2, optyFOR3, outTmp, outputFile: string;

  msgWarning, msgNote, msgUser, UnitPath, OptimizeBuf, LinkObj: TArrayString;

  optimize : record
	      use: Boolean;
	      unitIndex, line, old: integer;
	     end;

  codealign : record
		proc, loop, link : integer;
	      end;


  PROGRAMTOK_USE, INTERFACETOK_USE: Boolean;
  OutputDisabled, isConst, isError, isInterrupt, IOCheck, Macros: Boolean;

  DiagMode: Boolean = false;
  DataSegmentUse: Boolean = false;

  PublicSection : Boolean = true;


{$IFDEF USEOPTFILE}

  OptFile: TextFile;

{$ENDIF}


function Tab2Space(a: string; spc: byte = 8): string;
var column, nextTabStop: integer;
    ch: char;
begin

 Result := '';
 column:=0;

 for ch in a do
  case ch of

   #9:
	begin
		nextTabStop := (column + spc) div spc * spc;
		while column <> nextTabStop do begin Result := Result + ' '; inc(column) end;
	end;

   CR, LF:
	begin
		Result := Result + ch;
		column:=0;
        end;

  else
		Result := Result + ch;
		inc(column);
  end;

end;


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
 SetLength(IFTmpPosStack, 0);
 SetLength(UnitPath, 0);
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

    PROCVARTOK: Result := '"<Procedure Variable>"';

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


procedure WritelnMsg;
var i: integer;
begin

 TextColor(LIGHTGREEN);

 for i := 0 to High(msgWarning) - 1 do writeln(msgWarning[i]);

 TextColor(LIGHTCYAN);

 for i := 0 to High(msgNote) - 1 do writeln(msgNote[i]);

 NormVideo;

end;


function GetEnumName(IdentIndex: integer): TString;
var IdentTtemp: integer;


  function Search(Num: cardinal): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do	// search all nesting levels from the current one to the most outer one
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

 CantAdrConstantExp: Result := 'Can''t take the address of constant expressions';

       OParExpected: Result := '''(''' + ErrTokenFound(ErrTokenIndex);

  IllegalExpression: Result := 'Illegal expression';
   VariableExpected: Result := 'Variable identifier expected';
 OrdinalExpExpected: Result := 'Ordinal expression expected';
 OrdinalExpectedFOR: Result := 'Ordinal expression expected as ''FOR'' loop counter value';

  IncompatibleTypes: begin
                      Result := 'Incompatible types: got "';

		      if SrcType < 0 then Result := Result + '^';

		      Result := Result + InfoAboutToken(abs(SrcType)) + '" expected "';

		      if DstType < 0 then Result := Result + '^';

		      Result := Result + InfoAboutToken(abs(DstType)) + '"';
		     end;

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

       			Result := Result + 'expected ';

			if Ident[abs(SrcType)].NumAllocElements_ > 0 then
			 Result := Result + '"Array[0..' + IntToStr(Ident[abs(SrcType)].NumAllocElements-1)+'] Of Array[0..'+IntToStr(Ident[abs(SrcType)].NumAllocElements_-1)+'] Of '+InfoAboutToken(Ident[IdentIndex].AllocElementType)+'"'
       			else
			 if Ident[abs(SrcType)].AllocElementType in [RECORDTOK, OBJECTTOK] then
			  Result := Result + '"^'+Types[Ident[abs(SrcType)].NumAllocElements].Field[0].Name+'"'
			 else begin

			  if Ident[abs(SrcType)].DataType in [RECORDTOK, OBJECTTOK] then
			   Result := Result +  '"'+Types[Ident[abs(SrcType)].NumAllocElements].Field[0].Name+'"'
			  else
			   Result := Result + '"Array[0..' + IntToStr(Ident[abs(SrcType)].NumAllocElements-1)+'] Of '+InfoAboutToken(Ident[abs(SrcType)].AllocElementType)+'"';

			 end;

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
    UnreachableCode: Result := 'unreachable code';
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

 //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

 WritelnMsg;

 Msg:=ErrorMessage(ErrTokenIndex, err, IdentIndex, SrcType, DstType);

 if ErrTokenIndex > NumTok then ErrTokenIndex := NumTok;

 TextColor(LIGHTRED);

 WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) + ',' + IntToStr(Succ(Tok[ErrTokenIndex - 1].Column)) + ')'  + ' Error: ' + Msg);

 NormVideo;

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

 //Tok[NumTok-1].Column := Tok[NumTok].Column + Tok[NumTok-1].Column;

 WritelnMsg;

 if ErrTokenIndex > NumTok then ErrTokenIndex := NumTok;

 TextColor(LIGHTRED);

 WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) + ',' + IntToStr(Succ(Tok[ErrTokenIndex - 1].Column)) + ')'  + ' Error: ' + Msg);

 NormVideo;

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
begin

 if Pass = CODEGENERATIONPASS then begin

  Msg:=ErrorMessage(WarnTokenIndex, err, IdentIndex, SrcType, DstType);

  a := UnitName[Tok[WarnTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[WarnTokenIndex].Line) + ')' + ' Warning: ' + Msg;

  for i := High(msgWarning)-1 downto 0 do
   if msgWarning[i] = a then exit;

  i := High(msgWarning);
  msgWarning[i] := a;
  SetLength(msgWarning, i+2);

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
  if pos('.', Ident[IdentIndex].Name) = 0 then begin

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

  PROCEDURETOK: a := a + 'proc';
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
 if (S = 'UINT16') then S := 'WORD' else
  if (S = 'LONGINT') then S := 'INTEGER';

for i := 1 to MAXTOKENNAMES do
  if S = Spelling[i] then
    begin
    Result := i;
    Break;
    end;
end;


function GetIdentResult(ProcAsBlock: integer): integer;
var IdentIndex: Integer;
begin

Result := 0;

  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Name = 'RESULT') and (Ident[IdentIndex].Block = ProcAsBlock) then exit(IdentIndex);

end;


procedure ResetOpty;
begin

 optyA := '';
 optyY := '';
 optyBP2 := '';

end;


procedure asm65(a: string = ''; comment : string =''); forward;


function GetLocalName(IdentIndex: integer; a: string =''): string;
begin

 if (Ident[IdentIndex].UnitIndex > 1) and (Ident[IdentIndex].UnitIndex <> UnitNameIndex) and Ident[IdentIndex].Section then
   Result := UnitName[Ident[IdentIndex].UnitIndex].Name + '.' + a + Ident[IdentIndex].Name
 else
   Result := a + Ident[IdentIndex].Name;

end;


function GetIdent(S: TString): Integer;
var TempIndex: integer;

  function UnitAllowedAccess(IdentIndex, Index: integer): Boolean;
  var i: integer;
  begin

   Result := false;

   if Ident[IdentIndex].Section then
    for i := 1 to MAXALLOWEDUNITS do
      if UnitName[Index].Allow[i] = UnitName[Ident[IdentIndex].UnitIndex].Name then exit(true);

  end;


  function Search(X: TString; UnitIndex: integer): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
    for IdentIndex := NumIdent downto 1 do
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
    for IdentIndex := NumIdent downto 1 do
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

//    writeln(S,' | ',copy(S, 1, pos('.', S)-1),',',TempIndex,'/',Result,' | ',Ident[TempIndex].Kind,',',UnitName[Ident[TempIndex].UnitIndex].Name);

  end;

end;


{
function GetRecordField(i: integer; field: string): Byte;
var j: integer;
begin

 Result:=0;

 for j:=1 to Types[i].NumFields do
  if Types[i].Field[j].Name = field then begin Result:=Types[i].Field[j].DataType; Break end;

 if Result = 0 then
  Error(0, 'Record field not found');

end;
}


function GetIdentProc(S: TString; ProcIdentIndex: integer; Param: TParamList; NumParams: integer): integer;
var IdentIndex, BlockStackIndex, i, k, b, df: Integer;
    hits, m: cardinal;
    yes: Boolean;
    best: array of record
		    IdentIndex, b: integer;
		    hit: cardinal;
		   end;

begin

Result := 0;

SetLength(best, 1);

for BlockStackIndex := BlockStackTop downto 0 do	// search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := NumIdent downto 1 do
    if
//       (Ident[IdentIndex].Kind = Ident[ProcIdentIndex].Kind {in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]}) and
       (Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and
       (Ident[IdentIndex].UnitIndex = Ident[ProcIdentIndex].UnitIndex) and
       (S = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) and
       (Ident[IdentIndex].NumParams = NumParams) then
      begin

      hits := 0;

{
if Ident[IdentIndex].Name = 'TTX' then begin

write(pass,' > ');
      for i := 1 to NumParams do
	   write (Param[i].DataType,',');

 writeln;
end;
}


      for i := 1 to NumParams do
       if (
	  ( ((Ident[IdentIndex].Param[i].DataType in UnsignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and
	  (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

	  ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in SignedOrdinalTypes) ) and
	  (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

	  ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and	// smallint > byte
	  (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

	  ( (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) {and (Ident[IdentIndex].Param[i].AllocElementType = Param[i].AllocElementType)} ) ) or

	  //( (Ident[IdentIndex].Param[i].AllocElementType = PROCVARTOK) and (Ident[IdentIndex].Param[i].NumAllocElements shr 16 = Param[i].NumAllocElements shr 16) ) or

	  ( (Param[i].DataType in Pointers) and (Ident[IdentIndex].Param[i].DataType = Param[i].AllocElementType) ) or		// dla parametru VAR

          ( (Ident[IdentIndex].Param[i].DataType = UNTYPETOK) and (Ident[IdentIndex].Param[i].PassMethod = VARPASSING) ) //or

//	  ( (Ident[IdentIndex].Param[i].DataType = UNTYPETOK) and (Ident[IdentIndex].Param[i].PassMethod = VARPASSING) and (Param[i].DataType in OrdinalTypes {+ [POINTERTOK]} {IntegerTypes + [CHARTOK]}) )

	 then begin


	   if (Ident[IdentIndex].Param[i].AllocElementType = PROCVARTOK) then begin

//writeln(Ident[IdentIndex].Name,',', Ident[GetIdent('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams,',',Param[i].AllocElementType,' | ', Ident[IdentIndex].Param[i].DataType,',', Param[i].AllocElementType,',',Ident[GetIdent('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))].NumParams);

	      case Param[i].AllocElementType of

		PROCEDURETOK, FUNCTIONTOK :
		yes := Ident[GetIdent('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams = Ident[GetIdent(Param[i].Name)].NumParams;

		PROCVARTOK :
		yes := (Ident[GetIdent('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams) = (Ident[GetIdent('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))].NumParams);

	      else

	       yes := false

	      end;

	      if yes then inc(hits);

	   end else inc(hits);

{
writeln('_C: ', Ident[IdentIndex].Name);

	   writeln (Ident[IdentIndex].Name,',',IdentIndex);
	   writeln (Ident[IdentIndex].Param[i].DataType,',', Param[i].DataType);
	   writeln (Ident[IdentIndex].Param[i].AllocElementType ,',', Param[i].AllocElementType);
	   writeln (Ident[IdentIndex].Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}

	   if (Ident[IdentIndex].Param[i].DataType = UNTYPETOK) and (Param[i].DataType = POINTERTOK) and
	      (Ident[IdentIndex].Param[i].AllocElementType = UNTYPETOK) and (Param[i].AllocElementType <> UNTYPETOK) and (Param[i].NumAllocElements > 0) {and (Ident[IdentIndex].Param[i].NumAllocElements = Param[i].NumAllocElements)} then
	    begin
{
writeln('_A: ', Ident[IdentIndex].Name);

	   writeln (Ident[IdentIndex].Name,',',IdentIndex);
	   writeln (Ident[IdentIndex].Param[i].DataType,',', Param[i].DataType);
	   writeln (Ident[IdentIndex].Param[i].AllocElementType ,',', Param[i].AllocElementType);
	   writeln (Ident[IdentIndex].Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
	       inc(hits);

            end;


          if (Ident[IdentIndex].Param[i].DataType in IntegerTypes) and (Param[i].DataType in IntegerTypes) then begin

	    if Ident[IdentIndex].Param[i].DataType in UnsignedOrdinalTypes then begin

	     b := DataSize[Ident[IdentIndex].Param[i].DataType];	// required parameter type
	     k := DataSize[Param[i].DataType];				// type of parameter passed

//	     writeln('+ ',Ident[IdentIndex].Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',Ident[IdentIndex].Param[i].DataType);

	     if b >= k then begin
	      df := 4 - abs(b-k);
	      if Param[i].DataType in UnsignedOrdinalTypes then inc(df, 2);	// +2pts
	      while df > 0 do begin inc(hits); dec(df) end;
	     end;


	    end else begin						// signed

	     b := DataSize[Ident[IdentIndex].Param[i].DataType];	// required parameter type
	     k := DataSize[Param[i].DataType];				// type of parameter passed

	     if Param[i].DataType in [BYTETOK, WORDTOK] then inc(k);	// -> signed

//	     writeln('- ',Ident[IdentIndex].Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',Ident[IdentIndex].Param[i].DataType);

	     if b >= k then begin
	      df := 4 - abs(b-k);
	      if Param[i].DataType in SignedOrdinalTypes then inc(df, 2);	// +2pts if the same types
	      while df > 0 do begin inc(hits); dec(df) end;
	     end;

	    end;

	  end;


	   if (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) and
	      (Ident[IdentIndex].Param[i].AllocElementType <> UNTYPETOK) and
	      ((Ident[IdentIndex].Param[i].AllocElementType = Param[i].AllocElementType)) then

	    begin
{
writeln('_D: ', Ident[IdentIndex].Name);

	   writeln (Ident[IdentIndex].Name,',',IdentIndex, ' - ',Ident[IdentIndex].NumParams,',', NumParams);
	   writeln (Ident[IdentIndex].Param[i].DataType,',', Param[i].DataType);
	   writeln (Ident[IdentIndex].Param[i].AllocElementType ,',', Param[i].AllocElementType);
	   writeln (Ident[IdentIndex].Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
	       inc(hits);

	    end;


	   if (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) and
	      (
		(Ident[IdentIndex].Param[i].AllocElementType = Param[i].AllocElementType)  or

	        ((Ident[IdentIndex].Param[i].AllocElementType = UNTYPETOK) and (Param[i].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].Param[i].NumAllocElements = Param[i].NumAllocElements)) or
	        ((Ident[IdentIndex].Param[i].AllocElementType <> UNTYPETOK) and (Param[i].AllocElementType = UNTYPETOK) and (Ident[IdentIndex].Param[i].NumAllocElements = Param[i].NumAllocElements))

	      ) then
	    begin
{
writeln('_B: ', Ident[IdentIndex].Name);

	   writeln (Ident[IdentIndex].Name,',',IdentIndex, ' - ',Ident[IdentIndex].NumParams,',', NumParams);
	   writeln (Ident[IdentIndex].Param[i].DataType,',', Param[i].DataType);
	   writeln (Ident[IdentIndex].Param[i].AllocElementType ,',', Param[i].AllocElementType);
	   writeln (Ident[IdentIndex].Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
	       inc(hits);

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
 else begin

  if NumParams = 0 then begin

   for i := 0 to High(best) - 1 do
    if {(best[i].hit > m) and} (best[i].b >= b) then begin b := best[i].b; Result := best[i].IdentIndex end;

  end else

   for i := 0 to High(best) - 1 do
    if (best[i].hit > m) and (best[i].b >= b) then begin m := best[i].hit; b := best[i].b; Result := best[i].IdentIndex end;

 end;

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
  for IdentIndex := NumIdent downto 1 do
    if (Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and
       (S = Ident[IdentIndex].Name) and
       (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
    begin

     for k := 0 to High(l)-1 do
      if (Ident[IdentIndex].NumParams = l[k].NumParams) and (Ident[IdentIndex].UnitIndex = l[k].u) and (Ident[IdentIndex].Block = l[k].b)  then begin

       ok := true;

       for m := 1 to l[k].NumParams do begin
	if (Ident[IdentIndex].Param[m].DataType <> l[k].Param[m].DataType) or (Ident[IdentIndex].Param[m].AllocElementType <> l[k].Param[m].AllocElementType) then begin ok := false; Break end;


        if (Ident[IdentIndex].Param[m].DataType = l[k].Param[m].DataType) and (Ident[IdentIndex].Param[m].AllocElementType = PROCVARTOK) and
	(l[k].Param[m].AllocElementType = PROCVARTOK) and
	(Ident[IdentIndex].Param[m].NumAllocElements shr 16 <> l[k].Param[m].NumAllocElements shr 16) then begin

	//writeln('>',Ident[IdentIndex].NumParams);//,',', l[k].Param[m].NumParams );

	 ok := false; Break

	end;


       end;

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
(*  pobierz ciag zaczynajaca sie znakami '0'..'9','%','$'		      *)
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
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_'		      *)
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
(*  pobiera ciag znakow, ograniczony znakami '' lub ""			      *)
(*  podwojny '' oznacza literalne '					      *)
(*  podwojny "" oznacza literalne "					      *)
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


function FindFile(Name: string; ftyp: TString): string; overload;
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

  until (i > High(UnitPath)) or FileExists( Result );

  if not FileExists( Result ) then
   if ftyp = 'unit' then
    Error(NumTok, 'Can''t find unit '+ChangeFileExt(Name,'')+' used by '+PROGRAM_NAME)
   else
    Error(NumTok, 'Can''t open '+ftyp+' file '''+Result+'''');

end;


function FindFile(Name: string): Boolean; overload;
var i: integer;
    fnm: string;
begin

  NormalizePath(Name);

  i:=0;

  repeat

   fnm :=  Name;

   if not FileExists( fnm ) then begin
    fnm := UnitPath[i] + Name;

     if not FileExists( fnm ) and (i > 0) then begin
      fnm := FilePath + UnitPath[i] + Name;
     end;

   end;

   inc(i);

  until (i > High(UnitPath)) or FileExists( fnm );

  Result := FileExists( fnm );

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
     res.resFile := get_string(i, s, false);	// nie zmieniaj wielkosci liter

    if (AnsiUpperCase(res.resType) = 'RCDATA') or
       (AnsiUpperCase(res.resType) = 'RCASM') or
       (AnsiUpperCase(res.resType) = 'DOSFILE') or
       (AnsiUpperCase(res.resType) = 'RELOC') or
       (AnsiUpperCase(res.resType) = 'RMT') or
       (AnsiUpperCase(res.resType) = 'MPT') or
       (AnsiUpperCase(res.resType) = 'CMC') or
       (AnsiUpperCase(res.resType) = 'RMTPLAY') or
       (AnsiUpperCase(res.resType) = 'MPTPLAY') or
       (AnsiUpperCase(res.resType) = 'CMCPLAY') or
       (AnsiUpperCase(res.resType) = 'EXTMEM') or
       (AnsiUpperCase(res.resType) = 'XBMP') or
       (AnsiUpperCase(res.resType) = 'SAPR') or
       (AnsiUpperCase(res.resType) = 'SAPRPLAY')
      then

      else
        Error(NumTok, 'Undefined resource type: Type = UNKNOWN, Name = '''+res.resName+'''');


     if (res.resFile <> '') and not(FindFile(res.resFile)) then
       Error(NumTok, 'Resource file not found: Type = '+res.resType+', Name = '''+res.resName+'''');


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
       Error(NumTok, 'Duplicate resource: Type = '+res.resType+', Name = '''+res.resName+'''');

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

 if (Ident[IdentIndex].DataType = ENUMTYPE) then
  Result := 0
 else

   if (Ident[IdentIndex].NumAllocElements_ = 0) or (Ident[IdentIndex].AllocElementType in [PROCVARTOK, RECORDTOK, OBJECTTOK]) then
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

if (i > 0) and (not (Ident[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK])) and (Ident[i].Block = BlockStack[BlockStackTop]) and (Ident[i].isOverload = false) and (Ident[i].UnitIndex = UnitNameIndex) then
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
   NumAllocElements  := NumAllocElements and $FFFF;		// [xx,

  if Name <> 'RESULT' then
   if (NumIdent > NumPredefIdent + 1) and (UnitNameIndex = 1) and (Pass = CODEGENERATIONPASS) then
     if not ( (Ident[NumIdent].Pass in [CALLDETERMPASS , CODEGENERATIONPASS]) or (Ident[NumIdent].IsNotDead) ) then
      Note(ErrTokenIndex, NumIdent);

  case Kind of

    PROCEDURETOK, FUNCTIONTOK, UNITTYPE, CONSTRUCTORTOK, DESTRUCTORTOK:
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

       if DataType in [ENUMTYPE] then
        inc(VarDataSize)
       else
       if (DataType in [RECORDTOK, OBJECTTOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 0
       else
       if (DataType in [FILETOK, TEXTFILETOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 12
       else
	VarDataSize := VarDataSize + integer(Elements(NumIdent) * DataSize[AllocElementType]);

       if NumAllocElements > 0 then dec(VarDataSize, DataSize[DataType]);

      end;

      end;

    CONSTANT, ENUMTYPE:
      begin
      Ident[NumIdent].Value := Data;				// Constant value

      if DataType in Pointers + [ENUMTOK] then begin
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



procedure DefineStaticString(StrTokenIndex: Integer; StrValue: String);
var
  i, j, k, len: Integer;
  yes: Boolean;
begin

Fillchar(Data, sizeof(Data), 0);

len:=Length(StrValue);

if len > 255 then
 Data[0]:=255
else
 Data[0]:=len;

for i:=1 to len do Data[i] := ord(StrValue[i]);

i:=0;
j:=0;
yes:=false;

while (i < NumStaticStrChars) and (yes=false) do begin

 j:=0;
 k:=i;
 while (Data[j] = StaticStringData[k+j]) and (j < len+2) and (k+j < NumStaticStrChars) do inc(j);

 if j = len+2 then begin yes:=true; Break end;

 inc(i);
end;

Tok[StrTokenIndex].StrLength := len;

if yes then begin
 Tok[StrTokenIndex].StrAddress := CODEORIGIN + i;
 exit;
end;

Tok[StrTokenIndex].StrAddress := CODEORIGIN + NumStaticStrChars;

StaticStringData[NumStaticStrChars] := Data[0];//length(StrValue);
Inc(NumStaticStrChars);

for i := 1 to len do
  begin
  StaticStringData[NumStaticStrChars] := ord(StrValue[i]);
  Inc(NumStaticStrChars);
  end;

StaticStringData[NumStaticStrChars] := 0;
Inc(NumStaticStrChars);

end;


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


function GetCommonConstType(ErrTokenIndex: Integer; DstType, SrcType: Byte; err: Boolean = true): Boolean;
begin

  Result := false;

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

 AsmBlock[AsmBlockIndex] := AsmBlock[AsmBlockIndex] + a;

end;


function GetVAL(a: string): integer;
var err: integer;
begin

 Result := -1;

 if a <> '' then
  if a[1] = '#' then begin
   val(copy(a, 2, length(a)), Result, err);

   if err > 0 then Result := -1;

  end;

end;


procedure OptimizeTemporaryBuf;
var p, k , q: integer;
    tmp: string;
    yes: Boolean;


  function SKIP(i: integer): Boolean;
  begin

      Result :=	(TemporaryBuf[i] = #9'seq') or (TemporaryBuf[i] = #9'sne') or
		(TemporaryBuf[i] = #9'spl') or (TemporaryBuf[i] = #9'smi') or
		(TemporaryBuf[i] = #9'scc') or (TemporaryBuf[i] = #9'scs') or
		(TemporaryBuf[i] = #9'svc') or (TemporaryBuf[i] = #9'svs') or

		(pos('jne ', TemporaryBuf[i]) > 0) or (pos('jeq ', TemporaryBuf[i]) > 0) or
		(pos('jcc ', TemporaryBuf[i]) > 0) or (pos('jcs ', TemporaryBuf[i]) > 0) or
		(pos('jmi ', TemporaryBuf[i]) > 0) or (pos('jpl ', TemporaryBuf[i]) > 0) or

		(pos('bne ', TemporaryBuf[i]) > 0) or (pos('beq ', TemporaryBuf[i]) > 0) or
		(pos('bcc ', TemporaryBuf[i]) > 0) or (pos('bcs ', TemporaryBuf[i]) > 0) or
		(pos('bmi ', TemporaryBuf[i]) > 0) or (pos('bpl ', TemporaryBuf[i]) > 0);
  end;


  function IFDEF_MUL8(i: integer): Boolean;
  begin
      Result :=	//(TemporaryBuf[i+4] = #9'eif') and
      		//(TemporaryBuf[i+3] = #9'imulCL') and
      		//(TemporaryBuf[i+2] = #9'els') and
		(TemporaryBuf[i+1] = #9'fmulu_8') and
		(TemporaryBuf[i]   = #9'.ifdef fmulinit');
  end;


  function IFDEF_MUL16(i: integer): Boolean;
  begin
      Result :=	//(TemporaryBuf[i+4] = #9'eif') and
      		//(TemporaryBuf[i+3] = #9'imulCX') and
      		//(TemporaryBuf[i+2] = #9'els') and
		(TemporaryBuf[i+1] = #9'fmulu_16') and
		(TemporaryBuf[i]   = #9'.ifdef fmulinit');
  end;


  function fortmp(a: string): string;
  // @FORTMP_xxxx
  // @FORTMP_xxxx+1
  begin

    Result:=a;

//    Result[8] := '?';

    if length(Result) > 12 then
      Result[13] := '_'
    else
      Result := Result + '_0';

  end;


  function GetBYTE(i: integer): integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4));
  end;

  function GetWORD(i, j: integer): integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4)) + GetVAL(copy(TemporaryBuf[j], 6, 4)) * 256;
  end;


  function GetSTRING(j: integer): string;
  var i: integer;
       a: string;
  begin

    Result := '';
    i:=6;

    a:=TemporaryBuf[j];

    if a<>'' then
     while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
      Result := Result + a[i];
      inc(i);
     end;

  end;


begin

{
if (pos('sub #$01', TemporaryBuf[0]) > 0) then begin

      for p:=0 to 11 do writeln(TemporaryBuf[p]);
      writeln('-------');

end;
}


{$i include/opt_TEMP.inc}

{$i include/opt_TEMP_IFTMP.inc}

{$i include/opt_TEMP_IMUL_CX.inc}

{$i include/opt_TEMP_WHILE.inc}

{$i include/opt_TEMP_FOR.inc}

{$i include/opt_TEMP_FORDEC.inc}

{$i include/opt_TEMP_ORD.inc}

{$i include/opt_TEMP_X.inc}

{$i include/opt_TEMP_EAX.inc}

{$i include/opt_TEMP_JMP.inc}


    if (TemporaryBuf[0] = #9'jsr #$00') and						// jsr #$00				; 0
       (TemporaryBuf[1] = #9'lda @BYTE.MOD.RESULT') then				// lda @BYTE.MOD.RESULT			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;

    if (TemporaryBuf[0] = #9'jsr #$00') and						// jsr #$00				; 0
       (TemporaryBuf[1] = #9'ldy @BYTE.MOD.RESULT') then				// lda @BYTE.MOD.RESULT			; 1
       begin
	TemporaryBuf[0] := #9'tay';
	TemporaryBuf[1] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :STACKORIGIN,x') and					// lda :STACKORIGIN,x			; 0
       (pos('sta ', TemporaryBuf[1]) > 0) and						// sta F				; 1
       (TemporaryBuf[2] = #9'lda :STACKORIGIN+STACKWIDTH,x') and			// lda :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('sta ', TemporaryBuf[3]) > 0) and						// sta F+1				; 3
       (TemporaryBuf[4] = #9'dex') and							// dex					; 2
       (TemporaryBuf[5] = ':move') then							//:move					; 3
       begin
	TemporaryBuf[1] := #9'sta :bp2';
	TemporaryBuf[3] := #9'sta :bp2+1';

	tmp:=TemporaryBuf[6];
	p:=StrToInt(TemporaryBuf[7]);

	if p = 256 then begin
     	 TemporaryBuf[4] := #9'ldy #$00';
     	 TemporaryBuf[5] := #9'mva:rne (:bp2),y adr.'+tmp+',y+';
    	end else
    	if p <= 128 then begin
     	 TemporaryBuf[4] := #9'ldy #$'+IntToHex(p-1, 2);
     	 TemporaryBuf[5] := #9'mva:rpl (:bp2),y adr.'+tmp+',y-';
    	end else begin
     	 TemporaryBuf[4] := #9'@move '+tmp+' #adr.'+tmp+' #$'+IntToHex(p,2);
     	 TemporaryBuf[5] := '~';
	end;

     	TemporaryBuf[6] := #9'mwa #adr.'+tmp+' '+tmp;
     	TemporaryBuf[7] := #9'dex';
       end;

// -----------------------------------------------------------------------------

{$i include/opt_TEMP_MOVE.inc}

{$i include/opt_TEMP_FILL.inc}


// #asm

   if TemporaryBuf[0] = '#asm' then begin

    writeln(OutFile, AsmBlock[StrToInt(TemporaryBuf[1])]);

    TemporaryBuf[0] := '~';
    TemporaryBuf[1] := '~';

   end;


// @PARAM?

   if TemporaryBuf[0] = #9'sta @PARAM?' then TemporaryBuf[0] := '~';

   if TemporaryBuf[0] = #9'sty @PARAM?' then TemporaryBuf[0] := #9'tya';


// @FORTMP?

   if (pos('@FORTMP_', TemporaryBuf[0]) > 1) then

    if (pos('lda ', TemporaryBuf[0]) > 0) then
     TemporaryBuf[0] := #9'lda ' +  fortmp(GetSTRING(0)) + '::#$00'
    else
    if (pos('cmp ', TemporaryBuf[0]) > 0) then
     TemporaryBuf[0] := #9'cmp ' + fortmp(GetSTRING(0)) + '::#$00'
    else
    if (pos('sub ', TemporaryBuf[0]) > 0) then
     TemporaryBuf[0] := #9'sub ' + fortmp(GetSTRING(0)) + '::#$00'
    else
    if (pos('sbc ', TemporaryBuf[0]) > 0) then
     TemporaryBuf[0] := #9'sbc ' + fortmp(GetSTRING(0)) + '::#$00'
    else
    if (pos('sta ', TemporaryBuf[0]) > 0) then
      TemporaryBuf[0] := #9'sta ' + fortmp(GetSTRING(0))
    else
    if (pos('sty ', TemporaryBuf[0]) > 0) then
      TemporaryBuf[0] := #9'sty ' + fortmp(GetSTRING(0))
    else
    if (pos('mva ', TemporaryBuf[0]) > 0) and (pos('mva @FORTMP_', TemporaryBuf[0]) = 0) then begin
     tmp:=copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);
     TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + fortmp(tmp);
    end else
     writeln('Unassigned: ' + TemporaryBuf[0] );

   //  tmp:=copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);
  //   TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + ':' + fortmp(tmp);

end;


procedure WriteOut(a: string);
var i: integer;
begin

 if (pos(#9'jsr ', a) = 1) or (a = '#asm') then ResetOpty;


 if iOut < High(TemporaryBuf) then begin
  inc(iOut);
  TemporaryBuf[iOut] := a;
 end else begin

  OptimizeTemporaryBuf;

  if TemporaryBuf[iOut] = '; --- ForToDoCondition' then
   if (a = '') or (pos('; optimize OK', a) > 0) then exit;

  if TemporaryBuf[0] <> '~' then begin
   if (TemporaryBuf[0] <> '') or (outTmp <> TemporaryBuf[0]) then writeln(OutFile, TemporaryBuf[0]);

   outTmp := TemporaryBuf[0];
  end;

  for i:=1 to iOut do TemporaryBuf[i-1] := TemporaryBuf[i];

  TemporaryBuf[iOut] := a;

 end;

end;


procedure OptimizeASM;
(* -------------------------------------------------------------------------- *)
(* optymalizacja powiodla sie jesli na wyjsciu X=0
(* peephole optimization
(* -------------------------------------------------------------------------- *)
type
    TListing = array [0..511] of string;

var i, l, k, m, x: integer;
    a, t, {arg,} arg0, arg1: string;
    inxUse, found: Boolean;
    t0, t1, t2, t3: string;
    listing, listing_tmp: TListing;
    s: array [0..15, 0..3] of string;

// -----------------------------------------------------------------------------


   function GetBYTE(i: integer): integer;
   begin
    Result := GetVAL(copy(listing[i], 6, 4));
   end;

   function GetWORD(i,j: integer): integer;
   begin
    Result := GetVAL(copy(listing[i], 6, 4)) + GetVAL(copy(listing[j], 6, 4)) shl 8;
   end;


   function TAY(i: integer): Boolean;
   begin
     Result := listing[i] = #9'tay'
   end;

   function TYA(i: integer): Boolean;
   begin
     Result := listing[i] = #9'tya'
   end;

   function INY(i: integer): Boolean;
   begin
     Result := listing[i] = #9'iny'
   end;

   function DEY(i: integer): Boolean;
   begin
     Result := listing[i] = #9'dey'
   end;

   function INX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inx'
   end;

   function DEX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'dex'
   end;

   function AND_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'and (:bp),y'
   end;

   function ORA_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ora (:bp),y'
   end;

   function EOR_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'eor (:bp),y'
   end;

   function LDA_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda (:bp),y'
   end;

   function CMP_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'cmp (:bp),y'
   end;

   function STA_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta (:bp),y'
   end;

   function STA_BP(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp'
   end;

   function INC_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inc :bp+1'
   end;

   function STA_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp+1'
   end;

   function STY_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sty :bp+1'
   end;

   function LDA_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda (:bp2),y'
   end;

   function LDA_BP2(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :bp2'
   end;

   function LDA_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :bp2+1'
   end;

   function STA_BP2(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp2'
   end;

   function STA_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp2+1'
   end;

   function INC_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inc :bp2+1'
   end;

   function STA_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta (:bp2),y'
   end;

   function ADD_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add (:bp),y'
   end;

   function SUB_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub (:bp),y'
   end;

   function ADD_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add (:bp2),y'
   end;

   function ADC_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc (:bp2),y'
   end;

   function LDA_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda #$00'
   end;

   function ADD_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add #$00'
   end;

   function SUB_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub #$00'
   end;

   function ADC_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc #$00'
   end;

   function CMP_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'cmp #$00'
   end;

   function SBC_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc #$00'
   end;

   function ADC_SBC_IM_0(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'adc #$00') or (listing[i] = #9'sbc #$00')
   end;

   function LDY_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ldy #$00'
   end;

   function AND_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'and #$00'
   end;

   function ORA_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ora #$00'
   end;

   function EOR_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'eor #$00'
   end;

   function ROR_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ror @'
   end;

   function ROL_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'rol @'
   end;

   function LSR_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lsr @'
   end;

   function ASL_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'asl @'
   end;

   function LDY_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ldy #1'
   end;

   function ROL_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'rol :eax+1'
   end;

   function LDA_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :eax'
   end;

   function LDA_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :eax+1'
   end;

   function STA_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :eax'
   end;

   function STA_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :eax+1'
   end;

   function ADD_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add :eax'
   end;

   function ADD_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add :eax+1'
   end;

   function ADC_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc :eax'
   end;

   function ADC_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc :eax+1'
   end;

   function SUB_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub :eax'
   end;

   function SUB_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub :eax+1'
   end;

   function SBC_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc :eax'
   end;

   function SBC_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc :eax+1'
   end;


   function STA_im_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta #$00'
   end;

   function STY_im_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sty #$00'
   end;

   function LAB_a(i: integer): Boolean;
   begin
     Result := listing[i] = '@'
   end;


   function IX(i: integer): Boolean;
   begin
    Result := pos(',x', listing[i]) > 0;
   end;

   function IY(i: integer): Boolean;
   begin
    Result := pos(',y', listing[i]) > 0;
   end;


   function CMP_IM(i: integer): Boolean;
   begin
     Result := pos(#9'cmp #', listing[i]) = 1;
   end;

   function LDY_IM(i: integer): Boolean;
   begin
     Result := pos(#9'ldy #', listing[i]) = 1;
   end;

   function LDY(i: integer): Boolean;
   begin
     Result := pos(#9'ldy ', listing[i]) = 1;
   end;

   function LDY_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'ldy :STACK', listing[i]) = 1;
   end;

   function STY(i: integer): Boolean;
   begin
     Result := (pos(#9'sty ', listing[i]) = 1) and (pos(#9'sty #$00', listing[i]) = 0);
   end;

   function STY_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'sty :STACK', listing[i]) = 1;
   end;

   function ROR(i: integer): Boolean;
   begin
     Result := pos(#9'ror ', listing[i]) = 1;
   end;

   function ROR_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'ror :STACK', listing[i]) = 1;
   end;

   function LSR(i: integer): Boolean;
   begin
     Result := pos(#9'lsr ', listing[i]) = 1;
   end;

   function LSR_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'lsr :STACK', listing[i]) = 1;
   end;

   function ROL(i: integer): Boolean;
   begin
     Result := pos(#9'rol ', listing[i]) = 1;
   end;

   function ROL_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'rol :STACK', listing[i]) = 1;
   end;

   function ASL(i: integer): Boolean;
   begin
     Result := pos(#9'asl ', listing[i]) = 1;
   end;

   function ASL_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'asl :STACK', listing[i]) = 1;
   end;

   function CMP(i: integer): Boolean;
   begin
     Result := pos(#9'cmp ', listing[i]) = 1;
   end;

   function CMP_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'cmp :STACK', listing[i]) = 1;
   end;

   function MWA(i: integer): Boolean;
   begin
     Result := pos(#9'mwa ', listing[i]) = 1;
   end;

   function MWY(i: integer): Boolean;
   begin
     Result := pos(#9'mwy ', listing[i]) = 1;
   end;

   function MVY(i: integer): Boolean;
   begin
     Result := pos(#9'mvy ', listing[i]) = 1;
   end;

   function MVY_IM(i: integer): Boolean;
   begin
     Result := pos(#9'mvy #', listing[i]) = 1;
   end;

   function MVA(i: integer): Boolean;
   begin
     Result := pos(#9'mva ', listing[i]) = 1;
   end;

   function MVA_IM(i: integer): Boolean;
   begin
     Result := pos(#9'mva #', listing[i]) = 1;
   end;

   function MVA_IM_0(i: integer): Boolean;
   begin
     Result := pos(#9'mva #$00', listing[i]) = 1;
   end;

   function MVA_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'mva :STACK', listing[i]) = 1;
   end;

   function ORA(i: integer): Boolean;
   begin
     Result := pos(#9'ora ', listing[i]) = 1;
   end;

   function AND_IM(i: integer): Boolean;
   begin
     Result := pos(#9'and #', listing[i]) = 1;
   end;

   function LDA_IM(i: integer): Boolean;
   begin
     Result := pos(#9'lda #', listing[i]) = 1;
   end;

   function LDA_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'lda :STACK', listing[i]) = 1;
   end;

   function LDA_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'lda adr.', listing[i]) = 1) or ((pos(#9'lda ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function LDA(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1) and (pos(#9'lda adr.', listing[i]) = 0) and (pos('.adr.', listing[i]) = 0);
   end;

   function LDA_A(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1);
   end;

   function ADD_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'add adr.', listing[i]) = 1) or ((pos(#9'add ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function SUB_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sub adr.', listing[i]) = 1) or ((pos(#9'sub ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function ADC_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'adc adr.', listing[i]) = 1) or ((pos(#9'adc ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function SBC_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc adr.', listing[i]) = 1) or ((pos(#9'sbc ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function STA_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sta adr.', listing[i]) = 1) or ((pos(#9'sta ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function STA(i: integer): Boolean;
   begin
     Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta adr.', listing[i]) = 0) and (pos('.adr.', listing[i]) = 0) and (pos(#9'sta #$00', listing[i]) = 0);
   end;

   function STA_A(i: integer): Boolean;
   begin
     Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta #$00', listing[i]) = 0);
   end;

   function STA_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'sta :STACK', listing[i]) = 1;
   end;

   function INC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'inc :STACK', listing[i]) = 1);
   end;

   function DEC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'dec :STACK', listing[i]) = 1);
   end;

   function INC_(i: integer): Boolean;
   begin
     Result := (pos(#9'inc ', listing[i]) = 1);
   end;

   function DEC_(i: integer): Boolean;
   begin
     Result := (pos(#9'dec ', listing[i]) = 1);
   end;


   function ADD(i: integer): Boolean;
   begin
     Result := (pos(#9'add ', listing[i]) = 1);
   end;

   function ADD_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'add #', listing[i]) = 1);
   end;

   function ADC(i: integer): Boolean;
   begin
     Result := (pos(#9'adc ', listing[i]) = 1);
   end;

   function ADC_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'adc #', listing[i]) = 1);
   end;

   function ADD_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'add :STACK', listing[i]) = 1);
   end;

   function ADC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'adc :STACK', listing[i]) = 1);
   end;

   function ADD_SUB_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'add :STACK', listing[i]) = 1) or (pos(#9'sub :STACK', listing[i]) = 1);
   end;

   function ADC_SBC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'adc :STACK', listing[i]) = 1) or (pos(#9'sbc :STACK', listing[i]) = 1);
   end;

   function SUB(i: integer): Boolean;
   begin
     Result := (pos(#9'sub ', listing[i]) = 1);
   end;

   function SUB_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'sub #', listing[i]) = 1);
   end;

   function SBC(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc ', listing[i]) = 1);
   end;

   function SBC_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc #', listing[i]) = 1);
   end;

   function SUB_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'sub :STACK', listing[i]) = 1);
   end;

   function SBC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc :STACK', listing[i]) = 1);
   end;

   function ADC_SBC_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'adc #', listing[i]) = 1) or (pos(#9'sbc #', listing[i]) = 1);
   end;

   function ADD_SUB_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'add #', listing[i]) = 1) or (pos(#9'sub #', listing[i]) = 1);
   end;

   function ADD_SUB(i: integer): Boolean;
   begin
     Result := (pos(#9'add ', listing[i]) = 1) or (pos(#9'sub ', listing[i]) = 1);
   end;

   function ADD_SUB_VAL(i: integer): Boolean;
   begin
     Result := ((pos(#9'add ', listing[i]) = 1) and (pos(#9'add :STACK', listing[i]) = 0)) or
               ((pos(#9'sub ', listing[i]) = 1) and (pos(#9'sub :STACK', listing[i]) = 0));
   end;

   function ADC_SBC(i: integer): Boolean;
   begin
     Result := (pos(#9'adc ', listing[i]) = 1) or (pos(#9'sbc ', listing[i]) = 1);
   end;

   function ADC_SBC_VAL(i: integer): Boolean;
   begin
     Result := ((pos(#9'adc ', listing[i]) = 1) and (pos(#9'adc :STACK', listing[i]) = 0)) or
               ((pos(#9'sbc ', listing[i]) = 1) and (pos(#9'sbc :STACK', listing[i]) = 0));
   end;

   function AND_(i: integer): Boolean;
   begin
     Result := (pos(#9'and ', listing[i]) = 1);
   end;

   function AND_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'and :STACK', listing[i]) = 1);
   end;

   function ORA_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'ora :STACK', listing[i]) = 1);
   end;

   function EOR_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'eor :STACK', listing[i]) = 1);
   end;

   function AND_ORA_EOR_STACK(i: integer): Boolean;
   begin
     Result := and_stack(i) or ora_stack(i) or eor_stack(i);
   end;

   function AND_ORA_EOR_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'and #', listing[i]) = 1) or (pos(#9'ora #', listing[i]) = 1) or (pos(#9'eor #', listing[i]) = 1);
   end;

   function AND_ORA_EOR(i: integer): Boolean;
   begin
     Result := (pos(#9'and ', listing[i]) = 1) or (pos(#9'ora ', listing[i]) = 1) or (pos(#9'eor ', listing[i]) = 1);
   end;

   function MWY_BP2(i: integer): Boolean;
   begin
     Result := (pos(#9'mwy ', listing[i]) = 1) and (pos(' :bp2', listing[i]) > 0);
   end;


   function ADD_SUB_AL_CL(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'jsr addAL_CL') or (listing[i] = #9'jsr subAL_CL');
   end;

   function ADD_SUB_AX_CX(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'jsr addAX_CX') or (listing[i] = #9'jsr subAX_CX');
   end;

   function ADD_SUB_EAX_ECX(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'jsr addEAX_ECX') or (listing[i] = #9'jsr subEAX_ECX');
   end;


   function JSR(i: integer): Boolean;
   begin
     Result := (pos(#9'jsr ', listing[i]) = 1);
   end;


   function JEQ(i: integer): Boolean;
   begin
     Result := (pos(#9'jeq ', listing[i]) = 1);
   end;

   function JNE(i: integer): Boolean;
   begin
     Result := (pos(#9'jne ', listing[i]) = 1);
   end;

   function JPL(i: integer): Boolean;
   begin
     Result := (pos(#9'jpl ', listing[i]) = 1);
   end;

   function JMI(i: integer): Boolean;
   begin
     Result := (pos(#9'jmi ', listing[i]) = 1);
   end;

   function JCC(i: integer): Boolean;
   begin
     Result := (pos(#9'jcc ', listing[i]) = 1);
   end;

   function JCS(i: integer): Boolean;
   begin
     Result := (pos(#9'jcs ', listing[i]) = 1);
   end;


   function BEQ(i: integer): Boolean;
   begin
     Result := (pos(#9'beq ', listing[i]) = 1);
   end;

   function BNE(i: integer): Boolean;
   begin
     Result := (pos(#9'bne ', listing[i]) = 1);
   end;

   function BCC(i: integer): Boolean;
   begin
     Result := (pos(#9'bcc ', listing[i]) = 1);
   end;

   function BCS(i: integer): Boolean;
   begin
     Result := (pos(#9'bcs ', listing[i]) = 1);
   end;

   function BPL(i: integer): Boolean;
   begin
     Result := (pos(#9'bpl ', listing[i]) = 1);
   end;

   function BMI(i: integer): Boolean;
   begin
     Result := (pos(#9'bmi ', listing[i]) = 1);
   end;


   function BNE_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bne @+'
   end;

   function SEQ(i: integer): Boolean;
   begin
     Result := listing[i] = #9'seq'
   end;

   function SNE(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sne'
   end;

   function SPL(i: integer): Boolean;
   begin
     Result := listing[i] = #9'spl'
   end;

   function SMI(i: integer): Boolean;
   begin
     Result := listing[i] = #9'smi'
   end;

   function SCC(i: integer): Boolean;
   begin
     Result := listing[i] = #9'scc'
   end;

   function SCS(i: integer): Boolean;
   begin
     Result := listing[i] = #9'scs'
   end;


// !!! kolejny rozkaz po UNUSED_A na pozycji 'i+1' musi koniecznie byc conajmniej 'LDA ' !!!

   function UNUSED_A(i: integer): Boolean;
   begin
     Result := sty_stack(i) or lda_stack(i) or sta_stack(i) or {!!! (pos(#9'lda :eax', listing[i]) = 1) or (pos(#9'sta :eax', listing[i]) = 1) or} lda_im(i) or rol_stack(i) or ror_stack(i) or adc_sbc(i);
   end;


   function onBreak(i: integer): Boolean;
   begin
     Result := (listing[i] = '@') or (pos(#9'jsr ', listing[i]) = 1) or (listing[i] = #9'eif');		// !!! eif !!! koniecznie
   end;


   procedure WriteInstruction(i: integer);
   begin

     if isInterrupt and ( (pos(' :bp', listing[i]) > 0) or (pos(' :STACK', listing[i]) > 0) ) then begin
//       WritelnMsg;

       TextColor(LIGHTRED);

       WriteLn(UnitName[optimize.unitIndex].Path + ' (' + IntToStr(optimize.line) + ') Error: Illegal instruction in INTERRUPT block ''' + copy(listing[i], 2, 256) + '''');

       NormVideo;

//       FreeTokens;

//       CloseFile(OutFile);
//       Erase(OutFile);

//       Halt(2);
     end;

     WriteOut( listing[i] );

   end;


   function SKIP(i: integer): Boolean;
   begin

     if i < 0 then
      Result := False
     else
      Result :=	seq(i) or sne(i) or spl(i) or smi(i) or scc(i) or scs(i) or
		jeq(i) or jne(i) or jpl(i) or jmi(i) or jcc(i) or jcs(i) or
		beq(i) or bne(i) or bpl(i) or bmi(i) or bcc(i) or bcs(i);
   end;



   function LabelIsUsed(i: integer): Boolean;									// issue #91 fixed

(*

 +#$00Label
 -#$00Label

 *#$02Label
 *#$03Label
 *#$04Label
 *#$08Label

 *+$01Label|Label
 *-$01Label|Label

*)

     procedure LabelTest(const mne: string);
     begin

      case optyY[1] of

       '+','-' : Result := (listing[i] = mne + copy(optyY, 6, 256));

           '*' : if optyY[2] in ['+', '-'] then
	          Result := (listing[i] = mne + copy(optyY,6,pos('|',optyY) - 6)) or (listing[i] = mne + copy(optyY,pos('|',optyY) + 1,256))
		 else
	          Result := (listing[i] = mne + copy(optyY, 6, 256));

      else
       Result := (listing[i] = mne + optyY);
      end;

     end;


   begin

     Result:=false;

     if optyY <> '' then
      if (pos(#9'sta ', listing[i]) = 1) then LabelTest(#9'sta ') else
       if (pos(#9'inc ', listing[i]) = 1) then LabelTest(#9'inc ') else
        if (pos(#9'dec ', listing[i]) = 1) then LabelTest(#9'dec ');

   end;


   function EAX(i: integer): Boolean;
   begin
     Result := (pos(' :eax', listing[i]) > 0);
   end;


   function IFDEF_MUL8(i: integer): Boolean;
   begin
      Result :=	//(listing[i+4] = #9'eif') and
      		//(listing[i+3] = #9'imulCL') and
      		//(listing[i+2] = #9'els') and
		(listing[i+1] = #9'fmulu_8') and
		(listing[i]   = #9'.ifdef fmulinit');
   end;

   function IFDEF_MUL16(i: integer): Boolean;
   begin
      Result :=	//(listing[i+4] = #9'eif') and
		//(listing[i+3] = #9'imulCX') and
		//(listing[i+2] = #9'els') and
		(listing[i+1] = #9'fmulu_16') and
      		(listing[i]   = #9'.ifdef fmulinit');
   end;


   procedure LDA_STA_ADR(i, q: integer; op: char);
   begin

	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + op +'$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if (lda_adr(i+8) = false) and (sta_adr(i+9) = false) then exit;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if (lda_adr(i+10) = false) and (sta_adr(i+11) = false) then exit;

	if lda_adr(i+10) and iy(i+10) then begin
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+11) and iy(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if (lda_adr(i+12) = false) and (sta_adr(i+13) = false) then exit;

	if lda_adr(i+12) and iy(i+12) then begin
	 delete(listing[i+12], pos(',y', listing[i+12]), 2);
	 listing[i+12] := listing[i+12] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + op + '$' + IntToHex(q, 2) + ',y';
	end;

   end;

// -----------------------------------------------------------------------------

   procedure Rebuild;
   var k, i: integer;
   begin

    k:=0;
    for i := 0 to l - 1 do
     if (listing[i] <> '') and (listing[i][1] <> ';') then begin
      listing[k] := listing[i];
      inc(k);
     end;

    listing[k]   := '';
    listing[k+1] := '';
    listing[k+2] := '';

    l := k;
   end;


// -----------------------------------------------------------------------------


   function GetString(a: string): string; overload;
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



   function GetString(j: integer): string; overload;
   var i: integer;
       a: string;
   begin

    Result := '';
    i:=6;

    a:=listing[j];

    if a<>'' then
     while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
      Result := Result + a[i];
      inc(i);
     end;

   end;


   function GetStringLast(j: integer): string; overload;
   var i: integer;
       a: string;
   begin

    Result := '';

    a:=listing[j];

    if a<>'' then begin
     i:=length(a);

     while not(a[i] in [' ',#9]) and (i>0) do dec(i);

     Result:=copy(a, i+1, 256);
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

    if reset then s[x][n] := '';

   end;

  end;


  function RemoveUnusedSTACK: Boolean;
  var j: byte;
      i: integer;
      cnt_l,					// licznik odczytow stosu
      cnt_s: array [0..7+1, 0..3] of Boolean;	// licznik zapisow stosu


   procedure Clear;
   var i: byte;
   begin

    for i := 0 to 15 do begin
     s[i][0] := '';
     s[i][1] := '';
     s[i][2] := '';
     s[i][3] := '';
    end;

    fillchar(cnt_l, sizeof(cnt_l), false);
    fillchar(cnt_s, sizeof(cnt_s), false);

   end;


   function unrelated(i: integer): Boolean;	// unrelated stack references
   var j, k: byte;
   begin

     Result := false;

     for j := 0 to 7 do
      for k := 0 to 3 do
       if pos(GetARG(k, j, false), listing[i]) > 0 then exit( (cnt_s[j, k] and (cnt_l[j, k] = false)) or		// sa zapisy, brak odczytow
	                                                      ((cnt_s[j, k] = false) and cnt_l[j, k]) );		// brak zapisow, sa odczyty


    // wyjatek dla :STACKORIGIN+16 (cnt_s[8,k] ; cnt_l[8,k]) ktory mapuje :EAX

      for k := 0 to 3 do
       if pos(GetARG(k, 8, false), listing[i]) > 0 then 								// sa zapisy, brak odczytu
         exit( (cnt_s[8, 0] or cnt_s[8 ,1] or cnt_s[8, 2] or cnt_s[8, 3] = true ) and (cnt_l[8, 0] or cnt_l[8, 1] or cnt_l[8, 2] or cnt_l[8, 3] = false) );

{
;----	4x zapis :EAX, 1x odczyt :EAX

	lda SCORE
	sta :eax
	lda SCORE+1
	sta :eax+1
	lda SCORE+2
	sta :eax+2
	lda SCORE+3
	sta :eax+3
	lda #$0A
	sta :ecx
	lda #$00
	sta :ecx+1
	jsr idivEAX_CX
	ldy :STACKORIGIN+9
	lda :eax
	sta adr.TB,y


;----	 zapis i odczyt :EAX+1 (byte * 256)

	lda A
	sta :eax+1
	lda #$00
	sta A
	lda :eax+1
	sta A+1
}
   end;


  begin

  Result:=false;

 // szukamy pojedynczych odwolan do :STACKORIGIN+N

  Rebuild;

  Clear;

  // !!!!!!!!!!!!!!!!!!!!
  // czytamy listing szukajac zapisow :STACKORIGIN (STA, STY), kazde inne odwolanie do :STACKORIGIN traktujemy jako odczyt
  // jesli mamy tylko zapisy bez odczytow to kasujemy takie odwolanie
  // !!!!!!!!!!!!!!!!!!!!

  for i := 0 to l - 1 do 	       // zliczamy odwolania do :STACKORIGIN+N
   if (pos(' :STACK', listing[i]) > 0) then

     if sta_stack(i) or sty_stack(i) then begin

      for j := 0 to 7+1 do
       if pos(GetARG(0, j, false), listing[i]) > 0 then begin cnt_s[j, 0] := true; Break end else
        if pos(GetARG(1, j, false), listing[i]) > 0 then begin cnt_s[j, 1] := true; Break end else
         if pos(GetARG(2, j, false), listing[i]) > 0 then begin cnt_s[j, 2] := true; Break end else
          if pos(GetARG(3, j, false), listing[i]) > 0 then begin cnt_s[j, 3] := true; Break end;

     end else begin

      for j := 0 to 7+1 do
       if pos(GetARG(0, j, false), listing[i]) > 0 then begin cnt_l[j, 0] := true; Break end else
        if pos(GetARG(1, j, false), listing[i]) > 0 then begin cnt_l[j, 1] := true; Break end else
         if pos(GetARG(2, j, false), listing[i]) > 0 then begin cnt_l[j, 2] := true; Break end else
          if pos(GetARG(3, j, false), listing[i]) > 0 then begin cnt_l[j, 3] := true; Break end;

     end;


  for i := 0 to l - 1 do
   if (pos(' :STACK', listing[i]) > 0) then
    if unrelated(i) then begin
      a := listing[i];		// zamieniamy na potencjalne 'illegal instruction'
      k:=pos(' :STACK', a);
      delete(a, k, 256);
      insert(' #$00', a, k);

      listing[i] := a;

      Result := true;
    end;

  end;		// RemoveUnusedSTACK


 function PeepholeOptimization_STACK: Boolean;
 var i, p, q: integer;
     tmp: string;
     yes: Boolean;
 begin

  Result := true;

  tmp:='';

  for i := 0 to l - 1 do begin

   if jsr(i) or cmp(i) or SKIP(i) then Break;

   if mwy_bp2(i) then
    if tmp = listing[i] then
     listing[i] := ''
    else
     tmp := listing[i];

  end;

  Rebuild;


  for i := 0 to l - 1 do
   if listing[i] <> '' then begin


{
if (pos('mva FINDERX :STACKORIGIN,x', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


{$i include/opt_STACK.inc}

{$i include/opt_STACK_ADR.inc}

{$i include/opt_STACK_AL_CL.inc}

{$i include/opt_STACK_AX_CX.inc}

{$i include/opt_STACK_EAX_ECX.inc}

{$i include/opt_STACK_PRINT.inc}


  end;

 end;		// PeepholeOptimization_STACK


function OptimizeEAX: Boolean;
var i: integer;
    tmp: string;
begin

 Result := false;

 for i:=0 to l-1 do

    if (pos(' :eax', listing[i]) = 5) and (pos(#9'.if', listing[i+1]) = 0) then begin
      Result := true;

      tmp := copy(listing[i], 6, 256);

      if tmp = ':eax' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+16' else
       if tmp = ':eax+1' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+STACKWIDTH+16' else
        if tmp = ':eax+2' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+STACKWIDTH*2+16' else
         if tmp = ':eax+3' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+STACKWIDTH*3+16';

    end;

end;


procedure OptimizeEAX_OFF;
var i: integer;
    tmp: string;
begin

 for i:=0 to l-1 do

    if pos(' :STACKORIGIN+', listing[i]) = 5 then begin
      tmp := copy(listing[i], 6, 256);

      if tmp = ':STACKORIGIN+16' then listing[i] := copy(listing[i], 1, 5) + ':eax' else
       if tmp = ':STACKORIGIN+STACKWIDTH+16' then listing[i] := copy(listing[i], 1, 5) + ':eax+1' else
        if tmp = ':STACKORIGIN+STACKWIDTH*2+16' then listing[i] := copy(listing[i], 1, 5) + ':eax+2' else
         if tmp = ':STACKORIGIN+STACKWIDTH*3+16' then listing[i] := copy(listing[i], 1, 5) + ':eax+3';

    end;

end;


 procedure OptimizeAssignment;
 var k: integer;

(*
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

    while (pos('lda #', old) > 0) and sta_a(p+1) and lda_im(p+2) and (p < l-2) do begin	// lda #$28	; 0
											// sta		; 1
     if (copy(old, 6, 256) = copy(listing[p+2], 6, 256)) then begin			// lda #$28	; 2
      listing[p+2] := '';
      Result:=false;
     end else
      old:=listing[p+2];

     inc(p, 2);
    end;

   end;

   end;		// PeepholeOptimization_END
*)


   function PeepholeOptimization_STA: Boolean;
   var i, p, k: integer;
       tmp, old: string;
       yes, ok: Boolean;
   begin

   Result:=true;

   Rebuild;

   tmp:='';
   old:='';


   for i := 0 to l - 1 do
    if (listing[i] <> '') then begin

{
if (pos('RADIUS', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


{$i include/opt_STA_LDY.inc}

{$i include/opt_STA.inc}

{$i include/opt_STA_LSR.inc}

{$i include/opt_STA_IMUL.inc}

{$i include/opt_STA_IMUL_CX.inc}

{$i include/opt_STA_ZTMP.inc}

   end;

   end;		// PeepholeOptimization_STA


  function PeepholeOptimization: Boolean;
  var i, p, q, err: integer;
      tmp: string;
      yes: Boolean;
  begin

  Result:=true;

  Rebuild;

  tmp:='';


  for i := 0 to l - 1 do
   if listing[i] <> '' then begin


// cxxxxxxxxxxxxxxxx

{
if (pos('XBIT', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


{$i include/opt_FORTMP.inc}


    if (i = l - 1) and										// "samotna" instrukcja na koncu bloku
       (sta_stack(i) or sty_stack(i) or lda_a(i) or ldy(i) or and_ora_eor(i) or {iny(i) or}	// !!! 'iny' moze poprzedzac 'scc'
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i) or adc(i) or sbc(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 3) and										// "samotna" instrukcja na koncu bloku
       ((lda_a(i+1) and (lda_stack(i+1) = false)) or tya(i+1)) and
       sta_a(i+2) and

       (lda_a(i) or and_ora_eor(i) or
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 4) and										// "samotna" instrukcja na koncu bloku
       lda_a(i+1) and (lda_stack(i+1) = false) and
       sta_a(i+2) and
       sta_a(i+3) and

       (lda_a(i) or and_ora_eor(i) or
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 4) and										// "samotna" instrukcja na koncu bloku
       lda_stack(i) and
       sta_stack(i+1) and
       ((lda_a(i+2) and (lda_stack(i+2) = false)) or tya(i+2)) and
       sta_a(i+3) then
     begin
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false; Break;
     end;


{$i include/opt_ILLEGAL_STA_0.inc}

{$i include/opt_LDA.inc}

{$i include/opt_TAY.inc}

{$i include/opt_LDY.inc}

{$i include/opt_BP.inc}

{$i include/opt_AND.inc}

{$i include/opt_ORA.inc}

{$i include/opt_EOR.inc}

{$i include/opt_NOT.inc}

{$i include/opt_ADD.inc}

{$i include/opt_SUB.inc}


{$i include/opt_BP_ADR.inc}

{$i include/opt_BP2_ADR.inc}

{$i include/opt_ADR.inc}

{$i include/opt_LSR.inc}

{$i include/opt_ASL.inc}

{$i include/opt_SPL.inc}

{$i include/opt_POKE.inc}


  end;

 end;			// Peepholeoptimization


 begin			// OptimizeAssignment

  repeat until PeepholeOptimization;     while RemoveUnusedSTACK do repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_STA; while RemoveUnusedSTACK do repeat until PeepholeOptimization;


//  repeat until PeepholeOptimization_END; while RemoveUnusedSTACK do repeat until PeepholeOptimization;

 end;


 function OptimizeRelation: Boolean;
 var i, p: integer;
     c: cardinal;
     tmp: string;
     yes: Boolean;
 begin

  Result := true;

  // usuwamy puste '@'
  for i := 0 to l - 1 do begin
   if (pos('@+', listing[i]) > 0) then Break;
   if listing[i] = '@' then listing[i] := '';
  end;


  Rebuild;

   for i := 0 to l - 1 do
    if listing[i] <> '' then begin


{
if (pos('jcc l_0796', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


    if lda_im(i) and 										// lda #$		; 0
       add_im(i+1) and										// add #$		; 1
       sta(i+2) and										// sta			; 2
       (adc(i+4) = false) then
     begin

      p := GetBYTE(i) + GetBYTE(i+1);

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';

      Result:=false; Break;
     end;


    if lda_im(i) and 										// lda #$		; 0
       sub_im(i+1) and										// sub #$		; 1
       sta(i+2) and										// sta			; 2
       (sbc(i+4) = false) then
     begin

      p := GetBYTE(i) - GetBYTE(i+1);

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';

      Result:=false; Break;
     end;


    if lda(i) and										// lda		; 0
       ldy_1(i+1) and										// ldy #1	; 1
       (listing[i+2] = #9'and #$00') and							// and #$00	; 2
       bne(i+3) and										// bne @+	; 3
       lda(i+4) then										// lda		; 4
     begin
	listing[i] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false; Break;
     end;


    if (i>0) and (listing[i] = #9'and #$00') then						// lda #$00	; -1
     if lda_im_0(i-1) then begin								// and #$00	; 0
	listing[i] := '';
	Result:=false; Break;
     end;


    if lda_im_0(i) and										// lda #$00	; 0
       bne(i+1) and										// bne		; 1
       lda(i+2) then										// lda		; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if lda(i) and										// lda A	; 0
       SKIP(i+1) and										// SKIP		; 1
       lda(i+2) and										// lda A	; 2
       (listing[i] = listing[i+2]) then
     begin
	listing[i+2] := '';
	Result:=false; Break;
     end;


    if (lda_a(i) or adc_sbc(i)) and								// lda|adc|sbc		; 0
       ((listing[i+1] = #9'eor #$00') or (listing[i+1] = #9'ora #$00')) and			// eor|ora #$00		; 1
       SKIP(i+2) then										// SKIP			; 2
     begin
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if and_ora_eor(i) and									// and|ora|eor		; 0
       ((listing[i+1] = #9'eor #$00') or (listing[i+1] = #9'ora #$00')) and			// eor|ora #$00		; 1
       SKIP(i+2) then										// SKIP			; 2
     begin
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+9		; 0
       iny(i+1) and										// iny				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+9		; 2
       cmp(i+3) then										// cmp				; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := '';

	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+9		; 0
       lda(i+1) and										// lda				; 1
       AND_ORA_EOR_STACK(i+2) then 								// ora|and|eor :STACKORIGIN+9	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sty_stack(i) and										// sty :STACKORIGIN+10		; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+9		; 1
       AND_ORA_EOR_STACK(i+2) and								// ora|and|eor :STACKORIGIN+10	; 2
       sta_stack(i+3) then									// sta :STACKORIGIN+9		; 3
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
          (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sty_stack(i) and										// sty :STACKORIGIN+10		; 0
       lda(i+1) and										// lda 				; 1
       add_stack(i+2) and									// add :STACKORIGIN+10		; 2
       sta(i+3) then										// sta				; 3
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN		; 1
       AND_ORA_EOR(i+2) and (and_ora_eor_stack(i+2) = false) and				// ora|and|eor			; 2
       sta_stack(i+3) and									// sta :STACKORIGIN		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH	; 4
       bne(i+5) and										// bne @+			; 5
       lda_stack(i+6) then									// lda :STACKORIGIN		; 6
       if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
          (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
          (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i]   := listing[i+5];

//	listing[i+3] := '';

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	Result:=false; Break;
       end;

{
    if lda_stack(i) and										// lda :STACKORIGIN+10	; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10	; 1
       lda_stack(i+2) then									// lda :STACKORIGIN+10	; 2
       if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	  (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sta_stack(i) and 									// sta :STACKORIGIN+9	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+9	; 1
       (add_im_0(i+2) = false) and (cmp(i+2) = false) then					//~add #$00|~cmp	; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
      begin
       listing[i+1] := '';

       if (asl(i+2) = false) and (lsr(i+2) = false) then listing[i] := '';			// !!!

       Result:=false; Break;
      end;
}

    if adc_sbc(i+1) and										// adc|sbc		; 1
       sta_im_0(i+2) and									// sta #$00		; 2
       lda_a(i+3) and										// lda			; 3
       cmp(i+4) then										// cmp			; 4
     begin
	listing[i+1] := '';
	listing[i+2] := '';

	if lda_a(i) then listing[i] := '';

	Result:=false; Break;
     end;


    if sta_im_0(i) and										// sta #$00		; 0
       (cmp_im_0(i+1) or and_ora_eor(i+1)) and							// cmp #$00		; 1
       bne(i+2) then										// bne			; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	Result:=false; Break;
     end;


    if sta_im_0(i) and										// sta #$00		; 0
       adc_sbc(i+1) then									// adc|sbc		; 1
     begin
	listing[i+1] := '';

	if sta(i+2) then listing[i+2] := '';

	Result:=false; Break;
     end;


    if adc_sbc(i) and										// adc|sbc		; 0
       (lda(i+1) or mva(i+1) or mwa(i+1)) then							// lda|mva|mwa		; 1
     begin

      if (i>0) and lda(i-1) then listing[i-1] := '';

      listing[i] := '';
      Result:=false; Break;
     end;


    if sta_im_0(i) and										// sta #$00		; 0
       bne(i+1) and										// bne			; 1
       (SKIP(i+2) = false) then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if (and_ora_eor(i) or asl_a(i) or rol_a(i) or lsr_a(i) or ror_a(i)) and (iy(i) = false) and	// and|ora|eor		; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+N	; 1
       ldy_1(i+2) and										// ldy #1		; 2
       lda_stack(i+3) and 									// lda :STACKORIGIN+N	; 3
       (bne(i+4) or beq(i+4)) then								// bne|beq		; 4
     if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then
      begin
       listing[i+1] := '';
       listing[i+3] := listing[i];
       listing[i]   := '';
       Result:=false; Break;
      end;


    if (sty_stack(i) or sta_stack(i)) and							// sty|sta :STACKORIGIN+9	; 0
       mva_stack(i+1) and									// mva :STACKORIGIN+9 STOP	; 1
       (copy(listing[i], 6, 256) = GetString(i+1)) then
     begin
	listing[i+1] := copy(listing[i], 1, 5) + copy(listing[i+1], length(GetString(i+1)) + 7, 256);
	listing[i]   := '';
	Result:=false; Break;
     end;


// -----------------------------------------------------------------------------

{$i include/opt_CMP.inc}

{$i include/opt_LOCAL.inc}

{$i include/opt_POKE.inc}

{$i include/opt_CMP_BP2.inc}

{$i include/opt_CMP_0.inc}


// -----------------------------------------------------------------------------

{$i include/opt_LT_GTEQ.inc}

{$i include/opt_LTEQ.inc}

{$i include/opt_GT.inc}

{$i include/opt_NE_EQ.inc}

// -----------------------------------------------------------------------------

{$i include/opt_IF_AND.inc}

{$i include/opt_IF_OR.inc}

{$i include/opt_WHILE_AND.inc}

{$i include/opt_WHILE_OR.inc}

{$i include/opt_BOOLEAN_AND.inc}

// -----------------------------------------------------------------------------

{$i include/opt_BRANCH.inc}


   end;   // for

 end;


 procedure index(k: byte; x: integer; msb: Boolean = true);
 var m: byte;
 begin

   if msb then begin

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

   end else begin

	listing[l]   := #9'lda ' + GetARG(1, x);
	listing[l+1] := #9'sta ' + GetARG(1, x);
	listing[l+2] := #9'lda ' + GetARG(0, x);

	inc(l, 3);

	for m := 0 to k - 1 do begin

	  listing[l]   := #9'asl @';
	  listing[l+1] := #9'rol ' + GetARG(1, x);

	  inc(l, 2);
	end;

	listing[l]   := #9'sta ' + GetARG(0, x);
	listing[l+1] := #9'lda ' + GetARG(1, x);
	listing[l+2] := #9'sta ' + GetARG(1, x);

   end;

   inc(l, 3);

 end;


{$i include/opt_IMUL_CL.inc}


begin				// OptimizeASM

 l:=0;
 x:=0;

 arg0 := '';
 arg1 := '';

 inxUse := false;

 for i := 0 to High(s) do
  for k := 0 to 3 do s[i][k] := '';

 for i := 0 to High(listing) do listing[i]:='';


 for i := 0 to High(OptimizeBuf) - 1 do begin
  a := OptimizeBuf[i];

  if (a <> '') and (pos(';', a) = 0) then begin

   t:=a;

   if pos(#9'inx', a) > 0 then begin inc(x); inxUse:=true; t:='' end;
   if pos(#9'dex', a) > 0 then begin dec(x); t:='' end;


   if (pos('@print', a) > 0) then begin x:=51; arg0:='@print'; resetOpty; Break end;		// zakoncz optymalizacje niepowodzeniem

     if (pos(#9'jsr ', a) > 0) or (pos('m@', a) > 0) then begin

      if (pos(#9'jsr ', a) > 0) then
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

      if arg0 = '@expandToREAL' then begin
	t:='';

	s[x][3] := '';					// -> :STACKORIGIN+STACKWIDTH*3

	listing[l]   := #9'lda ' + GetARG(2, x);
	listing[l+1] := #9'sta ' + GetARG(3, x);
	listing[l+2] := #9'lda ' + GetARG(1, x);
	listing[l+3] := #9'sta ' + GetARG(2, x);
	listing[l+4] := #9'lda ' + GetARG(0, x);
	listing[l+5] := #9'sta ' + GetARG(1, x);
	listing[l+6] := #9'lda #$00';

	s[x][0] := '';					// -> :STACKORIGIN
	listing[l+7] := #9'sta ' + GetARG(0, x);

	inc(l,8);

      end else
      if arg0 = '@expandToREAL1' then begin
	t:='';

	s[x-1][3] := '';				// -> :STACKORIGIN-1+STACKWIDTH*3

	listing[l]   := #9'lda ' + GetARG(2, x-1);
	listing[l+1] := #9'sta ' + GetARG(3, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda ' + GetARG(0, x-1);
	listing[l+5] := #9'sta ' + GetARG(1, x-1);
	listing[l+6] := #9'lda #$00';

	s[x-1][0] := '';				// -> :STACKORIGIN-1
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l,8);

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
       listing[l+2] := #9'sub ' + GetARG(3, x);		// SBC ustawi znacznik V, gdy brak SUB #$00 => clv:sec
       listing[l+3] := #9'bne L4';
       listing[l+4] := #9'lda '+GetARG(2, x-1);
       listing[l+5] := #9'cmp '+GetARG(2, x);
       listing[l+6] := #9'bne L1';
       listing[l+7] := #9'lda '+GetARG(1, x-1);
       listing[l+8] := #9'cmp '+GetARG(1, x);
       listing[l+9] := #9'bne L1';
       listing[l+10]:= #9'lda '+GetARG(0, x-1);
       listing[l+11]:= #9'cmp '+GetARG(0, x);

       listing[l+12]:= 'L1'#9'beq L5';
       listing[l+13]:= #9'bcs L3';
       listing[l+14]:= #9'lda #$FF';
       listing[l+15]:= #9'bne L5';
       listing[l+16]:= 'L3'#9'lda #$01';
       listing[l+17]:= #9'bne L5';
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
       listing[l+1] := #9'lda '+GetARG(1, x-1);
       listing[l+2] := #9'sub '+GetARG(1, x);
       listing[l+3] := #9'bne L4';
       listing[l+4] := #9'lda '+GetARG(0, x-1);
       listing[l+5] := #9'cmp '+GetARG(0, x);
       listing[l+6] := #9'beq L5';
       listing[l+7] := #9'lda #$00';
       listing[l+8] := #9'adc #$FF';
       listing[l+9] := #9'ora #$01';
       listing[l+10]:= #9'bne L5';
       listing[l+11]:= 'L4'#9'bvc L5';
       listing[l+12]:= #9'eor #$FF';
       listing[l+13]:= #9'ora #$01';
       listing[l+14]:= 'L5';
       listing[l+15]:= #9'.ENDL';

       inc(l, 16);
      end else
      if arg0 = 'cmpSHORTINT' then begin
       t:='';

       arg1 := GetARG(0, x);

       if arg1 = '#$00' then begin
        listing[l] := #9'lda ' + GetARG(0, x-1);

        inc(l, 1);
       end else begin

       listing[l]   := #9'.LOCAL';
       listing[l+1] := #9'lda ' + GetARG(0, x-1);
       listing[l+2] := #9'sub ' + arg1;
       listing[l+3] := #9'beq L5';
       listing[l+4] := #9'bvc L5';
       listing[l+5] := #9'eor #$FF';
       listing[l+6] := #9'ora #$01';
       listing[l+7] := 'L5';
       listing[l+8] := #9'.ENDL';

       inc(l, 9);
       end;

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

       inc(l, 12);
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

       inc(l, 12);
      end else

      if arg0 = 'notBOOLEAN' then begin
       t:='';

       listing[l]   := #9'ldy #1';			// !!! wymagana konwencja
       listing[l+1] := #9'lda '+GetARG(0, x);
       listing[l+2] := #9'beq @+';
       listing[l+3] := #9'dey';
       listing[l+4] := '@';
       listing[l+5] := #9'sty '+GetARG(0, x);

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

	listing[l]   := #9'lda :ztmp8';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda :ztmp9';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda :ztmp10';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda :ztmp11';
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

      if (arg0 = '@BYTE.MOD') then begin
	t:='';

	if (l > 3) and lda_im(l-4) then
	  k := GetBYTE(l-4)
	else
	  k:=0;

	if k in [2,4,8,16,32,64,128] then begin

	 listing[l-4] := listing[l-2];

	 dec(l, 4);

	 case k of
	    2: listing[l+1] := #9'and #$01';
	    4: listing[l+1] := #9'and #$03';
	    8: listing[l+1] := #9'and #$07';
	   16: listing[l+1] := #9'and #$0F';
	   32: listing[l+1] := #9'and #$1F';
	   64: listing[l+1] := #9'and #$3F';
	  128: listing[l+1] := #9'and #$7F';
	 end;

	 listing[l+2] := #9'jsr #$00';

	 inc(l, 3);

	end else begin

	 listing[l] := #9'jsr @BYTE.MOD';

	 inc(l, 1);

	end;

{
	t0 := GetArg(0, x);
	t1 := GetArg(0, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) then begin

	  k:=GetVal(t1) mod GetVal(t0);

	  listing[l]   := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :ztmp8';

	  s[x-1, 1] := #9'lda #$00';
	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 2);
	end else begin
	  listing[l]   := #9'lda ' + t1;
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + t0;
	  listing[l+3] := #9'sta :ecx';
	  listing[l+4] := #9'jsr idivAL_CL.MOD';

	  inc(l, 5);
	end;
}
      end else


      if (arg0 = '@BYTE.DIV') then begin
	t:='';

	if (l > 3) and lda_im(l-4) then
	  k := GetBYTE(l-4)
	else
	  k:=0;

	if k in [2..32] then begin

	 listing[l-4] := listing[l-2];

	 dec(l, 4);

{$i include/opt_BYTE_DIV.inc}

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'sta :eax';

	 inc(l, 2);

	end else begin

	 listing[l]   := #9'jsr @BYTE.DIV';

	 inc(l, 1);

	end;

      end else
{
      if (arg0 = '@WORD.MOD') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(1, x);

	t2 := GetArg(0, x-1);
	t3 := GetArg(1, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) and (pos('#$', t2) > 0) and (pos('#$', t3) > 0) then begin

	  k:=(GetVal(t2) + GetVal(t3) shl 8) mod (GetVal(t0) + GetVal(t1) shl 8);

	  listing[l]   := #9'lda #$' + IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :ztmp8';
	  listing[l+2] := #9'lda #$' + IntToHex(byte(k shr 8), 2);
	  listing[l+3] := #9'sta :ztmp9';

	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 4);
	end else begin
	  listing[l]   := #9'lda ' + t2;
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + t3;
	  listing[l+3] := #9'sta :eax+1';
	  listing[l+4] := #9'lda ' + t0;
	  listing[l+5] := #9'sta :ecx';
	  listing[l+6] := #9'lda ' + t1;
	  listing[l+7] := #9'sta :ecx+1';
	  listing[l+8] := #9'jsr idivAX_CX.MOD';

	  inc(l, 9);
	end;

      end else
}

{
      if (arg0 = '@WORD.DIV') then begin
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
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + t3;
	  listing[l+3] := #9'sta :eax+1';
	  listing[l+4] := #9'lda ' + t0;
	  listing[l+5] := #9'sta :ecx';
	  listing[l+6] := #9'lda ' + t1;
	  listing[l+7] := #9'sta :ecx+1';
	  listing[l+8] := #9'jsr idivAX_CX';

	  inc(l, 9);
	end;

      end else
}

{
      if (arg0 = '@CARDINAL.DIV') or (arg0 = '@CARDINAL.MOD') then begin
	t:='';

	listing[l]   := #9'lda ' + GetArg(0, x-1);
	listing[l+1] := #9'sta :eax';
	listing[l+2] := #9'lda ' + GetArg(1, x-1);
	listing[l+3] := #9'sta :eax+1';
	listing[l+4] := #9'lda ' + GetArg(2, x-1);
	listing[l+5] := #9'sta :eax+2';
	listing[l+6] := #9'lda ' + GetArg(3, x-1);
	listing[l+7] := #9'sta :eax+3';
	listing[l+8] := #9'lda ' + GetArg(0, x);
	listing[l+9] := #9'sta :ecx';
	listing[l+10] := #9'lda ' + GetArg(1, x);
	listing[l+11] := #9'sta :ecx+1';
	listing[l+12] := #9'lda ' + GetArg(2, x);
	listing[l+13] := #9'sta :ecx+2';
	listing[l+14] := #9'lda ' + GetArg(3, x);
	listing[l+15] := #9'sta :ecx+3';

	if arg0 = '@CARDINAL.DIV' then
	 listing[l+16] := #9'jsr idivEAX_ECX.CARD'
	else
	 listing[l+16] := #9'jsr idivEAX_ECX.CARD.MOD';

	inc(l, 17);

      end else
}
      if (arg0 = 'imulBYTE') or (arg0 = 'mulSHORTINT') then begin
	t:='';

	s[x, 1] := '';
	s[x, 2] := '';
	s[x, 3] := '';

	s[x-1, 1] := '';
	s[x-1, 2] := '';
	s[x-1, 3] := '';

	m:=l;

	listing[l]   := #9'lda '+GetARG(0, x);
	listing[l+1] := #9'sta :ecx';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+2] := #9'sta :ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(0, x-1);
	listing[l+3]  := #9'sta :eax';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+4] := #9'sta :ztmp10';
	 inc(l);
	end;

	listing[l+4] := #9'.ifdef fmulinit';
	listing[l+5] := #9'fmulu_8';
	listing[l+6] := #9'els';
	listing[l+7] := #9'imulCL';
	listing[l+8] := #9'eif';


	if lda_im(l) and					// #const
	   (listing[l+1] = #9'sta :ecx') and
	   lda_im(l+2) and	   				// #const
	   (listing[l+3] = #9'sta :eax') then
	begin

	  k := GetBYTE(l) * GetBYTE(l+2);

      	  listing[l]  := #9'lda #$' + IntToHex(k and $ff, 2);
      	  listing[l+1]:= #9'sta :eax';
      	  listing[l+2]:= #9'lda #$' + IntToHex(byte(k shr 8), 2);
      	  listing[l+3]:= #9'sta :eax+1';

	  inc(l, 4);

	end else
	 if imulCL_opt then inc(l, 9);


	if arg0 = 'mulSHORTINT' then begin

	 listing[l]   := #9'lda :ztmp10';
	 listing[l+1] := #9'bpl @+';
	 listing[l+2] := #9'sec';
	 listing[l+3] := #9'lda :eax+1';
	 listing[l+4] := #9'sbc :ztmp8';
  	 listing[l+5] := #9'sta :eax+1';

	 listing[l+6] := '@';

	 listing[l+7]  := #9'lda :ztmp8';
	 listing[l+8]  := #9'bpl @+';
	 listing[l+9]  := #9'sec';
	 listing[l+10] := #9'lda :eax+1';
	 listing[l+11] := #9'sbc :ztmp10';
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

      end else

      if (arg0 = 'imulWORD') or (arg0 = 'mulSMALLINT') then begin
	t:='';

	s[x, 2] := '';
	s[x, 3] := '';

	s[x-1, 2] := '';
	s[x-1, 3] := '';

	m:=l;

	listing[l]   := #9'lda '+GetARG(0, x);		t0 := listing[l];
	listing[l+1] := #9'sta :ecx';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+2] := #9'sta :ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(1, x);		t1 := listing[l+2];
	listing[l+3]  := #9'sta :ecx+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+4] := #9'sta :ztmp9';
	 inc(l);
	end;

	listing[l+4]  := #9'lda '+GetARG(0, x-1);	t2 := listing[l+4];
	listing[l+5]  := #9'sta :eax';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+6] := #9'sta :ztmp10';
	 inc(l);
	end;

	listing[l+6]  := #9'lda '+GetARG(1, x-1);	t3 :=listing[l+6];
	listing[l+7]  := #9'sta :eax+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+8] := #9'sta :ztmp11';
	 inc(l);
	end;


        if lda_im(l) and
	   (listing[l+1] = #9'sta :ecx') and
	   lda_im(l+2) and
	   (listing[l+3] = #9'sta :ecx+1') and
	   lda_im(l+4) and
	   (listing[l+5] = #9'sta :eax') and
	   lda_im(l+6) and
	   (listing[l+7] = #9'sta :eax+1') then
	begin

	 k := GetWORD(l, l+2) * GetWORD(l+4, l+6);

         listing[l]   := #9'lda #$' + IntToHex(k and $ff, 2);
	 listing[l+1] := #9'sta :eax';
         listing[l+2] := #9'lda #$' + IntToHex(byte(k shr 8), 2);
	 listing[l+3] := #9'sta :eax+1';
         listing[l+4] := #9'lda #$' + IntToHex(byte(k shr 16), 2);
	 listing[l+5] := #9'sta :eax+2';
         listing[l+6] := #9'lda #$' + IntToHex(byte(k shr 24), 2);
	 listing[l+7] := #9'sta :eax+3';
         listing[l+8] := '';
         listing[l+9] := '';
         listing[l+10]:= '';
         listing[l+11]:= '';
         listing[l+12]:= '';

	end else begin

	 listing[l+8]  := #9'.ifdef fmulinit';
	 listing[l+9]  := #9'fmulu_16';
	 listing[l+10] := #9'els';
	 listing[l+11] := #9'imulCX';
	 listing[l+12] := #9'eif';

	end;

	inc(l, 13);

	if arg0 = 'mulSMALLINT' then begin

	listing[l]   := #9'lda :ztmp11';
	listing[l+1] := #9'bpl @+';
	listing[l+2] := #9'sec';
	listing[l+3] := #9'lda :eax+2';
	listing[l+4] := #9'sbc :ztmp8';
  	listing[l+5] := #9'sta :eax+2';
	listing[l+6] := #9'lda :eax+3';
	listing[l+7] := #9'sbc :ztmp9';
	listing[l+8] := #9'sta :eax+3';

	listing[l+9] := '@';

	listing[l+10] := #9'lda :ztmp9';
	listing[l+11] := #9'bpl @+';
	listing[l+12] := #9'sec';
	listing[l+13] := #9'lda :eax+2';
	listing[l+14] := #9'sbc :ztmp10';
	listing[l+15] := #9'sta :eax+2';
	listing[l+16] := #9'lda :eax+3';
	listing[l+17] := #9'sbc :ztmp11';
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


    if //lda_a(m) and {(lda_stack(m) = false) and}					// lda					; 0
       (listing[m+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       lda_im_0(m+2) and								// lda #$00				; 2
       (listing[m+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       lda_a(m+4) and {(lda_stack(m+4) = false) and}					// lda 					; 4
       (listing[m+5] = #9'sta :eax') and						// sta :eax				; 5
       lda_im_0(m+6) and								// lda #$00				; 6
       (listing[m+7] = #9'sta :eax+1') and						// sta :eax+1				; 7

       IFDEF_MUL16(m+8) then								// .ifdef fmulinit			; 8
       											// fmulu_16				; 9
     begin
      listing[m+2] := listing[m+4];
      listing[m+3] := listing[m+5];

      listing[m+4] := listing[m+8];
      listing[m+5] := #9'fmulu_8';
      listing[m+6] := listing[m+10];
      listing[m+7] := #9'imulCL';
      listing[m+8] := listing[m+12];

      l:=m+9;

      imulCL_opt;
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

	if sta_im_0(l+1) then begin
	 listing[l]   := '';
	 listing[l+1] := '';
	end;

	if sta_im_0(l+3) then begin
	 listing[l+2] := '';
	 listing[l+3] := '';
	end;

	if sta_im_0(l+5) then begin
	 listing[l+4] := '';
	 listing[l+5] := '';
	end;

	if sta_im_0(l+7) then begin
	 listing[l+6] := '';
	 listing[l+7] := '';
	end;

	inc(l, 8);
	end;

      end else

      if pos('@FCMPL', arg0) > 0 then		// @FCMPL		accepted
      else

      if pos('@FTOA', arg0) > 0 then		// @FTOA		accepted
      else

      if pos('@SHORTINT.DIV', arg0) > 0 then	// @SHORTINT.DIV	accepted
      else
      if pos('@SMALLINT.DIV', arg0) > 0 then	// @SMALLINT.DIV	accepted
      else
      if pos('@INTEGER.DIV', arg0) > 0 then	// @INTEGER.DIV		accepted
      else
      if pos('@SHORTINT.MOD', arg0) > 0 then	// @SHORTINT.MOD	accepted
      else
      if pos('@SMALLINT.MOD', arg0) > 0 then	// @SMALLINT.MOD	accepted
      else
      if pos('@INTEGER.MOD', arg0) > 0 then	// @INTEGER.MOD		accepted
      else

      if pos('@BYTE.DIV', arg0) > 0 then	// @BYTE.DIV		accepted
      else
      if pos('@WORD.DIV', arg0) > 0 then	// @WORD.DIV		accepted
      else
      if pos('@CARDINAL.DIV', arg0) > 0 then	// @CARDINAL.DIV	accepted
      else
      if pos('@BYTE.MOD', arg0) > 0 then	// @BYTE.MOD		accepted
      else
      if pos('@WORD.MOD', arg0) > 0 then	// @WORD.MOD		accepted
      else
      if pos('@CARDINAL.MOD', arg0) > 0 then	// @CARDINAL.MOD	accepted
      else

      if pos('@SHORTREAL_MUL', arg0) > 0 then	// @SHORTREAL_MUL	accepted
      else
      if pos('@REAL_MUL', arg0) > 0 then	// @REAL_MUL		accepted
      else
      if pos('@SHORTREAL_DIV', arg0) > 0 then	// @SHORTREAL_DIV	accepted
      else
      if pos('@REAL_DIV', arg0) > 0 then	// @REAL_DIV		accepted
      else

      if pos('@REAL_ROUND', arg0) > 0 then	// @REAL_ROUND		accepted
      else
      if pos('@REAL_TRUNC', arg0) > 0 then	// @REAL_TRUNC		accepted
      else
      if pos('@REAL_FRAC', arg0) > 0 then	// @REAL_FRAC		accepted
      else

      if pos('@F16_F2A', arg0) > 0 then		// @F16_F2A		accepted
      else
      if pos('@F16_ADD', arg0) > 0 then		// @F16_ADD		accepted
      else
      if pos('@F16_SUB', arg0) > 0 then 	// @F16_SUB		accepted
      else
      if pos('@F16_MUL', arg0) > 0 then		// @F16_MUL		accepted
      else
      if pos('@F16_DIV', arg0) > 0 then		// @F16_DIV		accepted
      else
      if pos('@F16_INT', arg0) > 0 then		// @F16_INT		accepted
      else
      if pos('@F16_ROUND', arg0) > 0 then	// @F16_ROUND		accepted
      else
      if pos('@F16_FRAC', arg0) > 0 then	// @F16_FRAC		accepted
      else
      if pos('@F16_I2F', arg0) > 0 then		// @F16_I2F		accepted
      else
      if pos('@F16_EQ', arg0) > 0 then		// @F16_EQ		accepted
      else
      if pos('@F16_GT', arg0) > 0 then		// @F16_GT		accepted
      else
      if pos('@F16_GTE', arg0) > 0 then		// @F16_GTE		accepted
      else

      if arg0 = 'SYSTEM.PEEK' then begin
	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) then begin

	  listing[l]   := #9'ldy '+GetARG(1, x);
	  listing[l+1] := #9'sty :bp+1';
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

	  listing[l]   := #9'ldy '+GetARG(1, x);
	  listing[l+1] := #9'sty :bp+1';
	  listing[l+2] := #9'ldy '+GetARG(0, x);
	  listing[l+3] := #9'lda '+GetARG(0, x-1);
	  listing[l+4] := #9'sta (:bp),y';

	  inc(l,5);
	end else begin

	  k := GetVAL(GetARG(0, x-1));
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l]   := #9'lda #$'+IntToHex(k, 2);

	  k := GetVAL(GetARG(0, x)) + GetVAL(GetARG(1, x)) shl 8;
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

	  listing[l]   := #9'lda '+GetARG(0, x);
	  listing[l+1] := #9'sta :bp2';
	  listing[l+2] := #9'lda '+GetARG(1, x);
	  listing[l+3] := #9'sta :bp2+1';
	  listing[l+4] := #9'ldy #$00';
	  listing[l+5] := #9'lda '+GetARG(0, x-1);
	  listing[l+6] := #9'sta (:bp2),y';
	  listing[l+7] := #9'iny';
	  listing[l+8] := #9'lda '+GetARG(1, x-1);
	  listing[l+9] := #9'sta (:bp2),y';

	  inc(l,10);
	end else begin

	  k := GetVAL(GetARG(0, x-1));
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;
	  listing[l]   := #9'lda #$'+IntToHex(k, 2);

	  k := GetVAL(GetARG(1, x-1));
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;
	  listing[l+2] := #9'lda #$'+IntToHex(k, 2);

	  k := GetVAL(GetARG(0, x)) + GetVAL(GetARG(1, x)) shl 8;
	  if (k > $FFFF) or (k < 0) then begin x:=50; Break end;

	  listing[l+1] := #9'sta $'+IntToHex(k, 4);
	  listing[l+3] := #9'sta $'+IntToHex(k, 4)+'+1';

	  inc(l, 4);
	end;

	dec(x, 2);

      end else
      if arg0 = 'shrAL_CL.BYTE' then begin		// SHR BYTE
	t:='';

	k := GetVAL(GetARG(0, x));

	if {(k > 7) or} (k < 0) then begin x:=50; Break end;

	if k > 7 then begin

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);
	listing[l+6] := #9'lda '+GetARG(3, x-1);
	listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);

	end else begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	inc(l);

	for m := 0 to k - 1 do begin
	 listing[l] := #9'lsr @';
	 inc(l);
	end;

	listing[l]   := #9'sta '+GetARG(0, x-1);

	inc(l);
{
	s[x-1, 1] := '';//#9'mva #$00';
	s[x-1, 2] := '';//#9'mva #$00';
	s[x-1, 3] := '';//#9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);

	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);
}
	inc(l, 2);
	end;

      end else
      if arg0 = 'shrAX_CL.WORD' then begin		// SHR WORD
	t:='';

	k := GetVAL(GetARG(0, x, false));

//	if {(k > 8) or} (k < 0) then begin x:=50; Break end;

	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

      if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'lsr ' + GetARG(1, x-1);
	 listing[l+11] := #9'ror @';

	 listing[l+12] := #9'dey';
	 listing[l+13] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+14] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+15] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 16);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

     end else
     if k > 15 then begin

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);
	listing[l+6] := #9'lda '+GetARG(3, x-1);
	listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);

     end else

     if k = 9 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+2] := #9'sta ' + GetARG(0, x-1);

	inc(l, 3);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 10 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+3] := #9'sta ' + GetARG(0, x-1);

	inc(l, 4);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 11 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+4] := #9'sta ' + GetARG(0, x-1);

	inc(l, 5);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 12 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+5] := #9'sta ' + GetARG(0, x-1);

	inc(l, 6);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 13 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	listing[l+5] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+6] := #9'sta ' + GetARG(0, x-1);

	inc(l, 7);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 14 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	listing[l+5] := #9'lsr @';
	listing[l+6] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 15 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'asl @';
	s[x-1][0] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'rol @';
	listing[l+4] := #9'sta ' + GetARG(0, x-1);

	inc(l, 5);

	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 8 then begin
	listing[l]   := #9'lda ' + GetARG(1, x-1);
	s[x-1][0] := '';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);

	inc(l, 2);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
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

	listing[l]   := #9'lda '+GetARG(2, x-1);
	listing[l+1] := #9'sta '+GetARG(2, x-1);
	listing[l+2] := #9'lda '+GetARG(3, x-1);
	listing[l+3] := #9'sta '+GetARG(3, x-1);

	inc(l, 4);

     end;

     end else
      if arg0 = 'shrEAX_CL' then begin			// SHR CARDINAL
	t:='';

	k := GetVAL(GetARG(0, x, false));

	if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+11] := #9'ror ' + GetARG(2, x-1);
	 listing[l+12] := #9'ror ' + GetARG(1, x-1);
	 listing[l+13] := #9'ror @';

	 listing[l+14] := #9'dey';
	 listing[l+15] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+16] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+17] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 18);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

	end else
	if k = 13 then begin

	 listing[l]   := #9'lda ' + GetARG(1, x-1);
	 s[x-1][0]    := '';
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][1]    := '';
	 listing[l+3] := #9'sta ' + GetARG(1, x-1);
	 listing[l+4] := #9'lda ' + GetARG(3, x-1);
	 s[x-1][2]    := '';
	 listing[l+5] := #9'sta ' + GetARG(2, x-1);

	 listing[l+6] := #9'lda #$00';

	 listing[l+7] := #9'asl ' + GetARG(0, x-1);
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);
	 listing[l+10] := #9'rol @';

	 listing[l+11] := #9'asl ' + GetARG(0, x-1);
	 listing[l+12] := #9'rol ' + GetARG(1, x-1);
	 listing[l+13] := #9'rol ' + GetARG(2, x-1);
	 listing[l+14] := #9'rol @';

	 listing[l+15] := #9'asl ' + GetARG(0, x-1);
	 listing[l+16] := #9'rol ' + GetARG(1, x-1);
	 listing[l+17] := #9'rol ' + GetARG(2, x-1);
	 listing[l+18] := #9'rol @';

	 listing[l+19] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 20);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);
	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta '+GetARG(3, x-1);

	 inc(l, 8);

	end else
	if k = 23 then begin

	 listing[l]   := #9'lda ' + GetARG(2, x-1);
	 listing[l+1] := #9'asl @';
	 s[x-1][0] := '';
	 listing[l+2] := #9'lda ' + GetARG(3, x-1);
	 listing[l+3] := #9'rol @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 s[x-1][1] := '';
	 listing[l+5] := #9'lda #$00';
	 listing[l+6] := #9'rol @';
	 listing[l+7] := #9'sta ' + GetARG(1, x-1);

	 inc(l, 8);

	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(2, x-1);
	 listing[l+2] := #9'lda '+GetARG(3, x-1);
	 listing[l+3] := #9'sta '+GetARG(3, x-1);

	 inc(l, 4);

	end else
	if k = 27 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1, 0] := '';
	 listing[l+1] := #9'lsr @';
	 listing[l+2] := #9'lsr @';
	 listing[l+3] := #9'lsr @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 5);

	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	end else
	if k = 31 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 listing[l+1] := #9'asl @';
	 s[x-1][0] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'rol @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 5);

	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l,6);

	end else begin

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

	end;	// if k = 31

     end else

      if arg0 = 'shlEAX_CL.BYTE' then begin		// SHL BYTE
	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1][1] := '';				// !!! bez tego nie zadziala gdy 'lda adr.' !!!
	s[x-1][2] := '';
	s[x-1][3] := '';

	inc(l, 2);


	if k > 31 then begin

	s[x-1][0] := '';

	listing[l]   := #9'lda #$00';			// shl 32..
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

	end else

	if k = 31 then begin				// shl 31

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(2, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);

	 inc(l,6);
	end else

	if k = 10 then begin

	 s[x-1][1] := #9'mva #$00';
	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'sta ' + GetARG(0, x-1);

	 inc(l,14);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 11 then begin

	 s[x-1][1] := #9'mva #$00';
	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'asl @';
	 listing[l+14] := #9'rol ' + GetARG(1, x-1);
	 listing[l+15] := #9'rol ' + GetARG(2, x-1);

	 listing[l+16] := #9'sta ' + GetARG(0, x-1);

	 inc(l,17);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

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

          s[x-1][3] := #9'mva #$00';

          listing[l+3] := #9'lda ' + GetARG(3, x-1);
          listing[l+4] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 5);

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

	if (k > 7) or (k < 0) then begin //x:=50; Break end;

	 listing[l]   := #9'lda #$00';
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda #$00';
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda #$00';
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);

	 inc(l, 6);

	 listing[l] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+1] := #9'sta ' + GetARG(1, x-1);
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 inc(l, 3);

	 listing[l] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+1] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+2] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+3] := #9'asl @';
	 listing[l+4] := #9'rol ' + GetARG(1, x-1);
	 listing[l+5] := #9'rol ' + GetARG(2, x-1);
	 listing[l+6] := #9'rol ' + GetARG(3, x-1);

	 listing[l+7] := #9'dey';
	 listing[l+8] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+10] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 11);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 s[x-1][2] := '';
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 s[x-1][3] := '';
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

       end else begin

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

      end;

      end else
      if arg0 = 'shlEAX_CL.WORD' then begin	    // SHL WORD
	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1][2] := '';
	s[x-1][3] := '';

        if k < 0 then begin

	 listing[l]   := #9'lda #$00';
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda #$00';
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);

	 inc(l, 4);

	 listing[l] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+1] := #9'sta ' + GetARG(1, x-1);
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 inc(l, 3);

	 listing[l] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+1] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+2] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+3] := #9'asl @';
	 listing[l+4] := #9'rol ' + GetARG(1, x-1);
	 listing[l+5] := #9'rol ' + GetARG(2, x-1);
	 listing[l+6] := #9'rol ' + GetARG(3, x-1);

	 listing[l+7] := #9'dey';
	 listing[l+8] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+10] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 11);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

        end else

	if k = 16 then begin

	s[x-1][2] := '';
	s[x-1][3] := '';

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(2, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(3, x-1);

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta '+GetARG(0, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta '+GetARG(1, x-1);

	inc(l,8);

	end else
{
	if k = 15 then begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][1] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'ror @';
	listing[l+4] := #9'sta ' + GetARG(1, x-1);

	inc(l, 5);

	s[x-1, 0] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

	end else
}
	if k = 10 then begin

	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'sta ' + GetARG(0, x-1);

	 inc(l,14);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 11 then begin

	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'asl @';
	 listing[l+14] := #9'rol ' + GetARG(1, x-1);
	 listing[l+15] := #9'rol ' + GetARG(2, x-1);

	 listing[l+16] := #9'sta ' + GetARG(0, x-1);

	 inc(l,17);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 31 then begin				// shl 31

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(2, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);

	 inc(l,6);
	end else

	if k = 8 then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(3, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda ' + GetARG(0, x-1);
	listing[l+5] := #9'sta ' + GetARG(1, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	end else begin

	if (k > 7) {or (k < 0)} then begin x:=50; Break end;

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

       k := GetVAL(GetARG(0, x, false));


	if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);
	 listing[l+13] := #9'rol ' + GetARG(3, x-1);

	 listing[l+14] := #9'dey';
	 listing[l+15] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+16] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+17] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 18);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

	end else
(*
       if k = 7 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';
	 listing[l+7] := #9'sta ' + GetARG(0, x-1);
	 listing[l+8] := #9'lda #$00';

	 listing[l+9] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+10] := #9'ror ' + GetARG(2, x-1);
	 listing[l+11] := #9'ror ' + GetARG(1, x-1);
	 listing[l+12] := #9'ror ' + GetARG(0, x-1);
	 listing[l+13] := #9'ror @';

	 listing[l+14] := #9'tay';

	 inc(l, 15);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);
         listing[l+6] := #9'tya';
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l, 8);

       end else
*)
       if k = 13 then begin

	 listing[l]   := #9'lda ' + GetARG(2, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 s[x-1][0]    := '';
	 listing[l+6] := #9'lda #$00';

	 listing[l+7] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+8] := #9'ror ' + GetARG(2, x-1);
	 listing[l+9] := #9'ror ' + GetARG(1, x-1);
	 listing[l+10] := #9'ror @';

	 listing[l+11] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+12] := #9'ror ' + GetARG(2, x-1);
	 listing[l+13] := #9'ror ' + GetARG(1, x-1);
	 listing[l+14] := #9'ror @';

	 listing[l+15] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+16] := #9'ror ' + GetARG(2, x-1);
	 listing[l+17] := #9'ror ' + GetARG(1, x-1);
	 listing[l+18] := #9'ror @';

	 listing[l+19] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 20);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);
	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l, 8);

       end else
       if k = 23 then begin

	 listing[l]   := #9'lda ' + GetARG(1, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 s[x-1][2] := '';
	 listing[l+5] := #9'lda #$00';
	 listing[l+6] := #9'ror @';
	 listing[l+7] := #9'sta ' + GetARG(2, x-1);

	 inc(l, 8);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);

	 inc(l, 4);

       end else
       if k = 31 then begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][3] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'ror @';
	listing[l+4] := #9'sta ' + GetARG(3, x-1);

	inc(l, 5);

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);

	inc(l,6);

       end else begin

//       if {(k > 7) or} (k < 0) then begin x:=50; Break end;

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

		s[x-1, 0] := '';
	     	s[x-1, 1] := '';

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

		s[x-1, 0] := '';
	     	s[x-1, 1] := '';
	     	s[x-1, 2] := '';

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

       end;	// if k = 31

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

{
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
}

      if (pos('add', arg0) > 0) or (pos('sub', arg0) > 0) then begin

      t:='';

      if (arg0 = 'subAL_CL') then begin

       s[x-1][1] := #9'mva #$00';
       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+3] := '';
       listing[l+4] := '';
       listing[l+5] := '';

       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 3);
      end;

      if (arg0 = 'subAX_CX') then begin

       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 6);
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

       s[x-1][1] := #9'mva #$00';
       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'adc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'adc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+3] := '';
       listing[l+4] := '';
       listing[l+5] := '';

       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 3);
      end;

      if arg0 = 'addAX_CX' then begin

       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'adc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'adc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 6);
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


   if (pos(':STACKORIGIN-1+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x-1][1]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN-1+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x-1][2]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN-1+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x-1][3]:=copy(a, 1, pos(' :STACK', a)); t:='' end;

   if (pos(':STACKORIGIN+1+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x+1][1]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN+1+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x+1][2]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN+1+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x+1][3]:=copy(a, 1, pos(' :STACK', a)); t:='' end;


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


   if (pos(':STACKORIGIN-1,', t) = 6) then		t:=copy(a, 1, pos(' :STACK', a)) + GetARG(0, x-1);
   if (pos(':STACKORIGIN-1+STACKWIDTH,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(1, x-1);
   if (pos(':STACKORIGIN-1+STACKWIDTH*2,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(2, x-1);
   if (pos(':STACKORIGIN-1+STACKWIDTH*3,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(3, x-1);


   if (pos(':STACKORIGIN+1,', t) = 6) then		t:=copy(a, 1, pos(' :STACK', a)) + GetARG(0, x+1);
   if (pos(':STACKORIGIN+1+STACKWIDTH,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(1, x+1);
   if (pos(':STACKORIGIN+1+STACKWIDTH*2,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(2, x+1);
   if (pos(':STACKORIGIN+1+STACKWIDTH*3,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(3, x+1);

   if t <> '' then begin
    listing[l] := t;
    inc(l);
   end;

  end;

 end;

(* -------------------------------------------------------------------------- *)

 if ((x = 0) and inxUse) then begin   // succesfull

  if optimize.line <> optimize.old then begin
   WriteOut('');
   WriteOut('; optimize OK ('+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line));
   WriteOut('');

   optimize.old := optimize.line;
  end;

{$IFDEF OPTIMIZECODE}

  repeat

    OptimizeAssignment;

    repeat until OptimizeRelation;

    OptimizeAssignment;

  until OptimizeRelation;


  if OptimizeEAX then begin
    OptimizeAssignment;

    OptimizeEAX_OFF;

    OptimizeAssignment;
  end;


{$ENDIF}


{$i include/opt_FOR.inc}


{$I include/opt_REG_A.inc}

{$I include/opt_REG_BP2.inc}

{$I include/opt_REG_Y.inc}


(* -------------------------------------------------------------------------- *)

  for i := 0 to l - 1 do
    if listing[i]<>'' then WriteInstruction(i);

(* -------------------------------------------------------------------------- *)


 end else begin

  l := High(OptimizeBuf);

  if l > High(listing) then begin writeln('Out of resources, LISTING'); halt end;

  for i := 0 to l-1 do
   listing[i] := OptimizeBuf[i];


{$IFDEF OPTIMIZECODE}

  repeat until PeepholeOptimization_STACK;		// optymalizacja lda :STACK...,x \ sta :STACK...,x

{$ENDIF}

// optyA := '';

 if optyA <> '' then
  for i:=0 to l-1 do
   if (listing[i] = #9'inc ' + optyA) or (listing[i] = #9'dec ' + optyA) or //((optyY <> '') and (optyA = optyY)) or
      lda(i) or lda_adr(i) or mva(i) or mwa(i) or tya(i) or lab_a(i) or jsr(i) or
      (pos(#9'jmp ', listing[i]) > 0) or (pos(#9'.if', listing[i]) > 0) then begin optyA := ''; Break end;


// optyY := '';

 if optyY <> '' then
  for i:=0 to l-1 do
   if LabelIsUsed(i) or //((optyA <> '') and (optyA = optyY)) or
      ldy(i) or mvy(i) or mwy(i) or iny(i) or dey(i) or tay(i) or lab_a(i) or jsr(i) or
      (pos(#9'jmp ', listing[i]) > 0) or (pos(#9'.if', listing[i]) > 0) then begin optyY := ''; Break end;


// optyBP2 := '';

 if optyBP2 <> '' then
  for i:=0 to l-1 do begin

   if (optyBP2 <> '') and (sta_a(i) or sty(i) or asl(i) or rol(i) or lsr(i) or ror(i) or inc_(i) or dec_(i)) then
    if (pos('? '+copy(listing[i], 6, 256)+' ', optyBP2) > 0) or (pos(';'+copy(listing[i], 6, 256)+';', optyBP2) > 0) then begin optyBP2:=''; Break end;

   if sta_bp2(i) or sta_bp2_1(i) or jsr(i) or
      (pos(#9'jmp ', listing[i]) > 0) then begin optyBP2 := ''; Break end;

  end;


 if optimize.line <> optimize.old then begin
  WriteOut('');

  if x = 51 then
   WriteOut('; optimize FAIL ('+''''+arg0+''''+ ', '+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line))
  else
   WriteOut('; optimize FAIL ('+IntToStr(x)+', '+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line));

  WriteOut('');

  optimize.old := optimize.line;
 end;


(* -------------------------------------------------------------------------- *)

  for i := 0 to l - 1 do WriteInstruction(i);

(* -------------------------------------------------------------------------- *)

 end;


{$IFDEF USEOPTFILE}

 writeln(OptFile, StringOfChar('-', 32));
 writeln(OptFile, 'SOURCE');
 writeln(OptFile, StringOfChar('-', 32));

  for i := 0 to High(OptimizeBuf) - 1 do
    Writeln(OptFile, OptimizeBuf[i]);

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


procedure asm65(a: string = ''; comment : string ='');
var len, i: integer;
    optimize_code: Boolean;
    str: string;
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
   OptimizeBuf[i] := a;

   SetLength(OptimizeBuf, i+2);

  end else begin

   if High(OptimizeBuf) > 0 then

     OptimizeASM

   else begin

    str:=a;

    if comment<>'' then begin

     len:=0;

     for i := 1 to length(a) do
      if a[i] = #9 then
       inc(len, 8-(len mod 8))
      else
       if not(a[i] in [CR, LF]) then inc(len);

     while len < 56 do begin str:=str+#9; inc(len, 8) end;

     str:=str + comment;

    end;

    WriteOut(str);

   end;

  end;

 end;

end;


function GetValueType(Value: Int64): byte;
begin

    if Value < 0 then begin

     if Value >= Low(shortint) then Result := SHORTINTTOK else
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
 else if (ExpectedTok = STRINGLITERALTOK) then
  s := 'string'
 else
  s := 'unknown token';

 if Tok[i].Kind <> ExpectedTok then
   Error(i, 'Syntax error, ' + ''''+ s +'''' + ' expected but ''' + GetSpelling(i) + ''' found');

end;


function SearchDefine(X: string): integer;
var i: integer;
begin
   for i:=1 to NumDefines do
    if X = Defines[i].Name then begin
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
    Defines[NumDefines].Name := S;

    Defines[NumDefines].Macro := '';
    Defines[NumDefines].Line := 0;
   end;
end;


procedure AddPath(s: string);
var k: integer;
begin

  for k:=1 to High(UnitPath)-1 do
    if UnitPath[k] = s then exit;
							// https://github.com/tebe6502/Mad-Pascal/issues/113
  {$IFDEF UNIX}
   if Pos('\', s) > 0 then
    s := LowerCase(StringReplace(s, '\', '/', [rfReplaceAll]));
  {$ENDIF}

  k:=High(UnitPath);
  UnitPath[k] := IncludeTrailingPathDelimiter ( s );

  SetLength(UnitPath, k + 2);
end;



procedure TokenizeMacro(a: string; Line, Spaces: integer);
var
  Text: string;
  Num, Frac: TString;
  Err, Line2, TextPos, im: Integer;
  Tmp: Int64;
  yes: Boolean;
  ch, ch2: Char;
  CurToken: Byte;


  procedure SkipWhiteSpace;				// 'string' + #xx + 'string'
  begin
    ch:=a[i]; inc(i);

    while ch in AllowWhiteSpaces do begin ch:=a[i]; inc(i) end;

    if not(ch in ['''','#']) then Error(NumTok, 'Syntax error, ''string'' expected but '''+ ch +''' found');
  end;


  procedure TextInvers(p: integer);
  var i: integer;
  begin

   for i := p to length(Text) do
    if ord(Text[i]) < 128 then
     Text[i] := chr(ord(Text[i])+$80);

  end;


  procedure TextInternal(p: integer);
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


  function cbm(const a: char): byte;
  begin
   Result:=ord(a);

      case a of
       'a'..'z': dec(Result, 96);
       '['..'_': dec(Result, 64);
            '`': Result:=64;
	    '@': Result:=0;
      end;

   end;


  begin

   if target.id = 'a8' then begin

     for i := p to length(Text) do
      Text[i] := chr(ata2int(ord(Text[i])));

   end else begin

     for i := p to length(Text) do
      Text[i] := chr(cbm(Text[i]));

   end;

  end;


  procedure ReadNumber;
  var x, k, ln: integer;
  begin

    Num:='';

    if ch='%' then begin		  // binary

      ch:=a[i]; inc(i);

      while ch in ['0', '1'] do
       begin
       Num := Num + ch;
       ch:=a[i]; inc(i);
       end;

       if length(Num)=0 then
	 iError(NumTok, OrdinalExpExpected);

       //remove leading zeros
       x:=1;
       while Num[x]='0' do inc(x);

       tmp:=0;

       ln:=length(Num);

       //do the conversion
       for k:=ln downto x do
	if Num[k]='1' then
	 tmp:=tmp+(1 shl (ln-k));

       Num:=IntToStr(tmp);

    end else

    if ch='$' then begin		  // hexadecimal

      ch:=a[i]; inc(i);

      while UpCase(ch) in AllowDigitChars do
       begin
       Num := Num + ch;
       ch:=a[i]; inc(i);
       end;

       if length(Num)=0 then
	 iError(NumTok, OrdinalExpExpected);

       val('$'+Num, tmp, err);

       Num:=IntToStr(tmp);

    end else

      while ch in ['0'..'9'] do		// Number suspected
	begin
	Num := Num + ch;
	ch:=a[i]; inc(i);
	end;

  end;


begin

 i:=1;

 while i <= length(a) do begin

  while a[i] in AllowWhiteSpaces do begin

   if a[i] = LF then begin
    inc(Line); Spaces:=0;
   end else
    inc(Spaces);

   inc(i);
  end;

  ch := UpCase(a[i]); inc(i);


      Num:='';
      if ch in ['0'..'9', '$', '%'] then ReadNumber;

      if Length(Num) > 0 then			// Number found
	begin
	AddToken(INTNUMBERTOK, 1, Line, length(Num) + Spaces, StrToInt(Num)); Spaces:=0;

	if ch = '.' then			// Fractional part suspected
	  begin

	  ch:=a[i]; inc(i);

	  if ch = '.' then
	    dec(i)				// Range ('..') token
	  else
	    begin				// Fractional part found
	    Frac := '.';

	    while ch in ['0'..'9'] do
	      begin
	      Frac := Frac + ch;

	      ch:=a[i]; inc(i);
	      end;

	    Tok[NumTok].Kind := FRACNUMBERTOK;
	    Tok[NumTok].FracValue := StrToFloat(Num + Frac);
	    Tok[NumTok].Column := Tok[NumTok-1].Column + length(Num) + length(Frac) + Spaces; Spaces:=0;
	    end;
	  end;

	Num := '';
	Frac := '';
	end;


      if ch in ['A'..'Z', '_'] then		// Keyword or identifier suspected
	begin

	Text := '';

	err:=0;

	TextPos := i - 1;

	while ch in ['A'..'Z', '_', '0'..'9','.'] do begin
	  Text := Text + ch;
	  inc(err);

	  ch:=UpCase(a[i]); inc(i);
	end;


	if err > 255 then
	 Error(NumTok, 'Constant strings can''t be longer than 255 chars');

	if Length(Text) > 0 then
	  begin

	 CurToken := GetStandardToken(Text);

	 im := SearchDefine(Text);

	 if (im > 0) and (Defines[im].Macro <> '') then begin

 	  ch:=#0;

	  i:=TextPos;

          if Defines[im].Macro = copy(a,i,length(text)) then
	   Error(NumTok, 'Recursion in macros is not allowed');

	  delete(a, i, length(Text));
	  insert(Defines[im].Macro, a, i);

	  CurToken := MACRORELEASE;

	 end else begin

	  if CurToken = TEXTTOK then CurToken := TEXTFILETOK;
	  if CurToken = FLOATTOK then CurToken := SINGLETOK;
	  if CurToken = FLOAT16TOK then CurToken := HALFSINGLETOK;
	  if CurToken = SHORTSTRINGTOK then CurToken := STRINGTOK;

	  AddToken(0, 1, Line, length(Text) + Spaces, 0); Spaces:=0;

	 end;

	 if CurToken <> MACRORELEASE then

	 if CurToken <> 0 then begin		// Keyword found

	     Tok[NumTok].Kind := CurToken;

	 end
	 else begin				// Identifier found
	     Tok[NumTok].Kind := IDENTTOK;
	     New(Tok[NumTok].Name);
	     Tok[NumTok].Name^ := Text;
	   end;

	 end;

	 Text := '';
	end;


	if ch in ['''', '#'] then begin

	 Text := '';
	 yes:=true;

	 repeat

	 case ch of

	  '''': begin

		 if yes then begin
		  TextPos := Length(Text)+1;
		  yes:=false;
		 end;

		 inc(Spaces);

		 repeat
		  ch:=a[i]; inc(i);

		  if ch = LF then	//Inc(Line);
		   Error(NumTok, 'String exceeds line');

		  if not(ch in ['''',CR,LF]) then
		   Text := Text + ch
		  else begin

		   ch2:=a[i]; inc(i);

		   if ch2='''' then begin
		    Text := Text + '''';
		    ch:=#0;
		   end else
		    dec(i);

		  end;

		 until ch = '''';

		 inc(Spaces);

		 ch:=a[i]; inc(i);

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=i;
			while ch2 in [' ',TAB] do begin ch2:=a[i]; inc(i) end;

			if ch2 in ['*','~','+'] then
			 ch:=ch2
			else
			 i:=Err;
		 end;


		 if ch='*' then begin
		  inc(Spaces);
		  TextInvers(TextPos);
		  ch:=a[i]; inc(i);
		 end;

		 if ch='~' then begin
		  inc(Spaces);
		  TextInternal(TextPos);
		  ch:=a[i]; inc(i);

		  if ch='*' then begin
		   inc(Spaces);
		   TextInvers(TextPos);
		   ch:=a[i]; inc(i);
		  end;

		 end;

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=i;
			while ch2 in [' ',TAB] do begin ch2:=a[i]; inc(i) end;

			if ch2 in ['''','+'] then
			 ch:=ch2
			else
			 i:=Err;
		 end;


		 if ch='+' then begin
		  yes:=true;
		  inc(Spaces);
		  SkipWhiteSpace;
		 end;

		end;

	   '#': begin
		 ch:=a[i]; inc(i);

		 Num:='';
		 ReadNumber;

		 if Length(Num)>0 then
		  Text := Text + chr(StrToInt(Num))
		 else
		  Error(NumTok, 'Constant expression expected');

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=i;
			while ch2 in [' ',TAB] do begin ch2:=a[i]; inc(i) end;

			if ch2 in ['''','+'] then
			 ch:=ch2
			else
			 i:=Err;
		 end;

		 if ch='+' then begin
		  inc(Spaces);
		  SkipWhiteSpace;
		 end;

		end;
	 end;

	 until not (ch in ['#', '''']);

	 case ch of
	  '*': begin TextInvers(TextPos); ch:=a[i]; inc(i) end;			// Invers
	  '~': begin TextInternal(TextPos); ch:=a[i]; inc(i) end;		// Antic
 	 end;

	// if Length(Text) > 0 then
	  if Length(Text) = 1 then begin
	    AddToken(CHARLITERALTOK, 1, Line, 1 + Spaces, Ord(Text[1])); Spaces:=0;
	  end else begin
	    AddToken(STRINGLITERALTOK, 1, Line, length(Text) + Spaces, 0); Spaces:=0;
	    DefineStaticString(NumTok, Text);
	  end;

	 Text := '';

	end;


      if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then begin
	AddToken(GetStandardToken(ch), 1, Line, 1 + Spaces, 0); Spaces:=0;
      end;


      if ch in [':', '>', '<', '.'] then					// Double-character token suspected
	begin

	Line2:=Line;

	ch2:=a[i]; inc(i);

	if (ch2 = '=') or
	   ((ch = '<') and (ch2 = '>')) or
	   ((ch = '.') and (ch2 = '.')) then begin				// Double-character token found
	  AddToken(GetStandardToken(ch + ch2), 1, Line, 2 + Spaces, 0); Spaces:=0;
	end else
	 if (ch='.') and (ch2 in ['0'..'9']) then begin

	   AddToken(INTNUMBERTOK, 1, Line, 0, 0);

	   Frac := '0.';		  // Fractional part found

	   while ch2 in ['0'..'9'] do begin
	    Frac := Frac + ch2;

	    ch2:=a[i]; inc(i);
	   end;

	   Tok[NumTok].Kind := FRACNUMBERTOK;
	   Tok[NumTok].FracValue := StrToFloat(Frac);
	   Tok[NumTok].Column := Tok[NumTok-1].Column + length(Frac) + Spaces; Spaces:=0;

	   Frac := '';

	   dec(i);

	 end else
	  begin
	  dec(i);
	  Line:=Line2;

	  if ch in [':','>', '<', '.'] then begin				// Single-character token found
	    AddToken(GetStandardToken(ch), 1, Line, 1 + Spaces, 0); Spaces:=0;
	  end;

	  end;

	end;

end;

end;


function SplitString(a: string; const Sep: Char): TArrayString;
(*----------------------------------------------------------------------------*)
(*  wczytaj dowolne znaki rozdzielone 'Sep'		                      *)
(*  jesli wystepuja znaki otwierajace ciag, czytaj taki ciag                  *)
(*----------------------------------------------------------------------------*)

var znak: char;
    i, len: integer;
    txt, s: string;


procedure omin_spacje (var i:integer; var a:string);
(*----------------------------------------------------------------------------*)
(*  omijamy tzw. "biale spacje" czyli spacje, tabulatory		      *)
(*----------------------------------------------------------------------------*)
begin

 if a <> '' then
  while (i<=length(a)) and (a[i] in AllowWhiteSpaces) do inc(i);

end;


function get_string(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag znakow, ograniczony znakami '' lub ""                        *)
(*  podwojny '' oznacza literalne '                                           *)
(*  podwojny "" oznacza literalne "                                           *)
(*----------------------------------------------------------------------------*)
var len: integer;
    znak, gchr: char;
begin
 Result:='';

 omin_spacje(i,a);
 if not(a[i] in AllowQuotes) then exit;

 gchr:=a[i]; len:=length(a);

 while i<=len do begin
  inc(i);         // omijamy pierwszy znak ' lub "

  znak:=a[i];

  if znak=gchr then begin
   inc(i);
   if a[i]=gchr then znak:=gchr else exit;
  end;

  Result:=Result+znak;
 end;

end;



function ciag_ograniczony(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobiera ciag ograniczony dwoma znakami 'LEWA' i 'PRAWA'                   *)
(*  znaki 'LEWA' i 'PRAWA' moga byc zagniezdzone                              *)
(*----------------------------------------------------------------------------*)
var nawias, len: integer;
    znak, lewa, prawa: char;
    petla: Boolean;
    txt: string;
begin
 Result:='';

 if not(a[i] in ['(']) then exit;

 lewa:=a[i];
 if lewa='(' then prawa:=')' else prawa:=chr(ord(lewa)+2);

 nawias:=0; petla:=true; len:=length(a);

 while petla and (i<=len) do begin

  znak := a[i];

  if znak=lewa then inc(nawias) else
   if znak=prawa then dec(nawias);

//  if not(zag) then
//   if nawias>1 then test_nawias(a,lewa,0);

//  if nawias=0 then petla:=false;
  petla := not(nawias=0);

   if znak in AllowQuotes then begin

   txt:= get_string(i,a);

   Result := Result + znak + txt + znak;

   if txt = znak then Result:=Result + znak;

   end else begin
    Result := Result + znak;
    inc(i)
   end;

 end;

end;


procedure AddString;
var i: integer;
begin

 i:=High(Result);
 Result[i] := s;

 SetLength(Result, i + 2);

 s:='';
end;


begin
 SetLength(Result, 1);

 i:=1;

 len:=length(a);

 s:='';

 while i <= len do

  if a[i]=Sep then begin

   AddString;

   inc(i);

  end else

  case UpCase(a[i]) of
   '(': s:=s + ciag_ograniczony(i,a);

   '''','"':
     begin
      znak:=a[i];

      txt:=get_string(i,a);

      s:=s + znak + txt + znak;

      if znak = txt then s:=s + znak;

     end;

  else
   begin
    s := s + a[i];
    inc(i);
   end;
  end;

 if s <> '' then AddString;

end;


procedure TokenizeProgram(UsesOn: Boolean = true);
var
  Text: string;
  Num, Frac: TString;
  OldNumTok, UnitIndex, IncludeIndex, Line, Err, cnt, Line2, Spaces, TextPos, im, OldNumDefines: Integer;
  Tmp: Int64;
  AsmFound, UsesFound, yes: Boolean;
  ch, ch2: Char;
  CurToken: Byte;
  StrParams: TArrayString;
  fl: double;


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

    if c = LF then Inc(Line);
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


  procedure ReadDirective(d: string; DefineLine: integer);
  var i, v, x: integer;
      cmd, s, nam: string;
      found: Boolean;
      Param: TDefinesParam;


	procedure skip_spaces;
	begin

 	 while d[i] in AllowWhiteSpaces do begin
   	  if d[i] = LF then inc(DefineLine);
 	  inc(i);
  	 end;

	end;


	procedure newMsgUser(Kind: Byte);
	var k: integer;
	begin

		k:=High(msgUser);

		AddToken(Kind, UnitIndex, Line, 1, k); AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

		omin_spacje(i, d);

		msgUser[k] := copy(d, i, length(d)-i);
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

     if cmd = 'MACRO+' then macros:=true else
     if cmd = 'MACRO-' then macros:=false else
     if cmd = 'MACRO' then begin

      s := get_string(i, d);

      if s='ON' then macros:=true else
       if s='OFF' then macros:=false else
        Error(NumTok, 'Wrong switch toggle, use ON/OFF or +/-');

     end else

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
	  UnitName[IncludeIndex].Name := ExtractFileName(nam);
	  UnitName[IncludeIndex].Path := nam;
	  UnitIndex := IncludeIndex;
	  inc(IncludeIndex);

	  Tokenize( nam );

	  Line := _line;
	  UnitIndex := _uidx;

	 end;

	end;

     end else

      if (cmd = 'CODEALIGN') then begin

       s := get_string(i, d);

       if AnsiUpperCase(s) = 'PROC' then AddToken(PROCALIGNTOK, UnitIndex, Line, 1, 0) else
        if AnsiUpperCase(s) = 'LOOP' then AddToken(LOOPALIGNTOK, UnitIndex, Line, 1, 0) else
         if AnsiUpperCase(s) = 'LINK' then AddToken(LINKALIGNTOK, UnitIndex, Line, 1, 0) else
	  Error(NumTok, 'Illegal alignment directive');

       omin_spacje(i, d);

       if d[i] <> '=' then Error(NumTok, 'Illegal alignment directive');
       inc(i);
       omin_spacje(i, d);

	s := get_digit(i, d);

	val(s, v, Err);

	if Err > 0 then
	 iError(NumTok, OrdinalExpExpected);

	GetCommonConstType(NumTok, WORDTOK, GetValueType(v));

	Tok[NumTok].Value := v;

	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0)

      end else

      if (cmd = 'LIBRARYPATH') then begin			// {$librarypath path1;path2;...}
       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       repeat

       s := get_string(i, d);

       AddPath(s);

       if d[i] = ';' then
	inc(i)
       else
	Break;

       until d[i] = ';';

       dec(NumTok);
      end else

      if (cmd = 'R') and not (d[i] in ['+','-']) then begin	// {$R filename}
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

      if (cmd = 'L') or (cmd = 'LINK') then begin		// {$L filename} | {$LINK filename}
       AddToken(LINKTOK, UnitIndex, Line, 1, 0);

       s := LowerCase( get_string(i, d) );

       s := FindFile(s, 'link object');

       v := High(linkObj);
       linkObj[v] := s;

       Tok[NumTok].Value := v;

       SetLength(linkObj, v+2);

       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       //dec(NumTok);
      end else

       if (cmd = 'F') or (cmd = 'FASTMUL') then begin		// {$F [page address]}
	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

	s := get_digit(i, d);

	val(s, FastMul, Err);

	if Err <> 0 then
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

	Err := 0;

	skip_spaces;

	if d[i] = '(' then begin	// macro parameters

	 Param[1] := '';
	 Param[2] := '';
 	 Param[3] := '';
	 Param[4] := '';
	 Param[5] := '';
	 Param[6] := '';
	 Param[7] := '';
	 Param[8] := '';

	 inc(i);
	 skip_spaces;

	 Tok[NumTok].Line := line;

	 if not(UpCase(d[i]) in AllowLabelFirstChars) then
	  Error(NumTok, 'Syntax error, ''identifier'' expected');

	 repeat

	  inc(Err);

          if Err > MAXPARAMS then
	   Error(NumTok, 'Too many formal parameters in ' + nam);

	  Param[Err] := get_label(i, d);

	  for x := 1 to Err - 1 do
	   if Param[x] = Param[Err] then
	    Error(NumTok, 'Duplicate identifier ''' + Param[Err] + '''');

	  skip_spaces;

	  if d[i] = ',' then begin
	   inc(i);
	   skip_spaces;

	   if not(UpCase(d[i]) in AllowLabelFirstChars) then
	    Error(NumTok, 'Syntax error, ''identifier'' expected');
	  end;

	 until d[i] = ')';

	 inc(i);
	 skip_spaces;

	end;


	if (d[i] = ':') and (d[i+1] = '=') then begin
	 inc(i, 2);

	 skip_spaces;

	 AddDefine(nam);		// define macro

	 s:=copy(d, i, length(d));
	 SetLength(s, length(s)-1);

	 Defines[NumDefines].Macro := s;
	 Defines[NumDefines].Line := DefineLine;

	 if Err > 0 then Defines[NumDefines].Param := Param;

	end else
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

   while (ch <> LF) do
     Read(InFile, ch);

  end;


  procedure ReadChar(var c: Char);
  var c2: Char;
      dir: Boolean;
      directive: string;
      _line: integer;
  begin

  Read(InFile, c);

   if c = '(' then begin
    Read(InFile, c2);

    if c2='*' then begin				// Skip comments (*   *)

     repeat
      c2:=c;
      Read(InFile, c);

      if c = LF then Inc(Line);
     until (c2 = '*') and (c = ')');

     Read(InFile, c);

    end else
     Seek(InFile, FilePos(InFile) - 1);

   end;


   if c = '{' then begin

    dir:=false;
    directive:='';

    _line := Line;

    Read(InFile, c2);

    if c2='$' then
     dir:=true
    else
     Seek(InFile, FilePos(InFile) - 1);

    repeat						// Skip comments
      Read(InFile, c);

      if dir then directive := directive + c;

      if c <> '}' then
       if AsmFound then SaveAsmBlock(c);

      if c = LF then Inc(Line);
    until c = '}';

    if dir then ReadDirective(directive, _line);

    Read(InFile, c);

   end else
    if c = '/' then begin
     Read(InFile, c2);

     if c2 = '/' then
      ReadSingleLineComment
     else
      Seek(InFile, FilePos(InFile) - 1);

    end;

  if c = LF then Inc(Line);				// Increment current line number
  end;


  function ReadParameters: String;
  var opn: integer;
  begin

   Result := '(';
   opn:=1;

   while true do begin
    ReadChar(ch);

    if ch = LF then inc(Line);

    if ch = '(' then inc(opn);
    if ch = ')' then dec(opn);

    if not(ch in [CR, LF]) then Result:=Result + ch;

    if (length(Result) > 255) or (opn = 0) then Break;

   end;

   if ch = ')' then ReadChar(ch);

  end;


  procedure SafeReadChar(var c: Char);
  begin

  ReadChar(c);

  c := UpCase(c);

  if c in [' ',TAB] then inc(Spaces);

  if not (c in ['''', ' ', '#', '~', '$', TAB, LF, CR, '{', (*'}',*) 'A'..'Z', '_', '0'..'9', '=', '.', ',', ';', '(', ')', '*', '/', '+', '-', ':', '>', '<', '^', '@', '[', ']']) then
    begin
    CloseFile(InFile);
    Error(NumTok, 'Unknown character: ' + c);
    end;
  end;


  procedure SkipWhiteSpace;				// 'string' + #xx + 'string'
  begin
    SafeReadChar(ch);

    while ch in AllowWhiteSpaces do SafeReadChar(ch);

    if not(ch in ['''','#']) then Error(NumTok, 'Syntax error, ''string'' expected but '''+ ch +''' found');
  end;


  procedure TextInvers(p: integer);
  var i: integer;
  begin

   for i := p to length(Text) do
    if ord(Text[i]) < 128 then
     Text[i] := chr(ord(Text[i])+$80);

  end;


  procedure TextInternal(p: integer);
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


  function cbm(const a: char): byte;
  begin
   Result:=ord(a);

      case a of
       'a'..'z': dec(Result, 96);
       '['..'_': dec(Result, 64);
            '`': Result:=64;
	    '@': Result:=0;
      end;

   end;


  begin

   if target.id = 'a8' then begin

     for i := p to length(Text) do
      Text[i] := chr(ata2int(ord(Text[i])));

   end else begin

     for i := p to length(Text) do
      Text[i] := chr(cbm(Text[i]));

   end;

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

      while ch in ['0'..'9'] do		// Number suspected
	begin
	Num := Num + ch;
	SafeReadChar(ch);
	end;

  end;


  begin

  AssignFile(InFile, fnam );		// UnitIndex = 1 main program

  Reset(InFile);

  Text := '';

  try
    while TRUE do
      begin
      OldNumTok := NumTok;

      repeat
	ReadChar(ch);

	if ch in [' ',TAB] then inc(Spaces);

      until not (ch in [' ',TAB,LF,CR,'{'(*, '}'*)]);    // Skip space, tab, line feed, carriage return, comment braces


      ch := UpCase(ch);


      Num:='';
      if ch in ['0'..'9', '$', '%'] then ReadNumber;

      if Length(Num) > 0 then			// Number found
	begin
	AddToken(INTNUMBERTOK, UnitIndex, Line, length(Num) + Spaces, StrToInt(Num)); Spaces:=0;

	if ch = '.' then			// Fractional part suspected
	  begin
	  SafeReadChar(ch);
	  if ch = '.' then
	    Seek(InFile, FilePos(InFile) - 1)	// Range ('..') token
	  else
	    begin				// Fractional part found
	    Frac := '.';

	    while ch in ['0'..'9'] do
	      begin
	      Frac := Frac + ch;
	      SafeReadChar(ch);
	      end;

	    Tok[NumTok].Kind := FRACNUMBERTOK;

	    if length(Num) > 17 then
	      Tok[NumTok].FracValue := 0
	    else
	      Tok[NumTok].FracValue := StrToFloat(Num + Frac);

	    Tok[NumTok].Column := Tok[NumTok-1].Column + length(Num) + length(Frac) + Spaces; Spaces:=0;
	    end;
	  end;

	Num := '';
	Frac := '';
	end;


      if ch in ['A'..'Z', '_'] then		// Keyword or identifier suspected
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

	 im := SearchDefine(Text);

	 if (im > 0) and (Defines[im].Macro <> '') then begin

	  tmp:=FilePos(InFile);
	  ch2:=ch;
	  Num:='';			// read parameters, max 255 chars

	  if Defines[im].Param[1] <> '' then begin
	    while ch in AllowWhiteSpaces do ReadChar(ch);
	    if ch = '(' then Num := ReadParameters;
	  end;

	  SetLength(StrParams, 1);
	  StrParams[0] := '';

	  Tok[NumTok].Line := Line;

	  if Num = '' then begin
	   Seek(InFile, tmp);
	   ch:=ch2;
	  end else begin
	   StrParams := SplitString(copy(Num, 2, length(Num)-2), ',');

	  if High(StrParams) > MAXPARAMS then
	   Error(NumTok, 'Too many formal parameters in ' + Text);

	  end;

	  if (StrParams[0] <> '') and (Defines[im].Param[1] = '') then
	   Error(NumTok, 'Wrong number of parameters');


	  OldNumDefines := NumDefines;

	  Err:=1;

	  while (Defines[im].Param[Err] <> '') and (Err <= MAXPARAMS) do begin

	   if StrParams[Err - 1] = '' then
	     Error(NumTok, 'Missing parameter');

	   AddDefine(Defines[im].Param[Err]);
	   Defines[NumDefines].Macro := StrParams[Err - 1];
	   Defines[NumDefines].Line := Line;

	   inc(Err);
	  end;


	  TokenizeMacro(Defines[im].Macro, Defines[im].Line, 0);

	  NumDefines := OldNumDefines;

	  CurToken := MACRORELEASE;
	 end else begin

	  if CurToken = TEXTTOK then CurToken := TEXTFILETOK;
	  if CurToken = FLOATTOK then CurToken := SINGLETOK;
	  if CurToken = FLOAT16TOK then CurToken := HALFSINGLETOK;
	  if CurToken = SHORTSTRINGTOK then CurToken := STRINGTOK;

	  AddToken(0, UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;

	 end;


	 if CurToken = ASMTOK then begin

	  Tok[NumTok].Kind := CurToken;
	  Tok[NumTok].Value:= 0;

	  tmp:=FilePos(InFile);

	  repeat
	   Read(InFile, ch);
	   if ch = LF then inc(line);
	  until not(ch in AllowWhiteSpaces);


	  if ch <> '{' then begin

	   Tok[NumTok].Value := 1;

	   Seek(InFile, tmp - 1);

	   Read(InFile, ch);

	   if ch in [CR,LF] then begin			// skip EOL after 'ASM'

	    if ch = LF then inc(line);

	    if ch = CR then Read(InFile, ch);		// CR LF

	    AsmBlock[AsmBlockIndex] := '';
	    Text:='';

	   end else begin
	    AsmBlock[AsmBlockIndex] := ch;
	    Text:=ch;
	   end;


	   while true do begin
	    Read(InFile, ch);

	    SaveAsmBlock(ch);

	    Text:=Text + UpperCase(ch);

	    if pos('END;', Text) > 0 then begin
	      SetLength(AsmBlock[AsmBlockIndex], length(AsmBlock[AsmBlockIndex])-4);

//	      inc(line, AsmBlock[AsmBlockIndex].CountChar(LF));

	      Break;
	    end;

	    if ch in [CR,LF] then begin
	     if ch = LF then inc(line);
	     Text:='';
	    end;

	   end;


	  end else begin

	  Seek(InFile, FilePos(InFile) - 1);

	  AsmFound:=true;

	  repeat
	   ReadChar(ch);

	   if ch in [' ',TAB] then inc(Spaces);

	  until not (ch in [' ',TAB,LF,CR,'{','}']);    // Skip space, tab, line feed, carriage return, comment braces

	  AsmFound:=false;

	  end;

	  inc(AsmBlockIndex);

	  if AsmBlockIndex > High(AsmBlock) then begin
	   Error(NumTok, 'Out of resources, ASMBLOCK');

	   halt(2);
	  end;

	 end else begin

	  if CurToken <> MACRORELEASE then

	   if CurToken <> 0 then begin		// Keyword found
	     Tok[NumTok].Kind := CurToken;

	     if CurToken = USESTOK then UsesFound := true;

	   end
	   else begin				// Identifier found
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
	 yes:=true;

	 repeat

	 case ch of

	  '''': begin

		 if yes then begin
		  TextPos := Length(Text)+1;
		  yes:=false;
		 end;

		 inc(Spaces);

		 repeat
		  Read(InFile, ch);

		  if ch = LF then	//Inc(Line);
		   Error(NumTok, 'String exceeds line');

		  if not(ch in ['''',CR,LF]) then
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

		 inc(Spaces);

		 SafeReadChar(ch);

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=FilePos(InFile);
			while ch2 in [' ',TAB] do Read(InFile, ch2);

			if ch2 in ['*','~','+'] then
			 ch:=ch2
			else
			 Seek(InFile, Err);
		 end;


		 if ch='*' then begin
		  inc(Spaces);
		  TextInvers(TextPos);
		  SafeReadChar(ch);
		 end;

		 if ch='~' then begin
		  inc(Spaces);
		  TextInternal(TextPos);
		  SafeReadChar(ch);

		  if ch='*' then begin
		   inc(Spaces);
		   TextInvers(TextPos);
		   SafeReadChar(ch);
		  end;

		 end;


		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=FilePos(InFile);
			while ch2 in [' ',TAB] do Read(InFile, ch2);

			if ch2 in ['''','+'] then
			 ch:=ch2
			else
			 Seek(InFile, Err);
		 end;


		 if ch='+' then begin
		  yes:=true;
		  inc(Spaces);
		  SkipWhiteSpace;
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

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=FilePos(InFile);
			while ch2 in [' ',TAB] do Read(InFile, ch2);

			if ch2 in ['''','+'] then
			 ch:=ch2
			else
			 Seek(InFile, Err);
		 end;

		 if ch='+' then begin
		  inc(Spaces);
		  SkipWhiteSpace;
		 end;

		end;
	 end;

	 until not (ch in ['#', '''']);

	 case ch of
	  '*': begin TextInvers(TextPos); SafeReadChar(ch) end;			// Invers
	  '~': begin TextInternal(TextPos); SafeReadChar(ch) end;		// Antic
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

Spelling[CONSTTOK	] := 'CONST';
Spelling[TYPETOK	] := 'TYPE';
Spelling[VARTOK		] := 'VAR';
Spelling[PROCEDURETOK	] := 'PROCEDURE';
Spelling[FUNCTIONTOK	] := 'FUNCTION';
Spelling[OBJECTTOK	] := 'OBJECT';
Spelling[PROGRAMTOK	] := 'PROGRAM';
Spelling[LIBRARYTOK	] := 'LIBRARY';
Spelling[EXPORTSTOK	] := 'EXPORTS';
Spelling[EXTERNALTOK	] := 'EXTERNAL';
Spelling[UNITTOK	] := 'UNIT';
Spelling[INTERFACETOK	] := 'INTERFACE';
Spelling[IMPLEMENTATIONTOK] := 'IMPLEMENTATION';
Spelling[INITIALIZATIONTOK] := 'INITIALIZATION';
Spelling[CONSTRUCTORTOK ] := 'CONSTRUCTOR';
Spelling[DESTRUCTORTOK  ] := 'DESTRUCTOR';
Spelling[OVERLOADTOK	] := 'OVERLOAD';
Spelling[ASSEMBLERTOK	] := 'ASSEMBLER';
Spelling[FORWARDTOK	] := 'FORWARD';
Spelling[REGISTERTOK	] := 'REGISTER';
Spelling[INTERRUPTTOK	] := 'INTERRUPT';
Spelling[PASCALTOK	] := 'PASCAL';
Spelling[STDCALLTOK	] := 'STDCALL';
Spelling[INLINETOK      ] := 'INLINE';
Spelling[KEEPTOK        ] := 'KEEP';

Spelling[ASSIGNFILETOK	] := 'ASSIGN';
Spelling[RESETTOK	] := 'RESET';
Spelling[REWRITETOK	] := 'REWRITE';
Spelling[APPENDTOK	] := 'APPEND';
Spelling[BLOCKREADTOK	] := 'BLOCKREAD';
Spelling[BLOCKWRITETOK	] := 'BLOCKWRITE';
Spelling[CLOSEFILETOK	] := 'CLOSE';

Spelling[GETRESOURCEHANDLETOK] := 'GETRESOURCEHANDLE';
Spelling[SIZEOFRESOURCETOK] := 'SIZEOFRESOURCE';


Spelling[FILETOK	] := 'FILE';
Spelling[TEXTFILETOK	] := 'TEXTFILE';
Spelling[SETTOK		] := 'SET';
Spelling[PACKEDTOK	] := 'PACKED';
Spelling[VOLATILETOK	] := 'VOLATILE';
Spelling[LABELTOK	] := 'LABEL';
Spelling[GOTOTOK	] := 'GOTO';
Spelling[INTOK		] := 'IN';
Spelling[RECORDTOK	] := 'RECORD';
Spelling[CASETOK	] := 'CASE';
Spelling[BEGINTOK	] := 'BEGIN';
Spelling[ENDTOK		] := 'END';
Spelling[IFTOK		] := 'IF';
Spelling[THENTOK	] := 'THEN';
Spelling[ELSETOK	] := 'ELSE';
Spelling[WHILETOK	] := 'WHILE';
Spelling[DOTOK		] := 'DO';
Spelling[REPEATTOK	] := 'REPEAT';
Spelling[UNTILTOK	] := 'UNTIL';
Spelling[FORTOK		] := 'FOR';
Spelling[TOTOK		] := 'TO';
Spelling[DOWNTOTOK	] := 'DOWNTO';
Spelling[ASSIGNTOK	] := ':=';
Spelling[WRITETOK	] := 'WRITE';
Spelling[WRITELNTOK	] := 'WRITELN';
Spelling[SIZEOFTOK	] := 'SIZEOF';
Spelling[LENGTHTOK	] := 'LENGTH';
Spelling[HIGHTOK	] := 'HIGH';
Spelling[LOWTOK		] := 'LOW';
Spelling[INTTOK		] := 'INT';
Spelling[FRACTOK	] := 'FRAC';
Spelling[TRUNCTOK	] := 'TRUNC';
Spelling[ROUNDTOK	] := 'ROUND';
Spelling[ODDTOK		] := 'ODD';

Spelling[READLNTOK	] := 'READLN';
Spelling[HALTTOK	] := 'HALT';
Spelling[BREAKTOK	] := 'BREAK';
Spelling[CONTINUETOK	] := 'CONTINUE';
Spelling[EXITTOK	] := 'EXIT';

Spelling[SUCCTOK	] := 'SUCC';
Spelling[PREDTOK	] := 'PRED';

Spelling[INCTOK		] := 'INC';
Spelling[DECTOK		] := 'DEC';
Spelling[ORDTOK		] := 'ORD';
Spelling[CHRTOK		] := 'CHR';
Spelling[ASMTOK		] := 'ASM';
Spelling[ABSOLUTETOK	] := 'ABSOLUTE';
Spelling[USESTOK	] := 'USES';
Spelling[LOTOK		] := 'LO';
Spelling[HITOK		] := 'HI';
Spelling[GETINTVECTOK	] := 'GETINTVEC';
Spelling[SETINTVECTOK	] := 'SETINTVEC';
Spelling[ARRAYTOK	] := 'ARRAY';
Spelling[OFTOK		] := 'OF';
Spelling[STRINGTOK	] := 'STRING';

Spelling[RANGETOK	] := '..';

Spelling[EQTOK		] := '=';
Spelling[NETOK		] := '<>';
Spelling[LTTOK		] := '<';
Spelling[LETOK		] := '<=';
Spelling[GTTOK		] := '>';
Spelling[GETOK		] := '>=';

Spelling[DOTTOK		] := '.';
Spelling[COMMATOK	] := ',';
Spelling[SEMICOLONTOK	] := ';';
Spelling[OPARTOK	] := '(';
Spelling[CPARTOK	] := ')';
Spelling[DEREFERENCETOK	] := '^';
Spelling[ADDRESSTOK	] := '@';
Spelling[OBRACKETTOK	] := '[';
Spelling[CBRACKETTOK	] := ']';
Spelling[COLONTOK	] := ':';

Spelling[PLUSTOK	] := '+';
Spelling[MINUSTOK	] := '-';
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

Spelling[INTEGERTOK	] := 'INTEGER';
Spelling[CARDINALTOK	] := 'CARDINAL';
Spelling[SMALLINTTOK	] := 'SMALLINT';
Spelling[SHORTINTTOK	] := 'SHORTINT';
Spelling[WORDTOK	] := 'WORD';
Spelling[BYTETOK	] := 'BYTE';
Spelling[CHARTOK	] := 'CHAR';
Spelling[BOOLEANTOK	] := 'BOOLEAN';
Spelling[POINTERTOK	] := 'POINTER';
Spelling[SHORTREALTOK	] := 'SHORTREAL';
Spelling[REALTOK	] := 'REAL';
Spelling[SINGLETOK	] := 'SINGLE';
Spelling[HALFSINGLETOK	] := 'FLOAT16';
Spelling[PCHARTOK	] := 'PCHAR';

Spelling[SHORTSTRINGTOK	] := 'SHORTSTRING';
Spelling[FLOATTOK	] := 'FLOAT';
Spelling[TEXTTOK	] := 'TEXT';

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

 if a then asm65;

 asm65('; '+StringOfChar('-',60));

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

	  __addBX: asm65(#9'inx');//, '; add bx, 1');
	  __subBX: asm65(#9'dex');//, '; sub bx, 1');

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

 if (Source in IntegerTypes) and (Dest in IntegerTypes) then begin

 i:=DataSize[Dest] - DataSize[Source];

 if i > 0 then
  case i of
   1: if (Source in SignedOrdinalTypes) then	// to WORD
       asm65(#9'jsr @expandSHORT2SMALL')
      else
       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x', '; expand to WORD');

   2: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD.SMALL')
      else begin
//       asm65(#9'jsr @expandToCARD.WORD');

       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x');
       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x');
      end;

   3: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD.SHORT')
      else begin
//       asm65(#9'jsr @expandToCARD.BYTE');

       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x');
       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x');
       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x');
      end;

  end;

 end;

end;


procedure ExpandParam_m1(Dest, Source: Byte);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 if (Source in IntegerTypes) and (Dest in IntegerTypes) then begin

 i:=DataSize[Dest] - DataSize[Source];

 if i>0 then
  case i of
   1: if (Source in SignedOrdinalTypes) then	// to WORD
       asm65(#9'jsr @expandSHORT2SMALL1')
      else
       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x', '; expand to WORD');

   2: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD1.SMALL')
      else begin
//       asm65(#9'jsr @expandToCARD1.WORD');

       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*2,x');
       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*3,x');
      end;

   3: if (Source in SignedOrdinalTypes) then	// to CARDINAL
       asm65(#9'jsr @expandToCARD1.SHORT')
      else begin
//       asm65(#9'jsr @expandToCARD1.BYTE');

       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x');
       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*2,x');
       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*3,x');
      end;

  end;

 end;

end;


procedure ExpandExpression(var ValType: Byte; RightValType, VarType: Byte; ForceMinusSign: Boolean = false);
var m: Byte;
    sign: Boolean;
begin

 if (ValType in IntegerTypes) and (RightValType in IntegerTypes) then begin

    if (DataSize[ValType] < DataSize[RightValType]) and ((VarType = 0) or (DataSize[RightValType] >= DataSize[VarType])) then begin
      ExpandParam_m1(RightValType, ValType);		// -1
      ValType:=RightValType;				// przyjmij najwiekszy typ dla operacji
    end else begin

      if VarType in Pointers then VarType := WORDTOK;

      m := DataSize[ValType];
      if DataSize[RightValType] > m then m := DataSize[RightValType];

      if VarType = BOOLEANTOK then
        inc(m)						// dla sytuacji np.: boolean := (shortint + shorint > 0)
      else

      if VarType <> 0 then
       if DataSize[VarType] > m then inc(m);		// okreslamy najwiekszy wspolny typ
       //m:=DataSize[VarType];


      if (ValType in SignedOrdinalTypes) or (RightValType in SignedOrdinalTypes) or ForceMinusSign then
       sign := true
      else
       sign := false;

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

 Gen;

end;


procedure ExpandByte;
begin

Gen;

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
    AllocElementType := Types[i].Field[j].AllocElementType;

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

    if AllocElementType = FORWARDTYPE then begin
     AllocElementType := POINTERTOK;
     NumAllocElements := 0;
    end;

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

  asm65;

  case DataSize[ElementType] of
    2: asm65(#9'm@index2 '+IntToStr(Ofset));
    4: asm65(#9'm@index4 '+IntToStr(Ofset));
  end;

end;

(*
procedure GenerateInterrupt(InterruptNumber: Byte);

 DLI     5  ($200)   Wektor przerwan NMI listy displejowej
 VBI     6  ($222)   Wektor NMI natychmiastowego VBI
 VBL     7  ($224)   Wektor NMI opoznionego VBI
 RESET
 IRQ
 BRK

VDSLST $0200 $E7B3 Wektor przerwan NMI listy displejowej
VPRCED $0202 $E7B3 Wektor IRQ procedury pryferyjnej
VINTER $0204 $E7B3 Wektor IRQ urzadzen peryferyjnych
VBREAK $0206 $E7B3 Wektor IRQ programowej instrukcji BRK
VKEYBD $0208 $EFBE Wektor IRQ klawiatury
VSERIN $020A $EB11 Wektor IRQ gotowosci wejscia szeregowego
VSEROR $020C $EA90 Wektor IRQ gotowosci wyjscia szeregowego
VSEROC $020E $EAD1 Wektor IRQ zakonczenia przesylania szereg.
VTIMR1 $0210 $E7B3 Wektor IRQ licznika 1 ukladu POKEY
VTIMR2 $0212 $E7B3 Wektor IRQ licznika 2 ukladu POKEY
VTIMR4 $0214 $E7B3 Wektor IRQ licznika 4 ukladu POKEY

VIMIRQ $0216 $E6F6 Wektor sterownika przerwan IRQ
VVBLKI $0222 $E7D1 Wektor NMI natychmiastowego VBI
VVBLKD $0224 $E93E Wektor NMI opoznionego VBI
CDTMA1 $0226 $XXXX Adres JSR licznika systemowego 1
CDTMA2 $0228 $XXXX Adres JSR licznika systemowego 2
BRKKEY $0236 $E754 Wektor IRQ klawisza BREAK **

begin

end;// GenerateInterrupt
*)


procedure StopOptimization;
begin

 if run_func = 0 then begin

  optimize.use := false;

  if High(OptimizeBuf) > 0 then asm65;

 end;

end;


procedure StartOptimization(i: integer);
begin

  StopOptimization;

  optimize.use := true;
  optimize.unitIndex := Tok[i].UnitIndex;
  optimize.line:= Tok[i].Line;

end;


procedure LoadBP2(IdentIndex: integer; svar: string);
var lab: string;
begin

//  if Ident[IdentIndex].PassMethod then

  if (pos('.', svar) > 0) then begin

	lab:=copy(svar,1,pos('.', svar)-1);

	if Ident[GetIdent(lab)].AllocElementType = RECORDTOK then begin

	 asm65(#9'mwy '+lab+' :bp2');			// !!! koniecznie w ten sposob
							// !!! kolejne optymalizacje podstawia pod :BP2 -> LAB
	 asm65(#9'lda :bp2');
	 asm65(#9'add #' + svar + '-DATAORIGIN');
	 asm65(#9'sta :bp2');
	 asm65(#9'lda :bp2+1');
	 asm65(#9'adc #$00');
	 asm65(#9'sta :bp2+1');

	end else
	 asm65(#9'mwy '+svar+' :bp2');

  end else
	asm65(#9'mwy '+svar+' :bp2');

end;


procedure Push(Value: Int64; IndirectionLevel: Byte; Size: Byte; IdentIndex: integer = 0; par: byte = 0);
var Kind: byte;
    NumAllocElements: cardinal;
    svar, svara, lab: string;
begin

 if IdentIndex > 0 then begin
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

 asm65;
 asm65('; Push' + InfoAboutSize(Size));

case IndirectionLevel of

  ASVALUE:
    begin
    asm65('; as Value $'+IntToHex(Value, 8) + ' ('+IntToStr(Value)+')');
    asm65;

    //Gen($83); Gen($C3); Gen($04);				// add bx, 4
    a65(__addBX);

    Gen; //Gen($C7); Gen($07); GenDWord(Value);			// mov dword ptr [bx], Value
    a65(__movaBX_Value, Value, Kind, Size, IdentIndex);

    end;


  ASPOINTER:
    begin
    asm65('; as Pointer');
    asm65;

    a65(__addBX);

    case Size of
      1: begin
	 Gen;

	 asm65(#9'mva '+svar+ GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin
	 Gen;

  	if (pos('.', svar) > 0) then begin

	lab:=copy(svar,1,pos('.', svar)-1);

	if Ident[GetIdent(lab)].AllocElementType = RECORDTOK then begin

	 asm65(#9'lda '+lab);
	 asm65(#9'ldy '+lab+'+1');
	 asm65(#9'add #' + svar + '-DATAORIGIN');
	 asm65(#9'scc');
	 asm65(#9'iny');
	 asm65(#9'sta'+GetStackVariable(0));
	 asm65(#9'sty'+GetStackVariable(1));
	end else begin
	 asm65(#9'mva '+svar+ GetStackVariable(0));
	 asm65(#9'mva '+svar+'+1' + GetStackVariable(1));
	end;

        end else begin
	 asm65(#9'mva ' + svar + GetStackVariable(0));
	 asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
        end;

	ExpandWord;
	end;

      4: begin
	 Gen;

	 asm65(#9'mva '+svar+ GetStackVariable(0));
	 asm65(#9'mva '+svar+'+1' + GetStackVariable(1));
	 asm65(#9'mva '+svar+'+2' + GetStackVariable(2));
	 asm65(#9'mva '+svar+'+3' + GetStackVariable(3));
	 end;
      end;

    end;


  ASPOINTERTORECORD:
    begin
    asm65('; as Pointer to Record');
    asm65;

    Gen;

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

    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer');	   	// ???
    asm65;

    Gen;

    a65(__addBX);

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+'+svar);	// +lda

//    writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements);

    if pos('.', svar) > 0 then begin

     if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) then
      asm65(#9'mwy '+svar+' :bp2')
     else
      asm65(#9'mwy '+copy(svar,1, pos('.', svar)-1)+' :bp2');

    end else
     asm65(#9'mwy '+svar+' :bp2');


    if pos('.', svar) > 0 then begin

     if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) then
      asm65(#9'ldy #$' + IntToHex(par, 2))
     else
      asm65(#9'ldy #'+svar+'-DATAORIGIN');

    end else
     asm65(#9'ldy #$' + IntToHex(par, 2));

    case Size of
      1: begin

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(3));

	 end;
      end;

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+');	// +lda

    end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');
    asm65;

    Gen;

    case Size of
      1: begin

	 if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+'+svar);	// +lda

	  asm65(#9'lda '+svar);					// pushBYTE
	  asm65(#9'add'+GetStackVariable(0));
	  asm65(#9'tay');
	  asm65(#9'lda '+svar+'+1');
	  asm65(#9'adc'+GetStackVariable(1));
	  asm65(#9'sta :bp+1');
	  asm65(#9'lda (:bp),y');
	  asm65(#9'sta'+GetStackVariable(0));

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+');	// +lda

	 end else begin

	  if Ident[IdentIndex].PassMethod = VARPASSING then begin

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy :STACKORIGIN,x');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(0));

	  end else begin

	   asm65(#9'lda' + GetStackVariable(0));
	   asm65(#9'add #$00');
	   asm65(#9'tay');
	   asm65(#9'lda' + GetStackVariable(1));
	   asm65(#9'adc #$00');
	   asm65(#9'sta' + GetStackVariable(1));

	   asm65(#9'lda '+svara+',y');
	   asm65(#9'sta' + GetStackVariable(0));
// =b'
	  end;

	 end;

	 ExpandByte;
	 end;

      2: begin

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(WORDTOK);

	 asm65;

	 if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

	  asm65(#9'lda '+svar);					// pushWORD
	  asm65(#9'add'+GetStackVariable(0));
	  asm65(#9'sta :bp2');
	  asm65(#9'lda '+svar+'+1');
	  asm65(#9'adc'+GetStackVariable(1));
	  asm65(#9'sta :bp2+1');

	  asm65(#9'ldy #$00');
	  asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	  asm65(#9'iny');
	  asm65(#9'mva (:bp2),y'+GetStackVariable(1));

	 end else begin

	  if Ident[IdentIndex].PassMethod = VARPASSING then begin

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy :STACKORIGIN,x');
	   asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	   asm65(#9'iny');
	   asm65(#9'mva (:bp2),y'+GetStackVariable(1));

	  end else begin

	   asm65(#9'lda' + GetStackVariable(0));
	   asm65(#9'add #$00');
	   asm65(#9'tay');
	   asm65(#9'lda' + GetStackVariable(1));
	   asm65(#9'adc #$00');
	   asm65(#9'sta' + GetStackVariable(1));

	   asm65(#9'lda '+svara+',y');
	   asm65(#9'sta' + GetStackVariable(0));
	   asm65(#9'lda '+svara+'+1,y');
	   asm65(#9'sta' + GetStackVariable(1));
// =w'
	  end;

	 end;

	 ExpandWord;
	 end;

      4: begin

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(CARDINALTOK);

	 asm65;

	 if (NumAllocElements * 4 > 256) or (NumAllocElements in [0,1]) then begin

	  asm65(#9'lda '+svar);					// pushCARD
	  asm65(#9'add'+GetStackVariable(0));
	  asm65(#9'sta :bp2');
	  asm65(#9'lda '+svar+'+1');
	  asm65(#9'adc'+GetStackVariable(1));
	  asm65(#9'sta :bp2+1');

	  asm65(#9'ldy #$00');
	  asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	  asm65(#9'iny');
	  asm65(#9'mva (:bp2),y'+GetStackVariable(1));
	  asm65(#9'iny');
	  asm65(#9'mva (:bp2),y'+GetStackVariable(2));
	  asm65(#9'iny');
	  asm65(#9'mva (:bp2),y'+GetStackVariable(3));

	 end else begin

	  if Ident[IdentIndex].PassMethod = VARPASSING then begin

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy :STACKORIGIN,x');
	   asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	   asm65(#9'iny');
	   asm65(#9'mva (:bp2),y'+GetStackVariable(1));
	   asm65(#9'iny');
	   asm65(#9'mva (:bp2),y'+GetStackVariable(2));
	   asm65(#9'iny');
	   asm65(#9'mva (:bp2),y'+GetStackVariable(3));

	  end else begin

	   asm65(#9'lda' + GetStackVariable(0));
	   asm65(#9'add #$00');
	   asm65(#9'tay');
	   asm65(#9'lda' + GetStackVariable(1));
	   asm65(#9'adc #$00');
	   asm65(#9'sta' + GetStackVariable(1));

	   asm65(#9'lda '+svara+',y');
	   asm65(#9'sta' + GetStackVariable(0));
	   asm65(#9'lda '+svara+'+1,y');
           asm65(#9'sta' + GetStackVariable(1));
	   asm65(#9'lda '+svara+'+2,y');
	   asm65(#9'sta' + GetStackVariable(2));
 	   asm65(#9'lda '+svara+'+3,y');
	   asm65(#9'sta' + GetStackVariable(3));
// =c'
	  end;

	 end;

	 end;
      end;

    end;


ASPOINTERTOARRAYRECORD:
    begin
    asm65('; as Pointer to Array ^Record');
    asm65;

    Gen;

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

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin

	 asm65(#9'mva (:bp2),y'+GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y'+GetStackVariable(3));

	 end;
      end;

    end;

end;// case

end;


procedure SaveToSystemStack(cnt: integer);
var i: integer;
    yes: Boolean;
begin

 asm65;
 asm65('; Save conditional expression');		//at expression stack top onto the system :STACK');

 Gen; Gen; Gen;						// push dword ptr [bx]

 yes:=false;

 if Pass = CODEGENERATIONPASS then
  for i:=High(IFTmpPosStack)-1 downto 0 do
   if IFTmpPosStack[i] = cnt then begin yes:=true; Break end;

 if yes then begin
  asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta :STACKORIGIN,x');
 end;

end;


procedure RestoreFromSystemStack(cnt: integer);
var i: integer;
begin

 //asm65;
 //asm65('; Restore conditional expression');

 Gen; Gen; Gen;						// add bx, 4

 asm65(#9'lda IFTMP_'+IntToHex(cnt, 4));

 if Pass = CALLDETERMPASS then begin
  i:=High(IFTmpPosStack);
  IFTmpPosStack[i]:=cnt;
  SetLength(IFTmpPosStack, i+2);
 end;

end;


procedure RemoveFromSystemStack;
begin
Gen; Gen;						// pop :eax
end;


procedure GenerateFileOpen(IdentIndex: Integer; Code: ioCode; NumParams: integer = 0);
begin

 ResetOpty;

 asm65;
 asm65(#9'txa:pha');

 if IOCheck then
  asm65(#9'sec')
 else
  asm65(#9'clc');

 case Code of

   ioAppend,
   ioOpenRead,
   ioOpenWrite:

	asm65(#9'@openfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code)));

   ioFileMode:

	asm65(#9'@openfile '+Ident[IdentIndex].Name+', MAIN.SYSTEM.FileMode');

   ioClose:

   	asm65(#9'@closefile '+Ident[IdentIndex].Name);

 end;

 asm65(#9'pla:tax');
 asm65;

end;


procedure GenerateFileRead(IdentIndex: Integer; Code: ioCode; NumParams: integer = 0);
begin

 ResetOpty;

 asm65;
 asm65(#9'txa:pha');

 if IOCheck then
  asm65(#9'sec')
 else
  asm65(#9'clc');

 case Code of

   ioRead,
   ioWrite,
   ioReadRecord,
   ioWriteRecord:

	if NumParams = 3 then
	  asm65(#9'@readfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code) or $80))
	else
	  asm65(#9'@readfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code)));

 end;

 asm65(#9'pla:tax');
 asm65;

end;


procedure GenerateIncOperation(IndirectionLevel: Byte; ExpressionType: Byte; Down: Boolean; IdentIndex: integer);
var b,c, svar, svara: string;
    NumAllocElements: cardinal;
begin

 //svar := GetLocalName(IdentIndex);
 //NumAllocElements := Elements(IdentIndex);

 if IdentIndex > 0 then begin

  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   NumAllocElements := 0;
  end else
   NumAllocElements := Elements(IdentIndex); //Ident[IdentIndex].NumAllocElements;

  svar := GetLocalName(IdentIndex);

 end else begin
  NumAllocElements := 0;
  svar := '';
 end;

 svara := svar;
 if pos('.', svar) > 0 then
  svara:=GetLocalName(IdentIndex, 'adr.')
 else
  svara:='adr.'+svar;


 if Down then begin
  asm65;
  asm65('; Dec(var X [ ; N: int ] ) -> '+InfoAboutToken(ExpressionType));

//  a:='sbb';
  b:='sub';
  c:='sbc';

 end else begin
  asm65;
  asm65('; Inc(var X [ ; N: int ] ) -> '+InfoAboutToken(ExpressionType));

//  a:='adb';
  b:='add';
  c:='adc';

 end;

 case IndirectionLevel of

  ASPOINTER:
	begin
             asm65('; as Pointer');
             asm65;

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

	   asm65('; as Pointer To Pointer');
	   asm65;

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy #$00');

	     case DataSize[ExpressionType] of
	      1: begin
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      2: begin
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+b+' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9+c+' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      4: begin
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

	     asm65('; as Pointer To Array Origin');
	     asm65;

	     case DataSize[ExpressionType] of
	      1: begin

		  if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

		   asm65(#9'lda '+svar);
		   asm65(#9'add :STACKORIGIN-1,x');
		   asm65(#9'tay');

		   asm65(#9'lda '+svar+'+1');
		   asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		   asm65(#9'sta :bp+1');

		   asm65;
		   asm65(#9'lda (:bp),y');
		   asm65(#9+b+' :STACKORIGIN,x');
		   asm65(#9'sta (:bp),y');

		  end else begin

		   if Ident[IdentIndex].PassMethod = VARPASSING then begin
		    LoadBP2(IdentIndex, svar);

		    asm65(#9'ldy :STACKORIGIN-1,x');
		    asm65(#9'lda (:bp2),y');
		    asm65(#9+b+' :STACKORIGIN,x');
		    asm65(#9'sta (:bp2),y');
		   end else begin
{
		    asm65(#9'ldy :STACKORIGIN-1,x');
		    asm65(#9'lda '+svara+',y');
		    asm65(#9+b+' :STACKORIGIN,x');
		    asm65(#9'sta '+svara+',y');
}
		    asm65(#9'lda <'+svara);
		    asm65(#9'add :STACKORIGIN-1,x');
		    asm65(#9'tay');

		    asm65(#9'lda >'+svara);
		    asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		    asm65(#9'sta :bp+1');

		    asm65(#9'lda (:bp),y');
		    asm65(#9+b+' :STACKORIGIN,x');
		    asm65(#9'sta (:bp),y');

		   end;

		  end;

		 end;

	      2: if Ident[IdentIndex].PassMethod = VARPASSING then begin

		  LoadBP2(IdentIndex, svar);

		  asm65(#9'lda :bp2');
		  asm65(#9'add :STACKORIGIN-1,x');
		  asm65(#9'sta :bp2');
		  asm65(#9'lda :bp2+1');
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

	      	 end else begin
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

	      4: if Ident[IdentIndex].PassMethod = VARPASSING then begin

		  LoadBP2(IdentIndex, svar);

		  asm65(#9'lda :bp2');
		  asm65(#9'add :STACKORIGIN-1,x');
		  asm65(#9'sta :bp2');
		  asm65(#9'lda :bp2+1');
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

	      	 end else begin
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


  procedure LoadRegisterY;
  begin

    if ParamY <> '' then
     asm65(#9'ldy #' + ParamY)
    else
     if pos('.', Ident[IdentIndex].Name) > 0 then begin

       if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) then
        asm65(#9'ldy #$00')
       else
        asm65(#9'ldy #' + svar + '-DATAORIGIN');

     end else
      asm65(#9'ldy #$00');

  end;


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

 asm65;
 asm65('; Generate Assignment for'+InfoAboutSize(Size));

 Gen; Gen; Gen;					// mov :eax, [bx]

case IndirectionLevel of

  ASPOINTERTOARRAYRECORD:
    begin
    asm65('; as Pointer to Array ^Record');


  if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

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

   end else begin

     asm65(#9'ldy :STACKORIGIN-1,x');
     asm65(#9'lda adr.'+svar+',y');
     asm65(#9'sta :bp2');
     asm65(#9'lda adr.'+svar+'+1,y');
     asm65(#9'sta :bp2+1');

   end;

{
    if ParamY<>'' then
     asm65(#9'ldy #'+ParamY)
    else
     if pos('.', Ident[IdentIndex].Name) > 0 then
      asm65(#9'ldy #'+svar+'-DATAORIGIN')
     else
      asm65(#9'ldy #$00');
}

    LoadRegisterY;

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


 ASPOINTERTODEREFERENCE:
    begin
    asm65('; as Pointer to Dereference');

    asm65(#9'lda :STACKORIGIN-1,x');
    asm65(#9'sta :bp2');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'sta :bp2+1');

{
    if ParamY<>'' then
     asm65(#9'ldy #'+ParamY)
    else
     if pos('.', Ident[IdentIndex].Name) > 0 then
      asm65(#9'ldy #'+svar+'-DATAORIGIN')
     else
      asm65(#9'ldy #$00');
}
    LoadRegisterY;

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


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');

    case Size of
      1: begin

	 if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('-'+svar);	// -sta

	  asm65(#9'lda '+svar);
	  asm65(#9'add :STACKORIGIN-1,x');
	  asm65(#9'tay');
	  asm65(#9'lda '+svar+'+1');
	  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	  asm65(#9'sta :bp+1');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp),y');

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('-');	// -sta

	 end else begin

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  LoadBP2(IdentIndex, svar);

	  asm65(#9'ldy :STACKORIGIN-1,x');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp2),y');

	 end else begin

	  asm65(#9'lda :STACKORIGIN-1,x');
	  asm65(#9'add #$00');
	  asm65(#9'tay');
	  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	  asm65(#9'adc #$00');
	  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta '+svara+',y');
// =b'
	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);
	 end;

      2: begin

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(WORDTOK, 1);

	 if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

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

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  LoadBP2(IdentIndex, svar);

	  asm65(#9'ldy :STACKORIGIN-1,x');
	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta (:bp2),y');
	  asm65(#9'iny');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta (:bp2),y');

	 end else begin

	  asm65(#9'lda :STACKORIGIN-1,x');
	  asm65(#9'add #$00');
	  asm65(#9'tay');
	  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	  asm65(#9'adc #$00');
	  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta '+svara+',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta '+svara+'+1,y');
// w='
	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);

	 end;

      4: begin

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	  GenerateIndexShift(CARDINALTOK, 1);

	 if (NumAllocElements * 4 > 256) or (NumAllocElements in [0,1]) then begin

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

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  LoadBP2(IdentIndex, svar);

          asm65(#9'ldy :STACKORIGIN-1,x');
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

	  asm65(#9'lda :STACKORIGIN-1,x');
	  asm65(#9'add #$00');
	  asm65(#9'tay');
	  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	  asm65(#9'adc #$00');
	  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta '+svara+',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta '+svara+'+1,y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	  asm65(#9'sta '+svara+'+2,y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	  asm65(#9'sta '+svara+'+3,y');
// c='
	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);

	 end;
      end;
    end;



  ASSTRINGPOINTERTOARRAYORIGIN:
    begin
    asm65('; as StringPointer to Array Origin');

    case Size of

      2: begin

	 if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

	 asm65(#9'lda '+svar);
	 asm65(#9'add :STACKORIGIN-1,x');
	 asm65(#9'sta :bp2');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	 asm65(#9'sta :bp2+1');

	 asm65(#9'ldy #$00');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta @move.dst');
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta @move.dst+1');

	 end else begin

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

	  LoadBP2(IdentIndex, svar);

	  asm65(#9'ldy :STACKORIGIN-1,x');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta @move.dst');
	  asm65(#9'iny');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta @move.dst+1');

	 end else begin

	  asm65(#9'lda :STACKORIGIN-1,x');
	  asm65(#9'add #$00');
	  asm65(#9'tay');
	  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	  asm65(#9'adc #$00');
	  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	  asm65(#9'lda '+svara+',y');
	  asm65(#9'sta @move.dst');
	  asm65(#9'lda '+svara+'+1,y');
	  asm65(#9'sta @move.dst+1');

	 end;

	 end;

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta @move.src');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta @move.src+1');

	  if Ident[IdentIndex].NestedNumAllocElements > 0 then begin

	   asm65(#9'lda <' + IntToStr(Ident[IdentIndex].NestedNumAllocElements));
	   asm65(#9'sta @move.cnt');
	   asm65(#9'lda >' + IntToStr(Ident[IdentIndex].NestedNumAllocElements));
	   asm65(#9'sta @move.cnt+1');

	   asm65(#9'.nowarn @move');

	   if Ident[IdentIndex].NestedNumAllocElements < 256 then begin
	    asm65(#9'ldy #$00');
	    asm65(#9'lda #' + IntToStr(Ident[IdentIndex].NestedNumAllocElements-1));
	    asm65(#9'cmp (@move.src),y');
	    asm65(#9'scs');
	    asm65(#9'sta (@move.dst),y');
	   end;

	  end else begin

	   asm65(#9'ldy #$00');
	   asm65(#9'lda (@move.src),y');
	   asm65(#9'add #1');
	   asm65(#9'sta @move.cnt');
	   asm65(#9'scc');
	   asm65(#9'iny');
	   asm65(#9'sty @move.cnt+1');

	   asm65(#9'.nowarn @move');

	  end;

	 a65(__subBX);
	 a65(__subBX);

	 end;
      end;
    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer');

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('-'+svar);	// -sta

//  writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

    if pos('.', svar) > 0 then begin

     if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) then
      asm65(#9'mwy ' + svar + ' :bp2')
     else
      asm65(#9'mwy '+copy(svar, 1, pos('.', svar)-1)+' :bp2');

    end else
     asm65(#9'mwy ' + svar + ' :bp2');

{
    if ParamY<>'' then
     asm65(#9'ldy #'+ParamY)
    else
     if pos('.', Ident[IdentIndex].Name) > 0 then begin

       if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) then
        asm65(#9'ldy #$00')
       else
        asm65(#9'ldy #' + svar + '-DATAORIGIN');

     end else
      asm65(#9'ldy #$00');
}

    LoadRegisterY;

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

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('-');	// -sta

     a65(__subBX);

    end;


  ASPOINTER:
    begin
    asm65('; as Pointer');

     case Size of
      1: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta '+svar);
	 end;

      2: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta '+svar);
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta '+svar+'+1');
	 end;

      4: begin
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta '+svar);
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta '+svar+'+1');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	 asm65(#9'sta '+svar+'+2');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	 asm65(#9'sta '+svar+'+3');
	 end;
      end;

     a65(__subBX);

    end;

end;// case

StopOptimization;

end;


procedure GenerateReturn(IsFunction, isInt, isInl: Boolean);
var yes: Boolean;
begin
 Gen;						// ret

 yes:=true;

 if not isInt then
  if not IsFunction then begin
   asm65('@exit');

   if not isInl then begin
   asm65(#9'.ifdef @new');			// @FreeMem
   asm65(#9'lda <@VarData');
   asm65(#9'sta :ztmp');
   asm65(#9'lda >@VarData');
   asm65(#9'ldy #@VarDataSize-1');
   asm65(#9'jmp @FreeMem');
   asm65(#9'els');
   asm65(#9'rts', '; ret');
   asm65(#9'eif');
   end;

   yes:=false;
  end;

 if yes and (isInl = false) then
  if isInt then
   asm65(#9'rti', '; ret')
  else
   asm65(#9'rts', '; ret');

 asm65('.endl');

end;


procedure GenerateIfThenCondition;
begin
asm65;
asm65('; If Then Condition');

Gen; Gen; Gen;								// mov :eax, [bx]

a65(__subBX);
asm65(#9'lda :STACKORIGIN+1,x');

//Gen($75); Gen($03);							// jne +3
a65(__jne);
end;


procedure GenerateElseCondition;
begin
//asm65;
//asm65('; else condition');

Gen; Gen; Gen;								// mov :eax, [bx]

//Gen($74); Gen($03);							// je  +3
a65(__je);

end;


{$IFDEF WHILEDO}

procedure GenerateWhileDoCondition;
begin

 GenerateIfThenCondition;

end;

{$ENDIF}


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


procedure GenerateForToDoCondition(ValType: Byte; Down: Boolean; IdentIndex: integer);
var svar: string;
    CounterSize: Byte;
begin

svar := GetLocalName(IdentIndex);
CounterSize := DataSize[ValType];

asm65(';' + InfoAboutSize(CounterSize));

Gen; Gen; Gen;						// mov :ecx, [bx]

a65(__subBX);

case CounterSize of

  1: begin
     ExpandByte;

     if ValType = SHORTINTTOK then begin		// @cmpFor_SHORTINT

       asm65(#9'lda '+svar);
       asm65(#9'sub :STACKORIGIN+1,x');
       asm65(#9'svc');
       asm65(#9'eor #$80');

     end else begin

       asm65(#9'lda '+svar);
       asm65(#9'cmp :STACKORIGIN+1,x');

     end;

     end;

  2: begin
     ExpandWord;

     if ValType = SMALLINTTOK then begin		// @cmpFor_SMALLINT

       asm65(#9'.LOCAL');
       asm65(#9'lda '+svar+'+1');
       asm65(#9'sub :STACKORIGIN+1+STACKWIDTH,x');
       asm65(#9'bne L4');
       asm65(#9'lda '+svar);
       asm65(#9'cmp :STACKORIGIN+1,x');
       asm65('L1'#9'beq L5');
       asm65(#9'bcs L3');
       asm65(#9'lda #$FF');
       asm65(#9'bne L5');
       asm65('L3'#9'lda #$01');
       asm65(#9'bne L5');
       asm65('L4'#9'bvc L5');
       asm65(#9'eor #$FF');
       asm65(#9'ora #$01');
       asm65('L5');
       asm65(#9'.ENDL');

     end else begin

       asm65(#9'lda '+svar+'+1');
       asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
       asm65(#9'bne @+');
       asm65(#9'lda '+svar);
       asm65(#9'cmp :STACKORIGIN+1,x');
       asm65('@');

     end;

     end;

  4: begin

     if ValType = INTEGERTOK then begin			// @cmpFor_INT

       asm65(#9'.LOCAL');
       asm65(#9'lda '+svar+'+3');
       asm65(#9'sub :STACKORIGIN+1+STACKWIDTH*3,x');
       asm65(#9'bne L4');
       asm65(#9'lda '+svar+'+2');
       asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
       asm65(#9'bne L1');
       asm65(#9'lda '+svar+'+1');
       asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
       asm65(#9'bne L1');
       asm65(#9'lda '+svar);
       asm65(#9'cmp :STACKORIGIN+1,x');
       asm65('L1'#9'beq L5');
       asm65(#9'bcs L3');
       asm65(#9'lda #$FF');
       asm65(#9'bne L5');
       asm65('L3'#9'lda #$01');
       asm65(#9'bne L5');
       asm65('L4'#9'bvc L5');
       asm65(#9'eor #$FF');
       asm65(#9'ora #$01');
       asm65('L5');
       asm65(#9'.ENDL');

     end else begin

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


procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: Byte; Join: Boolean; CaseLocalCnt: integer);
begin
//asm65;
//asm65('; GenerateCaseEqualityCheck');

Gen; Gen;							// cmp :ecx, Value

case DataSize[SelectorType] of

 1: if join=false then begin
//      asm65(#9'lda :STACKORIGIN+1,x');
      asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));
      if Value <> 0 then asm65(#9'cmp #$'+IntToHex(byte(Value),2));
    end else
      asm65(#9'cmp #$'+IntToHex(byte(Value),2));

// 2: asm65(#9'cpw :STACKORIGIN,x #$'+IntToHex(Value, 4));
// 4: asm65(#9'cpd :STACKORIGIN,x #$'+IntToHex(Value, 4));
end;

asm65(#9'beq @+');

end;


procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: Byte; Join: Boolean; CaseLocalCnt: integer);
begin
Gen; Gen;							// cmp :ecx, Value1

 if (SelectorType in [BYTETOK, CHARTOK, ENUMTYPE]) and (Value1 >= 0) and (Value2 >= 0) then begin

   if (Value1 = 0) and (Value2 = 255) then begin
//    asm65;
    asm65(#9'jmp @+');
   end else
   if Value1 = 0 then begin
//	    asm65;
    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

    if Value2 = 127 then
     asm65(#9'bpl @+')
    else begin
     asm65(#9'cmp #$' + IntToHex(Value2 + 1,2));
     asm65(#9'bcc @+');
    end;

   end else
   if Value2 = 255 then begin
//    asm65;
    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

    if Value1 = 128 then
     asm65(#9'bmi @+')
    else begin
     asm65(#9'cmp #$' + IntToHex(Value1,2));
     asm65(#9'bcs @+');
    end;

   end else
   if Value1 = Value2 then begin
//    asm65;
    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));
    asm65(#9'cmp #$' + IntToHex(Value1,2));
    asm65(#9'beq @+');
   end else begin
//    asm65;
    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));
    asm65(#9'clc', '; clear carry for add');
    asm65(#9'adc #$FF-$'+IntToHex(Value2,2), '; make m = $FF');
    asm65(#9'adc #$'+IntToHex(Value2,2)+'-$'+IntToHex(Value1,2)+'+1', '; carry set if in range n to m');
    asm65(#9'bcs @+');
   end;

 end else begin

  case DataSize[SelectorType] of
   1: begin
       if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));
       asm65(#9'cmp #'+IntToStr(byte(Value1)));
      end;

  end;

  GenerateRelationOperation(LTTOK, SelectorType);

  case DataSize[SelectorType] of
   1: begin
//       asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));
       asm65(#9'cmp #'+IntToStr(byte(Value2)));
      end;

  end;

  GenerateRelationOperation(GTTOK, SelectorType);

  asm65(#9'jmp *+6');
  asm65('@');

 end;

end;


procedure GenerateCaseStatementProlog;
begin

GenerateIfThenProlog;

end;


procedure GenerateCaseStatementEpilog(cnt: integer);
var StoredCodeSize: Integer;
begin
asm65;
//asm65('; GenerateCaseStatementEpilog');

asm65(#9'jmp a_'+IntToHex(cnt,4));

StoredCodeSize := CodeSize;

Gen;								// nop   ; jump to the CASE block end will be inserted here
Gen;								// nop
Gen;								// nop

asm65('l_'+IntToHex(CodePosStack[CodePosStackTop] + 3, 4));

resetOpty;

Gen;

CodePosStack[CodePosStackTop] := StoredCodeSize;

end;


procedure GenerateCaseEpilog(NumCaseStatements: Integer; cnt: integer);
begin

resetOpty;

//asm65;
//asm65('; GenerateCaseEpilog');

Dec(CodePosStackTop, NumCaseStatements);

if not OutputDisabled then Inc(CodeSize, NumCaseStatements);

asm65('a_'+IntToHex(cnt, 4));

end;


procedure GenerateAsmLabels(l: integer);
var i: integer;
//    ok: Boolean;
begin

if not OutputDisabled then
 if Pass = CODEGENERATIONPASS then begin

//   ok:=false;
   for i:=0 to High(AsmLabels)-1 do
     if AsmLabels[i]=l then exit;// begin ok:=true; Break end;

//   if not ok then begin
    i:=High(AsmLabels);
    AsmLabels[i] := l;

    SetLength(AsmLabels, i+2);

    asm65('l_'+IntToHex(l, 4));
//   end;

 end;

end;


procedure GenerateIfThenEpilog;
var CodePos: Word;
begin

 ResetOpty;

// asm65(#13#10'; IfThenEpilog');

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

GenerateAsmLabels(CodePos+3);

end;


procedure GenerateRepeatUntilProlog;
begin

 Inc(CodePosStackTop);
 CodePosStack[CodePosStackTop] := CodeSize;

 GenerateAsmLabels(CodeSize);

end;


procedure GenerateRepeatUntilEpilog;
var ReturnPos: Word;
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


procedure GenerateForToDoEpilog (ValType: Byte; Down: Boolean; IdentIndex: integer = 0; Epilog: Boolean = true; forBPL: byte = 0);
var svar: string;
    CounterSize: Byte;
begin

svar := GetLocalName(IdentIndex);
CounterSize := DataSize[ValType];

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
   1: asm65(#9'dec ' + svar);

   2: begin
	asm65(#9'lda ' + svar);
	asm65(#9'bne @+');

	asm65(#9'dec ' + svar + '+1');
	asm65('@');
	asm65(#9'dec ' + svar);
      end;

   4: begin
	asm65(#9'lda ' + svar);
	asm65(#9'bne @+1');

	asm65(#9'lda ' + svar + '+1');
	asm65(#9'bne @+');

	asm65(#9'lda ' + svar + '+2');
	asm65(#9'sne');
	asm65(#9'dec ' + svar + '+3');
	asm65(#9'dec ' + svar + '+2');
	asm65('@');
	asm65(#9'dec ' + svar + '+1');
	asm65('@');
	asm65(#9'dec ' + svar);
      end;

  end;

end else begin
  Gen;							// inc ...

  case CounterSize of
   1: asm65(#9'inc ' + svar);

   2: begin
       asm65(#9'inc ' + svar);				// dla optymalizacji z 'JMP L_xxxx'
       asm65(#9'sne');
       asm65(#9'inc ' + svar + '+1');
      end;

   4: begin
	asm65(#9'inc ' + svar);
	asm65(#9'bne @+');
	asm65(#9'inc ' + svar + '+1');
	asm65(#9'bne @+');
	asm65(#9'inc ' + svar + '+2');
	asm65(#9'bne @+');
	asm65(#9'inc ' + svar + '+3');
	asm65('@');
      end;

  end;

end;

Gen; Gen;						// ... [CounterAddress]

if Epilog then begin

 if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then begin

  case CounterSize of
   1: begin

       if Down then begin
        asm65(#9'lda '+svar);
        asm65(#9'cmp #$7f');
        asm65(#9'seq');
       end else begin
        asm65(#9'lda '+svar);
        asm65(#9'cmp #$80');
        asm65(#9'seq');
       end;

      end;
{
   2: begin
      end;

   4: begin
      end;
}

  end;

 end else
 if Down then begin					// for label = exp to max(type)

  case CounterSize of

   1: if forBPL and 1 <> 0 then		// [BYTE < 128] DOWNTO 0
	asm65(#9'bmi *+5')
      else
      if forBPL and 2 <> 0 then		// BYTE DOWNTO [exp > 0]
	asm65(#9'seq')
      else begin
        asm65(#9'lda '+svar);
        asm65(#9'cmp #$FF');
        asm65(#9'seq');
      end;

   2: begin
       asm65(#9'lda '+svar+'+1');
       asm65(#9'cmp #$FF');
       asm65(#9'seq');
      end;

   4: begin
       asm65(#9'lda '+svar+'+3');
       asm65(#9'cmp #$FF');
       asm65(#9'seq');
      end;
  end;

 end else begin

  asm65(#9'seq');

 end;

 GenerateWhileDoEpilog;
end;

end;


function CompilerTitle: string;
begin

 Result := 'Mad Pascal Compiler version '+title+' ['+{$I %DATE%}+'] for 6502';

end;


{$i targets/generate_program_prolog.inc}


procedure GenerateProgramEpilog(ExitCode: byte);
begin
Gen; Gen;							// mov ah, 4Ch

asm65(#9'lda #$'+IntToHex(ExitCode, 2));
asm65(#9'jmp @halt');

end;


procedure GenerateDeclarationProlog;
begin
Inc(CodePosStackTop);
CodePosStack[CodePosStackTop] := CodeSize;

Gen;								// nop   ; jump to the IF..THEN block end will be inserted here
Gen;								// nop
Gen;								// nop

asm65(#9'jmp l_'+IntToHex(CodeSize, 4));

end;


procedure GenerateDeclarationEpilog;
begin
 GenerateIfThenEpilog;
end;


procedure GenerateRead;//(Value: Int64);
begin
// Gen; Gen;							// mov bp, [bx]

 asm65(#9'@getline');

end;// GenerateRead


procedure GenerateWriteString(Address: Word; IndirectionLevel: byte; ValueType: byte = INTEGERTOK);
begin

asm65;

//Gen; Gen;							// mov ah, 09h

case IndirectionLevel of

  ASBOOLEAN:
    begin
     asm65(#9'jsr @printBOOLEAN');

//     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASCHAR:
    begin
     asm65(#9'@printCHAR');

//     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASSHORTREAL:
    begin
     asm65(#9'jsr @printSHORTREAL');

//     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASREAL:
    begin
     asm65(#9'jsr @printREAL');

//     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASSINGLE:
    begin
      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @FTOA.I');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @FTOA.I+1');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
      asm65(#9'sta @FTOA.I+2');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
      asm65(#9'sta @FTOA.I+3');

//      Gen; Gen; Gen;						// sub bx, 4
      a65(__subBX);

      asm65(#9'jsr @FTOA');
    end;

  ASHALFSINGLE:
    begin
//     asm65(#9'jsr @f16toa');

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @F16_F2A.I');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @F16_F2A.I+1');

//      Gen; Gen; Gen;						// sub bx, 4
      a65(__subBX);

      asm65(#9'jsr @F16_F2A');
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

//     Gen; Gen; Gen;						// sub bx, 4
     a65(__subBX);
    end;

  ASPOINTER:
    begin
//    Gen; //Gen(Lo(Address)); Gen(Hi(Address));			// mov dx, Address

    asm65(#9'@printSTRING #CODEORIGIN+$'+IntToHex(Address - CODEORIGIN, 4));

//    a65(__subBX);   !!!   bez DEX-a
    end;

  ASPOINTERTOPOINTER:
    begin
//    Gen; Gen; //Gen(Lo(Address)); Gen(Hi(Address));		// mov dx, [Address]

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'jsr @printSTRING');
    a65(__subBX);
    end;


  ASPCHAR:
    begin
//    Gen; Gen; //Gen(Lo(Address)); Gen(Hi(Address));		// mov dx, [Address]

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

    if ValType = HALFSINGLETOK then begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'eor #$80');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

    end else
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

asm65;
asm65('; Generate Binary Operation for '+InfoAboutToken(ResultType));

Gen; Gen; Gen;							// mov :ecx, [bx]      :STACKORIGIN,x

case op of

  PLUSTOK:
    begin

     if ResultType = HALFSINGLETOK then begin

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_ADD.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_ADD.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_ADD.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_ADD.A+1');

	asm65(#9'jsr @F16_ADD');

	asm65(#9'lda :eax');
	asm65(#9'sta :STACKORIGIN-1,x');
	asm65(#9'lda :eax+1');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

     end else
     if ResultType = SINGLETOK then
       asm65(#9'jsr @FSUB.FADD')
     else

     case DataSize[ResultType] of
       1: a65(__addAL_CL);
       2: a65(__addAX_CX);
       4: a65(__addEAX_ECX);
     end;

    end;

  MINUSTOK:
    begin

    if ResultType = HALFSINGLETOK then begin

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_SUB.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_SUB.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_SUB.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_SUB.A+1');

	asm65(#9'jsr @F16_SUB');

	asm65(#9'lda :eax');
	asm65(#9'sta :STACKORIGIN-1,x');
	asm65(#9'lda :eax+1');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

    end else
    if ResultType = SINGLETOK then
      asm65(#9'jsr @FSUB')
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

       SHORTREALTOK: //asm65(#9'jsr @SHORTREAL_MUL');	// Q8.8 fixed-point
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @SHORTREAL_MUL.B');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @SHORTREAL_MUL.B+1');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @SHORTREAL_MUL.A');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @SHORTREAL_MUL.A+1');

		asm65(#9'jsr @SHORTREAL_MUL');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end;

	    REALTOK: //asm65(#9'jsr @REAL_MUL'); 		// Q24.8 fixed-point
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @REAL_MUL.B');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @REAL_MUL.B+1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta @REAL_MUL.B+2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta @REAL_MUL.B+3');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @REAL_MUL.A');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @REAL_MUL.A+1');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'sta @REAL_MUL.A+2');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
		asm65(#9'sta @REAL_MUL.A+3');

		asm65(#9'jsr @REAL_MUL');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'lda :eax+2');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'lda :eax+3');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end;

	  SINGLETOK: asm65(#9'jsr @FMUL');		// IEEE754 32bit

      HALFSINGLETOK:					// IEEE754 16bit
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @F16_MUL.B');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @F16_MUL.B+1');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @F16_MUL.A');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @F16_MUL.A+1');

		asm65(#9'jsr @F16_MUL');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end;

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

//       asm65(#9'jsr movaBX_EAX');

       if DataSize[ResultType] = 1 then begin

	asm65(#9'lda :eax');
	asm65(#9'sta :STACKORIGIN-1,x');
	asm65(#9'lda :eax+1');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

       end else begin

	asm65(#9'lda :eax');
	asm65(#9'sta :STACKORIGIN-1,x');
	asm65(#9'lda :eax+1');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'lda :eax+2');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'lda :eax+3');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

       end;

      end;

      end;

    end;

  DIVTOK, IDIVTOK, MODTOK:
    begin

    if ResultType in RealTypes then begin	// Real division

//      Gen; Gen; Gen;				// mov edx, :eax

      case ResultType of
       SHORTREALTOK: //asm65(#9'jsr @SHORTREAL_DIV');		// Q8.8 fixed-point
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @SHORTREAL_DIV.B');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @SHORTREAL_DIV.B+1');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @SHORTREAL_DIV.A');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @SHORTREAL_DIV.A+1');

		asm65(#9'jsr @SHORTREAL_DIV');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end;

	    REALTOK: //asm65(#9'jsr divmulINT.REAL');		// Q24.8 fixed-point
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @REAL_DIV.B');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @REAL_DIV.B+1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta @REAL_DIV.B+2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta @REAL_DIV.B+3');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @REAL_DIV.A');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @REAL_DIV.A+1');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'sta @REAL_DIV.A+2');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
		asm65(#9'sta @REAL_DIV.A+3');

		asm65(#9'jsr @REAL_DIV');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'lda :eax+2');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'lda :eax+3');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end;

	  SINGLETOK: asm65(#9'jsr @FDIV');			// IEEE754 32bit

      HALFSINGLETOK:						// IEEE754 16bit
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @F16_DIV.B');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @F16_DIV.B+1');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @F16_DIV.A');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @F16_DIV.A+1');

		asm65(#9'jsr @F16_DIV');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end;
      end;

    end

    else					// Integer division
      begin
//      Gen;

      if ResultType in SignedOrdinalTypes then begin

	case ResultType of

	 SHORTINTTOK:
	 	if op = MODTOK then begin
//		        asm65(#9'jsr SHORTINTTOK.MOD')

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @SHORTINT.MOD.B');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @SHORTINT.MOD.A');

			asm65(#9'jsr @SHORTINT.MOD');

			asm65(#9'lda @SHORTINT.MOD.RESULT');
			asm65(#9'sta :STACKORIGIN-1,x');

		end else begin
//		        asm65(#9'jsr @SHORTINTTOK.DIV');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @SHORTINT.DIV.B');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @SHORTINT.DIV.A');

			asm65(#9'jsr @SHORTINT.DIV');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');

		end;


	 SMALLINTTOK:
		if op = MODTOK then begin
//		        asm65(#9'jsr @SMALLINT.MOD')

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @SMALLINT.MOD.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @SMALLINT.MOD.B+1');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @SMALLINT.MOD.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @SMALLINT.MOD.A+1');

			asm65(#9'jsr @SMALLINT.MOD');

			asm65(#9'lda @SMALLINT.MOD.RESULT');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda @SMALLINT.MOD.RESULT+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end else begin
//		        asm65(#9'jsr @SMALLINT.DIV');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @SMALLINT.DIV.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @SMALLINT.DIV.B+1');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @SMALLINT.DIV.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @SMALLINT.DIV.A+1');

			asm65(#9'jsr @SMALLINT.DIV');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end;

	  INTEGERTOK:
		if op = MODTOK then begin
//		        asm65(#9'jsr @INTEGER.MOD')

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @INTEGER.MOD.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @INTEGER.MOD.B+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @INTEGER.MOD.B+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @INTEGER.MOD.B+3');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @INTEGER.MOD.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @INTEGER.MOD.A+1');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'sta @INTEGER.MOD.A+2');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
			asm65(#9'sta @INTEGER.MOD.A+3');

			asm65(#9'jsr @INTEGER.MOD');

			asm65(#9'lda @INTEGER.MOD.RESULT');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda @INTEGER.MOD.RESULT+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'lda @INTEGER.MOD.RESULT+2');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'lda @INTEGER.MOD.RESULT+3');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end else begin
//		        asm65(#9'jsr @INTEGER.DIV');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @INTEGER.DIV.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @INTEGER.DIV.B+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @INTEGER.DIV.B+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @INTEGER.DIV.B+3');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @INTEGER.DIV.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @INTEGER.DIV.A+1');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'sta @INTEGER.DIV.A+2');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
			asm65(#9'sta @INTEGER.DIV.A+3');

			asm65(#9'jsr @INTEGER.DIV');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'lda :eax+2');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'lda :eax+3');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end;

	end;

      end else begin

	case ResultType of

	BYTETOK:
		if op = MODTOK then begin
//			asm65(#9'jsr @BYTE.MOD');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @BYTE.MOD.B');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @BYTE.MOD.A');

			asm65(#9'jsr @BYTE.MOD');

			asm65(#9'lda @BYTE.MOD.RESULT');
			asm65(#9'sta :STACKORIGIN-1,x');

	         end else begin
//			asm65(#9'jsr @BYTE.DIV');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @BYTE.DIV.B');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @BYTE.DIV.A');

			asm65(#9'jsr @BYTE.DIV');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');

	   	 end;

	WORDTOK:
		if op = MODTOK then begin
//	    		asm65(#9'jsr @WORD.MOD');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @WORD.MOD.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @WORD.MOD.B+1');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @WORD.MOD.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @WORD.MOD.A+1');

			asm65(#9'jsr @WORD.MOD');

			asm65(#9'lda @WORD.MOD.RESULT');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda @WORD.MOD.RESULT+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		end else begin
//			asm65(#9'jsr @WORD.DIV');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @WORD.DIV.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @WORD.DIV.B+1');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @WORD.DIV.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @WORD.DIV.A+1');

			asm65(#9'jsr @WORD.DIV');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	   	 end;

	CARDINALTOK:
		if op = MODTOK then begin
//	     	asm65(#9'jsr @CARDINAL.MOD');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @CARDINAL.MOD.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @CARDINAL.MOD.B+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @CARDINAL.MOD.B+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @CARDINAL.MOD.B+3');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @CARDINAL.MOD.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @CARDINAL.MOD.A+1');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'sta @CARDINAL.MOD.A+2');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
			asm65(#9'sta @CARDINAL.MOD.A+3');

			asm65(#9'jsr @CARDINAL.MOD');

			asm65(#9'lda @CARDINAL.MOD.RESULT');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda @CARDINAL.MOD.RESULT+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'lda @CARDINAL.MOD.RESULT+2');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'lda @CARDINAL.MOD.RESULT+3');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end else begin
//			asm65(#9'jsr @CARDINAL.DIV');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @CARDINAL.DIV.B');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @CARDINAL.DIV.B+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @CARDINAL.DIV.B+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @CARDINAL.DIV.B+3');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @CARDINAL.DIV.A');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @CARDINAL.DIV.A+1');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'sta @CARDINAL.DIV.A+2');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
			asm65(#9'sta @CARDINAL.DIV.A+3');

			asm65(#9'jsr @CARDINAL.DIV');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'lda :eax+2');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'lda :eax+3');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

	    	end;

        end;	// case

      END;	// end else begin

    end;	// if ResultType in SignedOrdinalTypes

    end;


  SHLTOK:
    begin

    if ResultType in SignedOrdinalTypes then begin

     case DataSize[ResultType] of

      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); asm65(#9'jsr shlEAX_CL.CARD') end;

      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); asm65(#9'jsr shlEAX_CL.CARD') end;

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

      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); asm65(#9'jsr shrEAX_CL') end;

      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); asm65(#9'jsr shrEAX_CL') end;

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

end;


procedure GenerateRelationString(rel: Byte; LeftValType, RightValType: Byte);
begin
 asm65;
 asm65('; relation STRING');

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
 asm65;
 asm65('; relation');

 Gen;

 if ValType = HALFSINGLETOK then begin

 case rel of
  EQTOK:	// =
    begin
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_EQ.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_EQ.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_EQ.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_EQ.A+1');

	asm65(#9'jsr @F16_EQ');

	asm65(#9'dex');
    end;

  NETOK, 0:	// <>
    begin
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_EQ.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_EQ.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_EQ.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_EQ.A+1');

	asm65(#9'jsr @F16_EQ');

	asm65(#9'dex');
	asm65(#9'eor #$01');
    end;

  GTTOK:	// >
    begin
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_GT.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_GT.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_GT.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_GT.A+1');

	asm65(#9'jsr @F16_GT');

	asm65(#9'dex');
    end;

  GETOK:	// >=
    begin
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_GTE.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_GTE.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_GTE.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_GTE.A+1');

	asm65(#9'jsr @F16_GTE');

	asm65(#9'dex');
    end;

  LTTOK:
    begin	// <
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_GT.A');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_GT.A+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_GT.B');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_GT.B+1');

	asm65(#9'jsr @F16_GT');

	asm65(#9'dex');
    end;

  LETOK:	// <=
    begin
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_GTE.A');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_GTE.A+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_GTE.B');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_GTE.B+1');

	asm65(#9'jsr @F16_GTE');

	asm65(#9'dex');
    end;

  end;

  asm65(#9'sta :STACKORIGIN,x');

 end else begin


 	if ValType = SINGLETOK then begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @FCMPL.A');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @FCMPL.A+1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta @FCMPL.A+2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta @FCMPL.A+3');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta @FCMPL.B');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta @FCMPL.B+1');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'sta @FCMPL.B+2');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
		asm65(#9'sta @FCMPL.B+3');

 	end;

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

     SINGLETOK: asm65(#9'jsr @FCMPL');

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

 end; // if ValType = HALFSINGLETOK

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
    STRINGTOK: Result := 1;

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
    STRINGTOK: Result := 255;

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

  asm65;

  if Ident[IdentIndex].NumAllocElements_ > 0 then
   asm65(';'+t+' Array index '+Ident[IdentIndex].Name+'[0..'+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+', 0..'+IntToStr(Ident[IdentIndex].NumAllocElements_ - 1)+']')
  else
   asm65(';'+t+' Array index '+Ident[IdentIndex].Name+'[0..'+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+']');

end;


procedure CheckArrayIndex(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

if Ident[IdentIndex].NumAllocElements > 0 then
 if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
  if Ident[IdentIndex].NumAllocElements <> 1 then warning(i, RangeCheckError, IdentIndex, ArrayIndex, ArrayIndexType);

end;


procedure CheckArrayIndex_(i: Integer; IdentIndex: Integer; ArrayIndex: Int64; ArrayIndexType: Byte);
begin

if Ident[IdentIndex].NumAllocElements_ > 0 then
 if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements_-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
  if Ident[IdentIndex].NumAllocElements_ <> 1 then warning(i, RangeCheckError_, IdentIndex, ArrayIndex, ArrayIndexType);

end;


function CompileType(i: Integer; out DataType: Byte; out NumAllocElements: cardinal; out AllocElementType: Byte): Integer; forward;


function CardToHalf(Src: uint32): word;
var
  Sign, Exp, Mantissa: LongInt;
  s: single;


function f32Tof16(fltInt32: uint32): word;
//https://stackoverflow.com/questions/3026441/float32-to-float16/3026505
var
//	fltInt32: uint32;
	fltInt16, tmp: uint16;

begin
//	fltInt32 := PLongWord(@Float)^;
	fltInt16 := (fltInt32 shr 31) shl 5;
	tmp := (fltInt32 shr 23) and $ff;
	tmp := (tmp - $70) and (LongWord(SarLongint(($70 - tmp), 4)) shr 27);
	fltInt16 := (fltInt16 or tmp) shl 10;
	result := fltInt16 or ((fltInt32 shr 13) and $3ff) + 1;
end;


begin

  s := PSingle(@Src)^;

  if (frac(s) <> 0) and (abs(s) >= 0.000060975552) then

   Result := f32Tof16(Src)

  else begin

  // Extract sign, exponent, and mantissa from Single number
  Sign := Src shr 31;
  Exp := LongInt((Src and $7F800000) shr 23) - 127 + 15;
  Mantissa := Src and $007FFFFF;

  if (Exp > 0) and (Exp < 30) then
  begin
    // Simple case - round the significand and combine it with the sign and exponent
    Result := (Sign shl 15) or (Exp shl 10) or ((Mantissa + $00001000) shr 13);
  end
  else if Src = 0 then
  begin
    // Input float is zero - return zero
    Result := 0;
  end
  else
  begin
    // Difficult case - lengthy conversion
    if Exp <= 0 then
    begin
      if Exp < -10 then
      begin
        // Input float's value is less than HalfMin, return zero
         Result := 0;
      end
      else
      begin
        // Float is a normalized Single whose magnitude is less than HalfNormMin.
        // We convert it to denormalized half.
        Mantissa := (Mantissa or $00800000) shr (1 - Exp);
        // Round to nearest
        if (Mantissa and $00001000) > 0 then
          Mantissa := Mantissa + $00002000;
        // Assemble Sign and Mantissa (Exp is zero to get denormalized number)
        Result := (Sign shl 15) or (Mantissa shr 13);
      end;
    end
    else if Exp = 255 - 127 + 15 then
    begin
      if Mantissa = 0 then
      begin
        // Input float is infinity, create infinity half with original sign
        Result := (Sign shl 15) or $7C00;
      end
      else
      begin
        // Input float is NaN, create half NaN with original sign and mantissa
        Result := (Sign shl 15) or $7C00 or (Mantissa shr 13);
      end;
    end
    else
    begin
      // Exp is > 0 so input float is normalized Single

      // Round to nearest
      if (Mantissa and $00001000) > 0 then
      begin
        Mantissa := Mantissa + $00002000;
        if (Mantissa and $00800000) > 0 then
        begin
          Mantissa := 0;
          Exp := Exp + 1;
        end;
      end;

      if Exp > 30 then
      begin
        // Exponent overflow - return infinity half
        Result := (Sign shl 15) or $7C00;
      end
      else
        // Assemble normalized half
        Result := (Sign shl 15) or (Exp shl 10) or (Mantissa shr 13);
    end;
  end;

  end;

end;


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

	HALFSINGLETOK: begin
			move(ConstVal, ftmp, sizeof(ftmp));
			ConstVal := CardToHalf( ftmp[1] );

			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
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

      Result := StaticStringData[Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_BASE + ArrayIndex * DataSize[ConstValType] + x];

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

     if Tok[i + 2].Kind in AllTypes + [STRINGTOK] then begin

      ConstValType := Tok[i + 2].Kind;

      inc(i, 2);

     end else begin

      i:=CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

     end;


     if ConstValType in Pointers then
      ConstVal := 0
     else
      ConstVal := LowBound(i, ConstValType);

     ConstValType := GetValueType(ConstVal);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 HIGHTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in AllTypes + [STRINGTOK] then begin

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

     end else
      ConstVal := HighBound(i, ConstValType);

     ConstValType := GetValueType(ConstVal);

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

      if Tok[i + 2].Kind <> IDENTTOK then
        iError(i + 2, IdentifierExpected);

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

      if ConstValType in [HALFSINGLETOK, SINGLETOK] then begin

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

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, BYTETOK);

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

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, BYTETOK);

      if not(ConstValType in OrdinalTypes + [ENUMTYPE]) then
	iError(i, OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, CPARTOK);

      if ConstValType in [CHARTOK, BOOLEANTOK, ENUMTOK] then
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

	    if Tok[j + 2].Kind = OBRACKETTOK then begin isError:=true; exit end;

	    InfoAboutArray(IdentIndex, true);

	    ConstValType := Ident[IdentIndex].AllocElementType;

	    case DataSize[ConstValType] of
	     1: ConstVal := GetStaticValue(0 + ord(Ident[IdentIndex].idType = PCHARTOK));
	     2: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8;
	     4: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8 + GetStaticValue(2) shl 16 + GetStaticValue(3) shl 24;
	    end;

	    if ConstValType in [HALFSINGLETOK, SINGLETOK] then ConstVal := ConstVal shl 32;

	    i := j + 1;
	    end else

	begin

	ConstValType := Ident[IdentIndex].DataType;

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
	   	      iError(i + 1, CantAdrConstantExp)
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
    ConstVal := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;

{    if Tok[i].StrLength > 255 then begin
     ConstValType := POINTERTOK;
     inc(ConstVal);
    end else}
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

  SHORTREALTOK, REALTOK, SINGLETOK, HALFSINGLETOK:			// Q8.8 ; Q16.16 ; SINGLE 32bit ; FLOAT16
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    if not(ConstValType in RealTypes) then Int2Float(ConstVal);

    CheckTok(j + 1, CPARTOK);

    ConstValType := Tok[i].Kind;

    Result := j + 1;

    end;


  INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK,  PCHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK:	// type conversion operations
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;


    if (ConstValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) and (Tok[i + 3].Kind <> OBRACKETTOK) then begin

      IdentIndex := GetIdent(Tok[i + 2].Name^);

      if (Ident[IdentIndex].DataType in Pointers) and ( (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> RECORDTOK) ) then
       if ((Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0,1])) or (Ident[IdentIndex].DataType = STRINGPOINTERTOK) then begin

       end else
	iError(i + 2, IllegalTypeConversion, IdentIndex, Tok[i].Kind);

    end;


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

if isError then Exit;

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


  if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (RightConstValType in [SHORTREALTOK, REALTOK]) then
   RightConstValType := ConstValType;

  if (RightConstValType in [SINGLETOK, HALFSINGLETOK]) and (ConstValType in [SHORTREALTOK, REALTOK]) then
   ConstValType := RightConstValType;


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

  if not(ConstValType in RealTypes + [BOOLEANTOK]) then
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


//  if (ConstValType = POINTERTOK) and (RightConstValType in IntegerTypes) then RightConstValType := ConstValType;


  if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then begin
   Int2Float(RightConstVal);
   RightConstValType := ConstValType;
  end;

  if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then begin
   Int2Float(ConstVal);
   ConstValType := RightConstValType;
  end;

  if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (RightConstValType in [SHORTREALTOK, REALTOK]) then
   RightConstValType := ConstValType;

  if (RightConstValType in [SINGLETOK, HALFSINGLETOK]) and (ConstValType in [SHORTREALTOK, REALTOK]) then
   ConstValType := RightConstValType;


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

    ORTOK:    ConstVal := ConstVal or RightConstVal;
    XORTOK:   ConstVal := ConstVal xor RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes + [BOOLEANTOK]) then
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
    yes, ShortArrayIndex: Boolean;
begin
	if optimize.use = false then StartOptimization(i);

	InfoAboutArray(IdentIndex);

	Size := DataSize[Ident[IdentIndex].AllocElementType];

	ShortArrayIndex := false;


	if ((Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].IdType = DEREFERENCEARRAYTOK)) then begin
	  NumAllocElements := Ident[IdentIndex].NestedNumAllocElements and $FFFF;
	  NumAllocElements_ := Ident[IdentIndex].NestedNumAllocElements shr 16;

	  if NumAllocElements_ > 0 then begin
	    if (NumAllocElements * NumAllocElements_ > 1) and (NumAllocElements * NumAllocElements_ * Size < 256) then ShortArrayIndex := true;
	  end else
	    if (NumAllocElements > 1) and (NumAllocElements * Size < 256) then ShortArrayIndex := true;

	end else begin
	  NumAllocElements := Ident[IdentIndex].NumAllocElements;
	  NumAllocElements_ := Ident[IdentIndex].NumAllocElements_;
	end;


	if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK, PROCVARTOK] then begin
	 NumAllocElements_ := 0;
	// Size := RecordSize(IdentIndex);
	end;

	      ActualParamType := WORDTOK;		// !!! aby dzialaly optymalizacje dla ADR.

	      j := i + 2;

	      if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
		  i := j;

		  CheckArrayIndex(i, IdentIndex, ConstVal, ArrayIndexType);

		  ArrayIndexType := WORDTOK;
		  ShortArrayIndex := false;

	      	  if NumAllocElements_ > 0 then
		   Push(ConstVal * NumAllocElements_ * Size, ASVALUE, DataSize[ArrayIndexType])
		  else
		   Push(ConstVal * Size, ASVALUE, DataSize[ArrayIndexType]);

	      end else begin
		 i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	  // array index [x, ..]

		 GetCommonType(i, ActualParamType, ArrayIndexType);

		 if DataSize[ArrayIndexType] = 1 then
		  ArrayIndexType := BYTETOK
		 else
		  ArrayIndexType := WORDTOK;

		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
		    ExpandParam(WORDTOK, ArrayIndexType);
		    ArrayIndexType := WORDTOK;
		  end;

		 if NumAllocElements_ > 0 then begin

		   Push(integer(NumAllocElements_ * Size), ASVALUE, DataSize[ArrayIndexType]);

		   GenerateBinaryOperation(MULTOK, ArrayIndexType);
{
		   asm65(#9'lda :STACKORIGIN,x');
		   asm65(#9'sta :STACKORIGIN,x');
		   asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
}
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
		  ShortArrayIndex := false;

		  Push(ConstVal * Size, ASVALUE, DataSize[ArrayIndexType]);

		end else begin
		  i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	  // array index [.., y]

		  GetCommonType(i, ActualParamType, ArrayIndexType);

		  if DataSize[ArrayIndexType] = 1 then begin
		   ExpandParam(WORDTOK, ArrayIndexType);
		   ArrayIndexType := BYTETOK;
		  end else
		   ArrayIndexType := WORDTOK;

		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
		    ExpandParam(WORDTOK, ArrayIndexType);
		    ArrayIndexType := WORDTOK;
		  end;

		  GenerateIndexShift( Ident[IdentIndex].AllocElementType );

		end;

		GenerateBinaryOperation(PLUSTOK, WORDTOK);

	    end;


	if ShortArrayIndex then begin

	  asm65(#9'lda #$00');
	  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end;

// writeln(Ident[IdentIndex].Name,',',Elements(IdentIndex));

 Result := i;
end;


function CompileAddress(i: integer; out ValType, AllocElementType: Byte; VarPass: Boolean = false): integer;
var IdentIndex, IdentTemp, j: integer;
    Name, svar, lab: string;
    NumAllocElements: cardinal;
    rec, dereference, address: Boolean;
begin

    Result:=i;

    lab := '';

    rec := false;
    dereference := false;

    address := false;

    AllocElementType := UNTYPETOK;


    if Tok[i + 1].Kind = ADDRESSTOK then begin

     if VarPass then
      Error(i + 1, 'Can''t assign values to an address');

     address := true;

     inc(i);
    end;


    if (Tok[i + 1].Kind = PCHARTOK) and (Tok[i + 2].Kind = OPARTOK) then begin

      j := CompileExpression(i + 3, ValType, POINTERTOK);

      CheckTok(j + 1, CPARTOK);

      if Tok[j + 2].Kind <> DEREFERENCETOK then
        Error(i + 3, 'Can''t assign values to an address');

      i := j + 1;

    end else

    if Tok[i + 1].Kind <> IDENTTOK then
      iError(i + 1, IdentifierExpected)
    else
      begin
      IdentIndex := GetIdent(Tok[i + 1].Name^);

      if IdentIndex > 0 then
	begin

	if not(Ident[IdentIndex].Kind in [CONSTANT, VARIABLE, PROCEDURETOK, FUNC, CONSTRUCTORTOK, DESTRUCTORTOK, ADDRESSTOK]) then
	 iError(i + 1, VariableExpected)
	else begin

 	  if Ident[IdentIndex].Kind = CONSTANT then
	   if not ( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
	     iError(i + 1, CantAdrConstantExp);

//	  asm65;
//	  asm65('; address');

	  if Ident[IdentIndex].Kind in [PROCEDURETOK, FUNC, CONSTRUCTORTOK, DESTRUCTORTOK] then begin

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
	  begin									// array index
	      inc(i);

 // atari	  // a := @tab[x,y]

	      i := CompileArrayIndex(i, IdentIndex);


	if Ident[IdentIndex].DataType = ENUMTYPE then begin
//   Size := DataSize[Ident[IdentIndex].AllocElementType];
	 NumAllocElements := 0;
	end else
	 NumAllocElements := Elements(IdentIndex); //Ident[IdentIndex].NumAllocElements;

	svar := GetLocalName(IdentIndex);

  	if (pos('.', svar) > 0) then begin
	 lab:=copy(svar,1,pos('.', svar)-1);
	 rec:=(Ident[GetIdent(lab)].AllocElementType = RECORDTOK);
	end;

	AllocElementType := Ident[IdentIndex].AllocElementType;

// writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements );

	if rec then begin							// record.array[]

	 asm65(#9'lda '+lab);
	 asm65(#9'add :STACKORIGIN,x');
	 asm65(#9'sta :STACKORIGIN,x');
	 asm65(#9'lda '+lab+'+1');
	 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'add #' + svar + '-DATAORIGIN');
	 asm65(#9'sta :STACKORIGIN,x');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'adc #$00');
	 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end else

	if (Ident[IdentIndex].PassMethod = VARPASSING) or (NumAllocElements * DataSize[AllocElementType] > 256) or (NumAllocElements in [0,1]) then begin

	 asm65(#9'lda '+svar);
	 asm65(#9'add :STACKORIGIN,x');
	 asm65(#9'sta :STACKORIGIN,x');
	 asm65(#9'lda '+svar+'+1');
	 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end else begin

	 asm65(#9'lda <' + GetLocalName(IdentIndex, 'adr.'));
	 asm65(#9'add :STACKORIGIN,x');
	 asm65(#9'sta :STACKORIGIN,x');
	 asm65(#9'lda >' + GetLocalName(IdentIndex, 'adr.'));
	 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end;

	     CheckTok(i + 1, CBRACKETTOK);

	     end else
	      if (Ident[IdentIndex].DataType in [FILETOK, TEXTFILETOK, RECORDTOK, OBJECTTOK] {+ Pointers}) or
	         ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> 0) and (Ident[IdentIndex].NumAllocElements > 0)) or
		 (Ident[IdentIndex].PassMethod = VARPASSING) or
		 (VarPass and (Ident[IdentIndex].DataType in Pointers))  then begin

// writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].PassMethod,',',Tok[i + 2].Kind);

		 DEREFERENCE := (Tok[i + 2].Kind = DEREFERENCETOK);


		 if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
		    (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET) then begin

		   Push(Ident[IdentIndex].Value, ASPOINTERTORECORD, DataSize[POINTERTOK], IdentIndex)
		 end else
		  if DEREFERENCE then begin


		 svar := GetLocalName(IdentIndex);

//  		 if (pos('.', svar) > 0) then begin
//		   lab:=copy(svar,1,pos('.', svar)-1);
//		   rec:=(Ident[GetIdent(lab)].AllocElementType = RECORDTOK);
//		 end;

		 if (Ident[IdentIndex].DataType in Pointers) {and (Tok[i + 2].Kind = DEREFERENCETOK)} then
		  if (Ident[IdentIndex].AllocElementType = RECORDTOK) and (Tok[i +3].Kind = DOTTOK) then begin		// var record^.field

		   // writeln(Tok[i + 2].Kind,',',Tok[i + 3].Kind,',',Tok[i + 4].Kind);

		    CheckTok(i + 3, DOTTOK);
		    CheckTok(i + 4, IDENTTOK);

//		    DEREFERENCE := true;

	      	    IdentTemp := RecordSize(IdentIndex, Tok[i + 4].Name^);

 	            if IdentTemp < 0 then
	              Error(i + 4, 'identifier idents no member '''+Tok[i + 4].Name^+'''');

	            AllocElementType := IdentTemp shr 16;

		    IdentTemp:=GetIdent(svar + '.' + string(Tok[i + 4].Name^) );

		    if IdentTemp = 0 then
		     iError(i + 4, UnknownIdentifier);

		    Push(Ident[IdentTemp].Value, ASPOINTER, DataSize[POINTERTOK], IdentTemp);

		    inc(i, 3);

		  end else begin											// type^
		    AllocElementType :=  Ident[IdentIndex].AllocElementType;

//	writeln('^',',', Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' / ',Ident[IdentIndex].NumAllocElements_,' = ',Ident[IdentIndex].idType,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

		    if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		      if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then begin

			if Ident[IdentIndex].NumAllocElements_ = 0 then

			else
			  iError(i + 4, IllegalQualifier);	// array of ^record

		      end else
		        iError(i + 4, IllegalQualifier);	// array

		    end;

		    Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

		    inc(i);
		  end;


// writeln('5: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE,',',VarPass);

//writeln(AllocElementType);
//	            Push(Ident[IdentIndex].Value, ASPOINTERTOARRAYORIGIN, DataSize[POINTERTOK], IdentIndex);


		  end else
		   if address or VarPass then begin
//		   if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) {and (Ident[IdentIndex].PassMethod <> VARPASSING)} then begin

 writeln('1: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,'..',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

//		     if  ((Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) then
//		       Push(Ident[IdentIndex].Value, ASVALUE, DataSize[POINTERTOK], IdentIndex)
//		     else
                     if (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK, FILETOK, TEXTFILETOK]) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].PassMethod = VARPASSING)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].NumAllocElements_ > 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET)) or
		        ((Ident[IdentIndex].DataType in Pointers) and not (Ident[IdentIndex].AllocElementType in [UNTYPETOK, RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].NumAllocElements > 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and {(Ident[IdentIndex].AllocElementType = UNTYPETOK) and} (Ident[IdentIndex].PassMethod = VARPASSING))
		     then
		       Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex)
		     else
		       Push(Ident[IdentIndex].Value, ASVALUE, DataSize[POINTERTOK], IdentIndex);

		     AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   end else begin

// writeln('2: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

		     Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

		     AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   end;

	      end else begin

		 if (Ident[IdentIndex].DataType in Pointers) and (Tok[i + 2].Kind = DEREFERENCETOK) then begin
		   AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   inc(i);

		   Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
		 end else
{		  if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> 0) and (Ident[IdentIndex].NumAllocElements = 0) then begin

writeln('3: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

		   Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
		  end else} begin

// writeln('4: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

  		   Push(Ident[IdentIndex].Value, ASVALUE, DataSize[POINTERTOK], IdentIndex);

		  end;

	 end;

	  ValType :=  POINTERTOK;

	  Result := i + 1;
	  end;

	end
      else
	iError(i + 1, UnknownIdentifier);
      end;

end;


function NumActualParameters(i: integer; IdentIndex: integer; out NumActualParams: integer): TParamList;
(*----------------------------------------------------------------------------*)
(* moze istniec wiele funkcji/procedur o tej samej nazwie ale roznej liczbie  *)
(* parametrow								      *)
(*----------------------------------------------------------------------------*)
var ActualParamType, AllocElementType: byte;
    NumAllocElements: cardinal;
    oldPass, oldCodeSize, IdentTemp: integer;
begin

   oldPass := Pass;
   oldCodeSize := CodeSize;
   Pass := CALLDETERMPASS;

   NumActualParams := 0;
   ActualParamType := 0;

   Result[1].i_ := i + 1;

   if (Tok[i + 1].Kind = OPARTOK) and (Tok[i + 2].Kind <> CPARTOK) then		    // Actual parameter list found
     begin
     repeat

       Inc(NumActualParams);

       if NumActualParams > MAXPARAMS then
	 iError(i, TooManyParameters, IdentIndex);

       Result[NumActualParams].i := i;

{
       if (Ident[IdentIndex].Param[NumActualParams].PassMethod = VARPASSING) then begin		// !!! to nie uwzglednia innych procedur/funkcji o innej liczbie parametrow

	CompileExpression(i + 2, ActualParamType);

	Result[NumActualParams].AllocElementType := ActualParamType;

	i := CompileAddress(i + 1, ActualParamType, AllocElementType);

       end else}

	 i := CompileExpression(i + 2, ActualParamType{, Ident[IdentIndex].Param[NumActualParams].DataType});	// Evaluate actual parameters and push them onto the stack

         AllocElementType := UNTYPETOK;
	 NumAllocElements := 0;

	if (ActualParamType = POINTERTOK) and (Tok[i].Kind = IDENTTOK) then begin

	  if (Tok[i - 1].Kind = ADDRESSTOK) and (not (Ident[GetIdent(Tok[i].Name^)].DataType in [RECORDTOK, OBJECTTOK])) then

	  else begin
	   AllocElementType := Ident[GetIdent(Tok[i].Name^)].AllocElementType;
	   NumAllocElements := Ident[GetIdent(Tok[i].Name^)].NumAllocElements;
	  end;


	  if Ident[GetIdent(Tok[i].Name^)].Kind in [PROCEDURETOK, FUNCTIONTOK] then begin

           Result[NumActualParams].Name := Ident[GetIdent(Tok[i].Name^)].Name;

	   AllocElementType := Ident[GetIdent(Tok[i].Name^)].Kind;

	  end;

//writeln(Ident[GetIdent(Tok[i].Name^)].Name,',',ActualParamType,',',AllocElementType,',',Ident[GetIdent(Tok[i].Name^)].NumAllocElements);

	end else begin

	 if Tok[i].Kind = IDENTTOK then begin

	  IdentTemp := GetIdent(Tok[i].Name^);

	  AllocElementType := Ident[GetIdent(Tok[i].Name^)].AllocElementType;
	  NumAllocElements := Ident[GetIdent(Tok[i].Name^)].NumAllocElements;

	  //writeln(Ident[IdentTemp].Name,' > ',ActualPAramType,',',AllocElementType,',',NumAllocElements,' | ',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements);

	 end else
	  AllocElementType := UNTYPETOK;


	end;

       Result[NumActualParams].DataType := ActualParamType;
       Result[NumActualParams].AllocElementType := AllocElementType;
       Result[NumActualParams].NumAllocElements := NumAllocElements;


//       writeln(Result[NumActualParams].DataType,',',Result[NumActualParams].AllocElementType);

     until Tok[i + 1].Kind <> COMMATOK;

     CheckTok(i + 1, CPARTOK);

     Result[1].i_ := i;

//     inc(i);
     end;	// if (Tok[i + 1].Kind = OPARTOR) and (Tok[i + 2].Kind <> CPARTOK)


     Pass := oldPass;
     CodeSize := oldCodeSize;
end;


procedure CompileActualParameters(var i: integer; IdentIndex: integer; ProcVarIndex: integer = 0);
var NumActualParams, IdentTemp, ParamIndex, j, old_func: integer;
    ActualParamType, AllocElementType: byte;
    svar: string;
    yes: Boolean;
    Param: TParamList;
begin

   j := i;

   if Ident[IdentIndex].ProcAsBlock = BlockStack[BlockStackTop] then Ident[IdentIndex].isRecursion := true;


   yes := {(Ident[IdentIndex].ObjectIndex > 0) or} Ident[IdentIndex].isRecursion or Ident[IdentIndex].isStdCall;

   for ParamIndex := Ident[IdentIndex].NumParams downto 1 do
    if not ( (Ident[IdentIndex].Param[ParamIndex].PassMethod = VARPASSING) or
	     ((Ident[IdentIndex].Param[ParamIndex].DataType in Pointers) and (Ident[IdentIndex].Param[ParamIndex].NumAllocElements and $FFFF in [0,1])) or
	     ((Ident[IdentIndex].Param[ParamIndex].DataType in Pointers) and (Ident[IdentIndex].Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) or
             (Ident[IdentIndex].Param[ParamIndex].DataType in OrdinalTypes + RealTypes)
	   ) then begin yes:=true; Break end;


//   yes:=true;

(*------------------------------------------------------------------------------------------------------------*)

   if  ProcVarIndex > 0 then begin

     svar := GetLocalName(ProcVarIndex);

     if (Tok[i + 1].Kind = OBRACKETTOK) then begin
       i := CompileArrayIndex(i, ProcVarIndex);

       CheckTok(i + 1, CBRACKETTOK);

       inc(i);

       if (Ident[ProcVarIndex].NumAllocElements * 2 > 256) or (Ident[ProcVarIndex].NumAllocElements in [0,1]) then begin

	asm65(#9'lda ' + svar);
        asm65(#9'add :STACKORIGIN,x');
        asm65(#9'sta :bp2');
        asm65(#9'lda ' + svar + '+1');
        asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta :bp2+1');
        asm65(#9'ldy #$00');
        asm65(#9'lda (:bp2),y');
        asm65(#9'sta :TMP+1');
        asm65(#9'iny');
        asm65(#9'lda (:bp2),y');
        asm65(#9'sta :TMP+2');

       end else begin

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'add #$00');
	asm65(#9'tay');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'adc #$00');
	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'lda adr.' + svar + ',y');
        asm65(#9'sta :TMP+1');
        asm65(#9'lda adr.' + svar + '+1,y');
        asm65(#9'sta :TMP+2');

       end;

       asm65(#9'lda #$4C');
       asm65(#9'sta :TMP');

     end else begin

       if Ident[ProcVarIndex].isAbsolute then begin

        asm65(#9'jsr *+6');
        asm65(#9'jmp *+6');

       end else begin
        asm65(#9'lda ' + svar);
        asm65(#9'sta :TMP+1');
        asm65(#9'lda ' + svar + '+1');
        asm65(#9'sta :TMP+2');

        asm65(#9'lda #$4C');
        asm65(#9'sta :TMP');
       end;

     end;


   end;

(*------------------------------------------------------------------------------------------------------------*)

   Param := NumActualParameters(i, IdentIndex, NumActualParams);


   if NumActualParams <> Ident[IdentIndex].NumParams then
     if ProcVarIndex > 0 then
	iError(i, WrongNumParameters, ProcVarIndex)
     else
	iError(i, WrongNumParameters, IdentIndex);


   ParamIndex := NumActualParams;

   AllocElementType := UNTYPETOK;

//   NumActualParams := 0;
   IdentTemp := 0;

   if (Tok[i + 1].Kind = OPARTOK) then		    // Actual parameter list found
     begin

     if (Tok[i + 2].Kind = CPARTOK) then
      inc(i)
     else
     //repeat

     while NumActualParams > 0 do begin

//       Inc(NumActualParams);

//       if NumActualParams > Ident[IdentIndex].NumParams then
//        if ProcVarIndex > 0 then
//	 iError(i, WrongNumParameters, ProcVarIndex)
//	else
//	 iError(i, WrongNumParameters, IdentIndex);

       i := Param[NumActualParams].i;

       if Ident[IdentIndex].Param[NumActualParams].PassMethod = VARPASSING then begin

	i := CompileAddress(i + 1, ActualParamType, AllocElementType, true);

	if Tok[i].Kind = IDENTTOK then
	 IdentTemp := GetIdent(Tok[i].Name^)
	else
	 IdentTemp := 0;

	if IdentTemp > 0 then begin

//      writeln(' - ',Tok[i].Name^,',',ActualParamType,',',AllocElementType, ',', Ident[IdentTemp].NumAllocElements );
//      writeln(Ident[IdentTemp].DataType,',',Ident[IdentIndex].Param[NumActualParams].DataType);

	if Ident[IdentTemp].DataType in Pointers then
	  if not(Ident[IdentIndex].Param[NumActualParams].DataType in [FILETOK, TEXTFILETOK]) then begin

{
 writeln('--- ',Ident[IdentIndex].Name);
 writeln(Ident[IdentIndex].Param[NumActualParams].DataType,',', Ident[IdentTemp].DataType);
 writeln(Ident[IdentIndex].Param[NumActualParams].NumAllocElements,',', Ident[IdentTemp].NumAllocElements);
 writeln(Ident[IdentIndex].Param[NumActualParams].PassMethod,',', Ident[IdentTemp].PassMethod);
}

	    if Ident[IdentTemp].PassMethod <> VARPASSING then

	      if Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK] then
	        Error(i, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + Types[Ident[IdentIndex].Param[NumActualParams].NumAllocElements].Field[0].Name + '"')
	      else
	        GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	  end;

	 if (Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK]) {and (Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK])} then
	  if (Ident[IdentIndex].Param[NumActualParams].NumAllocElements > 0) and (Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements) then begin

	    if Ident[IdentTemp].PassMethod <> Ident[IdentIndex].Param[NumActualParams].PassMethod then
		iError(i, CantAdrConstantExp)
	    else
		iError(i, IncompatibleTypeOf, IdentTemp);
	  end;

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
	   if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> Ident[IdentTemp].AllocElementType then begin

{
 writeln('--- ',Ident[IdentIndex].Name);
 writeln(Ident[IdentIndex].Param[NumActualParams].DataType,',', Ident[IdentTemp].DataType);
 writeln(Ident[IdentIndex].Param[NumActualParams].AllocElementType,',', Ident[IdentTemp].AllocElementType);
 writeln(Ident[IdentIndex].Param[NumActualParams].NumAllocElements,',', Ident[IdentTemp].NumAllocElements);
 writeln(Ident[IdentIndex].Param[NumActualParams].PassMethod,',', Ident[IdentTemp].PassMethod);
}

	     if (Ident[IdentIndex].Param[NumActualParams].AllocElementType = UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType = POINTERTOK) then begin

	      if Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK] then

	      else
	        iError(i, IncompatibleTypesArray, IdentTemp, POINTERTOK);

	     end else
	      iError(i, IncompatibleTypes, 0, Ident[IdentTemp].AllocElementType, Ident[IdentIndex].Param[NumActualParams].AllocElementType);

	   end;

	  end else
	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].AllocElementType);

	end else
	  if  Ident[IdentIndex].Param[NumActualParams].DataType <> UNTYPETOK then
	   if (Ident[IdentIndex].Param[NumActualParams].DataType <> AllocElementType)  then
	     iError(i, IncompatibleTypes, 0, AllocElementType, Ident[IdentIndex].Param[NumActualParams].DataType);

// writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].DataType,',',ActualParamType,' / ',IdentTemp);

       end else begin

	i := CompileExpression(i + 2, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);	// Evaluate actual parameters and push them onto the stack

// writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType ,'|',ActualParamType);


	if (Tok[i].Kind = IDENTTOK) and (ActualParamType in [RECORDTOK, OBJECTTOK]) and not (Ident[IdentIndex].Param[NumActualParams].DataType in Pointers) then
	 if Ident[GetIdent(Tok[i].Name^)].isNestedFunction then begin

	  if Ident[GetIdent(Tok[i].Name^)].NestedFunctionNumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    iError(i, IncompatibleTypeOf, GetIdent(Tok[i].Name^));

	 end else
	  if Ident[GetIdent(Tok[i].Name^)].NumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    iError(i, IncompatibleTypeOf, GetIdent(Tok[i].Name^));


	if ((ActualParamType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].Param[NumActualParams].DataType in Pointers)) or
	   ((ActualParamType in Pointers) and (Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK])) then
     //  jesli wymagany jest POINTER a przekazujemy RECORD (lub na odwrot) to OK

	begin

         if (ActualParamType = POINTERTOK) and (Tok[i].Kind = IDENTTOK) then begin
	   IdentTemp := GetIdent(Tok[i].Name^);

           if (Tok[i - 1].Kind = ADDRESSTOK) then
	    AllocElementType := UNTYPETOK
	   else
	    AllocElementType := Ident[IdentTemp].AllocElementType;

	   if AllocElementType = UNTYPETOK then
	      iError(i, IncompatibleTypes, 0, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);
{
 writeln('--- ',Ident[IdentIndex].Name,',',ActualParamType,',',AllocElementType);
 writeln(Ident[IdentIndex].Param[NumActualParams].DataType,',', Ident[IdentTemp].DataType);
 writeln(Ident[IdentIndex].Param[NumActualParams].AllocElementType,',', Ident[IdentTemp].AllocElementType);
 writeln(Ident[IdentIndex].Param[NumActualParams].NumAllocElements,',', Ident[IdentTemp].NumAllocElements);
 writeln(Ident[IdentIndex].Param[NumActualParams].PassMethod,',', Ident[IdentTemp].PassMethod);
}
	 end else
	   iError(i, IncompatibleTypes, 0, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);

	end

	else begin

         if (ActualParamType = POINTERTOK) and (Tok[i].Kind = IDENTTOK) then begin
	   IdentTemp := GetIdent(Tok[i].Name^);

           if (Tok[i - 1].Kind = ADDRESSTOK) then
	    AllocElementType := UNTYPETOK
	   else
	    AllocElementType := Ident[IdentTemp].AllocElementType;


	   if (Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK]) then
	    GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType)
	   else
	   if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> AllocElementType then begin

	     if (Ident[IdentIndex].Param[NumActualParams].AllocElementType = UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType = POINTERTOK) and ({Ident[IdentIndex].Param[NumActualParams]} Ident[IdentTemp].NumAllocElements > 0) then
	      iError(i, IncompatibleTypesArray, IdentTemp, POINTERTOK)
	     else
	      if (Ident[IdentIndex].Param[NumActualParams].AllocElementType <> PROCVARTOK) and (Ident[IdentIndex].Param[NumActualParams].NumAllocElements > 0) then
	       iError(i, IncompatibleTypes, 0, AllocElementType, Ident[IdentIndex].Param[NumActualParams].AllocElementType);

           end;

	 end else
          if (Ident[IdentIndex].Param[NumActualParams].DataType in [POINTERTOK, STRINGPOINTERTOK]) and (Tok[i].Kind = IDENTTOK) then begin
	    IdentTemp := GetIdent(Tok[i].Name^);

// writeln('1 > ',Ident[IdentTemp].name,',', Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements,' | ',Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements );

            if (Ident[IdentTemp].DataType = STRINGPOINTERTOK) and (Ident[IdentTemp].NumAllocElements <> 0) and (Ident[IdentIndex].Param[NumActualParams].DataType = POINTERTOK) and (Ident[IdentIndex].Param[NumActualParams].NumAllocElements = 0) then
	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType = UNTYPETOK then
	       iError(i, IncompatibleTypes, 0, Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].DataType)
	     else
	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> BYTETOK then		// wyjatkowo akceptujemy PBYTE jako STRING
	       iError(i, IncompatibleTypes, 0, Ident[IdentTemp].DataType, -Ident[IdentIndex].Param[NumActualParams].AllocElementType);

	    GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);
	  end else begin

// writeln('2 > ',Ident[IdentIndex].Name,',',ActualParamType,',',AllocElementType,',',Tok[i].Kind,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements);

            if (ActualParamType = POINTERTOK) and (Ident[IdentIndex].Param[NumActualParams].DataType = STRINGPOINTERTOK) then
              iError(i, IncompatibleTypes, 0, ActualParamType, -STRINGPOINTERTOK);

	    GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);

	  end;

	end;

	ExpandParam(Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);
       end;


       dec(NumActualParams);
     end;

     //until Tok[i + 1].Kind <> COMMATOK;

     i := Param[1].i_;

     CheckTok(i + 1, CPARTOK);

     inc(i);
     end;// if Tok[i + 1].Kind = OPARTOR


   NumActualParams := ParamIndex;

{
   if NumActualParams <> Ident[IdentIndex].NumParams then
    if ProcVarIndex > 0 then begin
     iError(i, WrongNumParameters, ProcVarIndex);
    end else
     iError(i, WrongNumParameters, IdentIndex);
}

   if Pass = CALLDETERMPASS then
     AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);


(*------------------------------------------------------------------------------------------------------------*)

// if Ident[IdentIndex].isUnresolvedForward then begin
//   Error(i, 'Unresolved forward declaration of ' + Ident[IdentIndex].Name);


 if Ident[IdentIndex].isOverload then
  svar := GetLocalName(IdentIndex) + '_' + IntToHex(Ident[IdentIndex].Value, 4)
 else
  svar := GetLocalName(IdentIndex);


if (yes = false) and (Ident[IdentIndex].NumParams > 0) then begin

 for ParamIndex := 1 to NumActualParams do
  if Ident[IdentIndex].Param[ParamIndex].PassMethod = VARPASSING then begin

					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');

					a65(__subBX);
  end else
  if (NumActualParams = 1) and (DataSize[Ident[IdentIndex].Param[ParamIndex].DataType] = 1) then begin			// only ONE parameter SIZE = 1

			if Ident[IdentIndex].ObjectIndex > 0 then begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					a65(__subBX);
			end else begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta @PARAM?');
					a65(__subBX);
			end;

  end else
  case Ident[IdentIndex].Param[ParamIndex].DataType of

   BYTETOK, CHARTOK, BOOLEANTOK, SHORTINTTOK:
   				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);

					a65(__subBX);
				     end;

   WORDTOK, SMALLINTTOK, SHORTREALTOK, HALFSINGLETOK, POINTERTOK, STRINGPOINTERTOK:
      				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');

					a65(__subBX);
				     end;

   CARDINALTOK, INTEGERTOK, REALTOK, SINGLETOK:
      				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');
					asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+2');
					asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+3');

					a65(__subBX);
				     end;

  else
   Error(i, 'Unassigned: ' + IntToStr(Ident[IdentIndex].Param[ParamIndex].DataType) );
  end;


  old_func:=run_func;
  run_func:=0;

  if (Ident[IdentIndex].isStdCall = false) then
						if Ident[IdentIndex].Kind = FUNC then
	  						StartOptimization(i)
						else
	  						StopOptimization;
  run_func:=old_func;


 end;

 Gen;

(*------------------------------------------------------------------------------------------------------------*)

   if Ident[IdentIndex].ObjectIndex > 0 then begin
     IdentTemp := GetIdent(copy(Tok[j].Name^, 1, pos('.', Tok[j].Name^)-1 ));

     asm65(#9'lda ' + GetLocalName(IdentTemp));
     asm65(#9'ldy ' + GetLocalName(IdentTemp) + '+1');
   end;

(*------------------------------------------------------------------------------------------------------------*)

 if Ident[IdentIndex].isInline then begin

// if pass = CODEGENERATIONPASS then
//    writeln(svar,',', Ident[IdentIndex].ProcAsBlock,',', BlockStack[BlockStackTop], ',' ,Ident[IdentIndex].Block ,',', Ident[IdentIndex].UnitIndex );

//  asm65(#9'.LOCAL ' + svar);


  if (Ident[IdentIndex].Block > 1) and (Ident[IdentIndex].Block <> BlockStack[BlockStackTop]) then	// issue #102 fixed
    for IdentTemp := 1 to NumIdent  do
      if (Ident[IdentTemp].Kind in [PROCEDURETOK, FUNCTIONTOK]) and (Ident[IdentTemp].ProcAsBlock = Ident[IdentIndex].Block) then begin
        svar := Ident[IdentTemp].Name + '.' + svar;
	Break;
      end;


  if (BlockStack[BlockStackTop] <> 1) and (Ident[IdentIndex].Block = BlockStack[BlockStackTop]) then	// w aktualnym bloku procedury/funkcji
   asm65(#9'.LOCAL ' + svar)
  else

  if (Ident[IdentIndex].UnitIndex > 1) and (Ident[IdentIndex].UnitIndex <> UnitNameIndex) and Ident[IdentIndex].Section then
   asm65(#9'.LOCAL +MAIN.' + svar)									// w tym samym module poza aktualnym blokiem procedury/funkcji
  else
  if (Ident[IdentIndex].UnitIndex > 1) then
   asm65(#9'.LOCAL +MAIN.' + UnitName[Ident[IdentIndex].UnitIndex].Name + '.' + svar)			// w innym module
  else
   asm65(#9'.LOCAL +MAIN.' + svar);									// w tym samym module poza aktualnym blokiem procedury/funkcji

{
  if Ident[IdentIndex].UnitIndex > 1 then
   asm65(#9'.LOCAL +MAIN.' + UnitName[Ident[IdentIndex].UnitIndex].Name + '.' + svar)			// w innym module
  else
   asm65(#9'.LOCAL +MAIN.' + svar);									// w tym samym module poza aktualnym blokiem procedury/funkcji
}

  asm65(#9+'m@INLINE');
  asm65(#9'.ENDL');

  resetOpty;

 end else begin


  if ProcVarIndex > 0 then begin

   if Ident[ProcVarIndex].isAbsolute then
    asm65(#9'jmp (' + GetLocalName(ProcVarIndex) + ')')
   else
    asm65(#9'jsr :TMP');

  end else
   asm65(#9'jsr ' + svar);				// GenerateCall

 end;


	if (Ident[IdentIndex].Kind = FUNC) and (Ident[IdentIndex].isStdCall = false) and (Ident[IdentIndex].isRecursion = false) then begin

		  asm65(#9'inx');

		  case DataSize[Ident[IdentIndex].DataType] of

		    1: begin
			asm65(#9'mva ' + svar + '.RESULT :STACKORIGIN,x');
		       end;

		    2: begin
			asm65(#9'mva ' + svar + '.RESULT :STACKORIGIN,x');
			asm65(#9'mva ' + svar + '.RESULT+1 :STACKORIGIN+STACKWIDTH,x');
		       end;

		    4: begin
			asm65(#9'mva ' + svar + '.RESULT :STACKORIGIN,x');
			asm65(#9'mva ' + svar + '.RESULT+1 :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'mva ' + svar + '.RESULT+2 :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'mva ' + svar + '.RESULT+3 :STACKORIGIN+STACKWIDTH*3,x');
		       end;

		  end;

	end;

end;


function CompileFactor(i: Integer; out isZero: Boolean; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var IdentTemp, IdentIndex, j, oldCodeSize: Integer;
    ActualParamType, AllocElementType, Kind, oldPass: Byte;
    yes: Boolean;
    Value, ConstVal: Int64;
    svar: string;
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

      if Tok[i + 2].Kind in AllTypes + [STRINGTOK] then begin

       ValType := Tok[i + 2].Kind;

       j:=i + 2;

      end else begin

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := CALLDETERMPASS;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

      end;
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

      if Ident[IdentIndex].DataType = STRINGPOINTERTOK then begin
        a65(__addBX);
        asm65(#9'lda adr.' + GetLocalName(IdentIndex));
        asm65(#9'sta :STACKORIGIN,x');

	ValType := BYTETOK;
      end else
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

	if ValType = STRINGPOINTERTOK then Value := 1;

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

      if Tok[i + 2].Kind <> IDENTTOK then
        iError(i + 2, IdentifierExpected);

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

	   if ((Ident[IdentIndex].DataType = STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = CHARTOK)) or
	      ((Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK)) then begin

		if Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK then begin	// length(array[x])

		i:=CompileArrayIndex(i + 2, IdentIndex);

		a65(__addBX);

		if (Ident[IdentIndex].NumAllocElements * 2 > 256) or (Ident[IdentIndex].NumAllocElements in [0,1]) or (Ident[IdentIndex].PassMethod = VARPASSING) then begin

    		asm65(#9'lda ' + Ident[IdentIndex].Name);
     		asm65(#9'add :STACKORIGIN-1,x');
     		asm65(#9'sta :bp2');
     		asm65(#9'lda ' + Ident[IdentIndex].Name + '+1');
     		asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     		asm65(#9'sta :bp2+1');

		asm65(#9'ldy #$01');
		asm65(#9'lda (:bp2),y');
		asm65(#9'sta :bp+1');
		asm65(#9'dey');
		asm65(#9'lda (:bp2),y');
		asm65(#9'tay');

		end else begin

		asm65(#9'ldy :STACKORIGIN-1,x');
     		asm65(#9'lda adr.' + Ident[IdentIndex].Name + '+1,y');
     		asm65(#9'sta :bp+1');
    		asm65(#9'lda adr.' + Ident[IdentIndex].Name + ',y');
     		asm65(#9'tay');

		end;

		a65(__subBX);

		asm65(#9'lda (:bp),y');
		asm65(#9'sta :STACKORIGIN,x');

		CheckTok(i + 1, CBRACKETTOK);

		CheckTok(i + 2, CPARTOK);

		ValType := BYTETOK;

		Result:=i + 2;
		exit;

		end else
		if (Ident[IdentIndex].PassMethod = VARPASSING) or (Ident[IdentIndex].NumAllocElements = 0) then begin
		 a65(__addBX);

		 asm65(#9'ldy ' + Ident[IdentIndex].Name + '+1');
		 asm65(#9'sty :bp+1');
		 asm65(#9'ldy ' + Ident[IdentIndex].Name);
		 asm65(#9'lda (:bp),y');
	 	 asm65(#9'sta :STACKORIGIN,x');

		end else begin
		 a65(__addBX);

		 asm65(#9'lda ' + GetLocalName(IdentIndex, 'adr.'));
		 asm65(#9'sta :STACKORIGIN,x');

		end;

		ValType:=BYTETOK;

	   end else begin

	    if Tok[i + 3].Kind = OBRACKETTOK then

	     iError(i+2, TypeMismatch)

	    else begin

	     Value:=Ident[IdentIndex].NumAllocElements;

	     ValType := GetValueType(Value);
	     Push(Value, ASVALUE, DataSize[ValType]);

	    end;

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

     asm65;
     asm65('; Lo(X)');

     case ActualParamType of
      SHORTINTTOK, BYTETOK:
		  begin
		    asm65(#9'lda :STACKORIGIN,x');
		    asm65(#9'and #$0F');
		    asm65(#9'sta :STACKORIGIN,x');
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

     asm65;
     asm65('; Hi(X)');

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

     i := CompileExpression(i + 2, ActualParamType, BYTETOK);
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

     case ActualParamType of

       SHORTREALTOK: asm65(#9'jsr @INT_SHORT');

            REALTOK: asm65(#9'jsr @INT');

      HALFSINGLETOK: begin
			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @F16_INT.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @F16_INT.A+1');

			asm65(#9'jsr @F16_INT');
			asm65(#9'jsr @F16_I2F');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		     end;

          SINGLETOK: begin
      			asm65(#9'jsr @F2I');
      			asm65(#9'jsr @I2F');
		     end;
     end;

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

     case ActualParamType of

       SHORTREALTOK: asm65(#9'jsr @SHORTREAL_FRAC');

            REALTOK:// asm65(#9'jsr @REAL_FRAC');
	    	begin

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @REAL_FRAC.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @REAL_FRAC.A+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @REAL_FRAC.A+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @REAL_FRAC.A+3');

			asm65(#9'jsr @REAL_FRAC');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :eax+2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :eax+3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

		end;

      HALFSINGLETOK: begin
		     // asm65(#9'jsr @F16_FRAC');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @F16_FRAC.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @F16_FRAC.A+1');

			asm65(#9'jsr @F16_FRAC');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

		     end;

          SINGLETOK: asm65(#9'jsr @FFRAC');

     end;

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

      ValType := INTEGERTOK;

      case ActualParamType of

       SHORTREALTOK: begin
		      asm65(#9'jsr @SHORTREAL_TRUNC');

		      ValType := SHORTINTTOK;
		     end;

            REALTOK:// asm65(#9'jsr @REAL_TRUNC');
	    	begin

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @REAL_TRUNC.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @REAL_TRUNC.A+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @REAL_TRUNC.A+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @REAL_TRUNC.A+3');

			asm65(#9'jsr @REAL_TRUNC');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :eax+2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :eax+3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

		end;

      HALFSINGLETOK: begin
		     // asm65(#9'jsr @F16_INT');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @F16_INT.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @F16_INT.A+1');

			asm65(#9'jsr @F16_INT');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :eax+2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :eax+3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

                     end;

          SINGLETOK: asm65(#9'jsr @F2I');

      end;

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

      ValType := INTEGERTOK;

      case ActualParamType of

       SHORTREALTOK: begin
		      asm65(#9'jsr @SHORTREAL_ROUND');
		      ValType := SHORTINTTOK;
		     end;

            REALTOK: //asm65(#9'jsr @REAL_ROUND');
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta @REAL_ROUND.A');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta @REAL_ROUND.A+1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta @REAL_ROUND.A+2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta @REAL_ROUND.A+3');

		asm65(#9'jsr @REAL_ROUND');

		asm65(#9'lda :eax');
		asm65(#9'sta :STACKORIGIN,x');
		asm65(#9'lda :eax+1');
		asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'lda :eax+2');
		asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'lda :eax+3');
		asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

		end;

      HALFSINGLETOK: begin
		     // asm65(#9'jsr @F16_ROUND');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @F16_ROUND.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @F16_ROUND.A+1');

			asm65(#9'jsr @F16_ROUND');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :eax+2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :eax+3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

                     end;

          SINGLETOK: begin
		      asm65(#9'jsr @FROUND');
		      asm65(#9'jsr @F2I');
                     end;

      end;

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
     asm65(#9'and #$01');
     asm65(#9'sta :STACKORIGIN,x');

     ValType := BOOLEANTOK;
     Result:=i + 1;
    end;


  ORDTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     j := i + 2;

     i := CompileExpression(i + 2, ValType, BYTETOK);

     if not(ValType in OrdinalTypes + [ENUMTYPE]) then
	iError(i, OrdinalExpExpected);

     CheckTok(i + 1, CPARTOK);

     if ValType in [CHARTOK, BOOLEANTOK, ENUMTOK] then
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

//		CheckTok(i + 1, OPARTOK);

		j := CompileExpression(i + 2, ValType);


		if not(ValType in AllTypes) then
		  iError(i, TypeMismatch);


		if ValType in IntegerTypes then

		 case Ident[IdentIndex].DataType of

			ENUMTOK:
		   	begin
				ValType := ENUMTOK;
			end;


			SHORTREALTOK:
		 	begin
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


			REALTOK:
			begin
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


			HALFSINGLETOK:
			begin
				ExpandParam(INTEGERTOK, ValType);

				asm65(#9'jsr @F16_I2F');

				ValType := HALFSINGLETOK;
			end;


			SINGLETOK:
			begin
				ExpandParam(INTEGERTOK, ValType);

				asm65(#9'jsr @I2F');

				ValType := SINGLETOK;
			end;

		 end;

		CheckTok(j + 1, CPARTOK);

		if (ValType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = PROCVARTOK) then begin

			IdentTemp := GetIdent('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		       	if Ident[IdentTemp].IsNestedFunction = FALSE then
			 Error(j, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found');

			if Tok[j].Kind <> IDENTTOK then iError(j, VariableExpected);

			svar := GetLocalName(GetIdent(Tok[j].Name^));

			asm65(#9'lda ' + svar);
	       		asm65(#9'sta :TMP+1');
			asm65(#9'lda ' + svar + '+1');
			asm65(#9'sta :TMP+2');
	       		asm65(#9'lda #$4C');
	       		asm65(#9'sta :TMP');
	       		asm65(#9'jsr :TMP');

			ValType := Ident[IdentTemp].DataType;

		end else
		if ((ValType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in OrdinalTypes + RealTypes + [RECORDTOK, OBJECTTOK])) or
		   ((ValType = POINTERTOK) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK])) then begin

		 yes:=true;


 	     	 if (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) or (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK]) then begin

	       	  if Tok[j + 2].Kind = DEREFERENCETOK then inc(j);


		  if Tok[j+2].Kind <> DOTTOK then yes := false else

		   if Tok[j+2].Kind = DOTTOK then begin					// (pointer).field :=

//			CheckTok(j + 2, DOTTOK);
			CheckTok(j + 3, IDENTTOK);

	        	IdentTemp := RecordSize(IdentIndex, Tok[j + 3].Name^);

	        	if IdentTemp < 0 then
	        	  Error(j + 3, 'identifier idents no member '''+Tok[j + 3].Name^+'''');

	        	ValType := IdentTemp shr 16;

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta :bp2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta :bp2+1');
			asm65(#9'ldy #$'+IntToHex(IdentTemp and $ffff, 2));

	        	inc(j, 2);
		   end;

	         end else
		   if Tok[j + 2].Kind = DEREFERENCETOK then				// ASPOINTERTODEREFERENCE
		     if ValType = POINTERTOK then begin

			asm65(#9'lda :STACKORIGIN,x');
		    	asm65(#9'sta :bp2');
		    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		    	asm65(#9'sta :bp2+1');
		    	asm65(#9'ldy #$00');

			ValType := Ident[IdentIndex].AllocElementType;

		    	inc(j);

		     end else
		      iError(j + 2, IllegalQualifier);


		 if yes then
		  case DataSize[ValType] of

			 1: begin
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN,x');
			    end;

			 2: begin
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN,x');
				asm65(#9'iny');
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			    end;

			 4: begin
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN,x');
				asm65(#9'iny');
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'iny');
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'iny');
			    	asm65(#9'lda (:bp2),y');
			    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
			    end;

		  end;

		end;

		ExpandParam(Ident[IdentIndex].DataType, ValType);

		Result := j + 1;

	  end else

      if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = PROCVARTOK) then begin

//        writeln('!! ',hexstr(Ident[IdentIndex].NumAllocElements_,8));

	IdentTemp := GetIdent('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

	if Ident[IdentTemp].IsNestedFunction = FALSE then
	 Error(i, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found');

	CompileActualParameters(i, IdentTemp, IdentIndex);

	ValType := Ident[IdentTemp].DataType;

	Result := i;

      end else

      if Ident[IdentIndex].Kind = PROCEDURETOK then
	Error(i, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found')
      else if Ident[IdentIndex].Kind = FUNC then       // Function call
	begin

	  Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc( Ident[IdentIndex].Name, IdentIndex, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then
	      iError(i, CantDetermine, IdentIndex)
	     else
              iError(i, WrongNumParameters, IdentIndex);

	    IdentIndex := IdentTemp;

//	  end;


        if (Ident[IdentIndex].isStdCall = false) then
	 StartOptimization(i)
	else
        if optimize.use = false then StartOptimization(i);


	inc(run_func);

	CompileActualParameters(i, IdentIndex);

	ValType := Ident[IdentIndex].DataType;

	dec(run_func);

	Result := i;
	end // FUNC
      else
	begin
	if (Tok[i + 1].Kind = DEREFERENCETOK) then
	  if (Ident[IdentIndex].Kind <> VARIABLE) or not (Ident[IdentIndex].DataType in Pointers) then
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin
// cyyyyyyyyyyyyyyyy

	    if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	      ValType := STRINGPOINTERTOK
	    else
 	      ValType :=  Ident[IdentIndex].AllocElementType;


	    if (ValType = UNTYPETOK) and (Ident[IdentIndex].DataType = POINTERTOK) then begin

	     ValType := POINTERTOK;

	     Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[ValType], IdentIndex);

	    end else
	    if (ValType in [RECORDTOK, OBJECTTOK]) then begin			// record^.


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
	else if Tok[i + 1].Kind = OBRACKETTOK then			// Array element access
	  if not (Ident[IdentIndex].DataType in Pointers) {or ((Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].idType <> PCHARTOK))} then  // PByte, PWord
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin

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


	  if Ident[IdentIndex].isVolatile then begin
	   asm65('?volatile:');
	   resetOPTY;
	  end;


	  i := CompileConstTerm(i, ConstVal, ValType);

	  if isError then begin
	   i:=j;

	  if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements = 0) then begin

	   ValType := Ident[IdentIndex].AllocElementType;
	   if ValType = UNTYPETOK then ValType := Ident[IdentIndex].DataType;	// RECORD.

	  end else
	   ValType := Ident[IdentIndex].DataType;

// cyyyyyyyyyyyyyyyyyyyyy
	  if (ValType = STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	    ValType := POINTERTOK;

  //writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType ,' | ',ValType);


	  if (ValType = ENUMTYPE) and (Ident[IdentIndex].DataType = ENUMTYPE) then
	    ValType := Ident[IdentIndex].AllocElementType;


//	  if ValType in IntegerTypes then
//	    if DataSize[ValType] > DataSize[VarType] then ValType := VarType;     // skracaj typ danych    !!! niemozliwe skoro VarType = INTEGERTOK

	  if (Ident[IdentIndex].Kind = CONSTANT) and (ValType in Pointers) then
	   ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	  else
	   ConstVal := Ident[IdentIndex].Value;


	    if (ValType in IntegerTypes) and (VarType in [SINGLETOK, HALFSINGLETOK]) then Int2Float(ConstVal);

	    move(ConstVal, ftmp, sizeof(ftmp));

	    if (VarType = HALFSINGLETOK) {or (ValType = HALFSINGLETOK)} then begin
	      ConstVal := CardToHalf( ftmp[1] );
	      //ValType := HALFSINGLETOK;
	    end;

	    if (VarType = SINGLETOK) then begin
	      ConstVal := ftmp[1];
	      //ValType := SINGLETOK;
	    end;


	  if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
	     (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET) then

	   Push(ConstVal, ASPOINTERTORECORD, DataSize[ValType], IdentIndex)
	  else
	  if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements = 0) then
	   Push(ConstVal, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex)
	  else
	   Push(ConstVal, Ord(Ident[IdentIndex].Kind = VARIABLE), DataSize[ValType], IdentIndex);


	  if (BLOCKSTACKTOP = 1) then
	    if not (Ident[IdentIndex].isInit or Ident[IdentIndex].isInitialized or Ident[IdentIndex].LoopVariable) then
	      warning(i, VariableNotInit, IdentIndex);

	  end else begin	// isError


	   if (ValType in [SINGLETOK, HALFSINGLETOK]) or (VarType in [SINGLETOK, HALFSINGLETOK]) then begin	// constants

	    if ValType in IntegerTypes then Int2Float(ConstVal);

	    move(ConstVal, ftmp, sizeof(ftmp));

	    if (VarType = HALFSINGLETOK) or (ValType = HALFSINGLETOK) then begin
	      ConstVal := CardToHalf( ftmp[1] );
	      ValType := HALFSINGLETOK;
	    end else begin
	      ConstVal := ftmp[1];
	      ValType := SINGLETOK;
	    end;

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
    Result := CompileAddress(i-1, ValType, AllocElementType);


  INTNUMBERTOK:
    begin

    ConstVal := Tok[i].Value;
    ValType := GetValueType(ConstVal);

    if VarType in RealTypes then begin
     Int2Float(ConstVal);


     move(ConstVal, ftmp, sizeof(ftmp));

     if VarType = HALFSINGLETOK then
      ConstVal := CardToHalf( ftmp[1] )
     else
     if VarType = SINGLETOK then
      ConstVal := ftmp[1];

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, DataSize[ValType]);

    isZero := (ConstVal = 0);

    Result := i;
    end;


  FRACNUMBERTOK:
    begin

    fl := Tok[i].FracValue;

    ftmp[0] := round(fl * TWOPOWERFRACBITS);
    ftmp[1] := integer(fl);

    move(ftmp, ConstVal, sizeof(ftmp));

    ValType := REALTOK;

    if VarType in RealTypes then begin

     case VarType of
   	    SINGLETOK: ConstVal := ftmp[1];
	HALFSINGLETOK: ConstVal := CardToHalf( ftmp[1] );
     else
       ConstVal := ftmp[0]
     end;

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, DataSize[ValType]);

    isZero := (ConstVal = 0);

    Result := i;
    end;


  STRINGLITERALTOK:
    begin
    Push(Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE, ASVALUE, DataSize[STRINGPOINTERTOK]);
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

// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = DEREFERENCETOK then begin

     if ValType = POINTERTOK then begin

	asm65(#9'lda :STACKORIGIN,x');
    	asm65(#9'sta :bp2');
    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    	asm65(#9'sta :bp2+1');
    	asm65(#9'ldy #$00');

    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

    	inc(j);

     end else
      iError(j + 1, IllegalQualifier);

    end else begin

    if ValType in IntegerTypes + RealTypes then begin

     ExpandParam(SMALLINTTOK, ValType);

     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta :STACKORIGIN,x');

    end else
      Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken(SHORTREALTOK) + '"');

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


// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = DEREFERENCETOK then begin

     if ValType = POINTERTOK then begin

	asm65(#9'lda :STACKORIGIN,x');
    	asm65(#9'sta :bp2');
    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    	asm65(#9'sta :bp2+1');
    	asm65(#9'ldy #$00');

    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

    	inc(j);

     end else
      iError(j + 1, IllegalQualifier);

   end else begin

    if ValType in IntegerTypes + RealTypes then begin

     ExpandParam(INTEGERTOK, ValType);

     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta :STACKORIGIN,x');

    end else
      Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken(REALTOK) + '"');

    end;

    CheckTok(j + 1, CPARTOK);

    ValType := REALTOK;

    Result := j + 1;
    end;



 HALFSINGLETOK:
   begin

   if Tok[i + 1].Kind <> OPARTOK then
    Error(i, 'type identifier not allowed here');

    j := CompileExpression(i + 2, ValType);

// ASPOINTERTODEREFERENCE

    if Tok[j + 1].Kind = DEREFERENCETOK then begin

     if ValType = POINTERTOK then begin

	asm65(#9'lda :STACKORIGIN,x');
    	asm65(#9'sta :bp2');
    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    	asm65(#9'sta :bp2+1');
    	asm65(#9'ldy #$00');

    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

    	inc(j);

     end else
      iError(j + 1, IllegalQualifier);

    end else begin

    if ValType in [SHORTREALTOK, REALTOK] then
     Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken(HALFSINGLETOK) + '"');


    if ValType in IntegerTypes + RealTypes then begin

     ExpandParam(INTEGERTOK, ValType);

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @F16_I2F.SV');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @F16_I2F.SV+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @F16_I2F.SV+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @F16_I2F.SV+3');

			asm65(#9'jsr @F16_I2F');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
    end else
      Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken(HALFSINGLETOK) + '"');

    end;

    CheckTok(j + 1, CPARTOK);

    ValType := HALFSINGLETOK;

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

// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = DEREFERENCETOK then begin

     if ValType = POINTERTOK then begin

	asm65(#9'lda :STACKORIGIN,x');
    	asm65(#9'sta :bp2');
    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    	asm65(#9'sta :bp2+1');
    	asm65(#9'ldy #$00');

    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'iny');
    	asm65(#9'lda (:bp2),y');
    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

    	inc(j);

     end else
      iError(j + 1, IllegalQualifier);


   end else begin

	  if ValType in [SHORTREALTOK, REALTOK] then
	   Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken(SINGLETOK) + '"');


	  if ValType in IntegerTypes + RealTypes then begin

	    ExpandParam(INTEGERTOK, ValType);

	    asm65(#9'jsr @I2F');

	  end else
	   Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "'+InfoAboutToken(SINGLETOK) + '"');

   end;

	end;

    CheckTok(j + 1, CPARTOK);

    ValType := SINGLETOK;

    Result := j + 1;

    end;


  INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, PCHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK:	// type conversion operations
    begin

   if Tok[i + 1].Kind <> OPARTOK then
    Error(i, 'type identifier not allowed here');

    j := CompileExpression(i + 2, ValType, Tok[i].Kind);

    if (ValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) and (Tok[i + 3].Kind <> OBRACKETTOK) then begin

      IdentIndex := GetIdent(Tok[i + 2].Name^);

      if (Ident[IdentIndex].DataType in Pointers) and ( (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> RECORDTOK) ) then
       if ((Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0,1])) or (Ident[IdentIndex].DataType = STRINGPOINTERTOK) then

       else
	iError(i + 2, IllegalTypeConversion, IdentIndex, Tok[i].Kind);

    end;

// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = DEREFERENCETOK then
     if ValType = POINTERTOK then begin

	asm65(#9'lda :STACKORIGIN,x');
    	asm65(#9'sta :bp2');
    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    	asm65(#9'sta :bp2+1');
    	asm65(#9'ldy #$00');

	case DataSize[Tok[i].Kind] of

	 1: begin
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN,x');
	    end;

	 2: begin
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN,x');
		asm65(#9'iny');
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
	    end;

	 4: begin
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN,x');
		asm65(#9'iny');
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'iny');
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'iny');
	    	asm65(#9'lda (:bp2),y');
	    	asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
	    end;

	end;

    	inc(j);

     end else
      iError(j + 1, IllegalQualifier);


    if not(ValType in AllTypes) then
      iError(i, TypeMismatch);

    ExpandParam(Tok[i].Kind, ValType);

    CheckTok(j + 1, CPARTOK);

    ValType := Tok[i].Kind;


    if Tok[j + 2].Kind = DEREFERENCETOK then
      if (ValType = PCHARTOK) then begin

        ValType := CHARTOK;

        inc(j);

      end else
       iError(j + 1, IllegalQualifier);

    Result := j + 1;

    end;

else
  iError(i, IdNumExpExpected);
end;// case


end;// CompileFactor


procedure ResizeType(var ValType: Byte);
// dla operacji SHL, MUL rozszerzamy typ dla wyniku operacji
begin

  if ValType in [BYTETOK, WORDTOK, SHORTINTTOK, SMALLINTTOK] then inc(ValType);

end;


procedure RealTypeConversion(var ValType, RightValType: Byte; Kind: Byte = 0);
begin

  If ((ValType = SINGLETOK) or (Kind = SINGLETOK)) and (RightValType in IntegerTypes) then begin

//   writeln(ValType,',',RightValType);

   ExpandParam(INTEGERTOK, RightValType);

   asm65(#9'jsr @I2F');

   if (ValType <> SINGLETOK) and (Kind = SINGLETOK) then
    RightValType := Kind
   else
    RightValType := ValType;
  end;


  If (ValType in IntegerTypes) and ((RightValType = SINGLETOK) or (Kind = SINGLETOK)) then begin

   ExpandParam_m1(INTEGERTOK, ValType);

   asm65(#9'jsr @I2F_m');

   if (RightValType <> SINGLETOK) and (Kind = SINGLETOK) then
    ValType := Kind
   else
    ValType := RightValType;
  end;


  If ((ValType = HALFSINGLETOK) or (Kind = HALFSINGLETOK)) and (RightValType in IntegerTypes) then begin

   ExpandParam(INTEGERTOK, RightValType);

//   asm65(#9'jsr @F16_I2F');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @F16_I2F.SV');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @F16_I2F.SV+1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta @F16_I2F.SV+2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta @F16_I2F.SV+3');

			asm65(#9'jsr @F16_I2F');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

   if (ValType <> HALFSINGLETOK) and (Kind = HALFSINGLETOK) then
    RightValType := Kind
   else
    RightValType := ValType;

  end;


  If (ValType in IntegerTypes) and ((RightValType = HALFSINGLETOK) or (Kind = HALFSINGLETOK)) then begin

   ExpandParam_m1(INTEGERTOK, ValType);

//   asm65(#9'jsr @F16_I2F');//_m');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta @F16_I2F.SV');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta @F16_I2F.SV+1');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'sta @F16_I2F.SV+2');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
			asm65(#9'sta @F16_I2F.SV+3');

			asm65(#9'jsr @F16_I2F');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda :eax+1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');


   if (RightValType <> HALFSINGLETOK) and (Kind = HALFSINGLETOK) then
    ValType := Kind
   else
    ValType := RightValType;
  end;



  If ((ValType in [REALTOK, SHORTREALTOK]) or (Kind in [REALTOK, SHORTREALTOK])) and (RightValType in IntegerTypes) then begin

   ExpandParam(INTEGERTOK, RightValType);

   asm65(#9'jsr @expandToREAL');
{
   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
   asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
   asm65(#9'lda :STACKORIGIN,x');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'lda #$00');
   asm65(#9'sta :STACKORIGIN,x');
}
   if not(ValType in [REALTOK, SHORTREALTOK]) and (Kind in [REALTOK, SHORTREALTOK]) then
    RightValType := Kind
   else
    RightValType := ValType;

  end;


  If (ValType in IntegerTypes) and ((RightValType in [REALTOK, SHORTREALTOK]) or (Kind in [REALTOK, SHORTREALTOK])) then begin

   ExpandParam_m1(INTEGERTOK, ValType);

   asm65(#9'jsr @expandToREAL1');
{
   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
   asm65(#9'lda :STACKORIGIN-1,x');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'lda #$00');
   asm65(#9'sta :STACKORIGIN-1,x');
}

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
 else begin

  if ValType in RealTypes then VarType := ValType;

  j := CompileFactor(i, isZero, ValType, VarType);

 end;

while Tok[j + 1].Kind in [MULTOK, DIVTOK, MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] do
  begin


  if ValType in RealTypes then VarType := ValType;


  if Tok[j + 1].Kind in [MULTOK, DIVTOK] then
   k := CompileFactor(j + 2, isZero, RightValType, VarType)
  else
   k := CompileFactor(j + 2, isZero, RightValType, INTEGERTOK);

  if (Tok[j + 1].Kind in [MODTOK, IDIVTOK]) and isZero then
   Error(j + 1, 'Division by zero');


  if ((ValType in [HALFSINGLETOK, SINGLETOK]) and (RightValType in [SHORTREALTOK, REALTOK])) or
   ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [HALFSINGLETOK, SINGLETOK])) then
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

  if Tok[j + 1].Kind = MULTOK then
   if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
    if DataSize[ValType] > DataSize[VarType] then ValType:=VarType;

  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  case Tok[j + 1].Kind of							// !!! tutaj a nie przed ExpandExpression
   MULTOK: begin ResizeType(ValType); ExpandExpression(VarType, 0, 0) end;

   SHRTOK: if (ValType in SignedOrdinalTypes) and (DataSize[ValType] > 1) then begin ResizeType(ValType); ResizeType(ValType) end;	// int:=smallint(-90100) shr 4;

   SHLTOK: begin ResizeType(ValType); ResizeType(ValType) end;	 	        // !!! Silly Intro lub "x(byte) shl 14" tego wymaga
  end;

  j := k;
  end;

Result := j;
end;	// CompileTerm


function CompileSimpleExpression(i: Integer; out ValType: Byte; VarType: Byte): Integer;
var
  j, k: Integer;
  ConstVal: Int64;
  RightValType: Byte;
  ftmp: TFloat;
  fl: single;
begin

if Tok[i].Kind in [PLUSTOK, MINUSTOK] then j := i + 1 else j := i;

if SafeCompileConstExpression(j, ConstVal, ValType, VarType) then begin

 if (ValType in IntegerTypes) and (VarType in RealTypes) then begin Int2Float(ConstVal); ValType := VarType end;

 if VarType in RealTypes then ValType := VarType;


 if Tok[i].Kind = MINUSTOK then
   if ValType in RealTypes then begin		// Unary minus (RealTypes)

     move(ConstVal, ftmp, sizeof(ftmp));
     move(ftmp[1], fl, sizeof(fl));

     fl := -fl;

     ftmp[0] := round(fl * TWOPOWERFRACBITS);
     ftmp[1] := integer(fl);

     move(ftmp, ConstVal, sizeof(ftmp));

   end else begin
     ConstVal := -ConstVal;     		// Unary minus (IntegerTypes)

     if ValType in IntegerTypes then
       ValType := GetValueType(ConstVal);

   end;


 if ValType = SINGLETOK then begin
  move(ConstVal, ftmp, sizeof(ftmp));
  ConstVal := ftmp[1];
 end;

 if ValType = HALFSINGLETOK then begin
  move(ConstVal, ftmp, sizeof(ftmp));
  ConstVal := CardToHalf( ftmp[1] );
 end;


 Push(ConstVal, ASVALUE, DataSize[ValType]);


end else begin	// if SafeCompileConstExpression

 j := CompileTerm(j, ValType, VarType);

 if Tok[i].Kind = MINUSTOK then begin

  GenerateUnaryOperation(MINUSTOK, ValType);	// Unary minus

  if ValType in UnsignedOrdinalTypes then	// jesli odczytalismy typ bez znaku zamieniamy na 'ze znakiem'
   if ValType = BYTETOK then
     ValType := SMALLINTTOK
   else
     ValType := INTEGERTOK;

 end;

end;


while Tok[j + 1].Kind in [PLUSTOK, MINUSTOK, ORTOK, XORTOK] do
  begin

  if ValType in RealTypes then VarType := ValType;

  k := CompileTerm(j + 2, RightValType, VarType);

  if ((ValType in [HALFSINGLETOK, SINGLETOK]) and (RightValType in [SHORTREALTOK, REALTOK])) or
     ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [HALFSINGLETOK, SINGLETOK])) then
      Error(j + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(RightValType)+'"');


  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);//, VarType);


  if (ValType = POINTERTOK) {and (VarType = POINTERTOK)} and (RightValType in IntegerTypes) then RightValType := POINTERTOK;
//    CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);

  ValType := GetCommonType(j + 1, ValType, RightValType);

  CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);


  if Tok[j + 1].Kind in [PLUSTOK, MINUSTOK] then begin				// dla PLUSTOK, MINUSTOK rozszerz typ wyniku

    if (Tok[j + 1].Kind = MINUSTOK) and (RightValType in UnsignedOrdinalTypes) and (VarType in SignedOrdinalTypes + [BOOLEANTOK]) then begin

	if (ValType = VarType) and (RightValType = VarType) then
// do nothing, all types are with sign
	else
         ExpandExpression(ValType, RightValType, VarType, true);		// promote to type with sign

    end else
      ExpandExpression(ValType, RightValType, VarType);

  end else
    ExpandExpression(ValType, RightValType, 0);

  if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
   if DataSize[ValType] > DataSize[VarType] then ValType:=VarType;


//  if (VarType = INTEGERTOK) and (Tok[j + 1].Kind in [PLUSTOK, MINUSTOK]) then ResizeType(ValType);		// dla PLUSTOK, MINUSTOK rozszerz typ wyniku

  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  j := k;
  end;

Result := j;
end;// CompileSimpleExpression


function CompileExpression(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType, ConstValType, isZero: Byte;
  sLeft, sRight, cRight, yes: Boolean;
  ConstVal, ConstValRight: Int64;
  ftmp: TFloat;
begin

 ftmp[0]:=0;
 ftmp[1]:=0;

 isZero := INTEGERTOK;

 cRight:=false;

 if SafeCompileConstExpression(i, ConstVal, ValType, VarType, False) then begin

   if (ValType in IntegerTypes) and (VarType in RealTypes) then begin Int2Float(ConstVal); ValType := VarType end;

   if VarType in RealTypes then ValType := VarType;


   if (ValType = HALFSINGLETOK) {or ((VarType = HALFSINGLETOK) and (ValType in RealTypes))} then begin
     move(ConstVal, ftmp, sizeof(ftmp));
     ConstVal := CardToHalf( ftmp[1] );
     ValType := HALFSINGLETOK;
     VarType := HALFSINGLETOK;
   end;

   if (ValType = SINGLETOK) {or ((VarType = SINGLETOK) and (ValType in RealTypes))} then begin
     move(ConstVal, ftmp, sizeof(ftmp));
     ConstVal := ftmp[1];
     ValType := SINGLETOK;
     VarType := SINGLETOK;
   end;

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


if Tok[i + 1].Kind = INTOK then writeln('IN');				// not yet programmed


if Tok[i + 1].Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
  begin


  if ValType in RealTypes then VarType := ValType;


  j := CompileSimpleExpression(i + 2, RightValType, VarType);


  k := i + 2;
  if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
   if (ConstValType in IntegerTypes) and (VarType in IntegerTypes) then begin

    if ConstVal = 0 then begin
      isZero := BYTETOK;

      if (ValType in SignedOrdinalTypes) and (Tok[i + 1].Kind in [EQTOK, NETOK]) then begin

	case ValType of
	 SHORTINTTOK: ValType := BYTETOK;
	 SMALLINTTOK: ValType := WORDTOK;
	  INTEGERTOK: ValType := CARDINALTOK;
	end;

      end;

    end;


    if ConstValType in SignedOrdinalTypes then
     if ConstVal < 0 then isZero := SHORTINTTOK;

    cRight := true;

    ConstValRight := ConstVal;
    RightValType  := ConstValType;

   end;		// if ConstValType in IntegerTypes



  if (Tok[i + 2].Kind = STRINGLITERALTOK) or (RightValType = STRINGPOINTERTOK) then sRight:=true else
   if (RightValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) then
    if (Ident[GetIdent(Tok[i + 2].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i + 2].Name^)) > 0) then sRight:=true;


//  if (ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [SHORTREALTOK, REALTOK]) then
//    RightValType := ValType;

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);//, VarType);

//  writeln(VarType,  ' | ', ValType,'/',RightValType,',',isZero,',',Tok[i + 1].Kind ,' : ', ConstVal);


  if (Tok[i + 1].Kind in [LTTOK, GTTOK]) and (ValType in IntegerTypes) then begin

   yes:=false;

   if Tok[i + 1].Kind = LTTOK then begin

    case ValType of
     BYTETOK, WORDTOK, CARDINALTOK: yes := (isZero = BYTETOK);
//         BYTETOK: yes := (ConstVal = Low(byte));	// < 0
//         WORDTOK: yes := (ConstVal = Low(word));	// < 0
//     CARDINALTOK: yes := (ConstVal = Low(cardinal));	// < 0
     SHORTINTTOK: yes := (ConstVal = Low(shortint));	// < -128
     SMALLINTTOK: yes := (ConstVal = Low(smallint));	// < -32768
      INTEGERTOK: yes := (ConstVal = Low(integer));	// < -2147483648
    end;

   end else

    case ValType of
         BYTETOK: yes := (ConstVal = High(byte));	// > 255
         WORDTOK: yes := (ConstVal = High(word));	// > 65535
     CARDINALTOK: yes := (ConstVal = High(cardinal));	// > 4294967295
     SHORTINTTOK: yes := (ConstVal = High(shortint));	// > 127
     SMALLINTTOK: yes := (ConstVal = High(smallint));	// > 32767
      INTEGERTOK: yes := (ConstVal = High(integer));	// > 2147483647
    end;

   if yes then begin
     warning(i + 2, AlwaysFalse);
     warning(i + 2, UnreachableCode);
   end;

  end;


  if (isZero = BYTETOK) and (ValType in UnsignedOrdinalTypes) then
   case Tok[i + 1].Kind of
//    LTTOK: warning(i + 2, AlwaysFalse);		// BYTE, WORD, CARDINAL '<' 0
    GETOK: warning(i + 2, AlwaysTrue);			// BYTE, WORD, CARDINAL '>', '>=' 0
   end;


  if (isZero = SHORTINTTOK) and (ValType in UnsignedOrdinalTypes) then
   case Tok[i + 1].Kind of

    EQTOK, LTTOK, LETOK: begin				// BYTE, WORD, CARDINAL '=', '<'. '<=' -X
			  warning(i + 2, AlwaysFalse);
			  warning(i + 2, UnreachableCode);
			 end;

	   GTTOK, GETOK: warning(i + 2, AlwaysTrue);	// BYTE, WORD, CARDINAL '>', '>=' -X
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
  BreakPosStack[BreakPosStackTop].ptr := CodeSize;
  BreakPosStack[BreakPosStackTop].brk := false;
  BreakPosStack[BreakPosStackTop].cnt := false;

end;


procedure RestoreBreakAddress;
begin

  if BreakPosStack[BreakPosStackTop].brk then asm65('b_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

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

       if fBlockRead_ParamType[NumActualParams] in Pointers + [UNTYPETOK] then begin

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
	i := CompileExpression(i + 2 , ActualParamType);	// Evaluate actual parameters and push them onto the stack

       GetCommonType(i, fBlockRead_ParamType[NumActualParams], ActualParamType);

       ExpandParam(fBlockRead_ParamType[NumActualParams], ActualParamType);

       case NumActualParams of
	1: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.buffer');	// VAR LABEL;
	2: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.nrecord');	// VAR LABEL: POINTER;
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
  IfLocalCnt, CaseLocalCnt, NumCaseStatements, vlen: integer;
  oldPass, oldCodeSize: integer;
  Param: TParamList;
  ExpressionType, IndirectionLevel, ActualParamType, ConstValType, VarType, SelectorType: Byte;
  Value, ConstVal, ConstVal2: Int64;
  Down, ExitLoop, yes, DEREFERENCE, ADDRESS: Boolean;			  // To distinguish TO / DOWNTO loops
  CaseLabelArray: TCaseLabelArray;
  CaseLabel: TCaseLabel;
  Name, EnumName, svar, par1, par2: string;
  forBPL: byte;
begin

Result:=i;

FillChar(Param, sizeof(Param), 0);

IdentIndex := 0;
ExpressionType := 0;

par1:='';
par2:='';

StopOptimization;


case Tok[i].Kind of


  INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK, SHORTREALTOK, REALTOK, SINGLETOK, HALFSINGLETOK :	// type conversion operations
    begin

     if Tok[i + 1].Kind <> OPARTOK then
      Error(i, 'type identifier not allowed here');

     StartOptimization(i + 1);

     if Tok[i + 2].Kind <> IDENTTOK then
      iError(i + 2, VariableExpected)
     else
      IdentIndex := GetIdent(Tok[i + 2].Name^);

     VarType := Ident[IdentIndex].DataType;

     if VarType <> Tok[i].Kind then
      Error(i, 'Argument cannot be assigned to');

     CheckTok(i + 3, CPARTOK);

     if Tok[i + 4].Kind <> ASSIGNTOK then
      iError(i + 4, IllegalExpression);

     i := CompileExpression(i + 5, ExpressionType, VarType);

     GenerateAssignment(ASPOINTER, DataSize[VarType], IdentIndex);

     Result := i;

   end;


  IDENTTOK:
    begin
     IdentIndex := GetIdent(Tok[i].Name^);

    if (IdentIndex > 0) and (Ident[IdentIndex].Kind = FUNC) and (BlockStackTop > 1) and (Tok[i + 1].Kind <> OPARTOK) then
     for j:=NumIdent downto 1 do
      if (Ident[j].ProcAsBlock = NumBlocks) and (Ident[j].Kind = FUNC) then begin
	if (Ident[j].Name = Ident[IdentIndex].Name) and (Ident[j].UnitIndex = Ident[IdentIndex].UnitIndex) then IdentIndex := GetIdentResult(NumBlocks);
	Break;
      end;


    if IdentIndex > 0 then

      case Ident[IdentIndex].Kind of


	LABELTYPE:
	  begin
	   CheckTok(i + 1, COLONTOK);

	   if Ident[IdentIndex].isInit then
	     Error(i , 'Label already defined');

	   Ident[IdentIndex].isInit := true;

	   asm65(Ident[IdentIndex].Name);

	   Result := i;

	  end;


	VARIABLE, TYPETOK:								// Variable or array element assignment
	  begin

	   VarType:=0;

	   StartOptimization(i + 1);


	   if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = PROCVARTOK) and ( not (Tok[i + 1].Kind in [ASSIGNTOK, OBRACKETTOK]) ) then begin

	        IdentTemp := GetIdent('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		CompileActualParameters(i, IdentTemp, IdentIndex);

		Result := i;
		exit;

	   end;


           IndirectionLevel := ASPOINTERTOPOINTER;

           if Tok[i + 1].Kind = OPARTOK then begin

//	    writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

	    if not (Ident[IdentIndex].DataType in [POINTERTOK, RECORDTOK, OBJECTTOK]) then
	      iError(i, IllegalExpression);

	    if Ident[IdentIndex].DataType = POINTERTOK then
	      VarType := Ident[IdentIndex].AllocElementType
	    else
	      VarType := Ident[IdentIndex].DataType;


            i := CompileExpression(i + 2, ExpressionType, POINTERTOK);

            CheckTok(i + 1, CPARTOK);


	    if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin

	      IndirectionLevel := ASPOINTERTODEREFERENCE;

	      IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);		// (pointer^).field :=

	      if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	      VarType := IdentTemp shr 16;
	      par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	      inc(i, 2);

	    end else

            if Tok[i + 2].Kind = DEREFERENCETOK then begin

	     IndirectionLevel := ASPOINTERTODEREFERENCE;

	     inc(i);

	     if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin

	       IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);		// (pointer)^.field :=

	       if IdentTemp < 0 then
	         Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	       VarType := IdentTemp shr 16;
	       par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	       inc(i, 2);

	     end;


	    end else begin


	     if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin

	       IndirectionLevel := ASPOINTERTODEREFERENCE;

	       IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);		// (pointer).field :=

	       if IdentTemp < 0 then
	         Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	       VarType := IdentTemp shr 16;
	       par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	       inc(i, 2);

	     end;


	    end;


	    inc(i);


	   end else

	   if Tok[i + 1].Kind = DEREFERENCETOK then				// With dereferencing '^'
	    begin

	    if not (Ident[IdentIndex].DataType in Pointers) then
	      iError(i + 1, IncompatibleTypeOf, IdentIndex);
// cyyyyyyyyyyyyyy

	    if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	      VarType := STRINGPOINTERTOK
	    else
 	      VarType := Ident[IdentIndex].AllocElementType;

	    IndirectionLevel := ASPOINTERTOPOINTER;


//writeln(Ident[IdentIndex].name,',',VarTYpe,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements);

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

	     inc(i, 2);

	    end;

	    i := i + 1;
	    end
	  else if (Tok[i + 1].Kind = OBRACKETTOK) then				// With indexing
	    begin

	    if not (Ident[IdentIndex].DataType in Pointers) then
	      iError(i + 1, IncompatibleTypeOf, IdentIndex);

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	    i := CompileArrayIndex(i, IdentIndex);

    	    VarType := Ident[IdentIndex].AllocElementType;

//	    if (Ident[IdentIndex].NumAllocElements = 0) and (VarType <> CHARTOK) then
//	       Error(i, 'Array type required');

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
	     if VarType in [RECORDTOK, OBJECTTOK, PROCVARTOK] then VarType := POINTERTOK;

	    //CheckTok(i + 1, CBRACKETTOK);

	    inc(i);

	    end
	  else								// Without dereferencing or indexing
	    begin

	    if (Ident[IdentIndex].PassMethod = VARPASSING) then begin
	     IndirectionLevel := ASPOINTERTOPOINTER;

	     if Ident[IdentIndex].AllocElementType = UNTYPETOK then
	      VarType := Ident[IdentIndex].DataType			// RECORD.
	     else
	      VarType := Ident[IdentIndex].AllocElementType;

	    end else begin
	     IndirectionLevel := ASPOINTER;
	     VarType := Ident[IdentIndex].DataType;
	    end;

	    end;


	   if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = PROCVARTOK) and (Tok[i + 1].Kind <> ASSIGNTOK) then begin

	        IdentTemp := GetIdent('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		CompileActualParameters(i, IdentTemp, IdentIndex);

		Result := i;
		exit;

	   end else
	    CheckTok(i + 1, ASSIGNTOK);

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',IndirectionLevel);


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
		       asm65(#9'mwy ' + Ident[IdentIndex].Name + ' :bp2');
		       asm65(#9'ldy #$00');
		       asm65(#9'mva #$01 (:bp2),y');
		       asm65(#9'iny');
		       asm65(#9'mva #$' + IntToHex(Tok[i + 2].Value , 2) + ' (:bp2),y');
		     end;

		     ASPOINTERTOARRAYORIGIN:
		     begin
		       asm65(#9'mwy ' + Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'ldy :STACKORIGIN,x');
		       asm65(#9'mva #$' + IntToHex(Tok[i + 2].Value , 2) + ' (:bp2),y');

		       a65(__subBX);
		     end;

		     ASPOINTER:
		     begin
		       asm65(#9'mva #$01 ' + GetLocalName(IdentIndex, 'adr.'));
		       asm65(#9'mva #$' + IntToHex(Tok[i + 2].Value , 2) + ' ' + GetLocalName(IdentIndex, 'adr.') + '+1');
		     end;

		 end;		// case IndirectionLevel

		Result := i + 2;
		end;		// case CHARLITERALTOK

 // String assignment to pointer  f:='string'

	STRINGLITERALTOK:
		begin

		Ident[IdentIndex].isInit := true;

		StopOptimization;

		ResetOpty;

		if Ident[IdentIndex].NumAllocElements in [0,1] then
		  NumCharacters := Tok[i + 2].StrLength
		else
		  NumCharacters := Min(Tok[i + 2].StrLength, Ident[IdentIndex].NumAllocElements - 1);

		 case IndirectionLevel of

		   ASPOINTERTOPOINTER:

		   if Tok[i + 2].StrLength = 0 then begin
		     asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
		     asm65(#9'ldy #$00');
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
		     else begin

		      if Ident[IdentIndex].DataType = POINTERTOK then
//		       asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN + 1, 4)+' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(vlen))
		       k := Tok[i + 2].StrAddress - CODEORIGIN + 1
		      else
//		       asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(Succ(NumCharacters)));
		       k := Tok[i + 2].StrAddress - CODEORIGIN;

		       vlen := Succ(NumCharacters);

		       if vlen <=256 then begin
		        asm65(#9'ldy #256-'+IntToStr(vlen));
			asm65(#9'mva:rne CODEORIGIN+$'+ IntToHex(k, 4) +'+'+IntToStr(vlen)+'-256,y ' + GetLocalName(IdentIndex, 'adr.')+'+'+IntToStr(vlen)+'-256,y+');
		       end else
		        asm65(#9'@move #CODEORIGIN+$'+ IntToHex(k, 4) +' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(vlen));

		     end;
//move_1

		     if Succ(Tok[i + 2].StrLength) > Ident[IdentIndex].NumAllocElements then begin
		      Warning(i + 2, ShortStringLength);
		      asm65(#9'mva #$'+IntToHex(NumCharacters,2)+' '+GetLocalName(IdentIndex, 'adr.'));    //adr.'+Ident[IdentIndex].Name);
		     end;

		   end;

		 end;		// case IndirectionLevel

		Result := i + 2;
		end;		// case STRINGLITERALTOK


	IDENTTOK:
		begin

		 Ident[IdentIndex].isInit := true;

		 //StopOptimization;

		 Result := CompileExpression(i + 2, ExpressionType, VarType);      // Right-hand side expression

		 asm65;

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

		       asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'ldy #$00');
		       asm65(#9'mva #$01 (:bp2),y');
		       asm65(#9'iny');
		       asm65(#9'mva :STACKORIGIN,x (:bp2),y');

		       a65(__subBX);
		     end;

		   ASPOINTERTOARRAYORIGIN:
		     begin

		      asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
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

		 // StopOptimization;

		 // ResetOpty;

		  svar := GetLocalName(IdentIndex);

		  case IndirectionLevel of

		    ASPOINTER, ASPOINTERTOPOINTER:
		      begin

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @move.src');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @move.src+1');

			if Ident[IdentIndex].DataType = POINTERTOK then
			 asm65(#9'@moveSTRING_1 ' + GetLocalName(IdentIndex) )
			else begin

		         if Ident[IdentIndex].NumAllocElements = 256 then begin

			  asm65(#9'mwy '+svar+' :bp2');

			  asm65(#9'ldy #$00');
			  asm65(#9'mva:rne (@move.src),y (:bp2),y+');

			 end else
			  asm65(#9'@moveSTRING ' + GetLocalName(IdentIndex) + ' #' + IntToStr(Ident[IdentIndex].NumAllocElements));

			end;

			a65(__subBX);

			StopOptimization;
			ResetOpty;

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
	      begin								// Usual assignment

	      if VarType = UNTYPETOK then
		Error(i, 'Assignments to formal parameters and open arrays are not possible');

	      Result := CompileExpression(i + 2, ExpressionType, VarType);	// Right-hand side expression

	      k := i + 2;


	      RealTypeConversion(VarType, ExpressionType);

	      if (VarType in [SHORTREALTOK, REALTOK]) and (ExpressionType in [SHORTREALTOK, REALTOK]) then
		ExpressionType := VarType;


	      if (VarType = POINTERTOK)	and (ExpressionType = STRINGPOINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType = CHARTOK) then begin	// +1
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


//	if (Tok[k].Kind = IDENTTOK) then
//	  writeln(Ident[IdentIndex].Name,'/',Tok[k].Name^,',', VarType,',', ExpressionType,' - ', Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' | ',Ident[GetIdent(Tok[k].Name^)].DataType,':',Ident[GetIdent(Tok[k].Name^)].AllocElementType,':',Ident[GetIdent(Tok[k].Name^)].NumAllocElements ,' / ',IndirectionLevel)
//	else
//	  writeln(Ident[IdentIndex].Name,',', VarType,',', ExpressionType,' - ', Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' / ',IndirectionLevel);


	      CheckAssignment(i + 1, IdentIndex);

	      if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) {and not (Ident[IdentIndex].AllocElementType in [PROCEDURETOK, FUNC])} then begin

//writeln(Ident[IdentIndex].idtype,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].Name);
//writeln(Ident[GetIdent(Ident[IdentIndex].Name)].AllocElementType);

	       if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then
		 GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType)
	       else
	         GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, ExpressionType);

	      end else
	       if (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) then begin

		  if (ExpressionType in Pointers - [STRINGPOINTERTOK]) and (Tok[k].Kind = IDENTTOK) then begin

		    IdentTemp := GetIdent(Tok[k].Name^);

		    if (IdentTemp > 0) and (Ident[IdentTemp].Kind = FUNCTIONTOK) then
		      IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		    {if (Tok[i + 3].Kind <> OBRACKETTOK) and ((Elements(IdentTemp) <> Elements(IdentIndex)) or (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType)) then
		     iError(k, IncompatibleTypesArray, GetIdent(Tok[k].Name^), ExpressionType )
		    else
		     if (Elements(IdentTemp) > 0) and (Tok[i + 3].Kind <> OBRACKETTOK) then
		      iError(k, IncompatibleTypesArray, IdentTemp, ExpressionType )
		    else}

		    if Ident[IdentTemp].AllocElementType = RECORDTOK then
		    // GetCommonType(i + 1, VarType, RECORDTOK)
		    else

		    if (Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentTemp].AllocElementType <> UNTYPETOK) and (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType) and (Tok[k + 1].Kind <> OBRACKETTOK) then begin

		      if ((Ident[IdentTemp].NumAllocElements > 0) {and (Ident[IdentTemp].AllocElementType <> RECORDTOK)}) and ((Ident[IdentIndex].NumAllocElements > 0) {and (Ident[IdentIndex].AllocElementType <> RECORDTOK)}) then

		        iError(k, IncompatibleTypesArray, IdentTemp, -IdentIndex)

		      else begin

//      writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' | ',Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,':',Ident[IdentTemp].AllocElementType,':',Ident[IdentTemp].NumAllocElements);

		        if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].NumAllocElements = 0) and
		           (Ident[IdentTemp].DataType = POINTERTOK) and (Ident[IdentTemp].AllocElementType <> UNTYPETOK) and (Ident[IdentTemp].NumAllocElements = 0) then
			  Error(k, 'Incompatible types: got "^'+InfoAboutToken(Ident[IdentTemp].AllocElementType)+'" expected "^' + InfoAboutToken(Ident[IdentIndex].AllocElementType) + '"')
			else
			  iError(k, IncompatibleTypesArray, IdentTemp, ExpressionType);

		     end;


		    end;

		 end else
		    if (ExpressionType in [RECORDTOK, OBJECTTOK]) then begin

//writeln(vartype,',',ExpressionType);

			IdentTemp := GetIdent(Tok[k].Name^);

			case IndirectionLevel of
			           ASPOINTER:
				   if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] ) then
				    Error(k, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

			  ASPOINTERTOPOINTER:
				   if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK] ) then
				    Error(k, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');
			else
			  GetCommonType(i + 1, VarType, ExpressionType)

			end;

		    end else begin

//		 writeln('1> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,', P:', Ident[IdentIndex].PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

		      if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then

		      else
		      if (VarType in [RECORDTOK, OBJECTTOK]) then
                        Error(i, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) +'" expected "' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"')
		      else
		        GetCommonType(i + 1, VarType, ExpressionType);

		    end;

	       end else
			     if (VarType = ENUMTYPE) {and (Tok[k].Kind = IDENTTOK)} then begin

				  if (Tok[k].Kind = IDENTTOK) then
				    IdentTemp := GetIdent(Tok[k].Name^)
				  else
				    IdentTemp := 0;

				  if (IdentTemp > 0) and (Ident[IdentTemp].Kind = FUNCTIONTOK) then
				   IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

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


// writeln(vartype,',',ExpressionType,',',Ident[IdentIndex].Name);

//      	writeln('0> ',Ident[IdentIndex].Name,',',VarType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', ExpressionType,',',IndirectionLevel);

	      if (Ident[IdentIndex].PassMethod <> VARPASSING) and (IndirectionLevel <> ASPOINTERTODEREFERENCE) and (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) and (ExpressionType <> POINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType in {IntegerTypes}OrdinalTypes) and (ExpressionType in {IntegerTypes}OrdinalTypes) then

		else
		 if Ident[IdentIndex].AllocElementType <> 0 then
		   Error(i + 1, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) + '" expected "' + Ident[IdentIndex].Name + '"')
		 else
		   GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);

	      end;



	      if (VarType in [RECORDTOK, OBJECTTOK]) or ((VarType = POINTERTOK) and (ExpressionType in [RECORDTOK, OBJECTTOK]) ) then begin

		ADDRESS := false;

		if Tok[k].Kind = ADDRESSTOK then begin
		 inc(k);

		 ADDRESS := true;
		end;

		if Tok[k].Kind <> IDENTTOK then iError(k, IdentifierExpected);

		IdentTemp := GetIdent(Tok[k].Name^);


		if Ident[IdentIndex].PassMethod = Ident[IdentTemp].PassMethod then
		  case IndirectionLevel of
		    ASPOINTER:
			   if (Tok[k + 1].Kind <> DEREFERENCETOK) and (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK] ) then
			    Error(k, 'Incompatible types: got "^' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

 		    ASPOINTERTOPOINTER:
//			   if {(Tok[i + 1].Kind <> DEREFERENCETOK) and }(Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] ) then
//			    Error(k, 'Incompatible types: got "^' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');
		  else
  		    GetCommonType(i + 1, VarType, ExpressionType)
		  end;


               if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].PassMethod = Ident[IdentTemp].PassMethod) then begin

//		   writeln('2> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements);

		   if (ADDRESS = false) and {(Ident[IdentTemp].NumAllocElements > 0)} (Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements) and
	            (ExpressionType in [RECORDTOK, OBJECTTOK]) {or (Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements)} then
	  	     if (Ident[IdentTemp].DataType = POINTERTOK) and (Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK]) then
                       Error(i, 'Incompatible types: got "^' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "^' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"')
		     else
                       Error(i, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "^' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

	       end;


	       if (ExpressionType in [RECORDTOK, OBJECTTOK]) or ( (ExpressionType = POINTERTOK) and (Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK]) ) then begin

		svar := Tok[k].Name^;

		if (Ident[IdentTemp].DataType = RECORDTOK) and (Ident[IdentTemp].AllocElementType <> RECORDTOK) then
		  Name := 'adr.' + svar
		else
		  Name := svar;

		if Ident[IdentTemp].Kind = FUNCTIONTOK then begin
		  svar := GetLocalName(IdentTemp);

		  IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		  Name := svar + '.adr.result';
		  svar := svar + '.result';
		end;


		DEREFERENCE := false;
	        if (Tok[k + 1].Kind = DEREFERENCETOK) then begin
		 inc(k);

		 DEREFERENCE := true;
		end;


	        if Tok[k + 1].Kind = DOTTOK then begin

		 CheckTok(k + 2, IDENTTOK);

		 Name := svar + '.' + Tok[k+2].Name^;
		 IdentTemp := GetIdent(Name);

		end;

//writeln( Ident[IdentIndex].Name,',', Ident[IdentIndex].NumAllocElements, ',', Ident[IdentIndex].AllocElementType  ,' / ', Ident[IdentTemp].Name,',', Ident[IdentTemp].NumAllocElements,',',Ident[IdentTemp].AllocElementType );
//writeln( '>', Ident[IdentIndex].Name,',', Ident[IdentIndex].DataType, ',', Ident[IdentIndex].AllocElementTYpe );
//writeln( '>', Ident[IdentTemp].Name,',', Ident[IdentTemp].DataType, ',', Ident[IdentTemp].AllocElementTYpe );
//writeln(Types[5].Field[0].Name);


		if Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements then		// porownanie indeksow do tablicy TYPES
//		  iError(i, IncompatibleTypeOf, IdentTemp);
		  if (Ident[IdentIndex].NumAllocElements = 0) then
                    Error(i, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "' + InfoAboutToken(Ident[IdentIndex].DataType) + '"')
	          else
                    Error(i, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

		a65(__subBX);
		StopOptimization;

		ResetOpty;


		if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = RECORDTOK) and (Ident[IdentTemp].AllocElementTYpe = RECORDTOK) then begin

		  if DEREFERENCE then begin								// issue #98 fixed

	            asm65(#9'lda :bp2');
	            asm65(#9'add #' + Name + '-DATAORIGIN');
	            asm65(#9'sta :bp2');
	            asm65(#9'lda :bp2+1');
	            asm65(#9'adc #$00');
	            asm65(#9'sta :bp2+1');

		  end else begin

	            asm65(#9'sta :bp2');
	            asm65(#9'sty :bp2+1');

		  end;


	          if RecordSize(IdentIndex) <= 8 then begin

		   asm65(#9'ldy #$00');

		   for j:=0 to RecordSize(IdentIndex)-1 do begin
		    asm65(#9'lda (:bp2),y');
		    asm65(#9'sta adr.'+Ident[IdentIndex].Name + '+' + IntToStr(j));

		    if j <> RecordSize(IdentIndex)-1 then asm65(#9'iny');
		   end;

		  end else begin
		    asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
		    asm65(#9'mva:rpl (:bp2),y adr.'+Ident[IdentIndex].Name+',y-');
		  end;

		end else
		if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = RECORDTOK) and (RecordSize(IdentIndex) <= 8) then begin

		  if RecordSize(IdentIndex) = 1 then
		   asm65(#9' mva '+Name+' '+GetLocalName(IdentIndex, 'adr.'))
		  else
		   asm65(#9':'+IntToStr(RecordSize(IdentIndex))+' mva '+Name+'+# '+GetLocalName(IdentIndex, 'adr.')+'+#');

		end else
		 if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentTemp].DataType = POINTERTOK) then begin
{
		  if RecordSize(IdentIndex) <= 128 then begin

		    asm65(#9'mwy '+Name+' :bp2');
		    asm65(#9'mwy '+Ident[IdentIndex].Name+' :TMP');
		    asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
		    asm65(#9'mva:rpl (:bp2),y (:TMP),y-');

		  end else
}
		   asm65(#9'@move '+Name+' '+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)))

		 end else
		  if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = POINTERTOK) then begin

		   if RecordSize(IdentIndex) <= 128 then begin

		    asm65(#9'mwy '+Name+' :bp2');
		    asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
		    asm65(#9'mva:rpl (:bp2),y adr.'+Ident[IdentIndex].Name+',y-');

		   end else
		    asm65(#9'@move '+Name+' #adr.'+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)));

 		  end else begin

		   if (pos('adr.', Name) > 0) and (RecordSize(IdentIndex) <= 128) then begin

		    asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
		    asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
		    asm65(#9'mva:rpl '+Name+',y (:bp2),y-');

		   end else
		    asm65(#9'@move #'+Name+' '+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)));

		  end;

     	       end else	   // ExpressionType <> RECORDTOK + OBJECTTOK
		 GetCommonType(i + 1, ExpressionType, RECORDTOK);

	      end else

		if// (Tok[k].Kind = IDENTTOK) and
		   (VarType = STRINGPOINTERTOK) and (ExpressionType in Pointers) {and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK])} then begin

		 if Tok[k].Kind = ADDRESSTOK then
		   iError(i, IncompatibleTypes,  0, POINTERTOK, STRINGPOINTERTOK);


//	        if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) and
//	           (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK) and (ExpressionType = STRINGPOINTERTOK) then begin

		 if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) and (Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK) then begin

		  GenerateAssignment(ASSTRINGPOINTERTOARRAYORIGIN, DataSize[VarType], IdentIndex);

		  StopOptimization;
		  ResetOpty;

		 end else
		  GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

	        end else


// dla PROC, FUNC -> Ident[GetIdent(Tok[k].Name^)].NumAllocElements -> oznacza liczbe parametrow takiej procedury/funkcji

		if (VarType in Pointers) and ( (ExpressionType in Pointers) and (Tok[k].Kind = IDENTTOK) ) and
		   ( not (Ident[IdentIndex].AllocElementType in Pointers + [RECORDTOK, OBJECTTOK]) and not (Ident[GetIdent(Tok[k].Name^)].AllocElementType in Pointers + [RECORDTOK, OBJECTTOK])  ) (* and
		   (({DataSize[Ident[IdentIndex].AllocElementType] *} Ident[IdentIndex].NumAllocElements > 1) and ({DataSize[Ident[GetIdent(Tok[k].Name^)].AllocElementType] *} Ident[GetIdent(Tok[k].Name^)].NumAllocElements > 1)) *) then begin


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


	          if (Ident[IdentIndex].NumAllocElements > 1) and (Ident[IdentTemp].NumAllocElements > 1) then begin

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

		  end else
		   GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);


		end else
 	 	  iError(k, UnknownIdentifier);


	       end else
		GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

	      end;

//	    StopOptimization;

	  end;// VARIABLE


	PROCEDURETOK, FUNC, CONSTRUCTORTOK, DESTRUCTORTOK:			// Procedure, Function (without assignment) call
	  begin

//	  yes := (Ident[IdentIndex].Kind = FUNC);

	  if (Tok[i+1].Kind = OPARTOK) and (Tok[i+2].Kind=CPARTOK) then begin
	   inc(i, 2);
	   j := 0;
	  end else

	   Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc(Ident[IdentIndex].Name, IdentIndex, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then
	      iError(i, CantDetermine, IdentIndex)
	     else
              iError(i, WrongNumParameters, IdentIndex);

	    IdentIndex := IdentTemp;

//	  end;


          if (Ident[IdentIndex].isStdCall = false) then
	    StartOptimization(i)
	  else
          if optimize.use = false then StartOptimization(i);


	  inc(run_func);

	  CompileActualParameters(i, IdentIndex);

	  if Ident[IdentIndex].Kind = FUNC then a65(__subBX);	// zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji

	  dec(run_func);

	  Result := i;
	  end;	// PROC

      else
	Error(i, 'Assignment or procedure call expected but ' + Ident[IdentIndex].Name + ' found');
      end// case Ident[IdentIndex].Kind
    else
      iError(i, UnknownIdentifier)
    end;

  INFOTOK:
    begin

      if Pass = CODEGENERATIONPASS then writeln('User defined: ' + msgUser[Tok[i].Value]);

      Result := i;
    end;


  WARNINGTOK:
    begin

      Warning(i, UserDefined);

      Result := i;
    end;


  ERRORTOK:
    begin

      if Pass = CODEGENERATIONPASS then iError(i, UserDefined);

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


  PROCALIGNTOK:
    begin
     codealign.proc := Tok[i].Value;

     Result := i;
    end;


  LOOPALIGNTOK:
    begin
     codealign.loop := Tok[i].Value;

     Result := i;
    end;


  LINKALIGNTOK:
    begin
     codealign.link := Tok[i].Value;

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

    StartOptimization(i);

    i := CompileExpression(i + 1, SelectorType);

    if Tok[i].Kind = IDENTTOK then
      EnumName := GetEnumName(GetIdent(Tok[i].Name^));

    if SelectorType <> ENUMTYPE then
     if DataSize[SelectorType]<>1 then
      Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes + [ENUMTYPE]) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, OFTOK);


    GenerateAssignment(ASPOINTER, DataSize[SelectorType], 0, '@CASETMP_'+IntToHex(CaseLocalCnt, 4));

    DefineIdent(i, '@CASETMP_'+IntToHex(CaseLocalCnt, 4), VARIABLE, SelectorType, 0, 0, 0);

    GetIdent('@CASETMP_'+IntToHex(CaseLocalCnt, 4));


    yes:=true;

    NumCaseStatements := 0;

    inc(i, 2);

    SetLength(CaseLabelArray, 1);

    repeat	// Loop over all cases

//      yes:=false;

      repeat	// Loop over all constants for the current case
	i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

//	 ConstVal:=ConstVal and $ff;
	//warning(i, RangeCheckError, 0, ConstValType, SelectorType);

	GetCommonType(i, ConstValType, SelectorType);

	if (Tok[i].Kind = IDENTTOK) then
	 if ((EnumName = '') and (GetEnumName(GetIdent(Tok[i].Name^)) <> '')) or
  	    ((EnumName <> '') and (GetEnumName(GetIdent(Tok[i].Name^)) <> EnumName)) then
		Error(i, 'Constant and CASE types do not match');

	if Tok[i + 1].Kind = RANGETOK then						// Range check
	  begin
	  i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

//	  ConstVal2:=ConstVal2 and $ff;
	  //warning(i, RangeCheckError, 0, ConstValType, SelectorType);

	  GetCommonType(i, ConstValType, SelectorType);

	  if ConstVal > ConstVal2 then
	   Error(i, 'Upper bound of case range is less than lower bound');

	  GenerateCaseRangeCheck(ConstVal, ConstVal2, SelectorType, yes, CaseLocalCnt);

	  yes:=false;

	  CaseLabel.left:=ConstVal;
	  CaseLabel.right:=ConstVal2;
	  end
	else begin
	  GenerateCaseEqualityCheck(ConstVal, SelectorType, yes, CaseLocalCnt);		// Equality check

	  yes:=true;

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

      GenerateCaseStatementProlog; //(CaseLabel.equality);

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

    j := CompileExpression(i + 1, ExpressionType);	// !!! VarType = INTEGERTOK, 'IF BYTE+SHORTINT < BYTE'

    GetCommonType(j, BOOLEANTOK, ExpressionType);	// wywali blad jesli warunek bedzie typu IF A THEN

    CheckTok(j + 1, THENTOK);

    SaveToSystemStack(ifLocalCnt);		// Save conditional expression at expression stack top onto the system stack

    GenerateIfThenCondition;			// Satisfied if expression is not zero
    GenerateIfThenProlog;

    inc(CodeSize);				// !!! aby dzialaly petle WHILE, REPEAT po IF

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

{$IFDEF WHILEDO}

WHILETOK:
    begin
//    writeln(codesize,',',CodePosStackTop);

    inc(CodeSize);				// !!! aby dzialaly zagniezdzone WHILE

    asm65;
    asm65('; --- WhileProlog');

    ResetOpty;

    GenerateRepeatUntilProlog;			// Save return address used by GenerateWhileDoEpilog

    SaveBreakAddress;


    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType);


    GetCommonType(j, BOOLEANTOK, ExpressionType);

    CheckTok(j + 1, DOTOK);

      asm65;
      asm65('; --- WhileDoCondition');
      GenerateWhileDoCondition;			// Satisfied if expression is not zero

      asm65;
      asm65('; --- WhileDoProlog');
      GenerateWhileDoProlog;

      j := CompileStatement(j + 2);

      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      GenerateWhileDoEpilog;

      asm65('; --- WhileDoEpilog');

      RestoreBreakAddress;

      Result := j;

//    writeln('.',codesize,',',CodePosStackTop);

    end;

{$ELSE}

  WHILETOK:
    begin
   // writeln(codesize,',',CodePosStackTop);

    inc(CodeSize);				// !!! aby dzialaly zagniezdzone WHILE


    if codealign.loop > 0 then begin
	     asm65;
	     asm65(#9'jmp @+');
	     asm65(#9'.align $' + IntToHex(codealign.loop, 4));
	     asm65('@');
	     asm65;
    end;


    asm65;
    asm65('; --- WhileProlog');

    ResetOpty;

    inc(CodeSize);

    Inc(CodePosStackTop);
    CodePosStack[CodePosStackTop] := CodeSize;

    asm65(#9'jmp l_'+IntToHex(CodePosStack[CodePosStackTop], 4));

    inc(CodeSize);

    GenerateRepeatUntilProlog;			// Save return address used by GenerateWhileDoEpilog

    SaveBreakAddress;



    oldPass := Pass;
    oldCodeSize := CodeSize;
    Pass := CALLDETERMPASS;

    k:=i;

    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType);

    GetCommonType(j, BOOLEANTOK, ExpressionType);

    CheckTok(j + 1, DOTOK);

    Pass := oldPass;
    CodeSize := oldCodeSize;


    Inc(CodePosStackTop);
    CodePosStack[CodePosStackTop] := CodeSize;

      j := CompileStatement(j + 2);

      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

      Dec(CodePosStackTop);
      Dec(CodePosStackTop);
      GenerateAsmLabels(CodePosStack[CodePosStackTop]);

      StartOptimization(k + 1);

      CompileExpression(k + 1, ExpressionType);


      asm65('; --- WhileDoCondition');

      Gen; Gen; Gen;								// mov :eax, [bx]

      a65(__subBX);
      asm65(#9'lda :STACKORIGIN+1,x');
      asm65(#9'jne l_'+IntToHex(CodePosStack[CodePosStackTop+1], 4));

      Dec(CodePosStackTop);

      asm65('; --- WhileDoEpilog');

      RestoreBreakAddress;

      Result := j;

   // writeln('.',codesize,',',CodePosStackTop);

    end;

{$ENDIF}

  REPEATTOK:
    begin
    inc(CodeSize);			    // !!! aby dzialaly zagniezdzone REPEAT

    if codealign.loop > 0 then begin
	     asm65;
	     asm65(#9'jmp @+');
	     asm65(#9'.align $' + IntToHex(codealign.loop, 4));
	     asm65('@');
	     asm65;
    end;

    asm65;
    asm65('; --- RepeatUntilProlog');

    ResetOpty;

    GenerateRepeatUntilProlog;

    SaveBreakAddress;

    j := CompileStatement(i + 1);

    while Tok[j + 1].Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

    CheckTok(j + 1, UNTILTOK);

    StartOptimization(j + 2);

    j := CompileExpression(j + 2, ExpressionType);

    GetCommonType(j, BOOLEANTOK, ExpressionType);

    asm65;
    asm65('; --- RepeatUntilCondition');
    GenerateRepeatUntilCondition;

    asm65;
    asm65('; --- RepeatUntilEpilog');

    if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

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
	if not ( (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].DataType in OrdinalTypes + Pointers) ) then
	  Error(i + 1, 'Ordinal variable expected as ''FOR'' loop counter')
	 else
	 if (Ident[IdentIndex].isInitialized) or (Ident[IdentIndex].PassMethod <> VALPASSING) then
	  Error(i + 1, 'Simple local variable expected as FOR loop counter')
	 else
	    begin

	    Ident[IdentIndex].LoopVariable := true;


	    if codealign.loop > 0 then begin
	      asm65;
	      asm65(#9'jmp @+');
	      asm65(#9'.align $' + IntToHex(codealign.loop, 4));
	      asm65('@');
	      asm65;
	    end;


	   if Tok[i + 2].Kind = INTOK then begin		// IN

	    j := i + 3;

	    	if Tok[j].Kind = STRINGLITERALTOK then begin

		{$i include/for_in_stringliteral.inc}

	    	end else begin

		{$i include/for_in_ident.inc}

	    	end;

	   end else begin					// = INTOK

	    CheckTok(i + 2, ASSIGNTOK);

//	    asm65;
//	    asm65('; --- For');

	    j := i + 3;

	    StartOptimization(j);


	    forBPL := 0;

	    if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin
	      Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	      forBPL := ord(ConstVal < 128);
	    end else begin
	      j := CompileExpression(j, ExpressionType, Ident[IdentIndex].DataType);
	      ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
	    end;

	    if not (ExpressionType in OrdinalTypes) then
	      iError(j, OrdinalExpectedFOR);

	    ActualParamType := ExpressionType;

	    GenerateAssignment(ASPOINTER, DataSize[Ident[IdentIndex].DataType], IdentIndex);  //!!!!!

	    if not (Tok[j + 1].Kind in [TOTOK, DOWNTOTOK]) then
	      Error(j + 1, '''TO'' or ''DOWNTO'' expected but ' + GetSpelling(j + 1) + ' found')
	    else
	      begin
	      Down := Tok[j + 1].Kind = DOWNTOTOK;


	      inc(j, 2);

	      StartOptimization(j);

	      IdentTemp := -1;


	{$IFDEF OPTIMIZECODE}

	      if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin

		Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);
		DefineIdent(j, '@FORTMP_'+IntToHex(CodeSize, 4), CONSTANT, Ident[IdentIndex].DataType, Ident[IdentIndex].NumAllocElements, Ident[IdentIndex].AllocElementType, ConstVal, Tok[j].Kind);

		if ConstVal > 0 then forBPL:=forBPL or 2;

	      end else begin

	        if ((Tok[j].Kind = IDENTTOK) and (Tok[j + 1].Kind = DOTOK)) or
		   ((Tok[j].Kind = OPARTOK) and (Tok[j + 1].Kind = IDENTTOK) and (Tok[j + 2].Kind = CPARTOK) and (Tok[j + 3].Kind = DOTOK)) then begin

		 if Tok[j].Kind = IDENTTOK then
		  IdentTemp := GetIdent(Tok[j].Name^)
		 else
		  IdentTemp := GetIdent(Tok[j + 1].Name^);

		 j := CompileExpression(j, ExpressionType, Ident[IdentIndex].DataType);
		 ExpandParam(Ident[IdentIndex].DataType, ExpressionType);

		end else begin
		 j := CompileExpression(j, ExpressionType, Ident[IdentIndex].DataType);
		 ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
		 DefineIdent(j, '@FORTMP_'+IntToHex(CodeSize, 4), VARIABLE, Ident[IdentIndex].DataType, Ident[IdentIndex].NumAllocElements, Ident[IdentIndex].AllocElementType, 1);
		end;

	      end;

	{$ELSE}

		j := CompileExpression(j, ExpressionType, Ident[IdentIndex].DataType);
		ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
		DefineIdent(j, '@FORTMP_'+IntToHex(CodeSize, 4), VARIABLE, Ident[IdentIndex].DataType, Ident[IdentIndex].NumAllocElements, Ident[IdentIndex].AllocElementType, 0);

	{$ENDIF}

	        if not (ExpressionType in OrdinalTypes) then
		  iError(j, OrdinalExpectedFOR);


		if ((ActualParamType in UnsignedOrdinalTypes) and (ExpressionType in UnsignedOrdinalTypes)) or
		   ((ActualParamType in SignedOrdinalTypes) and (ExpressionType in SignedOrdinalTypes)) then
		begin

		 if DataSize[ExpressionType] > DataSize[ActualParamType] then ActualParamType := ExpressionType;
		 if DataSize[ActualParamType] > DataSize[Ident[IdentIndex].DataType] then ActualParamType := Ident[IdentIndex].DataType;

		end else
		 ActualParamType := Ident[IdentIndex].DataType;


	        if IdentTemp < 0 then IdentTemp := GetIdent('@FORTMP_'+IntToHex(CodeSize, 4));

	        GenerateAssignment(ASPOINTER, DataSize[Ident[IdentTemp].DataType], IdentTemp);

		asm65;		// ; --- To

	        GenerateRepeatUntilProlog;	// Save return address used by GenerateForToDoEpilog

	        SaveBreakAddress;

	        asm65('; --- ForToDoCondition');


	 	if (ActualParamType = ExpressionType) and (DataSize[Ident[IdentTemp].DataType] > DataSize[ActualParamType]) then
	          Note(j, 'FOR loop counter variable type is of larger size than required');


	        StartOptimization(j);
		ResetOpty;			// !!!


	        Push(Ident[IdentTemp].Value, ASPOINTER,  DataSize[Ident[IdentTemp].DataType], IdentTemp);

	        GenerateForToDoCondition(ActualParamType, Down, IdentIndex);	// Satisfied if counter does not reach the second expression value

	        CheckTok(j + 1, DOTOK);

		//asm65(#13#10'; ForToDoProlog');

		GenerateForToDoProlog;
		j := CompileStatement(j + 2);

//	        StartOptimization(j);		!!! zaremowac aby dzialaly optymalizacje w TemporaryBuf

		asm65;
		asm65('; --- ForToDoEpilog');

		if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

		GenerateForToDoEpilog(ActualParamType, Down, IdentIndex, true, forBPL);

		RestoreBreakAddress;

		Result := j;

	      end;

	     end;	// if Tok[i + 2].Kind = INTTOK

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

	if not( (Ident[IdentIndex].DataType in [FILETOK, TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [FILETOK, TEXTFILETOK]) ) then
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

	if (Ident[IdentIndex].DataType = TEXTFILETOK) or (Ident[IdentIndex].AllocElementType = TEXTFILETOK) then begin

		  asm65(#9'ldy #s@file.buffer');
		  asm65(#9'lda <@buf');
		  asm65(#9'sta (:bp2),y');
	 	  asm65(#9'iny');
		  asm65(#9'lda >@buf');
		  asm65(#9'sta (:bp2),y');

	end;

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

	if not( (Ident[IdentIndex].DataType in [FILETOK, TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [FILETOK, TEXTFILETOK]) ) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	StartOptimization(i + 3);

	if Tok[i + 3].Kind <> COMMATOK then begin
	 if Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] = 0 then
	  Push(128, ASVALUE, 2)
	 else
	  Push(integer(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType]), ASVALUE, 2);    // predefined record by FILE OF (default =128)

	 inc(i, 3);
	end else begin

	 if (Ident[IdentIndex].DataType = TEXTFILETOK) or (Ident[IdentIndex].AllocElementType = TEXTFILETOK) then
	  Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' + InfoAboutToken(Ident[IdentIndex].DataType) + '" expected "File"');

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

	if not( (Ident[IdentIndex].DataType in [FILETOK, TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [FILETOK, TEXTFILETOK]) ) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	StartOptimization(i + 3);

	if Tok[i + 3].Kind <> COMMATOK then begin

	 if Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] = 0 then
	  Push(128, ASVALUE, 2)
	 else
	  Push(integer(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType]), ASVALUE, 2);    // predefined record by FILE OF (default =128)

	 inc(i, 3);
	end else begin

	 if (Ident[IdentIndex].DataType = TEXTFILETOK) or (Ident[IdentIndex].AllocElementType = TEXTFILETOK) then
	  Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' + InfoAboutToken(Ident[IdentIndex].DataType) + '" expected "File"');

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


  APPENDTOK:
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

	asm65('; Append');

	if not( (Ident[IdentIndex].DataType in [TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [TEXTFILETOK]) ) then
	 Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' + InfoAboutToken(Ident[IdentIndex].DataType) + '" expected "Text"');

	if Tok[i + 3].Kind = COMMATOK then
	 Error(i, 'Wrong number of parameters specified for call to Append');

	StartOptimization(i + 3);

	CheckTok(i + 3, CPARTOK);

	Push(1, ASVALUE, 2);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

	GenerateFileOpen(IdentIndex, ioAppend);

	Result := i + 3;
       end;


  GETRESOURCEHANDLETOK:
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

	if Ident[IdentIndex].DataType <> POINTERTOK then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, COMMATOK);

        CheckTok(i + 4, STRINGLITERALTOK);

	svar:='';

	for k:=1 to Tok[i+4].StrLength do
	 svar:=svar + chr(StaticStringData[Tok[i+4].StrAddress - CODEORIGIN+k]);

	CheckTok(i + 5, CPARTOK);

	asm65;
	asm65('; GetResourceHandle');

	asm65(#9'mwa #MAIN.@RESOURCE.'+svar+' '+Tok[i + 2].Name^);

	inc(i, 5);

	Result := i;
      end;


  SIZEOFRESOURCETOK:
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

	if not(Ident[IdentIndex].DataType in IntegerTypes) then
	 iError(i + 2, IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, COMMATOK);

        CheckTok(i + 4, STRINGLITERALTOK);

	svar:='';

	for k:=1 to Tok[i+4].StrLength do
	 svar:=svar + chr(StaticStringData[Tok[i+4].StrAddress - CODEORIGIN+k]);

	CheckTok(i + 5, CPARTOK);

	asm65;
	asm65('; GetResourceHandle');

	asm65(#9'mwa #MAIN.@RESOURCE.'+svar+'.end-MAIN.@RESOURCE.'+svar+' '+Tok[i + 2].Name^);

	inc(i, 5);

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

	GenerateFileRead(IdentIndex, ioRead, NumActualParams);

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

	GenerateFileRead(IdentIndex, ioWrite, NumActualParams);

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

	if not( (Ident[IdentIndex].DataType in [FILETOK, TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [FILETOK, TEXTFILETOK])) then
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

	if (IdentIndex > 0) and (Ident[identIndex].DataType = TEXTFILETOK) then begin

	  asm65(#9'lda #eol');
	  asm65(#9'sta @buf');
	  GenerateFileRead(IdentIndex, ioReadRecord, 0);

	  inc(i, 3);

	  CheckTok(i, COMMATOK);
	  CheckTok(i + 1, IDENTTOK);

	  if Ident[GetIdent(Tok[i + 1].Name^)].DataType <> STRINGPOINTERTOK then
	   iError(i + 1, VariableExpected);

	  IdentIndex := GetIdent(Tok[i + 1].Name^);

	  asm65(#9'@moveRECORD ' +  GetLocalName(IdentIndex) );

	  CheckTok(i + 2, CPARTOK);

	  Result := i + 2;

	end else

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

    StartOptimization(i);

    yes := (Tok[i].Kind = WRITELNTOK);


    if (Tok[i + 1].Kind = OPARTOK) and (Tok[i + 2].Kind = CPARTOK) then inc(i, 2);


    if Tok[i + 1].Kind = SEMICOLONTOK then begin

    end else begin

     CheckTok(i + 1, OPARTOK);

     inc(i);

     if (Tok[i + 1].Kind = IDENTTOK) and (Ident[GetIdent(Tok[i + 1].Name^)].DataType = TEXTFILETOK) then begin

      IdentIndex := GetIdent(Tok[i + 1].Name^);

      inc(i);
      CheckTok(i + 1, COMMATOK);
      inc(i);

      case Tok[i + 1].Kind of

        IDENTTOK:					// variable (pointer to string)
		begin

		  if Ident[GetIdent(Tok[i + 1].Name^)].DataType <> STRINGPOINTERTOK then
		   iError(i + 1, VariableExpected);

	   	   asm65(#9'mwy ' + GetLocalName(GetIdent(Tok[i + 1].Name^)) +' :bp2');
		   asm65(#9'ldy #$01');
		   asm65(#9'mva:rne (:bp2),y @buf-1,y+');
		   asm65(#9'lda (:bp2),y');

		   if yes then begin 								// WRITELN

			asm65(#9'tay');
			asm65(#9'lda #eol');
			asm65(#9'sta @buf,y');

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$01');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, ioWriteRecord, 0);

		   end else begin								// WRITE

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, ioWrite, 0);

		   end;

		  inc(i, 2);

		end;

	STRINGLITERALTOK:			      // 'text'
		begin
	          asm65(#9'ldy #$00');
		  asm65(#9'mva:rne CODEORIGIN+$'+IntToHex(Tok[i + 1].StrAddress - CODEORIGIN + 1,4)+',y @buf,y+');

		   if yes then begin 								// WRITELN

		 	asm65(#9'lda #eol');
			asm65(#9'ldy CODEORIGIN+$'+IntToHex(Tok[i + 1].StrAddress - CODEORIGIN,4));
			asm65(#9'sta @buf,y');

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$01');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, ioWriteRecord, 0);

		   end else begin								// WRITE

			asm65(#9'lda CODEORIGIN+$'+IntToHex(Tok[i + 1].StrAddress - CODEORIGIN,4));

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, ioWrite, 0);

		   end;

		  inc(i, 2);
		end;


	INTNUMBERTOK:			      // 0..9
		begin
		  asm65(#9'txa:pha');

		  Push(Tok[i + 1].Value, ASVALUE, DataSize[CARDINALTOK]);

		  asm65(#9'@ValueToRec #@printINT');

		  asm65(#9'pla:tax');

		   if yes then begin 								// WRITELN

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$01');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, ioWriteRecord, 0);

		   end else begin								// WRITE

			asm65(#9'tya');

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, ioWrite, 0);

		   end;

		  inc(i, 2);
		end;


      end;

      yes:=false;

     end else

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

	  j := i + 1;

	  i := CompileExpression(j, ExpressionType);

//	if (ExpressionType = CHARTOK) and (Tok[i].Kind = DEREFERENCETOK) then ExpressionType:=STRINGPOINTERTOK;

//	  if ExpressionType = ENUMTYPE then
//	    GenerateWriteString(Tok[i].Value, ASVALUE, INTEGERTOK)		// Enumeration argument
//	  else

	  if (ExpressionType in IntegerTypes) then
		GenerateWriteString(Tok[i].Value, ASVALUE, ExpressionType)	// Integer argument
	  else if (ExpressionType = BOOLEANTOK) then
		GenerateWriteString(Tok[i].Value, ASBOOLEAN)			// Boolean argument
	  else if (ExpressionType = CHARTOK) then
		GenerateWriteString(Tok[i].Value, ASCHAR)			// Character argument
	  else if ExpressionType = REALTOK then
		GenerateWriteString(Tok[i].Value, ASREAL)			// Real argument
	  else if ExpressionType = SHORTREALTOK then
		GenerateWriteString(Tok[i].Value, ASSHORTREAL)			// ShortReal argument
	  else if ExpressionType = HALFSINGLETOK then
		GenerateWriteString(Tok[i].Value, ASHALFSINGLE)			// Half Single argument
	  else if ExpressionType = SINGLETOK then
		GenerateWriteString(Tok[i].Value, ASSINGLE)			// Single argument
	  else if ExpressionType in Pointers then begin

		if Tok[j].Kind = ADDRESSTOK then
		 IdentIndex := GetIdent(Tok[j + 1].Name^)
		else
		 if Tok[j].Kind = IDENTTOK then
		  IdentIndex := GetIdent(Tok[j].Name^)
		 else
		  iError(i, CantReadWrite);

//		writeln(Ident[IdentIndex].Name,',',ExpressionType,' | ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].idType);

		if (ExpressionType = STRINGPOINTERTOK) or (Ident[IdentIndex].Kind = FUNC) or ((ExpressionType = POINTERTOK) and (Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
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

    StopOptimization;

    Result := i;

    end;


  ASMTOK:
    begin

     ResetOpty;

     StopOptimization;			// takich blokow nie optymalizujemy

     asm65;
     asm65('; -------------------  ASM Block '+format('%.8d',[AsmBlockIndex])+'  -------------------');
     asm65;


     if isInterrupt and ( (pos(' :bp', AsmBlock[AsmBlockIndex]) > 0) or (pos(' :STACK', AsmBlock[AsmBlockIndex]) > 0) ) then begin

      if (pos(' :bp', AsmBlock[AsmBlockIndex]) > 0) then Error(i, 'Illegal instruction in INTERRUPT block '':BP''');
      if (pos(' :STACK', AsmBlock[AsmBlockIndex]) > 0) then Error(i, 'Illegal instruction in INTERRUPT block '':STACKORIGIN''');

     end;

//   writeln(OutputDisabled,',',Pass);
//   writeln('----------------------');

//     writeln(AsmBlock[AsmBlockIndex]);


//     asm65(AsmBlock[AsmBlockIndex]);

     asm65('#asm');
     asm65(IntToStr(AsmBlockIndex));


//     if (OutputDisabled=false) and (Pass = CODEGENERATIONPASS) then WriteOut(AsmBlock[AsmBlockIndex]);

     inc(AsmBlockIndex);

     if isAsm and (Tok[i].Value = 0) then begin

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
// dluga i wolna, jesli mamy tablice lub dwa parametry, np. INC(TMP[1]), DEC(VAR, VALUE+12)
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


	  if not(Ident[IdentIndex].idType in [PCHARTOK]) and (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) and ( not(Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) ) then begin

	      if Tok[i + 1].Kind = OBRACKETTOK then begin			// array index

		ExpressionType := Ident[IdentIndex].AllocElementType;

		IndirectionLevel := ASPOINTERTOARRAYORIGIN;

		i := CompileArrayIndex(i, IdentIndex);

		CheckTok(i + 1, CBRACKETTOK);

		inc(i);

	      end else
	       if Tok[i + 1].Kind = DEREFERENCETOK then
		iError(i + 1, IllegalQualifier)
	       else
		iError(i + 1, IncompatibleTypes, IdentIndex, Ident[IdentIndex].DataType, ExpressionType);

	  end else

//          if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType <> 0) then begin

	  if Tok[i + 1].Kind = OBRACKETTOK then begin				// typed pointer: PByte[], Pword[] ...

	    ExpressionType := Ident[IdentIndex].AllocElementType;

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN;

	    i := CompileArrayIndex(i, IdentIndex);

	    CheckTok(i + 1, CBRACKETTOK);

	    inc(i);

	  end else

	  if Tok[i + 1].Kind = DEREFERENCETOK then
	   if Ident[IdentIndex].AllocElementType = 0 then
	    iError(i + 1, CantAdrConstantExp)
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

	   GetCommonType(i, ExpressionType, ActualParamType);

	   inc(NumActualParams);

	   if Ident[IdentIndex].PassMethod <> VARPASSING then begin

	    if yes = false then ExpandParam(ExpressionType, ActualParamType);

	    if  (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

	     if yes then
	      Push(ConstVal * RecordSize(IdentIndex), ASVALUE, 2)
	     else
	      Error(i, '-- under construction --');

	    end else
	    if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType in OrdinalTypes) and (IndirectionLevel <> ASPOINTERTOPOINTER) then begin	    // zwieksz o N * DATASIZE jesli to wskaznik ale nie tablica

	     if yes then begin

	      if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
	       Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType])
	      else
	       Push(ConstVal * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	     end else
	      GenerateIndexShift( Ident[IdentIndex].AllocElementType );		// * DATASIZE

	    end else
	     if yes then Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	   end else begin

	    if yes then Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	    ExpressionType := Ident[IdentIndex].AllocElementType;
	    if ExpressionType = UNTYPETOK then ExpressionType := Ident[IdentIndex].DataType;	// RECORD.

	    ExpandParam(ExpressionType, ActualParamType);
	   end;


	 end else	// if Tok[i + 1].Kind = COMMATOK
	   if (Ident[IdentIndex].PassMethod = VARPASSING) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in OrdinalTypes + [RECORDTOK, OBJECTTOK])) then

	     if (Ident[IdentIndex].PassMethod = VARPASSING) or (Ident[IdentIndex].NumAllocElements > 0) or (IndirectionLevel = ASPOINTERTOPOINTER) or ((Ident[IdentIndex].NumAllocElements = 0) and (IndirectionLevel = ASPOINTERTOARRAYORIGIN)) then begin

	       ExpressionType := Ident[IdentIndex].AllocElementType;

	       if ExpressionType in [RECORDTOK, OBJECTTOK] then
		Push(RecordSize(IdentIndex), ASVALUE, 2)
	       else
		Push(1, ASVALUE, DataSize[ExpressionType]);

	       inc(NumActualParams);
	     end else
	     if not(Ident[IdentIndex].AllocElementType in [BYTETOK, SHORTINTTOK]) then begin
	       Push(DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, 1);			// +/- DATASIZE

	       ExpandParam(ExpressionType, BYTETOK);

	       inc(NumActualParams);
	     end;


	 if (Ident[IdentIndex].PassMethod = VARPASSING) and (IndirectionLevel <> ASPOINTERTOARRAYORIGIN) then IndirectionLevel := ASPOINTERTOPOINTER;

	 if ExpressionType = UNTYPETOK then
	  Error(i, 'Assignments to formal parameters and open arrays are not possible');

//       NumActualParams:=1;
//	 Value:=3;

	 if NumActualParams = 0 then begin

	  asm65;

	  if Down then
	   asm65('; Dec(var X) -> ' + InfoAboutToken(ExpressionType))
	  else
	   asm65('; Inc(var X) -> ' + InfoAboutToken(ExpressionType));

	  asm65;

	  GenerateForToDoEpilog(ExpressionType, Down, IdentIndex, false, 0);		// +1, -1
	 end else
	  GenerateIncOperation(IndirectionLevel, ExpressionType, Down, IdentIndex);	// +N, -N

	 StopOptimization;

	 inc(i);

      CheckTok(i, CPARTOK);

      Result := i;
    end;


  EXITTOK:
    begin

     if TOK[i + 1].Kind = OPARTOK then begin

      StartOptimization(i);

      i := CompileExpression(i + 2, ActualParamType);

      CheckTok(i + 1, CPARTOK);

      inc(i);

      yes := false;

      for j:=1 to NumIdent do
       if (Ident[j].ProcAsBlock = BlockStack[BlockStackTop]) and (Ident[j].Kind = FUNC) then begin

	IdentIndex := GetIdentResult(BlockStack[BlockStackTop]);

	yes := true;
	Break;
       end;


      if not yes then
	Error(i, 'Procedures cannot return a value');

      if (ActualParamType = STRINGPOINTERTOK) and ((Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0)) then
       iError(i, IncompatibleTypes, 0, ActualParamType, PCHARTOK)
      else
       GetCommonConstType(i, Ident[IdentIndex].DataType, ActualParamType);

      GenerateAssignment(ASPOINTER, DataSize[Ident[IdentIndex].DataType], 0, 'RESULT');

     end;

     asm65(#9'jmp @exit', '; exit');

     ResetOpty;

     Result := i;
    end;


  BREAKTOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'BREAK not allowed');

//     asm65;
     asm65(#9'jmp b_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4), '; break');

     BreakPosStack[BreakPosStackTop].brk := true;

     ResetOpty;

     Result := i;
    end;


  CONTINUETOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'CONTINUE not allowed');

//     asm65;
     asm65(#9'jmp c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4), '; continue');

     BreakPosStack[BreakPosStackTop].cnt := true;

     Result := i;
    end;


  HALTTOK:
    begin
     if Tok[i + 1].Kind = OPARTOK then begin

      i := CompileConstExpression(i + 2, Value, ExpressionType);
      GetCommonConstType(i, BYTETOK, ExpressionType);

      CheckTok(i + 1, CPARTOK);

      inc(i, 1);

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

    if not(byte(ConstVal) in [0..4]) then
      Error(i, 'Interrupt Number in [0..4]');

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
		 asm65;
		 asm65(#9'lda VDSLST');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VDSLST+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(iVBLI): begin
		 asm65;
		 asm65(#9'lda VVBLKI');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VVBLKI+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(iVBLD): begin
		 asm65;
		 asm65(#9'lda VVBLKD');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VVBLKD+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(iTIM1): begin
		 asm65;
		 asm65(#9'lda VTIMR1');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VTIMR1+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(iTIM2): begin
		 asm65;
		 asm65(#9'lda VTIMR2');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VTIMR2+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(iTIM4): begin
		 asm65;
		 asm65(#9'lda VTIMR4');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VTIMR4+1');
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

    if not(byte(ConstVal) in [0..4]) then
      Error(i, 'Interrupt Number in [0..4]');

    i := CompileExpression(i + 2, ActualParamType);
    GetCommonType(i, POINTERTOK, ActualParamType);

    case ConstVal of
     ord(iDLI): begin
		 asm65(#9'mva :STACKORIGIN,x VDSLST');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VDSLST+1');
		 a65(__subBX);
		end;

    ord(iVBLI): begin
		 asm65(#9'lda :STACKORIGIN,x');
		 asm65(#9'ldy #5');
		 asm65(#9'sta wsync');
		 asm65(#9'dey');
		 asm65(#9'rne');
		 asm65(#9'sta VVBLKI');
		 asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
		 asm65(#9'sty VVBLKI+1');
		 a65(__subBX);
		end;

    ord(iVBLD): begin
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

     ord(iTIM1): begin
	         asm65(#9'sei');
		 asm65(#9'mva :STACKORIGIN,x VTIMR1');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR1+1');
		 a65(__subBX);

		 if Tok[i + 1].Kind = COMMATOK then begin

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, BYTETOK, ActualParamType);

		   asm65(#9'lda #$00');
		   asm65(#9'ldy #$03');
		   asm65(#9'sta AUDCTL');
		   asm65(#9'sta AUDC1');
		   asm65(#9'sty SKCTL');

		   asm65(#9'mva :STACKORIGIN,x AUDCTL');
	 	   a65(__subBX);

		   CheckTok(i + 1, COMMATOK);

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, BYTETOK, ActualParamType);

		   asm65(#9'mva :STACKORIGIN,x AUDF1');
	 	   a65(__subBX);

		   asm65(#9'lda irqens');
		   asm65(#9'ora #$01');
		   asm65(#9'sta irqens');
		   asm65(#9'sta irqen');
		   asm65(#9'sta stimer');

		 end else begin

		  asm65(#9'lda irqens');
		  asm65(#9'and #$fe');
		  asm65(#9'sta irqens');
		  asm65(#9'sta irqen');

		 end;

	         asm65(#9'cli');
		end;

     ord(iTIM2): begin
	         asm65(#9'sei');
		 asm65(#9'mva :STACKORIGIN,x VTIMR2');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR2+1');
		 a65(__subBX);

		 if Tok[i + 1].Kind = COMMATOK then begin

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, BYTETOK, ActualParamType);

		   asm65(#9'lda #$00');
		   asm65(#9'ldy #$03');
		   asm65(#9'sta AUDCTL');
		   asm65(#9'sta AUDC2');
		   asm65(#9'sty SKCTL');

		   asm65(#9'mva :STACKORIGIN,x AUDCTL');
	 	   a65(__subBX);

		   CheckTok(i + 1, COMMATOK);

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, BYTETOK, ActualParamType);

		   asm65(#9'mva :STACKORIGIN,x AUDF2');
	 	   a65(__subBX);

		   asm65(#9'lda irqens');
		   asm65(#9'ora #$02');
		   asm65(#9'sta irqens');
		   asm65(#9'sta irqen');
		   asm65(#9'sta stimer');

		 end else begin

		  asm65(#9'lda irqens');
		  asm65(#9'and #$fd');
		  asm65(#9'sta irqens');
		  asm65(#9'sta irqen');

		 end;

	         asm65(#9'cli');
		end;

     ord(iTIM4): begin
	         asm65(#9'sei');
		 asm65(#9'mva :STACKORIGIN,x VTIMR4');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR4+1');
		 a65(__subBX);

		 if Tok[i + 1].Kind = COMMATOK then begin

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, BYTETOK, ActualParamType);

		   asm65(#9'lda #$00');
		   asm65(#9'ldy #$03');
		   asm65(#9'sta AUDCTL');
		   asm65(#9'sta AUDC4');
		   asm65(#9'sty SKCTL');

		   asm65(#9'mva :STACKORIGIN,x AUDCTL');
	 	   a65(__subBX);

		   CheckTok(i + 1, COMMATOK);

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, BYTETOK, ActualParamType);

		   asm65(#9'mva :STACKORIGIN,x AUDF4');
	 	   a65(__subBX);

		   asm65(#9'lda irqens');
		   asm65(#9'ora #$04');
		   asm65(#9'sta irqens');
		   asm65(#9'sta irqen');
		   asm65(#9'sta stimer');

		 end else begin

		  asm65(#9'lda irqens');
		  asm65(#9'and #$fb');
		  asm65(#9'sta irqens');
		  asm65(#9'sta irqen');

		 end;

	         asm65(#9'cli');
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


function DeclareFunction(i: integer; out ProcVarIndex: cardinal): integer;
var  VarOfSameType: TVariableList;
     NumVarOfSameType, VarOfSameTypeIndex, x: Integer;
     ListPassMethod, VarType, AllocElementType, ActualParamType: Byte;
     NumAllocElements: cardinal;
     IsNestedFunction: Boolean;
//     ConstVal: Int64;

begin
      inc(NumProc);

      if Tok[i].Kind in [PROCEDURETOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
	begin
	DefineIdent(i, '@FN' + IntToHex(NumProc, 4), Tok[i].Kind, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i, '@FN' + IntToHex(NumProc, 4), FUNC, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;

      NumVarOfSameType := 0;
      ProcVarIndex := NumProc;			// -> NumAllocElements_

      dec(i);

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

		for x := 1 to NumVarOfSameType do
		 if VarOfSameType[x].Name = Tok[i + 1].Name^ then
		   Error(i + 1, 'Identifier ' + Tok[i + 1].Name^ + ' is already defined');

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

      if IsNestedFunction then
	begin

	CheckTok(i, COLONTOK);

	if Tok[i + 1].Kind = ARRAYTOK then
	 Error(i + 1, 'Type identifier expected');

	i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	Ident[NumIdent].DataType := VarType;					// Result
	Ident[NumIdent].NestedFunctionNumAllocElements := NumAllocElements;
	Ident[NumIdent].NestedFunctionAllocElementType := AllocElementType;

	i := i + 1;
	end;// if IsNestedFunction


    Ident[NumIdent].isStdCall := true;
    Ident[NumIdent].IsNestedFunction := IsNestedFunction;

    Result := i;

end;


function DefineFunction(i, ForwardIdentIndex: integer; out isForward, isInt, isInl: Boolean; var IsNestedFunction: Boolean; out NestedFunctionResultType: Byte; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: Byte): integer;
var  VarOfSameType: TVariableList;
     NumVarOfSameType, VarOfSameTypeIndex, x: Integer;
     ListPassMethod, VarType, AllocElementType: Byte;
     NumAllocElements: cardinal;
begin

    if ForwardIdentIndex = 0 then begin

      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, 'Reserved word used as identifier');

      if Tok[i].Kind in [PROCEDURETOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
	begin
	DefineIdent(i + 1, Tok[i + 1].Name^, Tok[i].Kind, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i + 1, Tok[i + 1].Name^, FUNC, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;


      NumVarOfSameType := 0;

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

		for x := 1 to NumVarOfSameType do
		 if VarOfSameType[x].Name = Tok[i + 1].Name^ then
		   Error(i + 1, 'Identifier ' + Tok[i + 1].Name^ + ' is already defined');

	        Inc(NumVarOfSameType);
	        VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name^;
	      end;

	    i := i + 2;
	    until Tok[i].Kind <> COMMATOK;


	  VarType := 0;								// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod = VARPASSING)  and (Tok[i].Kind <> COLONTOK) then begin
										// UNTYPED PARAM ('var buf')
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

//	if Tok[i].Kind = PCHARTOK then NestedFunctionResultType := PCHARTOK;

	Ident[NumIdent].DataType := NestedFunctionResultType;			// Result

	NestedFunctionNumAllocElements := NumAllocElements;
	Ident[NumIdent].NestedFunctionNumAllocElements := NumAllocElements;

	NestedFunctionAllocElementType := AllocElementType;
	Ident[NumIdent].NestedFunctionAllocElementType := AllocElementType;

	Ident[NumIdent].isNestedFunction := true;

	i := i + 1;
	end;// if IsNestedFunction

    CheckTok(i, SEMICOLONTOK);

    end; //if ForwardIdentIndex = 0


    isForward := false;
    isInt := false;
    isInl := false;

	while Tok[i + 1].Kind in [OVERLOADTOK, ASSEMBLERTOK, FORWARDTOK, REGISTERTOK, INTERRUPTTOK, PASCALTOK, STDCALLTOK, INLINETOK, EXTERNALTOK, KEEPTOK] do begin

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

	     STDCALLTOK: begin
			   Ident[NumIdent].isStdCall := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	     INLINETOK: begin
	                   isInl := true;
			   Ident[NumIdent].isInline := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   INTERRUPTTOK: begin
			   isInt := true;
			   Ident[NumIdent].isInterrupt := true;
			   Ident[NumIdent].IsNotDead := true;		// zawsze wygeneruj kod dla przerwania
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	      PASCALTOK: begin
			   Ident[NumIdent].isRecursion := true;
			   Ident[NumIdent].isPascal := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	    EXTERNALTOK: begin
			   Ident[NumIdent].isExternal := true;
			   isForward := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

                 KEEPTOK: begin
			   Ident[NumIdent].isKeep := true;
			   Ident[NumIdent].IsNotDead := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	  end;

	  inc(i);
	end;// while


  if Ident[NumIdent].isRegister and (Ident[NumIdent].isPascal or Ident[NumIdent].isRecursion) then
   Error(i, 'Calling convention directive "REGISTER" not applicable with "PASCAL"');

  if Ident[NumIdent].isInline and (Ident[NumIdent].isPascal or Ident[NumIdent].isRecursion)  then
   Error(i, 'Calling convention directive "INLINE" not applicable with "PASCAL"');

  if Ident[NumIdent].isInline and (Ident[NumIdent].isInterrupt) then
   Error(i, 'Procedure directive "INTERRUPT" cannot be used with "INLINE"');

//  if Ident[NumIdent].isInterrupt and (Ident[NumIdent].isAsm = false) then
//    Note(i, 'Use assembler block instead pascal');

 Result := i;
end;


function CompileType(i: Integer; out DataType: Byte; out NumAllocElements: cardinal; out AllocElementType: Byte): Integer;
var
  NestedNumAllocElements, NestedFunctionNumAllocElements: cardinal;
  LowerBound, UpperBound, ConstVal, IdentIndex: Int64;
  {ForwardIdentIndex,} NumFieldsInList, FieldInListIndex, RecType, k, j: integer;
  NestedDataType, ExpressionType, NestedAllocElementType, NestedFunctionAllocElementType, NestedFunctionResultType: Byte;
  FieldInListName: array [1..MAXFIELDS] of TField;
  ExitLoop, isForward, isInt, isInl, IsNestedFunction: Boolean;
  Name: TString;


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

   if not (FieldType in [RECORDTOK, OBJECTTOK]) then begin

    if FieldType in Pointers then
     inc(Types[RecType].Size, (NumAllocElements shr 16) * (NumAllocElements and $FFFF) * DataSize[AllocElementType])
    else
     inc(Types[RecType].Size, DataSize[FieldType]);

   end else
    inc(Types[RecType].Size, DataSize[FieldType]);

   Types[RecType].Field[x].Kind := 0;
  end;


begin


if Tok[i].Kind in [PROCEDURETOK, FUNC] then begin			// PROCEDURE, FUNCTION

  DataType := POINTERTOK;
  AllocElementType := PROCVARTOK;

  i := DeclareFunction(i, NestedNumAllocElements);

  NumAllocElements := NestedNumAllocElements shl 16;	// NumAllocElements = NumProc shl 16

  Result := i - 1;

end else

if Tok[i].Kind = DEREFERENCETOK then begin				// ^type

 DataType := POINTERTOK;

 if Tok[i + 1].Kind = STRINGTOK then begin				// ^string
  NumAllocElements := 0;
  AllocElementType := CHARTOK;
  DataType := STRINGPOINTERTOK;
 end else
 if Tok[i + 1].Kind = IDENTTOK then begin

  IdentIndex := GetIdent(Tok[i + 1].Name^);

  if IdentIndex = 0 then begin

   NumAllocElements  := i + 1;
   AllocElementType  := FORWARDTYPE;

  end else

  if (IdentIndex > 0) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) then begin
    NumAllocElements := Ident[IdentIndex].NumAllocElements;

    if Ident[IdentIndex].DataType in Pointers then begin

     if Ident[IdentIndex].DataType = STRINGPOINTERTOK then begin
       NumAllocElements := 0;
       AllocElementType := CHARTOK;
       DataType := STRINGPOINTERTOK;
     end else begin
       NumAllocElements := Ident[IdentIndex].NumAllocElements or (Ident[IdentIndex].NumAllocElements_ shl 16);
       AllocElementType := Ident[IdentIndex].AllocElementType;
       DataType := DEREFERENCEARRAYTOK;
     end;

    end else begin
     AllocElementType := Ident[IdentIndex].DataType;
     NumAllocElements := Ident[IdentIndex].NumAllocElements or (Ident[IdentIndex].NumAllocElements_ shl 16);
    end;

//  writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType ,' | ',DataType,',',AllocElementType,',',NumAllocElements);

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
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, CONSTANT, POINTERTOK, length(FieldInListName[FieldInListIndex].Name)+1, CHARTOK, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE , IDENTTOK);

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

if Tok[i].Kind = TEXTFILETOK then begin					// TextFile

 AllocElementType := BYTETOK;
 NumAllocElements := 1;

 DataType := TEXTFILETOK;
 Result := i;

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

    if (Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);

	  k := i;

	  i := DefineFunction(i, 0, isForward, isInt, isInl, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

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

      if (Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) then
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

    j := i + 1;

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    if Tok[j].Kind = ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


    for FieldInListIndex := 1 to NumFieldsInList do begin							// issue #92 fixed
      DeclareField(FieldInListName[FieldInListIndex].Name, DataType, NumAllocElements, AllocElementType);	//
														//
      if DataType in [RECORDTOK, OBJECTTOK] then								//
//      for FieldInListIndex := 1 to NumFieldsInList do								//
         for k := 1 to Types[NumAllocElements].NumFields do begin						//
	  DeclareField(FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name,	//
		     Types[NumAllocElements].Field[k].DataType//,						//
		     //Types[NumAllocElements].Field[k].NumAllocElements,					//
		     //Types[NumAllocElements].Field[k].AllocElementType
		     );

	  Types[RecType].Field[ Types[RecType].NumFields ].Kind := OBJECTVARIABLE;

//	writeln('>> ',FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name,',', Types[NumAllocElements].Field[k].NumAllocElements);
         end;

     end;


    ExitLoop := FALSE;
    if Tok[i + 1].Kind <> SEMICOLONTOK then begin
      inc(i);
      ExitLoop := TRUE
    end else
      begin
      inc(i, 2);

      if Tok[i].Kind = ENDTOK then ExitLoop := TRUE else
       if Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);

	  k := i;

	  i := DefineFunction(i, 0, isForward, isInt, isInl, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

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

  if (Tok[i].Kind = RECORDTOK) or ((Tok[i].Kind = PACKEDTOK) and (Tok[i+1].Kind = RECORDTOK)) then		// Record
  begin

  Name := Tok[i-2].Name^;

  if Tok[i].Kind = PACKEDTOK then inc(i);

  inc(NumTypes);
  RecType := NumTypes;

  if NumTypes > MAXTYPES then
   Error(i, 'Out of resources, MAXTYPES');

  inc(i);

  Types[RecType].Size := 0;
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

    j := i + 1;

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    if Tok[j].Kind = ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


    //NumAllocElements:=0;		// ??? arrays not allowed, only pointers ???

    for FieldInListIndex := 1 to NumFieldsInList do begin								// issue #92 fixed
      DeclareField(FieldInListName[FieldInListIndex].Name, DataType, NumAllocElements, AllocElementType);		//
															//
      if DataType = RECORDTOK then											//
        //for FieldInListIndex := 1 to NumFieldsInList do								//
        for k := 1 to Types[NumAllocElements].NumFields do
 	  DeclareField(FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name, Types[NumAllocElements].Field[k].DataType);

    end;

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
  NumAllocElements := RecType;			// indeks do tablicy Types
  AllocElementType := 0;

  if Types[RecType].Size > 255 then
   Error(i, 'Record size beyond the 256 bytes limit');

  Result := i;
end else// if RECORDTOK

if Tok[i].Kind in AllTypes then
  begin
  DataType := Tok[i].Kind;
  NumAllocElements := 0;
  AllocElementType := 0;
  Result := i;
  end

else if Tok[i].Kind = PCHARTOK then					// PChar
  begin
  DataType := POINTERTOK;
  AllocElementType := CHARTOK;

  NumAllocElements := 0;

  Result:=i;
 end	// Pchar

else if Tok[i].Kind = STRINGTOK then					// String
  begin
  DataType := STRINGPOINTERTOK;
  AllocElementType := CHARTOK;

  if Tok[i + 1].Kind <> OBRACKETTOK then begin

   UpperBound:=255;				 // default string[255]

   Result:=i;

  end  else begin
 //   Error(i + 1, '[ expected but ' + GetSpelling(i + 1) + ' found');

  i := CompileConstExpression(i + 2, UpperBound, ExpressionType);

  if (UpperBound < 1) or (UpperBound > 255) then
    Error(i, 'string length must be a value from 1 to 255');

  CheckTok(i + 1, CBRACKETTOK);

  Result := i + 1;
  end;

  NumAllocElements := UpperBound + 1;

  if UpperBound>255 then
   iError(i, SubrangeBounds);

  end	// if STRINGTOK
else if (Tok[i].Kind = ARRAYTOK) or ((Tok[i].Kind = PACKEDTOK) and (Tok[i + 1].Kind = ARRAYTOK))  then		// Array
  begin
  DataType := POINTERTOK;

  if Tok[i].Kind = PACKEDTOK then inc(i);

  CheckTok(i + 1, OBRACKETTOK);

  if Tok[i + 2].Kind in AllTypes + StringTypes then begin

   if Tok[i + 2].Kind = BYTETOK then begin
    LowerBound := 0;
    UpperBound := 255;

    NumAllocElements := 256;
   end else
    Error(i, 'Error in type definition');

   inc(i, 2);

  end else begin

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

  end;	// if Tok[i + 2].Kind in AllTypes + StringTypes

  CheckTok(i + 1, CBRACKETTOK);
  CheckTok(i + 2, OFTOK);

  if Tok[i + 3].Kind = ARRAYTOK then begin
    i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);
    Result := i;
  end else begin
    Result := i;
    i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);
  end;


  if (NumAllocElements shr 16) * (NumAllocElements and $0000FFFF) * DataSize[NestedDataType] > 40960-1 then
    Error(i, 'Array [0..' + IntToStr(NumAllocElements and $0000FFFF-1)+', 0..' + IntToStr(NumAllocElements shr 16-1)+'] size exceeds available RAM');


// sick3
// writeln('>',NestedDataType,',',NestedAllocElementType,',',Tok[i].kind,',',hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));

//  if NestedAllocElementType = PROCVARTOK then
//      Error(i, InfoAboutToken(NestedAllocElementType)+' arrays are not supported');


  if NestedNumAllocElements > 0 then
//    Error(i, 'Multidimensional arrays are not supported');
   if NestedDataType in [RECORDTOK, OBJECTTOK, ENUMTOK] then begin			// !!! dla RECORD, OBJECT tablice nie zadzialaja !!!

    if NumAllocElements shr 16 > 0 then
      Error(i, 'Multidimensional ' + InfoAboutToken(NestedDataType) + ' arrays are not supported');

//    if NestedDataType = RECORDTOK then
//    else
    if NestedDataType in [RECORDTOK, OBJECTTOK] then
     Error(i, 'Only Array [0..'+IntToStr(NumAllocElements-1)+'] of ^'+InfoAboutToken(NestedDataType)+' supported')
    else
     Error(i, InfoAboutToken(NestedDataType)+' arrays are not supported');

//    NumAllocElements := NestedNumAllocElements;
//    NestedAllocElementType := NestedDataType;
//    NestedDataType := POINTERTOK;

//    NestedDataType := NestedAllocElementType;
    NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

   end else
   if not (NestedDataType in [STRINGPOINTERTOK, RECORDTOK, OBJECTTOK{, PCHARTOK}]) and (Tok[i].Kind <> PCHARTOK) then begin

     if (NestedAllocElementType in [RECORDTOK, OBJECTTOK, PROCVARTOK]) and (NumAllocElements shr 16 > 0) then
       Error(i, 'Multidimensional arrays type ' +  InfoAboutToken(NestedAllocElementType) + ' are not supported');

     NestedDataType := NestedAllocElementType;

     if NestedAllocElementType = PROCVARTOK then
      NumAllocElements := NumAllocElements or NestedNumAllocElements
     else
      if NestedAllocElementType in [RECORDTOK, OBJECTTOK] then
       NumAllocElements := NestedNumAllocElements or (NumAllocElements shl 16)			// array [..] of ^record|^object
      else
       NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

   end;

  AllocElementType :=  NestedDataType;

//  writeln('** ',hexstr(NumAllocElements,8));

//  Result := i;
  end // if ARRAYTOK
else if (Tok[i].Kind = IDENTTOK) and (Ident[GetIdent(Tok[i].Name^)].Kind = USERTYPE) then
  begin
  IdentIndex := GetIdent(Tok[i].Name^);

  if IdentIndex = 0 then
    iError(i, UnknownIdentifier);

  if Ident[IdentIndex].Kind <> USERTYPE then
    Error(i, 'Type expected but ' + Tok[i].Name^ + ' found');

  DataType := Ident[IdentIndex].DataType;
  NumAllocElements := Ident[IdentIndex].NumAllocElements or (Ident[IdentIndex].NumAllocElements_ shl 16);
  AllocElementType := Ident[IdentIndex].AllocElementType;

// writeln('> ',Ident[IdentIndex].Name,',',DataType,',',AllocElementType,',',NumAllocElements);

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


   function Value(dorig: Boolean = false; brackets: Boolean = false): string;
   const reg: array [1..3] of string = (':EDX', ':ECX', ':EAX');			// !!! kolejnosc edx, ecx, eax !!! korzysta z tego memmove, memset !!!
   var ftmp: TFloat;
       v: Int64;
   begin

    move(Ident[IdentIndex].Value, ftmp, sizeof(ftmp));

    case Ident[IdentIndex].DataType of
     SHORTREALTOK, REALTOK: v := ftmp[0];
                 SINGLETOK: v := ftmp[1];
             HALFSINGLETOK: v := CardToHalf( ftmp[1] );
    else
      v := Ident[IdentIndex].Value;
    end;


    if dorig then begin

     if brackets then
      Result := #9'= [DATAORIGIN+$'+IntToHex(Ident[IdentIndex].Value - DATAORIGIN, 4)+']'
     else
      Result := #9'= DATAORIGIN+$'+IntToHex(Ident[IdentIndex].Value - DATAORIGIN, 4);

    end else
     if Ident[IdentIndex].isAbsolute and (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].Value and $ff = 0) and (byte((Ident[IdentIndex].Value shr 24) and $7f) in [1..127]) then begin

      case byte((Ident[IdentIndex].Value shr 24) and $7f) of
       1..3 : Result := #9'= '+reg[(Ident[IdentIndex].Value shr 24) and $7f];
       4..19: Result := #9'= :STACKORIGIN-'+IntToStr(byte((Ident[IdentIndex].Value shr 24) and $7f)-3);
      else
       Result := #9'= ''out of resource'''
      end;

      size := 0;
     end else

     if Ident[IdentIndex].isExternal then begin

      Result := #9'= ' + Tok[Ident[IdentIndex].Value + 1].Name^;

     end else

     if Ident[IdentIndex].isAbsolute then begin

      if Ident[IdentIndex].Value < 0 then
       Result := #9'= DATAORIGIN+$'+IntToHex(abs(Ident[IdentIndex].Value), 4)
      else
       if abs(Ident[IdentIndex].Value) < 256 then
        Result := #9'= $'+IntToHex(byte(Ident[IdentIndex].Value), 2)
       else
        Result := #9'= $'+IntToHex(Ident[IdentIndex].Value, 4);

     end else

      if Ident[IdentIndex].NumAllocElements > 0 then
	Result := #9'= CODEORIGIN+$'+IntToHex(Ident[IdentIndex].Value - CODEORIGIN_BASE - CODEORIGIN, 4)
      else
       if abs(v) < 256 then
	Result := #9'= $'+IntToHex(byte(v), 2)
       else
	Result := #9'= $'+IntToHex(v, 4);

   end;


  function mads_data_size: string;
  begin

   Result := '';

   if Ident[IdentIndex].AllocElementType in [BYTETOK..FORWARDTYPE] then begin

      case DataSize[Ident[IdentIndex].AllocElementType] of
    	//1: Result := ' .byte';
    	2: Result := ' .word';
    	4: Result := ' .dword';
      end;

   end else
    Result := ' ; type unknown';

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
     asm65;

     emptyLine:=false;
    end;


    case Ident[IdentIndex].Kind of

      VARIABLE: if Ident[IdentIndex].isAbsolute then begin		// ABSOLUTE = TRUE

		 if (Ident[IdentIndex].PassMethod <> VARPASSING) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		  asm65('adr.'+Ident[IdentIndex].Name + Value);
		  asm65('.var '+Ident[IdentIndex].Name + #9'= adr.' + Ident[IdentIndex].Name + ' .word');

		  if size = 0 then varbegin := Ident[IdentIndex].Name;
		  inc(size, Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType] );

		 end else
		  if Ident[IdentIndex].DataType = FILETOK then
		   asm65('.var '+Ident[IdentIndex].Name + Value + ' .word')
		  else
		   if pos('@FORTMP_', Ident[IdentIndex].Name) = 0 then asm65(Ident[IdentIndex].Name + Value);

		end else						// ABSOLUTE = FALSE

		 if (Ident[IdentIndex].PassMethod <> VARPASSING) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

//		writeln(Ident[IdentIndex].Name,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].IdType);

		  if (Ident[IdentIndex].IdType <> ARRAYTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then

		    asm65(Ident[IdentIndex].Name + Value(true))

		  else begin

		   if Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] then
		     asm65('adr.' + Ident[IdentIndex].Name + Value(true) + #9'; [' + IntToStr(RecordSize(IdentIndex)) + '] ' + InfoAboutToken(Ident[IdentIndex].DataType))
		   else

		   if Elements(IdentIndex) > 0 then begin

		    if (Ident[IdentIndex].NumAllocElements_ > 0) and not (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then
		     asm65('adr.' + Ident[IdentIndex].Name + Value(true, true) + ' .array [' + IntToStr(Ident[IdentIndex].NumAllocElements) + '] [' + IntToStr(Ident[IdentIndex].NumAllocElements_) + ']' + mads_data_size)
		    else
  		     asm65('adr.' + Ident[IdentIndex].Name + Value(true, true) + ' .array [' + IntToStr(Elements(IdentIndex)) + ']' + mads_data_size);

		   end else
		    asm65('adr.' + Ident[IdentIndex].Name + Value(true));

		   asm65('.var ' + Ident[IdentIndex].Name + #9'= adr.' + Ident[IdentIndex].Name + ' .word');

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

		     if (Ident[IdentIndex].Name = 'RESULT') and (Ident[BlockIdentIndex].Kind = FUNCTIONTOK) then	// RESULT nie zliczaj

		     else
		      inc(size, DataSize[Ident[IdentIndex].DataType]);

		  end;

      CONSTANT: if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		 asm65('adr.'+Ident[IdentIndex].Name + Value);
		 asm65('.var '+Ident[IdentIndex].Name+#9'= adr.' + Ident[IdentIndex].Name + ' .word');

		end else
		 if pos('@FORTMP_', Ident[IdentIndex].Name) = 0 then asm65(Ident[IdentIndex].Name + Value);
    end;

   end;

  if (BlockStack[BlockStackTop] <> 1) and VarSize and (size > 0) then begin
   asm65;
   asm65('@VarData'#9'= '+varbegin);
   asm65('@VarDataSize'#9'= '+IntToStr(size));
   asm65;
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

	HALFSINGLETOK: begin
			move(ConstVal, ftmp, sizeof(ftmp));
			ConstVal := CardToHalf( ftmp[1] );

			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	 end;
end;


function ReadDataArray(i: integer; ConstDataSize: integer; const ConstValType: Byte; NumAllocElements: cardinal; StaticData: Boolean; Add: Boolean = false): integer;
var ActualParamType, ch: byte;
    NumActualParams, NumActualParams_, NumAllocElements_: cardinal;
    ConstVal: Int64;


procedure SaveDataSegment(DataType: Byte);
begin

   if StaticData then
    SaveToStaticDataSegment(ConstDataSize, ConstVal + ord(Add), DataType)
   else
    SaveToDataSegment(ConstDataSize, ConstVal + ord(Add), DataType);

   if DataType = DATAORIGINOFFSET then
    inc(ConstDataSize, DataSize[POINTERTOK] )
   else
    inc(ConstDataSize, DataSize[DataType] );

end;


procedure SaveData;
begin

  i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);

  if (ConstValType = STRINGPOINTERTOK) and (ActualParamType = CHARTOK) then begin	// rejestrujemy CHAR jako STRING

    if StaticData then
      Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

    ch := Tok[i].Value;
    DefineStaticString(i, chr(ch));

    ConstVal:=Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
    Tok[i].Value := ch;

    ActualParamType := STRINGPOINTERTOK;

  end;


  if (ConstValType in StringTypes + [CHARTOK, STRINGPOINTERTOK]) and (ActualParamType in IntegerTypes + RealTypes) then
    iError(i, IllegalExpression);


  if (ConstValType in StringTypes + [STRINGPOINTERTOK]) and (ActualParamType = CHARTOK) then
   iError(i, IncompatibleTypes, 0, ActualParamType, ConstValType);


  if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (ActualParamType = REALTOK) then
   ActualParamType := ConstValType;

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

    if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
     warning(i, RangeCheckError, 0, ConstVal, ConstValType);

   end else
    GetCommonConstType(i, ConstValType, ActualParamType);

   SaveDataSegment(ConstValType);

  end;

end;


begin

  if (Tok[i].Kind = STRINGLITERALTOK) and (ConstValType = CHARTOK) then begin		// init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   if Tok[i].StrLength > NumAllocElements then
     Error(i, 'string length is larger than array of char length');

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > Tok[i].StrLength then
     ConstVal:=byte(' ')
    else
     ConstVal := byte(StaticStringData[Tok[i].StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;


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

    SaveData;

    inc(i);
   until Tok[i].Kind <> COMMATOK;

   CheckTok(i, CPARTOK);

   //inc(i);
  end else
   SaveData;

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
 if Ident[BlockIdentIndex].isKeep then info := info + ' | KEEP';
 if Ident[BlockIdentIndex].isPascal then info := info + ' | PASCAL';
 if Ident[BlockIdentIndex].isInline then info := info + ' | INLINE';

 asm65;

 if codealign.proc > 0 then begin
  asm65(#9'.align $' + IntToHex(codealign.proc,4));
  asm65;
 end;

 if Ident[BlockIdentIndex].isOverload then
   asm65('.local'#9 + Ident[BlockIdentIndex].Name+'_'+IntToHex(Ident[BlockIdentIndex].Value, 4), info)
 else
   asm65('.local'#9 + Ident[BlockIdentIndex].Name, info);

 if Ident[BlockIdentIndex].isInline then asm65(#13#10#9'.MACRO m@INLINE');

end;


procedure FormalParameterList(var i: integer; var NumParams: integer; var Param: TParamList; out Status: word; IsNestedFunction: Boolean; out NestedFunctionResultType: Byte; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: Byte);
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

	      Param[NumParams].DataType		:= VarType;
	      Param[NumParams].Name		:= VarOfSameType[VarOfSameTypeIndex].Name;
	      Param[NumParams].NumAllocElements := NumAllocElements;
	      Param[NumParams].AllocElementType	:= AllocElementType;
	      Param[NumParams].PassMethod	:= ListPassMethod;

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
	end;	// if IsNestedFunction

	CheckTok(i, SEMICOLONTOK);


	while Tok[i + 1].Kind in [OVERLOADTOK, ASSEMBLERTOK, FORWARDTOK, REGISTERTOK, INTERRUPTTOK, PASCALTOK, STDCALLTOK, INLINETOK, KEEPTOK] do begin

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

	      STDCALLTOK: begin
			   Status := Status or ord(mStdCall);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	      INLINETOK: begin
			   Status := Status or ord(mInline);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   INTERRUPTTOK: begin
			   Status := Status or ord(mInterrupt);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	      PASCALTOK: begin
			   Status := Status or ord(mPascal);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

             KEEPTOK: begin
			   Status := Status or ord(mKeep);
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;
	  end;

	  inc(i);
	end;// while

end;


procedure CheckForwardResolutions;
var TypeIndex, IdentIndex: Integer;
    Name: string;
begin

// Search for unresolved forward references
for TypeIndex := 1 to NumIdent do
  if (Ident[TypeIndex].AllocElementType = FORWARDTYPE) and
     (Ident[TypeIndex].Block = BlockStack[BlockStackTop]) then begin

     Name := Ident[GetIdent(Tok[Ident[TypeIndex].NumAllocElements].Name^)].Name;

     for IdentIndex := 1 to NumIdent do
       if (Ident[IdentIndex].Name = Name) and
          (Ident[IdentIndex].Block = BlockStack[BlockStackTop]) then begin

	   Ident[TypeIndex].NumAllocElements  := Ident[IdentIndex].NumAllocElements;
	   Ident[TypeIndex].NumAllocElements_ := 0;
	   Ident[TypeIndex].AllocElementType  := Ident[IdentIndex].DataType;

	   Break;
	  end;

    end;


// Search for unresolved forward references
for TypeIndex := 1 to NumIdent do
  if (Ident[TypeIndex].AllocElementType = FORWARDTYPE) and
     (Ident[TypeIndex].Block = BlockStack[BlockStackTop]) then
    Error(TypeIndex, 'Unresolved forward reference to type ' + Ident[TypeIndex].Name);

end;	// CheckForwardResolutions


function CompileBlock(i: Integer; BlockIdentIndex: Integer; NumParams: Integer; IsFunction: Boolean; FunctionResultType: Byte; FunctionNumAllocElements: cardinal = 0; FunctionAllocElementType: byte = 0): Integer;
var
  VarOfSameType: TVariableList;
  Param: TParamList;
  j, ParamIndex, NumVarOfSameType, VarOfSameTypeIndex, idx, tmpVarDataSize,  tmpVarDataSize_: Integer;
  ForwardIdentIndex, IdentIndex: integer;
  NumAllocElements, NestedNumAllocElements, NestedFunctionNumAllocElements: cardinal;
  ConstVal: Int64;
  IsNestedFunction, isAsm, isReg, isInt, isInl, isAbsolute, isExternal, isForward, ImplementationUse: Boolean;
  iocheck_old, isVolatile, isInterrupt_old, yes, pack: Boolean;
  VarType, VarRegister, NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType: Byte;
  NestedFunctionAllocElementType, NestedDataType, NestedAllocElementType, IdType, varPassMethod: Byte;
  Tmp, TmpResult: word;

  UnitList: array of TString;

begin

ResetOpty;

FillChar(VarOfSameType, sizeof(VarOfSameType), 0);

j := 0;
ConstVal := 0;
VarRegister := 0;

varPassMethod := 255;

ImplementationUse:=false;
pack:=false;

Param := Ident[BlockIdentIndex].Param;
isAsm := Ident[BlockIdentIndex].isAsm;
isReg := Ident[BlockIdentIndex].isRegister;
isInt := Ident[BlockIdentIndex].isInterrupt;
isInl := Ident[BlockIdentIndex].isInline;

isInterrupt:=isInt;

Inc(NumBlocks);
Inc(BlockStackTop);
BlockStack[BlockStackTop] := NumBlocks;
Ident[BlockIdentIndex].ProcAsBlock := NumBlocks;


GenerateLocal(BlockIdentIndex, IsFunction);

if (BlockStack[BlockStackTop] <> 1) {and (NumParams > 0)} and Ident[BlockIdentIndex].isRecursion then begin

 if Ident[BlockIdentIndex].isRegister then
   Error(i, 'Calling convention directive "REGISTER" not applicable with recursion');

 if not isInl then begin
  asm65(#9'.ifdef @VarData');
  asm65('@new'#9'lda <@VarData');			// @AllocMem
  asm65(#9'sta :ztmp');
  asm65(#9'lda >@VarData');
  asm65(#9'ldy #@VarDataSize-1');
  asm65(#9'jsr @AllocMem');
  asm65(#9'eif');
 end;

end;


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
      NumAllocElements := DataSize[ Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType ];
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


     if (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK]) then begin

      tmpVarDataSize := VarDataSize;

      for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do begin

       DefineIdent(i, Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,
		   VARIABLE,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
		   Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, DATAORIGINOFFSET);

       Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize;
       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;

       if Ident[NumIdent].AllocElementType = UNTYPETOK then Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;

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

//   writeln(Param[ParamIndex].Name,',',Param[ParamIndex].DataType);

     if (Param[ParamIndex].DataType = POINTERTOK) and (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin		// fix issue #94
																	//
      tmpVarDataSize := VarDataSize;													//
																	//
      for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do begin							//
																	//
       DefineIdent(i, Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,				//
		   VARIABLE,														//
		   Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,								//
		   Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,							//
		   Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, DATAORIGINOFFSET);				//
																	//
       Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize;									//
       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;									//
																	//
       if Ident[NumIdent].AllocElementType = UNTYPETOK then Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;		//
																	//
      end;																//
																	//
      VarDataSize := tmpVarDataSize;													//
																	//
     end else

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
if IsFunction then begin	//DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, 0, 0, 0);

    tmpVarDataSize := VarDataSize;

    DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, FunctionNumAllocElements, FunctionAllocElementType, 0);

    if isReg and (FunctionResultType in OrdinalTypes + RealTypes) then begin
      Ident[NumIdent].isAbsolute := true;
      Ident[NumIdent].Value := $87000000;	// :STACKORIGIN-4 -> :TMP

      VarDataSize := tmpVarDataSize;
    end;

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


yes := {(Ident[BlockIdentIndex].ObjectIndex > 0) or} Ident[BlockIdentIndex].isRecursion or Ident[BlockIdentIndex].isStdCall;

for ParamIndex := NumParams downto 1 do
 if not ( (Param[ParamIndex].PassMethod = VARPASSING) or
          ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].NumAllocElements and $FFFF in [0,1])) or
          ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) or
	  (Param[ParamIndex].DataType in OrdinalTypes + RealTypes)
	) then begin yes:=true; Break end;


// yes:=true;


// Load ONE parameters from the stack
if (Ident[BlockIdentIndex].ObjectIndex = 0) then
 if (yes = false) and (NumParams = 1) and (DataSize[Param[1].DataType] = 1) and (Param[1].PassMethod <> VARPASSING) then asm65(#9'sta ' + Param[1].Name);


// Load parameters from the stack
if yes then begin
 for ParamIndex := 1 to NumParams do begin

//  if ParamIndex = 1 then begin
//   asm65(#9'txa');
//   asm65(#9'jmi @main');
//  end;

  if Param[ParamIndex].PassMethod = VARPASSING then
     GenerateAssignment(ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
  else
     GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);

  if (Param[ParamIndex].PassMethod <> VARPASSING) and (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Param[ParamIndex].NumAllocElements and $FFFF > 1) then // copy arrays
   if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then begin

    idx := RecordSize(GetIdent(Param[ParamIndex].Name));

    asm65(':move');
    asm65(Param[ParamIndex].Name);
    asm65(IntToStr(idx));

//    asm65(#9'@move '+Param[ParamIndex].Name+' #adr.'+Param[ParamIndex].Name+' #'+IntToStr(idx));
//    asm65(#9'mwa #adr.'+Param[ParamIndex].Name+' '+Param[ParamIndex].Name);
   end else
   if not (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

    if Param[ParamIndex].NumAllocElements shr 16 <> 0 then
     NumAllocElements := (Param[ParamIndex].NumAllocElements and $FFFF) * (Param[ParamIndex].NumAllocElements shr 16)
    else
     NumAllocElements := Param[ParamIndex].NumAllocElements;

    asm65(':move');
    asm65(Param[ParamIndex].Name);
    asm65(IntToStr(integer(NumAllocElements * DataSize[Param[ParamIndex].AllocElementType])));

//    asm65(#9'@move '+Param[ParamIndex].Name+' #adr.'+Param[ParamIndex].Name+' #'+IntToStr(integer(Param[ParamIndex].NumAllocElements * DataSize[Param[ParamIndex].AllocElementType])));
//    asm65(#9'mwa #adr.'+Param[ParamIndex].Name+' '+Param[ParamIndex].Name);
   end;

   if (Paramindex <> NumParams) then asm65(#9'jmi @main');

 end;

asm65('@main');
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


asm65;

if not isAsm then				// skaczemy do poczatku bloku procedury, wazne dla zagniezdzonych procedur / funkcji
  GenerateDeclarationProlog;


while Tok[i].Kind in
 [CONSTTOK, TYPETOK, VARTOK, LABELTOK, PROCEDURETOK, FUNCTIONTOK, PROGRAMTOK, USESTOK, LIBRARYTOK, EXPORTSTOK,
  CONSTRUCTORTOK, DESTRUCTORTOK, LINKTOK,
  UNITBEGINTOK, UNITENDTOK, IMPLEMENTATIONTOK, INITIALIZATIONTOK, IOCHECKON, IOCHECKOFF,
  PROCALIGNTOK, LOOPALIGNTOK, LINKALIGNTOK, INFOTOK, WARNINGTOK, ERRORTOK] do
  begin


  if Tok[i].Kind = LINKTOK then begin

   if codealign.link > 0 then begin
    asm65(#9'.align $' + IntToHex(codealign.link,4));
    asm65;
   end;

   asm65(#9'.link ''' + linkObj[ Tok[i].Value ] + '''');
   inc(i, 2);
  end;


  if Tok[i].Kind = PROCALIGNTOK then begin
   if Pass = CODEGENERATIONPASS then codealign.proc := Tok[i].Value;
   inc(i, 2);
  end;


  if Tok[i].Kind = LOOPALIGNTOK then begin
   if Pass = CODEGENERATIONPASS then codealign.loop := Tok[i].Value;
   inc(i, 2);
  end;


  if Tok[i].Kind = LINKALIGNTOK then begin
   if Pass = CODEGENERATIONPASS then codealign.link := Tok[i].Value;
   inc(i, 2);
  end;


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
   Ident[NumIdent].UnitIndex := Tok[i].UnitIndex;

//   writeln(UnitName[Tok[i].UnitIndex].Name,',',Ident[NumIdent].UnitIndex,',',Tok[i].UnitIndex);

   asm65;
   asm65('.local'#9 + UnitName[Tok[i].UnitIndex].Name, '; UNIT');

   UnitNameIndex := Tok[i].UnitIndex;

   CheckTok(i + 1, UNITTOK);
   CheckTok(i + 2, IDENTTOK);

   if Tok[i + 2].Name^ <> UnitName[Tok[i].UnitIndex].Name then
    Error(i + 2, 'Illegal unit name: ' + Tok[i + 2].Name^);

   CheckTok(i + 3, SEMICOLONTOK);

   while Tok[i + 4].Kind in [WARNINGTOK, ERRORTOK, INFOTOK] do inc(i,2);

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

   asm65;
   asm65('.endl', '; UNIT ' + UnitName[Tok[i].UnitIndex].Name);

   j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = UnitNameIndex) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROCEDURETOK, FUNC, CONSTRUCTORTOK, DESTRUCTORTOK] then
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

   asm65;
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
    if (UnitName[UnitNameIndex].Allow[j] = Tok[i].Name^) or (Tok[i].Name^='SYSTEM') then yes:=false;

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

	  if Tok[j].Kind in StringTypes then begin

	   if Tok[j].StrLength > 255 then
	     DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, POINTERTOK, 0, CHARTOK, ConstVal + CODEORIGIN, PCHARTOK)
	   else
	     DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, ConstValType, Tok[j].StrLength, CHARTOK, ConstVal + CODEORIGIN, Tok[j].Kind);

	  end else
   	   if (ConstValType in Pointers) then
	     iError(j, IllegalExpression)
	   else
	     DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, ConstValType, 0, 0, ConstVal, Tok[j].Kind);

	  i := j;
	end else
	if Tok[i + 2].Kind = COLONTOK then begin

	  j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

	  if Tok[i +3].Kind = ARRAYTOK then j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	  if (VarType in Pointers) and (NumAllocElements = 0) then
	   if AllocElementType <> CHARTOK then iError(j, IllegalExpression);

	  CheckTok(j + 1, EQTOK);

	  if Tok[i + 3].Kind in StringTypes then begin

	   j := CompileConstExpression(j + 2, ConstVal, ConstValType);

	   if Tok[i + 3].Kind = PCHARTOK then
	    DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, POINTERTOK, 0, CHARTOK, ConstVal + CODEORIGIN + 1, PCHARTOK)
	   else
	    DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, ConstValType, Tok[j].StrLength, CHARTOK, ConstVal + CODEORIGIN, Tok[j].Kind);

	  end else

	  if NumAllocElements > 0 then begin
	   DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, POINTERTOK, NumAllocElements, AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE, IDENTTOK);

	   j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true, Tok[j].Kind = PCHARTOK);

	   if NumAllocElements shr 16 > 0 then
	     inc(NumStaticStrChars, ((NumAllocElements and $ffff) * (NumAllocElements shr 16)) * DataSize[AllocElementType])
	   else
	     inc(NumStaticStrChars, NumAllocElements * DataSize[AllocElementType]);

	  end else begin
	   j := CompileConstExpression(j + 2, ConstVal, ConstValType, VarType, false);


	   if (VarType in [SINGLETOK, HALFSINGLETOK]) and (ConstValType in [SHORTREALTOK, REALTOK]) then ConstValType := VarType;
	   if (VarType = SHORTREALTOK) and (ConstValType = REALTOK) then ConstValType := SHORTREALTOK;


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

	   if Tok[i +3].Kind = ARRAYTOK then j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	   DefineIdent(i + 1, Tok[i + 1].Name^, USERTYPE, VarType, NumAllocElements, AllocElementType, 0, Tok[i + 3].Kind);
	   Ident[NumIdent].Pass := CALLDETERMPASS;

	  end;

      CheckTok(j + 1, SEMICOLONTOK);

      i := j + 1;
    until Tok[i + 1].Kind <> IDENTTOK;

    CheckForwardResolutions;

    i := i + 1;
    end;// if TYPETOK


  if Tok[i].Kind = VARTOK then
    begin

    isVolatile := false;

    if (Tok[i + 1].Kind = OBRACKETTOK) and (Tok[i + 2].Kind = VOLATILETOK) then begin
       CheckTok(i + 3, CBRACKETTOK);

       isVolatile := true;

       inc(i, 3);
    end;

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

      pack:=false;


      if Tok[i + 1].Kind = PACKEDTOK then begin

       if (Tok[i + 2].Kind in [ARRAYTOK, RECORDTOK]) then begin
        inc(i);
        pack := true;
       end else
        CheckTok(i + 2, RECORDTOK);

      end;

      IdType := Tok[i + 1].Kind;

      i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

      isAbsolute := false;
      isExternal := false;

      if IdType = ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


      if Tok[i + 1].Kind = REGISTERTOK then begin

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'REGISTER can only be associated to one variable');

	isAbsolute := true;

	inc(VarRegister, DataSize[VarType]);

	ConstVal := (VarRegister+3) shl 24 + 1 ;

	inc(i);

      end else

      if Tok[i + 1].Kind = EXTERNALTOK then begin

       if NumVarOfSameType > 1 then
	 Error(i + 1, 'Only one variable can be initialized');

//	 Ident[NumIdent].isExternal:=true;

       isAbsolute := true;
       isExternal := true;

//	 Ident[NumIdent].isInit := true;

       inc(i);

       if Tok[i + 1].Kind <> IDENTTOK then
         iError(i + 1, IdentifierExpected);

//       ConstVal := GetIdent(Tok[i + 1].Name^);

        ConstVal:=i+1;

       inc(i);

//       VarType := POINTERTOK;


      end else


      if Tok[i + 1].Kind = ABSOLUTETOK then begin

	isAbsolute := true;

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'ABSOLUTE can only be associated to one variable');


	if (VarType in [RECORDTOK, OBJECTTOK] {+ Pointers}) and (NumAllocElements = 0) then	 // brak mozliwosci identyfikacji dla takiego przypadku
	 Error(i + 1, 'not possible in this case');

	inc(i);

	varPassMethod := 255;

	if (Tok[i+1].Kind = IDENTTOK) and (Ident[GetIdent(Tok[i+1].Name^)].Kind = VARTOK) then begin
	 ConstVal := Ident[GetIdent(Tok[i+1].Name^)].Value - DATAORIGIN;

	 varPassMethod := Ident[GetIdent(Tok[i+1].Name^)].PassMethod;

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
// writeln(VarType,',',NumAllocElements and $FFFF,',',NumAllocElements shr 16,',',AllocElementType, ',',idType);


	if VarType = DEREFERENCEARRAYTOK then begin

	  VarType := POINTERTOK;

	  NestedNumAllocElements := NumAllocElements;

	  IdType := DEREFERENCEARRAYTOK;

          NumAllocElements := 1;

	end;


	if VarType = ENUMTYPE then begin

	  DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, AllocElementType, 0, 0, 0, IdType);

	  Ident[NumIdent].DataType := ENUMTYPE;
	  Ident[NumIdent].AllocElementType := AllocElementType;
	  Ident[NumIdent].NumAllocElements := NumAllocElements;

	end else begin
	  DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, VarType, NumAllocElements, AllocElementType, ord(isAbsolute) * ConstVal, IdType);

	  Ident[NumIdent].NestedDataType := NestedDataType;
	  Ident[NumIdent].NestedAllocElementType := NestedAllocElementType;
	  Ident[NumIdent].NestedNumAllocElements := NestedNumAllocElements;
	  Ident[NumIdent].isVolatile := isVolatile;

	  if varPassMethod <> 255 then Ident[NumIdent].PassMethod := varPassMethod;

	  varPassMethod := 255;

//	  writeln(VarType, ' / ', AllocElementType ,' = ',NestedDataType, ',',NestedAllocElementType,',', hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));

	  if (VarType = POINTERTOK) and (AllocElementType = STRINGPOINTERTOK) and (NestedNumAllocElements > 0) and (NumAllocElements > 1) then begin	// array [ ][ ] of string;

	   idx := Ident[NumIdent].Value - DATAORIGIN;

	   if NumAllocElements shr 16 > 0 then begin

		for j:=0 to (NumAllocElements and $FFFF) * (NumAllocElements shr 16) - 1 do begin
      		  SaveToDataSegment(idx, VarDataSize, DATAORIGINOFFSET);

		  inc(idx, 2);
 		  inc(VarDataSize, NestedNumAllocElements);
		end;

	   end else begin

		for j:=0 to NumAllocElements - 1 do begin
      		  SaveToDataSegment(idx, VarDataSize, DATAORIGINOFFSET);

		  inc(idx, 2);
 		  inc(VarDataSize, NestedNumAllocElements);
		end;

	   end;

	  end;


	end;


//	writeln(VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',Types[NumAllocElements].Block,' | ', AllocElementType);

	if ( (VarType in Pointers) and (AllocElementType = RECORDTOK) ) then begin

//	 writeln('> ',NestedDataType, ',',NestedAllocElementType,',', NestedNumAllocElements);

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


	 idx := Ident[NumIdent].Value - DATAORIGIN;

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

//	    writeln(VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,',',Types[NumAllocElements].Field[ParamIndex].DataType,',',Types[NumAllocElements].Field[ParamIndex].AllocElementType,' | ',Ident[NumIdent].Value);

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


       if isExternal then Ident[NumIdent].isExternal := true;


       if isAbsolute then

	VarDataSize := tmpVarDataSize

       else

       if Tok[i + 1].Kind = EQTOK then begin

	if VarType in [RECORDTOK, OBJECTTOK] then
	 Error(i + 1, 'Initialization for '+InfoAboutToken(VarType)+' not allowed');

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'Only one variable can be initialized');

	inc(i);


	if (VarType = POINTERTOK) and (AllocElementType in [RECORDTOK, OBJECTTOK]) then

	else
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
		  iError(i + 1, CantAdrConstantExp)
		else
		 SaveToDataSegment(idx, Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_BASE, CODEORIGINOFFSET);

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

	   if (Ident[NumIdent].NumAllocElements > 0 ) and (Tok[i].StrLength > Ident[NumIdent].NumAllocElements) then begin
	    Warning(i, StringTruncated, NumIdent);

	    ParamIndex := Ident[NumIdent].NumAllocElements;
	   end else
	    ParamIndex := Tok[i].StrLength + 1;

	   VarType := STRINGPOINTERTOK;

	   if (Ident[NumIdent].NumAllocElements = 0) then 					// var label: pchar = ''
	    SaveToDataSegment(idx, Tok[i].StrAddress - CODEORIGIN + 1, CODEORIGINOFFSET)
	   else begin

	     if (IdType = ARRAYTOK) and (AllocElementType = CHARTOK) then begin			// var label: array of char = ''

	      if Tok[i].StrLength > NumAllocElements then
     	        Error(i, 'string length is larger than array of char length');

 	      for j := 0 to Ident[NumIdent].NumAllocElements-1 do
	       if j > Tok[i].StrLength-1 then
 	         SaveToDataSegment(idx + j, ord(' '), CHARTOK)
	       else
 	         SaveToDataSegment(idx + j, ord( StaticStringData[ Tok[i].StrAddress - CODEORIGIN + j + 1] ), CHARTOK);

	     end else
 	      for j := 0 to ParamIndex-1 do							// var label: string = ''
 	        SaveToDataSegment(idx + j, ord( StaticStringData[ Tok[i].StrAddress - CODEORIGIN + j ] ), BYTETOK);

	   end;

	  end else
	   if Ident[NumIdent].NumAllocElements = 0 then
	    iError(i, IllegalExpression)
	   else 										// array [] of type = ( )
	    i := ReadDataArray(i, idx, Ident[NumIdent].AllocElementType, Ident[NumIdent].NumAllocElements or Ident[NumIdent].NumAllocElements_ shl 16, false, Tok[i-2].Kind = PCHARTOK);

	end;

       end;

      CheckTok(i + 1, SEMICOLONTOK);

      isVolatile := false;

      if (Tok[i + 2].Kind = OBRACKETTOK) and (Tok[i + 3].Kind = VOLATILETOK) then begin
       CheckTok(i + 4, CBRACKETTOK);

       isVolatile := true;

       inc(i, 3);
      end;

    i := i + 1;
    until Tok[i + 1].Kind <> IDENTTOK;

    i := i + 1;
    end;// if VARTOK


  if Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
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

       ForwardIdentIndex := GetIdentProc(Ident[ForwardIdentIndex].Name, ForwardIdentIndex, Param, ParamIndex);

      end;


      if ForwardIdentIndex <> 0 then
       if (Ident[ForwardIdentIndex].IsUnresolvedForward) and (Ident[ForwardIdentIndex].Block = BlockStack[BlockStackTop]) then
	if Tok[i].Kind <> Ident[ForwardIdentIndex].Kind then
	 Error(i, 'Unresolved forward declaration of ' + Ident[ForwardIdentIndex].Name);


      if ForwardIdentIndex <> 0 then
       if not Ident[ForwardIdentIndex].IsUnresolvedForward or
	 (Ident[ForwardIdentIndex].Block <> BlockStack[BlockStackTop]) or
	 ((Tok[i].Kind = PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROCEDURETOK)) or
//	 ((Tok[i].Kind = CONSTRUCTORTOK) and (Ident[ForwardIdentIndex].Kind <> CONSTRUCTORTOK)) or
//	 ((Tok[i].Kind = DESTRUCTORTOK) and (Ident[ForwardIdentIndex].Kind <> DESTRUCTORTOK)) or
	 ((Tok[i].Kind = FUNCTIONTOK) and (Ident[ForwardIdentIndex].Kind <> FUNCTIONTOK)) then
	ForwardIdentIndex := 0;     // Found an identifier of another kind or scope, or it is already resolved


      if (Tok[i].Kind in [CONSTRUCTORTOK, DESTRUCTORTOK]) and (ForwardIdentIndex = 0) then
        Error(i, 'constructors, destructors operators must be methods');


//    writeln(ForwardIdentIndex,',',tok[i].line,',',Ident[ForwardIdentIndex].isOverload,',',Ident[ForwardIdentIndex].IsUnresolvedForward,' / ',Tok[i].Kind = PROCEDURETOK,',',  ((Tok[i].Kind = PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROC)));

    i := DefineFunction(i, ForwardIdentIndex, isForward, isInt, isInl, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);


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

	if ((Pass = CODEGENERATIONPASS) and ( not Ident[NumIdent].IsNotDead) ) then	// Do not compile dead procedures and functions
	  begin
	  OutputDisabled := TRUE;
	  end;

	iocheck_old := IOCheck;
        isInterrupt_old := isInterrupt;

	j := CompileBlock(i + 1, NumIdent, Ident[NumIdent].NumParams, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	IOCheck := iocheck_old;
	isInterrupt := isInterrupt_old;

	i := j + 1;

	GenerateReturn(IsNestedFunction, isInt, isInl);

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

//	   function header "arg1" doesn't match forward : var name changes arg2 = arg3

	 for ParamIndex := 1 to Ident[ForwardIdentIndex].NumParams do
	  if ((Ident[ForwardIdentIndex].Param[ParamIndex].Name <> Param[ParamIndex].Name) or (Ident[ForwardIdentIndex].Param[ParamIndex].DataType <> Param[ParamIndex].DataType)) then
	    Error(i, 'Function header '''+Ident[ForwardIdentIndex].Name+''' doesn''t match forward : '+  Ident[ForwardIdentIndex].Param[ParamIndex].Name +' <> ' + Param[ParamIndex].Name);

	 for ParamIndex := 1 to Ident[ForwardIdentIndex].NumParams do
	  if (Ident[ForwardIdentIndex].Param[ParamIndex].PassMethod <> Param[ParamIndex].PassMethod) then
	    Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');

	end;

	 Tmp := 0;

	 if Ident[ForwardIdentIndex].isKeep	 then Tmp := Tmp or ord(mKeep);
	 if Ident[ForwardIdentIndex].isOverload	 then Tmp := Tmp or ord(mOverload);
	 if Ident[ForwardIdentIndex].isAsm	 then Tmp := Tmp or ord(mAssembler);
	 if Ident[ForwardIdentIndex].isRegister	 then Tmp := Tmp or ord(mRegister);
	 if Ident[ForwardIdentIndex].isInterrupt then Tmp := Tmp or ord(mInterrupt);
	 if Ident[ForwardIdentIndex].isPascal	 then Tmp := Tmp or ord(mPascal);
	 if Ident[ForwardIdentIndex].isStdCall	 then Tmp := Tmp or ord(mStdCall);
	 if Ident[ForwardIdentIndex].isInline	 then Tmp := Tmp or ord(mInline);

	 if Tmp <> TmpResult then
	   Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');


	 if IsNestedFunction then
	   if (Ident[ForwardIdentIndex].DataType <> NestedFunctionResultType) or
	      (Ident[ForwardIdentIndex].NestedFunctionNumAllocElements <> NestedFunctionNumAllocElements) or
	      (Ident[ForwardIdentIndex].NestedFunctionAllocElementType <> NestedFunctionAllocElementType) then
	     Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');


	CheckTok(i + 2, SEMICOLONTOK);

	iocheck_old := IOCheck;
	isInterrupt_old := isInterrupt;

	j := CompileBlock(i + 3, ForwardIdentIndex, Ident[ForwardIdentIndex].NumParams, IsNestedFunction, Ident[ForwardIdentIndex].DataType, Ident[ForwardIdentIndex].NestedFunctionNumAllocElements, Ident[ForwardIdentIndex].NestedFunctionAllocElementType);

	IOCheck := iocheck_old;
	isInterrupt := isInterrupt_old;

	i := j + 1;

	GenerateReturn(IsNestedFunction, isInt, Ident[ForwardIdentIndex].isInline);

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

 if not(Tok[i-1].Kind in [PROCALIGNTOK, LOOPALIGNTOK, LINKALIGNTOK]) then
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
  if Ident[j].Kind in [PROCEDURETOK, FUNC, CONSTRUCTORTOK, DESTRUCTORTOK] then
    if (Ident[j].IsUnresolvedForward) then
      Error(i, 'Unresolved forward declaration of ' + Ident[j].Name);

  Dec(j);
  end;


// Return Result value

if IsFunction then begin
// if FunctionNumAllocElements > 0 then
//  Push(Ident[GetIdent('RESULT')].Value, ASVALUE, DataSize[FunctionResultType], GetIdent('RESULT'))
// else
//  asm65;
  asm65('@exit');

  if Ident[BlockIdentIndex].isStdCall or Ident[BlockIdentIndex].isRecursion then begin

    Push(Ident[GetIdent('RESULT')].Value, ASPOINTER, DataSize[FunctionResultType], GetIdent('RESULT'));

    asm65;

    if not isInl then begin
      asm65(#9'.ifdef @new');			// @FreeMem
      asm65(#9'lda <@VarData');
      asm65(#9'sta :ztmp');
      asm65(#9'lda >@VarData');
      asm65(#9'ldy #@VarDataSize-1');
      asm65(#9'jmp @FreeMem');
      asm65(#9'eif');
    end;

   end;

end;

if Ident[BlockIdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then begin

 if Ident[BlockIdentIndex].isInline then asm65(#9'.ENDM');

 GenerateProcFuncAsmLabels(BlockIdentIndex, true);

end;

Dec(BlockStackTop);


 if (Ident[BlockIdentIndex].isKeep) or (Ident[BlockIdentIndex].isInterrupt) then
  if Pass = CALLDETERMPASS then
    AddCallGraphChild(BlockStack[BlockStackTop], Ident[BlockIdentIndex].ProcAsBlock);


//Result := j;
end;// CompileBlock


procedure CompileProgram;
var i, j, DataSegmentSize, IdentIndex: Integer;
    tmp, a: string;
    yes: Boolean;
    res: TResource;
begin

optimize.use := false;

IOCheck := true;

DataSegmentSize := 0;

AsmBlockIndex := 0;

SetLength(AsmLabels, 1);

DefineIdent(1, 'MAIN', PROCEDURETOK, 0, 0, 0, 0);

GenerateProgramProlog;


j := CompileBlock(1, NumIdent, 0, FALSE, 0);


if Tok[j].Kind = ENDTOK then CheckTok(j + 1, DOTTOK) else
 if Tok[NumTok].Kind = EOFTOK then
   Error(NumTok, 'Unexpected end of file');

j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = 1) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROCEDURETOK, FUNC, CONSTRUCTORTOK, DESTRUCTORTOK] then
       if (Ident[j].IsUnresolvedForward) and (Ident[j].isExternal = false) then
	 Error(j, 'Unresolved forward declaration of ' + Ident[j].Name);

     Dec(j);
     end;

StopOptimization;

//asm65;
asm65('@exit');
asm65;
asm65('@halt'#9'ldx #$00');
asm65(#9'txs');

if target.id = 'a8' then begin
 asm65(#9'.ifdef MAIN.@DEFINES.ROMOFF');
 asm65(#9'inc portb');
 asm65(#9'.fi');
 asm65;
 asm65(#9'ldy #$01');
end;

asm65;
asm65(#9'rts');

asm65separator;

if target.id = 'a8' then begin
 asm65;
 asm65('IOCB@COPY'#9':16 brk');
end;

asm65separator;

asm65;
asm65('.local'#9'@DEFINES');

for j:=1 to MAXDEFINES do
 if (Defines[j].Name <> '') and (Defines[j].Macro = '') then asm65( Defines[j].Name );

asm65('.endl');


asm65(#13#10'.local'#9'@RESOURCE');

 for i := 0 to High(resArray) - 1 do begin

  resArray[i].resStream := false;

  yes:=false;
  for IdentIndex := 1 to NumIdent do
    if (resArray[i].resName = Ident[IdentIndex].Name) and (Ident[IdentIndex].Block = 1) then begin

     if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then
      tmp := GetLocalName(IdentIndex, 'adr.')
     else
      tmp := GetLocalName(IdentIndex);

//     asm65(resArray[i].resName+' = ' + tmp);
//     asm65(resArray[i].resName+'.end');

     yes:=true; Break;
    end;


  if not yes then
   if AnsiUpperCase(resArray[i].resType) = 'SAPR' then begin
    asm65(resArray[i].resName);
    asm65(#9'dta a('+resArray[i].resName+'.end-'+resArray[i].resName+'-2)');
    asm65(#9'ins '''+resArray[i].resFile+'''');
    asm65(resArray[i].resName+'.end');
    resArray[i].resStream := true;
   end else

   if AnsiUpperCase(resArray[i].resType) = 'RCDATA' then begin
    asm65(resArray[i].resName+#9'ins '''+resArray[i].resFile+'''');
    asm65(resArray[i].resName+'.end');
    resArray[i].resStream := true;
   end else

    Error(NumTok, 'Resource identifier not found: Type = '+resArray[i].resType+', Name = '+resArray[i].resName);

//  asm65(#9+resArray[i].resType+' '''+resArray[i].resFile+''''+','+resArray[i].resName);

  resArray[i].resFullName := tmp;

  Ident[IdentIndex].Pass := Pass;
 end;

asm65('.endl');


asm65;
asm65('.endl','; MAIN');
//GenerateReturn(false, false);

asm65separator;
asm65separator(false);

asm65;
asm65('.macro'#9'UNITINITIALIZATION');

for j := NumUnits downto 2 do
 if UnitName[j].Name <> '' then begin

  asm65;
  asm65(#9'.ifdef MAIN.'+UnitName[j].Name+'.@UnitInit');
  asm65(#9'jsr MAIN.'+UnitName[j].Name+'.@UnitInit');
  asm65(#9'.fi');

 end;

asm65('.endm');

asm65separator;

for j := NumUnits downto 2 do
 if UnitName[j].Name <> '' then begin
  asm65;
  asm65(#9'ift .SIZEOF(MAIN.'+UnitName[j].Name+') > 0');
  asm65(#9'.print '''+UnitName[j].Name+': '+''',MAIN.'+UnitName[j].Name+','+'''..'''+','+'MAIN.'+UnitName[j].Name+'+.SIZEOF(MAIN.'+UnitName[j].Name+')-1');
  asm65(#9'eif');
 end;

asm65;
asm65('.nowarn'#9'.print ''CODE: '',CODEORIGIN,''..'',MAIN.@RESOURCE-1');

for i:=0 to High(resArray)-1 do
 if resArray[i].resStream then
   asm65(#9'.print ''$R '+resArray[i].resName+''','+''' '''+','+'"'''+resArray[i].resFile+'''"'+','+''' '''+',MAIN.@RESOURCE.'+resArray[i].resName+','+'''..'''+',MAIN.@RESOURCE.'+resArray[i].resName+'.end-1');

asm65separator;

asm65;

if DATA_Atari > 0 then
 asm65(#9'org $'+IntToHex(DATA_Atari, 4))
else begin

 asm65(#9'?adr = *');
 asm65(#9'ift (?adr < ?old_adr) && (?old_adr - ?adr < 256)');
 asm65(#9'?adr = ?old_adr');
 asm65(#9'eif');
 asm65;
 asm65(#9'org ?adr');
 asm65(#9'?old_adr = *');

end;


asm65;
asm65('DATAORIGIN');

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

 // asm65;

//  asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',*');

 end;

end;{ else
 asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',DATAORIGIN+'+IntToStr(VarDataSize));
}

asm65;
asm65('VARINITSIZE'#9'= *-DATAORIGIN');
asm65('VARDATASIZE'#9'= '+IntToStr(VarDataSize));

asm65;
asm65('PROGRAMSTACK'#9'= DATAORIGIN+VARDATASIZE');

asm65;
asm65(#9'.print ''DATA: '',DATAORIGIN,''..'',PROGRAMSTACK');


if FastMul > 0  then begin

 asm65separator;

 asm65;
 asm65(#9'icl ''common\fmul.asm''', '; fast multiplication');

 asm65;
 asm65(#9'.print ''FMUL_INIT: '',fmulinit,''..'',*-1');

 asm65;
 asm65(#9'org $'+IntToHex(FastMul, 2)+'00');

 asm65;
 asm65(#9'.print ''FMUL_DATA: '',*,''..'',*+$07FF');

 asm65;
 asm65('square1_lo'#9'.ds $200');
 asm65('square1_hi'#9'.ds $200');
 asm65('square2_lo'#9'.ds $200');
 asm65('square2_hi'#9'.ds $200');

end;

if target.id = 'a8' then begin
 asm65;
 asm65(#9'run START');
end;

asm65separator;

asm65;
asm65('.macro'#9'STATICDATA');

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


 if (High(resArray) > 0) and (target.id <> 'a8') then begin

  asm65;
  asm65('.local'#9'RESOURCE');

  asm65(#9'icl '''+target.id+'\resource.asm''');

  asm65;


  for i := 0 to High(resArray) - 1 do
   if resArray[i].resStream = false then begin

    j := NumIdent;

    while (j > 0) and (Ident[j].UnitIndex = 1) do begin
     if Ident[j].Name = resArray[i].resName then begin resArray[i].resValue := Ident[j].Value; Break end;
     Dec(j);
    end;

  end;


  for i:=0 to High(resArray)-1 do
   for j:=0 to High(resArray)-1 do
    if resArray[i].resValue < resArray[j].resValue then begin
     res := resArray[j];
     resArray[j] := resArray[i];
     resArray[i] := res;
    end;


  for i := 0 to High(resArray) - 1 do
   if resArray[i].resStream = false then begin

    a:=#9+resArray[i].resType+' '''+resArray[i].resFile+''''+' ';

    a:=a+resArray[i].resFullName;

    for j := 1 to MAXPARAMS do a:=a+' '+resArray[i].resPar[j];

    asm65(a);
   end;

  asm65('.endl');
 end;


asm65;
asm65(#9'end');

for i:=0 to High(TemporaryBuf) do WriteOut('');		// flush TemporaryBuf

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

  AssignFile(DiagFile, ChangeFileExt( UnitName[1].Name, '.txt') );
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
    if (Ident[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and not Ident[i].IsNotDead then WriteLn(DiagFile, 'Yes': 5) else WriteLn(DiagFile, '': 5);
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


{$i include/syntax.inc}


procedure ParseParam;
var i, err: integer;
    s, t: string;
begin

 t:='A8';

 i:=1;
 while i <= ParamCount do begin

  if ParamStr(i)[1] = '-' then begin

   if AnsiUpperCase(ParamStr(i)) = '-O' then begin

     outputFile := ParamStr(i+1);
     inc(i);
     if outputFile = '' then Syntax(3);

   end else
   if pos('-O:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     outputFile := copy(ParamStr(i), 4, 255);

     if outputFile = '' then Syntax(3);

   end else
   if AnsiUpperCase(ParamStr(i)) = '-DIAG' then
    DiagMode := TRUE
   else

   if (AnsiUpperCase(ParamStr(i)) = '-IPATH') or (AnsiUpperCase(ParamStr(i)) = '-I') then begin

     AddPath(ParamStr(i+1));
     inc(i);

   end else
   if pos('-IPATH:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     s:=copy(ParamStr(i), 8, 255);
     AddPath(s);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-DEFINE') or (AnsiUpperCase(ParamStr(i)) = '-DEF') then begin

     AddDefine(AnsiUpperCase(ParamStr(i+1)));
     inc(i);
     AddDefines := NumDefines;

   end else
   if pos('-DEFINE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     s:=copy(ParamStr(i), 9, 255);
     AddDefine(AnsiUpperCase(s));
     AddDefines := NumDefines;

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-CODE') or (AnsiUpperCase(ParamStr(i)) = '-C') then begin

     val('$'+ParamStr(i+1), CODEORIGIN_BASE, err);
     inc(i);
     if err<>0 then Syntax(3);

     raw.codeorigin := CODEORIGIN_BASE;

   end else
   if pos('-CODE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 7, 255), CODEORIGIN_BASE, err);
     if err<>0 then Syntax(3);

     raw.codeorigin := CODEORIGIN_BASE;

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-DATA') or (AnsiUpperCase(ParamStr(i)) = '-D') then begin

     val('$'+ParamStr(i+1), DATA_Atari, err);
     inc(i);
     if err<>0 then Syntax(3);

   end else
   if pos('-DATA:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 7, 255), DATA_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-STACK') or (AnsiUpperCase(ParamStr(i)) = '-S') then begin

     val('$'+ParamStr(i+1), STACK_Atari, err);
     inc(i);
     if err<>0 then Syntax(3);

   end else
   if pos('-STACK:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 8, 255), STACK_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-ZPAGE') or (AnsiUpperCase(ParamStr(i)) = '-Z') then begin

     val('$'+ParamStr(i+1), ZPAGE_Atari, err);
     inc(i);
     if err<>0 then Syntax(3);

   end else
   if pos('-ZPAGE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 8, 255), ZPAGE_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-TARGET') or (AnsiUpperCase(ParamStr(i)) = '-T') then begin

     t:=AnsiUpperCase(ParamStr(i+1));
     inc(i);

   end else
   if pos('-TARGET:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     t:=AnsiUpperCase(copy(ParamStr(i), 9, 255));

   end else
     Syntax(3);

  end else

   begin
    UnitName[1].Name := ParamStr(i);	//ChangeFileExt(ParamStr(i), '.pas');
    UnitName[1].Path := UnitName[1].Name;

    if not FileExists(UnitName[1].Name) then begin
     writeln('Error: Can''t open file '''+UnitName[1].Name+'''');
     FreeTokens;
     Halt(3);
    end;

   end;

  inc(i);
 end;

{$i targets/parse_param.inc}

end;


// Main program

begin

{$IFDEF WINDOWS}
 if GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) = 3 then begin
  Assign(Output, ''); Rewrite(Output);
 end;
{$ENDIF}

//WriteLn('Sub-Pascal 32-bit real mode compiler v. 2.0 by Vasiliy Tereshkov, 2009');


 {$i targets/init.inc}


 WriteLn(CompilerTitle);

 SetLength(Tok, 1);
 SetLength(IFTmpPosStack, 1);

 Tok[NumTok].Line := 0;
 UnitName[1].Name := '';

 MainPath := ExtractFilePath(ParamStr(0));

 SetLength(UnitPath, 2);

 MainPath := IncludeTrailingPathDelimiter( MainPath );
 UnitPath[0] := IncludeTrailingPathDelimiter( MainPath + 'lib' );

 if (ParamCount = 0) then Syntax(3);

 NumUnits:=1;			     // !!! 1 !!!

 ParseParam;

 Defines[1].Name := target.name;

 if (UnitName[1].Name='') then Syntax(3);

 if pos(MainPath, ExtractFilePath(UnitName[1].name)) > 0 then
  FilePath := ExtractFilePath(UnitName[1].Name)
 else
  FilePath := MainPath + ExtractFilePath(UnitName[1].Name);

 DefaultFormatSettings.DecimalSeparator := '.';

 SetLength(linkObj, 1);
 SetLength(resArray, 1);
 SetLength(msgUser, 1);
 SetLength(msgWarning, 1);
 SetLength(msgNote, 1);


 {$IFDEF USEOPTFILE}

 AssignFile(OptFile, ChangeFileExt(UnitName[1].Name, '.opt') ); rewrite(OptFile);

 {$ENDIF}


 if ExtractFileName(outputFile) <> '' then
  AssignFile(OutFile, outputFile)
 else
  AssignFile(OutFile, ChangeFileExt(UnitName[1].Name, '.a65') );

 rewrite(OutFile);

 TextColor(WHITE);

 Writeln('Compiling ', UnitName[1].Name);

 start_time:=GetTickCount64;

// Set defines for first pass
// NumDefines := AddDefines; IfdefLevel := 0;
// Defines[1] := 'ATARI';

 TokenizeProgram;				// AsmBlockIndex = 0


 if NumTok=0 then Error(1, '');

 inc(NumUnits);
 UnitName[NumUnits].Name := 'SYSTEM';		// default UNIT 'system.pas'
 UnitName[NumUnits].Path := FindFile('system.pas', 'unit');


 fillchar(Ident, sizeof(Ident), 0);
 fillchar(DataSegment, sizeof(DataSegment), 0);
 fillchar(StaticStringData, sizeof(StaticStringData), 0);

 PublicSection := true;
 UnitNameIndex := 1;

 SetLength(linkObj, 1);
 SetLength(resArray, 1);
 SetLength(msgUser, 1);
 SetLength(msgWarning, 1);
 SetLength(msgNote, 1);

 BlockStackTop := 0; CodeSize := 0; CodePosStackTop := 0;
 VarDataSize := 0; NumStaticStrChars := 0;
 NumBlocks := 0; NumTypes := 0;
 CaseCnt :=0; IfCnt := 0; ShrShlCnt:=0; run_func := 0;
 NumTok := 0; NumIdent := 0; NumProc:=0;
 NumDefines := AddDefines; IfdefLevel := 0;
 //Defines[1] := 'ATARI';
 AsmBlockIndex := 0;
 ResetOpty;
 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 for i := 0 to High(AsmBlock) do AsmBlock[i]:='';

 TokenizeProgram(false);


 NumStaticStrCharsTmp :=  NumStaticStrChars;

// Predefined constants
 DefineIdent(1, 'BLOCKREAD',      FUNC, INTEGERTOK, 0, 0, $00000000);
 DefineIdent(1, 'BLOCKWRITE',     FUNC, INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'GETRESOURCEHANDLE', FUNC, INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'NIL',      CONSTANT, POINTERTOK, 0, 0, CODEORIGIN);

 DefineIdent(1, 'EOL',      CONSTANT, CHARTOK, 0, 0, target.eol);

 DefineIdent(1, 'TRUE',     CONSTANT, BOOLEANTOK, 0, 0, $00000001);
 DefineIdent(1, 'FALSE',    CONSTANT, BOOLEANTOK, 0, 0, $00000000);

 DefineIdent(1, 'MAXINT',       CONSTANT, INTEGERTOK, 0, 0, MAXINT);
 DefineIdent(1, 'MAXSMALLINT',       CONSTANT, INTEGERTOK, 0, 0, MAXSMALLINT);

 DefineIdent(1, 'PI',       CONSTANT, REALTOK, 0, 0, $40490FDB00000324);
 DefineIdent(1, 'NAN',      CONSTANT, SINGLETOK, 0, 0, $FFC00000FFC00000);
 DefineIdent(1, 'INFINITY', CONSTANT, SINGLETOK, 0, 0, $7F8000007F800000);
 DefineIdent(1, 'NEGINFINITY', CONSTANT, SINGLETOK, 0, 0, $FF800000FF800000);


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
 CaseCnt :=0; IfCnt := 0; ShrShlCnt:=0; NumTypes := 0; run_func := 0; NumProc:=0;
 ResetOpty;
 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 PROGRAMTOK_USE := false;
 INTERFACETOK_USE := false;
 PublicSection := true;

 for i := 1 to MAXUNITS do UnitName[i].Units := 0;

 iOut:=0;
 outTmp:='';

 SetLength(OptimizeBuf, 1);

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

 TextColor(WHITE);

 Writeln(Tok[NumTok].Line, ' lines compiled, ', ((GetTickCount64 - start_time + 500)/1000):2:2,' sec, ',
	 NumTok, ' tokens, ',NumIdent, ' idents, ',  NumBlocks, ' blocks, ', NumTypes, ' types');

 FreeTokens;

 TextColor(LIGHTGRAY);

 if High(msgWarning) > 0 then Writeln(High(msgWarning), ' warning(s) issued');
 if High(msgNote) > 0 then Writeln(High(msgNote), ' note(s) issued');

 NormVideo;

end.
