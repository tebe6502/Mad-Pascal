
function opt_ASL(i: integer): Boolean;
var p: integer;
    yes: Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      ASL.
// -----------------------------------------------------------------------------
//
//	SHR 23 -> shrEAX_CL
//
//	lda :STACKORIGIN+STACKWIDTH*2+9		bit7 -> C
//	asl @
//	lda :STACKORIGIN+STACKWIDTH*3+9
//	rol @


    if asl_a(i+5) and										// asl @				; 5

       lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_im_0(i+2) and									// lda #$00 				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) then									// lda :STACKORIGIN			; 4
//       asl_a(i+5) then									// asl @				; 5
     if argMatch(i+1, i+4) then
     begin
	listing_tmp[0] := listing[i+2];
	listing_tmp[1] := listing[i+3];
	listing_tmp[2] := listing[i];
	listing_tmp[3] := listing[i+1];
	listing_tmp[4] := listing[i+4];
	listing_tmp[5] := listing[i+5];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];
	listing[i+5] := listing_tmp[5];

	exit(false);
     end;


    if rol_a(i) and										// rol @				; 0
       lda_a(i+1) and										// lda					; 1
       (sta_a(i+2) or lsr_a(i+2) or asl_a(i+2)) then						// sta|lsr @|asl @			; 2
      begin
	listing[i] := '';

	exit(false);
      end;


    if rol_a(i) and										// rol @				; 0
       lda_a(i+1) and										// lda					; 1
       (and_ora_eor(i+2) or add_sub(i+2)) and							// and|ora|eor|add|sub			; 2
       (sta_a(i+3) or mwy_bp2(i+3) or ldy(i+3) or tay(i+3)) then				// sta|mwy|ldy|tay			; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if rol_a(i) and										// rol @				; 0
       (mwy_bp2(i+1) or ldy(i+1)) and								// mwy|ldy				; 1
       lda_a(i+2) and										// lda					; 2
       (and_ora_eor(i+3) or add_sub(i+3)) and							// and|ora|eor|add|sub			; 3
       (sta_a(i+4) or ldy(i+4) or tay(i+4)) then						// sta|ldy|tay				; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if rol_a(i) and										// rol @				; 0
       lda_a(i+1) and										// lda					; 1
       (and_ora_eor(i+2) or add_sub(i+2)) and							// and|ora|eor|add|sub			; 2
       (and_ora_eor(i+3) or add_sub(i+3)) and							// and|ora|eor|add|sub			; 3
       (sta_a(i+4) or mwy_bp2(i+4) or ldy(i+4)) then						// sta|mwy|ldy				; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_val(i) and										// lda					; 0	~:STACKORIGIN
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH		; 2
       asl_stack(i+3) then									// asl :STACKORIGIN			; 3
     begin
	listing[i] := '';

	exit(false);
     end;


    if rol_a(i+14) and										// rol @				; 14

       lda_a(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_im_0(i+9) and									// lda #$00				; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH		; 12
       asl_stack(i+13) and									// asl :STACKORIGIN			; 13
//       rol_a(i+14) and									// rol @				; 14
       sta_stack(i+15) then									// sta :STACKORIGIN+STACKWIDTH		; 15
     if argMatch(i+2, i+13) and
	argMatch(i+5, i+12) and
	argMatch(i+5, i+15) then
       begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


    if //lda_a(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDHT		; 5
       asl_stack(i+6) and									// asl :STACKORIGIN			; 6
       rol_a(i+7) then										// rol @				; 7
     if argMatch(i+2, i+6) then
       begin

	 if sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDHT		; 8
	    argMatch(i+5, i+8) then
	 begin
	  listing[i+5] := '';

	  exit(false);
	 end;


	 if (listing[i+8] = listing[i+6]) and							// asl :STACKORIGIN			; 8
	    (listing[i+9] = listing[i+7]) and							// rol @				; 9
	    sta_stack(i+10) and									// sta :STACKORIGIN+STACKWIDTH		; 10
	    argMatch(i+5, i+10) then
	 begin
	  listing[i+5] := '';

	  exit(false);
	 end;

       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_a(i+1) and										// rol @				; 1
       lda_stack(i+2) then									// lda :STACKORIGIN			; 2
     if argMatch(i, i+2) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if rol_a(i+6) and										// rol @				; 6

//       lda_a(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       asl_stack(i+5) and									// asl :STACKORIGIN			; 5
//       rol_a(i+6) and										// rol @				; 6
       ldy_stack(i+7) then									// ldy :STACKORIGIN			; 7
     if argMatch(i+2, i+5) and
	argMatch(i+5, i+7) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := #9'asl @';
	listing[i+6] := '';
	listing[i+7] := #9'tay';

	exit(false);
       end;


    if rol_a(i+3) and										// rol @				; 3

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_a(i+1) and										// lda					; 1
       asl_stack(i+2) and									// asl :STACKORIGIN			; 2
//       rol_a(i+3) and										// rol @				; 3
       ldy_stack(i+4) then									// ldy :STACKORIGIN			; 4
     if argMatch(i, i+2) and
	argMatch(i+2, i+4) then
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := #9'asl @';
	listing[i+4] := #9'tay';

	exit(false);
       end;


    if rol_a(i+4) and										// rol @				; 4

       lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
//       rol_a(i+4) and										// rol @				; 4
       sta_val(i+5) and										// sta					; 5	~:STACKORIGN
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       sta_val(i+7) and (iy(i+7) = false) then							// sta					; 7	~:STACKORIGN
     if argMatch(i+1, i+3) and
	argMatch(i+3, i+6) then
       begin
	listing[i+1] := #9'sta ' + copy(listing[i+7], 6, 256);

	listing[i+3] := #9'asl ' + copy(listing[i+7], 6, 256);

	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if lda_a(i) and 										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_stack(i+2) and									// asl :STACKORIGIN			; 2
       ( lda_a(i+3) or mwa(i+3) ) then								// lda|mwa				; 3
     if argMatch(i+1, i+2) then
       begin
	listing[i+2] := listing[i+1];
	listing[i+1] := #9'asl @';

	exit(false);
       end;


    if sta_stack(i) and 									// sta :STACKORIGIN			; 0
       lda_a(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       (asl_stack(i+3) or lsr_stack(i+3)) and							// asl|lsr :STACKORIGIN			; 3
       ((rol(i+4) = false) and (ror(i+4) = false)) then						//~rol|ror				; 4
     if argMatch(i, i+3) then begin
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       (asl(i+3) or lsr(i+3)) and								// asl|lsr				; 3
       sta_im_0(i+4) and 									// sta #$00				; 4
       (ror_stack(i+5) or rol_stack(i+5)) then							// ror|rol :STACKORIGIN			; 5
     if argMatch(i, i+5) then begin
	listing[i+4] := '';

	exit(false);
     end;


    if asl_im_0(i) and										// asl #$00				; 0
       rol_im_0(i+1) then									// rol #$00				; 1
     begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if (asl_stack(i) or asl_a(i)) and								// asl @|asl :STACKORIGIN		; 0
       rol_im_0(i+1) then									// rol #$00				; 1
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if rol_stack(i) and										// rol :STACKORIGIN			; 0
       rol_im_0(i+1) then									// rol #$00				; 1
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       asl_stack(i+2) and									// asl :STACKORIGIN			; 2
       ldy_stack(i+3) then									// ldy :STACKORIGIN			; 3
     if argMatch(i, i+1) and
	argMatch(i, i+2) and
	argMatch(i, i+3) then
      begin
	listing[i]   := '';
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       lda_stack(i+2) then									// lda :STACKORIGIN			; 2
     if argMatch(i, i+1) and
	argMatch(i, i+2) then
      begin
	listing[i]   := #9'asl @';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_a(i+1) and										// asl @				; 1
       sta_stack(i+2) then									// sta :STACKORIGIN			; 2
     if argMatch(i, i+2) then
      begin
	listing[i] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       lda_val(i+2) then									// lda					; 2	~:STACKORIGIN
     if argMatch(i, i+1) then
      begin
	listing[i+1] := listing[i];

	listing[i] := #9'asl @';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_a(i+1) and										// lda					; 1
       asl_stack(i+2) and									// asl :STACKORIGIN			; 2
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
       (ldy_stack(i+4) or lda_stack(i+4)) then							// ldy|lda :STACKORIGIN 		; 4
     if argMatch(i, i+2) and
	argMatch(i, i+3) and
	argMatch(i, i+4) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'asl @';

	if ldy_stack(i+4) then
	 listing[i+4] := #9'tay'
	else
	 listing[i+4] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       ldy_stack(i+2) then									// ldy :STACKORIGIN			; 2
     if argMatch(i, i+1) and
	argMatch(i, i+2) then
      begin
	listing[i]   := '';
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'tay';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_a(i+1) and										// lda					; 1
       asl_stack(i+2) and									// asl :STACKORIGIN			; 2
       ldy_stack(i+3) then									// ldy :STACKORIGIN			; 3
     if argMatch(i, i+2) and
	argMatch(i, i+3) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';

	exit(false);
      end;


    if asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       ldy_stack(i+4) then									// ldy :STACKORIGIN			; 4
     if argMatch(i+2, i+4) then
      begin
	listing[i+1] := '';

	exit(false);
      end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       lda_a(i+4) and										// lda					; 4
       add_sub_stack(i+5) and									// add|sub :STACKORIGIN			; 5
       sta_a(i+6) and										// sta					; 6
       lda_a(i+7) and										// lda					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       sta_a(i+9) and										// sta					; 9
												//					; 10
       (adc_sbc(i+11) = false) then								//~adc|sbc				; 11
     if argMatch(i, i+5) then begin

	yes := stack(i+8);

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 if not yes then listing[k-4+1] := '';

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	if not yes then listing[i+1] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       lda_a(i+4) and										// lda					; 4
       add_sub_stack(i+5) and									// add|sub :STACKORIGIN			; 5
       sta_a(i+6) and										// sta					; 6
   												//					; 7
       (adc_sbc(i+8) = false) then								//~adc|sbc				; 8
     if argMatch(i, i+5) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

         listing[k-4+1] := '';
	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2	redundant
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3	redundant
       lda(i+4) and										// lda					; 4
       asl_a(i+5) and										// asl @				; 5
       tay(i+6) and										// tay					; 6
       lda_stack(i+7) and									// lda :STACKORIGIN			; 7
       add_sub(i+8) and										// add|sub				; 8
       sta_a(i+9) and										// sta					; 9
       lda(i+10) and										// lda :STACKORIGIN+STACKWIDTH		; 10
       adc_sbc(i+11) and									// adc|sbc				; 11
       sta_a(i+12) and										// sta					; 12
      												//					; 13
       (adc_sbc(i+14) = false) then								//~adc|sbc				; 14
     if argMatch(i, i+7) then begin

	yes := stack(i+10);

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 if not yes then listing[k-4+1] := '';

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	 if not yes then listing[i+1] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if adc_sbc(i+16) and									// adc|sbc				; 16

       lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda(i+6) and										// lda					; 6
       adc_sbc(i+7) and										// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 8	redundant
       lda(i+9) and										// lda I				; 9
       asl_a(i+10) and										// asl @				; 10
       tay(i+11) and										// tay					; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+9			; 12
       add_sub(i+13) and									// add|sub				; 13
       sta(i+14) and										// sta T				; 14
       lda_stack(i+15) and									// lda :STACKORIGIN+STACKWIDTH+9	; 15
//       adc_sbc(i+16) and									// adc|sbc				; 16
       sta(i+17) and										// sta T+1				; 17
												//					; 18
       (adc_sbc(i+19) = false) then								//~adc|sbc				; 19
     if argMatch(i+2, i+12) and
	argMatch(i+5, i+15) then
       begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_val(i+5) and (EAX(i+5) = false) and							// sta					; 5	~:STACKORIGN
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       sta_val(i+7) and (EAX(i+7) = false) and							// sta					; 7	~:STACKORIGN
       (lda_stack(i+8) = false)  then								//~lda :STACKORIGIN+STACKWIDTH*2	; 8
     if argMatch(i, i+4) and
	argMatch(i+1, i+6) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH		; 3
       sta_val(i+4) and (EAX(i+4) = false) and							// sta					; 4	~:STACKORIGN
       lda_stack(i+5) and									// lda :STACKORIGIN+STACKWIDTH*2	; 5
       sta_val(i+6) and (EAX(i+6) = false) and							// sta					; 6	~:STACKORIGN
       (lda_stack(i+7) = false)  then								//~lda :STACKORIGIN			; 7
     if argMatch(i+1, i+3) and
	argMatch(i+2, i+5) then begin

	k:=i;
	while (listing[i]=listing[k-3]) and (listing[i+1]=listing[k-3+1]) and (listing[i+2]=listing[k-3+2]) do begin

	 dec(k, 3);
	end;

	if sta_stack(k-1) and argMatch(k-1, i+2) then begin

	  k:=i;
	  while (listing[i]=listing[k-3]) and (listing[i+1]=listing[k-3+1]) and (listing[i+2]=listing[k-3+2]) do begin

	   listing[k-3+2] := #9'rol @';

	   dec(k, 3);
	  end;

	  listing[i+2] := #9'rol @';

	  listing[k-1] := '';

	  listing[i+5] := listing[i+3];

	  listing[i+3] := listing[i+6];

	  listing[i+6] := listing[i+4];

	  listing[i+4] := '';

	  exit(false);
	end;

       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       lda_stack(i+2) and									// lda :STACKORIGIN			; 2
       sta_val(i+3) and (EAX(i+3) = false) and							// sta					; 3	~:STACKORIGN
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH		; 4
       sta_val(i+5) and (EAX(i+5) = false) and							// sta					; 5	~:STACKORIGN
       (lda_stack(i+6) = false)  then								//~lda :STACK				; 6
     if argMatch(i, i+2) and
	argMatch(i+1, i+4) then begin

	k:=i;
	while (listing[i]=listing[k-2]) and (listing[i+1]=listing[k-2+1]) do begin

	 dec(k, 2);
	end;


	if sta_stack(k-1) and argMatch(k-1, i) then begin	// sta :STACKORIGIN		// k-1
													// asl :STACKORIGIN 		// k
	  k:=i;												// rol :STACKORIGIN+STACKWIDTH	// k+1
	  while (listing[i]=listing[k-2]) and (listing[i+1]=listing[k-2+1]) do begin

	   listing[k-2] := #9'asl @';

	   dec(k, 2);
	  end;

	  listing[i] := #9'asl @';

	  listing[k-1] := '';

	  listing[i+2] := '';

	  exit(false);
	end else

	if sta_stack(k-1) and argMatch(k-1, i+1) then begin	// sta :STACKORIGIN+STACKWIDHT	// k-1
													// asl :STACKORIGIN 		// k
	  k:=i;												// rol :STACKORIGIN+STACKWIDTH	// k+1
	  while (listing[i]=listing[k-2]) and (listing[i+1]=listing[k-2+1]) do begin

	   listing[k-2+1] := #9'rol @';

	   dec(k, 2);
	  end;

	  listing[i+1] := #9'rol @';

	  listing[k-1] := '';

	  listing[i+4] := listing[i+2];

	  listing[i+2] := listing[i+5];

	  listing[i+5] := listing[i+3];

	  listing[i+3] := '';

	  exit(false);
	end;

       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_val(i+5) and (EAX(i+5) = false) and							// sta					; 5	~:STACKORIGN
       (lda_stack(i+6) = false)  then								//~lda :STACKORIGIN+STACKWIDTH*2	; 8
     if argMatch(i, i+4) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+1] := '';
	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;


	if sta_stack(k-1) and			// sta :STACKORIGIN+STACKWIDTH*3+9	// -1
	   adc_sbc(k-2) and			// adc|sbc :STACKORIGIN+STACKWIDTH*3+10	// -2
	   lda(k-3) and				// lda :STACKORIGIN+STACKWIDTH*3+9	// -3
	   sta_stack(k-4) and			// sta :STACKORIGIN+STACKWIDTH*2+9	// -4
	   adc_sbc(k-5) and			// adc|sbc :STACKORIGIN+STACKWIDTH*2+10	// -5
	   lda(k-6) and				// lda :STACKORIGIN+STACKWIDTH*2+9	// -6
	   sta_stack(k-7) and			// sta :STACKORIGIN+STACKWIDTH+9	// -7
	   adc_sbc(k-8) and			// adc|sbc :STACKORIGIN+STACKWIDTH+10	// -8
	   lda(k-9) then			// lda :STACKORIGIN+STACKWIDTH+9	// -9
	 if argMatch(k-7, i+1) and
	    argMatch(k-4, i+2) and
	    argMatch(k-1, i+3) then
	  begin
	   listing[k-1] := '';
	   listing[k-2] := '';
	   listing[k-3] := '';
	   listing[k-4] := '';
	   listing[k-5] := '';
	   listing[k-6] := '';
	   listing[k-7] := '';
	   listing[k-8] := '';
	   listing[k-9] := '';
	  end;

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       asl_stack(i+1) and									// asl :STACKORIGN			; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH		; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH		; 3
       sta_val(i+4) and										// sta					; 4	~:STACKORIGN
       (lda_stack(i+5) = false) then								//~lda :STACKORIGIN+			; 5
     if argMatch(i, i+2) and
        argMatch(i+2, i+3) then
       begin
        listing[i]   := '';

        listing[i+2] := #9'rol @';
        listing[i+3] := '';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       lda_stack(i+2) and									// lda :STACKORIGIN			; 2
       sta_val(i+3) and (EAX(i+3) = false) and							// sta					; 3	~:STACKORIGN
       (lda_stack(i+4) = false) then								//~lda :STACKORIGIN+STACKWIDTH		; 4
     if argMatch(i, i+2) then
       begin

	k:=i;
	while (listing[i]=listing[k-2]) and (listing[i+1]=listing[k-2+1]) do begin

	 listing[k-2+1] := '';

	 dec(k, 2);
	end;

	listing[i+1] := '';

	exit(false);
       end;


    if rol_a(i+6) and										// rol @				; 6

       lda_val(i) and										// lda A				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda A+1				; 2	~:STACKORIGIN
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
       rol_a(i+4) and										// rol @				; 4
       asl_stack(i+5) and									// asl :STACKORIGIN			; 5
//       rol_a(i+6) and										// rol @				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH		; 7
       lda(i+8) and (lda_stack(i+8) = false) and						// lda					; 8	~:STACKORIGIN ~lda adr.
       add_stack(i+9) then									// add :STACKORIGIN			; 9
      if argMatch(i+1, i+3) and
         argMatch(i+3, i+5) and
         argMatch(i+5, i+9) then
       begin
	 listing[i+1] := listing[i+7];

	 listing[i+9] := #9'add ' + copy(listing[i+8], 6, 256);
	 listing[i+8] := #9'rol ' + copy(listing[i+7], 6, 256);
	 listing[i+7] := #9'asl @';
	 listing[i+6] := listing[i+8];
	 listing[i+5] := #9'asl @';
	 listing[i+4] := listing[i];
	 listing[i+3] := '';

	 listing[i] := listing[i+2];

	 listing[i+2] := '';

	 exit(false);
       end;


    if rol_a(i+4) and										// rol @				; 4

       lda_val(i) and										// lda A				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda A+1				; 2	~:STACKORIGIN
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
//       rol_a(i+4) and										// rol @				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and (lda_stack(i+6) = false) and						// lda					; 6	~:STACKORIGIN ~lda adr.
       add_stack(i+7) then									// add :STACKORIGIN			; 7
      if argMatch(i+1, i+3) and
         argMatch(i+3, i+7) then
       begin
	 listing[i+1] := listing[i+5];

	 listing[i+7] := #9'add ' + copy(listing[i+6], 6, 256);
	 listing[i+6] := #9'rol ' + copy(listing[i+5], 6, 256);
	 listing[i+5] := #9'asl @';
	 listing[i+4] := listing[i];
	 listing[i+3] := '';

	 listing[i] := listing[i+2];

	 listing[i+2] := '';

	 exit(false);
       end;


    if rol_a(i+7) and										// rol @				; 7

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_bp2_y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       lda_bp2_y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       asl_stack(i+6) and									// asl :STACKORIGIN			; 6
//       rol_a(i+7) and										// rol @				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH		; 8
       lda(i+9) and										// lda					; 9	~lda adr.
       add_stack(i+10) then									// add :STACKORIGIN			; 10
      if argMatch(i+2, i+6) and
         argMatch(i+6, i+10) and
         argMatch(i+5, i+8) then
       begin
	 listing[i]   := #9'ldy #$01';

	 listing[i+2] := listing[i+5];
	 listing[i+3] := #9'dey';

	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol ' + copy(listing[i+8], 6, 256);
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'add ' + copy(listing[i+9], 6, 256);
	 listing[i+10]:='';

	 exit(false);
       end;


    if ldy_stack(i+9) and									// ldy :STACKORIGIN			; 9

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda 					; 2
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
       rol_a(i+4) and										// rol @				; 4
       asl_stack(i+5) and									// asl :STACKORIGIN			; 5
       rol_a(i+6) and										// rol @				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH		; 7
       mwy_bp2(i+8) then									// mwy XX :bp2				; 8
//       ldy_stack(i+9) then									// ldy :STACKORIGIN			; 9
     if argMatch(i+1, i+3) and
        argMatch(i+3, i+5) and
        argMatch(i+5, i+9) then
       begin
	listing[i+2] := listing[i+1];
	listing[i+1] := listing[i];

	listing[i] := listing[i+8];

	listing[i+4] := '';

	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
       end;


    if ldy_stack(i+4) and									// ldy :STACKORIGIN			; 4

       asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_a(i+1) and										// rol @				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       mwy_bp2(i+3) then									// mwy XX :bp2				; 3
//       ldy_stack(i+4) then									// ldy :STACKORIGIN			; 4
     if argMatch(i, i+4) and
        (argMatch(i, i+2) = false) then
       begin
	listing[i+1] := #9'lda ' + copy(listing[i], 6, 256);
	listing[i+2] := '';

	listing[i+4] := #9'tay';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       mwy_bp2(i+4) and										// mwy XX bp2				; 4
       ldy(i+5) and										// ldy					; 5
       lda_stack(i+6) and STA_BP2_Y(i+7) and							// lda :STACKORIGIN			; 6
       iny(i+8) and										// sta (:bp2),y				; 7
       lda_stack(i+9) and STA_BP2_Y(i+10) and							// iny					; 8
       (iny(i+11) = false) then									// lda :STACKORIGIN+STACKWIDTH		; 9
     if argMatch(i, i+6) and
	argMatch(i+1, i+9) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       lda_a(i+4) and										// lda					; 4
       (ADD_SUB_STACK(i+5) or AND_ORA_EOR_STACK(i+5)) and					// add|sub|and|ora|eor :STACKORIGIN	; 5
       sta_a(i+6) and										// sta					; 6
       (lda_a(i+7) = false) then								//~lda					; 7
     if argMatch(i, i+5) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+1] := '';
	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       (add_sub(i+5) or and_ora_eor(i+5)) and							// add|sub|and|ora|eor			; 5
       sta_a(i+6) and										// sta					; 6
       (lda_a(i+7) = false) then								//~lda					; 7
     if argMatch(i, i+4) then begin

	k:=i;
	while (listing[i]=listing[k-4]) and (listing[i+1]=listing[k-4+1]) and (listing[i+2]=listing[k-4+2]) and (listing[i+3]=listing[k-4+3]) do begin

	 listing[k-4+1] := '';
	 listing[k-4+2] := '';
	 listing[k-4+3] := '';

	 dec(k, 4);
	end;

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if asl_stack(i+10) and									// asl :STACKORIGIN			; 10

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and										// lda					; 4
       adc_sbc(i+5) and										// adc|sbc				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*2	; 6
       lda(i+7) and										// lda					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH*3	; 9
