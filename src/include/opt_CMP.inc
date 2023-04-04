
function opt_CMP(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===		     		      CMP.
// -----------------------------------------------------------------------------
//
// prevent such an arrangement if the preceding LDY|TAY command is missing
//
// ~cmp adr.label
//

    if lda(i) and (iy(i) = false) and								// lda				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2; 3
       lda(i+4) and 										// lda				; 4
       and_ora_eor(i+5) and									// and|ora|eor			; 5
       bne(i+6) and										// bne				; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH*2; 7
       cmp(i+8) and										// cmp				; 8
       bne(i+9) and										// bne @+			; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH	; 10
       bne(i+11) and										// bne @+			; 11
       lda_stack(i+12) then									// lda :STACKORIGIN		; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
       listing[i+7] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i+10] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i+12] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH	; 2
       lda(i+3) and 										// lda X+2			; 3
       and_ora_eor(i+4) and									// and|ora|eor			; 4
       bne(i+5) and										// bne				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH	; 6
       bne(i+7) and										// bne @+			; 7
       lda_stack(i+8) then									// lda :STACKORIGIN		; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
       listing[i+6] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i+8] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH	; 2
       lda(i+3) and 										// lda X+2			; 3
       and_ora_eor(i+4) and									// and|ora|eor			; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2; 5
       lda(i+6) and 										// lda X+3			; 6
       and_ora_eor(i+7) and									// and|ora|eor			; 7
       bne(i+8) and										// bne				; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH*2; 9
       cmp(i+10) and										// cmp				; 10
       bne(i+11) and										// bne @+			; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH	; 12
       bne(i+13) and										// bne @+			; 13
       lda_stack(i+14) then									// lda :STACKORIGIN		; 14
     if (copy(listing[i+1], 6, 256) = copy(listing[i+14], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) then
      begin
       listing[i+12] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i+14] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda				; 0
       add_sub(i+1) and										// add|sub			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+X		; 2
       lda(i+3) and (iy(i) = false) and								// lda				; 3
       adc_sbc(i+4) and 									// adc|sbc			; 4
       sta_stack(i+5) and									// lda :STACKORIGIN+STACKWIDTH+X; 5
       lda(i+6) and (iy(i) = false) and								// lda				; 6
       add_sub(i+7) and										// add|sub			; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+Y		; 8
       lda(i+9) and (iy(i) = false) and								// lda				; 9
       adc_sbc(i+10) and									// adc|sbc			; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH+Y; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH+X; 12
       cmp_stack(i+13) then									// cmp :STACKORIGIN+STACKWIDTH+Y; 13
     if (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+11], 6, 256) = copy(listing[i+13], 6, 256)) then
      begin
       listing_tmp[0] := listing[i+6];
       listing_tmp[1] := listing[i+7];
       listing_tmp[2] := listing[i+8];
       listing_tmp[3] := listing[i+9];
       listing_tmp[4] := listing[i+10];
       listing_tmp[5] := listing[i+11];

       listing[i+6] := listing[i];
       listing[i+7] := listing[i+1];
       listing[i+8] := listing[i+2];
       listing[i+9] := listing[i+3];
       listing[i+10] := listing[i+4];
       listing[i+11] := listing[i+5];

       listing[i] := listing_tmp[0];
       listing[i+1] := listing_tmp[1];
       listing[i+2] := listing_tmp[2];
       listing[i+3] := listing_tmp[3];
       listing[i+4] := listing_tmp[4];
       listing[i+5] := listing_tmp[5];

       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9	; 1
       lda(i+2) and 										// lda			; 2
       and_ora_eor(i+3) and									// and|ora|eor		; 3
       bne(i+4) and										// bne			; 4
       lda_stack(i+5) then									// lda :STACKORIGIN+9	; 5
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
       listing[i+5] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9	; 1
       lda(i+2) and 										// lda			; 2
       and_ora_eor(i+3) and									// and|ora|eor		; 3
       cmp(i+4) and (cmp_stack(i+4) = false) and						// cmp			; 4
       bne(i+5) and										// bne			; 5
       lda_stack(i+6) then									// lda :STACKORIGIN+9	; 6
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then
      begin
       listing[i+6] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if bne(i) and										// bne @+		; 0
       lda_im_0(i+1) and									// lda #$00		; 1
       lab_a(i+2) and 										//@			; 2
       jne(i+3) then										// jne l_		; 3
      begin
       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+9	; 0
       lda(i+1) and										// lda			; 1		~lda adr.
       cmp_stack(i+2) and	 								// cmp :STACKORIGIN+9	; 2
       (jeq(i+3) or jne(i+3)) then								// jeq|jne		; 3
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
      begin
       listing[i+1] := #9'cmp ' + copy(listing[i+1], 6, 256);

       listing[i]   := '';
       listing[i+2] := '';
       exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+9	; 0
       lda(i+1) and 										// lda			; 1		~lda adr.
       sub_stack(i+2) and	 								// sub :STACKORIGIN+9	; 2
       cmp(i+3) and (cmp_stack(i+3) = false) and						// cmp			; 3
       SKIP(i+4) then										// SKIP			; 4
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
      begin
       listing[i+2] := #9'adc ' + copy(listing[i+1], 6, 256);

       listing[i]   := #9'eor #$ff';
       listing[i+1] := #9'sec';

       exit(false);
      end;


    if (cmp(i) or lda(i) or and_ora_eor(i)) and							// cmp|lda|and|ora|eor	; 0
       (beq(i+1) or bne(i+1) or bcc(i+1)) and							// beq|bne|bcc @+	; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and	 									//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq			; 5
     begin

       if listing[i+1] = #9'bcc @+' then
        listing[i+1] := #9'jcs ' + copy(listing[i+5], 6, 256)
       else
       if listing[i+1] = #9'bne @+' then
        listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256)
       else
        listing[i+1] := #9'jne ' + copy(listing[i+5], 6, 256);

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if ldy_1(i) and 										// ldy #1		; 0
       lda(i+1) and										// lda			; 1
       seq(i+2) and										// seq			; 2
       dey(i+3) and										// dey			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then			 							// jeq l_		; 5
      begin
       listing[i] := '';

       listing[i+3] := #9'jmp ' + copy(listing[i+5], 6, 256);
       listing[i+4] := '';
       listing[i+5] := '';

       exit(false);
      end;


    if ldy_1(i) and										// ldy #1		; 0
       lda_a(i+1) and iy(i+1) and	 							// lda ,y		; 1
       sta_stack(i+2)  and									// sta :STACKORIGIN	; 2
       lda_a(i+3) and (iy(i+3) = false) and							// lda 			; 3
       cmp_stack(i+4) then			 						// cmp :STACKORIGIN	; 4
     if copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256) then
      begin
       listing[i+4] := #9'cmp ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
      end;


    if lda_a(i) and										// lda			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN	; 1
       ldy_1(i+2) and										// ldy #1		; 2
       lda_stack(i+3) and									// lda :STACKORIGIN	; 3
       (cmp(i+4) or AND_ORA_EOR(i+4)) and (cmp_im_0(i+4) = false) then				// cmp|and|ora|eor	; 4
     if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then
      begin
       listing[i+1] := '';
       listing[i+3] := '';
       exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN	; 0
       lda_a(i+1) and (iy(i+1) = false) and							// lda			; 1
       ldy_1(i+2) and										// ldy #1		; 2
       ora_stack(i+3) then									// ora :STACKORIGIN	; 3
     if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then
      begin
       listing[i+3] := #9'ora ' + copy(listing[i+1], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda					; 0
       ldy_1(i+1) and										// ldy #1				; 1
       (listing[i+2] = #9'ora #$00') then							// ora #$00				; 2
     begin
       listing[i+2] := listing[i];

       listing[i] := '';
       exit(false);
      end;


    if lda(i) and										// lda A				; 0
       ldy_1(i+1) and										// ldy #1				; 1
       cmp(i+2) and										// cmp A				; 2
       bne(i+3) then										// bne					; 3
    if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       exit(false);
      end;


    if lda(i) and										// lda					; 0
       and_im(i+1) and (listing[i+1] = listing[i+4]) and					// and #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda					; 3
//       and_im(i+4) and									// and #				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+10			; 5
       ldy_1(i+6) and										// ldy #1				; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+9			; 7
       cmp_stack(i+8) and									// cmp :STACKORIGIN+10			; 8
       (beq(i+9) or bne(i+9)) and								// beq|bne				; 9
       dey(i+10) then										// dey					; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+8], 6, 256)) then
     begin
	listing[i+5] := #9'ldy #1';
	listing[i+6] := listing[i];
	listing[i+7] := #9'eor ' + copy(listing[i+3], 6, 256);
	listing[i+8] := listing[i+4];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
     end;


    if ldy_im(i) and										// ldy #				; 0
       lda(i+1) and										// lda					; 1
       and_im(i+2) and (listing[i+2] = listing[i+6]) and					// and #				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+9			; 3
       ldy_im(i+4) and										// ldy #				; 4
       lda(i+5) and										// lda					; 5
//       and_im(i+6) and									// and #				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+10			; 7
       ldy_1(i+8) and										// ldy #1				; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+9			; 9
       cmp_stack(i+10) and									// cmp :STACKORIGIN+10			; 10
       (beq(i+11) or bne(i+11)) and								// beq|bne				; 11
       dey(i+12) then										// dey					; 12
     if (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+10], 6, 256)) then
     begin
	listing[i+9]  := #9'ldy #1';
	listing[i+10] := listing[i+6];

	listing[i+2] := listing[i+4];
	listing[i+3] := #9'eor ' + copy(listing[i+5], 6,256);
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
     end;


    if mwy_bp2(i) and (listing[i] = listing[i+5]) and						// mwy					; 0
       ldy_im(i+1) and										// ldy #				; 1
       lda_bp2_y(i+2) and									// lda (:bp2),y				; 2
       and_im(i+3) and (listing[i+3] = listing[i+8]) and					// and #				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+9			; 4
