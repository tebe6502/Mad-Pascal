
function opt_BP(i: integer): Boolean;
var p: integer;
    tmp: string;
    yes: Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      BP.
// -----------------------------------------------------------------------------
//
//	lda (:bp2),y	-> 1 :bp2
//	sta (:TMP),y	-> 2 :TMP
//

    if listing[i] = #9'mwy :bp2 :bp2' then
     begin
      listing[i] := '';

      exit(false);
     end;


    if (pos(#9'ldy >', listing[i]) > 0) and							// ldy >				; 0
       sty_bp_1(i+1) and									// sty :bp+1				; 1
       (pos(#9'ldy <', listing[i+2]) > 0) and							// ldy <				; 2
       lda_bp_y(i+3) and									// lda (:bp),y				; 3
       (listing[i+4] = #9'add #$01') and							// add #$01				; 4
       sta_bp_y(i+5) then									// sta (:bp),y				; 5
     if (copy(listing[i], 7, 256) = copy(listing[i+2], 7, 256)) then
      begin
        listing[i] := #9'inc ' + copy(listing[i], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if (pos(#9'ldy >', listing[i]) > 0) and							// ldy >				; 0
       sty_bp_1(i+1) and									// sty :bp+1				; 1
       (pos(#9'ldy <', listing[i+2]) > 0) and							// ldy <				; 2
       lda_bp_y(i+3) and									// lda (:bp),y				; 3
       (listing[i+4] = #9'sub #$01') and							// sub #$01				; 4
       sta_bp_y(i+5) then									// sta (:bp),y				; 5
     if (copy(listing[i], 7, 256) = copy(listing[i+2], 7, 256)) then
      begin
        listing[i] := #9'dec ' + copy(listing[i], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if lda_val(i) and (iy(i) = false) and							// lda A				; 0	~:STACKORIGIN
       ldy(i+1) and										// ldy A+1				; 1
       sty_bp_1(i+2) and									// sty :bp+1				; 2
       tay(i+3) and										// tay					; 3
       lda_bp_y(i+4) then									// lda (:bp),y				; 4
      begin
	listing[i+3] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i] := '';

	exit(false);
       end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       sta_bp_1(i+1) and									// sta :bp+1				; 1
       lda_bp_y(i+2) and									// lda (:bp),y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       lda_stack(i+4) then									// lda :STACKORIGIN+STACKWIDTH		; 4
//       sta_bp_1(i+5) then									// sta :bp+1				; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i]   := '';

	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_1(i+6) and									// sta :bp+1				; 6

       sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       sta_bp_1(i+1) and									// sta :bp+1				; 1
       lda_bp_y(i+2) and									// lda (:bp),y				; 2
       (and_ora_eor(i+3) or add_sub(i+3)) and							// and|ora|eor|add|sub			; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_stack(i+5) then									// lda :STACKORIGIN+STACKWIDTH		; 5
//       sta_bp_1(i+6) then									// sta :bp+1				; 6
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i]   := '';

	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
       end;

    if sty_bp_1(i+7) and									// sty :bp+1				; 7

       ldy(i) and										// ldy T+1				; 0
       sty_bp_1(i+1) and									// sty :bp+1				; 1
       ldy(i+2) and										// ldy T				; 2
       lda(i+3) and										// lda					; 3
       and_ora_eor(i+4) and									// and|ora|eor				; 4
       (sta(i+5) or and_ora_eor(i+5)) and							// sta|and|ora|eor			; 5
       ldy(i+6) then										// ldy T+1				; 6
//       sty_bp_1(i+7) then									// sty :bp+1				; 7
     if (listing[i] = listing[i+6]) and
        (listing[i+1] = listing[i+7]) then
       begin
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if sty_bp_1(i+8) and									// sty :bp+1				; 8

       ldy(i) and										// ldy T+1				; 0
       sty_bp_1(i+1) and									// sty :bp+1				; 1
       ldy(i+2) and										// ldy T				; 2
       lda(i+3) and										// lda					; 3
       and_ora_eor(i+4) and									// and|ora|eor				; 4
       and_ora_eor(i+5) and									// and|ora|eor				; 5
       sta(i+6) and										// sta					; 6
       ldy(i+7) then										// ldy T+1				; 7
//       sty_bp_1(i+8) then									// sty :bp+1				; 8
     if (listing[i] = listing[i+7]) and
        (listing[i+1] = listing[i+8]) then
       begin
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
       end;


    if sta_bp_1(i+3) and									// sta :bp+1				; 3

       lda_a(i) and (iy(i) = false) and								// lda T				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda(i+2) and										// lda					; 2
//       sta_bp_1(i+3) and									// sta :bp+1				; 3
       ldy_stack(i+4) then									// ldy :STACKORIGIN+9			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i+4] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	listing[i+2] := #9'ldy ' + copy(listing[i+2], 6, 256);
	listing[i+3] := #9'sty :bp+1';

	exit(false);
       end;


    if sta_bp_1(i+4) and									// sta :bp+1				; 4

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda(i+2) and										// lda					; 2
       add_sub(i+3) and										// add|sub				; 3
//       sta_bp_1(i+4) and									// sta :bp+1				; 4
       ldy_stack(i+5) then									// ldy :STACKORIGIN+9			; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+5] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	if (add_im_0(i+3) or sub_im_0(i+3)) then begin
	 listing[i+3] := #9'ldy ' + copy(listing[i+2], 6, 256);
	 listing[i+4] := #9'sty :bp+1';

	 listing[i+2] := '';
	end;

	exit(false);
       end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_stack(i) and										// lda :STACKORIGIN			; 0
       sub(i+1) and (sub_stack(i+1) = false) and						// sub					; 1	~:STACKORIGIN
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH		; 3
       sbc(i+4) and (sbc_stack(i+4) = false) and						// sbc					; 4	~:STACKORIGIN
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) then									// ldy :STACKORIGIN+9			; 6
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+6] := '';

	listing[i+2] := #9'tay';

	exit(false);
       end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       (add_im_0(i+1) or sub_im_0(i+1)) and							// add|sub #$00				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) then									// ldy :STACKORIGIN+9			; 6
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+6] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	if adc(i+4) then
	 listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256)
	else
	 listing[i+4] := #9'sub ' + copy(listing[i+4], 6, 256);

	if (add_im_0(i+4) or sub_im_0(i+4)) then begin
	 listing[i+3] := #9'ldy ' + copy(listing[i+3], 6, 256);
	 listing[i+4] := #9'sty :bp+1';
	 listing[i+5] := '';
	end;

	exit(false);
       end;


    if sta_bp_1(i+3) and									// sta :bp+1				; 3

       ldy(i) and										// ldy					; 0
       lda(i+1) and (iy(i+1) = false) and							// lda					; 1
       add_im_0(i+2) then									// add #$00				; 2
//       sta_bp_1(i+3) then									// sta :bp+1				; 3
      begin
        listing[i+3] := listing[i];

	listing[i]   := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'sty :bp+1';
	listing[i+2] := '';

	exit(false);
      end;


    if sty_bp_1(i+3) and									// sty :bp+1				; 3

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_val(i+2) and										// ldy					; 2	~:STACKORIGIN
//       sty_bp_1(i+3) and									// sty :bp+1				; 3
       ldy_val(i+4) and										// ldy					; 4	~:STACKORIGIN
       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
        listing[i+5] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if sty_bp_1(i+3) and									// sty :bp+1				; 3

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_val(i+2) and										// ldy					; 2	~:STACKORIGIN
//       sty_bp_1(i+3) and									// sty :bp+1				; 3
       ldy_val(i+4) and										// ldy					; 4	~:STACKORIGIN
       lda_bp_y(i+5) and									// lda (:bp),y				; 5
       ldy_stack(i+6) then									// ldy :STACKORIGIN			; 6
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then
      begin
        listing[i+6] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if sty_bp_1(i+3) and									// sty :bp+1				; 3

       (lda_a(i) = false) and 									//~lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_val(i+2) and										// ldy					; 2	~:STACKORIGIN
//       sty_bp_1(i+3) and									// sty :bp+1				; 3
       ldy_val(i+4) and										// ldy					; 4	~:STACKORIGIN
       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
        listing[i+1] := '';

        listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_y(i+10) and 									// sta (:bp),y				; 10

       lda_val(i) and (lda_im(i) = false) and							// lda A				; 0
       add(i+1) and (add_stack(i+1) = false) and (iy(i+1) = false) and				// add X				; 1	~:STACKORIGIN
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       (listing[i+3] = listing[i] + '+1') and 							// lda A+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy(i+6) and										// ldy Y				; 6
       lda_a(i+7) and										// lda 					; 7
       (add_sub(i+8) or and_ora_eor(i+8)) and							// add|sub|and|ora|eor			; 8
       ldy_stack(i+9) then 									// ldy :STACKORIGIN+10			; 9
//       sta_bp_y(i+10) then 									// sta (:bp),y				; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	 listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	 listing[i+9]  := #9'ldy ' + copy(listing[i+1], 6, 256);
	 listing[i+10] := #9'sta (:bp2),y';

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_1(i+10) and									// sta :bp+1				; 10

       add(i) and										// add					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+STACKWIDTH		; 2
       adc_im_0(i+3) and									// adc #$00				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_im_0(i+5) and									// lda #$00				; 5
       add_stack(i+6) and									// add :STACKORIGIN			; 6
       tay(i+7) and										// tay					; 7
       lda_val(i+8) and										// lda					; 8	~:STACKORIGIN
       adc_stack(i+9) then									// adc :STACKORIGIN+STACKWIDTH		; 9
//       sta_bp_1(i+10) then									// sta :bp+1				; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+1] := #9'tay';

	listing[i+3] := #9'adc ' + copy(listing[i+8], 6, 256);
	listing[i+4] := #9'sta :bp+1';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';

	exit(false);
       end;


    if sta_bp_1(i+7) and									// sta :bp+1				; 7

       (adc(i) = false) and									//~adc					; 0
												//					; 1
       lda_im_0(i+2) and									// lda #$00				; 2
       add_stack(i+3) and									// add :STACKORIGIN			; 3
       tay(i+4) and										// tay					; 4
       lda_im(i+5) and (lda_im_0(i+5) = false) and						// lda #				; 5	~#$00
       adc_stack(i+6) then									// adc :STACKORIGIN+STACKWIDTH		; 6
//       sta_bp_1(i+7) then									// sta :bp+1				; 7
      begin
	listing[i+2] := '';
	listing[i+3] := #9'ldy ' + copy(listing[i+3], 6, 256);
	listing[i+4] := '';

	listing[i+6] := #9'add ' + copy(listing[i+6], 6, 256);

	exit(false);
       end;


    if sta_bp_y(i+11) and									// sta (:bp),y				; 11

       lda(i) and										// lda 					; 0
       sta_stack(i+1) and 									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda(i+2) and										// lda TB+1				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       lda(i+4) and										// lda BUFFER				; 4
       add_sub(i+5) and										// add|sub				; 5
       tay(i+6) and										// tay					; 6
       lda(i+7) and										// lda BUFFER+1				; 7
       adc_sbc_stack(i+8) and									// adc|sbc :STACKORIGIN+STACKWIDTH	; 8
       sta_bp_1(i+9) and									// sta :bp+1				; 9
       lda_stack(i+10) then									// lda :STACKORIGIN			; 10
//       sta_bp_y(i+11) then									// sta (:bp),y				; 11
    if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
       (copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+10] := #9'lda ' + copy(listing[i+2], 6, 256);

	listing[i+2] := '';
	listing[i+3] := '';

	if adc_stack(i+8) then
	 listing[i+8] := #9'adc ' + copy(listing[i], 6, 256)
	else
	 listing[i+8] := #9'sbc ' + copy(listing[i], 6, 256);

	listing[i] := '';
	listing[i+1] := '';

	exit(false);
      end;


    if sta_bp_y(i+9) and									// sta (:bp),y				; 9

       lda_val(i) and (iy(i) = false) and							// lda TB+1				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and										// lda BUFFER				; 2
       add_sub(i+3) and										// add|sub				; 3
       tay(i+4) and										// tay					; 4
       lda_a(i+5) and										// lda BUFFER+1				; 5
       adc_sbc(i+6) and										// adc|sbc				; 6
       sta_bp_1(i+7) and									// sta :bp+1				; 7
       lda_stack(i+8) then									// lda :STACKORIGIN			; 8
//       sta_bp_y(i+9) then									// sta (:bp),y				; 9
    if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+8] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if sta_bp_y(i+6) and									// sta (:bp),y				; 6

       lda(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and 									// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda TB+1				; 2
       sta_bp_1(i+3) and									// sta :bp+1				; 3
       ldy(i+4) and										// ldy TB				; 4
       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
//       sta_bp_y(i+6) then									// sta (:bp),y				; 6
    if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+5] := listing[i];

	listing[i] := '';
	listing[i+1] := '';

	listing[i+2] := #9'ldy ' + copy(listing[i+2], 6, 256);
	listing[i+3] := #9'sty :bp+1';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       sty_stack(i) and										// sty :STACKORIGIN+STACKWIDTH		; 0
       lda(i+1) and										// lda					; 1
       add_sub(i+2) and										// add|sub				; 2
       sta(i+3) and										// sta					; 3
       lda_stack(i+4) then									// lda :STACKORIGIN+STACKWIDTH		; 4
//       sta_bp_1(i+5) then									// sta :bp+1				; 5
    if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i] := #9'sty :bp+1';

	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda O				; 0
       add(i+1) and (iy(i+1) = false) and							// add C				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and (lda_im(i+3) = false) and (iy(i+3) = false) and				// lda O+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_val(i+9) and (lda_im_0(i+9) = false) and						// lda					; 9	~#$00
       adc_stack(i+10) then									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) then									// sta :bp+1				; 11
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+6] := #9'lda ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if ldy_im(i) and										// ldy #				; 0
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       ldy_im(i+3) and										// ldy #				; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_val(i+5) and										// sta					; 5	~:STACKORIGN
       lda_stack(i+6) then									// lda :STACKORIGIN+STACKWIDTH		; 6
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+2] := listing[i+5];

	listing[i+5] := listing[i];
	listing[i+6] := listing[i+1];

	listing[i] := listing[i+3];

	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
       end;


    if LDA_BP2_Y(i) and										// lda (:bp2),y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       iny(i+2) and										// iny					; 2
       LDA_BP2_Y(i+3) and									// lda (:bp2),y				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+9			; 5
       sta_a(i+6) and										// sta					; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH		; 7
       sta_a(i+8) then										// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin
	listing[i+1] := listing[i+6];
	listing[i+4] := listing[i+8];

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
       end;


    if lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       mwy_bp2(i+2) and										// mwy   :bp2				; 2
       ldy(i+3) and										// ldy 					; 3
       lda_bp2_y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta STACKORIGIN			; 5
       lda_stack(i+6) then									// lda :STACKORIGIN+STACKWIDTH		; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       mwy_bp2(i+1) and										// mwy   :bp2				; 1
       ldy(i+2) and										// ldy 					; 2
       lda_stack(i+3) then									// lda STACKORIGIN			; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+3] := '';

	exit(false);
       end;


    if lda_a(i) and										// lda					; 0
       mwy_bp2(i+1) and										// mwy   :bp2				; 1
       ldy(i+2) and										// ldy 					; 2
       lda_a(i+3) then										// lda 					; 3
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_a(i) or AND_ORA_EOR(i)) and								// lda|and|ora|eor			; 0
       mwy_bp2(i+1) and	(pos(#9'mwy #', listing[i+1]) = 0) and					// mwy P0 :bp2				; 1
       ldy_im_0(i+2) and 									// ldy #$00				; 2
       STA_BP2_Y(i+3) and  									// sta (:bp2),y				; 3
       (listing[i+4] = '') then									//~
      begin

        yes:=true;
	for p:=i-1 downto 0 do
	 if copy(listing[p], 6, 256) = copy(listing[i+1], 6, 256) then begin yes:=false; Break end;

	if yes then begin
	 tmp := GetString(i+1);

	 listing[i+1] := #9'mvy ' + tmp + '+1 :bp+1';
	 listing[i+2] := #9'ldy ' + tmp;
	 listing[i+3] := #9'sta (:bp),y';

	 exit(false);
	end;

      end;


    if (asl(i) or lsr(i)) and									// asl|lsr				; 0
       mwy_bp2(i+1) and (pos(#9'mwy #', listing[i+1]) = 0) and					// mwy P0 :bp2				; 1
       ldy_im_0(i+2) and 									// ldy #$00				; 2
       STA_BP2_Y(i+3) and  									// sta (:bp2),y				; 3
       (listing[i+4] = '') then									//~
       begin

        yes:=true;
	for p:=i-1 downto 0 do
	 if copy(listing[p], 6, 256) = copy(listing[i+1], 6, 256) then begin yes:=false; Break end;

	if yes then begin
	 tmp := GetString(i+1);

	 listing[i+1] := #9'mvy ' + tmp + '+1 :bp+1';
	 listing[i+2] := #9'ldy ' + tmp;
	 listing[i+3] := #9'sta (:bp),y';

	 exit(false);
	end;

       end;


    if STA_BP2_Y(i+7) and									// sta (:bp2),y				; 7

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda 					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       mwy_bp2(i+4) and										// mwy X :bp2				; 4
       ldy(i+5) and 										// ldy					; 5
       lda_stack(i+6) and									// lda  :STACKORIGIN+9			; 6
//       STA_BP2_Y(i+7) and									// sta (:bp2),y				; 7
       iny(i+8) and										// iny					; 8
       lda_stack(i+9) then 									// lda :STACKORIGIN+STACKWIDTH+9	; 9
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+6] := listing[i];
	listing[i+9] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if ADC_BP2_Y(i+11) and									// adc (:bp2),y				; 11

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda 					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       mwy_bp2(i+4) and										// mwy X :bp2				; 4
       ldy(i+5) and 										// ldy					; 5
       lda_stack(i+6) and									// lda  :STACKORIGIN+9			; 6
       ADD_BP2_Y(i+7) and									// add (:bp2),y				; 7
       iny(i+8) and										// iny					; 8
       sta(i+9) and 										// sta					; 9
       lda_stack(i+10) then									// lda :STACKORIGIN+STACKWIDTH+9	; 10
//       ADC_BP2_Y(i+11) then									// adc (:bp2),y				; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	listing[i+6] := listing[i];
	listing[i+10] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if ADC_BP2_Y(i+15) and									// adc (:bp2),y				; 15

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       lda_a(i+4) and (iy(i+4) = false) and							// lda					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 5
       lda_a(i+6) and (iy(i+6) = false) and							// lda					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 7
       mwy_bp2(i+8) and										// mwy BASE :bp2			; 8
       ldy(i+9) and										// ldy					; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+9			; 10
       ADD_BP2_Y(i+11) and									// add (:bp2),y				; 11
       iny(i+12) and										// iny					; 12
       sta(i+13) and										// sta LPOS				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH+9	; 14
//       ADC_BP2_Y(i+15) and									// adc (:bp2),y				; 15
       sta(i+16) and										// sta LPOS+1				; 16
       lda_stack(i+17) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 17
       adc(i+18) and										// adc #$00				; 18
       sta(i+19) and										// sta LPOS+2				; 19
       lda_stack(i+20) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 20
       adc(i+21) and										// adc #$00				; 21
       sta(i+22) then										// sta LPOS+3				; 22
     if (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+20], 6, 256)) then
       begin
	listing[i+10] := listing[i];
	listing[i+14] := listing[i+2];
	listing[i+17] := listing[i+4];
	listing[i+20] := listing[i+6];

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


    if STA_BP2_Y(i+13) and 									// sta (:bp2),y				; 13

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda 					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       mwy_bp2(i+4) and										// mwy X bp2				; 4
       ldy(i+5) and 										// ldy					; 5
       lda(i+6) and										// lda					; 6
       STA_BP2_Y(i+7) and									// sta (:bp2),y				; 7
       iny(i+8) and										// iny					; 8
       lda(i+9) and										// lda					; 9
       STA_BP2_Y(i+10) and 									// sta (:bp2),y				; 10
       iny(i+11) and										// iny					; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+9			; 12
//       STA_BP2_Y(i+13) and 									// sta (:bp2),y				; 13
       iny(i+14) and										// iny					; 14
       lda_stack(i+15) and									// lda :STACKORIGIN+STACKWIDTH+9	; 15
       STA_BP2_Y(i+16) then
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+15], 6, 256)) then
       begin
	listing[i+12] := listing[i];
	listing[i+15] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10

