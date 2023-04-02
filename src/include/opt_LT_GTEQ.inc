// -----------------------------------------------------------------------------
//				      LT.
//				      GTEQ.
// -----------------------------------------------------------------------------

    if lab_a(i+11) and										//@			; 11

       lda(i) and										// lda W+3		; 0	opt_080 | CARDINAL < 0 ; >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W+2		; 3
       cmp_im_0(i+4) and									// cmp #$00		; 4
       bne(i+5) and										// bne @+		; 5
       lda(i+6) and										// lda W+1		; 6
       cmp_im_0(i+7) and									// cmp #$00		; 7
       bne(i+8) and										// bne @+		; 8
       lda(i+9) and										// lda W		; 9
       cmp(i+10) and										// cmp			; 10

       (jcs(i+12) or jcc(i+12)) and								// jcc|jcs l_		; 12
       (SKIP(i+13) = false) then
     if (pos(listing[i+9], listing[i]) > 0) and
        (pos(listing[i+9], listing[i+3]) > 0) and
        (pos(listing[i+9], listing[i+6]) > 0) then
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

        Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	WHILE WORD <
       cmp_im(i+1) and										// cmp #		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp_im_0(i+4) and									// cmp #$00		; 4
       lab_a(i+5) and										//@			; 5
       jcc(i+6) and										// jcc l_		; 6
       (SKIP(i+7) = false) then
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

        Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda W+1		; 0	opt_081 | WORD < 0 ; >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       bne(i+2) and										// bne @+		; 2
       lda(i+3) and										// lda W		; 3
       cmp(i+4) and										// cmp 			; 4
       lab_a(i+5) and										//@			; 5
       (jcs(i+6) or jcc(i+6)) and								// jcc|jcs l_		; 6
       (SKIP(i+7) = false) then
     if (pos(listing[i+3], listing[i]) > 0) then
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

	Result:=false; Break;
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
       sta(i+10) then										// sta			; 10
     if (pos(listing[i+3], listing[i]) > 0) then
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

	Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       lda(i) and										// lda			; 0	opt_082	| BYTE < 0 ; >= 0
       cmp_im_0(i+1) and									// cmp #$00		; 1
       (jcs(i+2) or jcc(i+2)) and								// jcc|jcs l_		; 2
       (SKIP(i+3) = false) then
      begin
	listing[i]   := '';
	listing[i+1] := '';

	if jcs(i+2) then
	 listing[i+2] := #9'jmp ' + copy(listing[i+2], 6, 256)
	else
	 listing[i+2] := '';

	Result:=false; Break;
      end;


    if (listing[i+8] = #9'.ENDL') and								// .ENDL		; 8
       (jpl(i+9) or jmi(i+9)) and								// jpl|jmi		; 9
       (SKIP(i+10) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	shortint < #$xx		JPL
       lda_a(i+1) and										// lda E		; 1	shortint >= #$xx	JMI
       sub_im(i+2) and										// sub #		; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7

      begin
        p := shortint(GetBYTE(i+2));

	if jmi(i+9) then begin
	 listing[i] := listing[i+1];
	 listing[i+1] := listing[i+2];
	 listing[i+2] := #9'svc';
	 listing[i+3] := #9'eor #$80';
	 listing[i+4] := #9'jmi ' + copy(listing[i+9], 6, 256);
	end else
	if p <> Low(shortint) then begin
	 listing[i] := listing[i+1];
	 listing[i+1] := listing[i+2];
	 listing[i+2] := #9'svc';
	 listing[i+3] := #9'eor #$80';
	 listing[i+4] := #9'jpl ' + copy(listing[i+9], 6, 256);
	end else begin
	 listing[i] := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := #9'jmp ' + copy(listing[i+9], 6, 256);
	end;

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
      end;


    if (listing[i+8] = #9'.ENDL') and								// .ENDL		; 8
       (jpl(i+9) or jmi(i+9)) and								// jpl|jmi		; 9
       (SKIP(i+11) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	shortint < shortint	JPL
       lda_a(i+1) and										// lda E		; 1	shortint >= shortint	JMI
       sub(i+2) and (sub_im(i+2) = false) and							// sub 			; 2
       (listing[i+3] = #9'beq L5') and								// beq L5		; 3
       (listing[i+4] = #9'bvc L5') and								// bvc L5		; 4
       (listing[i+5] = #9'eor #$FF') and							// eor #$FF		; 5
       (listing[i+6] = #9'ora #$01') and							// ora #$01		; 6
       (listing[i+7] = 'L5') then								//L5			; 7

      begin
	listing[i] := listing[i+1];
	listing[i+1] := listing[i+2];

	if jpl(i+9) then begin
	 listing[i+2] := #9'svc';
	 listing[i+3] := #9'eor #$80';
	 listing[i+4] := #9'jpl ' + copy(listing[i+9], 6, 256);
	end else begin
	 listing[i+2] := #9'svc';
	 listing[i+3] := #9'eor #$80';
	 listing[i+4] := #9'jmi ' + copy(listing[i+9], 6, 256);
	end;

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
      end;


    if (listing[i+8] = #9'.ENDL') and								// .ENDL		; 8
       ((listing[i+9] = #9'bpl @+') or (listing[i+9] = #9'bmi @+')) and				// bpl @+|bmi @+	; 9
       dey(i+10) and										// dey			; 10
       lab_a(i+11) and										//@			; 11
       ((sty(i+12) and (lda(i+13) = false)) or (tya(i+12) and (SKIP(i+13) = false))) and	// sty|tya		; 12

       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	BOOL := SHORTINT >= SHORTINT	BPL
       lda_a(i+1) and										// lda E		; 1	BOOL := SHORTINT < SHORTINT	BMI
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

	Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jne(i+5) then										// sta			; 5
      begin
       listing[i+1] := #9'jpl ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       (jpl(i+16) or jmi(i+16)) and								// jpl|jmi		; 16
       (SKIP(i+17) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	SMALLINT < SMALLINT	JPL
       lda_a(i+1) and										// lda E+1		; 1	SMALLINT >= SMALLINT	JMI
       sub(i+2) and (sub_im(i+2) = false) and							// sub 			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and										// lda E		; 4
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

	Result:=false; Break;
      end;


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       jpl(i+16) and										// jpl			; 16
       (SKIP(i+17) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	SMALLINT < BYTE		JPL
       lda_a(i+1) and										// lda E+1		; 1	SMALLINT >= BYTE	JMI
       sub_im_0(i+2) and									// sub #$00		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda_a(i+4) and (lda_im(i+4) = false) and							// lda E		; 4
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
	listing[i+13] := #9'sbc #$00';
	listing[i+14] := #9'svc';
	listing[i+15] := #9'eor #$80';
	listing[i+16] := #9'jpl ' + copy(listing[i+16], 6, 256);

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


    if ldy_1(i) and 										// ldy #1		; 0	BOOL := smallint < 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda			; 1
       (listing[i+2] = #9'bmi @+') and								// bmi @+		; 2
       dey(i+3) and										// dey			; 3
       lab_a(i+4) and										//@			; 4
       tya(i+5) and										// tya			; 5
       sta(i+6) then										// sta			; 6
     begin
	listing[i]   := '';

	listing[i+2] := #9'cmp #$80';
	listing[i+3] := #9'lda #$00';
	listing[i+4] := #9'rol @';
	listing[i+5] := '';

	Result:=false; Break;
     end;


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       (bpl(i+16) or bmi(i+16)) and								// bpl|bmi		; 16
       dey(i+17) and										// dey			; 17
       lab_a(i+18) and										//@			; 18
       ((sty(i+19) and (lda(i+20) = false)) or (tya(i+19) and (SKIP(i+20) = false))) and	// sty|tya		; 19

       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	BOOL := SMALLINT < 0	BMI
       lda(i+1) and										// lda E+1		; 1	BOOL := SMALLINT >= 0	BPL
       sub_im_0(i+2) and									// sub #$00		; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda(i+4) and										// lda E		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
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

	listing[i] := listing[i+1];
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

	Result:=false; Break;
      end;


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       (bpl(i+16) or bmi(i+16)) and								// bpl|bmi		; 16
       dey(i+17) and										// dey			; 17
       lab_a(i+18) and										//@			; 18
       ((sty(i+19) and (lda(i+20) = false)) or (tya(i+19) and (SKIP(i+20) = false))) and	// sty|tya		; 19

       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	BOOL := SMALLINT < SMALLINT	BMI
       lda(i+1) and										// lda E+1		; 1	BOOL := SMALLINT >= SMALLINT	BPL
       sub(i+2) and (sub_im(i+2) = false) and							// sub 			; 2
       (listing[i+3] = #9'bne L4') and								// bne L4		; 3
       lda(i+4) and										// lda E		; 4
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

	Result:=false; Break;
      end;


    if lda(i) and										// lda E		; 0	BOOL := SMALLINT < 0	BMI
       cmp_im_0(i+1) and									// cmp #$00		; 1	BOOL := SMALLINT >= 0	BPL
       lda(i+2) and										// lda E+1		; 2
       sbc_im_0(i+3) and									// sbc #$00		; 3
       (listing[i+4] = #9'svc') and								// svc			; 4
       (listing[i+5] = #9'eor #$80') and							// eor #$80		; 5
       (bpl(i+6) or bmi(i+6)) and								// bpl|bmi		; 6
       dey(i+7) and										// dey			; 7
       lab_a(i+8) and										//@			; 8
       (sty(i+9) or tya(i+9)) then								// sty|tya		; 9
      begin
	listing[i] := '';
	listing[i+1] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       jpl(i+16) and										// jpl			; 16
       (SKIP(i+17) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	SMALLINT < #$XXYY
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

	if p = 0 then begin									//				SMALLINT < 0
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
	 listing[i+16] := #9'jpl ' + copy(listing[i+16], 6, 256);
	end else begin
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := '';
	 listing[i+16] := #9'jmp ' + copy(listing[i+16], 6, 256);
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


    if (listing[i+15] = #9'.ENDL') and								// .ENDL		; 15
       jmi(i+16) and										// jmi			; 16
       (SKIP(i+17) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	SMALLINT >= #$XXYY
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

	if p = 0 then begin									//				SMALLINT >= 0
	 listing[i+10] := listing[i+1];
	 listing[i+11] := listing[i+16];
	 listing[i+12] := '';
	 listing[i+13] := '';
	 listing[i+14] := '';
	 listing[i+15] := '';
	 listing[i+16] := '';
	end else begin
	 listing[i+10] := listing[i+4];
	 listing[i+11] := listing[i+5];
	 listing[i+12] := listing[i+1];
	 listing[i+13] := #9'sbc ' + copy(listing[i+2], 6, 256);
	 listing[i+14] := #9'svc';
	 listing[i+15] := #9'eor #$80';
	 listing[i+16] := #9'jmi ' + copy(listing[i+16], 6, 256);
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
       jpl(i+23) and										// jpl			; 23
       (SKIP(i+24) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	INTEGER < 0
       lda(i+1) and										// lda E+3		; 1
       (sub_im_0(i+2) or (listing[i+2] = #9'sub #$80')) and					// sub #$00|$80		; 2
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

	if listing[i+2] = #9'sub #$80' then begin			// < LOW(INTEGER)
	 listing[i] := #9'jmp ' + copy(listing[i+23], 6, 256);
	 listing[i+1] := '';
	end else begin							// < 0
	 listing[i]   := listing[i+1];
	 listing[i+1] := listing[i+23];
	end;

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
	listing[i+23] := '';

	Result:=false; Break;
      end;


    if (listing[i+22] = #9'.ENDL') and								// .ENDL		; 22
       jmi(i+23) and										// jmi			; 23
       (SKIP(i+24) = false) and
       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	INTEGER >= 0
       lda(i+1) and										// lda E+3		; 1
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

	listing[i]   := listing[i+1];
	listing[i+1] := listing[i+23];
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
	listing[i+23] := '';

	Result:=false; Break;
      end;


    if (listing[i+22] = #9'.ENDL') and								// .ENDL		; 22
       (bpl(i+23) or bmi(i+23)) and								// bmi @+|bpl @+	; 23
       dey(i+24) and										// dey			; 24
       lab_a(i+25) and										//@			; 25
       ((sty(i+26) and (lda(i+27) = false)) or (tya(i+26) and (SKIP(i+27) = false))) and	// sty|tya		; 26

       (listing[i] = #9'.LOCAL') and								// .LOCAL		; 0	BOOL := INTEGER < 0
       lda(i+1) and										// lda E+3		; 1	BOOL := INTEGER >= 0
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

	Result:=false; Break;
      end;