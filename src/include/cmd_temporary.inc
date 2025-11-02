
function MWY(const i: Integer): Boolean;
begin
  Result := pos(#9'mwy ', TemporaryBuf[i]) = 1;
end;

function MVY(const i: Integer): Boolean;
begin
  Result := pos(#9'mvy ', TemporaryBuf[i]) = 1;
end;

function MVA(const i: Integer): Boolean;
begin
  Result := pos(#9'mva ', TemporaryBuf[i]) = 1;
end;

function MVA_IM(const i: Integer): Boolean;
begin
  Result := pos(#9'mva #', TemporaryBuf[i]) = 1;
end;

function MVA_STACK(const i: Integer): Boolean;
begin
  Result := pos(#9'mva :STACK', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function mINLINE(const i: Integer): Boolean;
begin
  Result := pos(#9'm@INLINE', TemporaryBuf[i]) = 1;
end;

function ENDL(const i: Integer): Boolean;
begin
  Result := pos(#9'.ENDL', TemporaryBuf[i]) = 1;
end;

function IFTMP(const i: Integer): Boolean;
begin
  Result := pos(#9'lda IFTMP_', TemporaryBuf[i]) = 1;
end;

function JMP_L(const i: Integer): Boolean;
begin
  Result := pos(#9'jmp l_', TemporaryBuf[i]) = 1;
end;

function JMP_A(const i: Integer): Boolean;
begin
  Result := pos(#9'jmp @+', TemporaryBuf[i]) = 1;
end;

function LAB_L(const i: Integer): Boolean;
begin
  Result := pos('l_', TemporaryBuf[i]) = 1;
end;

function LAB_B(const i: Integer): Boolean;
begin
  Result := pos('b_', TemporaryBuf[i]) = 1;
end;

function LAB_C(const i: Integer): Boolean;
begin
  Result := pos('c_', TemporaryBuf[i]) = 1;
end;

function LAB_S(const i: Integer): Boolean;
begin
  Result := pos('s_', TemporaryBuf[i]) = 1;
end;

function INC_(const i: Integer): Boolean;
begin
  Result := pos(#9'inc ', TemporaryBuf[i]) = 1;
end;

function DEC_(const i: Integer): Boolean;
begin
  Result := pos(#9'dec ', TemporaryBuf[i]) = 1;
end;

function JSR(const i: Integer): Boolean;
begin
  Result := pos(#9'jsr ', TemporaryBuf[i]) = 1;
end;

function LDY(const i: Integer): Boolean;
begin
  Result := pos(#9'ldy ', TemporaryBuf[i]) = 1;
end;

function LDY_IM(const i: Integer): Boolean;
begin
  Result := pos(#9'ldy #', TemporaryBuf[i]) = 1;
end;

function CMP(const i: Integer): Boolean;
begin
  Result := pos(#9'cmp ', TemporaryBuf[i]) = 1;
end;

function LDA(const i: Integer): Boolean;
begin
  Result := pos(#9'lda ', TemporaryBuf[i]) = 1;
end;

function LDA_IM(const i: Integer): Boolean;
begin
  Result := pos(#9'lda #', TemporaryBuf[i]) = 1;
end;

function LDA_STACK(const i: Integer): Boolean;
begin
  Result := pos(#9'lda :STACK', TemporaryBuf[i]) = 1;
end;

function STA(const i: Integer): Boolean;
begin
  Result := pos(#9'sta ', TemporaryBuf[i]) = 1;
end;

function STA_STACK(const i: Integer): Boolean;
begin
  Result := pos(#9'sta :STACK', TemporaryBuf[i]) = 1;
end;

function ORA(const i: Integer): Boolean;
begin
  Result := pos(#9'ora ', TemporaryBuf[i]) = 1;
end;

function LSR(const i: Integer): Boolean;
begin
  Result := pos(#9'lsr ', TemporaryBuf[i]) = 1;
end;

function ASL_STACK(const i: Integer): Boolean;
begin
  Result := pos(#9'asl :STACK', TemporaryBuf[i]) = 1;
end;

function ROL_STACK(const i: Integer): Boolean;
begin
  Result := pos(#9'rol :STACK', TemporaryBuf[i]) = 1;
end;

function STY(const i: Integer): Boolean;
begin
  Result := pos(#9'sty ', TemporaryBuf[i]) = 1;
end;

function STY_STACK(const i: Integer): Boolean;
begin
  Result := pos(#9'sty :STACK', TemporaryBuf[i]) = 1;
end;

function ADD(const i: Integer): Boolean;
begin
  Result := pos(#9'add ', TemporaryBuf[i]) = 1;
end;

function ADC(const i: Integer): Boolean;
begin
  Result := pos(#9'adc ', TemporaryBuf[i]) = 1;
end;

function SUB(const i: Integer): Boolean;
begin
  Result := pos(#9'sub ', TemporaryBuf[i]) = 1;
end;

function ADD_SUB(const i: Integer): Boolean;
begin
  Result := (pos(#9'add ', TemporaryBuf[i]) = 1) or (pos(#9'sub ', TemporaryBuf[i]) = 1);
end;

function ADC_SBC(const i: Integer): Boolean;
begin
  Result := (pos(#9'adc ', TemporaryBuf[i]) = 1) or (pos(#9'sbc ', TemporaryBuf[i]) = 1);
end;

function SBC(const i: Integer): Boolean;
begin
  Result := pos(#9'sbc ', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function LDA_EAX(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda :eax';
end;

function LDA_EAX_1(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda :eax+1';
end;

function STA_EAX(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :eax';
end;

function STA_EAX_1(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :eax+1';
end;

function STA_ECX(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :ecx';
end;

function STA_ECX_1(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :ecx+1';
end;

// -----------------------------------------------------------------------------

function ASL_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'asl @';
end;

function CMP_IM_0(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'cmp #$00';
end;

function LDY_1(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'ldy #1';
end;

function LAB_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = '@';
end;

function LDA_IM_0(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda #$00';
end;

function LDY_IM_0(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'ldy #$00';
end;

function INX(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'inx';
end;

function DEX(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'dex';
end;

function INY(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'iny';
end;

function DEY(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'dey';
end;

function TYA(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'tya';
end;

function TAY(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'tay';
end;

function STA_BP2(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp2';
end;

function STA_BP2_1(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp2+1';
end;

function STA_BP_1(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp+1';
end;

function STA_BP_Y(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta (:bp),y';
end;

function LDA_BP2_Y(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda (:bp2),y';
end;

// -----------------------------------------------------------------------------

function BEQ_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'beq @+';
end;

function BNE_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bne @+';
end;

function BCC_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bcc @+';
end;

function BCS_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bcs @+';
end;

function BPL_A(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bpl @+';
end;

// -----------------------------------------------------------------------------

function SNE(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sne';
end;

function SEQ(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'seq';
end;

function SCC(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'scc';
end;

function SCS(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'scs';
end;

function SPL(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'spl';
end;

function SMI(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'smi';
end;

function SVC(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'svc';
end;

function SVS(const i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'svs';
end;

// -----------------------------------------------------------------------------

function JEQ(const i: Integer): Boolean;
begin
  Result := pos(#9'jeq ', TemporaryBuf[i]) = 1;
end;

function JNE(const i: Integer): Boolean;
begin
  Result := pos(#9'jne ', TemporaryBuf[i]) = 1;
end;

function JCC(const i: Integer): Boolean;
begin
  Result := pos(#9'jcc ', TemporaryBuf[i]) = 1;
end;

function JCS(const i: Integer): Boolean;
begin
  Result := pos(#9'jcs ', TemporaryBuf[i]) = 1;
end;

function JMI(const i: Integer): Boolean;
begin
  Result := pos(#9'jmi ', TemporaryBuf[i]) = 1;
end;

function JPL(const i: Integer): Boolean;
begin
  Result := pos(#9'jpl ', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function JEQ_L(const i: Integer): Boolean;
begin
  Result := pos(#9'jeq l_', TemporaryBuf[i]) = 1;
end;

function JNE_L(const i: Integer): Boolean;
begin
  Result := pos(#9'jne l_', TemporaryBuf[i]) = 1;
end;

function JCC_L(const i: Integer): Boolean;
begin
  Result := pos(#9'jcc l_', TemporaryBuf[i]) = 1;
end;

function JCS_L(const i: Integer): Boolean;
begin
  Result := pos(#9'jcs l_', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function AND_ORA_EOR(const i: Integer): Boolean;
begin
  Result := (pos(#9'and ', TemporaryBuf[i]) = 1) or (pos(#9'ora ', TemporaryBuf[i]) = 1) or
    (pos(#9'eor ', TemporaryBuf[i]) = 1);
end;

function IY(const i: Integer): Boolean;
begin
  Result := pos(',y', TemporaryBuf[i]) > 0;
end;

// -----------------------------------------------------------------------------

function STA_ADR(const i: Integer): Boolean;
begin
  Result := iy(i) and (pos(#9'sta adr.', TemporaryBuf[i]) = 1) or
    ((pos(#9'sta ', TemporaryBuf[i]) = 1) and (pos('.adr.', TemporaryBuf[i]) > 0));
end;

function OPTI(const i: Integer): Boolean;
begin
  Result := pos('; optimize ', TemporaryBuf[i]) > 0;
end;
