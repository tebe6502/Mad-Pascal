
function opt_LDA(i: integer): Boolean;
var tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===		     		      LDA.
// -----------------------------------------------------------------------------


    if lda_im(i) and										// lda #				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       iny(i+2) then										// iny					; 2
      begin
	listing[i+2] := listing[i+1];
	listing[i+1] := listing[i];
	listing[i]   := #9'iny';
//	exit(false);
      end;


    if ldy(i) and 										// ldy I				; 0
       lda_a(i+1) and										// lda I				; 1
       sta_a(i+2) and										// sta					; 2
       sty(i+3) and										// sty					; 3
       sty(i+4) and										// sty					; 4
       sty(i+5) then										// sty					; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
      begin
	listing[i] := '';

	listing[i+3] := #9'sta ' + copy(listing[i+3], 6, 256);
	listing[i+4] := #9'sta ' + copy(listing[i+4], 6, 256);
	listing[i+5] := #9'sta ' + copy(listing[i+5], 6, 256);

	exit(false);
      end;


    if sty_stack(i) and 									// sty :STACKORIGIN+10			; 0
       lda(i+1) and										// lda					; 1
       AND_ORA_EOR_STACK(i+2) then								// and|ora|eor :STACKORIGIN+10		; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
      begin
	listing[i]   := #9'tya';
	listing[i+1] := copy(listing[i+2], 1, 5) + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
      end;


    if (lab_a(i) or dey(i)) and									//@|dey					; 0
       sty_stack(i+1) and 									// sty :STACKORIGIN+10			; 1
       lda_stack(i+2) then									// lda :STACKORIGIN+10			; 2
     if copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256) then begin
	listing[i+1]   := #9'tya';
	listing[i+2] := '';

	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN+10			; 0
       (sty(i+1) or iny(i+1) or dey(i+1) or ldy(i+1)) and (ldy_1(i+1) = false) and		// sty|iny|dey|ldy			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+10			; 2
       (SKIP(i+3) = false) and (cmp(i+3) = false) then						//~cmp					; 3
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
      begin
	listing[i]   := '';

	listing[i+2] := '';

	exit(false);
      end;


    if sty_stack(i) and										// sty :STACKORIGIN+10			; 0
       sta(i+1) and										// sta					; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+10			; 2
       sta_a(i+3) and (iy(i+3) = false) and							// sta					; 3
       lda_a(i+4) then										// lda					; 4
    if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
	listing[i] := #9'sty ' + copy(listing[i+3], 6, 256);

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if sty_stack(i) and										// sty :STACKORIGIN			; 0
       sty_stack(i+1) then									// sty :STACKORIGIN			; 1
    if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if ldy(i) and										// ldy					; 0
       lda_a(i+1) and										// lda					; 1
       sty(i+2) and										// sty					; 2
       sta_a(i+3) then										// sta					; 3
     begin
        tmp := listing[i+1];

	listing[i+1] := listing[i+2];
	listing[i+2] := tmp;
	exit(false);
     end;


    if ldy_im(i) and										// ldy #				; 0
       lda_im(i+1) and										// lda #				; 1
       sty(i+2) and										// sty					; 2
       sta(i+3) then										// sta					; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
      begin
	listing[i+1] := '';
	listing[i+3] := #9'sty '+copy(listing[i+3], 6, 256);

	exit(false);
      end;


    if ldy_im(i) and										// ldy #				; 0
       lda_im(i+1) and										// lda #				; 1
       sty_stack(i+2) and									// sty :STACKORIGIN			; 2
       sta_val(i+3) and										// sta					; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_val(i+5) then									// sta					; 5
     if (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+4] := #9'lda ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+2] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       ldy(i+1) and										// ldy					; 1
       sty(i+2) and										// sty					; 2
       ldy(i+3) and										// ldy					; 3
       lda_stack(i+4) then									// lda :STACKORIGIN			; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+4] := '';

	exit(false);
       end;


    if (listing[i] = listing[i+3]) and								// lda I				; 0
       (and_ora_eor(i+1) or lsr_a(i+1) or asl_a(i+1)) and					// asl @|lsr @|and|ora|eor		; 1
       (listing[i+1] = listing[i+4]) and							// sta					; 2
												// lda I				; 3
												// asl @|lsr @|and|ora|eor		; 4
       sta(i+2) and										// sta					; 5
       sta(i+5) then
     begin
     	listing[i+3] := '';
	listing[i+4] := '';
	exit(false);
     end;


    if (lda_a(i) or adc_sbc(i)) and								// lda|adc|sbc				; 0
       mwy(i+1) and										// mwy					; 1
       ldy(i+2) and										// ldy					; 2
       lda_a(i+3) then										// lda					; 3
     begin
       listing[i] := '';
       exit(false);
     end;


    if lda_im_0(i) and										// lda #$00				; 0
       (sta_a(i+1) or ldy(i+1)) and								// sta|ldy				; 1
       mva_im_0(i+2) then									// mva #$00				; 2
     begin
	listing[i+2] := #9'sta ' + copy(listing[i+2], 11, 256);
	exit(false);
     end;



    if lda_val(i) and										// lda 					; 0	~:STACKORIGIN
       asl_stack(i+1) and									// asl :STACKORIGIN			; 1
       ldy_val(i+2) and										// ldy					; 2	~:STACKORIGIN
       lda_val(i+3) then									// lda					; 3	~:STACKORIGIN
      begin
	listing[i] := '';

	exit(false);
      end;


    if (lda_im(i) = false) and (lda_im(i+2) = false) and
       lda(i) and										// lda TEMP				; 0	~lda adr. !!!
       sta_a(i+1) and										// sta					; 1
       lda(i+2) then										// lda TEMP				; 2	~lda adr. !!!
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then begin
	listing[i+2] := '';
	exit(false);
     end;


    if lda_im(i) and										// lda #				; 0
       sta_a(i+1) and										// sta					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       sta_a(i+3) and										// sta					; 3
       lda_stack(i+4) then									// lda :STACKORIGIN+10			; 4
     if (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+4] := listing[i];

	listing[i+2] := '';

	exit(false);
      end;


    if lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       ldy_val(i+3) and										// ldy					; 3	~:STACKORIGIN
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_a(i+5) and										// sta					; 5
//       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       sta_a(i+7) then										// sta					; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i+4] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if lda_stack(i+5) and									// lda :STACKORIGIN			; 5

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_val(i+2) and										// ldy					; 2	~:STACKORIGIN
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_a(i+4) then										// sta					; 4
//       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
     if (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+5] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH+9		; 7

       lda_stack(i) and										// lda :STACKORIGIN+STACKWIDTH+10		; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+STACKWIDTH*2+10		; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+10		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+9				; 4
       AND_ORA_EOR_STACK(i+5) and		 						// and|ora|eor :STACKORIGIN+10			; 5
       sta_val(i+6) and										// sta						; 6	~:STACKORIGN
