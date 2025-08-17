unit Scanner;

interface

{$i define.inc}

// ----------------------------------------------------------------------------

	procedure TokenizeProgram(UsesOn: Boolean = true);

	procedure TokenizeMacro(a: string; Line, Spaces: integer);

	function get_digit(var i:integer; var a:string): string;

	function get_constant(var i:integer; var a:string): string;

	function get_label(var i:integer; var a:string; up: Boolean = true): string;

	function get_string(var i:integer; var a:string; up: Boolean = true): string;

	procedure omin_spacje (var i:integer; var a:string);

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Common, Messages, SplitString;

// ----------------------------------------------------------------------------


procedure TokenizeProgramInitialization;
var i: integer;
begin

 fillchar(Ident, sizeof(Ident), 0);
 fillchar(DataSegment, sizeof(DataSegment), 0);
 fillchar(StaticStringData, sizeof(StaticStringData), 0);

 PublicSection := true;
 UnitNameIndex := 1;

 SetLength(WithName, 1);
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


procedure omin_spacje (var i:integer; var a:string);
(*----------------------------------------------------------------------------*)
(*  omijamy tzw. "biale spacje" czyli spacje, tabulatory		      *)
(*----------------------------------------------------------------------------*)
begin

 if a<>'' then
  while (i<=length(a)) and (a[i] in AllowWhiteSpaces) do inc(i);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function get_constant(var i:integer; var a:string): string;
(*----------------------------------------------------------------------------*)
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_'		      *)
(*----------------------------------------------------------------------------*)
begin

 Result := '';

 if a <> '' then begin

  omin_spacje(i,a);

  if UpCase(a[i]) in AllowLabelFirstChars + ['.'] then
   while UpCase(a[i]) in AllowLabelChars do begin

    Result := Result + UpCase(a[i]);

    inc(i);
   end;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function get_label(var i:integer; var a:string; up: Boolean = true): string;
