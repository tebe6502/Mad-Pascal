
  function MWY(i: integer): Boolean;
  begin
    Result := pos(#9'mwy ', TemporaryBuf[i]) = 1
  end;

  function MVY(i: integer): Boolean;
  begin
    Result := pos(#9'mvy ', TemporaryBuf[i]) = 1
  end;

  function MVA(i: integer): Boolean;
  begin
    Result := pos(#9'mva ', TemporaryBuf[i]) = 1
  end;

  function MVA_IM(i: integer): Boolean;
  begin
    Result := pos(#9'mva #', TemporaryBuf[i]) = 1
  end;

  function MVA_STACK(i: integer): Boolean;
  begin
    Result := pos(#9'mva :STACK', TemporaryBuf[i]) = 1
  end;


  function IFTMP(i: integer): Boolean;
  begin
    Result := pos(#9'lda IFTMP_', TemporaryBuf[i]) = 1
  end;

  function JMP(i: integer): Boolean;
  begin
    Result := pos(#9'jmp l_', TemporaryBuf[i]) = 1
  end;

  function LAB_L(i: integer): Boolean;
  begin
    Result := pos('l_', TemporaryBuf[i]) = 1
  end;

  function LAB_B(i: integer): Boolean;
  begin
    Result := pos('b_', TemporaryBuf[i]) = 1
  end;

  function LAB_C(i: integer): Boolean;
  begin
    Result := pos('c_', TemporaryBuf[i]) = 1
  end;

  function LAB_S(i: integer): Boolean;
  begin
    Result := pos('s_', TemporaryBuf[i]) = 1
  end;

  function INC_(i: integer): Boolean;
  begin
    Result := pos(#9'inc ', TemporaryBuf[i]) = 1
  end;

  function DEC_(i: integer): Boolean;
  begin
    Result := pos(#9'dec ', TemporaryBuf[i]) = 1
  end;

  function JSR(i: integer): Boolean;
  begin
    Result := pos(#9'jsr ', TemporaryBuf[i]) = 1
  end;

  function LDY(i: integer): Boolean;
  begin
    Result := pos(#9'ldy ', TemporaryBuf[i]) = 1
  end;

  function LDY_IM(i: integer): Boolean;
  begin
    Result := pos(#9'ldy #', TemporaryBuf[i]) = 1
  end;

  function CMP(i: integer): Boolean;
  begin
    Result := pos(#9'cmp ', TemporaryBuf[i]) = 1
  end;

  function LDA(i: integer): Boolean;
  begin
    Result := pos(#9'lda ', TemporaryBuf[i]) = 1
  end;

  function LDA_IM(i: integer): Boolean;
  begin
    Result := pos(#9'lda #', TemporaryBuf[i]) = 1
  end;

  function LDA_STACK(i: integer): Boolean;
  begin
    Result := pos(#9'lda :STACK', TemporaryBuf[i]) = 1
  end;

  function STA(i: integer): Boolean;
  begin
    Result := pos(#9'sta ', TemporaryBuf[i]) = 1
  end;

  function STA_STACK(i: integer): Boolean;
  begin
    Result := pos(#9'sta :STACK', TemporaryBuf[i]) = 1
  end;

  function STY(i: integer): Boolean;
  begin
    Result := pos(#9'sty ', TemporaryBuf[i]) = 1
  end;

  function STY_STACK(i: integer): Boolean;
  begin
    Result := pos(#9'sty :STACK', TemporaryBuf[i]) = 1
  end;

  function ADD(i: integer): Boolean;
  begin
    Result := pos(#9'add ', TemporaryBuf[i]) = 1
  end;

  function SUB(i: integer): Boolean;
  begin
    Result := pos(#9'sub ', TemporaryBuf[i]) = 1
  end;

  function ADD_SUB(i: integer): Boolean;
  begin
    Result := (pos(#9'add ', TemporaryBuf[i]) = 1) or (pos(#9'sub ', TemporaryBuf[i]) = 1)
  end;

  function ADC_SBC(i: integer): Boolean;
  begin
    Result := (pos(#9'adc ', TemporaryBuf[i]) = 1) or (pos(#9'sbc ', TemporaryBuf[i]) = 1)
  end;

  function SBC(i: integer): Boolean;
  begin
    Result := pos(#9'sbc ', TemporaryBuf[i]) = 1
  end;


  function ASL_A(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'asl @'
  end;

  function CMP_IM_0(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'cmp #$00'
  end;

  function LDY_1(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'ldy #1'
  end;

  function LAB_A(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = '@'
  end;

  function LDA_IM_0(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'lda #$00'
  end;

  function LDY_IM_0(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'ldy #$00'
  end;

  function INX(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'inx'
  end;

  function DEX(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'dex'
  end;

  function INY(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'iny'
  end;

  function DEY(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'dey'
  end;

  function TYA(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'tya'
  end;

 function TAY(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'tay'
  end;

  function STA_BP2(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp2'
  end;

  function STA_BP2_1(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp2+1'
  end;

  function STA_BP_1(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp+1'
  end;

  function STA_BP_Y(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta (:bp),y'
  end;

  function LDA_BP2_Y(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'lda :bp2'
  end;


  function SNE(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sne'
  end;

  function SEQ(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'seq'
  end;

  function SCC(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'scc'
  end;

  function SCS(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'scs'
  end;

  function SPL(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'spl'
  end;

  function SMI(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'smi'
  end;

  function SVC(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'svc'
  end;

  function SVS(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'svs'
  end;


  function JEQ(i: integer): Boolean;
  begin
    Result := pos(#9'jeq ', TemporaryBuf[i]) = 1
  end;

  function JNE(i: integer): Boolean;
  begin
    Result := pos(#9'jne ', TemporaryBuf[i]) = 1
  end;

  function JCC(i: integer): Boolean;
  begin
    Result := pos(#9'jcc ', TemporaryBuf[i]) = 1
  end;

  function JCS(i: integer): Boolean;
  begin
    Result := pos(#9'jcs ', TemporaryBuf[i]) = 1
  end;

  function JMI(i: integer): Boolean;
  begin
    Result := pos(#9'jmi ', TemporaryBuf[i]) = 1
  end;

  function JPL(i: integer): Boolean;
  begin
    Result := pos(#9'jpl ', TemporaryBuf[i]) = 1
  end;


  function JEQ_L(i: integer): Boolean;
  begin
    Result := pos(#9'jeq l_', TemporaryBuf[i]) = 1
  end;

  function JNE_L(i: integer): Boolean;
  begin
    Result := pos(#9'jne l_', TemporaryBuf[i]) = 1
  end;

  function JCC_L(i: integer): Boolean;
  begin
    Result := pos(#9'jcc l_', TemporaryBuf[i]) = 1
  end;

  function JCS_L(i: integer): Boolean;
  begin
    Result := pos(#9'jcs l_', TemporaryBuf[i]) = 1
  end;


  function AND_ORA_EOR(i: integer): Boolean;
  begin
    Result := (pos(#9'and ', TemporaryBuf[i]) = 1) or (pos(#9'ora ', TemporaryBuf[i]) = 1) or (pos(#9'eor ', TemporaryBuf[i]) = 1);
  end;

  function IY(i: integer): Boolean;
  begin
    Result := pos(',y', TemporaryBuf[i]) > 0
  end;


  function STA_ADR(i: integer): Boolean;
  begin
    Result :=  iy(i) and (pos(#9'sta adr.', TemporaryBuf[i]) = 1) or ((pos(#9'sta ', TemporaryBuf[i]) = 1) and (pos('.adr.', TemporaryBuf[i]) > 0));
  end;


  function OPTI(i: integer): Boolean;
  begin
    Result := pos('; optimize ', TemporaryBuf[i]) > 0
  end;

