
function opt_STACK_ADR(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				 STACK ADR.
// -----------------------------------------------------------------------------

 if (lda_adr(i+16) or										// lda     |lda adr.			; 16
    sta_adr(i+17) or										// sta adr.|sta				; 17
    lda_adr(i+18) or										// lda     |lda adr.			; 18
    sta_adr(i+19)) and  									// sta adr.|sta				; 19

    (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
    (listing[i+7] = #9'asl :STACKORIGIN,x') and							// asl :STACKORIGIN,x			; 7
    rol_a(i+8) and										// rol @				; 8
    (listing[i+9] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 9
    (listing[i+10] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 10
    add_im_0(i+11) and										// add #$00				; 11
    tay(i+12) and										// tay					; 12
    (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 13
    adc_im_0(i+14) and										// adc #$00				; 14
    (listing[i+15] = #9'sta :STACKORIGIN+STACKWIDTH,x') then					// sta :STACKORIGIN+STACKWIDTH,x	; 15
   begin


    if (lda_stack(i) = false) and (sub_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and sub_im(i+1)) or 				// lda  |lda #				; 0		-WORD
        (lda_im(i) and sub(i+1) and (sub_im(i+1) = false))) and				// sub #|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and					// sta :STACKORIGIN,x			; 2
       lda(i+3) and									// lda					; 3
       sbc(i+4) and									// sbc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') then				// sta :STACKORIGIN+STACKWIDTH,x	; 5
     begin

	if lda_im(i) then begin
	 p:=GetWORD(i, i+3);
	 listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	 listing[i+1] := '';
	end else begin
	 p:=GetWORD(i+1, i+4);
	 listing[i+1] := '';
	end;

	p := p * 2;

        listing[i+2] := #9'asl @';
        listing[i+3] := #9'tay';
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

	if lda_adr_y(i+16) then begin
	 delete(listing[i+16], pos(',y', listing[i+16]), 2);
	 listing[i+16] := listing[i+16] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+17) then begin
	 delete(listing[i+17], pos(',y', listing[i+17]), 2);
	 listing[i+17] := listing[i+17] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+18) then begin
	 delete(listing[i+18], pos(',y', listing[i+18]), 2);
	 listing[i+18] := listing[i+18] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+19) then begin
	 delete(listing[i+19], pos(',y', listing[i+19]), 2);
	 listing[i+19] := listing[i+19] + '-$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


    if (lda_stack(i) = false) and (add_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and add_im(i+1)) or 				// lda  |lda #				; 0		+WORD
        (lda_im(i) and add(i+1) and (add_im(i+1) = false))) and				// add #|add				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and					// sta :STACKORIGIN,x			; 2
       lda(i+3) and									// lda					; 3
       adc(i+4) and									// adc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') then				// sta :STACKORIGIN+STACKWIDTH,x	; 5
     begin

	if lda_im(i) then begin
	 p:=GetWORD(i, i+3);
	 listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	 listing[i+1] := '';
	end else begin
	 p:=GetWORD(i+1, i+4);
	 listing[i+1] := '';
	end;

	p := p * 2;

        listing[i+2] := #9'asl @';
        listing[i+3] := #9'tay';
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

	if lda_adr_y(i+16) then begin
	 delete(listing[i+16], pos(',y', listing[i+16]), 2);
	 listing[i+16] := listing[i+16] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+17) then begin
	 delete(listing[i+17], pos(',y', listing[i+17]), 2);
	 listing[i+17] := listing[i+17] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+18) then begin
	 delete(listing[i+18], pos(',y', listing[i+18]), 2);
	 listing[i+18] := listing[i+18] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+19) then begin
	 delete(listing[i+19], pos(',y', listing[i+19]), 2);
	 listing[i+19] := listing[i+19] + '+$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


   end;


