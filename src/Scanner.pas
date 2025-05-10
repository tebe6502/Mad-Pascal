unit Scanner;

{$I Defines.inc}

interface

uses CommonTypes, CompilerTypes, Tokens;

// ----------------------------------------------------------------------------

type
  IScanner = interface

    procedure TokenizeProgram(UsesOn: Boolean);

    // This is only public for for testing. Idea: Put token array into a ITokenList, so it can be tested independently of the whole scanner
    procedure AddToken(Kind: TTokenKind; UnitIndex, Line, Column: Integer; Value: TInteger);

  end;

type
  TScanner = class(TInterfacedObject, IScanner)

    procedure TokenizeProgram(UsesOn: Boolean);
    procedure AddToken(Kind: TTokenKind; UnitIndex, Line, Column: Integer; Value: TInteger);

  private
    procedure TokenizeMacro(a: String; Line, Spaces: Integer);
  end;

implementation

uses Classes, SysUtils, Common, Datatypes, Messages, FileIO, Memory, Optimize, StringUtilities, Targets, Utilities;

// ----------------------------------------------------------------------------
// Class TScanner Implementation
// ----------------------------------------------------------------------------

procedure ErrorOrdinalExpExpected(i: TTokenIndex);
begin
  Error(i, TMessage.Create(TErrorCode.OrdinalExpExpected, 'Ordinal expression expected.'));
end;

procedure TokenizeProgramInitialization;
var
  i: Integer;
begin

  NumIdent := 0;
  for i := Low(Ident) to High(Ident) do
  begin
    Ident[i] := Default(TIdentifier);
  end;

  tokenList.Clear;
  ClearWordMemory(DataSegment);
  ClearWordMemory(StaticStringData);

  FastMul := -1;
  DataSegmentUse := False;
  LoopUnroll := False;
  PublicSection := True;
  UnitNameIndex := 1; // TODO This is the current unit index

  SetLength(linkObj, 1);
  SetLength(resArray, 1);
  msgLists.msgUser := TStringList.Create;
  msgLists.msgWarning := TStringList.Create;
  msgLists.msgNote := TStringList.Create;

  NumBlocks := 0;
  BlockStackTop := 0;
  CodeSize := 0;
  CodePosStackTop := 0;
  VarDataSize := 0;
  CaseCnt := 0;
  IfCnt := 0;
  ShrShlCnt := 0;
  NumTypes := 0;
  run_func := 0;
  NumProc := 0;

  NumStaticStrChars := 0;

  IfdefLevel := 0;
  AsmBlockIndex := 0;

  NumDefines := AddDefines;

  ResetOpty;

  for i := 0 to High(AsmBlock) do AsmBlock[i] := '';

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure AddResource(fnam: String);
var
  i, j: Integer;
  t: ITextFile;
  res: TResource;
  s, tmp: String;
