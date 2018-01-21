
// Poetic License:
//
// This work 'as-is' we provide.
// No warranty express or implied.
// We've done our best,
// to debug and test.
// Liability for damages denied.
//
// Permission is granted hereby,
// to copy, share, and modify.
// Use as is fit,
// free or for profit.
// These rights, on this notice, rely.


(*

Sub-Pascal 32-bit real mode compiler for 80386+ processors v. 2.0 by Vasiliy Tereshkov, 2009
Mad-Pascal cross compiler for 6502 (Atari XE/XL) by Tomasz Biela, 2015-2017

# rejestr X uzywany jest do przekazywania parametrow przez programowy stos STACKORIGIN

# stos programowy sluzy tez do tymczasowego przechowywania wyrazen, wynikow operacji itp.

# Real Fixed-Point Q16.16 przekracza 32 bity dla MUL i DIV, czêsty OVERFLOW

# uzywaj asm65('') zamiast #13#10, POS bedzie wlasciwie zwracalo indeksy

# wystepuja tylko skoki w przod @+ (@- nie istnieje)

# edx+2, edx+3 nie wystepuje

# BP  tylko przy adresowaniu bajtu

# BP2 przy adresowaniu wiecej niz 1 bajtu (WORD, CARDINAL itd.)

# indeks dla jednowymiarowej tablicy [0..x] = a * DataSize[AllocElementType]

# indeks dla dwuwymiarowej tablicy [0..x, 0..y] = a * ((y+1) * DataSize[AllocElementType]) + b * DataSize[AllocElementType]

# optymalizator usuwa odwolania do STACKORIGIN+STACKWIDTH*2+9 gdy operacja ADC, SBC konczy sie na takim odwolaniu


21.01.2018
- dodane porownania __cmpCHAR2STRING, __cmpSTRING2CHAR

14.01.2018
- poprawiona optymalizacja optyFOR (@FORTMP_)

11.12.2017
- poprawiona optymalilzacja addAX_CX, koniecznie musi wypelnic wszystkie bajty wartosciami, redukcji dokona dalsza optymalizacja

23.11.2017
- wprowadzony typ STRINGPOINTERTOK ktory wskazuje na STRING
- mozliwy odczyt typu ENUM, np. DMACTL.NORMAL

18/19.11.2017
- poprawionu blad optymalizacji shrAX_CL.WORD (8)
- CODE_Atari zastapione przez CODEORIGIN_Atari, teraz dziala prawidlowo zmiana adresu programu CODEORIGIN
- DataOriginAddress zastapione przez DATAORIGINOFFSET, CODEORIGINOFFSET
- dodany komunikat ostrzezenia 'UnreachableCode' gdy np.'if byte = -1' (powinno byc 'if byte = byte(-1)' )

14.11.2017
- dodana obs³uga wskaznika do tablicy w rekordzie

11.11.2017
- pêtla FOR do prawid³owego dzia³ania wymaga zmiennej/sta³ej @FORTMP_

02/03.11.2017
- optymalizacja dla IMULBYTE (gdy *0, *1)
- poprawiona optymalizacja dla 'Nx ASL'

27.10.2017
- dodana mozliwosc ustalenia adresu dla ABSOLUTE poprzez inna zmienna (VAR), np.: 'tmp: byte absolute x'

29/30.09.2017
- SIZEOF dla typy RECORD
- poprawione negBYTE, negWORD, !!! koniecznie typ musi byc rozszerzony to 32 bit !!!
- rezygnacja z 'SafeCompileConstExpression' w 'CompileTerm' i 'CompileSimpleExpression', wystepowaly bledy przy wyrazeniu typu 'w:=x-1024-10' (pierwszy '-' byl traktowany jak '+')

21/23/24.09.2017
- usuniety powazny blad dla FOR counter(integer), brakowalo 'CLV:SEC' -> cmpINT (base\cpu6502), oraz 'end else begin' w GenerateForToDoCondition
- usuniety blad w CompileArrayIndex, index tablicy typu BYTE musi zostaæ rozszerzony do WORD jesli array [0..0]
- tablica CODE nie jest juz potrzebna
- brakowalo reakcji na brak podania w linii komend nazwy pliku do kompilacji, teraz zostanie wywolane Syntax

21.08.2017
- poprawki dla GetIdent, dodany SearchCurrentUnit
- label: nie wymaga dododatkowego koncz¹cego srednika 'semicolontok'

12.08.2017
- poprawka dla GetIdentProc (+ [CHARTOK]) aby mozliwe bylo 'move(txt[2], pointer(dpeek(88)), 10)'
- dodany nowy znak dla modyfikacji kodowania ciagu znakowego '~', kody ANTIC-a

01.08.2017
- poprawki dla CompileSimpleExpression, CompileExpression, warning gdy 'unsignedordinaltypes < 0' lub 'unsignedordinaltypes >= 0'

28.07.2017
- predefiniowane stale typu SINGLE: NAN, INFINITY, NEGINFINITY
- akceptowane i ignorowane jest formatowanie dla write/writeln (x:8:4)
- ustalony zakres normalizacji dla SINGLE, (exponent < 10) -> 0.0 , (exponent = $ff) -> 0.0

16/17/18.07.2017
- optymalizacje dla 'sta #$00', 'sty #$00', taki 'illegal' wskazuje potencjalna optymalizacje
- optymalizacje OptimizeRelation dla '<= 127', '< 128', '>= 128', '> 127'
- nowy kod dla prezentacji liczby po przecinku @float

01/03/06.07.2017
- dodana mozliwosc inicjowania tablic typu POINTER (SaveToDataSegment, SaveToStaticDataSegment)
- poprawiona i uzupelniona inicjalizacja zmiennych typu wyliczeniowego
- przebudowane typy rzeczywiste, SHORTREAL (Q8.8 fixed-point, 16bit), REAL (Q24.8 fixed-point, 32bit), SINGLE (IEEE754, 32bit)
- nowe nazwy typu danych LONGWORD, DWORD, UINT32 jako odpowiednik typu CARDINAL
- nowa nazwa typu danych LONGINT jako odpowiednik typu INTEGER

17.06.2017
- optymlizacja @trunc, @round
- optymalizacja mulReal, mulSingle usunieta, blad dla 'a := trunc(real(times) * status_step);   //time,status: word  //status_step = 40.0 / 512.0;'

12/14/15.06.2017
- zmniejszanie wskaznika stosu programowego w przypadku wywolania funkcji bez odebrania jej wartosci
- CheckOperator, nowy bardziej szczegolowy komunikat
- lepsza ocena mozliwosci ustalenia adresu stalej/zmiennej, dodany komunikat "Can't take the address of constant expressions"

04.06.2017
- nowe optymalizacje dla OptimizeStack
- nowa wersja procedury Randomize

28.05.2017
- DefineFunction, dodany komunikat bledu 'Reserved word used as identifier'

12/15/21.05.2017
- optymalizacja imulBYTE, operacja *2;*4;*8;*16;*32 zastêpowana jest odpowiednim przesunieciem bitów ASL
- wiecej optymalizacji dla OptimizeAssignment ('ldy #$07\ lda adr.tab,y' -> 'lda adr.tab+$07')
- dodana zunifikowana funkcja CompileArrayIndex zwracaj¹ca adres do tablicy jedno / dwu wymiarowej
- usuniety blad dla optymalizacji CMPINTEGER, dodane CLV:SEC

07.05.2017
- wiecej optymalizacji dla OptimizeRelation
- optymalizacja krotkiego warunku 'cmp #$00, beq|bne, dey'

01.05.2017
- dodana obsluga LENGTHTOK dla CompileConstFactor
- usuniety blad dla optymalizacji 'adc #$00 \ sta #$00'
- optymalizacja dla shlEAX_CL.BYTE (shl 8)
- naprawiony assignment tablic gdy elementem takiej tablicy jest pointer (11700)
- poprawiony OptimizeASM.Rebuild, tworzy oddzielne linie, pozbywa sie znakow EOL

15.04.2017
- poprawione SHL (wymagane 2x ResizeType -> CompileTerm) "x(byte) shl 14"

31.03.2017
-  dodany nowy typ OBJECT, dziala jak RECORD tylko dodatkowo posiada jeszcze metody - procedury, funkcje
   do procedury, funkcji OBJECT przekazywany jest wskaznik obiektu do ktorego naleza
-  obsuga sekcji INITIALIZATION dla Unit-ow

14.03.2017
- optymalizacja dla imulBYTE, imulWORD, imulCARD, mulSHORTINT, mulSMALLINT, mulINTEGER
- CompileAddress akceptuje tablice dwuwymiarowe

05.03.2017
- dodana podstawowa obsluga typu wyliczeniowego 'type day = (pon, wt, sr, czw, pt, sob, nied)'
- dodana obsluga tablic dwuwymiarowych

02.03.2017
- dodana obs³uga dyrektyw warunkowych $IFDEF, $IFNDEF, $ELSE, $ENDIF, $DEFINE, $UNDEF przez DMSC/Chile

24.02.2017
- poprawka dla UNIX/LINUX, reaguje na znak '/', '\' i zamienia na ma³e literki
- w linii komend opcja -o jest nadmiarowa, zawsze domyslnie wlaczona jest optymalizacja

21.02.2017
- poprawki dla $R (resource), mo¿na je umieszczac w dowolnym unicie (alokowane sa w glownym programie),
  dodana informacje ResFullName, pelna nazwa adresu zasobu pobierana z unitu przez GetLocalName (isArray jest niepotrzebne)

20.02.2017
- klauzula USES dostêpna w jest teraz w unitach, rozrozniany jest dostep do unitow z poziomu programu glownego i unitow

16.02.2017
- dodana rejestracja nazwy unitu (UNITTYPE = UNITTOK) przez DefineIdent
- dodana mo¿liwoœæ odwo³ania sie do publicznych zmiennych, procedur/funkcji unitu przez podanie 'unitname.label'

15.02.2017
- 'adr.'+Ident[IdentIndex].Name zastapione przez GetLocalName(IdentIndex, 'adr.')

14.02.2017
- dodana deklaracja funkcji/procedur w blokach interface unitow
- przepisana od nowa procedura GetIdentProc, inne podejscie do decydowania ktora funkcje overload wybrac
- dodana procedura FormalParameterList odczytujaca parametry deklarowanej funkcji/procedury

08.02.2017
- poprawki dotyczace odwolan do zmiennej rekordowej zdefiniowanej w unicie

06.02.2017
- poprawki FRAC, INT (@frac, @int -> cpu6502.asm)

05.02.2017
- poprawki dla CompileExpression (wyjatek dla porownania typow tego samego rozmiaru, ale z roznymi znakami)

05.09.2016
- zmiany dla DefineIdent, isAbsolute (gdy Data<>0 i Kind=Variable oznacza to isAbsolute = true)
- label, goto

21.08.2016
- IFTOK 'j := CompileExpression(i + 1, ExpressionType);'
- nowe funkcje na podstawie zrodel FreePascala
- GetIdentProc rozroznia typ parametrow przekazywanych przez VAR
- dla FUNCTION dodana mozliwosc zwrocenia wyniku poprzez RECORD

14.08.2016
- rozpisanie kodu dla mulREAL, mulSINGLE
- optymalizacja (rozpisanie kodu) dla mulSHORTINT nie dziala NUTS.PAS, mulSMALLINT tez problem z LINES.PAS
- ResizeType, ExpandExpression przepisane na nowo

01/07.08.2016
- {$f} procedura szybkiego mnozenia FAST_MUL (16 x 16 -> 32 bit, 8 x 8 -> 16 bit), zajmuje 2Kb pamiêci na tablice
- BASE6502.ASM -> poprawione mulSINGLE
- SHORTINT, SMALLINT, INTEGER dla MUL nie wymagaja testu znaku, wystarczy ta sama procka mnozenia jak dla typow bez znaku
- poprawiona optymalizacja zapisu rejestru akumulatora (optyA)
- optymalizcja pêtli FOR (fixed repetition - only repeats a fixed number of times)

  for index := StartingLow to EndingHigh do statement;

  wartosc wyrazenia EndingHigh jest teraz przed petla FOR

22/25/27.07.2016
- 'procedure addEAX' skasowana, bledne zalozenia dla typow innych niz 32bit
- rozbudowane RemoveUnusedSTACK, usprawnione OptimizeAssignment (m.in. optymalizacja dla warunków '<>0' i '=0')
- linia 12206

     if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then
      resArray[i].isArray := true
     else
      resArray[i].isArray := false;

17.07.2016
- INTTOREAL zast¹pione przez typowanie do REAL
- usuniety blad 'GenerateProcFuncAsmLabels -> Value' ktory powodowal zwis gdy 'const f = -1.0;'

09.07.2016
- dodane 'Range check error while evaluating constants (-10 must be between 0 and 255)'
- dodane inc(CodeSize) dla WHILETOK, aby dzialaly zagniezdzone petle WHILE
- mozliwy parametr untyped dla VAR 'procedure name (var x)'

05.07.2016
- dla CASETOK, przed ELSE moze byc tez SEMICOLONTOK
- dla array [0..0] nie bêdzie ostrzezen 'Range check error while evaluating constants'

03.07.2016
- optymalizator ASM, array [0..255] of word|cardinal
- dodany inwers znakow gdy po apostrofie wystepuje znak *, np. 'atari'*

30.06.2016
- wyjatek dla 'array [0..0]', bez optymalizacji adr.array_label, tylko przez indeks jak do tablic >256,
  dla tak zadeklarowanej tablicy mozna ustalic nowa wartosc wskaznika tablicy
- dodatkowy warunek [PROCEDURETOK, FUNCTIONTOK] w GetIdentProc, TestIdentProc

27.06.2016
- poprawka dla optymalizatora ASM, resetowanie OPTYBP2 dla bloku ELSE (IFTOK)
- resource {$R} sprawdza czy etykieta odnosi siê do wskaŸnika, przekazuje wtedy adres ADR.LABEL ( resArray[].isArray )

21.04.2016
- dodane poprawki Greblus-a ($IFDEF UNIX} dla FindFile, Initialize

26.04.2016
- ExpandExpression przepisane na nowo

27.04.2016
- dla zmiennych rekordowych poprawnie ustawia adres gdy ABSOLUTE (line 9810...)

04.05.2016
- dla CompileTerm (INTNUMBERTOK, FRACNUMBERTOK) dodany test CompileConstTerm

08.05.2016
- IFTOK 'j := CompileExpression(i + 1, ExpressionType, 0);'
- dodatkowa optymalizacja dla RECORD, nie powtarzamy inicjowania BP2 gdy 'mwa A bp2', 'mwy A bp2'

12.05.2016
- dodatkowy parametr dla zasobów {$R} aby mo¿na by³o bitmapy VBXE od zadanego koloru wczytac

14.05.2016
- dodana do optymilizatora obs³uga procedur xorAX_CX, xorEAX_ECX
- kompilator potrafi wyliczyæ wyra¿enie z udzia³em sta³ych (CONST)
- optymalizacja dla INC/DEC(label, expression), expression jest wyliczane jako sta³a jeœli to mo¿liwe

21.05.2016
- do oœmiu parametrów dla makr realizujacych ³adowanie zasobów (RESOURCE $R+}

30.05.2016
- pooprawki Greblusa dla $i+, $r+ (LowerCase)
- optymalizator asm dla operacji I/O (openfile, readfile, closefile)

05.06.2016
- dodana mozliwosc odczytu adresu stalych 'const tb: array [0..0] of byte = ( lo(word(@tb)) );'
- poprawki dla CompileBlock, przenosi (NumAllocElements * AllocElementType) danych
- optymalizacja asm dla @pull, @push

12.06.2016
- INTR zast¹pione przez GETINTVEC, SETINTVEC
- RESULT dla funkcji moze byc teraz tablica
- optymalizator ASM dla POKE, DPOKE, PEEK, DPEEK, FILLCHAR, MOVE, INTTOREAL
- poprawione Tokenize, nie wymaga bia³ych znaków po 'END.'

*)

program MADPASCAL;

{$APPTYPE CONSOLE}

//{$DEFINE USEOPTFILE}

{$DEFINE OPTIMIZECODE}

{$I+}

uses
  SysUtils;

const

  title = '1.5.3';

  TAB = ^I;            // Char for a TAB
  CR  = ^M;            // Char for a CR
  LF  = ^J;            // Char for a LF

  AllowDirectorySeparators : set of char = ['/','\'];

  AllowWhiteSpaces     : set of char = [' ',TAB,CR,LF];
  AllowQuotes          : set of char = ['''','"'];
  AllowLabelFirstChars : set of char = ['A'..'Z','_'];
  AllowLabelChars      : set of char = ['A'..'Z','0'..'9','_','.'];
  AllowDigitFirstChars : set of char = ['0'..'9','%','$'];
  AllowDigitChars      : set of char = ['0'..'9','A'..'F'];


  // Token codes

  UNTYPETOK             = 0;

  CONSTTOK              = 1;     // !!! nie zmieniac
  TYPETOK               = 2;     // !!!
  VARTOK                = 3;     // !!!
  PROCEDURETOK          = 4;     // !!!
  FUNCTIONTOK           = 5;     // !!!
  LABELTOK              = 6;	 // !!!
  UNITTOK               = 7;	 // !!!
  ENUMTOK               = 8;	 // !!!

  GETINTVECTOK          = 10;
  SETINTVECTOK          = 11;
  CASETOK               = 12;
  BEGINTOK              = 13;
  ENDTOK                = 14;
  IFTOK                 = 15;
  THENTOK               = 16;
  ELSETOK               = 17;
  WHILETOK              = 18;
  DOTOK                 = 19;
  REPEATTOK             = 20;
  UNTILTOK              = 21;
  FORTOK                = 22;
  TOTOK                 = 23;
  DOWNTOTOK             = 24;
  ASSIGNTOK             = 25;
  WRITETOK              = 26;
  READLNTOK             = 27;
  HALTTOK               = 28;
  USESTOK               = 29;
  ARRAYTOK              = 30;
  OFTOK                 = 31;
  STRINGTOK             = 32;
  INCTOK                = 33;
  DECTOK                = 34;
  ORDTOK                = 35;
  CHRTOK                = 36;
  ASMTOK                = 37;
  ABSOLUTETOK           = 38;
  BREAKTOK              = 39;
  CONTINUETOK           = 40;
  EXITTOK               = 41;
  RANGETOK              = 42;

  EQTOK                 = 43;
  NETOK                 = 44;
  LTTOK                 = 45;
  LETOK                 = 46;
  GTTOK                 = 47;
  GETOK                 = 48;
  LOTOK                 = 49;
  HITOK                 = 50;

  DOTTOK                = 51;
  COMMATOK              = 52;
  SEMICOLONTOK          = 53;
  OPARTOK               = 54;
  CPARTOK               = 55;
  DEREFERENCETOK        = 56;
  ADDRESSTOK            = 57;
  OBRACKETTOK           = 58;
  CBRACKETTOK           = 59;
  COLONTOK              = 60;

  PLUSTOK               = 61;
  MINUSTOK              = 62;
  MULTOK                = 63;
  DIVTOK                = 64;
  IDIVTOK               = 65;
  MODTOK                = 66;
  SHLTOK                = 67;
  SHRTOK                = 68;
  ORTOK                 = 69;
  XORTOK                = 70;
  ANDTOK                = 71;
  NOTTOK                = 72;

  ASSIGNFILETOK         = 73;
  RESETTOK              = 74;
  REWRITETOK            = 75;
  APPENDTOK             = 76;
  BLOCKREADTOK          = 77;
  BLOCKWRITETOK         = 78;
  CLOSEFILETOK          = 79;

  WRITELNTOK            = 80;
  SIZEOFTOK             = 81;
  LENGTHTOK             = 82;
  HIGHTOK               = 83;
  LOWTOK                = 84;
  INTTOK                = 85;
  FRACTOK               = 86;
  TRUNCTOK              = 87;
  ROUNDTOK              = 88;
  ODDTOK                = 89;

  PROGRAMTOK            = 90;
  INTERFACETOK          = 91;
  IMPLEMENTATIONTOK     = 92;
  INITIALIZATIONTOK     = 93;
  OVERLOADTOK           = 94;
  ASSEMBLERTOK          = 95;
  FORWARDTOK            = 96;
  REGISTERTOK           = 97;
  INTERRUPTTOK          = 98;

  SUCCTOK               = 100;
  PREDTOK               = 101;
  PACKEDTOK             = 102;
  GOTOTOK               = 104;

  SETTOK                = 127;     // Size = 32 SET OF

  BYTETOK               = 128;     // Size = 1  BYTE
  WORDTOK		= 129;     // Size = 2  WORD
  CARDINALTOK           = 130;     // Size = 4  CARDINAL
  SHORTINTTOK           = 131;     // Size = 1  SHORTINT
  SMALLINTTOK		= 132;     // Size = 2  SMALLINT
  INTEGERTOK            = 133;     // Size = 4  INTEGER
  CHARTOK               = 134;     // Size = 1  CHAR
  BOOLEANTOK            = 135;     // Size = 1  BOOLEAN
  POINTERTOK            = 136;     // Size = 2  POINTER
  STRINGPOINTERTOK	= 137;	   // Size = 2  POINTER to STRING
  FILETOK               = 138;     // Size = 2/12 FILE
  RECORDTOK             = 139;     // Size = 2/???
  OBJECTTOK		= 140;     // Size = 2/???
  SHORTREALTOK		= 141;     // Size = 2	SHORTREAL	Fixed-Point Q8.8
  REALTOK               = 142;     // Size = 4  REAL		Fixed-Point Q24.8
  SINGLETOK             = 143;     // Size = 4  SINGLE/FLOAT	IEEE-754

  FLOATTOK		= 144;	   // zamieniamy na SINGLETOK

  DATAORIGINOFFSET	= 150;
  CODEORIGINOFFSET	= 151;

  IDENTTOK              = 180;
  INTNUMBERTOK          = 181;
  FRACNUMBERTOK         = 182;
  CHARLITERALTOK        = 183;
  STRINGLITERALTOK      = 184;
  UNKNOWNIDENTTOK	= 185;

  UNITBEGINTOK          = 195;
  UNITENDTOK            = 196;
  IOCHECKON             = 197;
  IOCHECKOFF            = 198;
  EOFTOK                = 199;     // MAXTOKENNAMES = 200

  UnsignedOrdinalTypes  = [BYTETOK, WORDTOK, CARDINALTOK];
  SignedOrdinalTypes    = [SHORTINTTOK, SMALLINTTOK, INTEGERTOK];
  RealTypes             = [SHORTREALTOK, REALTOK, SINGLETOK];

  IntegerTypes          = UnsignedOrdinalTypes + SignedOrdinalTypes;
  OrdinalTypes          = IntegerTypes + [CHARTOK, BOOLEANTOK];

  Pointers		= [POINTERTOK, STRINGPOINTERTOK];

  AllTypes              = OrdinalTypes + RealTypes + Pointers;

  StringTypes           = [STRINGLITERALTOK, STRINGTOK];

  // Identifier kind codes

  CONSTANT              = 1;
  USERTYPE              = 2;
  VARIABLE              = 3;
  PROC                  = 4;
  FUNC                  = 5;
  LABELTYPE             = 6;
  UNITTYPE              = 7;
  ENUMTYPE              = 8;

  // Compiler parameters

  MAXNAMELENGTH         = 32;
  MAXTOKENNAMES         = 200;
  MAXSTRLENGTH          = 255;
  MAXFIELDS             = 256;
  MAXTYPES              = 1024;
  MAXTOKENS             = 32768;
  MAXIDENTS             = 16384;
  MAXBLOCKS             = 16384;	// maksymalna liczba blokow
  MAXPARAMS             = 8;		// maksymalna liczba parametrow dla PROC, FUNC
  MAXVARS               = 256;		// maksymalna liczba parametrów dla VAR
  MAXUNITS              = 128;
  MAXDEFINES            = 256;		// maksymalna liczba $DEFINE
  MAXIFDEFNEST          = 128;		// maksymalna liczba zagniezdzonych IFDEF
  MAXALLOWEDUNITS       = 16;

  CODEORIGIN            = $100;
  DATAORIGIN            = $8000;

  CALLDETERMPASS        = 1;
  CODEGENERATIONPASS    = 2;

  EOL                   = $9b;      // XE/XL End Of Line

  // Indirection levels

  ASVALUE                = 0;
  ASPOINTER              = 1;
  ASPOINTERTOPOINTER     = 2;
  ASPOINTERTOARRAYORIGIN = 3;
  ASPOINTERTOARRAYORIGIN2= 4;
  ASPOINTERTORECORD	 = 5;

  ASCHAR                 = 6;       // GenerateWriteString
  ASBOOLEAN              = 7;
  ASREAL                 = 8;
  ASSHORTREAL		 = 9;
  ASSINGLE		 = 10;
  ASPCHAR		 = 11;

  // Fixed-point 32-bit real number storage

  FRACBITS              = 8;        // Float Fixed Point
  TWOPOWERFRACBITS      = 256;

  // Parameter passing

  VALPASSING            = 1;
  CONSTPASSING          = 2;
  VARPASSING            = 3;


  // Data sizes

  DataSize: array [BYTETOK..SINGLETOK] of Byte = (1,2,4,1,2,4,1,1,2,2,2,2,2,2,4,4);

  fBlockRead_ParamType : array [1..3] of byte = (POINTERTOK, SMALLINTTOK, POINTERTOK);

type

  ModifierCode = (mOverload= $80, mInterrupt = $40, mRegister = $20, mAssembler = $10, mForward = $08);

  irCode = (iDLI, iVBL);

  ioCode = (ioOpenRead = 4, ioRead = 7, ioOpenWrite = 8, ioOpenAppend = 9, ioWrite = $0b, ioClose = $0c);

  ErrorCode =
  (
  UnknownIdentifier, OParExpected, IdentifierExpected, IncompatibleTypeOf,
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
    Value: Int64;                       // Value for a constant, address for a variable, procedure or function
    Block: Integer;                     // Index of a block in which the identifier is defined
    UnitIndex : Integer;
    DataType: Byte;
    IdType: Byte;
    PassMethod: Byte;
    Pass: Byte;

    NestedFunctionNumAllocElements: cardinal;
    NestedFunctionAllocElementType: Byte;

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
    end;

  TCaseLabelArray = array of TCaseLabel;

var

  PROGRAM_NAME: string = 'Program';

  AsmBlock: array [0..255] of string;

  DataSegment, StaticStringData: array [0..$FFFF] of Word;

  Types: array [1..MAXTYPES] of TType;
  Tok: array [1..MAXTOKENS] of TToken;
  Ident: array [1..MAXIDENTS] of TIdentifier;
  Spelling: array [1..MAXTOKENNAMES] of TString;
  UnitName: array [1..MAXUNITS + MAXUNITS] of TUnit;
  Defines: array [1..MAXDEFINES] of TName;
  CodePosStack, BreakPosStack: array [0..1023] of Word;
  BlockStack: array [0..MAXBLOCKS - 1] of Integer;
  CallGraph: array [1..MAXBLOCKS] of TCallGraphNode;    // For dead code elimination

  i, NumTok, NumIdent, NumTypes, NumPredefIdent, NumStaticStrChars, NumUnits, NumBlocks,
  BlockStackTop, CodeSize, CodePosStackTop, BreakPosStackTop, VarDataSize, Pass,
  NumStaticStrCharsTmp, AsmBlockIndex, IfCnt, CaseCnt, NumDefines, IfdefLevel: Integer;

   CODEORIGIN_Atari: integer = $2000;

   DATA_Atari: integer = -1;
  ZPAGE_Atari: integer = -1;
  STACK_Atari: integer = -1;

  UnitNameIndex: Integer = 1;

  FastMul: Integer = -1;

  CPUMode: Integer = 6502;

  OutFile: TextFile;

  asmLabels: array of integer;

  OptimizeBuf: array of TOptimizeBuf;

  resArray: array of TResource;

  UnitPath, MainPath, FilePath, optyA, optyY, optyBP2: string;
  optyFOR0, optyFOR1, optyFOR2, optyFOR3: string;

  msgWarning, msgNote: array of string;

  optimize : record
              use, assign: Boolean;
              unitIndex, line: integer;
             end;


  PROGRAMTOK_USE, INTERFACETOK_USE: Boolean;
  OutputDisabled, isConst, isError, DiagMode, IOCheck: Boolean;

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
var
  i: Integer;
begin
for i := 1 to NumTok do
  if (Tok[i].Kind = IDENTTOK) and (Tok[i].Name <> nil) then Dispose(Tok[i].Name);
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
    POINTERTOK: Result := 'POINTER';

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

 for i := 0 to High(msgWarning) - 1 do
   writeln(msgWarning[i]);

 for i := 0 to High(msgNote) - 1 do
   writeln(msgNote[i]);

end;


function GetEnumName(IdentIndex: integer): TString;
var IdentTtemp: integer;


  function Search(Num: integer): integer;
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
 WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) + ',' + IntToStr(Tok[ErrTokenIndex].Column) + ')'  + ' Error: ' + Msg);

 FreeTokens;
 Halt(2);

 end;

 isError := true;

end;


procedure Error(ErrTokenIndex: Integer; Msg: string);
begin

 if not isConst then begin

 WritelnMsg;

 if ErrTokenIndex > NumTok then ErrTokenIndex := NumTok;
 WriteLn(UnitName[Tok[ErrTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[ErrTokenIndex].Line) + ',' + IntToStr(Tok[ErrTokenIndex].Column) + ')'  + ' Error: ' + Msg);

 FreeTokens;
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


procedure Note(NoteTokenIndex: Integer; IdentIndex: Integer); overload;
var i: integer;
    a: string;
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

    i:=High(msgNote);
    msgNote[i] := a;

    SetLength(msgNote, i+2);

   end;

  end;

end;


procedure Note(NoteTokenIndex: Integer; Msg: string); overload;
var i: integer;
    a: string;
begin

 if Pass = CODEGENERATIONPASS then begin

   a := UnitName[Tok[NoteTokenIndex].UnitIndex].Path + ' (' + IntToStr(Tok[NoteTokenIndex].Line) + ')' + ' Note: ';

   a := a + Msg;

   i:=High(msgNote);
   msgNote[i] := a;

   SetLength(msgNote, i+2);

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

          exit;
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

          exit;
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


function GetIdentProc(S: TString; Param: TParamList; NumParams: integer): integer;
var IdentIndex, BlockStackIndex, i, k: Integer;
    cnt: byte;
    hits, m: word;
    best: array of record
                    IdentIndex : integer;
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

      for i := 1 to NumParams do
       if ( ( ((Ident[IdentIndex].Param[i].DataType in UnsignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and
          (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

          ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in SignedOrdinalTypes) ) and
          (DataSize[Ident[IdentIndex].Param[i].DataType] >= DataSize[Param[i].DataType]) ) or

          ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and		// smallint > byte
          (DataSize[Ident[IdentIndex].Param[i].DataType] > DataSize[Param[i].DataType]) ) or

	  (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) ) or

	  ( (Param[i].DataType in Pointers) and (Ident[IdentIndex].Param[i].DataType = Param[i].AllocElementType) ) or			// dla parametru VAR

	  ( (Ident[IdentIndex].Param[i].DataType = UNTYPETOK) and (Ident[IdentIndex].Param[i].PassMethod = VARPASSING) and (Param[i].DataType in IntegerTypes + [CHARTOK]) )

         then begin
           hits := hits or mask[cnt];                  // z grubsza spelnia warunek
           inc(cnt);

           if Ident[IdentIndex].Param[i].DataType = Param[i].DataType then begin   // dodatkowe punkty jesli idealnie spelnia warunek
             hits := hits or mask[cnt];
             inc(cnt);
           end;

         end;

        k:=High(best);

        best[k].IdentIndex := IdentIndex;
        best[k].hit        := hits;

        SetLength(best, k+2);
      end;

  end;// for

 m:=0;

 if High(best) = 1 then
  Result := best[0].IdentIndex
 else
  for i := 0 to High(best) - 1 do
   if best[i].hit > m then begin m := best[i].hit; Result := best[i].IdentIndex end;

 SetLength(best, 0);

end;


procedure TestIdentProc(x: integer; S: TString);
var IdentIndex, BlockStackIndex: Integer;
    k, i,j, m: integer;
    ok: Boolean;
    l: array of record
                  Param: TParamList;
                  NumParams: word;
       end;
begin

i := 0;
j := 0;

SetLength(l, 1);

for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK]) and
       (S = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
    begin

     inc(j);

     for k := 0 to High(l)-1 do
      if Ident[IdentIndex].NumParams = l[k].NumParams then begin

       ok := true;

       for m := 1 to l[k].NumParams do
        if (Ident[IdentIndex].Param[m].DataType <> l[k].Param[m].DataType) then begin ok := false; Break end;

       if ok then
        Error(x, 'Overloaded functions ''' + Ident[IdentIndex].Name + ''' have the same parameter list');

      end;

     l[High(l)].NumParams := Ident[IdentIndex].NumParams;
     l[High(l)].Param := Ident[IdentIndex].Param;

     SetLength(l, High(l)+2);

     if Ident[IdentIndex].isOverload then inc(i);
    end;

  end;// for

if j>1 then
 if i<>j then
  Error(x, 'Not all declarations of '+Ident[NumIdent].Name+' are declared with OVERLOAD');

SetLength(l, 0);
end;


procedure omin_spacje (var i:integer; var a:string);
(*----------------------------------------------------------------------------*)
(*  omijamy tzw. "biale spacje" czyli spacje, tabulatory                      *)
(*----------------------------------------------------------------------------*)
begin

 if a<>'' then
  while (i<=length(a)) and (a[i] in AllowWhiteSpaces) do inc(i);

end;


function get_digit(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobierz ciag zaczynajaca sie znakami '0'..'9','%','$'                     *)
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


function get_label(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_'                     *)
(*----------------------------------------------------------------------------*)
begin
 Result:='';

 if a<>'' then begin

  omin_spacje(i,a);

  if UpCase(a[i]) in AllowLabelFirstChars then
   while UpCase(a[i]) in AllowLabelChars + AllowDirectorySeparators do begin Result:=Result+UpCase(a[i]); inc(i) end;

 end;

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
 if not(a[i] in AllowQuotes) then begin

  Result := get_label(i, a);

 end else begin

  gchr:=a[i]; len:=length(a);

  while i<=len do begin
   inc(i);         // omijamy pierwszy znak ' lub "

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
     res.resFile := get_string(i, s);

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

 Tok[NumTok].Line := Line;
 Tok[NumTok].Column := Column;

end;


function Elements(IdentIndex: integer): cardinal;
begin

 if Ident[IdentIndex].DataType = ENUMTYPE then
  Result := 0
 else

 if Ident[IdentIndex].NumAllocElements_ = 0 then
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
if (i > 0) and (Ident[i].Block = BlockStack[BlockStackTop]) and (Ident[i].isOverload = false) and (Ident[i].UnitIndex = UnitNameIndex) then
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

  NumAllocElements_ := NumAllocElements shr 16;               // , yy]
  NumAllocElements  := NumAllocElements and $FFFF;            // [xx,

  if (NumIdent > NumPredefIdent + 1) and (UnitNameIndex = 1) and (Pass = CODEGENERATIONPASS) then
    if not ( (Ident[NumIdent].Pass in [CALLDETERMPASS , CODEGENERATIONPASS]) or (Ident[NumIdent].IsNotDead) ) then
      Note(ErrTokenIndex, NumIdent);

  case Kind of

    PROC, FUNC, UNITTYPE:
      begin
      Ident[NumIdent].Value := CodeSize;                      // Procedure entry point address
//      Ident[NumIdent].Section := true;
      end;

    VARIABLE:
      begin

      if Ident[NumIdent].isAbsolute then
       Ident[NumIdent].Value := Data - 1
      else
       Ident[NumIdent].Value := DATAORIGIN + VarDataSize;     // Variable address

      if not OutputDisabled then
        VarDataSize := VarDataSize + DataSize[DataType];

      Ident[NumIdent].NumAllocElements := NumAllocElements;   // Number of array elements (0 for single variable)
      Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

      Ident[NumIdent].AllocElementType := AllocElementType;

      if not OutputDisabled then begin

       if (DataType in [RECORDTOK, OBJECTTOK]) and (NumAllocElements > 0) then
        VarDataSize := VarDataSize + 0
       else
       if (DataType = FILETOK) and (NumAllocElements > 0) then
        VarDataSize := VarDataSize + 12
       else
        VarDataSize := VarDataSize + Elements(NumIdent) * DataSize[AllocElementType] ;

       if NumAllocElements > 0 then dec(VarDataSize, DataSize[DataType]);

      end;

      end;

    CONSTANT, ENUMTYPE:
      begin
      Ident[NumIdent].Value := Data;                          // Constant value

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
  i: Integer;
begin

Tok[StrTokenIndex].StrAddress := CODEORIGIN + 3 + NumStaticStrChars;
Tok[StrTokenIndex].StrLength := Length(StrValue);

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
       not (op in [MULTOK, IDIVTOK, MODTOK, SHLTOK, SHRTOK, ANDTOK, PLUSTOK, MINUSTOK, ORTOK, XORTOK, NOTTOK, GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK])) or
   ((DataType = CHARTOK) and
       not (op in [GTTOK, GETOK, EQTOK, NETOK, LETOK, LTTOK])) or
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

     ( (DstType in IntegerTypes) and (SrcType in [CHARTOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK]) ) or
     ( (SrcType in IntegerTypes) and (DstType in [CHARTOK, BOOLEANTOK]) ) then

     if err then
      iError(ErrTokenIndex, IncompatibleTypes, 0, SrcType, DstType)
     else
      Result := true;

end;


function GetCommonType(ErrTokenIndex: Integer; LeftType, RightType: Byte): Byte;
begin

 Result := 0;

 if LeftType = RightType then                 // General rule

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


  function GetARG(n: byte; x: integer; reset: Boolean = true): string;
  var i: integer;
      a: string;
  begin

   Result:='';

   if x < 0 then exit;

   a := s[x][n];

   if (a='') then begin

    case n of
     0: Result := 'STACKORIGIN+'+IntToStr(x+8);
     1: Result := 'STACKORIGIN+STACKWIDTH+'+IntToStr(x+8);
     2: Result := 'STACKORIGIN+STACKWIDTH*2+'+IntToStr(x+8);
     3: Result := 'STACKORIGIN+STACKWIDTH*3+'+IntToStr(x+8);
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

        if (pos('rol @', listing[i-1]) > 0) then begin
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
 // szukamy pojedynczych odwolan do STACKORIGIN+N

  Rebuild;

  Clear;

  SetLength(stackBuf, 1);

  for i := 0 to l - 1 do               // zliczamy odwolania do STACKORIGIN+N
   for j := 0 to 6 do
    for k := 0 to 3 do
     if pos(GetARG(k, j, false), listing[i]) > 0 then inc( cnt[j, k] );


//  for i := 0 to l - 1 do
//   if Num(i) <> 0 then listing[i] := listing[i] + #9'; '+IntToStr( Num(i) );


  for i := 1 to l - 1 do begin

   if (pos('sta STACK', listing[i]) > 0) or (pos('sty STACK', listing[i]) > 0) then begin

    yes:=true;
    for j:=0 to High(stackBuf)-1 do
      if stackBuf[j].name = listing[i] then begin

       Remove(stackBuf[j].line);       // usun dotychczasowe odwolanie

       stackBuf[j].line := i;          // nadpisz nowym

       yes:=false;
       Break;
      end;

    if yes then begin                  // dodaj nowy wpis
     k:=High(stackBuf);
     stackBuf[k].name := listing[i];
     stackBuf[k].line := i;
     SetLength(stackBuf, k+2);
    end;

   end;


   if ((pos('sta STACK', listing[i]) = 0) and (pos('sty STACK', listing[i]) = 0)) and
      ((pos(' STACK', listing[i]) > 0) or (pos(' STACK', listing[i]) > 0)) then
   begin

    for j:=0 to High(stackBuf)-1 do    // odwolania inne niz STA|STY resetuja wpisy
      if copy(stackBuf[j].name, 6, 256) = copy(listing[i], 6, 256) then begin
       stackBuf[j].name := '';         // usun wpis
       Break;
      end;

   end;


  if Num(i) = 1 then
   if (pos('rol @', listing[i-1]) > 0) then

    Remove(i)			// pojedyncze odwolanie do STACKORIGIN+N jest eliminowane

   else begin

    a := listing[i];		// zamieniamy na 'illegal instruction'
    k:=pos(' STACK', a);
    delete(a, k, length(a));
    insert(' #$00', a, k);

    if (pos('ldy #$00', a) > 0) or (pos('lda #$00', a) > 0) then
     listing[i] := ''
    else
     listing[i] := a;

   end;

  end;

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
      (pos(#9'spl', listing[i]) > 0) or (pos(#9'smi', listing[i]) > 0) or
      (pos(#9'seq', listing[i]) > 0) or (pos(#9'sne', listing[i]) > 0) then Break;

   if (pos('mwa ', listing[i]) > 0) and (pos(' bp2', listing[i]) > 0) then
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


    if (pos(#9'dex', listing[i]) > 0) and (pos(#9'inx', listing[i+1]) > 0) then			// dex
     begin											// inx
       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and (pos(#9'dex', listing[i+1]) > 0) then			// inx
     begin											// dex
       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) then		// lda STACKORIGIN+9
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin			// sta STACKORIGIN+9
       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos('mva ', listing[i]) > 0) and (pos(#9'inx', listing[i-1]) > 0) and			// mva A	; -2
       (pos('mva ', listing[i-2]) > 0) then							// inx		; -1
     if listing[i] = listing[i-2] then begin							// mva A	; 0
       listing[i] := #9'sta ' + copy(listing[i], pos('STACK', listing[i]), 256);		// inx		; 1
       if (pos(#9'inx', listing[i+1]) > 0) and (listing[i-2] = listing[i+2]) then		// mva A	; 2
        listing[i+2] := #9'sta ' + copy(listing[i+2], pos('STACK', listing[i+2]), 256);

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva aa STACKORIGIN,x			; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('add STACK', listing[i+4]) > 0) and		// mva bb STACKORIGIN+STACKWIDTH,x	; 2
       (pos(#9'tay', listing[i+5]) > 0) and							// lda					; 3
       (pos('lda ', listing[i+6]) > 0) and (pos('adc STACK', listing[i+7]) > 0) and		// add STACKORIGIN,x			; 4
       (pos('sta bp+1', listing[i+8]) > 0) and							// tay					; 5
       (pos('lda (bp),y', listing[i+9]) > 0) then						// lda					; 6
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// adc STACKORIGIN+STACKWIDTH,x		; 7
        (pos('STACKORIGIN,x', listing[i+4]) > 0) and						// sta bp+1				; 8
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and					// lda (bp),y				; 9
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin
       listing[i+4]  := #9'add ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+7]  := #9'adc ' + copy(listing[i+2], 6, pos('STACK', listing[i+2])-6 );

       listing[i+1] := '';
       listing[i+2] := '';

       if (pos('adc #$00', listing[i+7]) > 0) then
        if copy(listing[i+3], 6, 256)+'+1' = copy(listing[i+6], 6, 256) then begin
	 listing[i+3] := #9'mwa ' + copy(listing[i+3], 6, 256) + ' bp2';
	 listing[i+4] := #9'ldy ' + copy(listing[i+4], 6, 256);
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda (bp2),y';
	end;

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva aa STACKORIGIN,x			; 1
       (pos('sta STACK', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and	// mva bb STACKORIGIN+STACKWIDTH,x	; 2
       (pos('lda STACK', listing[i+5]) > 0) and (pos('lda STACK', listing[i+7]) > 0) and	// sta STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('lda STACK', listing[i+9]) > 0) and (pos('lda STACK', listing[i+11]) > 0) and	// sta STACKORIGIN+STACKWIDTH*3,x	; 4
       (pos('sta ecx', listing[i+6]) > 0) and (pos('sta ecx+1', listing[i+8]) > 0) and		// lda STACKORIGIN,x			; 5
       (pos('sta ecx+2', listing[i+10]) > 0) and (pos('sta ecx+3', listing[i+12]) > 0) then	// sta ecx				; 6
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// lda STACKORIGIN+STACKWIDTH,x		; 7
        (pos('STACKORIGIN,x', listing[i+5]) > 0) and						// sta ecx+1				; 8
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and					// lda STACKORIGIN+STACKWIDTH*2,	; 9
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) and					// sta ecx+2				; 10
        (pos('STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and				// lda STACKORIGIN+STACKWIDTH*3,x	; 11
        (pos('STACKORIGIN+STACKWIDTH*2,x', listing[i+9]) > 0) and				// sta ecx+3				; 12
        (pos('STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*3,x', listing[i+11]) > 0) then
     begin
       listing[i+7]  := listing[i+2];
       listing[i+8]  := listing[i+3];
       listing[i+9]  := listing[i+4];
       listing[i+10] := #9'sta ecx+1';
       listing[i+11] := #9'sta ecx+2';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// mva xx STACKORIGIN,x			; 1
       (pos('ldy STACK', listing[i+3]) > 0) and							// sta STACKORIGIN+STACKWIDTH,x		; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) > 0) then		// ldy STACKORIGIN,x			; 3
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y STACKORIGIN,x		; 4
        (pos('STACKORIGIN,x', listing[i+3]) > 0) and						// mva adr.__,y STACKORIGIN+STACKWIDTH,x; 5
        (pos('STACKORIGIN,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva xx STACKORIGIN,x			; 1
       (pos('ldy STACK', listing[i+3]) > 0) and							// mva yy STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) > 0) then		// ldy STACKORIGIN,x			; 3
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y STACKORIGIN,x		; 4
        (pos('STACKORIGIN,x', listing[i+3]) > 0) and						// mva adr.__,y STACKORIGIN+STACKWIDTH,x; 5
        (pos('STACKORIGIN,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and 							// mva xx STACKORIGIN,x			; 1
       (pos('ldy STACK', listing[i+2]) > 0) and							// ldy STACKORIGIN,x			; 2
       (pos('mva adr.', listing[i+3]) > 0) and (pos('mva adr.', listing[i+4]) = 0) then		// mva adr.__,y STACKORIGIN,x		; 3
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
        (pos('STACKORIGIN,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN,x', listing[i+3]) > 0) then
     begin
       listing[i+2] := #9'ldy ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and			// mva xx STACKORIGIN,x			; 1
       (pos('ldy STACK', listing[i+3]) > 0) and							// sta STACKORIGIN+STACKWIDTH,x		; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) = 0) then		// ldy STACKORIGIN,x			; 3
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y STACKORIGIN,x		; 4
        (pos('STACKORIGIN,x', listing[i+3]) > 0) and
        (pos('STACKORIGIN,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva xx STACKORIGIN,x			; 1
       (pos('ldy STACK', listing[i+3]) > 0) and							// mva yy STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva adr.', listing[i+4]) > 0) and (pos('mva adr.', listing[i+5]) = 0) then		// ldy STACKORIGIN,x			; 3
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// mva adr.__,y STACKORIGIN,x		; 4
        (pos('STACKORIGIN,x', listing[i+3]) > 0) and
        (pos('STACKORIGIN,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := #9'ldy ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and			// mva xx STACKORIGIN,x			; 1
       (pos('mva ', listing[i+3]) > 0) and (pos('mva ', listing[i+4]) > 0) and			// mva yy STACKORIGIN+STACKWIDTH,x	; 2
       (pos('ldy STACK', listing[i+5]) > 0) and							// mva zz STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('mva adr.', listing[i+6]) > 0) and (pos('mva adr.', listing[i+7]) = 0) then		// mva qq STACKORIGIN+STACKWIDTH*3,x	; 4
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and						// ldy STACKORIGIN,x			; 5
     	(pos('STACKORIGIN,x', listing[i+5]) > 0) and						// mva adr.__,y STACKORIGIN,x		; 6
        (pos('STACKORIGIN,x', listing[i+6]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 );
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # STACKORIGIN,x			; 1
       (pos(#9'inx', listing[i+2]) > 0) and							// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # STACKORIGIN,x			; 3
       (pos(#9'jsr subAL_CL', listing[i+4]) > 0) then						// jsr subAL_CL				; 4
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos('STACKORIGIN,x', listing[i+3]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4));
       q := GetVAL(copy(listing[i+3], 6, 4));

       p:=p - q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' STACKORIGIN,x';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := #9'inx';

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # STACKORIGIN,x			; 1
       (pos(#9'inx', listing[i+2]) > 0) and							// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # STACKORIGIN,x			; 3
       (pos(#9'jsr addAL_CL', listing[i+4]) > 0) then						// jsr addAL_CL				; 4
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos('STACKORIGIN,x', listing[i+3]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4));
       q := GetVAL(copy(listing[i+3], 6, 4));

       p:=p + q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' STACKORIGIN,x';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := #9'inx';

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # STACKORIGIN,x			; 1
       (pos(#9'inx', listing[i+2]) > 0) and							// inx					; 2
       (pos('mva #', listing[i+3]) > 0) and							// mva # STACKORIGIN,x			; 3
       (pos('mva #', listing[i+4]) > 0) and							// mva # STACKORIGIN-1+STACKWIDTH,x	; 4
       (pos('mva #', listing[i+5]) > 0) and 							// mva # STACKORIGIN+STACKWIDTH,x	; 5
       (pos(#9'jsr subAX_CX', listing[i+6]) > 0) then						// jsr subAX_CX				; 6
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos('STACKORIGIN,x', listing[i+3]) > 0) and
        (pos('STACKORIGIN-1+STACKWIDTH,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) + GetVAL(copy(listing[i+4], 6, 4)) shl 8;
       q := GetVAL(copy(listing[i+3], 6, 4)) + GetVAL(copy(listing[i+5], 6, 4)) shl 8;

       p:=p - q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # STACKORIGIN,x			; 1
       (pos('mva #', listing[i+2]) > 0) and							// mva # STACKORIGIN+STACKWIDTH,x	; 2
       (pos(#9'inx', listing[i+3]) > 0) and							// inx					; 3
       (pos('mva #', listing[i+4]) > 0) and							// mva # STACKORIGIN,x			; 4
       (pos('mva #', listing[i+5]) > 0) and 							// mva # STACKORIGIN+STACKWIDTH,x	; 5
       (pos(#9'jsr subAX_CX', listing[i+6]) > 0) then						// jsr subAX_CX				; 6
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos('STACKORIGIN,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) + GetVAL(copy(listing[i+2], 6, 4)) shl 8;
       q := GetVAL(copy(listing[i+4], 6, 4)) + GetVAL(copy(listing[i+5], 6, 4)) shl 8;

       p:=p - q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva #', listing[i+1]) > 0) and							// mva # STACKORIGIN,x			; 1
       (pos('mva #', listing[i+2]) > 0) and							// mva # STACKORIGIN+STACKWIDTH,x	; 2
       (pos(#9'inx', listing[i+3]) > 0) and							// inx					; 3
       (pos('mva #', listing[i+4]) > 0) and							// mva # STACKORIGIN,x			; 4
       (pos('mva #', listing[i+5]) > 0) and 							// mva # STACKORIGIN+STACKWIDTH,x	; 5
       (pos(#9'jsr addAX_CX', listing[i+6]) > 0) then						// jsr addAX_CX				; 6
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos('STACKORIGIN,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin

       p := GetVAL(copy(listing[i+1], 6, 4)) + GetVAL(copy(listing[i+2], 6, 4)) shl 8;
       q := GetVAL(copy(listing[i+4], 6, 4)) + GetVAL(copy(listing[i+5], 6, 4)) shl 8;

       p:=p + q;

       listing[i+1] := #9'mva #$'+IntToHex(p and $ff, 2) + ' STACKORIGIN,x';
       listing[i+2] := #9'mva #$'+IntToHex(byte(p shr 8), 2) + ' STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       Result:=false;
     end;


    if (pos(#9'inx', listing[i]) > 0) and							// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and							// mva  STACKORIGIN,x			; 1
       (pos('mva ', listing[i+2]) > 0) and							// mva  STACKORIGIN+STACKWIDTH,x	; 2
       (pos('mva ', listing[i+3]) > 0) and							// mva  STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('mva ', listing[i+4]) > 0) and							// mva  STACKORIGIN+STACKWIDTH*3,x	; 4
       (pos(#9'inx', listing[i+5]) > 0) and							// inx					; 5
       (pos('mva ', listing[i+6]) > 0) and							// mva  STACKORIGIN,x			; 6
       (pos('mva ', listing[i+7]) > 0) and 							// mva  STACKORIGIN+STACKWIDTH,x	; 7
       (pos('mva ', listing[i+8]) > 0) and							// mva  STACKORIGIN+STACKWIDTH*2,x	; 8
       (pos('mva ', listing[i+9]) > 0) and 							// mva  STACKORIGIN+STACKWIDTH*3,x	; 9
       ((pos(#9'jsr addEAX_ECX', listing[i+10]) > 0) or						// jsr addEAX_ECX|subEAX_ECX		; 10
       (pos(#9'jsr subEAX_ECX', listing[i+10]) > 0)) then
     if (pos('STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos('STACKORIGIN,x', listing[i+6]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*2,x', listing[i+8]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) and
        (pos('STACKORIGIN+STACKWIDTH*3,x', listing[i+9]) > 0) then
     begin

	if (pos(#9'jsr addEAX_ECX', listing[i+10]) > 0) then
	       tmp := #9'm@addEAX_ECX '
	else
	       tmp := #9'm@subEAX_ECX ';

	listing[i+1] := tmp +
	       		copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 ) +
       			copy(listing[i+6], 6, pos('STACK', listing[i+6])-6 ) +
			copy(listing[i+2], 6, pos('STACK', listing[i+2])-6 ) +
			copy(listing[i+7], 6, pos('STACK', listing[i+7])-6 ) +
        		copy(listing[i+3], 6, pos('STACK', listing[i+3])-6 ) +
        		copy(listing[i+8], 6, pos('STACK', listing[i+8])-6 ) +
			copy(listing[i+4], 6, pos('STACK', listing[i+4])-6 ) +
        		copy(listing[i+9], 6, pos('STACK', listing[i+9])-6 );


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

{
    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and 		// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) and (pos('mva #$', listing[i+3]) > 0) then		// mva #$xx	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and 				// mva #$xx	; 2
	(copy(listing[i+1], 6, 4) = copy(listing[i+2], 6, 4)) and 				// mva #$xx	; 3
	(copy(listing[i+2], 6, 4) = copy(listing[i+3], 6, 4)) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       listing[i+3] := #9'sta' + copy(listing[i+3], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and 		// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) then							// mva #$xx	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and 				// mva #$xx	; 2
	(copy(listing[i+1], 6, 4) = copy(listing[i+2], 6, 4)) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) then		// mva #$xx	; 0
     if copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4) then begin				// mva #$xx	; 1

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos('mva #$', listing[i+1]) > 0) and		// mva #$xx	; 0
       (pos('mva #$', listing[i+2]) > 0) then							// mva #$yy	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4)) and					// mva #$xx	; 2
        (copy(listing[i], 6, 4) <> copy(listing[i+1], 6, 4)) then begin

       tmp := listing[i];

       listing[i]   := listing[i+1];
       listing[i+1] := tmp;
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos(' STACK', listing[i]) > 0) and			// mva #$xx STACKORIGN,x		; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos(#9'inx', listing[i+2]) > 0) and		// sta STACKORIGIN+STACKWIDTH,x		; 1
       (pos('mva #$', listing[i+3]) > 0) and (pos(' STACK', listing[i+3]) > 0) then		// inx					; 2
     if copy(listing[i], 6, 4) = copy(listing[i+3], 6, 4) then					// mva #$xx STACKORIGN,x		; 3
     begin
       listing[i+3] := #9'sta ' + copy(listing[i+3], pos('STACK', listing[i+3]), 256 );
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos(' STACK', listing[i]) > 0) and			// mva #$xx STACKORIGN,x		; 0
       (pos(#9'inx', listing[i+1]) > 0) and							// inx					; 1
       (pos('mva #$', listing[i+2]) > 0) and (pos(' STACK', listing[i+2]) > 0) then		// mva #$xx STACKORIGN,x		; 2
     if copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4) then
     begin
       listing[i+2] := #9'sta ' + copy(listing[i+2], pos('STACK', listing[i+2]), 256 );
       Result:=false;
     end;


    if (pos('mva #$', listing[i]) > 0) and (pos(' STACK', listing[i]) > 0) and			// mva #$xx STACKORIGN			; 0
       (pos('mva #$', listing[i+1]) > 0) and (pos(' STACK', listing[i+1]) > 0) and		// mva #$yy STACKORIGN			; 1
       (pos(#9'inx', listing[i+2]) > 0) and							// inx					; 2
       (pos('mva #$', listing[i+3]) > 0) and (pos(' STACK', listing[i+3]) > 0) then		// mva #$xx STACKORIGN			; 3
     if copy(listing[i], 6, 4) = copy(listing[i+3], 6, 4) then
     begin
       tmp:=listing[i];
       listing[i]   := listing[i+1];
       listing[i+1] := tmp;
       Result:=false;
     end;
}

{	!!! takie optymalizacje na stosie nie dzialaja prawidlowo !!!

    if (pos(#9'inx', listing[i]) > 0) and										// inx					; 0
       (pos('mva ', listing[i+1]) > 0) and (pos('mva ', listing[i+2]) > 0) and						// mva aa STACKORIGN,x			; 1
       (pos('mva ', listing[i+3]) > 0) and (pos('mva ', listing[i+4]) > 0) and						// mva bb STACKORIGN+STACKWIDTH,x	; 2
       (pos('inx', listing[i+5]) > 0) and										// mva cc STACKORIGIN+STACKWIDTH*2,x	; 3
       (pos('mva ', listing[i+6]) > 0) and (pos('mva ', listing[i+7]) > 0) and						// mva dd STACKORIGIN+STACKWIDTH*3,x	; 4
       (pos('mva ', listing[i+8]) > 0) and (pos('mva ', listing[i+9]) > 0) and						// inx					; 5
       (pos('STACKORIGIN,', listing[i+1]) > 6) and (pos('STACKORIGIN+STACKWIDTH,', listing[i+2]) > 6) and		// mva aa STACKORIGN,x			; 6
       (pos('STACKORIGIN+STACKWIDTH*2,', listing[i+3]) > 6) and (pos('STACKORIGIN+STACKWIDTH*3,', listing[i+4]) > 6) and// mva bb STACKORIGN+STACKWIDTH,x	; 7
       (pos('STACKORIGIN', listing[i+6]) > 6) and (pos('STACKORIGIN+STACKWIDTH,', listing[i+7]) > 6) and		// mva cc STACKORIGIN+STACKWIDTH*2,x	; 8
       (pos('STACKORIGIN+STACKWIDTH*2,', listing[i+8]) > 6) and (pos('STACKORIGIN+STACKWIDTH*3,', listing[i+9]) > 6) and// mva dd STACKORIGIN+STACKWIDTH*3,x	; 9
       (pos('jsr mulREAL', listing[i+10]) > 0) then									// jsr mulREAL				; 10
     begin
       listing[i+1] := #9'mva ' + copy(listing[i+1], 6, pos('STACK', listing[i+1])-6 ) + ':eax';
       listing[i+2] := #9'mva ' + copy(listing[i+2], 6, pos('STACK', listing[i+2])-6 ) + ':eax+1';
       listing[i+3] := #9'mva ' + copy(listing[i+3], 6, pos('STACK', listing[i+3])-6 ) + ':eax+2';
       listing[i+4] := #9'mva ' + copy(listing[i+4], 6, pos('STACK', listing[i+4])-6 ) + ':eax+3';

       listing[i+6] := #9'mva ' + copy(listing[i+6], 6, pos('STACK', listing[i+6])-6 ) + 'mulREAL.ecx0';
       listing[i+7] := #9'mva ' + copy(listing[i+7], 6, pos('STACK', listing[i+7])-6 ) + 'mulREAL.ecx1';
       listing[i+8] := #9'mva ' + copy(listing[i+8], 6, pos('STACK', listing[i+8])-6 ) + 'mulREAL.ecx2';
       listing[i+9] := #9'mva ' + copy(listing[i+9], 6, pos('STACK', listing[i+9])-6 ) + 'mulREAL.ecx3';

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

   for i := 0 to l - 1 do begin

    p:=i;

    old := listing[p];

    while (pos('lda #', old) > 0) and (pos('sta ', listing[p+1]) > 0) and (pos('lda #', listing[p+2]) > 0) and (p<l-2) do begin	// lda #

     if (copy(old, 6, 256) = copy(listing[p+2], 6, 256)) then
      listing[p+2] := ''                                               // sta
     else
      old:=listing[p+2];

     inc(p, 2);                                                        // lda #
    end;

   end;


   end;



   function PeepholeOptimization_STA: Boolean;
   var i, p: integer;
       tmp: string;
       yes: Boolean;
   begin

   Result:=true;

   Rebuild;

   for i := 0 to l - 1 do begin

     if (pos('add STACK', listing[i]) > 0) or (pos('adc STACK', listing[i]) > 0) or	// add|sub|adc|sbc STACK
	(pos('sub STACK', listing[i]) > 0) or (pos('sbc STACK', listing[i]) > 0) then
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
	  if (pos('ldy ', listing[p]) > 0) or (pos(#9'.if', listing[p]) > 0) or
	     (pos(#9'iny', listing[p]) > 0) or (pos(#9'dey', listing[p]) > 0) or
	     (pos(#9'tya', listing[p]) > 0) or (pos(#9'tay', listing[p]) > 0) then Break;

      end;


     if (pos('lda STACK', listing[i]) > 0) and ( (pos('adc ', listing[i+1]) > 0) or (pos('add ', listing[i+1]) > 0) ) then	// lda STACK
      begin															// add|adc

        tmp:=copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (pos('sta ', listing[p]) > 0) and (pos('lda ', listing[p-1]) > 0) and (pos('sta ', listing[p+1]) = 0) then begin

	   listing[i] := #9'lda ' + copy(listing[p-1], 6, 256);

	   listing[p-1] := '';
	   listing[p] := '';

	   Result:=false;
	   Break;
	  end else
	   Break;

	 end else
	  if (listing[p] = '@') or
	     (pos('ldy ', listing[p]) > 0) or (pos(#9'.if', listing[p]) > 0) or
	     (pos(#9'iny', listing[p]) > 0) or (pos(#9'dey', listing[p]) > 0) or
	     (pos(#9'tya', listing[p]) > 0) or (pos(#9'tay', listing[p]) > 0) then Break;

      end;


     if Result and									// lda STACK
	(pos('lda STACK', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and	// sta
	(pos('sta ', listing[i+2]) = 0)  then						// ~sta
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
	 if not ( (pos('lda ', listing[p]) > 0) or (pos('sta ', listing[p]) > 0) or
	    (pos(#9'iny', listing[p]) > 0) or (pos(#9'dey', listing[p]) > 0) or
	    (pos(#9'tya', listing[p]) > 0) or (pos(#9'tay', listing[p]) > 0) or
	    (pos('adc ', listing[p]) > 0) or (pos('sbc ', listing[p]) > 0) or
	    (pos('ora ', listing[p]) > 0) or (pos('and ', listing[p]) > 0) or (pos('eor ', listing[p]) > 0) ) then Break;

       end;



     if (pos('lda ', listing[i]) > 0) and 		// lda				; 0
        (pos('add STACK', listing[i+1]) > 0) and 	// add STACKORIGIN+9		; 1
        (pos(#9'tay', listing[i+2]) > 0) and		// tay				; 2
        (pos('lda ', listing[i+3]) > 0) and		// lda				; 3
        (pos('adc STACK', listing[i+4]) > 0) and 	// adc STACKORIGIN+STACKWIDTH+9	; 4
        (pos('sta bp+1', listing[i+5]) > 0) then 	// sta bp+1			; 5
      begin

        tmp:=#9'sta ' + copy(listing[i+1], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (pos('lda ', listing[p-2]) > 0) and
	     ( (pos('add ', listing[p-1]) > 0) or (pos('sub ', listing[p-1]) > 0) ) and
	     (pos('sta STACK', listing[p]) > 0) and
	     (pos('lda ', listing[p+1]) > 0) and
	     ( (pos('adc ', listing[p+2]) > 0) or (pos('sbc ', listing[p+2]) > 0) ) and
	     (pos('sta STACK', listing[p+3]) > 0) and
	     (pos('lda ', listing[p+4]) > 0) and
	     ( (pos('adc ', listing[p+5]) > 0) or (pos('sbc ', listing[p+5]) > 0) ) and
	     (pos('sta STACK', listing[p+6]) > 0) and
	     (pos('lda ', listing[p+7]) > 0) and
	     ( (pos('adc ', listing[p+8]) > 0) or (pos('sbc ', listing[p+8]) > 0) ) and
	     (pos('sta STACK', listing[p+9]) > 0) then begin

{
	lda STACKORIGIN+9		; p-2
	add #$80			; p-1
	sta STACKORIGIN+9		; p
	lda STACKORIGIN+STACKWIDTH+9	; p+1
	adc #$03			; p+2
	sta STACKORIGIN+STACKWIDTH+9	; p+3
	lda STACKORIGIN+STACKWIDTH*2+9	; p+4
	adc #$00			; p+5
	sta STACKORIGIN+STACKWIDTH*2+9	; p+6
	lda STACKORIGIN+STACKWIDTH*3+9	; p+7
	adc #$00			; p+8
	sta STACKORIGIN+STACKWIDTH*3+9	; p+9
}
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
	  if (listing[p] = '@') or (pos(#9'.if', listing[p]) > 0) then Break;

      end;


// -----------------------------------------------------------------------------
// ===				IMUL.					  === //
// -----------------------------------------------------------------------------

    if (pos('lda #$00', listing[i]) > 0) and (pos('sta eax+2', listing[i+1]) > 0) and
       (pos('lda #$00', listing[i+2]) > 0) and (pos('sta eax+3', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ecx', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ecx+1', listing[i+7]) > 0) and
       (pos('lda #$00', listing[i+8]) > 0) and (pos('sta ecx+2', listing[i+9]) > 0) and
       (pos('lda #$00', listing[i+10]) > 0) and (pos('sta ecx+3', listing[i+11]) > 0) and
       (pos('jsr imulECX', listing[i+12]) > 0) then
      begin
{
	lda #$00	; 0
	sta eax+2	; 1
	lda #$00	; 2
	sta eax+3	; 3
	lda #$80	; 4
	sta ecx		; 5
	lda #$01	; 6
	sta ecx+1	; 7
	lda #$00	; 8
	sta ecx+2	; 9
	lda #$00	; 10
	sta ecx+3	; 11
	jsr imulECX	; 12
}
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


    if (pos('lda ', listing[i]) > 0) and					// lda ztmp9		; 0
       (pos('bpl @+', listing[i+1]) > 0) and					// bpl @+		; 1
       (pos('lda ', listing[i+2]) > 0) and					// lda 			; 2
       (pos('sub ', listing[i+3]) > 0) and					// sub 			; 3
       (pos('sta eax+2', listing[i+4]) > 0) and					// sta eax+2		; 4
       (pos('lda ', listing[i+5]) > 0) and					// lda 			; 5
       (pos('sbc ', listing[i+6]) > 0) and					// sbc			; 6
       (pos('sta eax+3', listing[i+7]) > 0) and 				// sta eax+3		; 7
       (listing[i+8] = '@') and							//@			; 8
       (pos('lda eax', listing[i+9]) > 0) and 					// lda eax		; 9
       (pos('sta ', listing[i+10]) > 0) and 					// sta 			; 10
       (pos('lda eax+1', listing[i+11]) > 0) and 				// lda eax+1		; 11
       (pos('sta ', listing[i+12]) > 0) and 					// sta 			; 12
       (pos('lda ', listing[i+13]) = 0)  then					// ~lda			; 13
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


    if (pos('asl STACK', listing[i]) > 0) and					// asl STACKORIGIN+10	; 0
       (pos('rol @', listing[i+1]) > 0) and					// rol @		; 1
       (pos('sta eax+1', listing[i+2]) > 0) and					// sta eax+1		; 2
       (pos('lda STACK', listing[i+3]) > 0) and					// lda STACKORIGIN+10	; 3
       (pos('sta eax', listing[i+4]) > 0) and					// sta eax		; 4
       (pos('lda #$00', listing[i+5]) > 0) and					// lda #$00		; 5
       (pos('sta eax+2', listing[i+6]) > 0) and					// sta eax+2		; 6
       (pos('lda #$00', listing[i+7]) > 0) and					// lda #$00		; 7
       (pos('sta eax+3', listing[i+8]) > 0) then 				// sta eax+3		; 8
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin

	tmp:=#9'sta ' + copy(listing[i+3], 6, 256);
	insert('STACKWIDTH+', tmp, pos('STACKORIGIN+', listing[i+3])+12);

	yes:=false;
	for p:=i+3 to l-1 do
	 if pos('eax+1', listing[p]) > 0 then begin yes:=true; Break end;

	if not yes then listing[i+2] := tmp;

	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

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

  for i := 0 to l - 1 do begin

// -----------------------------------------------------------------------------
// ===				optymalizacja LDA.			  === //
// -----------------------------------------------------------------------------

    if (pos('lda #$', listing[i]) > 0) and (pos('sta @FORTMP_', listing[i+1]) > 0) then		// zamiana na MVA aby zadzialala optymalizacja OPTYFOR
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


    if (pos('lda #', listing[i]) = 0) and (pos('lda #', listing[i+2]) = 0) and
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and		// lda TEMP	; 0
       (pos('lda ', listing[i+2]) > 0) then						// sta		; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and 			// lda TEMP	; 2
        (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then begin
        listing[i+2] := '';
        Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===				optymalizacja regY.			  === //
// -----------------------------------------------------------------------------

    if Result and				// "samotna" instrukcja na koncu bloku
       ((pos('ldy ', listing[i]) > 0) or (pos('lda ', listing[i]) > 0)) and
       (listing[i+1] = '') then begin

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
//	sta STACKORIGIN+10
//	lda adr.PAC_SPRITES+1,y
//	sta STACKORIGIN+STACKWIDTH+10

    if (pos('ldy #$', listing[i]) > 0) and						// ldy #
       (pos('a adr.', listing[i+1]) > 0) and (pos(',y', listing[i+1]) > 0) then		// lda|sta adr.xxx,y
       begin

        yes := false;

        p:=i+1;
	while p < l do begin

        if (pos('cmp ', listing[p]) > 0) or (pos('bne ', listing[p]) > 0) or (pos('beq ', listing[p]) > 0) or	// wyjatki dla ktorych
	   (pos('bcc ', listing[p]) > 0) or (pos('bcs ', listing[p]) > 0) or (pos(#9'tya', listing[p]) > 0) or	// musimy zachowac ldy #$xx
	   (pos(#9'dey', listing[p]) > 0) or (pos(#9'iny', listing[p]) > 0) or
	   (pos('bpl ', listing[p]) > 0) or (pos('bmi ', listing[p]) > 0) or
	   (pos(#9'spl', listing[p]) > 0) or (pos(#9'smi', listing[p]) > 0) or
	   (pos(#9'seq', listing[p]) > 0) or (pos(#9'sne', listing[p]) > 0)
	then begin
	 yes:=true; Break
	end;

	if not((pos('lda ', listing[p]) > 0) or (pos('sta ', listing[p]) > 0) or
	       (pos('and ', listing[p]) > 0) or (pos('ora ', listing[p]) > 0) or (pos('eor ', listing[p]) > 0) or
	       (pos('add ', listing[p]) > 0) or (pos('adc ', listing[p]) > 0) or
	       (pos('sub ', listing[p]) > 0) or (pos('sbc ', listing[p]) > 0) ) then Break;

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
//	lda STACKORIGIN+10
//	sta adr.PAC_SPRITES,y
//	lda STACKORIGIN+STACKWIDTH+10
//	sta adr.PAC_SPRITES+1,y

    if (pos('ldy #$', listing[i]) > 0) and (pos(',y', listing[i+1]) = 0) and
       (pos('a adr.', listing[i+2]) > 0) and (pos(',y', listing[i+2]) > 0) then
       begin

        yes := false;

        p:=i+2;
	while p < l do begin

        if (pos('cmp ', listing[p]) > 0) or (pos('bne ', listing[p]) > 0) or (pos('beq ', listing[p]) > 0) or		// wyjatki dla ktorych
	   (pos('bcc ', listing[p]) > 0) or (pos('bcs ', listing[p]) > 0) or (pos(#9'tya', listing[p]) > 0) or		// musimy zachowac ldy #$xx
	   (pos(#9'dey', listing[p]) > 0) or (pos(#9'iny', listing[p]) > 0) or
	   (pos('bpl ', listing[p]) > 0) or (pos('bmi ', listing[p]) > 0) or
	   (pos(#9'spl', listing[p]) > 0) or (pos(#9'smi', listing[p]) > 0) or
	   (pos(#9'seq', listing[p]) > 0) or (pos(#9'sne', listing[p]) > 0)
	then begin
	 yes:=true; Break
	end;

	if not((pos('lda ', listing[p]) > 0) or (pos('sta ', listing[p]) > 0) or
	       (pos('and ', listing[p]) > 0) or (pos('ora ', listing[p]) > 0) or (pos('eor ', listing[p]) > 0) or
	       (pos('add ', listing[p]) > 0) or (pos('adc ', listing[p]) > 0) or
	       (pos('sub ', listing[p]) > 0) or (pos('sbc ', listing[p]) > 0) ) then Break;

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


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and						// lda 		; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) and						// sta A	; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and						// lda 		; 2
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) then						// sta A+1	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and 							// lda A	; 4
        (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then							// sta		; 5
     begin														// lda A+1	; 6
	listing[i+4] := listing[i];											// sta		; 7
	listing[i+6] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

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
      if listing[i] = listing[i+3] then											// sta STACKORIGIN+9	; 2
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
       ((pos('add ', listing[i+2]) > 0) or (pos('sub ', listing[i+2]) > 0)) and						// lda adr...,y		; 1
       (pos('ldy ', listing[i+3]) > 0) then										// add|subadd|sub	; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin						// ldy I		; 3
	listing[i+3] := '';												// sta adr...,y		; 4
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('add #$01', listing[i+1]) > 0) and 					// lda I
       (pos('sta STACK', listing[i+2]) > 0) then									// add #$01
     if (pos('ldy ', listing[i+3]) > 0) and (pos('lda ', listing[i+4]) > 0) and 					// sta STACKORIGIN+9
        (pos('ldy STACK', listing[i+5]) > 0) then									// ldy I
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and							// lda
         (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then begin						// ldy STACKORIGIN+9
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+5] := #9'iny';
	Result:=false;
       end;


    if (pos('ldy ', listing[i]) > 0) and (pos(#9'iny', listing[i+1]) > 0) and (pos('ldy ', listing[i+3]) > 0) and	// ldy I
       ( (pos('lda ', listing[i+2]) > 0) or (pos('sta ', listing[i+2]) > 0)) then					// iny
       if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then begin						// lda|sta xxx
	listing[i+3] := #9'dey';											// ldy I
	Result:=false;
       end;


// -----------------------------------------------------------------------------

//	lda adr.L_BLOCK,y		; 0
//	sta STACKORIGIN+9		; 1
//	lda adr.H_BLOCK,y		; 2
//	sta STACKORIGIN+STACKWIDTH+10	; 3
//	lda #$00			; 4
//	add STACKORIGIN+9		; 5
//	sta TB				; 6
//	lda #$00			; 7
//	adc STACKORIGIN+STACKWIDTH+10	; 8
//	sta TB+1			; 9

    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('add STACK', listing[i+5]) > 0)  then
       if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
          (pos(copy(listing[i+1], 6, 256), listing[i+2]) = 0) and
          (pos(copy(listing[i+1], 6, 256), listing[i+3]) = 0) and
          (pos(copy(listing[i+1], 6, 256), listing[i+4]) = 0) then begin

       listing[i+5] := #9'add '+copy(listing[i], 6, 256);
       listing[i]   := '';
       listing[i+1] := '';

       Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('adc STACK', listing[i+6]) > 0)  then
       if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
          (pos(copy(listing[i+1], 6, 256), listing[i+2]) = 0) and
          (pos(copy(listing[i+1], 6, 256), listing[i+3]) = 0) and
          (pos(copy(listing[i+1], 6, 256), listing[i+4]) = 0) and
          (pos(copy(listing[i+1], 6, 256), listing[i+5]) = 0) then begin

       listing[i+6] := #9'adc '+copy(listing[i], 6, 256);
       listing[i]   := '';
       listing[i+1] := '';

       Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===				FILL.					  === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and
       ((pos('sub ', listing[i+1]) > 0) or (pos('add ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('sbc ', listing[i+4]) > 0) or (pos('adc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('sbc ', listing[i+7]) > 0) or (pos('adc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('sbc ', listing[i+10]) > 0) or (pos('adc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta edx', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta edx+1', listing[i+15]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then begin
 {
	lda STACKORIGIN+9		; 0
	add STACKORIGIN+10		; 1
	sta STACKORIGIN+9		; 2
	lda STACKORIGIN+STACKWIDTH+9	; 3
	adc STACKORIGIN+STACKWIDTH+10	; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda STACKORIGIN+STACKWIDTH*2+9	; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda STACKORIGIN+STACKWIDTH*3+9	; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+9	; 11
	lda STACKORIGIN+9		; 12
	sta edx				; 13
	lda STACKORIGIN+STACKWIDTH+9	; 14
	sta edx+1			; 15
}
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

    if (pos('lda ', listing[i]) > 0) and
       ((pos('add eax', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc eax+1', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta eax+2', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta eax+3', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and
       (pos('add ', listing[i+13]) > 0) and
       (pos('sta STACK', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and
       (pos('adc ', listing[i+16]) > 0) and
       (pos('sta STACK', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) = 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+12], 6, 256) = copy(listing[i+14], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+15], 6, 256) = copy(listing[i+17], 6, 256)) then begin
 {
	lda #$00			; 0
	add eax				; 1
	sta STACKORIGIN+10		; 2
	lda #$A8			; 3
	adc eax+1			; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda #$00			; 6
	adc #$00			; 7
	sta eax+2			; 8
	lda #$00			; 9
	adc #$00			; 10
	sta eax+3			; 11
	lda STACKORIGIN+10		; 12
	add #$A1			; 13
	sta STACKORIGIN+10		; 14
	lda STACKORIGIN+STACKWIDTH+10	; 15
	adc #$00			; 16
	sta STACKORIGIN+STACKWIDTH+10	; 17
	lda #$28			; 18
}
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10]  := '';
	listing[i+11]  := '';

        Result:=false;
       end;


    if (pos('lda STACK', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta edx', listing[i+2]) > 0) and
       (pos('lda STACK', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta edx+1', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta ', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta ', listing[i+11]) > 0) then
      begin
 {
	lda STACKORIGIN+10		; 0
	add #$35			; 1
	sta edx				; 2
	lda STACKORIGIN+STACKWIDTH+10	; 3
	adc #$00			; 4
	sta edx+1			; 5
	lda STACKORIGIN+STACKWIDTH*2+10	; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda STACKORIGIN+STACKWIDTH*3+10	; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
}
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10]  := '';
	listing[i+11]  := '';

        Result:=false;
       end;


    if (pos('lda STACK', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta ecx', listing[i+2]) > 0) and
       (pos('lda STACK', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta ecx+1', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda ', listing[i+12]) > 0) and
       (pos('sta edx', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and
       (pos('sta edx+1', listing[i+15]) > 0) then
     if (copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) then begin
 {
	lda STACKORIGIN+10		; 0
	add #$35			; 1
	sta ecx				; 2
	lda STACKORIGIN+STACKWIDTH+10	; 3
	adc #$00			; 4
	sta ecx+1			; 5
	lda STACKORIGIN+STACKWIDTH*2+10	; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda STACKORIGIN+STACKWIDTH*3+10	; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	lda #$B3			; 12
	sta edx				; 13
	lda #$20			; 14
	sta edx+1			; 15
}
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10]  := '';
	listing[i+11]  := '';

        Result:=false;
       end;


    if (pos('ldy #$00', listing[i]) > 0) and
       (pos('lda STACK', listing[i+1]) > 0) and
       (pos(#9'spl', listing[i+2]) > 0) and
       (pos(#9'dey', listing[i+3]) > 0) and
       (pos('sta STACK', listing[i+4]) > 0) and
       (pos('sty STACK', listing[i+5]) > 0) and
       (pos('sty STACK', listing[i+6]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and
       ((pos('add STACK', listing[i+8]) > 0) or (pos('sub STACK', listing[i+8]) > 0)) and
       (pos('sta ecx', listing[i+9]) > 0) and
       (pos('lda ', listing[i+10]) > 0) and
       ((pos('adc STACK', listing[i+11]) > 0) or (pos('sbc STACK', listing[i+11]) > 0)) and
       (pos('sta ecx+1', listing[i+12]) > 0) and
       (pos('lda ', listing[i+13]) = 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+11], 6, 256)) then begin
 {
	ldy #$00			; 0
	lda STACKORIGIN+STACKWIDTH+11	; 1
	spl				; 2
	dey				; 3
	sta STACKORIGIN+STACKWIDTH+11	; 4
	sty STACKORIGIN+STACKWIDTH*2+11	; 5
	sty STACKORIGIN+STACKWIDTH*3+11	; 6
	lda 				; 7
	add STACKORIGIN+11		; 8
	sta ecx				; 9
	lda 				; 10
	adc STACKORIGIN+STACKWIDTH+11	; 11
	sta ecx+1			; 12
}
	listing[i+5]  := '';
	listing[i+6]  := '';

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('sub ', listing[i+1]) > 0) or (pos('add ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('sbc ', listing[i+4]) > 0) or (pos('adc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('sbc ', listing[i+7]) > 0) or (pos('adc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('sbc ', listing[i+10]) > 0) or (pos('adc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta edx', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta edx+1', listing[i+15]) > 0) and
       (pos('lda STACK', listing[i+16]) > 0) and (pos('sta ecx', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) > 0) and (pos('sta ecx+1', listing[i+19]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+16], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+18], 6, 256)) then begin
 {
	lda				; 0
	sub STACKORIGIN+11		; 1
	sta STACKORIGIN+10		; 2
	lda				; 3
	sbc STACKORIGIN+STACKWIDTH+11	; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda 				; 6
	sbc STACKORIGIN+STACKWIDTH*2+11	; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda				; 9
	sbc STACKORIGIN+STACKWIDTH*3+11	; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	lda STACKORIGIN+9		; 12
	sta edx				; 13
	lda STACKORIGIN+STACKWIDTH+9	; 14
	sta edx+1			; 15
	lda STACKORIGIN+10		; 16
	sta ecx				; 17
	lda STACKORIGIN+STACKWIDTH+10	; 18
	sta ecx+1			; 19
}
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


    if (pos('lda ', listing[i]) > 0) and
       ((pos('sub ', listing[i+1]) > 0) or (pos('add ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('sbc ', listing[i+4]) > 0) or (pos('adc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('sbc ', listing[i+7]) > 0) or (pos('adc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('sbc ', listing[i+10]) > 0) or (pos('adc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('mwa ', listing[i+12]) > 0) and (pos(' bp2', listing[i+12]) > 0) and
       (pos('ldy ', listing[i+13]) > 0) and
       (pos('lda (bp2),y', listing[i+14]) > 0) and (pos('sta STACK', listing[i+15]) > 0) and
       (pos('lda STACK', listing[i+16]) > 0) and (pos('sta edx', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) > 0) and (pos('sta edx+1', listing[i+19]) > 0) and
       (pos('lda STACK', listing[i+20]) > 0) and (pos('sta ecx', listing[i+21]) > 0) and
       (pos('lda STACK', listing[i+22]) > 0) and (pos('sta ecx+1', listing[i+23]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+20], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) then begin
 {
	lda STACKORIGIN+10		; 0
	add STACKORIGIN+11		; 1
	sta STACKORIGIN+10		; 2
	lda STACKORIGIN+STACKWIDTH+10	; 3
	adc STACKORIGIN+STACKWIDTH+11	; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda STACKORIGIN+STACKWIDTH*2+10	; 6
	adc STACKORIGIN+STACKWIDTH*2+11	; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda STACKORIGIN+STACKWIDTH*3+10	; 9
	adc STACKORIGIN+STACKWIDTH*3+11	; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	mwa xx bp2			; 12
	ldy #$0A			; 13
	lda (bp2),y			; 14
	sta STACKORIGIN+11		; 15
	lda STACKORIGIN+9		; 16
	sta edx				; 17
	lda STACKORIGIN+STACKWIDTH+9	; 18
	sta edx+1			; 19
	lda STACKORIGIN+10		; 20
	sta ecx				; 21
	lda STACKORIGIN+STACKWIDTH+10	; 22
	sta ecx+1			; 23
}
        listing[i+2] := listing[i+21];
        listing[i+5] := listing[i+23];

        listing[i+20] := '';
        listing[i+21] := '';
        listing[i+22] := '';
        listing[i+23] := '';

        listing[i+6]   := '';
        listing[i+7]   := '';
        listing[i+8]   := '';
        listing[i+9]   := '';
        listing[i+10]  := '';
        listing[i+11]  := '';

        Result:=false;
       end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos(#9'iny', listing[i+2]) > 0) and
       (pos('lda (bp2),y', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and
       (pos('lda ', listing[i+5]) > 0) and
       (pos('add ', listing[i+6]) > 0) and (pos('sta ecx', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and
       (pos('adc ', listing[i+9]) > 0) and  (pos('sta ecx+1', listing[i+10]) > 0) and
       (pos('lda STACK', listing[i+11]) > 0) and (pos('sta edx', listing[i+12]) > 0) and
       (pos('lda STACK', listing[i+13]) > 0) and (pos('sta edx+1', listing[i+14]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+13], 6, 256)) then begin
{
	lda (bp2),y			; 0
	sta STACKORIGIN+9		; 1
	iny				; 2
	lda (bp2),y			; 3
	sta STACKORIGIN+STACKWIDTH+9	; 4
	lda #$80			; 5
	add PAC.SY			; 6
	sta ecx				; 7
	lda #$C1			; 8
	adc PAC.SY+1			; 9
	sta ecx+1			; 10
	lda STACKORIGIN+9		; 11
	sta edx				; 12
	lda STACKORIGIN+STACKWIDTH+9	; 13
	sta edx+1			; 14
}
	listing[i+1] := listing[i+12];
	listing[i+4] := listing[i+14];

	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';

        Result:=false;
       end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos(#9'iny', listing[i+2]) > 0) and
       (pos('lda (bp2),y', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and
       (pos('lda STACK', listing[i+5]) > 0) and  (pos('sta ', listing[i+6]) > 0) and
       (pos('lda STACK', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then begin
{
	lda (bp2),y			; 0
	sta STACKORIGIN+9		; 1
	iny				; 2
	lda (bp2),y			; 3
	sta STACKORIGIN+STACKWIDTH+9	; 4
	lda STACKORIGIN+9		; 5
	sta				; 6
	lda STACKORIGIN+STACKWIDTH+9	; 7
	sta				; 8
}
	listing[i+1] := listing[i+6];
	listing[i+4] := listing[i+8];

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('sub ', listing[i+1]) > 0) or (pos('add ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('sbc ', listing[i+4]) > 0) or (pos('adc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('sub ', listing[i+7]) > 0) or (pos('add ', listing[i+7]) > 0)) and
       (pos('sta ecx', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('sbc ', listing[i+10]) > 0) or (pos('adc ', listing[i+10]) > 0)) and
       (pos('sta ecx+1', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta edx', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta edx+1', listing[i+15]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then begin
 {
	lda K				; 0
	add #$15			; 1
	sta STACKORIGIN+9		; 2
	lda K+1				; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda Q				; 6
	sub #$05			; 7
	sta ecx				; 8
	lda Q+1				; 9
	sbc #$00			; 10
	sta ecx+1			; 11
	lda STACKORIGIN+9		; 12
	sta edx				; 13
	lda STACKORIGIN+STACKWIDTH+9	; 14
	sta edx+1			; 15
}
        listing[i+2] := listing[i+13];
        listing[i+5] := listing[i+15];

        listing[i+12] := '';
        listing[i+13] := '';
        listing[i+14] := '';
        listing[i+15] := '';

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta edx', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and  (pos('sta edx+1', listing[i+9]) > 0) and
       (pos('lda STACK', listing[i+10]) > 0) and (pos('sta ecx', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta ecx+1', listing[i+13]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+10], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) then begin
{
	lda				; 0
	add|sub PAC.SY			; 1
	sta STACKORIGIN+10		; 2
	lda				; 3
	adc|sbc PAC.SY+1		; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda STACKORIGIN+9		; 6
	sta edx				; 7
	lda STACKORIGIN+STACKWIDTH+9	; 8
	sta edx+1			; 9
	lda STACKORIGIN+10		; 10
	sta ecx				; 11
	lda STACKORIGIN+STACKWIDTH+10	; 12
	sta ecx+1			; 13
}
        listing[i+2] := listing[i+11];
        listing[i+5] := listing[i+13];

        listing[i+10] := '';
        listing[i+11] := '';
        listing[i+12] := '';
        listing[i+13] := '';

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda STACK', listing[i+4]) > 0) and (pos('sta edx', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and  (pos('sta edx+1', listing[i+7]) > 0) and
       (pos('lda STACK', listing[i+8]) > 0) and (pos('sta ecx', listing[i+9]) > 0) and
       (pos('lda STACK', listing[i+10]) > 0) and (pos('sta ecx+1', listing[i+11]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then begin
{
	lda $0058			; 0
	sta STACKORIGIN+10		; 1
	lda $0058+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda STACKORIGIN+9		; 4
	sta edx				; 5
	lda STACKORIGIN+STACKWIDTH+9	; 6
	sta edx+1			; 7
	lda STACKORIGIN+10		; 8
	sta ecx				; 9
	lda STACKORIGIN+STACKWIDTH+10	; 10
	sta ecx+1			; 11
}
        listing[i+8]  := listing[i];
        listing[i+10] := listing[i+2];
        listing[i]    := '';
        listing[i+1]  := '';
        listing[i+2]  := '';
        listing[i+3]  := '';

        Result:=false;
       end;


    if (i>0) and
       (pos('lda STACK', listing[i]) > 0) and (pos('sta edx', listing[i+1]) > 0) and
       (pos('lda STACK', listing[i+2]) > 0) and  (pos('sta edx+1', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ecx', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ecx+1', listing[i+7]) > 0) then
     begin
{
	lda STACKORIGIN+9		; 0
	sta edx				; 1
	lda STACKORIGIN+STACKWIDTH+9	; 2
	sta edx+1			; 3
	lda				; 4
	sta ecx				; 5
	lda				; 6
	sta ecx+1			; 7
}
	tmp:='sta ' + copy(listing[i], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (pos(#9'eif', listing[p]) > 0) or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta edx'; Break end;
	end;

	if yes then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 Result:=false;
	end;

	tmp:='sta ' + copy(listing[i+2], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (pos(#9'eif', listing[p]) > 0) or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta edx+1'; Break end;
	end;

	if yes then begin
	 listing[i+2] := '';
	 listing[i+3] := '';
	 Result:=false;
	end;

     end;


    if (i>0) and
       (pos('lda STACK', listing[i]) > 0) and (pos('sta edx', listing[i+1]) > 0) and
       (pos('lda STACK', listing[i+2]) > 0) and  (pos('sta edx+1', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta eax', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta eax+1', listing[i+7]) > 0) then
     begin
{
	lda STACKORIGIN+9		; 0
	sta edx				; 1
	lda STACKORIGIN+STACKWIDTH+9	; 2
	sta edx+1			; 3
	lda				; 4
	sta eax				; 5
	lda				; 6
	sta eax+1			; 7
}
	tmp:='sta ' + copy(listing[i], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (pos(#9'eif', listing[p]) > 0) or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta edx'; Break end;
	end;

	if yes then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 Result:=false;
	end;

	tmp:='sta ' + copy(listing[i+2], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (pos(#9'eif', listing[p]) > 0) or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta edx+1'; Break end;
	end;

	if yes then begin
	 listing[i+2] := '';
	 listing[i+3] := '';
	 Result:=false;
	end;

     end;


    if (i>0) and
       (pos('lda STACK', listing[i]) > 0) and (pos('sta ecx', listing[i+1]) > 0) and
       (pos('lda STACK', listing[i+2]) > 0) and  (pos('sta ecx+1', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta eax', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta eax+1', listing[i+7]) > 0) then
     begin
{
	lda STACKORIGIN+9		; 0
	sta ecx				; 1
	lda STACKORIGIN+STACKWIDTH+9	; 2
	sta ecx+1			; 3
	lda				; 4
	sta eax				; 5
	lda				; 6
	sta eax+1			; 7
}
	tmp:='sta ' + copy(listing[i], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (pos(#9'eif', listing[p]) > 0) or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta ecx'; Break end;
	end;

	if yes then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 Result:=false;
	end;

	tmp:='sta ' + copy(listing[i+2], 6, 256);
	yes:=false;
	for p:=i-1 downto 0 do begin
	 if (pos(#9'eif', listing[p]) > 0) or (pos('jsr ', listing[p]) > 0) or (listing[p] = '@') then Break;

	 if pos(tmp, listing[p]) > 0 then begin yes:=true; listing[p] := #9'sta ecx+1'; Break end;
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

    if (pos('lda ', listing[i]) > 0) and
       (pos('lsr @', listing[i+1]) > 0) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('ror STACK', listing[i+3]) > 0) and
       (pos('ror STACK', listing[i+4]) > 0) and
       (pos('ror STACK', listing[i+5]) > 0) then
      begin
{
	lda #$00			; 0
	lsr @				; 1
	sta STACKORIGIN+STACKWIDTH*3+9	; 2
	ror STACKORIGIN+STACKWIDTH*2+9	; 3
	ror STACKORIGIN+STACKWIDTH+9	; 4
	ror STACKORIGIN+9		; 5
	lsr STACKORIGIN+STACKWIDTH*3+9	; 6	-
	ror STACKORIGIN+STACKWIDTH*2+9	; 7
	ror STACKORIGIN+STACKWIDTH+9	; 8
	ror STACKORIGIN+9		; 9
	lsr STACKORIGIN+STACKWIDTH*3+9	; 10	-
	ror STACKORIGIN+STACKWIDTH*2+9	; 11
	ror STACKORIGIN+STACKWIDTH+9	; 12
	ror STACKORIGIN+9		; 13
	lsr STACKORIGIN+STACKWIDTH*3+9	; 14	-
	ror STACKORIGIN+STACKWIDTH*2+9	; 15
	ror STACKORIGIN+STACKWIDTH+9	; 16
	ror STACKORIGIN+9		; 17
	lsr STACKORIGIN+STACKWIDTH*3+9	; 18	-
	ror STACKORIGIN+STACKWIDTH*2+9	; 19
	ror STACKORIGIN+STACKWIDTH+9	; 20
	ror STACKORIGIN+9		; 21
	lsr STACKORIGIN+STACKWIDTH*3+9	; 22	-
	ror STACKORIGIN+STACKWIDTH*2+9	; 23
	ror STACKORIGIN+STACKWIDTH+9	; 24
	ror STACKORIGIN+9		; 25
	lsr STACKORIGIN+STACKWIDTH*3+9	; 26	-
	ror STACKORIGIN+STACKWIDTH*2+9	; 27
	ror STACKORIGIN+STACKWIDTH+9	; 28
	ror STACKORIGIN+9		; 29
}
       if (pos('lsr STACK', listing[i+6]) > 0) and (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then listing[i+6] := #9'lsr @';
       if (pos('lsr STACK', listing[i+10]) > 0) and (copy(listing[i+2], 6, 256) = copy(listing[i+10], 6, 256)) then listing[i+10] := #9'lsr @';
       if (pos('lsr STACK', listing[i+14]) > 0) and (copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) then listing[i+14] := #9'lsr @';
       if (pos('lsr STACK', listing[i+18]) > 0) and (copy(listing[i+2], 6, 256) = copy(listing[i+18], 6, 256)) then listing[i+18] := #9'lsr @';
       if (pos('lsr STACK', listing[i+22]) > 0) and (copy(listing[i+2], 6, 256) = copy(listing[i+22], 6, 256)) then listing[i+22] := #9'lsr @';
       if (pos('lsr STACK', listing[i+26]) > 0) and (copy(listing[i+2], 6, 256) = copy(listing[i+26], 6, 256)) then listing[i+26] := #9'lsr @';

       listing[i+2] := '';

       Result:=false;
      end;


// -----------------------------------------------------------------------------
// ===				ASL.					  === //
// -----------------------------------------------------------------------------


    if (pos('rol STACK', listing[i]) > 0) and (pos('+STACKWIDTH*', listing[i]) > 0) and		// rol STACKORIGIN+STACKWIDTH*3+9	; 0
       (pos('lda ', listing[i+1]) > 0) and							// lda					; 1
       ((pos('add ', listing[i+2]) > 0) or (pos('sub ', listing[i+2]) > 0)) and			// add|sub				; 2
       (pos('sta ', listing[i+3]) > 0) and							// sta					; 3
       (pos('lda ', listing[i+4]) > 0) and							// lda					; 4
       ((pos('adc ', listing[i+5]) > 0) or (pos('sbc ', listing[i+5]) > 0)) and			// adc|sbc				; 5
       (pos('sta ', listing[i+6]) > 0) and							// sta					; 6
       (pos('lda ', listing[i+7]) = 0) then
     begin
       listing[i] := '';
       Result:=false;
     end;


    if (pos('asl STACK', listing[i]) > 0) and							// asl STACKORIGIN+9			; 0
       (pos('rol STACK', listing[i+1]) > 0) and							// rol STACKORIGIN+STACKWIDTH+9		; 1
       (pos('rol STACK', listing[i+2]) > 0) and							// rol STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol STACK', listing[i+3]) > 0) and							// rol STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('lda ', listing[i+4]) > 0) and (pos('asl @', listing[i+5]) > 0) and			// lda					; 4
       (pos(#9'tay', listing[i+6]) > 0) and							// asl @				; 5
       (pos('lda STACK', listing[i+7]) > 0) and							// tay					; 6
       ((pos('add ', listing[i+8]) > 0) or (pos('sub ', listing[i+8]) > 0)) and			// lda STACKORIGIN+9			; 7
       (pos('sta ', listing[i+9]) > 0) and							// add|sub				; 8
       (pos('lda STACK', listing[i+10]) > 0) and						// sta					; 9
       ((pos('adc ', listing[i+11]) > 0) or (pos('sbc ', listing[i+11]) > 0)) and		// lda STACKORIGIN+STACKWIDTH+9		; 10
       (pos('sta ', listing[i+12]) > 0) and							// adc|sbc				; 11
       (pos('lda STACK', listing[i+13]) = 0) then						// sta					; 12
     if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) then begin

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


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('asl @', listing[i+10]) > 0) and
       (pos(#9'tay', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and
       ((pos('add ', listing[i+13]) > 0) or (pos('sub ', listing[i+13]) > 0)) and
       (pos('sta ', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and
       ((pos('adc ', listing[i+16]) > 0) or (pos('sbc ', listing[i+16]) > 0)) and
       (pos('sta ', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) = 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) then begin
{
	lda				; 0
	sub adr.VEL,y			; 1
	sta STACKORIGIN+9		; 2
	lda				; 3
	sbc adr.VEL+1,y			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda				; 6
	sbc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda I				; 9
	asl @				; 10
	tay				; 11
	lda STACKORIGIN+9		; 12
	sub adr.BALL,y			; 13
	sta T				; 14
	lda STACKORIGIN+STACKWIDTH+9	; 15
	sbc adr.BALL+1,y		; 16
	sta T+1				; 17
}
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

        Result:=false;
       end;


    if (pos('asl STACK', listing[i]) > 0) and							// asl STACKORIGIN+9			; 0
       (pos('rol STACK', listing[i+1]) > 0) and							// rol STACKORIGIN+STACKWIDTH+9		; 1
       (pos('rol STACK', listing[i+2]) > 0) and							// rol STACKORIGIN+STACKWIDTH*2+9	; 2
       (pos('rol STACK', listing[i+3]) > 0) and							// rol STACKORIGIN+STACKWIDTH*3+9	; 3
       (pos('mwa ', listing[i+4]) > 0) and (pos(' bp2', listing[i+4]) > 0) and			// mwa XX bp2				; 4
       (pos('ldy ', listing[i+5]) > 0) and							// ldy					; 5
       (pos('lda STACK', listing[i+6]) > 0) and (pos('sta (bp2),y', listing[i+7]) > 0) and	// lda STACKORIGIN+9			; 6
       (pos(#9'iny', listing[i+8]) > 0) and							// sta (bp2),y				; 7
       (pos('lda STACK', listing[i+9]) > 0) and (pos('sta (bp2),y', listing[i+10]) > 0) and	// iny					; 8
       (pos(#9'iny', listing[i+11]) = 0) then							// lda STACKORIGIN+STACKWIDTH+9		; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta (bp2),y				; 10
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


    if (pos('sta ', listing[i]) > 0) and (pos('asl ', listing[i+1]) > 0) and		// sta STACKORIGIN+9	; 0
       (pos('sta #$00', listing[i+2]) > 0) then						// asl STACKORIGIN+9	; 1
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then			// sta #$00		; 2
       begin
        listing[i+1] := listing[i];
	listing[i]   := #9'asl @';
	listing[i+2] := '';
        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and 						// lda			; 0
       ( (pos('lda ', listing[i+3]) > 0) or (pos('mwa ', listing[i+3]) > 0) ) and	// sta STACKORIGIN	; 1
       (pos('sta STACK', listing[i+1]) > 0) and						// asl STACKORIGIN	; 2
       (pos('asl STACK', listing[i+2]) > 0) then					// lda|mwa		; 3
      if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
        listing[i+2] := listing[i+1];
        listing[i+1] := #9'asl @';
        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('asl @', listing[i+1]) > 0) and (pos(#9'tay', listing[i+2]) > 0) and
       (pos('lda ', listing[i+5]) > 0) and (pos('asl @', listing[i+6]) > 0) and (pos(#9'tay', listing[i+7]) > 0) and
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and
       (pos('lda STACK', listing[i+8]) > 0) and  (pos('sta ', listing[i+10]) > 0) and
       ((pos('add adr.', listing[i+9]) > 0) or (pos('sub adr.', listing[i+9]) > 0)) then
     if (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then begin
{
	lda U			; 0
	asl @			; 1
	tay			; 2
	lda adr.MX,y		; 3
	sta STACKORIGIN+9	; 4
	lda U			; 5
	asl @			; 6
	tay			; 7
	lda STACKORIGIN+9	; 8
	sub adr.MY,y		; 9
	sta U			; 10
}
        listing[i+4] := '';
        listing[i+5] := '';
        listing[i+6] := '';
        listing[i+7] := '';
        listing[i+8] := '';

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('asl @', listing[i+1]) > 0) and (pos(#9'tay', listing[i+2]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and (pos('asl @', listing[i+8]) > 0) and (pos(#9'tay', listing[i+9]) > 0) and
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and
       (pos('lda adr.', listing[i+5]) > 0) and (pos('sta STACK', listing[i+6]) > 0) and
       (pos('lda STACK', listing[i+10]) > 0) and
       ((pos('add ', listing[i+11]) > 0) or (pos('sub ', listing[i+11]) > 0)) and
       (pos('sta ', listing[i+12]) > 0) and (pos('lda STACK', listing[i+13]) > 0) and
       ((pos('adc ', listing[i+14]) > 0) or (pos('sbc ', listing[i+14]) > 0)) and
       (pos('sta ', listing[i+15]) > 0) then
     if (copy(listing[i+4], 6, 256) = copy(listing[i+10], 6, 256)) and
        (copy(listing[i+6], 6, 256) = copy(listing[i+13], 6, 256)) and
        (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) then begin
{
	lda I				; 0
	asl @				; 1
	tay				; 2
	lda adr.BALL,y			; 3
	sta STACKORIGIN+9		; 4
	lda adr.BALL+1,y		; 5
	sta STACKORIGIN+STACKWIDTH+9	; 6
	lda I				; 7
	asl @				; 8
	tay				; 9
	lda STACKORIGIN+9		; 10
	add adr.VEL,y			; 11
	sta T				; 12
	lda STACKORIGIN+STACKWIDTH+9	; 13
	adc adr.VEL+1,y			; 14
	sta T+1				; 15
}
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
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+9		; 1
       (pos('asl STACK', listing[i+4]) > 0) and (pos('rol STACK', listing[i+5]) > 0) and	// lda I+1			; 2
       (pos('lda STACK', listing[i+6]) > 0) then						// sta STACKORIGIN+STACKWIDTH+9	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// asl STACKORIGIN+9		; 4
        (copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) and				// rol STACKORIGIN+STACKWIDTH+9	; 5
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then				// lda STACKORIGIN+9		; 6
       begin
        tmp := listing[i+1];

	listing[i+1] := listing[i+3];
	listing[i+3] := listing[i];
	listing[i]   := listing[i+2];
	listing[i+2] := listing[i+3];

	listing[i+3] := #9'asl @';
	listing[i+4] := listing[i+5];
	listing[i+5] := tmp;

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda ', listing[i+2]) > 0) and			// lda I			; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+9		; 1
       (pos('asl STACK', listing[i+4]) > 0) and (pos('rol STACK', listing[i+5]) > 0) and	// lda I+1			; 2
       (pos('lda STACK', listing[i+6]) > 0) then						// sta STACKORIGIN+STACKWIDTH+9	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// asl STACKORIGIN+9		; 4
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and				// rol STACKORIGIN+STACKWIDTH+9	; 5
	(copy(listing[i+5], 6, 256) = copy(listing[i+6], 6, 256)) then				// lda STACKORIGIN+STACKWIDTH+9	; 6
       begin
        listing[i+5] := listing[i+3];
	listing[i+3] := listing[i+4];
	listing[i+4] := #9'rol @';

        Result:=false;
       end;

{
    if (pos('asl STACK', listing[i]) > 0) and (pos('rol @', listing[i+1]) > 0) and		// asl STACKORIGIN+9		; 0
       (pos('sta STACK', listing[i+2]) > 0) and (pos('ldy STACK', listing[i+3]) > 0) and	// rol @			; 1
       (pos('lda adr.', listing[i+4]) > 0) then				 			// sta STACKORIGIN+STACKWIDTH+9	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// ldy STACKORIGIN+9		; 3
       begin
        listing[i+1] := '';
	listing[i+2] := '';

        Result:=false;
       end;
}

// wspolna procka dla Nx ASL

    if ((pos('lda ', listing[i]) > 0) or (pos('and ', listing[i]) > 0) or			// lda|and|ora|eor	; 0
        (pos('ora ', listing[i]) > 0) or (pos('eor ', listing[i]) > 0)) and			// sta STACKORIGIN+9	; 1
       (pos('sta STACK', listing[i+1]) > 0) and (pos('asl STACK', listing[i+2]) > 0) then	// asl STACKORIGIN+9	; 2
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then				// lda STACKORIGIN+9	; 3
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


    if (pos('lda ', listing[i]) > 0) and (pos('lda ', listing[i+3]) > 0) and			// lda I		; 0
       (pos('asl @', listing[i+1]) > 0) and (pos('asl @', listing[i+4]) > 0) and		// asl @		; 1
       (pos('sta STACK', listing[i+2]) > 0) and (pos(#9'tay', listing[i+5]) > 0) then		// sta STACKORIGIN+9	; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// lda 	I		; 3
       begin											// asl @		; 4
        listing[i+2] := '';									// tay			; 5
        listing[i+3] := '';
        listing[i+4] := '';
        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('asl @', listing[i+1]) > 0) and (pos(#9'tay', listing[i+2]) > 0) and
       (pos('lda ', listing[i+5]) > 0) and (pos('asl @', listing[i+6]) > 0) and (pos(#9'tay', listing[i+7]) > 0) and
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and
       (pos('lda adr.', listing[i+8]) > 0) and  (pos('sta ', listing[i+10]) > 0) and
       ((pos('add STACK', listing[i+9]) > 0) or (pos('sub STACK', listing[i+9]) > 0)) then
     if (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then begin
{
	lda U			; 0
	asl @			; 1
	tay			; 2
	lda adr.MX,y		; 3
	sta STACKORIGIN+9	; 4
	lda U			; 5
	asl @			; 6
	tay			; 7
	lda adr.MY,y		; 8
	add STACKORIGIN+9	; 9
	sta U			; 10
}
        listing[i+4] := '';
        listing[i+5] := '';
        listing[i+6] := '';
        listing[i+7] := '';
        listing[i+8] := copy(listing[i+9], 1, 5) + copy(listing[i+8], 6, 256);
        listing[i+9] := '';

        Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda X			; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and		// sta STACKORIGIN+9		; 1
       (pos('asl STACK', listing[i+4]) > 0) and (pos('rol STACK', listing[i+5]) > 0) and	// lda X+1			; 2
       (pos('asl STACK', listing[i+6]) > 0) and (pos('rol STACK', listing[i+7]) > 0) and	// sta STACKORIGIN+STACKWIDTH+9	; 3
       (pos('lda ', listing[i+8]) > 0) then							// asl STACKORIGIN+9		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// rol STACKORIGIN+STACKWIDTH+9	; 5
        (copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) and				// asl STACKORIGIN+9		; 6
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and				// rol STACKORIGIN+STACKWIDTH+9	; 7
        (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then 				// lda				; 8
	begin
        tmp := listing[i+1];

	listing[i+1] := listing[i+3];
	listing[i+3] := listing[i];
	listing[i]   := listing[i+2];
	listing[i+2] := listing[i+3];

	listing[i+3] := #9'asl @';
	listing[i+4] := listing[i+5];
	listing[i+5] := #9'asl @';
	listing[i+6] := listing[i+7];
	listing[i+7] := tmp;

	Result := false;
	end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta STACKORIGIN+10		; 0
       ((pos('adc ', listing[i+2]) > 0) or (pos('sbc ', listing[i+2]) > 0)) and			// lda				; 1
       ((pos('asl STACK', listing[i+3]) > 0) or (pos('lsr STACK', listing[i+3]) > 0)) and	// adc|sbc			; 2
       ((pos('rol ', listing[i+4]) = 0) and (pos('ror ', listing[i+4]) = 0)) then		// asl|lsr STACKORIGIN+10	; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// <> rol|ror			; 4
        listing[i+1] := '';
        listing[i+2] := '';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta STACKORIGIN+STACK	; 0
       ((pos('adc ', listing[i+2]) > 0) or (pos('sbc ', listing[i+2]) > 0)) and			// lda				; 1
       ((pos('asl ', listing[i+3]) > 0) or (pos('lsr ', listing[i+3]) > 0)) and			// adc|sbc			; 2
       (pos('sta #$00', listing[i+4]) > 0) and 							// asl|lsr			; 3
       ((pos('ror STACK', listing[i+5]) > 0) or (pos('rol STACK', listing[i+5]) > 0)) then	// sta #$00			; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then begin			// ror|rol STACKORIGIN+STACK	; 5
        listing[i+4] := '';
        Result:=false;
     end;


    if (pos('asl STACKORIGIN', listing[i]) > 0) and						// asl STACKORIGIN
       (pos('rol STACKORIGIN+STACKWIDTH', listing[i+1]) > 0) and				// rol STACKORIGIN+STACKWIDTH
       (pos('rol STACKORIGIN+STACKWIDTH*2', listing[i+2]) > 0) and				// rol STACKORIGIN+STACKWIDTH*2
       (pos('rol #$00', listing[i+3]) > 0)  then						// rol #$00
     begin
        listing[i+2] := '';
        listing[i+3] := '';
        Result:=false;
     end;


    if (pos('asl STACK', listing[i]) > 0) and (pos('rol #$00', listing[i+1]) > 0) then		// asl STACKORIGIN+9
     begin											// rol #$00
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('asl @', listing[i]) > 0) and (pos('sta #$00', listing[i+1]) > 0) then		// asl @
     begin											// sta #$00
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and							// sta STACKORIGIN+9
       (pos('asl STACK', listing[i+1]) > 0) and (pos('asl STACK', listing[i+2]) > 0) and	// asl STACKORIGIN+9
       (pos('ldy STACK', listing[i+3]) > 0) then						// asl STACKORIGIN+9
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and				// ldy STACKORIGIN+9
        (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin

        listing[i]   := '';
        listing[i+1] := #9'asl @';
        listing[i+2] := #9'asl @';
        listing[i+3] := #9'tay';

        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta STACKORIGIN+9
       (pos('asl STACK', listing[i+2]) > 0) and (pos('asl STACK', listing[i+3]) > 0) and	// lda
       (pos('ldy STACK', listing[i+4]) > 0) then						// asl STACKORIGIN+9
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// asl STACKORIGIN+9
        (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and				// ldy STACKORIGIN+9 | lda
        (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then begin
        listing[i]   := '';
        listing[i+1] := '';
        listing[i+2] := #9'asl @';
        listing[i+3] := #9'asl @';
        listing[i+4] := #9'tay';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('asl STACK', listing[i+1]) > 0) and		// sta STACKORIGIN+9
       (pos('ldy STACK', listing[i+2]) > 0) then						// asl STACKORIGIN+9
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and				// ldy STACKORIGIN+9
        (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin
        listing[i]   := '';
        listing[i+1] := #9'asl @';
        listing[i+2] := #9'tay';
        Result:=false;
     end;

    if (pos('sta STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sta STACKORIGIN+9
       (pos('asl STACK', listing[i+2]) > 0) and (pos('ldy STACK', listing[i+3]) > 0) then	// lda
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and				// asl STACKORIGIN+9
        (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// ldy STACKORIGIN+9
        listing[i]   := '';
        listing[i+1] := '';
        listing[i+2] := #9'asl @';
        listing[i+3] := #9'tay';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACKORIGIN', listing[i+1]) > 0) and						// lda 				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACKORIGIN+STACKWIDTH', listing[i+3]) > 0) and				// sta STACKORIGIN		; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACKORIGIN+STACKWIDTH*2', listing[i+5]) > 0) and				// lda 				; 2
       (pos('lda ', listing[i+6]) > 0) and (pos('sta STACKORIGIN+STACKWIDTH*3', listing[i+7]) > 0) and				// sta STACKORIGIN+STACKWIDTH	; 3
       (pos('asl STACKORIGIN', listing[i+8]) > 0) and (pos('rol STACKORIGIN+STACKWIDTH', listing[i+9]) > 0) and			// lda				; 4
       (pos('rol STACKORIGIN+STACKWIDTH*2', listing[i+10]) > 0) and (pos('rol STACKORIGIN+STACKWIDTH*3', listing[i+11]) > 0) and// sta STACKORIGIN+STACKWIDTH*2	; 5
       (pos('lda STACKORIGIN', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and					// lda 				; 6
       (pos('lda STACKORIGIN+STACKWIDTH', listing[i+14]) > 0) and (pos('sta ', listing[i+15]) > 0) and				// sta STACKORIGIN+STACKWIDTH*3	; 7
       (pos('lda STACKORIGIN+STACKWIDTH*2', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and			// asl STACKORIGIN		; 8
       (pos('lda STACKORIGIN+STACKWIDTH*3', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then			// rol STACKORIGIN+STACKWIDTH	; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and								// rol STACKORIGIN+STACKWIDTH*2	; 10
        (copy(listing[i+8], 6, 256) = copy(listing[i+12], 6, 256)) and								// rol STACKORIGIN+STACKWIDTH*3	; 11
        (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and								// lda STACKORIGIN		; 12
        (copy(listing[i+9], 6, 256) = copy(listing[i+14], 6, 256)) and								// sta				; 13
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and								// lda STACKORIGIN+STACKWIDTH	; 14
        (copy(listing[i+10], 6, 256) = copy(listing[i+16], 6, 256)) and								// sta 				; 15
        (copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) and								// lda STACKORIGIN+STACKWIDTH*2	; 16
        (copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then							// sta 				; 17
     begin															// lda STACKORIGIN+STACKWIDTH*3	; 18
	listing[i+1] := listing[i+13];												// sta				; 19
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

{
    if (pos('lda eax', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda eax				; 0
       (pos('lda eax+1', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+9			; 1
       (pos('lda eax+2', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and	// lda eax+1				; 2
       (pos('lda eax+3', listing[i+6]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and	// sta STACKORIGIN+STACKWIDTH+9		; 3
       (pos('asl STACK', listing[i+8]) > 0) and (pos('rol STACK', listing[i+9]) > 0) and	// lda eax+2				; 4
       (pos('rol STACK', listing[i+10]) > 0) and (pos('rol STACK', listing[i+11]) > 0) and	// sta STACKORIGIN+STACKWIDTH*2+9	; 5
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and		// lda eax+3				; 6
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta ', listing[i+15]) > 0) and		// sta STACKORIGIN+STACKWIDTH*3+9	; 7
       (pos('lda STACK', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and		// asl STACKORIGIN+9			; 8
       (pos('lda STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then		// rol STACKORIGIN+STACKWIDTH+9		; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and				// rol STACKORIGIN+STACKWIDTH*2+9	; 10
        (copy(listing[i+8], 6, 256) = copy(listing[i+12], 6, 256)) and				// rol STACKORIGIN+STACKWIDTH*3+9	; 11
        (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and				// lda STACKORIGIN+9			; 12
        (copy(listing[i+9], 6, 256) = copy(listing[i+14], 6, 256)) and				// sta A2				; 13
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and				// lda STACKORIGIN+STACKWIDTH+9		; 14
        (copy(listing[i+10], 6, 256) = copy(listing[i+16], 6, 256)) and				// sta A2+1				; 15
        (copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) and				// lda STACKORIGIN+STACKWIDTH*2+9	; 16
        (copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then			// sta A2+2				; 17
     begin											// lda STACKORIGIN+STACKWIDTH*3+9	; 18
	listing[i]   := '';									// sta A2+3				; 19
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	listing[i+8]  := #9'asl eax';
	listing[i+9]  := #9'rol eax+1';
	listing[i+10] := #9'rol eax+2';
	listing[i+11] := #9'rol eax+3';

	listing[i+12] := #9'lda eax';
	listing[i+14] := #9'lda eax+1';
	listing[i+16] := #9'lda eax+2';
	listing[i+18] := #9'lda eax+3';

      	Result:=false;
     end;
}

    if ((pos('ldy ', listing[i]) > 0) or (pos(#9'tay', listing[i]) > 0)) and
       (pos('lda adr.', listing[i+1]) > 0) and                                                                                     // tay|ldy A                  ; 0
       (pos('sta STACK', listing[i+2]) > 0) and (pos('ldy ', listing[i+3]) > 0) and                                                // lda adr.???,y              ; 1
       (pos('lda adr.', listing[i+4]) > 0) and                                                                                     // sta STACKORIGIN+9          ; 2
       ((pos('ora STACK', listing[i+5]) > 0) or (pos('and STACK', listing[i+5]) > 0) or (pos('eor STACK', listing[i+5]) > 0)) then // ldy B                      ; 3
     if copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)  then begin                                                        // lda adr.???,y              ; 4
        listing[i+2] := '';                                                                                                        // ora|and|eor STACKORIGIN+9  ; 5
        listing[i+4] := copy(listing[i+5], 1, 5) + copy(listing[i+4], 6, 256);
        listing[i+5] := '';

        Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (pos(#9'tay', listing[i]) > 0)) and
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and                                            // tay|ldy A                  ; 0
       (pos('ldy ', listing[i+3]) > 0) and (pos('lda adr.', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and        // lda adr.???,y              ; 1
       (pos('lda STACK', listing[i+6]) > 0) and                                                                                    // sta STACKORIGIN+9          ; 2
       ((pos('ora STACK', listing[i+7]) > 0) or (pos('and STACK', listing[i+7]) > 0) or (pos('eor STACK', listing[i+7]) > 0)) then // ldy B                      ; 3
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and                                                              // lda adr.???,y              ; 4
        (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then begin                                                       // sta STACKORIGIN+10         ; 5
        listing[i+2] := '';                                                                                                        // lda STACKORIGIN+9          ; 6
        listing[i+5] := '';                                                                                                        // ora|and|eor STACKORIGIN+10 ; 7
        listing[i+6] := '';
        listing[i+4] := copy(listing[i+7], 1, 5) + copy(listing[i+4], 6, 256);
        listing[i+7] := '';

        Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (pos(#9'tay', listing[i]) > 0)) and
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and         // tay|ldy A                  ; 0
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and         // lda adr.???,y              ; 1
       (pos('lda STACK', listing[i+5]) > 0) and                                                 // sta STACKORIGIN            ; 2
       ((pos('add ', listing[i+6]) > 0) or (pos('sub ', listing[i+6]) > 0)) and                 // lda adr.???+1,y            ; 3
       (pos('sta ', listing[i+7]) > 0) and (pos('lda STACK', listing[i+8]) > 0) and             // sta STACKORIGIN+STACKWIDTH ; 4
       ((pos('adc ', listing[i+9]) > 0) or (pos('sbc ', listing[i+9]) > 0)) then                // lda STACKORIGIN            ; 5
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and                           // add|sub                    ; 6
        (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then begin                    // sta                        ; 7
        listing[i+2] := '';                                                                     // lda STACKORIGIN+STACKWIDTH ; 8
        listing[i+5] := listing[i+1];                                                           // adc|sbc                    ; 9
        listing[i+8] := listing[i+3];
        listing[i+1] := '';
        listing[i+3] := '';
        listing[i+4] := '';

        Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (pos(#9'tay', listing[i]) > 0)) and
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and         // tay|ldy A                  ; 0
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and         // lda adr.???,y              ; 1
       (pos('lda ', listing[i+5]) > 0) and                                                      // sta STACKORIGIN            ; 2
       ((pos('add STACK', listing[i+6]) > 0) or (pos('sub STACK', listing[i+6]) > 0)) and       // lda adr.???+1,y            ; 3
       (pos('sta ', listing[i+7]) > 0) and (pos('lda ', listing[i+8]) > 0) and                  // sta STACKORIGIN+STACKWIDTH ; 4
       ((pos('adc STACK', listing[i+9]) > 0) or (pos('sbc STACK', listing[i+9]) > 0)) then      // lda                        ; 5
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and                           // add|sub STACKORIGIN        ; 6
        (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then begin                    // sta                        ; 7
        listing[i+2] := '';                                                                     // lda                        ; 8
        listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i+1], 6, 256);                  // adc|sbc STACKORIGIN+STAWCKWIDTH ; 9
        listing[i+9] := copy(listing[i+9], 1, 5) + copy(listing[i+3], 6, 256);
        listing[i+1] := '';
        listing[i+3] := '';
        listing[i+4] := '';
        Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (pos(#9'tay', listing[i]) > 0)) and
       (pos('lda adr.', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and         // tay|ldy A		  ; 0
       (pos('lda adr.', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and         // lda adr.???,y	  ; 1
       (pos('lda STACK', listing[i+5]) > 0) and                                                 // sta STACKORIGIN+9	  ; 2
       ((pos('add STACK', listing[i+6]) > 0) or (pos('sub STACK', listing[i+6]) > 0)) and       // lda adr.???+1,y	  ; 3
       (pos('sta ', listing[i+7]) > 0) and							// sta STACKORIGIN+10	  ; 4
       ((pos('adc STACK', listing[i+9]) = 0) and (pos('sbc STACK', listing[i+9]) = 0)) then     // lda STACKORIGIN+9	  ; 5
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and				// add|sub STACKORIGIN+10 ; 6
	(copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) then				// sta			  ; 7
      begin
        listing[i+5] := copy(listing[i+5], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i+3], 6, 256);
        listing[i+1] := '';
	listing[i+2] := '';
        listing[i+3] := '';
        listing[i+4] := '';
        Result:=false;
      end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda			  ; 0
       (pos('lda STACK', listing[i+2]) > 0) and							// sta STACKORIGIN+10	  ; 1
       ((pos('add STACK', listing[i+3]) > 0) or (pos('sub STACK', listing[i+3]) > 0)) then	// lda STACKORIGIN+9	  ; 2
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin               	// add|sub STACKORIGIN+10 ; 3
        listing[i+3] := copy(listing[i+3], 1, 5) + copy(listing[i], 6, 256);
        listing[i]   := '';
        listing[i+1] := '';
        Result:=false;
     end;


    if ((pos('ldy ', listing[i]) > 0) or (pos(#9'tay', listing[i]) > 0)) and
       (pos('lda adr.', listing[i+1]) > 0) and							// tay|ldy B          ; 0
       (pos('sta STACK', listing[i+2]) > 0) and (pos('ldy ', listing[i+3]) > 0) and		// lda adr.MY,y       ; 1
       (pos('lda adr.', listing[i+4]) > 0) and (pos(#9'tay', listing[i+5]) > 0) then		// sta STACKORIGIN+9  ; 2
     if (listing[i] = listing[i+3]) and (listing[i+1] = listing[i+4]) then begin		// ldy B              ; 3
        listing[i+3] := '';									// lda adr.MY,y       ; 4
        listing[i+4] := '';									// tay                ; 5
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos(#9'iny', listing[i+1]) > 0) and		// sta STACKORIGIN	; 0
       (pos('lda STACK', listing[i+2]) > 0) then						// iny			; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin			// lda STACKORIGIN	; 2
        listing[i]   := '';
        listing[i+1] := '';
        listing[i+2] := '';
        Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===			SPL. konwersja liczby ze znakiem	  	  === //
// -----------------------------------------------------------------------------

    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda #$', listing[i+1]) > 0) and		// ldy #$00	; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) then		// lda #$	; 1
     begin											// spl		; 2
       val(copy(listing[i+1], 7, 256), p, err);							// dey		; 3

       listing[i+2] := '';
       listing[i+3] := '';

       if p > 127 then listing[i] := #9'ldy #$FF';

       Result:=false;
     end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('sty #$00', listing[i+1]) > 0) then		// sty STACK	; 0
     begin											// sty #$00	; 1
       listing[i+1] := '';
       Result:=false;
     end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda			; 1
       (pos('sta STACKORIGIN', listing[i+4]) > 0) and						// spl			; 2
       (pos('sty #$00', listing[i+5]) > 0) then							// dey			; 3
     begin											// sta STACKORIGIN	; 4
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


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda			; 1
       (pos('sty #$00', listing[i+4]) > 0) and							// spl			; 2
       (pos('sta STACKORIGIN', listing[i+5]) > 0) then						// dey			; 3
     begin											// sty #$00		; 4
       listing[i]   := '';									// sta STACKORIGIN	; 5
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       Result:=false;
     end;


     if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda A		; 1
       (pos('sty #$00', listing[i+4]) > 0) and							// spl			; 2
       ((pos('add ', listing[i+5]) > 0) or (pos('sub ', listing[i+5]) > 0)) then		// dey			; 3
     begin											// sty #$00		; 4
      listing[i]   := '';									// add|sub		; 5
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      Result:=false;
     end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda A		; 1
       (pos('sty #$00', listing[i+4]) > 0) and							// spl			; 2
       ((pos('lda ', listing[i+5]) > 0) or (pos('sta ', listing[i+5]) > 0)) then		// dey			; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then begin			// sty #$00		; 4
      listing[i]   := '';									// lda|sta A		; 5
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';
      Result:=false;
     end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda			; 1
       (pos('sta ', listing[i+4]) > 0) and (pos('sty ', listing[i+5]) = 0) then			// spl			; 2
     begin											// dey			; 3
        listing[i]   := '';									// sta			; 4
        listing[i+2] := '';									// <> sty		; 5
        listing[i+3] := '';
        Result:=false;
     end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda			; 1
       (pos('sta #$00', listing[i+4]) > 0) then							// spl			; 2
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


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// ldy #$00		  ; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda			  ; 1
       (pos('sty STACK', listing[i+4]) > 0) and (pos('sta #$00', listing[i+5]) > 0) then	// spl			  ; 2
     begin											// dey			  ; 3
        listing[i+5] := '';									// sty STACKORIGIN+STACKW ; 4
        Result:=false;										// sta #$00		  ; 5
     end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) and		// ldy #$00               ; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda STACKORIGIN+9      ; 1
       (pos('sty STACK', listing[i+4]) > 0) and							// spl                    ; 2
       ((pos('sta STACK', listing[i+5]) > 0) or (pos('lda STACK', listing[i+5]) > 0)) then	// dey                    ; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then begin			// sty STACKORIGIN+STACKW ; 4
        listing[i+5] := '';									// lda|sta STACKORIGIN+9  ; 5
        Result:=false;
     end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) and		// ldy #$00               ; 0
       (pos(#9'spl', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) and		// lda STACKORIGIN+9      ; 1
       (pos('lda STACK', listing[i+4]) > 0) then						// spl                    ; 2
     if listing[i+1] = listing[i+4] then begin							// dey                    ; 3
        listing[i]   := '';									// lda STACKORIGIN+9      ; 4
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';
        Result:=false;
     end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and		// sty STACKORIGIN	  ; 0
       (pos('sta ', listing[i+2]) > 0) and (pos('lda STACK', listing[i+3]) > 0) then		// add			  ; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin			// sta			  ; 2
        listing[i]   := '';									// lda STACKORIGIN	  ; 3
        listing[i+3] := #9'tya';
        Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===                        optymalizacja BP2.                          === //
// -----------------------------------------------------------------------------


    if (pos('lda ', listing[i]) > 0) and							// lda 			; 0
       (pos('add #$00', listing[i+1]) > 0) and							// add #$00		; 1
       (pos(#9'tay', listing[i+2]) > 0) and 							// tay			; 2
       (pos('lda ', listing[i+3]) > 0) and							// lda			; 3
       (pos('adc #$00', listing[i+4]) > 0) and 							// adc #$00		; 4
       (pos('sta bp+1', listing[i+5]) > 0) then 						// sta bp+1		; 5
       begin
	listing[i] := #9'ldy ' + copy(listing[i], 6, 256);
        listing[i+1] := '';
	listing[i+2] := '';
	listing[i+4] := '';

	Result:=false;
       end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta bp+1', listing[i+1]) > 0) and		// lda #		; 0
       (pos('ldy #', listing[i+2]) > 0) and (pos('lda ', listing[i+3]) > 0) and			// sta bp+1		; 1
       (pos('sta (bp),y', listing[i+4]) > 0) then 						// ldy #		; 2
       begin											// lda			; 3
												// sta (bp),y		; 4
        p := GetVAL(copy(listing[i], 6, 256)) shl 8 + GetVAL(copy(listing[i+2], 6, 256));

	listing[i+4] := #9'sta $'+IntToHex(p, 4);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and		// sta STACKORIGIN+9			; 1
       (pos('mwa ', listing[i+4]) > 0) and (pos(' bp2', listing[i+4]) > 0) and			// lda 					; 2
       (pos('ldy #$00', listing[i+5]) > 0) and 							// sta STACKORIGIN+STACKWIDTH+9		; 3
       (pos('lda STACK', listing[i+6]) > 0) and	(pos('sta (bp2),y', listing[i+7]) > 0) and	// mwa X bp2				; 4
       (pos(#9'iny', listing[i+8]) > 0) and							// ldy #$00				; 5
       (pos('lda STACK', listing[i+9]) > 0) then 						// lda  STACKORIGIN+9			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// sta (bp2),y				; 7
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) then				// iny					; 8
       begin											// lda STACKORIGIN+STACKWIDTH+9		; 9
	listing[i+6] := listing[i];
	listing[i+9] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and		// sta STACKORIGIN+9			; 1
       (pos('mwa ', listing[i+4]) > 0) and (pos(' bp2', listing[i+4]) > 0) and			// lda 					; 2
       (pos('ldy #$00', listing[i+5]) > 0) and 							// sta STACKORIGIN+STACKWIDTH+9		; 3
       (pos('lda ', listing[i+6]) > 0) and (pos('sta (bp2),y', listing[i+7]) > 0) and		// mwa X bp2				; 4
       (pos(#9'iny', listing[i+8]) > 0) and							// ldy #$00				; 5
       (pos('lda ', listing[i+9]) > 0) and (pos('sta (bp2),y', listing[i+10]) > 0) and 		// lda					; 6
       (pos(#9'iny', listing[i+11]) > 0) and							// sta (bp2),y				; 7
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta (bp2),y', listing[i+13]) > 0) and 	// iny					; 8
       (pos(#9'iny', listing[i+14]) > 0) and							// lda					; 9
       (pos('lda STACK', listing[i+15]) > 0) and (pos('sta (bp2),y', listing[i+16]) > 0) then 	// sta (bp2),y				; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and				// iny					; 11
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) then				// lda STACKORIGIN+9			; 12
       begin											// sta (bp2),y				; 13
	listing[i+12] := listing[i];								// iny					; 14
	listing[i+15] := listing[i+2];								// lda STACKORIGIN+STACKWIDTH+9		; 15

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('ldy #$00', listing[i]) > 0) and (pos('lda (bp2),y', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos(#9'iny', listing[i+3]) > 0) and (pos('lda (bp2),y', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos(#9'iny', listing[i+6]) > 0) and (pos('lda (bp2),y', listing[i+7]) > 0) and (pos('sta STACK', listing[i+8]) > 0) and
       (pos(#9'iny', listing[i+9]) > 0) and (pos('lda (bp2),y', listing[i+10]) > 0) and (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda ', listing[i+12]) > 0) and (pos('add STACK', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) and
       (pos('lda ', listing[i+15]) > 0) and (pos('adc STACK', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda ', listing[i+18]) > 0) and (pos('adc STACK', listing[i+19]) > 0) and (pos('sta ', listing[i+20]) > 0) and
       (pos('lda ', listing[i+21]) > 0) and (pos('adc STACK', listing[i+22]) > 0) and (pos('sta ', listing[i+23]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
        (copy(listing[i+8], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+22], 6, 256)) then begin
{
	ldy #$00			; 0
	lda (bp2),y			; 1
	sta STACKORIGIN+10		; 2
	iny				; 3
	lda (bp2),y			; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	iny				; 6
	lda (bp2),y			; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	iny				; 9
	lda (bp2),y			; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	lda SCRL			; 12
	add STACKORIGIN+10		; 13
	sta X				; 14
	lda SCRL+1			; 15
	adc STACKORIGIN+STACKWIDTH+10	; 16
	sta X+1				; 17
	lda SCRL+2			; 18
	adc STACKORIGIN+STACKWIDTH*2+10	; 19
	sta X+2				; 20
	lda SCRL+3			; 21
	adc STACKORIGIN+STACKWIDTH*3+10	; 22
	sta X+3				; 23
}
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

	listing[i+13] := #9'add (bp2),y+';
	listing[i+16] := #9'adc (bp2),y+';
	listing[i+19] := #9'adc (bp2),y+';
	listing[i+22] := #9'adc (bp2),y';

        Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===                        optymalizacja ORA.                          === //
// -----------------------------------------------------------------------------

    if (pos('lda ', listing[i]) > 0) and (pos('ora #$00', listing[i+1]) > 0) and		// lda			; 0
       (pos('sta ', listing[i+2]) > 0) then							// ora #$00		; 1
     begin											// sta			; 2
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda #$00', listing[i]) > 0) and (pos('ora ', listing[i+1]) > 0) and		// lda #$00		; 0
       (pos('sta ', listing[i+2]) > 0) then							// ora 			; 1
     begin											// sta			; 2
        listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256) ;
	listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and 							// sta STACKORIGIN+10	; 0
       (pos('lda ', listing[i+1]) > 0) and 							// lda 			; 1
       (pos('ora STACK', listing[i+2]) > 0) then						// ora STACKORIGIN+10	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
        listing[i] := '';
	listing[i+2] := '';
	listing[i+1] := #9'ora ' + copy(listing[i+1], 6, 256) ;
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and	// sta STACKORIGIN+9			; 1
       (pos('lda STACK', listing[i+3]) > 0) and							// sta STACKORIGIN+STACKWIDTH+9		; 2
       (pos('ora ', listing[i+4]) > 0) and 							// lda STACKORIGIN+9			; 3
       (pos('sta ', listing[i+5]) > 0) and							// ora					; 4
       (pos('lda STACK', listing[i+6]) > 0) and							// sta					; 5
       (pos('ora ', listing[i+7]) > 0) then 							// lda  STACKORIGIN+STACKWIDTH+9	; 6
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


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('ora STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('ora STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('ora STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('ora STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda eax				; 0
	sta STACKORIGIN+10		; 1
	lda eax+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda eax+2			; 4
	sta STACKORIGIN+STACKWIDTH*2+10	; 5
	lda eax+3			; 6
	sta STACKORIGIN+STACKWIDTH*3+10	; 7
	lda ERROR			; 8
	ora STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	ora STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	ora STACKORIGIN+STACKWIDTH*2+10	; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	ora STACKORIGIN+STACKWIDTH*3+10	; 18
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


// -----------------------------------------------------------------------------
// ===                        optymalizacja EOR.                          === //
// -----------------------------------------------------------------------------


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('eor STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('eor STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('eor STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('eor STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda eax				; 0
	sta STACKORIGIN+10		; 1
	lda eax+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda eax+2			; 4
	sta STACKORIGIN+STACKWIDTH*2+10	; 5
	lda eax+3			; 6
	sta STACKORIGIN+STACKWIDTH*3+10	; 7
	lda ERROR			; 8
	eor STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	eor STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	eor STACKORIGIN+STACKWIDTH*2+10	; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	eor STACKORIGIN+STACKWIDTH*3+10	; 18
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
// ===                        optymalizacja ADD.                          === //
// -----------------------------------------------------------------------------


    if (l = 3) and (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and	// lda X 	; 0
       (pos('add #$01', listing[i+1]) > 0) and (pos(',y', listing[i]) = 0) and		// add #$01	; 1
       (pos('sta ', listing[i+2]) > 0) and (pos(',y', listing[i+2]) = 0) then		// sta Y	; 2
     if copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256) then
     begin
        listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
        listing[i+1] := #9'iny';
        listing[i+2] := #9'sty '+copy(listing[i+2], 6, 256);
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and						// sta STACKORIGIN+9	; 0
       (pos('lda STACK', listing[i+1]) > 0) and						// lda STACKORIGIN+10	; 1
       (pos('add STACK', listing[i+2]) > 0) then					// add STACKORIGIN+9	; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
        listing[i]   := #9'add ' + copy(listing[i+1], 6, 256);
        listing[i+1] := '';
        listing[i+2] := '';

        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and						// sta STACKORIGIN+9	; 0
       (pos('add STACK', listing[i+1]) > 0) and						// add STACKORIGIN+9	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta			; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin
        listing[i]   := #9'add ' + copy(listing[i+2], 6, 256);
        listing[i+1] := '';
        Result:=false;
     end;


    if (l = 3) and
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda W
       (pos('add #$01', listing[i+1]) > 0) then						// add #$01
       if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then			// sta W
       begin
	listing[i]   := #9'inc '+copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	Result := false;
       end;


    if (pos(#9'clc', listing[i]) > 0) and						// clc		; 0
       (pos('lda ', listing[i+1]) > 0) and 						// lda		; 1
       (pos('adc ', listing[i+2]) > 0) then						// adc		; 2
       begin
	listing[i]   := '';
	listing[i+2] := #9'add ' + copy(listing[i+2], 6, 256);

	Result := false;
       end;


    if (pos(#9'clc', listing[i]) > 0) and						// clc		; 0
       (pos('lda ', listing[i+1]) > 0) and						// lda		; 1
       (pos('add ', listing[i+2]) > 0) then						// add		; 2
     begin
        listing[i] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 						// lda		; 0	!!! zadziala tylko dla ADD|ADC !!!
       (pos('add #$00', listing[i+1]) > 0) and						// add #$00	; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta		; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda		; 3
       (pos('adc ', listing[i+4]) > 0) then						// adc		; 4
     begin
      listing[i+1] := '';
      listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);
      Result:=false;
     end;


    if (pos('lda #$00', listing[i]) > 0) and						// lda #$00	; 0	!!! zadziala tylko dla ADD|ADC !!!
       (pos('add ', listing[i+1]) > 0) and						// add		; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta		; 2
       (pos('lda ', listing[i+3]) > 0) and 						// lda 		; 3
       (pos('adc ', listing[i+4]) > 0) then						// adc		; 4
     begin
        listing[i]   := '';
        listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);
        Result:=false;
     end;


    if Result and
       (pos('lda ', listing[i]) > 0) and 						// lda		; 0
       (pos('add #$00', listing[i+1]) > 0) and						// add #$00	; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta		; 2
//       (pos('lda ', listing[i+3]) = 0) and						// ~lda		; 3
       (pos('adc ', listing[i+4]) = 0) then						// ~adc		; 4
     begin
      listing[i+1] := '';
      Result:=false;
     end;


    if Result and
       (pos('lda #$00', listing[i]) > 0) and 						// lda #$00	; 0
       (pos('add ', listing[i+1]) > 0) and						// add		; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta		; 2
//       (pos('lda ', listing[i+3]) = 0) and						// ~lda		; 3
       (pos('adc ', listing[i+4]) = 0) then						// ~adc		; 4
     begin
      listing[i] := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);;
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and							// lda					; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and	// sta STACKORIGIN+9			; 1
       (pos('lda ', listing[i+3]) > 0) and							// sta STACKORIGIN+STACKWIDTH+9		; 2
       ((pos('add STACK', listing[i+4]) > 0) or (pos('sub STACK', listing[i+4]) > 0)) and 	// lda 					; 3
       (pos('sta ', listing[i+5]) > 0) and							// add|sub STACKORIGIN+9		; 4
       (pos('lda ', listing[i+6]) > 0) and							// sta					; 5
       ((pos('adc STACK', listing[i+7]) > 0) or (pos('sbc STACK', listing[i+7]) > 0)) then 	// lda 					; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// adc|sbc STACKORIGIN+STACKWIDTH+9	; 7
	(copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+4] := copy(listing[i+4], 1, 5) + copy(listing[i], 6, 256);
	listing[i+7] := copy(listing[i+7], 1, 5) + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and							// lda				; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and	// sta STACKORIGIN+9		; 1
       (pos('lda STACK', listing[i+3]) > 0) and							// sta STACKORIGIN+STACKWIDTH+9	; 2
       ((pos('add ', listing[i+4]) > 0) or (pos('sub ', listing[i+4]) > 0)) and 		// lda STACKORIGIN+9		; 3
       (pos('sta ', listing[i+5]) > 0) and							// add|sub			; 4
       (pos('lda STACK', listing[i+6]) > 0) and							// sta				; 5
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) then 		// lda STACKORIGIN+STACKWIDTH+9	; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and				// adc|sbc 			; 7
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+3] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false;
       end;


{ !!! ta optymalizacja powoduje straty !!! bardzo nieefektywna

    if (pos('rol ', listing[i]) > 0) and						// rol				; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos('lda STACK', listing[i+2]) > 0) and// sta STACKORIGIN+STACKWIDTH+9	; 1
       ((pos('add ', listing[i+3]) > 0) or (pos('sub ', listing[i+3]) > 0)) and		// lda STACKORIGIN+9		; 2
       (pos('sta ', listing[i+4]) > 0) and (pos(',y', listing[i+4]) = 0) and		// add|sub			; 3
       (pos('lda STACK', listing[i+5]) > 0) and						// sta				; 4
       ((pos('adc ', listing[i+6]) > 0) or (pos('sbc ', listing[i+6]) > 0)) and		// lda STACKORIGIN+STACKWIDTH+9	; 5
       (pos('sta ', listing[i+7]) > 0) and (pos(',y', listing[i+7]) = 0) then		// adc|sbc			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then			// sta				; 7
       begin
	listing[i+1] := #9'tay';
	listing[i+5] := #9'tya';
	Result:=false;
       end;
}

    if (pos('lda ', listing[i]) > 0) and						// lda			; 0
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and		// add|sub		; 1
       (pos('sta STACK', listing[i+2]) > 0) and						// sta STACKORIGIN+10	; 2
       (pos('lda ', listing[i+3]) > 0) and 						// lda			; 3
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and		// adc|sbc		; 4
       (pos('sta bp+1', listing[i+5]) > 0) and						// sta bp+1		; 5
       (pos('ldy STACK', listing[i+6]) > 0) and 					// ldy STACKORIGIN+10	; 6
       (pos('lda ', listing[i+7]) > 0) and 	 					// lda 			; 7
       (pos('sta (bp),y', listing[i+8]) > 0) then	 				// sta (bp),y		; 8
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+2]  := #9'tay';
	listing[i+6]  := '';
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and						// lda			; 0
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and		// add|sub		; 1
       (pos('sta STACK', listing[i+2]) > 0) and						// sta STACKORIGIN+10	; 2
       (pos('lda ', listing[i+3]) > 0) and 						// lda			; 3
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and		// adc|sbc		; 4
       (pos('sta bp+1', listing[i+5]) > 0) and						// sta bp+1		; 5
       (pos('ldy STACK', listing[i+6]) > 0) and 					// ldy STACKORIGIN+10	; 6
       (pos('lda (bp),y', listing[i+7]) > 0) then 					// lda (bp),y		; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+2]  := #9'tay';
	listing[i+6]  := '';
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and
       (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and
       ((pos('add ', listing[i+5]) > 0) or (pos('sub ', listing[i+5]) > 0)) and
       (pos('sta STACK', listing[i+6]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and
       ((pos('adc ', listing[i+8]) > 0) or (pos('sbc ', listing[i+8]) > 0)) and
       (pos('sta STACK', listing[i+9]) > 0) and
       (pos('lda ', listing[i+10]) > 0) and
       ((pos('adc ', listing[i+11]) > 0) or (pos('sbc ', listing[i+11]) > 0)) and
       (pos('sta STACK', listing[i+12]) > 0) and
       (pos('lda ', listing[i+13]) > 0) and
       ((pos('adc ', listing[i+14]) > 0) or (pos('sbc ', listing[i+14]) > 0)) and
       (pos('sta STACK', listing[i+15]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+13], 6, 256)) then
       begin
{
	lda GD				; 0
	sta STACKORIGIN+STACKWIDTH*2+10	; 1
	lda GD+1			; 2
	sta STACKORIGIN+STACKWIDTH*3+10	; 3
	lda #$00			; 4
	add GM				; 5
	sta STACKORIGIN+10		; 6
	lda #$00			; 7
	adc GM+1			; 8
	sta STACKORIGIN+STACKWIDTH+10	; 9
	lda STACKORIGIN+STACKWIDTH*2+10	; 10
	adc #$00			; 11
	sta STACKORIGIN+STACKWIDTH*2+10	; 12
	lda STACKORIGIN+STACKWIDTH*3+10	; 13
	adc #$00			; 14
	sta STACKORIGIN+STACKWIDTH*3+10	; 15
}
	listing[i+10] := listing[i];
	listing[i+13] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and
       ((pos('add ', listing[i+10]) > 0) or (pos('sub ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and
       ((pos('adc ', listing[i+13]) > 0) or (pos('sbc ', listing[i+13]) > 0)) and
       (pos('sta STACK', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and
       ((pos('adc ', listing[i+16]) > 0) or (pos('sbc ', listing[i+16]) > 0)) and
       (pos('sta STACK', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) > 0) and
       ((pos('adc ', listing[i+19]) > 0) or (pos('sbc ', listing[i+19]) > 0)) and
       (pos('sta STACK', listing[i+20]) > 0) then
     if (copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+12], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+18], 6, 256) = copy(listing[i+20], 6, 256)) and
        (listing[i+2] = listing[i+11]) and
        (listing[i+5] = listing[i+14]) and
        (listing[i+8] = listing[i+17]) then
       begin
{
	lda P				; 0
	add #$04			; 1
	sta STACKORIGIN+9		; 2
	lda P+1				; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda #$00			; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda STACKORIGIN+9		; 9
	add H				; 10
	sta STACKORIGIN+9		; 11
	lda STACKORIGIN+STACKWIDTH+9	; 12
	adc #$00			; 13
	sta STACKORIGIN+STACKWIDTH+9	; 14
	lda STACKORIGIN+STACKWIDTH*2+9	; 15
	adc #$00			; 16
	sta STACKORIGIN+STACKWIDTH*2+9	; 17
	lda STACKORIGIN+STACKWIDTH*3+9	; 18
	adc #$00			; 19
	sta STACKORIGIN+STACKWIDTH*3+9	; 20
}
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';

	Result:=false;
       end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and		// sty STACKORIGIN+10	; 0
       (pos('sta ', listing[i+2]) > 0) and (pos('lda ', listing[i+3]) > 0) and			// add			; 1
       (pos('adc STACK', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) then		// sta			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then				// lda			; 3
       begin											// adc STACKORIGIN+10	; 4
												// sta			; 5
	listing[i]   := '';
	listing[i+4] := #9'adc ' + copy(listing[i+3], 6, 256);
	listing[i+3] := #9'tya';
	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda 					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and		// sta STACKORIGIN+10			; 1
       (pos('lda STACK', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and		// lda					; 2
       (pos('sta STACK', listing[i+6]) > 0) then						// sta STACKORIGIN+STACKWIDTH+10	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				// lda STACKORIGIN+10			; 4
        (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and				// add  				; 5
	(copy(listing[i+3], 6, 256) <> copy(listing[i+7], 6, 256)) then				// sta STACKORIGIN+10			; 6
       begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	Result:=false;
       end;


    if (pos('lda STACK', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda STACK', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and
       ((pos('add ', listing[i+13]) > 0) or (pos('sub ', listing[i+13]) > 0)) and
       (pos('sta STACK', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) = 0) and (pos('adc ', listing[i+16]) = 0) then
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
        (listing[i] = listing[i+12]) and
        (listing[i+2] = listing[i+14]) and
        (listing[i+3] <> listing[i+15]) then
       begin
{
	lda STACKORIGIN+10		; 0
	add STACKORIGIN+11		; 1
	sta STACKORIGIN+10		; 2
	lda STACKORIGIN+STACKWIDTH+10	; 3
	adc STACKORIGIN+STACKWIDTH+11	; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda STACKORIGIN+STACKWIDTH*2+10	; 6
	adc STACKORIGIN+STACKWIDTH*2+11	; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda STACKORIGIN+STACKWIDTH*3+10	; 9
	adc STACKORIGIN+STACKWIDTH*3+11	; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	lda STACKORIGIN+10		; 12
	add #$37			; 13
	sta STACKORIGIN+10		; 14
}
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


    if (pos('lda STACK', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda STACK', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda ', listing[i+12]) > 0) and (pos('sta bp+1', listing[i+13]) > 0) and
       (pos('ldy ', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and (pos('sta (bp),y', listing[i+16]) > 0) then
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+15], 6, 256)) then
       begin
{
	lda STACKORIGIN+10		; 0
	add STACKORIGIN+11		; 1
	sta STACKORIGIN+10		; 2
	lda STACKORIGIN+STACKWIDTH+10	; 3
	adc STACKORIGIN+STACKWIDTH+11	; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda STACKORIGIN+STACKWIDTH*2+10	; 6
	adc STACKORIGIN+STACKWIDTH*2+11	; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda STACKORIGIN+STACKWIDTH*3+10	; 9
	adc STACKORIGIN+STACKWIDTH*3+11	; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	lda STACKORIGIN+STACKWIDTH+9	; 12
	sta bp+1			; 13
	ldy STACKORIGIN+9		; 14
	lda STACKORIGIN+10		; 15
	sta (bp),y			; 16
}
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


    if (pos('lda STACK', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda STACK', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta bp+1', listing[i+13]) > 0) and
       (pos('ldy STACK', listing[i+14]) > 0) and
       (pos('lda ', listing[i+15]) > 0) and (pos('sta (bp),y', listing[i+16]) > 0) then
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
{
	lda STACKORIGIN+9		; 0
	add #$40			; 1
	sta STACKORIGIN+9		; 2
	lda STACKORIGIN+STACKWIDTH+9	; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda STACKORIGIN+STACKWIDTH*2+9	; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda STACKORIGIN+STACKWIDTH*3+9	; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+9	; 11
	lda STACKORIGIN+STACKWIDTH+9	; 12
	sta bp+1			; 13
	ldy STACKORIGIN+9		; 14
	lda #$70			; 15
	sta (bp),y			; 16
}
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('add #$01', listing[i+1]) > 0) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('adc #$00', listing[i+4]) > 0) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('add STACK', listing[i+7]) > 0) and (pos(#9'tay', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('adc STACK', listing[i+10]) > 0) and (pos('sta bp+1', listing[i+11]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
{
	lda P				; 0
	add #$01			; 1
	sta STACKORIGIN+11		; 2
	lda P+1				; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+11	; 5
	lda LEVELDATA			; 6
	add STACKORIGIN+11		; 7
	tay				; 8
	lda LEVELDATA+1			; 9
	adc STACKORIGIN+STACKWIDTH+11	; 10
	sta bp+1			; 11
}
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


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) and
       (pos(#9'clc', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('adc STACK', listing[i+10]) > 0) and
       (pos('sta ', listing[i+11]) > 0) and
       (pos('lda ', listing[i+12]) > 0) and (pos('adc STACK', listing[i+13]) > 0) and
       (pos('sta ', listing[i+14]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+13], 6, 256)) then
       begin
{
	lda XR				; 0
	sta STACKORIGIN+STACKWIDTH*2+11	; 1
	lda XR+1			; 2
	sta STACKORIGIN+STACKWIDTH*3+11	; 3
	lda YR				; 4
	sta 				; 5
	lda YR+1			; 6
	sta 				; 7
	clc				; 8
	lda #$00			; 9
	adc STACKORIGIN+STACKWIDTH*2+11	; 10
	sta				; 11
	lda #$00			; 12
	adc STACKORIGIN+STACKWIDTH*3+11	; 13
	sta				; 14
}
	listing[i+10] := #9'adc ' + copy(listing[i], 6, 256);
	listing[i+13] := #9'adc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and (pos('ldy ', listing[i+12]) > 0) and
       (pos('lda STACK', listing[i+13]) > 0) and (pos('sta adr.', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and (pos('sta adr.', listing[i+16]) > 0) and
       (pos('lda STACK', listing[i+17]) = 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) then
       begin
{
	lda STACKORIGIN+10		; 0
	add #				; 1
	sta STACKORIGIN+10		; 2
	lda STACKORIGIN+STACKWIDTH+10	; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda STACKORIGIN+STACKWIDTH*2+10	; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda STACKORIGIN+STACKWIDTH*3+10	; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
	ldy STACKORIGIN+9		; 12
	lda STACKORIGIN+10		; 13
	sta adr.SPAWNERS,y		; 14
	lda STACKORIGIN+STACKWIDTH+10	; 15
	sta adr.SPAWNERS+1,y		; 16
}
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('ldy STACK', listing[i+6]) > 0) and
       (pos(' adr.', listing[i+7]) > 0) and
       (listing[i+8] = '') then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
{
	lda STACKORIGIN+9		; 0
	add #$01			; 1
	sta STACKORIGIN+9		; 2
	lda STACKORIGIN+STACKWIDTH+9	; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	ldy STACKORIGIN+9		; 6
	mva V adr.BUF,y			; 7
}
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('ora ', listing[i+7]) > 0) or (pos('and ', listing[i+7]) > 0) or (pos('eor ', listing[i+7]) > 0)) and
       (pos('ldy STACK', listing[i+8]) > 0) and
       (pos(' adr.', listing[i+9]) > 0) and
       (listing[i+10] = '') then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
{
       	lda STACKORIGIN+9		; 0
	add #$01			; 1
	sta STACKORIGIN+9		; 2
	lda STACKORIGIN+STACKWIDTH+9	; 3
	adc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda V				; 6
	and #$0F			; 7
	ldy STACKORIGIN+9		; 8
	sta adr.BUF,y			; 9
}
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[i+2] := #9'tay';
	listing[i+8] := '';

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and
       ((pos('add ', listing[i+1]) > 0) or (pos('sub ', listing[i+1]) > 0)) and
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and
       ((pos('adc ', listing[i+4]) > 0) or (pos('sbc ', listing[i+4]) > 0)) and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and
       ((pos('adc ', listing[i+7]) > 0) or (pos('sbc ', listing[i+7]) > 0)) and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and
       ((pos('adc ', listing[i+10]) > 0) or (pos('sbc ', listing[i+10]) > 0)) and
       (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta bp2', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta bp2+1', listing[i+15]) > 0) and
       (pos('ldy #$00', listing[i+16]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
{
	lda STACKORIGIN+9		; 0
	add STACKORIGIN+11		; 1
	sta STACKORIGIN+9		; 2
	lda STACKORIGIN+STACKWIDTH+9	; 3
	adc STACKORIGIN+STACKWIDTH+11	; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda STACKORIGIN+STACKWIDTH*2+9	; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda STACKORIGIN+STACKWIDTH*3+9	; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+9	; 11
	lda STACKORIGIN+9		; 12
	sta bp2				; 13
	lda STACKORIGIN+STACKWIDTH+9	; 14
	sta bp2+1			; 15
	ldy #$00			; 16
}
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


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda					; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+10			; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and	// lda 					; 2
       (pos('lda STACK', listing[i+6]) > 0) and						// sta STACKORIGIN+STACKWIDTH+10	; 3
       (pos('add ', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and		// lda 					; 4
       (pos('lda STACK', listing[i+9]) > 0) and						// sta STACKORIGIN+STACKWIDTH*2+10	; 5
       (pos('adc ', listing[i+10]) > 0) and (pos('sta ', listing[i+11]) > 0) and	// lda STACKORIGIN+10			; 6
       (pos('lda STACK', listing[i+12]) > 0) and					// add					; 7
       (pos('adc ', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) then	// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and			// lda STACKORIGIN+STACKWIDTH+10	; 9
        (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and			// adc 					; 10
        (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) then			// sta					; 11
       begin										// lda STACKORIGIN+STACKWIDTH*2+10	; 12
	listing[i+6]  := listing[i];							// adc					; 13
	listing[i+9]  := listing[i+2];							// sta					; 14
	listing[i+12] := listing[i+4];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	if (pos('lda STACKORIGIN+STACKWIDTH*3+', listing[i+15]) > 0) and
	   (pos('adc ', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) then
	begin
	 listing[i+15] := '';
	 listing[i+16] := '';
	 listing[i+17] := '';
	end;

	Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('add STACK', listing[i+1]) > 0) and			// lda					; 0
       (pos('sta STACK', listing[i+2]) > 0) and								// add STACKORIGIN+10			; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('adc STACK', listing[i+4]) > 0) and			// sta STACKORIGIN+9			; 2
       (pos('sta STACK', listing[i+5]) > 0) and								// lda					; 3
       (pos('mwa ', listing[i+6]) > 0) and (pos('bp2', listing[i+6]) > 0) and				// adc STACKORIGIN+STACKWIDTH+10	; 4
       (pos('ldy ', listing[i+7]) > 0) and								// sta STACKORIGIN+STACKWIDTH+9		; 5
       (pos('lda STACK', listing[i+8]) > 0) and (pos('sta (bp2),y', listing[i+9]) > 0) and		// mwa xxx bp2				; 6
       (pos(#9'iny', listing[i+10]) > 0) and								// ldy					; 7
       (pos('lda STACK', listing[i+11]) > 0) and (pos('sta (bp2),y', listing[i+12]) > 0) then		// lda STACKORIGIN+9			; 8
     if {(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and}					// sta (bp2),y				; 9
        (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and					// iny 					; 10
        {(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and}					// lda STACKORIGIN+STACKWIDTH+9 	; 11
        (copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then					// sta (bp2),y				; 12
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


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda (bp2),y			; 0
       (pos(#9'iny', listing[i+2]) > 0) and								// sta STACKORIGIN+9		; 1
       (pos('lda (bp2),y', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and		// iny				; 2
       (pos('lda ', listing[i+5]) > 0) and (pos('add STACK', listing[i+6]) > 0) and			// lda (bp2),y			; 3
       (pos('sta ', listing[i+7]) > 0) and								// sta STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+8]) > 0) and (pos('adc STACK', listing[i+9]) > 0) and			// lda 				; 5
       (pos('sta ', listing[i+10]) > 0) then								// add STACKORIGIN+9		; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and					// sta				; 7
        (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then					// lda 				; 8
        begin												// adc STACKORIGIN+STACKWIDTH+9	; 9
          listing[i]    := '';										// sta				; 10
	  listing[i+1]  := '';
	  listing[i+2]  := '';
	  listing[i+3]  := '';

	  listing[i+4] := listing[i+5];
	  listing[i+5] := #9'add (bp2),y';
	  listing[i+6] := #9'iny';

	  listing[i+9] := #9'adc (bp2),y';

          Result:=false;
	end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda (bp2),y			; 0
       (pos(#9'iny', listing[i+2]) > 0) and								// sta STACKORIGIN+9		; 1
       (pos('lda (bp2),y', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and		// iny				; 2
       (pos('lda STACK', listing[i+5]) > 0) and (pos('add ', listing[i+6]) > 0) and			// lda (bp2),y			; 3
       (pos('sta ', listing[i+7]) > 0) and								// sta STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda STACK', listing[i+8]) > 0) and (pos('adc ', listing[i+9]) > 0) and			// lda STACKORIGIN+9		; 5
       (pos('sta ', listing[i+10]) > 0) then								// add				; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and					// sta				; 7
        (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then					// lda STACKORIGIN+STACKWIDTH+9	; 8
        begin												// adc				; 9
          listing[i+1] := '';										// sta				; 10
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';

	  listing[i+8] := listing[i];

          Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and
       (pos('sta bp2', listing[i+6]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and (pos('adc', listing[i+8]) > 0) and
       (pos('sta bp2+1', listing[i+9]) > 0) and
       (pos('ldy #$00', listing[i+10]) > 0) and
       (pos('lda STACK', listing[i+11]) > 0) and (pos('sta (bp2),y', listing[i+12]) > 0) and
       (pos(#9'iny', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta (bp2),y', listing[i+15]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) then
	begin
{
	lda YR				; 0
	sta STACKORIGIN+10		; 1
	lda YR+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda FLOODFILLSTACK		; 4
	add STACKORIGIN+9		; 5
	sta bp2				; 6
	lda FLOODFILLSTACK+1		; 7
	adc STACKORIGIN+STACKWIDTH+9	; 8
	sta bp2+1			; 9
	ldy #$00			; 10
	lda STACKORIGIN+10		; 11
	sta (bp2),y			; 12
	iny				; 13
	lda STACKORIGIN+STACKWIDTH+10	; 14
	sta (bp2),y			; 15
}
	listing[i+11] := listing[i];
	listing[i+14] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and
       (pos('sta bp2', listing[i+6]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and (pos('adc', listing[i+8]) > 0) and
       (pos('sta bp2+1', listing[i+9]) > 0) and
       (pos('ldy #$00', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('sta (bp2),y', listing[i+12]) > 0) and
       (pos(#9'iny', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('sta (bp2),y', listing[i+15]) > 0) and
       (pos(#9'iny', listing[i+16]) > 0) and
       (pos('lda STACK', listing[i+17]) > 0) and (pos('sta (bp2),y', listing[i+18]) > 0) and
       (pos(#9'iny', listing[i+19]) > 0) and
       (pos('lda STACK', listing[i+20]) > 0) and (pos('sta (bp2),y', listing[i+21]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+17], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+20], 6, 256)) then
	begin
{
	lda XR				; 0
	sta STACKORIGIN+STACKWIDTH*2+10	; 1
	lda XR+1			; 2
	sta STACKORIGIN+STACKWIDTH*3+10	; 3
	lda FLOODFILLSTACK		; 4
	add STACKORIGIN+9		; 5
	sta bp2				; 6
	lda FLOODFILLSTACK+1		; 7
	adc STACKORIGIN+STACKWIDTH+9	; 8
	sta bp2+1			; 9
	ldy #$00			; 10
	lda YR				; 11
	sta (bp2),y			; 12
	iny				; 13
	lda YR+1			; 14
	sta (bp2),y			; 15
	iny				; 16
	lda STACKORIGIN+STACKWIDTH*2+10	; 17
	sta (bp2),y			; 18
	iny				; 19
	lda STACKORIGIN+STACKWIDTH*3+10	; 20
	sta (bp2),y			; 21
}
	listing[i+17] := listing[i];
	listing[i+20] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('add STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('adc STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('adc STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('adc STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda eax				; 0
	sta STACKORIGIN+10		; 1
	lda eax+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda eax+2			; 4
	sta STACKORIGIN+STACKWIDTH*2+10	; 5
	lda eax+3			; 6
	sta STACKORIGIN+STACKWIDTH*3+10	; 7
	lda ERROR			; 8
	add STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	adc STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	adc STACKORIGIN+STACKWIDTH*2+10	; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	adc STACKORIGIN+STACKWIDTH*3+10	; 18
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


    if (pos('lda ', listing[i]) > 0) and (pos('sta eax+2', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta eax+3', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('add eax', listing[i+5]) > 0) and (pos('sta ', listing[i+6]) > 0) and
       (pos('lda ', listing[i+7]) > 0) and (pos('adc eax+1', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) and
       (pos('lda ', listing[i+10]) = 0) and (pos('adc ', listing[i+11]) = 0) then
	begin
{
	lda #$00	; 0
	sta eax+2	; 1
	lda #$00	; 2
	sta eax+3	; 3
	lda #$80	; 4
	add eax		; 5
	sta W		; 6
	lda #$B0	; 7
	adc eax+1	; 8
	sta W+1		; 9
}
	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and
       (pos('lda STACK', listing[i+8]) > 0) and (pos('add ', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda STACK', listing[i+11]) > 0) and (pos('adc ', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('adc ', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda STACK', listing[i+17]) > 0) and (pos('adc ', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+17], 6, 256)) then
	begin
{
	lda eax				; 0
	sta STACKORIGIN+10		; 1
	lda eax+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda eax+2			; 4
	sta STACKORIGIN+STACKWIDTH*2+10	; 5
	lda eax+3			; 6
	sta STACKORIGIN+STACKWIDTH*3+10	; 7
	lda STACKORIGIN+10		; 8
	add 				; 9
	sta ERROR			; 10
	lda STACKORIGIN+STACKWIDTH+10	; 11
	adc 				; 12
	sta ERROR+1			; 13
	lda STACKORIGIN+STACKWIDTH*2+10	; 14
	adc 				; 15
	sta ERROR+2			; 16
	lda STACKORIGIN+STACKWIDTH*3+10	; 17
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


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+9		; 1
       (pos('lda STACK', listing[i+4]) > 0) and (pos('add ', listing[i+5]) > 0) and	// lda				; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda STACK', listing[i+7]) > 0) and	// sta STACKORIGIN+STACKWIDTH+9	; 3
       (pos('adc ', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then		// lda STACKORIGIN+9		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and			// add				; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then begin		// sta				; 6
        listing[i+4] := listing[i];							// lda STACKORIGIN+STACKWIDTH+9	; 7
        listing[i+7] := listing[i+2];							// adc				; 8
        listing[i]   := '';								// sta				; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda				; 0
       (pos('lda STACK', listing[i+2]) > 0) and (pos('add ', listing[i+3]) > 0) and	// sta STACKORIGIN+STACKWIDTH+9	; 1
       (pos('sta ', listing[i+4]) > 0) and (pos('lda STACK', listing[i+5]) > 0) and	// lda STACKORIGIN+9		; 2
       (pos('adc ', listing[i+6]) > 0) and (pos('sta ', listing[i+7]) > 0) then		// add				; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then			// sta				; 4
       begin										// lda STACKORIGIN+STACKWIDTH+9	; 5
        listing[i+5] := listing[i];							// adc				; 6
        listing[i]   := '';								// sta				; 7
        listing[i+1] := '';

        Result:=false;
       end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax', listing[i+1]) > 0) and	 // lda STACKORIGIN+9		  ; 0
       (pos('lda STACK', listing[i+2]) > 0) and (pos('sta eax+1', listing[i+3]) > 0) and // sta eax            		  ; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('add eax', listing[i+5]) > 0) and	 // lda STACKORIGIN+STACKWIDTH+9  ; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) > 0) and 		 // sta eax+1			  ; 3
       (pos('adc eax+1', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then     // lda 			  ; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and                    // add	eax			  ; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin             // sta 			  ; 6
        listing[i+5] := #9'add ' + copy(listing[i], 6, 256);                             // lda 			  ; 7
        listing[i+8] := #9'adc ' + copy(listing[i+2], 6, 256);                           // adc	eax+1			  ; 8
        listing[i]   := '';								 // sta 			  ; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('lda eax', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	 // lda eax			  ; 0
       (pos('lda eax+1', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and // sta STACKORIGIN+10		  ; 1
       (pos('lda STACK', listing[i+4]) > 0) and (pos('add STACK', listing[i+5]) > 0) and // lda eax+1			  ; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda STACK', listing[i+7]) > 0) and 	 // sta STACKORIGIN+STACKWIDTH+10 ; 3
       (pos('adc STACK', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then     // lda STACKORIGIN+9		  ; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and                    // add STACKORIGIN+10		  ; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin             // sta 			  ; 6
        listing[i+5] := #9'add ' + copy(listing[i], 6, 256);                             // lda STACKORIGIN+STACKWIDTH+9  ; 7
        listing[i+8] := #9'adc ' + copy(listing[i+2], 6, 256);                           // adc	STACKORIGIN+STACKWIDTH+10 ; 8
        listing[i]   := '';								 // sta 			  ; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax', listing[i+1]) > 0) and	 // lda STACKORIGIN+9		  ; 0
       (pos('lda STACK', listing[i+2]) > 0) and (pos('sta eax+1', listing[i+3]) > 0) and // sta eax            		  ; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('add eax', listing[i+5]) > 0) and	 // lda STACKORIGIN+STACKWIDTH+9  ; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) = 0) then		 // sta eax+1			  ; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then begin		 // lda 			  ; 4
	listing[i+5] := #9'add ' + copy(listing[i], 6, 256);		                 // add	eax			  ; 5
	listing[i]   := '';								 // sta 			  ; 6
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if ((pos('add ', listing[i]) > 0) or (pos('sub ', listing[i]) > 0)) and
       (pos('sta STACK', listing[i+1]) > 0) and	(pos('lda ', listing[i+2]) > 0) and	 // add                           0
       ((pos('adc ', listing[i+3]) > 0) or (pos('sbc ', listing[i+3]) > 0)) and	         // sta STACKORIGIN+9             1
       (pos('sta STACK', listing[i+4]) > 0) and                                          // lda                           2
       (pos('lda STACK', listing[i+5]) > 0) and (pos('sta ', listing[i+6]) > 0) and      // adc                           3
       (pos('lda STACK', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) then     // sta STACKORIGIN+STACKWIDTH+9  4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and                    // lda STACKORIGIN+9             5
        (copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then begin             // sta                           6
        listing[i+1] := listing[i+6];                                                    // lda STACKORIGIN+STACKWIDTH+9  7
        listing[i+4] := listing[i+8];                                                    // sta                           8

        listing[i+5] := '';
        listing[i+6] := '';
        listing[i+7] := '';
        listing[i+8] := '';

        Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and						// lda #			  ; 0
       (pos('add #', listing[i+1]) > 0) and						// add #			  ; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta STACKORIGIN+10		  ; 2
       (pos('lda #', listing[i+3]) > 0) and						// lda #			  ; 3
       (pos('adc #', listing[i+4]) > 0) and						// adc #$00			  ; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta STACKORIGIN+STACKWIDTH+10  ; 5
       (pos('lda #', listing[i+6]) > 0) and						// lda #			  ; 6
       (pos('adc #', listing[i+7]) > 0) and						// adc #$00			  ; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta STACKORIGIN+STACKWIDTH*2+10; 8
       (pos('lda #', listing[i+9]) > 0) and						// lda #			  ; 9
       (pos('adc #', listing[i+10]) > 0) and						// adc #$00			  ; 10
       (pos('sta ', listing[i+11]) > 0) then						// sta STACKORIGIN+STACKWIDTH*3+10; 11
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


    if (pos(#9'clc', listing[i]) > 0) and						// clc		; 0
       (pos('lda #', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) and		// lda #$	; 1
       (pos('lda #', listing[i+4]) > 0) and (pos('sta ', listing[i+6]) > 0) and		// adc #$	; 2
       (pos('adc #', listing[i+2]) > 0) and (pos('adc #', listing[i+5]) > 0) and	// sta 		; 3
       (pos('lda #', listing[i+7]) = 0) and (pos('adc ', listing[i+8]) = 0) then	// lda #$	; 4
     begin										// adc #$	; 5
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


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda #$	; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and		// add #$	; 1
       (pos('add #', listing[i+1]) > 0) and (pos('adc #', listing[i+4]) > 0) and	// sta 		; 2
       (pos('lda #', listing[i+6]) = 0)  and (pos('adc ', listing[i+7]) = 0) then	// lda #$	; 3
     begin										// adc #$	; 4
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


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda #$	; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and		// add #$	; 1
       (pos('lda #', listing[i+6]) > 0) and (pos('sta ', listing[i+8]) > 0) and		// sta 		; 2
       (pos('add #', listing[i+1]) > 0) and						// lda #$	; 3
       (pos('adc #', listing[i+4]) > 0) and						// adc #$	; 4
       (pos('adc #', listing[i+7]) > 0) and						// sta 		; 5
       (pos('lda #', listing[i+9]) = 0) and (pos('adc ', listing[i+10]) = 0) then	// lda #$	; 6
     begin										// adc #$	; 7
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


    if (pos('lda #', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda #', listing[i+3]) > 0) and (pos('adc ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and (pos('add #', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and (pos('adc #', listing[i+10]) > 0) and (pos('sta ', listing[i+11]) > 0) then
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
         (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
{
	lda #$80			; 0
	add eax				; 1
	sta STACKORIGIN+9		; 2
	lda #$B0			; 3
	adc eax+1			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda STACKORIGIN+9		; 6
	add #$03			; 7
	sta P				; 8
	lda STACKORIGIN+STACKWIDTH+9	; 9
	adc #$00			; 10
	sta P+1				; 11
}
      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8;
      err :=  GetVAL(copy(listing[i+7], 6, 256)) + GetVAL(copy(listing[i+10], 6, 256)) shl 8;

      p:=p + err;

      listing[i] := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);

      listing[i+7] := '';
      listing[i+10] := '';

      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('add #', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('adc #', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and (pos('add #', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and (pos('adc #', listing[i+10]) > 0) and (pos('sta ', listing[i+11]) > 0) then
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
         (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
//         (copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) and
//         (copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
{
	lda W				; 0
	add #$00			; 1
	sta STACKORIGIN+9		; 2
	lda W+1				; 3
	adc #$04			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda STACKORIGIN+9		; 6
	add #$36			; 7
	sta edx				; 8
	lda STACKORIGIN+STACKWIDTH+9	; 9
	adc #$00			; 10
	sta edx+1			; 11
}
      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;
      err :=  GetVAL(copy(listing[i+7], 6, 256)) + GetVAL(copy(listing[i+10], 6, 256)) shl 8;

      p:=p + err;

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


    if (pos('lda ', listing[i]) > 0) and (pos('add #', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('adc #', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('adc #', listing[i+7]) > 0) and (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('adc #', listing[i+10]) > 0) and (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('add #', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and (pos('adc #', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) > 0) and (pos('adc #', listing[i+19]) > 0) and (pos('sta ', listing[i+20]) > 0) and
       (pos('lda STACK', listing[i+21]) > 0) and (pos('adc #', listing[i+22]) > 0) and (pos('sta ', listing[i+23]) > 0) then
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
	sta STACKORIGIN+9		; 2
	lda W+1				; 3
	adc #$04			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda W+2				; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda W+3				; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+9	; 11
	lda STACKORIGIN+9		; 12
	add #$36			; 13
	sta W				; 14
	lda STACKORIGIN+STACKWIDTH+9	; 15
	adc #$00			; 16
	sta W+1				; 17
	lda STACKORIGIN+STACKWIDTH*2+9	; 18
	adc #$00			; 19
	sta W+2				; 20
	lda STACKORIGIN+STACKWIDTH*3+9	; 21
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


    if (l = 6) and (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and // lda W              ; 0
       (pos('lda ', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and           // add #$01..$ff      ; 1
       (pos('add #$', listing[i+1]) > 0) and (pos('adc #$00', listing[i+4]) > 0) and     // sta W              ; 2
       (pos('add #$00', listing[i+1]) = 0) then                                          // lda W+1            ; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and                      // adc #$00           ; 4
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then                   // sta W+1            ; 5
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


    if (pos('lda #$00', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda #$00		; 0
       (pos('add STACK', listing[i+2]) > 0) and	(pos('sta ', listing[i+3]) > 0) then	// sta STACKORIGIN+10	; 1
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then begin		// add STACKORIGIN+10	; 2
        listing[i+1] := '';								// sta			; 3
        listing[i+2] := #9'add #$00';

        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and		// lda			; 0
       (pos('ldy ', listing[i+2]) > 0) and (pos('lda ', listing[i+3]) > 0) then		// add			; 1
     begin										// ldy			; 2
        listing[i]   := '';								// lda 			; 3
        listing[i+1] := '';

        Result := false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('add #$01', listing[i+1]) > 0) and	// lda I
       (pos(#9'tay', listing[i+2]) > 0) and (pos(',y', listing[i]) = 0) and		// add #$01
       ( (pos(' adr.', listing[i+3]) > 0) and (pos(',y', listing[i+3]) > 0) ) then	// tay
     begin										// lda adr.TAB,y
        listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
        listing[i+1] := #9'iny';
        listing[i+2] := '';

        Result := false;
     end;


{
    if ((pos('add ', listing[i]) > 0) or (pos('sub ', listing[i]) > 0)) and		// add|sub	; 0
       (pos('sta #$00', listing[i+1]) > 0) and						// sta #$00	; 1
       ((pos('add ', listing[i+2]) > 0) or (pos('sub ', listing[i+2]) > 0)) then	// add|sub	; 2
     begin
        listing[i+1] := '';
//        listing[i+2] := #9'adc ' + copy(listing[i+2], 6, 256);			// !!! bledny wynik !!! -1 od oczekiwanego
        Result:=false;
     end;
}

    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos(',y', listing[i+2]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos(',y', listing[i+4]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos(',y', listing[i+6]) > 0) and
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('sta STACK', listing[i+5]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('lda ', listing[i+11]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('lda ', listing[i+17]) > 0) and
       (pos('sta ', listing[i+10]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('sta ', listing[i+16]) > 0) and (pos('sta ', listing[i+19]) > 0) and
       (pos('add STACK', listing[i+9]) > 0) and (pos('adc STACK', listing[i+12]) > 0) and
       (pos('adc STACK', listing[i+15]) > 0) and (pos('adc STACK', listing[i+18]) > 0) then

     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then begin
{
	lda adr.MY,y			; 0
	sta STACKORIGIN+10		; 1
	lda adr.MY+1,y			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda adr.MY+2,y			; 4
	sta STACKORIGIN+STACKWIDTH*2+10	; 5
	lda adr.MY+3,y			; 6
	sta STACKORIGIN+STACKWIDTH*3+10	; 7
	lda X				; 8
	add STACKORIGIN+10		; 9
	sta A				; 10
	lda X+1				; 11
	adc STACKORIGIN+STACKWIDTH+10	; 12
	sta A+1				; 13
	lda X+2				; 14
	adc STACKORIGIN+STACKWIDTH*2+10	; 15
	sta A+2				; 16
	lda X+3				; 17
	adc STACKORIGIN+STACKWIDTH*3+10	; 18
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


    if (i=0) and (pos('lda ', listing[i]) > 0) and (pos('add #$00', listing[i+1]) > 0) and
       (pos(#9'tay', listing[i+2]) > 0) and (pos('lda ', listing[i+3]) > 0) and
       (pos('adc #$00', listing[i+4]) > 0) and (pos('sta bp+1', listing[i+5]) > 0) and
       (pos('lda (bp),y', listing[i+6]) > 0) then begin
{
	lda TB		; 0
	add #$00	; 1
	tay		; 2
	lda TB+1	; 3
	adc #$00	; 4
	sta bp+1	; 5
	lda (bp),y	; 6
}
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+4] := '';

	Result := false;
	end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('lda (bp2),y', listing[i+3]) > 0) and
       (pos('lda (bp2),y', listing[i+6]) > 0) and (pos('lda (bp2),y', listing[i+9]) > 0) and
       (pos('sta STACK', listing[i+1]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and
       (pos('sta STACK', listing[i+7]) > 0) and (pos('sta STACK', listing[i+10]) > 0) and
       (pos(#9'iny', listing[i+2]) > 0) and (pos(#9'iny', listing[i+5]) > 0) and (pos(#9'iny', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+11]) > 0) and (pos('lda STACK', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+17]) > 0) and (pos('lda STACK', listing[i+20]) > 0) and
       (pos('sta ', listing[i+13]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('sta ', listing[i+19]) > 0) and (pos('sta ', listing[i+22]) > 0) and
       (pos('add STACK', listing[i+12]) > 0) and (pos('adc STACK', listing[i+15]) > 0) and
       (pos('adc STACK', listing[i+18]) > 0) and (pos('adc STACK', listing[i+21]) > 0) then

     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) and
        (copy(listing[i+10], 6, 256) = copy(listing[i+21], 6, 256)) then begin
{
	lda (bp2),y			; 0
	sta STACKORIGIN+10		; 1
	iny				; 2
	lda (bp2),y			; 3
	sta STACKORIGIN+STACKWIDTH+10	; 4
	iny				; 5
	lda (bp2),y			; 6
	sta STACKORIGIN+STACKWIDTH*2+10	; 7
	iny				; 8
	lda (bp2),y			; 9
	sta STACKORIGIN+STACKWIDTH*3+10	; 10
	lda STACKORIGIN+9		; 11
	add STACKORIGIN+10		; 12
	sta X				; 13
	lda STACKORIGIN+STACKWIDTH+9	; 14
	adc STACKORIGIN+STACKWIDTH+10	; 15
	sta X+1				; 16
	lda STACKORIGIN+STACKWIDTH*2+9	; 17
	adc STACKORIGIN+STACKWIDTH*2+10	; 18
	sta X+2				; 19
	lda STACKORIGIN+STACKWIDTH*3+9	; 20
	adc STACKORIGIN+STACKWIDTH*3+10	; 21
	sta X+3				; 22
}
	 listing[i+12] := #9'add (bp2),y+';
	 listing[i+15] := #9'adc (bp2),y+';
	 listing[i+18] := #9'adc (bp2),y+';
	 listing[i+21] := #9'adc (bp2),y';

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


    if (pos('ldy ', listing[i]) > 0) and (pos('ldy ', listing[i+3]) > 0) and			// ldy                    ; 0     0=3 mnemonic
       (pos('lda adr.', listing[i+1]) > 0) and (pos('lda adr.', listing[i+4]) > 0) and		// lda adr.???,y          ; 1     1=4 arg
       (pos(',y', listing[i+1]) > 0) and (pos(',y', listing[i+4]) > 0) and			// sta STACKORIGIN+10     ; 2     2=6 arg
       (pos('sta STACK', listing[i+2]) > 0) and (pos('lda STACK', listing[i+6]) > 0) and	// ldy                    ; 3
       (pos('sta STACK', listing[i+5]) > 0) and							// lda adr.???,y          ; 4
       ((pos('add STACK', listing[i+7]) > 0) or (pos('sub STACK', listing[i+7]) > 0)) then	// sta STACKORIGIN+11     ; 5     5=7 arg
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda STACKORIGIN+10     ; 6
        (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then 				// add|sub STACKORIGIN+11 ; 7
       begin
        listing[i+2] := '';
        listing[i+5] := '';
        listing[i+6] := '';
        listing[i+4] := copy(listing[i+7], 1, 5) + copy(listing[i+4], 6, 256);
        listing[i+7] := '';

        Result:=false;
       end;


(*
    if (pos(#9'clc', listing[i]) > 0) and						// clc		; 0	!!! zadziala tylko dla ADD|ADC !!!
       (pos('lda #$00', listing[i+1]) > 0) and						// lda #$00	; 1
       (pos('adc ', listing[i+2]) > 0) and						// adc		; 2
       (pos('sta ', listing[i+3]) > 0) and						// sta 		; 3
       (pos('lda #$00', listing[i+4]) > 0) and 						// lda #$00	; 4
       (pos('adc ', listing[i+5]) > 0)  and						// adc		; 5
       (pos('sta ', listing[i+6]) > 0) then						// sta 		; 6
     begin
        listing[i]   := '';

        listing[i+2] := #9'lda '+copy(listing[i+2], 6, 256);
        listing[i+4] := #9'lda '+copy(listing[i+5], 6, 256);
	listing[i+5] := listing[i+6];
	listing[i+6] := #9'clc';
        Result:=false;
     end;


    if (pos('lda #$00', listing[i]) > 0) and (pos('add ', listing[i+1]) > 0) and	// 			!!! zadziala tylko dla ADD|ADC !!!
       (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda #$00', listing[i+3]) > 0) and (pos('adc ', listing[i+4]) > 0)  and
       (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('adc #$00', listing[i+7]) > 0)  and
       (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('adc #$00', listing[i+10]) > 0)  and
       (pos('sta STACK', listing[i+11]) > 0) then
       begin
{
	lda #$00			; 0
	add YR				; 1
	sta STACKORIGIN+10		; 2
	lda #$00			; 3
	adc YR+1			; 4
	sta STACKORIGIN+STACKWIDTH+10	; 5
	lda XR				; 6
	adc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+10	; 8
	lda XR+1			; 9
	adc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+10	; 11
}
	listing[i]    := '';
	listing[i+1]  := #9'lda ' +  copy(listing[i+1], 6, 256);
	listing[i+3]  := '';
	listing[i+4]  := #9'lda ' +  copy(listing[i+4], 6, 256);
	listing[i+7]  := '';
	listing[i+10] := '';

	Result:=false;
       end;
*)


// -----------------------------------------------------------------------------
// ===                        optymalizacja SUB.			  === //
// -----------------------------------------------------------------------------

    if (l = 3) and (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and		// lda X 	; 0
       (pos('sub #$01', listing[i+1]) > 0) and							// sub #$01	; 1
       (pos('sta ', listing[i+2]) > 0) and (pos(',y', listing[i+2]) = 0) then			// sta Y	; 2
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
       (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda W	; 0
       (pos('sub #$01', listing[i+1]) > 0) then						// sub #$01	; 1
       if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then			// sta W	; 2
       begin
         listing[i]   := #9'dec '+copy(listing[i], 6, 256);
         listing[i+1] := '';
         listing[i+2] := '';

         Result := false;
       end;


    if (pos(#9'sec', listing[i]) > 0) and						// sec		; 0
       (pos('lda ', listing[i+1]) > 0) and 						// lda		; 1
       (pos('sbc ', listing[i+2]) > 0) then						// sbc		; 2
       begin
	listing[i]   := '';
	listing[i+2] := #9'sub ' + copy(listing[i+2], 6, 256);

	Result := false;
       end;


    if (pos(#9'sec', listing[i]) > 0) and						// sec		; 0
       (pos('lda ', listing[i+1]) > 0) and						// lda		; 1
       (pos('sub ', listing[i+2]) > 0) then						// sub		; 2
     begin
        listing[i] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 						// lda		; 0
       (pos('sub #$00', listing[i+1]) > 0) and						// sub #$00	; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta		; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda		; 3
       (pos('sbc ', listing[i+4]) > 0) then						// sbc		; 4
     begin
      listing[i+1] := '';
      listing[i+4] := #9'sub ' + copy(listing[i+4], 6, 256);
      Result:=false;
     end;



    if Result and
       (pos('lda ', listing[i]) > 0) and 						// lda		; 0
       (pos('sub #$00', listing[i+1]) > 0) and						// sub #$00	; 1
       (pos('sta ', listing[i+2]) > 0) and 						// sta		; 2
       (pos('lda ', listing[i+3]) = 0) and						// ~lda		; 3
       (pos('sbc ', listing[i+4]) = 0) then						// ~sbc		; 4
     begin
      listing[i+1] := '';
      Result:=false;
     end;


{
    if (pos('lsr STACK', listing[i]) > 0) and							// lsr STACKORIGIN+STACKWIDTH*3		; 0
       (pos('ror STACK', listing[i+1]) > 0) and							// ror STACKORIGIN+STACKWIDTH*2		; 1
       (pos('ror STACK', listing[i+2]) > 0) and							// ror STACKORIGIN+STACKWIDTH		; 2
       (pos('ror STACK', listing[i+3]) > 0) and							// ror STACKORIGIN			; 3
       (pos('lda ', listing[i+4]) > 0) and 							// lda 					; 4
       ((pos('add STACK', listing[i+5]) > 0) or (pos('sub STACK', listing[i+5]) > 0)) and	// add|sub STACKORIGIN			; 5
       (pos('sta ', listing[i+6]) > 0) and 							// sta					; 6
       (pos('lda ', listing[i+7]) > 0) and 							// lda 					; 7
       ((pos('adc STACK', listing[i+8]) > 0) or (pos('sbc STACK', listing[i+8]) > 0)) and	// adc|sbc STACKORIGIN+STACKWIDTH	; 8
       (pos('sta ', listing[i+9]) > 0) and  							// sta					; 9
       (pos('lda ', listing[i+10]) = 0) and
       (pos('adc ', listing[i+11]) = 0) and (pos('sbc ', listing[i+11]) = 0) then
     if (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4] := '';		// tylko najstarszy usuwany (*3) !!!

	 dec(k, 4);
	end;

        listing[i] := '';

        Result:=false;
       end;
}

    if (pos('lda ', listing[i]) > 0) and (pos('sub STACK', listing[i+1]) > 0) and		// lda					; 0
       (pos('sta STACK', listing[i+2]) > 0) and							// sub STACKORIGIN+10			; 1
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc STACK', listing[i+4]) > 0) and		// sta STACKORIGIN+9			; 2
       (pos('sta STACK', listing[i+5]) > 0) and							// lda					; 3
       (pos('mwa ', listing[i+6]) > 0) and (pos('bp2', listing[i+6]) > 0) and			// sbc STACKORIGIN+STACKWIDTH+10	; 4
       (pos('ldy ', listing[i+7]) > 0) and							// sta STACKORIGIN+STACKWIDTH+9		; 5
       (pos('lda STACK', listing[i+8]) > 0) and (pos('sta (bp2),y', listing[i+9]) > 0) and	// mwa xxx bp2				; 6
       (pos(#9'iny', listing[i+10]) > 0) and							// ldy					; 7
       (pos('lda STACK', listing[i+11]) > 0) and (pos('sta (bp2),y', listing[i+12]) > 0) then	// lda STACKORIGIN+9			; 8
     if {(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and}				// sta (bp2),y				; 9
        (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and				// iny 					; 10
        {(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and}				// lda STACKORIGIN+STACKWIDTH+9 	; 11
        (copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then				// sta (bp2),y				; 12
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


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda (bp2),y			; 0
       (pos(#9'iny', listing[i+2]) > 0) and								// sta STACKORIGIN+9		; 1
       (pos('lda (bp2),y', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and		// iny				; 2
       (pos('lda ', listing[i+5]) > 0) and (pos('sub STACK', listing[i+6]) > 0) and			// lda (bp2),y			; 3
       (pos('sta ', listing[i+7]) > 0) and								// sta STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda ', listing[i+8]) > 0) and (pos('sbc STACK', listing[i+9]) > 0) and			// lda 				; 5
       (pos('sta ', listing[i+10]) > 0) then								// sub STACKORIGIN+9		; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and					// sta				; 7
        (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then					// lda 				; 8
        												// sbc STACKORIGIN+STACKWIDTH+9	; 9
        												// sta				; 10
	begin
	  listing[i]    := '';
	  listing[i+1]  := '';
	  listing[i+2]  := '';
	  listing[i+3]  := '';

	  listing[i+4] := listing[i+5];
	  listing[i+5] := #9'sub (bp2),y';
	  listing[i+6] := #9'iny';

	  listing[i+9] := #9'sbc (bp2),y';

          Result:=false;
	end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and		// lda (bp2),y			; 0
       (pos(#9'iny', listing[i+2]) > 0) and								// sta STACKORIGIN+9		; 1
       (pos('lda (bp2),y', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and		// iny				; 2
       (pos('lda STACK', listing[i+5]) > 0) and (pos('sub ', listing[i+6]) > 0) and			// lda (bp2),y			; 3
       (pos('sta ', listing[i+7]) > 0) and								// sta STACKORIGIN+STACKWIDTH+9	; 4
       (pos('lda STACK', listing[i+8]) > 0) and (pos('sbc ', listing[i+9]) > 0) and			// lda STACKORIGIN+9		; 5
       (pos('sta ', listing[i+10]) > 0) then								// sub				; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and					// sta				; 7
        (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then					// lda STACKORIGIN+STACKWIDTH+9	; 8
        												// sbc				; 9
        												// sta				; 10
	begin
	  listing[i+1] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';

	  listing[i+8] := listing[i];

          Result:=false;
	end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and
       (pos('lda ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sta STACK', listing[i+7]) > 0) and
       (pos('lda ', listing[i+8]) > 0) and (pos('sub STACK', listing[i+9]) > 0) and (pos('sta ', listing[i+10]) > 0) and
       (pos('lda ', listing[i+11]) > 0) and (pos('sbc STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda ', listing[i+14]) > 0) and (pos('sbc STACK', listing[i+15]) > 0) and (pos('sta ', listing[i+16]) > 0) and
       (pos('lda ', listing[i+17]) > 0) and (pos('sbc STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda eax				; 0
	sta STACKORIGIN+10		; 1
	lda eax+1			; 2
	sta STACKORIGIN+STACKWIDTH+10	; 3
	lda eax+2			; 4
	sta STACKORIGIN+STACKWIDTH*2+10	; 5
	lda eax+3			; 6
	sta STACKORIGIN+STACKWIDTH*3+10	; 7
	lda ERROR			; 8
	sub STACKORIGIN+10		; 9
	sta ERROR			; 10
	lda ERROR+1			; 11
	sbc STACKORIGIN+STACKWIDTH+10	; 12
	sta ERROR+1			; 13
	lda ERROR+2			; 14
	sbc STACKORIGIN+STACKWIDTH*2+10	; 15
	sta ERROR+2			; 16
	lda ERROR+3			; 17
	sbc STACKORIGIN+STACKWIDTH*3+10	; 18
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


    if (pos('lda ', listing[i]) > 0) and (pos('sub ', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc ', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sbc ', listing[i+7]) > 0) and (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('sbc ', listing[i+10]) > 0) and (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sta ', listing[i+13]) > 0) and
       (pos('lda STACK', listing[i+14]) > 0) and (pos('sta ', listing[i+15]) > 0) and
       (pos('lda STACK', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) > 0) and (pos('sta ', listing[i+19]) > 0) then
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
        (copy(listing[i+8], 6, 256) = copy(listing[i+16], 6, 256)) and
        (copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then
	begin
{
	lda Y				; 0
	sub #$01			; 1
	sta STACKORIGIN+11		; 2
	lda Y+1				; 3
	sbc #$00			; 4
	sta STACKORIGIN+STACKWIDTH+11	; 5
	lda #$00			; 6
	sbc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+11	; 8
	lda #$00			; 9
	sbc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+11	; 11
	lda STACKORIGIN+11		; 12
	sta ecx				; 13
	lda STACKORIGIN+STACKWIDTH+11	; 14
	sta ecx+1			; 15
	lda STACKORIGIN+STACKWIDTH*2+11	; 16
	sta ecx+2			; 17
	lda STACKORIGIN+STACKWIDTH*3+11	; 18
	sta ecx+3			; 19
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


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+9		; 1
       (pos('lda STACK', listing[i+4]) > 0) and (pos('sub ', listing[i+5]) > 0) and	// lda				; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda STACK', listing[i+7]) > 0) and	// sta STACKORIGIN+STACKWIDTH+9	; 3
       (pos('sbc ', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then		// lda STACKORIGIN+9		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and			// sub				; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then begin		// sta				; 6
        listing[i+4] := listing[i];							// lda STACKORIGIN+STACKWIDTH+9	; 7
        listing[i+7] := listing[i+2];							// sbc				; 8
        listing[i]   := '';								// sta				; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda				; 0
       (pos('lda ', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and	// sta STACKORIGIN+9		; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sub STACK', listing[i+5]) > 0) and	// lda				; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) > 0) and		// sta STACKORIGIN+STACKWIDTH+9	; 3
       (pos('sbc STACK', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then	// lda				; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and			// sub STACKORIGIN+9		; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin		// sta				; 6
        listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);				// lda				; 7
        listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);				// sbc STACKORIGIN+STACKWIDTH+9	; 8
        listing[i]   := '';								// sta				; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('sub ', listing[i+1]) > 0) and	// sty STACKORIGIN+10	; 0
       (pos('sta ', listing[i+2]) > 0) and (pos('lda STACK', listing[i+3]) > 0) and	// sub			; 1
       (pos('sbc ', listing[i+4]) > 0) and (pos('sta ', listing[i+5]) > 0) then		// sta			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then			// lda STACKORIGIN+10	; 3
       begin										// sbc			; 4
											// sta			; 5
	listing[i]   := '';
	listing[i+3] := #9'tya';
	Result:=false;
       end;


    if (l = 6) and (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and// lda W              ; 0
       (pos('lda ', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and		// sub #$01..$ff      ; 1
       (pos('sub #$', listing[i+1]) > 0) and (pos('sbc #$00', listing[i+4]) > 0) and	// sta W              ; 2
       (pos('sub #$00', listing[i+1]) = 0) then						// lda W+1            ; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and			// sbc #$00           ; 4
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then			// sta W+1            ; 5
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


(*
    if (l = 4) and (pos(#9'sec', listing[i]) > 0) and					// sec		; 0
       (pos('lda ', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) and		// lda W	; 1
       (pos('sbc #$01', listing[i+2]) > 0) then						// sbc #$01	; 2
       if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then			// sta X | W	; 3
       begin
         listing[i]   := #9'dec '+copy(listing[i+1], 6, 256);
         listing[i+1] := '';
         listing[i+2] := '';
         listing[i+3] := '';

         Result := false;
       end;


    if (pos('lda ', listing[i]) > 0) and 						// lda W	; 0
       (pos('sub #$00', listing[i+1]) > 0) and  					// sub #$00	; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta W	; 2
       (pos('lda ', listing[i+3]) > 0) and						// lda W+1	; 3
       (pos('sbc #$01', listing[i+4]) > 0) and  					// sbc #$01	; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta W+1	; 5
       (pos(listing[i], listing[i+6]) = 0) then 					// lda ...	; 6
      begin
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
         (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then begin

	 listing[i] := '';
	 listing[i+1] := '';
	 listing[i+2] := '';

	 listing[i+3] := #9'dec ' + copy(listing[i+3], 6, 256);

	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';

      end;

      Result:=false;
     end;



    if (pos('lda ', listing[i]) > 0) and (pos('sub #$00', listing[i+1]) > 0) and         // lda W	; 0		!!! utrudnia inne optymalizacje ktore sa wydajniejsze !!!
       (pos('sta ', listing[i+2]) > 0) then                                              // sub #$00	; 1
     begin                                                                               // sta W	; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin
        listing[i]   := #9'sec';
        listing[i+1] := '';
        listing[i+2] := '';
      end else begin
        listing[i+1] := listing[i+2];
        listing[i+2] := #9'sec';
      end;

      Result:=false;
     end;


    if (pos(#9'sec', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and		// sec		; 0
       (pos('sbc #$00', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0) then	// lda W+1	; 1
     begin										// sbc #$00	; 2
      if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin		// sta W+1	; 3
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';
      end else begin
        listing[i]   := '';
        listing[i+2] := listing[i+3];
        listing[i+3] := #9'sec';
      end;

      Result:=false;
     end;
*)


    if (pos(#9'sec', listing[i]) > 0) and						// sec		; 0
       (pos('lda #', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) and		// lda #$	; 1
       (pos('lda #', listing[i+4]) > 0) and (pos('sta ', listing[i+6]) > 0) and		// sbc #$	; 2
       (pos('sbc #', listing[i+2]) > 0) and (pos('sbc #', listing[i+5]) > 0) and	// sta 		; 3
       (pos('lda #', listing[i+7]) = 0) and (pos('sbc ', listing[i+8]) = 0) then	// lda #$	; 4
     begin										// sbc #$	; 5
											// sta 		; 6
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


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda #$	; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and		// sub #$	; 1
       (pos('sub #', listing[i+1]) > 0) and (pos('sbc #', listing[i+4]) > 0) and	// sta 		; 2
       (pos('lda #', listing[i+6]) = 0)  and (pos('sbc ', listing[i+7]) = 0) then	// lda #$	; 3
     begin										// sbc #$	; 4
											// sta 		; 5
      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8;
      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8;

      p:=p - err;

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';
      listing[i+3] := #9'lda #$' + IntToHex(byte(p shr 8), 2);
      listing[i+4] := '';

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sub #', listing[i+1]) > 0) and		// lda #$	; 0
       (pos('sta ', listing[i+2]) > 0) and						// sub #$	; 1
       (pos('lda #', listing[i+3]) = 0)  and (pos('sbc ', listing[i+4]) = 0) then	// sta 		; 2
     begin
      p := GetVAL(copy(listing[i], 6, 256));
      err := GetVAL(copy(listing[i+1], 6, 256));

      p:=p - err;

      listing[i] := '';

      listing[i+1] := #9'lda #$' + IntToHex(p and $ff, 2);

      Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and (pos('sta ', listing[i+2]) > 0) and		// lda #$	; 0
       (pos('lda #', listing[i+3]) > 0) and (pos('sta ', listing[i+5]) > 0) and		// sub #$	; 1
       (pos('lda #', listing[i+6]) > 0) and (pos('sta ', listing[i+8]) > 0) and		// sta 		; 2
       (pos('sub #', listing[i+1]) > 0) and						// lda #$	; 3
       (pos('sbc #', listing[i+4]) > 0) and						// sbc #$	; 4
       (pos('sbc #', listing[i+7]) > 0) and						// sta 		; 5
       (pos('lda #', listing[i+9]) = 0) and (pos('sbc ', listing[i+10]) = 0) then	// lda #$	; 6
     begin										// sbc #$	; 7
											// sta 		; 8
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


    if (pos('lda ', listing[i]) > 0) and (pos('sub #', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc #', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda STACK', listing[i+6]) > 0) and (pos('sub #', listing[i+7]) > 0) and (pos('sta ', listing[i+8]) > 0) and
       (pos('lda STACK', listing[i+9]) > 0) and (pos('sbc #', listing[i+10]) > 0) and (pos('sta ', listing[i+11]) > 0) then
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
         (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) and
         (copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) and
         (copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
{
	lda W				; 0
	sub #$00			; 1
	sta STACKORIGIN+9		; 2
	lda W+1				; 3
	sbc #$04			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda STACKORIGIN+9		; 6
	sub #$36			; 7
	sta W				; 8
	lda STACKORIGIN+STACKWIDTH+9	; 9
	sbc #$00			; 10
	sta W+1				; 11
}
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


    if (pos('lda #', listing[i]) > 0) and						// lda #			  ; 0
       (pos('sub #', listing[i+1]) > 0) and						// sub #			  ; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta STACKORIGIN+10		  ; 2
       (pos('lda #', listing[i+3]) > 0) and						// lda #			  ; 3
       (pos('sbc #', listing[i+4]) > 0) and						// sbc #$00			  ; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta STACKORIGIN+STACKWIDTH+10  ; 5
       (pos('lda #', listing[i+6]) > 0) and						// lda #			  ; 6
       (pos('sbc #', listing[i+7]) > 0) and						// sbc #$00			  ; 7
       (pos('sta ', listing[i+8]) > 0) and						// sta STACKORIGIN+STACKWIDTH*2+10; 8
       (pos('lda #', listing[i+9]) > 0) and						// lda #			  ; 9
       (pos('sbc #', listing[i+10]) > 0) and						// sbc #$00			  ; 10
       (pos('sta ', listing[i+11]) > 0) then						// sta STACKORIGIN+STACKWIDTH*3+10; 11
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


    if (pos('lda #', listing[i]) > 0) and						// lda #			  ; 0
       (pos('sub #', listing[i+1]) > 0) and						// sub #			  ; 1
       (pos('sta ', listing[i+2]) > 0) and						// sta STACKORIGIN+10		  ; 2
       (pos('lda #', listing[i+3]) > 0) and						// lda #			  ; 3
       (pos('sbc #', listing[i+4]) > 0) and						// sbc #$00			  ; 4
       (pos('sta ', listing[i+5]) > 0) and						// sta STACKORIGIN+STACKWIDTH+10  ; 5
       (pos('lda #', listing[i+6]) > 0) and						// lda #			  ; 6
       (pos('sbc #', listing[i+7]) > 0) and						// sbc #$00			  ; 7
       (pos('sta ', listing[i+8]) > 0) then						// sta STACKORIGIN+STACKWIDTH*2+10; 8
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


    if (pos('lda ', listing[i]) > 0) and (pos('sub #', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and
       (pos('lda ', listing[i+3]) > 0) and (pos('sbc #', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and
       (pos('lda ', listing[i+6]) > 0) and (pos('sbc #', listing[i+7]) > 0) and (pos('sta STACK', listing[i+8]) > 0) and
       (pos('lda ', listing[i+9]) > 0) and (pos('sbc #', listing[i+10]) > 0) and (pos('sta STACK', listing[i+11]) > 0) and
       (pos('lda STACK', listing[i+12]) > 0) and (pos('sub #', listing[i+13]) > 0) and (pos('sta ', listing[i+14]) > 0) and
       (pos('lda STACK', listing[i+15]) > 0) and (pos('sbc #', listing[i+16]) > 0) and (pos('sta ', listing[i+17]) > 0) and
       (pos('lda STACK', listing[i+18]) > 0) and (pos('sbc #', listing[i+19]) > 0) and (pos('sta ', listing[i+20]) > 0) and
       (pos('lda STACK', listing[i+21]) > 0) and (pos('sbc #', listing[i+22]) > 0) and (pos('sta ', listing[i+23]) > 0) then
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
	sta STACKORIGIN+9		; 2
	lda W+1				; 3
	sbc #$04			; 4
	sta STACKORIGIN+STACKWIDTH+9	; 5
	lda W+2				; 6
	sbc #$00			; 7
	sta STACKORIGIN+STACKWIDTH*2+9	; 8
	lda W+3				; 9
	sbc #$00			; 10
	sta STACKORIGIN+STACKWIDTH*3+9	; 11
	lda STACKORIGIN+9		; 12
	sub #$36			; 13
	sta W				; 14
	lda STACKORIGIN+STACKWIDTH+9	; 15
	sbc #$00			; 16
	sta W+1				; 17
	lda STACKORIGIN+STACKWIDTH*2+9	; 18
	sbc #$00			; 19
	sta W+2				; 20
	lda STACKORIGIN+STACKWIDTH*3+9	; 21
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


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax', listing[i+1]) > 0) and	 // lda STACKORIGIN+9		  ; 0
       (pos('lda STACK', listing[i+2]) > 0) and (pos('sta eax+1', listing[i+3]) > 0) and // sta eax            		  ; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sub eax', listing[i+5]) > 0) and	 // lda STACKORIGIN+STACKWIDTH+9  ; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) > 0) and 		 // sta eax+1			  ; 3
       (pos('sbc eax+1', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then     // lda 			  ; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and                    // sub	eax			  ; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin             // sta 			  ; 6
        listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);                             // lda 			  ; 7
        listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);                           // sbc	eax+1			  ; 8
        listing[i]   := '';								 // sta 			  ; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('lda eax', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	 // lda eax			  ; 0
       (pos('lda eax+1', listing[i+2]) > 0) and (pos('sta STACK', listing[i+3]) > 0) and // sta STACKORIGIN+10		  ; 1
       (pos('lda STACK', listing[i+4]) > 0) and (pos('sub STACK', listing[i+5]) > 0) and // lda eax+1			  ; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda STACK', listing[i+7]) > 0) and 	 // sta STACKORIGIN+STACKWIDTH+10 ; 3
       (pos('sbc STACK', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) then     // lda STACKORIGIN+9		  ; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and                    // sub STACKORIGIN+10		  ; 5
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then begin             // sta 			  ; 6
        listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);                             // lda STACKORIGIN+STACKWIDTH+9  ; 7
        listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);                           // sbc	STACKORIGIN+STACKWIDTH+10 ; 8
        listing[i]   := '';								 // sta 			  ; 9
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax', listing[i+1]) > 0) and	 // lda STACKORIGIN+9		  ; 0
       (pos('lda STACK', listing[i+2]) > 0) and (pos('sta eax+1', listing[i+3]) > 0) and // sta eax            		  ; 1
       (pos('lda ', listing[i+4]) > 0) and (pos('sub eax', listing[i+5]) > 0) and	 // lda STACKORIGIN+STACKWIDTH+9  ; 2
       (pos('sta ', listing[i+6]) > 0) and (pos('lda ', listing[i+7]) = 0) then		 // sta eax+1			  ; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then begin		 // lda 			  ; 4
	listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);		                 // sub	eax			  ; 5
	listing[i]   := '';								 // sta 			  ; 6
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';

        Result:=false;
     end;


// -----------------------------------------------------------------------------
// ===                     optymalizacja STA #$00.			  === //
// -----------------------------------------------------------------------------

    if (i=0) and (pos('sta #$00', listing[i]) > 0) then begin				// jedno linijkowy sta #$00
       listing[i] := '';
       Result:=false;
     end;


    if (i>0) and (pos('sta #$00', listing[i]) > 0) then					// lda 		; -2
     if (pos('adc ', listing[i-1]) > 0) or (pos('sbc ', listing[i-1]) > 0) then begin	// adc|sbc	; -1
											// sta #$00	; 0
       if ((pos('adc ', listing[i-1]) > 0) or (pos('sbc ', listing[i-1]) > 0)) and
          (pos('lda ', listing[i-2]) > 0) then listing[i-2] := '';

       listing[i-1] := '';
       listing[i]   := '';
       Result:=false;
     end;


    if ((pos('add ', listing[i]) > 0) or (pos('sub ', listing[i]) > 0)) and		// add|sub	; 0
       (pos('sta #$00', listing[i+1]) > 0) then						// sta #$00	; 1
     begin
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sta #$00', listing[i]) > 0) and (i>0) then					// iny		; -2
     if (pos('lda (bp2),y', listing[i-1]) > 0) then					// lda (bp2),y	; -1
      begin										// sta #$00	; 0

        if  (pos(#9'iny', listing[i-2]) > 0) then listing[i-2] := '';

        listing[i-1] := '';
        listing[i]   := '';
        Result:=false;
      end;


    if ( (pos('ora ', listing[i]) > 0) or						// ora|and|eor	; 0
	 (pos('and ', listing[i]) > 0) or 						// sta #$00	; 1
	 (pos('eor ', listing[i]) > 0) ) and (pos('sta #$00', listing[i+1]) > 0) then
     begin
        listing[i]   := '';
        listing[i+1] := '';
	Result:=false;
     end;


    if (pos('adc STACK', listing[i]) > 0) and (pos('sta #$00', listing[i+1]) > 0) then	// adc STACK
     begin										// sta #$00
        listing[i]   := '';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta #$00', listing[i+1]) > 0) then	// lda
     begin										// sta #$00
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and (pos('sta #$00', listing[i+1]) > 0) then	// sta
     begin										// sta #$00
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('scc', listing[i]) > 0) and (pos('inc #$00', listing[i+1]) > 0) then	// scc
     begin										// inc #$00
        listing[i]   := '';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('scs', listing[i]) > 0) and (pos('dec #$00', listing[i+1]) > 0) then         // scs
     begin                                                                               // dec #$00
        listing[i]   := '';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) then  		 // lda STACKORIGIN+9
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin                 // sta STACKORIGIN+9

       if (pos('sta #$00', listing[i+1]) = 0) then listing[i] := '';

       listing[i+1] := '';
       Result:=false;
     end;


// -----------------------------------------------------------------------------


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and	// sta STACKORIGIN+10
       (pos('add STACK', listing[i+2]) > 0) and						// lda
       ( (pos('sta ', listing[i+3]) > 0) or (pos(#9'tay', listing[i+3]) > 0) ) then	// add STACKORIGIN+10
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin		// sta | tay
        listing[i]   := '';
        listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256) ;
        listing[i+2] := '';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('ora STACK', listing[i+2]) > 0) and   // sta STACKORIGIN+10
       (pos('lda ', listing[i+1]) > 0) and (pos('sta ', listing[i+3]) > 0) then          // lda B
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and                      // ora STACKORIGIN+10
        (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin             // sta B
        listing[i]   := '';
        listing[i+2] := '';

        listing[i+1] := #9'ora '+copy(listing[i+1], 6, 256);
        Result:=false;
     end;


    if (pos('ldy ', listing[i-1]) = 0) and (pos(#9'tay ', listing[i-1]) = 0) and	// sta STACKORIGIN+9	; 0
       (pos('sta ', listing[i]) > 0) and (pos('lda ', listing[i+2]) > 0) and 		// clc|sec		; 1
       ((pos(#9'clc', listing[i+1]) > 0) or (pos(#9'sec', listing[i+1]) > 0)) then	// lda STACKORIGIN+9	; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin
        listing[i]   := '';
        listing[i+2] := '';
        Result:=false;
     end;


    if (pos('ldy ', listing[i-1]) = 0) and (pos(#9'tay ', listing[i-1]) = 0) and	// sta STACKORIGIN+9	; 0
       (pos('sta ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and 		// lda STACKORIGIN+9	; 1
       ((pos('add ', listing[i+2]) = 0) or (pos('sub ', listing[i+2]) = 0)) then	// add|sub		; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin
        listing[i]   := '';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda STACK', listing[i+3]) > 0) and   // sta STACKORIGIN+9	; 0
       (pos('mwa ', listing[i+1]) > 0) and (pos('ldy ', listing[i+2]) > 0) then          // mwa SCRN bp2	; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then begin               // ldy #$00		; 2
        listing[i]   := '';                                                              // lda STACKORIGIN+9	; 3
        listing[i+3] := '';

        listing[i+1] := #9'mwy '+copy(listing[i+1], 6, 256);
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and                                                                            // lda
       ((pos('lda ', listing[i+2]) > 0) or (pos('ldy ', listing[i+2]) > 0) or (pos('mwa ', listing[i+2]) > 0)) and  // adc|sbc STACK
       ((pos('sbc STACK', listing[i+1]) > 0) or (pos('adc STACK', listing[i+1]) > 0)) then                          // lda | ldy | mwa
     begin
        listing[i]   := '';
        listing[i+1] := '';
        Result:=false;
    end;


    if ((pos('sbc #$00', listing[i]) > 0) or (pos('adc #$00', listing[i]) > 0)) and                                    // sbc #$00 | adc #$00
       ((pos('lda ', listing[i+1]) > 0) or (pos('ldy ', listing[i+1]) > 0) or (pos('mwa ', listing[i+1]) > 0)) then    // lda | ldy | mwa
     begin
        listing[i]   := '';
        Result:=false;
    end;


    if (pos('ldy #$', listing[i]) > 0) and (pos('lda #$', listing[i+1]) > 0) and 	// ldy #$xx	; 0
       (pos('sta ', listing[i+2]) > 0) and (listing[i+3] = '') then			// lda #$xx	; 1
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then			// sta		; 2
     begin
        listing[i+1] := #9'tya';
        Result:=false;
     end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos(#9'iny', listing[i+1]) > 0) and	// lda (bp2),y
       (pos('lda (bp2),y', listing[i+2]) > 0) then begin				// iny
        listing[i] := '';								// lda (bp2),y
        Result:=false;
    end;


    if (pos(#9'iny', listing[i]) > 0) and (pos('lda (bp2),y', listing[i+1]) > 0) and	// iny
       (pos(#9'iny', listing[i+2]) > 0) then begin					// lda (bp2),y
        listing[i]   := '';								// iny
        listing[i+1] := '';
        listing[i+2] := '';
        Result:=false;
    end;


    if (pos('lda (bp2),y', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) then	// iny		; -1
     begin										// lda (bp2),y	; 0
     											// lda		; 1
      listing[i] := '';
      if (pos(#9'iny', listing[i-1]) > 0) then listing[i-1] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and 		// lda		; 0
       (pos(',y', listing[i]) = 0) then							// lda		; 1
     begin
      listing[i] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('mwa ', listing[i+1]) > 0) then 		// lda		; 0
     begin										// mwa		; 1
      listing[i] := '';
      Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda 		; 0
       (pos('and #$00', listing[i+1]) > 0) and						// and #$00	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta 		; 2
     begin
        listing[i]   := '';
        listing[i+1] := #9'lda #$00';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda 		; 0
       (pos('ora #$00', listing[i+1]) > 0) and						// ora #$00	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta 		; 2
     begin
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda 		; 0
       (pos('eor #$00', listing[i+1]) > 0) and						// eor #$00	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta 		; 2
     begin
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and						// lda 		; 0
       (pos('and #$FF', listing[i+1]) > 0) and						// and #$FF	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta 		; 2
     begin
        listing[i+1] := '';
        Result:=false;
     end;

    if (pos('lda ', listing[i]) > 0) and						// lda 		; 0
       (pos('ora #$FF', listing[i+1]) > 0) and						// ora #$FF	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta 		; 2
     begin
        listing[i]   := '';
	listing[i+1] := #9'lda #$FF';
        Result:=false;
     end;


    if (pos('lda #', listing[i]) > 0) and						// lda #	; 0
       (pos('eor #', listing[i+1]) > 0) and						// eor #	; 1
       (pos('sta ', listing[i+2]) > 0) then						// sta 		; 2
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
    if (pos(#9'clc', listing[i]) > 0) then						// <> add|adc	; 2
    begin
        listing[i] := '';
        Result:=false;
    end;


    if (pos('sta STACKORIGIN+STACKWIDTH', listing[i]) > 0) and				// sta STACKORIGIN+STACKWIDTH	; 0
       (pos('lda STACKORIGIN+STACKWIDTH*2', listing[i+1]) > 0) and			// lda STACKORIGIN+STACKWIDTH*2	; 1
       ((pos('adc ', listing[i+2]) > 0) or (pos('sbc ', listing[i+2]) > 0)) and		// adc|sbc			; 2
       (pos('sta STACKORIGIN+STACKWIDTH*2', listing[i+3]) > 0) and			// sta STACKORIGIN+STACKWIDTH*2 ; 3
       (pos('lda STACKORIGIN+STACKWIDTH*3', listing[i+4]) = 0) then			// ~lda STACKORIGIN+STACKWIDTH*3; 4	skracamy do dwoch bajtow
     begin
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       Result:=false;
     end;


    if (i>0) and
       (pos('lda STACKORIGIN+STACKWIDTH*3', listing[i]) > 0) and			// lda STACKORIGIN+STACKWIDTH*3	; 0	wczesniej musi wystapic zapis do 'STACKORIGIN+STACKWIDTH*3'
       ((pos('adc ', listing[i+1]) > 0) or (pos('sbc ', listing[i+1]) > 0)) and		// adc|sbc			; 1
       (pos('sta STACKORIGIN+STACKWIDTH*3', listing[i+2]) > 0) then			// sta STACKORIGIN+STACKWIDTH*3 ; 2
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


    if (pos('lsr #$00', listing[i]) > 0) and (pos('ror @', listing[i+1]) > 0)  then	// lsr #$00
     begin										// ror @
        listing[i]   := #9'lsr @';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lsr #$00', listing[i]) > 0) and (pos('ror STACK', listing[i+1]) > 0) then	// lsr #$00
     begin										// ror STACKORIGIN+STACKWIDTH*2+9
        listing[i]   := '';
        listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lsr STACK', listing[i+1]) > 0) then  // sta STACKORIGIN+9
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then begin               // lsr STACKORIGIN+9
        listing[i+1] := listing[i];
        listing[i]   := #9'lsr @';
        Result:=false;
     end;


    if (pos('bne @+', listing[i]) > 0) and (pos('bne @+', listing[i+1]) > 0) then begin	// bne @+
        listing[i]   := '';								// bne @+
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and 						// lda #$00	; 0
       (pos('sta (bp2),y', listing[i+1]) > 0) and 					// sta (bp2),y	; 1
       (pos(#9'iny', listing[i+2]) > 0) and						// iny		; 2 5 8
       (pos('lda ', listing[i+3]) > 0) and 						// lda #$00	; 3 6 9
       (pos('sta (bp2),y', listing[i+4]) > 0) then					// sta (bp2),y 	; 4 7 10
      if listing[i] = listing[i+3] then begin

        listing[i+3] := '';

	if (pos(#9'iny', listing[i+5]) > 0) and (pos('lda ', listing[i+6]) > 0) and (pos('sta (bp2),y', listing[i+7]) > 0) then
	  if listing[i] = listing[i+6] then begin

	   listing[i+6] := '';

	   if (pos(#9'iny', listing[i+8]) > 0) and (pos('lda ', listing[i+9]) > 0) and (pos('sta (bp2),y', listing[i+10]) > 0) then
	     if listing[i] = listing[i+9] then listing[i+9] := '';

	  end;

        Result:=false;
      end;


    if (pos('lsr #$00', listing[i]) > 0) and (pos('ror #$00', listing[i+1]) > 0) and
       (pos('ror STACK', listing[i+2]) > 0) and (pos('ror STACK', listing[i+3]) > 0) then begin
        listing[i]   := '';								// lsr #$00
        listing[i+1] := '';								// ror #$00
        listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);				// ror STACKORIGIN+STACKWIDTH+9
        listing[i+3] := #9'ror ' + copy(listing[i+3], 6, 256);				// ror STACKORIGIN+9
        Result:=false;
     end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) then	// sty STACKORIGIN+10
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin		// lda STACKORIGIN+10
        listing[i]   := #9'tya';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos(#9'tya', listing[i]) > 0) and (pos('sta ', listing[i+1]) > 0) and		// tya
       (pos(',y', listing[i+1]) = 0) and (pos('sta ', listing[i+2]) = 0) then		// sta xxx
     begin										// st?   ? <> a
        listing[i]   := #9'sty '+copy(listing[i+1], 6, 256);
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) and	// sty STACKORIGIN+10
       (pos('lda STACK', listing[i+2]) > 0) then					// sty
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin		// lda STACKORIGIN+10
        old := listing[i];
        listing[i]   := listing[i+1];
        listing[i+1] := old;
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) and	// sta STACKORIGIN+10	; 0
       (pos('sty ', listing[i+2]) > 0) and (pos('lda STACK', listing[i+3]) > 0) then	// sty			; 1
     if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then begin		// sty			; 2
        listing[i]   := '';								// lda STACKORIGIN+10	; 3
        listing[i+3] := '';
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('sty ', listing[i+1]) > 0) and	// sta STACKORIGIN+10
       (pos('lda STACK', listing[i+2]) > 0) then					// sty
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin		// lda STACKORIGIN+10
        listing[i]   := '';
        listing[i+2] := '';
        Result:=false;
     end;


    if (pos('lda eax', listing[i]) > 0) and (pos(#9'tay', listing[i+1]) > 0) then	// lda eax
     begin										// tay
        listing[i]   := #9'ldy eax';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and (pos('ldy ', listing[i+1]) > 0) then		// sta STACKORIGIN+10
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin		// ldy STACKORIGIN+10
        listing[i]   := #9'tay';
        listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos(',y', listing[i]) = 0) and		// lda
       (pos(#9'tay', listing[i+1]) > 0) and (pos(',y', listing[i+2]) > 0) then          // tay
     begin                                                                              // lda|sta xxx,y
        listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('ldy ', listing[i+1]) > 0) and             // lda
       ((pos('mwa ', listing[i+2]) > 0) or (pos('lda ', listing[i+2]) > 0)) then         // ldy
     begin                                                                               // mwa | lda
        listing[i]   := '';
        Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('sub #$01', listing[i+1]) > 0) and	// lda
       (pos(#9'tay', listing[i+2]) > 0) then						// sub #$01
     begin										// tay
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


    if (pos('ldy #', listing[i]) > 0) and (pos('lda #', listing[i+1]) > 0) and           // ldy #$ff
       (pos('sty ', listing[i+2]) > 0) and (pos('sta ', listing[i+3]) > 0)  then         // lda #$ff
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then begin               // sty
        listing[i+1] := '';                                                              // sta
        listing[i+3] := #9'sty '+copy(listing[i+3], 6, 256);
        Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and
       (pos('lda STACK', listing[i+1]) > 0) and (pos('sta ', listing[i+2]) > 0) and	// sta STACK+WIDTH+10	; 0
       (pos('lda STACK', listing[i+3]) > 0) and (pos('sta ', listing[i+4]) > 0) and	// lda STACK+10		; 1
       (pos('ldy ', listing[i+5]) > 0) and (pos('lda ', listing[i+6]) > 0) and		// sta eax		; 2
       (pos('sta ', listing[i+7]) > 0) and (pos('lda ', listing[i+8]) > 0) and		// lda STACK+WIDTH+10	; 3
       (pos('sta ', listing[i+9]) > 0) then						// sta eax+1		; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and 			// ldy eax		; 5
        (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then			// lda			; 6
     begin										// sta ,y		; 7
     	//listing[i]   := '';								// lda 			; 8
	listing[i+2] := #9'tay';							// sta ,y		; 9
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

      	Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos(',y', listing[i+1]) = 0) and (pos(',y', listing[i+3]) = 0) and
       (pos('lda ', listing[i+1]) > 0) and (pos('sta STACK', listing[i+2]) > 0) and		// sta STACK+9		; 0
       (pos('lda ', listing[i+3]) > 0) and (pos('sta STACK', listing[i+4]) > 0) and		// lda 			; 1
       (pos('ldy STACK', listing[i+5]) > 0) and (pos('lda STACK', listing[i+6]) > 0) and	// sta STACK+10		; 2
       (pos('sta ', listing[i+7]) > 0) and (pos('lda STACK', listing[i+8]) > 0) and		// lda 			; 3
       (pos('sta ', listing[i+9]) > 0) then							// sta STACK+WIDTH+10	; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and 				// ldy STACK+9		; 5
        (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and				// lda STACK+10		; 6
        (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then				// sta			; 7
     begin											// lda STACK+WIDTH+10	; 8
	listing[i+6] := listing[i+1];								// sta			; 9
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
    if (pos('sta STACK', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) and		// sta STACKORIGIN+STACKWIDTH+11		// optymalizacje byte = byte * ? psuje
       (pos('sta eax', listing[i+2]) > 0) and (pos('lda STACK', listing[i+3]) > 0) and		// lda STACKORIGIN+11
       (pos('sta eax+1', listing[i+4]) > 0) then 						// sta eax
    if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then				// lda STACKORIGIN+STACKWIDTH+11
     begin											// sta eax+1
      	listing[i] := listing[i+4];
	listing[i+3] := '';
	listing[i+4] := '';
        Result:=false;
     end;
}

    if (pos('mwa ', listing[i]) > 0) and (pos(' bp2', listing[i]) > 0) and                      // mva FIRST bp2                 0
       (pos('mwa ', listing[i+7]) > 0) and (pos(' bp2', listing[i+7]) > 0) and                  // ldy #                         1
       (listing[i+1] = listing[i+8]) and (listing[i+4] = listing[i+11]) and                     // lda (bp2),y                   2
       (pos('lda (bp2),y', listing[i+2]) > 0) and (pos('lda (bp2),y', listing[i+5]) > 0) and    // sta STACKORIGIN+9             3
       (pos('sta (bp2),y', listing[i+10]) > 0) and (pos('sta (bp2),y', listing[i+13]) > 0) and  // iny                           4
       (pos('sta STACK', listing[i+3]) > 0) and (pos('sta STACK', listing[i+6]) > 0) and        // lda (bp2),y                   5
       (pos('lda STACK', listing[i+9]) > 0) and (pos('lda STACK', listing[i+12]) > 0) then      // sta STACKORIGIN+STACKWIDTH+9  6
     if (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and                           // mwa LAST bp2                  7
        (copy(listing[i+6], 6, 256) = copy(listing[i+12], 6, 256)) then begin                   // ldy #                         8
												// lda STACKORIGIN+9             9
	delete(listing[i+7], pos(' bp2', listing[i+7]), 256);					// sta (bp2),y                   10
												// iny				 11
	listing[i+1] := listing[i+7] + ' ztmp';							// lda STACKORIGIN+STACKWIDTH+9  12
	listing[i+2] := listing[i+8];								// sta (bp2),y			 13
	listing[i+3] := #9'lda (bp2),y';
	listing[i+4] := #9'sta (ztmp),y';
        listing[i+5] := #9'iny';
	listing[i+6] := #9'lda (bp2),y';
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
// ===                        optymalizacja EAX.                          === //
// -----------------------------------------------------------------------------

    if (pos('lda eax', listing[i]) > 0) and (pos('sta STACKORIGIN', listing[i+1]) > 0) and			// lda eax			; 0
       (pos('lda eax+1', listing[i+2]) > 0) and (pos('sta STACKORIGIN+STACKWIDTH', listing[i+3]) > 0) and	// sta STACKORIGIN		; 1
       (pos('lda eax+2', listing[i+4]) > 0) and (pos('sta STACKORIGIN+STACKWIDTH*2', listing[i+5]) > 0) and	// lda eax+1			; 2
       (pos('lda eax+3', listing[i+6]) > 0) and (pos('sta STACKORIGIN+STACKWIDTH*3', listing[i+7]) > 0) and	// sta STACKORIGIN+STACKWIDTH	; 3
       (pos('lda STACKORIGIN', listing[i+8]) > 0) and (pos('sta ', listing[i+9]) > 0) and			// lda eax+2			; 4
       (listing[i+10] = '') then										// sta STACKORIGIN+STACKWIDTH*2	; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then 						// lda eax+3			; 6
     begin													// sta STACKORIGIN+STACKWIDTH*3	; 7
      listing[i+8] := listing[i];										// lda STACKORIGIN		; 8
      listing[i]   := '';											// sta				; 9
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';

      Result:=false;
     end;


     if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax', listing[i+1]) > 0) and		// lda STACK	; 0
       (pos('lda STACK', listing[i+2]) > 0) and (pos('sta eax+1', listing[i+3]) > 0) and	// sta eax	; 1
       (pos('lda eax', listing[i+4]) > 0) and (pos('sta STACK', listing[i+5]) > 0) and		// lda STACK+	; 2
       (pos('lda eax+1', listing[i+6]) = 0) then						// sta eax+1	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and 				// lda eax	; 4
        (copy(listing[i+3], 6, 256) <> copy(listing[i+6], 6, 256)) then				// sta STACK	; 5
     begin											// lda Y	; 6
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

      	Result:=false;
     end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax+1', listing[i+1]) > 0) and		// lda STACK	; 0
       (pos('lda #$00', listing[i+2]) > 0) and (pos('sta eax+2', listing[i+3]) > 0) and		// sta eax+1	; 1
       (pos('sta eax+3', listing[i+4]) > 0) then 						// lda #$00	; 2
     begin											// sta eax+2	; 3
//     	listing[i+2] := '';									// sta eax+3	; 4
	listing[i+3] := '';
	listing[i+4] := '';
      	Result:=false;
     end;


    if (pos('sta ', listing[i]) > 0) and (pos('mva ', listing[i+1]) > 0) and			// sta eax
       (pos(copy(listing[i], 6, 256), listing[i+1]) = 6) then					// mva eax v
     begin
        tmp := copy(listing[i], 6, 256);
	delete( listing[i+1], pos(tmp, listing[i+1]), length(tmp) + 1 );
	listing[i]   := #9'sta ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax+1', listing[i+1]) > 0) and		// lda STACK		// byte = byte * ?
       (pos('mva eax ', listing[i+2]) > 0) and (pos('mva eax+1 ', listing[i+3]) = 0) then	// sta eax+1
     begin											// mva eax v
	listing[i]   := '';
	listing[i+1] := '';
        Result:=false;
     end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta eax', listing[i+1]) > 0) and		// word = byte * ?
       (pos('lda STACK', listing[i+2]) > 0) and (pos('sta eax+1', listing[i+3]) > 0) and
       (pos('mva eax ', listing[i+4]) > 0) and (pos('mva eax+1 ', listing[i+5]) > 0) then
     begin
{
	lda STACKORIGIN+10		; 0
	sta eax				; 1
	lda STACKORIGIN+STACKWIDTH+10	; 2
	sta eax+1			; 3
	mva eax V			; 4
	mva eax+1 V+1			; 5
}
	delete( listing[i+4], pos('eax', listing[i+4]), 3);
	delete( listing[i+5], pos('eax+1', listing[i+5]), 5);
	listing[i+1]   := #9'mva ' + copy(listing[i], 6, 256) + copy(listing[i+4], 6, 256);
	listing[i] := #9'mva ' + copy(listing[i+2], 6, 256) + copy(listing[i+5], 6, 256);

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

        Result:=false;
     end;


// y:=256; while word(y)>=100  -> nie zadziala dla n/w optymalizacji
//
//    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$00', listing[i+1]) > 0) and         // lda           tylko dla <>0 lub =0
//       ((pos('beq ', listing[i+2]) > 0) or (pos('bne ', listing[i+2]) > 0)) then         // cmp #$00
//     begin                                                                               // beq | bne
//        listing[i+1] := '';
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

    if pos('STACK', a) > 0 then begin

      if (pos('sta STACK', a) > 0) or (pos('sty STACK', a) > 0) then                // z 'ldy ' CIRCLE wygeneruje bledny kod
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

     if pos('STACK', a) = 6 then begin
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


      if pos('mva STACK', a) > 0 then begin

       if v+1 > emptyStart then emptyStart := v + 1;


       if (pos('(bp2),y', a) > 0) then begin   // indexed mode (bp2),y

        if emptyEnd<0 then emptyEnd := i - 2;

       end else
       if (pos('adr.', a) > 0) and (pos(',y', a) > 0) then begin   // indexed mode  adr.NAME,y

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

     end;//if pos('STACK',

  end;//for //if


  for i := emptyStart to emptyEnd-1 do        // usuwamy wszystko co nie jest potrzebne
   listing[i] := ';' + listing[i];


  repeat until PeepholeOptimization;

  repeat until PeepholeOptimization_STA;

  repeat until PeepholeOptimization;

  repeat until PeepholeOptimization_STA;

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
   if (pos('ldy #1', listing[i]) > 0) or (pos('cmp ', listing[i]) > 0) then begin optimize.assign := false; Break end;


  // usuwamy puste '@'
  for i := 0 to l - 1 do begin
   if (pos('@+', listing[i]) > 0) then Break;
   if listing[i] = '@' then listing[i] := '';
  end;

  Rebuild;


  if not optimize.assign then
   for i := 0 to l - 1 do begin


    if (pos('lda ', listing[i]) > 0) and (pos('ldy #1', listing[i+1]) > 0) and		// lda		; 0
       (pos('and #$00', listing[i+2]) > 0) and (pos('bne @+', listing[i+3]) > 0) and	// ldy #1	; 1
       (pos('lda ', listing[i+4]) > 0) then						// and #$00	; 2
     begin										// bne @+	; 3
	listing[i] := '';								// lda		; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if ( pos('and #$00', listing[i]) > 0 ) and (i>0) then				// lda #$00	; -1
     if pos('lda #$00', listing[i-1]) > 0 then begin					// and #$00	; 0
        listing[i] := '';
	Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) and								// sta STACKORIGIN+N1		; 0
       ((pos('ora STACK', listing[i+2]) > 0) or (pos('and STACK', listing[i+2]) > 0) or (pos('eor STACK', listing[i+2]) > 0)) and		// lda STACKORIGIN+N0		; 1
       (pos('sta STACK', listing[i+3]) > 0) then												// ora|and|eor STACKORIGIN+N1	; 2
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin	// sta STACKORIGIN+N0		; 3
       listing[i]   := '';
       listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
       listing[i+2] := '';
       Result:=false;
       end;


    if (pos('sty STACK', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) and								// sty STACKORIGIN+N1		; 0
       ((pos('ora STACK', listing[i+2]) > 0) or (pos('and STACK', listing[i+2]) > 0) or (pos('eor STACK', listing[i+2]) > 0)) and		// lda STACKORIGIN+N0		; 1
       (pos('sta STACK', listing[i+3]) > 0) then												// ora|and|eor STACKORIGIN+N1	; 2
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then begin	// sta STACKORIGIN+N0		; 3
       listing[i]   := #9'tya';
       listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
       listing[i+2] := '';
       Result:=false;
       end;


    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$80', listing[i+1]) > 0) and	// lda			; 0	>= 128
       (pos('bcs @+', listing[i+2]) > 0) and (pos(#9'dey', listing[i+3]) > 0) then	// cmp #$80		; 1
     begin										// bcs @+		; 2
	listing[i+1] := #9'bmi @+';							// dey			; 3
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$7F', listing[i+1]) > 0) and	// lda			; 0	> 127
       (pos(#9'seq', listing[i+2]) > 0) and (pos('bcs @+', listing[i+3]) > 0) and	// cmp #$7F		; 1
       (pos(#9'dey', listing[i+4]) > 0) then						// seq			; 2
     begin										// bcs @+		; 3
	listing[i+1] := #9'bmi @+';							// dey			; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$7F', listing[i+1]) > 0) and	// lda			; 0	<= 127
       (pos('bcc @+', listing[i+2]) > 0) and (pos('beq @+', listing[i+3]) > 0) and	// cmp #$7F		; 1
       (pos(#9'dey', listing[i+4]) > 0) then						// bcc @+		; 2
     begin										// beq @+		; 3
	listing[i+1] := #9'bpl @+';							// dey			; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$7F', listing[i+1]) > 0) and	// lda			; 0	<= 127	FOR
       (pos('bcc *+7', listing[i+2]) > 0) and (pos('beq *+5', listing[i+3]) > 0) then	// cmp #$7F		; 1
     begin										// bcc *+7		; 2
	listing[i+1] := #9'bpl *+5';							// beq *+5		; 3
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$00', listing[i+1]) > 0) and	// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (pos(#9'dey', listing[i+3]) > 0) and						// cmp #$00		; 1	!!! to oznacza krotki test !!!
       ((pos('beq ', listing[i+2]) > 0) or (pos('bne ', listing[i+2]) > 0) or		// beq|bne|seq|sne	; 2
	(pos(#9'seq', listing[i+2]) > 0) or (pos(#9'sne', listing[i+2]) > 0)) then	// dey			; 3
     begin
        listing[i+1] := '';
	Result:=false;
     end;


    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$00', listing[i+1]) > 0) and	// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (listing[i+2] = '@') and								// cmp #$00		; 1
       (pos(#9'dey', listing[i+4]) > 0) and						// @			; 2	!!! to oznacza krotki test !!!
       ((pos('beq ', listing[i+3]) > 0) or (pos('bne ', listing[i+3]) > 0)) then	// beq|bne		; 3
     begin										// dey			; 4
        listing[i+1] := '';
	Result:=false;
     end;


{	!!! optymalizacja potencjalnie niebezpieczna

    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$00', listing[i+1]) > 0) and	// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (pos('lda ', listing[i+3]) > 0) and						// cmp #$00		; 1
       ((pos('beq ', listing[i+2]) > 0) or (pos('bne ', listing[i+2]) > 0)) then	// beq|bne		; 2
     begin										// lda			; 3
        listing[i+1] := '';
	Result:=false;
     end;
}

    if (pos('lda ', listing[i]) > 0) and (pos('cmp #$00', listing[i+1]) > 0) and	// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       (listing[i+2] = '@') and								// cmp #$00		; 1
       (pos(#9'dey', listing[i+5]) > 0) and						// @			; 2	!!! to oznacza krotki test !!!
       (pos(#9'seq', listing[i+3]) > 0) and						// seq			; 3
       ((pos('bpl ', listing[i+4]) > 0) or (pos('bcs ', listing[i+4]) > 0)) then	// bpl|bcs		; 4
     begin										// dey			; 5
        listing[i+1] := '';
	Result:=false;
     end;


     if (pos('lda #$00', listing[i]) > 0) and (pos('cmp #$00', listing[i+1]) > 0) and	// lda #$00		; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       	(pos('bne ', listing[i+2]) > 0) then						// cmp #$00		; 1
     begin										// bne 			; 2	!!! to oznacza krotki test !!!
        listing[i]   := '';
        listing[i+1] := '';
        listing[i+2] := '';
	Result:=false;
     end;


    if ((pos('and ', listing[i]) > 0) or (pos('ora ', listing[i]) > 0) or
        (pos('eor ', listing[i]) > 0)) and    						// and|ora|eor #	; 0
       (pos(',y', listing[i]) = 0) and							// ldy #1		; 1
       (pos('ldy #1', listing[i+1]) > 0) and (pos('cmp #$00', listing[i+2]) > 0) and	// cmp #$00		; 2
       ((pos('beq ', listing[i+3]) > 0) or (pos('bne ', listing[i+3]) > 0) ) then	// beq|bne		; 3
     begin
        a := listing[i];
	listing[i]   := listing[i+1];
	listing[i+1] := a;
	listing[i+2] := '';
	Result:=false;
     end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('lda STACK', listing[i+1]) > 0) then	// sta STACKORIGIN+9	; 0
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin		// lda STACKORIGIN+9	; 1
        listing[i]   := '';
        listing[i+1] := '';
	Result:=false;
     end;


    if ((pos('and ', listing[i]) > 0) or (pos('ora ', listing[i]) > 0) or (pos('eor ', listing[i]) > 0)) and	// and|ora|eor		; 0
       (pos('sta STACK', listing[i+1]) > 0) and (pos('ldy #1', listing[i+2]) > 0) and				// sta STACKORIGIN+N	; 1
       (pos('lda STACK', listing[i+3]) > 0) and 								// ldy #1		; 2
       ((pos('bne @+', listing[i+4]) > 0) or (pos('beq @+', listing[i+4]) > 0)) then				// lda STACKORIGIN+N	; 3
     if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then begin					// beq @+|bneQ+		; 4
       listing[i+1] := '';
       listing[i+3] := #9'cmp #$00';
       Result:=false;
      end;


    if (pos('ldy #1', listing[i]) > 0) and (pos('lda ', listing[i+1]) > 0) and 		// ldy #1		; 0
       (pos('sta STACK', listing[i+2]) > 0) and (pos(',y', listing[i+1]) > 0) and	// lda ,y		; 1
       (pos('lda ', listing[i+3]) > 0) and (pos(',y', listing[i+3]) = 0) and		// sta STACKORIGIN+N	; 2
       (pos('cmp STACK', listing[i+4]) > 0) then			 		// lda 			; 3
     if copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256) then begin		// cmp STACKORIGIN+N	; 4
       listing[i+4] := #9'cmp ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       Result:=false;
      end;


    if (pos('sta STACK', listing[i]) > 0) and (pos('ldy #1', listing[i+1]) > 0) and	// sta STACKORIGIN+N	; 0
       (pos('lda STACK', listing[i+2]) > 0) and						// ldy #1		; 1
       ((pos('cmp ', listing[i+3]) > 0) or (pos('and ', listing[i+3]) > 0) or		// lda STACKORIGIN+N	; 2
        (pos('ora ', listing[i+3]) > 0) or (pos('eor ', listing[i+3]) > 0)) then	// cmp|and|ora|eor	; 3
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin
       listing[i]   := '';
       listing[i+2] := '';
       Result:=false;
      end;


    if (pos(',y', listing[i]) = 0) and
       (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// lda ~,y		; 0
       (pos('ldy #1', listing[i+2]) > 0) and						// sta STACKORIGIN+N	; 1
       (pos('lda ', listing[i+3]) > 0) and						// ldy #1		; 2
       (pos('cmp STACK', listing[i+4]) > 0) then					// lda 			; 3
     if copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256) then begin		// cmp STACKORIGIN+N	; 4

       listing[i+4] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
      end;


    if (pos(',y', listing[i]) = 0) and							// lda ~,y		; 0
       (pos('lda ', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and	// sta STACKORIGIN+N	; 1
       (pos('ldy ', listing[i+2]) > 0) and						// ldy			; 2
       (pos('lda ', listing[i+3]) > 0) and (pos(',y', listing[i+3]) > 0) and		// lda ,y		; 3
       (pos('sta STACK', listing[i+4]) > 0) and						// sta STACK		; 4
       (pos('ldy #1', listing[i+5]) > 0) and						// ldy #1		; 5
       (pos('lda ', listing[i+6]) > 0) and						// lda STACKORIGIN+N	; 6
       (pos('cmp STACK', listing[i+7]) > 0) then					// cmp STACK		; 7
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then begin

       listing[i+6] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       Result:=false;
      end;


    if (pos('sty STACKORIGIN+9', listing[i]) > 0) and (pos('.ifdef IFTMP_', listing[i+1]) > 0) and
       (pos('lda STACKORIGIN+9', listing[i+2]) > 0) and (pos('sta IFTMP_', listing[i+3]) > 0) and
       (pos(#9'eif', listing[i+4]) > 0) and (pos('lda STACKORIGIN+9', listing[i+5]) > 0) then begin
{
	sty STACKORIGIN+9        ; 0
	.ifdef IFTMP_29          ; 1
	lda STACKORIGIN+9        ; 2
	sta IFTMP_29             ; 3
	eif                      ; 4
	lda STACKORIGIN+9        ; 5
	bne *+5                  ; 6
	jmp l_030F               ; 7
}
       listing[i]   := '';
       listing[i+2] := '';
       listing[i+3] := #9'sty '+copy(listing[i+3], 6, 256);
       listing[i+5] := #9'tya';
       Result:=false;
       end;


    if (pos('sta STACKORIGIN+9', listing[i]) > 0) and (pos('.ifdef IFTMP_', listing[i+1]) > 0) and
       (pos('lda STACKORIGIN+9', listing[i+2]) > 0) and (pos('sta IFTMP_', listing[i+3]) > 0) and
       (pos(#9'eif', listing[i+4]) > 0) and (pos('lda STACKORIGIN+9', listing[i+5]) > 0) then begin
{
	sta STACKORIGIN+9        ; 0
	.ifdef iftmp_26          ; 1
	lda STACKORIGIN+9        ; 2
	sta iftmp_26             ; 3
	eif                      ; 4
	lda STACKORIGIN+9        ; 5
}
       listing[i]   := '';
       listing[i+2] := '';
       listing[i+5] := '';
       Result:=false;
    end;


    if (pos('sty STACKORIGIN+9', listing[i]) > 0) and
       (pos('lda STACKORIGIN+9', listing[i+1]) > 0) and (pos('jmp l_', listing[i+3]) > 0) then begin
{
	sty STACKORIGIN+9        ; 0
	lda STACKORIGIN+9        ; 1
	bne *+5                  ; 2
	jmp l_0087               ; 3
}
       listing[i]   := #9'tya';
       listing[i+1] := '';

       if (pos('ldy #1', listing[0]) > 0) and (pos(#9'dey', listing[i-2]) > 0) then begin

        listing[i-2] := listing[i+3];

        listing[0] := '';
        listing[i] := '';
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';
       end;

       Result:=false;
    end;


    if (pos('lda STACK', listing[i]) > 0) and (pos('sta STACK', listing[i+1]) > 0) and				// lda STACKORIGIN+10	; 0
       (pos('lda STACK', listing[i+2]) > 0) then								// sta STACKORIGIN+10	; 1
       if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and						// lda STACKORIGIN+10	; 2
          (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
        listing[i+1] := '';
        listing[i+2] := '';
	Result:=false;
       end;


    if ((pos('sty STACKORIGIN+9', listing[i]) > 0) or (pos('sta STACKORIGIN+9', listing[i]) > 0)) and		// sty|sta STACKORIGIN+9	; 0
       (pos('mva STACKORIGIN+9', listing[i+1]) > 0) then begin							// mva STACKORIGIN+9 STOP	; 1
        listing[i+1] := copy(listing[i], 1, 5)+copy(listing[i+1], pos('STACK', listing[i+1]) + 14, 256);
        listing[i]   := '';
	Result:=false;
    end;

   end;   // for


   Rebuild;


   for i := 0 to l - 1 do begin

    if (pos('ldy #1', listing[i]) > 0) then begin
{
	ldy #$01
  	mwa ptr bp2
	lda (bp2),y
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
       listing[l+2] := #9'sta bp2';
       listing[l+3] := #9'lda '+arg0+'+1';
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta bp2+1';
       listing[l+6] := #9'ldy #$00';
       listing[l+7] := #9'lda (bp2),y';
       listing[l+8] := #9'sta '+GetARG(0, x);
       listing[l+9] := #9'iny';
       listing[l+10]:= #9'lda (bp2),y';
       listing[l+11]:= #9'sta '+GetARG(1, x);

       inc(l, 12);
      end;


      if pos('@pushCARD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]   := #9'lda '+arg0;
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta bp2';
       listing[l+3] := #9'lda '+arg0+'+1';
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta bp2+1';
       listing[l+6] := #9'ldy #$00';
       listing[l+7] := #9'lda (bp2),y';
       listing[l+8] := #9'sta '+GetARG(0, x);
       listing[l+9] := #9'iny';
       listing[l+10]:= #9'lda (bp2),y';
       listing[l+11]:= #9'sta '+GetARG(1, x);
       listing[l+12]:= #9'iny';
       listing[l+13]:= #9'lda (bp2),y';
       listing[l+14]:= #9'sta '+GetARG(2, x);
       listing[l+15]:= #9'iny';
       listing[l+16]:= #9'lda (bp2),y';
       listing[l+17]:= #9'sta '+GetARG(3, x);

       inc(l, 18);
      end;


      if pos('@pullWORD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]    := #9'lda '+arg0;
       listing[l+1]  := #9'add '+GetARG(0, x-1);
       listing[l+2]  := #9'sta bp2';
       listing[l+3]  := #9'lda '+arg0+'+1';
       listing[l+4]  := #9'adc '+GetARG(1, x-1);
       listing[l+5]  := #9'sta bp2+1';
       listing[l+6]  := #9'ldy #$00';
       listing[l+7]  := #9'lda '+GetARG(0, x);
       listing[l+8]  := #9'sta (bp2),y';
       listing[l+9]  := #9'iny';
       listing[l+10] := #9'lda '+GetARG(1, x);
       listing[l+11] := #9'sta (bp2),y';

       inc(l, 12);
      end;


      if pos('@pullCARD', a)>0 then begin
       t:='';

       arg0:=copy(a, 12, 256);

       listing[l]    := #9'lda '+arg0;
       listing[l+1]  := #9'add '+GetARG(0, x-1);
       listing[l+2]  := #9'sta bp2';
       listing[l+3]  := #9'lda '+arg0+'+1';
       listing[l+4]  := #9'adc '+GetARG(1, x-1);
       listing[l+5]  := #9'sta bp2+1';
       listing[l+6]  := #9'ldy #$00';
       listing[l+7]  := #9'lda '+GetARG(0, x);
       listing[l+8]  := #9'sta (bp2),y';
       listing[l+9]  := #9'iny';
       listing[l+10] := #9'lda '+GetARG(1, x);
       listing[l+11] := #9'sta (bp2),y';
       listing[l+12] := #9'iny';
       listing[l+13] := #9'lda '+GetARG(2, x);
       listing[l+14] := #9'sta (bp2),y';
       listing[l+15] := #9'iny';
       listing[l+16] := #9'lda '+GetARG(3, x);
       listing[l+17] := #9'sta (bp2),y';

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
       listing[l+1] := #9'lda '+GetARG(1, x-1);        // lda label     -> zastepujemy sub #$00 przez SEC !!!
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
       if arg0 = '@round' then begin
        t:='';

        listing[l]   := #9'lda '+GetARG(0, x);
        listing[l+1] := #9'sta '+GetARG(0, x);
        listing[l+2] := #9'lda '+GetARG(1, x);
        listing[l+3] := #9'sta '+GetARG(1, x);
        listing[l+4] := #9'lda '+GetARG(2, x);
        listing[l+5] := #9'sta '+GetARG(2, x);
        listing[l+6] := #9'lda '+GetARG(3, x);
        listing[l+7] := #9'sta '+GetARG(3, x);
	listing[l+8] := #9'tay';
	listing[l+9] := #9'bpl @+';

	inc(l, 10);

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

	listing[l]    := '@';
	listing[l+1]  := #9'lda '+GetARG(0, x);
	listing[l+2]  := #9'cmp #$80';

	inc(l, 3);

	listing[l]    := #9'lda '+GetARG(1, x);
	listing[l+1]  := #9'adc #$00';
	listing[l+2]  := #9'sta '+GetARG(0, x);
	listing[l+3]  := #9'lda '+GetARG(2, x);
	listing[l+4]  := #9'adc #$00';
	listing[l+5]  := #9'sta '+GetARG(1, x);
	listing[l+6]  := #9'lda '+GetARG(3, x);
	listing[l+7] := #9'adc #$00';
	listing[l+8] := #9'sta '+GetARG(2, x);
	listing[l+9] := #9'lda #$00';
	listing[l+10] := #9'sta '+GetARG(3, x);
	listing[l+11] := #9'tya';
	listing[l+12] := #9'bpl @+';

	inc(l, 13);

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

	listing[l]  := '@';
        listing[l+1] := #9'lda '+GetARG(0, x);
        listing[l+2] := #9'sta '+GetARG(0, x);
        listing[l+3] := #9'lda '+GetARG(1, x);
        listing[l+4] := #9'sta '+GetARG(1, x);
        listing[l+5] := #9'lda '+GetARG(2, x);
        listing[l+6] := #9'sta '+GetARG(2, x);
        listing[l+7] := #9'lda '+GetARG(3, x);
        listing[l+8] := #9'sta '+GetARG(3, x);

	inc(l, 9);

       end else
       if arg0 = '@trunc' then begin
        t:='';

        listing[l]   := #9'lda '+GetARG(0, x);
        listing[l+1] := #9'sta '+GetARG(0, x);
        listing[l+2] := #9'lda '+GetARG(1, x);
        listing[l+3] := #9'sta '+GetARG(1, x);
        listing[l+4] := #9'lda '+GetARG(2, x);
        listing[l+5] := #9'sta '+GetARG(2, x);
        listing[l+6] := #9'lda '+GetARG(3, x);
        listing[l+7] := #9'sta '+GetARG(3, x);

	inc(l, 8);

	listing[l]     := #9'tay';
	listing[l+1]   := #9'bpl @+';

	inc(l, 2);

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

	listing[l]    := '@';
	listing[l+1]  := #9'lda '+GetARG(1, x);
	listing[l+2]  := #9'sta '+GetARG(0, x);
	listing[l+3]  := #9'lda '+GetARG(2, x);
	listing[l+4]  := #9'sta '+GetARG(1, x);
	listing[l+5]  := #9'lda '+GetARG(3, x);
	listing[l+6]  := #9'sta '+GetARG(2, x);
	listing[l+7]  := #9'lda #$00';
	listing[l+8]  := #9'sta '+GetARG(3, x);
	listing[l+9]  := #9'tya';
	listing[l+10] := #9'bpl @+';

	inc(l, 11);

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

	listing[l]  := '@';
        listing[l+1] := #9'lda '+GetARG(0, x);
        listing[l+2] := #9'sta '+GetARG(0, x);
        listing[l+3] := #9'lda '+GetARG(1, x);
        listing[l+4] := #9'sta '+GetARG(1, x);
        listing[l+5] := #9'lda '+GetARG(2, x);
        listing[l+6] := #9'sta '+GetARG(2, x);
        listing[l+7] := #9'lda '+GetARG(3, x);
        listing[l+8] := #9'sta '+GetARG(3, x);

	inc(l, 9);

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

      if arg0 = 'movaBX_EAX' then begin
	t:='';

	s[x-1][0] := #9'lda eax';
	s[x-1][1] := #9'lda eax+1';
	s[x-1][2] := #9'lda eax+2';
	s[x-1][3] := #9'lda eax+3';

      end else

      if (arg0 = 'imulBYTE') or (arg0 = 'mulSHORTINT') then begin
        t:='';

	listing[l]    := #9'lda '+GetARG(0, x);
	listing[l+1]  := #9'sta ecx';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+2] := #9'sta ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(0, x-1);
	listing[l+3]  := #9'sta eax';

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

        if (arg0 = 'imulBYTE') and (k in [0,1,2,4,8,16,32]) then begin

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

	  listing[l+1] := #9'sta eax';

	  inc(l, 2);

	 end else begin

          listing[l]   := #9'lda ' + GetARG(0, x);
	  listing[l+1] := #9'sta eax';
          listing[l+2] := #9'lda ' + GetARG(1, x);
	  listing[l+3] := #9'sta eax+1';
          listing[l+4] := #9'lda ' + GetARG(2, x);
	  listing[l+5] := #9'sta eax+2';
          listing[l+6] := #9'lda ' + GetARG(3, x);
	  listing[l+7] := #9'sta eax+3';

	  inc(l, 8);
	 end;

	end else
	 inc(l, 9);

	if arg0 = 'mulSHORTINT' then begin

	listing[l]   := #9'lda ztmp10';
	listing[l+1] := #9'bpl @+';
	listing[l+2] := #9'sec';
	listing[l+3] := #9'lda eax+1';
	listing[l+4] := #9'sbc ztmp8';
  	listing[l+5] := #9'sta eax+1';

	listing[l+6] := '@';

	listing[l+7]  := #9'lda ztmp8';
	listing[l+8]  := #9'bpl @+';
	listing[l+9]  := #9'sec';
	listing[l+10] := #9'lda eax+1';
	listing[l+11] := #9'sbc ztmp10';
	listing[l+12] := #9'sta eax+1';

        listing[l+13] := '@';

        listing[l+14] := #9'lda eax';
        listing[l+15] := #9'sta '+GetARG(0, x-1);
        listing[l+16] := #9'lda eax+1';
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

	listing[l]    := #9'lda '+GetARG(0, x);		t0 := listing[l];
	listing[l+1]  := #9'sta ecx';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+2] := #9'sta ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(1, x);		t1 := listing[l+2];
	listing[l+3]  := #9'sta ecx+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+4] := #9'sta ztmp9';
	 inc(l);
	end;

	listing[l+4]  := #9'lda '+GetARG(0, x-1);	t2 := listing[l+4];
	listing[l+5]  := #9'sta eax';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+6] := #9'sta ztmp10';
	 inc(l);
	end;

	listing[l+6]  := #9'lda '+GetARG(1, x-1);	t3 :=listing[l+6];
	listing[l+7]  := #9'sta eax+1';

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
	   listing[l+1]  := #9'sta eax';
	   listing[l+2]  := #9'lda #$'+IntToHex(byte(k shr 8), 2);
	   listing[l+3]  := #9'sta eax+1';

	   inc(l, 4);

	end else
	 inc(l, 13);

	if arg0 = 'mulSMALLINT' then begin

	listing[l]   := #9'lda ztmp11';
	listing[l+1] := #9'bpl @+';
	listing[l+2] := #9'sec';
	listing[l+3] := #9'lda eax+2';
	listing[l+4] := #9'sbc ztmp8';
  	listing[l+5] := #9'sta eax+2';
	listing[l+6] := #9'lda eax+3';
	listing[l+7] := #9'sbc ztmp9';
	listing[l+8] := #9'sta eax+3';

	listing[l+9] := '@';

	listing[l+10] := #9'lda ztmp9';
	listing[l+11] := #9'bpl @+';
	listing[l+12] := #9'sec';
	listing[l+13] := #9'lda eax+2';
	listing[l+14] := #9'sbc ztmp10';
	listing[l+15] := #9'sta eax+2';
	listing[l+16] := #9'lda eax+3';
	listing[l+17] := #9'sbc ztmp11';
	listing[l+18] := #9'sta eax+3';

        listing[l+19] := '@';

        listing[l+20] := #9'lda eax';
        listing[l+21] := #9'sta '+GetARG(0, x-1);
        listing[l+22] := #9'lda eax+1';
        listing[l+23] := #9'sta '+GetARG(1, x-1);
        listing[l+24] := #9'lda eax+2';
        listing[l+25] := #9'sta '+GetARG(2, x-1);
        listing[l+26] := #9'lda eax+3';
        listing[l+27] := #9'sta '+GetARG(3, x-1);

	inc(l, 28);
	end;

      end else


      if (arg0 = 'imulCARD') or (arg0 = 'mulINTEGER') then begin
        t:='';

	listing[l]    := #9'lda '+GetARG(0, x);
	listing[l+1]  := #9'sta ecx';
	listing[l+2]  := #9'lda '+GetARG(1, x);
	listing[l+3]  := #9'sta ecx+1';
	listing[l+4]  := #9'lda '+GetARG(2, x);
	listing[l+5]  := #9'sta ecx+2';
	listing[l+6]  := #9'lda '+GetARG(3, x);
	listing[l+7]  := #9'sta ecx+3';

	listing[l+8]  := #9'lda '+GetARG(0, x-1);
	listing[l+9]  := #9'sta eax';
	listing[l+10] := #9'lda '+GetARG(1, x-1);
	listing[l+11] := #9'sta eax+1';
	listing[l+12] := #9'lda '+GetARG(2, x-1);
	listing[l+13] := #9'sta eax+2';
	listing[l+14] := #9'lda '+GetARG(3, x-1);
	listing[l+15] := #9'sta eax+3';

	listing[l+16] := #9'jsr imulECX';

	inc(l, 17);

	if arg0 = 'mulINTEGER' then begin
        listing[l]   := #9'lda eax';
        listing[l+1] := #9'sta '+GetARG(0, x-1);
        listing[l+2] := #9'lda eax+1';
        listing[l+3] := #9'sta '+GetARG(1, x-1);
        listing[l+4] := #9'lda eax+2';
        listing[l+5] := #9'sta '+GetARG(2, x-1);
        listing[l+6] := #9'lda eax+3';
        listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);
	end;

      end else


      if pos('SYSTEM.MOVE', arg0) > 0 then begin
        t:='';

        listing[l]   := #9'lda '+GetARG(0, x-2);
        listing[l+1] := #9'sta edx';
        listing[l+2] := #9'lda '+GetARG(1, x-2);
        listing[l+3] := #9'sta edx+1';

        listing[l+4] := #9'lda '+GetARG(0, x-1);
        listing[l+5] := #9'sta ecx';
        listing[l+6] := #9'lda '+GetARG(1, x-1);
        listing[l+7] := #9'sta ecx+1';

        listing[l+8] := #9'lda '+GetARG(0, x);
        listing[l+9] := #9'sta eax';
        listing[l+10]:= #9'lda '+GetARG(1, x);
        listing[l+11]:= #9'sta eax+1';

        listing[l+12]:= #9'jsr @move';

        inc(l, 13);
        dec(x, 3);

      end else
      if (pos('SYSTEM.FILLCHAR', arg0) > 0) or (pos('SYSTEM.FILLBYTE', arg0) > 0) then begin
        t:='';

        listing[l]   := #9'lda '+GetARG(0, x-2);
        listing[l+1] := #9'sta edx';
        listing[l+2] := #9'lda '+GetARG(1, x-2);
        listing[l+3] := #9'sta edx+1';

        listing[l+4] := #9'lda '+GetARG(0, x-1);
        listing[l+5] := #9'sta ecx';
        listing[l+6] := #9'lda '+GetARG(1, x-1);
        listing[l+7] := #9'sta ecx+1';

        listing[l+8] := #9'lda '+GetARG(0, x);
        listing[l+9] := #9'sta eax';

        listing[l+10]:= #9'jsr @fill';

        inc(l, 11);
        dec(x, 3);

      end else
      if arg0 = 'SYSTEM.PEEK' then begin
        t:='';

        if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) then begin

          listing[l]   := #9'lda '+GetARG(1, x);
          listing[l+1] := #9'sta bp+1';
          listing[l+2] := #9'ldy '+GetARG(0, x);
          listing[l+3] := #9'lda (bp),y';
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
          listing[l+1] := #9'sta bp+1';
          listing[l+2] := #9'ldy '+GetARG(0, x-1);
          listing[l+3] := #9'lda '+GetARG(0, x);
          listing[l+4] := #9'sta (bp),y';

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
          listing[l+1] := #9'sta bp2';
          listing[l+2] := #9'lda '+GetARG(1, x);
          listing[l+3] := #9'sta bp2+1';
          listing[l+4] := #9'ldy #$00';
          listing[l+5] := #9'lda (bp2),y';
          listing[l+6] := #9'sta '+GetARG(0, x);
          listing[l+7] := #9'iny';
          listing[l+8] := #9'lda (bp2),y';
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
          listing[l+1] := #9'sta bp2';
          listing[l+2] := #9'lda '+GetARG(1, x-1);
          listing[l+3] := #9'sta bp2+1';
          listing[l+4] := #9'ldy #$00';
          listing[l+5] := #9'lda '+GetARG(0, x);
          listing[l+6] := #9'sta (bp2),y';
          listing[l+7] := #9'iny';
          listing[l+8] := #9'lda '+GetARG(1, x);
          listing[l+9] := #9'sta (bp2),y';

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
      if arg0 = 'shrAL_CL.BYTE' then begin             // SHR BYTE
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
      if arg0 = 'shrAX_CL.WORD' then begin             // SHR WORD
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
      if arg0 = 'shrEAX_CL' then begin             // SHR CARDINAL
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

      if arg0 = 'shlEAX_CL.BYTE' then begin            // SHL BYTE
        t:='';

        k := GetVAL(GetARG(0, x));


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

        if k = 24 then begin

        listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
        listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
        listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
        listing[l+6] := #9'lda ' + GetARG(0, x-1);
        listing[l+7] := #9'sta ' + GetARG(3, x-1);
        listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

        inc(l, 10);

        end else

        if k = 16 then begin

        listing[l]   := #9'lda #$00';
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

        end else

        if k = 8 then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
        listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
        listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
        listing[l+6] := #9'lda ' + GetARG(0, x-1);
        listing[l+7] := #9'sta ' + GetARG(1, x-1);
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
      if arg0 = 'shlEAX_CL.WORD' then begin            // SHL WORD
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
      if arg0 = 'shlEAX_CL.CARD' then begin            // SHL CARD
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

       inc(l, 6);
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

       inc(l, 9);
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



   if (pos('STACKORIGIN,', t) > 7) and (pos('(bp),', t) = 0) then begin        // kiedy odczytujemy tablice
    s[x][0]:=copy(a, 1, pos(' STACK', a));
    t:='';

    if pos(',y', s[x][0]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(0, x);
     listing[l+1] := #9'sta ' + GetARG(0, x);

     inc(l, 2);
    end;
   end;

   if (pos('STACKORIGIN+STACKWIDTH,', t) > 7) and (pos('(bp),', t) = 0) then begin
    s[x][1]:=copy(a, 1, pos(' STACK', a));
    t:='';

    if pos(',y', s[x][1]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(1, x);
     listing[l+1] := #9'sta ' + GetARG(1, x);

     inc(l, 2);
    end;
   end;

   if (pos('STACKORIGIN+STACKWIDTH*2,', t) > 7) and (pos('(bp),', t) = 0) then begin
    s[x][2]:=copy(a, 1, pos(' STACK', a));
    t:='';

    if pos(',y', s[x][2]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(2, x);
     listing[l+1] := #9'sta ' + GetARG(2, x);

     inc(l, 2);
    end;
   end;

   if (pos('STACKORIGIN+STACKWIDTH*3,', t) > 7) and (pos('(bp),', t) = 0) then begin
    s[x][3]:=copy(a, 1, pos(' STACK', a));
    t:='';

    if pos(',y', s[x][3]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(3, x);
     listing[l+1] := #9'sta ' + GetARG(3, x);

     inc(l, 2);
    end;
   end;



{
   if (pos('STACKORIGIN+STACKWIDTH,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x][1]:=copy(a, 1, pos(' STACK', a)); oldT:=t; t:='' end;
   if (pos('STACKORIGIN,', oldt) > 7) and (pos('sta STACKORIGIN+STACKWIDTH,', t) > 0) then begin s[x][1] := s[x][0]; oldT:=''; t:='' end;

   if (pos('STACKORIGIN+STACKWIDTH*2,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x][2]:=copy(a, 1, pos(' STACK', a)); oldT:=t; t:=''end;
   if (pos('STACKORIGIN+STACKWIDTH,', oldt) > 7) and (pos('sta STACKORIGIN+STACKWIDTH*2,', t) > 0) then begin s[x][2] := s[x][1]; oldT:=''; t:='' end;

   if (pos('STACKORIGIN+STACKWIDTH*3,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x][3]:=copy(a, 1, pos(' STACK', a)); oldT:=t; t:='' end;
   if (pos('STACKORIGIN+STACKWIDTH*2,', oldt) > 7) and (pos('sta STACKORIGIN+STACKWIDTH*3,', t) > 0) then begin s[x][3] := s[x][2]; oldT:=''; t:='' end;
}


   if (pos('STACKORIGIN-1+STACKWIDTH,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x-1][1]:=copy(a, 1, pos(' STACK', a)); t:='' end;
   if (pos('STACKORIGIN-1+STACKWIDTH*2,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x-1][2]:=copy(a, 1, pos(' STACK', a)); t:='' end;
   if (pos('STACKORIGIN-1+STACKWIDTH*3,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x-1][3]:=copy(a, 1, pos(' STACK', a)); t:='' end;

   if (pos('STACKORIGIN+1+STACKWIDTH,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x+1][1]:=copy(a, 1, pos(' STACK', a)); t:='' end;
   if (pos('STACKORIGIN+1+STACKWIDTH*2,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x+1][2]:=copy(a, 1, pos(' STACK', a)); t:='' end;
   if (pos('STACKORIGIN+1+STACKWIDTH*3,', t) > 7) and (pos('(bp),', t) = 0) then begin s[x+1][3]:=copy(a, 1, pos(' STACK', a)); t:='' end;



   if (pos('STACKORIGIN,', t) = 6) then begin
    k:=pos('STACK', t);
    delete(t, k, 13);

    arg0 := GetARG(0, x);
    insert(arg0, t, k );
   end;

   if (pos('STACKORIGIN+STACKWIDTH,', t) = 6) then begin
    k:=pos('STACK', t);
    delete(t, k, 24);

    arg0 := GetARG(1, x);
    insert(arg0, t, k );
   end;

   if (pos('STACKORIGIN+STACKWIDTH*2,', t) = 6) then begin
    k:=pos('STACK', t);
    delete(t, k, 26);

    arg0 := GetARG(2, x);
    insert(arg0, t, k );
   end;

   if (pos('STACKORIGIN+STACKWIDTH*3,', t) = 6) then begin
    k:=pos('STACK', t);
    delete(t, k, 26);

    arg0 := GetARG(3, x);
    insert(arg0, t, k );
   end;


   if (pos('STACKORIGIN-1,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(0, x-1);

   if (pos('STACKORIGIN-1+STACKWIDTH,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(1, x-1);

   if (pos('STACKORIGIN-1+STACKWIDTH*2,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(2, x-1);

   if (pos('STACKORIGIN-1+STACKWIDTH*3,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(3, x-1);



   if (pos('STACKORIGIN+1,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(0, x+1);

   if (pos('STACKORIGIN+1+STACKWIDTH,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(1, x+1);

   if (pos('STACKORIGIN+1+STACKWIDTH*2,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(2, x+1);

   if (pos('STACKORIGIN+1+STACKWIDTH*3,', t) = 6) then
     t:=copy(a, 1, pos(' STACK', a)) + GetARG(3, x+1);


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

{
    if (pos('cmp #$00', listing[i]) > 0) and (listing[i+1] = '@') and (pos('bcs *+5', listing[i+2]) > 0) then	// lda i+1	// -4
     if (pos('lda ', listing[i-1]) > 0) and (pos('bne @+', listing[i-2]) > 0) and				// cmp #$00	// -3
        (pos('cmp #$00', listing[i-3]) > 0) and (pos('lda ', listing[i-4]) > 0) and (i-4 = 0) then		// bne @+	// -2
       begin													// lda i	// -1
	listing[i-3] := '';											// cmp #$00	// 0
	listing[i-2] := '';											//@		// 1
	listing[i-1] := #9'ora ' + copy(listing[i-1], 6, 256);							// bcs *+5	// 2
	listing[i+1] := '';
       end;
}
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
        if (pos(#9'iny', listing[k]) > 0) or (pos(#9'dey', listing[k]) > 0) or (pos(#9'tay', listing[k]) > 0) or (pos('mvy ', listing[k]) > 0) then Break;

    end;


(* -------------------------------------------------------------------------- *)
//				opty	REG A
(* -------------------------------------------------------------------------- *)

  Rebuild;

  arg0 := '';

  if l < 3 then
   for i := 0 to l - 1 do
    if pos('mva #$', listing[i]) > 0 then begin

     arg0:=GetString(listing[i]);

     if arg0 = optyA then listing[i] := #9'sta ' + copy(listing[i], pos('mva #$', listing[i]) + 9, 256);

     optyA := arg0;

    end else
     if (pos('mva ', listing[i]) > 0) or (pos(#9'tya', listing[i]) > 0) or (pos('lda ', listing[i]) > 0) then begin arg0 := ''; optyA := '' end;


  optyA := arg0;


(* -------------------------------------------------------------------------- *)
//				opty	BP2
(* -------------------------------------------------------------------------- *)

  Rebuild;

  for i := 0 to l - 1 do begin

   if listing[i]<>'' then                                                      // mwa a bp2
    if ((pos('mwa ', listing[i])>0) and (pos(' bp2', listing[i])>0)) or
       ((pos('mwy ', listing[i])>0) and (pos(' bp2', listing[i])>0)) then begin
         arg0:=listing[i]; arg0[4]:='?';

         if arg0 = optyBP2 then listing[i] := '';

         optyBP2 := arg0;
       end;

    if listing[i]<>'' then Writeln(OutFile, listing[i]);

  end;


(* -------------------------------------------------------------------------- *)


 end else begin

  optyA := '';
  optyBP2 := '';

  if x = 51 then
   writeln(OutFile, #13#10'; optimize FAIL ('+''''+arg0+''''+ ', '+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line))
  else
   writeln(OutFile, #13#10'; optimize FAIL ('+IntToStr(x)+', '+UnitName[optimize.unitIndex].Name+'), line = '+IntToStr(optimize.line));


  l := High(OptimizeBuf);
  for i := 0 to l - 1 do
   listing[i] := OptimizeBuf[i].line;

{$IFDEF OPTIMIZECODE}

  repeat until OptimizeStack;             // optymalizacja lda stack... \ sta stack...

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


procedure asm65(a: string; comment : string ='');
var len, i: integer;
    optimize_code: Boolean;
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

   if High(OptimizeBuf) > 0 then
     OptimizeASM
   else begin

    write(OutFile, a);

    if comment<>'' then begin

     len:=0;

     for i := 1 to length(a) do
      if a[i] = #9 then
       inc(len, 8-(len mod 8))
      else
       if not(a[i] in [#13, #10]) then inc(len);

     while len<56 do begin write(OutFile, #9); inc(len, 8) end;

     writeln(OutFile, comment);

    end else
     writeln(OutFile);

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
  OldNumTok, UnitIndex, IncludeIndex, Line, Err, cnt: Integer;
  Tmp: Int64;
  AsmFound, UsesFound: Boolean;
  ch, ch2: Char;
  CurToken: Byte;


  procedure TokenizeUnit(a: integer); forward;


  procedure Tokenize(fnam: string);
  var InFile: file of char;
      _line: integer;
      _uidx: integer;


  function FindFile(Name: string; ftyp: TString): string;
  begin

  {$IFDEF UNIX}
   if Pos('\', Name) > 0 then
    Name := LowerCase(StringReplace(Name, '\', '/', [rfReplaceAll]));
  {$ENDIF}

  {$IFDEF LINUX}
    Name := LowerCase(Name);
  {$ENDIF}

   Result := UnitPath + Name;

   if not FileExists( Result ) then begin
    Result := Name;

    if not FileExists( Result ) then begin
     Result := FilePath + Name;

     if not FileExists( Result ) then
       Error(NumTok, 'Can''t open '+ftyp+' file '''+Result+'''');

    end;

   end;

  end;


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

         for j := 2 to NumUnits do                   // kasujemy wczesniejsze odwolania
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
      if c = '*' then i := 3
      else            i := 1;
     3:
      if c = '*' then i := 4;
     4:
      if c = ')' then i := 1
      else            i := 3;
     5:
      if c = '$' then i := 6
      else            i := 0;
     6:
      if UpCase(c) in AllowLabelFirstChars then
      begin
       Result := UpCase(c);
       i := 7;
      end else i := 0;
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
  var i: integer;
      cmd, s, nam: string;
      found: Boolean;
  begin

    if UpCase(d[1]) in AllowLabelFirstChars then begin

     i:=1;
     cmd := get_label(i, d);

     if cmd = 'I' then begin                           // {$i filename}
                                                       // {$i+-} iocheck
      if d[i]='+' then begin AddToken(IOCHECKON, UnitIndex, Line, 1, 0); AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0) end else
       if d[i]='-' then begin AddToken(IOCHECKOFF, UnitIndex, Line, 1, 0); AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0) end else
        begin
         AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

         s := LowerCase( get_string(i, d) );

         nam := FindFile(s, 'include');

         dec(NumTok);

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

     end else
      if cmd = 'R' then begin                          // {$r filename}
       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       s := LowerCase( get_string(i, d) );
       AddResource( FindFile(s, 'resource') );

       dec(NumTok);
      end else

       if cmd = 'C' then begin                          // {$c 6502|65816}
        AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

        s := get_digit(i, d);

        val(s,CPUMode, Err);

        if Err > 0 then
         iError(NumTok, OrdinalExpExpected);

        GetCommonConstType(NumTok, CARDINALTOK, GetValueType(CPUMode));

        dec(NumTok);

       end else

       if cmd = 'F' then begin                          // {$f address}
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
        Error(NumTok, 'Illegal compiler directive $'+cmd);

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

    if c2='*' then begin                               // Skip comments (*   *)

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

    repeat                                             // Skip comments
      Read(InFile, c);

      if dir then directive := directive + c;

      if c<>'}' then
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

  if c = #10 then Inc(Line);                           // Increment current line number
  end;


  procedure SafeReadChar(var c: Char);
  begin

  ReadChar(c);

  c := UpCase(c);
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
  (*  zamiana znakow ATASCII na INTERNAL                                        *)
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

    if ch='%' then begin                  // binary

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

    if ch='$' then begin                  // hexadecimal

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

      while ch in ['0'..'9'] do           // Number suspected
        begin
        Num := Num + ch;
        SafeReadChar(ch);
        end;

  end;


  begin

  AssignFile(InFile, fnam );              // UnitIndex = 1 main program

  Reset(InFile);

  Text := '';

  try
    while TRUE do
      begin
      OldNumTok := NumTok;

      repeat
        ReadChar(ch);
      until not (ch in [' ', #9, #10, #13, '{'(*, '}'*)]);    // Skip space, tab, line feed, carriage return, comment braces


      ch := UpCase(ch);


      Num:='';
      if ch in ['0'..'9', '$', '%'] then ReadNumber;

      if Length(Num) > 0 then             // Number found
        begin
        AddToken(INTNUMBERTOK, UnitIndex, Line, length(Num), StrToInt(Num));

        if ch = '.' then                  // Fractional part suspected
          begin
          SafeReadChar(ch);
          if ch = '.' then
            Seek(InFile, FilePos(InFile) - 1)   // Range ('..') token
          else
            begin                         // Fractional part found
            Frac := '.';

            while ch in ['0'..'9'] do
              begin
              Frac := Frac + ch;
              SafeReadChar(ch);
              end;

            Tok[NumTok].Kind := FRACNUMBERTOK;
            Tok[NumTok].FracValue := StrToFloat(Num + Frac);
            Tok[NumTok].Column := Tok[NumTok-1].Column + length(Num) + length(Frac);
            end;
          end;

        Num := '';
        Frac := '';
        end;


      if ch in ['A'..'Z', '_'] then         // Keyword or identifier suspected
        begin
        Text := '';

        err:=0;
        repeat
          Text := Text + ch;
          SafeReadChar(ch);
          inc(err);
        until not (ch in ['A'..'Z', '_', '0'..'9','.']);

        if Text[length(Text)] = '.' then begin
         SetLength(Text, length(Text)-1);
         Seek(InFile, FilePos(InFile) - 2);
        end;

        if err > 255 then
         Error(NumTok, 'Constant strings can''t be longer than 255 chars');

        if Length(Text) > 0 then
          begin

         CurToken := GetStandardToken(Text);
         if CurToken = FLOATTOK then CurToken := SINGLETOK;

         AddToken(0, UnitIndex, Line, length(Text), 0);

         if CurToken = ASMTOK then begin

          Tok[NumTok].Kind := CurToken;

          AsmFound:=true;

          repeat
           ReadChar(ch);
          until not (ch in [' ', #9, #10, #13, '{', '}']);    // Skip space, tab, line feed, carriage return, comment braces

          AsmFound:=false;

          inc(AsmBlockIndex);

          if AsmBlockIndex > High(AsmBlock) then begin
           Error(NumTok, 'Out of resources, ASMBLOCK');

           halt(2);
          end;

         end else begin

           if CurToken <> 0 then begin            // Keyword found
             Tok[NumTok].Kind := CurToken;

	     if CurToken = USESTOK then UsesFound := true;

	   end
           else begin                             // Identifier found
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
          if Length(Text) = 1 then
            AddToken(CHARLITERALTOK, UnitIndex, Line, 1, Ord(Text[1]))
          else begin
            AddToken(STRINGLITERALTOK, UnitIndex, Line, length(Text), 0);
            DefineStaticString(NumTok, Text);
          end;

         Text := '';

        end;


      if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then begin
        AddToken(GetStandardToken(ch), UnitIndex, Line, 1, 0);

	  if UsesFound and (ch = ';') then
	    if UsesOn then ReadUses;
      end;


//      if ch in ['?','!','&','\','|','_','#'] then
//        AddToken(UNKNOWNIDENTTOK, UnitIndex, Line, 1, ord(ch));


      if ch in [':', '>', '<', '.'] then                                                          // Double-character token suspected
        begin
        SafeReadChar(ch2);
        if (ch2 = '=') or ((ch = '<') and (ch2 = '>')) or ((ch = '.') and (ch2 = '.')) then       // Double-character token found
          AddToken(GetStandardToken(ch + ch2), UnitIndex, Line, 2, 0)
        else
         if (ch='.') and (ch2 in ['0'..'9']) then begin

           AddToken(INTNUMBERTOK, UnitIndex, Line, 0, 0);

           Frac := '0.';                  // Fractional part found

           while ch2 in ['0'..'9'] do begin
            Frac := Frac + ch2;
            SafeReadChar(ch2);
           end;

           Tok[NumTok].Kind := FRACNUMBERTOK;
           Tok[NumTok].FracValue := StrToFloat(Frac);
           Tok[NumTok].Column := Tok[NumTok-1].Column + length(Frac);

           Frac := '';

           Seek(InFile, FilePos(InFile) - 1);

         end else
          begin
          Seek(InFile, FilePos(InFile) - 1);
          if ch in ['>', '<', '.', ':'] then                                                      // Single-character token found
            AddToken(GetStandardToken(ch), UnitIndex, Line, 1, 0)
          else
            begin
            CloseFile(InFile);
            Error(NumTok, 'Unknown character: ' + ch);
            end;
          end;
        end;


      if NumTok = OldNumTok then         // No token found
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
    end else
     AddToken(GetStandardToken(Text), UnitIndex, Line, length(Text), 0);

    CloseFile(InFile);
  end;// try

  end;


procedure TokenizeUnit(a: integer);
// Read input file and get tokens
begin

  UnitIndex := a;

  Line := 1;

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
Spelling[TYPETOK        ] := 'TYPE';
Spelling[VARTOK         ] := 'VAR';
Spelling[PROCEDURETOK   ] := 'PROCEDURE';
Spelling[FUNCTIONTOK    ] := 'FUNCTION';
Spelling[OBJECTTOK      ] := 'OBJECT';

Spelling[PROGRAMTOK     ] := 'PROGRAM';
Spelling[UNITTOK        ] := 'UNIT';
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

Spelling[FILETOK        ] := 'FILE';
Spelling[SETTOK         ] := 'SET';
Spelling[PACKEDTOK      ] := 'PACKED';
Spelling[LABELTOK       ] := 'LABEL';
Spelling[GOTOTOK        ] := 'GOTO';
Spelling[RECORDTOK      ] := 'RECORD';
Spelling[CASETOK        ] := 'CASE';
Spelling[BEGINTOK       ] := 'BEGIN';
Spelling[ENDTOK         ] := 'END';
Spelling[IFTOK          ] := 'IF';
Spelling[THENTOK        ] := 'THEN';
Spelling[ELSETOK        ] := 'ELSE';
Spelling[WHILETOK       ] := 'WHILE';
Spelling[DOTOK          ] := 'DO';
Spelling[REPEATTOK      ] := 'REPEAT';
Spelling[UNTILTOK       ] := 'UNTIL';
Spelling[FORTOK         ] := 'FOR';
Spelling[TOTOK          ] := 'TO';
Spelling[DOWNTOTOK      ] := 'DOWNTO';
Spelling[ASSIGNTOK      ] := ':=';
Spelling[WRITETOK       ] := 'WRITE';
Spelling[WRITELNTOK     ] := 'WRITELN';
Spelling[SIZEOFTOK      ] := 'SIZEOF';
Spelling[LENGTHTOK      ] := 'LENGTH';
Spelling[HIGHTOK        ] := 'HIGH';
Spelling[LOWTOK         ] := 'LOW';
Spelling[INTTOK         ] := 'INT';
Spelling[FRACTOK        ] := 'FRAC';
Spelling[TRUNCTOK       ] := 'TRUNC';
Spelling[ROUNDTOK       ] := 'ROUND';
Spelling[ODDTOK         ] := 'ODD';

Spelling[READLNTOK      ] := 'READLN';
Spelling[HALTTOK        ] := 'HALT';
Spelling[BREAKTOK       ] := 'BREAK';
Spelling[CONTINUETOK    ] := 'CONTINUE';
Spelling[EXITTOK        ] := 'EXIT';

Spelling[SUCCTOK        ] := 'SUCC';
Spelling[PREDTOK        ] := 'PRED';

Spelling[INCTOK         ] := 'INC';
Spelling[DECTOK         ] := 'DEC';
Spelling[ORDTOK         ] := 'ORD';
Spelling[CHRTOK         ] := 'CHR';
Spelling[ASMTOK         ] := 'ASM';
Spelling[ABSOLUTETOK    ] := 'ABSOLUTE';
Spelling[USESTOK        ] := 'USES';
Spelling[LOTOK          ] := 'LO';
Spelling[HITOK          ] := 'HI';
Spelling[GETINTVECTOK   ] := 'GETINTVEC';
Spelling[SETINTVECTOK   ] := 'SETINTVEC';
Spelling[ARRAYTOK       ] := 'ARRAY';
Spelling[OFTOK          ] := 'OF';
Spelling[STRINGTOK      ] := 'STRING';

Spelling[RANGETOK       ] := '..';

Spelling[EQTOK          ] := '=';
Spelling[NETOK          ] := '<>';
Spelling[LTTOK          ] := '<';
Spelling[LETOK          ] := '<=';
Spelling[GTTOK          ] := '>';
Spelling[GETOK          ] := '>=';

Spelling[DOTTOK         ] := '.';
Spelling[COMMATOK       ] := ',';
Spelling[SEMICOLONTOK   ] := ';';
Spelling[OPARTOK        ] := '(';
Spelling[CPARTOK        ] := ')';
Spelling[DEREFERENCETOK ] := '^';
Spelling[ADDRESSTOK     ] := '@';
Spelling[OBRACKETTOK    ] := '[';
Spelling[CBRACKETTOK    ] := ']';
Spelling[COLONTOK       ] := ':';

Spelling[PLUSTOK        ] := '+';
Spelling[MINUSTOK       ] := '-';
Spelling[MULTOK         ] := '*';
Spelling[DIVTOK         ] := '/';
Spelling[IDIVTOK        ] := 'DIV';
Spelling[MODTOK         ] := 'MOD';
Spelling[SHLTOK         ] := 'SHL';
Spelling[SHRTOK         ] := 'SHR';
Spelling[ORTOK          ] := 'OR';
Spelling[XORTOK         ] := 'XOR';
Spelling[ANDTOK         ] := 'AND';
Spelling[NOTTOK         ] := 'NOT';

Spelling[INTEGERTOK     ] := 'INTEGER';
Spelling[CARDINALTOK    ] := 'CARDINAL';
Spelling[SMALLINTTOK    ] := 'SMALLINT';
Spelling[SHORTINTTOK    ] := 'SHORTINT';
Spelling[WORDTOK        ] := 'WORD';
Spelling[BYTETOK        ] := 'BYTE';
Spelling[CHARTOK        ] := 'CHAR';
Spelling[BOOLEANTOK     ] := 'BOOLEAN';
Spelling[POINTERTOK     ] := 'POINTER';
Spelling[SHORTREALTOK   ] := 'SHORTREAL';
Spelling[REALTOK        ] := 'REAL';
Spelling[SINGLETOK      ] := 'SINGLE';

Spelling[FLOATTOK       ] := 'FLOAT';

 AsmFound  := false;
 UsesFound := false;

 IncludeIndex := MAXUNITS;

 if UsesOn then
  TokenizeUnit( 1 )           // main_file
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
   0: Result := ' STACKORIGIN,x';
   1: Result := ' STACKORIGIN+STACKWIDTH,x';
   2: Result := ' STACKORIGIN+STACKWIDTH*2,x';
   3: Result := ' STACKORIGIN+STACKWIDTH*3,x';
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

             __je: asm65(#9'beq *+5', '; je');                                // =
            __jne: asm65(#9'bne *+5', '; jne');                               // <>
             __jg: begin asm65(#9'seq', '; jg'); asm65(#9'bcs *+5') end;      // >
            __jge: asm65(#9'bcs *+5', '; jge');                               // >=
             __jl: asm65(#9'bcc *+5', '; jl');                                // <
            __jle: begin asm65(#9'bcc *+7', '; jle'); asm65(#9'beq *+5') end; // <=

          __addBX: asm65(#9'inx', '; add bx, 1');
          __subBX: asm65(#9'dex', '; sub bx, 1');

       __addAL_CL: asm65(#9'jsr addAL_CL', '; add al, cl');
       __addAX_CX: asm65(#9'jsr addAX_CX', '; add ax, cx');
     __addEAX_ECX: asm65(#9'jsr addEAX_ECX', '; add eax, ecx');

       __subAL_CL: asm65(#9'jsr subAL_CL', '; sub al, cl');
       __subAX_CX: asm65(#9'jsr subAX_CX', '; sub ax, cx');
     __subEAX_ECX: asm65(#9'jsr subEAX_ECX', '; sub eax, ecx');

        __imulECX: asm65(#9'jsr imulECX', '; imul ecx');

     __notBOOLEAN: asm65(#9'jsr notBOOLEAN', '; not BOOLEAN');
         __notaBX: asm65(#9'jsr notaBX');

         __negaBX: asm65(#9'jsr negaBX');

     __xorEAX_ECX: asm65(#9'jsr xorEAX_ECX', '; xor eax, ecx');
       __xorAX_CX: asm65(#9'jsr xorAX_CX', '; xor ax, cx');
       __xorAL_CL: asm65(#9'jsr xorAL_CL', '; xor al, cl');

     __andEAX_ECX: asm65(#9'jsr andEAX_ECX', '; and eax, ecx');
       __andAX_CX: asm65(#9'jsr andAX_CX', '; and ax, cx');
       __andAL_CL: asm65(#9'jsr andAL_CL', '; and al, cl');

      __orEAX_ECX: asm65(#9'jsr orEAX_ECX', '; or eax, ecx');
        __orAX_CX: asm65(#9'jsr orAX_CX', '; or ax, cx');
        __orAL_CL: asm65(#9'jsr orAL_CL', '; or al, cl');

     __cmpEAX_ECX: asm65(#9'jsr cmpEAX_ECX', '; cmp eax, ecx');
       __cmpAX_CX: asm65(#9'jsr cmpEAX_ECX.AX_CX', '; cmp ax, cx');
         __cmpINT: asm65(#9'jsr cmpINT', '; cmp eax, ecx');
    __cmpSHORTINT: asm65(#9'jsr cmpSHORTINT', '; cmp eax, ecx');
    __cmpSMALLINT: asm65(#9'jsr cmpSMALLINT', '; cmp eax, ecx');

      __cmpSTRING: asm65(#9'jsr cmpSTRING');
 __cmpSTRING2CHAR: asm65(#9'jsr cmpSTRING2CHAR');
 __cmpCHAR2STRING: asm65(#9'jsr cmpCHAR2STRING');

   __movaBX_Value: begin
//                    asm65(#9'ldx sp', '; mov dword ptr [bx], Value');

                    if Kind=VARIABLE then begin                      // @label

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


procedure Gen(b: Byte);
begin
 //Code[CodeSize] := b;
 if not OutputDisabled then Inc(CodeSize);

end;


procedure GenDWord(dw: Int64);
begin
 Gen(Lo(dw)); Gen(Hi(dw));
 dw := dw shr 16;
 Gen(Lo(dw)); Gen(Hi(dw));
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
   1: if (Source in SignedOrdinalTypes) then                                    // to WORD
       asm65(#9'jsr @expandSHORT2SMALL')
      else
       asm65(#9'mva #$00 STACKORIGIN+STACKWIDTH,x', '; expand to WORD');

   2: if (Source in SignedOrdinalTypes) then                                    // to CARDINAL
       asm65(#9'jsr @expandToCARD.SMALL')
      else
       asm65(#9'jsr @expandToCARD.WORD');

   3: if (Source in SignedOrdinalTypes) then                                    // to CARDINAL
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
   1: if (Source in SignedOrdinalTypes) then                                    // to WORD
       asm65(#9'jsr @expandSHORT2SMALL1')
      else
       asm65(#9'mva #$00 STACKORIGIN-1+STACKWIDTH,x', '; expand to WORD');

   2: if (Source in SignedOrdinalTypes) then                                    // to CARDINAL
       asm65(#9'jsr @expandToCARD1.SMALL')
      else
       asm65(#9'jsr @expandToCARD1.WORD');

   3: if (Source in SignedOrdinalTypes) then                                    // to CARDINAL
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
      ExpandParam_m1(RightValType, ValType);       // -1
      ValType:=RightValType;                       // przyjmij najwiekszy typ dla operacji
    end else begin

      if VarType in Pointers then VarType:=WORDTOK;

      m:=DataSize[ValType];
      if DataSize[RightValType] > m then m:=DataSize[RightValType];

      if VarType <> 0 then
       if DataSize[VarType] > m then m:=DataSize[VarType];     // okreslamy najwiekszy wspolny typ

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
 Gen($66); Gen($C1); Gen($E0); Gen(16);                          // shl eax, 16
 Gen($66); Gen($C1); Gen($F8); Gen(16);                          // sar eax, 16
{
 if regA=0 then begin
  asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
  asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');
 end else begin
  asm65(#9'mva #$00 STACKORIGIN+STACKWIDTH*2,x');
  asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');
 end;
}
end;



procedure ExpandByte;
begin

Gen($98);                                                       // cbw

//asm65(#9'mva #$00 STACKORIGIN+STACKWIDTH,x');

ExpandWord;// (0);

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
// Gen($53);                                                               // push bx
// Gen($8B); Gen($2F);                                                     // mov bp, [bx]
// Gen($8B); Gen($46); Gen($00);                                           // mov ax, [bp]
// Gen($8B); Gen($5E); Gen($04);                                           // mov bx, [bp + 4]
// Gen($8B); Gen($4E); Gen($08);                                           // mov cx, [bp + 8]
// Gen($8B); Gen($56); Gen($0C);                                           // mov dx, [bp + 12]
// Gen($CD); Gen(InterruptNumber);                                         // int InterruptNumber
// Gen($89); Gen($46); Gen($00);                                           // mov [bp], ax
// Gen($89); Gen($5E); Gen($04);                                           // mov [bp + 4], bx
// Gen($89); Gen($4E); Gen($08);                                           // mov [bp + 8], cx
// Gen($89); Gen($56); Gen($0C);                                           // mov [bp + 12], dx
// Gen($5B);                                                               // pop bx
// Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4

end;// GenerateInterrupt
*)


procedure Push(Value: Int64; IndirectionLevel: Byte; Size: Byte; IdentIndex: integer = 0; par: byte = 0);
var Kind: byte;
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

    Gen($83); Gen($C3); Gen($04);                                         // add bx, 4
    a65(__addBX);

    Gen($66); Gen($C7); Gen($07); GenDWord(Value);                        // mov dword ptr [bx], Value
    a65(__movaBX_Value, Value, Kind, Size, IdentIndex);

    end;

  ASPOINTER:
    begin
    asm65('; as Pointer'+#13#10);

    a65(__addBX);
//    asm65(#9'ldx sp');

    case Size of
      1: begin
         Gen($A0); Gen(Lo(Value)); Gen(Hi(Value));                        // mov al, [Value]

         asm65(#9'mva '+svar+ GetStackVariable(0));

         ExpandByte;
         end;

      2: begin
         Gen($A1); Gen(Lo(Value)); Gen(Hi(Value));                        // mov ax, [Value]

         asm65(#9'mva '+svar+ GetStackVariable(0));
         asm65(#9'mva '+svar+'+1' + GetStackVariable(1));

         ExpandWord;
         end;

      4: begin
         Gen($66); Gen($A1); Gen(Lo(Value)); Gen(Hi(Value));              // mov eax, [Value]

         asm65(#9'mva '+svar+ GetStackVariable(0));
         asm65(#9'mva '+svar+'+1' + GetStackVariable(1));
         asm65(#9'mva '+svar+'+2' + GetStackVariable(2));
         asm65(#9'mva '+svar+'+3' + GetStackVariable(3));
         end;
      end;

    Gen($83); Gen($C3); Gen($04);                                         // add bx, 4
//    a65(__addBX);
    Gen($66); Gen($89); Gen($07);                                         // mov [bx], eax
//    a65(__movaBX_EAX);

    end;


  ASPOINTERTORECORD:
    begin
    asm65('; as Pointer to Record'+#13#10);

    Gen($8B); Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));                   // mov bp, [Value]

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

    Gen($83); Gen($C3); Gen($04);                                         // add bx, 4
//    a65(__addBX);

    Gen($66); Gen($89); Gen($07);                                         // mov [bx], eax
//    a65(__movaBX_EAX);
    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer'+#13#10);           // ???

    Gen($8B); Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));                   // mov bp, [Value]

    a65(__addBX);

    if pos('.', svar) > 0 then
     asm65(#9'mwa '+copy(svar,1, pos('.', svar)-1)+' bp2')
    else
     asm65(#9'mwa '+svar+' bp2');

    if pos('.', svar) > 0 then
     asm65(#9'ldy #'+svar+'-DATAORIGIN')
    else
     asm65(#9'ldy #$' + IntToHex(par, 2));

    case Size of
      1: begin
         Gen($8A); Gen($46); Gen($00);                                    // mov al, [bp]

         asm65(#9'mva (bp2),y'+GetStackVariable(0));

         ExpandByte;
         end;
      2: begin
         Gen($8B); Gen($46); Gen($00);                                    // mov ax, [bp]

         asm65(#9'mva (bp2),y'+GetStackVariable(0));
         asm65(#9'iny');
         asm65(#9'mva (bp2),y'+GetStackVariable(1));

         ExpandWord;
         end;
      4: begin
         Gen($66); Gen($8B); Gen($46); Gen($00);                          // mov eax, [bp]

         asm65(#9'mva (bp2),y'+GetStackVariable(0));
         asm65(#9'iny');
         asm65(#9'mva (bp2),y'+GetStackVariable(1));
         asm65(#9'iny');
         asm65(#9'mva (bp2),y'+GetStackVariable(2));
         asm65(#9'iny');
         asm65(#9'mva (bp2),y'+GetStackVariable(3));

         end;
      end;

    Gen($83); Gen($C3); Gen($04);                                         // add bx, 4
//    a65(__addBX);

    Gen($66); Gen($89); Gen($07);                                         // mov [bx], eax
//    a65(__movaBX_EAX);
    end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin'+#13#10);

    Gen($8B); Gen($2E); Gen(Lo(Value)); Gen(Hi(Value));                   // mov bp, [Value]
//    a65(__movBP_aAdr, Value);

    Gen($8B); Gen($37);                                                   // mov si, [bx]
//    a65(__movSI_aBX);

    case Size of
      1: begin
         Gen($8A); Gen($02);                                              // mov al, [bp + si]
//         a65(__movAL_BPSI);

         if (NumAllocElements>256) or (NumAllocElements=1) then begin

         asm65(#9'lda '+svar);
         asm65(#9'add STACKORIGIN,x');
         asm65(#9'tay');
         asm65(#9'lda '+svar+'+1');
         asm65(#9'adc STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta bp+1');
         asm65(#9'lda (bp),y');
         asm65(#9'sta STACKORIGIN,x');

         end else begin

          asm65(#9'ldy STACKORIGIN,x', '; si');

          if Ident[IdentIndex].PassMethod = VARPASSING then begin
           asm65(#9'mwa '+svar+' bp2');
           asm65(#9'lda (bp2),y');
           asm65(#9'sta'+ GetStackVariable(0));
          end else
           asm65(#9'mva '+svara+',y'+ GetStackVariable(0));

         end;

         ExpandByte;
         end;

      2: begin
         Gen($C1); Gen($E6); Gen($01);                                    // shl si, 1
         Gen($8B); Gen($02);                                              // mov ax, [bp + si]
//         a65(__movAX_BPSI);

         if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
         GenerateIndexShift(WORDTOK);

         asm65('');

         if (NumAllocElements * 2>256) or (NumAllocElements=1) or (Ident[IdentIndex].PassMethod = VARPASSING) then begin

          asm65(#9'lda '+svar);                                           // pushWORD
          asm65(#9'add STACKORIGIN,x');
          asm65(#9'sta bp2');
          asm65(#9'lda '+svar+'+1');
          asm65(#9'adc STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta bp2+1');

          asm65(#9'ldy #$00');

          asm65(#9'lda (bp2),y');
          asm65(#9'sta'+ GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'lda (bp2),y');
          asm65(#9'sta'+ GetStackVariable(1));

         end else begin

          asm65(#9'ldy STACKORIGIN,x', '; si');
          asm65(#9'mva '+svara+',y'+ GetStackVariable(0));
          asm65(#9'mva '+svara+'+1,y'+ GetStackVariable(1));

         end;

         ExpandWord;
         end;

      4: begin
         Gen($C1); Gen($E6); Gen($02);                                    // shl si, 2
         Gen($66); Gen($8B); Gen($02);                                    // mov eax, [bp + si]


         if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
         GenerateIndexShift(CARDINALTOK);

         asm65('');

         if (NumAllocElements * 4>256) or (NumAllocElements=1)  or (Ident[IdentIndex].PassMethod = VARPASSING) then begin

          asm65(#9'lda '+svar);                                           // pushCARD
          asm65(#9'add STACKORIGIN,x');
          asm65(#9'sta bp2');
          asm65(#9'lda '+svar+'+1');
          asm65(#9'adc STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta bp2+1');

          asm65(#9'ldy #$00');

          asm65(#9'lda (bp2),y');
          asm65(#9'sta'+ GetStackVariable(0));
          asm65(#9'iny');
          asm65(#9'lda (bp2),y');
          asm65(#9'sta'+ GetStackVariable(1));
          asm65(#9'iny');
          asm65(#9'lda (bp2),y');
          asm65(#9'sta'+ GetStackVariable(2));
          asm65(#9'iny');
          asm65(#9'lda (bp2),y');
          asm65(#9'sta'+ GetStackVariable(3));

         end else begin

          asm65(#9'ldy STACKORIGIN,x', '; si');
          asm65(#9'mva '+svara+',y'+ GetStackVariable(0));
          asm65(#9'mva '+svara+'+1,y'+ GetStackVariable(1));
          asm65(#9'mva '+svara+'+2,y'+ GetStackVariable(2));
          asm65(#9'mva '+svara+'+3,y'+ GetStackVariable(3));

         end;


         end;
      end;

    Gen($66); Gen($89); Gen($07);                                         // mov [bx], eax
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

 asm65(#13#10'; Save conditional expression');//at expression stack top onto the system stack');

 Gen($66); Gen($FF); Gen($37);                                     // push dword ptr [bx]

// asm65('.var iftmp_'+IntToStr(cnt)+' .byte');

 asm65(#9'.ifdef IFTMP_'+IntToStr(cnt));
 asm65(#9'lda STACKORIGIN,x');
 asm65(#9'sta IFTMP_'+IntToStr(cnt));
 asm65(#9'eif');

// asm65(#9'pha');
end;


procedure RestoreFromSystemStack(cnt: integer);
begin

 asm65(#13#10'; Restore conditional expression');

 Gen($83); Gen($C3); Gen($04);                           // add bx, 4
// a65(__addBX);

 Gen($66); Gen($8F); Gen($07);                           // pop dword ptr [bx]

// asm65(#9'pla');

// asm65(#9'lda #0');
// asm65('iftmp_'+IntToStr(Cnt)+#9'equ *-1');

 asm65(#9'lda IFTMP_'+IntToStr(Cnt));

 DefineIdent(NumTok, 'IFTMP_'+IntToStr(Cnt), VARIABLE, BOOLEANTOK, 0, 0, 0);
 GetIdent('IFTMP_'+IntToStr(Cnt));                       // zapobiega informacji o nieuzywaniu tej zmiennej

// asm65(#9'sta STACKORIGIN,x');

end;


procedure RemoveFromSystemStack;
begin
Gen($66); Gen($58);                                     // pop eax

//asm65(#13#10'; Remove conditional expression');
//a65(__popEAX);
//asm65(#9'pla');

end;


procedure GenerateFileOpen(IdentIndex: Integer; Code: ioCode; NumParams: integer = 0);
begin

 optyA := '';
 optyBP2 := '';

 asm65('');
 asm65(#9'txa:pha');

 if IOCheck then
  asm65(#9'sec')
 else
  asm65(#9'clc');

 case Code of

   ioOpenRead,
   ioOpenWrite: asm65(#9'@openfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(Code)));

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


procedure GenerateIncOperation(Value: Int64; IndirectionLevel: Byte; ExpressionType: Byte; Down: Boolean; IdentIndex: integer);
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
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta '+svar);
                 end;

              2: begin
                  asm65(#9'lda '+svar);
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta '+svar);

                  asm65(#9'lda '+svar+'+1');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta '+svar+'+1');
                 end;

              4: begin
                  asm65(#9'lda '+svar);
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta '+svar);

                  asm65(#9'lda '+svar+'+1');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta '+svar+'+1');

                  asm65(#9'lda '+svar+'+2');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH*2,x');
                  asm65(#9'sta '+svar+'+2');

                  asm65(#9'lda '+svar+'+3');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH*3,x');
                  asm65(#9'sta '+svar+'+3');
              end;

             end;

       end;


  ASPOINTERTOPOINTER:
        begin

           asm65('; as Pointer To Pointer'#13#10);

           if pos('.', svar) > 0 then
            asm65(#9'mwa '+copy(svar, 1, pos('.', svar)-1)+' bp2')
           else
            asm65(#9'mwa '+svar+' bp2');

           if pos('.', svar) > 0 then
            asm65(#9'ldy #'+svar+'-DATAORIGIN')
           else
            asm65(#9'ldy #$00');

             case DataSize[ExpressionType] of
              1: begin
                  asm65('');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta (bp2),y');
                 end;

              2: begin
                  asm65('');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta (bp2),y');
                 end;

              4: begin
                  asm65('');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH*2,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH*3,x');
                  asm65(#9'sta (bp2),y');
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
                   asm65(#9'add STACKORIGIN-1,x');
                   asm65(#9'tay');

                   asm65(#9'lda '+svar+'+1');
                   asm65(#9'adc STACKORIGIN-1+STACKWIDTH,x');
                   asm65(#9'sta bp+1');

                   asm65('');
                   asm65(#9'lda (bp),y');
                   asm65(#9+b+' STACKORIGIN,x');
                   asm65(#9'sta (bp),y');

                  end else begin

                   asm65(#9'ldy STACKORIGIN-1,x');

                   if Ident[IdentIndex].PassMethod = VARPASSING then begin
                    asm65(#9'mwa '+svar+' bp2');
                    asm65(#9'lda (bp2),y');
                    asm65(#9+b+' STACKORIGIN,x');
                    asm65(#9'sta (bp2),y');
                   end else begin
                    asm65(#9'lda '+svara+',y');
                    asm65(#9+b+' STACKORIGIN,x');
                    asm65(#9'sta '+svara+',y');
                   end;

                  end;

                 end;

              2: begin
                  asm65(#9'lda '+svar);
                  asm65(#9'add STACKORIGIN-1,x');
                  asm65(#9'sta bp2');

                  asm65(#9'lda '+svar+'+1');
                  asm65(#9'adc STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta bp2+1');

                  asm65(#9'ldy #$00');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta (bp2),y');
                 end;

              4: begin
                  asm65(#9'lda '+svar);
                  asm65(#9'add STACKORIGIN-1,x');
                  asm65(#9'sta bp2');

                  asm65(#9'lda '+svar+'+1');
                  asm65(#9'adc STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta bp2+1');

                  asm65(#9'ldy #$00');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+b+' STACKORIGIN,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH*2,x');
                  asm65(#9'sta (bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda (bp2),y');
                  asm65(#9+c+' STACKORIGIN+STACKWIDTH*3,x');
                  asm65(#9'sta (bp2),y');
                 end;

             end;

           a65(__subBX);

          end;

 end;

 a65(__subBX);
end;



procedure GenerateAssignment(Address: Int64; IndirectionLevel: Byte; Size: Byte; IdentIndex: integer; Param: string = ''; ParamY: string = '');
var NumAllocElements: cardinal;
    svar, svara: string;
begin

 if IdentIndex > 0 then begin

  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   Size := DataSize[Ident[IdentIndex].AllocElementType];
   NumAllocElements := 0;
  end else
   NumAllocElements := Elements(IdentIndex); //Ident[IdentIndex].NumAllocElements;

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

    Gen($66); Gen($8B); Gen($07);                                         // mov eax, [bx]
//    a65(__movEAX_aBX);
    Gen($83); Gen($EB); Gen($04);                                         // sub bx, 4
//    a65(__subBX);


case IndirectionLevel of

  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');

    Gen($66); Gen($8B); Gen($07);                                         // mov eax, [bx]
//    a65(__movEAX_aBX);
    Gen($83); Gen($EB); Gen($04);                                         // sub bx, 4
//    a65(__subBX);

    Gen($8B); Gen($2E); Gen(Lo(Address)); Gen(Hi(Address));               // mov bp, [Address]
//    a65(__movBP_aAdr, Address);

    Gen($8B); Gen($37);                                                   // mov si, [bx]
//    a65(__movSI_aBX);

    Gen($83); Gen($EB); Gen($04);                                         // sub bx, 4
//    a65(__subBX);


    case Size of
      1: begin
         Gen($88); Gen($02);                                              // mov [bp + si], al

         if NumAllocElements = 0 then begin

         asm65(#9'lda '+svar);
         asm65(#9'add STACKORIGIN-1,x');
         asm65(#9'tay');
         asm65(#9'lda '+svar+'+1');
         asm65(#9'adc #0','; si+1');
         asm65(#9'sta bp+1');
         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp),y');

         end else

         if (NumAllocElements > 256) or (NumAllocElements = 1) then begin

         asm65(#9'lda '+svar);
         asm65(#9'add STACKORIGIN-1,x');
         asm65(#9'tay');
         asm65(#9'lda '+svar+'+1');
         asm65(#9'adc STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'sta bp+1');
         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp),y');

         end else begin

         asm65(#9'ldy STACKORIGIN-1,x','; si');

         if Ident[IdentIndex].PassMethod = VARPASSING then begin
          asm65(#9'mwa '+svar+' bp2');
          asm65(#9'lda STACKORIGIN,x');
          asm65(#9'sta (bp2),y');
         end else begin
          asm65(#9'mva STACKORIGIN,x '+svara+',y');

//          asm65(#9'lda STACKORIGIN,x');
//          asm65(#9'sta '+svara+',y');
         end;

         end;

         a65(__subBX);
         a65(__subBX);
         end;

      2: begin
         Gen($C1); Gen($E6); Gen($01);                                    // shl si, 1
         Gen($89); Gen($02);                                              // mov [bp + si], ax

         if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
         GenerateIndexShift(WORDTOK, 1);

         if (NumAllocElements * 2 > 256) or (NumAllocElements = 1) then begin

         asm65(#9'lda '+svar);                                            // pullWORD
         asm65(#9'add STACKORIGIN-1,x');
         asm65(#9'sta bp2');
         asm65(#9'lda '+svar+'+1');
         asm65(#9'adc STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'sta bp2+1');
         asm65(#9'ldy #$00');
         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta (bp2),y');

         end else begin

         asm65(#9'ldy STACKORIGIN-1,x','; si');

         if Ident[IdentIndex].PassMethod = VARPASSING then begin

          asm65(#9'mwa '+svar+' bp2');
          asm65(#9'lda STACKORIGIN,x');
          asm65(#9'sta (bp2),y');
          asm65(#9'iny');
          asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (bp2),y');

         end else begin

          asm65(#9'lda STACKORIGIN,x');
          asm65(#9'sta '+svara+',y');
          asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta '+svara+'+1,y');

         end;

         end;

         a65(__subBX);
         a65(__subBX);

         end;

      4: begin
         Gen($C1); Gen($E6); Gen($02);                                    // shl si, 2
         Gen($66); Gen($89); Gen($02);                                    // mov [bp + si], eax

         if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
          GenerateIndexShift(CARDINALTOK, 1);

         if (NumAllocElements * 4 > 256) or (NumAllocElements = 1) then begin

         asm65(#9'lda '+svar);                                            // pullCARD
         asm65(#9'add STACKORIGIN-1,x');
         asm65(#9'sta bp2');
         asm65(#9'lda '+svar+'+1');
         asm65(#9'adc STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'sta bp2+1');
         asm65(#9'ldy #$00');
         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH*3,x');
         asm65(#9'sta (bp2),y');

         end else begin

         asm65(#9'ldy STACKORIGIN-1,x','; si');

         if Ident[IdentIndex].PassMethod = VARPASSING then begin

          asm65(#9'mwa '+svar+' bp2');
          asm65(#9'lda STACKORIGIN,x');
          asm65(#9'sta (bp2),y');
          asm65(#9'iny');
          asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta (bp2),y');
          asm65(#9'iny');
          asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta (bp2),y');
          asm65(#9'iny');
          asm65(#9'lda STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta (bp2),y');

         end else begin

          asm65(#9'lda STACKORIGIN,x');
          asm65(#9'sta '+svara+',y');
          asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta '+svara+'+1,y');
          asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta '+svara+'+2,y');
          asm65(#9'lda STACKORIGIN+STACKWIDTH*3,x');
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
    asm65('; as Pointer to Pointer');       // ???


    Gen($66); Gen($8B); Gen($07);                                             // mov eax, [bx]
//    a65(__movEAX_aBX);
    Gen($83); Gen($EB); Gen($04);                                             // sub bx, 4
//    a65(__subBX);

    Gen($8B); Gen($2E); Gen(Lo(Address)); Gen(Hi(Address));               // mov bp, [Address]

    if pos('.', svar) > 0 then
     asm65(#9'mwa '+copy(svar, 1, pos('.', svar)-1)+' bp2')
    else
     asm65(#9'mwa '+svar+' bp2');

    if ParamY<>'' then
     asm65(#9'ldy #'+ParamY)
    else
     if pos('.', svar) > 0 then
      asm65(#9'ldy #'+svar+'-DATAORIGIN')
     else
      asm65(#9'ldy #$00');

    case Size of
      1: begin
         Gen($88); Gen($46); Gen($00);                                    // mov [bp], al
//         a65(__movaBP_AL);

         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp2),y');

         end;
      2: begin
         Gen($89); Gen($46); Gen($00);                                    // mov [bp], ax
//         a65(__movaBP_AX);

         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta (bp2),y');

         end;
      4: begin
         Gen($66); Gen($89); Gen($46); Gen($00);                          // mov [bp], eax
//         a65(__movaBP_EAX);

         asm65(#9'lda STACKORIGIN,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'sta (bp2),y');
         asm65(#9'iny');
         asm65(#9'lda STACKORIGIN+STACKWIDTH*3,x');
         asm65(#9'sta (bp2),y');

         end;
      end;

     a65(__subBX);

    end;


  ASPOINTER:
    begin
    asm65('; as Pointer');

    Gen($66); Gen($8B); Gen($07);                                             // mov eax, [bx]
//    a65(__movEAX_aBX);
    Gen($83); Gen($EB); Gen($04);                                             // sub bx, 4
//    a65(__subBX);

     case Size of
      1: begin
         Gen($A2); Gen(Lo(Address)); Gen(Hi(Address));                    // mov [Address], al
//         a65(__movaAdr_AL, Address);
         asm65(#9'mva STACKORIGIN,x '+svar);
         end;
      2: begin
         Gen($A3); Gen(Lo(Address)); Gen(Hi(Address));                    // mov [Address], ax
//         a65(__movaAdr_AX, Address);
         asm65(#9'mva STACKORIGIN,x '+svar);
         asm65(#9'mva STACKORIGIN+STACKWIDTH,x '+svar+'+1');

         end;
      4: begin
         Gen($66); Gen($A3); Gen(Lo(Address)); Gen(Hi(Address));          // mov [Address], eax
//         a65(__movaAdr_EAX, Address);
         asm65(#9'mva STACKORIGIN,x '+svar);
         asm65(#9'mva STACKORIGIN+STACKWIDTH,x '+svar+'+1');
         asm65(#9'mva STACKORIGIN+STACKWIDTH*2,x '+svar+'+2');
         asm65(#9'mva STACKORIGIN+STACKWIDTH*3,x '+svar+'+3');

         end;
      end;

     a65(__subBX);

    end;

end;// case

StopOptimization(true);

end;


procedure GenerateCall(IdentIndex: integer);
var
  CodePos: Word;
  Entry: Int64;
  Name: string;
begin

 optyA := '';
 optyBP2 := '';

 Entry := Ident[IdentIndex].Value;

 Name := GetLocalName(IdentIndex);

 CodePos := CodeSize;
 Gen($E8); Gen(Lo(Entry - (CodePos + 3))); Gen(Hi(Entry - (CodePos + 3)));           // call Entry

 asm65('');

 if Ident[IdentIndex].isOverload then
  asm65(#9'jsr '+Name+'_'+IntToHex(Ident[IdentIndex].Value, 4), '; call Entry'#13#10)
 else
  asm65(#9'jsr '+Name, '; call Entry'#13#10);

 if Ident[IdentIndex].Kind <> FUNCTIONTOK then StopOptimization;

end;


procedure GenerateReturn(IsFunction, isInt: Boolean);
begin
 Gen($C3);                                                               // ret

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

Gen($66); Gen($8B); Gen($07);                                           // mov eax, [bx]
//a65(__movEAX_aBX);

Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
//a65(__subBX);

Gen($66); Gen($83); Gen($F8); Gen($00);                                 // cmp eax, 0
//a65(__cmpEAX_0);

//asm65(#9'dex');
a65(__subBX);
asm65(#9'lda STACKORIGIN+1,x');

Gen($75); Gen($03);                                                     // jne +3
a65(__jne);
end;




procedure GenerateElseCondition;
begin
asm65(#13#10'; else condition');

Gen($66); Gen($8B); Gen($07);                                           // mov eax, [bx]

Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4

Gen($66); Gen($83); Gen($F8); Gen($00);                                 // cmp eax, 0

//a65(__subBX);
//asm65(#9'lda STACKORIGIN+1,x');

Gen($74); Gen($03);                                                     // je  +3
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
    Gen($74); Gen($03);                                                 // je +3   =
    asm65(#9'beq @+', '; =');
    end;

  NETOK, 0:
    begin
    Gen($75); Gen($03);                                                 // jne +3  <>
    asm65(#9'bne @+', '; <>');
    end;

  GTTOK:
    begin
    Gen($7F); Gen($03);                                                 // jg +3   >

    asm65(#9'seq', '; >');

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+')
    else
     asm65(#9'bcs @+');

    end;

  GETOK:
    begin
    Gen($7D); Gen($03);                                                 // jge +3  >=

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+', '; >=')
    else
     asm65(#9'bcs @+', '; >=');

    end;

  LTTOK:
    begin
    Gen($7C); Gen($03);                                                 // jl +3   <

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bmi @+', '; <')
    else
     asm65(#9'bcc @+', '; <');

    end;

  LETOK:
    begin
    Gen($7E); Gen($03);                                                 // jle +3  <=

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
            asm65(#9'cmp STACKORIGIN+1,x');
           end;

        INTEGERTOK:
           begin
            asm65(#9'lda '+svar+'+2');
            asm65(#9'cmp STACKORIGIN+1+STACKWIDTH*2,x');
            asm65(#9'bne L1');

            asm65(#9'lda '+svar+'+1');
            asm65(#9'cmp STACKORIGIN+1+STACKWIDTH,x');
            asm65(#9'bne L1');

            asm65(#9'lda '+svar);
            asm65(#9'cmp STACKORIGIN+1,x');
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


procedure GenerateForToDoCondition(CounterAddress: Word; CounterSize: Byte; Down: Boolean; IdentIndex: integer);
var svar: string;
    ValType: Byte;
begin

svar    := GetLocalName(IdentIndex);
ValType := Ident[IdentIndex].DataType;

asm65(';'+InfoAboutSize(CounterSize));

Gen($66); Gen($8B); Gen($0F);                                                           // mov ecx, [bx]
//a65(__movECX_aBX);

Gen($83); Gen($EB); Gen($04);                                                           // sub bx, 4

a65(__subBX);

case CounterSize of

  1: begin
     Gen($A0); Gen(Lo(CounterAddress)); Gen(Hi(CounterAddress));                        // mov al, [CounterAddress]
//     a65(__movAL_aVal, CounterAddress);
     ExpandByte;

     if ValType = SHORTINTTOK then begin
                                                             // @cmpFor_SHORTINT
       asm65(#9'.LOCAL', '; @cmpFor_SHORTINT');
       asm65(#9'lda '+svar);
       asm65(#9'clv:sec');
       asm65(#9'sbc STACKORIGIN+1,x');

       SignedTest(ValType, svar);
     end else begin
      asm65(#9'lda '+svar);
      asm65(#9'cmp STACKORIGIN+1,x');
     end;

     end;

  2: begin
     Gen($A1); Gen(Lo(CounterAddress)); Gen(Hi(CounterAddress));                        // mov ax, [CounterAddress]
//     a65(__movAX_aVal, CounterAddress);
     ExpandWord;

     if ValType = SMALLINTTOK then begin
                                                             // @cmpFor_SMALLINT
       asm65(#9'.LOCAL', '; @cmpFor_SMALLINT');
       asm65(#9'lda '+svar+'+1');
       asm65(#9'clv:sec');
       asm65(#9'sbc STACKORIGIN+1+STACKWIDTH,x');

       SignedTest(ValType, svar);
     end else begin
//      asm65(#9'@cmpFor_WORD #'+svar);
      asm65(#9'lda '+svar+'+1');
      asm65(#9'cmp STACKORIGIN+1+STACKWIDTH,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar);
      asm65(#9'cmp STACKORIGIN+1,x');
      asm65('@');
     end;

     end;

  4: begin
     Gen($66); Gen($A1); Gen(Lo(CounterAddress)); Gen(Hi(CounterAddress));              // mov eax, [CounterAddress]
//     a65(__movEAX_aVal, CounterAddress);

     if ValType = INTEGERTOK then begin
                                                             // @cmpFor_INT
       asm65(#9'.LOCAL', '; @cmpFor_INT');
       asm65(#9'lda '+svar+'+3');
       asm65(#9'clv:sec');
       asm65(#9'sbc STACKORIGIN+1+STACKWIDTH*3,x');

       SignedTest(ValType, svar);
     end else begin
//      asm65(#9'@cmpFor_CARD #'+svar);
      asm65(#9'lda '+svar+'+3');
      asm65(#9'cmp STACKORIGIN+1+STACKWIDTH*3,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar+'+2');
      asm65(#9'cmp STACKORIGIN+1+STACKWIDTH*2,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar+'+1');
      asm65(#9'cmp STACKORIGIN+1+STACKWIDTH,x');
      asm65(#9'bne @+');
      asm65(#9'lda '+svar);
      asm65(#9'cmp STACKORIGIN+1,x');
      asm65('@');
     end;

    end;

  end;


Gen($66); Gen($3B); Gen($C1);                                                           // cmp eax, ecx
//a65(__cmpEAX_ECX);

if Down then
  begin
  Gen($7D); Gen($03);                                                                   // jge +3 >=

  if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then
   asm65(#9'bpl *+5', '; >=')
  else
   asm65(#9'bcs *+5', '; >=');

  end

else
  begin
  Gen($7E); Gen($03);                                                                   // jle +3 <=


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

Gen($90);                                                               // nop   ; jump to the IF..THEN block end will be inserted here
Gen($90);                                                               // nop
Gen($90);                                                               // nop

asm65(#9'jmp l_'+IntToHex(CodeSize, 4));

end;


procedure GenerateCaseProlog(SelectorType: Byte; cnt: integer);
begin
asm65(#13#10'; GenerateCaseProlog');

Gen($66); Gen($59);                                         // pop ecx           ; CASE switch value
Gen($B0); Gen($00);                                         // mov al, 00h       ; initial flag mask

a65(__subBX);

end;


procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: Byte);
begin
asm65(#13#10'; GenerateCaseEqualityCheck');

Gen($66); Gen($81); Gen($F9); GenDWord(Value);              // cmp ecx, Value
Gen($9F);                                                   // lahf
Gen($0A); Gen($C4);                                         // or al, ah

case DataSize[SelectorType] of
 1: begin
     asm65(#9'lda STACKORIGIN+1,x');
     asm65(#9'cmp #'+IntToStr(Value));
    end;

// 2: asm65(#9'cpw STACKORIGIN,x #$'+IntToHex(Value, 4));
// 4: asm65(#9'cpd STACKORIGIN,x #$'+IntToHex(Value, 4));
end;

asm65(#9'beq @+');

end;


procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: Byte);
begin
Gen($66); Gen($81); Gen($F9); GenDWord(Value1);             // cmp ecx, Value1
Gen($7C); Gen($0B);                                         // jl +11
Gen($66); Gen($81); Gen($F9); GenDWord(Value2);             // cmp ecx, Value2
Gen($7F); Gen($02);                                         // jg +2
Gen($0C); Gen($40);                                         // or al, 40h     ; set zero flag on success

 if (SelectorType in [BYTETOK, CHARTOK]) and (Value1 >= 0) and (Value2 >= 0) then begin

   asm65('');
   asm65(#9'lda STACKORIGIN+1,x');
   asm65(#9'clc', '; clear carry for add');
   asm65(#9'adc #$FF-'+IntToStr(Value2), '; make m = $FF');
   asm65(#9'adc #'+IntToStr(Value2)+'-'+IntToStr(Value1)+'+1', '; carry set if in range n to m');
   asm65(#9'bcs @+');

 end else begin

  case DataSize[SelectorType] of
   1: begin
       asm65(#9'lda STACKORIGIN+1,x');
       asm65(#9'cmp #'+IntToStr(Value1));
      end;

  end;

  GenerateRelationOperation(LTTOK, SelectorType);

  case DataSize[SelectorType] of
   1: begin
//       asm65(#9'lda STACKORIGIN+1,x');
       asm65(#9'cmp #'+IntToStr(Value2));
      end;

  end;

  GenerateRelationOperation(GTTOK, SelectorType);

  asm65(#9'jmp *+6');
  asm65('@');

 end;

end;


procedure GenerateCaseStatementProlog;
begin
asm65(#13#10'; GenerateCaseStatementProlog');

Gen($24); Gen($40);                                         // and al, 40h    ; test zero flag
Gen($75); Gen($03);                                         // jnz +3         ; if set, jump to the case statement

GenerateIfThenProlog;
end;


procedure GenerateIfElseEpilog;
var CodePos: Integer;
begin
asm65(#13#10'; GenerateIfElseEpilog');

CodePos := CodePosStack[CodePosStackTop];
Dec(CodePosStackTop);

Gen($E9); GenDWord(CodeSize - (CodePos + 3));      // jmp (IF..THEN block end)
end;


procedure GenerateCaseStatementEpilog(cnt: integer);
var StoredCodeSize: LongInt;
begin
asm65(#13#10'; GenerateCaseStatementEpilog');

asm65(#9'jmp a_'+IntToHex(cnt,4));

StoredCodeSize := CodeSize;

Gen($90);                                                   // nop   ; jump to the CASE block end will be inserted here
Gen($90);                                                   // nop
Gen($90);                                                   // nop

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

  optyA := '';
  optyBP2 := '';

asm65(#13#10'; IfThenEpilog');

CodePos := CodePosStack[CodePosStackTop];
Dec(CodePosStackTop);

//Code[CodePos] := $E9;
//Code[CodePos + 1] := Lo(CodeSize - (CodePos + 3));
//Code[CodePos + 2] := Hi(CodeSize - (CodePos + 3));  // jmp (IF..THEN block end)

GenerateAsmLabels(CodePos+3);
end;




procedure GenerateWhileDoProlog;
begin
GenerateIfThenProlog;
end;




procedure GenerateWhileDoEpilog;
var
  CodePos, CurPos, ReturnPos: Word;
begin
asm65(#13#10'; WhileDoEpilog');

CodePos := CodePosStack[CodePosStackTop];
Dec(CodePosStackTop);

//Code[CodePos] := $E9;
//Code[CodePos + 1] := Lo(CodeSize - (CodePos + 3) + 3);
//Code[CodePos + 2] := Hi(CodeSize - (CodePos + 3) + 3);  // jmp (WHILE..DO block end)

ReturnPos := CodePosStack[CodePosStackTop];
Dec(CodePosStackTop);

CurPos := CodeSize;

Gen($E9); Gen(Lo(ReturnPos - (CurPos + 3))); Gen(Hi(ReturnPos - (CurPos + 3)));             // jmp ReturnPos

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
  CurPos, ReturnPos: Word;
begin

  optyA := '';
  optyBP2 := '';

 ReturnPos := CodePosStack[CodePosStackTop];
 Dec(CodePosStackTop);

 CurPos := CodeSize;

 Gen($E9); Gen(Lo(ReturnPos - (CurPos + 3))); Gen(Hi(ReturnPos - (CurPos + 3)));

 asm65(#9'jmp l_'+IntToHex(ReturnPos , 4));

end;


procedure GenerateForToDoProlog;
begin

 GenerateWhileDoProlog;

end;


procedure GenerateForToDoEpilog (CounterAddress: Word; CounterSize: Byte; Down: Boolean; IdentIndex: integer = 0; Epilog: Boolean = true);
var svar: string;
    ValType: Byte;
begin

svar    := GetLocalName(IdentIndex);
ValType := Ident[IdentIndex].DataType;

case CounterSize of
  1: begin
     Gen($FE);                                          // ... byte ptr ...
     end;
  2: begin
     Gen($FF);                                          // ... word ptr ...
     end;
  4: begin
     Gen($66); Gen($FF);                                // ... dword ptr ...
     end;
  end;

if Down then begin
  Gen($0E);                                             // dec ...

  case CounterSize of
   1: asm65(#9'dec '+svar, '; dec ptr byte [CounterAddress]');
   2: asm65(#9'dew '+svar, '; dec ptr word [CounterAddress]');
   4: asm65(#9'ded '+svar, '; dec ptr dword [CounterAddress]');
  end;

end else begin
  Gen($06);                                             // inc ...

  case CounterSize of
   1: asm65(#9'inc '+svar, '; inc ptr byte [CounterAddress]');
   2: asm65(#9'inw '+svar, '; inc ptr word [CounterAddress]');
   4: asm65(#9'ind '+svar, '; inc ptr dword [CounterAddress]');
  end;

end;

Gen(Lo(CounterAddress)); Gen(Hi(CounterAddress));       // ... [CounterAddress]

if Epilog then begin

 if not (ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK]) then
 if Down then begin             // for label = exp to max(type)

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


procedure GenerateProgramProlog;
var i, j: Integer;
    tmp: Boolean;
    a: string;
begin

if Pass = CODEGENERATIONPASS then begin

 tmp := optimize.use;
 optimize.use := false;

 Gen($E9); Gen(Lo(NumStaticStrChars)); Gen(Hi(NumStaticStrChars));       // jmp +NumStaticStrChars

// asm65('STACKORIGIN'#9'= $98', '; zp free = $d8..$ff');
 asm65('STACKWIDTH'#9'= 16');

 asm65('CODEORIGIN'#9'= $'+IntToHex(CODEORIGIN_Atari, 4));

 asm65('');

// asm65('FRACBITS'#9'= '+IntToStr(FRACBITS));
// asm65('FRACMASK'#9'= '+IntToStr(TWOPOWERFRACBITS-1));
 asm65('TRUE'#9#9'= '+IntToStr(Ident[GetIdent('TRUE')].Value));
 asm65('FALSE'#9#9'= '+IntToStr(Ident[GetIdent('FALSE')].Value));

// asm65('');
// asm65(#9'.define @stack0 inx:STA STACKORIGIN,x');
// asm65(#9'.define @stack1 STA STACKORIGIN+STACkWIDTH,x');
// asm65(#9'.define @stack2 STA STACKORIGIN+STACkWIDTH*2,x');
// asm65(#9'.define @stack3 STA STACKORIGIN+STACkWIDTH*3,x');
// asm65(#9'.define @param .print %%1');

 asm65('');

 if ZPAGE_Atari > 0 then
  asm65(#9'org $'+IntToHex(ZPAGE_Atari, 2))
 else
  asm65(#9'org $80');

 asm65(#13#10#9'.print ''ZPFREE: $0000..'',*-1');

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

 asm65(#13#10#9'.print ''ZPFREE: '',*,''..'',$ff');

 // asm65(#13#10'@sp'#9'.ds 1');

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

 asm65(#13#10#9'jmp start');


// Build static string data table
 for i := 0 to NumStaticStrChars - 1 do
  Gen(Ord(StaticStringData[i]));				// db StaticStringData[i]

 asm65(#13#10#9'STATICDATA');
 asm65('');

// asm65(#13#10'start');

 Gen($BB); Gen(0); Gen(0);					// mov bx, STACKORIGIN
// asm65(#9'mwa #STACKORIGIN bx', '; mov bx, STACKORIGIN');

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

 asm65(#9'mvx #$00 bp','; lo BP = 0, X = 0 !!!');

 if CPUMode = 65816 then asm65(#9'opt c+');

 asm65('');
 asm65(#9'UNITINITIALIZATION');

 optimize.use := tmp;
end;

end;


procedure GenerateProgramEpilog(ExitCode: byte);
begin
Gen($B4); Gen($4C);                                                     // mov ah, 4Ch
Gen($B0); Gen($00);                                                     // mov al, 0
Gen($CD); Gen($21);                                                     // int 21h

asm65(#9'lda #$'+IntToHex(ExitCode, 2));
asm65(#9'jmp @halt');
asm65('');
end;


procedure GenerateDeclarationProlog;
begin
GenerateIfThenProlog;
end;


procedure GenerateDeclarationEpilog;
begin
GenerateIfThenEpilog;
end;


procedure GenerateRead(Value: Int64);
begin
Gen($8B); Gen($2F);                                                     // mov bp, [bx]
Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
Gen($B4); Gen($01);                                                     // mov ah, 01h
Gen($CD); Gen($21);                                                     // int 21h
Gen($88); Gen($46); Gen($00);                                           // mov [bp], al

asm65(#9'@getline');

end;// GenerateRead


procedure GenerateWriteString(Address: Word; IndirectionLevel: byte; ValueType: byte = INTEGERTOK; IdentIndex: integer = 0);
begin

asm65('');

Gen($B4); Gen($09);                                                     // mov ah, 09h

case IndirectionLevel of

  ASBOOLEAN:
    begin
     asm65(#9'jsr @printBOOLEAN');

//     Gen($B4); Gen($02);                                                     // mov ah, 02h
//     Gen($8A); Gen($17);                                                     // mov dl, [bx]
//     Gen($CD); Gen($21);                                                     // int 21h

     Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
     a65(__subBX);
    end;

  ASCHAR:
    begin
     asm65(#9'@printCHAR');

//     Gen($B4); Gen($02);                                                     // mov ah, 02h
//     Gen($8A); Gen($17);                                                     // mov dl, [bx]
//     Gen($CD); Gen($21);                                                     // int 21h

     Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
     a65(__subBX);
    end;

  ASSHORTREAL:
    begin
     asm65(#9'jsr @printSHORTREAL');

//     Gen($B4); Gen($02);                                                     // mov ah, 02h
//     Gen($8A); Gen($17);                                                     // mov dl, [bx]
//     Gen($CD); Gen($21);                                                     // int 21h

     Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
     a65(__subBX);
    end;

  ASREAL:
    begin
     asm65(#9'jsr @printREAL');

//     Gen($B4); Gen($02);                                                     // mov ah, 02h
//     Gen($8A); Gen($17);                                                     // mov dl, [bx]
//     Gen($CD); Gen($21);                                                     // int 21h

     Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
     a65(__subBX);
    end;

  ASSINGLE:
    begin
     asm65(#9'jsr @ftoa');

     Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
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

//     Gen($B4); Gen($02);                                                     // mov ah, 02h
//     Gen($8A); Gen($17);                                                     // mov dl, [bx]
//     Gen($CD); Gen($21);                                                     // int 21h

     Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
     a65(__subBX);
    end;

  ASPOINTER:
    begin
    Gen($BA); Gen(Lo(Address)); Gen(Hi(Address));                       // mov dx, Address

    asm65(#9'@printSTRING #CODEORIGIN+$'+IntToHex(Address - CODEORIGIN, 4));

//    a65(__subBX);   !!!   bez DEX-a
    end;

  ASPOINTERTOPOINTER:
    begin
    Gen($8B); Gen($16); Gen(Lo(Address)); Gen(Hi(Address));             // mov dx, [Address]

    asm65(#9'lda STACKORIGIN,x');
    asm65(#9'ldy STACKORIGIN+STACKWIDTH,x');
    asm65(#9'jsr @printSTRING');// #'+Ident[IdentIndex].Name);
    a65(__subBX);
    end;


  ASPCHAR:
    begin
    Gen($8B); Gen($16); Gen(Lo(Address)); Gen(Hi(Address));             // mov dx, [Address]

    asm65(#9'lda STACKORIGIN,x');
    asm65(#9'ldy STACKORIGIN+STACKWIDTH,x');
    asm65(#9'jsr @printPCHAR');
    a65(__subBX);
    end;


  end;

Gen($CD); Gen($21);                                                     // int 21h


end;// GenerateWriteString


procedure GenerateUnaryOperation(op: Byte; ValType: Byte = 0);
begin

case op of

  PLUSTOK:
    begin
    end;

  MINUSTOK:
    begin
    Gen($66); Gen($F7); Gen($1F);                                       // neg dword ptr [bx]

    if ValType = SINGLETOK then begin

     asm65(#9'lda STACKORIGIN,x');
     asm65(#9'sta STACKORIGIN,x');
     asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'eor #$80');
     asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');

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
    Gen($66); Gen($F7); Gen($17);                                       // not dword ptr [bx]

    if ValType = BOOLEANTOK then
     a65(__notBOOLEAN)
    else
     a65(__notaBX);

    end;

end;// case
end;


procedure GenerateBinaryOperation(op: Byte; ResultType: Byte);
begin

asm65(#13#10'; Generate Binary Operation for '+InfoAboutToken(ResultType));

Gen($66); Gen($8B); Gen($0F);                                           // mov ecx, [bx]      stackorigin,x
//a65(__movECX_aBX);

Gen($83); Gen($EB); Gen($04);                                           // sub bx, 4
//a65(__subBX);

Gen($66); Gen($8B); Gen($07);                                           // mov eax, [bx]      stackorigin-1,x
//a65(__movEAX_aBX);


case op of

  PLUSTOK:
    begin
    Gen($66); Gen($03); Gen($C1);                                       // add eax, ecx

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
    Gen($66); Gen($2B); Gen($C1);                                       // sub eax, ecx

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

    Gen($66); Gen($F7); Gen($E9);			// imul ecx

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

//      a65(__imulECX);

      asm65(#9'jsr movaBX_EAX');
      end;

   //   StopOptimization;

      end;
    end;

  DIVTOK, IDIVTOK, MODTOK:
    begin

    if ResultType in RealTypes then begin	// Real division

      Gen($66); Gen($8B); Gen($D0);				// mov edx, eax

      case ResultType of
       SHORTREALTOK: asm65(#9'jsr divmulSMALLINT.SHORTREAL');	// Q8.8 fixed-point
            REALTOK: asm65(#9'jsr divmulINT.REAL');		// Q24.8 fixed-point
          SINGLETOK: asm65(#9'jsr FDIV');			// IEEE754
      end;

    end

    else					// Integer division
      begin
      Gen($66); Gen($99);					// cdq
      Gen($66); Gen($F7); Gen($F9);				// idiv ecx

      if op = MODTOK then begin
          Gen($66); Gen($8B); Gen($C2);				// mov eax, edx		; save remainder
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
         1: asm65(#9'jsr idivAL_CL');
         2: asm65(#9'jsr idivAX_CX');
         4: asm65(#9'jsr idivEAX_ECX.CARD');
        end;

        if op = MODTOK then
          asm65(#9'jsr movZTMP_aBX')
        else
          asm65(#9'jsr movaBX_EAX');

      end;

      StopOptimization;
      end;
    end;

  SHLTOK:
    begin
    Gen($66); Gen($D3); Gen($E0);                                       // shl eax, cl

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
    Gen($66); Gen($D3); Gen($E8);                                       // shr eax, cl

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
    Gen($66); Gen($23); Gen($C1);                                       // and eax, ecx

    case DataSize[ResultType] of
      1: a65(__andAL_CL);
      2: a65(__andAX_CX);
      4: a65(__andEAX_ECX)
    end;

    end;

  ORTOK:
    begin
    Gen($66); Gen($0B); Gen($C1);                                       // or eax, ecx

    case DataSize[ResultType] of
      1: a65(__orAL_CL);
      2: a65(__orAX_CX);
      4: a65(__orEAX_ECX)
    end;

    end;

  XORTOK:
    begin
    Gen($66); Gen($33); Gen($C1);                                       // xor eax, ecx

    case DataSize[ResultType] of
      1: a65(__xorAL_CL);
      2: a65(__xorAX_CX);
      4: a65(__xorEAX_ECX)
    end;

    end;

end;// case

Gen($66); Gen($89); Gen($07);                                           // mov [bx], eax
//a65(__movaBX_EAX);

//asm65(#9'mva al STACKORIGIN-1,x');

//asm65(#9'dex');
a65(__subBX);

//StopOptimization;

end;


procedure GenerateRelationString(rel: Byte; LeftValType, RightValType: Byte);
begin
 asm65(#13#10'; relation STRING');

 Gen($66);

{
Gen($8B); Gen($0F);					// mov ecx, [bx]
//a65(__movECX_aBX);

Gen($83); Gen($EB); Gen($04);				// sub bx, 4
//a65(__subBX);

Gen($66); Gen($8B); Gen($07);				// mov eax, [bx]
//a65(__movEAX_aBX);

Gen($66); Gen($BA); GenDWord($FFFFFFFF);		// mov edx, FFFFFFFFh
//a65(__fillEDX, $FF);
}

 asm65(#9'ldy #1', '; true');

 Gen($66);

{
Gen($66); Gen($89); Gen($17);				// mov [bx], edx
//a65(__movaBX_DL);

Gen($66); Gen($BA); GenDWord($00000000);		// mov edx, 00000000h
//a65(__fillEDX, $00);

Gen($66); Gen($3B); Gen($C1);
}


 if (LeftValType = STRINGTOK) and (RightValType = STRINGTOK) then
  a65(__cmpSTRING)					// STRING ? STRING
 else
 if LeftValType = CHARTOK then
  a65(__cmpCHAR2STRING)					// CHAR ? STRING
 else
 if RightValType = CHARTOK then
  a65(__cmpSTRING2CHAR);				// STRING ? CHAR


 GenerateRelationOperation(rel, BYTETOK);

 Gen($66);

{
Gen($66); Gen($89); Gen($17);				// mov [bx], edx
//a65(__movaBX_DL);
}

 asm65(#9'dey', '; false');
 asm65('@');

 asm65(#9'sty STACKORIGIN-1,x');

 a65(__subBX);

end;


procedure GenerateRelation(rel: Byte; ValType: Byte);
begin
 asm65(#13#10'; relation');

 Gen($66);

{
Gen($66); Gen($8B); Gen($0F);				// mov ecx, [bx]
//a65(__movECX_aBX);

Gen($83); Gen($EB); Gen($04);				// sub bx, 4
//a65(__subBX);

Gen($66); Gen($8B); Gen($07);				// mov eax, [bx]
//a65(__movEAX_aBX);

Gen($66); Gen($BA); GenDWord($FFFFFFFF);		// mov edx, FFFFFFFFh
//a65(__fillEDX, $FF);
}

 asm65(#9'ldy #1', '; true');

 Gen($66);

{
Gen($66); Gen($89); Gen($17);				// mov [bx], edx
//a65(__movaBX_DL);

Gen($66); Gen($BA); GenDWord($00000000);		// mov edx, 00000000h
//a65(__fillEDX, $00);

Gen($66); Gen($3B); Gen($C1);
}

 case ValType of
     BYTETOK, CHARTOK, BOOLEANTOK:
	begin
         asm65(#9'lda STACKORIGIN-1,x');
         asm65(#9'cmp STACKORIGIN,x');
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

 Gen($66);

{
Gen($66); Gen($89); Gen($17);				// mov [bx], edx
//a65(__movaBX_DL);
}
 asm65(#9'dey', '; false');
 asm65('@');

 asm65(#9'sty STACKORIGIN-1,x');

 a65(__subBX);

end;


// The following functions implement recursive descent parser in accordance with Sub-Pascal EBNF
// Parameter i is the index of the first token of the current EBNF symbol, result is the index of the last one


function CompileConstExpression(i: Integer; var ConstVal: Int64; var ConstValType: Byte; VarType: Byte = INTEGERTOK; Err: Boolean = false; War: Boolean = true): Integer; forward;
function CompileExpression(i: Integer; var ValType: Byte; VarType: Byte = INTEGERTOK): Integer; forward;


function RecordSize(IdentIndex: integer; field: string =''): integer;
var i, j: integer;
    name, base: TName;
    FieldType, AllocElementType: Byte;
    NumAllocElements: cardinal;
    yes: Boolean;
begin

 i := Ident[IdentIndex].NumAllocElements;

 Result:=0;

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


function CompileType(i: Integer; var DataType: Byte; var NumAllocElements: cardinal; var AllocElementType: Byte): Integer; forward;


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


function CompileConstFactor(i: Integer; var ConstVal: Int64; var ConstValType: Byte): Integer;
var IdentIndex, idx, j: Integer;
    Kind, ArrayIndexType: Byte;
    ArrayIndex: Int64;
    ftmp: TFloat;
    yes: Boolean;

    function GetStaticValue(x: byte): Int64;
    begin

      Result := StaticStringData[Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_Atari - 3 + ArrayIndex * DataSize[ConstValType] + x];

    end;

begin

 Result := i;
 ConstVal:=0;
 ConstValType:=0;

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

          if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

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

     if Tok[i + 2].Kind in AllTypes then begin

      ConstValType := Tok[i + 2].Kind;

      ConstVal := DataSize[ConstValType];

      inc(i, 2);

     end else begin

      i:=CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      IdentIndex := GetIdent(Tok[i].Name^);


     case ConstValType of

        ENUMTYPE: ConstVal := DataSize[Ident[IdentIndex].AllocElementType];

       RECORDTOK: ConstVal := RecordSize(IdentIndex);

      POINTERTOK, STRINGPOINTERTOK:
                  begin

                    if Ident[IdentIndex].AllocElementType = RECORDTOK then
                     ConstVal := RecordSize(IdentIndex)
                    else
		     if Elements(IdentIndex) > 0 then
		       ConstVal := Elements(IdentIndex) * DataSize[Ident[IdentIndex].AllocElementType]
                     else
                       ConstVal := DataSize[POINTERTOK];

                  end;

      else

        if ConstValType = UNTYPETOK then
         ConstVal := 0
        else
         ConstVal := DataSize[ConstValType]

     end;

     ConstValType := GetValueType(ConstVal);

     end;

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


  LOTOK:
    begin

    CheckTok(i + 1, OPARTOK);

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

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

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

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

      GetCommonConstType(i, REALTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

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

      ConstValType := REALTOK;
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
        if Tok[i + 1].Kind = OBRACKETTOK then                    			// Array element access
          if  not (Ident[IdentIndex].DataType in Pointers) then
            iError(i, IncompatibleTypeOf, IdentIndex)
          else
            begin

            j := CompileConstExpression(i + 2, ArrayIndex, ArrayIndexType);            // Array index

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

	if (ConstValType in Pointers) then iError(i, IllegalExpression);


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
		     // Error(i + 1, 'Can''t take the address of variable');
		     if isConst then begin isError:=true; exit end;			// !!! koniecznie zamiast Error !!!


			ConstVal := Ident[IdentIndex].Value - DATAORIGIN;

			ConstValType := DATAORIGINOFFSET;


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

    ConstValType := Tok[i].Kind;

    Result := j + 1;
    end;


else
  iError(i, IdNumExpExpected);
end;// case


end;// CompileConstFactor


function CompileConstTerm(i: Integer; var ConstVal: Int64; var ConstValType: Byte): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  ftmp, ftmp_: TFloat;
  fl, fl_: single;

begin

j := CompileConstFactor(j, ConstVal, ConstValType);

if isError then exit;

while Tok[j + 1].Kind in [MULTOK, DIVTOK, IDIVTOK, MODTOK, SHLTOK, SHRTOK, ANDTOK] do
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

   IDIVTOK:  ConstVal := ConstVal div RightConstVal;
    MODTOK:  ConstVal := ConstVal mod RightConstVal;
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


function CompileSimpleConstExpression(i: Integer; var ConstVal: Int64; var ConstValType: Byte): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  ftmp, ftmp_: TFloat;
  fl, fl_: single;

begin

if Tok[i].Kind in [PLUSTOK, MINUSTOK] then j := i + 1 else j := i;

j := CompileConstTerm(j, ConstVal, ConstValType);

if isError then exit;


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



function CompileConstExpression(i: Integer; var ConstVal: Int64; var ConstValType: Byte; VarType: Byte = INTEGERTOK; Err: Boolean = false; War: Boolean = True): Integer;
var
  j: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  Yes: Boolean;

begin

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



function SafeCompileConstExpression(var i: Integer; var ConstVal: Int64; var ValType: Byte; VarType: Byte; Err: Boolean = false; War: Boolean = true): Boolean;
var j: integer;
begin

 j := i;

 isError := false;                 // dodatkowy test
 isConst := true;

 i := CompileConstExpression(i, ConstVal, ValType, VarType, Err, War);

 Result := not isError;

 isConst := false;
 isError := false;

 if not Result then i := j;

end;


function CompileArrayIndex(i: integer; IdentIndex: integer): integer;
var ConstVal: Int64;
    ActualParamType, ArrayIndexType: Byte;
    j: integer;
begin
              InfoAboutArray(IdentIndex);

              if (DataSize[Ident[IdentIndex].AllocElementType] > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) = 1) or (Ident[IdentIndex].NumAllocElements_ > 0) then
               ActualParamType := WORDTOK
              else
               ActualParamType := GetValueType(Elements(IdentIndex));

              j := i + 2;

              if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
                  i := j;

		  CheckArrayIndex(i, IdentIndex, ConstVal, ArrayIndexType);

                  ArrayIndexType := WORDTOK;

	      	  if Ident[IdentIndex].NumAllocElements_ > 0 then
		   Push(ConstVal * Ident[IdentIndex].NumAllocElements_ * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, DataSize[ArrayIndexType])
		  else
		   Push(ConstVal * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, DataSize[ArrayIndexType]);

                end else begin
                 i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);          // array index [x, ..]

                 GetCommonType(i, ActualParamType, ArrayIndexType);

                 if (DataSize[Ident[IdentIndex].AllocElementType]>1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) = 1) or (Ident[IdentIndex].NumAllocElements_ > 0) then ExpandParam(WORDTOK, ArrayIndexType);

		 if Ident[IdentIndex].NumAllocElements_ > 0 then begin
		   Push(Ident[IdentIndex].NumAllocElements_ * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, ArrayIndexType);
                   GenerateBinaryOperation(MULTOK, ArrayIndexType);

	    asm65(#9'lda STACKORIGIN,x');
	    asm65(#9'sta STACKORIGIN,x');
	    asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
	    asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
	    asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
	    asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
	    asm65(#9'lda STACKORIGIN+STACKWIDTH*3,x');
	    asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');

		 end else
		   GenerateIndexShift( Ident[IdentIndex].AllocElementType );

	      end;


            if Ident[IdentIndex].NumAllocElements_ > 0 then
     	     CheckTok(i + 1, COMMATOK)
	    else
	     CheckTok(i + 1, CBRACKETTOK);


            if Tok[i + 1].Kind = COMMATOK then begin

            	j := i + 2;

                if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
                  i := j;

		  CheckArrayIndex_(i, IdentIndex, ConstVal, ArrayIndexType);

                  ArrayIndexType := WORDTOK;

		  Push(ConstVal * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, DataSize[ArrayIndexType]);

                end else begin
                  i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);          // array index [.., y]

                  GetCommonType(i, ActualParamType, ArrayIndexType);

                  if (DataSize[Ident[IdentIndex].AllocElementType]>1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) = 1) or (Ident[IdentIndex].NumAllocElements_ > 0) then ExpandParam(WORDTOK, ArrayIndexType);

                  GenerateIndexShift( Ident[IdentIndex].AllocElementType );

		end;

                GenerateBinaryOperation(PLUSTOK, WORDTOK);

	    end;

 Result := i;
end;


function CompileAddress(i: integer; var ValType, AllocElementType: Byte): integer;
var IdentIndex: integer;
    Name, svar: string;
begin

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
            asm65(#9'mva <'+Name+' STACKORIGIN,x');
            asm65(#9'mva >'+Name+' STACKORIGIN+STACKWIDTH,x');

            if Pass = CALLDETERMPASS then
              AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);

          end else

          if (Ident[IdentIndex].DataType in Pointers) and
             (Ident[IdentIndex].NumAllocElements > 0) and
             (Tok[i + 2].Kind = OBRACKETTOK)  then
          begin                                                // array index
	      inc(i);

 // asm65(#9'atari');          // a := @tab[x,y]

	      i := CompileArrayIndex(i, IdentIndex);

 svar := GetLocalName(IdentIndex);

 asm65('');
 asm65(#9'lda '+svar);
 asm65(#9'add STACKORIGIN,x');
 asm65(#9'sta STACKORIGIN,x');
 asm65(#9'lda '+svar+'+1');
 asm65(#9'adc STACKORIGIN+STACKWIDTH,x');
 asm65(#9'sta STACKORIGIN+STACKWIDTH,x');

             CheckTok(i + 1, CBRACKETTOK);

             AllocElementType := Ident[IdentIndex].AllocElementType;

             end else
              if (Ident[IdentIndex].DataType in [FILETOK, RECORDTOK, OBJECTTOK] + Pointers) then begin

                 if (Ident[IdentIndex].DataType in Pointers) and (Tok[i + 2].Kind = DEREFERENCETOK) then begin
		   AllocElementType :=  Ident[IdentIndex].AllocElementType;

                   inc(i);
		 end;

	         if (Ident[IdentIndex].PassMethod = VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
	            (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET) then
                   Push(Ident[IdentIndex].Value, ASPOINTERTORECORD, DataSize[POINTERTOK], IdentIndex)
	         else
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


function NumActualParameters(i: integer; IdentIndex: integer; var NumActualParams: integer): TParamList;
var ActualParamType, AllocElementType: byte;
    oldPass: integer;
begin

   oldPass := Pass;
   Pass := CALLDETERMPASS;

   NumActualParams := 0;
   AllocElementType := 0;

   if Tok[i + 1].Kind = OPARTOK then                    // Actual parameter list found
     begin
     repeat

       Inc(NumActualParams);

       if NumActualParams > MAXPARAMS then
         iError(i, TooManyParameters, IdentIndex);


       if Ident[IdentIndex].Param[NumActualParams].PassMethod = VARPASSING then begin

        CompileExpression(i + 2, ActualParamType);

        Result[NumActualParams].AllocElementType := ActualParamType;

        i := CompileAddress(i + 1, ActualParamType, AllocElementType);

       end else
        i := CompileExpression(i + 2, ActualParamType);  // Evaluate actual parameters and push them onto the stack

       Result[NumActualParams].DataType := ActualParamType;

     until Tok[i + 1].Kind <> COMMATOK;

     CheckTok(i + 1, CPARTOK);

//     inc(i);
     end;// if Tok[i + 1].Kind = OPARTOR

     Pass := oldPass;
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

   if Tok[i + 1].Kind = OPARTOK then                    // Actual parameter list found
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

//      writeln(' - ',ActualParamType,',',AllocElementType, ',', Ident[IdentTemp].NumAllocElements );
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


function CompileFactor(i: Integer; var ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var IdentTemp, IdentIndex, j: Integer;
    ActualParamType, AllocElementType,  Kind, oldPass, IndirectionLevel: Byte;
    Value, ConstVal: Int64;
    Param: TParamList;
    ftmp: TFloat;
    fl: single;
begin

 Result := i;
 ValType := 0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 HIGHTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      oldPass := Pass;
      Pass := CALLDETERMPASS;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
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
      Pass := CALLDETERMPASS;

      j := i + 2;

      i:=CompileExpression(i + 2, ValType);

      Pass := oldPass;

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

      oldPass := Pass;
      Pass := CALLDETERMPASS;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;

      IdentIndex := GetIdent(Tok[i + 2].Name^);

      case ValType of
	 ENUMTYPE: Value := DataSize[Ident[IdentIndex].AllocElementType];

        RECORDTOK: Value := RecordSize(IdentIndex);

       POINTERTOK, STRINGPOINTERTOK:
                   begin

                    if Ident[IdentIndex].AllocElementType = RECORDTOK then
                     Value := RecordSize(IdentIndex)
                    else
		     if Elements(IdentIndex) > 0 then
		       Value := Elements(IdentIndex) * DataSize[Ident[IdentIndex].AllocElementType]
                     else
                       Value := DataSize[POINTERTOK];

                   end;

      else

        if ValType = UNTYPETOK then
         Value := 0
        else
         Value := DataSize[ValType]

      end;

    ValType := GetValueType(Value);

    Push(Value, ASVALUE, DataSize[ValType]);

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

          if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

           if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = CHARTOK) then begin

            a65(__addBX);
            asm65(#9'mwa '+Ident[IdentIndex].Name+' bp2');
            asm65(#9'ldy #0');
            asm65(#9'lda (bp2),y');
            asm65(#9'sta STACKORIGIN,x');

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
                    asm65(#9'lda STACKORIGIN,x', '; lo BYTE');
                    asm65(#9'and #$0f');
                    asm65(#9'sta STACKORIGIN,x');
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
     GetCommonConstType(i, REALTOK, ActualParamType);

     CheckTok(i + 1, CPARTOK);

     asm65(#9'jsr @int');

     ValType := REALTOK;
     Result:=i + 1;
    end;


  FRACTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, REALTOK, ActualParamType);

     CheckTok(i + 1, CPARTOK);

     asm65(#9'jsr @frac');

     ValType := REALTOK;
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

     asm65(#9'lda STACKORIGIN,x');
     asm65(#9'and #1');
     asm65(#9'sta STACKORIGIN,x');

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

      Push(1, ASVALUE, SHORTINTTOK);

      if Kind = PREDTOK then
       GenerateBinaryOperation(MINUSTOK, ValType)
      else
       GenerateBinaryOperation(PLUSTOK, ValType);

//      if not (ConstValType in [CHARTOK, BOOLEANTOK]) then
//       ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
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

		  asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'lda STACKORIGIN,x');
		  asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'lda #$00');
		  asm65(#9'sta STACKORIGIN,x');

		  ValType := SHORTREALTOK;
		end;


		if (ValType in IntegerTypes) and (Ident[GetIdent(Tok[i].Name^)].DataType = REALTOK) then begin

		  ExpandParam(INTEGERTOK, ValType);

		  asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'lda STACKORIGIN,x');
		  asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'lda #$00');
		  asm65(#9'sta STACKORIGIN,x');

		  ValType := REALTOK;
		end;


		if (ValType in IntegerTypes) and (Ident[GetIdent(Tok[i].Name^)].DataType = SINGLETOK) then begin

		  ExpandParam(INTEGERTOK, ValType);

		  asm65(#9'jsr I2F');

		  ValType := SINGLETOK;
		end;


		if Ident[GetIdent(Tok[i].Name^)].DataType in Pointers then
		  Error(j, 'Illegal--- type conversion: "'+InfoAboutToken(ValType)+'" to "'+Tok[i].Name^+'"');

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

          if Ident[IdentIndex].isOverload then begin
            IdentTemp := GetIdentProc( Ident[IdentIndex].Name, Param, j);

            if IdentTemp = 0 then
             iError(i, CantDetermine, IdentIndex);

            IdentIndex := IdentTemp;
          end;

        CompileActualParameters( i, IdentIndex );

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

	    if (ValType in [RECORDTOK, OBJECTTOK]) then begin

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
              Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[ValType], IdentIndex);                       // record_label^

	    end else
             Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex);

            Result := i + 1;
            end
        else if Tok[i + 1].Kind = OBRACKETTOK then                    // Array element access
          if not (Ident[IdentIndex].DataType in Pointers) or (Ident[IdentIndex].NumAllocElements = 0) then
            iError(i, IncompatibleTypeOf, IdentIndex)
          else
            begin

 //asm65(#9'amstrad');

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	    i := CompileArrayIndex(i, IdentIndex);

	    Push(Ident[IdentIndex].Value, IndirectionLevel, DataSize[Ident[IdentIndex].AllocElementType], IdentIndex);

            CheckTok(i + 1, CBRACKETTOK);

	    ValType := Ident[IdentIndex].AllocElementType;

            Result := i + 1;
            end
        else                                                          // Usual variable or constant
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


//          if ValType in IntegerTypes then
//            if DataSize[ValType] > DataSize[VarType] then ValType := VarType;     // skracaj typ danych    !!! niemozliwe skoro VarType = INTEGERTOK

	  if (Ident[IdentIndex].Kind = CONSTANT) and (ValType in Pointers) then
	   ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	  else
	   ConstVal := Ident[IdentIndex].Value;

	  if (ValType = SINGLETOK) or (VarType = SINGLETOK) then begin
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

    j:=i;

    isError := false;
    isConst := true;

    i := CompileConstTerm(i, ConstVal, ValType);

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

    Result := i;
    end;


  FRACNUMBERTOK:
    begin

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
    Result := CompileFactor(i + 1, ValType, INTEGERTOK);
    CheckOperator(i, NOTTOK, ValType);
    GenerateUnaryOperation(NOTTOK, Valtype);
    end;


  SHORTREALTOK:					// SHORTREAL	fixed-point	Q8.8
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileExpression(i + 2, ValType);//, SHORTREALTOK);

    if not(ValType in RealTypes) then begin

     ExpandParam(SMALLINTTOK, ValType);

     asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda STACKORIGIN,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta STACKORIGIN,x');

    end;

    CheckTok(j + 1, CPARTOK);

    ValType := SHORTREALTOK;

    Result := j + 1;
    end;


  REALTOK:					// REAL		fixed-point	Q24.8
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileExpression(i + 2, ValType);//, REALTOK);

    if not(ValType in RealTypes) then begin

     ExpandParam(INTEGERTOK, ValType);

     asm65(#9'lda STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda STACKORIGIN,x');
     asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta STACKORIGIN,x');

    end;

    CheckTok(j + 1, CPARTOK);

    ValType := REALTOK;

    Result := j + 1;
    end;


  SINGLETOK:					// SINGLE	IEEE-754	Q32
    begin

    CheckTok(i + 1, OPARTOK);

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

    CheckTok(i + 1, OPARTOK);

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


function CompileTerm(i: Integer; var ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType: Byte;
  ConstVal: Int64;
begin

 j := CompileFactor(i, ValType, VarType);

while Tok[j + 1].Kind in [MULTOK, DIVTOK, IDIVTOK, MODTOK, SHLTOK, SHRTOK, ANDTOK] do
  begin

  k := CompileFactor(j + 2, RightValType, VarType);

  if ((ValType = SINGLETOK) and (RightValType in [SHORTREALTOK, REALTOK])) or
   ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType = SINGLETOK)) then
    Error(j + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(RightValType)+'"');

//  if (ValType = SINGLETOK) and (RightValType = REALTOK) then RightValType := SINGLETOK;
//  if (ValType = REALTOK) and (RightValType = SINGLETOK) then ValType := SINGLETOK;

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

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



function CompileSimpleExpression(i: Integer; var ValType: Byte; VarType: Byte; War: Boolean = true): Integer;
var
  j, k: Integer;
  RightValType: Byte;
  ConstVal: Int64;
begin

if Tok[i].Kind in [PLUSTOK, MINUSTOK] then j := i + 1 else j := i;

j := CompileTerm(j, ValType, VarType);

if Tok[i].Kind = MINUSTOK then begin
 GenerateUnaryOperation(MINUSTOK, ValType);		// Unary minus

 //if ValType in IntegerTypes then ValType:=INTEGERTOK;	// !!! wymagane !!!

   if ValType in SignedOrdinalTypes then begin

     case ValType of
      SHORTINTTOK: ValType := BYTETOK;
      SMALLINTTOK: ValType := WORDTOK;
       INTEGERTOK: ValType := CARDINALTOK;
     end;

    end else

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


function CompileExpression(i: Integer; var ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType, ConstValType, isZero: Byte;
  sLeft, sRight: Boolean;
  ConstVal: Int64;
  ftmp: TFloat;
begin

 isZero := INTEGERTOK;

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


sLeft:=false;
sRight:=false;

i := CompileSimpleExpression(i, ValType, VarType);

if Tok[i].Kind = STRINGLITERALTOK then sLeft:=true else
 if (ValType in Pointers) and (Tok[i].Kind = IDENTTOK) then
  if (Ident[GetIdent(Tok[i].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i].Name^)) > 0) then sLeft:=true;


if Tok[i + 1].Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
  begin

  j := CompileSimpleExpression(i + 2, RightValType, VarType, False);


  k := i + 2;
  if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
   if ConstValType in IntegerTypes then begin

    if ConstVal = 0 then isZero := BYTETOK;

    if ConstValType in SignedOrdinalTypes then
     if ConstVal < 0 then isZero := SHORTINTTOK;

   end;


  if Tok[i + 2].Kind = STRINGLITERALTOK then sRight:=true else
   if (RightValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) then
    if (Ident[GetIdent(Tok[i + 2].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i + 2].Name^)) > 0) then sRight:=true;


  if (ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [SHORTREALTOK, REALTOK]) then
    RightValType := ValType;

//  if (ValType = SINGLETOK) and (RightValType = REALTOK) then RightValType := SINGLETOK;
//  if (ValType = REALTOK) and (RightValType = SINGLETOK) then ValType := SINGLETOK;

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


 // writeln(ValType,',',RightValType);

  if sLeft or sRight then
   else
  GetCommonType(j, ValType, RightValType);

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

// !!! wyjatek !!! porownanie typow tego samego rozmiaru, ale z roznymi znakami

   if ((ValType in SignedOrdinalTypes) and (RightValType in UnsignedOrdinalTypes)) or ((ValType in UnsignedOrdinalTypes) and (RightValType in SignedOrdinalTypes)) then
   if DataSize[ValType] = DataSize[RightValType] then
    if ValType in SignedOrdinalTypes then begin

     case DataSize[RightValType] of
      1: ExpandExpression(ValType, SMALLINTTOK, 0);
      2: ExpandExpression(ValType, INTEGERTOK, 0);
     end;

    end else begin

     case DataSize[ValType] of
      1: ExpandExpression(RightValType, SMALLINTTOK, 0);
      2: ExpandExpression(RightValType, INTEGERTOK, 0);
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
  BreakPosStack[BreakPosStackTop] := CodeSize;

end;


procedure RestoreBreakAddress;
begin

  asm65('b_'+IntToHex(BreakPosStack[BreakPosStackTop], 4));
  dec(BreakPosStackTop);

  optyA := '';
  optyBP2 := '';

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

        i := CompileAddress(i + 1, ActualParamType, AllocElementType);
       end else
        i := CompileExpression(i + 2 , ActualParamType);  // Evaluate actual parameters and push them onto the stack

       GetCommonType(i, fBlockRead_ParamType[NumActualParams], ActualParamType);

       ExpandParam(fBlockRead_ParamType[NumActualParams], ActualParamType);

       case NumActualParams of
        1: GenerateAssignment(0, ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.buffer');
        2: GenerateAssignment(0, ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.nrecord');
        3: GenerateAssignment(0, ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.numread');
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
  j, IdentIndex, IdentTemp, NumActualParams, NumCharacters: Integer;
  IfLocalCnt, CaseLocalCnt, NumCaseStatements: integer;
  Param: TParamList;
  ExpressionType, IndirectionLevel, ActualParamType, ConstValType, VarType, SelectorType: Byte;
  Value, ConstVal, ConstVal2: Int64;
  Down, ExitLoop, yes: Boolean;                          // To distinguish TO / DOWNTO loops
  CaseLabelArray: TCaseLabelArray;
  CaseLabel: TCaseLabel;
  Name, EnumName, svar, par1, par2: string;
begin

par1:='';
par2:='';

case Tok[i].Kind of
  IDENTTOK:
    begin
    IdentIndex := GetIdent(Tok[i].Name^);

//    if IdentIndex>0 then
//     writeln(Tok[i].Name^,',',Ident[IdentIndex].Kind);

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

        VARIABLE:                                                             // Variable or array element assignment
          begin

           StartOptimization(i + 1);

           if Tok[i + 1].Kind = DEREFERENCETOK then                           // With dereferencing '^'
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

             IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

	     if IdentTemp < 0 then
	      Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

             VarType := IdentTemp shr 16;
	     par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	     optyBP2 := '';

             inc(i, 2);

	    end;


            i := i + 1;
            end
          else if (Tok[i + 1].Kind = OBRACKETTOK) then                          // With indexing
            begin
            if not (Ident[IdentIndex].DataType in Pointers) then
              iError(i + 1, IncompatibleTypeOf, IdentIndex);

// asm65(#9'spectrum');       // tab[] := xxx

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	    i := CompileArrayIndex(i, IdentIndex);

            CheckTok(i + 1, CBRACKETTOK);

            VarType := Ident[IdentIndex].AllocElementType;

            inc(i);
            end
          else                                                                // Without dereferencing or indexing
            begin

            if (Ident[IdentIndex].PassMethod = VARPASSING) then begin
             IndirectionLevel := ASPOINTERTOPOINTER;
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
                       asm65(#9'mwa '+Ident[IdentIndex].Name+' bp2');
                       asm65(#9'mva #$01 (bp2),y');
                       asm65(#9'iny');
                       asm65(#9'mva #$'+IntToHex(Tok[i + 2].Value , 2)+' (bp2),y');
                     end;

                     ASPOINTERTOARRAYORIGIN:
                     begin
                       asm65(#9'mwa '+Ident[IdentIndex].Name+' bp2');
                       asm65(#9'ldy STACKORIGIN,x');
                       asm65(#9'mva #$'+IntToHex(Tok[i + 2].Value , 2)+' (bp2),y');

                       a65(__subBX);
                     end;

                     ASPOINTER:
                     begin
                       asm65(#9'mva #1 '+GetLocalName(IdentIndex, 'adr.'));
                       asm65(#9'mva #$'+IntToHex(Tok[i + 2].Value , 2)+' '+GetLocalName(IdentIndex, 'adr.')+'+1');
                     end;

                 end;            // case IndirectionLevel

                Result := i + 2;
                end;             // case CHARLITERALTOK

 // String assignment to pointer  f:='string'

                STRINGLITERALTOK:
                begin

		Ident[IdentIndex].isInit := true;

                StopOptimization;

                NumCharacters := Min(Tok[i + 2].StrLength, Ident[IdentIndex].NumAllocElements - 1);

                 case IndirectionLevel of

                   ASPOINTERTOPOINTER:

                   if Tok[i + 2].StrLength = 0 then begin
                     asm65(#9'ldy #$00');
                     asm65(#9'mwa '+Ident[IdentIndex].Name+' bp2');
                     asm65(#9'mva #$00 (bp2),y');
                   end else
                    if pos('.', Ident[IdentIndex].Name) > 0 then begin

                     asm65(#9'mwa #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' @move.src');
                     asm65(#9'adw '+copy(Ident[IdentIndex].Name,1, pos('.', Ident[IdentIndex].Name)-1) + ' #' +Ident[IdentIndex].Name +'-DATAORIGIN @move.dst');
                     asm65(#9'mwa #'+IntToStr(NumCharacters+1)+' @move.cnt');
                     asm65(#9'jsr @move');

                    end else
                     asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' '+Ident[IdentIndex].Name+' #'+IntToStr(NumCharacters+1));

                   ASPOINTERTOARRAYORIGIN:
                   GetCommonType(i + 1, CHARTOK, POINTERTOK);

                   ASPOINTER:
                   begin

                     if Tok[i + 2].StrLength = 0 then
                      asm65(#9'mva #$00 '+GetLocalName(IdentIndex, 'adr.'))
                     else
		      if Ident[IdentIndex].DataType = POINTERTOK then
		       asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN + 1, 4)+' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(NumCharacters+1))
		      else
		       asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' #'+GetLocalName(IdentIndex, 'adr.'){  Ident[IdentIndex].Name}+' #'+IntToStr(NumCharacters+1));

                     if Tok[i + 2].StrLength + 1 > Ident[IdentIndex].NumAllocElements then begin
                      Warning(i + 2, ShortStringLength);
                      asm65(#9'mva #'+IntToStr(NumCharacters)+' '+GetLocalName(IdentIndex, 'adr.'));    //adr.'+Ident[IdentIndex].Name);
                     end;

                   end;

                 end;             // case IndirectionLevel

                Result := i + 2;
                end;             // case STRINGLITERALTOK


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

                      asm65(#9'mva STACKORIGIN,x '+GetLocalName(IdentIndex, 'adr.')+'+1');
                      asm65(#9'mva #$01 '+GetLocalName(IdentIndex, 'adr.'));

                      a65(__subBX);
                     end;

                   ASPOINTERTOPOINTER:
                     begin

                       asm65(#9'ldy #$00');
                       asm65(#9'mwa '+Ident[IdentIndex].Name+' bp2');
                       asm65(#9'mva #$01 (bp2),y');
                       asm65(#9'iny');
                       asm65(#9'mva STACKORIGIN,x (bp2),y');

                       a65(__subBX);
                     end;

                   ASPOINTERTOARRAYORIGIN:
                     begin

                      asm65(#9'mwa '+Ident[IdentIndex].Name+' bp2');
                      asm65(#9'ldy STACKORIGIN-1,x');
                      asm65(#9'lda STACKORIGIN,x');
                      asm65(#9'sta (bp2),y');

                      a65(__subBX);
                      a65(__subBX);
                     end;

                 else
                    GenerateAssignment(Ident[IdentIndex].Value, IndirectionLevel, DataSize[VarType], IdentIndex);
                 end;// case IndirectionLevel

                end else

 // String assignment to pointer  var f:=txt

                if ExpressionType in Pointers then begin

                  Ident[IdentIndex].isInit := true;

                  StopOptimization;

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
                   GenerateAssignment(Ident[IdentIndex].Value, IndirectionLevel, DataSize[VarType], IdentIndex);
                  end;// case IndirectionLevel

                end else
                 iError(i, IncompatibleTypes, 0, ExpressionType, VarType);

                end;


              end; // case Tok[i + 2].Kind

              end // if
            else
              begin                                                             // Usual assignment

              if VarType = UNTYPETOK then
                Error(i, 'Assignments to formal parameters and open arrays are not possible');

              Result := CompileExpression(i + 2, ExpressionType, VarType);      // Right-hand side expression

	      if (VarType in [SHORTREALTOK, REALTOK]) and (ExpressionType in [SHORTREALTOK, REALTOK]) then
		ExpressionType := VarType;


	      if (VarType = POINTERTOK)	and (ExpressionType = STRINGPOINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType = CHARTOK) then begin		// +1
		  asm65(#9'lda STACKORIGIN,x');
	          asm65(#9'add #$01');
	          asm65(#9'sta STACKORIGIN,x');
	          asm65(#9'lda STACKORIGIN+STACKWIDTH,x');
	          asm65(#9'adc #$00');
	          asm65(#9'sta STACKORIGIN+STACKWIDTH,x');
		end else
	         if Ident[IdentIndex].AllocElementType = UNTYPETOK then
		  iError(i + 1, IncompatibleTypes, IdentIndex, STRINGPOINTERTOK, POINTERTOK)
		 else
		  GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, STRINGPOINTERTOK);

	      end;

//	if Ident[IdentIndex].Name = 'A.TX' then
//       if  (Tok[i + 2].Kind = IDENTTOK) then
//	  writeln(VarType,',', ExpressionType,' - ', Ident[IdentIndex].AllocElementType, ' - ', Ident[IdentIndex].DataType,'|',Ident[GetIdent(Tok[i + 2].Name^)].DataType,' / ',IndirectionLevel);


              CheckAssignment(i + 1, IdentIndex);

              if IndirectionLevel = ASPOINTERTOARRAYORIGIN then

	       GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, ExpressionType)

              else
               if (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) then begin
//c64
                  if (ExpressionType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) then begin

		    IdentTemp := GetIdent(Tok[i + 2].Name^);

		    {if (Tok[i + 3].Kind <> OBRACKETTOK) and ((Elements(IdentTemp) <> Elements(IdentIndex)) or (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType)) then
		     halt//iError(i + 2, IncompatibleTypesArray, GetIdent(Tok[i + 2].Name^), ExpressionType )
		    else
		     if (Elements(IdentTemp) > 0) and (Tok[i + 3].Kind <> OBRACKETTOK) then
		      iError(i + 2, IncompatibleTypesArray, IdentTemp, ExpressionType )
		    else}
		    if (Ident[IdentTemp].AllocElementType <> UNTYPETOK) and (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType) and (Tok[i + 3].Kind <> OBRACKETTOK) then begin

		     if Ident[IdentTemp].NumAllocElements = 0 then
		      iError(i + 2, IncompatibleTypesArray, IdentTemp, -IdentIndex)
		     else
		      iError(i + 2, IncompatibleTypesArray, IdentTemp, ExpressionType);

		    end else
                     if Ident[IdentTemp].AllocElementType = RECORDTOK then
                      GetCommonType(i + 1, VarType, RECORDTOK);

                 end else
		   GetCommonType(i + 1, VarType, ExpressionType);

               end else
			     if (VarType = ENUMTYPE) {and (Tok[i + 2].Kind = IDENTTOK)} then begin

				  if (Tok[i + 2].Kind = IDENTTOK) then
				    IdentTemp := GetIdent(Tok[i + 2].Name^)
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

				  if (Tok[i + 2].Kind = IDENTTOK) then
				    IdentTemp := GetIdent(Tok[i + 2].Name^)
				  else
				    IdentTemp := 0;

				  if (IdentTemp > 0) and ((Ident[IdentTemp].Kind = ENUMTYPE) or (Ident[IdentTemp].DataType = ENUMTYPE)) then
 			           iError(i, IncompatibleEnum, 0, IdentTemp, -ExpressionType)
				  else
				   GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);

				 end;

              ExpandParam(VarType, ExpressionType);                             // :=

              Ident[IdentIndex].isInit := true;

              if VarType in [RECORDTOK, OBJECTTOK] then begin

               IdentTemp := GetIdent(Tok[i + 2].Name^);

	       if ExpressionType in [RECORDTOK, OBJECTTOK] then begin

                svar := Tok[i + 2].Name^;

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

                if Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements then          // porownanie indeksow do tablicy TYPES
                  iError(i, IncompatibleTypeOf, IdentTemp);

                a65(__subBX);
                StopOptimization;

                if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = RECORDTOK) and (RecordSize(IdentIndex) <= 4) then
                  asm65(#9':'+IntToStr(RecordSize(IdentIndex))+' mva '+Name+'+# '+GetLocalName(IdentIndex, 'adr.')+'+#')
                else
		 if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentTemp].DataType in Pointers) then
                  asm65(#9'@move '+Name+' '+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)))
		 else
		  if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType in Pointers) then
                   asm65(#9'@move '+Name+' #adr.'+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)))
 		  else
                   asm65(#9'@move #'+Name+' '+Ident[IdentIndex].Name+' #'+IntToStr(RecordSize(IdentIndex)));

     	       end else           // ExpressionType <> RECORDTOK+OBJECTTOK
		 GetCommonType(i + 1, ExpressionType, RECORDTOK);

              end else
               if (VarType in Pointers) and ( (ExpressionType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) ) and
	          ( not (Ident[IdentIndex].AllocElementType in Pointers) and not (Ident[GetIdent(Tok[i + 2].Name^)].AllocElementType in Pointers)  ) and
                  ((Ident[IdentIndex].AllocElementType * Ident[IdentIndex].NumAllocElements > 0) and (Ident[GetIdent(Tok[i + 2].Name^)].AllocElementType * Ident[GetIdent(Tok[i + 2].Name^)].NumAllocElements > 0)) then begin

                j := Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType];

                IdentTemp := GetIdent(Tok[i + 2].Name^);

                Name := 'adr.'+Tok[i + 2].Name^;
                svar := Tok[i + 2].Name^;

                if IdentTemp > 0 then begin

                  if Ident[IdentTemp].Kind = FUNCTIONTOK then begin

                   svar := GetLocalName(IdentTemp);

                   IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

                   Name := svar+'.adr.result';
                   svar := svar+'.result';

                  end;

                  if j <> (Ident[IdentTemp].NumAllocElements * DataSize[Ident[IdentTemp].AllocElementType]) then
		   iError(i, IncompatibleTypesArray, IdentTemp, -IdentIndex);

           	  a65(__subBX);
                  StopOptimization;

                  if j <= 4 then
                   asm65(#9':'+IntToStr(j)+' mva '+Name+'+# '+GetLocalName(IdentIndex, 'adr.')+'+#')
                  else
                   asm65(#9'@move '+svar+' '+Ident[IdentIndex].Name+' #'+IntToStr(j));

                end;

	       end else
 	        GenerateAssignment(Ident[IdentIndex].Value, IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

              end;

//            StopOptimization;

          end;// VARIABLE


        PROC, FUNC:						// Procedure, Function (without assignment) call
          begin

	  yes := (Ident[IdentIndex].Kind = FUNC);

          Param := NumActualParameters(i, IdentIndex, j);

          if Ident[IdentIndex].isOverload then begin
            IdentTemp := GetIdentProc( Ident[IdentIndex].Name, Param, j);

            if IdentTemp = 0 then
             iError(i, CantDetermine, IdentIndex);

            IdentIndex := IdentTemp;
          end;

          CompileActualParameters( i, IdentIndex );

	  if yes then a65(__subBX);				// zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji

          Result := i;
          end;// PROC

      else
        Error(i, 'Assignment or procedure call expected but ' + Ident[IdentIndex].Name + ' found');
      end// case Ident[IdentIndex].Kind
    else
      iError(i, UnknownIdentifier)
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

    optyA := '';
    optyBP2 := '';

    StopOptimization;    // !!! potrzebujemy zachowac na stosie testowana wartosc

    i := CompileExpression(i + 1, SelectorType);

	if Tok[i].Kind = IDENTTOK then
	 EnumName := GetEnumName(GetIdent(Tok[i].Name^));


    if DataSize[SelectorType]<>1 then
     Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, OFTOK);

    GenerateCaseProlog(SelectorType, CaseLocalCnt);

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

        if Tok[i + 1].Kind = RANGETOK then                                      // Range check
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
          GenerateCaseEqualityCheck(ConstVal, SelectorType);                    // Equality check

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

      optyA := '';
      optyBP2 := '';

      asm65('@');

      j := CompileStatement(i + 1);
      i := j + 1;
      GenerateCaseStatementEpilog(CaseLocalCnt);

      Inc(NumCaseStatements);

      ExitLoop := FALSE;
      if Tok[i].Kind <> SEMICOLONTOK then
        begin
        if Tok[i].Kind = ELSETOK then              // Default statements
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

    optyA := '';
    optyBP2 := '';

    Result := i;
    end;


  IFTOK:
    begin
    ifLocalCnt := ifCnt;
    inc(ifCnt);

//    optyA := '';
//    optyBP2 := '';

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

    optyA := '';
    optyBP2 := '';

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
    inc(CodeSize);                            // !!! aby dzialaly zagniezdzone REPEAT

    asm65(#13#10'; --- RepeatUntilProlog');

    optyA := '';
    optyBP2 := '';

    GenerateRepeatUntilProlog;

    SaveBreakAddress;

    StartOptimization(i + 1);

    j := CompileStatement(i + 1);

    while Tok[j + 1].Kind = SEMICOLONTOK do
      j := CompileStatement(j + 2);

    CheckTok(j + 1, UNTILTOK);

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

      inc(CodeSize);                      // !!! aby dzialaly zagniezdzone FOR

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

            optyA := '';
            optyBP2 := '';

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


            GenerateAssignment(Ident[IdentIndex].Value, ASPOINTER, DataSize[Ident[IdentIndex].DataType], IdentIndex);

            if not (Tok[j + 1].Kind in [TOTOK, DOWNTOTOK]) then
              Error(j + 1, '''TO'' or ''DOWNTO'' expected but ' + GetSpelling(j + 1) + ' found')
            else
              begin
              Down := Tok[j + 1].Kind = DOWNTOTOK;


              inc(j, 2);

              StartOptimization(j);

              if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin
                Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);
                DefineIdent(j, '@FORTMP_'+IntToStr(CodeSize), CONSTANT, Ident[IdentIndex].DataType, 0, 0, ConstVal, Tok[j].Kind);
              end else begin
                j := CompileExpression(j, ExpressionType);
                ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
                DefineIdent(j, '@FORTMP_'+IntToStr(CodeSize), VARIABLE, Ident[IdentIndex].DataType, 0, 0, 0);
              end;

              if not (ExpressionType in OrdinalTypes) then
                iError(j, OrdinalExpectedFOR);


              IdentTemp := GetIdent('@FORTMP_'+IntToStr(CodeSize));
              GenerateAssignment(Ident[IdentTemp].Value, ASPOINTER, DataSize[Ident[IdentTemp].DataType], IdentTemp);


              asm65('; To');

              GenerateRepeatUntilProlog;      // Save return address used by GenerateForToDoEpilog

              SaveBreakAddress;

              asm65(#13#10'; ForToDoCondition');

              StartOptimization(j);
              Push(Ident[IdentTemp].Value, ASPOINTER, DataSize[Ident[IdentTemp].DataType], IdentTemp);

              GenerateForToDoCondition(Ident[IdentIndex].Value, DataSize[Ident[IdentIndex].DataType], Down, IdentIndex);  // Satisfied if counter does not reach the second expression value

              StopOptimization;

              CheckTok(j + 1, DOTOK);

                asm65(#13#10'; ForToDoProlog');

                GenerateForToDoProlog;
                j := CompileStatement(j + 2);

                asm65(#13#10'; ForToDoEpilog');
                asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop], 4));

                GenerateForToDoEpilog(Ident[IdentIndex].Value, DataSize[Ident[IdentIndex].DataType], Down, IdentIndex);

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

        GenerateAssignment(0, ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.pfname');

        StartOptimization(i);

        Push(0, ASVALUE, DataSize[BYTETOK]);

        GenerateAssignment(0, ASPOINTERTOPOINTER, 1, 0, Ident[IdentIndex].Name, 's@file.status');

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
          Push(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, 2);    // predefined record by FILE OF (default =128)

         inc(i, 3);
        end else begin
         i := CompileExpression(i + 4, ActualParamType);             // custom record size
         GetCommonType(i, WORDTOK, ActualParamType);

         ExpandParam(WORDTOK, ActualParamType);

         inc(i);
        end;

        CheckTok(i, CPARTOK);

        GenerateAssignment(0, ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

        GenerateFileOpen(IdentIndex, ioOpenRead);

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
          Push(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, 2);    // predefined record by FILE OF (default =128)

         inc(i, 3);
        end else begin
         i := CompileExpression(i + 4, ActualParamType);             // custom record size
         GetCommonType(i, WORDTOK, ActualParamType);

         ExpandParam(WORDTOK, ActualParamType);

         inc(i);
        end;

        CheckTok(i, CPARTOK);

        GenerateAssignment(0, ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

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
    if Tok[i + 1].Kind <> OPARTOK then
      iError(i + 1, OParExpected)
    else
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
//            Push(Ident[IdentIndex].Value, ASVALUE, DataSize[CHARTOK]);

            GenerateRead(Ident[IdentIndex].Value);

            if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType = CHARTOK) then begin     // string

                asm65(#9'@move #@buf #'+GetLocalName(IdentIndex, 'adr.')+' #'+IntToStr(Ident[IdentIndex].NumAllocElements));

            end else
             if (Ident[IdentIndex].DataType = CHARTOK) then
              asm65(#9'mva @buf+1 '+Ident[IdentIndex].Name)
             else
              if (Ident[IdentIndex].DataType in IntegerTypes ) then begin

                asm65(#9'@StrToInt #@buf');
                asm65(#9'mva edx '+Ident[IdentIndex].Name);
                asm65(#9'mva edx+1 '+Ident[IdentIndex].Name+'+1');
                asm65(#9'mva edx+2 '+Ident[IdentIndex].Name+'+2');
                asm65(#9'mva edx+3 '+Ident[IdentIndex].Name+'+3');

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
               begin                                   // #65#32#77
                 inc(i);

                 repeat
                   asm65(#9'@print #$'+IntToHex(Tok[i].Value ,2));
                   inc(i);
                 until Tok[i].Kind <> CHARLITERALTOK;

               end;

        STRINGLITERALTOK:                              // 'text'
               repeat
                 GenerateWriteString(Tok[i + 1].StrAddress, ASPOINTER);
                 inc(i, 2);
               until Tok[i + 1].Kind <> STRINGLITERALTOK;

        else

         begin

          j:=i + 1;

          i := CompileExpression(j, ExpressionType);

//          if ExpressionType = ENUMTYPE then
//            GenerateWriteString(Tok[i].Value, ASVALUE, INTEGERTOK)            // Enumeration argument
//	  else


          if (ExpressionType in IntegerTypes) then
                GenerateWriteString(Tok[i].Value, ASVALUE, ExpressionType)    // Integer argument
          else if (ExpressionType = BOOLEANTOK) then
                GenerateWriteString(Tok[i].Value, ASBOOLEAN)                  // Boolean argument
          else if (ExpressionType = CHARTOK) then
                GenerateWriteString(Tok[i].Value, ASCHAR)                     // Character argument
          else if ExpressionType = REALTOK then
                GenerateWriteString(Tok[i].Value, ASREAL)                     // Real argument
          else if ExpressionType = SHORTREALTOK then
                GenerateWriteString(Tok[i].Value, ASSHORTREAL)		      // ShortReal argument
          else if ExpressionType = SINGLETOK then
                GenerateWriteString(Tok[i].Value, ASSINGLE)                   // Single argument
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
                 GenerateWriteString(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, Ident[IdentIndex].DataType, IdentIndex)
		else
		if (Ident[IdentIndex].AllocElementType in [CHARTOK, POINTERTOK]) {and (Ident[IdentIndex].NumAllocElements = 0)} then
                 GenerateWriteString(Ident[IdentIndex].Value, ASPCHAR, Ident[IdentIndex].DataType, IdentIndex)
		else
                 iError(i, CantReadWrite);

          end else
           iError(i, CantReadWrite);

          END;

          inc(i);

	 end;

	j:=0;

	if Tok[i].Kind = COLONTOK then			// pomijamy formatowanie wyniku value:x:x
	 repeat
	  i := CompileExpression(i + 1, ExpressionType);
	  a65(__subBX);					// zdejmujemy ze stosu
	  inc(i);

	  inc(j); if j>1 then Break;			// maksymalnie :x:x

	 until Tok[i].Kind <> COLONTOK;


      until Tok[i].Kind <> COMMATOK;     // repeat

    CheckTok(i, CPARTOK);

    end; // if Tok[i + 1].Kind = SEMICOLONTOK

    if yes then a65(__putEOL);

    Result := i;

    end;


  ASMTOK:
    begin

     optyA := '';
     optyBP2 := '';

     StopOptimization;                       // takich blokow nie optymalizujemy

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

          if Tok[i].Kind = IDENTTOK then begin                // first parameter
            IdentIndex := GetIdent(Tok[i].Name^);

            CheckAssignment(i, IdentIndex);

            if IdentIndex = 0 then
             iError(i, UnknownIdentifier);

            if Ident[IdentIndex].Kind = VARIABLE then begin

               ExpressionType := Ident[IdentIndex].DataType;

               if ExpressionType = CHARTOK then ExpressionType := BYTETOK;    // wyjatkowo CHARTOK -> BYTETOK

               if {((Ident[IdentIndex].DataType in Pointers) and
                   (Ident[IdentIndex].NumAllocElements=0)) or}
                   (Ident[IdentIndex].DataType = REALTOK) then
                Error(i, 'Left side cannot be assigned to')
               else begin
                Value := Ident[IdentIndex].Value;

                if ExpressionType in Pointers then begin                     // Alloc Element Type
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

              if Tok[i + 1].Kind = OBRACKETTOK then begin        // array index

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


         if Tok[i + 1].Kind = COMMATOK then begin            // potencjalnie drugi parametr

           j := i + 2;
           yes:=false;

           if SafeCompileConstExpression(j, ConstVal, ActualParamType, Ident[IdentIndex].DataType, true) then
            yes:=true
           else
             j := CompileExpression(j, ActualParamType);

           i := j;

//           i := CompileExpression(i + 2, ActualParamType);
           GetCommonType(i, ExpressionType, ActualParamType);

           inc(NumActualParams);

           if Ident[IdentIndex].PassMethod <> VARPASSING then begin

            ExpandParam(ExpressionType, ActualParamType);

            if  (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

	     if yes then
              Push(ConstVal * RecordSize(IdentIndex), ASVALUE, 2)
	     else
	      Error(i, 'Under construction :)');

	    end else
            if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType in OrdinalTypes) and (IndirectionLevel <> ASPOINTERTOPOINTER) then begin            // zwieksz o N * DATASIZE jesli to wskaznik ale nie tablica

             if yes then
              Push(ConstVal * DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, DataSize[Ident[IdentIndex].DataType])
             else
              GenerateIndexShift( Ident[IdentIndex].AllocElementType );           // * DATASIZE

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

          GenerateForToDoEpilog(Value, DataSize[ExpressionType], Down, IdentIndex, false)    // +1, -1
         end else
          GenerateIncOperation(Value, IndirectionLevel, ExpressionType, Down, IdentIndex);   // +N, -N

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

      GenerateAssignment(0, ASPOINTER, DataSize[ActualParamType], 0, 'RESULT');

     end;

     asm65('');

     asm65(#9'jmp @exit', '; exit');

     Result := i;
    end;


  BREAKTOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'BREAK not allowed');

     asm65('');
     asm65(#9'jmp b_'+IntToHex(BreakPosStack[BreakPosStackTop], 4), '; break');

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

    if not(ConstVal in [0..1]) then
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

    if not(ConstVal in [0..1]) then
      Error(i, 'Interrupt Number in [0..1]');

    i := CompileExpression(i + 2, ActualParamType);
    GetCommonType(i, POINTERTOK, ActualParamType);

    case ConstVal of
     ord(iDLI): begin
                 asm65(#9'mva STACKORIGIN,x VDSLST');
                 asm65(#9'mva STACKORIGIN+STACKWIDTH,x VDSLST+1');
                 a65(__subBX);
                end;

     ord(iVBL): begin
                 asm65(#9'lda STACKORIGIN,x');
                 asm65(#9'ldy #5');
                 asm65(#9'sta wsync');
                 asm65(#9'dey');
                 asm65(#9'rne');
                 asm65(#9'sta VVBLKD');
                 asm65(#9'ldy STACKORIGIN+STACKWIDTH,x');
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


function DefineFunction(i, ForwardIdentIndex: integer; var isForward, isInt, IsNestedFunction: Boolean; var NestedFunctionResultType: Byte; var NestedFunctionNumAllocElements: cardinal; var NestedFunctionAllocElementType: Byte): integer;
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


      if Tok[i + 2].Kind = OPARTOK then                           // Formal parameter list found
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


          VarType := 0;                                                          // UNTYPED
          NumAllocElements := 0;
          AllocElementType := 0;

          if (ListPassMethod = VARPASSING)  and (Tok[i].Kind <> COLONTOK) then begin

           dec(i);

          end else begin

           CheckTok(i, COLONTOK);

           if Tok[i + 1].Kind = DEREFERENCETOK then                              // ^type
             Error(i + 1, 'Type identifier expected');

           i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

           if (VarType = FILETOK) and (ListPassMethod <> VARPASSING) then
             Error(i, 'File types must be var parameters');

          end;


          for VarOfSameTypeIndex := 1 to NumVarOfSameType do
            begin

//            if NumAllocElements > 0 then
//              Error(i, 'Structured parameters cannot be passed by value');

            Inc(Ident[NumIdent].NumParams);
            if Ident[NumIdent].NumParams > MAXPARAMS then
              iError(i, TooManyParameters, NumIdent)
            else
              begin
              VarOfSameType[VarOfSameTypeIndex].DataType                        := VarType;

              Ident[NumIdent].Param[Ident[NumIdent].NumParams].DataType         := VarType;
              Ident[NumIdent].Param[Ident[NumIdent].NumParams].Name             := VarOfSameType[VarOfSameTypeIndex].Name;
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
        Ident[NumIdent].DataType := NestedFunctionResultType;           // Result

        NestedFunctionNumAllocElements := NumAllocElements;
        Ident[NumIdent].NestedFunctionNumAllocElements := NumAllocElements;

        NestedFunctionAllocElementType := AllocElementType;
        Ident[NumIdent].NestedFunctionAllocElementType := AllocElementType;

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
//                           Ident[NumIdent].isAsm := true;
                           inc(i);
                           CheckTok(i + 1, SEMICOLONTOK);
                         end;
          end;

          inc(i);
        end;// while

 Result := i;
end;


function CompileType(i: Integer; var DataType: Byte; var NumAllocElements: cardinal; var AllocElementType: Byte): Integer;
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

  end;


begin

if Tok[i].Kind = DEREFERENCETOK then begin			// ^type

 DataType := POINTERTOK;

 if Tok[i + 1].Kind = STRINGTOK then begin			// ^string
  NumAllocElements := 0;
  AllocElementType := CHARTOK;
  DataType := STRINGPOINTERTOK;
 end else
 if Tok[i + 1].Kind = IDENTTOK then begin

  IdentIndex := GetIdent(Tok[i + 1].Name^);

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

if Tok[i].Kind = OPARTOK then begin				// enumerated

    Name := Tok[i-2].Name^;

    inc(NumTypes);
    RecType := NumTypes;

    if NumTypes > MAXTYPES then
     Error(i, 'Out of resources, MAXTYPES');

    inc(i);

    Types[RecType].NumFields := 0;
    Types[RecType].Field[0].Name := Name;

    NumFieldsInList := 0;
    ConstVal := 0;

    repeat
      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name^;

      inc(i);

      if Tok[i].Kind in [ASSIGNTOK, EQTOK] then begin

        i := CompileConstExpression(i + 1, ConstVal, ExpressionType);
//        GetCommonType(i, ConstValType, SelectorType);

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


    if (LowerBound < 0) or (UpperBound < 0) then begin

     if (LowerBound >= Low(shortint)) and (UpperBound <= High(shortint)) then DataType := SHORTINTTOK else
      if (LowerBound >= Low(smallint)) and (UpperBound <= High(smallint)) then DataType := SMALLINTTOK else
        DataType := INTEGERTOK;

    end else begin

     if (LowerBound >= Low(byte)) and (UpperBound <= High(byte)) then DataType := BYTETOK else
      if (LowerBound >= Low(word)) and (UpperBound <= High(word)) then DataType := WORDTOK else
        DataType := CARDINALTOK;

    end;

    for FieldInListIndex := 1 to NumFieldsInList do begin
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, ENUMTYPE, DataType, 0, 0, FieldInListName[FieldInListIndex].Value);
{
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, CONSTANT, POINTERTOK, length(FieldInListName[FieldInListIndex].Name)+1, CHARTOK, NumStaticStrChars + CODEORIGIN + CODEORIGIN_Atari + 3, IDENTTOK);

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

if Tok[i].Kind = FILETOK then begin                               // File

 if Tok[i + 1].Kind = OFTOK then
  i := CompileType(i + 2, DataType, NumAllocElements, AllocElementType)
 else begin
  AllocElementType := 0;//BYTETOK;
  NumAllocElements := 128;
 end;

 DataType := FILETOK;
 Result := i;

end else

if Tok[i].Kind = SETTOK then begin                                // Set Of

 CheckTok(i + 1, OFTOK);

 if not (Tok[i + 2].Kind in [CHARTOK, BYTETOK]) then
  Error(i + 2, 'Illegal type declaration of set elements');

 DataType := POINTERTOK;
 NumAllocElements := 32;
 AllocElementType := Tok[i + 2].Kind;

 Result := i + 2;

end else


  if Tok[i].Kind = OBJECTTOK then                                // Object
  begin

  Name := Tok[i-2].Name^;

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

      if Tok[i].Kind in [FUNCTIONTOK, PROCEDURETOK] then
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

    if DataType = OBJECTTOK then
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

  if Tok[i].Kind in [PACKEDTOK, RECORDTOK] then                   // Record
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
  NumAllocElements := RecType;      // indeks do tablicy Types
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
else if Tok[i].Kind = STRINGTOK then
  begin
  DataType := STRINGPOINTERTOK;
  AllocElementType := CHARTOK;

  if Tok[i + 1].Kind <> OBRACKETTOK then begin

   UpperBound:=255;                         // default string[255]

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
else if Tok[i].Kind = ARRAYTOK then
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


  if Tok[i + 1].Kind = COMMATOK then begin      // [0..x, 0..y]

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

  if NestedNumAllocElements > 0 then
    Error(i, 'Multidimensional arrays are not supported');

  AllocElementType := NestedDataType;

  Result := i;
  end // if ARRAYTOK
else if Tok[i].Kind = IDENTTOK then
  begin
  IdentIndex := GetIdent(Tok[i].Name^);

  if IdentIndex = 0 then
    iError(i, UnknownIdentifier);

  if Ident[IdentIndex].Kind <> USERTYPE then
    Error(i, 'Type expected but ' + Tok[i].Name^ + ' found');

  DataType := Ident[IdentIndex].DataType;
  NumAllocElements := Ident[IdentIndex].NumAllocElements;
  AllocElementType := Ident[IdentIndex].AllocElementType;
  Result := i;
  end // if IDENTTOK
else
  Error(i, 'Error in type definition');

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
     if Ident[IdentIndex].isAbsolute and (Ident[IdentIndex].Kind = VARIABLE) and ((Ident[IdentIndex].Value shr 24) and $7f in [1..3]) then begin
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

      VARIABLE: if Ident[IdentIndex].isAbsolute then begin

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

                end else

                 if (Ident[IdentIndex].PassMethod <> VARPASSING) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

                  asm65('adr.'+Ident[IdentIndex].Name + Value(true));
                  asm65('.var '+Ident[IdentIndex].Name+#9'= adr.' + Ident[IdentIndex].Name + ' .word');

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
    NumActualParams: integer;
    ConstVal: Int64;
begin

 CheckTok(i, OPARTOK);

 NumActualParams := 0;

 repeat

  inc(NumActualParams);
  if NumActualParams > NumAllocElements then Break;

  i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

  if (ConstValType = SINGLETOK) and (ActualParamType = REALTOK) then
   ActualParamType := SINGLETOK;

  if (ConstValType = SINGLETOK) and (ActualParamType in IntegerTypes) then begin
   Int2Float(ConstVal);
   ActualParamType := SINGLETOK;
  end;

  if (ConstValType = SHORTREALTOK) and (ActualParamType = REALTOK) then
   ActualParamType := SHORTREALTOK;


  if ActualParamType = DATAORIGINOFFSET then begin

   if StaticData then
    SaveToStaticDataSegment(ConstDataSize, ConstVal, DATAORIGINOFFSET)
   else
    SaveToDataSegment(ConstDataSize, ConstVal, DATAORIGINOFFSET);

   inc(ConstDataSize, DataSize[POINTERTOK] );

  end else begin

   if ConstValType in IntegerTypes then begin

    if GetCommonConstType(i, ConstValType, ActualParamType, false) then
     warning(i, RangeCheckError, 0, ConstVal, ConstValType);

   end else
    GetCommonConstType(i, ConstValType, ActualParamType);


   if StaticData then
    SaveToStaticDataSegment(ConstDataSize, ConstVal, ConstValType)
   else
    SaveToDataSegment(ConstDataSize, ConstVal, ConstValType);

   inc(ConstDataSize, DataSize[ConstValType] );

  end;

  inc(i);

 until Tok[ i ].Kind <> COMMATOK;

 CheckTok(i, CPARTOK);

 if NumActualParams < NumAllocElements then
  Error(i, 'Expected another '+IntToStr(NumAllocElements - NumActualParams)+' array elements');

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



procedure FormalParameterList(var i: integer; var NumParams: integer; var Param: TParamList; var Status: byte; IsNestedFunction: Boolean; var NestedFunctionResultType: Byte; var NestedFunctionNumAllocElements: cardinal; var NestedFunctionAllocElementType: Byte);
var ListPassMethod, NumVarOfSameType, VarTYpe, AllocElementType: byte;
    NumAllocElements: cardinal;
    VarOfSameTypeIndex: integer;
    VarOfSameType: TVariableList;
begin

      NumParams := 0;

      if Tok[i + 2].Kind = OPARTOK then                           // Formal parameter list found
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


          VarType := 0;                                                          // UNTYPED
          NumAllocElements := 0;
          AllocElementType := 0;

          if (ListPassMethod = VARPASSING)  and (Tok[i].Kind <> COLONTOK) then begin

           dec(i);

          end else begin

           CheckTok(i, COLONTOK);

           if Tok[i + 1].Kind = DEREFERENCETOK then                              // ^type
             Error(i + 1, 'Type identifier expected');

           i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

           if (VarType = FILETOK) and (ListPassMethod <> VARPASSING) then
             Error(i, 'File types must be var parameters');

          end;


          for VarOfSameTypeIndex := 1 to NumVarOfSameType do
            begin

//            if NumAllocElements > 0 then
//              Error(i, 'Structured parameters cannot be passed by value');

            Inc(NumParams);
            if NumParams > MAXPARAMS then
              iError(i, TooManyParameters, NumIdent)
            else
              begin
//              VarOfSameType[VarOfSameTypeIndex].DataType                        := VarType;

              Param[NumParams].DataType         := VarType;
              Param[NumParams].Name             := VarOfSameType[VarOfSameTypeIndex].Name;
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

        NestedFunctionResultType := VarType;                           // Result
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

{             FORWARDTOK: begin
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
  j, ParamIndex, NumVarOfSameType, VarOfSameTypeIndex, idx, tmpVarDataSize: Integer;
  NumAllocElements, NestedFunctionNumAllocElements: cardinal;
  ConstVal: Int64;
  IsNestedFunction, isAsm, isReg, isInt, isAbsolute, isForward, ImplementationUse: Boolean;
  iocheck_old: Boolean;
  VarType, NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType: Byte;
  NestedFunctionAllocElementType, IdType, Tmp: Byte;
  ForwardIdentIndex, IdentIndex: integer;
  TmpResult: byte;

begin

optyA := '';
optyBP2 := '';

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


if Ident[BlockIdentIndex].ObjectIndex > 0 then
 for ParamIndex := 1 to Types[Ident[BlockIdentIndex].ObjectIndex].NumFields do begin

  if ParamIndex = 1 then begin
   asm65(#9'sta bp2');
   asm65(#9'sty bp2+1');
  end;

  asm65(#9'sta '+Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name);
  asm65(#9'sty '+Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name+'+1');

  if ParamIndex <> Types[Ident[BlockIdentIndex].ObjectIndex].NumFields then begin
    asm65(#9'add #'+IntToStr(DataSize[ Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType ]) );
    asm65(#9'scc');
    asm65(#9'iny');
  end;

 end;



// Allocate parameters as local variables of the current block if necessary
for ParamIndex := 1 to NumParams do
  begin

    if Param[ParamIndex].PassMethod = VARPASSING then begin

     if isReg and (ParamIndex in [1..3]) then begin
      tmpVarDataSize := VarDataSize;

      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      Ident[GetIdent(Param[ParamIndex].Name)].isAbsolute := true;
      Ident[GetIdent(Param[ParamIndex].Name)].Value := (ParamIndex shl 24) or $80000000;

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
      Ident[GetIdent(Param[ParamIndex].Name)].Value := (ParamIndex shl 24) or $80000000;

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
     GenerateAssignment(Ident[GetIdent(Param[ParamIndex].Name)].Value, ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
  else
     GenerateAssignment(Ident[GetIdent(Param[ParamIndex].Name)].Value, ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);

  if (Param[ParamIndex].PassMethod <> VARPASSING) and (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and (Param[ParamIndex].NumAllocElements > 0) then // copy arrays
   if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then begin

    idx := RecordSize(GetIdent(Param[ParamIndex].Name));

    asm65(#9'@move '+Param[ParamIndex].Name+' #adr.'+Param[ParamIndex].Name+' #'+IntToStr(idx));
    asm65(#9'mwa #adr.'+Param[ParamIndex].Name+' '+Param[ParamIndex].Name);
   end else begin

    asm65(#9'@move '+Param[ParamIndex].Name+' #adr.'+Param[ParamIndex].Name+' #'+IntToStr(Param[ParamIndex].NumAllocElements * DataSize[Param[ParamIndex].AllocElementType]));
    asm65(#9'mwa #adr.'+Param[ParamIndex].Name+' '+Param[ParamIndex].Name);
   end;

 end;



if Ident[BlockIdentIndex].ObjectIndex > 0 then
 for ParamIndex := 1 to Types[Ident[BlockIdentIndex].ObjectIndex].NumFields do begin

  DefineIdent(i, Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name, VARIABLE,
	      POINTERTOK,
              Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,
              Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType, 0);

  Ident[NumIdent].PassMethod := VARPASSING;
 end;



asm65('');


if not isAsm then                         // skaczemy do poczatku bloku procedury, wazne dla zagniezdzonych procedur / funkcji
 GenerateDeclarationProlog;


while Tok[i].Kind in
 [CONSTTOK, TYPETOK, VARTOK, LABELTOK, PROCEDURETOK, FUNCTIONTOK, PROGRAMTOK, USESTOK,
  UNITBEGINTOK, UNITENDTOK, IMPLEMENTATIONTOK, INITIALIZATIONTOK, IOCHECKON, IOCHECKOFF] do
  begin


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

   if PROGRAMTOK_USE then
    CheckTok(i, BEGINTOK);

   CheckTok(i + 1, IDENTTOK);
   CheckTok(i + 2, SEMICOLONTOK);

   inc(i, 3);

   PROGRAMTOK_USE := true;
  end;


  if Tok[i].Kind = USESTOK then begin          // co najwyzej po PROGRAM

  if PROGRAMTOK_USE then
   if Tok[i - 3].Kind <> PROGRAMTOK then
    CheckTok(i, BEGINTOK);

  if INTERFACETOK_USE then
   if Tok[i - 1].Kind <> INTERFACETOK then
    CheckTok(i, IMPLEMENTATIONTOK);

  if ImplementationUse then
   if Tok[i - 1].Kind <> IMPLEMENTATIONTOK then
    CheckTok(i, BEGINTOK);

  inc(i);

  repeat

   CheckTok(i , IDENTTOK);

   for j := 1 to UnitName[UnitNameIndex].Units do
    if (UnitName[UnitNameIndex].Allow[j] = Tok[i].Name^) or (Tok[i].Name^='SYSTEM') then begin
     Error(i, 'Duplicate identifier '''+Tok[i].Name^+'''');
    end;

   inc(UnitName[UnitNameIndex].Units);

   if UnitName[UnitNameIndex].Units > MAXALLOWEDUNITS then
     Error(i, 'Out of resources, MAXALLOWEDUNITS');

   UnitName[UnitNameIndex].Allow[UnitName[UnitNameIndex].Units] := Tok[i].Name^;

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
           DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, POINTERTOK, NumAllocElements, AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_Atari + 3, IDENTTOK);

           j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true);

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


	if (VarType in [RECORDTOK, OBJECTTOK] + Pointers) and (NumAllocElements <= 0) then         // brak mozliwosci identyfikacji dla takiego przypadku
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


      tmpVarDataSize := VarDataSize;           // dla ABSOLUTE, RECORD

      for VarOfSameTypeIndex := 1 to NumVarOfSameType do begin

        if VarType = ENUMTYPE then begin

	  DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, AllocElementType, 0, 0, 0, IdType);

	  Ident[NumIdent].DataType := ENUMTYPE;
	  Ident[NumIdent].AllocElementType := AllocElementType;
	  Ident[NumIdent].NumAllocElements := NumAllocElements;

	end else
          DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, VarType, NumAllocElements, AllocElementType, ord(isAbsolute) * ConstVal, IdType);

//        writeln(VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',Types[NumAllocElements].Block,' | ', AllocElementType);


        if ( (VarType in Pointers) and (AllocElementType = RECORDTOK) ) then begin

	 tmpVarDataSize := VarDataSize;

         for ParamIndex := 1 to Types[NumAllocElements].NumFields do
          if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//            writeln(VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name);

            DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,
            VARIABLE,
            Types[NumAllocElements].Field[ParamIndex].DataType,
            Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
            Types[NumAllocElements].Field[ParamIndex].AllocElementType, 0, DATAORIGINOFFSET);

            Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize;
            Ident[NumIdent].PassMethod := VARPASSING;
            Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;
          end;

	  VarDataSize := tmpVarDataSize;

	end else

        if (VarType in [RECORDTOK, OBJECTTOK]) then
         for ParamIndex := 1 to Types[NumAllocElements].NumFields do
          if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//            writeln(VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name);

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

//         if Ident[NumIdent].NumAllocElements = 0 then
//          Error(i + 1, 'Illegal expression');

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

           for j := 0 to ParamIndex-1 do               // string = ''
            SaveToDataSegment(idx + j, ord( StaticStringData[ Tok[i].StrAddress - (CODEORIGIN + 3) + j ] ), BYTETOK);

          end else
	   if Ident[NumIdent].NumAllocElements = 0 then
	    iError(i, IllegalExpression)
	   else
            i := ReadDataArray(i, idx, Ident[NumIdent].AllocElementType, Ident[NumIdent].NumAllocElements);     // array [] of type = ( )

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

      if ForwardIdentIndex = 0 then                                                       // New declaration
        begin

        TestIdentProc(i, Ident[NumIdent].Name);

       // Inc(NumBlocks);
       // Ident[NumIdent].ProcAsBlock := NumBlocks;
      //  CompileBlock(NumIdent);

        if ((Pass = CODEGENERATIONPASS) and ( not Ident[NumIdent].IsNotDead) ) then   // Do not compile dead procedures and functions
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
      else                                                                                // Forward declaration resolution
        begin
      //  GenerateForwardResolution(ForwardIdentIndex);
      //  CompileBlock(ForwardIdentIndex);

        if ((Pass = CODEGENERATIONPASS) and ( not Ident[ForwardIdentIndex].IsNotDead) ) then   // Do not compile dead procedures and functions
          begin
          OutputDisabled := TRUE;
          end;

        Ident[ForwardIdentIndex].Value := CodeSize;

        FormalParameterList(i, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

        dec(i, 2);

        if ParamIndex > 0 then begin

         if Ident[ForwardIdentIndex].NumParams <> ParamIndex then
           Error(i, 'Wrong number of parameters specified for call to '+''''+Ident[ForwardIdentIndex].Name+'''');

//           function header ”arg1” doesn’t match forward : var name changes arg2 = arg3

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
         Error(i, 'Unresolved forward declaration of ' + Ident[j].Name);

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

asm65('IOCB@COPY .ds 16');

asm65('.endl');
//GenerateReturn(false, false);

asm65separator;

asm65(#13#10#9'icl ''cpu6502.asm''');

asm65separator;

asm65('');
asm65('.macro UNITINITIALIZATION');

for j := NumUnits downto 2 do begin

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

  for j := 0 to DataSegmentSize-1 do begin
   if (j mod 24 = 0) then write(OutFile, #13#10+'.by');
   if (j mod 8 = 0) then write(OutFile,' ');

   if DataSegment[j] and $c000 = $8000 then
    write(OutFile, ' <[DATAORIGIN+$' + IntToHex(byte(DataSegment[j]) + byte(DataSegment[j+1]) shl 8, 4)+']')
   else
   if DataSegment[j] and $c000 = $4000 then
    write(OutFile, ' >[DATAORIGIN+$' + IntToHex(byte(DataSegment[j-1]) + byte(DataSegment[j]) shl 8, 4)+']')
   else
   if DataSegment[j] and $3000 = $2000 then
    write(OutFile, ' <[CODEORIGIN+$' + IntToHex(byte(DataSegment[j]) + byte(DataSegment[j+1]) shl 8, 4)+']')
   else
   if DataSegment[j] and $3000 = $1000 then
    write(OutFile, ' >[CODEORIGIN+$' + IntToHex(byte(DataSegment[j-1]) + byte(DataSegment[j]) shl 8, 4)+']')
   else
    write(OutFile, ' $' + IntToHex(DataSegment[j],2) );

  end;

  asm65('');

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
asm65(#9'run CODEORIGIN');

asm65separator;


asm65(#13#10'.macro'#9'STATICDATA'#13#10);

 tmp:='.by ';
 for i := 0 to NumStaticStrChars - 1 do begin

  if (i>0) and (i mod 24=0) then tmp:=tmp+#13#10'.by ' else
   if (i>0) and (i mod 8=0) then tmp:=tmp+' ';

  if StaticStringData[i] and $c000 = $8000 then
   tmp:=tmp+' <[DATAORIGIN+'+IntToHex(byte(StaticStringData[i]) + byte(StaticStringData[i+1]) shl 8, 4)+']'
  else
  if StaticStringData[i] and $c000 = $4000 then
   tmp:=tmp+' >[DATAORIGIN+'+IntToHex(byte(StaticStringData[i-1]) + byte(StaticStringData[i]) shl 8, 4)+']'
  else
  if StaticStringData[i] and $3000 = $2000 then
   tmp:=tmp+' <[CODEORIGIN+'+IntToHex(byte(StaticStringData[i]) + byte(StaticStringData[i+1]) shl 8, 4)+']'
  else
  if StaticStringData[i] and $3000 = $1000 then
   tmp:=tmp+' >[CODEORIGIN+'+IntToHex(byte(StaticStringData[i-1]) + byte(StaticStringData[i]) shl 8, 4)+']'
  else
   tmp:=tmp+' $'+IntToHex(StaticStringData[i], 2);

 end;

 asm65(tmp);
 asm65('');
 asm65('.def START');
 asm65('');

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
        Write(DiagFile, StaticStringData[Tok[i].StrAddress - (CODEORIGIN + 3) + (CharIndex - 1)]);
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
  WriteLn('-code:$address'#9'Code origin address');
  WriteLn('-data:$address'#9'Data origin address');
  WriteLn('-stack:$address'#9'Software stack address (size = 64 bytes)');
  WriteLn('-zpage:$address'#9'Address variables on the zero page (size = 24 bytes)');

  Halt(ExitCode);

end;


procedure ParseParam;
var i, err: integer;
    optimize: Boolean;
begin

 for i := 1 to ParamCount do begin

  if ParamStr(i)[1] = '-' then begin

   if AnsiUpperCase(ParamStr(i)) = '-O' then
//    OptimizeCode := TRUE
   else
   if AnsiUpperCase(ParamStr(i)) = '-D' then
    DiagMode := TRUE
   else
   if pos('-CODE:$', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val(copy(ParamStr(i), 7, 255), CODEORIGIN_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if pos('-DATA:$', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val(copy(ParamStr(i), 7, 255), DATA_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if pos('-STACK:$', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val(copy(ParamStr(i), 8, 255), STACK_Atari, err);
     if err<>0 then Syntax(3);

   end else
   if pos('-ZPAGE:$', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val(copy(ParamStr(i), 8, 255), ZPAGE_Atari, err);
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

 WriteLn('Mad Pascal Compiler version '+title+' [2018/01/21] for 6502');

 MainPath := ExtractFilePath(ParamStr(0));

 MainPath := IncludeTrailingPathDelimiter( MainPath );
 UnitPath := IncludeTrailingPathDelimiter( MainPath + 'lib' );

 if (ParamCount = 0) then Syntax(3);

 NumUnits:=1;                             // !!! 1 !!!

 ParseParam;

 if (UnitName[1].Name='') then Syntax(3);

 if pos(MainPath, ExtractFilePath(UnitName[1].name)) > 0 then
  FilePath := ExtractFilePath(UnitName[1].Name)
 else
  FilePath := MainPath + ExtractFilePath(UnitName[1].Name);

 DecimalSeparator := '.';

 SetLength(resArray, 1);


 {$IFDEF USEOPTFILE}

 AssignFile(OptFile, ChangeFileExt(UnitName[1].Name, '.opt') ); rewrite(OptFile);

 {$ENDIF}


 AssignFile(OutFile, ChangeFileExt(UnitName[1].Name, '.a65') ); rewrite(OutFile);

 Writeln('Compiling ', UnitName[1].Name);

// Set defines for first pass
 NumDefines := 1; IfdefLevel := 0;
 Defines[1] := 'ATARI';

 TokenizeProgram;                         // AsmBlockIndex = 0

 if NumTok=0 then Error(1, '');

 inc(NumUnits);
 UnitName[NumUnits].Name := 'SYSTEM';      // default UNIT 'system.pas'
 UnitName[NumUnits].Path := UnitPath + 'system.pas';


//if NumUnits > 2 then begin               // jeszcze raz tym razem z unitami

 fillchar(Ident, sizeof(Ident), 0);
 fillchar(DataSegment, sizeof(DataSegment), 0);
 fillchar(StaticStringData, sizeof(StaticStringData), 0);

 PublicSection := true;
 UnitNameIndex := 1;

 SetLength(resArray, 1);

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

 DefineIdent(1, 'EOL',      CONSTANT, CHARTOK, 0, 0, $0000009B);
 DefineIdent(1, 'TRUE',     CONSTANT, BOOLEANTOK, 0, 0, $00000001);
 DefineIdent(1, 'FALSE',    CONSTANT, BOOLEANTOK, 0, 0, $00000000);
 DefineIdent(1, 'FRACBITS', CONSTANT, INTEGERTOK, 0, 0, FRACBITS);
 DefineIdent(1, 'FRACMASK', CONSTANT, INTEGERTOK, 0, 0, TWOPOWERFRACBITS - 1);
 DefineIdent(1, 'PI',       CONSTANT, REALTOK, 0, 0, $40490FDB00000324);
 DefineIdent(1, 'NAN',      CONSTANT, SINGLETOK, 0, 0, $FFC00000FFC00000);
 DefineIdent(1, 'INFINITY', CONSTANT, SINGLETOK, 0, 0, $7F8000007F800000);
 DefineIdent(1, 'NEGINFINITY', CONSTANT, SINGLETOK, 0, 0, $FF800000FF800000);

 DefineIdent(1, 'TMEMORYSTREAM', USERTYPE, OBJECTTOK, 0, 0, 0);

// First pass: compile the program and build call graph
 NumPredefIdent := NumIdent;
 Pass := CALLDETERMPASS;
 CompileProgram;


// Visit call graph nodes and mark all procedures that are called as not dead
 OptimizeProgram;

// Second pass: compile the program and generate output (IsNotDead fields are preserved since the first pass)
 NumIdent := NumPredefIdent;

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

 Writeln(Tok[NumTok].Line, ' lines compiled, ', NumTok, ' tokens, ',NumIdent, ' idents, ',  NumBlocks, ' blocks, ', NumTypes, ' types');

 FreeTokens;

 if High(msgWarning) > 0 then Writeln(High(msgWarning), ' warning(s) issued');
 if High(msgNote) > 0 then Writeln(High(msgNote), ' note(s) issued');

end.
