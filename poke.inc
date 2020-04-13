
// -----------------------------------------------------------------------------
// ===			optymalizacja POKE.				  === //
// -----------------------------------------------------------------------------

  if ((pos(listing[i], listing[i+3]) > 0) or ((pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0))) and
     lda(i) and (lda_stack(i) = false) and (lda_im(i) = false) and				// lda T			; 0
     add(i+1) and										// add				; 1
     tay(i+2) and										// tay				; 2
     lda(i+3) and										// lda T+1			; 3
     adc_im_0(i+4) and										// adc #$00			; 4
     sta_bp_1(i+5) then										// sta :bp+1			; 5
   begin

    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       (sta(i+7) or lsr_a(i+7) or asl_a(i+7)) and (pos(' :STACK', listing[i+7]) = 0) then	// lsr @|asl @|sta|sta (:bp),y	; 7
       begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if sta_bp_y(i+7) then listing[i+7] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
       end;


    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       sta_stack(i+7) and									// sta :STACKORIGIN		; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH	; 8
       sta_bp_1(i+9) then									// sta :bp+1			; 9
    if copy(listing[i+7], 6, 256) <> copy(listing[i+8], 6, 256) then
       begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
       end;
       
       
    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       tay(i+7) and										// tay				; 7
       lda(i+8) and										// lda 				; 8
       sta(i+9) then										// sta 				; 9
    if copy(listing[i+7], 6, 256) <> copy(listing[i+8], 6, 256) then
       begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if lda_bp_y(i+8) then listing[i+8] := #9'lda (:bp2),y';
	if sta_bp_y(i+9) then listing[i+9] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
       end;


    if lda(i+6) and (lda_bp_y(i+6) = false) and	(lda_stack(i+6) = false) and			// lda				; 6
       (and_ora_eor(i+7) or add_sub(i+7)) and ((pos(' (:bp),y', listing[i+7]) > 0)) and		// and|ora|eor|add|sub (:bp),y	; 7
       sta(i+8) and (sta_bp_y(i+8) = false) and (sta_stack(i+8) = false) then			// sta				; 8
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);

	listing[i+7] := copy(listing[i+7], 1, 5) + '(:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;


    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       and_ora_eor(i+7) and									// and|ora|eor			; 7
       ((sta(i+8) and (sta_stack(i+8) = false)) or cmp(i+8)) then				// cmp|sta|sta (:bp),y		; 8
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';
	if cmp_bp_y(i+8) then listing[i+8] := #9'cmp (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;


    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       cmp(i+7) then										// cmp				; 7
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if cmp_bp_y(i+7) then listing[i+7] := #9'cmp (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;
      

    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       and_ora_eor(i+7) and									// and|ora|eor			; 7
       sta_stack(i+8) and									// sta :STACKORIGIN		; 8
       (mwy_bp2(i+9) or mwa_bp2(i+9)) then							// mwy|mwa ... :bp2		; 9
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;


    if lda(i+6) and 										// lda 				; 6
       sta(i+7) and (sta_stack(i+7) = false) then 						// sta|sta (:bp),y		; 7
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);

	if sta_bp_y(i+7) then listing[i+7] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;

  end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


  if ((pos(listing[i], listing[i+4]) > 0) or ((pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+4]) > 0))) and
     lda(i) and (lda_stack(i) = false) and (lda_im(i) = false) and				// lda T			; 0
     add(i+1) and										// add				; 1
     sta_stack(i+2) and										// sta :STACKORIGIN		; 2
     tay(i+3) and										// tay				; 3
     lda(i+4) and										// lda T+1			; 4
     adc_im_0(i+5) and										// adc #$00			; 5
     sta_bp_1(i+6) then										// sta :bp+1			; 6
   begin

    if lda_bp_y(i+7) and									// lda (:bp),y			; 7
       ldy_stack(i+8) and									// ldy :STACKORIGIN		; 8
       sta(i+9) and (sta_stack(i+9) = false) then						// sta|sta (:bp),y		; 9
    if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';
	listing[i+7] := '';
	listing[i+8] := '';

	if sta_bp_y(i+9) then listing[i+9] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;


    if lda_bp_y(i+7) and									// lda (:bp),y			; 7
       (and_ora_eor(i+8) or add_sub(i+8)) and							// and|ora|eor|add|sub		; 8
       ldy_stack(i+9) and									// ldy :STACKORIGIN		; 9
       sta(i+10) and (sta_stack(i+10) = false) then						// sta|sta (:bp),y		; 10
    if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';
	listing[i+7] := '';

        listing[i+9]  := '';

	if sta_bp_y(i+10) then listing[i+10] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;

  end;

