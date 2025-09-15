
function opt_STACK_INX(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      INX.
// -----------------------------------------------------------------------------

    if dex(i) and 										// dex

       inx(i+1) then										// inx
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if dex(i+1) and										// dex

       inx(i) then										// inx
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       sta_val(i+2) then									// sta					; 2	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+3] := '';

       exit(false);
     end;


    if dex(i+4) and										// dex					; 4

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       and_ora_eor_val(i+2) and									// and|ora|eor ~:STACKORIGIN		; 2
       sta_val(i+3) then									// sta					; 3	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if dex(i+5) and										// dex					; 5

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       sta_val(i+2) and										// sta					; 2	~:STACKORIGIN
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_val(i+4) then									// sta 					; 4	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if dex(i+9) and										// dex					; 9

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       sta_val(i+2) and										// sta					; 2	~:STACKORIGIN
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_val(i+4) and										// sta					; 4	~:STACKORIGIN
       lda_val(i+5) and										// lda					; 5	~:STACKORIGIN
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       lda_val(i+7) and										// lda					; 7	~:STACKORIGIN
       sta_val(i+8) then									// sta					; 8	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+9] := '';

       exit(false);
     end;


    if dex(i+13) and										// dex					; 13

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       (and_ora_eor_val(i+2) or add_sub_val(i+2)) and						// and|ora|eor|add|sub			; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       (and_ora_eor_val(i+5) or adc_sbc_val(i+5)) and						// and|ora|eor|adc|sbc			; 5	~:STACKORIGIN
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       lda_val(i+7) and										// lda					; 7	~:STACKORIGIN
       (and_ora_eor_val(i+8) or adc_sbc_val(i+8)) and						// and|ora|eor|adc|sbc			; 8	~:STACKORIGIN
       sta_val(i+9) and										// sta					; 9	~:STACKORIGIN
       lda_val(i+10) and									// lda					; 10	~:STACKORIGIN
       (and_ora_eor_val(i+11) or adc_sbc_val(i+11)) and						// and|ora|eor|adc|sbc			; 11	~:STACKORIGIN
       sta_val(i+12) then									// sta					; 12	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+13]:= '';

       exit(false);
     end;


    if dex(i+7) and										// dex					; 7

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       (and_ora_eor_val(i+2) or add_sub_val(i+2)) and						// and|ora|eor|add|sub			; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       (and_ora_eor_val(i+5) or adc_sbc_val(i+5)) and						// and|ora|eor|adc|sbc			; 5	~:STACKORIGIN
       sta_val(i+6) then									// sta					; 6	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+7]:= '';

       exit(false);
     end;


    if dex(i+11) and										// dex					; 11

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       (and_ora_eor_val(i+2) or add_sub_val(i+2)) and						// and|ora|eor|add|sub			; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       (and_ora_eor_val(i+5) or adc_sbc_val(i+5)) and						// and|ora|eor|adc|sbc			; 5	~:STACKORIGIN
       sta_val(i+6) and										// sta					; 6	~:STACKORIGIN
       lda_val(i+7) and										// lda					; 7	~:STACKORIGIN
       sta_val(i+8) and										// sta					; 8	~:STACKORIGIN
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       sta_val(i+10) then									// sta					; 10	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+11]:= '';

       exit(false);
     end;


    if dex(i+5) and										// dex					; 5

       inx(i) and										// inx					; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       iny(i+2) and										// iny					; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_val(i+4) then									// sta					; 4	~:STACKORIGIN
     begin
       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       inx(i) and										// inx					; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       lda_val(i+2) then									// lda					; 2	~:STACKORIGIN
//       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';

       listing[i+3] := '';

       exit(false);
     end;


    if dex(i+4) and										// dex					; 4

       inx(i) and										// inx					; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) then									// sta					; 3	~:STACKORIGIN
//       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if dex(i+6) and										// dex					; 6

       inx(i) and										// inx					; 0
       ldy_val(i+1) and										// ldy					; 1	~:STACKORIGIN
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_val(i+5) then									// sta					; 5	~:STACKORIGIN
//       dex(i+6) then										// dex					; 6
     begin
       listing[i]   := '';

       listing[i+6] := '';

       exit(false);
     end;



    if dex(i+4) and										// dex					; 4

       inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) then									// sta					; 3	~:STACKORIGIN
