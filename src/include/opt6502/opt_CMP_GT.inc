
function opt_GT(i: integer): Boolean;
var p: integer;
    c: cardinal;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
//					GT.
// -----------------------------------------------------------------------------

    if lab_a(i+11) and										//@			; 11
       jcc(i+12) and										// jcc l_		; 12
       jeq(i+13) and										// jeq l_		; 13

       lda_a(i) and										// lda			; 0	CARDINAL > 0
       bne_a(i+1) and										// bne @+		; 1
       dey(i+2) and										// dey			; 2
       lda_a(i+3) and										// lda			; 3
       bne_a(i+4) and										// bne @+		; 4
       dey(i+5) and										// dey			; 5
       lda_a(i+6) and										// lda			; 6
       bne_a(i+7) and										// bne @+		; 7
       dey(i+8) and										// dey			; 8
       lda_a(i+9) and										// lda			; 9
       cmp_im_0(i+10) then									// cmp #$00		; 10
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


    if lab_a(i+11) and										//@			; 11
       jcc(i+12) and										// jcc l_		; 12
       jeq(i+13) and										// jeq l_		; 13

       lda_val(i) and										// lda W+3		; 0	opt_092 | CARDINAL > 0
       cmp_im(i+1) and										// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W+2		; 3
       cmp_im(i+4) and										// cmp #$00		; 4
       bne(i+5) and										// bne @+		; 5
       lda_a(i+6) and										// lda W+1		; 6
       cmp_im(i+7) and										// cmp #$00		; 7
       bne(i+8) and										// bne @+		; 8
       lda_a(i+9) and										// lda W		; 9
       cmp_im(i+10) then									// cmp #$00		; 10
      begin
       c := GetDWORD(i+10, i+7, i+4, i+1);

       if c = 0 then begin
        listing[i+1] := '';
        listing[i+2] := '';
        listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);

        listing[i+4] := '';
        listing[i+5] := '';
        listing[i+6] := #9'ora ' + copy(listing[i+6], 6, 256);

        listing[i+7] := '';
        listing[i+8] := '';
        listing[i+9] := #9'ora ' + copy(listing[i+9], 6, 256);

        listing[i+10] := '';
        listing[i+11] := '';
        listing[i+12] := '';

        exit(false);
       end else
       if c < $FFFFFFFF then begin
        listing[i+1] := #9'cmp #$' + IntToHex(byte((c+1) shr 24), 2);

        listing[i+4] := #9'cmp #$' + IntToHex(byte((c+1) shr 16), 2);

        listing[i+7] := #9'cmp #$' + IntToHex(byte((c+1) shr 8), 2);

        listing[i+10] := #9'cmp #$' + IntToHex(byte(c+1), 2);

	listing[i+13] := '';

        exit(false);
       end else
       if c = $FFFFFFFF then begin
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
	listing[i+11] := '';
	listing[i+12] := '';

	listing[i+13] := #9'jmp ' + copy(listing[i+13], 6, 256);

	exit(false);
       end;

      end;


// -----------------------------------------------------------------------------
// 				     WORD
// -----------------------------------------------------------------------------