//       ldy_im_0(i) and									// ldy #$00				; 0	cardinal
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       iny(i+6) and										// iny					; 6
       LDA_BP2_Y(i+7) and									// lda (:bp2),y				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       iny(i+9) and										// iny					; 9
//       LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH		; 12
       sta_stack(i+13) and									// sta :STACKORIGIN			; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH*2	; 14
       sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH		; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*3	; 16
       sta_stack(i+17) then									// sta :STACKORIGIN+STACKWIDTH*2	; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+12], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+14], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+11] := listing[i+8];

	listing[i+8] := listing[i+5];

	listing[i+5] := listing[i+2];

	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';

	exit(false);
       end;


    if LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10

//       ldy_im_0(i) and									// ldy #$00				; 0	cardinal
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       iny(i+6) and										// iny					; 6
       LDA_BP2_Y(i+7) and									// lda (:bp2),y				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       iny(i+9) and										// iny					; 9
//       LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda(i+12) and										// lda SCRL				; 12
       add_sub(i+13) and									// add|sub :STACKORIGIN			; 13
       sta(i+14) and										// sta X				; 14
       lda(i+15) and										// lda SCRL+1				; 15
       adc_sbc(i+16) and									// adc|sbc :STACKORIGIN+STACKWIDTH	; 16
       sta(i+17) and										// sta X+1				; 17
       lda(i+18) and										// lda SCRL+2				; 18
       adc_sbc(i+19) and									// adc|sbc :STACKORIGIN+STACKWIDTH*2	; 19
       sta(i+20) and										// sta X+2				; 20
       lda(i+21) and										// lda SCRL+3				; 21
       adc_sbc(i+22) and									// adc|sbc :STACKORIGIN+STACKWIDTH*3	; 22
       sta(i+23) then										// sta X+3				; 23
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+22], 6, 256)) then
       begin
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

	if add(i+13) then begin
	 listing[i+13] := #9'add (:bp2),y+';
	 listing[i+16] := #9'adc (:bp2),y+';
	 listing[i+19] := #9'adc (:bp2),y+';
	 listing[i+22] := #9'adc (:bp2),y';
	end else begin
	 listing[i+13] := #9'sub (:bp2),y+';
	 listing[i+16] := #9'sbc (:bp2),y+';
	 listing[i+19] := #9'sbc (:bp2),y+';
	 listing[i+22] := #9'sbc (:bp2),y';
	end;

	exit(false);
       end;


    if LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10

//       ldy_im(i) and										// ldy #				; 0	cardinal
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       iny(i+6) and										// iny					; 6
       LDA_BP2_Y(i+7) and									// lda (:bp2),y				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       iny(i+9) and										// iny					; 9
//       LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       (add_sub(i+13) or and_ora_eor(i+13)) and (iy(i+13) = false) and				// add|sub|and|ora|eor A		; 13
       sta(i+14) and										// sta 					; 14
       lda_stack(i+15) and									// lda :STACKORIGIN+STACKWIDTH		; 15
       (adc_sbc(i+16) or and_ora_eor(i+16)) and							// adc|sbc|and|ora|eor A+1	 	; 16
       sta(i+17) and										// sta 					; 17
       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH*2	; 18
       (adc_sbc(i+19) or and_ora_eor(i+19)) and							// adc|sbc|and|ora|eor A+2 		; 19
       sta(i+20) and										// sta 					; 20
       lda_stack(i+21) and									// lda :STACKORIGIN+STACKWIDTH*3	; 21
       (adc_sbc(i+22) or and_ora_eor(i+22)) and							// adc|sbc|and|ora|eor A+3 		; 22
       sta(i+23) then										// sta 					; 23
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+21], 6, 256)) then
       begin
	listing[i+1] := #9'lda (:bp2),y';
	listing[i+2] := listing[i+13];
	listing[i+3] := listing[i+14];
	listing[i+4] := #9'iny';
	listing[i+5] := #9'lda (:bp2),y';
	listing[i+6] := listing[i+16];
	listing[i+7] := listing[i+17];
	listing[i+8] := #9'iny';
	listing[i+9] := #9'lda (:bp2),y';
	listing[i+10]:= listing[i+19];
	listing[i+11]:= listing[i+20];
	listing[i+12]:= #9'iny';
	listing[i+13]:= #9'lda (:bp2),y';
	listing[i+14]:= listing[i+22];
	listing[i+15]:= listing[i+23];

	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	exit(false);
       end;


    if sta_bp2_y(i+15) and									// sta (:bp2),y				; 15

       mwy(i) and (listing[i] = listing[i+9]) and						// mwy					; 0	word
       ldy_im(i+1) and (listing[i+1] = listing[i+10]) and					// ldy #				; 1
       LDA_BP2_Y(i+2) and									// lda (:bp2),y				; 2
       add_sub(i+3) and										// add|sub				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       iny(i+5) and										// iny					; 5
       LDA_BP2_Y(i+6) and									// lda (:bp2),y				; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH		; 8
//       mwy(i+9) and										// mwy					; 9
//       ldy_im(i+10) and									// ldy #				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN			; 11
       sta_bp2_y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and										// iny					; 13
       lda_stack(i+14) then									// lda :STACKORIGIN+STACKWIDTH		; 14
//       sta_bp2_y(i+15) then									// sta (:bp2),y				; 15
     if (copy(listing[i+4], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+4] := #9'sta (:bp2),y';

	listing[i+8] := #9'sta (:bp2),y';

	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';
	listing[i+14]:= '';
	listing[i+15]:= '';

	exit(false);
       end;


    if LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4

//       ldy_im(i) and										// ldy #				; 0	word
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
//       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       (add_sub(i+7) or and_ora_eor(i+7)) and (iy(i+7) = false) and				// add|sub|and|ora|eor A		; 7
       sta(i+8) and										// sta 					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH		; 9
       (adc_sbc(i+10) or and_ora_eor(i+10)) and							// adc|sbc|and|ora|eor A+1	 	; 10
       sta(i+11) then										// sta 					; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	listing[i+1] := #9'lda (:bp2),y';
	listing[i+2] := listing[i+7];
	listing[i+3] := listing[i+8];
	listing[i+4] := #9'iny';
	listing[i+5] := #9'lda (:bp2),y';
	listing[i+6] := listing[i+10];
	listing[i+7] := listing[i+11];

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	exit(false);
       end;


    if LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4

//       ldy_im(i) and										// ldy #				; 0	word
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
//       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_a(i+6) and (iy(i+6) = false) and							// lda					; 6
       (add_sub_stack(i+7) or and_ora_eor_stack(i+7)) and					// add|sub|and|ora|eor :STACKORIGIN	; 7
       sta(i+8) and										// sta 					; 8
       lda_a(i+9) and (iy(i+9) = false) and							// lda					; 9
       (adc_sbc_stack(i+10) or and_ora_eor_stack(i+10)) and					// adc|sbc|and|ora|eor :STACKORIGIN+ 	; 10
       sta(i+11) then										// sta 					; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	listing[i+1] := listing[i+6];
	listing[i+2] := copy(listing[i+7], 1, 5) + '(:bp2),y';
	listing[i+3] := listing[i+8];
	listing[i+4] := #9'iny';
	listing[i+5] := listing[i+9];
	listing[i+6] := copy(listing[i+10], 1, 5) + '(:bp2),y';
	listing[i+7] := listing[i+11];

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	exit(false);
       end;


    if (i > 0) and
       STA_BP2_Y(i+28) and									// sta (:bp2),y				; 28

//       mwy_bp2(i-1) and									// mwy ... :bp2				; -1

       ldy(i) and {ldy(i+17) and} (listing[i] = listing[i+17]) and				// ldy 					; 0
       {mwy_bp2(i+16) and} mwy_bp2(i-1) and (listing[i-1] = listing[i+16]) and			// mwy ... :bp2				; 16

       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       add_sub(i+2) and										// add|sub				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       iny(i+4) and										// iny					; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       adc_sbc(i+6) and										// adc|sbc				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH		; 7
       iny(i+8) and										// iny					; 8
       LDA_BP2_Y(i+9) and									// lda (:bp2),y				; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*2	; 11
       iny(i+12) and										// iny					; 12
       LDA_BP2_Y(i+13) and									// lda (:bp2),y				; 13
       adc_sbc(i+14) and									// adc|sbc 				; 14
       sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*3	; 15
//       mwy_bp2(i+16) and									// mwy ... :bp2				; 16
//       ldy(i+17) and										// ldy 					; 17
       lda_stack(i+18) and									// lda :STACKORIGIN			; 18
       STA_BP2_Y(i+19) and									// sta (:bp2),y				; 19
       iny(i+20) and										// iny					; 20
       lda_stack(i+21) and									// lda :STACKORIGIN+STACKWIDTH		; 21
       STA_BP2_Y(i+22) and									// sta (:bp2),y				; 22
       iny(i+23) and										// iny					; 23
       lda_stack(i+24) and									// lda :STACKORIGIN+STACKWIDTH*2	; 24
       STA_BP2_Y(i+25) and									// sta (:bp2),y				; 25
       iny(i+26) and										// iny					; 26
       lda_stack(i+27) then									// lda :STACKORIGIN+STACKWIDTH*3	; 27
//       STA_BP2_Y(i+28) then									// sta (:bp2),y				; 28
     if (copy(listing[i+3], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+21], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+24], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+27], 6, 256)) then
       begin
	listing[i+3] := #9'sta (:bp2),y';
	listing[i+7] := #9'sta (:bp2),y';
	listing[i+11]:= #9'sta (:bp2),y';
	listing[i+15]:= #9'sta (:bp2),y';

	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+29) and									// sta (:bp2),y				; 29

       lda(i) and										// lda :STACKORIGIN+10			; 0
       add_sub(i+1) and										// add|sub				; 1
       sta(i+2) and										// sta :STACKORIGIN+10			; 2
       lda(i+3) and										// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta(i+5) and										// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda(i+6) and										// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta(i+8) and										// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda(i+9) and										// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta(i+11) and										// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda(i+12) and										// lda SINLOGO				; 12
       add_sub(i+13) and									// add :STACKORIGIN+9			; 13
       sta_bp2(i+14) and									// sta :bp2				; 14
       lda(i+15) and										// lda SINLOGO+1			; 15
       adc_sbc(i+16) and									// adc :STACKORIGIN+STACKWIDTH+9	; 16
       sta_bp2_1(i+17) and									// sta :bp2+1				; 17
       ldy_im_0(i+18) and									// ldy #$00				; 18
       lda(i+19) and										// lda :STACKORIGIN+10			; 19
       STA_BP2_Y(i+20) and									// sta (:bp2),y				; 20
       iny(i+21) and										// iny					; 21
       lda(i+22) and										// lda :STACKORIGIN+STACKWIDTH+10	; 22
       STA_BP2_Y(i+23) and									// sta (:bp2),y				; 23
       iny(i+24) and										// iny					; 24
       lda(i+25) and										// lda :STACKORIGIN+STACKWIDTH*2+10	; 25
       STA_BP2_Y(i+26) and									// sta (:bp2),y				; 26
       iny(i+27) and										// iny					; 27
       lda(i+28) then										// lda :STACKORIGIN+STACKWIDTH*3+10	; 28
