unit OptimizeTemporary;

interface

uses CommonIO, CompilerTypes;

// Public Interface
// Note that due to the usage of the global unit variables, only on instance mustbe used a at a time currently.
type
  IOptimizeTemporary = interface
    procedure Initialize(const aAsmBlockArray: TAsmBlockArray; const aWriter: IWriter);
    procedure WriteOut(const a: String);
    procedure Finalize;
  end;

type
  TOptimizeTemporary = class(TInterfacedObject, IOptimizeTemporary)

    public

    procedure Initialize(const aAsmBlockArray: TAsmBlockArray; const aWriter: IWriter);
    procedure WriteOut(const a: String);
    procedure Finalize;
  end;

implementation

uses SysUtils, Assembler;

type
  TTemporaryBufIndex = Integer;

var
  AsmBlockArray: TAsmBlockArray;
var
  Writer: IWriter;
var
  TemporaryBuf: array [0..511] of String;
  TemporaryBufIndex: TTemporaryBufIndex;
  LastTempBuf0: TString;

procedure TOptimizeTemporary.Initialize(const aAsmBlockArray: TAsmBlockArray; const aWriter: IWriter);
var
  i: TTemporaryBufIndex;
begin
  AsmBlockArray:=aAsmBlockArray;
  Writer:=aWriter;


  for i := Low(TemporaryBuf) to High(TemporaryBuf) do TemporaryBuf[i] := '';
  TemporaryBufIndex := -1;
  LastTempBuf0 := '';

end;