begin

  t := TFileSystem.CreateTextFile;
  t.Assign(fnam);
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

        if (res.resType = 'RCDATA') or (res.resType = 'RCASM') or (res.resType = 'DOSFILE') or
          (res.resType = 'RELOC') or (res.resType = 'RMT') or (res.resType = 'MPT') or
          (res.resType = 'CMC') or (res.resType = 'RMTPLAY') or (res.resType = 'RMTPLAY2') or
          (res.resType = 'RMTPLAYV') or (res.resType = 'MPTPLAY') or (res.resType = 'CMCPLAY') or
          (res.resType = 'EXTMEM') or (res.resType = 'XBMP') or (res.resType = 'SAPR') or
          (res.resType = 'SAPRPLAY') or (res.resType = 'PP') or (res.resType = 'LIBRARY') then

        else
          Error(NumTok, TMessage.Create(TErrorCode.UndefinedResourceType,
            'Undefined resource type: Type = ''' + res.resType + ''', Name = ''' + res.resName + ''''));


        if (res.resFile <> '') and (unitPathList.FindFile(res.resFile) = '') then
          Error(NumTok, TMessage.Create(TErrorCode.ResourceFileNotFound, 'Resource file not found: Type = ' +
            res.resType + ', Name = ''' + res.resName + ''' in unit path ''' + unitPathList.ToString + ''''));

        for j := 1 to MAXPARAMS do
        begin

          if s[i] in ['''', '"'] then
            tmp := GetStringUpperCase(s, i)
          else
            tmp := GetNumber(s, i);

          if tmp = '' then tmp := '0';

          res.resPar[j] := tmp;
        end;

        // WriteLn(res.resName,',',res.resType,',',res.resFile);

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


procedure TScanner.AddToken(Kind: TTokenKind; UnitIndex, Line, Column: Integer; Value: TInteger);
begin
  tokenList.AddToken(kind, UnitIndex, line, Column, Value);
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveAsmBlock(a: Char);
begin

  AsmBlock[AsmBlockIndex] := AsmBlock[AsmBlockIndex] + a;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TScanner.TokenizeProgram(UsesOn: Boolean);
var
  Text: String;
  Num, Frac: TString;
  OldNumTok, UnitIndex, IncludeIndex, Line, Err, cnt, Line2, Spaces, TextPos, im, OldNumDefines: Integer;
  Tmp: Int64;
  AsmFound, UsesFound, UnitFound, ExternalFound, yes: Boolean;
  ch, ch2, ch_: Char;
  CurToken: TTokenKind;
  StrParams: TStringArray;


  procedure TokenizeUnit(a: Integer; testUnit: Boolean = False); forward;


  procedure Tokenize(fnam: String; testUnit: Boolean = False);
  var
    InFile: IBinaryFile;
    _line: Integer;
    _uidx: Integer;


    procedure ReadUses;
    var
      i, j, k: Integer;
      _line: Integer;
      _uidx: Integer;
      s, nam: String;
    begin

      UsesFound := False;

      i := NumTok - 1;


      while Tok[i].Kind <> TTokenKind.USESTOK do
      begin

        if Tok[i].Kind = TTokenKind.STRINGLITERALTOK then
        begin

          CheckTok(i - 1, TTokenKind.INTOK);
          CheckTok(i - 2, TTokenKind.IDENTTOK);

          nam := '';

          for k := 1 to Tok[i].StrLength do
            nam := nam + chr(StaticStringData[Tok[i].StrAddress - CODEORIGIN + k]);

          nam := FindFile(nam, 'unit');

          Dec(i, 2);

        end
        else
        begin

          CheckTok(i, TTokenKind.IDENTTOK);

          nam := FindFile(Tok[i].Name + '.pas', 'unit');

        end;


        s := AnsiUpperCase(Tok[i].Name);


        // We clear earlier usage
        for j := 2 to NumUnits do
        begin
          if GetUnitName(j) = s then UnitList.UnitArray[j].Name := '';
        end;

        _line := Line;
        _uidx := UnitIndex;

        // TODO
        UnitIndex := NumUnits+1;

        if UnitIndex > High(UnitList.UnitArray) then
        begin
          Error(NumTok, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, UnitIndex: ' +
            IntToStr(UnitIndex)));
        end;

        Line := 1;
        UnitList.AddUnit(s,nam);

        TokenizeUnit(UnitIndex, True);

        Line := _line;
        UnitIndex := _uidx;

        if Tok[i - 1].Kind = TTokenKind.COMMATOK then
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


    procedure ReadDirective(d: String; DefineLine: Integer);
    var
      i, v, x: Integer;
      cmd, s, nam: String;
      found: Boolean;
      Param: TDefineParams;


      procedure bin2csv(fn: String);
      var
        bin: IBinaryFile;
        tmp: Byte;
        NumRead: Integer;
        yes: Boolean;
      begin

        yes := False;

        tmp := 0;
        NumRead := 0;
        bin := TFileSystem.CreateBinaryFile;
        bin.Assign(fn);
        bin.Reset(1);

        repeat
          bin.BlockRead(tmp, 1, NumRead);

          if NumRead = 1 then
          begin

            if yes then AddToken(GetStandardToken(','), UnitIndex, Line, 1, 0);

            AddToken(TTokenKind.INTNUMBERTOK, UnitIndex, Line, 1, tmp);

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


      procedure newMsgUser(Kind: TTokenKind);
      var
        k: Integer;
      begin

        k := msgLists.msgUser.Count;

        AddToken(Kind, UnitIndex, Line, 1, k);
        AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

        SkipWhitespaces(d, i);

        msgLists.msgUser.Add( copy(d, i, length(d) - i));

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
                    begin          // {$i filename}
                      // {$i+-} iocheck
                      if d[i] = '+' then
                      begin
                        AddToken(TTokenKind.IOCHECKON, UnitIndex, Line, 1, 0);
                        AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);
                      end
                      else
                        if d[i] = '-' then
                        begin
                          AddToken(TTokenKind.IOCHECKOFF, UnitIndex, Line, 1, 0);
                          AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);
                        end
                        else
                        begin
                          //   AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

                          s := GetString(d, False, i);        // don't change the case, it could be a file path

                          if AnsiUpperCase(s) = '%TIME%' then
                          begin

                            s := TimeToStr(Now);

                            AddToken(TTokenKind.STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0);
                            Spaces := 0;
                            DefineStaticString(NumTok, s);

                          end
                          else
                            if AnsiUpperCase(s) = '%DATE%' then
                            begin

                              s := DateToStr(Now);

                              AddToken(TTokenKind.STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0);
                              Spaces := 0;
                              DefineStaticString(NumTok, s);

                            end
                            else
                            begin

                              nam := FindFile(s, 'include');

                              _line := Line;
                              _uidx := UnitIndex;

                              Line := 1;
                              UnitList.UnitArray[IncludeIndex].Name := ExtractFileName(nam);
                              UnitList.UnitArray[IncludeIndex].Path := nam;
                              UnitIndex := IncludeIndex;
                              Inc(IncludeIndex);

                              if IncludeIndex > High(UnitList.UnitArray) then
                                Error(NumTok, TMessage.Create(TErrorCode.OutOfResources,
                                  'Out of resources, IncludeIndex: ' + IntToStr(IncludeIndex)));

                              Tokenize(nam);

                              Line := _line;
                              UnitIndex := _uidx;

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

                        AddToken(TTokenKind.EVALTOK, UnitIndex, Line, 1, 0);

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

                            if s = 'LOOPUNROLL' then AddToken(TTokenKind.LOOPUNROLLTOK, UnitIndex, Line, 1, 0)
                            else
                              if s = 'NOLOOPUNROLL' then AddToken(TTokenKind.NOLOOPUNROLLTOK, UnitIndex, Line, 1, 0)
                              else
                                Error(NumTok, TMessage.Create(TErrorCode.IllegalOptimizationSpecified,
                                  'Illegal optimization specified "' + s + '"'));

                            AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                          end
                          else

                            if (cmd = 'CODEALIGN') then
                            begin

                              s := GetStringUpperCase(d, i);

                              if s = 'PROC' then AddToken(TTokenKind.PROCALIGNTOK, UnitIndex, Line, 1, 0)
                              else
                                if s = 'LOOP' then AddToken(TTokenKind.LOOPALIGNTOK, UnitIndex, Line, 1, 0)
                                else
                                  if s = 'LINK' then AddToken(TTokenKind.LINKALIGNTOK, UnitIndex, Line, 1, 0)
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

                              GetCommonConstType(NumTok, TTokenKind.WORDTOK, GetValueType(v));

                              Tok[NumTok].Value := v;

                              AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                            end
                            else

                              if (cmd = 'UNITPATH') then
                              begin      // {$unitpath path1;path2;...}
                                AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                                repeat

                                  s := GetFilePath(d, i);

                                  if s = '' then
                                    Error(NumTok, TMessage.Create(TErrorCode.FilePathNotSpecified,
                                      'An empty path cannot be used'));

                                  AddPath(s);

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
                                  AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                                  repeat

                                    s := GetFilePath(d, i);

                                    if s = '' then
                                      Error(NumTok, TMessage.Create(TErrorCode.FilePathNotSpecified,
                                        'An empty path cannot be used'));

                                    AddPath(s);

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
                                    AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                                    s := GetFilePath(d, i);
                                    AddResource(FindFile(s, 'resource'));

                                    tokenList.RemoveToken;
                                  end
                                  else
