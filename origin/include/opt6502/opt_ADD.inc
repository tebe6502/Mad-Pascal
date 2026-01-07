
function opt_ADD(i: integer): Boolean;
var p, q: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      ADD.
// -----------------------------------------------------------------------------
//
// prevent such an arrangement if the preceding LDY|TAY command is missing
//
// ~add adr.label
// ~adc adr.label
//


    if lda_l_adr(i) and									// lda <adr.				; 0
       add_im(i+1) and									// add #				; 1
       sta_a(i+2) and									// sta					; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
       adc_im(i+4) and									// adc #				; 4
       sta_a(i+5) then									// sta					; 5
     begin
	p := GetWORD(i+1, i+4);

	if p <> 0 then begin
	 listing[i] := listing[i] + '+' + Hex(p, 2);

	 listing[i+3] := listing[i+3] + '+' + Hex(p, 2);
	end;

	listing[i+1] := '';

	listing[i+4] := '';

	exit(false);
     end;


    if lda_a(i)	and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       add_sub(i+2) and									// add|sub				; 2
       add_im_0(i+3) and								// add #$00				; 3
       (sta_a(i+4) or tay(i+4)) then							// sta|tay				; 4
     begin
	listing[i+3] := '';

	exit(false);
     end;


    if lda_a(i)	and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       add_im_0(i+2) and								// add #$00				; 2
       (sta_a(i+3) or tay(i+3)) then							// sta|tay				; 3
     begin
	listing[i+2] := '';

	exit(false);
     end;


    if lda_l_adr(i) and									// lda <adr.				; 0
       add_stack(i+1) and								// add :STACKORIGIN			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
       adc_stack(i+4) and								// adc :STACKORIGIN+STACKWIDTH		; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add_im(i+7) and (data(i+7) = false) and						// add #				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN			; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_im(i+10) and									// adc #				; 10
       sta_stack(i+11) then								// sta :STACKORIGIN+STACKWIDTH		; 11
     if argMatch(i+1, i+2) and
        argMatch(i+2, i+6) and
        argMatch(i+6, i+8) and
        argMatch(i+4, i+5) and
        argMatch(i+5, i+9) and
        argMatch(i+9, i+11) then
     begin
	p := GetWORD(i+7, i+10);

	if p <> 0 then begin
	 listing[i] := listing[i] + '+' + Hex(p, 2);

	 listing[i+3] := listing[i+3] + '+' + Hex(p, 2);
	end;

	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	exit(false);
     end;


    if (pos(#9'add <adr.', listing[i]) > 0) and						// add <adr.				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       (pos(#9'lda >adr.', listing[i+2]) > 0) and					// lda >adr.				; 2
       adc(i+3) and									// adc					; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
       add_im(i+6) and (data(i+6) = false) and						// add #				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN			; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+STACKWIDTH		; 8
       adc_im(i+9) and									// adc #				; 9
       sta_stack(i+10) then								// sta :STACKORIGIN+STACKWIDTH		; 10
     if argMatch(i+1, i+5) and
        argMatch(i+5, i+7) and
        argMatch(i+4, i+8) and
        argMatch(i+8, i+10) then
     begin
	p := GetWORD(i+6, i+9);

	if p <> 0 then begin
	 listing[i] := listing[i] + '+' + Hex(p, 2);

	 listing[i+2] := listing[i+2] + '+' + Hex(p, 2);
	end;

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';

	exit(false);
     end;


    if lda_val(i) and									// lda					; 0	~:STACKORIGIN
       adc_sbc(i+1) and									// adc|sbc				; 1
       sta_a(i+2) and (listing[i+2] = listing[i+4]) and					// sta :STACKORIGIN			; 2
       lda_val(i+3) then								// lda					; 3	~:STACKORIGIN
//       sta_a(i+4) then								// sta :STACKORIGIN			; 4
     begin
      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';

      exit(false);
     end;


    if adc_sbc(i) and									// adc|sbc				; 0
       lda_a(i+1) and									// lda					; 1
       add_sub(i+2) then								// add|sub				; 2
     begin
	listing[i]   := '';

	exit(false);
     end;


    if (l = 3) and
       lda_a(i) and (iy(i) = false) and							// lda W				; 0
       add_im_1(i+1) and								// add #$01				; 1
       sta_a(i+2) then									// sta W				; 2
     if argMatch(i, i+2) then
       begin
	listing[i]   := #9'inc ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if (l = 3) and
       lda_a(i) and (iy(i) = false) and							// lda X 				; 0
       add_im_1(i+1) and								// add #$01				; 1
       sta_a(i+2) and (iy(i+2) = false) and (sta_bp_1(i+2) = false) then		// sta Y				; 2
     if (argMatch(i, i+2) = false) then
     begin
	listing[i]   := #9'ldy '+copy(listing[i], 6, 256);
	listing[i+1] := #9'iny';
	listing[i+2] := #9'sty '+copy(listing[i+2], 6, 256);

	exit(false);
     end;


    if //(i=0) and
       lda(i) and (iy(i) = false) and							// lda					; 0
       add_im_1(i+1) and								// add #$01				; 1
       tay(i+2) and									// tay					; 2
       (iy(i+3) or iy(i+4)) then							// ,y|					; 3
											//    ,y				; 4
     begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'iny';
	listing[i+2] := '';

	exit(false);
     end;


    if lda_val(i) and (iy(i) = false) and						// lda					; 0
       (add_im_1(i+1) or sub_im_1(i+1)) and						// add #$01|sub #$01			; 1
       sta_val(i+2) and (iy(i+2) = false) and (sta_bp_1(i+2) = false) and		// sta					; 2
       lda_a(i+3) and									// lda					; 3
       (add_sub(i+4) or sta_a(i+4)) then						// add|sub|sta				; 4
     begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);

        if add_im_1(i+1) then
	 listing[i+1] := #9'iny'
	else
	 listing[i+1] := #9'dey';

	listing[i+2] := #9'sty ' + copy(listing[i+2], 6, 256);

	exit(false);
     end;


    if lda_val(i) and (iy(i) = false) and						// lda					; 0
       (add_im_1(i+1) or sub_im_1(i+1)) and						// add #$01|sub #$01			; 1
       sta_val(i+2) and (iy(i+2) = false) and						// sta					; 2
       ldy(i+3) then									// ldy					; 3
     begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);

        if add_im_1(i+1) then
	 listing[i+1] := #9'iny'
	else
	 listing[i+1] := #9'dey';

	listing[i+2] := #9'sty ' + copy(listing[i+2], 6, 256);

	exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and							// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       ldy(i+3) and									// ldy					; 3
       lda_stack(i+4) and								// lda :STACKORIGIN			; 4
       (SKIP(i+5) = false) then
     if argMatch(i+2, i+4) then
       begin
	listing[i+2] := '';

	listing[i+4] := '';

	exit(false);
       end;


    if lda_a(i) and									// lda					; 0
       add_sub(i+1) and 								// add|sub				; 1
       lda_a(i+2) and									// lda					; 2
       (adc_sbc(i+3) = false) then							// ~adc|sbc				; 3
       begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0
       adc_im_0(i+1) and								// adc #$00				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       ldy(i+3) and									// ldy					; 3
       lda_stack(i+4) and 								// lda :STACKORIGIN			; 4
       add(i+5) then									// add					; 5
     if argMatch(i+2, i+4) then
     begin
      listing[i+1] := listing[i];
      listing[i]   := listing[i+3];

      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := #9'adc ' + copy(listing[i+5], 6, 256);

      exit(false);
     end;


    if lda(i) and									// lda					; 0
       add(i+1) and									// add					; 1
       ldy(i+2) and									// ldy					; 2
       lda(i+3) then									// lda 					; 3
     begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if lda(i) and									// lda I				; 0
       add_sub(i+1) and									// add|sub				; 1
       add_im_1(i+2) and								// add #$01				; 2
       tay(i+3) then									// tay					; 3
     begin
	listing[i+2] := #9'tay';
	listing[i+3] := #9'iny';

	exit(false);
     end;


   if (ldy_val(i) or tay(i)) and							// ldy|tay				; 0	!!!
       lda(i+1) and (lda_stack(i+1) = false) and					// lda					; 1	~lda :STACKORIGIN ~lda adr.
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and				 					// lda					; 3	~lda :STACKORIGIN
       add_sub_stack(i+4) then								// add|sub :STACKORIGIN			; 4
     if argMatch(i+2, i+4) then
     begin

        if add_stack(i+4) then
	 listing[i+4]  := #9'add ' + copy(listing[i+1], 6, 256)
	else
	 listing[i+4]  := #9'sub ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if lda(i) and (lda_stack(i) = false) and (iy(i) = false) and			// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       ldy_val(i+2) and									// ldy					; 2	~:STACKORIGIN
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       add_sub_stack(i+4) then								// add|sub :STACKORIGIN			; 4
     if argMatch(i+1, i+4) then
     begin

	if add_stack(i+4) then
	 listing[i+4]  := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+4]  := #9'sub ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if (lda_a(i) = false) and								//~lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+9			; 1
       ldy_val(i+2) and									// ldy					; 2	~:STACKORIGIN
       lda(i+3) and (lda_stack(i+3) = false) and					// lda					; 3	~:STACKORIGIN ~lda adr.
       add_stack(i+4) then								// add :STACKORIGIN+9			; 4
     if argMatch(i+1, i+4) then
     begin
	listing[i+3]  := #9'add ' + copy(listing[i+3], 6, 256);

	listing[i+1] := '';
	listing[i+4] := '';

	exit(false);
     end;


    if tya(i) and									// tya	 				; 0
       add_im_1(i+1) and								// add #$01				; 1
       tay(i+2) and 									// tay					; 2
       scc(i+3) and									// scc					; 3
       inc_bp_1(i+4) then								// inc :bp+1				; 4
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'iny';
	listing[i+3] := #9'sne';

	exit(false);
     end;


    if lda(i) and (iy(i) = false) and							// lda					; 0	~lda adr.
       add(i+1) and iy(i+1) and								// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and 									// lda					; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_bp_1(i+5) then								// sta :bp+1				; 5	!!! sta :bp+1
      begin
	tmp := listing[i];

	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'add ' + copy(tmp, 6, 256);

	exit(false);
      end;


    if lda_stack(i) and									// lda :STACKORIGIN			; 0
       add(i+1) and (add_stack(i+1) = false) and					// add					; 1	~:STACKORIGIN
       (sta_stack(i+2) or tay(i+2))  and						// sta :STACKORIGIN|tay			; 2
       lda_stack(i+3) and 								// lda :STACKORIGIN+STACKWIDTH		; 3
       adc(i+4) and (adc_stack(i+4) = false) and					// adc					; 4	~:STACKWIDTH
       sta_bp_1(i+5) then								// sta :bp+1				; 5	!!! sta :bp+1
      begin
	tmp := listing[i];

	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'add ' + copy(tmp, 6, 256);

	tmp := listing[i+3];

	listing[i+3] := #9'lda ' + copy(listing[i+4], 6, 256);
	listing[i+4] := #9'adc ' + copy(tmp, 6, 256);

	exit(false);
      end;


    if tay(i+8) and									// tay					; 8

       lda_stack(i) and									// lda :STACKORIGIN			; 0
       add_im_0(i+1) and								// add #$00				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH		; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add_im_0(i+7) and								// add #$00				; 7