//       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH+9		; 7
       AND_ORA_EOR_STACK(i+8) and								// and|ora|eor :STACKORIGIN+STACKWIDTH+10	; 8
       sta_val(i+9) then									// sta						; 9	~:STACKORIGN
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+7], 6, 256)) and
        (copy(listing[i+2], 6, 256) <> copy(listing[i+4], 6, 256)) and
        (copy(listing[i+2], 6, 256) <> copy(listing[i+7], 6, 256)) then
      begin
	listing[i+5] := copy(listing[i+5], 1, 5) + copy(listing[i], 6, 256);

	listing[i+8] := copy(listing[i+8], 1, 5) + copy(listing[i+2], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_val(i+7) and										// lda					; 7	~:STACKORIGIN

       lda(i) and 										// lda					; 0	~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and 										// lda					; 2	~lda adr.
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       AND_ORA_EOR_STACK(i+5) and		 						// and|ora|eor :STACKORIGIN		; 5
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
//       lda_val(i+7) and									// lda					; 7	~:STACKORIGIN
       AND_ORA_EOR_STACK(i+8) and								// and|ora|eor :STACKORIGIN+STACKWIDTH	; 8
       sta_val(i+9) then									// sta					; 9	~:STACKORIGIN
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
	listing[i+5] := copy(listing[i+5], 1, 5) + copy(listing[i], 6, 256);

	listing[i+8] := copy(listing[i+8], 1, 5) + copy(listing[i+2], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH		; 6

       lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_a(i+2) and										// lda					; 2
       and_ora_eor(i+3) and (AND_ORA_EOR_STACK(i+3) = false) and				// and|ora|eor				; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       lda_val(i+5) then									// lda					; 5	~:STACKORIGIN
//       sta_stack(i+6) then									// sta :STACKORIGIN+STACKWIDTH		; 6
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i+1], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if (lda_a(i) = false) and									//~lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and (lda_stack(i+2) = false) and						// lda					; 2	~lda adr.
       AND_ORA_EOR_STACK(i+3) and								// and|ora|eor :STACKORIGIN+10		; 3
       sta_a(i+4) then										// sta					; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
      begin
	listing[i+2] := copy(listing[i+3], 1, 5) + copy(listing[i+2], 6, 256);

	listing[i+1]   := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda(i) and										// lda					; 0	~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda(i+2) and (iy(i+2) = false) and							// lda					; 2
       and_ora_eor(i+3) and (iy(i+3) = false) and						// and|ora|eor				; 3
       AND_ORA_EOR_STACK(i+4) then								// and|ora|eor :STACKORIGIN		; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i+4] := copy(listing[i+4], 1, 5) + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if lda(i) and iy(i) and									// lda .. ,y				; 0	~lda adr.
       and_ora_eor(i+1) and									// and|ora|eor B			; 1
       sta_a(i+2) then										// sta B				; 2
     if (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
      begin
	listing[i+1] := copy(listing[i+1], 1, 5) + copy(listing[i], 6, 256);
	listing[i]   := #9'lda ' + copy(listing[i+2], 6, 256);

	exit(false);
      end;


{
    if (i > 0) and
       (ldy(i-1) = false) and (tay(i-1) = false) and						// sta :STACKORIGIN+9			; 0
       sta(i) and										// clc|sec				; 1
       lda(i+2) and 										// lda :STACKORIGIN+9			; 2
       ((listing[i+1] = #9'clc') or (listing[i+1] = #9'sec')) then
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then
      begin
	listing[i]   := '';
	listing[i+2] := '';
	exit(false);
      end;
}


    if ldy_val(i+5) and										// ldy					; 5	~:STACKORIGIN

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and (iy(i+2) = false) and							// lda					; 2	~:STACKORIGIN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       mwy_bp2(i+4) and										// mwy					; 4
//       ldy_val(i+5) and									// ldy					; 5	~:STACKORIGIN
       lda_stack(i+6) then									// lda :STACKORIGIN			; 6
     if copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256) then
      begin
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if LDA_BP2_Y(i) and										// lda (:bp2),y				; 0
       iny(i+1) and										// iny					; 1
       LDA_BP2_Y(i+2) then									// lda (:bp2),y				; 2
      begin
	listing[i] := '';
	exit(false);
      end;


    if LDA_BP2_Y(i) and										// iny					; -1
       lda_a(i+1) then										// lda (:bp2),y				; 0
     begin											// lda					; 1

      listing[i] := '';
      if (i>0) and iny(i-1) then listing[i-1] := '';

      exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and								// lda					; 0
       mwy_bp2(i+1) and										// mwy  				; 1
       (lda_a(i+2) or mva(i+2) or mwa(i+2)) then						// lda|mva|mwa				; 2
     begin
      listing[i] := '';
      exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and								// lda					; 0
       (lda_a(i+1) or mva(i+1) or mwa(i+1)) then						// lda|mva|mwa				; 1
     begin
      listing[i] := '';
      exit(false);
     end;


    if lda_a(i) and iy(i) and									// lda  ,y				; 0
       lda_a(i+1) and (iy(i+1) = false) then							// lda					; 1
     begin
      listing[i] := '';
      exit(false);
     end;


    if lda_a(i) and iy(i) and									// lda  ,y				; 0
       lda_a(i+1) and iy(i+1) then								// lda  ,y				; 1
     begin
      listing[i] := '';
      exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
       sta_stack(i+2) then									// sta :STACKORIGIN			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_stack(i+2) then									// lda :STACKORIGIN			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if lda_val(i) and										// lda					; 0	~lda :STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN			; 2
       (add_im_0(i+3) = false) then								//~add #$00
     if copy(listing[i+1], 6, 256) = copy(listing[i+2], 6, 256) then
     begin
       listing[i+2] := '';

       if (asl(i+3) = false) and (lsr(i+3) = false) then listing[i+1] := '';					// !!!

       exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
       (add_im_0(i+2) = false) and (cmp(i+2) = false) then					//~add #$00|~cmp			; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin
       listing[i+1] := '';

       if (asl(i+2) = false) and (lsr(i+2) = false) and (SKIP(i+2) = false) then listing[i] := '';		// !!!

       exit(false);
     end;


    if and_ora_eor(i) and									// and|ora|eor				; 0	!!! ~asl @|rol@
       (lda_a(i+1) or mva(i+1) or mwa(i+1)) then						// lda|mva|mwa				; 1
     begin
      listing[i] := '';

      exit(false);
     end;


    if lda_a(i) and										// lda					; 0
       (SKIP(i+1) = false) and (tay(i+1) = false) and (sta(i+1) = false) and			//~sta|tay|SKIP				; 1
       mwa(i+2) then 										// mwa					; 2
     begin
      listing[i]   := '';
      listing[i+1] := '';

      exit(false);
     end;


    if ldy(i+5) and										// ldy					; 5

       mwy_bp2(i) and										// mwy LEVEL :bp2			; 0
       ldy(i+1) and										// ldy					; 1
       lda(i+2) and										// lda (:bp2),y				; 2
       SKIP(i+3) and										// SKIP					; 3
       mwy(i+4) and										// mwy LEVEL :bp2			; 4
//       ldy(i+5) and										// ldy					; 5
       lda(i+6) then										// lda (:bp2),y				; 6
    if listing[i] = listing[i+4] then
     begin
      listing[i+4] := '';

      if listing[i+1] = listing[i+5] then listing[i+5] := '';
//      if listing[i+2] = listing[i+6] then listing[i+6] := '';							// issue #127 fixed

      exit(false);
     end;


    if (listing[i] = #9'lsr #$00') and								// lsr #$00
       (listing[i+1] = #9'ror @')  then								// ror @
     begin
	listing[i]   := #9'lsr @';
	listing[i+1] := '';
	exit(false);
     end;


    if (listing[i] = #9'lsr #$00') and								// lsr #$00
       ror_stack(i+1) then									// ror :STACKORIGIN
     begin
	listing[i]   := '';
	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);
	exit(false);
     end;


    if bne(i) and										// bne @+
       bne(i+1) then begin									// bne @+
	listing[i]   := '';
	listing[i+1] := '';
	exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and								// lda #$00		; 0
       STA_BP2_Y(i+1) and 									// sta (:bp2),y		; 1
       iny(i+2) and										// iny			; 2 5 8
       lda_a(i+3) and (iy(i+3) = false) and							// lda #$00		; 3 6 9
       STA_BP2_Y(i+4) then									// sta (:bp2),y 	; 4 7 10
      if listing[i] = listing[i+3] then begin

	listing[i+3] := '';

	if iny(i+5) and lda(i+6) and STA_BP2_Y(i+7) then
	  if listing[i] = listing[i+6] then begin

	   listing[i+6] := '';

	   if iny(i+8) and lda(i+9) and STA_BP2_Y(i+10) then
	     if listing[i] = listing[i+9] then listing[i+9] := '';

	  end;

	exit(false);
      end;


    if (listing[i] = #9'lsr #$00') and								// lsr #$00				; 0
       (listing[i+1] = #9'ror #$00') and							// ror #$00				; 1
       ror_stack(i+2) and									// ror :STACKORIGIN+STACKWIDTH		; 2
       ror_stack(i+3) then									// ror :STACKORIGIN			; 3
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);
	listing[i+3] := #9'ror ' + copy(listing[i+3], 6, 256);

	exit(false);
     end;


    if tya(i) and										// tya					; 0
       lda(i+1) and										// lda					; 1
       sta(i+2) then										// sta					; 2
     begin
	listing[i] := '';
	exit(false);
     end;


    if tya(i) and										// tya					; 0
       lda(i+1) and										// lda					; 1
       and_ora_eor(i+2) and									// and|ora|eor				; 2
       sta(i+3) then										// sta					; 3
     begin
	listing[i] := '';
	exit(false);
     end;


    if ldy(i+4) and										// ldy					; 4

       lda_im(i) and										// lda #				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH		; 2
       mwy_bp2(i+3) and										// mwy 					; 3
//       ldy(i+4) and										// ldy					; 4
       lda_stack(i+5) then									// lda :STACKORIGIN			; 5
     if copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256) then
      begin
	listing[i+5] := listing[i];

	listing[i+1] := '';
	exit(false);
      end;


    if ldy(i+7) and										// ldy #				; 7

       lda_im(i) and										// lda #				; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       mwy_bp2(i+2) and										// mwy 					; 2
       ldy(i+3) and										// ldy #				; 3
       lda_bp2_y(i+4) and									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+10			; 5
       mwy_bp2(i+6) and										// mwy 					; 6
//       ldy(i+7) and										// ldy #				; 7
       lda_stack(i+8) then									// lda :STACKORIGIN+9			; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
        (copy(listing[i+1], 6, 256) <> copy(listing[i+5], 6, 256)) then
      begin
	listing[i+8] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
       ldy_stack(i+2) and									// ldy :STACKORIGIN+STACKWIDTH		; 2
       (SKIP(i+3) = false) then									//~SKIP					; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
       begin
	listing[i]   := #9'tay';

	listing[i+2] := '';
	exit(false);
       end;


    if sta_stack(i) and										// sta :STACKORIGIN+10			; 0
       ldy(i+1) and										// ldy					; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+10			; 2
       sta(i+3) and iy(i+3) then								// sta (:bp),y				; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+2] := '';
	exit(false);
      end;


    if sta_stack(i) and										// sta :STACKORIGIN+10			; 0
       mwy_bp2(i+1) and										// mwy ... :bp2				; 1
       ldy(i+2) and										// ldy					; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+10			; 3
       sta(i+4) and iy(i+4) then								// sta (:bp),y				; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+3] := '';
	exit(false);
      end;


    if sta(i) and										// sta I				; 0
       ldy(i+1) then										// ldy I				; 1
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then begin
	listing[i]   := #9'tay';
	listing[i+1] := '';
	exit(false);
     end;


    if sta(i) and										// sta I				; 0
       mwy_bp2(i+1) and										// mwy ... :bp2				; 1
       ldy(i+2) then										// ldy I				; 2
     if copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256) then begin
	listing[i] := '';

	listing[i+2] := #9'tay';
	exit(false);
     end;


    if (lda_a(i) or adc_sbc(i)) and (iy(i) = false) and						// lda|adc|sbc				; 0
       ldy(i+1) and										// ldy					; 1
       (lda_a(i+2) or mva(i+2) or mwa(i+2)) then						// lda|mva|mwa				; 2
     begin

      if (i>0) and adc_sbc(i) and lda_a(i-1) then listing[i-1] := '';

      listing[i] := '';
      exit(false);
     end;


    if ldy_im_0(i) and										// ldy #$00				; 0
       iny(i+1) then										// iny					; 1
     begin
	listing[i]   := #9'ldy #$01';
	listing[i+1] := '';
	exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda					; 2	~lda :STACKORIGIN
       sta_val(i+3) and										// sta A				; 3	~sta :STACKORIGN
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH		; 4
       sta_val(i+5) then									// sta A+1				; 5	~sta :STACKORIGN
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
      begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH+10	; 8

       sta_stack(i) and (iy(i+1) = false) and (iy(i+3) = false) and				// sta :STACKORIGIN+9			; 0
       lda_a(i+1) and										// lda 					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and										// lda 					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+10	; 4
       ldy_stack(i+5) and									// ldy :STACKORIGIN+9			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+10			; 6
       sta_a(i+7) and										// sta					; 7
//       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH+10	; 8
       sta_a(i+9) then										// sta					; 9
     if (copy(listing[i], 6, 256) = copy(listing[i+5], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+8], 6, 256)) then
     begin
	listing[i+6] := listing[i+1];
	listing[i+8] := listing[i+3];
	listing[i]   := #9'tay';

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

      	exit(false);
     end;


    if lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*3+10	; 16

       ldy_val(i) and (listing[i] = listing[i+9]) and						// ldy I				; 0	~:STACKORIGIN
       lda_a(i+1) and										// lda					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and										// lda 					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+10	; 4
       lda_a(i+5) and										// lda 					; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 6
       lda_a(i+7) and										// lda 					; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 8
       ldy(i+9) and										// ldy I				; 9
       lda_stack(i+10) and									// lda :STACKORIGIN+10			; 10
       sta_a(i+11) and										// sta					; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH+10	; 12
       sta_a(i+13) and										// sta					; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH*2+10	; 14
       sta_a(i+15) and										// sta					; 15
//       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*3+10	; 16
       sta_a(i+17) then										// sta					; 17
     if (copy(listing[i+2], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+16], 6, 256)) then
     begin
	listing[i+10] := listing[i+1];

	listing[i+12] := listing[i+3];

	listing[i+14] := listing[i+5];

	listing[i+16] := listing[i+7];

	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';

      	exit(false);
     end;


    if lda_stack(i+15) and									// lda :STACKORIGIN+STACKWIDTH*3+10	; 15

       lda_val(i) and (iy(i) = false) and							// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+10			; 1
       lda(i+2) and										// lda 					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda(i+4) and										// lda 					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda(i+6) and										// lda 					; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       ldy_stack(i+8) and									// ldy :STACKORIGIN+9			; 8
       lda_stack(i+9) and									// lda :STACKORIGIN+10			; 9
       sta_a(i+10) and										// sta					; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH+10	; 11
       sta_a(i+12) and										// sta					; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH*2+10	; 13
       sta_a(i+14) and										// sta					; 14
//       lda_stack(i+15) and									// lda :STACKORIGIN+STACKWIDTH*3+10	; 15
       sta_a(i+16) then										// sta					; 16
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+13], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+15], 6, 256)) then
     begin
	listing[i+9] := listing[i];

	listing[i+11] := listing[i+2];

	listing[i+13] := listing[i+4];

	listing[i+15] := listing[i+6];

	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';

      	exit(false);
     end;


