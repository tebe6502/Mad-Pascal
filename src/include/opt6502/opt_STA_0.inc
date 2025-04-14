
function opt_STA_0(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      STA #$00.
// -----------------------------------------------------------------------------

    if (listing[i] = #9'sta @PARAM?.@NIL') then							// sta @PARAM?.@NIL		; 0
      begin
	listing[i] := #9'sta #$00';

	exit(false);
      end;


    if (i=0) and sta_im_0(i) then begin								// sta #$00			; 0
       listing[i] := '';
       exit(false);
     end;


    if lab_a(i) and										//@				; 0
       sty_im_0(i+1) then									// sty #$00			; 1
      begin
       listing[i+1] := '';

       exit(false);
      end;


    if (iny(i) = false) and (dey(i) = false) and						//~iny|dey			; 0
       sty_im_0(i+1) and									// sty #$00			; 1
       (lda(i+2) or sta(i+2)) then								// lda|sta			; 2
      begin
       listing[i+1] := '';

       exit(false);
      end;


    if sty_stack(i) and										// sty :STACKORIGIN		; 0
       sty_im_0(i+1) then									// sty #$00			; 1
     begin
       listing[i+1] := '';
       exit(false);
     end;


    if tay(i) and										// tay				; 0
       sty_im_0(i+1) and									// sty #$00			; 1
       mva(i+2) then										// mva				; 2
     begin
       listing[i+1] := #9'lda ' + GetSTRING(i+2);
       listing[i+2] := #9'sta ' + GetSTRINGLast(i+2);
       exit(false);
     end;


    if lda_a(i) and										// lda				; 0
       sta_im_0(i+1) then									// sta #$00			; 1
     begin
       listing[i+1] := '';
       exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN		; 0
       sta_im_0(i+1) then									// sta #$00			; 1
     begin
       listing[i+1] := '';
       exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       sta_a(i+1) then										// sta				; 1
     begin
       listing[i] := '';
       exit(false);
     end;


    if lda_im_0(i) and										// lda #$00			; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00			; 1
       sta_im_0(i+2) then									// sta #$00			; 2
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       if lda_im_0(i+3) and						/// lda #$00			; 3
          adc_sbc_im_0(i+4) and						/// adc|sbc #$00		; 4
          sta_im_0(i+5) then						/// sta #$00			; 5
	begin
         listing[i+3] := '';
         listing[i+4] := '';
         listing[i+5] := '';

         if lda_im_0(i+6) and						/// lda #$00			; 6
            adc_sbc_im_0(i+7) and					/// adc|sbc #$00		; 7
            sta_im_0(i+8) then						/// sta #$00			; 8
	  begin
           listing[i+6] := '';
           listing[i+7] := '';
           listing[i+8] := '';
          end;

	end;

	exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       lda_im_0(i+1) and									// lda #$00			; 1
       adc_sbc_im_0(i+2) then									// adc|sbc #$00			; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       lda_a(i+1) and (lda_im_0(i+1) = false) and						// lda				; 1
       adc_sbc_im_0(i+2) then									// adc|sbc #$00			; 2
     begin
	listing[i] := '';

	exit(false);
     end;


    if (lda_a(i) or tya(i)) and									// lda|tya			; 0
       add_sub(i+1) and										// add				; 1
       sta_im_0(i+2) and									// sta #$00			; 2
       lda_a(i+3) and 										// lda				; 3
       adc_sbc(i+4) then									// adc				; 4
     begin
	listing[i+2] := '';

	exit(false);
     end;


    if (lda_a(i) or tya(i)) and									// lda|tya			; 0
       adc_sbc(i+1) and										// adc|sbc			; 1
       sta_im_0(i+2) and									// sta #$00			; 2
       (ldy(i+3) = false) and 									//~ldy				; 3
       (adc_sbc(i+4) = false) then								//~adc|sbc			; 4
     begin
	listing[i+2] := '';

	if lsr_stack(i+3) or asl_stack(i+3) then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	end else
	if (i > 0) and sta_im_0(i-1) then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	end;

	exit(false);
     end;


    if add_sub(i) and										// add|sub			; 0
       sta_im_0(i+1) and									// sta #$00			; 1
       (ldy(i+2) = false) and									//~ldy				; 2
       (adc_sbc(i+3) = false) then								//~adc|sbc			; 3
     begin
	listing[i+1] := '';
	exit(false);
     end;


    if (add_sub(i) = false) and (adc_sbc(i) = false) and					//~add|sub|adc|sbc		; 0
       sta_im_0(i+1) and									// sta #$00			; 1
       (lda_a(i+2) or mva(i+2) or mwa(i+2) or and_ora_eor(i+2)) then				// lda|mva|mwa|and|ora|eor	; 2
     begin
	listing[i+1] := '';

	if lda_a(i) and (iy(i) = false) then listing[i] := '';

	exit(false);
     end;


    if (AND_ORA_EOR(i) or lda_adr(i)) and							// and|ora|eor|lda adr.		; 0
       sta_im_0(i+1) then									// sta #$00			; 1
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if (lsr_a(i) or asl_a(i) or rol_a(i) or ror_a(i)) and					// lsr|asl|rol|ror @		; 0
       sta_im_0(i+1) then									// sta #$00			; 1
     begin
	listing[i+1] := '';

	if lda_a(i+2) or						/// lda | ldy | mwy	; 2
	   (ldy(i+2) and lda_a(i+3)) or					///     | lda | lda	; 3
	   (mwy(i+2) and lda_a(i+3)) then listing[i] := '';

	exit(false);
     end;


    if (i > 0) and (add_sub(i-1) = false) and (adc_sbc(i-1) = false) and			//~add|sub|adc|sbc		; -1
       sta_im_0(i) and										// sta #$00			; 0
       (asl(i+1) or lsr(i+1)) then								// asl|lsr			; 1
     begin
	listing[i] := '';

	exit(false);
     end;


    if (sta_im_0(i) or lda_a(i)) and								// sta #$00|lda			; 0
       ldy(i+1) and										// ldy 				; 1
       (lda_a(i+2) or mva(i+2) or mwa(i+2) or tya(i+2)) then					// lda|mva|mwa|tya		; 2
     begin
	listing[i] := '';

	if (i>0) and (lda_a(i-1) or adc_sbc(i-1)) then listing[i-1] := '';

	exit(false);
     end;


    if mwy_bp2(i) and										// mwy ... :b2			; 0
       ldy(i+1) and										// ldy				; 1
       lda_bp2_y(i+2) and									// lda (:bp2),y			; 2
       sta_im_0(i+3) and									// sta #$00			; 3
       (mvy(i+4) or ldy(i+4) or mwy(i+4)) then							// mvy|ldy|mwy			; 4
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if (ldy(i) or iny(i)) and									// ldy|iny			; 0
       lda_bp2_y(i+1) and									// lda (:bp2),y			; 1
       sta_im_0(i+2) and									// sta #$00			; 2
       iny(i+3) and										// iny				; 3
       lda_bp2_y(i+4) then									// lda (:bp2),y			; 4
     begin
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if (sta_im_0(i) or lda_a(i)) and								// sta #$00|lda			; 0
       ldy(i+1) and										// ldy				; 1
       sty_bp_1(i+2) and									// sty :bp+1			; 2
       ldy(i+3) and										// ldy				; 3
       lda(i+4) then										// lda				; 4
     begin
	listing[i] := '';

	if (i>0) and (lda_a(i-1) or adc_sbc(i-1)) then listing[i-1] := '';

	exit(false);
     end;


    if (sta_im_0(i) or lda_a(i)) and								// sta #$00|lda			; 0
       mwy(i+1) and										// mwy				; 1
       ldy(i+2) and										// ldy				; 2
       (lda_a(i+3) or mva(i+3) or mwa(i+3)) then						// lda|mva|mwa			; 3
     begin
	listing[i] := '';

	if (i>0) and (lda_a(i-1) or adc_sbc(i-1)) then listing[i-1] := '';

	exit(false);
     end;


    if (sta_im_0(i) or lda_a(i)) and								// sta #$00|lda			; 0
       ldy(i+1) and										// ldy 				; 1
       (iny(i+2) or dey(i+2)) and								// iny|dey			; 2
       (lda_a(i+3) or mva(i+3) or mwa(i+3)) then						// lda|mva|mwa			; 3
     begin
	listing[i] := '';

	if (i>0) and (lda_a(i-1) or adc_sbc(i-1)) then listing[i-1] := '';

	exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       ldy(i+1) and										// ldy 				; 1
       LOCAL(i+2) and										// .LOCAL			; 2
       lda(i+3) then										// lda				; 3
     begin
	listing[i] := '';
	exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       LOCAL(i+1) and										// .LOCAL			; 1
       lda(i+2) then										// lda				; 2
     begin
	listing[i] := '';
	exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       cmp_im_0(i+1) and									// cmp #$00			; 1
       bne(i+2) then										// bne				; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	exit(false);
     end;


    if sta_im_0(i) and										// sta #$00			; 0
       (beq(i+1) or bne(i+1)) and								// beq|bne			; 1
       jmp(i+2) then										// jmp				; 2
     begin
	listing[i]   := '';

	exit(false);
     end;


    if tya(i) and										// tya				; 0
       sta_im_0(i+1) and									// sta #$00			; 1
       SKIP(i+2) then										// SKIP				; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if scc(i) and										// scc				; 0
       (listing[i+1] = #9'inc #$00') then							// inc #$00			; 1
     begin
	listing[i]   := '';
	listing[i+1] := '';
	exit(false);
     end;


    if scs(i) and										// scs				; 0
       (listing[i+1] = #9'dec #$00') then							// dec #$00			; 1
     begin
	listing[i]   := '';
	listing[i+1] := '';
	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN		; 0
       asl_stack(i+1) and									// asl :STACKORIGIN		; 1
       sta_im_0(i+2) then									// sta #$00			; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
       begin
	listing[i+1] := listing[i];
	listing[i]   := #9'asl @';
	listing[i+2] := '';

	exit(false);
       end;


     if sta_stack(i) and									// sta :STACKORIGIN		; 0
	asl_stack(i+1) and									// asl :STACKORIGIN		; 1
	asl_stack(i+2) and									// asl :STACKORIGIN		; 2
        sta_im_0(i+3) then									// sta #$00			; 3
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i+2] := listing[i];
	listing[i]   := #9'asl @';
	listing[i+1] := #9'asl @';
	listing[i+3] := '';

	exit(false);
       end;


    if (SKIP(i-1) = false) and									//~SKIP
       lda_a(i) and										// lda :STACKORIGIN+9		; 0
       sta_a(i+1) then										// sta :STACKORIGIN+9		; 1
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin
       listing[i]  := '';
       listing[i+1]:= '';
       exit(false);
     end;


    if lda(i) and										// lda :ztmp8			; 0
       bpl_a(i+1) and										// bpl @+			; 1
       lda(i+2) and										// lda  			; 2
       sub(i+3) and										// sub 				; 3
       sta_im_0(i+4) and									// sta #$00			; 4
       lab_a(i+5) then										//@				; 5
     begin
        listing[i]   := '';
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := '';
        listing[i+4] := '';
        listing[i+5] := '';

	exit(false);
     end;

end;		// function
