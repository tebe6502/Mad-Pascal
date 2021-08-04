// -------------------------------------------------------------------------------------------
//					NE.	EQ.
// -------------------------------------------------------------------------------------------

    if lda(i) and										// lda W+3		; 0	opt_098	| CARDINAL <> 0 ; CARDINAL = 0
       bne(i+1) and										// bne @+		; 1
       lda(i+2) and										// lda W+2		; 2
       bne(i+3) and										// bne @+		; 3
       lda(i+4) and										// lda W+1		; 4
       bne(i+5) and										// bne @+		; 5
       lda(i+6) and										// lda W		; 6
       (listing[i+7] = '@') and									//@			; 7
       (jeq(i+8) or jne(i+8) or beq(i+8) or bne(i+8)) and					// jeq|jne|beq|bne	; 8
       (SKIP(i+9) = false) then
     if (pos(listing[i+6], listing[i]) > 0) and
        (pos(listing[i+6], listing[i+2]) > 0) and
        (pos(listing[i+6], listing[i+4]) > 0) then
      begin
       listing[i+2] := #9'ora ' + copy(listing[i+2], 6, 256);
       listing[i+4] := #9'ora ' + copy(listing[i+4], 6, 256);
       listing[i+6] := #9'ora ' + copy(listing[i+6], 6, 256);

       listing[i+1] := '';
       listing[i+3] := '';
       listing[i+5] := '';
       listing[i+7] := '';

       Result:=false; Break;
      end;


    if lda(i) and										// lda W+3		; 0	CARDINAL <> 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W+2		; 3
       cmp_im_0(i+4) and									// cmp #$00		; 4
       bne(i+5) and										// bne @+		; 5
       lda(i+6) and										// lda W+1		; 6
       bne(i+7) and										// bne @+		; 7
       lda(i+8) and										// lda W		; 8
       (listing[i+9] = '@') and									//@			; 9
       (jeq(i+10) or jne(i+10) or beq(i+10) or bne(i+10)) and					// jeq|jne|beq|bne	; 10
       (SKIP(i+11) = false) then
     if (pos(listing[i+8], listing[i]) > 0) and
        (pos(listing[i+8], listing[i+3]) > 0) and
        (pos(listing[i+8], listing[i+6]) > 0) then
      begin
       listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);
       listing[i+6] := #9'ora ' + copy(listing[i+6], 6, 256);
       listing[i+8] := #9'ora ' + copy(listing[i+8], 6, 256);

       listing[i+1] := '';
       listing[i+2] := '';

       listing[i+4] := '';
       listing[i+5] := '';

       listing[i+7] := '';

       Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	opt_097	| WORD <> 0 ; WORD = 0
       bne(i+1) and										// bne @+		; 1
       lda(i+2) and										// lda W		; 2
       (listing[i+3] = '@') and									//@			; 3
       (jeq(i+4) or jne(i+4) or beq(i+4) or bne(i+4)) and					// jeq|jne|beq|bne	; 4
       (SKIP(i+5) = false) then
     if (pos(listing[i+2], listing[i]) > 0) then
      begin

       if jne(i+4) then
	listing[i+1] := listing[i+4]
       else begin
        listing[i+1] := '';
        listing[i+2] := #9'ora ' + copy(listing[i+2], 6, 256);
       end;

       listing[i+3] := '';

       Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	opt_097	| WORD <> 0 ; WORD = 0
       ora(i+1) and										// ora W		; 1
       (beq(i+2) or bne(i+2)) and								// beq|bne @+		; 2
       dey(i+3) and										// dey			; 3
       (listing[i+4] = '@') and									//@			; 4
       tya(i+5) and										// tya			; 5
       jne(i+6) then										// jne			; 6
      begin

       if beq(i+2) then
        listing[i+6] := #9'jeq ' + copy(listing[i+6], 6, 256);

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	opt_097	| WORD <>
       cmp(i+1) and										// cmp 			; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp			; 4
       (listing[i+5] = '@') and									//@			; 5
       bne(i+6) and										// bne @+		; 6
       dey(i+7) and										// dey			; 7
       (listing[i+8] = '@') and									//@			; 8
       tya(i+9) and										// tya			; 9
       jne(i+10) then										// jne l_		; 10
     if (pos(listing[i+3], listing[i]) > 0) then
      begin
       if cmp_im_0(i+1) then listing[i+1] := '';
       if cmp_im_0(i+4) then listing[i+4] := '';

       listing[i+2] := listing[i+10];

       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	WORD =
       cmp(i+1) and										// cmp 			; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp			; 4
       (listing[i+5] = '@') and									//@			; 5
       beq(i+6) and										// beq @+		; 6
       dey(i+7) and										// dey			; 7
       (listing[i+8] = '@') and									//@			; 8
       tya(i+9) and										// tya			; 9
       jne(i+10) then										// jne l_		; 10
     if (pos(listing[i+3], listing[i]) > 0) then
      begin
       listing[i+10] := #9'jeq ' + copy(listing[i+10], 6, 256);

       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if ldy(i) and										// ldy 			; 0	opt_095	| WORD <> 0 ; WORD = 0
       lda_bp2_y(i+1) and									// lda (:bp2),y		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN	; 2
       iny(i+3) and										// iny			; 3
       lda_bp2_y(i+4) and									// lda (:bp2),y		; 4
       bne(i+5) and										// bne @+		; 5
       lda_stack(i+6) and									// lda :STACKORIGIN	; 6
       (listing[i+7] = '@') and									//@			; 7
       (jeq(i+8) or jne(i+8) or beq(i+8) or bne(i+8)) then					// jeq|jne|beq|bne	; 8
    if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
       listing[i+4] := #9'ora (:bp2),y';

       listing[i+2] := '';

       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';

       Result:=false; Break;
      end;


    if (listing[i+8] = #9'.ENDL') and								// .ENDL		; 8
       (jeq(i+9) or jne(i+9)) and								// jeq|jne		; 9
       (SKIP(i+10) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	shortint <> shortint
       lda(i+1) and										// lda E		; 1	shortint = shortint
       sub(i+2) and										// sub			; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7
      begin
	listing[i] := listing[i+1];
	listing[i+1] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+2] := listing[i+9];
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
      end;


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       (jeq(i+16) or jne(i+16)) and								// jeq|jne		; 16
       (SKIP(i+17) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	smallint <> smallint
       lda(i+1) and										// lda E+1		; 1	smallint = smallint
       sub(i+2) and (sub_stack(i+2) = false) and						// sub 			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda(i+4) and										// lda E		; 4
       cmp(i+5) and (cmp_stack(i+5) = false) and						// cmp			; 5
       (listing[i+6] = #9'beq L5') and								// beq L5		; 6
       lda_im_0(i+7) and									// lda #$00		; 7
       (listing[i+8] = #9'adc #$FF') and							// adc #$FF		; 8
       (listing[i+9] = #9'ora #$01') and							// ora #$01		; 9
       (listing[i+10] = #9'bne L5') and								// bne L5		; 10
       (listing[i+11] = 'L4'#9'bvc L5') and							//L4 bvc L5		; 11
       (listing[i+12] = #9'eor #$FF') and							// eor #$FF		; 12
       (listing[i+13] = #9'ora #$01') and							// ora #$01		; 13
       (listing[i+14] = 'L5') then								//L5			; 14
      begin

       if jeq(i+16) then begin
	listing[i+10] := listing[i+1];
	listing[i+11] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+12] := #9'bne @+';
	listing[i+13] := listing[i+4];
	listing[i+14] := #9'cmp ' + copy(listing[i+5], 6, 256);
	listing[i+15] := listing[i+16];
	listing[i+16] := '@';
       end else begin
        listing[i+10] := '';
	listing[i+11] := listing[i+1];
	listing[i+12] := #9'eor ' + copy(listing[i+2], 6, 256);
	listing[i+13] := listing[i+16];
	listing[i+14] := listing[i+4];
	listing[i+15] := #9'eor ' + copy(listing[i+5], 6, 256);
       end;

	listing[i] := '';
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


    if (listing[i+22] = #9'.ENDL') and								// .ENDL		; 22
       (jeq(i+23) or jne(i+23) or beq(i+23) or bne(i+23)) and					// jeq|jne|beq|bne	; 23
       (SKIP(i+24) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	integer = 0
       lda(i+1) and										// lda E+3		; 1	integer <> 0
       sub_im_0(i+2) and									// sub #$00		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda(i+4) and										// lda E+2		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
       (listing[i+6] = #9'bne L1') and								// bne L1		; 6
       lda(i+7) and										// lda E+1		; 7
       cmp_im_0(i+8) and									// cmp #$00		; 8
       (listing[i+9] = #9'bne L1') and								// bne L1		; 9
       lda(i+10) and										// lda E		; 10
       cmp_im_0(i+11) and									// cmp #$00		; 11
       (listing[i+12] = 'L1'#9'beq L5') and							//L1 beq L5		; 12
       (listing[i+13] = #9'bcs L3') and								// bcs L3		; 13
       (listing[i+14] = #9'lda #$FF') and							// lda #$FF		; 14
       (listing[i+15] = #9'bne L5') and								// bne L5		; 15
       (listing[i+16] = 'L3'#9'lda #$01') and							//L3 lda #$01		; 16
       (listing[i+17] = #9'bne L5') and								// bne L5		; 17
       (listing[i+18] = 'L4'#9'bvc L5') and							//L4 bvc L5		; 18
       (listing[i+19] = #9'eor #$FF') and							// eor #$FF		; 19
       (listing[i+20] = #9'ora #$01') and							// ora #$01		; 20
       (listing[i+21] = 'L5') then								//L5			; 21
      begin

	listing[i] := listing[i+1];
	listing[i+1] := #9'ora ' + copy(listing[i+4], 6, 256);
	listing[i+2] := #9'ora ' + copy(listing[i+7], 6, 256);
	listing[i+3] := #9'ora ' + copy(listing[i+10], 6, 256);
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
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';

	Result:=false; Break;
      end;


    if (listing[i+22] = #9'.ENDL') and								// .ENDL		; 22
       (jeq(i+23) or jne(i+23)) and								// jeq|jne		; 23
       (SKIP(i+24) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	integer <> integer	JEQ
       lda(i+1) and										// lda E+3		; 1	integer = integer	JNE
       sub(i+2) and (sub_stack(i+2) = false) and						// sub			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda(i+4) and										// lda E+2		; 4
       cmp(i+5) and (cmp_stack(i+5) = false) and						// cmp			; 5
       (listing[i+6] = #9'bne L1') and								// bne L1		; 6
       lda(i+7) and										// lda E+1		; 7
       cmp(i+8) and (cmp_stack(i+8) = false) and						// cmp			; 8
       (listing[i+9] = #9'bne L1') and								// bne L1		; 9
       lda(i+10) and										// lda E		; 10
       cmp(i+11) and (cmp_stack(i+11) = false) and						// cmp			; 11
       (listing[i+12] = 'L1'#9'beq L5') and							//L1 beq L5		; 12
       (listing[i+13] = #9'bcs L3') and								// bcs L3		; 13
       (listing[i+14] = #9'lda #$FF') and							// lda #$FF		; 14
       (listing[i+15] = #9'bne L5') and								// bne L5		; 15
       (listing[i+16] = 'L3'#9'lda #$01') and							//L3 lda #$01		; 16
       (listing[i+17] = #9'bne L5') and								// bne L5		; 17
       (listing[i+18] = 'L4'#9'bvc L5') and							//L4 bvc L5		; 18
       (listing[i+19] = #9'eor #$FF') and							// eor #$FF		; 19
       (listing[i+20] = #9'ora #$01') and							// ora #$01		; 20
       (listing[i+21] = 'L5') then								//L5			; 21
      begin

       if jeq(i+23) then begin
	listing[i] := listing[i+1];
	listing[i+1] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+2] := #9'bne @+';
	listing[i+3] := listing[i+4];
	listing[i+4] := #9'cmp ' + copy(listing[i+5], 6, 256);
	listing[i+5] := #9'bne @+';
	listing[i+6] := listing[i+7];
	listing[i+7] := #9'cmp ' + copy(listing[i+8], 6, 256);
	listing[i+8] := #9'bne @+';
	listing[i+9] := listing[i+10];
	listing[i+10] := #9'cmp ' + copy(listing[i+11], 6, 256);
	listing[i+11] := listing[i+23];
	listing[i+12] := '@';
       end else begin
	listing[i] := listing[i+1];
	listing[i+1] := #9'eor ' + copy(listing[i+2], 6, 256);
	listing[i+2] := listing[i+23];
	listing[i+3] := listing[i+4];
	listing[i+4] := #9'eor ' + copy(listing[i+5], 6, 256);
	listing[i+5] := listing[i+23];
	listing[i+6] := listing[i+7];
	listing[i+7] := #9'eor ' + copy(listing[i+8], 6, 256);
	listing[i+8] := listing[i+23];
	listing[i+9] := listing[i+10];
	listing[i+10] := #9'eor ' + copy(listing[i+11], 6, 256);
	listing[i+11] := listing[i+23];
	listing[i+12] := '';
       end;

	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	Result:=false; Break;
      end;
