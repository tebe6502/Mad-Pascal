// -----------------------------------------------------------------------------
// ===				      PRINT.
// -----------------------------------------------------------------------------

    if lda_im(i) and										// lda #				; 0
       ldy_im(i+1) and										// ldy #				; 1
       (listing[i+2] = #9'jsr @printSTRING') then						// jsr @printSTRING			; 2
      begin
        p:=GetWORD(i+0, i+1);

	listing[i+2] := #9'@printSTRING #$' + IntToHex(p, 4);

	listing[i]   := '';
	listing[i+1] := '';

 	Result:=false; Break;
      end;


    if lda_a(i) and (lda_stack(i) = false) and							// lda 					; 0
       ldy(i+1) and										// ldy					; 1
       (listing[i+2] = #9'jsr @printSTRING') then						// jsr @printSTRING			; 2
      begin
        tmp := copy(listing[i], 6, 256);

	if tmp + '+1' = copy(listing[i+1], 6, 256) then begin
	  listing[i+2] := #9'@printSTRING ' + tmp;

	  listing[i]   := '';
	  listing[i+1] := '';

  	  Result:=false; Break;
	end;

      end;


    if lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       ldy_stack(i+5) and									// ldy :STACKORIGIN+STACKWIDTH		; 5
       (listing[i+6] = #9'jsr @printSTRING') then						// jsr @printSTRING			; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+4], 6, 256)) and
        (copy(listing[i+3], 6, 256) = copy(listing[i+5], 6, 256)) then
      begin
	listing[i+4] := listing[i];
	listing[i+5] := #9'ldy ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	if dex(i+7) then
	 for p:=i-1 downto 0 do
	  if jsr(p) then Break else
	   if inx(p) then begin listing[i+7] := ''; listing[p] := ''; Break end;

  	Result:=false; Break;
      end;


    if mva_im(i) and										// mva #  :STACKORIGIN			; 0
       (listing[i+1] = #9'@printCHAR') then							// @printCHAR				; 1
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) then
      begin
	listing[i+1] := #9'@print ' + GetString(i);

	listing[i]   := '';

	Result:=false; Break;
      end;


    if (pos('mva adr.', listing[i]) > 0) and iy(i) and						// mva adr. ,y  :STACKORIGIN		; 0
       (listing[i+1] = #9'@printCHAR') then							// @printCHAR				; 1
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) then
      begin
	listing[i]   := #9'lda ' + GetString(i);
	listing[i+1] := #9'@print @';

	if dex(i+2) then
	 for p:=i-1 downto 0 do
	  if jsr(p) then Break else
	   if inx(p) then begin listing[i+2] := ''; listing[p] := ''; Break end;

	Result:=false; Break;
      end;


    if inx(i) and										// inx					; 0
       (pos(#9'@print', listing[i+1]) > 0) then							// @print				; 1
      begin

        p:=i+1;
	while pos(#9'@print', listing[p]) > 0 do inc(p);

	if dex(p) then begin
	 listing[i] := '';
	 listing[p] := '';

	 Result:=false; Break;
	end;

      end;


    if add_sub_AL_CL(i) and									// jsr addAL_CL|subAL_CL		; 0
       dex(i+1) and										// dex					; 1
       (listing[i+2] = #9'@printCHAR') and							// @printCHAR				; 2
       dex(i+3) then										// dex					; 3
     begin

       if listing[i] = #9'jsr addAL_CL' then
        listing[i] := #9'adb :STACKORIGIN-1,x :STACKORIGIN,x'
       else
        listing[i] := #9'sbb :STACKORIGIN-1,x :STACKORIGIN,x';

       Result:=false; Break;
     end;


    if sta_stack(i) and										// sta :STACKORIGIN,x			; 0
       (listing[i+1] = #9'jsr @printBYTE') then							// jsr @printBYTE			; 1
      begin

        listing[i]   := '';
	listing[i+1] := #9'jsr @printBYTE._a';

	if dex(i+2) then
	 for p:=i-1 downto 0 do
	  if jsr(p) then Break else
	   if inx(p) then begin listing[i+2] := ''; listing[p] := ''; Break end;

	Result:=false; Break;
      end;


    if mva(i) and (iy(i) = false) and								// mva I :STACKORIGIN,x			; 0
       (listing[i+1] = #9'jsr @printBYTE') then							// jsr @printBYTE			; 1
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) then
      begin

        listing[i]   := #9'lda ' + GetString(i);
	listing[i+1] := #9'jsr @printBYTE._a';

	if dex(i+2) then
	 for p:=i-1 downto 0 do
	  if jsr(p) then Break else
	   if inx(p) then begin listing[i+2] := ''; listing[p] := ''; Break end;

	Result:=false; Break;
      end;


    if mva(i) and (iy(i) = false) and								// mva ... :STACKORIGIN,x		; 0
       mva(i+1) and (iy(i+1) = false) and							// mva ... :STACKORIGIN+STACKWIDTH,x	; 1
       (listing[i+2] = #9'jsr @printWORD') then							// jsr @printWORD			; 2
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) and
        (pos(' :STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0 ) then
      begin

        listing[i]   := #9'lda ' + GetString(i);
        listing[i+1] := #9'ldy ' + GetString(i+1);
	listing[i+2] := #9'jsr @printWORD._ay';

	if dex(i+3) then
	 for p:=i-1 downto 0 do
	  if jsr(p) then Break else
	   if inx(p) then begin listing[i+3] := ''; listing[p] := ''; Break end;

	Result:=false; Break;
      end;


    if mva(i) and										// mva ... :STACKORIGIN,x		; 0
       mva(i+1) and										// mva ... :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva ... :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) and										// mva ... :STACKORIGIN+STACKWIDTH*3,x	; 3
       (listing[i+4] = #9'jsr @printCARD') then							// jsr @printCARD			; 4
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) and
        (pos(' :STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0 ) and
        (pos(' :STACKORIGIN+STACKWIDTH*2,x', listing[i+2]) > 0 ) and
        (pos(' :STACKORIGIN+STACKWIDTH*3,x', listing[i+3]) > 0 ) then
      begin

        listing[i]   := #9'mva ' + GetString(i) + ' :dx';
        listing[i+1] := #9'mva ' + GetString(i+1) + ' :dx+1';
        listing[i+2] := #9'mva ' + GetString(i+2) + ' :dx+2';
        listing[i+3] := #9'mva ' + GetString(i+3) + ' :dx+3';
	listing[i+4] := #9'@printVALUE';

	if dex(i+5) then
	 for p:=i-1 downto 0 do
	  if jsr(p) then Break else
	   if inx(p) then begin listing[i+5] := ''; listing[p] := ''; Break end;

	Result:=false; Break;
      end;