{ !!! nie usuwaj 'CMP #$00' !!!

    if ldy_1(i) and										// ldy #1		; 0	BOOL := WORD >
       lda_val(i+1) and										// lda W+1		; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       bne_a(i+3) and										// bne @+		; 3
       lda_a(i+4) and										// lda W		; 4
       cmp(i+5) and (cmp_im_0(i+5) = false) and							// cmp			; 5
       lab_a(i+6) and										//@			; 6
       bcs_a(i+7) and										// bcs @+		; 7
       dey(i+8) and										// dey			; 8
       lab_a(i+9) and										//@			; 9
       tya(i+10) and										// tya			; 10
       (sta(i+11) or and_ora_eor(i+11)) and							// sta|and|ora|eor	; 11
												//			; 12
       (dex(i+13) = false) then									//~dex			; 13
      begin
       listing[i+2] := '';

       listing[i+6] := '';

       exit(false);
      end;
}

    if (SKIP(i-1) = false) and
       lda_bp2_y(i) and										// lda (:bp2),y		; 0	:BP2 > 0
       bne(i+1) and										// bne @+		; 1
       dey(i+2) and										// dey			; 2
       lda_bp2_y(i+3) and									// lda (:bp2),y		; 3
       cmp_im_0(i+4) and									// cmp #$00		; 4
       lab_a(i+5) and										//@			; 5
       jcc(i+6) and										// jcc l_		; 6
       jeq(i+7) then										// jeq l_		; 7
      begin
	listing[i+1] := '';

        listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);

       // listing[i+4] := '';
        listing[i+5] := '';
        listing[i+6] := '';

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda W+1		; 0	opt_093 | WORD > 0
       cmp_im(i+1) and										// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp_im(i+4) and										// cmp #$00		; 4
       lab_a(i+5) and										//@			; 5
       jcc(i+6) and										// jcc l_		; 6
       jeq(i+7) then										// jeq l_		; 7
      begin

	c:=GetWord(i+4, i+1);

	if c = 0 then begin
	 listing[i+1] := '';
         listing[i+2] := '';
         listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);

         listing[i+5] := '';
         listing[i+6] := '';

	 exit(false);
        end else
	if c < $FFFF then begin									// faster than by SUB
	 listing[i+1] := #9'cmp #$' + IntToHex(byte((c+1) shr 8),2);

	 listing[i+4] := #9'cmp #$' + IntToHex(byte(c+1),2);

	 listing[i+7] := '';

	 exit(false);
	end else
	if c = $FFFF then begin
	 listing[i] := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';

	 listing[i+7] := #9'jmp ' + copy(listing[i+7], 6, 256);

	 exit(false);
	end;

      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda W+1		; 0	opt_091 | WORD > 0
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp_im(i+4) and										// cmp #		; 4
       lab_a(i+5) and										//@			; 5
       beq(i+6) and										// beq @+		; 6
       jcs(i+7) and										// jcs l_		; 7
       lab_a(i+8) then										//@			; 8
      begin

	c:=GetWord(i+4, i+1);

	if c = 0 then begin
	 listing[i+1] := '';
         listing[i+2] := #9'jne ' + copy(listing[i+7], 6, 256);

         listing[i+5] := '';
         listing[i+6] := '';
         listing[i+7] := #9'jne ' + copy(listing[i+7], 6, 256);

	 exit(false);
        end else
	if c < $FFFF then begin
	 listing[i+1] := #9'cmp #$' + IntToHex(byte((c+1) shr 8),2);

	 listing[i+4] := #9'cmp #$' + IntToHex(byte(c+1),2);

	 listing[i+6] := '';

	 listing[i+8] := '';

	 exit(false);
	end;

      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda W+1			; 0	BYTE > BYTE + 255
       (listing[i+1] = #9'add #$FF') and							// add #$FF			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN		; 2
       lda_im_0(i+3) and									// lda #$00			; 3
       adc_im_0(i+4) and									// adc #$00			; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH	; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH	; 6
       cmp_im_0(i+7) and									// cmp #$00			; 7
       bne(i+8) and										// bne @+			; 8
       lda_stack(i+9) and									// lda :STACKORIGIN		; 9
       cmp(i+10) and										// cmp				; 10
       lab_a(i+11) and										//@				; 11
       jcs(i+12) and										// jcs l_			; 12
       (SKIP(i+13) = false) then								//				; 13
     if argMatch(i+2, i+9) and
        argMatch(i+5, i+6) then
      begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';
	listing[i+9]:= '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	listing[i+12] := #9'jmp ' + copy(listing[i+12], 6, 256);

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda W+1		; 0	BOOL := WORD > WORD
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp_im(i+4) and										// cmp #		; 4
       lab_a(i+5) and										//@			; 5
       seq(i+6) and										// seq			; 6
       bcs(i+7) and										// bcs @+		; 7
       dey(i+8) and										// dey			; 8
       lab_a(i+9) then										//@			; 9
      begin

	c:=GetWord(i+4, i+1);

	if c = 0 then begin
	 listing[i+1] := '';
         listing[i+2] := '';
	 listing[i+3] := #9'ora ' + copy(listing[i+3], 6, 256);
         listing[i+4] := '';
         listing[i+5] := '';
         listing[i+6] := '';
         listing[i+7] := #9'bne @+';

	 exit(false);
        end else
	if c < $FFFF then begin
	 listing[i+1] := #9'cmp #$' + IntToHex(byte((c+1) shr 8),2);

	 listing[i+4] := #9'cmp #$' + IntToHex(byte(c+1),2);

	 listing[i+6] := '';

	 exit(false);
	end;

      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda W+1		; 0	WORD_1 > WORD_2 => WORD_2 < WORD_1
       cmp(i+1) and (cmp_im(i+1) = false) and 							// cmp 			; 1
       bne(i+2) and										// bne @+		; 2
       lda_a(i+3) and										// lda W		; 3
       cmp(i+4) and (cmp_im(i+4) = false) and							// cmp			; 4
       lab_a(i+5) and										//@			; 5
       seq(i+6) and										// seq			; 6
       bcs(i+7) and										// bcs @+		; 7
       dey(i+8) then										// dey			; 8
      begin
	tmp := listing[i];
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'cmp ' + copy(tmp, 6, 256);

	tmp := listing[i+3];
	listing[i+3]   := #9'lda ' + copy(listing[i+4], 6, 256);
	listing[i+4] := #9'cmp ' + copy(tmp, 6, 256);

	listing[i+6] := '';
	listing[i+7] := #9'bcc @+';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     BYTE
// -----------------------------------------------------------------------------

    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda			; 0	opt_094	| BYTE > 0
       cmp_im(i+1) and										// cmp #		; 1
       jcc(i+2) and										// jcc l_		; 2
       jeq(i+3) then										// jeq l_		; 3
      begin

       if cmp_im_0(i+1) then begin
        listing[i+1] := '';
        listing[i+2] := '';

	exit(false);
       end else begin
	c:=GetByte(i+1);

	if c < 255 then begin
	 listing[i+1] := #9'cmp #$' + IntToHex(byte(c + 1), 2);

	 listing[i+3] := '';

	 exit(false);
	end else
	if c = 255 then begin
	 listing[i] := '';
	 listing[i+1] := '';
	 listing[i+2] := '';

	 listing[i+3] := #9'jmp ' + copy(listing[i+3], 6, 256);

	 exit(false);
	end;

       end;

      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda			; 0	BYTE > 0
       cmp_im(i+1) and										// cmp #		; 1
       seq(i+2) and										// seq			; 2
       bcs_a(i+3) then										// bcs @+		; 3
      begin

       if cmp_im_0(i+1) then begin
        listing[i+1] := '';
        listing[i+2] := '';
	listing[i+3] := #9'bne @+';

	exit(false);
       end else begin
	c:=GetByte(i+1);

	if c < 255 then begin
	 listing[i+1] := #9'cmp #$' + IntToHex(byte(c+1), 2);

	 listing[i+2] := '';

	 exit(false);
	end;

       end;

      end;


    if (SKIP(i-1) = false) and
       lda_a(i) and										// lda			; 0	BYTE_1 > BYTE_2 => BYTE_2 < BYTE_1
       cmp(i+1) and (cmp_im(i+1) = false) and							// cmp			; 1
       seq(i+2) and										// seq			; 2
       bcs_a(i+3) then										// bcs @+		; 3
      begin
	tmp := listing[i];

	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'cmp ' + copy(tmp, 6, 256);
	listing[i+2] := #9'bcc @+';
	listing[i+3] := '';

	exit(false);
      end;


    if (SKIP(i) = false) and									//
       bmi_a(i+1) and										// bmi @+		; 1	> 0
       ora(i+2) and										// ora 			; 2
       sne(i+3) and										// sne			; 3
       lab_a(i+4) and										//@			; 4
       jmp(i+5) then										// jmp l_		; 5
      begin
	listing[i+1] := #9'jmi ' + copy(listing[i+5], 6, 256);

	listing[i+3] := #9'jeq ' + copy(listing[i+5], 6, 256);
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if (SKIP(i) = false) and									//
       bmi_a(i+1) and										// bmi @+		; 1	> 0
       ora(i+2) and										// ora 			; 2
       sne(i+3) and										// sne			; 3
       lab_a(i+4) and										//@			; 4
       dey(i+5) and										// dey			; 5
       lab_a(i+6) and										//@			; 6
       tya(i+7) and										// tya			; 7
       jeq(i+8) then										// jeq			; 8
      begin
	listing[i+1] := #9'jmi ' + copy(listing[i+8], 6, 256);

	listing[i+3] := #9'jeq ' + copy(listing[i+8], 6, 256);
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SHORTINT
// -----------------------------------------------------------------------------

    if ENDL(i+8) and										// .ENDL		; 8
       seq(i+9) and										// seq			; 9
       bpl_a(i+10) and										// bpl @+		; 10
       dey(i+11) and										// dey			; 11
       lab_a(i+12) and										//@			; 12
       (sty(i+13) or tya(i+13)) and								// sty|tya		; 13

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT > XX
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
	 listing[i] := listing[i+1];
	 listing[i+1] := #9'smi';
	 listing[i+2] := #9'bne @+';
	 listing[i+3] := '';
	 listing[i+4] := '';
	end else
	if p = 127 then begin
	 listing[i] := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := #9'beq @+';
	end else begin
	 inc(p);

	 listing[i] := listing[i+1];
	 listing[i+1] := #9'sub #$' + IntToHex(p and $ff, 2);
	 listing[i+2] := #9'svc';
	 listing[i+3] := #9'eor #$80';
	 listing[i+4] := #9'bpl @+';
	end;

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	exit(false);
      end;


    if ENDL(i+8) and										// .ENDL		; 8
       seq(i+9) and										// seq			; 9
       bpl_a(i+10) and										// bpl @+		; 10
       dey(i+11) and										// dey			; 11
       lab_a(i+12) and										//@			; 12
       (sty(i+13) or tya(i+13)) and								// sty|tya		; 13

       LOCAL(i) and										// .LOCAL		; 0	SHORTINT_0 > SHORINT_1 => SHORTINT_1 < SHORTINT_0
       lda_a(i+1) and										// lda K		; 1
       sub(i+2) and (sub_im(i+2) = false) and							// sub U		; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7
      begin
        tmp := listing[i+1];

	listing[i+1] := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+2] := #9'sub ' + copy(tmp, 6, 256);

	listing[i+9]  := '';
	listing[i+10] := #9'bmi @+';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     SMALLINT