//       tay(i+8) and									// tay					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_im_0(i+10) and								// adc #$00				; 10
       sta_stack(i+11) then								// sta :STACKORIGIN+STACKWIDTH		; 11
     if argMatch(i, i+2) and
	argMatch(i+2, i+6) and
	argMatch(i+3, i+5) and
	argMatch(i+5, i+9) then
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if sta(i) and									// sta A				; 0
       lda_stack(i+1) and								// lda :STACKORIGIN+9			; 1
       sta(i+2) and									// sta D				; 2
       lda(i+3) and									// lda A				; 3
       add_sub(i+4) and	(iy(i+4) = false) and						// add|sub				; 4
       sta(i+5) and (iy(i+5) = false) and						// sta D+1				; 5
											//					; 6
       (adc_sbc(i+7) = false) then							//~adc|sbc				; 7
     if argMatch(i, i+3) and
	(pos(listing[i+2], listing[i+5]) > 0) then
       begin
	listing[i] := listing[i+4];

	listing[i+3] := listing[i+1];
	listing[i+4] := listing[i+2];

	listing[i+1] := listing[i+5];

	listing[i+2] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta(i+5) and									// sta					; 5
       lda(i+6) and (iy(i+6) = false) and						// lda 					; 6
       add_sub_stack(i+7) and								// add|sub :STACKORIGIN+10		; 7
       sta(i+8) and (iy(i+8) = false) and						// sta					; 8
											//					; 9
       (adc_sbc(i+10) = false) then							//~adc|sbc				; 10
    if argMatch(i+2, i+7) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta(i+5) and									// sta					; 5
       lda(i+6) and (iy(i+6) = false) and						// lda 					; 6
       add_stack(i+7) and								// add :STACKORIGIN+10			; 7
       sub(i+8) and (iy(i+8) = false) and						// sub					; 8
       sta(i+9) and (iy(i+9) = false) and						// sta					; 9
											//					; 10
       (sbc(i+11) = false) then								//~sbc					; 11
    if argMatch(i+2, i+7) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0	~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN+9			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH+9	; 2
       lda(i+3) and									// lda 					; 3
       add_sub_stack(i+4) and								// add|sub :STACKORIGIN+9		; 4
       sta(i+5) and									// sta					; 5
       lda(i+6) and									// lda 					; 6
       adc_sbc_stack(i+7) then								// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 7
     if argMatch(i+1, i+4) and
	argMatch(i+2, i+7) then
       begin
	listing[i+4] := copy(listing[i+4], 1, 5) + copy(listing[i], 6, 256);
	listing[i+7] := copy(listing[i+7], 1, 5) + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+9			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH+9	; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+9			; 3
       add_sub(i+4) and 								// add|sub				; 4
       sta(i+5) and									// sta					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH+9	; 6
       adc_sbc(i+7) then 								// adc|sbc 				; 7
     if argMatch(i+1, i+3) and
	argMatch(i+2, i+6) then
       begin
	listing[i+3] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if adc_sbc(i+14) and								// adc|sbc				; 14

       lda_a(i) and									// lda GD				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 1
       lda_a(i+2) and									// lda GD+1				; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 3
       lda_a(i+4) and									// lda					; 4
       add_sub(i+5) and									// add|sub				; 5
       sta_stack(i+6) and								// sta :STACKORIGIN+10			; 6
       lda_a(i+7) and									// lda					; 7
       adc_sbc(i+8) and									// adc|sbc				; 8
       sta_stack(i+9) and								// sta :STACKORIGIN+STACKWIDTH+10	; 9
       lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 10
       adc_sbc(i+11) and								// adc|sbc				; 11
       sta_stack(i+12) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 12
       lda_stack(i+13) and								// lda :STACKORIGIN+STACKWIDTH*3+10	; 13
//       adc_sbc(i+14) and								// adc|sbc				; 14
       sta_stack(i+15) then								// sta :STACKORIGIN+STACKWIDTH*3+10	; 15
     if argMatch(i+1, i+10) and
	argMatch(i+3, i+13) then
       begin
	listing[i+10] := listing[i];
	listing[i+13] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if adc_sbc(i+19) and								// adc|sbc				; 19

       lda_a(i) and									// lda P				; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda P+1				; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_a(i+6) and									// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+9			; 9
       add_sub(i+10) and								// add|sub H				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+9			; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+STACKWIDTH+9	; 12
       adc_sbc(i+13) and								// adc|sbc				; 13
       sta_stack(i+14) and								// sta :STACKORIGIN+STACKWIDTH+9	; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH*2+9	; 15
       adc_sbc(i+16) and								// adc|sbc				; 16
       sta_stack(i+17) and								// sta :STACKORIGIN+STACKWIDTH*2+9	; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*3+9	; 18
//       adc_sbc(i+19) and								// adc|sbc				; 19
       sta_stack(i+20) then								// sta :STACKORIGIN+STACKWIDTH*3+9	; 20
     if argMatch(i+9, i+11) and
	argMatch(i+12, i+14) and
	argMatch(i+15, i+17) and
	argMatch(i+18, i+20) and
	(listing[i+2] = listing[i+11]) and
	(listing[i+5] = listing[i+14]) and
	(listing[i+8] = listing[i+17]) then
       begin
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';

	exit(false);
       end;


    if adc_sbc(i+16) and								// adc|sbc				; 16

       lda_a(i) and									// lda 					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and									// lda 					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_a(i+6) and									// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_a(i+9) and									// lda 					; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+10			; 12
       add_sub(i+13) and								// add|sub				; 13
       sta_a(i+14) and									// sta 					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+10	; 15
//       adc_sbc(i+16) and								// adc|sbc				; 16
       sta_a(i+17) and									// sta					; 17
											//					; 18
       (adc_sbc(i+19) = false) then							// ~adc|sbc				; 19
     if argMatch(i+2, i+12) and
        argMatch(i+5, i+15) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if adc_sbc(i+10) and								// adc|sbc				; 10

       lda_a(i) and									// lda 					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and									// lda 					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_a(i+6) and									// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_a(i+9) and									// lda 					; 9
//       adc_sbc(i+10) and								// adc|sbc				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+10			; 12
       add_sub(i+13) and								// add|sub				; 13
       sta_a(i+14) and									// sta 					; 14
											//					; 15
       (adc_sbc(i+16) = false) then							// ~adc|sbc				; 16
     if argMatch(i+2, i+12) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if adc_sbc(i+9) and									// adc|sbc				; 9

       add_sub(i) and									// add|sub				; 0
       sta_val(i+1) and									// sta S				; 1	~:STACKORIGN
       lda_a(i+2) and									// lda 					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       sta_val(i+4) and									// sta S+1				; 4	~:STACKORIGN
       lda_a(i+5) and									// lda					; 5
       adc_sbc(i+6) and									// adc|sbc				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*2	; 7
       lda_a(i+8) and									// lda 					; 8
//       adc_sbc(i+9) and								// adc|sbc				; 9
       sta_stack(i+10) then								// sta :STACKORIGIN+STACKWIDTH*3	; 10
      begin
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9] := '';
	listing[i+10] := '';

	exit(false);
      end;


    if adc_sbc(i+9) and									// adc|sbc				; 9

       add_sub(i) and									// add|sub				; 0
       sta_val(i+1) and									// sta S				; 1	~:STACKORIGN
       lda_a(i+2) and									// lda 					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_a(i+5) and									// lda					; 5
       adc_sbc(i+6) and									// adc|sbc				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*2	; 7
       lda_a(i+8) and									// lda 					; 8
//       adc_sbc(i+9) and								// adc|sbc				; 9
       sta_stack(i+10) then								// sta :STACKORIGIN+STACKWIDTH*3	; 10
      begin
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


    if adc_sbc(i+9) and									// adc|sbc				; 9

       add_sub(i) and									// add|sub				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and									// lda 					; 2
       adc_sbc(i+3) and									// adc|sbc				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_a(i+5) and									// lda					; 5
       adc_sbc(i+6) and									// adc|sbc				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*2	; 7
       lda_a(i+8) and									// lda 					; 8
//       adc_sbc(i+9) and								// adc|sbc				; 9
       sta_stack(i+10) and								// sta :STACKORIGIN+STACKWIDTH*3	; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH*2	; 11
       sta_stack(i+12) and								// sta :STACKORIGIN+STACKWIDTH*3	; 12
       lda_stack(i+13) and								// lda :STACKORIGIN+STACKWIDTH		; 13
       sta_stack(i+14) and								// sta :STACKORIGIN+STACKWIDTH*2	; 14
       lda_stack(i+15) and								// lda :STACKORIGIN			; 15
       sta_stack(i+16) then								// sta :STACKORIGIN+STACKWIDTH		; 16
     if (argMatch(i+4, i+2) = false) and
     
        argMatch(i+1, i+15) and
	argMatch(i+4, i+13) and
	argMatch(i+7, i+11) and
	argMatch(i+10, i+12) and
	argMatch(i+11, i+14) and
	argMatch(i+13, i+16) then
      begin
	listing[i+1] := listing[i+4];

	listing[i+4] := listing[i+7];

	listing[i+7] := listing[i+10];

	listing[i+8]:= '';
	listing[i+9]:= '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';
	listing[i+14]:= '';
	listing[i+15]:= '';
	listing[i+16]:= '';

	exit(false);
      end;


    if adc(i+11) and									// adc					; 11

       lda_a(i) and (iy(i) = false) and							// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and						// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_a(i+4) and									// lda 					; 4
       asl_a(i+5) and									// asl @				; 5
       tay(i+6) and									// tay 					; 6
       lda_stack(i+7) and								// lda :STACKORIGIN			; 7
       add(i+8) and									// add					; 8
       sta(i+9) and									// sta					; 9
       lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH		; 10
//       adc(i+11) and									// adc					; 11
       sta(i+12) then									// sta 					; 12
     if argMatch(i+1, i+7) and
	argMatch(i+3, i+10) then
       begin
        listing[i+7]  := listing[i];
	listing[i+10] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if lda_a(i) and 									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+10			; 6
       sta_a(i+7) and									// sta					; 7
       sta_a(i+8) and									// sta					; 8
       lda_a(i+9) then									// lda					; 9
     if argMatch(i+2, i+6) then
      begin
	listing[i+6] := listing[i+5];
	listing[i+5] := listing[i+4];
	listing[i+4] := listing[i+3];

	listing[i+2] := listing[i+7];
	listing[i+3] := listing[i+8];

	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


    if lda_a(i) and 									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_val(i+6) and									// lda 					; 6	~:STACKORIGIN
       sta_val(i+7) and									// sta					; 7	~:STACKORIGN
       lda_val(i+8) and									// lda					; 8	~:STACKORIGIN
       sta_val(i+9) and									// sta					; 9	~:STACKORIGN
       lda_stack(i+10) and								// lda :STACKORIGIN+10			; 10
       sta_val(i+11) and								// sta					; 11	~:STACKORIGN
       lda_stack(i+12) and								// lda :STACKORIGIN+STACKWIDTH+10	; 12
       sta_val(i+13) then								// sta					; 13	~:STACKORIGN
     if argMatch(i+2, i+10) and
        argMatch(i+5, i+12) then
      begin
	listing[i+2] := listing[i+11];

	listing[i+5] := listing[i+13];

	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
      end;


    if adc(i+13) and									// adc					; 13

       lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_a(i+2) and									// lda 					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda_a(i+4) and									// lda 					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+10			; 6
       add(i+7) and									// add					; 7
       sta_a(i+8) and									// sta					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+10	; 9
       adc(i+10) and									// adc 					; 10
       sta_a(i+11) and									// sta					; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 12
//       adc(i+13) and									// adc					; 13
       sta_a(i+14) and									// sta					; 14
											//					; 15
       (adc(i+16) = false) then								//~adc					; 16
     if argMatch(i+1, i+6) and
	argMatch(i+3, i+9) and
	argMatch(i+5, i+12) then
       begin
	listing[i+6]  := listing[i];
	listing[i+9]  := listing[i+2];
	listing[i+12] := listing[i+4];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if adc(i+18) and									// adc 					; 18

       lda_a(i) and									// lda A				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_a(i+2) and									// lda A+1				; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda_a(i+4) and									// lda A+2				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda_a(i+6) and									// lda A+3				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+10			; 8
       add(i+9) and									// add 					; 9
       sta_A(i+10) and									// sta ERROR				; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH+10	; 11
       adc(i+12) and									// adc 					; 12
       sta_a(i+13) and									// sta ERROR+1				; 13
       lda_stack(i+14) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 14
       adc(i+15) and									// adc 					; 15
       sta_a(i+16) and									// sta ERROR+2				; 16
       lda_stack(i+17) and								// lda :STACKORIGIN+STACKWIDTH*3+10	; 17