// -----------------------------------------------------------------------------


    if lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH*3	; 18

       lda_a(i) and										// lda					; 0
       and_ora_eor(i+1) and									// and|ora|eor				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_a(i+3) and										// lda 					; 3
       and_ora_eor(i+4) and									// and|ora|eor				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_a(i+6) and										// lda 					; 6
       and_ora_eor(i+7) and									// and|ora|eor				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       lda_a(i+9) and										// lda 					; 9
       and_ora_eor(i+10) and									// and|ora|eor				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN			; 12
       sta_a(i+13) and										// sta 					; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH		; 14
       sta_a(i+15) and										// sta 					; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH*2	; 16
       sta_a(i+17) and										// sta					; 17
//       lda_stack(i+18) and									// lda :STACKORIGIN+STACKWIDTH*3	; 18
       sta_a(i+19) then										// sta					; 19
     if (copy(listing[i+2], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+8], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+11], 6, 256) = copy(listing[i+18], 6, 256)) then
     begin
	listing[i+2] := listing[i+13];

	listing[i+5] := listing[i+15];

	listing[i+8] := listing[i+17];

	listing[i+11]:= listing[i+19];

	listing[i+12] := '';
	listing[i+13] := '';
	listing[i+14] := '';
	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';

      	exit(false);
     end;


