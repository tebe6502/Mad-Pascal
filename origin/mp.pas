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

+ Peter Dell :
  - pas2js
  - optimizations

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

# ---------------------------------------------------------------------------------------------------------------
#                          |      DataType      |  AllocElementType   |  NumAllocElements  |  NumAllocElements_ |
# ---------------------------------------------------------------------------------------------------------------
# ARRAY [0..X]             | POINTERTOK         | Type                | X Array Size       | 0                  |
# ARRAY [0..X, 0..Y]       | POINTERTOK         | Type                | X Array Size       | Y Array Size       |
# VAR RECORD               | POINTERTOK         | RECORDTOK|OBJECTTOK | 0                  | 0                  |
# VAR ^RECORD              | POINTERTOK         | RECORDTOK           | RecType            | 0                  |
# ARRAY [0..X] OF ^RECORD  | POINTERTOK         | RECORDTOK           | RecType            | X Array Size       |
# ARRAY [0..X] OF ^OBJECT  | POINTERTOK         | OBJECTTOK           | RecType            | X Array Size       |
# ---------------------------------------------------------------------------------------------------------------

*)

program MADPASCAL;

{$i define.inc}

uses
  Crt,
  SysUtils,

{$IFDEF WINDOWS}
  Windows,
{$ENDIF}

  Common,
  Messages,
  Compiler,
  Scanner,
  Parser,
  Optimize,
  Diagnostic;


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
    c := '';      // cpu

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
                                  if (AnsiUpperCase(ParamStr(i)) = '-STACK') or (AnsiUpperCase(ParamStr(i)) = '-S') then
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
                                      if (AnsiUpperCase(ParamStr(i)) = '-ZPAGE') or (AnsiUpperCase(ParamStr(i)) = '-Z') then
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
                                          if (AnsiUpperCase(ParamStr(i)) = '-TARGET') or (AnsiUpperCase(ParamStr(i)) = '-T') then
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
  _VarDataSize := 0;
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

  // Diagnostics
  if DiagMode then Diagnostics;


  WritelnMsg;

  TextColor(WHITE);

  Writeln(Tok[NumTok].Line, ' lines compiled, ', ((GetTickCount64 - start_time + 500) / 1000): 2: 2, ' sec, ', NumTok, ' tokens, ', NumIdent, ' idents, ', NumBlocks, ' blocks, ', NumTypes, ' types');

  FreeTokens;

  TextColor(LIGHTGRAY);

  if High(msgWarning) > 0 then Writeln(High(msgWarning), ' warning(s) issued');
  if High(msgNote) > 0 then Writeln(High(msgNote), ' note(s) issued');

  NormVideo;

end.
