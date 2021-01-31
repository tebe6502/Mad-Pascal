
// -----------------------------------------------------------------------------
// ===				optymalizacja ADR.			  === //
// -----------------------------------------------------------------------------

    if lda_stack(i) and									// lda :STACKORIGIN			; 0
       add_im_0(i+1) and								// add #$00				; 1
       tay(i+2) and									// tay					; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH		; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) then 		 						// sta :STACKORIGIN+STACKWIDTH		; 5
    begin

     tmp:=#9'sta ' + copy(listing[i], 6, 256);

     for p:=i-1 downto 0 do
      if listing[p] = tmp then begin

// -----------------------------------------------------------------------------


    if (p > 2) and
       ((lda_a(p-3) = false) or
       (lda_a(p-3) and (lda_stack(p-3) = false) and (lda_im(p-3) = false))) and		// lda					; p-3		#-+BYTE
       sub_im(p-2) and					 				// sub #				; p-2
       add(p-1) and (add_stack(p-1) = false) and					// add					; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	q:=GetBYTE(p-2);

	LDA_STA_ADR(i,q,'-');

	listing[p-2] := '';

	if (listing[p+1] = #9'lda :eax+1') and (listing[p-1] = #9'add :eax')  then begin
	 listing[p-1] := #9'add ' + copy(listing[p-3], 6, 256);

	 listing[p-3] := #9'lda :eax';
	end;

	Result:=false; Break;
      end;


    if (p > 2) and
       ((lda_a(p-3) = false) or
       (lda_a(p-3) and (lda_stack(p-3) = false) and (lda_im(p-3) = false))) and		// lda					; p-3		#-+BYTE
       add_im(p-2) and 									// add #				; p-2
       add(p-1) and (add_stack(p-1) = false) and					// add 					; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	q:=GetBYTE(p-2);

	LDA_STA_ADR(i,q,'+');

	listing[p-2] := '';

	if (listing[p+1] = #9'lda :eax+1') and (listing[p-1] = #9'add :eax')  then begin
	 listing[p-1] := #9'add ' + copy(listing[p-3], 6, 256);

	 listing[p-3] := #9'lda :eax';
	end;

	Result:=false; Break;
      end;


    if (p > 2) and
       lda_a(p-3) and (lda_stack(p-3) = false) and (lda_im(p-3) = false) and		// lda					; p-3		+-BYTE
       add_sub(p-2) and (add_sub_stack(p-2) = false) and 				// add|sub				; p-2
       add_sub(p-1) and (add_sub_stack(p-1) = false) and 				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;



    if (p > 2) and
       lda_a(p-3) and (lda_stack(p-3) = false) and (lda_im(p-3) = false) and		// lda					; p-3		+-BYTE
       and_ora_eor(p-2) and (and_ora_eor_stack(p-2) = false) and 			// and|ora|eor				; p-2
       add_sub(p-1) and (add_sub_stack(p-1) = false) and 				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       ((lda_a(p-2) = false) or
       (lda_a(p-2) and (lda_stack(p-2) = false) and (lda_im(p-2) = false))) and		// lda					; p-2		+-BYTE
       add_sub(p-1) and (add_sub_stack(p-1) = false) and (add_sub_im(p-1) = false) and	// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       lda_a(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2		+-BYTE
       add_sub(p-1) and (add_sub_stack(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
//       lda(p+1) and									//~lda 					; p+1
       (adc_sbc(p+2) = false) then							//~adc|sbc				; p+2
//       sta_stack(p+3) then								//~sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 0) and
       lda_a(p-1) and (lda_stack(p-1) = false) and (lda_im(p-1) = false) and		// lda					; p-1		BYTE
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       add_sub(p+2) and									// add|sub				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 4) and
       ldy_im_0(p-5) and								// ldy #$00				; p-5		+-SHORTINT
       lda(p-4) and									// lda					; p-4
       spl(p-3) and									// spl					; p-3
       dey(p-2) and									// dey					; p-2
       add_sub(p-1) and									// add|sub				; p-1
											// sta :STACKORIGIN			; p
       tya(p+1) and									// tya 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
	listing[p-5] := '';

	listing[p-3] := '';
	listing[p-2] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------

    if (p > 7) and
       lda(p-8) and (lda_stack(p-8) = false) and					// lda					; p-8		#-+BYTE
       add_sub_im(p-7) and								// add|sub #				; p-7
       sta_stack(p-6) and								// sta :STACKORIGIN+10			; p-6
       lda(p-5) and									// lda					; p-5
       adc_sbc_im(p-4) and								// adc|sbc #				; p-4
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH+10	; p-3

       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2
       add_stack(p-1) and								// add :STACKORIGIN+10			; p-1
											// sta :STACKORIGIN+9			; p
       lda(p+1) and									// lda 					; p+1
       adc_stack(p+2) and								// adc :STACKORIGIN+STACKWIDTH+10	; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p+3
       (adc(p+5) = false) then								//~adc					; p+5
    if (copy(listing[p-6], 6, 256) = copy(listing[p-1], 6, 256)) and
       (copy(listing[p-3], 6, 256) = copy(listing[p+2], 6, 256)) then
      begin
        q:=GetWORD(p-7, p-4);

	if add_im(p-7) then
	 LDA_STA_ADR(i,q,'+')
	else
	 LDA_STA_ADR(i,q,'-');

	listing[p-1] := #9'add ' + copy(listing[p-8], 6, 256);

	listing[p+2] := #9'adc ' + copy(listing[p-5], 6, 256);

	listing[p-8] := '';
	listing[p-7] := '';
	listing[p-6] := '';
	listing[p-5] := '';
	listing[p-4] := '';
	listing[p-3] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       (lda_stack(p-2) = false) and (add_stack(p-1) = false) and
       ((lda(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+BYTE
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin

	if lda_im(p-2) then begin
	 q:=GetWORD(p-2, p+1);

	 listing[i]   := #9'ldy ' + copy(listing[p-1], 6, 256);
	 listing[i+1] := '';
	end else begin
	 q:=GetWORD(p-1, p+2);

	 if iy(p-2) = false then begin
 	  listing[i]   := #9'ldy ' + copy(listing[p-2], 6, 256);
 	  listing[i+1] := '';
	 end else
	  listing[i+1] := #9'tay';

	end;

	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	LDA_STA_ADR(i,q,'+');
{
	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '+$' + IntToHex(q, 2) + ',y';
	end;
}
	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and			// lda					; p-2		#-BYTE
       (lda(p-2) and (lda_im(p-2) = false) and sub_im(p-1)) and				// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin

	q:=GetWORD(p-1, p+2);

	if iy(p-2) = false then begin
 	  listing[i]   := #9'ldy ' + copy(listing[p-2], 6, 256);
 	  listing[i+1] := '';
	end else
	  listing[i+1] := #9'tay';

	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	LDA_STA_ADR(i,q,'-');

{
	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '-$' + IntToHex(q, 2) + ',y';
	end;
}
	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and			// lda #				; p-2		#-BYTE
       (lda_im(p-2) and sub(p-1) and (sub_im(p-1) = false)) and				// sub					; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------

    if (p > 1) and
       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2		+-WORD	[byte]
       add_sub(p-1) and (add_sub_stack(p-1) = false) and 				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_im_0(p+1) and								// lda #$00				; p+1
       asl_stack(p+2) and								// asl :STACKORIGIN			; p+2
       rol_a(p+3) and									// rol @				; p+3
       sta_stack(p+4) then								// sta :STACKORIGIN+STACKWIDTH		; p+4
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';

	Result:=false; Break;
      end;


    if (p > 2) and
       lda(p-3) and (lda_stack(p-3) = false) and					// lda					; p-3		+-WORD	[byte]
       add_sub(p-2) and (add_sub_stack(p-2) = false) and 				// add|sub				; p-2
       and_ora_eor(p-1) and								// and|ora|eor				; p-1
											// sta :STACKORIGIN			; p
       lda_im_0(p+1) and								// lda #$00				; p+1
       asl_stack(p+2) and								// asl :STACKORIGIN			; p+2
       rol_a(p+3) and									// rol @				; p+3
       sta_stack(p+4) then								// sta :STACKORIGIN+STACKWIDTH		; p+4
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';

	Result:=false; Break;
      end;


    if (p > 0) and
       lda_a(p-1) and (lda_stack(p-1) = false) and (lda_im(p-1) = false) and		// lda					; p-1		WORD	[byte]
											// sta :STACKORIGIN			; p
       lda_im_0(p+1) and								// lda #$00				; p+1
       asl_stack(p+2) and								// asl :STACKORIGIN			; p+2
       rol_a(p+3) and									// rol @				; p+3
       sta_stack(p+4) then								// sta :STACKORIGIN+STACKWIDTH		; p+4
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       lda_a(p-2) and (lda_stack(p-2) = false) and (lda_im(p-2) = false) and		// lda					; p-2		+-WORD
       add_sub(p-1) and (add_sub_stack(p-1) = false) and (add_sub_im(p-1) = false) and	// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and 									// lda					; p+1
       adc(p+2) and									// adc					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';

	Result:=false; Break;
      end;


    if (p > 0) and
       lda_a(p-1) and (lda_stack(p-1) = false) and (lda_im(p-1) = false) and		// lda					; p-1		WORD
											// sta :STACKORIGIN			; p
       lda(p+1) and 									// lda					; p+1
       adc(p+2) and									// adc					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_stack(p-2) = false) and (add_stack(p-1) = false) and
       ((lda(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+WORD
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin

	if lda_im(p-2) then begin
	 q:=GetWORD(p-2, p+1);
	 listing[i] := #9'lda ' + copy(listing[p-1], 6, 256);
	end else begin
	 q:=GetWORD(p-1, p+2);
	 listing[i] := #9'lda ' + copy(listing[p-2], 6, 256);
	end;

	q:=q * 2;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'tay';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	LDA_STA_ADR(i,q,'+');
{
	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '+$' + IntToHex(q, 2) + ',y';
	end;
}
	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and
       (lda(p-2) or lda_adr(p-2)) and (lda_im(p-2) = false) and sub_im(p-1) and 	// lda  				; p-2		#-WORD
//        (lda_im(p-2) and sub(p-1) and (sub_im(p-1) = false))) and			// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin

//	if lda_im(p-2) then begin
//	 q:=GetWORD(p-2, p+1);
//	 listing[i] := #9'lda ' + copy(listing[p-1], 6, 256);
//	end else begin
	 q:=GetWORD(p-1, p+2);
	 listing[i] := #9'lda ' + copy(listing[p-2], 6, 256);
//	end;

	q:=q * 2;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'tay';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	LDA_STA_ADR(i,q,'-');
{
	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '-$' + IntToHex(q, 2) + ',y';
	end;
}
	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 0) and
       lda_a(p-1) and (lda_stack(p-1) = false) and (lda_im(p-1) = false) and		// lda					; p-1		CARDINAL	[byte]
											// sta :STACKORIGIN			; p
       lda_im_0(p+1) and								// lda #$00				; p+1
       asl_stack(p+2) and								// asl :STACKORIGIN			; p+2
       rol_a(p+3) and									// rol @				; p+3
       asl_stack(p+4) and								// asl :STACKORIGIN			; p+4
       rol_a(p+5) and									// rol @				; p+5
       sta_stack(p+6) then								// sta :STACKORIGIN+STACKWIDTH		; p+6
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'asl @';
	listing[i+4] := #9'tay';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2		+-CARDINAL	[byte]
       add_sub(p-1) and (add_sub_stack(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_im_0(p+1) and								// lda #$00				; p+1
       asl_stack(p+2) and								// asl :STACKORIGIN			; p+2
       rol_a(p+3) and									// rol @				; p+3
       asl_stack(p+4) and								// asl :STACKORIGIN			; p+4
       rol_a(p+5) and									// rol @				; p+5
       sta_stack(p+6) then								// sta :STACKORIGIN+STACKWIDTH		; p+6
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'asl @';
	listing[i+4] := #9'tay';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       lda_a(p-2) and (lda_stack(p-2) = false) and (lda_im(p-2) = false) and		// lda					; p-2		+-CARDINAL
       add_sub(p-1) and (add_sub_stack(p-1) = false) and (add_sub_im(p-1) = false) and	// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       asl_stack(p+5) and								// asl :STACKORIGIN			; p+5
       rol_a(p+6) and									// rol @				; p+6
       sta_stack(p+7) then								// sta :STACKORIGIN+STACKWIDTH		; p+7
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'asl @';
	listing[i+4] := #9'tay';
	listing[i+5] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';
	listing[p+7] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_stack(p-2) = false) and (add_stack(p-1) = false) and
       ((lda(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+CARDINAL
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       asl_stack(p+5) and								// asl :STACKORIGIN			; p+5
       rol_a(p+6) and									// rol @				; p+6
       sta_stack(p+7) then								// sta :STACKORIGIN+STACKWIDTH		; p+7
      begin

	if lda_im(p-2) then begin
	 q:=GetWORD(p-2, p+1);
	 listing[i] := #9'lda ' + copy(listing[p-1], 6, 256);
	end else begin
	 q:=GetWORD(p-1, p+2);
	 listing[i] := #9'lda ' + copy(listing[p-2], 6, 256);
	end;

	q:=q * 4;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'asl @';
	listing[i+3]  := #9'tay';
	listing[i+4]  := '';
	listing[i+5]  := '';

	LDA_STA_ADR(i,q,'+');
{
	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+10) and iy(i+10) then begin
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+11) and iy(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+12) and iy(i+12) then begin
	 delete(listing[i+12], pos(',y', listing[i+12]), 2);
	 listing[i+12] := listing[i+12] + '+$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '+$' + IntToHex(q, 2) + ',y';
	end;

}
	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';
	listing[p+7] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and
       lda(p-2) and (lda_im(p-2) = false) and sub_im(p-1) and 				// lda  				; p-2		#-CARDINAL
//        (lda_im(p-2) and sub(p-1) and (sub_im(p-1) = false))) and			// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       asl_stack(p+5) and								// asl :STACKORIGIN			; p+5
       rol_a(p+6) and									// rol @				; p+6
       sta_stack(p+7) then								// sta :STACKORIGIN+STACKWIDTH		; p+7
      begin

//	if lda_im(p-2) then begin
//	 q:=GetWORD(p-2, p+1);
//	 listing[i] := #9'lda ' + copy(listing[p-1], 6, 256);
//	end else begin
	 q:=GetWORD(p-1, p+2);
	 listing[i] := #9'lda ' + copy(listing[p-2], 6, 256);
//	end;

	q:=q * 4;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'asl @';
	listing[i+3]  := #9'tay';
	listing[i+4]  := '';
	listing[i+5]  := '';

	LDA_STA_ADR(i,q,'-');

{
	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+10) and iy(i+10) then begin
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+11) and iy(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if lda_adr(i+12) and iy(i+12) then begin
	 delete(listing[i+12], pos(',y', listing[i+12]), 2);
	 listing[i+12] := listing[i+12] + '-$' + IntToHex(q, 2) + ',y';
	end;

	if sta_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '-$' + IntToHex(q, 2) + ',y';
	end;
}

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';
	listing[p+7] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

       Break;
      end;	// for p:=

     if Result = false then Break;
    end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


    if (lda_im(i) = false) and (lda_stack(i) = false) and				//~lda					; 0		BYTE
       add_im_0(i+1) and								// add #$00				; 1
       tay(i+2) and									// tay					; 2
       lda(i+3) and									// lda					; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) and		 						// sta :STACKORIGIN+STACKWIDTH		; 5
       (lda_adr(i+6) or sta_adr(i+7)) then						// lda     |lda adr.			; 6
											// sta adr.|sta				; 7
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
       end;


    if lda_im(i) and									// lda #				; 0		BYTE
       add_im_0(i+1) and								// add #$00				; 1
       tay(i+2) and									// tay					; 2
       lda(i+3) and									// lda					; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) and		 						// sta :STACKORIGIN+STACKWIDTH		; 5
       (lda_adr(i+6) or sta_adr(i+7)) then						// lda     |lda adr.			; 6
											// sta adr.|sta				; 7
       begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	q:=GetBYTE(i);

	if lda_adr(i+6) and iy(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 listing[i+6] := listing[i+6] + '+$' + IntToHex(q, 2);
	end;

	if sta_adr(i+7) and iy(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 listing[i+7] := listing[i+7] + '+$' + IntToHex(q, 2);
	end;

	listing[i] := '';

	if (lda_adr(i+8) = false) and (sta_adr(i+9) = false) then begin Result:=false; Break end;

	if lda_adr(i+8) and iy(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 listing[i+8] := listing[i+8] + '+$' + IntToHex(q, 2);
	end;

	if sta_adr(i+9) and iy(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 listing[i+9] := listing[i+9] + '+$' + IntToHex(q, 2);
	end;

	if (lda_adr(i+10) = false) and (sta_adr(i+11) = false) then begin Result:=false; Break end;

	if lda_adr(i+10) and iy(i+10) then begin
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 listing[i+10] := listing[i+10] + '+$' + IntToHex(q, 2);
	end;

	if sta_adr(i+11) and iy(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 listing[i+11] := listing[i+11] + '+$' + IntToHex(q, 2);
	end;

	if (lda_adr(i+12) = false) and (sta_adr(i+13) = false) then begin Result:=false; Break end;

	if lda_adr(i+12) and iy(i+12) then begin
	 delete(listing[i+12], pos(',y', listing[i+12]), 2);
	 listing[i+12] := listing[i+12] + '+$' + IntToHex(q, 2);
	end;

	if sta_adr(i+13) and iy(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 listing[i+13] := listing[i+13] + '+$' + IntToHex(q, 2);
	end;

	Result:=false; Break;
       end;

