
function opt_CMP_NE_EQ(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
//				      NE.
//				      EQ.
// -----------------------------------------------------------------------------


    if sta_stack(i) and										// sta :STACKORIGIN	; 0
       ldy_1(i+1) and										// ldy #1		; 1
       lda_val(i+2) and										// lda W		; 2
       cmp_stack(i+3) and									// cmp :STACKORIGIN	; 3
       (beq_a(i+4) or bne_a(i+4)) and								// beq|bne @+		; 4
       dey(i+5) and										// dey			; 5
       lab_a(i+6) and										//@			; 6
       (tya(i+7) or sty(i+7)) then								// tya|sty		; 7
     if argMatch(i, i+3) then
      begin
       listing[i+2] := #9'cmp ' + GetARG(i+2);

       listing[i] := '';

       listing[i+3] := '';

       exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN	; 0
       ldy_1(i+1) and										// ldy #1		; 1
       lda_stack(i+2) and									// lda :STACKORIGIN	; 2
       and_ora_eor(i+3) and									// ora:and:eor		; 3
       (beq_a(i+4) or bne_a(i+4)) and								// beq|bne @+		; 4
       dey(i+5) and										// dey			; 5
       lab_a(i+6) and										//@			; 6
       (tya(i+7) or sty(i+7)) then								// tya|sty		; 7
     if argMatch(i, i+2) then
      begin
       listing[i+2] := '';

       exit(false);
      end;


    if ldy_1(i) and										// ldy #1		; 0
       lda_val(i+1) and										// lda W+1		; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       bne_a(i+3) and										// bne @+		; 3
       lda_a(i+4) and										// lda W		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
       lab_a(i+6) and										//@			; 6
       (beq_a(i+7) or bne_a(i+7)) and								// beq|bne @+		; 7
       dey(i+8) and										// dey			; 8
       lab_a(i+9) and										//@			; 9
       (tya(i+10) or sty(i+10)) and								// tya|sty		; 10
       (dex(i+11) = false) then									//~dex			; 11
      begin
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := #9'ora ' + GetARG(i+4);
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	opt_097	| WORD <> 0 ; WORD = 0
       ora(i+1) and										// ora W		; 1
       (beq(i+2) or bne(i+2)) and								// beq|bne @+		; 2
       dey(i+3) and										// dey			; 3
       lab_a(i+4) and										//@			; 4
       tya(i+5) and										// tya			; 5
       jne(i+6) then										// jne			; 6
      begin

       if beq(i+2) then
        listing[i+6] := #9'jeq ' + GetARG(i+6);

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda(i) and 										// lda W+1		; 0	opt_097	| WORD <>
       cmp(i+1) and										// cmp 			; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp			; 4
       lab_a(i+5) and										//@			; 5
       bne(i+6) and										// bne @+		; 6
       dey(i+7) and										// dey			; 7
       lab_a(i+8) and										//@			; 8
       tya(i+9) and										// tya			; 9
       jne(i+10) then										// jne l_		; 10
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

       exit(false);
      end;


{ !!! nie moze decydowac na podstawie tylko starszego bajtu

    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	WORD =
       cmp(i+1) and										// cmp 			; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp			; 4
       lab_a(i+5) and										//@			; 5
       beq(i+6) and										// beq @+		; 6
       dey(i+7) and										// dey			; 7
       lab_a(i+8) and										//@			; 8
       tya(i+9) and										// tya			; 9
       jne(i+10) then										// jne l_		; 10
      begin
       if cmp_im_0(i+1) then listing[i+1] := '';
       if cmp_im_0(i+4) then listing[i+4] := '';

       listing[i+2] := #9'jeq ' + copy(listing[i+10], 6, 256);

       listing[i+10] := #9'jeq ' + copy(listing[i+10], 6, 256);

       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;
}


    if ldy(i) and										// ldy 			; 0	opt_095	| WORD <> 0 ; WORD = 0
       lda_bp2_y(i+1) and									// lda (:bp2),y		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN	; 2
       iny(i+3) and										// iny			; 3
       lda_bp2_y(i+4) and									// lda (:bp2),y		; 4
       bne(i+5) and										// bne @+		; 5
       lda_stack(i+6) and									// lda :STACKORIGIN	; 6
       lab_a(i+7) and										//@			; 7
       (jeq(i+8) or jne(i+8) {or beq(i+8) or bne(i+8)}) then					// jeq|jne|beq|bne	; 8
    if argMatch(i+2, i+6) then
      begin
       listing[i+4] := #9'ora (:bp2),y';

       listing[i+2] := '';

       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';

       exit(false);
      end;


    if ldy(i) and										// ldy 			; 0	WORD <> 0 ; WORD = 0
       lda_bp2_y(i+1) and									// lda (:bp2),y		; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       bne(i+3) and										// bne			; 3
       dey(i+4) and										// dey			; 4
       lda_bp2_y(i+5) and									// lda (:bp2),y		; 5
       cmp_im_0(i+6) and									// cmp #$00		; 6
       lab_a(i+7) and										//@			; 7
       (jeq(i+8) or jne(i+8) {or beq(i+8) or bne(i+8)}) then					// jeq|jne|beq|bne	; 8
      begin
       listing[i+5] := #9'ora (:bp2),y';

       listing[i+2] := '';
       listing[i+3] := '';

       listing[i+6] := '';
       listing[i+7] := '';

       exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SHORTINT
// -----------------------------------------------------------------------------

    if ENDL(i+8) and										// .ENDL		; 8
       (beq(i+9) or bne(i+9)) and								// beq|bne		; 9
       dey(i+10) and										// dey			; 10
       lab_a(i+11) and										//@			; 11
       (sty(i+12) or tya(i+12)) and								// sty|tya		; 12

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT <>	BNE
       lda_a(i+1) and										// lda E		; 1	SHORTINT = 	BEQ
       sub(i+2) and										// sub			; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7
      begin

       if sub_im_0(i+2) then begin
        listing[i] := listing[i+1];
	listing[i+1] := '';
	listing[i+2] := '';
       end else begin
	listing[i] := listing[i+1];
	listing[i+1] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+2] := '';
       end;

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SMALLINT
// -----------------------------------------------------------------------------

    if ENDL(i+15) and										// .ENDL		; 15
       (beq(i+16) or bne(i+16)) and								// beq|bne		; 16
       dey(i+17) and										// dey			; 17
       lab_a(i+18) and										//@			; 18
       (sty(i+19) or tya(i+19)) and								// sty|tya		; 19

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT <>	BNE
       lda_a(i+1) and										// lda E+1		; 1	SMALLINT =	BEQ
       sub(i+2) and {(sub_stack(i+2) = false) and}						// sub 			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E		; 4
       cmp(i+5) and {(cmp_stack(i+5) = false) and}						// cmp			; 5
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

       if sub_im_0(i+2) and cmp_im_0(i+5) then begin
        listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := listing[i+1];
	listing[i+15] := #9'ora ' + copy(listing[i+4], 6, 256);
       end else begin
        listing[i+10] := listing[i+1];
        listing[i+11] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+12] := #9'bne @+';
	listing[i+13] := #9'lda ' + copy(listing[i+4], 6, 256);
	listing[i+14] := #9'cmp ' + copy(listing[i+5], 6, 256);
	listing[i+15] := '@';
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

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     INTEGER
// -----------------------------------------------------------------------------

    if ENDL(i+22) and										// .ENDL		; 22
       (beq(i+23) or bne(i+23)) and								// beq|bne		; 23
       dey(i+24) and										// dey			; 24
       lab_a(i+25) and										//@			; 25
       (sty(i+26) or tya(i+26)) and								// sty|tya		; 26

       LOCAL(i) and										// .LOCAL		; 0	INTEGER <>	BNE
       lda_a(i+1) and										// lda E+3		; 1	INTEGER =	BEQ
       sub(i+2) and {(sub_stack(i+2) = false) and}						// sub			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E+2		; 4
       cmp(i+5) and {(cmp_stack(i+5) = false) and}						// cmp			; 5
       (listing[i+6] = #9'bne L1') and								// bne L1		; 6
       lda_a(i+7) and										// lda E+1		; 7
       cmp(i+8) and {(cmp_stack(i+8) = false) and}						// cmp			; 8
       (listing[i+9] = #9'bne L1') and								// bne L1		; 9
       lda_a(i+10) and										// lda E		; 10
       cmp(i+11) and {(cmp_stack(i+11) = false) and}						// cmp			; 11
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

       if sub_im_0(i+2) and cmp_im_0(i+5) and cmp_im_0(i+8) and cmp_im_0(i+11) then begin
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
       end else begin
	listing[i] := listing[i+1];
	listing[i+1] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+2] := #9'bne @+';
	listing[i+3] := #9'lda ' + copy(listing[i+4], 6, 256);
	listing[i+4] := #9'cmp ' + copy(listing[i+5], 6, 256);
	listing[i+5] := #9'bne @+';
	listing[i+6] := #9'lda ' + copy(listing[i+7], 6, 256);
	listing[i+7] := #9'cmp ' + copy(listing[i+8], 6, 256);
	listing[i+8] := #9'bne @+';
	listing[i+9] := #9'lda ' + copy(listing[i+10], 6, 256);
	listing[i+10] := #9'cmp ' + copy(listing[i+11], 6, 256);
	listing[i+11] := '@';
       end;

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

	exit(false);
      end;

end;		// function
