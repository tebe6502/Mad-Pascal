
function opt_STACK_AX_CX(i: integer): Boolean;
var p, q: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				    ADDAX_CX|SUBAX_CX
// -----------------------------------------------------------------------------

    if //inx(i) and										// inx					; 0
       mva_im(i+1) and										// mva # :STACKORIGIN,x			; 1
       mva_im(i+2) and										// mva # :STACKORIGIN+STACKWIDTH,x	; 2
       inx(i+3) and										// inx					; 3
       mva_im(i+4) and										// mva # :STACKORIGIN,x			; 4
       mva_im(i+5) and 										// mva # :STACKORIGIN+STACKWIDTH,x	; 5
       add_sub_AX_CX(i+6) then									// jsr addAX_CX|subAX_CX		; 6
     if stack_0x(i+1) and
     	stack_0x(i+4) and
	stack_1x(i+2) and
	stack_1x(i+5) then
     begin

       p := GetWORD(i+1, i+2);
       q := GetWORD(i+4, i+5);

       if listing[i+6] = #9'jsr addAX_CX' then
        p:=p + q
       else
        p:=p - q;

       listing[i+1] := #9'mva #' + HexByte(p and $ff) + ' :STACKORIGIN,x';
       listing[i+2] := #9'mva #' + HexByte(byte(p shr 8)) + ' :STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva_im(i+1) and										// mva # :STACKORIGIN,x			; 1
       inx(i+2) and										// inx					; 2
       mva_im(i+3) and										// mva # :STACKORIGIN,x			; 3
       mva_im(i+4) and										// mva # :STACKORIGIN-1+STACKWIDTH,x	; 4
       mva_im(i+5) and 										// mva # :STACKORIGIN+STACKWIDTH,x	; 5
       add_sub_AX_CX(i+6) then									// jsr addAX_CX|subAX_CX		; 6
     if stack_0x(i+1) and
     	stack_0x(i+3) and
	stack_prev_1x(i+4) and
	stack_1x(i+5) then
     begin

       p := GetWORD(i+1, i+4);
       q := GetWORD(i+3, i+5);

       if listing[i+6] = #9'jsr addAX_CX' then
        p:=p + q
       else
        p:=p - q;

       listing[i+1] := #9'mva #' + HexByte(p and $ff) + ' :STACKORIGIN,x';
       listing[i+2] := #9'mva #' + HexByte(byte(p shr 8)) + ' :STACKORIGIN+STACKWIDTH,x';

       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := #9'inx';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva  :STACKORIGIN,x			; 1
       inx(i+2) and										// inx					; 2
       mva(i+3) and										// mva  :STACKORIGIN,x			; 3
       mva(i+4) and										// mva  :STACKORIGIN+STACKWIDTH,x	; 4
       mva(i+5) and 										// mva  :STACKORIGIN-1+STACKWIDTH,x	; 5
       add_sub_AX_CX(i+6) and									// jsr addAX_CX|subAX_CX		; 6
       dex(i+7) then										// dex					; 7
     if stack_0x(i+1) and
     	stack_0x(i+3) and
	stack_1x(i+4) and
	stack_prev_1x(i+5) then
     begin

       listing[i+1] := #9'lda ' + GetString(i+1);

       if listing[i+6] = #9'jsr addAX_CX' then
        listing[i+2] := #9'add ' + GetString(i+3)
       else
        listing[i+2] := #9'sub ' + GetString(i+3);

       listing[i+3] := #9'sta :STACKORIGIN,x';

       tmp:=GetString(i+4);

       listing[i+4] := #9'lda ' + GetString(i+5);

       if listing[i+6] = #9'jsr addAX_CX' then
        listing[i+5] := #9'adc ' + tmp
       else
        listing[i+5] := #9'sbc ' + tmp;

       listing[i+6] := #9'sta :STACKORIGIN+STACKWIDTH,x';

       listing[i+7] :='';

       exit(false);
     end;


    if mva(i) and (mva_im(i) = false) and							// mva  :STACKORIGIN,x			; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       inx(i+2) and  										// inx					; 2
       mva(i+3) and 										// mva  :STACKORIGIN,x			; 3
       mva(i+4) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 4
       add_sub_AX_CX(i+5) and									// jsr addAX_CX|subAX_CX		; 5
       dex(i+6) then										// dex					; 6
     if stack_0x(i) and
     	stack_0x(i+3) and
     	stack_1x(i+1) and
     	stack_1x(i+4) then
     begin

       tmp:=listing[i+3];

       listing[i]   := #9'lda ' + GetString(i);

       listing[i+3] := #9'lda ' + GetString(i+1);

       listing[i+2] := #9'sta :STACKORIGIN,x';

       if listing[i+5] = #9'jsr addAX_CX' then begin
	listing[i+1] := #9'add ' + GetString(tmp);
	listing[i+4] := #9'adc ' + GetString(i+4);
       end else begin
	listing[i+1] := #9'sub ' + GetString(tmp);
	listing[i+4] := #9'sbc ' + GetString(i+4);
       end;

       listing[i+5] := #9'sta :STACKORIGIN+STACKWIDTH,x';
       listing[i+6] :='';

       exit(false);
     end;


    if (mva(i) = false) and									//~mva					; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       inx(i+2) and  										// inx					; 2
       mva(i+3) and 										// mva  :STACKORIGIN,x			; 3
       mva(i+4) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 4
       add_sub_AX_CX(i+5) and									// jsr addAX_CX|subAX_CX		; 5
       dex(i+6) then										// dex					; 6
     if	stack_0x(i+3) and
     	stack_1x(i+1) and
     	stack_1x(i+4) then
     begin

       tmp:=listing[i+4];

       listing[i+4] := #9'lda ' + GetString(i+1);

       listing[i+1] := #9'lda :STACKORIGIN,x';

       if listing[i+5] = #9'jsr addAX_CX' then begin
	listing[i+2] := #9'add ' + GetString(i+3);
	listing[i+5] := #9'adc ' + GetString(tmp);
       end else begin
	listing[i+2] := #9'sub ' + GetString(i+3);
	listing[i+5] := #9'sbc ' + GetString(tmp);
       end;

       listing[i+3] := #9'sta :STACKORIGIN,x';

       listing[i+6] := #9'sta :STACKORIGIN+STACKWIDTH,x';

       exit(false);
     end;


    if mva(i) and										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and 										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 3
       inx(i+4) and										// inx					; 4
       mva(i+5) and 										// mva  :STACKORIGIN,x			; 5
       mva(i+6) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 6
       mva(i+7) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 7
       mva(i+8) and										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 8
       ADD_SUB_AX_CX(i+9) then									// jsr addAX_CX|subAX_CX		; 9
     if	stack_2x(i+2) and
	stack_3x(i+3) and

	stack_2x(i+7) and
	stack_3x(i+8) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+7] := '';
	listing[i+8] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva  :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 2
       inx(i+3) and										// inx					; 3
       mva(i+4) and										// mva  :STACKORIGIN,x			; 4
       mva(i+5) and										// mva  :STACKORIGIN+STACKWIDTH,x	; 5
       add_sub_AX_CX(i+6) and									// jsr addAX_CX|subAX_CX		; 6
       (dex(i+7) = false) then									//~dex					; 7
     if stack_0x(i+1) and
     	stack_0x(i+4) and
	stack_1x(i+2) and
	stack_1x(i+5) then
     begin

	Expand(i+6, 1);

	listing_tmp[0] := #9'inx';
	listing_tmp[1] := #9'inx';
	listing_tmp[2] := #9'lda ' + GetSTRING(i+1);

	if listing[i+7] = #9'jsr addAX_CX' then begin
	 listing_tmp[3] := #9'add ' + GetSTRING(i+4);
	 listing_tmp[6] := #9'adc ' + GetSTRING(i+5)
	end else begin
	 listing_tmp[3] := #9'sub ' + GetSTRING(i+4);
	 listing_tmp[6] := #9'sbc ' + GetSTRING(i+5);
	end;

	listing_tmp[4] :=  #9'sta :STACKORIGIN-1,x';
	listing_tmp[5] :=  #9'lda ' + GetSTRING(i+2);

	listing_tmp[7] :=  #9'sta :STACKORIGIN-1+STACKWIDTH,x';

	for p:=0 to 7 do listing[i+p] := listing_tmp[p];

        exit(false);
     end;


    if inx(i) and										// inx					; 0
       mwy(i+1) and										// mwy					; 1
       ldy_im(i+2) and										// ldy #				; 2
       mva(i+3) and										// mva  :STACKORIGIN,x			; 3
       mva(i+4) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 4
       inx(i+5) and										// inx					; 5
       mva(i+6) and										// mva  :STACKORIGIN,x			; 6
       mva(i+7) and										// mva  :STACKORIGIN+STACKWIDTH,x	; 7
       add_sub_AX_CX(i+8) and									// jsr addAX_CX|subAX_CX		; 8
       (dex(i+9) = false) then									//~dex					; 9
     if stack_0x(i+3) and
     	stack_0x(i+6) and
	stack_1x(i+4) and
	stack_1x(i+7) then
     begin

	Expand(i+8, 1);

	listing_tmp[0] := #9'inx';
	listing_tmp[1] := #9'inx';
        listing_tmp[2] := listing[i+1];
        listing_tmp[3] := listing[i+2];
	listing_tmp[4] :=  #9'lda ' + GetSTRING(i+3);

	if listing[i+9] = #9'jsr addAX_CX' then begin
	 listing_tmp[5] := #9'add ' + GetSTRING(i+6);
	 listing_tmp[8] := #9'adc ' + GetSTRING(i+7)
	end else begin
	 listing_tmp[5] := #9'sub ' + GetSTRING(i+6);
	 listing_tmp[8] := #9'sbc ' + GetSTRING(i+7);
	end;

	listing_tmp[6] :=  #9'sta :STACKORIGIN-1,x';
	listing_tmp[7] :=  #9'lda ' + GetSTRING(i+4);

	listing_tmp[9] :=  #9'sta :STACKORIGIN-1+STACKWIDTH,x';

	for p:=0 to 9 do listing[i+p] := listing_tmp[p];

        exit(false);
     end;


    if lda_val(i) and										// lda					; 0	~:STACKORIGIN
       sta_stack_prev_0x(i+1) and								// sta :STACKORIGIN-1,x			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_stack_prev_1x(i+3) and								// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       mva(i+4) and										// mva  :STACKORIGIN,x			; 4
       mva(i+5) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 5
       add_sub_AX_CX(i+6) and									// jsr addAX_CX|subAX_CX		; 6
       dex(i+7) then										// dex					; 7
     if stack_0x(i+4) and
	stack_1x(i+5) then
     begin

       listing[i+3] := listing[i+2];

       if listing[i+6] = #9'jsr addAX_CX' then begin
        listing[i+1] := #9'add ' + GetString(i+4);
        listing[i+4] := #9'adc ' + GetString(i+5);
       end else begin
        listing[i+1] := #9'sub ' + GetString(i+4);
        listing[i+4] := #9'sbc ' + GetString(i+5);
       end;

       listing[i+2] := #9'sta :STACKORIGIN-1,x';

       listing[i+5] := #9'sta :STACKORIGIN-1+STACKWIDTH,x';
       listing[i+6] := '';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if mva(i) and 										// mva .. :STACKORIGIN,x		; 0
       mva(i+1) and										// mva .. :STACKORIGIN+STACKWIDTH,x	; 1
       add_sub_AX_CX(i+2) and									// jsr addAX_CX|subAX_CX		; 2
       dex(i+3) and										// dex					; 3
       lda_stack_0x(i+4) and									// lda :STACKORIGIN,x			; 4
       sta_a(i+5) and										// sta					; 5
       lda_stack_1x(i+6) and									// lda :STACKORIGIN+STACKWIDTH,x	; 6
       sta_a(i+7) then										// sta					; 7
     if stack_0x(i) and
	stack_1x(i+1) then
     begin

       tmp:=listing[i+1];

       if listing[i+2] = #9'jsr addAX_CX' then begin
	listing[i+1] := #9'lda :STACKORIGIN-1,x';
	listing[i+2] := #9'add ' + GetSTRING(i);
	listing[i+3] := #9'sta ' + copy(listing[i+5], 6, 256);
	listing[i+4] := #9'lda :STACKORIGIN-1+STACKWIDTH,x';
	listing[i+5] := #9'adc ' + GetSTRING(tmp);
	listing[i+6] := #9'sta ' + copy(listing[i+7], 6, 256);
       end else begin
	listing[i+1] := #9'lda :STACKORIGIN-1,x';
	listing[i+2] := #9'sub ' + GetSTRING(i);
	listing[i+3] := #9'sta ' + copy(listing[i+5], 6, 256);
	listing[i+4] := #9'lda :STACKORIGIN-1+STACKWIDTH,x';
	listing[i+5] := #9'sbc ' + GetSTRING(tmp);
	listing[i+6] := #9'sta ' + copy(listing[i+7], 6, 256);
       end;

       listing[i] := '';

       listing[i+7] := #9'dex';

       exit(false);
     end;


    if jsr(i) and										// jsr					; 0
       mva_im_0(i+1) and stack_prev_1x(i+1) and							// mva #$00 :STACKORIGIN-1+STACKWIDTH,x	; 1
       mva_im_0(i+2) and stack_1x(i+2) and							// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 2
       add_sub_AX_CX(i+3) and									// jsr addAX_CX|subAX_CX		; 3
       dex(i+4) and										// dex					; 4
       lda_stack_0x(i+5) and									// lda :STACKORIGIN,x			; 5
       sta_a(i+6) and										// sta					; 6
       lda_stack_1x(i+7) and									// lda :STACKORIGIN+STACKWIDTH,x	; 7
       sta_a(i+8) then										// sta					; 8
     begin

       if listing[i+3] = #9'jsr addAX_CX' then begin
	listing[i+1] := #9'lda :STACKORIGIN-1,x';
	listing[i+2] := #9'add :STACKORIGIN,x';
	listing[i+3] := #9'sta ' + copy(listing[i+6], 6, 256);
	listing[i+4] := #9'lda #$00';
	listing[i+5] := #9'adc #$00';
	listing[i+6] := #9'sta ' + copy(listing[i+8], 6, 256);
       end else begin
	listing[i+1] := #9'lda :STACKORIGIN-1,x';
	listing[i+2] := #9'sub :STACKORIGIN,x';
	listing[i+3] := #9'sta ' + copy(listing[i+6], 6, 256);
	listing[i+4] := #9'lda #$00';
	listing[i+5] := #9'sbc #$00';
	listing[i+6] := #9'sta ' + copy(listing[i+8], 6, 256);
       end;

       listing[i+7] := #9'dex';
       listing[i+8] := '';

       exit(false);
     end;


    if jsr(i) and										// jsr					; 0
       inx(i+1) and										// inx					; 1
       mva(i+2) and										// mva ... :STACKORIGIN,x		; 2
       mva_im_0(i+3) and stack_1x(i+3) and							// mva #$00 :STACKORIGIN+STACKWIDTH,x	; 3
       mva_im_0(i+4) and stack_prev_1x(i+4) and							// mva #$00 :STACKORIGIN-1+STACKWIDTH,x	; 4
       add_sub_AX_CX(i+5) and									// jsr addAX_CX|subAX_CX		; 5
       dex(i+6) and										// dex					; 6
       lda_stack_0x(i+7) and									// lda :STACKORIGIN,x			; 7
       sta_a(i+8) and										// sta					; 8
       lda_stack_1x(i+9) and									// lda :STACKORIGIN+STACKWIDTH,x	; 9
       sta_a(i+10) then										// sta					; 10
     if stack_0x(i+2) then
     begin

       if listing[i+5] = #9'jsr addAX_CX' then begin
	listing[i+3] := #9'add ' + GetString(i+2);

	listing[i+2] := #9'lda :STACKORIGIN-1,x';

	listing[i+4] := #9'sta ' + copy(listing[i+8], 6, 256);
	listing[i+5] := #9'lda #$00';
	listing[i+6] := #9'adc #$00';
	listing[i+7] := #9'sta ' + copy(listing[i+10], 6, 256);
       end else begin
	listing[i+3] := #9'sub ' + GetString(i+2);

	listing[i+2] := #9'lda :STACKORIGIN-1,x';

	listing[i+4] := #9'sta ' + copy(listing[i+8], 6, 256);
	listing[i+5] := #9'lda #$00';
	listing[i+6] := #9'sbc #$00';
	listing[i+7] := #9'sta ' + copy(listing[i+10], 6, 256);
       end;

       listing[i+8]  := #9'dex';
       listing[i+9]  := '';
       listing[i+10] := '';

       exit(false);
     end;


    if (mva(i) = false) and									// ~mva					; 0
       inx(i+1) and										// inx					; 1
       mva(i+2) and 										// mva  :STACKORIGIN,x			; 2
       mva(i+3) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 3
       mva(i+4) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 4
       mva(i+5) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 5
       ADD_SUB_AX_CX(i+6) and									// jsr addAX_CX|subAX_CX		; 6
       dex(i+7) and										// dex					; 7
       lda_stack_0x(i+8) and									// lda :STACKORIGIN,x			; 8
       sta_a(i+9) and										// sta A				; 9
       lda_stack_1x(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_a(i+11) then										// sta A+1				; 11
     if stack_0x(i+2) and
	stack_1x(i+3) and
	stack_2x(i+4) and
	stack_3x(i+5) then
     begin

	if (listing[i+6] = #9'jsr addAX_CX') then begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'add ' + GetString(i+2);
	 listing_tmp[2] := listing[i+9];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'adc ' + GetString(i+3);
	 listing_tmp[5] := listing[i+11];
	end else begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'sub ' + GetString(i+2);
	 listing_tmp[2] := listing[i+9];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'sbc ' + GetString(i+3);
	 listing_tmp[5] := listing[i+11];
	end;

	listing[i+1] := listing_tmp[0];
	listing[i+2] := listing_tmp[1];
	listing[i+3] := listing_tmp[2];
	listing[i+4] := listing_tmp[3];
	listing[i+5] := listing_tmp[4];
	listing[i+6] := listing_tmp[5];

	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

       exit(false);
     end;


    if (inx(i) = false) and									//~inx					; 0
       mva(i+1) and 										// mva  :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 2
       mva(i+3) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 3
       mva(i+4) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 4
       ADD_SUB_AX_CX(i+5) and									// jsr addAX_CX|subAX_CX		; 5
       dex(i+6) and										// dex					; 6
       ldy_stack_prev_0x(i+7) and								// ldy :STACKORIGIN-1,x			; 7
       lda_stack_0x(i+8) and									// lda :STACKORIGIN,x			; 8
       sta_a(i+9) and										// sta 					; 9
       lda_stack_1x(i+10) and									// lda :STACKORIGIN+STACKWIDTH,x	; 10
       sta_a(i+11) then										// sta 					; 11
     if stack_0x(i+1) and
	stack_1x(i+2) and
	stack_2x(i+3) and
	stack_3x(i+4) then
     begin

	if (listing[i+5] = #9'jsr addAX_CX') then begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'add ' + GetString(i+1);
	 listing_tmp[2] := listing[i+9];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'adc ' + GetString(i+2);
	 listing_tmp[5] := listing[i+11];
	end else begin
	 listing_tmp[0] := #9'lda :STACKORIGIN,x';
	 listing_tmp[1] := #9'sub ' + GetString(i+1);
	 listing_tmp[2] := listing[i+9];
	 listing_tmp[3] := #9'lda :STACKORIGIN+STACKWIDTH,x';
	 listing_tmp[4] := #9'sbc ' + GetString(i+2);
	 listing_tmp[5] := listing[i+11];
	end;

	listing[i+1] := #9'dex';
	listing[i+2] := #9'ldy :STACKORIGIN-1,x';
	listing[i+3] := listing_tmp[0];
	listing[i+4] := listing_tmp[1];
	listing[i+5] := listing_tmp[2];
	listing[i+6] := listing_tmp[3];
	listing[i+7] := listing_tmp[4];
	listing[i+8] := listing_tmp[5];

	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';

       exit(false);
     end;


    if (inx(i) = false) and									//~inx					; 0
       lda_val(i+1) and										// lda ~:STACKORIGIN			; 1
       sta_stack_prev_0x(i+2) and								// sta :STACKORIGIN-1,x			; 2
       lda_val(i+3) and										// lda ~:STACKORIGIN			; 3
       sta_stack_prev_1x(i+4) and								// sta :STACKORIGIN-1+STACKWIDTH,x	; 4
       mva(i+5) and 										// mva  :STACKORIGIN,x			; 5
       mva(i+6) and 										// mva  :STACKORIGIN+STACKWIDTH,x	; 6
       mva(i+7) and										// mva  :STACKORIGIN+STACKWIDTH*2,x	; 7
       mva(i+8) and 										// mva  :STACKORIGIN+STACKWIDTH*3,x	; 8
       ADD_SUB_AX_CX(i+9) and									// jsr addAX_CX|subAX_CX		; 9
       dex(i+10) then										// dex					; 10
     if stack_0x(i+5) and
	stack_1x(i+6) and
	stack_2x(i+7) and
	stack_3x(i+8) then
     begin

	if (listing[i+9] = #9'jsr addAX_CX') then begin
	 listing_tmp[0] := listing[i+1];
	 listing_tmp[1] := #9'add ' + GetString(i+5);
	 listing_tmp[2] := #9'sta :STACKORIGIN,x';
	 listing_tmp[3] := listing[i+3];
	 listing_tmp[4] := #9'adc ' + GetString(i+6);
	 listing_tmp[5] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	end else begin
	 listing_tmp[0] := listing[i+1];
	 listing_tmp[1] := #9'sub ' + GetString(i+5);
	 listing_tmp[2] := #9'sta :STACKORIGIN,x';
	 listing_tmp[3] := listing[i+3];
	 listing_tmp[4] := #9'sbc ' + GetString(i+6);
	 listing_tmp[5] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	end;

	listing[i+1] := #9'dex';
	listing[i+2] := listing_tmp[0];
	listing[i+3] := listing_tmp[1];
	listing[i+4] := listing_tmp[2];
	listing[i+5] := listing_tmp[3];
	listing[i+6] := listing_tmp[4];
	listing[i+7] := listing_tmp[5];

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if //dex(i) and										// dex					; 0
       lda_a(i+1) and										// lda					; 1
       sta_stack_prev_0x(i+2) and								// sta :STACKORIGIN-1,x			; 2
       lda_a(i+3) and										// lda					; 3
       sta_stack_prev_1x(i+4) and								// sta :STACKORIGIN-1+STACKWIDTH,x	; 4
       lda_a(i+5) and										// lda					; 5
       sta_stack_prev_2x(i+6) and								// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 6
       lda_a(i+7) and										// lda					; 7
       sta_stack_prev_3x(i+8) and								// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 8
       mva(i+9) and 										// mva   :STACKORIGIN,x			; 9
       mva(i+10) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 10
       add_sub_AX_CX(i+11) and									// jsr addAX_CX|subAX_CX		; 11
       dex(i+12) then										// dex					; 12
     if stack_0x(i+9) and
	stack_1x(i+10) then
     begin

       listing[i+4] := listing[i+3];

       if listing[i+11] = #9'jsr addAX_CX' then begin
         listing[i+2] := #9'add ' + GetString(i+9);
         listing[i+5] := #9'adc ' + GetString(i+10);
       end else begin
         listing[i+2] := #9'sub ' + GetString(i+9);
         listing[i+5] := #9'sbc ' + GetString(i+10);
       end;

       listing[i+3] := #9'sta :STACKORIGIN-1,x';

       listing[i+6] := #9'sta :STACKORIGIN-1+STACKWIDTH,x';

       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';
       listing[i+10]:= '';
       listing[i+11]:= '';

       exit(false);
     end;


    if //dex(i) and										// dex					; 0
       lda_a(i+1) and										// lda					; 1
       sta_stack_0x(i+2) and									// sta :STACKORIGIN,x			; 2
       lda_a(i+3) and										// lda					; 3
       sta_stack_1x(i+4) and									// sta :STACKORIGIN+STACKWIDTH,x	; 4
       lda_a(i+5) and										// lda					; 5
       sta_stack_2x(i+6) and									// sta :STACKORIGIN+STACKWIDTH*2,x	; 6
       lda_a(i+7) and										// lda					; 7
       sta_stack_3x(i+8) and									// sta :STACKORIGIN+STACKWIDTH*3,x	; 8
       inx(i+9) and										// inx					; 9
       mva(i+10) and 										// mva   :STACKORIGIN,x			; 10
       mva(i+11) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 11
       add_sub_AX_CX(i+12) and									// jsr addAX_CX|subAX_CX		; 12
       dex(i+13) then										// dex					; 13
     if stack_0x(i+10) and
	stack_1x(i+11) then
     begin

       listing[i+4] := listing[i+3];

       if listing[i+12] = #9'jsr addAX_CX' then begin
         listing[i+2] := #9'add ' + GetString(i+10);
         listing[i+5] := #9'adc ' + GetString(i+11);
       end else begin
         listing[i+2] := #9'sub ' + GetString(i+10);
         listing[i+5] := #9'sbc ' + GetString(i+11);
       end;

       listing[i+3] := #9'sta :STACKORIGIN,x';

       listing[i+6] := #9'sta :STACKORIGIN+STACKWIDTH,x';

       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';
       listing[i+10]:= '';
       listing[i+11]:= '';
       listing[i+12]:= '';
       listing[i+13]:= '';

       exit(false);
     end;


// -----------------------------------------------------------------------------


    if dex(i+9) and										// dex					; 9

       lda_a(i+1) and										// lda					; 1
       sta_stack_prev_0x(i+2) and								// sta :STACKORIGIN-1,x			; 2
       lda_a(i+3) and										// lda					; 3
       sta_stack_prev_1x(i+4) and								// sta :STACKORIGIN-1+STACKWIDTH,x	; 4
       lda_a(i+5) and										// lda					; 5
       sta_stack_prev_2x(i+6) and								// sta :STACKORIGIN-1+STACKWIDTH*2,x	; 6
       lda_a(i+7) and										// lda					; 7
       sta_stack_prev_3x(i+8) then								// sta :STACKORIGIN-1+STACKWIDTH*3,x	; 8
    begin


    if inx(i+10) and										// inx					; 10
       mva(i+11) and 										// mva   :STACKORIGIN,x			; 11
       mva(i+12) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 12
       add_sub_AX_CX(i+13) and									// jsr addAX_CX|subAX_CX		; 13
       dex(i+14) then										// dex					; 14
     if stack_0x(i+11) and
	stack_1x(i+12) then
     begin
       listing[i+7] := #9'dex';

       if listing[i+13] = #9'jsr addAX_CX' then begin
         listing[i+8]  := listing[i+1];
         listing[i+9]  := #9'add ' + GetString(i+11);
         listing[i+10] := #9'sta :STACKORIGIN,x';
         listing[i+11] := listing[i+3];
         listing[i+12] := #9'adc ' + GetString(i+12);
         listing[i+13] := #9'sta :STACKORIGIN+STACKWIDTH,x';
       end else begin
         listing[i+8]  := listing[i+1];
         listing[i+9]  := #9'sub ' + GetString(i+11);
         listing[i+10] := #9'sta :STACKORIGIN,x';
         listing[i+11] := listing[i+3];
         listing[i+12] := #9'sbc ' + GetString(i+12);
         listing[i+13] := #9'sta :STACKORIGIN+STACKWIDTH,x';
       end;

       listing[i+14] := '';

       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if inx(i+10) and										// inx					; 10
       mva(i+11) and 										// mva   :STACKORIGIN,x			; 11
       mva(i+12) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 12
       mva(i+13) and 										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 13
       mva(i+14) and 										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 14
       add_sub_AX_CX(i+15) and									// jsr addAX_CX|subAX_CX		; 15
       dex(i+16) then										// dex					; 16
     if stack_0x(i+11) and
	stack_1x(i+12) and
	stack_2x(i+13) and
	stack_3x(i+14) then
     begin
       listing[i+7] := #9'dex';

       if listing[i+15] = #9'jsr addAX_CX' then begin
         listing[i+8]  := listing[i+1];
         listing[i+9]  := #9'add ' + GetString(i+11);
         listing[i+10] := #9'sta :STACKORIGIN,x';
         listing[i+11] := listing[i+3];
         listing[i+12] := #9'adc ' + GetString(i+12);
         listing[i+13] := #9'sta :STACKORIGIN+STACKWIDTH,x';
       end else begin
         listing[i+8]  := listing[i+1];
         listing[i+9]  := #9'sub ' + GetString(i+11);
         listing[i+10] := #9'sta :STACKORIGIN,x';
         listing[i+11] := listing[i+3];
         listing[i+12] := #9'sbc ' + GetString(i+12);
         listing[i+13] := #9'sta :STACKORIGIN+STACKWIDTH,x';
       end;

       listing[i+14] := '';
       listing[i+15] := '';
       listing[i+16] := '';

       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if mva(i+10) and 										// mva   :STACKORIGIN-1+STACKWIDTH*2,x	; 10
       mva(i+11) and 										// mva   :STACKORIGIN-1+STACKWIDTH*3,x	; 11
       add_sub_AX_CX(i+12) and									// jsr addAX_CX|subAX_CX		; 12
       dex(i+13) then										// dex					; 13
     if stack_prev_2x(i+10) and
	stack_prev_3x(i+11) then
     begin
       listing[i+6] := #9'dex';

       if listing[i+12] = #9'jsr addAX_CX' then begin
         listing[i+7]  := #9'lda :STACKORIGIN-1,x';
         listing[i+8]  := #9'add ' + GetString(i+1);
         listing[i+9]  := #9'sta :STACKORIGIN-1,x';
         listing[i+10] := #9'lda :STACKORIGIN-1+STACKWIDTH,x';
         listing[i+11] := #9'adc ' + GetString(i+3);
         listing[i+12] := #9'sta :STACKORIGIN-1+STACKWIDTH,x';
       end else begin
         listing[i+7]  := #9'lda :STACKORIGIN-1,x';
         listing[i+8]  := #9'sub ' + GetString(i+1);
         listing[i+9]  := #9'sta :STACKORIGIN-1,x';
         listing[i+10] := #9'lda :STACKORIGIN-1+STACKWIDTH,x';
         listing[i+11] := #9'sbc ' + GetString(i+3);
         listing[i+12] := #9'sta :STACKORIGIN-1+STACKWIDTH,x';
       end;

       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4]:= '';
       listing[i+5]:= '';

       exit(false);
     end;


    end;


end;		// function
