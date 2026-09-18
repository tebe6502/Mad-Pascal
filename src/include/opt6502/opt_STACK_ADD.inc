
function opt_STACK_ADD(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      STACK ADD.
// -----------------------------------------------------------------------------

    if lda_a(i) and										// lda					; 0
       add_sub(i+1) and 									// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and 										// lda					; 3
       adc_sbc(i+4) and 									// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       sta_val(i+7) and										// sta					; 7	~:STACKORIGIN
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH		; 8
       sta_val(i+9) then									// sta					; 9	~:STACKORIGIN
     if argMatch(i+2, i+6) and
        argMatch(i+5, i+8) then
     begin
       listing[i+2] := listing[i+7];

       listing[i+5] := listing[i+9];
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN,x			; 0
       (add_im_1(i+1) or sub_im_1(i+1)) and							// add|sub #$01				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN,x			; 2
       (inx(i+3) or dex(i+3)) then								// inx|dex				; 3
    if argMatch(i, i+2) then
     begin

       if add_im_1(i+1) then
        listing[i+1] := #9'inc ' + GetARG(i)
       else
        listing[i+1] := #9'dec ' + GetARG(i);

       listing[i] := '';

       listing[i+2] := '';

       exit(false);
     end;


    if lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       (add_im_1(i+1) or sub_im_1(i+1)) and							// add|sub #$01				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN,x			; 2
       (inx(i+3) or dex(i+3)) and								// inx|dex				; 3
       (inx(i+4) = false) and (dex(i+4) = false) then						//~inx|dex				; 4
     begin

       if add_im_1(i+1) then
        listing[i+1] := #9'iny'
       else
        listing[i+1] := #9'dey';

       listing[i] := #9'ldy ' + GetARG(i);

       listing[i+2] := #9'sty ' + GetARG(i+2);

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       add_sub_val(i+2) and									// add|sub				; 2	~:STACKORIGIN
       ldy_stack_prev_0x(i+3) and								// ldy :STACKORIGIN-1,x			; 3
       sta_val(i+4) and										// sta					; 4	~:STACKORIGIN
       dex(i+5) then										// dex					; 5
     begin
       listing[i+3] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       add_sub_val(i+2) and									// add|sub				; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';
       listing[i+4] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda_val(i+1) and (iy(i+1) = false) and							// lda IMAGES				; 1
       add_im_1(i+2) and									// add #$01				; 2
       tay(i+3) then										// tay					; 3
     begin
       listing[i+1] := #9'ldy ' + GetARG(i+1);
       listing[i+2] := #9'iny';
       listing[i+3] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda(i+1) and 										// lda IMAGES				; 1
       add_im_0(i+2) and									// add #$00				; 2
       sta(i+3) and										// sta					; 3
       lda(i+4) and										// lda IMAGES+1				; 4
       adc(i+5) and										// adc 					; 5
       sta(i+6) then										// sta					; 6
     begin
       listing[i+2] := '';

       listing[i+5] := #9'add ' + GetARG(i+5);

        exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda_im_0(i+1) and 									// lda #$00				; 1
       add(i+2) and										// add					; 2
       sta(i+3) and										// sta					; 3
       lda(i+4) and										// lda IMAGES+1				; 4
       adc(i+5) and										// adc 					; 5
       sta(i+6) then										// sta					; 6
     begin
       listing[i+1] := '';
       listing[i+2] := #9'lda ' + GetARG(i+2);

       listing[i+5] := #9'add ' + GetARG(i+5);

        exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda_a(i+1) and 										// lda IMAGES				; 1
       add_im_0(i+2) and									// add #$00				; 2
       sta_a(i+3) and										// sta					; 3
       (iny(i+4) = false) and									//~iny					; 4
       (adc(i+5) = false) then									//~adc 					; 5
     begin
       listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva ... :STACKORIGIN			; 1
       mva(i+2) and										// mva ... :STACKORIGIN+STACKWIDTH	; 2
       lda_val(i+3) and (lda_im(i+3) = false) and						// lda TB				; 3	~#
       add_stack(i+4) and									// add :STACKORIGIN			; 4
       tay(i+5) and										// tay					; 5
       (listing[i+6] = listing[i+3] + '+1') and							// lda TB+1				; 6	~#
       adc_stack(i+7) and									// adc :STACKORIGIN+STACKWIDTH		; 7
       sta_bp_1(i+8) and									// sta :bp+1				; 8
       lda_bp_y(i+9) and									// lda (:bp),y				; 9
       sta(i+10) then										// sta					; 10
     if stack_0x(i+1) and
	stack_0x(i+4) and
	stack_1x(i+2) and
	stack_1x(i+7) then
     begin
       listing[i+4]  := #9'add ' + GetString(i+1);
       listing[i+7]  := #9'adc ' + GetString(i+2);

       listing[i+1] := '';
       listing[i+2] := '';

       if adc_im_0(i+7) then
	if GetARG(i+3) + '+1' = GetARG(i+6) then begin
	 listing[i+3] := #9'mwy ' + GetARG(i+3) + ' :bp2';
	 listing[i+4] := #9'ldy ' + GetARG(i+4);
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda (:bp2),y';
	end;

       exit(false);
     end;


    if mva(i) and										// mva .. :STACKORIGIN,x		; 0
       mva(i+1) and 										// mva .. :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva .. :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and 										// mva .. :STACKORIGIN+STACKWIDTH*3,x	; 3
       lda_val(i+4) and										// lda					; 4
       add_sub_stack(i+5) and									// add|sub				; 5
       sta_a(i+6) and										// sta					; 6
       lda_val(i+7) and										// lda					; 7
       adc_sbc_stack(i+8) and 									// adc|sbc				; 8
       sta_a(i+9) and										// sta					; 9
       lda_val(i+10) and									// lda					; 10
       adc_sbc_stack(i+11) and 									// adc|sbc				; 11
       sta_a(i+12) and										// sta					; 12
       lda_val(i+13) and									// lda					; 13
       adc_sbc_stack(i+14) and 									// adc|sbc				; 14
       sta_a(i+15) then										// sta					; 15
     if stack_0x(i) and
	stack_1x(i+1) and
	stack_2x(i+2) and
	stack_3x(i+3) and
        stack_0x(i+5) and
	stack_1x(i+8) and
	stack_2x(i+11) and
	stack_3x(i+14) then
     begin

        if add(i+5) then begin
          listing[i+5] := #9'add ' +  GetString(i);
          listing[i+8] := #9'adc ' +  GetString(i+1);
          listing[i+11]:= #9'adc ' +  GetString(i+2);
          listing[i+14]:= #9'adc ' +  GetString(i+3);
	end else begin
          listing[i+5] := #9'sub ' +  GetString(i);
          listing[i+8] := #9'sbc ' +  GetString(i+1);
          listing[i+11]:= #9'sbc ' +  GetString(i+2);
          listing[i+14]:= #9'sbc ' +  GetString(i+3);
	end;

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if mva(i) and										// mva .. :STACKORIGIN,x		; 0
       mva(i+1) and										// mva .. :STACKORIGIN+STACKWIDTH,x	; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       add_sub_stack(i+3) and 									// add|sub :STACKORIGIN,x		; 3
       sta_a(i+4) and										// sta					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       adc_sbc_stack(i+6) and 									// adc|sbc :STACKORIGIN+STACKWIDTH,x	; 6
       sta_a(i+7) then										// sta					; 7
     if stack_0x(i) and
        stack_1x(i+1) and
        stack_0x(i+3) and
        stack_1x(i+6) then
      begin

       if add(i+3) then begin
        listing[i+3] := #9'add ' + GetSTRING(i);
        listing[i+6] := #9'adc ' + GetSTRING(i+1);
       end else begin
        listing[i+3] := #9'sub ' + GetSTRING(i);
        listing[i+6] := #9'sbc ' + GetSTRING(i+1);
       end;

       listing[i]  := '';
       listing[i+1]:= '';

       exit(false);
      end;


    if ldy_stack(i+7) and 									// ldy :STACKORIGIN,x			; 7

       mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       lda_bp2(i+1) and										// lda :bp2				; 1
       add_im(i+2) and DATA(i+2) and								// add #CONTEXT.STATE-DATAORIGIN	; 2
       sta_bp2(i+3) and										// sta :bp2				; 3
       lda_bp2_1(i+4) and									// lda :bp2+1				; 4
       adc_im_0(i+5) and									// adc #$00				; 5
       sta_bp2_1(i+6) then									// sta :bp2+1				; 6
//       ldy_stack(i+7) then 									// ldy :STACKORIGIN,x			; 7
     begin

      for p:=i-1 downto 0 do
       if inx(p) and
          stack_0x(p+1) and mva_im(p+1) and
	  stack_1x(p+2) and (mva(p+2) or sta(p+2)) then
	begin
       	 listing[i+7] := #9'ldy ' + GetARG(i+2) + '+' + Hex(GetBYTE(p+1), 2);

       	 listing[p+1] := '';
	 listing[p+2] := '';

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';

	 exit(false);
	end;

       if Result then begin
	listing[i+1] := #9'ldy ' + GetString(i) + '+1';

	listing[i] := #9'lda ' + GetString(i);

	listing[i+4] := #9'scc';
	listing[i+5] := #9'iny';
	listing[i+6] := #9'sty :bp2+1';

	exit(false);
       end;

     end;


    if ldy_stack(i+6) and									// ldy :STACKORIGIN,x			; 6

       lda_a(i) and										// lda					; 0
       add_sub_val(i+1) and									// add|sub				; 1	~:STACKORIGIN
       sta_stack(i+2) and									// sta :STACKORIGIN,x			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_a(i+5) and										// sta :STACKORIGIN+STACKWIDTH,x	; 5
//       ldy_stack(i+6) and									// ldy :STACKORIGIN,x			; 6
       (SKIP(i+7) = false) then									//~SKIP					; 7
     if argMatch(i+2, i+6) then
     begin
       listing[i+2] := #9'tay';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


end;		// function