//       STA_BP2_Y(i+29) then									// sta (:bp2),y				; 29
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+13], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+25], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+28], 6, 256)) then
       begin
	listing_tmp[0]  := listing[i+12];
	listing_tmp[1]  := listing[i+13];
	listing_tmp[2]  := listing[i+14];
	listing_tmp[3]  := listing[i+15];
	listing_tmp[4]  := listing[i+16];
	listing_tmp[5]  := listing[i+17];

	listing_tmp[6]  := listing[i+18];

	listing_tmp[7]  := listing[i];
	listing_tmp[8]  := listing[i+1];
	listing_tmp[9]  := listing[i+20];

	listing_tmp[10] := listing[i+21];

	listing_tmp[11] := listing[i+3];
	listing_tmp[12] := listing[i+4];
	listing_tmp[13] := listing[i+20];

	listing_tmp[14] := listing[i+21];

	listing_tmp[15] := listing[i+6];
	listing_tmp[16] := listing[i+7];
	listing_tmp[17] := listing[i+20];

	listing_tmp[18] := listing[i+21];

	listing_tmp[19] := listing[i+9];
	listing_tmp[20] := listing[i+10];
	listing_tmp[21] := listing[i+20];

	for p:=0 to 21 do
	 listing[i+p] := listing_tmp[p];

	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';
	listing[i+29] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+29) and									// sta (:bp2),y				; 29

       lda_im(i) and										// lda #				; 0
       sta(i+1) and										// sta 					; 1
       lda_im(i+2) and										// lda #				; 2
       sta(i+3) and										// sta 					; 3
       lda_im(i+4) and										// lda #				; 4
       sta(i+5) and										// sta 					; 5
       lda_im(i+6) and										// lda #				; 6
       sta(i+7) and										// sta 					; 7
       lda(i+8) and										// lda SINSCROL				; 8
       add_sub(i+9) and										// add|sub :STACKORIGIN+9		; 9
       sta_bp2(i+10) and									// sta :bp2				; 10
       lda(i+11) and										// lda SINSCROL+1			; 11
       adc_sbc(i+12) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 12
       sta_bp2_1(i+13) and									// sta :bp2+1				; 13
       ldy_im_0(i+14) and									// ldy #$00				; 14
       lda(i+15) and										// lda :STACKORIGIN+10			; 15
       add_sub(i+16) and									// add|sub A				; 16
       STA_BP2_Y(i+17) and									// sta (:bp2),y				; 17
       iny(i+18) and										// iny					; 18
       lda(i+19) and										// lda :STACKORIGIN+STACKWIDTH+10	; 19
       adc_sbc(i+20) and									// adc|sbc A+1				; 20
       STA_BP2_Y(i+21) and									// sta (:bp2),y				; 21
       iny(i+22) and										// iny					; 22
       lda(i+23) and										// lda :STACKORIGIN+STACKWIDTH*2+10	; 23
       adc_sbc(i+24) and									// adc|sbc A+2				; 24
       STA_BP2_Y(i+25) and									// sta (:bp2),y				; 25
       iny(i+26) and										// iny					; 26
       lda(i+27) and										// lda :STACKORIGIN+STACKWIDTH*3+10	; 27
       adc_sbc(i+28) then									// adc|sbc A+3				; 28
//       STA_BP2_Y(i+29) then									// sta (:bp2),y				; 29
     if (copy(listing[i+1], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+20], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+24], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+28], 6, 256)) then
       begin
	listing[i+16] := #9'add ' + copy(listing[i], 6, 256);
	listing[i+20] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i+24] := #9'adc ' + copy(listing[i+4], 6, 256);
	listing[i+28] := #9'adc ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15

       ldy(i) and (listing[i] = listing[i+10]) and						// ldy XXX				; 0
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_val(i+6) and (lda_im(i+6) = false) and						// lda OFFSET				; 6	~#
       sta_bp2(i+7) and										// sta :bp2				; 7
       (listing[i+8] = listing[i+6] + '+1') and							// lda OFFSET+1				; 8	~#
       sta_bp2_1(i+9) and									// sta :bp2+1				; 9
//       ldy(i+10) and										// ldy XXX				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+10			; 11
       STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and										// iny					; 13
       lda_stack(i+14) then									// lda :STACKORIGIN+STACKWIDTH+10	; 14
//       STA_BP2_Y(i+15) then									// sta (:bp2),y				; 15
     if (copy(listing[i+2], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin

        if pos(listing[i+6], listing[i+8]) > 0 then begin
	 listing[i]   := #9'mwy ' + copy(listing[i+6], 6, 256) + ' :TMP';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	end else begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := #9'sta :TMP';
	 listing[i+2] := listing[i+8];
	 listing[i+3] := #9'sta :TMP+1';
	end;

	listing[i+4] := #9'ldy #$00';
	listing[i+5] := #9'lda (:bp2),y';
	listing[i+6] := #9'sta (:TMP),y';
	listing[i+7] := #9'iny';
	listing[i+8] := #9'lda (:bp2),y';
	listing[i+9] := #9'sta (:TMP),y';

	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+37) and									// sta (:bp2),y				; 37

       sta_bp2(i) and										// sta :bp2				; 0
       lda_a(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1 				; 3
       ldy(i+4) and (listing[i+4] = listing[i+26]) and						// ldy XXX				; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       (add_sub(i+6) or and_ora_eor(i+6)) and							// add|sub|and|ora|eor			; 6
       sta_stack(i+7) and									// sta :STACKORIGIN			; 7
       iny(i+8) and										// iny					; 8
       LDA_BP2_Y(i+9) and									// lda (:bp2),y				; 9
       (adc_sbc(i+10) or and_ora_eor(i+10)) and							// adc|sbc|and|ora|eor			; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH		; 11
       iny(i+12) and										// iny					; 12
       LDA_BP2_Y(i+13) and									// lda (:bp2),y				; 13
       (adc_sbc(i+14) or and_ora_eor(i+14)) and							// adc|sbc|and|ora|eor			; 14
       sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*2	; 15
       iny(i+16) and										// iny					; 16
       LDA_BP2_Y(i+17) and									// lda (:bp2),y				; 17
       (adc_sbc(i+18) or and_ora_eor(i+18)) and							// adc|sbc|and|ora|eor			; 18
       sta_stack(i+19) and									// sta :STACKORIGIN+STACKWIDTH*3	; 19
       lda_a(i+20) and										// lda OFFSET				; 20
       add_sub(i+21) and									// add|sub				; 21
       sta_bp2(i+22) and									// sta :bp2				; 22
       lda_a(i+23) and										// lda OFFSET+1				; 23
       adc_sbc(i+24) and									// adc|sbc				; 24
       sta_bp2_1(i+25) and									// sta :bp2+1				; 25
//       ldy(i+26) and										// ldy XXX				; 26
       lda_stack(i+27) and									// lda :STACKORIGIN			; 27
       STA_BP2_Y(i+28) and									// sta (:bp2),y				; 28
       iny(i+29) and										// iny					; 29
       lda_stack(i+30) and									// lda :STACKORIGIN+STACKWIDTH		; 30
       STA_BP2_Y(i+31) and									// sta (:bp2),y				; 31
       iny(i+32) and										// iny					; 32
       lda_stack(i+33) and									// lda :STACKORIGIN+STACKWIDTH*2	; 33
       STA_BP2_Y(i+34) and									// sta (:bp2),y				; 34
       iny(i+35) and										// iny					; 35
       lda_stack(i+36) then									// lda :STACKORIGIN+STACKWIDTH*3	; 36
//       STA_BP2_Y(i+37) then									// sta (:bp2),y				; 37
     if (copy(listing[i+7], 6, 256) = copy(listing[i+27], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+30], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+33], 6, 256)) and
	(copy(listing[i+19], 6, 256) = copy(listing[i+36], 6, 256)) then
       begin
        listing[i+22]:= #9'sta :TMP';

	listing[i+25]:= #9'sta :TMP+1';

	listing_tmp[0] := listing[i+20];
	listing_tmp[1] := listing[i+21];
	listing_tmp[2] := listing[i+22];
	listing_tmp[3] := listing[i+23];
	listing_tmp[4] := listing[i+24];
	listing_tmp[5] := listing[i+25];

	listing_tmp[6] := listing[i+4];
	listing_tmp[7] := listing[i+5];
	listing_tmp[8] := listing[i+6];
	listing_tmp[9] := #9'sta (:TMP),y';
	listing_tmp[10]:= #9'iny';
	listing_tmp[11]:= listing[i+9];
	listing_tmp[12]:= listing[i+10];
	listing_tmp[13]:= #9'sta (:TMP),y';
	listing_tmp[14]:= #9'iny';
	listing_tmp[15]:= listing[i+13];
	listing_tmp[16]:= listing[i+14];
	listing_tmp[17]:= #9'sta (:TMP),y';
	listing_tmp[18]:= #9'iny';
	listing_tmp[19]:= listing[i+17];
	listing_tmp[20]:= listing[i+18];
	listing_tmp[21]:= #9'sta (:TMP),y';

	for p:=0 to 21 do listing[i+p+4] := listing_tmp[p];

	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';
	listing[i+29] := '';
	listing[i+30] := '';
	listing[i+31] := '';
	listing[i+32] := '';
	listing[i+33] := '';
	listing[i+34] := '';
	listing[i+35] := '';
	listing[i+36] := '';
	listing[i+37] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+23) and									// sta (:bp2),y				; 23

       sta_bp2(i) and										// sta :bp2				; 0
       lda_a(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1 				; 3
       ldy(i+4) and (listing[i+4] = listing[i+18]) and						// ldy XXX				; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       (add_sub(i+6) or and_ora_eor(i+6)) and							// add|sub|and|ora|eor			; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+10			; 7
       iny(i+8) and										// iny					; 8
       LDA_BP2_Y(i+9) and									// lda (:bp2),y				; 9
       (adc_sbc(i+10) or and_ora_eor(i+10)) and							// adc|sbc|and|ora|eor			; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH+10	; 11
       lda_a(i+12) and										// lda OFFSET				; 12
       add_sub(i+13) and									// add|sub				; 13
       sta_bp2(i+14) and									// sta :bp2				; 14
       lda_a(i+15) and										// lda OFFSET+1				; 15
       adc_sbc(i+16) and									// adc|sbc				; 16
       sta_bp2_1(i+17) and									// sta :bp2+1				; 17
//       ldy(i+18) and										// ldy XXX				; 18
       lda_stack(i+19) and									// lda :STACKORIGIN+10			; 19
       STA_BP2_Y(i+20) and									// sta (:bp2),y				; 20
       iny(i+21) and										// iny					; 21
       lda_stack(i+22) then									// lda :STACKORIGIN+STACKWIDTH+10	; 22
//       STA_BP2_Y(i+23) then									// sta (:bp2),y				; 23
     if (copy(listing[i+7], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+22], 6, 256)) then
       begin
        listing[i+14]:= #9'sta :TMP';

	listing[i+17]:= #9'sta :TMP+1';

	listing_tmp[0] := listing[i+12];
	listing_tmp[1] := listing[i+13];
	listing_tmp[2] := listing[i+14];
	listing_tmp[3] := listing[i+15];
	listing_tmp[4] := listing[i+16];
	listing_tmp[5] := listing[i+17];

	listing_tmp[6] := listing[i+4];
	listing_tmp[7] := listing[i+5];
	listing_tmp[8] := listing[i+6];
	listing_tmp[9] := #9'sta (:TMP),y';
	listing_tmp[10]:= #9'iny';
	listing_tmp[11]:= listing[i+9];
	listing_tmp[12]:= listing[i+10];
	listing_tmp[13]:= #9'sta (:TMP),y';

	for p:=0 to 13 do listing[i+p+4] := listing_tmp[p];

	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+21) and									// sta (:bp2),y				; 21

       sta_bp2(i) and										// sta :bp2				; 0
       lda_a(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1 				; 3
       ldy(i+4) and (listing[i+4] = listing[i+16]) and						// ldy XXX				; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+10			; 6
       iny(i+7) and										// iny					; 7
       LDA_BP2_Y(i+8) and									// lda (:bp2),y				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH+10	; 9
       lda_a(i+10) and										// lda OFFSET				; 10
       add_sub(i+11) and									// add|sub				; 11
       sta_bp2(i+12) and									// sta :bp2				; 12
       lda_a(i+13) and										// lda OFFSET+1				; 13
       adc_sbc(i+14) and									// adc|sbc				; 14
       sta_bp2_1(i+15) and									// sta :bp2+1				; 15
//       ldy(i+16) and										// ldy XXX				; 16
       lda_stack(i+17) and									// lda :STACKORIGIN+10			; 17
       STA_BP2_Y(i+18) and									// sta (:bp2),y				; 18
       iny(i+19) and										// iny					; 19
       lda_stack(i+20) then									// lda :STACKORIGIN+STACKWIDTH+10	; 20
//       STA_BP2_Y(i+21) then									// sta (:bp2),y				; 21
     if (copy(listing[i+6], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+9], 6, 256) = copy(listing[i+20], 6, 256)) then
       begin
        listing[i+12]:= #9'sta :TMP';

	listing[i+15]:= #9'sta :TMP+1';

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	listing[i+17]:= #9'lda (:bp2),y';
	listing[i+18]:= #9'sta (:TMP),y';

	listing[i+20]:= #9'lda (:bp2),y';
	listing[i+21]:= #9'sta (:TMP),y';

	exit(false);
       end;


    if STA_BP2_Y(i+18) and									// sta (:bp2),y				; 18

       lda_a(i) and (iy(i) = false) and								// lda					; 0		06-11-2023
       sta_a(i+1) and										// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_a(i+3) and										// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and (iy(i+4) = false) and							// lda					; 4
       sta_a(i+5) and										// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_a(i+6) and (iy(i+6) = false) and							// lda					; 6
       sta_a(i+7) and										// sta :STACKORIGIN+STACKWIDTH*3	; 7
       ldy(i+8) and										// ldy					; 8
       lda_a(i+9) and										// lda					; 9
       sta_bp2(i+10) and									// sta :bp2				; 10
       lda_a(i+11) and										// lda					; 11
       sta_bp2_1(i+12) and									// sta :bp2+1				; 12
       ldy(i+13) and										// ldy					; 13
       lda_a(i+14) and										// lda :STACKORIGIN			; 14
       STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15
       iny(i+16) and										// iny					; 16
       lda_a(i+17) and										// lda :STACKORIGIN+STACKWIDTH		; 17