//       dex(i+4) then										// dex					; 4
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if dex(i+6) and										// dex					; 6

       inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_val(i+5) then									// sta					; 5	~:STACKORIGIN
//       dex(i+6) then										// dex					; 6
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+6] := '';

       exit(false);
     end;


    if dex(i+10) and										// dex					; 10

       inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_val(i+5) and										// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       sta_val(i+7) and										// sta					; 7	~:STACKORIGIN
       lda_val(i+8) and										// lda					; 8	~:STACKORIGIN
       sta_val(i+9) then									// sta					; 9	~:STACKORIGIN
//       dex(i+10) then										// dex					; 10
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+10] := '';

       exit(false);
     end;


    if dex(i+14) and										// dex					; 14

       inx(i) and										// inx					; 0
       mwy_bp2(i+1) and 									// mwy G :bp2				; 1
       (listing[i+2] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_val(i+4) and										// sta					; 4	~:STACKORIGIN
       iny(i+5) and										// iny					; 5
       lda_val(i+6) and										// lda					; 6	~:STACKORIGIN
       sta_val(i+7) and										// sta					; 7	~:STACKORIGIN
       iny(i+8) and										// iny					; 8
       lda_val(i+9) and										// lda					; 9	~:STACKORIGIN
       sta_val(i+10) and									// sta					; 10	~:STACKORIGIN
       iny(i+11) and										// iny					; 11
       lda_val(i+12) and									// lda					; 12	~:STACKORIGIN
       sta_val(i+13) then									// sta					; 13	~:STACKORIGIN
//       dex(i+14) then										// dex					; 14
     begin
       listing[i+2] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+14] := '';

       exit(false);
     end;


    if dex(i+6) and										// dex					; 6

       inx(i) and										// inx					; 0
       mva(i+1) and										// mva ... :STACKORIGIN,x		; 1
       mwy_bp2(i+2) and										// mwy G :bp2				; 2
       ldy_val(i+3) and										// ldy					; 3	~:STACKORIGIN
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_val(i+5) then									// sta					; 5	~:STACKORIGIN
//       dex(i+6) then										// dex					; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i]   := '';
	listing[i+1] := '';

	listing[i+6] := '';

       exit(false);
     end;


    if dex(i+5) and										// dex					; 5

       inx(i) and										// inx					; 0
       mwy_bp2(i+1) and										// mwy G :bp2				; 1
       (listing[i+2] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 2
       lda_val(i+3) and										// lda					; 3	~:STACKORIGIN
       sta_val(i+4) then									// sta					; 4	~:STACKORIGIN
//       dex(i+5) then										// dex					; 5
     begin
	listing[i+2] := #9'ldy :STACKORIGIN,x';

	listing[i]   := '';

	listing[i+5] := '';

       exit(false);
     end;


    if dex(i+3) and										// dex					; 3

       inx(i) and										// inx					; 0
       lda_val(i+1) and										// lda					; 1	~:STACKORIGIN
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
//       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if dex(i+2) and										// dex					; 2

       inx(i) and										// inx					; 0
       mva(i+1) and										// mva ... :STACKORIGIN,x		; 1
  //     dex(i+2) and										// dex					; 2
       (listing[i+3] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda ' + GetString(i+1);
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if dex(i+2) and										// dex					; 2

       inx(i) and										// inx					; 0
       mva(i+1) and										// mva ... :STACKORIGIN,x		; 1
//       dex(i+2) and										// dex					; 2
       ldy_1(i+3) then										// ldy #1				; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'mva ' + GetString(i+1) + ' :STACKORIGIN+1,x';
	listing[i+2] := '';

       exit(false);
     end;


    if dex(i+2) and										// dex					; 2

       inx(i) and										// inx					; 0
       mva(i+1) and 										// mva ... :STACKORIGIN,x		; 1
//       dex(i+2) and										// dex					; 2
       mwy_bp2(i+3) and										// mwy 					; 3
       ldy_val(i+4) and										// ldy 					; 4	~:STACKORIGIN
       (listing[i+5] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

       exit(false);
     end;


    if dex(i+11) and										// dex					; 11

       inx(i) and										// inx					; 0
       mva(i+1) and 										// mva ... :STACKORIGIN,x		; 1
       mva(i+2) and 										// mva ... :STACKORIGIN+STACKWIDTH,x 	; 2
       mva(i+3) and										// mva ... :STACKORIGIN+STACKWIDTH*2,x	; 3
       mva(i+4) and										// mva ... :STACKORIGIN+STACKWIDTH*3,x	; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       add_sub_val(i+6) and									// add|sub				; 6	~:STACKORIGIN
       sta_val(i+7) and										// sta					; 7	~:STACKORIGIN
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
       adc_sbc_val(i+9) and									// adc|sbc				; 9	~:STACKORIGIN
       sta_val(i+10) then									// sta					; 10	~:STACKORIGIN
//       dex(i+11) then										// dex					; 11
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', listing[i+3]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', listing[i+4]) > 0) then
     begin
	listing[i+5] := #9'lda ' + GetString(i+1);

	listing[i+8] := #9'lda ' + GetString(i+2);

	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if dex(i+7) and										// dex					; 7

       inx(i) and										// inx					; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       add_sub_val(i+2) and									// add|sub				; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       (listing[i+4] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 4
       adc_sbc_val(i+5) and									// adc|sbc				; 5	~:STACKORIGIN
       sta_val(i+6) then									// sta					; 6	~:STACKORIGIN
//       dex(i+7) then										// dex					; 7
     begin
       listing[i+1] := #9'lda :STACKORIGIN,x';

       listing[i+4] := #9'lda :STACKORIGIN+STACKWIDTH,x';

       listing[i]   := '';

       listing[i+7] := '';

       exit(false);
     end;


    if dex(i+7) and										// dex					; 7

       inx(i) and										// inx					; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       add_sub_val(i+2) and									// add|sub				; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       adc_sbc_val(i+5) and									// adc|sbc				; 5	~:STACKORIGIN
       sta_val(i+6) then									// sta 					; 6	~:STACKORIGIN
//       dex(i+7) then										// dex					; 7
     begin
       listing[i+1] := #9'lda :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+7] := '';

       exit(false);
     end;


    if dex(i+5) and										// dex					; 5

     //inx(i) and										// inx					; 0
       mva(i+1) and										// mva ... :STACKORIGIN,x		; 1
       mva(i+2) and 										// mva ... :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_val(i+4) then									// sta					; 4	~:STACKORIGIN
//       dex(i+5) then										// dex					; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+2] := '';
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


    if dex(i+6) and										// dex					; 6

       lda_val(i) and										// lda					; 0	~:STACKORIGIN
       (listing[i+1] = #9'sta :STACKORIGIN-1,x') and						// sta :STACKORIGIN-1,x			; 1
       lda_val(i+2) and										// lda					; 2	~:STACKORIGIN
       (listing[i+3] = #9'sta :STACKORIGIN-1+STACKWIDTH,x') and					// sta :STACKORIGIN-1+STACKWIDTH,x	; 3
       lda_val(i+4) and										// lda					; 4	~:STACKORIGIN
       sta_val(i+5) then									// sta					; 5	~:STACKORIGIN
//       dex(i+6) then										// dex					; 6
     begin
	listing[i+6] := listing[i+5];
	listing[i+5] := listing[i+4];
	listing[i+4] := #9'sta :STACKORIGIN+STACKWIDTH,x';
	listing[i+3] := listing[i+2];
	listing[i+2] := #9'sta :STACKORIGIN,x';
	listing[i+1] := listing[i];

	listing[i] := #9'dex';

       exit(false);
     end;


    if dex(i+7) and										// dex					; 7

       //inx(i) and										// inx					; 0
       (listing[i+1] = #9'lda :STACKORIGIN-1,x') and						// lda :STACKORIGIN-1,x			; 1
       add_sub_val(i+2) and									// add|sub				; 2	~:STACKORIGIN
       sta_val(i+3) and										// sta					; 3	~:STACKORIGIN
       (listing[i+4] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 4
       adc_sbc_val(i+5) and									// adc|sbc				; 5	~:STACKORIGIN
       sta_val(i+6) then									// sta					; 6	~:STACKORIGIN
//       dex(i+7) then										// dex					; 7
     begin
       listing[i+7] := listing[i+6];
       listing[i+6] := listing[i+5];
       listing[i+5] := #9'lda :STACKORIGIN+STACKWIDTH,x';
       listing[i+4] := listing[i+3];
       listing[i+3] := listing[i+2];
       listing[i+2] := #9'lda :STACKORIGIN,x';

       listing[i+1] := #9'dex';

       exit(false);
     end;


end;		// function
