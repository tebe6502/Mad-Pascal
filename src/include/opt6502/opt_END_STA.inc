// -----------------------------------------------------------------------------
// ===				      STA.
// -----------------------------------------------------------------------------

     if (ADD_SUB_STACK(i) or ADC_SBC_STACK(i) or AND_ORA_EOR_STACK(i)) then		// add|sub|adc|sbc :STACKORIGIN
      begin

	tmp:=copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if ((p>1) and sta_stack(p) and lda_a(p-1) and (SKIP(p-2) = false) and (lda_stack(p-1) = false) {and (iy(p-1) = false)}) or
	     ((p=1) and sta_stack(1) and lda_a(0) and (lda_stack(0) = false) and (iy(0) = false)) then
	  begin


	   ok := false;
	   if lda_im(p-1) = false then begin						// argument z LDA nie moze wystapic w przedziale p..i
	    old:=copy(listing[p-1], 6-1, 256);

	    for k:=p to i do
	     if pos(old, listing[k]) > 0 then begin ok := true; Break end;

	   end;
	   if ok then Break;


	   listing[i] := copy(listing[i], 1, 5) +  copy(listing[p-1], 6, 256);

	   if asl_a(p+1) or lsr_a(p+1) then

	   else
	   if sta(p+1) or tay(p+1) then
	    listing[p] := ''
	   else begin
	    listing[p-1] := '';
	    listing[p]   := '';
	   end;

	   Result:=false; Break;
	  end;

	  Break;

	 end else
	  if ldy(p) or iny(p) or dey(p) or tay(p) or tya(p) or onBreak(p) then Break;

	if Result = false then Break;
      end;


{
	lda :STACKORIGIN
	asl @

	zmiennej ':STACKORIGIN,x' nie można usunąć, bo jeśli występuje w innych miejscach zostanie zastąpiona przez #$00

	co w przypadku mnozen *3, *5, *7 etc. oznacza bledne obliczenia

	zalezy nam aby operacje odbywaly sie z uzyciem stosu :STACKORIGIN a nie rejestru :EAX (uzywany przez REGISTER)
}

     if lda_stack(i) and											// lda :STACKORIGIN
        (add_sub(i+1) or adc_sbc(i+1) or and_ora_eor(i+1) or							// add|adc|sub|sbc|asl @|asl @|lsr @
	 (asl_a(i+1) and tay(i+2)) or										//                |tay  |asl @|tay
	 (asl_a(i+1) and  asl_a(i+2) and tay(i+3)) or								//			|tay  |
	 (lsr_a(i+1) and tay(i+2))) then
      begin

        //if add_im_0(i+1) or sub_im_0(i+1) or adc_im_0(i+1) or sbc_im_0(i+1) then Break;

	tmp := copy(listing[i], 6, 256);
	yes := false;

	for p:=i-1 downto 1 do
	 if pos(tmp, listing[p]) > 0 then begin

	  if ((p>1) and sta_stack(p) and lda_a(p-1) and (SKIP(p-2) = false) and (lda_stack(p-1) = false) {and (iy(p-1) = false)}) or
	     ((p=1) and sta_stack(1) and lda_a(0) and (lda_stack(0) = false) {and (iy(0) = false)}) then begin

	   if iy(p-1) and yes then Break;


	   ok := false;
	   if lda_im(p-1) = false then begin						// argument z LDA nie moze wystapic w przedziale p..i
	    old := copy(listing[p-1], 6-1, 256);

	    for k:=p to i do
	     if pos(old, listing[k]) > 0 then begin ok := true; Break end;

	   end;
	   if ok then Break;


	   listing[i] := listing[p-1];

	   if asl_a(p+1) or lsr_a(p+1) then

	   else
	   if sta(p+1) or tay(p+1) then
	    listing[p] := ''
	   else begin
 	    listing[p-1] := '';
 	    listing[p]   := '';
	   end;

	   Result:=false; Break;
	  end;

	  Break;

	 end else
	  if ldy(p) or iny(p) or dey(p) or tay(p) then
	   yes:=true
	  else
	  if onBreak(p) then Break;

	if Result = false then Break;
      end;


    if lda_stack(i) and									// lda :STACKORIGIN		; 0
       STA_BP2_Y(i+2) and								// add|sub|and|ora|eor		; 1	<> listing[i]
       (add_sub(i+1) or adc_sbc(i+1) or and_ora_eor(i+1)) and				// sta (:bp2),y			; 2
       (pos(' :STACK', listing[i+1]) = 0) then
       begin

        //if add_im_0(i+1) or sub_im_0(i+1) or adc_im_0(i+1) or sbc_im_0(i+1) or and_im_0(i+1) or ora_im_0(i+1) or eor_im_0(i+1) then Break;

 	tmp := copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if ((p>1) and sta_stack(p) and lda_a(p-1) and (SKIP(p-2) = false) and (lda_stack(p-1) = false) and (iy(p-1) = false) and (copy(listing[p-1], 6, 256) <> copy(listing[i+1], 6, 256)) ) or
	     ((p=1) and sta_stack(1) and lda_a(0) and (lda_stack(0) = false) and (iy(0) = false) and (copy(listing[p-1], 6, 256) <> copy(listing[i+1], 6, 256)) ) then begin


	   ok := false;
	   if lda_im(p-1) = false then begin						// argument z LDA nie moze wystapic w przedziale p..i
	    old:=copy(listing[p-1], 6-1, 256);

	    for k:=p to i do
	     if pos(old, listing[k]) > 0 then begin ok := true; Break end;

	   end;
	   if ok then Break;


	   listing[i] := listing[p-1];

	   if asl_a(p+1) or lsr_a(p+1) then

	   else
	   if sta(p+1) or tay(p+1) then
	    listing[p] := ''
	   else begin
	    listing[p-1] := '';
	    listing[p]   := '';
	   end;

	   Result:=false; Break;
	  end;

	  Break;

	 end else
	  if onBreak(p) then Break;

	if Result = false then Break;
       end;


    if lda_stack(i) and									// lda :STACKORIGIN		; 0
       STA_BP2_Y(i+1) then								// sta (:bp2),y			; 1
       begin

 	tmp:=copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if ((p>1) and sta_stack(p) and lda_a(p-1) and (SKIP(p-2) = false) and (lda_stack(p-1) = false) and (iy(p-1) = false)) or
	     ((p=1) and sta_stack(1) and lda_a(0) and (lda_stack(0) = false) and (iy(0) = false)) then begin


	   ok := false;
	   if lda_im(p-1) = false then begin						// argument z LDA nie moze wystapic w przedziale p..i

	    old := copy(listing[p-1], 6-1, 256);

	    for k:=p to i do
	     if pos(old, listing[k]) > 0 then begin ok := true; Break end;

	   end;
	   if ok then Break;


	   listing[i] := listing[p-1];

	   if asl_a(p+1) or lsr_a(p+1) then

	   else
	   if sta(p+1) or tay(p+1) then
	    listing[p] := ''
	   else begin
	    listing[p-1] := '';
	    listing[p]   := '';
	   end;

