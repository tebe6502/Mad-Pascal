
function opt_EOR(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      EOR.
// -----------------------------------------------------------------------------

    if and_ora_eor(i+22) and								// and|ora|eor				; 22

       lda_a(i) and									// lda					; 0
       and_ora_eor(i+1) and								// and|ora|eor				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+10			; 2
       lda_a(i+3) and									// lda					; 3
       and_ora_eor(i+4) and								// and|ora|eor				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+10	; 5
       lda_a(i+6) and									// lda					; 6
       and_ora_eor(i+7) and								// and|ora|eor				; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 8
       lda_a(i+9) and									// lda					; 9
       and_ora_eor(i+10) and								// and|ora|eor				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 11
       lda_stack(i+12) and								// lda :STACKORIGIN+10			; 12
       and_ora_eor(i+13) and								// and|ora|eor				; 13
       sta_a(i+14) and									// sta					; 14
       lda_stack(i+15) and								// lda :STACKORIGIN+STACKWIDTH+10	; 15
       and_ora_eor(i+16) and								// and|ora|eor				; 16
       sta_a(i+17) and									// sta					; 17
       lda_stack(i+18) and								// lda :STACKORIGIN+STACKWIDTH*2+10	; 18
       and_ora_eor(i+19) and								// and|ora|eor				; 19
       sta_a(i+20) and									// sta					; 20
       lda_stack(i+21) and								// lda :STACKORIGIN+STACKWIDTH*3+10	; 21
//       and_ora_eor(i+22) and								// and|ora|eor				; 22
       sta_a(i+23) then									// sta					; 23
     if argMatch(i+2, i+12) and
	argMatch(i+5, i+15) and
	argMatch(i+8, i+18) and
	argMatch(i+11, i+21) then
       begin

	listing_tmp[0] := listing[i];
	listing_tmp[1] := listing[i+1];
	listing_tmp[2] := listing[i+13];
	listing_tmp[3] := listing[i+14];

	listing_tmp[4] := listing[i+3];
	listing_tmp[5] := listing[i+4];
	listing_tmp[6] := listing[i+16];
	listing_tmp[7] := listing[i+17];

	listing_tmp[8] := listing[i+6];
	listing_tmp[9] := listing[i+7];
	listing_tmp[10]:= listing[i+19];
	listing_tmp[11]:= listing[i+20];

	listing_tmp[12] := listing[i+9];
	listing_tmp[13] := listing[i+10];
	listing_tmp[14] := listing[i+22];
	listing_tmp[15] := listing[i+23];

	for p:=0 to 15 do listing[i+p] := listing_tmp[p];

	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	exit(false);
       end;


    if and_ora_eor_stack(i+22) and							// and|ora|eor :STACKORIGIN+STACKWIDTH*3	; 22

       lda_a(i) and									// lda						; 0
       and_ora_eor(i+1) and								// and|ora|eor					; 1
       sta_stack(i+2) and								// sta :STACKORIGIN				; 2
       lda_a(i+3) and									// lda						; 3
       and_ora_eor(i+4) and								// and|ora|eor					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH			; 5
       lda_a(i+6) and									// lda						; 6
       and_ora_eor(i+7) and								// and|ora|eor					; 7
       sta_stack(i+8) and								// sta :STACKORIGIN+STACKWIDTH*2		; 8
       lda_a(i+9) and									// lda						; 9
       and_ora_eor(i+10) and								// and|ora|eor					; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*3		; 11
       lda_val(i+12) and 								// lda						; 12	~:STACKORIGIN
       and_ora_eor_stack(i+13) and							// and|ora|eor :STACKORIGIN			; 13
       sta_a(i+14) and									// sta						; 14
       lda_val(i+15) and								// lda						; 15	~:STACKORIGIN
       and_ora_eor_stack(i+16) and							// and|ora|eor :STACKORIGIN+STACKWIDTH		; 16
       sta_a(i+17) and									// sta						; 17
       lda_val(i+18) and								// lda						; 18	~:STACKORIGIN
       and_ora_eor_stack(i+19) and							// and|ora|eor :STACKORIGIN+STACKWIDTH*2	; 19
       sta_a(i+20) and									// sta						; 20
       lda_val(i+21) and								// lda						; 21	~:STACKORIGIN
//       and_ora_eor_stack(i+22) and							// and|ora|eor :STACKORIGIN+STACKWIDTH*3	; 22
       sta_a(i+23) then									// sta						; 23
     if argMatch(i+2, i+13) and
	argMatch(i+5, i+16) and
	argMatch(i+8, i+19) and
	argMatch(i+11, i+22) then
       begin

	listing_tmp[0] := listing[i];
	listing_tmp[1] := listing[i+1];
	listing_tmp[2] := copy(listing[i+13], 1, 5) + copy(listing[i+12], 6, 256);
	listing_tmp[3] := listing[i+14];

	listing_tmp[4] := listing[i+3];
	listing_tmp[5] := listing[i+4];
	listing_tmp[6] := copy(listing[i+16], 1, 5) + copy(listing[i+15], 6, 256);
	listing_tmp[7] := listing[i+17];

	listing_tmp[8] := listing[i+6];
	listing_tmp[9] := listing[i+7];
	listing_tmp[10]:= copy(listing[i+19], 1, 5) + copy(listing[i+18], 6, 256);
	listing_tmp[11]:= listing[i+20];

	listing_tmp[12] := listing[i+9];
	listing_tmp[13] := listing[i+10];
	listing_tmp[14] := copy(listing[i+22], 1, 5) + copy(listing[i+21], 6, 256);
	listing_tmp[15] := listing[i+23];

	for p:=0 to 15 do listing[i+p] := listing_tmp[p];

	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';

	exit(false);
       end;


    if and_ora_eor_stack(i+26) and							// and|ora|eor :STACKORIGIN+STACKWIDTH*3+10	; 26

       lda_a(i) and									// lda						; 0
       and_ora_eor(i+1) and								// and|ora|eor					; 1
       and_ora_eor(i+2) and								// and|ora|eor					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+10				; 3
       lda_a(i+4) and									// lda						; 4
       and_ora_eor(i+5) and								// and|ora|eor					; 5
       and_ora_eor(i+6) and								// and|ora|eor					; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH+10		; 7
       lda_a(i+8) and									// lda						; 8
       and_ora_eor(i+9) and								// and|ora|eor					; 9
       and_ora_eor(i+10) and								// and|ora|eor					; 10
       sta_stack(i+11) and								// sta :STACKORIGIN+STACKWIDTH*2+10		; 11
       lda_a(i+12) and									// lda						; 12
       and_ora_eor(i+13) and								// and|ora|eor					; 13
       and_ora_eor(i+14) and								// and|ora|eor					; 14
       sta_stack(i+15) and								// sta :STACKORIGIN+STACKWIDTH*3+10		; 15
       lda_a(i+16) and {(lda_stack(i+16) = false) and}					// lda 						; 16
       and_ora_eor_stack(i+17) and							// and|ora|eor :STACKORIGIN+10			; 17
       sta_a(i+18) and									// sta						; 18
       lda_a(i+19) and {(lda_stack(i+19) = false) and}					// lda 						; 19
       and_ora_eor_stack(i+20) and							// and|ora|eor :STACKORIGIN+STACKWIDTH+10	; 20
       sta_a(i+21) and									// sta						; 21
       lda_a(i+22) and {(lda_stack(i+22) = false) and}					// lda 						; 22
       and_ora_eor_stack(i+23) and							// and|ora|eor :STACKORIGIN+STACKWIDTH*2+10	; 23
       sta_a(i+24) and									// sta						; 24
       lda_a(i+25) and {(lda_stack(i+25) = false) and}					// lda 						; 25
//       and_ora_eor_stack(i+26) and							// and|ora|eor :STACKORIGIN+STACKWIDTH*3+10	; 26
       sta_a(i+27) then									// sta						; 27
     if argMatch(i+3, i+17) and
	argMatch(i+7, i+20) and
	argMatch(i+11, i+23) and
	argMatch(i+15, i+26) then
       begin

	listing_tmp[0] := listing[i];
	listing_tmp[1] := listing[i+1];
	listing_tmp[2] := listing[i+2];
	listing_tmp[3] := copy(listing[i+17], 1, 5) + copy(listing[i+16], 6, 256);
	listing_tmp[4] := listing[i+18];

	listing_tmp[5] := listing[i+4];
	listing_tmp[6] := listing[i+5];
	listing_tmp[7] := listing[i+6];
	listing_tmp[8] := copy(listing[i+20], 1, 5) + copy(listing[i+19], 6, 256);
	listing_tmp[9] := listing[i+21];

	listing_tmp[10] := listing[i+8];
	listing_tmp[11] := listing[i+9];
	listing_tmp[12] := listing[i+10];
	listing_tmp[13] := copy(listing[i+23], 1, 5) + copy(listing[i+22], 6, 256);
	listing_tmp[14] := listing[i+24];

	listing_tmp[15] := listing[i+12];
	listing_tmp[16] := listing[i+13];
	listing_tmp[17] := listing[i+14];
	listing_tmp[18] := copy(listing[i+26], 1, 5) + copy(listing[i+25], 6, 256);
	listing_tmp[19] := listing[i+27];

	for p:=0 to 19 do listing[i+p] := listing_tmp[p];

	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';
	listing[i+23] := '';
	listing[i+24] := '';
	listing[i+25] := '';
	listing[i+26] := '';
	listing[i+27] := '';

	exit(false);
       end;


    if eor_stack(i+18) and								// eor :STACKORIGIN+STACKWIDTH*3+10	; 18

       lda_a(i) and									// lda					; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       lda_a(i+2) and									// lda					; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH+10	; 3
       lda_a(i+4) and									// lda					; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 5
       lda_a(i+6) and									// lda					; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 7
       lda_a(i+8) and									// lda					; 8
       eor_stack(i+9) and								// eor :STACKORIGIN+10			; 9
       sta_a(i+10) and									// sta					; 10
       lda_a(i+11) and									// lda					; 11
       eor_stack(i+12) and								// eor :STACKORIGIN+STACKWIDTH+10	; 12
       sta_a(i+13) and									// sta					; 13
       lda_a(i+14) and									// lda ERROR+2				; 14
       eor_stack(i+15) and								// eor :STACKORIGIN+STACKWIDTH*2+10	; 15
       sta_a(i+16) and									// sta					; 16
       lda_a(i+17) and									// lda					; 17
//       eor_stack(i+18) and								// eor :STACKORIGIN+STACKWIDTH*3+10	; 18
       sta_a(i+19) then									// sta					; 19
     if argMatch(i+1, i+9) and
	argMatch(i+3, i+12) and
	argMatch(i+5, i+15) and
	argMatch(i+7, i+18) then
       begin
	listing[i+9]  := #9'eor ' + copy(listing[i], 6, 256);
	listing[i+12] := #9'eor ' + copy(listing[i+2], 6, 256);
	listing[i+15] := #9'eor ' + copy(listing[i+4], 6, 256);
	listing[i+18] := #9'eor ' + copy(listing[i+6], 6, 256);

	listing[i] := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if eor_stack(i+21) and								// eor :STACKORIGIN+STACKWIDTH*3+10	; 21

       lda_bp2_y(i) and									// lda (:bp2),y				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+10			; 1
       iny(i+2) and									// iny					; 2
       lda_bp2_y(i+3) and								// lda (:bp2),y				; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH+10	; 4
       iny(i+5) and									// iny					; 5
       lda_bp2_y(i+6) and								// lda (:bp2),y				; 6
       sta_stack(i+7) and								// sta :STACKORIGIN+STACKWIDTH*2+10	; 7
       iny(i+8) and									// iny					; 8
       lda_bp2_y(i+9) and								// lda (:bp2),y				; 9
       sta_stack(i+10) and								// sta :STACKORIGIN+STACKWIDTH*3+10	; 10
       lda_a(i+11) and									// lda					; 11
       eor_stack(i+12) and								// eor :STACKORIGIN+10			; 12
       sta_a(i+13) and									// sta					; 13
       lda_a(i+14) and									// lda					; 14
       eor_stack(i+15) and								// eor :STACKORIGIN+STACKWIDTH+10	; 15
       sta_a(i+16) and									// sta					; 16
       lda_a(i+17) and									// lda					; 17
       eor_stack(i+18) and								// eor :STACKORIGIN+STACKWIDTH*2+10	; 18
       sta_a(i+19) and									// sta					; 19
       lda_a(i+20) and									// lda					; 20
//       eor_stack(i+21) and								// eor :STACKORIGIN+STACKWIDTH*3+10	; 21
       sta_a(i+22) then									// sta					; 22
     if argMatch(i+1, i+12) and
	argMatch(i+4, i+15) and
	argMatch(i+7, i+18) and
	argMatch(i+10, i+21) then
       begin
	listing[i]   := listing[i+11];
	listing[i+1] := #9'eor (:bp2),y';
	listing[i+2] := listing[i+13];
	listing[i+3] := #9'iny';

	listing[i+4] := listing[i+14];
	listing[i+5] := #9'eor (:bp2),y';
	listing[i+6] := listing[i+16];
	listing[i+7] := #9'iny';

	listing[i+8] := listing[i+17];
	listing[i+9] := #9'eor (:bp2),y';
	listing[i+10]:= listing[i+19];
	listing[i+11]:= #9'iny';

	listing[i+12]:= listing[i+20];
	listing[i+13]:= #9'eor (:bp2),y';
	listing[i+14]:= listing[i+22];

	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';

	exit(false);
       end;


    if and_ora_eor(i+6) and								// and|ora|eor				; 6

       lda_a(i) and									// lda					; 0
       and_ora_eor(i+1) and								// and|ora|eor				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_a(i+3) and									// lda					; 3
       sta_val(i+4) and									// sta					; 4	~sta :STACKORIGN
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
//       and_ora_eor(i+6) and								// and|ora|eor				; 6
       sta_val(i+7) then								// sta					; 7	~sta :STACKORIGN
     if argMatch(i+2, i+5) then
       begin
	listing[i+2] := listing[i+6];

	listing[i+5] := listing[i+3];
	listing[i+6] := listing[i+4];

	listing[i+3] := listing[i+7];
	listing[i+4] := '';

	listing[i+7] := '';

	exit(false);
       end;


    if sta_stack(i) and 								// sta :STACKORIGIN+10			; 0
       lda_a(i+1) and 									// lda 					; 1
       eor_stack(i+2) then								// eor :STACKORIGIN+10			; 2
     if argMatch(i, i+2) then
       begin
	listing[i] := '';
	listing[i+1] := #9'eor ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
       end;


    if (iny(i) = false) and								// iny					; 0
       lda_a(i+1) and									// lda 					; 1
       eor_im_0(i+2) and								// eor #$00				; 2
       sta_a(i+3) then									// sta					; 3
     begin
	listing[i+2] := '';
	exit(false);
     end;


    if (iny(i) = false) and								// iny					; 0
       lda_im_0(i+1) and								// lda #$00				; 1
       eor(i+2) and									// eor					; 2
       sta_a(i+3) then									// sta					; 3
     begin
	listing[i+1] := #9'lda ' + copy(listing[i+2], 6, 256);
	listing[i+2] := '';
	exit(false);
     end;


    if lda_im(i) and									// lda #				; 0
       eor_im(i+1) and									// eor #				; 1
       sta_a(i+2) then									// sta					; 2
     begin
	p := GetBYTE(i) xor GetBYTE(i+1);

	listing[i]   := #9'lda #' + HexByte(p);
	listing[i+1] := '';
	exit(false);
     end;


    if (listing[i] = #9'lda #$FF') and							// lda #$FF				; 0
       sub(i+1) and (sub_im(i+1) = false) and						// sub 					; 1
       ldy(i+2) and									// ldy					; 2
       sta_a(i+3) then									// sta					; 3
     begin
	listing[i+1] := #9'eor ' + copy(listing[i+1], 6, 256);
	exit(false);
     end;


    if (listing[i] = #9'lda #$FF') and							// lda #$FF				; 0
       sub(i+1) and (sub_im(i+1) = false) and						// sub 					; 1
       sta_a(i+2) and									// sta					; 2
											//					; 3
       (sbc(i+4) = false) then								// ~sbc					; 4
     begin
	listing[i+1] := #9'eor ' + copy(listing[i+1], 6, 256);
	exit(false);
     end;

end;		// function
