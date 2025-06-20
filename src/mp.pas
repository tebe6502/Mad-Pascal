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

# (TokenAt( ].Kind = ASMTOK + TokenAt( ].Value = 0) wersja z { }
# (TokenAt( ].Kind = ASMTOK + TokenAt( ].Value = 1) wersja bez { }

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
 {$IFDEF WINDOWS}
  Windows,
                                {$ENDIF} {$IFDEF SIMULATED_CONSOLE}
  browserconsole,
                                {$ENDIF}
  Common,
  Compiler,
  CompilerTypes,
  Console,
  Diagnostic,
  FileIO,
  Messages,
  Targets,
  Tokens,
  Utilities;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

{$i include/syntax.inc}


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
//                                 Main program
// ----------------------------------------------------------------------------

  function Main: TExitCode;

  var
    MainPath: String;

    // Command line parameters
    inputFilePath: TFilePath;
    unitPathList: TPathList;
    targetID: TTargetID;
    cpu: TCPU;

    outputFilePath: TFilePath;
    DiagMode: Boolean;

    StartTime: QWord;
    seconds: ValReal;

    // Processing variables.
    programUnit: TSourceFile;

    procedure ParseParam;
    var
      i: Integer;
      parameter, parameterUpperCase, parameterValue: String;
    begin

      inputFilePath := '';
      targetID := TTargetID.A8;
      cpu := TCPU.NONE;

      CODEORIGIN_BASE := -1;
      DATA_BASE := -1;
      ZPAGE_BASE := -1;
      STACK_BASE := -1;
      outputFilePath := '';

      i := 1;
      while i <= TEnvironment.GetParameterCount() do
      begin
        parameter := TEnvironment.GetParameterString(i);
        parameterUpperCase := AnsiUpperCase(parameter);
        parameterValue := '';
        // Options start with a minus.
        if parameter[1] = '-' then
        begin

          if parameterUpperCase = '-O' then
          begin

            Inc(i);
            outputFilePath := parameter;
            if outputFilePath = '' then ParameterError(i, 'Output file path is empty');

          end
          else
            if pos('-O:', parameterUpperCase) = 1 then
            begin

              outputFilePath := copy(parameter, 4, 255);
              if outputFilePath = '' then ParameterError(i, 'Output file path is empty');

            end
            else
              if parameterUpperCase = '-DIAG' then
                DiagMode := True
              else

                if (parameterUpperCase = '-IPATH') or (parameterUpperCase = '-I') then
                begin
                  Inc(i);
                  parameterValue := TEnvironment.GetParameterString(i);
                  unitPathList.AddFolder(parameterValue);

                end
                else
                  if pos('-IPATH:', parameterUpperCase) = 1 then
                  begin
                    parameterValue := copy(parameter, 8, 255);
                    unitPathList.AddFolder(parameterValue);

                  end
                  else
                    if (parameterUpperCase = '-CPU') then
                    begin

                      Inc(i);
                      parameterValue := TEnvironment.GetParameterStringUpperCase(i);
                      cpu := ParseCPUParameter(i, parameterValue);

                    end
                    else
                      if pos('-CPU:', parameterUpperCase) = 1 then
                      begin

                        parameterValue := copy(parameter, 6, 255);
                        cpu := ParseCPUParameter(i, parameterValue);

                      end
                      else
                        if (parameterUpperCase = '-DEFINE') or (parameterUpperCase = '-DEF') then
                        begin

                          Inc(i);
                          parameterValue := TEnvironment.GetParameterStringUpperCase(i);
                          AddDefine(parameterValue);
                          AddDefines := NumDefines;
                          AddDefines := NumDefines;

                        end
                        else
                          if pos('-DEFINE:', parameterUpperCase) = 1 then
                          begin
                            parameterValue := copy(parameterUpperCase, 9, 255);
                            AddDefine(parameterValue);
                            AddDefines := NumDefines;
                          end
                          else
                            if (parameterUpperCase = '-CODE') or (parameterUpperCase = '-C') then
                            begin

                              Inc(i);
                              parameterValue := TEnvironment.GetParameterString(i);
                              CODEORIGIN_BASE := ParseHexParameter(i, parameterValue);

                            end
                            else
                              if pos('-CODE:', parameterUpperCase) = 1 then
                              begin
                                parameterValue := copy(parameter, 7, 255);
                                CODEORIGIN_BASE := ParseHexParameter(i, parameterValue);

                              end
                              else
                                if (parameterUpperCase = '-DATA') or (parameterUpperCase = '-D') then
                                begin

                                  Inc(i);
                                  parameterValue := TEnvironment.GetParameterString(i);
                                  DATA_BASE := ParseHexParameter(i, parameterValue);

                                end
                                else
                                  if pos('-DATA:', parameterUpperCase) = 1 then
                                  begin
                                    parameterValue := copy(parameter, 7, 255);
                                    DATA_BASE := ParseHexParameter(i, parameterValue);

                                  end
                                  else
                                    if (parameterUpperCase = '-STACK') or (parameterUpperCase = '-S') then
                                    begin

                                      Inc(i);
                                      parameterValue := TEnvironment.GetParameterString(i);
                                      STACK_BASE := ParseHexParameter(i, parameterValue);

                                    end
                                    else
                                      if pos('-STACK:', parameterUpperCase) = 1 then
                                      begin
                                        parameterValue := copy(parameter, 8, 255);
                                        STACK_BASE := ParseHexParameter(i, parameterValue);

                                      end
                                      else
                                        if (parameterUpperCase = '-ZPAGE') or (parameterUpperCase = '-Z') then
                                        begin

                                          Inc(i);
                                          parameterValue := TEnvironment.GetParameterString(i);
                                          ZPAGE_BASE := ParseHexParameter(i, parameterValue);

                                        end
                                        else
                                          if pos('-ZPAGE:', parameterUpperCase) = 1 then
                                          begin
                                            parameterValue := copy(parameter, 8, 255);
                                            ZPAGE_BASE := ParseHexParameter(i, parameterValue);

                                          end
                                          else
                                            if (parameterUpperCase = '-TARGET') or (parameterUpperCase = '-T') then
                                            begin

                                              Inc(i);
                                              parameterValue := TEnvironment.GetParameterStringUpperCase(i);
                                              targetID := ParseTargetParameter(i, parameterValue);
                                            end
                                            else
                                              if pos('-TARGET:', parameterUpperCase) = 1 then
                                              begin
                                                parameterValue := AnsiUpperCase(copy(parameter, 9, 255));
                                                targetID := ParseTargetParameter(i, parameterValue);
                                              end
                                              else
                                                ParameterError(i, 'Unknown option ''' + parameter + '''.');

        end
        // No minus, so this must be the file name.
        else

        begin
          inputFilePath := TFileSystem.NormalizePath(TEnvironment.GetParameterString(i));

          if not TFileSystem.FileExists_(inputFilePath) then
          begin
            ParameterError(i, 'Error: Can''t open file ''' + parameterValue + '''.');
          end;
        end;

        Inc(i);
      end;


      // All parameters parsed.
      Init(targetId, target);


      if CODEORIGIN_BASE < 0 then
        CODEORIGIN_BASE := target.codeorigin
      else
        target.codeorigin := CODEORIGIN_BASE;


      if ZPAGE_BASE < 0 then
        ZPAGE_BASE := target.zpage
      else
        target.zpage := ZPAGE_BASE;


      if cpu <> TCPU.NONE then target.cpu := cpu;

      case target.cpu of
        TCPU.CPU_6502: AddDefine('CPU_6502');
        TCPU.CPU_65C02: AddDefine('CPU_65C02');
        TCPU.CPU_65816: AddDefine('CPU_65816');
      end;

      AddDefines := NumDefines;

    end;  //ParseParam

    // Main
  begin

    Result := 0;
{$IFDEF WINDOWS}
   if Windows.GetFileType(Windows.GetStdHandle(STD_OUTPUT_HANDLE)) = Windows.FILE_TYPE_PIPE then
   begin
    System.Assign(Output, ''); FileMode:=1; System.Rewrite(Output);
   end;
{$ENDIF}

    // WriteLn('Sub-Pascal 32-bit real mode compiler v. 2.0 by Vasiliy Tereshkov, 2009');

    WriteLn(Compiler.CompilerTitle);


    MainPath := ExtractFilePath(ParamStr(0));
    MainPath := IncludeTrailingPathDelimiter(MainPath);
    unitPathList := TPathList.Create;
    unitPathList.AddFolder(MainPath + 'lib');

    if (TEnvironment.GetParameterCount = 0) then Syntax(THaltException.COMPILING_NOT_STARTED);

    SourceFileList := TSourceFileList.Create();

    try
      ParseParam();
    except
      on e: THaltException do
      begin
        Result := e.GetExitCode();
        Exit;
      end;
    end;

    // The main program is the first unit.

    if (inputFilePath = '') then Syntax(THaltException.COMPILING_NOT_STARTED);
    programUnit := SourceFileList.AddUnit(TSourceFileType.PROGRAM_FILE, ExtractFilename(inputFilePath), inputFilePath);

 {$IFDEF USEOPTFILE}

   OptFile:=TFileSystem.CreateTextFile();
   OptFile.Assign(ChangeFileExt(programUnit.Name, '.opt') );
   OptFile.Rewrite();

 {$ENDIF}

    OutFile := TFileSystem.CreateTextFile;
    if ExtractFileName(outputFilePath) <> '' then
      OutFile.Assign(outputFilePath)
    else
      OutFile.Assign(ChangeFileExt(programUnit.Name, '.a65'));

    OutFile.Rewrite;


    StartTime := GetTickCount64;

    try
      Compiler.Main(programUnit, unitPathList);
      OutFile.Flush;
      OutFile.Close;
    except
      on e: THaltException do
      begin
        Result := e.GetExitCode();
        OutFile.Close;
        OutFile.Erase;
      end;
    end;

{$IFDEF USEOPTFILE}

 OptFile.Close;

{$ENDIF}


    // Diagnostics
    if DiagMode then Diagnostics(programUnit);


    WritelnMsg;

    TextColor(WHITE);
    seconds := (GetTickCount64 - StartTime + 500) / 1000;
{$IFNDEF PAS2JS}
    Writeln(TokenAt(NumTok).SourceLocation.Line, ' lines compiled, ', seconds: 2: 2, ' sec, ',
      NumTok, ' tokens, ', NumIdent, ' idents, ', NumBlocks, ' blocks, ', NumTypes, ' types');
{$ELSE}
   Writeln(IntToStr(TokenAt(NumTok).SourceLocation.Line) + ' lines compiled, ' + FloatToStr(seconds) + ' sec, '
 	   + IntToStr(NumTok) + ' tokens        , ' + IntToStr(NumIdent) + ' idents, '
	   + IntToStr(NumBlocks) + ' blocks, ' +  IntToStr(NumTypes) + ' types');
{$ENDIF}

    Compiler.Free;

    TextColor(LIGHTGRAY);

    if msgLists.msgWarning.Count > 0 then Writeln(IntToStr(msgLists.msgWarning.Count) + ' warning(s) issued');
    if msgLists.msgNote.Count > 0 then Writeln(IntToStr(msgLists.msgNote.Count) + ' note(s) issued');

    NormVideo;
  end;

  function CallMain: TExitCode;
  var
    exitCode: TExitCode;
   {$IFDEF SIMULATED_FILE_IO}
    fileMap: TFileMap;
    fileMapEntry: TFileMapEntry;
    content: String;
   {$ENDIF}
  begin

    exitCode := Main();
    if (exitCode <> 0) then
    begin
      WriteLn('Program ended with exit code ' + IntToStr(exitCode));
    end;

  {$IFDEF SIMULATED_FILE_IO}
  fileMap:=TFileSystem.GetFileMap();
  fileMapEntry:=fileMap.GetEntry('Output.a65');
  if fileMapEntry<>nil then
  begin
    content:=fileMapEntry.content;
    WriteLn(content);
  end;
  {$ENDIF}

    Result := exitCode;
  end;

var
  exitCode: TExitCode;
begin
  exitCode := CallMain;
  {$IFDEF DEBUG}
  //exitCode := CallMain; // TODO until 2nd call works
  {$ENDIF}

  {$IFDEF DEBUG}
  Console.WaitForKeyPressed;
  {$ENDIF}

  {$IFNDEF PAS2JS}
  Halt(exitCode);
  {$ENDIF}
end.