// -----------------------------------------------------------------------------


    if sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*3	; 15

       lda_a(i) and										// lda					; 0
       sta_a(i+1) and										// sta A				; 1
       lda_a(i+2) and										// lda 					; 2
       sta_a(i+3) and										// sta A+1				; 3
       lda_a(i+4) and										// lda 					; 4
       sta_a(i+5) and										// sta A+2				; 5
       lda_a(i+6) and										// lda 					; 6
       sta_a(i+7) and										// sta A+3				; 7
       lda_a(i+8) and										// lda A				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN			; 9
       lda_a(i+10) and										// lda A+1				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH		; 11
       lda_a(i+12) and										// lda A+2				; 12
       sta_stack(i+13) and									// sta :STACKORIGIN+STACKWIDTH*2	; 13
       lda_a(i+14) then										// lda A+3				; 14
//       sta_stack(i+15) then									// sta :STACKORIGIN+STACKWIDTH*3	; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+14], 6, 256)) then
     begin
	listing[i+8] := listing[i];

	listing[i+10] := listing[i+2];

	listing[i+12] := listing[i+4];

	listing[i+14] := listing[i+6];

	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';

      	exit(false);
     end;


    if sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*3	; 15

       lda_a(i) and										// lda					; 0
       sta_a(i+1) and										// sta A				; 1
       lda_a(i+2) and										// lda 					; 2
       sta_a(i+3) and										// sta A+1				; 3
       lda_a(i+4) and										// lda 					; 4
       sta_a(i+5) and										// sta A+2				; 5
       lda_a(i+6) and										// lda 					; 6
       sta_a(i+7) and										// sta A+3				; 7
       lda_a(i+8) and										// lda A				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN			; 9
       lda_a(i+10) and										// lda A+1				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH		; 11
       lda_a(i+12) and										// lda ...				; 12
       sta_stack(i+13) and									// sta :STACKORIGIN+STACKWIDTH*2	; 13
       lda_a(i+14) then										// lda ...				; 14
