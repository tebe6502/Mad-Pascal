// Optimized version of "StartsWith"
// Assumption is that "str" is always at least 4 chars, e.g. '#9abc'
function pos1(const str: String; const i: Integer): Boolean;
begin
  if (Length(str) > Length(listing[i])) // Compare lengths
    or (str[2] <> listing[i][2])  // Compare first regular letter first
    or (str[3] <> listing[i][3])  // ...
    or (str[4] <> listing[i][4])  // ...
    or (str[1] <> listing[i][1])  // Compare the typical #9 last
  then exit(False);
  Result := pos(str, listing[i]) = 1;  // Compare the rest
end;

// Check for 2 character label prefix
function pos1_lab(const str: String; const i: Integer): Boolean;
begin
  if (Length(str) > Length(listing[i])) // Compare lengths
    or (str[1] <> listing[i][1])  // Compare first regular character
    or (str[2] <> listing[i][2])  // Compare second regular character
  then exit(False);
  Result := True;
end;

// -----------------------------------------------------------------------------

function LOCAL(const i: Integer): Boolean;
begin

  if (i < 0) {or (listing[i] = '')} then
    Result := False
  else
    Result := (listing[i] = #9'.LOCAL');

end;

function ENDL(const i: Integer): Boolean;
begin

  if (i < 0) {or (listing[i] = '')} then
    Result := False
  else
    Result := (listing[i] = #9'.ENDL');

end;

function _FOR(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'#for')
end;

function _IF(const i: Integer): Boolean;
begin
  Result := pos1(#9'.if', i)
end;

function EIF(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'eif')
end;

function STA_PARAM(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta @PARAM?');
end;

// -----------------------------------------------------------------------------

function LDA_ZTMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda :ztmp', i);
end;

function STA_ZTMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'sta :ztmp', i);
end;

function STY_ZTMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'sty :ztmp', i);
end;

function SUB_ZTMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'sub :ztmp', i);
end;

// -----------------------------------------------------------------------------

function ASL_STACK_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'asl :STACKORIGIN,x');
end;

function LDY_STACK_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN,x');
end;

function LDY_STACK_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN+STACKWIDTH,x');
end;

function STY_STACK_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sty :STACKORIGIN,x');
end;

function LDY_STACK_PREV_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN-1,x');
end;

function STY_STACK_PREV_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sty :STACKORIGIN-1,x');
end;

function LDY_STACK_NEXT_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'ldy :STACKORIGIN+1,x');
end;

function STY_STACK_NEXT_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sty :STACKORIGIN+1,x');
end;

function LDA_STACK_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN,x');
end;

function LDA_STACK_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+STACKWIDTH,x');
end;

function LDA_STACK_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+STACKWIDTH*2,x');
end;

function LDA_STACK_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+STACKWIDTH*3,x');
end;

function STA_STACK_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN,x');
end;

function STA_STACK_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH,x');
end;

function STA_STACK_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH*2,x');
end;

function STA_STACK_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH*3,x');
end;

function CMP_STACK_NEXT_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+1,x');
end;

function CMP_STACK_PREV_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN-1,x');
end;

function CMP_STACK_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN,x');
end;

function CMP_STACK_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+STACKWIDTH,x');
end;

function CMP_STACK_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+STACKWIDTH*2,x');
end;

function CMP_STACK_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'cmp :STACKORIGIN+STACKWIDTH*3,x');
end;

function LDA_STACK_PREV_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1,x');
end;

function LDA_STACK_PREV_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1+STACKWIDTH,x');
end;

function LDA_STACK_PREV_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x');
end;

function LDA_STACK_PREV_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x');
end;

function STA_STACK_PREV_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1,x');
end;

function STA_STACK_PREV_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1+STACKWIDTH,x');
end;

function STA_STACK_PREV_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x');
end;

function STA_STACK_PREV_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x');
end;

function LDA_STACK_NEXT_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1,x');
end;

function LDA_STACK_NEXT_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1+STACKWIDTH,x');
end;

function LDA_STACK_NEXT_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1+STACKWIDTH*2,x');
end;

function LDA_STACK_NEXT_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'lda :STACKORIGIN+1+STACKWIDTH*3,x');
end;