//       asl_stack(i+10) and									// asl :STACKORIGIN			; 10
       (rol_stack(i+11) = false) then								//~rol :STACKORIGIN+STACKWIDTH		; 11
      if argMatch(i, i+10) then
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

	exit(false);
       end;


    if rol_stack(i+5) and									// rol :STACKORIGIN+STACKWIDTH		; 5

       asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       asl_stack(i+4) and									// asl :STACKORIGIN			; 4
//       rol_stack(i+5) and									// rol :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) then									// lda :STACKORIGIN			; 6
      if (listing[i] = listing[i+4]) and
	 (listing[i+1] = listing[i+5]) and
	 argMatch(i+4, i+6) then
      begin
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if rol_stack(i+7) and									// rol :STACKORIGIN+STACKWIDTH		; 7

       asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3	; 3
       asl_stack(i+4) and									// asl :STACKORIGIN			; 4
       rol_stack(i+5) and									// rol :STACKORIGIN+STACKWIDTH		; 5
       asl_stack(i+6) and									// asl :STACKORIGIN			; 6
//       rol_stack(i+7) and									// rol :STACKORIGIN+STACKWIDTH		; 7
       lda_stack(i+8) then									// lda :STACKORIGIN			; 8
      if (listing[i] = listing[i+4]) and
	 (listing[i+1] = listing[i+5]) and
         (listing[i+4] = listing[i+6]) and
	 (listing[i+5] = listing[i+7]) and
	 argMatch(i+6, i+8) then
      begin
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       asl_stack(i+4) and									// asl :STACKORIGIN			; 4
       asl_stack(i+5) then									// asl :STACKORIGIN			; 5
      if argMatch(i, i+4) and
	 argMatch(i, i+5) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


