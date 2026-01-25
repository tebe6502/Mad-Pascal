
function opt_SPL(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===			   SPL. sign number conversion
// -----------------------------------------------------------------------------


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_im(i+1) and (lda_im_0(i+1) = false) and						// lda #				; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) then										// dey					; 3
     begin
	p := GetBYTE(i+1);

	listing[i+2] := '';
	listing[i+3] := '';

	if p > 127 then listing[i] := #9'ldy #$FF';

	exit(false);
     end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       (lda_stack(i+5) or sta_stack(i+5)) then							// lda|sta :STACKORIGIN			; 5
    if argMatch(i+1, i+5) then
     begin
	listing[i+5] := '';

	exit(false);
     end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_a(i+1) and										// lda					; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH		; 5
       (lda_a(i+6) or ldy(i+6)) then								// lda|ldy				; 6
    if argMatch(i+4, i+5) then
     begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
     end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       lda_stack(i+4) then									// lda :STACKORIGIN			; 4
     if listing[i+1] = listing[i+4] then begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       add_sub_val(i+4) and									// add|sub				; 4	~:STACKORIGIN
       sta_stack(i+5) and									// sta :STACKORIGIN+9			; 5
       tya(i+6) and										// tya					; 6
       ldy_stack(i+7) and									// ldy :STACKORIGIN+9			; 7
       (lda(i+8) or mva(i+8)) then								// lda|mva				; 8
     if argMatch(i+5, i+7) then
       begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := '';

	exit(false);
       end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       add_sub(i+4) and										// add|sub				; 4
       and_ora_eor_val(i+5) and									// and|ora|eor				; 5	~:STACKORIGIN
       sta(i+6) then										// sta					; 6
       begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_im_0(i+1) and									// lda #$00				; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH		; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*2	; 6
       sty_stack(i+7) then									// sty :STACKORIGIN+STACKWIDTH*3	; 7
     begin
	listing[i]   := #9'lda #$00';
	listing[i+1] := listing[i+4];
	listing[i+2] := #9'lda #$00';
	listing[i+3] := #9'sta ' + copy(listing[i+5], 6, 256);
	listing[i+4] := #9'lda #$00';
	listing[i+5] := #9'sta ' + copy(listing[i+6], 6, 256);
	listing[i+6] := #9'lda #$00';
	listing[i+7] := #9'sta ' + copy(listing[i+7], 6, 256);

	exit(false);
     end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_im_0(i+1) and									// lda #$00				; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*2	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*3	; 6
       (sta_a(i+7) = false) and (sty(i+7) = false) then						//~sta|sty				; 7
     begin
	listing[i]   := #9'lda #$00';
	listing[i+1] := listing[i+4];
	listing[i+2] := #9'lda #$00';
	listing[i+3] := #9'sta ' + copy(listing[i+5], 6, 256);
	listing[i+4] := #9'lda #$00';
	listing[i+5] := #9'sta ' + copy(listing[i+6], 6, 256);
	listing[i+6] := '';

	exit(false);
     end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN			; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey 					; 3
       sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       mwy_bp2(i+5) and										// mwy xx :bp2				; 5
       ldy_im(i+6) and										// ldy #				; 6
       lda_bp2_y(i+7) and									// lda (:bp2),y				; 7
       add_stack(i+8) then									// add :STACKORIGIN			; 8
     if argMatch(i+1, i+8) then
       begin
	listing[i+7] := #9'add (:bp2),y';
	listing[i+8] := '';

	exit(false);
       end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey 					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH		; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*2	; 6
       sty_stack(i+7) and									// sty :STACKORIGIN+STACKWIDTH*3	; 7
       lda_stack(i+8) and									// lda :STACKORIGIN			; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH		; 9
       lda_a(i+10) then										// lda					; 10
     if argMatch(i+4, i+8) and
        argMatch(i+5, i+9) then
       begin
	listing[i+5] := #9'sta ' + copy(listing[i+5], 6, 256);

	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
       end;


    if spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_stack(i+1) and									// lda :STACKORIGIN+STACKWIDTH		; 1
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey 					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH		; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH*2	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*3	; 6
       lda_a(i+7) and										// lda					; 7
       add_sub_stack(i+8) and									// add|sub :STACKORIGIN+11		; 8
       sta_a(i+9) and										// sta 					; 9
       lda_a(i+10) and										// lda					; 10
       adc_sbc_stack(i+11) and									// adc|sbc :STACKORIGIN+STACKWIDTH	; 11
       sta_a(i+12) and										// sta					; 12
												//					; 13
       (adc_sbc(i+14) = false) then								//~adc|sbc :STACKORIGIN+STACKWIDTH*2	; 14
     if argMatch(i+1, i+4) and
	argMatch(i+4, i+11) then
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


    if spl(i+10) and										// spl					; 10
       spl(i+2) and										// spl					; 2

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_val(i+1) and										// lda CX				; 1	~:STACKORIGIN
//       spl(i+2) and										// spl					; 2
       dey(i+3) and										// dey 					; 3
       sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH		; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*2	; 6
       sty_stack(i+7) and									// sty :STACKORIGIN+STACKWIDTH*3	; 7
       ldy_im_0(i+8) and									// ldy #$00				; 8
       lda_val(i+9) and										// lda CX				; 9	~:STACKORIGIN
//       spl(i+10) and										// spl					; 10
       dey(i+11) and										// dey 					; 11
       sta_stack(i+12) and									// sta :STACKORIGIN			; 12
       sty_stack(i+13) and									// sty :STACKORIGIN+STACKWIDTH		; 13
       sty_stack(i+14) and									// sty :STACKORIGIN+STACKWIDTH*2	; 14
       sty_stack(i+15) then									// sty :STACKORIGIN+STACKWIDTH*3	; 15
     if argMatch(i+1, i+9) then
       begin
	listing[i+8]  := '';
	listing[i+9]  := '';
	listing[i+10] := '';
	listing[i+11] := '';

	exit(false);
       end;


    if spl(i+3) and										// spl					; 3

       sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH		; 0
       ldy_im_0(i+1) and									// ldy #$00				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN			; 2
//       spl(i+3) and										// spl					; 3
       dey(i+4) and										// dey					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       sty_stack(i+6) then									// sty :STACKORIGIN+STACKWIDTH		; 6
     if argMatch(i, i+6) and
	argMatch(i+2, i+5) and
	(argMatch(i, i+2) = false) then
       begin
	listing[i] := '';

	exit(false);
       end;


    if spl(i+3) and										// spl					; 3

       sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH*3+10	; 0
       ldy_im_0(i+1) and									// ldy #$00				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+STACKWIDTH+10	; 2
//       spl(i+3) and										// spl					; 3
       dey(i+4) and										// dey					; 4
       sta_stack(i+5) and									// sta :STACKORIGIN+STACKWIDTH+10	; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*2+10	; 6
       sty_stack(i+7) then									// sty :STACKORIGIN+STACKWIDTH*3+10	; 7
     if argMatch(i, i+7) and
	argMatch(i+2, i+5) and
	(argMatch(i, i+2) = false) then
       begin
	listing[i] := '';

	exit(false);
       end;


    if spl(i+3) and										// spl					; 3

       sta_stack(i) and										// sta :STACKORIGIN+STACKWIDTH+9	; 0
       ldy_im_0(i+1) and									// ldy #$00				; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+9			; 2
//       spl(i+3) and										// spl					; 3
       dey(i+4) and										// dey					; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH+9	; 5
       sta(i+6) and 										// sta A				; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH+9	; 7
       sta(i+8) and (iy(i+8) = false) then							// sta A+1				; 8
     if argMatch(i, i+5) and
	argMatch(i+5, i+7) and
	(argMatch(i, i+2) = false) then
       begin
	listing[i+5] := listing[i+6];
	listing[i+6] := #9'sty ' + copy(listing[i+8], 6, 256);
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
       end;


    if spl(i+4) and										// spl					; 4

       lda(i) and (lda_stack(i) = false) and (iy(i) = false) and				// lda K				; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       ldy_im_0(i+2) and									// ldy #$00				; 2
       lda_val(i+3) and										// lda K+1				; 3	~:STACKORIGIN
//       spl(i+4) and										// spl					; 4
       dey(i+5) and										// dey 					; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH+9	; 6
       sty_stack(i+7) and									// sty :STACKORIGIN+STACKWIDTH*2+9	; 7
       lda(i+8) and										// lda					; 8
       sta(i+9) and										// sta					; 9
       lda(i+10) and										// lda					; 10
       add_sub_stack(i+11) then									// add|sub :STACKORIGIN+9		; 11
     if argMatch(i+1, i+11) then
       begin

	if add_stack(i+11) then
	 listing[i+11] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+11] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if spl(i+4) and										// spl					; 4

       lda(i) and (lda_stack(i) = false) and (iy(i) = false) and				// lda					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_im_0(i+2) and									// ldy #$00				; 2
       lda(i+3) and										// lda					; 3
