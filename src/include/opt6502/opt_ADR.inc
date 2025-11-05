
function opt_ADR(i: integer): Boolean;
var p, q: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				       ADR.
// -----------------------------------------------------------------------------

    if lda_stack(i) and									// lda :STACKORIGIN			; 0
       add_im_0(i+1) and								// add #$00				; 1
       tay(i+2) and									// tay					; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH		; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) then 		 						// sta :STACKORIGIN+STACKWIDTH		; 5
    begin

     tmp:=#9'sta ' + copy(listing[i], 6, 256);

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------	// array of CARDINAL
// -----------------------------------------------------------------------------

     for p:=i-1 downto 0 do
      if listing[p] = tmp then begin


    if (p > 0) and
       lda_val(p-1) and (lda_im(p-1) = false) and					// lda					; p-1		CARDINAL	[byte]
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       lda_val(p-2) and (lda_im(p-2) = false) and					// lda					; p-2		CARDINAL	[byte]
       and_ora_eor(p-1) and								// and|ora|eor				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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


    if (p > 2) and
       lda_val(p-3) and (lda_im(p-3) = false) and					// lda					; p-3		CARDINAL	[byte]
       add_sub(p-2) and									// add|sub				; p-2
       and_ora_eor(p-1) and								// and|ora|eor				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       add_sub_val(p-1) and								// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_stack(p-2) = false) and (add_stack(p-1) = false) and
       ((lda(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+CARDINAL
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
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

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';
	listing[p+7] := #9'sta #$00';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and
       lda(p-2) and (lda_im(p-2) = false) and						// lda  				; p-2		#-CARDINAL
       sub_im(p-1) and									// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       asl_stack(p+5) and								// asl :STACKORIGIN			; p+5
       rol_a(p+6) and									// rol @				; p+6
       sta_stack(p+7) then								// sta :STACKORIGIN+STACKWIDTH		; p+7
      begin

	q:=GetWORD(p-1, p+2);
	listing[i] := #9'lda ' + copy(listing[p-2], 6, 256);

	q:=q * 4;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'asl @';
	listing[i+3]  := #9'tay';
	listing[i+4]  := '';
	listing[i+5]  := '';

		LDA_STA_ADR(i,q,'-');

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';
	listing[p+7] := #9'sta #$00';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       lda_val(p-2) and									// lda					; p-2		+-CARDINAL	[byte]
       add_sub(p-1) and									// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_val(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// add|sbc				; p+2
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
{
    if (p > 1) and
       lda_val(p-2) and (lda_im(p-2) = false) and					// lda					; p-2		+-CARDINAL
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
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

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := '';
	listing[p+6] := '';
	listing[p+7] := #9'sta #$00';

	Result:=false; Break;
      end;
}
// -----------------------------------------------------------------------------

       Break;

      end;// else	// for p:=
        //if onBreak(p) then Break;

     if Result = false then exit(false);


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------	// array of WORD
// -----------------------------------------------------------------------------


     for p:=i-1 downto 0 do
      if listing[p] = tmp then begin


    if (p > 1) and
       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2		+-WORD	[byte]
       add_sub_val(p-1) and								// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2		+-WORD	[byte]
       and_ora_eor(p-1) and (and_ora_eor_stack(p-1) = false) and 			// and|ora|eor				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       add_sub_val(p-2) and 								// add|sub				; p-2
       and_ora_eor(p-1) and								// and|ora|eor				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       lda_val(p-1) and (lda_im(p-1) = false) and					// lda					; p-1		WORD	[byte]
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
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
       lda_val(p-2) and (lda_im(p-2) = false) and					// lda					; p-2		+-WORD
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin
	listing[i+1] := '';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := '';
	listing[i+5] := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := #9'sta #$00';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------


    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       lda_stack(p-2) and argMatch(p-2, p) and
       add_sub_im(p-1) and					 			// add #|sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_sbc_im(p+2) and								// adc #|sbc #				; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin

	q:=GetWORD(p-1, p+2);

	listing[i] := #9'lda ' + copy(listing[p], 6, 256);

	q:=q * 2;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'tay';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-1] := '';
	listing[p]   := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := #9'sta #$00';

	Result:=false; Break;
      end;


    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_a(p-2) = false) and								//~lda					; p-2		#+-WORD
       add_sub_im(p-1) and					 			// add #|sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_sbc_im(p+2) and								// adc #|sbc #				; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin

	q:=GetWORD(p-1, p+2);

	listing[i] := #9'lda ' + copy(listing[p], 6, 256);

	q:=q * 2;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'tay';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-1] := '';