//       adc(i+18) and									// adc 					; 18
       sta_a(i+19) then									// sta ERROR+3				; 19
     if argMatch(i+1, i+8) and
	argMatch(i+3, i+11) and
	argMatch(i+5, i+14) and
	argMatch(i+7, i+17) then
	begin
	listing[i+8]  := listing[i];
	listing[i+11] := listing[i+2];
	listing[i+14] := listing[i+4];
	listing[i+17] := listing[i+6];

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


    if adc(i+12) and									// adc 					; 12

       lda(i) and									// lda A				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda(i+2) and									// lda A+1				; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and									// lda A+2				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda(i+6) and									// lda A+3				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+10			; 8
       add(i+9) and									// add 					; 9
       sta_stack(i+10) and								// sta :STACKORIGIN+10			; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH+10	; 11
//       adc(i+12) and									// adc 					; 12
       sta_stack(i+13) and								// sta :STACKORIGIN+STACKWIDTH+10	; 13
       lda_im_0(i+14) and								// lda #$00				; 14
       adc_im_0(i+15) and								// adc #$00				; 15
       sta_stack(i+16) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 16
       lda_im_0(i+17) and								// lda #$00				; 17
       adc_im_0(i+18) and								// adc #$00				; 18
       sta_stack(i+19) then								// sta :STACKORIGIN+STACKWIDTH*3+10	; 19
     if argMatch(i+1, i+8) and
	argMatch(i+3, i+11) and
	argMatch(i+5, i+16) and
	argMatch(i+7, i+19) then
	begin
	listing[i+8]  := listing[i];
	listing[i+11] := listing[i+2];

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


    if adc(i+12) and									// adc 					; 12

       lda_a(i) and									// lda 					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_a(i+2) and									// lda 					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda_a(i+4) and									// lda					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+??			; 5
       lda_a(i+6) and									// lda					; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH+??	; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+10			; 8
       add(i+9) and									// add 					; 9
       sta_a(i+10) and									// sta ERROR				; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH+10	; 11
//       adc(i+12) and									// adc 					; 12
       sta_a(i+13) and									// sta ERROR+1				; 13
											//					; 14
       (adc(i+15) = false) then								//~adc					; 15
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


    if adc(i+8) and									// adc					; 8

       lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and								// lda :STACKORIGIN			; 4
       add(i+5) and									// add					; 5
       sta_a(i+6) and									// sta					; 6
       lda_stack(i+7) and								// lda :STACKORIGIN+STACKWIDTH		; 7
//       adc(i+8) and									// adc					; 8
       sta_a(i+9) then									// sta					; 9
     if argMatch(i+1, i+4) and
	argMatch(i+3, i+7) and
	(argMatch(i+6, i+2) = false) then
      begin
	listing[i+4] := listing[i];
	listing[i+7] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if adc(i+6) and									// adc					; 6

       lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       add(i+3) and (add_stack(i+3) = false) and					// add					; 3
       sta_a(i+4) and 									// sta					; 4
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
//       adc(i+6) and									// adc					; 6
       sta_a(i+7) then									// sta					; 7
     if argMatch(i+1, i+5) and
        (argMatch(i, i+4) = false) then
      begin
	listing[i+5] := listing[i];
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if add_sub_val(i) and								// add|sub				; 0		2023-01-26
       sta_val(i+1) and									// sta A				; 1	~:STACKORIGN
       lda_a(i+2) and									// lda 					; 2
       adc_sbc_val(i+3) and								// adc|sbc				; 3
       sta_val(i+4) and									// sta A+1				; 4	~:STACKORIGN
       lda_a(i+5) and									// lda A				; 5
       sta_stack(i+6) and								// sta :STACKORIGIN			; 6
       lda_a(i+7) and									// lda A+1				; 7
       sta_stack(i+8) then								// sta :STACKORIGIN+STACKWIDTH		; 8
     if argMatch(i+1, i+5) and
        argMatch(i+4, i+7) then
      begin
	listing[i+1] := listing[i+6];

	listing[i+4] := listing[i+8];

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


    if adc_im(i+10) and									// adc #				; 10

       lda_im(i) and									// lda #				; 0
       add_im(i+1) and									// add #				; 1
       sta_a(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_im(i+3) and									// lda #				; 3
       adc_im(i+4) and									// adc #$00				; 4
       sta_a(i+5) and									// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_im(i+6) and									// lda #				; 6
       adc_im(i+7) and									// adc #				; 7
       sta_a(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_im(i+9) and									// lda #				; 9
//       adc_im(i+10) and								// adc #				; 10
       sta_a(i+11) then									// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
      begin
//	p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16 + GetVAL(copy(listing[i+9], 6, 256)) shl 24;
//	err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16 + GetVAL(copy(listing[i+10], 6, 256)) shl 24;

	p := GetDWORD(i, i+3, i+6, i+9);
	q := GetDWORD(i+1, i+4, i+7, i+10);

	p := p + q;

	listing[i]   := #9'lda #' + HexByte(byte(p));
	listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
	listing[i+6] := #9'lda #' + HexByte(byte(p shr 16));
	listing[i+9] := #9'lda #' + HexByte(byte(p shr 24));

	listing[i+1] := '';
	listing[i+4] := '';
	listing[i+7] := '';
	listing[i+10] := '';

	exit(false);
       end;


    if adc_im(i+4) and									// adc #				; 4

       lda_im(i) and 									// lda #				; 0
       add_im(i+1) and (data(i+1) = false) and						// add #				; 1
       sta_a(i+2) and									// sta					; 2
       lda_im(i+3) and									// lda #				; 3
//       adc_im(i+4) and								// adc #				; 4
       sta_a(i+5) and									// sta					; 5
											//					; 6
       (adc(i+7) = false) then								//~adc					; 7
     begin
      p := GetWORD(i, i+3) + GetWORD(i+1, i+4);

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+1] := '';
      listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+4] := '';

      exit(false);
     end;


    if lda_im(i) and 									// lda #				; 0
       add_im(i+1) and									// add #				; 1
       sta_a(i+2) and									// sta					; 2
											//					; 3
       (adc(i+4) = false) then								//~adc					; 4
     begin
      p := GetBYTE(i) + GetBYTE(i+1);

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+1] := '';

      exit(false);
     end;


    if //lda_a(i) and (lda_im(i) = false) and						// lda					; 0
       sub_im(i+1) and 									// sub #				; 1
       add_im(i+2) and 									// add #				; 2
       (sta_a(i+3) or tay(i+3)) and							// sta|tay				; 3
											//					; 4
       (adc_sbc(i+5) = false) then							//~adc|sbc				; 5
     begin
      p := -GetBYTE(i+1) + GetBYTE(i+2);

      listing[i+1] := '';
      listing[i+2] := #9'add #' + HexByte(byte(p));

      exit(false);
     end;


    if //lda_a(i) and (lda_im(i) = false) and						// lda					; 0
       add_im(i+1) and									// add #				; 1
       sub_im(i+2) and									// sub #				; 2
       (sta_a(i+3) or tay(i+3)) and							// sta|tay				; 3
											//					; 4
       (adc_sbc(i+5) = false) then							//~adc|sbc				; 5
     begin
      p := GetBYTE(i+1) - GetBYTE(i+2);

      listing[i+1] := #9'add #' + HexByte(byte(p));
      listing[i+2] := '';

      exit(false);
     end;


    if //lda_a(i) and (lda_im(i) = false) and						// lda					; 0
       add_im(i+1) and 									// add #				; 1
       add_im(i+2) and									// add #				; 2
       (sta_a(i+3) or tay(i+3)) and							// sta|tay				; 3
											//					; 4
       (adc(i+5) = false) then								//~adc					; 5
     begin
      p := GetBYTE(i+1) + GetBYTE(i+2);

      listing[i+1] := '';
      listing[i+2] := #9'add #' + HexByte(byte(p));

      exit(false);
     end;


    if //lda_a(i) and (lda_im(i) = false) and						// lda					; 0
       sub_im(i+1) and									// sub #				; 1
       sub_im(i+2) and 									// sub #				; 2
       (sta_a(i+3) or tay(i+3)) and							// sta|tay				; 3
											//					; 4
       (sbc(i+5) = false) then								//~sbc					; 5
     begin
      p := GetBYTE(i+1) + GetBYTE(i+2);

      listing[i+1] := '';
      listing[i+2] := #9'sub #' + HexByte(byte(p));

      exit(false);
     end;


    if lda_a(i) and (lda_im(i) = false) and						// lda					; 0
       add_sub_im(i+1) and 								// add #|sub #				; 1
       add_sub(i+2) and (add_sub_im(i+2) = false) and					// add|sub				; 2
       add_sub_im(i+3) then								// add #|sub #				; 3
     begin
      tmp:=listing[i+2];

      listing[i+2] := listing[i+1];
      listing[i+1] := tmp;

      exit(false);
     end;


    if lda_im(i) and 									// lda #				; 0
       add_im(i+1) and									// add #				; 1
       sta_a(i+2) and									// sta 					; 2
       lda_im(i+3) and									// lda #				; 3
       adc_im(i+4) and									// adc #				; 4
       sta_a(i+5) and     								// sta 					; 5
       lda_im(i+6) and       								// lda #				; 6
       adc_im(i+7) and									// adc #				; 7
       sta_a(i+8) and									// sta 					; 8
											//					; 9
       (adc(i+10) = false) then								//~adc					; 10
     begin

//      p := GetVAL(copy(listing[i], 6, 256)) + GetVAL(copy(listing[i+3], 6, 256)) shl 8 + GetVAL(copy(listing[i+6], 6, 256)) shl 16;
//      err := GetVAL(copy(listing[i+1], 6, 256)) + GetVAL(copy(listing[i+4], 6, 256)) shl 8 + GetVAL(copy(listing[i+7], 6, 256)) shl 16;

      p := GetTRIPLE(i, i+3, i+6);
      q := GetTRIPLE(i+1, i+4, i+7);

      p := p + q;

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+1] := '';
      listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+4] := '';
      listing[i+6] := #9'lda #' + HexByte(byte(p shr 16));
      listing[i+7] := '';

      exit(false);
     end;


    if adc_stack(i+14) and								// adc :STACKORIGIN+STACKWIDTH		; 14

       lda_im(i) and									// lda #				; 0
       add(i+1) and (add_stack(i+1) = false) and					// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_im(i+3) and									// lda #				; 3
       adc(i+4) and (adc_stack(i+1) = false) and					// adc					; 4
       asl_stack(i+5) and								// asl :STACKORIGIN			; 5
       rol_a(i+6) and									// rol @				; 6
       asl_stack(i+7) and								// asl :STACKORIGIN			; 7
       rol_a(i+8) and									// rol @				; 8
       sta_stack(i+9) and								// sta :STACKORIGIN+STACKWIDTH		; 9
       lda_im(i+10) and									// lda #				; 10
       add_stack(i+11) and								// add :STACKORIGIN			; 11
       sta_a(i+12) and									// sta P				; 12
       lda_im(i+13) and									// lda #				; 13
