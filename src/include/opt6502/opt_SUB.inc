
function opt_SUB(i: integer): Boolean;
var p, q: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      SUB.
// -----------------------------------------------------------------------------
//
// prevent such an arrangement if the preceding LDY|TAY command is missing
//
// ~sub adr.label
// ~sbc adr.label
//

    if lda_l_adr(i) and									// lda <adr.				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_a(i+2) and									// sta					; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_a(i+5) then									// sta					; 5
     begin
	p := GetWORD(i+1, i+4);

	if p <> 0 then listing[i] := listing[i] + '-' + HexWord2(p);
	listing[i+1] := '';

	if p <> 0 then listing[i+3] := listing[i+3] + '-' + HexWord2(p);
	listing[i+4] := '';

	exit(false);
     end;


    if lda(i) and									// lda					; 0
       lda(i+1) and									// lda					; 1
       add_sub(i+2) then								// add|sub				; 2
      begin
	listing[i] := '';

	exit(false);
      end;


    if (l = 3) and
       lda_a(i) and (iy(i) = false) and							// lda W				; 0
       sub_im_1(i+1) and								// sub #$01				; 1
       sta_a(i+2) then									// sta W				; 2
       if argMatch(i, i+2) then
       begin
	 listing[i]   := #9'dec '+copy(listing[i], 6, 256);
	 listing[i+1] := '';
	 listing[i+2] := '';

	exit(false);
       end;


    if (l = 3) and
       lda_a(i) and (iy(i) = false) and							// lda X 				; 0
       sub_im_1(i+1) and								// sub #$01				; 1
       sta_a(i+2) and (iy(i+2) = false) then						// sta Y				; 2
      if (argMatch(i, i+2) = false) then
     begin

       if lda_im(i) then begin
	p := GetBYTE(i);

	listing[i]   := #9'lda #' + HexByte(Byte(p-1));
	listing[i+1] := '';
       end else begin
	listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
	listing[i+1] := #9'dey';
	listing[i+2] := #9'sty '+copy(listing[i+2], 6, 256);
       end;

	exit(false);
     end;


    if tya(i) and 									// tya					; 0
       sub_im_1(i+1) and								// sub #$01				; 1
       tay(i+2) and 									// tay					; 2
       scs(i+3) and									// scs					; 3
       dec_(i+4) then									// dec					; 4
     begin
      listing[i+1] := #9'sne';
      listing[i+2] := listing[i+4];
      listing[i+3] := #9'dey';
      listing[i+4] := '';

      exit(false);
     end;


    if sta(i) and									// sta A				; 0
       lda(i+1) and									// lda					; 1
       (add_im_1(i+2) or sub_im_1(i+2)) and						// add|sub #$01				; 2
       add(i+3) and									// add A				; 3
       tay(i+4) then									// tay					; 4
      if argMatch(i, i+3) then
       begin
	listing[i]   := '';
	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);

	if add(i+2) then
	 listing[i+3] := #9'iny'
	else
	 listing[i+3] := #9'dey';

	listing[i+2] := #9'tay';

	listing[i+4] := '';

	exit(false);
       end;


    if lda(i) and 									// lda					; 0
       sub_im_0(i+1) and								// sub #$00				; 1
       sta(i+2) and 									// sta					; 2
       lda(i+3) and									// lda					; 3
       sbc(i+4) then									// sbc					; 4
     begin
      listing[i+1] := '';
      listing[i+4] := #9'sub ' + copy(listing[i+4], 6, 256);

      exit(false);
     end;


    if lda(i) and 									// lda					; 0
       sub_im_0(i+1) and								// sub #$00				; 1
       sta(i+2) and 									// sta					; 2
											//					; 3
       (sbc(i+4) = false) then								//~sbc					; 4
     begin
      listing[i+1] := '';

      exit(false);
     end;


    if sub(i) and									// sub					; 0
       sub_im_0(i+1) then								// sub #$00				; 1
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if lda_a(i) and									// lda					; 0
       sub_stack(i+1) and								// sub :STACKORIGIN+10			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_A(i+3) and 									// lda					; 3
       sbc_stack(i+4) and								// sbc :STACKORIGIN+STACKWIDTH+10	; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       mwy_bp2(i+6) and									// mwa xxx bp2				; 6
       ldy(i+7) and									// ldy					; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+9			; 8
       STA_BP2_Y(i+9) and								// sta (:bp2),y				; 9
       iny(i+10) and									// iny 					; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH+9 	; 11
       STA_BP2_Y(i+12) then								// sta (:bp2),y				; 12
     if argMatch(i+2, i+8) and
	argMatch(i+5, i+11) then
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


    if sbc_stack(i+9) and								// sbc :STACKORIGIN+STACKWIDTH		; 9

       LDA_BP2_Y(i) and									// lda (:bp2),y				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       iny(i+2) and									// iny					; 2
       LDA_BP2_Y(i+3) and								// lda (:bp2),y				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda(i+5) and									// lda 					; 5
       sub_stack(i+6) and								// sub :STACKORIGIN			; 6
       sta(i+7) and									// sta					; 7
       lda(i+8) and									// lda 					; 8
