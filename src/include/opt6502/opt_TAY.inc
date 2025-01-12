
function opt_TAY(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===		     		      TAY.
// -----------------------------------------------------------------------------

    if lda_a(i) and (iy(i) = false) and								// lda					; 0
       tay(i+1) and										// tay					; 1
       lda_a(i+2) then										// lda					; 2
     begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';

	exit(false);
     end;


    if lda(i) and (iy(i) = false) and								// lda					; 0
       (listing[i+1] = #9'sub #$01') and							// sub #$01				; 1
       tay(i+2) and 										// tay					; 2
												// lda					; 3
       (sbc(i+4) = false) then									//~sbc					; 4
     begin
	if lda_im(i) then begin
	 p := GetBYTE(i);

	 listing[i]   := #9'ldy #$' + IntToHex((p-1) and $ff, 2);
	 listing[i+1] := '';
	 listing[i+2] := '';

	end else begin
	 listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	 listing[i+1] := #9'dey';
	 listing[i+2] := '';
	end;

	exit(false);
     end;


    if tya(i) and										// tya					; 0
       (listing[i+1] = #9'add #$01') and							// add #$01				; 1
       tay(i+2) and										// tay					; 2
       (SKIP(i+3) = false) then									// SKIP					; 3
      begin
	listing[i]   := #9'iny';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if tya(i) and										// tya					; 0
       (listing[i+1] = #9'sub #$01') and							// sub #$01				; 1
       tay(i+2) and										// tay					; 2
       (SKIP(i+3) = false) then									// SKIP					; 3
      begin
	listing[i]   := #9'dey';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda					; 0
       (listing[i+1] = #9'add #$01') and							// add #$01				; 1
       tay(i+2) and										// tay					; 2
       lda(i+3) and										// lda					; 3
       add(i+4) then										// add					; 4
      begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'iny';
	listing[i+2] := '';

	exit(false);
      end;


    if add_im_0(i) and										// add #$00				; 0
       tay(i+1) and										// tay					; 1
												//					; 2
       (adc(i+3) = false) then									//~adc					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if sub_im_0(i) and										// sub #$00				; 0
       tay(i+1) and										// tay					; 1
												//					; 2
       (sbc(i+3) = false) then									//~sbc					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda					; 0
       tay(i+1) then										// tay					; 1
      begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';

	exit(false);
      end;


    if tay(i+2) and										// tay					; 2

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_a(i+1) and										// asl @				; 1
//       tay(i+2) and										// tay					; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_stack(i+4) then									// sta :STACKORIGIN			; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i] := '';

	exit(false);
      end;


    if tay(i+3) and										// tay					; 3

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
//       tay(i+3) and										// tay					; 3
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_stack(i+5) then									// sta :STACKORIGIN			; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i] := '';

	exit(false);
      end;


    if tay(i+4) and										// tay					; 4

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       add_sub_stack(i+3) and									// add|sub :STACKORIGIN			; 3
//       tay(i+4) and										// tay					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       adc_sbc_stack(i+6) then									// adc|sbc :STACKORIGIN+STACKWIDTH	; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

      	exit(false);
     end;


    if tay(i+4) and										// tay					; 4

       lda_stack(i) and										// lda :STACKORIGIN+STACKWIDHT*2	; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       add_sub_stack(i+3) and									// add|sub :STACKORIGIN			; 3
//       tay(i+4) and										// tay					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       adc_sbc_stack(i+6) then									// adc|sbc :STACKORIGIN+STACKWIDTH	; 6
     if (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

      	exit(false);
     end;


    if tay(i+4) and										// tay					; 4

       lda_a(i) and (iy(i) = false) and	(EAX(i) = false) and					// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       asl_a(i+3) and										// asl @				; 3
//       tay(i+4) and										// tay					; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       sta_a(i+6) and										// sta					; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH		; 7
       sta_a(i+8) then										// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+7] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if tay(i+5) and										// tay					; 5

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH+10	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda(i+3) and										// lda					; 3
       asl_a(i+4) and										// asl @				; 4
//       tay(i+5) and										// tay					; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+10			; 6
       sta_a(i+7) and										// sta					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH+10	; 8
       sta_a(i+9) then										// sta					; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+6] := listing[i];
	listing[i+8] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if tay(i+6) and										// tay					; 6

       lda_a(i) and (iy(i) = false) and	(EAX(i) = false) and					// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and										// lda					; 4
       asl_a(i+5) and										// asl @				; 5
//       tay(i+6) and										// tay					; 6
       lda_stack(i+7) and									// lda :STACKORIGIN			; 7
       sta_a(i+8) and										// sta					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH		; 9
       sta_a(i+10) then										// sta					; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
	listing[i+7] := listing[i];

	listing[i+9] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if tay(i+6) and										// tay					; 6

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       asl_a(i+5) then										// asl @				; 5
//       tay(i+6) then										// tay					; 6
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if tay(i+8) and										// tay					; 8

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       add_sub(i+1) and (iy(i+1) = false) and							// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and (iy(i+3) = false) and							// lda					; 3
       adc_sbc(i+4) and (iy(i+4) = false) and							// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_a(i+6) and										// lda					; 6
       asl_a(i+7) and										// asl @				; 7
//       tay(i+8) and										// tay					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+9			; 9
       sta_val(i+10) and									// sta ~:STACKORIGIN			; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH+9	; 11
       sta_val(i+12) then									// sta ~:STACKORIGIN			; 12
     if	(copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then
      begin

       listing_tmp[0] := listing[i+6];
       listing_tmp[1] := listing[i+7];
       listing_tmp[2] := listing[i+8];

       listing_tmp[3] := listing[i];
       listing_tmp[4] := listing[i+1];
       listing_tmp[5] := listing[i+10];

       listing_tmp[6] := listing[i+3];
       listing_tmp[7] := listing[i+4];
       listing_tmp[8] := listing[i+12];

       listing[i+9]  := '';
       listing[i+10] := '';
       listing[i+11] := '';
       listing[i+12] := '';

       for p:=0 to 8 do listing[i+p] := listing_tmp[p];

       exit(false);
      end;


    if tay(i+11) and										// tay					; 11

       lda_a(i) and (iy(i) = false) and (EAX(i) = false) and					// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and (iy(i+4) = false) and							// lda					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_a(i+6) and (iy(i+6) = false) and							// lda					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lda_a(i+8) and										// lda					; 8
       asl_a(i+9) and										// asl @				; 9
       asl_a(i+10) and										// asl @				; 10
//       tay(i+11) and										// tay					; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta_a(i+13) and										// sta					; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_a(i+15) and										// sta					; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*2	; 16
       sta_a(i+17) and										// sta					; 17
       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH*3	; 18
       sta_a(i+19) then										// sta					; 19
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
      begin
	listing[i+12] := listing[i];
	listing[i+14] := listing[i+2];
	listing[i+16] := listing[i+4];
	listing[i+18] := listing[i+6];

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


// -----------------------------------------------------------------------------


    if lda_a(i) and (listing[i] = listing[i+5]) and						// lda I				; 0

       add_im(i+1) and (listing[i+1] = listing[i+6]) and					// add #AB				; 1
       asl_a(i+2) and 										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
//       lda_a(i+5) and										// lda I				; 5
//       add_im(i+6) and									// add #AB				; 6
       asl_a(i+7) and										// asl @				; 7
       asl_a(i+8) then										// asl @				; 8
      begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


    if tay(i+5) and										// tay					; 5

       lda_a(i) and (listing[i] = listing[i+3]) and						// lda I				; 0
       asl_a(i+1) and 										// asl @				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
//       lda_a(i+3) and										// lda I				; 3
       asl_a(i+4) then										// asl @				; 4
//       tay(i+5) then										// tay					; 5
      begin
	listing[i+3] := #9'sty ' + copy(listing[i+2], 6, 256);

	listing[i+2] := #9'tay';

	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if tay(i+7) and										// tay					; 7

       lda_a(i) and (listing[i] = listing[i+4]) and						// lda I				; 0
       asl_a(i+1) and 										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
//       lda_a(i+4) and										// lda I				; 4
       asl_a(i+5) and										// asl @				; 5
       asl_a(i+6) then										// asl @				; 6
//       tay(i+7) then										// tay					; 7
      begin
	listing[i+4] := #9'sty ' + copy(listing[i+3], 6, 256);

	listing[i+3] := #9'tay';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
      end;


   if tay(i+7) and										// tay					; 7

       lda(i) and (listing[i] = listing[i+5]) and						// lda U				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
//       lda(i+5) and										// lda U				; 5
       asl_a(i+6) and										// asl @				; 6
//       tay(i+7) and										// tay					; 7
       lda_adr(i+8) and										// lda adr.				; 8
       add_sub_stack(i+9) and									// add|sub :STACKORIGIN			; 9
       sta(i+10) then										// sta U				; 10
     if (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	if add_stack(i+9) then
	 listing[i+8] := #9'add ' + copy(listing[i+8], 6, 256)
	else
	 listing[i+8] := #9'sub ' + copy(listing[i+8], 6, 256);

	listing[i+9] := '';

	exit(false);
       end;


    if tay(i+7) and										// tay					; 7

       lda(i) and (listing[i] = listing[i+5]) and						// lda U				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda_adr(i+3) and										// lda adr.MX,y				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
//       lda(i+5) and										// lda U				; 5
       asl_a(i+6) and										// asl @				; 6
//       tay(i+7) and										// tay					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN			; 8
       add_sub(i+9) and										// add|sub				; 9
       sta(i+10) then										// sta U				; 10
     if (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
       end;


    if tay(i+8) and										// tay					; 8

       lda_a(i) and (listing[i] = listing[i+5]) and						// lda I				; 0
       asl_a(i+1) and 										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       mwy_bp2(i+4) and										// mwy					; 4
       lda_a(i+5) and										// lda I				; 5
       asl_a(i+6) and										// asl @				; 6
       asl_a(i+7) then										// asl @				; 7
//       tay(i+8) then										// tay					; 8
      begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
      end;


    if tay(i+9) and										// tay					; 9

       lda_a(i) and (listing[i] = listing[i+5]) and						// lda I				; 0
       asl_a(i+1) and 										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
//       lda_a(i+5) and										// lda I				; 5
       asl_a(i+6) and										// asl @				; 6
       asl_a(i+7) and										// asl @				; 7
       asl_a(i+8) then										// asl @				; 8
//       tay(i+9) then										// tay					; 9
      begin
	listing[i+5] := #9'sty ' + copy(listing[i+4], 6, 256);

	listing[i+4] := #9'tay';

	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
      end;


    if tay(i+9) and										// tay					; 9

       lda(i) and (listing[i] = listing[i+7]) and						// lda I				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda_adr(i+3) and										// lda adr.BALL,y			; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_adr(i+5) and										// lda adr.BALL+1,y			; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH		; 6
//       lda(i+7) and										// lda I				; 7
       asl_a(i+8) and										// asl @				; 8
//       tay(i+9) and										// tay					; 9
       lda_stack(i+10) and									// lda :STACKORIGIN			; 10
       add_sub(i+11) and									// add|sub				; 11
       sta(i+12) and										// sta T				; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH		; 13
       adc_sbc(i+14) and									// adc|sbc				; 14
       sta(i+15) then										// sta T+1				; 15
     if (copy(listing[i+4], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+13], 6, 256)) then
       begin
	listing[i+10] := listing[i+3];
	listing[i+13] := listing[i+5];

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
       end;


    if tay(i+9) and										// tay					; 9

       lda_a(i) and (listing[i] = listing[i+7]) and						// lda A				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda_adr(i+3) and 									// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_adr(i+5) and										// lda adr.				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH		; 6
//       lda_a(i+7) and										// lda A				; 7
       asl_a(i+8) and										// asl @				; 8
//       tay(i+9) and										// tay					; 9
       lda_stack(i+10) and									// lda :STACKORIGIN			; 10
       sta_adr(i+11) and									// sta adr.				; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH		; 12
       sta_adr(i+13) then									// sta adr.				; 13
     if (copy(listing[i+4], 6, 256) = copy(listing[i+10], 6, 256)) and
        (copy(listing[i+6], 6, 256) = copy(listing[i+12], 6, 256)) then
      begin
	listing[i+4] := listing[i+11];

	listing[i+6] := listing[i+13];

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
      end;


    if tay(i+11) and										// tay					; 11

       ldy(i) and (listing[i] = listing[i+7]) and						// ldy I				; 0
       lda_adr(i+1) and (listing[i+1] = listing[i+8]) and					// lda adr.				; 1
       asl_a(i+2) and 										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       tay(i+4) and										// tay					; 4
       lda_adr(i+5) and										// lda adr.				; 5
       sta_a(i+6) and										// sta					; 6
//       ldy(i+7) and										// ldy I				; 7
//       lda_adr(i+8) and									// lda adr.				; 8
       asl_a(i+9) and 										// asl @				; 9
       asl_a(i+10) then										// asl @				; 10
//       tay(i+11) then										// tay					; 11
     if (copy(listing[i+6], 6, 256) <> copy(listing[i+7], 6, 256)) and
        (copy(listing[i+6], 6, 256) <> copy(listing[i+8], 6, 256)) then
      begin
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	exit(false);
      end;


    if tay(i+11) and										// tay					; 11

       lda_a(i) and (listing[i] = listing[i+9]) and						// lda A				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda_adr(i+3) and 									// lda adr.				; 3
       add_sub(i+4) and										// add|sub				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda_adr(i+6) and										// lda adr.				; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH		; 8
//       lda_a(i+9) and										// lda A				; 9
       asl_a(i+10) and										// asl @				; 10
//       tay(i+11) and										// tay					; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta_adr(i+13) and									// sta adr.				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_adr(i+15) then									// sta adr.				; 15
     if (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) then
      begin
	listing[i+5] := listing[i+13];

	listing[i+8] := listing[i+15];

	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	exit(false);
      end;


    if tay(i+11) and										// tay					; 11

       lda_a(i) and (listing[i] = listing[i+9]) and						// lda A				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda_a(i+3) and										// lda					; 3
       and_ora_eor(i+4) and									// and|ora|eor				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda_a(i+6) and										// lda 					; 6
       and_ora_eor(i+7) and									// and|ora|eor				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH		; 8
//       lda_a(i+9) and 									// lda A				; 9
       asl_a(i+10) and										// asl @				; 10
//       tay(i+11) and										// tay					; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta_a(i+13) and										// sta 					; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_a(i+15) then										// sta 					; 15
     if (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) then
     begin
	listing[i+5] := listing[i+13];

	listing[i+8] := listing[i+15];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

      	exit(false);
     end;


    if tay(i+13) and										// tay					; 13

       lda_a(i) and (listing[i] = listing[i+7]) and						// lda I				; 0
       asl_a(i+1) and 										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub(i+3) and	(listing[i+3] = listing[i+10]) and					// add|sub A				; 3
       asl_a(i+4) and										// asl @				; 4
       add_sub(i+5) and (listing[i+5] = listing[i+12]) and					// add|sub B				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN			; 6
//       lda_a(i+7) and										// lda I				; 7
       asl_a(i+8) and 										// asl @				; 8
       asl_a(i+9) and										// asl @				; 9
//       add_sub(i+10) and									// add|sub A				; 10
       asl_a(i+11) then										// asl @				; 11
//       add_sub(i+12) and									// add|sub B				; 12
//       tay(i+13) then										// tay					; 13
      begin
	listing[i+7] := #9'sty ' + copy(listing[i+6], 6, 256);

	listing[i+6] := #9'tay';

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
      end;


    if tay(i+19) and										// tay					; 19

       lda_a(i) and (listing[i] = listing[i+16]) and						// lda A				; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       tay(i+3) and										// tay					; 3
       lda_a(i+4) and										// lda					; 4
       and_ora_eor(i+5) and									// and|ora|eor				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN			; 6
       lda_a(i+7) and										// lda 					; 7
       and_ora_eor(i+8) and									// and|ora|eor				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH		; 9
       lda_a(i+10) and										// lda 					; 10
       and_ora_eor(i+11) and									// and|ora|eor				; 11
       sta_stack(i+12) and									// sta :STACKORIGIN+STACKWIDTH*2	; 12
       lda_a(i+13) and										// lda 					; 13
       and_ora_eor(i+14) and									// and|ora|eor				; 14
       sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*3	; 15
//       lda_a(i+16) and 									// lda A				; 16
       asl_a(i+17) and										// asl @				; 17
       asl_a(i+18) and										// asl @				; 18
//       tay(i+19) and										// tay					; 19
       lda_stack(i+20) and									// lda :STACKORIGIN			; 20
       sta_a(i+21) and										// sta 					; 21
       lda_stack(i+22) and									// lda :STACKORIGIN+STACKWIDTH		; 22
       sta_a(i+23) and										// sta 					; 23
       lda_stack(i+24) and									// lda :STACKORIGIN+STACKWIDTH*2	; 24
       sta_a(i+25) and										// sta 					; 25
       lda_stack(i+26) and									// lda :STACKORIGIN+STACKWIDTH*3	; 26
       sta_a(i+27) then										// sta 					; 27
     if (copy(listing[i+6], 6, 256) = copy(listing[i+20], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+12], 6, 256) = copy(listing[i+24], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+26], 6, 256)) then
     begin
	listing[i+6] := listing[i+21];

	listing[i+9] := listing[i+23];

	listing[i+12] := listing[i+25];

	listing[i+15] := listing[i+27];

	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';

      	exit(false);
     end;


// -----------------------------------------------------------------------------


    if (lda_adr(i+4) or sta_adr(i+5)) and							// lda adr.|				; 4
												//         |sta adr.			; 5

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       add_sub_val(i+2) and									// add|sub				; 2
       tay(i+3) then										// tay					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+5) or sta_adr(i+6)) and							// lda adr.|				; 5
												//         |sta adr.			; 6

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub_val(i+3) and									// add|sub				; 3
       tay(i+4) then										// tay					; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+6) or sta_adr(i+7)) and							// lda adr.|				; 6
												//         |sta adr.			; 7

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_val(i+4) and									// add|sub				; 4
       tay(i+5) then										// tay					; 5
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+7) or sta_adr(i+8)) and							// lda adr.|				; 7
												//         |sta adr.			; 8

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       asl_a(i+4) and										// asl @				; 4
       add_sub_val(i+5) and									// add|sub				; 5
       tay(i+6) then										// tay					; 6
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+2) or sta_adr(i+3)) and							// lda adr.|				; 2
												//         |sta adr.			; 3

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       tay(i+1) then										// tay					; 1
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+3) or sta_adr(i+4)) and							// lda adr.|				; 3
												//         |sta adr.			; 4

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) then										// tay					; 2
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+4) or sta_adr(i+5)) and							// lda adr.|				; 4
												//         |sta adr.			; 5

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       tay(i+3) then										// tay					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+4) or sta_adr(i+5)) and							// lda adr.|				; 4
												//         |sta adr.			; 5

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       add_sub_val(i+1) and									// add|sub				; 1
       add_sub_val(i+2) and									// add|sub				; 2
       tay(i+3) then										// tay					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+5) or sta_adr(i+6)) and							// lda adr.|				; 5
												//         |sta adr.			; 6

       rol_a(i) and										// rol @				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda A				; 2
       add_sub_stack(i+3) and									// add|sub :STACKORIGIN			; 3
       tay(i+4) then										// tay					; 4
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+5) or sta_adr(i+6)) and							// lda adr.|				; 5
												//         |sta adr.			; 6

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       add_sub_val(i+2) and									// add|sub				; 2
       add_sub_val(i+3) and 									// add|sub				; 3
       tay(i+4) then										// tay					; 4
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+6) or sta_adr(i+7)) and							// lda adr.|				; 6
												//         |sta adr.			; 7

       asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_a(i+1) and										// rol @				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_stack(i+3) and									// lda :STACKORIGIN			; 3
       add_sub_val(i+4) and 									// add|sub				; 4
       tay(i+5) then										// tay					; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if (lda_adr(i+6) or sta_adr(i+7)) and							// lda adr.|				; 6
												//         |sta adr.			; 7

       asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       add_sub(i+2) and										// add|sub				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_val(i+4) and									// add|sub				; 4
       tay(i+5) then										// tay					; 5
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+6) or sta_adr(i+7)) and							// lda adr.|				; 6
												//         |sta adr.			; 7

       rol_a(i) and										// rol @				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda A				; 2	~:STACKORIGIN
       and_ora_eor_val(i+3) and									// and|ora|eor				; 3	~:STACKORIGIN
       add_sub_stack(i+4) and									// add|sub :STACKORIGIN			; 4
       tay(i+5) then										// tay					; 5
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+6) or sta_adr(i+7)) and							// lda adr.|				; 6
												//         |sta adr.			; 7

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub_val(i+3) and									// add|sub				; 3
       add_sub_val(i+4) and 									// add|sub				; 4
       tay(i+5) then										// tay					; 5
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+7) or sta_adr(i+8)) and							// lda adr.|				; 7
												//         |sta adr.			; 8

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_val(i+4) and									// add|sub				; 4
       add_sub_val(i+5) and									// add|sub				; 5
       tay(i+6) then										// tay					; 6
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+8) or sta_adr(i+9)) and							// lda adr.|				; 8
												//         |sta adr.			; 9

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       asl_a(i+4) and										// asl @				; 4
       add_sub_val(i+5) and									// add|sub				; 5
       add_sub_val(i+6) and 									// add|sub				; 6
       tay(i+7) then										// tay					; 7
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+7) or sta_adr(i+8)) and							// lda adr.|				; 7
												//         |sta adr.			; 8

       asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub(i+3) and										// add|sub				; 3
       asl_a(i+4) and										// asl @				; 4
       add_sub_val(i+5) and									// add|sub				; 5
       tay(i+6) then										// tay					; 6
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+7) or sta_adr(i+8)) and							// lda adr.|				; 7
												//         |sta adr.			; 8

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       add_sub_val(i+1) and									// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_val(i+3) and										// lda I				; 3	~:STACKORIGIN
       and_ora_eor_val(i+4) and									// and|ora|eor				; 4	~:STACKORIGIN
       add_sub_stack(i+5) and									// add|sub :STACKORIGIN			; 5
       tay(i+6) then										// tay					; 6
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+8) or sta_adr(i+9)) and							// lda adr.|				; 8
												//         |sta adr.			; 9

       add_sub(i) and										// add|sub				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and									// lda :STACKORIGIN			; 5
       add_sub_val(i+6) and									// add|sub				; 6
       tay(i+7) then										// tay					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

      	exit(false);
     end;


    if (lda_adr(i+8) or sta_adr(i+9)) and							// lda adr.|				; 8
												//         |sta adr.			; 9

       lda_val(i) and										// lda A				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       asl_a(i+2) and										// asl @				; 2
       asl_a(i+3) and										// asl @				; 3
       add_sub_stack(i+4) and									// add|sub :STACKORIGIN			; 4
       asl_a(i+5) and										// asl @				; 5
       add_sub_val(i+6) and									// add|sub ~:STACKORIGIN		; 6
       tay(i+7) then										// tay					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i+1] := '';

	if add_stack(i+4) then
	 listing[i+4] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+4] := #9'sub ' + copy(listing[i], 6, 256);

	exit(false);
       end;


    if (lda_adr(i+8) or sta_adr(i+9)) and							// lda adr.|				; 8
												//         |sta adr.			; 9

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       add_sub_val(i+2) and									// add|sub				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       lda_val(i+4) and										// lda I				; 4	~:STACKORIGIN
       and_ora_eor_val(i+5) and									// and|ora|eor				; 5	~:STACKORIGIN
       add_sub_stack(i+6) and									// add|sub :STACKORIGIN			; 6
       tay(i+7) then										// tay					; 7
     if (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+9) or sta_adr(i+10)) and							// lda adr.|				; 9
												//         |sta adr.			; 10

       asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       add_sub_stack(i+2) and									// add|sub :STACKORIGIN			; 2
       asl_a(i+3) and										// asl @				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       and_ora_eor(i+6) and									// and|ora|eor				; 6
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN			; 7
       tay(i+8) then										// tay					; 8
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+9) or sta_adr(i+10)) and							// lda adr.|				; 9
												//         |sta adr.			; 10

       add_sub(i) and										// add|sub A				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+STACKWIDTH		; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_val(i+5) and										// lda I				; 5	~:STACKORIGIN
       and_ora_eor_val(i+6) and									// and|ora|eor				; 6	~:STACKORIGIN
       add_sub_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) then										// tay					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
       end;


    if (lda_adr(i+9) or sta_adr(i+10)) and							// lda adr.|				; 9
												//         |sta adr.			; 10

       rol_stack(i) and										// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and										// asl @				; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub_val(i+3) and 									// add|sub				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_val(i+5) and										// lda I				; 5	~:STACKORIGIN
       and_ora_eor_val(i+6) and									// and|ora|eor				; 6	~:STACKORIGIN
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN			; 7
       tay(i+8) then										// tay					; 8
     if (copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+10) or sta_adr(i+11)) and							// lda adr.|				; 10
												//         |sta adr.			; 11

       asl_a(i) and										// asl @				; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and										// asl @				; 2
       add_sub_stack(i+3) and									// add|sub :STACKORIGIN			; 3
       asl_a(i+4) and										// asl @				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       and_ora_eor(i+7) and									// and|ora|eor				; 7
       add_sub_stack(i+8) and									// add|sub :STACKORIGIN			; 8
       tay(i+9) then										// tay					; 9
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+9) or sta_adr(i+10)) and							// lda adr.|				; 9
												//         |sta adr.			; 10

       add_sub(i) and										// add|sub				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       asl_stack(i+5) and									// asl :STACKORIGIN			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       add_sub_val(i+7) and 									// add|sub				; 7
       tay(i+8) then										// tay					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

      	exit(false);
     end;


    if (lda_adr(i+9) or sta_adr(i+10)) and							// lda adr.|				; 9
												//         |sta adr.			; 10

       add_sub(i) and										// add|sub				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       asl_stack(i+5) and									// asl :STACKORIGIN			; 5
       lda_val(i+6) and										// lda 					; 6	~:STACKORIGIN
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN			; 7
       tay(i+8) then										// tay					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

      	exit(false);
     end;


    if (lda_adr(i+5) or sta_adr(i+6)) and							// lda adr.|				; 5
												//         |sta adr.			; 6

       asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       lda_stack(i+2) and									// lda :STACKORIGIN			; 2
       add_sub_val(i+3) and									// add|sub 				; 3
       tay(i+4) then										// tay					; 4
     if ((copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256))) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if (lda_adr(i+4) or sta_adr(i+5)) and							// lda adr.|				; 4
												//         |sta adr.			; 5

       rol_a(i) and										// rol @				; 0
       lda_a(i+1) and										// lda					; 1
       asl_a(i+2) and										// asl @				; 2
       tay(i+3) then										// tay					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_adr(i+5) or sta_adr(i+6)) and							// lda adr.|				; 5
												//         |sta adr.			; 6

       asl_stack(i) and										// asl :STACKORIGIN			; 0
       rol_stack(i+1) and									// rol :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       add_sub_stack(i+3) and									// add|sub :STACKORIGIN			; 3
       tay(i+4) then										// tay					; 4
     if ((copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256))) then
       begin
	listing[i+1] := '';

	exit(false);
       end;

end;		// function