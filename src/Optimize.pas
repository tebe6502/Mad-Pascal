unit Optimize;

interface

{$i define.inc}

// ----------------------------------------------------------------------------

	procedure asm65(a: string = ''; comment : string ='');			// OptimizeASM

	procedure OptimizeProgram(MainIndex: Integer);

	procedure ResetOpty;

	procedure WriteOut(a: string);						// OptimizeTemporaryBuf

// ----------------------------------------------------------------------------

implementation

uses Crt, SysUtils, Common;

// ----------------------------------------------------------------------------


procedure ResetOpty;
begin

 optyA := '';
 optyY := '';
 optyBP2 := '';

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure OptimizeProgram(MainIndex: Integer);
var ProcAsBlock: array [1..MAXBLOCKS] of Boolean;				// issue #125 fixed

  procedure MarkNotDead(IdentIndex: Integer);
  var
    ChildIndex, ChildIdentIndex: Integer;
  begin

    Ident[IdentIndex].IsNotDead := TRUE;

    if (Ident[IdentIndex].ProcAsBlock > 0) and (CallGraph[Ident[IdentIndex].ProcAsBlock].NumChildren > 0) and (ProcAsBlock[Ident[IdentIndex].ProcAsBlock] = FALSE) then begin

	ProcAsBlock[Ident[IdentIndex].ProcAsBlock] := TRUE;

  	for ChildIndex := 1 to CallGraph[Ident[IdentIndex].ProcAsBlock].NumChildren do
	   for ChildIdentIndex := 1 to NumIdent do
	      if (Ident[ChildIdentIndex].ProcAsBlock > 0) and (Ident[ChildIdentIndex].ProcAsBlock = CallGraph[Ident[IdentIndex].ProcAsBlock].ChildBlock[ChildIndex]) then
		MarkNotDead(ChildIdentIndex);

     end;

  end;

begin

 fillbyte(ProcAsBlock, sizeof(ProcAsBlock), 0);

// Perform dead code elimination
 MarkNotDead(MainIndex);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure OptimizeTemporaryBuf;