// -----------------------------------------------------------------------------


 if (lda_adr(i+18) or										// lda     |lda adr.			; 18
    sta_adr(i+19) or										// sta adr.|sta				; 19
    lda_adr(i+20) or										// lda     |lda adr.			; 20
    sta_adr(i+21) or										// sta adr.|sta				; 21
    lda_adr(i+22) or										// lda     |lda adr.			; 22
    sta_adr(i+23) or										// sta adr.|sta				; 23
    lda_adr(i+24) or										// lda     |lda adr.			; 24
    sta_adr(i+25)) and										// sta adr.|sta				; 25

    (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
    (listing[i+7] = #9'asl :STACKORIGIN,x') and							// asl :STACKORIGIN,x			; 7
    rol_a(i+8) and										// rol @				; 8
    (listing[i+9] = #9'asl :STACKORIGIN,x') and							// asl :STACKORIGIN,x			; 9
    rol_a(i+10) and										// rol @				; 10
    (listing[i+11] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 11
    (listing[i+12] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 12
    add_im_0(i+13) and										// add #$00				; 13
    tay(i+14) and										// tay					; 14
    (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 15
    adc_im_0(i+16) and										// adc #$00				; 16
    (listing[i+17] = #9'sta :STACKORIGIN+STACKWIDTH,x') then					// sta :STACKORIGIN+STACKWIDTH,x	; 17
   begin


    if (lda_stack(i) = false) and (sub_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and sub_im(i+1)) or 				// lda  |lda #				; 0		-CARDINAL
        (lda_im(i) and sub(i+1) and (sub_im(i+1) = false))) and				// sub #|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and					// sta :STACKORIGIN,x			; 2
       lda(i+3) and									// lda					; 3
       sbc(i+4) and									// sbc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') then				// sta :STACKORIGIN+STACKWIDTH,x	; 5
     begin

	if lda_im(i) then begin
	 p:=GetWORD(i, i+3);
	 listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	 listing[i+1] := '';
	end else begin
	 p:=GetWORD(i+1, i+4);
	 listing[i+1] := '';
	end;

	p := p * 4;

        listing[i+2] := #9'asl @';
        listing[i+3] := #9'asl @';
        listing[i+4] := #9'tay';
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

	if lda_adr_y(i+18) then begin
	 delete(listing[i+18], pos(',y', listing[i+18]), 2);
	 listing[i+18] := listing[i+18] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+19) then begin
	 delete(listing[i+19], pos(',y', listing[i+19]), 2);
	 listing[i+19] := listing[i+19] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+20) then begin
	 delete(listing[i+20], pos(',y', listing[i+20]), 2);
	 listing[i+20] := listing[i+20] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+21) then begin
	 delete(listing[i+21], pos(',y', listing[i+21]), 2);
	 listing[i+21] := listing[i+21] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+22) then begin
	 delete(listing[i+22], pos(',y', listing[i+22]), 2);
	 listing[i+22] := listing[i+22] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+23) then begin
	 delete(listing[i+23], pos(',y', listing[i+23]), 2);
	 listing[i+23] := listing[i+23] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+24) then begin
	 delete(listing[i+24], pos(',y', listing[i+24]), 2);
	 listing[i+24] := listing[i+24] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+25) then begin
	 delete(listing[i+25], pos(',y', listing[i+25]), 2);
	 listing[i+25] := listing[i+25] + '-$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


    if (lda_stack(i) = false) and (add_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and add_im(i+1)) or 				// lda  |lda #				; 0		+CARDINAL
        (lda_im(i) and add(i+1) and (add_im(i+1) = false))) and				// add #|add				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and					// sta :STACKORIGIN,x			; 2
       lda(i+3) and									// lda					; 3
       adc(i+4) and									// adc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') then				// sta :STACKORIGIN+STACKWIDTH,x	; 5
     begin

	if lda_im(i) then begin
	 p:=GetWORD(i, i+3);
	 listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	 listing[i+1] := '';
	end else begin
	 p:=GetWORD(i+1, i+4);
	 listing[i+1] := '';
	end;

	p := p * 4;

        listing[i+2] := #9'asl @';
        listing[i+3] := #9'asl @';
        listing[i+4] := #9'tay';
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

	if lda_adr_y(i+18) then begin
	 delete(listing[i+18], pos(',y', listing[i+18]), 2);
	 listing[i+18] := listing[i+18] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+19) then begin
	 delete(listing[i+19], pos(',y', listing[i+19]), 2);
	 listing[i+19] := listing[i+19] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+20) then begin
	 delete(listing[i+20], pos(',y', listing[i+20]), 2);
	 listing[i+20] := listing[i+20] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+21) then begin
	 delete(listing[i+21], pos(',y', listing[i+21]), 2);
	 listing[i+21] := listing[i+21] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+22) then begin
	 delete(listing[i+22], pos(',y', listing[i+22]), 2);
	 listing[i+22] := listing[i+22] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+23) then begin
	 delete(listing[i+23], pos(',y', listing[i+23]), 2);
	 listing[i+23] := listing[i+23] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr_y(i+24) then begin
	 delete(listing[i+24], pos(',y', listing[i+24]), 2);
	 listing[i+24] := listing[i+24] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr_y(i+25) then begin
	 delete(listing[i+25], pos(',y', listing[i+25]), 2);
	 listing[i+25] := listing[i+25] + '+$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


   end;


