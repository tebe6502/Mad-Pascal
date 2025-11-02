
function LOCAL(i: Integer): Boolean;
begin

  if (i < 0) {or (listing[i] = '')} then
    Result := False
  else
    Result := (listing[i] = #9'.LOCAL');

end;

function ENDL(i: Integer): Boolean;
begin

  if (i < 0) {or (listing[i] = '')} then
    Result := False
  else
    Result := (listing[i] = #9'.ENDL');

end;

function _FOR(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'#for');
end;

function _IF(i: Integer): Boolean;
begin
  Result := pos(#9'.if', listing[i]) = 1;
end;

function EIF(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'eif');
end;

function STA_PARAM(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta @PARAM?');
end;

// -----------------------------------------------------------------------------

function LDA_ZTMP(i: Integer): Boolean;
begin
  Result := pos(#9'lda :ztmp', listing[i]) = 1;
end;

function STA_ZTMP(i: Integer): Boolean;
begin
  Result := pos(#9'sta :ztmp', listing[i]) = 1;
end;

function STY_ZTMP(i: Integer): Boolean;
begin
  Result := pos(#9'sty :ztmp', listing[i]) = 1;
end;

function SUB_ZTMP(i: Integer): Boolean;
begin
  Result := pos(#9'sub :ztmp', listing[i]) = 1;
end;

// -----------------------------------------------------------------------------

function ASL_STACK_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'asl :STACKORIGIN,x');
end;

function LDY_STACK_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN,x');
end;

function LDY_STACK_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN+STACKWIDTH,x');
end;

function STY_STACK_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sty :STACKORIGIN,x');
end;

function LDY_STACK_PREV_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN-1,x');
end;

function STY_STACK_PREV_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sty :STACKORIGIN-1,x');
end;

function LDY_STACK_NEXT_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN+1,x');
end;

function STY_STACK_NEXT_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sty :STACKORIGIN+1,x');
end;

function LDA_STACK_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN,x');
end;

function LDA_STACK_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+STACKWIDTH,x');
end;

function LDA_STACK_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+STACKWIDTH*2,x');
end;

function LDA_STACK_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+STACKWIDTH*3,x');
end;

function STA_STACK_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN,x');
end;

function STA_STACK_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH,x');
end;

function STA_STACK_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH*2,x');
end;

function STA_STACK_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH*3,x');
end;

function CMP_STACK_NEXT_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+1,x');
end;

function CMP_STACK_PREV_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN-1,x');
end;

function CMP_STACK_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN,x');
end;

function CMP_STACK_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+STACKWIDTH,x');
end;

function CMP_STACK_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+STACKWIDTH*2,x');
end;

function CMP_STACK_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+STACKWIDTH*3,x');
end;

function LDA_STACK_PREV_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1,x');
end;

function LDA_STACK_PREV_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1+STACKWIDTH,x');
end;

function LDA_STACK_PREV_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
end;

function LDA_STACK_PREV_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
end;

function STA_STACK_PREV_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1,x');
end;

function STA_STACK_PREV_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1+STACKWIDTH,x');
end;

function STA_STACK_PREV_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
end;

function STA_STACK_PREV_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
end;

function LDA_STACK_NEXT_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1,x');
end;

function LDA_STACK_NEXT_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1+STACKWIDTH,x');
end;

function LDA_STACK_NEXT_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1+STACKWIDTH*2,x');
end;

function LDA_STACK_NEXT_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1+STACKWIDTH*3,x');
end;

function STA_STACK_NEXT_0X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1,x');
end;

function STA_STACK_NEXT_1X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1+STACKWIDTH,x');
end;

function STA_STACK_NEXT_2X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1+STACKWIDTH*2,x');
end;

function STA_STACK_NEXT_3X(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1+STACKWIDTH*3,x');
end;

// -----------------------------------------------------------------------------


function STACK_PREV_0X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1,x', listing[i]) > 0;
end;

function STACK_PREV_1X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1+STACKWIDTH,x', listing[i]) > 0;
end;

function STACK_PREV_2X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1+STACKWIDTH*2,x', listing[i]) > 0;
end;

function STACK_PREV_3X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1+STACKWIDTH*3,x', listing[i]) > 0;
end;

function STACK_NEXT_0X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1,x', listing[i]) > 0;
end;

function STACK_NEXT_1X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1+STACKWIDTH,x', listing[i]) > 0;
end;

function STACK_NEXT_2X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1+STACKWIDTH*2,x', listing[i]) > 0;
end;

function STACK_NEXT_3X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1+STACKWIDTH*3,x', listing[i]) > 0;
end;

function STACK_0X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN,x', listing[i]) > 0;
end;

function STACK_1X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+STACKWIDTH,x', listing[i]) > 0;
end;

function STACK_2X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+STACKWIDTH*2,x', listing[i]) > 0;
end;

function STACK_3X(i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+STACKWIDTH*3,x', listing[i]) > 0;
end;

function STACK(i: Integer): Boolean;
begin
  Result := pos(' :STACK', listing[i]) > 0;
end;

function EAX(i: Integer): Boolean;
begin
  Result := pos(' :eax', listing[i]) > 0;
end;

function Data(i: Integer): Boolean;
begin
  Result := pos('-DATAORIGIN', listing[i]) > 0;
end;

function IX(i: Integer): Boolean;
begin
  Result := pos(',x', listing[i]) > 0;
end;

function IY(i: Integer): Boolean;
begin
  Result := pos(',y', listing[i]) > 0;
end;

// -----------------------------------------------------------------------------

function STA_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta #$00';
end;

function STY_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty #$00';
end;

function INC_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'inc #$00';
end;

function DEC_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'dec #$00';
end;

function ROL_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'rol #$00';
end;

function ASL_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'asl #$00';
end;

function ROR_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'ror #$00';
end;

function LSR_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lsr #$00';
end;

function JSR_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'jsr #$00';
end;

// -----------------------------------------------------------------------------

function LDA_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda #$00';
end;

function LDY_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'ldy #$00';
end;

function CMP_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'cmp #$00';
end;

function ADD_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'add #$00';
end;

function SUB_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub #$00';
end;

function ADD_IM_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'add #$01';
end;

function SUB_IM_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub #$01';
end;

function ADC_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc #$00';
end;

function SBC_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc #$00';
end;

function ADC_SBC_IM_0(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'adc #$00') or (listing[i] = #9'sbc #$00');
end;

function AND_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'and #$00';
end;

function ORA_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'ora #$00';
end;

function EOR_IM_0(i: Integer): Boolean;
begin
  Result := listing[i] = #9'eor #$00';
end;

function MVA_IM_0(i: Integer): Boolean;
begin
  Result := pos(#9'mva #$00', listing[i]) = 1;
end;

// -----------------------------------------------------------------------------

function LDA_L_ADR(i: Integer): Boolean;
begin
  Result := pos(#9'lda <adr.', listing[i]) = 1;
end;

function LDA_H_ADR(i: Integer): Boolean;
begin
  Result := pos(#9'lda >adr.', listing[i]) = 1;
end;

function LDA_L(i: Integer): Boolean;
begin
  Result := pos(#9'lda <', listing[i]) = 1;
end;

function LDA_H(i: Integer): Boolean;
begin
  Result := pos(#9'lda >', listing[i]) = 1;
end;

function LDY_L(i: Integer): Boolean;
begin
  Result := pos(#9'ldy <', listing[i]) = 1;
end;

function LDY_H(i: Integer): Boolean;
begin
  Result := pos(#9'ldy >', listing[i]) = 1;
end;

// -----------------------------------------------------------------------------

function LDA_IM(i: Integer): Boolean;
begin
  Result := pos(#9'lda #', listing[i]) = 1;
end;

function LDY_IM(i: Integer): Boolean;
begin
  Result := pos(#9'ldy #', listing[i]) = 1;
end;

function CMP_IM(i: Integer): Boolean;
begin
  Result := pos(#9'cmp #', listing[i]) = 1;
end;

function ADD_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'add #', listing[i]) = 1);
end;

function ADC_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'adc #', listing[i]) = 1);
end;

function SUB_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'sub #', listing[i]) = 1);
end;

function SBC_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'sbc #', listing[i]) = 1);
end;

function ADD_SUB_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'add #', listing[i]) = 1) or (pos(#9'sub #', listing[i]) = 1);
end;

function ADC_SBC_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'adc #', listing[i]) = 1) or (pos(#9'sbc #', listing[i]) = 1);
end;

function AND_IM(i: Integer): Boolean;
begin
  Result := pos(#9'and #', listing[i]) = 1;
end;

function AND_ORA_EOR_IM(i: Integer): Boolean;
begin
  Result := (pos(#9'and #', listing[i]) = 1) or (pos(#9'ora #', listing[i]) = 1) or
    (pos(#9'eor #', listing[i]) = 1);
end;

function MVA_IM(i: Integer): Boolean;
begin
  Result := pos(#9'mva #', listing[i]) = 1;
end;

function MVY_IM(i: Integer): Boolean;
begin
  Result := pos(#9'mvy #', listing[i]) = 1;
end;

// -----------------------------------------------------------------------------

function JSR(i: Integer): Boolean;
begin
  Result := (pos(#9'jsr ', listing[i]) = 1);
end;

function JMP(i: Integer): Boolean;
begin
  Result := (pos(#9'jmp l_', listing[i]) = 1);
end;

function LAB_L(i: Integer): Boolean;
begin
  Result := (pos('l_', listing[i]) = 1);
end;

function LAB_B(i: Integer): Boolean;
begin
  Result := (pos('b_', listing[i]) = 1);
end;

function LAB_C(i: Integer): Boolean;
begin
  Result := (pos('c_', listing[i]) = 1);
end;

function LAB_A(i: Integer): Boolean;
begin
  Result := (listing[i] = '@');
end;

// -----------------------------------------------------------------------------

function BP(i: Integer): Boolean;
begin
  Result := pos(' :bp', listing[i]) > 0;
end;

function BP_Y(i: Integer): Boolean;
begin
  Result := pos(' (:bp),y', listing[i]) > 0;
end;

function BP_1(i: Integer): Boolean;
begin
  Result := pos(' :bp+1', listing[i]) > 0;
end;

function LDA_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda (:bp),y';
end;

function STA_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta (:bp),y';
end;

function STA_BP(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp';
end;

function STA_BP_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp+1';
end;

function INC_BP_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'inc :bp+1';
end;

function STY_BP_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :bp+1';
end;

function AND_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'and (:bp),y';
end;

function ORA_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'ora (:bp),y';
end;

function EOR_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'eor (:bp),y';
end;

function CMP_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'cmp (:bp),y';
end;

function ADD_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'add (:bp),y';
end;

function SUB_BP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub (:bp),y';
end;

// -----------------------------------------------------------------------------

function BP2_Y(i: Integer): Boolean;
begin
  Result := pos(' (:bp2),y', listing[i]) > 0;
end;

function BP2(i: Integer): Boolean;
begin
  Result := pos(' :bp2', listing[i]) > 0;
end;

function LDA_BP2(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :bp2';
end;

function LDA_BP2_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :bp2+1';
end;

function LDA_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda (:bp2),y';
end;

function STA_BP2(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp2';
end;

function STA_BP2_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp2+1';
end;

function STY_BP2_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :bp2+1';
end;

function STA_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta (:bp2),y';
end;

function INC_BP2_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'inc :bp2+1';
end;

function CMP_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'cmp (:bp2),y';
end;

function ADD_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'add (:bp2),y';
end;

function SUB_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub (:bp2),y';
end;

function ADC_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc (:bp2),y';
end;

function SBC_BP2_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc (:bp2),y';
end;

function ADD_SUB_BP2_Y(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'add (:bp2),y') or (listing[i] = #9'sub (:bp2),y');
end;

function ADC_SBC_BP2_Y(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'adc (:bp2),y') or (listing[i] = #9'sbc (:bp2),y');
end;

function AND_ORA_EOR_BP2_Y(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'and (:bp2),y') or (listing[i] = #9'ora (:bp2),y') or (listing[i] = #9'eor (:bp2),y');
end;

function MVA_BP2_Y(i: Integer): Boolean;
begin
  Result := (pos(#9'mva (:bp2),y', listing[i]) = 1);
end;

function MWY_BP2(i: Integer): Boolean;
begin
  Result := (pos(#9'mwy ', listing[i]) = 1) and (pos(' :bp2', listing[i]) > 0);
end;

// -----------------------------------------------------------------------------

function LDA_TMP_Y(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda (:TMP),y';
end;

function STA_TMP(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :TMP';
end;

function STA_TMP_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :TMP+1';
end;

function MWY_TMP(i: Integer): Boolean;
begin
  Result := (pos(#9'mwy ', listing[i]) = 1) and (pos(' :TMP', listing[i]) > 0);
end;

// -----------------------------------------------------------------------------

function TAY(i: Integer): Boolean;
begin
  Result := listing[i] = #9'tay';
end;

function TYA(i: Integer): Boolean;
begin
  Result := listing[i] = #9'tya';
end;

function INY(i: Integer): Boolean;
begin
  Result := listing[i] = #9'iny';
end;

function DEY(i: Integer): Boolean;
begin
  Result := listing[i] = #9'dey';
end;

function INX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'inx';
end;

function DEX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'dex';
end;

function ROR_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'ror @';
end;

function ROL_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'rol @';
end;

function LSR_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lsr @';
end;

function ASL_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'asl @';
end;

function LDY_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'ldy #1';
end;

// -----------------------------------------------------------------------------

function ROL_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'rol :eax+1';
end;

function LDA_EAX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax';
end;

function LDA_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax+1';
end;

function LDA_EAX_2(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax+2';
end;

function LDA_EAX_3(i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax+3';
end;

function STA_EAX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax';
end;

function STA_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax+1';
end;

function STA_EAX_2(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax+2';
end;

function STA_EAX_3(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax+3';
end;

function STY_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :eax+1';
end;

function STA_ECX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx';
end;

function STA_ECX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx+1';
end;

function STA_ECX_2(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx+2';
end;

function STA_ECX_3(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx+3';
end;

function STY_ECX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :ecx+1';
end;

function ADD_EAX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'add :eax';
end;

function ADD_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'add :eax+1';
end;

function ADC_EAX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc :eax';
end;

function ADC_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc :eax+1';
end;

function SUB_EAX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub :eax';
end;

function SUB_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub :eax+1';
end;

function SBC_EAX(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc :eax';
end;

function SBC_EAX_1(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc :eax+1';
end;

function ADD_SUB_EAX_ECX(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'jsr addEAX_ECX') or (listing[i] = #9'jsr subEAX_ECX');
end;

// -----------------------------------------------------------------------------

function LDA_EAX_X(i: Integer): Boolean;
begin
  Result := pos(#9'lda :eax', listing[i]) > 0;
end;

// -----------------------------------------------------------------------------

function LDA_VAL(i: Integer): Boolean;
begin
  Result := (pos(#9'lda ', listing[i]) = 1) and (pos(#9'lda :STACK', listing[i]) = 0);
end;

function STA_VAL(i: Integer): Boolean;
begin
  if listing[i] = #9'sta #$00' then exit(False);

  Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta :STACK', listing[i]) = 0);
end;

function LDY_VAL(i: Integer): Boolean;
begin
  Result := (pos(#9'ldy ', listing[i]) = 1) and (pos(#9'ldy :STACK', listing[i]) = 0);
end;

function CMP_VAL(i: Integer): Boolean;
begin
  Result := (pos(#9'cmp ', listing[i]) = 1) and (pos(#9'cmp :STACK', listing[i]) = 0);
end;

function ADD_SUB_VAL(i: Integer): Boolean;
begin
  Result := (pos(' :STACK', listing[i]) = 0) and ((pos(#9'add ', listing[i]) = 1) or
    (pos(#9'sub ', listing[i]) = 1));
end;

function ADC_SBC_VAL(i: Integer): Boolean;
begin
  Result := (pos(' :STACK', listing[i]) = 0) and ((pos(#9'adc ', listing[i]) = 1) or
    (pos(#9'sbc ', listing[i]) = 1));
end;

function ORA_VAL(i: Integer): Boolean;
begin
  Result := (pos(#9'ora ', listing[i]) = 1) and (pos(#9'ora :STACK', listing[i]) = 0);
end;

function AND_VAL(i: Integer): Boolean;
begin
  Result := (pos(#9'and ', listing[i]) = 1) and (pos(#9'and :STACK', listing[i]) = 0);
end;

function AND_ORA_EOR_VAL(i: Integer): Boolean;
begin
  Result := (pos(' :STACK', listing[i]) = 0) and ((pos(#9'and ', listing[i]) = 1) or
    (pos(#9'ora ', listing[i]) = 1) or (pos(#9'eor ', listing[i]) = 1));
end;

// -----------------------------------------------------------------------------

function LDA_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'lda :STACK', listing[i]) = 1;
end;

function STA_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'sta :STACK', listing[i]) = 1;
end;

function ADD_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'add :STACK', listing[i]) = 1);
end;

function ADC_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'adc :STACK', listing[i]) = 1);
end;

function SUB_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'sub :STACK', listing[i]) = 1);
end;

function SBC_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'sbc :STACK', listing[i]) = 1);
end;

function ADD_SUB_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'add :STACK', listing[i]) = 1) or (pos(#9'sub :STACK', listing[i]) = 1);
end;

function ADC_SBC_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'adc :STACK', listing[i]) = 1) or (pos(#9'sbc :STACK', listing[i]) = 1);
end;

function INC_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'inc :STACK', listing[i]) = 1);
end;

function DEC_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'dec :STACK', listing[i]) = 1);
end;

function LDY_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'ldy :STACK', listing[i]) = 1;
end;

function STY_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'sty :STACK', listing[i]) = 1;
end;

function CMP_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'cmp :STACK', listing[i]) = 1;
end;

function MVA_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'mva :STACK', listing[i]) = 1;
end;

function ROR_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'ror :STACK', listing[i]) = 1;
end;

function ROL_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'rol :STACK', listing[i]) = 1;
end;

function LSR_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'lsr :STACK', listing[i]) = 1;
end;

function ASL_STACK(i: Integer): Boolean;
begin
  Result := pos(#9'asl :STACK', listing[i]) = 1;
end;

function AND_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'and :STACK', listing[i]) = 1);
end;

function ORA_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'ora :STACK', listing[i]) = 1);
end;

function EOR_STACK(i: Integer): Boolean;
begin
  Result := (pos(#9'eor :STACK', listing[i]) = 1);
end;

function AND_ORA_EOR_STACK(i: Integer): Boolean;
begin
  Result := and_stack(i) or ora_stack(i) or eor_stack(i);
end;

// -----------------------------------------------------------------------------

function LDA(i: Integer): Boolean;
begin
  Result := (pos(#9'lda ', listing[i]) = 1) and (pos(#9'lda adr.', listing[i]) = 0) and
    (pos('.adr.', listing[i]) = 0);
end;

function LDA_A(i: Integer): Boolean;
begin
  Result := (pos(#9'lda ', listing[i]) = 1);
end;

function LDA_Y(i: Integer): Boolean;
begin
  Result := (pos(#9'lda ', listing[i]) = 1) and (pos(',y', listing[i]) > 0);
end;

function LDA_ADR_Y(i: Integer): Boolean;
begin
  if (pos(',y', listing[i]) > 0) then
    Result := (pos(#9'lda adr.', listing[i]) = 1) or ((pos(#9'lda ', listing[i]) = 1) and
      (pos('.adr.', listing[i]) > 0))
  else
    Result := False;
end;

function LDA_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'lda adr.', listing[i]) = 1) or ((pos(#9'lda ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function STA_ADR_Y(i: Integer): Boolean;
begin
  if (pos(',y', listing[i]) > 0) then
    Result := (pos(#9'sta adr.', listing[i]) = 1) or ((pos(#9'sta ', listing[i]) = 1) and
      (pos('.adr.', listing[i]) > 0))
  else
    Result := False;
end;

function STA_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'sta adr.', listing[i]) = 1) or ((pos(#9'sta ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function STA(i: Integer): Boolean;
begin
  if listing[i] = #9'sta #$00' then exit(False);

  Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta adr.', listing[i]) = 0) and
    (pos('.adr.', listing[i]) = 0);
end;

function STA_A(i: Integer): Boolean;
begin
  if listing[i] = #9'sta #$00' then exit(False);

  Result := (pos(#9'sta ', listing[i]) = 1);
end;

function LDY(i: Integer): Boolean;
begin
  Result := pos(#9'ldy ', listing[i]) = 1;
end;

function STY(i: Integer): Boolean;
begin
  if listing[i] = #9'sty #$00' then exit(False);

  Result := pos(#9'sty ', listing[i]) = 1;
end;

function ROR(i: Integer): Boolean;
begin
  Result := pos(#9'ror ', listing[i]) = 1;
end;

function LSR(i: Integer): Boolean;
begin
  Result := pos(#9'lsr ', listing[i]) = 1;
end;

function ROL(i: Integer): Boolean;
begin
  Result := pos(#9'rol ', listing[i]) = 1;
end;

function ASL(i: Integer): Boolean;
begin
  Result := pos(#9'asl ', listing[i]) = 1;
end;

function CMP(i: Integer): Boolean;
begin
  Result := pos(#9'cmp ', listing[i]) = 1;
end;

function MVA(i: Integer): Boolean;
begin
  Result := pos(#9'mva ', listing[i]) = 1;
end;

function MWA(i: Integer): Boolean;
begin
  Result := pos(#9'mwa ', listing[i]) = 1;
end;

function MVY(i: Integer): Boolean;
begin
  Result := pos(#9'mvy ', listing[i]) = 1;
end;

function MWY(i: Integer): Boolean;
begin
  Result := pos(#9'mwy ', listing[i]) = 1;
end;

function MVA_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'mva adr.', listing[i]) = 1) or ((pos(#9'mva ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function MVA_ARG(i: Integer): Boolean;
begin
  Result := (pos(#9'mva ', listing[i]) = 1) and (pos(',y', listing[i]) = 0);
end;

function ORA(i: Integer): Boolean;
begin
  Result := pos(#9'ora ', listing[i]) = 1;
end;

function ADD_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'add adr.', listing[i]) = 1) or ((pos(#9'add ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function SUB_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'sub adr.', listing[i]) = 1) or ((pos(#9'sub ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function ADC_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'adc adr.', listing[i]) = 1) or ((pos(#9'adc ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function SBC_ADR(i: Integer): Boolean;
begin
  Result := (pos(#9'sbc adr.', listing[i]) = 1) or ((pos(#9'sbc ', listing[i]) = 1) and
    (pos('.adr.', listing[i]) > 0));
end;

function INC_(i: Integer): Boolean;
begin
  if listing[i] = #9'inc #$00' then exit(False);

  Result := (pos(#9'inc ', listing[i]) = 1);
end;

function DEC_(i: Integer): Boolean;
begin
  if listing[i] = #9'dec #$00' then exit(False);

  Result := (pos(#9'dec ', listing[i]) = 1);
end;

function ADD(i: Integer): Boolean;
begin
  Result := (pos(#9'add ', listing[i]) = 1);
end;

function ADC(i: Integer): Boolean;
begin
  Result := (pos(#9'adc ', listing[i]) = 1);
end;

function SUB(i: Integer): Boolean;
begin
  Result := (pos(#9'sub ', listing[i]) = 1);
end;

function SBC(i: Integer): Boolean;
begin
  Result := (pos(#9'sbc ', listing[i]) = 1);
end;

function ADD_SUB(i: Integer): Boolean;
begin
  Result := (pos(#9'add ', listing[i]) = 1) or (pos(#9'sub ', listing[i]) = 1);
end;

function ADC_SBC(i: Integer): Boolean;
begin
  Result := (pos(#9'adc ', listing[i]) = 1) or (pos(#9'sbc ', listing[i]) = 1);
end;

function EOR(i: Integer): Boolean;
begin
  Result := (pos(#9'eor ', listing[i]) = 1);
end;

function AND_(i: Integer): Boolean;
begin
  Result := (pos(#9'and ', listing[i]) = 1);
end;

function AND_ORA_EOR(i: Integer): Boolean;
begin
  Result := (pos(#9'and ', listing[i]) = 1) or (pos(#9'ora ', listing[i]) = 1) or (pos(#9'eor ', listing[i]) = 1);
end;

// -----------------------------------------------------------------------------

function ADD_SUB_AL_CL(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'jsr addAL_CL') or (listing[i] = #9'jsr subAL_CL');
end;

function ADD_SUB_AX_CX(i: Integer): Boolean;
begin
  Result := (listing[i] = #9'jsr addAX_CX') or (listing[i] = #9'jsr subAX_CX');
end;

// -----------------------------------------------------------------------------

function JEQ(i: Integer): Boolean;
begin
  Result := pos(#9'jeq ', listing[i]) = 1;
end;

function JNE(i: Integer): Boolean;
begin
  Result := pos(#9'jne ', listing[i]) = 1;
end;

function JPL(i: Integer): Boolean;
begin
  Result := pos(#9'jpl ', listing[i]) = 1;
end;

function JMI(i: Integer): Boolean;
begin
  Result := pos(#9'jmi ', listing[i]) = 1;
end;

function JCC(i: Integer): Boolean;
begin
  Result := pos(#9'jcc ', listing[i]) = 1;
end;

function JCS(i: Integer): Boolean;
begin
  Result := pos(#9'jcs ', listing[i]) = 1;
end;

// -----------------------------------------------------------------------------

function BEQ(i: Integer): Boolean;
begin
  Result := pos(#9'beq ', listing[i]) = 1;
end;

function BNE(i: Integer): Boolean;
begin
  Result := pos(#9'bne ', listing[i]) = 1;
end;

function BCC(i: Integer): Boolean;
begin
  Result := pos(#9'bcc ', listing[i]) = 1;
end;

function BCS(i: Integer): Boolean;
begin
  Result := pos(#9'bcs ', listing[i]) = 1;
end;

function BPL(i: Integer): Boolean;
begin
  Result := pos(#9'bpl ', listing[i]) = 1;
end;

function BMI(i: Integer): Boolean;
begin
  Result := pos(#9'bmi ', listing[i]) = 1;
end;

// -----------------------------------------------------------------------------

function SVC(i: Integer): Boolean;
begin
  Result := listing[i] = #9'svc';
end;

function BNE_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'bne @+';
end;

function BEQ_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'beq @+';
end;

function BCC_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'bcc @+';
end;

function BCS_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'bcs @+';
end;

function BPL_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'bpl @+';
end;

function BMI_A(i: Integer): Boolean;
begin
  Result := listing[i] = #9'bmi @+';
end;

// -----------------------------------------------------------------------------

function SEQ(i: Integer): Boolean;
begin
  Result := listing[i] = #9'seq';
end;

function SNE(i: Integer): Boolean;
begin
  Result := listing[i] = #9'sne';
end;

function SPL(i: Integer): Boolean;
begin
  Result := listing[i] = #9'spl';
end;

function SMI(i: Integer): Boolean;
begin
  Result := listing[i] = #9'smi';
end;

function SCC(i: Integer): Boolean;
begin
  Result := listing[i] = #9'scc';
end;

function SCS(i: Integer): Boolean;
begin
  Result := listing[i] = #9'scs';
end;
