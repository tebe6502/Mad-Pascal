
function opt_LDY(i: integer): Boolean;
var p: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      LDY.
// -----------------------------------------------------------------------------

    if iny(i) and										// iny					; 0
       lda_im_0(i+1) and									// lda #$00				; 1
       asl_stack(i+2) then									// asl :STACKORIGIN			; 2
     begin
	listing[i] := '';

      	exit(false);
     end;


    if iny(i) and										// iny					; 0
       (lsr_stack(i+1) or asl_stack(i+1)) then							// lsr|asl :STACKORIGIN			; 1
     begin
	listing[i] := '';

      	exit(false);
     end;


    if tay(i) and										// tay					; 0
       tya(i+1) then										// tya					; 1
      begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if (iny(i) or dey(i)) and									// iny|dey				; 0
       (ldy(i+1) or mvy(i+1)) then								// ldy|mvy				; 1
       begin
	listing[i] := '';

	optyY := '';

	exit(false);
       end;

{
    if ldy_val(i) and 										// ldy					; 0	~:STACKORIGIN
       lda_val(i+1) and iy(i+1) and								// lda   ,y				; 1	~:STACKORIGIN
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_val(i+3) and (iy(i+3) = false) and							// lda					; 3	~:STACKORIGIN
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_a(i+5) then										// lda					; 5
     if copy(listing[i+2], 6, 256) <> copy(listing[i+4], 6, 256) then
       begin
	listing_tmp[0] := listing[i+3];
	listing_tmp[1] := listing[i+4];
	listing_tmp[2] := listing[i];
	listing_tmp[3] := listing[i+1];
	listing_tmp[4] := listing[i+2];

	for p:=0 to 4 do listing[i+p] := listing_tmp[p];

	exit(false);
       end;
}

    if ldy(i) and 										// ldy					; 0
       sty(i+1) and (sty_bp_1(i+1) = false) then						// sty					; 1
       begin
	listing[i] := #9'lda ' + copy(listing[i], 6, 256);

	k:=i+1;
	while sty(k) do begin
	 listing[k] := #9'sta ' + copy(listing[k], 6, 256);
	 inc(k);
	end;

	optyY := '';

	exit(false);
       end;


    if ldy_im(i) and 										// ldy #				; 0
       iny(i+1) then										// iny					; 1
       begin
	p := GetBYTE(i) + 1;

	if p < 256 then begin
 	 listing[i]   := #9'ldy #$' + IntToHex(p, 2);
	 listing[i+1] := '';

	 exit(false);
	end;

       end;


    if lda_val(i) and (lda_im(i) = false) and							// lda I				; 0	~:STACKORIGIN
       add_sub(i+1) and										// add|sub				; 1
       sta_val(i+2) and										// sta					; 2	~:STACKORIGN
       ldy(i+3) then										// ldy I				; 3
    if copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256) then
     begin
	listing[i+3] := listing[i+2];
	listing[i+2] := listing[i+1];
	listing[i+1] := #9'tya';

	listing[i] := #9'ldy ' + copy(listing[i], 6, 256);

	exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and								// lda 	~,y				; 0
       sta(i+1) and 										// sta A				; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda 	~,y				; 2
       sta(i+3) and 										// sta A+1				; 3
       ldy(i+4) and										// ldy 					; 4
       lda(i+5) and										// lda A				; 5
       sta_a(i+6) and										// sta					; 6
       lda(i+7) and										// lda A+1				; 7
       sta_a(i+8) then										// sta					; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
	listing[i+5] := listing[i];
	listing[i+7] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

      	exit(false);
     end;


    if tay(i) and										// tay					; 0
       sty(i+1) and										// sty					; 1
       ldy(i+2) then										// ldy					; 2
      begin
	listing[i] := '';
	listing[i+1] := #9'sta ' + copy(listing[i+1], 6, 256);

	exit(false);
      end;


    if sta(i) and										// sta :STACKORIGIN			; 0
       sta(i+1) and										// sta					; 1
       ldy(i+2) then										// ldy :STACKORIGIN			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
      begin
        listing[i]   := '';

	listing[i+2] := #9'tay';
	exit(false);
      end;


    if lda_a(i) and (iy(i) = false) and								// lda					; 0
       ldy(i+1) and										// ldy					; 1
       cmp(i+2) then										// cmp					; 2
      begin
	tmp := listing[i];

	listing[i]   := listing[i+1];
	listing[i+1] := tmp;

	exit(false);
      end;


    if sty_stack(i) and										// sty :STACKORIGIN			; 0
       tya(i+1) and										// tya					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda(i+3) then										// lda					; 3
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if ldy_stack(i+3) and									// ldy :STACKORIGIN			; 3

       sty_stack(i) and										// sty :STACKORIGIN			; 0
       lda_a(i+1) and 										// lda					; 1
       add_sub(i+2) and 									// add|sub				; 2