//       spl(i+4) and										// spl					; 4
       dey(i+5) and										// dey					; 5
       add_sub_val(i+6) and									// add|sub ~:STACKORIGIN		; 6
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN			; 7
       (sta(i+8) or tay(i+8)) then								// sta|tay				; 8
     if argMatch(i+1, i+7) then
       begin

        if add(i+7) then
	 listing[i+7] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+7] := #9'sub ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	listing[i+4] := '';
	listing[i+5] := '';

	exit(false);
       end;


    if spl(i+4) and										// spl					; 4

       (add_sub(i) or and_ora_eor(i)) and (iy(i) = false) and					// add|sub|and|ora|eor			; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_im_0(i+2) and									// ldy #$00				; 2
       lda_stack(i+3) and									// lda :STACKORIGIN			; 3
//       spl(i+4) and										// spl					; 4
       dey(i+5) then										// dey					; 5
     if argMatch(i+1, i+3) then
     begin
	listing[i+3] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
     end;


    if spl(i+4) and										// spl					; 4

       lda_val(i) and (iy(i) = false) and							// lda K				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
       ldy_im_0(i+2) and									// ldy #$00				; 2
       lda_stack(i+3) and									// lda :STACKORIGIN+9			; 3
//       spl(i+4) and										// spl					; 4
       dey(i+5) and										// dey 					; 5
       sta_stack(i+6) then									// sta :STACKORIGIN+9			; 6
     if argMatch(i+1, i+3) and
        argMatch(i+3, i+6) then
       begin
	listing[i+3] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


    if spl(i+4) and										// spl					; 4

       lda_val(i) and (iy(i) = false) and							// lda A				; 0	~:STACKORIGIN
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       ldy_im_0(i+2) and									// ldy #$00				; 2
       lda_a(i+3) and										// lda A+1				; 3
