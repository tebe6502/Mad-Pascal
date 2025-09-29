
function opt_STACK(i: integer): Boolean;
var p: integer;
    tmp: string;
    yes: Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      STACK.
// -----------------------------------------------------------------------------

  if (listing[i] = #9'pla') and									// pla					; 0
     (listing[i+1] = #9'sta portb') then begin							// sta portb				; 1

    if dex(i+10) and

       lda_stack(i+2) and						// lda :STACKORIGIN,x			; 2
       sta_val(i+3) and							// sta ~:STACKORIGIN			; 3
       lda_stack(i+4) and						// lda :STACKORIGIN+STACKWIDTH,x	; 4
       sta_val(i+5) and							// sta ~:STACKORIGIN			; 5
       lda_stack(i+6) and						// lda :STACKORIGIN+STACKWIDTH,x	; 6
       sta_val(i+7) and							// sta ~:STACKORIGIN			; 7
       lda_stack(i+8) and						// lda :STACKORIGIN+STACKWIDTH,x	; 8
       sta_val(i+9) then						// sta ~:STACKORIGIN			; 9
//       dex(i+10) then							// dex					; 10
     begin
	listing[i]   := listing[i+2];
	listing[i+1] := listing[i+3];
	listing[i+2] := listing[i+4];
	listing[i+3] := listing[i+5];
	listing[i+4] := listing[i+6];
	listing[i+5] := listing[i+7];
	listing[i+6] := listing[i+8];
	listing[i+7] := listing[i+9];
	listing[i+8] := #9'dex';
	listing[i+9] := #9'pla';
	listing[i+10] := #9'sta portb';

        exit(false);
     end;


    if dex(i+6) and

       lda_stack(i+2) and						// lda :STACKORIGIN,x			; 2
       sta_val(i+3) and							// sta ~:STACKORIGIN			; 3
       lda_stack(i+4) and						// lda :STACKORIGIN+STACKWIDTH,x	; 4
       sta_val(i+5) then						// sta ~:STACKORIGIN			; 5
//       dex(i+6) then							// dex					; 6
     begin
	listing[i]   := listing[i+2];
	listing[i+1] := listing[i+3];
	listing[i+2] := listing[i+4];
	listing[i+3] := listing[i+5];
	listing[i+4] := #9'dex';
	listing[i+5] := #9'pla';
	listing[i+6] := #9'sta portb';

        exit(false);
     end;


    if dex(i+4) and

       lda_stack(i+2) and						// lda :STACKORIGIN,x			; 2
       sta_val(i+3) then						// sta ~:STACKORIGIN			; 3
//       dex(i+4) then							// dex					; 4
     begin
	listing[i]   := listing[i+2];
	listing[i+1] := listing[i+3];
	listing[i+2] := #9'dex';
	listing[i+3] := #9'pla';
	listing[i+4] := #9'sta portb';

        exit(false);
     end;


    end;


// -----------------------------------------------------------------------------


    if inx(i) and										// inx					; 0
       lda(i+1) and (ix(i+1) = false) and							// lda					; 1
       (listing[i+2] = #9'sta @PARAM?') and							// sta @PARAM?				; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';
       listing[i+3] := '';
       exit(false);
     end;


    if (listing[i] = #9'sta @PARAM?.@NIL') then							// sta @PARAM?.@NIL			; 0
     begin
       listing[i] := #9'sta #$00';
       exit(false);
     end;


    if (l = i + 2) and
       dex(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i) and (mva_stack(i) = false) and (pos(':STACKORIGIN', listing[i]) > 0) then		// dex					; 2
     begin
       	  listing[i] := '';
       	  exit(false);
     end;


    if (l = i + 4) and
       (lda_a(i) or sta_stack(i)) and								// lda|sta :STACKORIGIN+STACKWIDTH	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
       sta_val(i+2) and										// sta					; 2	~:STACKORIGIN
       dex(i+3) then										// dex					; 3
     if (argMatch(i, i+1) = false) then
     begin
       listing[i] := '';

       exit(false);
     end;


    if (l = i + 4) and
       (and_ora_eor_val(i) or add_sub_val(i) or adc_sbc_val(i)) and				// and|ora|eor|add|sdc|sub|sbc		; 0	~:STACKORIGIN
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
       sta_val(i+2) and										// sta					; 2	~:STACKORIGIN
       dex(i+3) then										// dex					; 3
     if (argMatch(i, i+1) = false) then
     begin
       listing[i] := '';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x
       (listing[i+1] = #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x') then			// mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x
      begin
       listing[i]   := #9'sta :STACKORIGIN,x';
       listing[i+1] := '';

       exit(false);
      end;


    if lda_val(i) and										// lda						; 0	~:STACKORIGIN
       (listing[i+1] = #9'sta :STACKORIGIN,x') and 						// sta :STACKORIGIN,x				; 1
       lda_val(i+2) and										// lda						; 2	~:STACKORIGIN
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x		; 3
       (listing[i+4] = #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x') then			// mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x	; 4
     begin
       listing[i] := listing[i+2];

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       lda_stack(i) and										// lda :STACKORIGIN+9			; 0
       sta_stack(i+1) then									// sta :STACKORIGIN+9			; 1
     if argMatch(i, i+1) then begin
       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN			; 0
       (listing[i+1] = #9'sta #$00') then							// sta #$00				; 1
     begin
       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
     end;


    if lda_val(i) and										// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_stack(i+3) then									// sta :STACKORIGIN			; 3
     if argMatch(i+1, i+3) then
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN			; 0
       and_ora_eor(i+1) and									// and|ora|eor				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       (listing[i+3] = listing[i]) and								// lda :STACKORIGIN			; 3
       sta_val(i+4) then									// sta					; 4
     if argMatch(i, i+2) then
     begin
       listing[i+2] := '';
       listing[i+3] := '';
       exit(false);
     end;


    if (lab_a(i) = false) and									//~@					; 0
       sty_stack(i+1) and 									// sty :STACKORIGIN			; 1
       lda_stack(i+2) then									// lda :STACKORIGIN			; 2
     if argMatch(i+1, i+2) then
     begin
       listing[i+1] := #9'tya';
       listing[i+2] := '';

       exit(false);
     end;


    if mva(i) and										// mva I :STACKORIGIN+STACKWIDTH,x	; 0
       (listing[i+1] = #9'lda :STACKORIGIN+STACKWIDTH,x') then					// lda :STACKORIGIN+STACKWIDTH,x	; 1
     if (pos(':STACKORIGIN+STACKWIDTH,x', listing[i]) > 0) then
     begin
       listing[i+1] := #9'lda ' + GetSTRING(i);
       listing[i]   := '';

       exit(false);
     end;


    if mva(i) and										// mva I :STACKORIGIN,x			; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') then						// lda :STACKORIGIN,x			; 1
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+1] := #9'lda ' + GetSTRING(i);
       listing[i]   := '';

       exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN,x			; 0
       lda_stack(i+1) and									// lda :STACKORIGIN,x			; 1
       sta_val(i+2) then									// sta TILE				; 2
     if argMatch(i, i+1) then
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if lda_a(i) and 										// lda					; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       lda_a(i+2) and										// lda					; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_a(i+5) and										// sta					; 5
       (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
       sta_a(i+7) then										// sta					; 7
     begin
       listing[i+4] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i+6] := #9'lda ' + copy(listing[i+2], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i] = #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x') and			// mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x	; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x				; 1
       (listing[i+2] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x				; 2
       sta_adr(i+3) then									// sta adr.					; 3
     begin
       listing[i+2] := #9'lda :STACKORIGIN+STACKWIDTH,x';

       listing[i] := '';

       exit(false);
     end;


    if lda_val(i) and (iy(i) = false) and							// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN,x			; 1
       ldy_stack(i+2) then									// ldy :STACKORIGIN,x			; 2
     if argMatch(i+1, i+2) then
     begin

       if iy(i) = false then begin
        listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
       end else
        listing[i+1] := #9'tay';

       listing[i+2] := '';

       exit(false);
     end;


    if lda_val(i) and										// lda					; 0	~:STACKORIGIN
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       (listing[i+2] = #9'mva #$00 :STACKORIGIN+STACKWIDTH,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+3] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 3
     begin

       if iy(i) = false then begin
        listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
       end else
        listing[i+1] := #9'tay';

       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN,x			; 0
       ldy_stack(i+1) and									// ldy :STACKORIGIN-1,x			; 1
       lda_stack(i+2) then									// lda :STACKORIGIN,x			; 2
     if argMatch(i, i+2) then
     begin
       listing[i]   := '';
       listing[i+2] := '';
       exit(false);
     end;


    if lda_val(i) and										// lda					; 0	~:STACKORIGIN
       dex(i+1) then										// dex					; 1
     begin
       listing[i+1]:= listing[i];
       listing[i]  := #9'dex';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 0
       dex(i+1) then										// dex					; 1
     begin
       listing[i]  := #9'dex';
       listing[i+1]:= #9'sta :STACKORIGIN,x';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 0
       dex(i+1) then										// dex					; 1
     begin
       listing[i]  := #9'dex';
       listing[i+1]:= #9'sta :STACKORIGIN+1,x';

       exit(false);
     end;


    if (listing[i] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 0
       dex(i+1) then										// dex					; 1
     begin
       listing[i]  := #9'dex';
       listing[i+1]:= #9'lda :STACKORIGIN,x';

       exit(false);
     end;


    if (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       dex(i+1) then										// dex					; 1
     begin
       listing[i]  := #9'dex';
       listing[i+1]:= #9'lda :STACKORIGIN+1,x';

       exit(false);
     end;


    if tya(i) and										// tya					; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       dex(i+2) then										// dex					; 2
     begin
       listing[i+2] := #9'sta :STACKORIGIN+1,x';
       listing[i+1] := #9'tya';
       listing[i]   := #9'dex';

       exit(false);
     end;


    if tya(i) and										// tya					; 0
       and_ora_eor_val(i+1) and									// and|ora|eor				; 1
       dex(i+2) then										// dex					; 2
     begin
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];
       listing[i]   := #9'dex';

       exit(false);
     end;


    if (inx(i) = false) and									// inx					; 0	~inx
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       (listing[i+3] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i+4] := #9'sta :STACKORIGIN+1,x';
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := #9'dex';

       exit(false);
     end;


    if (inx(i) = false) and									// inx					; 0	~inx
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       (listing[i+3] = #9'sta :STACKORIGIN+1,x') and						// sta :STACKORIGIN+1,x			; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i+4] := #9'sta :STACKORIGIN+2,x';
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := #9'dex';

       exit(false);
     end;


    if lda_a(i) and 										// lda					; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       lda_a(i+2) and										// lda					; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       (listing[i+5] = #9'ldy :STACKORIGIN+STACKWIDTH,x') then					// ldy :STACKORIGIN+STACKWIDTH,x	; 5
     begin
       listing[i+4] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       (listing[i+2] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_val(i+4) then									// sta					; 4	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mwy_bp2(i+2) and										// mwy G :bp2				; 2
       (listing[i+3] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_val(i+5) then									// sta 					; 5	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if mva(i) and										// mva	 :STACKORIGIN,x			; 0
       mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 2
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
     begin
       listing[i+2] := #9'ldy ' + GetSTRING(i);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva    :STACKORIGIN			; 1
       mva(i+2) and (iy(i+2) = false) and							// mva    :STACKORIGIN+STACKWIDTH	; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN			; 3
       (listing[i+4] = #9'ldy :STACKORIGIN+STACKWIDTH,x') then					// ldy :STACKORIGIN+STACKWIDTH		; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
       listing[i+3]  := #9'lda ' + GetString(i+1);
       listing[i+4]  := #9'ldy ' + GetString(i+2);

       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva    :STACKORIGIN,x		; 1
       mva(i+2) and										// mva    :STACKORIGIN+STACKWIDTH,x	; 2
       mwy_bp2(i+3) and										// mwy G :bp2				; 3
       ldy(i+4) and										// ldy					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       iny(i+7) and										// iny					; 7
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
       sta_val(i+9) then									// sta					; 9	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva    :STACKORIGIN,x		; 1
       mva(i+2) and 										// mva    :STACKORIGIN+STACKWIDTH,x	; 2
       ldy(i+3) and 										// ldy					; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_val(i+5) and										// sta					; 5	~:STACKORIGIN
       (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
       sta_val(i+7) then									// sta					; 7	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i+6] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if mwy_bp2(i) and										// mwy G :bp2				; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       iny(i+4) and										// iny					; 4	~:STACKORIGIN
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];
       listing[i]   := #9'dex';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_val(i+5) then									// sta					; 5	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and										// mva					; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_val(i+4) and										// sta					; 4	~:STACKORIGIN
       (listing[i+5] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 5
       sta_val(i+6) then									// sta					; 6	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+5] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva    :STACKORIGIN			; 1
       mva(i+2) and 										// mva    :STACKORIGIN+STACKWIDTH	; 2
       lda_a(i+3) and										// lda					; 3
       and_ora_eor_stack(i+4) and								// and|ora|eor :STACKORIGIN		; 4
       sta_a(i+5) and										// sta					; 5
       lda_a(i+6) and										// lda					; 6
       and_ora_eor_stack(i+7) and								// and|ora|eor :STACKORIGIN+STACKWIDTH	; 7
       sta_a(i+8) and										// sta					; 8
       dex(i+9) then										// dex					; 9
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN,x', listing[i+4]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin
	listing[i+4] := copy(listing[i+4], 1, 5) + GetString(i+1);

	listing[i+7] := copy(listing[i+7], 1, 5) + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva    :STACKORIGIN			; 1
       mva(i+2) and 										// mva    :STACKORIGIN+STACKWIDTH	; 2
       lda_stack(i+3) and									// lda :STACKORIGIN			; 3
       and_ora_eor(i+4) and									// and|ora|eor 				; 4
       sta_a(i+5) and										// sta					; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       and_ora_eor(i+7) and									// and|ora|eor				; 7
       sta_a(i+8) and										// sta					; 8
       dex(i+9) then										// dex					; 9
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+6]) > 0) then
     begin
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+6] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva    :STACKORIGIN			; 1
       mva(i+2) and 										// mva    :STACKORIGIN+STACKWIDTH	; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       (add_sub_val(i+4) or and_ora_eor_val(i+4)) and						// add|sub|and|ora|eor			; 4	~:STACKORIGIN
       sta_a(i+5) and										// sta					; 5
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       (adc_sbc_val(i+7) or and_ora_eor_val(i+7)) and						// adc|sbc|and|ora|eor			; 7	~:STACKORIGIN
       sta_a(i+8) and										// sta					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN			; 9
       sta_a(i+10) and										// sta					; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH		; 11
       sta_a(i+12) and										// sta					; 12
       dex(i+13) then										// dex					; 13
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN,x', listing[i+9]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+11]) > 0) then
     begin
	listing[i+9] := #9'lda ' + GetString(i+1);

	listing[i+11] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva    :STACKORIGIN			; 1
       mva(i+2) and 										// mva    :STACKORIGIN+STACKWIDTH	; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_a(i+4) and										// sta					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       sta_a(i+6) and										// sta					; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       sta_val(i+8) and										// sta					; 8	~:STACKORIGIN
       (listing[i+9] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 9
       sta_val(i+10) then									// sta					; 10	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+7] := #9'lda ' + GetString(i+1);

	listing[i+9] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva	 :STACKORIGIN,x			; 1
       mva(i+2) and										// mva	 :STACKORIGIN+STACKWIDTH,x	; 2
       inx(i+3) and										// inx					; 3
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_val(i+5) and										// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       sta_val(i+7) and										// sta					; 7	~:STACKORIGIN
       (listing[i+8] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 8
       sta_val(i+9) and										// sta					; 9	~:STACKORIGIN
       (listing[i+10] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 10
       sta_val(i+11) then									// sta					; 11	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+8] := #9'lda ' + GetString(i+1);

	listing[i+10] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       (listing[i+4] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 4
       sta_val(i+5) and										// sta ~:STACKORIGIN			; 5
       (listing[i+6] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 6
       sta_val(i+7) and										// sta ~:STACKORIGIN			; 7
       (listing[i+8] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 8
       sta_val(i+9) and										// sta ~:STACKORIGIN			; 9
       (listing[i+10] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 10
       sta_val(i+11) then									// sta ~:STACKORIGIN			; 11
     if (pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN-1+STACKWIDTH*2,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN-1+STACKWIDTH*3,x', listing[i+3]) > 0) then
     begin
	listing[i+6] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i+10] := #9'lda ' + GetString(i+3);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if lda_val(i) and 										// lda ~:STACKORIGIN			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN,x			; 1
       lda_val(i+2) and 									// lda ~:STACKORIGIN			; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH,x	; 3
       lda_val(i+4) and										// lda ~:STACKORIGIN			; 4
       sta_val(i+5) and										// sta ~:STACKORIGIN			; 5
       lda_val(i+6) and										// lda ~:STACKORIGIN			; 6
       sta_val(i+7) and										// sta ~:STACKORIGIN			; 7
       lda_stack(i+8) and									// lda :STACKORIGIN,x			; 8
       sta_val(i+9)  and									// sta ~:STACKORIGIN			; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_val(i+11) then									// sta ~:STACKORIGIN			; 11
     if argMatch(i+1, i+8) and
        argMatch(i+3, i+10) then
     begin
	listing[i+8]  := #9'lda ' + copy(listing[i], 6, 256);

	listing[i+10] := #9'lda ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if lda_val(i) and										// lda ~:STACKORIGIN			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda ~:STACKORIGIN			; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_val(i+4) and										// lda ~:STACKORIGIN			; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_val(i+6) and										// lda ~:STACKORIGIN			; 6
       sta_stack(i+7) then 									// sta :STACKORIGIN+STACKWIDTH*3	; 7
      begin


       if lda_stack(i+8) and									// lda :STACKORIGIN,x			; 8
          sta_val(i+9) and									// sta ~:STACKORIGIN			; 9
          lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
          sta_val(i+11) and									// sta ~:STACKORIGIN			; 11
          lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH*2,x	; 12
          sta_val(i+13) and									// sta ~:STACKORIGIN			; 13
          lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH*3,x	; 14
          sta_val(i+15) then									// sta ~:STACKORIGIN			; 15
        if argMatch(i+1, i+8) and
           argMatch(i+3, i+10) and
           argMatch(i+5, i+12) and
           argMatch(i+7, i+14) then
         begin
	   listing[i+8]  := #9'lda ' + GetString(i);

	   listing[i+10] := #9'lda ' + GetString(i+2);

	   listing[i+12] := #9'lda ' + GetString(i+4);

	   listing[i+14] := #9'lda ' + GetString(i+6);

	   listing[i]   := '';
	   listing[i+1] := '';
	   listing[i+2] := '';
	   listing[i+3] := '';
	   listing[i+4] := '';
	   listing[i+5] := '';
	   listing[i+6] := '';
	   listing[i+7] := '';

           exit(false);
         end;


       if lda_a(i+8) and									// lda					; 8
          and_ora_eor_stack(i+9) and								// and|ora|eor :STACKORIGIN		; 9
          sta_a(i+10) and									// sta					; 10
          lda_a(i+11) and									// lda					; 11
          and_ora_eor_stack(i+12) and								// and|ora|eor :STACKORIGIN+STACKWIDTH	; 12
          sta_a(i+13) and									// sta					; 13
          lda_a(i+14) and									// lda					; 14
          and_ora_eor_stack(i+15) and								// and|ora|eor :STACKORIGIN+STACKWIDTH*2; 15
          sta_a(i+16) and									// sta					; 16
          lda_a(i+17) and									// lda					; 17
          and_ora_eor_stack(i+18) and								// and|ora|eor :STACKORIGIN+STACKWIDTH*3; 18
          sta_a(i+19) then									// sta					; 19
        if argMatch(i+1, i+9) and
           argMatch(i+3, i+12) and
           argMatch(i+5, i+15) and
           argMatch(i+7, i+18) then
         begin
	   listing[i+9]  := copy(listing[i+9], 1, 5) + copy(listing[i], 6, 256);

	   listing[i+12] := copy(listing[i+12], 1, 5) + copy(listing[i+2], 6, 256);

   	   listing[i+15] := copy(listing[i+15], 1, 5) + copy(listing[i+4], 6, 256);

	   listing[i+18] := copy(listing[i+18], 1, 5) + copy(listing[i+6], 6, 256);

	   listing[i]   := '';
	   listing[i+1] := '';
	   listing[i+2] := '';
	   listing[i+3] := '';
	   listing[i+4] := '';
	   listing[i+5] := '';
	   listing[i+6] := '';
	   listing[i+7] := '';

           exit(false);
         end;

      end;


// -----------------------------------------------------------------------------


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4
       (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
       (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
       (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
       (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin


      if (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
         sta_val(i+6) and									// sta ~:STACKORIGIN			; 6
         dex(i+7) then										// dex					; 7
      	begin
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

	 listing[i+5] := #9'lda ' + GetString(i+1);

	 listing[i+1] := '';

       	 exit(false);
     	end;


      if (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
         sta_val(i+6) and									// sta ~:STACKORIGIN			; 6
       	 (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       	 sta_val(i+8) and									// sta ~:STACKORIGIN			; 8
       	 dex(i+9) then										// dex					; 9
     	begin
	 listing[i+3] := '';
	 listing[i+4] := '';

	 listing[i+5] := #9'lda ' + GetString(i+1);

	 listing[i+7] := #9'lda ' + GetString(i+2);

	 listing[i+1] := '';
	 listing[i+2] := '';

         exit(false);
     	end;


      if (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
         sta_val(i+6) and									// sta ~:STACKORIGIN			; 6
         (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
         sta_val(i+8) and									// sta ~:STACKORIGIN			; 8
         (listing[i+9] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 9
         sta_val(i+10) and									// sta ~:STACKORIGIN			; 10
         (listing[i+11] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 11
         sta_val(i+12) then									// sta ~:STACKORIGIN			; 12
     	begin
	 listing[i+5] := #9'lda ' + GetString(i+1);

	 listing[i+7] := #9'lda ' + GetString(i+2);

	 listing[i+9] := #9'lda ' + GetString(i+3);

	 listing[i+11] := #9'lda ' + GetString(i+4);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

	 exit(false);
     	end;


      if inx(i+5) and										// inx					; 5
         (listing[i+6] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 6
	 and_ora_eor(i+7) and									// and|ora|eor				; 7
         sta_a(i+8) and {(sta_stack(i+8) = false) and}						// sta					; 8
         (listing[i+9] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 9
	 and_ora_eor(i+10) and									// and|ora|eor				; 10
         sta_a(i+11) and {(sta_stack(i+11) = false) and}					// sta					; 11
         (listing[i+12] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 12
	 and_ora_eor(i+13) and									// and|ora|eor				; 13
         sta_a(i+14) and {(sta_stack(i+14) = false) and}					// sta					; 14
         (listing[i+15] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 15
	 and_ora_eor(i+16) and									// and|ora|eor				; 16
         sta_a(i+17) {and (sta_stack(i+17) = false)} then					// sta					; 17
     	begin
	 listing[i+6] := #9'lda ' + GetString(i+1);

	 listing[i+9] := #9'lda ' + GetString(i+2);

	 listing[i+12] := #9'lda ' + GetString(i+3);

	 listing[i+15] := #9'lda ' + GetString(i+4);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

       	 exit(false);
     	end;


      if (listing[i+5] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1			; 5
	 and_ora_eor_stack(i+6) and								// and|ora|eor :STACKORIGIN		; 6
         sta_a(i+7) and										// sta					; 7
         (listing[i+8] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH	; 8
	 and_ora_eor_stack(i+9) and								// and|ora|eor :STACKORIGIN+STACKWIDTH	; 9
         sta_a(i+10) and									// sta					; 10
         (listing[i+11] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2	; 11
	 and_ora_eor_stack(i+12) and								// and|ora|eor :STACKORIGIN+STACKWIDTH*2; 12
         sta_a(i+13) and 									// sta					; 13
         (listing[i+14] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3	; 14
	 and_ora_eor_stack(i+15) and								// and|ora|eor :STACKORIGIN+STACKWIDTH*3; 15
         sta_a(i+16) then									// sta					; 16
       if (pos(':STACKORIGIN,x', listing[i+6]) > 0) and
          (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+9]) > 0) and
          (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+12]) > 0) and
          (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+15]) > 0) then
     	begin
	 listing[i+6] := copy(listing[i+6], 1, 5) + GetString(i+1);

	 listing[i+9] := copy(listing[i+9], 1, 5) + GetString(i+2);

	 listing[i+12] := copy(listing[i+12], 1, 5) + GetString(i+3);

	 listing[i+15] := copy(listing[i+15], 1, 5) + GetString(i+4);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

       	 exit(false);
     	end;


      if inx(i+5) and										// inx					; 5
         lda_val(i+6) and									// lda ~:STACKORIGIN			; 6
         sta_val(i+7) and									// sta ~:STACKORIGIN			; 7
         lda_val(i+8) and									// lda ~:STACKORIGIN			; 8
         sta_val(i+9) and									// sta ~:STACKORIGIN			; 9
         lda_val(i+10) and									// lda ~:STACKORIGIN			; 10
         sta_val(i+11)  and									// sta ~:STACKORIGIN			; 11
         lda_val(i+12) and									// lda ~:STACKORIGIN			; 12
         sta_val(i+13) and									// sta ~:STACKORIGIN			; 13
         (listing[i+14] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 14
         sta_val(i+15) and									// sta ~:STACKORIGIN			; 15
         (listing[i+16] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 16
         sta_val(i+17) and									// sta ~:STACKORIGIN			; 17
         (listing[i+18] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 18
         sta_val(i+19) and									// sta ~:STACKORIGIN			; 19
         (listing[i+20] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 20
         sta_val(i+21) then									// sta ~:STACKORIGIN			; 21
     	begin
	 listing[i+14] := #9'lda ' + GetString(i+1);

	 listing[i+16] := #9'lda ' + GetString(i+2);

	 listing[i+18] := #9'lda ' + GetString(i+3);

	 listing[i+20] := #9'lda ' + GetString(i+4);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

       	 exit(false);
     	end;


     if mwy_bp2(i+5) and									// mwy G :bp2				; 5
        ldy(i+6) and										// ldy					; 6
        (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
        sta_val(i+8) and									// sta ~:STACKORIGIN			; 8
        iny(i+9) and										// iny					; 9
        (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
        sta_val(i+11) and									// sta ~:STACKORIGIN			; 11
        iny(i+12) and										// iny					; 12
        (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 13
        sta_val(i+14) and									// sta ~:STACKORIGIN			; 14
        iny(i+15) and										// iny					; 15
        (listing[i+16] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 16
        sta_val(i+17) then									// sta ~:STACKORIGIN			; 17
      begin
	 listing[i+7] := #9'lda ' + GetString(i+1);

	 listing[i+10] := #9'lda ' + GetString(i+2);

	 listing[i+13] := #9'lda ' + GetString(i+3);

	 listing[i+16] := #9'lda ' + GetString(i+4);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

         exit(false);
      end;


      if (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
         sta_val(i+6) and									// sta ~:STACKORIGIN			; 6
         (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
         sta_val(i+8) and									// sta ~:STACKORIGIN			; 8
         (listing[i+9] <> #9'lda :STACKORIGIN+STACKWIDTH*2,x') then				// lda :STACKORIGIN+STACKWIDTH*2,x	; 9
     	begin
	 listing[i+5] := #9'lda ' + GetString(i+1);

	 listing[i+7] := #9'lda ' + GetString(i+2);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

	 exit(false);
     	end;


      if (listing[i+5] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 5
         (listing[i+6] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 6
         sta_val(i+7) and									// sta ~:STACKORIGIN			; 7
         (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
         sta_val(i+9) and									// sta ~:STACKORIGIN			; 9
         (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 10
         sta_val(i+11) and									// sta ~:STACKORIGIN			; 11
         (listing[i+12] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 12
         sta_val(i+13) then									// sta ~:STACKORIGIN			; 13
    	begin
	 listing[i+6] := #9'lda ' + GetString(i+1);

	 listing[i+8] := #9'lda ' + GetString(i+2);

	 listing[i+10] := #9'lda ' + GetString(i+3);

	 listing[i+12] := #9'lda ' + GetString(i+4);

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

         exit(false);
     	end;

     end;

// -----------------------------------------------------------------------------

    if dex(i+24) and										// dex					; 24

       inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4

       (listing[i+12] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 12
       (listing[i+13] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 13
       sta_bp2_y(i+14) and									// sta (:bp2),y				; 14
       iny(i+15) and										// iny					; 15
       (listing[i+16] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 16
       sta_bp2_y(i+17) and									// sta (:bp2),y				; 17
       iny(i+18) and										// iny					; 18
       (listing[i+19] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 19
       sta_bp2_y(i+20) and									// sta (:bp2),y				; 20
       iny(i+21) and										// iny					; 21
       (listing[i+22] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 22
       sta_bp2_y(i+23) then									// sta (:bp2),y				; 23
//       dex(i+24) then										// dex					; 24
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin


      if lda_val(i+5) and									// lda ~:STACKORIGIN			; 5
         ldy_val(i+6) and									// ldy ~:STACKORIGIN			; 6
         add_im(i+7) and									// add #				; 7
         sta_bp2(i+8) and									// sta :bp2				; 8
         scc(i+9) and										// scc					; 9
         iny(i+10) and										// iny					; 10
         (listing[i+11] = #9'sty :bp2+1') then							// sty :bp2+1				; 11
	begin

	 listing[i+12] := #9'ldy :STACKORIGIN,x';
	 listing[i+13] := #9'lda ' + GetString(i+1);

	 listing[i+16] := #9'lda ' + GetString(i+2);

	 listing[i+19] := #9'lda ' + GetString(i+3);

	 listing[i+22] := #9'lda ' + GetString(i+4);

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

	 listing[i+24] := '';

         exit(false);
	end;


      if mwy_bp2(i+5) and									// mwy    :bp2				; 5
         (listing[i+6] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 6
         add_im(i+7) and									// add #				; 7
         (listing[i+8] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 8
         (listing[i+9] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 9
         adc_im(i+10) and									// add #				; 10
         (listing[i+11] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') then				// sta :STACKORIGIN-1+STACKWIDTH,x	; 11
        begin
	 listing[i+6] := #9'lda :STACKORIGIN,x';

	 listing[i+8] := '';
	 listing[i+9] := '';
	 listing[i+10]:= '';
	 listing[i+11]:= '';
	 listing[i+12]:= #9'tay';

	 listing[i+13] := #9'lda ' + GetString(i+1);

	 listing[i+16] := #9'lda ' + GetString(i+2);

	 listing[i+19] := #9'lda ' + GetString(i+3);

	 listing[i+22] := #9'lda ' + GetString(i+4);

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

	 listing[i+24] := '';

         exit(false);
        end;


     end;


// -----------------------------------------------------------------------------


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva    :STACKORIGIN,x		; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       (add_sub_stack(i+3) or and_ora_eor_stack(i+3)) and					// add|sub|and|ora|eor :STACKORIGIN,x	; 3
       sta_val(i+4) then									// sta					; 4	~:STACKORIGIN
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN,x', listing[i+3]) > 0) then
     begin
	listing[i+3] := copy(listing[i+3], 1, 5) + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if (listing[i] = #9'jsr movZTMP_aBX') and							// jsr movZTMP_aBX			; 0
       dex(i+1) and										// dex					; 1
       (pos('mva :STACKORIGIN,x', listing[i+2]) > 0) and					// mva :STACKORIGIN,x NEW		; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';

       listing[i+2] := #9'mva :ztmp8 ' + copy(listing[i+2], 21, 256);

       exit(false);
     end;


    if lda_val(i) and (lda_im(i) = false) and							// lda TB				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       (listing[i+2] = listing[i] + '+1') and							// lda TB+1				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1                  		; 3
       ldy(i+4) then										// ldy					; 4
     if pos(listing[i], listing[i+2]) > 0 then
      begin
       listing[i]   := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
      end;


    if mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       (listing[i+2] = #9'mva (:bp2),y :STACKORIGIN,x') and					// mva (:bp2),y :STACKORIGIN,x		; 2
       dex(i+3) then										// dex                  		; 3
     begin
       listing[i+3] := #9'mva (:bp2),y :STACKORIGIN+1,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       (listing[i+2] = #9'mva (:bp2),y :STACKORIGIN+1,x') and					// mva (:bp2),y :STACKORIGIN+1,x	; 2
       dex(i+3) then										// dex                  		; 3
     begin
       listing[i+3] := #9'mva (:bp2),y :STACKORIGIN+2,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if dex(i+12) and										// dex					; 12

       (listing[i] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 0
       (and_ora_eor_val(i+1) or add_sub_val(i+1)) and						// and|ora|eor|add|sub			; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       (listing[i+3] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 3
       (and_ora_eor_val(i+4) or adc_sbc_val(i+4)) and						// and|ora|eor|adc|sbc			; 4	~:STACKORIGIN
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 5
       (listing[i+6] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 6
       (and_ora_eor_val(i+7) or adc_sbc_val(i+7)) and						// and|ora|eor|adc|sbc			; 7	~:STACKORIGIN
       (listing[i+8] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 8
       (listing[i+9] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 9
       (and_ora_eor_val(i+10) or adc_sbc_val(i+10)) and						// and|ora|eor|adc|sbc			; 10	~:STACKORIGIN
       (listing[i+11] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') then				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 11
//       dex(i+12) then										// dex					; 12
      begin
	listing[i+12]:= #9'sta :STACKORIGIN+STACKWIDTH*3,x';
	listing[i+11]:= listing[i+10];
	listing[i+10]:= #9'lda :STACKORIGIN+STACKWIDTH*3,x';
	listing[i+9] := #9'sta :STACKORIGIN+STACKWIDTH*2,x';
	listing[i+8] := listing[i+7];
	listing[i+7] := #9'lda :STACKORIGIN+STACKWIDTH*2,x';
	listing[i+6] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	listing[i+5] := listing[i+4];
	listing[i+4] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	listing[i+3] := #9'sta :STACKORIGIN,x';
	listing[i+2] := listing[i+1];
	listing[i+1] := #9'lda :STACKORIGIN,x';
	listing[i]   := #9'dex';

        exit(false);
      end;


    if dex(i+6) and										// dex					; 6

       (listing[i] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 0
       (and_ora_eor_val(i+1) or add_sub_val(i+1)) and						// and|ora|eor|add|sub			; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       (listing[i+3] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 3
       (and_ora_eor_val(i+4) or adc_sbc_val(i+4)) and						// and|ora|eor|adc|sbc			; 4	~:STACKORIGIN
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') then				// sta :STACKORIGIN-1+STACKWIDTH,x	; 5
//       dex(i+6) then										// dex					; 6
      begin
	listing[i+6] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	listing[i+5] := listing[i+4];
	listing[i+4] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	listing[i+3] := #9'sta :STACKORIGIN,x';
	listing[i+2] := listing[i+1];
	listing[i+1] := #9'lda :STACKORIGIN,x';
	listing[i]   := #9'dex';

        exit(false);
      end;


    if dex(i+6) and										// dex					; 6

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       (and_ora_eor_val(i+1) or add_sub_val(i+1)) and						// and|ora|eor|add|sub			; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       (and_ora_eor_val(i+4) or adc_sbc_val(i+4)) and						// and|ora|eor|adc|sbc			; 4	~:STACKORIGIN
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') then				// sta :STACKORIGIN-1+STACKWIDTH,x	; 5
//       dex(i+6) then										// dex					; 6
      begin
	listing[i+6] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	listing[i+5] := listing[i+4];
	listing[i+4] := listing[i+3];
	listing[i+3] := #9'sta :STACKORIGIN,x';
	listing[i+2] := listing[i+1];
	listing[i+1] := listing[i];
	listing[i]   := #9'dex';

        exit(false);
      end;


    if dex(i+10) and										// dex					; 10

       lda_a(i) and										// lda					; 0
       and_ora_eor(i+1) and									// and|ora|eor				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       and_ora_eor(i+4) and									// and|ora|eor				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and									// lda :STACKORIGIN,x			; 6
       sta_val(i+7) and										// sta					; 7	~:STACKORIGIN
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH,x	; 8
       sta_val(i+9) then									// sta					; 9	~:STACKORIGIN
//       dex(i+10) then										// dex					; 10
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


    if dex(i+12) and										// dex					; 12

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH		; 1
       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH,x	; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*2,x	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*3,x	; 6
       ldy(i+7) and										// ldy :STACKORIGIN-1,x			; 7
       lda_stack(i+8) and									// lda :STACKORIGIN,x			; 8
       sta_val(i+9) and										// sta					; 9	~:STACKORIGIN
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_val(i+11) then									// sta					; 11	~:STACKORIGIN
//       dex(i+12) then										// dex					; 12
    if argMatch(i+1, i+4) and
       argMatch(i+1, i+10) then
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if dex(i+11) and										// dex					; 11

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH		; 1
       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH,x	; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*2,x	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*3,x	; 6
       lda_stack(i+7) and									// lda :STACKORIGIN,x			; 7
       sta_val(i+8) and										// sta					; 8	~:STACKORIGIN
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKORIGIN,x	; 9
       sta_val(i+10) then									// sta					; 10	~:STACKORIGIN
//       dex(i+11) then										// dex					; 11
    if argMatch(i+1, i+4) and
       argMatch(i+1, i+9) then
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       and_ora_eor_im(i+1) and									// and|ora|eor #			; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
       listing[i+2] := listing[i+1];

       listing[i]   := #9'dex';
       listing[i+1] := #9'lda :STACKORIGIN+1,x';

       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       and_ora_eor(i+2) and									// and|ora|eor				; 2
       (listing[i+3] = #9'sta :STACKORIGIN,x') then						// sta :STACKORIGIN,x			; 3
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if ldy(i) and										// ldy I				; 0
       mva(i+1) and										// mva ...				; 1
       inx(i+2) and										// inx					; 2
       ldy(i+3) and (listing[i] = listing[i+3]) then						// ldy I				; 3
     begin
       listing[i+3] := '';

       exit(false);
     end;


    if listing[i] = #9'jsr @hiWORD' then							// jsr @hiWORD				; 0
     begin
       listing[i] := #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x';

       Result:=false;
     end;


    if dex(i+14) and 										// dex					; 14

       dex(i+11) and										// dex					; 11

     //dex(i) and										// dex					; 0
       lda_a(i+1) and										// lda					; 1
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       lda_a(i+3) and										// lda					; 3
       (listing[i+4] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 4
       lda_a(i+5) and										// lda					; 5
       (listing[i+6] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 6
       lda_a(i+7) and										// lda					; 7
       (listing[i+8] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 8
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       sta_val(i+10) and									// sta					; 10	~:STACKORIGIN
//       dex(i+11) and 										// dex					; 11
       (listing[i+12] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 12
       sta_val(i+13) then									// sta					; 13	~:STACKORIGIN
//       dex(i+14) then										// dex					; 14
     begin
       listing[i+12] := listing[i+1];

       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4]:= '';
       listing[i+5]:= '';
       listing[i+6]:= '';
       listing[i+7]:= '';
       listing[i+8]:= '';

       exit(false);
     end;


    if ldy(i) and										// ldy					; 0
       (listing[i+1] = #9'mva (:bp2),y :STACKORIGIN,x') and					// mva (:bp2),y :STACKORIGIN,x		; 1
       iny(i+2) and 										// iny					; 2
       (listing[i+3] = #9'mva (:bp2),y :STACKORIGIN+STACKWIDTH,x') and				// mva (:bp2),y :STACKORIGIN+STACKWIDTH ; 3
       lda(i+4) and										// lda A				; 4
       (listing[i+5] = #9'add :STACKORIGIN,x') and						// add :STACKORIGIN,x			; 5
       sta(i+6) and										// sta 					; 6
       lda(i+7) and										// lda A+1				; 7
       (listing[i+8] = #9'adc :STACKORIGIN+STACKWIDTH,x') and					// adc :STACKORIGIN+STACKWIDTH,x	; 8
       sta(i+9) then										// sta					; 9
     begin
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := listing[i+4];
       listing[i+4] := #9'add (:bp2),y';
       listing[i+5] := listing[i+6];
       listing[i+6] := #9'iny';

       listing[i+8] := #9'adc (:bp2),y';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 0
       (listing[i+1] = #9'asl :STACKORIGIN,x') and						// asl :STACKORIGIN,x			; 1
       (listing[i+2] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 2
     begin
       listing[i]   := #9'asl @';
       listing[i+1] := #9'tay';
       listing[i+2] := '';

       exit(false);
     end;


    if mva(i) and										// mva   :STACKORIGIN,x			; 0
       mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 3
       (listing[i+4] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 4
       (listing[i+5] = #9'asl :STACKORIGIN,x') and						// asl :STACKORIGIN,x			; 5
       rol_a(i+6) then										// rol @				; 6
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
     	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
     	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) then
     begin
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------


    if dex(i+3) and										// dex					; 3

       tya(i) and										// tya					; 0
       and_ora_eor_stack(i+1) and								// and|ora|eor :STACKORIGIN-1,x		; 1
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') then						// sta :STACKORIGIN-1,x			; 2
//       dex(i+3) then										// dex					; 3
     if (pos(':STACKORIGIN-1,x', listing[i+1]) > 0) then
     begin

       listing[i+3] := #9'sta :STACKORIGIN,x';

       listing[i+2] := copy(listing[i+1], 1, 5) + ':STACKORIGIN,x';

       listing[i] := #9'dex';
       listing[i+1] := #9'tya';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       tya(i) and										// tya					; 0
       and_ora_eor_stack(i+1) and								// and|ora|eor :STACKORIGIN,x		; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') then						// sta :STACKORIGIN,x			; 2
//       dex(i+3) then										// dex					; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin

       listing[i+3] := #9'sta :STACKORIGIN+1,x';

       listing[i+2] := copy(listing[i+1], 1, 5) + ':STACKORIGIN+1,x';

       listing[i] := #9'dex';
       listing[i+1] := #9'tya';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------
// andAL_CL

    if mva(i) and										// mva   :STACKORIGIN,x			; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       and_ora_eor_stack(i+2) and								// and|ora|eor :STACKORIGIN,x		; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1,x') then						// sta :STACKORIGIN-1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+2]) > 0) then
     begin

       listing[i+2] := copy(listing[i+2], 1, 5) + GetString(i);

       listing[i] := ''	 ;

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       (listing[i] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 0
       and_ora_eor_val(i+1) and									// and|ora|eor ~:STACKORIGIN		; 1
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') then						// sta :STACKORIGIN-1,x			; 2
//       dex(i+3) then										// dex					; 3
     begin
       listing[i+3] := #9'sta :STACKORIGIN,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := #9'lda :STACKORIGIN,x';
       listing[i] := #9'dex';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       and_ora_eor_val(i+1) and									// and|ora|eor ~:STACKORIGIN		; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') then						// sta :STACKORIGIN,x			; 2
//       dex(i+3) then										// dex					; 3
     begin
       listing[i+3] := #9'sta :STACKORIGIN+1,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := #9'lda :STACKORIGIN+1,x';
       listing[i]   := #9'dex';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       and_ora_eor_val(i+1) and									// and|ora|eor ~:STACKORIGIN		; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') then						// sta :STACKORIGIN,x			; 2
//       dex(i+3) then										// dex					; 3
     begin
       listing[i+3] := #9'sta :STACKORIGIN+1,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];
       listing[i]   := #9'dex';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       and_ora_eor_val(i+1) and									// and|ora|eor ~:STACKORIGIN		; 1
       (listing[i+2] = #9'sta :STACKORIGIN+1,x') then						// sta :STACKORIGIN+1,x			; 2
//       dex(i+3) then										// dex					; 3
     begin
       listing[i+3] := #9'sta :STACKORIGIN+2,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];
       listing[i]   := #9'dex';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       (listing[i] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 0
       and_ora_eor_stack(i+1) and								// and|ora|eor :STACKORIGIN,x		; 1
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') then						// sta :STACKORIGIN-1,x			; 2
//       dex(i+3) then										// dex					; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin

       listing[i+3] := #9'sta :STACKORIGIN,x';

       listing[i+2] := copy(listing[i+1], 1, 5) + ':STACKORIGIN+1,x';

       listing[i] := #9'dex';
       listing[i+1] := #9'lda :STACKORIGIN,x';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       and_ora_eor_stack(i+1) and								// and|ora|eor :STACKORIGIN+1,x		; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') then						// sta :STACKORIGIN,x			; 2
//       dex(i+3) then										// dex					; 3
     if (pos(':STACKORIGIN+1,x', listing[i+1]) > 0) then
     begin

       listing[i+3] := #9'sta :STACKORIGIN+1,x';

       listing[i+2] := copy(listing[i+1], 1, 5) + ':STACKORIGIN+2,x';

       listing[i] := #9'dex';
       listing[i+1] := #9'lda :STACKORIGIN+1,x';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------
// shlEAX

    if mva(i) and 										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       inx(i+2) and 										// inx					; 2
       (listing[i+3] = #9'mva #$10 :STACKORIGIN,x') and 					// mva #$10 :STACKORIGIN,x		; 3
       (listing[i+4] = #9'jsr shlEAX_CL.WORD') then 						// jsr shlEAX_CL.WORD			; 4
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
     	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
     begin

       listing[i+2] := #9'mva ' + GetString(i) + ' :STACKORIGIN+STACKWIDTH*2,x';
       listing[i+3] := #9'mva ' + GetString(i+1) + ' :STACKORIGIN+STACKWIDTH*3,x';
       listing[i+4] := #9'inx';

       listing[i]   := #9'mva #$00 :STACKORIGIN,x';
       listing[i+1] := #9'mva #$00 :STACKORIGIN+STACKWIDTH,x';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------
// array

    if mva(i) and 										// mva   :STACKORIGIN+STACKWIDTH	; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       add_sub(i+2) and 									// add|sub				; 2
       sta_a(i+3) and										// sta					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH		; 4
       adc_sbc(i+5) and 									// adc|sbc				; 5
       sta_a(i+6) then										// sta					; 6
     if (pos(':STACKORIGIN+STACKWIDTH,x', listing[i]) > 0) then
     begin
       listing[i+4] := #9'lda ' + GetString(i);

       listing[i] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_val(i+1) and (iy(i+1) = false) and							// lda					; 1	~:STACKORIGIN
       add_sub_val(i+2) and									// add|sub				; 2	~:STACKORIGIN
       (listing[i+3] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN			; 3
       lda_val(i+4) and (iy(i+4) = false) and							// lda					; 4	~:STACKORIGIN
       adc_sbc_val(i+5) and									// adc|sbc				; 5	~:STACKORIGIN
       (listing[i+6] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH		; 6
       (listing[i+7] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 7
       (listing[i+8] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 8
       sta_val(i+9) and										// sta					; 9	~:STACKORIGIN
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH		; 10
       sta_val(i+11) and									// sta					; 11	~:STACKORIGIN
       (lda_a(i+12) = false) then								//~lda					; 12
     begin
       listing[i+3] := listing[i+9];

       listing[i+6] := listing[i+11];

       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];

       if dex(i+12) then begin
        listing[i+1] := #9'ldy :STACKORIGIN,x';
	listing[i]   := '';

	listing[i+12] := '';
       end else
        listing[i+1] := #9'ldy :STACKORIGIN-1,x';

       listing[i+8]  := '';
       listing[i+9]  := '';
       listing[i+10] := '';
       listing[i+11] := '';

       exit(false);
     end;


    if sta_bp2_y(i+21) and									// sta (:bp2),y				; 21

       mva(i) and										// mva   :STACKORIGIN,x			; 0
       mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 3
       lda_val(i+4) and				 						// lda ~:STACKORIGIN			; 4
       add_sub(i+5) and 									// add|sub :STACKORIGIN-1,x		; 5
       sta_bp2(i+6) and										// sta :bp2				; 6
       lda_val(i+7) and										// lda ~:STACKORIGIN			; 7
       adc_sbc(i+8) and 									// adc|sbc :STACKORIGIN-1+STACKWIDTH,x	; 8
       sta_bp2_1(i+9) and									// sta :bp2+1				; 9
       ldy_im_0(i+10) and									// ldy #$00				; 10
       (listing[i+11] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 11
       sta_bp2_y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and										// iny					; 13
       (listing[i+14] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_bp2_y(i+15) and									// sta (:bp2),y				; 15
       iny(i+16) and										// iny					; 16
       (listing[i+17] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2	; 17
       sta_bp2_y(i+18) and									// sta (:bp2),y				; 18
       iny(i+19) and										// iny					; 19
       (listing[i+20] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') then				// lda :STACKORIGIN+STACKWIDTH*3	; 20
//       sta_bp2_y(i+21) then									// sta (:bp2),y				; 21
     if (pos(':STACKORIGIN-1,x', listing[i+5]) > 0) and
        (pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+8]) > 0) and
        (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) then
      begin
       listing[i+11] := #9'lda ' + GetSTRING(i);

       listing[i+14] := #9'lda ' + GetSTRING(i+1);

       listing[i+17] := #9'lda ' + GetSTRING(i+2);

       listing[i+20] := #9'lda ' + GetSTRING(i+3);

       listing[i]  := '';
       listing[i+1]:= '';
       listing[i+2]:= '';
       listing[i+3]:= '';

       exit(false);
      end;


    if sta_bp2_y(i+13) and									// sta (:bp2),y				; 13

       mva(i) and										// mva   :STACKORIGIN,x			; 0
       mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
       lda_val(i+2) and										// lda ~:STACKORIGIN			; 2
       add_sub(i+3) and 									// add|sub :STACKORIGIN-1,x		; 3
       sta_bp2(i+4) and										// sta :bp2				; 4
       lda_val(i+5) and										// lda ~:STACKORIGIN			; 5
       adc_sbc(i+6) and 									// adc|sbc :STACKORIGIN-1+STACKWIDTH,x	; 6
       sta_bp2_1(i+7) and									// sta :bp2+1				; 7
       ldy_im_0(i+8) and									// ldy #$00				; 8
       (listing[i+9] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 9
       sta_bp2_y(i+10) and									// sta (:bp2),y				; 10
       iny(i+11) and										// iny					; 11
       (listing[i+12] = #9'lda :STACKORIGIN+STACKWIDTH,x') then					// lda :STACKORIGIN+STACKWIDTH		; 12
//       sta_bp2_y(i+13) then									// sta (:bp2),y				; 13
     if (pos(':STACKORIGIN-1,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+6]) > 0) and
        (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
      begin
       listing[i+9] := #9'lda ' + GetSTRING(i);

       listing[i+12] := #9'lda ' + GetSTRING(i+1);

       listing[i]  := '';
       listing[i+1]:= '';

       exit(false);
      end;


    if mva(i) and										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 3
       inx(i+4) and										// inx					; 4
       lda_val(i+5) and										// lda					; 5
       add_sub_val(i+6) and									// add|sub ~:STACKORIGIN		; 6
       sta_val(i+7) and										// sta					; 7
       lda(i+8) and										// lda					; 8
       adc_sbc(i+9) and 									// adc|sbc				; 9
       sta(i+10) and										// sta					; 10
       lda(i+11) and										// lda					; 11
       adc_sbc(i+12) and 									// adc|sbc				; 12
       sta(i+13) and										// sta					; 13
       lda(i+14) and										// lda					; 14
       adc_sbc(i+15) and 									// adc|sbc				; 15
       sta(i+16) and										// sta					; 16
       (listing[i+17] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 17
       sta(i+18) and										// sta A				; 18
       (listing[i+19] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 19
       sta(i+20) and										// sta A+1				; 20
       (listing[i+21] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 21
       sta(i+22) and										// sta A+2				; 22
       (listing[i+23] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 23
       sta(i+24) then										// sta A+3				; 24
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) then
     begin

	listing[i+17] := #9'lda ' + GetString(i);

	listing[i+19] := #9'lda ' + GetString(i+1);

	listing[i+21] := #9'lda ' + GetString(i+2);

	listing[i+23] := #9'lda ' + GetString(i+3);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if dex(i+8) and										// dex					; 8

       lda_a(i) and										// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       lda_a(i+4) and										// lda A+2				; 4
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 5
       lda_a(i+6) and										// lda A+3				; 6
       (listing[i+7] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 7
//       dex(i+8) and										// dex					; 8
       (listing[i+9] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 9
       sta_val(i+10) and									// sta B				; 10
       (listing[i+11] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 11
       sta_val(i+12) and									// sta B+1				; 12
       (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 13
       sta_val(i+14) and									// sta B+2				; 14
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 15
       sta_val(i+16) then									// sta B+3				; 16
     begin
	listing[i+9]  := listing[i];

	listing[i+11] := listing[i+2];

	listing[i+13] := listing[i+4];

	listing[i+15] := listing[i+6];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

       exit(false);
     end;


    if dex(i+12) and										// dex					; 12

       lda_a(i) and										// lda					; 0
       and_ora_eor_val(i+1) and									// and|ora|eor				; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       lda_a(i+3) and										// lda					; 3
       and_ora_eor_val(i+4) and									// and|ora|eor				; 4	~:STACKORIGIN
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 5
       lda_a(i+6) and										// lda					; 6
       and_ora_eor_val(i+7) and									// and|ora|eor				; 7	~:STACKORIGIN
       (listing[i+8] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 8
       lda_a(i+9) and										// lda					; 9
       and_ora_eor_val(i+10) and								// and|ora|eor				; 10	~:STACKORIGIN
       (listing[i+11] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 11
//       dex(i+12) and										// dex					; 12
       (listing[i+13] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 13
       sta_val(i+14) and									// sta B				; 14
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 15
       sta_val(i+16) and									// sta B+1				; 16
       (listing[i+17] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 17
       sta_val(i+18) and									// sta B+2				; 18
       (listing[i+19] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 19
       sta_val(i+20) then									// sta B+3				; 20
     begin
	listing[i+2]  := listing[i+14];

	listing[i+5] := listing[i+16];

	listing[i+8] := listing[i+18];

	listing[i+11] := listing[i+20];

	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';

       exit(false);
     end;


    if (listing[i+12] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 12

       lda_a(i) and										// lda					; 0
       and_ora_eor_val(i+1) and									// and|ora|eor				; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda_a(i+3) and										// lda					; 3
       and_ora_eor_val(i+4) and									// and|ora|eor				; 4	~:STACKORIGIN
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       lda_a(i+6) and										// lda					; 6
       and_ora_eor_val(i+7) and									// and|ora|eor				; 7	~:STACKORIGIN
       (listing[i+8] = #9'sta :STACKORIGIN+STACKWIDTH*2,x') and					// sta :STACKORIGIN+STACKWIDTH*2,x	; 8
       lda_a(i+9) and										// lda					; 9
       and_ora_eor_val(i+10) and								// and|ora|eor				; 10	~:STACKORIGIN
       (listing[i+11] = #9'sta :STACKORIGIN+STACKWIDTH*3,x') and				// sta :STACKORIGIN+STACKWIDTH*3,x	; 11
//       (listing[i+12] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 12
       (listing[i+13] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 13
       sta_val(i+14) and									// sta					; 14	~:STACKORIGIN
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 15
       sta_val(i+16) and									// sta					; 16	~:STACKORIGIN
       (listing[i+17] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 17
       sta_val(i+18) and									// sta					; 18	~:STACKORIGIN
       (listing[i+19] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 19
       sta_val(i+20) then									// sta					; 20	~:STACKORIGIN
     begin
	listing_tmp[0] := listing[i+12];
	listing_tmp[1] := listing[i];
	listing_tmp[2] := listing[i+1];
	listing_tmp[3] := listing[i+14];
	listing_tmp[4] := listing[i+3];
	listing_tmp[5] := listing[i+4];
	listing_tmp[6] := listing[i+16];
	listing_tmp[7] := listing[i+6];
	listing_tmp[8] := listing[i+7];
	listing_tmp[9] := listing[i+18];
	listing_tmp[10]:= listing[i+9];
	listing_tmp[11]:= listing[i+10];
	listing_tmp[12]:= listing[i+20];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];
	listing[i+5] := listing_tmp[5];
	listing[i+6] := listing_tmp[6];
	listing[i+7] := listing_tmp[7];
	listing[i+8] := listing_tmp[8];
	listing[i+9] := listing_tmp[9];
	listing[i+10]:= listing_tmp[10];
	listing[i+11]:= listing_tmp[11];
	listing[i+12]:= listing_tmp[12];

	listing[i+13]:= '';
	listing[i+14]:= '';
	listing[i+15]:= '';
	listing[i+16]:= '';
	listing[i+17]:= '';
	listing[i+18]:= '';
	listing[i+19]:= '';
	listing[i+20]:= '';

        exit(false);
     end;


    if (listing[i+12] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 12

       (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       and_ora_eor_val(i+1) and									// and|ora|eor				; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       (listing[i+3] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 3
       and_ora_eor_val(i+4) and									// and|ora|eor				; 4	~:STACKORIGIN
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and					// lda :STACKORIGIN+STACKWIDTH*2,x	; 6
       and_ora_eor_val(i+7) and									// and|ora|eor				; 7	~:STACKORIGIN
       (listing[i+8] = #9'sta :STACKORIGIN+STACKWIDTH*2,x') and					// sta :STACKORIGIN+STACKWIDTH*2,x	; 8
       (listing[i+9] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and					// lda :STACKORIGIN+STACKWIDTH*3,x	; 9
       and_ora_eor_val(i+10) and								// and|ora|eor				; 10	~:STACKORIGIN
       (listing[i+11] = #9'sta :STACKORIGIN+STACKWIDTH*3,x') and				// sta :STACKORIGIN+STACKWIDTH*3,x	; 11
//       (listing[i+12] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 12

       (listing[i+13] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 13
       and_ora_eor(i+14) and									// and|ora|eor				; 14
       sta_val(i+15) and									// sta					; 15	~:STACKORIGIN
       (listing[i+16] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 16
       and_ora_eor(i+17) and									// and|ora|eor				; 17
       sta_val(i+18) and									// sta					; 18	~:STACKORIGIN
       (listing[i+19] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 19
       and_ora_eor(i+20) and									// and|ora|eor				; 20
       sta_val(i+21) and									// sta					; 21	~:STACKORIGIN
       (listing[i+22] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 22
       and_ora_eor(i+23) and									// and|ora|eor				; 23
       sta_val(i+24) then									// sta					; 24	~:STACKORIGIN
     begin
	listing_tmp[0] := listing[i+12];

	listing_tmp[1] := listing[i];
	listing_tmp[2] := listing[i+1];
	listing_tmp[3] := listing[i+14];
	listing_tmp[4] := listing[i+15];

	listing_tmp[5] := listing[i+3];
	listing_tmp[6] := listing[i+4];
	listing_tmp[7] := listing[i+17];
	listing_tmp[8] := listing[i+18];

	listing_tmp[9] := listing[i+6];
	listing_tmp[10]:= listing[i+7];
	listing_tmp[11]:= listing[i+20];
	listing_tmp[12]:= listing[i+21];

	listing_tmp[13]:= listing[i+9];
	listing_tmp[14]:= listing[i+10];
	listing_tmp[15]:= listing[i+23];
	listing_tmp[16]:= listing[i+24];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];
	listing[i+5] := listing_tmp[5];
	listing[i+6] := listing_tmp[6];
	listing[i+7] := listing_tmp[7];
	listing[i+8] := listing_tmp[8];
	listing[i+9] := listing_tmp[9];
	listing[i+10]:= listing_tmp[10];
	listing[i+11]:= listing_tmp[11];
	listing[i+12]:= listing_tmp[12];
	listing[i+13]:= listing_tmp[13];
	listing[i+14]:= listing_tmp[14];
	listing[i+15]:= listing_tmp[15];
	listing[i+16]:= listing_tmp[16];

	listing[i+17]:= '';
	listing[i+18]:= '';
	listing[i+19]:= '';
	listing[i+20]:= '';
	listing[i+21]:= '';
	listing[i+22]:= '';
	listing[i+23]:= '';
	listing[i+24]:= '';

        exit(false);
     end;


    if dex(i+4) and										// dex					; 4

       lda_a(i) and										// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
//       dex(i+4) and										// dex					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_val(i+6) and										// sta B				; 6
       (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       sta_val(i+8) then									// sta B+1				; 8
     begin
	listing[i+5] := listing[i];

	listing[i+7] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if dex(i+12) and										// dex					; 12

       lda_val(i) and										// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       lda_val(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       lda_val(i+4) and										// lda A+2				; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH*2,x') and					// sta :STACKORIGIN+STACKWIDTH*2,x	; 5
       lda_val(i+6) and										// lda A+3				; 6
       (listing[i+7] = #9'sta :STACKORIGIN+STACKWIDTH*3,x') and					// sta :STACKORIGIN+STACKWIDTH*3,x	; 7
       (listing[i+8] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 8
       sta_val(i+9) and										// sta B				; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_val(i+11) then									// sta B+1				; 11
//       dex(i+12) then										// dex					; 12
     begin
	listing[i+1] := listing[i+9];

	listing[i+3] := listing[i+11];
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------
// expand

    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and										// mva   :STACKORIGIN-1+STACKWIDTH	; 2
       mva(i+3) and 										// mva   :STACKORIGIN-1+STACKWIDTH*2	; 3
       mva(i+4) then 										// mva   :STACKORIGIN-1+STACKWIDTH*3	; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH*2,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH*3,x', listing[i+4]) > 0) then
      begin

	listing_tmp[0] := #9'mva ' + GetString(i+2) + ' :STACKORIGIN+STACKWIDTH,x';
	listing_tmp[1] := #9'mva ' + GetString(i+3) + ' :STACKORIGIN+STACKWIDTH*2,x';
	listing_tmp[2] := #9'mva ' + GetString(i+4) + ' :STACKORIGIN+STACKWIDTH*3,x';
	listing_tmp[3] := #9'inx';
	listing_tmp[4] := listing[i+1];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];

	exit(false);
      end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN-1+STACKWIDTH	; 2
       mva(i+3) then 										// mva   :STACKORIGIN+STACKWIDTH	; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+3]) > 0) then
      begin

	listing_tmp[0] := #9'mva ' + GetString(i+2) + ' :STACKORIGIN+STACKWIDTH,x';
	listing_tmp[1] := #9'inx';
	listing_tmp[2] := listing[i+1];
	listing_tmp[3] := listing[i+3];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];

	exit(false);
      end;


// ----------------------------------------------------------------------------------------------------------------------------------------


    if mva(i) and (pos(' :STACK', listing[i]) > 0) and						// mva YY+3 :STACKORIGIN+STACKWIDTH*3,x	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH*3,x	; 1
       and_ora_eor(i+2) and									// and|ora|eor				; 2
       sta_stack(i+3) then									// sta :STACKORIGIN+STACKWIDTH*3,x	; 3
     if argMatch(i+1, i+3) and
	(pos(copy(listing[i+1], 6, 256), listing[i]) > 0) then
      begin
	listing[i]   := #9'lda ' + GetString(i);
	listing[i+1] := '';

	exit(false);
      end;


    if mva(i) and 										// mva YY :STACKORIGIN,x		; 0
       mva(i+1) and										// mva YY+1 :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'jsr @hiWORD') then							// jsr @hiWORD				; 2
     if (pos(' :STACKORIGIN,x', listing[i]) > 0) and
        (pos(' :STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
      begin
	listing[i]   := #9'mva ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6) + ':STACKORIGIN,x';

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if tay(i+7) and										// tay					; 7

       lda(i) and (listing[i] = listing[i+5]) and						// lda I				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       mva(i+3) and										// mva xxxx :STACKORIGIN,x		; 3
       inx(i+4) and										// inx					; 4
       lda(i+5) and										// lda I				; 5
       asl_a(i+6) then										// asl @				; 6
//       tay(i+7) then										// tay					; 7
      begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
      end;


    if tay(i+8) and										// tay					; 8

       lda(i) and (listing[i] = listing[i+6]) and						// lda I				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda(i+3) and										// lda					; 3
       sta(i+4) and										// sta					; 4
       inx(i+5) and										// inx					; 5
       lda(i+6) and										// lda I				; 6
       asl_a(i+7) then										// asl @				; 7
//       tay(i+8) then										// tay					; 8
      begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// ===		 	    ABSOLUTE BP. :STACK
// -----------------------------------------------------------------------------

     if (mva(i) = false) and									// inx					; 0
        mva(i+1) and										// mva N :STACKORIGIN,x			; 1
	mva(i+2) and										// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 2
	((pos('+', listing[i+3]) = 1) or (pos('-', listing[i+3]) = 1)) then			//+-S					; 3
      begin
       tmp := listing[i+3];

       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := tmp;

       exit(false);
      end;


    if (pos('+', listing[i]) = 1) or (pos('-', listing[i]) = 1) then begin

     tmp:=copy(listing[i], 2, 256);

     yes:=false;

     for p:=i+1 to l-1 do
      if mwy_bp2(p) and (listing[p] = #9'mwy '+tmp+' :bp2') then listing[p] := '' else
       if pos('(:bp2),y', listing[p]) > 0 then begin

        if pos('mva (:bp2),y', listing[p]) > 0 then
         listing[p] := copy(listing[p], 1, 5) + '('+tmp+'),y' + copy(listing[p], 14, 256)
	else
         listing[p] := copy(listing[p], 1, 5) + '('+tmp+'),y';

	yes:=true;
       end else
        if ((pos('+', listing[p]) = 1) or (pos('-', listing[p]) = 1)) then begin

	  if length(listing[p]) = 1 then listing[p] := '';

	  Break;

	end;

     if yes then begin
      listing[i] := '';

      exit(false);
     end;

    end;


// -----------------------------------------------------------------------------


     if mva(i) and										// mva   :STACKORIGIN,x			; 0
        mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
        inx(i+2) and										// inx					; 2
	mva(i+3) and										// mva   :STACKORIGIN,x			; 3
	(listing[i+4] = #9'jsr imulBYTE') then							// jsr imulBYTE				; 4
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN,x', listing[i+3]) > 0) then
      begin
       listing[i+1] := '';

       exit(false);
      end;


     if mva(i) and										// mva   :STACKORIGIN,x			; 0
        mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
	mva(i+2) and										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 2
	mva(i+3) and										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 3
	(listing[i+4] = #9'jsr @expandToREAL') then						// jsr @expandToReal			; 4
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) then
      begin
       listing_tmp[0] := #9'mva ' + GetSTRING(i+2) + ' :STACKORIGIN+STACKWIDTH*3,x';
       listing_tmp[1] := #9'mva ' + GetSTRING(i+1) + ' :STACKORIGIN+STACKWIDTH*2,x';
       listing_tmp[2] := #9'mva ' + GetSTRING(i) + ' :STACKORIGIN+STACKWIDTH,x';
       listing_tmp[3] := #9'mva #$00 :STACKORIGIN,x';

       listing[i]  := listing_tmp[3];
       listing[i+1]:= listing_tmp[2];
       listing[i+2]:= listing_tmp[1];
       listing[i+3]:= listing_tmp[0];
       listing[i+4]:= '';

       exit(false);
      end;

end;		// function