(*
       if cmd = 'C' then begin          // {$c 6502|65816}
  AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

  s := GetNumber(i, d);

  val(s,CPUMode, Err);

  if Err > 0 then
   Error(NumTok, OrdinalExpExpected);

  GetCommonConstType(NumTok, CARDINALTOK, GetValueType(CPUMode));

  dec(NumTok);
       end else
*)

                                    if (cmd = 'L') or (cmd = 'LINK') then
                                    begin    // {$L filename} | {$LINK filename}
                                      AddToken(TTokenKind.LINKTOK, UnitIndex, Line, 1, 0);

                                      s := GetFilePath(d, i);
                                      s := FindFile(s, 'link object');

                                      DefineFilename(NumTok, s);

                                      AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                                      //dec(NumTok);
                                    end
                                    else

                                      if (cmd = 'F') or (cmd = 'FASTMUL') then
                                      begin    // {$F [page address]}
                                        AddToken(TTokenKind.SEMICOLONTOK, UnitIndex, Line, 1, 0);

                                        s := GetNumber(d, i);

                                        val(s, FastMul, Err);

                                        if Err <> 0 then
                                          ErrorOrdinalExpExpected(NumTok);

                                        AddDefine('FASTMUL');
                                        AddDefines := NumDefines;

                                        GetCommonConstType(NumTok, TTokenKind.BYTETOK, GetValueType(FastMul));

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
                                                nam := GetLabelUpperCase(d, i);

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

                                                  Tok[NumTok].Line := line;

                                                  if not (UpCase(d[i]) in AllowLabelFirstChars) then
                                                    Error(NumTok,
                                                      TMessage.Create(TErrorCode.SyntaxError,
                                                      'Syntax error, ''identifier'' expected'));

                                                  repeat

                                                    Inc(Err);

                                                    if Err > MAXPARAMS then
                                                      Error(NumTok,
                                                        TMessage.Create(TErrorCode.TooManyFormalParameters,
                                                        'Too many formal parameters in ' + nam));

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

                                                  AddDefine(nam);    // define macro

                                                  s := copy(d, i, length(d));
                                                  SetLength(s, length(s) - 1);

                                                  Defines[NumDefines].Macro := s;
                                                  Defines[NumDefines].Line := DefineLine;

                                                  if Err > 0 then Defines[NumDefines].Param := Param;

                                                end
                                                else
                                                  AddDefine(nam);

                                              end
                                              else
                                                if cmd = 'UNDEF' then
                                                begin
                                                  nam := GetLabelUpperCase(d, i);
                                                  RemoveDefine(nam);
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
          InFile.Seek2(InFile.FilePos() - 1);

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
          InFile.Seek2(InFile.FilePos() - 1);

        repeat            // Skip comments
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
            InFile.Seek2(InFile.FilePos() - 1);

        end;

      if c = LF then Inc(Line);        // Increment current line number
    end;


    function ReadParameters: String;
    var
      opn: Integer;
    begin

      Result := '(';
      opn := 1;

      while True do
      begin
        ReadChar(ch);

        if ch = LF then Inc(Line);

        if ch = '(' then Inc(opn);
        if ch = ')' then Dec(opn);

        if not (ch in [CR, LF]) then Result := Result + ch;

        if (length(Result) > 255) or (opn = 0) then Break;

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
        // InFile.Close();
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


    procedure TextInvers(p: Integer);
    var
      i: Integer;
    begin

      for i := p to length(Text) do
        if Ord(Text[i]) < 128 then
          Text[i] := chr(Ord(Text[i]) + $80);

    end;


    procedure TextInternal(p: Integer);
    var
      i: Integer;

      function ata2int(const a: Byte): Byte;
        (*----------------------------------------------------------------------------*)
        (*  zamiana znakow ATASCII na INTERNAL          *)
        (*----------------------------------------------------------------------------*)
      begin
        Result := a;

        case (a and $7f) of
          0..31: Inc(Result, 64);
          32..95: Dec(Result, 32);
        end;

      end;


      function cbm(const a: Char): Byte;
      begin
        Result := Ord(a);

        case a of
          'a'..'z': Dec(Result, 96);
          '['..'_': Dec(Result, 64);
          '`': Result := 64;
          '@': Result := 0;
        end;

      end;

    begin

      if target.id = TTargetID.A8 then
      begin

        for i := p to length(Text) do
          Text[i] := chr(ata2int(Ord(Text[i])));

      end
      else
      begin

        for i := p to length(Text) do
          Text[i] := chr(cbm(Text[i]));

      end;

    end;


    procedure ReadNumber;
    begin

      //    Num:='';

      if ch = '%' then
      begin      // binary

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
        begin      // hexadecimal

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

          while ch in ['0'..'9'] do    // Number suspected
          begin
            Num := Num + ch;
            SafeReadChar(ch);
          end;

    end;

  begin

    inFile := TFileSystem.CreateBinaryFile;
    inFile.Assign(fnam);    // UnitIndex = 1 main program
    inFile.Reset(1);

    Text := '';
    ch := ' ';

    try
      while True do
      begin
        OldNumTok := NumTok;

        repeat
          ReadChar(ch);

          if ch in [' ', TAB] then Inc(Spaces);

        until not (ch in [' ', TAB, LF, CR, '{'(*, '}'*)]);
        // Skip space, tab, line feed, carriage return, comment braces


        ch := UpCase(ch);


        Num := '';
        if ch in ['0'..'9', '$', '%'] then ReadNumber;

        if Length(Num) > 0 then      // Number found
        begin
          AddToken(TTokenKind.INTNUMBERTOK, UnitIndex, Line, length(Num) + Spaces, StrToInt(Num));
          Spaces := 0;

          if ch = '.' then      // Fractional part suspected
          begin
            SafeReadChar(ch);
            if ch = '.' then
              InFile.Seek2(InFile.FilePos() - 1)  // Range ('..') token
            else
            begin        // Fractional part found
              Frac := '.';

              while ch in ['0'..'9'] do
              begin
                Frac := Frac + ch;
                SafeReadChar(ch);
              end;

              Tok[NumTok].Kind := TTokenKind.FRACNUMBERTOK;

              if length(Num) > 17 then
                Tok[NumTok].FracValue := 0
              else
                Tok[NumTok].FracValue := StrToFloat(Num + Frac);

              Tok[NumTok].Column := Tok[NumTok - 1].Column + length(Num) + length(Frac) + Spaces;
              Spaces := 0;
            end;
          end;

          Num := '';
          Frac := '';
        end;


        if ch in ['A'..'Z', '_'] then    // Keyword or identifier suspected
        begin
          Text := '';

          err := 0;
          repeat
            Text := Text + ch;
            ch2 := ch;
            SafeReadChar(ch);

            if (ch = '.') and (ch2 = '.') then
            begin
              ch := #0;
              Break;
            end;

            Inc(err);
          until not (ch in ['A'..'Z', '_', '0'..'9', '.']);

          if Text[length(Text)] = '.' then
          begin
            SetLength(Text, length(Text) - 1);
            InFile.Seek2(InFile.FilePos() - 2);
            Dec(err);
          end;

          if err > 255 then
            Error(NumTok, TMessage.Create(TErrorCode.ConstantStringTooLong,
              'Constant strings can''t be longer than 255 chars'));

          if Length(Text) > 0 then
          begin

            CurToken := GetStandardToken(Text);

            im := SearchDefine(Text);

            if (im > 0) and (Defines[im].Macro <> '') then
            begin

              tmp := InFile.FilePos();
              ch2 := ch;
              Num := '';      // read parameters, max 255 chars

              if Defines[im].Param[1] <> '' then
              begin
                while ch in AllowWhiteSpaces do ReadChar(ch);
                if ch = '(' then Num := ReadParameters;
              end;

              SetLength(StrParams, 1);
              StrParams[0] := '';

              Tok[NumTok].Line := Line;

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
                    'Too many formal parameters in ' + Text));

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

              AddToken(TTokenKind.UNTYPETOK, UnitIndex, Line, length(Text) + Spaces, 0);
              Spaces := 0;

            end;


            if CurToken = TTokenKind.ASMTOK then
            begin

              Tok[NumTok].Kind := CurToken;
              Tok[NumTok].Value := 0;

              tmp := InFile.FilePos();

              _line := line;

              repeat          // pomijaj puste znaki i sprawdz jaki znak zastaniesz
                InFile.Read(ch);
                if ch = LF then Inc(line);
              until not (ch in AllowWhiteSpaces);


              if ch <> '{' then
              begin      // nie znalazl znaku '{'

                line := _line;        // zaczynamy od nowa czytać po 'ASM'

                Tok[NumTok].Value := 1;

                InFile.Seek2(tmp - 1);

                InFile.Read(ch);

                AsmBlock[AsmBlockIndex] := '';
                Text := '';