//       sta_stack(i+15) then									// sta :STACKORIGIN+STACKWIDTH*3	; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+5], 6, 256) <> copy(listing[i+12], 6, 256)) and
	(copy(listing[i+7], 6, 256) <> copy(listing[i+14], 6, 256)) then
     begin
	listing[i+8] := listing[i];

	listing[i+10] := listing[i+2];

	listing[i]    := '';
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';

      	exit(false);
     end;


    if sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH*2	; 4

       lda_val(i) and										// lda 					; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2	; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+STACKWIDTH*3	; 2
       lda_a(i+3) then										// lda					; 3
//       sta_stack(i+4) then									// sta :STACKORIGIN+STACKWIDTH*2	; 4
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+1] := '';

      	exit(false);
     end;


    if (lda_a(i) = false) and									//~lda					; 0
       sta_val(i+1) and										// sta A				; 1	~sta :STACKORIGN
       lda_stack(i+2) and									// lda :STACKORIGIN			; 2
       sta_val(i+3) and										// sta A+1				; 3	~sta :STACKORIGN
       lda_a(i+4) and										// lda A				; 4
       sta_val(i+5) and										// sta					; 5	~sta :STACKORIGN
       lda_a(i+6) and										// lda A+1				; 6
       sta_val(i+7) then									// sta					; 7	~sta :STACKORIGN
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+6] := listing[i+2];

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 5

       lda_val(i) and										// lda					; 0	~sta :STACKORIGN
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH*2+10	; 1
       lda_val(i+2) and										// lda					; 2	~sta :STACKORIGN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       lda_stack(i+4) and									// lda :STACKORIGIN+STACKWIDTH*2+10	; 4
       //sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 5
       (lda_a(i+6) or (ldy(i+6) and lda_a(i+7))) then						// lda|ldy				; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and				//    |lda				; 7
        (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) and
        (copy(listing[i+3], 6, 256) <> copy(listing[i+5], 6, 256)) then
      begin

	listing_tmp[0] := listing[i];
	listing_tmp[1] := listing[i+1];
	listing_tmp[2] := listing[i+4];
	listing_tmp[3] := listing[i+5];
	listing_tmp[4] := listing[i+2];
	listing_tmp[5] := listing[i+3];

	listing[i]   := listing_tmp[0];
	listing[i+1] := listing_tmp[1];
	listing[i+2] := listing_tmp[2];
	listing[i+3] := listing_tmp[3];
	listing[i+4] := listing_tmp[4];
	listing[i+5] := listing_tmp[5];

	exit(false);
      end;


    if lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6

       lda_val(i) and										// lda					; 0	~lda :STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~lda :STACKORIGIN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_val(i+5) and										// sta					; 5	5 <> 2	!!!	~sta :STACKORIGN