// -----------------------------------------------------------------------------

    if ENDL(i+15) and										// .ENDL		; 15
       seq(i+16) and										// seq			; 16
       bpl_a(i+17) and										// bpl @+		; 17
       dey(i+18)  and										// dey			; 18
       lab_a(i+19) and										//@			; 19
       (sty(i+20) or tya(i+20)) and								// sty|tya		; 20

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT > #
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
	 listing[i+13] := listing[i+1];
	 listing[i+14] := #9'bmi @+';
 	 listing[i+15] := #9'ora ' + copy(listing[i+4], 6, 256);
	 listing[i+16] := #9'sne';
	 listing[i+17] := '@';
	end else
	if p < $7FFF then begin
	 inc(p);

	 listing[i+10] := listing[i+4];
	 listing[i+11] := #9'cmp #$' + IntToHex(p and $ff, 2);
	 listing[i+12] := listing[i+1];
	 listing[i+13] := #9'sbc #$' + IntToHex(byte(p shr 8), 2);
	 listing[i+14] := #9'svc';
	 listing[i+15] := #9'eor #$80';
	 listing[i+16] := '';
	end else begin
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := #9'beq @+';
	 listing[i+16] := '';
	 listing[i+17] := '';
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
       seq(i+16) and										// seq			; 16
       bpl_a(i+17) and										// bpl @+		; 17
       dey(i+18)  and										// dey			; 18
       lab_a(i+19) and										//@			; 19
       (sty(i+20) or tya(i+20)) and								// sty|tya		; 20

       LOCAL(i) and										// .LOCAL		; 0	SMALLINT_0 > SMALLINT_1 => SMALLINT_1 < SMALLINT_0
       lda_a(i+1) and 										// lda K+1		; 1
       sub(i+2) and 			 							// sub U+1		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda K		; 4
       cmp(i+5) and (cmp_im(i+5) = false) and							// cmp U		; 5
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
	tmp := listing[i+1];
	listing[i+1] := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+2] := #9'sub ' + copy(tmp, 6, 256);

	tmp := listing[i+4];
	listing[i+4] := #9'lda ' + copy(listing[i+5], 6, 256);
	listing[i+5] := #9'cmp ' + copy(tmp, 6, 256);

	listing[i+16] := '';
	listing[i+17] := #9'bmi @+';

	exit(false);
      end;


