
function opt_STA_BP(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      STA (:BP),y
// -----------------------------------------------------------------------------

    if sta_bp_y(i+8) and								// sta (:bp),y				; 8

       lda(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       ldy_stack(i+6) and								// ldy :STACKORIGIN+9			; 6
       lda_stack(i+7) then								// lda :STACKORIGIN+10			; 7
//       sta_bp_y(i+8) then								// sta (:bp),y				; 8
     if argMatch(i+2, i+7) and
	(argMatch(i+2, i+6) = false) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if sta_bp_y(i+10) and								// sta (:bp),y				; 10

       lda(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       ldy_stack(i+6) and								// ldy :STACKORIGIN+STACKWIDTH+9	; 6
       sty_bp_1(i+7) and								// sty :bp+1				; 7
       ldy_stack(i+8) and								// ldy :STACKORIGIN+9			; 8
       lda_stack(i+9) then								// lda :STACKORIGIN+10			; 9
//       sta_bp_y(i+10) then								// sta (:bp),y				; 10
     if argMatch(i+2, i+9) and
	(argMatch(i+2, i+8) = false) then
       begin
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if ldy_stack(i+13) and								// ldy :STACKORIGIN+9			; 13

       lda(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_bp_1(i+5) and								// sta :bp+1				; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       add(i+7) and									// add					; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+9			; 8
       scc(i+9) and									// scc					; 9
       inc_bp_1(i+10) and								// inc :bp+1				; 10
       lda(i+11) and									// lda					; 11
       (add_sub(i+12) or and_ora_eor(i+12)) then					// add|sub|and|ora|eor			; 12
//       ldy_stack(i+13) then								// ldy :STACKORIGIN+9			; 13
     if argMatch(i+2, i+6) and
	argMatch(i+6, i+8) and
	argMatch(i+8, i+13) then
       begin
	listing[i+2] := #9'tay';

	listing[i+6] := #9'tya';
	listing[i+8] := #9'tay';

	listing[i+13] := '';

	exit(false);
       end;


    if mvy_im(i) and bp_1(i) and							// mvy #   :bp+1			; 0
       ldy_im(i+1) and 									// ldy #				; 1
       lda_a(i+2) and									// lda					; 2
       sta_bp_y(i+3) then 								// sta (:bp),y				; 3
      begin
	p := GetWORD(i+1, i);

	listing[i+3] := #9'sta ' + HexWord(Word(p));

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if mvy_im(i) and bp_1(i) and							// mvy #   :bp+1			; 0
       ldy(i+1) and (ldy_im(i+1) = false) and						// ldy					; 1
       lda_a(i+2) and									// lda					; 2
       sta_bp_y(i+3) then 								// sta (:bp),y				; 3
      begin
        p:=GetBYTE(i);

	listing[i+3] := #9'sta ' + HexByte(Word(p)) + '00,y';

	listing[i] := '';

	exit(false);
      end;


    if ldy_im(i) and									// ldy #				; 0
       sty_bp_1(i+1) and								// sty :bp+1				; 1
       ldy_im(i+2) and 									// ldy #				; 2
       lda_a(i+3) and									// lda					; 3
       sta_bp_y(i+4) then 								// sta (:bp),y				; 4
      begin
	p := GetWORD(i+2, i);

	listing[i+4] := #9'sta ' + HexWord(Word(p));

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if ldy_im(i) and									// ldy #				; 0
       sty_bp_1(i+1) and								// sty :bp+1				; 1
       ldy_im(i+2) and 									// ldy #				; 2
       sta_bp_y(i+3) then 								// sta (:bp),y				; 3
      begin
	p := GetWORD(i+2, i);

	listing[i+3] := #9'sta ' + HexWord(Word(p));

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if ldy_im(i) and									// ldy #				; 0
       sty_bp_1(i+1) and								// sty :bp+1				; 1
       ldy(i+2) and (ldy_im(i+2) = false) and						// ldy 					; 2
       lda_a(i+3) and									// lda					; 3
       sta_bp_y(i+4) then 								// sta (:bp),y				; 4
      begin
        p:=GetBYTE(i);

	listing[i] := '';
	listing[i+1] := '';

	if (p = 0) and (ldy_stack(i+2) = false) then begin
	 listing[i+4] := #9'sta ' + copy(listing[i+2], 6, 256);

	 listing[i+2] := '';
	end else
	 listing[i+4] := #9'sta ' + HexByte(Byte(p)) + '00,y';

	exit(false);
      end;


    if ldy_im(i) and									// ldy #				; 0
       sty_bp_1(i+1) and								// sty :bp+1				; 1
       ldy(i+2) and (ldy_im(i+2) = false) and						// ldy					; 2
       sta_bp_y(i+3) then 								// sta (:bp),y				; 3
      begin
        p:=GetBYTE(i);

	if (p = 0) and (ldy_stack(i+2) = false) then begin
	 listing[i+3] := #9'sta ' + copy(listing[i+2], 6, 256);

	 listing[i+2] := '';
	end else
 	 listing[i+3] := #9'sta ' + HexByte(Byte(p)) + '00,y';

	listing[i] := '';
	listing[i+1] := '';

	exit(false);
      end;


    if sta_bp_y(i+8) and 								// sta (:bp),y				; 8

       lda(i) and									// lda 					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_im(i+2) and									// lda #				; 2
       sta_bp_1(i+3) and								// sta :bp+1				; 3
       ldy(i+4) and (ldy_im(i+4) = false) and						// ldy					; 4
       lda_a(i+5) and									// lda					; 5
       and_ora_eor(i+6) and								// and|ora|eor				; 6
       ldy_stack(i+7) then								// ldy :STACKORIGIN			; 7
//       sta_bp_y(i+8) then 								// sta (:bp),y				; 8
     if argMatch(i+1, i+7) then
      begin
        p:=GetBYTE(i+2);

	listing[i+7] := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+8] := #9'sta ' + HexByte(Byte(p)) + '00,y';

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_bp_y(i+7) and 								// sta (:bp),y				; 7

       lda(i) and									// lda 					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_im(i+2) and									// lda #				; 2
       sta_bp_1(i+3) and								// sta :bp+1				; 3
       ldy(i+4) and (ldy_im(i+4) = false) and						// ldy					; 4
       lda_a(i+5) and									// lda					; 5
       ldy_stack(i+6) then								// ldy :STACKORIGIN			; 6
//       sta_bp_y(i+7) then 								// sta (:bp),y				; 7
     if argMatch(i+1, i+6) then
      begin
        p:=GetBYTE(i+2);

	listing[i+6] := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+7] := #9'sta ' + HexByte(Byte(p)) + '00,y';

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_bp_y(i+5) and 								// lda (:bp),y				; 5

       lda(i) and									// lda 					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       ldy_im(i+2) and									// ldy #				; 2
       sty_bp_1(i+3) and								// sty :bp+1				; 3
       ldy_stack(i+4) then								// ldy :STACKORIGIN			; 4
//       lda_bp_y(i+5) then 								// lda (:bp),y				; 5
     if argMatch(i+1, i+4) then
      begin
        p:=GetBYTE(i+2);

	listing[i+4] := #9'ldy ' + copy(listing[i], 6, 256);
	listing[i+5] := #9'lda ' + HexByte(Byte(p)) + '00,y';

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_bp_y(i+6) and 								// sta (:bp),y				; 6

       add_im(i) and									// add #				; 0
       tay(i+1) and									// tay					; 1
       lda_im(i+2) and									// lda #				; 2
       adc_im_0(i+3) and								// adc #$00				; 3
       sta_bp_1(i+4) and								// sta :bp+1				; 4
       lda_a(i+5) and (iy(i+5) = false) then						// lda					; 5
//       sta_bp_y(i+6) then 								// sta (:bp),y				; 6
      begin
        p:=GetWORD(i, i+2);

	listing[i]   := #9'tay';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	listing[i+6] := #9'sta ' + HexWord(Word(p)) + ',y';

	exit(false);
      end;

end;		// function
