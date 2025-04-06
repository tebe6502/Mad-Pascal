
function opt_ORA(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      ORA.
// -----------------------------------------------------------------------------

    if lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_a(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda_a(i+4) and									// lda					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda_a(i+6) and									// lda					; 6
       sta_stack(i+7) then								// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
    begin

     if
       lda_a(i+8) and									// lda ERROR				; 8
       ora_stack(i+9) and								// ora :STACKORIGIN+10			; 9
       sta_a(i+10) and									// sta ERROR				; 10
       lda_a(i+11) and									// lda ERROR+1				; 11
       ora_stack(i+12) and								// ora :STACKORIGIN+STACKWIDTH+10	; 12
       sta_a(i+13) and									// sta ERROR+1				; 13
       lda_a(i+14) and									// lda ERROR+2				; 14
       ora_stack(i+15) and								// ora :STACKORIGIN+STACKWIDTH*2+10	; 15
       sta_a(i+16) and									// sta ERROR+2				; 16
       lda_a(i+17) and									// lda ERROR+3				; 17
       ora_stack(i+18) and								// ora :STACKORIGIN+STACKWIDTH*3+10	; 18
       sta_a(i+19) then									// sta ERROR+3				; 19
     if (copy(listing[i+1], 6, 256) = copy(listing[i+9], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+12], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+15], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+18], 6, 256)) then
       begin
	listing[i+9]  := #9'ora ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'ora ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'ora ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'ora ' + copy(listing[i+6], 6, 256);

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


     if
       lda_stack(i+8) and								// lda :STACKORIGIN+10			; 8
       and_ora_eor(i+9) and								// and|ora|eor				; 9
       sta_a(i+10) and									// sta					; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH+10	; 11
       and_ora_eor(i+12) and								// and|ora|eor 				; 12
       sta_a(i+13) and									// sta					; 13
       lda_stack(i+14) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 14
       and_ora_eor(i+15) and								// and|ora|eor				; 15
       sta_a(i+16) and									// sta					; 16
       lda_stack(i+17) and								// lda :STACKORIGIN+STACKWIDTH*3+10	; 17
       and_ora_eor(i+18) and								// and|ora|eor				; 18
       sta_a(i+19) then									// sta					; 19
     if (copy(listing[i+1], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+7], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+8]  := listing[i];
	listing[i+11] := listing[i+2];
	listing[i+14] := listing[i+4];
	listing[i+17] := listing[i+6];

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

    end;