//	listing[p]   := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := #9'sta #$00';

	Result:=false; Break;
      end;


    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_stack(p-2) = false) and (add_stack(p-1) = false) and
       ((lda(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+WORD
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
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

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := #9'sta #$00';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and
       lda_a(p-2) and (lda_im(p-2) = false) and			 			// lda  				; p-2		#-WORD
       sub_im(p-1) and									// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       asl_stack(p+3) and								// asl :STACKORIGIN			; p+3
       rol_a(p+4) and									// rol @				; p+4
       sta_stack(p+5) then								// sta :STACKORIGIN+STACKWIDTH		; p+5
      begin

	q:=GetWORD(p-1, p+2);
	listing[i] := #9'lda ' + copy(listing[p-2], 6, 256);

	q:=q * 2;

	listing[i+1]  := #9'asl @';
	listing[i+2]  := #9'tay';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

		LDA_STA_ADR(i,q,'-');

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';

	listing[p+2] := '';
	listing[p+3] := '';
	listing[p+4] := '';
	listing[p+5] := #9'sta #$00';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

       Break;

      end;// else	// for p:=
        //if onBreak(p) then Break;

     if Result = false then exit(false);


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------	// array of BYTE
// -----------------------------------------------------------------------------

     for p:=i-1 downto 0 do
      if listing[p] = tmp then begin


    if (p > 2) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       ((lda_a(p-3) = false) or
       (lda_a(p-3) and (lda_stack(p-3) = false) and (lda_im(p-3) = false))) and		// lda					; p-3		#-+BYTE
       sub_im(p-2) and					 				// sub #				; p-2
       add(p-1) and (add_stack(p-1) = false) and					// add					; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc(p+5) = false) then								//~adc					; p+5
      begin
	q:=GetBYTE(p-2);

		LDA_STA_ADR(i,q,'-');

	listing[p-2] := '';

	if lda_eax_1(p+1) and add_eax(p-1) then begin
	 listing[p-1] := #9'add ' + copy(listing[p-3], 6, 256);

	 listing[p-3] := #9'lda :eax';
	end;

	Result:=false; Break;
      end;


    if (p > 2) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       ((lda_a(p-3) = false) or
       (lda_a(p-3) and (lda_stack(p-3) = false) and (lda_im(p-3) = false))) and		// lda					; p-3		#-+BYTE
       add_im(p-2) and 									// add #				; p-2
       add(p-1) and (add_stack(p-1) = false) and					// add 					; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc(p+2) and									// adc 					; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc(p+5) = false) then								//~adc					; p+5
      begin
	q:=GetBYTE(p-2);

		LDA_STA_ADR(i,q,'+');

	listing[p-2] := '';

	if lda_eax_1(p+1) and add_eax(p-1) then begin
	 listing[p-1] := #9'add ' + copy(listing[p-3], 6, 256);

	 listing[p-3] := #9'lda :eax';
	end;

	Result:=false; Break;
      end;


    if (p > 2) and
       lda_val(p-3) and (lda_im(p-3) = false) and					// lda					; p-3		+-BYTE
       add_sub_val(p-2) and								// add|sub				; p-2
       add_sub_val(p-1) and 								// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and					// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
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
       rol_stack(p-2) and								// rol :STACKORIGIN+STACKWIDTH		; p-2		+-BYTE
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-2, p+3) then
      begin
      	listing[p-2] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       asl_a(p-2) and									// asl @				; p-2		+-BYTE
       rol_stack(p-1) then								// rol :STACKORIGIN+STACKWIDTH		; p-1
											// sta :STACKORIGIN			; p
     if argMatch(p-1, i+3) then
      begin
      	listing[p-1] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 2) and
       rol_stack(p-3) and								// rol :STACKORIGIN+STACKWIDTH		; p-3		+-BYTE
       add_sub_val(p-2) and (add_sub_im(p-2) = false) and 				// add|sub				; p-2
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and			 	// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
	listing[p-3] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 2) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       rol_stack(p-3) and								// rol :STACKORIGIN+STACKWIDTH		; p-3		+-BYTE
       add_sub_im(p-2) and 								// add|sub #				; p-2
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
{
        q:=GetBYTE(p-2);			// !!! wyłączone !!! psuje [ ] [ ]

	if add_im(p-2) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');
}
	listing[p-3] := '';
//	listing[p-2] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 2) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       rol_stack(p-3) and								// rol :STACKORIGIN+STACKWIDTH		; p-3		+-BYTE
       add_sub_val(p-2) and (add_sub_im(p-2) = false) and 				// add|sub				; p-2
       add_sub_im(p-1) and 								// add|sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
{
        q:=GetBYTE(p-1);			// !!! wyłączone !!! psuje [ ] [ ]

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');
}
	listing[p-3] := '';

