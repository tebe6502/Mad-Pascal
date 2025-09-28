
function opt_STACK_PRINT(i: integer): Boolean;
var p: integer;
    tmp: string;


 function fail(i: integer): Boolean;
 begin

  Result := jsr(i) or
            dex(i) or
            (pos(#9'@print', listing[i]) > 0);

 end;


begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      PRINT.
// -----------------------------------------------------------------------------

    if (listing[i+2] = #9'jsr @printPCHAR') and							// jsr @printPCHAR			; 2

       lda_im(i) and										// lda #				; 0
       ldy_im(i+1) then										// ldy #				; 1
      begin
        p:=GetWORD(i+0, i+1);

	listing[i+2] := #9'@printPCHAR #$' + IntToHex(p, 4);

	listing[i]   := '';
	listing[i+1] := '';

 	exit(false);
      end;


    if (listing[i+2] = #9'jsr @printPCHAR') and							// jsr @printPCHAR			; 2

       lda_val(i) and										// lda ~:STACKORIGIN			; 0
       ldy(i+1) then										// ldy					; 1
      begin
        tmp := copy(listing[i], 6, 256);

	if tmp + '+1' = copy(listing[i+1], 6, 256) then begin
	  listing[i+2] := #9'@printPCHAR ' + tmp;

	  listing[i]   := '';
	  listing[i+1] := '';

  	  exit(false);
	end;

      end;


    if (listing[i+2] = #9'jsr @printSTRING') and						// jsr @printSTRING			; 2

       lda_im(i) and										// lda #				; 0
       ldy_im(i+1) then										// ldy #				; 1
      begin
        p:=GetWORD(i+0, i+1);

	listing[i+2] := #9'@printSTRING #$' + IntToHex(p, 4);

	listing[i]   := '';
	listing[i+1] := '';

 	exit(false);
      end;


    if (listing[i+2] = #9'jsr @printSTRING') and						// jsr @printSTRING			; 2

       lda_val(i) and										// lda ~:STACKORIGIN			; 0
       ldy(i+1) then										// ldy					; 1
      begin
        tmp := copy(listing[i], 6, 256);

	if tmp + '+1' = copy(listing[i+1], 6, 256) then begin
	  listing[i+2] := #9'@printSTRING ' + tmp;

	  listing[i]   := '';
	  listing[i+1] := '';

  	  exit(false);
	end;

      end;


    if ((listing[i+6] = #9'jsr @printSTRING') or (listing[i+6] = #9'@printPCHAR')) and		// jsr @printSTRING|@printPCHAR		; 6

       lda_a(i) and										// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN			; 1
       lda_a(i+2) and (iy(i+2) = false) and							// lda					; 2
       sta_stack(i+3) and									// sta :STACKORIGIN+STACKWIDTH		; 3
       lda_stack(i+4) and									// lda :STACKORIGIN			; 4
       ldy_stack(i+5) then									// ldy :STACKORIGIN+STACKWIDTH		; 5
     if argMatch(i+1, i+4) and
        argMatch(i+3, i+5) then
      begin
	listing[i+4] := listing[i];
	listing[i+5] := #9'ldy ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	if dex(i+7) then
	 for p:=i-1 downto 0 do
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+7] := ''; listing[p] := ''; Break end;

  	exit(false);
      end;


    if ((listing[i+4] = #9'jsr @printSTRING') or (listing[i+4] = #9'@printPCHAR')) and		// jsr @printSTRING|@printPCHAR		; 4

       lda_a(i) and (iy(i) = false) and								// lda 					; 0
       sta_stack(i+1) and									// sta :STACKORIGIN+STACKWIDTH		; 1
       lda_val(i+2) and										// lda ~:STACKORIGIN			; 2
       ldy_stack(i+3) then									// ldy :STACKORIGIN+STACKWIDTH		; 3
     if argMatch(i+1, i+3) then
      begin
	listing[i+3] := #9'ldy ' + copy(listing[i], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	if dex(i+5) then
	 for p:=i-1 downto 0 do
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+5] := ''; listing[p] := ''; Break end;

  	exit(false);
      end;


    if (listing[i+1] = #9'@printCHAR') and							// @printCHAR				; 1

       mva_im(i) then										// mva #  :STACKORIGIN			; 0
//       (listing[i+1] = #9'@printCHAR') then							// @printCHAR				; 1
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) then
      begin
	listing[i+1] := #9'@print ' + GetString(i);

	listing[i]   := '';

	exit(false);
      end;


    if (listing[i+1] = #9'@printCHAR') and							// @printCHAR				; 1

       (pos(#9'mva adr.', listing[i]) > 0) and iy(i) then					// mva adr. ,y  :STACKORIGIN		; 0
//       (listing[i+1] = #9'@printCHAR') then							// @printCHAR				; 1
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) then
      begin
	listing[i]   := #9'lda ' + GetString(i);
	listing[i+1] := #9'@print @';

	if dex(i+2) then
	 for p:=i-1 downto 0 do
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+2] := ''; listing[p] := ''; Break end;

	exit(false);
      end;


    if inx(i) and										// inx					; 0
       (pos(#9'@print', listing[i+1]) > 0) then							// @print				; 1
      begin

        p:=i+1;
	while pos(#9'@print', listing[p]) > 0 do inc(p);

	if dex(p) then begin
	 listing[i] := '';
	 listing[p] := '';

	 exit(false);
	end;

      end;


    if (listing[i+2] = #9'@printCHAR') and							// @printCHAR				; 2

       add_sub_AL_CL(i) and									// jsr addAL_CL|subAL_CL		; 0
       dex(i+1) and										// dex					; 1
//       (listing[i+2] = #9'@printCHAR') and							// @printCHAR				; 2
       dex(i+3) then										// dex					; 3
     begin

       if listing[i] = #9'jsr addAL_CL' then
        listing[i] := #9'adb :STACKORIGIN-1,x :STACKORIGIN,x'
       else
        listing[i] := #9'sbb :STACKORIGIN-1,x :STACKORIGIN,x';

       exit(false);
     end;


    if (listing[i+1] = #9'jsr @printBYTE') and							// jsr @printBYTE			; 1

       sta_stack(i) then									// sta :STACKORIGIN,x			; 0
//       (listing[i+1] = #9'jsr @printBYTE') then						// jsr @printBYTE			; 1
      begin
        listing[i]   := '';
	listing[i+1] := #9'jsr @printBYTE._a';

	if dex(i+2) then
	 for p:=i-1 downto 0 do
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+2] := ''; listing[p] := ''; Break end;

	exit(false);
      end;


    if (listing[i+1] = #9'jsr @printBYTE') and							// jsr @printBYTE			; 1

       mva(i) and (iy(i) = false) then								// mva I :STACKORIGIN,x			; 0
//       (listing[i+1] = #9'jsr @printBYTE') then						// jsr @printBYTE			; 1
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) then
      begin
        listing[i]   := #9'lda ' + GetString(i);
	listing[i+1] := #9'jsr @printBYTE._a';

	if dex(i+2) then
	 for p:=i-1 downto 0 do
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+2] := ''; listing[p] := ''; Break end;

	exit(false);
      end;


    if (listing[i+2] = #9'jsr @printWORD') and							// jsr @printWORD			; 2

       mva(i) and (iy(i) = false) and								// mva ... :STACKORIGIN,x		; 0
       mva(i+1) and (iy(i+1) = false) then							// mva ... :STACKORIGIN+STACKWIDTH,x	; 1
//       (listing[i+2] = #9'jsr @printWORD') then						// jsr @printWORD			; 2
     if (pos(' :STACKORIGIN,x', listing[i]) > 0 ) and
        (pos(' :STACKORIGIN+STACKWIDTH,x', listing[i+1]) > 0 ) then
      begin

        listing[i]   := #9'lda ' + GetString(i);
        listing[i+1] := #9'ldy ' + GetString(i+1);
	listing[i+2] := #9'jsr @printWORD._ay';

	if dex(i+3) then
	 for p:=i-1 downto 0 do
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+3] := ''; listing[p] := ''; Break end;

	exit(false);
      end;


    if (listing[i+4] = #9'jsr @printCARD') and							// jsr @printCARD			; 4

       mva(i) and										// mva ... :STACKORIGIN,x		; 0
       mva(i+1) and										// mva ... :STACKORIGIN+STACKWIDTH,x	; 1
       mva(i+2) and										// mva ... :STACKORIGIN+STACKWIDTH*2,x	; 2
       mva(i+3) then										// mva ... :STACKORIGIN+STACKWIDTH*3,x	; 3
//       (listing[i+4] = #9'jsr @printCARD') then						// jsr @printCARD			; 4
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
	  if fail(p) then Break else
	   if inx(p) then begin listing[i+5] := ''; listing[p] := ''; Break end;

	exit(false);
      end;

end;		// function