//       spl(i+4) and										// spl					; 4
       dey(i+5) and										// dey 					; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH		; 6
       sta_stack(i+7) and									// sta :STACKORIGIN+STACKWIDTH*2	; 7
       sty_stack(i+8) and									// sty :STACKORIGIN+STACKWIDTH*3	; 8
       lda_stack(i+9) and									// lda :STACKORIGIN			; 9
       sta_stack(i+10) then									// sta :STACKORIGIN+STACKWIDTH		; 10
     if argMatch(i+1, i+9) and
        argMatch(i+6, i+10) and
        (argMatch(i+1, i+3) = false) then
       begin
	listing[i+9] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;



    if spl(i+4) and										// spl					; 4

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_a(i+1) and										// lda 					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       lda_stack(i+3) and									// lda :STACKORIGIN			; 3
//       spl(i+4) and										// spl					; 4
       dey(i+5) and										// dey 					; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH		; 6
       add_sub(i+7) and										// add|sub 				; 7
       sta_val(i+8) and										// sta					; 8	~:STACKORIGIN
       lda_stack(i+9) and									// lda :STACKORIGIN+STACKWIDTH		; 9
       adc_sbc(i+10) then									// adc|sbc 				; 10
     if argMatch(i+2, i+3) and
        argMatch(i+6, i+9) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := '';

	listing[i+9] := #9'tya';

	exit(false);
       end;


    if spl(i+5) and										// spl					; 5

       ldy_im_0(i) and										// ldy #$00				; 0
       lda_a(i+1) and										// lda					; 1
       sta_stack(i+2) and									// sta :STACKORIGIN			; 2
       ldy_im_0(i+3) and									// ldy #$00				; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