//	  listing[p-1] := '';		//!!! zachowac 'lda'
//	  listing[p]   := '';

	   Result:=false; Break;

	  end;

	  Break;

	 end else
	  if onBreak(p) then Break;

	if Result = false then Break;
       end;


    if ldy_stack(i) and									// ldy :STACKORIGIN		; 0
       sty_bp_1(i+1) then								// sty :bp+1			; 1
       begin

 	tmp:=copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if ((p>1) and sta_stack(p) and lda_a(p-1) and (SKIP(p-2) = false) and (lda_stack(p-1) = false)) or
	     ((p=1) and sta_stack(1) and lda_a(0) and (lda_stack(0) = false)) then begin


	   ok := false;
	   if lda_im(p-1) = false then begin						// argument z LDA nie moze wystapic w przedziale p..i
	    old:=copy(listing[p-1], 6-1, 256);

	    for k:=p to i do
	     if pos(old, listing[k]) > 0 then begin ok := true; Break end;

	   end;
	   if ok then Break;


	   listing[i] := #9'ldy ' + copy(listing[p-1], 6, 256);

	   if asl_a(p+1) or lsr_a(p+1) then

	   else
	   if sta(p+1) or tay(p+1) then
	    listing[p] := ''
	   else begin
	    listing[p-1] := '';
	    listing[p]   := '';
	   end;

	   Result:=false; Break;

	  end;

	  Break;

	 end else
	  if onBreak(p) then Break;

	if Result = false then Break;
       end;


// usuwa zapis do stack jesli wczesniej juz wystapil

     if	sta_stack(i+1) and								// sta :STACKORIGIN		; 1

       ((lda_a(i) and (lda_stack(i) = false)) or					// lda				; 0
         (and_ora_eor(i) and (and_ora_eor_stack(i) = false)) or				// and|ora|eor			; 0
	 asl_a(i) or									// asl @			; 0
	 rol_a(i) or									// rol @			; 0
	 add_sub_val(i) or								// add|sub			; 0
	 adc_sbc_val(i) ) then								// adc|sbc			; 0

       begin

	tmp := copy(listing[i+1], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if sta_stack(p) then begin

	   if (p > 2) and
	      tay(p-3)and				// tay				; p-3
	      lda_stack(p-2) and			// lda :STACKORIGIN+STACKWIDTH	; p-2
	      adc_im_0(p-1) 				// adc #$00			; p-1
	   then

	   else begin
	    listing[p] := '';

	    Result:=false; Break;
	   end;

	  end;

	  Break;
	 end else
          if onBreak(p) then Break;

	if Result = false then Break;
     end;



     if lda_stack(i) and (EAX(i) = false) and						// lda :STACKORIGIN		; 0
	sta_a(i+1) and (iy(i+1) = false) and (pos(':bp2', listing[i+1]) = 0) and	// sta				; 1
	(sta_a(i+2) = false) and (tay(i+2) = false) and 				//~sta|tay			; 2
	( copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256) ) then
       begin

	tmp := copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) and
	    ( (sta_stack(p) and (lda_stack(p-1) = false)) or (sty_stack(p) and (ldy_stack(p-1) = false)) ) then begin

	  if sta_stack(p) then
	   listing[p] := #9'sta ' + copy(listing[i+1], 6, 256)
	  else
	   listing[p] := #9'sty ' + copy(listing[i+1], 6, 256);

	  listing[i]   := '';
	  listing[i+1] := '';

	  Result:=false; Break;
	 end else
	  if (pos(tmp, listing[p]) = 6) or
	     (copy(listing[i+1], 6, 256) = copy(listing[p], 6, 256)) or			// pos(listing[i+1] !!! tutaj nie jest mozliwe
	     onBreak(p) then Break;

	if Result = false then Break;
     end;


     if ldy_stack(i) and								// ldy :STACKORIGIN		; 0
	sty(i+1) and 									// sty				; 1
	(pos(':bp2', listing[i+1]) = 0) and
	(sty(i+2) = false) and (tya(i+2) = false) and 					//~sty				; 2
	( copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256) ) then
       begin

	tmp := #9'sta ' + copy(listing[i], 6, 256);

	for p:=i-1 downto 1 do
	 if (listing[p] = tmp) and (lda_stack(p-1) = false) then begin

	  listing[p]   := #9'sta ' + copy(listing[i+1], 6, 256);

	  listing[i]   := '';
	  listing[i+1] := '';

	  Result:=false; Break;
	 end else
	  if (pos(copy(listing[i], 6, 256), listing[p]) = 6) or
	     (copy(listing[i+1], 6, 256) = copy(listing[p], 6, 256)) or			// pos(listing[i+1] !!! tutaj nie jest mozliwe
	     onBreak(p) then Break;

	if Result = false then Break;
     end;


     if lda(i) and 									// lda				; 0
	add_stack(i+1) and 								// add :STACKORIGIN+9		; 1
	tay(i+2) and									// tay				; 2
	lda(i+3) and									// lda				; 3
	adc_stack(i+4) and 								// adc :STACKORIGIN+STACKWIDTH	; 4
	sta_bp_1(i+5) then 								// sta :bp+1			; 5
      begin

	tmp := #9'sta ' + copy(listing[i+1], 6, 256);

	for p:=i-1 downto 1 do
	 if (pos(tmp, listing[p]) > 0) then begin

	  if (p > 1) and
	     lda(p-2) and					// lda :STACKORIGIN+9			; p-2
	     add_sub(p-1) and					// add|sub				; p-1
	     sta_stack(p) and					// sta :STACKORIGIN+9			; p
	     lda(p+1) and					// lda :STACKORIGIN+STACKWIDTH+9	; p+1
	     adc_sbc(p+2) and					// adc|sbc				; p+2
	     sta_stack(p+3) and					// sta :STACKORIGIN+STACKWIDTH+9	; p+3
	     lda(p+4) and					// lda :STACKORIGIN+STACKWIDTH*2+9	; p+4
	     adc_sbc(p+5) and					// adc|sbc				; p+5
	     sta_stack(p+6) and					// sta :STACKORIGIN+STACKWIDTH*2+9	; p+6
	     lda(p+7) and					// lda :STACKORIGIN+STACKWIDTH*3+9	; p+7
	     adc_sbc(p+8) and					// adc|sbc				; p+8
	     sta_stack(p+9) then				// sta :STACKORIGIN+STACKWIDTH*3+9	; p+9
	  begin
	   listing[p+4] := '';
	   listing[p+5] := '';
	   listing[p+6] := '';
	   listing[p+7] := '';
	   listing[p+8] := '';
	   listing[p+9] := '';

	   Result:=false; Break;
	  end;

	  Break;

	 end else
	  if onBreak(p) then Break;

	if Result = false then Break;
      end;


    if dey(i) and									// dey				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN		; 1
       sty_stack(i+2) and								// sty :STACKORIGIN+STACKWIDTH	; 2
       asl_stack(i+3) and								// asl :STACKORIGIN		; 3
       rol_stack(i+4) then								// rol :STACKORIGIN+STACKWIDTH	; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+4], 6, 256)) then
       begin

        tmp:=listing[i+1];

        listing[i+1] := listing[i+2];

	p:=i+3;

	while asl_stack(p) and rol_stack(p+1) do begin
	 listing[p-1] := #9'asl @';
	 listing[p] := listing[p+1];

	 inc(p,2);
	end;

	listing[p-1] := tmp;

	Result:=false; Break;
       end;


    if lda_stack(i) and									// lda :STACKORIGIN+9		; 0
       sta_bp2(i+1) and									// sta :bp2			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN+STAWCKWIDTH	; 2
       sta_bp2_1(i+3) then								// sta :bp2+1			; 3
       begin

 	tmp := #9'sta ' + copy(listing[i], 6, 256);

	for p:=i-1 downto 0 do
	 if listing[p] = tmp then begin

	  if (p > 1) and								// ldy #$00			; 4
	     ldy_im_0(i+4) and
	     lda_val(p-2) and (lda_im(p-2) = false) and			/// lda TB 				; -2
	     add_im(p-1) and						/// add #				; -1