//       mwy_bp2(i+5) and									// mwy					; 5
       ldy_im(i+6) and										// ldy #				; 6
       lda_bp2_y(i+7) and									// lda (:bp2),y				; 7
       and_im(i+8) and										// and #				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+10			; 9
       ldy_1(i+10) and										// ldy #1				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+9			; 11
       cmp_stack(i+12) and									// cmp :STACKORIGIN+10			; 12
       (beq(i+13) or bne(i+13)) and								// beq|bne				; 13
       dey(i+14) then										// dey					; 14
     if (copy(listing[i+4], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+9], 6, 256) = copy(listing[i+12], 6, 256)) then
     begin
	listing[i+11] := #9'ldy #1';
	listing[i+12] := listing[i+8];

	listing[i+3] := listing[i+6];
	listing[i+4] := #9'eor (:bp2),y';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       cmp(i+1) and										// cmp					; 1
       bne(i+2) and										// bne @+				; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       sty(i+5) and										// sty :STACKORIGIN+9			; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       sub(i+7) then										// sub :STACKORIGIN+9			; 7
     if copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256) then begin
       listing[i]   := #9'ldy #$00';

       listing[i+5] := #9'tya';
       listing[i+6] := '';
       listing[i+7] := '';

       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*3	; 3
       ldy_1(i+4) and										// ldy #1				; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+STACKWIDTH*3	; 5
       cmp(i+6) and										// cmp					; 6
												// bne|beq				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH*2	; 8
       cmp(i+9) and										// cmp					; 9
												// bne|beq				; 10
       lda_stack(i+11) then									// lda :STACKORIGIN+STACKWIDTH		; 11
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


    if lda(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*2	; 3
       lda_a(i+4) and										// lda					; 4
       and_ora_eor(i+5) and									// and|ora|eor				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*3	; 6
       ldy_1(i+7) and										// ldy #1				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH*3	; 8
       cmp(i+9) and										// cmp					; 9
												//					; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH*2	; 11
       cmp(i+12) and										// cmp					; 12
												//					; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       cmp(i+15) and										// cmp					; 15
												//					; 16
       lda_stack(i+17) then									// lda :STACKORIGIN			; 17
     if (copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+17], 6, 256)) then
     begin
	listing[i+11] := listing[i];
	listing[i+14] := listing[i];
	listing[i+17] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if lda(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*3	; 2
       ldy_1(i+3) and										// ldy #1				; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH*3	; 4
       cmp(i+5) and										// cmp					; 5
												// bne|beq				; 6
       lda_stack(i+7) then									// lda :STACKORIGIN+STACKWIDTH*2	; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+4]  := listing[i];
	listing[i+7]  := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if lda(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_1(i+2) and										// ldy #1				; 2
       lda(i+3) and										// lda 					; 3
       cmp_stack(i+4) and									// cmp :STACKORIGIN			; 4
       beq(i+5) and										// beq @+				; 5
       dey(i+6) then										// dey					; 6
     if copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256) then begin

       listing[i+3] := #9'cmp ' + copy(listing[i+3], 6, 256);

       listing[i+1] := '';
       listing[i+4] := '';
       exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+9			; 0
       ldy_1(i+1) and										// ldy #1				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+9			; 2
       beq(i+3) and										// beq @+				; 3
       dey(i+4) then										// dey					; 4
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin

       listing[i] := '';
       listing[i+2] := #9'cmp #$00';

       exit(false);
      end;


// -----------------------------------------------------------------------------


    if lda(i) and (iy(i) = false) and 								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and (iy(i+2) = false) and							// lda ~,y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and (iy(i+4) = false) and							// lda ~,y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda(i+6) and (iy(i+6) = false) and							// lda ~,y				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       ldy_1(i+8) and										// ldy #1				; 8
       lda(i+9) and										// lda					; 9
       cmp_stack(i+10) and									// cmp :STACKORIGIN+STACKWIDTH*3+10	; 10
												// bne|beq				; 11
       lda(i+12) and										// lda					; 12
       cmp_stack(i+13) and									// cmp :STACKORIGIN+STACKWIDTH*2+10	; 13
												// bne|beq				; 14
       lda(i+15) and										// lda					; 15
       cmp_stack(i+16) and									// cmp :STACKORIGIN+STACKWIDTH+10	; 16
												// bne|beq				; 17
       lda(i+18) and										// lda					; 18
       cmp_stack(i+19) then									// cmp :STACKORIGIN+10			; 19
     if (copy(listing[i+1], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+10], 6, 256)) then
     begin
	listing[i+10] := #9'cmp ' + copy(listing[i+6], 6, 256);
	listing[i+13] := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+16] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+19] := #9'cmp ' + copy(listing[i], 6, 256);

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


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and (iy(i+2) = false) and							// lda ~,y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and (iy(i+4) = false) and							// lda ~,y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 6
       ldy_1(i+7) and										// ldy #1				; 7
       lda(i+8) and										// lda					; 8
       cmp_stack(i+9) and									// cmp :STACKORIGIN+STACKWIDTH*3+10	; 9
												// bne|beq				; 10
       lda(i+11) and										// lda					; 11
       cmp_stack(i+12) and									// cmp :STACKORIGIN+STACKWIDTH*2+10	; 12
												// bne|beq				; 13
       lda(i+14) and										// lda					; 14
       cmp_stack(i+15) and									// cmp :STACKORIGIN+STACKWIDTH+10	; 15
												// bne|beq				; 16
       lda(i+17) and										// lda					; 17
       cmp_stack(i+18) then									// cmp :STACKORIGIN+10			; 18
     if (copy(listing[i+1], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
	listing[i+9]  := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+12] := #9'cmp ' + copy(listing[i+4], 6, 256);
	listing[i+15] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+18] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
     end;


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and (iy(i+2) = false) and							// lda ~,y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+10	; 3
       ldy_1(i+4) and										// ldy #1				; 4
       lda(i+5) and										// lda					; 5
       cmp_stack(i+6) and									// cmp :STACKORIGIN+STACKWIDTH+10	; 6
												// bne|beq				; 7
       lda(i+8) and										// lda					; 8
       cmp_stack(i+9) then									// cmp :STACKORIGIN+10			; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	listing[i+6] := #9'cmp ' + copy(listing[i+2], 6, 256);
	listing[i+9] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_1(i+2) and										// ldy #1				; 2
       lda(i+3) and										// lda 					; 3
       cmp_stack(i+4) then									// cmp :STACKORIGIN			; 4
     if copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256) then begin

       listing[i+4] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       ldy(i+2) and										// ldy					; 2
       lda_a(i+3) and iy(i+3) and								// lda ~,y				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+10			; 4
       ldy_1(i+5) and										// ldy #1				; 5
       lda(i+6) and										// lda :STACKORIGIN+9			; 6
       cmp_stack(i+7) then									// cmp :STACKORIGIN+10			; 7
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then begin

       listing[i+6] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy(i+2) and										// ldy					; 2
       lda_a(i+3) and iy(i+3) and								// lda ,y				; 3
       ldy_1(i+4) and										// ldy #1				; 4
       cmp_stack(i+5) then									// cmp :STACKORIGIN			; 5
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then begin

       listing[i+5] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy(i+2) and										// ldy					; 2
       iny(i+3) and										// iny					; 3
       lda_a(i+4) and iy(i+4) and								// lda ,y				; 4
       ldy_1(i+5) and										// ldy #1				; 5
       cmp_stack(i+6) then									// cmp :STACKORIGIN			; 6
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then begin

       listing[i+6] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


    if lda(i) and (iy(i) = false) and								// lda ~,y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2
       add_sub(i+3) and										// add|sub				; 3
       tay(i+4) and										// tay					; 4
       lda_a(i+5) and iy(i+5) and								// lda ,y				; 5
       ldy_1(i+6) and										// ldy #1				; 6
       cmp_stack(i+7) then									// cmp :STACKORIGIN			; 7
     if copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256) then begin

       listing[i+7] := #9'cmp ' + copy(listing[i], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
      end;