(*----------------------------------------------------------------------------*)
(*  pobierz etykiete zaczynajaca sie znakami 'A'..'Z','_'		      *)
(*----------------------------------------------------------------------------*)
begin

 Result := '';

 if a <> '' then begin

  omin_spacje(i,a);

  if UpCase(a[i]) in AllowLabelFirstChars + ['.'] then
   while UpCase(a[i]) in AllowLabelChars + AllowDirectorySeparators do begin

    if up then
     Result := Result + UpCase(a[i])
    else
     Result := Result + a[i];

    inc(i);
   end;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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

 omin_spacje(i, a);

 if a[i] = '%' then begin

   while UpCase(a[i]) in ['A'..'Z','%'] do begin Result:=Result + Upcase(a[i]); inc(i) end;

 end else
 if not(a[i] in AllowQuotes) then begin

  Result := get_label(i, a, up);

 end else begin

  gchr:=a[i];
  len:=length(a);

  while i <= len do begin
   inc(i);	 // omijamy pierwszy znak ' lub "

   znak:=a[i];

   if znak=gchr then begin inc(i); Break end;

   Result := Result + znak;
  end;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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
     res.resFile := get_string(i, s, false);			// don't change the case

    if (AnsiUpperCase(res.resType) = 'RCDATA') or
       (AnsiUpperCase(res.resType) = 'RCASM') or
       (AnsiUpperCase(res.resType) = 'DOSFILE') or
       (AnsiUpperCase(res.resType) = 'RELOC') or
       (AnsiUpperCase(res.resType) = 'RMT') or
       (AnsiUpperCase(res.resType) = 'MPT') or
       (AnsiUpperCase(res.resType) = 'CMC') or
       (AnsiUpperCase(res.resType) = 'RMTPLAY') or
       (AnsiUpperCase(res.resType) = 'RMTPLAY2') or
       (AnsiUpperCase(res.resType) = 'RMTPLAYV') or
       (AnsiUpperCase(res.resType) = 'MPTPLAY') or
       (AnsiUpperCase(res.resType) = 'CMCPLAY') or
       (AnsiUpperCase(res.resType) = 'EXTMEM') or
       (AnsiUpperCase(res.resType) = 'XBMP') or
       (AnsiUpperCase(res.resType) = 'SAPR') or
       (AnsiUpperCase(res.resType) = 'SAPRPLAY') or
       (AnsiUpperCase(res.resType) = 'PP') or
       (AnsiUpperCase(res.resType) = 'LIBRARY')
      then

      else
        Error(NumTok, 'Undefined resource type: Type = ''' + res.resType + ''', Name = ''' + res.resName + '''');


     if (res.resFile <> '') and not(FindFile(res.resFile)) then
       Error(NumTok, 'Resource file not found: Type = ' + res.resType + ', Name = ''' + res.resName + '''');


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
       Error(NumTok, 'Duplicate resource: Type = ' + res.resType + ', Name = ''' + res.resName + '''');

     j:=High(resArray);
     resArray[j] := res;

     SetLength(resArray, j+2);

    end;

  end;

 CloseFile(t);

end;	//AddResource


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


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
  CurToken: Byte;
  StrParams: TArrayString;


  procedure TokenizeUnit(a: integer; testUnit: Boolean = false); forward;


  procedure Tokenize(fnam: string; testUnit: Boolean = false);
  var InFile: file of char;
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


	 while Tok[i].Kind <> USESTOK do begin


	  if Tok[i].Kind = STRINGLITERALTOK then begin

	   CheckTok(i - 1, INTOK);
	   CheckTok(i - 2, IDENTTOK);

	   nam := '';

	   for k:=1 to Tok[i].StrLength do
	    nam := nam + chr( StaticStringData[Tok[i].StrAddress - CODEORIGIN + k] );

	   nam := FindFile(nam, 'unit');

	   dec(i, 2);

	  end else begin

	   CheckTok(i, IDENTTOK);

	   nam := FindFile(Tok[i].Name^ + '.pas', 'unit');

	  end;


	 s:=AnsiUpperCase(Tok[i].Name^);


	 for j := 2 to NumUnits do		// kasujemy wczesniejsze odwolania
	   if UnitName[j].Name = s then UnitName[j].Name := '';

	  _line := Line;
	 _uidx := UnitIndex;

	 inc(NumUnits);
	 UnitIndex := NumUnits;

	 if UnitIndex > High(UnitName) then
	  Error(NumTok, 'Out of resources, UnitIndex: ' + IntToStr(UnitIndex));

	 Line:=1;
  	 UnitName[UnitIndex].Name := s;
	 UnitName[UnitIndex].Path := nam;

	 TokenizeUnit( UnitIndex, true );

	 Line := _line;
	 UnitIndex := _uidx;

	 if Tok[i - 1].Kind = COMMATOK then
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


	procedure bin2csv(fn: string);
	var bin: file;
	    tmp: byte;
	    NumRead: integer;
	    yes: Boolean;
	begin

	  yes:=false;

	  tmp:=0;
	  NumRead:=0;

	  AssignFile(bin, fn); FileMode:=0; Reset(bin, 1);

  	  Repeat
    		BlockRead (bin, tmp, 1, NumRead);

		if NumRead = 1 then begin

	    		if yes then AddToken(GetStandardToken(','), UnitIndex, Line, 1, 0);

	    		AddToken(INTNUMBERTOK, UnitIndex, Line, 1, tmp);

	    		yes:=true;
	   	end;

  	  Until (NumRead = 0);

	  CloseFile(bin);

	end;


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

    Param:=Default(TDefinesParam);

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

	 s := get_string(i, d, false);				// don't change the case

	 if AnsiUpperCase(s) = '%TIME%' then begin

	   s:=TimeToStr(Now);

	   AddToken(STRINGLITERALTOK, UnitIndex, Line, length(s) + Spaces, 0); Spaces:=0;
	   DefineStaticString(NumTok, s);

	 end else
	 if AnsiUpperCase(s) = '%DATE%' then begin

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

	  if IncludeIndex > High(UnitName) then
	    Error(NumTok, 'Out of resources, IncludeIndex: '+IntToStr(IncludeIndex));

	  Tokenize( nam );

	  Line := _line;
	  UnitIndex := _uidx;

	 end;

	end;

     end else

      if (cmd = 'EVAL') then begin

       if  d.LastIndexOf('}') < 0 then Error(NumTok, 'Syntax error');

       s := copy(d, i, d.LastIndexOf('}') - i + 1);
       s := TrimRight(s);

       if s[length(s)] <> '"' then Error(NumTok, 'Missing ''"''');

       AddToken(EVALTOK, UnitIndex, Line, 1, 0);

       DefineFilename(NumTok, s);

      end else

      if (cmd = 'BIN2CSV') then begin

       s := get_string(i, d, false);

       s := FindFile(s, 'BIN2CSV');

       bin2csv(s);

      end else

      if (cmd = 'OPTIMIZATION') then begin

       s := get_string(i, d);

       if AnsiUpperCase(s) = 'LOOPUNROLL' then AddToken(LOOPUNROLLTOK, UnitIndex, Line, 1, 0) else
        if AnsiUpperCase(s) = 'NOLOOPUNROLL' then AddToken(NOLOOPUNROLLTOK, UnitIndex, Line, 1, 0) else
	  Error(NumTok, 'Illegal optimization specified "' + AnsiUpperCase(s) + '"');

	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0)

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

      if (cmd = 'UNITPATH') then begin			// {$unitpath path1;path2;...}
       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       repeat

       s := get_string(i, d, false);				// don't change the case

       if s = '' then
       	 Error(NumTok, 'An empty path cannot be used');

       AddPath(s);

       if d[i] = ';' then
	inc(i)
       else
	Break;

       until d[i] = ';';

       dec(NumTok);
      end else

      if (cmd = 'LIBRARYPATH') then begin			// {$librarypath path1;path2;...}
       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       repeat

       s := get_string(i, d, false);				// don't change the case

       if s = '' then
       	 Error(NumTok, 'An empty path cannot be used');

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

       s := get_string(i, d, false);				// don't change the case
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

       s := get_string(i, d, false);				// don't change the case

       s := FindFile(s, 'link object');

       DefineFilename(NumTok, s);

       AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

       //dec(NumTok);
      end else

       if (cmd = 'F') or (cmd = 'FASTMUL') then begin		// {$F [page address]}
	AddToken(SEMICOLONTOK, UnitIndex, Line, 1, 0);

	s := get_digit(i, d);

	val(s, FastMul, Err);

	if Err <> 0 then
	 iError(NumTok, OrdinalExpExpected);

	AddDefine('FASTMUL');
        AddDefines := NumDefines;

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

   if target.id = ___a8 then begin

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
	 iError(NumTok, OrdinalExpExpected);

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
	 iError(NumTok, OrdinalExpExpected);

       Num := '$' + Num;

    end else

      while ch in ['0'..'9'] do		// Number suspected
	begin
	Num := Num + ch;
	SafeReadChar(ch);
	end;

  end;


  begin

  AssignFile(InFile, fnam );		// UnitIndex = 1 main program
  FileMode:=0;
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
	   StrParams := SplitStr(copy(Num, 2, length(Num)-2), ',');

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

	  if CurToken = EXTERNALTOK then ExternalFound := TRUE;

	  AddToken(0, UnitIndex, Line, length(Text) + Spaces, 0); Spaces:=0;

	 end;


	 if CurToken = ASMTOK then begin

	  Tok[NumTok].Kind := CurToken;
	  Tok[NumTok].Value:= 0;

	  tmp:=FilePos(InFile);

	  _line := line;

	  repeat					// pomijaj puste znaki i sprawdz jaki znak zastaniesz
	   Read(InFile, ch);
	   if ch = LF then inc(line);
	  until not(ch in AllowWhiteSpaces);


	  if ch <> '{' then begin			// nie znalazl znaku '{'

	   line := _line;				// zaczynamy od nowa czytać po 'ASM'

	   Tok[NumTok].Value := 1;

	   Seek(InFile, tmp - 1);

	   Read(InFile, ch);

	   AsmBlock[AsmBlockIndex] := '';
	   Text:='';

