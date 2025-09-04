
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

   function STA_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp+1'
   end;

   function INC_BP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'inc :bp+1'
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

   function STA_TMP(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :TMP'
   end;

   function STA_TMP_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :TMP+1'
   end;

   function STA_BP2(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp2'
   end;

   function STA_BP2_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :bp2+1'
   end;

   function STA_BP2_(i: integer): Boolean;
   begin
     Result := (listing[i] = #9'sta :bp2') or (listing[i] = #9'sta :bp2+1')
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

   function SUB_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sub (:bp2),y'
   end;

   function ADC_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'adc (:bp2),y'
   end;

   function SBC_BP2_Y(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sbc (:bp2),y'
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

   function STA_ECX(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :ecx'
   end;

   function STA_ECX_1(i: integer): Boolean;
   begin
     Result := listing[i] = #9'sta :ecx+1'
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

   function LAB_A(i: integer): Boolean;
   begin
     Result := (listing[i] = '@')
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

   function LDY_VAL(i: integer): Boolean;
   begin
     Result := (pos(#9'ldy ', listing[i]) = 1) and (pos(#9'ldy :STACK', listing[i]) = 0);
   end;

   function STY(i: integer): Boolean;
   begin
     if listing[i] = #9'sty #$00' then exit(false);

     Result := pos(#9'sty ', listing[i]) = 1;
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

   function CMP_VAL(i: integer): Boolean;
   begin
     Result := (pos(#9'cmp ', listing[i]) = 1) and (pos(#9'cmp :STACK', listing[i]) = 0);
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

   function LDA_ADR_Y(i: integer): Boolean;
   begin
     if (pos(',y', listing[i]) > 0) then
      Result := (pos(#9'lda adr.', listing[i]) = 1) or ((pos(#9'lda ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0))
     else
      Result := false;
   end;

   function LDA_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'lda adr.', listing[i]) = 1) or ((pos(#9'lda ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function LDA(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1) and (pos(#9'lda adr.', listing[i]) = 0) and (pos('.adr.', listing[i]) = 0);
   end;

   function LDA_VAL(i: integer): Boolean;
   begin
     Result := (pos(#9'lda ', listing[i]) = 1) and (pos(#9'lda :STACK', listing[i]) = 0);
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

   function STA_ADR_Y(i: integer): Boolean;
   begin
     if (pos(',y', listing[i]) > 0) then
      Result := (pos(#9'sta adr.', listing[i]) = 1) or ((pos(#9'sta ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0))
     else
      Result := false;
   end;

   function STA_ADR(i: integer): Boolean;
   begin
     Result := (pos(#9'sta adr.', listing[i]) = 1) or ((pos(#9'sta ', listing[i]) = 1) and (pos('.adr.', listing[i]) > 0));
   end;

   function STA(i: integer): Boolean;
   begin
     if listing[i] = #9'sta #$00' then exit(false);

     Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta adr.', listing[i]) = 0) and (pos('.adr.', listing[i]) = 0);
   end;

   function STA_A(i: integer): Boolean;
   begin
     if listing[i] = #9'sta #$00' then exit(false);

     Result := (pos(#9'sta ', listing[i]) = 1);
   end;

   function STA_VAL(i: integer): Boolean;
   begin
     if listing[i] = #9'sta #$00' then exit(false);

     Result := (pos(#9'sta ', listing[i]) = 1) and (pos(#9'sta :STACK', listing[i]) = 0);
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

   function LAB_L(i: integer): Boolean;
   begin
     Result := (pos('l_', listing[i]) = 1);
   end;

   function LAB_B(i: integer): Boolean;
   begin
     Result := (pos('b_', listing[i]) = 1);
   end;

   function LAB_C(i: integer): Boolean;
   begin
     Result := (pos('c_', listing[i]) = 1);
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

   function AND_ORA_EOR_VAL(i: integer): Boolean;
   begin
     Result := ((pos(#9'and ', listing[i]) = 1) and (pos(#9'and :STACK', listing[i]) = 0)) or
               ((pos(#9'ora ', listing[i]) = 1) and (pos(#9'ora :STACK', listing[i]) = 0)) or
	       ((pos(#9'eor ', listing[i]) = 1) and (pos(#9'eor :STACK', listing[i]) = 0));
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


   function SVC(i: integer): Boolean;
   begin
     Result := listing[i] = #9'svc'
   end;

   function BNE_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bne @+'
   end;

   function BEQ_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'beq @+'
   end;

   function BCC_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bcc @+'
   end;

   function BCS_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bcs @+'
   end;

   function BPL_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bpl @+'
   end;

   function BMI_A(i: integer): Boolean;
   begin
     Result := listing[i] = #9'bmi @+'
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
