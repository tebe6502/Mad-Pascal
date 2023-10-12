
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


    if inx(i) and										// inx
       dex(i+1) then										// dex
     begin
       listing[i]   := '';
       listing[i+1] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       and_ora_eor(i+2) and (and_ora_eor_stack(i+2) = false) and				// and|ora|eor				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       sta_a(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';

       listing[i+3] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       sta_a(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       sta_a(i+2) and (sta_stack(i+2) = false) and						// sta					; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       lda_a(i+5) and (lda_stack(i+5) = false) and						// lda					; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       lda_a(i+7) and (lda_stack(i+7) = false) and						// lda					; 7
       sta_a(i+8) and (sta_stack(i+8) = false) and						// sta					; 8
       dex(i+9) then										// dex					; 9
     begin
       listing[i]   := '';

       listing[i+9] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       and_ora_eor(i+2) and (and_ora_eor_stack(i+2) = false) and				// and|ora|eor				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       and_ora_eor(i+5) and (and_ora_eor_stack(i+5) = false) and				// and|ora|eor				; 5
       sta_a(i+6) and (sta_stack(i+6) = false) and						// sta					; 6
       lda_a(i+7) and (lda_stack(i+7) = false) and						// lda					; 7
       and_ora_eor(i+8) and (and_ora_eor_stack(i+8) = false) and				// and|ora|eor				; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       lda_a(i+10) and (lda_stack(i+10) = false) and						// lda					; 10
       and_ora_eor(i+11) and (and_ora_eor_stack(i+11) = false) and				// and|ora|eor				; 11
       sta_a(i+12) and (sta_stack(i+12) = false) and						// sta					; 12
       dex(i+13) then										// dex					; 13
     begin
       listing[i]   := '';

       listing[i+13] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       iny(i+2) and										// iny					; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     begin
       listing[i]   := '';

       listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       dex(i+3) then										// dex					; 3
     begin
       listing[i]   := '';
       listing[i+3] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       ldy(i+1) and (ldy_stack(i+1) = false) and						// ldy					; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i]   := '';
       listing[i+4] := '';

       exit(false);
     end;



    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       dex(i+4) then										// dex					; 4
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       dex(i+6) then										// dex					; 6
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+6] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       (listing[i+1] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 1
       lda_a(i+2) and (lda_stack(i+2) = false) and						// lda					; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda					; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       lda_a(i+8) and (lda_stack(i+8) = false) and						// lda					; 8
       sta_a(i+9) and (sta_stack(i+9) = false) and						// sta					; 9
       dex(i+10) then										// dex					; 10
     begin
       listing[i+1] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+10] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mwy_bp2(i+1) and 									// mwy G :bp2				; 1
       (listing[i+2] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       iny(i+5) and										// iny					; 5
       lda_a(i+6) and (lda_stack(i+6) = false) and						// lda					; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       iny(i+8) and										// iny					; 8
       lda_a(i+9) and (lda_stack(i+9) = false) and						// lda					; 9
       sta_a(i+10) and (sta_stack(i+10) = false) and						// sta					; 10
       iny(i+11) and										// iny					; 11
       lda_a(i+12) and (lda_stack(i+12) = false) and						// lda					; 12
       sta_a(i+13) and (sta_stack(i+13) = false) and						// sta					; 13
       dex(i+14) then										// dex					; 14
     begin
       listing[i+2] := #9'ldy :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+14] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva					; 1
       mwy_bp2(i+2) and										// mwy G :bp2				; 2
       ldy(i+3) and (ldy_stack(i+3) = false) and						// ldy					; 3
       (listing[i+4] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 4
       sta_a(i+5) and (sta_stack(i+5) = false) and						// sta					; 5
       dex(i+6) then										// dex					; 6
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i+4] := #9'lda ' + GetString(i+1);

	listing[i]   := '';
	listing[i+1] := '';

	listing[i+6] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mwy_bp2(i+1) and										// mwy G :bp2				; 1
       (listing[i+2] = #9'ldy :STACKORIGIN-1,x') and						// ldy :STACKORIGIN-1,x			; 2
       lda_a(i+3) and (lda_stack(i+3) = false) and						// lda					; 3
       sta_a(i+4) and (sta_stack(i+4) = false) and						// sta					; 4
       dex(i+5) then										// dex					; 5
     begin
	listing[i+2] := #9'ldy :STACKORIGIN,x';

	listing[i]   := '';

	listing[i+5] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       lda_a(i+1) and (lda_stack(i+1) = false) and						// lda					; 1
       (listing[i+2] = #9'sta :STACKORIGIN,x') and						// sta :STACKORIGIN,x			; 2
       dex(i+3) and										// dex					; 3
       (listing[i+4] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 4
     begin
	listing[i]   := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva					; 1
       dex(i+2) and										// dex					; 2
       (listing[i+3] = #9'lda :STACKORIGIN+1,x') then						// lda :STACKORIGIN+1,x			; 3
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda ' + GetString(i+1);
	listing[i+2] := '';
	listing[i+3] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and 										// mva   :STACKORIGIN,x			; 1
       dex(i+2) and										// dex					; 2
       mwy_bp2(i+3) and										// mwy 					; 3
       ldy(i+4) and (ldy_stack(i+4) = false) and						// ldy					; 4
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
       mva(i+1) and 										// mva					; 1
       mva(i+2) and 										// mva					; 2
       mva(i+3) and										// mva					; 3
       mva(i+4) and										// mva					; 4
       (listing[i+5] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 5
       add_sub(i+6) and (add_sub_stack(i+6) = false) and					// add|sub				; 6
       sta_a(i+7) and (sta_stack(i+7) = false) and						// sta					; 7
       (listing[i+8] = #9'lda :STACKORIGIN+STACKWIDTH,x') and					// lda :STACKORIGIN+STACKWIDTH,x	; 8
       adc_sbc(i+9) and (adc_sbc_stack(i+9) = false) and					// adc|sbc				; 9
       sta_a(i+10) and (sta_stack(i+10) = false) then						// sta					; 10
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
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       (listing[i+4] = #9'lda :STACKORIGIN-1+STACKWIDTH,x') and					// lda :STACKORIGIN-1+STACKWIDTH,x	; 4
       adc_sbc(i+5) and (adc_sbc_stack(i+5) = false) and					// adc|sbc				; 5
       sta_a(i+6) and (sta_stack(i+6) = false) then						// sta					; 6
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
       add_sub(i+2) and (add_sub_stack(i+2) = false) and					// add|sub				; 2
       sta_a(i+3) and (sta_stack(i+3) = false) and						// sta					; 3
       lda_a(i+4) and (lda_stack(i+4) = false) and						// lda					; 4
       adc_sbc(i+5) and (adc_sbc_stack(i+5) = false) and					// adc|sbc				; 5
       sta_a(i+6) and (sta_stack(i+6) = false) then						// sta					; 6
//       dex(i+7) then										// dex					; 7
     begin
       listing[i+1] := #9'lda :STACKORIGIN,x';

       listing[i]   := '';

       listing[i+7] := '';

       exit(false);
     end;


    if dex(i+5) and										// dex					; 5

     //inx(i) and										// inx					; 0
       mva(i+1) and										// mva	 :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       (listing[i+3] = #9'lda :STACKORIGIN,x') and						// lda :STACKORIGIN,x			; 3
       sta_a(i+4) and (sta_stack(i+4) = false) then						// sta					; 4
//       dex(i+5) then										// dex					; 5
     if (pos(':STACKORIGIN,x', listing[i+1]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', listing[i+2]) > 0) then
     begin
	listing[i+2] := '';
	listing[i+3] := #9'lda ' + GetString(i+1);

	listing[i+1] := '';

       exit(false);
     end;


end;		// function