//	listing[p-1] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 4) and
       rol_a(p-5) and									// rol @				; p-5		+-BYTE
       sta_stack(p-4) and								// sta :STACKORIGIN+STACKWIDTH		; p-4
       lda_a(p-3) and (lda_im(p-3) = false) and						// lda					; p-3
       and_ora_eor(p-2) and								// and|ora|eor				; p-2
       add_sub(p-1) and (add_sub_im(p-1) = false) and					// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-4, p+3) then
      begin
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 3) and
       rol_a(p-4) and									// rol @				; p-4		+-BYTE
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH		; p-3
       lda_a(p-2) and (lda_im(p-2) = false) and						// lda					; p-2
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 3) and
       asl_stack(p-4) and								// asl :STACKORIGIN			; p-4		+-BYTE
       rol_stack(p-3) and								// rol :STACKORIGIN+STACKWIDTH		; p-3
       lda_stack(p-2) and 								// lda :STACKORIGIN			; p-2
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
	listing[p-3] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 3) and
       asl_stack(p-4) and								// asl :STACKORIGIN			; p-4		+-BYTE
       rol_stack(p-3) and								// rol :STACKORIGIN+STACKWIDTH		; p-3
       lda_val(p-2) and (lda_im(p-2) = false) and					// lda					; p-2
       add_sub_stack(p-1) and								// add|sub :STACKORIGIN			; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
	listing[p-3] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


{
    if (p > 2) and
       rol_stack(p-3) and								// rol :STACKORIGIN+STACKWIDTH		; p-3		+-BYTE
       asl_a(p-2) and									// asl @				; p-2
       add_sub_stack(p-1) and								// add|sub :STACKORIGIN			; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if (argMatch(p-3, p) = false) then
      begin
      	listing[p-3] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;
}


    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       rol_stack(p-2) and								// rol :STACKORIGIN+STACKWIDTH		; p-2		+-BYTE
       add_sub_im(p-1) and 								// add|sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc_im(p+2) and								// adc|sbc #				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-2, p+3) then
      begin
        q:=GetWORD(p-1, p+2);

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-2] := '';
	listing[p-1] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 3) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       rol_a(p-4) and									// rol @				; p-4		+-BYTE
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH		; p-3
       lda_a(p-2) and (lda_im(p-2) = false) and						// lda					; p-2
       add_sub_im(p-1) and 								// add|sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc_im(p+2) and								// adc|sbc #				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
     if argMatch(p-3, p+3) then
      begin
        q:=GetWORD(p-1, p+2);

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-1] := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 2) and
       lda_val(p-3) and (lda_im(p-3) = false) and					// lda					; p-3		+-BYTE
       and_ora_eor(p-2) and (and_ora_eor_stack(p-2) = false) and 			// and|ora|eor				; p-2
       add_sub_val(p-1) and 								// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											//					; p+4
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
       (lda_val(p-2) and (lda_im(p-2) = false))) and					// lda					; p-2		+-BYTE
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											//					; p+4
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


    if sta_stack(p) and									// sta :STACKORIGIN			; p		BYTE
       iny(p+1)and									// iny					; p+1	
       lda_a(p+2) and									// add|sub				; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
     if argMatch(p+3, i+3) then
      begin
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       lda_val(p-2) and									// lda					; p-2		+-BYTE
       add_sub_val(p-1) and								// add|sub				; p-1
											// sta :STACKORIGIN			; p
											//					; p+1
       (adc_sbc(p+2) = false) then							//~adc|sbc				; p+2
      begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 0) and
       lda_val(p-1) and (lda_im(p-1) = false) and					// lda					; p-1		BYTE
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       add_sub(p+2) and									// add|sub				; p+2
       sta_stack(p+3) and (listing[i+3] = listing[p+3]) and				// sta :STACKORIGIN+STACKWIDTH		; p+3
											//					; p+4
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


    if (p > 0) and
       lda_val(p-1) and (lda_im(p-1) = false) and					// lda					; p-1		BYTE
											// sta :STACKORIGIN			; p
       lda(p+1) and (lda_stack(p+1) = false) and (lda_im(p+1) = false) and		// lda 					; p+1
       asl_stack(p+2) and argMatch(p, p+2) and
       rol_a(p+3) and									// rol @				; p+3
       sta_stack(p+4) then								// sta :STACKORIGIN+STACKWIDTH		; p+4
      begin

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


    if (p > 5) and
       ldy_im_0(p-6) and								// ldy #$00				; p-6		+-SHORTINT
       lda(p-5) and									// lda					; p-5
       spl(p-4) and									// spl					; p-4
       dey(p-3) and									// dey					; p-3
       sty_stack(p-2) and								// sty :STACKORIGIN+STACKWIDTH		; p-2
       add_sub(p-1) and									// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											//					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
	listing[p-2] := #9'sty #$00';

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
											//					; p+4
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


    if (p > 7) and
