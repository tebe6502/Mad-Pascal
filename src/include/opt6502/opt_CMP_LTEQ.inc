
function opt_LTEQ(i: integer): Boolean;
var p: integer;
    c: cardinal;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
//				      LTEQ.
// -----------------------------------------------------------------------------

    if lda_a(i) and										// lda K+3		; 0	CARDINAL <=
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda K+2		; 3
       cmp_im(i+4) and										// cmp #		; 4
       bne(i+5) and										// bne @+		; 5
       lda_a(i+6) and										// lda K+1		; 6
       cmp_im(i+7) and										// cmp #		; 7
       bne(i+8) and										// bne @+		; 8
       lda_a(i+9) and										// lda K		; 9
       cmp_im(i+10) and										// cmp #		; 10
       lab_a(i+11) and										//@			; 11
       bcc_a(i+12) and										// bcc @+		; 12
       jne(i+13) and										// jne l_		; 13
       lab_a(i+14) then 									//@			; 14
     begin
      c := GetWORD(i+10, i+7) + GetWORD(i+4, i+1) shl 16;

      if c = 0 then begin
       listing[i+1] := '';
       listing[i+2] := listing[i+13];

       listing[i+4] := '';
       listing[i+5] := listing[i+13];

       listing[i+7] := '';
       listing[i+8] := listing[i+13];

       listing[i+10] := '';
       listing[i+11] := '';
       listing[i+12] := '';

       listing[i+14] := '';

       exit(false);
      end else
      if c < $FFFFFFFF then begin

        inc(c);

	listing[i+1] := #9'cmp #' + HexByte(byte(c shr 24));

	listing[i+4] := #9'cmp #' + HexByte(byte(c shr 16));

	listing[i+7] := #9'cmp #' + HexByte(byte(c shr 8));

	if c and $ff = 0 then begin
	 listing[i+8] := #9'sne';

	 listing[i+10] := '';
	 listing[i+11] := '';
	end else
	 listing[i+10] := #9'cmp #' + HexByte(c and $ff);

	listing[i+12] := '';
	listing[i+13] := #9'jcs ' + copy(listing[i+13], 6, 256);
	listing[i+14] := '';

	exit(false);
      end else begin
	listing[i]    := '';
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

	exit(false);
      end;

     end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda K+1		; 0	WHILE WORD <=
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda K		; 3
       cmp_im(i+4) and										// cmp #		; 4
       lab_a(i+5) and										//@			; 5
       jcc(i+6) and										// jcc l_		; 6
       jeq(i+7) then										// jeq l_		; 7
     begin
      p := GetWORD(i+4, i+1);

      if (p > 0) and (p < $FFFF) then begin
       inc(p);

       listing[i+1] := #9'cmp #' + HexByte(byte(p shr 8));
       listing[i+2] := listing[i+6];

       listing[i+7] := '@';

       if (p and $ff) <> 0 then
        listing[i+5] := #9'cmp #' + HexByte(byte(p) and $ff)
       else
        listing[i+5] := '';

       listing[i+4] := listing[i+3];
       listing[i+3] := #9'bne @+';

       exit(false);
      end;

     end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda K+1		; 0	WORD <=
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda K		; 3
       cmp_im(i+4) and										// cmp #		; 4
       lab_a(i+5) and										//@			; 5
       bcc_a(i+6) and										// bcc @+		; 6
       jne(i+7) and										// jne l_		; 7
       lab_a(i+8) then 										//@			; 8
     begin

      p := GetWORD(i+4, i+1);

      if p = 0 then begin
       listing[i+1] := '';
       listing[i+2] := listing[i+7];

       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       listing[i+8] := '';

       exit(false);
      end else
      if p < $FFFF then begin

        inc(p);

	listing[i+1] := #9'cmp #' + HexByte(byte(p shr 8));

	if (p and $ff) = 0 then begin
	 listing[i+2] := #9'sne';

	 listing[i+4] := '';
	 listing[i+5] := '';
	end else
	 listing[i+4] := #9'cmp #' + HexByte(Byte(p) and $ff);

	listing[i+6] := '';
	listing[i+7] := #9'jcs ' + copy(listing[i+7], 6, 256);
	listing[i+8] := '';

	exit(false);
      end else begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;

     end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda K+1		; 0	BOOL := WORD <=  ->  WORD >=
       cmp(i+1) and (cmp_im(i+1) = false) and							// cmp W+1		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda K		; 3
       cmp(i+4) and (cmp_im(i+4) = false) and							// cmp W		; 4
       lab_a(i+5) and										//@			; 5
       bcc_a(i+6) and										// bcc @+		; 6
       beq_a(i+7) and										// beq @+		; 7
       dey(i+8) and										// dey			; 8
       lab_a(i+9) then 										//@			; 9
      begin