//       spl(i+5) and										// spl					; 5
       dey(i+6) then										// dey					; 6
     if argMatch(i+2, i+4) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
     end;


    if spl(i+6) and										// spl					; 6

       lda(i) and (lda_stack(i) = false) and (iy(i) = false) and				// lda 					; 0	~:STACKORIGIN ~lda adr.
       sta_stack(i+1) and		 							// sta :STACKORIGIN+9			; 1
       lda(i+2) and (lda_stack(i+2) = false) and (iy(i+2) = false) and				// lda 					; 2	~:STACKORIGIN ~lda adr.
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       ldy_im_0(i+4) and									// ldy #$00				; 4
       lda(i+5) and										// lda					; 5
//       spl(i+6) and										// spl					; 6
       dey(i+7) and										// dey					; 7
       add_sub_stack(i+8) and									// add|sub :STACKORIGIN+9		; 8
       sta(i+9) and										// sta					; 9
       tya(i+10) and										// tya					; 10
       adc_sbc_stack(i+11) and									// adc|sbc :STACKORIGIN+STACKWIDTH+9	; 11
       sta(i+12) then										// sta :STACKORIGIN+STACKWIDTH+9	; 12
     if argMatch(i+1, i+8) and
	argMatch(i+3, i+11) then
       begin

	if add_stack(i+8) then
	 listing[i+8] := #9'add ' + copy(listing[i], 6, 256)
	else
	 listing[i+8] := #9'sub ' + copy(listing[i], 6, 256);

	if adc_stack(i+11) then
	 listing[i+11] := #9'adc ' + copy(listing[i+2], 6, 256)
	else
	 listing[i+11] := #9'sbc ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if spl(i+12) and										// spl					; 12

       sta_stack(i) and										// sta :STACKORIGIN+9			; 0
       lda_a(i+1) and										// lda					; 1
       adc_sbc(i+2) and										// adc|sbc				; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH+9	; 3
       lda_a(i+4) and										// lda 					; 4
       adc_sbc(i+5) and										// adc|sbc				; 5
       sta_stack(i+6) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 6
       lda_a(i+7) and										// lda 					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH*3+9	; 9
       ldy_im_0(i+10) and									// ldy #$00				; 10
       lda_stack(i+11) and									// lda :STACKORIGIN+9			; 11
