
function opt_STACK(i: integer): Boolean;
var p: integer;
    tmp: string;
    yes: Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      STACK.
// -----------------------------------------------------------------------------

    if dex(i) and 										// dex
       inx(i+1) then										// inx
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx
       dex(i+1) then										// dex
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (l = i + 3) and
       inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       dex(i+2) then										// dex					; 2
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
      end;


    if (l = i + 4) and
       inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       dex(i+3) then										// dex					; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
      end;


    if (l = i + 6) and
       inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       mva(i+3) and 										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 3
       mva(i+4) and										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 4
       dex(i+5) then										// dex					; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       exit(false);
      end;


    if inx(i) and										// inx				; 0
       lda(i+1) and (ix(i+1) = false) and							// lda				; 1
       (listing[i+2] = #9'sta @PARAM?') and							// sta @PARAM?			; 2
       dex(i+3) then										// dex				; 3
     begin
       listing[i]   := '';
       listing[i+3] := '';
       exit(false);
     end;


    if (listing[i] = #9'sta @PARAM?.@NIL') then							// sta @PARAM?.@NIL		; 0
     begin
       listing[i] := #9'sta #$00';
       exit(false);
     end;


    if (SKIP(i-1) = false) and
       lda_stack(i) and										// lda :STACKORIGIN+9		; 0
       sta_stack(i+1) then									// sta :STACKORIGIN+9		; 1
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin
       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN		; 0
       (listing[i+1] = #9'sta #$00') then							// sta #$00			; 1
     begin
       listing[i]   := '';
       listing[i+1] := '';
       exit(false);
     end;


     if (listing[i] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x
        (listing[i+1] = #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x') then			// mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x
      begin
       listing[i]   := #9'sta :STACKORIGIN,x';
       listing[i+1] := '';

       exit(false);
      end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda 				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN		; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda 				; 2
       sta_stack(i+3) then									// sta :STACKORIGIN		; 3
     if copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256) then begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN+9		; 0
       and_ora_eor(i+1) and									// and|ora|eor			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9		; 2
       (listing[i+3] = listing[i]) and								// lda :STACKORIGIN+9		; 3
       sta(i+4) and (sta_stack(i+4) = false) then						// sta				; 4
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
      begin
       listing[i+2] := '';
       listing[i+3] := '';
       exit(false);
     end;


    if sty_stack(i) and lda_stack(i+1) then							// sty :STACKORIGIN+9		; 0
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin			// lda :STACKORIGIN+9		; 1
       listing[i]   := #9'tya';
       listing[i+1] := '';
       exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN,x		; 0
       ldy_stack(i+1) and									// ldy :STACKORIGIN-1,x		; 1
       lda_stack(i+2) then									// lda :STACKORIGIN,x		; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
       listing[i]   := '';
       listing[i+2] := '';
       exit(false);
     end;


    if mva(i) and										// mva I :STACKORIGIN,x		; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') then						// lda :STACKORIGIN,x		; 1
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+1] := #9'lda ' + GetSTRING(i);
       listing[i]   := '';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x		; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x		; 1
       sta(i+2) and (sta_stack(i+2) = false) then						// sta TILE			; 2
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN,x		; 1
       ldy_stack(i+2) then									// ldy :STACKORIGIN,x		; 2
     if copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256) then
     begin

       if iy(i) = false then begin
        listing[i]   := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+1] := '';
       end else
        listing[i+1] := #9'tay';

       listing[i+2] := '';

       exit(false);
     end;


    if lda_a(i) and										// lda					; 0
       add_sub(i+1) and	(add_sub_stack(i+1) = false) and					// add|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       lda_a(i+3) and										// lda					; 3
       adc_sbc(i+4) and										// adc|sbc				; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 5
       (listing[i+6] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 6
     begin
       listing[i+2] := #9'tay';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if (i>1) and										// mva A	; -2
       mva(i) and										// inx		; -1
       inx(i-1) and										// mva A	; 0
       mva(i-2) then										// inx		; 1
     if listing[i] = listing[i-2] then begin							// mva A	; 2
       listing[i] := #9'sta ' + copy(listing[i], pos(':STACK', listing[i]), 256);
       if inx(i+1) and (listing[i-2] = listing[i+2]) then
	listing[i+2] := #9'sta ' + copy(listing[i+2], pos(':STACK', listing[i+2]), 256);

       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN,x			; 0
       ((listing[i+1] = #9'add #$01') or (listing[i+1] = #9'sub #$01')) and			// add|sub #$01				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN,x			; 2
       (inx(i+3) or dex(i+3)) then								// inx|dex				; 3
    if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin

       if listing[i+1] = #9'add #$01' then
        listing[i+1] := #9'inc ' + copy(listing[i], 6, 256)
       else
        listing[i+1] := #9'dec ' + copy(listing[i], 6, 256);

       listing[i] := '';

       listing[i+2] := '';

       exit(false);
     end;


    if lda(i) and (lda_stack(i) = false) and (iy(i) = false) and				// lda					; 0
       ((listing[i+1] = #9'add #$01') or (listing[i+1] = #9'sub #$01')) and			// add|sub #$01				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN,x			; 2
       (inx(i+3) or dex(i+3)) and								// inx|dex				; 3
       (inx(i+4) = false) and (dex(i+4) = false) then
     begin

       if listing[i+1] = #9'add #$01' then
        listing[i+1] := #9'iny'
       else
        listing[i+1] := #9'dey';

       listing[i] := #9'ldy ' + copy(listing[i], 6, 256);

       listing[i+2] := #9'sty ' + copy(listing[i+2], 6, 256);

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       and_ora_eor(i+2) and (and_ora_eor_stack(i+2) = false) and				// and|ora|eor				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       sta_a(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';

       listing[i+3] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       sta_a(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       sta_a(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       lda_a(i+5) and (lda_stack(i+5) = false) and						// lda					; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       lda_a(i+7) and (lda_stack(i+7) = false) and						// lda					; 7
       sta_a(i+8) and (sta_stack(i+8) = false) and						// sta					; 8
       dex(i+9) then										// dex					; 9
     begin
       listing[i]   := '';

       listing[i+9] := '';

       exit(false);
     end;



    if inx(i) and										// inx					; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       iny(i+2) and										// iny					; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+6] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda					; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       lda_a(i+8) and (lda_stack(i+8) = false) and						// lda					; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       dex(i+10) then										// dex					; 10
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+10] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       (listing[i+3] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i+3] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva					; 1
       mwy_bp2(i+2) and										// mwy G :bp2				; 2
       ldy(i+3) and (ldy_stack(i+3) = false) and						// ldy					; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       dex(i+6) then										// dex					; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i]   := '';
	listing[i+1] := '';

	listing[i+6] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva					; 1
       mva(i+2) and										// mva					; 2
       mwy_bp2(i+3) and										// mwy G :bp2				; 3
       ldy(i+4) and (ldy_stack(i+4) = false) and						// ldy					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       iny(i+7) and										// iny					; 7
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       dex(i+10) then										// dex					; 10
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+10] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       (listing[i+3] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
       sta_a(i+7) and (sta_stack(i+7) = false) then						// sta					; 7
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i+6] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if mva(i) and										// mva	 :STACKORIGIN,x			; 0
       mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 2
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
     begin
       listing[i+2] := #9'ldy ' + GetSTRING(i);

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       (listing[i+2] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_a(i+4) and (sta_stack(i+4) = false) then						// sta					; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta 					; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_a(i+5) and (sta_stack(i+5) = false) then						// sta					; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva   :STACKORIGIN,x			; 1
       dex(i+2) and										// dex					; 2
       mwy_bp2(i+3) and										// mwy 					; 3
       ldy(i+4) and (ldy_stack(i+4) = false) and						// ldy					; 4
       (listing[i+5] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva	 :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+2] := '';
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and										// mva					; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       (listing[i+5] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 5
       sta_a(i+6) and (sta_stack(i+6) = false) then						// sta					; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+5] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       lda(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta(i+4) and										// sta					; 4
       lda(i+5) and (lda_stack(i+5) = false) and						// lda					; 5
       sta(i+6) and										// sta					; 6
       (listing[i+7] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 7
       sta_a(i+8) and (sta_stack(i+8) = false) and						// sta					; 8
       (listing[i+9] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 9
       sta_a(i+10) and (sta_stack(i+10) = false) then						// sta					; 10
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+7] := #9'lda ' + GetString(i+1);

	listing[i+9] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       dex(i+7) then										// dex					; 7
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and										// mva					; 3
       mva(i+4) and 										// mva					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       sta_a(i+8) and (sta_stack(i+8) = false) and						// sta					; 8
       dex(i+9) then										// dex					; 9
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+7] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva	 :STACKORIGIN,x			; 1
       mva(i+2) and										// mva	 :STACKORIGIN+STACKWIDTH,x	; 2
       inx(i+3) and										// inx					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda					; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       (listing[i+8] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       (listing[i+10] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 10
       sta_a(i+11) and (sta_stack(i+11) = false) then						// sta					; 11
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+8] := #9'lda ' + GetString(i+1);

	listing[i+10] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda					; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH*2,x') and					// sta :STACKORIGIN+STACKWIDTH*2,x	; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda					; 6
       (listing[i+7] = #9'sta :STACKORIGIN+STACKWIDTH*3,x') and					// sta :STACKORIGIN+STACKWIDTH*3,x	; 7
       (listing[i+8] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_a(i+11) and (sta_stack(i+11) = false) and						// sta					; 11
       (listing[i+12] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 12
       sta_a(i+13) and (sta_stack(i+13) = false) and						// sta					; 13
       (listing[i+14] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 14
       sta_a(i+15) and (sta_stack(i+15) = false) then						// sta					; 15
     begin
	listing[i+8]  := #9'lda ' + GetString(i);

	listing[i+10] := #9'lda ' + GetString(i+2);

	listing[i+12] := #9'lda ' + GetString(i+4);

	listing[i+14] := #9'lda ' + GetString(i+6);

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


    if lda_a(i) and (lda_stack(i) = false) and							// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH,x	; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda					; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       lda_stack(i+8) and									// lda :STACKORIGIN,x			; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_a(i+11) and (sta_stack(i+11) = false) then						// sta					; 11
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
     begin
	listing[i+8]  := #9'lda ' + copy(listing[i], 6, 256);

	listing[i+10] := #9'lda ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       (listing[i+4] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       (listing[i+6] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       (listing[i+8] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       (listing[i+10] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 10
       sta_a(i+11) and (sta_stack(i+11) = false) then						// sta					; 11
     if (pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN-1+STACKWIDTH*2,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN-1+STACKWIDTH*3,x', listing[i+3]) > 0) then
     begin
	listing[i+6] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i+10] := #9'lda ' + GetString(i+3);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       sta_a(i+8) and (sta_stack(i+8) = false) and						// sta					; 8
       (listing[i+9] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and					// lda :STACKORIGIN+STACKWIDTH*2,x	; 9
       sta_a(i+10) and (sta_stack(i+10) = false) and						// sta					; 10
       (listing[i+11] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 11
       sta_a(i+12) and (sta_stack(i+12) = false) then						// sta					; 12
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+7] := #9'lda ' + GetString(i+2);

	listing[i+9] := #9'lda ' + GetString(i+3);

	listing[i+11] := #9'lda ' + GetString(i+4);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       sta_a(i+8) and (sta_stack(i+8) = false) and						// sta					; 8
       (listing[i+9] <> #9'lda :STACKORIGIN+STACKWIDTH*2,x') then				// lda :STACKORIGIN+STACKWIDTH*2,x	; 9
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+7] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4
       (listing[i+5] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 5
       (listing[i+6] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 10
       sta_a(i+11) and (sta_stack(i+11) = false) and						// sta					; 11
       (listing[i+12] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 12
       sta_a(i+13) and (sta_stack(i+13) = false) then						// sta					; 13
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+6] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i+10] := #9'lda ' + GetString(i+3);

	listing[i+12] := #9'lda ' + GetString(i+4);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and 										// mva					; 3
       mva(i+4) and 										// mva					; 4
       lda(i+5) and (lda_stack(i+5) = false) and						// lda					; 5
       ldy(i+6) and (ldy_stack(i+6) = false) and						// ldy					; 6
       add_im(i+7) and										// add #				; 7
       sta_bp2(i+8) and										// sta :bp2				; 8
       scc(i+9) and										// scc					; 9
       iny(i+10) and										// iny					; 10
       (listing[i+11] = #9'sty :bp2+1') and							// sty :bp2+1				; 11
       (listing[i+12] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 12
       (listing[i+13] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 13
       sta_bp2_y(i+14) and									// sta (:bp2),y				; 14
       iny(i+15) and										// iny					; 15
       (listing[i+16] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 16
       sta_bp2_y(i+17) and									// sta (:bp2),y				; 17
       iny(i+18) and										// iny					; 18
       (listing[i+19] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 19
       sta_bp2_y(i+20) and									// sta (:bp2),y				; 20
       iny(i+21) and										// iny					; 21
       (listing[i+22] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 22
       sta_bp2_y(i+23) and									// sta (:bp2),y				; 23
       dex(i+24) then										// dex					; 24
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+12] := #9'ldy :STACKORIGIN,x';
	listing[i+13] := #9'lda ' + GetString(i+1);

	listing[i+16] := #9'lda ' + GetString(i+2);

	listing[i+19] := #9'lda ' + GetString(i+3);

	listing[i+22] := #9'lda ' + GetString(i+4);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+24] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       (add_sub_stack(i+3) or and_ora_eor_stack(i+3)) and					// add|sub|and|ora|eor :STACKORIGIN,x	; 3
       sta_a(i+4) and (sta_stack(i+4) = false) then						// sta					; 4
     if (pos(':STACKORIGIN,x', listing[i+3]) > 0) then
     begin
	listing[i+3] := copy(listing[i+3], 1, 5) + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva					; 1
       dex(i+2) and										// dex					; 2
       (listing[i+3] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda ' + GetString(i+1);
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';
       listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';
       listing[i+3] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';
       listing[i+4] := '';

       exit(false);
     end;


    if (listing[i] = #9'jsr movZTMP_aBX') and							// jsr movZTMP_aBX			; 0
       dex(i+1) and										// dex					; 1
       (pos('mva :STACKORIGIN,x', listing[i+2]) > 0) and					// mva :STACKORIGIN,x NEW		; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';

       listing[i+2] := #9'mva :ztmp8 ' + copy(listing[i+2], 21, 256);

       exit(false);
     end;


    if mva(i) and (iy(i) = false) and								// mva aa :STACKORIGIN,x		; 0
       ldy_1(i+1) and										// ldy #1				; 1
       (listing[i+2] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 2
       (listing[i+3] = #9'cmp :STACKORIGIN,x') then						// cmp :STACKORIGIN,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+3] := #9'cmp ' + GetString(i);
       listing[i]   := '';

       exit(false);
     end;


    if mva(i) and (iy(i) = false) and								// mva aa :STACKORIGIN,x		; 0
       ldy_1(i+1) and										// ldy #1				; 1
       (listing[i+2] = #9'jsr cmpSHORTINT') and							// jsr cmpSHORTINT			; 2
       (beq(i+3) or bne(i+3)) and								// beq|bne				; 3
       dey(i+4) then										// dey					; 4
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+2] := #9'cmp ' + GetString(i);
       listing[i+1] := #9'lda :STACKORIGIN-1,x';
       listing[i] := #9'ldy #1';

       exit(false);
     end;


    if mva(i) and (iy(i) = false) and								// mva aa :STACKORIGIN,x		; 0
       inx(i+1) and										// inx					; 1
       ldy_1(i+2) and										// ldy #1				; 2
       (listing[i+3] = #9'lda :STACKORIGIN-1,x') then						// lda :STACKORIGIN-1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+3] := #9'lda ' + GetString(i);
       listing[i]   := '';

       exit(false);
     end;


    if lda(i) and										// lda                                  ; 0
       cmp_im_0(i+1) and									// cmp #$00				; 1
       (bne(i+2) or beq(i+2)) and								// bne @+				; 2
       dey(i+3) and										// dey                  		; 3
       lab_a(i+4) and										//@					; 4
       sty_stack(i+5) then									// sty :STACK				; 5
     begin
       listing[i+1] := '';

       exit(false);
     end;


    if lda(i) and										// lda                                  ; 0
       cmp_im_0(i+1) and									// cmp #$00				; 1
       (bne(i+2) or beq(i+2)) and								// bne @+				; 2
       dey(i+3) and										// dey                  		; 3
       lab_a(i+4) and										//@					; 4
       sty_stack(i+5) then									// sty :STACK				; 5
     begin
       listing[i+1] := '';

       exit(false);
     end;


    if lda(i) and										// lda                                  ; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda(i+2) and										// lda					; 2
       sta_bp2_1(i+3) and									// sta :bp2+1                  		; 3
       ldy(i+4) then										// ldy					; 4
     if pos(listing[i], listing[i+2]) > 0 then
      begin
       listing[i]   := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
      end;


    if mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       (listing[i+2] = #9'mva (:bp2),y :STACKORIGIN,x') and					// mva (:bp2),y :STACKORIGIN,x		; 2
       dex(i+3) then										// dex                  		; 3
     begin
       listing[i+3] := #9'mva (:bp2),y :STACKORIGIN+1,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       (listing[i+2] = #9'mva (:bp2),y :STACKORIGIN+1,x') and					// mva (:bp2),y :STACKORIGIN+1,x	; 2
       dex(i+3) then										// dex                  		; 3
     begin
       listing[i+3] := #9'mva (:bp2),y :STACKORIGIN+2,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if (pos('mva (:bp2),y', listing[i]) > 0) and						// mva (:bp2),y :STACKORIGIN,x		; 0
       lda(i+1) and										// lda                  		; 1
       cmp_stack(i+2) then									// cmp :STACKORIGIN,x			; 2
     if pos(copy(listing[i+2], 6, 256), listing[i]) > 0 then
     begin
       listing[i+2] := #9'cmp (:bp2),y';

       listing[i] := '';

       exit(false);
     end;


    if jsr(i) and										// jsr					; 0
       (listing[i+1] = #9'mva #$00 :STACKORIGIN+STACKWIDTH,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'm@index2 0') and							// m@index2 0				; 2
       (listing[i+3] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 3
     begin

       listing[i+1] := #9'lda :STACKORIGIN,x';
       listing[i+2] := #9'asl @';
       listing[i+3] := #9'tay';

       exit(false);
     end;


    if ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH		; 1
       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH,x	; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*2,x	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*3,x	; 6
       ldy(i+7) and										// ldy :STACKORIGIN-1,x			; 7
       lda_stack(i+8) and									// lda :STACKORIGIN,x			; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_a(i+11) and (sta_stack(i+11) = false) and						// sta					; 11
       dex(i+12) then										// dex					; 12
    if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
       (copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) then
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH		; 1
       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH,x	; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*2,x	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*3,x	; 6
       lda_stack(i+7) and									// lda :STACKORIGIN,x			; 7
       sta_a(i+8) and										// sta					; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKORIGIN,x	; 9
       sta_a(i+10) and										// sta					; 10
       dex(i+11) then										// dex					; 11
    if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
       (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) then
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if (lda(i) or lda_adr(i)) and								// lda					; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       (lda(i+2) or lda_adr(i+2)) and								// lda					; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       (sta(i+5) or sta_adr(i+5)) and								// sta					; 5
       (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
       (sta(i+7) or sta_adr(i+7)) then								// sta					; 7
     begin
       listing[i+4] := #9'lda ' + copy(listing[i], 6, 256);

       listing[i+6] := #9'lda ' + copy(listing[i+2], 6, 256);

       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       lda_bp2(i+1) and										// lda :bp2				; 1
       add_im(i+2) and (pos('-DATAORIGIN', listing[i+2]) > 0) and				// add #CONTEXT.STATE-DATAORIGIN	; 2
       sta_bp2(i+3) and										// sta :bp2				; 3
       lda_bp2_1(i+4) and									// lda :bp2+1				; 4
       adc_im_0(i+5) and									// adc #$00				; 5
       sta_bp2_1(i+6) and									// sta :bp2+1				; 6
       ldy_stack(i+7) then 									// ldy :STACKORIGIN,x			; 7
     begin

      for p:=i-1 downto 0 do
       if inx(p) and mva_im(p+1) and (mva(p+2) or sta(p+2)) and
         (pos(':STACKORIGIN,x', listing[p+1]) > 0) and
         (pos(':STACKORIGIN+STACKWIDTH,x', listing[p+2]) > 0) then
	begin
       	 listing[i+7] := #9'ldy ' + copy(listing[i+2], 6, 256) + '+$' + IntToHex(GetBYTE(p+1), 2);

       	 listing[p+1] := '';
	 listing[p+2] := '';

	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';

	 exit(false);
	end;

       if Result then begin
	listing[i+1] := #9'ldy ' + GetString(i) + '+1';

	listing[i] := #9'lda ' + GetString(i);

	listing[i+4] := #9'scc';
	listing[i+5] := #9'iny';
	listing[i+6] := #9'sty :bp2+1';

	exit(false);
       end;

     end;


    if lab_a(i) and										//@					; 0
       (listing[i+1] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 1
       dex(i+2) and										// dex					; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
       listing[i+1] := '';
       listing[i+4] := #9'tya';

       exit(false);
     end;


    if lab_a(i) and										//@					; 0
       sty_stack(i+1) and									// sty :STACKORIGIN+2,x			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+1,x			; 2
       and_ora_eor_stack(i+3) then								// and|ora|eor :STACKORIGIN+2,x		; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) then
     begin
       listing[i+1] := #9'tya';
       listing[i+2] := copy(listing[i+3], 1, 5) + copy(listing[i+2], 6, 256);
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       and_ora_eor_im(i+1) and									// and|ora|eor #			; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
       listing[i+2] := listing[i+1];

       listing[i]   := #9'dex';
       listing[i+1] := #9'lda :STACKORIGIN+1,x';

       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if and_ora_eor_im(i) and									// and|ora|eor #			; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       ldy_1(i+2) and										// ldy #1				; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') then						// lda :STACKORIGIN,x			; 3
     begin
       listing[i+3] := listing[i];

       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       and_ora_eor(i+2) and									// and|ora|eor #			; 2
       (listing[i+3] = #9'sta :STACKORIGIN,x') then						// sta :STACKORIGIN,x			; 3
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0	byte_0 > byte_1 -> byte_1 < byte_0
       lda(i+1) and 										// lda 					; 1
       cmp(i+2) and										// cmp					; 2
       seq(i+3) and										// seq					; 3
       bcs(i+4) and										// bcs @+				; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) then										//@					; 6
     begin
       listing[i+3] := #9'cmp ' + copy(listing[i+1], 6, 256);
       listing[i+4] := #9'bcc @+';

       listing[i+2] := #9'lda ' + copy(listing[i+2], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0	byte_0 >= byte_1 -> byte_1 <= byte_0
       lda(i+1) and 										// lda 					; 1
       cmp(i+2) and										// cmp					; 2
       bcc(i+3) and										// bcc @+				; 3
       beq(i+4) and										// beq @+				; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) then										//@					; 6
     begin
       listing[i+3] := #9'cmp ' + copy(listing[i+1], 6, 256);
       listing[i+4] := #9'bcs @+';

       listing[i+2] := #9'lda ' + copy(listing[i+2], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       dey(i+1) and										// dey			; 1
       lab_a(i+2) and										//@			; 2
       tya(i+3) and										// tya			; 3
       jne(i+4) then										// jne l_		; 4
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+4], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (lda(i+1) or and_ora_eor(i+1)) and							// lda|and|ora|eor			; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       tya(i+5) and										// tya					; 5
       jeq(i+6) then										// jeq					; 6
     begin
       listing[i+3] := #9'jmp ' + copy(listing[i+6], 6, 256);

       listing[i+5] := '';
       listing[i+6] := '';

       listing[i] := '';
       exit(false);
     end;


  if ldy_1(i) and										// ldy #1				; 0
     (lda(i+1) or and_ora_eor(i+1)) and								// lda|and|ora|eor			; 1
     cmp(i+2) and										// cmp					; 2
     SKIP(i+3) and										// SKIP					; 3
     dey(i+4) and										// dey					; 4
     lab_a(i+5) and										//@					; 5
     tya(i+6) then begin									// tya					; 6

    if jeq(i+7) then										// jeq					; 7
     begin
       listing[i+4] := #9'jmp ' + copy(listing[i+7], 6, 256);

       listing[i+6] := '';
       listing[i+7] := '';

       listing[i] := '';
       exit(false);
     end;


    if and_stack(i+7) and									// and :STACKORIGIN,x			; 7
       jeq(i+8) then										// jeq					; 8
     begin
       listing[i+4] := #9'jmp ' + copy(listing[i+8], 6, 256);

       listing[i+6] := #9'lda ' + copy(listing[i+7], 6, 256);
       listing[i+7] := '';

       listing[i] := '';
       exit(false);
     end;


    if and_stack(i+7) and									// and :STACKORIGIN,x			; 7
       jne(i+8) then										// jne					; 8
     begin
       listing[i+4] := #9'jmp ' + copy(listing[i+8], 6, 256) + 'w';

       listing[i+6] := #9'jmp ' + copy(listing[i+8], 6, 256);
       listing[i+7] := copy(listing[i+8], 6, 256) + 'w';
       listing[i+8] := '';

       listing[i] := '';
       exit(false);
     end;


    if cmp_im_0(i+2) then begin
     listing[i+2] := '';
     exit(false);
    end;

  end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'ora :STACKORIGIN,x') and						// ora :STACKORIGIN,x			; 2
       (bne(i+3) or beq(i+3)) and								// bne|beq @+				; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) and										// dex					; 6
       tya(i+7) and										// tya					; 7
       jeq(i+8) then 										// jeq l_				; 8
     begin
       if beq(i+3) then listing[i+8] := #9'jne ' + copy(listing[i+8], 6, 256);

       listing[i]   := #9'dex';
       listing[i+1] := #9'lda :STACKORIGIN+1+STACKWIDTH,x';
       listing[i+2] := #9'ora :STACKORIGIN+1,x';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       ldy_1(i+1) and										// ldy #1				; 1
       lda(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       SKIP(i+3) and										// bmi @+				; 3
       ora(i+4) and (ora_stack(i+4) = false) and						// ora					; 4
       SKIP(i+5) and										// sne					; 5
       lab_a(i+6) and										//@					; 6
       dey(i+7) and										// dey					; 7
       (listing[i+8] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 8
       dex(i+9) then 										// dex					; 9
     begin
       listing[i] := '';

       listing[i+8] := #9'sty :STACKORIGIN,x';
       listing[i+9] := '';

       exit(false);
     end;


    if (listing[i] = #9'inx:inx') and								// inx:inx				; 0
       ldy_1(i+1) and										// ldy #1				; 1
       lda(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       cmp(i+3) and (cmp_stack(i+3) = false) and						// cmp					; 3
       SKIP(i+4) and										// bne @+				; 4
       lda(i+5) and (lda_stack(i+5) = false) and						// lda					; 5
       cmp(i+6) and (cmp_stack(i+6) = false) and						// cmp					; 6
       lab_a(i+7) and										//@					; 7
       SKIP(i+8) and										// bcc @+				; 8
       dey(i+9) and										// dey					; 9
       lab_a(i+10) and										//@					; 10
       (listing[i+11] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 11
       dex(i+12) then 										// dex					; 12
     begin
       listing[i] := #9'inx';

       listing[i+11] := #9'sty :STACKORIGIN,x';
       listing[i+12] := '';

       exit(false);
     end;


    if mva(i) and (iy(i) = false) and								// mva aa :STACKORIGIN,x		; 0
       (listing[i+1] = #9'jsr andAL_CL') and							// jst andAL_CL				; 1
       ldy_1(i+2) and										// ldy #1				; 2
       (listing[i+3] = #9'lda :STACKORIGIN-1,x') then						// lda :STACKORIGIN-1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i]) > 0) then
     begin
       listing[i+1] := listing[i+2];
       listing[i+2] := listing[i+3];

       listing[i+3] := #9'and ' + GetString(i);
       listing[i]   := '';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 0		2022-03-05
       (listing[i+1] = #9'jsr andAL_CL') and							// jsr andAL_CL				; 1
       dex(i+2) and										// dex					; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'dex';
       listing[i+2] := #9'tya';
       listing[i+3] := #9'and :STACKORIGIN+1,x';
       listing[i+4] := #9'sta :STACKORIGIN+1,x';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'jsr andAL_CL') and							// jsr andAL_CL				; 2
       inx(i+3) then										// inx					; 3
     begin
       listing[i]   := #9'tya';
       listing[i+1] := #9'and :STACKORIGIN-2,x';
       listing[i+2] := #9'sta :STACKORIGIN-2,x';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'jsr andAL_CL') and							// jsr andAL_CL				; 2
       dex(i+3) and										// dex					; 3
       (pos('mva :STACKORIGIN,x ', listing[i+4]) > 0) then					// mva :STACKORIGIN,x RESULT		; 4
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'dex';
       listing[i+2] := #9'tya';
       listing[i+3] := #9'and :STACKORIGIN,x';
       listing[i+4] := #9'sta ' + copy(listing[i+4], 21, 256);

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 0
       (listing[i+1] = #9'jsr andAL_CL') and							// jsr andAL_CL				; 1
       dex(i+2) and										// dex					; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta(i+4) and (sta_stack(i+4) = false) and						// sta RESULT				; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'tya';
       listing[i+2] := #9'and :STACKORIGIN+1,x';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'jsr andAL_CL') and							// jsr andAL_CL				; 2
       dex(i+3) and										// dex					; 3
       dex(i+4) and										// dex					; 4
       (listing[i+5] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 5
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'dex';
       listing[i+2] := #9'dex';
       listing[i+3] := #9'tya';
       listing[i+4] := #9'and :STACKORIGIN+1,x';
       listing[i+5] := '';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 0
       (listing[i+1] = #9'jsr orAL_CL') and							// jsr orAL_CL				; 1
       dex(i+2) and										// dex					; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta(i+4) and (sta_stack(i+4) = false) and						// sta RESULT				; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'tya';
       listing[i+2] := #9'ora :STACKORIGIN,x';
       listing[i+3] := '';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 0
       (listing[i+1] = #9'jsr orAL_CL') and							// jsr orAL_CL				; 1
       dex(i+2) and										// dex					; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'dex';
       listing[i+2] := #9'tya';
       listing[i+3] := #9'ora :STACKORIGIN+1,x';
       listing[i+4] := '';

       exit(false);
     end;


    if (sty(i) = false) and									//~sty					; 0
       (listing[i+1] = #9'jsr orAL_CL') and							// jsr orAL_CL				; 1
       dex(i+2) and										// dex					; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
       listing[i+1] := #9'dex';
       listing[i+2] := #9'dex';
       listing[i+3] := #9'lda :STACKORIGIN+1,x';
       listing[i+4] := #9'ora :STACKORIGIN+2,x';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'jsr orAL_CL') and							// jsr orAL_CL				; 2
       dex(i+3) and										// dex					; 3
       dex(i+4) and										// dex					; 4
       (listing[i+5] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 5
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'dex';
       listing[i+2] := #9'dex';
       listing[i+3] := #9'tya';
       listing[i+4] := #9'ora :STACKORIGIN+1,x';
       listing[i+5] := '';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'jsr orAL_CL') and							// jsr orAL_CL				; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta(i+5) and (ix(i+5) = false) and							// sta					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := #9'lda :STACKORIGIN+1,x';
       listing[i+4] := #9'dex';

       exit(false);
     end;


    if (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       and_ora_eor(i+1) and (and_ora_eor_stack(i+1) = false) and				// and|ora|eor				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i+3] := #9'sta :STACKORIGIN+1,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := #9'lda :STACKORIGIN+1,x';
       listing[i]   := #9'dex';

       exit(false);
     end;


    if (listing[i] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 0
       dex(i+1) and										// dex					; 1
       dex(i+2) and										// dex					; 1
       dex(i+3) and										// dex					; 2
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') and						// lda :STACKORIGIN+1,x			; 3
       (listing[i+5] = #9'and :STACKORIGIN+2,x') then						// and :STACKORIGIN+2,x			; 3
     begin
       listing[i]   := #9'dex';
       listing[i+1] := #9'dex';
       listing[i+2] := #9'dex';
       listing[i+3] := #9'tya';
       listing[i+4] := #9'and :STACKORIGIN+1,x';
       listing[i+5] := '';

       exit(false);
     end;


    if tya(i) and										// tya					; 0
       (listing[i+1] = #9'and :STACKORIGIN,x') and						// and :STACKORIGIN,x			; 1
       sta(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i+3] := listing[i+2];

       listing[i]   := #9'dex';
       listing[i+1] := #9'tya';
       listing[i+2] := #9'and :STACKORIGIN+1,x';

       exit(false);
     end;


    if (listing[i] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 0
       ldy_1(i+1) and										// ldy #1				; 1
       and_ora_eor(i+2) and (pos(' :STACK', listing[i+2]) = 0) and				// and|ora|eor				; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := #9'lda :STACKORIGIN+1,x';

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       (listing[i+5] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := #9'sty :STACKORIGIN+1,x';
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+1,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN+1,x') and						// lda :STACKORIGIN+1,x			; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       (listing[i+5] = #9'sty :STACKORIGIN+1,x') and						// sty :STACKORIGIN+1,x			; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := #9'sty :STACKORIGIN+2,x';
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+2,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       (listing[i+2] = #9'cmp :STACKORIGIN-1,x') and						// cmp :STACKORIGIN-1,x			; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := #9'cmp :STACKORIGIN,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       (listing[i+2] = #9'cmp :STACKORIGIN,x') and						// cmp :STACKORIGIN,x			; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := #9'cmp :STACKORIGIN+1,x';
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       (listing[i+6] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := #9'sty :STACKORIGIN,x';
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       (listing[i+6] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := #9'sty :STACKORIGIN+1,x';
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       (listing[i+6] = #9'sty :STACKORIGIN+1,x') and						// sty :STACKORIGIN+1,x			; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := #9'sty :STACKORIGIN+2,x';
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       (listing[i+6] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := #9'sty :STACKORIGIN+1,x';
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+1,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN+1,x') and						// lda :STACKORIGIN+1,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       (listing[i+6] = #9'sty :STACKORIGIN+1,x') and						// sty :STACKORIGIN+1,x			; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := #9'sty :STACKORIGIN+2,x';
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+2,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda T				; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       (listing[i+5] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := #9'sty :STACKORIGIN,x';
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda T				; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       (listing[i+5] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := #9'sty :STACKORIGIN+1,x';
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda T				; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       (listing[i+5] = #9'sty :STACKORIGIN+1,x') and						// sty :STACKORIGIN+1,x			; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := #9'sty :STACKORIGIN+2,x';
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda A				; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp B				; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       (listing[i+6] = #9'sty :STACKORIGIN-1,x') and						// sty :STACKORIGIN-1,x			; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+6] := #9'dex';
       listing[i+7] := #9'sty :STACKORIGIN,x';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda A				; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp B				; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+1,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+1,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN+1,x') and						// lda :STACKORIGIN+1,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+2,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       (listing[i+2] = #9'cmp :STACKORIGIN,x') and						// cmp :STACKORIGIN,x			; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := #9'cmp :STACKORIGIN+1,x';
       listing[i+2] := #9'lda :STACKORIGIN,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       (listing[i+2] = #9'cmp :STACKORIGIN+1,x') and						// cmp :STACKORIGIN+1,x			; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := #9'cmp :STACKORIGIN+2,x';
       listing[i+2] := #9'lda :STACKORIGIN+1,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       SKIP(i+4) and										// SKIP					; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) and										//@					; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       SKIP(i+4) and										// SKIP					; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) and										//@					; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+1,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       (listing[i+1] = #9'lda :STACKORIGIN+1,x') and						// lda :STACKORIGIN+1,x			; 1
       cmp(i+2) and (cmp_stack(i+2) = false) and						// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       SKIP(i+4) and										// SKIP					; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) and										//@					; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN+2,x';
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if lda(i) and (lda_stack(i) = false) and							// lda					; 0
       ldy_1(i+1) and										// ldy #1				; 1
       and_ora_eor(i+2) and (and_ora_eor_stack(i+2) = false) and				// and|ora|eor				; 2
       cmp(i+3) and (cmp_stack(i+3) = false) and						// cmp					; 3
       SKIP(i+4) and										// SKIP					; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) and										//@					; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if lda(i) and (lda_stack(i) = false) and							// lda					; 0
       ldy_1(i+1) and										// ldy #1				; 1
       and_ora_eor(i+2) and (and_ora_eor_stack(i+2) = false) and				// and|ora|eor				; 2
       cmp(i+3) and (cmp_stack(i+3) = false) and						// cmp					; 3
       SKIP(i+4) and										// SKIP					; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) and										//@					; 6
       (listing[i+7] = #9'sty :STACKORIGIN,x') and						// sty :STACKORIGIN,x			; 7
       dex(i+8) then										// dex					; 8
     begin
       listing[i+8] := #9'sty :STACKORIGIN+1,x';

       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := listing[i];

       listing[i] := #9'dex';

       exit(false);
     end;


    if lab_a(i) and										//@					; 0
       tya(i+1) and										// tya					; 1
       sta_a(i+2) and (iy(i+2) = false) and							// sta					; 2
       dex(i+3) and										// dex					; 3
       lda_a(i+4) then										// lda					; 4
     begin
       listing[i+1] := '';
       listing[i+2] := #9'sty ' + copy(listing[i+2], 6, 256);

       exit(false);
     end;


    if mva(i) and										// mva X :STACKORIGIN			; 0	| label > 0
       mva(i+1) and										// mva X+1 :STACKORIGIN+STACKWIDTH	; 1
       inx(i+2) and										// inx					; 2
       (listing[i+3] = #9'mva #$00 :STACKORIGIN,x') and						// mva #$00 :STACKORIGIN		; 3
       (listing[i+4] = #9'mva #$00 :STACKORIGIN+STACKWIDTH,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH	; 4
       ldy_1(i+5) and										// ldy #1				; 5
       (listing[i+6] = #9'jsr cmpSMALLINT') and							// jsr cmpSMALLINT			; 6
       seq(i+7) and										// seq					; 7
       (listing[i+8] = #9'bpl @+') and								// bpl @+				; 8
       dey(i+9) and										// dey					; 9
       lab_a(i+10) then										//@					; 10
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
     begin
	listing[i+2] := #9'lda ' + GetString(i+1);
	listing[i+3] := #9'bmi @+';
	listing[i+4] := #9'ora ' + GetString(i);
	listing[i+5] := #9'sne';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '@';
	listing[i+9] := #9'dey';
	listing[i+10] := '';

	listing[i]   := #9'inx';
	listing[i+1] := #9'ldy #1';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva .. :STACKORIGIN,x		; 1
       mva(i+2) and										// mva .. :STACKORIGIN+STACKWIDTH,x	; 2
       inx(i+3) and										// inx					; 3
       mva(i+4) and 										// mva .. :STACKORIGIN,x		; 4
       mva(i+5) and										// mva .. :STACKORIGIN+STACKWIDTH,x	; 5
       ldy_1(i+6) and										// ldy #1				; 6
       (listing[i+7] = #9'jsr cmpEAX_ECX.AX_CX') then						// jsr cmpEAX_ECX.AX_CX			; 7
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN,x', listing[i+4]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+5]) > 0) then
     begin
       listing[i] := #9'inx:inx';

       listing[i+2] := #9'lda ' + GetString(i+2);
       listing[i+3] := #9'cmp ' + GetString(i+5);

       listing[i+5] := #9'lda ' + GetString(i+1);
       listing[i+6] := #9'cmp ' + GetString(i+4);
       listing[i+7] := '@';

       listing[i+1] := #9'ldy #1';

       listing[i+4] := #9'bne @+';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'mva #$00 :STACKORIGIN,x') and 					// mva #$00 :STACKORIGIN,x		; 1
       (listing[i+2] = #9'mva #$00 :STACKORIGIN+STACKWIDTH,x') and 				// mav #$00 :STACKORIGIN+STACKWIDTH,x	; 2
       ldy_1(i+3) and										// ldy #1				; 3
       (listing[i+4] = #9'jsr cmpEAX_ECX.AX_CX') and						// jsr cmpEAX_ECX.AX_CX			; 4
       (beq(i+5) or bne(i+5)) and 								// beq|bne @+				; 5
       dey(i+6) and										// dey					; 6
       lab_a(i+7) and					 					//@					; 7
       dex(i+8) and										// dex					; 8
       dex(i+9) and										// dex					; 9
       tya(i+10) and										// tya					; 10
       jeq(i+11) then										// jeq l_				; 11
     begin
       listing[i]   := #9'ldy #1';
       listing[i+1] := #9'lda :STACKORIGIN+STACKWIDTH,x';
       listing[i+2] := #9'ora :STACKORIGIN,x';
       listing[i+3] := '';
       listing[i+4] := '';

       listing[i+8] := '';

       exit(false);
     end;


    if ldy_1(i) and										// ldy #1				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN-1,x			; 1
       cmp_im(i+2) and										// cmp #				; 2
       (listing[i+3] = #9'bcc @+') and								// bcc @+				; 3
       beq(i+4) and										// beq @+				; 4
       dey(i+5) and										// dey					; 5
       lab_a(i+6) then										//@					; 6
     if (pos(':STACKORIGIN-1,x', listing[i+1]) > 0) then
     begin
       p := GetBYTE(i+2);

       if p < 255 then begin
        listing[i+2] := #9'cmp #$' + IntToHex(p+1, 2);

        listing[i+4] := '';

        exit(false);
       end;

     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva aa :STACKORIGIN,x		; 1
       ((listing[i+2] = #9'jsr orAL_CL') or (listing[i+2] = #9'jsr andAL_CL') or		// jsr or|and|xor AL_CL			; 2
        (listing[i+2] = #9'jsr xorAL_CL')) and							// dex					; 3
       dex(i+3) then
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
       listing[i] := #9'lda :STACKORIGIN,x';

       if listing[i+2] = #9'jsr orAL_CL' then listing[i+1] := #9'ora ' + GetString(i+1) else
        if listing[i+2] = #9'jsr andAL_CL' then listing[i+1] := #9'and ' + GetString(i+1) else
         if listing[i+2] = #9'jsr xorAL_CL' then listing[i+1] := #9'eor ' + GetString(i+1);

       listing[i+2] := #9'sta :STACKORIGIN,x';
       listing[i+3] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva a :STACKORIGIN			; 1
       mva(i+2) and (iy(i+2) = false) and							// mva a+1 :STACKORIGIN+STACKWIDTH	; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN			; 3
       (listing[i+4] = #9'ldy :STACKORIGIN+STACKWIDTH,x') then					// ldy :STACKORIGIN+STACKWIDTH		; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
       listing[i+3]  := #9'lda ' + GetString(i+1);
       listing[i+4]  := #9'ldy ' + GetString(i+2);

       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda(i+1) and (iy(i+1) = false) and							// lda IMAGES				; 1
       (listing[i+2] = #9'add #$01') and							// add #$01				; 2
       tay(i+3) then										// tay					; 3
     begin
       listing[i+1] := #9'ldy ' + copy(listing[i+1], 6, 256);
       listing[i+2] := #9'iny';
       listing[i+3] := '';

       exit(false);
     end;


    if ldy(i) and										// ldy I				; 0
       mva(i+1) and										// mva ...				; 1
       inx(i+2) and										// inx					; 2
       ldy(i+3) and (listing[i] = listing[i+3]) then						// ldy I				; 3
     begin
       listing[i+3] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda(i+1) and 										// lda IMAGES				; 1
       add_im_0(i+2) and									// add #$00				; 2
       sta(i+3) and										// sta					; 3
       lda(i+4) and										// lda IMAGES+1				; 4
       adc(i+5) and										// adc 					; 5
       sta(i+6) then										// sta					; 6
     begin
       listing[i+2] := '';

       listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

        exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda_im_0(i+1) and 									// lda #$00				; 1
       add(i+2) and										// add					; 2
       sta(i+3) and										// sta					; 3
       lda(i+4) and										// lda IMAGES+1				; 4
       adc(i+5) and										// adc 					; 5
       sta(i+6) then										// sta					; 6
     begin
       listing[i+1] := '';
       listing[i+2] := #9'lda ' + copy(listing[i+2], 6, 256);

       listing[i+5] := #9'add ' + copy(listing[i+5], 6, 256);

        exit(false);
     end;


    if //inx(i) and										// inx					; 0
       lda(i+1) and 										// lda IMAGES				; 1
       add_im_0(i+2) and									// add #$00				; 2
       sta(i+3) and										// sta					; 3
//       lda(i+4) and										// lda IMAGES+1				; 4
       (adc(i+5) = false) then									//~adc 					; 5
     begin
       listing[i+2] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and 										// mva aa :STACKORIGIN			; 1
       mva(i+2) and										// mva bb|#$00 :STACKORIGIN+STACKWIDTH	; 2
       lda(i+3) and										// lda					; 3
       add_stack(i+4) and									// add :STACKORIGIN			; 4
       tay(i+5) and										// tay					; 5
       lda(i+6) and										// lda					; 6
       adc_stack(i+7) and									// adc :STACKORIGIN+STACKWIDTH		; 7
       sta_bp_1(i+8) and									// sta :bp+1				; 8
       lda_bp_y(i+9) and									// lda (:bp),y				; 9
       sta(i+10) then										// sta					; 10
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin
       listing[i+4]  := #9'add ' + GetString(i+1);
       listing[i+7]  := #9'adc ' + GetString(i+2);

       listing[i+1] := '';
       listing[i+2] := '';

       if adc_im_0(i+7) then
	if copy(listing[i+3], 6, 256)+'+1' = copy(listing[i+6], 6, 256) then begin
	 listing[i+3] := #9'mwy ' + copy(listing[i+3], 6, 256) + ' :bp2';
	 listing[i+4] := #9'ldy ' + copy(listing[i+4], 6, 256);
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda (:bp2),y';
	end;

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva(i+1) and										// mva aa :STACKORIGIN,x		; 1
       mva(i+2) and										// mva bb :STACKORIGIN+STACKWIDTH,x	; 2
       lda(i+3) and										// lda					; 3
       add_stack(i+4) and									// add :STACKORIGIN,x			; 4
       sta(i+5) and										// sta					; 5
       lda(i+6) and										// lda					; 6
       adc_stack(i+7) and									// adc :STACKORIGIN+STACKWIDTH,x	; 7
       sta(i+8) then										// sta					; 8
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN,x', listing[i+4]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+7]) > 0) then
     begin
       listing[i+4]  := #9'add ' + GetString(i+1);
       listing[i+7]  := #9'adc ' + GetString(i+2);

       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if listing[i] = #9'jsr hiWORD' then								// jsr hiWORD				; 0
     begin
       listing[i] := #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x';

       Result:=false;
     end;


    if (listing[i] = #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x') and			// mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x	; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x				; 1
       (listing[i+2] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x				; 2
       sta_adr(i+3) then									// sta adr.					; 3
     begin
       listing[i+2] := #9'lda :STACKORIGIN+STACKWIDTH,x';

       listing[i] := '';

       exit(false);
     end;


    if lda(i) and										// lda						; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and 						// sta :STACKORIGIN,x				; 1
       lda(i+2) and										// lda						; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x		; 3
       (listing[i+4] = #9'mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x') then			// mva :STACKORIGIN+STACKWIDTH,x :STACKORIGIN,x	; 4
     begin
       listing[i] := listing[i+2];

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;



    if lda_a(i) and										// lda					; 0
       add_sub(i+1) and 									// add|sub				; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN			; 2
       lda_a(i+3) and 										// lda					; 3
       adc_sbc(i+4) and 									// adc|sbc				; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH		; 5
       (listing[i+6] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN			; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH		; 8
       sta_a(i+9) and (sta_stack(i+9) = false) then						// sta					; 9
     begin
       listing[i+2] := listing[i+7];

       listing[i+5] := listing[i+9];
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       exit(false);
     end;




    if //dex(i) and										// dex					; 0
       lda_a(i+1) and										// lda					; 1
       (listing[i+2] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 2
       lda_a(i+3) and										// lda					; 3
       (listing[i+4] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 4
       lda_a(i+5) and										// lda					; 5
       (listing[i+6] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 6
       lda_a(i+7) and										// lda					; 7
       (listing[i+8] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 8
       lda_a(i+9) and (lda_stack(i+9) = false) and						// lda					; 9
       sta_a(i+10) and (sta_stack(i+10) = false) and						// sta					; 10
       dex(i+11) and 										// dex					; 11
       (listing[i+12] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 12
       sta_a(i+13) and (sta_stack(i+13) = false) and						// sta					; 13
       dex(i+14) then										// dex					; 14
     begin
       listing[i+12] := listing[i+1];

       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4]:= '';
       listing[i+5]:= '';
       listing[i+6]:= '';
       listing[i+7]:= '';
       listing[i+8]:= '';

       exit(false);
     end;


    if mva(i) and 										// mva ... :STACKORIGIN,x		; 0
       mva(i+1) and 										// mva ... :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and 										// mva ... :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and 										// mva ... :STACKORIGIN+STACKWIDTH*3,x	; 3
       (listing[i+4] = #9'm@index4 0') and							// m@index4 0				; 4
       lda(i+5) and										// lda A				; 5
       add_stack(i+6) and									// add :STACKORIGIN,x			; 6
       sta_bp2(i+7) and										// sta :bp2				; 7
       lda(i+8) and										// lda A+1				; 8
       adc_stack(i+9) and									// adc :STACKORIGIN+STACKWIDTH,x	; 9
       sta_bp2_1(i+10) then									// sta :bp2+1				; 10
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
     	(pos(':STACKORIGIN,x', listing[i+6]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
     	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+9]) > 0) then
     begin

       tmp:=listing[i];

       listing[i]   := #9'mva ' + GetString(i+1) + ' :STACKORIGIN,x';
       listing[i+1] := #9'lda ' + GetString(tmp);
       listing[i+2] := #9'asl @';
       listing[i+3] := #9'rol :STACKORIGIN,x';
       listing[i+4] := #9'asl @';

       tmp:=listing[i+5];

       listing[i+5] := #9'rol :STACKORIGIN,x';
       listing[i+6] := #9'add ' + GetString(tmp);
       listing[i+7] := #9'sta :bp2';

       tmp:=listing[i+8];

       listing[i+8] := #9'lda :STACKORIGIN,x';
       listing[i+9] := #9'adc ' + GetString(tmp);
       listing[i+10]:= #9'sta :bp2+1';

       exit(false);
     end;


    if ldy(i) and										// ldy					; 0
       (listing[i+1] = #9'mva (:bp2),y :STACKORIGIN,x') and					// mva (:bp2),y :STACKORIGIN,x		; 1
       iny(i+2) and 										// iny					; 2
       (listing[i+3] = #9'mva (:bp2),y :STACKORIGIN+STACKWIDTH,x') and				// mva (:bp2),y :STACKORIGIN+STACKWIDTH ; 3
       lda(i+4) and										// lda A				; 4
       (listing[i+5] = #9'add :STACKORIGIN,x') and						// add :STACKORIGIN,x			; 5
       sta(i+6) and										// sta 					; 6
       lda(i+7) and										// lda A+1				; 7
       (listing[i+8] = #9'adc :STACKORIGIN+STACKWIDTH,x') and					// adc :STACKORIGIN+STACKWIDTH,x	; 8
       sta(i+9) then										// sta					; 9
     begin
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := listing[i+4];
       listing[i+4] := #9'add (:bp2),y';
       listing[i+5] := listing[i+6];
       listing[i+6] := #9'iny';

       listing[i+8] := #9'adc (:bp2),y';

       exit(false);
     end;


    if lda_a(i) and										// lda					; 0
       adc_sbc(i+1) and										// adc|sbc				; 1
       (listing[i+2] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 2
       (asl_stack(i+3) or lsr_stack(i+3)) and							// asl|lsr				; 3
       (listing[i+4] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 4
     begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if (listing[i] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 0
       (listing[i+1] = #9'asl :STACKORIGIN,x') and						// asl :STACKORIGIN,x			; 1
       (listing[i+2] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 2
     begin
       listing[i]   := #9'asl @';
       listing[i+1] := #9'tay';
       listing[i+2] := '';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------
// shlEAX

    if mva(i) and 										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       inx(i+2) and 										// inx					; 2
       (listing[i+3] = #9'mva #$10 :STACKORIGIN,x') and 					// mva #$10 :STACKORIGIN,x		; 3
       (listing[i+4] = #9'jsr shlEAX_CL.WORD') then 						// jsr shlEAX_CL.WORD			; 4
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
     	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
     begin

       listing[i+2] := #9'mva ' + GetString(i) + ' :STACKORIGIN+STACKWIDTH*2,x';
       listing[i+3] := #9'mva ' + GetString(i+1) + ' :STACKORIGIN+STACKWIDTH*3,x';
       listing[i+4] := #9'inx';

       listing[i]   := #9'mva #$00 :STACKORIGIN,x';
       listing[i+1] := #9'mva #$00 :STACKORIGIN+STACKWIDTH,x';

       exit(false);
     end;

// ----------------------------------------------------------------------------------------------------------------------------------------
// array

    if inx(i) and										// inx					; 0
       lda(i+1) and										// lda					; 1
       add_sub(i+2) and 									// add|sub				; 2
       (listing[i+3] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 3
       lda(i+4) and										// lda					; 4
       adc_sbc(i+5) and 									// adc|sbc				; 5
       sta(i+6) and										// sta					; 6
       (listing[i+7] = #9'ldy :STACKORIGIN,x') then						// ldy :STACKORIGIN,x			; 7
     begin
       listing[i+3] := #9'tay';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';

       exit(false);
     end;


    if (mva(i) or (listing[i] = #9'sta :STACKORIGIN,x')) and					// mva I :STACKORIGIN,x			; 0
       (listing[i+1] = #9'mva #$00 :STACKORIGIN+STACKWIDTH,x') and				// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 1
       ((listing[i+2] = #9'm@index2 0') or (listing[i+2] = #9'm@index4 0')) and			// m@index2 0|m@index4 0		; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       add_im_0(i+4) and									// add #$00				; 4
       tay(i+5) and										// tay					; 5
       (listing[i+6] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 6
       adc_im_0(i+7) and									// adc #$00				; 7
       (listing[i+8] = #9'sta :STACKORIGIN+STACKWIDTH,x') then					// sta :STACKORIGIN+STACKWIDTH,x	; 8
     begin
       if (listing[i] = #9'sta :STACKORIGIN,x') then
        listing[i] := ''
       else
        listing[i] := #9'lda ' + GetString(i);

       if listing[i+2] = #9'm@index2 0' then begin
        listing[i+1] := #9'asl @';
        listing[i+2] := '';
       end else begin
        listing[i+1] := #9'asl @';
        listing[i+2] := #9'asl @';
       end;

       listing[i+3] := #9'tay';

       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';
       listing[i+7] := '';
       listing[i+8] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and										// mva					; 3
       mva(i+4) and										// mva					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       add_sub(i+6) and (add_sub_stack(i+6) = false) and					// add|sub				; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
       adc_sbc(i+9) and (adc_sbc_stack(i+9) = false) and					// adc|sbc				; 9
       sta_a(i+10) and (sta_stack(i+10) = false) and						// sta					; 10
       dex(i+11) then										// dex					; 11
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;

    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       (listing[i+4] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 4
       adc_sbc(i+5) and (adc_sbc_stack(i+5) = false) and					// adc|sbc				; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+1] := #9'lda :STACKORIGIN,x';

       listing[i+4] := #9'lda :STACKORIGIN+STACKWIDTH,x';

       listing[i]   := '';

       listing[i+7] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       adc_sbc(i+5) and (adc_sbc_stack(i+5) = false) and					// adc|sbc				; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       dex(i+7) then										// dex					; 7
     begin
       listing[i+1] := #9'lda :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+7] := '';

       exit(false);
     end;


    if mva(i) and 										// mva   :STACKORIGIN+STACKWIDTH	; 0
       (listing[i+1] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 1
       add_sub(i+2) and 									// add|sub				; 2
       sta(i+3) and										// sta					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH		; 4
       adc_sbc(i+5) and 									// adc|sbc				; 5
       sta(i+6) then										// sta					; 6
     if (pos(':STACKORIGIN+STACKWIDTH,x', listing[i]) > 0) then
     begin
       listing[i+4] := #9'lda ' + GetString(i);

       listing[i] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and (iy(i+1) = false) and			// lda					; 1
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       (listing[i+3] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN			; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and (iy(i+4) = false) and			// lda					; 4
       adc_sbc(i+5) and (adc_sbc_stack(i+5) = false) and					// adc|sbc				; 5
       (listing[i+6] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH		; 6
       (listing[i+7] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 7
       (listing[i+8] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH		; 10
       sta_a(i+11) and (sta_stack(i+11) = false) and						// sta					; 11
       (lda(i+12) = false) then									// ~lda					; 12
     begin
       listing[i+3] := listing[i+9];

       listing[i+6] := listing[i+11];

       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := listing[i+4];
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];

       if dex(i+12) then begin
        listing[i+1] := #9'ldy :STACKORIGIN,x';
	listing[i]   := '';

	listing[i+12] := '';
       end else
        listing[i+1] := #9'ldy :STACKORIGIN-1,x';

       listing[i+8]  := '';
       listing[i+9]  := '';
       listing[i+10] := '';
       listing[i+11] := '';

       exit(false);
     end;


    if mva(i) and										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 3
       inx(i+4) and										// inx					; 4
       lda(i+5) and (lda_stack(i+5) = false) and						// lda					; 5
       add_sub(i+6) and (add_sub_stack(i+6) = false) and					// add|sub				; 6
       sta(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       lda(i+8) and										// lda					; 8
       adc_sbc(i+9) and 									// adc|sbc				; 9
       sta(i+10) and										// sta					; 10
       lda(i+11) and										// lda					; 11
       adc_sbc(i+12) and 									// adc|sbc				; 12
       sta(i+13) and										// sta					; 13
       lda(i+14) and										// lda					; 14
       adc_sbc(i+15) and 									// adc|sbc				; 15
       sta(i+16) and										// sta					; 16
       (listing[i+17] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 17
       sta(i+18) and										// sta A				; 18
       (listing[i+19] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and				// lda :STACKORIGIN-1+STACKWIDTH,x	; 19
       sta(i+20) and										// sta A+1				; 20
       (listing[i+21] = #9'lda :STACKORIGIN-1+STACKWIDTH*2,x') and				// lda :STACKORIGIN-1+STACKWIDTH*2,x	; 21
       sta(i+22) and										// sta A+2				; 22
       (listing[i+23] = #9'lda :STACKORIGIN-1+STACKWIDTH*3,x') and				// lda :STACKORIGIN-1+STACKWIDTH*3,x	; 23
       sta(i+24) then										// sta A+3				; 24
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) then
     begin

	listing[i+17] := #9'lda ' + GetString(i);

	listing[i+19] := #9'lda ' + GetString(i+1);

	listing[i+21] := #9'lda ' + GetString(i+2);

	listing[i+23] := #9'lda ' + GetString(i+3);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       lda_a(i+4) and										// lda A+2				; 4
       (listing[i+5] = #9'sta :STACKORIGIN-1+STACKWIDTH*2,x') and				// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 5
       lda_a(i+6) and										// lda A+3				; 6
       (listing[i+7] = #9'sta :STACKORIGIN-1+STACKWIDTH*3,x') and				// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 7
       dex(i+8) and										// dex					; 8
       (listing[i+9] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 9
       sta(i+10) and										// sta B				; 10
       (listing[i+11] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 11
       sta(i+12) and										// sta B+1				; 12
       (listing[i+13] = #9'lda :STACKORIGIN+STACKWIDTH*2,x') and				// lda :STACKORIGIN+STACKWIDTH*2,x	; 13
       sta(i+14) and										// sta B+2				; 14
       (listing[i+15] = #9'lda :STACKORIGIN+STACKWIDTH*3,x') and				// lda :STACKORIGIN+STACKWIDTH*3,x	; 15
       sta(i+16) then										// sta B+3				; 16
     begin

	listing[i+9]  := listing[i];

	listing[i+11] := listing[i+2];

	listing[i+13] := listing[i+4];

	listing[i+15] := listing[i+6];

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


    if lda_a(i) and (lda_stack(i) = false) and							// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_a(i+2) and										// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       dex(i+4) and										// dex					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       sta(i+6) and										// sta B				; 6
       (listing[i+7] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 7
       sta(i+8) then										// sta B+1				; 8
     begin

	listing[i+5] := listing[i];

	listing[i+7] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda A				; 0
       (listing[i+1] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda A+1				; 2
       (listing[i+3] = #9'sta :STACKORIGIN+STACKWIDTH,x') and					// sta :STACKORIGIN+STACKWIDTH,x	; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda A+2				; 4
       (listing[i+5] = #9'sta :STACKORIGIN+STACKWIDTH*2,x') and					// sta :STACKORIGIN+STACKWIDTH*2,x	; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda A+3				; 6
       (listing[i+7] = #9'sta :STACKORIGIN+STACKWIDTH*3,x') and					// sta :STACKORIGIN+STACKWIDTH*3,x	; 7
       (listing[i+8] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 8
       sta(i+9) and (sta_stack(i+9) = false) and						// sta B				; 9
       (listing[i+10] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta(i+11) and (sta_stack(i+11) = false) and						// sta B+1				; 11
       dex(i+12) then										// dex					; 12
     begin
	listing[i+1] := listing[i+9];

	listing[i+3] := listing[i+11];
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

       exit(false);
     end;


// ----------------------------------------------------------------------------------------------------------------------------------------
// expand


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and										// mva   :STACKORIGIN-1+STACKWIDTH	; 2
       mva(i+3) and 										// mva   :STACKORIGIN-1+STACKWIDTH*2	; 3
       mva(i+4) then 										// mva   :STACKORIGIN-1+STACKWIDTH*3	; 4
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH*2,x', listing[i+3]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH*3,x', listing[i+4]) > 0) then
      begin

	listing_tmp[0] := #9'mva ' + GetString(i+2) + ' :STACKORIGIN+STACKWIDTH,x';
	listing_tmp[1] := #9'mva ' + GetString(i+3) + ' :STACKORIGIN+STACKWIDTH*2,x';
	listing_tmp[2] := #9'mva ' + GetString(i+4) + ' :STACKORIGIN+STACKWIDTH*3,x';
	listing_tmp[3] := #9'inx';
	listing_tmp[4] := listing[i+1];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];

	exit(false);
      end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN-1+STACKWIDTH	; 2
       mva(i+3) then 										// mva   :STACKORIGIN+STACKWIDTH	; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
	(pos(':STACKORIGIN-1+STACKWIDTH,x', listing[i+2]) > 0) and
	(pos(':STACKORIGIN+STACKWIDTH,x', listing[i+3]) > 0) then
      begin

	listing_tmp[0] := #9'mva ' + GetString(i+2) + ' :STACKORIGIN+STACKWIDTH,x';
	listing_tmp[1] := #9'inx';
	listing_tmp[2] := listing[i+1];
	listing_tmp[3] := listing[i+3];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];

	exit(false);
      end;



// ----------------------------------------------------------------------------------------------------------------------------------------


    if mva(i) and (pos(' :STACK', listing[i]) > 0) and						// mva YY+3 :STACKORIGIN+STACKWIDTH*3,x	; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH*3,x	; 1
       and_ora_eor(i+2) and									// and|ora|eor				; 2
       sta_stack(i+3) then									// sta :STACKORIGIN+STACKWIDTH*3,x	; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
	(pos(copy(listing[i+1], 6, 256), listing[i]) > 0) then
      begin
	listing[i]   := #9'lda ' + GetString(i);
	listing[i+1] := '';

	exit(false);
      end;


    if mva(i) and 										// mva YY :STACKORIGIN,x		; 0
       mva(i+1) and										// mva YY+1 :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'jsr hiWORD') then							// jsr hiWORD				; 2
     if (pos(' :STACKORIGIN,x', listing[i]) > 0) and
        (pos(' :STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) then
      begin
	listing[i]   := #9'mva ' + copy(listing[i+1], 6, pos(':STACK', listing[i+1])-6) + ':STACKORIGIN,x';

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if (listing[i] = #9'jsr notBOOLEAN') and							// jsr notBOOLEAN			; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'lda :STACKORIGIN+1,x') and						// lda :STACKORIGIN+1,x			; 2
       jeq(i+3) then										// jeq					; 3
      begin
	listing[i] := '';

	listing[i+3] := #9'jne ' + copy(listing[i+3], 6, 256);

	exit(false);
      end;


    if lda(i) and (listing[i] = listing[i+5]) and						// lda I				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       mva(i+3) and										// mva xxxx :STACKORIGIN,x		; 3
       inx(i+4) and										// inx					; 4
       lda(i+5) and										// lda I				; 5
       asl_a(i+6) and										// asl @				; 6
       tay(i+7) then										// tay					; 7
      begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
      end;


    if lda(i) and (listing[i] = listing[i+6]) and						// lda I				; 0
       asl_a(i+1) and										// asl @				; 1
       tay(i+2) and										// tay					; 2
       lda(i+3) and										// lda					; 3
       sta(i+4) and										// sta					; 4
       inx(i+5) and										// inx					; 5
       lda(i+6) and										// lda I				; 6
       asl_a(i+7) and										// asl @				; 7
       tay(i+8) then										// tay					; 8
      begin
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


    if bne(i) and										// bne *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jeq ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if beq(i) and										// beq *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jne ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if bcc(i) and										// bcc *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jcs ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if bcs(i) and										// bcs *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jcc ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if bpl(i) and										// bpl *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jmi ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if bmi(i) and										// bmi *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jpl ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if jcc(i) and										// jcc l_00C5w		; 0
       lab_a(i+1) and										//@			; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = copy(listing[i], 6, 256)) then						//l_00C5w		; 3
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+2], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if jcs(i) and										// jcs l_00C5w		; 0
       lab_a(i+1) and										//@			; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = copy(listing[i], 6, 256)) then						//l_00C5w		; 3
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+2], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if jne(i) and										// jne l_00C5w		; 0
       lab_a(i+1) and										//@			; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = copy(listing[i], 6, 256)) then						//l_00C5w		; 3
     begin
       listing[i]   := #9'jeq ' + copy(listing[i+2], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if jeq(i) and										// jeq l_00C5w		; 0
       lab_a(i+1) and										//@			; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       (listing[i+3] = copy(listing[i], 6, 256)) then						//l_00C5w		; 3
     begin
       listing[i]   := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


// -----------------------------------------------------------------------------
// ===		 	    ABSOLUTE BP. :STACK
// -----------------------------------------------------------------------------

     if (mva(i) = false) and									// inx					; 0
        mva(i+1) and										// mva N :STACKORIGIN,x			; 1
	mva(i+2) and										// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 2
	((pos('+', listing[i+3]) = 1) or (pos('-', listing[i+3]) = 1)) then			//+-S					; 3
      begin
       tmp := listing[i+3];

       listing[i+3] := listing[i+2];
       listing[i+2] := listing[i+1];
       listing[i+1] := tmp;

       exit(false);
      end;


    if (pos('+', listing[i]) = 1) or (pos('-', listing[i]) = 1) then begin

     tmp:=copy(listing[i], 2, 256);

     yes:=false;

     for p:=i+1 to l-1 do
      if mwy_bp2(p) and (listing[p] = #9'mwy '+tmp+' :bp2') then listing[p] := '' else
       if pos('(:bp2),y', listing[p]) > 0 then begin

        if pos('mva (:bp2),y', listing[p]) > 0 then
         listing[p] := copy(listing[p], 1, 5) + '('+tmp+'),y' + copy(listing[p], 14, 256)
	else
         listing[p] := copy(listing[p], 1, 5) + '('+tmp+'),y';

	yes:=true;
       end else
        if ((pos('+', listing[p]) = 1) or (pos('-', listing[p]) = 1)) then begin

	  if length(listing[p]) = 1 then listing[p] := '';

	  Break;

	end;

     if yes then begin
      listing[i] := '';

      exit(false);
     end;

    end;


// -----------------------------------------------------------------------------


     if mva(i) and										// mva   :STACKORIGIN,x			; 0
        mva(i+1) and										// mva   :STACKORIGIN+STACKWIDTH,x	; 1
	mva(i+2) and										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 2
	mva(i+3) and										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 3
	(listing[i+4] = #9'jsr @expandToREAL') then
     if (pos(':STACKORIGIN,x', listing[i]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0) then
      begin
       listing_tmp[0] := #9'mva ' + GetSTRING(i+2) + ' :STACKORIGIN+STACKWIDTH*3,x';
       listing_tmp[1] := #9'mva ' + GetSTRING(i+1) + ' :STACKORIGIN+STACKWIDTH*2,x';
       listing_tmp[2] := #9'mva ' + GetSTRING(i) + ' :STACKORIGIN+STACKWIDTH,x';
       listing_tmp[3] := #9'mva #$00 :STACKORIGIN,x';

       listing[i]  := listing_tmp[3];
       listing[i+1]:= listing_tmp[2];
       listing[i+2]:= listing_tmp[1];
       listing[i+3]:= listing_tmp[0];
       listing[i+4]:= '';

       exit(false);
      end;

end;		// function