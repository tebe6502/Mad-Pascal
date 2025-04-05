function MVA(i: Integer): Boolean;
begin
  Result := pos(#9'mva ', TemporaryBuf[i]) = 1;
end;

function MVA_IM(i: Integer): Boolean;
begin
  Result := pos(#9'mva #', TemporaryBuf[i]) = 1;
end;


function IFTMP(i: Integer): Boolean;
begin
  Result := pos(#9'lda IFTMP_', TemporaryBuf[i]) = 1;
end;

function JMP(i: Integer): Boolean;
begin
  Result := pos(#9'jmp l_', TemporaryBuf[i]) = 1;
end;

function LAB_L(i: Integer): Boolean;
begin
  Result := pos('l_', TemporaryBuf[i]) = 1;
end;

function LAB_A(i: Integer): Boolean;
begin
  Result := (TemporaryBuf[i] = '@');
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


function DEX(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'dex';
end;

function STA_BP2(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp2';
end;

function STA_BP2_1(i: Integer): Boolean;
begin
  Result := TemporaryBuf[i] = #9'sta :bp2+1';
end;


function AND_ORA_EOR(i: Integer): Boolean;
begin
  Result := (pos(#9'and ', TemporaryBuf[i]) = 1) or (pos(#9'ora ', TemporaryBuf[i]) = 1) or
    (pos(#9'eor ', TemporaryBuf[i]) = 1);
end;

function IY(i: Integer): Boolean;
begin
  Result := pos(',y', TemporaryBuf[i]) > 0;
end;


function STA_ADR(i: Integer): Boolean;
begin
  Result := iy(i) and (pos(#9'sta adr.', TemporaryBuf[i]) = 1) or
    ((pos(#9'sta ', TemporaryBuf[i]) = 1) and (pos('.adr.', TemporaryBuf[i]) > 0));
end;


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


function OPTI(i: Integer): Boolean;
begin
  Result := pos('; optimize ', TemporaryBuf[i]) > 0;
end;
