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

+ Andrew Danson:
	- unit BFONT (Borland CHR)

+ Artyom Beilis, Marek Mauder (https://github.com/artyom-beilis/float16) :
	- Float16 (half-single)

+ Bartosz Zbytniewski :
	- Bug Hunter
	- Commodore C4+/C64 minimal unit SYSTEM setup

+ Bjarke Viksoe :
	- unit GIF

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
	- RMTPLAY2 (base/atari/players/rmt_player_reloc.asm)

+ Joseph Zatarski (https://forums.atariage.com/topic/225063-full-color-ansi-vbxe-terminal-in-the-works/) :
	- base\atari\vbxeansi.asm

+ John Brandwood :
	- unit APLIB

+ Konrad Kokoszkiewicz :
	- base\atari\cmdline.asm
	- base\atari\vbxedetect.asm
	- unit MISC: DetectCPU, DetectCPUSpeed, DetectMem, DetectHighMem, DetectStereo
	- unit S2 (VBXE handler)

+ Krzysztof Dudek (http://xxl.atari.pl/) :
	- unit XBIOS: BLIBS library
	- unit LZ4: unLZ4

+ Krzysztof Święcicki :
	- unit PP

+ Marcin Żukowski :
	- unit FASTGRAPH: fLine

+ Michael Jaskula :
	- {$DEFINE BASICOFF} (base\atari\basicoff.asm)

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

+ Stijn Sanders (https://github.com/stijnsanders) :
	- unit AES

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

+ Wojciech Bociański (http://bocianu.atari.pl/) :
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

# indeks dla jednowymiarowej tablicy [0..x] = a * DataSize[AllocElementType]
# indeks dla dwuwymiarowej tablicy [0..x, 0..y] = a * ((y+1) * DataSize[AllocElementType]) + b * DataSize[AllocElementType]

# dla typu OBJECT przekazywany jest poczatkowy adres alokacji danych pamieci (HI = regY, LO = regA), potem sa obliczane kolejne adresy w naglowku procedury/funkcji
# zaleca się uzywania typow prostych, wskazniki do tablic w OBJECT marnuja duzo zasobow CPU

# podczas wartosciowania wyrazen typy sa roszerzane, w przypadku operacji '-' promowane do SIGNEDORDINALTYPES (BYTE -> SMALLINTTOK ; WORD -> INTEGERTOK)

# (Tok[ ].Kind = ASMTOK + Tok[ ].Value = 0) wersja z { }
# (Tok[ ].Kind = ASMTOK + Tok[ ].Value = 1) wersja bez { }

# --------------------------------------------------------------------------------------------------------------
#                          |      DataType      |  AllocElementType  |  NumAllocElements  |  NumAllocElements_ |
# --------------------------------------------------------------------------------------------------------------
# VAR RECORD               | RECORDTOK          | 0                  | RecType            | 0                  |
# VAR ^RECORD              | POINTERTOK         | RECORDTOK          | RecType            | 0                  |
# ARRAY [0..X]             | POINTERTOK         | Type               | X Array Size       | 0                  |
# ARRAY [0..X, 0..Y]       | POINTERTOK         | Type               | X Array Size       | Y Array Size       |
# ARRAY [0..X] OF ^RECORD  | POINTERTOK         | RECORDTOK          | RecType            | X Array Size       |
# ARRAY [0..X] OF ^OBJECT  | POINTERTOK         | OBJECTTOK          | RecType            | X Array Size       |
# --------------------------------------------------------------------------------------------------------------

*)

program MADPASCAL;

{$i define.inc}

uses
	Crt, SysUtils,

{$IFDEF WINDOWS}
	Windows,
{$ENDIF}

	Common, Messages, Scanner, Parser, Optimize, Diagnostic, MathEvaluate;


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
   Result := Result + IntToHex(ord(Ident[IdentIndex].Param[ParamIndex].PassMethod), 2) +
		      IntToHex(Ident[IdentIndex].Param[ParamIndex].DataType, 2) +
		      IntToHex(Ident[IdentIndex].Param[ParamIndex].AllocElementType, 2) +
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

SetLength(best, 1);

best[0].IdentIndex := 0;
best[0].b := 0;
best[0].hit := 0;

for BlockStackIndex := BlockStackTop downto 0 do	// search all nesting levels from the current one to the most outer one
  begin
  for IdentIndex := NumIdent downto 1 do
    if
       (Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and
       (Ident[IdentIndex].UnitIndex = Ident[ProcIdentIndex].UnitIndex) and
       (S = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) and
       (Ident[IdentIndex].NumParams = NumParams) then
      begin

      hits := 0;


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

//	writeln(Ident[IdentIndex].Name,',', Ident[GetIdent('@FN' + IntToHex(Ident[IdentIndex].Param[i].NumAllocElements shr 16, 4))].NumParams,',',Param[i].AllocElementType,' | ', Ident[IdentIndex].Param[i].DataType,',', Param[i].AllocElementType,',',Ident[GetIdent('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))].NumParams);

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

	      inc(hits, df);
	      //while df > 0 do begin inc(hits); dec(df) end;
	     end;


	    end else begin						// signed

	     b := DataSize[Ident[IdentIndex].Param[i].DataType];	// required parameter type
	     k := DataSize[Param[i].DataType];				// type of parameter passed

	     if Param[i].DataType in [BYTETOK, WORDTOK] then inc(k);	// -> signed

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
	      (Ident[IdentIndex].Param[i].AllocElementType <> UNTYPETOK) and
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

end;	//GetIdentProc


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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
    Error(x, 'Not all declarations of ' + Ident[NumIdent].Name + ' are declared with OVERLOAD');

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


procedure a65(code: code65; Value: Int64 = 0; Kind: Byte = CONSTANT; Size: Byte = 4; IdentIndex: integer = 0);
var v: byte;
    svar: string;
begin

  case code of

	 __putEOL: asm65(#9'@printEOL');
	__putCHAR: asm65(#9'jsr @printCHAR');

      __shlAL_CL: asm65(#9'jsr @shlEAX_CL.BYTE');
      __shlAX_CL: asm65(#9'jsr @shlEAX_CL.WORD');
      __shlEAX_CL: asm65(#9'jsr @shlEAX_CL.CARD');

       __shrAL_CL: asm65(#9'jsr @shrAL_CL');
       __shrAX_CL: asm65(#9'jsr @shrAX_CL');
      __shrEAX_CL: asm65(#9'jsr @shrEAX_CL');

	     __je: asm65(#9'beq *+5');					// =
	    __jne: asm65(#9'bne *+5');					// <>

//	     __jg: begin asm65(#9'seq'); asm65(#9'bcs *+5') end;	// >
//	    __jge: asm65(#9'bcs *+5');					// >=
//	     __jl: asm65(#9'bcc *+5');					// <
//	    __jle: begin asm65(#9'bcc *+7'); asm65(#9'beq *+5') end;	// <=

	  __addBX: asm65(#9'inx');
	  __subBX: asm65(#9'dex');

       __addAL_CL: asm65(#9'jsr addAL_CL');
       __addAX_CX: asm65(#9'jsr addAX_CX');
     __addEAX_ECX: asm65(#9'jsr addEAX_ECX');

       __subAL_CL: asm65(#9'jsr subAL_CL');
       __subAX_CX: asm65(#9'jsr subAX_CX');
     __subEAX_ECX: asm65(#9'jsr subEAX_ECX');

	__imulECX: asm65(#9'jsr imulECX');

//     __notBOOLEAN: asm65(#9'jsr notBOOLEAN');
//	 __notaBX: asm65(#9'jsr notaBX');

//	 __negaBX: asm65(#9'jsr negaBX');

//     __xorEAX_ECX: asm65(#9'jsr xorEAX_ECX');
//       __xorAX_CX: asm65(#9'jsr xorAX_CX');
//       __xorAL_CL: asm65(#9'jsr xorAL_CL');

//     __andEAX_ECX: asm65(#9'jsr andEAX_ECX');
//       __andAX_CX: asm65(#9'jsr andAX_CX');
//       __andAL_CL: asm65(#9'jsr andAL_CL');

//      __orEAX_ECX: asm65(#9'jsr orEAX_ECX');
//	__orAX_CX: asm65(#9'jsr orAX_CX');
//	__orAL_CL: asm65(#9'jsr orAL_CL');

//     __cmpEAX_ECX: asm65(#9'jsr cmpEAX_ECX');
//       __cmpAX_CX: asm65(#9'jsr cmpEAX_ECX.AX_CX');
//    __cmpSHORTINT: asm65(#9'jsr cmpSHORTINT');
//    __cmpSMALLINT: asm65(#9'jsr cmpSMALLINT');
//	   __cmpINT: asm65(#9'jsr cmpINT');

//      __cmpSTRING: asm65(#9'jsr cmpSTRING');

 __cmpSTRING2CHAR: asm65(#9'jsr cmpSTRING2CHAR');
 __cmpCHAR2STRING: asm65(#9'jsr cmpCHAR2STRING');

   __movaBX_Value: begin
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

end;	//ExpandExpression


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


procedure GenerateIndexShift(ElementType: Byte; Ofset: Byte = 0);
begin

  case DataSize[ElementType] of

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

	if Ident[GetIdent(lab)].AllocElementType = RECORDTOK then begin

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


procedure Push(Value: Int64; IndirectionLevel: TIndirectionLevel; Size: Byte; IdentIndex: integer = 0; par: byte = 0);
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

    a65(__addBX);

    Gen;
    a65(__movaBX_Value, Value, Kind, Size, IdentIndex);

    end;


  ASPOINTER:
    begin
    asm65('; as Pointer');
    asm65;

    Gen;

    a65(__addBX);

    case Size of

      1: begin
	  asm65(#9'mva ' + svar + GetStackVariable(0));

	  ExpandByte;
	 end;

      2: begin

  	 if TestName(IdentIndex, svar) then begin

	  lab := ExtractName(IdentIndex, svar);

	  if Ident[GetIdent(lab)].AllocElementType = RECORDTOK then begin
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

    a65(__addBX);

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

    a65(__addBX);

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+'+svar);	// +lda

//	writeln(Ident[IdentIndex].PassMethod,',', Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', svar,',',ExtractName(IdentIndex, svar),',',par);

    if TestName(IdentIndex, svar) then begin

     if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].PassMethod <> VARPASSING) then
      asm65(#9'mwy ' + svar + ' :bp2')
     else
      asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

    end else
     asm65(#9'mwy ' + svar + ' :bp2');


    if TestName(IdentIndex, svar) then begin

     if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].PassMethod <> VARPASSING) then
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

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+');	// +lda

    end;


  ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
    begin
    asm65('; as Pointer to Array Origin');
    asm65;

    Gen;

    case Size of
      1: begin										// PUSH BYTE

	 if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('+'+svar);	// +lda

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

	    asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
	    asm65(#9'add' + GetStackVariable(0));
	    asm65(#9'tay');
	    asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
	    asm65(#9'adc' + GetStackVariable(1));
	    asm65(#9'sta :bp+1');
	    asm65(#9'lda (:bp),y');
	    asm65(#9'sta' + GetStackVariable(0));

	  end else begin

	   if Ident[IdentIndex].ObjectVariable and (Ident[IdentIndex].PassMethod = VARPASSING) then begin

 	     asm65(#9'mwy ' + svar + ' :TMP');

	     asm65(#9'ldy #$00');
	     asm65(#9'lda (:TMP),y');
	     asm65(#9'add' + GetStackVariable(0));
	     asm65(#9'sta :bp2');
	     asm65(#9'iny');
	     asm65(#9'lda (:TMP),y');
	     asm65(#9'adc' + GetStackVariable(1));
	     asm65(#9'sta :bp2+1');
	     asm65(#9'ldy #$00');
	     asm65(#9'lda (:bp2),y');
	     asm65(#9'sta' + GetStackVariable(0));

	   end else begin

	     asm65(#9'lda '+svar);
	     asm65(#9'add' + GetStackVariable(0));
	     asm65(#9'tay');
	     asm65(#9'lda '+svar+'+1');
	     asm65(#9'adc' + GetStackVariable(1));
	     asm65(#9'sta :bp+1');
	     asm65(#9'lda (:bp),y');
	     asm65(#9'sta' + GetStackVariable(0));

	   end;

	  end;

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

      2: begin										// PUSH WORD

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(WORDTOK);

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

	    if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

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

	  if Ident[IdentIndex].PassMethod = VARPASSING then begin

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
	 GenerateIndexShift(CARDINALTOK);

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

	    if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

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

	  if Ident[IdentIndex].PassMethod = VARPASSING then begin

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
    asm65(#9'lda (:TMP),y');
    asm65(#9'sta :bp2');
    asm65(#9'iny');
    asm65(#9'lda (:TMP),y');
    asm65(#9'sta :bp2+1');

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

//     a65(__subBX);
     a65(__subBX);

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

 if Pass = CODEGENERATIONPASS then
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

 if Pass = CALLDETERMPASS then begin

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


procedure GenerateFileOpen(IdentIndex: Integer; Code: ioCode);
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

end;	//GenerateFileOpen


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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

end;	//GenerateFileRead


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateIncDec(IndirectionLevel: TIndirectionLevel; ExpressionType: Byte; Down: Boolean; IdentIndex: integer);
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

	     case DataSize[ExpressionType] of
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

	     case DataSize[ExpressionType] of
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

		   if Ident[IdentIndex].PassMethod = VARPASSING then begin

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

		     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

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

		   if Ident[IdentIndex].isStriped  then begin

		     asm65(#9'ldy :STACKORIGIN-1,x');
		     asm65(#9'lda ' + svara + ',y');
		     asm65(#9 + b + ' :STACKORIGIN,x');
		     asm65(#9'sta ' + svara + ',y');
		     asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
		     asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
		     asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

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

		     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

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


	   	   if Ident[IdentIndex].isStriped then begin

	     	     asm65(#9'ldy :STACKORIGIN-1,x');
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

	     end;

	   a65(__subBX);

	end;

 end;

 a65(__subBX);
end;	//GenerateIncDec


procedure GenerateAssignment(IndirectionLevel: TIndirectionLevel; Size: Byte; IdentIndex: integer; Param: string = ''; ParamY: string = '');
var NumAllocElements: cardinal;
    IdentTemp: integer;
    svar, svara: string;


  procedure LoadRegisterY;
  begin

    if ParamY <> '' then
      asm65(#9'ldy #' + ParamY)
    else
     if pos('.', Ident[IdentIndex].Name) > 0 then begin

       if (Ident[IdentIndex].DataType = POINTERTOK) and not (Ident[IdentIndex].AllocElementType in [UNTYPETOK, PROCVARTOK]) then
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

     IdentTemp := GetIdent(ExtractName(IdentIndex, svar));
     if (IdentTemp > 0) and (Ident[IdentTemp].DataType = POINTERTOK) and (Ident[IdentTemp].AllocElementType = RECORDTOK) and (Ident[IdentTemp].NumAllocElements_ > 1) and (Ident[IdentTemp].NumAllocElements_ <= 128) then begin

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
       asm65(#9'lda (:TMP),y');
       asm65(#9'sta :bp2');
       asm65(#9'iny');
       asm65(#9'lda (:TMP),y');
       asm65(#9'sta :bp2+1');

     end;

    end else begin
     asm65(#9'lda '+svar);
     asm65(#9'add :STACKORIGIN-1,x');
     asm65(#9'sta :TMP');
     asm65(#9'lda '+svar+'+1');
     asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
     asm65(#9'sta :TMP+1');

     asm65(#9'ldy #$00');
     asm65(#9'lda (:TMP),y');
     asm65(#9'sta :bp2');
     asm65(#9'iny');
     asm65(#9'lda (:TMP),y');
     asm65(#9'sta :bp2+1');

    end;

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
      1: begin										// PULL BYTE

	 if (NumAllocElements > 256) or (NumAllocElements in [0,1]) then begin

	  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('-'+svar);	// -sta

	    if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value), 2));
	      asm65(#9'add :STACKORIGIN-1,x');
	      asm65(#9'tay');
	      asm65(#9'lda #$' + IntToHex(byte(Ident[IdentIndex].Value shr 8), 2));
	      asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	      asm65(#9'sta :bp+1');
	      asm65(#9'lda :STACKORIGIN,x');
	      asm65(#9'sta (:bp),y');

	    end else begin

	     if Ident[IdentIndex].ObjectVariable and (Ident[IdentIndex].PassMethod = VARPASSING) then begin

 	      asm65(#9'mwy ' + svar + ' :TMP');

	      asm65(#9'ldy #$00');
	      asm65(#9'lda (:TMP),y');
	      asm65(#9'add :STACKORIGIN-1,x');
	      asm65(#9'sta :bp2');
	      asm65(#9'iny');
	      asm65(#9'lda (:TMP),y');
	      asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	      asm65(#9'sta :bp2+1');
	      asm65(#9'ldy #$00');
	      asm65(#9'lda :STACKORIGIN,x');
	      asm65(#9'sta (:bp2),y');

	     end else begin

	      asm65(#9'lda ' + svar);
	      asm65(#9'add :STACKORIGIN-1,x');
	      asm65(#9'tay');
	      asm65(#9'lda ' + svar + '+1');
	      asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
	      asm65(#9'sta :bp+1');
	      asm65(#9'lda :STACKORIGIN,x');
	      asm65(#9'sta (:bp),y');

	     end;

	    end;


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
	  asm65(#9'sta ' + svara + ',y');
// =b'
	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);
	 end;

      2: begin										// PULL WORD

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	 GenerateIndexShift(WORDTOK, 1);

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

	     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

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
	  asm65(#9'sta ' + svara + ',y');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

	  if Ident[IdentIndex].isStriped then
	    asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
	  else
	    asm65(#9'sta ' + svara + '+1,y');
// w='
	 end;

	 end;

	 a65(__subBX);
	 a65(__subBX);

	 end;

      4: begin										// PULL CARDINAL

	 if IndirectionLevel = ASPOINTERTOARRAYORIGIN  then
	  GenerateIndexShift(CARDINALTOK, 1);

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

	     if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].idType = ARRAYTOK) and (Ident[IdentIndex].Value >= 0) then begin

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

	 a65(__subBX);
	 a65(__subBX);

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

	 if Ident[IdentIndex].PassMethod = VARPASSING then begin

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

	 a65(__subBX);
	 a65(__subBX);

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

    a65(__subBX);
    a65(__subBX);

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

    a65(__subBX);
    a65(__subBX);

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

     a65(__subBX);
     a65(__subBX);
     a65(__subBX);

    end;


  ASPOINTERTOPOINTER:
    begin
    asm65('; as Pointer to Pointer');

  if (Ident[IdentIndex].isAbsolute) and (Ident[IdentIndex].PassMethod <> VARPASSING) and (NumAllocElements = 0) then asm65('-'+svar);	// -sta

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,' / ',svar ,' / ', UnitName[Ident[IdentIndex].UnitIndex].Name,',',svar.LastIndexOf('.'));

    if TestName(IdentIndex, svar) then begin

     if (Ident[IdentIndex].DataType = POINTERTOK) and not (Ident[IdentIndex].AllocElementType in [UNTYPETOK, PROCVARTOK]) then
      asm65(#9'mwy ' + svar + ' :bp2')
     else
      asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

    end else
     asm65(#9'mwy ' + svar + ' :bp2');


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

a65(__subBX);

asm65(#9'lda :STACKORIGIN+1,x');

a65(__jne);
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateElseCondition;
begin
//asm65;
//asm65('; else condition');

Gen; Gen; Gen;								// mov :eax, [bx]

a65(__je);

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


procedure GenerateRelationOperation(rel: Byte; ValType: Byte);
begin

 case rel of
  EQTOK:
    begin
    Gen; Gen;								// je +3   =

    asm65(#9'beq @+');
    end;

  NETOK, 0:
    begin
    Gen; Gen;								// jne +3  <>

    asm65(#9'bne @+');
    end;

  GTTOK:
    begin
    Gen; Gen;								// jg +3   >

    asm65(#9'seq');

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+')
    else
     asm65(#9'bcs @+');

    end;

  GETOK:
    begin
    Gen; Gen;								// jge +3  >=

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bpl @+')
    else
     asm65(#9'bcs @+');

    end;

  LTTOK:
    begin
    Gen; Gen;								// jl +3   <

    if ValType in (RealTypes + SignedOrdinalTypes) then
     asm65(#9'bmi @+')
    else
     asm65(#9'bcc @+');

    end;

  LETOK:
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


procedure GenerateForToDoCondition(ValType: Byte; Down: Boolean; IdentIndex: integer);
var svar: string;
    CounterSize: Byte;
begin

svar    := GetLocalName(IdentIndex);
CounterSize := DataSize[ValType];

asm65(';'+InfoAboutSize(CounterSize));

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
   asm65(#9'bpl *+5')
  else
   asm65(#9'bcs *+5');

  end

else
  begin

  if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then begin
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


procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: Byte; Join: Boolean; CaseLocalCnt: integer);
begin
Gen; Gen;							// cmp :ecx, Value

case DataSize[SelectorType] of

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


procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: Byte; Join: Boolean; CaseLocalCnt: integer);
begin

 Gen; Gen;							// cmp :ecx, Value1

 if (SelectorType in [BYTETOK, CHARTOK, ENUMTYPE]) and (Value1 >= 0) and (Value2 >= 0) then begin

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

  case DataSize[SelectorType] of
   1: begin
       if join=false then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

       asm65(#9'cmp #' + IntToStr(byte(Value1)));
      end;

  end;

  GenerateRelationOperation(LTTOK, SelectorType);

  case DataSize[SelectorType] of
   1: begin
//       asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

       asm65(#9'cmp #' + IntToStr(byte(Value2)));
      end;

  end;

  GenerateRelationOperation(GTTOK, SelectorType);

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
 if Pass = CODEGENERATIONPASS then begin
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


procedure GenerateForToDoEpilog (ValType: Byte; Down: Boolean; IdentIndex: integer = 0; Epilog: Boolean = true; forBPL: byte = 0);
var svar: string;
    CounterSize: Byte;
begin

svar    := GetLocalName(IdentIndex);
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


procedure GenerateWriteString(Address: Word; IndirectionLevel: TIndirectionLevel; ValueType: byte = INTEGERTOK);
begin
//Gen; Gen;							// mov ah, 09h

asm65;

case IndirectionLevel of

  ASBOOLEAN:
    begin
     asm65(#9'jsr @printBOOLEAN');

     a65(__subBX);
    end;

  ASCHAR:
    begin
     asm65(#9'@printCHAR');

     a65(__subBX);
    end;

  ASSHORTREAL:
    begin
     asm65(#9'jsr @printSHORTREAL');

     a65(__subBX);
    end;

  ASREAL:
    begin
     asm65(#9'jsr @printREAL');

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

     a65(__subBX);
    end;

  ASPOINTER:
    begin

     asm65(#9'@printSTRING #CODEORIGIN+$'+IntToHex(Address - CODEORIGIN, 4));

//    a65(__subBX);   !!!   bez DEX-a
    end;

  ASPOINTERTOPOINTER:
    begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'jsr @printSTRING');

     a65(__subBX);
    end;


  ASPCHAR:
    begin

     asm65(#9'lda :STACKORIGIN,x');
     asm65(#9'ldy :STACKORIGIN+STACKWIDTH,x');
     asm65(#9'jsr @printPCHAR');

     a65(__subBX);
    end;


  end;

end;	//GenerateWriteString


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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

  NOTTOK:
    begin
    Gen; Gen; Gen;						// not dword ptr [bx]

    if ValType = BOOLEANTOK then begin
//     a65(__notBOOLEAN)

       asm65(#9'ldy #1');					// !!! wymagana konwencja
       asm65(#9'lda :STACKORIGIN,x');
       asm65(#9'beq @+');
       asm65(#9'dey');
       asm65('@');
//       asm65(#9'tya');		!!! ~
       asm65(#9'sty :STACKORIGIN,x');

    end else begin

     ExpandParam(INTEGERTOK, ValType);

//     a65(__notaBX);

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
     if ResultType = SINGLETOK then begin
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
    if ResultType = SINGLETOK then begin
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

       SHORTREALTOK:					// Q8.8 fixed-point
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

	    REALTOK:					// Q24.8 fixed-point
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

	  SINGLETOK: //asm65(#9'jsr @FMUL');		// IEEE754 32bit
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

    if ResultType in RealTypes then begin		// Real division

      case ResultType of
       SHORTREALTOK:					// Q8.8 fixed-point
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

	    REALTOK:					// Q24.8 fixed-point
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

	  SINGLETOK:					// IEEE754 32bit
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

      HALFSINGLETOK:					// IEEE754 16bit
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

      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); a65(__shlEAX_CL) end;

      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); a65(__shlEAX_CL) end;

      4: a65(__shlEAX_CL);

     end;

    end else
     case DataSize[ResultType] of
      1: a65(__shlAL_CL);
      2: a65(__shlAX_CL);
      4: a65(__shlEAX_CL);
     end;

    end;


  SHRTOK:
    begin

    if ResultType in SignedOrdinalTypes then begin

     case DataSize[ResultType] of

      1: begin asm65(#9'jsr @expandToCARD1.SHORT'); a65(__shrEAX_CL) end;

      2: begin asm65(#9'jsr @expandToCARD1.SMALL'); a65(__shrEAX_CL) end;

      4: a65(__shrEAX_CL);

     end;

    end else
     case DataSize[ResultType] of
      1: a65(__shrAL_CL);
      2: a65(__shrAX_CL);
      4: a65(__shrEAX_CL);
     end;

    end;


  ANDTOK:
    begin

    case DataSize[ResultType] of
      1: //a65(__andAL_CL);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'and :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');
      end;

      2: //a65(__andAX_CX);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'and :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'and :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
      end;

      4: //a65(__andEAX_ECX)
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


  ORTOK:
    begin

    case DataSize[ResultType] of
      1: //a65(__orAL_CL);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'ora :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');
      end;

      2: //a65(__orAX_CX);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'ora :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'ora :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
      end;

      4: //a65(__orEAX_ECX)
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


  XORTOK:
    begin

    case DataSize[ResultType] of
      1: //a65(__xorAL_CL);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'eor :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');
      end;

      2: //a65(__xorAX_CX);
      begin
	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'eor :STACKORIGIN,x');
	asm65(#9'sta :STACKORIGIN-1,x');

	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'eor :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');
      end;

      4: //a65(__xorEAX_ECX)
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

a65(__subBX);

end;	//GenerateBinaryOperation


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelationString(rel: Byte; LeftValType, RightValType: Byte; sLeft: WordBool = false; sRight: WordBool = false);
begin
 asm65;
 asm65('; relation STRING');

 Gen;

 asm65(#9'ldy #1');

 Gen;

 if (LeftValType = POINTERTOK) and (RightValType = POINTERTOK) then begin

 	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @cmpSTRING.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @cmpSTRING.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.A+1');

	asm65(#9'jsr @cmpPCHAR');

 end else
 if (LeftValType = POINTERTOK) and (RightValType = STRINGPOINTERTOK) then begin

 	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @cmpSTRING.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @cmpSTRING.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.A+1');

	asm65(#9'jsr @cmpPCHAR2STRING');

 end else
 if (LeftValType = STRINGPOINTERTOK) and (RightValType = POINTERTOK) then begin

 	asm65(#9'lda :STACKORIGIN,x');
	asm65(#9'sta @cmpSTRING.B');
	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.B+1');

	asm65(#9'lda :STACKORIGIN-1,x');
	asm65(#9'sta @cmpSTRING.A');
	asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	asm65(#9'sta @cmpSTRING.A+1');

	asm65(#9'jsr @cmpSTRING2PCHAR');

 end else
 if (LeftValType = STRINGPOINTERTOK) and (RightValType = STRINGPOINTERTOK) then begin
//  a65(__cmpSTRING)					// STRING ? STRING

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
 if LeftValType = CHARTOK then
  a65(__cmpCHAR2STRING)					// CHAR ? STRING
 else
 if RightValType = CHARTOK then
  a65(__cmpSTRING2CHAR);				// STRING ? CHAR

 GenerateRelationOperation(rel, BYTETOK);

 Gen;

 asm65(#9'dey');
 asm65('@');
// asm65(#9'tya');			!!! ~
 asm65(#9'sty :STACKORIGIN-1,x');

 a65(__subBX);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateRelation(rel: Byte; ValType: Byte);
begin
// asm65;
// asm65('; relation');

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

  LTTOK:	// <
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

  LETOK:	// <=
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

 asm65(#9'ldy #1');

 Gen;

 case ValType of
     BYTETOK, CHARTOK, BOOLEANTOK:
	begin
	 asm65(#9'lda :STACKORIGIN-1,x');
	 asm65(#9'cmp :STACKORIGIN,x');
	end;

     SHORTINTTOK:
	begin	//a65(__cmpSHORTINT);

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

     SMALLINTTOK, SHORTREALTOK:
	begin	//a65(__cmpSMALLINT);

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

     SINGLETOK: asm65(#9'jsr @FCMPL');

     REALTOK, INTEGERTOK:
	begin	//a65(__cmpINT);

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

     WORDTOK, POINTERTOK, STRINGPOINTERTOK:
     	begin	//a65(__cmpAX_CX);

         asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
         asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
         asm65(#9'bne @+');
         asm65(#9'lda :STACKORIGIN-1,x');
         asm65(#9'cmp :STACKORIGIN,x');
         asm65('@');

	end;

 else
	begin	//a65(__cmpEAX_ECX);					// CARDINALTOK

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

 a65(__subBX);

 end; // if ValType = HALFSINGLETOK

end;	//GenerateRelation


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// The following functions implement recursive descent parser in accordance with Sub-Pascal EBNF
// Parameter i is the index of the first token of the current EBNF symbol, result is the index of the last one

function CompileExpression(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer; forward;


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileArrayIndex(i: integer; IdentIndex: integer; out VarType: Byte): integer;
var ConstVal: Int64;
    ActualParamType, ArrayIndexType, Size: Byte;
    NumAllocElements, NumAllocElements_: cardinal;
    j: integer;
    yes, ShortArrayIndex: Boolean;
begin

	      if common.optimize.use = false then StartOptimization(i);


	      if (Ident[IdentIndex].isStriped) then
	        Size := 1
	      else
   	        Size := DataSize[Ident[IdentIndex].AllocElementType];


	      ShortArrayIndex := false;

	      VarType := Ident[IdentIndex].AllocElementType;


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


	      if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK, PROCVARTOK] then NumAllocElements_ := 0;


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
		 i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	// array index [x, ..]

		 GetCommonType(i, ActualParamType, ArrayIndexType);

		 case ArrayIndexType of
		  SHORTINTTOK: ArrayIndexType := BYTETOK;
		  SMALLINTTOK: ArrayIndexType := WORDTOK;
		   INTEGERTOK: ArrayIndexType := CARDINALTOK;
		 end;

		 if DataSize[ArrayIndexType] = 4 then begin	// remove oldest bytes
	  	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
	  	  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		  asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		 end;

		 if DataSize[ArrayIndexType] = 1 then begin
		  ExpandParam(WORDTOK, ArrayIndexType);
//		  ArrayIndexType := WORDTOK;
		 end else
		  ArrayIndexType := WORDTOK;

		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
//		    ExpandParam(WORDTOK, ArrayIndexType);
		    ArrayIndexType := WORDTOK;
		  end;


		 if NumAllocElements_ > 0 then begin

		   Push(integer(NumAllocElements_ * Size), ASVALUE, DataSize[ArrayIndexType]);

		   GenerateBinaryOperation(MULTOK, ArrayIndexType);

		 end else
		   if Ident[IdentIndex].isStriped = FALSE then GenerateIndexShift( Ident[IdentIndex].AllocElementType );

	      end;


	    yes:=false;

	    if NumAllocElements_ > 0 then begin

	     if (Tok[i + 1].Kind = CBRACKETTOK) and (Tok[i + 2].Kind in [ASSIGNTOK, SEMICOLONTOK]) then begin
	      yes := FALSE;

	      VarType := ARRAYTOK;
	     end else
	     if Tok[i + 1].Kind = CBRACKETTOK then begin
	      inc(i);
	      CheckTok(i + 1, OBRACKETTOK);
	      yes := TRUE;
	     end else begin
	      CheckTok(i + 1, COMMATOK);
	      yes := TRUE;
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
		  i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);	// array index [.., y]

		  GetCommonType(i, ActualParamType, ArrayIndexType);

		  case ArrayIndexType of
		   SHORTINTTOK: ArrayIndexType := BYTETOK;
		   SMALLINTTOK: ArrayIndexType := WORDTOK;
		    INTEGERTOK: ArrayIndexType := CARDINALTOK;
		  end;

		  if DataSize[ArrayIndexType] = 4 then begin	// remove oldest bytes
	  	   asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
	  	   asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
		   asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
		  end;

		  if DataSize[ArrayIndexType] = 1 then begin
		   ExpandParam(WORDTOK, ArrayIndexType);
		   ArrayIndexType := WORDTOK;
		  end else
		   ArrayIndexType := WORDTOK;

//		  if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
//		    ExpandParam(WORDTOK, ArrayIndexType);
//		    ArrayIndexType := WORDTOK;
//		  end;

		  if Ident[IdentIndex].isStriped = FALSE then GenerateIndexShift( Ident[IdentIndex].AllocElementType );

		end;

		GenerateBinaryOperation(PLUSTOK, WORDTOK);

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

	if not(Ident[IdentIndex].Kind in [CONSTANT, VARIABLE, PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK, ADDRESSTOK]) then
	 iError(i + 1, VariableExpected)
	else begin

 	  if Ident[IdentIndex].Kind = CONSTANT then
	   if not ( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
	     iError(i + 1, CantAdrConstantExp);


//	writeln(Ident[IdentIndex].nAME,' = ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod );


	  if Ident[IdentIndex].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then begin

	    Name := GetLocalName(IdentIndex);

	    if Ident[IdentIndex].isOverload then Name := Name + '.' + GetOverloadName(IdentIndex);

	    a65(__addBX);
	    asm65(#9'mva <'+Name+' :STACKORIGIN,x');
	    asm65(#9'mva >'+Name+' :STACKORIGIN+STACKWIDTH,x');

	    if Pass = CALLDETERMPASS then
	      AddCallGraphChild(BlockStack[BlockStackTop], Ident[IdentIndex].ProcAsBlock);

	  end else

	  if (Tok[i + 2].Kind = OBRACKETTOK) and
	     (Ident[IdentIndex].DataType in Pointers) and
	     ((Ident[IdentIndex].NumAllocElements > 0) or ((Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK))) then
	  begin									// array index
	      inc(i);

 // atari	  // a := @tab[x,y]

	      i := CompileArrayIndex(i, IdentIndex, AllocElementType);


	if Ident[IdentIndex].DataType = ENUMTYPE then begin
//   Size := DataSize[Ident[IdentIndex].AllocElementType];
	 NumAllocElements := 0;
	end else
	 NumAllocElements := Elements(IdentIndex); //Ident[IdentIndex].NumAllocElements;

	svar := GetLocalName(IdentIndex);

  	if (pos('.', svar) > 0) then begin
//	 lab:=copy(svar,1,pos('.', svar)-1);
	 lab := ExtractName(IdentIndex, svar);

	 rec := (Ident[GetIdent(lab)].AllocElementType = RECORDTOK);
	end;

	//AllocElementType := Ident[IdentIndex].AllocElementType;

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

	if (Ident[IdentIndex].PassMethod = VARPASSING) or (NumAllocElements * DataSize[AllocElementType] > 256) or (NumAllocElements in [0,1]) then begin

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

	     CheckTok(i + 1, CBRACKETTOK);

	     end else
	      if (Ident[IdentIndex].DataType in [FILETOK, TEXTFILETOK, RECORDTOK, OBJECTTOK] {+ Pointers}) or
	         ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> 0) and (Ident[IdentIndex].NumAllocElements > 0)) or
		 (Ident[IdentIndex].PassMethod = VARPASSING) or
		 (VarPass and (Ident[IdentIndex].DataType in Pointers))  then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',Tok[i + 2].Kind);

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
		  if (Ident[IdentIndex].AllocElementType = RECORDTOK) and (Tok[i + 3].Kind = DOTTOK) then begin		// var record^.field

//		    DEREFERENCE := true;

		    CheckTok(i + 4, IDENTTOK);
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
//trs
		    if Ident[IdentIndex].ObjectVariable and (Ident[IdentIndex].PassMethod = VARPASSING) then
		      Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, DataSize[POINTERTOK], IdentIndex)
		    else
		      Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

		    inc(i);
		  end;


//	writeln('5: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE,',',VarPass);


		  end else
		   if address or VarPass then begin
//		   if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements = 0) {and (Ident[IdentIndex].PassMethod <> VARPASSING)} then begin

//	writeln('1: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,'..',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE,',',varpass,' o ',Ident[IdentIndex].isAbsolute);

                     if (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK, FILETOK, TEXTFILETOK]) or
		        (VarPass and (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in AllTypes - [PROCVARTOK, RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].NumAllocElements = 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) and (VarPass or (Ident[IdentIndex].PassMethod = VARPASSING)) ) or
		        (Ident[IdentIndex].isAbsolute and (abs(Ident[IdentIndex].Value) and $ff = 0) and (byte(abs(Ident[IdentIndex].Value shr 24) and $7f) in [1..127])) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].NumAllocElements_ = 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].idType = DATAORIGINOFFSET)) or
		        ((Ident[IdentIndex].DataType in Pointers) and not (Ident[IdentIndex].AllocElementType in [UNTYPETOK, RECORDTOK, OBJECTTOK, PROCVARTOK]) and (Ident[IdentIndex].NumAllocElements > 0)) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].PassMethod = VARPASSING) )
		     then
		       Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex)
		     else
		       Push(Ident[IdentIndex].Value, ASVALUE, DataSize[POINTERTOK], IdentIndex);

		     AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   end else begin

//	writeln('2: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

		     Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

		     AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   end;

	      end else begin

		 if (Ident[IdentIndex].DataType in Pointers) and (Tok[i + 2].Kind = DEREFERENCETOK) then begin
		   AllocElementType :=  Ident[IdentIndex].AllocElementType;

		   inc(i);

		   Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
		 end else
//		  if (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> 0) and (Ident[IdentIndex].NumAllocElements = 0) then begin
//	writeln('3: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);
//		   Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
//		  end else
		  begin

//	writeln('4: ',Ident[IdentIndex].Name,',',Ident[IdentIndex].idType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].PassMethod,',',DEREFERENCE);

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

end;	//CompileAddress


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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

	if (ActualParamType in [POINTERTOK, STRINGPOINTERTOK]) and (Tok[i].Kind = IDENTTOK) then begin

	  IdentTemp := GetIdent(Tok[i].Name^);

	  if (Tok[i - 1].Kind = ADDRESSTOK) and (not (Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK])) then

	  else begin
	   AllocElementType := Ident[IdentTemp].AllocElementType;
	   NumAllocElements := Ident[IdentTemp].NumAllocElements;
	  end;


	  if Ident[IdentTemp].Kind in [PROCEDURETOK, FUNCTIONTOK] then begin

           Result[NumActualParams].Name := Ident[IdentTemp].Name;

	   AllocElementType := Ident[IdentTemp].Kind;

	  end;

//	writeln(Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements,'/',Ident[IdentTemp].NumAllocElements_,'|',ActualParamType,',',AllocElementType);

	end else begin

	 if Tok[i].Kind = IDENTTOK then begin

	  IdentTemp := GetIdent(Tok[i].Name^);

	  AllocElementType := Ident[IdentTemp].AllocElementType;
	  NumAllocElements := Ident[IdentTemp].NumAllocElements;

//	writeln(Ident[IdentTemp].Name,' > ',ActualPAramType,',',AllocElementType,',',NumAllocElements,' | ',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements);

	 end else
	  AllocElementType := UNTYPETOK;

	end;

       Result[NumActualParams].DataType := ActualParamType;
       Result[NumActualParams].AllocElementType := AllocElementType;
       Result[NumActualParams].NumAllocElements := NumAllocElements;


//	writeln(Result[NumActualParams].DataType,',',Result[NumActualParams].AllocElementType);

     until Tok[i + 1].Kind <> COMMATOK;

     CheckTok(i + 1, CPARTOK);

     Result[1].i_ := i;

//     inc(i);
     end;	// if (Tok[i + 1].Kind = OPARTOR) and (Tok[i + 2].Kind <> CPARTOK)


     Pass := oldPass;
     CodeSize := oldCodeSize;

end;	//NumActualParameters


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileActualParameters(var i: integer; IdentIndex: integer; ProcVarIndex: integer = 0);
var NumActualParams, IdentTemp, ParamIndex, j, old_i, old_func: integer;
    ActualParamType, AllocElementType: byte;
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
    if not ( (Ident[IdentIndex].Param[ParamIndex].PassMethod = VARPASSING) or
	     ((Ident[IdentIndex].Param[ParamIndex].DataType in Pointers) and (Ident[IdentIndex].Param[ParamIndex].NumAllocElements and $FFFF in [0,1])) or
	     ((Ident[IdentIndex].Param[ParamIndex].DataType in Pointers) and (Ident[IdentIndex].Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) or
             (Ident[IdentIndex].Param[ParamIndex].DataType in OrdinalTypes + RealTypes)
	   ) then begin yes := TRUE; Break end;


//   yes:=true;

(*------------------------------------------------------------------------------------------------------------*)

   if  ProcVarIndex > 0 then begin

     svar := GetLocalName(ProcVarIndex);

     if (Tok[i + 1].Kind = OBRACKETTOK) then begin
       i := CompileArrayIndex(i, ProcVarIndex, AllocElementType);

       CheckTok(i + 1, CBRACKETTOK);

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

         if (Ident[ProcVarIndex].PassMethod = VARPASSING) then begin

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

       if (Ident[IdentIndex].Param[NumActualParams].PassMethod = VARPASSING) then begin

	i := CompileAddress(i + 1, ActualParamType, AllocElementType, true);


//	writeln(Ident[IdentIndex].Param[NumActualParams].Name,',',Ident[IdentIndex].Param[NumActualParams].DataType  ,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements and $FFFF,'/',Ident[IdentIndex].Param[NumActualParams].NumAllocElements shr 16,' | ',ActualParamType,',', AllocElementType);


	if (Ident[IdentIndex].Param[NumActualParams].DataType <> UNTYPETOK) and (ActualParamType = POINTERTOK) and (AllocElementType in [POINTERTOK, STRINGPOINTERTOK, PCHARTOK]) then begin

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


	if Tok[i].Kind = IDENTTOK then
	 IdentTemp := GetIdent(Tok[i].Name^)
	else
	 IdentTemp := 0;

	if IdentTemp > 0 then begin


	if Ident[IdentTemp].Kind = FUNCTIONTOK then iError(i, CantAdrConstantExp);	// VARPASSING function not possible


//	writeln(' - ',Tok[i].Name^,',',ActualParamType,',',AllocElementType, ',', Ident[IdentTemp].NumAllocElements );
//	writeln(Ident[IdentTemp].Kind,',',Ident[IdentTemp].DataType,',',Ident[IdentIndex].Param[NumActualParams].DataType);

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


	 if (Ident[IdentTemp].AllocElementType = UNTYPETOK) then begin

	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].DataType);

	   if (Ident[IdentTemp].AllocElementType = UNTYPETOK) then
	     if (Ident[IdentIndex].Param[NumActualParams].DataType <> UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType <> Ident[IdentTemp].DataType) then
	       iError(i, IncompatibleTypes, 0, Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].DataType);

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

	     if (Ident[IdentIndex].Param[NumActualParams].AllocElementType = UNTYPETOK) and (Ident[IdentIndex].Param[NumActualParams].DataType in [POINTERTOK, PCHARTOK]) then begin

	      if Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK] then

	      else
	        iError(i, IncompatibleTypesArray, IdentTemp, Ident[IdentIndex].Param[NumActualParams].DataType);

	     end else
	      iError(i, IncompatibleTypes, 0, Ident[IdentTemp].AllocElementType, Ident[IdentIndex].Param[NumActualParams].AllocElementType);

	   end;

	  end else
	   GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, Ident[IdentTemp].AllocElementType);

	end else
	  if  Ident[IdentIndex].Param[NumActualParams].DataType <> UNTYPETOK then
	   if (Ident[IdentIndex].Param[NumActualParams].DataType <> AllocElementType)  then begin

//	writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType);

	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> UNTYPETOK then begin

	       if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> AllocElementType then
	         iError(i, IncompatibleTypes, 0, AllocElementType, Ident[IdentIndex].Param[NumActualParams].DataType);

	     end else
	       iError(i, IncompatibleTypes, 0, AllocElementType, Ident[IdentIndex].Param[NumActualParams].DataType);

	   end;


//	writeln('x ',Ident[IdentIndex].name,',', Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType,',',IdentTemp);


	  if IdentTemp = 0 then
	   if (Ident[IdentIndex].Param[NumActualParams].DataType = RECORDTOK) and (ActualParamType = POINTERTOK) and (AllocElementType = RECORDTOK) then

	   else
	   if (ActualParamType = POINTERTOK) and (AllocElementType <> UNTYPETOK) then
	     GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, AllocElementType)
	   else
	    GetCommonType(i, Ident[IdentIndex].Param[NumActualParams].DataType, ActualParamType);


       end else begin

	i := CompileExpression(i + 2, ActualParamType, Ident[IdentIndex].Param[NumActualParams].DataType);	// Evaluate actual parameters and push them onto the stack

//	writeln(Ident[IdentIndex].name,',', Ident[IdentIndex].kind,',',    Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].AllocElementType ,'|',ActualParamType);


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

//	writeln('1 > ',Ident[IdentTemp].name,',', Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements,' | ',Ident[IdentIndex].Param[NumActualParams].DataType,',',Ident[IdentIndex].Param[NumActualParams].NumAllocElements );

            if (Ident[IdentTemp].DataType = STRINGPOINTERTOK) and (Ident[IdentTemp].NumAllocElements <> 0) and (Ident[IdentIndex].Param[NumActualParams].DataType = POINTERTOK) and (Ident[IdentIndex].Param[NumActualParams].NumAllocElements = 0) then
	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType = UNTYPETOK then
	       iError(i, IncompatibleTypes, 0, Ident[IdentTemp].DataType, Ident[IdentIndex].Param[NumActualParams].DataType)
	     else
	     if Ident[IdentIndex].Param[NumActualParams].AllocElementType <> BYTETOK then		// wyjatkowo akceptujemy PBYTE jako STRING
	       iError(i, IncompatibleTypes, 0, Ident[IdentTemp].DataType, -Ident[IdentIndex].Param[NumActualParams].AllocElementType);

{
	      if (Ident[IdentIndex].Param[NumActualParams].DataType = PCHARTOK) then begin

	        if Ident[IdentTemp].DataType = STRINGPOINTERTOK then begin
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

            if (ActualParamType = POINTERTOK) and (Ident[IdentIndex].Param[NumActualParams].DataType = STRINGPOINTERTOK) then
              iError(i, IncompatibleTypes, 0, ActualParamType, -STRINGPOINTERTOK);

	      if (Ident[IdentIndex].Param[NumActualParams].DataType = STRINGPOINTERTOK) then begin		// CHAR -> STRING

	        if (ActualParamType = CHARTOK) and (Tok[i].Kind = CHARLITERALTOK) then begin

		  ActualParamType := STRINGPOINTERTOK;

		  if Pass = CODEGENERATIONPASS then begin
		   DefineStaticString(i, chr(Tok[i].Value));
		   Tok[i].Kind := STRINGLITERALTOK;

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


	      if (Ident[IdentIndex].Param[NumActualParams].DataType = PCHARTOK) then begin

	        if (ActualParamType = STRINGPOINTERTOK) then begin
	          asm65(#9'lda :STACKORIGIN,x');
		  asm65(#9'add #$01');
	          asm65(#9'sta :STACKORIGIN,x');
	          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		  asm65(#9'adc #$00');
	          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
		end;


	        if (ActualParamType = CHARTOK) and (Tok[i].Kind = CHARLITERALTOK) then begin

		  ActualParamType := PCHARTOK;

		  if Pass = CODEGENERATIONPASS then begin
		   DefineStaticString(i, chr(Tok[i].Value));
		   Tok[i].Kind := STRINGLITERALTOK;

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
	   (Ident[IdentIndex].Param[NumActualParams].PassMethod <> VARPASSING) and
	   (Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and
	   (Ident[IdentIndex].Param[NumActualParams].NumAllocElements and $FFFF > 1) then

	 if Ident[IdentIndex].Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK] then begin

 	  if Ident[IdentIndex].isOverload then
  	    svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
 	  else
  	    svar := GetLocalName(IdentIndex);

	  asm65(#9'lda :STACKORIGIN,x');
	  asm65(#9'sta :bp2');
	  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
	  asm65(#9'sta :bp2+1');

	  j := RecordSize(GetIdent(Types[Ident[IdentIndex].Param[NumActualParams].Numallocelements].Field[0].Name ) );

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
         if not (Ident[IdentIndex].Param[NumActualParams].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

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

	  j := j * DataSize[Ident[IdentIndex].Param[NumActualParams].AllocElementType];

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

     //until Tok[i + 1].Kind <> COMMATOK;

     i := Param[1].i_;

     CheckTok(i + 1, CPARTOK);

     inc(i);
     end;// if Tok[i + 1].Kind = OPARTOR


   NumActualParams := ParamIndex;


 //writeln(Ident[IdentIndex].name,',',NumActualParams,',',Ident[IdentIndex].isUnresolvedForward ,',',Ident[IdentIndex].isRecursion );


   if Pass = CALLDETERMPASS then											// issue #103 fixed
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

 for ParamIndex := 1 to NumActualParams do begin

  ActualParamType := Ident[IdentIndex].Param[ParamIndex].DataType;
  if ActualParamType = ENUMTOK then ActualParamType := Ident[IdentIndex].Param[ParamIndex].AllocElementType;

  if Ident[IdentIndex].Param[ParamIndex].PassMethod = VARPASSING then begin

					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);
					asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name + '+1');

					a65(__subBX);
  end else
  if (NumActualParams = 1) and (DataSize[ActualParamType] = 1) then begin			// only ONE parameter SIZE = 1

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
  case ActualParamType of

   BYTETOK, CHARTOK, BOOLEANTOK, SHORTINTTOK:
   				     begin
					asm65(#9'lda :STACKORIGIN,x');
					asm65(#9'sta ' + svar + '.' + Ident[IdentIndex].Param[ParamIndex].Name);

					a65(__subBX);
				     end;

   WORDTOK, SMALLINTTOK, SHORTREALTOK, HALFSINGLETOK, POINTERTOK, STRINGPOINTERTOK, PCHARTOK:
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
   Error(i, 'Unassigned: ' + IntToStr(ActualParamType) );
  end;

 end;


  old_func:=run_func;
  run_func:=0;

  if (Ident[IdentIndex].isStdCall = false) then
						if Ident[IdentIndex].Kind = FUNCTIONTOK then
	  						StartOptimization(i)
						else
	  						StopOptimization;
  run_func:=old_func;


 end;

 Gen;


(*------------------------------------------------------------------------------------------------------------*)

   if Ident[IdentIndex].ObjectIndex > 0 then begin

    if Tok[old_i].Kind <> IDENTTOK then
      iError(old_i, IdentifierExpected)
    else
      IdentTemp := GetIdent(copy(Tok[old_i].Name^, 1, pos('.', Tok[old_i].Name^)-1 ));

     asm65(#9'lda ' + GetLocalName(IdentTemp));
     asm65(#9'ldy ' + GetLocalName(IdentTemp) + '+1');
   end;

(*------------------------------------------------------------------------------------------------------------*)


 if Ident[IdentIndex].isInline then begin

// if pass = CODEGENERATIONPASS then
//    writeln(svar,',', Ident[IdentIndex].ProcAsBlock,',', BlockStack[BlockStackTop], ',' ,Ident[IdentIndex].Block ,',', Ident[IdentIndex].UnitIndex );

//  asm65(#9'.LOCAL ' + svar);


  if (Ident[IdentIndex].Block > 1) and (Ident[IdentIndex].Block <> BlockStack[BlockStackTop]) then	// issue #102 fixed
    for IdentTemp := NumIdent downto 1  do
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

//writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].Kind,',',Ident[IdentIndex].isStdCall,',',Ident[IdentIndex].isRecursion);

	if (Ident[IdentIndex].Kind = FUNCTIONTOK) and (Ident[IdentIndex].isStdCall = false) and (Ident[IdentIndex].isRecursion = false) then begin

		  asm65(#9'inx');

		  ActualParamType := Ident[IdentIndex].DataType;
		  if ActualParamType = ENUMTOK then ActualParamType := Ident[IdentIndex].AllocElementType;

		  case DataSize[ActualParamType] of

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


function CompileFactor(i: Integer; out isZero: Boolean; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var IdentTemp, IdentIndex, oldCodeSize, j: Integer;
    ActualParamType, AllocElementType, Kind, oldPass: Byte;
    IndirectionLevel: TIndirectionLevel;
    yes: Boolean;
    Value, ConstVal: Int64;
    svar, lab: string;
    Param: TParamList;
    ftmp: TFloat;
    fl: single;
begin

 isZero:=false;

 Result := i;

 ftmp:=Default(TFloat);

 ValType := 0;
 ConstVal := 0;
 IdentIndex := 0;

 fl:=0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 HIGHTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      if Tok[i + 2].Kind in AllTypes {+ [STRINGTOK]} then begin

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

       if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then
	Value := Ident[IdentIndex].NumAllocElements_ - 1
       else
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


      if Tok[i + 2].Kind = CHARLITERALTOK then begin

	Push(1, ASVALUE, 1);

	ValType := BYTETOK;

	inc(i, 2);

      end else
      if Tok[i + 2].Kind = STRINGLITERALTOK then begin

	Push(Tok[i + 2].StrLength, ASVALUE, 1);

	ValType := BYTETOK;

	inc(i, 2);

      end else

      if Tok[i + 2].Kind = IDENTTOK then begin

	IdentIndex := GetIdent(Tok[i + 2].Name^);

	if IdentIndex = 0 then
	 iError(i + 2, UnknownIdentifier);

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].AllocElementType );


	if Ident[IdentIndex].Kind in [VARIABLE, CONSTANT] then begin


	  if Ident[IdentIndex].DataType = CHARTOK then begin					// length(CHAR) = 1

	    Push(1, ASVALUE, 1);

	    ValType := BYTETOK;

	  end else

	  if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

  	    i := CompileArrayIndex(i + 2, IdentIndex, ValType);						// array[ ].field

	    CheckTok(i + 2, DOTTOK);
	    CheckTok(i + 3, IDENTTOK);

	    IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

	    if IdentTemp < 0 then
	      Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

//	     ValType := Ident[GetIdent(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name^)].AllocElementType;


	     if (IdentTemp shr 16) = CHARTOK then begin

	       a65(__subBX);

	       Push(1 , ASVALUE, 1);

	     end else begin

              if (IdentTemp shr 16) <> STRINGPOINTERTOK then iError(i + 1, TypeMismatch);

	      Push(0, ASVALUE, 1);

	      Push(1, ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN, 1, IdentIndex, IdentTemp and $ffff);

 	     end;

	     ValType:=BYTETOK;

	     inc(i);

	  end else

	  if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0)) then begin

	   if ((Ident[IdentIndex].DataType = STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = CHARTOK)) or
	      ((Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK)) then begin

		if Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK then begin		// length(array[x])

		i:=CompileArrayIndex(i + 2, IdentIndex, ValType);

		a65(__addBX);

		svar := GetLocalName(IdentIndex);

		if (Ident[IdentIndex].NumAllocElements * 2 > 256) or (Ident[IdentIndex].NumAllocElements in [0,1]) or (Ident[IdentIndex].PassMethod = VARPASSING) then begin

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

		 svar := GetLocalName(IdentIndex);

	  	 if TestName(IdentIndex, svar) then begin

		  lab := ExtractName(IdentIndex, svar);

		  if Ident[GetIdent(lab)].AllocElementType = RECORDTOK then begin
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
		 a65(__addBX);

		 asm65(#9'lda ' + GetLocalName(IdentIndex, 'adr.'));
		 asm65(#9'sta :STACKORIGIN,x');

		end;

		ValType := BYTETOK;

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
	   iError(i + 2, TypeMismatch);

	end else
	 iError(i + 2, IdentifierExpected);

	inc(i, 2);
      end else
       iError(i + 2, IdentifierExpected);

    CheckTok(i + 1, CPARTOK);

    Result := i + 1;
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
	 SHORTINTTOK, BYTETOK: asm65(#9'jsr @hiBYTE');
	 SMALLINTTOK, WORDTOK: asm65(#9'jsr @hiWORD');
      INTEGERTOK, CARDINALTOK: asm65(#9'jsr @hiCARD');
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

      HALFSINGLETOK:
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

          SINGLETOK:
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


  FRACTOK:
    begin

     CheckTok(i + 1, OPARTOK);

     i := CompileExpression(i + 2, ActualParamType);

     if not (ActualParamType in RealTypes) then
       iError(i + 2, IncompatibleTypes, 0, ActualParamType, REALTOK);

     CheckTok(i + 1, CPARTOK);

     case ActualParamType of

       SHORTREALTOK: asm65(#9'jsr @SHORTREAL_FRAC');

            REALTOK:
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

      HALFSINGLETOK:
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

          SINGLETOK:
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

       SHORTREALTOK:
       		begin
		      //asm65(#9'jsr @SHORTREAL_TRUNC');

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @SHORTREAL_TRUNC.A');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @SHORTREAL_TRUNC.A+1');

			asm65(#9'jsr @SHORTREAL_TRUNC');

			asm65(#9'lda :eax');
			asm65(#9'sta :STACKORIGIN,x');

		        ValType := SHORTINTTOK;
		end;

            REALTOK:
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

      HALFSINGLETOK:
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

          SINGLETOK:
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

	SHORTREALTOK:
		begin

		  asm65(#9'jsr @SHORTREAL_ROUND');

		  ValType := SHORTINTTOK;

		end;

        REALTOK:
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

	HALFSINGLETOK:
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

        SINGLETOK:
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

      Push(1, ASVALUE, DataSize[ValType]);

      if Kind = PREDTOK then
       GenerateBinaryOperation(MINUSTOK, ValType)
      else
       GenerateBinaryOperation(PLUSTOK, ValType);

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

}
    Result := i;
    end;


  IDENTTOK:
    begin
    IdentIndex := GetIdent(Tok[i].Name^);

    if IdentIndex > 0 then
	  if (Ident[IdentIndex].Kind = USERTYPE) and (Tok[i + 1].Kind = OPARTOK) then begin

//		CheckTok(i + 1, OPARTOK);

		if (Ident[IdentIndex].DataType = POINTERTOK) and (Elements(IdentIndex) > 0) then begin

		 i := CompileAddress(i+1, VarType, ValType);

		 CheckTok(i + 1, CPARTOK);
		 CheckTok(i + 2, OBRACKETTOK);

		 i := CompileArrayIndex(i+1, IdentIndex, AllocElementType);

	         asm65(#9'lda :STACKORIGIN-1,x');
		 asm65(#9'add :STACKORIGIN,x');
		 asm65(#9'sta :STACKORIGIN-1,x');
	    	 asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	    	 asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	    	 asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

		 asm65(#9'dex');

    		 asm65(#9'lda :STACKORIGIN,x');
    		 asm65(#9'sta :bp2');
    		 asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
    		 asm65(#9'sta :bp2+1');
		 asm65(#9'ldy #$00');
// perl
//		 writeln( DataSize[Ident[IdentIndex].AllocElementType],',', Ident[IdentIndex].AllocElementType );

	 	 case DataSize[Ident[IdentIndex].AllocElementType] of
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

		 exit(i+1);
		end;


		j := CompileExpression(i + 2, ValType);


		if not(ValType in AllTypes) then
		  iError(i, TypeMismatch);


		if (ValType = POINTERTOK) and not (Ident[IdentIndex].DataType in [POINTERTOK, RECORDTOK, OBJECTTOK]) then begin
		 ValType := Ident[IdentIndex].DataType;

		 if (Tok[i + 4].Kind = DEREFERENCETOK) then exit(j + 2);
		end;


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

				ValType := HALFSINGLETOK;
			end;


			SINGLETOK:
			begin
				ExpandParam(INTEGERTOK, ValType);

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

		 yes:=false;

		 if (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK]) and (Tok[j].Kind = DEREFERENCETOK) then yes:=true;
		 if (Ident[IdentIndex].DataType = POINTERTOK) and (Tok[j + 2].Kind = DEREFERENCETOK) then yes:=true;

//		 yes := (Tok[j + 2].Kind = DEREFERENCETOK);


//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Tok[j ].Kind,',',Tok[j + 1].Kind,',',Tok[j + 2].Kind);

 	     	 if (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) or (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK]) then begin


	       	  if Tok[j + 2].Kind = DEREFERENCETOK then inc(j);


		  if Tok[j+2].Kind <> DOTTOK then yes := false else

		   if Tok[j+2].Kind = DOTTOK then begin					// (pointer).field :=

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

//	if Ident[IdentTemp].IsNestedFunction = FALSE then
//	 Error(i, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found');


	if Tok[i + 1].Kind = OBRACKETTOK then begin
	  i := CompileArrayIndex(i, IdentIndex, ValType);

          CheckTok(i + 1, CBRACKETTOK);

          inc(i);
	end;


	if Tok[i + 1].Kind = OPARTOK then

	  CompileActualParameters(i, IdentTemp, IdentIndex)

	else begin

	  if Ident[IdentIndex].NumAllocElements > 0 then
	    Push(0, ASPOINTERTOARRAYORIGIN2, DataSize[POINTERTOK], IdentIndex)
	  else
	    Push(0, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

	end;

 	ValType := POINTERTOK;

	Result := i;


      end else

      if Ident[IdentIndex].Kind = PROCEDURETOK then
	Error(i, 'Variable, constant or function name expected but procedure ' + Ident[IdentIndex].Name + ' found')
      else if Ident[IdentIndex].Kind = FUNCTIONTOK then       // Function call
	begin

	  Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc( Ident[IdentIndex].Name, IdentIndex, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then begin

	      if Ident[IdentIndex].NumParams <> j then
		iError(i, WrongNumParameters, IdentIndex);

	      iError(i, CantDetermine, IdentIndex)
	     end else
              iError(i, WrongNumParameters, IdentIndex);

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

	if (Tok[i + 1].Kind = DEREFERENCETOK) then
	  if (Ident[IdentIndex].Kind <> VARIABLE) or not (Ident[IdentIndex].DataType in Pointers) then
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin

	    if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	      ValType := STRINGPOINTERTOK
	    else
 	      ValType :=  Ident[IdentIndex].AllocElementType;


	    if (ValType = UNTYPETOK) and (Ident[IdentIndex].DataType = POINTERTOK) then begin

	     ValType := POINTERTOK;

	     Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[ValType], IdentIndex);

	    end else
	    if (ValType in [RECORDTOK, OBJECTTOK]) then begin						// record^.


	     if (Tok[i + 2].Kind = DOTTOK) then begin

//	writeln(Ident[IdentIndex].Name,',',Tok[i + 3].Name^,' | ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements);

	      CheckTok(i + 3, IDENTTOK);
	      IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

 	      if IdentTemp < 0 then
	       Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	      ValType := IdentTemp shr 16;

	      inc(i, 2);


	      if (Tok[i + 1].Kind = IDENTTOK) and (Tok[i + 2].Kind = OBRACKETTOK) then begin		// record^.label[x]

	       inc(i);

	       i := CompileArrayIndex(i, GetIdent(Ident[IdentIndex].Name + '.' + Tok[i].Name^), ValType);

	       Push(Ident[IdentIndex].Value, ASPOINTERTORECORDARRAYORIGIN, DataSize[ValType], IdentIndex, IdentTemp and $ffff);

	      end else

	      if ValType = STRINGPOINTERTOK then
	        Push(Ident[IdentIndex].Value, ASPOINTERTORECORD, DataSize[ValType], IdentIndex, IdentTemp and $ffff)	// record^.string
	      else
	        Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex, IdentTemp and $ffff);	// record_lebel.field^

	     end else
	     // fake code, do nothing ;)
	      Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[ValType], IdentIndex);			// record_label^

	    end else
	     if Ident[IdentIndex].DataType = STRINGPOINTERTOK then
	       Push(Ident[IdentIndex].Value, ASPOINTER, DataSize[ValType], IdentIndex)
	     else
	       Push(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex);

// LUCI
	    Result := i + 1;
	    end
	else

// -----------------------------------------------------------------------------
// ===				 array [index].
// -----------------------------------------------------------------------------

	if Tok[i + 1].Kind = OBRACKETTOK then			// Array element access
	  if not (Ident[IdentIndex].DataType in Pointers) {or ((Ident[IdentIndex].NumAllocElements = 0) and (Ident[IdentIndex].idType <> PCHARTOK))} then  // PByte, PWord
	    iError(i, IncompatibleTypeOf, IdentIndex)
	  else
	    begin

//writeln('> ',Ident[IdentIndex].Name,',',ValType,',',Ident[GetIdent(Tok[i].Name^)].name);
// perl
  	    i := CompileArrayIndex(i, IdentIndex, ValType);							// array[ ].field

 	    if ValType = ARRAYTOK then begin

	        ValType := POINTERTOK ;

		Push(0, ASPOINTER, DataSize[ValType], IdentIndex, 0);

	    end else

	    if Tok[i + 2].Kind = DEREFERENCETOK then begin

//	writeln(valType,' / ',Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_);

	     Push(0, ASPOINTERTORECORDARRAYORIGIN, DataSize[ValType], IdentIndex, 0);

	     inc(i);
	    end else

            if (Tok[i + 2].Kind = DOTTOK) and (ValType in [RECORDTOK, OBJECTTOK]) then begin

//	writeln(valType,' / ',Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Tok[i + 3].Kind );

	     CheckTok(i + 1, CBRACKETTOK);

	     CheckTok(i + 3, IDENTTOK);
	     IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

	     if IdentTemp < 0 then
	      Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');

	     ValType := IdentTemp shr 16;

	     inc(i, 2);


	     if (Tok[i + 1].Kind = IDENTTOK) and (Tok[i + 2].Kind = OBRACKETTOK) then begin		// array_of_record_pointers[x].array[i]

	       inc(i);

	       ValType := Ident[GetIdent(Ident[IdentIndex].Name + '.' + Tok[i].Name^)].AllocElementType;

 	       IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

	      if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

//	writeln(ValType,',',Ident[IdentIndex].Name + '||' + Tok[i].Name^,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_ );

	       IdentTemp := RecordSize(IdentIndex, Tok[i].Name^);

	       if IdentTemp < 0 then
	        Error(i, 'identifier idents no member '''+Tok[i].Name^+'''');

	       ValType := Ident[GetIdent(Ident[IdentIndex].Name + '.' + Tok[i].Name^)].AllocElementType;

	       IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

	      end;


	       i := CompileArrayIndex(i, GetIdent(Ident[IdentIndex].Name + '.' + Tok[i].Name^), AllocElementType);

	       Push(Ident[IdentIndex].Value, IndirectionLevel, DataSize[ValType], IdentIndex, IdentTemp and $ffff);

	     end else

	     if ValType = STRINGPOINTERTOK then 							// array_of_record_pointers[index].string
 	       Push(0, ASPOINTERTOARRAYRECORDTOSTRING, DataSize[ValType], IdentIndex, IdentTemp and $ffff)
	     else
 	       Push(0, ASPOINTERTOARRAYRECORD, DataSize[ValType], IdentIndex, IdentTemp and $ffff);


	    end else
	    if (Tok[i + 2].Kind = OBRACKETTOK) and (ValType = STRINGPOINTERTOK) then begin

	     Error(i, '-- under construction --');
{
	     ValType := CHARTOK;
	     inc(i, 3);

	     Push(2, ASVALUE, 2);

	     GenerateBinaryOperation(PLUSTOK, WORDTOK);
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

	      IdentTemp := GetIdent( copy(Ident[IdentIndex].Name, 1, pos('.', Ident[IdentIndex].Name)-1) );

	      if (Ident[IdentTemp].DataType = POINTERTOK) and (Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

	       svar := copy(Ident[IdentIndex].Name, pos('.', Ident[IdentIndex].Name)+1, length(Ident[IdentIndex].Name));

	       IdentIndex := IdentTemp;

	       IdentTemp := RecordSize(IdentIndex, svar);

	       if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member ''' + svar + '''');

	       IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

//	       Push(Ident[IdentIndex].Value, ASPOINTERTORECORDARRAYORIGIN, DataSize[ValType], IdentIndex, IdentTemp and $ffff);

	      end;

	    end;


	    if ValType in [RECORDTOK, OBJECTTOK] then ValType := POINTERTOK;

	    Push(Ident[IdentIndex].Value, IndirectionLevel, DataSize[ValType], IdentIndex, IdentTemp and $ffff);

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

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].idType,'/',Ident[IdentIndex].Kind,' = ',Ident[IdentIndex].PassMethod ,' | ',ValType,',',Tok[j].kind,',',Tok[j+1].kind);

	   ValType := Ident[IdentIndex].AllocElementType;

	   if (ValType = CHARTOK) then

	    case Ident[IdentIndex].DataType of
	            POINTERTOK : ValType := PCHARTOK;
	      STRINGPOINTERTOK : ValType := STRINGPOINTERTOK;
	    end;


	   if ValType = UNTYPETOK then ValType := Ident[IdentIndex].DataType;	// RECORD.

	  end else
	   ValType := Ident[IdentIndex].DataType;


// LUCI
//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].idType,'/',Ident[IdentIndex].Kind,' = ',Ident[IdentIndex].PassMethod ,' | ',ValType,',',Tok[j].kind,',',Tok[j+1].kind);


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
	  {if Ident[IdentIndex].IdType = DEREFERENCETOK then		// !!! test-record\record_dereference_as_val.pas !!!
	   Push(ConstVal, ASVALUE, DataSize[ValType], IdentIndex)
	  else}
	   Push(ConstVal, TIndirectionLevel(Ord(Ident[IdentIndex].Kind = VARIABLE)), DataSize[ValType], IdentIndex);


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

end;	//CompileFactor


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure ResizeType(var ValType: Byte);
// dla operacji SHL, MUL rozszerzamy typ dla wyniku operacji
begin

  if ValType in [BYTETOK, WORDTOK, SHORTINTTOK, SMALLINTTOK] then inc(ValType);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure RealTypeConversion(var ValType, RightValType: Byte; Kind: Byte = 0);
begin

  If ((ValType = SINGLETOK) or (Kind = SINGLETOK)) and (RightValType in IntegerTypes) then begin

   ExpandParam(INTEGERTOK, RightValType);

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

   if (ValType <> SINGLETOK) and (Kind = SINGLETOK) then
    RightValType := Kind
   else
    RightValType := ValType;
  end;


  If (ValType in IntegerTypes) and ((RightValType = SINGLETOK) or (Kind = SINGLETOK)) then begin

   ExpandParam_m1(INTEGERTOK, ValType);

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

end;	//RealTypeConversion


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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
end;	//CompileTerm


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileSimpleExpression(i: Integer; out ValType: Byte; VarType: Byte): Integer;
var
  j, k: Integer;
  ConstVal: Int64;
  RightValType: Byte;
  ftmp: TFloat;
  fl: single;
begin

ftmp:=Default(TFloat);
fl:=0;

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


  if (ValType = POINTERTOK) and (RightValType in IntegerTypes) then begin ExpandParam(WORDTOK, RightValType); RightValType := POINTERTOK end;
  if (RightValType = POINTERTOK) and (ValType in IntegerTypes) then begin ExpandParam_m1(WORDTOK, ValType); ValType := POINTERTOK end;


  ValType := GetCommonType(j + 1, ValType, RightValType);

  CheckOperator(i, Tok[j + 1].Kind, ValType, RightValType);


  if Tok[j + 1].Kind in [PLUSTOK, MINUSTOK] then begin				// dla PLUSTOK, MINUSTOK rozszerz typ wyniku

    if (Tok[j + 1].Kind = MINUSTOK) and (RightValType in UnsignedOrdinalTypes) and (VarType in SignedOrdinalTypes + [BOOLEANTOK, REALTOK, HALFSINGLETOK, SINGLETOK]) then begin

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


  GenerateBinaryOperation(Tok[j + 1].Kind, ValType);

  j := k;
  end;

Result := j;
end;	//CompileSimpleExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileExpression(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
var
  j, k: Integer;
  RightValType, ConstValType, isZero: Byte;
  cRight, yes: Boolean;
  sLeft, sRight: WordBool;
  ConstVal, ConstValRight: Int64;
  ftmp: TFloat;
begin

 ftmp:=Default(TFloat);

 ConstVal:=0;

 isZero := INTEGERTOK;

 cRight:=false;		// constantRight

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

sLeft:=false;		// stringLeft
sRight:=false;		// stringRight


i := CompileSimpleExpression(i, ValType, VarType);


if (Tok[i].Kind = STRINGLITERALTOK) or (ValType = STRINGPOINTERTOK) then sLeft:=WordBool(1) else
 if (ValType in Pointers) and (Tok[i].Kind = IDENTTOK) then
  if (Ident[GetIdent(Tok[i].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i].Name^)) in [1..255]) then sLeft:=WordBool(1 or Elements(GetIdent(Tok[i].Name^)) shl 8);


if Tok[i + 1].Kind = INTOK then writeln('IN');				// not yet programmed


if Tok[i + 1].Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
  begin


  if ValType in RealTypes then VarType := ValType;


  j := CompileSimpleExpression(i + 2, RightValType, VarType);


  k := i + 2;
  if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
   if (ConstValType in IntegerTypes) and (VarType in IntegerTypes + [BOOLEANTOK]) then begin

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



  if (Tok[i + 2].Kind = STRINGLITERALTOK) or (RightValType = STRINGPOINTERTOK) then sRight:=WordBool(1) else
   if (RightValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) then
    if (Ident[GetIdent(Tok[i + 2].Name^)].AllocElementType = CHARTOK) and (Elements(GetIdent(Tok[i + 2].Name^)) in [1..255]) then sRight:=WordBool(1 or Elements(GetIdent(Tok[i + 2].Name^)) shl 8);


//  if (ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [SHORTREALTOK, REALTOK]) then
//    RightValType := ValType;

  if VarType in RealTypes then begin
   if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
   if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
  end;

  RealTypeConversion(ValType, RightValType);//, VarType);

//  writeln(VarType,  ' | ', ValType,'/',RightValType,',',isZero,',',Tok[i + 1].Kind ,' : ', ConstVal);


  if cRight and (Tok[i + 1].Kind in [LTTOK, GTTOK]) and (ValType in IntegerTypes) then begin

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

   if (ValType in [CHARTOK, STRINGPOINTERTOK, POINTERTOK]) and (RightValType in [CHARTOK, STRINGPOINTERTOK, POINTERTOK]) then
    GenerateRelationString(Tok[i + 1].Kind, ValType, RightValType, sLeft, sRight)
   else
    GetCommonType(j, ValType, RightValType);

  end else
   GenerateRelation(Tok[i + 1].Kind, ValType);

  i := j;

  ValType:=BOOLEANTOK;
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

 if Ident[IdentIndex].PassMethod = CONSTPASSING then
   Error(i, 'Can''t assign values to const variable');

 if Ident[IdentIndex].LoopVariable then
   Error(i, 'Illegal assignment to for-loop variable '''+Ident[IdentIndex].Name+'''');

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileStatement(i: Integer; isAsm: Boolean = false): Integer;
var
  j, k, IdentIndex, IdentTemp, NumActualParams, NumCharacters,
  IfLocalCnt, CaseLocalCnt, NumCaseStatements, vlen, oldPass, oldCodeSize: integer;
  Param: TParamList;
  ExpressionType, ActualParamType, ConstValType, VarType, SelectorType: Byte;
  IndirectionLevel: TIndirectionLevel;
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

    if (IdentIndex > 0) and (Ident[IdentIndex].Kind = FUNCTIONTOK) and (BlockStackTop > 1) and (Tok[i + 1].Kind <> OPARTOK) then
     for j:=NumIdent downto 1 do
      if (Ident[j].ProcAsBlock = NumBlocks) and (Ident[j].Kind = FUNCTIONTOK) then begin
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



           if Ident[IdentIndex].IdType = DATAORIGINOFFSET then begin

	     IdentTemp:=GetIdent( ExtractName(IdentIndex, Ident[IdentIndex].Name) );

	     if (Ident[IdentTemp].NumAllocElements_ > 0) and (Ident[IdentTemp].DataType = POINTERTOK) and (Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK]) then
	       iError(i, IllegalQualifier);

//	     writeln(Ident[IdentTemp].name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements_);

	   end;



           IndirectionLevel := ASPOINTERTOPOINTER;


	   if (Ident[IdentIndex].Kind = TYPETOK) and (Tok[i + 1].Kind <> OPARTOK) then iError(i + 1, VariableExpected);


	   if (Tok[i + 1].Kind = OPARTOK) and (Ident[IdentIndex].DataType = POINTERTOK) and (Elements(IdentIndex) > 0) then begin

//	writeln('= ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements);

            IndirectionLevel := ASPOINTERTODEREFERENCE;

	    j := i;

	    i := CompileAddress(i + 1, ExpressionType, VarType);


//	    writeln(ExpressionType,',',VarTYpe,',',Elements(GetIdent(Tok[j + 2].Name^)));

	    if DataSize[VarType] <> Elements(IdentIndex) * DataSize[Ident[IdentIndex].AllocElementType] then
	     if VarType =  UNTYPETOK then
               Error(j + 2, 'Illegal type conversion: "POINTER" to "Array[0..' + IntToStr(Elements(IdentIndex) - 1) + '] Of ' + InfoAboutToken(Ident[IdentIndex].AllocElementType) + '"')
	     else
	      if Elements(GetIdent(Tok[j + 2].Name^)) = 0 then
                Error(j + 2, 'Illegal type conversion: "' + InfoAboutToken(VarType) + '" to "' + Ident[IdentIndex].Name + '"')
              else
                Error(j + 2, 'Illegal type conversion: "Array[0..' + IntToStr(Elements(GetIdent(Tok[j + 2].Name^)) - 1) + '] Of ' + InfoAboutToken(VarType) + '" to "' + Ident[IdentIndex].Name + '"');

// perl
            CheckTok(i + 1, CPARTOK);

	    inc(i);

	    CheckTok(i + 1, OBRACKETTOK);

	    i := CompileArrayIndex(i, IdentIndex, VarType);

	    CheckTok(i + 1, CBRACKETTOK);

	    inc(i);

	    asm65(#9'lda :STACKORIGIN-1,x');
	    asm65(#9'add :STACKORIGIN,x');
	    asm65(#9'sta :STACKORIGIN-1,x');
	    asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
	    asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
	    asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

	    asm65(#9'dex');

	   end else

           if Tok[i + 1].Kind = OPARTOK then begin				// (pointer)

//	writeln('= ',Ident[IdentIndex].Name,',',Ident[IdentIndex].Kind,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType);

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

	      CheckTok(i + 3, IDENTTOK);
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

	       CheckTok(i + 3, IDENTTOK);
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

	       CheckTok(i + 3, IDENTTOK);
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

	    if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) then
	      VarType := STRINGPOINTERTOK
	    else
 	      VarType := Ident[IdentIndex].AllocElementType;

	    IndirectionLevel := ASPOINTERTOPOINTER;


//	writeln('= ',Ident[IdentIndex].name,',',VarTYpe,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].PassMethod);


	    if Tok[i + 2].Kind = OBRACKETTOK then begin				// pp^[index] :=

	     inc(i);

	     if not (Ident[IdentIndex].DataType in Pointers) then
	       iError(i + 1, IncompatibleTypeOf, IdentIndex);

	     IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

	     i := CompileArrayIndex(i, IdentIndex, VarType);

	     CheckTok(i + 1, CBRACKETTOK);

	    end else

	    if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin

	     CheckTok(i + 3, IDENTTOK);
	     IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

	     if IdentTemp < 0 then
	      Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');


	    if Tok[i + 4].Kind = OBRACKETTOK then begin				// pp^.field[index] :=

	     if not (Ident[IdentIndex].DataType in Pointers) then
	       iError(i + 2, IncompatibleTypeOf, IdentIndex);

	     par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	     IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

	     i := CompileArrayIndex(i + 3, GetIdent(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name^), VarType);

	     CheckTok(i + 1, CBRACKETTOK);

	    end else begin							// pp^.field :=

	     VarType := IdentTemp shr 16;
	     par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	     if GetIdent(Ident[IdentIndex].name+'.'+Tok[i + 3].Name^) > 0 then IdentIndex := GetIdent(Ident[IdentIndex].name+'.'+Tok[i + 3].Name^);

	     inc(i, 2);

	    end;

	    end;

	    i := i + 1;
	    end
	  else if (Tok[i + 1].Kind = OBRACKETTOK) then				// With indexing
	    begin

	    if not (Ident[IdentIndex].DataType in Pointers) then
	      iError(i + 1, IncompatibleTypeOf, IdentIndex);

	    IndirectionLevel :=  ASPOINTERTOARRAYORIGIN2;

	    j := i;

	    i := CompileArrayIndex(i, IdentIndex, VarType);

	    if VarType = ARRAYTOK then begin IndirectionLevel:=ASPOINTER; VarType := POINTERTOK end;


	    if Tok[i + 2].Kind = DEREFERENCETOK then begin
	     inc(i);

	     Push(0, ASPOINTERTOARRAYORIGIN2, DataSize[VarType], IdentIndex, 0);

	    end;

										// label.field[index] -> label + field[index]

	    if pos('.', Ident[IdentIndex].Name) > 0 then begin			// record_ptr.field[index] :=

	      IdentTemp := GetIdent( copy(Ident[IdentIndex].Name, 1, pos('.', Ident[IdentIndex].Name)-1) );

	      if (Ident[IdentTemp].DataType = POINTERTOK) and (Ident[IdentTemp].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin
	       IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

	       par2 := copy(Ident[IdentIndex].Name, pos('.', Ident[IdentIndex].Name)+1, length(Ident[IdentIndex].Name));

	       IdentIndex := IdentTemp;

	       IdentTemp := RecordSize(IdentIndex, par2);

	       if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member ''' + par2 + '''');

	       par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	      end;

	    end;


//	    writeln(Ident[IdentIndex].Name,',',vartype,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].Kind);//+ '.' + Tok[i + 3].Name^);

	    if (VarType in [RECORDTOK, OBJECTTOK]) and (Tok[i + 2].Kind = DOTTOK) then begin
	       IndirectionLevel := ASPOINTERTOARRAYRECORD;

	       CheckTok(i + 3, IDENTTOK);
	       IdentTemp := RecordSize(IdentIndex, Tok[i + 3].Name^);

	       if IdentTemp < 0 then
	        Error(i + 3, 'identifier idents no member '''+Tok[i + 3].Name^+'''');


//	       writeln('>',Ident[IdentIndex].Name+ '||' + Tok[i + 3].Name^,',',IdentTemp shr 16,',',VarType,'||',Tok[i+4].Kind,',',ident[GetIdent(Ident[IdentIndex].Name+ '.' + Tok[i + 3].Name^)].AllocElementTYpe);


	      if Tok[i + 4].Kind = OBRACKETTOK then begin				// array_to_record_pointers[x].field[index] :=

	        if not (Ident[IdentIndex].DataType in Pointers) then
	          iError(i + 2, IncompatibleTypeOf, IdentIndex);

	        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

	        IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

	        i := CompileArrayIndex(i + 3, GetIdent(Ident[IdentIndex].Name + '.' + Tok[i + 3].Name^), VarType);

	        CheckTok(i + 1, CBRACKETTOK);

	      end else begin								// array_to_record_pointers[x].field :=
//-------
	        VarType := IdentTemp shr 16;
	        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

 	        if GetIdent(Ident[IdentIndex].name+'.'+Tok[i + 3].Name^) > 0 then IdentIndex := GetIdent(Ident[IdentIndex].name+'.'+Tok[i + 3].Name^);

		if VarType = STRINGPOINTERTOK then IndirectionLevel := ASPOINTERTOARRAYRECORDTOSTRING;

	        inc(i, 2);

	      end;


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

//	writeln('= ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', VarType,',',IndirectionLevel);

	    end;


	   if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = PROCVARTOK) and (Tok[i + 1].Kind <> ASSIGNTOK) then begin

	        IdentTemp := GetIdent('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		CompileActualParameters(i, IdentTemp, IdentIndex);

		if Ident[IdentTemp].Kind = FUNCTIONTOK then a65(__subBX);

		Result := i;
		exit;

	   end else
	    CheckTok(i + 1, ASSIGNTOK);


//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',IndirectionLevel);


	    if (Ident[IdentIndex].DataType = PCHARTOK) and
//	       ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (Ident[IdentIndex].PassMethod = VARPASSING)) ) and
	       (IndirectionLevel = ASPOINTER) and
	       (Tok[i + 2].Kind in [STRINGLITERALTOK, CHARLITERALTOK, IDENTTOK]) then
	      begin


{$i include/compile_pchar.inc}


	      end else

	    if (Ident[IdentIndex].DataType in Pointers) and
	       (Ident[IdentIndex].AllocElementType = CHARTOK) and
	       (Ident[IdentIndex].NumAllocElements > 0) and
	       ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (Ident[IdentIndex].PassMethod = VARPASSING)) ) and
	       (Tok[i + 2].Kind in [STRINGLITERALTOK, CHARLITERALTOK, IDENTTOK]) then
	      begin


{$i include/compile_string.inc}


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


	      if (VarType = POINTERTOK) and (ExpressionType = STRINGPOINTERTOK) then begin

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


 	      if (Tok[i].Kind = DEREFERENCETOK) and (VarType = POINTERTOK) and (ExpressionType = RECORDTOK) then begin

	         ExpressionType := RECORDTOK;
	         VarType := RECORDTOK;

	      end;


//	if (Tok[k].Kind = IDENTTOK) then
//	  writeln(Ident[IdentIndex].Name,'/',Tok[k].Name^,',', VarType,':', ExpressionType,' - ', Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' | ',Ident[GetIdent(Tok[k].Name^)].DataType,':',Ident[GetIdent(Tok[k].Name^)].AllocElementType,':',Ident[GetIdent(Tok[k].Name^)].NumAllocElements ,' / ',IndirectionLevel)
//	else
//	  writeln(Ident[IdentIndex].Name,',', VarType,',', ExpressionType,' - ', Ident[IdentIndex].DataType,':',Ident[IdentIndex].AllocElementType,':',Ident[IdentIndex].NumAllocElements,' / ',IndirectionLevel);


	     if  VarType <> ExpressionType then
	      if (ExpressionType = POINTERTOK) and (Tok[k].Kind = IDENTTOK) then
	       if (Ident[GetIdent(Tok[k].Name^)].DataType = POINTERTOK) and (Ident[GetIdent(Tok[k].Name^)].AllocElementType = PROCVARTOK) then begin

	         IdentTemp := GetIdent('@FN' + IntToHex(Ident[GetIdent(Tok[k].Name^)].NumAllocElements_, 4) );

		 //CompileActualParameters(i, IdentTemp, GetIdent(Tok[k].Name^));

		 if Ident[IdentTemp].Kind = FUNCTIONTOK then ExpressionType := Ident[IdentTemp].DataType;

               end;


	      CheckAssignment(i + 1, IdentIndex);

	      if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) {and not (Ident[IdentIndex].AllocElementType in [PROCEDURETOK, FUNC])} then begin

//	writeln(ExpressionType,' | ',Ident[IdentIndex].idtype,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].Name,',',IndirectionLevel);
//	writeln(Ident[GetIdent(Ident[IdentIndex].Name)].AllocElementType);


	       if (ExpressionType = CHARTOK) and ( Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK) then

		IndirectionLevel := ASSTRINGPOINTER1TOARRAYORIGIN		// tab[ ] := 'a'

	       else
	       if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then begin


		if (Ident[IdentIndex].DataType = POINTERTOK) and (ExpressionType in [RECORDTOK, OBJECTTOK]) then

		else
		  GetCommonType(i + 1, Ident[IdentIndex].DataType, ExpressionType);


	        end else
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

			IdentTemp := GetIdent(Tok[k].Name^);

			case IndirectionLevel of
			           ASPOINTER:
				   if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] ) then
				    Error(k, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');

			  ASPOINTERTOPOINTER:
				   if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) and not ( Ident[IdentTemp].DataType in [RECORDTOK, OBJECTTOK] ) then
				    Error(k, 'Incompatible types: got "' + Types[Ident[IdentTemp].NumAllocElements].Field[0].Name +'" expected "^' + Types[Ident[IdentIndex].NumAllocElements].Field[0].Name + '"');
			else
			  GetCommonType(i + 1, VarType, ExpressionType);

			end;

		    end else begin

//		 writeln('1> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,', P:', Ident[IdentIndex].PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

		      if ((Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) or
		         ((VarType = STRINGPOINTERTOK) and (ExpressionType = PCHARTOK))   	                                           then

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


//	writeln(vartype,',',ExpressionType,',',Ident[IdentIndex].Name);

//     	writeln('0> ',Ident[IdentIndex].Name,',',VarType,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', ExpressionType,',',IndirectionLevel);


	      if (Ident[IdentIndex].PassMethod <> VARPASSING) and (IndirectionLevel <> ASPOINTERTODEREFERENCE) and (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].NumAllocElements = 0) and (ExpressionType <> POINTERTOK) then begin

		if (Ident[IdentIndex].AllocElementType in {IntegerTypes}OrdinalTypes) and (ExpressionType in {IntegerTypes}OrdinalTypes) then

		else
		 if Ident[IdentIndex].AllocElementType <> UNTYPETOK then begin

		  if (ExpressionType in [PCHARTOK, STRINGPOINTERTOK]) and (Ident[IdentIndex].AllocElementType = CHARTOK) then

		  else
		   Error(i + 1, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) + '" expected "' + Ident[IdentIndex].Name + '"');

		 end else
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
  		    GetCommonType(i + 1, VarType, ExpressionType);

		  end;


               if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) and (Ident[IdentIndex].PassMethod = Ident[IdentTemp].PassMethod) then begin

//		   writeln('2> ',Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,' | ', Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType,',',Ident[IdentTemp].NumAllocElements);

  		   if Ident[IdentTemp].Kind = FUNCTIONTOK then
		    yes := Ident[IdentIndex].NumAllocElements <> Ident[GetIdentResult(Ident[IdentTemp].ProcAsBlock)].NumAllocElements
		   else
		    yes := Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements;


		   if yes and (ADDRESS = false) and (ExpressionType in [RECORDTOK, OBJECTTOK]) then
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


		if (Ident[IdentTemp].Kind = FUNCTIONTOK) then begin
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

		if IdentTemp > 0 then

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
		if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = RECORDTOK) and (RecordSize(IdentIndex) <= 8) then begin


		if Ident[IdentIndex].PassMethod = VARPASSING then begin

        	  svar:=GetLocalName(IdentIndex);
		  LoadBP2(IdentIndex, svar);

		  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
  		  asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

		end else
			if RecordSize(IdentIndex) = 1 then
			  asm65(#9' mva ' + Name + ' ' + GetLocalName(IdentIndex, 'adr.'))
			else
			  asm65(#9':' + IntToStr(RecordSize(IdentIndex)) + ' mva ' + Name + '+# ' + GetLocalName(IdentIndex, 'adr.') + '+#');

		end else
		 if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentTemp].DataType = POINTERTOK) then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType ,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].pASSmETHOD);
//	writeln(Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType ,',',Ident[IdentTemp].NumAllocElements,'/',Ident[IdentTemp].NumAllocElements_,',',Ident[IdentTemp].pASSmETHOD);
//	writeln('--- ', IndirectionLevel);

			asm65(#9'@move ' + Name + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(RecordSize(IdentIndex)))

		 end else
		  if (Ident[IdentIndex].DataType = RECORDTOK) and (Ident[IdentTemp].DataType = POINTERTOK) then begin

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType ,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].pASSmETHOD);
//	writeln(Ident[IdentTemp].Name,',',Ident[IdentTemp].DataType,',',Ident[IdentTemp].AllocElementType ,',',Ident[IdentTemp].NumAllocElements,'/',Ident[IdentTemp].NumAllocElements_,',',Ident[IdentTemp].pASSmETHOD);
//	writeln('--- ', IndirectionLevel);


			if Ident[IdentTemp].PassMethod = VARPASSING then begin

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

		  	if Ident[IdentIndex].PassMethod = VARPASSING then begin

        		 svar:=GetLocalName(IdentIndex);
			 LoadBP2(IdentIndex, svar);

			 if RecordSize(IdentIndex) <= 128 then begin

			  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex)-1, 2));
			  asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

			 end else
			  asm65(#9'@move #' + Name + ' ":bp2" #' + IntToStr(RecordSize(IdentIndex)));

			end else

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


     	       end else	   // ExpressionType <> RECORDTOK + OBJECTTOK
		 GetCommonType(i + 1, ExpressionType, RECORDTOK);

	      end else

		if// (Tok[k].Kind = IDENTTOK) and
		   (VarType = STRINGPOINTERTOK) and (ExpressionType in Pointers) {and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK])} then begin


//	writeln(Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType ,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].Name,',',IndirectionLevel,',',vartype,' || ',Ident[GetIdent(Tok[k].Name^)].NumAllocElements,',',Ident[GetIdent(Tok[k].Name^)].PassMethod);

//	writeln(address,',',Tok[k].kind,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].AllocElementType,' / ', VarType,',',ExpressionType,',',IndirectionLevel);


		 if (Tok[k].Kind <> ADDRESSTOK) and (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) and (Ident[IdentIndex].AllocElementType = STRINGPOINTERTOK) then begin

		  if (Tok[k].Kind = IDENTTOK) and (Ident[GetIdent(Tok[k].Name^)].AllocElementType <> UNTYPETOK) then IndirectionLevel := ASSTRINGPOINTERTOARRAYORIGIN;

		  GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex);

		  StopOptimization;

		  ResetOpty;

		 end else
		  GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);


	        end else


// dla PROC, FUNC -> Ident[GetIdent(Tok[k].Name^)].NumAllocElements -> oznacza liczbe parametrow takiej procedury/funkcji

		if (VarType in Pointers) and ( (ExpressionType in Pointers) and (Tok[k].Kind = IDENTTOK) ) and
		   ( not (Ident[IdentIndex].AllocElementType in Pointers + [RECORDTOK, OBJECTTOK]) and not (Ident[GetIdent(Tok[k].Name^)].AllocElementType in Pointers + [RECORDTOK, OBJECTTOK]) ) then
		begin


		j := Elements(IdentIndex) {Ident[IdentIndex].NumAllocElements} * DataSize[Ident[IdentIndex].AllocElementType];

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


	          //if (Ident[IdentIndex].NumAllocElements > 1) and (Ident[IdentTemp].NumAllocElements > 1) then begin
		  if (Elements(IdentIndex) > 1) and (Elements(IdentTemp) > 1) then begin

//writeln(j,',', Elements(IdentTemp) );
// perl
		    if Ident[IdentTemp].AllocElementType <> RECORDTOK then
		     if (j <> integer(Elements(IdentTemp) {Ident[IdentTemp].NumAllocElements} * DataSize[Ident[IdentTemp].AllocElementType])) then
		      if (Ident[IdentIndex].AllocElementType <> Ident[IdentTemp].AllocElementType) or
		         ((Ident[IdentTemp].NumAllocElements <> Ident[IdentIndex].NumAllocElements_) and (Ident[IdentTemp].NumAllocElements_ = 0)) or
		         ((Ident[IdentIndex].NumAllocElements <> Ident[IdentTemp].NumAllocElements_) and (Ident[IdentIndex].NumAllocElements_ = 0)) then
		           iError(i, IncompatibleTypesArray, IdentTemp, -IdentIndex);

{
	   	    a65(__subBX);
		    StopOptimization;

		    ResetOpty;
}

		    if j <> integer(Elements(IdentTemp) * DataSize[Ident[IdentTemp].AllocElementType]) then begin

		      if (Ident[IdentIndex].NumAllocElements_ > 0) and
		         ((Ident[IdentIndex].NumAllocElements_ = Ident[IdentTemp].NumAllocElements) or
		          (Ident[IdentIndex].NumAllocElements_ = Ident[IdentTemp].NumAllocElements_)) then begin

//writeln('1: ', Ident[IdentIndex].NumAllocElements_);

                        asm65(#9'lda <' + GetLocalName(IdentIndex, 'adr.'));
                        asm65(#9'add :STACKORIGIN-1,x');
                        asm65(#9'sta @move.dst');
                        asm65(#9'lda >' + GetLocalName(IdentIndex, 'adr.'));
                        asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                        asm65(#9'sta @move.dst+1');

                        asm65(#9'lda :STACKORIGIN,x');
		        asm65(#9'sta @move.src');
                        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		        asm65(#9'sta @move.src+1');

	   	        a65(__subBX);
	   	        a65(__subBX);
		        StopOptimization;

		        ResetOpty;

                        asm65(#9'lda <' + IntToStr(Ident[IdentIndex].NumAllocElements_ * DataSize[Ident[IdentIndex].AllocElementType]));
                        asm65(#9'sta @move.cnt');
                        asm65(#9'lda >' + IntToStr(Ident[IdentIndex].NumAllocElements_ * DataSize[Ident[IdentIndex].AllocElementType]));
                        asm65(#9'sta @move.cnt+1');

		        asm65(#9'jsr @move');

		      end else begin

//writeln('2: ',Ident[IdentIndex].NumAllocElements);

                        asm65(#9'lda <' + GetLocalName(IdentIndex, 'adr.'));
		        asm65(#9'sta @move.dst');
                        asm65(#9'lda >' + GetLocalName(IdentIndex, 'adr.'));
		        asm65(#9'sta @move.dst+1');

                        asm65(#9'lda :STACKORIGIN,x');
                        asm65(#9'add :STACKORIGIN-1,x');
                        asm65(#9'sta @move.src');
                        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                        asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                        asm65(#9'sta @move.src+1');

	   	        a65(__subBX);
	   	        a65(__subBX);
		        StopOptimization;

		        ResetOpty;

                        asm65(#9'lda <' + IntToStr(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType]));
                        asm65(#9'sta @move.cnt');
                        asm65(#9'lda >' + IntToStr(Ident[IdentIndex].NumAllocElements * DataSize[Ident[IdentIndex].AllocElementType]));
                        asm65(#9'sta @move.cnt+1');

		        asm65(#9'jsr @move');

		      end;

		    end else begin

	     	      a65(__subBX);
		      StopOptimization;

 	              ResetOpty;

		      if (j <= 4) and (Ident[IdentTemp].AllocElementType <> RECORDTOK) then
		        asm65(#9':' + IntToStr(j) + ' mva ' + Name + '+# ' + GetLocalName(IdentIndex, 'adr.') + '+#')
		      else
		        asm65(#9'@move ' + svar + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(j));

		    end;

		  end else
		   GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);


		end else
 	 	  iError(k, UnknownIdentifier);


	       end else
		GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

	      end;

//	    StopOptimization;

	  end;// VARIABLE


	PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK:		// Procedure, Function (without assignment) call
	  begin

	   Param := NumActualParameters(i, IdentIndex, j);

//	  if Ident[IdentIndex].isOverload then begin
	    IdentTemp := GetIdentProc(Ident[IdentIndex].Name, IdentIndex, Param, j);

	    if IdentTemp = 0 then
	     if Ident[IdentIndex].isOverload then begin

	      if Ident[IdentIndex].NumParams <> j then
		iError(i, WrongNumParameters, IdentIndex);

	      iError(i, CantDetermine, IdentIndex);
	     end else
              iError(i, WrongNumParameters, IdentIndex);

	    IdentIndex := IdentTemp;

//	  end;

          if (Ident[IdentIndex].isStdCall = false) then
	    StartOptimization(i)
	  else
          if common.optimize.use = false then StartOptimization(i);


	  inc(run_func);

	  CompileActualParameters(i, IdentIndex);

	  dec(run_func);

	  if Ident[IdentIndex].Kind = FUNCTIONTOK then begin
	    a65(__subBX);							// zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji
	    StartOptimization(i);
	  end;

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


  LOOPUNROLLTOK:
    begin
     loopunroll := true;

     Result := i;
    end;


  NOLOOPUNROLLTOK:
    begin
     loopunroll := false;

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

    j := i + 1;

    i := CompileExpression(i + 1, SelectorType);


    if (SelectorType = ENUMTOK) and (Tok[j].Kind = IDENTTOK) and (Ident[GetIdent(Tok[j].Name^)].Kind = FUNCTIONTOK) then begin

       IdentTemp:=GetIdent(Tok[j].Name^);

       SelectorType := Ident[GetIdentResult(Ident[IdentTemp].ProcAsBlock)].AllocElementType;

       EnumName := Types[Ident[GetIdentResult(Ident[IdentTemp].ProcAsBlock)].NumAllocElements].Field[0].Name;

    end else

    if Tok[i].Kind = IDENTTOK then
      EnumName := GetEnumName(GetIdent(Tok[i].Name^));


    if SelectorType <> ENUMTYPE then
     if DataSize[SelectorType] <> 1 then
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

	if (Tok[i].Kind = IDENTTOK)  then
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
	if not ( (Ident[IdentIndex].Kind = VARIABLE) and (Ident[IdentIndex].DataType in OrdinalTypes + Pointers) {and (Ident[IdentIndex].AllocElementType = UNTYPETOK)} ) then
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

	    forLoop.begin_const := false;
	    forLoop.end_const := false;

	    forBPL := 0;

	    if SafeCompileConstExpression(j, ConstVal, ExpressionType, Ident[IdentIndex].DataType, true) then begin
	      Push(ConstVal, ASVALUE, DataSize[Ident[IdentIndex].DataType]);

	      forLoop.begin_value := ConstVal;
	      forLoop.begin_const := true;

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

	        forLoop.end_value := ConstVal;
	        forLoop.end_const := true;

		if ConstVal > 0 then forBPL := forBPL or 2;

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


//		if DataSize[ExpressionType] > DataSize[Ident[IdentIndex].DataType] then
//		  Error(i, 'FOR loop counter variable type (' + InfoAboutToken(Ident[IdentIndex].DataType) + ') is smaller than the type of the maximum range (' + InfoAboutToken(ExpressionType) +')' );


		if ((ActualParamType in UnsignedOrdinalTypes) and (ExpressionType in UnsignedOrdinalTypes)) or
		   ((ActualParamType in SignedOrdinalTypes) and (ExpressionType in SignedOrdinalTypes)) then
		begin

		 if DataSize[ExpressionType] > DataSize[ActualParamType] then ActualParamType := ExpressionType;
		 if DataSize[ActualParamType] > DataSize[Ident[IdentIndex].DataType] then ActualParamType := Ident[IdentIndex].DataType;

		end else
		 ActualParamType := Ident[IdentIndex].DataType;


	        if IdentTemp < 0 then IdentTemp := GetIdent('@FORTMP_'+IntToHex(CodeSize, 4));

	        GenerateAssignment(ASPOINTER, {DataSize[Ident[IdentTemp].DataType]} DataSize[ActualParamType], IdentTemp);

		asm65;		// ; --- To


		if loopunroll and forLoop.begin_const and forLoop.end_const then

		else
	          GenerateRepeatUntilProlog;	// Save return address used by GenerateForToDoEpilog


	        SaveBreakAddress;

	        asm65('; --- ForToDoCondition');


	 	if (ActualParamType = ExpressionType) and (DataSize[Ident[IdentTemp].DataType] > DataSize[ActualParamType]) then
	          Note(j, 'FOR loop counter variable type is of larger size than required');


	        StartOptimization(j);
		ResetOpty;			// !!!

		yes:=true;


		if loopunroll and forLoop.begin_const and forLoop.end_const then begin

	          CheckTok(j + 1, DOTOK);

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

		   case DataSize[ActualParamType] of
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

		   case DataSize[ActualParamType] of
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

		  Push(Ident[IdentTemp].Value, ASPOINTER, {DataSize[Ident[IdentTemp].DataType]} DataSize[ActualParamType], IdentTemp);

	          GenerateForToDoCondition(ActualParamType, Down, IdentIndex);	// Satisfied if counter does not reach the second expression value

	          CheckTok(j + 1, DOTOK);

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

//	asm65('; AssignFile');

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

//	asm65('; Reset');

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

//	asm65('; Rewrite');

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

//	asm65('; Append');

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

//	 writeln(svar,',',Tok[i+4].StrLength);

	CheckTok(i + 5, CPARTOK);

//	asm65;
//	asm65('; GetResourceHandle');

	asm65(#9'lda <MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name^);
	asm65(#9'lda >MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name^ + '+1');

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

//	asm65;
//	asm65('; GetResourceHandle');

	asm65(#9'lda <MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name^);

	asm65(#9'lda >MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
	asm65(#9'sta ' + Tok[i + 2].Name^ + '+1');

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

//	asm65('; BlockRead');

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

//	asm65('; BlockWrite');

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

//	asm65('; CloseFile');

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


	  if (ExpressionType = CHARTOK) and (Tok[i].Kind = DEREFERENCETOK) and (Tok[i - 1].Kind <> IDENTTOK) then begin

			asm65(#9'lda :STACKORIGIN,x');
		    	asm65(#9'sta :bp2');
		    	asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
		    	asm65(#9'sta :bp2+1');
		    	asm65(#9'ldy #$00');
			asm65(#9'lda (:bp2),y');
			asm65(#9'sta :STACKORIGIN,x');

	  end;

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


//	writeln(Ident[IdentIndex].Name,',',ExpressionType,' | ',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].Kind);


		if (Ident[IdentIndex].AllocElementType = PROCVARTOK) then begin

		  IdentTemp := GetIdent('@FN' + IntToHex(Ident[IdentIndex].NumAllocElements_, 4) );

		  if Ident[IdentTemp].Kind =  FUNCTIONTOK then
		   ExpressionType := Ident[IdentTemp].DataType
		  else
		   ExpressionType := UNTYPETOK;


		  if (ExpressionType = STRINGPOINTERTOK) then
		        GenerateWriteString(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, POINTERTOK)
		  else if (ExpressionType in IntegerTypes) then
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
		  else iError(i, CantReadWrite);


		end else
		if (ExpressionType = STRINGPOINTERTOK) or (Ident[IdentIndex].Kind = FUNCTIONTOK) or ((ExpressionType = POINTERTOK) and (Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then
		 GenerateWriteString(Ident[IdentIndex].Value, ASPOINTERTOPOINTER, Ident[IdentIndex].DataType)
		else
		if (ExpressionType = PCHARTOK) or (Ident[IdentIndex].AllocElementType in [CHARTOK, POINTERTOK]) then
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


     asm65('#asm:' + IntToStr(AsmBlockIndex));


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

      inc(i, 2);

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


	  if Ident[IdentIndex].DataType = ENUMTOK then
	   ExpressionType := Ident[IdentIndex].AllocElementType
	  else
	  if Ident[IdentIndex].DataType in Pointers then
	   ExpressionType := WORDTOK
	  else
	   ExpressionType := Ident[IdentIndex].DataType;


	  if Ident[IdentIndex].AllocElementType = REALTOK then
	   iError(i, OrdinalExpExpected);


	  if not (Ident[IdentIndex].idType in [PCHARTOK]) and (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) and ( not(Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) ) then begin

	      if Tok[i + 1].Kind = OBRACKETTOK then begin			// array index

		IndirectionLevel := ASPOINTERTOARRAYORIGIN;

		i := CompileArrayIndex(i, IdentIndex, ExpressionType);

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

	    IndirectionLevel := ASPOINTERTOARRAYORIGIN;

	    i := CompileArrayIndex(i, IdentIndex, ExpressionType);

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

	   if (Ident[IdentIndex].PassMethod = VARPASSING) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType in OrdinalTypes + Pointers + [RECORDTOK, OBJECTTOK])) then

	     if (Ident[IdentIndex].PassMethod = VARPASSING) or (Ident[IdentIndex].NumAllocElements > 0) or (IndirectionLevel = ASPOINTERTOPOINTER) or ((Ident[IdentIndex].NumAllocElements = 0) and (IndirectionLevel = ASPOINTERTOARRAYORIGIN)) then begin

	       ExpressionType := Ident[IdentIndex].AllocElementType;
 	       if ExpressionType = UNTYPETOK then ExpressionType := Ident[IdentIndex].DataType;


	       if ExpressionType in [RECORDTOK, OBJECTTOK] then
		Push(RecordSize(IdentIndex), ASVALUE, 2)
	       else
		Push(1, ASVALUE, DataSize[ExpressionType]);

	       inc(NumActualParams);
	     end else
	     if not (Ident[IdentIndex].AllocElementType in [BYTETOK, SHORTINTTOK]) then begin
	       Push(DataSize[Ident[IdentIndex].AllocElementType], ASVALUE, 1);			// +/- DATASIZE

	       ExpandParam(ExpressionType, BYTETOK);

	       inc(NumActualParams);
	     end;


	 if (Ident[IdentIndex].PassMethod = VARPASSING) and (IndirectionLevel <> ASPOINTERTOARRAYORIGIN) then IndirectionLevel := ASPOINTERTOPOINTER;

	 if ExpressionType = UNTYPETOK then
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
       if (Ident[j].ProcAsBlock = BlockStack[BlockStackTop]) and (Ident[j].Kind = FUNCTIONTOK) then begin

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

     asm65(#9'jmp @exit');

     ResetOpty;

     Result := i;
    end;


  BREAKTOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'BREAK not allowed');

//     asm65;
     asm65(#9'jmp b_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

     BreakPosStack[BreakPosStackTop].brk := true;

     ResetOpty;

     Result := i;
    end;


  CONTINUETOK:
    begin
     if BreakPosStackTop = 0 then
      Error(i, 'CONTINUE not allowed');

//     asm65;
     asm65(#9'jmp c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

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
end;	// case

end;	//CompileStatement


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure GenerateProcFuncAsmLabels(BlockIdentIndex: integer; VarSize: Boolean = false);
var IdentIndex, size: integer;
    emptyLine, yes: Boolean;
    fnam, txt, svar: string;
    varbegin: TString;
    HeaFile: TextFile;

// ----------------------------------------------------------------------------

   function Value(dorig: Boolean = false; brackets: Boolean = false): string;
   const reg: array [1..3] of string = (':EDX', ':ECX', ':EAX');			// !!! kolejnosc edx, ecx, eax !!! korzysta z tego memmove, memset !!!
   var ftmp: TFloat;
       v: Int64;
   begin

    ftmp:=Default(TFloat);

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
     if Ident[IdentIndex].isAbsolute and (Ident[IdentIndex].Kind = VARIABLE) and (abs(Ident[IdentIndex].Value) and $ff = 0) and (byte((abs(Ident[IdentIndex].Value) shr 24) and $7f) in [1..127]) then begin

      case byte(abs(Ident[IdentIndex].Value shr 24) and $7f) of
       1..3 : Result := #9'= ' + reg[abs(Ident[IdentIndex].Value shr 24) and $7f];
       4..19: Result := #9'= :STACKORIGIN-' + IntToStr(byte(abs(Ident[IdentIndex].Value shr 24) and $7f) - 3);
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

   if Ident[IdentIndex].AllocElementType in [BYTETOK..FORWARDTYPE] then begin

      case DataSize[Ident[IdentIndex].AllocElementType] of
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
       IdentTemp := GetIdent(resArray[i].resName);

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

        AssignFile(HeaFile, fnam); FileMode:=0; Reset(HeaFile);

	while not eof(HeaFile) do begin
	  readln(HeaFile, txt);

	  txt:=AnsiUpperCase(txt);

	  if (length(txt) > 255) or (pos(#0, txt) > 0) then begin
	   CloseFile(HeaFile);

	   Error(Ident[IdentIndex].Libraries, 'Error: MADS header file ''' + fnam + ''' has invalid format.');
	  end;

	  if (txt.IndexOf('.@EXIT') < 0) and (txt.IndexOf('.@VARDATA') < 0) then			// skip '@.EXIT', '.@VARDATA'
	   if (pos('MAIN.' + svar + ' ', txt) = 1) or (pos('MAIN.' + svar + #9, txt) = 1) or (pos('MAIN.' + svar + '.', txt) = 1) then begin
	    yes := FALSE;

	    asm65( Ident[IdentIndex].Name + copy(txt, 6 + length(Ident[IdentIndex].Alias), length(txt)) );
	   end;

	end;

	if yes then
	  iError(Ident[IdentIndex].Libraries, UnknownIdentifier, IdentIndex);

	CloseFile(HeaFile);

        if RCLIBRARY then begin asm65(''); asm65(#9'rmb'); asm65('') end;				// reset bank -> #0

    end else


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

//	writeln(Ident[IdentIndex].Name,',', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].IdType);

		  if ((Ident[IdentIndex].IdType <> ARRAYTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) or (Ident[IdentIndex].IdType = DATAORIGINOFFSET) then

		    asm65(Ident[IdentIndex].Name + Value(true))

		  else begin

		   if Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] then
		     asm65('adr.' + Ident[IdentIndex].Name + Value(true) + #9'; [' + IntToStr(RecordSize(IdentIndex)) + '] ' + InfoAboutToken(Ident[IdentIndex].DataType))
		   else

		   if Elements(IdentIndex) > 0 then begin

//	writeln(Ident[IdentIndex].Name,' | ',Elements(IdentIndex),'/',Ident[IdentIndex].IdType,'/',Ident[IdentIndex].PassMethod ,' | ', Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].IdType);

		    if (Ident[IdentIndex].NumAllocElements_ > 0) and not (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then
		     asm65('adr.' + Ident[IdentIndex].Name + Value(true, true) + ' .array [' + IntToStr(Ident[IdentIndex].NumAllocElements) + '] [' + IntToStr(Ident[IdentIndex].NumAllocElements_) + ']' + mads_data_size)
		    else
  		     asm65('adr.' + Ident[IdentIndex].Name + Value(true, true) + ' .array [' + IntToStr(Elements(IdentIndex)) + ']' + mads_data_size);  // !!!!

		   end else
		    asm65('adr.' + Ident[IdentIndex].Name + Value(true));

		   asm65('.var ' + Ident[IdentIndex].Name + #9'= adr.' + Ident[IdentIndex].Name + ' .word');    // !!!!

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
		      if Ident[IdentIndex].DataType = ENUMTOK then
		        inc(size, DataSize[Ident[IdentIndex].AllocElementType])
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


procedure SaveToStaticDataSegment(ConstDataSize: integer; ConstVal: Int64; ConstValType: Byte);
var ftmp: TFloat;
begin

	if (ConstDataSize < 0) or (ConstDataSize > $FFFF) then begin writeln('SaveToStaticDataSegment: ', ConstDataSize); halt end;

	 ftmp:=Default(TFloat);

	 case ConstValType of

	  SHORTINTTOK, BYTETOK, CHARTOK, BOOLEANTOK:
		       StaticStringData[ConstDataSize] := byte(ConstVal);

	  SMALLINTTOK, WORDTOK, SHORTREALTOK, POINTERTOK, STRINGPOINTERTOK, PCHARTOK:
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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ReadDataArray(i: integer; ConstDataSize: integer; const ConstValType: Byte; NumAllocElements: cardinal; StaticData: Boolean; Add: Boolean = false): integer;
var ActualParamType, ch: byte;
    NumActualParams, NumActualParams_, NumAllocElements_: cardinal;
    ConstVal: Int64;

// ----------------------------------------------------------------------------

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


// ----------------------------------------------------------------------------

procedure SaveData(compile: Boolean = true);
begin

   if compile then
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


// ----------------------------------------------------------------------------

{$i include/doevaluate.inc}

// ----------------------------------------------------------------------------


begin

// yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

{
  if (Tok[i].Kind = STRINGLITERALTOK) and (ConstValType = CHARTOK) then begin		// init char array by string -> array [0..15] of char = '0123456789ABCDEF';

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

  CheckTok(i, OPARTOK);

  NumActualParams := 0;
  NumActualParams_:= 0;

  NumAllocElements_ := NumAllocElements shr 16;
  NumAllocElements  := NumAllocElements and $ffff;

  repeat

  inc(NumActualParams);
//  if NumActualParams > NumAllocElements then Break;

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
   //SaveData;
    if Tok[i + 1].Kind = EVALTOK then
      NumActualParams := doEvaluate
    else
      SaveData;


  inc(i);

 until Tok[i].Kind <> COMMATOK;

 CheckTok(i, CPARTOK);


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


function ReadDataOpenArray(i: integer; ConstDataSize: integer; const ConstValType: Byte; out NumAllocElements: cardinal; StaticData: Boolean; Add: Boolean = false): integer;
var ActualParamType, ch: byte;
    NumActualParams: cardinal;
    ConstVal: Int64;


// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------


procedure SaveData(compile: Boolean = true);
begin

   if compile then
     i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


  if (ConstValType = STRINGPOINTERTOK) and (ActualParamType = CHARTOK) then begin	// rejestrujemy CHAR jako STRING

    if StaticData then
      Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

    ch := Tok[i].Value;
    DefineStaticString(i, chr(ch));

    ConstVal := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
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

  inc(NumActualParams);

end;


// ----------------------------------------------------------------------------

{$i include/doevaluate.inc}

// ----------------------------------------------------------------------------

begin

// yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
{
  if (Tok[i].Kind = STRINGLITERALTOK) and (ConstValType = CHARTOK) then begin		// init char array by string -> array [0..15] of char = '0123456789ABCDEF';

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

  CheckTok(i, OBRACKETTOK);

  NumActualParams := 0;
  NumAllocElements := 0;


  if Tok[i + 1].Kind = CBRACKETTOK then

   inc(i)

  else
  repeat

    if Tok[i + 1].Kind = EVALTOK then
      doEvaluate
    else
      SaveData;

    inc(i);

  until Tok[i].Kind <> COMMATOK;


 CheckTok(i, CBRACKETTOK);

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


procedure FormalParameterList(var i: integer; var NumParams: integer; var Param: TParamList; out Status: word; IsNestedFunction: Boolean; out NestedFunctionResultType: Byte; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: Byte);
var ListPassMethod: TParameterPassingMethod;
    NumVarOfSameType, VarTYpe, AllocElementType: byte;
    NumAllocElements: cardinal;
    VarOfSameTypeIndex: integer;
    VarOfSameType: TVariableList;
begin

      //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
      VarOfSameType := Default(TVariableList);

      NumParams := 0;

      if (Tok[i + 3].Kind = CPARTOK) and (Tok[i + 2].Kind = OPARTOK) then
       i := i + 4
      else

      if (Tok[i + 2].Kind = OPARTOK) then			   // Formal parameter list found
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


	  VarType := 0;							// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod in [CONSTPASSING, VARPASSING])  and (Tok[i].Kind <> COLONTOK) then begin

	   ListPassMethod := VARPASSING;
	   dec(i);

	  end else begin

	   CheckTok(i, COLONTOK);

	   if Tok[i + 1].Kind = DEREFERENCETOK then			// ^type
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

end;	//FormalParameterList


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CheckForwardResolutions(typ: Boolean = true);
var TypeIndex, IdentIndex: Integer;
    Name: string;
begin

// Search for unresolved forward references
for TypeIndex := 1 to NumIdent do
  if (Ident[TypeIndex].AllocElementType = FORWARDTYPE) and
     (Ident[TypeIndex].Block = BlockStack[BlockStackTop]) then begin

     Name := Ident[GetIdent(Tok[Ident[TypeIndex].NumAllocElements].Name^)].Name;

     if Ident[GetIdent(Tok[Ident[TypeIndex].NumAllocElements].Name^)].Kind = TYPETOK then

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
  if (Ident[TypeIndex].AllocElementType = FORWARDTYPE) and
     (Ident[TypeIndex].Block = BlockStack[BlockStackTop]) then

      if typ then
        Error(TypeIndex, 'Unresolved forward reference to type ' + Ident[TypeIndex].Name)
      else
        Error(TypeIndex, 'Identifier not found "' + Ident[GetIdent(Tok[Ident[TypeIndex].NumAllocElements].Name^)].Name + '"');

end;	//CheckForwardResolutions


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure CompileRecordDeclaration(var VarOfSameType: TVariableList; var tmpVarDataSize: integer; var ConstVal: Int64; VarOfSameTypeIndex: integer; VarType, AllocElementType: Byte; NumAllocElements: cardinal; isAbsolute: Boolean);
var tmpVarDataSize_, ParamIndex{, idx}: integer;
begin

//	writeln(iDtype,',',VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',Types[NumAllocElements].Block,' | ', AllocElementType);

   if ( (VarType in Pointers) and (AllocElementType = RECORDTOK) ) then begin

//	 writeln('> ',VarOfSameType[VarOfSameTypeIndex].Name,',',NestedDataType, ',',NestedAllocElementType,',', NestedNumAllocElements,',',NestedNumAllocElements and $ffff,'/',NestedNumAllocElements shr 16);

	 tmpVarDataSize_ := VarDataSize;


	 if (NumAllocElements shr 16) > 0 then begin											// array [0..x] of record

	   Ident[NumIdent].NumAllocElements  := NumAllocElements and $FFFF;
	   Ident[NumIdent].NumAllocElements_ := NumAllocElements shr 16;

	   VarDataSize := tmpVarDataSize + (NumAllocElements shr 16) * DataSize[POINTERTOK];

	   tmpVarDataSize := VarDataSize;

	   NumAllocElements := NumAllocElements and $FFFF;

	 end else
	   if Ident[NumIdent].isAbsolute = false then inc(tmpVarDataSize, DataSize[POINTERTOK]);		// wskaznik dla ^record


	 //idx := Ident[NumIdent].Value - DATAORIGIN;

//writeln(NumAllocElements);
//!@!@
	 for ParamIndex := 1 to Types[NumAllocElements].NumFields do									// label: ^record
	  if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//	    writeln('a ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,',',Types[NumAllocElements].Field[ParamIndex].DataType,',',Types[NumAllocElements].Field[ParamIndex].AllocElementType,',',Types[NumAllocElements].Field[ParamIndex].NumAllocElements);

	    DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,
	    VARIABLE,
	    Types[NumAllocElements].Field[ParamIndex].DataType,
	    Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
	    Types[NumAllocElements].Field[ParamIndex].AllocElementType, 0, DATAORIGINOFFSET);

	    Ident[NumIdent].Value := Ident[NumIdent].Value - tmpVarDataSize_;
	    Ident[NumIdent].PassMethod := VARPASSING;
//	    Ident[NumIdent].AllocElementType := Ident[NumIdent].DataType;

	  end;

	  VarDataSize := tmpVarDataSize;

   end else

	if (VarType in [RECORDTOK, OBJECTTOK]) then											// label: record
	 for ParamIndex := 1 to Types[NumAllocElements].NumFields do
	  if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then begin

//	    writeln('b ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,',',Types[NumAllocElements].Field[ParamIndex].DataType,',',Types[NumAllocElements].Field[ParamIndex].AllocElementType,',',Types[NumAllocElements].Field[ParamIndex].NumAllocElements,' | ',Ident[NumIdent].Value);

 	    tmpVarDataSize_ := VarDataSize;

	    DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,
	    VARIABLE,
	    Types[NumAllocElements].Field[ParamIndex].DataType,
	    Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
	    Types[NumAllocElements].Field[ParamIndex].AllocElementType, ord(isAbsolute) * ConstVal);

	    if isAbsolute then
	      if not (Types[NumAllocElements].Field[ParamIndex].DataType in [RECORDTOK, OBJECTTOK]) then				// fixed https://forums.atariage.com/topic/240919-mad-pascal/?do=findComment&comment=5422587
		inc(ConstVal, VarDataSize - tmpVarDataSize_);//    DataSize[Types[NumAllocElements].Field[ParamIndex].DataType]);

	  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileBlock(i: Integer; BlockIdentIndex: Integer; NumParams: Integer; IsFunction: Boolean; FunctionResultType: Byte; FunctionNumAllocElements: cardinal = 0; FunctionAllocElementType: byte = 0): Integer;
var
  VarOfSameType: TVariableList;
  VarPassMethod: TParameterPassingMethod;
  Param: TParamList;
  j, idx, NumVarOfSameType, VarOfSameTypeIndex, tmpVarDataSize, ParamIndex, ForwardIdentIndex, IdentIndex, external_libr: integer;
  NumAllocElements, NestedNumAllocElements, NestedFunctionNumAllocElements: cardinal;
  ConstVal: Int64;
  ImplementationUse, open_array, iocheck_old, isInterrupt_old, yes, Assignment, {pack,} IsNestedFunction,
  isAbsolute, isExternal, isForward, isVolatile, isStriped, isAsm, isReg, isInt, isInl, isOvr: Boolean;
  VarType, VarRegister, NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType,
  NestedFunctionAllocElementType, NestedDataType, NestedAllocElementType, IdType: Byte;
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

varPassMethod := UNDEFINED;

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
   asm65(#9'sta ' + Types[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name);
   asm65(#9'sty ' + Types[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name + '+1');

   DefineIdent(i, Types[Ident[BlockIdentIndex].ObjectIndex].Field[0].Name, VARIABLE,  WORDTOK, 0 , 0, 0);
   Ident[NumIdent].PassMethod := VARPASSING;
   Ident[NumIdent].AllocElementType := WORDTOK;
//  end;

 NumAllocElements := 0;

 for ParamIndex := 1 to Types[Ident[BlockIdentIndex].ObjectIndex].NumFields do
  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].ObjectVariable = false then begin

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

//	writeln(Param[ParamIndex].Name,':',Param[ParamIndex].DataType,'|',Param[ParamIndex].NumAllocElements and $FFFF,'/',Param[ParamIndex].NumAllocElements shr 16);

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

      Ident[GetIdent(Param[ParamIndex].Name)].NumAllocElements := Param[ParamIndex].NumAllocElements and $FFFF;
      Ident[GetIdent(Param[ParamIndex].Name)].NumAllocElements_ := Param[ParamIndex].NumAllocElements shr 16;

    end else begin
     if isReg and (ParamIndex in [1..3]) then begin
      tmpVarDataSize := VarDataSize;

      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

      Ident[GetIdent(Param[ParamIndex].Name)].isAbsolute := true;
      Ident[GetIdent(Param[ParamIndex].Name)].Value := (byte(ParamIndex) shl 24) or $80000000;

      VarDataSize := tmpVarDataSize;

     end else
      DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

//	writeln(Param[ParamIndex].Name,',',Param[ParamIndex].DataType);

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

// writeln(Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,',',Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,',',Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,',',Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType);

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

//	writeln(Ident[BlockIdentIndex].name,',',FunctionResultType,',',FunctionNumAllocElements,',',FunctionAllocElementType);

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
	) then begin yes := TRUE; Break end;


// yes:=true;


// Load ONE parameters from the stack
if (Ident[BlockIdentIndex].ObjectIndex = 0) then
 if Param[1].DataType = ENUMTOK then begin

  if (yes = false) and (NumParams = 1) and (DataSize[Param[1].AllocElementType] = 1) and (Param[1].PassMethod <> VARPASSING) then asm65(#9'sta ' + Param[1].Name)

 end else

  if (yes = false) and (NumParams = 1) and (DataSize[Param[1].DataType] = 1) and (Param[1].PassMethod <> VARPASSING) then asm65(#9'sta ' + Param[1].Name);


// Load parameters from the stack
if yes then begin
 for ParamIndex := 1 to NumParams do begin

  if Ident[BlockIdentIndex].isRecursion or Ident[BlockIdentIndex].isStdCall or (NumParams = 1) then begin

	if Param[ParamIndex].PassMethod = VARPASSING then
	  GenerateAssignment(ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
	else
	  GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);


  	if (Param[ParamIndex].PassMethod <> VARPASSING) and
     	   (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and
     	   (Param[ParamIndex].NumAllocElements and $FFFF > 1) then			// copy arrays

   	if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then begin

    	   asm65(':move');
    	   asm65(Param[ParamIndex].Name);
    	   asm65(IntToStr( RecordSize(GetIdent(Param[ParamIndex].Name)) ));

   	end else
  	 if not (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

	   if Param[ParamIndex].NumAllocElements shr 16 <> 0 then
     	     NumAllocElements := (Param[ParamIndex].NumAllocElements and $FFFF) * (Param[ParamIndex].NumAllocElements shr 16)
    	   else
     	     NumAllocElements := Param[ParamIndex].NumAllocElements;

    	   asm65(':move');
    	   asm65(Param[ParamIndex].Name);
    	   asm65(IntToStr(integer(NumAllocElements * DataSize[Param[ParamIndex].AllocElementType])));
   	end;

  end else begin

  	Assignment := true;

  	if (Param[ParamIndex].PassMethod <> VARPASSING) and
     	   (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and
     	   (Param[ParamIndex].NumAllocElements and $FFFF > 1) then			// copy arrays

   	if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then begin

	   Assignment := false;
	   asm65(#9'dex');

 	end else
  	 if not (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then begin

	   Assignment := false;
	   asm65(#9'dex');

	end;

  	if Assignment then
	  if Param[ParamIndex].PassMethod = VARPASSING then
	    GenerateAssignment(ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
	  else
	    GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);
  end;

  if (Paramindex <> NumParams) then asm65(#9'jmi @main');

 end;

 asm65('@main');
end;


// Object variable definitions
if Ident[BlockIdentIndex].ObjectIndex > 0 then
 for ParamIndex := 1 to Types[Ident[BlockIdentIndex].ObjectIndex].NumFields do begin

  tmpVarDataSize := VarDataSize;

{
  writeln(Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].Name,',',
          Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].DataType,',',
          Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].NumAllocElements,',',
          Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].AllocElementType);
}

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
  Ident[NumIdent].ObjectVariable := TRUE;


  VarDataSize := tmpVarDataSize + DataSize[POINTERTOK];

  if Types[Ident[BlockIdentIndex].ObjectIndex].Field[ParamIndex].ObjectVariable then begin
   Ident[NumIdent].Value := ConstVal + DATAORIGIN;

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
  UNITBEGINTOK, UNITENDTOK, IMPLEMENTATIONTOK, INITIALIZATIONTOK, IOCHECKON, IOCHECKOFF, LOOPUNROLLTOK, NOLOOPUNROLLTOK,
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


  if Tok[i].Kind = LOOPUNROLLTOK then begin
   if Pass = CODEGENERATIONPASS then loopunroll := true;
   inc(i, 2);
  end;


  if Tok[i].Kind = NOLOOPUNROLLTOK then begin
   if Pass = CODEGENERATIONPASS then loopunroll := false;
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

   VarRegister := 0;

   asm65;
   asm65('.endl', '; UNIT ' + UnitName[Tok[i].UnitIndex].Name);

   j := NumIdent;

   while (j > 0) and (Ident[j].UnitIndex = UnitNameIndex) do
     begin
  // If procedure or function, delete parameters first
      if Ident[j].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
       if Ident[j].IsUnresolvedForward and (Ident[j].isExternal = false) then
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


  if Tok[i].Kind = EXPORTSTOK then begin

   inc(i);

   repeat

    CheckTok(i , IDENTTOK);

    if Pass = CALLDETERMPASS then begin
      IdentIndex := GetIdent(Tok[i].Name^);

      if IdentIndex = 0 then
       iError(i, UnknownIdentifier);

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

    if not (Tok[i].Kind in [COMMATOK, SEMICOLONTOK]) then CheckTok(i, SEMICOLONTOK);

    if Tok[i].Kind = COMMATOK then inc(i);

   until Tok[i].Kind = SEMICOLONTOK;

    inc(i,1);

  end;


  if (Tok[i].Kind = INITIALIZATIONTOK) or ((PublicSection = FALSE) and (Tok[i].Kind = BEGINTOK))  then begin

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



  if Tok[i].Kind = LIBRARYTOK then begin       // na samym poczatku listingu

   if LIBRARYTOK_USE then CheckTok(i, BEGINTOK);

   CheckTok(i + 1, IDENTTOK);

   LIBRARY_NAME := Tok[i + 1].Name^;

   if (Tok[i + 2].Kind = COLONTOK) and (Tok[i + 3].Kind = INTNUMBERTOK) then begin

     CODEORIGIN_BASE := Tok[i + 3].Value;

     target.codeorigin := CODEORIGIN_BASE;

     inc(i, 2);
   end;

   inc(i);

   CheckTok(i + 1, SEMICOLONTOK);

   inc(i, 2);

   LIBRARYTOK_USE := true;
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


   if (Tok[i + 1].Kind = COLONTOK) and (Tok[i + 2].Kind = INTNUMBERTOK) then begin

     CODEORIGIN_BASE := Tok[i + 2].Value;

     target.codeorigin := CODEORIGIN_BASE;

     inc(i, 2);
   end;


   CheckTok(i + 1, SEMICOLONTOK);

   inc(i, 2);

   PROGRAMTOK_USE := true;
  end;


  if Tok[i].Kind = USESTOK then begin	  // co najwyzej po PROGRAM

  if LIBRARYTOK_USE then begin

   j:=i-1;

   while Tok[j].Kind in [SEMICOLONTOK, IDENTTOK, COLONTOK, INTNUMBERTOK] do dec(j);

   if Tok[j].Kind <> LIBRARYTOK then
    CheckTok(i, BEGINTOK);

  end;

  if PROGRAMTOK_USE then begin

   j:=i-1;

   while Tok[j].Kind in [SEMICOLONTOK, CPARTOK, OPARTOK, IDENTTOK, COMMATOK, COLONTOK, INTNUMBERTOK] do dec(j);

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

   if Tok[i].Kind = INTOK then begin
    CheckTok(i + 1, STRINGLITERALTOK);

    inc(i,2);
   end;

   if not (Tok[i].Kind in [COMMATOK, SEMICOLONTOK]) then CheckTok(i, SEMICOLONTOK);

   if Tok[i].Kind = COMMATOK then inc(i);

  until Tok[i].Kind <> IDENTTOK;

  CheckTok(i, SEMICOLONTOK);


  i:=idx;

  SetLength(UnitList, 0);		//  wlasciwy odczyt USES

  repeat

   CheckTok(i , IDENTTOK);

   yes:=true;
   for j := 1 to UnitName[UnitNameIndex].Units do
    if (UnitName[UnitNameIndex].Allow[j] = Tok[i].Name^) or (Tok[i].Name^ = 'SYSTEM') then yes:=false;

   if yes then begin

    inc(UnitName[UnitNameIndex].Units);

    if UnitName[UnitNameIndex].Units > MAXALLOWEDUNITS then
      Error(i, 'Out of resources, MAXALLOWEDUNITS');

    UnitName[UnitNameIndex].Allow[UnitName[UnitNameIndex].Units] := Tok[i].Name^;

   end;

   inc(i);

   if Tok[i].Kind = INTOK then begin
    CheckTok(i + 1, STRINGLITERALTOK);

    inc(i,2);
   end;

   if not (Tok[i].Kind in [COMMATOK, SEMICOLONTOK]) then CheckTok(i, SEMICOLONTOK);

   if Tok[i].Kind = COMMATOK then inc(i);

  until Tok[i].Kind <> IDENTTOK;

  CheckTok(i, SEMICOLONTOK);

  inc(i);

  end;

// -----------------------------------------------------------------------------
//				   LABEL
// -----------------------------------------------------------------------------

  if Tok[i].Kind = LABELTOK then begin

   inc(i);

   repeat

    CheckTok(i , IDENTTOK);

    DefineIdent(i, Tok[i].Name^, LABELTYPE, 0, 0, 0, 0);

    inc(i);

    if Tok[i].Kind = COMMATOK then inc(i);

   until Tok[i].Kind <> IDENTTOK;

   i := i + 1;
  end;	// if LABELTOK

// -----------------------------------------------------------------------------
//				   CONST
// -----------------------------------------------------------------------------

  if Tok[i].Kind = CONSTTOK then
    begin
    repeat

      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, 'Constant name expected but ' + GetSpelling(i + 1) + ' found')
      else
	if Tok[i + 2].Kind = EQTOK then begin

	  j := CompileConstExpression(i + 3, ConstVal, ConstValType, INTEGERTOK, false, false);

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

	  open_array := false;


	  if (Tok[i + 3].Kind = ARRAYTOK) and (Tok[i + 4].Kind = OFTOK) then begin

	   j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

  	   if VarType in [RECORDTOK, OBJECTTOK] then
	     Error(i, 'Only Array of ^'+InfoAboutToken(VarType)+' supported')
	   else
	   if VarType = ENUMTOK then
	     Error(i, InfoAboutToken(VarType)+' arrays are not supported');

	   if VarType = POINTERTOK then begin

	    if AllocElementType = UNTYPETOK then begin
	     NumAllocElements := 1;
	     AllocElementType := VarType;
	    end;

	   end else begin
	     NumAllocElements := 1;
	     AllocElementType := VarType;
	     VarType := POINTERTOK;
	   end;

	   if not (AllocElementType in [RECORDTOK, OBJECTTOK]) then open_array := true;

	  end else begin

	   j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

	   if Tok[i + 3].Kind = ARRAYTOK then j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	  end;


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

       	    DefineIdent(i + 1, Tok[i + 1].Name^, CONSTANT, VarType, NumAllocElements, AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE, IDENTTOK);

	   if (Ident[NumIdent].NumAllocElements in [0,1]) and (open_array = false) then
	    iError(i, IllegalExpression)
	   else
	   if open_array then begin									// const array of type = [ ]

	     if (Tok[j + 2].Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then begin	// = 'string'

	       Ident[NumIdent].Value := Tok[j + 2].StrAddress + CODEORIGIN_BASE;
       	       if VarType <> STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[j + 2].StrLength;

	       j := j + 2;

	       NumAllocElements := 0;

	     end else begin
	       j := ReadDataOpenArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true, Tok[j].Kind = PCHARTOK);

	       Ident[NumIdent].NumAllocElements := NumAllocElements;
	     end;

	   end else begin										// const array [] of type = ( )

	     if (Tok[j + 2].Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then begin	// = 'string'

	       if Tok[j + 2].StrLength > NumAllocElements then
     	         Error(j + 2, 'String length is larger than array of char length');

	       Ident[NumIdent].Value := Tok[j + 2].StrAddress + CODEORIGIN_BASE;
	       if VarType <> STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[j + 2].StrLength;

	       j := j + 2;

	       NumAllocElements := 0;

	     end else
	       j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType, NumAllocElements, true, Tok[j].Kind = PCHARTOK);

	   end;


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
    end;	// if CONSTTOK

// -----------------------------------------------------------------------------
//				TYPE
// -----------------------------------------------------------------------------

  if Tok[i].Kind = TYPETOK then
    begin
    repeat
      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, 'Type name expected but ' + GetSpelling(i + 1) + ' found')
      else
	  begin

	   CheckTok(i + 2, EQTOK);

	   if (Tok[i + 3].Kind = ARRAYTOK) and (Tok[i + 4].Kind <> OBRACKETTOK) then begin
	    j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

	    DefineIdent(i + 1, Tok[i + 1].Name^, USERTYPE, VarType, NumAllocElements, AllocElementType, 0, Tok[i + 3].Kind);
	    Ident[NumIdent].Pass := CALLDETERMPASS;

	   end else begin
	    j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

	    if Tok[i + 3].Kind = ARRAYTOK then j := CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	    DefineIdent(i + 1, Tok[i + 1].Name^, USERTYPE, VarType, NumAllocElements, AllocElementType, 0, Tok[i + 3].Kind);
	    Ident[NumIdent].Pass := CALLDETERMPASS;

	   end;

	  end;

      CheckTok(j + 1, SEMICOLONTOK);

      i := j + 1;
    until Tok[i + 1].Kind <> IDENTTOK;

    CheckForwardResolutions;

    i := i + 1;
    end;	// if TYPETOK
// -----------------------------------------------------------------------------
//				  VAR
// -----------------------------------------------------------------------------

  if Tok[i].Kind = VARTOK then
    begin

    isVolatile := FALSE;
    isStriped  := FALSE;

    NestedDataType := 0;
    NestedAllocElementType := 0;
    NestedNumAllocElements := 0;

    if (Tok[i + 1].Kind = OBRACKETTOK) and (Tok[i + 2].Kind in [VOLATILETOK, STRIPEDTOK]) then begin
       CheckTok(i + 3, CBRACKETTOK);

       if Tok[i + 2].Kind = VOLATILETOK then
         isVolatile := TRUE
       else
         isStriped  := TRUE;

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

     // pack:=false;


      if Tok[i + 1].Kind = PACKEDTOK then begin

       if (Tok[i + 2].Kind in [ARRAYTOK, RECORDTOK]) then begin
        inc(i);
       // pack := true;
       end else
        CheckTok(i + 2, RECORDTOK);

      end;


      IdType := Tok[i + 1].Kind;

      idx := i + 1;


      open_array := false;

      isAbsolute := false;
      isExternal := false;


      if (IdType = ARRAYTOK) and (Tok[i + 2].Kind = OFTOK) then begin			// array of type [Ordinal Types]

	i := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

    	if VarType in [RECORDTOK, OBJECTTOK] then
	  Error(i, 'Only Array of ^'+InfoAboutToken(VarType)+' supported')
	else
	if VarType = ENUMTOK then
	  Error(i, InfoAboutToken(VarType)+' arrays are not supported');

	if VarType = POINTERTOK then begin

	  if AllocElementType = UNTYPETOK then begin
	   NumAllocElements := 1;
	   AllocElementType := VarType;
	  end;

	end else begin
	  NumAllocElements := 1;
	  AllocElementType := VarType;
	  VarType := POINTERTOK;
	end;

	//if Tok[i + 1].Kind <> EQTOK then isAbsolute := true;				// !!!!

	ConstVal := 1;

	if not (AllocElementType in [RECORDTOK, OBJECTTOK]) then open_array := true;

      end else begin

        i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

        if IdType = ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

	if (NumAllocElements = 1) or (NumAllocElements = $10001) then ConstVal := 1;

      end;


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

       isAbsolute := true;
       isExternal := true;

       inc(i);

       external_libr := 0;

       if Tok[i + 1].Kind = IDENTTOK then begin

	external_name := Tok[i + 1].Name^;

	if Tok[i + 2].Kind = STRINGLITERALTOK then begin
	  external_libr := i + 2;

	  inc(i);
	end;

	inc(i);
       end else
       if Tok[i + 1].Kind = STRINGLITERALTOK then begin

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


	if (VarType in [RECORDTOK, OBJECTTOK] {+ Pointers}) and (NumAllocElements = 0) then	 // brak mozliwosci identyfikacji dla takiego przypadku
	 Error(i + 1, 'not possible in this case');

	inc(i);

	varPassMethod := UNDEFINED;

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



      if IdType = IDENTTOK then IdType := Ident[GetIdent(Tok[idx].Name^)].IdType;



      tmpVarDataSize := VarDataSize;		// dla ABSOLUTE, RECORD


      for VarOfSameTypeIndex := 1 to NumVarOfSameType do begin


//  writeln(VarType,',',NumAllocElements and $FFFF,',',NumAllocElements shr 16,',',AllocElementType, ',',idType,',',varPassMethod,',',isAbsolute);


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

//	  writeln('? ',VarOfSameType[VarOfSameTypeIndex].Name,',', NestedDataType,',',NestedAllocElementType,',',NestedNumAllocElements,'|',IdType);

	  Ident[NumIdent].NestedDataType := NestedDataType;
	  Ident[NumIdent].NestedAllocElementType := NestedAllocElementType;
	  Ident[NumIdent].NestedNumAllocElements := NestedNumAllocElements;
	  Ident[NumIdent].isVolatile := isVolatile;

	  if varPassMethod <> UNDEFINED then Ident[NumIdent].PassMethod := varPassMethod;


	  if isStriped and (Ident[NumIdent].PassMethod <> VARPASSING) then begin

            if NumAllocElements shr 16 > 0 then
              yes := (NumAllocElements and $FFFF) * (NumAllocElements shr 16) <= 256
	    else
	      yes := NumAllocElements <= 256;

	    if yes then
  	      Ident[NumIdent].isStriped := TRUE
	    else
	      warning(i, StripedAllowed);

	  end;


	  varPassMethod := UNDEFINED;


//	  writeln(VarType, ' / ', AllocElementType ,' = ',NestedDataType, ',',NestedAllocElementType,',', hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));


	  if (VarType = POINTERTOK) and (AllocElementType = STRINGPOINTERTOK) and (NestedNumAllocElements > 0) and (NumAllocElements > 1) then begin	// array [ ][ ] of string;


	   if Ident[NumIdent].isAbsolute then
	     Error(i, 'ABSOLUTE modifier is not available for this type of array');

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

       if Tok[i + 1].Kind = EQTOK then begin


        if Ident[NumIdent].isStriped then
	 Error(i + 1, 'Initialization for striped array not allowed');


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
	  if (Tok[i].Kind = STRINGLITERALTOK) and (open_array = false) and (VarType = POINTERTOK) and (AllocElementType = CHARTOK) then

	    SaveToDataSegment(idx, Tok[i].StrAddress - CODEORIGIN + 1, CODEORIGINOFFSET)

	  else

{
	  if (Tok[i].Kind = STRINGLITERALTOK) and (open_array = false) then begin

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
}

	   if (Ident[NumIdent].NumAllocElements in [0,1]) and (open_array = false) then
	    iError(i, IllegalExpression)
	   else
	    if open_array then begin 									// array of type = [ ]

	     if (Tok[i].Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then begin		// = 'string'

	       Ident[NumIdent].Value := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
	       if VarType <> STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[i].StrLength;

	       Ident[NumIdent].isAbsolute := true;

	       NumAllocElements := 0;

	     end else begin
	       i := ReadDataOpenArray(i, idx, Ident[NumIdent].AllocElementType, NumAllocElements, false, Tok[i-2].Kind = PCHARTOK);

	       Ident[NumIdent].NumAllocElements := NumAllocElements;
	     end;

	     inc(VarDataSize, NumAllocElements * DataSize[Ident[NumIdent].AllocElementType]);

	    end else begin										// array [] of type = ( )

	     if (Tok[i].Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then begin		// = 'string'

	       if Tok[i].StrLength > NumAllocElements then
     	         Error(i, 'string length is larger than array of char length');

	       Ident[NumIdent].Value := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
	       if VarType <> STRINGPOINTERTOK then inc(Ident[NumIdent].Value);

	       Ident[NumIdent].NumAllocElements := Tok[i].StrLength;

	       Ident[NumIdent].isAbsolute := true;

	      // NumAllocElements := 1;

	     end else
 	       i := ReadDataArray(i, idx, Ident[NumIdent].AllocElementType, Ident[NumIdent].NumAllocElements or Ident[NumIdent].NumAllocElements_ shl 16, false, Tok[i-2].Kind = PCHARTOK);

	    end;

	end;

       end;

      CheckTok(i + 1, SEMICOLONTOK);

      isVolatile := FALSE;
      isStriped  := FALSE;

      if (Tok[i + 2].Kind = OBRACKETTOK) and (Tok[i + 3].Kind in [VOLATILETOK, STRIPEDTOK]) then begin
       CheckTok(i + 4, CBRACKETTOK);

       if Tok[i + 3].Kind = VOLATILETOK then
         isVolatile := TRUE
       else
         isStriped  := TRUE;

       inc(i, 3);
      end;


    i := i + 1;
    until Tok[i + 1].Kind <> IDENTTOK;

    CheckForwardResolutions(false);								// issue #126 fixed

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
	 ((Tok[i].Kind = PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROCEDURETOK)) or
//	 ((Tok[i].Kind = CONSTRUCTORTOK) and (Ident[ForwardIdentIndex].Kind <> CONSTRUCTORTOK)) or
//	 ((Tok[i].Kind = DESTRUCTORTOK) and (Ident[ForwardIdentIndex].Kind <> DESTRUCTORTOK)) or
	 ((Tok[i].Kind = FUNCTIONTOK) and (Ident[ForwardIdentIndex].Kind <> FUNCTIONTOK)) then
	ForwardIdentIndex := 0;     // Found an identifier of another kind or scope, or it is already resolved


      if (Tok[i].Kind in [CONSTRUCTORTOK, DESTRUCTORTOK]) and (ForwardIdentIndex = 0) then
        Error(i, 'constructors, destructors operators must be methods');


//    writeln(ForwardIdentIndex,',',tok[i].line,',',Ident[ForwardIdentIndex].isOverload,',',Ident[ForwardIdentIndex].IsUnresolvedForward,' / ',Tok[i].Kind = PROCEDURETOK,',',  ((Tok[i].Kind = PROCEDURETOK) and (Ident[ForwardIdentIndex].Kind <> PROC)));

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

	GenerateReturn(IsNestedFunction, isInt, isInl, isOvr);

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

	GenerateReturn(IsNestedFunction, isInt, Ident[ForwardIdentIndex].isInline, Ident[ForwardIdentIndex].isOverload);

	if OutputDisabled then OutputDisabled := FALSE;

	Ident[ForwardIdentIndex].IsUnresolvedForward := FALSE;

	end;

      end;


	CheckTok(i, SEMICOLONTOK);

	inc(i);

	end;// else
  end;// while


OutputDisabled := (Pass = CODEGENERATIONPASS) and (BlockStack[BlockStackTop] <> 1) and (not Ident[BlockIdentIndex].IsNotDead);


// asm65('@main');

if not isAsm then begin
  GenerateDeclarationEpilog;  // Make jump to block entry point

  if not(Tok[i-1].Kind in [PROCALIGNTOK, LOOPALIGNTOK, LINKALIGNTOK]) then
   if LIBRARYTOK_USE and (Tok[i].Kind <> BEGINTOK) then

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
  if Ident[j].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
    if Ident[j].IsUnresolvedForward and (Ident[j].isExternal = false) then
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


 if Pass = CALLDETERMPASS then
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
      if Ident[j].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
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

if target.id = ___a8 then begin

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

  if target.id = ___a8 then begin
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
 if Pass = CODEGENERATIONPASS then begin

// !!! musze zapisac wszystko, lacznie z 'zerami' !!! np. aby TextAtr dzialal

  DataSegmentSize := VarDataSize;

  if LIBRARYTOK_USE = FALSE then
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


if LIBRARYTOK_USE then begin

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

if target.id = ___a8 then begin
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


 if (High(resArray) > 0) and (target.id <> ___a8) then begin

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
var i, err: integer;
    s: string;
    t, c: string[32];
begin

  t := 'A8';		// target
  c := '';		// cpu

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
   if (AnsiUpperCase(ParamStr(i)) = '-CPU') then begin

     c := AnsiUpperCase(ParamStr(i+1));
     inc(i);

   end else
   if pos('-CPU:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     c := copy(ParamStr(i), 6, 255);

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
     if err <> 0 then Syntax(3);

   end else
   if pos('-CODE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 7, 255), CODEORIGIN_BASE, err);
     if err <> 0 then Syntax(3);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-DATA') or (AnsiUpperCase(ParamStr(i)) = '-D') then begin

     val('$'+ParamStr(i+1), DATA_BASE, err);
     inc(i);
     if err<>0 then Syntax(3);

   end else
   if pos('-DATA:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 7, 255), DATA_BASE, err);
     if err<>0 then Syntax(3);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-STACK') or (AnsiUpperCase(ParamStr(i)) = '-S') then begin

     val('$'+ParamStr(i+1), STACK_BASE, err);
     inc(i);
     if err<>0 then Syntax(3);

   end else
   if pos('-STACK:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 8, 255), STACK_BASE, err);
     if err<>0 then Syntax(3);

   end else
   if (AnsiUpperCase(ParamStr(i)) = '-ZPAGE') or (AnsiUpperCase(ParamStr(i)) = '-Z') then begin

     val('$'+ParamStr(i+1), ZPAGE_BASE, err);
     inc(i);
     if err<>0 then Syntax(3);

   end else
   if pos('-ZPAGE:', AnsiUpperCase(ParamStr(i))) = 1 then begin

     val('$'+copy(ParamStr(i), 8, 255), ZPAGE_BASE, err);
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
     writeln('Error: Can''t open file ''' + UnitName[1].Name + '''');
     FreeTokens;
     Halt(3);
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
  if AnsiUpperCase(c) = '6502' then target.cpu := CPU_6502 else
   if AnsiUpperCase(c) = '65C02' then target.cpu := CPU_65C02 else
    if AnsiUpperCase(c) = '65816' then target.cpu := CPU_65816 else
     Syntax(3);


 case target.cpu of
  CPU_6502: AddDefine('CPU_6502');
  cpu_65c02: AddDefine('CPU_65C02');
  cpu_65816: AddDefine('CPU_65816');
 end;

 AddDefines := NumDefines;

end;	//ParseParam


// ----------------------------------------------------------------------------
//                                 Main program
// ----------------------------------------------------------------------------

begin

{$IFDEF WINDOWS}
 if GetFileType(GetStdHandle(STD_OUTPUT_HANDLE)) = 3 then begin
  Assign(Output, ''); FileMode:=1; Rewrite(Output);
 end;
{$ENDIF}

//WriteLn('Sub-Pascal 32-bit real mode compiler v. 2.0 by Vasiliy Tereshkov, 2009');

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


 Defines[1].Name := AnsiUpperCase(target.name);

 if (UnitName[1].Name='') then Syntax(3);

 if pos(MainPath, ExtractFilePath(UnitName[1].name)) > 0 then
  FilePath := ExtractFilePath(UnitName[1].Name)
 else
  FilePath := MainPath + ExtractFilePath(UnitName[1].Name);

 DefaultFormatSettings.DecimalSeparator := '.';


 {$IFDEF USEOPTFILE}

 AssignFile(OptFile, ChangeFileExt(UnitName[1].Name, '.opt') ); FileMode:=1; rewrite(OptFile);

 {$ENDIF}


 if ExtractFileName(outputFile) <> '' then
  AssignFile(OutFile, outputFile)
 else
  AssignFile(OutFile, ChangeFileExt(UnitName[1].Name, '.a65') );

 FileMode:=1;
 rewrite(OutFile);

 TextColor(WHITE);

 Writeln('Compiling ', UnitName[1].Name);

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
 DefineIdent(1, 'BLOCKREAD',      FUNCTIONTOK, INTEGERTOK, 0, 0, $00000000);
 DefineIdent(1, 'BLOCKWRITE',     FUNCTIONTOK, INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'GETRESOURCEHANDLE', FUNCTIONTOK, INTEGERTOK, 0, 0, $00000000);

 DefineIdent(1, 'NIL',      CONSTANT, POINTERTOK, 0, 0, CODEORIGIN);

 DefineIdent(1, 'EOL',      CONSTANT, CHARTOK, 0, 0, target.eol);

 DefineIdent(1, '__BUFFER', CONSTANT, WORDTOK, 0, 0, target.buf);

 DefineIdent(1, 'TRUE',     CONSTANT, BOOLEANTOK, 0, 0, $00000001);
 DefineIdent(1, 'FALSE',    CONSTANT, BOOLEANTOK, 0, 0, $00000000);

 DefineIdent(1, 'MAXINT',      CONSTANT, INTEGERTOK, 0, 0, MAXINT);
 DefineIdent(1, 'MAXSMALLINT', CONSTANT, INTEGERTOK, 0, 0, MAXSMALLINT);

 DefineIdent(1, 'PI',       CONSTANT, REALTOK, 0, 0, $40490FDB00000324);
 DefineIdent(1, 'NAN',      CONSTANT, SINGLETOK, 0, 0, $FFC00000FFC00000);
 DefineIdent(1, 'INFINITY', CONSTANT, SINGLETOK, 0, 0, $7F8000007F800000);
 DefineIdent(1, 'NEGINFINITY', CONSTANT, SINGLETOK, 0, 0, $FF800000FF800000);

// First pass: compile the program and build call graph
 NumPredefIdent := NumIdent;
 Pass := CALLDETERMPASS;
 CompileProgram;


// Visit call graph nodes and mark all procedures that are called as not dead
 OptimizeProgram(GetIdent('MAIN'));


// Second pass: compile the program and generate output (IsNotDead fields are preserved since the first pass)
 NumIdent := NumPredefIdent;

 fillchar(DataSegment, sizeof(DataSegment), 0);

 NumBlocks := 0; BlockStackTop := 0; CodeSize := 0; CodePosStackTop := 0; VarDataSize := 0;
 CaseCnt := 0; IfCnt := 0; ShrShlCnt := 0; NumTypes := 0; run_func := 0; NumProc := 0;

 NumStaticStrChars := NumStaticStrCharsTmp;


 ResetOpty;
 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 LIBRARY_USE := LIBRARYTOK_USE;

 LIBRARYTOK_USE := FALSE;
 PROGRAMTOK_USE := FALSE;
 INTERFACETOK_USE := FALSE;
 PublicSection := TRUE;

 for i := 1 to High(UnitName) do UnitName[i].Units := 0;

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