// -----------------------------------------------------------------------------
// 				     INTEGER
// -----------------------------------------------------------------------------

    if ENDL(i+22) and										// .ENDL		; 22
       seq(i+23) and										// seq			; 23
       bpl(i+24) and										// bpl @+		; 24
       dey(i+25) and										// dey			; 25
       lab_a(i+26) and										//@			; 26
       (sty(i+27) or tya(i+27)) and								// sty|tya		; 27

       LOCAL(i) and										// .LOCAL		; 0	INTEGER > XXYYXXYY
       lda_a(i+1) and 										// lda E+3		; 1
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and {(lda_stack(i+4) = false) and}						// lda E+2		; 4
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

	 if lda_im_0(i+1) then begin
 	  listing[i+16] := '';
	  listing[i+17] := '';
	  listing[i+18] := #9'lda ' + copy(listing[i+4], 6, 256);
	  listing[i+19] := #9'ora ' + copy(listing[i+7], 6, 256);
	  listing[i+20] := #9'ora ' + copy(listing[i+10], 6, 256);
	  listing[i+21] := #9'sne';
	  listing[i+22] := '';
	 end else begin
 	  listing[i+16] := listing[i+1];
	  listing[i+17] := #9'bmi @+';
	  listing[i+18] := #9'ora ' + copy(listing[i+4], 6, 256);
	  listing[i+19] := #9'ora ' + copy(listing[i+7], 6, 256);
	  listing[i+20] := #9'ora ' + copy(listing[i+10], 6, 256);
	  listing[i+21] := #9'sne';
	  listing[i+22] := '@';
	 end;

	 listing[i+23] := '';
	 listing[i+24] := '';

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
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := '';

	 exit(false);
	end else
	if p < $7FFFFFFF then begin

	 if (i > 0) and ldy_1(i-1) and
	    tya(i+27) and
	    (jeq(i+28) or jne(i+28)) then
	 begin
	  listing[i-1] := '';

	  if jeq(i+28) then begin
       	   listing[i+23] := #9'jmi ' + copy(listing[i+28], 6, 256);
           listing[i+24] := #9'jeq ' + copy(listing[i+28], 6, 256);
	  end else begin
       	   listing[i+23] := #9'smi';
           listing[i+24] := #9'jne ' + copy(listing[i+28], 6, 256);
	  end;

          listing[i+25] := '';
          listing[i+26] := '';
          listing[i+27] := '';
          listing[i+28] := '';

	  exit(false);
	 end;

	end else begin
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
	 listing[i+22] := #9'beq @+';
	 listing[i+23] := '';
	 listing[i+24] := '';

	 exit(false);
	end;

      end;


    if ENDL(i+22) and										// .ENDL		; 22
       seq(i+23) and										// seq			; 23
       bpl(i+24) and										// bpl @+		; 24
       dey(i+25) and										// dey			; 25
       lab_a(i+26) and										//@			; 26
       tya(i+27) and										// tya			; 27
       jeq(i+28) and										// jeq			; 28

       LOCAL(i) and										// .LOCAL		; 0	INTEGER >
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

	listing[i+23] := #9'jmi ' + copy(listing[i+28], 6, 256);
	listing[i+24] := #9'jeq ' + copy(listing[i+28], 6, 256);

        for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

        listing[i+25] := '';
        listing[i+26] := '';
        listing[i+27] := '';
        listing[i+28] := '';

	exit(false);
      end;


end;		// function