//       (lda_adr(i+6) or sta_adr(i+7)) and
//       (iy(i+6) or iy(i+7)) and

       (lda_a(p-8) = false) and								//~lda					; p-8
       add_sub(p-7) and	(add_sub_im(p-7) = false) and					// add|sub				; p-7
       sta_stack(p-6) and								// sta :STACKORIGIN+10			; p-6
       lda_stack(p-5) and								// lda :STACKORIGIN+STACKWIDTH+10	; p-5
       adc_sbc(p-4) and									// adc|sbc				; p-4
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH+10	; p-3
       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2
       add_sub_stack(p-1) and								// add|sub :STACKORIGIN+10		; p-1
											// sta :STACKORIGIN+9			; p
											//					; p+1
       (adc_sbc(p+2) = false) then							//~adc|sbc				; p+2
    if argMatch(p-6, p-1) then
      begin
	listing[p-5] := '';
	listing[p-4] := '';
	listing[p-3] := '';

	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------

    if (p > 7) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       lda_val(p-8) and									// lda					; p-8		#-+BYTE	X
       add_sub_im(p-7) and								// add|sub #				; p-7
       sta_stack(p-6) and								// sta :STACKORIGIN+10			; p-6
       lda(p-5) and									// lda					; p-5
       adc_sbc_im(p-4) and								// adc|sbc #				; p-4
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH+10	; p-3

       lda_val(p-2) and									// lda					; p-2
       sub_stack(p-1) and								// sub :STACKORIGIN+10			; p-1
											// sta :STACKORIGIN+9			; p
       lda_a(p+1) and									// lda 					; p+1
       sbc_stack(p+2) and								// sbc :STACKORIGIN+STACKWIDTH+10	; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p+3
											//					; p+4
       (sbc(p+5) = false) then								//~adc					; p+5
    if argMatch(p-6, p-1) and
       argMatch(p-3, p+2) then
      begin
        q:=GetWORD(p-7, p-4);

	if add_im(p-7) then
		LDA_STA_ADR(i,q,'-')
	else
		LDA_STA_ADR(i,q,'+');

	listing[p-1] := #9'sub ' + copy(listing[p-8], 6, 256);

	listing[p+2] := #9'sbc ' + copy(listing[p-5], 6, 256);

	listing[p-8] := '';
	listing[p-7] := '';
	listing[p-6] := '';
	listing[p-5] := '';
	listing[p-4] := '';
	listing[p-3] := '';

	Result:=false; Break;
      end;


    if (p > 7) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       lda_val(p-8) and									// lda					; p-8		#-+BYTE	X
       add_sub_im(p-7) and								// add|sub #				; p-7
       sta_stack(p-6) and								// sta :STACKORIGIN+10			; p-6
       lda(p-5) and									// lda					; p-5
       adc_sbc_im(p-4) and								// adc|sbc #				; p-4
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH+10	; p-3

       lda_val(p-2) and									// lda					; p-2
       add_stack(p-1) and								// add :STACKORIGIN+10			; p-1
											// sta :STACKORIGIN+9			; p
       lda_a(p+1) and									// lda 					; p+1
       adc_stack(p+2) and								// adc :STACKORIGIN+STACKWIDTH+10	; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p+3
											//					; p+4
       (adc(p+5) = false) then								//~adc					; p+5
    if argMatch(p-6, p-1) and
       argMatch(p-3, p+2) then
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


    if (p > 7) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       lda_val(p-8) and (lda_im(p-8) = false) and					// lda					; p-8		#-+BYTE	X
       add_sub_im(p-7) and								// add|sub #				; p-7
       sta_stack(p-6) and								// sta :STACKORIGIN+9			; p-6
       lda(p-5) and									// lda					; p-5
       adc_sbc_im(p-4) and								// adc|sbc #				; p-4
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p-3

       lda_stack(p-2) and								// lda :STACKORIGIN+9			; p-2
       add(p-1) and (add_stack(p-1) = false) and (add_im(p-1) = false) and		// add 					; p-1
											// sta :STACKORIGIN+9			; p
       lda_a(p+1) and									// lda					; p+1
       adc(p+2) and (adc_stack(p+2) = false) and (adc_im(p+2) = false) and		// adc 					; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p+3
											//					; p+4
       (adc(p+5) = false) then								//~adc					; p+5
    if argMatch(p-6, p-2) and
       argMatch(p-3, p+3) then
      begin
        q:=GetWORD(p-7, p-4);

	if add_im(p-7) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-2] := listing[p-8];

	listing[p+1] := listing[p-5];

	listing[p-8] := '';
	listing[p-7] := '';
	listing[p-6] := '';
	listing[p-5] := '';
	listing[p-4] := '';
	listing[p-3] := '';

	Result:=false; Break;
      end;


    if (p > 7) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       lda_val(p-8) and (lda_im(p-8) = false) and					// lda					; p-8		#-+BYTE	X
       add(p-7) and (add_stack(p-7) = false) and (add_im(p-7) = false) and		// add					; p-7
       sta_stack(p-6) and								// sta :STACKORIGIN+9			; p-6
       lda(p-5) and									// lda					; p-5
       adc(p-4) and (adc_stack(p-4) = false) and (adc_im(p-4) = false) and		// adc					; p-4
       sta_stack(p-3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p-3

       lda_stack(p-2) and								// lda :STACKORIGIN+9			; p-2
       add_sub_im(p-1) and								// add|sub #				; p-1
											// sta :STACKORIGIN+9			; p
       lda_a(p+1) and									// lda					; p+1
       adc_sbc_im(p+2) and								// adc|sbc #				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p+3
											//					; p+4
       (adc_sbc(p+5) = false) then							//~adc					; p+5
    if argMatch(p-6, p-2) and
       argMatch(p-3, p+3) then
      begin
        q:=GetWORD(p-1, p+2);

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;


    if (p > 7) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and
											// lda					; p-8		#+BYTE	X
       (add_sub(p-7) = false) and							//~add|sub				; p-7
											// sta :STACKORIGIN+9			; p-6
											// lda					; p-5
       (adc_sbc(p-4) = false) and							//~adc|sbc				; p-4
											// sta :STACKORIGIN+STACKWIDTH+9	; p-3

       lda_stack(p-2) and								// lda :STACKORIGIN			; p-2
       add_sub_im(p-1) and								// add|sub #				; p-1
											// sta :STACKORIGIN+9			; p
       lda_stack(p+1) and								// lda :STACKORIGIN+STACKWIDTH		; p+1
       adc_sbc_im(p+2) and								// adc|sbc #				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH+9	; p+3
											//					; p+4
       (adc_sbc(p+5) = false) then							//~adc|sbc				; p+5
      begin
        q:=GetWORD(p-1, p+2);

	if add_im(p-1) then
		LDA_STA_ADR(i,q,'+')
	else
		LDA_STA_ADR(i,q,'-');

	listing[p-1] := '';

	listing[p+2] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_stack(p-2) = false) and (add_stack(p-1) = false) and (iy(p-2) = false) and
       ((lda_a(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+BYTE
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda_val(p+1) and									// lda 					; p+1
       adc(p+2) and (adc_stack(p+2) = false) and					// adc 					; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (adc(p+5) = false) then								//~adc					; p+5
      begin

	if lda_im(p-2) then begin
	 q:=GetWORD(p-2, p+1);

	 listing[i]   := #9'ldy ' + copy(listing[p-1], 6, 256);
	 listing[i+1] := '';
	end else begin
	 q:=GetWORD(p-1, p+2);

	 listing[i]   := #9'ldy ' + copy(listing[p-2], 6, 256);
 	 listing[i+1] := '';
	end;

	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

		LDA_STA_ADR(i,q,'+');

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
       (lda_adr(i+6) or sta_adr(i+7)) and
       (iy(i+6) or iy(i+7)) and

       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and (iy(p-2) = false) and	// lda					; p-2		#-BYTE
       (lda_a(p-2) and (lda_im(p-2) = false) and sub_im(p-1)) and			// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
       sbc_im(p+2) and									// sbc #				; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (sbc(p+5) = false) then								//~sbc					; p+5
      begin
	q:=GetWORD(p-1, p+2);

 	listing[i]   := #9'ldy ' + copy(listing[p-2], 6, 256);
 	listing[i+1] := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';

		LDA_STA_ADR(i,q,'-');

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
       lda_a(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       sta_stack(p+3) and								// sta :STACKORIGIN+STACKWIDTH		; p+3
											// 					; p+4
       (sbc(p+5) = false) then								//~sbc					; p+5
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

       Break;

      end else	// for p:=
        if {onBreak(p) or} (listing[p] = #9'asl ' + copy(listing[i], 6, 256)) then Break;	// 'asl :STACKORIGIN' wystepuje przy adresowaniu tablic WORD, CARDINAL

// -----------------------------------------------------------------------------

     if Result = false then exit(false);
    end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

    if (lda_adr(i+6) or sta_adr(i+7)) and						// lda adr.|				; 6
       (iy(i+6) or iy(i+7)) and								//         |sta adr.			; 7

       lda_val(i) and (lda_im(i) = false) and						// lda 					; 0		BYTE
       add(i+1) and (add_im_0(i+1) = false) and (add_stack(i+1) = false) and		// add 					; 1
       tay(i+2) and									// tay					; 2
       lda(i+3) and									// lda					; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) then		 						// sta :STACKORIGIN+STACKWIDTH		; 5
      begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if (lda_adr(i+6) or sta_adr(i+7)) and						// lda adr.|				; 6
       (iy(i+6) or iy(i+7)) and								//         |sta adr.			; 7

       lda_im(i) and									// lda #				; 0		BYTE
       add_im_0(i+1) and								// add #$00				; 1
       tay(i+2) and									// tay					; 2
       lda(i+3) and									// lda					; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) then		 						// sta :STACKORIGIN+STACKWIDTH		; 5

       begin
	listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	q:=GetBYTE(i);

	if lda_adr_y(i+6) then begin
	 delete(listing[i+6], pos(',y', listing[i+6]), 2);
	 if q<>0 then listing[i+6] := listing[i+6] + '+' + HexByte(q);
	end;

	if sta_adr_y(i+7) then begin
	 delete(listing[i+7], pos(',y', listing[i+7]), 2);
	 if q<>0 then listing[i+7] := listing[i+7] + '+' + HexByte(q);
	end;

	listing[i] := '';

	if (lda_adr(i+8) = false) and (sta_adr(i+9) = false) then exit(false);

	if lda_adr_y(i+8) then begin
	 delete(listing[i+8], pos(',y', listing[i+8]), 2);
	 if q<>0 then listing[i+8] := listing[i+8] + '+' + HexByte(q);
	end;

	if sta_adr_y(i+9) then begin
	 delete(listing[i+9], pos(',y', listing[i+9]), 2);
	 if q<>0 then listing[i+9] := listing[i+9] + '+' + HexByte(q);
	end;

	if (lda_adr(i+10) = false) and (sta_adr(i+11) = false) then exit(false);

	if lda_adr_y(i+10) then begin
	 delete(listing[i+10], pos(',y', listing[i+10]), 2);
	 if q<>0 then listing[i+10] := listing[i+10] + '+' + HexByte(q);
	end;

	if sta_adr_y(i+11) then begin
	 delete(listing[i+11], pos(',y', listing[i+11]), 2);
	 if q<>0 then listing[i+11] := listing[i+11] + '+' + HexByte(q);
	end;

	if (lda_adr(i+12) = false) and (sta_adr(i+13) = false) then exit(false);

	if lda_adr_y(i+12) then begin
	 delete(listing[i+12], pos(',y', listing[i+12]), 2);
	 if q<>0 then listing[i+12] := listing[i+12] + '+' + HexByte(q);
	end;

	if sta_adr_y(i+13) then begin
	 delete(listing[i+13], pos(',y', listing[i+13]), 2);
	 if q<>0 then listing[i+13] := listing[i+13] + '+' + HexByte(q);
	end;

	exit(false);
       end;


    if (lda_adr(i+6) or sta_adr(i+7)) and						// lda adr.|				; 6
											//         |sta adr.			; 7

       (lda_im(i) = false) and (lda_stack(i) = false) and				//~lda #|:STACKORIGIN			; 0		BYTE
       add_im(i+1) and									// add #				; 1
       tay(i+2) and									// tay					; 2
       lda(i+3) and									// lda					; 3
       adc_im_0(i+4) and								// adc #$00				; 4
       sta_stack(i+5) then		 						// sta :STACKORIGIN+STACKWIDTH		; 5

       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


// 2D ARRAY [BYTE..BYTE -> 256b] of BYTE

    if (lda_adr(i+18) or sta_adr(i+19)) and						// lda adr.|				; 18
       (iy(i+18) or iy(i+19)) and							//         |sta adr.			; 19

       lda_val(i) and									// lda Y				; 0
       add_sub_im(i+1) and 								// add|sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and									// lda Y+1				; 3
       adc_sbc_im(i+4) and								// adc|sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5

       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_stack(i+7) and								// add :STACKORIGIN+10			; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+9			; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
       adc_stack(i+10) and								// adc :STACKORIGIN+STACKWIDTH+10	; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH+9	; 11

       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       add_im_0(i+13) and								// add #$00				; 13
       tay(i+14) and									// tay					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_im_0(i+16) and								// adc #$00				; 16
       sta_stack(i+17) then								// sta :STACKORIGIN+STACKWIDTH+9	; 17

     if argMatch(i+2, i+7) and
        argMatch(i+5, i+10) and
        argMatch(i+6, i+8) and
	argMatch(i+8, i+12) and
	argMatch(i+9, i+11) and
	argMatch(i+11, i+15) then
       begin
	q:=GetWORD(i+1, i+4);

	if add_im(i+1) then
        	LDA_STA_ADR(i+12, q, '+')
	else
        	LDA_STA_ADR(i+12, q, '-');

	listing[i+7]  := #9'add ' + copy(listing[i], 6, 256);

	listing[i+10] := #9'adc ' + copy(listing[i+3], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if (lda_adr(i+18) or sta_adr(i+19)) and						// lda adr.|				; 18
       (iy(i+18) or iy(i+19)) and							//         |sta adr.			; 19

       lda_im(i) and									// lda #				; 0
       add(i+1) and (add_stack(i+1) = false) and (add_im(i+1) = false) and		// add					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_im(i+3) and									// lda #				; 3
       adc(i+4) and (adc_stack(i+1) = false) and					// adc					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5

       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_stack(i+7) and								// add :STACKORIGIN+10			; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+9			; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
       adc_stack(i+10) and								// adc :STACKORIGIN+STACKWIDTH+10	; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH+9	; 11

       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       add_im_0(i+13) and								// add #$00				; 13
       tay(i+14) and									// tay					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_im_0(i+16) and								// adc #$00				; 16
       sta_stack(i+17) then								// sta :STACKORIGIN+STACKWIDTH+9	; 17

     if argMatch(i+2, i+7) and
        argMatch(i+5, i+10) and
        argMatch(i+6, i+8) and
	argMatch(i+8, i+12) and
	argMatch(i+9, i+11) and
	argMatch(i+11, i+15) then
       begin
	q:=GetWORD(i, i+3);

        	LDA_STA_ADR(i+12, q, '+');

	listing[i+7]  := #9'add ' + copy(listing[i+1], 6, 256);

	listing[i+10] := #9'adc ' + copy(listing[i+4], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if (lda_adr(i+18) or sta_adr(i+19)) and						// lda adr.|				; 18
       (iy(i+18) or iy(i+19)) and							//         |sta adr.			; 19

       lda_val(i) and									// lda					; 0	~lda :STACKORIGIN
       add_sub_im(i+1) and 								// add|sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and									// lda					; 3	~lda :STACKORIGIN
       adc_sbc_im(i+4) and								// adc|sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5

       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       add(i+7) and (add_stack(i+7) = false) and					// add					; 7
       sta_stack(i+8) and								// sta :STACKORIGIN			; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       adc(i+10) and (adc_stack(i+10) = false) and					// adc					; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH		; 11

       lda_stack(i+12) and								// lda :STACKORIGIN			; 12
       add_im_0(i+13) and								// add #$00				; 13
       tay(i+14) and									// tay					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH		; 15
       adc_im_0(i+16) and								// adc #$00				; 16
       sta_stack(i+17) then								// sta :STACKORIGIN+STACKWIDTH		; 17

     if argMatch(i+2, i+6) and
        argMatch(i+6, i+8) and
	argMatch(i+8, i+12) and

        argMatch(i+5, i+9) and
	argMatch(i+9, i+11) and
	argMatch(i+11, i+15) then
       begin
	q:=GetWORD(i+1, i+4);

	if add_im(i+1) then
        	LDA_STA_ADR(i+12, q, '+')
	else
        	LDA_STA_ADR(i+12, q, '-');

	listing[i+6] := listing[i];

	listing[i+9] := listing[i+3];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if (lda_adr(i+18) or sta_adr(i+19)) and						// lda adr.|				; 18
       (iy(i+18) or iy(i+19)) and							//         |sta adr.			; 19

       lda_stack(i) and									// lda :STACKORIGIN+10			; 0
       add_sub_im(i+1) and 								// add|sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc_im(i+4) and								// adc|sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5

       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_stack(i+7) and								// add :STACKORIGIN+10			; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+9			; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
       adc_stack(i+10) and								// adc :STACKORIGIN+STACKWIDTH+10	; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH+9	; 11

       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       add_im_0(i+13) and								// add #$00				; 13
       tay(i+14) and									// tay					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_im_0(i+16) and								// adc #$00				; 16
       sta_stack(i+17) then								// sta :STACKORIGIN+STACKWIDTH+9	; 17

     if argMatch(i, i+2) and
        argMatch(i+2, i+7) and
        argMatch(i+3, i+5) and
        argMatch(i+5, i+10) and
        argMatch(i+6, i+8) and
	argMatch(i+8, i+12) and
	argMatch(i+9, i+11) and
	argMatch(i+11, i+15) then
       begin
	q:=GetWORD(i+1, i+4);

	if add_im(i+1) then
        	LDA_STA_ADR(i+12, q, '+')
	else
        	LDA_STA_ADR(i+12, q, '-');

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if (lda_adr(i+12) or sta_adr(i+13)) and						// lda adr.|				; 12
       (iy(i+12) or iy(i+13)) and							//         |sta adr.			; 13

       lda_stack(i) and									// lda :STACKORIGIN+9			; 0
       add_sub_im(i+1) and 								// add|sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda(i+3) and									// lda :STACKORIGIN+STACKWIDTH+9	; 3
       adc_sbc_im(i+4) and								// adc|sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5

       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_im_0(i+7) and								// add #$00				; 7
       tay(i+8) and									// tay					; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
       adc_im_0(i+10) and								// adc #$00				; 10
       sta_stack(i+11) then								// sta :STACKORIGIN+STACKWIDTH+9	; 11

     if argMatch(i, i+2) and
        argMatch(i+2, i+6) and
        argMatch(i+3, i+5) and
        argMatch(i+5, i+9) and
        argMatch(i+9, i+11) then
       begin
	q:=GetWORD(i+1, i+4);

	if add_im(i+1) then
        	LDA_STA_ADR(i+6, q, '+')
	else
        	LDA_STA_ADR(i+6, q, '-');

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if (lda_adr(i+18) or sta_adr(i+19)) and						// lda adr.|				; 18
       (iy(i+18) or iy(i+19)) and							//         |sta adr.			; 19

       sty_stack(i) and									// sty :STACKORIGIN+STACKWIDTH+10	; 0
       add_sub_im(i+1) and 								// add|sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda :STACKORIGIN+STACKWIDTH+10	; 3
       adc_sbc_im(i+4) and								// adc|sbc #				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5

       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add_stack(i+7) and								// add :STACKORIGIN+10			; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+9			; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH+9	; 9
       adc_stack(i+10) and								// adc :STACKORIGIN+STACKWIDTH+10	; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH+9	; 11

       lda_stack(i+12) and								// lda :STACKORIGIN+9			; 12
       add_im_0(i+13) and								// add #$00				; 13
       tay(i+14) and									// tay					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+9	; 15
       adc_im_0(i+16) and								// adc #$00				; 16
       sta_stack(i+17) then								// sta :STACKORIGIN+STACKWIDTH+9	; 17

     if argMatch(i, i+3) and
        argMatch(i+2, i+7) and
        argMatch(i+3, i+5) and
        argMatch(i+5, i+10) and
        argMatch(i+6, i+8) and
	argMatch(i+8, i+12) and
	argMatch(i+9, i+11) and
	argMatch(i+11, i+15) then
       begin
	q:=GetWORD(i+1, i+4);

	if add_im(i+1) then
        	LDA_STA_ADR(i+12, q, '+')
	else
        	LDA_STA_ADR(i+12, q, '-');

	listing[i] := #9'sty #$00';

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if //lda_a(i) and									// lda					; 0
      add_sub(i+1) and									// add|sub				; 1
      sta_stack(i+2) and								// sta :STACKORIGIN			; 2
      lda_a(i+3) and									// lda					; 3
      adc_sbc(i+4) and									// adc|sbc				; 4
      sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
      mwy(i+6) and									// mwy					; 6
      lda_stack(i+7) and								// lda :STACKORIGIN			; 7
      add_sub(i+8) and									// add|sub				; 8
      sta_stack(i+9) and								// sta :STACKORIGIN			; 9
      lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH		; 10
      adc_sbc(i+11) and									// adc|sbc				; 11
      sta_stack(i+12) and								// sta :STACKORIGIN+STACKWIDTH		; 12
      ldy_stack(i+13) then								// ldy :STACKORIGIN			; 13
    if argMatch(i+2, i+7) and
       argMatch(i+7, i+9) and
       argMatch(i+5, i+10) and
       argMatch(i+10, i+12) and
       argMatch(i+9, i+13) then
    begin

     listing[i+3] := '';
     listing[i+4] := '';
     listing[i+5] := '';

     listing[i+10] := '';
     listing[i+11] := '';
     listing[i+12] := '';

     exit(false);
    end;



end;		// function