//	     sta(p) and							/// sta :STACKORIGIN+9			; 0
	     (listing[p+1] = listing[p-2] + '+1') and			/// lda TB+1				; 1
	     adc_im_0(p+2) and						/// adc #$00				; 2
	     sta_stack(p+3) then					/// :STACKORIGIN+STACKWIDTH+9		; 3
	   if pos(listing[p-2], listing[p+1]) > 0 then
	  begin
	   listing[i] := #9'mwy ' + copy(listing[p-2], 6, 256) + ' :bp2';
	   listing[i+1] := #9'ldy ' + copy(listing[p-1], 6, 256);
	   listing[i+2] := '';
	   listing[i+3] := '';
	   listing[i+4] := '';

	   listing[p-2] := '';
	   listing[p-1] := '';
	   listing[p]   := '';
	   listing[p+1] := '';
	   listing[p+2] := '';
	   listing[p+3] := '';

	   Result:=false; Break;
	  end;


	  if sta_stack(p) and						/// sta :STACKORIGIN+9			; 0
	     lda(p+1) and						/// lda :STACKORIGIN+STACKWIDTH+9	; 1
	     adc_sbc(p+2) and						/// adc|sbc :STACKORIGIN+STACKWIDTH+11	; 2
	     sta_stack(p+3) and						/// sta :STACKORIGIN+STACKWIDTH+9	; 3
	     lda(p+4) and						/// lda :STACKORIGIN+STACKWIDTH*2+9	; 4
	     adc_sbc(p+5) and						/// adc|sbc #$00			; 5
	     sta_stack(p+6) and						/// sta :STACKORIGIN+STACKWIDTH*2+9	; 6
	     lda(p+7) and						/// lda :STACKORIGIN+STACKWIDTH*3+9	; 7
	     adc_sbc(p+8) and						/// adc|sbc #$00			; 8
	     sta_stack(p+9) then 					/// sta :STACKORIGIN+STACKWIDTH*3+9	; 9
	  if copy(listing[i+2], 6, 256) = copy(listing[p+3], 6, 256) then
	  begin

	   listing[p+4] := '';
	   listing[p+5] := '';
	   listing[p+6] := '';
	   listing[p+7] := '';
	   listing[p+8] := '';
	   listing[p+9] := '';

	   Result:=false; Break;
	  end;

	  Break;

	 end else
	  if onBreak(p) then Break;

	if Result = false then Break;
       end;


    if mwy_bp2(i) and										// mwy   :bp2			; 0
       ldy(i+1) and										// ldy #$XX			; 1
       lda_stack(i+2) and									// lda :STACKORIGIN+9		; 2
       add_sub(i+3) and										// add|sub			; 3
       sta_bp2_y(i+4) and									// sta (:bp2),y			; 4
       iny(i+5) and										// iny				; 5
       lda_stack(i+6) and									// lda :STACKORIGIN+STACKWIDTH+9; 6
       adc_sbc(i+7) and										// adc|sbc			; 7
       sta_bp2_y(i+8) and									// sta (:bp2),y			; 8
       (iny(i+9) = false) then
      begin

	tmp := #9'sta ' + copy(listing[i+2], 6, 256);

	for p:=i-1 downto 0 do
	 if listing[p] = tmp then begin

	  if (listing[p-3] = listing[i]) and				// mwy   :bp2			; -3
	     (listing[p-2] = listing[i+1]) and				// ldy				; -2
	     lda_bp2_y(p-1) and						// lda (:bp2),y			; -1
	     iny(p+1) and						// sta :STACKORIGIN+9		; 0
	     lda_bp2_y(p+2) and						// iny				; 1
	     sta_stack(p+3) then					// lda (:bp2),y			; 2
	    begin							// sta :STACKORIGIN+STACKWIDTH+9; 3
	     listing[p-3] := '';
	     listing[p-2] := '';
	     listing[p-1] := '';
	     listing[p]   := '';
	     listing[p+1] := '';
	     listing[p+2] := '';
	     listing[p+3] := '';

	     listing[i+2] := #9'lda (:bp2),y';

	     listing[i+6] := #9'lda (:bp2),y';

	     Result:=false; Break;
	    end;

	  Break;

	 end else
	  if onBreak(p) then Break;

	if Result = false then Break;
      end;


    if sty_stack(i) and									// sty :STACKORIGIN+STACKWIDTH*2	; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH*3	; 1
       lda_stack(i+2) and								// lda :STACKORIGIN+STACKWIDTH*2	; 2
       sta_val(i+3) and									// sta A				; 3	~:STACKORIGIN
       lda(i+4) and									// lda :STACKORIGIN+STACKWIDTH*3	; 4
       sta_val(i+5) then				 				// sta A+1				; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i]   := #9'sty ' + copy(listing[i+3], 6, 256);
	listing[i+1] := #9'sty ' + copy(listing[i+5], 6, 256);
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

      	Result:=false; Break;
     end;


    if sty_stack(i) and									// sty :STACKORIGIN+STACKWIDTH*2	; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH*3	; 1
       lda_stack(i+2) and								// lda :STACKORIGIN+STACKWIDTH*2	; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH*3	; 3
       lda(i+4) then									// lda					; 4
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i+2] := '';
	listing[i+3] := '';

      	Result:=false; Break;
     end;


    if sty_stack(i) and									// sty :STACKORIGIN+STACKWIDTH		; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH*2	; 1
       sty_stack(i+2) and								// sty :STACKORIGIN+STACKWIDTH*3	; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH		; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH*2	; 4
       lda(i+5) then									// lda					; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+3] := '';
	listing[i+4] := '';

      	Result:=false; Break;
     end;


    if sty_stack(i) and									// sty :STACKORIGIN+STACKWIDTH		; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH*2	; 1
       sty_stack(i+2) and								// sty :STACKORIGIN+STACKWIDTH*3	; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH		; 3
       sta_val(i+4) and									// sta ~:STACKORIGIN			; 4
       lda_stack(i+5) and								// lda :STACKORIGIN+STACKWIDTH*2	; 5
       sta_val(i+6) and									// sta ~:STACKORIGIN			; 6
       lda_stack(i+7) and								// lda :STACKORIGIN+STACKWIDTH*3	; 7
       sta_val(i+8) then								// sta ~:STACKORIGIN			; 8
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
	listing[i]   := #9'sty ' + copy(listing[i+4], 6, 256);
	listing[i+1] := #9'sty ' + copy(listing[i+6], 6, 256);
	listing[i+2] := #9'sty ' + copy(listing[i+8], 6, 256);
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

      	Result:=false; Break;
     end;


    if sta_stack(i) and									// sta :STACKORIGIN+STACKWIDTH		; 0
       sty_stack(i+1) and								// sty :STACKORIGIN+STACKWIDTH*2	; 1
       sty_stack(i+2) and								// sty :STACKORIGIN+STACKWIDTH*3	; 2
       lda_stack(i+3) and								// lda :STACKORIGIN+STACKWIDTH		; 3
       sta_stack(i+4) and								// sta :STACKORIGIN+STACKWIDTH*2	; 4
       lda(i+5) then									// lda					; 5
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
        (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i+1] := #9'sta ' + copy(listing[i+1], 6, 256);

	listing[i+3] := '';
	listing[i+4] := '';

      	Result:=false; Break;
     end;


    if sta_stack(i) and									// sta :STACKORIGIN+STACKWIDTH+11	; 0
       lda_stack(i+1) and								// lda :STACKORIGIN+11			; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       add_sub_stack(i+4) and								// add|sub :STACKORIGIN+STACKWIDTH+11	; 4
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_stack(i+6) and								// lda :STACKORIGIN+9			; 6
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
        (copy(listing[i], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) then
     begin
	listing[i+6] := listing[i+1];

	listing[i+1] := '';
	listing[i+2] := '';

      	Result:=false; Break;
     end;


    if sta_stack(i) and									// sta :STACKORIGIN+9			; 0
       ldy(i+1) and									// ldy					; 1
       mva_stack(i+2) then								// mva :STACKORIGIN+9 ...		; 2
     if pos(copy(listing[i], 6, 256), listing[i+2]) > 0 then
       begin
	tmp:=copy(listing[i], 6, 256);

	listing[i+2] := #9'sta' + copy(listing[i+2], 6 + length(tmp), 256);

	listing[i] := '';

	Result:=false; Break;
       end;


    if sta_stack(i) and									// sta :STACKORIGIN+10			; 0
       ldy(i+1) and									// ldy					; 1
       lda_stack(i+2) and								// lda :STACKORIGIN+10			; 2
       sta(i+3) and iy(i+3) then							// sta (:bp),y				; 3
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+2] := '';
	Result:=false; Break;
      end;


    if lda_a(i) and (iy(i) = false) and							// lda					; 0
       (lda_a(i+1) or mva(i+1) or mwa(i+1)) then					// lda|mva|mwa				; 1
     begin
      listing[i] := '';
      Result:=false; Break;
     end;


    if lda_a(i) and iy(i) and								// lda  ,y				; 0
       lda_a(i+1) and (iy(i+1) = false) then						// lda					; 1
     begin
      listing[i] := '';
      Result:=false; Break;
     end;


    if lda_a(i) and iy(i) and								// lda  ,y				; 0
       lda_a(i+1) and iy(i+1) then							// lda  ,y				; 1
     begin
      listing[i] := '';
      Result:=false; Break;
     end;

