
function MWY(i: Integer): Boolean;
begin
  Result := pos(#9'mwy ', TemporaryBuf[i]) = 1;
end;

function MVY(i: Integer): Boolean;
begin
  Result := pos(#9'mvy ', TemporaryBuf[i]) = 1;
end;

function MVA(i: Integer): Boolean;
begin
  Result := pos(#9'mva ', TemporaryBuf[i]) = 1;
end;

function MVA_IM(i: Integer): Boolean;
begin
  Result := pos(#9'mva #', TemporaryBuf[i]) = 1;
end;

function MVA_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'mva :STACK', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function mINLINE(i: Integer): Boolean;
begin
  Result := pos(#9'm@INLINE', TemporaryBuf[i]) = 1;
end;

function ENDL(i: Integer): Boolean;
begin
  Result := pos(#9'.ENDL', TemporaryBuf[i]) = 1;
end;

function IFTMP(i: Integer): Boolean;
begin
  Result := pos(#9'lda IFTMP_', TemporaryBuf[i]) = 1;
end;

function JMP_L(i: Integer): Boolean;
begin
  Result := pos(#9'jmp l_', TemporaryBuf[i]) = 1;
end;

function JMP_A(i: Integer): Boolean;
begin
  Result := pos(#9'jmp @+', TemporaryBuf[i]) = 1;
end;

function LAB_L(i: Integer): Boolean;
begin
  Result := pos('l_', TemporaryBuf[i]) = 1;
end;

function LAB_B(i: Integer): Boolean;
begin
  Result := pos('b_', TemporaryBuf[i]) = 1;
end;

function LAB_C(i: Integer): Boolean;
begin
  Result := pos('c_', TemporaryBuf[i]) = 1;
end;

function LAB_S(i: Integer): Boolean;
begin
  Result := pos('s_', TemporaryBuf[i]) = 1;
end;

function INC_(i: Integer): Boolean;
begin
  Result := pos(#9'inc ', TemporaryBuf[i]) = 1;
end;

function DEC_(i: Integer): Boolean;
begin
  Result := pos(#9'dec ', TemporaryBuf[i]) = 1;
end;

function JSR(i: Integer): Boolean;
begin
  Result := pos(#9'jsr ', TemporaryBuf[i]) = 1;
end;

function LDY(i: Integer): Boolean;
begin
  Result := pos(#9'ldy ', TemporaryBuf[i]) = 1;
end;

function LDY_IM(i: Integer): Boolean;
begin
  Result := pos(#9'ldy #', TemporaryBuf[i]) = 1;
end;

function CMP(i: Integer): Boolean;
begin
  Result := pos(#9'cmp ', TemporaryBuf[i]) = 1;
end;

function LDA(i: Integer): Boolean;
begin
  Result := pos(#9'lda ', TemporaryBuf[i]) = 1;
end;

function LDA_IM(i: Integer): Boolean;
begin
  Result := pos(#9'lda #', TemporaryBuf[i]) = 1;
end;

function LDA_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'lda :STACK', TemporaryBuf[i]) = 1;
end;

function STA(i: Integer): Boolean;
begin
  Result := pos(#9'sta ', TemporaryBuf[i]) = 1;
end;

function STA_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'sta :STACK', TemporaryBuf[i]) = 1;
end;

function ORA(i: Integer): Boolean;
begin
  Result := pos(#9'ora ', TemporaryBuf[i]) = 1;
end;

function LSR(i: Integer): Boolean;
begin
  Result := pos(#9'lsr ', TemporaryBuf[i]) = 1;
end;

function ASL_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'asl :STACK', TemporaryBuf[i]) = 1;
end;

function ROL_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'rol :STACK', TemporaryBuf[i]) = 1;
end;

function STY(i: Integer): Boolean;
begin
  Result := pos(#9'sty ', TemporaryBuf[i]) = 1;
end;

function STY_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'sty :STACK', TemporaryBuf[i]) = 1;
end;

function ADD(i: Integer): Boolean;
begin
  Result := pos(#9'add ', TemporaryBuf[i]) = 1;
end;

function ADC(i: Integer): Boolean;
begin
  Result := pos(#9'adc ', TemporaryBuf[i]) = 1;
end;

function SUB(i: Integer): Boolean;
begin
  Result := pos(#9'sub ', TemporaryBuf[i]) = 1;
end;

function ADD_SUB(i: Integer): Boolean;
begin
  Result := (pos(#9'add ', TemporaryBuf[i]) = 1) or (pos(#9'sub ', TemporaryBuf[i]) = 1);
end;

function ADC_SBC(i: Integer): Boolean;
begin
  Result := (pos(#9'adc ', TemporaryBuf[i]) = 1) or (pos(#9'sbc ', TemporaryBuf[i]) = 1);
end;

function SBC(i: Integer): Boolean;
begin
  Result := pos(#9'sbc ', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function LDA_EAX(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda :eax';
end;

function LDA_EAX_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda :eax+1';
end;

function STA_EAX(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :eax';
end;

function STA_EAX_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :eax+1';
end;

function STA_ECX(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :ecx';
end;

function STA_ECX_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :ecx+1';
end;

// -----------------------------------------------------------------------------

function ASL_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'asl @';
end;

function CMP_IM_0(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'cmp #$00';
end;

function LDY_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'ldy #1';
end;

function LAB_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = '@';
end;

function LDA_IM_0(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda #$00';
end;

function LDY_IM_0(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'ldy #$00';
end;

function INX(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'inx';
end;

function DEX(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'dex';
end;

function INY(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'iny';
end;

function DEY(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'dey';
end;

function TYA(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'tya';
end;

function TAY(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'tay';
end;

function STA_BP2(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp2';
end;

function STA_BP2_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp2+1';
end;

function STA_BP_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp+1';
end;

function STA_BP_Y(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta (:bp),y';
end;

function LDA_BP2_Y(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'lda (:bp2),y';
end;

// -----------------------------------------------------------------------------

function BEQ_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'beq @+';
end;

function BNE_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bne @+';
end;

function BCC_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bcc @+';
end;

function BCS_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bcs @+';
end;

function BPL_A(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'bpl @+';
end;

// -----------------------------------------------------------------------------

function SNE(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sne';
end;

function SEQ(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'seq';
end;

function SCC(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'scc';
end;

function SCS(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'scs';
end;

function SPL(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'spl';
end;

function SMI(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'smi';
end;

function SVC(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'svc';
end;

function SVS(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'svs';
end;

// -----------------------------------------------------------------------------

function JEQ(i: Integer): Boolean;
begin
  Result := pos(#9'jeq ', TemporaryBuf[i]) = 1;
end;

function JNE(i: Integer): Boolean;
begin
  Result := pos(#9'jne ', TemporaryBuf[i]) = 1;
end;

function JCC(i: Integer): Boolean;
begin
  Result := pos(#9'jcc ', TemporaryBuf[i]) = 1;
end;

function JCS(i: Integer): Boolean;
begin
  Result := pos(#9'jcs ', TemporaryBuf[i]) = 1;
end;

function JMI(i: Integer): Boolean;
begin
  Result := pos(#9'jmi ', TemporaryBuf[i]) = 1;
end;

function JPL(i: Integer): Boolean;
begin
  Result := pos(#9'jpl ', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function JEQ_L(i: Integer): Boolean;
begin
  Result := pos(#9'jeq l_', TemporaryBuf[i]) = 1;
end;

function JNE_L(i: Integer): Boolean;
begin
  Result := pos(#9'jne l_', TemporaryBuf[i]) = 1;
end;

function JCC_L(i: Integer): Boolean;
begin
  Result := pos(#9'jcc l_', TemporaryBuf[i]) = 1;
end;

function JCS_L(i: Integer): Boolean;
begin
  Result := pos(#9'jcs l_', TemporaryBuf[i]) = 1;
end;

// -----------------------------------------------------------------------------

function AND_ORA_EOR(i: Integer): Boolean;
begin
  Result := (pos(#9'and ', TemporaryBuf[i]) = 1) or (pos(#9'ora ', TemporaryBuf[i]) = 1) or
    (pos(#9'eor ', TemporaryBuf[i]) = 1);
end;

function IY(i: Integer): Boolean;
begin
  Result := pos(',y', TemporaryBuf[i]) > 0;
end;

// -----------------------------------------------------------------------------

function STA_ADR(i: Integer): Boolean;
begin
  Result := iy(i) and (pos(#9'sta adr.', TemporaryBuf[i]) = 1) or
    ((pos(#9'sta ', TemporaryBuf[i]) = 1) and (pos('.adr.', TemporaryBuf[i]) > 0));
end;

function OPTI(i: Integer): Boolean;
begin
  Result := pos('; optimize ', TemporaryBuf[i]) > 0;
end;