//       STA_BP2_Y(i+18) and									// sta (:bp2),y				; 18
       (lda_a(i+19) = false) then								//~lda					; 19
     if (copy(listing[i+1], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+14] := listing[i];

	listing[i+17] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+13) and									// sta (:bp2),y				; 13

       mwy_bp2(i) and										// mwy FIRST bp2			; 0
       ldy_im(i+1) and (listing[i+1] = listing[i+8]) and					// ldy #				; 1
       LDA_BP2_Y(i+2) and									// lda (:bp2),y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+9			; 3
       iny(i+4) and										// iny					; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH+9	; 6
       mwy_bp2(i+7) and	(listing[i+7] <> listing[i]) and					// mwy LAST bp2				; 7
//       ldy_im(i+8) and									// ldy #				; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+9			; 9
       STA_BP2_Y(i+10) and  									// sta (:bp2),y				; 10
       iny(i+11) and										// iny					; 11
       lda_stack(i+12) then									// lda :STACKORIGIN+STACKWIDTH		; 12
//       STA_BP2_Y(i+13) then									// sta (:bp2),y				; 13
     if (copy(listing[i+3], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+12], 6, 256)) then
      begin

	listing[i+1] := #9'mwy ' + GetString(i+7) + ' :TMP';
	listing[i+2] := listing[i+8];
	listing[i+3] := #9'lda (:bp2),y';
	listing[i+4] := #9'sta (:TMP),y';
	listing[i+5] := #9'iny';
	listing[i+6] := #9'lda (:bp2),y';
	listing[i+7] := #9'sta (:TMP),y';

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
      end;


    if STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12

       ldy(i) and (listing[i] = listing[i+7]) and						// ldy #$00				; 0
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta(i+2) and										// sta :STACKORIGIN+10			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta(i+5) and										// sta :STACKORIGIN+STACKWIDTH+10	; 5
       mwy_bp2(i+6) and										// mwy XXX :bp2				; 6
//       ldy(i+7) and										// ldy #$00				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+10			; 8
       STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9
       iny(i+10) and										// iny					; 10
       lda_im_0(i+11) then									// lda #$00				; 11
//       STA_BP2_Y(i+12) then									// sta (:bp2),y				; 12
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin

	listing[i]   := #9'mwy ' + GetString(i+6) + ' :TMP';
	listing[i+1] := listing[i+7];
	listing[i+2] := #9'lda (:bp2),y';
	listing[i+3] := #9'sta (:TMP),y';
	listing[i+4] := #9'iny';
	listing[i+5] := #9'lda #$00';
	listing[i+6] := #9'sta (:TMP),y';

	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       ldy_im_0(i) and										// ldy #$00				; 0
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta(i+2) and										// sta :STACKORIGIN+10			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta(i+5) and										// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda(i+6) and 										// lda OUTCODE				; 6
       add_sub(i+7) and										// add|sub				; 7
       tay(i+8) and										// tay					; 8
       lda(i+9) and 										// lda OUTCODE+1			; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       lda(i+12) then 										// lda :STACKORIGIN+10			; 12
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	exit(false);
       end;


    if sta_bp2_1(i+27) and									// sta :bp2+1				; 27

       and_ora_eor_bp2_y(i+42) and								// and|ora|eor (:bp2),y			; 42

       ldy(i) and (listing[i] = listing[i+28]) and						// ldy XXX				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+9			; 1
       and_ora_eor_bp2_y(i+2) and 								// and|ora|eor (:bp2),y			; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+9			; 3
       iny(i+4) and										// iny					; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+STACKWIDTH+9	; 5
       and_ora_eor_bp2_y(i+6) and								// and|ora|eor (:bp2),y			; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH+9	; 7
       iny(i+8) and										// iny					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 9
       and_ora_eor_bp2_y(i+10) and								// and|ora|eor (:bp2),y			; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 11
       iny(i+12) and										// iny					; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 13
       and_ora_eor_bp2_y(i+14) and								// and|ora|eor (:bp2),y			; 14
       sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 15
       lda_im_0(i+16) and									// lda #$00				; 16
       sta_stack(i+17) and									// sta :STACKORIGIN+STACKWIDTH+10	; 17
       lda_a(i+18) and										// lda OFFSET				; 18
       asl_a(i+19) and										// asl @				; 19
       rol_stack(i+20) and									// rol :STACKORIGIN+STACKWIDTH+10	; 20
       asl_a(i+21) and										// asl @				; 21
       rol_stack(i+22) and									// rol :STACKORIGIN+STACKWIDTH+10	; 22
       add_sub(i+23) and									// add|sub				; 23
       sta_bp2(i+24) and									// sta :bp2				; 24
       lda_a(i+25) and										// lda OFFSET+1				; 25
       adc_sbc_stack(i+26) and									// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 26
//       sta_bp2_1(i+27) and									// sta :bp2+1				; 27
       ldy(i+28) and										// ldy XXX				; 28
       lda_stack(i+29) and									// lda :STACKORIGIN+9			; 29
       and_ora_eor_bp2_y(i+30) and 								// and|ora|eor (:bp2),y			; 30
       sta_a(i+31) and										// sta					; 31
       iny(i+32) and										// iny					; 32
       lda_stack(i+33) and									// lda :STACKORIGIN+STACKWIDTH+9	; 33
       and_ora_eor_bp2_y(i+34) and								// and|ora|eor (:bp2),y			; 34
       sta_a(i+35) and										// sta					; 35
       iny(i+36) and										// iny					; 36
       lda_stack(i+37) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 37
       and_ora_eor_bp2_y(i+38) and								// and|ora|eor (:bp2),y			; 38
       sta_a(i+39) and										// sta					; 39
       iny(i+40) and										// iny					; 40
       lda_stack(i+41) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 41
//       and_ora_eor_bp2_y(i+42) and								// and|ora|eor (:bp2),y			; 42
       sta_a(i+43) then										// sta					; 43
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+9], 6, 256) = copy(listing[i+11], 6, 256)) and
        (copy(listing[i+13], 6, 256) = copy(listing[i+15], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+29], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+33], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+37], 6, 256)) and
	(copy(listing[i+15], 6, 256) = copy(listing[i+41], 6, 256)) then
       begin
	listing[i+24] := #9'sta :TMP';

	listing[i+27] := #9'sta :TMP+1';

	listing_tmp[0] := listing[i+16];
	listing_tmp[1] := listing[i+17];
	listing_tmp[2] := listing[i+18];
	listing_tmp[3] := listing[i+19];
	listing_tmp[4] := listing[i+20];
	listing_tmp[5] := listing[i+21];
	listing_tmp[6] := listing[i+22];
	listing_tmp[7] := listing[i+23];
	listing_tmp[8] := listing[i+24];
	listing_tmp[9] := listing[i+25];
	listing_tmp[10]:= listing[i+26];
	listing_tmp[11]:= listing[i+27];
	listing_tmp[12]:= listing[i+28];

	listing_tmp[13]:= listing[i+29];
	listing_tmp[14]:= listing[i+30];
	listing_tmp[15]:= copy(listing[i+2], 1, 5) + '(:TMP),y';
	listing_tmp[16]:= listing[i+31];
	listing_tmp[17]:= #9'iny';

	listing_tmp[18]:= listing[i+33];
	listing_tmp[19]:= listing[i+34];
	listing_tmp[20]:= copy(listing[i+6], 1, 5) + '(:TMP),y';
	listing_tmp[21]:= listing[i+35];
	listing_tmp[22]:= #9'iny';

	listing_tmp[23]:= listing[i+37];
	listing_tmp[24]:= listing[i+38];
	listing_tmp[25]:= copy(listing[i+10], 1, 5) + '(:TMP),y';
	listing_tmp[26]:= listing[i+39];
	listing_tmp[27]:= #9'iny';

	listing_tmp[28]:= listing[i+41];
	listing_tmp[29]:= listing[i+42];
	listing_tmp[30]:= copy(listing[i+14], 1, 5) + '(:TMP),y';
	listing_tmp[31]:= listing[i+43];

	for p:=0 to 31 do listing[i+p] := listing_tmp[p];

	listing[i+32] := '';
	listing[i+33] := '';
	listing[i+34] := '';
	listing[i+35] := '';
	listing[i+36] := '';
	listing[i+37] := '';
	listing[i+38] := '';
	listing[i+39] := '';
	listing[i+40] := '';
	listing[i+41] := '';
	listing[i+42] := '';
	listing[i+43] := '';

	exit(false);
       end;


    if sta_bp2_1(i+23) and									// sta :bp2+1				; 23

       and_ora_eor_bp2_y(i+38) and								// and|ora|eor (:bp2),y			; 38

       ldy(i) and (listing[i] = listing[i+24]) and						// ldy XXX				; 0
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       iny(i+6) and										// iny					; 6
       LDA_BP2_Y(i+7) and									// lda (:bp2),y				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       iny(i+9) and										// iny					; 9
       LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       lda_im_0(i+12) and									// lda #$00				; 12
       sta_stack(i+13) and									// sta :STACKORIGIN+STACKWIDTH+10	; 13
       lda_a(i+14) and										// lda OFFSET				; 14
       asl_a(i+15) and										// asl @				; 15
       rol_stack(i+16) and									// rol :STACKORIGIN+STACKWIDTH+10	; 16
       asl_a(i+17) and										// asl @				; 17
       rol_stack(i+18) and									// rol :STACKORIGIN+STACKWIDTH+10	; 18
       add_sub(i+19) and									// add|sub				; 19
       sta_bp2(i+20) and									// sta :bp2				; 20
       lda_a(i+21) and										// lda OFFSET+1				; 21
       adc_sbc_stack(i+22) and									// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 22
//       sta_bp2_1(i+23) and									// sta :bp2+1				; 23
//       ldy(i+24) and										// ldy XXX				; 24
       lda_stack(i+25) and									// lda :STACKORIGIN+9			; 25
       and_ora_eor_bp2_y(i+26) and 								// and|ora|eor (:bp2),y			; 26
       sta_a(i+27) and										// sta					; 27
       iny(i+28) and										// iny					; 28
       lda_stack(i+29) and									// lda :STACKORIGIN+STACKWIDTH+9	; 29
       and_ora_eor_bp2_y(i+30) and								// and|ora|eor (:bp2),y			; 30
       sta_a(i+31) and										// sta					; 31
       iny(i+32) and										// iny					; 32
       lda_stack(i+33) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 33
       and_ora_eor_bp2_y(i+34) and								// and|ora|eor (:bp2),y			; 34
       sta_a(i+35) and										// sta					; 35
       iny(i+36) and										// iny					; 36
       lda_stack(i+37) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 37
//       and_ora_eor_bp2_y(i+38) and								// and|ora|eor (:bp2),y			; 38
       sta_a(i+39) then										// sta					; 39
     if (copy(listing[i+2], 6, 256) = copy(listing[i+25], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+29], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+33], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+37], 6, 256)) then
       begin
	listing[i+20] := #9'sta :TMP';

	listing[i+23] := #9'sta :TMP+1';

	listing[i+25] := #9'lda (:bp2),y';
	listing[i+26] := copy(listing[i+26], 1, 5) + '(:TMP),y';

	listing[i+29] := #9'lda (:bp2),y';
	listing[i+30] := copy(listing[i+26], 1, 5) + '(:TMP),y';

	listing[i+33] := #9'lda (:bp2),y';
	listing[i+34] := copy(listing[i+26], 1, 5) + '(:TMP),y';

	listing[i+37] := #9'lda (:bp2),y';
	listing[i+38] := copy(listing[i+26], 1, 5) + '(:TMP),y';

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
	listing[i+10]:= '';
	listing[i+11]:= '';

	exit(false);
       end;


    if STA_BP2_Y(i+29) and									// sta (:bp2),y				; 29

       ldy(i) and (listing[i] = listing[i+18]) and						// ldy XXX				; 0
       LDA_BP2_Y(i+1) and									// lda (:bp2),y				; 1
       sta(i+2) and										// sta :STACKORIGIN+10			; 2
       iny(i+3) and										// iny					; 3
       LDA_BP2_Y(i+4) and									// lda (:bp2),y				; 4
       sta(i+5) and										// sta :STACKORIGIN+STACKWIDTH+10	; 5
       iny(i+6) and										// iny					; 6
       LDA_BP2_Y(i+7) and									// lda (:bp2),y				; 7
       sta(i+8) and										// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       iny(i+9) and										// iny					; 9
       LDA_BP2_Y(i+10) and									// lda (:bp2),y				; 10
       sta(i+11) and										// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda_a(i+12) and										// lda OFFSET				; 12
       add_sub(i+13) and									// add|sub				; 13
       sta_bp2(i+14) and									// sta :bp2				; 14
       lda_a(i+15) and										// lda OFFSET+1				; 15
       adc_sbc(i+16) and									// adc|sbc				; 16
       sta_bp2_1(i+17) and									// sta :bp2+1				; 17