{
    if sta_stack(i) and									// sta :STACKORIGIN			; 0
       lda_stack(i+1) and								// lda :STACKORIGIN			; 1
       (add_im_0(i+2) = false) and (cmp(i+2) = false) then				//~add #$00|~cmp			; 2
     if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin
       listing[i+1] := '';

       if (asl(i+2) = false) and (lsr(i+2) = false) then listing[i] := '';		// !!!

       Result:=false; Break;
     end;
}

// -----------------------------------------------------------------------------


    if lda_stack(i) and									// lda :STACKORIGIN			; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       add_stack(i+3) and								// add :STACKORIGIN+STACKWIDTH		; 3
       tay(i+4) then									// tay					; 4
     if (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) then
     begin
	listing[i+1] := '';
	listing[i+2] := #9'add ' + copy(listing[i+2], 6, 256);
	listing[i+3] := '';

      	Result:=false; Break;
     end;


  if add_sub(i) and									// add|sub				; 0
     sta_stack(i+1) and									// sta :STACKORIGIN+9			; 1
     lda(i+2) and									// lda					; 2
     adc_sbc(i+3) and									// adc|sbc				; 3
     sta_stack(i+4) and									// sta :STACKORIGIN+STACKWIDTH+9	; 4
     lda(i+5) and									// lda					; 5
     adc_sbc(i+6) and									// adc|sbc				; 6
     sta(i+7) and									// sta :STACKORIGIN+STACKWIDTH*2+9	; 7
     lda(i+8) and									// lda					; 8
     adc_sbc(i+9) and									// adc|sbc				; 9
     sta(i+10) then 									// sta :STACKORIGIN+STACKWIDTH*3+9	; 10
   begin


    if (i+22 = l-1) and
       lda(i+17) and									// lda					; 17
       adc_sbc(i+18) and								// adc|sbc				; 18
       sta_stack(i+19) and								// sta :STACKORIGIN+STACKWIDTH*2	; 19
       lda(i+20) and									// lda					; 20
       adc_sbc(i+21) and								// adc|sbc				; 21
       sta_stack(i+22) then								// sta :STACKORIGIN+STACKWIDTH*3	; 22
      begin										//~
	listing[i+17] := '';
	listing[i+18] := '';
	listing[i+19] := '';
	listing[i+20] := '';
	listing[i+21] := '';
	listing[i+22] := '';

	Result:=false; Break;
      end;


    if lda_stack(i+11) and								// lda :STACKORIGIN+9			; 11
       (and_ora_eor(i+12) or add_sub(i+12)) and						// and|ora|eor|add|sub			; 12
       sta(i+13) then									// sta					; 13
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and			//~lda :STACKORIGIN+STACKWIDTH+9	; 14
	(copy(listing[i+4], 6, 256) <> copy(listing[i+14], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false; Break;
       end;


    if lda_stack(i+11) and								// lda :STACKORIGIN+9			; 11
       (and_ora_eor(i+12) or add_sub(i+12)) and						// and|ora|eor|add|sub			; 12
       ldy(i+13) and									// ldy					; 13
       sta(i+14) and									// sta ,y				; 14
       (lda(i+15) = false) then								//~lda 				; 15
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false; Break;
       end;


    if lda_stack(i+11) and								// lda :STACKORIGIN+9			; 11
       (and_ora_eor(i+12) or add_sub(i+12)) and						// and|ora|eor|add|sub			; 12
       sta(i+13) and									// sta					; 13
       lda_stack(i+14) and								// lda :STACKORIGIN+STACKWIDTH+9	; 14
       (and_ora_eor(i+15) or adc_sbc(i+15)) and						// and|ora|eor|adc|sbc			; 15
       sta(i+16) then									// sta					; 16
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and			//~lda :STACKORIGIN+STACKWIDTH*2+9	; 17
	(copy(listing[i+4], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+7], 6, 256) <> copy(listing[i+17], 6, 256)) then
       begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false; Break;
       end;


    if lda(i+11) and									// lda					; 11
       add_sub(i+12) and								// add|sub				; 12
       sta_stack(i+13) and								// sta :STACKORIGIN+10			; 13
       ldy_stack(i+14) and								// ldy :STACKORIGIN+STACKWIDTH+9	; 14
       sty_bp_1(i+15) and								// sty :bp+1				; 15
       ldy_stack(i+16) and								// ldy :STACKORIGIN+9			; 16
       lda_stack(i+17) and								// lda :STACKORIGIN+10			; 17
       sta_bp_y(i+18) then								// sta (:bp),y				; 18
     if (copy(listing[i+1], 6, 256) = copy(listing[i+16], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+14], 6, 256)) and
	(copy(listing[i+13], 6, 256) = copy(listing[i+17], 6, 256)) then
       begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false; Break;
       end;


    if lda_stack(i+11) and								// lda :STACKORIGIN+9			; 11
       add_sub(i+12) and								// add|sub				; 12
       tay(i+13) and									// tay					; 13
       lda_stack(i+14) and								// lda :STACKORIGIN+STACKWIDTH+9	; 14
       adc_sbc(i+15) and								// adc|sbc				; 15
       sta_bp_1(i+16) and								// sta :bp+1				; 16
       lda(i+17) and									// lda 					; 17
       sta_bp_y(i+18) then								// sta (:bp),y				; 18
     if (copy(listing[i+1], 6, 256) = copy(listing[i+11], 6, 256)) and
	(copy(listing[i+4], 6, 256) = copy(listing[i+14], 6, 256)) then
       begin
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';

	Result:=false; Break;
       end;


    end;


