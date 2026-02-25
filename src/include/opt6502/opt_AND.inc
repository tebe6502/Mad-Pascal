
function opt_AND(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      AND.
// -----------------------------------------------------------------------------


    if and_stack(i+18) and								// and :STACKORIGIN+STACKWIDTH*3+10	; 18

       lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_a(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda_a(i+4) and									// lda					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda_a(i+6) and									// lda					; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       lda_a(i+8) and									// lda ERROR				; 8
       and_stack(i+9) and								// and :STACKORIGIN+10			; 9
       sta_a(i+10) and									// sta ERROR				; 10
       lda_a(i+11) and									// lda ERROR+1				; 11
       and_stack(i+12) and								// and :STACKORIGIN+STACKWIDTH+10	; 12
       sta_a(i+13) and									// sta ERROR+1				; 13
       lda_a(i+14) and									// lda ERROR+2				; 14
       and_stack(i+15) and								// and :STACKORIGIN+STACKWIDTH*2+10	; 15
       sta_a(i+16) and									// sta ERROR+2				; 16
       lda_a(i+17) and									// lda ERROR+3				; 17
//       and_stack(i+18) and								// and :STACKORIGIN+STACKWIDTH*3+10	; 18
       sta_a(i+19) then									// sta ERROR+3				; 19
     if argMatch(i+1, i+9) and
	argMatch(i+3, i+12) and
	argMatch(i+5, i+15) and
	argMatch(i+7, i+18) then
       begin
	listing[i+9]  := #9'and ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'and ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'and ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'and ' + copy(listing[i+6], 6, 256);

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

	if argMatch(i, i+2) then begin
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
     if argMatch(i, i+2) then
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
     if argMatch(i+3, i+17) and
        argMatch(i+7, i+20) and
        argMatch(i+11, i+23) and
        argMatch(i+15, i+26) then
       begin

        for p:=0 to 3 do

	if and_im_0(p*4+i+2) then begin
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