{
	   if ch in [CR,LF] then begin			// skip EOL after 'ASM'

	    if ch = LF then inc(line);

	    if ch = CR then Read(InFile, ch);		// CR LF

	    AsmBlock[AsmBlockIndex] := '';
	    Text:='';

	   end else begin
	    AsmBlock[AsmBlockIndex] := ch;
	    Text:=ch;
	   end;
}

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

	     if CurToken = UNITTOK then UnitFound := true;

	     if testUnit and (UnitFound = false) then
	      Error(NumTok, 'Syntax error, "UNIT" expected but "' + Spelling[CurToken] + '" found');

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


procedure TokenizeUnit(a: integer; testUnit: Boolean = false);
// Read input file and get tokens
begin

  UnitIndex := a;

  Line := 1;
  Spaces := 0;

  if UnitIndex > 1 then AddToken(UNITBEGINTOK, UnitIndex, Line, 0, 0);

//  writeln('>',UnitIndex,',',UnitName[UnitIndex].Name);

  UnitFound := false;

  Tokenize( UnitName[UnitIndex].Path, testUnit );

  if UnitIndex > 1 then begin

    CheckTok(NumTok, DOTTOK);
    CheckTok(NumTok - 1, ENDTOK);

    dec(NumTok, 2);

    AddToken(UNITENDTOK, UnitIndex, Tok[NumTok+1].Line - 1, 0, 0);
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
Spelling[STRIPEDTOK	] := 'STRIPED';
Spelling[WITHTOK	] := 'WITH';
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
  i, Err, Line2, TextPos, im: Integer;
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

   if target.id = ___a8 then begin

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
	 iError(NumTok, OrdinalExpExpected);

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
	 iError(NumTok, OrdinalExpExpected);

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

end;	//TokenizeMacro


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


end.