//       sbc_stack(i+9) and								// sbc :STACKORIGIN+STACKWIDTH		; 9
       sta(i+10) then									// sta					; 10
     if argMatch(i+1, i+6) and
	argMatch(i+4, i+9) then
	begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';

	  listing[i+4] := listing[i+5];
	  listing[i+5] := #9'sub (:bp2),y';
	  listing[i+6] := #9'iny';

	  listing[i+9] := #9'sbc (:bp2),y';

	  exit(false);
	end;


    if sbc(i+9) and									// sbc					; 9

       LDA_BP2_Y(i) and									// lda (:bp2),y				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       iny(i+2) and									// iny					; 2
       LDA_BP2_Y(i+3) and								// lda (:bp2),y				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
       sub(i+6) and									// sub					; 6
       sta_a(i+7) and									// sta					; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+STACKWIDTH		; 8
//       sbc(i+9) and									// sbc					; 9
       sta_a(i+10) then									// sta					; 10
     if argMatch(i+1, i+5) and
	argMatch(i+4, i+8) then
	begin
	  listing[i+1] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';

	  listing[i+8] := listing[i];

	  exit(false);
	end;


    if sbc_stack(i+18) and								// sbc :STACKORIGIN+STACKWIDTH*3	; 18

       lda(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and									// lda					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda(i+6) and									// lda					; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lda_a(i+8) and									// lda					; 8
       sub_stack(i+9) and								// sub :STACKORIGIN			; 9
       sta_a(i+10) and									// sta					; 10
       lda_a(i+11) and									// lda					; 11
       sbc_stack(i+12) and								// sbc :STACKORIGIN+STACKWIDTH		; 12
       sta_a(i+13) and									// sta					; 13
       lda_a(i+14) and									// lda					; 14
       sbc_stack(i+15) and								// sbc :STACKORIGIN+STACKWIDTH*2	; 15
       sta_a(i+16) and									// sta					; 16
       lda_a(i+17) and									// lda					; 17
//       sbc_stack(i+18) and								// sbc :STACKORIGIN+STACKWIDTH*3	; 18
       sta_a(i+19) then									// sta					; 19
     if argMatch(i+1, i+9) and
	argMatch(i+3, i+12) and
	argMatch(i+5, i+15) and
	argMatch(i+7, i+18) then
       begin
	listing[i+9]  := #9'sub ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'sbc ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'sbc ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'sbc ' + copy(listing[i+6], 6, 256);

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


    if sbc(i+10) and									// sbc 					; 10

       lda_a(i) and									// lda					; 0
       sub(i+1) and									// sub 					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda 					; 3
       sbc(i+4) and									// sbc 					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_a(i+6) and									// lda 					; 6
       sbc(i+7) and									// sbc 					; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_a(i+9) and									// lda 					; 9
//       sbc(i+10) and									// sbc 					; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN			; 12
       sta_a(i+13) and									// sta 					; 13
       lda_stack(i+14) and								// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_a(i+15) and									// sta 					; 15
       lda_stack(i+16) and								// lda :STACKORIGIN+STACKWIDTH*2	; 16
       sta_a(i+17) and									// sta 					; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*3	; 18
       sta_a(i+19) then									// sta 					; 19
     if argMatch(i+2, i+12) and
	argMatch(i+5, i+14) and
	argMatch(i+8, i+16) and
	argMatch(i+11, i+18) then
       begin
	listing[i+2]  := listing[i+13];
	listing[i+5]  := listing[i+15];
	listing[i+8]  := listing[i+17];
	listing[i+11] := listing[i+19];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

	exit(false);
       end;


    if sbc(i+12) and									// sbc 					; 12

       lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and									// lda					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2	; 5
       lda_a(i+6) and									// lda					; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3	; 7
       lda_stack(i+8) and								// lda :STACKORIGIN			; 8
       sub(i+9) and									// sub 					; 9
       sta_a(i+10) and									// sta ERROR				; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH		; 11
//       sbc(i+12) and									// sbc 					; 12
       sta_a(i+13) and									// sta ERROR+1				; 13
											//					; 14
       (sbc(i+15) = false) then								//~sbc					; 15
     if argMatch(i+1, i+8) and
	argMatch(i+3, i+11) then
       begin
	listing[i+8]  := listing[i];
	listing[i+11] := listing[i+2];

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if adc_sbc(i+8) and									// adc|sbc				; 8

       lda(i) and									// lda					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda					; 2		~lda adr.
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and								// lda :STACKORIGIN			; 4
       add_sub(i+5) and									// add|sub				; 5
       sta_a(i+6) and									// sta					; 6
       lda_stack(i+7) then								// lda :STACKORIGIN+STACKWIDTH		; 7
//       adc_sbc(i+8) and								// adc|sbc				; 8
//       sta(i+9) then									// sta					; 9
     if argMatch(i+1, i+4) and
	argMatch(i+3, i+7) then
      begin
	listing[i+4] := listing[i];
	listing[i+7] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sbc_stack(i+8) and								// sbc :STACKORIGIN+STACKWIDTH		; 8

       lda(i) and									// lda					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda					; 2		~lda.adr
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and									// lda					; 4		~lda.adr
       sub_stack(i+5) and								// sub :STACKORIGIN			; 5
       sta_a(i+6) and									// sta					; 6
       lda(i+7) then									// lda					; 7		~lda.adr
//       sbc_stack(i+8) and								// sbc :STACKORIGIN+STACKWIDTH		; 8
//       sta_a(i+9) then								// sta					; 9
     if argMatch(i+1, i+5) and
	argMatch(i+3, i+8) then
      begin
	listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+8] := #9'sbc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if adc_sbc(i+6) and									// adc|sbc				; 6

       lda(i) and 									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       add_sub(i+3) and									// add|sub				; 3
       sta(i+4) and 									// sta					; 4
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
//       adc_sbc(i+6) and								// adc|sbc				; 6
       sta(i+7) then									// sta					; 7
     if argMatch(i+1, i+5) and
        (argMatch(i+4, i) = false) then
     begin
	listing[i+5] := #9'lda ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if lda(i) and 									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta(i+3) and 									// sta					; 3
       lda_stack(i+4) and								// lda :STACKORIGIN			; 4
       add_sub(i+5) and									// add|sub				; 5
       sta(i+6) then									// sta					; 6
     if argMatch(i+1, i+4) and
        (argMatch(i+3, i) = false) then
     begin
	listing[i+4] := #9'lda ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if lda(i) and 									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta(i+3) and 									// sta					; 3
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       add_sub(i+5) and									// add|sub				; 5
       sta(i+6) and									// sta					; 6
       lda_stack(i+7) and								// lda :STACKORIGIN			; 7
       adc_sbc(i+8) then								// adc|sbc				; 8
     if argMatch(i+1, i+7) and
        (argMatch(i+6, i) = false) then
     begin
	listing[i+7] := #9'lda ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if sty_stack(i) and									// sty :STACKORIGIN+10			; 0
       sub(i+1) and									// sub					; 1
       sta_val(i+2) and									// sta					; 2	~:STACKORIGIN
       lda_stack(i+3) and								// lda :STACKORIGIN+10			; 3
       sbc(i+4) then									// sbc					; 4
     if argMatch(i, i+3) then
       begin

	listing[i]   := '';
	listing[i+3] := #9'tya';

	exit(false);
       end;


    if sbc_im_0(i+10) and								// sbc #$00				; 10

       lda_val(i) and									// lda K				; 0	~:STACKORIGIN
       sub_im_1(i+1) and								// sub #$01				; 1
       sta_a(i+2) and									// sta K				; 2
       lda_a(i+3) and									// lda K+1				; 3
       sbc_im_0(i+4) and								// sbc #$00				; 4
       sta_a(i+5) and									// sta K+1				; 5
       lda_a(i+6) and									// lda K+2				; 6
       sbc_im_0(i+7) and								// sbc #$00				; 7
       sta_a(i+8) and									// sta K+2				; 8
       lda_a(i+9) and									// lda K+3				; 9