//       spl(i+12) and										// spl					; 12
       dey(i+13) and										// dey					; 13
       sta_stack(i+14) and									// sta :STACKORIGIN+9			; 14
       sty_stack(i+15) and									// sty :STACKORIGIN+STACKWIDTH+9	; 15
       sty_stack(i+16) and									// sty :STACKORIGIN+STACKWIDTH*2+9	; 16
       sty_stack(i+17) then									// sty :STACKORIGIN+STACKWIDTH*3+9	; 17
     if argMatch(i, i+11) and
	argMatch(i+11, i+14) and
	argMatch(i+3, i+15) and
	argMatch(i+6, i+16) and
	argMatch(i+9, i+17) then
       begin
	listing[i+1]  := '';
	listing[i+2]  := '';
	listing[i+3]  := '';
	listing[i+4]  := '';
	listing[i+5]  := '';
	listing[i+6]  := '';
	listing[i+7]  := '';
	listing[i+8]  := '';
	listing[i+9]  := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


  if ldy_im_0(i) and										// ldy #$00				; 0
     (lda_a(i+1) or and_ora_eor(i+1)) and							// lda|and|ora|eor			; 1
     spl(i+2) and										// spl					; 2
     dey(i+3) then										// dey					; 3
  begin


    if sta_a(i+4) and										// sta					; 4
       LOCAL(i+5) and										// .LOCAL				; 5
       lda_a(i+6) then										// lda					; 6
     begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if sty(i+4) and										// sty					; 4
       asl_a(i+5) and										// asl @				; 5
       tay(i+6) then										// tay					; 6
     begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
     end;


    if add_sub(i+4) and										// add|sub				; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       tya(i+6) and										// tya					; 6
       adc_sbc(i+7) and										// adc|sbc				; 7
       sta_stack(i+8) and									// sta :STACKORIGIN+STACKWIDTH		; 8
       ldy_stack(i+9) then									// ldy :STACKORIGIN			; 9
     if argMatch(i+5, i+9) then
       begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+5] := #9'tay';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
       end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       asl_stack(i+7) and									// asl :STACKORIGIN			; 7
       rol_a(i+8) and										// rol @				; 8
       sta_stack(i+9) and									// sta :STACKORIGIN+STACKWIDTH		; 9
       ldy_stack(i+10) then									// ldy :STACKORIGIN			; 10
     if argMatch(i+4, i+6) and
        argMatch(i+6, i+9) and
        argMatch(i+5, i+7) and
        argMatch(i+7, i+10) then
       begin
	listing[i]   := listing[i+1];
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'tay';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	exit(false);
       end;


    if sta_stack(i+4) and									// sta :STACKORIGIN			; 4
       sty_stack(i+5) and									// sty :STACKORIGIN+STACKWIDTH		; 5
       sty_stack(i+6) and									// sty :STACKORIGIN+STACKWIDTH*2	; 6
       sty_stack(i+7) and									// sty :STACKORIGIN+STACKWIDTH*3	; 7
       lda_stack(i+8) and									// lda :STACKORIGIN			; 8
       add_sub(i+9) and										// add|sub 				; 9
       sta_val(i+10) and									// sta 					; 10	~:STACKORIGIN
       lda_stack(i+11) and									// lda :STACKORIGIN+STACKWIDTH		; 11
       adc_sbc(i+12) and									// adc|sbc				; 12
       sta(i+13) and										// sta					; 13
												//					; 14
       (adc_sbc(i+15) = false) then								//~adc|sbc 				; 15
     if argMatch(i+4, i+8) and
	argMatch(i+5, i+11) then
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	listing[i+11] := #9'tya';

	exit(false);
       end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       add_sub(i+5) and										// add|sub 				; 5
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH		; 7
       adc_sbc(i+8) then									// adc|sbc 				; 8
     if argMatch(i+4, i+7) then
       begin
	listing[i+4] := '';

	listing[i+7] := #9'tya';

	exit(false);
       end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       add(i+5) and										// add					; 5	!!! add
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       lda(i+7) and										// lda					; 7
       adc_stack(i+8) then									// adc :STACKORIGIN+STACKWIDTH		; 8
     if argMatch(i+4, i+8) then
       begin
	listing[i+4] := '';

	listing[i+8] := #9'adc ' + copy(listing[i+7], 6, 256);
	listing[i+7] := #9'tya';

	exit(false);
       end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta(i+5) and										// sta 					; 5
       sta(i+6) and										// sta 					; 6
       lda_stack(i+7) and									// lda :STACKORIGIN+STACKWIDTH		; 7
       sta(i+8) and 										// sta 					; 8
       sta(i+9) then 										// sta 					; 9
     if argMatch(i+4, i+7) then
     begin
      listing[i+7] := listing[i+6];
      listing[i+6] := listing[i+5];

      listing[i+4] := #9'sty ' + copy(listing[i+8], 6, 256);
      listing[i+5] := #9'sty ' + copy(listing[i+9], 6, 256);

      listing[i+8] := '';
      listing[i+9] := '';

      exit(false);
     end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta_val(i+5) and										// sta					; 5	~sta :STACKORIGN
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH		; 6
       sta_val(i+7) and										// sta 					; 7	~sta :STACKORIGN
       (sta_a(i+8) = false) then								//~sta					; 8
     if argMatch(i+4, i+6) then
       begin
	listing[i+4] := #9'sty ' + copy(listing[i+7], 6, 256);

	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
       end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta_stack(i+5) and 									// sta :STACKORIGIN			; 5
       lda_a(i+6) and										// lda					; 6
       add_sub_stack(i+7) and									// add|sub :STACKORIGIN			; 7
       sta(i+8) and										// sta					; 8
												//					; 9
       (adc_sbc(i+10) = false) then								//~adc|sbc				;10
     if argMatch(i+5, i+7) and
        (argMatch(i+4, i+6) = false) then
       begin
	listing[i+4] := #9'sty #$00';

	exit(false);
       end;


    if sty_stack(i+4) and									// sty :STACKORIGIN+STACKWIDTH		; 4
       sta_stack(i+5) and									// sta :STACKORIGIN			; 5
       lda(i+6) and										// lda					; 6	~lda adr.
       add_stack(i+7) then									// add :STACKORIGIN+STACKWIDTH		; 7
     if argMatch(i+4, i+7) then
       begin
        listing[i+4] := listing[i+5];
	listing[i+5] := #9'tya';
	listing[i+6] := #9'add ' + copy(listing[i+6], 6, 256);
	listing[i+7] := '';

	exit(false);
       end;


    if sta_a(i+4) and										// sta					; 4
       (lda_a(i+5) or asl(i+5) or lsr(i+5)) then						// lda|asl|lsr				; 5
      begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_a(i+4) and										// sta					; 4
       sta_a(i+5) and										// sta					; 5
       (lda_a(i+6) or asl(i+6) or lsr(i+6)) then						// lda|asl|lsr				; 6
      begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if sta_im_0(i+4) and									// sta #$00				; 4
       sty_im_0(i+5) and									// sty #$00				; 5
       sty_im_0(i+6) and									// sty #$00				; 6
       (sta_a(i+7) = false) and (sty(i+7) = false) then						//~sta|sty				; 7
     begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	exit(false);
     end;


    if sta_im_0(i+4) and									// sta #$00				; 4
       (sta_a(i+5) or sty(i+5)) then								// sta|sty				; 5
     begin
	listing[i+4] := '';

	exit(false);
     end;


    if sta_im_0(i+4) and									// sta #$00				; 4
       (sta_a(i+5) = false) and (sty(i+5) = false) then						//~sta|sty				; 5
     begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

	exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       (tya(i+5) or cmp(i+5) or add_sub(i+5) or and_ora_eor(i+5) or SKIP(i+5)) then		// tya|cmp|sub|add|and|ora|eor|SKIP	; 5
     begin
       listing[i] := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       sta_im_0(i+5) and									// sta #$00				; 5
       (sta_a(i+6) = false) then								//~sta					; 6
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       exit(false);
     end;


    if sta_a(i+4) and										// sta					; 4
       sty_im_0(i+5) then									// sty #$00				; 5
     begin
       listing[i+5] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       sta_a(i+5) then										// sta					; 5
     begin
       listing[i+4] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       sty_im_0(i+5) and									// sty #$00				; 5
       (lda_a(i+6) or ldy(i+6) or mwy(i+6)) then						// lda|ldy|mwy				; 6
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       (lda_a(i+5) or ldy(i+5) or mwy(i+5)) then						// lda|ldy|mwy				; 5
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       add_sub(i+5) and										// add|sub				; 5
       sta(i+6) and										// sta					; 6
												//					; 7
       (adc_sbc(i+8) = false) then								//~adc|sbc				; 8
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       add_sub(i+5) and										// add|sub				; 5
       tay(i+6) then										// tay					; 6
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if sty_im_0(i+4) and									// sty #$00				; 4
       add_sub(i+5) and										// add|sub				; 5
       sta(i+6) and										// sta					; 6
       lda(i+7) and										// lda					; 7
       adc_sbc(i+8) and										// adc|sbc				; 8
       sta(i+9) then										// sta					; 9
     begin
       listing[i]   := '';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if sta_a(i+4) and										// sta :STACKORIGIN			; 4
       (mwy(i+5) or ldy(i+5)) then								// mwy|ldy				; 5
      begin
        listing[i]   := '';

        listing[i+2] := '';
        listing[i+3] := '';

        exit(false);
      end;

  end;

end;		// function
