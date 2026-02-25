
function opt_BP_ADR(i: integer): Boolean;
var p,q: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				    BP -> ADR.
// -----------------------------------------------------------------------------

    if lda_l_adr(i) and									// lda <adr.				; 0
       add_stack(i+1) and								// add :STACKORIGIN			; 1
       tay(i+2) and									// tay					; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
       adc_stack(i+4) and								// adc :STACKORIGIN+STACKWIDTH		; 4
       sta_bp_1(i+5) and								// sta :bp+1				; 5
       lda_bp_y(i+6) and								// lda (:bp),y				; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_bp_y(i+8) then								// sta (:bp),y				; 8
    begin

     tmp := #9'sta ' + copy(listing[i+1], 6, 256);

     for p:=i-1 downto 0 do
      if listing[p] = tmp then begin

// -----------------------------------------------------------------------------

    if (p > 1) and
       lda_val(p-2) and (lda_im(p-2) = false) and					// lda					; p-2		+-BYTE
       add_sub_val(p-1) and (add_sub_im(p-1) = false) and				// add|sub				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
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
       lda_val(p-2) and									// lda					; p-2		+-BYTE
       add_sub_val(p-1) and								// add|sub				; p-1
											// sta :STACKORIGIN			; p
//       lda_a(p+1) and									//~lda 					; p+1
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
       lda_val(p-1) and (lda_im(p-1) = false) and					// lda					; p-1		BYTE
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
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
       ((lda_a(p-2) and (lda_im(p-2) = false) and add_im(p-1)) or 			// lda  |lda #				; p-2		#+BYTE
        (lda_im(p-2) and add(p-1) and (add_im(p-1) = false))) and			// add #|add				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
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

	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + '+' + Hex(q, 2) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + '+' + Hex(q, 2) + ',y';

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
       lda_a(p-2) and (lda_im(p-2) = false) and sub_im(p-1) and 			// sub #				; p-1
											// sta :STACKORIGIN			; p
       lda_a(p+1) and									// lda 					; p+1
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

	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + '-' + Hex(q, 2) + ',y';
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + '-' + Hex(q, 2) + ',y';

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
       lda_a(p+1) and									// lda 					; p+1
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


    if lda_l_adr(i) and									// lda <adr.				; 0		#BYTE
       add_im(i+1) and									// add #				; 1
       tay(i+2) and									// tay					; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
       adc_im(i+4) and									// adc #				; 4
       sta_bp_1(i+5) and								// sta :bp+1				; 5
       lda_bp_y(i+6) and								// lda (:bp),y				; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_bp_y(i+8) then								// sta (:bp),y				; 8
    begin
	q:=getWORD(i+1, i+4);

	listing[i+6] := #9'lda ' + copy(listing[i], 7, 256) + '+' + Hex(q, 2);
	listing[i+8] := #9'sta ' + copy(listing[i], 7, 256) + '+' + Hex(q, 2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
    end;


    if lda_l_adr(i) and									// lda <adr.				; 0		BYTE
       add(i+1) and (add_stack(i+1) = false) and (add_im(i+1) = false) and		// add 					; 1
       tay(i+2) and									// tay					; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
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

// -----------------------------------------------------------------------------

    if ldy_im_0(i+4) and								// ldy #$00				; 4

       lda_l_adr(i) and									// lda <adr.				; 0
       sta_bp2(i+1) and									// sta :bp2				; 1
       lda_h_adr(i+2) and								// lda >adr.				; 2
       sta_bp2_1(i+3) and								// sta :bp2+1				; 3