// -----------------------------------------------------------------------------


    if scc(i) and									// scc					; 0
       inc_stack(i+1) and								// inc :STACKORIGIN+STACKWIDTH		; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       (add_sub(i+3) or and_ora_eor(i+3)) and						// add|sub|and|ora|eor			; 3
       (add_sub(i+4) or and_ora_eor(i+4)) and						// add|sub|and|ora|eor			; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i+1], 6, 256) <> copy(listing[i+3], 6, 256)) and
	(copy(listing[i+1], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i] := '';
	listing[i+1] := '';

	Result:=false; Break;
       end;


    if (l = i + 8) and
       lsr_a(i) and									// lsr @				; 0
       ror_stack(i+1) and								// ror :STACKORIGIN+STACKWIDTH*2	; 1
       ror_stack(i+2) and								// ror :STACKORIGIN+STACKWIDTH		; 2
       ror_stack(i+3) and								// ror :STACKORIGIN			; 3
       lda_stack(i+4) and								// lda :STACKORIGIN			; 4
       sta(i+5) and									// sta					; 5
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH		; 6
       sta(i+7) then									// sta					; 7
     if (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+4], 6, 256)) then
     begin
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'lsr @';

      	Result:=false; Break;
     end;


    if lsr_a(i) and									// lsr @				; 0
       ror_stack(i+1) and								// ror :STACKORIGIN+STACKWIDTH*2	; 1
       ror_stack(i+2) and								// ror :STACKORIGIN+STACKWIDTH		; 2
       ror_stack(i+3) and								// ror :STACKORIGIN			; 3
       lda_stack(i+4) and								// lda :STACKORIGIN+STACKWIDTH*2	; 4
       lsr_a(i+5) and									// lsr @				; 5
       ror_stack(i+6) and								// ror :STACKORIGIN+STACKWIDTH		; 6
       ror_stack(i+7) then								// ror :STACKORIGIN			; 7
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+2], 6, 256) = copy(listing[i+6], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+7], 6, 256)) then
     begin
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := #9'lsr @';

	listing[i+4] := '';

      	Result:=false; Break;
     end;


// -----------------------------------------------------------------------------


    if (l = i + 2) and
       sta_a(i) and									// sta					; 0
       iny(i+1) then									// iny					; 1
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------


  if (l = i + 3) then begin


    if lda_a(i) and									// lda					; 0
       (add_im_0(i+1) or sub_im_0(i+1)) and						// add|sub #$00				; 1
       sta_val(i+2) then								// sta					; 2	~:STACKORIGIN
     begin
	listing[i+1] := '';

	Result:=false; Break;
     end;


    if lda_im_0(i) and									// lda #$00				; 0
       add(i+1) and (add_im_0(i+1) = false) and						// add					; 1
       sta_val(i+2) then								// sta					; 2	~:STACKORIGIN
     begin
	listing[i]   := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+1] := '';

	Result:=false; Break;
     end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       ldy(i+1) and 									// ldy					; 1
       sta_val(i+2) then								// sta					; 2	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       add_sub(i+1) and 								// add|sub				; 1
       sta_val(i+2) then								// sta					; 2	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       sta_val(i+2) then								// sta					; 2	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if sta_a(i) and									// sta					; 0
       iny(i+1) and									// iny					; 1
       iny(i+2) then									// iny					; 2
      begin
	listing[i+2] := '';

	Result:=false; Break;
      end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       sta_val(i+2) then								// sta					; 2	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


  end;


// -----------------------------------------------------------------------------


  if (l = i + 4) then begin


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       sta_val(i+1) and									// sta					; 1	~:STACKORIGIN
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       add_sub(i+1) and									// add|sub				; 1
       add_sub(i+2) and									// add|sub				; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       add_sub(i+1) and									// add|sub				; 1
       and_ora_eor(i+2) and								// and|ora|eor				; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       add_sub_val(i+2) and								// add|sub				; 2	~:STACKORIGIN
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and									// asl @				; 1
       add_sub_stack(i+2) and								// add|sub :STACKORIGIN			; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and									// asl @				; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       (lda(i+1) or ldy(i+1)) and							// lda					; 1
       (ldy(i+2) or lda_a(i+2)) and							// ldy					; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       (add_sub(i+2) or and_ora_eor(i+2)) and						// add|sub|and|ora|eor			; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       asl_stack(i+1) and								// asl :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       sta_val(i+3) then								// sta					; 3	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


  end;


// -----------------------------------------------------------------------------


  if (l = i + 5) then begin


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       add_sub(i+1) and 								// add|sub				; 1
       tay(i+2) and									// tay					; 2
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       add_sub(i+1) and									// add|sub				; 1
       add_sub(i+2) and									// add|sub				; 2
       and_ora_eor(i+3) and								// and|ora|eor				; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       add_sub_stack(i+3) and								// add|sub :STACKORIGIN			; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0		2023-02-05
       asl_a(i+1) and									// asl @				; 1
       add_sub_val(i+2) and								// add|sub				; 2
       and_ora_eor(i+3) and								// and|ora|eor				; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       sta_val(i+2) and									// sta					; 2	~:STACKORIGIN
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and									// asl @				; 2
       asl_a(i+3) and									// asl @				; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if ldy_im_0(i) and									// ldy #$00				; 0
       lda_a(i+1) and									// lda					; 1
       spl(i+2) and									// spl					; 2
       dey(i+3) and									// dey					; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
     end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda :STACKORIGIN			; 1
       sta_val(i+2) and									// sta					; 2	~:STACKORIGIN
       lda_a(i+3) and									// lda :STACKORIGIN+STACKWIDTH		; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       (add_sub(i+2) or and_ora_eor(i+2)) and						// add|sub|and|ora|eor			; 2
       ldy(i+3) and									// ldy					; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       (add_sub(i+2) or and_ora_eor(i+2)) and						// add|sub|and|ora|eor			; 2
       (add_sub(i+3) or and_ora_eor(i+3)) and						// add|sub|and|ora|eor			; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda :STACKORIGIN			; 1
       (add_sub(i+2) or and_ora_eor(i+2)) and						// add|sub|and|ora|eor			; 2
       tay(i+3) and									// tay					; 3
       lda_a(i+4) and									// lda					; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       asl_stack(i+1) and								// asl :STACKORIGIN			; 1
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       (add_sub_stack(i+3) or and_ora_eor_stack(i+3)) and				// add|sub|and|ora|eor :STACKORIGIN	; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       asl_stack(i+1) and								// asl :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       (add_sub(i+3) or and_ora_eor(i+3)) and						// add|sub|and|ora|eor			; 3
       sta_val(i+4) then								// sta					; 4	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


  end;