procedure OptimizeTemporaryBuf;
var
  p, k, q: Integer;
  tmp: String;
  yes: Boolean;


  {$i include\cmd_temporary.inc}


  function argMatch(const i, j: TTemporaryBufIndex): Boolean;
  begin
    Result := copy(TemporaryBuf[i], 6, 256) = copy(TemporaryBuf[j], 6, 256);
  end;


  function fail(i: Integer): Boolean;
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


  function IFDEF_MUL8(const i: TTemporaryBufIndex): Boolean;
  begin
      Result :=	//(TemporaryBuf[i+4] = #9'eif') and
      		//(TemporaryBuf[i+3] = #9'imulCL') and
      		//(TemporaryBuf[i+2] = #9'els') and
		(TemporaryBuf[i+1] = #9'fmulu_8') and
		(TemporaryBuf[i]   = #9'.ifdef fmulinit');
  end;


  function IFDEF_MUL16(const i: TTemporaryBufIndex): Boolean;
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


  function GetBYTE(const i: TTemporaryBufIndex): Integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4));
  end;

  // TODO: The functions below do not handle errors situations (-1) correctly
  function GetWORD(const i, j: TTemporaryBufIndex): Integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4)) + GetVAL(copy(TemporaryBuf[j], 6, 4)) * 256;
  end;


  function GetSTRING(const j: TTemporaryBufIndex): String;
  var
    i: Integer;
    a: String;
  begin

    Result := '';
    i := 6;

    a := TemporaryBuf[j];

    if a <> '' then
      while (i <= length(a)) and not (a[i] in [' ', #9]) do
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
if (pos('#for:dec', TemporaryBuf[10]) > 0) then begin

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

    if (pos('@move ":bp2" ', TemporaryBuf[4]) > 1) and					// @move ":bp2"				; 4

       lda(0) and									// lda A				; 0
       sta_bp2(1) and									// sta :bp2				; 1
       (TemporaryBuf[2] = TemporaryBuf[0] + '+1') and					// lda A+1				; 2
       sta_bp2_1(3) then								// sta :bp2+1				; 3
       begin
	TemporaryBuf[4] := #9'@move ' + GetSTRING(0) + ' ' +  copy(TemporaryBuf[4], 15, 256);

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
	TemporaryBuf[3] := '~';
       end;


    if (pos('mva:rpl (:bp2),y ', TemporaryBuf[5]) > 1) and				// mva:rpl (:bp2),y			; 5

       lda_im(0) and									// lda #				; 0
       sta_bp2(1) and									// sta :bp2				; 1
       lda_im(2) and									// lda #				; 2
       sta_bp2_1(3) and									// sta :bp2+1				; 3
       ldy_im(4) then									// ldy #				; 4
       begin
	p := GetWORD(0, 2);

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
	TemporaryBuf[3] := '~';

	TemporaryBuf[5] := #9'mva:rpl ' + HexWord(word(p)) + ',y ' +  copy(TemporaryBuf[5], 19, 256);
       end;


    if (pos('mva:rne (:bp2),y ', TemporaryBuf[5]) > 1) and				// mva:rne (:bp2),y			; 5

       lda_im(0) and									// lda #				; 0
       sta_bp2(1) and									// sta :bp2				; 1
       lda_im(2) and									// lda #				; 2
       sta_bp2_1(3) and									// sta :bp2+1				; 3
       ldy_im(4) then									// ldy #				; 4
       begin
	p := GetWORD(0, 2);

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
	TemporaryBuf[3] := '~';

	TemporaryBuf[5] := #9'mva:rne ' + HexWord(word(p)) + ',y ' +  copy(TemporaryBuf[5], 19, 256);
       end;

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

    if (TemporaryBuf[0] = #9'lda :STACKORIGIN,x') and					// lda :STACKORIGIN,x			; 0
       sta(1) and									// sta F				; 1
       (TemporaryBuf[2] = #9'lda :STACKORIGIN+STACKWIDTH,x') and			// lda :STACKORIGIN+STACKWIDTH,x	; 2
       sta(3) and									// sta F+1				; 3
       dex(4) and									// dex					; 2
       (TemporaryBuf[5] = ':move') then							//:move					; 3
       begin

	tmp:=TemporaryBuf[6];
	p:=StrToInt(TemporaryBuf[7]);

	if p = 256 then begin
	 TemporaryBuf[1] := #9'sta :bp2';
	 TemporaryBuf[3] := #9'sta :bp2+1';

     	 TemporaryBuf[4] := #9'ldy #$00';
     	 TemporaryBuf[5] := #9'mva:rne (:bp2),y adr.' + tmp + ',y+';
    	end else
    	if p <= 128 then begin
	 TemporaryBuf[1] := #9'sta :bp2';
	 TemporaryBuf[3] := #9'sta :bp2+1';

	 TemporaryBuf[4] := #9'ldy #' + HexByte(Byte(p-1));
     	 TemporaryBuf[5] := #9'mva:rpl (:bp2),y adr.' + tmp + ',y-';
    	end else begin
     	 TemporaryBuf[4] := #9'@move ' + tmp + ' #adr.' + tmp + ' #' + HexValue(p,2);
     	 TemporaryBuf[5] := '~';
	end;

     	TemporaryBuf[6] := '~';//' #9'mwa #adr.'+tmp+' '+tmp;
     	TemporaryBuf[7] := #9'dex';
       end;

// -----------------------------------------------------------------------------

  opt_TEMP_MOVE;
  opt_TEMP_FILL;

  opt_TEMP_IFTMP;
  opt_TEMP_TAIL_IF;
  opt_TEMP_TAIL_CASE;

  // #asm

  if TemporaryBuf[0].IndexOf('#asm:') = 0 then
  begin

    Writer.WriteLn(AsmBlockArray[StrToInt(copy(TemporaryBuf[0], 6, 256))]);

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

                  TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0])) + fortmp(tmp);
    end else
                  writeln('Unassigned: ' + TemporaryBuf[0]);

  //  tmp:=copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);
  //   TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + ':' + fortmp(tmp);

end;  //OptimizeTemporaryBuf


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure TOptimizeTemporary.WriteOut(const a: String);
var
  i: Integer;
begin

  // Debugger.debugger.WriteOut(a);

  // if (pos(#9'jsr ', a) = 1) or (a = '#asm') then ResetOpty; // TODO: Move to OptimizeASM

  if TemporaryBufIndex < High(TemporaryBuf) then
  begin

    if (TemporaryBufIndex >= 0) and (TemporaryBuf[TemporaryBufIndex] <> '') then
    begin

      if TemporaryBuf[TemporaryBufIndex] = '; --- ForToDoCondition' then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;

      if (pos(#9'#for', TemporaryBuf[TemporaryBufIndex]) > 0) then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;
    end;

    Inc(TemporaryBufIndex);
    TemporaryBuf[TemporaryBufIndex] := a;

  end
  else
  begin

    // DebugCall('OptimizeTemporaryBuf.Before',  a+'/'+TemporaryBufToString);
    OptimizeTemporaryBuf;
    // DebugCall('OptimizeTemporaryBuf.After ', a+'/'+TemporaryBufToString);

    if TemporaryBuf[TemporaryBufIndex] <> '' then
    begin

      if TemporaryBuf[TemporaryBufIndex] = '; --- ForToDoCondition' then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;

      if (pos(#9'#for', TemporaryBuf[TemporaryBufIndex]) > 0) then
        if (a = '') or (pos('; optimize ', a) > 0) then exit;
    end;

    if TemporaryBuf[0] <> '~' then
    begin
      if (TemporaryBuf[0] <> '') or (LastTempBuf0 <> TemporaryBuf[0]) then Writer.WriteLn(TemporaryBuf[0]);

      LastTempBuf0 := TemporaryBuf[0];
    end;

    for i := 1 to TemporaryBufIndex do TemporaryBuf[i - 1] := TemporaryBuf[i];

    TemporaryBuf[TemporaryBufIndex] := a;

  end;

end;  //WriteOut

procedure TOptimizeTemporary.Finalize;
var
  i: Integer;
begin

  for i := 0 to High(TemporaryBuf) do WriteOut('');    // flush TemporaryBuf

end;

end.

