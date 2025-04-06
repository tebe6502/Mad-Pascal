
function opt_STA_ADD(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      ADD.
// -----------------------------------------------------------------------------

    if sta_stack(i) and									// sta :STACKORIGIN+9			; 0
       lda_a(i+1) and		 							// lda					; 1
       add_stack(i+2) then								// add :STACKORIGIN+9			; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
	listing[i]   := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if lda(i) and									// lda DX 				; 0
       add(i+1) and									// add DX				; 1
       sta(i+2) and									// sta DX				; 2
       lda(i+3) and									// lda DX+1				; 3
       adc(i+4) and									// adc DX+1				; 4
       sta(i+5) and									// sta DX+1				; 5
       lda(i+6) and									// lda DX+2				; 6
       adc(i+7) and									// adc DX+2				; 7
       sta(i+8) and									// sta DX+2				; 8
       lda(i+9) and									// lda DX+3				; 9
       adc(i+10) and									// adc DX+3				; 10
       sta(i+11) then									// sta DX+3				; 11
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+7], 6, 256)) and
	 (copy(listing[i+7], 6, 256) = copy(listing[i+8], 6, 256)) and
	 (copy(listing[i+9], 6, 256) = copy(listing[i+10], 6, 256)) and
	 (copy(listing[i+10], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'rol ' + copy(listing[i+3], 6, 256);
	listing[i+2] := #9'rol ' + copy(listing[i+6], 6, 256);
	listing[i+3] := #9'rol ' + copy(listing[i+9], 6, 256);

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


    if lda(i) and									// lda DX 				; 0
       add(i+1) and									// add DX				; 1
       sta(i+2) and									// sta DX				; 2
       lda(i+3) and									// lda DX+1				; 3
       adc(i+4) and									// adc DX+1				; 4
       sta(i+5) and									// sta DX+1				; 5
											//					; 6
       (adc(i+7) = false) then								//~adc					; 7
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+4], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'rol ' + copy(listing[i+3], 6, 256);

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if lda(i) and									// lda DX 				; 0
       add(i+1) and									// add DX				; 1
       sta(i+2) and									// sta DX				; 2
											//					; 3
       (adc(i+4) = false) then								//~adc					; 4
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if lda(i) and									// lda DX 				; 0
       add(i+1) and									// add DX				; 1
       sta(i+2) and									// sta					; 2
											//					; 3
       (adc(i+4) = false) then								//~adc					; 4
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) then
       begin
	listing[i+1] := #9'asl @';

	exit(false);
       end;


    if lda(i) and									// lda DX 				; 0
       add(i+1) and									// add DX				; 1
       add(i+2) and									// add DX				; 2
       add(i+3) and									// add DX				; 3
       sta(i+4) and									// sta DX				; 4
											//					; 5
       (adc(i+6) = false) then								//~adc					; 6
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+2], 6, 256) = copy(listing[i+3], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i]   := #9'asl ' + copy(listing[i], 6, 256);
	listing[i+1] := listing[i];
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
       end;


    if lda(i) and									// lda DX 				; 0
       add(i+1) and									// add DX				; 1
       add(i+2) and									// add DX				; 2
       add(i+3) and									// add DX				; 3
       sta(i+4) and									// sta					; 4
											//					; 5
       (adc(i+6) = false) then								//~adc					; 6
      if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) and
	 (copy(listing[i+2], 6, 256) = copy(listing[i+3], 6, 256)) and
	 (copy(listing[i+3], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := '';

	exit(false);
       end;


// add !!!

    if (lda_a(i) = false) and								//~lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda					; 3
       adc_sbc_im_0(i+4) and								// adc|sbc #$00				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add_sub(i+7) and									// add|sub				; 7
       sta(i+8) and 									// sta D				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_sbc_im_0(i+10) and								// adc|sbc #$00				; 10
       sta(i+11) then									// sta D+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+6] := listing[i+11];
	listing[i+5] := listing[i+4];
	listing[i+4] := listing[i+3];
	listing[i+3] := listing[i+8];
	listing[i+2] := listing[i+1];

	listing[i+1] := listing[i+7];

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if lda_im_0(i) and									// lda #$00				; 0
       add(i+1) and (add_im_0(i+1) = false) and	(iy(i+1) = false) and			// add D				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda(i+3) and									// lda					; 3
       adc(i+4) and 									// adc D+1				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add(i+7) and									// add					; 7
       sta(i+8) and 									// sta D				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_im_0(i+10) and								// adc #$00				; 10
       sta(i+11) then									// sta D+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := listing[i+7];
	listing[i+2] := listing[i+8];

	listing[i+5] := listing[i+11];
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


{!#!#!#!#!#!#!#!#!#!#!#

    if lda(i) and (lda_im_0(i) = false) and (iy(i) = false) and				// lda					; 0
       add(i+1) and (add_im_0(i+1) = false) and (iy(i+1) = false) and			// add D				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_im_0(i+3) and								// lda #$00				; 3
       adc(i+4) and (adc_im_0(i+4) = false) and						// adc D+1				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add_sub(i+7) and									// add|sub				; 7
       (sta_stack(i+8) = false) and sta(i+8) and (iy(i+8) = false) and			// sta D				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       sta(i+11) and									// sta D+1				; 11
											//					; 12
       (adc_sbc(i+13) = false) then							//~adc|sbc				; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+2] := listing[i+1];

	listing[i+1] := #9'ldy ' + copy(listing[i+11], 6, 256);

	listing[i+3] := #9'scc';
	listing[i+4] := #9'iny';

	listing[i+5] := '';
	listing[i+6] := '';

	listing[i+9] := #9'tya';

	if adc_im_0(i+10) then begin
	 listing[i+9]  := #9'scc';
	 listing[i+10] := #9'iny';
	 listing[i+11] := #9'sty ' + copy(listing[i+11], 6, 256);
	end;

	if sbc_im_0(i+10) then begin
	 listing[i+9]  := #9'scs';
	 listing[i+10] := #9'dey';
	 listing[i+11] := #9'sty ' + copy(listing[i+11], 6, 256);
	end;

	exit(false);
       end;
}


    if lda(i) and (lda_im_0(i) = false) and (iy(i) = false) and				// lda					; 0
       add_sub(i+1) and (iy(i+1) = false) and
       (add_im_0(i+1) = false) and (sub_im_0(i+1) = false) and				// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       (lda_im(i+3) = false) and lda(i+3) and (iy(i+3) = false) and			// lda					; 3
       adc_sbc_im_0(i+4) and								// adc|sbc #$00				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_val(i+8) and (iy(i+8) = false) and						// sta T				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_sbc_im_0(i+10) and								// adc|sbc #$00				; 10
       sta(i+11) and									// sta T+1				; 11
											//					; 12
       (adc_sbc(i+13) = false) then							//~adc|sbc				; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+2] := listing[i+1];

	listing[i+1] := #9'ldy ' + copy(listing[i+3], 6, 256);

	if adc_im_0(i+4) then begin
	 listing[i+3] := #9'scc';
	 listing[i+4] := #9'iny';
	end else begin
	 listing[i+3] := #9'scs';
	 listing[i+4] := #9'dey';
	end;

	listing[i+5] := '';
	listing[i+6] := '';

	listing[i+9] := #9'tya';

	if adc_im_0(i+10) then begin
	 listing[i+9]  := #9'scc';
	 listing[i+10] := #9'iny';
	 listing[i+11] := #9'sty ' + copy(listing[i+11], 6, 256);
	end else begin
	 listing[i+9]  := #9'scs';
	 listing[i+10] := #9'dey';
	 listing[i+11] := #9'sty ' + copy(listing[i+11], 6, 256);
	end;

	exit(false);
       end;


    if ((i > 0) and lda_im_0(i-1) = false) and
       add_sub(i) and (add_im_0(i) = false) and (sub_im_0(i) = false) and		// add|sub				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
       add(i+6) and									// add					; 6
       sta_val(i+7) and									// sta					; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+STACKWIDTH		; 8
       adc_im_0(i+9) and								// adc #$00				; 9
       sta_val(i+10) and (iy(i+10) = false) and						// sta					; 10
											//					; 11
       (adc(i+12) = false) then								//~adc					; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+4] := listing[i+10];

	if (listing[i+6] = #9'add #$01') and (pos(listing[i+7], listing[i+10]) > 0) then begin
	 listing[i+1] := listing[i+7];

	 listing[i+5] := #9'inc ' + copy(listing[i+7], 6, 256);
	 listing[i+6] := #9'sne';
	 listing[i+7] := #9'inc ' + copy(listing[i+10], 6, 256);
	 listing[i+8] := '';
	 listing[i+9] := '';
	 listing[i+10] := '';
	end else begin

 	 if (iy(i) = false) and (iy(i+2) = false) then begin
 	  listing[i+1] := #9'tay';

	  listing[i+5] := #9'tya';
	 end;

	 listing[i+8] := #9'scc';
	 listing[i+9] := #9'inc ' + copy(listing[i+4], 6, 256);
	 listing[i+10] := '';

	end;

	exit(false);
       end;


    if ((i > 0) and lda_im_0(i-1) = false) and
       add_sub(i) and (add_im_0(i) = false) and (sub_im_0(i) = false) and		// add|sub				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
       sub(i+6) and									// sub					; 6
       sta_val(i+7) and									// sta					; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+STACKWIDTH		; 8
       sbc_im_0(i+9) and								// sbc #$00				; 9
       sta_val(i+10) and (iy(i+10) = false) and						// sta					; 10
											//					; 11
       (sbc(i+12) = false) then								//~sbc					; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+4] := listing[i+10];

	if (listing[i+6] = #9'sub #$01') and (pos(listing[i+7], listing[i+10]) > 0) then begin
	 listing[i+1] := listing[i+7];

	 listing[i+8] := #9'dec ' + copy(listing[i+7], 6, 256);

	 listing[i+5] := #9'lda ' + copy(listing[i+7], 6, 256);
	 listing[i+6] := #9'sne';
	 listing[i+7] := #9'dec ' + copy(listing[i+10], 6, 256);

	 listing[i+9] := '';
	 listing[i+10] := '';
	end else begin

	 if (iy(i) = false) and (iy(i+2) = false) then begin
	  listing[i+1] := #9'tay';

	  listing[i+5] := #9'tya';
	 end;

	 listing[i+8] := #9'scs';
	 listing[i+9] := #9'dec ' + copy(listing[i+4], 6, 256);
	 listing[i+10] := '';

	end;

	exit(false);
       end;


    if sta_stack(i) and									// sta :STACKORIGIN+9			; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH+9	; 1
       sty_stack(i+2) and								// sty :STACKORIGIN+STACKWIDTH*2+9	; 2
       sty_stack(i+3) and								// sty :STACKORIGIN+STACKWIDTH*3+9	; 3
       lda(i+4) and									// lda					; 4
       add_sub(i+5) and									// add|sub :STACKORIGIN+9		; 5
       sta(i+6) and									// sta					; 6
       lda(i+7) and									// lda					; 7
       adc_sbc(i+8) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 8
       sta(i+9) and									// sta					; 9
											//					; 10
       (adc_sbc(i+11) = false) then							//~adc|sbc				; 11
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if sta_stack(i) and									// sta :STACKORIGIN+STACKWIDTH+9	; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH*2+9	; 1
       sty_stack(i+2) and								// sty :STACKORIGIN+STACKWIDTH*3+9	; 2
       lda(i+3) and									// lda					; 3
       add_sub(i+4) and									// add|sub :STACKORIGIN+9		; 4
       sta(i+5) and									// sta					; 5
       lda(i+6) and									// lda					; 6
       adc_sbc(i+7) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 7
       sta(i+8) and									// sta					; 8
											//					; 9
       (adc_sbc(i+10) = false) then							//~adc|sbc				; 10
     if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if sta_stack(i) and									// sta :STACKORIGIN+9			; 0
       lda(i+1) and									// lda					; 1
       adc_sbc(i+2) and									// adc|sbc				; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; 3
       lda_stack(i+4) and								// lda :STACKORIGIN+9			; 4
       sta_a(i+5) and									// sta					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH+9	; 6
       sta_a(i+7) then									// sta					; 7
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i]   := listing[i+5];
	listing[i+3] := listing[i+7];

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if lda_stack(i) and									// lda :STACKORIGIN+9		; 0
       add_sub(i+1) and									// add|sub			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9		; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH+9; 3
       adc_sbc(i+4) and									// adc|sbc			; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+9		; 6
       add_sub(i+7) and									// add|sub			; 7
       sta(i+8) and									// sta				; 8
											//				; 9
       (adc_sbc(i+10) = false) then							//~adc|sbc			; 10
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


// add !!!

    if lda_stack(i) and									// lda :STACKORIGIN+10			; 0
       add(i+1) and									// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_im_0(i+7) and								// adc #$00				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_im_0(i+10) and								// adc #$00				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+10			; 12
       sta(i+13) and									// sta ADDR				; 13
       lda_val(i+14) and								// lda #$A0				; 14
       add_stack(i+15) and								// add :STACKORIGIN+STACKWIDTH+10	; 15
       sta(i+16) and									// sta ADDR+1				; 16
											//					; 17
       (adc(i+18) = false) then								//~adc					; 18
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
	(listing[i] = listing[i+12]) then
       begin
        listing[i+2] := listing[i+13];
	listing[i+4] := #9'adc ' + copy(listing[i+14], 6, 256);
	listing[i+5] := listing[i+16];

	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';

	exit(false);
       end;


    if asl_stack(i) and									// asl :STACKORIGIN+10			; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH+10	; 1
       lda(i+2) and									// lda					; 2
       add_sub_stack(i+3) and								// add|sub :STACKORIGIN+10		; 3
       sta(i+4) and									// sta					; 4
											//					; 5
       (adc_sbc(i+6) = false) then							//~adc|sbc				; 6
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i+1] := '';

	exit(false);
       end;


    if lda(i) and									// lda 					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       asl_stack(i+6) and								// asl :STACKORIGIN+10			; 6
       lda(i+7) and									// lda					; 7
       add_sub_stack(i+8) and								// add|sub :STACKORIGIN+10		; 8
       sta(i+9) and									// sta					; 9
											//					; 10
       (adc_sbc(i+11) = false) then							//~adc|sbc				; 11
      if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	 (copy(listing[i+6], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if asl_stack(i) and									// asl :STACKORIGIN+9 			; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH+9	; 1
       rol_stack(i+2) and								// rol :STACKORIGIN+STACKWIDTH*2+9	; 2
       rol_stack(i+3) and								// rol :STACKORIGIN+STACKWIDTH*3+9	; 3
       lda_stack(i+4) and								// lda :STACKORIGIN+9 			; 4
       add_sub(i+5) and									// add|sub 				; 5
       sta(i+6) and									// sta					; 6
       lda_stack(i+7) and								// lda :STACKORIGIN+STACKWIDTH+9	; 7
       adc_sbc(i+8) and									// adc|sbc				; 8
       sta(i+9) and									// sta					; 9
											//					; 10
       (adc_sbc(i+11) = false) then							//~adc|sbc			 	; 11
      if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;

end;		// function
