
function opt_POKE(i: integer): Boolean;
var p: integer;
    tmp: string;
    yes: Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				     POKE.
// -----------------------------------------------------------------------------

  if ((pos(listing[i], listing[i+3]) > 0) or
      ((pos(#9'lda <', listing[i]) > 0) and (pos(#9'lda >', listing[i+3]) > 0))) and
     lda_val(i) and (lda_im(i) = false) and								// lda T			; 0	~#
     add(i+1) and											// add				; 1
     tay(i+2) and											// tay				; 2
     lda_val(i+3) and (lda_im(i+3) = false) and								// lda T+1			; 3	~#
     adc_im_0(i+4) and											// adc #$00			; 4
     sta_bp_1(i+5) then											// sta :bp+1			; 5
   begin

    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       (sta(i+7) or lsr_a(i+7) or asl_a(i+7)) and (pos(' :STACK', listing[i+7]) = 0) then	// lsr @|asl @|sta|sta (:bp),y	; 7
       begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if sta_bp_y(i+7) then listing[i+7] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       sta_stack(i+7) and									// sta :STACKORIGIN		; 7
       lda_stack(i+8) and									// lda :STACKORIGIN+STACKWIDTH	; 8
       sta_bp_1(i+9) then									// sta :bp+1			; 9
    if copy(listing[i+7], 6, 256) <> copy(listing[i+8], 6, 256) then
       begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       tay(i+7) and										// tay				; 7
       lda(i+8) and										// lda 				; 8
       sta(i+9) then										// sta 				; 9
    if copy(listing[i+7], 6, 256) <> copy(listing[i+8], 6, 256) then
       begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if lda_bp_y(i+8) then listing[i+8] := #9'lda (:bp2),y';
	if sta_bp_y(i+9) then listing[i+9] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if LDA_BP_Y(i+6) and									// lda (:bp),y			; 6
       ldy(i+7) and										// ldy				; 7
       sta(i+8) then										// sta 				; 8
    if copy(listing[i+7], 6, 256) <> copy(listing[i+8], 6, 256) then
       begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


    if lda(i+6) and (lda_bp_y(i+6) = false) and	(lda_stack(i+6) = false) and			// lda				; 6
       (and_ora_eor(i+7) or add_sub(i+7)) and ((pos(' (:bp),y', listing[i+7]) > 0)) and		// and|ora|eor|add|sub (:bp),y	; 7
       sta(i+8) and (sta_bp_y(i+8) = false) and (sta_stack(i+8) = false) then			// sta				; 8
      begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);

	listing[i+7] := copy(listing[i+7], 1, 5) + '(:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       and_ora_eor(i+7) and									// and|ora|eor			; 7
       (sta_val(i+8) or cmp(i+8)) then								// cmp|sta|sta (:bp),y		; 8
      begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';
	if cmp_bp_y(i+8) then listing[i+8] := #9'cmp (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       sta_stack(i+7) then									// sta :STACKORIGIN		; 7
      begin
	if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       cmp(i+7) then										// cmp				; 7
      begin
	if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	if cmp_bp_y(i+7) then listing[i+7] := #9'cmp (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_bp_y(i+6) and									// lda (:bp),y			; 6
       and_ora_eor(i+7) and									// and|ora|eor			; 7
       sta_stack(i+8) and									// sta :STACKORIGIN		; 8
       (mwy_bp2(i+9) or ldy(i+9)) then								// mwy ... :bp2			; 9
      begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda(i+6) and 										// lda 				; 6
       sta_val(i+7) then			 						// sta|sta (:bp),y		; 7
      begin
        if (pos(#9'lda <', listing[i]) > 0) {and (pos('lda >', listing[i+3]) > 0)} then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);

	if lda_bp_y(i+6) then listing[i+6] := #9'lda (:bp2),y';
	if sta_bp_y(i+7) then listing[i+7] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;

  end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

{
  if ((pos(listing[i], listing[i+4]) > 0) or ((pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+4]) > 0))) and
     lda_val(i) and (lda_im(i) = false) and								// lda T			; 0
     add(i+1) and											// add				; 1
     sta_stack(i+2) and											// sta :STACKORIGIN		; 2
     tay(i+3) and											// tay				; 3
     lda(i+4) and											// lda T+1			; 4
     adc_im_0(i+5) and											// adc #$00			; 5
     sta_bp_1(i+6) then											// sta :bp+1			; 6
   begin

    if lda_bp_y(i+7) and									// lda (:bp),y			; 7
       ldy_stack(i+8) and									// ldy :STACKORIGIN		; 8
       sta(i+9) and (sta_stack(i+9) = false) then						// sta|sta (:bp),y		; 9
    if (copy(listing[i+2], 6, 256) = copy(listing[i+8], 6, 256)) then
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';
	listing[i+7] := '';
	listing[i+8] := '';

	if sta_bp_y(i+9) then listing[i+9] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if lda_bp_y(i+7) and									// lda (:bp),y			; 7
       (and_ora_eor(i+8) or add_sub(i+8)) and							// and|ora|eor|add|sub		; 8
       ldy_stack(i+9) and									// ldy :STACKORIGIN		; 9
       sta(i+10) and (sta_stack(i+10) = false) then						// sta|sta (:bp),y		; 10
    if (copy(listing[i+2], 6, 256) = copy(listing[i+9], 6, 256)) then
      begin
        if (pos('lda <', listing[i]) > 0) and (pos('lda >', listing[i+3]) > 0) then
	 listing[i+4] := #9'mwy #' + copy(listing[i], 7, 256) + ' :bp2'
	else
	 listing[i+4] := #9'mwy ' + copy(listing[i], 6, 256) + ' :bp2';

	listing[i+5] := #9'ldy ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'lda (:bp2),y';
	listing[i+7] := '';

        listing[i+9]  := '';

	if sta_bp_y(i+10) then listing[i+10] := #9'sta (:bp2),y';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;

  end;
}


// -----------------------------------------------------------------------------
// ===				ABSOLUTE BP.				  === //
// -----------------------------------------------------------------------------

    if ((pos('+', listing[i]) = 1) or (pos('-', listing[i]) = 1)) then begin

     tmp:=copy(listing[i], 2, 256);

     yes:=false;

     for p:=i+1 to l-1 do
      if mwy_bp2(p) and (listing[p] = #9'mwy '+tmp+' :bp2') then listing[p] := '' else
       if pos('(:bp2),y', listing[p]) > 0 then begin listing[p] := copy(listing[p], 1, 5) + '('+tmp+'),y'; yes:=true end else
        if (pos('+', listing[p]) = 1) or (pos('-', listing[p]) = 1) then begin

	  if length(listing[p]) = 1 then listing[p] := '';

	  Break;

	end;

     if yes then begin
      listing[i] := '';

      exit(false);
     end;

    end;

{

    if listing[i][1] = '-' then begin

     tmp:=copy(listing[i], 2, 256);

     yes:=false;

     for p:=i+1 to l-1 do
       if mwy_bp2(p) and (listing[p] = #9'mwy '+tmp+' :bp2') then begin listing[p] := ''; yes:=true end else
        if sta_bp2_y(p) then begin listing[p] := #9'sta ('+tmp+'),y'; yes:=true end else
         if listing[p][1] in ['+','-'] then Break;

     if yes then begin
      listing[i] := '';

      exit(false);
     end;

    end;
}


  if ((pos('+', listing[i]) = 1) or (pos('-', listing[i]) = 1)) and					//+-label				; 0
     ldy_val(i+1) and											// ldy P				; 1
     lda_val(i+2) and (#9'lda ' + copy(listing[i+1], 6, 256) + '+1' = listing[i+2]) and			// lda P+1				; 2
     sta_bp_1(i+3) then begin										// sta :bp+1				; 3


    if lda(i+4) and										// lda 					; 4
       add_sub(i+5) and										// add|sub				; 5
       sta(i+6) then										// sta					; 6
      begin
	listing[i+1] := #9'mwy ' + copy(listing[i+1], 6, 256) + ' :bp2';
	listing[i+2] := #9'ldy #$00';
	listing[i+3] := '';

	if lda_bp_y(i+4) then listing[i+4] := #9'lda (:bp2),y';

	if add_bp_y(i+5) then listing[i+5] := #9'add (:bp2),y';
	if sub_bp_y(i+5) then listing[i+5] := #9'sub (:bp2),y';

	if sta_bp_y(i+6) then listing[i+6] := #9'sta (:bp2),y';

	exit(false);
      end;


    if lda(i+4) and										// lda 					; 4
       and_ora_eor(i+5) and									// and|ora|eor				; 5
       sta(i+6) then										// sta					; 6
      begin
	listing[i+1] := #9'mwy ' + copy(listing[i+1], 6, 256) + ' :bp2';
	listing[i+2] := #9'ldy #$00';
	listing[i+3] := '';

	if lda_bp_y(i+4) then listing[i+4] := #9'lda (:bp2),y';

	if and_bp_y(i+5) then listing[i+5] := #9'and (:bp2),y';
	if ora_bp_y(i+5) then listing[i+5] := #9'ora (:bp2),y';
	if eor_bp_y(i+5) then listing[i+5] := #9'eor (:bp2),y';

	if sta_bp_y(i+6) then listing[i+6] := #9'sta (:bp2),y';

	exit(false);
      end;


    if lda(i+4) and										// lda 					; 4
       ldy(i+5) and										// ldy					; 5
       sta(i+6) then										// sta					; 6
      begin
	listing[i+1] := #9'mwy ' + copy(listing[i+1], 6, 256) + ' :bp2';
	listing[i+2] := #9'ldy #$00';
	listing[i+3] := '';

	if lda_bp_y(i+4) then listing[i+4] := #9'lda (:bp2),y';
	if sta_bp_y(i+6) then listing[i+6] := #9'sta (:bp2),y';

	exit(false);
      end;

  end;


// -----------------------------------------------------------------------------


  if ((pos('+', listing[i]) = 1) or (pos('-', listing[i]) = 1)) and					//+-label				; 0
     lda_val(i+1) and (lda_im(i+1) = false) and								// lda P				; 1
     add(i+2) and											// add					; 2
     tay(i+3) and											// tay					; 3
     lda_val(i+4) and (listing[i+1] + '+1' = listing[i+4]) and						// lda P+1				; 4
     adc_im_0(i+5) and											// adc #$00				; 5
     sta_bp_1(i+6) then begin										// sta :bp+1				; 6

    if lda(i+7) and										// lda 					; 7
       sta(i+8) then										// sta					; 8
      begin
	listing[i+1] := #9'mwy ' + copy(listing[i+1], 6, 256) + ' :bp2';
	listing[i+2] := #9'ldy ' + copy(listing[i+2], 6, 256);
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	if lda_bp_y(i+7) then listing[i+7] := #9'lda (:bp2),y';

	if sta_bp_y(i+8) then listing[i+8] := #9'sta (:bp2),y';

	exit(false);
      end;

   end;

 end;		// function