//       adc_stack(i+14) and								// adc :STACKORIGIN+STACKWIDTH		; 14
       sta_a(i+15) then									// sta P+1				; 15
      if argMatch(i+2, i+5) and
	 argMatch(i+5, i+11) and
	 argMatch(i+9, i+14) then
     begin
      p := GetWORD(i, i+3) * 4 + GetWORD(i+10, i+13);

      listing[i+10] := #9'lda #' + HexByte(byte(p));

      listing[i+13] := #9'lda #' + HexByte(byte(p shr 8));

      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

      listing[i+3] := '';
      listing[i+4] := #9'lda ' + copy(listing[i+4], 6, 256);

      exit(false);
     end;


    if adc_stack(i+14) and								// adc :STACKORIGIN+STACKWIDTH		; 14

       lda_val(i) and									// lda					; 0
       add_im(i+1) and									// add #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and									// lda					; 3
       adc_im(i+4) and									// adc #				; 4
       asl_stack(i+5) and								// asl :STACKORIGIN			; 5
       rol_a(i+6) and									// rol @				; 6
       asl_stack(i+7) and								// asl :STACKORIGIN			; 7
       rol_a(i+8) and									// rol @				; 8
       sta_stack(i+9) and								// sta :STACKORIGIN+STACKWIDTH		; 9
       lda_im(i+10) and									// lda #				; 10
       add_stack(i+11) and								// add :STACKORIGIN			; 11
       sta_a(i+12) and									// sta P				; 12
       lda_im(i+13) and									// lda #				; 13
//       adc_stack(i+14) and								// adc :STACKORIGIN+STACKWIDTH		; 14
       sta_a(i+15) then									// sta P+1				; 15
      if argMatch(i+2, i+5) and
	 argMatch(i+5, i+11) and
	 argMatch(i+9, i+14) then
     begin
      p := GetWORD(i+1, i+4) * 4 + GetWORD(i+10, i+13);

      listing[i+10] := #9'lda #' + HexByte(byte(p));

      listing[i+13] := #9'lda #' + HexByte(byte(p shr 8));

      listing[i+1]   := '';

      listing[i+4] := '';

      exit(false);
     end;


    if adc_stack(i+12) and								// adc :STACKORIGIN+STACKWIDTH		; 12

       lda_im(i) and									// lda #				; 0
       add(i+1) and (add_stack(i+1) = false) and					// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_im(i+3) and									// lda #				; 3
       adc(i+4) and (adc_stack(i+1) = false) and					// adc					; 4
       asl_stack(i+5) and								// asl :STACKORIGIN			; 5
       rol_a(i+6) and									// rol @				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH		; 7
       lda_im(i+8) and									// lda #				; 8
       add_stack(i+9) and								// add :STACKORIGIN			; 9
       sta_a(i+10) and									// sta P				; 10
       lda_im(i+11) and									// lda #				; 11
//       adc_stack(i+12) and								// adc :STACKORIGIN+STACKWIDTH		; 12
       sta_a(i+13) then									// sta P+1				; 13
      if argMatch(i+2, i+5) and
	 argMatch(i+5, i+9) and
	 argMatch(i+7, i+12) then
     begin
      p := GetWORD(i, i+3) * 2 + GetWORD(i+8, i+11);

      listing[i+8]  := #9'lda #' + HexByte(byte(p));

      listing[i+11] := #9'lda #' + HexByte(byte(p shr 8));

      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

      listing[i+3] := '';
      listing[i+4] := #9'lda ' + copy(listing[i+4], 6, 256);

      exit(false);
     end;


    if adc_stack(i+12) and								// adc :STACKORIGIN+STACKWIDTH		; 12

       lda_val(i) and									// lda					; 0
       add_im(i+1) and									// add #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and									// lda					; 3
       adc_im(i+4) and									// adc #				; 4
       asl_stack(i+5) and								// asl :STACKORIGIN			; 5
       rol_a(i+6) and									// rol @				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH		; 7
       lda_im(i+8) and									// lda #				; 8
       add_stack(i+9) and								// add :STACKORIGIN			; 9
       sta_a(i+10) and									// sta P				; 10
       lda_im(i+11) and									// lda #				; 11
//       adc_stack(i+12) and								// adc :STACKORIGIN+STACKWIDTH		; 12
       sta_a(i+13) then									// sta P+1				; 13
      if argMatch(i+2, i+5) and
	 argMatch(i+5, i+9) and
	 argMatch(i+7, i+12) then
     begin
      p := GetWORD(i+1, i+4) * 2 + GetWORD(i+8, i+11);

      listing[i+8]  := #9'lda #' + HexByte(byte(p));

      listing[i+11] := #9'lda #' + HexByte(byte(p shr 8));

      listing[i+1]   := '';

      listing[i+4] := '';

      exit(false);
     end;


    if adc_im(i+10) and									// adc #$00				; 10

       lda_im(i) and									// lda #				; 0
       add(i+1) and									// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_im(i+3) and									// lda #				; 3
       adc(i+4) and									// adc					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_im(i+7) and (data(i+7) = false) and						// add #				; 7
       sta_a(i+8) and									// sta P				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
//       adc_im(i+10) and								// adc #$00				; 10
       sta_a(i+11) then									// sta P+1				; 11
      if argMatch(i+2, i+6) and
	 argMatch(i+5, i+9) then
     begin

      p := GetWORD(i, i+3) + GetWORD(i+7, i+10);

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+2] := listing[i+8];
      listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      exit(false);
     end;


    if adc_im(i+10) and									// adc #				; 10

       lda_a(i) and									// lda W				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda W+1				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_im(i+7) and									// add #				; 7
       sta_a(i+8) and									// sta 					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
//       adc_im(i+10) and								// adc #				; 10
       sta_a(i+11) then									// sta 					; 11
      if argMatch(i+2, i+6) and
	 argMatch(i+5, i+9) then
     begin
      p := -1 * GetWORD(i+1, i+4) + GetWORD(i+7, i+10);

      listing[i+1] := #9'add #' + HexByte(byte(p));
      listing[i+4] := #9'adc #' + HexByte(byte(p shr 8));

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

       lda_a(i) and									// lda W				; 0
       add_im(i+1) and									// add #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda W+1				; 3
       adc_im(i+4) and									// adc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       sub_im(i+7) and									// sub #				; 7
       sta_a(i+8) and									// sta 					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
//       sbc_im(i+10) and								// sbc #				; 10
       sta_a(i+11) then									// sta 					; 11
      if argMatch(i+2, i+6) and
	 argMatch(i+5, i+9) then
     begin
      p := GetWORD(i+1, i+4) - GetWORD(i+7, i+10);

      if p < 0 then begin
        p:=abs(p);

        listing[i+1] := #9'sub #' + HexByte(byte(p));
        listing[i+4] := #9'sbc #' + HexByte(byte(p shr 8));

        listing[i+2] := listing[i+8];
        listing[i+5] := listing[i+11];
      end else begin
        listing[i+1] := #9'add #' + HexByte(byte(p));
        listing[i+4] := #9'adc #' + HexByte(byte(p shr 8));

        listing[i+2] := listing[i+8];
        listing[i+5] := listing[i+11];
      end;

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      exit(false);
     end;


    if adc_im(i+22) and									// adc #				; 22

       lda_a(i) and									// lda W				; 0
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
       add_im(i+13) and									// add #				; 13
       sta_a(i+14) and									// sta W				; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_im(i+16) and									// adc #				; 16
       sta_a(i+17) and									// sta W+1				; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*2	; 18
       adc_im(i+19) and									// adc #				; 19
       sta_a(i+20) and									// sta W+2				; 20
       lda_stack(i+21) and								// lda :STACKORIGIN+STACKWIDTH*3+9	; 21
//       adc_im(i+22) and								// adc #				; 22
       sta_a(i+23) then									// sta W+3				; 23
      if argMatch(i+2, i+12) and
	 argMatch(i+5, i+15) and
	 argMatch(i+8, i+18) and
	 argMatch(i+11, i+21) then
     begin
      p := GetDWORD(i+1, i+4, i+7, i+10);
      q := GetDWORD(i+13, i+16, i+19, i+22);

      p := p + q;

      listing[i+1] := #9'add #' + HexByte(byte(p));
      listing[i+4] := #9'adc #' + HexByte(byte(p shr 8));

      listing[i+7] := #9'adc #' + HexByte(byte(p shr 16));
      listing[i+10] := #9'adc #' + HexByte(byte(p shr 24));

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


    if adc_im(i+22) and									// adc #				; 22

       lda_im(i) and									// lda #				; 0
       add(i+1) and 									// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_im(i+3) and									// lda #				; 3
       adc(i+4) and									// adc					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_im(i+6) and									// lda #				; 6
       adc(i+7) and									// adc					; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_im(i+9) and									// lda #				; 9
       adc(i+10) and									// adc					; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       add_im(i+13) and									// add #				; 13
       sta_a(i+14) and									// sta					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH		; 15
       adc_im(i+16) and									// adc #				; 16
       sta_a(i+17) and									// sta					; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*2	; 18
       adc_im(i+19) and									// adc #				; 19
       sta_a(i+20) and									// sta					; 20
       lda_stack(i+21) and								// lda :STACKORIGIN+STACKWIDTH*3	; 21
//       adc_im(i+22) and								// adc #				; 22
       sta_a(i+23) then									// sta					; 23
      if argMatch(i+2, i+12) and
	 argMatch(i+5, i+15) and
	 argMatch(i+8, i+18) and
	 argMatch(i+11, i+21) then
     begin
      p := GetDWORD(i, i+3, i+6, i+9);
      q := GetDWORD(i+13, i+16, i+19, i+22);

      p := p + q;

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+3] := #9'lda #' + HexByte(byte(p shr 8));

      listing[i+6] := #9'lda #' + HexByte(byte(p shr 16));
      listing[i+9] := #9'lda #' + HexByte(byte(p shr 24));

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


    if adc_im(i+22) and									// adc #				; 22

       lda_a(i) and									// lda W				; 0
       sub_im(i+1) and									// sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda W+1				; 3
       sbc_im(i+4) and									// sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_a(i+6) and									// lda W+2				; 6
       sbc_im(i+7) and									// sbc #				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_a(i+9) and									// lda W+3				; 9
       sbc_im(i+10) and									// sbc #				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       add_im(i+13) and									// add #				; 13
       sta_a(i+14) and									// sta W				; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_im(i+16) and									// adc #				; 16
       sta_a(i+17) and									// sta W+1				; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*2+9	; 18
       adc_im(i+19) and									// adc #				; 19
       sta_a(i+20) and									// sta W+2				; 20
       lda_stack(i+21) and								// lda :STACKORIGIN+STACKWIDTH*3+9	; 21
//       adc_im(i+22) and								// adc #				; 22
       sta_a(i+23) then									// sta W+3				; 23
      if argMatch(i+2, i+12) and
	 argMatch(i+5, i+15) and
	 argMatch(i+8, i+18) and
	 argMatch(i+11, i+21) then
     begin
      p := GetDWORD(i+1, i+4, i+7, i+10);
      q := GetDWORD(i+13, i+16, i+19, i+22);

      p := -p + q;

      listing[i+1] := #9'add #' + HexByte(byte(p));
      listing[i+4] := #9'adc #' + HexByte(byte(p shr 8));

      listing[i+7] := #9'adc #' + HexByte(byte(p shr 16));
      listing[i+10] := #9'adc #' + HexByte(byte(p shr 24));

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


   if adc_im(i+11) and									// adc #				; 11

      lda_a(i) and									// lda W				; 0
      add_im(i+1) and (data(i+1) = false) and						// add #				; 1
      sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
      iny(i+3) and									// iny					; 3
      lda_a(i+4) and									// lda W+1				; 4
      adc_im(i+5) and									// adc #				; 5
      sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH+9	; 6
      lda_stack(i+7) and								// lda :STACKORIGIN+9			; 7
      add_im(i+8) and (data(i+8) = false) and						// add #				; 8
      sta_a(i+9) and									// sta W				; 9
      lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH+9	; 10
