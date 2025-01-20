
  function IFTMP(i: integer): Boolean;
  begin
    Result := (pos(#9'lda IFTMP_', TemporaryBuf[i]) = 1);
  end;

  function JMP(i: integer): Boolean;
  begin
    Result := (pos(#9'jmp l_', TemporaryBuf[i]) = 1);
  end;

  function LAB_L(i: integer): Boolean;
  begin
    Result := (pos('l_', TemporaryBuf[i]) = 1);
  end;

  function JSR(i: integer): Boolean;
  begin
    Result := (pos(#9'jsr ', TemporaryBuf[i]) = 1)
  end;

  function LDY(i: integer): Boolean;
  begin
    Result := (pos(#9'ldy ', TemporaryBuf[i]) = 1)
  end;

  function LDY_IM(i: integer): Boolean;
  begin
    Result := (pos(#9'ldy #', TemporaryBuf[i]) = 1)
  end;

  function CMP(i: integer): Boolean;
  begin
    Result := (pos(#9'cmp ', TemporaryBuf[i]) = 1)
  end;

  function LDA(i: integer): Boolean;
  begin
    Result := (pos(#9'lda ', TemporaryBuf[i]) = 1)
  end;

  function LDA_IM(i: integer): Boolean;
  begin
    Result := (pos(#9'lda #', TemporaryBuf[i]) = 1)
  end;

  function LDA_STACK(i: integer): Boolean;
  begin
    Result := pos(#9'lda :STACK', TemporaryBuf[i]) = 1;
  end;

  function STA(i: integer): Boolean;
  begin
    Result := (pos(#9'sta ', TemporaryBuf[i]) = 1)
  end;

  function STA_STACK(i: integer): Boolean;
  begin
    Result := (pos(#9'sta :STACK', TemporaryBuf[i]) = 1)
  end;


  function ADD(i: integer): Boolean;
  begin
    Result := (pos(#9'add ', TemporaryBuf[i]) = 1)
  end;

  function SUB(i: integer): Boolean;
  begin
    Result := (pos(#9'sub ', TemporaryBuf[i]) = 1)
  end;

  function ADD_SUB(i: integer): Boolean;
  begin
    Result := (pos(#9'add ', TemporaryBuf[i]) = 1) or (pos(#9'sub ', TemporaryBuf[i]) = 1)
  end;

  function ADC_SBC(i: integer): Boolean;
  begin
    Result := (pos(#9'adc ', TemporaryBuf[i]) = 1) or (pos(#9'sbc ', TemporaryBuf[i]) = 1)
  end;


  function DEX(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'dex'
  end;

  function STA_BP2(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp2'
  end;

  function STA_BP2_1(i: integer): Boolean;
  begin
    Result := TemporaryBuf[i] = #9'sta :bp2+1'
  end;


  function IY(i: integer): Boolean;
  begin
    Result := pos(',y', TemporaryBuf[i]) > 0;
  end;