{
     if ch in [CR,LF] then begin      // skip EOL after 'ASM'

      if ch = LF then inc(line);

      if ch = CR then InFile.Read(ch);    // CR LF

      AsmBlock[AsmBlockIndex] := '';
      Text:='';

     end else begin
      AsmBlock[AsmBlockIndex] := ch;
      Text:=ch;
     end;
}

                while True do
                begin
                  InFile.Read(ch);

                  SaveAsmBlock(ch);

                  Text := Text + UpperCase(ch);

                  if pos('END;', Text) > 0 then
                  begin
                    SetLength(AsmBlock[AsmBlockIndex], length(AsmBlock[AsmBlockIndex]) - 4);

                    //        inc(line, AsmBlock[AsmBlockIndex].CountChar(LF));
                    Break;
                  end;

                  if ch in [CR, LF] then
                  begin
                    if ch = LF then Inc(line);
                    Text := '';
                  end;

                end;

              end
              else
              begin

                InFile.Seek2(InFile.FilePos() - 1);

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
                RaiseHaltException(THaltException.COMPILING_ABORTED);
              end;

            end
            else
            begin

              if CurToken <> TTokenKind.MACRORELEASE then

                if CurToken <> TTokenKind.UNTYPETOK then
                begin    // Keyword found
                  Tok[NumTok].Kind := CurToken;

                  if CurToken = TTokenKind.USESTOK then UsesFound := True;

                  if CurToken = TTokenKind.UNITTOK then UnitFound := True;

                  if testUnit and (UnitFound = False) then
                    Error(NumTok, TMessage.Create(TErrorCode.UnitExpected, '"UNIT" expected but "' +
                      GetTokenSpelling(CurToken) + '" found'));

                end
                else
                begin        // Identifier found
                  Tok[NumTok].Kind := TTokenKind.IDENTTOK;
                  Tok[NumTok].Name := Text;
                end;

            end;

            Text := '';
          end;

        end;


        if ch in ['''', '#'] then
        begin

          Text := '';
          yes := True;

          repeat

            case ch of

              '''': begin

                if yes then
                begin
                  TextPos := Length(Text) + 1;
                  yes := False;
                end;

                Inc(Spaces);

                repeat
                  InFile.Read(ch);

                  if ch = LF then  //Inc(Line);
                    Error(NumTok, TMessage.Create(TErrorCode.StringExceedsLine, 'String exceeds line'));

                  if not (ch in ['''', CR, LF]) then
                    Text := Text + ch
                  else
                  begin

                    InFile.Read(ch2);

                    if ch2 = '''' then
                    begin
                      Text := Text + '''';
                      ch := #0;
                    end
                    else
                      InFile.Seek2(InFile.FilePos() - 1);

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
                  TextInvers(TextPos);
                  SafeReadChar(ch);
                end;

                if ch = '~' then
                begin
                  Inc(Spaces);
                  TextInternal(TextPos);
                  SafeReadChar(ch);

                  if ch = '*' then
                  begin
                    Inc(Spaces);
                    TextInvers(TextPos);
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
                  Text := Text + chr(StrToInt(Num))
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
            '*': begin
              TextInvers(TextPos);
              SafeReadChar(ch);
            end;      // Invers
            '~': begin
              TextInternal(TextPos);
              SafeReadChar(ch);
            end;    // Antic
          end;

          // if Length(Text) > 0 then
          if Length(Text) = 1 then
          begin
            AddToken(TTokenKind.CHARLITERALTOK, UnitIndex, Line, 1 + Spaces, Ord(Text[1]));
            Spaces := 0;
          end
          else
          begin
            AddToken(TTokenKind.STRINGLITERALTOK, UnitIndex, Line, length(Text) + Spaces, 0);
            Spaces := 0;

            if ExternalFound then
              DefineFilename(NumTok, Text)
            else
              DefineStaticString(NumTok, Text);

          end;

          Text := '';

        end;


        if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then
        begin
          AddToken(GetStandardToken(ch), UnitIndex, Line, 1 + Spaces, 0);
          Spaces := 0;

          ExternalFound := False;

          if UsesFound and (ch = ';') then
            if UsesOn then ReadUses;
        end;


        //      if ch in ['?','!','&','\','|','_','#'] then
        //  AddToken(UNKNOWNIDENTTOK, UnitIndex, Line, 1, ord(ch));


        if ch in [':', '>', '<', '.'] then          // Double-character token suspected
        begin
          ch_ := ch;

          Line2 := Line;
          SafeReadChar(ch2);

          ch := ch_;

          if (ch2 = '=') or ((ch = '<') and (ch2 = '>')) or ((ch = '.') and (ch2 = '.')) then
          begin        // Double-character token found
            AddToken(GetStandardToken(ch + ch2), UnitIndex, Line, 2 + Spaces, 0);
            Spaces := 0;
          end
          else
            if (ch = '.') and (ch2 in ['0'..'9']) then
            begin

              AddToken(TTokenKind.INTNUMBERTOK, UnitIndex, Line, 0, 0);

              Frac := '0.';      // Fractional part found

              while ch2 in ['0'..'9'] do
              begin
                Frac := Frac + ch2;
                SafeReadChar(ch2);
              end;

              Tok[NumTok].Kind := TTokenKind.FRACNUMBERTOK;
              Tok[NumTok].FracValue := StrToFloat(Frac);
              Tok[NumTok].Column := Tok[NumTok - 1].Column + length(Frac) + Spaces;
              Spaces := 0;

              Frac := '';

              InFile.Seek2(InFile.FilePos() - 1);

            end
            else
            begin
              InFile.Seek2(InFile.FilePos() - 1);
              Line := Line2;

              if ch in [':', '>', '<', '.'] then
              begin        // Single-character token found
                AddToken(GetStandardToken(ch), UnitIndex, Line, 1 + Spaces, 0);
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
      on e: THaltException do
      begin
        RaiseHaltException(e.GetExitCode());
      end;
      on e: EInOutError do    // EOF reached
        if Text <> '' then
        begin
          if Text = 'END.' then
          begin
            AddToken(TTokenKind.ENDTOK, UnitIndex, Line, 3, 0);
            AddToken(TTokenKind.DOTTOK, UnitIndex, Line, 1, 0);
          end
          else
          begin
            AddToken(GetStandardToken(Text), UnitIndex, Line, length(Text) + Spaces, 0);
            Spaces := 0;
          end;
        end;
    end;// try
    InFile.Close;
  end;


  procedure TokenizeUnit(a: Integer; testUnit: Boolean = False);
  // Read input file and get tokens
  var
    endLine: Integer;
  begin

    UnitIndex := a;

    Line := 1;
    Spaces := 0;

    if UnitIndex > 1 then AddToken(TTokenKind.UNITBEGINTOK, UnitIndex, Line, 0, 0);

    //  writeln('>',UnitIndex,',',UnitArray[UnitIndex].Name);

    UnitFound := False;

    Tokenize(UnitList.UnitArray[UnitIndex].Path, testUnit);

    if UnitIndex > 1 then
    begin

      CheckTok(NumTok, TTokenKind.DOTTOK);
      CheckTok(NumTok - 1, TTokenKind.ENDTOK);
      EndLine := Tok[NumTok - 1].Line;
      tokenList.RemoveToken;
      tokenList.RemoveToken;

      AddToken(TTokenKind.UNITENDTOK, UnitIndex, EndLine - 1, 0, 0);
    end
    else
      AddToken(TTokenKind.EOFTOK, UnitIndex, Line, 0, 0);

  end;

begin
  AsmFound := False;
  UsesFound := False;
  UnitFound := False;
  ExternalFound := False;

  IncludeIndex := MAXUNITS;

  TokenizeProgramInitialization;

  if UsesOn then
    TokenizeUnit(1)     // main_file
  else
    for cnt := NumUnits downto 1 do
      if GetUnit(cnt).Name <> '' then TokenizeUnit(cnt);

end;  // TokenizeProgram


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TScanner.TokenizeMacro(a: String; Line, Spaces: Integer);
var
  i: Integer;
  Text: String;
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


  procedure TextInvers(p: Integer);
  var
    i: Integer;
  begin

    for i := p to length(Text) do
      if Ord(Text[i]) < 128 then
        Text[i] := chr(Ord(Text[i]) + $80);

  end;


  procedure TextInternal(p: Integer);
  var
    i: Integer;

    function ata2int(const a: Byte): Byte;
      (*----------------------------------------------------------------------------*)
      (*  zamiana znakow ATASCII na INTERNAL          *)
      (*----------------------------------------------------------------------------*)
    begin
      Result := a;

      case (a and $7f) of
        0..31: Inc(Result, 64);
        32..95: Dec(Result, 32);
      end;

    end;


    function cbm(const a: Char): Byte;
    begin
      Result := Ord(a);

      case a of
        'a'..'z': Dec(Result, 96);
        '['..'_': Dec(Result, 64);
        '`': Result := 64;
        '@': Result := 0;
      end;

    end;

  begin

    if target.id = TTargetID.A8 then
    begin

      for i := p to length(Text) do
        Text[i] := chr(ata2int(Ord(Text[i])));

    end
    else
    begin

      for i := p to length(Text) do
        Text[i] := chr(cbm(Text[i]));

    end;

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

        while ch in ['0'..'9'] do    // Number suspected
        begin
          Num := Num + ch;
          ch := a[i];
          Inc(i);
        end;

  end;

begin

  TextPos := 0;
  i := 1;

  while i <= length(a) do
  begin

    while a[i] in AllowWhiteSpaces do
    begin

      if a[i] = LF then
      begin
        Inc(Line);
        Spaces := 0;
      end
      else
        Inc(Spaces);

      Inc(i);
    end;

    ch := UpCase(a[i]);
    Inc(i);


    Num := '';
    if ch in ['0'..'9', '$', '%'] then ReadNumber;

    if Length(Num) > 0 then      // Number found
    begin
      AddToken(TTokenKind.INTNUMBERTOK, 1, Line, length(Num) + Spaces, StrToInt(Num));
      Spaces := 0;

      if ch = '.' then      // Fractional part suspected
      begin

        ch := a[i];
        Inc(i);

        if ch = '.' then
          Dec(i)        // Range ('..') token
        else
        begin        // Fractional part found
          Frac := '.';

          while ch in ['0'..'9'] do
          begin
            Frac := Frac + ch;

            ch := a[i];
            Inc(i);
          end;

          Tok[NumTok].Kind := TTokenKind.FRACNUMBERTOK;
          Tok[NumTok].FracValue := StrToFloat(Num + Frac);
          Tok[NumTok].Column := Tok[NumTok - 1].Column + length(Num) + length(Frac) + Spaces;
          Spaces := 0;
        end;
      end;

      Num := '';
      Frac := '';
    end;


    if ch in ['A'..'Z', '_'] then    // Keyword or identifier suspected
    begin

      Text := '';

      err := 0;

      TextPos := i - 1;

      while ch in ['A'..'Z', '_', '0'..'9', '.'] do
      begin
        Text := Text + ch;
        Inc(err);

        ch := UpCase(a[i]);
        Inc(i);
      end;


      if err > 255 then
        Error(NumTok, TMessage.Create(TErrorCode.ConstantStringTooLong,
          'Constant strings can''t be longer than 255 chars'));

      if Length(Text) > 0 then
      begin

        CurToken := GetStandardToken(Text);

        im := SearchDefine(Text);

        if (im > 0) and (Defines[im].Macro <> '') then
        begin

          ch := #0;

          i := TextPos;

          if Defines[im].Macro = copy(a, i, length(Text)) then
            Error(NumTok, TMessage.Create(TErrorCode.RecursionInMacro, 'Recursion in macros is not allowed'));

          Delete(a, i, length(Text));
          insert(Defines[im].Macro, a, i);

          CurToken := TTokenKind.MACRORELEASE;

        end
        else
        begin

          if CurToken = TTokenKind.TEXTTOK then CurToken := TTokenKind.TEXTFILETOK;
          if CurToken = TTokenKind.FLOATTOK then CurToken := TTokenKind.SINGLETOK;
          if CurToken = TTokenKind.FLOAT16TOK then CurToken := TTokenKind.HALFSINGLETOK;
          if CurToken = TTokenKind.SHORTSTRINGTOK then CurToken := TTokenKind.STRINGTOK;

          AddToken(TTokenKind.UNTYPETOK, 1, Line, length(Text) + Spaces, 0);
          Spaces := 0;

        end;

        if CurToken <> TTokenKind.MACRORELEASE then

          if CurToken <> TTokenKind.UNTYPETOK then
          begin    // Keyword found

            Tok[NumTok].Kind := CurToken;

          end
          else
          begin        // Identifier found
            Tok[NumTok].Kind := TTokenKind.IDENTTOK;
            Tok[NumTok].Name := Text;
          end;

      end;

      Text := '';
    end;


    if ch in ['''', '#'] then
    begin

      Text := '';
      yes := True;

      repeat

        case ch of

          '''': begin

            if yes then
            begin
              TextPos := Length(Text) + 1;
              yes := False;
            end;

            Inc(Spaces);

            repeat
              ch := a[i];
              Inc(i);

              if ch = LF then  //Inc(Line);
                Error(NumTok, TMessage.Create(TErrorCode.StringExceedsLine, 'String exceeds line'));

              if not (ch in ['''', CR, LF]) then
                Text := Text + ch
              else
              begin

                ch2 := a[i];
                Inc(i);

                if ch2 = '''' then
                begin
                  Text := Text + '''';
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
              TextInvers(TextPos);
              ch := a[i];
              Inc(i);
            end;

            if ch = '~' then
            begin
              Inc(Spaces);
              TextInternal(TextPos);
              ch := a[i];
              Inc(i);

              if ch = '*' then
              begin
                Inc(Spaces);
                TextInvers(TextPos);
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
              Text := Text + chr(StrToInt(Num))
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
          TextInvers(TextPos);
          ch := a[i];
          Inc(i);
        end;      // Invers
        '~': begin
          TextInternal(TextPos);
          ch := a[i];
          Inc(i);
        end;    // Antic
      end;

      // if Length(Text) > 0 then
      if Length(Text) = 1 then
      begin
        AddToken(TTokenKind.CHARLITERALTOK, 1, Line, 1 + Spaces, Ord(Text[1]));
        Spaces := 0;
      end
      else
      begin
        AddToken(TTokenKind.STRINGLITERALTOK, 1, Line, length(Text) + Spaces, 0);
        Spaces := 0;
        DefineStaticString(NumTok, Text);
      end;

      Text := '';

    end;


    if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then
    begin
      AddToken(GetStandardToken(ch), 1, Line, 1 + Spaces, 0);
      Spaces := 0;
    end;


    if ch in [':', '>', '<', '.'] then          // Double-character token suspected
    begin

      Line2 := Line;

      ch2 := a[i];
      Inc(i);

      if (ch2 = '=') or ((ch = '<') and (ch2 = '>')) or ((ch = '.') and (ch2 = '.')) then
      begin        // Double-character token found
        AddToken(GetStandardToken(ch + ch2), 1, Line, 2 + Spaces, 0);
        Spaces := 0;
      end
      else
        if (ch = '.') and (ch2 in ['0'..'9']) then
        begin

          AddToken(TTokenKind.INTNUMBERTOK, 1, Line, 0, 0);

          Frac := '0.';      // Fractional part found

          while ch2 in ['0'..'9'] do
          begin
            Frac := Frac + ch2;

            ch2 := a[i];
            Inc(i);
          end;

          Tok[NumTok].Kind := TTokenKind.FRACNUMBERTOK;
          Tok[NumTok].FracValue := StrToFloat(Frac);
          Tok[NumTok].Column := Tok[NumTok - 1].Column + length(Frac) + Spaces;
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
            AddToken(GetStandardToken(ch), 1, Line, 1 + Spaces, 0);
            Spaces := 0;
          end;

        end;

    end;

  end;

end;  //TokenizeMacro


end.
