
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
       sta_val(i+7) and										// sta ~:STACKORIGIN			; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH		; 8
       sta_val(i+9) then									// sta ~:STACKORIGIN			; 9
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
        listing[i+1] := #9'inc ' + copy(listing[i], 6, 256)
       else
        listing[i+1] := #9'dec ' + copy(listing[i], 6, 256);

       listing[i] := '';

       listing[i+2] := '';

       exit(false);
     end;


    if lda_val(i) and (iy(i) = false) and							// lda ~:STACKORIGIN			; 0
       (add_im_1(i+1) or sub_im_1(i+1)) and							// add|sub #$01				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN,x			; 2
       (inx(i+3) or dex(i+3)) and								// inx|dex				; 3
       (inx(i+4) = false) and (dex(i+4) = false) then						//~inx|dex				; 4
     begin

       if add_im_1(i+1) then
        listing[i+1] := #9'iny'
       else
        listing[i+1] := #9'dey';

       listing[i] := #9'ldy ' + copy(listing[i], 6, 256);

       listing[i+2] := #9'sty ' + copy(listing[i+2], 6, 256);

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda ~:STACKORIGIN			; 1
       add_sub_val(i+2) and									// add|sub ~:STACKORIGIN		; 2
       ldy_stack_prev_0x(i+3) and								// ldy :STACKORIGIN-1,x			; 3
       sta_val(i+4) and										// sta ~:STACKORIGIN			; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i+3] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda ~:STACKORIGIN			; 1
       add_sub_val(i+2) and									// add|sub ~:STACKORIGIN		; 2
       sta_val(i+3) and										// sta ~:STACKORIGIN			; 3
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
       listing[i+1] := #9'ldy ' + copy(listing[i+1], 6, 256);
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

       listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

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
       listing[i+2] := #9'lda ' + copy(listing[i+2], 6, 256);

       listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

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
       mva(i+1) and 										// mva aa :STACKORIGIN			; 1
       mva(i+2) and										// mva bb|#$00 :STACKORIGIN+STACKWIDTH	; 2
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
	if copy(listing[i+3], 6, 256) + '+1' = copy(listing[i+6], 6, 256) then begin
	 listing[i+3] := #9'mwy ' + copy(listing[i+3], 6, 256) + ' :bp2';
	 listing[i+4] := #9'ldy ' + copy(listing[i+4], 6, 256);
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda (:bp2),y';
	end;

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva aa :STACKORIGIN,x		; 1
       mva(i+2) and										// mva bb :STACKORIGIN+STACKWIDTH,x	; 2
       lda(i+3) and										// lda					; 3
       add_stack(i+4) and									// add :STACKORIGIN,x			; 4
       sta(i+5) and										// sta					; 5
       lda(i+6) and										// lda					; 6
       adc_stack(i+7) and									// adc :STACKORIGIN+STACKWIDTH,x	; 7
       sta(i+8) then										// sta					; 8
     if stack_0x(i+1) and
	stack_0x(i+4) and
	stack_1x(i+2) and
	stack_1x(i+7) then
     begin
       listing[i+4]  := #9'add ' + GetString(i+1);
       listing[i+7]  := #9'adc ' + GetString(i+2);

       listing[i+1] := '';
       listing[i+2] := '';

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
       	 listing[i+7] := #9'ldy ' + copy(listing[i+2], 6, 256) + '+' + HexByte(GetBYTE(p+1));

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
       add_sub_val(i+1) and									// add|sub ~:STACKORIGIN		; 1
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