{ !!!
	if cmp_im(i+1) and cmp_im(i+4) then begin
         c := GetWORD(i+4, i+1);

	 if c < $FFFF then begin
	  listing[i+1] := #9'cmp #' + Hex(byte((c+1) shr 8),2);

	  listing[i+4] := #9'cmp #' + Hex(byte(c+1),2);

	  listing[i+7] := '';

     	  exit(false);
	 end;

	end else begin
}
 	 tmp := listing[i];
	 listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	 listing[i+1] := #9'cmp ' + copy(tmp, 6, 256);

	 tmp := listing[i+3];
	 listing[i+3] := #9'lda ' + copy(listing[i+4], 6, 256);
	 listing[i+4] := #9'cmp ' + copy(tmp, 6, 256);

	 listing[i+6] := #9'bcs @+';
	 listing[i+7] := '';

	 exit(false);

//	end;

      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda K+1		; 0	BOOL := WORD <=  ->  WORD >=
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda K		; 3
       cmp_im(i+4) and										// cmp #		; 4
       lab_a(i+5) and										//@			; 5
       bcc_a(i+6) and										// bcc @+		; 6
       beq_a(i+7) and										// beq @+		; 7
       dey(i+8) and										// dey			; 8
       lab_a(i+9) and 										//@			; 9
       tya(i+10) and										// tya			; 10
       (sta(i+11) or and_ora_eor(i+11)) and							// sta|and|ora|eor	; 11
												//			; 12
       (dex(i+13) = false) then									//~dex			; 13
      begin

        c := GetWORD(i+4, i+1);

	if c = 0 then begin
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);
	  listing[i+4] := '';

	  listing[i+6] := '';

     	  exit(false);
	end else

	if c < $FFFF then begin
	  listing[i+1] := #9'cmp #' + HexByte(byte((c+1) shr 8));

	  listing[i+4] := #9'cmp #' + HexByte(byte(c+1));

	  listing[i+7] := '';

     	  exit(false);
	end;

      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda K		; 0	BYTE <=
       cmp_im(i+1) and										// cmp #		; 1
       bcc_a(i+2) and										// bcc @+		; 2
       jne(i+3) and										// jne l_		; 3
       lab_a(i+4) then										//@			; 4
     begin
      p := GetBYTE(i+1);

      if p = 0 then begin
       listing[i+2] := '';

       listing[i+4] := '';

       exit(false);
      end else
      if p < $FF then begin
	listing[i+1] := #9'cmp #' + HexByte((p+1) and $ff);

	listing[i+2] := '';
	listing[i+3] := #9'jcs ' + copy(listing[i+3], 6, 256);
	listing[i+4] := '';

	exit(false);
      end else begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;

     end;


    if (SKIP(i-1) = false) and									//				BYTE <=  ->  BYTE >=
       lda_a(i) and										// lda			; 0
       cmp(i+1) and (cmp_im(i+1) = false) and							// cmp			; 1
       jcc(i+2) and										// jcc			; 2
       jeq(i+3) then										// jeq			; 3
      begin
       listing[i+2] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);
       listing[i]   := '';

       listing[i+3] := #9'jcs ' + copy(listing[i+3], 6, 256);

       exit(false);
      end;


    if (SKIP(i-1) = false) and									//				BOOL := BYTE <=  ->  BYTE >=
       lda(i) and										// lda			; 0
       cmp(i+1) and 										// cmp			; 1
       bcc(i+2) and										// bcc @+		; 2
       beq(i+3) and										// beq @+		; 3
       dey(i+4) and										// dey			; 4
       lab_a(i+5) and										//@			; 5
       (sty(i+6) or tya(i+6)) then								// sty|tya		; 6
      begin
       listing[i+2] := #9'cmp ' + copy(listing[i], 6, 256);
       listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);
       listing[i]   := '';

       listing[i+3] := #9'bcs @+';

       exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SHORTINT
