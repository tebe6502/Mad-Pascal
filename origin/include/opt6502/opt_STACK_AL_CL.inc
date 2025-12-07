
function opt_STACK_AL_CL(i: integer): Boolean;
var p, q: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				    ADDAL_CL|SUBAL_CL
// -----------------------------------------------------------------------------

    if add_sub_AL_CL(i+10) and									// jsr addAL_CL|subAL_CL		; 10

     //inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       mva(i+3) and 										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 3
       mva(i+4) and 										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 4
       inx(i+5) and										// inx					; 5
       mva(i+6) and										// mva   :STACKORIGIN,x			; 6
       mva(i+7) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 7
       mva(i+8) and 										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 8
       mva(i+9) then 										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 9
     if stack_0x(i+1) and
	stack_1x(i+2) and
	stack_2x(i+3) and
	stack_3x(i+4) and
        stack_0x(i+6) and
	stack_1x(i+7) and
	stack_2x(i+8) and
	stack_3x(i+9) then
     begin

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       listing[i+7] := '';
       listing[i+8] := '';
       listing[i+9] := '';

       exit(false);
     end;


    if add_sub_AL_CL(i+7) and									// jsr addAL_CL|subAL_CL		; 7

     //inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       mva(i+3) and 										// mva   :STACKORIGIN+STACKWIDTH*2,x	; 3
       mva(i+4) and 										// mva   :STACKORIGIN+STACKWIDTH*3,x	; 4
       inx(i+5) and										// inx					; 5
       mva(i+6) then										// mva   :STACKORIGIN,x			; 6
     if stack_0x(i+1) and
	stack_1x(i+2) and
	stack_2x(i+3) and
	stack_3x(i+4) and
        stack_0x(i+6) then
     begin

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       exit(false);
     end;


    if //inx(i) and										// inx					; 0
       mva_im(i+1) and										// mva # :STACKORIGIN,x			; 1
       inx(i+2) and										// inx					; 2
       mva_im(i+3) and										// mva # :STACKORIGIN,x			; 3
       add_sub_AL_CL(i+4) then									// jsr addAL_CL|subAL_CL		; 4
     if stack_0x(i+1) and
     	stack_0x(i+3) then
     begin

       p := GetBYTE(i+1);
       q := GetBYTE(i+3);

       if listing[i+4] = #9'jsr addAL_CL' then
        p := p + q
       else
        p := p - q;

       listing[i+1] := #9'mva #' + HexByte(byte(p)) + ' :STACKORIGIN,x';

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := #9'inx';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       add_sub_AL_CL(i+3) then									// jsr addAL_CL|subAL_CL		; 3
     if stack_0x(i+1) and
	stack_1x(i+2) then
     begin

       listing[i+2] := '';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mva(i+1) and										// mva   :STACKORIGIN,x			; 1
       mva(i+2) and 										// mva   :STACKORIGIN+STACKWIDTH,x	; 2
       mva(i+3) and 										// mva   :STACKORIGIN-1+STACKWIDTH,x	; 3
       add_sub_AL_CL(i+4) then									// jsr addAL_CL|subAL_CL		; 4
     if stack_0x(i+1) and
	stack_1x(i+2) then
     begin

       listing[i+2] := '';
       listing[i+3] := '';

       exit(false);
     end;


    if jsr(i) and										// jsr					; 0
       inx(i+1) and										// inx					; 1
       mva(i+2) and										// mva  :STACKORIGIN,x			; 2
       add_sub_AL_CL(i+3) and									// jsr addAL_CL|subAL_CL		; 3
       dex(i+4) then										// dex					; 4
     if stack_0x(i+2) then
     begin

       listing[i+1] := #9'lda :STACKORIGIN,x';

       if listing[i+3] = #9'jsr addAL_CL' then
        listing[i+2] := #9'add ' + GetString(i+2)
       else
        listing[i+2] := #9'sub ' + GetString(i+2);

       listing[i+3] := #9'sta :STACKORIGIN,x';
       listing[i+4] := '';

       exit(false);
     end;


    if mva(i) and										// mva  :STACKORIGIN,x			; 0
       inx(i+1) and										// inx					; 1
       mva(i+2) and 										// mva  :STACKORIGIN,x			; 2
       add_sub_AL_CL(i+3) then									// jsr addAL_CL|subAL_CL		; 3
     if stack_0x(i) and
     	stack_0x(i+2) then
     begin

        tmp:=GetString(i+2);

        listing[i] := #9'lda ' + GetString(i);

        if listing[i+3] = #9'jsr addAL_CL' then
         listing[i+1] := #9'add ' + tmp
        else
         listing[i+1] := #9'sub ' + tmp;

        listing[i+2] := #9'sta :STACKORIGIN,x';

        listing[i+3] := #9'inx';

        exit(false);
     end;


    if (lda(i) or lda_adr(i)) and								// lda					; 0
       sta_stack_0x(i+1) and									// sta :STACKORIGIN,x			; 1
       (lda(i+2) or lda_adr(i+2)) and								// lda					; 2
       sta_stack_1x(i+3) and									// sta :STACKORIGIN+STACKWIDTH,x	; 3
       inx(i+4) and										// inx					; 4
       mva(i+5) and 										// mva  :STACKORIGIN,x			; 5
       add_sub_AL_CL(i+6) then									// jsr addAL_CL|subAL_CL		; 6
     if stack_0x(i+5) then
     begin

       if listing[i+6] = #9'jsr addAL_CL' then
        listing[i+1] := #9'add ' + GetString(i+5)
       else
        listing[i+1] := #9'sub ' + GetString(i+5);

       listing[i+2] := #9'sta :STACKORIGIN,x';
       listing[i+3] := #9'inx';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       exit(false);
     end;


    if mva(i) and										// mva  :STACKORIGIN,x			; 0
       mva(i+1) and										// mva  :STACKORIGIN+STACKWIDTH,x	; 1
       inx(i+2) and										// inx					; 2
       mva(i+3) and 										// mva  :STACKORIGIN,x			; 3
       add_sub_AL_CL(i+4) then									// jsr addAL_CL|subAL_CL		; 4
     if stack_0x(i) and
     	stack_1x(i+1) and
     	stack_0x(i+3) then
     begin

       listing[i] := #9'lda ' + GetString(i);

       if listing[i+4] = #9'jsr addAL_CL' then
        listing[i+1] := #9'add ' + GetString(i+3)
       else
        listing[i+1] := #9'sub ' + GetString(i+3);

       listing[i+2] := #9'sta :STACKORIGIN,x';
       listing[i+3] := #9'inx';
       listing[i+4] := '';

       exit(false);
     end;


    if //inx(i) and 										// inx					; 0
       mva(i+1) and (iy(i+1) = false) and							// mva  :STACKORIGIN,x			; 1
       inx(i+2) and 										// inx					; 2
       (lda(i+3) or lda_adr(i+3)) and								// lda					; 3
       sta_stack_0x(i+4) and									// sta :STACKORIGIN,x			; 4
       add_sub_AL_CL(i+5) then									// jsr addAL_CL|subAL_CL		; 5
     if stack_0x(i+1) then
     begin

       listing[i+1] := #9'lda ' + GetString(i+1);

       if listing[i+5] = #9'jsr addAL_CL' then
        listing[i+2] := #9'add ' + copy(listing[i+3], 6, 256)
       else
        listing[i+2] := #9'sub ' + copy(listing[i+3], 6, 256);

       listing[i+3] := '';
       listing[i+4] := #9'sta :STACKORIGIN,x';
       listing[i+5] := #9'inx';

       exit(false);
     end;


    if inx(i) and (iy(i+1) = false) and								// inx					; 0
       mva(i+1) and 										// mva  :STACKORIGIN,x			; 1
       inx(i+2) and 										// inx					; 2
       mwy_bp2(i+3) and										// mwy ... :bp2				; 3
       ldy_im(i+4) and										// ldy #				; 4
       mva_bp2_y(i+5) and			 						// mva (:bp2),y :STACKORIGIN,x		; 5
       add_sub_AL_CL(i+6) then									// jsr addAL_CL|subAL_CL		; 6
     if stack_0x(i+1) and
     	stack_0x(i+5) then
     begin

       tmp := #9'lda ' + GetString(i+1);

       listing[i+1] := listing[i+3];
       listing[i+2] := listing[i+4];
       listing[i+3] := tmp;

       if listing[i+6] = #9'jsr addAL_CL' then
        listing[i+4] := #9'add (:bp2),y'
       else
        listing[i+4] := #9'sub (:bp2),y';

       listing[i+5] := #9'sta :STACKORIGIN,x';
       listing[i+6] := #9'inx';

       exit(false);
     end;


    if inx(i) and										// inx					; 0
       mwy_bp2(i+1) and										// mwa ... :bp2				; 1
       ldy_im(i+2) and										// ldy #				; 2
       LDA_BP2_Y(i+3) and 									// lda (:bp2),y 			; 3
       sta_stack_0x(i+4) and 									// sta :STACKORIGIN,x			; 4
       inx(i+5) and (iy(i+6) = false) and							// inx					; 5
       mva(i+6) and 										// mva .. :STACKORIGIN,x		; 6
       add_sub_AL_CL(i+7) then									// jsr addAL_CL|subAL_CL		; 7
     if stack_0x(i+6) then
     begin

       if listing[i+7] = #9'jsr addAL_CL' then
        listing[i+4] := #9'add ' + GetString(i+6)
       else
        listing[i+4] := #9'sub ' + GetString(i+6);

       listing[i+5] := #9'sta :STACKORIGIN,x';
       listing[i+6] := #9'inx';

       listing[i+7] := '';

       exit(false);
     end;


    if inx(i) and 										// inx					; 0
       mwy_bp2(i+1) and										// mwa ... :bp2				; 1
       ldy_im(i+2) and										// ldy #				; 2
       mva_bp2_y(i+3) and			 						// mva (:bp2),y :STACKORIGIN,x		; 3
       inx(i+4) and (iy(i+5) = false) and							// inx					; 4
       mva(i+5) and 										// mva .. :STACKORIGIN,x		; 5
       add_sub_AL_CL(i+6) then									// jsr addAL_CL|subAL_CL		; 6
     if stack_0x(i+3) and
     	stack_0x(i+5) then
     begin

       listing[i+3] := #9'lda (:bp2),y';

       if listing[i+6] = #9'jsr addAL_CL' then
        listing[i+4] := #9'add ' + GetString(i+5)
       else
        listing[i+4] := #9'sub ' + GetString(i+5);

       listing[i+5] := #9'sta :STACKORIGIN,x';
       listing[i+6] := #9'inx';

       exit(false);
     end;


    if inx(i) and 										// inx					; 0
       mwy_bp2(i+1) and										// mwa ... :bp2				; 1
       ldy_im(i+2) and										// ldy #				; 2
       mva_bp2_y(i+3) and			 						// mva (:bp2),y :STACKORIGIN,x		; 3
       inx(i+4) and 										// inx					; 4
       ldy_im(i+5) and										// ldy #				; 5
       mva_bp2_y(i+6) and				 					// mva (:bp2),y :STACKORIGIN,x		; 6
       add_sub_AL_CL(i+7) then									// jsr addAL_CL|subAL_CL		; 7
     if stack_0x(i+3) and
     	stack_0x(i+6) then
     begin

       listing[i+3] := #9'lda (:bp2),y';
       listing[i+4] := listing[i+5];

       if listing[i+7] = #9'jsr addAL_CL' then
        listing[i+5] := #9'add (:bp2),y'
       else
        listing[i+5] := #9'sub (:bp2),y';

       listing[i+6] := #9'sta :STACKORIGIN,x';
       listing[i+7] := #9'inx';

       exit(false);
     end;


    if inx(i) and 										// inx					; 0
       ldy_im(i+1) and										// ldy #				; 1
       mva_bp2_y(i+2) and			 						// mva (:bp2),y :STACKORIGIN,x		; 2
       inx(i+3) and 										// inx					; 3
       ldy_im(i+4) and										// ldy #				; 4
       mva_bp2_y(i+5) and				 					// mva (:bp2),y :STACKORIGIN,x		; 5
       add_sub_AL_CL(i+6) then									// jsr addAL_CL|subAL_CL		; 6
     if stack_0x(i+2) and
     	stack_0x(i+5) then
     begin

       listing[i+2] := #9'lda (:bp2),y';
       listing[i+3] := listing[i+4];

       if listing[i+6] = #9'jsr addAL_CL' then
        listing[i+4] := #9'add (:bp2),y'
       else
        listing[i+4] := #9'sub (:bp2),y';

       listing[i+5] := #9'sta :STACKORIGIN,x';
       listing[i+6] := #9'inx';

       exit(false);
     end;


    if add_sub_AL_CL(i) and									// jsr addAL_CL|subAL_CL		; 0
       dex(i+1) and										// dex					; 1
       (pos(#9'mva :STACKORIGIN,x', listing[i+2]) > 0) and					// mva :STACKORIGIN,x ...		; 2
       dex(i+3) then										// dex					; 3
     begin

       if listing[i] = #9'jsr addAL_CL' then
        listing[i] := #9'adb :STACKORIGIN-1,x :STACKORIGIN,x ' + copy(listing[i+2], pos(',x', listing[i+2])+3, length(listing[i+2]) )
       else
        listing[i] := #9'sbb :STACKORIGIN-1,x :STACKORIGIN,x ' + copy(listing[i+2], pos(',x', listing[i+2])+3, length(listing[i+2]) );

       listing[i+2] := '';

       if (i>0) and (pos(#9'jsr @expand', listing[i-1]) > 0) then listing[i-1] := '';

       exit(false);
     end;


    if add_sub_AL_CL(i) and									// jsr addAL_CL|subAL_CL		; 0
       dex(i+1) and										// dex					; 1
       lda_stack_0x(i+2) and									// lda :STACKORIGIN,x			; 2
       sta_val(i+3) and										// sta I				; 3
       (lda(i+4) = false) then									//~lda					; 4
     begin

       if listing[i] = #9'jsr addAL_CL' then begin
        listing[i]   := #9'lda :STACKORIGIN-1,x';
	listing[i+1] := #9'add :STACKORIGIN,x';
       end else begin
        listing[i]   := #9'lda :STACKORIGIN-1,x';
	listing[i+1] := #9'sub :STACKORIGIN,x';
       end;

       listing[i+2] := #9'sta ' + copy(listing[i+3], 6, 256);

       listing[i+3] := #9'dex';

       exit(false);
     end;

end;		// function