//      adc_im(i+11) and								// adc #				; 11
      sta_a(i+12) then									// sta W+1				; 12
      if argMatch(i+2, i+7) and
	 argMatch(i+6, i+10) then
     begin
      p := GetWORD(i+1, i+5) + GetWORD(i+8, i+11);

      listing[i+1] := #9'add #' + HexByte(byte(p));
      listing[i+2] := listing[i+9];

      listing[i+5] := #9'adc #' + HexByte(byte(p shr 8));
      listing[i+6] := listing[i+12];

      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


   if adc_im(i+11) and									// adc #				; 11

      lda_im(i) and									// lda #				; 0
      add(i+1) and									// add					; 1
      sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
      iny(i+3) and									// iny					; 3
      lda_im(i+4) and									// lda #				; 4
      adc(i+5) and									// adc					; 5
      sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH+9	; 6
      lda_stack(i+7) and								// lda :STACKORIGIN+9			; 7
      add_im(i+8) and (data(i+8) = false) and						// add #				; 8
      sta_a(i+9) and									// sta W				; 9
      lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH+9	; 10
//      adc_im(i+11) and								// adc #				; 11
      sta_a(i+12) then									// sta W+1				; 12
      if argMatch(i+2, i+7) and
	 argMatch(i+6, i+10) then
     begin
      p := GetWORD(i, i+4) + GetWORD(i+8, i+11);

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+2] := listing[i+9];

      listing[i+4] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+6] := listing[i+12];

      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


   if sbc_im(i+11) and									// sbc #				; 11

      lda_a(i) and									// lda W				; 0
      add_im(i+1) and									// add #				; 1
      sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
      iny(i+3) and									// iny					; 3
      lda_a(i+4) and									// lda W+1				; 4
      adc_im(i+5) and									// adc #				; 5
      sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH+9	; 6
      lda_stack(i+7) and								// lda :STACKORIGIN+9			; 7
      sub_im(i+8) and									// sub #				; 8
      sta_a(i+9) and									// sta W				; 9
      lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH+9	; 10
//      sbc_im(i+11) and								// sbc #				; 11
      sta_a(i+12) then									// sta W+1				; 12
      if argMatch(i+2, i+7) and
	 argMatch(i+6, i+10) then
     begin
      p := GetWORD(i+1, i+5) - GetWORD(i+8, i+11);

      if p < 0 then begin
       p := abs(p);

       listing[i+1] := #9'sub #' + HexByte(byte(p));
       listing[i+2] := listing[i+9];

       listing[i+5] := #9'sbc #' + HexByte(byte(p shr 8));
       listing[i+6] := listing[i+12];
      end else begin
       listing[i+1] := #9'add #' + HexByte(byte(p));
       listing[i+2] := listing[i+9];

       listing[i+5] := #9'adc #' + HexByte(byte(p shr 8));
       listing[i+6] := listing[i+12];
      end;

      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


   if sbc_im(i+11) and									// sbc #				; 11

      lda_im(i) and									// lda #				; 0
      add(i+1) and									// add					; 1
      sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
      iny(i+3) and									// iny					; 3
      lda_im(i+4) and									// lda #				; 4
      adc(i+5) and									// adc					; 5
      sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH+9	; 6
      lda_stack(i+7) and								// lda :STACKORIGIN+9			; 7
      sub_im(i+8) and									// sub #				; 8
      sta_a(i+9) and									// sta W				; 9
      lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH+9	; 10
//      sbc_im(i+11) and								// sbc #				; 11
      sta_a(i+12) then									// sta W+1				; 12
      if argMatch(i+2, i+7) and
	 argMatch(i+6, i+10) then
     begin
      p := GetWORD(i, i+4) - GetWORD(i+8, i+11);

      listing[i]   := #9'lda #' + HexByte(byte(p));
      listing[i+2] := listing[i+9];

      listing[i+4] := #9'lda #' + HexByte(byte(p shr 8));
      listing[i+6] := listing[i+12];

      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


   if adc_im(i+10) and									// adc #				; 10

      lda_a(i) and									// lda W				; 0
      add_im(i+1) and (data(i+1) = false) and						// add #				; 1
      sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
      lda_a(i+3) and									// lda W+1				; 3
      adc_im(i+4) and									// adc #				; 4
      sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
      lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
      add_im(i+7) and (data(i+7) = false) and						// add #				; 7
      sta_a(i+8) and									// sta W				; 8
      lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
//      adc_im(i+10) and								// adc #				; 10
      sta_a(i+11) then									// sta W+1				; 11
      if argMatch(i+2, i+6) and
	 argMatch(i+5, i+9) then
     begin
      p := GetWORD(i+1, i+4) + GetWORD(i+7, i+10);

      listing[i+1] := #9'add #' + HexByte(byte(p));
      listing[i+2] := listing[i+8];

      listing[i+4] := #9'adc #' + HexByte(byte(p shr 8));
      listing[i+5] := listing[i+11];

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';

      exit(false);
     end;


    if adc_im_0(i+10) and								// adc #$00				; 10

       lda(i) and (lda_stack(i) = false) and						// lda K				; 0
       add_im_1(i+1) and								// add #$01				; 1
       sta(i+2) and									// sta K				; 2
       lda(i+3) and									// lda K+1				; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta(i+5) and									// sta K+1				; 5
       lda(i+6) and									// lda K+2				; 6
       adc_im_0(i+7) and								// adc #$00				; 7
       sta(i+8) and									// sta K+2				; 8
       lda(i+9) and									// lda K+3				; 9
//       adc_im_0(i+10) and								// adc #$00				; 10
       sta(i+11) then									// sta K+3				; 11
      if argMatch(i, i+2) and
	 argMatch(i+3, i+5) and
	 argMatch(i+6, i+8) and
	 argMatch(i+9, i+11) then
     begin
	listing[i]   := #9'inc ' + copy(listing[i], 6, 256);
	listing[i+1] := #9'bne @+';
	listing[i+2] := #9'inc ' + copy(listing[i+3], 6, 256);
	listing[i+3] := #9'bne @+';
	listing[i+4] := #9'inc ' + copy(listing[i+6], 6, 256);
	listing[i+5] := #9'bne @+';
	listing[i+6] := #9'inc ' + copy(listing[i+9], 6, 256);
	listing[i+7] := '@';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
    end;


    if adc_im_0(i+4) and								// adc #$00				; 4

       lda_val(i) and (lda_im_0(i) = false) and						// lda W				; 0	~:STACKORIGIN
       add(i+1) and (add_im_0(i+1) = false) and						// add 					; 1
       sta_a(i+2) and 									// sta W				; 2
       lda_a(i+3) and									// lda W+1				; 3
//       adc_im_0(i+4) and								// adc #$00				; 4
       sta_a(i+5) and									// sta W+1				; 5
											//					; 6
       (adc(i+7) = false) then								//~adc					; 7
     if argMatch(i, i+2) and
	argMatch(i+3, i+5) and
	(pos(listing[i], listing[i+3]) > 0) then
     begin

	if add_im_1(i+1) then begin
	 listing[i]   := #9'inc ' + copy(listing[i], 6, 256);
	 listing[i+1] := #9'sne';
	 listing[i+2] := #9'inc ' + copy(listing[i+3], 6, 256);
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	end else begin
	 listing[i+3] := #9'scc';
	 listing[i+4] := #9'inc ' + copy(listing[i+5], 6, 256);
	 listing[i+5] := '';
	end;

	exit(false);
     end;


    if adc_sbc(i+7) and									// adc|sbc				; 7

       lda(i) and 									// lda 					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda(i+2) and 									// lda					; 2
       add_sub(i+3) and	 								// add|sub				; 3
       ldy(i+4) and									// ldy :STACKORIGIN+9			; 4
       sta(i+5) and 									// sta					; 5
       lda_stack(i+6) and 								// lda :STACKORIGIN+10			; 6
//       adc_sbc(i+7) and								// adc|sbc				; 7
       sta(i+8) then									// sta					; 8
     if argMatch(i+1, i+6) and
        (argMatch(i+1, i+4) = false) then
       begin
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if adc_im_0(i+7) and								// adc #$00				; 7

       lda(i) and (iy(i) = false) and							// lda					; 0
       add(i+1) and (iy(i+1) = false) and						// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH		; 2
       lda(i+3) and									// lda					; 3
       add(i+4) and									// add 					; 4
       (sta(i+5) or tay(i+5)) and							// sta|tay				; 5
       lda_stack(i+6) then								// lda :STACKORIGIN+STACKWIDTH		; 6
//       adc_im_0(i+7) then								// adc #$00				; 7
    if argMatch(i+2, i+6) then
       begin
	listing[i+6] := listing[i];
	listing[i+7] := #9'adc ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if adc_sbc_val(i+6) and								// adc|sbc 				; 6

       lda_val(i) and (iy(i) = false) and						// lda					; 0	~lda :STACKORIGIN
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN+9			; 2
       add_sub_val(i+3) and								// add|sub				; 3
       tay(i+4) and									// tay					; 4
       lda_stack(i+5) and								// lda :STACKORIGIN+STACKWIDTH+9	; 5
//       adc_sbc_val(i+6) and								// adc|sbc 				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH+9	; 7
       lda_stack(i+8) then								// lda :STACKORIGIN+10			; 8
    if argMatch(i+1, i+8) and
       (argMatch(i+1, i+2) = false) and
       (argMatch(i+1, i+5) = false) and
       argMatch(i+5, i+7) then
       begin
        listing[i+8] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if sta(i) and									// sta :STACKORIGIN+9			; 0
       lda(i+1) and									// lda					; 1		~lda.adr
       add_im_0(i+2) and								// add #$00				; 2
       sta(i+3) and 									// sta					; 3
       lda(i+4) and									// lda					; 4		~lda.adr
       adc(i+5) and									// adc :STACKORIGIN+9			; 5
       sta(i+6) then 									// sta	 				; 6
     if argMatch(i, i+5) then
       begin
	listing[i+2] := '';

	listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

	exit(false);
       end;


    if lda(i) and (lda_stack(i) = false) and						// lda					; 0		~lda adr.
       add_im_0(i+1) and								// add #$00				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       adc_im(i+4) and (adc_im_0(i+4) = false) and					// adc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       add_sub_stack(i+7) then								// add|sub :STACKORIGIN			; 7
     if argMatch(i+2, i+7) then
       begin

	if add_stack(i+7) then
	  listing[i+7] := #9'add ' + copy(listing[i], 6, 256)
	else
	  listing[i+7] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if sta_stack(i) and									// sta :STACKORIGIN			; 0
       lda(i+1) and (lda_im(i+1) = false) and						// lda					; 1		~lda adr.
       add_im_1(i+2) and								// add #$01				; 2
       add_stack(i+3) and								// add :STACKORIGIN			; 3
       tay(i+4) then									// tay					; 4
      if argMatch(i, i+3) then
       begin
	listing[i] := '';

	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := #9'tay';
	listing[i+3] := #9'iny';

	listing[i+4] := '';

	exit(false);
       end;