//       ldy_stack(i+3) and									// ldy :STACKORIGIN			; 3
       (SKIP(i+4) = false) then									//~SKIP					; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
      begin
	listing[i] := '';

	listing[i+3] := '';

	exit(false);
      end;


    if ldy_stack(i+4) and									// ldy :STACKORIGIN			; 4

       sta_stack(i) and										// sta :STACKORIGIN			; 0
       tay(i+1) and										// tay					; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       add_sub_val(i+3) and									// add|sub				; 3
//       ldy_stack(i+4) and									// ldy :STACKORIGIN			; 4
       sta_val(i+5) then									// sta					; 5	~:STACKORIGN
      if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i] := '';

	listing[i+4] := '';

	exit(false);
       end;


    if ldy_stack(i+5) and									// ldy :STACKORIGIN+9			; 5

       lda(i) and										// lda I				; 0
       (listing[i+1] = #9'add #$01') and 							// add #$01				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       ldy(i+3) and										// ldy I				; 3
       lda_a(i+4) then 										// lda					; 4
//       ldy_stack(i+5) then									// ldy :STACKORIGIN+9			; 5
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
	 (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+5] := #9'iny';
	exit(false);
       end;


    if ldy_stack(i+2) and									// ldy :STACKORIGIN+9			; 2

       sta_stack(i) and										// sta :STACKORIGIN+9			; 0
       (lda_a(i+1) or AND_ORA_EOR(i+1)) and (iy(i+1) = false) and				// lda|ora|and|eor			; 1
//       ldy_stack(i+2) and									// ldy :STACKORIGIN+9			; 2
       sta_a(i+3) then										// sta					; 3
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i]   := #9'tay';

	listing[i+2] := '';
	exit(false);
       end;


    if ldy_stack(i+3) and									// ldy :STACKORIGIN+9			; 3

       sta_stack(i) and										// sta :STACKORIGIN+9			; 0
       lda_a(i+1) and (iy(i+1) = false) and							// lda					; 1
       and_ora_eor(i+2) and (iy(i+2) = false) and						// and|ora|eor				; 2
//       ldy_stack(i+3) and									// ldy :STACKORIGIN+9			; 3
       sta_a(i+4) then										// sta					; 4
      if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := #9'tay';

	listing[i+3] := '';
	exit(false);
       end;


    if ldy_stack(i+4) and									// ldy :STACKORIGIN+9			; 4

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       ldy(i+2) and										// ldy					; 2
       lda_a(i+3) then										// lda					; 3
//       ldy_stack(i+4) then									// ldy :STACKORIGIN+9			; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+4] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

      	exit(false);
     end;


    if ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0
       iny(i+1) and 										// iny					; 1
       (lda_a(i+2) or sta_a(i+2)) then								// lda|sta				; 2
//       ldy(i+3) then										// ldy I				; 3
      begin
	listing[i+3] := #9'dey';

	exit(false);
      end;


    if tay(i+10) and 										// tay					; 10

       lda_val(i) and										// lda I				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       asl_a(i+2) and										// asl @				; 2
       tay(i+3) and										// tay					; 3
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_a(i+5) and										// sta					; 5
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       sta_a(i+7) and										// sta					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+9			; 8
       asl_a(i+9) then										// asl @				; 9
//       tay(i+10) then 									// tay					; 10
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+8] := listing[i];

	listing[i+1] := '';

	exit(false);
      end;


    if ldy_im(i+5) and										// ldy #				; 5

       lda_bp2(i) and										// lda :bp2				; 0
       add_im(i+1) and (pos('-DATAORIGIN', listing[i+1]) > 0) and				// add #CONTEXT.STATE-DATAORIGIN	; 1
       sta_bp2(i+2) and										// sta :bp2				; 2
       scc(i+3) and										// scc					; 3
       inc_bp2_1(i+4) then									// inc :bp2+1				; 4
