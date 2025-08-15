
function opt_STACK_EAX_ECX(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				  ADDEAX_ECX|SUBEAX_ECX
// -----------------------------------------------------------------------------

    if mva(i) and 										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and (mva_im_0(i+2) = false) and							// mva  :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and (mva_im_0(i+3) = false) and							// mva  :STACKORIGIN+STACKWIDTH*3,x	; 3
       inx(i+4) and										// inx					; 4
       mva(i+5) and 										// mva  :STACKORIGIN,x			; 5
       mva(i+6) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 6
       mva(i+7) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 7
       mva(i+8) and										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 8
       ADD_SUB_EAX_ECX(i+9) and									// jsr addEAX_ECX|subEAX_ECX		; 9
       dex(i+10) and										// dex					; 10
       (listing[i+11] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 11
       sta(i+12) and										// sta A				; 12
       (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 13
       sta(i+14) and										// sta A+1				; 14
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 15
       sta(i+16) and										// sta A+2				; 16
       (listing[i+17] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 17
       sta(i+18) then										// sta A+3				; 18
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+5]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+6]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+7]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+8]) > 0) then
     begin

	if (listing[i+9] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := #9'lda ' + GetString(i);
	 listing_tmp[1] := #9'add ' + GetString(i+5);
	 listing_tmp[2] := listing[i+12];
	 listing_tmp[3] := #9'lda ' + GetString(i+1);
	 listing_tmp[4] := #9'adc ' + GetString(i+6);
	 listing_tmp[5] := listing[i+14];
	 listing_tmp[6] := #9'lda ' + GetString(i+2);
	 listing_tmp[7] := #9'adc ' + GetString(i+7);
	 listing_tmp[8] := listing[i+16];
	 listing_tmp[9]  := #9'lda ' + GetString(i+3);
	 listing_tmp[10] := #9'adc ' + GetString(i+8);
	 listing_tmp[11] := listing[i+18];
	end else begin
	 listing_tmp[0] := #9'lda ' + GetString(i);
	 listing_tmp[1] := #9'sub ' + GetString(i+5);
	 listing_tmp[2] := listing[i+12];
	 listing_tmp[3] := #9'lda ' + GetString(i+1);
	 listing_tmp[4] := #9'sbc ' + GetString(i+6);
	 listing_tmp[5] := listing[i+14];
	 listing_tmp[6] := #9'lda ' + GetString(i+2);
	 listing_tmp[7] := #9'sbc ' + GetString(i+7);
	 listing_tmp[8] := listing[i+16];
	 listing_tmp[9]  := #9'lda ' + GetString(i+3);
	 listing_tmp[10] := #9'sbc ' + GetString(i+8);
	 listing_tmp[11] := listing[i+18];
	end;

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
	listing[i+10] := listing_tmp[10];
	listing[i+11] := listing_tmp[11];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';

        exit(false);
     end;


    if lda_a(i) and 										// lda					; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and 										// lda					; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       lda_a(i+4) and 										// lda					; 4
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 5
       lda_a(i+6) and 										// lda					; 6
       (listing[i+7] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 7
       dex(i+8) and										// dex					; 8
       ADD_SUB_EAX_ECX(i+9) and									// jsr addEAX_ECX|subEAX_ECX		; 9
       dex(i+10) and										// dex					; 10
       (listing[i+11] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 11
       sta_a(i+12) and										// sta A				; 12
       (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 13
       sta_a(i+14) and										// sta A+1				; 14
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 15
       sta_a(i+16) and										// sta A+2				; 16
       (listing[i+17] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 17
       sta_a(i+18) then										// sta A+3				; 18
     begin

	if (listing[i+9] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'add ' + copy(listing[i], 6, 256);
	 listing_tmp[2] := listing[i+12];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'adc ' + copy(listing[i+2], 6, 256);
	 listing_tmp[5] := listing[i+14];
	 listing_tmp[6] := #9'lda :STACKORIGIN+STACKWIDTH*2,x';
	 listing_tmp[7] := #9'adc ' + copy(listing[i+4], 6, 256);
	 listing_tmp[8] := listing[i+16];
	 listing_tmp[9]  := #9'lda :STACKORIGIN+STACKWIDTH*3,x';
	 listing_tmp[10] := #9'adc ' + copy(listing[i+6], 6, 256);
	 listing_tmp[11] := listing[i+18];
	end else begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'sub ' + copy(listing[i], 6, 256);
	 listing_tmp[2] := listing[i+12];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'sbc ' + copy(listing[i+2], 6, 256);
	 listing_tmp[5] := listing[i+14];
	 listing_tmp[6] := #9'lda :STACKORIGIN+STACKWIDTH*2,x';
	 listing_tmp[7] := #9'sbc ' + copy(listing[i+4], 6, 256);
	 listing_tmp[8] := listing[i+16];
	 listing_tmp[9]  := #9'lda :STACKORIGIN+STACKWIDTH*3,x';
	 listing_tmp[10] := #9'sbc ' + copy(listing[i+6], 6, 256);
	 listing_tmp[11] := listing[i+18];
	end;

	listing[i]   := #9'dex';
	listing[i+1] := #9'dex';
	listing[i+2] := listing_tmp[0];
	listing[i+3] := listing_tmp[1];
	listing[i+4] := listing_tmp[2];
	listing[i+5] := listing_tmp[3];
	listing[i+6] := listing_tmp[4];
	listing[i+7] := listing_tmp[5];
	listing[i+8] := listing_tmp[6];
	listing[i+9] := listing_tmp[7];
	listing[i+10]:= listing_tmp[8];
	listing[i+11]:= listing_tmp[9];
	listing[i+12]:= listing_tmp[10];
	listing[i+13]:= listing_tmp[11];

	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';

        exit(false);
     end;


    if (mva(i) = false) and									// ~mva					; 0
       inx(i+1) and										// inx					; 1
       mva(i+2) and 										// mva  :STACKORIGIN,x			; 2
       mva(i+3) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 3
       mva(i+4) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 4
       mva(i+5) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 5
       ADD_SUB_EAX_ECX(i+6) and									// jsr addEAX_ECX|subEAX_ECX		; 6
       dex(i+7) and										// dex					; 7
       (listing[i+8] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 8
       sta(i+9) and										// sta A				; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta(i+11) and										// sta A+1				; 11
       (listing[i+12] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 12
       sta(i+13) and										// sta A+2				; 13
       (listing[i+14] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 14
       sta(i+15) then										// sta A+3				; 15
     if (pos(':STACKORIGIN,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+5]) > 0) then
     begin

	if (listing[i+6] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'add ' + GetString(i+2);
	 listing_tmp[2] := listing[i+9];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'adc ' + GetString(i+3);
	 listing_tmp[5] := listing[i+11];
	 listing_tmp[6] := #9'lda :STACKORIGIN+STACKWIDTH*2,x';
	 listing_tmp[7] := #9'adc ' + GetString(i+4);
	 listing_tmp[8] := listing[i+13];
	 listing_tmp[9]  := #9'lda :STACKORIGIN+STACKWIDTH*3,x';
	 listing_tmp[10] := #9'adc ' + GetString(i+5);
	 listing_tmp[11] := listing[i+15];
	end else begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'sub ' + GetString(i+2);
	 listing_tmp[2] := listing[i+9];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'sbc ' + GetString(i+3);
	 listing_tmp[5] := listing[i+11];
	 listing_tmp[6] := #9'lda :STACKORIGIN+STACKWIDTH*2,x';
	 listing_tmp[7] := #9'sbc ' + GetString(i+4);
	 listing_tmp[8] := listing[i+13];
	 listing_tmp[9]  := #9'lda :STACKORIGIN+STACKWIDTH*3,x';
	 listing_tmp[10] := #9'sbc ' + GetString(i+5);
	 listing_tmp[11] := listing[i+15];
	end;

	listing[i+1] := listing_tmp[0];
	listing[i+2] := listing_tmp[1];
	listing[i+3] := listing_tmp[2];
	listing[i+4] := listing_tmp[3];
	listing[i+5] := listing_tmp[4];
	listing[i+6] := listing_tmp[5];
	listing[i+7] := listing_tmp[6];
	listing[i+8] := listing_tmp[7];
	listing[i+9] := listing_tmp[8];
	listing[i+10] := listing_tmp[9];
	listing[i+11] := listing_tmp[10];
	listing[i+12] := listing_tmp[11];

	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

       exit(false);
     end;


    if lda_val(i) and										// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       lda_a(i+4) and										// lda A+2				; 4
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 5
       lda_a(i+6) and										// lda A+3				; 6
       (listing[i+7] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 7
       mva(i+8) and 										// mva  :STACKORIGIN,x			; 8
       mva(i+9) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 9
       mva(i+10) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 10
       mva(i+11) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 11
       ADD_SUB_EAX_ECX(i+12) and								// jsr addEAX_ECX|subEAX_ECX		; 12
       (dex(i+13) = false) then									// ~dex					; 13
     if (pos(':STACKORIGIN,x', listing[i+8]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+9]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+10]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+11]) > 0) then
     begin

	if (listing[i+12] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := listing[i];
	 listing_tmp[1] := #9'add ' + GetString(i+8);
	 listing_tmp[2] := #9'sta :STACKORIGIN-1,x';
	 listing_tmp[3] := listing[i+2];
	 listing_tmp[4] := #9'adc ' + GetString(i+9);
	 listing_tmp[5] := #9'sta :STACKORIGIN-1+STACKWIDTH,x';
	 listing_tmp[6] := listing[i+4];
	 listing_tmp[7] := #9'adc ' + GetString(i+10);
	 listing_tmp[8] := #9'sta :STACKORIGIN-1+STACKWIDTH*2,x';
	 listing_tmp[9]  := listing[i+6];
	 listing_tmp[10] := #9'adc ' + GetString(i+11);
	 listing_tmp[11] := #9'sta :STACKORIGIN-1+STACKWIDTH*3,x';
	end else begin
	 listing_tmp[0] := listing[i];
	 listing_tmp[1] := #9'sub ' + GetString(i+8);
	 listing_tmp[2] := #9'sta :STACKORIGIN-1,x';
	 listing_tmp[3] := listing[i+2];
	 listing_tmp[4] := #9'sbc ' + GetString(i+9);
	 listing_tmp[5] := #9'sta :STACKORIGIN-1+STACKWIDTH,x';
	 listing_tmp[6] := listing[i+4];
	 listing_tmp[7] := #9'sbc ' + GetString(i+10);
	 listing_tmp[8] := #9'sta :STACKORIGIN-1+STACKWIDTH*2,x';
	 listing_tmp[9]  := listing[i+6];
	 listing_tmp[10] := #9'sbc ' + GetString(i+11);
	 listing_tmp[11] := #9'sta :STACKORIGIN-1+STACKWIDTH*3,x';
	end;

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
	listing[i+10] := listing_tmp[10];
	listing[i+11] := listing_tmp[11];

	listing[i+12] := '';

       exit(false);
     end;


    if dex(i+13) and										// dex					; 13

       lda_val(i) and										// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       lda_a(i+4) and										// lda A+2				; 4
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 5
       lda_a(i+6) and										// lda A+3				; 6
       (listing[i+7] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 7
       mva(i+8) and 										// mva  :STACKORIGIN,x			; 8
       mva(i+9) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 9
       mva(i+10) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 10
       mva(i+11) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 11
       ADD_SUB_EAX_ECX(i+12) and								// jsr addEAX_ECX|subEAX_ECX		; 12

       (listing[i+14] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 14
       sta_val(i+15) and									// sta A				; 15
       (listing[i+16] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 16
       sta(i+17) and										// sta A+1				; 17
       (listing[i+18] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 18
       sta(i+19) and										// sta A+2				; 19
       (listing[i+20] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 20
       sta(i+21) then										// sta A+3				; 21
     if (pos(':STACKORIGIN,x', listing[i+8]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+9]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+10]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+11]) > 0) then
     begin

	if (listing[i+12] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := listing[i];
	 listing_tmp[1] := #9'add ' + GetString(i+8);
	 listing_tmp[2] := listing[i+15];
	 listing_tmp[3] := listing[i+2];
	 listing_tmp[4] := #9'adc ' + GetString(i+9);
	 listing_tmp[5] := listing[i+17];
	 listing_tmp[6] := listing[i+4];
	 listing_tmp[7] := #9'adc ' + GetString(i+10);
	 listing_tmp[8] := listing[i+19];
	 listing_tmp[9]  := listing[i+6];
	 listing_tmp[10] := #9'adc ' + GetString(i+11);
	 listing_tmp[11] := listing[i+21];
	end else begin
	 listing_tmp[0] := listing[i];
	 listing_tmp[1] := #9'sub ' + GetString(i+8);
	 listing_tmp[2] := listing[i+15];
	 listing_tmp[3] := listing[i+2];
	 listing_tmp[4] := #9'sbc ' + GetString(i+9);
	 listing_tmp[5] := listing[i+17];
	 listing_tmp[6] := listing[i+4];
	 listing_tmp[7] := #9'sbc ' + GetString(i+10);
	 listing_tmp[8] := listing[i+19];
	 listing_tmp[9]  := listing[i+6];
	 listing_tmp[10] := #9'sbc ' + GetString(i+11);
	 listing_tmp[11] := listing[i+21];
	end;

	listing[i]   := #9'dex';
	listing[i+1] := listing_tmp[0];
	listing[i+2] := listing_tmp[1];
	listing[i+3] := listing_tmp[2];
	listing[i+4] := listing_tmp[3];
	listing[i+5] := listing_tmp[4];
	listing[i+6] := listing_tmp[5];
	listing[i+7] := listing_tmp[6];
	listing[i+8] := listing_tmp[7];
	listing[i+9] := listing_tmp[8];
	listing[i+10] := listing_tmp[9];
	listing[i+11] := listing_tmp[10];
	listing[i+12] := listing_tmp[11];

	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';

       exit(false);
     end;


    if tay(i) and										// tay					; 0
       lda_val(i+1) and										// lda A				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda_a(i+3) and										// lda A+1				; 3
       (listing[i+4] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 4
       lda_a(i+5) and										// lda A+2				; 5
       (listing[i+6] = #9'sta :STACKORIGIN+STACKWIDTH*2,x') and					// sta :STACKORIGIN+STACKWIDTH*2,x	; 6
       lda_a(i+7) and										// lda A+3				; 7
       (listing[i+8] = #9'sta :STACKORIGIN+STACKWIDTH*3,x') and					// sta :STACKORIGIN+STACKWIDTH*3,x	; 8
       ADD_SUB_EAX_ECX(i+9) and									// jsr addEAX_ECX|subEAX_ECX		; 9
       dex(i+10) and										// dex					; 10
       (listing[i+11] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 11
       sta_val(i+12) and									// sta A				; 12
       (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 13
       sta(i+14) and										// sta A+1				; 14
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 15
       sta(i+16) and										// sta A+2				; 16
       (listing[i+17] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 17
       sta(i+18) then										// sta A+3				; 18
     begin

	if (listing[i+9] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := #9'lda :STACKORIGIN-1,x';
	 listing_tmp[1] := #9'add ' + GetString(i+1);
	 listing_tmp[2] := #9'sta ' + GetString(i+12);
	 listing_tmp[3] := #9'lda :STACKORIGIN-1+STACKWIDTH,x';
	 listing_tmp[4] := #9'adc ' + GetString(i+3);
	 listing_tmp[5] := #9'sta ' + GetString(i+14);
	 listing_tmp[6] := #9'lda :STACKORIGIN-1+STACKWIDTH*2,x';
	 listing_tmp[7] := #9'adc ' + GetString(i+5);
	 listing_tmp[8] := #9'sta ' + GetString(i+16);
	 listing_tmp[9] := #9'lda :STACKORIGIN-1+STACKWIDTH*3,x';
	 listing_tmp[10] := #9'adc ' + GetString(i+7);
	 listing_tmp[11] := #9'sta ' + GetString(i+18);
	end else begin
	 listing_tmp[0] := #9'lda :STACKORIGIN-1,x';
	 listing_tmp[1] := #9'sub ' + GetString(i+1);
	 listing_tmp[2] := #9'sta ' + GetString(i+12);
	 listing_tmp[3] := #9'lda :STACKORIGIN-1+STACKWIDTH,x';
	 listing_tmp[4] := #9'sbc ' + GetString(i+3);
	 listing_tmp[5] := #9'sta ' + GetString(i+14);
	 listing_tmp[6] := #9'lda :STACKORIGIN-1+STACKWIDTH*2,x';
	 listing_tmp[7] := #9'sbc ' + GetString(i+5);
	 listing_tmp[8] := #9'sta ' + GetString(i+16);
	 listing_tmp[9] := #9'lda :STACKORIGIN-1+STACKWIDTH*3,x';
	 listing_tmp[10] := #9'sbc ' + GetString(i+7);
	 listing_tmp[11] := #9'sta ' + GetString(i+18);
	end;

	listing[i+1] := listing_tmp[0];
	listing[i+2] := listing_tmp[1];
	listing[i+3] := listing_tmp[2];
	listing[i+4] := listing_tmp[3];
	listing[i+5] := listing_tmp[4];
	listing[i+6] := listing_tmp[5];
	listing[i+7] := listing_tmp[6];
	listing[i+8] := listing_tmp[7];
	listing[i+9] := listing_tmp[8];
	listing[i+10] := listing_tmp[9];
	listing[i+11] := listing_tmp[10];
	listing[i+12] := listing_tmp[11];

	listing[i+13] := #9'dex';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva  :STACKORIGIN			; 1
       mva(i+2) and										// mva  :STACKORIGIN+STACKWIDTH		; 2
       (listing[i+3] = #9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH*2	; 3
       (listing[i+4] = #9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH*3	; 4
       inx(i+5) and										// inx					; 5
       mva(i+6) and 										// mva  :STACKORIGIN,x			; 6
       mva(i+7) and 										// mva  :STACKORIGIN+STACKWIDTH		; 7
       (listing[i+8] = #9'mva #$00 :STACKORIGIN+STACKWIDTH*2,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH*2	; 8
       (listing[i+9] = #9'mva #$00 :STACKORIGIN+STACKWIDTH*3,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH*3	; 9
       ADD_SUB_EAX_ECX(i+10) and								// jsr addEAX_ECX|subEAX_ECX		; 10
       dex(i+11) then										// dex					; 11
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+6]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin

	if (listing[i+10] = #9'jsr addEAX_ECX') then begin
	 listing_tmp[0] := #9'inx';
	 listing_tmp[1] := #9'ldy #$00';
	 listing_tmp[2] := #9'sty :STACKORIGIN+STACKWIDTH*3,x';
	 listing_tmp[3] := #9'lda ' + GetString(i+1);
	 listing_tmp[4] := #9'add ' + GetString(i+6);
	 listing_tmp[5] := #9'sta :STACKORIGIN,x';
	 listing_tmp[6] := #9'lda ' + GetString(i+2);
	 listing_tmp[7] := #9'adc ' + GetString(i+7);
	 listing_tmp[8] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[9] := #9'scc';
	 listing_tmp[10] := #9'iny';
	 listing_tmp[11] := #9'sty :STACKORIGIN+STACKWIDTH*2,x';
	end else begin
	 listing_tmp[0] := #9'inx';
	 listing_tmp[1] := #9'ldy #$00';
	 listing_tmp[2] := #9'lda ' + GetString(i+1);
	 listing_tmp[3] := #9'sub ' + GetString(i+6);
	 listing_tmp[4] := #9'sta :STACKORIGIN,x';
	 listing_tmp[5] := #9'lda ' + GetString(i+2);
	 listing_tmp[6] := #9'sbc ' + GetString(i+7);
	 listing_tmp[7] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[8] := #9'scs';
	 listing_tmp[9] := #9'dey';
	 listing_tmp[10] := #9'sty :STACKORIGIN+STACKWIDTH*2,x';
	 listing_tmp[11] := #9'sty :STACKORIGIN+STACKWIDTH*3,x';
	end;

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
	listing[i+10] := listing_tmp[10];
	listing[i+11] := listing_tmp[11];

       exit(false);
     end;

end;		// function