// add !!!

    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH		; 2
       lda(i+3) and (lda_stack(i+3) = false) and						// lda 					; 3	~:STACKORIGIN ~lda adr.
       add_stack(i+4) and									// add :STACKORIGIN+STACKWIDTH		; 4
       sta_val(i+5) then									// sta 					; 5	~:STACKORIGN
     if argMatch(i, i+2) and
	argMatch(i+2, i+4) then
      begin
        listing[i]   := '';

	listing[i+2] := #9'rol @';
	listing[i+3] := #9'add ' + copy(listing[i+3], 6, 256);
	listing[i+4] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH		; 2
       lda_val(i+3) and										// lda 					; 3	~:STACKORIGIN
       (add_stack(i+4) = false) then								//~add					; 4
     if argMatch(i, i+2) then
      begin
        listing[i+2] := listing[i];

        listing[i]   := listing[i+1];
        listing[i+1] := #9'rol @';

	exit(false);
      end;


    if rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+STACKWIDTH		; 2
       sta_val(i+3) and										// sta 					; 3	~:STACKORIGIN
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_val(i+5) and										// sta 					; 5	~:STACKORIGIN
       lda_a(i+6) then										// lda					; 6
     if argMatch(i, i+2) and
	argMatch(i+1, i+4) then
      begin
	listing[i+1] := listing[i+5];

	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


