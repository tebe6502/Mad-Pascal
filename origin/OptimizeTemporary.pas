unit OptimizeTemporary;

interface

{$i define.inc}

// ----------------------------------------------------------------------------

procedure OptimizeTemporaryBuf;

procedure WriteOut(const a: String);
procedure FlushTempBuf;

// ----------------------------------------------------------------------------

implementation

uses Crt, SysUtils, Common, Assembler;


var
  TemporaryBuf: array [0..511] of String;

// ----------------------------------------------------------------------------


procedure WriteOut(const a: String);
var
  i: Integer;
begin

  if (pos(#9'jsr ', a) = 1) or (a = '#asm') then ResetOpty;


  if iOut < High(TemporaryBuf) then
  begin

    if (iOut >= 0) and (TemporaryBuf[iOut] <> '') then
    begin

      if TemporaryBuf[iOut] = '; --- ForToDoCondition' then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;

      if (pos(#9'#for', TemporaryBuf[iOut]) > 0) then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;
    end;

    Inc(iOut);
    TemporaryBuf[iOut] := a;

  end
  else
  begin

    OptimizeTemporaryBuf;

    if TemporaryBuf[iOut] <> '' then
    begin

      if TemporaryBuf[iOut] = '; --- ForToDoCondition' then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;

      if (pos(#9'#for', TemporaryBuf[iOut]) > 0) then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;
    end;

    if TemporaryBuf[0] <> '~' then
    begin
      if (TemporaryBuf[0] <> '') or (outTmp <> TemporaryBuf[0]) then writeln(OutFile, TemporaryBuf[0]);

      outTmp := TemporaryBuf[0];
    end;

    for i := 1 to iOut do TemporaryBuf[i - 1] := TemporaryBuf[i];

    TemporaryBuf[iOut] := a;

  end;

end;  //WriteOut


// ----------------------------------------------------------------------------


procedure FlushTempBuf;
var
  i: Integer;
begin

  for i := 0 to High(TemporaryBuf) do WriteOut('');    // flush TemporaryBuf

end;


// ----------------------------------------------------------------------------


procedure OptimizeTemporaryBuf;
var p, k , q: integer;
    yes: Boolean;
    tmp: string;

{$i include\cmd_temporary.inc}


  function argMatch(i, j: Integer): Boolean;
  begin
    Result := copy(TemporaryBuf[i], 6, 256) = copy(TemporaryBuf[j], 6, 256);
  end;


  function fail(i: integer): Boolean;
  begin

        if (pos('#asm:', TemporaryBuf[i]) = 1) or

	   ldy(i) or
           jsr(i) or
           iny(i) or
           dey(i) or
           tay(i) or
           tya(i) or
           mwy(i) or
	   mwy(i) or
           (pos(#9'.if', TemporaryBuf[i]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[i]) > 0) or
           (pos(#9'@print', TemporaryBuf[i]) > 0) then Result:=true else Result:=false;
  end;


  function SKIP(i: integer): Boolean;
  begin

      Result :=	seq(i) or sne(i) or
		spl(i) or smi(i) or
		scc(i) or scs(i) or
		svc(i) or svs(i) or

		jne(i) or jeq(i) or
		jcc(i) or jcs(i) or
		jmi(i) or jpl(i) or

		(pos(#9'bne ', TemporaryBuf[i]) = 1) or (pos(#9'beq ', TemporaryBuf[i]) = 1) or
		(pos(#9'bcc ', TemporaryBuf[i]) = 1) or (pos(#9'bcs ', TemporaryBuf[i]) = 1) or
		(pos(#9'bmi ', TemporaryBuf[i]) = 1) or (pos(#9'bpl ', TemporaryBuf[i]) = 1);
  end;


  function IFDEF_MUL8(i: integer): Boolean;
  begin
      Result :=	//(TemporaryBuf[i+4] = #9'eif') and
      		//(TemporaryBuf[i+3] = #9'imulCL') and
      		//(TemporaryBuf[i+2] = #9'els') and
		(TemporaryBuf[i+1] = #9'fmulu_8') and
		(TemporaryBuf[i]   = #9'.ifdef fmulinit');
  end;


  function IFDEF_MUL16(i: integer): Boolean;
  begin
      Result :=	//(TemporaryBuf[i+4] = #9'eif') and
      		//(TemporaryBuf[i+3] = #9'imulCX') and
      		//(TemporaryBuf[i+2] = #9'els') and
		(TemporaryBuf[i+1] = #9'fmulu_16') and
		(TemporaryBuf[i]   = #9'.ifdef fmulinit');
  end;


  function fortmp(const a: String): String;
    // @FORTMP_xxxx
    // @FORTMP_xxxx+1
  begin

    Result := a;

    //    Result[8] := '?';

    if length(Result) > 12 then
      Result[13] := '_'
    else
      Result := Result + '_0';

  end;


  function GetBYTE(const i: Integer): Integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4));
  end;

  function GetWORD(const i, j: Integer): Integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4)) + GetVAL(copy(TemporaryBuf[j], 6, 4)) * 256;
  end;


  function GetARG(const i: integer): String;
  begin
   Result := copy(TemporaryBuf[i], 6, 256);
  end;


  function GetSTRING(const j: Integer): String;
  var
    i: Integer;
    a: String;
  begin

    Result := '';
    i := 6;

    a := TemporaryBuf[j];

    if a <> '' then
      while not (a[i] in [' ', #9]) and (i <= length(a)) do
      begin
        Result := Result + a[i];
        Inc(i);
      end;

  end;

// -----------------------------------------------------------------------------

{$i include/opt6502/opt_TEMP_MOVE.inc}
{$i include/opt6502/opt_TEMP_FILL.inc}
{$i include/opt6502/opt_TEMP_TAIL_IF.inc}
{$i include/opt6502/opt_TEMP_TAIL_CASE.inc}
{$i include/opt6502/opt_TEMP.inc}
{$i include/opt6502/opt_TEMP_CMP.inc}
{$i include/opt6502/opt_TEMP_CMP_0.inc}
{$i include/opt6502/opt_TEMP_WHILE.inc}
{$i include/opt6502/opt_TEMP_FOR.inc}
{$i include/opt6502/opt_TEMP_FORDEC.inc}
{$i include/opt6502/opt_TEMP_IMUL_CX.inc}
{$i include/opt6502/opt_TEMP_IFTMP.inc}
{$i include/opt6502/opt_TEMP_ORD.inc}
{$i include/opt6502/opt_TEMP_X.inc}
{$i include/opt6502/opt_TEMP_EAX.inc}
{$i include/opt6502/opt_TEMP_JMP.inc}
{$i include/opt6502/opt_TEMP_ZTMP.inc}
{$i include/opt6502/opt_TEMP_UNROLL.inc}
{$i include/opt6502/opt_TEMP_BOOLEAN_OR.inc}

// -----------------------------------------------------------------------------

begin


{
if (pos('lda adr.WALL,y', TemporaryBuf[10]) > 0) then begin

      for p:=0 to 30 do writeln(TemporaryBuf[p]);
      writeln('-------');

end;
}


  opt_TEMP_BOOLEAN_OR;
  opt_TEMP_ORD;
  opt_TEMP_CMP;
  opt_TEMP_CMP_0;
  opt_TEMP;
  opt_TEMP_IMUL_CX;
  opt_TEMP_WHILE;
  opt_TEMP_FORDEC;
  opt_TEMP_FOR;
  opt_TEMP_X;
  opt_TEMP_EAX;
  opt_TEMP_JMP;
  opt_TEMP_ZTMP;
  opt_TEMP_UNROLL;


// -----------------------------------------------------------------------------

    if (TemporaryBuf[0] = #9'jsr #$00') and						// jsr #$00				; 0
       (TemporaryBuf[1] = #9'lda @BYTE.MOD.RESULT') then				// lda @BYTE.MOD.RESULT			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;

    if (TemporaryBuf[0] = #9'jsr #$00') and						// jsr #$00				; 0
       (TemporaryBuf[1] = #9'ldy @BYTE.MOD.RESULT') then				// ldy @BYTE.MOD.RESULT			; 1
       begin
	TemporaryBuf[0] := #9'tay';
	TemporaryBuf[1] := '~';
       end;

// -----------------------------------------------------------------------------


   opt_TEMP_MOVE;
   opt_TEMP_FILL;

   opt_TEMP_IFTMP;
   opt_TEMP_TAIL_IF;
   opt_TEMP_TAIL_CASE;


 // #asm

   if TemporaryBuf[0].IndexOf('#asm:') = 0 then begin

    writeln(OutFile, AsmBlock[StrToInt( copy(TemporaryBuf[0], 6, 256) )]);

    TemporaryBuf[0] := '~';

   end;


// #lib:label

   if TemporaryBuf[0].IndexOf('#lib:') = 0 then
    TemporaryBuf[0] := #9'm@lib ' + copy(TemporaryBuf[0], 6, 256);


// @PARAM?

   if TemporaryBuf[0] = #9'sta @PARAM?' then TemporaryBuf[0] := '~';

   if TemporaryBuf[0] = #9'sty @PARAM?' then TemporaryBuf[0] := #9'tya';


// @FORTMP?

   if (pos('@FORTMP_', TemporaryBuf[0]) > 1) then

    if lda(0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'lda ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if cmp(0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'cmp ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if sub(0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'sub ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if sbc(0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'sbc ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if sta(0) then
      TemporaryBuf[0] := #9'sta ' + fortmp(GetSTRING(0))
    else
    if sty(0) then
      TemporaryBuf[0] := #9'sty ' + fortmp(GetSTRING(0))
    else
    if mva(0) and (pos('mva @FORTMP_', TemporaryBuf[0]) = 0) then begin
     tmp := copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);

     TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + fortmp(tmp);
    end else
     writeln('Unassigned: ' + TemporaryBuf[0] );

   //  tmp := copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);
  //   TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + ':' + fortmp(tmp);

end;  //OptimizeTemporaryBuf


end.