function STA_STACK_NEXT_0X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1,x');
end;

function STA_STACK_NEXT_1X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1+STACKWIDTH,x');
end;

function STA_STACK_NEXT_2X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1+STACKWIDTH*2,x');
end;

function STA_STACK_NEXT_3X(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'sta :STACKORIGIN+1+STACKWIDTH*3,x');
end;

// -----------------------------------------------------------------------------


function STACK_PREV_0X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1,x', listing[i]) > 0;
end;

function STACK_PREV_1X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1+STACKWIDTH,x', listing[i]) > 0;
end;

function STACK_PREV_2X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1+STACKWIDTH*2,x', listing[i]) > 0;
end;

function STACK_PREV_3X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN-1+STACKWIDTH*3,x', listing[i]) > 0;
end;

function STACK_NEXT_0X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1,x', listing[i]) > 0;
end;

function STACK_NEXT_1X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1+STACKWIDTH,x', listing[i]) > 0;
end;

function STACK_NEXT_2X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1+STACKWIDTH*2,x', listing[i]) > 0;
end;

function STACK_NEXT_3X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+1+STACKWIDTH*3,x', listing[i]) > 0;
end;

function STACK_0X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN,x', listing[i]) > 0;
end;

function STACK_1X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+STACKWIDTH,x', listing[i]) > 0;
end;

function STACK_2X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+STACKWIDTH*2,x', listing[i]) > 0;
end;

function STACK_3X(const i: Integer): Boolean;
begin
  Result := pos(' :STACKORIGIN+STACKWIDTH*3,x', listing[i]) > 0;
end;

function STACK(const i: Integer): Boolean;
begin
  Result := pos(' :STACK', listing[i]) > 0;
end;

function EAX(const i: Integer): Boolean;
begin
  Result := pos(' :eax', listing[i]) > 0;
end;

function Data(const i: Integer): Boolean;
begin
  Result := pos('-DATAORIGIN', listing[i]) > 0;
end;

function IX(const i: Integer): Boolean;
begin
  Result := pos(',x', listing[i]) > 0;
end;

function IY(const i: Integer): Boolean;
begin
  Result := pos(',y', listing[i]) > 0;
end;

// -----------------------------------------------------------------------------

function STA_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta #$00';
end;

function STY_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty #$00';
end;

function INC_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'inc #$00';
end;

function DEC_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'dec #$00';
end;

function ROL_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'rol #$00';
end;

function ASL_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'asl #$00';
end;

function ROR_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'ror #$00';
end;

function LSR_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lsr #$00';
end;

function JSR_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'jsr #$00';
end;

// -----------------------------------------------------------------------------

function LDA_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda #$00';
end;

function LDY_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'ldy #$00';
end;

function CMP_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'cmp #$00';
end;

function ADD_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'add #$00';
end;

function SUB_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub #$00';
end;

function ADD_IM_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'add #$01';
end;

function SUB_IM_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub #$01';
end;

function ADC_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc #$00';
end;

function SBC_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc #$00';
end;