var p, k , q: integer;
    tmp: string;
    yes: Boolean;


  function SKIP(i: integer): Boolean;
  begin

      Result :=	(TemporaryBuf[i] = #9'seq') or (TemporaryBuf[i] = #9'sne') or
		(TemporaryBuf[i] = #9'spl') or (TemporaryBuf[i] = #9'smi') or
		(TemporaryBuf[i] = #9'scc') or (TemporaryBuf[i] = #9'scs') or
		(TemporaryBuf[i] = #9'svc') or (TemporaryBuf[i] = #9'svs') or

		(pos('jne ', TemporaryBuf[i]) > 0) or (pos('jeq ', TemporaryBuf[i]) > 0) or
		(pos('jcc ', TemporaryBuf[i]) > 0) or (pos('jcs ', TemporaryBuf[i]) > 0) or
		(pos('jmi ', TemporaryBuf[i]) > 0) or (pos('jpl ', TemporaryBuf[i]) > 0) or

		(pos('bne ', TemporaryBuf[i]) > 0) or (pos('beq ', TemporaryBuf[i]) > 0) or
		(pos('bcc ', TemporaryBuf[i]) > 0) or (pos('bcs ', TemporaryBuf[i]) > 0) or
		(pos('bmi ', TemporaryBuf[i]) > 0) or (pos('bpl ', TemporaryBuf[i]) > 0);
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


  function fortmp(a: string): string;
  // @FORTMP_xxxx
  // @FORTMP_xxxx+1
  begin

    Result:=a;

//    Result[8] := '?';

    if length(Result) > 12 then
      Result[13] := '_'
    else
      Result := Result + '_0';

  end;


  function GetBYTE(i: integer): integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4));
  end;

  function GetWORD(i, j: integer): integer;
  begin
    Result := GetVAL(copy(TemporaryBuf[i], 6, 4)) + GetVAL(copy(TemporaryBuf[j], 6, 4)) * 256;
  end;


  function GetSTRING(j: integer): string;
  var i: integer;
       a: string;
  begin

    Result := '';
    i:=6;

    a:=TemporaryBuf[j];

    if a<>'' then
     while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
      Result := Result + a[i];
      inc(i);
     end;

  end;


{$i include/opt6502/opt_TEMP_MOVE.inc}
{$i include/opt6502/opt_TEMP_FILL.inc}
{$i include/opt6502/opt_TEMP_TAIL.inc}
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


begin


{
if (pos('l_00E9', TemporaryBuf[3]) > 0) then begin

      for p:=0 to 11 do writeln(TemporaryBuf[p]);
      writeln('-------');

end;
}


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


    if (TemporaryBuf[0] = #9'lda :STACKORIGIN,x') and					// lda :STACKORIGIN,x			; 0
       (pos('sta ', TemporaryBuf[1]) > 0) and						// sta F				; 1
       (TemporaryBuf[2] = #9'lda :STACKORIGIN+STACKWIDTH,x') and			// lda :STACKORIGIN+STACKWIDTH,x	; 2
       (pos('sta ', TemporaryBuf[3]) > 0) and						// sta F+1				; 3
       (TemporaryBuf[4] = #9'dex') and							// dex					; 2
       (TemporaryBuf[5] = ':move') then							//:move					; 3
       begin

	tmp:=TemporaryBuf[6];
	p:=StrToInt(TemporaryBuf[7]);

	if p = 256 then begin
	 TemporaryBuf[1] := #9'sta :bp2';
	 TemporaryBuf[3] := #9'sta :bp2+1';

     	 TemporaryBuf[4] := #9'ldy #$00';
     	 TemporaryBuf[5] := #9'mva:rne (:bp2),y adr.'+tmp+',y+';
    	end else
    	if p <= 128 then begin
	 TemporaryBuf[1] := #9'sta :bp2';
	 TemporaryBuf[3] := #9'sta :bp2+1';

	 TemporaryBuf[4] := #9'ldy #$'+IntToHex(p-1, 2);
     	 TemporaryBuf[5] := #9'mva:rpl (:bp2),y adr.'+tmp+',y-';
    	end else begin
     	 TemporaryBuf[4] := #9'@move '+tmp+' #adr.'+tmp+' #$'+IntToHex(p,2);
     	 TemporaryBuf[5] := '~';
	end;

     	TemporaryBuf[6] := #9'mwa #adr.'+tmp+' '+tmp;
     	TemporaryBuf[7] := #9'dex';
       end;

// -----------------------------------------------------------------------------

   opt_TEMP_MOVE;
   opt_TEMP_FILL;

   opt_TEMP_IFTMP;
   opt_TEMP_TAIL;


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

    if (pos('lda ', TemporaryBuf[0]) > 0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'lda ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if (pos('cmp ', TemporaryBuf[0]) > 0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'cmp ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if (pos('sub ', TemporaryBuf[0]) > 0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'sub ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if (pos('sbc ', TemporaryBuf[0]) > 0) then begin

     if (pos('::#$00', TemporaryBuf[0]) = 0) then TemporaryBuf[0] := #9'sbc ' + fortmp(GetSTRING(0)) + '::#$00';

    end else
    if (pos('sta ', TemporaryBuf[0]) > 0) then
      TemporaryBuf[0] := #9'sta ' + fortmp(GetSTRING(0))
    else
    if (pos('sty ', TemporaryBuf[0]) > 0) then
      TemporaryBuf[0] := #9'sty ' + fortmp(GetSTRING(0))
    else
    if (pos('mva ', TemporaryBuf[0]) > 0) and (pos('mva @FORTMP_', TemporaryBuf[0]) = 0) then begin
     tmp:=copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);

     TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + fortmp(tmp);
    end else
     writeln('Unassigned: ' + TemporaryBuf[0] );

   //  tmp:=copy(TemporaryBuf[0], pos('@FORTMP_', TemporaryBuf[0]), 256);
  //   TemporaryBuf[0] := copy(TemporaryBuf[0], 1, pos(' @FORTMP_', TemporaryBuf[0]) ) + ':' + fortmp(tmp);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure WriteOut(a: string);
var i: integer;
begin

 if (pos(#9'jsr ', a) = 1) or (a = '#asm') then ResetOpty;


 if iOut < High(TemporaryBuf) then begin

    if (iOut >= 0) and (TemporaryBuf[iOut] <> '') then begin

	  if TemporaryBuf[iOut] = '; --- ForToDoCondition' then
	   if (a = '') or (pos('; optimize ', a) > 0) then exit;

	  if (pos(#9'#for', TemporaryBuf[iOut]) > 0) then
	   if (a = '') or (pos('; optimize ', a) > 0) then exit;
    end;

  inc(iOut);
  TemporaryBuf[iOut] := a;

 end else begin

  OptimizeTemporaryBuf;

    if TemporaryBuf[iOut] <> '' then begin

	  if TemporaryBuf[iOut] = '; --- ForToDoCondition' then
	   if (a = '') or (pos('; optimize ', a) > 0) then exit;

	  if (pos(#9'#for', TemporaryBuf[iOut]) > 0) then
	   if (a = '') or (pos('; optimize ', a) > 0) then exit;
    end;

  if TemporaryBuf[0] <> '~' then begin
   if (TemporaryBuf[0] <> '') or (outTmp <> TemporaryBuf[0]) then writeln(OutFile, TemporaryBuf[0]);

   outTmp := TemporaryBuf[0];
  end;

  for i:=1 to iOut do TemporaryBuf[i-1] := TemporaryBuf[i];

  TemporaryBuf[iOut] := a;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure OptimizeASM;
(* -------------------------------------------------------------------------- *)
(* optymalizacja powiodla sie jesli na wyjsciu X=0
(* peephole optimization
(* -------------------------------------------------------------------------- *)
type
    TListing = array [0..1023] of string;

var i, l, k, m, x: integer;
    a, t, {arg,} arg0{, arg1}: string;
    inxUse, found: Boolean;
//    t0, t1, t2, t3: string;
    listing, listing_tmp: TListing;
    s: array [0..15, 0..3] of string;

// -----------------------------------------------------------------------------


   function GetBYTE(i: integer): integer;
   begin
    Result := GetVAL(copy(listing[i], 6, 4));
   end;

   function GetWORD(i,j: integer): integer;
   begin
    Result := GetVAL(copy(listing[i], 6, 4)) + GetVAL(copy(listing[j], 6, 4)) shl 8;
   end;


   function TAY(i: integer): Boolean;
   begin
     Result := listing[i] = #9'tay'
   end;

   function TYA(i: integer): Boolean;
   begin
     Result := listing[i] = #9'tya'
   end;

   function INY(i: integer): Boolean;
   begin
     Result := listing[i] = #9'iny'
   end;

   function DEY(i: integer): Boolean;
   begin
     Result := listing[i] = #9'dey'
   end;

   function INX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inx'
   end;

   function DEX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'dex'
   end;

   function AND_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'and (:bp),y'
   end;

   function ORA_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ora (:bp),y'
   end;

   function EOR_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'eor (:bp),y'
   end;

   function LDA_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda (:bp),y'
   end;

   function CMP_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'cmp (:bp),y'
   end;

   function CMP_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'cmp (:bp2),y'
   end;

   function STA_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta (:bp),y'
   end;

   function STA_BP(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp'
   end;

   function INC_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inc :bp+1'
   end;

   function STA_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp+1'
   end;

   function STY_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sty :bp+1'
   end;

   function LDA_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda (:bp2),y'
   end;

   function LDA_BP2(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :bp2'
   end;

   function LDA_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :bp2+1'
   end;

   function STA_BP2(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp2'
   end;

   function STA_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp2+1'
   end;

   function INC_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inc :bp2+1'
   end;

   function STA_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta (:bp2),y'
   end;

   function ADD_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add (:bp),y'
   end;

   function SUB_BP_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub (:bp),y'
   end;

   function ADD_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add (:bp2),y'
   end;

   function ADC_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc (:bp2),y'
   end;

   function LDA_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda #$00'
   end;

   function ADD_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add #$00'
   end;

   function SUB_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub #$00'
   end;

   function ADC_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc #$00'
   end;

   function CMP_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'cmp #$00'
   end;

   function SBC_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc #$00'
   end;

   function ADC_SBC_IM_0(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'adc #$00') or (listing[i] = #9'sbc #$00')
   end;

   function LDY_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ldy #$00'
   end;

   function AND_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'and #$00'
   end;

   function ORA_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ora #$00'
   end;

   function EOR_IM_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'eor #$00'
   end;

   function ROR_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ror @'
   end;

   function ROL_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'rol @'
   end;

   function LSR_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lsr @'
   end;

   function ASL_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'asl @'
   end;

   function LDY_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'ldy #1'
   end;

   function ROL_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'rol :eax+1'
   end;

   function LDA_EAX_X(i: integer): Boolean;
   begin
     Result := pos(#9'lda :eax', listing[i]) > 0
   end;

   function LDA_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :eax'
   end;

   function LDA_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'lda :eax+1'
   end;

   function STA_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :eax'
   end;

   function STA_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :eax+1'
   end;

   function ADD_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add :eax'
   end;

   function ADD_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'add :eax+1'
   end;

   function ADC_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc :eax'
   end;

   function ADC_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc :eax+1'
   end;

   function SUB_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub :eax'
   end;

   function SUB_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub :eax+1'
   end;

   function SBC_EAX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc :eax'
   end;

   function SBC_EAX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc :eax+1'
   end;


   function STA_im_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta #$00'
   end;

   function STY_im_0(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sty #$00'
   end;

   function LAB_a(i: integer): Boolean;
   begin
     Result := listing[i] = '@'
   end;


   function IX(i: integer): Boolean;
   begin
    Result := pos(',x', listing[i]) > 0;
   end;

   function IY(i: integer): Boolean;
   begin
    Result := pos(',y', listing[i]) > 0;
   end;


   function CMP_IM(i: integer): Boolean;
   begin
     Result := pos(#9'cmp #', listing[i]) = 1;
   end;

   function LDY_IM(i: integer): Boolean;
   begin
     Result := pos(#9'ldy #', listing[i]) = 1;
   end;

   function LDY(i: integer): Boolean;
   begin
     Result := pos(#9'ldy ', listing[i]) = 1;
   end;

   function LDY_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'ldy :STACK', listing[i]) = 1;
   end;

   function STY(i: integer): Boolean;
   begin
     Result := (pos(#9'sty ', listing[i]) = 1) and (pos(#9'sty #$00', listing[i]) = 0);
   end;

   function STY_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'sty :STACK', listing[i]) = 1;
   end;

   function ROR(i: integer): Boolean;
   begin
     Result := pos(#9'ror ', listing[i]) = 1;
   end;

   function ROR_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'ror :STACK', listing[i]) = 1;
   end;

   function LSR(i: integer): Boolean;
   begin
     Result := pos(#9'lsr ', listing[i]) = 1;
   end;

   function LSR_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'lsr :STACK', listing[i]) = 1;
   end;

   function ROL(i: integer): Boolean;
   begin
     Result := pos(#9'rol ', listing[i]) = 1;
   end;

   function ROL_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'rol :STACK', listing[i]) = 1;
   end;

   function ASL(i: integer): Boolean;
   begin
     Result := pos(#9'asl ', listing[i]) = 1;
   end;

   function ASL_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'asl :STACK', listing[i]) = 1;
   end;

   function CMP(i: integer): Boolean;
   begin
     Result := pos(#9'cmp ', listing[i]) = 1;
   end;

   function CMP_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'cmp :STACK', listing[i]) = 1;
   end;

   function MWA(i: integer): Boolean;
   begin
     Result := pos(#9'mwa ', listing[i]) = 1;
   end;

   function MWY(i: integer): Boolean;
   begin
     Result := pos(#9'mwy ', listing[i]) = 1;
   end;

   function MVY(i: integer): Boolean;
   begin
     Result := pos(#9'mvy ', listing[i]) = 1;
   end;

   function MVY_IM(i: integer): Boolean;
   begin
     Result := pos(#9'mvy #', listing[i]) = 1;
   end;

   function MVA_(i: integer): Boolean;
   begin
     Result := (pos(#9'mva ', listing[i]) = 1) and (pos(',y', listing[i]) = 0);
   end;

   function MVA(i: integer): Boolean;
   begin
     Result := pos(#9'mva ', listing[i]) = 1;
   end;

   function MVA_IM(i: integer): Boolean;
   begin
     Result := pos(#9'mva #', listing[i]) = 1;
   end;

   function MVA_IM_0(i: integer): Boolean;
   begin
     Result := pos(#9'mva #$00', listing[i]) = 1;
   end;

   function MVA_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'mva :STACK', listing[i]) = 1;
   end;

   function ORA(i: integer): Boolean;
   begin
     Result := pos(#9'ora ', listing[i]) = 1;
   end;

   function AND_IM(i: integer): Boolean;
   begin
     Result := pos(#9'and #', listing[i]) = 1;
   end;

   function LDA_IM(i: integer): Boolean;
   begin
     Result := pos(#9'lda #', listing[i]) = 1;
   end;

   function LDA_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'lda :STACK', listing[i]) = 1;
   end;

   function LDA_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'lda adr.', listing[i]) = 1) or ((pos(#9'lda ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function LDA(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1) and (pos(#9'lda adr.', listing[i]) = 0) and (pos('.adr.', listing[i]) = 0);
   end;

   function LDA_A(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1);
   end;

   function LDA_Y(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1) and (pos(',y', listing[i]) > 0);
   end;

   function ADD_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'add adr.', listing[i]) = 1) or ((pos(#9'add ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function SUB_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sub adr.', listing[i]) = 1) or ((pos(#9'sub ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function ADC_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'adc adr.', listing[i]) = 1) or ((pos(#9'adc ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function SBC_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc adr.', listing[i]) = 1) or ((pos(#9'sbc ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function STA_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sta adr.', listing[i]) = 1) or ((pos(#9'sta ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function STA(i: integer): Boolean;
   begin
     Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta adr.', listing[i]) = 0) and (pos('.adr.', listing[i]) = 0) and (pos(#9'sta #$00', listing[i]) = 0);
   end;

   function STA_A(i: integer): Boolean;
   begin
     Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta #$00', listing[i]) = 0);
   end;

   function STA_STACK(i: integer): Boolean;
   begin
     Result := pos(#9'sta :STACK', listing[i]) = 1;
   end;

   function INC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'inc :STACK', listing[i]) = 1);
   end;

   function DEC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'dec :STACK', listing[i]) = 1);
   end;

   function INC_(i: integer): Boolean;
   begin
     Result := (pos(#9'inc ', listing[i]) = 1);
   end;

   function DEC_(i: integer): Boolean;
   begin
     Result := (pos(#9'dec ', listing[i]) = 1);
   end;

   function JMP(i: integer): Boolean;
   begin
     Result := (pos(#9'jmp l_', listing[i]) = 1);
   end;


   function ADD(i: integer): Boolean;
   begin
     Result := (pos(#9'add ', listing[i]) = 1);
   end;

   function ADD_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'add #', listing[i]) = 1);
   end;

   function ADC(i: integer): Boolean;
   begin
     Result := (pos(#9'adc ', listing[i]) = 1);
   end;

   function ADC_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'adc #', listing[i]) = 1);
   end;

   function ADD_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'add :STACK', listing[i]) = 1);
   end;

   function ADC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'adc :STACK', listing[i]) = 1);
   end;

   function ADD_SUB_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'add :STACK', listing[i]) = 1) or (pos(#9'sub :STACK', listing[i]) = 1);
   end;

   function ADC_SBC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'adc :STACK', listing[i]) = 1) or (pos(#9'sbc :STACK', listing[i]) = 1);
   end;

   function SUB(i: integer): Boolean;
   begin
     Result := (pos(#9'sub ', listing[i]) = 1);
   end;

   function SUB_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'sub #', listing[i]) = 1);
   end;

   function SBC(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc ', listing[i]) = 1);
   end;

   function SBC_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc #', listing[i]) = 1);
   end;

   function SUB_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'sub :STACK', listing[i]) = 1);
   end;

   function SBC_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'sbc :STACK', listing[i]) = 1);
   end;

   function ADC_SBC_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'adc #', listing[i]) = 1) or (pos(#9'sbc #', listing[i]) = 1);
   end;

   function ADD_SUB_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'add #', listing[i]) = 1) or (pos(#9'sub #', listing[i]) = 1);
   end;

   function ADD_SUB(i: integer): Boolean;
   begin
     Result := (pos(#9'add ', listing[i]) = 1) or (pos(#9'sub ', listing[i]) = 1);
   end;

   function ADD_SUB_VAL(i: integer): Boolean;
   begin
     Result := ((pos(#9'add ', listing[i]) = 1) and (pos(#9'add :STACK', listing[i]) = 0)) or
               ((pos(#9'sub ', listing[i]) = 1) and (pos(#9'sub :STACK', listing[i]) = 0));
   end;

   function ADC_SBC(i: integer): Boolean;
   begin
     Result := (pos(#9'adc ', listing[i]) = 1) or (pos(#9'sbc ', listing[i]) = 1);
   end;

   function ADC_SBC_VAL(i: integer): Boolean;
   begin
     Result := ((pos(#9'adc ', listing[i]) = 1) and (pos(#9'adc :STACK', listing[i]) = 0)) or
               ((pos(#9'sbc ', listing[i]) = 1) and (pos(#9'sbc :STACK', listing[i]) = 0));
   end;

   function EOR(i: integer): Boolean;
   begin
     Result := (pos(#9'eor ', listing[i]) = 1);
   end;

   function AND_(i: integer): Boolean;
   begin
     Result := (pos(#9'and ', listing[i]) = 1);
   end;

   function AND_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'and :STACK', listing[i]) = 1);
   end;

   function ORA_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'ora :STACK', listing[i]) = 1);
   end;

   function EOR_STACK(i: integer): Boolean;
   begin
     Result := (pos(#9'eor :STACK', listing[i]) = 1);
   end;

   function AND_ORA_EOR_STACK(i: integer): Boolean;
   begin
     Result := and_stack(i) or ora_stack(i) or eor_stack(i);
   end;

   function AND_ORA_EOR_IM(i: integer): Boolean;
   begin
     Result := (pos(#9'and #', listing[i]) = 1) or (pos(#9'ora #', listing[i]) = 1) or (pos(#9'eor #', listing[i]) = 1);
   end;

   function AND_ORA_EOR(i: integer): Boolean;
   begin
     Result := (pos(#9'and ', listing[i]) = 1) or (pos(#9'ora ', listing[i]) = 1) or (pos(#9'eor ', listing[i]) = 1);
   end;

   function AND_ORA_EOR_BP2_Y(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'and (:bp2),y') or (listing[i] = #9'ora (:bp2),y') or (listing[i] = #9'eor (:bp2),y');
   end;

   function MWY_BP2(i: integer): Boolean;
   begin
     Result := (pos(#9'mwy ', listing[i]) = 1) and (pos(' :bp2', listing[i]) > 0);
   end;


   function ADD_SUB_AL_CL(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'jsr addAL_CL') or (listing[i] = #9'jsr subAL_CL');
   end;

   function ADD_SUB_AX_CX(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'jsr addAX_CX') or (listing[i] = #9'jsr subAX_CX');
   end;

   function ADD_SUB_EAX_ECX(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'jsr addEAX_ECX') or (listing[i] = #9'jsr subEAX_ECX');
   end;


   function JSR(i: integer): Boolean;
   begin
     Result := (pos(#9'jsr ', listing[i]) = 1);
   end;


   function JEQ(i: integer): Boolean;
   begin
     Result := (pos(#9'jeq ', listing[i]) = 1);
   end;

   function JNE(i: integer): Boolean;
   begin
     Result := (pos(#9'jne ', listing[i]) = 1);
   end;

   function JPL(i: integer): Boolean;
   begin
     Result := (pos(#9'jpl ', listing[i]) = 1);
   end;

   function JMI(i: integer): Boolean;
   begin
     Result := (pos(#9'jmi ', listing[i]) = 1);
   end;

   function JCC(i: integer): Boolean;
   begin
     Result := (pos(#9'jcc ', listing[i]) = 1);
   end;

   function JCS(i: integer): Boolean;
   begin
     Result := (pos(#9'jcs ', listing[i]) = 1);
   end;


   function BEQ(i: integer): Boolean;
   begin
     Result := (pos(#9'beq ', listing[i]) = 1);
   end;

   function BNE(i: integer): Boolean;
   begin
     Result := (pos(#9'bne ', listing[i]) = 1);
   end;

   function BCC(i: integer): Boolean;
   begin
     Result := (pos(#9'bcc ', listing[i]) = 1);
   end;

   function BCS(i: integer): Boolean;
   begin
     Result := (pos(#9'bcs ', listing[i]) = 1);
   end;

   function BPL(i: integer): Boolean;
   begin
     Result := (pos(#9'bpl ', listing[i]) = 1);
   end;

   function BMI(i: integer): Boolean;
   begin
     Result := (pos(#9'bmi ', listing[i]) = 1);
   end;


   function BNE_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bne @+'
   end;

   function SEQ(i: integer): Boolean;
   begin
     Result := listing[i] = #9'seq'
   end;

   function SNE(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sne'
   end;

   function SPL(i: integer): Boolean;
   begin
     Result := listing[i] = #9'spl'
   end;

   function SMI(i: integer): Boolean;
   begin
     Result := listing[i] = #9'smi'
   end;

   function SCC(i: integer): Boolean;
   begin
     Result := listing[i] = #9'scc'
   end;

   function SCS(i: integer): Boolean;
   begin
     Result := listing[i] = #9'scs'
   end;


// !!! kolejny rozkaz po UNUSED_A na pozycji 'i+1' musi koniecznie byc conajmniej 'LDA ' !!!

   function UNUSED_A(i: integer): Boolean;
   begin
     Result := sty_stack(i) or lda_stack(i) or sta_stack(i) or {!!! (pos(#9'lda :eax', listing[i]) = 1) or (pos(#9'sta :eax', listing[i]) = 1) or} lda_im(i) or rol_stack(i) or ror_stack(i) or adc_sbc(i);
   end;


   function onBreak(i: integer): Boolean;
   begin
     Result := (listing[i] = '@') or (pos(#9'jsr ', listing[i]) = 1) or (listing[i] = #9'eif');		// !!! eif !!! koniecznie
   end;


   procedure WriteInstruction(i: integer);
   begin

     if isInterrupt and ( (pos(' :bp', listing[i]) > 0) or (pos(' :STACK', listing[i]) > 0) ) then begin
//       WritelnMsg;

       TextColor(LIGHTRED);

       WriteLn(UnitName[common.optimize.unitIndex].Path + ' (' + IntToStr(common.optimize.line) + ') Error: Illegal instruction in INTERRUPT block ''' + copy(listing[i], 2, 256) + '''');

       NormVideo;

//       FreeTokens;

//       CloseFile(OutFile);
//       Erase(OutFile);

//       Halt(2);
     end;

     WriteOut( listing[i] );

   end;


  function ENDL(i: integer): Boolean;
   begin

     if (i < 0) or (listing[i] = '') then
      Result := False
     else
      Result :=	(listing[i] = #9'.ENDL');

   end;


   function SKIP(i: integer): Boolean;
   begin

     if (i < 0) or (listing[i] = '') then
      Result := False
     else
      Result := seq(i) or sne(i) or spl(i) or smi(i) or scc(i) or scs(i) or
		jeq(i) or jne(i) or jpl(i) or jmi(i) or jcc(i) or jcs(i) or
		beq(i) or bne(i) or bpl(i) or bmi(i) or bcc(i) or bcs(i);
   end;



   function LabelIsUsed(i: integer): Boolean;									// issue #91 fixed

(*

 +#$00Label
 -#$00Label

 *#$02Label
 *#$03Label
 *#$04Label
 *#$08Label

 *+$01Label|Label
 *-$01Label|Label

*)

     procedure LabelTest(const mne: string);
     begin

      case optyY[1] of

       '+','-' : Result := (listing[i] = mne + copy(optyY, 6, 256));

           '*' : if optyY[2] in ['+', '-'] then
	          Result := (listing[i] = mne + copy(optyY,6,pos('|',optyY) - 6)) or (listing[i] = mne + copy(optyY,pos('|',optyY) + 1,256))
		 else
	          Result := (listing[i] = mne + copy(optyY, 6, 256));

      else
       Result := (listing[i] = mne + optyY);
      end;

     end;


   begin

     Result:=false;

     if optyY <> '' then
      if (pos(#9'sta ', listing[i]) = 1) then LabelTest(#9'sta ') else
       if (pos(#9'inc ', listing[i]) = 1) then LabelTest(#9'inc ') else
        if (pos(#9'dec ', listing[i]) = 1) then LabelTest(#9'dec ');

   end;


   function EAX(i: integer): Boolean;
   begin
     Result := (pos(' :eax', listing[i]) > 0);
   end;


   function IFDEF_MUL8(i: integer): Boolean;
   begin
      Result :=	//(listing[i+4] = #9'eif') and
      		//(listing[i+3] = #9'imulCL') and
      		//(listing[i+2] = #9'els') and
		(listing[i+1] = #9'fmulu_8') and
		(listing[i]   = #9'.ifdef fmulinit');
   end;

   function IFDEF_MUL16(i: integer): Boolean;
   begin
      Result :=	//(listing[i+4] = #9'eif') and
		//(listing[i+3] = #9'imulCX') and
		//(listing[i+2] = #9'els') and
		(listing[i+1] = #9'fmulu_16') and
      		(listing[i]   = #9'.ifdef fmulinit');
   end;


   procedure LDA_STA_ADR(i, q: integer; op: char);
   begin

	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + op +'$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if (lda_adr(i+8) = false) and (sta_adr(i+9) = false) then exit;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if (lda_adr(i+10) = false) and (sta_adr(i+11) = false) then exit;

	if lda_adr(i+10) and iy(i+10) then begin
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+11) and iy(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if (lda_adr(i+12) = false) and (sta_adr(i+13) = false) then exit;

	if lda_adr(i+12) and iy(i+12) then begin
	 delete(listing[i+12], pos(',y', listing[i+12]), 2);
	 listing[i+12] := listing[i+12] + op + '$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + op + '$' + IntToHex(q, 2) + ',y';
	end;

   end;

// -----------------------------------------------------------------------------

   procedure Rebuild;
   var k, i: integer;
   begin

    k:=0;
    for i := 0 to l - 1 do
     if (listing[i] <> '') and (listing[i][1] <> ';') then begin
      listing[k] := listing[i];
      inc(k);
     end;

    listing[k]   := '';
    listing[k+1] := '';
    listing[k+2] := '';

    l := k;
   end;

// -----------------------------------------------------------------------------

   function GetString(a: string): string; overload;
   var i: integer;
   begin

    Result := '';
    i:=6;

    if a<>'' then
     while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
      Result := Result + a[i];
      inc(i);
     end;

   end;


   function GetString(j: integer): string; overload;
   var i: integer;
       a: string;
   begin

    Result := '';
    i:=6;

    a:=listing[j];

    if a<>'' then
     while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
      Result := Result + a[i];
      inc(i);
     end;

   end;


   function GetStringLast(j: integer): string; overload;
   var i: integer;
       a: string;
   begin

    Result := '';

    a:=listing[j];

    if a<>'' then begin
     i:=length(a);

     while not(a[i] in [' ',#9]) and (i>0) do dec(i);

     Result:=copy(a, i+1, 256);
    end;

   end;


  function GetARG(n: byte; x: shortint; reset: Boolean = true): string;
  var i: integer;
      a: string;
  begin

   Result:='';

   if x < 0 then exit;

   a := s[x][n];

   if (a='') then begin

    case n of
     0: Result := ':STACKORIGIN+'+IntToStr(shortint(x+8));
     1: Result := ':STACKORIGIN+STACKWIDTH+'+IntToStr(shortint(x+8));
     2: Result := ':STACKORIGIN+STACKWIDTH*2+'+IntToStr(shortint(x+8));
     3: Result := ':STACKORIGIN+STACKWIDTH*3+'+IntToStr(shortint(x+8));
    end;

   end else begin

    i := 6;

    while a[i] in [' ',#9] do inc(i);

    while not(a[i] in [' ',#9]) and (i <= length(a)) do begin
     Result := Result + a[i];
     inc(i);
    end;

    if reset then s[x][n] := '';

   end;

  end;


  function RemoveUnusedSTACK: Boolean;
  var j: byte;
      i: integer;
      cnt_l,					// licznik odczytow stosu
      cnt_s: array [0..7+1, 0..3] of Boolean;	// licznik zapisow stosu


   procedure Clear;
   var i: byte;
   begin

    for i := 0 to 15 do begin
     s[i][0] := '';
     s[i][1] := '';
     s[i][2] := '';
     s[i][3] := '';
    end;

    fillchar(cnt_l, sizeof(cnt_l), false);
    fillchar(cnt_s, sizeof(cnt_s), false);

   end;


   function unrelated(i: integer): Boolean;	// unrelated stack references
   var j, k: byte;
   begin

     Result := false;

     for j := 0 to 7 do
      for k := 0 to 3 do
       if pos(GetARG(k, j, false), listing[i]) > 0 then exit( (cnt_s[j, k] and (cnt_l[j, k] = false)) or		// sa zapisy, brak odczytow
	                                                      ((cnt_s[j, k] = false) and cnt_l[j, k]) );		// brak zapisow, sa odczyty


    // wyjatek dla :STACKORIGIN+16 (cnt_s[8,k] ; cnt_l[8,k]) ktory mapuje :EAX

      for k := 0 to 3 do
       if pos(GetARG(k, 8, false), listing[i]) > 0 then 								// sa zapisy, brak odczytu
         exit( (cnt_s[8, 0] or cnt_s[8 ,1] or cnt_s[8, 2] or cnt_s[8, 3] = true ) and (cnt_l[8, 0] or cnt_l[8, 1] or cnt_l[8, 2] or cnt_l[8, 3] = false) );

{
;----	4x zapis :EAX, 1x odczyt :EAX

	lda SCORE
	sta :eax
	lda SCORE+1
	sta :eax+1
	lda SCORE+2
	sta :eax+2
	lda SCORE+3
	sta :eax+3
	lda #$0A
	sta :ecx
	lda #$00
	sta :ecx+1
	jsr idivEAX_CX
	ldy :STACKORIGIN+9
	lda :eax
	sta adr.TB,y


;----	 zapis i odczyt :EAX+1 (byte * 256)

	lda A
	sta :eax+1
	lda #$00
	sta A
	lda :eax+1
	sta A+1
}
   end;


  begin

  Result:=false;

 // szukamy pojedynczych odwolan do :STACKORIGIN+N

  Rebuild;

  Clear;

  // !!!!!!!!!!!!!!!!!!!!
  // czytamy listing szukajac zapisow :STACKORIGIN (STA, STY), kazde inne odwolanie do :STACKORIGIN traktujemy jako odczyt
  // jesli mamy tylko zapisy bez odczytow to kasujemy takie odwolanie
  // !!!!!!!!!!!!!!!!!!!!

  for i := 0 to l - 1 do 	       // zliczamy odwolania do :STACKORIGIN+N
   if (pos(' :STACK', listing[i]) > 0) then

     if sta_stack(i) or sty_stack(i) then begin

      for j := 0 to 7+1 do
       if pos(GetARG(0, j, false), listing[i]) > 0 then begin cnt_s[j, 0] := true; Break end else
        if pos(GetARG(1, j, false), listing[i]) > 0 then begin cnt_s[j, 1] := true; Break end else
         if pos(GetARG(2, j, false), listing[i]) > 0 then begin cnt_s[j, 2] := true; Break end else
          if pos(GetARG(3, j, false), listing[i]) > 0 then begin cnt_s[j, 3] := true; Break end;

     end else begin

      for j := 0 to 7+1 do
       if pos(GetARG(0, j, false), listing[i]) > 0 then begin cnt_l[j, 0] := true; Break end else
        if pos(GetARG(1, j, false), listing[i]) > 0 then begin cnt_l[j, 1] := true; Break end else
         if pos(GetARG(2, j, false), listing[i]) > 0 then begin cnt_l[j, 2] := true; Break end else
          if pos(GetARG(3, j, false), listing[i]) > 0 then begin cnt_l[j, 3] := true; Break end;

     end;


  for i := 0 to l - 1 do
   if (pos(' :STACK', listing[i]) > 0) then
    if unrelated(i) then begin
      a := listing[i];		// zamieniamy na potencjalne 'illegal instruction'
      k:=pos(' :STACK', a);
      delete(a, k, 256);
      insert(' #$00', a, k);

      listing[i] := a;

      Result := true;
    end;

  end;		// RemoveUnusedSTACK


{$i include/opt6502/opt_STA_0.inc}
{$i include/opt6502/opt_STACK.inc}
{$i include/opt6502/opt_STACK_INX.inc}
{$i include/opt6502/opt_STACK_ADD.inc}
{$i include/opt6502/opt_STACK_CMP.inc}
{$i include/opt6502/opt_STACK_ADR.inc}
{$i include/opt6502/opt_STACK_AL_CL.inc}
{$i include/opt6502/opt_STACK_AX_CX.inc}
{$i include/opt6502/opt_STACK_EAX_ECX.inc}
{$i include/opt6502/opt_STACK_PRINT.inc}
{$i include/opt6502/opt_CMP_BRANCH.inc}
{$i include/opt6502/opt_CMP_BP2.inc}
{$i include/opt6502/opt_CMP_LOCAL.inc}
{$i include/opt6502/opt_CMP_LT_GTEQ.inc}
{$i include/opt6502/opt_CMP_LTEQ.inc}
{$i include/opt6502/opt_CMP_GT.inc}
{$i include/opt6502/opt_CMP_NE_EQ.inc}
{$i include/opt6502/opt_CMP.inc}


 function PeepholeOptimization_STACK: Boolean;
 var i, p: integer;
     tmp: string;
 begin

  Result := true;

  tmp:='';

  for i := 0 to l - 1 do begin

   if jsr(i) or cmp(i) or SKIP(i) then Break;

   if mwy_bp2(i) then
    if tmp = listing[i] then
     listing[i] := ''
    else
     tmp := listing[i];

  end;


  Rebuild;

  for i := 0 to l - 1 do begin


{
if (pos('@printSTRING', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


     if opt_LT_GTEQ(i) = false then begin Result := false; Break end;
     if opt_LTEQ(i) = false then begin Result := false; Break end;
     if opt_GT(i) = false then begin Result := false; Break end;
     if opt_NE_EQ(i) = false then begin Result := false; Break end;

     if opt_CMP(i) = false then begin Result := false; Break end;

     if opt_BRANCH(i) = false then begin Result := false; Break end;

     if opt_STACK(i) = false then begin Result := false; Break end;
     if opt_STACK_INX(i) = false then begin Result := false; Break end;
     if opt_STACK_ADD(i) = false then begin Result := false; Break end;
     if opt_STACK_CMP(i) = false then begin Result := false; Break end;
     if opt_STACK_ADR(i) = false then begin Result := false; Break end;
     if opt_STACK_AL_CL(i) = false then begin Result := false; Break end;
     if opt_STACK_AX_CX(i) = false then begin Result := false; Break end;
     if opt_STACK_EAX_ECX(i) = false then begin Result := false; Break end;
     if opt_STACK_PRINT(i) = false then begin Result := false; Break end;

  end;

 end;	//PeepholeOptimization_STACK


function OptimizeEAX: Boolean;
var i: integer;
    tmp: string;
begin

 Result := false;

 for i:=0 to l-1 do

    if (pos(' :eax', listing[i]) = 5) and (pos(#9'.if', listing[i+1]) = 0) then begin
      Result := true;

      tmp := copy(listing[i], 6, 256);

      if tmp = ':eax' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+16' else
       if tmp = ':eax+1' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+STACKWIDTH+16' else
        if tmp = ':eax+2' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+STACKWIDTH*2+16' else
         if tmp = ':eax+3' then listing[i] := copy(listing[i], 1, 5) + ':STACKORIGIN+STACKWIDTH*3+16';

    end;

end;


procedure OptimizeEAX_OFF;
var i: integer;
    tmp: string;
begin

 for i:=0 to l-1 do

    if pos(' :STACKORIGIN+', listing[i]) = 5 then begin
      tmp := copy(listing[i], 6, 256);

      if tmp = ':STACKORIGIN+16' then listing[i] := copy(listing[i], 1, 5) + ':eax' else
       if tmp = ':STACKORIGIN+STACKWIDTH+16' then listing[i] := copy(listing[i], 1, 5) + ':eax+1' else
        if tmp = ':STACKORIGIN+STACKWIDTH*2+16' then listing[i] := copy(listing[i], 1, 5) + ':eax+2' else
         if tmp = ':STACKORIGIN+STACKWIDTH*3+16' then listing[i] := copy(listing[i], 1, 5) + ':eax+3';

    end;

end;


 procedure OptimizeAssignment;
 var k: integer;


{$i include/opt6502/opt_STA_ADD.inc}
{$i include/opt6502/opt_STA_LDY.inc}
{$i include/opt6502/opt_STA_BP.inc}
{$i include/opt6502/opt_STA_LSR.inc}
{$i include/opt6502/opt_STA_IMUL.inc}
{$i include/opt6502/opt_STA_IMUL_CX.inc}
{$i include/opt6502/opt_STA_ZTMP.inc}


   function PeepholeOptimization_END: Boolean;
   var i, p, k: integer;
       tmp, old: string;
       yes, ok: Boolean;
   begin

    Result:=true;

    Rebuild;

    tmp:='';
    old:='';

    for i := 0 to l - 1 do begin

{$i include/opt6502/opt_END_STA.inc}

    end;

   end;	//PeepholeOptimization_END



   function PeepholeOptimization_STA: Boolean;
   var i, p: integer;
   begin

   Result:=true;

   Rebuild;

   for i := 0 to l - 1 do begin


{
if (pos('ora (:bp2),y', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


     if opt_STA_ADD(i) = false then begin Result := false; Break end;
     if opt_STA_LDY(i) = false then begin Result := false; Break end;
     if opt_STA_BP(i) = false then begin Result := false; Break end;
     if opt_STA_LSR(i) = false then begin Result := false; Break end;
     if opt_STA_IMUL(i) = false then begin Result := false; Break end;
     if opt_STA_IMUL_CX(i) = false then begin Result := false; Break end;
     if opt_STA_ZTMP(i) = false then begin Result := false; Break end;

   end;

  end;	//PeepholeOptimization_STA

{$i include/opt65c02/opt_STZ.inc}

{$i include/opt6502/opt_LDA.inc}
{$i include/opt6502/opt_TAY.inc}
{$i include/opt6502/opt_LDY.inc}
{$i include/opt6502/opt_AND.inc}
{$i include/opt6502/opt_ORA.inc}
{$i include/opt6502/opt_EOR.inc}
{$i include/opt6502/opt_NOT.inc}
{$i include/opt6502/opt_ADD.inc}
{$i include/opt6502/opt_SUB.inc}
{$i include/opt6502/opt_LSR.inc}
{$i include/opt6502/opt_ASL.inc}
{$i include/opt6502/opt_SPL.inc}
{$i include/opt6502/opt_POKE.inc}
{$i include/opt6502/opt_BP.inc}
{$i include/opt6502/opt_BP_ADR.inc}
{$i include/opt6502/opt_BP2_ADR.inc}
{$i include/opt6502/opt_ADR.inc}
{$i include/opt6502/opt_FORTMP.inc}


  function PeepholeOptimization: Boolean;
  var p, i: integer;
  begin

  Result:=true;

  Rebuild;

  for i := 0 to l - 1 do begin

{
if (pos('lda DST', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


    if opt_FORTMP(i) = false then begin Result := false; Break end;


    if (i = l - 1) and										// "samotna" instrukcja na koncu bloku
       (sta_stack(i) or sty_stack(i) or lda_a(i) or ldy(i) or and_ora_eor(i) or {iny(i) or}	// !!! 'iny' moze poprzedzac 'scc'
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i) or adc(i) or sbc(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 2) and
       SKIP(i+1) and										// sta :STACKORIGIN			; 1
       sta_stack(i) then									// SKIP					; 0
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 2) and										// "samotna" instrukcja na koncu bloku
       jmp(i+1) and										// jmp l_
       (sta_stack(i) or sty_stack(i) or lda_a(i) or ldy(i) or and_ora_eor(i) or iny(i) or
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i) or adc(i) or sbc(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 2) and										// "samotna" instrukcja na koncu bloku
       sta_im_0(i) and
       iny(i+1) then
     begin
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false; Break;
     end;


    if (i = l - 3) and										// "samotna" instrukcja na koncu bloku
       ((lda_a(i+1) and (lda_stack(i+1) = false)) or tya(i+1)) and
       sta_a(i+2) and

       (lda_a(i) or and_ora_eor(i) or
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 3) and										// "samotna" instrukcja na koncu bloku
       sta_stack(i) and
       (jne(i+1) or jeq(i+1)) and
       ((pos('l_', listing[i+2]) = 1) or (pos('b_', listing[i+2]) = 1)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 3) and
       iny(i) and										// iny					; 0
       and_ora_eor(i+1) and (iy(i+1) = false) and						// and|ora|eor				; 1
       sta_a(i+2) and (iy(i+2) = false) then							// sta					; 2
     begin
	listing[i]   := '';

	Result:=false; Break;
     end;


    if (i = l - 4) and										// "samotna" instrukcja na koncu bloku
       lda_a(i+1) and (lda_stack(i+1) = false) and
       sta_a(i+2) and
       sta_a(i+3) and

       (lda_a(i) or and_ora_eor(i) or
        lsr_stack(i) or asl_stack(i) or ror_stack(i) or rol_stack(i) or
        lsr_a(i) or asl_a(i) or ror_a(i) or rol_a(i)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if (i = l - 4) and
       lda_stack(i) and										// lda :STACKORIGIN			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ((lda_a(i+2) and (lda_stack(i+2) = false)) or tya(i+2)) and				// lda|tya				; 2
       sta_a(i+3) then										// sta					; 3
     begin
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false; Break;
     end;


    if (i = l - 4) and
       iny(i) and										// iny					; 0
       lda_a(i+1) and (iy(i+1) = false) and							// lda					; 1
       and_ora_eor(i+2) and (iy(i+2) = false) and						// and|ora|eor				; 2
       sta_a(i+3) and (iy(i+3) = false) then							// sta					; 3
     begin
	listing[i]   := '';

	Result:=false; Break;
     end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda					; 0
       and_im(i+1) and										// and #				; 1
       (listing[i+2] = #9'jsr #$00') and							// jsr #$00				; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       (listing[i+5] = #9'lda @BYTE.MOD.RESULT') then						// lda @BYTE.MOD.RESULT			; 5
       begin
	listing[i+2] := listing[i+4];
	listing[i+3] := '';
	listing[i+4] := listing[i];
	listing[i+5] := listing[i+1];

	listing[i]   := '';
	listing[i+1] := #9'lda #$00';

	Result:=false; Break;
       end;


    if (listing[i] = #9'jsr #$00') and								// jsr #$00				; 0
       (listing[i+1] = #9'lda @BYTE.MOD.RESULT') then						// lda @BYTE.MOD.RESULT			; 1
       begin
	listing[i]   := '';
	listing[i+1] := '';

	Result:=false; Break;
       end;


    if (listing[i] = #9'jsr #$00') and								// jsr #$00				; 0
       (listing[i+1] = #9'ldy @BYTE.MOD.RESULT') then						// ldy @BYTE.MOD.RESULT			; 1
       begin
	listing[i]   := #9'tay';
	listing[i+1] := '';

	Result:=false; Break;
       end;


     if opt_STA_0(i) = false then begin Result := false; Break end;

     if opt_LDA(i) = false then begin Result := false; Break end;
     if opt_TAY(i) = false then begin Result := false; Break end;
     if opt_LDY(i) = false then begin Result := false; Break end;
     if opt_BP(i) = false then begin Result := false; Break end;
     if opt_AND(i) = false then begin Result := false; Break end;
     if opt_ORA(i) = false then begin Result := false; Break end;
     if opt_EOR(i) = false then begin Result := false; Break end;
     if opt_NOT(i) = false then begin Result := false; Break end;
     if opt_ADD(i) = false then begin Result := false; Break end;
     if opt_SUB(i) = false then begin Result := false; Break end;
     if opt_LSR(i) = false then begin Result := false; Break end;
     if opt_ASL(i) = false then begin Result := false; Break end;
     if opt_SPL(i) = false then begin Result := false; Break end;
     if opt_ADR(i) = false then begin Result := false; Break end;
     if opt_BP_ADR(i) = false then begin Result := false; Break end;
     if opt_BP2_ADR(i) = false then begin Result := false; Break end;
     if opt_POKE(i) = false then begin Result := false; Break end;

     if target.cpu <> CPU_6502 then begin

       if opt_STZ(i) = false then begin Result := false; Break end;

     end;

  end;

 end;			// Peepholeoptimization


 begin			// OptimizeAssignment

  repeat until PeepholeOptimization;     while RemoveUnusedSTACK do repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_STA; while RemoveUnusedSTACK do repeat until PeepholeOptimization;
  repeat until PeepholeOptimization_END; while RemoveUnusedSTACK do repeat until PeepholeOptimization;

 end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


 function OptimizeRelation: Boolean;
 var i, p: integer;
     tmp: string;
     yes: Boolean;
 begin

  Result := true;

  // usuwamy puste '@'
  for i := 0 to l - 1 do begin
   if (pos('@+', listing[i]) > 0) then Break;
   if listing[i] = '@' then listing[i] := '';
  end;


  Rebuild;

  for i := 0 to l - 1 do begin


{
if (pos('cmp #$29', listing[i]) > 0) then begin

      for p:=0 to l-1 do writeln(listing[p]);
      writeln('-------');

end;
}


    if cmp(i) and										// cmp				; 0
       lab_a(i+1) and 										//@				; 1
       (jeq(i+2) or jne(i+2)) and 								// jeq|jne			; 2
       lab_a(i+3) then 										//@				; 3
     begin
      listing[i+3] := '';

      Result:=false; Break;
     end;


    if lda_im(i) and 										// lda #$			; 0
       add_im(i+1) and										// add #$			; 1
       sta(i+2) and										// sta				; 2
												//				; 3
       (adc(i+4) = false) then									//~adc				; 4
     begin

      p := GetBYTE(i) + GetBYTE(i+1);

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';

      Result:=false; Break;
     end;


    if lda_im(i) and 										// lda #$			; 0
       sub_im(i+1) and										// sub #$			; 1
       sta(i+2) and										// sta				; 2
												//				; 3
       (sbc(i+4) = false) then									//~sbc				; 4
     begin

      p := GetBYTE(i) - GetBYTE(i+1);

      listing[i]   := #9'lda #$' + IntToHex(p and $ff, 2);
      listing[i+1] := '';

      Result:=false; Break;
     end;


    if lda(i) and										// lda				; 0
       ldy_1(i+1) and										// ldy #1			; 1
       (listing[i+2] = #9'and #$00') and							// and #$00			; 2
       bne(i+3) and										// bne @+			; 3
       lda(i+4) then										// lda				; 4
     begin
	listing[i] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false; Break;
     end;


    if (i>0) and (listing[i] = #9'and #$00') then						// lda #$00			; -1
     if lda_im_0(i-1) then begin								// and #$00			; 0
	listing[i] := '';
	Result:=false; Break;
     end;


    if lda_im_0(i) and										// lda #$00			; 0
       bne(i+1) and										// bne				; 1
       lda(i+2) then										// lda				; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if lda(i) and										// lda A			; 0
       SKIP(i+1) and										// SKIP				; 1
       lda(i+2) and										// lda A			; 2
       (listing[i] = listing[i+2]) then
     begin
	listing[i+2] := '';
	Result:=false; Break;
     end;


    if (lda_a(i) or adc_sbc(i)) and								// lda|adc|sbc			; 0
       ((listing[i+1] = #9'eor #$00') or (listing[i+1] = #9'ora #$00')) and			// eor|ora #$00			; 1
       SKIP(i+2) then										// SKIP				; 2
     begin
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if and_ora_eor(i) and									// and|ora|eor			; 0
       ((listing[i+1] = #9'eor #$00') or (listing[i+1] = #9'ora #$00')) and			// eor|ora #$00			; 1
       SKIP(i+2) then										// SKIP				; 2
     begin
	listing[i+1] := '';
	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+9		; 0
       iny(i+1) and										// iny				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+9		; 2
       cmp(i+3) then										// cmp				; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := '';

	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+9		; 0
       lda(i+1) and										// lda				; 1
       AND_ORA_EOR_STACK(i+2) then 								// ora|and|eor :STACKORIGIN+9	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sty_stack(i) and										// sty :STACKORIGIN+10		; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+9		; 1
       AND_ORA_EOR_STACK(i+2) and								// ora|and|eor :STACKORIGIN+10	; 2
       sta_stack(i+3) then									// sta :STACKORIGIN+9		; 3
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
          (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sty_stack(i) and										// sty :STACKORIGIN+10		; 0
       lda(i+1) and										// lda 				; 1
       add_stack(i+2) and									// add :STACKORIGIN+10		; 2
       sta(i+3) then										// sta				; 3
       if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	Result:=false; Break;
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN		; 1
       AND_ORA_EOR(i+2) and (and_ora_eor_stack(i+2) = false) and				// ora|and|eor			; 2
       sta_stack(i+3) and									// sta :STACKORIGIN		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH	; 4
       bne(i+5) and										// bne @+			; 5
       lda_stack(i+6) then									// lda :STACKORIGIN		; 6
       if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
          (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
          (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i]   := listing[i+5];

//	listing[i+3] := '';

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	Result:=false; Break;
       end;


    if (and_ora_eor(i) or asl_a(i) or rol_a(i) or lsr_a(i) or ror_a(i)) and (iy(i) = false) and	// and|ora|eor			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+N		; 1
       ldy_1(i+2) and										// ldy #1			; 2
       lda_stack(i+3) and 									// lda :STACKORIGIN+N		; 3
       (bne(i+4) or beq(i+4)) then								// bne|beq			; 4
     if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then
      begin
       listing[i+1] := '';
       listing[i+3] := listing[i];
       listing[i]   := '';
       Result:=false; Break;
      end;


    if (sty_stack(i) or sta_stack(i)) and							// sty|sta :STACKORIGIN		; 0
       mva_stack(i+1) and									// mva :STACKORIGIN STOP	; 1
       (copy(listing[i], 6, 256) = GetString(i+1)) then
     begin
	listing[i+1] := copy(listing[i], 1, 5) + copy(listing[i+1], length(GetString(i+1)) + 7, 256);
	listing[i]   := '';
	Result:=false; Break;
     end;


// -----------------------------------------------------------------------------

     if opt_LOCAL(i) = false then begin Result := false; Break end;

     if opt_LT_GTEQ(i) = false then begin Result := false; Break end;
     if opt_LTEQ(i) = false then begin Result := false; Break end;
     if opt_GT(i) = false then begin Result := false; Break end;
     if opt_NE_EQ(i) = false then begin Result := false; Break end;

     if opt_CMP(i) = false then begin Result := false; Break end;
     if opt_CMP_BP2(i) = false then begin Result := false; Break end;

     if opt_BRANCH(i) = false then begin Result := false; Break end;

// -----------------------------------------------------------------------------

{$i include/opt6502/opt_IF_AND.inc}
{$i include/opt6502/opt_IF_OR.inc}
{$i include/opt6502/opt_WHILE_AND.inc}
{$i include/opt6502/opt_WHILE_OR.inc}
{$i include/opt6502/opt_BOOLEAN_AND.inc}

// -----------------------------------------------------------------------------

  end;   // for

 end;	// OptimizeRelation


 procedure index(k: byte; x: integer; msb: Boolean = true);
 var m: byte;
 begin

   if msb then begin

	listing[l]   := #9'lda ' + GetARG(0, x);
	listing[l+1] := #9'sta ' + GetARG(0, x);
	listing[l+2] := #9'lda ' + GetARG(1, x);

	inc(l, 3);

	for m := 0 to k - 1 do begin

	  listing[l]   := #9'asl ' + GetARG(0, x);
	  listing[l+1] := #9'rol @';

	  inc(l, 2);
	end;

	listing[l]   := #9'sta ' + GetARG(1, x);
	listing[l+1] := #9'lda ' + GetARG(0, x);
	listing[l+2] := #9'sta ' + GetARG(0, x);

   end else begin

	listing[l]   := #9'lda ' + GetARG(1, x);
	listing[l+1] := #9'sta ' + GetARG(1, x);
	listing[l+2] := #9'lda ' + GetARG(0, x);

	inc(l, 3);

	for m := 0 to k - 1 do begin

	  listing[l]   := #9'asl @';
	  listing[l+1] := #9'rol ' + GetARG(1, x);

	  inc(l, 2);
	end;

	listing[l]   := #9'sta ' + GetARG(0, x);
	listing[l+1] := #9'lda ' + GetARG(1, x);
	listing[l+2] := #9'sta ' + GetARG(1, x);

   end;

   inc(l, 3);

 end;	// index


{$i include/opt6502/opt_IMUL_CL.inc}

{$i include/opt6502/opt_inline_POKE.inc}
{$i include/opt6502/opt_inline_PEEK.inc}


begin				// OptimizeASM

 l:=0;
 x:=0;

 arg0 := '';
 //arg1 := '';

 inxUse := false;

 for i := 0 to High(s) do
  for k := 0 to 3 do s[i][k] := '';

 for i := 0 to High(listing) do listing[i]:='';


 for i := 0 to High(OptimizeBuf) - 1 do begin
  a := OptimizeBuf[i];

  if (a <> '') and (pos(';', a) = 0) then begin

   t:=a;

   if pos(#9'inx', a) > 0 then begin inc(x); inxUse:=true; t:='' end;
   if pos(#9'dex', a) > 0 then begin dec(x); t:='' end;


   if (pos('@print', a) > 0) then begin x:=51; arg0:='@print'; resetOpty; Break end;		// zakoncz optymalizacje niepowodzeniem

     if (pos(#9'jsr ', a) > 0) or (pos('m@', a) > 0) then begin

      if (pos(#9'jsr ', a) > 0) then
       arg0 := copy(a, 6, 256)
      else
       arg0 := copy(a, 2, 256);


      if arg0='@expandSHORT2SMALL1' then begin
       t:='';

       listing[l]   := #9'ldy #$00';
       listing[l+1] := #9'lda '+GetARG(0, x-1);
       listing[l+2] := #9'spl';
       listing[l+3] := #9'dey';
       listing[l+4] := #9'sty '+GetARG(1, x-1);
       listing[l+5] := #9'sta '+GetARG(0, x-1);

       inc(l, 6);
      end else
      if arg0='@expandSHORT2SMALL' then begin
       t:='';

       listing[l]   := #9'ldy #$00';
       listing[l+1] := #9'lda '+GetARG(0, x);
       listing[l+2] := #9'spl';
       listing[l+3] := #9'dey';
       listing[l+4] := #9'sty '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(0, x);

       inc(l, 6);
      end else
      if arg0 = '@expandToCARD.SHORT' then begin
	t:='';

	if (s[x][1]='') and (s[x][2]='') and (s[x][3]='') then begin

	listing[l]   := #9'ldy #$00';
	listing[l+1] := #9'lda '+GetARG(0, x);
	listing[l+2] := #9'spl';
	listing[l+3] := #9'dey';
	listing[l+4] := #9'sta '+GetARG(0, x);
	listing[l+5] := #9'sty '+GetARG(1, x);
	listing[l+6] := #9'sty '+GetARG(2, x);
	listing[l+7] := #9'sty '+GetARG(3, x);

	inc(l, 8);
	end;

      end else
      if arg0 = '@expandToCARD1.SHORT' then begin
	t:='';

	if (s[x-1][1]='') and (s[x-1][2]='') and (s[x-1][3]='') then begin

	listing[l]   := #9'ldy #$00';
	listing[l+1] := #9'lda '+GetARG(0, x-1);
	listing[l+2] := #9'spl';
	listing[l+3] := #9'dey';
	listing[l+4] := #9'sta '+GetARG(0, x-1);
	listing[l+5] := #9'sty '+GetARG(1, x-1);
	listing[l+6] := #9'sty '+GetARG(2, x-1);
	listing[l+7] := #9'sty '+GetARG(3, x-1);

	inc(l, 8);
	end;

      end else
      if arg0 = '@expandToCARD.SMALL' then begin
	t:='';

	if (s[x][2]='') and (s[x][3]='') then begin

	listing[l]   := #9'lda '+GetARG(0, x);
	listing[l+1] := #9'sta '+GetARG(0, x);
	listing[l+2] := #9'ldy #$00';
	listing[l+3] := #9'lda '+GetARG(1, x);
	listing[l+4] := #9'spl';
	listing[l+5] := #9'dey';
	listing[l+6] := #9'sta '+GetARG(1, x);
	listing[l+7] := #9'sty '+GetARG(2, x);
	listing[l+8] := #9'sty '+GetARG(3, x);

	inc(l, 9);
	end;

      end else
      if arg0 = '@expandToCARD1.SMALL' then begin
	t:='';

	if (s[x-1][2]='') and (s[x-1][3]='') then begin

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'ldy #$00';
	listing[l+3] := #9'lda '+GetARG(1, x-1);
	listing[l+4] := #9'spl';
	listing[l+5] := #9'dey';
	listing[l+6] := #9'sta '+GetARG(1, x-1);
	listing[l+7] := #9'sty '+GetARG(2, x-1);
	listing[l+8] := #9'sty '+GetARG(3, x-1);

	inc(l, 9);
	end;

      end else

      if arg0 = '@expandToREAL' then begin
	t:='';

	s[x][3] := '';					// -> :STACKORIGIN+STACKWIDTH*3

	listing[l]   := #9'lda ' + GetARG(2, x);
	listing[l+1] := #9'sta ' + GetARG(3, x);
	listing[l+2] := #9'lda ' + GetARG(1, x);
	listing[l+3] := #9'sta ' + GetARG(2, x);
	listing[l+4] := #9'lda ' + GetARG(0, x);
	listing[l+5] := #9'sta ' + GetARG(1, x);
	listing[l+6] := #9'lda #$00';

	s[x][0] := '';					// -> :STACKORIGIN
	listing[l+7] := #9'sta ' + GetARG(0, x);

	inc(l,8);

      end else
      if arg0 = '@expandToREAL1' then begin
	t:='';

	s[x-1][3] := '';				// -> :STACKORIGIN-1+STACKWIDTH*3

	listing[l]   := #9'lda ' + GetARG(2, x-1);
	listing[l+1] := #9'sta ' + GetARG(3, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda ' + GetARG(0, x-1);
	listing[l+5] := #9'sta ' + GetARG(1, x-1);
	listing[l+6] := #9'lda #$00';

	s[x-1][0] := '';				// -> :STACKORIGIN-1
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l,8);

      end else

      if arg0 = 'negBYTE' then begin
       t:='';

       listing[l]   := #9'lda #$00';
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x);

       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x);
       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x);
       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x);

       inc(l, 12);
      end else
      if arg0 = 'negWORD' then begin
       t:='';

       listing[l]   := #9'lda #$00';
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x);
       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x);

       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x);
       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x);

       inc(l, 12);
      end else
{
      if arg0 = 'notBOOLEAN' then begin
       t:='';

       listing[l]   := #9'ldy #1';			// !!! wymagana konwencja
       listing[l+1] := #9'lda '+GetARG(0, x);
       listing[l+2] := #9'beq @+';
       listing[l+3] := #9'dey';
       listing[l+4] := '@';
       listing[l+5] := #9'sty '+GetARG(0, x);

       inc(l, 6);
      end else
}
      if arg0 = 'negCARD' then begin
       t:='';

       listing[l]   := #9'lda #$00';
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x);
       listing[l+3] := #9'lda #$00';
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x);
       listing[l+6] := #9'lda #$00';
       listing[l+7] := #9'sbc '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x);
       listing[l+9] := #9'lda #$00';
       listing[l+10] := #9'sbc '+GetARG(3, x);
       listing[l+11] := #9'sta '+GetARG(3, x);

       inc(l, 12);
      end else
      if arg0 = 'hiBYTE' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x);
       listing[l+1] := #9':4 lsr @';
       listing[l+2] := #9'sta '+GetARG(0, x);

       inc(l, 3);
      end else

      if arg0 = 'hiWORD' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(1, x);
       s[x][0] := '';
       listing[l+1] := #9'sta '+GetARG(0, x);

       inc(l, 2);
      end else
      if arg0 = 'hiCARD' then begin
       t:='';

       s[x][0] := '';
       s[x][1] := '';

       listing[l]   := #9'lda '+GetARG(3, x);
       listing[l+1] := #9'sta '+GetARG(1, x);

       listing[l+2] := #9'lda '+GetARG(2, x);
       listing[l+3] := #9'sta '+GetARG(0, x);

       inc(l, 4);
      end else

      if arg0 = 'movZTMP_aBX' then begin
	t:='';

	s[x-1, 0] := '';
	s[x-1, 1] := '';
	s[x-1, 2] := '';
	s[x-1, 3] := '';

	listing[l]   := #9'lda :ztmp8';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda :ztmp9';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda :ztmp10';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda :ztmp11';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

      end else

      if arg0 = 'movaBX_EAX' then begin
	t:='';

	s[x-1, 0] := '';
	s[x-1, 1] := '';
	s[x-1, 2] := '';
	s[x-1, 3] := '';

	listing[l]   := #9'lda :eax';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda :eax+1';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda :eax+2';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda :eax+3';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

      end else

      if (arg0 = '@BYTE.MOD') then begin
	t:='';

	if (l > 3) and lda_im(l-4) then
	  k := GetBYTE(l-4)
	else
	  k:=0;

	if k in [2,4,8,16,32,64,128] then begin

	 listing[l-4] := listing[l-2];

	 dec(l, 4);

	 case k of
	    2: listing[l+1] := #9'and #$01';
	    4: listing[l+1] := #9'and #$03';
	    8: listing[l+1] := #9'and #$07';
	   16: listing[l+1] := #9'and #$0F';
	   32: listing[l+1] := #9'and #$1F';
	   64: listing[l+1] := #9'and #$3F';
	  128: listing[l+1] := #9'and #$7F';
	 end;

	 listing[l+2] := #9'jsr #$00';

	 inc(l, 3);

	end else begin

	 listing[l] := #9'jsr @BYTE.MOD';

	 inc(l, 1);

	end;

{
	t0 := GetArg(0, x);
	t1 := GetArg(0, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) then begin

	  k:=GetVal(t1) mod GetVal(t0);

	  listing[l]   := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :ztmp8';

	  s[x-1, 1] := #9'lda #$00';
	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 2);
	end else begin
	  listing[l]   := #9'lda ' + t1;
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + t0;
	  listing[l+3] := #9'sta :ecx';
	  listing[l+4] := #9'jsr idivAL_CL.MOD';

	  inc(l, 5);
	end;
}
      end else


      if (arg0 = '@BYTE.DIV') then begin
	t:='';

	if (l > 3) and lda_im(l-4) then
	  k := GetBYTE(l-4)
	else
	  k:=0;

	if k in [2..32] then begin

	 listing[l-4] := listing[l-2];

	 dec(l, 4);


{$i include/opt6502/opt_BYTE_DIV.inc}


	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'sta :eax';

	 inc(l, 2);

	end else begin

	 listing[l]   := #9'jsr @BYTE.DIV';

	 inc(l, 1);

	end;

      end else
{
      if (arg0 = '@WORD.MOD') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(1, x);

	t2 := GetArg(0, x-1);
	t3 := GetArg(1, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) and (pos('#$', t2) > 0) and (pos('#$', t3) > 0) then begin

	  k:=(GetVal(t2) + GetVal(t3) shl 8) mod (GetVal(t0) + GetVal(t1) shl 8);

	  listing[l]   := #9'lda #$' + IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :ztmp8';
	  listing[l+2] := #9'lda #$' + IntToHex(byte(k shr 8), 2);
	  listing[l+3] := #9'sta :ztmp9';

	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 4);
	end else begin
	  listing[l]   := #9'lda ' + t2;
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + t3;
	  listing[l+3] := #9'sta :eax+1';
	  listing[l+4] := #9'lda ' + t0;
	  listing[l+5] := #9'sta :ecx';
	  listing[l+6] := #9'lda ' + t1;
	  listing[l+7] := #9'sta :ecx+1';
	  listing[l+8] := #9'jsr idivAX_CX.MOD';

	  inc(l, 9);
	end;

      end else
}

{
      if (arg0 = '@WORD.DIV') then begin
	t:='';

	t0 := GetArg(0, x);
	t1 := GetArg(1, x);

	t2 := GetArg(0, x-1);
	t3 := GetArg(1, x-1);

	if (pos('#$', t0) > 0) and (pos('#$', t1) > 0) and (pos('#$', t2) > 0) and (pos('#$', t3) > 0) then begin

	  k:=(GetVal(t2) + GetVal(t3) shl 8) div (GetVal(t0) + GetVal(t1) shl 8);

	  listing[l]   := #9'lda #$'+IntToHex(k and $ff, 2);
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda #$'+IntToHex(byte(k shr 8), 2);
	  listing[l+3] := #9'sta :eax+1';

	  s[x-1, 2] := #9'lda #$00';
	  s[x-1, 3] := #9'lda #$00';

	  inc(l, 4);
	end else begin
	  listing[l]   := #9'lda ' + t2;
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + t3;
	  listing[l+3] := #9'sta :eax+1';
	  listing[l+4] := #9'lda ' + t0;
	  listing[l+5] := #9'sta :ecx';
	  listing[l+6] := #9'lda ' + t1;
	  listing[l+7] := #9'sta :ecx+1';
	  listing[l+8] := #9'jsr idivAX_CX';

	  inc(l, 9);
	end;

      end else
}

{
      if (arg0 = '@CARDINAL.DIV') or (arg0 = '@CARDINAL.MOD') then begin
	t:='';

	listing[l]   := #9'lda ' + GetArg(0, x-1);
	listing[l+1] := #9'sta :eax';
	listing[l+2] := #9'lda ' + GetArg(1, x-1);
	listing[l+3] := #9'sta :eax+1';
	listing[l+4] := #9'lda ' + GetArg(2, x-1);
	listing[l+5] := #9'sta :eax+2';
	listing[l+6] := #9'lda ' + GetArg(3, x-1);
	listing[l+7] := #9'sta :eax+3';
	listing[l+8] := #9'lda ' + GetArg(0, x);
	listing[l+9] := #9'sta :ecx';
	listing[l+10] := #9'lda ' + GetArg(1, x);
	listing[l+11] := #9'sta :ecx+1';
	listing[l+12] := #9'lda ' + GetArg(2, x);
	listing[l+13] := #9'sta :ecx+2';
	listing[l+14] := #9'lda ' + GetArg(3, x);
	listing[l+15] := #9'sta :ecx+3';

	if arg0 = '@CARDINAL.DIV' then
	 listing[l+16] := #9'jsr idivEAX_ECX.CARD'
	else
	 listing[l+16] := #9'jsr idivEAX_ECX.CARD.MOD';

	inc(l, 17);

      end else
}
      if (arg0 = 'imulBYTE') or (arg0 = 'mulSHORTINT') then begin
	t:='';

	s[x, 1] := '';
	s[x, 2] := '';
	s[x, 3] := '';

	s[x-1, 1] := '';
	s[x-1, 2] := '';
	s[x-1, 3] := '';

	m:=l;

	listing[l]   := #9'lda '+GetARG(0, x);
	listing[l+1] := #9'sta :ecx';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+2] := #9'sta :ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(0, x-1);
	listing[l+3]  := #9'sta :eax';

	if arg0 = 'mulSHORTINT' then begin
	 listing[l+4] := #9'sta :ztmp10';
	 inc(l);
	end;

	listing[l+4] := #9'.ifdef fmulinit';
	listing[l+5] := #9'fmulu_8';
	listing[l+6] := #9'els';
	listing[l+7] := #9'imulCL';
	listing[l+8] := #9'eif';


	if lda_im(l) and					// #const
	   (listing[l+1] = #9'sta :ecx') and
	   lda_im(l+2) and	   				// #const
	   (listing[l+3] = #9'sta :eax') then
	begin

	  k := GetBYTE(l) * GetBYTE(l+2);

      	  listing[l]  := #9'lda #$' + IntToHex(k and $ff, 2);
      	  listing[l+1]:= #9'sta :eax';
      	  listing[l+2]:= #9'lda #$' + IntToHex(byte(k shr 8), 2);
      	  listing[l+3]:= #9'sta :eax+1';

	  inc(l, 4);

	end else
	 if imulCL_opt then inc(l, 9);


	if arg0 = 'mulSHORTINT' then begin

	 listing[l]   := #9'lda :ztmp10';
	 listing[l+1] := #9'bpl @+';
	 listing[l+2] := #9'sec';
	 listing[l+3] := #9'lda :eax+1';
	 listing[l+4] := #9'sbc :ztmp8';
  	 listing[l+5] := #9'sta :eax+1';

	 listing[l+6] := '@';

	 listing[l+7]  := #9'lda :ztmp8';
	 listing[l+8]  := #9'bpl @+';
	 listing[l+9]  := #9'sec';
	 listing[l+10] := #9'lda :eax+1';
	 listing[l+11] := #9'sbc :ztmp10';
	 listing[l+12] := #9'sta :eax+1';

	 listing[l+13] := '@';

	 listing[l+14] := #9'lda :eax';
	 listing[l+15] := #9'sta '+GetARG(0, x-1);
	 listing[l+16] := #9'lda :eax+1';
	 listing[l+17] := #9'sta '+GetARG(1, x-1);
	 listing[l+18] := #9'lda #$00';
	 listing[l+19] := #9'sta '+GetARG(2, x-1);
	 listing[l+20] := #9'lda #$00';
	 listing[l+21] := #9'sta '+GetARG(3, x-1);

	 inc(l, 22);
	end;

      end else

      if (arg0 = 'imulWORD') or (arg0 = 'mulSMALLINT') then begin
	t:='';

	s[x, 2] := '';
	s[x, 3] := '';

	s[x-1, 2] := '';
	s[x-1, 3] := '';

	m:=l;

	listing[l]   := #9'lda '+GetARG(0, x);		//t0 := listing[l];
	listing[l+1] := #9'sta :ecx';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+2] := #9'sta :ztmp8';
	 inc(l);
	end;

	listing[l+2]  := #9'lda '+GetARG(1, x);		//t1 := listing[l+2];
	listing[l+3]  := #9'sta :ecx+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+4] := #9'sta :ztmp9';
	 inc(l);
	end;

	listing[l+4]  := #9'lda '+GetARG(0, x-1);	//t2 := listing[l+4];
	listing[l+5]  := #9'sta :eax';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+6] := #9'sta :ztmp10';
	 inc(l);
	end;

	listing[l+6]  := #9'lda '+GetARG(1, x-1);	//t3 :=listing[l+6];
	listing[l+7]  := #9'sta :eax+1';

	if arg0 = 'mulSMALLINT' then begin
	 listing[l+8] := #9'sta :ztmp11';
	 inc(l);
	end;


        if lda_im(l) and
	   (listing[l+1] = #9'sta :ecx') and
	   lda_im(l+2) and
	   (listing[l+3] = #9'sta :ecx+1') and
	   lda_im(l+4) and
	   (listing[l+5] = #9'sta :eax') and
	   lda_im(l+6) and
	   (listing[l+7] = #9'sta :eax+1') then
	begin

	 k := GetWORD(l, l+2) * GetWORD(l+4, l+6);

         listing[l]   := #9'lda #$' + IntToHex(k and $ff, 2);
	 listing[l+1] := #9'sta :eax';
         listing[l+2] := #9'lda #$' + IntToHex(byte(k shr 8), 2);
	 listing[l+3] := #9'sta :eax+1';
         listing[l+4] := #9'lda #$' + IntToHex(byte(k shr 16), 2);
	 listing[l+5] := #9'sta :eax+2';
         listing[l+6] := #9'lda #$' + IntToHex(byte(k shr 24), 2);
	 listing[l+7] := #9'sta :eax+3';
         listing[l+8] := '';
         listing[l+9] := '';
         listing[l+10]:= '';
         listing[l+11]:= '';
         listing[l+12]:= '';

	end else begin

	 listing[l+8]  := #9'.ifdef fmulinit';
	 listing[l+9]  := #9'fmulu_16';
	 listing[l+10] := #9'els';
	 listing[l+11] := #9'imulCX';
	 listing[l+12] := #9'eif';

	end;

	inc(l, 13);

	if arg0 = 'mulSMALLINT' then begin

	listing[l]   := #9'lda :ztmp11';
	listing[l+1] := #9'bpl @+';
	listing[l+2] := #9'sec';
	listing[l+3] := #9'lda :eax+2';
	listing[l+4] := #9'sbc :ztmp8';
  	listing[l+5] := #9'sta :eax+2';
	listing[l+6] := #9'lda :eax+3';
	listing[l+7] := #9'sbc :ztmp9';
	listing[l+8] := #9'sta :eax+3';

	listing[l+9] := '@';

	listing[l+10] := #9'lda :ztmp9';
	listing[l+11] := #9'bpl @+';
	listing[l+12] := #9'sec';
	listing[l+13] := #9'lda :eax+2';
	listing[l+14] := #9'sbc :ztmp10';
	listing[l+15] := #9'sta :eax+2';
	listing[l+16] := #9'lda :eax+3';
	listing[l+17] := #9'sbc :ztmp11';
	listing[l+18] := #9'sta :eax+3';

	listing[l+19] := '@';

	listing[l+20] := #9'lda :eax';
	listing[l+21] := #9'sta '+GetARG(0, x-1);
	listing[l+22] := #9'lda :eax+1';
	listing[l+23] := #9'sta '+GetARG(1, x-1);
	listing[l+24] := #9'lda :eax+2';
	listing[l+25] := #9'sta '+GetARG(2, x-1);
	listing[l+26] := #9'lda :eax+3';
	listing[l+27] := #9'sta '+GetARG(3, x-1);

	inc(l, 28);
	end;


    if //lda_a(m) and {(lda_stack(m) = false) and}					// lda					; 0
       (listing[m+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       lda_im_0(m+2) and								// lda #$00				; 2
       (listing[m+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       lda_a(m+4) and {(lda_stack(m+4) = false) and}					// lda 					; 4
       (listing[m+5] = #9'sta :eax') and						// sta :eax				; 5
       lda_im_0(m+6) and								// lda #$00				; 6
       (listing[m+7] = #9'sta :eax+1') and						// sta :eax+1				; 7

       IFDEF_MUL16(m+8) then								// .ifdef fmulinit			; 8
       											// fmulu_16				; 9
     begin
      listing[m+2] := listing[m+4];
      listing[m+3] := listing[m+5];

      listing[m+4] := listing[m+8];
      listing[m+5] := #9'fmulu_8';
      listing[m+6] := listing[m+10];
      listing[m+7] := #9'imulCL';
      listing[m+8] := listing[m+12];

      l:=m+9;

      imulCL_opt;
     end;


      end else

      if (arg0 = 'imulCARD') or (arg0 = 'mulINTEGER') then begin
	t:='';

        if (target.id = ___NEO) then begin

          listing[l]    := #9'lda '+GetARG(0, x);
          listing[l+1]  := #9'sta :VAR1_B0';
          listing[l+2]  := #9'lda '+GetARG(1, x);
          listing[l+3]  := #9'sta :VAR1_B1';
          listing[l+4]  := #9'lda '+GetARG(2, x);
          listing[l+5]  := #9'sta :VAR1_B2';
          listing[l+6]  := #9'lda '+GetARG(3, x);
          listing[l+7]  := #9'sta :VAR1_B3';

          listing[l+8]  := #9'lda '+GetARG(0, x-1);
          listing[l+9]  := #9'sta :VAR2_B0';
          listing[l+10] := #9'lda '+GetARG(1, x-1);
          listing[l+11] := #9'sta :VAR2_B1';
          listing[l+12] := #9'lda '+GetARG(2, x-1);
          listing[l+13] := #9'sta :VAR2_B2';
          listing[l+14] := #9'lda '+GetARG(3, x-1);
          listing[l+15] := #9'sta :VAR2_B3';

          listing[l+16] := #9'jsr imulECX';

          inc(l, 17);

        end else begin

          listing[l]    := #9'lda '+GetARG(0, x);
          listing[l+1]  := #9'sta :ecx';
          listing[l+2]  := #9'lda '+GetARG(1, x);
          listing[l+3]  := #9'sta :ecx+1';
          listing[l+4]  := #9'lda '+GetARG(2, x);
          listing[l+5]  := #9'sta :ecx+2';
          listing[l+6]  := #9'lda '+GetARG(3, x);
          listing[l+7]  := #9'sta :ecx+3';

          listing[l+8]  := #9'lda '+GetARG(0, x-1);
          listing[l+9]  := #9'sta :eax';
          listing[l+10] := #9'lda '+GetARG(1, x-1);
          listing[l+11] := #9'sta :eax+1';
          listing[l+12] := #9'lda '+GetARG(2, x-1);
          listing[l+13] := #9'sta :eax+2';
          listing[l+14] := #9'lda '+GetARG(3, x-1);
          listing[l+15] := #9'sta :eax+3';

          listing[l+16] := #9'jsr imulECX';

          inc(l, 17);

          if arg0 = 'mulINTEGER' then begin
          listing[l]   := #9'lda :eax';
          listing[l+1] := #9'sta '+GetARG(0, x-1);
          listing[l+2] := #9'lda :eax+1';
          listing[l+3] := #9'sta '+GetARG(1, x-1);
          listing[l+4] := #9'lda :eax+2';
          listing[l+5] := #9'sta '+GetARG(2, x-1);
          listing[l+6] := #9'lda :eax+3';
          listing[l+7] := #9'sta '+GetARG(3, x-1);

          if sta_im_0(l+1) then begin
           listing[l]   := '';
           listing[l+1] := '';
          end;

          if sta_im_0(l+3) then begin
           listing[l+2] := '';
           listing[l+3] := '';
          end;

          if sta_im_0(l+5) then begin
           listing[l+4] := '';
           listing[l+5] := '';
          end;

          if sta_im_0(l+7) then begin
           listing[l+6] := '';
           listing[l+7] := '';
          end;

          inc(l, 8);

        end;

	end;

      end else
{
      if arg0 = ':TMP' then			// :TMP			!!! not accepted !!!
      else
      if arg0 = '*+6' then			// *+6			!!! not accepted !!!
      else
}
      if arg0 = '@move' then			// @move		accepted
      else

      if arg0 = '@cmpSTRING' then		// @cmpSTRING		accepted
      else

      if arg0 = '@FCMPL' then			// @FCMPL		accepted
      else

      if arg0 = '@FTOA' then			// @FTOA		accepted
      else

      if arg0 = '@SHORTINT.DIV' then		// @SHORTINT.DIV	accepted
      else
      if arg0 = '@SMALLINT.DIV' then		// @SMALLINT.DIV	accepted
      else
      if arg0 = '@INTEGER.DIV' then		// @INTEGER.DIV		accepted
      else
      if arg0 = '@SHORTINT.MOD' then		// @SHORTINT.MOD	accepted
      else
      if arg0 = '@SMALLINT.MOD' then		// @SMALLINT.MOD	accepted
      else
      if arg0 = '@INTEGER.MOD' then		// @INTEGER.MOD		accepted
      else

      if arg0 = '@BYTE.DIV' then		// @BYTE.DIV		accepted
      else
      if arg0 = '@WORD.DIV' then		// @WORD.DIV		accepted
      else
      if arg0 = '@CARDINAL.DIV' then		// @CARDINAL.DIV	accepted
      else
      if arg0 = '@BYTE.MOD' then		// @BYTE.MOD		accepted
      else
      if arg0 = '@WORD.MOD' then		// @WORD.MOD		accepted
      else
      if arg0 = '@CARDINAL.MOD' then		// @CARDINAL.MOD	accepted
      else

      if arg0 = '@SHORTREAL_MUL' then		// @SHORTREAL_MUL	accepted
      else
      if arg0 = '@REAL_MUL' then		// @REAL_MUL		accepted
      else
      if arg0 = '@SHORTREAL_DIV' then		// @SHORTREAL_DIV	accepted
      else
      if arg0 = '@REAL_DIV' then		// @REAL_DIV		accepted
      else

      if arg0 = '@REAL_ROUND' then		// @REAL_ROUND		accepted
      else
      if arg0 = '@SHORTREAL_TRUNC' then		// @SHORTREAL_TRUNC	accepted
      else
      if arg0 = '@REAL_TRUNC' then		// @REAL_TRUNC		accepted
      else
      if arg0 = '@REAL_FRAC' then		// @REAL_FRAC		accepted
      else

      if arg0 = '@FMUL' then			// @FMUL		accepted
      else
      if arg0 = '@FDIV' then			// @FDIV		accepted
      else
      if arg0 = '@FADD' then			// @FADD		accepted
      else
      if arg0 = '@FSUB' then			// @FSUB		accepted
      else
      if arg0 = '@I2F' then			// @I2F			accepted
      else
      if arg0 = '@F2I' then			// @F2I			accepted
      else
      if arg0 = '@FFRAC' then			// @FFRAC		accepted
      else
      if arg0 = '@FROUND' then			// @FROUND		accepted
      else

      if arg0 = '@F16_F2A' then			// @F16_F2A		accepted
      else
      if arg0 = '@F16_ADD' then			// @F16_ADD		accepted
      else
      if arg0 = '@F16_SUB' then 		// @F16_SUB		accepted
      else
      if arg0 = '@F16_MUL' then			// @F16_MUL		accepted
      else
      if arg0 = '@F16_DIV' then			// @F16_DIV		accepted
      else
      if arg0 = '@F16_INT' then			// @F16_INT		accepted
      else
      if arg0 = '@F16_ROUND' then		// @F16_ROUND		accepted
      else
      if arg0 = '@F16_FRAC' then		// @F16_FRAC		accepted
      else
      if arg0 = '@F16_I2F' then			// @F16_I2F		accepted
      else
      if arg0 = '@F16_EQ' then			// @F16_EQ		accepted
      else
      if arg0 = '@F16_GT' then			// @F16_GT		accepted
      else
      if arg0 = '@F16_GTE' then			// @F16_GTE		accepted
      else

      if arg0 = 'SYSTEM.PEEK' then begin

	if system_peek then begin x:=50; Break end;

      end else
      if arg0 = 'SYSTEM.POKE' then begin

	if system_poke then begin x:=50; Break end;

      end else
      if arg0 = 'SYSTEM.DPEEK' then begin

	if system_dpeek then begin x:=50; Break end;

      end else
      if arg0 = 'SYSTEM.DPOKE' then begin

	if system_dpoke then begin x:=50; Break end;

      end else
      if arg0 = 'shrAL_CL.BYTE' then begin		// SHR BYTE
	t:='';

	k := GetVAL(GetARG(0, x));

	if {(k > 7) or} (k < 0) then begin x:=50; Break end;

	if k > 7 then begin

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);
	listing[l+6] := #9'lda '+GetARG(3, x-1);
	listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);

	end else begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	inc(l);

	for m := 0 to k - 1 do begin
	 listing[l] := #9'lsr @';
	 inc(l);
	end;

	listing[l]   := #9'sta '+GetARG(0, x-1);

	inc(l);
{
	s[x-1, 1] := '';//#9'mva #$00';
	s[x-1, 2] := '';//#9'mva #$00';
	s[x-1, 3] := '';//#9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);

	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);
}
	inc(l, 2);
	end;

      end else
      if arg0 = 'shrAX_CL.WORD' then begin		// SHR WORD
	t:='';

	k := GetVAL(GetARG(0, x, false));

//	if {(k > 8) or} (k < 0) then begin x:=50; Break end;

	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

      if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'lsr ' + GetARG(1, x-1);
	 listing[l+11] := #9'ror @';

	 listing[l+12] := #9'dey';
	 listing[l+13] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+14] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+15] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 16);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

     end else
     if k > 15 then begin

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);
	listing[l+6] := #9'lda '+GetARG(3, x-1);
	listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);

     end else

     if k = 9 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+2] := #9'sta ' + GetARG(0, x-1);

	inc(l, 3);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 10 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+3] := #9'sta ' + GetARG(0, x-1);

	inc(l, 4);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 11 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+4] := #9'sta ' + GetARG(0, x-1);

	inc(l, 5);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 12 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+5] := #9'sta ' + GetARG(0, x-1);

	inc(l, 6);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 13 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	listing[l+5] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+6] := #9'sta ' + GetARG(0, x-1);

	inc(l, 7);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 14 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	listing[l+5] := #9'lsr @';
	listing[l+6] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 15 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'asl @';
	s[x-1][0] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'rol @';
	listing[l+4] := #9'sta ' + GetARG(0, x-1);

	inc(l, 5);

	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 8 then begin
	listing[l]   := #9'lda ' + GetARG(1, x-1);
	s[x-1][0] := '';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);

	inc(l, 2);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda ' + GetARG(0, x-1);

	inc(l, 3);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'lsr ' + GetARG(1, x-1);
	listing[l+1] := #9'ror @';

	inc(l, 2);
       end;

	listing[l]   := #9'sta ' + GetARG(0, x-1);
	listing[l+1] := #9'lda ' + GetARG(1, x-1);
	listing[l+2] := #9'sta ' + GetARG(1, x-1);

	inc(l, 3);

	listing[l]   := #9'lda '+GetARG(2, x-1);
	listing[l+1] := #9'sta '+GetARG(2, x-1);
	listing[l+2] := #9'lda '+GetARG(3, x-1);
	listing[l+3] := #9'sta '+GetARG(3, x-1);

	inc(l, 4);

     end;

     end else

      if arg0 = 'shrEAX_CL' then begin			// SHR CARDINAL
	t:='';

	k := GetVAL(GetARG(0, x, false));

	if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+11] := #9'ror ' + GetARG(2, x-1);
	 listing[l+12] := #9'ror ' + GetARG(1, x-1);
	 listing[l+13] := #9'ror @';

	 listing[l+14] := #9'dey';
	 listing[l+15] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+16] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+17] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 18);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

	end else
	if k = 13 then begin

	 listing[l]   := #9'lda ' + GetARG(1, x-1);
	 s[x-1][0]    := '';
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][1]    := '';
	 listing[l+3] := #9'sta ' + GetARG(1, x-1);
	 listing[l+4] := #9'lda ' + GetARG(3, x-1);
	 s[x-1][2]    := '';
	 listing[l+5] := #9'sta ' + GetARG(2, x-1);

	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta ' + GetARG(3, x-1);

	 listing[l+8] := #9'asl ' + GetARG(0, x-1);
	 listing[l+9] := #9'rol ' + GetARG(1, x-1);
	 listing[l+10] := #9'rol ' + GetARG(2, x-1);
	 listing[l+11] := #9'rol ' + GetARG(3, x-1);

	 listing[l+12] := #9'asl ' + GetARG(0, x-1);
	 listing[l+13] := #9'rol ' + GetARG(1, x-1);
	 listing[l+14] := #9'rol ' + GetARG(2, x-1);
	 listing[l+15] := #9'rol ' + GetARG(3, x-1);

	 listing[l+16] := #9'asl ' + GetARG(0, x-1);
	 listing[l+17] := #9'rol ' + GetARG(1, x-1);
	 listing[l+18] := #9'rol ' + GetARG(2, x-1);
	 listing[l+19] := #9'rol ' + GetARG(3, x-1);

	 inc(l, 20);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);
	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta '+GetARG(3, x-1);

	 inc(l, 8);

	end else
	if k = 23 then begin

	 listing[l]   := #9'lda ' + GetARG(2, x-1);		// bit7 -> C
	 listing[l+1] := #9'asl @';
	 s[x-1][0] := '';
	 listing[l+2] := #9'lda ' + GetARG(3, x-1);
	 listing[l+3] := #9'rol @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 s[x-1][1] := '';
	 listing[l+5] := #9'lda #$00';
	 listing[l+6] := #9'rol @';
	 listing[l+7] := #9'sta ' + GetARG(1, x-1);

	 inc(l, 8);

	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(2, x-1);
	 listing[l+2] := #9'lda '+GetARG(3, x-1);
	 listing[l+3] := #9'sta '+GetARG(3, x-1);

	 inc(l, 4);

	end else
	if k = 27 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1, 0] := '';
	 listing[l+1] := #9'lsr @';
	 listing[l+2] := #9'lsr @';
	 listing[l+3] := #9'lsr @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 5);

	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	end else
	if k = 31 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 listing[l+1] := #9'asl @';
	 s[x-1][0] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'rol @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 5);

	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l,6);

	end else begin

	m := k div 8;
	k := k mod 8;

	if m > 3 then begin

	 k:=0;

	 listing[l]   := #9'lda #$00';
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'sta ' + GetARG(1, x-1);
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);
	end else
	 case m of
	   1: begin
	       listing[l]   := #9'lda ' + GetARG(1, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	       s[x-1][1] := '';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);

	       listing[l+4]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][2] := '';
	       listing[l+5] := #9'sta ' + GetARG(2, x-1);

	       listing[l+6] := #9'lda #$00';
	       listing[l+7] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 8);
	      end;

	   2: begin
	       listing[l]   := #9'lda ' + GetARG(2, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       listing[l+2]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][1] := '';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);

	       listing[l+4] := #9'lda #$00';
	       listing[l+5] := #9'sta ' + GetARG(2, x-1);
	       listing[l+6] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 7);
	      end;

	   3: begin
	       listing[l]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       s[x-1][1] := '';
	       s[x-1][2] := '';
	       s[x-1][3] := '';

	       listing[l+2] := #9'lda #$00';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);
	       listing[l+4] := #9'sta ' + GetARG(2, x-1);
	       listing[l+5] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 6);
	      end;

	   end;

	if k > 0 then begin

	  if m = 0 then begin

	   listing[l]   := #9'lda ' + GetARG(0, x-1);
	   listing[l+1] := #9'sta ' + GetARG(0, x-1);
	   listing[l+2] := #9'lda ' + GetARG(1, x-1);
	   listing[l+3] := #9'sta ' + GetARG(1, x-1);
	   listing[l+4] := #9'lda ' + GetARG(2, x-1);
	   listing[l+5] := #9'sta ' + GetARG(2, x-1);
	   listing[l+6] := #9'lda ' + GetARG(3, x-1);
	   listing[l+7] := #9'sta ' + GetARG(3, x-1);

	   inc(l, 8);
	  end;

	  for m := 0 to k - 1 do begin

	    listing[l]   := #9'lsr ' + GetARG(3, x-1);
	    listing[l+1] := #9'ror ' + GetARG(2, x-1);
	    listing[l+2] := #9'ror ' + GetARG(1, x-1);
	    listing[l+3] := #9'ror ' + GetARG(0, x-1);

	    inc(l, 4);
	  end;

	  listing[l]   := #9'lda ' + GetARG(0, x-1);
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lda ' + GetARG(1, x-1);
	  listing[l+3] := #9'sta ' + GetARG(1, x-1);
	  listing[l+4] := #9'lda ' + GetARG(2, x-1);
	  listing[l+5] := #9'sta ' + GetARG(2, x-1);
	  listing[l+6] := #9'lda ' + GetARG(3, x-1);
	  listing[l+7] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 8);
	end;

	end;	// if k = 31

     end else

      if arg0 = 'shlEAX_CL.BYTE' then begin		// SHL BYTE
	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1][1] := '';				// !!! bez tego nie zadziala gdy 'lda adr.' !!!
	s[x-1][2] := '';
	s[x-1][3] := '';

	inc(l, 2);


	if k > 31 then begin

	s[x-1][0] := '';

	listing[l]   := #9'lda #$00';			// shl 32..
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

	end else

	if k = 31 then begin				// shl 31

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(2, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);

	 inc(l,6);
	end else

	if k = 10 then begin

	 s[x-1][1] := #9'mva #$00';
	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'sta ' + GetARG(0, x-1);

	 inc(l,14);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 11 then begin

	 s[x-1][1] := #9'mva #$00';
	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'asl @';
	 listing[l+14] := #9'rol ' + GetARG(1, x-1);
	 listing[l+15] := #9'rol ' + GetARG(2, x-1);

	 listing[l+16] := #9'sta ' + GetARG(0, x-1);

	 inc(l,17);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k in [12..15] then begin			// shl 14 -> (shl 16) shr 2

	k:=16-k;

	listing[l]   := #9'lda #$00';			// shl 16
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
	listing[l+6] := #9'lda ' + GetARG(0, x-1);
	listing[l+7] := #9'sta ' + GetARG(2, x-1);
	listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

	inc(l, 10);

	  for m := 0 to k-1 do begin			// shr 2

	    listing[l]   := #9'lsr ' + GetARG(2, x-1);
	    listing[l+1] := #9'ror @';

	    inc(l, 2);
	  end;

	  listing[l]   := #9'sta ' + GetARG(1, x-1);
	  listing[l+1] := #9'lda ' + GetARG(2, x-1);
	  listing[l+2] := #9'sta ' + GetARG(2, x-1);

          s[x-1][3] := #9'mva #$00';

          listing[l+3] := #9'lda ' + GetARG(3, x-1);
          listing[l+4] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 5);

	end else

	if k in [8,16,24] then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
	listing[l+6] := #9'lda ' + GetARG(0, x-1);

	 case k of
	  8: listing[l+7] := #9'sta ' + GetARG(1, x-1);
	 16: listing[l+7] := #9'sta ' + GetARG(2, x-1);
	 24: listing[l+7] := #9'sta ' + GetARG(3, x-1);
	 end;

	listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

	inc(l, 10);

	end else begin

	if (k > 7) or (k < 0) then begin //x:=50; Break end;

	 listing[l]   := #9'lda #$00';
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda #$00';
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda #$00';
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);

	 inc(l, 6);

	 listing[l] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+1] := #9'sta ' + GetARG(1, x-1);
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 inc(l, 3);

	 listing[l] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+1] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+2] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+3] := #9'asl @';
	 listing[l+4] := #9'rol ' + GetARG(1, x-1);
	 listing[l+5] := #9'rol ' + GetARG(2, x-1);
	 listing[l+6] := #9'rol ' + GetARG(3, x-1);

	 listing[l+7] := #9'dey';
	 listing[l+8] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+10] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 11);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 s[x-1][2] := '';
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 s[x-1][3] := '';
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

       end else begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda #$00';

	inc(l, 3);

        for m := 0 to k - 1 do begin

	 listing[l]   := #9'asl ' + GetARG(0, x-1);
	 listing[l+1] := #9'rol @';

	 inc(l, 2);
        end;

        listing[l]   := #9'sta ' + GetARG(1, x-1);
        listing[l+1] := #9'lda ' + GetARG(0, x-1);
        listing[l+2] := #9'sta ' + GetARG(0, x-1);

        inc(l, 3);

       end;

      end;

      end else
      if arg0 = 'shlEAX_CL.WORD' then begin	    // SHL WORD
	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1][2] := '';
	s[x-1][3] := '';

        if k < 0 then begin

	 listing[l]   := #9'lda #$00';
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda #$00';
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);

	 inc(l, 4);

	 listing[l] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+1] := #9'sta ' + GetARG(1, x-1);
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 inc(l, 3);

	 listing[l] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+1] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+2] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+3] := #9'asl @';
	 listing[l+4] := #9'rol ' + GetARG(1, x-1);
	 listing[l+5] := #9'rol ' + GetARG(2, x-1);
	 listing[l+6] := #9'rol ' + GetARG(3, x-1);

	 listing[l+7] := #9'dey';
	 listing[l+8] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+10] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 11);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

        end else

	if k = 16 then begin

	s[x-1][2] := '';
	s[x-1][3] := '';

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(2, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(3, x-1);

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta '+GetARG(0, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta '+GetARG(1, x-1);

	inc(l,8);

	end else
{
	if k = 15 then begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][1] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'ror @';
	listing[l+4] := #9'sta ' + GetARG(1, x-1);

	inc(l, 5);

	s[x-1, 0] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

	end else
}
	if k = 10 then begin

	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'sta ' + GetARG(0, x-1);

	 inc(l,14);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 11 then begin

	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'asl @';
	 listing[l+14] := #9'rol ' + GetARG(1, x-1);
	 listing[l+15] := #9'rol ' + GetARG(2, x-1);

	 listing[l+16] := #9'sta ' + GetARG(0, x-1);

	 inc(l,17);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 31 then begin				// shl 31

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(2, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);

	 inc(l,6);
	end else

	if k = 8 then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(3, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda ' + GetARG(0, x-1);
	listing[l+5] := #9'sta ' + GetARG(1, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	end else begin

	if (k > 7) {or (k < 0)} then begin x:=50; Break end;

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda #$00';

	inc(l, 5);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'asl ' + GetARG(0, x-1);
	listing[l+1] := #9'rol ' + GetARG(1, x-1);
	listing[l+2] := #9'rol @';

	inc(l, 3);
       end;

       listing[l]   := #9'sta ' + GetARG(2, x-1);
       listing[l+1] := #9'lda ' + GetARG(0, x-1);
       listing[l+2] := #9'sta ' + GetARG(0, x-1);
       listing[l+3] := #9'lda ' + GetARG(1, x-1);
       listing[l+4] := #9'sta ' + GetARG(1, x-1);

       inc(l, 5);

       end;

      end else

      if arg0 = 'shlEAX_CL.CARD' then begin	    // SHL CARD
       t:='';

       k := GetVAL(GetARG(0, x, false));


	if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);
	 listing[l+13] := #9'rol ' + GetARG(3, x-1);

	 listing[l+14] := #9'dey';
	 listing[l+15] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+16] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+17] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 18);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

	end else
(*
       if k = 7 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';
	 listing[l+7] := #9'sta ' + GetARG(0, x-1);
	 listing[l+8] := #9'lda #$00';

	 listing[l+9] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+10] := #9'ror ' + GetARG(2, x-1);
	 listing[l+11] := #9'ror ' + GetARG(1, x-1);
	 listing[l+12] := #9'ror ' + GetARG(0, x-1);
	 listing[l+13] := #9'ror @';

	 listing[l+14] := #9'tay';

	 inc(l, 15);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);
         listing[l+6] := #9'tya';
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l, 8);

       end else
*)
       if k = 13 then begin

	 listing[l]   := #9'lda ' + GetARG(2, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 s[x-1][0]    := '';
	 listing[l+6] := #9'lda #$00';

	 listing[l+7] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+8] := #9'ror ' + GetARG(2, x-1);
	 listing[l+9] := #9'ror ' + GetARG(1, x-1);
	 listing[l+10] := #9'ror @';

	 listing[l+11] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+12] := #9'ror ' + GetARG(2, x-1);
	 listing[l+13] := #9'ror ' + GetARG(1, x-1);
	 listing[l+14] := #9'ror @';

	 listing[l+15] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+16] := #9'ror ' + GetARG(2, x-1);
	 listing[l+17] := #9'ror ' + GetARG(1, x-1);
	 listing[l+18] := #9'ror @';

	 listing[l+19] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 20);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);
	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l, 8);

       end else
       if k = 23 then begin

	 listing[l]   := #9'lda ' + GetARG(1, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 s[x-1][2] := '';
	 listing[l+5] := #9'lda #$00';
	 listing[l+6] := #9'ror @';
	 listing[l+7] := #9'sta ' + GetARG(2, x-1);

	 inc(l, 8);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);

	 inc(l, 4);

       end else
       if k = 31 then begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][3] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'ror @';
	listing[l+4] := #9'sta ' + GetARG(3, x-1);

	inc(l, 5);

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);

	inc(l,6);

       end else begin

//       if {(k > 7) or} (k < 0) then begin x:=50; Break end;

       m:=k div 8;
       k:=k mod 8;

       if m > 3 then begin

	k:=0;

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'sta ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'sta ' + GetARG(3, x-1);

	inc(l, 5);
       end else
	case m of
	 1: begin
	     listing[l]   := #9'lda ' + GetARG(1, x-1);
	     listing[l+1] := #9'sta ' + GetARG(1, x-1);
	     listing[l+2] := #9'lda ' + GetARG(2, x-1);
	     listing[l+3] := #9'sta ' + GetARG(2, x-1);
	     listing[l+4] := #9'lda ' + GetARG(3, x-1);
	     listing[l+5] := #9'sta ' + GetARG(3, x-1);

	     inc(l, 6);

	     listing[l]   := #9'lda ' + GetARG(2, x-1);

	     	s[x-1, 3] := '';

	     listing[l+1] := #9'sta ' + GetARG(3, x-1);
	     listing[l+2] := #9'lda ' + GetARG(1, x-1);

	     	s[x-1, 2] := '';

	     listing[l+3] := #9'sta ' + GetARG(2, x-1);
	     listing[l+4] := #9'lda ' + GetARG(0, x-1);

	     	s[x-1, 1] := '';

	     listing[l+5] := #9'sta ' + GetARG(1, x-1);
	     listing[l+6] := #9'lda #$00';

	     	s[x-1, 0] := '';

	     listing[l+7] := #9'sta ' + GetARG(0, x-1);

	     inc(l, 8);
	    end;

	 2: begin
	     listing[l]   := #9'lda ' + GetARG(2, x-1);
	     listing[l+1] := #9'sta ' + GetARG(2, x-1);
	     listing[l+2] := #9'lda ' + GetARG(3, x-1);
	     listing[l+3] := #9'sta ' + GetARG(3, x-1);

	     inc(l, 4);

	     listing[l]   := #9'lda ' + GetARG(1, x-1);

		s[x-1, 3] := '';

	     listing[l+1] := #9'sta ' + GetARG(3, x-1);
	     listing[l+2] := #9'lda ' + GetARG(0, x-1);

	     	s[x-1, 2] := '';

	     listing[l+3] := #9'sta ' + GetARG(2, x-1);
	     listing[l+4] := #9'lda #$00';

		s[x-1, 0] := '';
	     	s[x-1, 1] := '';

	     listing[l+5] := #9'sta ' + GetARG(0, x-1);
	     listing[l+6] := #9'sta ' + GetARG(1, x-1);

	     inc(l, 7);
	    end;

	 3: begin
	     listing[l]   := #9'lda ' + GetARG(3, x-1);
	     listing[l+1] := #9'sta ' + GetARG(3, x-1);

	     inc(l, 2);

	     listing[l]   := #9'lda ' + GetARG(0, x-1);

	     	s[x-1, 3] := '';

	     listing[l+1] := #9'sta ' + GetARG(3, x-1);
	     listing[l+2] := #9'lda #$00';

		s[x-1, 0] := '';
	     	s[x-1, 1] := '';
	     	s[x-1, 2] := '';

	     listing[l+3] := #9'sta ' + GetARG(0, x-1);
	     listing[l+4] := #9'sta ' + GetARG(1, x-1);
	     listing[l+5] := #9'sta ' + GetARG(2, x-1);

	     inc(l, 6);
	    end;

	end;

       if k > 0 then begin

	 if m = 0 then begin

	  listing[l]   := #9'lda ' + GetARG(0, x-1);
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lda ' + GetARG(1, x-1);
	  listing[l+3] := #9'sta ' + GetARG(1, x-1);
	  listing[l+4] := #9'lda ' + GetARG(2, x-1);
	  listing[l+5] := #9'sta ' + GetARG(2, x-1);
	  listing[l+6] := #9'lda ' + GetARG(3, x-1);
	  listing[l+7] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 8);
	 end;

	 for m := 0 to k - 1 do begin

	  listing[l]   := #9'asl ' + GetARG(0, x-1);
	  listing[l+1] := #9'rol ' + GetARG(1, x-1);
	  listing[l+2] := #9'rol ' + GetARG(2, x-1);
	  listing[l+3] := #9'rol ' + GetARG(3, x-1);

	  inc(l, 4);
	 end;

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'lda ' + GetARG(1, x-1);
	 listing[l+3] := #9'sta ' + GetARG(1, x-1);
	 listing[l+4] := #9'lda ' + GetARG(2, x-1);
	 listing[l+5] := #9'sta ' + GetARG(2, x-1);
	 listing[l+6] := #9'lda ' + GetARG(3, x-1);
	 listing[l+7] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 8);
       end;

       end;	// if k = 31

      end else

{
      if arg0 = 'andAL_CL' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       inc(l, 3);
      end else

      if arg0 = 'andAX_CX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'and '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       inc(l, 6);
      end else
      if arg0 = 'andEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'and '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'and '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'and '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9]  := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'and '+GetARG(3, x);
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
}

{
      if arg0 = 'orAL_CL' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'ora '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       inc(l, 3);
      end else

      if arg0 = 'orAX_CX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'ora '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'ora '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       inc(l, 6);
      end else
      if arg0 = 'orEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'ora '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'ora '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'ora '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'ora '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
}

{
      if arg0 = 'xorAL_CL' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'eor '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       inc(l, 3);
      end else

      if arg0 = 'xorAX_CX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'eor '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'eor '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       inc(l, 6);
      end else
      if arg0 = 'xorEAX_ECX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'eor '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'eor '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'eor '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'eor '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end else
}
      if arg0 = 'notaBX' then begin
       t:='';

       listing[l]   := #9'lda '+GetARG(0, x);
       listing[l+1] := #9'eor #$ff';
       listing[l+2] := #9'sta '+GetARG(0, x);

       listing[l+3] := #9'lda '+GetARG(1, x);
       listing[l+4] := #9'eor #$ff';
       listing[l+5] := #9'sta '+GetARG(1, x);

       listing[l+6] := #9'lda '+GetARG(2, x);
       listing[l+7] := #9'eor #$ff';
       listing[l+8] := #9'sta '+GetARG(2, x);

       listing[l+9] := #9'lda '+GetARG(3, x);
       listing[l+10]:= #9'eor #$ff';
       listing[l+11]:= #9'sta '+GetARG(3, x);

       inc(l, 12);
      end else

      if (pos('add', arg0) > 0) or (pos('sub', arg0) > 0) then begin

      t:='';

      if (arg0 = 'subAL_CL') then begin

       s[x][1] := '';
       s[x][2] := '';
       s[x][3] := '';

       s[x-1][1] := #9'mva #$00';
       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+3] := '';
       listing[l+4] := '';
       listing[l+5] := '';
       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 3);
      end;

      if (arg0 = 'subAX_CX') then begin

       s[x][2] := '';
       s[x][3] := '';

       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'sbc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'sbc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 6);
      end;

      if (arg0 = 'subEAX_ECX') then begin

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'sub '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'sbc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'sbc '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9]  := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'sbc '+GetARG(3, x);
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       inc(l, 12);
      end;

      if arg0 = 'addAL_CL' then begin

       if (pos(',y', s[x-1][0]) >0 ) or (pos(',y', s[x][0]) >0 ) then begin x:=30; Break end;

       s[x][1] := '';
       s[x][2] := '';
       s[x][3] := '';

       s[x-1][1] := #9'mva #$00';
       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc #$00';
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'adc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'adc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+3] := '';
       listing[l+4] := '';
       listing[l+5] := '';
       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 3);
      end;

      if arg0 = 'addAX_CX' then begin

       s[x][2] := '';
       s[x][3] := '';

       s[x-1][2] := #9'mva #$00';
       s[x-1][3] := #9'mva #$00';

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'adc #$00';
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10] := #9'adc #$00';
       listing[l+11] := #9'sta '+GetARG(3, x-1);

       listing[l+6] := '';
       listing[l+7] := '';
       listing[l+8] := '';
       listing[l+9] := '';
       listing[l+10] := '';
       listing[l+11] := '';

       inc(l, 6);
      end;

      if (arg0 = 'addEAX_ECX') then begin

       listing[l]   := #9'lda '+GetARG(0, x-1);
       listing[l+1] := #9'add '+GetARG(0, x);
       listing[l+2] := #9'sta '+GetARG(0, x-1);

       listing[l+3] := #9'lda '+GetARG(1, x-1);
       listing[l+4] := #9'adc '+GetARG(1, x);
       listing[l+5] := #9'sta '+GetARG(1, x-1);

       listing[l+6] := #9'lda '+GetARG(2, x-1);
       listing[l+7] := #9'adc '+GetARG(2, x);
       listing[l+8] := #9'sta '+GetARG(2, x-1);

       listing[l+9] := #9'lda '+GetARG(3, x-1);
       listing[l+10]:= #9'adc '+GetARG(3, x);
       listing[l+11]:= #9'sta '+GetARG(3, x-1);

       inc(l, 12);

      end;

      end else begin

{$IFDEF USEOPTFILE}

	writeln(arg0);

{$ENDIF}

	x:=51; Break;

      end;

     end;


   if (pos(':STACKORIGIN,', t) > 7) and (pos('(:bp),', t) = 0) then begin	// kiedy odczytujemy tablice
    s[x][0]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][0]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(0, x);
     listing[l+1] := #9'sta ' + GetARG(0, x);

     inc(l, 2);
    end;
   end;

   if (pos(':STACKORIGIN+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0) then begin
    s[x][1]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][1]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(1, x);
     listing[l+1] := #9'sta ' + GetARG(1, x);

     inc(l, 2);
    end;
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0) then begin
    s[x][2]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][2]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(2, x);
     listing[l+1] := #9'sta ' + GetARG(2, x);

     inc(l, 2);
    end;
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0) then begin
    s[x][3]:=copy(a, 1, pos(' :STACK', a));
    t:='';

    if pos(',y', s[x][3]) > 0 then begin
     listing[l]   := #9'lda ' + GetARG(3, x);
     listing[l+1] := #9'sta ' + GetARG(3, x);

     inc(l, 2);
    end;
   end;


   if (pos(':STACKORIGIN-1+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x-1][1]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN-1+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x-1][2]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN-1+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x-1][3]:=copy(a, 1, pos(' :STACK', a)); t:='' end;

   if (pos(':STACKORIGIN+1+STACKWIDTH,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x+1][1]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN+1+STACKWIDTH*2,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x+1][2]:=copy(a, 1, pos(' :STACK', a)); t:='' end;
   if (pos(':STACKORIGIN+1+STACKWIDTH*3,', t) > 7) and (pos('(:bp),', t) = 0)	then begin s[x+1][3]:=copy(a, 1, pos(' :STACK', a)); t:='' end;


   if (pos(':STACKORIGIN,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 14);

    arg0 := GetARG(0, x);
    insert(arg0, t, k );
   end;

   if (pos(':STACKORIGIN+STACKWIDTH,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 25);

    arg0 := GetARG(1, x);
    insert(arg0, t, k );
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*2,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 27);

    arg0 := GetARG(2, x);
    insert(arg0, t, k );
   end;

   if (pos(':STACKORIGIN+STACKWIDTH*3,', t) = 6) then begin
    k:=pos(':STACK', t);
    delete(t, k, 27);

    arg0 := GetARG(3, x);
    insert(arg0, t, k );
   end;


   if (pos(':STACKORIGIN-1,', t) = 6) then		t:=copy(a, 1, pos(' :STACK', a)) + GetARG(0, x-1);
   if (pos(':STACKORIGIN-1+STACKWIDTH,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(1, x-1);
   if (pos(':STACKORIGIN-1+STACKWIDTH*2,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(2, x-1);
   if (pos(':STACKORIGIN-1+STACKWIDTH*3,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(3, x-1);


   if (pos(':STACKORIGIN+1,', t) = 6) then		t:=copy(a, 1, pos(' :STACK', a)) + GetARG(0, x+1);
   if (pos(':STACKORIGIN+1+STACKWIDTH,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(1, x+1);
   if (pos(':STACKORIGIN+1+STACKWIDTH*2,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(2, x+1);
   if (pos(':STACKORIGIN+1+STACKWIDTH*3,', t) = 6) then	t:=copy(a, 1, pos(' :STACK', a)) + GetARG(3, x+1);

   if t <> '' then begin
    listing[l] := t;
    inc(l);
   end;

  end;

 end;

(* -------------------------------------------------------------------------- *)

 if ((x = 0) and inxUse) then begin   // succesfull

  if common.optimize.line <> common.optimize.old then begin
   WriteOut('');
   WriteOut('; optimize OK ('+UnitName[common.optimize.unitIndex].Name+'), line = '+IntToStr(common.optimize.line));
   WriteOut('');

   common.optimize.old := common.optimize.line;
  end;


{$IFDEF OPTIMIZECODE}

  repeat

    OptimizeAssignment;

    repeat until OptimizeRelation;

    OptimizeAssignment;

  until OptimizeRelation;


  if OptimizeEAX then begin
    OptimizeAssignment;

    OptimizeEAX_OFF;

    OptimizeAssignment;
  end;

{$ENDIF}


{$i include/opt6502/opt_FOR.inc}

{$i include/opt6502/opt_REG_A.inc}

{$i include/opt6502/opt_REG_BP2.inc}

{$i include/opt6502/opt_REG_Y.inc}


(* -------------------------------------------------------------------------- *)

  for i := 0 to l - 1 do
    if listing[i]<>'' then WriteInstruction(i);

(* -------------------------------------------------------------------------- *)


 end else begin

  l := High(OptimizeBuf);

  if l > High(listing) then begin writeln('Out of resources, LISTING'); halt end;

  for i := 0 to l-1 do
   listing[i] := OptimizeBuf[i];


{$IFDEF OPTIMIZECODE}

  repeat until PeepholeOptimization_STACK;		// optymalizacja lda :STACK...,x \ sta :STACK...,x

{$ENDIF}


// optyA := '';

 if optyA <> '' then
  for i:=0 to l-1 do
   if (listing[i] = #9'inc ' + optyA) or (listing[i] = #9'dec ' + optyA) or //((optyY <> '') and (optyA = optyY)) or
      lda(i) or lda_adr(i) or mva(i) or mwa(i) or tya(i) or lab_a(i) or jsr(i) or
      (pos(#9'jmp ', listing[i]) > 0) or (pos(#9'.if', listing[i]) > 0) then begin optyA := ''; Break end;


// optyY := '';

 if optyY <> '' then
  for i:=0 to l-1 do
   if LabelIsUsed(i) or //((optyA <> '') and (optyA = optyY)) or
      ldy(i) or mvy(i) or mwy(i) or iny(i) or dey(i) or tay(i) or lab_a(i) or jsr(i) or
      (pos(#9'jmp ', listing[i]) > 0) or (pos(#9'.if', listing[i]) > 0) then begin optyY := ''; Break end;


// optyBP2 := '';

 if optyBP2 <> '' then
  for i:=0 to l-1 do begin

   if (optyBP2 <> '') and (sta_a(i) or sty(i) or asl(i) or rol(i) or lsr(i) or ror(i) or inc_(i) or dec_(i)) then
    if (pos('? '+copy(listing[i], 6, 256)+' ', optyBP2) > 0) or (pos(';'+copy(listing[i], 6, 256)+';', optyBP2) > 0) then begin optyBP2:=''; Break end;

   if sta_bp2(i) or sta_bp2_1(i) or jsr(i) or
      (pos(#9'jmp ', listing[i]) > 0) then begin optyBP2 := ''; Break end;

  end;


 if common.optimize.line <> common.optimize.old then begin
  WriteOut('');

  if x = 51 then
   WriteOut('; optimize FAIL ('+''''+arg0+''''+ ', '+UnitName[common.optimize.unitIndex].Name+'), line = '+IntToStr(common.optimize.line))
  else
   WriteOut('; optimize FAIL ('+IntToStr(x)+', '+UnitName[common.optimize.unitIndex].Name+'), line = '+IntToStr(common.optimize.line));

  WriteOut('');

  common.optimize.old := common.optimize.line;
 end;


(* -------------------------------------------------------------------------- *)

  for i := 0 to l - 1 do WriteInstruction(i);

(* -------------------------------------------------------------------------- *)

 end;


{$IFDEF USEOPTFILE}

 writeln(OptFile, StringOfChar('-', 32));
 writeln(OptFile, 'SOURCE');
 writeln(OptFile, StringOfChar('-', 32));

  for i := 0 to High(OptimizeBuf) - 1 do
    Writeln(OptFile, OptimizeBuf[i]);

 writeln(OptFile, StringOfChar('-', 32));
 writeln(OptFile, 'OPTIMIZE ',((x = 0) and inxUse),', x=',x,', ('+UnitName[common.optimize.unitIndex].Name+') line = ',common.optimize.line);
 writeln(OptFile, StringOfChar('-', 32));

  for i := 0 to l - 1 do
    Writeln(OptFile, listing[i]);

 writeln(OptFile);
 writeln(OptFile, StringOfChar('-', 64));
 writeln(OptFile);

{$ENDIF}

 SetLength(OptimizeBuf, 1);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure asm65(a: string = ''; comment : string ='');
var len, i: integer;
    optimize_code: Boolean;
    str: string;
begin

{$IFDEF OPTIMIZECODE}
 optimize_code := true;
{$ELSE}
 optimize_code := false;
{$ENDIF}

 if not OutputDisabled then

 if Pass = CODEGENERATIONPASS then begin

  if optimize_code and common.optimize.use then begin

   i:=High(OptimizeBuf);
   OptimizeBuf[i] := a;

   SetLength(OptimizeBuf, i+2);

  end else begin

   if High(OptimizeBuf) > 0 then

     OptimizeASM

   else begin

    str:=a;

    if comment<>'' then begin

     len:=0;

     for i := 1 to length(a) do
      if a[i] = #9 then
       inc(len, 8-(len mod 8))
      else
       if not(a[i] in [CR, LF]) then inc(len);

     while len < 56 do begin str:=str+#9; inc(len, 8) end;

     str:=str + comment;

    end;

    WriteOut(str);

   end;

  end;

 end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


end.