//       ldy(i+18) and										// ldy XXX				; 18
       lda(i+19) and										// lda :STACKORIGIN+10			; 19
       STA_BP2_Y(i+20) and									// sta (:bp2),y				; 20
       iny(i+21) and										// iny					; 21
       lda(i+22) and										// lda :STACKORIGIN+STACKWIDTH+10	; 22
       STA_BP2_Y(i+23) and									// sta (:bp2),y				; 23
       iny(i+24) and										// iny					; 24
       lda(i+25) and										// lda :STACKORIGIN+STACKWIDTH*2+10	; 25
       STA_BP2_Y(i+26) and									// sta (:bp2),y				; 26
       iny(i+27) and										// iny					; 27
       lda(i+28) then										// lda :STACKORIGIN+STACKWIDTH*3+10	; 28
//       STA_BP2_Y(i+29) then									// sta (:bp2),y				; 29
     if (copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+25], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+28], 6, 256)) and

	(copy(listing[i+2], 6, 256) <> copy(listing[i+12], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+13], 6, 256)) then
       begin
	listing[i]   := listing[i+12];
	listing[i+1] := listing[i+13];
	listing[i+2] := #9'sta :TMP';
	listing[i+3] := listing[i+15];
	listing[i+4] := listing[i+16];
	listing[i+5] := #9'sta :TMP+1';

	listing[i+6]  := #9'ldy #$00';
	listing[i+7]  := #9'lda (:bp2),y';
	listing[i+8]  := #9'sta (:TMP),y';
	listing[i+9]  := #9'iny';
	listing[i+10] := #9'lda (:bp2),y';
	listing[i+11] := #9'sta (:TMP),y';
	listing[i+12] := #9'iny';
	listing[i+13] := #9'lda (:bp2),y';
	listing[i+14] := #9'sta (:TMP),y';
	listing[i+15] := #9'iny';
	listing[i+16] := #9'lda (:bp2),y';
	listing[i+17] := #9'sta (:TMP),y';

	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';
	listing[i+29] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+18) and									// sta (:bp2),y				; 18

       lda_a(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_a(i+6) and										// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_a(i+9) and										// lda					; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       mwy_bp2(i+12) and									// mwy  :bp2				; 12
       ldy_im(i+13) and										// ldy #				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+9			; 14
       STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15
       iny(i+16) and										// iny					; 16
       lda_stack(i+17) and									// lda :STACKORIGIN+STACKWIDTH+9	; 17
//       STA_BP2_Y(i+18) and									// sta (:bp2),y				; 18
       (iny(i+19) = false) then									//~iny					; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12

       lda_a(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       mwy_bp2(i+6) and										// mwy  :bp2				; 6
       ldy_im(i+7) and										// ldy #				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+9			; 8
       STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9
       iny(i+10) and										// iny					; 10
       lda_stack(i+11) then									// lda :STACKORIGIN+STACKWIDTH+9	; 11
//       STA_BP2_Y(i+12) then									// sta (:bp2),y				; 12
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing_tmp[0] := listing[i+6];
	listing_tmp[1] := listing[i+7];
	listing_tmp[2] := listing[i];
	listing_tmp[3] := listing[i+1];
	listing_tmp[4] := listing[i+9];
	listing_tmp[5] := listing[i+10];
	listing_tmp[6] := listing[i+3];
	listing_tmp[7] := listing[i+4];
	listing_tmp[8] := listing[i+9];

	for p:=0 to 8 do listing[i+p]:=listing_tmp[p];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


    if sta_bp_y(i+12) and									// sta (:bp),y				; 12

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       mwy_bp2(i+4) and										// mwy  :bp2				; 4
       ldy_im(i+5) and										// ldy #				; 5
       LDA_BP2_Y(i+6) and									// lda (:bp2),y				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+10			; 7
       ldy_stack(i+8) and									// ldy :STACKORIGIN+STACKWIDTH+9	; 8
       sty_bp_1(i+9) and									// sty :bp+1				; 9
       ldy_stack(i+10) and									// ldy :STACKORIGIN+9			; 10
       lda_stack(i+11) then									// lda :STACKORIGIN+10			; 11
//       sta_bp_y(i+12) then									// sta (:bp),y				; 12
     if (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+8]  := #9'ldy ' + copy(listing[i+2], 6, 256);

	listing[i+10] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       mwy_bp2(i+4) and										// mwy  :bp2				; 4
       ldy_im(i+5) and										// ldy #				; 5
       lda(i+6) and										// lda					; 6
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN+9		; 7
       STA_BP2_Y(i+8) and									// sta (:bp2),y				; 8
       iny(i+9) and										// iny					; 9
       lda(i+10) and										// lda 					; 10
       adc_sbc_stack(i+11) then									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 11
//       STA_BP2_Y(i+12) then									// sta (:bp2),y				; 12
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin

	if add_stack(i+7) then
 	 listing[i+7]  := #9'add ' + copy(listing[i], 6, 256)
	else
 	 listing[i+7]  := #9'sub ' + copy(listing[i], 6, 256);

	if adc_stack(i+11) then
 	 listing[i+11]  := #9'adc ' + copy(listing[i+2], 6, 256)
	else
 	 listing[i+11]  := #9'sbc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if sta_bp_y(i+16) and									// sta (:bp),y				; 16

       lda_a(i) and										// lda T				; 0
       add_sub(i+1) and										// add|sub Q				; 1
       tay(i+2) and										// tay					; 2
       lda_a(i+3) and										// lda T+1				; 3
       adc_sbc(i+4) and										// adc|sbc Q+1				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       lda_bp_y(i+6) and									// lda (:bp),y				; 6
       and_ora_eor(i+7) and									// and|ora|eor				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN			; 8
       lda(i+9) and										// lda T				; 9
       add_sub(i+10) and		 							// add|sub Q				; 10
       tay(i+11) and										// tay					; 11
       lda(i+12) and										// lda T+1				; 12
       adc_sbc(i+13) and									// adc|sbc Q+1				; 13
       sta_bp_1(i+14) and									// sta :bp+1				; 14
       lda_stack(i+15) then									// lda :STACKORIGIN			; 15
//       sta_bp_y(i+16) then									// sta (:bp),y				; 16
     if (copy(listing[i+8], 6, 256) = copy(listing[i+15], 6, 256)) and
        (listing[i] = listing[i+9]) and
        (listing[i+1] = listing[i+10]) and
        (listing[i+3] = listing[i+12]) and
        (listing[i+4] = listing[i+13]) then
       begin
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';
	listing[i+14]:= '';
	listing[i+15]:= '';

	exit(false);
       end;


    if sta_bp_1(i+12) and									// sta :bp+1				; 12

       lda_a(i) and										// lda T				; 0
       add_sub(i+1) and										// add|sub Q				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       tay(i+3) and										// tay					; 3
       lda_a(i+4) and										// lda T+1				; 4
       adc_sbc(i+5) and										// adc|sbc Q+1				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH+9	; 6
       sta_bp_1(i+7) and									// sta :bp+1				; 7
       lda_bp_y(i+8) and									// lda (:bp),y				; 8
       and_ora_eor(i+9) and									// ora|and|eor				; 9
       sta_stack(i+10) and									// sta :STACKORIGIN+10			; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH+9	; 11
//       sta_bp_1(i+12) and									// sta :bp+1				; 12
       ldy_stack(i+13) and									// ldy :STACKORIGIN+9			; 13
       lda_stack(i+14) then									// lda :STACKORIGI+10			; 14
     if (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+10], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+6] := '';

	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
       end;


    if sta_bp_y(i+10) and									// sta (:bp),y				; 10

       lda_a(i) and										// lda TB				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda TB+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       mwy_bp2(i+6) and										// mwy TB :bp2				; 6
       ldy(i+7) and										// ldy					; 7
       lda_bp2_y(i+8) and									// lda (:bp2),y				; 8
       ldy_stack(i+9) then									// ldy :STACKORIGIN			; 9
//       sta_bp_y(i+10) then									// sta (:bp),y				; 10
    if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) and
       (copy(listing[i], 6, 256) = GetString(i+6)) and
       (pos(listing[i], listing[i+3]) > 0) then
      begin
	listing[i+9] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+10]:= #9'sta (:bp2),y';

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_y(i+15) and									// sta (:bp),y				; 15

       lda_val(i) and (lda_im(i) = false) and							// lda OFS				; 0	~#
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN+9			; 2
       (listing[i+3] = listing[i] + '+1') and							// lda OFS+1				; 3	~#
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       ldy(i+6) and										// ldy TB+1				; 6
       sty_bp_1(i+7) and									// sty :bp+1				; 7
       ldy(i+8) and										// ldy TB				; 8
       lda_bp_y(i+9) and									// lda (:bp),y				; 9
       sta_stack(i+10) and									// sta :STACKORIGIN+10			; 10
       ldy_stack(i+11) and									// ldy :STACKORIGIN+STACKWIDTH+9	; 11
       sty_bp_1(i+12) and									// sty :bp+1				; 12
       ldy_stack(i+13) and									// ldy :STACKORIGIN+9			; 13
       lda_stack(i+14) then									// lda :STACKORIGIN+10			; 14
//       sta_bp_y(i+15) then									// sta (:bp),y				; 15
    if (listing[i+3] <> listing[i+6]) and
       (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) and
       (copy(listing[i+10], 6, 256) = copy(listing[i+14], 6, 256)) then
      begin
	listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := #9'ldy ' + copy(listing[i+1], 6, 256);

	listing[i+15] := #9'sta (:bp2),y';

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_y(i+15) and									// sta (:bp),y				; 15

       lda_val(i) and (lda_im(i) = false) and							// lda TB				; 0	~#
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN+9			; 2
       (listing[i+3] = listing[i] + '+1') and							// lda TB+1				; 3	~#
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       ldy(i+6) and										// ldy TB+1				; 6
       sty_bp_1(i+7) and									// sty :bp+1				; 7
       ldy(i+8) and										// ldy TB				; 8
       lda_bp_y(i+9) and									// lda (:bp),y				; 9
       sta_stack(i+10) and									// sta :STACKORIGIN+10			; 10
       ldy_stack(i+11) and									// ldy :STACKORIGIN+STACKWIDTH+9	; 11
       sty_bp_1(i+12) and									// sty :bp+1				; 12
       ldy_stack(i+13) and									// ldy :STACKORIGIN+9			; 13
       lda_stack(i+14) then									// lda :STACKORIGIN+10			; 14
//       sta_bp_y(i+15) then									// sta (:bp),y				; 15
    if (listing[i+3] = listing[i+6]) and
       (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) and
       (copy(listing[i+10], 6, 256) = copy(listing[i+14], 6, 256)) and
       (copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+11] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	listing[i+12] := #9'ldy #$00';
	listing[i+13] := #9'lda (:bp2),y';
	listing[i+14] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+15] := #9'sta (:bp2),y';

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


    if sta_bp_y(i+14) and									// sta (:bp),y				; 14

       lda_a(i) and										// lda TB				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and										// lda TB+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       mwy_bp2(i+6) and										// mwy TB :bp2				; 6
       ldy(i+7) and										// ldy					; 7
       lda_bp2_y(i+8) and									// lda (:bp2),y				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+10			; 9
       ldy_stack(i+10) and									// ldy :STACKORIGIN+STACKWIDTH+9	; 10
       sty_bp_1(i+11) and									// sty :bp+1				; 11
       ldy_stack(i+12) and									// ldy :STACKORIGIN+9			; 12
       lda_stack(i+13) then									// lda :STACKORIGIN+10			; 13
//       sta_bp_y(i+14) then									// sta (:bp),y				; 14
    if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
       (copy(listing[i+9], 6, 256) = copy(listing[i+13], 6, 256)) and
       (pos(listing[i], listing[i+3]) > 0) and
       (copy(listing[i], 6, 256) = GetString(i+6)) then
      begin
	listing[i+9]  := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+10] := #9'sta (:bp2),y';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_im(i) and										// lda #				; 0
       add(i+1) and (add_stack(i+1) = false) and						// add					; 1	~:STACKORIGIN
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im(i+3) and 										// lda #				; 3
       adc(i+4) and (adc_stack(i+4) = false) and						// adc 					; 4	~:STACKORIGIN
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and										// lda #				; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_im(i+9) and 										// lda #				; 9
       adc_stack(i+10) then									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) then									// sta :bp+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	 p := GetWORD(i, i+3) + GetWORD(i+6, i+9);

	 listing[i+6] := #9'lda #$' + IntToHex(byte(p),2);
	 listing[i+7] := listing[i+1];

	 listing[i+9] := #9'lda #$' + IntToHex(byte(p shr 8),2);
	 listing[i+10]:= listing[i+4];

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       add_im(i+1) and										// add #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       adc_im(i+4) and										// adc #				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and										// lda #				; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_im(i+9) and 										// lda #				; 9
       adc_stack(i+10) then									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) then									// sta :bp+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	 p := GetWORD(i+1, i+4) + GetWORD(i+6, i+9);

	 listing[i+6] := #9'lda #$' + IntToHex(byte(p),2);
	 listing[i+7] := #9'add ' + copy(listing[i], 6, 256);

	 listing[i+9] := #9'lda #$' + IntToHex(byte(p shr 8),2);
	 listing[i+10]:= #9'adc ' + copy(listing[i+3], 6, 256);

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_y(i+9) and 									// sta (:bp),y				; 9

       lda_im(i) and										// lda #				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_im(i+3) and 										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy(i+6) and										// ldy					; 6
       lda_a(i+7) and										// lda 					; 7
       ldy_stack(i+8) then 									// ldy :STACKORIGIN+10			; 8
//       sta_bp_y(i+9) then 									// sta (:bp),y				; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	 p := GetWORD(i, i+3);

	 listing[i+8] := #9'ldy ' + copy(listing[i+1], 6, 256);
	 listing[i+9] := #9'sta $' + IntToHex(p, 4) + ',y';

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_y(i+10) and 									// sta (:bp),y				; 10

       lda_im(i) and										// lda #				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_im(i+3) and 										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy(i+6) and										// ldy					; 6
       lda_a(i+7) and										// lda 					; 7
       (add_sub(i+8) or and_ora_eor(i+8)) and							// add|sub|and|ora|eor			; 8
       ldy_stack(i+9) then 									// ldy :STACKORIGIN+10			; 9