// -----------------------------------------------------------------------------

    if ENDL(i+8) and										// .ENDL		; 8
       bmi(i+9) and										// bmi @+		; 9
       beq(i+10) and										// beq @+		; 10
       dey(i+11) and										// dey			; 11
       lab_a(i+12) and										//@			; 12
       (sty(i+13) or tya(i+13)) and								// sty|tya		; 13

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT <= $XX
       lda_a(i+1) and										// lda E		; 1
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7
      begin
        p := shortint(GetBYTE(i+2));

	if p = 0 then begin
	 listing[i+4] := listing[i+1];
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	end else
	if p = -128 then begin
	 listing[i+4] := listing[i+1];
	 listing[i+5] := #9'cmp #$80';
	 listing[i+6] := #9'beq @+';
	 listing[i+7] := '';
	 listing[i+8] := '';

	 listing[i+9] := '';
	 listing[i+10] := '';
	end else begin
	 inc(p);

	 listing[i+4] := listing[i+1];
	 listing[i+5] := #9'sub #' + HexByte(p and $ff);
	 listing[i+6] := #9'svc';
	 listing[i+7] := #9'eor #$80';
	 listing[i+8] := #9'bmi @+';

	 listing[i+9] := '';
	 listing[i+10] := '';
	end;

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if ENDL(i+8) and										// .ENDL		; 8
       bmi(i+9) and										// bmi @+		; 9
       beq(i+10) and										// beq @+		; 10
       dey(i+11) and										// dey			; 11
       lab_a(i+12) and										//@			; 12
       (sty(i+13) or tya(i+13)) and								// sty|tya		; 13

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT_0 <= SHORTINT_1  ->  SHORTINT_1 >= SHORTINT_0
       lda_a(i+1) and										// lda A		; 1
       sub(i+2) and (sub_im(i+2) = false) and							// sub B		; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7

      begin
	tmp:=listing[i+1];

	listing[i+1] := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+2] := #9'sub ' + copy(tmp, 6, 256);

	listing[i+9]  := #9'bpl @+';
	listing[i+10] := '';

	exit(false);
      end;

// -----------------------------------------------------------------------------
// 				     SMALLINT
// -----------------------------------------------------------------------------

    if ENDL(i+15) and										// .ENDL		; 15
       bmi_a(i+16) and										// bmi @+		; 16
       beq_a(i+17) and										// beq @+		; 17
       dey(i+18) and										// dey			; 18
       lab_a(i+19) and										//@			; 19
       (sty(i+20) or tya(i+20)) and								// sty|tya		; 20

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT <= #
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
       p := GetWORD(i+5, i+2);

       if p = 0 then begin
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := listing[i+1];
	listing[i+15] := #9'bmi @+';
	listing[i+16] := #9'ora ' + copy(listing[i+4], 6, 256);
	listing[i+17] := #9'seq';
       end else begin
        inc(p);

	if p = $8000 then begin
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := '';
	 listing[i+16] := '';
	end else begin
	 listing[i+10] := listing[i+4];
	 listing[i+11] := #9'cmp #' + HexByte(p and $ff);
	 listing[i+12] := listing[i+1];
	 listing[i+13] := #9'sbc #' + HexByte(Byte(p shr 8));
	 listing[i+14] := #9'svc';
	 listing[i+15] := #9'eor #$80';
	 listing[i+16] := #9'bmi @+';
	 listing[i+17] := '';
	end;

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
       bmi_a(i+16) and										// bmi @+		; 16
       beq_a(i+17) and										// beq @+		; 17
       dey(i+18) and										// dey			; 18
       lab_a(i+19) and										//@			; 19
       (sty(i+20) or tya(i+20)) and								// sty|tya		; 20

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT_0 <= SMALLINT_1 -> SMALLINT_1 >= SMALLINT_0
       lda(i+1) and										// lda E+1		; 1
       sub(i+2) and 										// sub 			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda(i+4) and										// lda E		; 4
       cmp(i+5) and (cmp_im(i+5) = false) and							// cmp 			; 5
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
	listing[i+11] := #9'lda ' + copy(listing[i+5], 6, 256);
	listing[i+12] := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+13] := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+14] := #9'sbc ' + copy(listing[i+1], 6, 256);
	listing[i+15] := #9'svc';
	listing[i+16] := #9'eor #$80';
	listing[i+17] := #9'bpl @+';

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
	listing[i+10] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     INTEGER