// add !!!
    if sta(i) and									// sta A				; 0
       lda_stack(i+1) and								// lda :STACKORIGIN+9			; 1
       sta(i+2) and									// sta D				; 2
       lda(i+3) and (iy(i+3) = false) and						// lda 					; 3		~lda adr.
       add(i+4) and 									// add A				; 4
       sta(i+5) and (iy(i+5) = false) and						// sta D+1				; 5
											//					; 6
       (adc(i+7) = false) then								//~adc					; 7
     if argMatch(i, i+4) and
	(pos(listing[i+2], listing[i+5]) > 0) then
       begin
	listing[i] := #9'add ' + copy(listing[i+3], 6, 256);

	listing[i+3] := listing[i+1];
	listing[i+4] := listing[i+2];

	listing[i+1] := listing[i+5];

	listing[i+2] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and 									// lda					; 4
       asl_a(i+5) and									// asl @				; 5
       add_sub_stack(i+6) and								// add|sub :STACKORIGIN			; 6
       sta(i+7) and									// sta					; 7
       lda_stack(i+8) then								// lda :STACKORIGIN+STACKWIDTH		; 8
     if argMatch(i+1, i+6) and
	argMatch(i+3, i+8) then
      begin

        if add_stack(i+6) then
	 listing[i+6] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+6] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i+8] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if adc_stack(i+18) and								// adc :STACKORIGIN+STACKWIDTH*3+10	; 18

       lda(i) and									// lda A				; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda(i+2) and									// lda A+1				; 2		~lda adr.
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and									// lda A+2				; 4		~lda adr.
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda(i+6) and									// lda A+3				; 6		~lda adr.
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       lda_a(i+8) and									// lda ERROR				; 8
       add_stack(i+9) and								// add :STACKORIGIN+10			; 9
       sta_a(i+10) and									// sta ERROR				; 10
       lda_a(i+11) and									// lda ERROR+1				; 11
       adc_stack(i+12) and								// adc :STACKORIGIN+STACKWIDTH+10	; 12
       sta_a(i+13) and									// sta ERROR+1				; 13
       lda_a(i+14) and									// lda ERROR+2				; 14
       adc_stack(i+15) and								// adc :STACKORIGIN+STACKWIDTH*2+10	; 15
       sta_a(i+16) and									// sta ERROR+2				; 16
       lda_a(i+17) and									// lda ERROR+3				; 17
//       adc_stack(i+18) and								// adc :STACKORIGIN+STACKWIDTH*3+10	; 18
       sta_a(i+19) then									// sta ERROR+3				; 19
     if argMatch(i+1, i+9) and
	argMatch(i+3, i+12) and
	argMatch(i+5, i+15) and
	argMatch(i+7, i+18) then
	begin
	listing[i+9]  := #9'add ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'adc ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'adc ' + copy(listing[i+6], 6, 256);

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


    if adc_im_0(i+9) and								// adc #$00				; 9

       lda(i) and (lda_stack(i) = false) and						// lda 					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda 					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and (lda_stack(i+4) = false) and					// lda					; 4
       add_sub_val(i+5) and								// add|sub				; 5
       add_stack(i+6) and								// add :STACKORIGIN			; 6
       tay(i+7) and									// tay					; 7
       lda_stack(i+8) and								// lda :STACKORIGIN+STACKWIDTH		; 8
//       adc_im_0(i+9) and								// adc #$00				; 9
       sta_stack(i+10) then								// sta :STACKORIGIN+STACKWIDTH		; 10
     if argMatch(i+1, i+6) and
	argMatch(i+3, i+8) then
	begin
	listing[i+6]  := #9'add ' + copy(listing[i], 6, 256);

	listing[i+8] := listing[i+2];

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
	end;


    if adc_im_0(i+7) and								// adc #$00				; 7

       lda(i) and (lda_stack(i) = false) and						// lda 					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda					; 2
       add_sub_val(i+3) and								// add|sub				; 3
       add_stack(i+4) and								// add :STACKORIGIN			; 4
       tay(i+5) and									// tay					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH		; 6
//       adc_im_0(i+7) and								// adc #$00				; 7
       sta_stack(i+8) then								// sta :STACKORIGIN+STACKWIDTH		; 8
     if argMatch(i+1, i+4) then
	begin
	 listing[i+4]  := #9'add ' + copy(listing[i], 6, 256);

	 listing[i] := '';
	 listing[i+1] := '';

	 exit(false);
	end;


    if adc_stack(i+17) and								// adc :STACKORIGIN+STACKWIDTH*3+10	; 17

       lda(i) and									// lda A				; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda(i+2) and									// lda A+1				; 2		~lda adr.
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and									// lda A+2				; 4		~lda adr.
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 6
       lda_a(i+7) and									// lda ERROR				; 7
       add_stack(i+8) and								// add :STACKORIGIN+10			; 8
       sta_a(i+9) and									// sta ERROR				; 9
       lda_a(i+10) and									// lda ERROR+1				; 10
       adc_stack(i+11) and								// adc :STACKORIGIN+STACKWIDTH+10	; 11
       sta_a(i+12) and									// sta ERROR+1				; 12
       lda_a(i+13) and									// lda ERROR+2				; 13
       adc_stack(i+14) and								// adc :STACKORIGIN+STACKWIDTH*2+10	; 14
       sta_a(i+15) and									// sta ERROR+2				; 15
       lda_a(i+16) and									// lda ERROR+3				; 16
//       adc_stack(i+17) and								// adc :STACKORIGIN+STACKWIDTH*3+10	; 17
       sta_a(i+18) then									// sta ERROR+3				; 18
     if argMatch(i+1, i+8) and
	argMatch(i+3, i+11) and
	argMatch(i+5, i+14) and
	argMatch(i+6, i+17) then
	begin
	listing[i+8]  := #9'add ' + copy(listing[i], 6, 256);
	listing[i+11] := #9'adc ' + copy(listing[i+2], 6, 256);
	listing[i+14] := #9'adc ' + copy(listing[i+4], 6, 256);
	listing[i+17] := #9'adc ' + copy(listing[i+4], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
	end;


    if lda(i) and									// lda					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and									// lda 					; 2
       add_stack(i+3) and								// add :STACKORIGIN			; 3
       sta_a(i+4) then									// sta					; 4
     if argMatch(i+1, i+3) then
      begin
	listing[i+3] := #9'add ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if (lda_a(i) = false) and								//~lda	 				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda 					; 2		~lda adr.
       add_stack(i+3) and								// add :STACKORIGIN			; 3
       sta_a(i+4) then									// sta					; 4
     if argMatch(i+1, i+3) then
      begin
	listing[i+3] := #9'add ' + copy(listing[i+2], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if sta_stack(i) and									// sta :STACKORIGIN			; 0
       lda(i+1) and (lda_stack(i+1) = false) and					// lda					; 1		~lda adr.
       add(i+2) and (add_stack(i+2) = false) and					// add 					; 2
       add_stack(i+3) and								// add :STACKORIGIN			; 3
       sta_a(i+4) then									// sta					; 4
     if argMatch(i, i+3) then
      begin
	listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';

	listing[i+3] := '';

	exit(false);
      end;


    if (lda_a(i) = false) and								//~lda 					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and (lda_im(i+2) = false) and						// lda 					; 2		~lda adr.
       add_sub_im(i+3) and								// add|sub #				; 3
       add_stack(i+4) and								// add :STACKORIGIN			; 4
       tay(i+5) then									// tay					; 5
     if argMatch(i+1, i+4) then
      begin
	listing[i+2] := #9'add ' + copy(listing[i+2], 6, 256);

	listing[i+1] := '';

	listing[i+4] := '';

	if add_im_1(i+3) or sub_im_1(i+3) then begin

	 if add_im_1(i+3) then
	  listing[i+5] := #9'iny'
	 else
	  listing[i+5] := #9'dey';

	 listing[i+3] := '';
	 listing[i+4] := #9'tay';

	end;

	exit(false);
      end;


    if add_stack(i+5) and								// add :STACKORIGIN			; 5

       lda(i) and									// lda 					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_a(i+2) and									// lda 					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
//       add_stack(i+5) and								// add :STACKORIGIN			; 5
       sta_val(i+6) and									// sta					; 6	~:STACKORIGIN
											//					; 7
       (adc(i+8) = false) then								//~adc					; 8
     if argMatch(i+1, i+5) then
      begin

	if lda_im_0(i) then
	 listing[i+5] := ''
	else
	 listing[i+5] := #9'add ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if adc_stack(i+11) and								// adc :STACKORIGIN+STACKWIDTH		; 11

       sta_stack(i) and									// sta :STACKORIGIN			; 0
       lda(i+1) and									// lda					; 1		~lda adr.
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH		; 2
       lda(i+3) and									// lda					; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH*2	; 4
       lda(i+5) and									// lda					; 5
       sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH*3	; 6
       lda(i+7) and (lda_stack(i+7) = false) and					// lda					; 7
       add_stack(i+8) and								// add :STACKORIGIN			; 8
       sta(i+9) and									// sta 					; 9
       lda(i+10) and (lda_stack(i+10) = false) and					// lda					; 10
//       adc_stack(i+11) and								// adc :STACKORIGIN+STACKWIDTH		; 11
       sta_stack(i+12) and								// sta :STACKORIGIN+STACKWIDTH+9	; 12
       ldy_stack(i+13) then								// ldy :STACKORIGIN+STACKWIDTH+9	; 13
    if argMatch(i, i+8) and
       argMatch(i+2, i+11) and
       argMatch(i+12, i+13) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	listing[i+11] := #9'adc ' + copy(listing[i+1], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if adc_im_0(i+10) and								// adc #$00				; 10

       lda_im_0(i) and									// lda #$00				; 0
       add(i+1) and									// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda(i+3) and									// lda					; 3		~lda adr.
       adc(i+4) and									// adc					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add(i+7) and									// add 					; 7
       sta(i+8) and									// sta 					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
//       adc_im_0(i+10) and								// adc #$00				; 10
       sta(i+11) and									// sta 					; 11
											//					; 12
       (adc(i+13) = false) then								//~adc					; 13
    if argMatch(i+2, i+6) and
       argMatch(i+5, i+9) then
       begin
	listing[i+6] := #9'lda ' + copy(listing[i+1], 6, 256);

	listing[i+9]  := #9'lda ' + copy(listing[i+4], 6, 256);
	listing[i+10] := #9'adc ' + copy(listing[i+3], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if adc_stack(i+8) and								// adc :STACKORIGIN+STACKWIDTH		; 8

       lda(i) and									// lda					; 0		~lda adr.
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda(i+2) and									// lda					; 2		~lda.adr
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH		; 3
       lda(i+4) and									// lda					; 4		~lda.adr
       add_stack(i+5) and								// add :STACKORIGIN			; 5
       sta_a(i+6) and									// sta					; 6
       lda(i+7) then									// lda					; 7		~lda.adr
//       adc_stack(i+8) and								// adc :STACKORIGIN+STACKWIDTH		; 8
//       sta_a(i+9) then								// sta					; 9
     if argMatch(i+1, i+5) and
	argMatch(i+3, i+8) then
      begin
	listing[i+5] := #9'add ' + copy(listing[i], 6, 256);

	listing[i+8] := #9'adc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------


    if adc_sbc_stack(i+19) and								// adc|sbc :STACKORIGIN+STACKWIDTH*3+10	; 19

       (ldy_val(i) or tay(i) or sty(i)) and						// ldy|tay|sty				; 0	!!!	~:STACKORIGIN
       lda_adr(i+1) and 								// lda adr.				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_adr(i+3) and									// lda adr.				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH+10	; 4
       lda_adr(i+5) and									// lda adr.				; 5
       sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 6
       lda_adr(i+7) and									// lda adr.				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 8
       lda_a(i+9) and									// lda ERROR				; 9
       add_sub_stack(i+10) and								// add|sub :STACKORIGIN+10		; 10
       sta_a(i+11) and									// sta ERROR				; 11
       lda_a(i+12) and									// lda ERROR+1				; 12
       adc_sbc_stack(i+13) and								// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 13
       sta_a(i+14) and									// sta ERROR+1				; 14
       lda_a(i+15) and									// lda ERROR+2				; 15
       adc_sbc_stack(i+16) and								// adc|sbc :STACKORIGIN+STACKWIDTH*2+10	; 16
       sta_a(i+17) and									// sta ERROR+2				; 17
       lda_a(i+18) and									// lda ERROR+3				; 18
