unit Scanner;

{$I Defines.inc}

interface

uses CommonTypes, CompilerTypes, Tokens;

  // ----------------------------------------------------------------------------

type
  IScanner = interface

    procedure TokenizeProgram(const ProgramUnit: TSourceFile; const UsesOn: Boolean);
  end;

type
  TScanner = class(TInterfacedObject, IScanner)

    procedure TokenizeProgram(const ProgramUnit: TSourceFile; const UsesOn: Boolean);

  private
    function AddToken(Kind: TTokenKind; SourceFile: TSourceFile; Line, Column: Integer; Value: TInteger): TToken;
    function AddMacroToken(Kind: TTokenKind; Line, Column: Integer; Value: TInteger): TToken;
    procedure TokenizeMacro(a: String; Line, Spaces: Integer);
  end;

implementation

uses Classes, SysUtils, Common, DataTypes, Messages, FileIO, Memory, Optimize, ScannerTypes,
  StringUtilities, Utilities;

const
  SCANNER_CACHED = True;

  // ----------------------------------------------------------------------------
  // Class TScanner Implementation
  // ----------------------------------------------------------------------------

procedure ErrorOrdinalExpExpected(i: TTokenIndex);
begin
  Error(i, TMessage.Create(TErrorCode.OrdinalExpExpected, 'Ordinal expression expected.'));
end;

procedure TokenizeProgramInitialization(ProgramUnit: TSourceFile);
var
  i: Integer;
begin

  NumIdent_ := 0;
  TokenList.Clear;


  FastMul := -1;
  DataSegmentUse := False;
  LoopUnroll := False;
  PublicSection := True;
  ActiveSourceFile := ProgramUnit;

  SetLength(WithName, 1);
  SetLength(linkObj, 1);
  SetLength(resArray, 1);

  Messages.Initialize;

  BlockManager.Initialize;

  CodeSize := 0;
  CodePosStackTop := 0;
  CaseCnt := 0;
  IfCnt := 0;
  NumTypes := 0;
  run_func := 0;
  NumProc := 0;

  ClearWordMemory(StaticStringData);
  NumStaticStrChars := 0;

  IfdefLevel := 0;
  AsmBlockIndex := 0;

  NumDefines := AddDefines;

  for i := 0 to High(AsmBlock) do AsmBlock[i] := '';

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure AddResource(const filePath: TFilePath);
var
  i, j: Integer;
  t: ITextFile;
  res: TResource;
  s, tmp: String;