// -----------------------------------------------------------------------------


  if (l = i + 6) then begin


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       sta_val(i+1) and									// sta					; 1	~:STACKORIGIN
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       asl_a(i+3) and									// asl @				; 3
       add_sub_stack(i+4) and								// add|sub :STACKORIGIN			; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0		2023-02-05
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       add_sub_val(i+3) and								// add|sub				; 3
       and_ora_eor(i+4) and								// and|ora|eor				; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       add_sub_val(i+2) and								// add|sub				; 2
       add_sub_val(i+3) and								// add|sub				; 3
       and_ora_eor(i+4) and								// and|ora|eor				; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and									// asl @				; 2
       asl_a(i+3) and									// asl @				; 3
       asl_a(i+4) and									// asl @				; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       add_sub_val(i+2) and								// add|sub				; 2	~:STACKORIGIN
       asl_a(i+3) and									// asl @				; 3
       add_sub_val(i+4) and								// add|sub				; 4	~:STACKORIGIN
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if and_ora_eor(i) and								// and|ora|eor				; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_stack(i+2) and								// lda :STACKWIDTH			; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_stack(i+4) and								// lda :STACKORIGIN+STACKWIDTH		; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) then
	begin
	  listing[i+1] := listing[i+5];

	  listing[i+4] := '';
	  listing[i+5] := '';

	  Result:=false; Break;
	end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       sta_val(i+2) and									// sta					; 2	~:STACKORIGIN
       lda_im(i+3) and									// lda #				; 3
       (add_sub(i+4) or and_ora_eor(i+4)) and						// add|sub|and|ora|eor			; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       (add_sub(i+2) or and_ora_eor(i+2) or asl_a(i+2) or lsr_a(i+2)) and		// add|sub|and|ora|eor|asl @|lsr @	; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_a(i+4) and									// lda					; 4
       sta_val(i+5) then								// sta					; 5	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


  end;


// -----------------------------------------------------------------------------


  if (l = i + 7) then begin


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       sta_val(i+2) and									// sta					; 2	~:STACKORIGIN
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       sta_val(i+4) and									// sta					; 4	~:STACKORIGIN
       lda_val(i+5) and									// lda					; 5	~:STACKORIGIN
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       asl_a(i+3) and									// asl @				; 3
       asl_a(i+4) and									// asl @				; 4
       add_sub_stack(i+5) and								// add|sub :STACKORIGIN			; 5
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+5], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN+STACKWIDTH		; 2
       add_sub_val(i+3) and								// add|sub				; 3	~:STACKORIGIN
       sta_val(i+4) and									// sta					; 4	~:STACKORIGIN
       lda_stack(i+5) and								// lda :STACKORIGIN			; 5
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+1] := listing[i+6];

	listing[i+5] := '';
	listing[i+6] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and									// asl @				; 2
       asl_a(i+3) and									// asl @				; 3
       asl_a(i+4) and									// asl @				; 4
       asl_a(i+5) and									// asl @				; 5
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and									// asl @				; 2
       add_sub_val(i+3) and								// add|sub				; 3	~:STACKORIGIN
       asl_a(i+4) and									// asl @				; 4
       add_sub_val(i+5) and								// add|sub				; 5	~:STACKORIGIN
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_val(i+1) and									// lda 					; 1	~:STACKORIGIN
       sta_val(i+2) and									// sta TMP				; 2	~:STACKORIGIN
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       sta_val(i+4) and									// sta TMP+1				; 4	~:STACKORIGIN
       lda_val(i+5) and									// lda					; 5	~:STACKORIGIN
       sta_val(i+6) then								// sta TMP+2				; 6	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       asl_stack(i+1) and								// asl :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       (add_sub(i+3) or and_ora_eor(i+3)) and						// add|sub|and|ora|eor			; 3
       sta_val(i+4) and									// sta					; 4	~:STACKORIGIN
       lda_val(i+5) and									// lda					; 5	~:STACKORIGIN
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       (add_sub(i+2) or and_ora_eor(i+2)) and						// add|sub|and|ora|eor			; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_a(i+4) and									// lda					; 4
       (adc_sbc(i+5) or and_ora_eor(i+5)) and						// adc|sbc|and|ora|eor			; 5
       sta_val(i+6) then								// sta					; 6	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+5], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


  end;


// -----------------------------------------------------------------------------


  if (l = i + 8) then begin


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       sta_val(i+1) and									// sta					; 1	~:STACKORIGIN
       lda_val(i+2) and									// lda					; 2	~:STACKORIGIN
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       add_sub_val(i+2) and								// add|sub				; 2	~:STACKORIGIN
       asl_a(i+3) and									// asl @				; 3
       add_sub_val(i+4) and								// add|sub				; 4	~:STACKORIGIN
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       mwy(i+1) and									// mwy					; 1
       ldy_im(i+2) and									// ldy #				; 2
       lda(i+3) and									// lda					; 3
       sta_bp2_y(i+4) and								// sta (:bp2),y				; 4
       iny(i+5) and									// iny					; 5
       lda(i+6) and									// lda					; 6
       sta_bp2_y(i+7) then								// sta (:bp2),y				; 7
     if (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+6], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       iny(i+1) and									// iny					; 1
       lda_a(i+2) and									// lda					; 2
       (add_sub(i+3) or and_ora_eor(i+3)) and						// add|sub|and|ora|eor			; 3
       sta_val(i+4) and									// sta					; 4	~:STACKORIGIN
       lda_a(i+5) and									// lda					; 5
       (adc_sbc(i+6) or and_ora_eor(i+6)) and						// adc|sbc|and|ora|eor			; 6
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
     if (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+5], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+6], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if UNUSED_A(i) and									// UNUSED_A				; 0
       lda_a(i+1) and									// lda					; 1
       asl_a(i+2) and									// asl @				; 2
       tay(i+3) and									// tay					; 3
       lda_a(i+4) and									// lda					; 4
       sta_a(i+5) and									// sta					; 5
       lda_a(i+6) and									// lda					; 6
       sta_a(i+7) then									// sta					; 7
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+6], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


  end;