function ADC_SBC_IM_0(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'adc #$00') or (listing[i] = #9'sbc #$00');
end;

function AND_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'and #$00';
end;

function ORA_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'ora #$00';
end;

function EOR_IM_0(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'eor #$00';
end;

function MVA_IM_0(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva #$00', i);
end;

// -----------------------------------------------------------------------------

function LDA_L_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda <adr.', i);
end;

function LDA_H_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda >adr.', i);
end;

function LDA_L(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda <', i);
end;

function LDA_H(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda >', i);
end;

function LDY_L(const i: Integer): Boolean;
begin
  Result := pos1(#9'ldy <', i);
end;

function LDY_H(const i: Integer): Boolean;
begin
  Result := pos1(#9'ldy >', i);
end;

// -----------------------------------------------------------------------------

function LDA_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda #', i);
end;

function LDY_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'ldy #', i);
end;

function CMP_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'cmp #', i);
end;

function ADD_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'add #', i);
end;

function ADC_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc #', i);
end;

function SUB_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'sub #', i);
end;

function SBC_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'sbc #', i);
end;

function ADD_SUB_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'add #', i) or pos1(#9'sub #', i);
end;

function ADC_SBC_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc #', i) or pos1(#9'sbc #', i);
end;

function AND_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'and #', i);
end;

function AND_ORA_EOR_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'and #', i) or pos1(#9'ora #', i) or pos1(#9'eor #', i);
end;

function MVA_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva #', i);
end;

function MVY_IM(const i: Integer): Boolean;
begin
  Result := pos1(#9'mvy #', i);
end;

// -----------------------------------------------------------------------------

function JSR(const i: Integer): Boolean;
begin
  Result := pos1(#9'jsr ', i);
end;

function JMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'jmp l_', i);
end;

function LAB_L(const i: Integer): Boolean;
begin
  Result := pos1_lab('l_', i);
end;

function LAB_B(const i: Integer): Boolean;
begin
  Result := pos1_lab('b_', i);
end;

function LAB_C(const i: Integer): Boolean;
begin
  Result := pos1_lab('c_', i);
end;

function LAB_A(const i: Integer): Boolean;
begin
  Result := (listing[i] = '@');
end;

// -----------------------------------------------------------------------------

function BP(const i: Integer): Boolean;
begin
  Result := pos(' :bp', listing[i]) > 0;
end;

function BP_Y(const i: Integer): Boolean;
begin
  Result := pos(' (:bp),y', listing[i]) > 0;
end;

function BP_1(const i: Integer): Boolean;
begin
  Result := pos(' :bp+1', listing[i]) > 0;
end;

function LDA_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda (:bp),y';
end;

function STA_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta (:bp),y';
end;

function STA_BP(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp';
end;

function STA_BP_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp+1';
end;

function INC_BP_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'inc :bp+1';
end;

function STY_BP_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :bp+1';
end;

function AND_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'and (:bp),y';
end;

function ORA_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'ora (:bp),y';
end;

function EOR_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'eor (:bp),y';
end;

function CMP_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'cmp (:bp),y';
end;

function ADD_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'add (:bp),y';
end;

function SUB_BP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub (:bp),y';
end;

// -----------------------------------------------------------------------------

function BP2_Y(const i: Integer): Boolean;
begin
  Result := pos(' (:bp2),y', listing[i]) > 0;
end;

function BP2(const i: Integer): Boolean;
begin
  Result := pos(' :bp2', listing[i]) > 0;
end;

function LDA_BP2(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :bp2';
end;

function LDA_BP2_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :bp2+1';
end;

function LDA_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda (:bp2),y';
end;

function STA_BP2(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp2';
end;

function STA_BP2_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :bp2+1';
end;

function STY_BP2_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :bp2+1';
end;

function STA_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta (:bp2),y';
end;

function INC_BP2_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'inc :bp2+1';
end;

function CMP_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'cmp (:bp2),y';
end;

function ADD_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'add (:bp2),y';
end;

function SUB_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub (:bp2),y';
end;

function ADC_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc (:bp2),y';
end;

function SBC_BP2_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc (:bp2),y';
end;

function ADD_SUB_BP2_Y(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'add (:bp2),y') or (listing[i] = #9'sub (:bp2),y');
end;

function ADC_SBC_BP2_Y(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'adc (:bp2),y') or (listing[i] = #9'sbc (:bp2),y');
end;

function AND_ORA_EOR_BP2_Y(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'and (:bp2),y') or (listing[i] = #9'ora (:bp2),y') or (listing[i] = #9'eor (:bp2),y');
end;

function MVA_BP2_Y(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva (:bp2),y', i);
end;

function MWY_BP2(const i: Integer): Boolean;
begin
  Result := pos1(#9'mwy ', i) and (pos(' :bp2', listing[i]) > 0);
end;

// -----------------------------------------------------------------------------

function LDA_TMP_Y(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda (:TMP),y';
end;

function STA_TMP(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :TMP';
end;

function STA_TMP_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :TMP+1';
end;

function MWY_TMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'mwy ', i) and (pos(' :TMP', listing[i]) > 0);
end;

// -----------------------------------------------------------------------------

function TAY(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'tay';
end;

function TYA(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'tya';
end;

function INY(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'iny';
end;

function DEY(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'dey';
end;

function INX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'inx';
end;

function DEX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'dex';
end;

function ROR_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'ror @';
end;

function ROL_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'rol @';
end;

function LSR_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lsr @';
end;

function ASL_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'asl @';
end;

function LDY_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'ldy #1';
end;

// -----------------------------------------------------------------------------

function ROL_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'rol :eax+1';
end;

function LDA_EAX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax';
end;

function LDA_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax+1';
end;

function LDA_EAX_2(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax+2';
end;

function LDA_EAX_3(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'lda :eax+3';
end;

function STA_EAX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax';
end;

function STA_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax+1';
end;

function STA_EAX_2(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax+2';
end;

function STA_EAX_3(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :eax+3';
end;

function STY_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :eax+1';
end;

function STA_ECX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx';
end;

function STA_ECX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx+1';
end;

function STA_ECX_2(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx+2';
end;

function STA_ECX_3(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sta :ecx+3';
end;

function STY_ECX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sty :ecx+1';
end;

function ADD_EAX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'add :eax';
end;

function ADD_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'add :eax+1';
end;

function ADC_EAX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc :eax';
end;

function ADC_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'adc :eax+1';
end;

function SUB_EAX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub :eax';
end;

function SUB_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sub :eax+1';
end;

function SBC_EAX(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc :eax';
end;

function SBC_EAX_1(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sbc :eax+1';
end;

function ADD_SUB_EAX_ECX(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'jsr addEAX_ECX') or (listing[i] = #9'jsr subEAX_ECX');
end;

// -----------------------------------------------------------------------------

function LDA_EAX_X(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda :eax', i)
end;

// -----------------------------------------------------------------------------

function LDA_VAL(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda ', i) and (pos1(#9'lda :STACK', i) = false)
end;

function STA_VAL(const i: Integer): Boolean;
begin
  if listing[i] = #9'sta #$00' then exit(False);

  Result := pos1(#9'sta ', i) and (pos1(#9'sta :STACK', i) = false)
end;

function LDY_VAL(const i: Integer): Boolean;
begin
  Result := pos1(#9'ldy ', i) and (pos1(#9'ldy :STACK', i) = false)
end;

function CMP_VAL(const i: Integer): Boolean;
begin
  Result := pos1(#9'cmp ', i) and (pos1(#9'cmp :STACK', i) = false)
end;

function ADD_SUB_VAL(const i: Integer): Boolean;
begin
  Result := (pos(' :STACK', listing[i]) = 0) and (pos1(#9'add ', i) or pos1(#9'sub ', i));
end;

function ADC_SBC_VAL(const i: Integer): Boolean;
begin
  Result := (pos(' :STACK', listing[i]) = 0) and (pos1(#9'adc ', i) or pos1(#9'sbc ', i));
end;

function ORA_VAL(const i: Integer): Boolean;
begin
  Result := pos1(#9'ora ', i) and (pos1(#9'ora :STACK', i) = false)
end;

function AND_VAL(const i: Integer): Boolean;
begin
  Result := pos1(#9'and ', i) and (pos1(#9'and :STACK', i) = false)
end;

function AND_ORA_EOR_VAL(const i: Integer): Boolean;
begin
  Result := (pos(' :STACK', listing[i]) = 0) and (pos1(#9'and ', i) or pos1(#9'ora ', i) or pos1(#9'eor ', i));
end;

// -----------------------------------------------------------------------------

function LDA_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda :STACK', i);
end;

function STA_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'sta :STACK', i);
end;

function ADD_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'add :STACK', i);
end;

function ADC_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc :STACK', i);
end;

function SUB_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'sub :STACK', i);
end;

function SBC_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'sbc :STACK', i);
end;

function ADD_SUB_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'add :STACK', i) or pos1(#9'sub :STACK', i);
end;

function ADC_SBC_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc :STACK', i) or pos1(#9'sbc :STACK', i);
end;

function INC_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'inc :STACK', i);
end;

function DEC_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'dec :STACK', i);
end;

function LDY_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'ldy :STACK', i);
end;

function STY_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'sty :STACK', i);
end;

function CMP_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'cmp :STACK', i);
end;

function MVA_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva :STACK', i);
end;

function ROR_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'ror :STACK', i);
end;

function ROL_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'rol :STACK', i);
end;

function LSR_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'lsr :STACK', i);
end;

function ASL_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'asl :STACK', i);
end;

function AND_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'and :STACK', i);
end;

function ORA_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'ora :STACK', i);
end;

function EOR_STACK(const i: Integer): Boolean;
begin
  Result := pos1(#9'eor :STACK', i);
end;

function AND_ORA_EOR_STACK(const i: Integer): Boolean;
begin
  Result := and_stack(i) or ora_stack(i) or eor_stack(i);
end;

// -----------------------------------------------------------------------------

function LDA(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda ', i) and (pos1(#9'lda adr.', i) = false) and (pos('.adr.', listing[i]) = 0);
end;

function LDA_A(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda ', i);
end;

function LDA_Y(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda ', i) and (pos(',y', listing[i]) > 0);
end;

function LDA_ADR_Y(const i: Integer): Boolean;
begin
  if (pos(',y', listing[i]) > 0) then
    Result := pos1(#9'lda adr.', i) or (pos1(#9'lda ', i) and (pos('.adr.', listing[i]) > 0))
  else
    Result := False;
end;

function LDA_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'lda adr.', i) or (pos1(#9'lda ', i) and (pos('.adr.', listing[i]) > 0));
end;

function STA_ADR_Y(const i: Integer): Boolean;
begin
  if (pos(',y', listing[i]) > 0) then
    Result := pos1(#9'sta adr.', i) or (pos1(#9'sta ', i) and (pos('.adr.', listing[i]) > 0))
  else
    Result := False;
end;

function STA_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'sta adr.', i) or (pos1(#9'sta ', i) and (pos('.adr.', listing[i]) > 0));
end;

function STA(const i: Integer): Boolean;
begin
  if listing[i] = #9'sta #$00' then exit(False);

  Result := pos1(#9'sta ', i) and (pos1(#9'sta adr.', i) = false) and (pos('.adr.', listing[i]) = 0);
end;

function STA_A(const i: Integer): Boolean;
begin
  if listing[i] = #9'sta #$00' then exit(False);

  Result := pos1(#9'sta ', i);
end;

function LDY(const i: Integer): Boolean;
begin
  Result := pos1(#9'ldy ', i);
end;

function STY(const i: Integer): Boolean;
begin
  if listing[i] = #9'sty #$00' then exit(False);

  Result := pos1(#9'sty ', i);
end;

function ROR(const i: Integer): Boolean;
begin
  Result := pos1(#9'ror ', i);
end;

function LSR(const i: Integer): Boolean;
begin
  Result := pos1(#9'lsr ', i);
end;

function ROL(const i: Integer): Boolean;
begin
  Result := pos1(#9'rol ', i);
end;

function ASL(const i: Integer): Boolean;
begin
  Result := pos1(#9'asl ', i);
end;

function CMP(const i: Integer): Boolean;
begin
  Result := pos1(#9'cmp ', i);
end;

function MVA(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva ', i);
end;

function MWA(const i: Integer): Boolean;
begin
  Result := pos1(#9'mwa ', i);
end;

function MVY(const i: Integer): Boolean;
begin
  Result := pos1(#9'mvy ', i);
end;

function MWY(const i: Integer): Boolean;
begin
  Result := pos1(#9'mwy ', i);
end;

function MVA_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva adr.', i) or (pos1(#9'mva ', i) and (pos('.adr.', listing[i]) > 0));
end;

function MVA_ARG(const i: Integer): Boolean;
begin
  Result := pos1(#9'mva ', i) and (pos(',y', listing[i]) = 0);
end;

function ORA(const i: Integer): Boolean;
begin
  Result := pos1(#9'ora ', i);
end;

function ADD_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'add adr.', i) or (pos1(#9'add ', i) and (pos('.adr.', listing[i]) > 0));
end;

function SUB_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'sub adr.', i) or (pos1(#9'sub ', i) and (pos('.adr.', listing[i]) > 0));
end;

function ADC_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc adr.', i) or (pos1(#9'adc ', i) and (pos('.adr.', listing[i]) > 0));
end;

function SBC_ADR(const i: Integer): Boolean;
begin
  Result := pos1(#9'sbc adr.', i) or (pos1(#9'sbc ', i) and (pos('.adr.', listing[i]) > 0));
end;

function INC_(const i: Integer): Boolean;
begin
  if listing[i] = #9'inc #$00' then exit(False);

  Result := pos1(#9'inc ', i);
end;

function DEC_(const i: Integer): Boolean;
begin
  if listing[i] = #9'dec #$00' then exit(False);

  Result := pos1(#9'dec ', i);
end;

function ADD(const i: Integer): Boolean;
begin
  Result := pos1(#9'add ', i);
end;

function ADC(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc ', i);
end;

function SUB(const i: Integer): Boolean;
begin
  Result := pos1(#9'sub ', i);
end;

function SBC(const i: Integer): Boolean;
begin
  Result := pos1(#9'sbc ', i);
end;

function ADD_SUB(const i: Integer): Boolean;
begin
  Result := pos1(#9'add ', i) or pos1(#9'sub ', i);
end;

function ADC_SBC(const i: Integer): Boolean;
begin
  Result := pos1(#9'adc ', i) or pos1(#9'sbc ', i);
end;

function EOR(const i: Integer): Boolean;
begin
  Result := pos1(#9'eor ', i);
end;

function AND_(const i: Integer): Boolean;
begin
  Result := pos1(#9'and ', i);
end;

function AND_ORA_EOR(const i: Integer): Boolean;
begin
  Result := pos1(#9'and ', i) or pos1(#9'ora ', i) or pos1(#9'eor ', i);
end;

// -----------------------------------------------------------------------------

function ADD_SUB_AL_CL(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'jsr addAL_CL') or (listing[i] = #9'jsr subAL_CL');
end;

function ADD_SUB_AX_CX(const i: Integer): Boolean;
begin
  Result := (listing[i] = #9'jsr addAX_CX') or (listing[i] = #9'jsr subAX_CX');
end;

// -----------------------------------------------------------------------------

function JEQ(const i: Integer): Boolean;
begin
  Result := pos1(#9'jeq ', i);
end;

function JNE(const i: Integer): Boolean;
begin
  Result := pos1(#9'jne ', i);
end;

function JPL(const i: Integer): Boolean;
begin
  Result := pos1(#9'jpl ', i);
end;

function JMI(const i: Integer): Boolean;
begin
  Result := pos1(#9'jmi ', i);
end;

function JCC(const i: Integer): Boolean;
begin
  Result := pos1(#9'jcc ', i);
end;

function JCS(const i: Integer): Boolean;
begin
  Result := pos1(#9'jcs ', i);
end;

// -----------------------------------------------------------------------------

function BEQ(const i: Integer): Boolean;
begin
  Result := pos1(#9'beq ', i);
end;

function BNE(const i: Integer): Boolean;
begin
  Result := pos1(#9'bne ', i);
end;

function BCC(const i: Integer): Boolean;
begin
  Result := pos1(#9'bcc ', i);
end;

function BCS(const i: Integer): Boolean;
begin
  Result := pos1(#9'bcs ', i);
end;

function BPL(const i: Integer): Boolean;
begin
  Result := pos1(#9'bpl ', i);
end;

function BMI(const i: Integer): Boolean;
begin
  Result := pos1(#9'bmi ', i);
end;

// -----------------------------------------------------------------------------

function SVC(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'svc';
end;

function BNE_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'bne @+';
end;

function BEQ_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'beq @+';
end;

function BCC_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'bcc @+';
end;

function BCS_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'bcs @+';
end;

function BPL_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'bpl @+';
end;

function BMI_A(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'bmi @+';
end;

// -----------------------------------------------------------------------------

function SEQ(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'seq';
end;

function SNE(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'sne';
end;

function SPL(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'spl';
end;

function SMI(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'smi';
end;

function SCC(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'scc';
end;

function SCS(const i: Integer): Boolean;
begin
  Result := listing[i] = #9'scs';
end;