begin

  t := TFileSystem.CreateTextFile;
  t.Assign(filePath);
  t.Reset;

  try

    while not t.EOF do
    begin
      s := '';
      t.ReadLn(s);

      i := 1;
      SkipWhitespaces(s, i);

      if (length(s) > i - 1) and (not (s[i] in ['#', ';'])) then
      begin

        res.resName := GetLabelUpperCase(s, i);
        res.resType := GetLabelUpperCase(s, i);
        res.resFile := GetFilePath(s, i);

        // Debug
        // WriteLn('DEBUG: ', res.resName, ',', res.resType, ',', res.resFile);


        if (res.resType = 'RCDATA') or (res.resType = 'RCASM') or (res.resType = 'DOSFILE') or
          (res.resType = 'RELOC') or (res.resType = 'RMT') or (res.resType = 'MPT') or
          (res.resType = 'CMC') or (res.resType = 'TMC') or (res.resType = 'RMTPLAY') or
          (res.resType = 'RMTPLAY2') or (res.resType = 'RMTPLAYV') or (res.resType = 'MPTPLAY') or
          (res.resType = 'CMCPLAY') or (res.resType = 'TMCPLAY') or (res.resType = 'EXTMEM') or
          (res.resType = 'XBMP') or (res.resType = 'SAPR') or (res.resType = 'SAPRPLAY') or
          (res.resType = 'PP') or (res.resType = 'LIBRARY') or (res.resType = 'MD1PLAY') or (res.resType = 'MD1') then

        else
          Error(NumTok, TMessage.Create(TErrorCode.UndefinedResourceType,
            'Undefined resource type: Type = ''' + res.resType + ''', Name = ''' + res.resName + ''''));


        if (res.resFile <> '') and (unitPathList.FindFile(res.resFile) = '') then
        begin
          // TODO Have message for special case empty unit path
          Error(NumTok, TMessage.Create(TErrorCode.ResourceFileNotFound,
            'Cannot find resource file ''{0}'' for resource {1} of type {2} unit path ''{3}''.',
            res.resFile, res.resName, res.resType, unitPathList.ToString));
        end;

        for j := 1 to MAXPARAMS do
        begin

          if i <= Length(s) then
          begin
            if s[i] in ['''', '"'] then
              tmp := GetStringUpperCase(s, i)
            else
              tmp := GetNumber(s, i);
          end
          else
          begin
            tmp := '';
          end;

          if tmp = '' then tmp := '0';

          res.resPar[j] := tmp;
        end;

        for j := High(resArray) - 1 downto Low(resArray) do
          if resArray[j].resName = res.resName then
            Error(NumTok, TMessage.Create(TErrorCode.DuplicateResource, 'Duplicate resource: Type = ' +
              res.resType + ', Name = ''' + res.resName + ''''));

        j := High(resArray);
        resArray[j] := res;

        SetLength(resArray, j + 2);

      end;

    end;

  finally
    t.Close;
  end;

end;  //AddResource


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function TScanner.AddToken(Kind: TTokenKind; SourceFile: TSourceFile; Line, Column: Integer; Value: TInteger): TToken;
begin
  Result := tokenList.AddToken(kind, SourceFile, line, Column, Value);
end;

function TScanner.AddMacroToken(Kind: TTokenKind; Line, Column: Integer; Value: TInteger): TToken;
begin
  Result := AddToken(kind, SourceFileList.GetSourceFile(SYSTEM_UNIT_INDEX), line, Column, Value);
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveAsmBlock(const a: Char);
begin
  AsmBlock[AsmBlockIndex] := AsmBlock[AsmBlockIndex] + a;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TScanner.TokenizeProgram(const programUnit: TSourceFile; const UsesOn: Boolean);
var
  ActiveSourceFile: TSourceFile; // Currently tokenized source file
  Line, Err, cnt, Line2, Spaces, TextPos, im, OldNumDefines: Integer;
  Tmp: Int64;
  AsmFound, UsesFound, UnitFound, ExternalFound, yes: Boolean;

  CurToken: TTokenKind;
  StrParams: TStringArray;

  procedure TokenizeUnit(const SourceFile: TSourceFile; const TestSourceFile: Boolean = False); forward;


  procedure Tokenize(const FilePath: TFilePath; const TestSourceFile: Boolean = False);
  var
    InFile: IBinaryFile;
    _line: Integer;
    _uidx: TSourceFile;

    TextBuffer: ITextBuffer;
    Num, Frac: TString;
    OldNumTok: Integer;

    ch, ch2, ch_: Char;

    procedure ReadUses;
    var
      i, j, k: Integer;
      _line: Integer;
      _uidx: TSourceFile;
      unitName: String;
      filePath: TFilePath;
    begin

      UsesFound := False;

      i := NumTok - 1;


      while TokenAt(i).Kind <> TTokenKind.USESTOK do
      begin

        if TokenAt(i).Kind = TTokenKind.STRINGLITERALTOK then
        begin

          CheckTok(i - 1, TTokenKind.INTOK);
          CheckTok(i - 2, TTokenKind.IDENTTOK);

          filePath := '';

          for k := 1 to TokenAt(i).StrLength do
            filePath := filePath + chr(StaticStringData[TokenAt(i).StrAddress - CODEORIGIN + k]);

          filePath := FindFile(filePath, 'unit');

          Dec(i, 2);

        end
        else
        begin

          CheckTok(i, TTokenKind.IDENTTOK);
          //" TODO: Use case-sensitive name
          filePath := FindFile(TokenAt(i).Name + '.pas', 'unit');

        end;


        unitName := AnsiUpperCase(TokenAt(i).Name);


        // We clear earlier usages of the same unit.
        // This means this entry in the unit list will not be tokenized.
        for j := 2 to SourceFileList.Size do
        begin
          if SourceFileList.GetSourceFile(j).Name = unitName then SourceFileList.GetSourceFile(j).Name := '';
        end;

        _line := Line;
        _uidx := ActiveSourceFile;


        // TODO Move check to TSourceFileList and use exceptions
        (*
        if ActiveSourceFile > High(SourceFileList.UnitArray) then
        begin
          Error(NumTok, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, ActiveSourceFile: ' +
            IntToStr(ActiveSourceFile)));
        end; *)

        ActiveSourceFile := SourceFileList.AddUnit(TSourceFileType.UNIT_FILE, unitName, filePath);
        Line := 1;

        TokenizeUnit(ActiveSourceFile, True);

        Line := _line;
        ActiveSourceFile := _uidx;

        if TokenAt(i - 1).Kind = TTokenKind.COMMATOK then
          Dec(i, 2)
        else
          Dec(i);

      end;  //while

    end;


    procedure RemoveDefine(X: String);
    var
      i: Integer;
    begin
      i := SearchDefine(X);
      if i <> 0 then
      begin
        Dec(NumDefines);
        for i := i to NumDefines do
          Defines[i] := Defines[i + 1];
      end;
    end;


    function SkipCodeUntilDirective: String;
    var
      c: Char;
      i: Byte;
    begin
      i := 1;
      Result := '';

      repeat
        c := ' ';
        InFile.Read(c);

        if c = LF then Inc(Line);
        case i of
          1:
            case c of
              '(': i := 2;
              '{': i := 5;
            end;
          2:
            if c = '*' then i := 3
            else
              i := 1;
          3:
            if c = '*' then i := 4;
          4:
            if c = ')' then i := 1
            else
              i := 3;
          5:
            if c = '$' then i := 6
            else
            begin
              i := 0 + 1;
              Result := '';
            end;
          6:
            if UpCase(c) in AllowLabelFirstChars then
            begin
              Result := UpCase(c);
              i := 7;
            end
            else
            begin
              i := 0 + 1;
              Result := '';
            end;
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


    function SkipCodeUntilElseEndif: Boolean;
    var
      dir: String;
      lvl: Integer;
    begin
      lvl := 0;
      repeat
        dir := SkipCodeUntilDirective;
        if dir = 'ENDIF' then
        begin
          Dec(lvl);
          if lvl < 0 then
            Exit(False);
        end
        else if (lvl = 0) and (dir = 'ELSE') then
            Exit(True)
          else if dir = 'IFDEF' then
              Inc(lvl)
            else if dir = 'IFNDEF' then
                Inc(lvl);
      until False;
    end;


    procedure ReadDirective(const d: String; DefineLine: Integer);
    var
      i, v, x: Integer;
      cmd, s: String;
      defineName: TDefineName;
      filePath: TFilePath;
      found: Boolean;
      Param: TDefineParams;


      procedure bin2csv(const fn: String);
      var
        bin: IBinaryFile;
        tmp: Byte;
        NumRead: Integer;
        yes: Boolean;
      begin

        yes := False;

        tmp := 0;
        NumRead := 0;
        bin := TFileSystem.CreateBinaryFile(SCANNER_CACHED);
        bin.Assign(fn);
        bin.Reset(1);

        repeat
          bin.BlockRead(tmp, 1, NumRead);

          if NumRead = 1 then
          begin

            if yes then AddToken(GetStandardToken(','), ActiveSourceFile, Line, 1, 0);

            AddToken(TTokenKind.INTNUMBERTOK, ActiveSourceFile, Line, 1, tmp);

            yes := True;
          end;

        until (NumRead = 0);

        bin.Close();

      end;


      procedure skip_spaces;
      begin

        while d[i] in AllowWhiteSpaces do
        begin
          if d[i] = LF then Inc(DefineLine);
          Inc(i);
        end;

      end;


      procedure newMsgUser(const Kind: TTokenKind);
      var
        k: Integer;
      begin

        k := msgLists.msgUser.Count;

        AddToken(Kind, ActiveSourceFile, Line, 1, k);
        AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

        SkipWhitespaces(d, i);

        msgLists.msgUser.Add(copy(d, i, length(d) - i));

      end;

    begin

      Param := Default(TDefineParams);

      if UpCase(d[1]) in AllowLabelFirstChars then
      begin

        i := 1;
        cmd := GetLabelUpperCase(d, i);

        if cmd = 'INCLUDE' then cmd := 'I';
        if cmd = 'RESOURCE' then cmd := 'R';

        if cmd = 'WARNING' then newMsgUser(TTokenKind.WARNINGTOK)
        else
          if cmd = 'ERROR' then newMsgUser(TTokenKind.ERRORTOK)
          else
            if cmd = 'INFO' then newMsgUser(TTokenKind.INFOTOK)
            else

              if cmd = 'MACRO+' then macros := True
              else
                if cmd = 'MACRO-' then macros := False
                else
                  if cmd = 'MACRO' then
                  begin

                    s := GetStringUpperCase(d, i);

                    if s = 'ON' then macros := True
                    else
                      if s = 'OFF' then macros := False
                      else
                        Error(NumTok, TMessage.Create(TErrorCode.WrongSwitchToggle,
                          'Wrong switch toggle, use ON/OFF or +/-'));

                  end
                  else

                    if cmd = 'I' then
                    begin
                      // {$i filename}
                      // {$i+-} iocheck
                      if d[i] = '+' then
                      begin
                        AddToken(TTokenKind.IOCHECKON, ActiveSourceFile, Line, 1, 0);
                        AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);
                      end
                      else
                        if d[i] = '-' then
                        begin
                          AddToken(TTokenKind.IOCHECKOFF, ActiveSourceFile, Line, 1, 0);
                          AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);
                        end
                        else
                        begin
                          //   AddToken(SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                          s := GetString(d, False, i);        // don't change the case, it could be a file path

                          if AnsiUpperCase(s) = '%TIME%' then
                          begin

                            s := TimeToStr(Now);

                            AddToken(TTokenKind.STRINGLITERALTOK, ActiveSourceFile, Line, length(s) + Spaces, 0);
                            Spaces := 0;
                            DefineStaticString(NumTok, s);

                          end
                          else
                            if AnsiUpperCase(s) = '%DATE%' then
                            begin

                              s := DateToStr(Now);

                              AddToken(TTokenKind.STRINGLITERALTOK, ActiveSourceFile, Line, length(s) + Spaces, 0);
                              Spaces := 0;
                              DefineStaticString(NumTok, s);

                            end
                            else
                            begin

                              filePath := FindFile(s, 'include');

                              _line := Line;
                              _uidx := ActiveSourceFile;

                              Line := 1;

                              // TODO Error handling with exception
                              ActiveSourceFile :=
                                SourceFileList.AddUnit(TSourceFileType.INCLUDE_FILE,
                                ExtractFileName(filePath), filePath);
                              (* if IncludeIndex > High(SourceFileList.UnitArray) then
                                Error(NumTok, TMessage.Create(TErrorCode.OutOfResources,
                                  'Out of resources, IncludeIndex: ' + IntToStr(IncludeIndex)));
                               *)

                              Tokenize(filePath);

                              Line := _line;
                              ActiveSourceFile := _uidx;

                            end;

                        end;

                    end
                    else

                      if (cmd = 'EVAL') then
                      begin

                        if d.LastIndexOf('}') < 0 then
                          Error(NumTok, TMessage.Create(TErrorCode.SyntaxError,
                            'Syntax error. Character ''}'' expected'));

                        s := copy(d, i, d.LastIndexOf('}') - i + 1);
                        s := TrimRight(s);

                        if s[length(s)] <> '"' then
                          Error(NumTok, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error. Missing ''"'''));

                        AddToken(TTokenKind.EVALTOK, ActiveSourceFile, Line, 1, 0);

                        DefineFilename(NumTok, s);

                      end
                      else

                        if (cmd = 'BIN2CSV') then
                        begin

                          s := GetFilePath(d, i);

                          s := FindFile(s, 'BIN2CSV');

                          bin2csv(s);

                        end
                        else

                          if (cmd = 'OPTIMIZATION') then
                          begin

                            s := GetStringUpperCase(d, i);

                            if s = 'LOOPUNROLL' then AddToken(TTokenKind.LOOPUNROLLTOK, ActiveSourceFile, Line, 1, 0)
                            else
                              if s = 'NOLOOPUNROLL' then
                                AddToken(TTokenKind.NOLOOPUNROLLTOK, ActiveSourceFile, Line, 1, 0)
                              else
                                Error(NumTok, TMessage.Create(TErrorCode.IllegalOptimizationSpecified,
                                  'Illegal optimization specified "' + s + '"'));

                            AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                          end
                          else

                            if (cmd = 'CODEALIGN') then
                            begin

                              s := GetStringUpperCase(d, i);

                              if s = 'PROC' then AddToken(TTokenKind.PROCALIGNTOK, ActiveSourceFile, Line, 1, 0)
                              else
                                if s = 'LOOP' then AddToken(TTokenKind.LOOPALIGNTOK, ActiveSourceFile, Line, 1, 0)
                                else
                                  if s = 'LINK' then AddToken(TTokenKind.LINKALIGNTOK, ActiveSourceFile, Line, 1, 0)
                                  else
                                    Error(NumTok, TMessage.Create(TErrorCode.IllegalAlignmentDirective,
                                      'Illegal alignment directive ''' + s + '''.'));

                              SkipWhitespaces(d, i);

                              if d[i] <> '=' then
                                Error(NumTok, TMessage.Create(TErrorCode.SyntaxError, 'Character ''='' expected.'));
                              Inc(i);
                              SkipWhitespaces(d, i);

                              s := GetNumber(d, i);

                              val(s, v, Err);

                              if Err > 0 then
                                ErrorOrdinalExpExpected(NumTok);

                              CheckCommonConstType(NumTok, TDataType.WORDTOK, GetValueType(v));

                              TokenAt(NumTok).SetIntegerValue(v);

                              AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                            end
                            else

                              if (cmd = 'UNITPATH') then
                              begin      // {$unitpath path1;path2;...}
                                AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                                repeat

                                  s := GetFilePath(d, i);

                                  if s = '' then
                                    Error(NumTok, TMessage.Create(TErrorCode.FilePathNotSpecified,
                                      'An empty path cannot be used'));

                                  unitPathList.AddFolder(s);

                                  if d[i] = ';' then
                                    Inc(i)
                                  else
                                    Break;

                                until d[i] = ';';

                                tokenList.RemoveToken;
                              end
                              else

                                if (cmd = 'LIBRARYPATH') then
                                begin      // {$librarypath path1;path2;...}
                                  AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                                  repeat

                                    s := GetFilePath(d, i);

                                    if s = '' then
                                      Error(NumTok, TMessage.Create(TErrorCode.FilePathNotSpecified,
                                        'An empty path cannot be used'));

                                    unitPathList.AddFolder(s);

                                    if d[i] = ';' then
                                      Inc(i)
                                    else
                                      Break;

                                  until d[i] = ';';

                                  TokenList.RemoveToken;
                                end
                                else

                                  if (cmd = 'R') and not (d[i] in ['+', '-']) then
                                  begin  // {$R filename}
                                    AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                                    s := GetFilePath(d, i);
                                    AddResource(FindFile(s, 'resource'));

                                    tokenList.RemoveToken;
                                  end
                                  else
(*
       if cmd = 'C' then begin          // {$c 6502|65816}
  AddToken(SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

  s := GetNumber(i, d);

  val(s,CPUMode, Err);

  if Err > 0 then
   Error(NumTok, OrdinalExpExpected);

  CheckCommonConstType(NumTok, CARDINALTOK, GetValueType(CPUMode));

  dec(NumTok);
       end else
*)

                                    if (cmd = 'L') or (cmd = 'LINK') then
                                    begin    // {$L filename} | {$LINK filename}
                                      AddToken(TTokenKind.LINKTOK, ActiveSourceFile, Line, 1, 0);

                                      s := GetFilePath(d, i);
                                      s := FindFile(s, 'link object');

                                      DefineFilename(NumTok, s);

                                      AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                                      //dec(NumTok);
                                    end
                                    else

                                      if (cmd = 'F') or (cmd = 'FASTMUL') then
                                      begin    // {$F [page address]}
                                        AddToken(TTokenKind.SEMICOLONTOK, ActiveSourceFile, Line, 1, 0);

                                        s := GetNumber(d, i);

                                        val(s, FastMul, Err);

                                        if Err <> 0 then
                                          ErrorOrdinalExpExpected(NumTok);

                                        AddDefine('FASTMUL');
                                        AddDefines := NumDefines;

                                        CheckCommonConstType(NumTok, TDataType.BYTETOK, GetValueType(FastMul));

                                        tokenList.RemoveToken;
                                      end
                                      else

                                        if (cmd = 'IFDEF') or (cmd = 'IFNDEF') then
                                        begin

                                          found := 0 <> SearchDefine(GetLabelUpperCase(d, i));

                                          if cmd = 'IFNDEF' then found := not found;

                                          if not found then
                                          begin
                                            if SkipCodeUntilElseEndif then
                                              Inc(IfdefLevel);
                                          end
                                          else
                                            Inc(IfdefLevel);
                                        end
                                        else
                                          if cmd = 'ELSE' then
                                          begin
                                            if (IfdefLevel = 0) or SkipCodeUntilElseEndif then
                                              Error(NumTok, TMessage.Create(TErrorCode.ElseWithoutIf,
                                                'Found $ELSE without $IFXXX'));
                                            if IfdefLevel > 0 then
                                              Dec(IfdefLevel);
                                          end
                                          else
                                            if cmd = 'ENDIF' then
                                            begin
                                              if IfdefLevel = 0 then
                                                Error(NumTok, TMessage.Create(TErrorCode.EndifWithoutIf,
                                                  'Found $ENDIF without $IFXXX'))
                                              else
                                                Dec(IfdefLevel);
                                            end
                                            else
                                              if cmd = 'DEFINE' then
                                              begin
                                                defineName := GetLabelUpperCase(d, i);

                                                Err := 0;

                                                skip_spaces;

                                                if d[i] = '(' then
                                                begin  // macro parameters

                                                  Param[1] := '';
                                                  Param[2] := '';
                                                  Param[3] := '';
                                                  Param[4] := '';
                                                  Param[5] := '';
                                                  Param[6] := '';
                                                  Param[7] := '';
                                                  Param[8] := '';

                                                  Inc(i);
                                                  skip_spaces;

                                                  TokenAt(NumTok).SourceLocation.Line := line;

                                                  if not (UpCase(d[i]) in AllowLabelFirstChars) then
                                                    Error(NumTok,
                                                      TMessage.Create(TErrorCode.SyntaxError,
                                                      'Syntax error, ''identifier'' expected'));

                                                  repeat

                                                    Inc(Err);

                                                    if Err > MAXPARAMS then
                                                      Error(NumTok,
                                                        TMessage.Create(TErrorCode.TooManyFormalParameters,
                                                        'Too many formal parameters in ' + defineName));

                                                    Param[Err] := GetLabelUpperCase(d, i);

                                                    for x := 1 to Err - 1 do
                                                      if Param[x] = Param[Err] then
                                                        Error(NumTok,
                                                          TMessage.Create(TErrorCode.DuplicateIdentifier,
                                                          'Duplicate identifier ''' + Param[Err] + ''''));

                                                    skip_spaces;

                                                    if d[i] = ',' then
                                                    begin
                                                      Inc(i);
                                                      skip_spaces;

                                                      if not (UpCase(d[i]) in AllowLabelFirstChars) then
                                                        Error(NumTok,
                                                          TMessage.Create(TErrorCode.IdentifierExpected,
                                                          'Syntax error, ''identifier'' expected'));
                                                    end;

                                                  until d[i] = ')';

                                                  Inc(i);
                                                  skip_spaces;

                                                end;


                                                if (d[i] = ':') and (d[i + 1] = '=') then
                                                begin
                                                  Inc(i, 2);

                                                  skip_spaces;

                                                  AddDefine(defineName);    // define macro

                                                  s := copy(d, i, length(d));
                                                  SetLength(s, length(s) - 1);

                                                  Defines[NumDefines].Macro := s;
                                                  Defines[NumDefines].Line := DefineLine;

                                                  if Err > 0 then Defines[NumDefines].Param := Param;

                                                end
                                                else
                                                  AddDefine(defineName);

                                              end
                                              else
                                                if cmd = 'UNDEF' then
                                                begin
                                                  defineName := GetLabelUpperCase(d, i);
                                                  RemoveDefine(defineName);
                                                end
                                                else
                                                  Error(NumTok,
                                                    TMessage.Create(TErrorCode.IllegalCompilerDirective,
                                                    'Illegal compiler directive $' + cmd + d[i]));

      end;

    end;


    procedure ReadSingleLineComment;
    begin

      while (ch <> LF) do
        InFile.Read(ch);

    end;


    procedure ReadChar(var c: Char);
    var
      c2: Char;
      dir: Boolean;
      directive: String;
      _line: Integer;
    begin

      c2 := #0;

      InFile.Read(c);

      if c = '(' then
      begin
        c2 := ' ';
        InFile.Read(c2);

        if c2 = '*' then
        begin        // Skip comments (*   *)

          repeat
            c2 := c;
            InFile.Read(c);

            if c = LF then Inc(Line);
          until (c2 = '*') and (c = ')');

          InFile.Read(c);

        end
        else
          InFile.SeekBack;

      end;


      if c = '{' then
      begin

        dir := False;
        directive := '';

        _line := Line;

        InFile.Read(c2);

        if c2 = '$' then
          dir := True
        else
          InFile.SeekBack;

        repeat            // Skip comments {  } / read directives
          InFile.Read(c);

          if dir then directive := directive + c;

          if c <> '}' then
            if AsmFound then SaveAsmBlock(c);

          if c = LF then Inc(Line);
        until c = '}';

        if dir then ReadDirective(directive, _line);

        InFile.Read(c);

      end
      else
        if c = '/' then
        begin
          InFile.Read(c2);

          if c2 = '/' then
            ReadSingleLineComment
          else
            InFile.SeekBack;

        end;

      if c = LF then Inc(Line);        // Increment current line number
    end;


    function ReadParameters: String;
    var
      OpenParenthesisCount: Integer;
    begin

      Result := '(';
      OpenParenthesisCount := 1;

      while True do
      begin
        ReadChar(ch);

        if ch = LF then Inc(Line);

        if ch = '(' then Inc(OpenParenthesisCount);
        if ch = ')' then Dec(OpenParenthesisCount);

        if not (ch in [CR, LF]) then Result := Result + ch;

        if (length(Result) > 255) or (OpenParenthesisCount = 0) then Break;

      end;

      if ch = ')' then ReadChar(ch);

    end;


    procedure SafeReadChar(var c: Char);
    begin

      ReadChar(c);

      c := UpCase(c);

      if c in [' ', TAB] then Inc(Spaces);

      if not (c in ['''', ' ', '#', '~', '$', TAB, LF, CR, '{', (*'}',*) 'A'..'Z', '_',
        '0'..'9', '=', '.', ',', ';', '(', ')', '*', '/', '+', '-', ':', '>', '<', '^', '@', '[', ']']) then
      begin
        Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter, 'Unexpected unknown character: ' + c));
      end;
    end;


    procedure SkipWhiteSpace;        // 'string' + #xx + 'string'
    begin
      SafeReadChar(ch);

      while ch in AllowWhiteSpaces do SafeReadChar(ch);

      if not (ch in ['''', '#']) then Error(NumTok, TMessage.Create(TErrorCode.SyntaxError,
          'Syntax error, ''string'' expected but ''' + ch + ''' found'));
    end;

    function ReadFractionalPart(var ch: Char): String; overload;
    begin
      Result := '.';
      while ch in ['0'..'9'] do
      begin
        Result := Result + ch;
        SafeReadChar(ch);
      end;

      // Scientific exponent syntax?
      if UpCase(ch) in ['E'] then
      begin
        Result := Result + ch;
        SafeReadChar(ch);

        // Negative exponent or digit
        if ch in ['0'..'9', '-'] then
        begin
          Result := Result + ch;
          SafeReadChar(ch);
        end;

        // More digits
        while ch in ['0'..'9'] do
        begin
          Result := Result + ch;
          SafeReadChar(ch);
        end;
      end;
    end;

    procedure ReadNumber;
    begin

      if ch = '%' then
      begin      // binary number

        SafeReadChar(ch);

        while ch in ['0', '1'] do
        begin
          Num := Num + ch;
          SafeReadChar(ch);
        end;

        if length(Num) = 0 then
          ErrorOrdinalExpExpected(NumTok);

        Num := '%' + Num;

      end
      else

        if ch = '$' then
        begin // Hexadecimal number

          SafeReadChar(ch);

          while ch in AllowDigitChars do
          begin
            Num := Num + ch;
            SafeReadChar(ch);
          end;

          if length(Num) = 0 then
            ErrorOrdinalExpExpected(NumTok);

          Num := '$' + Num;

        end
        else

          while ch in ['0'..'9'] do    // Number expected
          begin
            Num := Num + ch;
            SafeReadChar(ch);
          end;

    end;

  var
    token: TToken;
  begin

    inFile := TFileSystem.CreateBinaryFile(SCANNER_CACHED);
    inFile.Assign(filePath);
    inFile.Reset(1);

    TextBuffer := TTextBuffer.Create(Target.ID);
    ch := ' ';

    try
      while True do
      begin
        OldNumTok := NumTok;

        // Skip space, tab, line feed, carriage return, comment braces
        repeat
          ReadChar(ch);

          if ch in [' ', TAB] then Inc(Spaces);

        until not (ch in [' ', TAB, LF, CR, '{'(*, '}'*)]);

        ch := UpCase(ch);

        Num := '';
        if ch in ['0'..'9', '$', '%'] then ReadNumber;

        if Length(Num) > 0 then      // Number found
        begin
          token := AddToken(TTokenKind.INTNUMBERTOK, ActiveSourceFile, Line, length(Num) + Spaces, StrToInt(Num));
          Spaces := 0;

          if ch = '.' then      // Fractional part expected
          begin
            SafeReadChar(ch);
            if ch = '.' then
              InFile.SeekBack   // Range ('..') token
            else
            begin        // Fractional part found
              Frac := ReadFractionalPart(ch);

              if length(Num) > 17 then
                Token.MakeFracNumber(0)
              else
                Token.MakeFracNumber(StrToFloat(Num + Frac));

              Token.SourceLocation.Column :=
                TokenAt(NumTok - 1).SourceLocation.Column + length(Num) + length(Frac) + Spaces;
              Spaces := 0;
            end;
          end;

          Num := '';
          Frac := '';
        end;


        if ch in ['A'..'Z', '_'] then    // Keyword or identifier expected
        begin
          TextBuffer.Clear;

          err := 0;
          repeat
            TextBuffer.Append(ch);
            ch2 := ch;
            SafeReadChar(ch);

            if (ch = '.') and (ch2 = '.') then
            begin
              ch := #0;
              Break;
            end;

            Inc(err);
          until not (ch in ['A'..'Z', '_', '0'..'9', '.']);

          if TextBuffer.EndsWith('.') then
          begin
            TextBuffer.DeleteLastChar;
            InFile.Seek2(InFile.FilePos() - 2);
            Dec(err);
          end;

          if err > 255 then
            Error(NumTok, TMessage.Create(TErrorCode.ConstantStringTooLong,
              'Constant strings can''t be longer than 255 chars'));

          if TextBuffer.Length() > 0 then
          begin

            CurToken := GetStandardToken(TextBuffer.GetString);

            im := SearchDefine(TextBuffer.GetString);

            if (im > 0) and (Defines[im].Macro <> '') then
            begin

              tmp := InFile.FilePos();
              ch2 := ch;
              Num := '';      // Read parameters, max 255 chars

              if Defines[im].Param[1] <> '' then
              begin
                while ch in AllowWhiteSpaces do ReadChar(ch);
                if ch = '(' then Num := ReadParameters;
              end;

              SetLength(StrParams, 1);
              StrParams[0] := '';

              TokenAt(NumTok).SourceLocation.Line := Line;

              if Num = '' then
              begin
                InFile.Seek2(tmp);
                ch := ch2;
              end
              else
              begin
                StrParams := SplitStr(copy(Num, 2, length(Num) - 2), ',');

                if High(StrParams) > MAXPARAMS then
                  Error(NumTok, TMessage.Create(TErrorCode.TooManyFormalParameters,
                    'Too many formal parameters in ' + TextBuffer.GetString()));

              end;

              if (StrParams[0] <> '') and (Defines[im].Param[1] = '') then
                Error(NumTok, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters'));


              OldNumDefines := NumDefines;

              Err := 1;

              while (Defines[im].Param[Err] <> '') and (Err <= MAXPARAMS) do
              begin

                if StrParams[Err - 1] = '' then
                  Error(NumTok, TMessage.Create(TErrorCode.ParameterMissing, 'Parameter missing'));

                AddDefine(Defines[im].Param[Err]);
                Defines[NumDefines].Macro := StrParams[Err - 1];
                Defines[NumDefines].Line := Line;

                Inc(Err);
              end;


              TokenizeMacro(Defines[im].Macro, Defines[im].Line, 0);

              NumDefines := OldNumDefines;

              CurToken := TTokenKind.MACRORELEASE;
            end
            else
            begin

              if CurToken = TTokenKind.TEXTTOK then CurToken := TTokenKind.TEXTFILETOK;
              if CurToken = TTokenKind.FLOATTOK then CurToken := TTokenKind.SINGLETOK;
              if CurToken = TTokenKind.FLOAT16TOK then CurToken := TTokenKind.HALFSINGLETOK;
              if CurToken = TTokenKind.SHORTSTRINGTOK then CurToken := TTokenKind.STRINGTOK;

              if CurToken = TTokenKind.EXTERNALTOK then ExternalFound := True;

              AddToken(TTokenKind.UNTYPETOK, ActiveSourceFile, Line, TextBuffer.Length + Spaces, 0);
              Spaces := 0;

            end;


            if CurToken = TTokenKind.ASMTOK then
            begin

              TokenAt(NumTok).MakeKind(CurToken);
              TokenAt(NumTok).SetIntegerValue(0);

              tmp := InFile.FilePos();

              _line := line;

              // Skip whitespace characters and check which character we encounter.
              repeat
                InFile.Read(ch);
                if ch = LF then Inc(line);
              until not (ch in AllowWhiteSpaces);


              if ch <> '{' then
              begin      // '{' not found

                line := _line; // Start reading again after 'ASM'

                TokenAt(NumTok).SetIntegerValue(1);

                InFile.Seek2(tmp - 1);

                InFile.Read(ch);

                AsmBlock[AsmBlockIndex] := '';
                TextBuffer.Clear;

                while True do
                begin
                  InFile.Read(ch);

                  SaveAsmBlock(ch);

                  TextBuffer.Append(UpCase(ch));

                  if pos('END;', TextBuffer.GetString()) > 0 then
                  begin
                    SetLength(AsmBlock[AsmBlockIndex], length(AsmBlock[AsmBlockIndex]) - 4);
                    Break;
                  end;

                  if ch in [CR, LF] then
                  begin
                    if ch = LF then Inc(line);
                    TextBuffer.Clear;
                  end;

                end;

              end
              else
              begin

                InFile.SeekBack;

                AsmFound := True;

                repeat
                  ReadChar(ch);

                  if ch in [' ', TAB] then Inc(Spaces);

                until not (ch in [' ', TAB, LF, CR, '{', '}']);
                // Skip space, tab, line feed, carriage return, comment braces

                AsmFound := False;

              end;

              Inc(AsmBlockIndex);

              if AsmBlockIndex > High(AsmBlock) then
              begin
                Error(NumTok, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, ASMBLOCK'));
                RaiseHaltException(EHaltException.COMPILING_ABORTED);
              end;

            end
            else
            begin

              if CurToken <> TTokenKind.MACRORELEASE then

                if CurToken <> TTokenKind.UNTYPETOK then
                begin // Keyword found
                  TokenAt(NumTok).MakeKind(CurToken);

                  if CurToken = TTokenKind.USESTOK then UsesFound := True;

                  if CurToken = TTokenKind.UNITTOK then UnitFound := True;

                  if TestSourceFile and (UnitFound = False) then
                    Error(NumTok, TMessage.Create(TErrorCode.UnitExpected, '"UNIT" expected but "' +
                      GetTokenSpelling(CurToken) + '" found'));

                end
                else
                begin // Identifier found
                  TokenAt(NumTok).MakeIdentifier(TextBuffer.GetString());
                  // if TextBuffer.GetString() = 'RIJNDAEL' then
                  // begin
                  //   WriteLn('INFO: Identifier found ' + TextBuffer.GetString());
                  // end;
                end;

            end;

            TextBuffer.Clear;
          end;

        end;


        if ch in ['''', '#'] then
        begin

          TextBuffer.Clear;
          yes := True;

          repeat

            case ch of

              '''': begin

                if yes then
                begin
                  TextPos := TextBuffer.Length() + 1;
                  yes := False;
                end;

                Inc(Spaces);

                repeat
                  InFile.Read(ch);

                  if ch = LF then
                    Error(NumTok, TMessage.Create(TErrorCode.StringExceedsLine, 'String exceeds line'));

                  if not (ch in ['''', CR, LF]) then
                    TextBuffer.Append(ch)
                  else
                  begin

                    InFile.Read(ch2);

                    if ch2 = '''' then
                    begin
                      TextBuffer.Append('''');
                      ch := #0;
                    end
                    else
                      InFile.SeekBack;

                  end;

                until ch = '''';

                Inc(Spaces);

                SafeReadChar(ch);

                if ch in [' ', TAB] then
                begin
                  ch2 := ch;
                  Err := InFile.FilePos();
                  while ch2 in [' ', TAB] do InFile.Read(ch2);

                  if ch2 in ['*', '~', '+'] then
                    ch := ch2
                  else
                    InFile.Seek2(Err);
                end;


                if ch = '*' then
                begin
                  Inc(Spaces);
                  TextBuffer.ToInverse(TextPos);
                  SafeReadChar(ch);
                end;

                if ch = '~' then
                begin
                  Inc(Spaces);
                  TextBuffer.ToInternal(TextPos);
                  SafeReadChar(ch);

                  if ch = '*' then
                  begin
                    Inc(Spaces);
                    TextBuffer.ToInverse(TextPos);
                    SafeReadChar(ch);
                  end;

                end;


                if ch in [' ', TAB] then
                begin
                  ch2 := ch;
                  Err := InFile.FilePos();
                  while ch2 in [' ', TAB] do InFile.Read(ch2);

                  if ch2 in ['''', '+'] then
                    ch := ch2
                  else
                    InFile.Seek2(Err);
                end;


                if ch = '+' then
                begin
                  yes := True;
                  Inc(Spaces);
                  SkipWhiteSpace;
                end;

              end;

              '#': begin
                SafeReadChar(ch);

                Num := '';
                ReadNumber;

                if Length(Num) > 0 then
                  TextBuffer.Append(chr(StrToInt(Num)))
                else
                  Error(NumTok, TMessage.Create(TErrorCode.ConstantExpressionExpected,
                    'Constant expression expected'));

                if ch in [' ', TAB] then
                begin
                  ch2 := ch;
                  Err := InFile.FilePos();
                  while ch2 in [' ', TAB] do InFile.Read(ch2);

                  if ch2 in ['''', '+'] then
                    ch := ch2
                  else
                    InFile.Seek2(Err);
                end;

                if ch = '+' then
                begin
                  Inc(Spaces);
                  SkipWhiteSpace;
                end;

              end;
            end;

          until not (ch in ['#', '''']);

          case ch of
            '*': // Inverse
            begin
              TextBuffer.ToInverse(TextPos);
              SafeReadChar(ch);
            end;
            '~': // Internal
            begin
              TextBuffer.ToInternal(TextPos);
              SafeReadChar(ch);
            end;
          end;

          if TextBuffer.Length() = 1 then
          begin
            AddToken(TTokenKind.CHARLITERALTOK, ActiveSourceFile, Line, 1 + Spaces, Ord(TextBuffer.CharAt(1)));
            Spaces := 0;
          end
          else
          begin
            AddToken(TTokenKind.STRINGLITERALTOK, ActiveSourceFile, Line, TextBuffer.Length() + Spaces, 0);
            Spaces := 0;

            if ExternalFound then
              DefineFilename(NumTok, TextBuffer.GetString())
            else
              DefineStaticString(NumTok, TextBuffer.GetString());

          end;

          TextBuffer.Clear;

        end;


        if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then
        begin
          AddToken(GetStandardToken(ch), ActiveSourceFile, Line, 1 + Spaces, 0);
          Spaces := 0;

          ExternalFound := False;

          if UsesFound and (ch = ';') then
            if UsesOn then ReadUses;
        end;


        //      if ch in ['?','!','&','\','|','_','#'] then
        //  AddToken(UNKNOWNIDENTTOK, ActiveSourceFile, Line, 1, ord(ch));


        if ch in [':', '>', '<', '.'] then          // Double-character token expected
        begin
          ch_ := ch;

          Line2 := Line;
          SafeReadChar(ch2);

          ch := ch_;

          if (ch2 = '=') or ((ch = '<') and (ch2 = '>')) or ((ch = '.') and (ch2 = '.')) then
          begin        // Double-character token found
            AddToken(GetStandardToken(ch + ch2), ActiveSourceFile, Line, 2 + Spaces, 0);
            Spaces := 0;
          end
          else
            if (ch = '.') and (ch2 in ['0'..'9']) then
            begin  // Fractional part found

              token := AddToken(TTokenKind.INTNUMBERTOK, ActiveSourceFile, Line, 0, 0);

              Frac := ReadFractionalPart(ch2);

              token.MakeFracNumber(StrToFloat('0' + Frac));
              token.SourceLocation.Column :=
                TokenAt(NumTok - 1).SourceLocation.Column + length(Frac) + Spaces;
              Spaces := 0;

              Frac := '';

              InFile.SeekBack;

            end
            else
            begin
              InFile.SeekBack;
              Line := Line2;

              if ch in [':', '>', '<', '.'] then
              begin        // Single-character token found
                AddToken(GetStandardToken(ch), ActiveSourceFile, Line, 1 + Spaces, 0);
                Spaces := 0;
              end
              else
              begin
                Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter,
                  'Unexpected character ''{0}'' found. Expected one of ''{1}.''', ch, ':><.'));
              end;
            end;
        end;


        if NumTok = OldNumTok then   // No token found
        begin
          Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter,
            'Illegal character ''{0}'' (${1}) found.', ch, IntToHex(Ord(ch), 2)));
        end;

      end;// while

    except
      on e: EHaltException do
      begin
        RaiseHaltException(e.GetExitCode());
      end;
      on e: EInOutError do
      begin // EOF reached
        // if e.ErrorCode > 0 then  // TODO: Distinguish EOF from other EInOutError by their ErrorCode,. not by TextBuffer.Length()
        // begin
        if TextBuffer.Length > 0 then
        begin
          if TextBuffer.GetString() = 'END.' then
          begin
            AddToken(TTokenKind.ENDTOK, ActiveSourceFile, Line, 3, 0);
            AddToken(TTokenKind.DOTTOK, ActiveSourceFile, Line, 1, 0);
          end
          else
          begin
            AddToken(GetStandardToken(TextBuffer.GetString()), ActiveSourceFile, Line,
              TextBuffer.Length() + Spaces, 0);
            Spaces := 0;
          end;
        end;
      end;
      //else
      // begin
      //   WriteLn('ERROR: EInOutError ' + e.message);
      //   RaiseHaltException(-1);
      //  end;
      //end;
    end;// try
    InFile.Close;
  end;


  procedure TokenizeUnit(const SourceFile: TSourceFile; const TestSourceFile: Boolean = False);
  // Read input file and get tokens
  var
    endLine: Integer;
  begin

    ActiveSourceFile := SourceFile;

    Line := 1;
    Spaces := 0;

    // TODO: Rather check unit type=UNIT_FILE?
    if ActiveSourceFile.UnitIndex > 1 then AddToken(TTokenKind.UNITBEGINTOK, ActiveSourceFile, Line, 0, 0);

    //  writeln('>',ActiveSourceFile,',',ActiveSourceFile.Name);

    UnitFound := False;

    Tokenize(ActiveSourceFile.Path, TestSourceFile);

    if ActiveSourceFile.UnitIndex > 1 then
    begin

      CheckTok(NumTok, TTokenKind.DOTTOK);
      CheckTok(NumTok - 1, TTokenKind.ENDTOK);
      EndLine := TokenAt(NumTok - 1).SourceLocation.Line;
      tokenList.RemoveToken;
      tokenList.RemoveToken;

      AddToken(TTokenKind.UNITENDTOK, ActiveSourceFile, EndLine - 1, 0, 0);
    end
    else
      AddToken(TTokenKind.EOFTOK, ActiveSourceFile, Line, 0, 0);

  end;