// -----------------------------------------------------------------------------


    if (lda_adr(i+10) or sta_adr(i+11)) and							// lda adr.|				; 10		WORD
       												//         |sta adr.			; 11

       lda_val(i) and										// lda ~:STACKORIGIN			; 0
       (listing[i+1] = #9'asl :STACKORIGIN,x') and						// asl :STACKORIGIN,x			; 1
       rol_a(i+2) and										// rol @				; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       add_im_0(i+5) and									// add #$00				; 5
       tay(i+6) and										// tay					; 6
       (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       adc_im_0(i+8) and									// adc #$00				; 8
       (listing[i+9] = #9'sta :STACKORIGIN+STACKWIDTH,x') then					// sta :STACKORIGIN+STACKWIDTH,x	; 9
     begin
       listing[i]   := #9'lda :STACKORIGIN,x';
       listing[i+1] := #9'asl @';
       listing[i+2] := #9'tay';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       exit(false);
     end;


    if (lda_adr(i+12) or sta_adr(i+13)) and							// lda adr.|				; 12		CARDINAL
       												//         |sta adr.			; 13

       lda_val(i) and										// lda ~:STACKORIGIN			; 0
       (listing[i+1] = #9'asl :STACKORIGIN,x') and						// asl :STACKORIGIN,x			; 1
       rol_a(i+2) and										// rol @				; 2
       (listing[i+3] = #9'asl :STACKORIGIN,x') and						// asl :STACKORIGIN,x			; 3
       rol_a(i+4) and										// rol @				; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 6
       add_im_0(i+7) and									// add #$00				; 7
       tay(i+8) and										// tay					; 8
       (listing[i+9] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 9
       adc_im_0(i+10) and									// adc #$00				; 10
       (listing[i+11] = #9'sta :STACKORIGIN+STACKWIDTH,x') then					// sta :STACKORIGIN+STACKWIDTH,x	; 11
     begin
       listing[i]   := #9'lda :STACKORIGIN,x';
       listing[i+1] := #9'asl @';
       listing[i+2] := #9'asl @';
       listing[i+3] := #9'tay';
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


    if (lda_adr(i+8) or	sta_adr(i+9)) and							// lda adr.|				; 8
       												// 	   |sta adr.			; 9

       mva_im(i) and (pos(':STACKORIGIN,x', listing[i]) > 0) and				// mva #$   :STACKORIGIN,x		; 0
       (mva(i+1) or sta(i+1)) and								// mva      :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 2
       add_im_0(i+3) and									// add #$00				; 3
       tay(i+4) and										// tay					; 4
       (listing[i+5] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 5
       adc_im_0(i+6) and									// adc #$00				; 6
       (listing[i+7] = #9'sta :STACKORIGIN+STACKWIDTH,x') then					// sta :STACKORIGIN+STACKWIDTH,x	; 7
     begin

       if mva_im(i+1) then
        p:=GetWORD(i, i+1)
       else
        p:=GetBYTE(i);

       if lda_adr_y(i+8) then begin							// BYTE
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '+$' + IntToHex(p, 2);
       end;

       if sta_adr_y(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '+$' + IntToHex(p, 2);
       end;

       if (lda(i+10) or lda_adr(i+10)) and (sta(i+11) or sta_adr(i+11)) then begin

        if lda_adr_y(i+10) then begin							// WORD
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + '+$' + IntToHex(p, 2);
        end;

        if sta_adr_y(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + '+$' + IntToHex(p, 2);
        end;

	if (lda(i+12) or lda_adr(i+12)) and (sta(i+13) or sta_adr(i+13)) then begin

         if lda_adr_y(i+12) then begin							// CARDINAL
	  delete(listing[i+12], pos(',y', listing[i+12]), 2);
	  listing[i+12] := listing[i+12] + '+$' + IntToHex(p, 2);
         end;

         if sta_adr_y(i+13) then begin
	  delete(listing[i+13], pos(',y', listing[i+13]), 2);
	  listing[i+13] := listing[i+13] + '+$' + IntToHex(p, 2);
         end;

	 if (lda(i+14) or lda_adr(i+14)) and (sta(i+15) or sta_adr(i+15)) then begin

          if lda_adr_y(i+14) then begin
	   delete(listing[i+14], pos(',y', listing[i+14]), 2);
	   listing[i+14] := listing[i+14] + '+$' + IntToHex(p, 2);
          end;

          if sta_adr_y(i+15) then begin
	   delete(listing[i+15], pos(',y', listing[i+15]), 2);
	   listing[i+15] := listing[i+15] + '+$' + IntToHex(p, 2);
          end;

	 end;

	end;

       end;

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



    if (lda_adr(i+13) or sta_adr(i+14)) and							// lda adr.|				; 13
       												//         |sta adr.			; 14

       lda_a(i) and										// lda					; 0
       add_sub(i+1) and										// add|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 5
       dex(i+6)	and										// dex					; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       add_im_0(i+8) and									// add #$00				; 8
       tay(i+9) and										// tay					; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       adc_im_0(i+11) and									// adc #$00				; 11
       sta_stack(i+12) then									// sta :STACKORIGIN+STACKWIDTH,x	; 12
     if copy(listing[i+10], 6, 256) = copy(listing[i+12], 6, 256) then
     begin
       listing[i+9]  := #9'dex';
       listing[i+10] := listing[i];
       listing[i+11] := listing[i+1];
       listing[i+12] := #9'tay';

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


    if (lda_adr(i+6) or sta_adr(i+7)) and							// lda adr.|				; 6
       												//         |sta adr.			; 7

       lda_a(i) and (lda_im(i) = false) and (iy(i) = false) and					// lda					; 0
       add_im_0(i+1) and									// add #$00				; 1
       tay(i+2) and										// tay					; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+STACKWIDTH,x	; 3
       adc_im_0(i+4) and									// adc #$00				; 4
       sta_stack(i+5) then									// sta :STACKORIGIN+STACKWIDTH,x	; 5
     if copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256) then
     begin
       listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       exit(false);
     end;

end;		// function