//       ldy_im(i+5) then									// ldy #				; 5
      begin

        if ldy_im_0(i+5) then
	 listing[i] := #9'ldy ' + copy(listing[i+1], 6, 256)
	else
	 listing[i] := #9'ldy ' + copy(listing[i+1], 6, 256) + '+' + copy(listing[i+5], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if ldy_im(i+12) and										// ldy #				; 12

       lda_bp2(i) and										// lda :bp2				; 0
       add_im(i+1) and (pos('-DATAORIGIN', listing[i+1]) > 0) and				// add #CONTEXT.STATE-DATAORIGIN	; 1
       sta_bp2(i+2) and										// sta :bp2				; 2
       lda_bp2_1(i+3) and									// lda :bp2+1				; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_bp2_1(i+5) and									// sta :bp2+1				; 5
       lda_bp2(i+6) and										// lda :bp2				; 6
       add_im(i+7) and										// add #				; 7
       sta_bp2(i+8) and										// sta :bp2				; 8
       lda_bp2_1(i+9) and									// lda :bp2+1				; 9
       adc_im_0(i+10) and									// adc #$00				; 10
       sta_bp2_1(i+11) then									// sta :bp2+1				; 11
//       ldy_im(i+12) then									// ldy #				; 12
      begin

        if ldy_im_0(i+5) then
	 listing[i] := #9'ldy ' + copy(listing[i+1], 6, 256)
	else
	 listing[i] := #9'ldy ' + copy(listing[i+1], 6, 256) + '+' + copy(listing[i+7], 7, 256);

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
	listing[i+12]:= '';

	exit(false);
      end;


// -----------------------------------------------------------------------------


    if ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0

       lda_adr(i+1) and										// lda adr.				; 1
       sta_adr(i+2) then									// sta adr.				; 2
//       ldy(i+3) then										// ldy I				; 3
      begin
	listing[i+3] := '';

	exit(false);
      end;


    if ldy(i) and (listing[i] = listing[i+5]) and						// ldy I				; 0

       lda_adr(i+1) and										// lda adr.				; 1
       sta_adr(i+2) and										// sta adr.				; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_adr(i+4) then									// sta adr.				; 4
//       ldy(i+5) then										// ldy I				; 5
      begin
	listing[i+5] := '';

	exit(false);
      end;


    if ldy(i) and (listing[i] = listing[i+2]) and						// ldy I				; 0

       lda_adr(i+1) and										// lda adr.				; 1
//       ldy(i+2) and										// ldy I				; 2
       sta_adr(i+3) then									// sta adr.				; 3
      begin
	listing[i+2] := '';

	exit(false);
      end;


    if ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0

       lda_adr(i+1) and										// lda adr.				; 1
       add_sub(i+2) and										// add|sub				; 2
//       ldy(i+3) and										// ldy I				; 3
       sta_adr(i+4) then									// sta adr.				; 4
      begin
	listing[i+3] := '';

	exit(false);
      end;


    if ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0

       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
