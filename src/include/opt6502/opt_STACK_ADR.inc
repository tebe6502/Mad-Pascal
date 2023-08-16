
function opt_STACK_ADR(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				 STACK ADR.
// -----------------------------------------------------------------------------

    if (lda_stack(i) = false) and (sub_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and sub_im(i+1)) or 					// lda  |lda #				; 0		-WORD
        (lda_im(i) and sub(i+1) and (sub_im(i+1) = false))) and					// sub #|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda(i+3) and										// lda					; 3
       sbc(i+4) and										// sbc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'm@index2 0') and							// m@index2 0				; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       add_im_0(i+8) and									// add #$00				; 8
       tay(i+9) and										// tay					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       adc_im_0(i+11) and									// adc #$00				; 11
       (listing[i+12] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 12
       (lda_adr(i+13) or									// lda     |lda adr.			; 13
       sta_adr(i+14) or										// sta adr.|sta				; 14
       lda_adr(i+15) or										// lda     |lda adr.			; 15
       sta_adr(i+16)) then									// sta adr.|sta				; 16
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

	if lda_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+14) and iy(i+14) then begin
	 delete(listing[i+14], pos(',y', listing[i+14]), 2);
	 listing[i+14] := listing[i+14] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+15) and iy(i+15) then begin
	 delete(listing[i+15], pos(',y', listing[i+15]), 2);
	 listing[i+15] := listing[i+15] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+16) and iy(i+16) then begin
	 delete(listing[i+16], pos(',y', listing[i+16]), 2);
	 listing[i+16] := listing[i+16] + '-$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


    if (lda_stack(i) = false) and (add_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and add_im(i+1)) or 					// lda  |lda #				; 0		+WORD
        (lda_im(i) and add(i+1) and (add_im(i+1) = false))) and					// add #|add				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda(i+3) and										// lda					; 3
       adc(i+4) and										// adc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'm@index2 0') and							// m@index2 0				; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       add_im_0(i+8) and									// add #$00				; 8
       tay(i+9) and										// tay					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       adc_im_0(i+11) and									// adc #$00				; 11
       (listing[i+12] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 12
       (lda_adr(i+13) or									// lda     |lda adr.			; 13
       sta_adr(i+14) or										// sta adr.|sta				; 14
       lda_adr(i+15) or										// lda     |lda adr.			; 15
       sta_adr(i+16)) then									// sta adr.|sta				; 16
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

	if lda_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+14) and iy(i+14) then begin
	 delete(listing[i+14], pos(',y', listing[i+14]), 2);
	 listing[i+14] := listing[i+14] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+15) and iy(i+15) then begin
	 delete(listing[i+15], pos(',y', listing[i+15]), 2);
	 listing[i+15] := listing[i+15] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+16) and iy(i+16) then begin
	 delete(listing[i+16], pos(',y', listing[i+16]), 2);
	 listing[i+16] := listing[i+16] + '+$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


    if (lda_stack(i) = false) and (sub_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and sub_im(i+1)) or 					// lda  |lda #				; 0		-CARDINAL
        (lda_im(i) and sub(i+1) and (sub_im(i+1) = false))) and					// sub #|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda(i+3) and										// lda					; 3
       sbc(i+4) and										// sbc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'm@index4 0') and							// m@index4 0				; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       add_im_0(i+8) and									// add #$00				; 8
       tay(i+9) and										// tay					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       adc_im_0(i+11) and									// adc #$00				; 11
       (listing[i+12] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 12
       (lda_adr(i+13) or									// lda     |lda adr.			; 13
       sta_adr(i+14) or										// sta adr.|sta				; 14
       lda_adr(i+15) or										// lda     |lda adr.			; 15
       sta_adr(i+16) or										// sta adr.|sta				; 16
       lda_adr(i+17) or										// lda     |lda adr.			; 17
       sta_adr(i+18) or										// sta adr.|sta				; 18
       lda_adr(i+19) or										// lda     |lda adr.			; 19
       sta_adr(i+20)) then									// sta adr.|sta				; 20
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

	if lda_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+14) and iy(i+14) then begin
	 delete(listing[i+14], pos(',y', listing[i+14]), 2);
	 listing[i+14] := listing[i+14] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+15) and iy(i+15) then begin
	 delete(listing[i+15], pos(',y', listing[i+15]), 2);
	 listing[i+15] := listing[i+15] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+16) and iy(i+16) then begin
	 delete(listing[i+16], pos(',y', listing[i+16]), 2);
	 listing[i+16] := listing[i+16] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+17) and iy(i+17) then begin
	 delete(listing[i+17], pos(',y', listing[i+17]), 2);
	 listing[i+17] := listing[i+17] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+18) and iy(i+18) then begin
	 delete(listing[i+18], pos(',y', listing[i+18]), 2);
	 listing[i+18] := listing[i+18] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+19) and iy(i+19) then begin
	 delete(listing[i+19], pos(',y', listing[i+19]), 2);
	 listing[i+19] := listing[i+19] + '-$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+20) and iy(i+20) then begin
	 delete(listing[i+20], pos(',y', listing[i+20]), 2);
	 listing[i+20] := listing[i+20] + '-$' + IntToHex(p, 2) + ',y';
	end;

	exit(false);
     end;


    if (lda_stack(i) = false) and (add_stack(i+1) = false) and
       ((lda(i) and (lda_im(i) = false) and add_im(i+1)) or 					// lda  |lda #				; 0		+CARDINAL
        (lda_im(i) and add(i+1) and (add_im(i+1) = false))) and					// add #|add				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda(i+3) and										// lda					; 3
       adc(i+4) and										// adc					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'm@index4 0') and							// m@index4 0				; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       add_im_0(i+8) and									// add #$00				; 8
       tay(i+9) and										// tay					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       adc_im_0(i+11) and									// adc #$00				; 11
       (listing[i+12] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 12
       (lda_adr(i+13) or									// lda     |lda adr.			; 13
       sta_adr(i+14) or										// sta adr.|sta				; 14
       lda_adr(i+15) or										// lda     |lda adr.			; 15
       sta_adr(i+16) or										// sta adr.|sta				; 16
       lda_adr(i+17) or										// lda     |lda adr.			; 17
       sta_adr(i+18) or										// sta adr.|sta				; 18
       lda_adr(i+19) or										// lda     |lda adr.			; 19
       sta_adr(i+20)) then									// sta adr.|sta				; 20
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

	if lda_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+14) and iy(i+14) then begin
	 delete(listing[i+14], pos(',y', listing[i+14]), 2);
	 listing[i+14] := listing[i+14] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+15) and iy(i+15) then begin
	 delete(listing[i+15], pos(',y', listing[i+15]), 2);
	 listing[i+15] := listing[i+15] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+16) and iy(i+16) then begin
	 delete(listing[i+16], pos(',y', listing[i+16]), 2);
	 listing[i+16] := listing[i+16] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+17) and iy(i+17) then begin
	 delete(listing[i+17], pos(',y', listing[i+17]), 2);
	 listing[i+17] := listing[i+17] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+18) and iy(i+18) then begin
	 delete(listing[i+18], pos(',y', listing[i+18]), 2);
	 listing[i+18] := listing[i+18] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if lda_adr(i+19) and iy(i+19) then begin
	 delete(listing[i+19], pos(',y', listing[i+19]), 2);
	 listing[i+19] := listing[i+19] + '+$' + IntToHex(p, 2) + ',y';
	end;

	if sta_adr(i+20) and iy(i+20) then begin
	 delete(listing[i+20], pos(',y', listing[i+20]), 2);
	 listing[i+20] := listing[i+20] + '+$' + IntToHex(p, 2) + ',y';
	end;

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

       if lda_adr(i+8) and iy(i+8) then begin						// BYTE
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '+$' + IntToHex(p, 2);
       end;

       if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '+$' + IntToHex(p, 2);
       end;

       if (lda(i+10) or lda_adr(i+10)) and (sta(i+11) or sta_adr(i+11)) then begin

        if lda_adr(i+10) and iy(i+10) then begin					// WORD
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + '+$' + IntToHex(p, 2);
        end;

        if sta_adr(i+11) and iy(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + '+$' + IntToHex(p, 2);
        end;

	if (lda(i+12) or lda_adr(i+12)) and (sta(i+13) or sta_adr(i+13)) then begin

         if lda_adr(i+12) and iy(i+12) then begin					// CARDINAL
	  delete(listing[i+12], pos(',y', listing[i+12]), 2);
	  listing[i+12] := listing[i+12] + '+$' + IntToHex(p, 2);
         end;

         if sta_adr(i+13) and iy(i+13) then begin
	  delete(listing[i+13], pos(',y', listing[i+13]), 2);
	  listing[i+13] := listing[i+13] + '+$' + IntToHex(p, 2);
         end;

	 if (lda(i+14) or lda_adr(i+14)) and (sta(i+15) or sta_adr(i+15)) then begin

          if lda_adr(i+14) and iy(i+14) then begin
	   delete(listing[i+14], pos(',y', listing[i+14]), 2);
	   listing[i+14] := listing[i+14] + '+$' + IntToHex(p, 2);
          end;

          if sta_adr(i+15) and iy(i+15) then begin
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