// wspolna procka dla Nx ASL

    if (add_sub(i) or lda_a(i) or rol_a(i) or AND_ORA_EOR(i)) and				// add|sub|lda|rol|and|ora|eor		; 0
	sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       	asl_stack(i+2) and									// asl :STACKORIGIN			; 2
	(rol_stack(i+3) = false) then								//~rol :STACKORIGIN			; 3
     if argMatch(i+1, i+2) then
       begin

	p:=0;
	while listing[i+2] = listing[i+2+p] do inc(p);

	dec(p);
	listing[i+2+p] := #9'sta ' + copy(listing[i+2], 6, 256);

	while p >= 0 do begin
	  dec(p);
	  listing[i+2+p] := #9'asl @';
	end;

	exit(false);
       end;


    if asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       add_sub_stack(i+2) and									// add|sub :STACKORIGIN+9		; 2
       and_ora_eor_val(i+3) and									// and|ora|eor				; 3	~:STACKORIGIN
       sta(i+4) and										// sta					; 4
       (lda(i+5) = false) then									//~lda					; 5
      if (argMatch(i+1, i+2) = false) then
       begin

	p:=i;
	while asl_a(p) and rol_stack(p+1) do begin
	 listing[p+1] := '';
	 dec(p, 2);
	end;

	exit(false);
       end;


    if rol_stack(i+11) and									// rol :STACKORIGIN+STACKWIDTH*3	; 11

       lda(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and 										// lda 					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and										// lda					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda(i+6) and										// lda 					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3	; 7
       asl_stack(i+8) and 									// asl :STACKORIGIN			; 8
       rol_stack(i+9) and									// rol :STACKORIGIN+STACKWIDTH		; 9
       rol_stack(i+10) and 									// rol :STACKORIGIN+STACKWIDTH*2	; 10
//       rol_stack(i+11) and									// rol :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta_val(i+13) and									// sta					; 13	~:STACKORIGIN
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_val(i+15) and									// sta 					; 15	~:STACKORIGIN
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*2	; 16
       sta_val(i+17) and									// sta 					; 17	~:STACKORIGIN
       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH*3	; 18
       sta_val(i+19) then									// sta					; 19	~:STACKORIGIN
     if argMatch(i+1, i+8) and
	argMatch(i+8, i+12) and
	argMatch(i+3, i+9) and
	argMatch(i+9, i+14) and
	argMatch(i+5, i+10) and
	argMatch(i+10, i+16) and
	argMatch(i+7, i+11) and
	argMatch(i+11, i+18) then
     begin
	listing[i+1] := listing[i+13];
	listing[i+3] := listing[i+15];
	listing[i+5] := listing[i+17];
	listing[i+7] := listing[i+19];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

	listing[i+8]  := #9'asl ' + copy(listing[i+1], 6, 256);
	listing[i+9]  := #9'rol ' + copy(listing[i+3], 6, 256) ;
	listing[i+10] := #9'rol ' + copy(listing[i+5], 6, 256) ;
	listing[i+11] := #9'rol ' + copy(listing[i+7], 6, 256) ;

      	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       sty_stack(i+1) and									// sty :STACKORIGIN+STACKWIDTH*2	; 1
       sty_stack(i+2) and									// sty :STACKORIGIN+STACKWIDTH*3	; 2
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
       rol_stack(i+4) and									// rol :STACKORIGIN+STACKWIDTH		; 4
       (rol_stack(i+5) = false) then								//~rol :STACKORIGIN+STACKWIDTH*9	; 5
     if argMatch(i, i+4) then
      begin
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0		2023-02-05
       lda_im_0(i+1) and 									// lda #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       asl_stack(i+3) and									// asl :STACKORIGIN			; 3
       rol_stack(i+4) and									// rol :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
     if argMatch(i, i+4) and
        argMatch(i+2, i+3) and
        argMatch(i+3, i+5) then
      begin
	listing[i+1] := listing[i];

	listing[i] := #9'asl @';

	listing[i+2] := #9'lda #$00';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if adc_sbc_val(i+10) and									// adc|sbc				; 10

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       asl_stack(i+4) and									// asl :STACKORIGIN			; 4
       rol_stack(i+5) and									// rol :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       add_sub_val(i+7) and									// add|sub				; 7
       sta_val(i+8) and										// sta					; 8	~:STACKORIGN
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH		; 9
//       adc_sbc_val(i+10) and									// adc|sbc				; 10
       sta_val(i+11) then									// sta					; 11	~:STACKORIGN
     if argMatch(i+1, i+4) and
        argMatch(i+3, i+5) and
        argMatch(i+4, i+6) and
        argMatch(i+5, i+9) then
       begin
        listing[i+6] := listing[i+5];

	listing[i+5] := #9'asl @';

	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if adc_im_0(i+8) and									// adc #$00				; 8

       lda_val(i) and										// lda TT+1 				; 0	~:STACKORIGIN
       sta(i+1) and										// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda TT				; 2	~:STACKORIGIN
       asl_a(i+3) and										// asl @				; 3
       rol(i+4) and										// rol :STACKORIGIN			; 4
       add(i+5) and										// add					; 5
       sta(i+6) and (sta_eax(i+6) = false) and							// sta PRIME				; 6	~sta :eax
       lda(i+7) and										// lda :STACKORIGIN			; 7
//       adc_im_0(i+8) and									// adc #$00				; 8
       sta(i+9) and (sta_eax_1(i+9) = false) and						// sta PRIME+1				; 9	~sta :eax+1
       (adc(i+11) = false) then									//~adc					; 11
      if (pos(listing[i+6], listing[i+9]) > 0) and
	 argMatch(i+1, i+4) and
	 argMatch(i+4, i+7) then
       begin

        if argMatch(i+9, i) then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	end else
	 listing[i+1] := listing[i+9];

	listing[i+4] := #9'rol ' + copy(listing[i+9], 6, 256);

	listing[i+7] := '';
	listing[i+8] := #9'scc';
	listing[i+9] := #9'inc ' + copy(listing[i+9], 6, 256);

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if dey(i+8) and										// dey					; 8

       lda(i) and (iy(i) = false) and								// lda B+1				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda(i+2) and										// lda B				; 2
       ldy(i+3) and										// ldy 					; 3
       beq(i+4) and										// beq					; 4
       lab_l(i+5) and										//l_					; 5
       asl_a(i+6) and										// asl @				; 6
       rol_stack(i+7) and									// rol :STACKORIGIN+STACKWIDTH		; 7
//       dey(i+8) and										// dey					; 8
       bne(i+9) and										// bne l_				; 9
       lab_l(i+10) and										//l_					; 10
       sta_val(i+11) and									// sta B				; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH		; 12
       sta_val(i+13) then									// sta B+1				; 13
     if argMatch(i+1, i+7) and
	argMatch(i+7, i+12) and
	argMatch(i, i+13) and
	argMatch(i+2, i+11) then
     begin
	listing[i+7]  := #9'rol ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
     end;


    if dey(i+14) and										// dey					; 14

       lda(i) and										// lda B+3				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*3	; 1
       lda(i+2) and										// lda B+2				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2	; 3
       lda(i+4) and										// lda B+1				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and										// lda B				; 6
       ldy(i+7) and										// ldy 					; 7
       beq(i+8) and										// beq					; 8
       lab_l(i+9) and										//l_					; 9
       asl_a(i+10) and										// asl @				; 10
       rol_stack(i+11) and									// rol :STACKORIGIN+STACKWIDTH		; 11
       rol_stack(i+12) and									// rol :STACKORIGIN+STACKWIDTH*2	; 12
       rol_stack(i+13) and									// rol :STACKORIGIN+STACKWIDTH*3	; 13
//       dey(i+14) and										// dey					; 14
       bne(i+15) and										// bne l_				; 15
       lab_l(i+16) and										//l_					; 16
       sta_val(i+17) and									// sta B				; 17
       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH		; 18
       sta_val(i+19) and									// sta B+1				; 19
       lda_stack(i+20) and									// lda :STACKORIGIN+STACKWIDTH*2	; 20
       sta_val(i+21) and									// sta B+2				; 21
       lda_stack(i+22) and									// lda :STACKORIGIN+STACKWIDTH*3	; 22
       sta_val(i+23) then									// sta B+3				; 23
     if argMatch(i+1, i+13) and
	argMatch(i+13, i+22) and
	argMatch(i+3, i+12) and
	argMatch(i+12, i+20) and
	argMatch(i+5, i+11) and
	argMatch(i+11, i+18) and
	argMatch(i, i+23) and
	argMatch(i+2, i+21) and
	argMatch(i+4, i+19) and
	argMatch(i+6, i+17) then
     begin
	listing[i+11]  := #9'rol ' + copy(listing[i+4], 6, 256);
	listing[i+12]  := #9'rol ' + copy(listing[i+2], 6, 256);
	listing[i+13]  := #9'rol ' + copy(listing[i], 6, 256);

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

	exit(false);
     end;


    if mwy_bp2(i+21) and									// mwy ... bp2				; 21

       lda_im_0(i) and										// lda #$00				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*3	; 1
       lda_im_0(i+2) and									// lda #$00				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2	; 3
       lda_im_0(i+4) and									// lda #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and										// lda B				; 6
       ldy(i+7) and										// ldy 					; 7
       beq(i+8) and										// beq					; 8
       lab_l(i+9) and										//l_					; 9
       asl_a(i+10) and										// asl @				; 10
       rol_stack(i+11) and									// rol :STACKORIGIN+STACKWIDTH		; 11
       rol_stack(i+12) and									// rol :STACKORIGIN+STACKWIDTH*2	; 12
       rol_stack(i+13) and									// rol :STACKORIGIN+STACKWIDTH*3	; 13
       dey(i+14) and										// dey					; 14
       bne(i+15) and										// bne l_				; 15
       lab_l(i+16) and										//l_					; 16
       sta_stack(i+17) and									// sta :STACKORIGIN			; 17
       lda_a(i+18) and										// lda					; 18
       add_sub_stack(i+19) and									// add|sub :STACKORIGIN			; 19
       sta_a(i+20) then										// sta					; 20
     if argMatch(i+1, i+13) and
	argMatch(i+3, i+12) and
	argMatch(i+5, i+11) and
	argMatch(i+17, i+19) and

	(argMatch(i+17, i+11) = false) and
	(argMatch(i+17, i+12) = false) and
	(argMatch(i+17, i+13) = false) then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
     end;


    if mwy_bp2(i+24) and									// mwy ... bp2				; 24

       lda_im_0(i) and										// lda #$00				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*3	; 1
       lda_im_0(i+2) and									// lda #$00				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2	; 3
       lda_im_0(i+4) and									// lda #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and										// lda B				; 6
       ldy(i+7) and										// ldy 					; 7
       beq(i+8) and										// beq					; 8
       lab_l(i+9) and										//l_					; 9
       asl_a(i+10) and										// asl @				; 10
       rol_stack(i+11) and									// rol :STACKORIGIN+STACKWIDTH		; 11
       rol_stack(i+12) and									// rol :STACKORIGIN+STACKWIDTH*2	; 12
       rol_stack(i+13) and									// rol :STACKORIGIN+STACKWIDTH*3	; 13
       dey(i+14) and										// dey					; 14
       bne(i+15) and										// bne l_				; 15
       lab_l(i+16) and										//l_					; 16
       sta_stack(i+17) and									// sta :STACKORIGIN			; 17
       lda_a(i+18) and										// lda					; 18
       add_sub_stack(i+19) and									// add|sub :STACKORIGIN			; 19
       sta_a(i+20) and										// sta					; 20
       lda_a(i+21) and										// lda					; 21
       adc_sbc_stack(i+22) and									// adc|sbc :STACKORIGIN+STACKWIDTH	; 22
       sta_a(i+23) then										// sta					; 23
     if argMatch(i+1, i+13) and
	argMatch(i+3, i+12) and
	argMatch(i+5, i+11) and
	argMatch(i+11, i+22) and
	argMatch(i+17, i+19) and

	(argMatch(i+17, i+11) = false) and
	(argMatch(i+17, i+12) = false) and
	(argMatch(i+17, i+13) = false) then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
     end;


    if asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH+9	; 1
       rol_stack(i+2) and									// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       rol_stack(i+3) and									// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       dey(i+4) and										// dey					; 4
       bne(i+5) and										// bne l_				; 5
       lab_l(i+6) and										//l_					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+9			; 7
       lda_val(i+8) and										// lda A				; 8	~:STACKORIGIN
       ora_stack(i+9) and									// ora :STACKORIGIN+9			; 9
       sta_stack(i+10) and									// sta :STACKORIGIN+10			; 10
       lda_val(i+11) and									// lda A+1				; 11	~:STACKORIGIN
       ora_stack(i+12) and									// ora :STACKORIGIN+STACKWIDTH+9	; 12
       sta_stack(i+13) and									// sta :STACKORIGIN+STACKWIDTH+10	; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+10			; 14
       sta_val(i+15) and									// sta B				; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH+10	; 16
       sta_val(i+17) then									// sta B+1				; 17
     if	argMatch(i+1, i+12) and
        argMatch(i+7, i+9) and
	argMatch(i+10, i+14) and
	argMatch(i+13, i+16) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


// -----------------------------------------------------------------------------


    if tay(i+4) and										// tay					; 4

       asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       add_sub_val(i+2) and									// add|sub				; 2
       add_sub_val(i+3) and									// add|sub				; 3
//       tay(i+4) and										// tay					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       adc_sbc_im_0(i+6) and									// adc|sbc #$00				; 6
       sta_a(i+7) then										// sta					; 7
      begin

	listing[i+1] := '';

	exit(false);
      end;


    if tay(i+4) and										// tay					; 4

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       add_sub_val(i+2) and									// add|sub				; 2
       add_sub_val(i+3) and									// add|sub				; 3
//       tay(i+4) and										// tay					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       adc_sbc_im_0(i+6) and									// adc|sbc #$00				; 6
       sta_a(i+7) then										// sta					; 7
      begin

	listing[i] := '';

	exit(false);
      end;


    if (sta_a(i+5) or tay(i+5)) and								// sta|tay				; 5

       lda(i) and (lda_stack(i) = false) and							// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_stack(i+4) then									// add|sub :STACKORIGIN			; 4
//       (sta_a(i+5) or tay(i+5)) then								// sta|tay				; 5
      begin

        if add_stack(i+4) then
	 listing[i+4] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+4] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+1] := '';

	exit(false);
      end;


    if (sta_a(i+6) or tay(i+6)) and								// sta|tay				; 6

       lda(i) and (lda_stack(i) = false) and							// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub_stack(i+3) and									// add|sub :STACKORIGIN			; 3
       add_sub_val(i+4) and									// add|sub				; 4
       and_ora_eor_val(i+5) then								// and|ora|eor				; 5	~:STACKORIGIN
