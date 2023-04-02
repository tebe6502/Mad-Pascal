// -----------------------------------------------------------------------------
// ===				      LSR.
// -----------------------------------------------------------------------------

    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_im_0(i+1) and									// lda #$00				; 1
       (adc_im_0(i+2) or sbc_im_0(i+2)) and							// adc|sbc #$00				; 2
       lsr_a(i+3) and										// lsr @				; 3
       ror_stack(i+4) and									// ror :STACKORIGIN			; 4
       lda_stack(i+5) and									// lda :STACKORIGIN			; 5
       sta(i+6) then										// sta					; 6
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
      listing[i] := listing[i+6];

      listing[i+4] := #9'ror ' + copy(listing[i+6], 6, 256);
      listing[i+5] := '';
      listing[i+6] := '';

      Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_im_0(i+1) and									// lda #$00				; 1
       (adc_im_0(i+2) or sbc_im_0(i+2)) and							// adc|sbc #$00				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_im_0(i+4) and									// lda #$00				; 4
       (adc_im_0(i+5) or sbc_im_0(i+5)) and							// adc|sbc #$00				; 5
       lsr_a(i+6) and										// lsr @				; 6
       ror_stack(i+7) and									// ror :STACKORIGIN+STACKWIDTH		; 7
       ror_stack(i+8) and									// ror :STACKORIGIN			; 8
       lda_stack(i+9) and									// lda :STACKORIGIN			; 9
       sta(i+10) and										// sta					; 10
       lda_stack(i+11) then									// lda :STACKORIGIN+STACKWIDTH		; 11
     if (copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+8], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := #9'lsr @';
      listing[i+7] := listing[i+8];
      listing[i+8] := listing[i+3];

      Result:=false; Break;
     end;


    if lda_a(i) and										// lda					; 0
       lsr_stack(i+1) and									// lsr :STACKORIGIN			; 1
       ror_stack(i+2) and									// ror :STACKORIGIN+STACKWIDTH		; 2
       lsr_stack(i+3) then									// lsr :STACKORIGIN			; 3
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if lda(i) and 										// lda					; 0
       adc_sbc(i+1) and										// adc|sbc				; 1
       lsr_stack(i+2) and									// lsr :STACKORIGIN+STACKWIDTH*2+9	; 2
       ror_stack(i+3) and									// ror :STACKORIGIN+STACKWIDTH+9	; 3
       ror_stack(i+4) and									// ror :STACKORIGIN+9			; 4
       lda_stack(i+5) then									// lda :STACKORIGIN+9			; 5
     if (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
      listing[i]   := '';
      listing[i+1] := '';

      Result:=false; Break;
     end;


    if lsr_a(i) and		 								// lsr @				; 0
       ror_stack(i+1) and									// ror :STACKORIGIN+STACKWIDTH*3	; 1
       ror_stack(i+2) and									// ror :STACKORIGIN+STACKWIDTH*2	; 2
       ror_stack(i+3) and									// ror :STACKORIGIN+STACKWIDTH*1	; 3
       sta_im_0(i+4) then									// sta #$00				; 4
     begin

	p:=0;
	while (listing[i] = listing[i-p*4]) and (listing[i+1] = listing[i+1-p*4]) and
	      (listing[i+2] = listing[i+2-p*4]) and (listing[i+3] = listing[i+3-p*4]) do inc(p);

	if lda_a(i+3-p*4) or tya(i+3-p*4) then begin
	 if iy(i+3-p*4) and (ldy(i+2-p*4) or iny(i+2-p*4)) then listing[i+2-p*4] := '';
	 listing[i+3-p*4] := '';
	end;

	dec(p);
	while p>=0 do begin
	 listing[i-p*4] := '';
	 listing[i+1-p*4] := #9'lsr ' + copy(listing[i+1-p*4], 6, 256) ;
	 dec(p);
	end;

	listing[i+4] := '';
	Result:=false; Break;
     end;


    if lsr_a(i) and		 								// lsr @				; 0
       ror_stack(i+1) and									// ror :STACKORIGIN+STACKWIDTH*3	; 1
       ror_stack(i+2) and									// ror :STACKORIGIN+STACKWIDTH*2	; 2
       sta_im_0(i+3) then									// sta #$00				; 3
     begin

	p:=0;
	while (listing[i] = listing[i-p*3]) and (listing[i+1] = listing[i+1-p*3]) and
	      (listing[i+2] = listing[i+2-p*3]) do inc(p);

	if lda_a(i+2-p*3) or tya(i+2-p*3) then begin
	 if iy(i+2-p*3) and (ldy(i+1-p*3) or iny(i+1-p*3)) then listing[i+1-p*3] := '';
	 listing[i+2-p*3] := '';
	end;

	dec(p);
	while p>=0 do begin
	 listing[i-p*3] := '';
	 listing[i+1-p*3] := #9'lsr ' + copy(listing[i+1-p*3], 6, 256) ;
	 dec(p);
	end;

	listing[i+3] := '';
	Result:=false; Break;
     end;


    if lsr_a(i) and		 								// lsr @				; 0
       ror_stack(i+1) and									// ror :STACKORIGIN+STACKWIDTH*3	; 1
       sta_im_0(i+2) then									// sta #$00				; 2
     begin

	p:=0;
	while (listing[i] = listing[i-p*2]) and (listing[i+1] = listing[i+1-p*2]) do inc(p);

	if lda_a(i+1-p*2) or tya(i+1-p*2) then begin
	 if iy(i+1-p*2) and (ldy(i-p*2) or iny(i-p*2)) then listing[i-p*2] := '';
	 listing[i+1-p*2] := '';
	end;

	dec(p);
	while p>=0 do begin
	 listing[i-p*2] := '';
	 listing[i+1-p*2] := #9'lsr ' + copy(listing[i+1-p*2], 6, 256) ;
	 dec(p);
	end;

	listing[i+2] := '';
	Result:=false; Break;
     end;


    if lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and (lda_im_0(i+4) = false) and						// lda					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lsr_stack(i+6) and									// lsr :STACKORIGIN+STACKWIDTH*2	; 6
       ror_stack(i+7) and									// ror :STACKORIGIN+STACKWIDTH		; 7
       ror_stack(i+8) then									// ror :STACKORIGIN			; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	tmp := listing[i+4];
	listing[i+4] := listing[i];
	listing[i] := tmp;

	tmp := listing[i+5];
	listing[i+5] := listing[i+1];
	listing[i+1] := tmp;

	p:=i+6;
	while (listing[p]=listing[p+3]) and (listing[p+1]=listing[p+4]) and (listing[p+2]=listing[p+5]) do inc(p, 3);

	if lda_stack(p+3) and
	   (copy(listing[p+2], 6, 256) = copy(listing[p+3], 6, 256)) then begin

		listing[p+3] := '';
		listing[i+5] := '';

		p:=i+6;
		while (listing[p]=listing[p+3]) and (listing[p+1]=listing[p+4]) and (listing[p+2]=listing[p+5]) do begin
		 listing[p+2] := #9'ror @';
		 inc(p, 3);
		end;

		listing[p+2] := #9'ror @';
	end;

	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       sty_stack(i+1) and									// sty :STACKORIGIN+STACKWIDTH*2	; 1
       lsr_stack(i+2) and									// lsr :STACKORIGIN+STACKWIDTH*2	; 2
       ror_stack(i+3) and									// ror :STACKORIGIN+STACKWIDTH		; 3
       ror_stack(i+4) and									// ror :STACKORIGIN			; 4
       lda_stack(i+5) and									// lda :STACKORIGIN			; 5
       sta(i+6) and										// sta					; 6
       (lda(i+7) = false) then									// ~lda					; 7
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
	listing[i+1]:='';
	listing[i+2]:='';

	listing[i+3] := #9'lsr ' + copy(listing[i+3], 6, 256);

	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       sty_stack(i+1) and									// sty :STACKORIGIN+STACKWIDTH*2	; 1
       sty_stack(i+2) and									// sty :STACKORIGIN+STACKWIDTH*3	; 2
       lsr_stack(i+3) and									// lsr :STACKORIGIN+STACKWIDTH*3	; 3
       ror_stack(i+4) and									// ror :STACKORIGIN+STACKWIDTH*2	; 4
       ror_stack(i+5) and									// ror :STACKORIGIN+STACKWIDTH		; 5
       ror_stack(i+6) and									// ror :STACKORIGIN			; 6
       lda_stack(i+7) and									// lda :STACKORIGIN			; 7
       sta(i+8) and										// sta					; 8
       (lda(i+9) = false) then									// ~lda					; 9
     if (copy(listing[i+6], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i+1]:='';
	listing[i+2]:='';
	listing[i+3]:='';
	listing[i+4]:='';

	listing[i+5] := #9'lsr ' + copy(listing[i+5], 6, 256);

	Result:=false; Break;
     end;


    if lda(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lsr_stack(i+4) and									// lsr :STACKORIGIN+STACKWIDTH		; 4
       ror_stack(i+5) and									// ror :STACKORIGIN			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       sta(i+7) then										// sta					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+1] := listing[i+3];
	listing[i+3] := listing[i];
	listing[i]   := listing[i+2];
	listing[i+2] := '';

	listing[i+5] := #9'ror @';
	listing[i+6] := '';

	Result:=false; Break;
     end;


    if lda(i) and										// lda W+1				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda(i+2) and										// lda W				; 2
       lsr_stack(i+3) and									// lsr :STACKORIGIN+STACKWIDTH		; 3
       ror_a(i+4) and										// ror @				; 4
       sta(i+5) and										// sta W				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       sta(i+7) then										// sta W+1				; 7
     if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	listing[i]   := #9'lsr ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'ror ' + copy(listing[i+2], 6, 256);
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false; Break;
     end;


    if lda(i) and										// lda W				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda W+1				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and										// lda W+2				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda(i+6) and										// lda W+3				; 6
       lsr_a(i+7) and										// lsr @				; 7
       ror_stack(i+8) and									// ror :STACKORIGIN+STACKWIDTH*2	; 8
       ror_stack(i+9) and									// ror :STACKORIGIN+STACKWIDTH		; 9
       ror_stack(i+10) and									// ror :STACKORIGIN			; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta(i+13) and										// sta W				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       sta(i+15) and										// sta W+1				; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*2	; 16
       sta(i+17) and										// sta W+2				; 17
       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH*3	; 18
       sta(i+19) then										// sta W+3				; 19
     if (copy(listing[i], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then
     begin
	listing[i+3] := #9'ror ' + copy(listing[i], 6, 256);

	listing[i]   := #9'lsr ' + copy(listing[i+6], 6, 256);
	listing[i+1] := #9'ror ' + copy(listing[i+4], 6, 256);
	listing[i+2] := #9'ror ' + copy(listing[i+2], 6, 256);

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

	Result:=false; Break;
     end;


    if lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and										// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lsr_stack(i+9) and									// lsr :STACKORIGIN+STACKWIDTH*2	; 9
       ror_stack(i+10) and									// ror :STACKORIGIN+STACKWIDTH		; 10
       ror_stack(i+11) and									// ror :STACKORIGIN			; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta(i+13) and										// sta 					; 13
       (lda_stack(i+14) = false) then								// ~lda :STACKORIGIN+STACKWIDTH		; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	listing[i+10] := #9'lsr ' + copy(listing[i+10], 6, 256);

	Result:=false; Break;
     end;


    if lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and										// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       lsr_a(i+8) and										// lsr @				; 8
       ror_stack(i+9) and									// ror :STACKORIGIN+STACKWIDTH		; 9
       ror_stack(i+10) and									// ror :STACKORIGIN			; 10
       lda_stack(i+11) and									// lda :STACKORIGIN			; 11
       sta(i+12) and (sta_stack(i+12) = false) and						// sta 					; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH		; 13
       sta(i+14) and (sta_stack(i+14) = false) then						// sta					; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+10], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
	listing[i+2] := listing[i+12];

	listing[i+5] := listing[i+14];

	listing[i+9]  := #9'ror ' + copy(listing[i+14], 6, 256);
	listing[i+10] := #9'ror ' + copy(listing[i+12], 6, 256);

	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';

	Result:=false; Break;
     end;


    if lda_im_0(i) and										// lda #$00				; 0
       (pos('sta :STACKORIGIN+STACKWIDTH*2', listing[i+1]) > 0) and				// sta :STACKORIGIN+STACKWIDTH*2	; 1
       lsr_a(i+2) and										// lsr @				; 2
       (pos('ror :STACKORIGIN+STACKWIDTH*2', listing[i+3]) > 0) and				// ror :STACKORIGIN+STACKWIDTH*2	; 3
       ror_stack(i+4) and									// ror :STACKORIGIN+STACKWIDTH		; 4
       ror_stack(i+5) and									// ror :STACKORIGIN			; 5
       sta(i+6) then										// sta					; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i]   := #9'lsr ' + copy(listing[i+4], 6, 256);
	listing[i+1] := listing[i+5];
	listing[i+2] := #9'lda #$00';
	listing[i+3] := #9'sta ' + copy(listing[i+3], 6, 256);
	listing[i+4] := #9'lda #$00';
	listing[i+5] := listing[i+6];
	listing[i+6] := '';

	Result:=false; Break;
     end;


    if lda_im_0(i) and										// lda #$00				; 0
       (pos('sta :STACKORIGIN+STACKWIDTH*2', listing[i+1]) > 0) and				// sta :STACKORIGIN+STACKWIDTH*2	; 1
       (pos('lsr :STACKORIGIN+STACKWIDTH*2', listing[i+2]) > 0) and				// lsr :STACKORIGIN+STACKWIDTH*2	; 2
       ror_stack(i+3) and									// ror :STACKORIGIN+STACKWIDTH		; 3
       ror_stack(i+4) then									// ror :STACKORIGIN			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := #9'lsr ' + copy(listing[i+3], 6, 256);
	listing[i+1] := listing[i+4];

	listing[i+3] := #9'lda #$00';
	listing[i+4] := #9'sta ' + copy(listing[i+2], 6, 256);

	listing[i+2] := '';

	Result:=false; Break;
     end;


    if (pos('lsr :STACKORIGIN+STACKWIDTH*2', listing[i]) > 0) and				// lsr :STACKORIGIN+STACKWIDTH*2	; 0
       (pos('ror :STACKORIGIN+STACKWIDTH', listing[i+1]) > 0 ) and				// ror :STACKORIGIN+STACKWIDTH		; 1
       (listing[i+2] = #9'ror @') and								// ror @				; 2
       ora(i+3) and										// ora					; 3
       sta(i+4) and										// sta 					; 4
       (lda(i+5) = false) then									// ~lda 				; 5
     begin
        listing[i]   := '';
	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	Result:=false; Break;
     end;


    if (pos('lsr :STACKORIGIN+STACKWIDTH*2', listing[i]) > 0) and				// lsr :STACKORIGIN+STACKWIDTH*2	; 0
       (pos('ror :STACKORIGIN+STACKWIDTH', listing[i+1]) > 0 ) and				// ror :STACKORIGIN+STACKWIDTH		; 1
       (listing[i+2] = #9'ror @') and								// ror @				; 2
       (pos('lsr :STACKORIGIN+STACKWIDTH', listing[i+3]) > 0 ) and				// lsr :STACKORIGIN+STACKWIDTH		; 3
       (listing[i+4] = #9'ror @') then								// ror @				; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
        listing[i]   := '';
	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	Result:=false; Break;
     end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda TEMP				; 0
       lsr_a(i+1) and										// lsr @				; 1
       sta_a(i+2) then										// sta TEMP				; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i] := #9'lsr ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lsr_a(i+1) and										// lsr @				; 1
       sta_stack(i+2) then									// sta :STACKORIGIN			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lsr_a(i+1) and										// lsr @				; 1
       lsr_a(i+2) and										// lsr @				; 2
       sta_stack(i+3) then									// sta :STACKORIGIN			; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i] := '';

	Result:=false; Break;
     end;


    if lda_a(i) and										// lda B+1				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_a(i+2) and										// lda B				; 2
       ldy(i+3) and										// ldy 					; 3
       beq(i+4) and										// beq					; 4
       (pos('l_', listing[i+5]) = 1) and							//l_					; 5
       lsr_stack(i+6) and									// lsr :STACKORIGIN+STACKWIDTH		; 6
       ror_a(i+7) and										// ror @				; 7
       dey(i+8) and										// dey					; 8
       bne(i+9) and										// bne l_				; 9
       (pos('l_', listing[i+10]) = 1) and							//l_					; 10
       sta(i+11) and (sta_stack(i+11) = false) and						// sta B				; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH		; 12
       sta(i+13) and (sta_stack(i+13) = false) then						// sta B+1				; 13
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
	listing[i+6]  := #9'lsr ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	listing[i+12] := '';
	listing[i+13] := '';

	Result:=false; Break;
     end;


    if lda(i) and										// lda B+3				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*3	; 1
       lda(i+2) and										// lda B+2				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2	; 3
       lda(i+4) and										// lda B+1				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and										// lda B				; 6
       ldy(i+7) and										// ldy 					; 7
       beq(i+8) and										// beq					; 8
       (pos('l_', listing[i+9]) = 1) and							//l_					; 9
       lsr_stack(i+10) and									// lsr :STACKORIGIN+STACKWIDTH*3	; 10
       ror_stack(i+11) and									// ror :STACKORIGIN+STACKWIDTH*2	; 11
       ror_stack(i+12) and									// ror :STACKORIGIN+STACKWIDTH		; 12
       ror_a(i+13) and										// ror @				; 13
       dey(i+14) and										// dey					; 14
       bne(i+15) and										// bne l_				; 15
       (pos('l_', listing[i+16]) = 1) and							//l_					; 16
       sta(i+17) and (sta_stack(i+17) = false) and						// sta B				; 17
       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH		; 18
       sta(i+19) and (sta_stack(i+19) = false) and						// sta B+1				; 19
       lda_stack(i+20) and									// lda :STACKORIGIN+STACKWIDTH*2	; 20
       sta(i+21) and (sta_stack(i+21) = false) and						// sta B+2				; 21
       lda_stack(i+22) and									// lda :STACKORIGIN+STACKWIDTH*3	; 22
       sta(i+23) and (sta_stack(i+23) = false) then						// sta B+3				; 23
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+10], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+20], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+12], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+23], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+21], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+17], 6, 256)) then
     begin
	listing[i+10]  := #9'lsr ' + copy(listing[i], 6, 256);
	listing[i+11]  := #9'ror ' + copy(listing[i+2], 6, 256);
	listing[i+12]  := #9'ror ' + copy(listing[i+4], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH		; 1
       (adc_im_0(i+2) or sbc_im_0(i+2)) and							// adc|sbc #$00				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH*2	; 4
       (adc_im_0(i+5) or sbc_im_0(i+5)) and							// adc|sbc #$00				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*2	; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH*3	; 7
       (adc_im_0(i+8) or sbc_im_0(i+8)) and							// adc|sbc #$00				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH*3	; 9
       lda(i+10) and										// lda					; 10
       ldy_stack(i+11) and									// ldy :STACKORIGIN			; 11
       beq(i+12) and										// beq					; 12
       (pos('l_', listing[i+13]) = 1) then							//l_					; 13
     if (copy(listing[i], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
     end;



{
    if //lda_a(i) and										// lda C				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and										// lda C+1				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and										// lda C+2				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_a(i+6) and (lda_im_0(i+6) = false) and						// lda C+3				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lsr_stack(i+8) and									// lsr :STACKORIGIN+STACKWIDTH*3	; 8
       ror_stack(i+9) and									// ror :STACKORIGIN+STACKWIDTH*2	; 9
       ror_stack(i+10) and									// ror :STACKORIGIN+STACKWIDTH		; 10
       ror_stack(i+11) then									// ror :STACKORIGIN+9			; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin

	p:=0;
	while (listing[i+8] = listing[i+8+p*4]) and (listing[i+9] = listing[i+9+p*4]) and
	      (listing[i+10] = listing[i+10+p*4]) and (listing[i+11] = listing[i+11+p*4]) do inc(p);

	listing[i+7+p*4] := listing[i+7];
	dec(p);

	while p>=0 do begin
	 listing[i+7+p*4] := #9'lsr @';
	 listing[i+8+p*4] := #9'ror ' + copy(listing[i+5], 6, 256) ;
	 listing[i+9+p*4] := #9'ror ' + copy(listing[i+3], 6, 256) ;
	 listing[i+10+p*4] := #9'ror ' + copy(listing[i+1], 6, 256) ;
	 dec(p);
	end;

	Result:=false; Break;
       end;
}
