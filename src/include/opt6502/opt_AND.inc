
function opt_AND(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      AND.
// -----------------------------------------------------------------------------

    if lda_im_0(i) and										// lda #$00				; 0
       and_(i+1) and										// and					; 1
       sta_a(i+2) then										// sta 					; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and								// lda 					; 0
       and_im_0(i+1) and									// and #$00				; 1
       sta_a(i+2) then										// sta 					; 2
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$00';

	exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN			; 0
       and_im_0(i+1) and									// and #$00				; 1
       sta_stack(i+2) then									// sta :STACKORIGIN			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$00';

	exit(false);
     end;


    if and_im_0(i) and										// and #$00				; 0
       mwy(i+1) and										// mwy					; 1
       ldy(i+2) and										// ldy					; 2
       lda_a(i+3) then										// lda					; 3
     begin
	listing[i]   := '';

	exit(false);
     end;


    if lda_a(i) and										// lda 					; 0
       (listing[i+1] = #9'and #$FF') and							// and #$FF				; 1
       sta_a(i+2) then										// sta 					; 2
     begin

	if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin
	  listing[i] := '';
	  listing[i+2] := '';
        end;

	listing[i+1] := '';

	exit(false);
     end;


    if and_ora_eor(i) and									// and|ora|eor				; 0
       (listing[i+1] = #9'and #$FF') and							// and #$FF				; 1
       sta_a(i+2) then										// sta 					; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN			; 0
       lda_a(i+1) and										// lda					; 1
       and_stack(i+2) then									// and :STACKORIGIN			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'and ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
     end;


    if //ldy_im_0(i) and									// ldy #$00				; 0
       lda_bp2_y(i+1) and									// lda (:bp2),y				; 1
       and_im(i+2) and										// and #				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN			; 3
       iny(i+4) and										// iny					; 4
       lda_bp2_y(i+5) and									// lda (:bp2),y				; 5
       and_im(i+6) and										// and #				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH		; 7
       iny(i+8) and										// iny					; 8
       lda_bp2_y(i+9) and									// lda (:bp2),y				; 9
       and_im(i+10) and										// and #				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*2	; 11
       iny(i+12) and										// iny					; 12
       lda_bp2_y(i+13) and									// lda (:bp2),y				; 13
       and_im(i+14) and										// and #				; 14
       sta_stack(i+15) and									// sta :STACKORIGIN+STACKWIDTH*3	; 15
       lda_a(i+16) and 										// lda					; 16
       eor_stack(i+17) and 									// eor :STACKORIGIN			; 17
       sta_a(i+18) and 	 									// sta					; 18
       lda_a(i+19) and 										// lda					; 19
       eor_stack(i+20) and 									// eor :STACKORIGIN+STACKWIDTH		; 20
       sta_a(i+21) and										// sta					; 21
       lda_a(i+22) and 										// lda					; 22
       eor_stack(i+23) and 									// eor :STACKORIGIN+STACKWIDTH*2	; 23
       sta_a(i+24) and 										// sta					; 24
       lda_a(i+25) and 										// lda					; 25
       eor_stack(i+26) and 									// eor :STACKORIGIN+STACKWIDTH*3	; 26
       sta_a(i+27) then										// sta					; 27
     if (copy(listing[i+3], 6, 256) = copy(listing[i+17], 6, 256)) and
        (copy(listing[i+7], 6, 256) = copy(listing[i+20], 6, 256)) and
        (copy(listing[i+11], 6, 256) = copy(listing[i+23], 6, 256)) and
        (copy(listing[i+15], 6, 256) = copy(listing[i+26], 6, 256)) then
       begin

        for p:=0 to 3 do

	if listing[p*4+i+2] = #9'and #$00' then begin
	  listing[p*4+i+1] := '';
	  listing[p*4+i+2] := '';
	  listing[p*4+i+3] := '';

	  listing[p*3+i+17] := '';
	end else
	if listing[p*4+i+2] = #9'and #$FF' then begin
	  listing[p*4+i+1] := listing[p*3+i+16];
	  listing[p*4+i+2] := #9'eor (:bp2),y';
	  listing[p*4+i+3] := listing[p*3+i+18];

	  listing[p*3+i+16] := '';
	  listing[p*3+i+17] := '';
	  listing[p*3+i+18] := '';
	end;


	if listing[i+13] = '' then begin

	   listing[i+12] := '';

	   if listing[i+9] = '' then begin

	      listing[i+8] := '';

	      if listing[i+5] = '' then begin

		 listing[i+4] := '';

	      end;

	   end;

	end;

	exit(false);
       end;


    if lda_bp2_y(i) and										// lda (:bp2),y				; 0
       and_im_0(i+1) and									// and #$00				; 1
       sta_a(i+2) then										// sta 					; 2
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$00';

	exit(false);
     end;

end;		// function