//       (sta_a(i+6) or tay(i+6)) then								// sta|tay				; 6
     if argMatch(i+1, i+3) then
      begin

        if add_stack(i+3) then
	 listing[i+3] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+3] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+1] := '';

	exit(false);
      end;


    if (sta_a(i+7) or tay(i+7)) and								// sta|tay				; 7

       lda(i) and (lda_stack(i) = false) and							// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_stack(i+4) and									// add|sub :STACKORIGIN			; 4
       add_sub_val(i+5) and									// add|sub				; 5
       and_ora_eor_val(i+6) then								// and|ora|eor				; 6	~:STACKORIGIN
//       (sta_a(i+7) or tay(i+7)) then								// sta|tay				; 7
     if argMatch(i+1, i+4) then
      begin

        if add_stack(i+4) then
	 listing[i+4] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+4] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+1] := '';

	exit(false);
      end;


    if (sta_a(i+7) or tay(i+7)) and								// sta|tay				; 7

       lda(i) and (lda_stack(i) = false) and							// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_stack(i+4) and									// add|sub :STACKORIGIN			; 4
       asl_a(i+5) and										// asl @				; 5
       add_sub_val(i+6) then									// add|sub				; 6
//       (sta_a(i+7) or tay(i+7)) then								// sta|tay				; 7
     if argMatch(i+1, i+4) then
       begin

	if add_stack(i+4) then
	 listing[i+4] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+4] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+1] := '';

	exit(false);
       end;


    if (sta_a(i+7) or tay(i+7)) and								// sta|tay				; 7

       lda(i) and (lda_stack(i) = false) and							// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_val(i+4) and 									// add|sub				; 4
       asl_a(i+5) and										// asl @				; 5
       add_sub_stack(i+6) then									// add|sub :STACKORIGIN			; 6
