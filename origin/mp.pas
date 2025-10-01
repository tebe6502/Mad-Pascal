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

# (TokenAt( ].Kind = ASMTOK + TokenAt( ].Value = 0) wersja z { }
# (TokenAt( ].Kind = ASMTOK + TokenAt( ].Value = 1) wersja bez { }

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

{$i Defines.inc}

uses
  Crt,
  SysUtils,
 {$IFDEF WINDOWS}
	Windows,
  {$ENDIF}

  Common,
  Messages,
  Scanner,
  Parser,
  Optimize,
  Diagnostic,
  MathEvaluate;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


  function GetIdentResult(ProcAsBlock: Integer): Integer;
  var
    IdentIndex: Integer;
  begin

    Result := 0;

    for IdentIndex := 1 to NumIdent do
      if (IdentifierAt(IdentIndex).Block = ProcAsBlock) and (IdentifierAt(IdentIndex).Name = 'RESULT') then
       exit(IdentIndex);

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function GetOverloadName(IdentIndex: Integer): String;
  var
    ParamIndex: Integer;
  begin

    // Result := '@' + IntToHex(IdentifierAt(IdentIndex).Value, 4);

    Result := '@' + IntToHex(IdentifierAt(IdentIndex).NumParams, 2);

    if IdentifierAt(IdentIndex).NumParams > 0 then
      for ParamIndex := IdentifierAt(IdentIndex).NumParams downto 1 do
        Result := Result + IntToHex(Ord(IdentifierAt(IdentIndex).Param[ParamIndex].PassMethod), 2) +
          IntToHex(IdentifierAt(IdentIndex).Param[ParamIndex].DataType, 2) +
          IntToHex(IdentifierAt(IdentIndex).Param[ParamIndex].AllocElementType, 2) +
          IntToHex(IdentifierAt(IdentIndex).Param[ParamIndex].NumAllocElements, 8 *
          Ord(IdentifierAt(IdentIndex).Param[ParamIndex].NumAllocElements <> 0));

  end;


  function GetLocalName(IdentIndex: Integer; a: String = ''): String;
  begin

    if ((IdentifierAt(IdentIndex).UnitIndex > 1) and (IdentifierAt(IdentIndex).UnitIndex <> UnitNameIndex) and
      IdentifierAt(IdentIndex).Section) then
      Result := UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.' + a + IdentifierAt(IdentIndex).Name
    else
      Result := a + IdentifierAt(IdentIndex).Name;

  end;


  function ExtractName(IdentIndex: Integer; const a: String): String;
  var
    lab: String;
  begin

    lab := IdentifierAt(IdentIndex).Name;

    if (lab <> a) and (pos(UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.', a) = 1) then
    begin

      if lab.IndexOf('.') > 0 then lab := copy(lab, 1, lab.LastIndexOf('.'));

      if (pos(UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.adr.', a) = 1) then
        Result := UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.adr.' + lab
      else
        Result := UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.' + lab;

    end
    else
      Result := copy(a, 1, a.IndexOf('.'));

  end;


  function TestName(IdentIndex: Integer; a: String): Boolean;
  begin

    if {(IdentifierAt(IdentIndex).UnitIndex > 1) and} (pos(UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.', a) = 1) then
      a := copy(a, a.IndexOf('.') + 2, length(a));

    Result := pos('.', a) > 0;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function GetIdentProc(S: TString; ProcIdentIndex: Integer; Param: TParamList; NumParams: Integer): Integer;

  type
    TBest = record
    hit: Cardinal;
    IdentIndex, b: Integer;
  end;

  var
    IdentIndex, BlockStackIndex, i, k, b: Integer;
    hits, m: Cardinal;
    df: Byte;
    yes: Boolean;

    best: array of TBest;

  begin

    Result := 0;

    SetLength(best, 1);

    best[0].IdentIndex := 0;
    best[0].b := 0;
    best[0].hit := 0;

    for BlockStackIndex := BlockStackTop downto 0 do
      // search all nesting levels from the current one to the most outer one
    begin
      for IdentIndex := NumIdent downto 1 do
        if (IdentifierAt(IdentIndex).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and
          (IdentifierAt(IdentIndex).UnitIndex = IdentifierAt(ProcIdentIndex).UnitIndex) and
          (S = IdentifierAt(IdentIndex).Name) and (BlockStack[BlockStackIndex] = IdentifierAt(IdentIndex).Block) and
          (IdentifierAt(IdentIndex).NumParams = NumParams) then
        begin

          hits := 0;


          for i := 1 to NumParams do
            if ((((IdentifierAt(IdentIndex).Param[i].DataType in UnsignedOrdinalTypes) and
              (Param[i].DataType in UnsignedOrdinalTypes)) and
              (DataSize[IdentifierAt(IdentIndex).Param[i].DataType] >= DataSize[Param[i].DataType])) or
              (((IdentifierAt(IdentIndex).Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in
              SignedOrdinalTypes)) and (DataSize[IdentifierAt(IdentIndex).Param[i].DataType] >=
              DataSize[Param[i].DataType])) or
              (((IdentifierAt(IdentIndex).Param[i].DataType in SignedOrdinalTypes) and (Param[i].DataType in
              UnsignedOrdinalTypes)) and  // smallint > byte
              (DataSize[IdentifierAt(IdentIndex).Param[i].DataType] >= DataSize[Param[i].DataType])) or
              ((IdentifierAt(IdentIndex).Param[i].DataType =
              Param[i].DataType) {and (IdentifierAt(IdentIndex).Param[i].AllocElementType = Param[i].AllocElementType)})) or

              //( (IdentifierAt(IdentIndex).Param[i].AllocElementType = PROCVARTOK) and (IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16 = Param[i].NumAllocElements shr 16) ) or

              ((Param[i].DataType in Pointers) and (IdentifierAt(IdentIndex).Param[i].DataType =
              Param[i].AllocElementType)) or
              // dla parametru VAR

              ((IdentifierAt(IdentIndex).Param[i].DataType = UNTYPETOK) and
              (IdentifierAt(IdentIndex).Param[i].PassMethod = VARPASSING)) //or

            //    ( (IdentifierAt(IdentIndex).Param[i].DataType = UNTYPETOK) and (IdentifierAt(IdentIndex).Param[i].PassMethod = VARPASSING) and (Param[i].DataType in OrdinalTypes {+ [POINTERTOK]} {IntegerTypes + [CHARTOK]}) )

            then
            begin

              if (IdentifierAt(IdentIndex).Param[i].AllocElementType = PROCVARTOK) then
              begin

                //  writeln(IdentifierAt(IdentIndex).Name,',', IdentifierAt(GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16, 4))].NumParams,',',Param[i].AllocElementType,' | ', IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].AllocElementType,',',IdentifierAt(GetIdent('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))].NumParams);

                case Param[i].AllocElementType of

                  PROCEDURETOK, FUNCTIONTOK:
                    yes := IdentifierAt(GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16, 4))).NumParams = IdentifierAt(GetIdent(Param[i].Name)).NumParams;

                  PROCVARTOK:
                    yes := (IdentifierAt(GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).Param[i].NumAllocElements shr 16, 4))).NumParams) = (IdentifierAt(GetIdent('@FN' + IntToHex(Param[i].NumAllocElements shr 16, 4))).NumParams);

                  else

                    yes := False

                end;

                if yes then Inc(hits);

              end
              else
                Inc(hits);

{
writeln('_C: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}

              if (IdentifierAt(IdentIndex).Param[i].DataType = UNTYPETOK) and (Param[i].DataType = POINTERTOK) and
                (IdentifierAt(IdentIndex).Param[i].AllocElementType = UNTYPETOK) and
                (Param[i].AllocElementType <> UNTYPETOK) and (Param[i].NumAllocElements > 0)
              {and (IdentifierAt(IdentIndex).Param[i].NumAllocElements = Param[i].NumAllocElements)} then
              begin
{
writeln('_A: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
                Inc(hits);

              end;


              if (IdentifierAt(IdentIndex).Param[i].DataType in IntegerTypes) and (Param[i].DataType in IntegerTypes) then
              begin

                if IdentifierAt(IdentIndex).Param[i].DataType in UnsignedOrdinalTypes then
                begin

                  b := DataSize[IdentifierAt(IdentIndex).Param[i].DataType];  // required parameter type
                  k := DataSize[Param[i].DataType];        // type of parameter passed

                  //       writeln('+ ',IdentifierAt(IdentIndex).Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',IdentifierAt(IdentIndex).Param[i].DataType);

                  if b >= k then
                  begin
                    df := 4 - abs(b - k);
                    if Param[i].DataType in UnsignedOrdinalTypes then Inc(df, 2);  // +2pts

                    Inc(hits, df);
                    //while df > 0 do begin inc(hits); dec(df) end;
                  end;

                end
                else
                begin            // signed

                  b := DataSize[IdentifierAt(IdentIndex).Param[i].DataType];  // required parameter type
                  k := DataSize[Param[i].DataType];        // type of parameter passed

                  if Param[i].DataType in [BYTETOK, WORDTOK] then Inc(k);  // -> signed

                  //       writeln('- ',IdentifierAt(IdentIndex).Name,' - ',b,',',k,',',4 - abs(b-k),' / ',Param[i].DataType,' | ',IdentifierAt(IdentIndex).Param[i].DataType);

                  if b >= k then
                  begin
                    df := 4 - abs(b - k);
                    if Param[i].DataType in SignedOrdinalTypes then Inc(df, 2);  // +2pts if the same types

                    Inc(hits, df);
                    //while df > 0 do begin inc(hits); dec(df) end;
                  end;

                end;

              end;


              if (IdentifierAt(IdentIndex).Param[i].DataType = Param[i].DataType) and
                (IdentifierAt(IdentIndex).Param[i].AllocElementType <> UNTYPETOK) and
                (IdentifierAt(IdentIndex).Param[i].AllocElementType = Param[i].AllocElementType) then

              begin
{
writeln('_D: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex, ' - ',IdentifierAt(IdentIndex).NumParams,',', NumParams);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
                Inc(hits);

              end;


              if (IdentifierAt(IdentIndex).Param[i].DataType = Param[i].DataType) and
                ((IdentifierAt(IdentIndex).Param[i].AllocElementType = Param[i].AllocElementType) or
                ((IdentifierAt(IdentIndex).Param[i].AllocElementType = UNTYPETOK) and
                (Param[i].AllocElementType <> UNTYPETOK) and (IdentifierAt(IdentIndex).Param[i].NumAllocElements =
                Param[i].NumAllocElements)) or ((IdentifierAt(IdentIndex).Param[i].AllocElementType <> UNTYPETOK) and
                (Param[i].AllocElementType = UNTYPETOK) and (IdentifierAt(IdentIndex).Param[i].NumAllocElements =
                Param[i].NumAllocElements))) then
              begin
{
writeln('_B: ', IdentifierAt(IdentIndex).Name);

     writeln (IdentifierAt(IdentIndex).Name,',',IdentIndex, ' - ',IdentifierAt(IdentIndex).NumParams,',', NumParams);
     writeln (IdentifierAt(IdentIndex).Param[i].DataType,',', Param[i].DataType);
     writeln (IdentifierAt(IdentIndex).Param[i].AllocElementType ,',', Param[i].AllocElementType);
     writeln (IdentifierAt(IdentIndex).Param[i].NumAllocElements,',', Param[i].NumAllocElements);
}
                Inc(hits);

              end;

            end;


          k := High(best);

          best[k].IdentIndex := IdentIndex;
          best[k].hit := hits;
          best[k].b := IdentifierAt(IdentIndex).Block;

          SetLength(best, k + 2);

        end;

    end;// for


    m := 0;
    b := 0;

    if High(best) = 1 then
      Result := best[0].IdentIndex
    else
    begin

      if NumParams = 0 then
      begin

        for i := 0 to High(best) - 1 do
          if {(best[i].hit > m) and} (best[i].b >= b) then
          begin
            b := best[i].b;
            Result := best[i].IdentIndex;
          end;

      end
      else

        for i := 0 to High(best) - 1 do
          if (best[i].hit > m) and (best[i].b >= b) then
          begin
            m := best[i].hit;
            b := best[i].b;
            Result := best[i].IdentIndex;
          end;

    end;

    SetLength(best, 0);

  end;  //GetIdentProc


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure TestIdentProc(x: Integer; S: TString);
  var
    IdentIndex, BlockStackIndex: Integer;
    i, k, m: Integer;
    ok: Boolean;

    ov: array of record
    i, j, u, b: Integer;
    end;

    l: array of record
    u, b: Integer;
    Param: TParamList;
    NumParams: Word;
    end;


    procedure addOverlay(UnitIndex, Block: Integer; ovr: Boolean);
    var
      i: Integer;
    begin

      for i := High(ov) - 1 downto 0 do
        if (ov[i].u = UnitIndex) and (ov[i].b = Block) then
        begin

          Inc(ov[i].i, Ord(ovr));
          Inc(ov[i].j);

          exit;
        end;

      i := High(ov);

      ov[i].u := UnitIndex;
      ov[i].b := Block;
      ov[i].i := Ord(ovr);
      ov[i].j := 1;

      SetLength(ov, i + 2);

    end;

  begin

    SetLength(ov, 1);
    SetLength(l, 1);

    for BlockStackIndex := BlockStackTop downto 0 do
      // search all nesting levels from the current one to the most outer one
    begin
      for IdentIndex := NumIdent downto 1 do
        if (IdentifierAt(IdentIndex).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and
          (S = IdentifierAt(IdentIndex).Name) and (BlockStack[BlockStackIndex] = IdentifierAt(IdentIndex).Block) then
        begin

          for k := 0 to High(l) - 1 do
            if (IdentifierAt(IdentIndex).NumParams = l[k].NumParams) and (IdentifierAt(IdentIndex).UnitIndex = l[k].u) and
              (IdentifierAt(IdentIndex).Block = l[k].b) then
            begin

              ok := True;

              for m := 1 to l[k].NumParams do
              begin
                if (IdentifierAt(IdentIndex).Param[m].DataType <> l[k].Param[m].DataType) or
                  (IdentifierAt(IdentIndex).Param[m].AllocElementType <> l[k].Param[m].AllocElementType) then
                begin
                  ok := False;
                  Break;
                end;


                if (IdentifierAt(IdentIndex).Param[m].DataType = l[k].Param[m].DataType) and
                  (IdentifierAt(IdentIndex).Param[m].AllocElementType = PROCVARTOK) and
                  (l[k].Param[m].AllocElementType = PROCVARTOK) and (IdentifierAt(IdentIndex).Param[m].NumAllocElements shr
                  16 <> l[k].Param[m].NumAllocElements shr 16) then
                begin

                  //writeln('>',IdentifierAt(IdentIndex).NumParams);//,',', l[k].Param[m].NumParams );

                  ok := False;
                  Break;

                end;

              end;

              if ok then
                Error(x, 'Overloaded functions ''' + IdentifierAt(IdentIndex).Name + ''' have the same parameter list');

            end;

          k := High(l);

          l[k].NumParams := IdentifierAt(IdentIndex).NumParams;
          l[k].Param := IdentifierAt(IdentIndex).Param;
          l[k].u := IdentifierAt(IdentIndex).UnitIndex;
          l[k].b := IdentifierAt(IdentIndex).Block;

          SetLength(l, k + 2);

          addOverlay(IdentifierAt(IdentIndex).UnitIndex, IdentifierAt(IdentIndex).Block, IdentifierAt(IdentIndex).isOverload);
        end;

    end;// for

    for i := 0 to High(ov) - 1 do
      if ov[i].j > 1 then
        if ov[i].i <> ov[i].j then
          Error(x, 'Not all declarations of ' + IdentifierAt(NumIdent).Name + ' are declared with OVERLOAD');

    SetLength(l, 0);
    SetLength(ov, 0);

  end;  //TestIdentProc


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure AddCallGraphChild(ParentBlock, ChildBlock: Integer);
  begin

    if ParentBlock <> ChildBlock then
    begin

      Inc(CallGraph[ParentBlock].NumChildren);
      CallGraph[ParentBlock].ChildBlock[CallGraph[ParentBlock].NumChildren] := ChildBlock;

    end;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure asm65separator(a: Boolean = True);
  begin

    if a then asm65;

    asm65('; ' + StringOfChar('-', 60));

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function GetStackVariable(n: Byte): TString;
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


  procedure a65(code: code65; Value: Int64 = 0; Kind: Byte = CONSTANT; Size: Byte = 4; IdentIndex: Integer = 0);
  var
    v: Byte;
    svar: String;
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

      //       __je: asm65(#9'beq *+5');          // =
      //      __jne: asm65(#9'bne *+5');          // <>
      //       __jg: begin asm65(#9'seq'); asm65(#9'bcs *+5') end;  // >
      //      __jge: asm65(#9'bcs *+5');          // >=
      //       __jl: asm65(#9'bcc *+5');          // <
      //      __jle: begin asm65(#9'bcc *+7'); asm65(#9'beq *+5') end;  // <=

      __addBX: asm65(#9'inx');
      __subBX: asm65(#9'dex');

      __addAL_CL: asm65(#9'jsr addAL_CL');
      __addAX_CX: asm65(#9'jsr addAX_CX');
      __addEAX_ECX: asm65(#9'jsr addEAX_ECX');

      __subAL_CL: asm65(#9'jsr subAL_CL');
      __subAX_CX: asm65(#9'jsr subAX_CX');
      __subEAX_ECX: asm65(#9'jsr subEAX_ECX');

      __imulECX: asm65(#9'jsr imulECX');

      __movaBX_Value: begin

        if Kind = VARIABLE then
        begin          // @label

          svar := GetLocalName(IdentIndex);

          asm65(#9'mva <' + svar + GetStackVariable(0));
          asm65(#9'mva >' + svar + GetStackVariable(1));

        end
        else
        begin

          // Size:=4;

          v := Byte(Value);
          asm65(#9'mva #$' + IntToHex(Byte(v), 2) + GetStackVariable(0));

          if Size in [2, 4] then
          begin
            v := Byte(Value shr 8);
            asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(1));
          end;

          if Size = 4 then
          begin
            v := Byte(Value shr 16);
            asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(2));

            v := Byte(Value shr 24);
            asm65(#9'mva #$' + IntToHex(v, 2) + GetStackVariable(3));
          end;

        end;

      end;

    end;

  end;  //a65


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
  var
    i: Integer;
  begin

    if (Source in IntegerTypes) and (Dest in IntegerTypes) then
    begin

      i := DataSize[Dest] - DataSize[Source];

      if i > 0 then
        case i of
          1: if (Source in SignedOrdinalTypes) then  // to WORD
              asm65(#9'jsr @expandSHORT2SMALL')
            else
              asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x');

          2: if (Source in SignedOrdinalTypes) then  // to CARDINAL
              asm65(#9'jsr @expandToCARD.SMALL')
            else
            begin
              //       asm65(#9'jsr @expandToCARD.WORD');

              asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x');
            end;

          3: if (Source in SignedOrdinalTypes) then  // to CARDINAL
              asm65(#9'jsr @expandToCARD.SHORT')
            else
            begin
              //       asm65(#9'jsr @expandToCARD.BYTE');

              asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x');
              asm65(#9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x');
            end;

        end;

    end;

  end;  //ExpandParam


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure ExpandParam_m1(Dest, Source: Byte);
  (*----------------------------------------------------------------------------*)
  (*  wypelniamy zerami jesli przekazywany parametr jest mniejszy od docelowego *)
  (*----------------------------------------------------------------------------*)
  var
    i: Integer;
  begin

    if (Source in IntegerTypes) and (Dest in IntegerTypes) then
    begin

      i := DataSize[Dest] - DataSize[Source];


      if i > 0 then
        case i of
          1: if (Source in SignedOrdinalTypes) then  // to WORD
              asm65(#9'jsr @expandSHORT2SMALL1')
            else
              asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x');

          2: if (Source in SignedOrdinalTypes) then  // to CARDINAL
              asm65(#9'jsr @expandToCARD1.SMALL')
            else
            begin
              //       asm65(#9'jsr @expandToCARD1.WORD');

              asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*2,x');
              asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*3,x');
            end;

          3: if (Source in SignedOrdinalTypes) then  // to CARDINAL
              asm65(#9'jsr @expandToCARD1.SHORT')
            else
            begin
              //       asm65(#9'jsr @expandToCARD1.BYTE');

              asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*2,x');
              asm65(#9'mva #$00 :STACKORIGIN-1+STACKWIDTH*3,x');
            end;

        end;

    end;

  end;  //ExpandParam_m1


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure ExpandExpression(var ValType: Byte; RightValType, VarType: Byte; ForceMinusSign: Boolean = False);
  var
    m: Byte;
    sign: Boolean;
  begin

    if (ValType in IntegerTypes) and (RightValType in IntegerTypes) then
    begin

      if (DataSize[ValType] < DataSize[RightValType]) and ((VarType = 0) or
        (DataSize[RightValType] >= DataSize[VarType])) then
      begin
        ExpandParam_m1(RightValType, ValType);    // -1
        ValType := RightValType;        // przyjmij najwiekszy typ dla operacji
      end
      else
      begin

        if VarType in Pointers then VarType := WORDTOK;

        m := DataSize[ValType];
        if DataSize[RightValType] > m then m := DataSize[RightValType];

        if VarType = BOOLEANTOK then
          Inc(m)            // dla sytuacji np.: boolean := (shortint + shorint > 0)
        else

          if VarType <> 0 then
            if DataSize[VarType] > m then Inc(m);    // okreslamy najwiekszy wspolny typ
        //m:=DataSize[VarType];


        if (ValType in SignedOrdinalTypes) or (RightValType in SignedOrdinalTypes) or ForceMinusSign then
          sign := True
        else
          sign := False;

        case m of
          1: if sign then VarType := SHORTINTTOK
            else
              VarType := BYTETOK;
          2: if sign then VarType := SMALLINTTOK
            else
              VarType := WORDTOK;
          else
            if sign then VarType := INTEGERTOK
            else
              VarType := CARDINALTOK
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

    ExpandWord;  // (0);

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function InfoAboutSize(Size: Byte): String;
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

      2: if Ofset = 0 then
        begin
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
        end
        else
        begin
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');

          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');

          asm65(#9'asl :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'rol @');

          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        end;

      4: if Ofset = 0 then
        begin
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
        end
        else
        begin
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*3,x');
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH*2,x');

          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');

          asm65(#9'asl :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'rol @');
          asm65(#9'asl :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'rol @');

          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + '+STACKWIDTH,x');
          asm65(#9'lda :STACKORIGIN-' + IntToStr(Ofset) + ',x');
          asm65(#9'sta :STACKORIGIN-' + IntToStr(Ofset) + ',x');
        end;

    end;

  end;  //GenerateIndexShift


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

    if run_func = 0 then
    begin

      common.optimize.use := False;

      if High(OptimizeBuf) > 0 then asm65;

    end;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure StartOptimization(i: Integer);
  begin

    StopOptimization;

    common.optimize.use := True;
    common.optimize.unitIndex := TokenAt(i).UnitIndex;
    common.optimize.line := TokenAt(i).Line;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure LoadBP2(IdentIndex: Integer; svar: String);
  var
    lab: String;
  begin

    if (pos('.', svar) > 0) then
    begin

      //  lab:=copy(svar,1,pos('.', svar)-1);
      lab := ExtractName(IdentIndex, svar);

      if IdentifierAt(GetIdent(lab)).AllocElementType = RECORDTOK then
      begin

        asm65(#9'mwy ' + lab + ' :bp2');    // !!! koniecznie w ten sposob
        // !!! kolejne optymalizacje podstawia pod :BP2 -> LAB
        asm65(#9'lda :bp2');
        asm65(#9'add #' + svar + '-DATAORIGIN');
        asm65(#9'sta :bp2');
        asm65(#9'lda :bp2+1');
        asm65(#9'adc #$00');
        asm65(#9'sta :bp2+1');

      end
      else
        asm65(#9'mwy ' + svar + ' :bp2');

    end
    else
      asm65(#9'mwy ' + svar + ' :bp2');

  end;  //LoadBP2


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure Push(Value: Int64; IndirectionLevel: TIndirectionLevel; Size: Byte;
    IdentIndex: Integer = 0; par: Byte = 0);
  var
    Kind: Byte;
    NumAllocElements: Cardinal;
    svar, svara, lab: String;
  begin

    if IdentIndex > 0 then
    begin
      Kind := IdentifierAt(IdentIndex).Kind;

      if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
      begin
        Size := DataSize[IdentifierAt(IdentIndex).AllocElementType];
        NumAllocElements := 0;
      end
      else
        NumAllocElements := Elements(IdentIndex);  //IdentifierAt(IdentIndex).NumAllocElements;

      svar := GetLocalName(IdentIndex);

    end
    else
    begin
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
        asm65('; as Value $' + IntToHex(Value, 8) + ' (' + IntToStr(Value) + ')');
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

            if TestName(IdentIndex, svar) then
            begin

              lab := ExtractName(IdentIndex, svar);

              if IdentifierAt(GetIdent(lab)).AllocElementType = RECORDTOK then
              begin
                asm65(#9'lda ' + lab);
                asm65(#9'ldy ' + lab + '+1');
                asm65(#9'add #' + svar + '-DATAORIGIN');
                asm65(#9'scc');
                asm65(#9'iny');
                asm65(#9'sta' + GetStackVariable(0));
                asm65(#9'sty' + GetStackVariable(1));
              end
              else
              begin
                asm65(#9'mva ' + svar + GetStackVariable(0));
                asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
              end;

            end
            else
            begin
              asm65(#9'mva ' + svar + GetStackVariable(0));
              asm65(#9'mva ' + svar + '+1' + GetStackVariable(1));
            end;

            ExpandWord;
          end;

          4: begin
            asm65(#9'mva ' + svar + GetStackVariable(0));
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

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'add ' + ExtractName(IdentIndex, svar));
          asm65(#9'sta' + GetStackVariable(0));
          asm65(#9'lda #$00');
          asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
          asm65(#9'sta' + GetStackVariable(1));
        end
        else
        begin
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

        if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
          (NumAllocElements = 0) then
          asm65('+' + svar);  // +lda

        //  writeln(IdentifierAt(IdentIndex).PassMethod,',', IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', svar,',',ExtractName(IdentIndex, svar),',',par);

        if TestName(IdentIndex, svar) then
        begin

          if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK) and
            (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) then
            asm65(#9'mwy ' + svar + ' :bp2')
          else
            asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

        end
        else
          asm65(#9'mwy ' + svar + ' :bp2');


        if TestName(IdentIndex, svar) then
        begin

          if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK) and
            (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) then
            asm65(#9'ldy #$' + IntToHex(par, 2))
          else
            asm65(#9'ldy #' + svar + '-DATAORIGIN');

        end
        else
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

        if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
          (NumAllocElements = 0) then
          asm65('+');  // +lda

      end;


      ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2:
      begin
        asm65('; as Pointer to Array Origin');
        asm65;

        Gen;

        case Size of
          1: begin                    // PUSH BYTE

            if (NumAllocElements > 256) or (NumAllocElements in [0, 1]) then
            begin

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
                (NumAllocElements = 0) then
                asm65('+' + svar);  // +lda

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add' + GetStackVariable(0));
                asm65(#9'tay');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc' + GetStackVariable(1));
                asm65(#9'sta :bp+1');
                asm65(#9'lda (:bp),y');
                asm65(#9'sta' + GetStackVariable(0));

              end
              else
              begin

                if IdentifierAt(IdentIndex).ObjectVariable and (IdentifierAt(IdentIndex).PassMethod = VARPASSING) then
                begin

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

                end
                else
                begin

                  asm65(#9'lda ' + svar);
                  asm65(#9'add' + GetStackVariable(0));
                  asm65(#9'tay');
                  asm65(#9'lda ' + svar + '+1');
                  asm65(#9'adc' + GetStackVariable(1));
                  asm65(#9'sta :bp+1');
                  asm65(#9'lda (:bp),y');
                  asm65(#9'sta' + GetStackVariable(0));

                end;

              end;

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
                (NumAllocElements = 0) then
                asm65('+');  // +lda

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN,x');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta' + GetStackVariable(0));

              end
              else
              begin

                asm65(#9'lda' + GetStackVariable(0));
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda' + GetStackVariable(1));
                asm65(#9'adc #$00');
                asm65(#9'sta' + GetStackVariable(1));

                asm65(#9'lda ' + svara + ',y');
                asm65(#9'sta' + GetStackVariable(0));
                // =b'
              end;

            end;

            ExpandByte;
          end;

          2: begin                    // PUSH WORD

            if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
              GenerateIndexShift(WORDTOK);

            asm65;

            if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

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

              end
              else
              begin

                if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                  (IdentifierAt(IdentIndex).Value >= 0) then
                begin

                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                  asm65(#9'add' + GetStackVariable(0));
                  asm65(#9'sta :bp2');
                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                  asm65(#9'adc' + GetStackVariable(1));
                  asm65(#9'sta :bp2+1');

                end
                else
                begin

                  asm65(#9'lda ' + svar);
                  asm65(#9'add' + GetStackVariable(0));
                  asm65(#9'sta :bp2');
                  asm65(#9'lda ' + svar + '+1');
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

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN,x');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta' + GetStackVariable(0));
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta' + GetStackVariable(1));

              end
              else
              begin

                asm65(#9'lda' + GetStackVariable(0));
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda' + GetStackVariable(1));
                asm65(#9'adc #$00');
                asm65(#9'sta' + GetStackVariable(1));

                asm65(#9'lda ' + svara + ',y');
                asm65(#9'sta' + GetStackVariable(0));

                if IdentifierAt(IdentIndex).isStriped then
                  asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
                else
                  asm65(#9'lda ' + svara + '+1,y');

                asm65(#9'sta' + GetStackVariable(1));
                // =w'
              end;

            end;

            ExpandWord;
          end;

          4: begin                      // PUSH CARDINAL

            if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
              GenerateIndexShift(CARDINALTOK);

            asm65;

            if (NumAllocElements * 4 > 256) or (NumAllocElements in [0, 1]) then
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'lda' + GetStackVariable(0));
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda' + GetStackVariable(1));
                asm65(#9'adc #$00');
                asm65(#9'sta' + GetStackVariable(1));

                asm65(#9'lda ' + svara + ',y');
                asm65(#9'sta' + GetStackVariable(0));
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9'sta' + GetStackVariable(1));
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9'sta' + GetStackVariable(2));
                asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                asm65(#9'sta' + GetStackVariable(3));

              end
              else
              begin

                if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                  (IdentifierAt(IdentIndex).Value >= 0) then
                begin

                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                  asm65(#9'add' + GetStackVariable(0));
                  asm65(#9'sta :bp2');
                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                  asm65(#9'adc' + GetStackVariable(1));
                  asm65(#9'sta :bp2+1');

                end
                else
                begin

                  asm65(#9'lda ' + svar);
                  asm65(#9'add' + GetStackVariable(0));
                  asm65(#9'sta :bp2');
                  asm65(#9'lda ' + svar + '+1');
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

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

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

              end
              else
              begin

                asm65(#9'lda' + GetStackVariable(0));
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda' + GetStackVariable(1));
                asm65(#9'adc #$00');
                asm65(#9'sta' + GetStackVariable(1));

                asm65(#9'lda ' + svara + ',y');
                asm65(#9'sta' + GetStackVariable(0));

                if IdentifierAt(IdentIndex).isStriped then
                begin

                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                  asm65(#9'sta' + GetStackVariable(1));
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                  asm65(#9'sta' + GetStackVariable(2));
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                  asm65(#9'sta' + GetStackVariable(3));

                end
                else
                begin

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


      ASPOINTERTOARRAYRECORD:                  // array [0..X] of ^record
      begin
        asm65('; as Pointer to Array ^Record');
        asm65;

        Gen;

        asm65(#9'lda' + GetStackVariable(0));

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'add ' + ExtractName(IdentIndex, svar));
          asm65(#9'sta :TMP');
          asm65(#9'lda' + GetStackVariable(1));
          asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
          asm65(#9'sta :TMP+1');
        end
        else
        begin
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


      ASPOINTERTOARRAYRECORDTOSTRING:                  // array_of_pointer_to_record[index].string
      begin
        asm65('; as Pointer to Array ^Record to String');
        asm65;

        Gen;

        asm65(#9'lda' + GetStackVariable(0));

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'add ' + ExtractName(IdentIndex, svar));
          asm65(#9'sta :bp2');
          asm65(#9'lda' + GetStackVariable(1));
          asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
          asm65(#9'sta :bp2+1');
        end
        else
        begin
          asm65(#9'add ' + svar);
          asm65(#9'sta :bp2');
          asm65(#9'lda' + GetStackVariable(1));
          asm65(#9'adc ' + svar + '+1');
          asm65(#9'sta :bp2+1');
        end;

        asm65(#9'ldy #$00');
        asm65(#9'lda (:bp2),y');

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'add #' + svar + '-DATAORIGIN');
        end
        else
          asm65(#9'add #$' + IntToHex(par, 2));

        asm65(#9'sta' + GetStackVariable(0));

        asm65(#9'iny');
        asm65(#9'lda (:bp2),y');
        asm65(#9'adc #$00');
        asm65(#9'sta' + GetStackVariable(1));

      end;


      ASPOINTERTORECORDARRAYORIGIN:                  // record^.array[i]
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


      ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN:              // record_array[index].array[i]
      begin

        if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
        begin

          if TestName(IdentIndex, svar) then
          begin
            asm65(#9'lda ' + ExtractName(IdentIndex, svar));
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :TMP');
            asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :TMP+1');
          end
          else
          begin
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

        end
        else
        begin

          asm65(#9'ldy :STACKORIGIN-1,x');
          //   asm65(#9'lda adr.' + svar + ',y');
          asm65(#9'lda ' + svara + ',y');
          asm65(#9'sta :bp2');
          //   asm65(#9'lda adr.' + svar + '+1,y');
          asm65(#9'lda ' + svara + '+1,y');
          asm65(#9'sta :bp2+1');

        end;

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'add #$' + IntToHex(par, 2));
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

  end;  //Push


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure SaveToSystemStack(cnt: Integer);
  var
    i: Integer;
  begin
    // asm65;
    // asm65('; Save conditional expression');    //at expression stack top onto the system :STACK');

    Gen;
    Gen;
    Gen;            // push dword ptr [bx]

    if Pass = CODEGENERATIONPASS then
      for i in IFTmpPosStack do
        if i = cnt then
        begin
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN,x');

          Break;
        end;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure RestoreFromSystemStack(cnt: Integer);
  var
    i: Integer;
  begin
    //asm65;
    //asm65('; Restore conditional expression');

    Gen;
    Gen;
    Gen;            // add bx, 4

    asm65(#9'lda IFTMP_' + IntToHex(cnt, 4));

    if Pass = CALLDETERMPASS then
    begin

      i := High(IFTmpPosStack);

      IFTmpPosStack[i] := cnt;

      SetLength(IFTmpPosStack, i + 2);

    end;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure RemoveFromSystemStack;
  begin

    Gen;
    Gen;            // pop :eax

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

        asm65(#9'@openfile ' + IdentifierAt(IdentIndex).Name + ', #' + IntToStr(Ord(Code)));

      ioFileMode:

        asm65(#9'@openfile ' + IdentifierAt(IdentIndex).Name + ', MAIN.SYSTEM.FileMode');

      ioClose:

        asm65(#9'@closefile ' + IdentifierAt(IdentIndex).Name);

    end;

    asm65(#9'pla:tax');
    asm65;

  end;  //GenerateFileOpen


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateFileRead(IdentIndex: Integer; Code: ioCode; NumParams: Integer = 0);
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
          asm65(#9'@readfile ' + IdentifierAt(IdentIndex).Name + ', #' + IntToStr(Ord(Code) or $80))
        else
          asm65(#9'@readfile ' + IdentifierAt(IdentIndex).Name + ', #' + IntToStr(Ord(Code)));

    end;

    asm65(#9'pla:tax');
    asm65;

  end;  //GenerateFileRead


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateIncDec(IndirectionLevel: TIndirectionLevel; ExpressionType: Byte;
    Down: Boolean; IdentIndex: Integer);
  var
    b, c, svar, svara: String;
    NumAllocElements: Cardinal;
  begin

    //svar := GetLocalName(IdentIndex);
    //NumAllocElements := Elements(IdentIndex);

    if IdentIndex > 0 then
    begin

      if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
      begin
        NumAllocElements := 0;
      end
      else
        NumAllocElements := Elements(IdentIndex); //IdentifierAt(IdentIndex).NumAllocElements;

      svar := GetLocalName(IdentIndex);

    end
    else
    begin
      NumAllocElements := 0;
      svar := '';
    end;

    svara := svar;
    if pos('.', svar) > 0 then
      svara := GetLocalName(IdentIndex, 'adr.')
    else
      svara := 'adr.' + svar;


    if Down then
    begin
      //asm65;
      //asm65('; Dec(var X [ ; N: int ] ) -> ' + InfoAboutToken(ExpressionType));

      //  a:='sbb';
      b := 'sub';
      c := 'sbc';

    end
    else
    begin
      //asm65;
      //asm65('; Inc(var X [ ; N: int ] ) -> ' + InfoAboutToken(ExpressionType));

      //  a:='adb';
      b := 'add';
      c := 'adc';

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

            if (NumAllocElements > 256) or (NumAllocElements in [0, 1]) then
            begin

              if (IdentIndex > 0) and (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'tay');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp+1');

                asm65(#9'lda (:bp),y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta (:bp),y');

              end
              else
              begin

                asm65(#9'lda ' + svar);
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'tay');
                asm65(#9'lda ' + svar + '+1');
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp+1');

                asm65(#9'lda (:bp),y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta (:bp),y');

              end;

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda (:bp2),y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta (:bp2),y');

              end
              else
              begin
{
        asm65(#9'ldy :STACKORIGIN-1,x');
        asm65(#9'lda '+svara+',y');
        asm65(#9 + b + ' :STACKORIGIN,x');
        asm65(#9'sta '+svara+',y');
}
                asm65(#9'lda <' + svara);
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'tay');

                asm65(#9'lda >' + svara);
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp+1');

                asm65(#9'lda (:bp),y');
                asm65(#9 + b + ' :STACKORIGIN,x');
                asm65(#9'sta (:bp),y');

              end;

            end;

          end;

          2: if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
            begin

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

            end
            else
            begin

              if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
              begin

                if IdentifierAt(IdentIndex).isStriped then
                begin

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

                end
                else
                begin

                  if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                    (IdentifierAt(IdentIndex).Value >= 0) then
                  begin

                    asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                    asm65(#9'add :STACKORIGIN-1,x');
                    asm65(#9'sta :bp2');
                    asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                    asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                    asm65(#9'sta :bp2+1');

                  end
                  else
                  begin

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

              end
              else
              begin

                if IdentifierAt(IdentIndex).isStriped then
                begin

                  asm65(#9'ldy :STACKORIGIN-1,x');
                  asm65(#9'lda ' + svara + ',y');
                  asm65(#9 + b + ' :STACKORIGIN,x');
                  asm65(#9'sta ' + svara + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(NumAllocElements) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y');

                end
                else
                begin

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

          4: if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
            begin

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

            end
            else
            begin

              if (NumAllocElements * 4 > 256) or (NumAllocElements in [0, 1]) then
              begin

                if IdentifierAt(IdentIndex).isStriped then
                begin

                  asm65(#9'lda :STACKORIGIN-1,x');
                  asm65(#9'add #$00');
                  asm65(#9'tay');
                  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'adc #$00');
                  asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                  asm65(#9'lda ' + svara + ',y');
                  asm65(#9 + b + ' :STACKORIGIN,x');
                  asm65(#9'sta ' + svara + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

                end
                else
                begin

                  if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                    (IdentifierAt(IdentIndex).Value >= 0) then
                  begin

                    asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                    asm65(#9'add :STACKORIGIN-1,x');
                    asm65(#9'sta :bp2');
                    asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                    asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                    asm65(#9'sta :bp2+1');

                  end
                  else
                  begin

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

              end
              else
              begin

                if IdentifierAt(IdentIndex).isStriped then
                begin

                  asm65(#9'ldy :STACKORIGIN-1,x');
                  asm65(#9'lda ' + svara + ',y');
                  asm65(#9 + b + ' :STACKORIGIN,x');
                  asm65(#9'sta ' + svara + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*2,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                  asm65(#9'lda ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');
                  asm65(#9 + c + ' :STACKORIGIN+STACKWIDTH*3,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

                end
                else
                begin

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
  end;  //GenerateIncDec


  procedure GenerateAssignment(IndirectionLevel: TIndirectionLevel; Size: Byte; IdentIndex: Integer;
    Param: String = ''; ParamY: String = '');
  var
    NumAllocElements: Cardinal;
    IdentTemp: Integer;
    svar, svara: String;


    procedure LoadRegisterY;
    begin

      if ParamY <> '' then
        asm65(#9'ldy #' + ParamY)
      else
        if pos('.', IdentifierAt(IdentIndex).Name) > 0 then
        begin

          if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and not (IdentifierAt(IdentIndex).AllocElementType in
            [UNTYPETOK, PROCVARTOK]) then
            asm65(#9'ldy #$00')
          else
            asm65(#9'ldy #' + svar + '-DATAORIGIN');

        end
        else
          asm65(#9'ldy #$00');

    end;

  begin

    if IdentIndex > 0 then
    begin

      if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
      begin
        Size := DataSize[IdentifierAt(IdentIndex).AllocElementType];
        NumAllocElements := 0;
      end
      else
        NumAllocElements := Elements(IdentIndex);

      svar := GetLocalName(IdentIndex);
    end
    else
    begin
      svar := Param;
      NumAllocElements := 0;
    end;

    svara := svar;

    if pos('.', svar) > 0 then
      svara := GetLocalName(IdentIndex, 'adr.')
    else
      svara := 'adr.' + svar;

    asm65separator;

    asm65;
    asm65('; Generate Assignment for' + InfoAboutSize(Size));

    Gen;
    Gen;
    Gen;          // mov :eax, [bx]


    case IndirectionLevel of

      ASPOINTERTOARRAYRECORD:            // array_of_record_pointers[index]
      begin
        asm65('; as Pointer to Array ^Record');


        if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
        begin

          if TestName(IdentIndex, svar) then
          begin

            IdentTemp := GetIdent(ExtractName(IdentIndex, svar));
            if (IdentTemp > 0) and (IdentifierAt(IdentTemp).DataType = POINTERTOK) and
              (IdentifierAt(IdentTemp).AllocElementType = RECORDTOK) and (IdentifierAt(IdentTemp).NumAllocElements_ > 1) and
              (IdentifierAt(IdentTemp).NumAllocElements_ <= 128) then
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

            end
            else
            begin
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

          end
          else
          begin
            asm65(#9'lda ' + svar);
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :TMP');
            asm65(#9'lda ' + svar + '+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :TMP+1');

            asm65(#9'ldy #$00');
            asm65(#9'lda (:TMP),y');
            asm65(#9'sta :bp2');
            asm65(#9'iny');
            asm65(#9'lda (:TMP),y');
            asm65(#9'sta :bp2+1');

          end;

        end
        else
        begin

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
          1: begin                    // PULL BYTE

            if (NumAllocElements > 256) or (NumAllocElements in [0, 1]) then
            begin

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
                (NumAllocElements = 0) then
                asm65('-' + svar);  // -sta

              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                (IdentifierAt(IdentIndex).Value >= 0) then
              begin

                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                asm65(#9'add :STACKORIGIN-1,x');
                asm65(#9'tay');
                asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'sta :bp+1');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta (:bp),y');

              end
              else
              begin

                if IdentifierAt(IdentIndex).ObjectVariable and (IdentifierAt(IdentIndex).PassMethod = VARPASSING) then
                begin

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

                end
                else
                begin

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


              if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
                (NumAllocElements = 0) then
                asm65('-');  // -sta

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta (:bp2),y');

              end
              else
              begin

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

          2: begin                    // PULL WORD

            if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
              GenerateIndexShift(WORDTOK, 1);

            if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

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

              end
              else
              begin

                if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                  (IdentifierAt(IdentIndex).Value >= 0) then
                begin

                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                  asm65(#9'add :STACKORIGIN-1,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');

                end
                else
                begin

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

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta (:bp2),y');

              end
              else
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

                if IdentifierAt(IdentIndex).isStriped then
                  asm65(#9'sta ' + svara + '+' + IntToStr(NumAllocElements) + ',y')
                else
                  asm65(#9'sta ' + svara + '+1,y');
                // w='
              end;

            end;

            a65(__subBX);
            a65(__subBX);

          end;

          4: begin                    // PULL CARDINAL

            if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
              GenerateIndexShift(CARDINALTOK, 1);

            if (NumAllocElements * 4 > 256) or (NumAllocElements in [0, 1]) then
            begin

              if IdentifierAt(IdentIndex).isStriped then
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

              end
              else
              begin

                if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).idType = ARRAYTOK) and
                  (IdentifierAt(IdentIndex).Value >= 0) then
                begin

                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2));
                  asm65(#9'add :STACKORIGIN-1,x');
                  asm65(#9'sta :bp2');
                  asm65(#9'lda #$' + IntToHex(Byte(IdentifierAt(IdentIndex).Value shr 8), 2));
                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                  asm65(#9'sta :bp2+1');

                end
                else
                begin

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
                asm65(#9'iny');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta (:bp2),y');
                asm65(#9'iny');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta (:bp2),y');

              end;

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

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

              end
              else
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta ' + svara + ',y');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');

                if IdentifierAt(IdentIndex).isStriped then
                begin

                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements)) + ',y');
                  asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 2)) + ',y');
                  asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                  asm65(#9'sta ' + svara + '+' + IntToStr(Integer(NumAllocElements * 3)) + ',y');

                end
                else
                begin

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

            if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
            begin

              asm65(#9'lda ' + svar);
              asm65(#9'add :STACKORIGIN-1,x');
              asm65(#9'sta :bp2');
              asm65(#9'lda ' + svar + '+1');
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

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda (:bp2),y');
                asm65(#9'pha');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta :bp2+1');
                asm65(#9'pla');
                asm65(#9'sta :bp2');

              end
              else
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda ' + svara + ',y');
                asm65(#9'sta :bp2');
                asm65(#9'lda ' + svara + '+1,y');
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

            if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
            begin

              asm65(#9'lda ' + svar);
              asm65(#9'add :STACKORIGIN-1,x');
              asm65(#9'sta :bp2');
              asm65(#9'lda ' + svar + '+1');
              asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
              asm65(#9'sta :bp2+1');

              asm65(#9'ldy #$00');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta @move.dst');
              asm65(#9'iny');
              asm65(#9'lda (:bp2),y');
              asm65(#9'sta @move.dst+1');

            end
            else
            begin

              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
              begin

                LoadBP2(IdentIndex, svar);

                asm65(#9'ldy :STACKORIGIN-1,x');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta @move.dst');
                asm65(#9'iny');
                asm65(#9'lda (:bp2),y');
                asm65(#9'sta @move.dst+1');

              end
              else
              begin

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add #$00');
                asm65(#9'tay');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc #$00');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'lda ' + svara + ',y');
                asm65(#9'sta @move.dst');
                asm65(#9'lda ' + svara + '+1,y');
                asm65(#9'sta @move.dst+1');

              end;

            end;

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @move.src');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @move.src+1');

            if IdentifierAt(IdentIndex).NestedNumAllocElements > 0 then
            begin

              asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NestedNumAllocElements));
              asm65(#9'sta @move.cnt');
              asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NestedNumAllocElements));
              asm65(#9'sta @move.cnt+1');

              asm65(#9'jsr @move');

              if IdentifierAt(IdentIndex).NestedNumAllocElements < 256 then
              begin
                asm65(#9'ldy #$00');
                asm65(#9'lda #' + IntToStr(IdentifierAt(IdentIndex).NestedNumAllocElements - 1));
                asm65(#9'cmp (@move.src),y');
                asm65(#9'scs');
                asm65(#9'sta (@move.dst),y');
              end;

            end
            else
            begin

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


      ASPOINTERTOARRAYRECORDTOSTRING:                  // array_of_pointer_to_record[index].string
      begin

        Gen;

        asm65(#9'lda :STACKORIGIN-1,x');

        if TestName(IdentIndex, svar) then
        begin
          asm65(#9'add ' + ExtractName(IdentIndex, svar));
          asm65(#9'sta :bp2');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'adc ' + ExtractName(IdentIndex, svar) + '+1');
          asm65(#9'sta :bp2+1');
        end
        else
        begin
          asm65(#9'add ' + svar);
          asm65(#9'sta :bp2');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'adc ' + svar + '+1');
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

        asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements));
        asm65(#9'sta @move.cnt');
        asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements));
        asm65(#9'sta @move.cnt+1');

        asm65(#9'jsr @move');

        a65(__subBX);
        a65(__subBX);

      end;


      ASPOINTERTORECORDARRAYORIGIN:            // record^.array[i]
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


      ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN:        // record_array[index].array[i]
      begin

        asm65(#9'dex');              // maksymalnie mozemy uzyc :STACKORIGIN-1 lub :STACKORIGIN+1, pomagamy przez DEX/INX

        if (NumAllocElements * 2 > 256) or (NumAllocElements in [0, 1]) then
        begin

          if TestName(IdentIndex, svar) then
          begin
            asm65(#9'lda ' + ExtractName(IdentIndex, svar));
            asm65(#9'add :STACKORIGIN-1,x');
            asm65(#9'sta :TMP');
            asm65(#9'lda ' + ExtractName(IdentIndex, svar) + '+1');
            asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
            asm65(#9'sta :TMP+1');
          end
          else
          begin
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

        end
        else
        begin
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

        if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
          (NumAllocElements = 0) then
          asm65('-' + svar);  // -sta

        //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,' / ',svar ,' / ', UnitName[IdentifierAt(IdentIndex).UnitIndex].Name,',',svar.LastIndexOf('.'));

        if TestName(IdentIndex, svar) then
        begin

          if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and not (IdentifierAt(IdentIndex).AllocElementType in
            [UNTYPETOK, PROCVARTOK]) then
            asm65(#9'mwy ' + svar + ' :bp2')
          else
            asm65(#9'mwy ' + ExtractName(IdentIndex, svar) + ' :bp2');

        end
        else
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

        if (IdentifierAt(IdentIndex).isAbsolute) and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
          (NumAllocElements = 0) then
          asm65('-');  // -sta

        a65(__subBX);

      end;


      ASPOINTER:
      begin
        asm65('; as Pointer');

        case Size of
          1: begin
            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta ' + svar);
          end;

          2: begin
            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta ' + svar);
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta ' + svar + '+1');
          end;

          4: begin
            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta ' + svar);
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta ' + svar + '+1');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta ' + svar + '+2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'sta ' + svar + '+3');
          end;
        end;

        a65(__subBX);

      end;

    end;// case

    StopOptimization;

  end;  //GenerateAssignment


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateReturn(IsFunction, isInt, isInl, isOvr: Boolean);
  var
    yes: Boolean;
  begin
    Gen;            // ret

    yes := True;

    if not isInt then        // not Interrupt
      if not IsFunction then
      begin
        asm65('@exit');

        if not isInl then
        begin
          asm65(#9'.ifdef @new');      // @FreeMem
          asm65(#9'lda <@VarData');
          asm65(#9'sta :ztmp');
          asm65(#9'lda >@VarData');
          asm65(#9'ldy #@VarDataSize-1');
          asm65(#9'jmp @FreeMem');
          asm65(#9'els');
          asm65(#9'rts', '; ret');
          asm65(#9'eif');
        end;

        yes := False;
      end;

    if yes and (isInl = False) then
      if isInt then
        asm65(#9'rti', '; ret')
      else
        asm65(#9'rts', '; ret');

    asm65('.endl');

    if isOvr then
    begin
      asm65('.endl', '; overload');
    end;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateIfThenCondition;
  begin
    //asm65;
    //asm65('; If Then Condition');

    Gen;
    Gen;
    Gen;                // mov :eax, [bx]

    a65(__subBX);

    asm65(#9'lda :STACKORIGIN+1,x');
    asm65(#9'bne *+5');

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateElseCondition;
  begin
    //asm65;
    //asm65('; else condition');

    Gen;
    Gen;
    Gen;                // mov :eax, [bx]

    asm65(#9'beq *+5');

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
        Gen;
        Gen;                // je +3   =

        asm65(#9'beq @+');
      end;

      NETOK, 0:
      begin
        Gen;
        Gen;                // jne +3  <>

        asm65(#9'bne @+');
      end;

      GTTOK:
      begin
        Gen;
        Gen;                // jg +3   >

        asm65(#9'seq');

        if ValType in (RealTypes + SignedOrdinalTypes) then
          asm65(#9'bpl @+')
        else
          asm65(#9'bcs @+');

      end;

      GETOK:
      begin
        Gen;
        Gen;                // jge +3  >=

        if ValType in (RealTypes + SignedOrdinalTypes) then
          asm65(#9'bpl @+')
        else
          asm65(#9'bcs @+');

      end;

      LTTOK:
      begin
        Gen;
        Gen;                // jl +3   <

        if ValType in (RealTypes + SignedOrdinalTypes) then
          asm65(#9'bmi @+')
        else
          asm65(#9'bcc @+');

      end;

      LETOK:
      begin
        Gen;
        Gen;                // jle +3  <=

        if ValType in (RealTypes + SignedOrdinalTypes) then
        begin
          asm65(#9'bmi @+');
          asm65(#9'beq @+');
        end
        else
        begin
          asm65(#9'bcc @+');
          asm65(#9'beq @+');
        end;

      end;

    end;  // case

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateForToDoCondition(ValType: Byte; Down: Boolean; IdentIndex: Integer);
  var
    svar: String;
    CounterSize: Byte;
  begin

    svar := GetLocalName(IdentIndex);
    CounterSize := DataSize[ValType];

    asm65(';' + InfoAboutSize(CounterSize));

    Gen;
    Gen;
    Gen;            // mov :ecx, [bx]

    a65(__subBX);

    case CounterSize of

      1: begin
        ExpandByte;

        if ValType = SHORTINTTOK then
        begin    // @cmpFor_SHORTINT

          asm65(#9'lda ' + svar);
          asm65(#9'sub :STACKORIGIN+1,x');
          asm65(#9'svc');
          asm65(#9'eor #$80');

        end
        else
        begin

          asm65(#9'lda ' + svar);
          asm65(#9'cmp :STACKORIGIN+1,x');

        end;

      end;

      2: begin
        ExpandWord;

        if ValType = SMALLINTTOK then
        begin    // @cmpFor_SMALLINT

          asm65(#9'.LOCAL');
          asm65(#9'lda ' + svar + '+1');
          asm65(#9'sub :STACKORIGIN+1+STACKWIDTH,x');
          asm65(#9'bne L4');
          asm65(#9'lda ' + svar);
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

        end
        else
        begin

          asm65(#9'lda ' + svar + '+1');
          asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
          asm65(#9'bne @+');
          asm65(#9'lda ' + svar);
          asm65(#9'cmp :STACKORIGIN+1,x');
          asm65('@');

        end;

      end;

      4: begin

        if ValType = INTEGERTOK then
        begin      // @cmpFor_INT

          asm65(#9'.LOCAL');
          asm65(#9'lda ' + svar + '+3');
          asm65(#9'sub :STACKORIGIN+1+STACKWIDTH*3,x');
          asm65(#9'bne L4');
          asm65(#9'lda ' + svar + '+2');
          asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
          asm65(#9'bne L1');
          asm65(#9'lda ' + svar + '+1');
          asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
          asm65(#9'bne L1');
          asm65(#9'lda ' + svar);
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

        end
        else
        begin

          asm65(#9'lda ' + svar + '+3');
          asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*3,x');
          asm65(#9'bne @+');
          asm65(#9'lda ' + svar + '+2');
          asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH*2,x');
          asm65(#9'bne @+');
          asm65(#9'lda ' + svar + '+1');
          asm65(#9'cmp :STACKORIGIN+1+STACKWIDTH,x');
          asm65(#9'bne @+');
          asm65(#9'lda ' + svar);
          asm65(#9'cmp :STACKORIGIN+1,x');
          asm65('@');

        end;

      end;

    end;


    Gen;
    Gen;
    Gen;              // cmp :eax, :ecx

    if Down then
    begin

      if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then
        asm65(#9'bpl *+5')
      else
        asm65(#9'bcs *+5');

    end

    else
    begin

      if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then
      begin
        asm65(#9'bmi *+7');
        asm65(#9'beq *+5');
      end
      else
      begin
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

    Gen;                // nop   ; jump to the IF..THEN block end will be inserted here
    Gen;                // nop   ; !!!
    Gen;                // nop   ; !!!

    asm65(#9'jmp l_' + IntToHex(CodeSize, 4));

  end;


  procedure GenerateCaseEqualityCheck(Value: Int64; SelectorType: Byte; Join: Boolean; CaseLocalCnt: Integer);
  begin
    Gen;
    Gen;              // cmp :ecx, Value

    case DataSize[SelectorType] of

      1: if join = False then
        begin
          asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

          if Value <> 0 then asm65(#9'cmp #$' + IntToHex(Byte(Value), 2));
        end
        else
          asm65(#9'cmp #$' + IntToHex(Byte(Value), 2));

      // 2: asm65(#9'cpw :STACKORIGIN,x #$'+IntToHex(Value, 4));
      // 4: asm65(#9'cpd :STACKORIGIN,x #$'+IntToHex(Value, 4));
    end;

    asm65(#9'beq @+');

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateCaseRangeCheck(Value1, Value2: Int64; SelectorType: Byte; Join: Boolean; CaseLocalCnt: Integer);
  begin

    Gen;
    Gen;              // cmp :ecx, Value1

    if (SelectorType in [BYTETOK, CHARTOK, ENUMTYPE]) and (Value1 >= 0) and (Value2 >= 0) then
    begin

      if (Value1 = 0) and (Value2 = 255) then
      begin

        asm65(#9'jmp @+');
      end
      else
        if Value1 = 0 then
        begin

          if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

          if Value2 = 127 then
          begin
            asm65(#9'cmp #$00');
            asm65(#9'bpl @+');
          end
          else
          begin
            asm65(#9'cmp #$' + IntToHex(Value2 + 1, 2));
            asm65(#9'bcc @+');
          end;

        end
        else
          if Value2 = 255 then
          begin

            if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

            if Value1 = 128 then
            begin
              asm65(#9'cmp #$00');
              asm65(#9'bmi @+');
            end
            else
            begin
              asm65(#9'cmp #$' + IntToHex(Value1, 2));
              asm65(#9'bcs @+');
            end;

          end
          else
            if Value1 = Value2 then
            begin

              if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

              asm65(#9'cmp #$' + IntToHex(Value1, 2));
              asm65(#9'beq @+');
            end
            else
            begin

              if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

              asm65(#9'clc', '; clear carry for add');
              asm65(#9'adc #$FF-$' + IntToHex(Value2, 2), '; make m = $FF');
              asm65(#9'adc #$' + IntToHex(Value2, 2) + '-$' + IntToHex(Value1, 2) + '+1',
                '; carry set if in range n to m');
              asm65(#9'bcs @+');
            end;

    end
    else
    begin

      case DataSize[SelectorType] of
        1: begin
          if join = False then asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

          asm65(#9'cmp #' + IntToStr(Byte(Value1)));
        end;

      end;

      GenerateRelationOperation(LTTOK, SelectorType);

      case DataSize[SelectorType] of
        1: begin
          //       asm65(#9'lda @CASETMP_' + IntToHex(CaseLocalCnt, 4));

          asm65(#9'cmp #' + IntToStr(Byte(Value2)));
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


  procedure GenerateCaseStatementEpilog(cnt: Integer);
  var
    StoredCodeSize: Integer;
  begin

    resetOpty;

    asm65(#9'jmp a_' + IntToHex(cnt, 4));

    asm65('s_' + IntToHex(CodeSize, 4));        // opt_TEMP_TAIL_CASE


    StoredCodeSize := CodeSize;

    Gen;                // nop   ; jump to the CASE block end will be inserted here
    // Gen;                // nop
    // Gen;                // nop

    asm65('l_' + IntToHex(CodePosStack[CodePosStackTop] + 3, 4));

    Gen;

    CodePosStack[CodePosStackTop] := StoredCodeSize;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateCaseEpilog(NumCaseStatements: Integer; cnt: Integer);
  begin

    resetOpty;

    //asm65;
    //asm65('; GenerateCaseEpilog');

    Dec(CodePosStackTop, NumCaseStatements);

    if not OutputDisabled then Inc(CodeSize, NumCaseStatements);

    asm65('a_' + IntToHex(cnt, 4));

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateAsmLabels(l: Integer);
  //var i: integer;
  begin

    if not OutputDisabled then
      if Pass = CODEGENERATIONPASS then
      begin
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
  var
    CodePos: Word;
  begin

    ResetOpty;

    // asm65(#13#10'; IfThenEpilog');

    CodePos := CodePosStack[CodePosStackTop];
    Dec(CodePosStackTop);

    GenerateAsmLabels(CodePos + 3);

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

    Gen;                // jmp ReturnPos

    asm65(#9'jmp l_' + IntToHex(ReturnPos, 4));

    GenerateAsmLabels(CodePos + 3);

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
  var
    ReturnPos: Word;
  begin

    ResetOpty;

    ReturnPos := CodePosStack[CodePosStackTop];
    Dec(CodePosStackTop);

    Gen;

    asm65(#9'jmp l_' + IntToHex(ReturnPos, 4));

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateForToDoProlog;
  begin

    GenerateWhileDoProlog;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateForToDoEpilog(ValType: Byte; Down: Boolean; IdentIndex: Integer = 0;
    Epilog: Boolean = True; forBPL: Byte = 0);
  var
    svar: String;
    CounterSize: Byte;
  begin

    svar := GetLocalName(IdentIndex);
    CounterSize := DataSize[ValType];

    case CounterSize of
      1: begin
        Gen;            // ... byte ptr ...
      end;
      2: begin
        Gen;            // ... word ptr ...
      end;
      4: begin
        Gen;
        Gen;            // ... dword ptr ...
      end;
    end;

    if Down then
    begin
      Gen;               // dec ...

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

    end
    else
    begin
      Gen;              // inc ...

      case CounterSize of
        1: asm65(#9'inc ' + svar);

        2: begin
          asm65(#9'inc ' + svar);        // dla optymalizacji z 'JMP L_xxxx'
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

    Gen;
    Gen;            // ... [CounterAddress]

    if Epilog then
    begin

      if ValType in [SHORTINTTOK, SMALLINTTOK, INTEGERTOK] then
      begin

        case CounterSize of
          1: begin

            if Down then
            begin
              asm65(#9'lda ' + svar);
              asm65(#9'cmp #$7f');
              asm65(#9'seq');
            end
            else
            begin
              asm65(#9'lda ' + svar);
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

      end
      else
        if Down then
        begin          // for label = exp to max(type)

          case CounterSize of

            1: if forBPL and 1 <> 0 then    // [BYTE < 128] DOWNTO 0
                asm65(#9'bmi *+5')
              else
                if forBPL and 2 <> 0 then    // BYTE DOWNTO [exp > 0]
                  asm65(#9'seq')
                else
                begin
                  asm65(#9'lda ' + svar);
                  asm65(#9'cmp #$FF');
                  asm65(#9'seq');
                end;

            2: begin
              asm65(#9'lda ' + svar + '+1');
              asm65(#9'cmp #$FF');
              asm65(#9'seq');
            end;

            4: begin
              asm65(#9'lda ' + svar + '+3');
              asm65(#9'cmp #$FF');
              asm65(#9'seq');
            end;
          end;

        end
        else
        begin

          asm65(#9'seq');

        end;

      GenerateWhileDoEpilog;
    end;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompilerTitle: String;
  begin

    Result := 'Mad Pascal Compiler version ' + title + ' [' + {$I %DATE%} + '] for MOS 6502 CPU';

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


{$i targets/generate_program_prolog.inc}


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateProgramEpilog(ExitCode: Byte);
  begin

    Gen;
    Gen;              // mov ah, 4Ch

    asm65(#9'lda #$' + IntToHex(ExitCode, 2));
    asm65(#9'jmp @halt');

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateDeclarationProlog;
  begin
    Inc(CodePosStackTop);
    CodePosStack[CodePosStackTop] := CodeSize;

    Gen;                // nop   ; jump to the IF..THEN block end will be inserted here
    Gen;                // nop   ; !!!
    Gen;                // nop   ; !!!

    asm65(#9'jmp l_' + IntToHex(CodeSize, 4));

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
    // Gen; Gen;              // mov bp, [bx]

    asm65(#9'@getline');

  end;  // GenerateRead


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateWriteString(Address: Word; IndirectionLevel: TIndirectionLevel; ValueType: Byte = INTEGERTOK);
  begin
    //Gen; Gen;              // mov ah, 09h

    asm65;

    case IndirectionLevel of

      AsBoolean:
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

          2: if ValueType = SMALLINTTOK then
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

        asm65(#9'@printSTRING #CODEORIGIN+$' + IntToHex(Address - CODEORIGIN, 4));

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

  end;  //GenerateWriteString


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
        Gen;
        Gen;
        Gen;            // neg dword ptr [bx]

        if ValType = HALFSINGLETOK then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta :STACKORIGIN,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'eor #$80');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

        end
        else
          if ValType = SINGLETOK then
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :STACKORIGIN,x');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
            asm65(#9'eor #$80');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');

          end
          else

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
        Gen;
        Gen;
        Gen;            // not dword ptr [bx]

        if ValType = BOOLEANTOK then
        begin
          //     a65(__notBOOLEAN)

          asm65(#9'ldy #1');          // !!! wymagana konwencja
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'beq @+');
          asm65(#9'dey');
          asm65('@');
          //       asm65(#9'tya');    !!! ~
          asm65(#9'sty :STACKORIGIN,x');

        end
        else
        begin

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

    //asm65;
    //asm65('; Generate Binary Operation for ' + InfoAboutToken(ResultType));

    Gen;
    Gen;
    Gen;              // mov :ecx, [bx]      :STACKORIGIN,x

    case op of

      PLUSTOK:
      begin

        if ResultType = HALFSINGLETOK then
        begin

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

        end
        else
          if ResultType = SINGLETOK then
          begin
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

          end
          else

            case DataSize[ResultType] of
              1: a65(__addAL_CL);
              2: a65(__addAX_CX);
              4: a65(__addEAX_ECX);
            end;

      end;

      MINUSTOK:
      begin

        if ResultType = HALFSINGLETOK then
        begin

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

        end
        else
          if ResultType = SINGLETOK then
          begin
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

          end
          else

            case DataSize[ResultType] of
              1: a65(__subAL_CL);
              2: a65(__subAX_CX);
              4: a65(__subEAX_ECX);
            end;

      end;

      MULTOK:
      begin

        if ResultType in RealTypes then
        begin    // Real multiplication

          case ResultType of

            SHORTREALTOK:          // Q8.8 fixed-point
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

            REALTOK:          // Q24.8 fixed-point
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

            SINGLETOK: //asm65(#9'jsr @FMUL');    // IEEE754 32bit
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

            HALFSINGLETOK:          // IEEE754 16bit
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

        end
        else
        begin          // Integer multiplication

          if ResultType in SignedOrdinalTypes then
          begin

            case ResultType of
              SHORTINTTOK: asm65(#9'jsr mulSHORTINT');
              SMALLINTTOK: asm65(#9'jsr mulSMALLINT');
              INTEGERTOK: asm65(#9'jsr mulINTEGER');
            end;

          end
          else
          begin

            case DataSize[ResultType] of
              1: asm65(#9'jsr imulBYTE');
              2: asm65(#9'jsr imulWORD');
              4: asm65(#9'jsr imulCARD');
            end;

            //       asm65(#9'jsr movaBX_EAX');

            if DataSize[ResultType] = 1 then
            begin

              asm65(#9'lda :eax');
              asm65(#9'sta :STACKORIGIN-1,x');
              asm65(#9'lda :eax+1');
              asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

            end
            else
            begin

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

        if ResultType in RealTypes then
        begin    // Real division

          case ResultType of
            SHORTREALTOK:          // Q8.8 fixed-point
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

            REALTOK:          // Q24.8 fixed-point
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

            SINGLETOK:          // IEEE754 32bit
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

            HALFSINGLETOK:          // IEEE754 16bit
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

        else            // Integer division
        begin

          if ResultType in SignedOrdinalTypes then
          begin

            case ResultType of

              SHORTINTTOK:
                if op = MODTOK then
                begin
                  //            asm65(#9'jsr SHORTINTTOK.MOD')

                  asm65(#9'lda :STACKORIGIN,x');
                  asm65(#9'sta @SHORTINT.MOD.B');

                  asm65(#9'lda :STACKORIGIN-1,x');
                  asm65(#9'sta @SHORTINT.MOD.A');

                  asm65(#9'jsr @SHORTINT.MOD');

                  asm65(#9'lda @SHORTINT.MOD.RESULT');
                  asm65(#9'sta :STACKORIGIN-1,x');

                end
                else
                begin
                  //            asm65(#9'jsr @SHORTINTTOK.DIV');

                  asm65(#9'lda :STACKORIGIN,x');
                  asm65(#9'sta @SHORTINT.DIV.B');

                  asm65(#9'lda :STACKORIGIN-1,x');
                  asm65(#9'sta @SHORTINT.DIV.A');

                  asm65(#9'jsr @SHORTINT.DIV');

                  asm65(#9'lda :eax');
                  asm65(#9'sta :STACKORIGIN-1,x');

                end;


              SMALLINTTOK:
                if op = MODTOK then
                begin
                  //            asm65(#9'jsr @SMALLINT.MOD')

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

                end
                else
                begin
                  //            asm65(#9'jsr @SMALLINT.DIV');

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
                if op = MODTOK then
                begin
                  //            asm65(#9'jsr @INTEGER.MOD')

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

                end
                else
                begin
                  //            asm65(#9'jsr @INTEGER.DIV');

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

          end
          else
          begin

            case ResultType of

              BYTETOK:
                if op = MODTOK then
                begin
                  //      asm65(#9'jsr @BYTE.MOD');

                  asm65(#9'lda :STACKORIGIN,x');
                  asm65(#9'sta @BYTE.MOD.B');

                  asm65(#9'lda :STACKORIGIN-1,x');
                  asm65(#9'sta @BYTE.MOD.A');

                  asm65(#9'jsr @BYTE.MOD');

                  asm65(#9'lda @BYTE.MOD.RESULT');
                  asm65(#9'sta :STACKORIGIN-1,x');

                end
                else
                begin
                  //      asm65(#9'jsr @BYTE.DIV');

                  asm65(#9'lda :STACKORIGIN,x');
                  asm65(#9'sta @BYTE.DIV.B');

                  asm65(#9'lda :STACKORIGIN-1,x');
                  asm65(#9'sta @BYTE.DIV.A');

                  asm65(#9'jsr @BYTE.DIV');

                  asm65(#9'lda :eax');
                  asm65(#9'sta :STACKORIGIN-1,x');

                end;

              WORDTOK:
                if op = MODTOK then
                begin
                  //          asm65(#9'jsr @WORD.MOD');

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

                end
                else
                begin
                  //      asm65(#9'jsr @WORD.DIV');

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
                if op = MODTOK then
                begin
                  //         asm65(#9'jsr @CARDINAL.MOD');

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

                end
                else
                begin
                  //      asm65(#9'jsr @CARDINAL.DIV');

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

            end;  // case

          end;  // end else begin

        end;  // if ResultType in SignedOrdinalTypes

      end;


      SHLTOK:
      begin

        if ResultType in SignedOrdinalTypes then
        begin

          case DataSize[ResultType] of

            1: begin
              asm65(#9'jsr @expandToCARD1.SHORT');
              a65(__shlEAX_CL);
            end;

            2: begin
              asm65(#9'jsr @expandToCARD1.SMALL');
              a65(__shlEAX_CL);
            end;

            4: a65(__shlEAX_CL);

          end;

        end
        else
          case DataSize[ResultType] of
            1: a65(__shlAL_CL);
            2: a65(__shlAX_CL);
            4: a65(__shlEAX_CL);
          end;

      end;


      SHRTOK:
      begin

        if ResultType in SignedOrdinalTypes then
        begin

          case DataSize[ResultType] of

            1: begin
              asm65(#9'jsr @expandToCARD1.SHORT');
              a65(__shrEAX_CL);
            end;

            2: begin
              asm65(#9'jsr @expandToCARD1.SMALL');
              a65(__shrEAX_CL);
            end;

            4: a65(__shrEAX_CL);

          end;

        end
        else
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

  end;  //GenerateBinaryOperation


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateRelationString(relation: Byte; LeftValType, RightValType: Byte;
    sLeft: Wordbool = False; sRight: Wordbool = False);
  begin

    // asm65;
    // asm65('; relation STRING');

    Gen;

    asm65(#9'ldy #1');

    Gen;

{
 if (LeftValType = POINTERTOK) and (RightValType = POINTERTOK) then begin

   asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta @cmpPCHAR.B');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR.B+1');

  asm65(#9'lda :STACKORIGIN-1,x');
  asm65(#9'sta @cmpPCHAR.A');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR.A+1');

  asm65(#9'jsr @cmpPCHAR');

 end else

 if (LeftValType = POINTERTOK) and (RightValType = STRINGPOINTERTOK) then begin

   asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta @cmpPCHAR2STRING.B');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR2STRING.B+1');

  asm65(#9'lda :STACKORIGIN-1,x');
  asm65(#9'sta @cmpPCHAR2STRING.A');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
  asm65(#9'sta @cmpPCHAR2STRING.A+1');

  asm65(#9'jsr @cmpPCHAR2STRING');

 end else
 if (LeftValType = STRINGPOINTERTOK) and (RightValType = POINTERTOK) then begin

   asm65(#9'lda :STACKORIGIN,x');
  asm65(#9'sta @cmpSTRING2PCHAR.B');
  asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
  asm65(#9'sta @cmpSTRING2PCHAR.B+1');

  asm65(#9'lda :STACKORIGIN-1,x');
  asm65(#9'sta @cmpSTRING2PCHAR.A');
  asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
  asm65(#9'sta @cmpSTRING2PCHAR.A+1');

  asm65(#9'jsr @cmpSTRING2PCHAR');

 end else
 }

    if (LeftValType = STRINGPOINTERTOK) and (RightValType = STRINGPOINTERTOK) then
    begin
      //  a65(__cmpSTRING)          // STRING ? STRING

      asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'sta @cmpSTRING.B');
      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'sta @cmpSTRING.B+1');

      asm65(#9'lda :STACKORIGIN-1,x');
      asm65(#9'sta @cmpSTRING.A');
      asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
      asm65(#9'sta @cmpSTRING.A+1');

      asm65(#9'jsr @cmpSTRING');

    end
    else
      if LeftValType = CHARTOK then
      begin
        //  a65(__cmpCHAR2STRING)        // CHAR ? STRING

        asm65(#9'lda :STACKORIGIN,x');
        asm65(#9'sta @cmpCHAR2STRING.B');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
        asm65(#9'sta @cmpCHAR2STRING.B+1');

        asm65(#9'lda :STACKORIGIN-1,x');
        asm65(#9'sta @cmpCHAR2STRING.A');

        asm65(#9'jsr @cmpCHAR2STRING');

      end
      else
        if RightValType = CHARTOK then
        begin
          //  a65(__cmpSTRING2CHAR);        // STRING ? CHAR

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta @cmpSTRING2CHAR.B');

          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'sta @cmpSTRING2CHAR.A');
          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'sta @cmpSTRING2CHAR.A+1');

          asm65(#9'jsr @cmpSTRING2CHAR');
        end;

    GenerateRelationOperation(relation, BYTETOK);

    Gen;

    asm65(#9'dey');
    asm65('@');
    // asm65(#9'tya');      !!! ~
    asm65(#9'sty :STACKORIGIN-1,x');

    a65(__subBX);

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateRelation(relation: Byte; ValType: Byte);
  begin
    // asm65;
    // asm65('; relation');

    Gen;

    if ValType = HALFSINGLETOK then
    begin

      case relation of
        EQTOK:  // =
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

        NETOK, 0:  // <>
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

        GTTOK:  // >
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

        LTTOK:  // <
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

        GETOK:  // >=
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

        LETOK:  // <=
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

    end
    else
    begin

      if ValType = SINGLETOK then
      begin

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
        begin  //a65(__cmpSHORTINT);

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
        begin  //a65(__cmpSMALLINT);

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
        begin  //a65(__cmpINT);

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
        begin  //a65(__cmpAX_CX);

          asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
          asm65(#9'cmp :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'bne @+');
          asm65(#9'lda :STACKORIGIN-1,x');
          asm65(#9'cmp :STACKORIGIN,x');
          asm65('@');

        end;

        else
        begin  //a65(__cmpEAX_ECX);          // CARDINALTOK

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

      GenerateRelationOperation(relation, ValType);

      Gen;

      asm65(#9'dey');
      asm65('@');
      //asm65(#9'tya');      !!! ~
      asm65(#9'sty :STACKORIGIN-1,x');

      a65(__subBX);

    end; // if ValType = HALFSINGLETOK

  end;  //GenerateRelation


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

  if IdentifierAt(IdentIndex).NumAllocElements_ > 0 then
   asm65(';' + t + ' Array index '+IdentifierAt(IdentIndex).Name+'[0..'+IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1)+', 0..'+IntToStr(IdentifierAt(IdentIndex).NumAllocElements_ - 1)+']')
  else
   asm65(';' + t + ' Array index '+IdentifierAt(IdentIndex).Name+'[0..'+IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1)+']');

end;
}

  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function SafeCompileConstExpression(var i: Integer; out ConstVal: Int64; out ValType: Byte;
    VarType: Byte; Err: Boolean = False; War: Boolean = True): Boolean;
  var
    j: Integer;
  begin

    j := i;

    isError := False;     // dodatkowy test
    isConst := True;

    i := CompileConstExpression(i, ConstVal, ValType, VarType, Err, War);

    Result := not isError;

    isConst := False;
    isError := False;

    if not Result then i := j;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileArrayIndex(i: Integer; IdentIndex: Integer; out VarType: Byte): Integer;
  var
    ConstVal: Int64;
    ActualParamType, ArrayIndexType, Size: Byte;
    NumAllocElements, NumAllocElements_: Cardinal;
    j: Integer;
    yes, ShortArrayIndex: Boolean;
  begin

    if common.optimize.use = False then StartOptimization(i);


    if (IdentifierAt(IdentIndex).isStriped) then
      Size := 1
    else
      Size := DataSize[IdentifierAt(IdentIndex).AllocElementType];


    ShortArrayIndex := False;

    VarType := IdentifierAt(IdentIndex).AllocElementType;

    if ((IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).IdType = DEREFERENCEARRAYTOK)) then
    begin
      NumAllocElements := IdentifierAt(IdentIndex).NestedNumAllocElements and $FFFF;
      NumAllocElements_ := IdentifierAt(IdentIndex).NestedNumAllocElements shr 16;

      if NumAllocElements_ > 0 then
      begin
        if (NumAllocElements * NumAllocElements_ > 1) and (NumAllocElements * NumAllocElements_ * Size < 256) then
          ShortArrayIndex := True;
      end
      else
        if (NumAllocElements > 1) and (NumAllocElements * Size < 256) then ShortArrayIndex := True;

    end
    else
    begin
      NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements;
      NumAllocElements_ := IdentifierAt(IdentIndex).NumAllocElements_;
    end;


    if IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK, PROCVARTOK] then NumAllocElements_ := 0;


    ActualParamType := WORDTOK;    // !!! aby dzialaly optymalizacje dla ADR.


    j := i + 2;

    if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then
    begin
      i := j;

      CheckArrayIndex(i, IdentIndex, ConstVal, ArrayIndexType);

      ArrayIndexType := WORDTOK;
      ShortArrayIndex := False;

      if NumAllocElements_ > 0 then
        Push(ConstVal * NumAllocElements_ * Size, ASVALUE, DataSize[ArrayIndexType])
      else
        Push(ConstVal * Size, ASVALUE, DataSize[ArrayIndexType]);

    end
    else
    begin
      i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);  // array index [x, ..]

      GetCommonType(i, ActualParamType, ArrayIndexType);

      case ArrayIndexType of
        SHORTINTTOK: ArrayIndexType := BYTETOK;
        SMALLINTTOK: ArrayIndexType := WORDTOK;
        INTEGERTOK: ArrayIndexType := CARDINALTOK;
      end;

      if DataSize[ArrayIndexType] = 4 then
      begin  // remove oldest bytes
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
        asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
        asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
      end;

      if DataSize[ArrayIndexType] = 1 then
      begin
        ExpandParam(WORDTOK, ArrayIndexType);
        //      ArrayIndexType := WORDTOK;
      end
      else
        ArrayIndexType := WORDTOK;

      if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0, 1])
      {or (NumAllocElements_ > 0)} then
      begin
        //        ExpandParam(WORDTOK, ArrayIndexType);
        ArrayIndexType := WORDTOK;
      end;


      if NumAllocElements_ > 0 then
      begin

        Push(Integer(NumAllocElements_ * Size), ASVALUE, DataSize[ArrayIndexType]);

        GenerateBinaryOperation(MULTOK, ArrayIndexType);

      end
      else
        if IdentifierAt(IdentIndex).isStriped = False then GenerateIndexShift(IdentifierAt(IdentIndex).AllocElementType);

    end;


    yes := False;

    if NumAllocElements_ > 0 then
    begin

      if (TokenAt(i + 1).Kind = CBRACKETTOK) and (TokenAt(i + 2).Kind <> OBRACKETTOK)
      {(TokenAt(i + 2).Kind in [ASSIGNTOK, SEMICOLONTOK])} then
      begin
        yes := False;

        Push(0, ASVALUE, DataSize[ArrayIndexType]);

        GenerateBinaryOperation(PLUSTOK, WORDTOK);

        VarType := ARRAYTOK;
      end
      else
        if TokenAt(i + 1).Kind = CBRACKETTOK then
        begin
          Inc(i);
          CheckTok(i + 1, OBRACKETTOK);
          yes := True;
        end
        else
        begin
          CheckTok(i + 1, COMMATOK);
          yes := True;
        end;

    end
    else
      CheckTok(i + 1, CBRACKETTOK);


    if {TokenAt(i + 1).Kind = COMMATOK} yes then
    begin

      j := i + 2;

      if SafeCompileConstExpression(j, ConstVal, ArrayIndexType, ActualParamType) then
      begin
        i := j;

        CheckArrayIndex_(i, IdentIndex, ConstVal, ArrayIndexType);

        ArrayIndexType := WORDTOK;
        ShortArrayIndex := False;

        Push(ConstVal * Size, ASVALUE, DataSize[ArrayIndexType]);

      end
      else
      begin
        i := CompileExpression(i + 2, ArrayIndexType, ActualParamType);  // array index [.., y]

        GetCommonType(i, ActualParamType, ArrayIndexType);

        case ArrayIndexType of
          SHORTINTTOK: ArrayIndexType := BYTETOK;
          SMALLINTTOK: ArrayIndexType := WORDTOK;
          INTEGERTOK: ArrayIndexType := CARDINALTOK;
        end;

        if DataSize[ArrayIndexType] = 4 then
        begin  // remove oldest bytes
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*2,x');
          asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
          asm65(#9'sta :STACKORIGIN+STACKWIDTH*3,x');
        end;

        if DataSize[ArrayIndexType] = 1 then
        begin
          ExpandParam(WORDTOK, ArrayIndexType);
          ArrayIndexType := WORDTOK;
        end
        else
          ArrayIndexType := WORDTOK;

        //      if (Size > 1) or (Elements(IdentIndex) > 256) or (Elements(IdentIndex) in [0,1]) {or (NumAllocElements_ > 0)} then begin
        //        ExpandParam(WORDTOK, ArrayIndexType);
        //        ArrayIndexType := WORDTOK;
        //      end;

        if IdentifierAt(IdentIndex).isStriped = False then GenerateIndexShift(IdentifierAt(IdentIndex).AllocElementType);

      end;

      GenerateBinaryOperation(PLUSTOK, WORDTOK);

    end;


    if ShortArrayIndex then
    begin

      asm65(#9'lda #$00');
      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

    end;

    //  writeln(IdentifierAt(IdentIndex).Name,',',Elements(IdentIndex));

    Result := i;

  end;  //CompileArrayIndex


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileAddress(i: Integer; out ValType, AllocElementType: Byte; VarPass: Boolean = False): Integer;
  var
    IdentIndex, IdentTemp, j: Integer;
    Name, svar, lab: String;
    NumAllocElements: Cardinal;
    rec, dereference, address: Boolean;
  begin

    Result := i;

    lab := '';

    rec := False;
    dereference := False;

    address := False;

    AllocElementType := UNTYPETOK;


    if TokenAt(i + 1).Kind = ADDRESSTOK then
    begin

      if VarPass then
        Error(i + 1, 'Can''t assign values to an address');

      address := True;

      Inc(i);
    end;


    if (TokenAt(i + 1).Kind = PCHARTOK) and (TokenAt(i + 2).Kind = OPARTOK) then
    begin

      j := CompileExpression(i + 3, ValType, POINTERTOK);

      CheckTok(j + 1, CPARTOK);

      if TokenAt(j + 2).Kind <> DEREFERENCETOK then
        Error(i + 3, 'Can''t assign values to an address');

      i := j + 1;

    end
    else

      if TokenAt(i + 1).Kind <> IDENTTOK then
        Error(i + 1, IdentifierExpected)
      else
      begin
        IdentIndex := GetIdent(TokenAt(i + 1).Name^);


        if IdentIndex > 0 then
        begin

          if not (IdentifierAt(IdentIndex).Kind in [CONSTANT, VARIABLE, PROCEDURETOK, FUNCTIONTOK,
            CONSTRUCTORTOK, DESTRUCTORTOK, ADDRESSTOK]) then
            Error(i + 1, VariableExpected)
          else
          begin

            if IdentifierAt(IdentIndex).Kind = CONSTANT then
              if not ((IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
                Error(i + 1, CantAdrConstantExp);


            //  writeln(IdentifierAt(IdentIndex).nAME,' = ',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod );


            if IdentifierAt(IdentIndex).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
            begin

              Name := GetLocalName(IdentIndex);

              if IdentifierAt(IdentIndex).isOverload then Name := Name + '.' + GetOverloadName(IdentIndex);

              a65(__addBX);
              asm65(#9'mva <' + Name + ' :STACKORIGIN,x');
              asm65(#9'mva >' + Name + ' :STACKORIGIN+STACKWIDTH,x');

              if Pass = CALLDETERMPASS then
                AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(IdentIndex).ProcAsBlock);

            end
            else

              if (TokenAt(i + 2).Kind = OBRACKETTOK) and (IdentifierAt(IdentIndex).DataType in Pointers) and
                ((IdentifierAt(IdentIndex).NumAllocElements > 0) or ((IdentifierAt(IdentIndex).NumAllocElements = 0) and
                (IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK))) then
              begin                  // array index
                Inc(i);

                // atari    // a := @tab[x,y]

                i := CompileArrayIndex(i, IdentIndex, AllocElementType);


                if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
                  NumAllocElements := 0
                else
                  NumAllocElements := Elements(IdentIndex);

                svar := GetLocalName(IdentIndex);

                if (pos('.', svar) > 0) then
                begin
                  //   lab:=copy(svar, 1, svar.IndexOf('.'));
                  lab := ExtractName(IdentIndex, svar);

                  rec := (IdentifierAt(GetIdent(lab)).AllocElementType = RECORDTOK);
                end;

                //AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',VarPass ,',',rec,',',IdentifierAt(IdentIndex).idType);

                if rec then
                begin              // record.array[]

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

                end
                else

                  if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) or (NumAllocElements *
                    DataSize[AllocElementType] > 256) or (NumAllocElements in [0, 1]) then
                  begin

                    //  writeln(IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',IdentifierAt(IdentIndex).idType );

                    asm65(#9'lda ' + svar);
                    asm65(#9'add :STACKORIGIN,x');
                    asm65(#9'sta :STACKORIGIN,x');
                    asm65(#9'lda ' + svar + '+1');
                    asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                  end
                  else
                  begin

                    //  writeln(IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',IdentifierAt(IdentIndex).idType );

                    asm65(#9'lda <' + GetLocalName(IdentIndex, 'adr.'));
                    asm65(#9'add :STACKORIGIN,x');
                    asm65(#9'sta :STACKORIGIN,x');
                    asm65(#9'lda >' + GetLocalName(IdentIndex, 'adr.'));
                    asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                  end;

                CheckTok(i + 1, CBRACKETTOK);

              end
              else
                if (IdentifierAt(IdentIndex).DataType in [FILETOK, TEXTFILETOK, RECORDTOK, OBJECTTOK] {+ Pointers}) or
                  ((IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType <> 0) and
                  (IdentifierAt(IdentIndex).NumAllocElements > 0)) or (IdentifierAt(IdentIndex).PassMethod = VARPASSING) or
                  (VarPass and (IdentifierAt(IdentIndex).DataType in Pointers)) then
                begin

                  //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',TokenAt(i + 2).Kind);

                  DEREFERENCE := (TokenAt(i + 2).Kind = DEREFERENCETOK);


                  if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) and (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                    (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType in Pointers) and
                    (IdentifierAt(IdentIndex).idType = DATAORIGINOFFSET) then
                  begin

                    Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORD, DataSize[POINTERTOK], IdentIndex);
                  end
                  else
                    if DEREFERENCE then
                    begin

                      svar := GetLocalName(IdentIndex);

                      //       if (pos('.', svar) > 0) then begin
                      //       lab:=copy(svar,1,pos('.', svar)-1);
                      //       rec:=(IdentifierAt(GetIdent(lab)].AllocElementType = RECORDTOK);
                      //     end;

                      if (IdentifierAt(IdentIndex).DataType in Pointers) {and (TokenAt(i + 2).Kind = DEREFERENCETOK)} then
                        if (IdentifierAt(IdentIndex).AllocElementType = RECORDTOK) and (TokenAt(i + 3).Kind = DOTTOK) then
                        begin    // var record^.field

                          //        DEREFERENCE := true;

                          CheckTok(i + 4, IDENTTOK);
                          IdentTemp := RecordSize(IdentIndex, TokenAt(i + 4).Name^);

                          if IdentTemp < 0 then
                            Error(i + 4, 'identifier idents no member ''' + TokenAt(i + 4).Name^ + '''');

                          AllocElementType := IdentTemp shr 16;

                          IdentTemp := GetIdent(svar + '.' + String(TokenAt(i + 4).Name^));

                          if IdentTemp = 0 then
                            Error(i + 4, UnknownIdentifier);

                          Push(IdentifierAt(IdentTemp).Value, ASPOINTER, DataSize[POINTERTOK], IdentTemp);

                          Inc(i, 3);

                        end
                        else
                        begin                      // type^
                          AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                          //  writeln('^',',', IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' / ',IdentifierAt(IdentIndex).NumAllocElements_,' = ',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);

                          if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                            (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                          begin

                            if IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK] then
                            begin

                              if IdentifierAt(IdentIndex).NumAllocElements_ = 0 then

                              else
                                Error(i + 4, IllegalQualifier);  // array of ^record

                            end
                            else
                              Error(i + 4, IllegalQualifier);  // array

                          end;
                          //trs
                          if IdentifierAt(IdentIndex).ObjectVariable and (IdentifierAt(IdentIndex).PassMethod = VARPASSING) then
                            Push(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER, DataSize[POINTERTOK], IdentIndex)
                          else
                            Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

                          Inc(i);
                        end;


                      //  writeln('5: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE,',',VarPass);

                    end
                    else
                      if address or VarPass then
                      begin
                        //       if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements = 0) {and (IdentifierAt(IdentIndex).PassMethod <> VARPASSING)} then begin

                        //  writeln('1: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,'..',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE,',',varpass,' o ',IdentifierAt(IdentIndex).isAbsolute);

                        if (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK, FILETOK, TEXTFILETOK]) or
                          (VarPass and (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                          (IdentifierAt(IdentIndex).AllocElementType in AllTypes - [PROCVARTOK, RECORDTOK, OBJECTTOK]) and
                          (IdentifierAt(IdentIndex).NumAllocElements = 0)) or
                          ((IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType in
                          [RECORDTOK, OBJECTTOK]) and (VarPass or (IdentifierAt(IdentIndex).PassMethod = VARPASSING))) or
                          (IdentifierAt(IdentIndex).isAbsolute and (abs(IdentifierAt(IdentIndex).Value) and $ff = 0) and
                          (Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) in [1..127])) or
                          ((IdentifierAt(IdentIndex).DataType in Pointers) and
                          (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK]) and
                          (IdentifierAt(IdentIndex).NumAllocElements_ = 0)) or ((IdentifierAt(IdentIndex).DataType in Pointers) and
                          (IdentifierAt(IdentIndex).idType = DATAORIGINOFFSET)) or
                          ((IdentifierAt(IdentIndex).DataType in Pointers) and not
                          (IdentifierAt(IdentIndex).AllocElementType in [UNTYPETOK, RECORDTOK, OBJECTTOK, PROCVARTOK]) and
                          (IdentifierAt(IdentIndex).NumAllocElements > 0)) or ((IdentifierAt(IdentIndex).DataType in Pointers) and
                          (IdentifierAt(IdentIndex).PassMethod = VARPASSING)) then
                          Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex)
                        else
                          Push(IdentifierAt(IdentIndex).Value, ASVALUE, DataSize[POINTERTOK], IdentIndex);

                        AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                      end
                      else
                      begin

                        //  writeln('2: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);

                        Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

                        AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                      end;

                end
                else
                begin

                  if (IdentifierAt(IdentIndex).DataType in Pointers) and (TokenAt(i + 2).Kind = DEREFERENCETOK) then
                  begin
                    AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                    Inc(i);

                    Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
                  end
                  else
                    //      if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType <> 0) and (IdentifierAt(IdentIndex).NumAllocElements = 0) then begin
                    //  writeln('3: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);
                    //       Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
                    //      end else
                  begin

                    //  writeln('4: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).idType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).PassMethod,',',DEREFERENCE);

                    Push(IdentifierAt(IdentIndex).Value, ASVALUE, DataSize[POINTERTOK], IdentIndex);

                  end;

                end;

            ValType := POINTERTOK;

            Result := i + 1;
          end;

        end
        else
          Error(i + 1, UnknownIdentifier);
      end;

  end;  //CompileAddress


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function NumActualParameters(i: Integer; IdentIndex: Integer; out NumActualParams: Integer): TParamList;
    (*----------------------------------------------------------------------------*)
    (* moze istniec wiele funkcji/procedur o tej samej nazwie ale roznej liczbie  *)
    (* parametrow                      *)
    (*----------------------------------------------------------------------------*)
  var
    ActualParamType, AllocElementType: Byte;
    NumAllocElements: Cardinal;
    oldPass, oldCodeSize, IdentTemp: Integer;
  begin

    oldPass := Pass;
    oldCodeSize := CodeSize;
    Pass := CALLDETERMPASS;

    NumActualParams := 0;
    ActualParamType := 0;

    Result[1].i_ := i + 1;

    if (TokenAt(i + 1).Kind = OPARTOK) and (TokenAt(i + 2).Kind <> CPARTOK) then        // Actual parameter list found
    begin
      repeat

        Inc(NumActualParams);

        if NumActualParams > MAXPARAMS then
          Error(i, TooManyParameters, IdentIndex);

        Result[NumActualParams].i := i;

{
       if (IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod = VARPASSING) then begin    // !!! to nie uwzglednia innych procedur/funkcji o innej liczbie parametrow

  CompileExpression(i + 2, ActualParamType);

  Result[NumActualParams].AllocElementType := ActualParamType;

  i := CompileAddress(i + 1, ActualParamType, AllocElementType);

       end else}

        i := CompileExpression(i + 2, ActualParamType{, IdentifierAt(IdentIndex).Param[NumActualParams].DataType});
        // Evaluate actual parameters and push them onto the stack

        AllocElementType := UNTYPETOK;
        NumAllocElements := 0;

        if (ActualParamType in [POINTERTOK, STRINGPOINTERTOK]) and (TokenAt(i).Kind = IDENTTOK) then
        begin

          IdentTemp := GetIdent(TokenAt(i).Name^);

          if (TokenAt(i - 1).Kind = ADDRESSTOK) and (not (IdentifierAt(IdentTemp).DataType in [RECORDTOK, OBJECTTOK])) then

          else
          begin
            AllocElementType := IdentifierAt(IdentTemp).AllocElementType;
            NumAllocElements := IdentifierAt(IdentTemp).NumAllocElements;
          end;


          if IdentifierAt(IdentTemp).Kind in [PROCEDURETOK, FUNCTIONTOK] then
          begin

            Result[NumActualParams].Name := IdentifierAt(IdentTemp).Name;

            AllocElementType := IdentifierAt(IdentTemp).Kind;

          end;

          //  writeln(IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements,'/',IdentifierAt(IdentTemp).NumAllocElements_,'|',ActualParamType,',',AllocElementType);

        end
        else
        begin

          if TokenAt(i).Kind = IDENTTOK then
          begin

            IdentTemp := GetIdent(TokenAt(i).Name^);

            AllocElementType := IdentifierAt(IdentTemp).AllocElementType;
            NumAllocElements := IdentifierAt(IdentTemp).NumAllocElements;

            //  writeln(IdentifierAt(IdentTemp).Name,' > ',ActualPAramType,',',AllocElementType,',',NumAllocElements,' | ',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements);

          end
          else
            AllocElementType := UNTYPETOK;

        end;

        Result[NumActualParams].DataType := ActualParamType;
        Result[NumActualParams].AllocElementType := AllocElementType;
        Result[NumActualParams].NumAllocElements := NumAllocElements;


        //  writeln(Result[NumActualParams].DataType,',',Result[NumActualParams].AllocElementType);

      until TokenAt(i + 1).Kind <> COMMATOK;

      CheckTok(i + 1, CPARTOK);

      Result[1].i_ := i;

      //     inc(i);
    end;  // if (TokenAt(i + 1).Kind = OPARTOR) and (TokenAt(i + 2).Kind <> CPARTOK)


    Pass := oldPass;
    CodeSize := oldCodeSize;

  end;  //NumActualParameters


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure RealTypeConversion(var ValType, RightValType: Byte; Kind: Byte = 0);
  begin

    if ((ValType = SINGLETOK) or (Kind = SINGLETOK)) and (RightValType in IntegerTypes) then
    begin

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


    if (ValType in IntegerTypes) and ((RightValType = SINGLETOK) or (Kind = SINGLETOK)) then
    begin

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


    if ((ValType = HALFSINGLETOK) or (Kind = HALFSINGLETOK)) and (RightValType in IntegerTypes) then
    begin

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


    if (ValType in IntegerTypes) and ((RightValType = HALFSINGLETOK) or (Kind = HALFSINGLETOK)) then
    begin

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


    if ((ValType in [REALTOK, SHORTREALTOK]) or (Kind in [REALTOK, SHORTREALTOK])) and
      (RightValType in IntegerTypes) then
    begin

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
      if not (ValType in [REALTOK, SHORTREALTOK]) and (Kind in [REALTOK, SHORTREALTOK]) then
        RightValType := Kind
      else
        RightValType := ValType;

    end;


    if (ValType in IntegerTypes) and ((RightValType in [REALTOK, SHORTREALTOK]) or
      (Kind in [REALTOK, SHORTREALTOK])) then
    begin

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

      if not (RightValType in [REALTOK, SHORTREALTOK]) and (Kind in [REALTOK, SHORTREALTOK]) then
        ValType := Kind
      else
        ValType := RightValType;

    end;

  end;  //RealTypeConversion


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure CompileActualParameters(var i: Integer; IdentIndex: Integer; ProcVarIndex: Integer = 0);
  var
    NumActualParams, IdentTemp, ParamIndex, j, old_i, old_func: Integer;
    ActualParamType, AllocElementType: Byte;
    svar, lab: String;
    yes: Boolean;
    Param: TParamList;
  begin

    svar := '';
    lab := '';

    old_i := i;

    if IdentifierAt(IdentIndex).ProcAsBlock = BlockStack[BlockStackTop] then Ident[IdentIndex].isRecursion := True;


    yes := {(IdentifierAt(IdentIndex).ObjectIndex > 0) or} IdentifierAt(IdentIndex).isRecursion or IdentifierAt(IdentIndex).isStdCall;

    for ParamIndex := IdentifierAt(IdentIndex).NumParams downto 1 do
      if not ((IdentifierAt(IdentIndex).Param[ParamIndex].PassMethod = VARPASSING) or
        ((IdentifierAt(IdentIndex).Param[ParamIndex].DataType in Pointers) and
        (IdentifierAt(IdentIndex).Param[ParamIndex].NumAllocElements and $FFFF in [0, 1])) or
        ((IdentifierAt(IdentIndex).Param[ParamIndex].DataType in Pointers) and
        (IdentifierAt(IdentIndex).Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK])) or
        (IdentifierAt(IdentIndex).Param[ParamIndex].DataType in OrdinalTypes + RealTypes)) then
      begin
        yes := True;
        Break;
      end;


    //   yes:=true;

    (*------------------------------------------------------------------------------------------------------------*)

    if ProcVarIndex > 0 then
    begin

      svar := GetLocalName(ProcVarIndex);

      if (TokenAt(i + 1).Kind = OBRACKETTOK) then
      begin
        i := CompileArrayIndex(i, ProcVarIndex, AllocElementType);

        CheckTok(i + 1, CBRACKETTOK);

        Inc(i);

        if (IdentifierAt(ProcVarIndex).NumAllocElements * 2 > 256) or (IdentifierAt(ProcVarIndex).NumAllocElements in [0, 1]) then
        begin

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

        end
        else
        begin

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

      end
      else
      begin

        if IdentifierAt(ProcVarIndex).isAbsolute and (IdentifierAt(ProcVarIndex).NumAllocElements = 0) then
        begin

          //        asm65(#9'jsr *+6');
          //        asm65(#9'jmp *+6');

        end
        else
        begin

          if (IdentifierAt(ProcVarIndex).PassMethod = VARPASSING) then
          begin

            if pos('.', svar) > 0 then
            begin

              lab := ExtractName(ProcVarIndex, svar);

              asm65(#9'mwy ' + lab + ' :bp2');
              asm65(#9'ldy #' + svar + '-DATAORIGIN');
            end
            else
            begin
              asm65(#9'mwy ' + svar + ' :bp2');
              asm65(#9'ldy #$00');
            end;

            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :TMP+1');
            asm65(#9'iny');
            asm65(#9'lda (:bp2),y');
            asm65(#9'sta :TMP+2');

          end
          else
          begin

            //   writeln(IdentifierAt(ProcVarIndex].Name,',',IdentifierAt(ProcVarIndex].DataType,',',   IdentifierAt(ProcVarIndex].NumAllocElements,',', IdentifierAt(ProcVarIndex].AllocElementType,',',IdentifierAt(ProcVarIndex].isAbsolute);

            if IdentifierAt(ProcVarIndex).NumAllocElements = 0 then
            begin

              asm65(#9'lda ' + svar);
              asm65(#9'sta :TMP+1');
              asm65(#9'lda ' + svar + '+1');
              asm65(#9'sta :TMP+2');

            end
            else

              if (IdentifierAt(ProcVarIndex).NumAllocElements * 2 > 256) or (IdentifierAt(ProcVarIndex).NumAllocElements in [1]) then
              begin

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

              end
              else
              begin

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

    if NumActualParams <> IdentifierAt(IdentIndex).NumParams then
      if ProcVarIndex > 0 then
        Error(i, WrongNumParameters, ProcVarIndex)
      else
        Error(i, WrongNumParameters, IdentIndex);


    ParamIndex := NumActualParams;

    AllocElementType := UNTYPETOK;

    //   NumActualParams := 0;
    IdentTemp := 0;

    if (TokenAt(i + 1).Kind = OPARTOK) then        // Actual parameter list found
    begin

      if (TokenAt(i + 2).Kind = CPARTOK) then
        Inc(i)
      else
        //repeat

        while NumActualParams > 0 do
        begin

          //       Inc(NumActualParams);

          //       if NumActualParams > IdentifierAt(IdentIndex).NumParams then
          //        if ProcVarIndex > 0 then
          //   Error(i, WrongNumParameters, ProcVarIndex)
          //  else
          //   Error(i, WrongNumParameters, IdentIndex);

          i := Param[NumActualParams].i;

          if (IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod = VARPASSING) then
          begin

            i := CompileAddress(i + 1, ActualParamType, AllocElementType, True);


            //  writeln(IdentifierAt(IdentIndex).Param[NumActualParams].Name,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType  ,',',IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements and $FFFF,'/',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements shr 16,' | ',ActualParamType,',', AllocElementType);


            if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> UNTYPETOK) and
              (ActualParamType = POINTERTOK) and (AllocElementType in [POINTERTOK, STRINGPOINTERTOK, PCHARTOK]) then
            begin

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

            if AllocElementType = ARRAYTOK then
            begin
              AllocElementType := POINTERTOK;
            end;


            if TokenAt(i).Kind = IDENTTOK then
              IdentTemp := GetIdent(TokenAt(i).Name^)
            else
              IdentTemp := 0;

            if IdentTemp > 0 then
            begin

              if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then Error(i, CantAdrConstantExp);
              // VARPASSING function not possible


              //  writeln(' - ',TokenAt(i).Name^,',',ActualParamType,',',AllocElementType, ',', IdentifierAt(IdentTemp).NumAllocElements );
              //  writeln(IdentifierAt(IdentTemp).Kind,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

              if IdentifierAt(IdentTemp).DataType in Pointers then
                if not (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [FILETOK, TEXTFILETOK]) then
                begin

{
 writeln('--- ',IdentifierAt(IdentIndex).Name);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',', IdentifierAt(IdentTemp).DataType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',', IdentifierAt(IdentTemp).NumAllocElements);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod,',', IdentifierAt(IdentTemp).PassMethod);
}

                  if IdentifierAt(IdentTemp).PassMethod <> VARPASSING then

                    if IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK] then
                      Error(i, 'Incompatible types: got "' +
                        Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name + '" expected "^' +
                        Types[IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements].Field[0].Name + '"')
                    else
                      GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, IdentifierAt(IdentTemp).DataType);

                end;



              if (IdentifierAt(IdentTemp).DataType in [RECORDTOK, OBJECTTOK])
              {and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK])} then
                if (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements > 0) and
                  (IdentifierAt(IdentTemp).NumAllocElements <> IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements) then
                begin

                  if IdentifierAt(IdentTemp).PassMethod <> IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod then
                    Error(i, CantAdrConstantExp)
                  else
                    Error(i, IncompatibleTypeOf, IdentTemp);
                end;


              if (IdentifierAt(IdentTemp).AllocElementType = UNTYPETOK) then
              begin

                GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, IdentifierAt(IdentTemp).DataType);

                if (IdentifierAt(IdentTemp).AllocElementType = UNTYPETOK) then
                  if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> UNTYPETOK) and
                    (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> IdentifierAt(IdentTemp).DataType) then
                    Error(i, IncompatibleTypes, 0, IdentifierAt(IdentTemp).DataType,
                      IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

              end
              else
                if IdentifierAt(IdentIndex).Param[NumActualParams].DataType in Pointers then
                begin

                  //     GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType, IdentifierAt(IdentTemp).AllocElementType);

                  if (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements = 0) and
                    (IdentifierAt(IdentTemp).NumAllocElements = 0) then
                  // ok ?
                  else
                    if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <>
                      IdentifierAt(IdentTemp).AllocElementType then
                    begin

{
 writeln('--- ',IdentifierAt(IdentIndex).Name);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',', IdentifierAt(IdentTemp).DataType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,',', IdentifierAt(IdentTemp).AllocElementType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',', IdentifierAt(IdentTemp).NumAllocElements);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod,',', IdentifierAt(IdentTemp).PassMethod);
}

                      if (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType = UNTYPETOK) and
                        (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [POINTERTOK, PCHARTOK]) then
                      begin

                        if IdentifierAt(IdentTemp).AllocElementType in [RECORDTOK, OBJECTTOK] then

                        else
                          Error(i, IncompatibleTypesArray, IdentTemp,
                            IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

                      end
                      else
                        Error(i, IncompatibleTypes, 0, IdentifierAt(IdentTemp).AllocElementType,
                          IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType);

                    end;

                end
                else
                  GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType,
                    IdentifierAt(IdentTemp).AllocElementType);

            end
            else
              if IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> UNTYPETOK then
                if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType <> AllocElementType) then
                begin

                  //  writeln(IdentifierAt(IdentIndex).name,',', IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType);

                  if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> UNTYPETOK then
                  begin

                    if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> AllocElementType then
                      Error(i, IncompatibleTypes, 0, AllocElementType,
                        IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

                  end
                  else
                    Error(i, IncompatibleTypes, 0, AllocElementType,
                      IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

                end;


            //  writeln('x ',IdentifierAt(IdentIndex).name,',', IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,' | ',ActualParamType,',',AllocElementType,',',IdentTemp);


            if IdentTemp = 0 then
              if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = RECORDTOK) and
                (ActualParamType = POINTERTOK) and (AllocElementType = RECORDTOK) then

              else
                if (ActualParamType = POINTERTOK) and (AllocElementType <> UNTYPETOK) then
                  GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, AllocElementType)
                else
                  GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);

          end
          else
          begin

            if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = POINTERTOK) and
              (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements > 0) and not
              (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType in [RECORDTOK, OBJECTTOK]) then
              i := CompileAddress(i + 1, ActualParamType, AllocElementType)
            else
              i := CompileExpression(i + 2, ActualParamType, IdentifierAt(IdentIndex).Param[NumActualParams].DataType);
            // Evaluate actual parameters and push them onto the stack



            //  writeln(IdentifierAt(IdentIndex).name,',', IdentifierAt(IdentIndex).kind,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',',IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType ,'|',ActualParamType);


            if (ActualParamType in IntegerTypes) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
              RealTypes) then
            begin

              AllocElementType := IdentifierAt(IdentIndex).Param[NumActualParams].DataType;

              RealTypeConversion(AllocElementType, ActualParamType);

            end;

            if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in IntegerTypes + RealTypes) and
              (ActualParamType in RealTypes) then
              GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);


            if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = POINTERTOK) then
              GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);


            if (TokenAt(i).Kind = IDENTTOK) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = ENUMTOK) then
            begin
              IdentTemp := GetIdent(TokenAt(i).Name^);

              if Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name <>
                Types[IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements].Field[0].Name then
                Error(i, 'Incompatible types: got "' + Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                  '" expected "' + Types[IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements].Field[0].Name
                  + '"');

              ActualParamType := IdentifierAt(IdentTemp).Kind;

              //    writeln(IdentifierAt(IdentTemp).Kind,',', IdentifierAt(IdentTemp).NumAllocElements,'/', IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements, ',',Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].name);
            end;


            if (TokenAt(i).Kind = IDENTTOK) and (ActualParamType in [RECORDTOK, OBJECTTOK]) and
              not (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in Pointers) then
              if IdentifierAt(GetIdent(TokenAt(i).Name^)).isNestedFunction then
              begin

                if IdentifierAt(GetIdent(TokenAt(i).Name^)).NestedFunctionNumAllocElements <>
                  IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements then
                  Error(i, IncompatibleTypeOf, GetIdent(TokenAt(i).Name^));

              end
              else
                if IdentifierAt(GetIdent(TokenAt(i).Name^)).NumAllocElements <>
                  IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements then
                  Error(i, IncompatibleTypeOf, GetIdent(TokenAt(i).Name^));


            if ((ActualParamType in [RECORDTOK, OBJECTTOK]) and
              (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in Pointers)) or
              ((ActualParamType in Pointers) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in
              [RECORDTOK, OBJECTTOK])) then
              //  jesli wymagany jest POINTER a przekazujemy RECORD (lub na odwrot) to OK

            begin

              if (ActualParamType = POINTERTOK) and (TokenAt(i).Kind = IDENTTOK) then
              begin
                IdentTemp := GetIdent(TokenAt(i).Name^);

                if (TokenAt(i - 1).Kind = ADDRESSTOK) then
                  AllocElementType := UNTYPETOK
                else
                  AllocElementType := IdentifierAt(IdentTemp).AllocElementType;

                if AllocElementType = UNTYPETOK then
                  Error(i, IncompatibleTypes, 0, ActualParamType, IdentifierAt(IdentIndex).Param[NumActualParams].DataType);
{
 writeln('--- ',IdentifierAt(IdentIndex).Name,',',ActualParamType,',',AllocElementType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',', IdentifierAt(IdentTemp).DataType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType,',', IdentifierAt(IdentTemp).AllocElementType);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements,',', IdentifierAt(IdentTemp).NumAllocElements);
 writeln(IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod,',', IdentifierAt(IdentTemp).PassMethod);
}
              end
              else
                Error(i, IncompatibleTypes, 0, ActualParamType, IdentifierAt(IdentIndex).Param[NumActualParams].DataType);

            end

            else
            begin

              if (ActualParamType = POINTERTOK) and (TokenAt(i).Kind = IDENTTOK) then
              begin
                IdentTemp := GetIdent(TokenAt(i).Name^);

                if (TokenAt(i - 1).Kind = ADDRESSTOK) then
                  AllocElementType := UNTYPETOK
                else
                  AllocElementType := IdentifierAt(IdentTemp).AllocElementType;


                if (IdentifierAt(IdentTemp).DataType in [RECORDTOK, OBJECTTOK]) then
                  GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType)
                else
                  if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> AllocElementType then
                  begin

                    if (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType = UNTYPETOK) and
                      (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = POINTERTOK) and
                      ({IdentifierAt(IdentIndex).Param[NumActualParams]} IdentifierAt(IdentTemp).NumAllocElements > 0) then
                      Error(i, IncompatibleTypesArray, IdentTemp, POINTERTOK)
                    else
                      if (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> PROCVARTOK) and
                        (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements > 0) then
                        Error(i, IncompatibleTypes, 0, AllocElementType,
                          IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType);

                  end;

              end
              else
                if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [POINTERTOK, STRINGPOINTERTOK]) and
                  (TokenAt(i).Kind = IDENTTOK) then
                begin
                  IdentTemp := GetIdent(TokenAt(i).Name^);

                  //  writeln('1 > ',IdentifierAt(IdentTemp).name,',', IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements,' | ',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements );

                  if (IdentifierAt(IdentTemp).DataType = STRINGPOINTERTOK) and (IdentifierAt(IdentTemp).NumAllocElements <> 0) and
                    (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = POINTERTOK) and
                    (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements = 0) then
                    if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType = UNTYPETOK then
                      Error(i, IncompatibleTypes, 0, IdentifierAt(IdentTemp).DataType,
                        IdentifierAt(IdentIndex).Param[NumActualParams].DataType)
                    else
                      if IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType <> BYTETOK then
                        // wyjatkowo akceptujemy PBYTE jako STRING
                        Error(i, IncompatibleTypes, 0, IdentifierAt(IdentTemp).DataType,
                          -IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType);

{
        if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = PCHARTOK) then begin

          if IdentifierAt(IdentTemp).DataType = STRINGPOINTERTOK then begin
            asm65(#9'lda :STACKORIGIN,x');
      asm65(#9'add #$01');
            asm65(#9'sta :STACKORIGIN,x');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
      asm65(#9'adc #$00');
            asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
    end;

        end;
}

                  GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, IdentifierAt(IdentTemp).DataType);

                end
                else
                begin

                  //  writeln('2 > ',IdentifierAt(IdentIndex).Name,',',ActualParamType,',',AllocElementType,',',TokenAt(i).Kind,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements);

                  if (ActualParamType = POINTERTOK) and (IdentifierAt(IdentIndex).Param[NumActualParams].DataType =
                    STRINGPOINTERTOK) then
                    Error(i, IncompatibleTypes, 0, ActualParamType, -STRINGPOINTERTOK);


                  if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = STRINGPOINTERTOK) then
                  begin    // CHAR -> STRING

                    if (ActualParamType = CHARTOK) and (TokenAt(i).Kind = CHARLITERALTOK) then
                    begin

                      ActualParamType := STRINGPOINTERTOK;

                      if Pass = CODEGENERATIONPASS then
                      begin
                        DefineStaticString(i, chr(TokenAt(i).Value));
                        Tok[i].Kind := STRINGLITERALTOK;

                        asm65(#9'lda :STACKORIGIN,x');
                        asm65(#9'sta :STACKORIGIN,x');
                        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                        asm65(#9'lda <CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN, 4));
                        asm65(#9'sta :STACKORIGIN,x');
                        asm65(#9'lda >CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN, 4));
                        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                      end;

                    end;

                  end;


                  if (IdentifierAt(IdentIndex).Param[NumActualParams].DataType = PCHARTOK) then
                  begin

                    if (ActualParamType = STRINGPOINTERTOK) then
                    begin
                      asm65(#9'lda :STACKORIGIN,x');
                      asm65(#9'add #$01');
                      asm65(#9'sta :STACKORIGIN,x');
                      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                      asm65(#9'adc #$00');
                      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                    end;


                    if (ActualParamType = CHARTOK) and (TokenAt(i).Kind = CHARLITERALTOK) then
                    begin

                      ActualParamType := PCHARTOK;

                      if Pass = CODEGENERATIONPASS then
                      begin
                        DefineStaticString(i, chr(TokenAt(i).Value));
                        Tok[i].Kind := STRINGLITERALTOK;

                        asm65(#9'lda :STACKORIGIN,x');
                        asm65(#9'sta :STACKORIGIN,x');
                        asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');

                        asm65(#9'lda <CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN + 1, 4));
                        asm65(#9'sta :STACKORIGIN,x');
                        asm65(#9'lda >CODEORIGIN+$' + IntToHex(TokenAt(i).StrAddress - CODEORIGIN + 1, 4));
                        asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                      end;

                    end;

                  end;

                  //GetCommonType(i, IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);

                end;

            end;

            ExpandParam(IdentifierAt(IdentIndex).Param[NumActualParams].DataType, ActualParamType);
          end;



          if (IdentifierAt(IdentIndex).isRecursion = False) and (IdentifierAt(IdentIndex).isStdCall = False) and
            (ParamIndex > 1) and (IdentifierAt(IdentIndex).Param[NumActualParams].PassMethod <> VARPASSING) and
            (IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK] + Pointers) and
            (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements and $FFFF > 1) then

            if IdentifierAt(IdentIndex).Param[NumActualParams].DataType in [RECORDTOK, OBJECTTOK] then
            begin

              if IdentifierAt(IdentIndex).isOverload then
                svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
              else
                svar := GetLocalName(IdentIndex);

              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta :bp2');
              asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
              asm65(#9'sta :bp2+1');

              j := RecordSize(GetIdent(Types[IdentifierAt(IdentIndex).Param[NumActualParams].Numallocelements].Field
                [0].Name));

              //  writeln('1: ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).Kind ,',',  IdentifierAt(IdentIndex).Param[NumActualParams].name,',',IdentifierAt(IdentIndex).Param[NumActualParams].DataType,',',j);

              if j = 256 then
              begin
                asm65(#9'ldy #$00');
                ;
                asm65(#9'mva:rne (:bp2),y ' + svar + '.adr.' + IdentifierAt(IdentIndex).Param[NumActualParams].Name + ',y+');
              end
              else
                if j <= 128 then
                begin
                  asm65(#9'ldy #$' + IntToHex(j - 1, 2));
                  asm65(#9'mva:rpl (:bp2),y ' + svar + '.adr.' +
                    IdentifierAt(IdentIndex).Param[NumActualParams].Name + ',y-');
                end
                else
                  asm65(#9'@move ":bp2" #' + svar + '.adr.' + IdentifierAt(IdentIndex).Param[NumActualParams].Name +
                    ' #' + IntToStr(j));

            end
            else
              if not (IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType in [RECORDTOK, OBJECTTOK]) then
              begin

                if IdentifierAt(IdentIndex).isOverload then
                  svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
                else
                  svar := GetLocalName(IdentIndex);

                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta :bp2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta :bp2+1');

                if IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements shr 16 <> 0 then
                  j := (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements and $FFFF) *
                    (IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements shr 16)
                else
                  j := IdentifierAt(IdentIndex).Param[NumActualParams].NumAllocElements;

                j := j * DataSize[IdentifierAt(IdentIndex).Param[NumActualParams].AllocElementType];

                //  writeln('2: ',IdentifierAt(IdentIndex).isStdCall ,',',IdentifierAt(IdentIndex).NumAllocElements,',',  IdentifierAt(IdentIndex).Param[NumActualParams].name,',',IdentifierAt(IdentIndex).Param[0].AllocElementType,',',j);

                if j = 256 then
                begin
                  asm65(#9'ldy #$00');
                  ;
                  asm65(#9'mva:rne (:bp2),y ' + svar + '.adr.' +
                    IdentifierAt(IdentIndex).Param[NumActualParams].Name + ',y+');
                end
                else
                  if j <= 128 then
                  begin
                    asm65(#9'ldy #$' + IntToHex(j - 1, 2));
                    asm65(#9'mva:rpl (:bp2),y ' + svar + '.adr.' +
                      IdentifierAt(IdentIndex).Param[NumActualParams].Name + ',y-');
                  end
                  else
                    asm65(#9'@move ":bp2" #' + svar + '.adr.' + IdentifierAt(IdentIndex).Param[NumActualParams].Name +
                      ' #' + IntToStr(j));

              end;


          Dec(NumActualParams);
        end;

      //until TokenAt(i + 1).Kind <> COMMATOK;

      i := Param[1].i_;

      CheckTok(i + 1, CPARTOK);

      Inc(i);
    end;// if TokenAt(i + 1).Kind = OPARTOR


    NumActualParams := ParamIndex;


    //writeln(IdentifierAt(IdentIndex).name,',',NumActualParams,',',IdentifierAt(IdentIndex).isUnresolvedForward ,',',IdentifierAt(IdentIndex).isRecursion );


    if Pass = CALLDETERMPASS then                      // issue #103 fixed
      if IdentifierAt(IdentIndex).isUnresolvedForward then

        Ident[IdentIndex].updateResolvedForward := True
      else
        AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(IdentIndex).ProcAsBlock);


    (*------------------------------------------------------------------------------------------------------------*)

    // if IdentifierAt(IdentIndex).isUnresolvedForward then begin
    //   Error(i, 'Unresolved forward declaration of ' + IdentifierAt(IdentIndex).Name);

{
 if (IdentifierAt(IdentIndex).isExternal) and (IdentifierAt(IdentIndex).Libraries > 0) then begin

  if IdentifierAt(IdentIndex).isOverload then
   svar := IdentifierAt(IdentIndex).Alias+ '.' + GetOverloadName(IdentIndex)
  else
   svar := GetLocalName(IdentIndex) + '.' + IdentifierAt(IdentIndex).Alias;

 end else
}



    if IdentifierAt(IdentIndex).isOverload then
      svar := GetLocalName(IdentIndex) + '.' + GetOverloadName(IdentIndex)
    else
      svar := GetLocalName(IdentIndex);


    if RCLIBRARY and IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) and
      (IdentifierAt(IdentIndex).isStdCall = False) then
    begin

      asm65('#lib:' + svar);

    end;


    if (yes = False) and (IdentifierAt(IdentIndex).NumParams > 0) then
    begin

      for ParamIndex := 1 to NumActualParams do
      begin

        ActualParamType := IdentifierAt(IdentIndex).Param[ParamIndex].DataType;
        if ActualParamType = ENUMTYPE then ActualParamType := IdentifierAt(IdentIndex).Param[ParamIndex].AllocElementType;

        if IdentifierAt(IdentIndex).Param[ParamIndex].PassMethod = VARPASSING then
        begin

          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
          asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
          asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+1');

          a65(__subBX);
        end
        else
          if (NumActualParams = 1) and (DataSize[ActualParamType] = 1) then
          begin      // only ONE parameter SIZE = 1

            if IdentifierAt(IdentIndex).ObjectIndex > 0 then
            begin
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
              a65(__subBX);
            end
            else
            begin
              asm65(#9'lda :STACKORIGIN,x');
              asm65(#9'sta @PARAM?');
              a65(__subBX);
            end;

          end
          else
            case ActualParamType of

              BYTETOK, CHARTOK, BOOLEANTOK, SHORTINTTOK:
              begin
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);

                a65(__subBX);
              end;

              WORDTOK, SMALLINTTOK, SHORTREALTOK, HALFSINGLETOK, POINTERTOK, STRINGPOINTERTOK, PCHARTOK:
              begin
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+1');

                a65(__subBX);
              end;

              CARDINALTOK, INTEGERTOK, REALTOK, SINGLETOK:
              begin
                asm65(#9'lda :STACKORIGIN,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name);
                asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+1');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*2,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+2');
                asm65(#9'lda :STACKORIGIN+STACKWIDTH*3,x');
                asm65(#9'sta ' + svar + '.' + IdentifierAt(IdentIndex).Param[ParamIndex].Name + '+3');

                a65(__subBX);
              end;

              else
                Error(i, 'Unassigned: ' + IntToStr(ActualParamType));
            end;

      end;


      old_func := run_func;
      run_func := 0;

      if (IdentifierAt(IdentIndex).isStdCall = False) then
        if IdentifierAt(IdentIndex).Kind = FUNCTIONTOK then
          StartOptimization(i)
        else
          StopOptimization;
      run_func := old_func;

    end;

    Gen;


    (*------------------------------------------------------------------------------------------------------------*)

    if IdentifierAt(IdentIndex).ObjectIndex > 0 then
    begin

      if TokenAt(old_i).Kind <> IDENTTOK then
        Error(old_i, IdentifierExpected)
      else
        IdentTemp := GetIdent(copy(TokenAt(old_i).Name^, 1, pos('.', TokenAt(old_i).Name^) - 1));

      asm65(#9'lda ' + GetLocalName(IdentTemp));
      asm65(#9'ldy ' + GetLocalName(IdentTemp) + '+1');
    end;

    (*------------------------------------------------------------------------------------------------------------*)


    if IdentifierAt(IdentIndex).isInline then
    begin

      // if pass = CODEGENERATIONPASS then
      //    writeln(svar,',', IdentifierAt(IdentIndex).ProcAsBlock,',', BlockStack[BlockStackTop], ',' ,IdentifierAt(IdentIndex).Block ,',', IdentifierAt(IdentIndex).UnitIndex );

      //  asm65(#9'.LOCAL ' + svar);


      if (IdentifierAt(IdentIndex).Block > 1) and (IdentifierAt(IdentIndex).Block <> BlockStack[BlockStackTop]) then
        // issue #102 fixed
        for IdentTemp := NumIdent downto 1 do
          if (IdentifierAt(IdentTemp).Kind in [PROCEDURETOK, FUNCTIONTOK]) and
            (IdentifierAt(IdentTemp).ProcAsBlock = IdentifierAt(IdentIndex).Block) then
          begin
            svar := IdentifierAt(IdentTemp).Name + '.' + svar;
            Break;
          end;


      if (BlockStack[BlockStackTop] <> 1) and (IdentifierAt(IdentIndex).Block = BlockStack[BlockStackTop]) then
        // w aktualnym bloku procedury/funkcji
        asm65(#9'.LOCAL ' + svar)
      else

        if (IdentifierAt(IdentIndex).UnitIndex > 1) and (IdentifierAt(IdentIndex).UnitIndex <> UnitNameIndex) and
          IdentifierAt(IdentIndex).Section then
          asm65(#9'.LOCAL +MAIN.' + svar)
        // w tym samym module poza aktualnym blokiem procedury/funkcji
        else
          if (IdentifierAt(IdentIndex).UnitIndex > 1) then
            asm65(#9'.LOCAL +MAIN.' + UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.' + svar)      // w innym module
          else
            asm65(#9'.LOCAL +MAIN.' + svar);
      // w tym samym module poza aktualnym blokiem procedury/funkcji

{
  if IdentifierAt(IdentIndex).UnitIndex > 1 then
   asm65(#9'.LOCAL +MAIN.' + UnitName[IdentifierAt(IdentIndex).UnitIndex].Name + '.' + svar)      // w innym module
  else
   asm65(#9'.LOCAL +MAIN.' + svar);                  // w tym samym module poza aktualnym blokiem procedury/funkcji
}

      asm65(#9 + 'm@INLINE');
      asm65(#9'.ENDL');

      resetOpty;

    end
    else
    begin

      if ProcVarIndex > 0 then
      begin

        if (IdentifierAt(ProcVarIndex).isAbsolute) and (IdentifierAt(ProcVarIndex).NumAllocElements = 0) then
        begin

          asm65(#9'jsr *+6');
          asm65(#9'jmp *+6');
          asm65(#9'jmp (' + GetLocalName(ProcVarIndex) + ')');

        end
        else
          asm65(#9'jsr :TMP');

      end
      else
        if RCLIBRARY and IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) and
          IdentifierAt(IdentIndex).isStdCall then
        begin

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

        end
        else
          asm65(#9'jsr ' + svar);        // Generate Call

    end;

    //writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).Kind,',',IdentifierAt(IdentIndex).isStdCall,',',IdentifierAt(IdentIndex).isRecursion);

    if (IdentifierAt(IdentIndex).Kind = FUNCTIONTOK) and (IdentifierAt(IdentIndex).isStdCall = False) and
      (IdentifierAt(IdentIndex).isRecursion = False) then
    begin

      asm65(#9'inx');

      ActualParamType := IdentifierAt(IdentIndex).DataType;
      if ActualParamType = ENUMTYPE then ActualParamType := IdentifierAt(IdentIndex).NestedFunctionAllocElementType;

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


    if RCLIBRARY and IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) and
      (IdentifierAt(IdentIndex).isStdCall = False) then
    begin

      asm65(#9'pla');
      asm65(#9'sta portb');

    end;

  end;  //CompileActualParameters


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileFactor(i: Integer; out isZero: Boolean; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
  var
    IdentTemp, IdentIndex, oldCodeSize, j: Integer;
    ActualParamType, AllocElementType, Kind, oldPass: Byte;
    IndirectionLevel: TIndirectionLevel;
    yes: Boolean;
    Value, ConstVal: Int64;
    svar, lab: String;
    Param: TParamList;
    ftmp: TFloat;
    fl: Single;
  begin

    isZero := False;

    Result := i;

    ftmp := Default(TFloat);

    ValType := 0;
    ConstVal := 0;
    IdentIndex := 0;

    fl := 0;

    // WRITELN(TokenAt(i).line, ',', TokenAt(i).kind);

    case TokenAt(i).Kind of

      HIGHTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        if TokenAt(i + 2).Kind in AllTypes {+ [STRINGTOK]} then
        begin

          ValType := TokenAt(i + 2).Kind;

          j := i + 2;

        end
        else
        begin

          oldPass := Pass;
          oldCodeSize := CodeSize;
          Pass := CALLDETERMPASS;

          j := CompileExpression(i + 2, ValType);

          Pass := oldPass;
          CodeSize := oldCodeSize;

        end;
{
      if ValType = ENUMTYPE then begin

       if TokenAt(j).Kind = IDENTTOK then
  IdentIndex := GetIdent(TokenAt(j).Name^)
       else
   Error(i, TypeMismatch);

       if IdentIndex = 0 then Error(i, TypeMismatch);

       IdentTemp := GetIdent(Types[IdentifierAt(IdentIndex).NumAllocElements].Field[Types[IdentifierAt(IdentIndex).NumAllocElements].NumFields].Name);

       if IdentifierAt(IdentTemp).NumAllocElements = 0 then Error(i, TypeMismatch);

       Push(IdentifierAt(IdentTemp).Value, ASPOINTER, DataSize[POINTERTOK], IdentTemp);

       GenerateWriteString(IdentifierAt(IdentTemp).Value, ASPOINTERTOPOINTER, IdentifierAt(IdentTemp).DataType, IdentTemp)

      end else begin
}
        if ValType in Pointers then
        begin
          IdentIndex := GetIdent(TokenAt(i + 2).Name^);

          if IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK] then
            Value := IdentifierAt(IdentIndex).NumAllocElements_ - 1
          else
            if IdentifierAt(IdentIndex).NumAllocElements > 0 then
              Value := IdentifierAt(IdentIndex).NumAllocElements - 1
            else
              Value := HighBound(j, IdentifierAt(IdentIndex).AllocElementType);

        end
        else
          Value := HighBound(j, ValType);

        ValType := GetValueType(Value);

        if IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK then
        begin
          a65(__addBX);
          asm65(#9'lda adr.' + GetLocalName(IdentIndex));
          asm65(#9'sta :STACKORIGIN,x');

          ValType := BYTETOK;
        end
        else
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

        i := CompileExpression(i + 2, ValType);

        Pass := oldPass;
        CodeSize := oldCodeSize;

{
      if ValType = ENUMTYPE then begin

       if TokenAt(j).Kind = IDENTTOK then
  IdentIndex := GetIdent(TokenAt(j).Name^)
       else
   Error(i, TypeMismatch);

       if IdentIndex = 0 then Error(i, TypeMismatch);

       IdentTemp := GetIdent(Types[IdentifierAt(IdentIndex).NumAllocElements].Field[1].Name);

       if IdentifierAt(IdentTemp).NumAllocElements = 0 then Error(i, TypeMismatch);

       ValType := ENUMTYPE;
       Push(IdentifierAt(IdentTemp).Value, ASPOINTER, DataSize[POINTERTOK], IdentTemp);

       GenerateWriteString(IdentifierAt(IdentTemp).Value, ASPOINTERTOPOINTER, IdentifierAt(IdentTemp).DataType, IdentTemp)

      end else begin
}

        if ValType in Pointers then
        begin
          Value := 0;

          if ValType = STRINGPOINTERTOK then Value := 1;

        end
        else
          Value := LowBound(i, ValType);

        ValType := GetValueType(Value);

        Push(Value, ASVALUE, DataSize[ValType]);

        //      end;

        CheckTok(i + 1, CPARTOK);

        Result := i + 1;
      end;


      SIZEOFTOK:
      begin
        Value := 0;

        CheckTok(i + 1, OPARTOK);

        if TokenAt(i + 2).Kind in OrdinalTypes + RealTypes + [POINTERTOK] then
        begin

          Value := DataSize[TokenAt(i + 2).Kind];

          ValType := BYTETOK;

          j := i + 2;

        end
        else
        begin

          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected);

          oldPass := Pass;
          oldCodeSize := CodeSize;
          Pass := CALLDETERMPASS;

          j := CompileExpression(i + 2, ValType);

          Pass := oldPass;
          CodeSize := oldCodeSize;

          Value := GetSizeof(i, ValType);

          ValType := GetValueType(Value);

        end;  // if TokenAt(i + 2).Kind in


        Push(Value, ASVALUE, DataSize[ValType]);

        CheckTok(j + 1, CPARTOK);

        Result := j + 1;

      end;


      LENGTHTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        Value := 0;


        if TokenAt(i + 2).Kind = CHARLITERALTOK then
        begin

          Push(1, ASVALUE, 1);

          ValType := BYTETOK;

          Inc(i, 2);

        end
        else
          if TokenAt(i + 2).Kind = STRINGLITERALTOK then
          begin

            Push(TokenAt(i + 2).StrLength, ASVALUE, 1);

            ValType := BYTETOK;

            Inc(i, 2);

          end
          else

            if TokenAt(i + 2).Kind = IDENTTOK then
            begin

              IdentIndex := GetIdent(TokenAt(i + 2).Name^);

              if IdentIndex = 0 then
                Error(i + 2, UnknownIdentifier);

              //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).AllocElementType );


              if IdentifierAt(IdentIndex).Kind in [VARIABLE, CONSTANT] then
              begin

                if IdentifierAt(IdentIndex).DataType = CHARTOK then
                begin          // length(CHAR) = 1

                  Push(1, ASVALUE, 1);

                  ValType := BYTETOK;

                end
                else

                  if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                    (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                  begin

                    i := CompileArrayIndex(i + 2, IdentIndex, ValType);            // array[ ].field

                    CheckTok(i + 2, DOTTOK);
                    CheckTok(i + 3, IDENTTOK);

                    IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);

                    if IdentTemp < 0 then
                      Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');

                    //       ValType := IdentifierAt(GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name^)].AllocElementType;


                    if (IdentTemp shr 16) = CHARTOK then
                    begin

                      a65(__subBX);

                      Push(1, ASVALUE, 1);

                    end
                    else
                    begin

                      if (IdentTemp shr 16) <> STRINGPOINTERTOK then Error(i + 1, TypeMismatch);

                      Push(0, ASVALUE, 1);

                      Push(1, ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN, 1, IdentIndex, IdentTemp and $ffff);

                    end;

                    ValType := BYTETOK;

                    Inc(i);

                  end
                  else

                    if (IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK) or
                      ((IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
                    begin

                      if ((IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK) or
                        (IdentifierAt(IdentIndex).AllocElementType = CHARTOK)) or
                        ((IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                        (IdentifierAt(IdentIndex).AllocElementType = STRINGPOINTERTOK)) then
                      begin

                        if IdentifierAt(IdentIndex).AllocElementType = STRINGPOINTERTOK then
                        begin    // length(array[x])

                          i := CompileArrayIndex(i + 2, IdentIndex, ValType);

                          a65(__addBX);

                          svar := GetLocalName(IdentIndex);

                          if (IdentifierAt(IdentIndex).NumAllocElements * 2 > 256) or
                            (IdentifierAt(IdentIndex).NumAllocElements in [0, 1]) or (IdentifierAt(IdentIndex).PassMethod =
                            VARPASSING) then
                          begin

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

                          end
                          else
                          begin

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

                          Result := i + 2;
                          exit;

                        end
                        else
                          if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) or
                            (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                          begin
                            a65(__addBX);

                            svar := GetLocalName(IdentIndex);

                            if TestName(IdentIndex, svar) then
                            begin

                              lab := ExtractName(IdentIndex, svar);

                              if IdentifierAt(GetIdent(lab)).AllocElementType = RECORDTOK then
                              begin
                                asm65(#9'lda ' + lab);
                                asm65(#9'ldy ' + lab + '+1');
                                asm65(#9'add #' + svar + '-DATAORIGIN');
                                asm65(#9'scc');
                                asm65(#9'iny');
                              end
                              else
                              begin
                                asm65(#9'lda ' + svar);
                                asm65(#9'ldy ' + svar + '+1');
                              end;

                            end
                            else
                            begin
                              asm65(#9'lda ' + svar);
                              asm65(#9'ldy ' + svar + '+1');
                            end;

                            asm65(#9'sty :bp+1');
                            asm65(#9'tay');

                            asm65(#9'lda (:bp),y');
                            asm65(#9'sta :STACKORIGIN,x');

                          end
                          else
                          begin
                            a65(__addBX);

                            asm65(#9'lda ' + GetLocalName(IdentIndex, 'adr.'));
                            asm65(#9'sta :STACKORIGIN,x');

                          end;

                        ValType := BYTETOK;

                      end
                      else
                      begin

                        if TokenAt(i + 3).Kind = OBRACKETTOK then

                          Error(i + 2, TypeMismatch)

                        else
                        begin

                          Value := IdentifierAt(IdentIndex).NumAllocElements;

                          ValType := GetValueType(Value);
                          Push(Value, ASVALUE, DataSize[ValType]);

                        end;

                      end;

                    end
                    else
                      Error(i + 2, TypeMismatch);

              end
              else
                Error(i + 2, IdentifierExpected);

              Inc(i, 2);
            end
            else
              Error(i + 2, IdentifierExpected);

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

        //asm65;
        //asm65('; Lo(X)');

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
          ValType := BYTETOK;

        Result := i + 1;
      end;


      HITOK:
      begin

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ActualParamType);
        GetCommonConstType(i, INTEGERTOK, ActualParamType);

        if DataSize[ActualParamType] > 2 then warning(i, LoHi);

        CheckTok(i + 1, CPARTOK);

        //asm65;
        //asm65('; Hi(X)');

        case ActualParamType of
          SHORTINTTOK, BYTETOK: asm65(#9'jsr @hiBYTE');
          SMALLINTTOK, WORDTOK: asm65(#9'jsr @hiWORD');
          INTEGERTOK, CARDINALTOK: asm65(#9'jsr @hiCARD');
        end;

        if ActualParamType in [INTEGERTOK, CARDINALTOK] then
          ValType := WORDTOK
        else
          ValType := BYTETOK;

        Result := i + 1;
      end;


      CHRTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ActualParamType, BYTETOK);
        GetCommonConstType(i, INTEGERTOK, ActualParamType);

        CheckTok(i + 1, CPARTOK);

        ValType := CHARTOK;
        Result := i + 1;
      end;


      INTTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ActualParamType);

        if not (ActualParamType in RealTypes) then
          Error(i + 2, IncompatibleTypes, 0, ActualParamType, REALTOK);

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
        Result := i + 1;
      end;


      FRACTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ActualParamType);

        if not (ActualParamType in RealTypes) then
          Error(i + 2, IncompatibleTypes, 0, ActualParamType, REALTOK);

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

        Result := i + 1;
      end;


      TRUNCTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ActualParamType);

        CheckTok(i + 1, CPARTOK);

        if ActualParamType in IntegerTypes then
          ValType := ActualParamType
        else
          if ActualParamType in RealTypes then
          begin

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

          end
          else
            GetCommonConstType(i, REALTOK, ActualParamType);

        Result := i + 1;
      end;


      ROUNDTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ActualParamType);

        CheckTok(i + 1, CPARTOK);

        if ActualParamType in IntegerTypes then
          ValType := ActualParamType
        else
          if ActualParamType in RealTypes then
          begin

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

          end
          else
            GetCommonConstType(i, REALTOK, ActualParamType);

        Result := i + 1;
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
        Result := i + 1;
      end;


      ORDTOK:
      begin

        CheckTok(i + 1, OPARTOK);

        j := i + 2;

        i := CompileExpression(i + 2, ValType, BYTETOK);

        if not (ValType in OrdinalTypes + [ENUMTYPE]) then
          Error(i, OrdinalExpExpected);

        CheckTok(i + 1, CPARTOK);

        if ValType in [CHARTOK, BOOLEANTOK, ENUMTYPE] then
          ValType := BYTETOK;

        Result := i + 1;
      end;


      PREDTOK, SUCCTOK:
      begin
        Kind := TokenAt(i).Kind;

        CheckTok(i + 1, OPARTOK);

        i := CompileExpression(i + 2, ValType);

        if not (ValType in OrdinalTypes) then
          Error(i, OrdinalExpExpected);

        CheckTok(i + 1, CPARTOK);

        Push(1, ASVALUE, DataSize[ValType]);

        if Kind = PREDTOK then
          GenerateBinaryOperation(MINUSTOK, ValType)
        else
          GenerateBinaryOperation(PLUSTOK, ValType);

        Result := i + 1;
      end;


      INTOK:
      begin

        writeln('IN');

{    CaseLocalCnt := CaseCnt;
    inc(CaseCnt);

    ResetOpty;

    StopOptimization;    // !!! potrzebujemy zachowac na stosie testowana wartosc

    i := CompileExpression(i + 1, SelectorType);

  if TokenAt(i).Kind = IDENTTOK then
   EnumName := GetEnumName(GetIdent(TokenAt(i).Name^));


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

  if (TokenAt(i).Kind = IDENTTOK) then
   if ((EnumName = '') and (GetEnumName(GetIdent(TokenAt(i).Name^)) <> '')) or
        ((EnumName <> '') and (GetEnumName(GetIdent(TokenAt(i).Name^)) <> EnumName)) then
    Error(i, 'Constant and CASE types do not match');

  if TokenAt(i + 1).Kind = RANGETOK then              // Range check
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
    GenerateCaseEqualityCheck(ConstVal, SelectorType);        // Equality check

    CaseLabel.left:=ConstVal;
    CaseLabel.right:=ConstVal;
  end;

  UpdateCaseLabels(i, CaseLabelArray, CaseLabel);

  inc(i);

  ExitLoop := FALSE;
  if TokenAt(i).Kind = COMMATOK then
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
      if TokenAt(i).Kind <> SEMICOLONTOK then
  begin
  if TokenAt(i).Kind = ELSETOK then        // Default statements
    begin

    j := CompileStatement(i + 1);
    while TokenAt(j + 1).Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

    i := j + 1;
    end;
  ExitLoop := TRUE;
  end
      else
  begin
  inc(i);

  if TokenAt(i).Kind = ELSETOK then begin
    j := CompileStatement(i + 1);
    while TokenAt(j + 1).Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

    i := j + 1;
  end;

  if TokenAt(i).Kind = ENDTOK then ExitLoop := TRUE;

  end

    until ExitLoop;

    CheckTok(i, ENDTOK);

    GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

}
        Result := i;
      end;


      IDENTTOK:
      begin
        IdentIndex := GetIdent(TokenAt(i).Name^);

        if IdentIndex > 0 then
          if (IdentifierAt(IdentIndex).Kind = USERTYPE) and (TokenAt(i + 1).Kind = OPARTOK) then
          begin

            //    CheckTok(i + 1, OPARTOK);

            if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (Elements(IdentIndex) > 0) then
            begin

              i := CompileAddress(i + 1, VarType, ValType);


              //writeln(IdentifierAt(IdentIndex).name, ',', IdentifierAt(IdentIndex).PassMethod,',',VarType,',',ValType);


              CheckTok(i + 1, CPARTOK);
              CheckTok(i + 2, OBRACKETTOK);

              i := CompileArrayIndex(i + 1, IdentIndex, AllocElementType);

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
              //     writeln(IdentifierAt(IdentIndex).name,',', DataSize[IdentifierAt(IdentIndex).AllocElementType],',', IdentifierAt(IdentIndex).AllocElementType ,',',ValType,',',VarType);

              ValType := IdentifierAt(IdentIndex).AllocElementType;

              case DataSize[IdentifierAt(IdentIndex).AllocElementType] of
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

              exit(i + 1);
            end;


            j := CompileExpression(i + 2, ValType);


            if not (ValType in AllTypes) then
              Error(i, TypeMismatch);


            if (ValType = POINTERTOK) and not (IdentifierAt(IdentIndex).DataType in [POINTERTOK, RECORDTOK, OBJECTTOK]) then
            begin
              ValType := IdentifierAt(IdentIndex).DataType;

              if (TokenAt(i + 4).Kind = DEREFERENCETOK) then exit(j + 2);
            end;


            if ValType in IntegerTypes then

              case IdentifierAt(IdentIndex).DataType of

                ENUMTYPE:
                begin
                  ValType := ENUMTYPE;
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

            if (ValType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType = PROCVARTOK) then
            begin

              IdentTemp := GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

              if IdentifierAt(IdentTemp).IsNestedFunction = False then
                Error(j, 'Variable, constant or function name expected but procedure ' +
                  IdentifierAt(IdentIndex).Name + ' found');

              if TokenAt(j).Kind <> IDENTTOK then Error(j, VariableExpected);

              svar := GetLocalName(GetIdent(TokenAt(j).Name^));

              asm65(#9'lda ' + svar);
              asm65(#9'sta :TMP+1');
              asm65(#9'lda ' + svar + '+1');
              asm65(#9'sta :TMP+2');
              asm65(#9'lda #$4C');
              asm65(#9'sta :TMP');
              asm65(#9'jsr :TMP');

              ValType := IdentifierAt(IdentTemp).DataType;

            end
            else
              if ((ValType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType in OrdinalTypes +
                RealTypes + [RECORDTOK, OBJECTTOK])) or ((ValType = POINTERTOK) and
                (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK])) then
              begin

                yes := False;

                if (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK]) and (TokenAt(j).Kind = DEREFERENCETOK) then
                  yes := True;
                if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (TokenAt(j + 2).Kind = DEREFERENCETOK) then yes := True;

                //     yes := (TokenAt(j + 2).Kind = DEREFERENCETOK);


                //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',TokenAt(j ].Kind,',',TokenAt(j + 1).Kind,',',TokenAt(j + 2).Kind);

                if (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK]) or
                  (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK]) then
                begin

                  if TokenAt(j + 2).Kind = DEREFERENCETOK then Inc(j);


                  if TokenAt(j + 2).Kind <> DOTTOK then yes := False
                  else

                    if TokenAt(j + 2).Kind = DOTTOK then
                    begin          // (pointer).field :=

                      CheckTok(j + 3, IDENTTOK);
                      IdentTemp := RecordSize(IdentIndex, TokenAt(j + 3).Name^);

                      if IdentTemp < 0 then
                        Error(j + 3, 'identifier idents no member ''' + TokenAt(j + 3).Name^ + '''');

                      ValType := IdentTemp shr 16;

                      asm65(#9'lda :STACKORIGIN,x');
                      asm65(#9'sta :bp2');
                      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                      asm65(#9'sta :bp2+1');
                      asm65(#9'ldy #$' + IntToHex(IdentTemp and $ffff, 2));

                      Inc(j, 2);
                    end;

                end
                else
                  if TokenAt(j + 2).Kind = DEREFERENCETOK then        // ASPOINTERTODEREFERENCE
                    if ValType = POINTERTOK then
                    begin

                      asm65(#9'lda :STACKORIGIN,x');
                      asm65(#9'sta :bp2');
                      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                      asm65(#9'sta :bp2+1');
                      asm65(#9'ldy #$00');

                      ValType := IdentifierAt(IdentIndex).AllocElementType;

                      Inc(j);

                    end
                    else
                      Error(j + 2, IllegalQualifier);


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

            ExpandParam(IdentifierAt(IdentIndex).DataType, ValType);

            Result := j + 1;

          end
          else



            if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType = PROCVARTOK) then
            begin

              //        writeln('!! ',hexstr(IdentifierAt(IdentIndex).NumAllocElements_,8));

              IdentTemp := GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

              //  if IdentifierAt(IdentTemp).IsNestedFunction = FALSE then
              //   Error(i, 'Variable, constant or function name expected but procedure ' + IdentifierAt(IdentIndex).Name + ' found');


              if TokenAt(i + 1).Kind = OBRACKETTOK then
              begin
                i := CompileArrayIndex(i, IdentIndex, ValType);

                CheckTok(i + 1, CBRACKETTOK);

                Inc(i);
              end;


              if TokenAt(i + 1).Kind = OPARTOK then

                CompileActualParameters(i, IdentTemp, IdentIndex)

              else
              begin

                if IdentifierAt(IdentIndex).NumAllocElements > 0 then
                  Push(0, ASPOINTERTOARRAYORIGIN2, DataSize[POINTERTOK], IdentIndex)
                else
                  Push(0, ASPOINTER, DataSize[POINTERTOK], IdentIndex);

              end;

              ValType := POINTERTOK;

              Result := i;

            end
            else

              if IdentifierAt(IdentIndex).Kind = PROCEDURETOK then
                Error(i, 'Variable, constant or function name expected but procedure ' +
                  IdentifierAt(IdentIndex).Name + ' found')
              else if IdentifierAt(IdentIndex).Kind = FUNCTIONTOK then       // Function call
                begin

                  Param := NumActualParameters(i, IdentIndex, j);

                  //    if IdentifierAt(IdentIndex).isOverload then begin
                  IdentTemp := GetIdentProc(IdentifierAt(IdentIndex).Name, IdentIndex, Param, j);

                  if IdentTemp = 0 then
                    if IdentifierAt(IdentIndex).isOverload then
                    begin

                      if IdentifierAt(IdentIndex).NumParams <> j then
                        Error(i, WrongNumParameters, IdentIndex);

                      Error(i, CantDetermine, IdentIndex);
                    end
                    else
                      Error(i, WrongNumParameters, IdentIndex);

                  IdentIndex := IdentTemp;

                  //    end;


                  if (IdentifierAt(IdentIndex).isStdCall = False) then
                    StartOptimization(i)
                  else
                    if common.optimize.use = False then StartOptimization(i);


                  Inc(run_func);

                  CompileActualParameters(i, IdentIndex);

                  ValType := IdentifierAt(IdentIndex).DataType;

                  if ValType = ENUMTYPE then ValType := IdentifierAt(IdentIndex).NestedFunctionAllocElementType;

                  Dec(run_func);

                  Result := i;
                end // FUNC
                else
                begin

                  // -----------------------------------------------------------------------------
                  // ===         record^.
                  // -----------------------------------------------------------------------------

                  if (TokenAt(i + 1).Kind = DEREFERENCETOK) then
                    if (IdentifierAt(IdentIndex).Kind <> VARIABLE) or not (IdentifierAt(IdentIndex).DataType in Pointers) then
                      Error(i, IncompatibleTypeOf, IdentIndex)
                    else
                    begin

                      if (IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK) and
                        (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                        ValType := STRINGPOINTERTOK
                      else
                        ValType := IdentifierAt(IdentIndex).AllocElementType;


                      if (ValType = UNTYPETOK) and (IdentifierAt(IdentIndex).DataType = POINTERTOK) then
                      begin

                        ValType := POINTERTOK;

                        Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[ValType], IdentIndex);

                      end
                      else
                        if (ValType in [RECORDTOK, OBJECTTOK]) then
                        begin            // record^.


                          if (TokenAt(i + 2).Kind = DOTTOK) then
                          begin

                            //  writeln(IdentifierAt(IdentIndex).Name,',',TokenAt(i + 3).Name^,' | ',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements);

                            CheckTok(i + 3, IDENTTOK);
                            IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);

                            if IdentTemp < 0 then
                              Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');

                            ValType := IdentTemp shr 16;

                            Inc(i, 2);


                            if (TokenAt(i + 1).Kind = IDENTTOK) and (TokenAt(i + 2).Kind = OBRACKETTOK) then
                            begin    // record^.label[x]

                              Inc(i);

                              i := CompileArrayIndex(i, GetIdent(IdentifierAt(IdentIndex).Name +
                                '.' + TokenAt(i).Name^), ValType);

                              Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORDARRAYORIGIN,
                                DataSize[ValType], IdentIndex,
                                IdentTemp and $ffff);

                            end
                            else

                              if ValType = STRINGPOINTERTOK then
                                Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORD, DataSize[ValType],
                                  IdentIndex, IdentTemp and $ffff)
                              // record^.string
                              else
                                Push(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER, DataSize[ValType],
                                  IdentIndex, IdentTemp and $ffff);
                            // record_lebel.field^

                          end
                          else
                            // fake code, do nothing ;)
                            Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[ValType], IdentIndex);
                          // record_label^

                        end
                        else
                          if IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK then
                            Push(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[ValType], IdentIndex)
                          else
                            Push(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex);

                      // LUCI
                      Result := i + 1;
                    end
                  else

                  // -----------------------------------------------------------------------------
                  // ===         array [index].
                  // -----------------------------------------------------------------------------

                    if TokenAt(i + 1).Kind = OBRACKETTOK then      // Array element access
                      if not (IdentifierAt(IdentIndex).DataType in Pointers)
                      {or ((IdentifierAt(IdentIndex).NumAllocElements = 0) and (IdentifierAt(IdentIndex).idType <> PCHARTOK))} then
                        // PByte, PWord
                        Error(i, IncompatibleTypeOf, IdentIndex)
                      else
                      begin

                        //  writeln('> ',IdentifierAt(IdentIndex).Name,',',ValType,',',IdentifierAt(GetIdent(TokenAt(i).Name^)].name,',',VarType);
                        // perl
                        i := CompileArrayIndex(i, IdentIndex, ValType);              // array[ ].field


                        if ValType = ARRAYTOK then
                        begin

                          ValType := POINTERTOK;

                          Push(0, ASPOINTER, DataSize[ValType], IdentIndex, 0);

                        end
                        else

                          if TokenAt(i + 2).Kind = DEREFERENCETOK then
                          begin

                            //  writeln(valType,' / ',IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_);

                            Push(0, ASPOINTERTORECORDARRAYORIGIN, DataSize[ValType], IdentIndex, 0);

                            Inc(i);
                          end
                          else

                            if (TokenAt(i + 2).Kind = DOTTOK) and (ValType in [RECORDTOK, OBJECTTOK]) then
                            begin

                              //  writeln(valType,' / ',IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_,',',TokenAt(i + 3).Kind );

                              CheckTok(i + 1, CBRACKETTOK);

                              CheckTok(i + 3, IDENTTOK);
                              IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);

                              if IdentTemp < 0 then
                                Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');

                              ValType := IdentTemp shr 16;

                              Inc(i, 2);


                              if (TokenAt(i + 1).Kind = IDENTTOK) and (TokenAt(i + 2).Kind = OBRACKETTOK) then
                              begin    // array_of_record_pointers[x].array[i]

                                Inc(i);

                                ValType :=
                                  IdentifierAt(GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i).Name^)).AllocElementType;

                                IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                                if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                                  (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                                begin

                                  //  writeln(ValType,',',IdentifierAt(IdentIndex).Name + '||' + TokenAt(i).Name^,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_ );

                                  IdentTemp := RecordSize(IdentIndex, TokenAt(i).Name^);

                                  if IdentTemp < 0 then
                                    Error(i, 'identifier idents no member ''' + TokenAt(i).Name^ + '''');

                                  ValType :=
                                    IdentifierAt(GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i).Name^)).AllocElementType;

                                  IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

                                end;


                                i := CompileArrayIndex(i, GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i).Name^),
                                  AllocElementType);

                                Push(IdentifierAt(IdentIndex).Value, IndirectionLevel, DataSize[ValType],
                                  IdentIndex, IdentTemp and $ffff);

                              end
                              else

                                if ValType = STRINGPOINTERTOK then
                                  // array_of_record_pointers[index].string
                                  Push(0, ASPOINTERTOARRAYRECORDTOSTRING, DataSize[ValType],
                                    IdentIndex, IdentTemp and $ffff)
                                else
                                  Push(0, ASPOINTERTOARRAYRECORD, DataSize[ValType], IdentIndex, IdentTemp and $ffff);

                            end
                            else
                              if (TokenAt(i + 2).Kind = OBRACKETTOK) and (ValType = STRINGPOINTERTOK) then
                              begin

                                Error(i, '-- under construction --');
{
       ValType := CHARTOK;
       inc(i, 3);

       Push(2, ASVALUE, 2);

       GenerateBinaryOperation(PLUSTOK, WORDTOK);
}
                              end
                              else
                              begin

                                // -----------------------------------------------------------------------------
                                //          record.
                                // record_ptr.label[index] traktowane jest jako 'record_ptr.label'
                                // zamiast 'record_ptr'
                                // -----------------------------------------------------------------------------

                                //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_);

                                IdentTemp := 0;

                                IndirectionLevel := ASPOINTERTOARRAYORIGIN2;


                                if (pos('.', IdentifierAt(IdentIndex).Name) > 0) then
                                begin         // record_ptr.field[index]

                                  //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).AllocElementType );

                                  IdentTemp :=
                                    GetIdent(copy(IdentifierAt(IdentIndex).Name, 1, pos('.', IdentifierAt(IdentIndex).Name) - 1));

                                  if (IdentifierAt(IdentTemp).DataType = POINTERTOK) and
                                    (IdentifierAt(IdentTemp).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                                  begin

                                    svar :=
                                      copy(IdentifierAt(IdentIndex).Name, pos('.', IdentifierAt(IdentIndex).Name) + 1, length(IdentifierAt(IdentIndex).Name));

                                    IdentIndex := IdentTemp;

                                    IdentTemp := RecordSize(IdentIndex, svar);

                                    if IdentTemp < 0 then
                                      Error(i + 3, 'identifier idents no member ''' + svar + '''');

                                    IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                                    //         Push(IdentifierAt(IdentIndex).Value, ASPOINTERTORECORDARRAYORIGIN, DataSize[ValType], IdentIndex, IdentTemp and $ffff);

                                  end;

                                end;


                                if ValType in [RECORDTOK, OBJECTTOK] then ValType := POINTERTOK;


                                if VarType <> UNTYPETOK then
                                  if DataSize[ValType] > DataSize[VarType] then ValType := VarType;


                                Push(IdentifierAt(IdentIndex).Value, IndirectionLevel, DataSize[ValType],
                                  IdentIndex, IdentTemp and $ffff);

                                CheckTok(i + 1, CBRACKETTOK);

                              end;


                        Result := i + 1;
                      end
                    else                // Usual variable or constant
                    begin

                      j := i;

                      isError := False;
                      isConst := True;


                      if IdentifierAt(IdentIndex).isVolatile then
                      begin
                        asm65('?volatile:');

                        resetOPTY;
                      end;


                      i := CompileConstTerm(i, ConstVal, ValType);

                      if isError then
                      begin
                        i := j;


                        if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) and
                          (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                        begin

                          //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).idType,'/',IdentifierAt(IdentIndex).Kind,' = ',IdentifierAt(IdentIndex).PassMethod ,' | ',ValType,',',TokenAt(j).Kind,',',TokenAt(j+1].kind);

                          ValType := IdentifierAt(IdentIndex).AllocElementType;

                          if (ValType = CHARTOK) then

                            case IdentifierAt(IdentIndex).DataType of
                              POINTERTOK: ValType := PCHARTOK;
                              STRINGPOINTERTOK: ValType := STRINGPOINTERTOK;
                            end;


                          if ValType = UNTYPETOK then ValType := IdentifierAt(IdentIndex).DataType;  // RECORD.

                        end
                        else
                          ValType := IdentifierAt(IdentIndex).DataType;


                        // LUCI
                        //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).idType,'/',IdentifierAt(IdentIndex).Kind,' = ',IdentifierAt(IdentIndex).PassMethod ,' | ',ValType,',',TokenAt(j).Kind,',',TokenAt(j+1].kind);


                        if (ValType = ENUMTYPE) and (IdentifierAt(IdentIndex).DataType = ENUMTYPE) then
                          ValType := IdentifierAt(IdentIndex).AllocElementType;


                        //    if ValType in IntegerTypes then
                        //      if DataSize[ValType] > DataSize[VarType] then ValType := VarType;     // skracaj typ danych    !!! niemozliwe skoro VarType = INTEGERTOK



                        if (IdentifierAt(IdentIndex).Kind = CONSTANT) then
                        begin

                          if {(IdentifierAt(IdentIndex).Kind = CONSTANT) and} (ValType in Pointers) then
                            ConstVal := IdentifierAt(IdentIndex).Value - CODEORIGIN
                          else
                            ConstVal := IdentifierAt(IdentIndex).Value;


                          if (ValType in IntegerTypes) and (VarType in [SINGLETOK, HALFSINGLETOK]) then
                            Int2Float(ConstVal);

                          move(ConstVal, ftmp, sizeof(ftmp));

                          if (VarType = HALFSINGLETOK) {or (ValType = HALFSINGLETOK)} then
                          begin
                            ConstVal := CardToHalf(ftmp[1]);
                            //ValType := HALFSINGLETOK;
                          end;

                          if (VarType = SINGLETOK) then
                          begin
                            ConstVal := ftmp[1];
                            //ValType := SINGLETOK;
                          end;

                        end;



                        if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) and
                          (IdentifierAt(IdentIndex).NumAllocElements > 0) and (IdentifierAt(IdentIndex).DataType in Pointers) and
                          (IdentifierAt(IdentIndex).AllocElementType in Pointers) and (IdentifierAt(IdentIndex).idType =
                          DATAORIGINOFFSET) then

                          Push(ConstVal, ASPOINTERTORECORD, DataSize[ValType], IdentIndex)
                        else
                          if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) and
                            (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                            Push(ConstVal, ASPOINTERTOPOINTER, DataSize[ValType], IdentIndex)
                          else
    {if IdentifierAt(IdentIndex).IdType = DEREFERENCETOK then    // !!! test-record\record_dereference_as_val.pas !!!
     Push(ConstVal, ASVALUE, DataSize[ValType], IdentIndex)
    else}
                            Push(ConstVal, TIndirectionLevel(Ord(IdentifierAt(IdentIndex).Kind = VARIABLE)),
                              DataSize[ValType], IdentIndex);



                        if (BLOCKSTACKTOP = 1) then
                          if not (IdentifierAt(IdentIndex).isInit or IdentifierAt(IdentIndex).isInitialized or
                            IdentifierAt(IdentIndex).LoopVariable) then
                            warning(i, VariableNotInit, IdentIndex);

                      end
                      else
                      begin  // isError

                        if (ValType in [SINGLETOK, HALFSINGLETOK]) or (VarType in [SINGLETOK, HALFSINGLETOK]) then
                        begin  // constants

                          if ValType in IntegerTypes then Int2Float(ConstVal);

                          move(ConstVal, ftmp, sizeof(ftmp));

                          if (VarType = HALFSINGLETOK) or (ValType = HALFSINGLETOK) then
                          begin
                            ConstVal := CardToHalf(ftmp[1]);
                            ValType := HALFSINGLETOK;
                          end
                          else
                          begin
                            ConstVal := ftmp[1];
                            ValType := SINGLETOK;
                          end;

                        end;

                        Push(ConstVal, ASVALUE, DataSize[ValType]);

                      end;

                      isConst := False;
                      isError := False;

                      Result := i;
                    end;

                end
        else
          Error(i, UnknownIdentifier);
      end;


      ADDRESSTOK:
        Result := CompileAddress(i - 1, ValType, AllocElementType);


      INTNUMBERTOK:
      begin

        ConstVal := TokenAt(i).Value;
        ValType := GetValueType(ConstVal);

        if VarType in RealTypes then
        begin
          Int2Float(ConstVal);


          move(ConstVal, ftmp, sizeof(ftmp));

          if VarType = HALFSINGLETOK then
            ConstVal := CardToHalf(ftmp[1])
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

        fl := TokenAt(i).FracValue;

        ftmp[0] := round(fl * TWOPOWERFRACBITS);
        ftmp[1] := Integer(fl);

        move(ftmp, ConstVal, sizeof(ftmp));

        ValType := REALTOK;

        if VarType in RealTypes then
        begin

          case VarType of
            SINGLETOK: ConstVal := ftmp[1];
            HALFSINGLETOK: ConstVal := CardToHalf(ftmp[1]);
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
        Push(TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE, ASVALUE, DataSize[STRINGPOINTERTOK]);
        ValType := STRINGPOINTERTOK;

        Result := i;
      end;


      CHARLITERALTOK:
      begin
        Push(TokenAt(i).Value, ASVALUE, DataSize[CHARTOK]);
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


      SHORTREALTOK:          // SHORTREAL  fixed-point  Q8.8
      begin

        //    CheckTok(i + 1, OPARTOK);

        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i, 'type identifier not allowed here');

        j := CompileExpression(i + 2, ValType);//, SHORTREALTOK);

        // ASPOINTERTODEREFERENCE

        if TokenAt(j + 1).Kind = DEREFERENCETOK then
        begin

          if ValType = POINTERTOK then
          begin

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

            Inc(j);

          end
          else
            Error(j + 1, IllegalQualifier);

        end
        else
        begin

          if ValType in IntegerTypes + RealTypes then
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

          end
          else
            Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
              InfoAboutToken(SHORTREALTOK) + '"');

        end;

        CheckTok(j + 1, CPARTOK);

        ValType := SHORTREALTOK;

        Result := j + 1;
      end;


      REALTOK:          // REAL    fixed-point  Q24.8
      begin

        //    CheckTok(i + 1, OPARTOK);

        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i, 'type identifier not allowed here');

        j := CompileExpression(i + 2, ValType);//, REALTOK);


        // ASPOINTERTODEREFERENCE

        if TokenAt(j + 1).Kind = DEREFERENCETOK then
        begin

          if ValType = POINTERTOK then
          begin

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

            Inc(j);

          end
          else
            Error(j + 1, IllegalQualifier);

        end
        else
        begin

          if ValType in IntegerTypes + RealTypes then
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

          end
          else
            Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
              InfoAboutToken(REALTOK) + '"');

        end;

        CheckTok(j + 1, CPARTOK);

        ValType := REALTOK;

        Result := j + 1;
      end;


      HALFSINGLETOK:
      begin

        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i, 'type identifier not allowed here');

        j := CompileExpression(i + 2, ValType);

        // ASPOINTERTODEREFERENCE

        if TokenAt(j + 1).Kind = DEREFERENCETOK then
        begin

          if ValType = POINTERTOK then
          begin

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

            Inc(j);

          end
          else
            Error(j + 1, IllegalQualifier);

        end
        else
        begin

          if ValType in [SHORTREALTOK, REALTOK] then
            Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
              InfoAboutToken(HALFSINGLETOK) + '"');


          if ValType in IntegerTypes + RealTypes then
          begin

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
          end
          else
            Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
              InfoAboutToken(HALFSINGLETOK) + '"');

        end;

        CheckTok(j + 1, CPARTOK);

        ValType := HALFSINGLETOK;

        Result := j + 1;

      end;


      SINGLETOK:          // SINGLE  IEEE-754  Q32
      begin

        //    CheckTok(i + 1, OPARTOK);

        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i, 'type identifier not allowed here');

        j := i + 2;

        if SafeCompileConstExpression(j, ConstVal, ValType, SINGLETOK) then
        begin

          if not (ValType in RealTypes) then Int2Float(ConstVal);

          move(ConstVal, ftmp, sizeof(ftmp));
          ConstVal := ftmp[1];

          ValType := SINGLETOK;

          Push(ConstVal, ASVALUE, DataSize[ValType]);

        end
        else
        begin
          j := CompileExpression(i + 2, ValType);

          // ASPOINTERTODEREFERENCE

          if TokenAt(j + 1).Kind = DEREFERENCETOK then
          begin

            if ValType = POINTERTOK then
            begin

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

              Inc(j);

            end
            else
              Error(j + 1, IllegalQualifier);

          end
          else
          begin

            if ValType in [SHORTREALTOK, REALTOK] then
              Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
                InfoAboutToken(SINGLETOK) + '"');


            if ValType in IntegerTypes + RealTypes then
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

            end
            else
              Error(i + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
                InfoAboutToken(SINGLETOK) + '"');

          end;

        end;

        CheckTok(j + 1, CPARTOK);

        ValType := SINGLETOK;

        Result := j + 1;

      end;


      INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, PCHARTOK, SHORTINTTOK, BYTETOK,
      BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK:  // type conversion operations
      begin

        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i, 'type identifier not allowed here');


        j := CompileExpression(i + 2, ValType, TokenAt(i).Kind);


        if (ValType in Pointers) and (TokenAt(i + 2).Kind = IDENTTOK) and (TokenAt(i + 3).Kind <> OBRACKETTOK) then
        begin

          IdentIndex := GetIdent(TokenAt(i + 2).Name^);

          if (IdentifierAt(IdentIndex).DataType in Pointers) and ((IdentifierAt(IdentIndex).NumAllocElements > 0) and
            (IdentifierAt(IdentIndex).AllocElementType <> RECORDTOK)) then
            if ((IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK) and
              (IdentifierAt(IdentIndex).NumAllocElements in [0, 1])) or (IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK) then

            else
              Error(i + 2, IllegalTypeConversion, IdentIndex, TokenAt(i).Kind);

        end;

        // ASPOINTERTODEREFERENCE

        if TokenAt(j + 1).Kind = DEREFERENCETOK then
          if ValType = POINTERTOK then
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta :bp2');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta :bp2+1');
            asm65(#9'ldy #$00');

            case DataSize[TokenAt(i).Kind] of

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

            Inc(j);

          end
          else
            Error(j + 1, IllegalQualifier);


        if not (ValType in AllTypes) then
          Error(i, TypeMismatch);

        ExpandParam(TokenAt(i).Kind, ValType);

        CheckTok(j + 1, CPARTOK);

        ValType := TokenAt(i).Kind;


        if TokenAt(j + 2).Kind = DEREFERENCETOK then
          if (ValType = PCHARTOK) then
          begin

            ValType := CHARTOK;

            Inc(j);

          end
          else
            Error(j + 1, IllegalQualifier);

        Result := j + 1;

      end;

      else
        Error(i, IdNumExpExpected);
    end;// case

  end;  //CompileFactor


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure ResizeType(var ValType: Byte);
  // dla operacji SHL, MUL rozszerzamy typ dla wyniku operacji
  begin

    if ValType in [BYTETOK, WORDTOK, SHORTINTTOK, SMALLINTTOK] then Inc(ValType);

  end;


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


    if TokenAt(j + 1).Kind in [MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] then
      j := CompileFactor(i, isZero, ValType, INTEGERTOK)
    else
    begin

      if ValType in RealTypes then VarType := ValType;

      j := CompileFactor(i, isZero, ValType, VarType);

    end;

    while TokenAt(j + 1).Kind in [MULTOK, DIVTOK, MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] do
    begin

      if ValType in RealTypes then VarType := ValType;


      if TokenAt(j + 1).Kind in [MULTOK, DIVTOK] then
        k := CompileFactor(j + 2, isZero, RightValType, VarType)
      else
        k := CompileFactor(j + 2, isZero, RightValType, INTEGERTOK);

      if (TokenAt(j + 1).Kind in [MODTOK, IDIVTOK]) and isZero then
        Error(j + 1, 'Division by zero');


      if ((ValType in [HALFSINGLETOK, SINGLETOK]) and (RightValType in [SHORTREALTOK, REALTOK])) or
        ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [HALFSINGLETOK, SINGLETOK])) then
        Error(j + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
          InfoAboutToken(RightValType) + '"');


      if VarType in RealTypes then
      begin
        if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
        if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
      end;

      if VarType in RealTypes then
        CastRealType := VarType
      else
        CastRealType := REALTOK;


      RealTypeConversion(ValType, RightValType, Ord(TokenAt(j + 1).Kind = DIVTOK) * CastRealType);


      ValType := GetCommonType(j + 1, ValType, RightValType);

      CheckOperator(i, TokenAt(j + 1).Kind, ValType, RightValType);

      if not (TokenAt(j + 1).Kind in [SHLTOK, SHRTOK]) then        // dla SHR, SHL nie wyrownuj typow parametrow
        ExpandExpression(ValType, RightValType, 0);

      if TokenAt(j + 1).Kind = MULTOK then
        if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
          if DataSize[ValType] > DataSize[VarType] then ValType := VarType;

      GenerateBinaryOperation(TokenAt(j + 1).Kind, ValType);

      case TokenAt(j + 1).Kind of              // !!! tutaj a nie przed ExpandExpression
        MULTOK: begin
          ResizeType(ValType);
          ExpandExpression(VarType, 0, 0);
        end;

        SHRTOK: if (ValType in SignedOrdinalTypes) and (DataSize[ValType] > 1) then
          begin
            ResizeType(ValType);
            ResizeType(ValType);
          end;  // int:=smallint(-90100) shr 4;

        SHLTOK: begin
          ResizeType(ValType);
          ResizeType(ValType);
        end;             // !!! Silly Intro lub "x(byte) shl 14" tego wymaga
      end;

      j := k;
    end;

    Result := j;
  end;  //CompileTerm


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileSimpleExpression(i: Integer; out ValType: Byte; VarType: Byte): Integer;
  var
    j, k: Integer;
    ConstVal: Int64;
    RightValType: Byte;
    ftmp: TFloat;
    fl: Single;
  begin

    ftmp := Default(TFloat);
    fl := 0;

    if TokenAt(i).Kind in [PLUSTOK, MINUSTOK] then j := i + 1
    else
      j := i;

    if SafeCompileConstExpression(j, ConstVal, ValType, VarType) then
    begin

      if (ValType in IntegerTypes) and (VarType in RealTypes) then
      begin
        Int2Float(ConstVal);
        ValType := VarType;
      end;

      if VarType in RealTypes then ValType := VarType;


      if TokenAt(i).Kind = MINUSTOK then
        if ValType in RealTypes then
        begin    // Unary minus (RealTypes)

          move(ConstVal, ftmp, sizeof(ftmp));
          move(ftmp[1], fl, sizeof(fl));

          fl := -fl;

          ftmp[0] := round(fl * TWOPOWERFRACBITS);
          ftmp[1] := Integer(fl);

          move(ftmp, ConstVal, sizeof(ftmp));

        end
        else
        begin
          ConstVal := -ConstVal;         // Unary minus (IntegerTypes)

          if ValType in IntegerTypes then
            ValType := GetValueType(ConstVal);

        end;


      if ValType = SINGLETOK then
      begin
        move(ConstVal, ftmp, sizeof(ftmp));
        ConstVal := ftmp[1];
      end;

      if ValType = HALFSINGLETOK then
      begin
        move(ConstVal, ftmp, sizeof(ftmp));
        ConstVal := CardToHalf(ftmp[1]);
      end;


      Push(ConstVal, ASVALUE, DataSize[ValType]);

    end
    else
    begin  // if SafeCompileConstExpression

      j := CompileTerm(j, ValType, VarType);

      if TokenAt(i).Kind = MINUSTOK then
      begin

        GenerateUnaryOperation(MINUSTOK, ValType);  // Unary minus

        if ValType in UnsignedOrdinalTypes then  // jesli odczytalismy typ bez znaku zamieniamy na 'ze znakiem'
          if ValType = BYTETOK then
            ValType := SMALLINTTOK
          else
            ValType := INTEGERTOK;

      end;

    end;


    while TokenAt(j + 1).Kind in [PLUSTOK, MINUSTOK, ORTOK, XORTOK] do
    begin

      if ValType in RealTypes then VarType := ValType;

      k := CompileTerm(j + 2, RightValType, VarType);

      if ((ValType in [HALFSINGLETOK, SINGLETOK]) and (RightValType in [SHORTREALTOK, REALTOK])) or
        ((ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [HALFSINGLETOK, SINGLETOK])) then
        Error(j + 2, 'Illegal type conversion: "' + InfoAboutToken(ValType) + '" to "' +
          InfoAboutToken(RightValType) + '"');


      if VarType in RealTypes then
      begin
        if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
        if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
      end;

      RealTypeConversion(ValType, RightValType);//, VarType);


      if (ValType = POINTERTOK) and (RightValType in IntegerTypes) then
      begin
        ExpandParam(WORDTOK, RightValType);
        RightValType := POINTERTOK;
      end;
      if (RightValType = POINTERTOK) and (ValType in IntegerTypes) then
      begin
        ExpandParam_m1(WORDTOK, ValType);
        ValType := POINTERTOK;
      end;


      ValType := GetCommonType(j + 1, ValType, RightValType);

      CheckOperator(i, TokenAt(j + 1).Kind, ValType, RightValType);


      if TokenAt(j + 1).Kind in [PLUSTOK, MINUSTOK] then
      begin        // dla PLUSTOK, MINUSTOK rozszerz typ wyniku

        if (TokenAt(j + 1).Kind = MINUSTOK) and (RightValType in UnsignedOrdinalTypes) and
          (VarType in SignedOrdinalTypes + [BOOLEANTOK, REALTOK, HALFSINGLETOK, SINGLETOK]) then
        begin

          if (ValType = VarType) and (RightValType = VarType) then
          // do nothing, all types are with sign
          else
            ExpandExpression(ValType, RightValType, VarType, True);    // promote to type with sign

        end
        else
          ExpandExpression(ValType, RightValType, VarType);

      end
      else
        ExpandExpression(ValType, RightValType, 0);

      if (ValType in IntegerTypes) and (VarType in IntegerTypes) then
        if DataSize[ValType] > DataSize[VarType] then ValType := VarType;


      GenerateBinaryOperation(TokenAt(j + 1).Kind, ValType);

      j := k;
    end;

    Result := j;
  end;  //CompileSimpleExpression


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileExpression(i: Integer; out ValType: Byte; VarType: Byte = INTEGERTOK): Integer;
  var
    j, k: Integer;
    RightValType, ConstValType, isZero: Byte;
    cRight, yes: Boolean;
    sLeft, sRight: Wordbool;
    ConstVal, ConstValRight: Int64;
    ftmp: TFloat;
  begin

    ftmp := Default(TFloat);

    ConstVal := 0;

    isZero := INTEGERTOK;

    cRight := False;    // constantRight

    if SafeCompileConstExpression(i, ConstVal, ValType, VarType, False) then
    begin

      if (ValType in IntegerTypes) and (VarType in RealTypes) then
      begin
        Int2Float(ConstVal);
        ValType := VarType;
      end;

      if VarType in RealTypes then ValType := VarType;


      if (ValType = HALFSINGLETOK) {or ((VarType = HALFSINGLETOK) and (ValType in RealTypes))} then
      begin
        move(ConstVal, ftmp, sizeof(ftmp));
        ConstVal := CardToHalf(ftmp[1]);
        ValType := HALFSINGLETOK;
        VarType := HALFSINGLETOK;
      end;

      if (ValType = SINGLETOK) {or ((VarType = SINGLETOK) and (ValType in RealTypes))} then
      begin
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

    sLeft := False;    // stringLeft
    sRight := False;    // stringRight


    i := CompileSimpleExpression(i, ValType, VarType);


    if (TokenAt(i).Kind = STRINGLITERALTOK) or (ValType = STRINGPOINTERTOK) then sLeft := Wordbool(1)
    else
      if (ValType in Pointers) and (TokenAt(i).Kind = IDENTTOK) then
        if (IdentifierAt(GetIdent(TokenAt(i).Name^)).AllocElementType = CHARTOK) and
          (Elements(GetIdent(TokenAt(i).Name^)) in [1..255]) then
          sLeft := Wordbool(1 or Elements(GetIdent(TokenAt(i).Name^)) shl 8);


    if TokenAt(i + 1).Kind = INTOK then writeln('IN');        // not yet programmed


    if TokenAt(i + 1).Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
    begin

      if ValType in RealTypes + [ENUMTYPE] then VarType := ValType;


      j := CompileSimpleExpression(i + 2, RightValType, VarType);


      k := i + 2;
      if SafeCompileConstExpression(k, ConstVal, ConstValType, VarType, False) then
        if (ConstValType in IntegerTypes) and (VarType in IntegerTypes + [BOOLEANTOK]) then
        begin

          if ConstVal = 0 then
          begin
            isZero := BYTETOK;

            if (ValType in SignedOrdinalTypes) and (TokenAt(i + 1).Kind in [EQTOK, NETOK]) then
            begin

              case ValType of
                SHORTINTTOK: ValType := BYTETOK;
                SMALLINTTOK: ValType := WORDTOK;
                INTEGERTOK: ValType := CARDINALTOK;
              end;

            end;

          end;


          if ConstValType in SignedOrdinalTypes then
            if ConstVal < 0 then isZero := SHORTINTTOK;

          cRight := True;

          ConstValRight := ConstVal;
          RightValType := ConstValType;

        end;    // if ConstValType in IntegerTypes



      if (TokenAt(i + 2).Kind = STRINGLITERALTOK) or (RightValType = STRINGPOINTERTOK) then sRight := Wordbool(1)
      else
        if (RightValType in Pointers) and (TokenAt(i + 2).Kind = IDENTTOK) then
          if (IdentifierAt(GetIdent(TokenAt(i + 2).Name^)).AllocElementType = CHARTOK) and
            (Elements(GetIdent(TokenAt(i + 2).Name^)) in [1..255]) then
            sRight := Wordbool(1 or Elements(GetIdent(TokenAt(i + 2).Name^)) shl 8);


      //  if (ValType in [SHORTREALTOK, REALTOK]) and (RightValType in [SHORTREALTOK, REALTOK]) then
      //    RightValType := ValType;

      if VarType in RealTypes then
      begin
        if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
        if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
      end;

      RealTypeConversion(ValType, RightValType);//, VarType);

      //  writeln(VarType,  ' | ', ValType,'/',RightValType,',',isZero,',',TokenAt(i + 1).Kind ,' : ', ConstVal);


      if cRight and (TokenAt(i + 1).Kind in [LTTOK, GTTOK]) and (ValType in IntegerTypes) then
      begin

        yes := False;

        if TokenAt(i + 1).Kind = LTTOK then
        begin

          case ValType of
            BYTETOK, WORDTOK, CARDINALTOK: yes := (isZero = BYTETOK);
            //         BYTETOK: yes := (ConstVal = Low(byte));  // < 0
            //         WORDTOK: yes := (ConstVal = Low(word));  // < 0
            //     CARDINALTOK: yes := (ConstVal = Low(cardinal));  // < 0
            SHORTINTTOK: yes := (ConstVal = Low(Shortint));  // < -128
            SMALLINTTOK: yes := (ConstVal = Low(Smallint));  // < -32768
            INTEGERTOK: yes := (ConstVal = Low(Integer));  // < -2147483648
          end;

        end
        else

          case ValType of
            BYTETOK: yes := (ConstVal = High(Byte));  // > 255
            WORDTOK: yes := (ConstVal = High(Word));  // > 65535
            CARDINALTOK: yes := (ConstVal = High(Cardinal));  // > 4294967295
            SHORTINTTOK: yes := (ConstVal = High(Shortint));  // > 127
            SMALLINTTOK: yes := (ConstVal = High(Smallint));  // > 32767
            INTEGERTOK: yes := (ConstVal = High(Integer));  // > 2147483647
          end;

        if yes then
        begin
          warning(i + 2, AlwaysFalse);
          warning(i + 2, UnreachableCode);
        end;

      end;


      if (isZero = BYTETOK) and (ValType in UnsignedOrdinalTypes) then
        case TokenAt(i + 1).Kind of
          //    LTTOK: warning(i + 2, AlwaysFalse);    // BYTE, WORD, CARDINAL '<' 0
          GETOK: warning(i + 2, AlwaysTrue);      // BYTE, WORD, CARDINAL '>', '>=' 0
        end;


      if (isZero = SHORTINTTOK) and (ValType in UnsignedOrdinalTypes) then
        case TokenAt(i + 1).Kind of

          EQTOK, LTTOK, LETOK: begin        // BYTE, WORD, CARDINAL '=', '<'. '<=' -X
            warning(i + 2, AlwaysFalse);
            warning(i + 2, UnreachableCode);
          end;

          GTTOK, GETOK: warning(i + 2, AlwaysTrue);  // BYTE, WORD, CARDINAL '>', '>=' -X
        end;


      //  writeln(ValType,',',RightValType,' / ',ConstValRight);

      if sLeft or sRight then
      else
        GetCommonType(j, ValType, RightValType);


      if VarType in RealTypes then
      begin
        if (ValType = VarType) and (RightValType in RealTypes) then RightValType := VarType;
        if (ValType in RealTypes) and (RightValType = VarType) then ValType := VarType;
      end;


      // !!! wyjatek !!! porownanie typow tego samego rozmiaru, ale z roznymi znakami

      if ((ValType in SignedOrdinalTypes) and (RightValType in UnsignedOrdinalTypes)) or
        ((ValType in UnsignedOrdinalTypes) and (RightValType in SignedOrdinalTypes)) then
        if DataSize[ValType] = DataSize[RightValType] then
          { if ValType in UnsignedOrdinalTypes then} begin

          case DataSize[ValType] of
            1: begin

              if cRight and ((ConstValRight >= Low(Shortint)) and (ConstValRight <= High(Shortint))) then
                // gdy nie przekracza zakresu dla typu SHORTINT
                RightValType := ValType
              else
              begin
                ExpandParam_m1(SMALLINTTOK, ValType);
                ExpandParam(SMALLINTTOK, RightValType);
                ValType := SMALLINTTOK;
                RightValType := SMALLINTTOK;
              end;

            end;

            2: begin

              if cRight and ((ConstValRight >= Low(Smallint)) and (ConstValRight <= High(Smallint))) then
                // gdy nie przekracza zakresu dla typu SMALLINT
                RightValType := ValType
              else
              begin
                ExpandParam_m1(INTEGERTOK, ValType);
                ExpandParam(INTEGERTOK, RightValType);
                ValType := INTEGERTOK;
                RightValType := INTEGERTOK;
              end;

            end;
          end;

        end;

      ExpandExpression(ValType, RightValType, 0);

      if sLeft or sRight then
      begin

        if (ValType in [CHARTOK, STRINGPOINTERTOK, POINTERTOK]) and (RightValType in
          [CHARTOK, STRINGPOINTERTOK, POINTERTOK]) then
        begin

          if (ValType = POINTERTOK) or (RightValType = POINTERTOK) then
            Error(i, 'Can''t determine PCHAR length, consider using COMPAREMEM');

          GenerateRelationString(TokenAt(i + 1).Kind, ValType, RightValType, sLeft, sRight);
        end
        else
          GetCommonType(j, ValType, RightValType);

      end
      else
        GenerateRelation(TokenAt(i + 1).Kind, ValType);

      i := j;

      ValType := BOOLEANTOK;
    end;

    Result := i;
  end;  //CompileExpression


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure SaveBreakAddress;
  begin

    Inc(BreakPosStackTop);

    BreakPosStack[BreakPosStackTop].ptr := CodeSize;
    BreakPosStack[BreakPosStackTop].brk := False;
    BreakPosStack[BreakPosStackTop].cnt := False;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure RestoreBreakAddress;
  begin

    if BreakPosStack[BreakPosStackTop].brk then asm65('b_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

    Dec(BreakPosStackTop);

    ResetOpty;

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileBlockRead(var i: Integer; IdentIndex: Integer; IdentBlock: Integer): Integer;
  var
    NumActualParams, idx: Integer;
    ActualParamType, AllocElementType: Byte;

  begin

    NumActualParams := 0;
    AllocElementType := 0;

    repeat
      Inc(NumActualParams);

      StartOptimization(i);

      if NumActualParams > 3 then
        Error(i, WrongNumParameters, IdentBlock);

      if fBlockRead_ParamType[NumActualParams] in Pointers + [UNTYPETOK] then
      begin

        if TokenAt(i + 2).Kind <> IDENTTOK then
          Error(i + 2, VariableExpected)
        else
        begin
          idx := GetIdent(TokenAt(i + 2).Name^);

          if (IdentifierAt(idx).Kind = CONSTTOK) then
          begin

            if not (IdentifierAt(idx).DataType in Pointers) or (Elements(idx) = 0) then
              Error(i + 2, VariableExpected);

          end
          else

            if (IdentifierAt(idx).Kind <> VARTOK) then
              Error(i + 2, VariableExpected);

        end;

        i := CompileAddress(i + 1, ActualParamType, AllocElementType, fBlockRead_ParamType[NumActualParams] in
          Pointers);

      end
      else
        i := CompileExpression(i + 2, ActualParamType);  // Evaluate actual parameters and push them onto the stack

      GetCommonType(i, fBlockRead_ParamType[NumActualParams], ActualParamType);

      ExpandParam(fBlockRead_ParamType[NumActualParams], ActualParamType);

      case NumActualParams of
        1: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.buffer');  // VAR LABEL;
        2: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.nrecord');
        // VAR LABEL: POINTER;
        3: GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.numread');
      end;

    until TokenAt(i + 1).Kind <> COMMATOK;

    if NumActualParams < 2 then
      Error(i, WrongNumParameters, IdentBlock);

    CheckTok(i + 1, CPARTOK);

    Inc(i);

    Result := NumActualParams;

  end;  //CompileBlockRead


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure UpdateCaseLabels(j: Integer; var tb: TCaseLabelArray; lab: TCaseLabel);
  var
    i: Integer;
  begin

    for i := 0 to High(tb) - 1 do
      if ((lab.left >= tb[i].left) and (lab.left <= tb[i].right)) or
        ((lab.right >= tb[i].left) and (lab.right <= tb[i].right)) or
        ((tb[i].left >= lab.left) and (tb[i].right <= lab.right)) then
        Error(j, 'Duplicate case label');

    i := High(tb);

    tb[i] := lab;

    SetLength(tb, i + 2);

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure CheckAssignment(i: Integer; IdentIndex: Integer);
  begin

    if IdentifierAt(IdentIndex).PassMethod = CONSTPASSING then
      Error(i, 'Can''t assign values to const variable');

    if IdentifierAt(IdentIndex).LoopVariable then
      Error(i, 'Illegal assignment to for-loop variable ''' + IdentifierAt(IdentIndex).Name + '''');

  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileStatement(i: Integer; isAsm: Boolean = False): Integer;
  var
    j, k, IdentIndex, IdentTemp, NumActualParams, NumCharacters, IfLocalCnt, CaseLocalCnt,
    NumCaseStatements, vlen, oldPass, oldCodeSize: Integer;
    Param: TParamList;
    ExpressionType, ActualParamType, ConstValType, VarType, SelectorType: Byte;
    IndirectionLevel: TIndirectionLevel;
    Value, ConstVal, ConstVal2: Int64;
    Down, ExitLoop, yes, DEREFERENCE, ADDRESS: Boolean;        // To distinguish TO / DOWNTO loops
    CaseLabelArray: TCaseLabelArray;
    CaseLabel: TCaseLabel;
    forLoop: TForLoop;
    Name, EnumName, svar, par1, par2: String;
    forBPL: Byte;
  begin

    Result := i;

    //FillChar(Param, sizeof(Param), 0);
    Param := Default(TParamList);

    IdentIndex := 0;
    ExpressionType := 0;

    par1 := '';
    par2 := '';

    StopOptimization;


    case TokenAt(i).Kind of

      INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK,
      POINTERTOK, STRINGPOINTERTOK, SHORTREALTOK, REALTOK, SINGLETOK, HALFSINGLETOK:  // type conversion operations
      begin

        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i, 'type identifier not allowed here');

        StartOptimization(i + 1);

        if TokenAt(i + 2).Kind <> IDENTTOK then
          Error(i + 2, VariableExpected)
        else
          IdentIndex := GetIdent(TokenAt(i + 2).Name^);

        VarType := IdentifierAt(IdentIndex).DataType;

        if VarType <> TokenAt(i).Kind then
          Error(i, 'Argument cannot be assigned to');

        CheckTok(i + 3, CPARTOK);

        if TokenAt(i + 4).Kind <> ASSIGNTOK then
          Error(i + 4, IllegalExpression);

        i := CompileExpression(i + 5, ExpressionType, VarType);

        GenerateAssignment(ASPOINTER, DataSize[VarType], IdentIndex);

        Result := i;

      end;


      IDENTTOK:
      begin
        IdentIndex := GetIdent(TokenAt(i).Name^);

        if (IdentIndex > 0) and (IdentifierAt(IdentIndex).Kind = FUNCTIONTOK) and (BlockStackTop > 1) and
          (TokenAt(i + 1).Kind <> OPARTOK) then
          for j := NumIdent downto 1 do
            if (IdentifierAt(j).ProcAsBlock = NumBlocks) and (IdentifierAt(j).Kind = FUNCTIONTOK) then
            begin
              if (IdentifierAt(j).Name = IdentifierAt(IdentIndex).Name) and (IdentifierAt(j).UnitIndex = IdentifierAt(IdentIndex).UnitIndex) then
                IdentIndex := GetIdentResult(NumBlocks);
              Break;
            end;


        if IdentIndex > 0 then

          case IdentifierAt(IdentIndex).Kind of


            LABELTYPE:
            begin
              CheckTok(i + 1, COLONTOK);

              if IdentifierAt(IdentIndex).isInit then
                Error(i, 'Label already defined');

              Ident[IdentIndex].isInit := True;

              asm65(IdentifierAt(IdentIndex).Name);

              Result := i;

            end;


            VARIABLE, TYPETOK:                // Variable or array element assignment
            begin

              VarType := 0;

              StartOptimization(i + 1);


              if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType = PROCVARTOK) and
                (not (TokenAt(i + 1).Kind in [ASSIGNTOK, OBRACKETTOK])) then
              begin

                IdentTemp := GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

                CompileActualParameters(i, IdentTemp, IdentIndex);

                Result := i;
                exit;

              end;



              if IdentifierAt(IdentIndex).IdType = DATAORIGINOFFSET then
              begin

                IdentTemp := GetIdent(ExtractName(IdentIndex, IdentifierAt(IdentIndex).Name));

                if (IdentifierAt(IdentTemp).NumAllocElements_ > 0) and (IdentifierAt(IdentTemp).DataType = POINTERTOK) and
                  (IdentifierAt(IdentTemp).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                  Error(i, IllegalQualifier);

                //       writeln(IdentifierAt(IdentTemp).name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements_);

              end;



              IndirectionLevel := ASPOINTERTOPOINTER;


              if (IdentifierAt(IdentIndex).Kind = TYPETOK) and (TokenAt(i + 1).Kind <> OPARTOK) then
                Error(i + 1, VariableExpected);


              if (TokenAt(i + 1).Kind = OPARTOK) and (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                (Elements(IdentIndex) > 0) then
              begin

                //  writeln('= ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements);

                IndirectionLevel := ASPOINTERTODEREFERENCE;

                j := i;

                i := CompileAddress(i + 1, ExpressionType, VarType);


                //      writeln(ExpressionType,',',VarTYpe,',',Elements(GetIdent(TokenAt(j + 2).Name^)));

                if DataSize[VarType] <> Elements(IdentIndex) * DataSize[IdentifierAt(IdentIndex).AllocElementType] then
                  if VarType = UNTYPETOK then
                    Error(j + 2, 'Illegal type conversion: "POINTER" to "Array[0..' +
                      IntToStr(Elements(IdentIndex) - 1) + '] Of ' +
                      InfoAboutToken(IdentifierAt(IdentIndex).AllocElementType) + '"')
                  else
                    if Elements(GetIdent(TokenAt(j + 2).Name^)) = 0 then
                      Error(j + 2, 'Illegal type conversion: "' + InfoAboutToken(VarType) +
                        '" to "' + IdentifierAt(IdentIndex).Name + '"')
                    else
                      Error(j + 2, 'Illegal type conversion: "Array[0..' +
                        IntToStr(Elements(GetIdent(TokenAt(j + 2).Name^)) - 1) + '] Of ' +
                        InfoAboutToken(VarType) + '" to "' + IdentifierAt(IdentIndex).Name + '"');

                // perl
                CheckTok(i + 1, CPARTOK);

                Inc(i);

                CheckTok(i + 1, OBRACKETTOK);

                i := CompileArrayIndex(i, IdentIndex, VarType);

                CheckTok(i + 1, CBRACKETTOK);

                Inc(i);

                asm65(#9'lda :STACKORIGIN-1,x');
                asm65(#9'add :STACKORIGIN,x');
                asm65(#9'sta :STACKORIGIN-1,x');
                asm65(#9'lda :STACKORIGIN-1+STACKWIDTH,x');
                asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                asm65(#9'sta :STACKORIGIN-1+STACKWIDTH,x');

                asm65(#9'dex');

              end
              else

                if TokenAt(i + 1).Kind = OPARTOK then
                begin        // (pointer)

                  //  writeln('= ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).Kind,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType);

                  if not (IdentifierAt(IdentIndex).DataType in [POINTERTOK, RECORDTOK, OBJECTTOK]) then
                    Error(i, IllegalExpression);

                  if IdentifierAt(IdentIndex).DataType = POINTERTOK then
                    VarType := IdentifierAt(IdentIndex).AllocElementType
                  else
                    VarType := IdentifierAt(IdentIndex).DataType;


                  i := CompileExpression(i + 2, ExpressionType, POINTERTOK);

                  CheckTok(i + 1, CPARTOK);


                  if (VarType in [RECORDTOK, OBJECTTOK]) and (TokenAt(i + 2).Kind = DOTTOK) then
                  begin

                    IndirectionLevel := ASPOINTERTODEREFERENCE;

                    CheckTok(i + 3, IDENTTOK);
                    IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);    // (pointer^).field :=

                    if IdentTemp < 0 then
                      Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');

                    VarType := IdentTemp shr 16;
                    par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                    Inc(i, 2);

                  end
                  else

                    if TokenAt(i + 2).Kind = DEREFERENCETOK then
                    begin

                      IndirectionLevel := ASPOINTERTODEREFERENCE;

                      Inc(i);

                      if (VarType in [RECORDTOK, OBJECTTOK]) and (TokenAt(i + 2).Kind = DOTTOK) then
                      begin

                        CheckTok(i + 3, IDENTTOK);
                        IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);    // (pointer)^.field :=

                        if IdentTemp < 0 then
                          Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');

                        VarType := IdentTemp shr 16;
                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                        Inc(i, 2);

                      end;

                    end
                    else
                    begin

                      if (VarType in [RECORDTOK, OBJECTTOK]) and (TokenAt(i + 2).Kind = DOTTOK) then
                      begin

                        IndirectionLevel := ASPOINTERTODEREFERENCE;

                        CheckTok(i + 3, IDENTTOK);
                        IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);    // (pointer).field :=

                        if IdentTemp < 0 then
                          Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');

                        VarType := IdentTemp shr 16;
                        par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                        Inc(i, 2);

                      end;

                    end;


                  Inc(i);

                end
                else

                  if TokenAt(i + 1).Kind = DEREFERENCETOK then        // With dereferencing '^'
                  begin

                    if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                      Error(i + 1, IncompatibleTypeOf, IdentIndex);

                    if (IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK) and
                      (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                      VarType := STRINGPOINTERTOK
                    else
                      VarType := IdentifierAt(IdentIndex).AllocElementType;

                    IndirectionLevel := ASPOINTERTOPOINTER;


                    //  writeln('= ',IdentifierAt(IdentIndex).name,',',VarTYpe,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).PassMethod);


                    if TokenAt(i + 2).Kind = OBRACKETTOK then
                    begin        // pp^[index] :=

                      Inc(i);

                      if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                        Error(i + 1, IncompatibleTypeOf, IdentIndex);

                      IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

                      i := CompileArrayIndex(i, IdentIndex, VarType);

                      CheckTok(i + 1, CBRACKETTOK);

                    end
                    else

                      if (VarType in [RECORDTOK, OBJECTTOK]) and (TokenAt(i + 2).Kind = DOTTOK) then
                      begin

                        CheckTok(i + 3, IDENTTOK);
                        IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);

                        if IdentTemp < 0 then
                          Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');


                        if TokenAt(i + 4).Kind = OBRACKETTOK then
                        begin        // pp^.field[index] :=

                          if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                            Error(i + 2, IncompatibleTypeOf, IdentIndex);

                          par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                          IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                          i := CompileArrayIndex(i + 3, GetIdent(IdentifierAt(IdentIndex).Name +
                            '.' + TokenAt(i + 3).Name^), VarType);

                          CheckTok(i + 1, CBRACKETTOK);

                        end
                        else
                        begin              // pp^.field :=

                          VarType := IdentTemp shr 16;
                          par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                          if GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name^) > 0 then
                            IdentIndex := GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name^);

                          Inc(i, 2);

                        end;

                      end;

                    i := i + 1;
                  end
                  else if (TokenAt(i + 1).Kind = OBRACKETTOK) then        // With indexing
                    begin

                      if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                        Error(i + 1, IncompatibleTypeOf, IdentIndex);

                      IndirectionLevel := ASPOINTERTOARRAYORIGIN2;

                      j := i;

                      i := CompileArrayIndex(i, IdentIndex, VarType);

                      if VarType = ARRAYTOK then
                      begin
                        IndirectionLevel := ASPOINTER;
                        VarType := POINTERTOK;
                      end;


                      if TokenAt(i + 2).Kind = DEREFERENCETOK then
                      begin
                        Inc(i);

                        Push(0, ASPOINTERTOARRAYORIGIN2, DataSize[VarType], IdentIndex, 0);

                      end;

                      // label.field[index] -> label + field[index]

                      if pos('.', IdentifierAt(IdentIndex).Name) > 0 then
                      begin      // record_ptr.field[index] :=

                        IdentTemp := GetIdent(copy(IdentifierAt(IdentIndex).Name, 1, pos('.', IdentifierAt(IdentIndex).Name) - 1));

                        if (IdentifierAt(IdentTemp).DataType = POINTERTOK) and
                          (IdentifierAt(IdentTemp).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                        begin
                          IndirectionLevel := ASPOINTERTORECORDARRAYORIGIN;

                          svar := copy(IdentifierAt(IdentIndex).Name, pos('.', IdentifierAt(IdentIndex).Name) +
                            1, length(IdentifierAt(IdentIndex).Name));

                          IdentIndex := IdentTemp;

                          IdentTemp := RecordSize(IdentIndex, svar);

                          if IdentTemp < 0 then
                            Error(i + 3, 'identifier idents no member ''' + svar + '''');

                          par2 := '$' + IntToHex(IdentTemp and $ffff, 2);      // offset to record field -> 'svar'

                        end;

                      end;


                      //      writeln(IdentifierAt(IdentIndex).Name,',',vartype,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).Kind);//+ '.' + TokenAt(i + 3).Name^);

                      if (VarType in [RECORDTOK, OBJECTTOK]) and (TokenAt(i + 2).Kind = DOTTOK) then
                      begin
                        IndirectionLevel := ASPOINTERTOARRAYRECORD;

                        CheckTok(i + 3, IDENTTOK);
                        IdentTemp := RecordSize(IdentIndex, TokenAt(i + 3).Name^);

                        if IdentTemp < 0 then
                          Error(i + 3, 'identifier idents no member ''' + TokenAt(i + 3).Name^ + '''');


                        //         writeln('>',IdentifierAt(IdentIndex).Name+ '||' + TokenAt(i + 3).Name^,',',IdentTemp shr 16,',',VarType,'||',TokenAt(i+4].Kind,',',IdentifierAt(GetIdent(IdentifierAt(IdentIndex).Name+ '.' + TokenAt(i + 3).Name^)].AllocElementTYpe);


                        if TokenAt(i + 4).Kind = OBRACKETTOK then
                        begin        // array_to_record_pointers[x].field[index] :=

                          if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                            Error(i + 2, IncompatibleTypeOf, IdentIndex);

                          par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                          IndirectionLevel := ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN;

                          i := CompileArrayIndex(i + 3, GetIdent(IdentifierAt(IdentIndex).Name +
                            '.' + TokenAt(i + 3).Name^), VarType);

                          CheckTok(i + 1, CBRACKETTOK);

                        end
                        else
                        begin                // array_to_record_pointers[x].field :=
                          //-------
                          VarType := IdentTemp shr 16;
                          par2 := '$' + IntToHex(IdentTemp and $ffff, 2);

                          if GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name^) > 0 then
                            IdentIndex := GetIdent(IdentifierAt(IdentIndex).Name + '.' + TokenAt(i + 3).Name^);

                          if VarType = STRINGPOINTERTOK then IndirectionLevel := ASPOINTERTOARRAYRECORDTOSTRING;

                          Inc(i, 2);

                        end;

                      end
                      else
                        if VarType in [RECORDTOK, OBJECTTOK, PROCVARTOK] then VarType := POINTERTOK;

                      //CheckTok(i + 1, CBRACKETTOK);

                      Inc(i);

                    end
                    else                // Without dereferencing or indexing
                    begin

                      if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) then
                      begin
                        IndirectionLevel := ASPOINTERTOPOINTER;

                        if IdentifierAt(IdentIndex).AllocElementType = UNTYPETOK then
                          VarType := IdentifierAt(IdentIndex).DataType      // RECORD.
                        else
                          VarType := IdentifierAt(IdentIndex).AllocElementType;

                      end
                      else
                      begin
                        IndirectionLevel := ASPOINTER;

                        VarType := IdentifierAt(IdentIndex).DataType;
                      end;

                      //  writeln('= ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', VarType,',',IndirectionLevel);

                    end;


              if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType = PROCVARTOK) and
                (TokenAt(i + 1).Kind <> ASSIGNTOK) then
              begin

                IdentTemp := GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

                CompileActualParameters(i, IdentTemp, IdentIndex);

                if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then a65(__subBX);

                Result := i;
                exit;

              end
              else
                CheckTok(i + 1, ASSIGNTOK);


              //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IndirectionLevel);


              if (IdentifierAt(IdentIndex).DataType = PCHARTOK) and
                //         ( (IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (IdentifierAt(IdentIndex).PassMethod = VARPASSING)) ) and
                (IndirectionLevel = ASPOINTER) and (TokenAt(i + 2).Kind in [STRINGLITERALTOK,
                CHARLITERALTOK, IDENTTOK]) then
              begin

{$i include/compile_pchar.inc}

              end
              else

                if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType = CHARTOK) and
                  (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                  ((IndirectionLevel in [ASPOINTER, ASPOINTERTOPOINTER]) or
                  ((IndirectionLevel = ASPOINTERTOARRAYORIGIN) and (IdentifierAt(IdentIndex).PassMethod = VARPASSING))) and
                  (TokenAt(i + 2).Kind in [STRINGLITERALTOK, CHARLITERALTOK, IDENTTOK]) then
                begin

{$i include/compile_string.inc}

                end // if
                else
                begin                // Usual assignment

                  if VarType = UNTYPETOK then
                    Error(i, 'Assignments to formal parameters and open arrays are not possible');



                  Result := CompileExpression(i + 2, ExpressionType, VarType);  // Right-hand side expression



                  k := i + 2;


                  RealTypeConversion(VarType, ExpressionType);

                  if (VarType in [SHORTREALTOK, REALTOK]) and (ExpressionType in [SHORTREALTOK, REALTOK]) then
                    ExpressionType := VarType;


                  if (VarType = POINTERTOK) and (ExpressionType = STRINGPOINTERTOK) then
                  begin

                    if (IdentifierAt(IdentIndex).AllocElementType = CHARTOK) then
                    begin  // +1
                      asm65(#9'lda :STACKORIGIN,x');
                      asm65(#9'add #$01');
                      asm65(#9'sta :STACKORIGIN,x');
                      asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                      asm65(#9'adc #$00');
                      asm65(#9'sta :STACKORIGIN+STACKWIDTH,x');
                    end
                    else
                      if IdentifierAt(IdentIndex).AllocElementType = UNTYPETOK then
                        Error(i + 1, IncompatibleTypes, IdentIndex, STRINGPOINTERTOK, POINTERTOK)
                      else
                        GetCommonType(i + 1, IdentifierAt(IdentIndex).AllocElementType, STRINGPOINTERTOK);

                  end;


                  if (TokenAt(i).Kind = DEREFERENCETOK) and (VarType = POINTERTOK) and (ExpressionType = RECORDTOK) then
                  begin

                    ExpressionType := RECORDTOK;
                    VarType := RECORDTOK;

                  end;


                  //  if (TokenAt(k).Kind = IDENTTOK) then
                  //    writeln(IdentifierAt(IdentIndex).Name,'/',TokenAt(k).Name^,',', VarType,':', ExpressionType,' - ', IdentifierAt(IdentIndex).DataType,':',IdentifierAt(IdentIndex).AllocElementType,':',IdentifierAt(IdentIndex).NumAllocElements,' | ',IdentifierAt(GetIdent(TokenAt(k).Name^)].DataType,':',IdentifierAt(GetIdent(TokenAt(k).Name^)].AllocElementType,':',IdentifierAt(GetIdent(TokenAt(k).Name^)].NumAllocElements ,' / ',IndirectionLevel)
                  //  else
                  //    writeln(IdentifierAt(IdentIndex).Name,',', VarType,',', ExpressionType,' - ', IdentifierAt(IdentIndex).DataType,':',IdentifierAt(IdentIndex).AllocElementType,':',IdentifierAt(IdentIndex).NumAllocElements,' / ',IndirectionLevel);


                  if VarType <> ExpressionType then
                    if (ExpressionType = POINTERTOK) and (TokenAt(k).Kind = IDENTTOK) then
                      if (IdentifierAt(GetIdent(TokenAt(k).Name^)).DataType = POINTERTOK) and
                        (IdentifierAt(GetIdent(TokenAt(k).Name^)).AllocElementType = PROCVARTOK) then
                      begin

                        IdentTemp := GetIdent('@FN' + IntToHex(IdentifierAt(GetIdent(TokenAt(k).Name^)).NumAllocElements_, 4));

                        //CompileActualParameters(i, IdentTemp, GetIdent(TokenAt(k).Name^));

                        if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then ExpressionType := IdentifierAt(IdentTemp).DataType;

                      end;


                  CheckAssignment(i + 1, IdentIndex);

                  if (IndirectionLevel in [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2])
                  {and not (IdentifierAt(IdentIndex).AllocElementType in [PROCEDURETOK, FUNC])} then
                  begin

                    //  writeln(ExpressionType,' | ',IdentifierAt(IdentIndex).idtype,',', IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).Name,',',IndirectionLevel);
                    //  writeln(IdentifierAt(GetIdent(IdentifierAt(IdentIndex).Name)].AllocElementType);


                    if (ExpressionType = CHARTOK) and (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                      (IdentifierAt(IdentIndex).AllocElementType = STRINGPOINTERTOK) then

                      IndirectionLevel := ASSTRINGPOINTER1TOARRAYORIGIN    // tab[ ] := 'a'

                    else
                      if IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK] then
                      begin

                        if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (ExpressionType in
                          [RECORDTOK, OBJECTTOK]) then

                        else
                          GetCommonType(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

                      end
                      else
                        GetCommonType(i + 1, IdentifierAt(IdentIndex).AllocElementType, ExpressionType);

                  end
                  else
                    if (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK] + Pointers) then
                    begin

                      if (ExpressionType in Pointers - [STRINGPOINTERTOK]) and (TokenAt(k).Kind = IDENTTOK) then
                      begin

                        IdentTemp := GetIdent(TokenAt(k).Name^);

                        if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = FUNCTIONTOK) then
                          IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

        {if (TokenAt(i + 3).Kind <> OBRACKETTOK) and ((Elements(IdentTemp) <> Elements(IdentIndex)) or (IdentifierAt(IdentTemp).AllocElementType <> IdentifierAt(IdentIndex).AllocElementType)) then
         Error(k, IncompatibleTypesArray, GetIdent(TokenAt(k).Name^), ExpressionType )
        else
         if (Elements(IdentTemp) > 0) and (TokenAt(i + 3).Kind <> OBRACKETTOK) then
          Error(k, IncompatibleTypesArray, IdentTemp, ExpressionType )
        else}

                        if IdentifierAt(IdentTemp).AllocElementType = RECORDTOK then
                        // GetCommonType(i + 1, VarType, RECORDTOK)
                        else

                          if (IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK) and
                            (IdentifierAt(IdentTemp).AllocElementType <> UNTYPETOK) and (IdentifierAt(IdentTemp).AllocElementType <>
                            IdentifierAt(IdentIndex).AllocElementType) and (TokenAt(k + 1).Kind <> OBRACKETTOK) then
                          begin

                            if ((IdentifierAt(IdentTemp).NumAllocElements >
                              0) {and (IdentifierAt(IdentTemp).AllocElementType <> RECORDTOK)}) and
                              ((IdentifierAt(IdentIndex).NumAllocElements >
                              0) {and (IdentifierAt(IdentIndex).AllocElementType <> RECORDTOK)}) then

                              Error(k, IncompatibleTypesArray, IdentTemp, -IdentIndex)

                            else
                            begin

                              //      writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,':',IdentifierAt(IdentIndex).AllocElementType,':',IdentifierAt(IdentIndex).NumAllocElements,' | ',IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,':',IdentifierAt(IdentTemp).AllocElementType,':',IdentifierAt(IdentTemp).NumAllocElements);

                              if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                                (IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK) and
                                (IdentifierAt(IdentIndex).NumAllocElements = 0) and
                                (IdentifierAt(IdentTemp).DataType = POINTERTOK) and (IdentifierAt(IdentTemp).AllocElementType <>
                                UNTYPETOK) and (IdentifierAt(IdentTemp).NumAllocElements = 0) then
                                Error(k, 'Incompatible types: got "^' +
                                  InfoAboutToken(IdentifierAt(IdentTemp).AllocElementType) + '" expected "^' +
                                  InfoAboutToken(IdentifierAt(IdentIndex).AllocElementType) + '"')
                              else
                                Error(k, IncompatibleTypesArray, IdentTemp, ExpressionType);

                            end;

                          end;

                      end
                      else
                        if (ExpressionType in [RECORDTOK, OBJECTTOK]) then
                        begin

                          IdentTemp := GetIdent(TokenAt(k).Name^);

                          case IndirectionLevel of
                            ASPOINTER:
                              if (IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) and
                                not (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK]) then
                                Error(k, 'Incompatible types: got "' +
                                  Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                                  '" expected "^' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"');

                            ASPOINTERTOPOINTER:
                              if (IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) and
                                not (IdentifierAt(IdentTemp).DataType in [RECORDTOK, OBJECTTOK]) then
                                Error(k, 'Incompatible types: got "' +
                                  Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                                  '" expected "^' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"');
                            else
                              GetCommonType(i + 1, VarType, ExpressionType);

                          end;

                        end
                        else
                        begin

                          //     writeln('1> ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,', P:', IdentifierAt(IdentIndex).PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

                          if ((IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                            (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK])) or
                            ((VarType = STRINGPOINTERTOK) and (ExpressionType = PCHARTOK)) then

                          else
                            if (VarType in [RECORDTOK, OBJECTTOK]) then
                              Error(i, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) +
                                '" expected "' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"')
                            else
                              GetCommonType(i + 1, VarType, ExpressionType);

                        end;

                    end
                    else
                      if (VarType = ENUMTYPE) {and (TokenAt(k).Kind = IDENTTOK)} then
                      begin

                        if (TokenAt(k).Kind = IDENTTOK) then
                          IdentTemp := GetIdent(TokenAt(k).Name^)
                        else
                          IdentTemp := 0;

                        if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = FUNCTIONTOK) then
                          IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

                        if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = USERTYPE) and
                          (IdentifierAt(IdentTemp).DataType = ENUMTYPE) then
                        begin

                          if IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements then
                            Error(i, IncompatibleEnum, 0, IdentTemp, IdentIndex);

                        end
                        else
                          if (IdentTemp > 0) and (IdentifierAt(IdentTemp).Kind = ENUMTYPE) then
                          begin

                            if IdentifierAt(IdentTemp).NumAllocElements <> IdentifierAt(IdentIndex).NumAllocElements then
                              Error(i, IncompatibleEnum, 0, IdentTemp, IdentIndex);

                          end
                          else
                            if (IdentTemp > 0) and (IdentifierAt(IdentTemp).DataType = ENUMTYPE) then
                            begin

                              if IdentifierAt(IdentTemp).NumAllocElements <> IdentifierAt(IdentIndex).NumAllocElements then
                                Error(i, IncompatibleEnum, 0, IdentTemp, IdentIndex);

                            end
                            else
                              Error(i, IncompatibleEnum, 0, -ExpressionType, IdentIndex);

                      end
                      else
                      begin

                        if (TokenAt(k).Kind = IDENTTOK) then
                          IdentTemp := GetIdent(TokenAt(k).Name^)
                        else
                          IdentTemp := 0;

                        if (IdentTemp > 0) and ((IdentifierAt(IdentTemp).Kind = ENUMTYPE) or
                          (IdentifierAt(IdentTemp).DataType = ENUMTYPE)) then
                          Error(i, IncompatibleEnum, 0, IdentTemp, -ExpressionType)
                        else
                          GetCommonType(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

                      end;


                  ExpandParam(VarType, ExpressionType);           // :=

                  Ident[IdentIndex].isInit := True;


                  //  writeln(vartype,',',ExpressionType,',',IdentifierAt(IdentIndex).Name);

                  //       writeln('0> ',IdentifierAt(IdentIndex).Name,',',VarType,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', ExpressionType,',',IndirectionLevel);


                  if (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and (IndirectionLevel <>
                    ASPOINTERTODEREFERENCE) and (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                    (IdentifierAt(IdentIndex).NumAllocElements = 0) and (ExpressionType <> POINTERTOK) then
                  begin

                    if (IdentifierAt(IdentIndex).AllocElementType in {IntegerTypes}OrdinalTypes) and
                      (ExpressionType in {IntegerTypes}OrdinalTypes) then

                    else
                      if IdentifierAt(IdentIndex).AllocElementType <> UNTYPETOK then
                      begin

                        if (ExpressionType in [PCHARTOK, STRINGPOINTERTOK]) and
                          (IdentifierAt(IdentIndex).AllocElementType = CHARTOK) then

                        else
                          Error(i + 1, 'Incompatible types: got "' + InfoAboutToken(ExpressionType) +
                            '" expected "' + IdentifierAt(IdentIndex).Name + '"');

                      end
                      else
                        GetCommonType(i + 1, IdentifierAt(IdentIndex).DataType, ExpressionType);

                  end;


                  if (VarType in [RECORDTOK, OBJECTTOK]) or ((VarType = POINTERTOK) and
                    (ExpressionType in [RECORDTOK, OBJECTTOK])) then
                  begin

                    ADDRESS := False;

                    if TokenAt(k).Kind = ADDRESSTOK then
                    begin
                      Inc(k);

                      ADDRESS := True;
                    end;

                    if TokenAt(k).Kind <> IDENTTOK then Error(k, IdentifierExpected);

                    IdentTemp := GetIdent(TokenAt(k).Name^);


                    if IdentifierAt(IdentIndex).PassMethod = IdentifierAt(IdentTemp).PassMethod then
                      case IndirectionLevel of
                        ASPOINTER:
                          if (TokenAt(k + 1).Kind <> DEREFERENCETOK) and
                            (IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) and
                            not (IdentifierAt(IdentTemp).DataType in [RECORDTOK, OBJECTTOK]) then
                            Error(k, 'Incompatible types: got "^' +
                              Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name + '" expected "' +
                              Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"');

                        ASPOINTERTOPOINTER:
                          //         if {(TokenAt(i + 1).Kind <> DEREFERENCETOK) and }(IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) and not ( IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK] ) then
                          //          Error(k, 'Incompatible types: got "^' + Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +'" expected "' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"');
                        else
                          GetCommonType(i + 1, VarType, ExpressionType);

                      end;


                    if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                      (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK]) and
                      (IdentifierAt(IdentIndex).PassMethod = IdentifierAt(IdentTemp).PassMethod) then
                    begin

                      //       writeln('2> ',IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,' | ', IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType,',',IdentifierAt(IdentTemp).NumAllocElements);

                      if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then
                        yes := IdentifierAt(IdentIndex).NumAllocElements <>
                          IdentifierAt(GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock)).NumAllocElements
                      else
                        yes := IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements;


                      if yes and (ADDRESS = False) and (ExpressionType in [RECORDTOK, OBJECTTOK]) then
                        if (IdentifierAt(IdentTemp).DataType = POINTERTOK) and
                          (IdentifierAt(IdentTemp).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                          Error(i, 'Incompatible types: got "^' +
                            Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                            '" expected "^' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"')
                        else
                          Error(i, 'Incompatible types: got "' +
                            Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                            '" expected "^' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"');

                    end;


                    if (ExpressionType in [RECORDTOK, OBJECTTOK]) or
                      ((ExpressionType = POINTERTOK) and (IdentifierAt(IdentTemp).AllocElementType in
                      [RECORDTOK, OBJECTTOK])) then
                    begin

                      svar := TokenAt(k).Name^;

                      if (IdentifierAt(IdentTemp).DataType = RECORDTOK) and
                        (IdentifierAt(IdentTemp).AllocElementType <> RECORDTOK) then
                        Name := 'adr.' + svar
                      else
                        Name := svar;


                      if (IdentifierAt(IdentTemp).Kind = FUNCTIONTOK) then
                      begin
                        svar := GetLocalName(IdentTemp);

                        IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

                        Name := svar + '.adr.result';
                        svar := svar + '.result';
                      end;


                      DEREFERENCE := False;
                      if (TokenAt(k + 1).Kind = DEREFERENCETOK) then
                      begin
                        Inc(k);

                        DEREFERENCE := True;
                      end;


                      if TokenAt(k + 1).Kind = DOTTOK then
                      begin

                        CheckTok(k + 2, IDENTTOK);

                        Name := svar + '.' + TokenAt(k + 2).Name^;
                        IdentTemp := GetIdent(Name);

                      end;

                      //writeln( IdentifierAt(IdentIndex).Name,',', IdentifierAt(IdentIndex).NumAllocElements, ',', IdentifierAt(IdentIndex).AllocElementType  ,' / ', IdentifierAt(IdentTemp).Name,',', IdentifierAt(IdentTemp).NumAllocElements,',',IdentifierAt(IdentTemp).AllocElementType );
                      //writeln( '>', IdentifierAt(IdentIndex).Name,',', IdentifierAt(IdentIndex).DataType, ',', IdentifierAt(IdentIndex).AllocElementTYpe );
                      //writeln( '>', IdentifierAt(IdentTemp).Name,',', IdentifierAt(IdentTemp).DataType, ',', IdentifierAt(IdentTemp).AllocElementTYpe );
                      //writeln(Types[5].Field[0].Name);

                      if IdentTemp > 0 then

                        if IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements then
                          // porownanie indeksow do tablicy TYPES
                          //      Error(i, IncompatibleTypeOf, IdentTemp);
                          if (IdentifierAt(IdentIndex).NumAllocElements = 0) then
                            Error(i, 'Incompatible types: got "' +
                              Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                              '" expected "' + InfoAboutToken(IdentifierAt(IdentIndex).DataType) + '"')
                          else
                            Error(i, 'Incompatible types: got "' +
                              Types[IdentifierAt(IdentTemp).NumAllocElements].Field[0].Name +
                              '" expected "' + Types[IdentifierAt(IdentIndex).NumAllocElements].Field[0].Name + '"');


                      a65(__subBX);
                      StopOptimization;

                      ResetOpty;


                      if (IdentifierAt(IdentIndex).DataType = RECORDTOK) and (IdentifierAt(IdentTemp).DataType = RECORDTOK) and
                        (IdentifierAt(IdentTemp).AllocElementTYpe = RECORDTOK) then
                      begin

                        if DEREFERENCE then
                        begin                // issue #98 fixed

                          asm65(#9'lda :bp2');
                          asm65(#9'add #' + Name + '-DATAORIGIN');
                          asm65(#9'sta :bp2');
                          asm65(#9'lda :bp2+1');
                          asm65(#9'adc #$00');
                          asm65(#9'sta :bp2+1');

                        end
                        else
                        begin

                          asm65(#9'sta :bp2');
                          asm65(#9'sty :bp2+1');

                        end;

{
            if RecordSize(IdentIndex) <= 8 then begin

       asm65(#9'ldy #$00');

       for j:=0 to RecordSize(IdentIndex)-1 do begin
        asm65(#9'lda (:bp2),y');
        asm65(#9'sta adr.'+IdentifierAt(IdentIndex).Name + '+' + IntToStr(j));

        if j <> RecordSize(IdentIndex)-1 then asm65(#9'iny');
       end;
}
                        if RecordSize(IdentIndex) <= 128 then
                        begin

                          asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                          asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

                        end
                        else
                          asm65(#9'@move ":bp2" ' + GetLocalName(IdentIndex) + ' #' +
                            IntToStr(RecordSize(IdentIndex)));

                      end
                      else
                        if (IdentifierAt(IdentIndex).DataType = RECORDTOK) and (IdentifierAt(IdentTemp).DataType = RECORDTOK) and
                          (RecordSize(IdentIndex) <= 8) then
                        begin

                          if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
                          begin

                            svar := GetLocalName(IdentIndex);
                            LoadBP2(IdentIndex, svar);

                            asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                            asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

                          end
                          else
                            if RecordSize(IdentIndex) = 1 then
                              asm65(#9' mva ' + Name + ' ' + GetLocalName(IdentIndex, 'adr.'))
                            else
                              asm65(#9':' + IntToStr(RecordSize(IdentIndex)) + ' mva ' + Name +
                                '+# ' + GetLocalName(IdentIndex, 'adr.') + '+#');

                        end
                        else
                          if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and
                            (IdentifierAt(IdentTemp).DataType = POINTERTOK) then
                          begin

                            //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType ,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).pASSmETHOD);
                            //  writeln(IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType ,',',IdentifierAt(IdentTemp).NumAllocElements,'/',IdentifierAt(IdentTemp).NumAllocElements_,',',IdentifierAt(IdentTemp).pASSmETHOD);
                            //  writeln('--- ', IndirectionLevel);

                            asm65(#9'@move ' + Name + ' ' + GetLocalName(IdentIndex) + ' #' +
                              IntToStr(RecordSize(IdentIndex)));

                          end
                          else
                            if (IdentifierAt(IdentIndex).DataType = RECORDTOK) and
                              (IdentifierAt(IdentTemp).DataType = POINTERTOK) then
                            begin

                              //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType ,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).pASSmETHOD);
                              //  writeln(IdentifierAt(IdentTemp).Name,',',IdentifierAt(IdentTemp).DataType,',',IdentifierAt(IdentTemp).AllocElementType ,',',IdentifierAt(IdentTemp).NumAllocElements,'/',IdentifierAt(IdentTemp).NumAllocElements_,',',IdentifierAt(IdentTemp).pASSmETHOD);
                              //  writeln('--- ', IndirectionLevel);


                              if IdentifierAt(IdentTemp).PassMethod = VARPASSING then
                              begin

                                asm65(#9'mwy ' + GetLocalName(IdentTemp) + ' :bp2');

                                if RecordSize(IdentIndex) <= 128 then
                                begin

                                  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                  asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

                                end
                                else
                                  asm65(#9'@move ":bp2" #' + GetLocalName(IdentIndex, 'adr.') +
                                    ' #' + IntToStr(RecordSize(IdentIndex)));

                              end
                              else

                                if RecordSize(IdentIndex) <= 128 then
                                begin

                                  asm65(#9'mwy ' + GetLocalName(IdentTemp) + ' :bp2');

                                  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                  asm65(#9'mva:rpl (:bp2),y ' + GetLocalName(IdentIndex, 'adr.') + ',y-');

                                end
                                else
                                  asm65(#9'@move ' + Name + ' #' + GetLocalName(IdentIndex, 'adr.') +
                                    ' #' + IntToStr(RecordSize(IdentIndex)));

                            end
                            else
                            begin

                              if IdentifierAt(IdentIndex).PassMethod = VARPASSING then
                              begin

                                svar := GetLocalName(IdentIndex);
                                LoadBP2(IdentIndex, svar);

                                if RecordSize(IdentIndex) <= 128 then
                                begin

                                  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                  asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

                                end
                                else
                                  asm65(#9'@move #' + Name + ' ":bp2" #' + IntToStr(RecordSize(IdentIndex)));

                              end
                              else

                                if (pos('adr.', Name) > 0) and (RecordSize(IdentIndex) <= 128) then
                                begin

                                  if IndirectionLevel = ASPOINTERTOARRAYORIGIN2 then
                                  begin

                                    asm65(#9'lda' + GetStackVariable(0));
                                    asm65(#9'sta :bp2');
                                    asm65(#9'lda' + GetStackVariable(1));
                                    asm65(#9'sta :bp2+1');

                                  end
                                  else
                                    asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                                  asm65(#9'ldy #$' + IntToHex(RecordSize(IdentIndex) - 1, 2));
                                  asm65(#9'mva:rpl ' + Name + ',y (:bp2),y-');

                                end
                                else
                                  asm65(#9'@move #' + Name + ' ' + GetLocalName(IdentIndex) +
                                    ' #' + IntToStr(RecordSize(IdentIndex)));

                            end;

                    end
                    else     // ExpressionType <> RECORDTOK + OBJECTTOK
                      GetCommonType(i + 1, ExpressionType, RECORDTOK);

                  end
                  else

                    if// (TokenAt(k).Kind = IDENTTOK) and
                    (VarType = STRINGPOINTERTOK) and (ExpressionType in Pointers)
                    {and (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK])} then
                    begin

                      //  writeln(IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType ,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).Name,',',IndirectionLevel,',',vartype,' || ',IdentifierAt(GetIdent(TokenAt(k).Name^)].NumAllocElements,',',IdentifierAt(GetIdent(TokenAt(k).Name^)].PassMethod);

                      //  writeln(address,',',TokenAt(k).kind,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).AllocElementType,' / ', VarType,',',ExpressionType,',',IndirectionLevel);


                      if (TokenAt(k).Kind <> ADDRESSTOK) and (IndirectionLevel in
                        [ASPOINTERTOARRAYORIGIN, ASPOINTERTOARRAYORIGIN2]) and (IdentifierAt(IdentIndex).AllocElementType =
                        STRINGPOINTERTOK) then
                      begin

                        if (TokenAt(k).Kind = IDENTTOK) and (IdentifierAt(GetIdent(TokenAt(k).Name^)).AllocElementType <>
                          UNTYPETOK) then
                          IndirectionLevel := ASSTRINGPOINTERTOARRAYORIGIN;

                        GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex);

                        StopOptimization;

                        ResetOpty;

                      end
                      else
                        GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

                    end
                    else


                    // dla PROC, FUNC -> IdentifierAt(GetIdent(TokenAt(k).Name^)].NumAllocElements -> oznacza liczbe parametrow takiej procedury/funkcji

                      if (VarType in Pointers) and ((ExpressionType in Pointers) and (TokenAt(k).Kind = IDENTTOK)) and
                        (not (IdentifierAt(IdentIndex).AllocElementType in Pointers + [RECORDTOK, OBJECTTOK]) and
                        not (IdentifierAt(GetIdent(TokenAt(k).Name^)).AllocElementType in Pointers + [RECORDTOK, OBJECTTOK])) then
                      begin

                        j := Elements(IdentIndex) {IdentifierAt(IdentIndex).NumAllocElements} *
                          DataSize[IdentifierAt(IdentIndex).AllocElementType];

                        IdentTemp := GetIdent(TokenAt(k).Name^);

                        Name := 'adr.' + TokenAt(k).Name^;
                        svar := TokenAt(k).Name^;

                        if IdentTemp > 0 then
                        begin

                          if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then
                          begin

                            svar := GetLocalName(IdentTemp);

                            IdentTemp := GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock);

                            Name := svar + '.adr.result';
                            svar := svar + '.result';

                          end;


                          //if (IdentifierAt(IdentIndex).NumAllocElements > 1) and (IdentifierAt(IdentTemp).NumAllocElements > 1) then begin
                          if (Elements(IdentIndex) > 1) and (Elements(IdentTemp) > 1) then
                          begin

                            //writeln(j,',', Elements(IdentTemp) );
                            // perl
                            if IdentifierAt(IdentTemp).AllocElementType <> RECORDTOK then
                              if (j <> Integer(Elements(IdentTemp) {IdentifierAt(IdentTemp).NumAllocElements} *
                                DataSize[IdentifierAt(IdentTemp).AllocElementType])) then
                                if (IdentifierAt(IdentIndex).AllocElementType <> IdentifierAt(IdentTemp).AllocElementType) or
                                  ((IdentifierAt(IdentTemp).NumAllocElements <> IdentifierAt(IdentIndex).NumAllocElements_) and
                                  (IdentifierAt(IdentTemp).NumAllocElements_ = 0)) or
                                  ((IdentifierAt(IdentIndex).NumAllocElements <> IdentifierAt(IdentTemp).NumAllocElements_) and
                                  (IdentifierAt(IdentIndex).NumAllocElements_ = 0)) then
                                  Error(i, IncompatibleTypesArray, IdentTemp, -IdentIndex);

{
           a65(__subBX);
        StopOptimization;

        ResetOpty;
}

                            if j <> Integer(Elements(IdentTemp) * DataSize[IdentifierAt(IdentTemp).AllocElementType]) then
                            begin

                              if (IdentifierAt(IdentIndex).NumAllocElements_ > 0) and
                                ((IdentifierAt(IdentIndex).NumAllocElements_ = IdentifierAt(IdentTemp).NumAllocElements) or
                                (IdentifierAt(IdentIndex).NumAllocElements_ = IdentifierAt(IdentTemp).NumAllocElements_)) then
                              begin

                                //writeln(TokenAt(k).line,',', IdentifierAt(IdentTemp).NumAllocElements_);

                                if IdentifierAt(IdentTemp).NumAllocElements_ = 0 then
                                begin

                                  asm65(#9'lda ' + GetLocalName(IdentIndex));
                                  asm65(#9'add :STACKORIGIN-1,x');
                                  asm65(#9'sta @move.dst');
                                  asm65(#9'lda ' + GetLocalName(IdentIndex) + '+1');
                                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                                  asm65(#9'sta @move.dst+1');

                                  asm65(#9'lda ' + GetLocalName(IdentTemp));
                                  asm65(#9'sta @move.src');
                                  asm65(#9'lda ' + GetLocalName(IdentTemp) + '+1');
                                  asm65(#9'sta @move.src+1');

                                end
                                else
                                begin
                                  a65(__subBX);

                                  asm65(#9'lda ' + GetLocalName(IdentIndex));
                                  asm65(#9'add :STACKORIGIN-1,x');
                                  asm65(#9'sta @move.dst');
                                  asm65(#9'lda ' + GetLocalName(IdentIndex) + '+1');
                                  asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                                  asm65(#9'sta @move.dst+1');

                                  asm65(#9'lda ' + GetLocalName(IdentTemp));
                                  asm65(#9'add :STACKORIGIN,x');
                                  asm65(#9'sta @move.src');
                                  asm65(#9'lda ' + GetLocalName(IdentTemp) + '+1');
                                  asm65(#9'adc :STACKORIGIN+STACKWIDTH,x');
                                  asm65(#9'sta @move.src+1');

                                end;

                                a65(__subBX);
                                a65(__subBX);
                                StopOptimization;

                                ResetOpty;

                                asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements_ *
                                  DataSize[IdentifierAt(IdentIndex).AllocElementType]));
                                asm65(#9'sta @move.cnt');
                                asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements_ *
                                  DataSize[IdentifierAt(IdentIndex).AllocElementType]));
                                asm65(#9'sta @move.cnt+1');

                                asm65(#9'jsr @move');

                              end
                              else
                              begin

                                //writeln('2: ',IdentifierAt(IdentIndex).NumAllocElements);

                                asm65(#9'lda ' + GetLocalName(IdentIndex));
                                asm65(#9'sta @move.dst');
                                asm65(#9'lda ' + GetLocalName(IdentIndex) + '+1');
                                asm65(#9'sta @move.dst+1');

                                asm65(#9'lda ' + GetLocalName(IdentTemp));
                                asm65(#9'add :STACKORIGIN-1,x');
                                asm65(#9'sta @move.src');
                                asm65(#9'lda ' + GetLocalName(IdentTemp) + '+1');
                                asm65(#9'adc :STACKORIGIN-1+STACKWIDTH,x');
                                asm65(#9'sta @move.src+1');

                                a65(__subBX);
                                a65(__subBX);
                                StopOptimization;

                                ResetOpty;

                                asm65(#9'lda <' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements *
                                  DataSize[IdentifierAt(IdentIndex).AllocElementType]));
                                asm65(#9'sta @move.cnt');
                                asm65(#9'lda >' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements *
                                  DataSize[IdentifierAt(IdentIndex).AllocElementType]));
                                asm65(#9'sta @move.cnt+1');

                                asm65(#9'jsr @move');

                              end;

                            end
                            else
                            begin

                              a65(__subBX);
                              StopOptimization;

                              ResetOpty;

                              if (j <= 4) and (IdentifierAt(IdentTemp).AllocElementType <> RECORDTOK) then
                                asm65(#9':' + IntToStr(j) + ' mva ' + Name + '+# ' +
                                  GetLocalName(IdentIndex, 'adr.') + '+#')
                              else
                                asm65(#9'@move ' + svar + ' ' + GetLocalName(IdentIndex) + ' #' + IntToStr(j));

                            end;

                          end
                          else
                            GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

                        end
                        else
                          Error(k, UnknownIdentifier);

                      end
                      else
                        GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex, par1, par2);

                end;

              //      StopOptimization;

            end;// VARIABLE


            PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK:
              // Procedure, Function (without assignment) call
            begin

              Param := NumActualParameters(i, IdentIndex, j);

              //    if IdentifierAt(IdentIndex).isOverload then begin
              IdentTemp := GetIdentProc(IdentifierAt(IdentIndex).Name, IdentIndex, Param, j);

              if IdentTemp = 0 then
                if IdentifierAt(IdentIndex).isOverload then
                begin

                  if IdentifierAt(IdentIndex).NumParams <> j then
                    Error(i, WrongNumParameters, IdentIndex);

                  Error(i, CantDetermine, IdentIndex);
                end
                else
                  Error(i, WrongNumParameters, IdentIndex);

              IdentIndex := IdentTemp;

              //    end;

              if (IdentifierAt(IdentIndex).isStdCall = False) then
                StartOptimization(i)
              else
                if common.optimize.use = False then StartOptimization(i);


              Inc(run_func);

              CompileActualParameters(i, IdentIndex);

              Dec(run_func);

              if IdentifierAt(IdentIndex).Kind = FUNCTIONTOK then
              begin
                a65(__subBX);              // zmniejsz wskaznik stosu skoro nie odbierasz wartosci funkcji
                StartOptimization(i);
              end;

              Result := i;
            end;  // PROC

            else
              Error(i, 'Assignment or procedure call expected but ' + IdentifierAt(IdentIndex).Name + ' found');
          end// case IdentifierAt(IdentIndex).Kind
        else
          Error(i, UnknownIdentifier);
      end;

      INFOTOK:
      begin

        if Pass = CODEGENERATIONPASS then writeln('User defined: ' + msgUser[TokenAt(i).Value]);

        Result := i;
      end;


      WARNINGTOK:
      begin

        Warning(i, UserDefined);

        Result := i;
      end;


      ERRORTOK:
      begin

        if Pass = CODEGENERATIONPASS then Error(i, UserDefined);

        Result := i;
      end;


      IOCHECKON:
      begin
        IOCheck := True;

        Result := i;
      end;


      IOCHECKOFF:
      begin
        IOCheck := False;

        Result := i;
      end;


      LOOPUNROLLTOK:
      begin
        loopunroll := True;

        Result := i;
      end;


      NOLOOPUNROLLTOK:
      begin
        loopunroll := False;

        Result := i;
      end;


      PROCALIGNTOK:
      begin
        codealign.proc := TokenAt(i).Value;

        Result := i;
      end;


      LOOPALIGNTOK:
      begin
        codealign.loop := TokenAt(i).Value;

        Result := i;
      end;


      LINKALIGNTOK:
      begin
        codealign.link := TokenAt(i).Value;

        Result := i;
      end;


      GOTOTOK:
      begin
        CheckTok(i + 1, IDENTTOK);

        IdentIndex := GetIdent(TokenAt(i + 1).Name^);

        if IdentIndex > 0 then
        begin

          if IdentifierAt(IdentIndex).Kind <> LABELTYPE then
            Error(i + 1, 'Identifier isn''t a label');

          asm65(#9'jmp ' + IdentifierAt(IdentIndex).Name);

        end
        else
          Error(i + 1, UnknownIdentifier);

        Result := i + 1;
      end;


      BEGINTOK:
      begin

        if isAsm then
          CheckTok(i, ASMTOK);

        j := CompileStatement(i + 1);
        while (TokenAt(j + 1).Kind = SEMICOLONTOK) or ((TokenAt(j + 1).Kind = COLONTOK) and (TokenAt(j).Kind = IDENTTOK)) do
          j := CompileStatement(j + 2);

        CheckTok(j + 1, ENDTOK);

        Result := j + 1;
      end;


      CASETOK:
      begin
        CaseLocalCnt := CaseCnt;
        Inc(CaseCnt);

        ResetOpty;

        EnumName := '';

        StartOptimization(i);

        j := i + 1;

        i := CompileExpression(i + 1, SelectorType);


        if (SelectorType = ENUMTYPE) and (TokenAt(j).Kind = IDENTTOK) and
          (IdentifierAt(GetIdent(TokenAt(j).Name^)).Kind = FUNCTIONTOK) then
        begin

          IdentTemp := GetIdent(TokenAt(j).Name^);

          SelectorType := IdentifierAt(GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock)).AllocElementType;

          EnumName := Types[IdentifierAt(GetIdentResult(IdentifierAt(IdentTemp).ProcAsBlock)).NumAllocElements].Field[0].Name;

        end
        else
          if (SelectorType = ENUMTYPE) and (TokenAt(j).Kind = IDENTTOK) and
            (IdentifierAt(GetIdent(TokenAt(j).Name^)).Kind = TYPETOK) then
          begin

            IdentTemp := GetIdent(TokenAt(j).Name^);

            EnumName := GetEnumName(IdentTemp);

            SelectorType := IdentifierAt(IdentTemp).AllocElementType;

          end
          else
            if TokenAt(i).Kind = IDENTTOK then
            begin

              IdentTemp := GetIdent(TokenAt(i).Name^);

              EnumName := GetEnumName(IdentTemp);

            end;


        if SelectorType <> ENUMTYPE then
          if DataSize[SelectorType] <> 1 then
            Error(i, 'Expected BYTE, SHORTINT, CHAR or BOOLEAN as CASE selector');

        if not (SelectorType in OrdinalTypes + [ENUMTYPE]) then
          Error(i, 'Ordinal variable expected as ''CASE'' selector');

        CheckTok(i + 1, OFTOK);


        GenerateAssignment(ASPOINTER, DataSize[SelectorType], 0, '@CASETMP_' + IntToHex(CaseLocalCnt, 4));

        DefineIdent(i, '@CASETMP_' + IntToHex(CaseLocalCnt, 4), VARIABLE, SelectorType, 0, 0, 0);

        GetIdent('@CASETMP_' + IntToHex(CaseLocalCnt, 4));

        yes := True;

        NumCaseStatements := 0;

        Inc(i, 2);

        SetLength(CaseLabelArray, 1);

        repeat  // Loop over all cases

          //      yes:=false;

          repeat  // Loop over all constants for the current case
            i := CompileConstExpression(i, ConstVal, ConstValType, SelectorType);

            //   ConstVal:=ConstVal and $ff;
            //warning(i, RangeCheckError, 0, ConstValType, SelectorType);

            GetCommonType(i, ConstValType, SelectorType);


            if (TokenAt(i).Kind = IDENTTOK) then
              if ((EnumName = '') and (GetEnumName(GetIdent(TokenAt(i).Name^)) <> '')) or
                ((EnumName <> '') and (GetEnumName(GetIdent(TokenAt(i).Name^)) <> EnumName)) then
                Error(i, 'Constant and CASE types do not match');


            if TokenAt(i + 1).Kind = RANGETOK then            // Range check
            begin
              i := CompileConstExpression(i + 2, ConstVal2, ConstValType, SelectorType);

              //    ConstVal2:=ConstVal2 and $ff;
              //warning(i, RangeCheckError, 0, ConstValType, SelectorType);

              GetCommonType(i, ConstValType, SelectorType);

              if ConstVal > ConstVal2 then
                Error(i, 'Upper bound of case range is less than lower bound');

              GenerateCaseRangeCheck(ConstVal, ConstVal2, SelectorType, yes, CaseLocalCnt);

              yes := False;

              CaseLabel.left := ConstVal;
              CaseLabel.right := ConstVal2;
            end
            else
            begin
              GenerateCaseEqualityCheck(ConstVal, SelectorType, yes, CaseLocalCnt);    // Equality check

              yes := True;

              CaseLabel.left := ConstVal;
              CaseLabel.right := ConstVal;
            end;

            UpdateCaseLabels(i, CaseLabelArray, CaseLabel);

            Inc(i);

            ExitLoop := False;
            if TokenAt(i).Kind = COMMATOK then
              Inc(i)
            else
              ExitLoop := True;

          until ExitLoop;


          CheckTok(i, COLONTOK);

          GenerateCaseStatementProlog; //(CaseLabel.equality);

          ResetOpty;

          asm65('@');

          j := CompileStatement(i + 1);
          i := j + 1;
          GenerateCaseStatementEpilog(CaseLocalCnt);

          Inc(NumCaseStatements);

          ExitLoop := False;
          if TokenAt(i).Kind <> SEMICOLONTOK then
          begin
            if TokenAt(i).Kind = ELSETOK then        // Default statements
            begin

              j := CompileStatement(i + 1);
              while TokenAt(j + 1).Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

              i := j + 1;
            end;
            ExitLoop := True;
          end
          else
          begin
            Inc(i);

            if TokenAt(i).Kind = ELSETOK then
            begin
              j := CompileStatement(i + 1);
              while TokenAt(j + 1).Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

              i := j + 1;
            end;

            if TokenAt(i).Kind = ENDTOK then ExitLoop := True;

          end

        until ExitLoop;

        CheckTok(i, ENDTOK);

        GenerateCaseEpilog(NumCaseStatements, CaseLocalCnt);

        Result := i;
      end;


      IFTOK:
      begin
        ifLocalCnt := ifCnt;
        Inc(ifCnt);

        //    ResetOpty;

        StartOptimization(i + 1);

        j := CompileExpression(i + 1, ExpressionType);  // !!! VarType = INTEGERTOK, 'IF BYTE+SHORTINT < BYTE'

        GetCommonType(j, BOOLEANTOK, ExpressionType);  // wywali blad jesli warunek bedzie typu IF A THEN

        CheckTok(j + 1, THENTOK);

        SaveToSystemStack(ifLocalCnt);    // Save conditional expression at expression stack top onto the system stack

        GenerateIfThenCondition;      // Satisfied if expression is not zero
        GenerateIfThenProlog;

        Inc(CodeSize);        // !!! aby dzialaly petle WHILE, REPEAT po IF

        j := CompileStatement(j + 2);

        GenerateIfThenEpilog;
        Result := j;

        if TokenAt(j + 1).Kind = ELSETOK then
        begin

          RestoreFromSystemStack(ifLocalCnt);  // Restore conditional expression
          GenerateElseCondition;      // Satisfied if expression is zero
          GenerateIfThenProlog;

          optyBP2 := '';

          j := CompileStatement(j + 2);
          GenerateIfThenEpilog;

          Result := j;
        end
        else
          RemoveFromSystemStack;      // Remove conditional expression

      end;


      WITHTOK:
      begin

        Inc(CodeSize);        // !!! aby dzialaly zagniezdzone WHILE

        CheckTok(i + 1, IDENTTOK);

        IdentIndex := GetIdent(TokenAt(i + 1).Name^);


        if (IdentifierAt(IdentIndex).Kind = USERTYPE) and (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK]) then

        else
          if (IdentifierAt(IdentIndex).Kind <> VARTOK) then
            Error(i + 1, 'Expression type must be object or record type');


        if (IdentifierAt(IdentIndex).DataType = POINTERTOK) and (IdentifierAt(IdentIndex).AllocElementType = RECORDTOK) then

        else
          if not (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK]) then
            Error(i + 1, 'Expression type must be object or record type');

        CheckTok(i + 2, DOTOK);

        k := High(WithName);
        WithName[k] := IdentifierAt(IdentIndex).Name;
        SetLength(WithName, k + 2);

        Inc(i, 2);

        j := CompileStatement(i + 1);

        SetLength(WithName, k + 1);

        Result := j;

      end;


{$IFDEF WHILEDO}

WHILETOK:
    begin
//    writeln(codesize,',',CodePosStackTop);

      inc(CodeSize);				// !!! aby dzialaly zagniezdzone WHILE

      asm65;
      asm65('; --- WhileProlog');

      ResetOpty;

      GenerateRepeatUntilProlog;		// Save return address used by GenerateWhileDoEpilog

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

        Inc(CodeSize);        // !!! aby dzialaly zagniezdzone WHILE


        if codealign.loop > 0 then
        begin
          asm65;
          asm65(#9'jmp @+');
          asm65(#9'.align $' + IntToHex(codealign.loop, 4));
          asm65('@');
          asm65;
        end;


        asm65;
        asm65('; --- WhileProlog');

        ResetOpty;

        Inc(CodeSize);

        Inc(CodePosStackTop);
        CodePosStack[CodePosStackTop] := CodeSize;

        asm65(#9'jmp l_' + IntToHex(CodePosStack[CodePosStackTop], 4));

        Inc(CodeSize);

        GenerateRepeatUntilProlog;      // Save return address used by GenerateWhileDoEpilog

        SaveBreakAddress;



        oldPass := Pass;
        oldCodeSize := CodeSize;
        Pass := CALLDETERMPASS;

        k := i;

        StartOptimization(i + 1);

        j := CompileExpression(i + 1, ExpressionType);

        GetCommonType(j, BOOLEANTOK, ExpressionType);

        CheckTok(j + 1, DOTOK);

        Pass := oldPass;
        CodeSize := oldCodeSize;


        Inc(CodePosStackTop);
        CodePosStack[CodePosStackTop] := CodeSize;

        j := CompileStatement(j + 2);

        if BreakPosStack[BreakPosStackTop].cnt then asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

        Dec(CodePosStackTop);
        Dec(CodePosStackTop);
        GenerateAsmLabels(CodePosStack[CodePosStackTop]);

        StartOptimization(k + 1);

        CompileExpression(k + 1, ExpressionType);


        asm65('; --- WhileDoCondition');

        Gen;
        Gen;
        Gen;                // mov :eax, [bx]

        a65(__subBX);

        asm65(#9'lda :STACKORIGIN+1,x');
        asm65(#9'jne l_' + IntToHex(CodePosStack[CodePosStackTop + 1], 4));

        Dec(CodePosStackTop);

        asm65('; --- WhileDoEpilog');

        RestoreBreakAddress;

        Result := j;

        // writeln('.',codesize,',',CodePosStackTop);

      end;

{$ENDIF}

      REPEATTOK:
      begin
        Inc(CodeSize);          // !!! aby dzialaly zagniezdzone REPEAT

        if codealign.loop > 0 then
        begin
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

        while TokenAt(j + 1).Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

        CheckTok(j + 1, UNTILTOK);

        StartOptimization(j + 2);

        j := CompileExpression(j + 2, ExpressionType);

        GetCommonType(j, BOOLEANTOK, ExpressionType);

        asm65;
        asm65('; --- RepeatUntilCondition');
        GenerateRepeatUntilCondition;

        asm65;
        asm65('; --- RepeatUntilEpilog');

        if BreakPosStack[BreakPosStackTop].cnt then asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

        GenerateRepeatUntilEpilog;

        RestoreBreakAddress;

        Result := j;
      end;


      FORTOK:
      begin
        if TokenAt(i + 1).Kind <> IDENTTOK then
          Error(i + 1, IdentifierExpected)
        else
        begin
          IdentIndex := GetIdent(TokenAt(i + 1).Name^);

          Inc(CodeSize);          // !!! aby dzialaly zagniezdzone FOR

          if IdentIndex > 0 then
            if not ((IdentifierAt(IdentIndex).Kind = VARIABLE) and (IdentifierAt(IdentIndex).DataType in
              OrdinalTypes + Pointers) {and (IdentifierAt(IdentIndex).AllocElementType = UNTYPETOK)}) then
              Error(i + 1, 'Ordinal variable expected as ''FOR'' loop counter')
            else
              if (IdentifierAt(IdentIndex).isInitialized) or (IdentifierAt(IdentIndex).PassMethod <> VALPASSING) then
                Error(i + 1, 'Simple local variable expected as FOR loop counter')
              else
              begin

                Ident[IdentIndex].LoopVariable := True;


                if codealign.loop > 0 then
                begin
                  asm65;
                  asm65(#9'jmp @+');
                  asm65(#9'.align $' + IntToHex(codealign.loop, 4));
                  asm65('@');
                  asm65;
                end;


                if TokenAt(i + 2).Kind = INTOK then
                begin    // IN

                  j := i + 3;

                  if TokenAt(j).Kind = STRINGLITERALTOK then
                  begin

    {$i include/for_in_stringliteral.inc}

                  end
                  else
                  begin

    {$i include/for_in_ident.inc}

                  end;

                end
                else
                begin          // = INTOK

                  CheckTok(i + 2, ASSIGNTOK);

                  //      asm65;
                  //      asm65('; --- For');

                  j := i + 3;

                  StartOptimization(j);

                  forLoop.begin_const := False;
                  forLoop.end_const := False;

                  forBPL := 0;

                  if SafeCompileConstExpression(j, ConstVal, ExpressionType, IdentifierAt(IdentIndex).DataType, True) then
                  begin
                    Push(ConstVal, ASVALUE, DataSize[IdentifierAt(IdentIndex).DataType]);

                    forLoop.begin_value := ConstVal;
                    forLoop.begin_const := True;

                    forBPL := Ord(ConstVal < 128);

                  end
                  else
                  begin
                    j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);

                    ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);
                  end;

                  if not (ExpressionType in OrdinalTypes) then
                    Error(j, OrdinalExpectedFOR);

                  ActualParamType := ExpressionType;


                  GenerateAssignment(ASPOINTER, DataSize[IdentifierAt(IdentIndex).DataType], IdentIndex);  //!!!!!

                  if not (TokenAt(j + 1).Kind in [TOTOK, DOWNTOTOK]) then
                    Error(j + 1, '''TO'' or ''DOWNTO'' expected but ' + GetSpelling(j + 1) + ' found')
                  else
                  begin
                    Down := TokenAt(j + 1).Kind = DOWNTOTOK;


                    Inc(j, 2);

                    StartOptimization(j);

                    IdentTemp := -1;


  {$IFDEF OPTIMIZECODE}

	      if SafeCompileConstExpression(j, ConstVal, ExpressionType, IdentifierAt(IdentIndex).DataType, true) then begin

		Push(ConstVal, ASVALUE, DataSize[IdentifierAt(IdentIndex).DataType]);
		DefineIdent(j, '@FORTMP_'+IntToHex(CodeSize, 4), CONSTANT, IdentifierAt(IdentIndex).DataType, IdentifierAt(IdentIndex).NumAllocElements, IdentifierAt(IdentIndex).AllocElementType, ConstVal, TokenAt(j).Kind);

	        forLoop.end_value := ConstVal;
	        forLoop.end_const := true;

		if ConstVal > 0 then forBPL := forBPL or 2;

	      end else begin

	        if ((TokenAt(j).Kind = IDENTTOK) and (TokenAt(j + 1).Kind = DOTOK)) or
		   ((TokenAt(j).Kind = OPARTOK) and (TokenAt(j + 1).Kind = IDENTTOK) and (TokenAt(j + 2).Kind = CPARTOK) and (TokenAt(j + 3).Kind = DOTOK)) then begin

		 if TokenAt(j).Kind = IDENTTOK then
		  IdentTemp := GetIdent(TokenAt(j).Name^)
		 else
		  IdentTemp := GetIdent(TokenAt(j + 1).Name^);

		 j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);
		 ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);

		end else begin
		 j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);
		 ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);
		 DefineIdent(j, '@FORTMP_'+IntToHex(CodeSize, 4), VARIABLE, IdentifierAt(IdentIndex).DataType, IdentifierAt(IdentIndex).NumAllocElements, IdentifierAt(IdentIndex).AllocElementType, 1);
		end;

	      end;

	{$ELSE}

                    j := CompileExpression(j, ExpressionType, IdentifierAt(IdentIndex).DataType);
                    ExpandParam(IdentifierAt(IdentIndex).DataType, ExpressionType);
                    DefineIdent(j, '@FORTMP_' + IntToHex(CodeSize, 4), VARIABLE, IdentifierAt(IdentIndex).DataType,
                      IdentifierAt(IdentIndex).NumAllocElements, IdentifierAt(IdentIndex).AllocElementType, 0);

  {$ENDIF}

                    if not (ExpressionType in OrdinalTypes) then
                      Error(j, OrdinalExpectedFOR);


                    //    if DataSize[ExpressionType] > DataSize[IdentifierAt(IdentIndex).DataType] then
                    //      Error(i, 'FOR loop counter variable type (' + InfoAboutToken(IdentifierAt(IdentIndex).DataType) + ') is smaller than the type of the maximum range (' + InfoAboutToken(ExpressionType) +')' );


                    if ((ActualParamType in UnsignedOrdinalTypes) and (ExpressionType in UnsignedOrdinalTypes)) or
                      ((ActualParamType in SignedOrdinalTypes) and (ExpressionType in SignedOrdinalTypes)) then
                    begin

                      if DataSize[ExpressionType] > DataSize[ActualParamType] then ActualParamType := ExpressionType;
                      if DataSize[ActualParamType] > DataSize[IdentifierAt(IdentIndex).DataType] then
                        ActualParamType := IdentifierAt(IdentIndex).DataType;

                    end
                    else
                      ActualParamType := IdentifierAt(IdentIndex).DataType;


                    if IdentTemp < 0 then IdentTemp := GetIdent('@FORTMP_' + IntToHex(CodeSize, 4));

                    GenerateAssignment(ASPOINTER, {DataSize[IdentifierAt(IdentTemp).DataType]} DataSize[ActualParamType],
                      IdentTemp);

                    asm65;    // ; --- To


                    if loopunroll and forLoop.begin_const and forLoop.end_const then

                    else
                      GenerateRepeatUntilProlog;  // Save return address used by GenerateForToDoEpilog


                    SaveBreakAddress;

                    asm65('; --- ForToDoCondition');


                    if (ActualParamType = ExpressionType) and (DataSize[IdentifierAt(IdentTemp).DataType] >
                      DataSize[ActualParamType]) then
                      Note(j, 'FOR loop counter variable type is of larger size than required');


                    StartOptimization(j);
                    ResetOpty;      // !!!

                    yes := True;


                    if loopunroll and forLoop.begin_const and forLoop.end_const then
                    begin

                      CheckTok(j + 1, DOTOK);

                      ConstVal := forLoop.begin_value;


                      if ((Down = False) and (forLoop.end_value >= forLoop.begin_value)) or
                        (Down and (forLoop.end_value <= forLoop.begin_value)) then
                      begin

                        while ConstVal <> forLoop.end_value do
                        begin

                          ResetOpty;

                          CompileStatement(j + 2);

                          if yes then
                          begin

                            if Down then
                              asm65('---unroll---')
                            else
                              asm65('+++unroll+++');

                            yes := False;
                          end
                          else
                            asm65('===unroll===');

                          if Down then
                            Dec(ConstVal)
                          else
                            Inc(ConstVal);

                          case DataSize[ActualParamType] of
                            1: begin
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex));
                            end;

                            2: begin
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex));
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                            end;

                            4: begin
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex));
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 16), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex) + '+2');
                              asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 24), 2));
                              asm65(#9'sty ' + GetLocalName(IdentIndex) + '+3');
                            end;

                          end;

                        end;

                        ResetOpty;

                        j := CompileStatement(j + 2);

                        asm65('===unroll===');

                        optyY := '';

                        case DataSize[ActualParamType] of
                          1: begin
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex));
                          end;

                          2: begin
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex));
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                          end;

                          4: begin
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex));
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 8), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+1');
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 16), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+2');
                            asm65(#9'ldy #$' + IntToHex(Byte(ConstVal shr 24), 2));
                            asm65(#9'sty ' + GetLocalName(IdentIndex) + '+3');
                          end;

                        end;

                      end
                      else  //if ((Down = false)
                        Error(j, 'for loop with invalid range');

                    end
                    else
                    begin

                      Push(IdentifierAt(IdentTemp).Value, ASPOINTER, {DataSize[IdentifierAt(IdentTemp).DataType]}
                        DataSize[ActualParamType],
                        IdentTemp);

                      GenerateForToDoCondition(ActualParamType, Down, IdentIndex);
                      // Satisfied if counter does not reach the second expression value

                      CheckTok(j + 1, DOTOK);

                      GenerateForToDoProlog;

                      j := CompileStatement(j + 2);

                    end;


                    //          StartOptimization(j);    !!! zaremowac aby dzialaly optymalizacje w TemporaryBuf

                    asm65;
                    asm65('; --- ForToDoEpilog');


                    if BreakPosStack[BreakPosStackTop].cnt then
                      asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));


                    if loopunroll and forLoop.begin_const and forLoop.end_const then

                    else
                      GenerateForToDoEpilog(ActualParamType, Down, IdentIndex, True, forBPL);


                    RestoreBreakAddress;

                    Result := j;

                  end;

                end;  // if TokenAt(i + 2).Kind = INTTOK

                Ident[IdentIndex].LoopVariable := False;

              end
          else
            Error(i + 1, UnknownIdentifier);
        end;
      end;


      ASSIGNFILETOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; AssignFile');

            if not ((IdentifierAt(IdentIndex).DataType in [FILETOK, TEXTFILETOK]) or
              (IdentifierAt(IdentIndex).AllocElementType in [FILETOK, TEXTFILETOK])) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            CheckTok(i + 3, COMMATOK);

            StartOptimization(i + 4);

            if TokenAt(i + 4).Kind = STRINGLITERALTOK then
              Note(i + 4, 'Only uppercase letters preceded by the drive symbol, like ''D:FILENAME.EXT'' or ''S:''');

            i := CompileExpression(i + 4, ActualParamType);
            GetCommonType(i, POINTERTOK, ActualParamType);

            GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.pfname');

            StartOptimization(i);

            Push(0, ASVALUE, DataSize[BYTETOK]);

            GenerateAssignment(ASPOINTERTOPOINTER, 1, 0, IdentifierAt(IdentIndex).Name, 's@file.status');

            if (IdentifierAt(IdentIndex).DataType = TEXTFILETOK) or (IdentifierAt(IdentIndex).AllocElementType = TEXTFILETOK) then
            begin

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
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; Reset');

            if not ((IdentifierAt(IdentIndex).DataType in [FILETOK, TEXTFILETOK]) or
              (IdentifierAt(IdentIndex).AllocElementType in [FILETOK, TEXTFILETOK])) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            StartOptimization(i + 3);

            if TokenAt(i + 3).Kind <> COMMATOK then
            begin
              if IdentifierAt(IdentIndex).NumAllocElements * DataSize[IdentifierAt(IdentIndex).AllocElementType] = 0 then
                Push(128, ASVALUE, 2)
              else
                Push(Integer(IdentifierAt(IdentIndex).NumAllocElements * DataSize[IdentifierAt(IdentIndex).AllocElementType]),
                  ASVALUE, 2);
              // predefined record by FILE OF (default =128)

              Inc(i, 3);
            end
            else
            begin

              if (IdentifierAt(IdentIndex).DataType = TEXTFILETOK) or (IdentifierAt(IdentIndex).AllocElementType = TEXTFILETOK) then
                Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' +
                  InfoAboutToken(IdentifierAt(IdentIndex).DataType) + '" expected "File"');

              i := CompileExpression(i + 4, ActualParamType);       // custom record size
              GetCommonType(i, WORDTOK, ActualParamType);

              ExpandParam(WORDTOK, ActualParamType);

              Inc(i);
            end;

            CheckTok(i, CPARTOK);

            GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.record');

            GenerateFileOpen(IdentIndex, ioFileMode);

            Result := i;
          end;


      REWRITETOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; Rewrite');

            if not ((IdentifierAt(IdentIndex).DataType in [FILETOK, TEXTFILETOK]) or
              (IdentifierAt(IdentIndex).AllocElementType in [FILETOK, TEXTFILETOK])) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            StartOptimization(i + 3);

            if TokenAt(i + 3).Kind <> COMMATOK then
            begin

              if IdentifierAt(IdentIndex).NumAllocElements * DataSize[IdentifierAt(IdentIndex).AllocElementType] = 0 then
                Push(128, ASVALUE, 2)
              else
                Push(Integer(IdentifierAt(IdentIndex).NumAllocElements * DataSize[IdentifierAt(IdentIndex).AllocElementType]),
                  ASVALUE, 2);
              // predefined record by FILE OF (default =128)

              Inc(i, 3);
            end
            else
            begin

              if (IdentifierAt(IdentIndex).DataType = TEXTFILETOK) or (IdentifierAt(IdentIndex).AllocElementType = TEXTFILETOK) then
                Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' +
                  InfoAboutToken(IdentifierAt(IdentIndex).DataType) + '" expected "File"');

              i := CompileExpression(i + 4, ActualParamType);       // custom record size
              GetCommonType(i, WORDTOK, ActualParamType);

              ExpandParam(WORDTOK, ActualParamType);

              Inc(i);
            end;

            CheckTok(i, CPARTOK);

            GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.record');

            GenerateFileOpen(IdentIndex, ioOpenWrite);

            Result := i;
          end;


      APPENDTOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin

            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; Append');

            if not ((IdentifierAt(IdentIndex).DataType in [TEXTFILETOK]) or
              (IdentifierAt(IdentIndex).AllocElementType in [TEXTFILETOK])) then
              Error(i, 'Call by var for arg no. 1 has to match exactly: Got "' +
                InfoAboutToken(IdentifierAt(IdentIndex).DataType) + '" expected "Text"');

            if TokenAt(i + 3).Kind = COMMATOK then
              Error(i, 'Wrong number of parameters specified for call to Append');

            StartOptimization(i + 3);

            CheckTok(i + 3, CPARTOK);

            Push(1, ASVALUE, 2);

            GenerateAssignment(ASPOINTERTOPOINTER, 2, 0, IdentifierAt(IdentIndex).Name, 's@file.record');

            GenerateFileOpen(IdentIndex, ioAppend);

            Result := i + 3;
          end;


      GETRESOURCEHANDLETOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            if IdentifierAt(IdentIndex).DataType <> POINTERTOK then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            CheckTok(i + 3, COMMATOK);

            CheckTok(i + 4, STRINGLITERALTOK);

            svar := '';

            for k := 1 to TokenAt(i + 4).StrLength do
              svar := svar + chr(StaticStringData[TokenAt(i + 4).StrAddress - CODEORIGIN + k]);

            //   writeln(svar,',',TokenAt(i+4].StrLength);

            CheckTok(i + 5, CPARTOK);

            //  asm65;
            //  asm65('; GetResourceHandle');

            asm65(#9'lda <MAIN.@RESOURCE.' + svar);
            asm65(#9'sta ' + TokenAt(i + 2).Name^);
            asm65(#9'lda >MAIN.@RESOURCE.' + svar);
            asm65(#9'sta ' + TokenAt(i + 2).Name^ + '+1');

            Inc(i, 5);

            Result := i;
          end;


      SIZEOFRESOURCETOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            if not (IdentifierAt(IdentIndex).DataType in IntegerTypes) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            CheckTok(i + 3, COMMATOK);

            CheckTok(i + 4, STRINGLITERALTOK);

            svar := '';

            for k := 1 to TokenAt(i + 4).StrLength do
              svar := svar + chr(StaticStringData[TokenAt(i + 4).StrAddress - CODEORIGIN + k]);

            CheckTok(i + 5, CPARTOK);

            //  asm65;
            //  asm65('; GetResourceHandle');

            asm65(#9'lda <MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
            asm65(#9'sta ' + TokenAt(i + 2).Name^);

            asm65(#9'lda >MAIN.@RESOURCE.' + svar + '.end-MAIN.@RESOURCE.' + svar);
            asm65(#9'sta ' + TokenAt(i + 2).Name^ + '+1');

            Inc(i, 5);

            Result := i;
          end;


      BLOCKREADTOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; BlockRead');

            if not ((IdentifierAt(IdentIndex).DataType = FILETOK) or (IdentifierAt(IdentIndex).AllocElementType = FILETOK)) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            CheckTok(i + 3, COMMATOK);

            Inc(i, 2);

            NumActualParams := CompileBlockRead(i, IdentIndex, GetIdent('BLOCKREAD'));

            GenerateFileRead(IdentIndex, ioRead, NumActualParams);

            Result := i;
          end;


      BLOCKWRITETOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; BlockWrite');

            if not ((IdentifierAt(IdentIndex).DataType = FILETOK) or (IdentifierAt(IdentIndex).AllocElementType = FILETOK)) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            CheckTok(i + 3, COMMATOK);

            Inc(i, 2);
            NumActualParams := CompileBlockRead(i, IdentIndex, GetIdent('BLOCKWRITE'));

            GenerateFileRead(IdentIndex, ioWrite, NumActualParams);

            Result := i;
          end;


      CLOSEFILETOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
          Error(i + 1, OParExpected)
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if IdentIndex = 0 then
              Error(i + 2, UnknownIdentifier);

            //  asm65('; CloseFile');

            if not ((IdentifierAt(IdentIndex).DataType in [FILETOK, TEXTFILETOK]) or
              (IdentifierAt(IdentIndex).AllocElementType in [FILETOK, TEXTFILETOK])) then
              Error(i + 2, IncompatibleTypeOf, IdentIndex);

            CheckTok(i + 3, CPARTOK);

            GenerateFileOpen(IdentIndex, ioClose);

            Result := i + 3;
          end;


      READLNTOK:
        if TokenAt(i + 1).Kind <> OPARTOK then
        begin

          if TokenAt(i + 1).Kind = SEMICOLONTOK then
          begin
            GenerateRead;

            Result := i;
          end
          else
            Error(i + 1, OParExpected);

        end
        else
          if TokenAt(i + 2).Kind <> IDENTTOK then
            Error(i + 2, IdentifierExpected)
          else
          begin
            IdentIndex := GetIdent(TokenAt(i + 2).Name^);

            if (IdentIndex > 0) and (IdentifierAt(IdentIndex).DataType = TEXTFILETOK) then
            begin

              asm65(#9'lda #eol');
              asm65(#9'sta @buf');
              GenerateFileRead(IdentIndex, ioReadRecord, 0);

              Inc(i, 3);

              CheckTok(i, COMMATOK);
              CheckTok(i + 1, IDENTTOK);

              if IdentifierAt(GetIdent(TokenAt(i + 1).Name^)).DataType <> STRINGPOINTERTOK then
                Error(i + 1, VariableExpected);

              IdentIndex := GetIdent(TokenAt(i + 1).Name^);

              asm65(#9'@moveRECORD ' + GetLocalName(IdentIndex));

              CheckTok(i + 2, CPARTOK);

              Result := i + 2;

            end
            else

              if IdentIndex > 0 then
                if (IdentifierAt(IdentIndex).Kind <> VARIABLE) {or (IdentifierAt(IdentIndex).DataType <> CHARTOK)} then
                  Error(i + 2, IncompatibleTypeOf, IdentIndex)
                else
                begin
                  //      Push(IdentifierAt(IdentIndex).Value, ASVALUE, DataSize[CHARTOK]);

                  GenerateRead;//(IdentifierAt(IdentIndex).Value);

                  ResetOpty;

                  if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) and
                    (IdentifierAt(IdentIndex).AllocElementType = CHARTOK) then
                  begin     // string

                    asm65(#9'@move #@buf #' + GetLocalName(IdentIndex, 'adr.') + ' #' +
                      IntToStr(IdentifierAt(IdentIndex).NumAllocElements));

                  end
                  else
                    if (IdentifierAt(IdentIndex).DataType = CHARTOK) then
                      asm65(#9'mva @buf+1 ' + IdentifierAt(IdentIndex).Name)
                    else
                      if (IdentifierAt(IdentIndex).DataType in IntegerTypes) then
                      begin

                        asm65(#9'@StrToInt #@buf');

                        case DataSize[IdentifierAt(IdentIndex).DataType] of

                          1: asm65(#9'mva :edx ' + IdentifierAt(IdentIndex).Name);

                          2: begin
                            asm65(#9'mva :edx ' + IdentifierAt(IdentIndex).Name);
                            asm65(#9'mva :edx+1 ' + IdentifierAt(IdentIndex).Name + '+1');
                          end;

                          4: begin
                            asm65(#9'mva :edx ' + IdentifierAt(IdentIndex).Name);
                            asm65(#9'mva :edx+1 ' + IdentifierAt(IdentIndex).Name + '+1');
                            asm65(#9'mva :edx+2 ' + IdentifierAt(IdentIndex).Name + '+2');
                            asm65(#9'mva :edx+3 ' + IdentifierAt(IdentIndex).Name + '+3');
                          end;

                        end;

                      end
                      else
                        Error(i + 2, IncompatibleTypeOf, IdentIndex);

                  CheckTok(i + 3, CPARTOK);

                  Result := i + 3;
                end
              else
                Error(i + 2, UnknownIdentifier);
          end;


      WRITETOK, WRITELNTOK:
      begin

        StartOptimization(i);

        yes := (TokenAt(i).Kind = WRITELNTOK);


        if (TokenAt(i + 1).Kind = OPARTOK) and (TokenAt(i + 2).Kind = CPARTOK) then Inc(i, 2);


        if TokenAt(i + 1).Kind = SEMICOLONTOK then
        begin

        end
        else
        begin

          CheckTok(i + 1, OPARTOK);

          Inc(i);

          if (TokenAt(i + 1).Kind = IDENTTOK) and (IdentifierAt(GetIdent(TokenAt(i + 1).Name^)).DataType = TEXTFILETOK) then
          begin

            IdentIndex := GetIdent(TokenAt(i + 1).Name^);

            Inc(i);
            CheckTok(i + 1, COMMATOK);
            Inc(i);

            case TokenAt(i + 1).Kind of

              IDENTTOK:          // variable (pointer to string)
              begin

                if IdentifierAt(GetIdent(TokenAt(i + 1).Name^)).DataType <> STRINGPOINTERTOK then
                  Error(i + 1, VariableExpected);

                asm65(#9'mwy ' + GetLocalName(GetIdent(TokenAt(i + 1).Name^)) + ' :bp2');
                asm65(#9'ldy #$01');
                asm65(#9'mva:rne (:bp2),y @buf-1,y+');
                asm65(#9'lda (:bp2),y');

                if yes then
                begin                 // WRITELN

                  asm65(#9'tay');
                  asm65(#9'lda #eol');
                  asm65(#9'sta @buf,y');

                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                  asm65(#9'ldy #s@file.nrecord');
                  asm65(#9'lda #$00');
                  asm65(#9'sta (:bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda #$01');
                  asm65(#9'sta (:bp2),y');

                  GenerateFileRead(IdentIndex, ioWriteRecord, 0);

                end
                else
                begin                // WRITE

                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                  asm65(#9'ldy #s@file.nrecord');
                  asm65(#9'sta (:bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda #$00');
                  asm65(#9'sta (:bp2),y');

                  GenerateFileRead(IdentIndex, ioWrite, 0);

                end;

                Inc(i, 2);

              end;

              STRINGLITERALTOK:            // 'text'
              begin
                asm65(#9'ldy #$00');
                asm65(#9'mva:rne CODEORIGIN+$' + IntToHex(TokenAt(i + 1).StrAddress - CODEORIGIN + 1, 4) + ',y @buf,y+');

                if yes then
                begin                 // WRITELN

                  asm65(#9'lda #eol');
                  asm65(#9'ldy CODEORIGIN+$' + IntToHex(TokenAt(i + 1).StrAddress - CODEORIGIN, 4));
                  asm65(#9'sta @buf,y');

                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                  asm65(#9'ldy #s@file.nrecord');
                  asm65(#9'lda #$00');
                  asm65(#9'sta (:bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda #$01');
                  asm65(#9'sta (:bp2),y');

                  GenerateFileRead(IdentIndex, ioWriteRecord, 0);

                end
                else
                begin                // WRITE

                  asm65(#9'lda CODEORIGIN+$' + IntToHex(TokenAt(i + 1).StrAddress - CODEORIGIN, 4));

                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                  asm65(#9'ldy #s@file.nrecord');
                  asm65(#9'sta (:bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda #$00');
                  asm65(#9'sta (:bp2),y');

                  GenerateFileRead(IdentIndex, ioWrite, 0);

                end;

                Inc(i, 2);
              end;


              INTNUMBERTOK:            // 0..9
              begin
                asm65(#9'txa:pha');

                Push(TokenAt(i + 1).Value, ASVALUE, DataSize[CARDINALTOK]);

                asm65(#9'@ValueToRec #@printINT');

                asm65(#9'pla:tax');

                if yes then
                begin                 // WRITELN

                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                  asm65(#9'ldy #s@file.nrecord');
                  asm65(#9'lda #$00');
                  asm65(#9'sta (:bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda #$01');
                  asm65(#9'sta (:bp2),y');

                  GenerateFileRead(IdentIndex, ioWriteRecord, 0);

                end
                else
                begin                // WRITE

                  asm65(#9'tya');

                  asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');

                  asm65(#9'ldy #s@file.nrecord');
                  asm65(#9'sta (:bp2),y');
                  asm65(#9'iny');
                  asm65(#9'lda #$00');
                  asm65(#9'sta (:bp2),y');

                  GenerateFileRead(IdentIndex, ioWrite, 0);

                end;

                Inc(i, 2);
              end;

            end;

            yes := False;

          end
          else

            repeat

              case TokenAt(i + 1).Kind of

                CHARLITERALTOK:
                begin           // #65#32#77
                  Inc(i);

                  repeat
                    asm65(#9'@print #$' + IntToHex(TokenAt(i).Value, 2));
                    Inc(i);
                  until TokenAt(i).Kind <> CHARLITERALTOK;

                end;

                STRINGLITERALTOK:            // 'text'
                  repeat
                    GenerateWriteString(TokenAt(i + 1).StrAddress, ASPOINTER);
                    Inc(i, 2);
                  until TokenAt(i + 1).Kind <> STRINGLITERALTOK;

                else

                begin

                  j := i + 1;

                  i := CompileExpression(j, ExpressionType);


                  if (ExpressionType = CHARTOK) and (TokenAt(i).Kind = DEREFERENCETOK) and
                    (TokenAt(i - 1).Kind <> IDENTTOK) then
                  begin

                    asm65(#9'lda :STACKORIGIN,x');
                    asm65(#9'sta :bp2');
                    asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
                    asm65(#9'sta :bp2+1');
                    asm65(#9'ldy #$00');
                    asm65(#9'lda (:bp2),y');
                    asm65(#9'sta :STACKORIGIN,x');

                  end;

                  //    if ExpressionType = ENUMTYPE then
                  //      GenerateWriteString(TokenAt(i).Value, ASVALUE, INTEGERTOK)    // Enumeration argument
                  //    else

                  if (ExpressionType in IntegerTypes) then
                    GenerateWriteString(TokenAt(i).Value, ASVALUE, ExpressionType)  // Integer argument
                  else if (ExpressionType = BOOLEANTOK) then
                      GenerateWriteString(TokenAt(i).Value, AsBoolean)      // Boolean argument
                    else if (ExpressionType = CHARTOK) then
                        GenerateWriteString(TokenAt(i).Value, ASCHAR)      // Character argument
                      else if ExpressionType = REALTOK then
                          GenerateWriteString(TokenAt(i).Value, ASREAL)      // Real argument
                        else if ExpressionType = SHORTREALTOK then
                            GenerateWriteString(TokenAt(i).Value, ASSHORTREAL)      // ShortReal argument
                          else if ExpressionType = HALFSINGLETOK then
                              GenerateWriteString(TokenAt(i).Value, ASHALFSINGLE)      // Half Single argument
                            else if ExpressionType = SINGLETOK then
                                GenerateWriteString(TokenAt(i).Value, ASSINGLE)      // Single argument
                              else if ExpressionType in Pointers then
                                begin

                                  if TokenAt(j).Kind = ADDRESSTOK then
                                    IdentIndex := GetIdent(TokenAt(j + 1).Name^)
                                  else
                                    if TokenAt(j).Kind = IDENTTOK then
                                      IdentIndex := GetIdent(TokenAt(j).Name^)
                                    else
                                      Error(i, CantReadWrite);


                                  //  writeln(IdentifierAt(IdentIndex).Name,',',ExpressionType,' | ',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).Kind);


                                  if (IdentifierAt(IdentIndex).AllocElementType = PROCVARTOK) then
                                  begin

                                    IdentTemp := GetIdent('@FN' + IntToHex(IdentifierAt(IdentIndex).NumAllocElements_, 4));

                                    if IdentifierAt(IdentTemp).Kind = FUNCTIONTOK then
                                      ExpressionType := IdentifierAt(IdentTemp).DataType
                                    else
                                      ExpressionType := UNTYPETOK;


                                    if (ExpressionType = STRINGPOINTERTOK) then
                                      GenerateWriteString(IdentifierAt(IdentIndex).Value, ASPOINTERTOPOINTER, POINTERTOK)
                                    else if (ExpressionType in IntegerTypes) then
                                        GenerateWriteString(TokenAt(i).Value, ASVALUE, ExpressionType)  // Integer argument
                                      else if (ExpressionType = BOOLEANTOK) then
                                          GenerateWriteString(TokenAt(i).Value, AsBoolean)      // Boolean argument
                                        else if (ExpressionType = CHARTOK) then
                                            GenerateWriteString(TokenAt(i).Value, ASCHAR)      // Character argument
                                          else if ExpressionType = REALTOK then
                                              GenerateWriteString(TokenAt(i).Value, ASREAL)      // Real argument
                                            else if ExpressionType = SHORTREALTOK then
                                                GenerateWriteString(TokenAt(i).Value, ASSHORTREAL)
                                              // ShortReal argument
                                              else if ExpressionType = HALFSINGLETOK then
                                                  GenerateWriteString(TokenAt(i).Value, ASHALFSINGLE)
                                                // Half Single argument
                                                else if ExpressionType = SINGLETOK then
                                                    GenerateWriteString(TokenAt(i).Value, ASSINGLE)      // Single argument
                                                  else
                                                    Error(i, CantReadWrite);

                                  end
                                  else
                                    if (ExpressionType = STRINGPOINTERTOK) or
                                      (IdentifierAt(IdentIndex).Kind = FUNCTIONTOK) or ((ExpressionType = POINTERTOK) and
                                      (IdentifierAt(IdentIndex).DataType = STRINGPOINTERTOK)) then
                                      GenerateWriteString(IdentifierAt(IdentIndex).Value,
                                        ASPOINTERTOPOINTER, IdentifierAt(IdentIndex).DataType)
                                    else
                                      if (ExpressionType = PCHARTOK) or
                                        (IdentifierAt(IdentIndex).AllocElementType in [CHARTOK, POINTERTOK]) then
                                        GenerateWriteString(IdentifierAt(IdentIndex).Value, ASPCHAR,
                                          IdentifierAt(IdentIndex).DataType)
                                      else
                                        Error(i, CantReadWrite);

                                end
                                else
                                  Error(i, CantReadWrite);

                end;

                  Inc(i);

              end;

              j := 0;

              ActualParamType := ExpressionType;

              if TokenAt(i).Kind = COLONTOK then      // pomijamy formatowanie wyniku value:x:x
                repeat
                  i := CompileExpression(i + 1, ExpressionType);
                  a65(__subBX);          // zdejmujemy ze stosu
                  Inc(i);

                  Inc(j);

                  if j > 2 - Ord(ActualParamType in OrdinalTypes) then// Break;      // maksymalnie :x:x
                    Error(i + 1, 'Illegal use of '':''');

                until TokenAt(i).Kind <> COLONTOK;


            until TokenAt(i).Kind <> COMMATOK;     // repeat

          CheckTok(i, CPARTOK);

        end; // if TokenAt(i + 1).Kind = SEMICOLONTOK

        if yes then a65(__putEOL);

        StopOptimization;

        Result := i;

      end;


      ASMTOK:
      begin

        ResetOpty;

        StopOptimization;      // takich blokow nie optymalizujemy

        asm65;
        asm65('; -------------------  ASM Block ' + format('%.8d', [AsmBlockIndex]) + '  -------------------');
        asm65;


        if isInterrupt and ((pos(' :bp', AsmBlock[AsmBlockIndex]) > 0) or
          (pos(' :STACK', AsmBlock[AsmBlockIndex]) > 0)) then
        begin

          if (pos(' :bp', AsmBlock[AsmBlockIndex]) > 0) then
            Error(i, 'Illegal instruction in INTERRUPT block '':BP''');
          if (pos(' :STACK', AsmBlock[AsmBlockIndex]) > 0) then
            Error(i, 'Illegal instruction in INTERRUPT block '':STACKORIGIN''');

        end;


        asm65('#asm:' + IntToStr(AsmBlockIndex));


        //     if (OutputDisabled=false) and (Pass = CODEGENERATIONPASS) then WriteOut(AsmBlock[AsmBlockIndex]);

        Inc(AsmBlockIndex);

        if isAsm and (TokenAt(i).Value = 0) then
        begin

          CheckTok(i + 1, SEMICOLONTOK);
          Inc(i);

          CheckTok(i + 1, ENDTOK);
          Inc(i);

        end;

        Result := i;

      end;


      INCTOK, DECTOK:
        // dwie wersje
        // krotka i szybka, jesli mamy jeden parametr, np. INC(VAR), DEC(VAR)
        // dluga i wolna, jesli mamy tablice lub dwa parametry, np. INC(TMP[1]), DEC(VAR, VALUE+12)
      begin

        Value := 0;
        ExpressionType := 0;
        NumActualParams := 0;

        Down := (TokenAt(i).Kind = DECTOK);

        CheckTok(i + 1, OPARTOK);

        Inc(i, 2);

        if TokenAt(i).Kind = IDENTTOK then
        begin          // first parameter
          IdentIndex := GetIdent(TokenAt(i).Name^);

          CheckAssignment(i, IdentIndex);

          if IdentIndex = 0 then
            Error(i, UnknownIdentifier);

          if IdentifierAt(IdentIndex).Kind = VARIABLE then
          begin

            ExpressionType := IdentifierAt(IdentIndex).DataType;

            if ExpressionType = CHARTOK then ExpressionType := BYTETOK;  // wyjatkowo CHARTOK -> BYTETOK

            if {((IdentifierAt(IdentIndex).DataType in Pointers) and
       (IdentifierAt(IdentIndex).NumAllocElements=0)) or}
            (IdentifierAt(IdentIndex).DataType = REALTOK) then
              Error(i, 'Left side cannot be assigned to')
            else
            begin
              Value := IdentifierAt(IdentIndex).Value;

              if ExpressionType in Pointers then
              begin      // Alloc Element Type
                ExpressionType := WORDTOK;

                if pos('mw? ' + TokenAt(i).Name^, optyBP2) > 0 then optyBP2 := '';
              end;

            end;

          end
          else
            Error(i, 'Left side cannot be assigned to');

        end
        else
          Error(i, IdentifierExpected);


        StartOptimization(i);

        IndirectionLevel := ASPOINTER;


        if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
          ExpressionType := IdentifierAt(IdentIndex).AllocElementType
        else
          if IdentifierAt(IdentIndex).DataType in Pointers then
            ExpressionType := WORDTOK
          else
            ExpressionType := IdentifierAt(IdentIndex).DataType;


        if IdentifierAt(IdentIndex).AllocElementType = REALTOK then
          Error(i, OrdinalExpExpected);


        if not (IdentifierAt(IdentIndex).idType in [PCHARTOK]) and (IdentifierAt(IdentIndex).DataType in Pointers) and
          (IdentifierAt(IdentIndex).NumAllocElements > 0) and
          (not (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK])) then
        begin

          if TokenAt(i + 1).Kind = OBRACKETTOK then
          begin      // array index

            IndirectionLevel := ASPOINTERTOARRAYORIGIN;

            i := CompileArrayIndex(i, IdentIndex, ExpressionType);

            CheckTok(i + 1, CBRACKETTOK);

            Inc(i);

          end
          else
            if TokenAt(i + 1).Kind = DEREFERENCETOK then
              Error(i + 1, IllegalQualifier)
            else
              Error(i + 1, IncompatibleTypes, IdentIndex, IdentifierAt(IdentIndex).DataType, ExpressionType);

        end
        else

        //          if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements = 0) and (IdentifierAt(IdentIndex).AllocElementType <> 0) then begin

          if TokenAt(i + 1).Kind = OBRACKETTOK then
          begin        // typed pointer: PByte[], Pword[] ...

            IndirectionLevel := ASPOINTERTOARRAYORIGIN;

            i := CompileArrayIndex(i, IdentIndex, ExpressionType);

            CheckTok(i + 1, CBRACKETTOK);

            Inc(i);

          end
          else

            if TokenAt(i + 1).Kind = DEREFERENCETOK then
              if IdentifierAt(IdentIndex).AllocElementType = 0 then
                Error(i + 1, CantAdrConstantExp)
              else
              begin

                ExpressionType := IdentifierAt(IdentIndex).AllocElementType;

                IndirectionLevel := ASPOINTERTOPOINTER;

                Inc(i);

              end;


        if TokenAt(i + 1).Kind = COMMATOK then
        begin        // potencjalnie drugi parametr

          j := i + 2;
          yes := False;

          if SafeCompileConstExpression(j, ConstVal, ActualParamType,
            {IdentifierAt(IdentIndex).DataType} ExpressionType, True) then
            yes := True
          else
            j := CompileExpression(j, ActualParamType);

          i := j;

          GetCommonType(i, ExpressionType, ActualParamType);

          Inc(NumActualParams);

          if IdentifierAt(IdentIndex).PassMethod <> VARPASSING then
          begin

            if yes = False then ExpandParam(ExpressionType, ActualParamType);

            if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).AllocElementType in
              [RECORDTOK, OBJECTTOK]) then
            begin

              if yes then
                Push(ConstVal * RecordSize(IdentIndex), ASVALUE, 2)
              else
                Error(i, '-- under construction --');

            end
            else
              if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements = 0) and
                (IdentifierAt(IdentIndex).AllocElementType in OrdinalTypes) and (IndirectionLevel <> ASPOINTERTOPOINTER) then
              begin      // zwieksz o N * DATASIZE jesli to wskaznik ale nie tablica

                if yes then
                begin

                  if IndirectionLevel = ASPOINTERTOARRAYORIGIN then
                    Push(ConstVal, ASVALUE, DataSize[IdentifierAt(IdentIndex).DataType])
                  else
                    Push(ConstVal * DataSize[IdentifierAt(IdentIndex).AllocElementType], ASVALUE,
                      DataSize[IdentifierAt(IdentIndex).DataType]);

                end
                else
                  GenerateIndexShift(IdentifierAt(IdentIndex).AllocElementType);    // * DATASIZE

              end
              else
                if yes then Push(ConstVal, ASVALUE, DataSize[IdentifierAt(IdentIndex).DataType]);

          end
          else
          begin

            if yes then Push(ConstVal, ASVALUE, DataSize[IdentifierAt(IdentIndex).DataType]);

            ExpressionType := IdentifierAt(IdentIndex).AllocElementType;
            if ExpressionType = UNTYPETOK then ExpressionType := IdentifierAt(IdentIndex).DataType;  // RECORD.

            ExpandParam(ExpressionType, ActualParamType);
          end;

        end
        else  // if TokenAt(i + 1).Kind = COMMATOK

          if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) or ((IdentifierAt(IdentIndex).DataType in Pointers) and
            (IdentifierAt(IdentIndex).AllocElementType in OrdinalTypes + Pointers + [RECORDTOK, OBJECTTOK])) then

            if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) or (IdentifierAt(IdentIndex).NumAllocElements > 0) or
              (IndirectionLevel = ASPOINTERTOPOINTER) or ((IdentifierAt(IdentIndex).NumAllocElements = 0) and
              (IndirectionLevel = ASPOINTERTOARRAYORIGIN)) then
            begin

              ExpressionType := IdentifierAt(IdentIndex).AllocElementType;
              if ExpressionType = UNTYPETOK then ExpressionType := IdentifierAt(IdentIndex).DataType;


              if ExpressionType in [RECORDTOK, OBJECTTOK] then
                Push(RecordSize(IdentIndex), ASVALUE, 2)
              else
                Push(1, ASVALUE, DataSize[ExpressionType]);

              Inc(NumActualParams);
            end
            else
              if not (IdentifierAt(IdentIndex).AllocElementType in [BYTETOK, SHORTINTTOK]) then
              begin
                Push(DataSize[IdentifierAt(IdentIndex).AllocElementType], ASVALUE, 1);      // +/- DATASIZE

                ExpandParam(ExpressionType, BYTETOK);

                Inc(NumActualParams);
              end;


        if (IdentifierAt(IdentIndex).PassMethod = VARPASSING) and (IndirectionLevel <> ASPOINTERTOARRAYORIGIN) then
          IndirectionLevel := ASPOINTERTOPOINTER;

        if ExpressionType = UNTYPETOK then
          Error(i, 'Assignments to formal parameters and open arrays are not possible');

        //       NumActualParams:=1;
        //   Value:=3;

        if (NumActualParams = 0) then
        begin

{
    asm65;

    if Down then
     asm65('; Dec(var X) -> ' + InfoAboutToken(ExpressionType))
    else
     asm65('; Inc(var X) -> ' + InfoAboutToken(ExpressionType));

    asm65;
}

          GenerateForToDoEpilog(ExpressionType, Down, IdentIndex, False, 0);    // +1, -1
        end
        else
          GenerateIncDec(IndirectionLevel, ExpressionType, Down, IdentIndex);    // +N, -N

        StopOptimization;

        Inc(i);

        CheckTok(i, CPARTOK);

        Result := i;
      end;


      EXITTOK:
      begin

        if TokenAt(i + 1).Kind = OPARTOK then
        begin

          StartOptimization(i);

          i := CompileExpression(i + 2, ActualParamType);

          CheckTok(i + 1, CPARTOK);

          Inc(i);

          yes := False;

          for j := 1 to NumIdent do
            if (IdentifierAt(j).ProcAsBlock = BlockStack[BlockStackTop]) and (IdentifierAt(j).Kind = FUNCTIONTOK) then
            begin

              IdentIndex := GetIdentResult(BlockStack[BlockStackTop]);

              yes := True;
              Break;
            end;


          if not yes then
            Error(i, 'Procedures cannot return a value');

          if (ActualParamType = STRINGPOINTERTOK) and ((IdentifierAt(IdentIndex).DataType = POINTERTOK) and
            (IdentifierAt(IdentIndex).NumAllocElements = 0)) then
            Error(i, IncompatibleTypes, 0, ActualParamType, PCHARTOK)
          else
            GetCommonConstType(i, IdentifierAt(IdentIndex).DataType, ActualParamType);

          GenerateAssignment(ASPOINTER, DataSize[IdentifierAt(IdentIndex).DataType], 0, 'RESULT');

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
        asm65(#9'jmp b_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

        BreakPosStack[BreakPosStackTop].brk := True;

        ResetOpty;

        Result := i;
      end;


      CONTINUETOK:
      begin
        if BreakPosStackTop = 0 then
          Error(i, 'CONTINUE not allowed');

        //     asm65;
        asm65(#9'jmp c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

        BreakPosStack[BreakPosStackTop].cnt := True;

        Result := i;
      end;


      HALTTOK:
      begin
        if TokenAt(i + 1).Kind = OPARTOK then
        begin

          i := CompileConstExpression(i + 2, Value, ExpressionType);
          GetCommonConstType(i, BYTETOK, ExpressionType);

          CheckTok(i + 1, CPARTOK);

          Inc(i, 1);

          GenerateProgramEpilog(Value);

        end
        else
          GenerateProgramEpilog(0);

        Result := i;
      end;


      GETINTVECTOK:
      begin
        CheckTok(i + 1, OPARTOK);

        i := CompileConstExpression(i + 2, ConstVal, ActualParamType);
        GetCommonType(i, INTEGERTOK, ActualParamType);

        CheckTok(i + 1, COMMATOK);

        if not (Byte(ConstVal) in [0..4]) then
          Error(i, 'Interrupt Number in [0..4]');

        CheckTok(i + 2, IDENTTOK);
        IdentIndex := GetIdent(TokenAt(i + 2).Name^);

        if IdentIndex = 0 then
          Error(i + 2, UnknownIdentifier);

        if not (IdentifierAt(IdentIndex).DataType in Pointers) then
          Error(i + 2, IncompatibleTypes, 0, IdentifierAt(IdentIndex).DataType, POINTERTOK);

        svar := GetLocalName(IdentIndex);

        Inc(i, 2);

        case ConstVal of
          Ord(iDLI): begin
            asm65;
            asm65(#9'lda VDSLST');
            asm65(#9'sta ' + svar);
            asm65(#9'lda VDSLST+1');
            asm65(#9'sta ' + svar + '+1');
          end;

          Ord(iVBLI): begin
            asm65;
            asm65(#9'lda VVBLKI');
            asm65(#9'sta ' + svar);
            asm65(#9'lda VVBLKI+1');
            asm65(#9'sta ' + svar + '+1');
          end;

          Ord(iVBLD): begin
            asm65;
            asm65(#9'lda VVBLKD');
            asm65(#9'sta ' + svar);
            asm65(#9'lda VVBLKD+1');
            asm65(#9'sta ' + svar + '+1');
          end;

          Ord(iTIM1): begin
            asm65;
            asm65(#9'lda VTIMR1');
            asm65(#9'sta ' + svar);
            asm65(#9'lda VTIMR1+1');
            asm65(#9'sta ' + svar + '+1');
          end;

          Ord(iTIM2): begin
            asm65;
            asm65(#9'lda VTIMR2');
            asm65(#9'sta ' + svar);
            asm65(#9'lda VTIMR2+1');
            asm65(#9'sta ' + svar + '+1');
          end;

          Ord(iTIM4): begin
            asm65;
            asm65(#9'lda VTIMR4');
            asm65(#9'sta ' + svar);
            asm65(#9'lda VTIMR4+1');
            asm65(#9'sta ' + svar + '+1');
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

        if not (Byte(ConstVal) in [0..4]) then
          Error(i, 'Interrupt Number in [0..4]');

        i := CompileExpression(i + 2, ActualParamType);
        GetCommonType(i, POINTERTOK, ActualParamType);

        case ConstVal of
          Ord(iDLI): begin
            asm65(#9'mva :STACKORIGIN,x VDSLST');
            asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VDSLST+1');
            a65(__subBX);
          end;

          Ord(iVBLI): begin
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

          Ord(iVBLD): begin
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

          Ord(iTIM1): begin
            asm65(#9'sei');
            asm65(#9'mva :STACKORIGIN,x VTIMR1');
            asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR1+1');
            a65(__subBX);

            if TokenAt(i + 1).Kind = COMMATOK then
            begin

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

            end
            else
            begin

              asm65(#9'lda irqens');
              asm65(#9'and #$fe');
              asm65(#9'sta irqens');
              asm65(#9'sta irqen');

            end;

            asm65(#9'cli');
          end;

          Ord(iTIM2): begin
            asm65(#9'sei');
            asm65(#9'mva :STACKORIGIN,x VTIMR2');
            asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR2+1');
            a65(__subBX);

            if TokenAt(i + 1).Kind = COMMATOK then
            begin

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

            end
            else
            begin

              asm65(#9'lda irqens');
              asm65(#9'and #$fd');
              asm65(#9'sta irqens');
              asm65(#9'sta irqen');

            end;

            asm65(#9'cli');
          end;

          Ord(iTIM4): begin
            asm65(#9'sei');
            asm65(#9'mva :STACKORIGIN,x VTIMR4');
            asm65(#9'mva :STACKORIGIN+STACKWIDTH,x VTIMR4+1');
            a65(__subBX);

            if TokenAt(i + 1).Kind = COMMATOK then
            begin

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

            end
            else
            begin

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
    end;  // case

  end;  //CompileStatement


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateProcFuncAsmLabels(BlockIdentIndex: Integer; VarSize: Boolean = False);
  var
    IdentIndex, size: Integer;
    emptyLine, yes: Boolean;
    fnam, txt, svar: String;
    varbegin: TString;
    HeaFile: TextFile;

    // ----------------------------------------------------------------------------

    function Value(dorig: Boolean = False; brackets: Boolean = False): String;
    const
      reg: array [1..3] of String = (':EDX', ':ECX', ':EAX');
      // !!! kolejnosc edx, ecx, eax !!! korzysta z tego memmove, memset !!!
    var
      ftmp: TFloat;
      v: Int64;
    begin

      ftmp := Default(TFloat);

      move(IdentifierAt(IdentIndex).Value, ftmp, sizeof(ftmp));

      case IdentifierAt(IdentIndex).DataType of
        SHORTREALTOK, REALTOK: v := ftmp[0];
        SINGLETOK: v := ftmp[1];
        HALFSINGLETOK: v := CardToHalf(ftmp[1]);
        else
          v := IdentifierAt(IdentIndex).Value;
      end;


      if dorig then
      begin

        if brackets then
          Result := #9'= [DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN, 4) + ']'
        else
          Result := #9'= DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN, 4);

      end
      else
        if IdentifierAt(IdentIndex).isAbsolute and (IdentifierAt(IdentIndex).Kind = VARIABLE) and
          (abs(IdentifierAt(IdentIndex).Value) and $ff = 0) and (Byte((abs(IdentifierAt(IdentIndex).Value) shr 24) and $7f) in
          [1..127]) then
        begin

          case Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) of
            1..3: Result := #9'= ' + reg[abs(IdentifierAt(IdentIndex).Value shr 24) and $7f];
            4..19: Result := #9'= :STACKORIGIN-' + IntToStr(Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) - 3);
            else
              Result := #9'= ''out of resource'''
          end;

          size := 0;
        end
        else

          if IdentifierAt(IdentIndex).isExternal {and (IdentifierAt(IdentIndex).Libraries = 0)} then
          begin
            Result := #9'= ' + IdentifierAt(IdentIndex).Alias;
          end
          else

            if IdentifierAt(IdentIndex).isAbsolute then
            begin

              if IdentifierAt(IdentIndex).Value < 0 then
                Result := #9'= DATAORIGIN+$' + IntToHex(abs(IdentifierAt(IdentIndex).Value), 4)
              else
                if abs(IdentifierAt(IdentIndex).Value) < 256 then
                  Result := #9'= $' + IntToHex(Byte(IdentifierAt(IdentIndex).Value), 2)
                else
                  Result := #9'= $' + IntToHex(IdentifierAt(IdentIndex).Value, 4);

            end
            else

              if IdentifierAt(IdentIndex).NumAllocElements > 0 then
                Result := #9'= CODEORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - CODEORIGIN_BASE - CODEORIGIN, 4)
              else
                if abs(v) < 256 then
                  Result := #9'= $' + IntToHex(Byte(v), 2)
                else
                  Result := #9'= $' + IntToHex(v, 4);

    end;

    // ----------------------------------------------------------------------------

    function mads_data_size: String;
    begin

      Result := '';

      if IdentifierAt(IdentIndex).AllocElementType in [BYTETOK..FORWARDTYPE] then
      begin

        case DataSize[IdentifierAt(IdentIndex).AllocElementType] of
          //1: Result := ' .byte';
          2: Result := ' .word';
          4: Result := ' .dword';
        end;

      end
      else
        Result := ' ; type unknown';

    end;

    // ----------------------------------------------------------------------------

    function SetBank: Boolean;
    var
      i, IdentTemp: Integer;
      hnam, rnam: String;
    begin

      Result := False;

      hnam := AnsiUpperCase(ExtractFileName(fnam));
      hnam := ChangeFileExt(hnam, '');

      for i := 0 to High(resArray) - 1 do
      begin

        rnam := AnsiUpperCase(ExtractFileName(resArray[i].resFile));
        rnam := ChangeFileExt(rnam, '');

        if hnam = rnam then
        begin
          IdentTemp := GetIdent(resArray[i].resName);

          if IdentTemp > 0 then
          begin
            asm65('');
            asm65(#9'lmb #$' + IntToHex(IdentifierAt(IdentTemp).Value + 1, 2));
            asm65('');

            Result := True;

            exit(True);
          end;

        end;

      end;

    end;

    // ----------------------------------------------------------------------------

    procedure IncSize(bytes: Integer);
    begin
      // LogTrace(Format('IncSize %d by %d', [size, bytes]));
      Inc(size, bytes);
    end;

    // ----------------------------------------------------------------------------
  begin

    if Pass = CODEGENERATIONPASS then
    begin

      StopOptimization;

      emptyLine := True;
      size := 0;
      varbegin := '';

      for IdentIndex := 1 to NumIdent do
        if (IdentifierAt(IdentIndex).Block = IdentifierAt(BlockIdentIndex).ProcAsBlock) and
          (IdentifierAt(IdentIndex).UnitIndex = UnitNameIndex) then
        begin

          if emptyLine then
          begin
            asm65separator;
            asm65;

            emptyLine := False;
          end;


          if IdentifierAt(IdentIndex).isExternal and (IdentifierAt(IdentIndex).Libraries > 0) then
          begin      // read file header libraryname.hea

            fnam := linkObj[TokenAt(IdentifierAt(IdentIndex).Libraries).Value];


            if RCLIBRARY then
              if SetBank = False then Error(IdentifierAt(IdentIndex).Libraries, 'Error: Bank identifier missing.');


            if ExtractFileExt(fnam) = '' then fnam := ChangeFileExt(fnam, '.hea');

            fnam := FindFile(fnam, 'header');

            if IdentifierAt(IdentIndex).isOverload then
              svar := IdentifierAt(IdentIndex).Alias + '.' + GetOverloadName(IdentIndex)
            else
              svar := IdentifierAt(IdentIndex).Alias;

            yes := True;

            AssignFile(HeaFile, fnam);
            FileMode := 0;
            Reset(HeaFile);

            while not EOF(HeaFile) do
            begin
              readln(HeaFile, txt);

              txt := AnsiUpperCase(txt);

              if (length(txt) > 255) or (pos(#0, txt) > 0) then
              begin
                CloseFile(HeaFile);

                Error(IdentifierAt(IdentIndex).Libraries, 'Error: MADS header file ''' + fnam + ''' has invalid format.');
              end;

              if (txt.IndexOf('.@EXIT') < 0) and (txt.IndexOf('.@VARDATA') < 0) then      // skip '@.EXIT', '.@VARDATA'
                if (pos('MAIN.' + svar + ' ', txt) = 1) or (pos('MAIN.' + svar + #9, txt) = 1) or
                  (pos('MAIN.' + svar + '.', txt) = 1) then
                begin
                  yes := False;

                  asm65(IdentifierAt(IdentIndex).Name + copy(txt, 6 + length(IdentifierAt(IdentIndex).Alias), length(txt)));
                end;

            end;

            if yes then
              Error(IdentifierAt(IdentIndex).Libraries, UnknownIdentifier, IdentIndex);

            CloseFile(HeaFile);

            if RCLIBRARY then
            begin
              asm65('');
              asm65(#9'rmb');
              asm65('');
            end;        // reset bank -> #0

          end
          else


            case IdentifierAt(IdentIndex).Kind of

              VARIABLE: if IdentifierAt(IdentIndex).isAbsolute then
                begin    // ABSOLUTE = TRUE

                  if (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
                    (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK] + Pointers) and
                    (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                  begin

                    asm65('adr.' + IdentifierAt(IdentIndex).Name + Value);
                    asm65('.var ' + IdentifierAt(IdentIndex).Name + #9'= adr.' + IdentifierAt(IdentIndex).Name + ' .word');

                    if size = 0 then varbegin := IdentifierAt(IdentIndex).Name;
                    IncSize(IdentifierAt(IdentIndex).NumAllocElements * DataSize[IdentifierAt(IdentIndex).AllocElementType]);

                  end
                  else
                    if IdentifierAt(IdentIndex).DataType = FILETOK then
                      asm65('.var ' + IdentifierAt(IdentIndex).Name + Value + ' .word')
                    else
                      if pos('@FORTMP_', IdentifierAt(IdentIndex).Name) = 0 then asm65(IdentifierAt(IdentIndex).Name + Value);

                end
                else            // ABSOLUTE = FALSE

                  if (IdentifierAt(IdentIndex).PassMethod <> VARPASSING) and
                    (IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK] + Pointers) and
                    (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                  begin

                    //  writeln(IdentifierAt(IdentIndex).Name,',', IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).IdType);

                    if ((IdentifierAt(IdentIndex).IdType <> ARRAYTOK) and
                      (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK])) or
                      (IdentifierAt(IdentIndex).IdType = DATAORIGINOFFSET) then

                      asm65(IdentifierAt(IdentIndex).Name + Value(True))

                    else
                    begin

                      if IdentifierAt(IdentIndex).DataType in [RECORDTOK, OBJECTTOK] then
                        asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True) + #9'; [' +
                          IntToStr(RecordSize(IdentIndex)) + '] ' + InfoAboutToken(IdentifierAt(IdentIndex).DataType))
                      else

                        if Elements(IdentIndex) > 0 then
                        begin

                          //  writeln(IdentifierAt(IdentIndex).Name,' | ',Elements(IdentIndex),'/',IdentifierAt(IdentIndex).IdType,'/',IdentifierAt(IdentIndex).PassMethod ,' | ', IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).IdType);

                          if (IdentifierAt(IdentIndex).NumAllocElements_ > 0) and not
                            (IdentifierAt(IdentIndex).AllocElementType in [RECORDTOK, OBJECTTOK]) then
                            asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True, True) +
                              ' .array [' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements) +
                              '] [' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements_) + ']' + mads_data_size)
                          else
                            asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True, True) +
                              ' .array [' + IntToStr(Elements(IdentIndex)) + ']' + mads_data_size);  // !!!!

                        end
                        else
                          asm65('adr.' + IdentifierAt(IdentIndex).Name + Value(True));

                      asm65('.var ' + IdentifierAt(IdentIndex).Name + #9'= adr.' + IdentifierAt(IdentIndex).Name + ' .word');
                      // !!!!

                    end;

                    if size = 0 then varbegin := IdentifierAt(IdentIndex).Name;
                    IncSize(IdentifierAt(IdentIndex).NumAllocElements * DataSize[IdentifierAt(IdentIndex).AllocElementType]);

                  end
                  else
                    if (IdentifierAt(IdentIndex).DataType = FILETOK) {and (IdentifierAt(IdentIndex).Block = 1)} then
                      asm65('.var ' + IdentifierAt(IdentIndex).Name + Value(True) + ' .word')  // tylko wskaznik
                    else
                    begin
                      asm65(IdentifierAt(IdentIndex).Name + Value(True));

                      if size = 0 then varbegin := IdentifierAt(IdentIndex).Name;

                      if IdentifierAt(IdentIndex).idType <> DATAORIGINOFFSET then      // indeksy do RECORD nie zliczaj

                        if (IdentifierAt(IdentIndex).Name = 'RESULT') and (IdentifierAt(BlockIdentIndex).Kind = FUNCTIONTOK) then
                        // RESULT nie zliczaj

                        else
                          if IdentifierAt(IdentIndex).DataType = ENUMTYPE then
                            IncSize(DataSize[IdentifierAt(IdentIndex).AllocElementType])
                          else
                            IncSize(DataSize[IdentifierAt(IdentIndex).DataType]);

                    end;

              CONSTANT: if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) then
                begin

                  asm65('adr.' + IdentifierAt(IdentIndex).Name + Value);
                  asm65('.var ' + IdentifierAt(IdentIndex).Name + #9'= adr.' + IdentifierAt(IdentIndex).Name + ' .word');

                end
                else
                  if pos('@FORTMP_', IdentifierAt(IdentIndex).Name) = 0 then asm65(IdentifierAt(IdentIndex).Name + Value);
            end;

        end;

      if (BlockStack[BlockStackTop] <> 1) then
      begin

        asm65;

        if LIBRARY_USE then asm65('@InitLibrary'#9'= :START');

        if VarSize and (size > 0) then
        begin
          asm65('@VarData'#9'= ' + varbegin);
          asm65('@VarDataSize'#9'= ' + IntToStr(size));
          asm65;
        end;

      end;

    end;

  end;  //GenerateProcFuncAsmLabels


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure SaveToStaticDataSegment(ConstDataSize: Integer; ConstVal: Int64; ConstValType: Byte);
  var
    ftmp: TFloat;
  begin

    if (ConstDataSize < 0) or (ConstDataSize > $FFFF) then
    begin
      writeln('SaveToStaticDataSegment: ', ConstDataSize);
      halt;
    end;

    ftmp := Default(TFloat);

    case ConstValType of

      SHORTINTTOK, BYTETOK, CHARTOK, BOOLEANTOK:
        StaticStringData[ConstDataSize] := Byte(ConstVal);

      SMALLINTTOK, WORDTOK, SHORTREALTOK, POINTERTOK, STRINGPOINTERTOK, PCHARTOK:
      begin
        StaticStringData[ConstDataSize] := Byte(ConstVal);
        StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
      end;

      DATAORIGINOFFSET:
      begin
        StaticStringData[ConstDataSize] := Byte(ConstVal) or $8000;
        StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8) or $4000;
      end;

      CODEORIGINOFFSET:
      begin
        StaticStringData[ConstDataSize] := Byte(ConstVal) or $2000;
        StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8) or $1000;
      end;

      INTEGERTOK, CARDINALTOK, REALTOK:
      begin
        StaticStringData[ConstDataSize] := Byte(ConstVal);
        StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
        StaticStringData[ConstDataSize + 2] := Byte(ConstVal shr 16);
        StaticStringData[ConstDataSize + 3] := Byte(ConstVal shr 24);
      end;

      SINGLETOK: begin
        move(ConstVal, ftmp, sizeof(ftmp));

        ConstVal := ftmp[1];

        StaticStringData[ConstDataSize] := Byte(ConstVal);
        StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
        StaticStringData[ConstDataSize + 2] := Byte(ConstVal shr 16);
        StaticStringData[ConstDataSize + 3] := Byte(ConstVal shr 24);
      end;

      HALFSINGLETOK: begin
        move(ConstVal, ftmp, sizeof(ftmp));
        ConstVal := CardToHalf(ftmp[1]);

        StaticStringData[ConstDataSize] := Byte(ConstVal);
        StaticStringData[ConstDataSize + 1] := Byte(ConstVal shr 8);
      end;

    end;
  end;


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function ReadDataArray(i: Integer; ConstDataSize: Integer; const ConstValType: Byte;
    NumAllocElements: Cardinal; StaticData: Boolean; Add: Boolean = False): Integer;
  var
    ActualParamType, ch: Byte;
    NumActualParams, NumActualParams_, NumAllocElements_: Cardinal;
    ConstVal: Int64;

    // ----------------------------------------------------------------------------

    procedure SaveDataSegment(DataType: Byte);
    begin

      if StaticData then
        SaveToStaticDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType)
      else
        SaveToDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType);

      if DataType = DATAORIGINOFFSET then
        Inc(ConstDataSize, DataSize[POINTERTOK])
      else
        Inc(ConstDataSize, DataSize[DataType]);

    end;


    // ----------------------------------------------------------------------------

    procedure SaveData(compile: Boolean = True);
    begin

      if compile then
        i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


      if (ConstValType = STRINGPOINTERTOK) and (ActualParamType = CHARTOK) then
      begin  // rejestrujemy CHAR jako STRING

        if StaticData then
          Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

        ch := TokenAt(i).Value;
        DefineStaticString(i, chr(ch));

        ConstVal := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
        Tok[i].Value := ch;

        ActualParamType := STRINGPOINTERTOK;

      end;


      if (ConstValType in StringTypes + [CHARTOK, STRINGPOINTERTOK]) and (ActualParamType in
        IntegerTypes + RealTypes) then
        Error(i, IllegalExpression);


      if (ConstValType in StringTypes + [STRINGPOINTERTOK]) and (ActualParamType = CHARTOK) then
        Error(i, IncompatibleTypes, 0, ActualParamType, ConstValType);


      if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (ActualParamType = REALTOK) then
        ActualParamType := ConstValType;

      if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then
      begin
        Int2Float(ConstVal);
        ActualParamType := ConstValType;
      end;

      if (ConstValType = SHORTREALTOK) and (ActualParamType = REALTOK) then
        ActualParamType := SHORTREALTOK;


      if ActualParamType = DATAORIGINOFFSET then

        SaveDataSegment(DATAORIGINOFFSET)

      else
      begin

        if ConstValType in IntegerTypes then
        begin

          if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
            warning(i, RangeCheckError, 0, ConstVal, ConstValType);

        end
        else
          GetCommonConstType(i, ConstValType, ActualParamType);

        SaveDataSegment(ConstValType);

      end;

    end;


    // ----------------------------------------------------------------------------

{$i include/doevaluate.inc}

    // ----------------------------------------------------------------------------

  begin

{
  if (TokenAt(i).Kind = STRINGLITERALTOK) and (ConstValType = CHARTOK) then begin    // init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   if TokenAt(i).StrLength > NumAllocElements then
     Error(i, 'string length is larger than array of char length');

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > TokenAt(i).StrLength then
     ConstVal := byte(' ')
    else
     ConstVal := byte(StaticStringData[TokenAt(i).StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;
}

    CheckTok(i, OPARTOK);

    NumActualParams := 0;
    NumActualParams_ := 0;

    NumAllocElements_ := NumAllocElements shr 16;
    NumAllocElements := NumAllocElements and $ffff;

    repeat

      Inc(NumActualParams);
      //  if NumActualParams > NumAllocElements then Break;

      if NumAllocElements_ > 0 then
      begin

        NumActualParams_ := 0;

        CheckTok(i + 1, OPARTOK);
        Inc(i);

        repeat
          Inc(NumActualParams_);
          if NumActualParams_ > NumAllocElements_ then Break;

          SaveData;

          Inc(i);
        until TokenAt(i).Kind <> COMMATOK;

        CheckTok(i, CPARTOK);

        //inc(i);
      end
      else
      //SaveData;
        if TokenAt(i + 1).Kind = EVALTOK then
          NumActualParams := doEvaluate
        else
          SaveData;


      Inc(i);

    until TokenAt(i).Kind <> COMMATOK;

    CheckTok(i, CPARTOK);


    if NumActualParams > NumAllocElements then
      Error(i, 'Number of elements (' + IntToStr(NumActualParams) + ') differs from declaration (' +
        IntToStr(NumAllocElements) + ')');

    if NumActualParams < NumAllocElements then
      Error(i, 'Expected another ' + IntToStr(NumAllocElements - NumActualParams) + ' array elements');

    if NumActualParams_ < NumAllocElements_ then
      Error(i, 'Expected another ' + IntToStr(NumAllocElements_ - NumActualParams_) + ' array elements');

    Result := i;

  end;  //ReadDataArray


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function ReadDataOpenArray(i: Integer; ConstDataSize: Integer; const ConstValType: Byte;
    out NumAllocElements: Cardinal; StaticData: Boolean; Add: Boolean = False): Integer;
  var
    ActualParamType, ch: Byte;
    NumActualParams: Cardinal;
    ConstVal: Int64;


    // ----------------------------------------------------------------------------


    procedure SaveDataSegment(DataType: Byte);
    begin

      if StaticData then
        SaveToStaticDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType)
      else
        SaveToDataSegment(ConstDataSize, ConstVal + Ord(Add), DataType);

      if DataType = DATAORIGINOFFSET then
        Inc(ConstDataSize, DataSize[POINTERTOK])
      else
        Inc(ConstDataSize, DataSize[DataType]);

    end;


    // ----------------------------------------------------------------------------


    procedure SaveData(compile: Boolean = True);
    begin

      if compile then
        i := CompileConstExpression(i + 1, ConstVal, ActualParamType, ConstValType);


      if (ConstValType = STRINGPOINTERTOK) and (ActualParamType = CHARTOK) then
      begin  // rejestrujemy CHAR jako STRING

        if StaticData then
          Error(i, 'Memory overlap due conversion CHAR to STRING, use VAR instead CONST');

        ch := TokenAt(i).Value;
        DefineStaticString(i, chr(ch));

        ConstVal := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
        Tok[i].Value := ch;

        ActualParamType := STRINGPOINTERTOK;

      end;


      if (ConstValType in StringTypes + [CHARTOK, STRINGPOINTERTOK]) and (ActualParamType in
        IntegerTypes + RealTypes) then
        Error(i, IllegalExpression);


      if (ConstValType in StringTypes + [STRINGPOINTERTOK]) and (ActualParamType = CHARTOK) then
        Error(i, IncompatibleTypes, 0, ActualParamType, ConstValType);


      if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (ActualParamType = REALTOK) then
        ActualParamType := ConstValType;

      if (ConstValType in RealTypes) and (ActualParamType in IntegerTypes) then
      begin
        Int2Float(ConstVal);
        ActualParamType := ConstValType;
      end;

      if (ConstValType = SHORTREALTOK) and (ActualParamType = REALTOK) then
        ActualParamType := SHORTREALTOK;


      if ActualParamType = DATAORIGINOFFSET then

        SaveDataSegment(DATAORIGINOFFSET)

      else
      begin

        if ConstValType in IntegerTypes then
        begin

          if GetCommonConstType(i, ConstValType, ActualParamType, (ActualParamType in RealTypes + Pointers)) then
            warning(i, RangeCheckError, 0, ConstVal, ConstValType);

        end
        else
          GetCommonConstType(i, ConstValType, ActualParamType);

        SaveDataSegment(ConstValType);

      end;

      Inc(NumActualParams);

    end;


    // ----------------------------------------------------------------------------

{$i include/doevaluate.inc}

    // ----------------------------------------------------------------------------

  begin

{
  if (TokenAt(i).Kind = STRINGLITERALTOK) and (ConstValType = CHARTOK) then begin    // init char array by string -> array [0..15] of char = '0123456789ABCDEF';

   NumAllocElements := TokenAt(i).StrLength;

   for NumActualParams:=1 to NumAllocElements do begin

    if NumActualParams > TokenAt(i).StrLength then
     ConstVal := byte(' ')
    else
     ConstVal := byte(StaticStringData[TokenAt(i).StrAddress - CODEORIGIN + NumActualParams]);

    SaveDataSegment(CHARTOK);
   end;

   Result := i;
   exit;
  end;
}

    CheckTok(i, OBRACKETTOK);

    NumActualParams := 0;
    NumAllocElements := 0;


    if TokenAt(i + 1).Kind = CBRACKETTOK then

      Inc(i)

    else
      repeat

        if TokenAt(i + 1).Kind = EVALTOK then
          doEvaluate
        else
          SaveData;

        Inc(i);

      until TokenAt(i).Kind <> COMMATOK;


    CheckTok(i, CBRACKETTOK);

    NumAllocElements := NumActualParams;

    Result := i;

  end;  //ReadDataOpenArray


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure GenerateLocal(BlockIdentIndex: Integer; IsFunction: Boolean);
  var
    info: String;
  begin

    if IsFunction then
      info := '; FUNCTION'
    else
      info := '; PROCEDURE';

    if IdentifierAt(BlockIdentIndex).isAsm then info := info + ' | ASSEMBLER';
    if IdentifierAt(BlockIdentIndex).isOverload then info := info + ' | OVERLOAD';
    if IdentifierAt(BlockIdentIndex).isRegister then info := info + ' | REGISTER';
    if IdentifierAt(BlockIdentIndex).isInterrupt then info := info + ' | INTERRUPT';
    if IdentifierAt(BlockIdentIndex).isKeep then info := info + ' | KEEP';
    if IdentifierAt(BlockIdentIndex).isPascal then info := info + ' | PASCAL';
    if IdentifierAt(BlockIdentIndex).isInline then info := info + ' | INLINE';

    asm65;

    if codealign.proc > 0 then
    begin
      asm65(#9'.align $' + IntToHex(codealign.proc, 4));
      asm65;
    end;

    asm65('.local'#9 + IdentifierAt(BlockIdentIndex).Name, info);

    if IdentifierAt(BlockIdentIndex).isOverload then
      asm65('.local'#9 + GetOverloadName(BlockIdentIndex));

{
 if IdentifierAt(BlockIdentIndex].isOverload then
   asm65('.local'#9 + IdentifierAt(BlockIdentIndex].Name+'_'+IntToHex(IdentifierAt(BlockIdentIndex].Value, 4), info)
 else
   asm65('.local'#9 + IdentifierAt(BlockIdentIndex].Name, info);
}
    if IdentifierAt(BlockIdentIndex).isInline then asm65(#13#10#9'.MACRO m@INLINE');

  end;  //GenerateLocal


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure FormalParameterList(var i: Integer; var NumParams: Integer; var Param: TParamList;
    out Status: Word; IsNestedFunction: Boolean; out NestedFunctionResultType: Byte;
    out NestedFunctionNumAllocElements: Cardinal; out NestedFunctionAllocElementType: Byte);
  var
    ListPassMethod: TParameterPassingMethod;
    NumVarOfSameType, VarTYpe, AllocElementType: Byte;
    NumAllocElements: Cardinal;
    VarOfSameTypeIndex: Integer;
    VarOfSameType: TVariableList;
  begin

    //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
    VarOfSameType := Default(TVariableList);

    NumParams := 0;

    if (TokenAt(i + 3).Kind = CPARTOK) and (TokenAt(i + 2).Kind = OPARTOK) then
      i := i + 4
    else

      if (TokenAt(i + 2).Kind = OPARTOK) then         // Formal parameter list found
      begin
        i := i + 2;
        repeat
          NumVarOfSameType := 0;

          ListPassMethod := VALPASSING;

          if TokenAt(i + 1).Kind = CONSTTOK then
          begin
            ListPassMethod := CONSTPASSING;
            Inc(i);
          end
          else if TokenAt(i + 1).Kind = VARTOK then
            begin
              ListPassMethod := VARPASSING;
              Inc(i);
            end;

          repeat

            if TokenAt(i + 1).Kind <> IDENTTOK then
              Error(i + 1, 'Formal parameter name expected but ' + GetSpelling(i + 1) + ' found')
            else
            begin
              Inc(NumVarOfSameType);
              VarOfSameType[NumVarOfSameType].Name := TokenAt(i + 1).Name^;
            end;
            i := i + 2;
          until TokenAt(i).Kind <> COMMATOK;


          VarType := 0;              // UNTYPED
          NumAllocElements := 0;
          AllocElementType := 0;

          if (ListPassMethod in [CONSTPASSING, VARPASSING]) and (TokenAt(i).Kind <> COLONTOK) then
          begin

            ListPassMethod := VARPASSING;
            Dec(i);

          end
          else
          begin

            CheckTok(i, COLONTOK);

            if TokenAt(i + 1).Kind = DEREFERENCETOK then      // ^type
              Error(i + 1, 'Type identifier expected');

            i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

            if (VarType = FILETOK) and (ListPassMethod <> VARPASSING) then
              Error(i, 'File types must be var parameters');

          end;


          for VarOfSameTypeIndex := 1 to NumVarOfSameType do
          begin

            //      if NumAllocElements > 0 then
            //        Error(i, 'Structured parameters cannot be passed by value');

            Inc(NumParams);
            if NumParams > MAXPARAMS then
              Error(i, TooManyParameters, NumIdent)
            else
            begin
              //        VarOfSameType[VarOfSameTypeIndex].DataType      := VarType;

              Param[NumParams].DataType := VarType;
              Param[NumParams].Name := VarOfSameType[VarOfSameTypeIndex].Name;
              Param[NumParams].NumAllocElements := NumAllocElements;
              Param[NumParams].AllocElementType := AllocElementType;
              Param[NumParams].PassMethod := ListPassMethod;

            end;
          end;

          i := i + 1;
        until TokenAt(i).Kind <> SEMICOLONTOK;

        CheckTok(i, CPARTOK);

        i := i + 1;
      end// if TokenAt(i + 2).Kind = OPARTOR
      else
        i := i + 2;

    //      NestedFunctionResultType := 0;
    //      NestedFunctionNumAllocElements := 0;
    //      NestedFunctionAllocElementType := 0;

    Status := 0;

    if IsNestedFunction then
    begin

      CheckTok(i, COLONTOK);

      if TokenAt(i + 1).Kind = ARRAYTOK then
        Error(i + 1, 'Type identifier expected');

      i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

      NestedFunctionResultType := VarType;         // Result
      NestedFunctionNumAllocElements := NumAllocElements;
      NestedFunctionAllocElementType := AllocElementType;

      i := i + 1;
    end;  // if IsNestedFunction

    CheckTok(i, SEMICOLONTOK);


    while TokenAt(i + 1).Kind in [OVERLOADTOK, ASSEMBLERTOK, FORWARDTOK, REGISTERTOK, INTERRUPTTOK,
        PASCALTOK, STDCALLTOK, INLINETOK, KEEPTOK] do
    begin

      case TokenAt(i + 1).Kind of

        OVERLOADTOK: begin
          Status := Status or Ord(mOverload);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

        ASSEMBLERTOK: begin
          Status := Status or Ord(mAssembler);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

{       FORWARDTOK: begin
         Status := Status or ord(mForward);
         inc(i);
         CheckTok(i + 1, SEMICOLONTOK);
       end;
 }
        REGISTERTOK: begin
          Status := Status or Ord(mRegister);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

        STDCALLTOK: begin
          Status := Status or Ord(mStdCall);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

        INLINETOK: begin
          Status := Status or Ord(mInline);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

        INTERRUPTTOK: begin
          Status := Status or Ord(mInterrupt);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

        PASCALTOK: begin
          Status := Status or Ord(mPascal);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;

        KEEPTOK: begin
          Status := Status or Ord(mKeep);
          Inc(i);
          CheckTok(i + 1, SEMICOLONTOK);
        end;
      end;

      Inc(i);
    end;// while

  end;  //FormalParameterList


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure CheckForwardResolutions(typ: Boolean = True);
  var
    TypeIndex, IdentIndex: Integer;
    Name: String;
  begin

    // Search for unresolved forward references
    for TypeIndex := 1 to NumIdent do
      if (IdentifierAt(TypeIndex).AllocElementType = FORWARDTYPE) and (IdentifierAt(TypeIndex).Block =
        BlockStack[BlockStackTop]) then
      begin

        Name := IdentifierAt(GetIdent(TokenAt(IdentifierAt(TypeIndex).NumAllocElements).Name^)).Name;

        if IdentifierAt(GetIdent(TokenAt(IdentifierAt(TypeIndex).NumAllocElements).Name^)).Kind = TYPETOK then

          for IdentIndex := 1 to NumIdent do
            if (IdentifierAt(IdentIndex).Name = Name) and (IdentifierAt(IdentIndex).Block = BlockStack[BlockStackTop]) then
            begin

              Ident[TypeIndex].NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements;
              Ident[TypeIndex].NumAllocElements_ := IdentifierAt(IdentIndex).NumAllocElements_;
              Ident[TypeIndex].AllocElementType := IdentifierAt(IdentIndex).DataType;

              Break;
            end;

      end;


    // Search for unresolved forward references
    for TypeIndex := 1 to NumIdent do
      if (IdentifierAt(TypeIndex).AllocElementType = FORWARDTYPE) and (IdentifierAt(TypeIndex).Block =
        BlockStack[BlockStackTop]) then

        if typ then
          Error(TypeIndex, 'Unresolved forward reference to type ' + IdentifierAt(TypeIndex).Name)
        else
          Error(TypeIndex, 'Identifier not found "' +
            IdentifierAt(GetIdent(TokenAt(IdentifierAt(TypeIndex).NumAllocElements).Name^)).Name + '"');

  end;  //CheckForwardResolutions


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure CompileRecordDeclaration(i: Integer; var VarOfSameType: TVariableList;
  var tmpVarDataSize: Integer; var ConstVal: Int64; VarOfSameTypeIndex: Integer;
    VarType, AllocElementType: Byte; NumAllocElements: Cardinal; isAbsolute: Boolean; var idx: Integer);
  var
    tmpVarDataSize_, ParamIndex: Integer;
  begin

    //  writeln(iDtype,',',VarOfSameType[VarOfSameTypeIndex].Name,' / ',NumAllocElements,' , ',VarType,',',Types[NumAllocElements].Block,' | ', AllocElementType);

    if ((VarType in Pointers) and (AllocElementType = RECORDTOK)) then
    begin

      //   writeln('> ',VarOfSameType[VarOfSameTypeIndex].Name,',',NestedDataType, ',',NestedAllocElementType,',', NestedNumAllocElements,',',NestedNumAllocElements and $ffff,'/',NestedNumAllocElements shr 16);

      tmpVarDataSize_ := GetVarDataSize;


      if (NumAllocElements shr 16) > 0 then
      begin                      // array [0..x] of record

        Ident[NumIdent].NumAllocElements := NumAllocElements and $FFFF;
        Ident[NumIdent].NumAllocElements_ := NumAllocElements shr 16;

        SetVarDataSize(i, tmpVarDataSize + (NumAllocElements shr 16) * DataSize[POINTERTOK]);

        tmpVarDataSize := GetVarDataSize;

        NumAllocElements := NumAllocElements and $FFFF;

      end
      else
        if IdentifierAt(NumIdent).isAbsolute = False then Inc(tmpVarDataSize, DataSize[POINTERTOK]);
      // wskaznik dla ^record


      idx := IdentifierAt(NumIdent).Value - DATAORIGIN;

      //writeln(NumAllocElements);
      //!@!@
      for ParamIndex := 1 to Types[NumAllocElements].NumFields do                  // label: ^record
        if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then
        begin

          //      writeln('a ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,',',Types[NumAllocElements].Field[ParamIndex].DataType,',',Types[NumAllocElements].Field[ParamIndex].AllocElementType,',',Types[NumAllocElements].Field[ParamIndex].NumAllocElements);

          DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,
            VARIABLE,
            Types[NumAllocElements].Field[ParamIndex].DataType,
            Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
            Types[NumAllocElements].Field[ParamIndex].AllocElementType, 0, DATAORIGINOFFSET);

          Ident[NumIdent].Value := IdentifierAt(NumIdent).Value - tmpVarDataSize_;
          Ident[NumIdent].PassMethod := VARPASSING;
          //      IdentifierAt(NumIdent].AllocElementType := IdentifierAt(NumIdent].DataType;

        end;

      SetVarDataSize(i, tmpVarDataSize);

    end
    else

      if (VarType in [RECORDTOK, OBJECTTOK]) then                      // label: record
        for ParamIndex := 1 to Types[NumAllocElements].NumFields do
          if (Types[NumAllocElements].Block = 1) or (Types[NumAllocElements].Block = BlockStack[BlockStackTop]) then
          begin

            //      writeln('b ',',',VarOfSameType[VarOfSameTypeIndex].Name + '.' + Types[NumAllocElements].Field[ParamIndex].Name,',',Types[NumAllocElements].Field[ParamIndex].DataType,',',Types[NumAllocElements].Field[ParamIndex].AllocElementType,',',Types[NumAllocElements].Field[ParamIndex].NumAllocElements,' | ',IdentifierAt(NumIdent].Value);

            tmpVarDataSize_ := GetVarDataSize;

            DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name + '.' +
              Types[NumAllocElements].Field[ParamIndex].Name,
              VARIABLE,
              Types[NumAllocElements].Field[ParamIndex].DataType,
              Types[NumAllocElements].Field[ParamIndex].NumAllocElements,
              Types[NumAllocElements].Field[ParamIndex].AllocElementType, Ord(isAbsolute) * ConstVal);

            if isAbsolute then
              if not (Types[NumAllocElements].Field[ParamIndex].DataType in [RECORDTOK, OBJECTTOK]) then
                // fixed https://forums.atariage.com/topic/240919-mad-pascal/?do=findComment&comment=5422587
                Inc(ConstVal, GetVarDataSize - tmpVarDataSize_);
            //    DataSize[Types[NumAllocElements].Field[ParamIndex].DataType]);

          end;

  end;  //CompileRecordDeclaration


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  function CompileBlock(i: Integer; BlockIdentIndex: Integer; NumParams: Integer; IsFunction: Boolean;
    FunctionResultType: Byte; FunctionNumAllocElements: Cardinal = 0; FunctionAllocElementType: Byte = 0): Integer;
  var
    VarOfSameType: TVariableList;
    VarPassMethod: TParameterPassingMethod;
    Param: TParamList;
    j, idx, NumVarOfSameType, VarOfSameTypeIndex, tmpVarDataSize, ParamIndex, ForwardIdentIndex,
    IdentIndex, external_libr: Integer;
    NumAllocElements, NestedNumAllocElements, NestedFunctionNumAllocElements: Cardinal;
    ConstVal: Int64;
    ImplementationUse, open_array, iocheck_old, isInterrupt_old, yes, Assignment,
    {pack,} IsNestedFunction, isAbsolute, isExternal, isForward, isVolatile, isStriped, isAsm,
    isReg, isInt, isInl, isOvr: Boolean;
    VarType, VarRegister, NestedFunctionResultType, ConstValType, AllocElementType, ActualParamType,
    NestedFunctionAllocElementType, NestedDataType, NestedAllocElementType, IdType: Byte;
    Tmp, TmpResult: Word;

    external_name: TString;

    UnitList: array of TString;

  begin

    ResetOpty;

    //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
    VarOfSameType := Default(TVariableList);

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

    ImplementationUse := False;

    Param := IdentifierAt(BlockIdentIndex).Param;
    isAsm := IdentifierAt(BlockIdentIndex).isAsm;
    isReg := IdentifierAt(BlockIdentIndex).isRegister;
    isInt := IdentifierAt(BlockIdentIndex).isInterrupt;
    isInl := IdentifierAt(BlockIdentIndex).isInline;
    isOvr := IdentifierAt(BlockIdentIndex).isOverload;

    isInterrupt := isInt;

    Inc(NumBlocks);
    Inc(BlockStackTop);
    BlockStack[BlockStackTop] := NumBlocks;
    Ident[BlockIdentIndex].ProcAsBlock := NumBlocks;


    GenerateLocal(BlockIdentIndex, IsFunction);

    if (BlockStack[BlockStackTop] <> 1) {and (NumParams > 0)} and IdentifierAt(BlockIdentIndex).isRecursion then
    begin

      if IdentifierAt(BlockIdentIndex).isRegister then
        Error(i, 'Calling convention directive "REGISTER" not applicable with recursion');

      if not isInl then
      begin
        asm65(#9'.ifdef @VarData');

        if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
        begin
          asm65(#9'sta :bp2');
          asm65(#9'sty :bp2+1');
        end;

        asm65('@new'#9'lda <@VarData');      // @AllocMem
        asm65(#9'sta :ztmp');
        asm65(#9'lda >@VarData');
        asm65(#9'ldy #@VarDataSize-1');
        asm65(#9'jsr @AllocMem');

        if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
        begin
          asm65(#9'lda :bp2');
          asm65(#9'ldy :bp2+1');
        end;

        asm65(#9'eif');
      end;

    end;


    if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
    begin

      //  if ParamIndex = 1 then begin
      asm65(#9'sta ' + Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[0].Name);
      asm65(#9'sty ' + Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[0].Name + '+1');

      DefineIdent(i, Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[0].Name, VARIABLE, WORDTOK, 0, 0, 0);
      Ident[NumIdent].PassMethod := VARPASSING;
      Ident[NumIdent].AllocElementType := WORDTOK;
      //  end;

      NumAllocElements := 0;

      for ParamIndex := 1 to Types[IdentifierAt(BlockIdentIndex).ObjectIndex].NumFields do
        if Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].ObjectVariable = False then
        begin

          if NumAllocElements > 0 then
            if NumAllocElements > 255 then
            begin
              asm65(#9'add <' + IntToStr(NumAllocElements));
              asm65(#9'pha');
              asm65(#9'tya');
              asm65(#9'adc >' + IntToStr(NumAllocElements));
              asm65(#9'tay');
              asm65(#9'pla');
            end
            else
            begin
              asm65(#9'add #' + IntToStr(NumAllocElements));
              asm65(#9'scc');
              asm65(#9'iny');
            end;

          asm65(#9'sta ' + Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].Name);
          asm65(#9'sty ' + Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].Name + '+1');


          if ParamIndex <> Types[IdentifierAt(BlockIdentIndex).ObjectIndex].NumFields then
          begin

            if (Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType = POINTERTOK) and
              (Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements > 0) then
            begin

              NumAllocElements := Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements
                and $ffff;

              if Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements shr 16 > 0 then
                NumAllocElements := (NumAllocElements *
                  (Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements shr 16));

              NumAllocElements := NumAllocElements *
                DataSize[Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].AllocElementType];

            end
            else
              case Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType of
                FILETOK: NumAllocElements := 12;
                STRINGPOINTERTOK: NumAllocElements :=
                    Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements;
                RECORDTOK: NumAllocElements :=
                    ObjectRecordSize(Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements);
                else
                  NumAllocElements := DataSize[Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType];
              end;

          end;

        end;

    end;   // IdentifierAt(BlockIdentIndex).ObjectIndex


    //writeln;
    // Allocate parameters as local variables of the current block if necessary
    for ParamIndex := 1 to NumParams do
    begin

      //  writeln(Param[ParamIndex].Name,':',Param[ParamIndex].DataType,'|',Param[ParamIndex].NumAllocElements and $FFFF,'/',Param[ParamIndex].NumAllocElements shr 16);

      if Param[ParamIndex].PassMethod = VARPASSING then
      begin

        if isReg and (ParamIndex in [1..3]) then
        begin
          tmpVarDataSize := GetVarDataSize;

          DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType,
            Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

          Ident[GetIdent(Param[ParamIndex].Name)].isAbsolute := True;
          Ident[GetIdent(Param[ParamIndex].Name)].Value := (Byte(ParamIndex) shl 24) or $80000000;

          SetVarDataSize(i, tmpVarDataSize);

        end
        else
          if Param[ParamIndex].DataType in Pointers then
            DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType, 0,
              Param[ParamIndex].DataType, 0)
          else
            DefineIdent(i, Param[ParamIndex].Name, VARIABLE, POINTERTOK, 0, Param[ParamIndex].DataType, 0);


        if (Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK]) then
        begin

          tmpVarDataSize := GetVarDataSize;

          for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do
          begin

            DefineIdent(i, Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,
              VARIABLE,
              Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,
              Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
              Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, DATAORIGINOFFSET);

            Ident[NumIdent].Value := IdentifierAt(NumIdent).Value - tmpVarDataSize;
            Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;

            if IdentifierAt(NumIdent).AllocElementType = UNTYPETOK then Ident[NumIdent].AllocElementType :=
                IdentifierAt(NumIdent).DataType;

          end;

          SetVarDataSize(i, tmpVarDataSize);

        end
        else

          if Param[ParamIndex].DataType in Pointers then
            Ident[GetIdent(Param[ParamIndex].Name)].AllocElementType := Param[ParamIndex].AllocElementType
          else
            Ident[GetIdent(Param[ParamIndex].Name)].AllocElementType := Param[ParamIndex].DataType;

        Ident[GetIdent(Param[ParamIndex].Name)].NumAllocElements := Param[ParamIndex].NumAllocElements and $FFFF;
        Ident[GetIdent(Param[ParamIndex].Name)].NumAllocElements_ := Param[ParamIndex].NumAllocElements shr 16;

      end
      else
      begin
        if isReg and (ParamIndex in [1..3]) then
        begin
          tmpVarDataSize := GetVarDataSize;

          DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType,
            Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

          Ident[GetIdent(Param[ParamIndex].Name)].isAbsolute := True;
          Ident[GetIdent(Param[ParamIndex].Name)].Value := (Byte(ParamIndex) shl 24) or $80000000;

          SetVarDataSize(i, tmpVarDataSize);

        end
        else
          DefineIdent(i, Param[ParamIndex].Name, VARIABLE, Param[ParamIndex].DataType,
            Param[ParamIndex].NumAllocElements, Param[ParamIndex].AllocElementType, 0);

        //  writeln(Param[ParamIndex].Name,',',Param[ParamIndex].DataType);

        if (Param[ParamIndex].DataType = POINTERTOK) and (Param[ParamIndex].AllocElementType in
          [RECORDTOK, OBJECTTOK]) then
        begin    // fix issue #94

          tmpVarDataSize := GetVarDataSize;

          for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do
          begin

            DefineIdent(i, Param[ParamIndex].Name + '.' + Types[Param[ParamIndex].NumAllocElements].Field[j].Name,
              VARIABLE,
              Types[Param[ParamIndex].NumAllocElements].Field[j].DataType,
              Types[Param[ParamIndex].NumAllocElements].Field[j].NumAllocElements,
              Types[Param[ParamIndex].NumAllocElements].Field[j].AllocElementType, 0, DATAORIGINOFFSET);

            Ident[NumIdent].Value := IdentifierAt(NumIdent).Value - tmpVarDataSize;
            Ident[NumIdent].PassMethod := Param[ParamIndex].PassMethod;

            if IdentifierAt(NumIdent).AllocElementType = UNTYPETOK then Ident[NumIdent].AllocElementType :=
                IdentifierAt(NumIdent).DataType;

          end;

          SetVarDataSize(i, tmpVarDataSize);

        end
        else

          if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then
            for j := 1 to Types[Param[ParamIndex].NumAllocElements].NumFields do
            begin

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
    if IsFunction then
    begin  //DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, 0, 0, 0);

      tmpVarDataSize := GetVarDataSize;

      //  writeln(IdentifierAt(BlockIdentIndex).name,',',FunctionResultType,',',FunctionNumAllocElements,',',FunctionAllocElementType);

      DefineIdent(i, 'RESULT', VARIABLE, FunctionResultType, FunctionNumAllocElements, FunctionAllocElementType, 0);

      if isReg and (FunctionResultType in OrdinalTypes + RealTypes) then
      begin
        Ident[NumIdent].isAbsolute := True;
        Ident[NumIdent].Value := $87000000;  // :STACKORIGIN-4 -> :TMP

        SetVarDataSize(i, tmpVarDataSize);
      end;

      if FunctionResultType in [RECORDTOK, OBJECTTOK] then
        for j := 1 to Types[FunctionNumAllocElements].NumFields do
        begin

          DefineIdent(i, 'RESULT.' + Types[FunctionNumAllocElements].Field[j].Name,
            VARIABLE,
            Types[FunctionNumAllocElements].Field[j].DataType,
            Types[FunctionNumAllocElements].Field[j].NumAllocElements,
            Types[FunctionNumAllocElements].Field[j].AllocElementType, 0);

          //       IdentifierAt(GetIdent(iname)].PassMethod := VALPASSING;
        end;

    end;


    yes := {(IdentifierAt(BlockIdentIndex).ObjectIndex > 0) or} IdentifierAt(BlockIdentIndex).isRecursion or
      IdentifierAt(BlockIdentIndex).isStdCall;

    for ParamIndex := NumParams downto 1 do
      if not ((Param[ParamIndex].PassMethod = VARPASSING) or ((Param[ParamIndex].DataType in Pointers) and
        (Param[ParamIndex].NumAllocElements and $FFFF in [0, 1])) or
        ((Param[ParamIndex].DataType in Pointers) and (Param[ParamIndex].AllocElementType in
        [RECORDTOK, OBJECTTOK])) or (Param[ParamIndex].DataType in OrdinalTypes + RealTypes)) then
      begin
        yes := True;
        Break;
      end;


    // yes:=true;


    // Load ONE parameters from the stack
    if (IdentifierAt(BlockIdentIndex).ObjectIndex = 0) then
      if Param[1].DataType = ENUMTYPE then
      begin

        if (yes = False) and (NumParams = 1) and (DataSize[Param[1].AllocElementType] = 1) and
          (Param[1].PassMethod <> VARPASSING) then asm65(#9'sta ' + Param[1].Name);

      end
      else

        if (yes = False) and (NumParams = 1) and (DataSize[Param[1].DataType] = 1) and
          (Param[1].PassMethod <> VARPASSING) then
          asm65(#9'sta ' + Param[1].Name);


    // Load parameters from the stack
    if yes then
    begin
      for ParamIndex := 1 to NumParams do
      begin

        if IdentifierAt(BlockIdentIndex).isRecursion or IdentifierAt(BlockIdentIndex).isStdCall or (NumParams = 1) then
        begin

          if Param[ParamIndex].PassMethod = VARPASSING then
            GenerateAssignment(ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
          else
          begin

            if Param[ParamIndex].DataType = ENUMTOK then
              GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].AllocElementType], 0, Param[ParamIndex].Name)
            else
              GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);

          end;


          if (Param[ParamIndex].PassMethod <> VARPASSING) and (Param[ParamIndex].DataType in
            [RECORDTOK, OBJECTTOK] + Pointers) and (Param[ParamIndex].NumAllocElements and $FFFF > 1) then
            // copy arrays

            if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then
            begin

              asm65(':move');
              asm65(Param[ParamIndex].Name);
              asm65(IntToStr(RecordSize(GetIdent(Param[ParamIndex].Name))));

            end
            else
              if not (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then
              begin

                if Param[ParamIndex].NumAllocElements shr 16 <> 0 then
                  NumAllocElements := (Param[ParamIndex].NumAllocElements and $FFFF) *
                    (Param[ParamIndex].NumAllocElements shr 16)
                else
                  NumAllocElements := Param[ParamIndex].NumAllocElements;

                asm65(':move');
                asm65(Param[ParamIndex].Name);
                asm65(IntToStr(Integer(NumAllocElements * DataSize[Param[ParamIndex].AllocElementType])));
              end;

        end
        else
        begin

          Assignment := True;

          if (Param[ParamIndex].PassMethod <> VARPASSING) and (Param[ParamIndex].DataType in
            [RECORDTOK, OBJECTTOK] + Pointers) and (Param[ParamIndex].NumAllocElements and $FFFF > 1) then
            // copy arrays

            if Param[ParamIndex].DataType in [RECORDTOK, OBJECTTOK] then
            begin

              Assignment := False;
              asm65(#9'dex');

            end
            else
              if not (Param[ParamIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then
              begin

                Assignment := False;
                asm65(#9'dex');

              end;

          if Assignment then
            if Param[ParamIndex].PassMethod = VARPASSING then
              GenerateAssignment(ASPOINTER, DataSize[POINTERTOK], 0, Param[ParamIndex].Name)
            else
            begin

              if Param[ParamIndex].DataType = ENUMTYPE then
                GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].AllocElementType], 0, Param[ParamIndex].Name)
              else
                GenerateAssignment(ASPOINTER, DataSize[Param[ParamIndex].DataType], 0, Param[ParamIndex].Name);

            end;
        end;

        if (Paramindex <> NumParams) then asm65(#9'jmi @main');

      end;

      asm65('@main');
    end;


    // Object variable definitions
    if IdentifierAt(BlockIdentIndex).ObjectIndex > 0 then
      for ParamIndex := 1 to Types[IdentifierAt(BlockIdentIndex).ObjectIndex].NumFields do
      begin

        tmpVarDataSize := GetVarDataSize;

{
  writeln(Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].Name,',',
          Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType,',',
          Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements,',',
          Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].AllocElementType);
}

        if Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType = OBJECTTOK then
          Error(i, '-- under construction --');

        if Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType = RECORDTOK then ConstVal := 0;

        if Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType in [POINTERTOK, STRINGPOINTERTOK] then

          DefineIdent(i, Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].Name,
            VARIABLE, Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType,
            Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements,
            Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].AllocElementType, 0)
        else

          DefineIdent(i, Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].Name,
            VARIABLE, POINTERTOK,
            Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].NumAllocElements,
            Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType, 0);

        Ident[NumIdent].PassMethod := VARPASSING;
        Ident[NumIdent].ObjectVariable := True;


        SetVarDataSize(i, tmpVarDataSize + DataSize[POINTERTOK]);

        if Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].ObjectVariable then
        begin
          Ident[NumIdent].Value := ConstVal + DATAORIGIN;

          Inc(ConstVal, DataSize[Types[IdentifierAt(BlockIdentIndex).ObjectIndex].Field[ParamIndex].DataType]);

          SetVarDataSize(i, tmpVarDataSize);
        end;

      end;


    asm65;

    if not isAsm then        // skaczemy do poczatku bloku procedury, wazne dla zagniezdzonych procedur / funkcji
      GenerateDeclarationProlog;


    while TokenAt(i).Kind in [CONSTTOK, TYPETOK, VARTOK, LABELTOK, PROCEDURETOK, FUNCTIONTOK,
        PROGRAMTOK, USESTOK, LIBRARYTOK, EXPORTSTOK, CONSTRUCTORTOK, DESTRUCTORTOK, LINKTOK,
        UNITBEGINTOK, UNITENDTOK, IMPLEMENTATIONTOK, INITIALIZATIONTOK, IOCHECKON, IOCHECKOFF,
        LOOPUNROLLTOK, NOLOOPUNROLLTOK, PROCALIGNTOK, LOOPALIGNTOK, LINKALIGNTOK, INFOTOK, WARNINGTOK, ERRORTOK] do
    begin

      if TokenAt(i).Kind = LINKTOK then
      begin

        if codealign.link > 0 then
        begin
          asm65(#9'.align $' + IntToHex(codealign.link, 4));
          asm65;
        end;

        asm65(#9'.link ''' + linkObj[TokenAt(i).Value] + '''');
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = LOOPUNROLLTOK then
      begin
        if Pass = CODEGENERATIONPASS then loopunroll := True;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = NOLOOPUNROLLTOK then
      begin
        if Pass = CODEGENERATIONPASS then loopunroll := False;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = PROCALIGNTOK then
      begin
        if Pass = CODEGENERATIONPASS then codealign.proc := TokenAt(i).Value;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = LOOPALIGNTOK then
      begin
        if Pass = CODEGENERATIONPASS then codealign.loop := TokenAt(i).Value;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = LINKALIGNTOK then
      begin
        if Pass = CODEGENERATIONPASS then codealign.link := TokenAt(i).Value;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = INFOTOK then
      begin
        if Pass = CODEGENERATIONPASS then writeln('User defined: ' + msgUser[TokenAt(i).Value]);
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = WARNINGTOK then
      begin
        Warning(i, UserDefined);
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = ERRORTOK then
      begin
        if Pass = CODEGENERATIONPASS then Error(i, UserDefined);
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = IOCHECKON then
      begin
        IOCheck := True;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = IOCHECKOFF then
      begin
        IOCheck := False;
        Inc(i, 2);
      end;


      if TokenAt(i).Kind = UNITBEGINTOK then
      begin
        asm65separator;

        DefineIdent(i, UnitName[TokenAt(i).UnitIndex].Name, UNITTYPE, 0, 0, 0, 0);
        Ident[NumIdent].UnitIndex := TokenAt(i).UnitIndex;

        //   writeln(UnitName[TokenAt(i).UnitIndex].Name,',',IdentifierAt(NumIdent].UnitIndex,',',TokenAt(i).UnitIndex);

        asm65;
        asm65('.local'#9 + UnitName[TokenAt(i).UnitIndex].Name, '; UNIT');

        UnitNameIndex := TokenAt(i).UnitIndex;

        CheckTok(i + 1, UNITTOK);
        CheckTok(i + 2, IDENTTOK);

        if TokenAt(i + 2).Name^ <> UnitName[TokenAt(i).UnitIndex].Name then
          Error(i + 2, 'Illegal unit name: ' + TokenAt(i + 2).Name^);

        CheckTok(i + 3, SEMICOLONTOK);

        while TokenAt(i + 4).Kind in [WARNINGTOK, ERRORTOK, INFOTOK] do Inc(i, 2);

        CheckTok(i + 4, INTERFACETOK);

        INTERFACETOK_USE := True;

        PublicSection := True;
        ImplementationUse := False;

        Inc(i, 5);
      end;


      if TokenAt(i).Kind = UNITENDTOK then
      begin

        if not ImplementationUse then
          CheckTok(i, IMPLEMENTATIONTOK);

        GenerateProcFuncAsmLabels(BlockIdentIndex);

        VarRegister := 0;

        asm65;
        asm65('.endl', '; UNIT ' + UnitName[TokenAt(i).UnitIndex].Name);

        j := NumIdent;

        while (j > 0) and (IdentifierAt(j).UnitIndex = UnitNameIndex) do
        begin
          // If procedure or function, delete parameters first
          if IdentifierAt(j).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
            if IdentifierAt(j).IsUnresolvedForward and (IdentifierAt(j).isExternal = False) then
              Error(i, 'Unresolved forward declaration of ' + IdentifierAt(j).Name);

          Dec(j);
        end;

        UnitNameIndex := 1;

        PublicSection := True;
        ImplementationUse := False;

        Inc(i);
      end;


      if TokenAt(i).Kind = IMPLEMENTATIONTOK then
      begin

        INTERFACETOK_USE := False;

        PublicSection := False;
        ImplementationUse := True;

        Inc(i);
      end;


      if TokenAt(i).Kind = EXPORTSTOK then
      begin

        Inc(i);

        repeat

          CheckTok(i, IDENTTOK);

          if Pass = CALLDETERMPASS then
          begin
            IdentIndex := GetIdent(TokenAt(i).Name^);

            if IdentIndex = 0 then
              Error(i, UnknownIdentifier);

            if IdentifierAt(IdentIndex).isInline then
              Error(i, 'INLINE is not allowed to exports');


            if IdentifierAt(IdentIndex).isOverload then
            begin

              for idx := 1 to NumIdent do
                if {(IdentifierAt(idx).ProcAsBlock = IdentifierAt(IdentIndex).ProcAsBlock) and} (IdentifierAt(idx).Name =
                  IdentifierAt(IdentIndex).Name) then
                  AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(idx).ProcAsBlock);

            end
            else
              AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(IdentIndex).ProcAsBlock);

          end;

          Inc(i);

          if not (TokenAt(i).Kind in [COMMATOK, SEMICOLONTOK]) then CheckTok(i, SEMICOLONTOK);

          if TokenAt(i).Kind = COMMATOK then Inc(i);

        until TokenAt(i).Kind = SEMICOLONTOK;

        Inc(i, 1);

      end;


      if (TokenAt(i).Kind = INITIALIZATIONTOK) or ((PublicSection = False) and (TokenAt(i).Kind = BEGINTOK)) then
      begin

        if not ImplementationUse then
          CheckTok(i, IMPLEMENTATIONTOK);

        asm65separator;
        asm65separator(False);

        asm65('@UnitInit');

        j := CompileStatement(i + 1);
        while TokenAt(j + 1).Kind = SEMICOLONTOK do j := CompileStatement(j + 2);

        asm65;
        asm65(#9'rts');

        i := j + 1;
      end;



      if TokenAt(i).Kind = LIBRARYTOK then
      begin       // na samym poczatku listingu

        if LIBRARYTOK_USE then CheckTok(i, BEGINTOK);

        CheckTok(i + 1, IDENTTOK);

        LIBRARY_NAME := TokenAt(i + 1).Name^;

        if (TokenAt(i + 2).Kind = COLONTOK) and (TokenAt(i + 3).Kind = INTNUMBERTOK) then
        begin

          CODEORIGIN_BASE := TokenAt(i + 3).Value;

          target.codeorigin := CODEORIGIN_BASE;

          Inc(i, 2);
        end;

        Inc(i);

        CheckTok(i + 1, SEMICOLONTOK);

        Inc(i, 2);

        LIBRARYTOK_USE := True;
      end;



      if TokenAt(i).Kind = PROGRAMTOK then
      begin       // na samym poczatku listingu

        if PROGRAMTOK_USE then CheckTok(i, BEGINTOK);

        CheckTok(i + 1, IDENTTOK);

        PROGRAM_NAME := TokenAt(i + 1).Name^;

        Inc(i);


        if TokenAt(i + 1).Kind = OPARTOK then
        begin

          Inc(i);

          repeat
            Inc(i);
            CheckTok(i, IDENTTOK);

            if TokenAt(i + 1).Kind = COMMATOK then Inc(i);

          until TokenAt(i + 1).Kind <> IDENTTOK;

          CheckTok(i + 1, CPARTOK);

          Inc(i);
        end;


        if (TokenAt(i + 1).Kind = COLONTOK) and (TokenAt(i + 2).Kind = INTNUMBERTOK) then
        begin

          CODEORIGIN_BASE := TokenAt(i + 2).Value;

          target.codeorigin := CODEORIGIN_BASE;

          Inc(i, 2);
        end;


        CheckTok(i + 1, SEMICOLONTOK);

        Inc(i, 2);

        PROGRAMTOK_USE := True;
      end;


      if TokenAt(i).Kind = USESTOK then
      begin    // co najwyzej po PROGRAM

        if LIBRARYTOK_USE then
        begin

          j := i - 1;

          while TokenAt(j).Kind in [SEMICOLONTOK, IDENTTOK, COLONTOK, INTNUMBERTOK] do Dec(j);

          if TokenAt(j).Kind <> LIBRARYTOK then
            CheckTok(i, BEGINTOK);

        end;

        if PROGRAMTOK_USE then
        begin

          j := i - 1;

          while TokenAt(j).Kind in [SEMICOLONTOK, CPARTOK, OPARTOK, IDENTTOK, COMMATOK, COLONTOK, INTNUMBERTOK] do Dec(j);

          if TokenAt(j).Kind <> PROGRAMTOK then
            CheckTok(i, BEGINTOK);

        end;

        if INTERFACETOK_USE then
          if TokenAt(i - 1).Kind <> INTERFACETOK then
            CheckTok(i, IMPLEMENTATIONTOK);

        if ImplementationUse then
          if TokenAt(i - 1).Kind <> IMPLEMENTATIONTOK then
            CheckTok(i, BEGINTOK);

        Inc(i);

        idx := i;

        SetLength(UnitList, 1);    // wstepny odczyt USES, sprawdzamy czy nie powtarzaja sie wpisy

        repeat

          CheckTok(i, IDENTTOK);

          for j := 0 to High(UnitList) - 1 do
            if UnitList[j] = TokenAt(i).Name^ then
              Error(i, 'Duplicate identifier ''' + TokenAt(i).Name^ + '''');

          j := High(UnitList);
          UnitList[j] := TokenAt(i).Name^;
          SetLength(UnitList, j + 2);

          Inc(i);

          if TokenAt(i).Kind = INTOK then
          begin
            CheckTok(i + 1, STRINGLITERALTOK);

            Inc(i, 2);
          end;

          if not (TokenAt(i).Kind in [COMMATOK, SEMICOLONTOK]) then CheckTok(i, SEMICOLONTOK);

          if TokenAt(i).Kind = COMMATOK then Inc(i);

        until TokenAt(i).Kind <> IDENTTOK;

        CheckTok(i, SEMICOLONTOK);


        i := idx;

        SetLength(UnitList, 0);    //  wlasciwy odczyt USES

        repeat

          CheckTok(i, IDENTTOK);

          yes := True;
          for j := 1 to UnitName[UnitNameIndex].Units do
            if (UnitName[UnitNameIndex].Allow[j] = TokenAt(i).Name^) or (TokenAt(i).Name^ = 'SYSTEM') then yes := False;

          if yes then
          begin

            Inc(UnitName[UnitNameIndex].Units);

            if UnitName[UnitNameIndex].Units > MAXALLOWEDUNITS then
              Error(i, 'Out of resources, MAXALLOWEDUNITS');

            UnitName[UnitNameIndex].Allow[UnitName[UnitNameIndex].Units] := TokenAt(i).Name^;

          end;

          Inc(i);

          if TokenAt(i).Kind = INTOK then
          begin
            CheckTok(i + 1, STRINGLITERALTOK);

            Inc(i, 2);
          end;

          if not (TokenAt(i).Kind in [COMMATOK, SEMICOLONTOK]) then CheckTok(i, SEMICOLONTOK);

          if TokenAt(i).Kind = COMMATOK then Inc(i);

        until TokenAt(i).Kind <> IDENTTOK;

        CheckTok(i, SEMICOLONTOK);

        Inc(i);

      end;

      // -----------------------------------------------------------------------------
      //           LABEL
      // -----------------------------------------------------------------------------

      if TokenAt(i).Kind = LABELTOK then
      begin

        Inc(i);

        repeat

          CheckTok(i, IDENTTOK);

          DefineIdent(i, TokenAt(i).Name^, LABELTYPE, 0, 0, 0, 0);

          Inc(i);

          if TokenAt(i).Kind = COMMATOK then Inc(i);

        until TokenAt(i).Kind <> IDENTTOK;

        i := i + 1;
      end;  // if LABELTOK

      // -----------------------------------------------------------------------------
      //           CONST
      // -----------------------------------------------------------------------------

      if TokenAt(i).Kind = CONSTTOK then
      begin
        repeat

          if TokenAt(i + 1).Kind <> IDENTTOK then
            Error(i + 1, 'Constant name expected but ' + GetSpelling(i + 1) + ' found')
          else
            if TokenAt(i + 2).Kind = EQTOK then
            begin

              j := CompileConstExpression(i + 3, ConstVal, ConstValType, INTEGERTOK, False, False);

              if TokenAt(j).Kind in StringTypes then
              begin

                if TokenAt(j).StrLength > 255 then
                  DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, POINTERTOK, 0, CHARTOK,
                    ConstVal + CODEORIGIN, PCHARTOK)
                else
                  DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, ConstValType, TokenAt(j).StrLength, CHARTOK,
                    ConstVal + CODEORIGIN, TokenAt(j).Kind);

              end
              else
                if (ConstValType in Pointers) then
                  Error(j, IllegalExpression)
                else
                  DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, ConstValType, 0, 0, ConstVal, TokenAt(j).Kind);

              i := j;
            end
            else
              if TokenAt(i + 2).Kind = COLONTOK then
              begin

                open_array := False;


                if (TokenAt(i + 3).Kind = ARRAYTOK) and (TokenAt(i + 4).Kind = OFTOK) then
                begin

                  j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

                  if VarType in [RECORDTOK, OBJECTTOK] then
                    Error(i, 'Only Array of ^' + InfoAboutToken(VarType) + ' supported')
                  else
                    if VarType = ENUMTYPE then
                      Error(i, InfoAboutToken(VarType) + ' arrays are not supported');

                  if VarType = POINTERTOK then
                  begin

                    if AllocElementType = UNTYPETOK then
                    begin
                      NumAllocElements := 1;
                      AllocElementType := VarType;
                    end;

                  end
                  else
                  begin
                    NumAllocElements := 1;
                    AllocElementType := VarType;
                    VarType := POINTERTOK;
                  end;

                  if not (AllocElementType in [RECORDTOK, OBJECTTOK]) then open_array := True;

                end
                else
                begin

                  j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

                  if TokenAt(i + 3).Kind = ARRAYTOK then j :=
                      CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

                end;


                if (VarType in Pointers) and (NumAllocElements = 0) then
                  if AllocElementType <> CHARTOK then Error(j, IllegalExpression);


                CheckTok(j + 1, EQTOK);

                if TokenAt(i + 3).Kind in StringTypes then
                begin

                  j := CompileConstExpression(j + 2, ConstVal, ConstValType);

                  if TokenAt(i + 3).Kind = PCHARTOK then
                    DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, POINTERTOK, 0, CHARTOK,
                      ConstVal + CODEORIGIN + 1, PCHARTOK)
                  else
                    DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, ConstValType, TokenAt(j).StrLength, CHARTOK,
                      ConstVal + CODEORIGIN, TokenAt(j).Kind);

                end
                else

                  if NumAllocElements > 0 then
                  begin

                    DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, VarType, NumAllocElements,
                      AllocElementType, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE, IDENTTOK);

                    if (IdentifierAt(NumIdent).NumAllocElements in [0, 1]) and (open_array = False) then
                      Error(i, IllegalExpression)
                    else
                      if open_array then
                      begin                  // const array of type = [ ]

                        if (TokenAt(j + 2).Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then
                        begin  // = 'string'

                          Ident[NumIdent].Value := TokenAt(j + 2).StrAddress + CODEORIGIN_BASE;
                          if VarType <> STRINGPOINTERTOK then Inc(Ident[NumIdent].Value);

                          Ident[NumIdent].NumAllocElements := TokenAt(j + 2).StrLength;

                          j := j + 2;

                          NumAllocElements := 0;

                        end
                        else
                        begin
                          j := ReadDataOpenArray(j + 2, NumStaticStrChars, AllocElementType,
                            NumAllocElements, True, TokenAt(j).Kind = PCHARTOK);

                          Ident[NumIdent].NumAllocElements := NumAllocElements;
                        end;

                      end
                      else
                      begin                    // const array [] of type = ( )

                        if (TokenAt(j + 2).Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then
                        begin  // = 'string'

                          if TokenAt(j + 2).StrLength > NumAllocElements then
                            Error(j + 2, 'String length is larger than array of char length');

                          Ident[NumIdent].Value := TokenAt(j + 2).StrAddress + CODEORIGIN_BASE;
                          if VarType <> STRINGPOINTERTOK then Inc(Ident[NumIdent].Value);

                          Ident[NumIdent].NumAllocElements := TokenAt(j + 2).StrLength;

                          j := j + 2;

                          NumAllocElements := 0;

                        end
                        else
                          j := ReadDataArray(j + 2, NumStaticStrChars, AllocElementType,
                            NumAllocElements, True, TokenAt(j).Kind = PCHARTOK);

                      end;


                    if NumAllocElements shr 16 > 0 then
                      Inc(NumStaticStrChars, ((NumAllocElements and $ffff) * (NumAllocElements shr 16)) *
                        DataSize[AllocElementType])
                    else
                      Inc(NumStaticStrChars, NumAllocElements * DataSize[AllocElementType]);

                  end
                  else
                  begin
                    j := CompileConstExpression(j + 2, ConstVal, ConstValType, VarType, False);


                    if (VarType in [SINGLETOK, HALFSINGLETOK]) and (ConstValType in [SHORTREALTOK, REALTOK]) then
                      ConstValType := VarType;
                    if (VarType = SHORTREALTOK) and (ConstValType = REALTOK) then ConstValType := SHORTREALTOK;


                    if (VarType in RealTypes) and (ConstValType in IntegerTypes) then
                    begin
                      Int2Float(ConstVal);
                      ConstValType := VarType;
                    end;

                    GetCommonType(i + 1, VarType, ConstValType);

                    DefineIdent(i + 1, TokenAt(i + 1).Name^, CONSTANT, VarType, 0, 0, ConstVal, TokenAt(j).Kind);
                  end;

                i := j;
              end
              else
                CheckTok(i + 2, EQTOK);

          CheckTok(i + 1, SEMICOLONTOK);

          Inc(i);
        until TokenAt(i + 1).Kind <> IDENTTOK;

        Inc(i);
      end;  // if CONSTTOK

      // -----------------------------------------------------------------------------
      //        TYPE
      // -----------------------------------------------------------------------------

      if TokenAt(i).Kind = TYPETOK then
      begin
        repeat
          if TokenAt(i + 1).Kind <> IDENTTOK then
            Error(i + 1, 'Type name expected but ' + GetSpelling(i + 1) + ' found')
          else
          begin

            CheckTok(i + 2, EQTOK);

            if (TokenAt(i + 3).Kind = ARRAYTOK) and (TokenAt(i + 4).Kind <> OBRACKETTOK) then
            begin
              j := CompileType(i + 5, VarType, NumAllocElements, AllocElementType);

              DefineIdent(i + 1, TokenAt(i + 1).Name^, USERTYPE, VarType, NumAllocElements,
                AllocElementType, 0, TokenAt(i + 3).Kind);
              Ident[NumIdent].Pass := CALLDETERMPASS;

            end
            else
            begin
              j := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

              if TokenAt(i + 3).Kind = ARRAYTOK then j :=
                  CompileType(j + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

              DefineIdent(i + 1, TokenAt(i + 1).Name^, USERTYPE, VarType, NumAllocElements,
                AllocElementType, 0, TokenAt(i + 3).Kind);
              Ident[NumIdent].Pass := CALLDETERMPASS;

            end;

          end;

          CheckTok(j + 1, SEMICOLONTOK);

          i := j + 1;
        until TokenAt(i + 1).Kind <> IDENTTOK;

        CheckForwardResolutions;

        i := i + 1;
      end;  // if TYPETOK
      // -----------------------------------------------------------------------------
      //          VAR
      // -----------------------------------------------------------------------------

      if TokenAt(i).Kind = VARTOK then
      begin

        isVolatile := False;
        isStriped := False;

        NestedDataType := 0;
        NestedAllocElementType := 0;
        NestedNumAllocElements := 0;

        if (TokenAt(i + 1).Kind = OBRACKETTOK) and (TokenAt(i + 2).Kind in [VOLATILETOK, STRIPEDTOK]) then
        begin
          CheckTok(i + 3, CBRACKETTOK);

          if TokenAt(i + 2).Kind = VOLATILETOK then
            isVolatile := True
          else
            isStriped := True;

          Inc(i, 3);
        end;

        repeat
          NumVarOfSameType := 0;
          repeat
            if TokenAt(i + 1).Kind <> IDENTTOK then
              Error(i + 1, 'Variable name expected but ' + GetSpelling(i + 1) + ' found')
            else
            begin
              Inc(NumVarOfSameType);

              if NumVarOfSameType > High(VarOfSameType) then
                Error(i, 'Too many formal parameters');

              VarOfSameType[NumVarOfSameType].Name := TokenAt(i + 1).Name^;
            end;
            i := i + 2;
          until TokenAt(i).Kind <> COMMATOK;

          CheckTok(i, COLONTOK);

          // pack:=false;


          if TokenAt(i + 1).Kind = PACKEDTOK then
          begin

            if (TokenAt(i + 2).Kind in [ARRAYTOK, RECORDTOK]) then
            begin
              Inc(i);
              // pack := true;
            end
            else
              CheckTok(i + 2, RECORDTOK);

          end;


          IdType := TokenAt(i + 1).Kind;

          idx := i + 1;


          open_array := False;

          isAbsolute := False;
          isExternal := False;


          if (IdType = ARRAYTOK) and (TokenAt(i + 2).Kind = OFTOK) then
          begin      // array of type [Ordinal Types]

            i := CompileType(i + 3, VarType, NumAllocElements, AllocElementType);

            if VarType in [RECORDTOK, OBJECTTOK] then
              Error(i, 'Only Array of ^' + InfoAboutToken(VarType) + ' supported')
            else
              if VarType = ENUMTYPE then
                Error(i, InfoAboutToken(VarType) + ' arrays are not supported');

            if VarType = POINTERTOK then
            begin

              if AllocElementType = UNTYPETOK then
              begin
                NumAllocElements := 1;
                AllocElementType := VarType;
              end;

            end
            else
            begin
              NumAllocElements := 1;
              AllocElementType := VarType;
              VarType := POINTERTOK;
            end;

            //if TokenAt(i + 1).Kind <> EQTOK then isAbsolute := true;        // !!!!

            ConstVal := 1;

            if not (AllocElementType in [RECORDTOK, OBJECTTOK]) then open_array := True;

          end
          else
          begin

            i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

            if IdType = ARRAYTOK then i :=
                CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);

            if (NumAllocElements = 1) or (NumAllocElements = $10001) then ConstVal := 1;

          end;


          if TokenAt(i + 1).Kind = REGISTERTOK then
          begin

            if NumVarOfSameType > 1 then
              Error(i + 1, 'REGISTER can only be associated to one variable');

            isAbsolute := True;

            Inc(VarRegister, DataSize[VarType]);

            ConstVal := (VarRegister + 3) shl 24 + 1;

            Inc(i);

          end
          else

            if TokenAt(i + 1).Kind = EXTERNALTOK then
            begin

              if NumVarOfSameType > 1 then
                Error(i + 1, 'Only one variable can be initialized');

              isAbsolute := True;
              isExternal := True;

              Inc(i);

              external_libr := 0;

              if TokenAt(i + 1).Kind = IDENTTOK then
              begin

                external_name := TokenAt(i + 1).Name^;

                if TokenAt(i + 2).Kind = STRINGLITERALTOK then
                begin
                  external_libr := i + 2;

                  Inc(i);
                end;

                Inc(i);
              end
              else
                if TokenAt(i + 1).Kind = STRINGLITERALTOK then
                begin

                  external_name := VarOfSameType[1].Name;
                  external_libr := i + 1;

                  Inc(i);
                end;


              ConstVal := 1;

            end
            else

              if TokenAt(i + 1).Kind = ABSOLUTETOK then
              begin

                isAbsolute := True;

                if NumVarOfSameType > 1 then
                  Error(i + 1, 'ABSOLUTE can only be associated to one variable');


                if (VarType in [RECORDTOK, OBJECTTOK] {+ Pointers}) and (NumAllocElements = 0) then
                  // brak mozliwosci identyfikacji dla takiego przypadku
                  Error(i + 1, 'not possible in this case');

                Inc(i);

                varPassMethod := UNDEFINED;

                if (TokenAt(i + 1).Kind = IDENTTOK) and (IdentifierAt(GetIdent(TokenAt(i + 1).Name^)).Kind = VARTOK) then
                begin
                  ConstVal := IdentifierAt(GetIdent(TokenAt(i + 1).Name^)).Value - DATAORIGIN;

                  varPassMethod := IdentifierAt(GetIdent(TokenAt(i + 1).Name^)).PassMethod;

                  if (ConstVal < 0) or (ConstVal > $FFFFFF) then
                    Error(i, 'Range check error while evaluating constants (' + IntToStr(ConstVal) +
                      ' must be between 0 and ' + IntToStr($FFFFFF) + ')');


                  ConstVal := -ConstVal;

                  Inc(i);
                end
                else
                begin
                  i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

                  if VarType in Pointers then
                    GetCommonConstType(i, WORDTOK, ActualParamType)
                  else
                    GetCommonConstType(i, CARDINALTOK, ActualParamType);

                  if (ConstVal < 0) or (ConstVal > $FFFFFF) then
                    Error(i, 'Range check error while evaluating constants (' + IntToStr(ConstVal) +
                      ' must be between 0 and ' + IntToStr($FFFFFF) + ')');
                end;

                Inc(ConstVal);   // wyjatkowo, aby mozna bylo ustawic adres $0000, DefineIdent zmniejszy wartosc -1

              end;



          if IdType = IDENTTOK then IdType := IdentifierAt(GetIdent(TokenAt(idx).Name^)).IdType;



          tmpVarDataSize := GetVarDataSize;    // dla ABSOLUTE, RECORD


          for VarOfSameTypeIndex := 1 to NumVarOfSameType do
          begin

            //  writeln(VarType,',',NumAllocElements and $FFFF,',',NumAllocElements shr 16,',',AllocElementType, ',',idType,',',varPassMethod,',',isAbsolute);


            if VarType = DEREFERENCEARRAYTOK then
            begin

              VarType := POINTERTOK;

              NestedNumAllocElements := NumAllocElements;

              IdType := DEREFERENCEARRAYTOK;

              NumAllocElements := 1;

            end;


            if VarType = ENUMTYPE then
            begin

              DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, AllocElementType, 0, 0, 0, IdType);

              Ident[NumIdent].DataType := ENUMTYPE;
              Ident[NumIdent].AllocElementType := AllocElementType;
              Ident[NumIdent].NumAllocElements := NumAllocElements;

            end
            else
            begin
              DefineIdent(i, VarOfSameType[VarOfSameTypeIndex].Name, VARIABLE, VarType, NumAllocElements,
                AllocElementType, Ord(isAbsolute) * ConstVal, IdType);

              //    writeln('? ',VarOfSameType[VarOfSameTypeIndex].Name,',', NestedDataType,',',NestedAllocElementType,',',NestedNumAllocElements,'|',IdType);

              Ident[NumIdent].NestedDataType := NestedDataType;
              Ident[NumIdent].NestedAllocElementType := NestedAllocElementType;
              Ident[NumIdent].NestedNumAllocElements := NestedNumAllocElements;
              Ident[NumIdent].isVolatile := isVolatile;

              if varPassMethod <> UNDEFINED then Ident[NumIdent].PassMethod := varPassMethod;


              if isStriped and (IdentifierAt(NumIdent).PassMethod <> VARPASSING) then
              begin

                if NumAllocElements shr 16 > 0 then
                  yes := (NumAllocElements and $FFFF) * (NumAllocElements shr 16) <= 256
                else
                  yes := NumAllocElements <= 256;

                if yes then
                  Ident[NumIdent].isStriped := True
                else
                  warning(i, StripedAllowed);

              end;


              varPassMethod := UNDEFINED;


              //    writeln(VarType, ' / ', AllocElementType ,' = ',NestedDataType, ',',NestedAllocElementType,',', hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));


              if (VarType = POINTERTOK) and (AllocElementType = STRINGPOINTERTOK) and
                (NestedNumAllocElements > 0) and (NumAllocElements > 1) then
              begin  // array [ ][ ] of string;


                if IdentifierAt(NumIdent).isAbsolute then
                  Error(i, 'ABSOLUTE modifier is not available for this type of array');

                idx := IdentifierAt(NumIdent).Value - DATAORIGIN;

                if NumAllocElements shr 16 > 0 then
                begin

                  for j := 0 to (NumAllocElements and $FFFF) * (NumAllocElements shr 16) - 1 do
                  begin
                    SaveToDataSegment(idx, GetVarDataSize, DATAORIGINOFFSET);

                    Inc(idx, 2);
                    incVarDataSize(i, NestedNumAllocElements);
                  end;

                end
                else
                begin

                  for j := 0 to NumAllocElements - 1 do
                  begin
                    SaveToDataSegment(idx, GetVarDataSize, DATAORIGINOFFSET);

                    Inc(idx, 2);
                    incVarDataSize(i, NestedNumAllocElements);
                  end;

                end;

              end;

            end;


            CompileRecordDeclaration(i, VarOfSameType, tmpVarDataSize, ConstVal, VarOfSameTypeIndex,
              VarType, AllocElementType, NumAllocElements, isAbsolute, idx);  // !!! idx !!!

          end;


          if isExternal then
          begin

            Ident[NumIdent].isExternal := True;

            Ident[NumIdent].Alias := external_name;
            Ident[NumIdent].Libraries := external_libr;

          end;


          if isAbsolute and (open_array = False) then

            SetVarDataSize(i, tmpVarDataSize)

          else

            if TokenAt(i + 1).Kind = EQTOK then
            begin

              if IdentifierAt(NumIdent).isStriped then
                Error(i + 1, 'Initialization for striped array not allowed');


              if VarType in [RECORDTOK, OBJECTTOK] then
                Error(i + 1, 'Initialization for ' + InfoAboutToken(VarType) + ' not allowed');

              if NumVarOfSameType > 1 then
                Error(i + 1, 'Only one variable can be initialized');

              Inc(i);


              if (VarType = POINTERTOK) and (AllocElementType in [RECORDTOK, OBJECTTOK]) then

              else
                idx := IdentifierAt(NumIdent).Value - DATAORIGIN;


              if not (VarType in Pointers) then
              begin

                Ident[NumIdent].isInitialized := True;

                i := CompileConstExpression(i + 1, ConstVal, ActualParamType);

                if (VarType in RealTypes) and (ActualParamType = REALTOK) then ActualParamType := VarType;

                GetCommonConstType(i, VarType, ActualParamType);

                SaveToDataSegment(idx, ConstVal, VarType);

              end
              else
              begin

                Ident[NumIdent].isInit := True;

                //   if IdentifierAt(NumIdent].NumAllocElements = 0 then
                //    Error(i + 1, 'Illegal expression');

                Inc(i);


                if TokenAt(i).Kind = ADDRESSTOK then
                begin

                  if TokenAt(i + 1).Kind <> IDENTTOK then
                    Error(i + 1, IdentifierExpected)
                  else
                  begin
                    IdentIndex := GetIdent(TokenAt(i + 1).Name^);

                    if IdentIndex > 0 then
                    begin

                      if (IdentifierAt(IdentIndex).Kind = CONSTANT) then
                      begin

                        if not ((IdentifierAt(IdentIndex).DataType in Pointers) and
                          (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
                          Error(i + 1, CantAdrConstantExp)
                        else
                          SaveToDataSegment(idx, IdentifierAt(IdentIndex).Value - CODEORIGIN -
                            CODEORIGIN_BASE, CODEORIGINOFFSET);

                      end
                      else
                        SaveToDataSegment(idx, IdentifierAt(IdentIndex).Value - DATAORIGIN, DATAORIGINOFFSET);

                      VarType := POINTERTOK;

                    end
                    else
                      Error(i + 1, UnknownIdentifier);

                  end;

                  Inc(i);

                end
                else
                  if TokenAt(i).Kind = CHARLITERALTOK then
                  begin

                    SaveToDataSegment(idx, 1, BYTETOK);
                    SaveToDataSegment(idx + 1, TokenAt(i).Value, BYTETOK);

                    VarType := POINTERTOK;

                  end
                  else
                    if (TokenAt(i).Kind = STRINGLITERALTOK) and (open_array = False) and
                      (VarType = POINTERTOK) and (AllocElementType = CHARTOK) then

                      SaveToDataSegment(idx, TokenAt(i).StrAddress - CODEORIGIN + 1, CODEORIGINOFFSET)

                    else

{
    if (TokenAt(i).Kind = STRINGLITERALTOK) and (open_array = false) then begin

     if (IdentifierAt(NumIdent].NumAllocElements > 0 ) and (TokenAt(i).StrLength > IdentifierAt(NumIdent].NumAllocElements) then begin
      Warning(i, StringTruncated, NumIdent);

      ParamIndex := IdentifierAt(NumIdent].NumAllocElements;
     end else
      ParamIndex := TokenAt(i).StrLength + 1;

     VarType := STRINGPOINTERTOK;


     if (IdentifierAt(NumIdent].NumAllocElements = 0) then           // var label: pchar = ''
      SaveToDataSegment(idx, TokenAt(i).StrAddress - CODEORIGIN + 1, CODEORIGINOFFSET)
     else begin

       if (IdType = ARRAYTOK) and (AllocElementType = CHARTOK) then begin      // var label: array of char = ''

        if TokenAt(i).StrLength > NumAllocElements then
               Error(i, 'string length is larger than array of char length');

         for j := 0 to IdentifierAt(NumIdent].NumAllocElements-1 do
         if j > TokenAt(i).StrLength-1 then
            SaveToDataSegment(idx + j, ord(' '), CHARTOK)
         else
            SaveToDataSegment(idx + j, ord( StaticStringData[ TokenAt(i).StrAddress - CODEORIGIN + j + 1] ), CHARTOK);

       end else
         for j := 0 to ParamIndex-1 do              // var label: string = ''
           SaveToDataSegment(idx + j, ord( StaticStringData[ TokenAt(i).StrAddress - CODEORIGIN + j ] ), BYTETOK);

     end;

    end else
}

                      if (IdentifierAt(NumIdent).NumAllocElements in [0, 1]) and (open_array = False) then
                        Error(i, IllegalExpression)
                      else
                        if open_array then
                        begin                   // array of type = [ ]

                          if (TokenAt(i).Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then
                          begin    // = 'string'

                            Ident[NumIdent].Value := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
                            if VarType <> STRINGPOINTERTOK then Inc(Ident[NumIdent].Value);

                            Ident[NumIdent].NumAllocElements := TokenAt(i).StrLength;

                            Ident[NumIdent].isAbsolute := True;

                            NumAllocElements := 0;

                          end
                          else
                          begin
                            i := ReadDataOpenArray(i, idx, IdentifierAt(NumIdent).AllocElementType,
                              NumAllocElements, False, TokenAt(i - 2).Kind = PCHARTOK);

                            Ident[NumIdent].NumAllocElements := NumAllocElements;
                          end;

                          incVarDataSize(i, NumAllocElements * DataSize[IdentifierAt(NumIdent).AllocElementType]);

                        end
                        else
                        begin                    // array [] of type = ( )

                          if (TokenAt(i).Kind = STRINGLITERALTOK) and (AllocElementType = CHARTOK) then
                          begin    // = 'string'

                            if TokenAt(i).StrLength > NumAllocElements then
                              Error(i, 'string length is larger than array of char length');

                            Ident[NumIdent].Value := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
                            if VarType <> STRINGPOINTERTOK then Inc(Ident[NumIdent].Value);

                            Ident[NumIdent].NumAllocElements := TokenAt(i).StrLength;

                            Ident[NumIdent].isAbsolute := True;

                            // NumAllocElements := 1;

                          end
                          else
                            i := ReadDataArray(i, idx, IdentifierAt(NumIdent).AllocElementType,
                              IdentifierAt(NumIdent).NumAllocElements or IdentifierAt(NumIdent).NumAllocElements_ shl
                              16, False, TokenAt(i - 2).Kind = PCHARTOK);

                        end;

              end;

            end;

          CheckTok(i + 1, SEMICOLONTOK);

          isVolatile := False;
          isStriped := False;

          if (TokenAt(i + 2).Kind = OBRACKETTOK) and (TokenAt(i + 3).Kind in [VOLATILETOK, STRIPEDTOK]) then
          begin
            CheckTok(i + 4, CBRACKETTOK);

            if TokenAt(i + 3).Kind = VOLATILETOK then
              isVolatile := True
            else
              isStriped := True;

            Inc(i, 3);
          end;


          i := i + 1;
        until TokenAt(i + 1).Kind <> IDENTTOK;

        CheckForwardResolutions(False);                // issue #126 fixed

        i := i + 1;
      end;// if VARTOK


      if TokenAt(i).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
        if TokenAt(i + 1).Kind <> IDENTTOK then
          Error(i + 1, 'Procedure name expected but ' + GetSpelling(i + 1) + ' found')
        else
        begin

          IsNestedFunction := (TokenAt(i).Kind = FUNCTIONTOK);


          if INTERFACETOK_USE then
            ForwardIdentIndex := 0
          else
            ForwardIdentIndex := GetIdent(TokenAt(i + 1).Name^);


          if (ForwardIdentIndex <> 0) and (IdentifierAt(ForwardIdentIndex).isOverload) then
          begin       // !!! dla forward; overload;

            j := i;
            FormalParameterList(j, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType,
              NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

            ForwardIdentIndex := GetIdentProc(IdentifierAt(ForwardIdentIndex).Name, ForwardIdentIndex, Param, ParamIndex);

          end;


          if ForwardIdentIndex <> 0 then
            if (IdentifierAt(ForwardIdentIndex).IsUnresolvedForward) and (IdentifierAt(ForwardIdentIndex).Block =
              BlockStack[BlockStackTop]) then
              if TokenAt(i).Kind <> IdentifierAt(ForwardIdentIndex).Kind then
                Error(i, 'Unresolved forward declaration of ' + IdentifierAt(ForwardIdentIndex).Name);


          if ForwardIdentIndex <> 0 then
            if not IdentifierAt(ForwardIdentIndex).IsUnresolvedForward or (IdentifierAt(ForwardIdentIndex).Block <>
              BlockStack[BlockStackTop]) or ((TokenAt(i).Kind = PROCEDURETOK) and
              (IdentifierAt(ForwardIdentIndex).Kind <> PROCEDURETOK)) or
              //   ((TokenAt(i).Kind = CONSTRUCTORTOK) and (IdentifierAt(ForwardIdentIndex].Kind <> CONSTRUCTORTOK)) or
              //   ((TokenAt(i).Kind = DESTRUCTORTOK) and (IdentifierAt(ForwardIdentIndex].Kind <> DESTRUCTORTOK)) or
              ((TokenAt(i).Kind = FUNCTIONTOK) and (IdentifierAt(ForwardIdentIndex).Kind <> FUNCTIONTOK)) then
              ForwardIdentIndex := 0;     // Found an identifier of another kind or scope, or it is already resolved


          if (TokenAt(i).Kind in [CONSTRUCTORTOK, DESTRUCTORTOK]) and (ForwardIdentIndex = 0) then
            Error(i, 'constructors, destructors operators must be methods');


          //    writeln(ForwardIdentIndex,',',TokenAt(i).line,',',IdentifierAt(ForwardIdentIndex).isOverload,',',IdentifierAt(ForwardIdentIndex).IsUnresolvedForward,' / ',TokenAt(i).Kind = PROCEDURETOK,',',  ((TokenAt(i).Kind = PROCEDURETOK) and (IdentifierAt(ForwardIdentIndex).Kind <> PROC)));

          i := DefineFunction(i, ForwardIdentIndex, isForward, isInt, isInl, isOvr, IsNestedFunction,
            NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);


          // Check for a FORWARD directive (it is not a reserved word)
          if ((ForwardIdentIndex = 0) and isForward) or INTERFACETOK_USE then  // Forward declaration
          begin
            //      Inc(NumBlocks);
            //      IdentifierAt(NumIdent].ProcAsBlock := NumBlocks;
            Ident[NumIdent].IsUnresolvedForward := True;

          end
          else
          begin

            if ForwardIdentIndex = 0 then              // New declaration
            begin

              TestIdentProc(i, IdentifierAt(NumIdent).Name);

              if ((Pass = CODEGENERATIONPASS) and (not IdentifierAt(NumIdent).IsNotDead)) then
                // Do not compile dead procedures and functions
              begin
                OutputDisabled := True;
              end;

              iocheck_old := IOCheck;
              isInterrupt_old := isInterrupt;

              j := CompileBlock(i + 1, NumIdent, IdentifierAt(NumIdent).NumParams, IsNestedFunction,
                NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

              IOCheck := iocheck_old;
              isInterrupt := isInterrupt_old;

              i := j + 1;

              GenerateReturn(IsNestedFunction, isInt, isInl, isOvr);

              if OutputDisabled then OutputDisabled := False;

            end
            else                      // Forward declaration resolution
            begin
              //  GenerateForwardResolution(ForwardIdentIndex);
              //  CompileBlock(ForwardIdentIndex);

              if ((Pass = CODEGENERATIONPASS) and (not IdentifierAt(ForwardIdentIndex).IsNotDead)) then
                // Do not compile dead procedures and functions
              begin
                OutputDisabled := True;
              end;

              Ident[ForwardIdentIndex].Value := CodeSize;

              FormalParameterList(i, ParamIndex, Param, TmpResult, IsNestedFunction, NestedFunctionResultType,
                NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

              Dec(i, 2);

              if ParamIndex > 0 then
              begin

                if IdentifierAt(ForwardIdentIndex).NumParams <> ParamIndex then
                  Error(i, 'Wrong number of parameters specified for call to ' + '''' +
                    IdentifierAt(ForwardIdentIndex).Name + '''');

                //     function header "arg1" doesn't match forward : var name changes arg2 = arg3

                for ParamIndex := 1 to IdentifierAt(ForwardIdentIndex).NumParams do
                  if ((IdentifierAt(ForwardIdentIndex).Param[ParamIndex].Name <> Param[ParamIndex].Name) or
                    (IdentifierAt(ForwardIdentIndex).Param[ParamIndex].DataType <> Param[ParamIndex].DataType)) then
                    Error(i, 'Function header ''' + IdentifierAt(ForwardIdentIndex).Name +
                      ''' doesn''t match forward : ' + IdentifierAt(ForwardIdentIndex).Param[ParamIndex].Name +
                      ' <> ' + Param[ParamIndex].Name);

                for ParamIndex := 1 to IdentifierAt(ForwardIdentIndex).NumParams do
                  if (IdentifierAt(ForwardIdentIndex).Param[ParamIndex].PassMethod <> Param[ParamIndex].PassMethod) then
                    Error(i, 'Function header doesn''t match the previous declaration ''' +
                      IdentifierAt(ForwardIdentIndex).Name + '''');

              end;

              Tmp := 0;

              if IdentifierAt(ForwardIdentIndex).isKeep then Tmp := Tmp or Ord(mKeep);
              if IdentifierAt(ForwardIdentIndex).isOverload then Tmp := Tmp or Ord(mOverload);
              if IdentifierAt(ForwardIdentIndex).isAsm then Tmp := Tmp or Ord(mAssembler);
              if IdentifierAt(ForwardIdentIndex).isRegister then Tmp := Tmp or Ord(mRegister);
              if IdentifierAt(ForwardIdentIndex).isInterrupt then Tmp := Tmp or Ord(mInterrupt);
              if IdentifierAt(ForwardIdentIndex).isPascal then Tmp := Tmp or Ord(mPascal);
              if IdentifierAt(ForwardIdentIndex).isStdCall then Tmp := Tmp or Ord(mStdCall);
              if IdentifierAt(ForwardIdentIndex).isInline then Tmp := Tmp or Ord(mInline);

              if Tmp <> TmpResult then
                Error(i, 'Function header doesn''t match the previous declaration ''' +
                  IdentifierAt(ForwardIdentIndex).Name + '''');


              if IsNestedFunction then
                if (IdentifierAt(ForwardIdentIndex).DataType <> NestedFunctionResultType) or
                  (IdentifierAt(ForwardIdentIndex).NestedFunctionNumAllocElements <> NestedFunctionNumAllocElements) or
                  (IdentifierAt(ForwardIdentIndex).NestedFunctionAllocElementType <> NestedFunctionAllocElementType) then
                  Error(i, 'Function header doesn''t match the previous declaration ''' +
                    IdentifierAt(ForwardIdentIndex).Name + '''');


              CheckTok(i + 2, SEMICOLONTOK);

              iocheck_old := IOCheck;
              isInterrupt_old := isInterrupt;

              j := CompileBlock(i + 3, ForwardIdentIndex, IdentifierAt(ForwardIdentIndex).NumParams,
                IsNestedFunction, IdentifierAt(ForwardIdentIndex).DataType,
                IdentifierAt(ForwardIdentIndex).NestedFunctionNumAllocElements,
                IdentifierAt(ForwardIdentIndex).NestedFunctionAllocElementType);

              IOCheck := iocheck_old;
              isInterrupt := isInterrupt_old;

              i := j + 1;

              GenerateReturn(IsNestedFunction, IdentifierAt(ForwardIdentIndex).isInterrupt, IdentifierAt(ForwardIdentIndex).isInline,
                IdentifierAt(ForwardIdentIndex).isOverload);

              if OutputDisabled then OutputDisabled := False;

              Ident[ForwardIdentIndex].IsUnresolvedForward := False;

            end;

          end;


          CheckTok(i, SEMICOLONTOK);

          Inc(i);

        end;// else
    end;// while


    OutputDisabled := (Pass = CODEGENERATIONPASS) and (BlockStack[BlockStackTop] <> 1) and
      (not IdentifierAt(BlockIdentIndex).IsNotDead);


    // asm65('@main');

    if not isAsm then
    begin
      GenerateDeclarationEpilog;  // Make jump to block entry point

      if not (TokenAt(i - 1).Kind in [PROCALIGNTOK, LOOPALIGNTOK, LINKALIGNTOK]) then
        if LIBRARYTOK_USE and (TokenAt(i).Kind <> BEGINTOK) then

          Inc(i)

        else
          CheckTok(i, BEGINTOK);

    end;


    // Initialize array origin pointers if the current block is the main program body
{
if BlockStack[BlockStackTop] = 1 then begin

  for IdentIndex := 1 to NumIdent do
    if (IdentifierAt(IdentIndex).Kind = VARIABLE) and (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) then
      begin
//      Push(IdentifierAt(IdentIndex).Value + SizeOf(Int64), ASVALUE, DataSize[POINTERTOK], IdentifierAt(IdentIndex).Kind);     // Array starts immediately after the pointer to its origin
//      GenerateAssignment(IdentifierAt(IdentIndex).Value, ASPOINTER, DataSize[POINTERTOK], IdentIndex);
      asm65(#9'mwa #DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN + DataSize[POINTERTOK], 4) + ' DATAORIGIN+$' + IntToHex(IdentifierAt(IdentIndex).Value - DATAORIGIN , 4), '; ' + IdentifierAt(IdentIndex).Name );

      end;

end;
}


    Result := CompileStatement(i, isAsm);

    j := NumIdent;

    // Delete local identifiers and types from the tables to save space
    while (j > 0) and (IdentifierAt(j).Block = BlockStack[BlockStackTop]) do
    begin
      // If procedure or function, delete parameters first
      if IdentifierAt(j).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
        if IdentifierAt(j).IsUnresolvedForward and (IdentifierAt(j).isExternal = False) then
          Error(i, 'Unresolved forward declaration of ' + IdentifierAt(j).Name);

      Dec(j);
    end;


    // Return Result value

    if IsFunction then
    begin
      // if FunctionNumAllocElements > 0 then
      //  Push(IdentifierAt(GetIdent('RESULT')].Value, ASVALUE, DataSize[FunctionResultType], GetIdent('RESULT'))
      // else
      //  asm65;
      asm65('@exit');

      if IdentifierAt(BlockIdentIndex).isStdCall or IdentifierAt(BlockIdentIndex).isRecursion then
      begin

        Push(IdentifierAt(GetIdent('RESULT')).Value, ASPOINTER, DataSize[FunctionResultType], GetIdent('RESULT'));

        asm65;

        if not isInl then
        begin
          asm65(#9'.ifdef @new');      // @FreeMem
          asm65(#9'lda <@VarData');
          asm65(#9'sta :ztmp');
          asm65(#9'lda >@VarData');
          asm65(#9'ldy #@VarDataSize-1');
          asm65(#9'jmp @FreeMem');
          asm65(#9'eif');
        end;

      end;

    end;

    if IdentifierAt(BlockIdentIndex).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
    begin

      if IdentifierAt(BlockIdentIndex).isInline then asm65(#9'.ENDM');

      GenerateProcFuncAsmLabels(BlockIdentIndex, True);

    end;

    Dec(BlockStackTop);


    if Pass = CALLDETERMPASS then
      if IdentifierAt(BlockIdentIndex).isKeep or IdentifierAt(BlockIdentIndex).isInterrupt or
        IdentifierAt(BlockIdentIndex).updateResolvedForward then
        AddCallGraphChild(BlockStack[BlockStackTop], IdentifierAt(BlockIdentIndex).ProcAsBlock);


    //Result := j;

  end;  //CompileBlock


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure CompileProgram;
  var
    i, j, DataSegmentSize, IdentIndex: Integer;
    tmp, a: String;
    yes: Boolean;
    res: TResource;
  begin

    ResetOpty;

    common.optimize.use := False;

    tmp := '';

    IOCheck := True;

    DataSegmentSize := 0;

    AsmBlockIndex := 0;

    //SetLength(AsmLabels, 1);

    DefineIdent(1, 'MAIN', PROCEDURETOK, 0, 0, 0, 0);


    GenerateProgramProlog;

    j := CompileBlock(1, NumIdent, 0, False, 0);


    if TokenAt(j).Kind = ENDTOK then CheckTok(j + 1, DOTTOK)
    else
      if TokenAt(NumTok).Kind = EOFTOK then
        Error(NumTok, 'Unexpected end of file');

    j := NumIdent;

    while (j > 0) and (IdentifierAt(j).UnitIndex = 1) do
    begin
      // If procedure or function, delete parameters first
      if IdentifierAt(j).Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
        if (IdentifierAt(j).IsUnresolvedForward) and (IdentifierAt(j).isExternal = False) then
          Error(j, 'Unresolved forward declaration of ' + IdentifierAt(j).Name);

      Dec(j);
    end;

    StopOptimization;

    //asm65;
    asm65('@exit');
    asm65;
    asm65('@halt'#9'ldx #$00');
    asm65(#9'txs');

    if LIBRARY_USE then asm65('@regX'#9'ldx #$00');

    if target.id = ___a8 then
    begin

      if LIBRARY_USE = False then
      begin
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

    for j := 1 to MAXDEFINES do
      if (Defines[j].Name <> '') and (Defines[j].Macro = '') then asm65(Defines[j].Name);

    asm65('.endl');


    asm65(#13#10'.local'#9'@RESOURCE');

    for i := 0 to High(resArray) - 1 do
    begin

      resArray[i].resStream := False;

      yes := False;
      for IdentIndex := 1 to NumIdent do
        if (resArray[i].resName = IdentifierAt(IdentIndex).Name) and (IdentifierAt(IdentIndex).Block = 1) then
        begin

          if (IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0) then
            tmp := GetLocalName(IdentIndex, 'adr.')
          else
            tmp := GetLocalName(IdentIndex);

          //     asm65(resArray[i].resName+' = ' + tmp);
          //     asm65(resArray[i].resName+'.end');

          if resArray[i].resType = 'LIBRARY' then RCLIBRARY := True;

          resArray[i].resFullName := tmp;

          Ident[IdentIndex].Pass := Pass;

          yes := True;
          Break;
        end;


      if not yes then
        if AnsiUpperCase(resArray[i].resType) = 'SAPR' then
        begin
          asm65(resArray[i].resName);
          asm65(#9'dta a(' + resArray[i].resName + '.end-' + resArray[i].resName + '-2)');
          asm65(#9'ins ''' + resArray[i].resFile + '''');
          asm65(resArray[i].resName + '.end');
          resArray[i].resStream := True;
        end
        else

          if AnsiUpperCase(resArray[i].resType) = 'PP' then
          begin
            asm65(resArray[i].resName + #9'm@pp "''' + resArray[i].resFile + '''"');
            asm65(resArray[i].resName + '.end');
            resArray[i].resStream := True;
          end
          else

            if AnsiUpperCase(resArray[i].resType) = 'DOSFILE' then
            begin

            end
            else

              if AnsiUpperCase(resArray[i].resType) = 'RCDATA' then
              begin
                asm65(resArray[i].resName + #9'ins ''' + resArray[i].resFile + '''');
                asm65(resArray[i].resName + '.end');
                resArray[i].resStream := True;
              end
              else

                Error(NumTok, 'Resource identifier not found: Type = ' + resArray[i].resType +
                  ', Name = ' + resArray[i].resName);

      //  asm65(#9+resArray[i].resType+' '''+resArray[i].resFile+''''+','+resArray[i].resName);

      //  resArray[i].resFullName := tmp;

      //  IdentifierAt(IdentIndex).Pass := Pass;
    end;

    asm65('.endl');


    asm65;
    asm65('.endl', '; MAIN');

    asm65separator;
    asm65separator(False);

    asm65;
    asm65('.macro'#9'UNITINITIALIZATION');

    for j := NumUnits downto 2 do
      if UnitName[j].Name <> '' then
      begin

        asm65;
        asm65(#9'.ifdef MAIN.' + UnitName[j].Name + '.@UnitInit');
        asm65(#9'jsr MAIN.' + UnitName[j].Name + '.@UnitInit');
        asm65(#9'.fi');

      end;

    asm65('.endm');

    asm65separator;

    for j := NumUnits downto 2 do
      if UnitName[j].Name <> '' then
      begin
        asm65;
        asm65(#9'ift .SIZEOF(MAIN.' + UnitName[j].Name + ') > 0');
        asm65(#9'.print ''' + UnitName[j].Name + ': ' + ''',MAIN.' + UnitName[j].Name + ',' +
          '''..''' + ',' + 'MAIN.' + UnitName[j].Name + '+.SIZEOF(MAIN.' + UnitName[j].Name + ')-1');
        asm65(#9'eif');
      end;


    asm65;
    asm65('.nowarn'#9'.print ''CODE: '',CODEORIGIN,''..'',MAIN.@RESOURCE-1');

    asm65;
    asm65(#9'ift .SIZEOF(MAIN.@RESOURCE)>0');
    asm65('.nowarn'#9'.print ''RESOURCE: '',MAIN.@RESOURCE,''..'',MAIN.@RESOURCE+.SIZEOF(MAIN.@RESOURCE)-1');
    asm65(#9'eif');
    asm65;


    for i := 0 to High(resArray) - 1 do
      if resArray[i].resStream then
        asm65(#9'.print ''$R ' + resArray[i].resName + ''',' + ''' ''' + ',' + '"''' +
          resArray[i].resFile + '''"' + ',' + ''' ''' + ',MAIN.@RESOURCE.' + resArray[i].resName +
          ',' + '''..''' + ',MAIN.@RESOURCE.' + resArray[i].resName + '.end-1');

    asm65;
    asm65('@end');
    asm65;
    asm65('.nowarn'#9'.print ''VARS: '',MAIN.@RESOURCE+.SIZEOF(MAIN.@RESOURCE),''..'',@end-1');

    asm65separator;
    asm65;


    if DATA_BASE > 0 then
      asm65(#9'org $' + IntToHex(DATA_BASE, 4))
    else
    begin

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

    if DataSegmentUse then
    begin
      if Pass = CODEGENERATIONPASS then
      begin

        // !!! I need to save everything, including the 'zeros'!!! For example, for TextAtr to work

        DataSegmentSize := GetVarDataSize;

        if LIBRARYTOK_USE = False then
          for j := GetVarDataSize - 1 downto 0 do
            if DataSegment[j] <> 0 then
            begin
              DataSegmentSize := j + 1;
              Break;
            end;

        tmp := '';

        for j := 0 to DataSegmentSize - 1 do
        begin

          if (j mod 24 = 0) then
          begin
            if tmp <> '' then asm65(tmp);
            tmp := '.by';
          end;

          if (j mod 8 = 0) then tmp := tmp + ' ';

          if DataSegment[j] and $c000 = $8000 then
            tmp := tmp + ' <[DATAORIGIN+$' + IntToHex(Byte(DataSegment[j]) or Byte(DataSegment[j + 1]) shl 8, 4) + ']'
          else
            if DataSegment[j] and $c000 = $4000 then
              tmp := tmp + ' >[DATAORIGIN+$' + IntToHex(Byte(DataSegment[j - 1]) or
                Byte(DataSegment[j]) shl 8, 4) + ']'
            else
              if DataSegment[j] and $3000 = $2000 then
                tmp := tmp + ' <[CODEORIGIN+$' + IntToHex(Byte(DataSegment[j]) or
                  Byte(DataSegment[j + 1]) shl 8, 4) + ']'
              else
                if DataSegment[j] and $3000 = $1000 then
                  tmp := tmp + ' >[CODEORIGIN+$' + IntToHex(Byte(DataSegment[j - 1]) or
                    Byte(DataSegment[j]) shl 8, 4) + ']'
                else
                  tmp := tmp + ' $' + IntToHex(DataSegment[j], 2);

        end;

        if tmp <> '' then asm65(tmp);

        // asm65;

        //  asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',*');

      end;

    end;{ else
 asm65(#13#10#9'.print ''DATA: '',DATAORIGIN,''..'',DATAORIGIN+'+IntToStr(VarDataSize));
}


    if LIBRARYTOK_USE then
    begin

      asm65;
      asm65('PROGRAMSTACK');

    end
    else
    begin

      asm65;
      asm65('VARINITSIZE'#9'= *-DATAORIGIN');
      asm65('VARDATASIZE'#9'= ' + IntToStr(GetVarDataSize));

      asm65;
      asm65('PROGRAMSTACK'#9'= DATAORIGIN+VARDATASIZE');

    end;

    asm65;
    asm65(#9'.print ''DATA: '',DATAORIGIN,''..'',PROGRAMSTACK');

    asm65;
    asm65(#9'ert DATAORIGIN<@end,''DATA memory overlap''');

    if FastMul > 0 then
    begin

      asm65separator;

      asm65;
      asm65(#9'icl ''common\fmul.asm''', '; fast multiplication');

      asm65;
      asm65(#9'.print ''FMUL_INIT: '',fmulinit,''..'',*-1');

      asm65;
      asm65(#9'org $' + IntToHex(FastMul, 2) + '00');

      asm65;
      asm65(#9'.print ''FMUL_DATA: '',*,''..'',*+$07FF');

      asm65;
      asm65('square1_lo'#9'.ds $200');
      asm65('square1_hi'#9'.ds $200');
      asm65('square2_lo'#9'.ds $200');
      asm65('square2_hi'#9'.ds $200');

    end;

    if target.id = ___a8 then
    begin
      asm65;
      asm65(#9'run START');
    end;

    asm65separator;

    asm65;
    asm65('.macro'#9'STATICDATA');

    tmp := '';
    for i := 0 to NumStaticStrChars - 1 do
    begin

      if (i mod 24 = 0) then
      begin

        if i > 0 then asm65(tmp);

        tmp := '.by ';

      end
      else
        if (i > 0) and (i mod 8 = 0) then tmp := tmp + ' ';

      if StaticStringData[i] and $c000 = $8000 then
        tmp := tmp + ' <[DATAORIGIN+$' + IntToHex(Byte(StaticStringData[i]) or
          Byte(StaticStringData[i + 1]) shl 8, 4) + ']'
      else
        if StaticStringData[i] and $c000 = $4000 then
          tmp := tmp + ' >[DATAORIGIN+$' + IntToHex(Byte(StaticStringData[i - 1]) or
            Byte(StaticStringData[i]) shl 8, 4) + ']'
        else
          if StaticStringData[i] and $3000 = $2000 then
            tmp := tmp + ' <[CODEORIGIN+$' + IntToHex(Byte(StaticStringData[i]) or
              Byte(StaticStringData[i + 1]) shl 8, 4) + ']'
          else
            if StaticStringData[i] and $3000 = $1000 then
              tmp := tmp + ' >[CODEORIGIN+$' + IntToHex(Byte(StaticStringData[i - 1]) or
                Byte(StaticStringData[i]) shl 8, 4) + ']'
            else
              tmp := tmp + ' $' + IntToHex(StaticStringData[i], 2);

    end;

    if tmp <> '' then asm65(tmp);

    asm65('.endm');


    if (High(resArray) > 0) and (target.id <> ___a8) then
    begin

      asm65;
      asm65('.local'#9'RESOURCE');

      asm65(#9'icl ''' + AnsiLowerCase(target.Name) + '\resource.asm''');

      asm65;


      for i := 0 to High(resArray) - 1 do
        if resArray[i].resStream = False then
        begin

          j := NumIdent;

          while (j > 0) and (IdentifierAt(j).UnitIndex = 1) do
          begin
            if IdentifierAt(j).Name = resArray[i].resName then
            begin
              resArray[i].resValue := IdentifierAt(j).Value;
              Break;
            end;
            Dec(j);
          end;

        end;


      for i := 0 to High(resArray) - 1 do
        for j := 0 to High(resArray) - 1 do
          if resArray[i].resValue < resArray[j].resValue then
          begin
            res := resArray[j];
            resArray[j] := resArray[i];
            resArray[i] := res;
          end;


      for i := 0 to High(resArray) - 1 do
        if resArray[i].resStream = False then
        begin

          a := #9 + resArray[i].resType + ' ''' + resArray[i].resFile + '''' + ' ';

          a := a + resArray[i].resFullName;

          for j := 1 to MAXPARAMS do a := a + ' ' + resArray[i].resPar[j];

          asm65(a);
        end;

      asm65('.endl');
    end;


    asm65;
    asm65(#9'end');

    flushTempBuf;      // flush TemporaryBuf

  end;  //CompileProgram


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


{$i include/syntax.inc}


  // ----------------------------------------------------------------------------
  // ----------------------------------------------------------------------------


  procedure ParseParam;
  var
    i, err: Integer;
    s: String;
    t, c: String[32];
  begin

    t := 'A8';    // target
    c := '';    // cpu

    i := 1;
    while i <= ParamCount do
    begin

      if ParamStr(i)[1] = '-' then
      begin

        if AnsiUpperCase(ParamStr(i)) = '-O' then
        begin

          outputFile := ParamStr(i + 1);
          Inc(i);
          if outputFile = '' then Syntax(3);

        end
        else
          if pos('-O:', AnsiUpperCase(ParamStr(i))) = 1 then
          begin

            outputFile := copy(ParamStr(i), 4, 255);

            if outputFile = '' then Syntax(3);

          end
          else
            if AnsiUpperCase(ParamStr(i)) = '-DIAG' then
              DiagMode := True
            else

              if (AnsiUpperCase(ParamStr(i)) = '-IPATH') or (AnsiUpperCase(ParamStr(i)) = '-I') then
              begin

                AddPath(ParamStr(i + 1));
                Inc(i);

              end
              else
                if pos('-IPATH:', AnsiUpperCase(ParamStr(i))) = 1 then
                begin

                  s := copy(ParamStr(i), 8, 255);
                  AddPath(s);

                end
                else
                  if (AnsiUpperCase(ParamStr(i)) = '-CPU') then
                  begin

                    c := AnsiUpperCase(ParamStr(i + 1));
                    Inc(i);

                  end
                  else
                    if pos('-CPU:', AnsiUpperCase(ParamStr(i))) = 1 then
                    begin

                      c := copy(ParamStr(i), 6, 255);

                    end
                    else
                      if (AnsiUpperCase(ParamStr(i)) = '-DEFINE') or (AnsiUpperCase(ParamStr(i)) = '-DEF') then
                      begin

                        AddDefine(AnsiUpperCase(ParamStr(i + 1)));
                        Inc(i);
                        AddDefines := NumDefines;

                      end
                      else
                        if pos('-DEFINE:', AnsiUpperCase(ParamStr(i))) = 1 then
                        begin

                          s := copy(ParamStr(i), 9, 255);
                          AddDefine(AnsiUpperCase(s));
                          AddDefines := NumDefines;

                        end
                        else
                          if (AnsiUpperCase(ParamStr(i)) = '-CODE') or (AnsiUpperCase(ParamStr(i)) = '-C') then
                          begin

                            val('$' + ParamStr(i + 1), CODEORIGIN_BASE, err);
                            Inc(i);
                            if err <> 0 then Syntax(3);

                          end
                          else
                            if pos('-CODE:', AnsiUpperCase(ParamStr(i))) = 1 then
                            begin

                              val('$' + copy(ParamStr(i), 7, 255), CODEORIGIN_BASE, err);
                              if err <> 0 then Syntax(3);

                            end
                            else
                              if (AnsiUpperCase(ParamStr(i)) = '-DATA') or (AnsiUpperCase(ParamStr(i)) = '-D') then
                              begin

                                val('$' + ParamStr(i + 1), DATA_BASE, err);
                                Inc(i);
                                if err <> 0 then Syntax(3);

                              end
                              else
                                if pos('-DATA:', AnsiUpperCase(ParamStr(i))) = 1 then
                                begin

                                  val('$' + copy(ParamStr(i), 7, 255), DATA_BASE, err);
                                  if err <> 0 then Syntax(3);

                                end
                                else
                                  if (AnsiUpperCase(ParamStr(i)) = '-STACK') or
                                    (AnsiUpperCase(ParamStr(i)) = '-S') then
                                  begin

                                    val('$' + ParamStr(i + 1), STACK_BASE, err);
                                    Inc(i);
                                    if err <> 0 then Syntax(3);

                                  end
                                  else
                                    if pos('-STACK:', AnsiUpperCase(ParamStr(i))) = 1 then
                                    begin

                                      val('$' + copy(ParamStr(i), 8, 255), STACK_BASE, err);
                                      if err <> 0 then Syntax(3);

                                    end
                                    else
                                      if (AnsiUpperCase(ParamStr(i)) = '-ZPAGE') or
                                        (AnsiUpperCase(ParamStr(i)) = '-Z') then
                                      begin

                                        val('$' + ParamStr(i + 1), ZPAGE_BASE, err);
                                        Inc(i);
                                        if err <> 0 then Syntax(3);

                                      end
                                      else
                                        if pos('-ZPAGE:', AnsiUpperCase(ParamStr(i))) = 1 then
                                        begin

                                          val('$' + copy(ParamStr(i), 8, 255), ZPAGE_BASE, err);
                                          if err <> 0 then Syntax(3);

                                        end
                                        else
                                          if (AnsiUpperCase(ParamStr(i)) = '-TARGET') or
                                            (AnsiUpperCase(ParamStr(i)) = '-T') then
                                          begin

                                            t := AnsiUpperCase(ParamStr(i + 1));
                                            Inc(i);

                                          end
                                          else
                                            if pos('-TARGET:', AnsiUpperCase(ParamStr(i))) = 1 then
                                            begin

                                              t := AnsiUpperCase(copy(ParamStr(i), 9, 255));

                                            end
                                            else
                                              Syntax(3);

      end
      else

      begin
        UnitName[1].Name := ParamStr(i);  //ChangeFileExt(ParamStr(i), '.pas');
        UnitName[1].Path := UnitName[1].Name;

        if not FileExists(UnitName[1].Name) then
        begin
          writeln('Error: Can''t open file ''' + UnitName[1].Name + '''');
          FreeTokens;
          Halt(3);
        end;

      end;

      Inc(i);
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
      if AnsiUpperCase(c) = '6502' then target.cpu := CPU_6502
      else
        if AnsiUpperCase(c) = '65C02' then target.cpu := CPU_65C02
        else
          if AnsiUpperCase(c) = '65816' then target.cpu := CPU_65816
          else
            Syntax(3);


    case target.cpu of
      CPU_6502: AddDefine('CPU_6502');
      cpu_65c02: AddDefine('CPU_65C02');
      cpu_65816: AddDefine('CPU_65816');
    end;

    AddDefines := NumDefines;

  end;  //ParseParam


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

  MainPath := IncludeTrailingPathDelimiter(MainPath);
  UnitPath[0] := IncludeTrailingPathDelimiter(MainPath + 'lib');

  if (ParamCount = 0) then Syntax(3);

  NumUnits := 1;           // !!! 1 !!!


  ParseParam;


  Defines[1].Name := AnsiUpperCase(target.Name);

  if (UnitName[1].Name = '') then Syntax(3);

  if pos(MainPath, ExtractFilePath(UnitName[1].Name)) > 0 then
    FilePath := ExtractFilePath(UnitName[1].Name)
  else
    FilePath := MainPath + ExtractFilePath(UnitName[1].Name);

  DefaultFormatSettings.DecimalSeparator := '.';
 {$IFDEF USEOPTFILE}
 AssignFile(OptFile, ChangeFileExt(UnitName[1].Name, '.opt') ); FileMode:=1; rewrite(OptFile);
 {$ENDIF}


  if ExtractFileName(outputFile) = '' then
  begin
    outputFile := ChangeFileExt(UnitName[1].Name, '.a65');
  end;

  AssignFile(OutFile, outputFile);

  FileMode := 1;
  Rewrite(OutFile);

  TextColor(WHITE);

  Writeln('Compiling ', UnitName[1].Name);

  start_time := GetTickCount64;

 {$IFDEF USETRACEFILE}
 Assign(traceFile, ChangeFileExt( outputFile, '.log'));
 FileMode:=1;
 Rewrite(traceFile);
 {$ENDIF}

  // ----------------------------------------------------------------------------
  // Set defines for first pass;
  TokenizeProgram;

  if NumTok = 0 then Error(1, '');

  Inc(NumUnits);
  UnitName[NumUnits].Name := 'SYSTEM';    // default UNIT 'system.pas'
  UnitName[NumUnits].Path := FindFile('system.pas', 'unit');


  TokenizeProgram(False);

  // ----------------------------------------------------------------------------

  NumStaticStrCharsTmp := NumStaticStrChars;

  // Predefined constants
  DefineIdent(1, 'BLOCKREAD', FUNCTIONTOK, INTEGERTOK, 0, 0, $00000000);
  DefineIdent(1, 'BLOCKWRITE', FUNCTIONTOK, INTEGERTOK, 0, 0, $00000000);

  DefineIdent(1, 'GETRESOURCEHANDLE', FUNCTIONTOK, INTEGERTOK, 0, 0, $00000000);

  DefineIdent(1, 'NIL', CONSTANT, POINTERTOK, 0, 0, CODEORIGIN);

  DefineIdent(1, 'EOL', CONSTANT, CHARTOK, 0, 0, target.eol);

  DefineIdent(1, '__BUFFER', CONSTANT, WORDTOK, 0, 0, target.buf);

  DefineIdent(1, 'TRUE', CONSTANT, BOOLEANTOK, 0, 0, $00000001);
  DefineIdent(1, 'FALSE', CONSTANT, BOOLEANTOK, 0, 0, $00000000);

  DefineIdent(1, 'MAXINT', CONSTANT, INTEGERTOK, 0, 0, MAXINT);
  DefineIdent(1, 'MAXSMALLINT', CONSTANT, INTEGERTOK, 0, 0, MAXSMALLINT);

  DefineIdent(1, 'PI', CONSTANT, REALTOK, 0, 0, $40490FDB00000324);
  DefineIdent(1, 'NAN', CONSTANT, SINGLETOK, 0, 0, $FFC00000FFC00000);
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

  for CodeSize := 1 to High(UnitName) do UnitName[CodeSize].Units := 0;

  NumBlocks := 0;
  BlockStackTop := 0;
  CodeSize := 0;
  CodePosStackTop := 0;
  SetVarDataSize(0, 0);
  CaseCnt := 0;
  IfCnt := 0;
  ShrShlCnt := 0;
  NumTypes := 0;
  run_func := 0;
  NumProc := 0;

  NumStaticStrChars := NumStaticStrCharsTmp;


  ResetOpty;
  optyFOR0 := '';
  optyFOR1 := '';
  optyFOR2 := '';
  optyFOR3 := '';

  LIBRARY_USE := LIBRARYTOK_USE;

  LIBRARYTOK_USE := False;
  PROGRAMTOK_USE := False;
  INTERFACETOK_USE := False;
  PublicSection := True;

  iOut := -1;
  outTmp := '';

  SetLength(OptimizeBuf, 1);

  Pass := CODEGENERATIONPASS;
  CompileProgram;

  Flush(OutFile);
  CloseFile(OutFile);

{$IFDEF USEOPTFILE}
 CloseFile(OptFile);
{$ENDIF}

{$IFDEF USETRACEFILE}
CloseFile(TraceFile);
{$ENDIF}

  // Diagnostics
  if DiagMode then Diagnostics;


  WritelnMsg;

  TextColor(WHITE);

  Writeln(TokenAt(NumTok).Line, ' lines compiled, ', ((GetTickCount64 - start_time + 500) / 1000): 2: 2, ' sec, ',
    NumTok, ' tokens, ', NumIdent, ' idents, ', NumBlocks, ' blocks, ', NumTypes, ' types');

  FreeTokens;

  TextColor(LIGHTGRAY);

  if High(msgWarning) > 0 then Writeln(High(msgWarning), ' warning(s) issued');
  if High(msgNote) > 0 then Writeln(High(msgNote), ' note(s) issued');

  NormVideo;

end.
