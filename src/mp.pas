(*

Sub-Pascal 32-bit real mode compiler for 80386+ processors v. 2.0 by Vasiliy Tereshkov, 2009
https://habr.com/en/post/440372/?fbclid=IwAR3SdW_HAqt6psraDj41UtNxFEXIgynOUKvS2d2cwPsJiF0kO_kDTNfYZg4

https://github.com/tebe6502/Mad-Pascal

https://atariage.com/forums/topic/240919-mad-pascal/
http://atarionline.pl/forum/comments.php?DiscussionID=4825&page=1

WUDSN IDE
https://atariage.com/forums/topic/145386-wudsn-ide-the-free-integrated-atari-8-bit-development-plugin-for-eclipse/page/25/?tab=comments#comment-4340150


Mad-Pascal cross-compiler for MOS 6502 CPU (Atari 8-bit, C64, ... ) by Tomasz Biela, 2015-2025

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

+ Daniel Serpell (https://github.com/dmsc) :
	- conditional directives {$IFDEF}, {$ELSE}, {$DEFINE} ...
	- unit SYSTEM: fsincos, fast SIN/COS (IEEE754-32 precision)
	- unit GRAPHICS: TextOut
	- unit EFAST
	- unit ZX2

+ David Schmenk :
	- IEEE-754 (32bit) Single[Float]

+ Daniel Kozminski :
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
	- RMTPLAY2 (base/atari/players/rmt_player_reloc.asm)

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

+ Krzysztof Swiecicki :
	- unit PP

+ Marcin Zukowski :
	- unit FASTGRAPH: fLine

+ Michael Jaskula :
	- {$DEFINE BASICOFF} (base\atari\basicoff.asm)

+ Peter Dell :
	- improved sources to make compilation compatible with pas2js (https://github.com/fpc/pas2js)

+ Piotr Fusik (https://github.com/pfusik) :
	- base\common\shortreal.asm (div24by15)
	- base\runtime\icmp.asm
	- unit GRAPH: detect X:Y graphics resolution (OS mode)
	- unit CRC
	- unit DEFLATE: unDEF

+ Rafal Czemko :
	- system X16 (-t x16)

+ Samuel Vin :
	- RMTPLAYV (base/atari/players/rmt_playerv_reloc.asm)

+ Sebastian Igielski :
	- unit MISC: DetectStereo

+ Simon Trew :
	- unit E80

+ Steven Don (https://www.shdon.com/) :
	- unit IMAGE, VIMAGE: BMP, GIF, PCX

+ Ullrich von Bassewitz, Christian Krueger (https://github.com/cc65/cc65/libsrc/common/) :
	- base\common\memmove.asm
	- base\common\memset.asm

+ Ullrich von Bassewitz (https://github.com/cc65/cc65/libsrc/runtime/) :
	- 8x8 => 16 multiplication routine (base\common\byte.asm)
	- 16x8 => 24 multiplication routine (base\common\word.asm)
	- 16x16 => 32 multiplication routine (base\common\word.asm)

+ Viacheslav Komenda :
	- unit LZJB
	- unit RC4

+ Wojciech Bocianski (http://bocianu.atari.pl/) :
	- library BLIBS: B_CRT, B_DL, B_PMG, B_SYSTEM, B_UTILS, XBIOS
	- MADSTRAP
	- PASDOC
	- system NEO6502 (-t neo)

+ Zlatko Bleha (https://atariwiki.org/wiki/Wiki.jsp?page=Super%20fast%20circle%20routine) :
	- GRAPH.INC Circle




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

# indeks do tablicy zawsze promowany jest do typu WORD

# :BP  tylko przy adresowaniu 1-go bajtu, :BP = $00 !!!, zmienia sie tylko :BP+1
# :BP2 przy adresowaniu wiecej niz 1-go bajtu (WORD, CARDINAL itd.)

# indeks dla jednowymiarowej tablicy [0..x] = a * GetDataSize(AllocElementType)
# indeks dla dwuwymiarowej tablicy [0..x, 0..y] = a * ((y+1) * GetDataSize(AllocElementType)) + b * GetDataSize(AllocElementType)

# dla typu OBJECT przekazywany jest poczatkowy adres alokacji danych pamieci (HI = regY, LO = regA), potem sa obliczane kolejne adresy w naglowku procedury/funkcji

# podczas wartosciowania wyrazen typy sa roszerzane, w przypadku operacji '-' promowane do SIGNEDORDINALTYPES (BYTE -> TTokenKind.SMALLINTTOK ; WORD -> TTokenKind.INTEGERTOK)

# (Tok[ ].Kind = ASMTOK + Tok[ ].Value = 0) wersja z { }
# (Tok[ ].Kind = ASMTOK + Tok[ ].Value = 1) wersja bez { }

# --------------------------------------------------------------------------------------------------------------
#                          |      DataType      |  AllocElementType  |  NumAllocElements  |  NumAllocElements_ |
# --------------------------------------------------------------------------------------------------------------
# VAR RECORD               | TTokenKind.RECORDTOK          | 0                  | RecType            | 0                  |
# VAR ^RECORD              | TTokenKind.POINTERTOK         | TTokenKind.RECORDTOK          | RecType            | 0                  |
# ARRAY [0..X]             | TTokenKind.POINTERTOK         | Type               | X Array Size       | 0                  |
# ARRAY [0..X, 0..Y]       | TTokenKind.POINTERTOK         | Type               | X Array Size       | Y Array Size       |
# ARRAY [0..X] OF ^RECORD  | TTokenKind.POINTERTOK         | TTokenKind.RECORDTOK          | RecType            | X Array Size       |
# ARRAY [0..X] OF ^OBJECT  | TTokenKind.POINTERTOK         | TTokenKind.OBJECTTOK          | RecType            | X Array Size       |
# --------------------------------------------------------------------------------------------------------------

*)

program MADPASCAL;

{$I Defines.inc}

uses
    SysUtils,
    Math, // Required for Min(), do not remove
{$IFDEF WINDOWS}
	Windows,
{$ENDIF}
{$IFDEF PAS2JS}
         browserconsole,
{$ENDIF}
	Common, CommonTypes, Console,  Diagnostic, FileIO, MathEvaluate, Messages, Numbers, Scanner, Optimize, Parser, StringUtilities, Utilities;

// Temporarily own variable, because main program is no class yet.
var evaluationContext: IEvaluationContext;

type
  TEvaluationContext = class(TInterfacedObject, IEvaluationContext)
  public
    constructor Create;
    function GetConstantName(const expression: String; var index: TStringIndex): String;
    function GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  end;

  constructor TEvaluationContext.Create;
  begin
  end;

  function TEvaluationContext.GetConstantName(const expression: String; var index: TStringIndex): String;
  begin
       Result:= GetConstantUpperCase(expression, index);
  end;

  function TEvaluationContext.GetConstantValue(const constantName: String; var constantValue: TInteger): Boolean;
  var identTemp: Integer;
  begin

  identTemp := Parser.GetIdentIndex(constantName);

  if identTemp > 0 then  begin

    constantValue := Ident[IdentTemp].Value;
    Result:=true;
    end
    else
    begin
    constantValue:=0;
    Result:=false;
      end;
  end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetIdentResult(ProcAsBlock: integer): integer;
var IdentIndex: Integer;
begin

Result := 0;

  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Block = ProcAsBlock)  and (Ident[IdentIndex].Name = 'RESULT') then exit(IdentIndex);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetOverloadName(IdentIndex: integer): string;
var ParamIndex: integer;
begin

// Result := '@' + IntToHex(Ident[IdentIndex].Value, 4);

 Result := '@' + IntToHex(Ident[IdentIndex].NumParams, 2);

 if Ident[IdentIndex].NumParams > 0 then
  for ParamIndex := Ident[IdentIndex].NumParams downto 1 do
   Result := Result + IntToHex(Ord(Ident[IdentIndex].Param[ParamIndex].PassMethod), 2) +
		      IntToHex(Ord(Ident[IdentIndex].Param[ParamIndex].DataType), 2) +
		      IntToHex(Ord(Ident[IdentIndex].Param[ParamIndex].AllocElementType), 2) +
		      IntToHex(Ident[IdentIndex].Param[ParamIndex].NumAllocElements, 8 * ord(Ident[IdentIndex].Param[ParamIndex].NumAllocElements <> 0));

 end;


function GetLocalName(IdentIndex: integer; a: string =''): string;
begin

  if ((Ident[IdentIndex].UnitIndex > 1) and (Ident[IdentIndex].UnitIndex <> UnitNameIndex) and Ident[IdentIndex].Section) then
    Result := UnitName[Ident[IdentIndex].UnitIndex].Name + '.' + a + Ident[IdentIndex].Name
  else
    Result := a + Ident[IdentIndex].Name;

end;


function ExtractName(IdentIndex: integer; const a: string): string;
var lab: string;
begin

 if {(Ident[IdentIndex].UnitIndex > 1) and} (pos(UnitName[Ident[IdentIndex].UnitIndex].Name + '.', a) = 1) then begin

   lab := Ident[IdentIndex].Name;
   if lab.IndexOf('.') > 0 then lab := copy(lab, 1, lab.LastIndexOf('.'));

   if (pos(UnitName[Ident[IdentIndex].UnitIndex].Name + '.adr.', a) = 1) then
     Result := UnitName[Ident[IdentIndex].UnitIndex].Name + '.adr.' +  lab
   else
     Result := UnitName[Ident[IdentIndex].UnitIndex].Name + '.' +  lab;

 end else
   Result := copy(a, 1, a.IndexOf('.'));

end;


function TestName(IdentIndex: integer; a: string): Boolean;
begin

  if {(Ident[IdentIndex].UnitIndex > 1) and} (pos(UnitName[Ident[IdentIndex].UnitIndex].Name + '.', a) = 1) then
    a := copy(a, a.IndexOf('.') + 2, length(a));

  Result := pos('.', a) > 0;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetIdentProc(S: TString; ProcIdentIndex: integer; Param: TParamList; NumParams: integer): integer;

type
    TBest = record
	      hit: cardinal;
              IdentIndex, b: integer;
	    end;

var IdentIndex, BlockStackIndex, i, k, b: Integer;
    hits, m: cardinal;
    df: byte;
    yes: Boolean;

    best: array of TBest;

begin

Result := 0;

best := nil;
SetLength(best, 1);
best[0] := Default(TBest);

for BlockStackIndex := BlockStackTop downto 0 do	// search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := NumIdent downto 1 do
    if
       (Ident[IdentIndex].Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) and
       (Ident[IdentIndex].UnitIndex = Ident[ProcIdentIndex].UnitIndex) and
       (S = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) and
       (Ident[IdentIndex].NumParams = NumParams) then
      begin

      hits := 0;


      for i := 1 to NumParams do
       if
	  ( ((Ident[IdentIndex].Param[i].DataType in UnsignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and
	  ( GetDataSize(Ident[IdentIndex].Param[i].DataType) >= GetDataSize(Param[i].DataType)) )
       // .
       or ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in SignedOrdinalTypes) ) and
	  (GetDataSize(Ident[IdentIndex].Param[i].DataType) >= GetDataSize(Param[i].DataType)) )
          // .
          or ( ((Ident[IdentIndex].Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in UnsignedOrdinalTypes) ) and	// smallint > byte
	  (GetDataSize(Ident[IdentIndex].Param[i].DataType) >= GetDataSize(Param[i].DataType)) )
          // .
          or ( (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) {and (Ident[IdentIndex].Param[i].AllocElementType = Param[i].AllocElementType)} )
          // .
          // or ( (Ident[IdentIndex].Param[i].AllocElementType = TDataType.PROCVARTOK) and (Ident[IdentIndex].Param[i].NumAllocElements shr 16 = Param[i].NumAllocElements shr 16) )
          // .
          or ( (Param[i].DataType in Pointers) and (Ident[IdentIndex].Param[i].DataType = Param[i].AllocElementType) )		// dla parametru VAR
          // .
          or ( (Ident[IdentIndex].Param[i].DataType = TDataType.UNTYPETOK) and (Ident[IdentIndex].Param[i].PassMethod = TParameterPassingMethod.VARPASSING) ) //

          // or ( (Ident[IdentIndex].Param[i].DataType = TDataType.UNTYPETOK) and (Ident[IdentIndex].Param[i].PassMethod = TParameterPassingMethod.VARPASSING) and (Param[i].DataType in OrdinalTypes {+ [POINTERTOK]} {IntegerTypes + [CHARTOK]}) )

	 then begin


	   if (Ident[IdentIndex].Param[i].AllocElementType = TDataType.PROCVARTOK) then begin

//	writeln(Ident[IdentIndex].Name,',', Ident[GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams,',',Param[i].AllocElementType,' | ', Ident[IdentIndex].Param[i].DataType,',', Param[i].AllocElementType,',',Ident[GetIdentIndex('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))].NumParams);

	      case Param[i].AllocElementType of

		TDataType.PROCEDURETOK, TDataType.FUNCTIONTOK :
		yes := Ident[GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams = Ident[GetIdentIndex(Param[i].Name)].NumParams;

		TDataType.PROCVARTOK :
		yes := (Ident[GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams) = (Ident[GetIdentIndex('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))].NumParams);

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

	   if (Ident[IdentIndex].Param[i].DataType = TDataType.UNTYPETOK) and (Param[i].DataType = TDataType.POINTERTOK) and
	      (Ident[IdentIndex].Param[i].AllocElementType = TDataType.UNTYPETOK) and (Param[i].AllocElementType <> TDataType.UNTYPETOK) and (Param[i].NumAllocElements > 0) {and (Ident[IdentIndex].Param[i].NumAllocElements = Param[i].NumAllocElements)} then
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

	     b := GetDataSize(Ident[IdentIndex].Param[i].DataType);	// required parameter type
	     k := GetDataSize(Param[i].DataType);			// type of parameter passed

//	     writeln('+ ',Ident[IdentIndex].Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',Ident[IdentIndex].Param[i].DataType);

	     if b >= k then begin
	      df := 4 - abs(b-k);
	      if Param[i].DataType in UnsignedOrdinalTypes then inc(df, 2);	// +2pts

	      inc(hits, df);
	      //while df > 0 do begin inc(hits); dec(df) end;
	     end;


	    end else begin						// signed

	     b := GetDataSize(Ident[IdentIndex].Param[i].DataType);	// required parameter type
	     k := GetDataSize(Param[i].DataType);			// type of parameter passed

	     if Param[i].DataType in [TDataType.BYTETOK, TDataType.WORDTOK] then inc(k);	// -> signed

//	     writeln('- ',Ident[IdentIndex].Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',Ident[IdentIndex].Param[i].DataType);

	     if b >= k then begin
	      df := 4 - abs(b-k);
	      if Param[i].DataType in SignedOrdinalTypes then inc(df, 2);	// +2pts if the same types

	      inc(hits, df);
	      //while df > 0 do begin inc(hits); dec(df) end;
	     end;

	    end;

	  end;


	   if (Ident[IdentIndex].Param[i].DataType = Param[i].DataType) and
	      (Ident[IdentIndex].Param[i].AllocElementType <> TDataType.UNTYPETOK) and
	      (Ident[IdentIndex].Param[i].AllocElementType = Param[i].AllocElementType) then

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
		(Ident[IdentIndex].Param[i].AllocElementType = Param[i].AllocElementType) or

	        ((Ident[IdentIndex].Param[i].AllocElementType = TDataType.UNTYPETOK) and (Param[i].AllocElementType <> TDataType.UNTYPETOK) and (Ident[IdentIndex].Param[i].NumAllocElements = Param[i].NumAllocElements)) or
	        ((Ident[IdentIndex].Param[i].AllocElementType <> TDataType.UNTYPETOK) and (Param[i].AllocElementType = TDataType.UNTYPETOK) and (Ident[IdentIndex].Param[i].NumAllocElements = Param[i].NumAllocElements))

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

end;	//GetIdentProc


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TestIdentProc(x: integer; S: TString);
type TOV = record
             i,j,u,b: integer;
           end;

type TL = record
		    u,b: integer;
		    Param: TParamList;
		    NumParams: word;
          end;

var IdentIndex, BlockStackIndex: Integer;
    k, m: integer;
    ok: Boolean;

    ov: array of TOV;

    l: array of TL;


procedure addOverlay(UnitIndex, Block: integer; ovr: Boolean);
var i: integer;
begin

 for i:=High(ov)-1 downto 0 do
  if (ov[i].u = UnitIndex) and (ov[i].b = Block) then begin

   inc(ov[i].i, ord(ovr));
   inc(ov[i].j);

   exit;
  end;

  i:=High(ov);

  ov[i].u := UnitIndex;
  ov[i].b := Block;
  ov[i].i := ord(ovr);
  ov[i].j := 1;

  SetLength(ov, i+2);

end;


begin

ov:=nil;
SetLength(ov, 1);
l:=nil;
SetLength(l, 1);

for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := NumIdent downto 1 do
    if (Ident[IdentIndex].Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) and
       (S = Ident[IdentIndex].Name) and
       (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
    begin

     for k := 0 to High(l)-1 do
      if (Ident[IdentIndex].NumParams = l[k].NumParams) and (Ident[IdentIndex].UnitIndex = l[k].u) and (Ident[IdentIndex].Block = l[k].b)  then begin

       ok := true;

       for m := 1 to l[k].NumParams do begin
	if (Ident[IdentIndex].Param[m].DataType <> l[k].Param[m].DataType) or (Ident[IdentIndex].Param[m].AllocElementType <> l[k].Param[m].AllocElementType) then begin ok := false; Break end;


        if (Ident[IdentIndex].Param[m].DataType = l[k].Param[m].DataType) and (Ident[IdentIndex].Param[m].AllocElementType = TDataType.PROCVARTOK) and
	(l[k].Param[m].AllocElementType = TDataType.PROCVARTOK) and
	(Ident[IdentIndex].Param[m].NumAllocElements shr 16 <> l[k].Param[m].NumAllocElements shr 16) then begin

	//writeln('>',Ident[IdentIndex].NumParams);//,',', l[k].Param[m].NumParams );

	 ok := false; Break

	end;


       end;

       if ok then
                Error(x, TMessage.Create(TErrorCode.WrongParameterList, 'Overloaded functions ''' +
                  Ident[IdentIndex].Name + ''' have the same parameter list'));

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
          Error(x, TMessage.Create(TErrorCode.NotAllDeclarationsOverloaded, 'Not all declarations of ' +
            Ident[NumIdent].Name + ' are declared with OVERLOAD'));

 SetLength(l, 0);
 SetLength(ov, 0);

end;	//TestIdentProc


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddCallGraphChild(ParentBlock, ChildBlock: Integer);
begin

 if ParentBlock <> ChildBlock then begin

  Inc(CallGraph[ParentBlock].NumChildren);
  CallGraph[ParentBlock].ChildBlock[CallGraph[ParentBlock].NumChildren] := ChildBlock;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure asm65separator(a: Boolean = true);
begin

 if a then asm65;

 asm65('; '+StringOfChar('-',60));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure a65(code: TCode65; Value: Int64 = 0; Kind: TTokenKind = CONSTANT; Size: Byte = 4; IdentIndex: integer = 0);
var v: byte;
    svar: string;
begin

  case code of

	 TCode65.putEOL: asm65(#9'@printEOL');
	TCode65.putCHAR: asm65(#9'jsr @printCHAR');

      TCode65.shlAL_CL: asm65(#9'jsr @shlEAX_CL.BYTE');
      TCode65.shlAX_CL: asm65(#9'jsr @shlEAX_CL.WORD');
      TCode65.shlEAX_CL: asm65(#9'jsr @shlEAX_CL.CARD');

       TCode65.shrAL_CL: asm65(#9'jsr @shrAL_CL');
       TCode65.shrAX_CL: asm65(#9'jsr @shrAX_CL');
      TCode65.shrEAX_CL: asm65(#9'jsr @shrEAX_CL');

	     TCode65.je: asm65(#9'beq *+5');					// =
	    TCode65.jne: asm65(#9'bne *+5');					// <>

//	     TCode65.jg: begin asm65(#9'seq'); asm65(#9'bcs *+5') end;	// >
//	    TCode65.jge: asm65(#9'bcs *+5');					// >=
//	     TCode65.jl: asm65(#9'bcc *+5');					// <
//	    TCode65.jle: begin asm65(#9'bcc *+7'); asm65(#9'beq *+5') end;	// <=

	  TCode65.addBX: asm65(#9'inx');
	  TCode65.subBX: asm65(#9'dex');

       TCode65.addAL_CL: asm65(#9'jsr addAL_CL');
       TCode65.addAX_CX: asm65(#9'jsr addAX_CX');
     TCode65.addEAX_ECX: asm65(#9'jsr addEAX_ECX');

       TCode65.subAL_CL: asm65(#9'jsr subAL_CL');
       TCode65.subAX_CX: asm65(#9'jsr subAX_CX');
     TCode65.subEAX_ECX: asm65(#9'jsr subEAX_ECX');

	TCode65.imulECX: asm65(#9'jsr imulECX');

//     TCode65.notBOOLEAN: asm65(#9'jsr notBOOLEAN');
//	 TCode65.notaBX: asm65(#9'jsr notaBX');

//	 TCode65.negaBX: asm65(#9'jsr negaBX');

//     TCode65.xorEAX_ECX: asm65(#9'jsr xorEAX_ECX');
//       TCode65.xorAX_CX: asm65(#9'jsr xorAX_CX');
//       TCode65.xorAL_CL: asm65(#9'jsr xorAL_CL');

//     TCode65.andEAX_ECX: asm65(#9'jsr andEAX_ECX');
//       TCode65.andAX_CX: asm65(#9'jsr andAX_CX');
//       TCode65.andAL_CL: asm65(#9'jsr andAL_CL');

//      TCode65.orEAX_ECX: asm65(#9'jsr orEAX_ECX');
//	TCode65.orAX_CX: asm65(#9'jsr orAX_CX');
//	TCode65.orAL_CL: asm65(#9'jsr orAL_CL');

//     TCode65.cmpEAX_ECX: asm65(#9'jsr cmpEAX_ECX');
//       TCode65.cmpAX_CX: asm65(#9'jsr cmpEAX_ECX.AX_CX');
//    TCode65.cmpSHORTINT: asm65(#9'jsr cmpSHORTINT');
//    TCode65.cmpSMALLINT: asm65(#9'jsr cmpSMALLINT');
//	   TCode65.cmpINT: asm65(#9'jsr cmpINT');

//      TCode65.cmpSTRING: asm65(#9'jsr cmpSTRING');

 TCode65.cmpSTRING2CHAR: asm65(#9'jsr cmpSTRING2CHAR');
 TCode65.cmpCHAR2STRING: asm65(#9'jsr cmpCHAR2STRING');

   TCode65.movaBX_Value: begin
//		    asm65(#9'ldx sp', '; mov dword ptr [bx], Value');

		    if Kind=VARIABLE then begin		      // @label

		     svar := GetLocalName(IdentIndex);

		     asm65(#9'mva <' + svar + GetStackVariable(0));
		     asm65(#9'mva >' + svar + GetStackVariable(1));

		    end else begin

		     // Size:=4;

		     v:=byte(Value);
		     asm65(#9'mva #$' + IntToHex(byte(v), 2) + GetStackVariable(0));

		     if Size in [2,4] then begin
		       v:=byte(Value shr 8);
		       asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(1));
		     end;

		     if Size = 4 then begin
		       v:=byte(Value shr 16);
		       asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(2));

		       v:=byte(Value shr 24);
		       asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(3));
		     end;

		   end;

   end;

		   end;

end;	//a65


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Gen;
begin

 if not OutputDisabled then Inc(CodeSize);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandParam(Dest, Source: TDataType);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 if (Source in IntegerTypes) and (Dest in IntegerTypes) then begin

 i:=GetDataSize(Dest) - GetDataSize(Source);

 if i > 0 then
  case i of
   1: if (Source in SignedOrdinalTypes) then	// to WORD
       asm65(#9'jsr @expandSHORT2SMALL')
      else
       asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x');

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

end;	//ExpandParam


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandParam_m1(Dest, Source: TDataType);
(*----------------------------------------------------------------------------*)
(*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
(*----------------------------------------------------------------------------*)
var i: integer;
begin

 if (Source in IntegerTypes) and (Dest in IntegerTypes) then begin

 i:=GetDataSize(Dest) - GetDataSize(Source);


 if i>0 then
  case i of
   1: if (Source in SignedOrdinalTypes) then	// to WORD
       asm65(#9'jsr @expandSHORT2SMALL1')
      else
       asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x');

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

end;	//ExpandParam_m1

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandExpression(var ValType: TDataType; RightValType, VarType: TDataType; ForceMinusSign: Boolean = False);
var
  m: Byte;
  sign: Boolean;
begin

  if (ValType in IntegerTypes) and (RightValType in IntegerTypes) then
  begin

    if (GetDataSize(ValType) < GetDataSize(RightValType)) and ((VarType = TDataType.UNTYPETOK) or
      (GetDataSize(RightValType) >= GetDataSize(VarType))) then
    begin
      ExpandParam_m1(RightValType, ValType);    // -1
      ValType := RightValType;        // przyjmij najwiekszy typ dla operacji
    end
    else
    begin

      if VarType in Pointers then VarType := TDataType.WORDTOK;

      m := GetDataSize(ValType);
      if GetDataSize(RightValType) > m then m := GetDataSize(RightValType);

      if VarType = TDataType.BOOLEANTOK then
        Inc(m)            // dla sytuacji np.: boolean := (shortint + shorint > 0)
      else

      if VarType <> TDataType.UNTYPETOK then
        if GetDataSize(VarType) > m then Inc(m);    // okreslamy najwiekszy wspolny typ
      //m:=GetDataSize(VarType];


      if (ValType in SignedOrdinalTypes) or (RightValType in SignedOrdinalTypes) or ForceMinusSign then
        sign := True
      else
        sign := False;

      case m of
        1: if sign then VarType := TDataType.SHORTINTTOK
          else
            VarType := TDataType.BYTETOK;
        2: if sign then VarType := TDataType.SMALLINTTOK
          else
            VarType := TDataType.WORDTOK;
        else
          if sign then VarType := TDataType.INTEGERTOK
          else
            VarType := TDataType.CARDINALTOK
      end;

      ExpandParam_m1(VarType, ValType);
      ExpandParam(VarType, RightValType);

      ValType := VarType;

    end;

  end;

end;  //ExpandExpression

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandWord; //(regA: integer = -1);
begin

 Gen;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ExpandByte;
begin

Gen;

ExpandWord;	// (0);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIndexShift(ElementType: TDataType; Ofset: Byte = 0);
begin

  case GetDataSize(ElementType) of

    2: if Ofset = 0 then begin
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN,x');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

	asm65(#9'asl :STACKORIGIN,x');
	asm65(#9'rol @');

	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN,x');
       end else begin
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*3,x');
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH,x');

	asm65(#9'asl :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'rol @');

	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH,x');
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+',x');
       end;

    4: if Ofset = 0 then begin
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN,x');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

	asm65(#9'asl :STACKORIGIN,x');
	asm65(#9'rol @');
	asm65(#9'asl :STACKORIGIN,x');
	asm65(#9'rol @');

	asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN,x');
       end else begin
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*3,x');
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH,x');

	asm65(#9'asl :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'rol @');
	asm65(#9'asl :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'rol @');

	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+'+STACKWIDTH,x');
	asm65(#9'lda :STACKORIGIN-'+IntToStr(Ofset)+',x');
	asm65(#9'sta :STACKORIGIN-'+IntToStr(Ofset)+',x');
       end;

  end;

end;	//GenerateIndexShift


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure StopOptimization;
begin

 if run_func = 0 then begin

  common.optimize.use := false;

  if High(OptimizeBuf) > 0 then asm65;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure StartOptimization(i: integer);
begin

  StopOptimization;

  common.optimize.use := true;
  common.optimize.unitIndex := Tok[i].UnitIndex;
  common.optimize.line:= Tok[i].Line;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure LoadBP2(IdentIndex: integer; svar: string);
var lab: string;
begin

  if (pos('.', svar) > 0) then begin

//	lab:=copy(svar,1,pos('.', svar)-1);
	lab := ExtractName(IdentIndex, svar);

	if Ident[GetIdentIndex(lab)].AllocElementType = TDataType.RECORDTOK then begin

	 asm65(#9'mwy ' + lab + ' :bp2');		// !!! koniecznie w ten sposob
							// !!! kolejne optymalizacje podstawia pod :BP2 -> LAB
	 asm65(#9'lda :bp2');
	 asm65(#9'add #' + svar + '-DATAORIGIN');
	 asm65(#9'sta :bp2');
	 asm65(#9'lda :bp2+1');
	 asm65(#9'adc #$00');
	 asm65(#9'sta :bp2+1');

	end else
	 asm65(#9'mwy ' + svar + ' :bp2');

  end else
	asm65(#9'mwy ' + svar + ' :bp2');

end;	//LoadBP2


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure Push(Value: Int64; IndirectionLevel: Byte; Size: Byte; IdentIndex: integer = 0; par: byte = 0);
var Kind: TTokenKind;
    NumAllocElements: cardinal;
    svar, svara, lab: string;
begin

 if IdentIndex > 0 then begin
  Kind := Ident[IdentIndex].Kind;

  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   Size := GetDataSize(Ident[IdentIndex].AllocElementType);
   NumAllocElements := 0;
  end else
   NumAllocElements := Elements(IdentIndex);	//Ident[IdentIndex].NumAllocElements;

  svar := GetLocalName(IdentIndex);

 end else begin
  Kind := CONSTANT;
  NumAllocElements := 0;
  svar := '';
 end;

 svara := svar;
 if pos('.', svar) > 0 then
  svara := GetLocalName(IdentIndex, 'adr.')
 else
  svara := 'adr.' + svar;

 asm65separator;

 asm65;
 asm65('; Push' + InfoAboutSize(Size));

case IndirectionLevel of

  ASVALUE:
    begin
    asm65('; as Value $'+IntToHex(Value, 8) + ' ('+IntToStr(Value)+')');
    asm65;

    a65(TCode65.addBX);

    Gen;
    a65(TCode65.movaBX_Value, Value, Kind, Size, IdentIndex);

    end;


  ASPOINTER:
    begin
    asm65('; as Pointer');
    asm65;

    Gen;

    a65(TCode65.addBX);

    case Size of

      1: begin
	  asm65(#9'mva ' + svar + GetStackVariable(0));

	  ExpandByte;
	 end;

      2: begin

  	 if TestName(IdentIndex, svar) then begin

	  lab := ExtractName(IdentIndex, svar);

	if Ident[GetIdentIndex(lab)].AllocElementType = TDataType.RECORDTOK then begin
	   asm65(#9'lda ' + lab);
	   asm65(#9'ldy ' + lab + '+1');
	   asm65(#9'add #' + svar + '-DATAORIGIN');
	   asm65(#9'scc');
	   asm65(#9'iny');
	   asm65(#9'sta' + GetStackVariable(0));
	   asm65(#9'sty' + GetStackVariable(1));
	  end else begin
	   asm65(#9'mva ' + svar +        GetStackVariable(0));
	   asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
	  end;

         end else begin
	  asm65(#9'mva ' + svar +        GetStackVariable(0));
	  asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
         end;

	 ExpandWord;
	 end;

      4: begin
	  asm65(#9'mva ' + svar +        GetStackVariable(0));
	  asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
	  asm65(#9'mva ' + svar + '+2' + GetStackVariable(2));
	  asm65(#9'mva ' + svar + '+3' + GetStackVariable(3));
	 end;

      end;

    end;


  ASPOINTERTORECORD:
    begin
    asm65('; as Pointer to Record');
    asm65;

    Gen;

    a65(TCode65.addBX);

    if TestName(IdentIndex, svar) then
     asm65(#9'lda #' + svar + '-DATAORIGIN')
    else
     asm65(#9'lda #$' + IntToHex(par, 2));

    if TestName(IdentIndex, svar) then begin
     asm65(#9'add ' + ExtractName(IdentIndex, svar));
     asm65(#9'sta' + GetStackVariable(0));
     asm65(#9'lda #$00');
     asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
     asm65(#9'sta' + GetStackVariable(1));
    end else begin
     asm65(#9'add ' + svar);
     asm65(#9'sta' + GetStackVariable(0));
     asm65(#9'lda #$00');
     asm65(#9'adc ' + svar + '+1');
     asm65(#9'sta' + GetStackVariable(1));
    end;

    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer');
    asm65;

    Gen;

    a65(TCode65.addBX);

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('+'+svar);	// +lda

//	writeln(Ident[IdentIndex].PassMethod,',', Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', svar,',',ExtractName(IdentIndex, svar),',',par);

    if TestName(IdentIndex, svar) then begin

     if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType <> TDataType.UNTYPETOK) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) then
      asm65(#9'mwy ' + svar + ' :bp2')
     else
      asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

    end else
     asm65(#9'mwy ' + svar + ' :bp2');


    if TestName(IdentIndex, svar) then begin

     if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType <> TDataType.UNTYPETOK) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) then
      asm65(#9'ldy #$' + IntToHex(par, 2))
     else
      asm65(#9'ldy #' + svar + '-DATAORIGIN');

    end else
     asm65(#9'ldy #$' + IntToHex(par, 2));

    case Size of
      1: begin

	 asm65(#9'mva (:bp2),y' + GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin

	 asm65(#9'mva (:bp2),y' + GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y' + GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin

	 asm65(#9'mva (:bp2),y' + GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y' + GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y' + GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'mva (:bp2),y' + GetStackVariable(3));

	 end;
      end;

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('+');	// +lda

    end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');
    asm65;

    Gen;

    case Size of
      1: begin										// PUSH BYTE

	 if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('+'+svar);	// +lda

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

	    asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
	    asm65(#9'add' + GetStackVariable(0));
	    asm65(#9'tay');
	    asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
	    asm65(#9'adc' + GetStackVariable(1));
	    asm65(#9'sta :bp+1');

	  end else begin

	    asm65(#9'lda '+svar);
	    asm65(#9'add' + GetStackVariable(0));
	    asm65(#9'tay');
	    asm65(#9'lda '+svar+'+1');
	    asm65(#9'adc' + GetStackVariable(1));
	    asm65(#9'sta :bp+1');

	  end;

	  asm65(#9'lda (:bp),y');
	  asm65(#9'sta' + GetStackVariable(0));

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('+');	// +lda

	 end else begin

	  if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

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

      2: begin										// PUSH WORD

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(TDataType.WORDTOK);

	 asm65;

	 if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

	  if Ident[IdentIndex].isStriped then begin

	   asm65(#9'lda' + GetStackVariable(0));
	   asm65(#9'add #$00');
	   asm65(#9'tay');
	   asm65(#9'lda' + GetStackVariable(1));
	   asm65(#9'adc #$00');
	   asm65(#9'sta' + GetStackVariable(1));

	   asm65(#9'lda ' + svara + ',y');
	   asm65(#9'sta' + GetStackVariable(0));
	   asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
	   asm65(#9'sta' + GetStackVariable(1));

	  end else begin

	    if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
	      asm65(#9'add' + GetStackVariable(0));
	      asm65(#9'sta :bp2');
	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
	      asm65(#9'adc' + GetStackVariable(1));
	      asm65(#9'sta :bp2+1');

	    end else begin

	      asm65(#9'lda '+svar);
	      asm65(#9'add' + GetStackVariable(0));
	      asm65(#9'sta :bp2');
	      asm65(#9'lda '+svar+'+1');
	      asm65(#9'adc' + GetStackVariable(1));
	      asm65(#9'sta :bp2+1');

	    end;

	    asm65(#9'ldy #$00');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta' + GetStackVariable(0));
	    asm65(#9'iny');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta' + GetStackVariable(1));

	  end;

	 end else begin

	  if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy :STACKORIGIN,x');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(0));
	   asm65(#9'iny');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(1));

	  end else begin

	   asm65(#9'lda' + GetStackVariable(0));
	   asm65(#9'add #$00');
	   asm65(#9'tay');
	   asm65(#9'lda' + GetStackVariable(1));
	   asm65(#9'adc #$00');
	   asm65(#9'sta' + GetStackVariable(1));

	   asm65(#9'lda ' + svara + ',y');
	   asm65(#9'sta' + GetStackVariable(0));

	   if Ident[IdentIndex].isStriped then
	     asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
	   else
	     asm65(#9'lda ' + svara + '+1,y');

	   asm65(#9'sta' + GetStackVariable(1));
// =w'
	  end;

	 end;

	 ExpandWord;
	 end;

      4: begin											// PUSH CARDINAL

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(TDataType.CARDINALTOK);

	 asm65;

	 if (NumAllocElements * 4 > 256) or (NumAllocElements in [0,1]) then begin

	  if Ident[IdentIndex].isStriped then begin

	    asm65(#9'lda' + GetStackVariable(0));
	    asm65(#9'add #$00');
	    asm65(#9'tay');
	    asm65(#9'lda' + GetStackVariable(1));
	    asm65(#9'adc #$00');
	    asm65(#9'sta' + GetStackVariable(1));

	    asm65(#9'lda ' + svara + ',y');
	    asm65(#9'sta' + GetStackVariable(0));
	    asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements)) + ',y');
	    asm65(#9'sta' + GetStackVariable(1));
	    asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements*2)) + ',y');
	    asm65(#9'sta' + GetStackVariable(2));
 	    asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements*3)) + ',y');
	    asm65(#9'sta' + GetStackVariable(3));

	  end else begin

	    if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
	      asm65(#9'add' + GetStackVariable(0));
	      asm65(#9'sta :bp2');
	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
	      asm65(#9'adc' + GetStackVariable(1));
	      asm65(#9'sta :bp2+1');

	    end else begin

	      asm65(#9'lda '+svar);
	      asm65(#9'add' + GetStackVariable(0));
	      asm65(#9'sta :bp2');
	      asm65(#9'lda '+svar+'+1');
	      asm65(#9'adc' + GetStackVariable(1));
	      asm65(#9'sta :bp2+1');

	    end;

	    asm65(#9'ldy #$00');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta' + GetStackVariable(0));
	    asm65(#9'iny');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta' + GetStackVariable(1));
	    asm65(#9'iny');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta' + GetStackVariable(2));
	    asm65(#9'iny');
	    asm65(#9'lda (:bp2),y');
	    asm65(#9'sta' + GetStackVariable(3));

	  end;

	 end else begin

	  if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy :STACKORIGIN,x');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(0));
	   asm65(#9'iny');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(1));
	   asm65(#9'iny');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(2));
	   asm65(#9'iny');
	   asm65(#9'lda (:bp2),y');
	   asm65(#9'sta' + GetStackVariable(3));

	  end else begin

	   asm65(#9'lda' + GetStackVariable(0));
	   asm65(#9'add #$00');
	   asm65(#9'tay');
	   asm65(#9'lda' + GetStackVariable(1));
	   asm65(#9'adc #$00');
	   asm65(#9'sta' + GetStackVariable(1));

	   asm65(#9'lda ' + svara + ',y');
	   asm65(#9'sta' + GetStackVariable(0));

	   if Ident[IdentIndex].isStriped then begin

	     asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements)) + ',y');
             asm65(#9'sta' + GetStackVariable(1));
	     asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements*2)) + ',y');
             asm65(#9'sta' + GetStackVariable(2));
	     asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements*3)) + ',y');
             asm65(#9'sta' + GetStackVariable(3));

	   end else begin

	     asm65(#9'lda ' + svara + '+1,y');
             asm65(#9'sta' + GetStackVariable(1));
	     asm65(#9'lda ' + svara + '+2,y');
	     asm65(#9'sta' + GetStackVariable(2));
 	     asm65(#9'lda ' + svara + '+3,y');
	     asm65(#9'sta' + GetStackVariable(3));

	   end;
// =c'
	  end;

	 end;

	 end;
      end;

    end;


ASPOINTERTOARRAYRECORD:									// array [0..X] of ^record
    begin
    asm65('; as Pointer to Array ^Record');
    asm65;

    Gen;

    asm65(#9'lda' + GetStackVariable(0));

    if TestName(IdentIndex, svar) then begin
     asm65(#9'add ' + ExtractName(IdentIndex, svar));
     asm65(#9'sta :TMP');
     asm65(#9'lda' + GetStackVariable(1));
     asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
     asm65(#9'sta :TMP+1');
    end else begin
     asm65(#9'add ' + svar);
     asm65(#9'sta :TMP');
     asm65(#9'lda' + GetStackVariable(1));
     asm65(#9'adc ' + svar + '+1');
     asm65(#9'sta :TMP+1');
    end;

    asm65(#9'ldy #$00');
    asm65(#9'mva (:TMP),y :bp2');
    asm65(#9'iny');
    asm65(#9'mva (:TMP),y :bp2+1');

    if TestName(IdentIndex, svar) then
     asm65(#9'ldy #' + svar + '-DATAORIGIN')
    else
     asm65(#9'ldy #$' + IntToHex(par, 2));

    case Size of
      1: begin

	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin

	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin

	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(3));

	 end;
      end;

    end;


ASPOINTERTOARRAYRECORDTOSTRING:									// array_of_pointer_to_record[index].string
    begin
    asm65('; as Pointer to Array ^Record to String');
    asm65;

    Gen;

    asm65(#9'lda' + GetStackVariable(0));

    if TestName(IdentIndex, svar) then begin
     asm65(#9'add ' + ExtractName(IdentIndex, svar));
     asm65(#9'sta :bp2');
     asm65(#9'lda' + GetStackVariable(1));
     asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
     asm65(#9'sta :bp2+1');
    end else begin
     asm65(#9'add ' + svar);
     asm65(#9'sta :bp2');
     asm65(#9'lda' + GetStackVariable(1));
     asm65(#9'adc ' + svar + '+1');
     asm65(#9'sta :bp2+1');
    end;

    asm65(#9'ldy #$00');
    asm65(#9'lda (:bp2),y');

    if TestName(IdentIndex, svar) then begin
     asm65(#9'add #' + svar + '-DATAORIGIN')
    end else
     asm65(#9'add #$' + IntToHex(par, 2));

    asm65(#9'sta' + GetStackVariable(0));

    asm65(#9'iny');
    asm65(#9'lda (:bp2),y');
    asm65(#9'adc #$00');
    asm65(#9'sta' + GetStackVariable(1));

    end;


ASPOINTERTORECORDARRAYORIGIN:									// record^.array[i]
    begin
    asm65('; as Pointer to Record^ Array Origin');
    asm65;

    Gen;

    if TestName(IdentIndex, svar) then
      asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2')
    else
      asm65(#9'mwy ' + svar + ' :bp2');

    asm65(#9'lda' + GetStackVariable(0));

    if TestName(IdentIndex, svar) then
      asm65(#9'add #' + svar + '-DATAORIGIN')
    else
      asm65(#9'add #$' + IntToHex(par, 2));

    asm65(#9'sta' + GetStackVariable(0));
    asm65(#9'lda' + GetStackVariable(1));
    asm65(#9'adc #$00');
    asm65(#9'sta' + GetStackVariable(1));

    asm65(#9'ldy' + GetStackVariable(0));

    case Size of
      1: begin

	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(0));

	 ExpandByte;
	 end;

      2: begin

	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(1));

	 ExpandWord;
	 end;

      4: begin

	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(0));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(1));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(2));
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta' + GetStackVariable(3));

	 end;
      end;

    end;


ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN:							// record_array[index].array[i]
    begin

  if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

    if TestName(IdentIndex, svar) then begin
     asm65(#9'lda ' + ExtractName(IdentIndex, svar));
     asm65(#9'add :STACKORIGIN-1,x');
     asm65(#9'sta :TMP');
     asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
     asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'sta :TMP+1');
    end else begin
     asm65(#9'lda ' + svar);
     asm65(#9'add :STACKORIGIN-1,x');
     asm65(#9'sta :TMP');
     asm65(#9'lda ' + svar+'+1');
     asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'sta :TMP+1');
    end;

    asm65(#9'ldy #$00');
    asm65(#9'lda (:TMP),y');
    asm65(#9'sta :bp2');
    asm65(#9'iny');
    asm65(#9'lda (:TMP),y');
    asm65(#9'sta :bp2+1');

   end else begin

     asm65(#9'ldy :STACKORIGIN-1,x');
//   asm65(#9'lda adr.' + svar + ',y');
     asm65(#9'lda ' + svara + ',y');
     asm65(#9'sta :bp2');
//   asm65(#9'lda adr.' + svar + '+1,y');
     asm65(#9'lda ' + svara + '+1,y');
     asm65(#9'sta :bp2+1');

   end;

   asm65(#9'lda :STACKORIGIN,x');
   asm65(#9'add #$' + IntToHex(par,2));
   asm65(#9'sta :STACKORIGIN,x');
   asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
   asm65(#9'adc #$00');
   asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

   asm65(#9'ldy :STACKORIGIN,x');

    case Size of
      1: begin
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1,x');
	 end;

      2: begin
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1,x');
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
	 end;

      4: begin
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1,x');
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
	 end;

      end;

//     a65(TCode65.subBX);
     a65(TCode65.subBX);

    end;


end;// case

end;	//Push


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveToSystemStack(cnt: integer);
var i: integer;
begin
// asm65;
// asm65('; Save conditional expression');		//at expression stack top onto the system :STACK');

 Gen; Gen; Gen;						// push dword ptr [bx]

 if Pass = TPass.CODE_GENERATION then
  for i in IFTmpPosStack do
   if i = cnt then begin
    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'sta :STACKORIGIN,x');

    Break;
   end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RestoreFromSystemStack(cnt: integer);
var i: integer;
begin
 //asm65;
 //asm65('; Restore conditional expression');

 Gen; Gen; Gen;						// add bx, 4

 asm65(#9'lda IFTMP_' + IntToHex(cnt, 4));

 if Pass = TPass.CALL_DETERMINATION then begin

  i:=High(IFTmpPosStack);

  IFTmpPosStack[i] := cnt;

  SetLength(IFTmpPosStack, i+2);

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RemoveFromSystemStack;
begin

 Gen; Gen;						// pop :eax

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateFileOpen(IdentIndex: Integer; ioCode: TIOCode);
begin

 ResetOpty;

 asm65;
 asm65(#9'txa:pha');

 if IOCheck then
  asm65(#9'sec')
 else
  asm65(#9'clc');

 case ioCode of

   TIOCode.Append,
   TIOCode.OpenRead,
   TIOCode.OpenWrite:

	asm65(#9'@openfile '+Ident[IdentIndex].Name+', #'+IntToStr(ord(ioCode)));

   TIOCode.FileMode:

	asm65(#9'@openfile '+Ident[IdentIndex].Name+', MAIN.SYSTEM.FileMode');

   TIOCode.Close:

   	asm65(#9'@closefile '+Ident[IdentIndex].Name);

 end;

 asm65(#9'pla:tax');
 asm65;

end;	//GenerateFileOpen


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateFileRead(IdentIndex: Integer; ioCode: TIOCode; NumParams: integer = 0);
begin

 ResetOpty;

 asm65;
 asm65(#9'txa:pha');

 if IOCheck then
  asm65(#9'sec')
 else
  asm65(#9'clc');

 case ioCode of

   TIOCode.Read,
   TIOCode.Write,
   TIOCode.ReadRecord,
   TIOCode.WriteRecord:

	if NumParams = 3 then
	  asm65(#9'@readfile '+Ident[IdentIndex].Name+', #'+IntToStr(GetIOBits(ioCode) or $80))
	else
	  asm65(#9'@readfile '+Ident[IdentIndex].Name+', #'+IntToStr(GetIOBits(ioCode)));

 end;

 asm65(#9'pla:tax');
 asm65;

end;	//GenerateFileRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIncDec(IndirectionLevel: Byte; ExpressionType: TDataType; Down: Boolean; IdentIndex: TIdentIndex);
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

	     case GetDataSize(ExpressionType) of
	      1: begin
		  asm65(#9'lda ' + svar);
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta ' + svar);
		 end;

	      2: begin
		  asm65(#9'lda ' + svar);
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta ' + svar);

		  asm65(#9'lda ' + svar + '+1');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta ' + svar + '+1');
		 end;

	      4: begin
		  asm65(#9'lda ' + svar);
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta ' + svar);

		  asm65(#9'lda ' + svar + '+1');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta ' + svar + '+1');

		  asm65(#9'lda ' + svar + '+2');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta ' + svar + '+2');

		  asm65(#9'lda ' + svar + '+3');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta ' + svar + '+3');
	      end;

	     end;

	end;


  ASPOINTERTOPOINTER:
	begin

	   asm65('; as Pointer To Pointer');
	   asm65;

	   LoadBP2(IdentIndex, svar);

	   asm65(#9'ldy #$00');

	     case GetDataSize(ExpressionType) of
	      1: begin
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      2: begin
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		 end;

	      4: begin
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta (:bp2),y');
	      end;

	     end;

	end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
	begin

	     asm65('; as Pointer To Array Origin');
	     asm65;

	     case GetDataSize(ExpressionType) of
	      1: begin

		  if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

		   asm65(#9'lda ' + svar);
		   asm65(#9'add :STACKORIGIN-1,x');
		   asm65(#9'tay');

		   asm65(#9'lda ' + svar + '+1');
		   asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		   asm65(#9'sta :bp+1');

		   asm65;
		   asm65(#9'lda (:bp),y');
		   asm65(#9 + b + ' :STACKORIGIN,x');
		   asm65(#9'sta (:bp),y');

		  end else begin

		   if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

		    LoadBP2(IdentIndex, svar);

		    asm65(#9'ldy :STACKORIGIN-1,x');
		    asm65(#9'lda (:bp2),y');
		    asm65(#9 + b + ' :STACKORIGIN,x');
		    asm65(#9'sta (:bp2),y');

		   end else begin
{
		    asm65(#9'ldy :STACKORIGIN-1,x');
		    asm65(#9'lda '+svara+',y');
		    asm65(#9 + b + ' :STACKORIGIN,x');
		    asm65(#9'sta '+svara+',y');
}
		    asm65(#9'lda <'+svara);
		    asm65(#9'add :STACKORIGIN-1,x');
		    asm65(#9'tay');

		    asm65(#9'lda >'+svara);
		    asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		    asm65(#9'sta :bp+1');

		    asm65(#9'lda (:bp),y');
		    asm65(#9 + b + ' :STACKORIGIN,x');
		    asm65(#9'sta (:bp),y');

		   end;

		  end;

		 end;

	      2: if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

		  LoadBP2(IdentIndex, svar);

		  asm65(#9'lda :bp2');
		  asm65(#9'add :STACKORIGIN-1,x');
		  asm65(#9'sta :bp2');
		  asm65(#9'lda :bp2+1');
		  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		  asm65(#9'sta :bp2+1');

		  asm65(#9'ldy #$00');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c  + ' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');

	      	 end else begin

	 	  if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

		   if Ident[IdentIndex].isStriped  then begin

		     asm65(#9'lda :STACKORIGIN-1,x');
		     asm65(#9'add #$00');
		     asm65(#9'tay');
		     asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		     asm65(#9'adc #$00');
		     asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		     asm65(#9'lda ' + svara + ',y');
		     asm65(#9 + b + ' :STACKORIGIN,x');
		     asm65(#9'sta ' + svara + ',y');
		     asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		     asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

		   end else begin

		     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

		       asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
		       asm65(#9'add :STACKORIGIN-1,x');
		       asm65(#9'sta :bp2');
		       asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
		       asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		       asm65(#9'sta :bp2+1');

		     end else begin

		       asm65(#9'lda ' + svar);
		       asm65(#9'add :STACKORIGIN-1,x');
		       asm65(#9'sta :bp2');
		       asm65(#9'lda ' + svar + '+1');
		       asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		       asm65(#9'sta :bp2+1');

		     end;

		     asm65(#9'ldy #$00');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9 + b + ' :STACKORIGIN,x');
		     asm65(#9'sta (:bp2),y');
		     asm65(#9'iny');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		     asm65(#9'sta (:bp2),y');

		   end;

		  end else begin

		   asm65(#9'ldy :STACKORIGIN-1,x');
		   asm65(#9'lda ' + svara + ',y');
		   asm65(#9 + b + ' :STACKORIGIN,x');
		   asm65(#9'sta ' + svara + ',y');
		   asm65(#9'lda ' + svara + '+1,y');
		   asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		   asm65(#9'sta ' + svara + '+1,y');

		  end;

		 end;

	      4: if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

		  LoadBP2(IdentIndex, svar);

		  asm65(#9'lda :bp2');
		  asm65(#9'add :STACKORIGIN-1,x');
		  asm65(#9'sta :bp2');
		  asm65(#9'lda :bp2+1');
		  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		  asm65(#9'sta :bp2+1');

		  asm65(#9'ldy #$00');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + b + ' :STACKORIGIN,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta (:bp2),y');
		  asm65(#9'iny');
		  asm65(#9'lda (:bp2),y');
		  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta (:bp2),y');

	      	 end else begin

	 	  if (NumAllocElements * 4 > 256) or (NumAllocElements in [0,1]) then begin

	   	   if Ident[IdentIndex].isStriped then begin

	     	     asm65(#9'lda :STACKORIGIN-1,x');
	     	     asm65(#9'add #$00');
	     	     asm65(#9'tay');
	     	     asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	     	     asm65(#9'adc #$00');
	     	     asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		     asm65(#9'lda ' + svara + ',y');
		     asm65(#9 + b + ' :STACKORIGIN,x');
		     asm65(#9'sta ' + svara + ',y');
		     asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements)) + ',y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		     asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements)) + ',y');
		     asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements*2)) + ',y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
		     asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements*2)) + ',y');
		     asm65(#9'lda ' + svara + '+' + IntToStr(integer(NumAllocElements*3)) + ',y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
		     asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements*3)) + ',y');

		   end else begin

		     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

		       asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
		       asm65(#9'add :STACKORIGIN-1,x');
		       asm65(#9'sta :bp2');
		       asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
		       asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		       asm65(#9'sta :bp2+1');

		     end else begin

		       asm65(#9'lda ' + svar);
		       asm65(#9'add :STACKORIGIN-1,x');
		       asm65(#9'sta :bp2');
		       asm65(#9'lda ' + svar + '+1');
		       asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		       asm65(#9'sta :bp2+1');

		     end;

		     asm65(#9'ldy #$00');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9 + b + ' :STACKORIGIN,x');
		     asm65(#9'sta (:bp2),y');
		     asm65(#9'iny');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		     asm65(#9'sta (:bp2),y');
		     asm65(#9'iny');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
		     asm65(#9'sta (:bp2),y');
		     asm65(#9'iny');
		     asm65(#9'lda (:bp2),y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
		     asm65(#9'sta (:bp2),y');

		   end;

		  end else begin

		   asm65(#9'ldy :STACKORIGIN-1,x');
		   asm65(#9'lda ' + svara + ',y');
		   asm65(#9 + b + ' :STACKORIGIN,x');
		   asm65(#9'sta ' + svara + ',y');
		   asm65(#9'lda ' + svara + '+1,y');
		   asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		   asm65(#9'sta ' + svara + '+1,y');
		   asm65(#9'lda ' + svara + '+2,y');
		   asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'sta ' + svara + '+2,y');
		   asm65(#9'lda ' + svara + '+3,y');
		   asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
		   asm65(#9'sta ' + svara + '+3,y');

		  end;

		 end;

	     end;

	   a65(TCode65.subBX);

	end;

 end;

 a65(TCode65.subBX);
end;	//GenerateIncDec


procedure GenerateAssignment(IndirectionLevel: Byte; Size: Byte; IdentIndex: integer; Param: string = ''; ParamY: string = '');
var NumAllocElements: cardinal;
    IdentTemp: integer;
    svar, svara: string;


  procedure LoadRegisterY;
  begin

    if ParamY <> '' then
     asm65(#9'ldy #' + ParamY)
    else
     if pos('.', Ident[IdentIndex].Name) > 0 then begin

       if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and not (Ident[IdentIndex].AllocElementType in [TDataType.UNTYPETOK, TDataType.PROCVARTOK]) then
        asm65(#9'ldy #$00')
       else
        asm65(#9'ldy #' + svar + '-DATAORIGIN');

     end else
      asm65(#9'ldy #$00');

  end;


begin

 if IdentIndex > 0 then begin

  if Ident[IdentIndex].DataType = ENUMTYPE then begin
   Size := GetDataSize(Ident[IdentIndex].AllocElementType);
   NumAllocElements := 0;
  end else
   NumAllocElements := Elements(IdentIndex);

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

  ASPOINTERTOARRAYRECORD:						// array_of_record_pointers[index]
    begin
    asm65('; as Pointer to Array ^Record');


  if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

    if TestName(IdentIndex, svar) then begin

     IdentTemp := GetIdentIndex(ExtractName(IdentIndex, svar));
            if (IdentTemp > 0) and (Ident[IdentTemp].DataType = TDataType.POINTERTOK) and
              (Ident[IdentTemp].AllocElementType = TDataType.RECORDTOK) and (Ident[IdentTemp].NumAllocElements_ > 1) and
              (Ident[IdentTemp].NumAllocElements_ <= 128) then
            begin

       asm65(#9'lda :STACKORIGIN-1,x');
       asm65(#9'add #$00');
       asm65(#9'tay');
       asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
       asm65(#9'adc #$00');
       asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

       asm65(#9'lda ' + GetLocalName(IdentTemp, 'adr.') + ',y');
       asm65(#9'sta :bp2');
       asm65(#9'lda ' + GetLocalName(IdentTemp, 'adr.') + '+1,y');
       asm65(#9'sta :bp2+1');

     end else begin
       asm65(#9'lda ' + ExtractName(IdentIndex, svar));
       asm65(#9'add :STACKORIGIN-1,x');
       asm65(#9'sta :TMP');
       asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
       asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
       asm65(#9'sta :TMP+1');

       asm65(#9'ldy #$00');
       asm65(#9'mva (:TMP),y :bp2');
       asm65(#9'iny');
       asm65(#9'mva (:TMP),y :bp2+1');

     end;

    end else begin
     asm65(#9'lda '+svar);
     asm65(#9'add :STACKORIGIN-1,x');
     asm65(#9'sta :TMP');
     asm65(#9'lda '+svar+'+1');
     asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'sta :TMP+1');

     asm65(#9'ldy #$00');
     asm65(#9'mva (:TMP),y :bp2');
     asm65(#9'iny');
     asm65(#9'mva (:TMP),y :bp2+1');

    end;
{
    asm65(#9'ldy #$00');
    asm65(#9'mva (:TMP),y :bp2');
    asm65(#9'iny');
    asm65(#9'mva (:TMP),y :bp2+1');
}
   end else begin

     asm65(#9'ldy :STACKORIGIN-1,x');
//   asm65(#9'lda adr.' + svar + ',y');
     asm65(#9'lda ' + svara + ',y');
     asm65(#9'sta :bp2');
//   asm65(#9'lda adr.'+svar+'+1,y');
     asm65(#9'lda ' + svara + '+1,y');
     asm65(#9'sta :bp2+1');

   end;

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

     a65(TCode65.subBX);
     a65(TCode65.subBX);

    end;


 ASPOINTERTODEREFERENCE:
    begin
    asm65('; as Pointer to Dereference');

    asm65(#9'lda :STACKORIGIN-1,x');
    asm65(#9'sta :bp2');
    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'sta :bp2+1');

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

    a65(TCode65.subBX);
    a65(TCode65.subBX);

    end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');

    case Size of
      1: begin										// PULL BYTE

	 if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('-'+svar);	// -sta

	    if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
	      asm65(#9'add :STACKORIGIN-1,x');
	      asm65(#9'tay');
	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
	      asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	      asm65(#9'sta :bp+1');

	    end else begin

	      asm65(#9'lda ' + svar);
	      asm65(#9'add :STACKORIGIN-1,x');
	      asm65(#9'tay');
	      asm65(#9'lda ' + svar + '+1');
	      asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	      asm65(#9'sta :bp+1');

	    end;

	    asm65(#9'lda :STACKORIGIN,x');
	    asm65(#9'sta (:bp),y');

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('-');	// -sta

	 end else begin

	 if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

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
	  asm65(#9'sta ' + svara + ',y');
// =b'
	 end;

	 end;

	 a65(TCode65.subBX);
	 a65(TCode65.subBX);
	 end;

      2: begin										// PULL WORD

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(TDataType.WORDTOK, 1);

	 if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

	   if Ident[IdentIndex].isStriped  then begin

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'add #$00');
		asm65(#9'tay');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'adc #$00');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta ' + svara + ',y');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

	   end else begin

	     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

		asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
		asm65(#9'add :STACKORIGIN-1,x');
		asm65(#9'sta :bp2');
		asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
		asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta :bp2+1');

	     end else begin

		asm65(#9'lda ' + svar);
		asm65(#9'add :STACKORIGIN-1,x');
		asm65(#9'sta :bp2');
		asm65(#9'lda ' + svar + '+1');
		asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta :bp2+1');

	     end;

	     asm65(#9'ldy #$00');
	     asm65(#9'lda :STACKORIGIN,x');
	     asm65(#9'sta (:bp2),y');
	     asm65(#9'iny');
	     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	     asm65(#9'sta (:bp2),y');

	   end;

	 end else begin

	 if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

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
	  asm65(#9'sta ' + svara + ',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

	  if Ident[IdentIndex].isStriped then
	    asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
	  else
	    asm65(#9'sta ' + svara + '+1,y');
// w='
	 end;

	 end;

	 a65(TCode65.subBX);
	 a65(TCode65.subBX);

	 end;

      4: begin										// PULL CARDINAL

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	  GenerateIndexShift(TDataType.CARDINALTOK, 1);

	 if (NumAllocElements * 4 > 256) or (NumAllocElements in [0,1]) then begin

	   if Ident[IdentIndex].isStriped then begin

	     asm65(#9'lda :STACKORIGIN-1,x');
	     asm65(#9'add #$00');
	     asm65(#9'tay');
	     asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	     asm65(#9'adc #$00');
	     asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	     asm65(#9'lda :STACKORIGIN,x');
	     asm65(#9'sta ' + svara + ',y');
	     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  	     asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements)) + ',y');
	     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
  	     asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements*2)) + ',y');
	     asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
  	     asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements*3)) + ',y');

	   end else begin

	     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = TDataType.ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

		asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
		asm65(#9'add :STACKORIGIN-1,x');
		asm65(#9'sta :bp2');
		asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
		asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta :bp2+1');

	     end else begin

		asm65(#9'lda '+svar);
		asm65(#9'add :STACKORIGIN-1,x');
		asm65(#9'sta :bp2');
		asm65(#9'lda '+svar+'+1');
		asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta :bp2+1');

	     end;

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

	   end;

	 end else begin

	 if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

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
	  asm65(#9'sta ' + svara + ',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

	  if Ident[IdentIndex].isStriped then begin

	    asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements)) + ',y');
	    asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	    asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements*2)) + ',y');
	    asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	    asm65(#9'sta ' + svara + '+' + IntToStr(integer(NumAllocElements*3)) + ',y');

	  end else begin

	    asm65(#9'sta ' + svara + '+1,y');
	    asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	    asm65(#9'sta ' + svara + '+2,y');
	    asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	    asm65(#9'sta ' + svara + '+3,y');

	  end;
// c='
	 end;

	 end;

	 a65(TCode65.subBX);
	 a65(TCode65.subBX);

	 end;
      end;
    end;


  ASSTRINGPOINTER1TOARRAYORIGIN:
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
	 asm65(#9'pha');
	 asm65(#9'iny');
	 asm65(#9'lda (:bp2),y');
	 asm65(#9'sta :bp2+1');
	 asm65(#9'pla');
	 asm65(#9'sta :bp2');

	 end else begin

	 if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

	  LoadBP2(IdentIndex, svar);

	  asm65(#9'ldy :STACKORIGIN-1,x');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'pha');
	  asm65(#9'iny');
	  asm65(#9'lda (:bp2),y');
	  asm65(#9'sta :bp2+1');
 	  asm65(#9'pla');
 	  asm65(#9'sta :bp2');

	 end else begin

	  asm65(#9'lda :STACKORIGIN-1,x');
	  asm65(#9'add #$00');
	  asm65(#9'tay');
	  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	  asm65(#9'adc #$00');
	  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	  asm65(#9'lda '+svara+',y');
	  asm65(#9'sta :bp2');
	  asm65(#9'lda '+svara+'+1,y');
	  asm65(#9'sta :bp2+1');

	 end;

	 end;

         asm65(#9'ldy #$00');
	 asm65(#9'lda #$01');
	 asm65(#9'sta (:bp2),y');
	 asm65(#9'iny');
	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'sta (:bp2),y');

	 a65(TCode65.subBX);
	 a65(TCode65.subBX);

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

	 if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

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

	   asm65(#9'jsr @move');

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

	   asm65(#9'jsr @move');

	  end;

	 a65(TCode65.subBX);
	 a65(TCode65.subBX);

	 end;
      end;
    end;


ASPOINTERTOARRAYRECORDTOSTRING:									// array_of_pointer_to_record[index].string
    begin

    Gen;

    asm65(#9'lda :STACKORIGIN-1,x');

    if TestName(IdentIndex, svar) then begin
     asm65(#9'add ' + ExtractName(IdentIndex, svar));
     asm65(#9'sta :bp2');
     asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
     asm65(#9'sta :bp2+1');
    end else begin
     asm65(#9'add '+svar);
     asm65(#9'sta :bp2');
     asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'adc '+svar+'+1');
     asm65(#9'sta :bp2+1');
    end;

    asm65(#9'ldy #$00');
    asm65(#9'lda (:bp2),y');

    if TestName(IdentIndex, svar) then
     asm65(#9'add #' + svar + '-DATAORIGIN')
    else
     asm65(#9'add #' + paramY);

    asm65(#9'sta @move.dst');

    asm65(#9'iny');
    asm65(#9'lda (:bp2),y');
    asm65(#9'adc #$00');
    asm65(#9'sta @move.dst+1');

    asm65(#9'lda :STACKORIGIN,x');
    asm65(#9'sta @move.src');
    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    asm65(#9'sta @move.src+1');

    asm65(#9'lda <' + IntToStr(Ident[IdentIndex].NumAllocElements));
    asm65(#9'sta @move.cnt');
    asm65(#9'lda >' + IntToStr(Ident[IdentIndex].NumAllocElements));
    asm65(#9'sta @move.cnt+1');

    asm65(#9'jsr @move');

    a65(TCode65.subBX);
    a65(TCode65.subBX);

    end;


ASPOINTERTORECORDARRAYORIGIN:						// record^.array[i]
  begin
    asm65('; as Pointer to Record^ Array Origin');
    asm65;

    Gen;

    if TestName(IdentIndex, svar) then
      asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2')
    else
      asm65(#9'mwy ' + svar + ' :bp2');

    asm65(#9'lda :STACKORIGIN-1,x');

    if TestName(IdentIndex, svar) then
     asm65(#9'add #' + svar + '-DATAORIGIN')
    else
     asm65(#9'add #' + ParamY);

    asm65(#9'sta :STACKORIGIN-1,x');

    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
    asm65(#9'adc #$00');
    asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

    asm65(#9'ldy :STACKORIGIN-1,x');

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

    a65(TCode65.subBX);
    a65(TCode65.subBX);

  end;


ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN:				// record_array[index].array[i]
    begin

    asm65(#9'dex');							// maksymalnie mozemy uzyc :STACKORIGIN-1 lub :STACKORIGIN+1, pomagamy przez DEX/INX

    if (NumAllocElements * 2 > 256) or (NumAllocElements in [0,1]) then begin

	if TestName(IdentIndex, svar) then begin
	   asm65(#9'lda ' + ExtractName(IdentIndex, svar));
	   asm65(#9'add :STACKORIGIN-1,x');
	   asm65(#9'sta :TMP');
	   asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
	   asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	   asm65(#9'sta :TMP+1');
	end else begin
	   asm65(#9'lda ' + svar);
	   asm65(#9'add :STACKORIGIN-1,x');
	   asm65(#9'sta :TMP');
	   asm65(#9'lda ' + svar + '+1');
	   asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	   asm65(#9'sta :TMP+1');
	end;

	asm65(#9'ldy #$00');
	asm65(#9'lda (:TMP),y');
	asm65(#9'sta :bp2');
	asm65(#9'iny');
	asm65(#9'lda (:TMP),y');
	asm65(#9'sta :bp2+1');

    end else begin
     asm65(#9'ldy :STACKORIGIN-1,x');
//   asm65(#9'lda adr.' + svar + ',y');
     asm65(#9'lda ' + svara + ',y');
     asm65(#9'sta :bp2');
//   asm65(#9'lda adr.' + svar + '+1,y');
     asm65(#9'lda ' + svara + '+1,y');
     asm65(#9'sta :bp2+1');
    end;

   asm65(#9'inx');

   asm65(#9'lda :STACKORIGIN-1,x');
   asm65(#9'add #' + ParamY);
   asm65(#9'sta :STACKORIGIN-1,x');
   asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
   asm65(#9'adc #$00');
   asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

   asm65(#9'ldy :STACKORIGIN-1,x');

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

     a65(TCode65.subBX);
     a65(TCode65.subBX);
     a65(TCode65.subBX);

    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer');

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('-'+svar);	// -sta

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,' / ',svar ,' / ', UnitName[Ident[IdentIndex].UnitIndex].Name,',',svar.LastIndexOf('.'));

    if TestName(IdentIndex, svar) then begin

     if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and not (Ident[IdentIndex].AllocElementType in [TDataType.UNTYPETOK, TDataType.PROCVARTOK]) then
      asm65(#9'mwy ' + svar + ' :bp2')
     else
      asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

    end else
     asm65(#9'mwy ' + svar + ' :bp2');

{
        if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) then begin


  writeln(Ident[Identindex].name,',',Ident[Identindex].AllocElementType,',',Ident[Identindex].NumAllocElements,',',Ident[Identindex].kind);


	   asm65(#9'ldy #$00') ;
	   asm65(#9'lda (:bp2),y') ;
	   asm65(#9'pha') ;
	   asm65(#9'iny') ;
	   asm65(#9'lda (:bp2),y') ;
	   asm65(#9'sta :bp2+1') ;
	   asm65(#9'pla') ;
	   asm65(#9'sta :bp2') ;
	end;
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

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (NumAllocElements = 0) then asm65('-');	// -sta

     a65(TCode65.subBX);

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

     a65(TCode65.subBX);

    end;

end;// case

StopOptimization;

end;	//GenerateAssignment


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateReturn(IsFunction, isInt, isInl, isOvr: Boolean);
var yes: Boolean;
begin
 Gen;						// ret

 yes:=true;

 if not isInt then				// not Interrupt
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

 if isOvr then begin
  asm65('.endl', '; overload');
 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIfThenCondition;
begin
//asm65;
//asm65('; If Then Condition');

Gen; Gen; Gen;								// mov :eax, [bx]

a65(TCode65.subBX);

asm65(#9'lda :STACKORIGIN+1,x');

a65(TCode65.jne);
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateElseCondition;
begin
//asm65;
//asm65('; else condition');

Gen; Gen; Gen;								// mov :eax, [bx]

a65(TCode65.je);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


{$IFDEF WHILEDO}

procedure GenerateWhileDoCondition;
begin

 GenerateIfThenCondition;

end;

{$ENDIF}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRepeatUntilCondition;
begin

 GenerateIfThenCondition;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelationOperation(rel: TTokenKind; ValType: TDataType);
begin

 case rel of
  TTokenKind.EQTOK:
    begin
    Gen; Gen;								// je +3   =

    asm65(#9'beq @+');
    end;

  TTokenKind.NETOK, TTokenKind.UNTYPETOK:
    begin
    Gen; Gen;								// jne +3  <>

    asm65(#9'bne @+');
    end;

  TTokenKind.GTTOK:
    begin
    Gen; Gen;								// jg +3   >

    asm65(#9'seq');

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+')
    else
     asm65(#9'bcs @+');

    end;

 TTokenKind.GETOK:
    begin
    Gen; Gen;								// jge +3  >=

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+')
    else
     asm65(#9'bcs @+');

    end;

  TTokenKind.LTTOK:
    begin
    Gen; Gen;								// jl +3   <

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bmi @+')
    else
     asm65(#9'bcc @+');

    end;

  TTokenKind.LETOK:
    begin
    Gen; Gen;								// jle +3  <=

    if ValType in (RealTypes + SignedOrdinalTypes) then begin
     asm65(#9'bmi @+');
     asm65(#9'beq @+');
    end else begin
     asm65(#9'bcc @+');
     asm65(#9'beq @+');
    end;

    end;

 end;	// case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateForToDoCondition(ValType: TDataType; Down: Boolean; IdentIndex: TIdentIndex);
var svar: string;
    CounterSize: Byte;
begin

svar    := GetLocalName(IdentIndex);
CounterSize := GetDataSize(ValType);

asm65(';'+InfoAboutSize(CounterSize));

Gen; Gen; Gen;						// mov :ecx, [bx]

a65(TCode65.subBX);

case CounterSize of

  1: begin
     ExpandByte;

     if ValType = TDataType.SHORTINTTOK then begin		// @cmpFor_SHORTINT

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

     if ValType = TDataType.SMALLINTTOK then begin		// @cmpFor_SMALLINT

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

     if ValType = TDataType.INTEGERTOK then begin			// @cmpFor_INT

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

  if ValType in [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK] then
   asm65(#9'bpl *+5')
  else
   asm65(#9'bcs *+5');

  end

else
  begin

  if ValType in [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK] then begin
   asm65(#9'bmi *+7');
   asm65(#9'beq *+5');
  end else begin
   asm65(#9'bcc *+7');
   asm65(#9'beq *+5');
  end;

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIfThenProlog;
begin

 Inc(CodePosStackTop);

 CodePosStack[CodePosStackTop] := CodeSize;

 Gen;								// nop   ; jump to the IF..THEN block end will be inserted here
 Gen;								// nop   ; !!!
 Gen;								// nop   ; !!!

 asm65(#9'jmp l_'+IntToHex(CodeSize, 4));

end;


procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: TDataType; Join: Boolean; CaseLocalCnt: integer);
begin
Gen; Gen;							// cmp :ecx, Value

case GetDataSize(SelectorType) of

 1: if join=false then begin
      asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

      if Value <> 0 then asm65(#9'cmp #$'+IntToHex(byte(Value),2));
    end else
      asm65(#9'cmp #$'+IntToHex(byte(Value),2));

// 2: asm65(#9'cpw :STACKORIGIN,x #$'+IntToHex(Value, 4));
// 4: asm65(#9'cpd :STACKORIGIN,x #$'+IntToHex(Value, 4));
end;

asm65(#9'beq @+');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: TDataType; Join: Boolean; CaseLocalCnt: integer);
begin

 Gen; Gen;							// cmp :ecx, Value1

 if (SelectorType in [TDataType.BYTETOK, TDataType.CHARTOK, ENUMTYPE]) and (Value1 >= 0) and (Value2 >= 0) then begin

   if (Value1 = 0) and (Value2 = 255) then begin

    asm65(#9'jmp @+');
   end else
   if Value1 = 0 then begin

    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

    if Value2 = 127 then begin
     asm65(#9'cmp #$00');
     asm65(#9'bpl @+')
    end else begin
     asm65(#9'cmp #$' + IntToHex(Value2 + 1,2));
     asm65(#9'bcc @+');
    end;

   end else
   if Value2 = 255 then begin

    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

    if Value1 = 128 then begin
     asm65(#9'cmp #$00');
     asm65(#9'bmi @+')
    end else begin
     asm65(#9'cmp #$' + IntToHex(Value1,2));
     asm65(#9'bcs @+');
    end;

   end else
   if Value1 = Value2 then begin

    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

    asm65(#9'cmp #$' + IntToHex(Value1,2));
    asm65(#9'beq @+');
   end else begin

    if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

    asm65(#9'clc', '; clear carry for add');
    asm65(#9'adc #$FF-$'+IntToHex(Value2,2), '; make m = $FF');
    asm65(#9'adc #$'+IntToHex(Value2,2)+'-$'+IntToHex(Value1,2)+'+1', '; carry set if in range n to m');
    asm65(#9'bcs @+');
   end;

 end else begin

  case GetDataSize(SelectorType) of
   1: begin
       if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

       asm65(#9'cmp #' + IntToStr(byte(Value1)));
      end;

  end;

  GenerateRelationOperation(TTokenKind.LTTOK, SelectorType);

  case GetDataSize(SelectorType) of
   1: begin
//       asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

       asm65(#9'cmp #' + IntToStr(byte(Value2)));
      end;

  end;

  GenerateRelationOperation(TTokenKind.GTTOK, SelectorType);

  asm65(#9'jmp *+6');
  asm65('@');

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseStatementProlog;
begin

 GenerateIfThenProlog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseStatementEpilog(cnt: integer);
var StoredCodeSize: Integer;
begin

 resetOpty;

 asm65(#9'jmp a_'+IntToHex(cnt,4));

 asm65('s_'+IntToHex(CodeSize, 4));				// opt_TEMP_TAIL_CASE


 StoredCodeSize := CodeSize;

 Gen;								// nop   ; jump to the CASE block end will be inserted here
// Gen;								// nop
// Gen;								// nop

 asm65('l_'+IntToHex(CodePosStack[CodePosStackTop] + 3, 4));

 Gen;

 CodePosStack[CodePosStackTop] := StoredCodeSize;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateCaseEpilog(NumCaseStatements: Integer; cnt: integer);
begin

 resetOpty;

//asm65;
//asm65('; GenerateCaseEpilog');

 Dec(CodePosStackTop, NumCaseStatements);

 if not OutputDisabled then Inc(CodeSize, NumCaseStatements);

 asm65('a_'+IntToHex(cnt, 4));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateAsmLabels(l: integer);
//var i: integer;
begin

if not OutputDisabled then
 if Pass = TPass.CODE_GENERATION then begin
{
   for i in AsmLabels do
     if i = l then exit;

   i := High(AsmLabels);

   AsmLabels[i] := l;

   SetLength(AsmLabels, i+2);
}
   asm65('l_' + IntToHex(l, 4));

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRepeatUntilProlog;
begin

 Inc(CodePosStackTop);
 CodePosStack[CodePosStackTop] := CodeSize;

 GenerateAsmLabels(CodeSize);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRepeatUntilEpilog;
var ReturnPos: Word;
begin

 ResetOpty;

 ReturnPos := CodePosStack[CodePosStackTop];
 Dec(CodePosStackTop);

 Gen;

 asm65(#9'jmp l_'+IntToHex(ReturnPos , 4));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateForToDoProlog;
begin

 GenerateWhileDoProlog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateForToDoEpilog (ValType: TDataType; Down: Boolean; IdentIndex: TIdentIndex = 0; Epilog: Boolean = true; forBPL: byte = 0);
var svar: string;
    CounterSize: Byte;
begin

svar    := GetLocalName(IdentIndex);
CounterSize := GetDataSize(ValType);

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

 if ValType in [TDataType.SHORTINTTOK, TDataType.SMALLINTTOK, TDataType.INTEGERTOK] then begin

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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompilerTitle: string;
begin

 Result := 'Mad Pascal Compiler version '+title+' ['+{$I %DATE%}+'] for MOS 6502 CPU';

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


{$i targets/generate_program_prolog.inc}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateProgramEpilog(ExitCode: byte);
begin

Gen; Gen;							// mov ah, 4Ch

asm65(#9'lda #$'+IntToHex(ExitCode, 2));
asm65(#9'jmp @halt');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateDeclarationProlog;
begin
Inc(CodePosStackTop);
CodePosStack[CodePosStackTop] := CodeSize;

Gen;								// nop   ; jump to the IF..THEN block end will be inserted here
Gen;								// nop   ; !!!
Gen;								// nop   ; !!!

asm65(#9'jmp l_'+IntToHex(CodeSize, 4));

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateDeclarationEpilog;
begin

 GenerateIfThenEpilog;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRead;//(Value: Int64);
begin
// Gen; Gen;							// mov bp, [bx]

 asm65(#9'@getline');

end;	// GenerateRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateWriteString(Address: Word; IndirectionLevel: byte; ValueType: TDataType = TDataType.INTEGERTOK);
begin
//Gen; Gen;							// mov ah, 09h

asm65;

case IndirectionLevel of

  ASBOOLEAN:
    begin
     asm65(#9'jsr @printBOOLEAN');

     a65(TCode65.subBX);
    end;

  ASCHAR:
    begin
     asm65(#9'@printCHAR');

     a65(TCode65.subBX);
    end;

  ASSHORTREAL:
    begin
     asm65(#9'jsr @printSHORTREAL');

     a65(TCode65.subBX);
    end;

  ASREAL:
    begin
     asm65(#9'jsr @printREAL');

     a65(TCode65.subBX);
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

      a65(TCode65.subBX);

      asm65(#9'jsr @FTOA');
    end;

  ASHALFSINGLE:
    begin
//     asm65(#9'jsr @f16toa');

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @F16_F2A.I');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @F16_F2A.I+1');

      a65(TCode65.subBX);

      asm65(#9'jsr @F16_F2A');
    end;


  ASVALUE:
    begin

     case GetDataSize(ValueType) of
      1: if ValueType = TDataType.SHORTINTTOK then
	  asm65(#9'jsr @printSHORTINT')
	 else
	  asm65(#9'jsr @printBYTE');

      2:  if ValueType = TDataType.SMALLINTTOK then
	   asm65(#9'jsr @printSMALLINT')
	  else
	   asm65(#9'jsr @printWORD');

      4: if ValueType = TDataType.INTEGERTOK then
	  asm65(#9'jsr @printINT')
	 else
	  asm65(#9'jsr @printCARD');
     end;

     a65(TCode65.subBX);
    end;

  ASPOINTER:
    begin

     asm65(#9'@printSTRING #CODEORIGIN+$'+IntToHex(Address - CODEORIGIN, 4));

//    a65(TCode65.subBX);   !!!   bez DEX-a
    end;

  ASPOINTERTOPOINTER:
    begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'jsr @printSTRING');

     a65(TCode65.subBX);
    end;


  ASPCHAR:
    begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'jsr @printPCHAR');

     a65(TCode65.subBX);
    end;


  end;

end;	//GenerateWriteString


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateUnaryOperation(op: TTokenKind; ValType: TDataType = TDataType.UNTYPETOK);
begin

case op of

  TTokenKind.PLUSTOK:
    begin
    end;

  TTokenKind.MINUSTOK:
    begin
    Gen; Gen; Gen;						// neg dword ptr [bx]

    if ValType = TDataType.HALFSINGLETOK then begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'eor #$80');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

    end else
    if ValType = TDataType.SINGLETOK then begin

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

    case GetDataSize(ValType) of
     1: begin //asm65(#9'jsr negBYTE');

         asm65(#9'lda #$00');
         asm65(#9'sub :STACKORIGIN,x');
         asm65(#9'sta :STACKORIGIN,x');

         asm65(#9'lda #$00');
         asm65(#9'sbc #$00');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc #$00');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc #$00');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

        end;

     2: begin //asm65(#9'jsr negWORD');

         asm65(#9'lda #$00');
         asm65(#9'sub :STACKORIGIN,x');
         asm65(#9'sta :STACKORIGIN,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

         asm65(#9'lda #$00');
         asm65(#9'sbc #$00');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc #$00');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

        end;

     4: begin //asm65(#9'jsr negCARD');

         asm65(#9'lda #$00');
         asm65(#9'sub :STACKORIGIN,x');
         asm65(#9'sta :STACKORIGIN,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc :STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'lda #$00');
         asm65(#9'sbc :STACKORIGIN+STACKWIDTH*3,x');
         asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

        end;

    end;

    end;

  TTokenKind.NOTTOK:
    begin
    Gen; Gen; Gen;						// not dword ptr [bx]

    if ValType = TDataType.BOOLEANTOK then begin
//     a65(TCode65.notBOOLEAN)

       asm65(#9'ldy #1');					// !!! wymagana konwencja
       asm65(#9'lda :STACKORIGIN,x');
       asm65(#9'beq @+');
       asm65(#9'dey');
       asm65('@');
//       asm65(#9'tya');		!!! ~
       asm65(#9'sty :STACKORIGIN,x');

    end else begin

     ExpandParam(TDataType.INTEGERTOK, ValType);

//     a65(TCode65.notaBX);

       asm65(#9'lda :STACKORIGIN,x');
       asm65(#9'eor #$FF');
       asm65(#9'sta :STACKORIGIN,x');
       asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
       asm65(#9'eor #$FF');
       asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
       asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
       asm65(#9'eor #$FF');
       asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
       asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
       asm65(#9'eor #$FF');
       asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

    end;

    end;

end;// case

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateBinaryOperation(op: TTokenKind; ResultType: TDataType);
begin

asm65;
asm65('; Generate Binary Operation for '+InfoAboutToken(ResultType));

Gen; Gen; Gen;							// mov :ecx, [bx]      :STACKORIGIN,x

case op of

  TTokenKind.PLUSTOK:
    begin

     if ResultType = TDataType.HALFSINGLETOK then begin

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
     if ResultType = TDataType.SINGLETOK then begin
//       asm65(#9'jsr @FADD')

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta :FP2MAN0');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :FP2MAN1');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :FP2MAN2');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :FP2MAN3');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta :FP1MAN0');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta :FP1MAN1');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'sta :FP1MAN2');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
	asm65(#9'sta :FP1MAN3');

	asm65(#9'jsr @FADD');

	asm65(#9'lda :FPMAN0');
	asm65(#9'sta :STACKORIGIN-1,x');
	asm65(#9'lda :FPMAN1');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'lda :FPMAN2');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'lda :FPMAN3');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

     end else

     case GetDataSize(ResultType) of
       1: a65(TCode65.addAL_CL);
       2: a65(TCode65.addAX_CX);
       4: a65(TCode65.addEAX_ECX);
     end;

    end;

  TTokenKind.MINUSTOK:
    begin

    if ResultType = TDataType.HALFSINGLETOK then begin

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
    if ResultType = TDataType.SINGLETOK then begin
//      asm65(#9'jsr @FSUB')

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta :FP2MAN0');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :FP2MAN1');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :FP2MAN2');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :FP2MAN3');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta :FP1MAN0');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta :FP1MAN1');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'sta :FP1MAN2');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
	asm65(#9'sta :FP1MAN3');

	asm65(#9'jsr @FSUB');

	asm65(#9'lda :FPMAN0');
	asm65(#9'sta :STACKORIGIN-1,x');
	asm65(#9'lda :FPMAN1');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'lda :FPMAN2');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'lda :FPMAN3');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

    end else

    case GetDataSize(ResultType) of
     1: a65(TCode65.subAL_CL);
     2: a65(TCode65.subAX_CX);
     4: a65(TCode65.subEAX_ECX);
    end;

    end;

    TTokenKind.MULTOK:
    begin

    if ResultType in RealTypes then begin		// Real multiplication

      case ResultType of

       TDataType.SHORTREALTOK:				// Q8.8 fixed-point
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

	    TDataType.REALTOK:				// Q24.8 fixed-point
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

	  TDataType.SINGLETOK: //asm65(#9'jsr @FMUL');	     // IEEE-754, 32-bit
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta :FP2MAN0');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta :FP2MAN1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta :FP2MAN2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta :FP2MAN3');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta :FP1MAN0');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta :FP1MAN1');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'sta :FP1MAN2');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
		asm65(#9'sta :FP1MAN3');

		asm65(#9'jsr @FMUL');

		asm65(#9'lda :FPMAN0');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :FPMAN1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'lda :FPMAN2');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'lda :FPMAN3');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end;

      TDataType.HALFSINGLETOK:					// IEEE-754, 16-bit
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
	TDataType.SHORTINTTOK: asm65(#9'jsr mulSHORTINT');
	TDataType.SMALLINTTOK: asm65(#9'jsr mulSMALLINT');
	TDataType.INTEGERTOK: asm65(#9'jsr mulINTEGER');
       end;

      end else begin

       case GetDataSize(ResultType) of
        1: asm65(#9'jsr imulBYTE');
        2: asm65(#9'jsr imulWORD');
        4: asm65(#9'jsr imulCARD');
       end;

//       asm65(#9'jsr movaBX_EAX');

       if GetDataSize(ResultType) = 1 then begin

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

  TTokenKind.DIVTOK, TTokenKind.IDIVTOK, TTokenKind.MODTOK:
    begin

    if ResultType in RealTypes then begin		// Real division

      case ResultType of
       TDataType.SHORTREALTOK:					// Q8.8 fixed-point
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

	    TDataType.REALTOK:					// Q24.8 fixed-point
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

	  TDataType.SINGLETOK:					// IEEE-754, 32-bit
		begin

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta :FP2MAN0');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta :FP2MAN1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta :FP2MAN2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta :FP2MAN3');

		asm65(#9'lda :STACKORIGIN-1,x');
		asm65(#9'sta :FP1MAN0');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'sta :FP1MAN1');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'sta :FP1MAN2');
		asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
		asm65(#9'sta :FP1MAN3');

		asm65(#9'jsr @FDIV');

		asm65(#9'lda :FPMAN0');
		asm65(#9'sta :STACKORIGIN-1,x');
		asm65(#9'lda :FPMAN1');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
		asm65(#9'lda :FPMAN2');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
		asm65(#9'lda :FPMAN3');
		asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

		end;

      TDataType.HALFSINGLETOK:					// IEEE-754, 16-bit
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

    else						// Integer division
      begin

      if ResultType in SignedOrdinalTypes then begin

	case ResultType of

	 TDataType.SHORTINTTOK:
	 	if op = TTokenKind.MODTOK then begin
//		        asm65(#9'jsr TTokenKind.SHORTINTTOK.MOD')

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


	 TDataType.SMALLINTTOK:
		if op = TTokenKind.MODTOK then begin
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

	  TDataType.INTEGERTOK:
		if op = TTokenKind.MODTOK then begin
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

	TDataType.BYTETOK:
		if op = TTokenKind.MODTOK then begin
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

	TDataType.WORDTOK:
		if op = TTokenKind.MODTOK then begin
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

	TDataType.CARDINALTOK:
		if op = TTokenKind.MODTOK then begin
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


  TTokenKind.SHLTOK:
    begin

    if ResultType in SignedOrdinalTypes then begin

     case GetDataSize(ResultType) of

      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); a65(TCode65.shlEAX_CL) end;

      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); a65(TCode65.shlEAX_CL) end;

      4: a65(TCode65.shlEAX_CL);

     end;

    end else
     case GetDataSize(ResultType) of
      1: a65(TCode65.shlAL_CL);
      2: a65(TCode65.shlAX_CL);
      4: a65(TCode65.shlEAX_CL);
     end;

    end;


  TTokenKind.SHRTOK:
    begin

    if ResultType in SignedOrdinalTypes then begin

     case GetDataSize(ResultType) of

      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); a65(TCode65.shrEAX_CL) end;

      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); a65(TCode65.shrEAX_CL) end;

      4: a65(TCode65.shrEAX_CL);

     end;

    end else
     case GetDataSize(ResultType) of
      1: a65(TCode65.shrAL_CL);
      2: a65(TCode65.shrAX_CL);
      4: a65(TCode65.shrEAX_CL);
     end;

    end;


  TTokenKind.ANDTOK:
    begin

    case GetDataSize(ResultType) of
      1: //a65(TCode65.andAL_CL);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'and :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');
      end;

      2: //a65(TCode65.andAX_CX);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'and :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'and :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
      end;

      4: //a65(TCode65.andEAX_ECX)
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'and :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'and :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'and :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
	asm65(#9'and :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
      end;

    end;

    end;


  TTokenKind.ORTOK:
    begin

    case GetDataSize(ResultType) of
      1: //a65(TCode65.orAL_CL);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'ora :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');
      end;

      2: //a65(TCode65.orAX_CX);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'ora :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'ora :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
      end;

      4: //a65(TCode65.orEAX_ECX)
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'ora :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'ora :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'ora :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
	asm65(#9'ora :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
      end;

    end;

    end;


  TTokenKind.XORTOK:
    begin

    case GetDataSize(ResultType) of
      1: //a65(TCode65.xorAL_CL);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'eor :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');
      end;

      2: //a65(TCode65.xorAX_CX);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'eor :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'eor :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
      end;

      4: //a65(TCode65.xorEAX_ECX)
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'eor :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'eor :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
	asm65(#9'eor :STACKORIGIN+STACKWIDTH*2,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
	asm65(#9'eor :STACKORIGIN+STACKWIDTH*3,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
      end;

    end;

    end;

end;// case

a65(TCode65.subBX);

end;	//GenerateBinaryOperation


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelationString(rel: TTokenKind; LeftValType, RightValType: TDataType);
begin
 asm65;
 asm65('; relation STRING');

 Gen;

 asm65(#9'ldy #1');

 Gen;

 if (LeftValType = TDataType.STRINGPOINTERTOK) and (RightValType = TDataType.STRINGPOINTERTOK) then begin
//  a65(TCode65.cmpSTRING)					// STRING ? STRING

 	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @cmpSTRING.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @cmpSTRING.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.A+1');

	asm65(#9'jsr @cmpSTRING');

 end else
 if LeftValType = TDataType.CHARTOK then
  a65(TCode65.cmpCHAR2STRING)					// CHAR ? STRING
 else
 if RightValType = TDataType.CHARTOK then
  a65(TCode65.cmpSTRING2CHAR);				// STRING ? CHAR

 GenerateRelationOperation(rel, TTokenKind.BYTETOK);

 Gen;

 asm65(#9'dey');
 asm65('@');
// asm65(#9'tya');			!!! ~
 asm65(#9'sty :STACKORIGIN-1,x');

 a65(TCode65.subBX);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelation(rel: TTokenKind; ValType: TDataType);
begin
// asm65;
// asm65('; relation');

 Gen;

 if ValType = TDataType.HALFSINGLETOK then begin

 case rel of
  TTokenKind.EQTOK:	// =
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

  TTokenKind.NETOK, TTokenKind.UNTYPETOK:	// <>
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

  TTokenKind.GTTOK:	// >
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

  TTokenKind.LTTOK:	// <
    begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_GT.B');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_GT.B+1');

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_GT.A');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_GT.A+1');

	asm65(#9'jsr @F16_GT');

	asm65(#9'dex');
    end;

  TTokenKind.GETOK:	// >=
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

  TTokenKind.LETOK:	// <=
    begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @F16_GTE.B');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @F16_GTE.B+1');

	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @F16_GTE.A');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @F16_GTE.A+1');

	asm65(#9'jsr @F16_GTE');

	asm65(#9'dex');
    end;

  end;

  asm65(#9'sta :STACKORIGIN,x');

 end else begin

 	if ValType = TDataType.SINGLETOK then begin

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

 asm65(#9'ldy #1');

 Gen;

 case ValType of
     TTokenKind.BYTETOK, TTokenKind.CHARTOK, TTokenKind.BOOLEANTOK:
	begin
	 asm65(#9'lda :STACKORIGIN-1,x');
	 asm65(#9'cmp :STACKORIGIN,x');
	end;

     TTokenKind.SHORTINTTOK:
	begin	//a65(TCode65.cmpSHORTINT);

         asm65(#9'.LOCAL');
         asm65(#9'lda :STACKORIGIN-1,x');
         asm65(#9'sub :STACKORIGIN,x');
         asm65(#9'beq L5');
         asm65(#9'bvc L5');
         asm65(#9'eor #$FF');
         asm65(#9'ora #$01');
         asm65('L5');
         asm65(#9'.ENDL');

	end;

     TTokenKind.SMALLINTTOK, TTokenKind.SHORTREALTOK:
	begin	//a65(TCode65.cmpSMALLINT);

         asm65(#9'.LOCAL');
         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'sub :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'bne L4');
         asm65(#9'lda :STACKORIGIN-1,x');
         asm65(#9'cmp :STACKORIGIN,x');
         asm65(#9'beq L5');
         asm65(#9'lda #$00');
         asm65(#9'adc #$FF');
         asm65(#9'ora #$01');
         asm65(#9'bne L5');
         asm65('L4'#9'bvc L5');
         asm65(#9'eor #$FF');
         asm65(#9'ora #$01');
         asm65('L5');
         asm65(#9'.ENDL');

	end;

     TTokenKind.SINGLETOK: asm65(#9'jsr @FCMPL');

     TTokenKind.REALTOK, TTokenKind.INTEGERTOK:
	begin	//a65(TCode65.cmpINT);

         asm65(#9'.LOCAL');
         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
         asm65(#9'sub :STACKORIGIN+STACKWIDTH*3,x');
         asm65(#9'bne L4');
         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'bne L1');
         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'bne L1');
         asm65(#9'lda :STACKORIGIN-1,x');
         asm65(#9'cmp :STACKORIGIN,x');
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

	end;

     TTokenKind.WORDTOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK:
     	begin	//a65(TCode65.cmpAX_CX);

         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'bne @+');
         asm65(#9'lda :STACKORIGIN-1,x');
         asm65(#9'cmp :STACKORIGIN,x');
         asm65('@');

	end;

 else
	begin	//a65(TCode65.cmpEAX_ECX);					// TTokenKind.CARDINALTOK

         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH*3,x');
         asm65(#9'bne @+');
         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH*2,x');
         asm65(#9'bne @+');
         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'bne @+');
         asm65(#9'lda :STACKORIGIN-1,x');
         asm65(#9'cmp :STACKORIGIN,x');
         asm65('@');

	end;

 end;

 GenerateRelationOperation(rel, ValType);

 Gen;

 asm65(#9'dey');
 asm65('@');
 //asm65(#9'tya');			!!! ~
 asm65(#9'sty :STACKORIGIN-1,x');

 a65(TCode65.subBX);

 end; // if ValType = TDataType.HALFSINGLETOK

end;	//GenerateRelation


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// The following functions implement recursive descent parser in accordance with Sub-Pascal EBNF
// Parameter i is the index of the first token of the current EBNF symbol, result is the index of the last one

function CompileExpression(i: Integer; out ValType: TTokenKind; VarType: TTokenKind = TTokenKind.INTEGERTOK): Integer; forward;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

{
procedure InfoAboutArray(IdentIndex: Integer; c: Boolean = false);
var t: string;
begin

  if c then
   t := ' Const'
  else
   t := '';

  asm65;

  if Ident[IdentIndex].NumAllocElements_ > 0 then
   asm65(';' + t + ' Array index '+Ident[IdentIndex].Name+'[0..'+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+', 0..'+IntToStr(Ident[IdentIndex].NumAllocElements_ - 1)+']')
  else
   asm65(';' + t + ' Array index '+Ident[IdentIndex].Name+'[0..'+IntToStr(Ident[IdentIndex].NumAllocElements - 1)+']');

end;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function SafeCompileConstExpression(var i: Integer; out ConstVal: Int64; out ValType: TTokenKind; VarType: TTokenKind; Err: Boolean = false; War: Boolean = true): Boolean;
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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileArrayIndex(i: integer; IdentIndex: integer): integer;
var ConstVal: Int64;
    ActualParamType, ArrayIndexType: TTokenKind;
    Size: Byte;
    NumAllocElements, NumAllocElements_: cardinal;
    j: integer;
    yes, ShortArrayIndex: Boolean;
begin

	      if common.optimize.use = false then StartOptimization(i);


	      if (Ident[IdentIndex].isStriped) then
	        Size := 1
	      else
   	        Size := GetDataSize(Ident[IdentIndex].AllocElementType);


	      ShortArrayIndex := false;


	      if ((Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].IdType = TDataType.DEREFERENCEARRAYTOK)) then begin
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


	      if Ident[IdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK, TTokenKind.PROCVARTOK] then NumAllocElements_ := 0;


	      ActualParamType := TTokenKind.WORDTOK;		// !!! aby dzialaly optymalizacje dla ADR.


	      j := i + 2;

	      if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
		  i := j;

		  CheckArrayIndex(i, IdentIndex, ConstVal, ArrayIndexType);

		  ArrayIndexType := TTokenKind.WORDTOK;
		  ShortArrayIndex := false;

	      	  if NumAllocElements_ > 0 then
		   Push(ConstVal * NumAllocElements_ * Size, ASVALUE, GetDataSize(ArrayIndexType))
		  else
		   Push(ConstVal * Size, ASVALUE, GetDataSize(ArrayIndexType));

	      end else begin
		 i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	// array index [x, ..]

		 GetCommonType(i, ActualParamType, ArrayIndexType);

		 case ArrayIndexType of
		  TTokenKind.SHORTINTTOK: ArrayIndexType := TTokenKind.BYTETOK;
		  TTokenKind.SMALLINTTOK: ArrayIndexType := TTokenKind.WORDTOK;
		   TTokenKind.INTEGERTOK: ArrayIndexType := TTokenKind.CARDINALTOK;
		 end;

		 if GetDataSize(ArrayIndexType) = 4 then begin	// remove oldest bytes
	  	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
	  	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		 end;

		 if GetDataSize(ArrayIndexType) = 1 then begin
		  ExpandParam(TTokenKind.WORDTOK, ArrayIndexType);
//		  ArrayIndexType := TTokenKind.WORDTOK;
		 end else
		  ArrayIndexType := TTokenKind.WORDTOK;

		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
//		    ExpandParam(TTokenKind.WORDTOK, ArrayIndexType);
		    ArrayIndexType := TTokenKind.WORDTOK;
		  end;


		 if NumAllocElements_ > 0 then begin

		   Push(integer(NumAllocElements_ * Size), ASVALUE, GetDataSize(ArrayIndexType));

		   GenerateBinaryOperation(TTokenKind.MULTOK, ArrayIndexType);

		 end else
		   if Ident[IdentIndex].isStriped = FALSE then GenerateIndexShift( Ident[IdentIndex].AllocElementType );

	      end;


	    yes:=false;

	    if NumAllocElements_ > 0 then begin

	     if Tok[i + 1].Kind = TTokenKind.CBRACKETTOK then begin
	      inc(i);
	      CheckTok(i + 1, TTokenKind.OBRACKETTOK);
	      yes:=true;
	     end else begin
	      CheckTok(i + 1, TTokenKind.COMMATOK);
	      yes:=true;
	     end;

	    end else
	     CheckTok(i + 1, TTokenKind.CBRACKETTOK);


	    if {Tok[i + 1].Kind = TTokenKind.COMMATOK} yes then begin

	    	j := i + 2;

		if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then begin
		  i := j;

		  CheckArrayIndex_(i, IdentIndex, ConstVal, ArrayIndexType);

		  ArrayIndexType := TTokenKind.WORDTOK;
		  ShortArrayIndex := false;

		  Push(ConstVal * Size, ASVALUE, GetDataSize(ArrayIndexType));

		end else begin
		  i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	// array index [.., y]

		  GetCommonType(i, ActualParamType, ArrayIndexType);

		  case ArrayIndexType of
		    TTokenKind.SHORTINTTOK: ArrayIndexType := TTokenKind.BYTETOK;
		    TTokenKind.SMALLINTTOK: ArrayIndexType := TTokenKind.WORDTOK;
		    TTokenKind.INTEGERTOK:  ArrayIndexType := TTokenKind.CARDINALTOK;
		  end;

		  if GetDataSize(ArrayIndexType) = 4 then begin	// remove oldest bytes
	  	   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
	  	   asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		  end;

		  if GetDataSize(ArrayIndexType) = 1 then begin
		   ExpandParam(TTokenKind.WORDTOK, ArrayIndexType);
		   ArrayIndexType := TTokenKind.WORDTOK;
		  end else
		   ArrayIndexType := TTokenKind.WORDTOK;

//		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
//		    ExpandParam(WORDTOK, ArrayIndexType);
//		    ArrayIndexType := TTokenKind.WORDTOK;
//		  end;

		  if Ident[IdentIndex].isStriped = FALSE then GenerateIndexShift( Ident[IdentIndex].AllocElementType );

		end;

		GenerateBinaryOperation(TTokenKind.PLUSTOK, TTokenKind.WORDTOK);

	    end;


	if ShortArrayIndex then begin

	  asm65(#9'lda #$00');
	  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end;

//	writeln(Ident[IdentIndex].Name,',',Elements(IdentIndex));

 Result := i;

end;	//CompileArrayIndex


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileAddress(i: integer; out ValType, AllocElementType: TDataType; VarPass: Boolean = false): integer;
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

    AllocElementType := TTokenKind.UNTYPETOK;


    if Tok[i + 1].Kind = TTokenKind.ADDRESSTOK then begin

     if VarPass then
        Error(i + 1, TMessage.Create(TErrorCode.CantAsignValuesToAnAddress, 'Can''t assign values to an address'));

     address := true;

     inc(i);
    end;


    if (Tok[i + 1].Kind = TTokenKind.PCHARTOK) and (Tok[i + 2].Kind = TTokenKind.OPARTOK) then begin

      j := CompileExpression(i + 3, ValType, TTokenKind.POINTERTOK);

      CheckTok(j + 1, TTokenKind.CPARTOK);

      if Tok[j + 2].Kind <> TTokenKind.DEREFERENCETOK then
        Error(i + 3, TMessage.Create(TErrorCode.CantAsignValuesToAnAddress, 'Can''t assign values to an address'));

      i := j + 1;

    end else

    if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
      Error(i + 1, TErrorCode.IdentifierExpected)
    else
      begin
      IdentIndex := GetIdentIndex(Tok[i + 1].Name);


      if IdentIndex > 0 then
	begin

	if not(Ident[IdentIndex].Kind in [CONSTANT, VARIABLE, TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK, TTokenKind.ADDRESSTOK]) then
	 Error(i + 1, TErrorCode.VariableExpected)
	else begin

 	  if Ident[IdentIndex].Kind = CONSTANT then
	   if not ( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
	     Error(i + 1, TErrorCode.CantAdrConstantExp);


//	writeln(Ident[IdentIndex].nAME,' = ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod );


	  if Ident[IdentIndex].Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then begin

	    Name := GetLocalName(IdentIndex);

	    if Ident[IdentIndex].isOverload then Name := Name + '.' + GetOverloadName(IdentIndex);

	    a65(TCode65.addBX);
	    asm65(#9'mva <'+Name+' :STACKORIGIN,x');
	    asm65(#9'mva >'+Name+' :STACKORIGIN+STACKWIDTH,x');

	    if Pass = TPass.CALL_DETERMINATION then
	      AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);

	  end else

	  if (Tok[i + 2].Kind = TTokenKind.OBRACKETTOK) and
	     (Ident[IdentIndex].DataType in Pointers) and
	     ((Ident[IdentIndex].NumAllocElements > 0) or ((Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType <> TTokenKind.UNTYPETOK))) then
	  begin									// array index
	      inc(i);

 // atari	  // a := @tab[x,y]

	      i := CompileArrayIndex(i, IdentIndex);


	if Ident[IdentIndex].DataType = ENUMTYPE then begin
//   Size := GetDataSize( TDataType.Ident[IdentIndex].AllocElementType];
	 NumAllocElements := 0;
	end else
	 NumAllocElements := Elements(IdentIndex); //Ident[IdentIndex].NumAllocElements;

	svar := GetLocalName(IdentIndex);

  	if (pos('.', svar) > 0) then begin
//	 lab:=copy(svar,1,pos('.', svar)-1);
	 lab := ExtractName(IdentIndex, svar);

	 rec := (Ident[GetIdentIndex(lab)].AllocElementType = TDataType.RECORDTOK);
	end;

	AllocElementType := Ident[IdentIndex].AllocElementType;

//	writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',VarPass );

	if rec then begin							// record.array[]

	 asm65(#9'lda ' + lab);
	 asm65(#9'add :STACKORIGIN,x');
	 asm65(#9'sta :STACKORIGIN,x');
	 asm65(#9'lda ' + lab + '+1');
	 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	 asm65(#9'lda :STACKORIGIN,x');
	 asm65(#9'add #' + svar + '-DATAORIGIN');
	 asm65(#9'sta :STACKORIGIN,x');
	 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	 asm65(#9'adc #$00');
	 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end else

	if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) or (NumAllocElements * GetDataSize(AllocElementType) > 256) or (NumAllocElements in [0,1]) then begin

//	writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',Ident[IdentIndex].idType );

 	  asm65(#9'lda ' + svar);
 	  asm65(#9'add :STACKORIGIN,x');
	  asm65(#9'sta :STACKORIGIN,x');
	  asm65(#9'lda ' + svar + '+1');
	  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end else begin

//	writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',Ident[IdentIndex].idType );

	  asm65(#9'lda <' + GetLocalName(IdentIndex, 'adr.'));
	  asm65(#9'add :STACKORIGIN,x');
	  asm65(#9'sta :STACKORIGIN,x');
	  asm65(#9'lda >' + GetLocalName(IdentIndex, 'adr.'));
	  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	end;

	     CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	     end else
	      if (Ident[IdentIndex].DataType in [TTokenKind.FILETOK, TTokenKind.TEXTFILETOK, TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] {+ Pointers}) or
	         ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> TTokenKind.UNTYPETOK) and (Ident[IdentIndex].NumAllocElements > 0)) or
		 (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) or
		 (VarPass and (Ident[IdentIndex].DataType in Pointers))  then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',Tok[i + 2].Kind);

		 DEREFERENCE := (Tok[i + 2].Kind = TTokenKind.DEREFERENCETOK);


		 if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
		    (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = TDataType.DATAORIGINOFFSET) then begin

		   Push(Ident[IdentIndex].Value, ASPOINTERTORECORD, GetDataSize(TTokenKind.POINTERTOK), IdentIndex)
		 end else
		  if DEREFERENCE then begin


		 svar := GetLocalName(IdentIndex);

//  		 if (pos('.', svar) > 0) then begin
//		   lab:=copy(svar,1,pos('.', svar)-1);
//		   rec:=(Ident[GetIdentIndex(lab)].AllocElementType = TDataType.RECORDTOK);
//		 end;

		 if (Ident[IdentIndex].DataType in Pointers) {and (Tok[i + 2].Kind = TTokenKind.DEREFERENCETOK)} then
		  if (Ident[IdentIndex].AllocElementType = TDataType.RECORDTOK) and (Tok[i + 3].Kind = TTokenKind.DOTTOK) then begin		// var record^.field

//		    DEREFERENCE := true;

		    CheckTok(i + 4, TTokenKind.IDENTTOK);
	      	    IdentTemp := RecordSize(IdentIndex, Tok[i + 4].Name);

 	            if IdentTemp < 0 then
	              Error(i + 4, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,'Identifier idents no member ''{0}''.', Tok[i + 4].Name ));

	            AllocElementType := TTokenKind(IdentTemp shr 16);

		    IdentTemp:=GetIdentIndex(svar + '.' + string(Tok[i + 4].Name) );

		    if IdentTemp = 0 then
		     Error(i + 4, TErrorCode.UnknownIdentifier);

		    Push(Ident[IdentTemp].Value, ASPOINTER, GetDataSize(TTokenKind.POINTERTOK), IdentTemp);

		    inc(i, 3);

		  end else begin											// type^
		    AllocElementType :=  Ident[IdentIndex].AllocElementType;

//	writeln('^',',', Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' / ',Ident[IdentIndex].NumAllocElements_,' = ',Ident[IdentIndex].idType,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

		    if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		      if Ident[IdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then begin

			if Ident[IdentIndex].NumAllocElements_ = 0 then

			else
			  Error(i + 4, TErrorCode.IllegalQualifier);	// array of ^record

		      end else
		        Error(i + 4, TErrorCode.IllegalQualifier);	// array

		    end;

		    Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(TTokenKind.POINTERTOK), IdentIndex);

		    inc(i);
		  end;


//	writeln('5: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE,',',VarPass);


		  end else
		   if address or VarPass then begin
//		   if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) {and (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING)} then begin

//	writeln('1: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,'..',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE,',',varpass,' o ',Ident[IdentIndex].isAbsolute);

                     if (Ident[IdentIndex].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK, TTokenKind.FILETOK, TTokenKind.TEXTFILETOK]) or
		        (VarPass and (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType in AllTypes - [TTokenKind.PROCVARTOK, TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) and (Ident[IdentIndex].NumAllocElements = 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) and (VarPass or (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING)) ) or
		        (Ident[IdentIndex].isAbsolute and (Ident[IdentIndex].Value and $ff = 0) and (byte((Ident[IdentIndex].Value shr 24) and $7f) in [1..127])) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) and (Ident[IdentIndex].NumAllocElements_ = 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].idType = TDataType.DATAORIGINOFFSET)) or
		        ((Ident[IdentIndex].DataType in Pointers) and not (Ident[IdentIndex].AllocElementType in [TTokenKind.UNTYPETOK, TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK, TTokenKind.PROCVARTOK]) and (Ident[IdentIndex].NumAllocElements > 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) )
		     then
		       Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(TTokenKind.POINTERTOK), IdentIndex)
		     else
		       Push(Ident[IdentIndex].Value, ASVALUE, GetDataSize(TTokenKind.POINTERTOK), IdentIndex);

		     AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   end else begin

//	writeln('2: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

		     Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(TTokenKind.POINTERTOK), IdentIndex);

		     AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   end;

	      end else begin

		 if (Ident[IdentIndex].DataType in Pointers) and (Tok[i + 2].Kind = TTokenKind.DEREFERENCETOK) then begin
		   AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   inc(i);

		   Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(TTokenKind.POINTERTOK), IdentIndex);
		 end else
//		  if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> 0) and (Ident[IdentIndex].NumAllocElements = 0) then begin
//	writeln('3: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);
//		   Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);
//		  end else
		  begin

//	writeln('4: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

  		    Push(Ident[IdentIndex].Value, ASVALUE, GetDataSize(TTokenKind.POINTERTOK), IdentIndex);

		  end;

	 end;

	  ValType := TTokenKind.POINTERTOK;

	  Result := i + 1;
	  end;

	end
      else
	Error(i + 1, TErrorCode.UnknownIdentifier);
      end;

end;	//CompileAddress


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function NumActualParameters(i: integer; IdentIndex: integer; out NumActualParams: integer): TParamList;
(*----------------------------------------------------------------------------*)
(* moze istniec wiele funkcji/procedur o tej samej nazwie ale roznej liczbie  *)
(* parametrow								      *)
(*----------------------------------------------------------------------------*)
var ActualParamType, AllocElementType: TTokenKind;
    NumAllocElements: cardinal;
    oldPass: TPass; oldCodeSize, IdentTemp: integer;
begin

   oldPass := pass;
   oldCodeSize := CodeSize;
   Pass := TPass.CALL_DETERMINATION;

   NumActualParams := 0;
   ActualParamType := TTokenKind.UNTYPETOK;

   Result[1].i_ := i + 1;

   if (Tok[i + 1].Kind = TTokenKind.OPARTOK) and (Tok[i + 2].Kind <> TTokenKind.CPARTOK) then		    // Actual parameter list found
     begin
     repeat

       Inc(NumActualParams);

       if NumActualParams > MAXPARAMS then
	 ErrorForIdentifier(i, TErrorCode.TooManyParameters, IdentIndex);

       Result[NumActualParams].i := i;

{
       if (Ident[IdentIndex].Param[NumActualParams].PassMethod = TParameterPassingMethod.VARPASSING) then begin		// !!! to nie uwzglednia innych procedur/funkcji o innej liczbie parametrow

	CompileExpression(i + 2, ActualParamType);

	Result[NumActualParams].AllocElementType := ActualParamType;

	i := CompileAddress(i + 1, ActualParamType, AllocElementType);

       end else}

	 i := CompileExpression(i + 2, ActualParamType{, Ident[IdentIndex].Param[NumActualParams].DataType});	// Evaluate actual parameters and push them onto the stack

         AllocElementType := TTokenKind.UNTYPETOK;
	 NumAllocElements := 0;

	if (ActualParamType in [TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK]) and (Tok[i].Kind = TTokenKind.IDENTTOK) then begin

	  IdentTemp := GetIdentIndex(Tok[i].Name);

	  if (Tok[i - 1].Kind = TTokenKind.ADDRESSTOK) and (not (Ident[IdentTemp].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK])) then

	  else begin
	   AllocElementType := Ident[IdentTemp].AllocElementType;
	   NumAllocElements := Ident[IdentTemp].NumAllocElements;
	  end;


	  if Ident[IdentTemp].Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK] then begin

           Result[NumActualParams].Name := Ident[IdentTemp].Name;

	   AllocElementType := Ident[IdentTemp].Kind;

	  end;

//	writeln(Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements,'/',Ident[IdentTemp].NumAllocElements_,'|',ActualParamType,',',AllocElementType);

	end else begin

	 if Tok[i].Kind = TTokenKind.IDENTTOK then begin

	  IdentTemp := GetIdentIndex(Tok[i].Name);

	  AllocElementType := Ident[IdentTemp].AllocElementType;
	  NumAllocElements := Ident[IdentTemp].NumAllocElements;

//	writeln(Ident[IdentTemp].Name,' > ',ActualPAramType,',',AllocElementType,',',NumAllocElements,' | ',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements);

	 end else
	  AllocElementType := TTokenKind.UNTYPETOK;

	end;

       Result[NumActualParams].DataType := ActualParamType;
       Result[NumActualParams].AllocElementType := AllocElementType;
       Result[NumActualParams].NumAllocElements := NumAllocElements;


//	writeln(Result[NumActualParams].DataType,',',Result[NumActualParams].AllocElementType);

     until Tok[i + 1].Kind <> TTokenKind.COMMATOK;

     CheckTok(i + 1, TTokenKind.CPARTOK);

     Result[1].i_ := i;

//     inc(i);
     end;	// if (Tok[i + 1].Kind = OPARTOR) and (Tok[i + 2].Kind <> TTokenKind.CPARTOK)


     Pass := oldPass;
     CodeSize := oldCodeSize;

end;	//NumActualParameters


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileActualParameters(var i: integer; IdentIndex: integer; ProcVarIndex: integer = 0);
var NumActualParams, IdentTemp, ParamIndex, j, old_i, old_func: integer;
    ActualParamType, AllocElementType: TTokenKind;
    svar, lab: string;
    yes: Boolean;
    Param: TParamList;
begin

   svar:= '';
   lab := '';

   old_i := i;

   if Ident[IdentIndex].ProcAsBlock = BlockStack[BlockStackTop] then Ident[IdentIndex].isRecursion := true;


   yes := {(Ident[IdentIndex].ObjectIndex > 0) or} Ident[IdentIndex].isRecursion or Ident[IdentIndex].isStdCall;

   for ParamIndex := Ident[IdentIndex].NumParams downto 1 do
    if not ( (Ident[IdentIndex].Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING) or
	     ((Ident[IdentIndex].Param[ParamIndex].DataType in Pointers) and (Ident[IdentIndex].Param[ParamIndex].NumAllocElements and $FFFF in [0,1])) or
	     ((Ident[IdentIndex].Param[ParamIndex].DataType in Pointers) and (Ident[IdentIndex].Param[ParamIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK])) or
             (Ident[IdentIndex].Param[ParamIndex].DataType in OrdinalTypes + RealTypes)
	   ) then begin yes := TRUE; Break end;


//   yes:=true;

(*------------------------------------------------------------------------------------------------------------*)

   if  ProcVarIndex > 0 then begin

     svar := GetLocalName(ProcVarIndex);

     if (Tok[i + 1].Kind = TTokenKind.OBRACKETTOK) then begin
       i := CompileArrayIndex(i, ProcVarIndex);

       CheckTok(i + 1, TTokenKind.CBRACKETTOK);

       inc(i);

       if (Ident[ProcVarIndex].NumAllocElements * 2 > 256) or (Ident[ProcVarIndex].NumAllocElements in [0, 1]) then begin

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

	asm65(#9'dex');

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

        asm65(#9'dex');

       end;

       asm65(#9'lda #$4C');
       asm65(#9'sta :TMP');

     end else begin

       if Ident[ProcVarIndex].isAbsolute and (Ident[ProcVarIndex].NumAllocElements = 0) then begin

//        asm65(#9'jsr *+6');
//        asm65(#9'jmp *+6');

       end else begin

         if (Ident[ProcVarIndex].PassMethod = TParameterPassingMethod.VARPASSING) then begin

          if pos('.', svar) > 0 then begin

	  lab := ExtractName(ProcVarIndex, svar);

           asm65(#9'mwy ' + lab + ' :bp2');
           asm65(#9'ldy #' + svar + '-DATAORIGIN')
          end else begin
           asm65(#9'mwy ' + svar + ' :bp2');
           asm65(#9'ldy #$00');
	  end;

          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :TMP+1');
          asm65(#9'iny');
          asm65(#9'lda (:bp2),y');
          asm65(#9'sta :TMP+2');

	 end else begin

//	 writeln(Ident[ProcVarIndex].Name,',',Ident[ProcVarIndex].DataType,',',   Ident[ProcVarIndex].NumAllocElements,',', Ident[ProcVarIndex].AllocElementType,',',Ident[ProcVarIndex].isAbsolute);

	  if Ident[ProcVarIndex].NumAllocElements = 0 then begin

           asm65(#9'lda ' + svar);
           asm65(#9'sta :TMP+1');
           asm65(#9'lda ' + svar + '+1');
           asm65(#9'sta :TMP+2');

	  end else

       	  if (Ident[ProcVarIndex].NumAllocElements * 2 > 256) or (Ident[ProcVarIndex].NumAllocElements in [1]) then begin

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

	   asm65(#9'dex');

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

	   asm65(#9'dex');

       	  end;

	 end;

         asm65(#9'lda #$4C');
         asm65(#9'sta :TMP');

       end;

     end;

   end;

(*------------------------------------------------------------------------------------------------------------*)

   Param := NumActualParameters(i, IdentIndex, NumActualParams);

   if NumActualParams <> Ident[IdentIndex].NumParams then
     if ProcVarIndex > 0 then
	Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters specified for {0}.', Ident[ProcVarIndex].Name) )
     else
	Error(i,TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters specified for {0}.', Ident[identIndex].Name) );


   ParamIndex := NumActualParams;

   AllocElementType := TTokenKind.UNTYPETOK;

//   NumActualParams := 0;
   IdentTemp := 0;

   if (Tok[i + 1].Kind = TTokenKind.OPARTOK) then		    // Actual parameter list found
     begin

     if (Tok[i + 2].Kind = TTokenKind.CPARTOK) then
      inc(i)
     else
     //repeat

     while NumActualParams > 0 do begin

//       Inc(NumActualParams);

//       if NumActualParams > Ident[IdentIndex].NumParams then
//        if ProcVarIndex > 0 then
//	 Error(i, WrongNumParameters, ProcVarIndex)
//	else
//	 Error(i, WrongNumParameters, IdentIndex);

       i := Param[NumActualParams].i;

       if (Ident[IdentIndex].Param[NumActualParams].PassMethod = TParameterPassingMethod.VARPASSING) then begin

	i := CompileAddress(i + 1, ActualParamType, AllocElementType, true);


//	writeln(Ident[IdentIndex].Param[NumActualParams].Name,',',Ident[IdentIndex].Param[NumActualParams].DataType  ,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements and $FFFF,'/',Ident[IdentIndex].Param[NumActualParams].NumAllocElements shr 16,' | ',ActualParamType,',', AllocElementType);


	if (Ident[IdentIndex].Param[NumActualParams].DataType <> TTokenKind.UNTYPETOK) and (ActualParamType = TDataType.POINTERTOK) and (AllocElementType in [TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.PCHARTOK]) then begin

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

	end;


	if Tok[i].Kind = TTokenKind.IDENTTOK then
	 IdentTemp := GetIdentIndex(Tok[i].Name)
	else
	 IdentTemp := 0;

	if IdentTemp > 0 then begin


	if Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK then Error(i, TErrorCode.CantAdrConstantExp);	// TParameterPassingMethod.VARPASSING function not possible


//	writeln(' - ',Tok[i].Name,',',ActualParamType,',',AllocElementType, ',', Ident[IdentTemp].NumAllocElements );
//	writeln(Ident[IdentTemp].Kind,',',Ident[IdentTemp].DataType,',',Ident[IdentIndex].Param[NumActualParams].DataType);

	if Ident[IdentTemp].DataType in Pointers then
	  if not(Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.FILETOK, TTokenKind.TEXTFILETOK]) then begin

{
 writeln('--- ',Ident[IdentIndex].Name);
 writeln(Ident[IdentIndex].Param[NumActualParams].DataType,',', Ident[IdentTemp].DataType);
 writeln(Ident[IdentIndex].Param[NumActualParams].NumAllocElements,',', Ident[IdentTemp].NumAllocElements);
 writeln(Ident[IdentIndex].Param[NumActualParams].PassMethod,',', Ident[IdentTemp].PassMethod);
}

	    if Ident[IdentTemp].PassMethod <> TParameterPassingMethod.VARPASSING then

	      if Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then
                      Error(i, TMessage.Create(TErrorCode.IncompatibleTypes, 'Incompatible types: got "{0}" expected "^{1}".',
                        TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name,
                        TypeArray[Ident[IdentIndex].Param[NumActualParams].NumAllocElements].Field[0].Name))
	      else
	        GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	  end;



	 if (Ident[IdentTemp].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) {and (Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK])} then
	  if (Ident[IdentIndex].Param[NumActualParams].NumAllocElements > 0) and (Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements) then begin

	    if Ident[IdentTemp].PassMethod <> Ident[IdentIndex].Param[NumActualParams].PassMethod then
		Error(i, TErrorCode.CantAdrConstantExp)
	    else
		ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentTemp);
	  end;


	 if (Ident[IdentTemp].AllocElementType = TDataType.UNTYPETOK) then begin

	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	   if (Ident[IdentTemp].AllocElementType = TDataType.UNTYPETOK) then
	     if (Ident[IdentIndex].Param[NumActualParams].DataType <> TTokenKind.UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType <> Ident[IdentTemp].DataType) then
	       ErrorIncompatibleTypes(i,Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].DataType);

	 end else
	  if Ident[IdentIndex].Param[NumActualParams].DataType in Pointers then begin

//	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].AllocElementType, Ident[IdentTemp].AllocElementType);

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

	     if (Ident[IdentIndex].Param[NumActualParams].AllocElementType = TDataType.UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.POINTERTOK, TTokenKind.PCHARTOK]) then begin

	      if Ident[IdentTemp].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then

	      else
	        ErrorIdentifierIncompatibleTypesArray(i, IdentTemp, Ident[IdentIndex].Param[NumActualParams].DataType);

	     end else
	      ErrorIncompatibleTypes(i, Ident[IdentTemp].AllocElementType, Ident[IdentIndex].Param[NumActualParams].AllocElementType);

	   end;

	  end else
	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].AllocElementType);

	end else
	  if  Ident[IdentIndex].Param[NumActualParams].DataType <> TTokenKind.UNTYPETOK then
	   if (Ident[IdentIndex].Param[NumActualParams].DataType <> AllocElementType)  then begin

//	writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType);

	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> TTokenKind.UNTYPETOK then begin

	       if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> AllocElementType then
	         ErrorIncompatibleTypes(i, AllocElementType, Ident[IdentIndex].Param[NumActualParams].DataType);

	     end else
	       ErrorIncompatibleTypes(i,  AllocElementType, Ident[IdentIndex].Param[NumActualParams].DataType);

	   end;


//	writeln('x ',Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType,',',IdentTemp);


	  if IdentTemp = 0 then
	   if (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.RECORDTOK) and (ActualParamType = TDataType.POINTERTOK) and (AllocElementType = TDataType.RECORDTOK) then

	   else
	   if (ActualParamType = TDataType.POINTERTOK) and (AllocElementType <> TTokenKind.UNTYPETOK) then
	     GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, AllocElementType)
	   else
	    GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);


       end else begin

	i := CompileExpression(i + 2, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);	// Evaluate actual parameters and push them onto the stack

//	writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].kind,',',    Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType ,'|',ActualParamType);


	if (Tok[i].Kind = TTokenKind.IDENTTOK) and (ActualParamType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) and not (Ident[IdentIndex].Param[NumActualParams].DataType in Pointers) then
	 if Ident[GetIdentIndex(Tok[i].Name)].isNestedFunction then begin

	  if Ident[GetIdentIndex(Tok[i].Name)].NestedFunctionNumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, GetIdentIndex(Tok[i].Name));

	 end else
	  if Ident[GetIdentIndex(Tok[i].Name)].NumAllocElements <> Ident[IdentIndex].Param[NumActualParams].NumAllocElements then
	    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, GetIdentIndex(Tok[i].Name));


	if ((ActualParamType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) and (Ident[IdentIndex].Param[NumActualParams].DataType in Pointers)) or
	   ((ActualParamType in Pointers) and (Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK])) then
     //  jesli wymagany jest POINTER a przekazujemy RECORD (lub na odwrot) to OK

	begin

         if (ActualParamType = TDataType.POINTERTOK) and (Tok[i].Kind = TTokenKind.IDENTTOK) then begin
	   IdentTemp := GetIdentIndex(Tok[i].Name);

           if (Tok[i - 1].Kind = TTokenKind.ADDRESSTOK) then
	    AllocElementType := TTokenKind.UNTYPETOK
	   else
	    AllocElementType := Ident[IdentTemp].AllocElementType;

	   if AllocElementType = TDataType.UNTYPETOK then
	      ErrorIncompatibleTypes(i, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);
{
 writeln('--- ',Ident[IdentIndex].Name,',',ActualParamType,',',AllocElementType);
 writeln(Ident[IdentIndex].Param[NumActualParams].DataType,',', Ident[IdentTemp].DataType);
 writeln(Ident[IdentIndex].Param[NumActualParams].AllocElementType,',', Ident[IdentTemp].AllocElementType);
 writeln(Ident[IdentIndex].Param[NumActualParams].NumAllocElements,',', Ident[IdentTemp].NumAllocElements);
 writeln(Ident[IdentIndex].Param[NumActualParams].PassMethod,',', Ident[IdentTemp].PassMethod);
}
	 end else
	   ErrorIncompatibleTypes(i, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);

	end

	else begin

         if (ActualParamType = TDataType.POINTERTOK) and (Tok[i].Kind = TTokenKind.IDENTTOK) then begin
	   IdentTemp := GetIdentIndex(Tok[i].Name);

           if (Tok[i - 1].Kind = TTokenKind.ADDRESSTOK) then
	    AllocElementType := TTokenKind.UNTYPETOK
	   else
	    AllocElementType := Ident[IdentTemp].AllocElementType;


	   if (Ident[IdentTemp].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) then
	    GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType)
	   else
	   if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> AllocElementType then begin

	     if (Ident[IdentIndex].Param[NumActualParams].AllocElementType = TDataType.UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.POINTERTOK) and ({Ident[IdentIndex].Param[NumActualParams]} Ident[IdentTemp].NumAllocElements > 0) then
	      ErrorIdentifierIncompatibleTypesArray(i, IdentTemp, TTokenKind.POINTERTOK)
	     else
	      if (Ident[IdentIndex].Param[NumActualParams].AllocElementType <> TTokenKind.PROCVARTOK) and (Ident[IdentIndex].Param[NumActualParams].NumAllocElements > 0) then
	       ErrorIncompatibleTypes(i, AllocElementType, Ident[IdentIndex].Param[NumActualParams].AllocElementType);

           end;

	 end else
          if (Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK]) and (Tok[i].Kind = TTokenKind.IDENTTOK) then begin
	    IdentTemp := GetIdentIndex(Tok[i].Name);

//	writeln('1 > ',Ident[IdentTemp].name,',', Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements,' | ',Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements );

            if (Ident[IdentTemp].DataType = TDataType.STRINGPOINTERTOK) and (Ident[IdentTemp].NumAllocElements <> 0)
            and (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].Param[NumActualParams].NumAllocElements = 0) then
	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType = TDataType.UNTYPETOK then
	       ErrorIncompatibleTypes(i, Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].DataType)
	     else
	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> TTokenKind.BYTETOK then		// Exceptionally we accept PBYTE as STRING
	       ErrorIncompatibleTypes(i, Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].AllocElementType, true);

{
	      if (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.PCHARTOK) then begin

	        if Ident[IdentTemp].DataType = TDataType.STRINGPOINTERTOK then begin
	          asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'add #$01');
	          asm65(#9'sta :STACKORIGIN,x');
	          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'adc #$00');
	          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		end;

	      end;
}

	      GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	  end else begin

//	writeln('2 > ',Ident[IdentIndex].Name,',',ActualParamType,',',AllocElementType,',',Tok[i].Kind,',',Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements);

            if (ActualParamType = TDataType.POINTERTOK) and (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.STRINGPOINTERTOK) then
              ErrorIncompatibleTypes(i, ActualParamType, TTokenKind.STRINGPOINTERTOK, true);

	      if (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.STRINGPOINTERTOK) then begin		// CHAR -> STRING

	        if (ActualParamType = TDataType.CHARTOK) and (Tok[i].Kind = TTokenKind.CHARLITERALTOK) then begin

		  ActualParamType := TTokenKind.STRINGPOINTERTOK;

		  if Pass = TPass.CODE_GENERATION then begin
		   DefineStaticString(i, chr(Tok[i].Value));
		   Tok[i].Kind := TTokenKind.STRINGLITERALTOK;

	           asm65(#9'lda :STACKORIGIN,x');
	           asm65(#9'sta :STACKORIGIN,x');
	           asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	           asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	           asm65(#9'lda <CODEORIGIN+$' + IntToHex(Tok[i].StrAddress - CODEORIGIN, 4));
	           asm65(#9'sta :STACKORIGIN,x');
	           asm65(#9'lda >CODEORIGIN+$' + IntToHex(Tok[i].StrAddress - CODEORIGIN, 4));
	           asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		  end;

		end;

	      end;


	      if (Ident[IdentIndex].Param[NumActualParams].DataType = TDataType.PCHARTOK) then begin

	        if (ActualParamType = TDataType.STRINGPOINTERTOK) then begin
	          asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'add #$01');
	          asm65(#9'sta :STACKORIGIN,x');
	          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'adc #$00');
	          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		end;


	        if (ActualParamType = TDataType.CHARTOK) and (Tok[i].Kind = TTokenKind.CHARLITERALTOK) then begin

		  ActualParamType := TTokenKind.PCHARTOK;

		  if Pass = TPass.CODE_GENERATION then begin
		   DefineStaticString(i, chr(Tok[i].Value));
		   Tok[i].Kind := TTokenKind.STRINGLITERALTOK;

	           asm65(#9'lda :STACKORIGIN,x');
	           asm65(#9'sta :STACKORIGIN,x');
	           asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	           asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

	           asm65(#9'lda <CODEORIGIN+$' + IntToHex(Tok[i].StrAddress - CODEORIGIN+1, 4));
	           asm65(#9'sta :STACKORIGIN,x');
	           asm65(#9'lda >CODEORIGIN+$' + IntToHex(Tok[i].StrAddress - CODEORIGIN+1, 4));
	           asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		  end;

		end;

	      end;

	      GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);

	  end;

	end;

	ExpandParam(Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);
       end;



	if (Ident[IdentIndex].isRecursion = false) and (Ident[IdentIndex].isStdCall = false) and (ParamIndex > 1) and
	   (Ident[IdentIndex].Param[NumActualParams].PassMethod <> TParameterPassingMethod.VARPASSING) and
	   (Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] + Pointers) and
	   (Ident[IdentIndex].Param[NumActualParams].NumAllocElements and $FFFF > 1) then

	 if Ident[IdentIndex].Param[NumActualParams].DataType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then begin

 	  if Ident[IdentIndex].isOverload then
  	    svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
 	  else
  	    svar := GetLocalName(IdentIndex);

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta :bp2');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :bp2+1');

	  j := RecordSize(GetIdentIndex(TypeArray[Ident[IdentIndex].Param[NumActualParams].Numallocelements].Field[0].Name ) );

//	writeln('1: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].Kind ,',',  Ident[IdentIndex].Param[NumActualParams].name,',',Ident[IdentIndex].Param[NumActualParams].DataType,',',j);

	  if j = 256 then begin
	    asm65(#9'ldy #$00');;
	    asm65(#9'mva:rne (:bp2),y ' + svar + '.adr.' + Ident[IdentIndex].Param[NumActualParams].Name + ',y+' );
	  end else
	  if j <= 128 then begin
	    asm65(#9'ldy #$' + IntToHex(j - 1, 2));
	    asm65(#9'mva:rpl (:bp2),y ' + svar + '.adr.' + Ident[IdentIndex].Param[NumActualParams].Name + ',y-' );
	  end else
	    asm65(#9'@move ":bp2" #' + svar + '.adr.' + Ident[IdentIndex].Param[NumActualParams].Name + ' #' + IntToStr(j));


	 end else
         if not (Ident[IdentIndex].Param[NumActualParams].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) then begin

 	  if Ident[IdentIndex].isOverload then
  	    svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
 	  else
  	    svar := GetLocalName(IdentIndex);

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta :bp2');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :bp2+1');

    	  if Ident[IdentIndex].Param[NumActualParams].NumAllocElements shr 16 <> 0 then
     	   j := (Ident[IdentIndex].Param[NumActualParams].NumAllocElements and $FFFF) * (Ident[IdentIndex].Param[NumActualParams].NumAllocElements shr 16)
    	  else
     	   j := Ident[IdentIndex].Param[NumActualParams].NumAllocElements;

	  j := j * GetDataSize(Ident[IdentIndex].Param[NumActualParams].AllocElementType);

//	writeln('2: ',Ident[IdentIndex].isStdCall ,',',Ident[IdentIndex].NumAllocElements,',',  Ident[IdentIndex].Param[NumActualParams].name,',',Ident[IdentIndex].Param[0].AllocElementType,',',j);

	  if j = 256 then begin
	    asm65(#9'ldy #$00');;
	    asm65(#9'mva:rne (:bp2),y ' + svar + '.adr.' + Ident[IdentIndex].Param[NumActualParams].Name + ',y+' );
	  end else
	  if j <= 128 then begin
	    asm65(#9'ldy #$' + IntToHex(j - 1, 2));
	    asm65(#9'mva:rpl (:bp2),y ' + svar + '.adr.' + Ident[IdentIndex].Param[NumActualParams].Name + ',y-' );
	  end else
	    asm65(#9'@move ":bp2" #' + svar + '.adr.' + Ident[IdentIndex].Param[NumActualParams].Name + ' #' + IntToStr(j));

	 end;


       dec(NumActualParams);
     end;

     //until Tok[i + 1].Kind <> TTokenKind.COMMATOK;

     i := Param[1].i_;

     CheckTok(i + 1, TTokenKind.CPARTOK);

     inc(i);
     end;// if Tok[i + 1].Kind = OPARTOR


   NumActualParams := ParamIndex;


 //writeln(Ident[IdentIndex].name,',',NumActualParams,',',Ident[IdentIndex].isUnresolvedForward ,',',Ident[IdentIndex].isRecursion );


   if Pass = TPass.CALL_DETERMINATION then											// issue #103 fixed
    if Ident[IdentIndex].isUnresolvedForward then									//
															//
      Ident[IdentIndex].updateResolvedForward := TRUE									//
    else														//
      AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);					//


(*------------------------------------------------------------------------------------------------------------*)

// if Ident[IdentIndex].isUnresolvedForward then begin
//   Error(i, 'Unresolved forward declaration of ' + Ident[IdentIndex].Name);

{
 if (Ident[IdentIndex].isExternal) and (Ident[IdentIndex].Libraries > 0) then begin

  if Ident[IdentIndex].isOverload then
   svar := Ident[IdentIndex].Alias+ '.' + GetOverloadName(IdentIndex)
  else
   svar := GetLocalName(IdentIndex) + '.' + Ident[IdentIndex].Alias;

 end else
}



 if Ident[IdentIndex].isOverload then
  svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
 else
  svar := GetLocalName(IdentIndex);


 if RCLIBRARY and Ident[IdentIndex].isExternal and (Ident[IdentIndex].Libraries > 0) and (Ident[IdentIndex].isStdCall = false) then begin

   asm65('#lib:' + svar);

 end;


if (yes = FALSE) and (Ident[IdentIndex].NumParams > 0) then begin

 for ParamIndex := 1 to NumActualParams do
  if Ident[IdentIndex].Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');

					a65(TCode65.subBX);
  end else
  if (NumActualParams = 1) and (GetDataSize(Ident[IdentIndex].Param[ParamIndex].DataType) = 1) then begin			// only ONE parameter SIZE = 1

			if Ident[IdentIndex].ObjectIndex > 0 then begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					a65(TCode65.subBX);
			end else begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta @PARAM?');
					a65(TCode65.subBX);
			end;

  end else
  case Ident[IdentIndex].Param[ParamIndex].DataType of

   TTokenKind.BYTETOK, TTokenKind.CHARTOK, TTokenKind.BOOLEANTOK, TTokenKind.SHORTINTTOK:
   				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);

					a65(TCode65.subBX);
				     end;

   TTokenKind.WORDTOK, TTokenKind.SMALLINTTOK, TTokenKind.SHORTREALTOK, TDataType.HALFSINGLETOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.PCHARTOK:
      				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');

					a65(TCode65.subBX);
				     end;

   TTokenKind.CARDINALTOK, TTokenKind.INTEGERTOK, TTokenKind.REALTOK, TTokenKind.SINGLETOK:
      				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');
					asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+2');
					asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+3');

					a65(TCode65.subBX);
				     end;

  else
              Error(i, TMessage.Create(TErrorCode.Unassigned, 'Unassigned: {0}',
                GetTokenKindName(Ident[IdentIndex].Param[ParamIndex].DataType)));
  end;


  old_func:=run_func;
  run_func:=0;

  if (Ident[IdentIndex].isStdCall = false) then
						if Ident[IdentIndex].Kind = TTokenKind.FUNCTIONTOK then
	  						StartOptimization(i)
						else
	  						StopOptimization;
  run_func:=old_func;


 end;

 Gen;


(*------------------------------------------------------------------------------------------------------------*)

   if Ident[IdentIndex].ObjectIndex > 0 then begin

    if Tok[old_i].Kind <> TTokenKind.IDENTTOK then
      Error(old_i, TErrorCode.IdentifierExpected)
    else
      IdentTemp := GetIdentIndex(copy(Tok[old_i].Name, 1, pos('.', Tok[old_i].Name)-1 ));

     asm65(#9'lda ' + GetLocalName(IdentTemp));
     asm65(#9'ldy ' + GetLocalName(IdentTemp) + '+1');
   end;

(*------------------------------------------------------------------------------------------------------------*)


 if Ident[IdentIndex].isInline then begin

// if pass = CODE_GENERATION then
//    writeln(svar,',', Ident[IdentIndex].ProcAsBlock,',', BlockStack[BlockStackTop], ',' ,Ident[IdentIndex].Block ,',', Ident[IdentIndex].UnitIndex );

//  asm65(#9'.LOCAL ' + svar);


  if (Ident[IdentIndex].Block > 1) and (Ident[IdentIndex].Block <> BlockStack[BlockStackTop]) then	// issue #102 fixed
    for IdentTemp := NumIdent downto 1  do
      if (Ident[IdentTemp].Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK]) and (Ident[IdentTemp].ProcAsBlock = Ident[IdentIndex].Block) then begin
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

   if (Ident[ProcVarIndex].isAbsolute) and (Ident[ProcVarIndex].NumAllocElements = 0) then begin

    asm65(#9'jsr *+6');
    asm65(#9'jmp *+6');
    asm65(#9'jmp (' + GetLocalName(ProcVarIndex) + ')');

   end else
    asm65(#9'jsr :TMP');

  end else
   if RCLIBRARY and Ident[IdentIndex].isExternal and (Ident[IdentIndex].Libraries > 0) and Ident[IdentIndex].isStdCall then begin

    asm65(#9'ldy <' + svar + '.@INITLIBRARY');
    asm65(#9'sty @xmsProc.ini');
    asm65(#9'ldy >' + svar + '.@INITLIBRARY');
    asm65(#9'sty @xmsProc.ini+1');

    asm65(#9'ldy <' + svar);
    asm65(#9'sty @xmsProc.prc');
    asm65(#9'ldy >' + svar);
    asm65(#9'sty @xmsProc.prc+1');

    asm65(#9'ldy #=' + svar);
    asm65(#9'jsr @xmsProc');

   end else
    asm65(#9'jsr ' + svar);				// Generate Call

 end;


	if (Ident[IdentIndex].Kind = TTokenKind.FUNCTIONTOK) and (Ident[IdentIndex].isStdCall = false) and (Ident[IdentIndex].isRecursion = false) then begin

		  asm65(#9'inx');

		  case GetDataSize(Ident[IdentIndex].DataType) of

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


 if RCLIBRARY and Ident[IdentIndex].isExternal and (Ident[IdentIndex].Libraries > 0) and (Ident[IdentIndex].isStdCall = false) then begin

     asm65(#9'pla');
     asm65(#9'sta portb');

 end;


end;	//CompileActualParameters


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileFactor(i: Integer; out isZero: Boolean; out ValType: TDataType; VarType: TDataType = TDataType.INTEGERTOK): Integer;
var IdentTemp, IdentIndex, oldCodeSize, j: Integer;
    ActualParamType: TDataType;
    AllocElementType: TDataType;
    IndirectionLevel: Integer;
    Kind: TTokenKind;
    oldPass: TPass;
    yes: Boolean;
    Value, ConstVal: Int64;
    svar, lab: string;
    Param: TParamList;
begin

 isZero:=false;

 Result := i;

 ValType := TDataType.UNTYPETOK;
 ConstVal := 0;
 IdentIndex := 0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 TTokenKind.HIGHTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      if Tok[i + 2].Kind in AllTypes {+ [TTokenKind.STRINGTOK]} then begin

       ValType := Tok[i + 2].Kind;

       j:=i + 2;

      end else begin

      oldPass := pass;
      oldCodeSize := CodeSize;
      Pass := TPass.CALL_DETERMINATION;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

      end;
{
      if ValType = TDataType.ENUMTYPE then begin

       if Tok[j].Kind = TTokenKind.IDENTTOK then
	IdentIndex := GetIdentIndex(Tok[j].Name)
       else
	 Error(i, TypeMismatch);

       if IdentIndex = 0 then Error(i, TypeMismatch);

       IdentTemp := GetIdentIndex(TypeArray[Ident[IdentIndex].NumAllocElements].Field[TypeArray[Ident[IdentIndex].NumAllocElements].NumFields].Name);

       if Ident[IdentTemp].NumAllocElements = 0 then Error(i, TypeMismatch);

       Push(Ident[IdentTemp].Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentTemp);

       GenerateWriteString(Ident[IdentTemp].Value, ASPOINTERTOPOINTER, Ident[IdentTemp].DataType, IdentTemp)

      end else begin
}
      if ValType in Pointers then begin
       IdentIndex := GetIdentIndex(Tok[i + 2].Name);

       if Ident[IdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK] then
	Value := Ident[IdentIndex].NumAllocElements_ - 1
       else
       if Ident[IdentIndex].NumAllocElements > 0 then
	Value := Ident[IdentIndex].NumAllocElements - 1
       else
	Value := HighBound(j, Ident[IdentIndex].AllocElementType);

      end else
       Value := HighBound(j, ValType);

      ValType:=GetValueType(Value);

      if Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK then begin
        a65(TCode65.addBX);
        asm65(#9'lda adr.' + GetLocalName(IdentIndex));
        asm65(#9'sta :STACKORIGIN,x');

	ValType := TTokenKind.BYTETOK;
      end else
       Push(Value, ASVALUE, GetDataSize(ValType));

//     end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      Result := j + 1;
    end;


 TTokenKind.LOWTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := TPass.CALL_DETERMINATION;

//      j := i + 2;

      i:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

{
      if ValType = ENUMTYPE then begin

       if Tok[j].Kind = TTokenKind.IDENTTOK then
	IdentIndex := GetIdentIndex(Tok[j].Name)
       else
	 Error(i, TypeMismatch);

       if IdentIndex = 0 then Error(i, TypeMismatch);

       IdentTemp := GetIdentIndex(TypeArray[Ident[IdentIndex].NumAllocElements].Field[1].Name);

       if Ident[IdentTemp].NumAllocElements = 0 then Error(i, TypeMismatch);

       ValType := ENUMTYPE;
       Push(Ident[IdentTemp].Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentTemp);

       GenerateWriteString(Ident[IdentTemp].Value, ASPOINTERTOPOINTER, Ident[IdentTemp].DataType, IdentTemp)

      end else begin
}

       if ValType in Pointers then begin
	Value := 0;

	if ValType = TDataType.STRINGPOINTERTOK then Value := 1;

       end else
	Value := LowBound(i, ValType);

       ValType := GetValueType(Value);

       Push(Value, ASVALUE, GetDataSize(ValType));

//      end;

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Result := i + 1;
    end;


 TTokenKind.SIZEOFTOK:
    begin
      Value:=0;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      if Tok[i + 2].Kind in OrdinalTypes + RealTypes + [TDataType.POINTERTOK] then begin

       Value := GetDataSize(Tok[i + 2].Kind);

       ValType := TTokenKind.BYTETOK;

       j:=i + 2;

      end else begin

      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
        Error(i + 2, TErrorCode.IdentifierExpected);

      oldPass := Pass;
      oldCodeSize := CodeSize;
      Pass := TPass.CALL_DETERMINATION;

      j:=CompileExpression(i + 2, ValType);

      Pass := oldPass;
      CodeSize := oldCodeSize;

      Value := GetSizeof(i, ValType);

      ValType := GetValueType(Value);

      end;  // if Tok[i + 2].Kind in


    Push(Value, ASVALUE, GetDataSize(ValType));

    CheckTok(j + 1, TTokenKind.CPARTOK);

    Result := j + 1;

    end;


 TTokenKind.LENGTHTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      Value:=0;


      if Tok[i + 2].Kind = TTokenKind.CHARLITERALTOK then begin

	Push(1, ASVALUE, 1);

	ValType := TTokenKind.BYTETOK;

	inc(i, 2);

      end else
      if Tok[i + 2].Kind = TTokenKind.STRINGLITERALTOK then begin

	Push(Tok[i + 2].StrLength, ASVALUE, 1);

	ValType := TTokenKind.BYTETOK;

	inc(i, 2);

      end else

      if Tok[i + 2].Kind = TTokenKind.IDENTTOK then begin

	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].AllocElementType );


	if Ident[IdentIndex].Kind in [VARIABLE, CONSTANT] then begin


	  if Ident[IdentIndex].DataType = TDataType.CHARTOK then begin					// length(CHAR) = 1

	    Push(1, ASVALUE, 1);

	    ValType := TTokenKind.BYTETOK;

	  end else

	  if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType in [TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) then begin

  	    i := CompileArrayIndex(i + 2, IdentIndex);						// array[ ].field

	    ValType := Ident[IdentIndex].AllocElementType;

	    CheckTok(i + 2, TTokenKind.DOTTOK);
	    CheckTok(i + 3, TTokenKind.IDENTTOK);

	    IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);

	    if IdentTemp < 0 then
                Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember, 'Identifier idents no member ''{0}''.',
                  Tok[i + 3].Name));

//	     ValType := Ident[GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name)].AllocElementType;


	     if TTokenKind(IdentTemp shr 16) = TTokenKind.CHARTOK then begin

	       a65(TCode65.subBX);

	       Push(1 , ASVALUE, 1);

	     end else begin

              if TTokenKind(IdentTemp shr 16) <> TTokenKind.STRINGPOINTERTOK then Error(i + 1, TErrorCode.TypeMismatch);

	      Push(0, ASVALUE, 1);

	      Push(1, ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN, 1, IdentIndex, IdentTemp and $ffff);

 	     end;

	     ValType:= TTokenKind.BYTETOK;

	     inc(i);

	  end else

	  if (Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0)) then begin

	   if ((Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = TDataType.CHARTOK)) or
	      ((Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType = TDataType.STRINGPOINTERTOK)) then begin

		if Ident[IdentIndex].AllocElementType = TDataType.STRINGPOINTERTOK then begin		// length(array[x])

		i:=CompileArrayIndex(i + 2, IdentIndex);

		a65(TCode65.addBX);

		svar := GetLocalName(IdentIndex);

		if (Ident[IdentIndex].NumAllocElements * 2 > 256) or (Ident[IdentIndex].NumAllocElements in [0,1]) or (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) then begin

    		asm65(#9'lda ' + svar);
     		asm65(#9'add :STACKORIGIN-1,x');
     		asm65(#9'sta :bp2');
     		asm65(#9'lda ' + svar + '+1');
     		asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     		asm65(#9'sta :bp2+1');

		asm65(#9'ldy #$01');
		asm65(#9'lda (:bp2),y');
		asm65(#9'sta :bp+1');
		asm65(#9'dey');
		asm65(#9'lda (:bp2),y');
		asm65(#9'tay');

		end else begin

		svar := GetLocalName(IdentIndex, 'adr.');

		asm65(#9'ldy :STACKORIGIN-1,x');
     		asm65(#9'lda ' + svar + '+1,y');
     		asm65(#9'sta :bp+1');
    		asm65(#9'lda ' + svar + ',y');
     		asm65(#9'tay');

		end;

		a65(TCode65.subBX);

		asm65(#9'lda (:bp),y');
		asm65(#9'sta :STACKORIGIN,x');

		CheckTok(i + 1, TTokenKind.CBRACKETTOK);

		CheckTok(i + 2, TTokenKind.CPARTOK);

		ValType := TTokenKind.BYTETOK;

		Result:=i + 2;
		exit;

		end else
		if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) or (Ident[IdentIndex].NumAllocElements = 0) then begin
		 a65(TCode65.addBX);

		 svar := GetLocalName(IdentIndex);

	  	 if TestName(IdentIndex, svar) then begin

		  lab := ExtractName(IdentIndex, svar);

		  if Ident[GetIdentIndex(lab)].AllocElementType = TDataType.RECORDTOK then begin
		   asm65(#9'lda ' + lab);
		   asm65(#9'ldy ' + lab + '+1');
		   asm65(#9'add #' + svar + '-DATAORIGIN');
		   asm65(#9'scc');
		   asm65(#9'iny');
		  end else begin
		   asm65(#9'lda ' + svar);
		   asm65(#9'ldy ' + svar + '+1');
		  end;

 	         end else begin
		  asm65(#9'lda ' + svar);
		  asm65(#9'ldy ' + svar + '+1');
	         end;

	 	 asm65(#9'sty :bp+1');
		 asm65(#9'tay');

		 asm65(#9'lda (:bp),y');
	 	 asm65(#9'sta :STACKORIGIN,x');

		end else begin
		 a65(TCode65.addBX);

		 asm65(#9'lda ' + GetLocalName(IdentIndex, 'adr.'));
		 asm65(#9'sta :STACKORIGIN,x');

		end;

		ValType := TTokenKind.BYTETOK;

	   end else begin

	    if Tok[i + 3].Kind = TTokenKind.OBRACKETTOK then

	     Error(i+2, TErrorCode.TypeMismatch)

	    else begin

	     Value:=Ident[IdentIndex].NumAllocElements;

	     ValType := GetValueType(Value);
	     Push(Value, ASVALUE, GetDataSize(ValType));

	    end;

	   end;

	  end else
	   Error(i + 2, TErrorCode.TypeMismatch);

	end else
	 Error(i + 2, TErrorCode.IdentifierExpected);

	inc(i, 2);
      end else
       Error(i + 2, TErrorCode.IdentifierExpected);

    CheckTok(i + 1, TTokenKind.CPARTOK);

    Result := i + 1;
    end;


  TTokenKind.LOTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, TTokenKind.INTEGERTOK, ActualParamType);

     if GetDataSize(ActualParamType) > 2 then WarningLoHi(i);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     asm65;
     asm65('; Lo(X)');

     case ActualParamType of
      TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK:
		  begin
		    asm65(#9'lda :STACKORIGIN,x');
		    asm65(#9'and #$0F');
		    asm65(#9'sta :STACKORIGIN,x');
		  end;
     end;

     if ActualParamType in [TDataType.INTEGERTOK, TDataType.CARDINALTOK] then
      ValType := TDataType.WORDTOK
     else
      ValType:= TDataType.BYTETOK;

     Result:=i + 1;
    end;


  TTokenKind.HITOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, TTokenKind.INTEGERTOK, ActualParamType);

     if GetDataSize(ActualParamType) > 2 then WarningLoHi(i);

     CheckTok(i + 1, TDataType.CPARTOK);

     asm65;
     asm65('; Hi(X)');

     case ActualParamType of
	 TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK: asm65(#9'jsr @hiBYTE');
	 TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK: asm65(#9'jsr @hiWORD');
      TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK: asm65(#9'jsr @hiCARD');
     end;

     if ActualParamType in [TDataType.INTEGERTOK, TDataType.CARDINALTOK] then
       ValType := TDataType.WORDTOK
     else
       ValType:= TDataType.BYTETOK;

     Result:=i + 1;
    end;


  TTokenKind.CHRTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType, TTokenKind.BYTETOK);
     GetCommonConstType(i, TTokenKind.INTEGERTOK, ActualParamType);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     ValType := TTokenKind.CHARTOK;
     Result:=i + 1;
    end;


  TTokenKind.INTTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     if not (ActualParamType in RealTypes) then
       ErrorIncompatibleTypes(i + 2, ActualParamType, TTokenKind.REALTOK);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     case ActualParamType of

       TTokenKind.SHORTREALTOK: asm65(#9'jsr @INT_SHORT');

            TTokenKind.REALTOK: asm65(#9'jsr @INT');

          TDataType.HALFSINGLETOK:
      		begin
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

          TDataType.SINGLETOK:
	  	begin
			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta :FPMAN0');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta :FPMAN1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta :FPMAN2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta :FPMAN3');

			asm65(#9'jsr @F2I');
			asm65(#9'jsr @I2F');

			asm65(#9'lda :FPMAN0');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :FPMAN1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :FPMAN2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :FPMAN3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		end;
     end;

     ValType := ActualParamType;
     Result:=i + 1;
    end;


  TTokenKind.FRACTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     if not (ActualParamType in RealTypes) then
       ErrorIncompatibleTypes(i + 2, ActualParamType, TTokenKind.REALTOK);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     case ActualParamType of

       TTokenKind.SHORTREALTOK: asm65(#9'jsr @SHORTREAL_FRAC');

            TTokenKind.REALTOK:
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

      TDataType.HALFSINGLETOK:
      		begin
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

          TTokenKind.SINGLETOK:
      		begin
			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta :FPMAN0');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta :FPMAN1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta :FPMAN2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta :FPMAN3');

			asm65(#9'jsr @FFRAC');

			asm65(#9'lda :FPMAN0');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :FPMAN1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :FPMAN2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :FPMAN3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
                end;


     end;

     ValType := ActualParamType;

     Result:=i + 1;
    end;


  TTokenKind.TRUNCTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     if ActualParamType in IntegerTypes then
      ValType := ActualParamType
     else
     if ActualParamType in RealTypes then begin

      ValType := TTokenKind.INTEGERTOK;

      case ActualParamType of

       TTokenKind.SHORTREALTOK:
       		begin
		      //asm65(#9'jsr @SHORTREAL_TRUNC');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @SHORTREAL_TRUNC.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @SHORTREAL_TRUNC.A+1');

			asm65(#9'jsr @SHORTREAL_TRUNC');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');

		        ValType := TTokenKind.SHORTINTTOK;
		end;

            TTokenKind.REALTOK:
	    	begin
		// asm65(#9'jsr @REAL_TRUNC');

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

      TDataType.HALFSINGLETOK:
      		begin
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

          TTokenKind.SINGLETOK:
      		begin
		     // asm65(#9'jsr @F2I');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta :FPMAN0');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta :FPMAN1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta :FPMAN2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta :FPMAN3');

			asm65(#9'jsr @F2I');

			asm65(#9'lda :FPMAN0');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :FPMAN1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :FPMAN2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :FPMAN3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
                end;

      end;

     end else
      GetCommonConstType(i, TTokenKind.REALTOK, ActualParamType);

     Result:=i + 1;
    end;


  TTokenKind.ROUNDTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     if ActualParamType in IntegerTypes then
      ValType := ActualParamType
     else
     if ActualParamType in RealTypes then begin

      ValType := TDataType.INTEGERTOK;

      case ActualParamType of

	TDataType.SHORTREALTOK:
		begin

		  asm65(#9'jsr @SHORTREAL_ROUND');

		  ValType := TDataType.SHORTINTTOK;

		end;

        TDataType.REALTOK:
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

	 TTokenKind.HALFSINGLETOK:
      		begin

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

        TTokenKind.SINGLETOK:
		begin
		 //asm65(#9'jsr @FROUND');

		 asm65(#9'lda :STACKORIGIN,x');
		 asm65(#9'sta :FP2MAN0');
		 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		 asm65(#9'sta :FP2MAN1');
		 asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		 asm65(#9'sta :FP2MAN2');
		 asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		 asm65(#9'sta :FP2MAN3');

		 asm65(#9'jsr @FROUND');

		 asm65(#9'lda :FPMAN0');
		 asm65(#9'sta :STACKORIGIN,x');
		 asm65(#9'lda :FPMAN1');
		 asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		 asm65(#9'lda :FPMAN2');
		 asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		 asm65(#9'lda :FPMAN3');
		 asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

        	end;

      end;

     end else
      GetCommonConstType(i, TTokenKind.REALTOK, ActualParamType);

     Result:=i + 1;
    end;


   TTokenKind.ODDTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);
     GetCommonConstType(i, TTokenKind.CARDINALTOK, ActualParamType);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'and #$01');
     asm65(#9'sta :STACKORIGIN,x');

     ValType := TTokenKind.BOOLEANTOK;
     Result:=i + 1;
    end;


  TTokenKind.ORDTOK:
    begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     j := i + 2;

     i := CompileExpression(i + 2, ValType, TDataType.BYTETOK);

     if not(ValType in OrdinalTypes + [ENUMTYPE]) then
	Error(i, TErrorCode.OrdinalExpExpected);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     if ValType in [TDataType.CHARTOK, TDataType.BOOLEANTOK, TDataType.ENUMTOK] then
       ValType := TTokenKind.BYTETOK;

     Result:=i + 1;
    end;


   TTokenKind.PREDTOK, TTokenKind.SUCCTOK:
    begin
      Kind := Tok[i].Kind;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileExpression(i + 2, ValType);

      if not(ValType in OrdinalTypes) then
	Error(i, TErrorCode.OrdinalExpExpected);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Push(1, ASVALUE, GetDataSize(ValType));

      if Kind =  TTokenKind.PREDTOK then
       GenerateBinaryOperation(TTokenKind.MINUSTOK, ValType)
      else
       GenerateBinaryOperation(TTokenKind.PLUSTOK, ValType);

      Result:=i + 1;
    end;


  TTokenKind.INTOK:
    begin

     writeln('IN');

{    CaseLocalCnt := CaseCnt;
    inc(CaseCnt);

    ResetOpty;

    StopOptimization;    // !!! potrzebujemy zachowac na stosie testowana wartosc

    i := CompileExpression(i + 1, SelectorType);

	if Tok[i].Kind = TTokenKind.IDENTTOK then
	 EnumName := GetEnumName(GetIdentIndex(Tok[i].Name));


    if GetDataSize( TDataType.SelectorType]<>1 then
     Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, TTokenKind.OFTOK);

    GenerateCaseProlog;

    NumCaseStatements := 0;

    inc(i, 2);

    SetLength(CaseLabelArray, 1);

    repeat       // Loop over all cases

      repeat     // Loop over all constants for the current case
	i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

	GetCommonType(i, ConstValType, SelectorType);

	if (Tok[i].Kind = TTokenKind.IDENTTOK) then
	 if ((EnumName = '') and (GetEnumName(GetIdentIndex(Tok[i].Name)) <> '')) or
  	    ((EnumName <> '') and (GetEnumName(GetIdentIndex(Tok[i].Name)) <> EnumName)) then
		Error(i, 'Constant and CASE types do not match');

	if Tok[i + 1].Kind = TTokenKind.RANGETOK then				      // Range check
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
	if Tok[i].Kind = TTokenKind.COMMATOK then
	  inc(i)
	else
	  ExitLoop := TRUE;
      until ExitLoop;


      CheckTok(i, TTokenKind.COLONTOK);

      GenerateCaseStatementProlog;

      ResetOpty;

      asm65('@');

      j := CompileStatement(i + 1);
      i := j + 1;
      GenerateCaseStatementEpilog(CaseLocalCnt);

      Inc(NumCaseStatements);

      ExitLoop := FALSE;
      if Tok[i].Kind <> TTokenKind.SEMICOLONTOK then
	begin
	if Tok[i].Kind = TTokenKind.ELSETOK then	      // Default statements
	  begin

	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	  end;
	ExitLoop := TRUE;
	end
      else
	begin
	inc(i);

	if Tok[i].Kind = TTokenKind.ELSETOK then begin
	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	end;

	if Tok[i].Kind = TTokenKind.ENDTOK then ExitLoop := TRUE;

	end

    until ExitLoop;

    CheckTok(i, TTokenKind.ENDTOK);

    GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

}
    Result := i;
    end;


  TTokenKind.IDENTTOK:
    begin
    IdentIndex := GetIdentIndex(Tok[i].Name);

    if IdentIndex > 0 then
	  if (Ident[IdentIndex].Kind = USERTYPE) and (Tok[i + 1].Kind = TTokenKind.OPARTOK) then begin

//		CheckTok(i + 1, TTokenKind.OPARTOK);


		j := CompileExpression(i + 2, ValType);


		if not(ValType in AllTypes) then
		  Error(i, TErrorCode.TypeMismatch);


		if (ValType = TDataType.POINTERTOK) and not (Ident[IdentIndex].DataType in [TTokenKind.POINTERTOK, TTokenKind.RECORDTOK, TTokenKind.OBJECTTOK]) then begin
		 ValType := Ident[IdentIndex].DataType;

		 if (Tok[i + 4].Kind = TTokenKind.DEREFERENCETOK) then exit(j + 2);
		end;


		if ValType in IntegerTypes then

		 case Ident[IdentIndex].DataType of

		        TDatatype.ENUMTOK:
		   	begin
				ValType :=  TDatatype.ENUMTOK;
			end;


			TDatatype.SHORTREALTOK:
		 	begin
				ExpandParam(TDatatype.SMALLINTTOK, ValType);

				asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
				asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'lda :STACKORIGIN,x');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'lda #$00');
				asm65(#9'sta :STACKORIGIN,x');

				ValType := TTokenKind.SHORTREALTOK;
			end;


			TDatatype.REALTOK:
			begin
				ExpandParam(TDatatype.INTEGERTOK, ValType);

				asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
				asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'lda :STACKORIGIN,x');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'lda #$00');
				asm65(#9'sta :STACKORIGIN,x');

				ValType := TTokenKind.REALTOK;
			end;


			 TTokenKind.HALFSINGLETOK:
			begin
				ExpandParam(TDatatype.INTEGERTOK, ValType);

				//asm65(#9'jsr @F16_I2F');

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

				ValType := TDataType.HALFSINGLETOK;
			end;


			TDatatype.SINGLETOK:
			begin
				ExpandParam(TDatatype.INTEGERTOK, ValType);

				//asm65(#9'jsr @I2F');

				asm65(#9'lda :STACKORIGIN,x');
				asm65(#9'sta :FPMAN0');
				asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'sta :FPMAN1');
				asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'sta :FPMAN2');
				asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
				asm65(#9'sta :FPMAN3');

				asm65(#9'jsr @I2F');

				asm65(#9'lda :FPMAN0');
				asm65(#9'sta :STACKORIGIN,x');
				asm65(#9'lda :FPMAN1');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
				asm65(#9'lda :FPMAN2');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
				asm65(#9'lda :FPMAN3');
				asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

				ValType := TTokenKind.SINGLETOK;
			end;

		 end;

		CheckTok(j + 1, TTokenKind.CPARTOK);

		if (ValType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType = TDataType.PROCVARTOK) then begin

			IdentTemp := GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		       	if Ident[IdentTemp].IsNestedFunction = FALSE then
                Error(j, TMessage.Create(TErrorCode.VariableConstantOrFunctionExpectedButProcedureFound,
                  'Variable, constant or function name expected but procedure {0} found.', Ident[IdentIndex].Name));

			if Tok[j].Kind <> TTokenKind.IDENTTOK then Error(j, TErrorCode.VariableExpected);

			svar := GetLocalName(GetIdentIndex(Tok[j].Name));

			asm65(#9'lda ' + svar);
	       		asm65(#9'sta :TMP+1');
			asm65(#9'lda ' + svar + '+1');
			asm65(#9'sta :TMP+2');
	       		asm65(#9'lda #$4C');
	       		asm65(#9'sta :TMP');
	       		asm65(#9'jsr :TMP');

			ValType := Ident[IdentTemp].DataType;

		end else
		if ((ValType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType in OrdinalTypes + RealTypes + [TDatatype.RECORDTOK, TTokenKind.OBJECTTOK])) or
		   ((ValType = TDataType.POINTERTOK) and (Ident[IdentIndex].DataType in [TDatatype.RECORDTOK, TTokenKind.OBJECTTOK])) then begin

		 yes:=false;

		 if (Ident[IdentIndex].DataType in [TDatatype.RECORDTOK, TTokenKind.OBJECTTOK]) and (Tok[j].Kind = TTokenKind.DEREFERENCETOK) then yes:=true;
		 if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Tok[j + 2].Kind = TTokenKind.DEREFERENCETOK) then yes:=true;

//		 yes := (Tok[j + 2].Kind = TTokenKind.DEREFERENCETOK);


//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Tok[j ].Kind,',',Tok[j + 1].Kind,',',Tok[j + 2].Kind);

 	     	 if (Ident[IdentIndex].AllocElementType in [TDatatype.RECORDTOK, TTokenKind.OBJECTTOK]) or (Ident[IdentIndex].DataType in [TDatatype.RECORDTOK, TTokenKind.OBJECTTOK]) then begin


	       	  if Tok[j + 2].Kind = TTokenKind.DEREFERENCETOK then inc(j);


		  if Tok[j+2].Kind <> TTokenKind.DOTTOK then yes := false else

		   if Tok[j+2].Kind = TTokenKind.DOTTOK then begin					// (pointer).field :=

			CheckTok(j + 3, TTokenKind.IDENTTOK);
	        	IdentTemp := RecordSize(IdentIndex, Tok[j + 3].Name);

	        	if IdentTemp < 0 then
                    Error(j + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                      'Identifier idents no member ''{0}''.', Tok[j + 3].Name));

	        	ValType := TDataType(IdentTemp shr 16);

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta :bp2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta :bp2+1');
			asm65(#9'ldy #$'+IntToHex(IdentTemp and $ffff, 2));

	        	inc(j, 2);
		   end;

	         end else
		   if Tok[j + 2].Kind = TTokenKind.DEREFERENCETOK then				// ASPOINTERTODEREFERENCE
		     if ValType = TDataType.POINTERTOK then begin

			asm65(#9'lda :STACKORIGIN,x');
		    	asm65(#9'sta :bp2');
		    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		    	asm65(#9'sta :bp2+1');
		    	asm65(#9'ldy #$00');

			ValType := Ident[IdentIndex].AllocElementType;

		    	inc(j);

		     end else
		      Error(j + 2, TErrorCode.IllegalQualifier);


		 if yes then
		  case GetDataSize(ValType) of

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



      if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType = TDataType.PROCVARTOK) then begin

//        writeln('!! ',hexstr(Ident[IdentIndex].NumAllocElements_,8));

	IdentTemp := GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

//	if Ident[IdentTemp].IsNestedFunction = FALSE then
//	 Error(i, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found');


	if Tok[i + 1].Kind = TTokenKind.OBRACKETTOK then begin
	  i := CompileArrayIndex(i, IdentIndex);

          CheckTok(i + 1, TTokenKind.CBRACKETTOK);

          inc(i);
	end;


	if Tok[i + 1].Kind = TTokenKind.OPARTOK then

	  CompileActualParameters(i, IdentTemp, IdentIndex)

	else begin

	  if Ident[IdentIndex].NumAllocElements > 0 then
	    Push(0, ASPOINTERTOARRAYORIGIN2, GetDataSize(TDataType.POINTERTOK), IdentIndex)
	  else
	    Push(0, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);

	end;

 	ValType := TTokenKind.POINTERTOK;

	Result := i;


      end else

      if Ident[IdentIndex].Kind = TTokenKind.PROCEDURETOK then
            Error(i, TMessage.Create(TErrorCode.VariableConstantOrFunctionExpectedButProcedureFound,
                  'Variable, constant or function name expected but procedure {0} found.',Ident[IdentIndex].Name ) )
      else if Ident[IdentIndex].Kind = TTokenKind.FUNCTIONTOK then       // Function call
	begin

	  Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc( Ident[IdentIndex].Name, IdentIndex, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then begin

	      if Ident[IdentIndex].NumParams <> j then
                  Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters specified for {0}.',
                    Ident[identIndex].Name));


	      ErrorForIdentifier(i, TErrorCode.CantDetermine, IdentIndex)
	     end else
             Error(i, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters specified for {0}.',
               Ident[identIndex].Name));

	    IdentIndex := IdentTemp;

//	  end;


        if (Ident[IdentIndex].isStdCall = false) then
	 StartOptimization(i)
	else
        if common.optimize.use = false then StartOptimization(i);


	inc(run_func);

	CompileActualParameters(i, IdentIndex);

	ValType := Ident[IdentIndex].DataType;

	dec(run_func);

	Result := i;
	end // FUNC
      else
	begin

// -----------------------------------------------------------------------------
// ===				 record^.
// -----------------------------------------------------------------------------

	if (Tok[i + 1].Kind = TTokenKind.DEREFERENCETOK) then
	  if (Ident[IdentIndex].Kind <> VARIABLE) or not (Ident[IdentIndex].DataType in Pointers) then
	    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
	  else
	    begin

	    if (Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	      ValType := TTokenKind.STRINGPOINTERTOK
	    else
 	      ValType :=  Ident[IdentIndex].AllocElementType;


	    if (ValType = TDataType.UNTYPETOK) and (Ident[IdentIndex].DataType = TDataType.POINTERTOK) then begin

	     ValType := TTokenKind.POINTERTOK;

	     Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(ValType), IdentIndex);

	    end else
	    if (ValType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin						// record^.


	     if (Tok[i + 2].Kind = TTokenKind.DOTTOK) then begin

//	writeln(Ident[IdentIndex].Name,',',Tok[i + 3].Name,' | ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements);

	      CheckTok(i + 3, TTokenKind.IDENTTOK);
	      IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);

 	      if IdentTemp < 0 then
                      Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                        'Identifier idents no member ''{0}''.', Tok[i + 3].Name));

	      ValType := TDataType(IdentTemp shr 16);

	      inc(i, 2);


	      if (Tok[i + 1].Kind = TTokenKind.IDENTTOK) and (Tok[i + 2].Kind = TTokenKind.OBRACKETTOK) then begin		// record^.label[x]

	       inc(i);

	       ValType := Ident[GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i].Name)].AllocElementType;

	       i := CompileArrayIndex(i, GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i].Name));

	       Push(Ident[IdentIndex].Value, ASPOINTERTORECORDARRAYORIGIN, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);

	      end else

	      if ValType = TDataType.STRINGPOINTERTOK then
	        Push(Ident[IdentIndex].Value, ASPOINTERTORECORD, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff)	// record^.string
	      else
	        Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);	// record_lebel.field^

	     end else
	     // fake code, do nothing ;)
	      Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(ValType), IdentIndex);			// record_label^

	    end else
	     if Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK then
	       Push(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(ValType), IdentIndex)
	     else
	       Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, GetDataSize(ValType), IdentIndex);

// LUCI
	    Result := i + 1;
	    end
	else

// -----------------------------------------------------------------------------
// ===				 array [index].
// -----------------------------------------------------------------------------

	if Tok[i + 1].Kind = TTokenKind.OBRACKETTOK then			// Array element access
	  if not (Ident[IdentIndex].DataType in Pointers) {or ((Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].idType <> TTokenKind.PCHARTOK))} then  // PByte, PWord
	    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
	  else
	    begin

  	    i := CompileArrayIndex(i, IdentIndex);							// array[ ].field

	    ValType := Ident[IdentIndex].AllocElementType;

	    if Tok[i + 2].Kind = TTokenKind.DEREFERENCETOK then begin

//	writeln(valType,' / ',Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_);

	     Push(0, ASPOINTERTORECORDARRAYORIGIN, GetDataSize(ValType), IdentIndex, 0);

	     inc(i);
	    end else

            if (Tok[i + 2].Kind = TTokenKind.DOTTOK) and (ValType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

//	writeln(valType,' / ',Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Tok[i + 3].Kind );

	     CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	     CheckTok(i + 3, TTokenKind.IDENTTOK);
	     IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);

	     if IdentTemp < 0 then
                    Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember, 'Identifier idents no member ''{0}''.',
                      Tok[i + 3].Name));

	     ValType := TDataType(IdentTemp shr 16);

	     inc(i, 2);


	     if (Tok[i + 1].Kind = TTokenKind.IDENTTOK) and (Tok[i + 2].Kind = TTokenKind.OBRACKETTOK) then begin		// array_of_record_pointers[x].array[i]

	       inc(i);

	       ValType := Ident[GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i].Name)].AllocElementType;

 	       IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;


	      if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

//	writeln(ValType,',',Ident[IdentIndex].Name + '||' + Tok[i].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_ );

	       IdentTemp := RecordSize(IdentIndex, Tok[i].Name);

	       if IdentTemp < 0 then
                        Error(i, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                          'Identifier idents no member ''{0}''.', Tok[i].Name));

	       ValType := Ident[GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i].Name)].AllocElementType;

	       IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

	      end;


	       i := CompileArrayIndex(i, GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i].Name));

	       Push(Ident[IdentIndex].Value, IndirectionLevel, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);

	     end else

	     if ValType = TDataType.STRINGPOINTERTOK then 							// array_of_record_pointers[index].string
 	       Push(0, ASPOINTERTOARRAYRECORDTOSTRING, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff)
	     else
 	       Push(0, ASPOINTERTOARRAYRECORD, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);


	    end else
	    if (Tok[i + 2].Kind = TTokenKind.OBRACKETTOK) and (ValType = TDataType.STRINGPOINTERTOK) then begin

	     Error(i, TMessage.Create(TErrorCode.UnderConstruction, 'Under construction' ) );
{
	     ValType := TTokenKind.CHARTOK;
	     inc(i, 3);

	     Push(2, ASVALUE, 2);

	     GenerateBinaryOperation(PLUSTOK, TTokenKind.WORDTOK);
}
	    end else begin

// -----------------------------------------------------------------------------
// 				 record.
// record_ptr.label[index] traktowane jest jako 'record_ptr.label'
// zamiast 'record_ptr'
// -----------------------------------------------------------------------------

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_);

	    IdentTemp := 0;

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN2;


	    if (pos('.', Ident[IdentIndex].Name) > 0) then begin   			// record_ptr.field[index]

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].AllocElementType );

	      IdentTemp := GetIdentIndex( copy(Ident[IdentIndex].Name, 1, pos('.', Ident[IdentIndex].Name)-1) );

	      if (Ident[IdentTemp].DataType = TDataType.POINTERTOK) and (Ident[IdentTemp].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

	       svar := copy(Ident[IdentIndex].Name, pos('.', Ident[IdentIndex].Name)+1, length(Ident[IdentIndex].Name));

	       IdentIndex := IdentTemp;

	       IdentTemp := RecordSize(IdentIndex, svar);

	       if IdentTemp < 0 then
                        Error(i + 3, TMessage.Create(TErrorCode.IdentifierIdentsNoMember,
                          'Identifier idents no member ''{0}''.', svar));

	       IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

//	       Push(Ident[IdentIndex].Value, ASPOINTERTORECORDARRAYORIGIN, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);

	      end;

	    end;


	    if ValType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then ValType := TDataType.POINTERTOK;

	    Push(Ident[IdentIndex].Value, IndirectionLevel, GetDataSize(ValType), IdentIndex, IdentTemp and $ffff);

	    CheckTok(i + 1, TTokenKind.CBRACKETTOK);

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


	  if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) and (Ident[IdentIndex].NumAllocElements = 0) then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].idType,'/',Ident[IdentIndex].Kind,' = ',Ident[IdentIndex].PassMethod ,' | ',ValType,',',Tok[j].kind,',',Tok[j+1].kind);

	   ValType := Ident[IdentIndex].AllocElementType;

	   if (ValType = TDataType.CHARTOK) then

	    case Ident[IdentIndex].DataType of
	            TTokenKind.POINTERTOK : ValType := TTokenKind.PCHARTOK;
	      TTokenKind.STRINGPOINTERTOK : ValType := TTokenKind.STRINGPOINTERTOK;
	    end;


	   if ValType = TDataType.UNTYPETOK then ValType := Ident[IdentIndex].DataType;	// RECORD.

	  end else
	   ValType := Ident[IdentIndex].DataType;


// LUCI
//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].idType,'/',Ident[IdentIndex].Kind,' = ',Ident[IdentIndex].PassMethod ,' | ',ValType,',',Tok[j].kind,',',Tok[j+1].kind);


	  if (ValType = ENUMTYPE) and (Ident[IdentIndex].DataType = ENUMTYPE) then
	    ValType := Ident[IdentIndex].AllocElementType;


//	  if ValType in IntegerTypes then
//	    if GetDataSize(ValType) > GetDataSize( TDataType.VarType] then ValType := VarType;     // skracaj typ danych    !!! niemozliwe skoro VarType = TDataType.INTEGERTOK


	  if (Ident[IdentIndex].Kind = CONSTANT) and (ValType in Pointers) then
	   ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	  else
	   ConstVal := Ident[IdentIndex].Value;


	    if (ValType in IntegerTypes) and (VarType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) then ConstVal:=FromInt64(ConstVal);

	    if (VarType = TDataType.HALFSINGLETOK) {or (ValType = TDataType. TTokenKind.HALFSINGLETOK)} then begin
	      ConstVal:=CastToHalfSingle(ConstVal);
	      //ValType := TTokenKind. TTokenKind.HALFSINGLETOK;
	    end;

	    if (VarType = TDataType.SINGLETOK) then begin
	      ConstVal:=CastToSingle(ConstVal);
	      //ValType := TTokenKind.SINGLETOK;
	    end;



	  if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) and (Ident[IdentIndex].NumAllocElements > 0) and
	     (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in Pointers) and (Ident[IdentIndex].idType = TDataType.DATAORIGINOFFSET) then

	   Push(ConstVal, ASPOINTERTORECORD, GetDataSize(ValType), IdentIndex)
	  else
	  if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) and (Ident[IdentIndex].NumAllocElements = 0) then
	   Push(ConstVal, ASPOINTERTOPOINTER, GetDataSize(ValType), IdentIndex)
	  else
	  {if Ident[IdentIndex].IdType = TDataType.DEREFERENCETOK then		// !!! test-record\record_dereference_as_val.pas !!!
	   Push(ConstVal, ASVALUE, GetDataSize(ValType), IdentIndex)
	  else}
	   Push(ConstVal, Ord(Ident[IdentIndex].Kind = VARIABLE), GetDataSize(ValType), IdentIndex);


	  if (BLOCKSTACKTOP = 1) then
	    if not (Ident[IdentIndex].isInit or Ident[IdentIndex].isInitialized or Ident[IdentIndex].LoopVariable) then
	      WarningVariableNotInitialized(i, IdentIndex);

	  end else begin	// isError

	   if (ValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) or (VarType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) then begin	// constants

	    if ValType in IntegerTypes then ConstVal:=FromInt64(ConstVal);

	    if (VarType = TDataType.HALFSINGLETOK) or (ValType = TDataType.HALFSINGLETOK) then begin
	      ConstVal := CastToHalfSingle(ConstVal);
	      ValType := TDataType.HALFSINGLETOK;
	    end else begin
	      ConstVal := CastToSingle(ConstVal);
	      ValType := TTokenKind.SINGLETOK;
	    end;

	   end;

	   Push(ConstVal, ASVALUE, GetDataSize(ValType));

	  end;

	  isConst := false;
	  isError := false;

	  Result := i;
	  end;

	end
    else
      Error(i, TErrorCode.UnknownIdentifier);
    end;


  TTokenKind.ADDRESSTOK:
    Result := CompileAddress(i-1, ValType, AllocElementType);


  TTokenKind.INTNUMBERTOK:
    begin

    ConstVal := Tok[i].Value;
    ValType := GetValueType(ConstVal);

    if VarType in RealTypes then begin
     ConstVal:=FromInt64(ConstVal);

     if VarType = TDataType.HALFSINGLETOK then
      ConstVal := CastToHalfSingle(ConstVal)
     else
     if VarType = TDataType.SINGLETOK then
      ConstVal := CastToSingle(ConstVal);

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, GetDataSize(ValType));

    isZero := (ConstVal = 0);

    Result := i;
    end;


  TTokenKind.FRACNUMBERTOK:
    begin

    constVal:=FromSingle(Tok[i].FracValue);

    ValType := TTokenKind.REALTOK;

    if VarType in RealTypes then begin

     case VarType of
   	    TTokenKind.SINGLETOK: ConstVal := CastToSingle(ConstVal);
	 TTokenKind.HALFSINGLETOK: ConstVal := CastToHalfSingle(ConstVal);
     else
       ConstVal := CastToReal(ConstVal);
     end;

     ValType := VarType;
    end;

    Push(ConstVal, ASVALUE, GetDataSize(ValType));

    isZero := (ConstVal = 0);

    Result := i;
    end;


  TTokenKind.STRINGLITERALTOK:
    begin
    Push(Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE, ASVALUE, GetDataSize( TDataType.STRINGPOINTERTOK));
    ValType := TTokenKind.STRINGPOINTERTOK;

    Result := i;
    end;


  TTokenKind.CHARLITERALTOK:
    begin
    Push(Tok[i].Value, ASVALUE, GetDataSize( TDataType.CHARTOK));
    ValType := TTokenKind.CHARTOK;
    Result := i;
    end;


  TTokenKind.OPARTOK:       // a whole expression in parentheses suspected
    begin
    j := CompileExpression(i + 1, ValType, VarType);

    CheckTok(j + 1, TTokenKind.CPARTOK);

    Result := j + 1;
    end;


  TTokenKind.NOTTOK:
    begin
    Result := CompileFactor(i + 1, isZero, ValType, TTokenKind.INTEGERTOK);
    CheckOperator(i, TTokenKind.NOTTOK, ValType);
    GenerateUnaryOperation(TTokenKind.NOTTOK, Valtype);
    end;


  TTokenKind.SHORTREALTOK:					// SHORTREAL	fixed-point	Q8.8
    begin

//    CheckTok(i + 1, TTokenKind.OPARTOK);

   if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
    Error(i, TMessage.Create(TErrorCode.TypeIdentifierNotAllowed, 'Type identifier not allowed here'));

    j := CompileExpression(i + 2, ValType);//, TTokenKind.SHORTREALTOK);

// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = TTokenKind.DEREFERENCETOK then begin

     if ValType = TDataType.POINTERTOK then begin

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
      Error(j + 1, TErrorCode.IllegalQualifier);

    end else begin

    if ValType in IntegerTypes + RealTypes then begin

     ExpandParam(TDataType.SMALLINTTOK, ValType);

     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta :STACKORIGIN,x');

    end else
            Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeConversion, 'Illegal type conversion: "{0}" to "{1}".',
              InfoAboutToken(ValType), InfoAboutToken(TTokenKind.SHORTREALTOK)));

    end;

    CheckTok(j + 1, TTokenKind.CPARTOK);

    ValType := TTokenKind.SHORTREALTOK;

    Result := j + 1;
    end;


  TTokenKind.REALTOK:					// REAL		fixed-point	Q24.8
    begin

//    CheckTok(i + 1, TTokenKind.OPARTOK);

   if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
    Error(i, TMessage.Create(TErrorCode.TypeIdentifierNotAllowed, 'Type identifier not allowed here.'));

    j := CompileExpression(i + 2, ValType);//, TTokenKind.REALTOK);


// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = TTokenKind.DEREFERENCETOK then begin

     if ValType = TDataType.POINTERTOK then begin

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
      Error(j + 1, TErrorCode.IllegalQualifier);

   end else begin

    if ValType in IntegerTypes + RealTypes then begin

     ExpandParam(TDataType.INTEGERTOK, ValType);

     asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
     asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'lda #$00');
     asm65(#9'sta :STACKORIGIN,x');

    end else
            Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeConversion, 'Illegal type conversion: "{0}" to "{1}".',
              InfoAboutToken(ValType), InfoAboutToken(TDataType.REALTOK)));

    end;

    CheckTok(j + 1, TTokenKind.CPARTOK);

    ValType := TTokenKind.REALTOK;

    Result := j + 1;
    end;


 TDataType.HALFSINGLETOK:
   begin

   if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
          Error(i, TMessage.Create(TErrorCode.TypeIdentifierNotAllowed, 'Type identifier not allowed here'));

    j := CompileExpression(i + 2, ValType);

// ASPOINTERTODEREFERENCE

    if Tok[j + 1].Kind = TTokenKind.DEREFERENCETOK then begin

     if ValType = TDataType.POINTERTOK then begin

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
      Error(j + 1, TErrorCode.IllegalQualifier);

    end else begin

    if ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK] then
     Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeConversion, 'Illegal type conversion: "{0}" to "{1}".', InfoAboutToken(ValType),InfoAboutToken( TTokenKind.HALFSINGLETOK)));


    if ValType in IntegerTypes + RealTypes then begin

     ExpandParam(TDataType.INTEGERTOK, ValType);

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
      Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken( TTokenKind.HALFSINGLETOK) + '"');

    end;

    CheckTok(j + 1, TTokenKind.CPARTOK);

    ValType := TDataType.HALFSINGLETOK;

    Result := j + 1;

   end;


  TTokenKind.SINGLETOK:					// SINGLE	IEEE-754	Q32
    begin

//    CheckTok(i + 1, TTokenKind.OPARTOK);

   if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
    Error(i, 'type identifier not allowed here');

 	j := i + 2;

	if SafeCompileConstExpression(j, ConstVal, ValType, TTokenKind.SINGLETOK) then begin

	  if not(ValType in RealTypes) then ConstVal:=FromInt64(ConstVal);

	  ConstVal:=CastToSingle(ConstVal);

	  ValType := TTokenKind.SINGLETOK;

	  Push(ConstVal, ASVALUE, GetDataSize(ValType));

	end else begin
	  j := CompileExpression(i + 2, ValType);

// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = TTokenKind.DEREFERENCETOK then begin

     if ValType = TDataType.POINTERTOK then begin

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
      Error(j + 1, TErrorCode.IllegalQualifier);


   end else begin

	  if ValType in [TDataType.SHORTREALTOK, TTokenKind.REALTOK] then
	   Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' + InfoAboutToken(TDataType.SINGLETOK) + '"');


	  if ValType in IntegerTypes + RealTypes then begin

		ExpandParam(TDataType.INTEGERTOK, ValType);

		//asm65(#9'jsr @I2F');

		asm65(#9'lda :STACKORIGIN,x');
		asm65(#9'sta :FPMAN0');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'sta :FPMAN1');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'sta :FPMAN2');
		asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		asm65(#9'sta :FPMAN3');

		asm65(#9'jsr @I2F');

		asm65(#9'lda :FPMAN0');
		asm65(#9'sta :STACKORIGIN,x');
		asm65(#9'lda :FPMAN1');
		asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		asm65(#9'lda :FPMAN2');
		asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
		asm65(#9'lda :FPMAN3');
		asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

	  end else
	   Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "'+InfoAboutToken(TDataType.SINGLETOK) + '"');

   end;

	end;

    CheckTok(j + 1, TTokenKind.CPARTOK);

    ValType := TTokenKind.SINGLETOK;

    Result := j + 1;

    end;


  TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK, TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK, TTokenKind.CHARTOK, TTokenKind.PCHARTOK, TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK, TTokenKind.BOOLEANTOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK:	// type conversion operations
    begin

   if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
    Error(i, 'type identifier not allowed here');


    j := CompileExpression(i + 2, ValType, Tok[i].Kind);


    if (ValType in Pointers) and (Tok[i + 2].Kind = TTokenKind.IDENTTOK) and (Tok[i + 3].Kind <> TTokenKind.OBRACKETTOK) then begin

      IdentIndex := GetIdentIndex(Tok[i + 2].Name);

      if (Ident[IdentIndex].DataType in Pointers) and ( (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> TTokenKind.RECORDTOK) ) then
       if ((Ident[IdentIndex].AllocElementType <> TTokenKind.UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0,1])) or (Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK) then

       else
	ErrorIdentifierIllegalTypeConversion(i + 2, IdentIndex, Tok[i].Kind);

    end;


// ASPOINTERTODEREFERENCE

   if Tok[j + 1].Kind = TTokenKind.DEREFERENCETOK then
     if ValType = TDataType.POINTERTOK then begin

	asm65(#9'lda :STACKORIGIN,x');
    	asm65(#9'sta :bp2');
    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    	asm65(#9'sta :bp2+1');
    	asm65(#9'ldy #$00');

	case GetDataSize( Tok[i].Kind) of

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
      Error(j + 1, TErrorCode.IllegalQualifier);


    if not(ValType in AllTypes) then
      Error(i, TErrorCode.TypeMismatch);

    ExpandParam(Tok[i].Kind, ValType);

    CheckTok(j + 1, TTokenKind.CPARTOK);

    ValType := Tok[i].Kind;


    if Tok[j + 2].Kind = TTokenKind.DEREFERENCETOK then
      if (ValType = TDataType.PCHARTOK) then begin

        ValType := TTokenKind.CHARTOK;

        inc(j);

      end else
       Error(j + 1, TErrorCode.IllegalQualifier);

    Result := j + 1;

    end;

else
  Error(i, TErrorCode.IdNumExpExpected);
end;// case

end;	//CompileFactor


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ResizeType(var ValType: TDataType);
// dla operacji SHL, MUL rozszerzamy typ dla wyniku operacji
begin

  if ValType in [TDataType.BYTETOK, TDataType.WORDTOK, TDataType.SHORTINTTOK, TDataType.SMALLINTTOK] then inc(ValType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RealTypeConversion(var ValType, RightValType: TDataType; Kind: TTokenKind = TTokenKind.UNTYPETOK);
begin

  If ((ValType = TDataType.SINGLETOK) or (Kind = TTokenKind.SINGLETOK)) and (RightValType in IntegerTypes) then begin

   ExpandParam(TDataType.INTEGERTOK, RightValType);

//   asm65(#9'jsr @I2F');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta :FPMAN0');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta :FPMAN1');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'sta :FPMAN2');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
			asm65(#9'sta :FPMAN3');

			asm65(#9'jsr @I2F');

			asm65(#9'lda :FPMAN0');
			asm65(#9'sta :STACKORIGIN,x');
			asm65(#9'lda :FPMAN1');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'lda :FPMAN2');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
			asm65(#9'lda :FPMAN3');
			asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

   if (ValType <> TTokenKind.SINGLETOK) and (Kind = TTokenKind.SINGLETOK) then
    RightValType := Kind
   else
    RightValType := ValType;
  end;


  If (ValType in IntegerTypes) and ((RightValType = TDataType.SINGLETOK) or (Kind = TTokenKind.SINGLETOK)) then begin

   ExpandParam_m1(TDataType.INTEGERTOK, ValType);

//   asm65(#9'jsr @I2F_M');

			asm65(#9'lda :STACKORIGIN-1,x');
			asm65(#9'sta :FPMAN0');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'sta :FPMAN1');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'sta :FPMAN2');
			asm65(#9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
			asm65(#9'sta :FPMAN3');

			asm65(#9'jsr @I2F');

			asm65(#9'lda :FPMAN0');
			asm65(#9'sta :STACKORIGIN-1,x');
			asm65(#9'lda :FPMAN1');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
			asm65(#9'lda :FPMAN2');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
			asm65(#9'lda :FPMAN3');
			asm65(#9'sta :STACKORIGIN-1+STACKWIDTH*3,x');

   if (RightValType <> TTokenKind.SINGLETOK) and (Kind = TTokenKind.SINGLETOK) then
    ValType := Kind
   else
    ValType := RightValType;
  end;


  If ((ValType = TDataType.HALFSINGLETOK) or (Kind = TDataType.HALFSINGLETOK)) and (RightValType in IntegerTypes) then begin

   ExpandParam(TDataType.INTEGERTOK, RightValType);

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

   if (ValType <> TDataType.HALFSINGLETOK) and (Kind = TDataType.HALFSINGLETOK) then
    RightValType := Kind
   else
    RightValType := ValType;

  end;


  If (ValType in IntegerTypes) and ((RightValType = TDataType.HALFSINGLETOK) or (Kind = TDataType.HALFSINGLETOK)) then begin

   ExpandParam_m1(TDataType.INTEGERTOK, ValType);

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


   if (RightValType <> TDataType.HALFSINGLETOK) and (Kind = TDataType.HALFSINGLETOK) then
    ValType := Kind
   else
    ValType := RightValType;
  end;


  If ((ValType in [TDataType.REALTOK, TDataType.SHORTREALTOK]) or (Kind in [TDataType.REALTOK, TDataType.SHORTREALTOK])) and (RightValType in IntegerTypes) then begin

   ExpandParam(TDataType.INTEGERTOK, RightValType);

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
   if not(ValType in [TDataType.REALTOK, TDataType.SHORTREALTOK]) and (Kind in [TTokenKind.REALTOK, TTokenKind.SHORTREALTOK]) then
    RightValType := Kind
   else
    RightValType := ValType;

  end;


  If (ValType in IntegerTypes) and ((RightValType in [TDataType.REALTOK, TDataType.SHORTREALTOK]) or (Kind in [TTokenKind.REALTOK, TTokenKind.SHORTREALTOK])) then begin

   ExpandParam_m1(TDataType.INTEGERTOK, ValType);

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

   if not(RightValType in [TDataType.REALTOK, TTokenKind.SHORTREALTOK]) and (Kind in [TTokenKind.REALTOK, TTokenKind.SHORTREALTOK]) then
    ValType := Kind
   else
    ValType := RightValType;

  end;

end;	//RealTypeConversion


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileTerm(i: Integer; out ValType: TDataType; VarType: TDataType = TDataType.INTEGERTOK): Integer;
var
  j, k, oldCodeSize: Integer;
  RightValType: TDataType;
  CastRealType: TDataType;
  oldPass: TPass;
  isZero: Boolean;
begin

 oldPass := Pass;
 oldCodeSize := CodeSize;
 Pass := TPass.CALL_DETERMINATION;

 j := CompileFactor(i, isZero, ValType, VarType);

 Pass := oldPass;
 CodeSize := oldCodeSize;


 if Tok[j + 1].Kind in [TTokenKind.MODTOK, TTokenKind.IDIVTOK, TTokenKind.SHLTOK, TTokenKind.SHRTOK, TTokenKind.ANDTOK] then
  j := CompileFactor(i, isZero, ValType, TTokenKind.INTEGERTOK)
 else begin

  if ValType in RealTypes then VarType := ValType;

  j := CompileFactor(i, isZero, ValType, VarType);

 end;

while Tok[j + 1].Kind in [TTokenKind.MULTOK, TTokenKind.DIVTOK, TTokenKind.MODTOK, TTokenKind.IDIVTOK, TTokenKind.SHLTOK, TTokenKind.SHRTOK, TTokenKind.ANDTOK] do
  begin


  if ValType in RealTypes then VarType := ValType;


  if Tok[j + 1].Kind in [TTokenKind.MULTOK, TTokenKind.DIVTOK] then
   k := CompileFactor(j + 2, isZero, RightValType, VarType)
  else
   k := CompileFactor(j + 2, isZero, RightValType, TTokenKind.INTEGERTOK);

  if (Tok[j + 1].Kind in [TTokenKind.MODTOK, TTokenKind.IDIVTOK]) and isZero then
   Error(j + 1, 'Division by zero');


  if ((ValType in [ TDataType.HALFSINGLETOK, TDataType.SINGLETOK]) and (RightValType in [TDataType.SHORTREALTOK, TDataType.REALTOK])) or
   ((ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) and (RightValType in [ TDataType.HALFSINGLETOK, TDataType.SINGLETOK])) then
    Error(j + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(RightValType)+'"');


  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  if Tok[j + 1].Kind = TTokenKind.DIVTOK then
  begin
    if VarType in RealTypes then
    begin
     CastRealType := VarType;
    end
    else
    begin
     CastRealType := TDataType.REALTOK;
    end;
   end
   else
   begin
     CastRealType := TDataType.UNTYPETOK;
   end;

  RealTypeConversion(ValType, RightValType, CastRealType);


  ValType := GetCommonType(j + 1, ValType, RightValType);

  CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);

  if not ( Tok[j + 1].Kind in [TTokenKind.SHLTOK, TTokenKind.SHRTOK] ) then				// dla SHR, SHL nie wyrownuj typow parametrow
   ExpandExpression(ValType, RightValType, TTokenKind.UNTYPETOK);

  if Tok[j + 1].Kind = TTokenKind.MULTOK then
   if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
    if GetDataSize(ValType) > GetDataSize( VarType) then ValType:=VarType;

  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  case Tok[j + 1].Kind of							// !!! tutaj a nie przed ExpandExpression
   TTokenKind.MULTOK: begin ResizeType(ValType); ExpandExpression(VarType, TDataType.UNTYPETOK, TDataType.UNTYPETOK) end;

   TTokenKind.SHRTOK: if (ValType in SignedOrdinalTypes) and (GetDataSize(ValType) > 1) then begin ResizeType(ValType); ResizeType(ValType) end;	// int:=smallint(-90100) shr 4;

   TTokenKind.SHLTOK: begin ResizeType(ValType); ResizeType(ValType) end;	 	        // !!! Silly Intro lub "x(byte) shl 14" tego wymaga
  end;

  j := k;
  end;

Result := j;
end;	//CompileTerm


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileSimpleExpression(i: Integer; out ValType: TDataType; VarType: TDataType): Integer;
var
  j, k: Integer;
  ConstVal: Int64;
  RightValType: TDataType;

begin


if Tok[i].Kind in [TTokenKind.PLUSTOK,TTokenKind.MINUSTOK] then j := i + 1 else j := i;

if SafeCompileConstExpression(j, ConstVal, ValType, VarType) then begin

 if (ValType in IntegerTypes) and (VarType in RealTypes) then
   begin ConstVal:=FromInt64(ConstVal);
         ValType := VarType
   end;

 if VarType in RealTypes then ValType := VarType;


 if Tok[i].Kind =TTokenKind.MINUSTOK then
   ConstVal:=Negate( ValType, ConstVal);

 if ValType = TDataType.SINGLETOK then begin
  ConstVal := CastToSingle(ConstVal);
 end;

 if ValType = TDataType.HALFSINGLETOK then begin
  ConstVal := CastToHalfSingle(ConstVal);
 end;


 Push(ConstVal, ASVALUE, GetDataSize(ValType));


end else begin	// if SafeCompileConstExpression

 j := CompileTerm(j, ValType, VarType);

 if Tok[i].Kind =TTokenKind.MINUSTOK then begin

  GenerateUnaryOperation(TTokenKind.MINUSTOK, ValType);	// Unary minus

  if ValType in UnsignedOrdinalTypes then	// jesli odczytalismy typ bez znaku zamieniamy na 'ze znakiem'
   if ValType = TDataType.BYTETOK then
     ValType := TTokenKind.SMALLINTTOK
   else
     ValType := TTokenKind.INTEGERTOK;

 end;

end;


while Tok[j + 1].Kind in [TTokenKind.PLUSTOK,TTokenKind.MINUSTOK,TTokenKind.ORTOK,TTokenKind.XORTOK] do
  begin

  if ValType in RealTypes then VarType := ValType;

  k := CompileTerm(j + 2, RightValType, VarType);

  if ((ValType in [ TDataType.HALFSINGLETOK, TDataType.SINGLETOK]) and (RightValType in [TDataType.SHORTREALTOK, TDataType.REALTOK])) or
     ((ValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) and (RightValType in [ TDataType.HALFSINGLETOK, TDataType.SINGLETOK])) then
      Error(j + 2, 'Illegal type conversion: "'+InfoAboutToken(ValType)+'" to "'+InfoAboutToken(RightValType)+'"');


  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);//, VarType);


  if (ValType = TDataType.POINTERTOK) and (RightValType in IntegerTypes) then begin ExpandParam(TDataType.WORDTOK, RightValType); RightValType := TDataType.POINTERTOK end;
  if (RightValType = TDataType.POINTERTOK) and (ValType in IntegerTypes) then begin ExpandParam_m1(TDataType.WORDTOK, ValType); ValType := TDataType.POINTERTOK end;


  ValType := GetCommonType(j + 1, ValType, RightValType);

  CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);


  if Tok[j + 1].Kind in [TTokenKind.PLUSTOK,TTokenKind.MINUSTOK] then begin				// dla PLUSTOK,TTokenKind.MINUSTOK rozszerz typ wyniku

    if (Tok[j + 1].Kind = TTokenKind.MINUSTOK) and (RightValType in UnsignedOrdinalTypes)
    and (VarType in SignedOrdinalTypes + [TDataType.BOOLEANTOK, TDataType.REALTOK, TDataType.HALFSINGLETOK, TDataType.SINGLETOK]) then begin

	if (ValType = VarType) and (RightValType = VarType) then
// do nothing, all types are with sign
	else
         ExpandExpression(ValType, RightValType, VarType, true);		// promote to type with sign

    end else
      ExpandExpression(ValType, RightValType, VarType);

  end else
    ExpandExpression(ValType, RightValType, TDataType.UNTYPETOK);

  if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
   if GetDataSize(ValType) > GetDataSize(VarType) then ValType:=VarType;


  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  j := k;
  end;

Result := j;
end;	//CompileSimpleExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileExpression(i: Integer; out ValType: TDataType; VarType: TDataType = TDataType.INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType, ConstValType: TDataType;
  isZero: TDataType;
  sLeft, sRight, cRight, yes: Boolean;
  ConstVal, ConstValRight: Int64;

begin

 ConstVal:=0;

 isZero := TTokenKind.INTEGERTOK;

 cRight:=false;		// constantRight

 if SafeCompileConstExpression(i, ConstVal, ValType, VarType, False) then begin

   if (ValType in IntegerTypes) and (VarType in RealTypes) then begin ConstVal:=FromInt64(ConstVal); ValType := VarType end;

   if VarType in RealTypes then ValType := VarType;


   if (ValType = TDataType.HALFSINGLETOK) {or ((VarType = TDataType.HALFSINGLETOK) and (ValType in RealTypes))} then begin
     ConstVal := CastToHalfSingle(ConstVal);
     ValType := TDataType.HALFSINGLETOK;  // Currently redundant
   end;

   if (ValType = TDataType.SINGLETOK) {or ((VarType = TDataType.SINGLETOK) and (ValType in RealTypes))} then begin
     ConstVal:=CastToSingle(ConstVal);
     ValType := TTokenKind.SINGLETOK; // Currently redundant
   end;

   Push(ConstVal, ASVALUE, GetDataSize(ValType));

   Result := i;
   exit;
 end;

ConstValRight := 0;

sLeft:=false;		// stringLeft
sRight:=false;		// stringRight


i := CompileSimpleExpression(i, ValType, VarType);


if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) or (ValType = TDataType.STRINGPOINTERTOK) then sLeft:=true else
 if (ValType in Pointers) and (Tok[i].Kind = TTokenKind.IDENTTOK) then
  if (Ident[GetIdentIndex(Tok[i].Name)].AllocElementType = TDataType.CHARTOK) and (Elements(GetIdentIndex(Tok[i].Name)) > 0) then sLeft:=true;


if Tok[i + 1].Kind = TTokenKind.INTOK then writeln('IN');				// not yet programmed


if Tok[i + 1].Kind in [TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LTTOK, TTokenKind.LETOK, TTokenKind.GTTOK, TTokenKind.GETOK] then
  begin


  if ValType in RealTypes then VarType := ValType;


  j := CompileSimpleExpression(i + 2, RightValType, VarType);


  k := i + 2;
  if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
   if (ConstValType in IntegerTypes) and (VarType in IntegerTypes + [TDataType.BOOLEANTOK]) then begin

    if ConstVal = 0 then begin
      isZero := TTokenKind.BYTETOK;

      if (ValType in SignedOrdinalTypes) and (Tok[i + 1].Kind in [TTokenKind.EQTOK, TTokenKind.NETOK]) then begin

	case ValType of
	 TTokenKind.SHORTINTTOK: ValType := TTokenKind.BYTETOK;
	 TTokenKind.SMALLINTTOK: ValType := TTokenKind.WORDTOK;
	  TTokenKind.INTEGERTOK: ValType := TTokenKind.CARDINALTOK;
	end;

      end;

    end;


    if ConstValType in SignedOrdinalTypes then
     if ConstVal < 0 then isZero := TTokenKind.SHORTINTTOK;

    cRight := true;

    ConstValRight := ConstVal;
    RightValType  := ConstValType;

   end;		// if ConstValType in IntegerTypes



  if (Tok[i + 2].Kind = TTokenKind.STRINGLITERALTOK) or (RightValType = TDataType.STRINGPOINTERTOK) then sRight:=true else
   if (RightValType in Pointers) and (Tok[i + 2].Kind = TTokenKind.IDENTTOK) then
    if (Ident[GetIdentIndex(Tok[i + 2].Name)].AllocElementType = TDataType.CHARTOK) and (Elements(GetIdentIndex(Tok[i + 2].Name)) > 0) then sRight:=true;


//  if (ValType in [SHORTREALTOK, TTokenKind.REALTOK]) and (RightValType in [SHORTREALTOK, TTokenKind.REALTOK]) then
//    RightValType := ValType;

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);//, VarType);

//  writeln(VarType,  ' | ', ValType,'/',RightValType,',',isZero,',',Tok[i + 1].Kind ,' : ', ConstVal);


  if cRight and (Tok[i + 1].Kind in [TTokenKind.LTTOK, TTokenKind.GTTOK]) and (ValType in IntegerTypes) then begin

   yes:=false;

   if Tok[i + 1].Kind = TTokenKind.LTTOK then begin

    case ValType of
     TTokenKind.BYTETOK, TTokenKind.WORDTOK, TTokenKind.CARDINALTOK: yes := (isZero = TTokenKind.BYTETOK);
//         TTokenKind.BYTETOK: yes := (ConstVal = Low(byte));	// < 0
//         TTokenKind.WORDTOK: yes := (ConstVal = Low(word));	// < 0
//     TTokenKind.CARDINALTOK: yes := (ConstVal = Low(cardinal));	// < 0
     TTokenKind.SHORTINTTOK: yes := (ConstVal = Low(shortint));	// < -128
     TTokenKind.SMALLINTTOK: yes := (ConstVal = Low(smallint));	// < -32768
      TTokenKind.INTEGERTOK: yes := (ConstVal = Low(integer));	// < -2147483648
    end;

   end else

    case ValType of
         TTokenKind.BYTETOK: yes := (ConstVal = High(byte));	// > 255
         TTokenKind.WORDTOK: yes := (ConstVal = High(word));	// > 65535
     TTokenKind.CARDINALTOK: yes := (ConstVal = High(cardinal));	// > 4294967295
     TTokenKind.SHORTINTTOK: yes := (ConstVal = High(shortint));	// > 127
     TTokenKind.SMALLINTTOK: yes := (ConstVal = High(smallint));	// > 32767
      TTokenKind.INTEGERTOK: yes := (ConstVal = High(integer));	// > 2147483647
    end;

   if yes then begin
     WarningAlwaysFalse(i + 2);
     WarningUnreachableCode(i + 2);
   end;

  end;


  if (isZero = TTokenKind.BYTETOK) and (ValType in UnsignedOrdinalTypes) then
   case Tok[i + 1].Kind of
//  TTokenKind.LTTOK: WarningAlwaysFalse(i + 2);		         // BYTE, WORD, CARDINAL '<' 0
    TTokenKind.GETOK: WarningAlwaysTrue(i + 2);			// BYTE, WORD, CARDINAL '>', '>=' 0
   end;


  if (isZero = TTokenKind.SHORTINTTOK) and (ValType in UnsignedOrdinalTypes) then
   case Tok[i + 1].Kind of

    TTokenKind.EQTOK, TTokenKind.LTTOK, TTokenKind.LETOK: begin				// BYTE, WORD, CARDINAL '=', '<'. '<=' -X
			  WarningAlwaysFalse(i + 2);
			  WarningUnreachableCode(i + 2);
			 end;

	   TTokenKind.GTTOK, TTokenKind.GETOK: WarningAlwaysTrue(i + 2);	// BYTE, WORD, CARDINAL '>', '>=' -X
   end;


//  writeln(ValType,',',RightValType,' / ',ConstValRight);

  if sLeft or sRight then   else   GetCommonType(j, ValType, RightValType);


  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;


// !!! wyjatek !!! porownanie typow tego samego rozmiaru, ale z roznymi znakami

   if ((ValType in SignedOrdinalTypes) and (RightValType in UnsignedOrdinalTypes)) or ((ValType in UnsignedOrdinalTypes) and (RightValType in SignedOrdinalTypes)) then
   if GetDataSize(ValType) = GetDataSize(RightValType) then
   { if ValType in UnsignedOrdinalTypes then} begin

     case GetDataSize(ValType) of
      1: begin

	  if cRight and ( (ConstValRight >= Low(shortint)) and (ConstValRight <= High(shortint)) ) then		// gdy nie przekracza zakresu dla typu SHORTINT
	   RightValType:=ValType
	  else begin
	   ExpandParam_m1(TDataType.SMALLINTTOK, ValType);
	   ExpandParam(TDataType.SMALLINTTOK, RightValType);
	   ValType:=TDataType.SMALLINTTOK; RightValType:=TDataType.SMALLINTTOK;
	  end;

	 end;

      2: begin

	  if cRight and ( (ConstValRight >= Low(smallint)) and (ConstValRight <= High(smallint)) ) then		// gdy nie przekracza zakresu dla typu SMALLINT
	   RightValType:=ValType
	  else begin
	   ExpandParam_m1(TDataType.INTEGERTOK, ValType);
	   ExpandParam(TDataType.INTEGERTOK, RightValType);
	   ValType:=TDataType.INTEGERTOK; RightValType:=TDataType.INTEGERTOK;
	  end;

	 end;
     end;

    end;

  ExpandExpression(ValType, RightValType, TDataType.UNTYPETOK);

  if sLeft or sRight then begin

   if sLeft and sRight then
    GenerateRelationString(Tok[i + 1].Kind, TTokenKind.STRINGPOINTERTOK, TTokenKind.STRINGPOINTERTOK)
   else
   if ValType = TDataType.CHARTOK then
    GenerateRelationString(Tok[i + 1].Kind, TTokenKind.CHARTOK, TTokenKind.STRINGPOINTERTOK)
   else
   if RightValType = TDataType.CHARTOK then
    GenerateRelationString(Tok[i + 1].Kind, TTokenKind.STRINGPOINTERTOK, TTokenKind.CHARTOK)
   else
    GetCommonType(j, ValType, RightValType);

  end else
   GenerateRelation(Tok[i + 1].Kind, ValType);

  i := j;

  ValType:=TDataType.BOOLEANTOK;
  end;

Result := i;
end;	//CompileExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveBreakAddress;
begin

  Inc(BreakPosStackTop);

  BreakPosStack[BreakPosStackTop].ptr := CodeSize;
  BreakPosStack[BreakPosStackTop].brk := false;
  BreakPosStack[BreakPosStackTop].cnt := false;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RestoreBreakAddress;
begin

  if BreakPosStack[BreakPosStackTop].brk then asm65('b_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

  dec(BreakPosStackTop);

  ResetOpty;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileBlockRead(var i: integer; IdentIndex: integer; IdentBlock: integer): integer;
var NumActualParams, idx: integer;
    ActualParamType, AllocElementType: TDataType;

begin

   NumActualParams := 0;
   AllocElementType := TDataType.UNTYPETOK;

     repeat
       Inc(NumActualParams);

       StartOptimization(i);

       if NumActualParams > 3 then
	ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentBlock);

       if fBlockRead_ParamType[NumActualParams] in Pointers + [TDataType.UNTYPETOK] then begin

	if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	 Error(i + 2, TErrorCode.VariableExpected)
	else begin
	 idx:=GetIdentIndex(Tok[i + 2].Name);


	if (Ident[idx].Kind = TTokenKind.CONSTTOK)	then begin

	 if not (Ident[idx].DataType in Pointers) or (Elements(idx) = 0) then
	  Error(i + 2, TErrorCode.VariableExpected);

	end else

	 if (Ident[idx].Kind <> TTokenKind.VARTOK) then
	  Error(i + 2, TErrorCode.VariableExpected);

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

     until Tok[i + 1].Kind <> TTokenKind.COMMATOK;

     if NumActualParams < 2 then
       ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentBlock);

     CheckTok(i + 1, TTokenKind.CPARTOK);

     inc(i);

     Result := NumActualParams;

end;	//CompileBlockRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckAssignment(i: integer; IdentIndex: integer);
begin

 if Ident[IdentIndex].PassMethod = TParameterPassingMethod.CONSTPASSING then
   Error(i, 'Can''t assign values to const variable');

 if Ident[IdentIndex].LoopVariable then
   Error(i, 'Illegal assignment to for-loop variable '''+Ident[IdentIndex].Name+'''');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileStatement(i: Integer; isAsm: Boolean = false): Integer;
var
  j, k, IdentIndex, IdentTemp, NumActualParams, NumCharacters,
  IfLocalCnt, CaseLocalCnt, NumCaseStatements, vlen: Integer;
  oldPass: TPass; oldCodeSize: integer;
  Param: TParamList;
  IndirectionLevel: Byte;
  ExpressionType, ActualParamType, ConstValType, VarType, SelectorType: TDataType;
  Value, ConstVal, ConstVal2: Int64;
  Down, ExitLoop, yes, DEREFERENCE, ADDRESS: Boolean;			  // To distinguish TO / DOWNTO loops
  CaseLabelArray: TCaseLabelArray;
  CaseLabel: TCaseLabel;
  forLoop: TForLoop;
  Name, EnumName, svar, par1, par2: string;
  forBPL: byte;
begin

Result:=i;

//FillChar(Param, sizeof(Param), 0);
Param:=Default(TParamList);

IdentIndex := 0;
ExpressionType := TDataType.UNTYPETOK;

par1:='';
par2:='';

StopOptimization;


case Tok[i].Kind of

  TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK, TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK, TTokenKind.CHARTOK, TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK, TTokenKind.BOOLEANTOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.SHORTREALTOK, TTokenKind.REALTOK, TTokenKind.SINGLETOK, TDataType.HALFSINGLETOK :	// type conversion operations
    begin

     if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i, 'type identifier not allowed here');

     StartOptimization(i + 1);

     if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
      Error(i + 2, TErrorCode.VariableExpected)
     else
      IdentIndex := GetIdentIndex(Tok[i + 2].Name);

     VarType := Ident[IdentIndex].DataType;

     if VarType <> Tok[i].Kind then
      Error(i, 'Argument cannot be assigned to');

     CheckTok(i + 3, TTokenKind.CPARTOK);

     if Tok[i + 4].Kind <> TTokenKind.ASSIGNTOK then
      Error(i + 4, TErrorCode.IllegalExpression);

     i := CompileExpression(i + 5, ExpressionType, VarType);

     GenerateAssignment(ASPOINTER, GetDataSize( VarType), IdentIndex);

     Result := i;

   end;


  TTokenKind.IDENTTOK:
    begin
     IdentIndex := GetIdentIndex(Tok[i].Name);

    if (IdentIndex > 0) and (Ident[IdentIndex].Kind = TTokenKind.FUNCTIONTOK) and (BlockStackTop > 1) and (Tok[i + 1].Kind <> TTokenKind.OPARTOK) then
     for j:=NumIdent downto 1 do
      if (Ident[j].ProcAsBlock = NumBlocks) and (Ident[j].Kind = TTokenKind.FUNCTIONTOK) then begin
	if (Ident[j].Name = Ident[IdentIndex].Name) and (Ident[j].UnitIndex = Ident[IdentIndex].UnitIndex) then IdentIndex := GetIdentResult(NumBlocks);
	Break;
      end;


    if IdentIndex > 0 then

      case Ident[IdentIndex].Kind of


	LABELTYPE:
	  begin
	   CheckTok(i + 1, TTokenKind.COLONTOK);

	   if Ident[IdentIndex].isInit then
	     Error(i , 'Label already defined');

	   Ident[IdentIndex].isInit := true;

	   asm65(Ident[IdentIndex].Name);

	   Result := i;

	  end;


	VARIABLE, TTokenKind.TYPETOK:								// Variable or array element assignment
	  begin

	   VarType:=TDataType.UNTYPETOK;

	   StartOptimization(i + 1);


	   if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType = TDataType.PROCVARTOK) and ( not (Tok[i + 1].Kind in [TTokenKind.ASSIGNTOK, TTokenKind.OBRACKETTOK]) ) then begin

	        IdentTemp := GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		CompileActualParameters(i, IdentTemp, IdentIndex);

		Result := i;
		exit;

	   end;



           if Ident[IdentIndex].IdType = TDataType.DATAORIGINOFFSET then begin

	     IdentTemp:=GetIdentIndex( ExtractName(IdentIndex, Ident[IdentIndex].Name) );

	     if (Ident[IdentTemp].NumAllocElements_ > 0) and (Ident[IdentTemp].DataType = TDataType.POINTERTOK)
             and (Ident[IdentTemp].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
	       Error(i, TErrorCode.IllegalQualifier);

//	     writeln(Ident[IdentTemp].name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements_);

	   end;



           IndirectionLevel := ASPOINTERTOPOINTER;

           if Tok[i + 1].Kind = TTokenKind.OPARTOK then begin				// (pointer)

//	writeln('= ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

	    if not (Ident[IdentIndex].DataType in [TDataType.POINTERTOK, TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
	      Error(i, TErrorCode.IllegalExpression);

	    if Ident[IdentIndex].DataType = TDataType.POINTERTOK then
	      VarType := Ident[IdentIndex].AllocElementType
	    else
	      VarType := Ident[IdentIndex].DataType;


            i := CompileExpression(i + 2, ExpressionType, TTokenKind.POINTERTOK);

            CheckTok(i + 1, TTokenKind.CPARTOK);


	    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (Tok[i + 2].Kind = TTokenKind.DOTTOK) then begin

	      IndirectionLevel := ASPOINTERTODEREFERENCE;

	      CheckTok(i + 3, TTokenKind.IDENTTOK);
	      IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);		// (pointer^).field :=

	      if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name+'''');

	      VarType := TDataType(IdentTemp shr 16);
	      par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	      inc(i, 2);

	    end else

            if Tok[i + 2].Kind = TTokenKind.DEREFERENCETOK then begin

	     IndirectionLevel := ASPOINTERTODEREFERENCE;

	     inc(i);

	     if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (Tok[i + 2].Kind = TTokenKind.DOTTOK) then begin

	       CheckTok(i + 3, TTokenKind.IDENTTOK);
	       IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);		// (pointer)^.field :=

	       if IdentTemp < 0 then
	         Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name+'''');

	       VarType := TDataType(IdentTemp shr 16);
	       par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	       inc(i, 2);

	     end;


	    end else begin

	     if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (Tok[i + 2].Kind = TTokenKind.DOTTOK) then begin

	       IndirectionLevel := ASPOINTERTODEREFERENCE;

	       CheckTok(i + 3, TTokenKind.IDENTTOK);
	       IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);		// (pointer).field :=

	       if IdentTemp < 0 then
	         Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name+'''');

	       VarType := TDataType(IdentTemp shr 16);
	       par2 := '$'+IntToHex(IdentTemp and $ffff, 2);

	       inc(i, 2);

	     end;


	    end;


	    inc(i);


	   end else

	   if Tok[i + 1].Kind = TTokenKind.DEREFERENCETOK then				// With dereferencing '^'
	    begin

	    if not (Ident[IdentIndex].DataType in Pointers) then
	      ErrorForIdentifier(i + 1, TErrorCode.IncompatibleTypeOf, IdentIndex);

	    if (Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	      VarType := TTokenKind.STRINGPOINTERTOK
	    else
 	      VarType := Ident[IdentIndex].AllocElementType;

	    IndirectionLevel := ASPOINTERTOPOINTER;


//	writeln('= ',Ident[IdentIndex].name,',',VarTYpe,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements);


	    if Tok[i + 2].Kind = TTokenKind.OBRACKETTOK then begin				// pp^[index] :=

	     inc(i);

	     if not (Ident[IdentIndex].DataType in Pointers) then
	       ErrorForIdentifier(i + 1, TErrorCode.IncompatibleTypeOf, IdentIndex);

	     IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	     i := CompileArrayIndex(i, IdentIndex);

	     CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	    end else

	    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (Tok[i + 2].Kind = TTokenKind.DOTTOK) then begin

	     CheckTok(i + 3, TTokenKind.IDENTTOK);
	     IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);

	     if IdentTemp < 0 then
	      Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name+'''');


	    if Tok[i + 4].Kind = TTokenKind.OBRACKETTOK then begin				// pp^.field[index] :=

	     if not (Ident[IdentIndex].DataType in Pointers) then
	       ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	     VarType := Ident[GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name)].AllocElementType;
	     par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	     IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

	     i := CompileArrayIndex(i + 3, GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name));

	     CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	    end else begin							// pp^.field :=

	     VarType := TDataType(IdentTemp shr 16);
	     par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	     if GetIdentIndex(Ident[IdentIndex].name+'.'+Tok[i + 3].Name) > 0 then IdentIndex := GetIdentIndex(Ident[IdentIndex].name+'.'+Tok[i + 3].Name);

	     inc(i, 2);

	    end;

	    end;

	    i := i + 1;
	    end
	  else if (Tok[i + 1].Kind = TTokenKind.OBRACKETTOK) then				// With indexing
	    begin

	    if not (Ident[IdentIndex].DataType in Pointers) then
	      ErrorForIdentifier(i + 1, TErrorCode.IncompatibleTypeOf, IdentIndex);

	    IndirectionLevel :=  ASPOINTERTOARRAYORIGIN2;

	    j := i;

	    i := CompileArrayIndex(i, IdentIndex);

    	    VarType := Ident[IdentIndex].AllocElementType;


//	    writeln(Ident[IdentIndex].Name,',',vartype,' | ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', Tok[i+2].Kind);


	    if Tok[i + 2].Kind = TTokenKind.DEREFERENCETOK then begin
	     inc(i);

	     Push(0, ASPOINTERTOARRAYORIGIN2, GetDataSize( VarType ), IdentIndex, 0);

	    end;

										// label.field[index] -> label + field[index]

	    if pos('.', Ident[IdentIndex].Name) > 0 then begin			// record_ptr.field[index] :=

	      IdentTemp := GetIdentIndex( copy(Ident[IdentIndex].Name, 1, pos('.', Ident[IdentIndex].Name)-1) );

	      if (Ident[IdentTemp].DataType = TDataType.POINTERTOK) and (Ident[IdentTemp].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin
	       IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

	       par2 := copy(Ident[IdentIndex].Name, pos('.', Ident[IdentIndex].Name)+1, length(Ident[IdentIndex].Name));

	       IdentIndex := IdentTemp;

	       IdentTemp := RecordSize(IdentIndex, par2);

	       if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member ''' + par2 + '''');

	       par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	      end;

	    end;


//	    writeln(Ident[IdentIndex].Name,',',vartype,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].Kind);//+ '.' + Tok[i + 3].Name);

	    if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (Tok[i + 2].Kind = TTokenKind.DOTTOK) then begin
	       IndirectionLevel := ASPOINTERTOARRAYRECORD;

	       CheckTok(i + 3, TTokenKind.IDENTTOK);
	       IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name);

	       if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name+'''');


//	       writeln('>',Ident[IdentIndex].Name+ '||' + Tok[i + 3].Name,',',IdentTemp shr 16,',',VarType,'||',Tok[i+4].Kind,',',ident[GetIdentIndex(Ident[IdentIndex].Name+ '.' + Tok[i + 3].Name)].AllocElementTYpe);


	      if Tok[i + 4].Kind = TTokenKind.OBRACKETTOK then begin				// array_to_record_pointers[x].field[index] :=

	        if not (Ident[IdentIndex].DataType in Pointers) then
	          ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	        VarType := Ident[GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name)].AllocElementType;
	        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	        IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

	        i := CompileArrayIndex(i + 3, GetIdentIndex(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name));

	        CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	      end else begin								// array_to_record_pointers[x].field :=
//-------
	        VarType := TDataType(IdentTemp shr 16);
	        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

 	        if GetIdentIndex(Ident[IdentIndex].name+'.'+Tok[i + 3].Name) > 0 then IdentIndex := GetIdentIndex(Ident[IdentIndex].name+'.'+Tok[i + 3].Name);

		if VarType = TDataType.STRINGPOINTERTOK then IndirectionLevel := ASPOINTERTOARRAYRECORDTOSTRING;

	        inc(i, 2);

	      end;


	    end else
	     if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK, TDataType.PROCVARTOK] then VarType := TDataType.POINTERTOK;

	    //CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	    inc(i);

	    end
	  else								// Without dereferencing or indexing
	    begin

	    if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) then begin
	     IndirectionLevel := ASPOINTERTOPOINTER;

	     if Ident[IdentIndex].AllocElementType = TDataType.UNTYPETOK then
	      VarType := Ident[IdentIndex].DataType			// RECORD.
	     else
	       VarType := Ident[IdentIndex].AllocElementType;

	    end else begin
	     IndirectionLevel := ASPOINTER;

	     VarType := Ident[IdentIndex].DataType;
	    end;

//	writeln('= ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', VarType,',',IndirectionLevel);

	    end;


	   if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType = TDataType.PROCVARTOK) and (Tok[i + 1].Kind <> TTokenKind.ASSIGNTOK) then begin

	        IdentTemp := GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		CompileActualParameters(i, IdentTemp, IdentIndex);

		if Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK then a65(TCode65.subBX);

		Result := i;
		exit;

	   end else
	    CheckTok(i + 1, TTokenKind.ASSIGNTOK);


//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',IndirectionLevel);


	    if (Ident[IdentIndex].DataType = TDataType.PCHARTOK) and
//	       ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING)) ) and
	       (IndirectionLevel = ASPOINTER) and
	       (Tok[i + 2].Kind in [TTokenKind.STRINGLITERALTOK, TTokenKind.CHARLITERALTOK, TTokenKind.IDENTTOK]) then
	      begin


{$i include/compile_pchar.inc}


	      end else

	    if (Ident[IdentIndex].DataType in Pointers) and
	       (Ident[IdentIndex].AllocElementType = TDataType.CHARTOK) and
	       (Ident[IdentIndex].NumAllocElements > 0) and
	       ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING)) ) and
	       (Tok[i + 2].Kind in [TTokenKind.STRINGLITERALTOK, TTokenKind.CHARLITERALTOK, TTokenKind.IDENTTOK]) then
	      begin


{$i include/compile_string.inc}


	      end // if
	    else
	      begin								// Usual assignment

	      if VarType = TDataType.UNTYPETOK then
		Error(i, 'Assignments to formal parameters and open arrays are not possible');



	      Result := CompileExpression(i + 2, ExpressionType, VarType);	// Right-hand side expression



	      k := i + 2;


	      RealTypeConversion(VarType, ExpressionType);

	      if (VarType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) and (ExpressionType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then
		ExpressionType := VarType;


	      if (VarType = TDataType.POINTERTOK) and (ExpressionType = TDataType.STRINGPOINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType = TDataType.CHARTOK) then begin	// +1
		  asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'add #$01');
		  asm65(#9'sta :STACKORIGIN,x');
		  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'adc #$00');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		end else
		 if Ident[IdentIndex].AllocElementType = TDataType.UNTYPETOK then
		  ErrorIncompatibleTypes(i + 1, TTokenKind.STRINGPOINTERTOK, TTokenKind.POINTERTOK)
		 else
		  GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, TTokenKind.STRINGPOINTERTOK);

	      end;


 	      if (Tok[i].Kind = TTokenKind.DEREFERENCETOK) and (VarType = TDataType.POINTERTOK) and (ExpressionType = TDataType.RECORDTOK) then begin

	         ExpressionType := TTokenKind.RECORDTOK;
	         VarType := TTokenKind.RECORDTOK;

	      end;


//	if (Tok[k].Kind = TTokenKind.IDENTTOK) then
//	  writeln(Ident[IdentIndex].Name,'/',Tok[k].Name,',', VarType,':', ExpressionType,' - ', Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' | ',Ident[GetIdentIndex(Tok[k].Name)].DataType,':',Ident[GetIdentIndex(Tok[k].Name)].AllocElementType,':',Ident[GetIdentIndex(Tok[k].Name)].NumAllocElements ,' / ',IndirectionLevel)
//	else
//	  writeln(Ident[IdentIndex].Name,',', VarType,',', ExpressionType,' - ', Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' / ',IndirectionLevel);


	     if  VarType <> ExpressionType then
	      if (ExpressionType = TDataType.POINTERTOK) and (Tok[k].Kind = TTokenKind.IDENTTOK) then
	       if (Ident[GetIdentIndex(Tok[k].Name)].DataType = TDataType.POINTERTOK) and (Ident[GetIdentIndex(Tok[k].Name)].AllocElementType = TDataType.PROCVARTOK) then begin

	         IdentTemp := GetIdentIndex('@FN' + IntToHex(Ident[GetIdentIndex(Tok[k].Name)].NumAllocElements_, 4) );

		 //CompileActualParameters(i, IdentTemp, GetIdentIndex(Tok[k].Name));

		 if Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK then ExpressionType := Ident[IdentTemp].DataType;

               end;


	      CheckAssignment(i + 1, IdentIndex);

	      if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) {and not (Ident[IdentIndex].AllocElementType in [PROCEDURETOK, FUNC])} then begin

//	writeln(ExpressionType,' | ',Ident[IdentIndex].idtype,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].Name,',',IndirectionLevel);
//	writeln(Ident[GetIdentIndex(Ident[IdentIndex].Name)].AllocElementType);


	       if (ExpressionType = TDataType.CHARTOK) and ( Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType = TDataType.STRINGPOINTERTOK) then

		IndirectionLevel := ASSTRINGPOINTER1TOARRAYORIGIN		// tab[ ] := 'a'

	       else
	       if Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then begin


		if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then

		else
		  GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);


	        end else
	          GetCommonType(i + 1, Ident[IdentIndex].AllocElementType, ExpressionType);

	      end else
	       if (Ident[IdentIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) then begin

		  if (ExpressionType in Pointers - [TDataType.STRINGPOINTERTOK]) and (Tok[k].Kind = TTokenKind.IDENTTOK) then begin

		    IdentTemp := GetIdentIndex(Tok[k].Name);

		    if (IdentTemp > 0) and (Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK) then
		      IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		    {if (Tok[i + 3].Kind <> TTokenKind.OBRACKETTOK) and ((Elements(IdentTemp) <> Elements(IdentIndex)) or (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType)) then
		     Error(k, IncompatibleTypes, GetIdentIndex(Tok[k].Name), ExpressionType )
		    else
		     if (Elements(IdentTemp) > 0) and (Tok[i + 3].Kind <> TTokenKind.OBRACKETTOK) then
		      Error(k, IncompatibleTypes, IdentTemp, ExpressionType )
		    else}

		    if Ident[IdentTemp].AllocElementType = TDataType.RECORDTOK then
		    // GetCommonType(i + 1, VarType, TTokenKind.RECORDTOK)
		    else

		    if (Ident[IdentIndex].AllocElementType <> TTokenKind.UNTYPETOK) and (Ident[IdentTemp].AllocElementType <> TTokenKind.UNTYPETOK) and (Ident[IdentTemp].AllocElementType <> Ident[IdentIndex].AllocElementType) and (Tok[k + 1].Kind <> TTokenKind.OBRACKETTOK) then begin

		      if ((Ident[IdentTemp].NumAllocElements > 0) {and (Ident[IdentTemp].AllocElementType <> TTokenKind.RECORDTOK)}) and ((Ident[IdentIndex].NumAllocElements > 0) {and (Ident[IdentIndex].AllocElementType <> TTokenKind.RECORDTOK)}) then
		        ErrorIdentifierIncompatibleTypesArrayIdentifier(k, IdentTemp, IdentIndex)

		      else begin

//      writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' | ',Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,':',Ident[IdentTemp].AllocElementType,':',Ident[IdentTemp].NumAllocElements);

		        if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType <> TTokenKind.UNTYPETOK) and (Ident[IdentIndex].NumAllocElements = 0) and
		           (Ident[IdentTemp].DataType = TDataType.POINTERTOK) and (Ident[IdentTemp].AllocElementType <> TTokenKind.UNTYPETOK) and (Ident[IdentTemp].NumAllocElements = 0) then
			  Error(k, 'Incompatible types: got "^'+InfoAboutToken(Ident[IdentTemp].AllocElementType)+'" expected "^' + InfoAboutToken(Ident[IdentIndex].AllocElementType) + '"')
			else
			  ErrorIdentifierIncompatibleTypesArray(k, IdentTemp, ExpressionType);

		     end;


		    end;

		 end else
		    if (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

			IdentTemp := GetIdentIndex(Tok[k].Name);

			case IndirectionLevel of
			           ASPOINTER:
				   if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] ) then
				    Error(k, 'Incompatible types: got "' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

			  ASPOINTERTOPOINTER:
				   if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentTemp].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] ) then
				    Error(k, 'Incompatible types: got "' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');
			else
			  GetCommonType(i + 1, VarType, ExpressionType);

			end;

		    end else begin

//		 writeln('1> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,', P:', Ident[IdentIndex].PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

		      if ((Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or
		         ((VarType = TDataType.STRINGPOINTERTOK) and (ExpressionType = TDataType.PCHARTOK))   	                                           then

		      else
		      if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                        Error(i, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) +'" expected "' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"')
		      else
		        GetCommonType(i + 1, VarType, ExpressionType);

		    end;

	       end else
			     if (VarType = ENUMTYPE) {and (Tok[k].Kind = TTokenKind.IDENTTOK)} then begin

				  if (Tok[k].Kind = TTokenKind.IDENTTOK) then
				    IdentTemp := GetIdentIndex(Tok[k].Name)
				  else
				    IdentTemp := 0;

				  if (IdentTemp > 0) and (Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK) then
				   IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

				  if (IdentTemp > 0) and (Ident[IdentTemp].Kind = USERTYPE) and (Ident[IdentTemp].DataType = ENUMTYPE) then begin

				    if Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements then
				      ErrorIncompatibleEnumIdentifiers(i,  IdentTemp, IdentIndex);

				  end else
				  if (IdentTemp > 0) and (Ident[IdentTemp].Kind = ENUMTYPE) then begin

				    if Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].NumAllocElements then
				      ErrorIncompatibleEnumIdentifiers(i, IdentTemp, IdentIndex);

				  end else
				  if (IdentTemp > 0) and (Ident[IdentTemp].DataType = ENUMTYPE) then begin

				    if Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].NumAllocElements then
				      ErrorIncompatibleEnumIdentifiers(i, IdentTemp, IdentIndex);

				  end else
 				   ErrorIncompatibleEnumTypeIdentifier(i, ExpressionType, IdentIndex);

				 end else begin

				  if (Tok[k].Kind = TTokenKind.IDENTTOK) then
				    IdentTemp := GetIdentIndex(Tok[k].Name)
				  else
				    IdentTemp := 0;

				  if (IdentTemp > 0) and ((Ident[IdentTemp].Kind = ENUMTYPE) or (Ident[IdentTemp].DataType = ENUMTYPE)) then
 				   ErrorIncompatibleEnumIdentifierType(i, IdentTemp, ExpressionType)
				  else
				   GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);

				 end;


	      ExpandParam(VarType, ExpressionType);			     // :=

	      Ident[IdentIndex].isInit := true;


//	writeln(vartype,',',ExpressionType,',',Ident[IdentIndex].Name);

//     	writeln('0> ',Ident[IdentIndex].Name,',',VarType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', ExpressionType,',',IndirectionLevel);


	      if (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (IndirectionLevel <> ASPOINTERTODEREFERENCE) and (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) and (ExpressionType <> TTokenKind.POINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType in {IntegerTypes}OrdinalTypes) and (ExpressionType in {IntegerTypes}OrdinalTypes) then

		else
		 if Ident[IdentIndex].AllocElementType <> TTokenKind.UNTYPETOK then begin

		  if (ExpressionType in [TDataType.PCHARTOK, TDataType.STRINGPOINTERTOK]) and (Ident[IdentIndex].AllocElementType = TDataType.CHARTOK) then

		  else
		   Error(i + 1, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) + '" expected "' + Ident[IdentIndex].Name + '"');

		 end else
		   GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);

	      end;


	      if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) or ((VarType = TDataType.POINTERTOK) and (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) ) then begin

		ADDRESS := false;

		if Tok[k].Kind = TTokenKind.ADDRESSTOK then begin
		 inc(k);

		 ADDRESS := true;
		end;

		if Tok[k].Kind <> TTokenKind.IDENTTOK then Error(k, TErrorCode.IdentifierExpected);

		IdentTemp := GetIdentIndex(Tok[k].Name);


		if Ident[IdentIndex].PassMethod = Ident[IdentTemp].PassMethod then
		  case IndirectionLevel of
		    ASPOINTER:
			   if (Tok[k + 1].Kind <> TTokenKind.DEREFERENCETOK) and (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentTemp].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] ) then
			    Error(k, 'Incompatible types: got "^' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

 		    ASPOINTERTOPOINTER:
//			   if {(Tok[i + 1].Kind <> TTokenKind.DEREFERENCETOK) and }(Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] ) then
//			    Error(k, 'Incompatible types: got "^' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');
		  else
  		    GetCommonType(i + 1, VarType, ExpressionType);

		  end;


               if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (Ident[IdentIndex].PassMethod = Ident[IdentTemp].PassMethod) then begin

//		   writeln('2> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements);

  		   if Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK then
		    yes := Ident[IdentIndex].NumAllocElements <> Ident[GetIdentResult(Ident[IdentTemp].ProcAsBlock)].NumAllocElements
		   else
		    yes := Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements;


		   if yes and (ADDRESS = false) and (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
	  	      if (Ident[IdentTemp].DataType = TDataType.POINTERTOK) and (Ident[IdentTemp].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                        Error(i, 'Incompatible types: got "^' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "^' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"')
		      else
                        Error(i, 'Incompatible types: got "' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "^' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

	       end;


	       if (ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) or ( (ExpressionType = TDataType.POINTERTOK) and (Ident[IdentTemp].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) ) then begin

		svar := Tok[k].Name;

		if (Ident[IdentTemp].DataType = TDataType.RECORDTOK) and (Ident[IdentTemp].AllocElementType <> TTokenKind.RECORDTOK) then
		  Name := 'adr.' + svar
		else
		  Name := svar;


		if (Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK) then begin
		  svar := GetLocalName(IdentTemp);

		  IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		  Name := svar + '.adr.result';
		  svar := svar + '.result';
		end;


		DEREFERENCE := false;
	        if (Tok[k + 1].Kind = TTokenKind.DEREFERENCETOK) then begin
		 inc(k);

		 DEREFERENCE := true;
		end;


	        if Tok[k + 1].Kind = TTokenKind.DOTTOK then begin

		 CheckTok(k + 2, TTokenKind.IDENTTOK);

		 Name := svar + '.' + Tok[k+2].Name;
		 IdentTemp := GetIdentIndex(Name);

		end;

//writeln( Ident[IdentIndex].Name,',', Ident[IdentIndex].NumAllocElements, ',', Ident[IdentIndex].AllocElementType  ,' / ', Ident[IdentTemp].Name,',', Ident[IdentTemp].NumAllocElements,',',Ident[IdentTemp].AllocElementType );
//writeln( '>', Ident[IdentIndex].Name,',', Ident[IdentIndex].DataType, ',', Ident[IdentIndex].AllocElementTYpe );
//writeln( '>', Ident[IdentTemp].Name,',', Ident[IdentTemp].DataType, ',', Ident[IdentTemp].AllocElementTYpe );
//writeln(TypeArray[5].Field[0].Name);

		if IdentTemp > 0 then

		if Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements then		// porownanie indeksow do tablicy TYPES
//		  Error(i, IncompatibleTypeOf, IdentTemp);
		  if (Ident[IdentIndex].NumAllocElements = 0) then
                    Error(i, 'Incompatible types: got "' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "' + InfoAboutToken(Ident[IdentIndex].DataType) + '"')
	          else
                    Error(i, 'Incompatible types: got "' + TypeArray[Ident[IdentTemp].NumAllocElements].Field[0].Name  +'" expected "' + TypeArray[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');


		a65(TCode65.subBX);
		StopOptimization;

		ResetOpty;


		if (Ident[IdentIndex].DataType = TDataType.RECORDTOK) and (Ident[IdentTemp].DataType = TDataType.RECORDTOK) and (Ident[IdentTemp].AllocElementType = TDataType.RECORDTOK) then begin

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

{
	          if RecordSize(IdentIndex) <= 8 then begin

		   asm65(#9'ldy #$00');

		   for j:=0 to RecordSize(IdentIndex)-1 do begin
		    asm65(#9'lda (:bp2),y');
		    asm65(#9'sta adr.'+Ident[IdentIndex].Name + '+' + IntToStr(j));

		    if j <> RecordSize(IdentIndex)-1 then asm65(#9'iny');
		   end;
}
		  if RecordSize(IdentIndex)  <= 128 then begin

			asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
			asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

		  end else
			asm65(#9'@move ":bp2" ' + GetLocalName(IdentIndex) + ' #' + IntToStr(RecordSize(IdentIndex)));


		end else
		if (Ident[IdentIndex].DataType = TDataType.RECORDTOK) and (Ident[IdentTemp].DataType = TDataType.RECORDTOK) and (RecordSize(IdentIndex) <= 8) then begin

			if RecordSize(IdentIndex) = 1 then
			  asm65(#9' mva ' + Name + ' ' + GetLocalName(IdentIndex, 'adr.'))
			else
			  asm65(#9':' + IntToStr(RecordSize(IdentIndex)) + ' mva ' + Name + '+# ' + GetLocalName(IdentIndex, 'adr.') + '+#');

		end else
		 if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentTemp].DataType = TDataType.POINTERTOK) then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType ,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].pASSmETHOD);
//	writeln(Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType ,',',Ident[IdentTemp].NumAllocElements,'/',Ident[IdentTemp].NumAllocElements_,',',Ident[IdentTemp].pASSmETHOD);
//	writeln('--- ', IndirectionLevel);

			asm65(#9'@move ' + Name + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(RecordSize(IdentIndex)))

		 end else
		  if (Ident[IdentIndex].DataType = TDataType.RECORDTOK) and (Ident[IdentTemp].DataType = TDataType.POINTERTOK) then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType ,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].pASSmETHOD);
//	writeln(Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType ,',',Ident[IdentTemp].NumAllocElements,'/',Ident[IdentTemp].NumAllocElements_,',',Ident[IdentTemp].pASSmETHOD);
//	writeln('--- ', IndirectionLevel);


			if Ident[IdentTemp].PassMethod = TParameterPassingMethod.VARPASSING then begin

			  asm65(#9'mwy ' + GetLocalName(IdentTemp) + ' :bp2');

			  if RecordSize(IdentIndex) <= 128 then begin

			    asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
  			    asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

			  end else
			    asm65(#9'@move ":bp2" #' + GetLocalName(IdentIndex, 'adr.') + ' #' + IntToStr(RecordSize(IdentIndex)));

			end else

			if RecordSize(IdentIndex) <= 128 then begin

			  asm65(#9'mwy ' + GetLocalName(IdentTemp) + ' :bp2');

			  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
			  asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

			end else
			  asm65(#9'@move ' + Name + ' #' + GetLocalName(IdentIndex, 'adr.') + ' #' + IntToStr(RecordSize(IdentIndex)));


 		  end else begin

			if (pos('adr.', Name) > 0) and (RecordSize(IdentIndex) <= 128) then begin

			  if IndirectionLevel = ASPOINTERTOARRAYORIGIN2 then begin

			    asm65(#9'lda' + GetStackVariable(0));
			    asm65(#9'sta :bp2');
			    asm65(#9'lda' + GetStackVariable(1));
			    asm65(#9'sta :bp2+1');

			  end else
			    asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

			  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
			  asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

			end else
			  asm65(#9'@move #' + Name + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(RecordSize(IdentIndex)));

		  end;



     	       end else	   // ExpressionType <> TTokenKind.RECORDTOK + TTokenKind.OBJECTTOK
		 GetCommonType(i + 1, ExpressionType, TTokenKind.RECORDTOK);

	      end else

		if// (Tok[k].Kind = TTokenKind.IDENTTOK) and
		   (VarType = TDataType.STRINGPOINTERTOK) and (ExpressionType in Pointers) {and (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])} then begin


//	writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType ,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].Name,',',IndirectionLevel,',',vartype,' || ',Ident[GetIdentIndex(Tok[k].Name)].NumAllocElements,',',Ident[GetIdentIndex(Tok[k].Name)].PassMethod);

//	writeln(address,',',Tok[k].kind,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].AllocElementType,' / ', VarType,',',ExpressionType,',',IndirectionLevel);


		 if (Tok[k].Kind <> TTokenKind.ADDRESSTOK) and (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) and (Ident[IdentIndex].AllocElementType = TDataType.STRINGPOINTERTOK) then begin

		  if (Tok[k].Kind = TTokenKind.IDENTTOK) and (Ident[GetIdentIndex(Tok[k].Name)].AllocElementType <> TTokenKind.UNTYPETOK) then IndirectionLevel := ASSTRINGPOINTERTOARRAYORIGIN;

		  GenerateAssignment(IndirectionLevel, GetDataSize( VarType ), IdentIndex);

		  StopOptimization;

		  ResetOpty;

		 end else
		  GenerateAssignment(IndirectionLevel, GetDataSize( VarType), IdentIndex, par1, par2);


	        end else


// dla PROC, FUNC -> Ident[GetIdentIndex(Tok[k].Name)].NumAllocElements -> oznacza liczbe parametrow takiej procedury/funkcji

		if (VarType in Pointers) and ( (ExpressionType in Pointers) and (Tok[k].Kind = TTokenKind.IDENTTOK) ) and
		   ( not (Ident[IdentIndex].AllocElementType in Pointers + [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and not (Ident[GetIdentIndex(Tok[k].Name)].AllocElementType in Pointers + [TDataType.RECORDTOK, TDataType.OBJECTTOK])  ) (* and
		   (({GetDataSize( TDataType.Ident[IdentIndex].AllocElementType] *} Ident[IdentIndex].NumAllocElements > 1) and ({GetDataSize( TDataType.Ident[GetIdentIndex(Tok[k].Name)].AllocElementType] *} Ident[GetIdentIndex(Tok[k].Name)].NumAllocElements > 1)) *) then begin


		j := Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType);

		IdentTemp := GetIdentIndex(Tok[k].Name);

		Name := 'adr.'+Tok[k].Name;
		svar := Tok[k].Name;

		if IdentTemp > 0 then begin

		  if Ident[IdentTemp].Kind = TTokenKind.FUNCTIONTOK then begin

		   svar := GetLocalName(IdentTemp);

		   IdentTemp := GetIdentResult(Ident[IdentTemp].ProcAsBlock);

		   Name := svar+'.adr.result';
		   svar := svar+'.result';

		  end;


	          if (Ident[IdentIndex].NumAllocElements > 1) and (Ident[IdentTemp].NumAllocElements > 1) then begin

		    if Ident[IdentTemp].AllocElementType <> TTokenKind.RECORDTOK then
		     if (j <> integer(Ident[IdentTemp].NumAllocElements * GetDataSize( Ident[IdentTemp].AllocElementType))) then

                       ErrorIdentifierIncompatibleTypesArrayIdentifier(i, IdentTemp, IdentIndex);

	   	    a65(TCode65.subBX);
		    StopOptimization;

		    ResetOpty;

		    if (j <= 4) and (Ident[IdentTemp].AllocElementType <> TTokenKind.RECORDTOK) then
		     asm65(#9':' + IntToStr(j) + ' mva ' + Name + '+# ' + GetLocalName(IdentIndex, 'adr.') + '+#')
		    else
		     asm65(#9'@move ' + svar + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(j));

		  end else
		   GenerateAssignment(IndirectionLevel, GetDataSize( VarType), IdentIndex, par1, par2);


		end else
 	 	  Error(k, TErrorCode.UnknownIdentifier);


	       end else
		GenerateAssignment(IndirectionLevel, GetDataSize( VarType), IdentIndex, par1, par2);

	      end;

//	    StopOptimization;

	  end;// VARIABLE


	TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK:		// Procedure, Function (without assignment) call
	  begin

	   Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc(Ident[IdentIndex].Name, IdentIndex, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then begin

	      if Ident[IdentIndex].NumParams <> j then
		ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentIndex);

	      ErrorForIdentifier(i, TErrorCode.CantDetermine, IdentIndex);
	     end else
              ErrorForIdentifier(i, TErrorCode.WrongNumberOfParameters, IdentIndex);

	    IdentIndex := IdentTemp;

//	  end;

          if (Ident[IdentIndex].isStdCall = false) then
	    StartOptimization(i)
	  else
          if common.optimize.use = false then StartOptimization(i);


	  inc(run_func);

	  CompileActualParameters(i, IdentIndex);

	  dec(run_func);

	  if Ident[IdentIndex].Kind = TTokenKind.FUNCTIONTOK then begin
	    a65(TCode65.subBX);							// zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji
	    StartOptimization(i);
	  end;

	  Result := i;
	  end;	// PROC

      else
	Error(i, 'Assignment or procedure call expected but ' + Ident[IdentIndex].Name + ' found');
      end// case Ident[IdentIndex].Kind
    else
      Error(i, TErrorCode.UnknownIdentifier)
    end;

  TTokenKind.INFOTOK:
    begin

      if Pass = TPass.CODE_GENERATION then writeln('User defined: ' + msgUser[Tok[i].Value]);

      Result := i;
    end;


  TTokenKind.WARNINGTOK:
    begin

      WarningUserDefined(i);

      Result := i;
    end;


  TTokenKind.ERRORTOK:
    begin

      if Pass = TPass.CODE_GENERATION then Error(i, TErrorCode.UserDefined);

       Result := i;
    end;


  TTokenKind.IOCHECKON:
    begin
     IOCheck := true;

     Result := i;
    end;


  TTokenKind.IOCHECKOFF:
    begin
     IOCheck := false;

     Result := i;
    end;


  TTokenKind.LOOPUNROLLTOK:
    begin
     loopunroll := true;

     Result := i;
    end;


  TTokenKind.NOLOOPUNROLLTOK:
    begin
     loopunroll := false;

     Result := i;
    end;


  TTokenKind.PROCALIGNTOK:
    begin
     codealign.proc := Tok[i].Value;

     Result := i;
    end;


  TTokenKind.LOOPALIGNTOK:
    begin
     codealign.loop := Tok[i].Value;

     Result := i;
    end;


  TTokenKind.LINKALIGNTOK:
    begin
     codealign.link := Tok[i].Value;

     Result := i;
    end;


  TTokenKind.GOTOTOK:
    begin
     CheckTok(i + 1, TTokenKind.IDENTTOK);

     IdentIndex := GetIdentIndex(Tok[i + 1].Name);

     if IdentIndex > 0 then begin

      if Ident[IdentIndex].Kind <> LABELTYPE then
	Error(i + 1, 'Identifier isn''t a label');

      asm65(#9'jmp '+Ident[IdentIndex].Name);

     end else
       Error(i + 1, TErrorCode.UnknownIdentifier);

     Result := i + 1;
    end;


  TTokenKind.BEGINTOK:
    begin

    if isAsm then
     CheckTok(i , TTokenKind.ASMTOK);

    j := CompileStatement(i + 1);
    while (Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK) or ((Tok[j + 1].Kind = TTokenKind.COLONTOK) and (Tok[j].Kind = TTokenKind.IDENTTOK)) do j := CompileStatement(j + 2);

    CheckTok(j + 1, TTokenKind.ENDTOK);

    Result := j + 1;
    end;


  TTokenKind.CASETOK:
    begin
    CaseLocalCnt := CaseCnt;
    inc(CaseCnt);

    ResetOpty;

    EnumName := '';

    StartOptimization(i);

    j := i + 1;

    i := CompileExpression(i + 1, SelectorType);


    if (SelectorType =  TTokenKind.ENUMTOK) and (Tok[j].Kind = TTokenKind.IDENTTOK) and (Ident[GetIdentIndex(Tok[j].Name)].Kind = TTokenKind.FUNCTIONTOK) then begin

       IdentTemp:=GetIdentIndex(Tok[j].Name);

       SelectorType := Ident[GetIdentResult(Ident[IdentTemp].ProcAsBlock)].AllocElementType;

       EnumName := TypeArray[Ident[GetIdentResult(Ident[IdentTemp].ProcAsBlock)].NumAllocElements].Field[0].Name;

    end else

    if Tok[i].Kind = TTokenKind.IDENTTOK then
      EnumName := GetEnumName(GetIdentIndex(Tok[i].Name));


    if SelectorType <> ENUMTYPE then
     if GetDataSize( SelectorType ) <> 1 then
      Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

    if not (SelectorType in OrdinalTypes + [ENUMTYPE]) then
      Error(i, 'Ordinal variable expected as ''CASE'' selector');

    CheckTok(i + 1, TTokenKind.OFTOK);


    GenerateAssignment(ASPOINTER, GetDataSize(SelectorType), 0, '@CASETMP_'+IntToHex(CaseLocalCnt, 4));

    DefineIdent(i, '@CASETMP_'+IntToHex(CaseLocalCnt, 4), VARIABLE, SelectorType, 0, TDataType.UNTYPETOK, 0);

    GetIdentIndex('@CASETMP_'+IntToHex(CaseLocalCnt, 4));

    yes:=true;

    NumCaseStatements := 0;

    inc(i, 2);

    CaseLabelArray:=nil;
    SetLength(CaseLabelArray, 1);

    repeat	// Loop over all cases

//      yes:=false;

      repeat	// Loop over all constants for the current case
	i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

//	 ConstVal:=ConstVal and $ff;
	// Warning(i, RangeCheckError, 0, ConstValType, SelectorType);

	GetCommonType(i, ConstValType, SelectorType);

	if (Tok[i].Kind = TTokenKind.IDENTTOK)  then
	 if ((EnumName = '') and (GetEnumName(GetIdentIndex(Tok[i].Name)) <> '')) or
  	    ((EnumName <> '') and (GetEnumName(GetIdentIndex(Tok[i].Name)) <> EnumName)) then
		Error(i, 'Constant and CASE types do not match');


	if Tok[i + 1].Kind = TTokenKind.RANGETOK then						// Range check
	  begin
	  i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

//	  ConstVal2:=ConstVal2 and $ff;
	  // Warning(i, RangeCheckError, 0, ConstValType, SelectorType);

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
	if Tok[i].Kind = TTokenKind.COMMATOK then
	  inc(i)
	else
	  ExitLoop := TRUE;

      until ExitLoop;


      CheckTok(i, TTokenKind.COLONTOK);

      GenerateCaseStatementProlog; //(CaseLabel.equality);

      ResetOpty;

      asm65('@');

      j := CompileStatement(i + 1);
      i := j + 1;
      GenerateCaseStatementEpilog(CaseLocalCnt);

      Inc(NumCaseStatements);

      ExitLoop := FALSE;
      if Tok[i].Kind <> TTokenKind.SEMICOLONTOK then
	begin
	if Tok[i].Kind = TTokenKind.ELSETOK then	      // Default statements
	  begin

	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	  end;
	ExitLoop := TRUE;
	end
      else
	begin
	inc(i);

	if Tok[i].Kind = TTokenKind.ELSETOK then begin
	  j := CompileStatement(i + 1);
	  while Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

	  i := j + 1;
	end;

	if Tok[i].Kind = TTokenKind.ENDTOK then ExitLoop := TRUE;

	end

    until ExitLoop;

    CheckTok(i, TTokenKind.ENDTOK);

    GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

    Result := i;
    end;


  TTokenKind.IFTOK:
    begin
    ifLocalCnt := ifCnt;
    inc(ifCnt);

//    ResetOpty;

    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType);	// !!! VarType = TDataType.INTEGERTOK, 'IF BYTE+SHORTINT < BYTE'

    GetCommonType(j, TTokenKind.BOOLEANTOK, ExpressionType);	// wywali blad jesli warunek bedzie typu IF A THEN

    CheckTok(j + 1, TTokenKind.THENTOK);

    SaveToSystemStack(ifLocalCnt);		// Save conditional expression at expression stack top onto the system stack

    GenerateIfThenCondition;			// Satisfied if expression is not zero
    GenerateIfThenProlog;

    inc(CodeSize);				// !!! aby dzialaly petle WHILE, REPEAT po IF

    j := CompileStatement(j + 2);

    GenerateIfThenEpilog;
    Result := j;

      if Tok[j + 1].Kind = TTokenKind.ELSETOK then
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


    GetCommonType(j, TTokenKind.BOOLEANTOK, ExpressionType);

    CheckTok(j + 1, TTokenKind.DOTOK);

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

  TTokenKind.WHILETOK:
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
    Pass := TPass.CALL_DETERMINATION;

    k:=i;

    StartOptimization(i + 1);

    j := CompileExpression(i + 1, ExpressionType);

    GetCommonType(j, TTokenKind.BOOLEANTOK, ExpressionType);

    CheckTok(j + 1, TTokenKind.DOTOK);

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

      a65(TCode65.subBX);

      asm65(#9'lda :STACKORIGIN+1,x');
      asm65(#9'jne l_'+IntToHex(CodePosStack[CodePosStackTop+1], 4));

      Dec(CodePosStackTop);

      asm65('; --- WhileDoEpilog');

      RestoreBreakAddress;

      Result := j;

   // writeln('.',codesize,',',CodePosStackTop);

    end;

{$ENDIF}

  TTokenKind.REPEATTOK:
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

    while Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

    CheckTok(j + 1, TTokenKind.UNTILTOK);

    StartOptimization(j + 2);

    j := CompileExpression(j + 2, ExpressionType);

    GetCommonType(j, TTokenKind.BOOLEANTOK, ExpressionType);

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


  TTokenKind.FORTOK:
    begin
    if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
      Error(i + 1, TErrorCode.IdentifierExpected)
    else
      begin
      IdentIndex := GetIdentIndex(Tok[i + 1].Name);

      inc(CodeSize);		      // !!! aby dzialaly zagniezdzone FOR

      if IdentIndex > 0 then
	if not ( (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].DataType in OrdinalTypes + Pointers) {and (Ident[IdentIndex].AllocElementType = TDataType.UNTYPETOK)} ) then
	  Error(i + 1, 'Ordinal variable expected as ''FOR'' loop counter')
	 else
	 if (Ident[IdentIndex].isInitialized) or (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VALPASSING) then
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


	   if Tok[i + 2].Kind = TTokenKind.INTOK then begin		// IN

	    j := i + 3;

	    	if Tok[j].Kind = TTokenKind.STRINGLITERALTOK then begin

		{$i include/for_in_stringliteral.inc}

	    	end else begin

		{$i include/for_in_ident.inc}

	    	end;

	   end else begin					// = TTokenKind.INTOK

	    CheckTok(i + 2, TTokenKind.ASSIGNTOK);

//	    asm65;
//	    asm65('; --- For');

	    j := i + 3;

	    StartOptimization(j);

	    forLoop.begin_const := false;
	    forLoop.end_const := false;

	    forBPL := 0;

	    if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin
	      Push(ConstVal, ASVALUE, GetDataSize( Ident[IdentIndex].DataType));

	      forLoop.begin_value := ConstVal;
	      forLoop.begin_const := true;

	      forBPL := ord(ConstVal < 128);

	    end else begin
	      j := CompileExpression(j, ExpressionType, Ident[IdentIndex].DataType);

	      ExpandParam(Ident[IdentIndex].DataType, ExpressionType);
	    end;

	    if not (ExpressionType in OrdinalTypes) then
	      Error(j, TErrorCode.OrdinalExpectedFOR);

	    ActualParamType := ExpressionType;


	    GenerateAssignment(ASPOINTER, GetDataSize( Ident[IdentIndex].DataType ), IdentIndex);  //!!!!!

	    if not (Tok[j + 1].Kind in [ TTokenKind.TOTOK, TTokenKind.DOWNTOTOK]) then
	      Error(j + 1, '''TO'' or ''DOWNTO'' expected but ' + GetSpelling(j + 1) + ' found')
	    else
	      begin
	      Down := Tok[j + 1].Kind = TTokenKind.DOWNTOTOK;


	      inc(j, 2);

	      StartOptimization(j);

	      IdentTemp := -1;


	{$IFDEF OPTIMIZECODE}

	      if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin

		Push(ConstVal, ASVALUE, GetDataSize( Ident[IdentIndex].DataType));
		DefineIdent(j, '@FORTMP_'+IntToHex(CodeSize, 4), CONSTANT, Ident[IdentIndex].DataType, Ident[IdentIndex].NumAllocElements, Ident[IdentIndex].AllocElementType, ConstVal, Tok[j].Kind);

	        forLoop.end_value := ConstVal;
	        forLoop.end_const := true;

		if ConstVal > 0 then forBPL := forBPL or 2;

	      end else begin

	        if ((Tok[j].Kind = TTokenKind.IDENTTOK) and (Tok[j + 1].Kind = TTokenKind.DOTOK)) or
		   ((Tok[j].Kind = TTokenKind.OPARTOK) and (Tok[j + 1].Kind = TTokenKind.IDENTTOK) and (Tok[j + 2].Kind = TTokenKind.CPARTOK) and (Tok[j + 3].Kind = TTokenKind.DOTOK)) then begin

		 if Tok[j].Kind = TTokenKind.IDENTTOK then
		  IdentTemp := GetIdentIndex(Tok[j].Name)
		 else
		  IdentTemp := GetIdentIndex(Tok[j + 1].Name);

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
		  Error(j, TErrorCode.OrdinalExpectedFOR);


//		if GetDataSize( TDataType.ExpressionType] > GetDataSize( Ident[IdentIndex].DataType) then
//		  Error(i, 'FOR loop counter variable type (' + InfoAboutToken(Ident[IdentIndex].DataType) + ') is smaller than the type of the maximum range (' + InfoAboutToken(ExpressionType) +')' );


		if ((ActualParamType in UnsignedOrdinalTypes) and (ExpressionType in UnsignedOrdinalTypes)) or
		   ((ActualParamType in SignedOrdinalTypes) and (ExpressionType in SignedOrdinalTypes)) then
		begin

		 if GetDataSize( ExpressionType) > GetDataSize( ActualParamType) then ActualParamType := ExpressionType;
		 if GetDataSize( ActualParamType) > GetDataSize( Ident[IdentIndex].DataType) then ActualParamType := Ident[IdentIndex].DataType;

		end else
		 ActualParamType := Ident[IdentIndex].DataType;


	        if IdentTemp < 0 then IdentTemp := GetIdentIndex('@FORTMP_'+IntToHex(CodeSize, 4));

	        GenerateAssignment(ASPOINTER, {GetDataSize( TDataType.Ident[IdentTemp].DataType]} GetDataSize( ActualParamType ), IdentTemp);

		asm65;		// ; --- To


		if loopunroll and forLoop.begin_const and forLoop.end_const then

		else
	          GenerateRepeatUntilProlog;	// Save return address used by GenerateForToDoEpilog


	        SaveBreakAddress;

	        asm65('; --- ForToDoCondition');


	 	if (ActualParamType = ExpressionType) and (GetDataSize( Ident[IdentTemp].DataType) > GetDataSize( ActualParamType)) then
	          Note(j, 'FOR loop counter variable type is of larger size than required');


	        StartOptimization(j);
		ResetOpty;			// !!!

		yes:=true;


		if loopunroll and forLoop.begin_const and forLoop.end_const then begin

	          CheckTok(j + 1, TTokenKind.DOTOK);

		  ConstVal := forLoop.begin_value;


		  if ((Down = false) and (forLoop.end_value >= forLoop.begin_value)) or (Down and (forLoop.end_value <= forLoop.begin_value)) then begin


		  while ConstVal <> forLoop.end_value do begin

		   ResetOpty;

		   CompileStatement(j + 2);

		   if yes then begin

		    if Down then
		     asm65('---unroll---')
		    else
		     asm65('+++unroll+++');

		    yes:=false;
		   end else
		    asm65('===unroll===');

		   if Down then
		    dec(ConstVal)
		   else
		    inc(ConstVal);

		   case GetDataSize( ActualParamType ) of
		    1: begin
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex));
		       end;

		    2: begin
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex));
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 8), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+1');
		       end;

		    4: begin
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex));
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 8), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+1');
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 16), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+2');
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 24), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+3');
		       end;

 		   end;


		  end;

		   ResetOpty;

		   j := CompileStatement(j + 2);

		   asm65('===unroll===');

		   optyY := '';

		   case GetDataSize( ActualParamType ) of
		    1: begin
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex));
		       end;

		    2: begin
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex));
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 8), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+1');
		       end;

		    4: begin
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex));
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 8), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+1');
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 16), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+2');
		        asm65(#9'ldy #$' + IntToHex(byte(ConstVal shr 24), 2));
		        asm65(#9'sty ' + GetLocalName(IdentIndex)+'+3');
		       end;

 		   end;


		  end else	//if ((Down = false)
	            Error(j, 'for loop with invalid range');

		end else begin

		  Push(Ident[IdentTemp].Value, ASPOINTER, {GetDataSize( Ident[IdentTemp].DataType)} GetDataSize( ActualParamType), IdentTemp);

	          GenerateForToDoCondition(ActualParamType, Down, IdentIndex);	// Satisfied if counter does not reach the second expression value

	          CheckTok(j + 1, TTokenKind.DOTOK);

		  GenerateForToDoProlog;

		  j := CompileStatement(j + 2);

		end;


//	        StartOptimization(j);		!!! zaremowac aby dzialaly optymalizacje w TemporaryBuf

		asm65;
		asm65('; --- ForToDoEpilog');


		if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));


		if loopunroll and forLoop.begin_const and forLoop.end_const then

		else
		  GenerateForToDoEpilog(ActualParamType, Down, IdentIndex, true, forBPL);


		RestoreBreakAddress;

		Result := j;

	      end;

	     end;	// if Tok[i + 2].Kind = TTokenKind.INTTOK

	    Ident[IdentIndex].LoopVariable := false;

	    end
      else
	Error(i + 1, TErrorCode.UnknownIdentifier);
      end;
    end;


  TTokenKind.ASSIGNFILETOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; AssignFile');

	if not( (Ident[IdentIndex].DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) ) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, TTokenKind.COMMATOK);

	StartOptimization(i + 4);

	if Tok[i + 4].Kind = TTokenKind.STRINGLITERALTOK then
	 Note(i + 4, 'Only uppercase letters preceded by the drive symbol, like ''D:FILENAME.EXT'' or ''S:''');

	i := CompileExpression(i + 4, ActualParamType);
	GetCommonType(i, TTokenKind.POINTERTOK, ActualParamType);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.pfname');

	StartOptimization(i);

	Push(0, ASVALUE, GetDataSize( TDataType.BYTETOK));

	GenerateAssignment(ASPOINTERTOPOINTER, 1, 0, Ident[IdentIndex].Name, 's@file.status');

	if (Ident[IdentIndex].DataType = TDataType.TEXTFILETOK) or (Ident[IdentIndex].AllocElementType = TDataType.TEXTFILETOK) then begin

		  asm65(#9'ldy #s@file.buffer');
		  asm65(#9'lda <@buf');
		  asm65(#9'sta (:bp2),y');
	 	  asm65(#9'iny');
		  asm65(#9'lda >@buf');
		  asm65(#9'sta (:bp2),y');

	end;

	Result := i + 1;
	end;


  TTokenKind.RESETTOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; Reset');

	if not( (Ident[IdentIndex].DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) ) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	StartOptimization(i + 3);

	if Tok[i + 3].Kind <> TTokenKind.COMMATOK then begin
	 if Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType) = 0 then
	  Push(128, ASVALUE, 2)
	 else
	  Push(integer(Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType)), ASVALUE, 2);    // predefined record by FILE OF (default =128)

	 inc(i, 3);
	end else begin

	 if (Ident[IdentIndex].DataType = TDataType.TEXTFILETOK) or (Ident[IdentIndex].AllocElementType = TDataType.TEXTFILETOK) then
	  Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' + InfoAboutToken(Ident[IdentIndex].DataType) + '" expected "File"');

	 i := CompileExpression(i + 4, ActualParamType);	     // custom record size
	 GetCommonType(i, TDataType.WORDTOK, ActualParamType);

	 ExpandParam(TDataType.WORDTOK, ActualParamType);

	 inc(i);
	end;

	CheckTok(i, TTokenKind.CPARTOK);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

	GenerateFileOpen(IdentIndex, TIOCode.FileMode);

	Result := i;
	end;


  TTokenKind.REWRITETOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; Rewrite');

	if not( (Ident[IdentIndex].DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK])
        or (Ident[IdentIndex].AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) ) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	StartOptimization(i + 3);

	if Tok[i + 3].Kind <> TTokenKind.COMMATOK then begin

	 if Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType ) = 0 then
	  Push(128, ASVALUE, 2)
	 else
	  Push(integer(Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType)), ASVALUE, 2);    // predefined record by FILE OF (default =128)

	 inc(i, 3);
	end else begin

	 if (Ident[IdentIndex].DataType = TDataType.TEXTFILETOK) or (Ident[IdentIndex].AllocElementType = TDataType.TEXTFILETOK) then
	  Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' + InfoAboutToken(Ident[IdentIndex].DataType) + '" expected "File"');

	 i := CompileExpression(i + 4, ActualParamType);	     // custom record size
	 GetCommonType(i, TDataType.WORDTOK, ActualParamType);

	 ExpandParam(TDataType.WORDTOK, ActualParamType);

	 inc(i);
	end;

	CheckTok(i, TTokenKind.CPARTOK);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

	GenerateFileOpen(IdentIndex, TIOCode.OpenWrite);

	Result := i;
	end;


  TTokenKind.APPENDTOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
       begin

	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; Append');

	if not( (Ident[IdentIndex].DataType in [TDataType.TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [TDataType.TEXTFILETOK]) ) then
	 Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' + InfoAboutToken(Ident[IdentIndex].DataType) + '" expected "Text"');

	if Tok[i + 3].Kind = TTokenKind.COMMATOK then
	 Error(i, 'Wrong number of parameters specified for call to Append');

	StartOptimization(i + 3);

	CheckTok(i + 3, TTokenKind.CPARTOK);

	Push(1, ASVALUE, 2);

	GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, Ident[IdentIndex].Name, 's@file.record');

	GenerateFileOpen(IdentIndex, TIOCode.Append);

	Result := i + 3;
       end;


  TTokenKind.GETRESOURCEHANDLETOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

	if Ident[IdentIndex].DataType <> TTokenKind.POINTERTOK then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, TTokenKind.COMMATOK);

        CheckTok(i + 4, TTokenKind.STRINGLITERALTOK);

	svar:='';

	for k:=1 to Tok[i+4].StrLength do
	 svar:=svar + chr(StaticStringData[Tok[i+4].StrAddress - CODEORIGIN+k]);

//	 writeln(svar,',',Tok[i+4].StrLength);

	CheckTok(i + 5, TTokenKind.CPARTOK);

//	asm65;
//	asm65('; GetResourceHandle');

	asm65(#9'lda <MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name);
	asm65(#9'lda >MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name + '+1');

	inc(i, 5);

	Result := i;
      end;


  TTokenKind.SIZEOFRESOURCETOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

	if not(Ident[IdentIndex].DataType in IntegerTypes) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, TTokenKind.COMMATOK);

        CheckTok(i + 4, TTokenKind.STRINGLITERALTOK);

	svar:='';

	for k:=1 to Tok[i+4].StrLength do
	 svar:=svar + chr(StaticStringData[Tok[i+4].StrAddress - CODEORIGIN+k]);

	CheckTok(i + 5, TTokenKind.CPARTOK);

//	asm65;
//	asm65('; GetResourceHandle');

	asm65(#9'lda <MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name);

	asm65(#9'lda >MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name + '+1');

	inc(i, 5);

	Result := i;
      end;


  TTokenKind.BLOCKREADTOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; BlockRead');

	if not((Ident[IdentIndex].DataType = TDataType.FILETOK) or (Ident[IdentIndex].AllocElementType = TDataType.FILETOK)) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, TTokenKind.COMMATOK);

	inc(i, 2);

	NumActualParams := CompileBlockRead(i, IdentIndex, GetIdentIndex('BLOCKREAD'));

	GenerateFileRead(IdentIndex, TIOCode.Read, NumActualParams);

	Result := i;
	end;


  TTokenKind.BLOCKWRITETOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; BlockWrite');

	if not((Ident[IdentIndex].DataType = TDataType.FILETOK) or (Ident[IdentIndex].AllocElementType = TDataType.FILETOK)) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, TTokenKind.COMMATOK);

	inc(i, 2);
	NumActualParams := CompileBlockRead(i, IdentIndex, GetIdentIndex('BLOCKWRITE'));

	GenerateFileRead(IdentIndex, TIOCode.Write, NumActualParams);

	Result := i;
	end;


  TTokenKind.CLOSEFILETOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then
      Error(i + 1, TErrorCode.OParExpected)
    else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

//	asm65('; CloseFile');

	if not( (Ident[IdentIndex].DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) or (Ident[IdentIndex].AllocElementType in [TDataType.FILETOK, TDataType.TEXTFILETOK])) then
	 ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	CheckTok(i + 3, TTokenKind.CPARTOK);

	GenerateFileOpen(IdentIndex, TIOCode.Close);

	Result := i + 3;
	end;


  TTokenKind.READLNTOK:
    if Tok[i + 1].Kind <> TTokenKind.OPARTOK then begin

      if Tok[i + 1].Kind = TTokenKind.SEMICOLONTOK then begin
       GenerateRead;

       Result := i;
      end else
       Error(i + 1, TErrorCode.OParExpected);

    end else
      if Tok[i + 2].Kind <> TTokenKind.IDENTTOK then
	Error(i + 2, TErrorCode.IdentifierExpected)
      else
	begin
	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if (IdentIndex > 0) and (Ident[identIndex].DataType = TDataType.TEXTFILETOK) then begin

	  asm65(#9'lda #eol');
	  asm65(#9'sta @buf');
	  GenerateFileRead(IdentIndex, TIOCode.ReadRecord, 0);

	  inc(i, 3);

	  CheckTok(i, TTokenKind.COMMATOK);
	  CheckTok(i + 1, TTokenKind.IDENTTOK);

	  if Ident[GetIdentIndex(Tok[i + 1].Name)].DataType <> TTokenKind.STRINGPOINTERTOK then
	   Error(i + 1, TErrorCode.VariableExpected);

	  IdentIndex := GetIdentIndex(Tok[i + 1].Name);

	  asm65(#9'@moveRECORD ' +  GetLocalName(IdentIndex) );

	  CheckTok(i + 2, TTokenKind.CPARTOK);

	  Result := i + 2;

	end else

	if IdentIndex > 0 then
	  if (Ident[IdentIndex].Kind <> VARIABLE) {or (Ident[IdentIndex].DataType <> TTokenKind.CHARTOK)} then
	    ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex)
	  else
	    begin
//	    Push(Ident[IdentIndex].Value, ASVALUE, GetDataSize( TDataType.CHARTOK]);

	    GenerateRead;//(Ident[IdentIndex].Value);

	    ResetOpty;

	    if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType = TDataType.CHARTOK) then begin     // string

		asm65(#9'@move #@buf #'+GetLocalName(IdentIndex, 'adr.')+' #'+IntToStr(Ident[IdentIndex].NumAllocElements));

	    end else
	     if (Ident[IdentIndex].DataType = TDataType.CHARTOK) then
	      asm65(#9'mva @buf+1 '+Ident[IdentIndex].Name)
	     else
	      if (Ident[IdentIndex].DataType in IntegerTypes ) then begin

		asm65(#9'@StrToInt #@buf');

		case GetDataSize( Ident[IdentIndex].DataType) of

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
	       ErrorForIdentifier(i + 2, TErrorCode.IncompatibleTypeOf, IdentIndex);

	    CheckTok(i + 3, TTokenKind.CPARTOK);

	    Result := i + 3;
	    end
	else
	  Error(i + 2, TErrorCode.UnknownIdentifier);
	end;

  TTokenKind.WRITETOK, TTokenKind.WRITELNTOK:
    begin

    StartOptimization(i);

    yes := (Tok[i].Kind = TTokenKind.WRITELNTOK);


    if (Tok[i + 1].Kind = TTokenKind.OPARTOK) and (Tok[i + 2].Kind = TTokenKind.CPARTOK) then inc(i, 2);


    if Tok[i + 1].Kind = TTokenKind.SEMICOLONTOK then begin

    end else begin

     CheckTok(i + 1, TTokenKind.OPARTOK);

     inc(i);

     if (Tok[i + 1].Kind = TTokenKind.IDENTTOK) and (Ident[GetIdentIndex(Tok[i + 1].Name)].DataType = TDataType.TEXTFILETOK) then begin

      IdentIndex := GetIdentIndex(Tok[i + 1].Name);

      inc(i);
      CheckTok(i + 1, TTokenKind.COMMATOK);
      inc(i);

      case Tok[i + 1].Kind of

        TTokenKind.IDENTTOK:					// variable (pointer to string)
		begin

		  if Ident[GetIdentIndex(Tok[i + 1].Name)].DataType <> TTokenKind.STRINGPOINTERTOK then
		   Error(i + 1, TErrorCode.VariableExpected);

	   	   asm65(#9'mwy ' + GetLocalName(GetIdentIndex(Tok[i + 1].Name)) +' :bp2');
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

	        	GenerateFileRead(IdentIndex, TIOCode.WriteRecord, 0);

		   end else begin								// WRITE

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, TIOCode.Write, 0);

		   end;

		  inc(i, 2);

		end;

	TTokenKind.STRINGLITERALTOK:			      // 'text'
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

	        	GenerateFileRead(IdentIndex, TIOCode.WriteRecord, 0);

		   end else begin								// WRITE

			asm65(#9'lda CODEORIGIN+$'+IntToHex(Tok[i + 1].StrAddress - CODEORIGIN,4));

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, TIOCode.Write, 0);

		   end;

		  inc(i, 2);
		end;


	TTokenKind.INTNUMBERTOK:			      // 0..9
		begin
		  asm65(#9'txa:pha');

		  Push(Tok[i + 1].Value, ASVALUE, GetDataSize( TDataType.CARDINALTOK));

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

	        	GenerateFileRead(IdentIndex, TIOCode.WriteRecord, 0);

		   end else begin								// WRITE

			asm65(#9'tya');

			asm65(#9'mwy ' + GetLocalName(IdentIndex) +' :bp2');

			asm65(#9'ldy #s@file.nrecord');
			asm65(#9'sta (:bp2),y');
	 		asm65(#9'iny');
			asm65(#9'lda #$00');
			asm65(#9'sta (:bp2),y');

	        	GenerateFileRead(IdentIndex, TIOCode.Write, 0);

		   end;

		  inc(i, 2);
		end;


      end;

      yes:=false;

     end else

      repeat

	case Tok[i + 1].Kind of

	  TTokenKind.CHARLITERALTOK:
	       begin				   // #65#32#77
		 inc(i);

		 repeat
		   asm65(#9'@print #$'+IntToHex(Tok[i].Value ,2));
		   inc(i);
		 until Tok[i].Kind <> TTokenKind.CHARLITERALTOK;

	       end;

	TTokenKind.STRINGLITERALTOK:			      // 'text'
	       repeat
		 GenerateWriteString(Tok[i + 1].StrAddress, ASPOINTER);
		 inc(i, 2);
	       until Tok[i + 1].Kind <> TTokenKind.STRINGLITERALTOK;

	else

	 begin

	  j := i + 1;

	  i := CompileExpression(j, ExpressionType);


	  if (ExpressionType = TDataType.CHARTOK) and (Tok[i].Kind = TTokenKind.DEREFERENCETOK) and (Tok[i - 1].Kind <> TTokenKind.IDENTTOK) then begin

			asm65(#9'lda :STACKORIGIN,x');
		    	asm65(#9'sta :bp2');
		    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		    	asm65(#9'sta :bp2+1');
		    	asm65(#9'ldy #$00');
			asm65(#9'lda (:bp2),y');
			asm65(#9'sta :STACKORIGIN,x');

	  end;

//	  if ExpressionType = ENUMTYPE then
//	    GenerateWriteString(Tok[i].Value, ASVALUE, TTokenKind.INTEGERTOK)		// Enumeration argument
//	  else

	  if (ExpressionType in IntegerTypes) then
		GenerateWriteString(Tok[i].Value, ASVALUE, ExpressionType)	// Integer argument
	  else if (ExpressionType = TDataType.BOOLEANTOK) then
		GenerateWriteString(Tok[i].Value, ASBOOLEAN)			// Boolean argument
	  else if (ExpressionType = TDataType.CHARTOK) then
		GenerateWriteString(Tok[i].Value, ASCHAR)			// Character argument
	  else if ExpressionType = TDataType.REALTOK then
		GenerateWriteString(Tok[i].Value, ASREAL)			// Real argument
	  else if ExpressionType = TDataType.SHORTREALTOK then
		GenerateWriteString(Tok[i].Value, ASSHORTREAL)			// ShortReal argument
	  else if ExpressionType = TDataType.HALFSINGLETOK then
		GenerateWriteString(Tok[i].Value, ASHALFSINGLE)			// Half Single argument
	  else if ExpressionType = TDataType.SINGLETOK then
		GenerateWriteString(Tok[i].Value, ASSINGLE)			// Single argument
	  else if ExpressionType in Pointers then begin

		if Tok[j].Kind = TTokenKind.ADDRESSTOK then
		 IdentIndex := GetIdentIndex(Tok[j + 1].Name)
		else
		 if Tok[j].Kind = TTokenKind.IDENTTOK then
		  IdentIndex := GetIdentIndex(Tok[j].Name)
		 else
		  Error(i, TErrorCode.CantReadWrite);


//	writeln(Ident[IdentIndex].Name,',',ExpressionType,' | ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].Kind);


		if (Ident[IdentIndex].AllocElementType = TDataType.PROCVARTOK) then begin

		  IdentTemp := GetIdentIndex('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		  if Ident[IdentTemp].Kind =  TTokenKind.FUNCTIONTOK then
		   ExpressionType := Ident[IdentTemp].DataType
		  else
		   ExpressionType := TTokenKind.UNTYPETOK;


		  if (ExpressionType = TDataType.STRINGPOINTERTOK) then
		        GenerateWriteString(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, TTokenKind.POINTERTOK)
		  else if (ExpressionType in IntegerTypes) then
			GenerateWriteString(Tok[i].Value, ASVALUE, ExpressionType)	// Integer argument
		  else if (ExpressionType = TDataType.BOOLEANTOK) then
			GenerateWriteString(Tok[i].Value, ASBOOLEAN)			// Boolean argument
		  else if (ExpressionType = TDataType.CHARTOK) then
			GenerateWriteString(Tok[i].Value, ASCHAR)			// Character argument
		  else if ExpressionType = TDataType.REALTOK then
			GenerateWriteString(Tok[i].Value, ASREAL)			// Real argument
		  else if ExpressionType = TDataType.SHORTREALTOK then
			GenerateWriteString(Tok[i].Value, ASSHORTREAL)			// ShortReal argument
		  else if ExpressionType = TDataType.HALFSINGLETOK then
			GenerateWriteString(Tok[i].Value, ASHALFSINGLE)			// Half Single argument
		  else if ExpressionType = TDataType.SINGLETOK then
			GenerateWriteString(Tok[i].Value, ASSINGLE)			// Single argument
		  else Error(i, TErrorCode.CantReadWrite);


		end else
		if (ExpressionType = TDataType.STRINGPOINTERTOK) or (Ident[IdentIndex].Kind = TTokenKind.FUNCTIONTOK) or ((ExpressionType = TDataType.POINTERTOK) and (Ident[IdentIndex].DataType = TDataType.STRINGPOINTERTOK)) then
		 GenerateWriteString(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, Ident[IdentIndex].DataType)
		else
		if (ExpressionType = TDataType.PCHARTOK) or (Ident[IdentIndex].AllocElementType in [TDataType.CHARTOK, TDataType.POINTERTOK]) then
		 GenerateWriteString(Ident[IdentIndex].Value, ASPCHAR, Ident[IdentIndex].DataType)
		else
		 Error(i, TErrorCode.CantReadWrite);

	  end else
	   Error(i, TErrorCode.CantReadWrite);

	  END;

	  inc(i);

	 end;

	j:=0;

	ActualParamType := ExpressionType;

	if Tok[i].Kind = TTokenKind.COLONTOK then			// pomijamy formatowanie wyniku value:x:x
	 repeat
	  i := CompileExpression(i + 1, ExpressionType);
	  a65(TCode65.subBX);					// zdejmujemy ze stosu
	  inc(i);

	  inc(j);

	  if j > 2 - ord(ActualParamType in OrdinalTypes) then// Break;			// maksymalnie :x:x
	    Error(i + 1, 'Illegal use of '':''');

	 until Tok[i].Kind <> TTokenKind.COLONTOK;


      until Tok[i].Kind <> TTokenKind.COMMATOK;     // repeat

    CheckTok(i, TTokenKind.CPARTOK);

    end; // if Tok[i + 1].Kind = TTokenKind.SEMICOLONTOK

    if yes then a65(TCode65.putEOL);

    StopOptimization;

    Result := i;

    end;


  TTokenKind.ASMTOK:
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


     asm65('#asm:' + IntToStr(AsmBlockIndex));


//     if (OutputDisabled=false) and (Pass = CODE_GENERATION) then WriteOut(AsmBlock[AsmBlockIndex]);

     inc(AsmBlockIndex);

     if isAsm and (Tok[i].Value = 0) then begin

      CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      inc(i);

      CheckTok(i + 1, TTokenKind.ENDTOK);
      inc(i);

     end;

     Result:=i;

    end;


  TTokenKind.INCTOK, TTokenKind.DECTOK:
// dwie wersje
// krotka i szybka, jesli mamy jeden parametr, np. INC(VAR), DEC(VAR)
// dluga i wolna, jesli mamy tablice lub dwa parametry, np. INC(TMP[1]), DEC(VAR, VALUE+12)
    begin

      Value := 0;
      ExpressionType := TDataType.UNTYPETOK;
      NumActualParams := 0;

      Down := (Tok[i].Kind = TTokenKind.DECTOK);

      CheckTok(i + 1, TTokenKind.OPARTOK);

      inc(i, 2);

	  if Tok[i].Kind = TTokenKind.IDENTTOK then begin					// first parameter
	    IdentIndex := GetIdentIndex(Tok[i].Name);

	    CheckAssignment(i, IdentIndex);

	    if IdentIndex = 0 then
	     Error(i, TErrorCode.UnknownIdentifier);

	    if Ident[IdentIndex].Kind = VARIABLE then begin

	       ExpressionType := Ident[IdentIndex].DataType;

	       if ExpressionType = TDataType.CHARTOK then ExpressionType := TTokenKind.BYTETOK;	// wyjatkowo TTokenKind.CHARTOK -> TTokenKind.BYTETOK

	       if {((Ident[IdentIndex].DataType in Pointers) and
		   (Ident[IdentIndex].NumAllocElements=0)) or}
		   (Ident[IdentIndex].DataType = TDataType.REALTOK) then
		Error(i, 'Left side cannot be assigned to')
	       else begin
		Value := Ident[IdentIndex].Value;

		if ExpressionType in Pointers then begin			// Alloc Element Type
		 ExpressionType := TTokenKind.WORDTOK;

		 if pos('mw? '+Tok[i].Name, optyBP2) > 0 then optyBP2 := '';
		end;

	       end;

	    end else
	     Error(i, 'Left side cannot be assigned to');

	  end else
	     Error(i , TErrorCode.IdentifierExpected);


	  StartOptimization(i);

	  IndirectionLevel := ASPOINTER;

	  if Ident[IdentIndex].DataType in Pointers then
	   ExpressionType := TTokenKind.WORDTOK
	  else
	   ExpressionType := Ident[IdentIndex].DataType;


	  if Ident[IdentIndex].AllocElementType = TDataType.REALTOK then
	   Error(i, TErrorCode.OrdinalExpExpected);


	  if not (Ident[IdentIndex].idType in [TDataType.PCHARTOK]) and (Ident[IdentIndex].DataType in Pointers)
           and (Ident[IdentIndex].NumAllocElements > 0) and ( not(Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) ) then begin

	      if Tok[i + 1].Kind = TTokenKind.OBRACKETTOK then begin			// array index

		ExpressionType := Ident[IdentIndex].AllocElementType;

		IndirectionLevel := ASPOINTERTOARRAYORIGIN;

		i := CompileArrayIndex(i, IdentIndex);

		CheckTok(i + 1, TTokenKind.CBRACKETTOK);

		inc(i);

	      end else
	       if Tok[i + 1].Kind = TTokenKind.DEREFERENCETOK then
		Error(i + 1, TErrorCode.IllegalQualifier)
	       else
		ErrorIncompatibleTypes(i + 1, Ident[IdentIndex].DataType, ExpressionType);

	  end else

//          if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType <> 0) then begin

	  if Tok[i + 1].Kind = TTokenKind.OBRACKETTOK then begin				// typed pointer: PByte[], Pword[] ...

	    ExpressionType := Ident[IdentIndex].AllocElementType;

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN;

	    i := CompileArrayIndex(i, IdentIndex);

	    CheckTok(i + 1, TTokenKind.CBRACKETTOK);

	    inc(i);

	  end else

	  if Tok[i + 1].Kind = TTokenKind.DEREFERENCETOK then
	   if Ident[IdentIndex].AllocElementType = TDataType.UNTYPETOK then
	    Error(i + 1, TErrorCode.CantAdrConstantExp)
	   else begin

	     ExpressionType := Ident[IdentIndex].AllocElementType;

	     IndirectionLevel := ASPOINTERTOPOINTER;

	     inc(i);

	   end;


	 if Tok[i + 1].Kind = TTokenKind.COMMATOK then begin				// potencjalnie drugi parametr

	   j := i + 2;
	   yes:=false;

	   if SafeCompileConstExpression(j, ConstVal, ActualParamType, Ident[IdentIndex].DataType, true) then
	    yes:=true
	   else
	     j := CompileExpression(j, ActualParamType);

	   i := j;

	   GetCommonType(i, ExpressionType, ActualParamType);

	   inc(NumActualParams);

	   if Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING then begin

	    if yes = false then ExpandParam(ExpressionType, ActualParamType);

	    if  (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

	     if yes then
	      Push(ConstVal * RecordSize(IdentIndex), ASVALUE, 2)
	     else
	      Error(i, '-- under construction --');

	    end else
	    if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType in OrdinalTypes) and (IndirectionLevel <> ASPOINTERTOPOINTER) then begin	    // zwieksz o N * DATASIZE jesli to wskaznik ale nie tablica

	     if yes then begin

	      if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
	       Push(ConstVal, ASVALUE, GetDataSize( Ident[IdentIndex].DataType))
	      else
	       Push(ConstVal * GetDataSize( Ident[IdentIndex].AllocElementType), ASVALUE, GetDataSize( Ident[IdentIndex].DataType));

	     end else
	      GenerateIndexShift( Ident[IdentIndex].AllocElementType );		// * DATASIZE

	    end else
	     if yes then Push(ConstVal, ASVALUE, GetDataSize( Ident[IdentIndex].DataType));

	   end else begin

	    if yes then Push(ConstVal, ASVALUE, GetDataSize( Ident[IdentIndex].DataType));

	    ExpressionType := Ident[IdentIndex].AllocElementType;
	    if ExpressionType = TDataType.UNTYPETOK then ExpressionType := Ident[IdentIndex].DataType;	// RECORD.

	    ExpandParam(ExpressionType, ActualParamType);
	   end;


	 end else	// if Tok[i + 1].Kind = TTokenKind.COMMATOK

	   if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in OrdinalTypes + Pointers + [TDataType.RECORDTOK, TDataType.OBJECTTOK])) then

	     if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) or (Ident[IdentIndex].NumAllocElements > 0) or (IndirectionLevel = ASPOINTERTOPOINTER) or ((Ident[IdentIndex].NumAllocElements = 0) and (IndirectionLevel = ASPOINTERTOARRAYORIGIN)) then begin

	       ExpressionType := Ident[IdentIndex].AllocElementType;
 	       if ExpressionType = TDataType.UNTYPETOK then ExpressionType := Ident[IdentIndex].DataType;


	       if ExpressionType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
		Push(RecordSize(IdentIndex), ASVALUE, 2)
	       else
		Push(1, ASVALUE, GetDataSize( ExpressionType ));

	       inc(NumActualParams);
	     end else
	     if not (Ident[IdentIndex].AllocElementType in [TDataType.BYTETOK, TDataType.SHORTINTTOK]) then begin
	       Push(GetDataSize( Ident[IdentIndex].AllocElementType), ASVALUE, 1);			// +/- DATASIZE

	       ExpandParam(ExpressionType, TTokenKind.BYTETOK);

	       inc(NumActualParams);
	     end;


	 if (Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING) and (IndirectionLevel <> ASPOINTERTOARRAYORIGIN) then IndirectionLevel := ASPOINTERTOPOINTER;

	 if ExpressionType = TDataType.UNTYPETOK then
	  Error(i, 'Assignments to formal parameters and open arrays are not possible');

//       NumActualParams:=1;
//	 Value:=3;

	 if (NumActualParams = 0) then begin

	  asm65;

	  if Down then
	   asm65('; Dec(var X) -> ' + InfoAboutToken(ExpressionType))
	  else
	   asm65('; Inc(var X) -> ' + InfoAboutToken(ExpressionType));

	  asm65;

	  GenerateForToDoEpilog(ExpressionType, Down, IdentIndex, false, 0);		// +1, -1
	 end else
	  GenerateIncDec(IndirectionLevel, ExpressionType, Down, IdentIndex);		// +N, -N

	 StopOptimization;

	 inc(i);

      CheckTok(i, TTokenKind.CPARTOK);

      Result := i;
    end;


  TTokenKind.EXITTOK:
    begin

     if TOK[i + 1].Kind = TTokenKind.OPARTOK then begin

      StartOptimization(i);

      i := CompileExpression(i + 2, ActualParamType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      inc(i);

      yes := false;

      for j:=1 to NumIdent do
       if (Ident[j].ProcAsBlock = BlockStack[BlockStackTop]) and (Ident[j].Kind = TTokenKind.FUNCTIONTOK) then begin

	IdentIndex := GetIdentResult(BlockStack[BlockStackTop]);

	yes := true;
	Break;
       end;


      if not yes then
	Error(i, 'Procedures cannot return a value');

      if (ActualParamType = TDataType.STRINGPOINTERTOK) and ((Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0)) then
       ErrorIncompatibleTypes(i, ActualParamType, TTokenKind.PCHARTOK)
      else
       GetCommonConstType(i, Ident[IdentIndex].DataType, ActualParamType);

      GenerateAssignment(ASPOINTER, GetDataSize( Ident[IdentIndex].DataType), 0, 'RESULT');

     end;

     asm65(#9'jmp @exit');

     ResetOpty;

     Result := i;
    end;


  TTokenKind.BREAKTOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'BREAK not allowed');

//     asm65;
     asm65(#9'jmp b_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

     BreakPosStack[BreakPosStackTop].brk := true;

     ResetOpty;

     Result := i;
    end;


  TTokenKind.CONTINUETOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'CONTINUE not allowed');

//     asm65;
     asm65(#9'jmp c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

     BreakPosStack[BreakPosStackTop].cnt := true;

     Result := i;
    end;


  TTokenKind.HALTTOK:
    begin
     if Tok[i + 1].Kind = TTokenKind.OPARTOK then begin

      i := CompileConstExpression(i + 2, Value, ExpressionType);
      GetCommonConstType(i, TTokenKind.BYTETOK, ExpressionType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      inc(i, 1);

      GenerateProgramEpilog(Value);

     end else
      GenerateProgramEpilog(0);

    Result := i;
    end;


  TTokenKind.GETINTVECTOK:
    begin
    CheckTok(i + 1, TTokenKind.OPARTOK);

    i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
    GetCommonType(i, TTokenKind.INTEGERTOK, ActualParamType);

    CheckTok(i + 1, TTokenKind.COMMATOK);

    if not(byte(ConstVal) in [0..4]) then
      Error(i, 'Interrupt Number in [0..4]');

    CheckTok(i + 2, TTokenKind.IDENTTOK);
    IdentIndex := GetIdentIndex(Tok[i + 2].Name);

    if IdentIndex = 0 then
      Error(i + 2, TErrorCode.UnknownIdentifier);

    if not (Ident[IdentIndex].DataType in Pointers) then
      ErrorIncompatibleTypes(i + 2, Ident[IdentIndex].DataType , TTokenKind.POINTERTOK);

    svar := GetLocalName(IdentIndex);

    inc(i, 2);

    case ConstVal of
     ord(TInterruptCode.DLI): begin
		 asm65;
		 asm65(#9'lda VDSLST');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VDSLST+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(TInterruptCode.VBLI): begin
		 asm65;
		 asm65(#9'lda VVBLKI');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VVBLKI+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(TInterruptCode.VBLD): begin
		 asm65;
		 asm65(#9'lda VVBLKD');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VVBLKD+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(TInterruptCode.TIM1): begin
		 asm65;
		 asm65(#9'lda VTIMR1');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VTIMR1+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(TInterruptCode.TIM2): begin
		 asm65;
		 asm65(#9'lda VTIMR2');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VTIMR2+1');
		 asm65(#9'sta '+svar+'+1');
		end;

     ord(TInterruptCode.TIM4): begin
		 asm65;
		 asm65(#9'lda VTIMR4');
		 asm65(#9'sta '+svar);
		 asm65(#9'lda VTIMR4+1');
		 asm65(#9'sta '+svar+'+1');
		end;

    end;

    CheckTok(i + 1, TTokenKind.CPARTOK);

//    GenerateInterrupt(InterruptNumber);
    Result := i + 1;
    end;


  TTokenKind.SETINTVECTOK:
    begin
    CheckTok(i + 1, TTokenKind.OPARTOK);

    i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
    GetCommonType(i, TTokenKind.INTEGERTOK, ActualParamType);

    CheckTok(i + 1, TTokenKind.COMMATOK);

    StartOptimization(i + 1);

    if not(byte(ConstVal) in [0..4]) then
      Error(i, 'Interrupt Number in [0..4]');

    i := CompileExpression(i + 2, ActualParamType);
    GetCommonType(i, TTokenKind.POINTERTOK, ActualParamType);

    case ConstVal of
     ord(TInterruptCode.DLI): begin
		 asm65(#9'mva :STACKORIGIN,x VDSLST');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VDSLST+1');
		 a65(TCode65.subBX);
		end;

    ord(TInterruptCode.VBLI): begin
		 asm65(#9'lda :STACKORIGIN,x');
		 asm65(#9'ldy #5');
		 asm65(#9'sta wsync');
		 asm65(#9'dey');
		 asm65(#9'rne');
		 asm65(#9'sta VVBLKI');
		 asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
		 asm65(#9'sty VVBLKI+1');
		 a65(TCode65.subBX);
		end;

    ord(TInterruptCode.VBLD): begin
		 asm65(#9'lda :STACKORIGIN,x');
		 asm65(#9'ldy #5');
		 asm65(#9'sta wsync');
		 asm65(#9'dey');
		 asm65(#9'rne');
		 asm65(#9'sta VVBLKD');
		 asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
		 asm65(#9'sty VVBLKD+1');
		 a65(TCode65.subBX);
		end;

     ord(TInterruptCode.TIM1): begin
	         asm65(#9'sei');
		 asm65(#9'mva :STACKORIGIN,x VTIMR1');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR1+1');
		 a65(TCode65.subBX);

		 if Tok[i + 1].Kind = TTokenKind.COMMATOK then begin

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, TTokenKind.BYTETOK, ActualParamType);

		   asm65(#9'lda #$00');
		   asm65(#9'ldy #$03');
		   asm65(#9'sta AUDCTL');
		   asm65(#9'sta AUDC1');
		   asm65(#9'sty SKCTL');

		   asm65(#9'mva :STACKORIGIN,x AUDCTL');
	 	   a65(TCode65.subBX);

		   CheckTok(i + 1, TTokenKind.COMMATOK);

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, TTokenKind.BYTETOK, ActualParamType);

		   asm65(#9'mva :STACKORIGIN,x AUDF1');
	 	   a65(TCode65.subBX);

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

     ord(TInterruptCode.TIM2): begin
	         asm65(#9'sei');
		 asm65(#9'mva :STACKORIGIN,x VTIMR2');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR2+1');
		 a65(TCode65.subBX);

		 if Tok[i + 1].Kind = TTokenKind.COMMATOK then begin

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, TTokenKind.BYTETOK, ActualParamType);

		   asm65(#9'lda #$00');
		   asm65(#9'ldy #$03');
		   asm65(#9'sta AUDCTL');
		   asm65(#9'sta AUDC2');
		   asm65(#9'sty SKCTL');

		   asm65(#9'mva :STACKORIGIN,x AUDCTL');
	 	   a65(TCode65.subBX);

		   CheckTok(i + 1, TTokenKind.COMMATOK);

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, TTokenKind.BYTETOK, ActualParamType);

		   asm65(#9'mva :STACKORIGIN,x AUDF2');
	 	   a65(TCode65.subBX);

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

     ord(TInterruptCode.TIM4): begin
	         asm65(#9'sei');
		 asm65(#9'mva :STACKORIGIN,x VTIMR4');
		 asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR4+1');
		 a65(TCode65.subBX);

		 if Tok[i + 1].Kind = TTokenKind.COMMATOK then begin

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, TTokenKind.BYTETOK, ActualParamType);

		   asm65(#9'lda #$00');
		   asm65(#9'ldy #$03');
		   asm65(#9'sta AUDCTL');
		   asm65(#9'sta AUDC4');
		   asm65(#9'sty SKCTL');

		   asm65(#9'mva :STACKORIGIN,x AUDCTL');
	 	   a65(TCode65.subBX);

		   CheckTok(i + 1, TTokenKind.COMMATOK);

		   i := CompileExpression(i + 2, ActualParamType);
    		   GetCommonType(i, TTokenKind.BYTETOK, ActualParamType);

		   asm65(#9'mva :STACKORIGIN,x AUDF4');
	 	   a65(TCode65.subBX);

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

    CheckTok(i + 1, TTokenKind.CPARTOK);

//    GenerateInterrupt(InterruptNumber);
    Result := i + 1;
    end;

else
  Result := i - 1;
end;	// case

end;	//CompileStatement


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateProcFuncAsmLabels(BlockIdentIndex: integer; VarSize: Boolean = false);
var IdentIndex, size: integer;
    emptyLine, yes: Boolean;
    fnam, txt, svar: string;
    varbegin: TString;
    HeaFile: ITextFile;

// ----------------------------------------------------------------------------

   function Value(dorig: Boolean = false; brackets: Boolean = false): string;
   const reg: array [1..3] of string = (':EDX', ':ECX', ':EAX');			// !!! kolejnosc edx, ecx, eax !!! korzysta z tego memmove, memset !!!
   var v: Int64;
   begin

    v:=Ident[IdentIndex].Value;

    case Ident[IdentIndex].DataType of
     TTokenKind.SHORTREALTOK, TTokenKind.REALTOK: v := CastToReal(v);
                 TTokenKind.SINGLETOK: v := CastToSingle(v);
             TDataType.HALFSINGLETOK: v := CastToHalfSingle(v);
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
       1..3 : Result := #9'= ' + reg[(Ident[IdentIndex].Value shr 24) and $7f];
       4..19: Result := #9'= :STACKORIGIN-' + IntToStr(byte((Ident[IdentIndex].Value shr 24) and $7f) - 3);
      else
       Result := #9'= ''out of resource'''
      end;

      size := 0;
     end else

     if Ident[IdentIndex].isExternal {and (Ident[IdentIndex].Libraries = 0)} then begin
      Result := #9'= ' + Ident[IdentIndex].Alias;
     end else

     if Ident[IdentIndex].isAbsolute then begin

      if Ident[IdentIndex].Value < 0 then
       Result := #9'= DATAORIGIN+$'+IntToHex(abs(Ident[IdentIndex].Value), 4)
      else
       if abs(Ident[IdentIndex].Value) < 256 then
        Result := #9'= $' + IntToHex(byte(Ident[IdentIndex].Value), 2)
       else
        Result := #9'= $' + IntToHex(Ident[IdentIndex].Value, 4);

     end else

      if Ident[IdentIndex].NumAllocElements > 0 then
	Result := #9'= CODEORIGIN+$'+IntToHex(Ident[IdentIndex].Value - CODEORIGIN_BASE - CODEORIGIN, 4)
      else
       if abs(v) < 256 then
	Result := #9'= $'+IntToHex(byte(v), 2)
       else
	Result := #9'= $'+IntToHex(v, 4);

   end;

// ----------------------------------------------------------------------------

  function mads_data_size: string;
  begin

   Result := '';

   if Ident[IdentIndex].AllocElementType in [TDataType.BYTETOK..TDataType.FORWARDTYPE] then begin

      case GetDataSize( Ident[IdentIndex].AllocElementType) of
    	//1: Result := ' .byte';
    	2: Result := ' .word';
    	4: Result := ' .dword';
      end;

   end else
    Result := ' ; type unknown';

  end;

// ----------------------------------------------------------------------------

  function SetBank: Boolean;
  var i, IdentTemp: integer;
      hnam, rnam: string;
  begin

    Result := false;

    hnam:=AnsiUpperCase(ExtractFileName(fnam));
    hnam:=ChangeFileExt(hnam, '');

    for i := 0 to High(resArray) - 1 do begin

     rnam:=AnsiUpperCase(ExtractFileName(resArray[i].resFile));
     rnam:=ChangeFileExt(rnam, '');

     if hnam = rnam then begin
       IdentTemp := GetIdentIndex(resArray[i].resName);

       if IdentTemp > 0 then begin
        asm65('');
	asm65(#9'lmb #$' + IntToHex(Ident[IdentTemp].Value + 1,2));
	asm65('');

	Result := true;

        exit(true);
       end;


     end;

    end;

  end;

// ----------------------------------------------------------------------------

begin

 if Pass = TPass.CODE_GENERATION then begin

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


    if Ident[IdentIndex].isExternal and (Ident[IdentIndex].Libraries > 0) then begin			// read file header libraryname.hea

        fnam := linkObj[ Tok[Ident[IdentIndex].Libraries].Value ];


        if RCLIBRARY then
	 if SetBank = false then Error(Ident[IdentIndex].Libraries, 'Error: Bank identifier missing.');


	if ExtractFileExt(fnam) = '' then fnam := ChangeFileExt(fnam, '.hea');

        fnam := FindFile(fnam, 'header');

	if Ident[IdentIndex].isOverload then
	 svar := Ident[IdentIndex].Alias + '.' + GetOverloadName(IdentIndex)
	else
	 svar := Ident[IdentIndex].Alias;

	yes := TRUE;

    HeaFile:=TFileSystem.CreateTextFile;
    HeaFile.Assign(fnam); HeaFile.Reset;

    txt:='';
	while not HeaFile.EOF do begin
	  HeaFile.ReadLn(txt);

	  txt:=AnsiUpperCase(txt);

	  if (length(txt) > 255) or (pos(#0, txt) > 0) then begin
	   HeaFile.Close;

	   Error(Ident[IdentIndex].Libraries, 'Error: MADS header file ''' + fnam + ''' has invalid format.');
	  end;

	  if (txt.IndexOf('.@EXIT') < 0) and (txt.IndexOf('.@VARDATA') < 0) then			// skip '@.EXIT', '.@VARDATA'
	   if (pos('MAIN.' + svar + ' ', txt) = 1) or (pos('MAIN.' + svar + #9, txt) = 1) or (pos('MAIN.' + svar + '.', txt) = 1) then begin
	    yes := FALSE;

	    asm65( Ident[IdentIndex].Name + copy(txt, 6 + length(Ident[IdentIndex].Alias), length(txt)) );
	   end;

	end;

	if yes then
	  ErrorForIdentifier(Ident[IdentIndex].Libraries, TErrorCode.UnknownIdentifier, IdentIndex);

	HeaFile.Close;

    if RCLIBRARY then begin asm65(''); asm65(#9'rmb'); asm65('') end;				// reset bank -> #0

    end else


    case Ident[IdentIndex].Kind of

      VARIABLE: if Ident[IdentIndex].isAbsolute then begin		// ABSOLUTE = TRUE

		 if (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (Ident[IdentIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		  asm65('adr.'+Ident[IdentIndex].Name + Value);
		  asm65('.var '+Ident[IdentIndex].Name + #9'= adr.' + Ident[IdentIndex].Name + ' .word');

		  if size = 0 then varbegin := Ident[IdentIndex].Name;
		  inc(size, Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType) );

		 end else
		  if Ident[IdentIndex].DataType = TDataType.FILETOK then
		   asm65('.var '+Ident[IdentIndex].Name + Value + ' .word')
		  else
		   if pos('@FORTMP_', Ident[IdentIndex].Name) = 0 then asm65(Ident[IdentIndex].Name + Value);

		end else						// ABSOLUTE = FALSE

		 if (Ident[IdentIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and (Ident[IdentIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

//	writeln(Ident[IdentIndex].Name,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].IdType);

		  if ((Ident[IdentIndex].IdType <> TDataType.ARRAYTOK) and (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or (Ident[IdentIndex].IdType = TDataType.DATAORIGINOFFSET) then

		    asm65(Ident[IdentIndex].Name + Value(true))

		  else begin

		   if Ident[IdentIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
		     asm65('adr.' + Ident[IdentIndex].Name + Value(true) + #9'; [' + IntToStr(RecordSize(IdentIndex)) + '] ' + InfoAboutToken(Ident[IdentIndex].DataType))
		   else

		   if Elements(IdentIndex) > 0 then begin

//	writeln(Ident[IdentIndex].Name,' | ',Elements(IdentIndex),'/',Ident[IdentIndex].IdType,'/',Ident[IdentIndex].PassMethod ,' | ', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].IdType);

		    if (Ident[IdentIndex].NumAllocElements_ > 0) and not (Ident[IdentIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
		     asm65('adr.' + Ident[IdentIndex].Name + Value(true, true) + ' .array [' + IntToStr(Ident[IdentIndex].NumAllocElements) + '] [' + IntToStr(Ident[IdentIndex].NumAllocElements_) + ']' + mads_data_size)
		    else
  		     asm65('adr.' + Ident[IdentIndex].Name + Value(true, true) + ' .array [' + IntToStr(Elements(IdentIndex)) + ']' + mads_data_size);  // !!!!

		   end else
		    asm65('adr.' + Ident[IdentIndex].Name + Value(true));

		   asm65('.var ' + Ident[IdentIndex].Name + #9'= adr.' + Ident[IdentIndex].Name + ' .word');    // !!!!

		  end;

		  if size = 0 then varbegin := Ident[IdentIndex].Name;
		  inc(size, Ident[IdentIndex].NumAllocElements * GetDataSize( Ident[IdentIndex].AllocElementType) );

		 end else
		  if (Ident[IdentIndex].DataType = TDataType.FILETOK) {and (Ident[IdentIndex].Block = 1)} then
		   asm65('.var '+Ident[IdentIndex].Name + Value(true) + ' .word')	// tylko wskaznik
		  else begin
		   asm65(Ident[IdentIndex].Name + Value(true));

		   if size = 0 then varbegin := Ident[IdentIndex].Name;

		   if Ident[IdentIndex].idType <> TTokenKind.DATAORIGINOFFSET then			// indeksy do RECORD nie zliczaj

		     if (Ident[IdentIndex].Name = 'RESULT') and (Ident[BlockIdentIndex].Kind = TTokenKind.FUNCTIONTOK) then	// RESULT nie zliczaj

		     else
		      inc(size, GetDataSize( Ident[IdentIndex].DataType));

		  end;

      CONSTANT: if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then begin

		 asm65('adr.'+Ident[IdentIndex].Name + Value);
		 asm65('.var '+Ident[IdentIndex].Name+#9'= adr.' + Ident[IdentIndex].Name + ' .word');

		end else
		 if pos('@FORTMP_', Ident[IdentIndex].Name) = 0 then asm65(Ident[IdentIndex].Name + Value);
    end;

   end;

  if (BlockStack[BlockStackTop] <> 1) then begin

    asm65;

    if LIBRARY_USE then asm65('@InitLibrary'#9'= :START');

    if VarSize and (size > 0) then begin
      asm65('@VarData'#9'= '+varbegin);
      asm65('@VarDataSize'#9'= '+IntToStr(size));
      asm65;
    end;

  end;

 end;

end;	//GenerateProcFuncAsmLabels


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveToStaticDataSegment(ConstDataSize: integer; ConstVal: Int64; ConstValType: TDataType);
begin

	if (ConstDataSize < 0) or (ConstDataSize > $FFFF) then
        begin writeln('SaveToStaticDataSegment: ' + IntToStr(ConstDataSize));
              RaiseHaltException(THaltException.COMPILING_ABORTED);
        end;

	 case ConstValType of

	  TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK, TTokenKind.CHARTOK, TTokenKind.BOOLEANTOK:
		       StaticStringData[ConstDataSize] := byte(ConstVal);

	  TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK, TTokenKind.SHORTREALTOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK, TTokenKind.PCHARTOK:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	   TTokenKind.DATAORIGINOFFSET:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal) or $8000;
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8) or $4000;
		       end;

	   TTokenKind.CODEORIGINOFFSET:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal) or $2000;
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8) or $1000;
		       end;

	   TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK, TTokenKind.REALTOK:
		       begin
			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
			StaticStringData[ConstDataSize+2] := byte(ConstVal shr 16);
			StaticStringData[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	    TTokenKind.SINGLETOK: begin
			ConstVal:=CastToSingle(ConstVal);

			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
			StaticStringData[ConstDataSize+2] := byte(ConstVal shr 16);
			StaticStringData[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	 TTokenKind.HALFSINGLETOK: begin
			ConstVal:=CastToHalfSingle(ConstVal);

			StaticStringData[ConstDataSize]   := byte(ConstVal);
			StaticStringData[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	 end;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ReadDataArray(i: integer; ConstDataSize: integer; const ConstValType: TDataType; NumAllocElements: cardinal; StaticData: Boolean; Add: Boolean = false): integer;
var ActualParamType: TDataType;
    ch: byte;
    NumActualParams, NumActualParams_, NumAllocElements_: cardinal;
    ConstVal: Int64;

// ----------------------------------------------------------------------------

procedure SaveDataSegment(DataType: TDataType);
begin

   if StaticData then
    SaveToStaticDataSegment(ConstDataSize, ConstVal + ord(Add), DataType)
   else
    SaveToDataSegment(ConstDataSize, ConstVal + ord(Add), DataType);

   if DataType = TTokenKind.DATAORIGINOFFSET then
    inc(ConstDataSize, GetDataSize(TDataType.POINTERTOK) )
   else
    inc(ConstDataSize, GetDataSize( DataType ));

end;


// ----------------------------------------------------------------------------

procedure SaveData(compile: Boolean = true);
begin

   if compile then
     i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


  if (ConstValType = TDataType.STRINGPOINTERTOK) and (ActualParamType = TDataType.CHARTOK) then begin	// rejestrujemy CHAR jako STRING

    if StaticData then
      Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

    ch := Tok[i].Value;
    DefineStaticString(i, chr(ch));

    ConstVal:=Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
    Tok[i].Value := ch;

    ActualParamType := TTokenKind.STRINGPOINTERTOK;

  end;


  if (ConstValType in StringTypes + [TDataType.CHARTOK, TDataType.STRINGPOINTERTOK]) and (ActualParamType in IntegerTypes + RealTypes) then
    Error(i, TErrorCode.IllegalExpression);


  if (ConstValType in StringTypes + [TDataType.STRINGPOINTERTOK]) and (ActualParamType = TDataType.CHARTOK) then
   ErrorIncompatibleTypes(i, ActualParamType, ConstValType);


  if (ConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and (ActualParamType = TDataType.REALTOK) then
   ActualParamType := ConstValType;

  if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then begin
   ConstVal:=FromInt64(ConstVal);
   ActualParamType := ConstValType;
  end;

  if (ConstValType = TDataType.SHORTREALTOK) and (ActualParamType = TDataType.REALTOK) then
   ActualParamType := TTokenKind.SHORTREALTOK;


  if ActualParamType = TTokenKind.DATAORIGINOFFSET then

   SaveDataSegment(TTokenKind.DATAORIGINOFFSET)

  else begin

   if ConstValType in IntegerTypes then begin

    if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
     WarningForRangeCheckError(i, ConstVal, ConstValType);

   end else
    GetCommonConstType(i, ConstValType, ActualParamType);

   SaveDataSegment(ConstValType);

  end;

end;


// ----------------------------------------------------------------------------

{$i include/doevaluate.inc}

// ----------------------------------------------------------------------------


begin

// yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

{
  if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) and (ConstValType = TDataType.CHARTOK) then begin		// init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   if Tok[i].StrLength > NumAllocElements then
     Error(i, 'string length is larger than array of char length');

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > Tok[i].StrLength then
     ConstVal := byte(' ')
    else
     ConstVal := byte(StaticStringData[Tok[i].StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;
}

  CheckTok(i, TTokenKind.OPARTOK);

  NumActualParams := 0;
  NumActualParams_:= 0;

  NumAllocElements_ := NumAllocElements shr 16;
  NumAllocElements  := NumAllocElements and $ffff;

  repeat

  inc(NumActualParams);
//  if NumActualParams > NumAllocElements then Break;

  if NumAllocElements_ > 0 then begin

   NumActualParams_ := 0;

   CheckTok(i + 1, TTokenKind.OPARTOK);
   inc(i);

   repeat
    inc(NumActualParams_);
    if NumActualParams_ > NumAllocElements_ then Break;

    SaveData;

    inc(i);
   until Tok[i].Kind <> TTokenKind.COMMATOK;

   CheckTok(i, TTokenKind.CPARTOK);

   //inc(i);
  end else
   //SaveData;
    if Tok[i + 1].Kind = TTokenKind.EVALTOK then
      NumActualParams := doEvaluate(evaluationContext)
    else
      SaveData;


  inc(i);

 until Tok[i].Kind <> TTokenKind.COMMATOK;

 CheckTok(i, TTokenKind.CPARTOK);


 if NumActualParams > NumAllocElements then
  Error(i, 'Number of elements (' + IntToStr(NumActualParams) + ') differs from declaration (' + IntToStr(NumAllocElements) + ')');

 if NumActualParams < NumAllocElements then
  Error(i, 'Expected another '+IntToStr(NumAllocElements - NumActualParams)+' array elements');

 if NumActualParams_ < NumAllocElements_ then
  Error(i, 'Expected another '+IntToStr(NumAllocElements_ - NumActualParams_)+' array elements');

 Result := i;

end;	//ReadDataArray


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ReadDataOpenArray(i: integer; ConstDataSize: integer; const ConstValType: TDataType; out NumAllocElements: cardinal; StaticData: Boolean; Add: Boolean = false): integer;
var ActualParamType: TDataType;
    ch: byte;
    NumActualParams: cardinal;
    ConstVal: Int64;


// ----------------------------------------------------------------------------


procedure SaveDataSegment(DataType: TDataType);
begin

   if StaticData then
    SaveToStaticDataSegment(ConstDataSize, ConstVal + ord(Add), DataType)
   else
    SaveToDataSegment(ConstDataSize, ConstVal + ord(Add), DataType);

   if DataType = TDataType.DATAORIGINOFFSET then
    inc(ConstDataSize, GetDataSize(TDataType.POINTERTOK) )
   else
    inc(ConstDataSize, GetDataSize( DataType ) );

end;


// ----------------------------------------------------------------------------


procedure SaveData(compile: Boolean = true);
begin

   if compile then
     i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


  if (ConstValType = TDataType.STRINGPOINTERTOK) and (ActualParamType = TDataType.CHARTOK) then begin	// rejestrujemy CHAR jako STRING

    if StaticData then
      Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

    ch := Tok[i].Value;
    DefineStaticString(i, chr(ch));

    ConstVal := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
    Tok[i].Value := ch;

    ActualParamType := TTokenKind.STRINGPOINTERTOK;

  end;


  if (ConstValType in StringTypes + [TDataType.CHARTOK, TDataType.STRINGPOINTERTOK]) and (ActualParamType in IntegerTypes + RealTypes) then
    Error(i, TErrorCode.IllegalExpression);


  if (ConstValType in StringTypes + [TDataType.STRINGPOINTERTOK]) and (ActualParamType = TDataType.CHARTOK) then
   ErrorIncompatibleTypes(i, ActualParamType, ConstValType);


  if (ConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and (ActualParamType = TDataType.REALTOK) then
   ActualParamType := ConstValType;

  if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then begin
   ConstVal:=FromInt64(ConstVal);
   ActualParamType := ConstValType;
  end;

  if (ConstValType = TDataType.SHORTREALTOK) and (ActualParamType = TDataType.REALTOK) then
   ActualParamType := TTokenKind.SHORTREALTOK;


  if ActualParamType = TTokenKind.DATAORIGINOFFSET then

   SaveDataSegment(TTokenKind.DATAORIGINOFFSET)

  else begin

   if ConstValType in IntegerTypes then begin

    if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
     WarningForRangeCheckError(i, ConstVal, ConstValType);

   end else
    GetCommonConstType(i, ConstValType, ActualParamType);

   SaveDataSegment(ConstValType);

  end;

  inc(NumActualParams);

end;


// ----------------------------------------------------------------------------

{$i include/doevaluate.inc}

// ----------------------------------------------------------------------------

begin

// yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
{
  if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) and (ConstValType = TDataType.CHARTOK) then begin		// init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   NumAllocElements := Tok[i].StrLength;

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > Tok[i].StrLength then
     ConstVal := byte(' ')
    else
     ConstVal := byte(StaticStringData[Tok[i].StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;
}

  CheckTok(i, TTokenKind.OBRACKETTOK);

  NumActualParams := 0;
  NumAllocElements := 0;


  if Tok[i + 1].Kind = TTokenKind.CBRACKETTOK then

   inc(i)

  else
  repeat

    if Tok[i + 1].Kind = TTokenKind.EVALTOK then
      doEvaluate(evaluationContext)
    else
      SaveData;

    inc(i);

  until Tok[i].Kind <> TTokenKind.COMMATOK;


 CheckTok(i, TTokenKind.CBRACKETTOK);

 NumAllocElements := NumActualParams;

 Result := i;

end;	//ReadDataOpenArray


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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

 asm65('.local'#9 + Ident[BlockIdentIndex].Name, info);

 if Ident[BlockIdentIndex].isOverload then
   asm65('.local'#9 + GetOverloadName(BlockIdentIndex));

{
 if Ident[BlockIdentIndex].isOverload then
   asm65('.local'#9 + Ident[BlockIdentIndex].Name+'_'+IntToHex(Ident[BlockIdentIndex].Value, 4), info)
 else
   asm65('.local'#9 + Ident[BlockIdentIndex].Name, info);
}
 if Ident[BlockIdentIndex].isInline then asm65(#13#10#9'.MACRO m@INLINE');

end;	//GenerateLocal


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure FormalParameterList(var i: integer; var NumParams: integer; var Param: TParamList; out Status: word; IsNestedFunction: Boolean; out NestedFunctionResultType: TDataType; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: TDataType);
var ListPassMethod: TParameterPassingMethod;
    NumVarOfSameType: byte;
    VarTYpe, AllocElementType: TDataType;
    NumAllocElements: cardinal;
    VarOfSameTypeIndex: integer;
    VarOfSameType: TVariableList;
begin

      //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
      VarOfSameType := Default(TVariableList);

      NumParams := 0;

      if (Tok[i + 3].Kind = TTokenKind.CPARTOK) and (Tok[i + 2].Kind = TTokenKind.OPARTOK) then
       i := i + 4
      else

      if (Tok[i + 2].Kind = TTokenKind.OPARTOK) then			   // Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := TParameterPassingMethod.VALPASSING;

	  if Tok[i + 1].Kind = TTokenKind.CONSTTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = TTokenKind.VARTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
	      Error(i + 1, 'Formal parameter name expected but ' + GetSpelling(i + 1) + ' found')
	    else
	      begin
	      Inc(NumVarOfSameType);
	      VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name;
	      end;
	    i := i + 2;
	    until Tok[i].Kind <> TTokenKind.COMMATOK;


	  VarType := TDataType.UNTYPETOK;
	  NumAllocElements := 0;
	  AllocElementType := TDataType.UNTYPETOK;

	  if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING])  and (Tok[i].Kind <> TTokenKind.COLONTOK) then begin

	   ListPassMethod := TParameterPassingMethod.VARPASSING;
	   dec(i);

	  end else begin

	   CheckTok(i, TTokenKind.COLONTOK);

	   if Tok[i + 1].Kind = TTokenKind.DEREFERENCETOK then			// ^type
	     Error(i + 1, 'Type identifier expected');

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = TDataType.FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
	     Error(i, 'File types must be var parameters');

	  end;


	  for VarOfSameTypeIndex := 1 to NumVarOfSameType do
	    begin

//	    if NumAllocElements > 0 then
//	      Error(i, 'Structured parameters cannot be passed by value');

	    Inc(NumParams);
	    if NumParams > MAXPARAMS then
	      ErrorForIdentifier(i, TErrorCode.TooManyParameters, NumIdent)
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
	until Tok[i].Kind <> TTokenKind.SEMICOLONTOK;

	CheckTok(i, TTokenKind.CPARTOK);

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

	CheckTok(i, TTokenKind.COLONTOK);

	if Tok[i + 1].Kind = TDataType.ARRAYTOK then
	  Error(i + 1, 'Type identifier expected');

	i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	NestedFunctionResultType := VarType;			   // Result
	NestedFunctionNumAllocElements := NumAllocElements;
	NestedFunctionAllocElementType := AllocElementType;

	i := i + 1;
	end;	// if IsNestedFunction

	CheckTok(i, TTokenKind.SEMICOLONTOK);


	while Tok[i + 1].Kind in [TTokenKind.OVERLOADTOK, TTokenKind.ASSEMBLERTOK, TTokenKind.FORWARDTOK, TTokenKind.REGISTERTOK, TTokenKind.INTERRUPTTOK, TTokenKind.PASCALTOK, TTokenKind.STDCALLTOK, TTokenKind.INLINETOK, TTokenKind.KEEPTOK] do begin

	  case Tok[i + 1].Kind of

	    TTokenKind.OVERLOADTOK: begin
			   SetModifierBit(TModifierCode.mOverload, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

	   TTokenKind.ASSEMBLERTOK: begin
			   SetModifierBit(TModifierCode.mAssembler, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

{	     TTokenKind.FORWARDTOK: begin
			   SetModifierBit(TModifierCode.mForward, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;
 }
	    TTokenKind.REGISTERTOK: begin
			   SetModifierBit(TModifierCode.mRegister, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

	      TTokenKind.STDCALLTOK: begin
			   SetModifierBit(TModifierCode.mStdCall, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

	      TTokenKind.INLINETOK: begin
			   SetModifierBit(TModifierCode.mInline, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

	   TTokenKind.INTERRUPTTOK: begin
			   SetModifierBit(TModifierCode.mInterrupt, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

	      TTokenKind.PASCALTOK: begin
			   SetModifierBit(TModifierCode.mPascal, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;

             TTokenKind.KEEPTOK: begin
			   SetModifierBit(TModifierCode.mKeep, Status);
			   inc(i);
			   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
			 end;
	  end;

	  inc(i);
	end;// while

end;	//FormalParameterList


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckForwardResolutions(typ: Boolean = true);
var TypeIndex, IdentIndex: Integer;
    Name: string;
begin

// Search for unresolved forward references
for TypeIndex := 1 to NumIdent do
  if (Ident[TypeIndex].AllocElementType = TDataType.FORWARDTYPE) and
     (Ident[TypeIndex].Block = BlockStack[BlockStackTop]) then begin

     Name := Ident[GetIdentIndex(Tok[Ident[TypeIndex].NumAllocElements].Name)].Name;

     if Ident[GetIdentIndex(Tok[Ident[TypeIndex].NumAllocElements].Name)].Kind = TTokenKind.TYPETOK then

     for IdentIndex := 1 to NumIdent do
       if (Ident[IdentIndex].Name = Name) and
          (Ident[IdentIndex].Block = BlockStack[BlockStackTop]) then begin

	   Ident[TypeIndex].NumAllocElements  := Ident[IdentIndex].NumAllocElements;
	   Ident[TypeIndex].NumAllocElements_ := Ident[IdentIndex].NumAllocElements_;
	   Ident[TypeIndex].AllocElementType  := Ident[IdentIndex].DataType;

	   Break;
	  end;

    end;


// Search for unresolved forward references
for TypeIndex := 1 to NumIdent do
  if (Ident[TypeIndex].AllocElementType = TDataType.FORWARDTYPE) and
     (Ident[TypeIndex].Block = BlockStack[BlockStackTop]) then

      if typ then
        Error(TypeIndex, 'Unresolved forward reference to type ' + Ident[TypeIndex].Name)
      else
        Error(TypeIndex, 'Identifier not found "' + Ident[GetIdentIndex(Tok[Ident[TypeIndex].NumAllocElements].Name)].Name + '"');

end;	//CheckForwardResolutions


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileRecordDeclaration(var VarOfSameType: TVariableList; var tmpVarDataSize: integer; var ConstVal: Int64; VarOfSameTypeIndex: integer; VarType, AllocElementType: TDataType; NumAllocElements: cardinal; isAbsolute: Boolean);
var tmpVarDataSize_, ParamIndex{, idx}: integer;
begin

//	writeln(iDtype,',',VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',TypeArray[NumAllocElements].Block,' | ', AllocElementType);

   if ( (VarType in Pointers) and (AllocElementType = TDataType.RECORDTOK) ) then begin

//	 writeln('> ',VarOfSameType[VarOfSameTypeIndex].Name,',',NestedDataType, ',',NestedAllocElementType,',', NestedNumAllocElements,',',NestedNumAllocElements and $ffff,'/',NestedNumAllocElements shr 16);

	 tmpVarDataSize_ := VarDataSize;


	 if (NumAllocElements shr 16) > 0 then begin											// array [0..x] of record

	   Ident[NumIdent].NumAllocElements  := NumAllocElements and $FFFF;
	   Ident[NumIdent].NumAllocElements_ := NumAllocElements shr 16;

	   VarDataSize := tmpVarDataSize + (NumAllocElements shr 16) * GetDataSize(TDataType.POINTERTOK);

	   tmpVarDataSize := VarDataSize;

	   NumAllocElements := NumAllocElements and $FFFF;

	 end else
	   if Ident[NumIdent].isAbsolute = false then inc(tmpVarDataSize, GetDataSize(TDataType.POINTERTOK));		// wskaznik dla ^record


	 //idx := Ident[NumIdent].Value - DATAORIGIN;

//writeln(NumAllocElements);
//!@!@
	 for ParamIndex := 1 to TypeArray[NumAllocElements].NumFields do									// label: ^record
	  if (TypeArray[NumAllocElements].Block = 1) or (TypeArray[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//	    writeln('a ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + TypeArray[NumAllocElements].Field[ParamIndex].Name,',',TypeArray[NumAllocElements].Field[ParamIndex].DataType,',',TypeArray[NumAllocElements].Field[ParamIndex].AllocElementType,',',TypeArray[NumAllocElements].Field[ParamIndex].NumAllocElements);

	    DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + TypeArray[NumAllocElements].Field[ParamIndex].Name,
	    VARIABLE,
	    TypeArray[NumAllocElements].Field[ParamIndex].DataType,
	    TypeArray[NumAllocElements].Field[ParamIndex].NumAllocElements,
	    TypeArray[NumAllocElements].Field[ParamIndex].AllocElementType, 0, TTokenKind.DATAORIGINOFFSET);

	    Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize_;
	    Ident[NumIdent].PassMethod := TParameterPassingMethod.VARPASSING;
//	    Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;

	  end;

	  VarDataSize := tmpVarDataSize;

   end else

	if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then											// label: record
	 for ParamIndex := 1 to TypeArray[NumAllocElements].NumFields do
	  if (TypeArray[NumAllocElements].Block = 1) or (TypeArray[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//	    writeln('b ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + TypeArray[NumAllocElements].Field[ParamIndex].Name,',',TypeArray[NumAllocElements].Field[ParamIndex].DataType,',',TypeArray[NumAllocElements].Field[ParamIndex].AllocElementType,',',TypeArray[NumAllocElements].Field[ParamIndex].NumAllocElements,' | ',Ident[NumIdent].Value);

 	    tmpVarDataSize_ := VarDataSize;

	    DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + TypeArray[NumAllocElements].Field[ParamIndex].Name,
	    VARIABLE,
	    TypeArray[NumAllocElements].Field[ParamIndex].DataType,
	    TypeArray[NumAllocElements].Field[ParamIndex].NumAllocElements,
	    TypeArray[NumAllocElements].Field[ParamIndex].AllocElementType, ord(isAbsolute) * ConstVal);

	    if isAbsolute then
	      if not (TypeArray[NumAllocElements].Field[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then				// fixed https://forums.atariage.com/topic/240919-mad-pascal/?do=findComment&comment=5422587
		inc(ConstVal, VarDataSize - tmpVarDataSize_);//    GetDataSize( TDataType.TypeArray[NumAllocElements].Field[ParamIndex].DataType]);

	  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileBlock(i: Integer; BlockIdentIndex: Integer; NumParams: Integer; IsFunction: Boolean; FunctionResultType: TDataType; FunctionNumAllocElements: cardinal = 0; FunctionAllocElementType: TDataType = TDataType.UNTYPETOK): Integer;
var
  VarOfSameType: TVariableList;
  Param: TParamList;
  j, idx, NumVarOfSameType, VarOfSameTypeIndex, tmpVarDataSize, ParamIndex, ForwardIdentIndex, IdentIndex, external_libr: integer;
  NumAllocElements, NestedNumAllocElements, NestedFunctionNumAllocElements: cardinal;
  ConstVal: Int64;
  ImplementationUse, open_array, iocheck_old, isInterrupt_old, yes, Assignment, {pack,} IsNestedFunction,
  isAbsolute, isExternal, isForward, isVolatile, isStriped, isAsm, isReg, isInt, isInl, isOvr: Boolean;
  VarType, VarRegister, NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType,
  NestedFunctionAllocElementType, NestedDataType, NestedAllocElementType, IdType: Byte;
  varPassMethod: TParameterPassingMethod;
  Tmp, TmpResult: word;

  external_name: TString;

  UnitList: array of TString;

begin

ResetOpty;

//FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
VarOfSameType:=Default(TVariableList);

j := 0;
ConstVal := 0;
VarRegister := 0;

external_libr := 0;
external_name := '';

NestedDataType := 0;
NestedAllocElementType := 0;
NestedNumAllocElements := 0;
ParamIndex := 0;

varPassMethod := TParameterPassingMethod.UNDEFINED;

ImplementationUse:=false;

Param := Ident[BlockIdentIndex].Param;
isAsm := Ident[BlockIdentIndex].isAsm;
isReg := Ident[BlockIdentIndex].isRegister;
isInt := Ident[BlockIdentIndex].isInterrupt;
isInl := Ident[BlockIdentIndex].isInline;
isOvr := Ident[BlockIdentIndex].isOverload;

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

  if Ident[BlockIdentIndex].ObjectIndex > 0 then begin
   asm65(#9'sta :bp2');
   asm65(#9'sty :bp2+1');
  end;

  asm65('@new'#9'lda <@VarData');			// @AllocMem
  asm65(#9'sta :ztmp');
  asm65(#9'lda >@VarData');
  asm65(#9'ldy #@VarDataSize-1');
  asm65(#9'jsr @AllocMem');

  if Ident[BlockIdentIndex].ObjectIndex > 0 then begin
   asm65(#9'lda :bp2');
   asm65(#9'ldy :bp2+1');
  end;

  asm65(#9'eif');
 end;

end;


if Ident[BlockIdentIndex].ObjectIndex > 0 then begin

//  if ParamIndex = 1 then begin
   asm65(#9'sta ' + TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name);
   asm65(#9'sty ' + TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name + '+1');

   DefineIdent(i, TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name, VARIABLE,  TTokenKind.WORDTOK, 0 , TDataType.UNTYPETOK, 0);
   Ident[NumIdent].PassMethod := TParameterPassingMethod.VARPASSING;
   Ident[NumIdent].AllocElementType := TTokenKind.WORDTOK;
//  end;

 NumAllocElements := 0;

 for ParamIndex := 1 to TypeArray[Ident[BlockIdentIndex].ObjectIndex].NumFields do
  if TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Kind = TFieldKind.UNTYPETOK then begin


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

    asm65(#9'sta ' + TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name);
    asm65(#9'sty ' + TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name+'+1');


  if ParamIndex <> TypeArray[Ident[BlockIdentIndex].ObjectIndex].NumFields then begin

   if (TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType = TDataType.POINTERTOK) and
      (TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements > 0) then begin

      NumAllocElements := TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements and $ffff;

      if TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements shr 16 > 0 then
       NumAllocElements:=(NumAllocElements * (TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements shr 16));

      NumAllocElements := NumAllocElements * GetDataSize( TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType );

   end else
    case TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType of
	      TDataType.FILETOK: NumAllocElements := 12;
     TDataType.STRINGPOINTERTOK: NumAllocElements := TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements;
	    TDataType.RECORDTOK: NumAllocElements := ObjectRecordSize(TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements);
    else
      NumAllocElements := GetDataSize( TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType );

    end;

  end;

 end;

 end;   // Ident[BlockIdentIndex].ObjectIndex


//writeln;
// Allocate parameters as local variables of the current block if necessary
for ParamIndex := 1 to NumParams do
  begin

//	writeln(Param[ParamIndex].Name,':',Param[ParamIndex].DataType,'|',Param[ParamIndex].NumAllocElements and $FFFF,'/',Param[ParamIndex].NumAllocElements shr 16);

    if Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then begin

     if isReg and (ParamIndex in [1..3]) then begin
      tmpVarDataSize := VarDataSize;

      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      Ident[GetIdentIndex(Param[ParamIndex].Name)].isAbsolute := true;
      Ident[GetIdentIndex(Param[ParamIndex].Name)].Value := (byte(ParamIndex) shl 24) or $80000000;

      VarDataSize := tmpVarDataSize;

     end else
      if Param[ParamIndex].DataType in Pointers then
       DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, 0, Param[ParamIndex].DataType, 0)
      else
       DefineIdent(i, Param[ParamIndex].Name, VARIABLE, TTokenKind.POINTERTOK, 0, Param[ParamIndex].DataType, 0);


     if (Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

      tmpVarDataSize := VarDataSize;

      for j := 1 to TypeArray[Param[ParamIndex].NumAllocElements].NumFields do begin

       DefineIdent(i, Param[ParamIndex].Name + '.' + TypeArray[Param[ParamIndex].NumAllocElements].Field[j].Name,
		   VARIABLE,
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].DataType,
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, TTokenKind.DATAORIGINOFFSET);

       Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize;
       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;

       if Ident[NumIdent].AllocElementType = TDataType.UNTYPETOK then Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;

      end;

      VarDataSize := tmpVarDataSize;

     end else

      if Param[ParamIndex].DataType in Pointers then
	Ident[GetIdentIndex(Param[ParamIndex].Name)].AllocElementType := Param[ParamIndex].AllocElementType
      else
	Ident[GetIdentIndex(Param[ParamIndex].Name)].AllocElementType := Param[ParamIndex].DataType;

      Ident[GetIdentIndex(Param[ParamIndex].Name)].NumAllocElements := Param[ParamIndex].NumAllocElements and $FFFF;
      Ident[GetIdentIndex(Param[ParamIndex].Name)].NumAllocElements_ := Param[ParamIndex].NumAllocElements shr 16;

    end else begin
     if isReg and (ParamIndex in [1..3]) then begin
      tmpVarDataSize := VarDataSize;

      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      Ident[GetIdentIndex(Param[ParamIndex].Name)].isAbsolute := true;
      Ident[GetIdentIndex(Param[ParamIndex].Name)].Value := (byte(ParamIndex) shl 24) or $80000000;

      VarDataSize := tmpVarDataSize;

     end else
      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

//	writeln(Param[ParamIndex].Name,',',Param[ParamIndex].DataType);

     if (Param[ParamIndex].DataType = TDataType.POINTERTOK) and (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin		// fix issue #94
																	//
      tmpVarDataSize := VarDataSize;													//
																	//
      for j := 1 to TypeArray[Param[ParamIndex].NumAllocElements].NumFields do begin							//
																	//
       DefineIdent(i, Param[ParamIndex].Name + '.' + TypeArray[Param[ParamIndex].NumAllocElements].Field[j].Name,				//
		   VARIABLE,														//
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].DataType,								//
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,							//
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, TTokenKind.DATAORIGINOFFSET);				//
																	//
       Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize;									//
       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;									//
																	//
       if Ident[NumIdent].AllocElementType = TDataType.UNTYPETOK then Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;		//
																	//
      end;																//
																	//
      VarDataSize := tmpVarDataSize;													//
																	//
     end else

     if Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
      for j := 1 to TypeArray[Param[ParamIndex].NumAllocElements].NumFields do begin

// writeln(Param[ParamIndex].Name + '.' + TypeArray[Param[ParamIndex].NumAllocElements].Field[j].Name,',',TypeArray[Param[ParamIndex].NumAllocElements].Field[j].DataType,',',TypeArray[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,',',TypeArray[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType);

	 DefineIdent(i, Param[ParamIndex].Name + '.' + TypeArray[Param[ParamIndex].NumAllocElements].Field[j].Name,
		   VARIABLE,
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].DataType,
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
		   TypeArray[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0);

       Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;
      end;

    end;

    Ident[GetIdentIndex(Param[ParamIndex].Name)].PassMethod := Param[ParamIndex].PassMethod;
  end;


// Allocate Result variable if the current block is a function
if IsFunction then begin	//DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, 0, 0, 0);

    tmpVarDataSize := VarDataSize;

//	writeln(Ident[BlockIdentIndex].name,',',FunctionResultType,',',FunctionNumAllocElements,',',FunctionAllocElementType);

    DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, FunctionNumAllocElements, FunctionAllocElementType, 0);

    if isReg and (FunctionResultType in OrdinalTypes + RealTypes) then begin
      Ident[NumIdent].isAbsolute := true;
      Ident[NumIdent].Value := $87000000;	// :STACKORIGIN-4 -> :TMP

      VarDataSize := tmpVarDataSize;
    end;

    if FunctionResultType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
     for j := 1 to TypeArray[FunctionNumAllocElements].NumFields do begin

       DefineIdent(i, 'RESULT.'+TypeArray[FunctionNumAllocElements].Field[j].Name,
		   VARIABLE,
		   TypeArray[FunctionNumAllocElements].Field[j].DataType,
		   TypeArray[FunctionNumAllocElements].Field[j].NumAllocElements,
		   TypeArray[FunctionNumAllocElements].Field[j].AllocElementType, 0);

//       Ident[GetIdentIndex(iname)].PassMethod := VALPASSING;
     end;

end;


yes := {(Ident[BlockIdentIndex].ObjectIndex > 0) or} Ident[BlockIdentIndex].isRecursion or Ident[BlockIdentIndex].isStdCall;

for ParamIndex := NumParams downto 1 do
 if not ( (Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING) or
          ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].NumAllocElements and $FFFF in [0,1])) or
          ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK])) or
	  (Param[ParamIndex].DataType in OrdinalTypes + RealTypes)
	) then begin yes := TRUE; Break end;


// yes:=true;


// Load ONE parameters from the stack
if (Ident[BlockIdentIndex].ObjectIndex = 0) then
 if (yes = false) and (NumParams = 1) and (GetDataSize( Param[1].DataType) = 1) and (Param[1].PassMethod <> TParameterPassingMethod.VARPASSING) then asm65(#9'sta ' + Param[1].Name);


// Load parameters from the stack
if yes then begin
 for ParamIndex := 1 to NumParams do begin

  if Ident[BlockIdentIndex].isRecursion or Ident[BlockIdentIndex].isStdCall or (NumParams = 1) then begin

	if Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then
	  GenerateAssignment(ASPOINTER, GetDataSize(TDataType.POINTERTOK), 0, Param[ParamIndex].Name)
	else
	  GenerateAssignment(ASPOINTER, GetDataSize( Param[ParamIndex].DataType), 0, Param[ParamIndex].Name);


  	if (Param[ParamIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and
     	   (Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
     	   (Param[ParamIndex].NumAllocElements and $FFFF > 1) then			// copy arrays

   	if Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then begin

    	   asm65(':move');
    	   asm65(Param[ParamIndex].Name);
    	   asm65(IntToStr( RecordSize(GetIdentIndex(Param[ParamIndex].Name)) ));

   	end else
  	 if not (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

	   if Param[ParamIndex].NumAllocElements shr 16 <> 0 then
     	     NumAllocElements := (Param[ParamIndex].NumAllocElements and $FFFF) * (Param[ParamIndex].NumAllocElements shr 16)
    	   else
     	     NumAllocElements := Param[ParamIndex].NumAllocElements;

    	   asm65(':move');
    	   asm65(Param[ParamIndex].Name);
    	   asm65(IntToStr(integer(NumAllocElements * GetDataSize( Param[ParamIndex].AllocElementType))));
   	end;

  end else begin

  	Assignment := true;

  	if (Param[ParamIndex].PassMethod <> TParameterPassingMethod.VARPASSING) and
     	   (Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) and
     	   (Param[ParamIndex].NumAllocElements and $FFFF > 1) then			// copy arrays

   	if Param[ParamIndex].DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then begin

	   Assignment := false;
	   asm65(#9'dex');

 	end else
  	 if not (Param[ParamIndex].AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then begin

	   Assignment := false;
	   asm65(#9'dex');

	end;

  	if Assignment then
	  if Param[ParamIndex].PassMethod = TParameterPassingMethod.VARPASSING then
	    GenerateAssignment(ASPOINTER, GetDataSize(TDataType.POINTERTOK), 0, Param[ParamIndex].Name)
	  else
	    GenerateAssignment(ASPOINTER, GetDataSize( Param[ParamIndex].DataType), 0, Param[ParamIndex].Name);
  end;

  if (Paramindex <> NumParams) then asm65(#9'jmi @main');

 end;

 asm65('@main');
end;


// Object variable definitions
if Ident[BlockIdentIndex].ObjectIndex > 0 then
 for ParamIndex := 1 to TypeArray[Ident[BlockIdentIndex].ObjectIndex].NumFields do begin

  tmpVarDataSize := VarDataSize;

{
  writeln(TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,',',
          TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType,',',
          TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,',',
          TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType);
}

  if TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType = TDataType.OBJECTTOK then Error(i, '-- under construction --');

  if TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType = TDataType.RECORDTOK then ConstVal:=0;

  if TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType in [TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK] then

  DefineIdent(i, TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,
	      VARIABLE, TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType,
	      TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,
	      TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType, 0)
  else

  DefineIdent(i, TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,
  	      VARIABLE, TTokenKind.POINTERTOK,
	      TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,
	      TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType, 0);

  Ident[NumIdent].PassMethod := TParameterPassingMethod.VARPASSING;

  VarDataSize := tmpVarDataSize + GetDataSize(TDataType.POINTERTOK);

  if TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Kind = TFieldKind.OBJECTVARIABLE then begin
   Ident[NumIdent].Value := ConstVal + DATAORIGIN;

   inc(ConstVal, GetDataSize( TypeArray[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType));

   VarDataSize := tmpVarDataSize;
  end;

 end;


asm65;

if not isAsm then				// skaczemy do poczatku bloku procedury, wazne dla zagniezdzonych procedur / funkcji
  GenerateDeclarationProlog;


while Tok[i].Kind in
 [TTokenKind.CONSTTOK, TTokenKind.TYPETOK, TTokenKind.VARTOK, TTokenKind.LABELTOK, TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.PROGRAMTOK, TTokenKind.USESTOK, TTokenKind.LIBRARYTOK, TTokenKind.EXPORTSTOK,
  TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK, TTokenKind.LINKTOK,
  TTokenKind.UNITBEGINTOK, TTokenKind.UNITENDTOK, TTokenKind.IMPLEMENTATIONTOK, TTokenKind.INITIALIZATIONTOK, TTokenKind.IOCHECKON, TTokenKind.IOCHECKOFF, TTokenKind.LOOPUNROLLTOK, TTokenKind.NOLOOPUNROLLTOK,
  TTokenKind.PROCALIGNTOK, TTokenKind.LOOPALIGNTOK, TTokenKind.LINKALIGNTOK, TTokenKind.INFOTOK, TTokenKind.WARNINGTOK, TTokenKind.ERRORTOK] do
  begin

  if Tok[i].Kind = TTokenKind.LINKTOK then begin

   if codealign.link > 0 then begin
    asm65(#9'.align $' + IntToHex(codealign.link,4));
    asm65;
   end;

   asm65(#9'.link ''' + linkObj[ Tok[i].Value ] + '''');
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.LOOPUNROLLTOK then begin
   if Pass = TPass.CODE_GENERATION then loopunroll := true;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.NOLOOPUNROLLTOK then begin
   if Pass = TPass.CODE_GENERATION then loopunroll := false;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.PROCALIGNTOK then begin
   if Pass = TPass.CODE_GENERATION then codealign.proc := Tok[i].Value;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.LOOPALIGNTOK then begin
   if Pass = TPass.CODE_GENERATION then codealign.loop := Tok[i].Value;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.LINKALIGNTOK then begin
   if Pass = TPass.CODE_GENERATION then codealign.link := Tok[i].Value;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.INFOTOK then begin
   if Pass = TPass.CODE_GENERATION then writeln('User defined: ' + msgUser[Tok[i].Value]);
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.WARNINGTOK then begin
   WarningUserDefined(i);
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.ERRORTOK then begin
   if Pass = TPass.CODE_GENERATION then Error(i, TErrorCode.UserDefined);
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.IOCHECKON then begin
   IOCheck := true;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.IOCHECKOFF then begin
   IOCheck := false;
   inc(i, 2);
  end;


  if Tok[i].Kind = TTokenKind.UNITBEGINTOK then begin
   asm65separator;

   DefineIdent(i, UnitName[Tok[i].UnitIndex].Name, UNITTYPE, 0, 0, TDataType.UNTYPETOK, 0);
   Ident[NumIdent].UnitIndex := Tok[i].UnitIndex;

//   writeln(UnitName[Tok[i].UnitIndex].Name,',',Ident[NumIdent].UnitIndex,',',Tok[i].UnitIndex);

   asm65;
   asm65('.local'#9 + UnitName[Tok[i].UnitIndex].Name, '; UNIT');

   UnitNameIndex := Tok[i].UnitIndex;

   CheckTok(i + 1, UNITTOK);
   CheckTok(i + 2, TTokenKind.IDENTTOK);

   if Tok[i + 2].Name <> UnitName[Tok[i].UnitIndex].Name then
    Error(i + 2, 'Illegal unit name: ' + Tok[i + 2].Name);

   CheckTok(i + 3, TTokenKind.SEMICOLONTOK);

   while Tok[i + 4].Kind in [WARNINGTOK, TTokenKind.ERRORTOK, TTokenKind.INFOTOK] do inc(i,2);

   CheckTok(i + 4, INTERFACETOK);

   INTERFACETOK_USE := true;

   PublicSection := true;
   ImplementationUse := false;

   inc(i, 5);
  end;


  if Tok[i].Kind = TTokenKind.UNITENDTOK then begin

   if not ImplementationUse then
    CheckTok(i, TTokenKind.IMPLEMENTATIONTOK);

   GenerateProcFuncAsmLabels(BlockIdentIndex);

   VarRegister := 0;

   asm65;
   asm65('.endl', '; UNIT ' + UnitName[Tok[i].UnitIndex].Name);

   j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = UnitNameIndex) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
       if Ident[j].IsUnresolvedForward and (Ident[j].isExternal = false) then
	 Error(i, 'Unresolved forward declaration of ' + Ident[j].Name);

     Dec(j);
     end;

   UnitNameIndex := 1;

   PublicSection := true;
   ImplementationUse := false;

   inc(i);
  end;


  if Tok[i].Kind = TTokenKind.IMPLEMENTATIONTOK then begin

   INTERFACETOK_USE := false;

   PublicSection := false;
   ImplementationUse := true;

   inc(i);
  end;


  if Tok[i].Kind = TTokenKind.EXPORTSTOK then begin

   inc(i);

   repeat

    CheckTok(i , TTokenKind.IDENTTOK);

    if Pass = TPass.CALL_DETERMINATION then begin
      IdentIndex := GetIdentIndex(Tok[i].Name);

      if IdentIndex = 0 then
       Error(i, TErrorCode.UnknownIdentifier);

      if Ident[IdentIndex].isInline then
       Error(i, 'INLINE is not allowed to exports');


      if Ident[IdentIndex].isOverload then begin

       for idx := 1 to NumIdent do
	 if {(Ident[idx].ProcAsBlock = Ident[IdentIndex].ProcAsBlock) and} (Ident[idx].Name = Ident[IdentIndex].Name) then
	  AddCallGraphChild(BlockStack[BlockStackTop], Ident[idx].ProcAsBlock);

      end else
       AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);

    end;

    inc(i);

    if not (Tok[i].Kind in [COMMATOK, TTokenKind.SEMICOLONTOK]) then CheckTok(i, TTokenKind.SEMICOLONTOK);

    if Tok[i].Kind = TTokenKind.COMMATOK then inc(i);

   until Tok[i].Kind = TTokenKind.SEMICOLONTOK;

    inc(i,1);

  end;


  if (Tok[i].Kind = TTokenKind.INITIALIZATIONTOK) or ((PublicSection = FALSE) and (Tok[i].Kind = BEGINTOK))  then begin

   if not ImplementationUse then
    CheckTok(i, TTokenKind.IMPLEMENTATIONTOK);

   asm65separator;
   asm65separator(false);

   asm65('@UnitInit');

   j := CompileStatement(i + 1);
   while Tok[j + 1].Kind = TTokenKind.SEMICOLONTOK do j := CompileStatement(j + 2);

   asm65;
   asm65(#9'rts');

   i := j + 1;
  end;



  if Tok[i].Kind = TTokenKind.LIBRARYTOK then begin       // na samym poczatku listingu

   if TTokenKind.LIBRARYTOK_USE then CheckTok(i, BEGINTOK);

   CheckTok(i + 1, TTokenKind.IDENTTOK);

   LIBRARY_NAME := Tok[i + 1].Name;

   if (Tok[i + 2].Kind = TTokenKind.COLONTOK) and (Tok[i + 3].Kind = TTokenKind.INTNUMBERTOK) then begin

     CODEORIGIN_BASE := Tok[i + 3].Value;

     target.codeorigin := CODEORIGIN_BASE;

     inc(i, 2);
   end;

   inc(i);

   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

   inc(i, 2);

   TTokenKind.LIBRARYTOK_USE := true;
  end;



  if Tok[i].Kind = TTokenKind.PROGRAMTOK then begin       // na samym poczatku listingu

   if TTokenKind.PROGRAMTOK_USE then CheckTok(i, BEGINTOK);

   CheckTok(i + 1, TTokenKind.IDENTTOK);

   PROGRAM_NAME := Tok[i + 1].Name;

   inc(i);


   if Tok[i+1].Kind = TTokenKind.OPARTOK then begin

    inc(i);

    repeat
     inc(i);
     CheckTok(i, TTokenKind.IDENTTOK);

     if Tok[i+1].Kind = TTokenKind.COMMATOK then inc(i);

    until Tok[i+1].Kind <> TTokenKind.IDENTTOK;

    CheckTok(i+1, TTokenKind.CPARTOK);

    inc(i);
   end;


   if (Tok[i + 1].Kind = TTokenKind.COLONTOK) and (Tok[i + 2].Kind = TTokenKind.INTNUMBERTOK) then begin

     CODEORIGIN_BASE := Tok[i + 2].Value;

     target.codeorigin := CODEORIGIN_BASE;

     inc(i, 2);
   end;


   CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

   inc(i, 2);

   TTokenKind.PROGRAMTOK_USE := true;
  end;


  if Tok[i].Kind = TTokenKind.USESTOK then begin	  // co najwyzej po PROGRAM

  if TTokenKind.LIBRARYTOK_USE then begin

   j:=i-1;

   while Tok[j].Kind in [SEMICOLONTOK, TTokenKind.IDENTTOK, TTokenKind.COLONTOK, TTokenKind.INTNUMBERTOK] do dec(j);

   if Tok[j].Kind <> TTokenKind.LIBRARYTOK then
    CheckTok(i, BEGINTOK);

  end;

  if TTokenKind.PROGRAMTOK_USE then begin

   j:=i-1;

   while Tok[j].Kind in [SEMICOLONTOK, TTokenKind.CPARTOK, TTokenKind.OPARTOK, TTokenKind.IDENTTOK, TTokenKind.COMMATOK, TTokenKind.COLONTOK, TTokenKind.INTNUMBERTOK] do dec(j);

   if Tok[j].Kind <> TTokenKind.PROGRAMTOK then
    CheckTok(i, BEGINTOK);

  end;

  if INTERFACETOK_USE then
   if Tok[i - 1].Kind <> INTERFACETOK then
    CheckTok(i, TTokenKind.IMPLEMENTATIONTOK);

  if ImplementationUse then
   if Tok[i - 1].Kind <> TTokenKind.IMPLEMENTATIONTOK then
    CheckTok(i, BEGINTOK);

  inc(i);

  idx:=i;

  UnitList:=nil;
  SetLength(UnitList, 1);		// preliminary USES reading, we check if there are any duplicate entries

  repeat

   CheckTok(i , TTokenKind.IDENTTOK);

   for j:=0 to High(UnitList)-1 do
    if UnitList[j] = Tok[i].Name then
     Error(i, 'Duplicate identifier '''+Tok[i].Name+'''');

   j:=High(UnitList);
   UnitList[j] := Tok[i].Name;
   SetLength(UnitList, j+2);

   inc(i);

   if Tok[i].Kind = TTokenKind.INTOK then begin
    CheckTok(i + 1, TTokenKind.STRINGLITERALTOK);

    inc(i,2);
   end;

   if not (Tok[i].Kind in [COMMATOK, TTokenKind.SEMICOLONTOK]) then CheckTok(i, TTokenKind.SEMICOLONTOK);

   if Tok[i].Kind = TTokenKind.COMMATOK then inc(i);

  until Tok[i].Kind <> TTokenKind.IDENTTOK;

  CheckTok(i, TTokenKind.SEMICOLONTOK);


  i:=idx;

  SetLength(UnitList, 0);		//  proper reading USES

  repeat

   CheckTok(i , TTokenKind.IDENTTOK);

   yes:=true;
   for j := 1 to UnitName[UnitNameIndex].Units do
    if (UnitName[UnitNameIndex].Allow[j] = Tok[i].Name) or (Tok[i].Name = 'SYSTEM') then yes:=false;

   if yes then begin

    inc(UnitName[UnitNameIndex].Units);

    if UnitName[UnitNameIndex].Units > MAXALLOWEDUNITS then
      Error(i, 'Out of resources, MAXALLOWEDUNITS');

    UnitName[UnitNameIndex].Allow[UnitName[UnitNameIndex].Units] := Tok[i].Name;

   end;

   inc(i);

   if Tok[i].Kind = TTokenKind.INTOK then begin
    CheckTok(i + 1, TTokenKind.STRINGLITERALTOK);

    inc(i,2);
   end;

   if not (Tok[i].Kind in [COMMATOK, TTokenKind.SEMICOLONTOK]) then CheckTok(i, TTokenKind.SEMICOLONTOK);

   if Tok[i].Kind = TTokenKind.COMMATOK then inc(i);

  until Tok[i].Kind <> TTokenKind.IDENTTOK;

  CheckTok(i, TTokenKind.SEMICOLONTOK);

  inc(i);

  end;

// -----------------------------------------------------------------------------
//				   LABEL
// -----------------------------------------------------------------------------

  if Tok[i].Kind = TTokenKind.LABELTOK then begin

   inc(i);

   repeat

    CheckTok(i , TTokenKind.IDENTTOK);

    DefineIdent(i, Tok[i].Name, LABELTYPE, 0, 0, 0, 0);

    inc(i);

    if Tok[i].Kind = TTokenKind.COMMATOK then inc(i);

   until Tok[i].Kind <> TTokenKind.IDENTTOK;

   i := i + 1;
  end;	// if TTokenKind.LABELTOK

// -----------------------------------------------------------------------------
//				   CONST
// -----------------------------------------------------------------------------

  if Tok[i].Kind = TTokenKind.CONSTTOK then
    begin
    repeat

      if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
	Error(i + 1, 'Constant name expected but ' + GetSpelling(i + 1) + ' found')
      else
	if Tok[i + 2].Kind = TTokenKind.EQTOK then begin

	  j := CompileConstExpression(i + 3, ConstVal, ConstValType, TTokenKind.INTEGERTOK, false, false);

	  if Tok[j].Kind in StringTypes then begin

	   if Tok[j].StrLength > 255 then
	     DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, TTokenKind.POINTERTOK, 0, TTokenKind.CHARTOK, ConstVal + CODEORIGIN, TTokenKind.PCHARTOK)
	   else
	     DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, ConstValType, Tok[j].StrLength, TTokenKind.CHARTOK, ConstVal + CODEORIGIN, Tok[j].Kind);

	  end else
   	   if (ConstValType in Pointers) then
	     Error(j, TErrorCode.IllegalExpression)
	   else
	     DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, ConstValType, 0, 0, ConstVal, Tok[j].Kind);

	  i := j;
	end else
	if Tok[i + 2].Kind = TTokenKind.COLONTOK then begin

	  open_array := false;


	  if (Tok[i + 3].Kind = TDataType.ARRAYTOK) and (Tok[i + 4].Kind = TTokenKind.OFTOK) then begin

	   j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

  	   if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
	     Error(i, 'Only Array of ^'+InfoAboutToken(VarType)+' supported')
	   else
	   if VarType =  TTokenKind.ENUMTOK then
	     Error(i, InfoAboutToken(VarType)+' arrays are not supported');

	   if VarType = TDataType.POINTERTOK then begin

	    if AllocElementType = TDataType.UNTYPETOK then begin
	     NumAllocElements := 1;
	     AllocElementType := VarType;
	    end;

	   end else begin
	     NumAllocElements := 1;
	     AllocElementType := VarType;
	     VarType := TTokenKind.POINTERTOK;
	   end;

	   if not (AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then open_array := true;

	  end else begin

	   j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

	   if Tok[i + 3].Kind = TDataType.ARRAYTOK then j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	  end;


	  if (VarType in Pointers) and (NumAllocElements = 0) then
	   if AllocElementType <> TTokenKind.CHARTOK then Error(j, TErrorCode.IllegalExpression);


	  CheckTok(j + 1, TTokenKind.EQTOK);

	  if Tok[i + 3].Kind in StringTypes then begin

	   j := CompileConstExpression(j + 2, ConstVal, ConstValType);

	   if Tok[i + 3].Kind = TTokenKind.PCHARTOK then
	    DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, TTokenKind.POINTERTOK, 0, TTokenKind.CHARTOK, ConstVal + CODEORIGIN + 1, TTokenKind.PCHARTOK)
	   else
	    DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, ConstValType, Tok[j].StrLength, TTokenKind.CHARTOK, ConstVal + CODEORIGIN, Tok[j].Kind);

	  end else

	  if NumAllocElements > 0 then begin

       	    DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, VarType, NumAllocElements, AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE, TTokenKind.IDENTTOK);

	   if (Ident[NumIdent].NumAllocElements in [0,1]) and (open_array = false) then
	    Error(i, TErrorCode.IllegalExpression)
	   else
	   if open_array then begin									// const array of type = [ ]

	     if (Tok[j + 2].Kind = TTokenKind.STRINGLITERALTOK) and (AllocElementType = TDataType.CHARTOK) then begin	// = 'string'

	       Ident[NumIdent].Value := Tok[j + 2].StrAddress + CODEORIGIN_BASE;
       	       if VarType <> TTokenKind.STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[j + 2].StrLength;

	       j := j + 2;

	       NumAllocElements := 0;

	     end else begin
	       j := ReadDataOpenArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true, Tok[j].Kind = TTokenKind.PCHARTOK);

	       Ident[NumIdent].NumAllocElements := NumAllocElements;
	     end;

	   end else begin										// const array [] of type = ( )

	     if (Tok[j + 2].Kind = TTokenKind.STRINGLITERALTOK) and (AllocElementType = TDataType.CHARTOK) then begin	// = 'string'

	       if Tok[j + 2].StrLength > NumAllocElements then
     	         Error(j + 2, 'String length is larger than array of char length');

	       Ident[NumIdent].Value := Tok[j + 2].StrAddress + CODEORIGIN_BASE;
	       if VarType <> TTokenKind.STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[j + 2].StrLength;

	       j := j + 2;

	       NumAllocElements := 0;

	     end else
	       j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true, Tok[j].Kind = TTokenKind.PCHARTOK);

	   end;


	   if NumAllocElements shr 16 > 0 then
	     inc(NumStaticStrChars, ((NumAllocElements and $ffff) * (NumAllocElements shr 16)) * GetDataSize( TDataType.AllocElementType])
	   else
	     inc(NumStaticStrChars, NumAllocElements * GetDataSize(AllocElementType));

	  end else begin
	   j := CompileConstExpression(j + 2, ConstVal, ConstValType, VarType, false);


	   if (VarType in [TTokenKind.SINGLETOK, TDataType.HALFSINGLETOK]) and (ConstValType in [TTokenKind.SHORTREALTOK, TTokenKind.REALTOK]) then ConstValType := VarType;
	   if (VarType = TDataType.SHORTREALTOK) and (ConstValType = TDataType.REALTOK) then ConstValType := TTokenKind.SHORTREALTOK;


	   if (VarType in RealTypes) and (ConstValType in IntegerTypes) then begin
	     ConstVal:=FromInt64(ConstVal);
	     ConstValType := VarType;
	   end;

	   GetCommonType(i + 1, VarType, ConstValType);

	   DefineIdent(i + 1, Tok[i + 1].Name, CONSTANT, VarType, 0, 0, ConstVal, Tok[j].Kind);
	  end;

	  i := j;
	end else
	 CheckTok(i + 2, TTokenKind.EQTOK);

      CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

      inc(i);
    until Tok[i + 1].Kind <> TTokenKind.IDENTTOK;

    inc(i);
    end;	// if TTokenKind.CONSTTOK

// -----------------------------------------------------------------------------
//				TYPE
// -----------------------------------------------------------------------------

  if Tok[i].Kind = TTokenKind.TYPETOK then
    begin
    repeat
      if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
	Error(i + 1, 'Type name expected but ' + GetSpelling(i + 1) + ' found')
      else
	  begin

	   CheckTok(i + 2, TTokenKind.EQTOK);

	   if (Tok[i + 3].Kind = TDataType.ARRAYTOK) and (Tok[i + 4].Kind <> TTokenKind.OBRACKETTOK) then begin
	    j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

	    DefineIdent(i + 1, Tok[i + 1].Name, USERTYPE, VarType, NumAllocElements, AllocElementType, 0, Tok[i + 3].Kind);
	    Ident[NumIdent].Pass := TPass.CALL_DETERMINATION;

	   end else begin
	    j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

	    if Tok[i + 3].Kind = TDataType.ARRAYTOK then j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	    DefineIdent(i + 1, Tok[i + 1].Name, USERTYPE, VarType, NumAllocElements, AllocElementType, 0, Tok[i + 3].Kind);
	    Ident[NumIdent].Pass := TPass.CALL_DETERMINATION;

	   end;

	  end;

      CheckTok(j + 1, TTokenKind.SEMICOLONTOK);

      i := j + 1;
    until Tok[i + 1].Kind <> TTokenKind.IDENTTOK;

    CheckForwardResolutions;

    i := i + 1;
    end;	// if TTokenKind.TYPETOK
// -----------------------------------------------------------------------------
//				  VAR
// -----------------------------------------------------------------------------

  if Tok[i].Kind = TTokenKind.VARTOK then
    begin

    isVolatile := FALSE;
    isStriped  := FALSE;

    NestedDataType := 0;
    NestedAllocElementType := 0;
    NestedNumAllocElements := 0;

    if (Tok[i + 1].Kind = TTokenKind.OBRACKETTOK) and (Tok[i + 2].Kind in [VOLATILETOK, STRIPEDTOK]) then begin
       CheckTok(i + 3, TTokenKind.CBRACKETTOK);

       if Tok[i + 2].Kind = VOLATILETOK then
         isVolatile := TRUE
       else
         isStriped  := TRUE;

       inc(i, 3);
    end;

    repeat
      NumVarOfSameType := 0;
      repeat
	if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
	  Error(i + 1, 'Variable name expected but ' + GetSpelling(i + 1) + ' found')
	else
	  begin
	  Inc(NumVarOfSameType);

	  if NumVarOfSameType > High(VarOfSameType) then
	    Error(i, 'Too many formal parameters');

	  VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name;
	  end;
	i := i + 2;
      until Tok[i].Kind <> TTokenKind.COMMATOK;

      CheckTok(i, TTokenKind.COLONTOK);

     // pack:=false;


      if Tok[i + 1].Kind = PACKEDTOK then begin

       if (Tok[i + 2].Kind in [ARRAYTOK, TTokenKind.RECORDTOK]) then begin
        inc(i);
       // pack := true;
       end else
        CheckTok(i + 2, TTokenKind.RECORDTOK);

      end;


      IdType := Tok[i + 1].Kind;

      idx := i + 1;


      open_array := false;

      isAbsolute := false;
      isExternal := false;


      if (IdType = TDataType.ARRAYTOK) and (Tok[i + 2].Kind = TTokenKind.OFTOK) then begin			// array of type [Ordinal Types]

	i := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

    	if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
	  Error(i, 'Only Array of ^'+InfoAboutToken(VarType)+' supported')
	else
	if VarType =  TTokenKind.ENUMTOK then
	  Error(i, InfoAboutToken(VarType)+' arrays are not supported');

	if VarType = TDataType.POINTERTOK then begin

	  if AllocElementType = TDataType.UNTYPETOK then begin
	   NumAllocElements := 1;
	   AllocElementType := VarType;
	  end;

	end else begin
	  NumAllocElements := 1;
	  AllocElementType := VarType;
	  VarType := TTokenKind.POINTERTOK;
	end;

	//if Tok[i + 1].Kind <> TTokenKind.EQTOK then isAbsolute := true;				// !!!!

	ConstVal := 1;

	if not (AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then open_array := true;

      end else begin

        i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

        if IdType = TDataType.ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	if (NumAllocElements = 1) or (NumAllocElements = $10001) then ConstVal := 1;

      end;


      if Tok[i + 1].Kind = TTokenKind.REGISTERTOK then begin

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'REGISTER can only be associated to one variable');

	isAbsolute := true;

	inc(VarRegister, GetDataSize( TDataType.VarType]);

	ConstVal := (VarRegister+3) shl 24 + 1 ;

	inc(i);

      end else

      if Tok[i + 1].Kind = EXTERNALTOK then begin

       if NumVarOfSameType > 1 then
	 Error(i + 1, 'Only one variable can be initialized');

       isAbsolute := true;
       isExternal := true;

       inc(i);

       external_libr := 0;

       if Tok[i + 1].Kind = TTokenKind.IDENTTOK then begin

	external_name := Tok[i + 1].Name;

	if Tok[i + 2].Kind = TTokenKind.STRINGLITERALTOK then begin
	  external_libr := i + 2;

	  inc(i);
	end;

	inc(i);
       end else
       if Tok[i + 1].Kind = TTokenKind.STRINGLITERALTOK then begin

	external_name := VarOfSameType[1].Name;
	external_libr := i + 1;

        inc(i);
       end;


       ConstVal := 1;


      end else

      if Tok[i + 1].Kind = ABSOLUTETOK then begin

	isAbsolute := true;

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'ABSOLUTE can only be associated to one variable');


	if (VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] {+ Pointers}) and (NumAllocElements = 0) then	 // brak mozliwosci identyfikacji dla takiego przypadku
	 Error(i + 1, 'not possible in this case');

	inc(i);

	varPassMethod := TParameterPassingMethod.UNDEFINED;

	if (Tok[i+1].Kind = TTokenKind.IDENTTOK) and (Ident[GetIdentIndex(Tok[i+1].Name)].Kind = TTokenKind.VARTOK) then begin
	 ConstVal := Ident[GetIdentIndex(Tok[i+1].Name)].Value - DATAORIGIN;

	 varPassMethod := Ident[GetIdentIndex(Tok[i+1].Name)].PassMethod;

 	 if (ConstVal < 0) or (ConstVal > $FFFFFF) then
	  Error(i, 'Range check error while evaluating constants ('+IntToStr(ConstVal)+' must be between 0 and '+IntToStr($FFFFFF)+')');


	 ConstVal := -ConstVal;

	 inc(i);
	end else begin
	 i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

	 if VarType in Pointers then
	  GetCommonConstType(i, TTokenKind.WORDTOK, ActualParamType)
	 else
	  GetCommonConstType(i, TTokenKind.CARDINALTOK, ActualParamType);

	 if (ConstVal < 0) or (ConstVal > $FFFFFF) then
	  Error(i, 'Range check error while evaluating constants ('+IntToStr(ConstVal)+' must be between 0 and '+IntToStr($FFFFFF)+')');
	end;

	inc(ConstVal);   // wyjatkowo, aby mozna bylo ustawic adres $0000, DefineIdent zmniejszy wartosc -1

      end;



      if IdType = TDataType.IDENTTOK then IdType := Ident[GetIdentIndex(Tok[idx].Name)].IdType;



      tmpVarDataSize := VarDataSize;		// dla ABSOLUTE, RECORD


      for VarOfSameTypeIndex := 1 to NumVarOfSameType do begin


//  writeln(VarType,',',NumAllocElements and $FFFF,',',NumAllocElements shr 16,',',AllocElementType, ',',idType,',',varPassMethod,',',isAbsolute);


	if VarType = DEREFERENCEARRAYTOK then begin

	  VarType := TTokenKind.POINTERTOK;

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

//	  writeln('? ',VarOfSameType[VarOfSameTypeIndex].Name,',', NestedDataType,',',NestedAllocElementType,',',NestedNumAllocElements,'|',IdType);

	  Ident[NumIdent].NestedDataType := NestedDataType;
	  Ident[NumIdent].NestedAllocElementType := NestedAllocElementType;
	  Ident[NumIdent].NestedNumAllocElements := NestedNumAllocElements;
	  Ident[NumIdent].isVolatile := isVolatile;

	  if varPassMethod <> TParameterPassingMethod.UNDEFINED then Ident[NumIdent].PassMethod := varPassMethod;


	  if isStriped and (Ident[NumIdent].PassMethod <> TParameterPassingMethod.VARPASSING) then begin

            if NumAllocElements shr 16 > 0 then
              yes := (NumAllocElements and $FFFF) * (NumAllocElements shr 16) <= 256
	    else
	      yes := NumAllocElements <= 256;

	    if yes then
  	      Ident[NumIdent].isStriped := TRUE
	    else
	      WarningStripedAllowed(i);

	  end;


	  varPassMethod := TParameterPassingMethod.UNDEFINED;


//	  writeln(VarType, ' / ', AllocElementType ,' = ',NestedDataType, ',',NestedAllocElementType,',', hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));


	  if (VarType = TDataType.POINTERTOK) and (AllocElementType = TDataType.STRINGPOINTERTOK) and (NestedNumAllocElements > 0) and (NumAllocElements > 1) then begin	// array [ ][ ] of string;


	   if Ident[NumIdent].isAbsolute then
	     Error(i, 'ABSOLUTE modifier is not available for this type of array');

	   idx := Ident[NumIdent].Value - DATAORIGIN;

	   if NumAllocElements shr 16 > 0 then begin

		for j:=0 to (NumAllocElements and $FFFF) * (NumAllocElements shr 16) - 1 do begin
      		  SaveToDataSegment(idx, VarDataSize, TTokenKind.DATAORIGINOFFSET);

		  inc(idx, 2);
 		  inc(VarDataSize, NestedNumAllocElements);
		end;

	   end else begin

		for j:=0 to NumAllocElements - 1 do begin
      		  SaveToDataSegment(idx, VarDataSize, TTokenKind.DATAORIGINOFFSET);

		  inc(idx, 2);
 		  inc(VarDataSize, NestedNumAllocElements);
		end;

	   end;

	  end;


	end;


	CompileRecordDeclaration(VarOfSameType, tmpVarDataSize, ConstVal, VarOfSameTypeIndex, VarType, AllocElementType, NumAllocElements, isAbsolute);


      end;


       if isExternal then begin

	Ident[NumIdent].isExternal := true;

        Ident[NumIdent].Alias := external_name;
        Ident[NumIdent].Libraries := external_libr;

       end;


       if isAbsolute and (open_array = false) then

	VarDataSize := tmpVarDataSize

       else

       if Tok[i + 1].Kind = TTokenKind.EQTOK then begin


        if Ident[NumIdent].isStriped then
	 Error(i + 1, 'Initialization for striped array not allowed');


	if VarType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
	 Error(i + 1, 'Initialization for '+InfoAboutToken(VarType)+' not allowed');

	if NumVarOfSameType > 1 then
	 Error(i + 1, 'Only one variable can be initialized');

	inc(i);


	if (VarType = TDataType.POINTERTOK) and (AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then

	else
	 idx := Ident[NumIdent].Value - DATAORIGIN;


	if not (VarType in Pointers) then begin

	 Ident[NumIdent].isInitialized := true;

	 i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

	 if (VarType in RealTypes) and (ActualParamType = TDataType.REALTOK) then ActualParamType := VarType;

	 GetCommonConstType(i, VarType, ActualParamType);

	 SaveToDataSegment(idx, ConstVal, VarType);

	end else begin

	 Ident[NumIdent].isInit := true;

//	 if Ident[NumIdent].NumAllocElements = 0 then
//	  Error(i + 1, 'Illegal expression');

	  inc(i);


	  if Tok[i].Kind = TTokenKind.ADDRESSTOK then begin

	    if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
	      Error(i + 1, TErrorCode.IdentifierExpected)
	    else begin
	      IdentIndex := GetIdentIndex(Tok[i + 1].Name);

	      if IdentIndex > 0 then begin

	       if (Ident[IdentIndex].Kind = CONSTANT) then begin

		if not ( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
		  Error(i + 1, TErrorCode.CantAdrConstantExp)
		else
		 SaveToDataSegment(idx, Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_BASE, TTokenKind.CODEORIGINOFFSET);

	       end else
		 SaveToDataSegment(idx, Ident[IdentIndex].Value - DATAORIGIN, TTokenKind.DATAORIGINOFFSET);

	       VarType := TTokenKind.POINTERTOK;

	      end else
	       Error(i + 1, TErrorCode.UnknownIdentifier);

	    end;

	    inc(i);

	  end else
	  if Tok[i].Kind = TTokenKind.CHARLITERALTOK then begin

	   SaveToDataSegment(idx, 1, TTokenKind.BYTETOK);
	   SaveToDataSegment(idx+1, Tok[i].Value, TTokenKind.BYTETOK);

	   VarType := TTokenKind.POINTERTOK;

	  end else
	  if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) and (open_array = false) and (VarType = TDataType.POINTERTOK) and (AllocElementType = TDataType.CHARTOK) then

	    SaveToDataSegment(idx, Tok[i].StrAddress - CODEORIGIN + 1, TTokenKind.CODEORIGINOFFSET)

	  else

{
	  if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) and (open_array = false) then begin

	   if (Ident[NumIdent].NumAllocElements > 0 ) and (Tok[i].StrLength > Ident[NumIdent].NumAllocElements) then begin
	    Warning(i, StringTruncated, NumIdent);

	    ParamIndex := Ident[NumIdent].NumAllocElements;
	   end else
	    ParamIndex := Tok[i].StrLength + 1;

	   VarType := TTokenKind.STRINGPOINTERTOK;


	   if (Ident[NumIdent].NumAllocElements = 0) then 					// var label: pchar = ''
	    SaveToDataSegment(idx, Tok[i].StrAddress - CODEORIGIN + 1, TTokenKind.CODEORIGINOFFSET)
	   else begin

	     if (IdType = TDataType.ARRAYTOK) and (AllocElementType = TDataType.CHARTOK) then begin			// var label: array of char = ''

	      if Tok[i].StrLength > NumAllocElements then
     	        Error(i, 'string length is larger than array of char length');

 	      for j := 0 to Ident[NumIdent].NumAllocElements-1 do
	       if j > Tok[i].StrLength-1 then
 	         SaveToDataSegment(idx + j, ord(' '), TTokenKind.CHARTOK)
	       else
 	         SaveToDataSegment(idx + j, ord( StaticStringData[ Tok[i].StrAddress - CODEORIGIN + j + 1] ), TTokenKind.CHARTOK);

	     end else
 	      for j := 0 to ParamIndex-1 do							// var label: string = ''
 	        SaveToDataSegment(idx + j, ord( StaticStringData[ Tok[i].StrAddress - CODEORIGIN + j ] ), TTokenKind.BYTETOK);

	   end;

	  end else
}

	   if (Ident[NumIdent].NumAllocElements in [0,1]) and (open_array = false) then
	    Error(i, TErrorCode.IllegalExpression)
	   else
	    if open_array then begin 									// array of type = [ ]

	     if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) and (AllocElementType = TDataType.CHARTOK) then begin		// = 'string'

	       Ident[NumIdent].Value := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
	       if VarType <> TTokenKind.STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[i].StrLength;

	       Ident[NumIdent].isAbsolute := true;

	       NumAllocElements := 0;

	     end else begin
	       i := ReadDataOpenArray(i, idx, Ident[NumIdent].AllocElementType, NumAllocElements, false, Tok[i-2].Kind = TTokenKind.PCHARTOK);

	       Ident[NumIdent].NumAllocElements := NumAllocElements;
	     end;

	     inc(VarDataSize, NumAllocElements * GetDataSize( TDataType.Ident[NumIdent].AllocElementType]);

	    end else begin										// array [] of type = ( )

	     if (Tok[i].Kind = TTokenKind.STRINGLITERALTOK) and (AllocElementType = TDataType.CHARTOK) then begin		// = 'string'

	       if Tok[i].StrLength > NumAllocElements then
     	         Error(i, 'string length is larger than array of char length');

	       Ident[NumIdent].Value := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
	       if VarType <> TTokenKind.STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[i].StrLength;

	       Ident[NumIdent].isAbsolute := true;

	      // NumAllocElements := 1;

	     end else
 	       i := ReadDataArray(i, idx, Ident[NumIdent].AllocElementType, Ident[NumIdent].NumAllocElements or Ident[NumIdent].NumAllocElements_ shl 16, false, Tok[i-2].Kind = TTokenKind.PCHARTOK);

	    end;

	end;

       end;

      CheckTok(i + 1, TTokenKind.SEMICOLONTOK);

      isVolatile := FALSE;
      isStriped  := FALSE;

      if (Tok[i + 2].Kind = TTokenKind.OBRACKETTOK) and (Tok[i + 3].Kind in [VOLATILETOK, STRIPEDTOK]) then begin
       CheckTok(i + 4, TTokenKind.CBRACKETTOK);

       if Tok[i + 3].Kind = VOLATILETOK then
         isVolatile := TRUE
       else
         isStriped  := TRUE;

       inc(i, 3);
      end;


    i := i + 1;
    until Tok[i + 1].Kind <> TTokenKind.IDENTTOK;

    CheckForwardResolutions(false);								// issue #126 fixed

    i := i + 1;
    end;// if TTokenKind.VARTOK


  if Tok[i].Kind in [PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
    if Tok[i + 1].Kind <> TTokenKind.IDENTTOK then
      Error(i + 1, 'Procedure name expected but ' + GetSpelling(i + 1) + ' found')
    else
      begin

      IsNestedFunction := (Tok[i].Kind = TTokenKind.FUNCTIONTOK);


      if INTERFACETOK_USE then
       ForwardIdentIndex := 0
      else
       ForwardIdentIndex := GetIdentIndex(Tok[i + 1].Name);


      if (ForwardIdentIndex <> 0) and (Ident[ForwardIdentIndex].isOverload) then begin     	// !!! dla forward; overload;

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
	 ((Tok[i].Kind = TTokenKind.PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> TTokenKind.PROCEDURETOK)) or
//	 ((Tok[i].Kind = TTokenKind.CONSTRUCTORTOK) and (Ident[ForwardIdentIndex].Kind <> TTokenKind.CONSTRUCTORTOK)) or
//	 ((Tok[i].Kind = TTokenKind.DESTRUCTORTOK) and (Ident[ForwardIdentIndex].Kind <> TTokenKind.DESTRUCTORTOK)) or
	 ((Tok[i].Kind = TTokenKind.FUNCTIONTOK) and (Ident[ForwardIdentIndex].Kind <> TTokenKind.FUNCTIONTOK)) then
	ForwardIdentIndex := 0;     // Found an identifier of another kind or scope, or it is already resolved


      if (Tok[i].Kind in [CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) and (ForwardIdentIndex = 0) then
        Error(i, 'constructors, destructors operators must be methods');


//    writeln(ForwardIdentIndex,',',tok[i].line,',',Ident[ForwardIdentIndex].isOverload,',',Ident[ForwardIdentIndex].IsUnresolvedForward,' / ',Tok[i].Kind = TTokenKind.PROCEDURETOK,',',  ((Tok[i].Kind = TTokenKind.PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROC)));

    i := DefineFunction(i, ForwardIdentIndex, isForward, isInt, isInl, isOvr, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);


    // Check for a FORWARD directive (it is not a reserved word)
    if ((ForwardIdentIndex = 0) and isForward) or INTERFACETOK_USE then  // Forward declaration
      begin
//      Inc(NumBlocks);
//      Ident[NumIdent].ProcAsBlock := NumBlocks;
      Ident[NumIdent].IsUnresolvedForward := TRUE;

      end
    else
      begin

      if ForwardIdentIndex = 0 then							// New declaration
	begin

	TestIdentProc(i, Ident[NumIdent].Name);

	if ((Pass = TPass.CODE_GENERATION) and ( not Ident[NumIdent].IsNotDead) ) then	// Do not compile dead procedures and functions
	  begin
	  OutputDisabled := TRUE;
	  end;

	iocheck_old := IOCheck;
        isInterrupt_old := isInterrupt;

	j := CompileBlock(i + 1, NumIdent, Ident[NumIdent].NumParams, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	IOCheck := iocheck_old;
	isInterrupt := isInterrupt_old;

	i := j + 1;

	GenerateReturn(IsNestedFunction, isInt, isInl, isOvr);

	if OutputDisabled then OutputDisabled := FALSE;

	end
      else											// Forward declaration resolution
	begin
      //  GenerateForwardResolution(ForwardIdentIndex);
      //  CompileBlock(ForwardIdentIndex);

	if ((Pass = TPass.CODE_GENERATION) and ( not Ident[ForwardIdentIndex].IsNotDead) ) then	// Do not compile dead procedures and functions
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

	 if Ident[ForwardIdentIndex].isKeep	     then SetModifierBit(TModifierCode.mKeep, tmp);
	 if Ident[ForwardIdentIndex].isOverload	 then SetModifierBit(TModifierCode.mOverload, tmp);
	 if Ident[ForwardIdentIndex].isAsm	     then SetModifierBit(TModifierCode.mAssembler, tmp);
	 if Ident[ForwardIdentIndex].isRegister	 then SetModifierBit(TModifierCode.mRegister, tmp);
	 if Ident[ForwardIdentIndex].isInterrupt then SetModifierBit(TModifierCode.mInterrupt, tmp);
	 if Ident[ForwardIdentIndex].isPascal	 then SetModifierBit(TModifierCode.mPascal, tmp);
	 if Ident[ForwardIdentIndex].isStdCall	 then SetModifierBit(TModifierCode.mStdCall, tmp);
	 if Ident[ForwardIdentIndex].isInline	 then SetModifierBit(TModifierCode.mInline, tmp);

	 if Tmp <> TmpResult then
       // TODO: List the difference in the modifiers
	   Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''. Different modifiers.');


	 if IsNestedFunction then
	   if (Ident[ForwardIdentIndex].DataType <> NestedFunctionResultType) or
	      (Ident[ForwardIdentIndex].NestedFunctionNumAllocElements <> NestedFunctionNumAllocElements) or
	      (Ident[ForwardIdentIndex].NestedFunctionAllocElementType <> NestedFunctionAllocElementType) then
	     Error(i, 'Function header doesn''t match the previous declaration ''' + Ident[ForwardIdentIndex].Name + '''');


	CheckTok(i + 2, TTokenKind.SEMICOLONTOK);

	iocheck_old := IOCheck;
	isInterrupt_old := isInterrupt;

	j := CompileBlock(i + 3, ForwardIdentIndex, Ident[ForwardIdentIndex].NumParams, IsNestedFunction, Ident[ForwardIdentIndex].DataType, Ident[ForwardIdentIndex].NestedFunctionNumAllocElements, Ident[ForwardIdentIndex].NestedFunctionAllocElementType);

	IOCheck := iocheck_old;
	isInterrupt := isInterrupt_old;

	i := j + 1;

	GenerateReturn(IsNestedFunction, isInt, Ident[ForwardIdentIndex].isInline, Ident[ForwardIdentIndex].isOverload);

	if OutputDisabled then OutputDisabled := FALSE;

	Ident[ForwardIdentIndex].IsUnresolvedForward := FALSE;

	end;

      end;


	CheckTok(i, TTokenKind.SEMICOLONTOK);

	inc(i);

	end;// else
  end;// while


OutputDisabled := (Pass = TPass.CODE_GENERATION) and (BlockStack[BlockStackTop] <> 1) and (not Ident[BlockIdentIndex].IsNotDead);


// asm65('@main');

if not isAsm then begin
  GenerateDeclarationEpilog;  // Make jump to block entry point

  if not(Tok[i-1].Kind in [PROCALIGNTOK, TTokenKind.LOOPALIGNTOK, TTokenKind.LINKALIGNTOK]) then
   if TTokenKind.LIBRARYTOK_USE and (Tok[i].Kind <> BEGINTOK) then

     inc(i)

   else
    CheckTok(i, BEGINTOK);

end;


// Initialize array origin pointers if the current block is the main program body
{
if BlockStack[BlockStackTop] = 1 then begin

  for IdentIndex := 1 to NumIdent do
    if (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) then
      begin
//      Push(Ident[IdentIndex].Value + SizeOf(Int64), ASVALUE, GetDataSize(TDataType.POINTERTOK), Ident[IdentIndex].Kind);     // Array starts immediately after the pointer to its origin
//      GenerateAssignment(Ident[IdentIndex].Value, ASPOINTER, GetDataSize(TDataType.POINTERTOK), IdentIndex);
      asm65(#9'mwa #DATAORIGIN+$' + IntToHex(Ident[IdentIndex].Value - DATAORIGIN + GetDataSize(TDataType.POINTERTOK), 4) + ' DATAORIGIN+$' + IntToHex(Ident[IdentIndex].Value - DATAORIGIN , 4), '; ' + Ident[IdentIndex].Name );

      end;

end;
}


Result := CompileStatement(i, isAsm);

j := NumIdent;

// Delete local identifiers and types from the tables to save space
while (j > 0) and (Ident[j].Block = BlockStack[BlockStackTop]) do
  begin
  // If procedure or function, delete parameters first
  if Ident[j].Kind in [PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
    if Ident[j].IsUnresolvedForward and (Ident[j].isExternal = false) then
      Error(i, 'Unresolved forward declaration of ' + Ident[j].Name);

  Dec(j);
  end;


// Return Result value

if IsFunction then begin
// if FunctionNumAllocElements > 0 then
//  Push(Ident[GetIdentIndex('RESULT')].Value, ASVALUE, GetDataSize( TDataType.FunctionResultType], GetIdentIndex('RESULT'))
// else
//  asm65;
  asm65('@exit');

  if Ident[BlockIdentIndex].isStdCall or Ident[BlockIdentIndex].isRecursion then begin

    Push(Ident[GetIdentIndex('RESULT')].Value, ASPOINTER, GetDataSize( TDataType.FunctionResultType), GetIdentIndex('RESULT'));

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

if Ident[BlockIdentIndex].Kind in [PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then begin

 if Ident[BlockIdentIndex].isInline then asm65(#9'.ENDM');

 GenerateProcFuncAsmLabels(BlockIdentIndex, true);

end;

Dec(BlockStackTop);


 if pass = TPass.CALL_DETERMINATION then
  if Ident[BlockIdentIndex].isKeep or Ident[BlockIdentIndex].isInterrupt or Ident[BlockIdentIndex].updateResolvedForward then
    AddCallGraphChild(BlockStack[BlockStackTop], Ident[BlockIdentIndex].ProcAsBlock);


//Result := j;

end;	//CompileBlock


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileProgram;
var i, j, DataSegmentSize, IdentIndex: Integer;
    tmp, a: string;
    yes: Boolean;
    res: TResource;
begin

ResetOpty;

common.optimize.use := false;

tmp:='';

IOCheck := true;

DataSegmentSize := 0;

AsmBlockIndex := 0;

//SetLength(AsmLabels, 1);

DefineIdent(1, 'MAIN', TTokenKind.PROCEDURETOK, 0, 0, 0, 0);


GenerateProgramProlog;

j := CompileBlock(1, NumIdent, 0, FALSE, 0);


if Tok[j].Kind = TTokenKind.ENDTOK then CheckTok(j + 1, TTokenKind.DOTTOK) else
 if Tok[NumTok].Kind = EOFTOK then
   Error(NumTok, 'Unexpected end of file');

j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = 1) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
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

if LIBRARY_USE then asm65('@regX'#9'ldx #$00');

if target.id = TComputer.A8 then begin

 if LIBRARY_USE = FALSE then begin
  asm65;
  asm65(#9'.ifdef MAIN.@DEFINES.ROMOFF');
  asm65(#9'inc portb');
  asm65(#9'.fi');
 end;

 asm65;
 asm65(#9'ldy #$01');
end;

asm65;
asm65(#9'rts');


{
if LIBRARY_USE = FALSE then begin

  asm65separator;

  if target.id = A8 then begin
    asm65;
    asm65('IOCB@COPY'#9':16 brk');
  end;

end;
}


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

     if resArray[i].resType = 'LIBRARY' then RCLIBRARY := true;

     resArray[i].resFullName := tmp;

     Ident[IdentIndex].Pass := Pass;

     yes:=true; Break;
    end;


  if not yes then
   if AnsiUpperCase(resArray[i].resType) = 'SAPR' then begin
    asm65(resArray[i].resName);
    asm65(#9'dta a(' + resArray[i].resName + '.end-' + resArray[i].resName + '-2)');
    asm65(#9'ins ''' + resArray[i].resFile + '''');
    asm65(resArray[i].resName + '.end');
    resArray[i].resStream := true;
   end else

   if AnsiUpperCase(resArray[i].resType) = 'PP' then begin
    asm65(resArray[i].resName + #9'm@pp "''' + resArray[i].resFile + '''"');
    asm65(resArray[i].resName + '.end');
    resArray[i].resStream := true;
   end else

   if AnsiUpperCase(resArray[i].resType) = 'DOSFILE' then begin

   end else

   if AnsiUpperCase(resArray[i].resType) = 'RCDATA' then begin
    asm65(resArray[i].resName + #9'ins ''' + resArray[i].resFile + '''');
    asm65(resArray[i].resName + '.end');
    resArray[i].resStream := true;
   end else

    Error(NumTok, 'Resource identifier not found: Type = ' + resArray[i].resType + ', Name = ' + resArray[i].resName);

//  asm65(#9+resArray[i].resType+' '''+resArray[i].resFile+''''+','+resArray[i].resName);

//  resArray[i].resFullName := tmp;

//  Ident[IdentIndex].Pass := Pass;
 end;

asm65('.endl');


asm65;
asm65('.endl','; MAIN');

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

asm65;
asm65(#9'ift .SIZEOF(MAIN.@RESOURCE)>0');
asm65('.nowarn'#9'.print ''RESOURCE: '',MAIN.@RESOURCE,''..'',MAIN.@RESOURCE+.SIZEOF(MAIN.@RESOURCE)-1');
asm65(#9'eif');
asm65;


for i:=0 to High(resArray)-1 do
 if resArray[i].resStream then
   asm65(#9'.print ''$R '+resArray[i].resName+''','+''' '''+','+'"'''+resArray[i].resFile+'''"'+','+''' '''+',MAIN.@RESOURCE.'+resArray[i].resName+','+'''..'''+',MAIN.@RESOURCE.'+resArray[i].resName+'.end-1');

asm65;
asm65('@end');
asm65;
asm65('.nowarn'#9'.print ''VARS: '',MAIN.@RESOURCE+.SIZEOF(MAIN.@RESOURCE),''..'',@end-1');

asm65separator;
asm65;


if DATA_BASE > 0 then
 asm65(#9'org $'+IntToHex(DATA_BASE, 4))
else begin

 asm65(#9'?adr = *');
 asm65(#9'ift (?adr < ?old_adr) && (?old_adr - ?adr < $120)');
 asm65(#9'?adr = ?old_adr');
 asm65(#9'eif');
 asm65;
 asm65(#9'org ?adr');
 asm65(#9'?old_adr = *');

end;

asm65;
asm65('DATAORIGIN');

if DataSegmentUse then begin
 if Pass = TPass.CODE_GENERATION then begin

// !!! musze zapisac wszystko, lacznie z 'zerami' !!! np. aby TextAtr dzialal

  DataSegmentSize := VarDataSize;

  if TTokenKind.LIBRARYTOK_USE = FALSE then
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


if TTokenKind.LIBRARYTOK_USE then begin

  asm65;
  asm65('PROGRAMSTACK');

end else begin

  asm65;
  asm65('VARINITSIZE'#9'= *-DATAORIGIN');
  asm65('VARDATASIZE'#9'= '+IntToStr(VarDataSize));

  asm65;
  asm65('PROGRAMSTACK'#9'= DATAORIGIN+VARDATASIZE');

end;

asm65;
asm65(#9'.print ''DATA: '',DATAORIGIN,''..'',PROGRAMSTACK');

asm65;
asm65(#9'ert DATAORIGIN<@end,''DATA memory overlap''');

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

if target.id = TComputer.A8 then begin
 asm65;
 asm65(#9'run START');
end;

asm65separator;

asm65;
asm65('.macro'#9'STATICDATA');

 tmp:='';
 for i := 0 to NumStaticStrChars - 1 do begin

  if (i mod 24=0) then begin

   if i>0 then asm65(tmp);

   tmp:='.by ';

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

 if tmp <> '' then asm65(tmp);

 asm65('.endm');


 if (High(resArray) > 0) and (target.id <> TComputer.A8) then begin

  asm65;
  asm65('.local'#9'RESOURCE');

  asm65(#9'icl ''' + AnsiLowerCase(target.name) + '\resource.asm''');

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

flushTempBuf;			// flush TemporaryBuf

end;	//CompileProgram


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


{$i include/syntax.inc}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ParseParam;
var i: Integer;
    parameter, parameterUpperCase,parameterValue: string;
    s: string;
    t, c: string;
begin

  t := 'A8';	// target
  c := '';		// cpu

 i:=1;
 while i <= TEnvironment.GetParameterCount() do begin
  parameter:=TEnvironment.GetParameterString(i);
  parameterUpperCase:=AnsiUpperCase(parameter);
  // Options start with a minus.
  if parameter[1] = '-' then begin

   if parameterUpperCase = '-O' then begin

     inc(i);
     outputFile := parameter;
     if outputFile = '' then ParameterError(i, 'Output file path is empty');

   end else
   if pos('-O:',parameterUpperCase) = 1 then
   begin

     outputFile := copy(parameter, 4, 255);
     if outputFile = '' then ParameterError(i, 'Output file path is empty');

   end else
   if parameterUpperCase = '-DIAG' then
    DiagMode := TRUE
   else

   if (parameterUpperCase = '-IPATH') or (parameterUpperCase = '-I') then
   begin
       inc(i);
       AddPath(TEnvironment.GetParameterString(i));

   end else
   if pos('-IPATH:',parameterUpperCase) = 1 then begin

     s:=copy(parameter, 8, 255);
     AddPath(s);

   end else
   if (parameterUpperCase = '-CPU') then begin

     inc(i);
     c := TEnvironment.GetParameterStringUpperCase(i);

   end else
   if pos('-CPU:',parameterUpperCase) = 1 then begin

     c := copy(parameter, 6, 255);

   end else
   if (parameterUpperCase = '-DEFINE') or (parameterUpperCase = '-DEF') then begin

     inc(i);
     AddDefine(TEnvironment.GetParameterStringUpperCase(i));
     AddDefines := NumDefines;

   end else
   if pos('-DEFINE:',parameterUpperCase) = 1 then begin

     s:=copy(parameter, 9, 255);
     AddDefine(AnsiUpperCase(s));
     AddDefines := NumDefines;

   end else
   if (parameterUpperCase = '-CODE') or (parameterUpperCase = '-C') then begin

     inc(i);
     parameterValue:=TEnvironment.GetParameterString(i);
     CODEORIGIN_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if pos('-CODE:',parameterUpperCase) = 1 then begin
      parameterValue:=copy(parameter, 7, 255);
      CODEORIGIN_BASE:=ParseHexParameter( i,  parameterValue)

   end else
   if (parameterUpperCase = '-DATA') or (parameterUpperCase = '-D') then begin

     inc(i);
     parameterValue:=TEnvironment.GetParameterString(i);
     DATA_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if pos('-DATA:',parameterUpperCase) = 1 then begin
     parameterValue:=copy(parameter, 7, 255);
     DATA_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if (parameterUpperCase = '-STACK') or (parameterUpperCase = '-S') then begin

     inc(i);
     parameterValue:=TEnvironment.GetParameterString(i);
     STACK_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if pos('-STACK:',parameterUpperCase) = 1 then
   begin
     parameterValue:= copy(parameter, 8, 255);
     STACK_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if (parameterUpperCase = '-ZPAGE') or (parameterUpperCase = '-Z') then begin

     inc(i);
     parameterValue:=TEnvironment.GetParameterString(i);
     ZPAGE_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if pos('-ZPAGE:',parameterUpperCase) = 1 then begin
     parameterValue:= copy(parameter, 8, 255);
     ZPAGE_BASE:=ParseHexParameter( i,  parameterValue);

   end else
   if (parameterUpperCase = '-TARGET') or (parameterUpperCase = '-T') then begin

     inc(i);
     t:=TEnvironment.GetParameterStringUpperCase(i);

   end else
   if pos('-TARGET:',parameterUpperCase) = 1 then begin

     t:=AnsiUpperCase(copy(parameter, 9, 255));

   end else
     ParameterError(i, 'Unkown option '''+parameter+'''.');

  end
  // No minus, so this must be the file name.
  else

   begin
    UnitName[1].Name := TEnvironment.GetParameterString(i);
    UnitName[1].Path := UnitName[1].Name;

    if not TFileSystem.FileExists_(UnitName[1].Name) then begin
     writeln('Error: Can''t open file ''' + UnitName[1].Name + '''.');
     FreeTokens;
     RaiseHaltException(THaltException.COMPILING_NOT_STARTED);
    end;

   end;

  inc(i);
 end;


{$i targets/parse_param.inc}

{$i targets/init.inc}


 if CODEORIGIN_BASE < 0 then
  CODEORIGIN_BASE := target.codeorigin
 else
  target.codeorigin := CODEORIGIN_BASE;


 if ZPAGE_BASE < 0 then
  ZPAGE_BASE := target.zpage
 else
  target.zpage := ZPAGE_BASE;


 if c <> '' then
  if AnsiUpperCase(c) = '6502' then target.cpu := TCPU.CPU_6502 else
   if AnsiUpperCase(c) = '65C02' then target.cpu := TCPU.CPU_65C02 else
    if AnsiUpperCase(c) = '65816' then target.cpu := TCPU.CPU_65816 else
     Syntax(THaltException.COMPILING_NOT_STARTED);


 case target.cpu of
  TCPU.CPU_6502: AddDefine('CPU_6502');
  TCPU.CPU_65C02: AddDefine('CPU_65C02');
  TCPU.CPU_65816: AddDefine('CPU_65816');
 end;

 AddDefines := NumDefines;

end;	//ParseParam


// ----------------------------------------------------------------------------
//                                 Main program
// ----------------------------------------------------------------------------

procedure Main;

{$IFNDEF PAS2JS}
const PI_VALUE: TNumber = $40490FDB00000324; // does not fit into 53 bits Javascript double  mantissa
const NAN_VALUE: TNumber =$FFC00000FFC00000;
const INFINITY_VALUE: TNumber = $7F8000007F800000;
const NEGINFINITY_VALUE: TNumber = $FF800000FF800000;
{$ELSE}
const PI_VALUE: Int64 = 3; // does not fit into 53 bits Javascript double  mantissa
const NAN_VALUE: Int64 = $11111111;
const INFINITY_VALUE: Int64 = $22222222;
const NEGINFINITY_VALUE: Int64 = $33333333;

var fileMap: TFileMap;
var fileMapEntry: TFileMapEntry;
{$ENDIF}

var seconds: ValReal;
begin

{$IFDEF WINDOWS}
 if Windows.GetFileType(Windows.GetStdHandle(STD_OUTPUT_HANDLE)) = Windows.FILE_TYPE_PIPE then begin
  System.Assign(Output, ''); FileMode:=1; System.Rewrite(Output);
 end;
{$ENDIF}

{$IFDEF PAS2JS}
 fileMap := TFileMap.Create;
 fileMapEntry:=fileMap.AddEntry('Input.pas', TFileMapEntry.TFileType.TextFile);
 fileMapEntry.content := 'Program program; end.';
 fileMapEntry := fileMap.AddEntry('lib', TFileMapEntry.TFileType.Folder);
 fileMapEntry.content := 'SubFolder1;SubFolder2';
 fileMapEntry := fileMap.AddEntry('Input.bin', TFileMapEntry.TFileType.BinaryFile);
 fileMapEntry.content := '01010110101';
 TFileSystem.Init(fileMap);
{$ENDIF}

// WriteLn('Sub-Pascal 32-bit real mode compiler v. 2.0 by Vasiliy Tereshkov, 2009');

 WriteLn(CompilerTitle);

 SetLength(Tok, 1);
 SetLength(IFTmpPosStack, 1);

 Tok[NumTok].Line := 0;
 UnitName[1].Name := '';

 unitPathList:=TPathList.Create;
 MainPath := ExtractFilePath(ParamStr(0));
 MainPath := IncludeTrailingPathDelimiter( MainPath );
 unitPathList.AddFolder( MainPath + 'lib' );

 if (TEnvironment.GetParameterCount = 0) then Syntax(3);

 NumUnits:=1;			     // !!! 1 !!!

 ParseParam;

 Defines[1].Name := AnsiUpperCase(target.name);

 if (UnitName[1].Name='') then Syntax(3);

 if pos(MainPath, ExtractFilePath(UnitName[1].name)) > 0 then
  FilePath := ExtractFilePath(UnitName[1].Name)
 else
  FilePath := MainPath + ExtractFilePath(UnitName[1].Name);

 DefaultFormatSettings.DecimalSeparator := '.';


 {$IFDEF USEOPTFILE}

 OptFile.AssignFile(ChangeFileExt(UnitName[1].Name, '.opt') ); OptFile.Rewrite();

 {$ENDIF}

 OutFile:=TFileSystem.CreateTextFile;
 if ExtractFileName(outputFile) <> '' then
  OutFile.Assign(outputFile)
 else
  OutFile.Assign( ChangeFileExt(UnitName[1].Name, '.a65') );

 OutFile.Rewrite;

 TextColor(WHITE);

 Writeln('Compiling ' + UnitName[1].Name);

 start_time:=GetTickCount64;

// ----------------------------------------------------------------------------
// Set defines for first pass;
 TokenizeProgram;

 if NumTok=0 then Error(1, '');

 inc(NumUnits);
 UnitName[NumUnits].Name := 'SYSTEM';		// default UNIT 'system.pas'
 UnitName[NumUnits].Path := FindFile('system.pas', 'unit');

 TokenizeProgram(false);

// ----------------------------------------------------------------------------

 NumStaticStrCharsTmp := NumStaticStrChars;

// Predefined constants
 DefineIdent(1, 'BLOCKREAD',      TTokenKind.FUNCTIONTOK, TTokenKind.INTEGERTOK, 0, 0, $00000000);
 DefineIdent(1, 'BLOCKWRITE',     TTokenKind.FUNCTIONTOK, TTokenKind.INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'GETRESOURCEHANDLE', TTokenKind.FUNCTIONTOK, TTokenKind.INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'NIL',      CONSTANT, TTokenKind.POINTERTOK, 0, 0, CODEORIGIN);

 DefineIdent(1, 'EOL',      CONSTANT, TTokenKind.CHARTOK, 0, 0, target.eol);

 DefineIdent(1, '__BUFFER', CONSTANT, TTokenKind.WORDTOK, 0, 0, target.buf);

 DefineIdent(1, 'TRUE',     CONSTANT, TTokenKind.BOOLEANTOK, 0, 0, $00000001);
 DefineIdent(1, 'FALSE',    CONSTANT, TTokenKind.BOOLEANTOK, 0, 0, $00000000);

 DefineIdent(1, 'MAXINT',      CONSTANT, TTokenKind.INTEGERTOK, 0, 0, MAXINT);
 DefineIdent(1, 'MAXSMALLINT', CONSTANT, TTokenKind.INTEGERTOK, 0, 0, MAXSMALLINT);

 DefineIdent(1, 'PI',       CONSTANT, TTokenKind.REALTOK, 0, 0, PI_VALUE );
 DefineIdent(1, 'NAN',      CONSTANT, TTokenKind.SINGLETOK, 0, 0, NAN_VALUE);
 DefineIdent(1, 'INFINITY', CONSTANT, TTokenKind.SINGLETOK, 0, 0, INFINITY_VALUE);
 DefineIdent(1, 'NEGINFINITY', CONSTANT, TTokenKind.SINGLETOK, 0, 0, NEGINFINITY_VALUE);

// First pass: compile the program and build call graph
 NumPredefIdent := NumIdent;
 Pass := TPass.CALL_DETERMINATION;
 CompileProgram;


// Visit call graph nodes and mark all procedures that are called as not dead
 OptimizeProgram(GetIdentIndex('MAIN'));


// Second pass: compile the program and generate output (IsNotDead fields are preserved since the first pass)
 NumIdent := NumPredefIdent;

 ClearWordMemory(DataSegment);

 NumBlocks := 0; BlockStackTop := 0; CodeSize := 0; CodePosStackTop := 0; VarDataSize := 0;
 CaseCnt := 0; IfCnt := 0; ShrShlCnt := 0; NumTypes := 0; run_func := 0; NumProc := 0;

 NumStaticStrChars := NumStaticStrCharsTmp;


 ResetOpty;
 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 LIBRARY_USE := TTokenKind.LIBRARYTOK_USE;

 TTokenKind.LIBRARYTOK_USE := FALSE;
 TTokenKind.PROGRAMTOK_USE := FALSE;
 INTERFACETOK_USE := FALSE;
 PublicSection := TRUE;

 for i := 1 to High(UnitName) do UnitName[i].Units := 0;

 iOut:=0;
 outTmp:='';

 SetLength(OptimizeBuf, 1);

 Pass := TPass.CODE_GENERATION;
 CompileProgram;

 OutFile.Flush;
 OutFile.Close;

{$IFDEF USEOPTFILE}

 OptFile.Close;

{$ENDIF}


// Diagnostics
 if DiagMode then Diagnostics;


 WritelnMsg;

 TextColor(WHITE);
 seconds := (GetTickCount64 - start_time + 500)/1000;
{$IFNDEF PAS2JS}
 Writeln(Tok[NumTok].Line, ' lines compiled, ', seconds:2:2,' sec, ',
	 NumTok, ' tokens, ',NumIdent, ' idents, ',  NumBlocks, ' blocks, ', NumTypes, ' types');
{$ELSE}
 Writeln(IntToStr(Tok[NumTok].Line) + ' lines compiled, ' + FloatToStr(seconds) + ' sec, '
 	 + IntToStr(NumTok) + ' tokens        , ' + IntToStr(NumIdent) + ' idents, '
	 + IntToStr(NumBlocks) + ' blocks, ' +  IntToStr(NumTypes) + ' types');
{$ENDIF}

 FreeTokens;

 TextColor(LIGHTGRAY);

 if High(msgWarning) > 0 then Writeln(IntToStr(High(msgWarning)) + ' warning(s) issued');
 if High(msgNote) > 0 then Writeln(IntToStr(High(msgNote)) + ' note(s) issued');

 NormVideo;
end;

var exitCode: TExitCode;
begin

  exitCode :=0;
  try
    Main;
  except on e: THaltException do
    begin
    	exitCode := e.GetExitCode();
    end;
  end;

  if (exitCode <> 0) then
  begin
    WriteLn('Program ended with exit code ' + IntToStr(exitCode));
  end;

  {$IFDEF DEBUG}
  Console.WaitForKeyPressed;
  {$ENDIF}

  {$IFNDEF PAS2JS}
  Halt(exitCode);
  {$ENDIF}
end.
