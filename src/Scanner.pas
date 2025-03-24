unit Scanner;

{$I Defines.inc}

interface

uses StringUtilities, CommonTypes, Common; // TODO: Only use tokens and type

// ----------------------------------------------------------------------------

procedure TokenizeProgram(UsesOn: Boolean = True);

procedure TokenizeMacro(a: String; Line, Spaces: Integer);

// For testing. Idea: Put token array into a ITokenList, so it can be tested independently of the whole scanner
procedure AddToken(Kind: TTokenKind; UnitIndex, Line, Column: Integer; Value: TInteger);

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Messages, FileIO, Utilities;

// ----------------------------------------------------------------------------

procedure ErrorOrdinalExpExpected(i: TTokenIndex);
begin
  Error(i, TMessage.Create(TErrorCode.OrdinalExpExpected, 'Ordinal expression expected.'));
end;

procedure TokenizeProgramInitialization;
var i: Integer;
begin

 for i := Low(Ident) to High(Ident) do
 begin
 	Ident[i] := Default(TIdentifier);
 end;
 ClearWordMemory(DataSegment);
 ClearWordMemory(StaticStringData);

 PublicSection := true;
 UnitNameIndex := 1;

 SetLength(linkObj, 1);
 SetLength(resArray, 1);
 SetLength(msgUser, 1);
 SetLength(msgWarning, 1);
 SetLength(msgNote, 1);

 NumBlocks := 0; BlockStackTop := 0; CodeSize := 0; CodePosStackTop := 0; VarDataSize := 0;
 CaseCnt := 0; IfCnt := 0; ShrShlCnt := 0; NumTypes := 0; run_func := 0; NumProc := 0;
 NumTok := 0; NumIdent := 0;

 NumStaticStrChars := 0;

 IfdefLevel := 0;
 AsmBlockIndex := 0;

 NumDefines := AddDefines;

 optyA := '';
 optyY := '';
 optyBP2 := '';

 optyFOR0 := '';
 optyFOR1 := '';
 optyFOR2 := '';
 optyFOR3 := '';

 for i := 0 to High(AsmBlock) do AsmBlock[i]:='';

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetStandardToken(S: TString): TTokenCode;
var
  i: Integer;
begin
Result := TTokenCode.UNTYPETOK;

if (S = 'LONGWORD') or (S = 'DWORD') or (S = 'UINT32') then S := 'CARDINAL' else
 if (S = 'UINT16') then S := 'WORD' else
  if (S = 'LONGINT') then S := 'INTEGER';

for i := 1 to MAXTOKENNAMES do
  if S = TokenSpelling[i].spelling then
    begin
    Result := TokenSpelling[i].tokenCode;
    Break;
    end;
end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddResource(fnam: string);
var i, j: integer;
    t: ITextFile;
    res: TResource;
    s, tmp: string;