// -----------------------------------------------------------------------------

    if ENDL(i+22) and										// .ENDL		; 22
       bmi_a(i+23) and										// bmi @+		; 23
       beq_a(i+24) and										// beq @+		; 24
       dey(i+25) and										// dey			; 25
       lab_a(i+26) and										//@			; 26
       (sty(i+27) or tya(i+27)) and								// sty|tya		; 27

       LOCAL(i) and										// .LOCAL		; 0	INTEGER <= #
       lda_a(i+1) and										// lda E+3		; 1
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

        if sub_im_0(i+2) and cmp_im_0(i+5) and cmp_im_0(i+8) and cmp_im_0(i+11) then begin
	 listing[i]   := listing[i+1];
	 listing[i+1] := #9'bmi @+';
	 listing[i+2] := #9'ora ' + copy(listing[i+4], 6, 256);
	 listing[i+3] := #9'ora ' + copy(listing[i+7], 6, 256);
	 listing[i+4] := #9'ora ' + copy(listing[i+10], 6, 256);
	 listing[i+5] := #9'seq';
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
	 listing[i+23] := '';
	 listing[i+24] := '';

	 exit(false);
        end else begin

	 if (i > 0) and ldy_1(i-1) and
	    tya(i+27) and
	    (jeq(i+28) or jne(i+28)) then
	 begin
	  listing[i-1] := '';

	  if jeq(i+28) then begin
           listing[i+23] := #9'smi';
       	   listing[i+24] := #9'jne ' + copy(listing[i+28], 6, 256);
	  end else begin
       	   listing[i+23] := #9'jmi ' + copy(listing[i+28], 6, 256);
           listing[i+24] := #9'jeq ' + copy(listing[i+28], 6, 256);
	  end;

          listing[i+25] := '';
          listing[i+26] := '';
          listing[i+27] := '';
          listing[i+28] := '';

	  exit(false);
	 end;

	end;

      end;


    if ENDL(i+22) and										// .ENDL		; 22
       bmi_a(i+23) and										// bmi @+		; 23
       beq_a(i+24) and										// beq @+		; 24
       dey(i+25) and										// dey			; 25
       lab_a(i+26) and										//@			; 26
       tya(i+27) and										// tya			; 27
       (jeq(i+28) or jne(i+28)) and								// jeq|jne		; 28

       LOCAL(i) and										// .LOCAL		; 0	INTEGER <=
       lda_a(i+1) and										// lda E+3		; 1
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

	if jeq(i+28) then begin
          listing[i+23] := #9'smi';
       	  listing[i+24] := #9'jne ' + copy(listing[i+28], 6, 256);
	end else begin
       	  listing[i+23] := #9'jmi ' + copy(listing[i+28], 6, 256);
          listing[i+24] := #9'jeq ' + copy(listing[i+28], 6, 256);
	end;

        for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

        listing[i+25] := '';
        listing[i+26] := '';
        listing[i+27] := '';
        listing[i+28] := '';

	exit(false);
      end;


end;		// function
