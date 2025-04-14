
function opt_LOCAL(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      LOCAL.
// -----------------------------------------------------------------------------

    if (listing[i+12] = #9'bne L1') and								// bne L1				; 12

       lda_im(i) and 										// lda #				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       and_ora_eor_val(i+3) and									// and|ora|eor				; 3	~:STACKORIGIN
       sta_a(i+4) and										// sta					; 4
       ldy_1(i+5) and										// ldy #1				; 5
       LOCAL(i+6) and										// .LOCAL				; 6
       lda_a(i+7) and										// lda					; 7
       sub(i+8) and										// sub					; 8
       (listing[i+9] = #9'bne L4') and								// bne L4				; 9
       lda_a(i+10) and										// lda					; 10
       cmp(i+11) and										// cmp					; 11
//       (listing[i+12] = #9'bne L1') and							// bne L1				; 12
       lda_stack(i+13) then									// lda :STACKORIGIN+STACKWIDTH		; 13
     if (copy(listing[i+1], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
      listing[i+13] := listing[i];

      listing[i] := '';
      listing[i+1] := '';

      exit(false);
     end;


    if (listing[i+15] = #9'bne L1') and								// bne L1				; 15

       lda_im(i) and 										// lda #				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       and_ora_eor_val(i+3) and									// and|ora|eor				; 3	~:STACKORIGIN
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH*2	; 4
       ldy_1(i+5) and										// ldy #1				; 5
       LOCAL(i+6) and										// .LOCAL				; 6
       lda_a(i+7) and										// lda					; 7
       sub(i+8) and										// sub					; 8
       (listing[i+9] = #9'bne L4') and								// bne L4				; 9
       lda_a(i+10) and										// lda					; 10
       cmp(i+11) and										// cmp					; 11
       (listing[i+12] = #9'bne L1') and								// bne L1				; 12
       lda_a(i+13) and										// lda					; 13
       cmp(i+14) and										// cmp					; 14
//       (listing[i+15] = #9'bne L1') then							// bne L1				; 15
       lda_stack(i+16) then									// lda :STACKORIGIN			; 16
     if (copy(listing[i+1], 6, 256) = copy(listing[i+16], 6, 256)) then
     begin
      listing[i+16] := listing[i];

      listing[i] := '';
      listing[i+1] := '';

      exit(false);
     end;


    if (listing[i+16] = #9'bne L1') and								// bne L1				; 16

       ldy_im(i) and										// ldy #				; 0
       lda_im(i+1) and										// lda #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       sty_stack(i+3) and									// sty :STACKORIGIN+STACKWIDTH		; 3
       sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH*2	; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*3	; 5
       ldy_1(i+6) and										// ldy #1				; 6
       LOCAL(i+7) and										// .LOCAL				; 7
       lda_a(i+8) and										// lda					; 8
       sub_stack(i+9) and									// sub :STACKORIGIN+STACKWIDTH*3	; 9
       (listing[i+10] = #9'bne L4') and								// bne L4				; 10
       lda_a(i+11) and										// lda					; 11
       cmp_stack(i+12) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 12
       (listing[i+13] = #9'bne L1') and								// bne L1				; 13
       lda_a(i+14) and										// lda					; 14
       cmp_stack(i+15) and									// cmp :STACKORIGIN+STACKWIDTH		; 15
//       (listing[i+16] = #9'bne L1') and							// bne L1				; 16
       lda_a(i+17) and										// lda					; 17
       cmp_stack(i+18) then									// cmp :STACKORIGIN			; 18
     if (copy(listing[i+2], 6, 256) = copy(listing[i+18], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
      listing[i+9] := #9'sub ' + copy(listing[i], 6, 256);

      listing[i+12] := #9'cmp ' + copy(listing[i], 6, 256);

      listing[i+15] := #9'cmp ' + copy(listing[i], 6, 256);

      listing[i+18] := #9'cmp ' + copy(listing[i+1], 6, 256);

      listing[i] := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';

      exit(false);
     end;


    if adc_sbc(i) and										// adc|sbc				; 0
       LOCAL(i+1) and										// .LOCAL				; 1
       lda_a(i+2) then										// lda					; 2
     begin

      if (i > 0) and lda_a(i-1) then listing[i-1] := '';

      listing[i] := '';

      exit(false);
     end;


    if lda_a(i) and 										// lda 					; 0
       LOCAL(i+1) and										// .LOCAL				; 1
       sub(i+2) then										// sub					; 2
     begin
      listing[i+1] := listing[i];
      listing[i] := #9'.LOCAL';

      exit(false);
     end;


    if lda_a(i) and										// lda					; 0
       ldy(i+1) and										// ldy #1				; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) then										// lda					; 3
      begin
	listing[i] := '';
	exit(false);
      end;


    if lda_a(i) and 										// lda 					; 0
       LOCAL(i+1) and		 								// .LOCAL				; 1
       lda_a(i+2) then 										// lda 					; 2
      begin
	listing[i]   := '';

      	exit(false);
     end;


    if lda_a(i) and 										// lda 					; 0
       sta_stack(i+1) and									// sta STACKORIGIN			; 1
       LOCAL(i+2) and		 								// .LOCAL				; 2
       lda_stack(i+3) then 									// lda STACKORIGIN			; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i+3]   := #9'lda ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

      	exit(false);
     end;


    if (listing[i+5] = #9'bne L4') and								// bne L4				; 5

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub(i+4) and										// sub 					; 4
//       (listing[i+5] = #9'bne L4') and							// bne L4				; 5
       lda_a(i+6) and										// lda 					; 6
       cmp_stack(i+7) then									// cmp :STACKORIGIN			; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
       listing[i+7]  := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+5] = #9'bne L4') and								// bne L4				; 5

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub(i+4) and										// sub 					; 4
//       (listing[i+5] = #9'bne L4') and							// bne L4				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       cmp(i+7) then										// cmp 					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
       listing[i+6]  := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+5] = #9'bne L4') and								// bne L4				; 5

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub_stack(i+4) then									// sub :STACKORIGIN			; 4
//       (listing[i+5] = #9'bne L4') then							// bne L4				; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
       listing[i+4]  := #9'sub ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+8] = #9'bne L1') and								// bne L1				; 8

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub(i+4) and										// sub					; 4
       (listing[i+5] = #9'bne L4') and								// bne L4				; 5
       lda_a(i+6) and										// lda					; 6
       cmp(i+7) and										// cmp					; 7
       (listing[i+8] = #9'bne L1') and								// bne L1				; 8
       lda_a(i+9) and										// lda					; 9
       cmp_stack(i+10) then									// cmp :STACKORIGIN			; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) then
     begin
       listing[i+10]  := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+8] = #9'bne L1') and								// bne L1				; 8

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub(i+4) and										// sub					; 4
       (listing[i+5] = #9'bne L4') and								// bne L4				; 5
       lda_a(i+6) and										// lda					; 6
       cmp(i+7) and										// cmp					; 7
//       (listing[i+8] = #9'bne L1') and							// bne L1				; 8
       lda_stack(i+9) then									// lda :STACKORIGIN			; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
       listing[i+9]  := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+11] = #9'bne L1') and								// bne L1				; 11

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub(i+4) and										// sub					; 4
       (listing[i+5] = #9'bne L4') and								// bne L4				; 5
       lda_a(i+6) and										// lda					; 6
       cmp(i+7) and										// cmp					; 7
       (listing[i+8] = #9'bne L1') and								// bne L1				; 8
       lda_a(i+9) and										// lda					; 9
       cmp(i+10) and										// cmp					; 10
//       (listing[i+11] = #9'bne L1') and							// bne L1				; 11
       lda_a(i+12) and										// lda					; 12
       cmp_stack(i+13) then									// cmp :STACKORIGIN			; 13
     if (copy(listing[i+1], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
       listing[i+13]  := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+11] = #9'bne L1') and								// bne L1				; 11

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       LOCAL(i+2) and										// .LOCAL				; 2
       lda_a(i+3) and										// lda					; 3
       sub(i+4) and										// sub					; 4
       (listing[i+5] = #9'bne L4') and								// bne L4				; 5
       lda_a(i+6) and										// lda					; 6
       cmp(i+7) and										// cmp					; 7
       (listing[i+8] = #9'bne L1') and								// bne L1				; 8
       lda_a(i+9) and										// lda					; 9
       cmp(i+10) and										// cmp					; 10
//       (listing[i+11] = #9'bne L1') and							// bne L1				; 11
       lda_stack(i+12) then									// lda :STACKORIGIN			; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) then
     begin
       listing[i+12]  := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+7] = #9'bne L4') and								// bne L4				; 7

       ldy(i) and										// ldy 					; 0
       lda_a(i+1) and										// lda 					; 1
       sty_stack(i+2) and									// sty :STACKORIGIN+STACKWIDTH+10	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+10			; 3
       LOCAL(i+4) and										// .LOCAL				; 4
       lda_a(i+5) and										// lda					; 5
       sub_stack(i+6) and									// sub :STACKORIGIN+STACKWIDTH+10	; 6
//       (listing[i+7] = #9'bne L4') and							// bne L4				; 7
       lda_a(i+8) and										// lda					; 8
       cmp_stack(i+9) then									// cmp :STACKORIGIN+10			; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
       listing[i+6] := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+9] := #9'cmp ' + copy(listing[i+1], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i+14] = #9'bne L1') and								// bne L1				; 14

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH+9	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 4
       LOCAL(i+5) and										// .LOCAL				; 5
       lda_a(i+6) and										// lda 					; 6
       sub_stack(i+7) and									// sub :STACKORIGIN+STACKWIDTH*3+9	; 7
       (listing[i+8] = #9'bne L4') and								// bne L4				; 8
       lda_a(i+9) and										// lda					; 9
       cmp_stack(i+10) and									// cmp :STACKORIGIN+STACKWIDTH*2+9	; 10
       (listing[i+11] = #9'bne L1') and								// bne L1				; 11
       lda_a(i+12) and										// lda					; 12
       cmp_stack(i+13) and									// cmp :STACKORIGIN+STACKWIDTH+9	; 13
//       (listing[i+14] = #9'bne L1') and							// bne L1				; 14
       lda_a(i+15) and										// lda					; 15
       cmp_stack(i+16) then									// cmp :STACKORIGIN+9			; 16
     if (copy(listing[i+1], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
       listing[i+7]  := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+10] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+13] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+16] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if (listing[i+13] = #9'bne L1') and								// bne L1				; 13

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       LOCAL(i+4) and										// .LOCAL				; 4
       lda_a(i+5) and										// lda 					; 5
       sub_im_0(i+6) and									// sub #$00				; 6
       (listing[i+7] = #9'bne L4') and								// bne L4				; 7
       lda_a(i+8) and										// lda					; 8
       cmp_stack(i+9) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 9
       (listing[i+10] = #9'bne L1') and								// bne L1				; 10
       lda_a(i+11) and										// lda					; 11
       cmp_stack(i+12) and									// cmp :STACKORIGIN+STACKWIDTH		; 12
//       (listing[i+13] = #9'bne L1') and							// bne L1				; 13
       lda_a(i+14) and										// lda					; 14
       cmp_stack(i+15) then									// cmp :STACKORIGIN			; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) then
     begin
       listing[i+9]  := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+12] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+15] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i+7] = #9'bne L4') and								// bne L4				; 7

       lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH+9	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 3
       LOCAL(i+4) and										// .LOCAL				; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 5
												// sub #$00				; 6
//       (listing[i+7] = #9'bne L4') and							// bne L4				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 8
       cmp(i+9) and										// cmp					; 9
												// bne L1				; 10
       lda_stack(i+11) then									// lda :STACKORIGIN+STACKSWIDTH+9	; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
       listing[i+5]  := listing[i];
       listing[i+8]  := listing[i];
       listing[i+11] := listing[i];

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH+10	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda_a(i+4) and										// lda					; 4
       sub_stack(i+5) and									// sub :STACKORIGIN+STACKWIDTH+10	; 5
//       (listing[i+6] = #9'bne L4') and							// bne L4				; 6
       lda_a(i+7) and										// lda					; 7
       cmp_stack(i+8) then									// cmp :STACKORIGIN+10			; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
     begin
       listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+8] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if (listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy(i+2) and										// ldy #1				; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda_a(i+4) and										// lda					; 4
       sub(i+5) and										// sub 					; 5

       lda_stack(i+7) and									// lda :STACKORIGIN			; 7
       cmp(i+8) then										// cmp 					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
       listing[i+7]  := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy(i+2) and										// ldy #1				; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda_a(i+4) and										// lda					; 4
       sub(i+5) and										// sub 					; 5

       lda_a(i+7) and										// lda 					; 7
       cmp_stack(i+8) then									// cmp :STACKORIGIN			; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
     begin
       listing[i+8]  := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if(listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy(i+2) and										// ldy #1				; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda(i+4) and										// lda					; 4
       sub_stack(i+5) then									// sub :STACKORIGIN			; 5

     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
     begin
       listing[i+5]  := #9'sub ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy(i+2) and										// ldy #1				; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda_a(i+4) and										// lda 					; 4
       sub_stack(i+5) and									// sub :STACKORIGIN+STACKWIDTH*3	; 5

       lda_a(i+7) and										// lda					; 7
       cmp_stack(i+8) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 8
       (listing[i+9] = #9'bne L1') and								// bne L1				; 9
       lda_a(i+10) and										// lda					; 10
       cmp_stack(i+11) and									// cmp :STACKORIGIN+STACKWIDTH		; 11
       (listing[i+12] = #9'bne L1') and								// bne L1				; 12
       lda_a(i+13) and										// lda					; 13
       cmp_stack(i+14) then									// cmp :STACKORIGIN+9			; 14
     if (copy(listing[i+1], 6, 256) = copy(listing[i+14], 6, 256)) then
     begin
       listing[i+14] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       ldy(i+2) and										// ldy #1				; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda_a(i+4) and										// lda 					; 4
       sub_stack(i+5) and									// sub :STACKORIGIN+STACKWIDTH*3	; 5

       lda_a(i+7) and										// lda					; 7
       cmp_stack(i+8) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 8
       (listing[i+9] = #9'bne L1') and								// bne L1				; 9
       lda_a(i+10) and										// lda					; 10
       cmp_stack(i+11) then									// cmp :STACKORIGIN+STACKWIDTH		; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
       listing[i+11] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+6] = #9'bne L4') and								// bne L4				; 6

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2	; 1
       ldy(i+2) and										// ldy #1				; 2
       LOCAL(i+3) and										// .LOCAL				; 3
       lda_a(i+4) and										// lda					; 4
       sub_stack(i+5) and									// sub :STACKORIGIN+STACKWIDTH*3	; 5

       lda_a(i+7) and										// lda					; 7
       cmp_stack(i+8) then									// cmp :STACKORIGIN+STACKWIDTH*2	; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
     begin
       listing[i+8]  := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i+7] = #9'bne L4') and								// bne L4				; 7

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH+10	; 2
       ldy(i+3) and										// ldy #1				; 3
       LOCAL(i+4) and										// .LOCAL				; 4
       lda_a(i+5) and										// lda					; 5
       sub_stack(i+6) and									// sub :STACKORIGIN+STACKWIDTH+10	; 6

       lda_a(i+8) and										// lda					; 8
       cmp_stack(i+9) then									// cmp :STACKORIGIN+10			; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
       listing[i+6] := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+9] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if (listing[i+7] = #9'bne L4') and								// bne L4				; 7

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH+10	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       ldy(i+3) and										// ldy #1				; 3
       LOCAL(i+4) and										// .LOCAL				; 4
       lda_a(i+5) and										// lda					; 5
       sub_stack(i+6) and									// sub :STACKORIGIN+STACKWIDTH+10	; 6

       lda_a(i+8) and										// lda					; 8
       cmp_stack(i+9) then									// cmp :STACKORIGIN+10			; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
       listing[i+6] := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+9] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if (listing[i+8] = #9'bne L4') and								// bne L4				; 8

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*3	; 3
       ldy(i+4) and										// ldy #1				; 4
       LOCAL(i+5) and										// .LOCAL				; 5
       lda(i+6) and										// lda :STACKORIGIN+STACKWIDTH*3	; 6
       sub_im_0(i+7) and									// sub #$00				; 7

       lda(i+9) and										// lda :STACKORIGIN+STACKWIDTH*2	; 9
       cmp(i+10) and										// cmp					; 10
       (listing[i+11] = #9'bne L1') and								// bne L1				; 11
       lda(i+12) then										// lda :STACKORIGIN+STACKWIDTH		; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
       listing[i+6]  := listing[i];
       listing[i+9]  := listing[i];
       listing[i+12] := listing[i];

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i+8] = #9'bne L4') and								// bne L4				; 8

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       ldy(i+4) and										// ldy #1				; 4
       LOCAL(i+5) and										// .LOCAL				; 5
       lda_a(i+6) and										// lda 					; 6
       sub_im_0(i+7) and									// sub #$00				; 7

       lda_a(i+9) and										// lda					; 9
       cmp_stack(i+10) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 10
       (listing[i+11] = #9'bne L1') and								// bne L1				; 11
       lda_a(i+12) and										// lda					; 12
       cmp_stack(i+13) and									// cmp :STACKORIGIN+STACKWIDTH		; 13
       (listing[i+14] = #9'bne L1') and								// bne L1				; 14
       lda_a(i+15) and										// lda					; 15
       cmp_stack(i+16) then									// cmp :STACKORIGIN			; 16
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+16], 6, 256)) then
     begin
       listing[i+10] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+13] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+16] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i+9] = #9'bne L4') and								// bne L4				; 9

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*3	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       ldy(i+5) and										// ldy #1				; 5
       LOCAL(i+6) and										// .LOCAL				; 6
       lda_a(i+7) and										// lda 					; 7
       sub_stack(i+8) and									// sub :STACKORIGIN+STACKWIDTH*3	; 8

       lda_a(i+10) and										// lda					; 10
       cmp_stack(i+11) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 11
       (listing[i+12] = #9'bne L1') and								// bne L1				; 12
       lda_a(i+13) and										// lda					; 13
       cmp_stack(i+14) and									// cmp :STACKORIGIN+STACKWIDTH		; 14
       (listing[i+15] = #9'bne L1') and								// bne L1				; 15
       lda_a(i+16) and										// lda					; 16
       cmp_stack(i+17) then									// cmp :STACKORIGIN			; 17
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+17], 6, 256)) then
     begin
       listing[i+8]  := #9'sub ' + copy(listing[i], 6, 256);
       listing[i+11] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+14] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+17] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if (listing[i+13] = #9'bne L4') and								// bne L4				; 13

       (listing[i+16] = #9'bne L1') and								// bne L1				; 16

       lda_stack(i) and										// lda :STACKORIGIN+STACKWIDTH		; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH*2	; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH*3	; 6
       adc_sbc_im_0(i+7) and									// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       ldy(i+9) and										// ldy #1				; 9
       LOCAL(i+10) and										// .LOCAL				; 10
       lda_im_0(i+11) and									// lda #$00				; 11
       sub_stack(i+12) and									// sub :STACKORIGIN+STACKWIDTH*3	; 12

       lda_im_0(i+14) and									// lda #$00				; 14
       cmp_stack(i+15) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 15

       lda_a(i+17) and										// lda					; 17
       cmp_stack(i+18) then									// cmp :STACKORIGIN+STACKWIDTH		; 18
     if (copy(listing[i+2], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+12], 6, 256)) then
     begin
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+12] := #9'sub #$00';

       listing[i+15] := #9'cmp #$00';

       exit(false);
     end;


    if (listing[i+13] = #9'bne L4') and								// bne L4				; 13

       (listing[i+16] = #9'bne L1') and								// bne L1				; 16

       lda_im_0(i) and										// lda #$00				; 0
       (adc_sbc_im_0(i+1) or adc_sbc_stack(i+1)) and						// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       adc_sbc_im_0(i+7) and									// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       ldy(i+9) and										// ldy #1				; 9
       LOCAL(i+10) and										// .LOCAL				; 10
       lda_im_0(i+11) and									// lda #$00				; 11
       sub_stack(i+12) and									// sub :STACKORIGIN+STACKWIDTH*3	; 12

       lda_im_0(i+14) and									// lda #$00				; 14
       cmp_stack(i+15) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 15

       lda_a(i+17) and										// lda #$00				; 17
       cmp_stack(i+18) then									// cmp :STACKORIGIN+STACKWIDTH		; 18
     if (copy(listing[i+2], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+12], 6, 256)) then
     begin
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+12] := #9'sub #$00';

       listing[i+15] := #9'cmp #$00';

       exit(false);
     end;


    if (listing[i+13] = #9'bne L4') and								// bne L4				; 13

       (listing[i+16] = #9'bne L1') and								// bne L1				; 16

       lda_stack(i) and										// lda :STACKORIGIN+STACKWIDTH		; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH*2	; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH*3	; 6
       adc_sbc_im_0(i+7) and									// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       ldy(i+9) and										// ldy #1				; 9
       LOCAL(i+10) and										// .LOCAL				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH*3	; 11
       sub_im_0(i+12) and									// sub #$00				; 12

       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH*2	; 14
       cmp_im_0(i+15) and									// cmp #$00				; 15

       lda_stack(i+17) then									// lda :STACKORIGIN+STACKWIDTH		; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+11] := #9'lda #$00';

       listing[i+14] := #9'lda #$00';

       exit(false);
     end;


    if (listing[i+13] = #9'bne L4') and								// bne L4				; 13

       (listing[i+16] = #9'bne L1') and								// bne L1				; 16

       lda_im_0(i) and										// lda #$00				; 0
       adc_sbc_stack(i+1) and									// adc|sbc :STACK			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_stack(i+4) and									// adc|sbc :STACK			; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       adc_sbc_stack(i+7) and									// adc|sbc :STACK			; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       ldy(i+9) and										// ldy #1				; 9
       LOCAL(i+10) and										// .LOCAL				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH*3	; 11
       sub_im_0(i+12) and									// sub #$00				; 12

       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH*2	; 14
       cmp_im_0(i+15) and									// cmp #$00				; 15

       lda_stack(i+17) then									// lda :STACKORIGIN+STACKWIDTH		; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+11], 6, 256)) then
     begin
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+11] := #9'lda #$00';

       listing[i+14] := #9'lda #$00';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if (listing[i+15] = #9'bne L4') and								// bne L4				; 15

       (listing[i+18] = #9'bne L1') and								// bne L1				; 18

       lda_stack(i) and										// lda :STACKORIGIN+STACKWIDTH		; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH*2	; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH*3	; 6
       adc_sbc_im_0(i+7) and									// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       asl_a(i+10) and										// asl @				; 10
       tay(i+11) and										// tay					; 11
       LOCAL(i+12) and										// .LOCAL				; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH*3	; 13
       sub_im_0(i+14) and									// sub #$00				; 14

       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*2	; 16
       cmp_im_0(i+17) and									// cmp #$00				; 17

       lda_stack(i+19) then									// lda :STACKORIGIN+STACKWIDTH		; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+13] := #9'lda #$00';

       listing[i+16] := #9'lda #$00';

       exit(false);
     end;



    if (listing[i+15] = #9'bne L4') and								// bne L4				; 15

       (listing[i+18] = #9'bne L1') and								// bne L1				; 18

       lda_im_0(i) and										// lda #$00				; 0
       adc_sbc_stack(i+1) and									// adc|sbc :STACK			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_stack(i+4) and									// adc|sbc :STACK			; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       adc_sbc_stack(i+7) and									// adc|sbc :STACK			; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       asl_a(i+10) and										// asl @				; 10
       tay(i+11) and										// tay					; 11
       LOCAL(i+12) and										// .LOCAL				; 12
       lda_Stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH*3	; 13
       sub_im_0(i+14) and									// sub #$00				; 14

       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*2	; 16
       cmp_im_0(i+17) and									// cmp #$00				; 17

       lda_stack(i+19) then									// lda :STACKORIGIN+STACKWIDTH		; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+13] := #9'lda #$00';

       listing[i+16] := #9'lda #$00';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if ENDL(i+22) and										// .ENDL				; 22	smallint -> shortint

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       ldy(i+6) and 										// ldy #1				; 6
       LOCAL(i+7) and										// .LOCAL				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH		; 8
       sub_im_0(i+9) and									// sub #$00				; 9
       (listing[i+10] = #9'bne L4') and								// bne L4				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN			; 11
       cmp_im(i+12) and										// cmp #0..127				; 12
       (listing[i+13] = #9'beq L5') and								// beq L5				; 13
       (listing[i+14] = #9'lda #$00') and							// lda #$00				; 14
       (listing[i+15] = #9'adc #$FF') and							// adc #$FF				; 15
       (listing[i+16] = #9'ora #$01') and							// ora #$01				; 16
       (listing[i+17] = #9'bne L5') and								// bne L5				; 17
       (listing[i+18] = 'L4'#9'bvc L5') and							//L4 bvc L5				; 18
       (listing[i+19] = #9'eor #$FF') and							// eor #$FF				; 19
       (listing[i+20] = #9'ora #$01') and							// ora #$01				; 20
       (listing[i+21] = 'L5') then								//L5					; 21

     if (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then
      begin

       if GetBYTE(i+12) < 128 then begin

	listing[i+8]  := listing[i+11];
	listing[i+9]  := #9'sub ' + copy(listing[i+12], 6, 256);
	listing[i+10] := #9'beq L5';
	listing[i+11] := #9'bvc L5';
	listing[i+12] := #9'eor #$FF';
	listing[i+13] := #9'ora #$01';
	listing[i+14] := 'L5';
	listing[i+15] := #9'.ENDL';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';

        exit(false);

       end;

      end;


    if ENDL(i+22) and										// .ENDL				; 22

       LOCAL(i) and										// .LOCAL				; 0	integer -> smallint
       lda_im_0(i+1) and									// lda #$00				; 1
       sub_im_0(i+2) and									// sub #$00				; 2
       (listing[i+3] = #9'bne L4') and								// bne L4				; 3
       lda_im_0(i+4) and									// lda #$00				; 4
       cmp_im_0(i+5) and									// cmp #$00				; 5
       (listing[i+6] = #9'bne L1') and								// bne L1				; 6
       lda_a(i+7) and										// lda					; 7
       cmp(i+8) and										// cmp					; 8
       (listing[i+9] = #9'bne L1') and								// bne L1				; 9
       lda_a(i+10) and										// lda					; 10
       cmp(i+11) and										// cmp 					; 11
       (listing[i+12] = 'L1'#9'beq L5') and							//L1 beq L5				; 12
       (listing[i+13] = #9'bcs L3') and								// bcs L3				; 13
       (listing[i+14] = #9'lda #$FF') and							// lda #$FF				; 14
       (listing[i+15] = #9'bne L5') and								// bne L5				; 15
       (listing[i+16] = 'L3'#9'lda #$01') and							//L3 lda #$01				; 16
       (listing[i+17] = #9'bne L5') and								// bne L5				; 17
       (listing[i+18] = 'L4'#9'bvc L5') and							//L4 bvc L5				; 18
       (listing[i+19] = #9'eor #$FF') and							// eor #$FF				; 19
       (listing[i+20] = #9'ora #$01') and							// ora #$01				; 20
       (listing[i+21] = 'L5') then								//L5					; 21
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'.LOCAL';

       listing[i+8] := #9'sub ' + copy(listing[i+8], 6, 256);
       listing[i+9] := #9'bne L4';

       listing[i+12] := #9'beq L5';
       listing[i+13] := #9'lda #$00';
       listing[i+14] := #9'adc #$FF';
       listing[i+15] := #9'ora #$01';
       listing[i+16] := #9'bne L5';
       listing[i+17] := 'L4'#9'bvc L5';
       listing[i+18] := #9'eor #$FF';
       listing[i+19] := #9'ora #$01';
       listing[i+20] := 'L5';
       listing[i+21] := '';

       exit(false);
     end;

end;		// function