// -----------------------------------------------------------------------------


    if (l = i + 9) and
       rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       sta_val(i+2) and									// sta					; 2	~:STACKORIGIN
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       sta_val(i+4) and									// sta					; 4	~:STACKORIGIN
       lda_val(i+5) and									// lda					; 5	~:STACKORIGIN
       sta_val(i+6) and									// sta					; 6	~:STACKORIGIN
       lda_val(i+7) and									// lda					; 7	~:STACKORIGIN
       sta_val(i+8) then								// sta					; 8	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if (l = i + 9) and
       rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0		2023-01-26
       add_sub_val(i+1) and								// add|sub W				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda_val(i+3) and									// lda					; 3	~:STACKORIGIN
       add_sub_stack(i+4) and								// add|sub :STACKORIGIN			; 4
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       adc_sbc_im_0(i+7) and								// adc|sbc #$00				; 7
       sta_val(i+8) then								// sta					; 8	~:STACKORIGIN
    if (copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
       (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if (l = i + 9) and
       asl_a(i) and									// asl @				; 0
       rol_stack(i+1) and								// rol :STACKORIGIN+STACKWIDTH		; 1
       asl_a(i+2) and									// asl @				; 2
       add_sub_val(i+3) and								// add|sub				; 3	~:STACKORIGIN
       asl_a(i+4) and									// asl @				; 4
       add_sub_val(i+5) and								// add|sub				; 5	~:STACKORIGIN
       sta_val(i+6) and									// sta					; 6	~:STACKORIGIN
       lda_val(i+7) and									// lda					; 7	~:STACKORIGIN
       sta_val(i+8) then								// sta					; 8	~:STACKORIGIN
      begin
	listing[i+1] := '';

	Result:=false; Break;
      end;


    if //(l = i + 9) and
       UNUSED_A(i) and									// UNUSED_A				; 0
       lda(i+1) and									// lda					; 1
       (add_sub(i+2) or and_ora_eor(i+2)) and						// add|sub|and|ora|eor			; 2
       tay(i+3) and									// tay					; 3
       lda(i+4) and									// lda					; 4
       (adc_sbc(i+5) or and_ora_eor(i+5)) and						// adc|sbc|and|ora|eor			; 5
       sta_bp_1(i+6) and								// sta :bp+1				; 6
       lda(i+7) and									// lda					; 7
       sta_bp_y(i+8) then								// sta (:bp),y				; 8
     if (copy(listing[i], 6, 256) <> copy(listing[i+1], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
        (copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+5], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+7], 6, 256)) then
       begin
	listing[i] := '';

	Result:=false; Break;
       end;


    if (l = i + 10) and
       rol_stack(i) and									// rol :STACKORIGIN			; 0
       asl_a(i+1) and									// asl @				; 1
       asl_a(i+2) and									// asl @				; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       sta_val(i+7) and									// sta					; 7	~:STACKORIGIN
       lda_val(i+8) and									// lda					; 8	~:STACKORIGIN
       sta_val(i+9) then								// sta					; 9	~:STACKORIGIN
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if (l = i + 10) and
       rol_stack(i) and									// rol :STACKORIGIN+STACKWIDTH		; 0		2023-01-26
       asl_a(i+1) and									// asl @				; 1
       add_sub_val(i+2) and								// add|sub W				; 2	~:STACKORIGIN
       sta_stack(i+3) and								// sta :STACKORIGIN			; 3
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       add_sub_stack(i+5) and								// add|sub :STACKORIGIN			; 5	~:STACKORIGIN
       sta_val(i+6) and									// sta A				; 6	~:STACKORIGIN
       lda_val(i+7) and									// lda					; 7	~:STACKORIGIN
       adc_sbc_im_0(i+8) and								// adc|sbc #$00				; 8
       sta_val(i+9) then								// sta A+1				; 9	~:STACKORIGIN
    if (copy(listing[i], 6, 256) <> copy(listing[i+3], 6, 256)) and
       (copy(listing[i], 6, 256) <> copy(listing[i+5], 6, 256)) then
      begin
	listing[i] := '';

	Result:=false; Break;
      end;


    if (l = i + 11) and
       lda(i) and (lda_stack(i) = false) and						// lda					; 0		~lda adr.
       add_sub_im(i+1) and								// add|sub #				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN			; 2
       lda(i+3) and (lda_stack(i+3) = false) and					// lda					; 3		~lda adr.
       adc_sbc_im(i+4) and								// adc|sbc #				; 4
       and_ora_eor(i+5) and								// and|ora|eor				; 5
       sta_stack(i+6) and								// sta :STACKORIGIN+STACKWIDTH		; 6
       lda_stack(i+7) and								// lda :STACKWIDTH			; 7
       sta_val(i+8) and									// sta					; 8	~:STACKORIGIN
       lda_stack(i+9) and								// lda :STACKORIGIN+STACKWIDTH		; 9
       sta_val(i+10) then								// sta					; 10	~:STACKORIGIN
     if (copy(listing[i+2], 6, 256) = copy(listing[i+7], 6, 256)) and
	(copy(listing[i+6], 6, 256) = copy(listing[i+9], 6, 256)) then
	begin
	  p := GetWORD(i+1, i+4);

	  if (p = 1) and add_im(i+1) and
	     (copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) and
	     (copy(listing[i+3], 6, 256) = copy(listing[i+10], 6, 256)) then
	  begin
	   listing[i]   := #9'inc ' + copy(listing[i], 6, 256);
	   listing[i+1] := #9'sne';
	   listing[i+2] := #9'inc ' + copy(listing[i+3], 6, 256);

	   listing[i+4] := '';

	   listing[i+6] := '';
	   listing[i+7] := '';
	   listing[i+8] := '';
	   listing[i+9] := '';
	  end else begin
	   listing[i+2] := listing[i+8];

	   listing[i+6] := listing[i+10];

	   listing[i+7] := '';
	   listing[i+8] := '';
	   listing[i+9] := '';
	   listing[i+10]:= '';
	  end;

	  Result:=false; Break;
	end;


    if (l = i + 11) and
       ldy(i) and									// ldy					; 0
       beq(i+1) and									// beq l_				; 1
       lab_l(i+2) and									//l_					; 2
       asl_a(i+3) and									// asl @				; 3
       rol_stack(i+4) and								// rol :STACKORIGIN+STACKWIDTH		; 4
       rol_stack(i+5) and								// rol :STACKORIGIN+STACKWIDTH*2	; 5
       rol_stack(i+6) and								// rol :STACKORIGIN+STACKWIDTH*3	; 6
       dey(i+7) and									// dey					; 7
       bne(i+8) and									// bne l_				; 8
       lab_l(i+9) and									//l_					; 9
       sta_a(i+10) then									// sta 					; 10
       begin
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	if ldy_im(i) and (GetBYTE(i) > 7) then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';

	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda #$00';
	end;

	Result:=false; Break;
       end;


    if (l = i + 12) and
       lda_stack(i) and									// lda :STACKORIGIN			; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and 								// lda					; 2	~:STACKORIGIN
       sta_stack(i+3) and								// sta :STACKORIGIN			; 3
       lda_val(i+4) and									// lda					; 4	~:STACKORIGIN
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_val(i+6) and									// lda					; 6	~:STACKORIGIN
       sta_val(i+7) and									// sta					; 7	~:STACKORIGIN
       lda_stack(i+8) and								// lda :STACKORIGIN			; 8
       sta_val(i+9) and									// sta					; 9	~:STACKORIGIN
       lda_stack(i+10) and								// lda :STACKORIGIN+STACKWIDTH		; 10
       sta_val(i+11) then								// sta					; 11	~:STACKORIGIN
     if (copy(listing[i], 6, 256) = copy(listing[i+3], 6, 256)) and
	(copy(listing[i], 6, 256) = copy(listing[i+8], 6, 256)) and
	(copy(listing[i+1], 6, 256) = copy(listing[i+10], 6, 256)) then
       begin
	listing[i+8]  := listing[i+2];

	listing[i+10] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
       end;


    if (l = i + 13) and
       ldy(i) and									// ldy					; 0
       beq(i+1) and									// beq l_				; 1
       lab_l(i+2) and									//l_					; 2
       asl_a(i+3) and									// asl @				; 3
       rol_stack(i+4) and								// rol :STACKORIGIN+STACKWIDTH		; 4
       rol_stack(i+5) and								// rol :STACKORIGIN+STACKWIDTH*2	; 5
       rol_stack(i+6) and								// rol :STACKORIGIN+STACKWIDTH*3	; 6
       dey(i+7) and									// dey					; 7
       bne(i+8) and									// bne l_				; 8
       lab_l(i+9) and									//l_					; 9
       sta_val(i+10) and								// sta ~:STACKORIGIN			; 10
       lda_stack(i+11) and								// lda :STACKORIGIN+STACKWIDTH		; 11
       sta_a(i+12) then									// sta 					; 12
     if (copy(listing[i+4], 6, 256) = copy(listing[i+11], 6, 256)) then
       begin
	listing[i+5] := '';
	listing[i+6] := '';

	if ldy_im(i) and (GetBYTE(i) > 15) then begin
	 listing[i]   := '';
	 listing[i+1] := '';
	 listing[i+2] := '';
	 listing[i+3] := '';
	 listing[i+4] := '';

	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := #9'lda #$00';

	 listing[i+11] := '';
	end;

	Result:=false; Break;
       end;


    if asl_stack(i) and (listing[i] = listing[i+4]) and					// asl :STACKORIGIN			; 0
       rol_stack(i+1) and (listing[i+1] = listing[i+5]) and				// rol :STACKORIGIN+STACKWIDTH		; 1
       rol_stack(i+2) and (listing[i+2] = listing[i+6]) and				// rol :STACKORIGIN+STACKWIDTH*2	; 2
       rol_stack(i+3) and (listing[i+3] <> listing[i+7]) then				// rol :STACKORIGIN+STACKWIDTH*3	; 3
//     asl_stack(i+4) and								// asl :STACKORIGIN			; 4
//     rol_stack(i+5) and								// rol :STACKORIGIN+STACKWIDTH		; 5
//     rol_stack(i+6) and								// rol :STACKORIGIN+STACKWIDTH*2	; 6
//     (rol_stack(i+7) = false) then							//~rol :STACKORIGIN+STACKWIDTH*3	; 7
     begin
	listing[i+3] := '';

	exit(false);
     end;


    if lda_stack(i) and									// lda :STACKORIGIN+STACKWIDTH*2	; 0
       sta_stack(i+1) and								// sta :STACKORIGIN+STACKWIDTH*3	; 1
       lda_a(i+2) and									// lda					; 2
       sta_val(i+3) and									// sta					; 3	~:STACKORIGIN
       lda_a(i+4) and									// lda					; 4
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_stack(i+6) and								// lda :STACKORIGIN+STACKWIDTH*3	; 6
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
     if (copy(listing[i+1], 6, 256) = copy(listing[i+6], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i], 6, 256) <> copy(listing[i+4], 6, 256)) and
	(copy(listing[i+1], 6, 256) <> copy(listing[i+2], 6, 256)) and
	(copy(listing[i+1], 6, 256) <> copy(listing[i+4], 6, 256)) then
       begin
	listing[i+6] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';

	Result:=false; Break;
       end;


    if lda_val(i) and									// lda A 				; 0	~:STACKORIGIN
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_val(i+2) and									// lda A+1				; 2	~:STACKORIGIN
       asl_stack(i+3) and								// asl :STACKORIGIN			; 3
       rol_a(i+4) and									// rol @				; 4
       sta_val(i+5) and									// sta					; 5	~:STACKORIGIN
       lda_stack(i+6) and								// lda :STACKORIGIN			; 6
       sta_val(i+7) then								// sta					; 7	~:STACKORIGIN
      if (copy(listing[i], 6, 256) = copy(listing[i+7], 6, 256)) and
	 (copy(listing[i+2], 6, 256) = copy(listing[i+5], 6, 256)) and
	 (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+6], 6, 256)) then
       begin
	listing[i+6] := #9'asl ' + copy(listing[i], 6, 256);
	listing[i+7] := #9'rol ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	Result:=false; Break;
       end;


    if lda_val(i) and									// lda Y 				; 0	~:STACKORIGIN
       sta_stack(i+1) and								// sta :STACKORIGIN			; 1
       lda_val(i+2) and									// lda Y+1				; 2	~:STACKORIGIN
       asl_stack(i+3) and								// asl :STACKORIGIN			; 3
       rol_a(i+4) and									// rol @				; 4
       asl_stack(i+5) and								// asl :STACKORIGIN			; 5
       rol_a(i+6) and									// rol @				; 6
       sta_val(i+7) and									// sta					; 7	~:STACKORIGIN
       lda_stack(i+8) and								// lda :STACKORIGIN			; 8
       sta_val(i+9) then								// sta					; 9	~:STACKORIGIN
      if (copy(listing[i], 6, 256) <> copy(listing[i+9], 6, 256)) and
         (copy(listing[i+1], 6, 256) = copy(listing[i+3], 6, 256)) and
	 (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) and
	 (copy(listing[i+5], 6, 256) = copy(listing[i+8], 6, 256)) then
       begin
	listing[i+1] := listing[i+9];

	listing[i+3] := #9'asl ' + copy(listing[i+1], 6, 256);

	listing[i+5] := #9'asl ' + copy(listing[i+1], 6, 256);

	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
       end;


    if lda(i) and									// lda TT 				; 0
       asl_a(i+1) and									// asl @				; 1
       sta(i+2) then									// sta TT				; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := #9'asl ' + copy(listing[i], 6, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
       end;


    if sta_stack(i) and									// sta :STACKORIGIN+9			; 0
       asl_stack(i+1) and								// asl :STACKORIGIN+9			; 1
       lda_val(i+2) then								// lda					; 2	~:STACKORIGIN
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
      begin
	listing[i+1] := listing[i];

	listing[i] := #9'asl @';

	Result:=false; Break;
      end;


    if sta_stack(i) and 								// sta :STACKORIGIN+10			; 0
       lda_val(i+1) and									// lda 					; 1	~:STACKORIGIN
       ora_stack(i+2) then								// ora :STACKORIGIN+10			; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
       begin
	listing[i] := '';
	listing[i+1] := #9'ora ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	Result:=false; Break;
       end;