//       sbc_im_0(i+10) and								// sbc #$00				; 10
       sta_a(i+11) then									// sta K+3				; 11
      if argMatch(i, i+2) and
	 argMatch(i+3, i+5) and
	 argMatch(i+6, i+8) and
	 argMatch(i+9, i+11) then
     begin

	listing[i+1] := #9'bne @+1';
	listing[i+2] := listing[i+3];
	listing[i+3] := #9'bne @+';
	listing[i+4] := listing[i+6];
	listing[i+5] := #9'sne';
	listing[i+6] := #9'dec ' + copy(listing[i+9], 6, 256);
	listing[i+7] := #9'dec ' + copy(listing[i+4], 6, 256);
	listing[i+8] := '@';
	listing[i+9] := #9'dec ' + copy(listing[i+2], 6, 256);
	listing[i+10] := '@';
	listing[i+11] := #9'dec ' + copy(listing[i], 6, 256);

	exit(false);
    end;


    if (l = 6) and
       lda_val(i) and									// lda W				; 0	~:STACKORIGIN
       sub_im(i+1) and (sub_im_0(i+1) = false) and					// sub #$01..$ff			; 1
       sta_a(i+2) and									// sta W				; 2
       lda_a(i+3) and									// lda W+1				; 3
       sbc_im_0(i+4) and								// sbc #$00				; 4
       sta_a(i+5) then									// sta W+1				; 5
     if argMatch(i, i+2) and
	argMatch(i+3, i+5) then
     begin

	if sub_im_1(i+1) then begin
	 listing[i+1] := #9'bne @+';
	 listing[i+2] := #9'dec ' + copy(listing[i], 6, 256) + '+1';
	 listing[i+3] := '@';
	 listing[i+4] := #9'dec ' + copy(listing[i], 6, 256);
	 listing[i+5] := '';
	end else begin
	 listing[i+3] := #9'scs';
	 listing[i+4] := #9'dec '+copy(listing[i+5], 6, 256);
	 listing[i+5] := '';
	end;

	exit(false);
     end;


    if lda_im(i) and									// lda #				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_a(i+2) and									// sta 					; 2
       lda_im(i+3) and									// lda #				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_a(i+5) and									// sta 					; 5
											//					; 6
       (sbc(i+7) = false) then								//~sbc					; 7
     begin
      p := GetWORD(i, i+3) - GetWORD(i+1, i+4);

      listing[i]   := #9'lda #' + HexByte(Byte(p and $ff));
      listing[i+1] := '';
      listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+4] := '';

      exit(false);
     end;


    if (l=3) and
       lda_im(i) and									// lda #				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_a(i+2) then									// sta 					; 2
     begin
      p := GetBYTE(i) - GetBYTE(i+1);

      listing[i] := '';

      listing[i+1] := #9'lda #' + HexByte(Byte(p and $ff));

      exit(false);
     end;


    if lda_a(i) and (lda_im(i) = false) and						// lda					; 0
       add_im(i+1) and									// add #				; 1
       sub_im(i+2) and									// sub #				; 2
       sta_a(i+3) then									// sta 					; 3
     begin
      p := -(GetBYTE(i+1) - GetBYTE(i+2));

      listing[i+1] := '';
      listing[i+2] := #9'sub #' + HexByte(Byte(p and $ff));

      exit(false);
     end;


    if lda_im(i) and									// lda #				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_bp2_y(i+2) and								// sta (:bp2),y				; 2
       iny(i+3) and									// iny					; 3
       lda_im(i+4) and									// lda #				; 4
       sbc_im(i+5) and									// sbc #				; 5
       sta_bp2_y(i+6) and								// sta (:bp2),y				; 6
       (iny(i+7) = false) then								//~iny					; 7
     begin

      p := GetWORD(i, i+4) - GetWORD(i+1, i+5);

      listing[i]   := #9'lda #' + HexByte(Byte(p and $ff));
      listing[i+1] := '';

      listing[i+4] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+5] := '';

      exit(false);
     end;


    if sbc_im(i+7) and									// sbc #				; 7

       lda_im(i) and									// lda #				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_a(i+2) and									// sta 					; 2
       lda_im(i+3) and 									// lda #				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_a(i+5) and									// sta 					; 5
       lda_im(i+6) and									// lda #				; 6
