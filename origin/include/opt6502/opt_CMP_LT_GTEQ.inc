
function opt_CMP_LT_GTEQ(i: integer): Boolean;
var p, k: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
//				      LT.
//				      GTEQ.
// -----------------------------------------------------------------------------

    if lab_a(i+11) and										//@			; 11

       lda_a(i) and {(lda_stack(i) = false) and}						// lda W+3		; 0	opt_080 | CARDINAL < 0 ; >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W+2		; 3
       cmp_im_0(i+4) and									// cmp #$00		; 4
       bne(i+5) and										// bne @+		; 5
       lda_a(i+6) and										// lda W+1		; 6
       cmp_im_0(i+7) and									// cmp #$00		; 7
       bne(i+8) and										// bne @+		; 8
       lda_a(i+9) and										// lda W		; 9
       cmp(i+10) and										// cmp			; 10

       (jcs(i+12) or jcc(i+12)) and								// jcc|jcs l_		; 12
       (SKIP(i+13) = false) then								//~SKIP			; 13
      begin

        if cmp_im_0(i+10) then begin
	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	if jcs(i+12) then
	 listing[i+12] := #9'jmp ' + copy(listing[i+12], 6, 256)
	else
	 listing[i+12] := '';

	end else
	 if jcs(i+12) then begin
	  listing[i+1] := '';
	  listing[i+2] := #9'jne ' + copy(listing[i+12], 6, 256);

	  listing[i+4] := '';
	  listing[i+5] := #9'jne ' + copy(listing[i+12], 6, 256);

	  listing[i+7] := '';
	  listing[i+8] := #9'jne ' + copy(listing[i+12], 6, 256);
	 end else begin
	  listing[i+1] := '';

	  listing[i+4] := '';

	  listing[i+7] := '';

	  listing[i+11] := listing[i+12];
	  listing[i+12] := '@';
	 end;

        exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda W+1		; 0	WHILE WORD <
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp_im_0(i+4) and									// cmp #$00		; 4
       lab_a(i+5) and										//@			; 5
       jcc(i+6) and										// jcc l_		; 6
       (SKIP(i+7) = false) then									//~SKIP			; 7
      begin
	k := GetWORD(i+4, i+1);

	if k = 0 then begin
	 listing[i]    := '';
	 listing[i+1]  := '';
	 listing[i+2]  := '';
	 listing[i+3]  := '';
	 listing[i+4]  := '';
	 listing[i+5]  := '';
	 listing[i+6]  := '';
	end else begin

	 listing[i+5] := listing[i+6];
	 listing[i+6] := '@';

	 listing[i+4] := listing[i+3];

	 listing[i+2] := listing[i+5];
	 listing[i+3] := #9'bne @+';

	end;

        exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda_val(i) and										// lda W+1		; 0	opt_081 | WORD < 0 ; >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp 			; 4
       lab_a(i+5) and										//@			; 5
       (jcs(i+6) or jcc(i+6)) and								// jcc|jcs l_		; 6
       (SKIP(i+7) = false) then									//~SKIP			; 7
      begin

	if cmp_im_0(i+4) then begin
	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	if jcs(i+6) then
	 listing[i+6] := #9'jmp ' + copy(listing[i+6], 6, 256)
	else
	 listing[i+6] := '';

	end else
	 if jcs(i+6) then begin
	  listing[i+1] := '';
	  listing[i+2] := #9'jne ' + copy(listing[i+6], 6, 256);
	 end else begin
	  listing[i+1] := '';

	  listing[i+5] := listing[i+6];
	  listing[i+6] := '@';
	 end;

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	BOOL := WORD >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp_im_0(i+4) and									// cmp 			; 4
       lab_a(i+5) and										//@			; 5
       bcs(i+6) and										// bcs @+		; 6
       dey(i+7) and										// dey			; 7
       lab_a(i+8) and										//@			; 8
       tya(i+9) and										// tya			; 9
       (sta(i+10) or and_ora_eor(i+10)) and							// sta|and|ora|eor	; 10
												//			; 11
       (dex(i+12) = false) then									//~dex			; 12
      begin
	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda			; 0	opt_082	| BYTE < 0 ; >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       (jcs(i+2) or jcc(i+2)) and								// jcc|jcs l_		; 2
       (SKIP(i+3) = false) then									//~SKIP			; 3
      begin
	listing[i]   := '';
	listing[i+1] := '';

	if jcs(i+2) then
	 listing[i+2] := #9'jmp ' + copy(listing[i+2], 6, 256)
	else
	 listing[i+2] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SHORTINT