//       sta_bp_y(i+10) then 									// sta (:bp),y				; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	 p := GetWORD(i, i+3);

	 listing[i+9] := #9'ldy ' + copy(listing[i+1], 6, 256);
	 listing[i+10] := #9'sta $' + IntToHex(p, 4) + ',y';

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_1(i+6) and									// sta :bp+1				; 6

       sty_stack(i) and										// sty :STACKORIGIN+STACKWIDTH		; 0
       lda(i+1) and										// lda					; 1
       add_sub(i+2) and										// add|sub				; 2
       add_sub(i+3) and										// add|sub				; 3
       sta(i+4) and										// sta					; 4
       lda_stack(i+5) then									// lda :STACKORIGIN+STACKWIDTH		; 5
//       sta_bp_1(i+6) then									// sta :bp+1				; 6
    if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i] := #9'sty :bp+1';

	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
      end;


    if ldy_stack(i+7) and									// ldy :STACKORIGIN			; 7

       add_sub(i) and										// add|sub				; 0
       sta_stack(i+1) and 									// sta :STACKORIGIN			; 1
       lda(i+2) and										// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_bp_1(i+4) and									// sta :bp+1				; 4
       lda(i+5) and (iy(i+5) = false) and							// lda					; 5
       add_sub(i+6) then									// add|sub				; 6
//       ldy_stack(i+7) then									// ldy :STACKORIGIN			; 7
    if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+1] := #9'tay';

	listing[i+7] := '';

	exit(false);
      end;


    if sta_bp_y(i+10) and									// sta (:bp),y				; 10

       lda_im(i) and										// lda #				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_im(i+3) and 										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       mwy_bp2(i+6) and										// mwy .. :bp2				; 6
       ldy(i+7) and										// ldy 					; 7
       lda_bp2_y(i+8) and									// lda (:bp2),y				; 8
       ldy_stack(i+9) then									// ldy :STACKORIGIN+10			; 9
//       sta_bp_y(i+10) then									// sta (:bp),y				; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) then
       begin
	p := GetWORD(i, i+3);

	listing[i+9] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+10] := #9'sta $' + IntToHex(p, 4) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if sta_bp2_y(i+7) and									// sta (:bp2),y				; 7

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       mwy_bp2(i+4) and										// mwy   :bp2				; 4
       ldy(i+5) and										// ldy					; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