//       sbc_im(i+7) and								// sbc #				; 7
       sta_a(i+8) and									// sta 					; 8
  //     (lda_im(i+9) = false) and							//					; 9
       (sbc(i+10) = false) then								//~sbc					; 10
     begin
//      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16;
//      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16;

      p := GetTRIPLE(i, i+3, i+6);
      q := GetTRIPLE(i+1, i+4, i+7);

      p := p - q;

      listing[i]   := #9'lda #' + HexByte(Byte(p and $ff));
      listing[i+1] := '';
      listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+4] := '';
      listing[i+6] := #9'lda #' + HexByte(byte(p shr 16));
      listing[i+7] := '';

      exit(false);
     end;


    if sbc_im(i+10) and									// sbc #				; 10

       lda_a(i) and (lda_im(i) = false) and						// lda W				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda W+1				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       sub_im(i+7) and									// sub #				; 7
       sta_a(i+8) and									// sta W				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
//       sbc_im(i+10) and								// sbc #				; 10
       sta_a(i+11) then									// sta W+1				; 11
      if argMatch(i+2, i+6) and
	 argMatch(i+5, i+9) then
     begin
      p := GetWORD(i+1, i+4) + GetWORD(i+7, i+10);

      listing[i+1] := #9'sub #' + HexByte(Byte(p and $ff));
      listing[i+4] := #9'sbc #' + HexByte(byte(p shr 8));

      listing[i+2] := listing[i+8];
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      exit(false);
     end;


    if sbc_im(i+10) and									// sbc #				; 10

       lda_im(i) and									// lda #				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_a(i+2) and									// sta :STACKORIGIN			; 2
       lda_im(i+3) and									// lda #				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_a(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and									// lda #				; 6
       sbc_im(i+7) and									// sbc #				; 7
       sta_a(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_im(i+9) and									// lda #				; 9
//       sbc_im(i+10) and								// sbc #				; 10
       sta_a(i+11) then									// sta :STACKORIGIN+STACKWIDTH*3	; 11
      begin
//	p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16 + GetVAL(copy(listing[i+9], 6, 256)) shl 24;
//	err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;

	p := GetDWORD(i, i+3, i+6, i+9);
	q := GetDWORD(i+1, i+4, i+7, i+10);

	p := p - q;

	listing[i]   := #9'lda #' + HexByte(Byte(p and $ff));
	listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
	listing[i+6] := #9'lda #' + HexByte(byte(p shr 16));
	listing[i+9] := #9'lda #' + HexByte(Byte(p shr 24));

	listing[i+1] := '';
	listing[i+4] := '';
	listing[i+7] := '';
	listing[i+10] := '';

	exit(false);
       end;


    if sbc_im(i+7) and									// sbc #				; 7

       lda_im(i) and									// lda #				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_a(i+2) and									// sta :STACKORIGIN			; 2
       lda_im(i+3) and									// lda #				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_a(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and									// lda #				; 6
//       sbc_im(i+7) and								// sbc #				; 7
       sta_a(i+8) then									// sta :STACKORIGIN+STACKWIDTH*2	; 8
      begin
//	p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16;
//	err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16;

	p := GetTRIPLE(i, i+3, i+6);
	q := GetTRIPLE(i+1, i+4, i+7);

	p := p - q;

	listing[i]   := #9'lda #' + HexByte(Byte(p and $ff));
	listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
	listing[i+6] := #9'lda #' + HexByte(byte(p shr 16));

	listing[i+1] := '';
	listing[i+4] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if sbc_im(i+22) and									// sbc #				; 22

       lda_a(i) and (lda_im(i) = false) and						// lda W				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda W+1				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_a(i+6) and									// lda W+2				; 6
       sbc_im(i+7) and									// sbc #				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_a(i+9) and									// lda W+3				; 9
       sbc_im(i+10) and									// sbc #				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       sub_im(i+13) and									// sub #				; 13
       sta_a(i+14) and									// sta W				; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH		; 15
       sbc_im(i+16) and									// sbc #				; 16
       sta_a(i+17) and									// sta W+1				; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*2	; 18
       sbc_im(i+19) and									// sbc #				; 19
       sta_a(i+20) and									// sta W+2				; 20
       lda_stack(i+21) and								// lda :STACKORIGIN+STACKWIDTH*3	; 21
//       sbc_im(i+22) and								// sbc #				; 22
       sta_a(i+23) then									// sta W+3				; 23
      if argMatch(i+2, i+12) and
	 argMatch(i+5, i+15) and
	 argMatch(i+8, i+18) and
	 argMatch(i+11, i+21) then
     begin
//      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;
//      err :=  GetVAL(copy(listing[i+13], 6, 256)) + GetVAL(copy(listing[i+16], 6, 256)) shl 8 + GetVAL(copy(listing[i+19], 6, 256)) shl 16 + GetVAL(copy(listing[i+22], 6, 256)) shl 24;

      p := GetDWORD(i+1, i+4, i+7, i+10);
      q := GetDWORD(i+13, i+16, i+19, i+22);

      p := p + q;

      listing[i+1] := #9'sub #' + HexByte(Byte(p and $ff));
      listing[i+4] := #9'sbc #' + HexByte(byte(p shr 8));
      listing[i+7] := #9'sbc #' + HexByte(byte(p shr 16));
      listing[i+10] := #9'sbc #' + HexByte(Byte(p shr 24));

      listing[i+2] := listing[i+14];
      listing[i+5] := listing[i+17];
      listing[i+8] := listing[i+20];
      listing[i+11] := listing[i+23];

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

      exit(false);
     end;


    if sbc_im(i+22) and									// sbc #				; 22

       lda_a(i) and (lda_im(i) = false) and						// lda W				; 0
       add_im(i+1) and									// add #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda W+1				; 3
       adc_im(i+4) and									// adc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_a(i+6) and									// lda W+2				; 6
       adc_im(i+7) and									// adc #				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_a(i+9) and									// lda W+3				; 9
       adc_im(i+10) and									// adc #				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       sub_im(i+13) and									// sub #				; 13
       sta_a(i+14) and									// sta W				; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       sbc_im(i+16) and									// sbc #				; 16
       sta_a(i+17) and									// sta W+1				; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*2+9	; 18
       sbc_im(i+19) and									// sbc #				; 19
       sta_a(i+20) and									// sta W+2				; 20
       lda_stack(i+21) and								// lda :STACKORIGIN+STACKWIDTH*3+9	; 21
//       sbc_im(i+22) and								// sbc #				; 22
       sta_a(i+23) then									// sta W+3				; 23
      if argMatch(i+2, i+12) and
	 argMatch(i+5, i+15) and
	 argMatch(i+8, i+18) and
	 argMatch(i+11, i+21) then
     begin
//      p := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;
//      err :=  GetVAL(copy(listing[i+13], 6, 256)) + GetVAL(copy(listing[i+16], 6, 256)) shl 8 + GetVAL(copy(listing[i+19], 6, 256)) shl 16 + GetVAL(copy(listing[i+22], 6, 256)) shl 24;

      p := GetDWORD(i+1, i+4, i+7, i+10);
      q := GetDWORD(i+13, i+16, i+19, i+22);

      p := p - q;

      listing[i+1] := #9'add #' + HexByte(Byte(p and $ff));
      listing[i+4] := #9'adc #' + HexByte(byte(p shr 8));
      listing[i+7] := #9'adc #' + HexByte(byte(p shr 16));
      listing[i+10] := #9'adc #' + HexByte(Byte(p shr 24));

      listing[i+2] := listing[i+14];
      listing[i+5] := listing[i+17];
      listing[i+8] := listing[i+20];
      listing[i+11] := listing[i+23];

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

      exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and							// lda					; 0
       sub(i+1) and (iy(i+1) = false) and						// sub					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_a(i+3) and									// lda					; 3
       sub(i+4) and									// sub 					; 4
       sta_a(i+5) and									// sta					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH		; 6
       sbc_im_0(i+7) then								// sbc #$00				; 7
    if argMatch(i+2, i+6) then
       begin
	listing[i+6] := listing[i];
	listing[i+7] := #9'sbc ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if tay(i+5) and									// tay					; 5

       lda_a(i) and (iy(i) = false) and							// lda					; 0
       sub(i+1) and (iy(i+1) = false) and						// sub					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH		; 2
       lda_a(i+3) and									// lda					; 3
       sub(i+4) and									// sub 					; 4
//       tay(i+5) and									// tay					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH		; 6
       sbc_im_0(i+7) then								// sbc #$00				; 7
    if argMatch(i+2, i+6) then
       begin
	listing[i+6] := listing[i];
	listing[i+7] := #9'sbc ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if sbc_im_0(i+10) and								// sbc #$00				; 10

       lda_a(i) and (iy(i) = false) and							// lda					; 0
       add_sub(i+1) and (iy(i+1) = false) and						// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       sub(i+7) and									// sub 					; 7
       tay(i+8) and									// tay					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
//       sbc_im_0(i+10) and								// sbc #$00				; 10
       sta_bp_1(i+11) then								// sta :bp+1				; 11
    if argMatch(i+2, i+6) and
       argMatch(i+5, i+9) then
       begin
	listing[i+2] := #9'tay';

	listing[i+5] := #9'sta :bp+1';
	listing[i+6] := #9'tya';

	listing[i+9]  := #9'scs';
	listing[i+10] := #9'dec :bp+1';
	listing[i+11] := '';

	exit(false);
       end;


    if lda_a(i) and									// lda					; 0
       sub(i+1) and									// sub					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda					; 3
       sub_stack(i+4) and								// sub :STACKORIGIN			; 4
       sta_a(i+5) and									// sta G				; 5
       scs(i+6) then									// scs					; 6
    if argMatch(i+2, i+4) then
       begin
	listing[i+2] := #9'clc';
	listing[i+3] := #9'sbc ' + copy(listing[i+3], 6, 256);
	listing[i+4] := #9'eor #$FF';

	listing[i+6] := #9'scc';

	exit(false);
       end;


    if lda_val(i) and sta_val(i+2) and							// lda W				; 0
       lda_val(i+3) and									// sub 					; 1
       sta_val(i+5) and									// sta W 				; 2
       sub(i+1) and (sub_im(i+1) = false) and						// lda W+1				; 3
       sbc_im_0(i+4) and								// sbc #$00				; 4
       (lda_a(i+6) = false) then							// sta W+1				; 5
     if argMatch(i, i+2) and
	argMatch(i+3, i+5) then
     begin
	listing[i+3] := #9'scs';
	listing[i+4] := #9'dec '+copy(listing[i+5], 6, 256);
	listing[i+5] := '';

	exit(false);
     end;

end;		// function