// -----------------------------------------------------------------------------

    if ENDL(i+8) and										// .ENDL		; 8
       (bpl(i+9) or bmi(i+9)) and								// bpl|bmi		; 9
       dey(i+10) and										// dey			; 10
       lab_a(i+11) and										//@			; 11
       (sty(i+12) or tya(i+12)) and								// sty|tya		; 12

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT >= $XX		BPL
       lda_a(i+1) and										// lda E		; 1	SHORTINT < $XX		BMI
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7
      begin
 	p := shortint(GetBYTE(i+2));

	if p = 0 then begin
	 listing[i] := listing[i+1];
	 listing[i+1] := listing[i+9];
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	end else
	if bpl(i+9) and (p = 127) then begin
	 listing[i] := listing[i+1];
	 listing[i+1] := #9'cmp #$7F';
	 listing[i+2] := #9'beq @+';
	 listing[i+3] := '';
	 listing[i+4] := '';
	end else
	if bmi(i+9) and (p = -128) then begin
	 listing[i] := #9'beq @+';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	end else begin
	 listing[i] := listing[i+1];
	 listing[i+1] := listing[i+2];
	 listing[i+2] := #9'svc';
	 listing[i+3] := #9'eor #$80';
	 listing[i+4] := listing[i+9];
	end;

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
      end;


    if ENDL(i+8) and										// .ENDL		; 8
       (bpl(i+9) or bmi(i+9)) and								// bpl|bmi		; 9
       dey(i+10) and										// dey			; 10
       lab_a(i+11) and										//@			; 11
       (sty(i+12) or tya(i+12)) and								// sty|tya		; 12

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT >= SHORTINT	BPL
       lda_a(i+1) and										// lda E		; 1	SHORTINT < SHORTINT	BMI
       sub(i+2) and (sub_im(i+2) = false) and							// sub 			; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7
      begin
	listing[i] := listing[i+1];
	listing[i+1] := listing[i+2];
	listing[i+2] := #9'svc';
	listing[i+3] := #9'eor #$80';
	listing[i+4] := listing[i+9];
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SMALLINT
// -----------------------------------------------------------------------------

    if ldy_1(i) and 										// ldy #1		; 0	BOOL := SHORTINT < 0
       lda_val(i+1) and										// lda			; 1	BOOL := SMALLINT < 0
       bmi_a(i+2) and										// bmi @+		; 2	BOOL := INTEGER < 0
       dey(i+3) and										// dey			; 3
       lab_a(i+4) and										//@			; 4
       tya(i+5) and										// tya			; 5
       sta_a(i+6) and										// sta			; 6
												//			; 7
       (dex(i+8) = false) then									//~dex			; 8
     begin
	listing[i]   := '';

	listing[i+2] := #9'cmp #$80';
	listing[i+3] := #9'lda #$00';
	listing[i+4] := #9'rol @';
	listing[i+5] := '';

	exit(false);
     end;


    if ENDL(i+15) and										// .ENDL		; 15
       bmi(i+16) and										// bmi			; 16
       dey(i+17) and										// dey			; 17
       lab_a(i+18) and										//@			; 18
       (sty(i+19) or tya(i+19)) and								// sty|tya		; 19

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT < #		BMI
       lda_a(i+1) and										// lda E+1		; 1
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E		; 4
       cmp_im(i+5) and										// cmp #		; 5
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
        p := smallint(GetWORD(i+5, i+2));

	if p = 0 then begin
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := listing[i+1];
	end else
	if p <> Low(smallint) then begin
	 listing[i+10] := listing[i+4];
	 listing[i+11] := listing[i+5];
	 listing[i+12] := listing[i+1];
	 listing[i+13] := #9'sbc ' + copy(listing[i+2], 6, 256);
	 listing[i+14] := #9'svc';
	 listing[i+15] := #9'eor #$80';
	end else begin
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := '';
	 listing[i+16] := #9'beq @+';
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


    if ENDL(i+15) and										// .ENDL		; 15
       bpl(i+16) and										// bpl			; 16
       dey(i+17) and										// dey			; 17
       lab_a(i+18) and										//@			; 18
       (sty(i+19) or tya(i+19)) and								// sty|tya		; 19

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT >= #		BPL
       lda_a(i+1) and										// lda E+1		; 1
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E		; 4
       cmp_im(i+5) and										// cmp #		; 5
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
        p := smallint(GetWORD(i+5, i+2));

	if p = 0 then begin
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := listing[i+1];
	end else begin
	 listing[i+10] := listing[i+4];
	 listing[i+11] := listing[i+5];
	 listing[i+12] := listing[i+1];
	 listing[i+13] := #9'sbc ' + copy(listing[i+2], 6, 256);
	 listing[i+14] := #9'svc';
	 listing[i+15] := #9'eor #$80';
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


    if ENDL(i+15) and										// .ENDL		; 15
       (bpl(i+16) or bmi(i+16)) and								// bpl|bmi		; 16
       dey(i+17) and										// dey			; 17
       lab_a(i+18) and										//@			; 18
       (sty(i+19) or tya(i+19)) and								// sty|tya		; 19

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT < SMALLINT	BMI
       lda_a(i+1) and										// lda E+1		; 1	SMALLINT >= SMALLINT	BPL
       sub(i+2) and										// sub 			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E		; 4
       cmp(i+5) and (cmp_im(i+5) = false) and							// cmp			; 5
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
	listing[i+10] := listing[i+4];
	listing[i+11] := listing[i+5];
	listing[i+12] := listing[i+1];
	listing[i+13] := #9'sbc ' + copy(listing[i+2], 6, 256);
	listing[i+14] := #9'svc';
	listing[i+15] := #9'eor #$80';

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
       (bpl(i+23) or bmi(i+23)) and								// bmi|bpl		; 23
       dey(i+24) and										// dey			; 24
       lab_a(i+25) and										//@			; 25
       (sty(i+26) or tya(i+26)) and								// sty|tya		; 26

       LOCAL(i) and										// .LOCAL		; 0	INTEGER < XXYYXXYY	BMI
       lda_a(i+1) and										// lda E+3		; 1	INTEGER >= XXYYXXYY	BPL
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E+2		; 4
       cmp_im(i+5) and										// cmp #		; 5
       (listing[i+6] = #9'bne L1') and								// bne L1		; 6
       lda_a(i+7) and										// lda E+1		; 7
       cmp_im(i+8) and										// cmp #		; 8
       (listing[i+9] = #9'bne L1') and								// bne L1		; 9
       lda_a(i+10) and										// lda E		; 10
       cmp_im(i+11) and										// cmp #		; 11
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
        p := GetBYTE(i+11) + GetBYTE(i+8) shl 8 + GetBYTE(i+5) shl 16 + GetBYTE(i+2) shl 24;

	if p = 0 then begin
	 listing[i]   := '';

	 listing[i+2] := '';
	 listing[i+3] := '';
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

 	 exit(false);
	end else
	if bmi(i+23) and (p = low(integer)) then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
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

	 listing[i+23] := #9'beq @+';

	 exit(false);
	end else begin

	 if (i > 0) and ldy_1(i-1) and
	    tya(i+26) and
	    (jeq(i+27) or jne(i+27)) then
	 begin
	  listing[i-1] := '';

	  if jeq(i+27) then begin

	   if bpl(i+23) then
	    listing[i+23] := #9'jmi ' + copy(listing[i+27], 6, 256)
	   else
	    listing[i+23] := #9'jpl ' + copy(listing[i+27], 6, 256);

	  end else begin

	   if bpl(i+23) then
	    listing[i+23] := #9'jpl ' + copy(listing[i+27], 6, 256)
	   else
	    listing[i+23] := #9'jmi ' + copy(listing[i+27], 6, 256);

	  end;

          listing[i+24] := '';
          listing[i+25] := '';
          listing[i+26] := '';
          listing[i+27] := '';

	  exit(false);
	 end;

	end;

      end;


    if ENDL(i+22) and										// .ENDL		; 22
       (bpl(i+23) or bmi(i+23)) and								// bmi|bpl		; 23
       dey(i+24) and										// dey			; 24
       lab_a(i+25) and										//@			; 25
       tya(i+26) and										// tya			; 26
       (jeq(i+27) or jne(i+27)) and								// jeq|jne		; 27

       LOCAL(i) and										// .LOCAL		; 0	INTEGER < 		BMI
       lda_a(i+1) and										// lda E+3		; 1	INTEGER >= 		BPL
       sub(i+2) and {(sub_im(i+2) = false) and}							// sub			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E+2		; 4
       cmp(i+5) and {(cmp_im(i+5) = false) and}							// cmp			; 5
       (listing[i+6] = #9'bne L1') and								// bne L1		; 6
       lda_a(i+7) and										// lda E+1		; 7
       cmp(i+8) and {(cmp_im(i+8) = false) and}							// cmp			; 8
       (listing[i+9] = #9'bne L1') and								// bne L1		; 9
       lda_a(i+10) and										// lda E		; 10
       cmp(i+11) and (cmp_im(i+11) = false) and							// cmp			; 11
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

	if jeq(i+27) then begin

	   if bpl(i+23) then
	    listing[i+23] := #9'jmi ' + copy(listing[i+27], 6, 256)
	   else
	    listing[i+23] := #9'jpl ' + copy(listing[i+27], 6, 256);

	end else begin

	   if bpl(i+23) then
	    listing[i+23] := #9'jpl ' + copy(listing[i+27], 6, 256)
	   else
	    listing[i+23] := #9'jmi ' + copy(listing[i+27], 6, 256);

	end;

        for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

        listing[i+24] := '';
        listing[i+25] := '';
        listing[i+26] := '';
        listing[i+27] := '';

	exit(false);
      end;


end;		// function