begin
  AsmFound := False;
  UsesFound := False;
  UnitFound := False;
  ExternalFound := False;

  TokenizeProgramInitialization(programUnit);

  if UsesOn then
    TokenizeUnit(programUnit)     // main program file
  else
    for cnt := SourceFileList.Size downto 1 do
      if SourceFileList.GetSourceFile(cnt).IsRelevant then
        TokenizeUnit(SourceFileList.GetSourceFile(cnt));

end;  // TokenizeProgram


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function ReadFractionalPart(const a: String; var i: Integer; ch: Char): String; overload;
begin
  Result := '.';

  begin
    Result := '.';
    while UpCase(ch) in ['0'..'9'] do
    begin
      Result := Result + ch;
      ch := a[i];
      Inc(i);
    end;

    // Scientific exponent syntax?
    if UpCase(ch) in ['E'] then
    begin
      Result := Result + ch;
      ch := a[i];
      Inc(i);

      // Negative exponent or digit
      if UpCase(ch) in ['0'..'9', '-'] then
      begin
        Result := Result + ch;
        ch := a[i];
        Inc(i);
      end;

      // More digits
      while UpCase(ch) in ['0'..'9'] do
      begin
        Result := Result + ch;
        ch := a[i];
        Inc(i);
      end;
    end;
  end;