//       ldy(i+3) and										// ldy I				; 3
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       add_sub_stack(i+5) then									// add|sub :STACKORIGIN			; 5
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin

	if add_stack(i+5) then
	 listing[i+5] := #9'add ' + copy(listing[i+1], 6, 256)
	else
	 listing[i+5] := #9'sub ' + copy(listing[i+1], 6, 256);

	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';

	exit(false);
      end;


    if ldy_val(i) and										// ldy					; 0	~:STACKORIGIN
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       ldy_val(i+3) and										// ldy					; 3	~:STACKORIGIN
       lda_adr(i+4) and										// lda adr.				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+11			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+10			; 6
       add_sub_stack(i+7) then									// add|sub :STACKORIGIN+11		; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
       begin

        if add_stack(i+7) then
	 listing[i+4] := #9'add ' + copy(listing[i+4], 6, 256)
	else
	 listing[i+4] := #9'sub ' + copy(listing[i+4], 6, 256);

	listing[i+2] := '';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	if listing[i] = listing[i+3] then listing[i+3] := '';

	exit(false);
       end;


    if (ldy(i) or tay(i)) and									// tay|ldy A				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       (ldy(i+3) or iny(i+3)) and								// iny|ldy B				; 3
       lda_adr(i+4) and										// lda adr.				; 4
       and_ora_eor_stack(i+5) then								// ora|and|eor :STACKORIGIN+9		; 5
     if copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
	listing[i+2] := '';
	listing[i+4] := copy(listing[i+5], 1, 5) + copy(listing[i+4], 6, 256);
	listing[i+5] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// tay|ldy A				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       (ldy(i+3) or iny(i+3)) and								// iny|ldy B				; 3
       lda_adr(i+4) and										// lda adr.				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+10			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+9			; 6
       and_ora_eor(i+7) then									// ora|and|eor :STACKORIGIN+10		; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+2] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+4] := copy(listing[i+7], 1, 5) + copy(listing[i+4], 6, 256);
	listing[i+7] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       lda_stack(i+5) and									// lda :STACKORIGIN			; 5
       (add_sub(i+6) or AND_ORA_EOR(i+6)) and							// add|sub|and|ora|eor			; 6
       sta_a(i+7) and										// sta					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH		; 8
       (adc_sbc(i+9) or AND_ORA_EOR(i+9)) then							// adc|sbc|and|ora|eor			; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+2] := '';
	listing[i+5] := listing[i+1];
	listing[i+8] := listing[i+3];
	listing[i+1] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// ldy|tay					; 0
       lda_adr(i+1) and										// lda adr.					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN				; 2
       lda_adr(i+3) and										// lda adr.					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH			; 4
       lda_a(i+5) and										// lda						; 5
       (add_sub_stack(i+6) or and_ora_eor_stack(i+6)) and					// add|sub|and|ora|eor :STACKORIGIN		; 6
       sta_a(i+7) and										// sta						; 7
       lda_a(i+8) and										// lda						; 8
       (adc_sbc_stack(i+9) or and_ora_eor_stack(i+9)) then					// adc|sbc|and|ora|eor :STACKORIGIN+STACKWIDTH	; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
	listing[i+2] := '';
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+9] := copy(listing[i+9], 1, 5) + copy(listing[i+3], 6, 256);
	listing[i+1] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if (ldy(i) or tay(i)) and									// ldy|tay				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+10			; 4
       lda_stack(i+5) and									// lda :STACKORIGIN+9			; 5
       add_sub_stack(i+6) and									// add|sub :STACKORIGIN+10		; 6
       sta(i+7) and										// sta					; 7
												//					; 8
       (adc_sbc_stack(i+9) = false) then							//~adc|sbc				; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i+5] := copy(listing[i+5], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+6] := copy(listing[i+6], 1, 5) + copy(listing[i+3], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if ldy_stack(i+5) and									// ldy :STACKORIGIN+9			; 5

       sty_stack(i) and										// sty :STACKORIGIN+9			; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+10	; 4
//       ldy_stack(i+5) and									// ldy :STACKORIGIN+9			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+10			; 6
       sta_adr(i+7) and										// sta adr.				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH+10	; 8
       sta_adr(i+9) then									// sta adr.				; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+6] := listing[i+1];

	listing[i+8] := listing[i+3];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if ldy(i+5) and (listing[i+5] = listing[i]) and						// ldy I				; 5

//       ldy(i) and										// ldy I				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
//       ldy(i+5) and										// ldy I				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       sta_adr(i+7) and										// sta adr.				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH		; 8
       sta_adr(i+9) then									// sta adr.				; 9
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+6] := listing[i+1];

	listing[i+8] := listing[i+3];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;


    if rol_a(i+10) and										// rol @				; 10

       ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
//       ldy(i+3) and										// ldy I				; 3
       lda_adr(i+4) and										// lda adr.				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+10			; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       asl_stack(i+7) and									// asl :STACKORIGIN+10			; 7
       rol_a(i+8) and										// rol @				; 8
       asl_stack(i+9) and									// asl :STACKORIGIN+10			; 9
//       rol_a(i+10) and									// rol @				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+:STACKWIDTH+10	; 11
       lda_stack(i+12) then									// lda :STACKORIGIN+9			; 12
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+5], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin
	listing[i+12] := listing[i+1];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;



    if rol_a(i+10) and										// rol @				; 10

       ldy(i) and (listing[i] = listing[i+3]) and						// ldy I				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH+9	; 2