//       sta_bp2_y(i+7) and									// sta (:bp2),y				; 7
       (iny(i+8) = false) then									//~iny					; 8
    if (copy(listing[i], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_bp2_1(i+5) and									// sta :bp2+1				; 5

       lda_val(i) and (lda_im(i) = false) and (iy(i) = false) and				// lda TB				; 0	~#
       add_im(i+1) and 										// add #				; 1
       sta_bp2(i+2) and										// sta :bp2				; 2
       (listing[i+3] = listing[i] + '+1') and							// lda TB+1				; 3	~#
       adc_im_0(i+4) and									// adc #$00				; 4
//       sta_bp2_1(i+5) and									// sta :bp2+1				; 5
       ldy_im_0(i+6) then									// ldy #$00				; 6
      begin
        p:=GetBYTE(i+1);

	if p <= $FC then begin									// $FC, $FD, $FE, $FF

	 listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	 listing[i+1] := #9'ldy ' + copy(listing[i+1], 6, 256);
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';

	 exit(false);
	end;

      end;


    if sta_bp2_1(i+4) and									// sta :bp2+1				; 4

       lda_val(i) and (lda_im(i) = false) and (iy(i) = false) and				// lda TB				; 0	~#
       sta_bp2(i+1) and										// sta :bp2				; 1
       (listing[i+2] = listing[i] + '+1') and							// lda TB+1				; 2	~#
       add_im_0(i+3) and									// add #$00				; 3
//       sta_bp2_1(i+4) and									// sta :bp2+1				; 4
       ldy(i+5) then										// ldy					; 5
      begin
	listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if sta_bp2_1(i+3) and									// sta :bp2+1				; 3

       lda_val(i) and (lda_im(i) = false) and (iy(i) = false) and				// lda TB				; 0	~#
       sta_bp2(i+1) and										// sta :bp2				; 1
       (listing[i+2] = listing[i] + '+1') and							// lda TB+1				; 2	~#
//       sta_bp2_1(i+3) and									// sta :bp2+1				; 3
       ldy(i+4) then										// ldy					; 4
      begin
	listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_bp2_1(i+3) and									// sta :bp2+1				; 3

       lda_adr(i) and (iy(i) = false) and							// lda adr.				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda_adr(i+2) and (iy(i+2) = false) and							// lda adr.  +1				; 2
//       sta_bp2_1(i+3) and									// sta :bp2+1				; 3
       ldy(i+4) then										// ldy					; 4
//     if pos(listing[i], listing[i+2]) > 0 then
      begin
	listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_val(i) and (lda_im(i) = false) and (iy(i) = false) and				// lda TB				; 0
       (listing[i+1] = #9'sta :TMP') and							// sta :TMP				; 1
       (listing[i+2] = listing[i] + '+1') and							// lda TB+1				; 2
       (listing[i+3] = #9'sta :TMP+1') and							// sta :TMP				; 3
       ldy(i+4) then										// ldy					; 4
      begin
	listing[i] := #9'mwy ' + copy(listing[i], 6, 256) + ' :TMP';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if ldy_val(i) and (ldy_im(i) = false) and							// ldy P				; 0	~#
       lda_val(i+1) and (lda_im(i+1) = false) and						// lda P+1				; 1	~#
       sta_bp_1(i+2) and									// sta :bp+1				; 2
       lda_bp_y(i+3) and									// lda (:bp),y				; 3
       mwy_bp2(i+4) then									// mwy  :bp2				; 4	!!!
     if (copy(listing[i], 6, 256) = GetString(i+4)) and
        (#9'lda ' + copy(listing[i], 6, 256) + '+1' = listing[i+1]) then
      begin
	listing[i]   := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	listing[i+1] := #9'ldy #$00';
	listing[i+2] := #9'lda (:bp2),y';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_bp2_y(i+8) and									// sta (:bp2),y				; 8

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       tay(i+1) and 										// tay					; 1
       lda(i+2) and										// lda					; 2
       sta_bp2(i+3) and										// sta :bp2				; 3
       lda(i+4) and										// lda					; 4
       sta_bp2_1(i+5) and									// sta :bp2+1				; 5
       ldy(i+6) and										// ldy					; 6
       lda_stack(i+7) then									// lda :STACKORIGIN			; 7
//       sta_bp2_y(i+8) then									// sta (:bp2),y				; 8
    if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i] := '';

	listing[i+7] := listing[i+6];
	listing[i+6] := #9'tya';

	exit(false);
      end;


    if lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       mwy_bp2(i+2) and										// mwy  :bp2				; 2
       ldy(i+3) and										// ldy X				; 3
       lda_bp2_y(i+4) and									// lda (:bp2),y				; 4
       ldy_stack(i+5) then									// ldy :STACKORIGIN			; 5
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
	listing[i+5] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if LDA_BP2_Y(i+9) and									// lda (:bp2),y				; 9

       LDA_BP2_Y(i) and										// lda (:bp2),y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       iny(i+2) and										// iny					; 2
       LDA_BP2_Y(i+3) and									// lda (:bp2),y				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+10	; 4
       iny(i+5) and										// iny					; 5
       LDA_BP2_Y(i+6) and									// lda (:bp2),y				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 7
       iny(i+8) and										// iny					; 8
//       LDA_BP2_Y(i+9) and									// lda (:bp2),y				; 9
       sta_stack(i+10) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+9			; 11
       add_stack(i+12) and									// add :STACKORIGIN+10			; 12
       sta_a(i+13) and										// sta X				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH+9	; 14
       adc_stack(i+15) and									// adc :STACKORIGIN+STACKWIDTH+10	; 15
       sta_a(i+16) and										// sta X+1				; 16
       lda_stack(i+17) and									// lda :STACKORIGIN+STACKWIDTH*2+9	; 17
       adc_stack(i+18) and									// adc :STACKORIGIN+STACKWIDTH*2+10	; 18
       sta_a(i+19) and										// sta X+2				; 19
       lda_stack(i+20) and									// lda :STACKORIGIN+STACKWIDTH*3+9	; 20
       adc_stack(i+21) and									// adc :STACKORIGIN+STACKWIDTH*3+10	; 21
       sta_a(i+22) then										// sta X+3				; 22
     if (copy(listing[i+1], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) and
	(copy(listing[i+10], 6, 256) = copy(listing[i+21], 6, 256)) then
       begin

	 listing[i+12] := #9'add (:bp2),y+';
	 listing[i+15] := #9'adc (:bp2),y+';
	 listing[i+18] := #9'adc (:bp2),y+';
	 listing[i+21] := #9'adc (:bp2),y';

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

	 exit(false);
	end;


    if sta_bp2_1(i+15) and									// sta :bp2+1				; 15

       lda(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda(i+6) and										// lda					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda(i+9) and										// lda					; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+9			; 12
       sta_bp2(i+13) and									// sta :bp2				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH+9	; 14
//       sta_bp2_1(i+15) and									// sta :bp2+1				; 15
       ldy_im_0(i+16) then									// ldy #$00				; 16
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+2] := listing[i+13];
	listing[i+5] := listing[i+15];

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

	exit(false);
       end;


    if STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12

       lda(i) and										// lda					; 0
       add_stack(i+1) and									// add :STACKORIGIN+10			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda(i+3) and										// lda					; 3
       adc_stack(i+4) and									// adc :STACKORIGIN+STACKWIDTH+10	; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       mwy_bp2(i+6) and										// mwy xxx bp2				; 6
       ldy(i+7) and										// ldy					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+9			; 8
       STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9
       iny(i+10) and										// iny 					; 10
       lda_stack(i+11) then									// lda :STACKORIGIN+STACKWIDTH+9 	; 11
//       STA_BP2_Y(i+12) then									// sta (:bp2),y				; 12
     if {(copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and}
	(copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) and
	{(copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and}
	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin

	listing_tmp[0]  := listing[i+6];
	listing_tmp[1]  := listing[i+7];
	listing_tmp[2]  := listing[i];
	listing_tmp[3]  := listing[i+1];
	listing_tmp[4]  := listing[i+9];
	listing_tmp[5]  := listing[i+10];
	listing_tmp[6]  := listing[i+3];
	listing_tmp[7]  := listing[i+4];
	listing_tmp[8]  := listing[i+12];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];
	listing[i+5] := listing_tmp[5];
	listing[i+6] := listing_tmp[6];
	listing[i+7] := listing_tmp[7];
	listing[i+8] := listing_tmp[8];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


    if LDA_BP2_Y(i) and										// lda (:bp2),y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       iny(i+2) and										// iny					; 2
       LDA_BP2_Y(i+3) and									// lda (:bp2),y				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+9	; 4
       lda_a(i+5) and										// lda 					; 5
       add_stack(i+6) and									// add :STACKORIGIN+9			; 6
       sta_a(i+7) and										// sta					; 7
       lda_a(i+8) and										// lda 					; 8
       adc_stack(i+9) and									// adc :STACKORIGIN+STACKWIDTH+9	; 9
       sta_a(i+10) then										// sta					; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then
	begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';

	  listing[i+4] := listing[i+5];
	  listing[i+5] := #9'add (:bp2),y';
	  listing[i+6] := #9'iny';

	  listing[i+9] := #9'adc (:bp2),y';

	  exit(false);
	end;


    if LDA_BP2_Y(i) and										// lda (:bp2),y				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       iny(i+2) and										// iny					; 2
       LDA_BP2_Y(i+3) and									// lda (:bp2),y				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+9	; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+9			; 5
       add(i+6) and										// add					; 6
       sta_a(i+7) and										// sta					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH+9	; 8
       adc(i+9) and										// adc					; 9
       sta_a(i+10) then										// sta					; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
	begin
	  listing[i+1] := '';

	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';

	  listing[i+8] := listing[i];

	  exit(false);
	end;


// -----------------------------------------------------------------------------


    if sta_bp_1(i+1) and									// sta :bp+1				; 1

       lda(i) and (iy(i) = false) and								// lda					; 0
//       sta_bp_1(i+1) and									// sta :bp+1				; 1
       ldy(i+2) and										// ldy 					; 2
       LDA_STA_BP(i+3) then									// lda (:bp),y|lda			; 3
        											// sta        |sta (:bp),y		; 4
      begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'sty :bp+1';

	exit(false);
      end;


    if sty_bp_1(i+5) and									// sty :bp+1				; 5

       mwy_bp2(i) and										// mwy  :bp2				; 0	!!!
       ldy(i+1) and										// ldy					; 1
       lda_bp2_y(i+2) and									// lda (:bp2),y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       ldy_val(i+4) and										// ldy S+1				; 4	~:STACKORIGIN
//       sty_bp_1(i+5) and									// sty :bp+1				; 5
       ldy_val(i+6) and										// ldy S				; 6	~:STACKORIGIN
       LDA_STA_BP(i+7) then									// lda        |lda (:bp),y		; 7
					 							// sta (:bp),y|sta			; 8
     if (copy(listing[i+6], 6, 256) = GetString(i)) and
        (listing[i+6] + '+1' = listing[i+4]) then
      begin
	listing[i+4] := listing[i];
	listing[i+5] := #9'ldy #$00';
	listing[i+6] := '';

	if lda_bp_y(i+7) then listing[i+7] := #9'lda (:bp2),y';
	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_a(i) and (listing[i] = listing[i+8]) and						// lda TB				; 0
       add(i+1) and (listing[i+1] = listing[i+9]) and						// add POS				; 1
       tay(i+2) and 										// tay					; 2
       lda_a(i+3) and (listing[i+3] = listing[i+11]) and					// lda TB+1				; 3
       adc(i+4) and (listing[i+4] = listing[i+12]) and						// adc POS+1				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       LDA_STA_BP(i+6) and									// lda        |lda (:bp),y		; 6
					 							// sta (:bp),y|sta			; 7
//       lda_a(i+8) and										// lda TB				; 8
//       add(i+9) and										// add POS				; 9
       sta_bp2(i+10) and									// sta :bp2				; 10
//       lda_a(i+11) and									// lda TB+1				; 11
//       adc(i+12) and										// adc POS+1				; 12
       sta_bp2_1(i+13) then									// sta :bp2+1				; 13
      begin
	listing[i]   := listing[i+8];
	listing[i+1] := listing[i+9];
	listing[i+2] := listing[i+10];
	listing[i+3] := listing[i+11];
	listing[i+4] := listing[i+12];
	listing[i+5] := listing[i+13];

	listing[i+8] := listing[i+7];
	listing[i+7] := listing[i+6];

	if lda_bp_y(i+7) then listing[i+7] := #9'lda (:bp2),y';
	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';

	listing[i+6] := #9'ldy #$00';

	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_val(i) and (lda_im(i) = false) and (iy(i) = false) and				// lda TB				; 0	~#
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN			; 2
       (listing[i+3] = listing[i] + '+1') and							// lda TB+1				; 3	~#
       adc_im_0(i+4) and									// adc #$00				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) and									// ldy :STACKORIGIN			; 6
       LDA_STA_BP(i+7) then									// lda        |lda (:bp),y		; 7
					 							// sta (:bp),y|sta			; 8
    if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i]   := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
	listing[i+1] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	if lda_bp_y(i+7) then listing[i+7] := #9'lda (:bp2),y';
	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       (pos(#9'lda <', listing[i]) > 0)  and							// lda <TB				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN+9			; 2
       (pos(#9'lda >', listing[i+3]) > 0)  and							// lda >TB				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) and									// ldy :STACKORIGIN+9			; 6
       LDA_STA_BP(i+7) then									// lda        |lda (:bp),y		; 7
					 							// sta (:bp),y|sta			; 8
    if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i]   := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2';
	listing[i+1] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	if lda_bp_y(i+7) then listing[i+7] := #9'lda (:bp2),y';
	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_im(i) and										// lda #				; 0
       add_im(i+1) and	 									// add #				; 1
       tay(i+2) and										// tay					; 2
       lda_im(i+3) and										// lda #				; 3
       adc_im(i+4) and										// adc #				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       LDA_STA_BP(i+6) then									// lda        |lda (:bp),y		; 6
					 							// sta (:bp),y|sta			; 7
      begin
        p := GetWORD(i, i+3) + GetWORD(i+1, i+4);

	if lda_bp_y(i+6) then listing[i+6] := #9'lda $' + IntToHex(p, 4);
	if sta_bp_y(i+7) then listing[i+7] := #9'sta $' + IntToHex(p, 4);

	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_im(i) and										// lda #				; 0
       add(i+1) and (add_stack(i+1) = false) and						// add					; 1
       tay(i+2) and										// tay					; 2
       lda_im(i+3) and										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       LDA_STA_BP(i+6) then									// lda        |lda (:bp),y		; 6
					 							// sta (:bp),y|sta			; 7
      begin
        p := GetWORD(i, i+3);

	if lda_bp_y(i+6) then listing[i+6] := #9'lda $' + IntToHex(p, 4) + ',y';
	if sta_bp_y(i+7) then listing[i+7] := #9'sta $' + IntToHex(p, 4) + ',y';

	listing[i]  := '';
	listing[i+1]:= #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	exit(false);
      end;


    if sta_bp_1(i+2) and									// sta :bp+1				; 2

       ldy_im(i) and										// ldy #				; 0
       lda_im(i+1) and										// lda #				; 1
//       sta_bp_1(i+2) and									// sta :bp+1				; 2
       LDA_STA_BP(i+3) then									// lda        |lda (:bp),y		; 3
					 							// sta (:bp),y|sta			; 4
      begin
        p := GetWORD(i, i+1);

	if lda_bp_y(i+3) then listing[i+3] := #9'lda $' + IntToHex(p, 4);
	if sta_bp_y(i+4) then listing[i+4] := #9'sta $' + IntToHex(p, 4);

	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';

	exit(false);
       end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_im(i) and										// lda #				; 0
       add(i+1) and (iy(i+1) = false) and							// add C				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im(i+3) and										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and										// lda #				; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_im(i+9) and										// lda #				; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
        p := GetWORD(i, i+3) + GetWORD(i+6, i+9);

	listing[i+11] := #9'ldy ' + copy(listing[i+1], 6, 256);

	if lda_bp_y(i+12) then listing[i+12] := #9'lda $' + IntToHex(p, 4) + ',y';
	if sta_bp_y(i+13) then listing[i+13] := #9'sta $' + IntToHex(p, 4) + ',y';

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
	listing[i+10]:= '';

	exit(false);
      end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda 					; 0
       (add_im(i+1) or sub(i+1)) and								// add #|sub #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       (adc_im(i+4) or sbc_im(i+4)) and								// adc #|sbc #				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and										// lda #				; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_im(i+9) and										// lda #				; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin

        if add_im(i+1) then
         p := GetWORD(i+1, i+4) + GetWORD(i+6, i+9)
	else
         p := GetWORD(i+6, i+9) - GetWORD(i+1, i+4);

	listing[i+11] := #9'ldy ' + copy(listing[i], 6, 256);

	if lda_bp_y(i+12) then listing[i+12] := #9'lda $' + IntToHex(p, 4) + ',y';
	if sta_bp_y(i+13) then listing[i+13] := #9'sta $' + IntToHex(p, 4) + ',y';

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
	listing[i+10]:= '';

	exit(false);
      end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda O				; 0
       add(i+1) and (iy(i+1) = false) and							// add C				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and (lda_im(i+3) = false) and (iy(i+3) = false) and				// lda O+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_im_0(i+9) and									// lda #$00				; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+11] := #9'ldy ' + copy(listing[i+1], 6, 256);

	listing[i+1] := #9'sta :bp2';
	listing[i+2] := '';

	listing[i+4] := #9'sta :bp2+1';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';

	if lda_bp_y(i+12) then listing[i+12] := #9'lda (:bp2),y';
	if sta_bp_y(i+13) then listing[i+13] := #9'sta (:bp2),y';

	exit(false);
      end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda O				; 0
       add(i+1) and (iy(i+1) = false) and							// add C				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and (lda_im(i+3) = false) and (iy(i+3) = false) and				// lda O+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_val(i+6) and (lda_im_0(i+6) = false) and						// lda|~#$00				; 6	~:STACKORIGIN
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+7] := #9'add ' + copy(listing[i], 6, 256);

	listing[i+10] := #9'adc ' + copy(listing[i+3], 6, 256);

	listing[i+5] := listing[i+6];
	listing[i+6] := listing[i+7];
	listing[i+7] := #9'sta :bp2';
	listing[i+8] := listing[i+9];
	listing[i+9] := listing[i+10];
	listing[i+10] := #9'sta :bp2+1';

	listing[i+11] := #9'ldy ' + copy(listing[i+1], 6, 256);

	if lda_bp_y(i+12) then listing[i+12] := #9'lda (:bp2),y';
	if sta_bp_y(i+13) then listing[i+13] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_a(i) and (lda_im(i) = false) and							// lda					; 0	~#
       add(i+1) and										// add					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and (lda_im(+3) = false) and							// lda					; 3	~#
       adc(i+4) and										// adc					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_val(i+6) and (lda_im_0(i+6) = false) and						// lda|~#$00				; 6	~:STACKORIGIN
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_im_0(i+9) and									// lda #$00				; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+2] := #9'sta :bp2';

	listing[i+5] := #9'sta :bp2+1';
	listing[i+6] := #9'ldy ' + copy(listing[i+6], 6, 256);
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	if lda_bp_y(i+12) then listing[i+12] := #9'lda (:bp2),y';
	if sta_bp_y(i+13) then listing[i+13] := #9'sta (:bp2),y';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda(i) and (iy(i) = false) and								// lda 					; 0
       add_sub_im(i+1) and									// add|sub #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_sbc_im(i+4) and									// adc|sbc #				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) and									// ldy :STACKORIGIN			; 6
       LDA_STA_BP(i+7) then									// lda        |lda (:bp),y		; 7
					 							// sta (:bp),y|sta			; 8
     if copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256) then
      begin
        p := GetWORD(i+1, i+4);

	if sub_im(i+1) then p := word(-p);

	listing[i+6] := #9'ldy ' + copy(listing[i], 6, 256);

	if lda_bp_y(i+7) then listing[i+7] := #9'lda $' + IntToHex(p, 4) + ',y';
	if sta_bp_y(i+8) then listing[i+8] := #9'sta $' + IntToHex(p, 4) + ',y';

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_1(i+4) and									// sta :bp+1				; 4

       add_im(i) and										// add #				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda_im(i+2) and										// lda #				; 2
       adc_im_0(i+3) and									// adc #$00				; 3
//       sta_bp_1(i+4) and									// sta :bp+1				; 4
       ldy_stack(i+5) and									// ldy :STACKORIGIN+10			; 5
       LDA_STA_BP(i+6) then									// lda        |lda (:bp),y		; 6
					 							// sta (:bp),y|sta			; 7
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
        p := GetWORD(i, i+2);

	listing[i] := #9'tay';

	if lda_bp_y(i+6) then listing[i+6] := #9'lda $' + IntToHex(p, 4) + ',y';
	if sta_bp_y(i+7) then listing[i+7] := #9'sta $' + IntToHex(p, 4) + ',y';

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_im(i) and										// lda #				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_im(i+3) and 										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
//       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) and									// ldy :STACKORIGIN+10			; 6
       LDA_STA_BP(i+7) then									// lda        |lda (:bp),y		; 7
					 							// sta (:bp),y|sta			; 8
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	 p := GetWORD(i, i+3);

	 listing[i+6] := #9'ldy ' + copy(listing[i+1], 6, 256);

	 if lda_bp_y(i+7) then listing[i+7] := #9'lda $' + IntToHex(p, 4) + ',y';
	 if sta_bp_y(i+8) then listing[i+8] := #9'sta $' + IntToHex(p, 4) + ',y';

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if lda_bp_y(i+7) and 									// lda (:bp),y				; 7

       lda_im(i) and										// lda #				; 0
       add(i+1) and (iy(i+1) = false) and							// add					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im(i+3) and 										// lda #				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp_1(i+5) and									// sta :bp+1				; 5
       ldy_stack(i+6) and 									// ldy :STACKORIGIN			; 6
//       lda_bp_y(i+7) and 									// lda (:bp),y				; 7
       (add_sub_val(i+8) or and_ora_eor_val(i+8)) and						// add|sub|and|ora|eor			; 8
       sta_a(i+9) then										// sta					; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin   
	 p := GetWORD(i, i+3);

	 listing[i+6] := #9'ldy ' + copy(listing[i+1], 6, 256);
	 listing[i+7] := #9'lda $' + IntToHex(p, 4) + ',y';

	 if sta_bp_y(i+9) then listing[i+9] := #9'sta $' + IntToHex(p, 4) + ',y';

	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_im(i) and										// lda #				; 0
       add(i+1) and (add_stack(i+1) = false) and (add_im(i+1) = false) and			// add					; 1	~:STACKORIGIN
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_val(i+6) and (lda_im(i+6) = false) and						// lda					; 6	~#
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_val(i+9) and 									// lda					; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
         listing[i+5] := listing[i+6];
	 listing[i+6] := #9'add ' + copy(listing[i+1], 6, 256);
	 listing[i+7] := #9'sta :bp2';
	 listing[i+8] := listing[i+9];
	 listing[i+9] := #9'adc #$00';
	 listing[i+10]:= #9'sta :bp2+1';
	 listing[i+11]:= #9'ldy ' + copy(listing[i], 6, 256);

	 if lda_bp_y(i+12) then listing[i+12] := #9'lda (:bp2),y';
	 if sta_bp_y(i+13) then listing[i+13] := #9'sta (:bp2),y';

	 listing[i]  := '';
	 listing[i+1]:= '';
	 listing[i+2]:= '';
	 listing[i+3]:= '';
	 listing[i+4]:= '';

	 exit(false);
       end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_val(i) and (lda_im(i) = false) and							// lda					; 0	~#
       add_im(i+1) and										// add #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_val(i+6) and (lda_im(i+6) = false) and						// lda					; 6	~#
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_val(i+9) and 									// lda					; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
         listing[i+5] := listing[i+6];
	 listing[i+6] := #9'add ' + copy(listing[i], 6, 256);
	 listing[i+7] := #9'sta :bp2';
	 listing[i+8] := listing[i+9];
	 listing[i+9] := #9'adc #$00';
	 listing[i+10]:= #9'sta :bp2+1';
	 listing[i+11]:= #9'ldy ' + copy(listing[i+1], 6, 256);

	 if lda_bp_y(i+12) then listing[i+12] := #9'lda (:bp2),y';
	 if sta_bp_y(i+13) then listing[i+13] := #9'sta (:bp2),y';

	 listing[i]  := '';
	 listing[i+1]:= '';
	 listing[i+2]:= '';
	 listing[i+3]:= '';
	 listing[i+4]:= '';

	 exit(false);
       end;


    if sta_bp_1(i+11) and									// sta :bp+1				; 11

       lda_val(i) and (lda_im(i) = false) and							// lda					; 0
       sub_im(i+1) and										// sub #				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_im_0(i+3) and									// lda #$00				; 3
       sbc_im_0(i+4) and									// sbc #$00				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_val(i+6) and										// lda					; 6
       add_stack(i+7) and									// add :STACKORIGIN			; 7
       tay(i+8) and										// tay					; 8
       lda_val(i+9) and 									// lda					; 9
       adc_stack(i+10) and									// adc :STACKORIGIN+STACKWIDTH		; 10
//       sta_bp_1(i+11) and									// sta :bp+1				; 11
       LDA_STA_BP(i+12) then									// lda        |lda (:bp),y		; 12
					 							// sta (:bp),y|sta			; 13
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
         listing[i+5] := listing[i+6];
	 listing[i+6] := listing[i+1];
	 listing[i+7] := #9'sta :bp2';
	 listing[i+8] := listing[i+9];
	 listing[i+9] := #9'sbc #$00';
	 listing[i+10]:= #9'sta :bp2+1';
	 listing[i+11]:= #9'ldy ' + copy(listing[i], 6, 256);

	 if lda_bp_y(i+12) then listing[i+12] := #9'lda (:bp2),y';
	 if sta_bp_y(i+13) then listing[i+13] := #9'sta (:bp2),y';

	 listing[i]  := '';
	 listing[i+1]:= '';
	 listing[i+2]:= '';
	 listing[i+3]:= '';
	 listing[i+4]:= '';

	 exit(false);
       end;


    if sta_bp_1(i+4) and									// sta :bp+1				; 4

       add_sub(i) and (iy(i) = false) and (add_sub_im(i) = false) and				// add|sub				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and (iy(i+2) = false) and							// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
//       sta_bp_1(i+4) and									// sta :bp+1				; 4
       ldy_stack(i+5) and 									// ldy :STACKORIGIN+10			; 5
       LDA_STA_BP(i+6) then									// lda        |lda (:bp),y		; 6
					 							// sta (:bp),y|sta			; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+1]  := #9'tay';
	listing[i+5]  := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if STA_BP2_Y(i+29) and									// sta (:bp2),y				; 29

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda YR				; 0	cardinal
       add_sub(i+1) and (iy(i+1) = false) and							// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and										// lda YR+1				; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_a(i+6) and										// lda YR+2				; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_a(i+9) and										// lda YR+3				; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda_a(i+12) and										// lda FLOODFILLSTACK			; 12
       add_sub(i+13) and									// add|sub				; 13
       sta_bp2(i+14) and									// sta :bp2				; 14
       lda_a(i+15) and										// lda FLOODFILLSTACK+1			; 15
       adc_sbc(i+16) and									// adc|sbc				; 16
       sta_bp2_1(i+17) and									// sta :bp2+1				; 17
       ldy_im_0(i+18) and									// ldy #$00				; 18
       lda_stack(i+19) and									// lda :STACKORIGIN+10			; 19
       STA_BP2_Y(i+20) and									// sta (:bp2),y				; 20
       iny(i+21) and										// iny					; 21
       lda_stack(i+22) and									// lda :STACKORIGIN+STACKWIDTH+10	; 22
       STA_BP2_Y(i+23) and									// sta (:bp2),y				; 23
       iny(i+24) and										// iny					; 24
       lda_stack(i+25) and									// lda :STACKORIGIN+STACKWIDTH*2+10	; 25
       STA_BP2_Y(i+26) and									// sta (:bp2),y				; 26
       iny(i+27) and										// iny					; 27
       lda_stack(i+28) then									// lda :STACKORIGIN+STACKWIDTH*3+10	; 28
//       STA_BP2_Y(i+29) then									// sta (:bp2),y				; 29
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+13], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+22], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+25], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+28], 6, 256)) then

       begin

	listing_tmp[0] := listing[i+12];
	listing_tmp[1] := listing[i+13];
	listing_tmp[2] := listing[i+14];
	listing_tmp[3] := listing[i+15];
	listing_tmp[4] := listing[i+16];
	listing_tmp[5] := listing[i+17];
	listing_tmp[6] := listing[i+18];

	listing_tmp[7] := listing[i];
	listing_tmp[8] := listing[i+1];
	listing_tmp[9] := #9'sta (:bp2),y';
	listing_tmp[10] := #9'iny';

	listing_tmp[11] := listing[i+3];
	listing_tmp[12] := listing[i+4];
	listing_tmp[13] := #9'sta (:bp2),y';
	listing_tmp[14] := #9'iny';

	listing_tmp[15] := listing[i+6];
	listing_tmp[16] := listing[i+7];
	listing_tmp[17] := #9'sta (:bp2),y';
	listing_tmp[18] := #9'iny';

	listing_tmp[19] := listing[i+9];
	listing_tmp[20] := listing[i+10];
	listing_tmp[21] := #9'sta (:bp2),y';

	for p:=0 to 21 do listing[i+p] := listing_tmp[p];

	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';
	listing[i+28] := '';
	listing[i+29] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+17) and									// sta (:bp2),y				; 17

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda					; 0	word
       add_sub(i+1) and (iy(i+1) = false) and							// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_a(i+6) and										// lda OFFSET				; 6
       add_sub(i+7) and										// add|sub				; 7
       sta_bp2(i+8) and										// sta :bp2				; 8
       lda_a(i+9) and										// lda OFFSET+1				; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_bp2_1(i+11) and									// sta :bp2+1				; 11
       ldy_im_0(i+12) and									// ldy #$00				; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+10			; 13
       STA_BP2_Y(i+14) and									// sta (:bp2),y				; 14
       iny(i+15) and										// iny					; 15
       lda_stack(i+16) then									// lda :STACKORIGIN+STACKWIDTH+10	; 16
