
function opt_CMP_0(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===		     		      CMP_0.
// -----------------------------------------------------------------------------

    if cmp(i) and										// cmp				; 0
       lab_a(i+1) and 										//@				; 1
       (jeq(i+2) or jne(i+2)) and 								// jeq|jne			; 2
       lab_a(i+3) then 										//@				; 3
     begin
      listing[i+3] := '';

      exit(false);
     end;


    if lda_im(i) and 										// lda #$			; 0
       add_im(i+1) and										// add #$			; 1
       sta(i+2) and										// sta				; 2
												//				; 3
       (adc(i+4) = false) then									//~adc				; 4
     begin

      p := GetBYTE(i) + GetBYTE(i+1);

      listing[i]   := #9'lda #' + Hex(p and $ff, 2);
      listing[i+1] := '';

      exit(false);
     end;


    if lda_im(i) and 										// lda #$			; 0
       sub_im(i+1) and										// sub #$			; 1
       sta(i+2) and										// sta				; 2
												//				; 3
       (sbc(i+4) = false) then									//~sbc				; 4
     begin

      p := GetBYTE(i) - GetBYTE(i+1);

      listing[i]   := #9'lda #' + Hex(p and $ff, 2);
      listing[i+1] := '';

      exit(false);
     end;


    if lda(i) and										// lda				; 0
       ldy_1(i+1) and										// ldy #1			; 1
       and_im_0(i+2) and									// and #$00			; 2
       bne(i+3) and										// bne @+			; 3
       lda(i+4) then										// lda				; 4
     begin
	listing[i] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if (i>0) and and_im_0(i) then								// lda #$00			; -1
     if lda_im_0(i-1) then begin								// and #$00			; 0
	listing[i] := '';

	exit(false);
     end;


    if (i>0) and ora(i) then									// lda #$00			; -1
     if lda_im_0(i-1) then begin								// ora				; 0
	listing[i] := #9'lda ' + copy(listing[i], 6, 256);

	exit(false);
     end;


    if lda_im_0(i) and										// lda #$00			; 0
       bne(i+1) and										// bne				; 1
       lda(i+2) then										// lda				; 2
     begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if lda(i) and										// lda A			; 0
       SKIP(i+1) and										// SKIP				; 1
       lda(i+2) and										// lda A			; 2
       (listing[i] = listing[i+2]) then
     begin
	listing[i+2] := '';

	exit(false);
     end;


    if (lda_a(i) or adc_sbc(i)) and								// lda|adc|sbc			; 0
       (eor_im_0(i+1) or ora_im_0(i+1)) and							// eor|ora #$00			; 1
       SKIP(i+2) then										// SKIP				; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if and_ora_eor(i) and									// and|ora|eor			; 0
       (eor_im_0(i+1) or ora_im_0(i+1)) and							// eor|ora #$00			; 1
       SKIP(i+2) then										// SKIP				; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+9		; 0
       iny(i+1) and										// iny				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+9		; 2
       cmp(i+3) then										// cmp				; 3
     if argMatch(i, i+2) then
       begin
	listing[i]   := '';

	listing[i+2] := '';

	exit(false);
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+9		; 0
       lda(i+1) and										// lda				; 1	~lda adr.
       AND_ORA_EOR_STACK(i+2) then 								// ora|and|eor :STACKORIGIN+9	; 2
     if argMatch(i, i+2) then
       begin
	listing[i]   := '';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
       end;


    if sty_stack(i) and										// sty :STACKORIGIN+10		; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+9		; 1
       AND_ORA_EOR_STACK(i+2) and								// ora|and|eor :STACKORIGIN+10	; 2
       sta_stack(i+3) then									// sta :STACKORIGIN+9		; 3
       if argMatch(i, i+2) and
          argMatch(i+1, i+3) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
       end;


    if sty_stack(i) and										// sty :STACKORIGIN+10		; 0
       lda(i+1) and										// lda 				; 1	~lda adr.
       add_stack(i+2) and									// add :STACKORIGIN+10		; 2
       sta(i+3) then										// sta				; 3
       if argMatch(i, i+2) then
       begin
	listing[i]   := #9'tya';
	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN		; 1
       AND_ORA_EOR(i+2) and (and_ora_eor_stack(i+2) = false) and				// ora|and|eor			; 2
       sta_stack(i+3) and									// sta :STACKORIGIN		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH	; 4
       bne(i+5) and										// bne @+			; 5
       lda_stack(i+6) then									// lda :STACKORIGIN		; 6
       if argMatch(i, i+4) and
          argMatch(i+1, i+3) and
          argMatch(i+3, i+6) then
       begin
	listing[i]   := listing[i+5];

//	listing[i+3] := '';

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
       end;


    if (and_ora_eor(i) or asl_a(i) or rol_a(i) or lsr_a(i) or ror_a(i)) and (iy(i) = false) and	// and|ora|eor			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+N		; 1
       ldy_1(i+2) and										// ldy #1			; 2
       lda_stack(i+3) and 									// lda :STACKORIGIN+N		; 3
       (bne(i+4) or beq(i+4)) then								// bne|beq			; 4
     if argMatch(i+1, i+3) then
      begin
       listing[i+1] := '';
       listing[i+3] := listing[i];
       listing[i]   := '';

       exit(false);
      end;


    if (sty_stack(i) or sta_stack(i)) and							// sty|sta :STACKORIGIN		; 0
       mva_stack(i+1) and									// mva :STACKORIGIN STOP	; 1
       (copy(listing[i], 6, 256) = GetString(i+1)) then
     begin
	listing[i+1] := copy(listing[i], 1, 5) + copy(listing[i+1], length(GetString(i+1)) + 7, 256);
	listing[i]   := '';

	exit(false);
     end;


end;		// function
