// Optimized version of "StartsWith"
// Assumption is that "str" is always at least 4 chars, e.g. '#9abc'
function pos1(const str: String; const i: Integer): Boolean;
begin
  if (Length(str) > Length(TemporaryBuf[i])) // Compare lengths
    or (str[2] <> TemporaryBuf[i][2])  // Compare first regular letter first
    or (str[3] <> TemporaryBuf[i][3])  // ...
    or (str[4] <> TemporaryBuf[i][4])  // ...
    or (str[1] <> TemporaryBuf[i][1])  // Compare the typical #9 last
  then exit(False);
  Result := pos(str, TemporaryBuf[i]) = 1;  // Compare the rest
end;

// Check for 2 character label prefix
function pos1_lab(const str: String; const i: Integer): Boolean;
begin
  if (Length(str) > Length(TemporaryBuf[i])) // Compare lengths
    or (str[1] <> TemporaryBuf[i][1])  // Compare first regular character
    or (str[2] <> TemporaryBuf[i][2])  // Compare second regular character
  then exit(False);
  Result := True;
end;

// -----------------------------------------------------------------------------

  function MWY(const i: Integer): Boolean;
  begin
    Result := pos1(#9'mwy ', i)
  end;

  function MVY(const i: Integer): Boolean;
  begin
    Result := pos1(#9'mvy ', i)
  end;

  function MVA(const i: Integer): Boolean;
  begin
    Result := pos1(#9'mva ', i)
  end;

  function MVA_IM(const i: Integer): Boolean;
  begin
    Result := pos1(#9'mva #', i)
  end;

// -----------------------------------------------------------------------------

  function IY(const i: Integer): Boolean;
  begin
    Result := pos(',y', TemporaryBuf[i]) > 0
  end;

  function OPTI(const i: Integer): Boolean;
  begin
    Result := pos('; optimize ', TemporaryBuf[i]) > 0
  end;

  function mINLINE(const i: Integer): Boolean;
  begin
    Result := pos1(#9'm@INLINE', i)
  end;

  function ENDL(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'.ENDL'
  end;

  function IFTMP(const i: Integer): Boolean;
  begin
    Result := pos1(#9'lda IFTMP_', i)
  end;

  function JMP_L(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jmp l_', i)
  end;

  function JMP_A(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jmp @+', i)
  end;

// -----------------------------------------------------------------------------

  function LAB_L(const i: Integer): Boolean;
  begin
    Result := pos1_lab('l_', i)
  end;

  function LAB_B(const i: Integer): Boolean;
  begin
    Result := pos1_lab('b_', i)
  end;

  function LAB_C(const i: Integer): Boolean;
  begin
    Result := pos1_lab('c_', i)
  end;

  function LAB_S(const i: Integer): Boolean;
  begin
    Result := pos1_lab('s_', i)
  end;

// -----------------------------------------------------------------------------

  function INC_(const i: Integer): Boolean;
  begin
    Result := pos1(#9'inc ', i)
  end;

  function DEC_(const i: Integer): Boolean;
  begin
    Result := pos1(#9'dec ', i)
  end;

  function JSR(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jsr ', i)
  end;

  function LDY(const i: Integer): Boolean;
  begin
    Result := pos1(#9'ldy ', i)
  end;

  function LDY_IM(const i: Integer): Boolean;
  begin
    Result := pos1(#9'ldy #', i)
  end;

  function CMP(const i: Integer): Boolean;
  begin
    Result := pos1(#9'cmp ', i)
  end;

  function LDA(const i: Integer): Boolean;
  begin
    Result := pos1(#9'lda ', i)
  end;

  function LDA_IM(const i: Integer): Boolean;
  begin
    Result := pos1(#9'lda #', i)
  end;

  function STA(const i: Integer): Boolean;
  begin
    Result := pos1(#9'sta ', i)
  end;

  function ORA(const i: Integer): Boolean;
  begin
    Result := pos1(#9'ora ', i)
  end;

  function LSR(const i: Integer): Boolean;
  begin
    Result := pos1(#9'lsr ', i)
  end;

  function STY(const i: Integer): Boolean;
  begin
    Result := pos1(#9'sty ', i)
  end;

  function ADD(const i: Integer): Boolean;
  begin
    Result := pos1(#9'add ', i)
  end;

  function ADC(const i: Integer): Boolean;
  begin
    Result := pos1(#9'adc ', i)
  end;

  function SUB(const i: Integer): Boolean;
  begin
    Result := pos1(#9'sub ', i)
  end;

  function SBC(const i: Integer): Boolean;
  begin
    Result := pos1(#9'sbc ', i)
  end;

// -----------------------------------------------------------------------------

  function LDA_STACK(const i: Integer): Boolean;
  begin
    Result := pos1(#9'lda :STACK', i);
  end;

  function STA_STACK(const i: Integer): Boolean;
  begin
    Result := pos1(#9'sta :STACK', i)
  end;

  function STY_STACK(const i: Integer): Boolean;
  begin
    Result := pos1(#9'sty :STACK', i)
  end;

  function MVA_STACK(const i: Integer): Boolean;
  begin
    Result := pos1(#9'mva :STACK', i)
  end;

  function ASL_STACK(const i: Integer): Boolean;
  begin
    Result := pos1(#9'asl :STACK', i)
  end;

  function ROL_STACK(const i: Integer): Boolean;
  begin
    Result := pos1(#9'rol :STACK', i)
  end;

// -----------------------------------------------------------------------------

  function LDA_EAX(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'lda :eax'
  end;

  function LDA_EAX_1(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'lda :eax+1'
  end;

  function STA_EAX(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :eax'
  end;

  function STA_EAX_1(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :eax+1'
  end;

  function STA_ECX(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :ecx'
  end;

  function STA_ECX_1(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :ecx+1'
  end;

// -----------------------------------------------------------------------------

  function ASL_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'asl @'
  end;

  function CMP_IM_0(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'cmp #$00'
  end;

  function LDY_1(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'ldy #1'
  end;

  function LAB_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = '@'
  end;

  function LDA_IM_0(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'lda #$00'
  end;

  function LDY_IM_0(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'ldy #$00'
  end;

  function INX(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'inx'
  end;

  function DEX(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'dex'
  end;

  function INY(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'iny'
  end;

  function DEY(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'dey'
  end;

  function TYA(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'tya'
  end;

 function TAY(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'tay'
  end;

  function STA_BP2(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp2'
  end;

  function STA_BP2_1(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp2+1'
  end;

  function STA_BP_1(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp+1'
  end;

  function STA_BP_Y(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta (:bp),y'
  end;

  function LDA_BP2_Y(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'lda (:bp2),y'
  end;

// -----------------------------------------------------------------------------

  function BEQ_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'beq @+'
  end;

  function BNE_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'bne @+'
  end;

  function BCC_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'bcc @+'
  end;

  function BCS_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'bcs @+'
  end;

  function BPL_A(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'bpl @+'
  end;

// -----------------------------------------------------------------------------

  function SNE(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sne'
  end;

  function SEQ(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'seq'
  end;

  function SCC(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'scc'
  end;

  function SCS(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'scs'
  end;

  function SPL(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'spl'
  end;

  function SMI(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'smi'
  end;

  function SVC(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'svc'
  end;

  function SVS(const i: Integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'svs'
  end;

// -----------------------------------------------------------------------------

  function JEQ(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jeq ', i)
  end;

  function JNE(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jne ', i)
  end;

  function JCC(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jcc ', i)
  end;

  function JCS(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jcs ', i)
  end;

  function JMI(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jmi ', i)
  end;

  function JPL(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jpl ', i)
  end;

// -----------------------------------------------------------------------------

  function JEQ_L(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jeq l_', i)
  end;

  function JNE_L(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jne l_', i)
  end;

  function JCC_L(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jcc l_', i)
  end;

  function JCS_L(const i: Integer): Boolean;
  begin
    Result := pos1(#9'jcs l_', i)
  end;

// -----------------------------------------------------------------------------

  function ADD_SUB(const i: Integer): Boolean;
  begin
    Result := pos1(#9'add ', i) or pos1(#9'sub ', i)
  end;

  function ADC_SBC(const i: Integer): Boolean;
  begin
    Result := pos1(#9'adc ', i) or pos1(#9'sbc ', i)
  end;

  function AND_ORA_EOR(const i: Integer): Boolean;
  begin
    Result := pos1(#9'and ', i) or pos1(#9'ora ', i) or pos1(#9'eor ', i);
  end;

  function STA_ADR(const i: Integer): Boolean;
  begin
    if (pos(',y', TemporaryBuf[i]) > 0) then
      Result := pos1(#9'sta adr.', i) or (pos1(#9'sta ', i) and (pos('.adr.', TemporaryBuf[i]) > 0))
    else
      Result := false;
  end;