//       (sta_a(i+7) or tay(i+7)) then								// sta|tay				; 7
     if argMatch(i+1, i+6) then
       begin

	if add_stack(i+6) then
	 listing[i+6] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+6] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+1] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if (lda_a(i) or rol_a(i)) and								// lda|rol @				; 0
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       rol_stack(i+2) then									// rol :STACKORIGIN+STACKWIDTH		; 2
    begin


    if lda_a(i+3) then								// lda					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+5) and								// lda					; 5

       asl_stack(i+3) and							// asl :STACKORIGIN			; 3
       rol_stack(i+4) then							// rol :STACKORIGIN+STACKWIDTH		; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+7) and								// lda					; 7

       asl_stack(i+3) and							// asl :STACKORIGIN			; 3
       rol_stack(i+4) and							// rol :STACKORIGIN+STACKWIDTH		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN			; 5
       rol_stack(i+6) then							// rol :STACKORIGIN+STACKWIDTH		; 6
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+9) and								// lda					; 9

       asl_stack(i+3) and							// asl :STACKORIGIN			; 3
       rol_stack(i+4) and							// rol :STACKORIGIN+STACKWIDTH		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN			; 5
       rol_stack(i+6) and							// rol :STACKORIGIN+STACKWIDTH		; 6
       asl_stack(i+7) and							// asl :STACKORIGIN			; 7
       rol_stack(i+8) then							// rol :STACKORIGIN+STACKWIDTH		; 8
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+11) and								// lda					; 11

       asl_stack(i+3) and							// asl :STACKORIGIN			; 3
       rol_stack(i+4) and							// rol :STACKORIGIN+STACKWIDTH		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN			; 5
       rol_stack(i+6) and							// rol :STACKORIGIN+STACKWIDTH		; 6
       asl_stack(i+7) and							// asl :STACKORIGIN			; 7
       rol_stack(i+8) and							// rol :STACKORIGIN+STACKWIDTH		; 8
       asl_stack(i+9) and							// asl :STACKORIGIN			; 9
       rol_stack(i+10) then							// rol :STACKORIGIN+STACKWIDTH		; 10
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+13) and								// lda					; 13

       asl_stack(i+3) and							// asl :STACKORIGIN			; 3
       rol_stack(i+4) and							// rol :STACKORIGIN+STACKWIDTH		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN			; 5
       rol_stack(i+6) and							// rol :STACKORIGIN+STACKWIDTH		; 6
       asl_stack(i+7) and							// asl :STACKORIGIN			; 7
       rol_stack(i+8) and							// rol :STACKORIGIN+STACKWIDTH		; 8
       asl_stack(i+9) and							// asl :STACKORIGIN			; 9
       rol_stack(i+10) and							// rol :STACKORIGIN+STACKWIDTH		; 10
       asl_stack(i+11) and							// asl :STACKORIGIN			; 11
       rol_stack(i+12) then							// rol :STACKORIGIN+STACKWIDTH		; 12
      begin
	listing[i] := '';

	exit(false);
      end;


    end;