//       ldy(i+3) and										// ldy I				; 3
       lda_adr(i+4) and										// lda adr.				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+10			; 5
       lda_im_0(i+6) and									// lda #$00				; 6
       asl_stack(i+7) and									// asl :STACKORIGIN+10			; 7
       rol_a(i+8) and										// rol @				; 8
       asl_stack(i+9) and									// asl :STACKORIGIN+10			; 9
//       rol_a(i+10) and									// rol @				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+:STACKWIDTH+10	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+9			; 12
       add_stack(i+13) and									// add|sub :STACKORIGIN+10		; 13
       sta_a(i+14) and										// sta					; 14
       lda_stack(i+15) then									// lda :STACKORIGIN+STACKWIDTH+9	; 15
     if (copy(listing[i+2], 6, 256) <> copy(listing[i+5], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+13], 6, 256)) then
      begin
	listing[i+15] := listing[i+1];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if sty_stack(i) and										// sty :STACKORIGIN+9			; 0
       lda_adr(i+1) and										// lda adr.				; 1
       ldy_stack(i+2) and									// ldy :STACKORIGIN+9			; 2
       sta_adr(i+3) then									// sta adr.				; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
      begin
	listing[i]   := '';

	listing[i+2] := '';

	exit(false);
      end;


    if ldy(i+5) and (listing[i+5] = listing[i]) and						// ldy					; 5

//       ldy(i) and										// ldy I				; 0
       lda_adr(i+1) and										// lda adr.				; 1
       sta_stack(i+2) and 									// sta :STACKORIGIN			; 2
       lda_adr(i+3) and										// lda adr.				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
//       ldy(i+5) and										// ldy I				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN			; 6
       add_sub(i+7) and										// add|sub				; 7
       sta_a(i+8) and										// sta					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) then									// sta					; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
        (copy(listing[i+4], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
	listing[i+6] := listing[i+1];

	listing[i+9] := listing[i+3];

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if ldy(i+7) and (listing[i+7] = listing[i]) and						// ldy I				; 7

//       ldy(i) and										// ldy I				; 0
       lda_a(i+1) and										// lda					; 1
       add_sub_val(i+2) and									// add|sub				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+10			; 3
       lda_a(i+4) and										// lda 					; 4
       adc_sbc_val(i+5) and									// adc|sbc				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH+10	; 6
//       ldy(i+7) and										// ldy I				; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+10			; 8
       sta_adr(i+9) and 									// sta adr.				; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH+10	; 10
       sta_adr(i+11) then									// sta adr.				; 11
     if (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+6], 6, 256) = copy(listing[i+10], 6, 256)) then
      begin
	listing[i+3] := listing[i+9];

	listing[i+6] := listing[i+11];

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';

	exit(false);
      end;


    if ldy(i+6) and										// ldy					; 6

       lda_a(i) and (iy(i) = false) and								// lda					; 0
       add_sub_val(i+1) and (iy(i+1) = false) and						// add|sub				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and (iy(i+3) = false) and							// lda 					; 3
       adc_sbc_val(i+4) and (iy(i+4) = false) and						// adc|sbc				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+10	; 5
//       ldy(i+6) and										// ldy					; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+10			; 7
       sta_adr(i+8) and 									// sta adr.				; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH+10	; 9
       sta_adr(i+10) then									// sta adr.				; 10
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
        listing_tmp[0] := listing[i+6];

        listing_tmp[1] := listing[i];
        listing_tmp[2] := listing[i+1];
        listing_tmp[3] := listing[i+8];

        listing_tmp[4] := listing[i+3];
        listing_tmp[5] := listing[i+4];
        listing_tmp[6] := listing[i+10];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];
	listing[i+5] := listing_tmp[5];
	listing[i+6] := listing_tmp[6];

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';

	exit(false);
      end;


    if tay(i+5) and										// tay					; 5

       ldy(i) and (listing[i] = listing[i+3]) and						// ldy B				; 0
       lda_adr(i+1) and ((listing[i+1] = listing[i+4])) and					// lda adr.				; 1
       sta_stack(i+2) then									// sta :STACKORIGIN+9			; 2
//       ldy(i+3) and										// ldy B				; 3
//       lda_adr(i+4) and									// lda adr.				; 4
//       tay(i+5) then										// tay					; 5
      begin
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
      end;

end;		// function