end;

procedure TScanner.TokenizeMacro(a: String; Line, Spaces: Integer);
var
  i: Integer;
  TextBuffer: ITextBuffer;
  Num, Frac: TString;
  Err, Line2, TextPos, im: Integer;
  yes: Boolean;
  ch, ch2: Char;
  CurToken: TTokenKind;


  procedure SkipWhiteSpace;        // 'string' + #xx + 'string'
  begin
    ch := a[i];
    Inc(i);

    while ch in AllowWhiteSpaces do
    begin
      ch := a[i];
      Inc(i);
    end;

    if not (ch in ['''', '#']) then Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter,
        'Syntax error, ''string'' expected but ''' + ch + ''' found'));
  end;

  procedure ReadNumber;
  begin

    //    Num:='';

    if ch = '%' then
    begin      // binary

      ch := a[i];
      Inc(i);

      while ch in ['0', '1'] do
      begin
        Num := Num + ch;
        ch := a[i];
        Inc(i);
      end;

      if length(Num) = 0 then
        ErrorOrdinalExpExpected(NumTok);

      Num := '%' + Num;

    end
    else

      if ch = '$' then
      begin      // hexadecimal

        ch := a[i];
        Inc(i);

        while UpCase(ch) in AllowDigitChars do
        begin
          Num := Num + ch;
          ch := a[i];
          Inc(i);
        end;

        if length(Num) = 0 then
          ErrorOrdinalExpExpected(NumTok);

        Num := '$' + Num;

      end
      else

        while ch in ['0'..'9'] do    // Number expected
        begin
          Num := Num + ch;
          ch := a[i];
          Inc(i);
        end;

  end;

var
  Token: TToken;
  // TokenizeMacro
begin

  TextBuffer := TTextBuffer.Create(Target.ID);

  TextPos := 0;
  i := 1;

  while i <= length(a) do
  begin

    while (i <= length(a)) and (a[i] in AllowWhiteSpaces) do
    begin

      if a[i] = LF then
      begin
        Inc(Line);
        Spaces := 0;
      end
      else
      begin
        Inc(Spaces);
      end;

      Inc(i);
    end;

    if i <= length(a) then
    begin

      ch := UpCase(a[i]);
      Inc(i);


      Num := '';
      if ch in ['0'..'9', '$', '%'] then ReadNumber;

      if Length(Num) > 0 then      // Number found
      begin
        token := AddMacroToken(TTokenKind.INTNUMBERTOK, Line, length(Num) + Spaces, StrToInt(Num));
        Spaces := 0;

        if ch = '.' then      // Fractional part expected
        begin

          ch := a[i];
          Inc(i);

          if ch = '.' then
            Dec(i)        // Range ('..') token
          else
          begin        // Fractional part found
            Frac := ReadFractionalPart(a, i, ch);

            token.MakeFracNumber(StrToFloat(Num + Frac));
            token.SourceLocation.Column :=
              TokenAt(NumTok - 1).SourceLocation.Column + length(Num) + length(Frac) + Spaces;
            Spaces := 0;
          end;
        end;

        Num := '';
        Frac := '';
      end;


      if ch in ['A'..'Z', '_'] then    // Keyword or identifier expected
      begin

        TextBuffer.Clear;

        err := 0;

        TextPos := i - 1;

        while ch in ['A'..'Z', '_', '0'..'9', '.'] do
        begin
          TextBuffer.Append(ch);
          Inc(err);

          ch := UpCase(a[i]);
          Inc(i);
        end;


        if err > 255 then
          Error(NumTok, TMessage.Create(TErrorCode.ConstantStringTooLong,
            'Constant strings can''t be longer than 255 chars'));

        if TextBuffer.Length() > 0 then
        begin

          CurToken := GetStandardToken(TextBuffer.GetString());

          im := SearchDefine(TextBuffer.GetString());

          if (im > 0) and (Defines[im].Macro <> '') then
          begin

            ch := #0;

            i := TextPos;

            if Defines[im].Macro = copy(a, i, TextBuffer.Length) then
              Error(NumTok, TMessage.Create(TErrorCode.RecursionInMacro, 'Recursion in macros is not allowed'));

            Delete(a, i, TextBuffer.Length);
            insert(Defines[im].Macro, a, i);

            CurToken := TTokenKind.MACRORELEASE;

          end
          else
          begin

            if CurToken = TTokenKind.TEXTTOK then CurToken := TTokenKind.TEXTFILETOK;
            if CurToken = TTokenKind.FLOATTOK then CurToken := TTokenKind.SINGLETOK;
            if CurToken = TTokenKind.FLOAT16TOK then CurToken := TTokenKind.HALFSINGLETOK;
            if CurToken = TTokenKind.SHORTSTRINGTOK then CurToken := TTokenKind.STRINGTOK;

            AddMacroToken(TTokenKind.UNTYPETOK, Line, TextBuffer.Length + Spaces, 0);
            Spaces := 0;

          end;

          if CurToken <> TTokenKind.MACRORELEASE then

            if CurToken <> TTokenKind.UNTYPETOK then
            begin // Keyword found

              TokenAt(NumTok).MakeKind(CurToken);

            end
            else
            begin // Identifier found
              TokenAt(NumTok).MakeIdentifier(TextBuffer.GetString());
            end;

        end;

        TextBuffer.Clear;
      end;


      if ch in ['''', '#'] then
      begin

        TextBuffer.Clear;
        ;
        yes := True;

        repeat

          case ch of

            '''': begin

              if yes then
              begin
                TextPos := TextBuffer.Length() + 1;
                yes := False;
              end;

              Inc(Spaces);

              repeat
                ch := a[i];
                Inc(i);

                if ch = LF then
                  Error(NumTok, TMessage.Create(TErrorCode.StringExceedsLine, 'String exceeds line'));

                if not (ch in ['''', CR, LF]) then
                  TextBuffer.Append(ch)
                else
                begin

                  ch2 := a[i];
                  Inc(i);

                  if ch2 = '''' then
                  begin
                    TextBuffer.Append('''');
                    ch := #0;
                  end
                  else
                    Dec(i);

                end;

              until ch = '''';

              Inc(Spaces);

              ch := a[i];
              Inc(i);

              if ch in [' ', TAB] then
              begin
                ch2 := ch;
                Err := i;
                while ch2 in [' ', TAB] do
                begin
                  ch2 := a[i];
                  Inc(i);
                end;

                if ch2 in ['*', '~', '+'] then
                  ch := ch2
                else
                  i := Err;
              end;


              if ch = '*' then
              begin
                Inc(Spaces);
                TextBuffer.ToInverse(TextPos);
                ch := a[i];
                Inc(i);
              end;

              if ch = '~' then
              begin
                Inc(Spaces);
                TextBuffer.ToInternal(TextPos);
                ch := a[i];
                Inc(i);

                if ch = '*' then
                begin
                  Inc(Spaces);
                  TextBuffer.ToInverse(TextPos);
                  ch := a[i];
                  Inc(i);
                end;

              end;

              if ch in [' ', TAB] then
              begin
                ch2 := ch;
                Err := i;
                while ch2 in [' ', TAB] do
                begin
                  ch2 := a[i];
                  Inc(i);
                end;

                if ch2 in ['''', '+'] then
                  ch := ch2
                else
                  i := Err;
              end;


              if ch = '+' then
              begin
                yes := True;
                Inc(Spaces);
                SkipWhiteSpace;
              end;

            end;

            '#': begin
              ch := a[i];
              Inc(i);

              Num := '';
              ReadNumber;

              if Length(Num) > 0 then
                TextBuffer.Append(chr(StrToInt(Num)))
              else
                Error(NumTok, TMessage.Create(TErrorCode.ConstantExpressionExpected, 'Constant expression expected'));

              if ch in [' ', TAB] then
              begin
                ch2 := ch;
                Err := i;
                while ch2 in [' ', TAB] do
                begin
                  ch2 := a[i];
                  Inc(i);
                end;

                if ch2 in ['''', '+'] then
                  ch := ch2
                else
                  i := Err;
              end;

              if ch = '+' then
              begin
                Inc(Spaces);
                SkipWhiteSpace;
              end;

            end;
          end;

        until not (ch in ['#', '''']);

        case ch of
          '*': begin
            TextBuffer.ToInverse(TextPos);
            ch := a[i];
            Inc(i);
          end;      // Inverse
          '~': begin
            TextBuffer.ToInternal(TextPos);
            ch := a[i];
            Inc(i);
          end;    // Internal
        end;

        if TextBuffer.Length() = 1 then
        begin
          AddMacroToken(TTokenKind.CHARLITERALTOK, Line, 1 + Spaces, Ord(TextBuffer.CharAt(1)));
          Spaces := 0;
        end
        else
        begin
          AddMacroToken(TTokenKind.STRINGLITERALTOK, Line, TextBuffer.Length() + Spaces, 0);
          Spaces := 0;
          DefineStaticString(NumTok, TextBuffer.GetString());
        end;

        TextBuffer.Clear;

      end;


      if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then
      begin
        AddMacroToken(GetStandardToken(ch), Line, 1 + Spaces, 0);
        Spaces := 0;
      end;


      if ch in [':', '>', '<', '.'] then // Double-character token expected
      begin

        Line2 := Line;

        ch2 := a[i];
        Inc(i);

        if (ch2 = '=') or ((ch = '<') and (ch2 = '>')) or ((ch = '.') and (ch2 = '.')) then
        begin // Double-character token found
          AddMacroToken(GetStandardToken(ch + ch2), Line, 2 + Spaces, 0);
          Spaces := 0;
        end
        else
          if (ch = '.') and (ch2 in ['0'..'9']) then
          begin

            Token := AddMacroToken(TTokenKind.INTNUMBERTOK, Line, 0, 0);
            Frac := ReadFractionalPart(a, i, ch2);

            Token.MakeFracNumber(StrToFloat('0' + Frac));
            Token.SourceLocation.Column := TokenAt(NumTok - 1).SourceLocation.Column + length(Frac) + Spaces;
            Spaces := 0;

            Frac := '';

            Dec(i);

          end
          else
          begin
            Dec(i);
            Line := Line2;

            if ch in [':', '>', '<', '.'] then
            begin        // Single-character token found
              AddMacroToken(GetStandardToken(ch), Line, 1 + Spaces, 0);
              Spaces := 0;
            end;

          end;
      end;
    end;

  end;

end;  // TokenizeMacro


end.