// -----------------------------------------------------------------------------


    if (lda_a(i) or rol_a(i)) and								// lda|rol @				; 0
       asl_stack(i+1) then									// asl :STACKORIGIN			; 1
    begin


    if lda_a(i+2) then								// lda				; 2
      begin
	listing[i] := '';

	exit(false);
      end;


    if (mwy_bp2(i+2) or ldy(i+2)) and						// mwy|ldy			; 2
       lda_a(i+3) then								// lda				; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if rol_a(i+2) and								// rol @			; 2
       lda_a(i+3) then								// lda				; 3
      begin
	listing[i] := '';

	listing[i+2] := '';

	exit(false);
      end;


    if rol_a(i+2) and								// rol @			; 2
       (mwy_bp2(i+3) or ldy(i+3)) and						// mwy|ldy			; 3
       lda_a(i+4) then								// lda				; 4
      begin
	listing[i] := '';

	listing[i+2] := '';

	exit(false);
      end;


    if rol_a(i+2) and								// rol @			; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       mwy_bp2(i+5) and								// mwy				; 5
       ldy(i+6) and								// ldy				; 6
       lda_a(i+7) then								// lda				; 7
      begin
	listing[i] := '';

	listing[i+2] := '';

	exit(false);
      end;


    if rol_a(i+2) and								// rol @			; 2
       mwy_bp2(i+3) and								// mwy				; 3
       ldy(i+4) and								// ldy				; 4
       lda_a(i+5) then								// lda				; 5
      begin
	listing[i] := '';

	listing[i+2] := '';

	exit(false);
      end;


    if rol_a(i+2) and								// rol @			; 2
       mwy_bp2(i+3) and								// mwy				; 3
       ldy(i+4) and								// ldy				; 4
       iny(i+5) and								// iny				; 5
       lda_a(i+6) then								// lda				; 6
      begin
	listing[i] := '';

	listing[i+2] := '';

	exit(false);
      end;


    if mwy_bp2(i+2) and								// mwy				; 2
       ldy(i+3) and								// ldy				; 3
       lda_a(i+4) then								// lda				; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+3) and								// lda				; 3

       asl_stack(i+2) then							// asl :STACKORIGIN		; 2
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+4) and								// lda				; 4

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       (mwy_bp2(i+3) or ldy(i+3)) then						// mwy|ldy			; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+5) and								// lda				; 5

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       (mwy_bp2(i+4) or ldy(i+4)) then						// mwy|ldy			; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+6) and								// lda				; 6

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       (mwy_bp2(i+5) or ldy(i+5)) then						// mwy|ldy			; 5
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+7) and								// lda				; 7

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN		; 5
       (mwy_bp2(i+6) or ldy(i+6)) then						// mwy|ldy			; 6
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+8) and								// lda				; 8

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN		; 5
       asl_stack(i+6) and							// asl :STACKORIGIN		; 6
       (mwy_bp2(i+7) or ldy(i+7)) then						// mwy|ldy			; 7
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+4) and								// lda				; 4

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) then							// asl :STACKORIGIN		; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+5) and								// lda				; 5

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) then							// asl :STACKORIGIN		; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+6) and								// lda				; 6

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       asl_stack(i+5) then							// asl :STACKORIGIN		; 5
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+7) and								// lda				; 7

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN		; 5
       asl_stack(i+6) then							// asl :STACKORIGIN		; 6
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda_a(i+8) and								// lda				; 8

       asl_stack(i+2) and							// asl :STACKORIGIN		; 2
       asl_stack(i+3) and							// asl :STACKORIGIN		; 3
       asl_stack(i+4) and							// asl :STACKORIGIN		; 4
       asl_stack(i+5) and							// asl :STACKORIGIN		; 5
       asl_stack(i+6) and							// asl :STACKORIGIN		; 6
       asl_stack(i+7) then							// asl :STACKORIGIN		; 7
      begin
	listing[i] := '';

	exit(false);
      end;


    end;

end;		// function