//       adc_sbc_stack(i+19) and							// adc|sbc :STACKORIGIN+STACKWIDTH*3+10	; 19
       sta_a(i+20) then									// sta ERROR+3				; 20
     if argMatch(i+2, i+10) and
	argMatch(i+4, i+13) and
	argMatch(i+6, i+16) and
	argMatch(i+8, i+19) then
       begin

	if add_stack(i+10) then begin
	 listing[i+10] := #9'add ' + copy(listing[i+1], 6, 256);
	 listing[i+13] := #9'adc ' + copy(listing[i+3], 6, 256);
	 listing[i+16] := #9'adc ' + copy(listing[i+5], 6, 256);
	 listing[i+19] := #9'adc ' + copy(listing[i+7], 6, 256);
	end else begin
	 listing[i+10] := #9'sub ' + copy(listing[i+1], 6, 256);
	 listing[i+13] := #9'sbc ' + copy(listing[i+3], 6, 256);
	 listing[i+16] := #9'sbc ' + copy(listing[i+5], 6, 256);
	 listing[i+19] := #9'sbc ' + copy(listing[i+7], 6, 256);
	end;

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


    if adc_sbc_stack(i+9) and								// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 9

       (ldy_val(i) or tay(i) or sty(i)) and						// ldy|tay|sty				; 0	!!!	~:STACKORIGIN
       lda_adr(i+1) and									// lda adr.				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_adr(i+3) and									// lda adr.				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH+10	; 4
       lda_a(i+5) and									// lda ERROR				; 5
       add_sub_stack(i+6) and								// add|sub :STACKORIGIN+10		; 6
       sta_a(i+7) and									// sta ERROR				; 7
       lda_a(i+8) and									// lda ERROR+1				; 8
//       adc_sbc_stack(i+9) and								// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 9
       sta_a(i+10) then									// sta ERROR+1				; 10
     if argMatch(i+2, i+6) and
	argMatch(i+4, i+9) then
       begin

	if add_stack(i+6) then begin
	 listing[i+6] := #9'add ' + copy(listing[i+1], 6, 256);
	 listing[i+9] := #9'adc ' + copy(listing[i+3], 6, 256);
	end else begin
	 listing[i+6] := #9'sub ' + copy(listing[i+1], 6, 256);
	 listing[i+9] := #9'sbc ' + copy(listing[i+3], 6, 256);
	end;

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
       end;


    if adc_sbc_stack(i+15) and								// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 15

       (ldy_val(i) or tay(i) or sty(i)) and						// ldy|tay|sty				; 0	!!!	~:STACKORIGIN
       lda_a(i+1) and									// lda					; 1
       add_sub(i+2) and									// add|sub				; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+9			; 3
       lda_a(i+4) and									// lda					; 4
       adc_sbc(i+5) and									// adc|sbc				; 5
       sta_stack(i+6) and								// sta :STACKORIGIN+STASCKWIDTH+9	; 6
       lda_adr(i+7) and									// lda adr.				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+10			; 8
       lda_adr(i+9) and									// lda adr.				; 9
       sta_stack(i+10) and								// sta :STACKORIGIN+STACKWIDTH+10	; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+9			; 11
       add_sub_stack(i+12) and								// add|sub :STACKORIGIN+10		; 12
       sta_a(i+13) and									// sta 					; 13
       lda_stack(i+14) and								// lda :STACKORIGIN+STACKWIDTH+9	; 14
//       adc_sbc_stack(i+15) and							// adc|sbc :STACKORIGIN+STACKWIDTH+10	; 15
       sta_a(i+16) then									// sta					; 16
     if argMatch(i+3, i+11) and
	argMatch(i+6, i+14) and
	argMatch(i+8, i+12) and
	argMatch(i+10, i+15) then
       begin

	if add_stack(i+12) then begin
	 listing[i+12] := #9'add ' + copy(listing[i+7], 6, 256);
	 listing[i+15] := #9'adc ' + copy(listing[i+9], 6, 256);
	end else begin
	 listing[i+12] := #9'sub ' + copy(listing[i+7], 6, 256);
	 listing[i+15] := #9'sbc ' + copy(listing[i+9], 6, 256);
	end;

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';

	exit(false);
       end;


    if sty_bp_1(i+13) and								// sty :bp+1				; 13

       lda_stack(i) and									// lda :STACKORIGIN+10			; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH*3+10	; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       ldy(i+12) and									// ldy :STACKORIGIN+STACKWIDTH+9	; 12
//       sty_bp_1(i+13) and								// sty :bp+1				; 13
       ldy(i+14) and									// ldy :STACKORIGIN+9			; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+10			; 15
       sta_bp_y(i+16) then								// sta (:bp),y				; 16
     if argMatch(i, i+2) and
	argMatch(i+3, i+5) and
	argMatch(i+6, i+8) and
	argMatch(i+9, i+11) and
	argMatch(i+2, i+15) then
       begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if adc_im_0(i+16) and								// adc #$00				; 16

       lda_a(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_a(i+6) and									// lda					; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_a(i+9) and									// lda					; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_a(i+12) and									// lda					; 12
       add_im_0(i+13) and								// add #$00				; 13
       tay(i+14) and									// tay					; 14
       lda_a(i+15) and									// lda					; 15
//       adc_im_0(i+16) and								// adc #$00				; 16
       sta_a(i+17) and	 								// sta :STACKORIGIN+STACKWIDTH		; 17
       lda_stack(i+18) and								// lda :STACKORIGIN			; 18
       sta_a(i+19) and									// sta					; 19
       lda_stack(i+20) and								// lda :STACKORIGIN+STACKWIDTH		; 20
       sta_a(i+21) and									// sta					; 21
       lda_stack(i+22) and								// lda :STACKORIGIN+STACKWIDTH*2	; 22
       sta_a(i+23) and									// sta					; 23
       lda_stack(i+24) and								// lda :STACKORIGIN+STACKWIDTH*3	; 24
       sta_a(i+25) then									// sta					; 25
     if argMatch(i+2, i+18) and
	argMatch(i+5, i+20) and
	argMatch(i+8, i+22) and
	argMatch(i+11, i+24) then
       begin

        listing_tmp[0] := listing[i+12];
        listing_tmp[1] := listing[i+13];
        listing_tmp[2] := listing[i+14];
        listing_tmp[3] := listing[i+15];
        listing_tmp[4] := listing[i+16];
        listing_tmp[5] := listing[i+17];

        listing_tmp[6] := listing[i];
        listing_tmp[7] := listing[i+1];
        listing_tmp[8] := listing[i+19];

        listing_tmp[9] := listing[i+3];
        listing_tmp[10] := listing[i+4];
        listing_tmp[11] := listing[i+21];

        listing_tmp[12] := listing[i+6];
        listing_tmp[13] := listing[i+7];
        listing_tmp[14] := listing[i+23];

        listing_tmp[15] := listing[i+9];
        listing_tmp[16] := listing[i+10];
        listing_tmp[17] := listing[i+25];

	for p:=0 to 17 do
	 listing[i+p] := listing_tmp[p];

	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';

	exit(false);
       end;


    if sty_bp_1(i+13) and								// sty :bp+1				; 13

       lda_stack(i) and									// lda :STACKORIGIN+9			; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH+9	; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH*2+9	; 6
       adc_sbc(i+7) and									// adc|sbc				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+9	; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH*3+9	; 9
       adc_sbc(i+10) and								// adc|sbc				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+9	; 11
       ldy_stack(i+12) and								// ldy :STACKORIGIN+STACKWIDTH+9	; 12
//       sty_bp_1(i+13) and								// sty :bp+1				; 13
       ldy_stack(i+14) and								// ldy :STACKORIGIN+9			; 14
       lda(i+15) and									// lda					; 15
       sta_bp_y(i+16) then								// sta (:bp),y				; 16
     if argMatch(i, i+2) and
	argMatch(i+3, i+5) and
	argMatch(i+6, i+8) and
	argMatch(i+9, i+11) and
	argMatch(i+5, i+12) and
	argMatch(i+2, i+14) then
       begin
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if (lab_a(i) = false) and								//~@					; 0
       lda_a(i+1) and									// lda					; 1
       add_eax(i+2) and									// add :eax				; 2
       sta_a(i+3) and									// sta					; 3
       lda_a(i+4) and									// lda					; 4
       adc_eax_1(i+5) and								// adc :eax+1				; 5
       sta_a(i+6) and									// sta					; 6
											//					; 7
       (adc(i+8) = false) then								//~adc					; 8
       begin
        listing[i+2] := #9'add ' + copy(listing[i+1], 6, 256);

	listing[i+5] := #9'adc ' + copy(listing[i+4], 6, 256);

	listing[i+1] := #9'lda :eax';

	listing[i+4] := #9'lda :eax+1';

	exit(false);
       end;


    if lda_stack(i) and									// lda :STACKORIGIN+STACKWIDTH		; 0
       sta_eax_1(i+1) and								// sta :eax+1				; 1
       lda_eax(i+2) and									// lda :eax				; 2
       add_sub_val(i+3) and								// add|sub				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN			; 4
       lda_eax_1(i+5) and								// lda :eax+1				; 5
       adc_sbc_val(i+6) and								// adc|sbc				; 6
       sta_stack(i+7) then								// sta :STACKORIGIN+STACKWIDTH		; 7
    if argMatch(i, i+7) then
       begin
        listing[i+5] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if lda_stack(i) and									// lda :STACKORIGIN+STACKWIDTH		; 0
       sta_eax_1(i+1) and								// sta :eax+1				; 1
       lda_a(i+2) and									// lda :STACKORIGIN			; 2
       add_sub_val(i+3) and								// add|sub				; 3
       sta_val(i+4) and									// sta A				; 4
       lda_a(i+5) and									// lda 					; 5
       (adc_eax_1(i+6) or sbc_eax_1(i+6)) and						// adc|sbc :eax+1			; 6
       sta_val(i+7) then								// sta A+1				; 7
    if (argMatch(i, i+2) = false) and
       (argMatch(i, i+5) = false) then
      begin

	if adc(i+6) then
	 listing[i+6] := #9'adc ' + copy(listing[i], 6, 256)
	else
	 listing[i+6] := #9'sbc ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if lda(i) and (lda_stack(i) = false) and						// lda					; 0		~lda adr.
       sta_eax(i+1) and									// sta :eax				; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta_eax_1(i+3) and								// sta :eax+1				; 3
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       (add_eax(i+5) or sub_eax(i+5)) and						// add|sub :eax				; 5
       sta_stack(i+6) then								// sta :STACKORIGIN			; 6
      begin

	if add_eax(i+5) then
	 listing[i+5] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+5] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if add_im_0(i+1) and								// add #$00				; 1

       lda_val(i) and									// lda S				; 0	~:STACKORIGIN
//       add_im_0(i+1) and								// add #$00				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and									// lda S+1				; 3	~:STACKORIGIN
       adc(i+4) and (adc_im_0(i+4) = false) and						// adc 					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_a(i+6) and									// lda					; 6
       add_stack(i+7) and								// add :STACKORIGIN			; 7
       (tay(i+8) or sta_a(i+8)) and							// tay|sta				; 8
       lda_a(i+9) and									// lda					; 9
       adc_stack(i+10) then								// adc :STACKORIGIN+STACKWIDTH		; 10
     if argMatch(i+2, i+7) and
	argMatch(i+5, i+10) then
       begin
	listing[i+7] := #9'add ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

	exit(false);
       end;


    if adc_im_0(i+4) and								// adc #$00				; 4

       lda(i) and									// lda					; 0
       add(i+1) and									// add					; 1
       sta(i+2) and									// sta					; 2
       lda(i+3) and									// lda					; 3
//       adc_im_0(i+4) and								// adc #$00				; 4
       add(i+5) then									// add					; 5
     begin
	listing[i+4] := #9'adc ' + copy(listing[i+5], 6, 256);
	listing[i+5] := '';

	exit(false);
     end;


    if adc_im_0(i+4) and								// adc #$00				; 4

       lda(i) and									// lda					; 0
       add(i+1) and									// add					; 1
       sta(i+2) and									// sta					; 2
       lda(i+3) and									// lda					; 3