//       ldy_im_0(i+4) and								// ldy #$00				; 4
       lda_bp2_y(i+5) and								// lda (:bp2),y				; 5
       (sta_a(i+6) or tay(i+6)) and							// sta|tay				; 6
       (iny(i+7) = false) then								//~iny					; 7
     if copy(listing[i], 7, 256) = copy(listing[i+2], 7, 256) then
      begin
	listing[i] := #9'lda ' + copy(listing[i], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if ldy_im_0(i+6) and								// ldy #$00				; 6

       lda_l_adr(i) and									// lda <adr.				; 0
       add_sub_val(i+1) and (iy(i+1) = false) and					// add|sub				; 1
       sta_bp2(i+2) and									// sta :bp2				; 2
       lda_h_adr(i+3) and								// lda >adr.				; 3
       adc_sbc_im_0(i+4) and								// adc|sbc #$00				; 4
       sta_bp2_1(i+5) and								// sta :bp2+1				; 5
//       ldy_im_0(i+6) and								// ldy #$00				; 6
       lda_bp2_y(i+7) and								// lda (:bp2),y				; 7
       (sta_a(i+8) or tay(i+8)) and							// sta|tay				; 8
       (iny(i+9) = false) then								//~iny					; 9
     if copy(listing[i], 7, 256) = copy(listing[i+3], 7, 256) then
      begin
	listing[i+7] := #9'lda ' + copy(listing[i], 7, 256) + ',y';
	listing[i+6] := #9'ldy ' + copy(listing[i+1], 6, 256) ;

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
      end;


    if ldy_im_0(i+12) and								// ldy #$00				; 12

       lda_im_0(i) and									// lda #$00				; 0
       asl_stack(i+1) and								// asl :STACKORIGIN			; 1
       rol_a(i+2) and									// rol @				; 2
       asl_stack(i+3) and								// asl :STACKORIGIN			; 3
       rol_a(i+4) and									// rol @				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_l_adr(i+6) and								// lda <adr.				; 6
       add_stack(i+7) and								// add :STACKORIGIN			; 7
       sta_bp2(i+8) and									// sta :bp2				; 8
       lda_h_adr(i+9) and								// lda >adr.				; 9
       adc_stack(i+10) and								// adc :STACKORIGIN+STACKWIDTH		; 10
       sta_bp2_1(i+11) and								// sta :bp2+1				; 11
//       ldy_im_0(i+12) and								// ldy #$00				; 12
       lda_bp2_y(i+13) and								// lda (:bp2),y				; 13
       (sta_a(i+14) or tay(i+14)) and							// sta|tay				; 14
       (iny(i+15) = false) then								//~iny					; 15
     if (copy(listing[i+6], 7, 256) = copy(listing[i+9], 7, 256)) and
        argMatch(i+3, i+7) and
        argMatch(i+5, i+10) then
      begin
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := #9'lda ' + copy(listing[i+6], 7, 256) + ',y';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';

	exit(false);
      end;


    if ldy_im_0(i+12) and								// ldy #$00				; 12

       lda_im_0(i) and									// lda #$00				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and									// lda A				; 2
       asl_a(i+3) and									// asl @				; 3
       rol_stack(i+4) and								// rol :STACKORIGIN+STACKWIDTH		; 4
       asl_a(i+5) and									// asl @				; 5
       rol_stack(i+6) and								// rol :STACKORIGIN+STACKWIDTH		; 6
       add_l_adr(i+7) and								// add <adr.				; 7
       sta_bp2(i+8) and									// sta :bp2				; 8
       lda_h_adr(i+9) and								// lda >adr.				; 9
       adc_stack(i+10) and								// adc :STACKORIGIN+STACKWIDTH		; 10
       sta_bp2_1(i+11) and								// sta :bp2+1				; 11
//       ldy_im_0(i+12) and								// ldy #$00				; 12
       lda_bp2_y(i+13) and								// lda (:bp2),y				; 13
       (sta_a(i+14) or tay(i+14)) and							// sta|tay				; 14
       (iny(i+15) = false) then								//~iny					; 15
     if (copy(listing[i+7], 7, 256) = copy(listing[i+9], 7, 256)) and
        argMatch(i+1, i+10) then
      begin
	listing[i]   := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'tay';
	listing[i+4] := #9'lda ' + copy(listing[i+7], 7, 256) + ',y';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';

	exit(false);
      end;

end;		// function
