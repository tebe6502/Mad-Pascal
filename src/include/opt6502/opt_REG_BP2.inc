
procedure opt_REG_BP2;
var i, k: integer;
begin

// -------------------------------------------------------------------------- //
//				     REG BP2.
// -------------------------------------------------------------------------- //

  Rebuild;

  i:=0;
  k:=0;

  while i < l do begin

//   if listing[i]<>'' then
    if mwy_bp2(i)							// mwy a bp2				; 0

       or

       ( sta_bp2_1(i+5) and						// sta :bp2+1				; 5			// +

	 lda_a(i) and							// lda TEXT_BUF				; 0
         add(i+1) and (add_stack(i+1) = false) and			// add R				; 1
	 sta_bp2(i+2) and						// sta :bp2				; 2
	 (listing[i+3] = listing[i] + '+1') and				// lda TEXT_BUF+1			; 3
	 adc(i+4) )							// adc R+1				; 4
//	 sta_bp2_1(i+5) )						// sta :bp2+1				; 5

       or

       ( sta_bp_1(i+5) and						// sta :bp+1				; 5

	 lda_a(i) and							// lda TEXT_BUF				; 0
         add(i+1) and (add_stack(i+1) = false) and			// add R				; 1
	 tay(i+2) and							// tay					; 2
	 (listing[i+3] = listing[i] + '+1') and				// lda TEXT_BUF+1			; 3
	 adc(i+4) and							// adc R+1				; 4
//	 sta_bp_1(i+5) and						// sta :bp+1				; 5
	 lda_bp_y(i+6) )						// lda (:bp),y				; 6

       or

       ( sta_bp2_1(i+9) and						// sta :bp2+1				; 9			// %

	 lda_val(i) and							// lda P+1				; 0	~:STACKORIGIN
         sta_stack(i+1) and 						// sta :STACKORIGIN+STACKWIDTH		; 1
	 lda_a(i+2) and (listing[i] = listing[i+2] + '+1') and		// lda P				; 2
	 asl_a(i+3) and							// asl @				; 3
	 rol_stack(i+4) and						// rol :STACKORIGIN+STACKWIDTH		; 4
	 add(i+5) and (add_stack(i+5) = false) and			// add RSON				; 5
	 sta_bp2(i+6) and						// sta :bp2				; 6
	 lda_a(i+7) and							// lda RSON+1				; 7
	 adc_stack(i+8) and						// adc :STACKORIGIN+STACKWIDTH		; 8
//	 sta_bp2_1(i+9) and						// sta :bp2+1				; 9
         (copy(listing[i+7], 6, 256) = copy(listing[i+5], 6, 256) + '+1') and
         argMatch(i+1, i+4) and
	 argMatch(i+1, i+8) )

       or

       ( sta_bp2_1(i+11) and						// sta :bp2+1				; 11			// &

	 lda_val(i) and							// lda P				; 0	~:STACKORIGIN
         sta_stack(i+1) and 						// sta :STACKORIGIN			; 1
	 lda_a(i+2) and (listing[i+2] = listing[i] + '+1') and		// lda P+1				; 2
	 asl_stack(i+3) and						// asl :STACKORIGIN			; 3
	 rol_a(i+4) and							// rol @				; 4
	 sta_stack(i+5) and						// sta :STACKORIGIN+STACKWIDTH		; 5
	 lda_a(i+6) and							// lda RSON				; 6
	 add_stack(i+7) and						// add :STACKORIGIN			; 7
	 sta_bp2(i+8) and						// sta :bp2				; 8
	 lda_a(i+9) and							// lda RSON+1				; 9
	 adc_stack(i+10) and						// adc :STACKORIGIN+STACKWIDTH		; 10
//	 sta_bp2_1(i+11) and						// sta :bp2+1				; 11
         (copy(listing[i+9], 6, 256) = copy(listing[i+6], 6, 256) + '+1') and
         argMatch(i+1, i+3) and
	 argMatch(i+1, i+7) and
	 argMatch(i+5, i+10) )

	or

       ( sta_bp2_1(i+17) and						// sta :bp2+1				; 17			// ]

	 lda_val(i) and							// lda P				; 0	~:STACKORIGIN
         sta_stack(i+1) and 						// sta :STACKORIGIN			; 1
	 lda_a(i+2) and (listing[i+2] = listing[i] + '+1') and		// lda P+1				; 2
	 asl_stack(i+3) and						// asl :STACKORIGIN			; 3
	 rol_a(i+4) and							// rol @				; 4
	 sta_stack(i+5) and						// sta :STACKORIGIN+STACKWIDTH		; 5
	 lda_stack(i+6) and						// lda :STACKORIGIN			; 6
	 add(i+7) and							// add RSON				; 7
	 sta_tmp(i+8) and						// sta :TMP				; 8
	 lda_stack(i+9) and						// lda :STACKORIGIN+STACKWIDTH		; 9
	 adc(i+10) and							// adc RSON+1				; 10
	 sta_tmp_1(i+11) and						// sta :TMP+1				; 11
	 ldy_im_0(i+12) and						// ldy #$00				; 12
	 lda_tmp_y(i+13) and						// lda (:TMP),y				; 13
	 sta_bp2(i+14) and						// sta :bp2				; 14
	 iny(i+15) and							// iny					; 15
	 lda_tmp_y(i+16) and						// lda (:TMP),y				; 16
//	 sta_bp2_1(i+17) and						// sta :bp2+1				; 17
         (copy(listing[i+10], 6, 256) = copy(listing[i+7], 6, 256) + '+1') and
         argMatch(i+1, i+3) and
	 argMatch(i+1, i+6) and
	 argMatch(i+5, i+9) )

	or

       ( sta_bp2_1(i+19) and						// sta :bp2+1				; 19			// A + ; S -

	 lda_val(i) and							// lda A				; 0	~:STACKORIGIN
	 add_sub_val(i+1) and						// add|sub				; 1	~:STACKORIGIN
         sta_stack(i+2) and 						// sta :STACKORIGIN			; 2
	 lda_val(i+3) and (listing[i+3] = listing[i] + '+1') and	// lda A+1				; 3
	 adc_sbc_val(i+4) and						// adc|sbc				; 4	~:STACKORIGIN
	 asl_stack(i+5) and						// asl :STACKORIGIN			; 5
	 rol_a(i+6) and							// rol @				; 6
	 sta_stack(i+7) and						// sta :STACKORIGIN+STACKWIDTH		; 7
	 lda_stack(i+8) and						// lda :STACKORIGIN			; 8
	 add(i+9) and							// add RSON				; 9
	 sta_tmp(i+10) and						// sta :TMP				; 10
	 lda_stack(i+11) and						// lda :STACKORIGIN+STACKWIDTH		; 11
	 adc(i+12) and							// adc RSON+1				; 12
	 sta_tmp_1(i+13) and						// sta :TMP+1				; 13
	 ldy_im_0(i+14) and						// ldy #$00				; 14
	 lda_tmp_y(i+15) and						// lda (:TMP),y				; 15
	 sta_bp2(i+16) and						// sta :bp2				; 16
	 iny(i+17) and							// iny					; 17
	 lda_tmp_y(i+18) and						// lda (:TMP),y				; 18
//	 sta_bp2_1(i+19) and						// sta :bp2+1				; 19
         (copy(listing[i+12], 6, 256) = copy(listing[i+9], 6, 256) + '+1') and
         argMatch(i+2, i+5) and
	 argMatch(i+7, i+11) and
	 argMatch(i+5, i+8) )

	or

       ( sta_bp2_1(i+17) and						// sta :bp2+1				; 17			// !

	 lda_adr(i) and							// lda adr.				; 0	~:STACKORIGIN
         sta_stack(i+1) and 						// sta :STACKORIGIN			; 1
	 lda_adr(i+2) and						// lda adr.				; 2
	 asl_stack(i+3) and						// asl :STACKORIGIN			; 3
	 rol_a(i+4) and							// rol @				; 4
	 sta_stack(i+5) and						// sta :STACKORIGIN+STACKWIDTH		; 5
	 lda_stack(i+6) and						// lda :STACKORIGIN			; 6
	 add(i+7) and							// add RSON				; 7
	 sta_tmp(i+8) and						// sta :TMP				; 8
	 lda_stack(i+9) and						// lda :STACKORIGIN+STACKWIDTH		; 9
	 adc(i+10) and							// adc RSON+1				; 10
	 sta_tmp_1(i+11) and						// sta :TMP+1				; 11
	 ldy_im_0(i+12) and						// ldy #$00				; 12
	 lda_tmp_y(i+13) and						// lda (:TMP),y				; 13
	 sta_bp2(i+14) and						// sta :bp2				; 14
	 iny(i+15) and							// iny					; 15
	 lda_tmp_y(i+16) and						// lda (:TMP),y				; 16
//	 sta_bp2_1(i+17) and						// sta :bp2+1				; 17
         (copy(listing[i+10], 6, 256) = copy(listing[i+7], 6, 256) + '+1') and
         argMatch(i+1, i+3) and
	 argMatch(i+1, i+6) and
	 argMatch(i+5, i+9) )

	or

       ( sta_bp2_1(i+15) and						// sta :bp2+1				; 15			// [

	 lda_val(i) and							// lda P+1				; 0	~:STACKORIGIN
         sta_stack(i+1) and 						// sta :STACKORIGIN+STACKWIDTH		; 1
	 lda_a(i+2) and (listing[i] = listing[i+2] + '+1') and		// lda P				; 2
	 asl_a(i+3) and							// asl @				; 3
	 rol_stack(i+4) and						// rol :STACKORIGIN+STACKWIDTH		; 4
	 add(i+5) and							// add RSON				; 5
	 sta_tmp(i+6) and						// sta :TMP				; 6
	 lda_a(i+7) and							// lda RSON+1				; 7
	 adc_stack(i+8) and						// adc :STACKORIGIN+STACKWIDTH		; 8
	 sta_tmp_1(i+9) and						// sta :TMP+1				; 9
	 ldy_im_0(i+10) and						// ldy #$00				; 10
	 lda_tmp_y(i+11) and						// lda (:TMP),y				; 11
	 sta_bp2(i+12) and						// sta :bp2				; 12
	 iny(i+13) and							// iny					; 13
	 lda_tmp_y(i+14) and						// lda (:TMP),y				; 14
//	 sta_bp2_1(i+15) and						// sta :bp2+1				; 15
         (copy(listing[i+7], 6, 256) = copy(listing[i+5], 6, 256) + '+1') and
         argMatch(i+1, i+4) and
	 argMatch(i+4, i+8) )

      then begin


	if lda_bp_y(i+6) then begin

	end else
	if lda_adr(i) and sta_tmp_1(i+11) and asl_stack(i+3) and rol_a(i+4) then begin
	 arg0:='!;'+GetString(i)+';'+GetString(i+2)+';'+GetString(i+7)+';'+GetString(i+10)+';';
	 k:=18;
	end else
	if lda(i) and sta_tmp_1(i+11) and asl_stack(i+3) and rol_a(i+4) then begin
	 arg0:='];'+GetString(i)+';'+GetString(i+2)+';'+GetString(i+7)+';'+GetString(i+10)+';';
	 k:=18;
	end else
	if add(i+1) and sta_tmp_1(i+13) and asl_stack(i+5) and rol_a(i+6) then begin
	 arg0:='A;'+GetString(i)+';'+GetString(i+3)+';'+GetString(i+9)+';'+GetString(i+12)+';'+GetString(i+1)+';'+GetString(i+4)+';';
	 k:=20;
	end else
	if sub(i+1) and sta_tmp_1(i+13) and asl_stack(i+5) and rol_a(i+6)then begin
	 arg0:='S;'+GetString(i)+';'+GetString(i+3)+';'+GetString(i+9)+';'+GetString(i+12)+';'+GetString(i+1)+';'+GetString(i+4)+';';
	 k:=20;
	end else
	if sta_tmp_1(i+9) and asl_a(i+3) and rol_stack(i+4) then begin
	 arg0:='[;'+GetString(i+2)+';'+GetString(i)+';'+GetString(i+5)+';'+GetString(i+7)+';';
	 k:=16;
	end else
	if asl_stack(i+3) and rol_a(i+4) then begin
	 arg0:='&;'+GetString(i)+';'+GetString(i+2)+';'+GetString(i+6)+';'+GetString(i+9)+';';
	 k:=12;
	end else
	if asl_a(i+3) and rol_stack(i+4) then begin
	 arg0:='%;'+GetString(i)+';'+GetString(i+2)+';'+GetString(i+5)+';'+GetString(i+7)+';';
	 k:=10;
	end else
        if lda_a(i) and add(i+1) then begin
	 arg0:='+;'+GetString(i)+';'+GetString(i+1)+';'+GetString(i+3)+';'+GetString(i+4)+';';
	 k:=6;
	end else begin
	 arg0:=listing[i]; arg0[4]:='?';
	 k:=1;
	end;


	if lda_bp_y(i+6) then begin

	 arg0:='+;'+GetString(i)+';'+GetString(i+1)+';'+GetString(i+3)+';'+GetString(i+4)+';';

	 if arg0 = optyBP2 then begin

	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := #9'ldy #$00';
	  listing[i+6] := #9'lda (:bp2),y';

	  k:=7;
	 end else begin
 	  arg0 := optyBP2;

	  k:=1;
	 end;

	end else

	if arg0 = optyBP2 then begin

	 if arg0[1] in ['A', 'S'] then begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';
	  listing[i+6] := '';
	  listing[i+7] := '';
	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10]:= '';
	  listing[i+11]:= '';
	  listing[i+12]:= '';
	  listing[i+13]:= '';
	  listing[i+14]:= '';
	  listing[i+15]:= '';
	  listing[i+16]:= '';
	  listing[i+17]:= '';
	  listing[i+18]:= '';
	  listing[i+19]:= '';
         end else
	 if arg0[1] in [']', '!'] then begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';
	  listing[i+6] := '';
	  listing[i+7] := '';
	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10]:= '';
	  listing[i+11]:= '';
	  listing[i+12]:= '';
	  listing[i+13]:= '';
	  listing[i+14]:= '';
	  listing[i+15]:= '';
	  listing[i+16]:= '';
	  listing[i+17]:= '';
         end else
	 if arg0[1] = '[' then begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';
	  listing[i+6] := '';
	  listing[i+7] := '';
	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10]:= '';
	  listing[i+11]:= '';
	  listing[i+12]:= '';
	  listing[i+13]:= '';
	  listing[i+14]:= '';
	  listing[i+15]:= '';
         end else
	 if arg0[1] = '&' then begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';
	  listing[i+6] := '';
	  listing[i+7] := '';
	  listing[i+8] := '';
	  listing[i+9] := '';
	  listing[i+10]:= '';
	  listing[i+11]:= '';
         end else
	 if arg0[1] = '%' then begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';
	  listing[i+6] := '';
	  listing[i+7] := '';
	  listing[i+8] := '';
	  listing[i+9] := '';
	 end else
	 if arg0[1] = '+' then begin
	  listing[i]   := '';
	  listing[i+1] := '';
	  listing[i+2] := '';
	  listing[i+3] := '';
	  listing[i+4] := '';
	  listing[i+5] := '';
	 end else
	  listing[i] := '';

	end;

	optyBP2 := arg0;

	inc(i, k);

    end else begin

     if (optyBP2 <> '') and (sta_a(i) or sty(i) or asl(i) or rol(i) or lsr(i) or ror(i) or inc_(i) or dec_(i)) then
      if (pos('? '+copy(listing[i], 6, 256)+' ', optyBP2) > 0) or (pos(';'+copy(listing[i], 6, 256)+';', optyBP2) > 0) then optyBP2:='';

     if sta_bp2(i) or sta_bp2_1(i) or jsr(i) or lab_l(i) or lab_b(i) or lab_c(i) then optyBP2:='';

     inc(i);

    end;

  end;


end;		// procedure