// -----------------------------------------------------------------------------


    if lda_a(i) and									// lda			; 0
       ora_im_0(i+1) and								// ora #$00		; 1
       sta_a(i+2) then									// sta			; 2
     begin

	if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin
	  listing[i] := '';
	  listing[i+2] := '';
        end;

	listing[i+1] := '';

	exit(false);
     end;


    if lda_a(i) and									// lda			; 0
       ora_im_0(i+1) and								// ora #$00		; 1
       and_ora_eor(i+2) then								// and|ora|eor		; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if and_ora_eor(i) and								// and|ora|eor		; 0
       ora_im_0(i+1) then								// ora #$00		; 1
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if lda_im_0(i) and									// lda #$00		; 0
       ora(i+1) and									// ora 			; 1
       sta_a(i+2) then									// sta			; 2
     begin
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256) ;
	listing[i+1] := '';

	exit(false);
     end;


    if lda_a(i) and									// lda 			; 0
       (listing[i+1] = #9'ora #$FF') and						// ora #$FF		; 1
       sta_a(i+2) then									// sta 			; 2
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$FF';

	exit(false);
     end;


    if sta_stack(i) and 								// sta :STACKORIGIN	; 0
       lda_a(i+1) and 									// lda 			; 1
       ora_stack(i+2) then								// ora :STACKORIGIN	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := '';
	listing[i+1] := #9'ora ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
       end;


    if lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+9			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH+9	; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+9			; 3
       and_ora_eor(i+4) and 								// and|ora|eor				; 4
       sta_a(i+5) and									// sta					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH+9	; 6
       ora(i+7) then 									// ora					; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
	(copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+3] := listing[i];
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


    if lda_val(i) and									// lda					; 0	~:STACKORIGIN
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH*2	; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH*3	; 3
       lda_a(i+4) and									// lda :STACKORIGIN			; 4
       and_ora_eor_val(i+5) and								// and|ora|eor				; 5	~:STACKORIGIN
       sta_a(i+6) and									// sta :STACKORIGIN			; 6
       lda_stack(i+7) and								// lda :STACKORIGIN+STACKWIDTH*2	; 7
       sta_stack(i+8) then								// sta :STACKORIGIN+STACKWIDTH*3	; 8
     if (copy(listing[i+1], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+1], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+7] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
//	listing[i+2] := '';
//	listing[i+3] := '';

	exit(false);
       end;


    if lda(i) and									// lda					; 0
       and_ora_eor(i+1) and								// and|ora|eor				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda(i+3) and									// lda					; 3
       and_ora_eor(i+4) and								// and|ora|eor				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda(i+6) and									// lda					; 6
       ora_stack(i+7) and								// ora :STACKORIGIN			; 7
       sta(i+8) and									// sta 					; 8
       lda(i+9) and									// lda					; 9
       ora_stack(i+10) and								// ora :STACKORIGIN+STACKWIDTH		; 10
       sta(i+11) then									// sta					; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	listing[i+2] := #9'ora ' + copy(listing[i+6], 6, 256);

	listing[i+5] := #9'ora ' + copy(listing[i+9], 6, 256);

	listing[i+6] := listing[i+5];
	listing[i+5] := listing[i+4];
	listing[i+4] := listing[i+3];

	listing[i+3] := listing[i+8];

	listing[i+7] := listing[i+11];

	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if ldy(i) and									// ldy #$00				; 0
       LDA_BP2_Y(i+1) and								// lda (:bp2),y				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       iny(i+3) and									// iny					; 3
       LDA_BP2_Y(i+4) and								// lda (:bp2),y				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda(i+6) and									// lda :STACKORIGIN+9			; 6
       ora_stack(i+7) and								// ora :STACKORIGIN+10			; 7
       sta(i+8) and									// sta C				; 8
       lda(i+9) and									// lda :STACKORIGIN+STACKWIDTH+9	; 9
       ora_stack(i+10) and								// ora :STACKORIGIN+STACKWIDTH+10	; 10
       sta(i+11) then									// sta C+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+10], 6, 256)) and
	(copy(listing[i+2], 6, 256) <> copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) <> copy(listing[i+9], 6, 256)) then
	begin

	  listing[i+1] := listing[i+6];
	  listing[i+2] := #9'ora (:bp2),y';
	  listing[i+3] := listing[i+8];
	  listing[i+4] := #9'iny';
	  listing[i+5] := listing[i+9];
	  listing[i+6] := #9'ora (:bp2),y';
	  listing[i+7] := listing[i+11];

	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10] := '';
	  listing[i+11] := '';

	  exit(false);
	end;


    if lda_a(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH		; 5
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       ora(i+7) and (ora_stack(i+7) = false) and					// ora S				; 7
       sta(i+8) and									// sta C				; 8
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       ora(i+10) and (ora_stack(i+10) = false) and					// ora S+1				; 10
       sta(i+11) then									// sta C+1				; 11
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i+5], 6, 256) = copy(listing[i+9], 6, 256)) then
	begin
	  listing[i+2] := listing[i+7];

	  listing[i+5] := listing[i+10];
	  listing[i+6] := listing[i+11];

	  listing[i+7] :=listing[i+6];
	  listing[i+6] :=listing[i+5];
	  listing[i+5] :=listing[i+4];
	  listing[i+4] :=listing[i+3];

	  listing[i+3] := listing[i+8];

	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10] := '';
	  listing[i+11] := '';

	  exit(false);
	end;

end;		// function