// -----------------------------------------------------------------------------


    if lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and										// lda					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_a(i+6) and										// lda					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH*3 	; 8
       cmp(i+9) and										// cmp 					; 9
												//					; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH*2	; 11
       cmp(i+12) and										// cmp 					; 12
												//					; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       cmp(i+15) and										// cmp 					; 15
												//					; 16
       lda_stack(i+17) then									// lda :STACKORIGIN			; 17
     if (copy(listing[i+1], 6, 256) = copy(listing[i+17], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+8] := listing[i+6];
	listing[i+11] := listing[i+4];
	listing[i+14] := listing[i+2];
	listing[i+17] := listing[i];

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


    if lda(i) and										// lda					; 0	~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2	~lda adr.
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and										// lda					; 4	~lda adr.
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda(i+6) and										// lda					; 6	~lda adr.
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lda_a(i+8) and										// lda 					; 8
       cmp_stack(i+9) and									// cmp :STACKORIGIN+STACKWIDTH*3 	; 9
												//					; 10
       lda_a(i+11) and										// lda 					; 11
       cmp_stack(i+12) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 12
												//					; 13
       lda_a(i+14) and										// lda 					; 14
       cmp_stack(i+15) and									// cmp :STACKORIGIN+STACKWIDTH		; 15
												//					; 16
       lda_a(i+17) and										// lda					; 17
       cmp_stack(i+18) then									// cmp :STACKORIGIN			; 18
     if (copy(listing[i+1], 6, 256) = copy(listing[i+18], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
	listing[i+9]  := #9'cmp ' + copy(listing[i+6], 6, 256);

	listing[i+12] := #9'cmp ' + copy(listing[i+4], 6, 256);

	listing[i+15] := #9'cmp ' + copy(listing[i+2], 6, 256);

	listing[i+18] := #9'cmp ' + copy(listing[i], 6, 256);

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


    if lda(i) and										// lda					; 0	~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2	~lda adr.
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and										// lda 					; 4
       cmp_stack(i+5) and									// cmp :STACKORIGIN+STACKWIDTH		; 5
       (beq(i+6) or bne(i+6)) and								// beq|bne @+				; 6
       lda_a(i+7) and										// lda 					; 7
       cmp_stack(i+8) then									// cmp :STACKORIGIN			; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+5] := #9'cmp ' + copy(listing[i+2], 6, 256);

	listing[i+8] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda(i) and (lda_stack(i) = false) and							// lda					; 0	~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and (lda_stack(i+2) = false) and						// lda					; 2	~lda.adr
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda 					; 4
       cmp_stack(i+5) and									// cmp :STACKORIGIN			; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda 					; 6
       sbc_stack(i+7) then									// sbc :STACKORIGIN+STACKWIDTH		; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+5] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i+7] := #9'sbc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------


    if lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and										// lda					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_a(i+6) and										// lda					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH*3	; 8
       bne(i+9) and										// bne @+				; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH*2	; 10
       bne(i+11) and										// bne @+				; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH		; 12
       bne(i+13) and										// bne @+				; 13
       lda_stack(i+14) then									// lda :STACKORIGIN			; 14
     if (copy(listing[i+1], 6, 256) = copy(listing[i+14], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+8] := listing[i+6];

	listing[i+10] := listing[i+4];

	listing[i+12] := listing[i+2];

	listing[i+14] := listing[i];

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


    if lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH		; 4
       bne(i+5) and										// bne @+				; 5
       lda_stack(i+6) then									// lda :STACKORIGIN			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+4] := listing[i+2];

	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       cmp(i+3) and										// cmp					; 3
       (beq(i+4) or bne(i+4)) and								// beq|bne @+				; 4
       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+5] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if lda(i) and										// lda					; 0	~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       cmp_stack(i+3) then									// cmp :STACKORIGIN			; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
      begin
	listing[i+3] := #9'cmp ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda 					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACVKWIDTH+9	; 5
       lda(i+6) and										// lda 					; 6
       cmp_stack(i+7) and									// cmp :STACKORIGIN+9			; 7
       SKIP(i+8) then										// SKIP					; 8
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if lda(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda(i+2) and										// lda 					; 2
       add_sub(i+3) and										// add|sub				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+10			; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+9			; 5
       cmp_stack(i+6) then									// cmp :STACKORIGIN+10			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+5] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda 					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACVKWIDTH+9	; 5
       lda(i+6) and										// lda 					; 6
       cmp_stack(i+7) and									// cmp :STACKORIGIN+9			; 7
       seq(i+8) and										// seq					; 8
       ((listing[i+9] = #9'bpl @+') or (listing[i+9] = #9'bcs @+')) and				// bpl|bcs @+				; 9
       (pos('jmp l_', listing[i+10]) > 0) then							// jmp l_				; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------


    if bne(i+20) and										// bne @+				; 20

       add_sub(i) and										// add|sub				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_im_0(i+5) and									// lda #$00				; 5
       adc_sbc_im_0(i+6) and									// adc|sbc #$00				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*2	; 7
       lda_im_0(i+8) and									// lda #$00				; 8
       adc_sbc_im_0(i+9) and									// adc|sbc #$00				; 9
       sta_stack(i+10) and									// sta :STACKORIGIN+STACKWIDTH*3	; 10
       ldy_1(i+11) and 										// ldy #1				; 11
       lda_im_0(i+12) and									// lda #$00				; 12
       cmp_stack(i+13) and									// cmp :STACKORIGIN+STACKWIDTH*3	; 13
       bne(i+14) and										// bne @+				; 14
       lda_im_0(i+15) and									// lda #$00				; 15
       cmp_stack(i+16) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 16
       bne(i+17) and										// bne @+				; 17
       lda_im_0(i+18) and									// lda #$00				; 18
       cmp_stack(i+19) and									// cmp :STACKORIGIN+STACKWIDTH		; 19

       lda_a(i+21) and										// lda					; 21
       cmp_stack(i+22) then									// cmp :STACKORIGIN			; 22

     if (copy(listing[i+1], 6, 256) = copy(listing[i+22], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+19], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+16], 6, 256)) and
        (copy(listing[i+10], 6, 256) = copy(listing[i+13], 6, 256)) then
      begin
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';
       listing[i+10]:= '';

       listing[i+12] := '';
       listing[i+13] := '';
       listing[i+14] := '';
       listing[i+15] := '';
       listing[i+16] := '';
       listing[i+17] := '';

       exit(false);
      end;


    if bne(i+18) and										// bne @+				; 18

       lda_a(i) and										// lda 					; 0
       add_sub(i+1) and										// add|sub 				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       adc_sbc_im_0(i+7) and									// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_im_0(i+9) and									// lda #$00				; 9
       adc_sbc_im_0(i+10) and									// adc|sbc #$00				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       ldy_1(i+12) and										// ldy #1				; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 13
       bne(i+14) and										// bne @+				; 14
       lda_stack(i+15) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 15
       bne(i+16) and										// bne @+				; 16
       lda_stack(i+17) and									// lda :STACKORIGIN+STACKWIDTH+9	; 17

       lda_a(i+19) and										// lda					; 19
       cmp_stack(i+20) then									// cmp :STACKORIGIN+9			; 20
     if (copy(listing[i+2], 6, 256) = copy(listing[i+20], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+13], 6, 256)) then
     begin
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      listing[i+13] := '';
      listing[i+14] := '';
      listing[i+15] := '';
      listing[i+16] := '';

      exit(false);
     end;


// -----------------------------------------------------------------------------


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH+10	; 0
       lda(i+1) and										// lda 					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 3
       ldy_im_0(i+4) and									// ldy #$00				; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+STACKWIDTH+10	; 5
       spl(i+6) and dey(i+7) and								// spl					; 6
       sta_stack(i+8) and									// dey					; 7
       sty_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH+10	; 8
       sty_stack(i+10) then									// sty :STACKORIGIN+STACKWIDTH*2+10	; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and				// sty :STACKORIGIN+STACKWIDTH*3+10	; 10
	(copy(listing[i+5], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';

	exit(false);
       end;


    if ldy_im_0(i) and										// ldy #$00				; 0
       lda(i+1) and										// lda 					; 1
       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey 					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH		; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*2	; 6
       sty_stack(i+7) and									// sty :STACKORIGIN+STACKWIDTH*3	; 7
       lda_stack(i+8) and									// lda :STACKORIGIN			; 8
       add_sub(i+9) and										// add|sub 				; 9
       sta(i+10) and										// sta 					; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH		; 11
       adc_sbc(i+12) and									// adc|sbc				; 12
       sta(i+13) and										// sta					; 13
												//					; 14
       (adc_sbc(i+15) = false) then								//~adc|sbc				; 15
     if (copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	listing[i+11] := #9'tya';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if lab_a(i+20) and										//@					; 20

       (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_adr(i+5) and										// lda adr.				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*2	; 6
       lda_adr(i+7) and										// lda adr.				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3	; 8
       lda_a(i+9) and										// lda					; 9
       cmp_stack(i+10) and									// cmp :STACKORIGIN+STACKWIDTH*3	; 10
       bne(i+11) and										// bne					; 11
       lda_a(i+12) and										// lda					; 12
       cmp_stack(i+13) and									// cmp :STACKORIGIN+STACKWIDTH*2	; 13
       bne(i+14) and										// bne					; 14
       lda_a(i+15) and										// lda					; 15
       cmp_stack(i+16) and									// cmp :STACKORIGIN+STACKWIDTH		; 16
       bne(i+17) and										// bne					; 17
       lda_a(i+18) and										// lda					; 18
       cmp_stack(i+19) then									// cmp :STACKORIGIN			; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+16], 6, 256)) and
        (copy(listing[i+6], 6, 256) = copy(listing[i+13], 6, 256)) and
        (copy(listing[i+8], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+10] := #9'cmp ' + copy(listing[i+7], 6, 256);

	listing[i+13] := #9'cmp ' + copy(listing[i+5], 6, 256);

	listing[i+16] := #9'cmp ' + copy(listing[i+3], 6, 256);

	listing[i+19] := #9'cmp ' + copy(listing[i+1], 6, 256);

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


    if lab_a(i+16) and										//@					; 16

       (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_a(i+5) and										// lda					; 5
       cmp(i+6) and										// cmp					; 6
       bne(i+7) and										// bne					; 7
       lda_a(i+8) and										// lda					; 8
       cmp(i+9) and										// cmp					; 9
       bne(i+10) and										// bne					; 10
       lda_a(i+11) and										// lda					; 11
       cmp_stack(i+12) and									// cmp :STACKORIGIN+STACKWIDTH		; 12
       bne(i+13) and										// bne					; 13
       lda_a(i+14) and										// lda					; 14
       cmp_stack(i+15) then									// cmp :STACKORIGIN			; 15
     if (copy(listing[i+2], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+12], 6, 256)) then
      begin
	listing[i+12] := #9'cmp ' + copy(listing[i+3], 6, 256);

	listing[i+15] := #9'cmp ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if lab_a(i+14) and										//@					; 14

       (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       cmp(i+4) and										// cmp					; 4
       bne(i+5) and										// bne					; 5
       lda_a(i+6) and										// lda					; 6
       cmp(i+7) and										// cmp					; 7
       bne(i+8) and										// bne					; 8
       lda_a(i+9) and										// lda					; 9
       cmp(i+10) and										// cmp					; 10
       bne(i+11) and										// bne					; 11
       lda_a(i+12) and										// lda					; 12
       cmp_stack(i+13) then									// cmp :STACKORIGIN			; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) then
      begin
	listing[i+13] := #9'cmp ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_a(i+5) and										// lda					; 5
       cmp_stack(i+6) and									// cmp :STACKORIGIN			; 6
       lda_a(i+7) and 										// lda					; 7
       sbc_stack(i+8) then									// sbc :STACKORIGIN+STACKWIDTH		; 8
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+6] := #9'cmp ' + copy(listing[i+1], 6, 256);

	listing[i+8] := #9'sbc ' + copy(listing[i+3], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       cmp_stack(i+4) then									// cmp :STACKORIGIN			; 4
     if (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+4] := #9'cmp ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda					; 3
       cmp(i+4) and										// cmp					; 4
       bne(i+5) and										// bne					; 5
       lda_a(i+6) and										// lda					; 6
       cmp_stack(i+7) then									// cmp :STACKORIGIN			; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+7] := #9'cmp ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
//       ldy(i+3) and										// ldy I				; 3
       lda_adr(i+4) and										// lda adr.				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+10			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+9			; 6
       cmp_stack(i+7) then									// cmp :STACKORIGIN+10			; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+6] := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+7] := #9'cmp ' + copy(listing[i+4], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;

end;		// function


{
    if bne(i+15) and										// bne @+				; 15

       lda_a(i) and										// lda 					; 0
       add_sub(i+1) and										// add|sub 				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       adc_sbc_im_0(i+7) and									// adc|sbc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_im_0(i+9) and									// lda #$00				; 9
       adc_sbc_im_0(i+10) and									// adc|sbc #$00				; 10
       bne(i+11) and										// bne @+				; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 12
       bne(i+13) and										// bne @+				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH+9	; 14

       lda_a(i+16) and										// lda					; 16
       cmp_stack(i+17) then									// cmp :STACKORIGIN+9			; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+12], 6, 256)) then
     begin
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


    if lab_a(i+16) and										//@					; 16

       lda_im_0(i) and										// lda #$00				; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       ldy_1(i+5) and										// ldy #1				; 5
       cmp_im_0(i+6) and									// cmp #$00				; 6
       bne(i+7) and										// bne @+				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 8
       cmp_im_0(i+9) and									// cmp #$00				; 9
       bne(i+10) and										// bne @+				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH+9	; 11
       cmp(i+12) and										// cmp					; 12
       bne(i+13) and										// bne @+				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+9			; 14
       cmp(i+15) then										// cmp					; 15

     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';
       listing[i+10] := '';

       exit(false);
      end;


    if lab_a(i+15) and										//@					; 15

       lda_im_0(i) and										// lda #$00				; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       cmp_im_0(i+5) and									// cmp #$00				; 5
       bne(i+6) and										// bne @+				; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 7
       cmp_im_0(i+8) and									// cmp #$00				; 8
       bne(i+9) and										// bne @+				; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH+9	; 10
       cmp(i+11) and										// cmp					; 11
       bne(i+12) and										// bne @+				; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+9			; 13
       cmp(i+14) then										// cmp					; 14

     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
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

       exit(false);
      end;


{
    if lab_a(i+8) and										//@					; 8

       lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       bne(i+5) and										// bne @+				; 5
       lda(i+6) and										// lda 					; 6
       cmp_stack(i+7) then									// cmp :STACKORIGIN+9			; 7

     if copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256) then begin

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       listing[i+8] := '';

       exit(false);
      end;


    if lab_a(i+11) and										//@					; 11

       lda(i) and										// lda					; 0
       adc_sbc(i+1) and										// adc|sbc				; 1
       sta(i+2) and										// sta A+1				; 2
       lda(i+3) and										// lda					; 3
       sub(i+4) and										// sub					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       sbc(i+7) and										// sbc A+1				; 7
       bne(i+8) and										// bne @+				; 8
       lda(i+9) and										// lda					; 9
       cmp_stack(i+10) then									// cmp :STACKORIGIN			; 10

     if (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       listing[i+11] := '';

       exit(false);
      end;


    if lab_a(i+10) and										//@					; 10

       scc(i) and										// scc					; 0
//       (pos('inc ', listing[i+1]) > 0) and							// inc T+1				; 1
       lda(i+2) and										// lda					; 2
       sub(i+3) and										// sub					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_im_0(i+5) and									// lda #$00				; 5
       sbc(i+6) and										// sbc T+1				; 6
       bne(i+7) and										// bne @+				; 7
       lda(i+8) and										// lda					; 8
       cmp_stack(i+9) then									// cmp :STACKORIGIN			; 9

     if (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
       listing[i]   := '';
       listing[i+1] := '';

       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';

       listing[i+10] := '';

       exit(false);
      end;


    if lab_a(i+13) and										//@					; 13

       lda_im_0(i) and										// lda #$00				; 0
       adc_sbc_im_0(i+1) and									// adc|sbc #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*2	; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_im_0(i+4) and									// adc|sbc #$00				; 4
       bne(i+5) and										// bne @+				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH*2	; 6
       bne(i+7) and										// bne @+				; 7
       lda_a(i+8) and										// lda 					; 8
       cmp_stack(i+9) and									// cmp :STACKORIGIN+STACKWIDTH		; 9
       bne(i+10) and										// bne @+				; 10
       lda_a(i+11) and										// lda					; 11
       cmp_stack(i+12) then									// cmp :STACKORIGIN			; 12

     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
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
}

