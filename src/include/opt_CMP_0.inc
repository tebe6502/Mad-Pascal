
function opt_CMP_0(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
//				      CMP #$00
// -----------------------------------------------------------------------------

    if lab_a(i+11) and										//@					; 11

       lda(i) and										// lda					; 0	> 0
       (listing[i+1] = #9'bne @+') and								// bne @+				; 1
       dey(i+2) and										// dey					; 2
       lda(i+3) and										// lda					; 3
       (listing[i+4] = #9'bne @+') and								// bne @+				; 4
       dey(i+5) and										// dey					; 5
       lda(i+6) and										// lda					; 6
       (listing[i+7] = #9'bne @+') and								// bne @+				; 7
       dey(i+8) and										// dey					; 8
       lda(i+9) and										// lda					; 9
       cmp_im_0(i+10) and									// cmp #$00				; 10

       jcc(i+12) and										// jcc l_				; 12
       jeq(i+13) then										// jeq l_				; 13
      begin
	listing[i+1] := '';

	listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);
	listing[i+4] := '';

	listing[i+6] := #9'ora ' + copy(listing[i+6], 6, 256);
	listing[i+7] := '';

	listing[i+9] := #9'ora ' + copy(listing[i+9], 6, 256);
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
      end;


    if lab_a(i+12) and										//@			; 12

       ldy_1(i) and										// ldy #1		; 0		CARDINAL <> = 0
       lda(i+1) and (lda_im(i+1) = false) and							// lda W+3		; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       bne(i+3) and										// bne @+		; 3
       lda(i+4) and (lda_im(i+4) = false) and							// lda W+2		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
       bne(i+6) and										// bne @+		; 6
       lda(i+7) and (lda_im(i+7) = false) and							// lda W+2		; 7
       cmp_im_0(i+8) and									// cmp #$00		; 8
       bne(i+9) and										// bne @+		; 9
       lda(i+10) and (lda_im(i+10) = false) and							// lda W+2		; 10
       cmp_im_0(i+11) and									// cmp #$00		; 11

       (beq(i+13) or bne(i+13)) and								// beq|bne		; 13
       dey(i+14) then										// dey
      begin
       listing[i+2] := '';

       listing[i+5] := '';

       listing[i+8] := '';

       listing[i+11] := '';

       exit(false);
      end;


    if (SKIP(i) = false) and
       lda_a(i+1) and (lda_im(i+1) = false) and							// lda W+1		; 1		WORD <> = 0
       cmp_im_0(i+2) and									// cmp #$00		; 2
       bne(i+3) and										// bne @+		; 3
       lda_a(i+4) and (lda_im(i+4) = false) and 						// lda W		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
       lab_a(i+6) and										//@			; 6
       (jeq(i+7) or jne(i+7)) then								// jeq|jne		; 7
      begin
       listing[i+2] := '';

       listing[i+5] := '';

       exit(false);
      end;


{
    if (SKIP(i) = false) and
       lda(i+1) and (lda_im(i+1) = false) and (lda_stack(i+1) = false) and			// lda W		; 1		BYTE <> = 0
       cmp_im_0(i+2) and									// cmp #$00		; 2
       (beq(i+3) or bne(i+3)) and								// beq|bne		; 3
       dey(i+4) and										// dey			; 4
       lab_a(i+5) then										//@			; 5
      begin
       listing[i+2] := '';

       exit(false);
      end;
}

    if (listing[i] = #9'bne @+') and								// bne @+		; 0
       lda_a(i+1) and										// lda			; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       lab_a(i+3) and										//@			; 3
       jcs(i+4) and										// jcs _lxxxx		; 4
       (SKIP(i+5) = false) then									//~SKIP			; 5
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
      end;


// -------------------------------------------------------------------------------------------


    if (jeq(i+9) or jne(i+9) or beq(i+9) or bne(i+9)) and					// jeq|jne|beq|bne	; 9
       (SKIP(i+10) = false) and (dey(i+10) = false) and						//~SKIP|dey		; 10

       lda_a(i) and										// lda W+3		; 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W+2		; 3
       bne(i+4) and										// bne @+		; 4
       lda_a(i+5) and										// lda W+1		; 5
       bne(i+6) and										// bne @+		; 6
       lda_a(i+7) and										// lda W		; 7
       lab_a(i+8) then										//@			; 8
     if (pos(listing[i+7], listing[i]) > 0) and
        (pos(listing[i+7], listing[i+3]) > 0) and
        (pos(listing[i+7], listing[i+5]) > 0) then
      begin
       listing[i+1] := '';

       exit(false);
      end;


    if (jeq(i+7) or jne(i+7) or beq(i+7) or bne(i+7)) and					// jeq|jne|beq|bne	; 7
       (SKIP(i+8) = false) and (dey(i+8) = false) and						//~SKIP|dey		; 8

       lda_a(i) and										// lda W+2		; 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W+1		; 3
       bne(i+4) and										// bne @+		; 4
       lda_a(i+5) and										// lda W		; 5
       lab_a(i+6) then										//@			; 6
     if (pos(listing[i+5], listing[i]) > 0) and
        (pos(listing[i+5], listing[i+3]) > 0) then
      begin
       listing[i+1] := '';

       exit(false);
      end;


    if (jeq(i+6) or jne(i+6) or beq(i+6) or bne(i+6)) and					// jeq|jne|beq|bne	; 6
       (SKIP(i+7) = false) and (dey(i+7) = false) and						//~SKIP|dey		; 7

       lda_a(i) and										// lda W+1		; 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp			; 4
       lab_a(i+5) then										//@			; 5
     if (pos(listing[i+3], listing[i]) > 0) then
      begin
       listing[i+1] := '';

       exit(false);
      end;

end;		// function