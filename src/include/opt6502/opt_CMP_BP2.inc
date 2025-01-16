
function opt_CMP_BP2(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      CMP :BP2.
// -----------------------------------------------------------------------------

    if mwy_bp2(i) and										// mwy ... :bp2				; 0
       ldy_im_0(i+1) and									// ldy #$00				; 1
       lda_bp2_y(i+2) and									// lda (:bp2),y				; 2
       cmp(i+3) then										// cmp					; 3
     begin
       listing[i+1] := #9'ldy ' + GetString(i);

       listing[i]   := #9'mvy ' + GetString(i) + '+1 :bp+1';
       listing[i+2] := #9'lda (:bp),y';

       exit(false);
     end;


    if lab_a(i+21) and										//@					; 21

       ldy_im(i) and										// ldy #				; 0
       lda_bp2_y(i+1) and 									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       lda_bp2_y(i+4) and 									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       iny(i+6) and										// iny					; 6
       lda_bp2_y(i+7) and 									// lda (:bp2),y				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       iny(i+9) and										// iny					; 9
       lda_bp2_y(i+10) and 									// lda (:bp2),y				; 10
       cmp(i+11) and										// cmp					; 11
       bne_a(i+12) and										// bne @+				; 12
       lda_stack(i+13) and									// lda :STACKORIGIN+STACKWIDTH*2	; 13
       cmp(i+14) and										// cmp					; 14
       bne_a(i+15) and										// bne @+				; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH		; 16
       cmp(i+17) and										// cmp					; 17
       bne_a(i+18) and										// bne @+				; 18
       lda_stack(i+19) and									// lda :STACKORIGIN			; 19
       cmp(i+20) then										// cmp					; 20

    if (copy(listing[i+2], 6, 256) = copy(listing[i+19], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
       (copy(listing[i+8], 6, 256) = copy(listing[i+13], 6, 256)) then
      begin

	if pos(#9'ldy #$', listing[i]) = 1 then begin
          p:=GetBYTE(i) + 3;
	  listing[i] := #9'ldy #$' + IntToHex(p, 2);
	end else
	  listing[i] := #9'ldy ' + copy(listing[i], 6, 256) + '+$03';

	listing[i+1] := #9'lda (:bp2),y';
	listing[i+2] := listing[i+11];
	listing[i+3] := #9'bne @+';
	listing[i+4] := #9'dey';
	listing[i+5] := #9'lda (:bp2),y';
	listing[i+6] := listing[i+14];
	listing[i+7] := #9'bne @+';
	listing[i+8] := #9'dey';
	listing[i+9] := #9'lda (:bp2),y';
	listing[i+10] := listing[i+17];
	listing[i+11] := #9'bne @+';
	listing[i+12] := #9'dey';
	listing[i+13] := #9'lda (:bp2),y';
	listing[i+14] := listing[i+20];

	listing[i+15] := '';
	listing[i+16] := '';
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';

	exit(false);
      end;


    if lab_a(i+19) and										//@					; 19

       ldy_im(i) and										// ldy #				; 0
       lda_bp2_y(i+1) and 									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       lda_bp2_y(i+4) and 									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       iny(i+6) and										// iny					; 6
       lda_bp2_y(i+7) and 									// lda (:bp2),y				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH*2	; 8
       iny(i+9) and										// iny					; 9
       lda_bp2_y(i+10) and 									// lda (:bp2),y				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH*3	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH*3	; 12
       bne(i+13) and										// bne @+				; 13
       lda_stack(i+14) and									// lda :STACKORIGIN+STACKWIDTH*2	; 14
       bne(i+15) and										// bne @+				; 15
       lda_stack(i+16) and									// lda :STACKORIGIN+STACKWIDTH		; 16
       bne(i+17) and										// bne @+				; 17
       lda_stack(i+18) and									// lda :STACKORIGIN			; 18

       (jeq(i+20) or jne(i+20)) and								// jeq|jne				; 20
       (SKIP(i+21) = false) then
    if (copy(listing[i+2], 6, 256) = copy(listing[i+18], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+16], 6, 256)) and
       (copy(listing[i+8], 6, 256) = copy(listing[i+14], 6, 256)) and
       (copy(listing[i+11], 6, 256) = copy(listing[i+12], 6, 256)) then
      begin
        listing[i+2] := '';

        listing[i+4] := #9'ora (:bp2),y';
	listing[i+5] := '';

        listing[i+7] := #9'ora (:bp2),y';
	listing[i+8] := '';

        listing[i+10] := #9'ora (:bp2),y';
	listing[i+11] := '';
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


    if mwy_bp2(i) and (listing[i] = listing[i+4]) and						// mwy P :bp2				; 0
       ldy(i+1) and										// ldy					; 1
       lda_bp2_y(i+2) and									// lda (:bp2),y				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+9			; 3
       mwy_bp2(i+4) and										// mwy P :bp2				; 4
       ldy(i+5) and										// ldy					; 5
       lda_bp2_y(i+6) and									// lda (:bp2),y				; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+10			; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+9			; 8
       cmp_stack(i+9) then									// cmp :STACKORIGIN+10			; 9
    if (copy(listing[i+3], 6, 256) = copy(listing[i+8], 6, 256)) and
       (copy(listing[i+7], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
        listing[i+3] := '';
        listing[i+4] := '';

        listing[i+6] := #9'cmp (:bp2),y';
        listing[i+7] := '';
        listing[i+8] := '';
        listing[i+9] := '';

	exit(false);
      end;


    if ldy(i) and										// ldy					; 0
       lda(i+1) and iy(i+1) and									// lda ,y				; 1	~lda adr.
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       ldy(i+3) and										// ldy					; 3
       lda_a(i+4) and iy(i+4) and								// lda ,y				; 4
       cmp_stack(i+5) then									// cmp :STACKORIGIN+10			; 5
    if (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
        listing[i+2] := listing[i+3];
        listing[i+3] := listing[i+4];
        listing[i+4] := listing[i];
        listing[i+5] := #9'cmp ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
      end;


    if lab_a(i+17) and										//@					; 17

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_bp2_y(i+1) and 									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN+9			; 2
       iny(i+3) and										// iny					; 3
       lda_bp2_y(i+4) and 									// lda (:bp2),y				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       add_sub(i+7) and										// add|sub				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+10			; 8
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       adc_sbc(i+10) and									// adc|sbc				; 10
       sta_stack(i+11) and									// sta :STACKORIGIN+STACKWIDTH+10	; 11
       lda_stack(i+12) and									// lda :STACKORIGIN+STACKWIDTH+10	; 12
       cmp_stack(i+13) and									// cmp :STACKORIGIN+STACKWIDTH+9	; 13
       bne_a(i+14) and										// bne @+				; 14
       lda_stack(i+15) and									// lda :STACKORIGIN+10			; 15
       cmp_stack(i+16) then									// cmp :STACKORIGIN+9			; 16
    if (copy(listing[i+2], 6, 256) = copy(listing[i+16], 6, 256)) and
       (copy(listing[i+5], 6, 256) = copy(listing[i+13], 6, 256)) and
       (copy(listing[i+8], 6, 256) = copy(listing[i+15], 6, 256)) and
       (copy(listing[i+11], 6, 256) = copy(listing[i+12], 6, 256)) then
      begin
	listing[i]   := listing[i+6];
	listing[i+1] := listing[i+7];
	listing[i+2] := listing[i+8];
	listing[i+3] := listing[i+9];
	listing[i+4] := listing[i+10];

	listing[i+5] := #9'ldy #$01';
	listing[i+6] := #9'cmp (:bp2),y';
	listing[i+7] := #9'bne @+';
	listing[i+8] := #9'dey';
	listing[i+9] := listing[i+15];
	listing[i+10]:= #9'cmp (:bp2),y';

	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';
	listing[i+14]:= '';
	listing[i+15]:= '';
	listing[i+16]:= '';

        exit(false);
      end;


    if lab_a(i+9) and										//@					; 9

       ldy_im(i) and										// ldy #				; 0
       lda_bp2_y(i+1) and 									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       lda_bp2_y(i+4) and 									// lda (:bp2),y				; 4
       cmp(i+5) and										// cmp					; 5
       bne_a(i+6) and										// bne @+				; 6
       lda_stack(i+7) and									// lda :STACKORIGIN			; 7
       cmp(i+8) then										// cmp					; 8
//       lab_a(i+9) then									//@					; 9
    if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
      begin

	if pos(#9'ldy #$', listing[i]) = 1 then begin
          p:=GetBYTE(i) + 1;
 	  listing[i] := #9'ldy #$' + IntToHex(p, 2);
	end else
	  listing[i] := #9'ldy ' + copy(listing[i], 6, 256) + '+$01';

	listing[i+1] := #9'lda (:bp2),y';
	listing[i+2] := listing[i+5];
	listing[i+3] := #9'bne @+';
	listing[i+4] := #9'dey';
	listing[i+5] := #9'lda (:bp2),y';
	listing[i+6] := listing[i+8];
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


    if lab_a(i+9) and										//@					; 9

       ldy_im(i) and										// ldy #				; 0
       lda_bp2_y(i+1) and 									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       lda_a(i+4) and 										// lda					; 4
       cmp_bp2_y(i+5) and									// cmp (:bp2),y				; 5
       bne_a(i+6) and										// bne @+				; 6
       lda_a(i+7) and										// lda					; 7
       cmp_stack(i+8) then									// cmp :STACKORIGIN			; 8
//       lab_a(i+9) then									//@					; 9
    if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin

	if pos(#9'ldy #$', listing[i]) = 1 then begin
          p:=GetBYTE(i) + 1;
 	  listing[i] := #9'ldy #$' + IntToHex(p, 2);
	end else
	  listing[i] := #9'ldy ' + copy(listing[i], 6, 256) + '+$01';

	listing[i+1] := listing[i+4];
	listing[i+2] := listing[i+5];
	listing[i+3] := #9'bne @+';
	listing[i+4] := #9'dey';
	listing[i+5] := listing[i+7];
	listing[i+6] := #9'cmp (:bp2),y';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;


    if ldy_im(i) and										// ldy #				; 0
       lda_bp2_y(i+1) and 									// lda (:bp2),y				; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       iny(i+3) and										// iny					; 3
       lda_bp2_y(i+4) and 									// lda (:bp2),y				; 4
       SKIP(i+5) and										// SKIP					; 5
       and_ora_eor_stack(i+6) and								// and|ora|eor :STACKORIGIN		; 6
       SKIP(i+7) then										// SKIP					; 7
    if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
      begin

	if pos(#9'ldy #$', listing[i]) = 1 then begin
          p:=GetBYTE(i) + 1;
 	  listing[i] := #9'ldy #$' + IntToHex(p, 2);
	end else
	  listing[i] := #9'ldy ' + copy(listing[i], 6, 256) + '+$01';

	listing[i+1] := #9'lda (:bp2),y';
	listing[i+2] := listing[i+5];
	listing[i+3] := #9'dey';

	if ora_stack(i+6) then listing[i+4] := #9'ora (:bp2),y' else
	 if eor_stack(i+6) then listing[i+4] := #9'eor (:bp2),y' else
	  listing[i+4] := #9'and (:bp2),y';

	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
      end;

end;		// function