//       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       sta_val(i+7) then									// sta					; 7			~sta :STACKORIGN
     if (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if lda_stack(i+4) and									// lda :STACKORIGIN			; 4

       lda_val(i) and										// lda					; 0	~lda :STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~lda :STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~sta :STACKORIGN
//       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       sta_val(i+5) then									// sta					; 5	~sta :STACKORIGN
     if (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if lda_stack(i+4) and									// lda :STACKORIGIN			; 4

       lda_val(i) and										// lda					; 0	~lda :STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda					; 2	~lda :STACKORIGIN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
//       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       (add_sub(i+5) or and_ora_eor(i+5)) then							// add|sub|and|ora|eor			; 5	~asl @  !!!
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin
	listing[i+4] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH		; 7

//       (lda_a(i) = false) and									//~lda					; 0
       sta_val(i+1) and										// sta A				; 1	~sta :STACKORIGN
       lda_stack(i+2) and									// lda :STACKORIGIN+STACKWIDTH		; 2
       sta_val(i+3) and										// sta A+1				; 3	~sta :STACKORIGN
       lda_val(i+4) and										// lda A				; 4	~lda :STACKORIGIN
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda_val(i+6) then									// lda A+1				; 6	~lda :STACKORIGIN
//       sta_stack(i+7) then									// sta :STACKORIGIN+STACKWIDTH		; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+1] := listing[i+5];

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5

//       (lda_a(i) = false) and									//~lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_val(i+2) and										// lda A				; 2	~lda :STACKORIGIN
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) then									// lda :STACKORIGIN			; 4
//       sta_stack(i+5) then									// sta :STACKORIGIN+STACKWIDTH		; 5
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
       end;


    if sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3

       lda_a(i) and										// lda					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) then									// lda					; 2	~lda :STACKORIGIN
//       sta_stack(i+3) then									// sta :STACKORIGIN+STACKWIDTH		; 3
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
       begin
	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if (listing[i] = #9'sta @PARAM?') and							// sta @PARAM?				; 0

       iny(i+1) and										// iny					; 1
       lda(i+2) and										// lda					; 2
       sta(i+3) then										// sta					; 3
      begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if (listing[i+7] = #9'sta @PARAM?') and							// sta @PARAM?				; 7

       add_sub(i) and										// add|sub				; 0
       sta_bp2(i+1) and										// sta :bp2				; 1
       lda(i+2) and										// lda					; 2
       adc_sbc(i+3) and										// adc|sbc				; 3
       sta_bp2_1(i+4) and									// sta :bp2+1				; 4
       ldy_im_0(i+5) and									// ldy #$00				; 5
       lda_bp2_y(i+6) then									// lda (:bp2),y				; 6
//       (listing[i+7] = #9'sta @PARAM?') then							// sta @PARAM?				; 7
      begin
	listing[i+1] := #9'tay';

	listing[i+4] := #9'sta :bp+1';
	listing[i+5] := '';
	listing[i+6] := #9'lda (:bp),y';

	exit(false);
      end;


    if iny(i) and										// iny					; 0
       lda_a(i+1) and										// lda					; 1
       iny(i+2) and										// iny					; 2
       lda_a(i+3) and										// lda					; 3
       lda_a(i+4) then										// lda					; 4
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


// -----------------------------------------------------------------------------


    if lda_eax_1(i+6) and									// lda :eax+1				; 6

       lda_val(i) and										// lda					; 0	~lda :STACKORIGIN
       sta_eax(i+1) and										// sta :eax				; 1
       lda_val(i+2) and										// lda					; 2	~lda :STACKORIGIN
       sta_eax_1(i+3) and									// sta :eax+1				; 3
       lda_eax(i+4) and										// lda :eax				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
//       lda_eax_1(i+6) and									// lda :eax+1				; 6
       sta_stack(i+7) then									// sta :STACKORIGIN+STACKWIDTH		; 7
     if (copy(listing[i+5], 6, 256) <> copy(listing[i+7], 6, 256)) then
       begin
	listing[i+4] := listing[i];

	listing[i+6] := listing[i+2];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;

end;		// function