//       STA_BP2_Y(i+17) then									// sta (:bp2),y				; 17
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+7], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) then
       begin
	listing_tmp[0] := listing[i+6];
	listing_tmp[1] := listing[i+7];
	listing_tmp[2] := listing[i+8];
	listing_tmp[3] := listing[i+9];
	listing_tmp[4] := listing[i+10];
	listing_tmp[5] := listing[i+11];

	listing_tmp[6] := #9'ldy #$00';
	listing_tmp[7] := listing[i];
	listing_tmp[8] := listing[i+1];
	listing_tmp[9] := listing[i+2];
	listing_tmp[10]:= #9'sta (:bp2),y';

	listing_tmp[11]:= #9'iny';
	listing_tmp[12]:= listing[i+3];
	listing_tmp[13]:= listing[i+4];
	listing_tmp[14]:= listing[i+5];
	listing_tmp[15]:= #9'sta (:bp2),y';

	for p:=0 to 15 do listing[i+p] := listing_tmp[p];

	listing[i+16] := '';
	listing[i+17] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15

       lda(i) and (iy(i) = false) and								// lda YR				; 0	opt_099
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and (iy(i+2) = false) and							// lda YR+1				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and										// lda FLOODFILLSTACK			; 4
       add(i+5) and										// add :STACKORIGIN+9			; 5
       sta_bp2(i+6) and										// sta :bp2				; 6
       lda(i+7) and										// lda FLOODFILLSTACK+1			; 7
       adc(i+8) and										// adc :STACKORIGIN+STACKWIDTH+9	; 8
       sta_bp2_1(i+9) and									// sta :bp2+1				; 9
       ldy_im_0(i+10) and									// ldy #$00				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+10			; 11
       STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and										// iny					; 13
       lda_stack(i+14) then									// lda :STACKORIGIN+STACKWIDTH+10	; 14
//       STA_BP2_Y(i+15) then									// sta (:bp2),y				; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+11] := listing[i];
	listing[i+14] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15

       lda(i) and (iy(i) = false) and								// lda XR				; 0	opt_100
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 1
       lda(i+2) and (iy(i+2) = false) and							// lda XR+1				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 3
       lda(i+4) and										// lda FLOODFILLSTACK			; 4
       add(i+5) and										// add :STACKORIGIN+9			; 5
       sta_bp2(i+6) and										// sta :bp2				; 6
       lda(i+7) and										// lda FLOODFILLSTACK+1			; 7
       adc(i+8) and										// adc :STACKORIGIN+STACKWIDTH+9	; 8
       sta_bp2_1(i+9) and									// sta :bp2+1				; 9
       ldy_im_0(i+10) and									// ldy #$00				; 10
       lda(i+11) and										// lda YR				; 11
       STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and										// iny					; 13
       lda(i+14) and										// lda YR+1				; 14
//       STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15
       iny(i+16) and										// iny					; 16
       lda_stack(i+17) and									// lda :STACKORIGIN+STACKWIDTH*2+10	; 17
       STA_BP2_Y(i+18) and									// sta (:bp2),y				; 18
       iny(i+19) and										// iny					; 19
       lda_stack(i+20) and									// lda :STACKORIGIN+STACKWIDTH*3+10	; 20
       STA_BP2_Y(i+21) then									// sta (:bp2),y				; 21
     if (copy(listing[i+1], 6, 256) = copy(listing[i+17], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+20], 6, 256)) then
	begin
	listing[i+17] := listing[i];
	listing[i+20] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
	end;


    if STA_BP2_Y(i+15) and									// sta (:bp2),y				; 15

       mwy_bp2(i) and mwy_bp2(i+9) and								// mwy ...	:bp2			; 0
       ldy(i+1) and										// ldy #XX				; 1
       LDA_BP2_Y(i+2) and									// lda (:bp2),y				; 2
       iny(i+3) and										// iny					; 3
       add_sub(i+4) and										// add #$01				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+9			; 5
       LDA_BP2_Y(i+6) and									// lda (:bp2),y				; 6
       adc_sbc(i+7) and										// adc #$00				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH+9	; 8
       												// mwy ...	:bp2			; 9
       ldy(i+10) and										// ldy #XX				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+9			; 11
       STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and										// iny					; 13
       lda_stack(i+14) then									// lda :STACKORIGIN+STACKWIDTH+9	; 14
//       STA_BP2_Y(i+15) then									// sta (:bp2),y				; 15
     if (listing[i] = listing[i+9]) and
     	(listing[i+1] = listing[i+10]) and
     	(copy(listing[i+5], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+3] := listing[i+4];
	listing[i+4] := listing[i+12];
	listing[i+5] := listing[i+13];

	listing[i+8] := listing[i+12];

	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if LDA_BP2_Y(i+8) and									// lda (:bp2),y				; 8

       lda_im(i) and										// lda #				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda_im(i+2) and										// lda #				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1				; 3
       ldy_im_0(i+4) and									// ldy #$00				; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       sta(i+6) and (iy(i+6) = false) and							// sta					; 6
       iny(i+7) and 										// iny					; 7
//       LDA_BP2_Y(i+8) and									// lda (:bp2),y				; 8
       sta(i+9) and (iy(i+9) = false) and							// sta					; 9
       iny(i+10) and 										// iny					; 10
       LDA_BP2_Y(i+11) and									// lda (:bp2),y				; 11
       sta(i+12) and (iy(i+12) = false) and							// sta					; 12
       iny(i+13) and 										// iny					; 13
       LDA_BP2_Y(i+14) and									// lda (:bp2),y				; 14
       sta(i+15) and (iy(i+15) = false) then							// sta					; 15
       begin
	p:=GetWORD(i, i+2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+5] := #9'lda $' + IntToHex(p, 4);
	listing[i+7] := '';

	listing[i+8] := #9'lda $' + IntToHex(p+1, 4);
	listing[i+10]:= '';

	listing[i+11]:= #9'lda $' + IntToHex(p+2, 4);
	listing[i+13]:= '';

	listing[i+14]:= #9'lda $' + IntToHex(p+3, 4);

	exit(false);
       end;


    if LDA_BP2_Y(i+8) and									// lda (:bp2),y				; 8

       lda_im(i) and										// lda #				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda_im(i+2) and										// lda #				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1				; 3
       ldy_im_0(i+4) and									// ldy #$00				; 4
       LDA_BP2_Y(i+5) and									// lda (:bp2),y				; 5
       sta(i+6) and (iy(i+6) = false) and							// sta					; 6
       iny(i+7) and 										// iny					; 7
//       LDA_BP2_Y(i+8) and									// lda (:bp2),y				; 8
       sta(i+9) and (iy(i+9) = false) and							// sta					; 9
       (iny(i+10) = false) then									//~iny					; 10
       begin
	p:=GetWORD(i, i+2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+5] := #9'lda $' + IntToHex(p, 4);
	listing[i+7] := '';

	listing[i+8] := #9'lda $' + IntToHex(p+1, 4);

	exit(false);
       end;


    if STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9

       lda_im(i) and										// lda #				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda_im(i+2) and										// lda #				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1				; 3
       ldy_im_0(i+4) and									// ldy #$00				; 4
       lda(i+5) and (iy(i+5) = false) and							// lda					; 5
       STA_BP2_Y(i+6) and									// sta (:bp2),y				; 6
       iny(i+7) and 										// iny					; 7
       lda(i+8) and (iy(i+8) = false) and							// lda					; 8
//       STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9
       iny(i+10) and 										// iny					; 10
       lda(i+11) and (iy(i+11) = false) and							// lda					; 11
       STA_BP2_Y(i+12) and									// sta (:bp2),y				; 12
       iny(i+13) and 										// iny					; 13
       lda(i+14) and (iy(i+14) = false) and							// lda					; 14
       STA_BP2_Y(i+15) then									// sta (:bp2),y				; 15
       begin
	p:=GetWORD(i, i+2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+6] := #9'sta $' + IntToHex(p, 4);
	listing[i+7] := '';

	listing[i+9] := #9'sta $' + IntToHex(p+1, 4);
	listing[i+10]:= '';

	listing[i+12]:= #9'sta $' + IntToHex(p+2, 4);
	listing[i+13]:= '';

	listing[i+15]:= #9'sta $' + IntToHex(p+3, 4);

	exit(false);
       end;


    if STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9

       lda_im(i) and										// lda #				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda_im(i+2) and										// lda #				; 2
       sta_bp2_1(i+3) and									// sta :bp2+1				; 3
       ldy_im_0(i+4) and									// ldy #$00				; 4
       lda(i+5) and (iy(i+5) = false) and							// lda					; 5
       STA_BP2_Y(i+6) and									// sta (:bp2),y				; 6
       iny(i+7) and 										// iny					; 7
       lda(i+8) and (iy(i+8) = false) and							// lda					; 8
//       STA_BP2_Y(i+9) and									// sta (:bp2),y				; 9
       (iny(i+10) = false) then									//~iny					; 10
       begin
	p:=GetWORD(i, i+2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+6] := #9'sta $' + IntToHex(p, 4);
	listing[i+7] := '';

	listing[i+9] := #9'sta $' + IntToHex(p+1, 4);

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_val(i) and (iy(i) = false) and							// lda					; 0
       add_im_0(i+1) and 									// add #$00				; 1
       tay(i+2) and										// tay					; 2
       lda_val(i+3) and										// lda					; 3
       adc(i+4) and (adc_stack(i+4) = false) then						// adc					; 4	~:STACKORIGIN
//       sta_bp_1(i+5) then									// sta :bp+1				; 5
      begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+4] := #9'add ' + copy(listing[i+4], 6 ,256);

	exit(false);
      end;


    if sta_bp_1(i+5) and									// sta :bp+1				; 5

       lda_im_0(i) and										// lda #$00				; 0
       add(i+1) and (add_stack(i+1) = false) and (iy(i+1) = false) and				// add 					; 1	~:STACKORIGIN
       tay(i+2) and										// tay					; 2
       lda_val(i+3) and										// lda					; 3
       adc(i+4) and (adc_stack(i+4) = false) then						// adc					; 4	~:STACKORIGIN
//       sta_bp_1(i+5) then									// sta :bp+1				; 5
      begin
	listing[i]   := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+4] := #9'add ' + copy(listing[i+4], 6 ,256);

	exit(false);
      end;


    if sta_bp_1(i+9) and									// sta :bp+1				; 9

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_a(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_im_0(i+4) and									// lda #$00				; 4
       add_stack(i+5) and 									// add :STACKORIGIN			; 5
       tay(i+6) and										// tay					; 6
       lda_im_0(i+7) and									// lda #$00				; 7
       adc_stack(i+8) then									// adc :STACKORIGIN+STACKWIDTH		; 8
//       sta_bp_1(i+9) then									// sta :bp+1				; 9
     if	(copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and
       	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i]   := listing[i+6];

	listing[i+3] := listing[i+9];

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
      end;

end;		// function