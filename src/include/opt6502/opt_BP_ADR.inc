
function opt_BP_ADR(i: integer): Boolean;
var p,q: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				    BP -> ADR.
// -----------------------------------------------------------------------------

    if (pos(#9'lda <adr.', listing[i]) > 0) and						// lda <adr.				; 0
       add_stack(i+1) and								// add :STACKORIGIN			; 1
       tay(i+2) and									// tay					; 2
       (pos(#9'lda >adr.', listing[i+3]) > 0) and					// lda >adr.				; 3
       adc_stack(i+4) and								// adc :STACKORIGIN+STACKWIDTH		; 4
       sta_bp_1(i+5) and								// sta :bp+1				; 5
       lda_bp_y(i+6) and								// lda (:bp),y				; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_bp_y(i+8) then								// sta (:bp),y				; 8
    begin
     tmp:=#9'sta ' + copy(listing[i+1], 6, 256);

     for p:=i-1 downto 0 do
      if listing[p] = tmp then begin

// -----------------------------------------------------------------------------

    if (p > 1) and
       lda(p-2) and (lda_stack(p-2) = false) and (lda_im(p-2) = false) and		// lda					; p-2		+-BYTE
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       adc_sbc(p+2) and									// adc|sbc				; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := listing[p-2];
	listing[i+4] := listing[p-1];
	listing[i+5] := #9'tay';

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;


    if (p > 1) and
       lda(p-2) and (lda_stack(p-2) = false) and					// lda					; p-2		+-BYTE
       add_sub_val(p-1) and								// add|sub				; p-1
											// sta :STACKORIGIN			; p
//       lda(p+1) and									//~lda 					; p+1
       (adc_sbc(p+2) = false) then							//~adc|sbc				; p+2
//       sta_stack(p+3) then								//~sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := listing[p-2];
	listing[i+4] := listing[p-1];
	listing[i+5] := #9'tay';

	listing[p-2] := '';
	listing[p-1] := '';
	listing[p]   := '';

	Result:=false; Break;
      end;


    if (p > 0) and
       lda(p-1) and (lda_stack(p-1) = false) and (lda_im(p-1) = false) and		// lda					; p-1		BYTE
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       add_sub(p+2) and									// add_sub				; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := listing[p-1];
	listing[i+5] := #9'tay';

	listing[p-1] := '';
	listing[p]   := '';
	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;

// -----------------------------------------------------------------------------

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

	 listing[i+4] := #9'ldy ' + copy(listing[p-1], 6, 256);
	 listing[i+5] := '';
	end else begin
	 q:=GetWORD(p-1, p+2);

	 if iy(p-2) = false then begin
 	  listing[i+4] := #9'ldy ' + copy(listing[p-2], 6, 256);
 	  listing[i+5] := '';
	 end else begin
	  listing[i+4] := #9'lda ' + copy(listing[i+1], 6, 256);
	  listing[i+5] := #9'tay';
	 end;

	end;

	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + '+$' + IntToHex(q, 2) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + '+$' + IntToHex(q, 2) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

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
       (lda_stack(p-2) = false) and (sub_stack(p-1) = false) and			// lda  				; p-2		#-BYTE
       lda(p-2) and (lda_im(p-2) = false) and sub_im(p-1) and 				// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda(p+1) and									// lda 					; p+1
       sbc(p+2) and									// sbc 					; p+2
       sta_stack(p+3) then								// sta :STACKORIGIN+STACKWIDTH		; p+3
      begin
{
	if lda_im(p-2) then begin
	 q:=GetWORD(p-2, p+1);

	 listing[i+4] := #9'ldy ' + copy(listing[p-1], 6, 256);
	 listing[i+5] := '';
	end else begin}
	 q:=GetWORD(p-1, p+2);

	 if iy(p-2) = false then begin
 	  listing[i+4] := #9'ldy ' + copy(listing[p-2], 6, 256);
 	  listing[i+5] := '';
	 end else begin
	  listing[i+4] := #9'lda ' + copy(listing[i+1], 6, 256);
	  listing[i+5] := #9'tay';
	 end;

//	end;

	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + '-$' + IntToHex(q, 2) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + '-$' + IntToHex(q, 2) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

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
//	listing[i+3]  := '';
//	listing[i+4]  := '';
//	listing[i+5]  := '';

	listing[p+1] := '';
	listing[p+2] := '';
	listing[p+3] := '';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------

       Break;
      end;	// for p:=

     if Result = false then exit(false);
    end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


    if (pos(#9'lda <adr.', listing[i]) > 0) and						// lda <adr.				; 0		#BYTE
       add_im(i+1) and									// add #				; 1
       tay(i+2) and									// tay					; 2
       (pos(#9'lda >adr.', listing[i+3]) > 0) and					// lda >adr.				; 3
       adc_im(i+4) and									// adc #				; 4
       sta_bp_1(i+5) and								// sta :bp+1				; 5
       lda_bp_y(i+6) and								// lda (:bp),y				; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_bp_y(i+8) then								// sta (:bp),y				; 8
    begin
	q:=getWORD(i+1, i+4);

	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + '+$' + IntToHex(q, 2);
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + '+$' + IntToHex(q, 2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
    end;


    if (pos(#9'lda <adr.', listing[i]) > 0) and						// lda <adr.				; 0		BYTE
       add(i+1) and (add_stack(i+1) = false) and (add_im(i+1) = false) and		// add 					; 1
       tay(i+2) and									// tay					; 2
       (pos(#9'lda >adr.', listing[i+3]) > 0) and					// lda >adr.				; 3
       adc_im(i+4) and									// adc					; 4
       sta_bp_1(i+5) and								// sta :bp+1				; 5
       lda_bp_y(i+6) and								// lda (:bp),y				; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_bp_y(i+8) then								// sta (:bp),y				; 8
    begin
	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + ',y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
    end;

end;		// function