begin

  t := TFileSystem.CreateTextFile;
  t.Assign(fnam); t.Reset;

  while not t.EOF do begin
    s := '';
    t.ReadLn(s);

    i:=1;
    SkipWhitespaces(s, i);

    if (length(s) > i-1) and (not (s[i] in ['#',';'])) then begin

     res.resName := GetLabelUpperCase(s, i);
     res.resType := GetLabelUpperCase(s, i);
     res.resFile := GetFilePath(s, i );

    if (res.resType = 'RCDATA') or
       (res.resType = 'RCASM') or
       (res.resType = 'DOSFILE') or
       (res.resType = 'RELOC') or
       (res.resType = 'RMT') or
       (res.resType = 'MPT') or
       (res.resType = 'CMC') or
       (res.resType = 'RMTPLAY') or
       (res.resType = 'RMTPLAY2') or
       (res.resType = 'RMTPLAYV') or
       (res.resType = 'MPTPLAY') or
       (res.resType = 'CMCPLAY') or
       (res.resType = 'EXTMEM') or
       (res.resType = 'XBMP') or
       (res.resType = 'SAPR') or
       (res.resType = 'SAPRPLAY') or
       (res.resType = 'PP') or
       (res.resType = 'LIBRARY')
      then

      else
        Error(NumTok, TMessage.Create(TErrorCode.UndefinedResourceType, 'Undefined resource type: Type = ''' +
          res.resType + ''', Name = ''' + res.resName + ''''));


      if (res.resFile <> '') and (unitPathList.FindFile(res.resFile) = '') then
        Error(NumTok, TMessage.Create(TErrorCode.ResourceFileNotFound, 'Resource file not found: Type = ' +
          res.resType + ', Name = ''' + res.resName + ''' in unit path ''' + unitPathList.ToString + ''''));

     for j := 1 to MAXPARAMS do begin

      if s[i] in ['''','"'] then
       tmp := GetStringUpperCase(s,i)
      else
       tmp := GetNumber(s,i);

      if tmp = '' then tmp:='0';

      res.resPar[j]  := tmp;
     end;

//     writeln(res.resName,',',res.resType,',',res.resFile);

     for j := High(resArray)-1 downto 0 do
      if resArray[j].resName = res.resName then
       Error(NumTok,  TMessage.Create(TErrorCode.DuplicateResource,'Duplicate resource: Type = ' + res.resType + ', Name = ''' + res.resName + ''''));

     j:=High(resArray);
     resArray[j] := res;

     SetLength(resArray, j+2);

    end;

  end;

  t.Close;

end;	//AddResource


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure AddToken(Kind: TTokenKind; UnitIndex, Line, Column: Integer; Value: TInteger);
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

end;	//AddToken


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveAsmBlock(a: char);
begin

 AsmBlock[AsmBlockIndex] := AsmBlock[AsmBlockIndex] + a;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TokenizeProgram(UsesOn: Boolean = true);
var
  Text: string;
  Num, Frac: TString;
  OldNumTok, UnitIndex, IncludeIndex, Line, Err, cnt, Line2, Spaces, TextPos, im, OldNumDefines: Integer;
  Tmp: Int64;
  AsmFound, UsesFound, UnitFound, ExternalFound, yes: Boolean;
  ch, ch2, ch_: Char;
  CurToken: TTokenCode;
  StrParams: TStringArray;


  procedure TokenizeUnit(a: integer; testUnit: Boolean = false); forward;


  procedure Tokenize(fnam: string; testUnit: Boolean = false);
  var InFile: IBinaryFile;
      _line: integer;
      _uidx: integer;


  procedure ReadUses;
  var i, j, k: integer;
      _line: integer;
      _uidx: integer;
      s, nam: string;
  begin

	 UsesFound := false;

	 i := NumTok - 1;


	 while Tok[i].Kind <> TTokenKind.USESTOK do begin


	  if Tok[i].Kind = TTokenKind.STRINGLITERALTOK then begin

	   CheckTok(i - 1, TTokenKind.INTOK);
	   CheckTok(i - 2, TTokenKind.IDENTTOK);

	   nam := '';

	   for k:=1 to Tok[i].StrLength do
	    nam := nam + chr( StaticStringData[Tok[i].StrAddress - CODEORIGIN + k] );

	   nam := FindFile(nam, 'unit');

	   dec(i, 2);

	  end else begin

	   CheckTok(i, TTokenKind.IDENTTOK);

	   nam := FindFile(Tok[i].Name + '.pas', 'unit');

	  end;


	 s:=AnsiUpperCase(Tok[i].Name);


	 for j := 2 to NumUnits do		// kasujemy wczesniejsze odwolania
	   if UnitName[j].Name = s then UnitName[j].Name := '';

	  _line := Line;
	 _uidx := UnitIndex;

	 inc(NumUnits);
	 UnitIndex := NumUnits;

	 if UnitIndex > High(UnitName) then
	Error(NumTok,  TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, UnitIndex: ' + IntToStr(UnitIndex)));

	 Line:=1;
  	 UnitName[UnitIndex].Name := s;
	 UnitName[UnitIndex].Path := nam;

	 TokenizeUnit( UnitIndex, true );

	 Line := _line;
	 UnitIndex := _uidx;

	 if Tok[i - 1].Kind = TTokenKind.COMMATOK then
	  dec(i, 2)
	 else
	  dec(i);

	 end;	//while

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
    c := ' ';
    InFile.Read(c);

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
      Param: TDefineParams;


	procedure bin2csv(fn: string);
	var bin: IBinaryFile;
	    tmp: byte;
	    NumRead: integer;
	    yes: Boolean;
	begin

	  yes:=false;

	  tmp:=0;
	  NumRead:=0;
          bin:=TFileSystem.CreateBinaryFile;
          bin.Assign(fn); bin.Reset(1);

  	  Repeat
    	bin.BlockRead(tmp, 1, NumRead);

		if NumRead = 1 then begin

	    		if yes then AddToken(GetStandardToken(','), UnitIndex, Line, 1, 0);

	    		AddToken(TTokenCode.INTNUMBERTOK, UnitIndex, Line, 1, tmp);

	    		yes:=true;
	   	end;

  	  Until (NumRead = 0);

	  bin.Close();

	end;


	procedure skip_spaces;
	begin

 	 while d[i] in AllowWhiteSpaces do begin
   	  if d[i] = LF then inc(DefineLine);
 	  inc(i);
  	 end;

	end;


	procedure newMsgUser(Kind: TTokenKind);
	var k: integer;
	begin

		k:=High(msgUser);

		AddToken(Kind, UnitIndex, Line, 1, k); AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);

		SkipWhitespaces(d, i);

		msgUser[k] := copy(d, i, length(d)-i);
		SetLength(msgUser, k+2);

	end;

  begin

    Param:=Default(TDefineParams);

    if UpCase(d[1]) in AllowLabelFirstChars then begin

     i:=1;
     cmd := GetLabelUpperCase(d, i);

     if cmd='INCLUDE' then cmd:='I';
     if cmd='RESOURCE' then cmd:='R';

     if cmd = 'WARNING' then newMsgUser(TTokenCode.WARNINGTOK) else
     if cmd = 'ERROR' then newMsgUser(TTokenCode.ERRORTOK) else
     if cmd = 'INFO' then newMsgUser(TTokenCode.INFOTOK) else

     if cmd = 'MACRO+' then macros:=true else
     if cmd = 'MACRO-' then macros:=false else
     if cmd = 'MACRO' then begin

      s := GetStringUpperCase(d,i);

      if s='ON' then macros:=true else
       if s='OFF' then macros:=false else
        Error(NumTok,  TMessage.Create(TErrorCode.WrongSwitchToggle, 'Wrong switch toggle, use ON/OFF or +/-'));

     end else

     if cmd = 'I' then begin					// {$i filename}
								// {$i+-} iocheck
          if d[i] = '+' then
          begin
            AddToken(TTokenCode.IOCHECKON, UnitIndex, Line, 1, 0);
            AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);
          end
          else
          if d[i] = '-' then
          begin
            AddToken(TTokenCode.IOCHECKOFF, UnitIndex, Line, 1, 0);
            AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);
          end
          else
	begin
//	 AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

            s := GetString(d, False, i);        // don't change the case, it could be a file path

	 if AnsiUpperCase(s) = '%TIME%' then begin

	   s:=TimeToStr(Now);

	   AddToken(TTokenCode.STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0); Spaces:=0;
	   DefineStaticString(NumTok, s);

	 end else
	 if AnsiUpperCase(s) = '%DATE%' then begin

	   s:=DateToStr(Now);

	   AddToken(TTokenCode.STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0); Spaces:=0;
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

	  if IncludeIndex > High(UnitName) then
                Error(NumTok, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, IncludeIndex: ' +
                  IntToStr(IncludeIndex)));

	  Tokenize( nam );

	  Line := _line;
	  UnitIndex := _uidx;

	 end;

	end;

     end else

      if (cmd = 'EVAL') then begin

          if d.LastIndexOf('}') < 0 then
            Error(NumTok, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error. Character ''}'' expected'));

       s := copy(d, i, d.LastIndexOf('}') - i + 1);
       s := TrimRight(s);

          if s[length(s)] <> '"' then Error(NumTok, TMessage.Create(TErrorCode.SyntaxError,
              'Syntax error. Missing ''"'''));

       AddToken(TTokenCode.EVALTOK, UnitIndex, Line, 1, 0);

       DefineFilename(NumTok, s);

      end else

      if (cmd = 'BIN2CSV') then begin

       s := GetFilePath(d, i);

       s := FindFile(s, 'BIN2CSV');

       bin2csv(s);

      end else

      if (cmd = 'OPTIMIZATION') then begin

       s := GetStringUpperCase(d, i);

       if s = 'LOOPUNROLL' then AddToken(TTokenCode.LOOPUNROLLTOK, UnitIndex, Line, 1, 0) else
        if s= 'NOLOOPUNROLL' then AddToken(TTokenCode.NOLOOPUNROLLTOK, UnitIndex, Line, 1, 0) else
            Error(NumTok, TMessage.Create(TErrorCode.IllegalOptimizationSpecified,
              'Illegal optimization specified "' + s + '"'));

	AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0)

      end else

      if (cmd = 'CODEALIGN') then begin

       s := GetStringUpperCase(d, i);

       if s = 'PROC' then AddToken(TTokenCode.PROCALIGNTOK, UnitIndex, Line, 1, 0) else
        if s = 'LOOP' then AddToken(TTokenCode.LOOPALIGNTOK, UnitIndex, Line, 1, 0) else
         if s = 'LINK' then AddToken(TTokenCode.LINKALIGNTOK, UnitIndex, Line, 1, 0) else
            Error(NumTok, TMessage.Create(TErrorCode.IllegalAlignmentDirective, 'Illegal alignment directive ''' + s + '''.'));

       SkipWhitespaces(d, i);

          if d[i] <> '=' then Error(NumTok, TMessage.Create(TErrorCode.SyntaxError, 'Character ''='' expected.'));
       inc(i);
       SkipWhitespaces(d, i);

	s := GetNumber(d,i);

	val(s, v, Err);

	if Err > 0 then
	 ErrorOrdinalExpExpected(NumTok);

	GetCommonConstType(NumTok, TTokenCode.WORDTOK, GetValueType(v));

	Tok[NumTok].Value := v;

	AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0)

      end else

      if (cmd = 'UNITPATH') then begin			// {$unitpath path1;path2;...}
       AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);

       repeat

       s := GetFilePath(d, i);

       if s = '' then
              Error(NumTok, TMessage.Create(TErrorCode.FilePathNotSpecified, 'An empty path cannot be used'));

       AddPath(s);

       if d[i] = ';' then
	inc(i)
       else
	Break;

       until d[i] = ';';

       dec(NumTok);
      end else

      if (cmd = 'LIBRARYPATH') then begin			// {$librarypath path1;path2;...}
       AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);

       repeat

       s := GetFilePath(d, i);

       if s = '' then
       	 Error(NumTok, TMessage.Create(TErrorCode.FilePathNotSpecified, 'An empty path cannot be used'));

       AddPath(s);

       if d[i] = ';' then
	inc(i)
       else
	Break;

       until d[i] = ';';

       dec(NumTok);
      end else

      if (cmd = 'R') and not (d[i] in ['+','-']) then begin	// {$R filename}
       AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);

       s := GetFilePath(d, i);
       AddResource( FindFile(s, 'resource') );

       dec(NumTok);
      end else
(*
       if cmd = 'C' then begin					// {$c 6502|65816}
	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

	s := GetNumber(i, d);

	val(s,CPUMode, Err);

	if Err > 0 then
	 Error(NumTok, OrdinalExpExpected);

	GetCommonConstType(NumTok, CARDINALTOK, GetValueType(CPUMode));

	dec(NumTok);
       end else
*)

      if (cmd = 'L') or (cmd = 'LINK') then begin		// {$L filename} | {$LINK filename}
       AddToken(TTokenCode.LINKTOK, UnitIndex, Line, 1, 0);

       s := GetFilePath(d, i);
       s := FindFile(s, 'link object');

       DefineFilename(NumTok, s);

       AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);

       //dec(NumTok);
      end else

       if (cmd = 'F') or (cmd = 'FASTMUL') then begin		// {$F [page address]}
	AddToken(TTokenCode.SEMICOLONTOK, UnitIndex, Line, 1, 0);

	s := GetNumber(d,i);

	val(s, FastMul, Err);

	if Err <> 0 then
	 ErrorOrdinalExpExpected(NumTok);

	AddDefine('FASTMUL');
        AddDefines := NumDefines;

	GetCommonConstType(NumTok, TTokenCode.BYTETOK, GetValueType(FastMul));

	dec(NumTok);
       end else

       if (cmd = 'IFDEF') or (cmd = 'IFNDEF') then begin

	found := 0 <> SearchDefine( GetLabelUpperCase(d, i) );

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
        Error(NumTok, TMessage.Create(TErrorCode.ElseWithoutIf, 'Found $ELSE without $IFXXX'));
	if IfdefLevel > 0 then
	 Dec(IfdefLevel)
       end else
       if cmd = 'ENDIF' then begin
	if IfdefLevel = 0 then
	 Error(NumTok, TMessage.Create(TErrorCode.EndifWithoutIf, 'Found $ENDIF without $IFXXX'))
	else
	 Dec(IfdefLevel)
       end else
       if cmd = 'DEFINE' then begin
	nam := GetLabelUpperCase(d, i);

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
              Error(NumTok, TMessage.Create(TErrorCode.SyntaxError, 'Syntax error, ''identifier'' expected'));

	 repeat

	  inc(Err);

          if Err > MAXPARAMS then
                Error(NumTok, TMessage.Create(TErrorCode.TooManyFormalParameters, 'Too many formal parameters in ' + nam));

	  Param[Err] := GetLabelUpperCase(d, i);

	  for x := 1 to Err - 1 do
	   if Param[x] = Param[Err] then
                  Error(NumTok, TMessage.Create(TErrorCode.DuplicateIdentifier, 'Duplicate identifier ''' + Param[Err] + ''''));

	  skip_spaces;

	  if d[i] = ',' then begin
	   inc(i);
	   skip_spaces;

	   if not(UpCase(d[i]) in AllowLabelFirstChars) then
                  Error(NumTok, TMessage.Create(TErrorCode.IdentifierExpected, 'Syntax error, ''identifier'' expected'));
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
	nam := GetLabelUpperCase(d, i);
	RemoveDefine(nam);
       end else
          Error(NumTok, TMessage.Create(TErrorCode.IllegalCompilerDirective, 'Illegal compiler directive $' + cmd + d[i]));

    end;

  end;


  procedure ReadSingleLineComment;
  begin

   while (ch <> LF) do
     InFile.Read(ch);

  end;


  procedure ReadChar(var c: Char);
  var c2: Char;
      dir: Boolean;
      directive: string;
      _line: integer;
  begin

  InFile.Read(c);

   if c = '(' then begin
    c2:=' ';
    InFile.Read(c2);

    if c2='*' then begin				// Skip comments (*   *)

     repeat
      c2:=c;
      InFile.Read(c);

      if c = LF then Inc(Line);
     until (c2 = '*') and (c = ')');

     InFile.Read(c);

    end else
     InFile.Seek2(InFile.FilePos() - 1);

   end;


   if c = '{' then begin

    dir:=false;
    directive:='';

    _line := Line;

    InFile.Read(c2);

    if c2='$' then
     dir:=true
    else
     InFile.Seek2(InFile.FilePos() - 1);

    repeat						// Skip comments
      InFile.Read(c);

      if dir then directive := directive + c;

      if c <> '}' then
       if AsmFound then SaveAsmBlock(c);

      if c = LF then Inc(Line);
    until c = '}';

    if dir then ReadDirective(directive, _line);

    InFile.Read(c);

   end else
    if c = '/' then begin
     InFile.Read(c2);

     if c2 = '/' then
      ReadSingleLineComment
     else
      InFile.Seek2(InFile.FilePos() - 1);

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
    // InFile.Close();
        Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter, 'Unexpected unknown character: ' + c));
    end;
  end;


  procedure SkipWhiteSpace;				// 'string' + #xx + 'string'
  begin
    SafeReadChar(ch);

    while ch in AllowWhiteSpaces do SafeReadChar(ch);

      if not (ch in ['''', '#']) then Error(NumTok, TMessage.Create(TErrorCode.SyntaxError,
          'Syntax error, ''string'' expected but ''' + ch + ''' found'));
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

   if target.id = TComputer.A8 then begin

     for i := p to length(Text) do
      Text[i] := chr(ata2int(ord(Text[i])));

   end else begin

     for i := p to length(Text) do
      Text[i] := chr(cbm(Text[i]));

   end;

  end;


  procedure ReadNumber;
  begin

//    Num:='';

    if ch='%' then begin		  // binary

      SafeReadChar(ch);

      while ch in ['0', '1'] do
       begin
       Num := Num + ch;
       SafeReadChar(ch);
       end;

       if length(Num)=0 then
	 ErrorOrdinalExpExpected(NumTok);

       Num := '%' + Num;

    end else

    if ch='$' then begin		  // hexadecimal

      SafeReadChar(ch);

      while ch in AllowDigitChars do
       begin
       Num := Num + ch;
       SafeReadChar(ch);
       end;

       if length(Num)=0 then
	 ErrorOrdinalExpExpected(NumTok);

       Num := '$' + Num;

    end else

      while ch in ['0'..'9'] do		// Number suspected
	begin
	Num := Num + ch;
	SafeReadChar(ch);
	end;

  end;


  begin

  inFile:=TFileSystem.CreateBinaryFile;
  inFile.Assign(fnam);		// UnitIndex = 1 main program
  inFile.Reset(1);

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
	AddToken(TTokenCode.INTNUMBERTOK, UnitIndex, Line, length(Num) + Spaces, StrToInt(Num)); Spaces:=0;

	if ch = '.' then			// Fractional part suspected
	  begin
	  SafeReadChar(ch);
	  if ch = '.' then
	    InFile.Seek2(InFile.FilePos() - 1)	// Range ('..') token
	  else
	    begin				// Fractional part found
	    Frac := '.';

	    while ch in ['0'..'9'] do
	      begin
	      Frac := Frac + ch;
	      SafeReadChar(ch);
	      end;

	    Tok[NumTok].Kind := TTokenCode.FRACNUMBERTOK;

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
	 InFile.Seek2(InFile.FilePos() - 2);
	 dec(err);
	end;

	if err > 255 then
            Error(NumTok, TMessage.Create(TErrorCode.ConstantStringTooLong, 'Constant strings can''t be longer than 255 chars'));

	if Length(Text) > 0 then
	  begin

	 CurToken := GetStandardToken(Text);

	 im := SearchDefine(Text);

	 if (im > 0) and (Defines[im].Macro <> '') then begin

	  tmp:=InFile.FilePos();
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
	   InFile.Seek2( tmp);
	   ch:=ch2;
	  end else begin
	   StrParams := SplitStr(copy(Num, 2, length(Num)-2), ',');

	  if High(StrParams) > MAXPARAMS then
	   Error(NumTok, TMessage.Create(TErrorCode.TooManyFormalParameters, 'Too many formal parameters in ' + Text));

	  end;

	  if (StrParams[0] <> '') and (Defines[im].Param[1] = '') then
                Error(NumTok, TMessage.Create(TErrorCode.WrongNumberOfParameters, 'Wrong number of parameters'));


	  OldNumDefines := NumDefines;

	  Err:=1;

	  while (Defines[im].Param[Err] <> '') and (Err <= MAXPARAMS) do begin

	   if StrParams[Err - 1] = '' then
	     Error(NumTok, TMessage.Create(TErrorCode.ParameterMissing, 'Parameter missing'));

	   AddDefine(Defines[im].Param[Err]);
	   Defines[NumDefines].Macro := StrParams[Err - 1];
	   Defines[NumDefines].Line := Line;

	   inc(Err);
	  end;


	  TokenizeMacro(Defines[im].Macro, Defines[im].Line, 0);

	  NumDefines := OldNumDefines;

	  CurToken := TTokenCode.MACRORELEASE;
	 end else begin

	  if CurToken = TTokenCode.TEXTTOK then CurToken := TTokenCode.TEXTFILETOK;
	  if CurToken = TTokenCode.FLOATTOK then CurToken := TTokenCode.SINGLETOK;
	  if CurToken = TTokenCode.FLOAT16TOK then CurToken := TTokenCode.HALFSINGLETOK;
	  if CurToken = TTokenCode.SHORTSTRINGTOK then CurToken := TTokenCode.STRINGTOK;

	  if CurToken = TTokenCode.EXTERNALTOK then ExternalFound := TRUE;

	  AddToken(TTokenCode.UNTYPETOK, UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;

	 end;


	 if CurToken = TTokenCode.ASMTOK then begin

	  Tok[NumTok].Kind := CurToken;
	  Tok[NumTok].Value:= 0;

	  tmp:=InFile.FilePos();

	  _line := line;

	  repeat					// pomijaj puste znaki i sprawdz jaki znak zastaniesz
	   InFile.Read(ch);
	   if ch = LF then inc(line);
	  until not(ch in AllowWhiteSpaces);


	  if ch <> '{' then begin			// nie znalazl znaku '{'

	   line := _line;				// zaczynamy od nowa czytać po 'ASM'

	   Tok[NumTok].Value := 1;

	   InFile.Seek2(tmp - 1);

	   InFile.Read(ch);

	   AsmBlock[AsmBlockIndex] := '';
	   Text:='';

{
	   if ch in [CR,LF] then begin			// skip EOL after 'ASM'

	    if ch = LF then inc(line);

	    if ch = CR then InFile.Read(ch);		// CR LF

	    AsmBlock[AsmBlockIndex] := '';
	    Text:='';

	   end else begin
	    AsmBlock[AsmBlockIndex] := ch;
	    Text:=ch;
	   end;
}

	   while true do begin
	    InFile.Read(ch);

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

	  InFile.Seek2(InFile.FilePos() - 1);

	  AsmFound:=true;

	  repeat
	   ReadChar(ch);

	   if ch in [' ',TAB] then inc(Spaces);

	  until not (ch in [' ',TAB,LF,CR,'{','}']);    // Skip space, tab, line feed, carriage return, comment braces

	  AsmFound:=false;

	  end;

	  inc(AsmBlockIndex);

	  if AsmBlockIndex > High(AsmBlock) then begin
	   Error(NumTok, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, ASMBLOCK'));
	   RaiseHaltException(THaltException.COMPILING_ABORTED);
	  end;

	 end else begin

	  if CurToken <> TTokenCode.MACRORELEASE then

	   if CurToken <> TTokenCode.UNTYPETOK then begin		// Keyword found
	     Tok[NumTok].Kind := CurToken;

	     if CurToken = TTokenCode.USESTOK then UsesFound := true;

	     if CurToken = TTokenCode.UNITTOK then UnitFound := true;

	     if testUnit and (UnitFound = false) then
	      Error(NumTok, TMessage.Create(TErrorCode.UnitExpected, '"UNIT" expected but "' + GetTokenSpelling(CurToken) + '" found'));

	   end
	   else begin				// Identifier found
	     Tok[NumTok].Kind := TTokenCode.IDENTTOK;
	     Tok[NumTok].Name := Text;
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
		  InFile.Read(ch);

		  if ch = LF then	//Inc(Line);
		   Error(NumTok, TMessage.Create(TErrorCode.StringExceedsLine, 'String exceeds line'));

		  if not(ch in ['''',CR,LF]) then
		   Text := Text + ch
		  else begin

		   InFile.Read(ch2);

		   if ch2='''' then begin
		    Text := Text + '''';
		    ch:=#0;
		   end else
		    InFile.Seek2( InFile.FilePos() - 1);

		  end;

		 until ch = '''';

		 inc(Spaces);

		 SafeReadChar(ch);

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=InFile.FilePos();
			while ch2 in [' ',TAB] do InFile.Read(ch2);

			if ch2 in ['*','~','+'] then
			 ch:=ch2
			else
			 InFile.Seek2( Err);
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
			Err:=InFile.FilePos();
			while ch2 in [' ',TAB] do InFile.Read(ch2);

			if ch2 in ['''','+'] then
			 ch:=ch2
			else
			 InFile.Seek2( Err);
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
                  Error(NumTok, TMessage.Create(TErrorCode.ConstantExpressionExpected, 'Constant expression expected'));

		 if ch in [' ',TAB] then begin
			ch2:=ch;
			Err:=InFile.FilePos();
			while ch2 in [' ',TAB] do InFile.Read(ch2);

			if ch2 in ['''','+'] then
			 ch:=ch2
			else
			 InFile.Seek2( Err);
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
	    AddToken(TTokenCode.CHARLITERALTOK, UnitIndex, Line, 1 + Spaces, Ord(Text[1])); Spaces:=0;
	  end else begin
	    AddToken(TTokenCode.STRINGLITERALTOK, UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;

	    if ExternalFound then
	      DefineFilename(NumTok, Text)
	    else
	      DefineStaticString(NumTok, Text);

	  end;

	 Text := '';

	end;


      if ch in ['=', ',', ';', '(', ')', '*', '/', '+', '-', '^', '@', '[', ']'] then begin
	AddToken(GetStandardToken(ch), UnitIndex, Line, 1 + Spaces, 0); Spaces:=0;

	ExternalFound := false;

	if UsesFound and (ch = ';') then
	  if UsesOn then ReadUses;
      end;


//      if ch in ['?','!','&','\','|','_','#'] then
//	AddToken(UNKNOWNIDENTTOK, UnitIndex, Line, 1, ord(ch));


      if ch in [':', '>', '<', '.'] then					// Double-character token suspected
	begin
	ch_:=ch;

	Line2:=Line;
	SafeReadChar(ch2);

	ch:=ch_;

	if (ch2 = '=') or
	   ((ch = '<') and (ch2 = '>')) or
	   ((ch = '.') and (ch2 = '.')) then begin				// Double-character token found
	  AddToken(GetStandardToken(ch + ch2), UnitIndex, Line, 2 + Spaces, 0); Spaces:=0;
	end else
	 if (ch='.') and (ch2 in ['0'..'9']) then begin

	   AddToken(TTokenCode.INTNUMBERTOK, UnitIndex, Line, 0, 0);

	   Frac := '0.';		  // Fractional part found

	   while ch2 in ['0'..'9'] do begin
	    Frac := Frac + ch2;
	    SafeReadChar(ch2);
	   end;

	   Tok[NumTok].Kind := TTokenCode.FRACNUMBERTOK;
	   Tok[NumTok].FracValue := StrToFloat(Frac);
	   Tok[NumTok].Column := Tok[NumTok-1].Column + length(Frac) + Spaces; Spaces:=0;

	   Frac := '';

	   InFile.Seek2( InFile.FilePos() - 1);

	 end else
	  begin
	  InFile.Seek2( InFile.FilePos() - 1);
	  Line:=Line2;

	  if ch in [':','>', '<', '.'] then begin				// Single-character token found
	    AddToken(GetStandardToken(ch), UnitIndex, Line, 1 + Spaces, 0); Spaces:=0;
	  end else
	    begin
              Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter, 'Unexpected character ''' +
                ch + ''' found. Expected one of '':><.''.'));
	    end;
	  end;
	end;


      if NumTok = OldNumTok then	 // No token found
	begin
	Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter, 'Illegal character '''+ch+''' ($'+IntToHex(ord(ch),2)+')'));
	end;

      end;// while

  except
     on e: THaltException do
     begin
          RaiseHaltException(e.GetExitCode());
     end
     else // EOF reached
     if Text <> '' then
     begin
       if Text='END.' then
         begin
           AddToken(TTokenCode.ENDTOK, UnitIndex, Line, 3, 0);
           AddToken(TTokenCode.DOTTOK, UnitIndex, Line, 1, 0);
         end
       else
         begin
           AddToken(GetStandardToken(Text), UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;
         end;
     end;
  end;// try
  InFile.Close;
end;


procedure TokenizeUnit(a: integer; testUnit: Boolean = false);
// Read input file and get tokens
begin

  UnitIndex := a;

  Line := 1;
  Spaces := 0;

  if UnitIndex > 1 then AddToken(TTokenCode.UNITBEGINTOK, UnitIndex, Line, 0, 0);

//  writeln('>',UnitIndex,',',UnitName[UnitIndex].Name);

  UnitFound := false;

  Tokenize( UnitName[UnitIndex].Path, testUnit );

  if UnitIndex > 1 then begin

    CheckTok(NumTok, TTokenCode.DOTTOK);
    CheckTok(NumTok - 1, TTokenCode.ENDTOK);

    dec(NumTok, 2);

    AddToken(TTokenCode.UNITENDTOK, UnitIndex, Tok[NumTok+1].Line - 1, 0, 0);
  end else
   AddToken(TTokenCode.EOFTOK, UnitIndex, Line, 0, 0);

end;

  procedure AddTokenSpelling(t: TTokenCode; s: String);
  var
    tokenSpelling: TTokenSpelling;
  begin
    tokenSpelling.TokenCode := t;
    tokenSpelling.Spelling := s;
    // TODO Add
    Assert(False);
  end;

begin
  // Token spelling definition
  AddTokenSpelling(TTokenCode.CONSTTOK, 'CONST');
  AddTokenSpelling(TTokenCode.TYPETOK, 'TYPE');
  AddTokenSpelling(TTokenCode.VARTOK, 'VAR');
  AddTokenSpelling(TTokenCode.PROCEDURETOK, 'PROCEDURE');
  AddTokenSpelling(TTokenCode.FUNCTIONTOK, 'FUNCTION');
  AddTokenSpelling(TTokenCode.OBJECTTOK, 'OBJECT');
  AddTokenSpelling(TTokenCode.PROGRAMTOK, 'PROGRAM');
  AddTokenSpelling(TTokenCode.LIBRARYTOK, 'LIBRARY');
  AddTokenSpelling(TTokenCode.EXPORTSTOK, 'EXPORTS');
  AddTokenSpelling(TTokenCode.EXTERNALTOK, 'EXTERNAL');
  AddTokenSpelling(TTokenCode.UNITTOK, 'UNIT');
  AddTokenSpelling(TTokenCode.INTERFACETOK, 'INTERFACE');
  AddTokenSpelling(TTokenCode.IMPLEMENTATIONTOK, 'IMPLEMENTATION');
  AddTokenSpelling(TTokenCode.INITIALIZATIONTOK, 'INITIALIZATION');
  AddTokenSpelling(TTokenCode.CONSTRUCTORTOK, 'CONSTRUCTOR');
  AddTokenSpelling(TTokenCode.DESTRUCTORTOK, 'DESTRUCTOR');
  AddTokenSpelling(TTokenCode.OVERLOADTOK, 'OVERLOAD');
  AddTokenSpelling(TTokenCode.ASSEMBLERTOK, 'ASSEMBLER');
  AddTokenSpelling(TTokenCode.FORWARDTOK, 'FORWARD');
  AddTokenSpelling(TTokenCode.REGISTERTOK, 'REGISTER');
  AddTokenSpelling(TTokenCode.INTERRUPTTOK, 'INTERRUPT');
  AddTokenSpelling(TTokenCode.PASCALTOK, 'PASCAL');
  AddTokenSpelling(TTokenCode.STDCALLTOK, 'STDCALL');
  AddTokenSpelling(TTokenCode.INLINETOK, 'INLINE');
  AddTokenSpelling(TTokenCode.KEEPTOK, 'KEEP');

  AddTokenSpelling(TTokenCode.ASSIGNFILETOK, 'ASSIGN');
  AddTokenSpelling(TTokenCode.RESETTOK, 'RESET');
  AddTokenSpelling(TTokenCode.REWRITETOK, 'REWRITE');
  AddTokenSpelling(TTokenCode.APPENDTOK, 'APPEND');
  AddTokenSpelling(TTokenCode.BLOCKREADTOK, 'BLOCKREAD');
  AddTokenSpelling(TTokenCode.BLOCKWRITETOK, 'BLOCKWRITE');
  AddTokenSpelling(TTokenCode.CLOSEFILETOK, 'CLOSE');

  AddTokenSpelling(TTokenCode.GETRESOURCEHANDLETOK, 'GETRESOURCEHANDLE');
  AddTokenSpelling(TTokenCode.SIZEOFRESOURCETOK, 'SIZEOFRESOURCE');


  AddTokenSpelling(TTokenCode.FILETOK, 'FILE');
  AddTokenSpelling(TTokenCode.TEXTFILETOK, 'TEXTFILE');
  AddTokenSpelling(TTokenCode.SETTOK, 'SET');
  AddTokenSpelling(TTokenCode.PACKEDTOK, 'PACKED');
  AddTokenSpelling(TTokenCode.VOLATILETOK, 'VOLATILE');
  AddTokenSpelling(TTokenCode.STRIPEDTOK, 'STRIPED');
  AddTokenSpelling(TTokenCode.LABELTOK, 'LABEL');
  AddTokenSpelling(TTokenCode.GOTOTOK, 'GOTO');
  AddTokenSpelling(TTokenCode.INTOK, 'IN');
  AddTokenSpelling(TTokenCode.RECORDTOK, 'RECORD');
  AddTokenSpelling(TTokenCode.CASETOK, 'CASE');
  AddTokenSpelling(TTokenCode.BEGINTOK, 'BEGIN');
  AddTokenSpelling(TTokenCode.ENDTOK, 'END');
  AddTokenSpelling(TTokenCode.IFTOK, 'IF');
  AddTokenSpelling(TTokenCode.THENTOK, 'THEN');
  AddTokenSpelling(TTokenCode.ELSETOK, 'ELSE');
  AddTokenSpelling(TTokenCode.WHILETOK, 'WHILE');
  AddTokenSpelling(TTokenCode.DOTOK, 'DO');
  AddTokenSpelling(TTokenCode.REPEATTOK, 'REPEAT');
  AddTokenSpelling(TTokenCode.UNTILTOK, 'UNTIL');
  AddTokenSpelling(TTokenCode.FORTOK, 'FOR');
  AddTokenSpelling(TTokenCode.TOTOK, 'TO');
  AddTokenSpelling(TTokenCode.DOWNTOTOK, 'DOWNTO');
  AddTokenSpelling(TTokenCode.ASSIGNTOK, ':=');
  AddTokenSpelling(TTokenCode.WRITETOK, 'WRITE');
  AddTokenSpelling(TTokenCode.WRITELNTOK, 'WRITELN');
  AddTokenSpelling(TTokenCode.SIZEOFTOK, 'SIZEOF');
  AddTokenSpelling(TTokenCode.LENGTHTOK, 'LENGTH');
  AddTokenSpelling(TTokenCode.HIGHTOK, 'HIGH');
  AddTokenSpelling(TTokenCode.LOWTOK, 'LOW');
  AddTokenSpelling(TTokenCode.INTTOK, 'INT');
  AddTokenSpelling(TTokenCode.FRACTOK, 'FRAC');
  AddTokenSpelling(TTokenCode.TRUNCTOK, 'TRUNC');
  AddTokenSpelling(TTokenCode.ROUNDTOK, 'ROUND');
  AddTokenSpelling(TTokenCode.ODDTOK, 'ODD');

  AddTokenSpelling(TTokenCode.READLNTOK, 'READLN');
  AddTokenSpelling(TTokenCode.HALTTOK, 'HALT');
  AddTokenSpelling(TTokenCode.BREAKTOK, 'BREAK');
  AddTokenSpelling(TTokenCode.CONTINUETOK, 'CONTINUE');
  AddTokenSpelling(TTokenCode.EXITTOK, 'EXIT');

  AddTokenSpelling(TTokenCode.SUCCTOK, 'SUCC');
  AddTokenSpelling(TTokenCode.PREDTOK, 'PRED');

  AddTokenSpelling(TTokenCode.INCTOK, 'INC');
  AddTokenSpelling(TTokenCode.DECTOK, 'DEC');
  AddTokenSpelling(TTokenCode.ORDTOK, 'ORD');
  AddTokenSpelling(TTokenCode.CHRTOK, 'CHR');
  AddTokenSpelling(TTokenCode.ASMTOK, 'ASM');
  AddTokenSpelling(TTokenCode.ABSOLUTETOK, 'ABSOLUTE');
  AddTokenSpelling(TTokenCode.USESTOK, 'USES');
  AddTokenSpelling(TTokenCode.LOTOK, 'LO');
  AddTokenSpelling(TTokenCode.HITOK, 'HI');
  AddTokenSpelling(TTokenCode.GETINTVECTOK, 'GETINTVEC');
  AddTokenSpelling(TTokenCode.SETINTVECTOK, 'SETINTVEC');
  AddTokenSpelling(TTokenCode.ARRAYTOK, 'ARRAY');
  AddTokenSpelling(TTokenCode.OFTOK, 'OF');
  AddTokenSpelling(TTokenCode.STRINGTOK, 'STRING');

  AddTokenSpelling(TTokenCode.RANGETOK, '..');

  AddTokenSpelling(TTokenCode.EQTOK, '=');
  AddTokenSpelling(TTokenCode.NETOK, '<>');
  AddTokenSpelling(TTokenCode.LTTOK, '<');
  AddTokenSpelling(TTokenCode.LETOK, '<=');
  AddTokenSpelling(TTokenCode.GTTOK, '>');
  AddTokenSpelling(TTokenCode.GETOK, '>=');

  AddTokenSpelling(TTokenCode.DOTTOK, '.');
  AddTokenSpelling(TTokenCode.COMMATOK, ',');
  AddTokenSpelling(TTokenCode.SEMICOLONTOK, ');');
  AddTokenSpelling(TTokenCode.OPARTOK, '(');
  AddTokenSpelling(TTokenCode.CPARTOK, ')');
  AddTokenSpelling(TTokenCode.DEREFERENCETOK, '^');
  AddTokenSpelling(TTokenCode.ADDRESSTOK, '@');
  AddTokenSpelling(TTokenCode.OBRACKETTOK, '[');
  AddTokenSpelling(TTokenCode.CBRACKETTOK, ']');
  AddTokenSpelling(TTokenCode.COLONTOK, ':');

  AddTokenSpelling(TTokenCode.PLUSTOK, '+');
  AddTokenSpelling(TTokenCode.MINUSTOK, '-');
  AddTokenSpelling(TTokenCode.MULTOK, '*');
  AddTokenSpelling(TTokenCode.DIVTOK, '/');
  AddTokenSpelling(TTokenCode.IDIVTOK, 'DIV');
  AddTokenSpelling(TTokenCode.MODTOK, 'MOD');
  AddTokenSpelling(TTokenCode.SHLTOK, 'SHL');
  AddTokenSpelling(TTokenCode.SHRTOK, 'SHR');
  AddTokenSpelling(TTokenCode.ORTOK, 'OR');
  AddTokenSpelling(TTokenCode.XORTOK, 'XOR');
  AddTokenSpelling(TTokenCode.ANDTOK, 'AND');
  AddTokenSpelling(TTokenCode.NOTTOK, 'NOT');

  AddTokenSpelling(TTokenCode.INTEGERTOK, 'INTEGER');
  AddTokenSpelling(TTokenCode.CARDINALTOK, 'CARDINAL');
  AddTokenSpelling(TTokenCode.SMALLINTTOK, 'SMALLINT');
  AddTokenSpelling(TTokenCode.SHORTINTTOK, 'SHORTINT');
  AddTokenSpelling(TTokenCode.WORDTOK, 'WORD');
  AddTokenSpelling(TTokenCode.BYTETOK, 'BYTE');
  AddTokenSpelling(TTokenCode.CHARTOK, 'CHAR');
  AddTokenSpelling(TTokenCode.BOOLEANTOK, 'BOOLEAN');
  AddTokenSpelling(TTokenCode.POINTERTOK, 'POINTER');
  AddTokenSpelling(TTokenCode.SHORTREALTOK, 'SHORTREAL');
  AddTokenSpelling(TTokenCode.REALTOK, 'REAL');
  AddTokenSpelling(TTokenCode.SINGLETOK, 'SINGLE');
  AddTokenSpelling(TTokenCode.HALFSINGLETOK, 'FLOAT16');
  AddTokenSpelling(TTokenCode.PCHARTOK, 'PCHAR');

  AddTokenSpelling(TTokenCode.SHORTSTRINGTOK, 'SHORTSTRING');
  AddTokenSpelling(TTokenCode.FLOATTOK, 'FLOAT');
  AddTokenSpelling(TTokenCode.TEXTTOK, 'TEXT');

 AsmFound  := false;
 UsesFound := false;
 UnitFound := false;
 ExternalFound := false;

 IncludeIndex := MAXUNITS;

 TokenizeProgramInitialization;

 if UsesOn then
  TokenizeUnit( 1 )	   // main_file
 else
  for cnt := NumUnits downto 1 do
    if UnitName[cnt].Name <> '' then TokenizeUnit( cnt );

end;	//TokenizeProgram


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TokenizeMacro(a: string; Line, Spaces: integer);
var
  Text: string;
  Num, Frac: TString;
  Err, Line2, TextPos, im: Integer;
  yes: Boolean;
  ch, ch2: Char;
  CurToken: TTokenCode;


  procedure SkipWhiteSpace;				// 'string' + #xx + 'string'
  begin
    ch:=a[i]; inc(i);

    while ch in AllowWhiteSpaces do begin ch:=a[i]; inc(i) end;

    if not (ch in ['''', '#']) then Error(NumTok, TMessage.Create(TErrorCode.UnexpectedCharacter,
        'Syntax error, ''string'' expected but ''' + ch + ''' found'));
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

   if target.id = TComputer.A8 then begin

     for i := p to length(Text) do
      Text[i] := chr(ata2int(ord(Text[i])));

   end else begin

     for i := p to length(Text) do
      Text[i] := chr(cbm(Text[i]));

   end;

  end;


  procedure ReadNumber;
  begin

//    Num:='';

    if ch='%' then begin		  // binary

      ch:=a[i]; inc(i);

      while ch in ['0', '1'] do
       begin
       Num := Num + ch;
       ch:=a[i]; inc(i);
       end;

       if length(Num)=0 then
	 ErrorOrdinalExpExpected(NumTok);

       Num := '%' + Num;

    end else

    if ch='$' then begin		  // hexadecimal

      ch:=a[i]; inc(i);

      while UpCase(ch) in AllowDigitChars do
       begin
       Num := Num + ch;
       ch:=a[i]; inc(i);
       end;

       if length(Num)=0 then
	 ErrorOrdinalExpExpected(NumTok);

       Num := '$' + Num;

    end else

      while ch in ['0'..'9'] do		// Number suspected
	begin
	Num := Num + ch;
	ch:=a[i]; inc(i);
	end;

  end;


begin

 TextPos:=0;
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
	AddToken(TTokenCode.INTNUMBERTOK, 1, Line, length(Num) + Spaces, StrToInt(Num)); Spaces:=0;

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

	    Tok[NumTok].Kind := TTokenCode.FRACNUMBERTOK;
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
        Error(NumTok, TMessage.Create(TErrorCode.ConstantStringTooLong,
          'Constant strings can''t be longer than 255 chars'));

	if Length(Text) > 0 then
	  begin

	 CurToken := GetStandardToken(Text);

	 im := SearchDefine(Text);

	 if (im > 0) and (Defines[im].Macro <> '') then begin

 	  ch:=#0;

	  i:=TextPos;

          if Defines[im].Macro = copy(a,i,length(text)) then
	   Error(NumTok, TMessage.Create(TErrorCode.RecursionInMacro,'Recursion in macros is not allowed'));

	  delete(a, i, length(Text));
	  insert(Defines[im].Macro, a, i);

	  CurToken := TTokenCode.MACRORELEASE;

	 end else begin

	  if CurToken = TTokenCode.TEXTTOK then CurToken := TTokenCode.TEXTFILETOK;
	  if CurToken = TTokenCode.FLOATTOK then CurToken := TTokenCode.SINGLETOK;
	  if CurToken = TTokenCode.FLOAT16TOK then CurToken := TTokenCode.HALFSINGLETOK;
	  if CurToken = TTokenCode.SHORTSTRINGTOK then CurToken := TTokenCode.STRINGTOK;

	  AddToken(TTokenCode.UNTYPETOK, 1, Line, length(Text) + Spaces, 0); Spaces:=0;

	 end;

	 if CurToken <> TTokenCode.MACRORELEASE then

	 if CurToken <> TTokenCode.UNTYPETOK then begin		// Keyword found

	     Tok[NumTok].Kind := CurToken;

	 end
	 else begin				// Identifier found
	     Tok[NumTok].Kind := TTokenCode.IDENTTOK;
	     Tok[NumTok].Name := Text;
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
		   Error(NumTok, TMessage.Create(TErrorCode.StringExceedsLine,'String exceeds line'));

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
		  Error(NumTok, TMessage.Create(TErrorCode.ConstantExpressionExpected, 'Constant expression expected'));

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
	    AddToken(TTokenCode.CHARLITERALTOK, 1, Line, 1 + Spaces, Ord(Text[1])); Spaces:=0;
	  end else begin
	    AddToken(TTokenCode.STRINGLITERALTOK, 1, Line, length(Text) + Spaces, 0); Spaces:=0;
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

	   AddToken(TTokenCode.INTNUMBERTOK, 1, Line, 0, 0);

	   Frac := '0.';		  // Fractional part found

	   while ch2 in ['0'..'9'] do begin
	    Frac := Frac + ch2;

	    ch2:=a[i]; inc(i);
	   end;

	   Tok[NumTok].Kind := TTokenCode.FRACNUMBERTOK;
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

end;	//TokenizeMacro


end.