//       adc_im_0(i+4) and								// adc #$00				; 4
       add(i+5) then									// add					; 5
     begin
	listing[i+4] := #9'adc ' + copy(listing[i+5], 6, 256);
	listing[i+5] := '';

	exit(false);
     end;


   if adc_im_0(i+10) and								// adc #$00				; 10

      lda_im_0(i) and									// lda #$00				; 0
      add(i+1) and (add_im_0(i+1) = false) and						// add					; 1
      sta_stack(i+2) and								// sta :STACKORIGIN			; 2
      lda_a(i+3) and (lda_im_0(i+3) = false) and					// lda					; 3
      adc(i+4) and									// adc					; 4
      sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
      lda_stack(i+6) and								// lda :STACKORIGIN			; 6
      add(i+7) and									// add					; 7
      sta_stack(i+8) and								// sta :STACKORIGIN			; 8
      lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
//      adc_im_0(i+10) and								// adc #$00				; 10
      sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH		; 11
											//					; 12
      (adc(i+13) = false) then								//~adc					; 13
    if argMatch(i+2, i+6) and
       argMatch(i+6, i+8) and
       argMatch(i+5, i+9) and
       argMatch(i+9, i+11) then
     begin
      listing[i] := #9'lda ' + copy(listing[i+7],6, 256);

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10]:= '';
      listing[i+11]:= '';

      exit(false);
     end;


    if lda_im_0(i) and									// lda #$00				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       add_stack(i+2) and								// add :STACKORIGIN+10			; 2
       sta(i+3) then									// sta					; 3
     if argMatch(i+1, i+2) then
     begin
	listing[i+1] := '';
	listing[i+2] := #9'add #$00';

	exit(false);
     end;


   if adc_im_0(i+4) and									// adc #$00				; 4

      lda_im_0(i) and									// lda #$00				; 0
      add(i+1) and									// add					; 1
      sta_a(i+2) and									// sta					; 2
      lda_a(i+3) and									// lda					; 3
//      adc_im_0(i+4) and								// adc #$00				; 4
      sta_a(i+5) and									// sta					; 5
											//					; 6
      (adc(i+7) = false) then								//~adc					; 7
     begin
      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

      listing[i+4] := '';

      exit(false);
     end;


   if adc_im_0(i+4) and									// adc #$00				; 4

      lda_im_0(i) and									// lda #$00				; 0
      add(i+1) and									// add					; 1
      sta_a(i+2) and									// sta					; 2
      lda_a(i+3) and									// lda					; 3
//      adc_im_0(i+4) and								// adc #$00				; 4
      sta_a(i+5) and									// sta					; 5
      lda_a(i+6) and									// lda					; 6
      adc_im_0(i+7) and									// adc #$00				; 7
      sta_a(i+8) and									// sta					; 8
											//					; 9
      (adc(i+10) = false) then								//~adc					; 10
     begin
      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

      listing[i+4] := '';

      listing[i+7] := '';

      exit(false);
     end;


   if lda_a(i) and									// lda W				; 0
      add_im_0(i+1) and									// add #$00				; 1
      sta_a(i+2) and									// sta					; 2
      lda_im_0(i+3) and									// lda #$00				; 3
      adc(i+4) and									// adc					; 4
      sta_a(i+5) and									// sta					; 5
      lda_im_0(i+6) and									// lda #$00				; 6
      adc(i+7) and									// adc					; 7
      sta_a(i+8) and									// sta					; 8
      lda_im_0(i+9) and									// lda #$00				; 9
      adc(i+10) and									// adc					; 10
      sta_a(i+11) then									// sta					; 11
     begin
      listing[i+1] := '';

      listing[i+3] := '';
      listing[i+4] := #9'lda ' + copy(listing[i+4], 6, 256);

      listing[i+6] := '';
      listing[i+7] := #9'lda ' + copy(listing[i+7], 6, 256);

      listing[i+9]  := '';
      listing[i+10] := #9'lda ' + copy(listing[i+10], 6, 256);

      exit(false);
     end;


   if lda_a(i) and									// lda W				; 0
      add_im_0(i+1) and									// add #$00				; 1
      sta_a(i+2) and									// sta					; 2
      lda_a(i+3) and									// lda W+1				; 3
      adc_im_0(i+4) and									// adc #$00				; 4
      sta_a(i+5) and									// sta					; 5
      lda_a(i+6) and									// lda W+2				; 6
      adc_im_0(i+7) and									// adc #$00				; 7
      sta_a(i+8) and									// sta					; 8
      lda_a(i+9) and									// lda W+3				; 9
      adc_im_0(i+10) and								// adc #$00				; 10
      sta_a(i+11) then									// sta					; 11
     begin
      listing[i+1] := '';

      listing[i+4] := '';

      listing[i+7] := '';

      listing[i+10]  := '';

      exit(false);
     end;


   if lda_val(i) and									// lda 					; 0	~:STACKORIGIN
      add_im_0(i+1) and									// add #$00				; 1
      sta_a(i+2) and									// sta					; 2
      lda_val(i+3) and									// lda 					; 3	~:STACKORIGIN
      adc_im_0(i+4) and									// adc #$00				; 4
      sta_a(i+5) and									// sta					; 5
											//					; 6
      (adc(i+7) = false) then								//~adc					; 7
     begin
      listing[i+1] := '';

      listing[i+4] := '';

      exit(false);
     end;


   if lda_val(i) and									// lda 					; 0	~:STACKORIGIN
      add_im_0(i+1) and									// add #$00				; 1
      sta_a(i+2) and									// sta					; 2
      lda_im_0(i+3) and									// lda #$00				; 3
      adc(i+4) and									// adc					; 4
      sta_a(i+5) and									// sta					; 5
											//					; 6
      (adc(i+7) = false) then								//~adc					; 7
     begin
      listing[i+1] := '';

      listing[i+3] := '';
      listing[i+4] := #9'lda ' + copy(listing[i+4], 6, 256);

      exit(false);
     end;


   if lda_a(i) and									// lda					; 0
      add_im_0(i+1) and									// add #$00				; 1
      sta_a(i+2) and									// sta					; 2
      lda_a(i+3) and									// lda					; 3
      adc_im_0(i+4) and									// adc #$00				; 4
      sta_a(i+5) and									// sta					; 5
											//					; 6
      (adc(i+7) = false) then								//~adc					; 7
     begin
      listing[i+1] := '';

      listing[i+4] := '';

      exit(false);
     end;


    if lda_im_0(i) and									// lda #$00				; 0
       add(i+1) and (iy(i+1) = false) and						// add 					; 1
       sta(i+2) and (iy(i+2) = false) and						// sta					; 2
											//					; 3
       (adc(i+4) = false) then								//~adc					; 4
     if (argMatch(i+1, i+2) = false) then
      begin
	listing[i]   := '';
	listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

	exit(false);
      end;


    if lda_im_0(i) and 									// lda #$00				; 0
       add(i+1) and									// add					; 1
       sta(i+2) and 									// sta					; 2
       iny(i+3) and									// iny					; 3
       lda(i+4) and									// lda 					; 4
       adc(i+5) then									// adc					; 5
     begin
      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

      exit(false);
     end;

// -----------------------------------------------------------------------------

    if lda_im_0(i) and 									// lda #$00				; 0
       add(i+1) and (add_im(i+1) = false) and						// add					; 1	~add #$00	!!!
       tay(i+2) and 									// tay					; 2
       lda_a(i+3) and									// lda					; 3
       adc(i+4) and (adc_im(i+4) = false) and						// adc 					; 4	~adc #$00	!!!
       sta_a(i+5) and (sta_bp_1(i+5) = false) then					// sta					; 5	~sta :bp+1	!!!
     begin
      listing[i]   := '';
      listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

      listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

      exit(false);
     end;


    if lda_im_0(i) and									// lda #$00				; 0	!!! zadziala tylko dla ADD|ADC !!!
       add(i+1) and (add_im(i+1) = false) and						// add					; 1
       sta(i+2) and (sta_bp2(i+2) = false) and						// sta					; 2	!!! ~sta.adr|~sta :bp2
       lda(i+3) and 									// lda 					; 3	!!! ~lda.adr
       adc(i+4) then									// adc					; 4
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda ' + copy(listing[i+1], 6, 256);

	listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

	exit(false);
     end;


    if (lda_im(i) = false) and								//~lda #				; 0	!!! zadziala tylko dla ADD|ADC !!!
       add_im_0(i+1) and								// add #$00				; 1
       sta(i+2) and									// sta					; 2	!!! ~sta.adr
       lda(i+3) and									// lda					; 3	!!! ~lda.adr
       adc(i+4) then									// adc					; 4
     begin
      listing[i+1] := '';

      listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256);

      exit(false);
     end;


    if adc_im_0(i) and									// adc #$00				; 0
       add(i+1) and (add_im(i+1) = false) and						// add					; 1
       sta_a(i+2) and									// sta					; 2
       											//					; 3
       (adc(i+4) = false) then								//~adc					; 4
     begin
	listing[i] := '';
	listing[i+1] := #9'adc ' + copy(listing[i+1], 6, 256);

	exit(false);
     end;


    if adc_im_0(i) and									// adc #$00				; 0
       ldy(i+1) and									// ldy					; 1
       add(i+2) and (add_im(i+2) = false) and						// add					; 2
       sta_a(i+3) and									// sta					; 3
       											//					; 4
       (adc(i+5) = false) then								//~adc					; 5
     begin
	listing[i] := '';
	listing[i+2] := #9'adc ' + copy(listing[i+2], 6, 256);

	exit(false);
     end;


    if add(i) and									// add					; 0
       add_im_0(i+1) then								// add #$00				; 1
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if add(i) and									// add					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       add_im_0(i+3) then								// add #$00				; 3
     if argMatch(i+1, i+2) then
     begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if lda(i) and (iy(i) = false) and							// lda A				; 0
       add_im_0(i+1) and								// add #$00				; 1
       sta(i+2) and (iy(i+2) = false) and						// sta A				; 2
       (iny(i+3) = false) and								//~iny					; 3
       (adc(i+4) = false) then								//~adc					; 4
     if argMatch(i, i+2) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if lda_a(i) and 									// lda 					; 0
       add_im_0(i+1) and								// add #$00				; 1
       sta_a(i+2) and 									// sta					; 2
       lda_a(i+3) and									// lda					; 3
       (add(i+4) or sta_a(i+4)) then							// add|sta				; 4
     begin
      listing[i+1] := '';

      exit(false);
     end;


    if lda(i) and 									// lda 					; 0
       add_im_0(i+1) and								// add #$00				; 1
       sta(i+2) and 									// sta					; 2
       iny(i+3) and									// iny					; 3
       lda(i+4) and									// lda 					; 4
       adc(i+5) then									// adc					; 5
     begin
      listing[i+1] := '';

      listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

      exit(false);
     end;


   if lda_im_0(i) and									// lda #$00				; 0
      adc_im_0(i+1) and									// adc #$00				; 1
      lda_a(i+2) and									// lda					; 2
      and_ora_eor(i+3) then								// and|ora|eor				; 3
     begin
      listing[i]   := '';
      listing[i+1] := '';

      exit(false);
     end;


    if sta_stack(i) and									// sta :STACKORIGIN			; 0
       lda_val(i+1) and									// lda					; 1
       add_stack(i+2) then								// add :STACKORIGIN			; 2
     if argMatch(i, i+2) then
     begin
	listing[i]   := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


    if sta_stack(i) and									// sta :STACKORIGIN+9			; 0
       add_stack(i+1) and								// add :STACKORIGIN+9			; 1
       sta_a(i+2) then									// sta					; 2
     if argMatch(i, i+1) then
     begin
	listing[i]   := #9'add ' + copy(listing[i+2], 6, 256);
	listing[i+1] := '';

	exit(false);
     end;

end;		// function
