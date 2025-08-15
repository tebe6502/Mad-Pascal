
function opt_STA_LSR(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      LSR.
// -----------------------------------------------------------------------------

    if lsr_stack(i) and									// lsr :STACKORIGIN+STACKWIDTH		; 0
       ror_stack(i+1) and								// ror :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       (add_sub(i+3) or and_ora_eor(i+3)) and						// add|sub|and|ora|eor			; 3
       sta_a(i+4) and									// sta					; 4
       (lda_stack(i+5) = false) then							//~lda :STACKORIGIN			; 5
     if argMatch(i+1, i+2) then
       begin
	p:=i;

	while lsr_stack(p) and ror_stack(p+1) do dec(p, 2);

	if lda_a(p) and sta_stack(p+1) and argMatch(p+1, i) then BEGIN

	  p:=i;
	  while lsr_stack(p) and ror_stack(p+1) do begin
	   listing[p] := #9'lsr @';
	   dec(p, 2);
	  end;

	  listing[p+1] := '';

	  exit(false);
	end;


	if lda_a(p) and sta_stack(p+1) and argMatch(p+1, i+1) then BEGIN

	  p:=i;
	  while lsr_stack(p) and ror_stack(p+1) do begin
	   listing[p+1] := #9'ror @';
	   dec(p, 2);
	  end;

	  listing[p+1] := '';

	  listing[i+2] := '';

	  exit(false);
	end;

       end;


    if lsr_stack(i) and									// lsr :STACKORIGIN+STACKWIDTH		; 0
       ror_stack(i+1) and								// ror :STACKORIGIN			; 1
       lda_stack(i+2) and								// lda :STACKORIGIN			; 2
       sta_a(i+3) and									// sta					; 3
       (lda_stack(i+4) = false) then							//~lda :STACKORIGIN			; 4
     if argMatch(i+1, i+2) then
       begin
	p:=i;

	while lsr_stack(p) and ror_stack(p+1) do dec(p, 2);

	if lda_a(p) and sta_stack(p+1) and argMatch(p+1, i) then BEGIN

	  p:=i;
	  while lsr_stack(p) and ror_stack(p+1) do begin
	   listing[p] := #9'lsr @';
	   dec(p, 2);
	  end;

	  listing[p+1] := '';

	  exit(false);
	end;


	if lda_a(p) and sta_stack(p+1) and argMatch(p+1, i+1) then BEGIN

	  p:=i;
	  while lsr_stack(p) and ror_stack(p+1) do begin
	   listing[p+1] := #9'ror @';
	   dec(p, 2);
	  end;

	  listing[p+1] := '';

	  listing[i+2] := '';

	  exit(false);
	end;

       end;


    if sta_stack(i) and									// sta :STACKORIGIN			; 0
       lda_im_0(i+1) and								// lda #$00				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+STACKWIDTH		; 2
       sta_stack(i+3) and								// sta :STACKORIGIN+STACKWIDTH*2	; 3
       lsr_stack(i+4) and								// lsr :STACKORIGIN+STACKWIDTH*2	; 4
       ror_stack(i+5) and								// ror :STACKORIGIN+STACKWIDTH		; 5
       ror_stack(i+6) and								// ror :STACKORIGIN			; 6
       (ror(i+7) = false) then								//~ror					; 7
     if argMatch(i, i+6) and
        argMatch(i+2, i+5) and
        argMatch(i+3, i+4) then
       begin
	p := i + 4;

	while lsr_stack(p) and ror_stack(p+1) and ror_stack(p+2) do begin
	 listing[p]   := #9'lsr @';
 	 listing[p+1] := '';
 	 listing[p+2] := '';

	 inc(p, 3);
	end;

	listing[p-1] := listing[i];

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
       end;


// -----------------------------------------------------------------------------


    if lsr_stack(i) and									// lsr :STACKORIGIN+STACKWIDTH*3	; 0
       ror_stack(i+1) and								// ror :STACKORIGIN+STACKWIDTH*2	; 1
       ror_stack(i+2) and								// ror :STACKORIGIN+STACKWIDTH		; 2
       ror_stack(i+3) then								// ror :STACKORIGIN			; 3
    begin


     if
       lda_stack(i+4) and							// lda :STACKORIGIN+STACKWIDTH		; 4
       add_sub(i+5) and								// add|sub				; 5
       sta_val(i+6) and								// sta					; 6
										//					; 7
       (adc_sbc(i+8) = false) then						//~adc|sbc				; 8
     if argMatch(i+2, i+4) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
	 listing[p-2] := #9'lsr ' + copy(listing[p-2], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';

	exit(false);
       end;


     if
       lda_stack(i+4) and							// lda :STACKORIGIN			; 4
       add_sub(i+5) and								// add|sub				; 5
       sta_val(i+6) and								// sta					; 6
       (lda_stack(i+7) = false) and						//~lda :STACKORIGIN+STACKWIDTH		; 7
       (adc_sbc(i+8) = false) then						//~adc|sbc				; 8
     if argMatch(i+3, i+4) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
	 listing[p-2] := '';
 	 listing[p-1] := #9'lsr ' + copy(listing[p-1], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


     if
       lda_stack(i+4) and							// lda :STACKORIGIN			; 4
       add_sub(i+5) and								// add|sub				; 5
       sta_val(i+6) and								// sta					; 6
       lda_stack(i+7) and							// lda :STACKORIGIN+STACKWIDTH		; 7
       adc_sbc(i+8) and								// adc|sbc				; 8
       sta_val(i+9) and								// sta					; 9
       (lda_stack(i+10) = false) and						//~lda :STACKORIGIN+STACKWIDTH*2	; 10
       (adc_sbc(i+11) = false) then						//~adc|sbc				; 11
     if argMatch(i+3, i+4) and
        argMatch(i+2, i+7) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
	 listing[p-2] := #9'lsr ' + copy(listing[p-2], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';

	exit(false);
       end;


     if
       lda_stack(i+4) and							// lda :STACKORIGIN			; 4
       sta_val(i+5) and								// sta					; 5
       (lda_stack(i+6) = false) then						//~lda :STACKORIGIN			; 6
     if argMatch(i+3, i+4) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
	 listing[p-2] := '';
 	 listing[p-1] := #9'lsr ' + copy(listing[p-1], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;


     if
       lda_stack(i+4) and							// lda :STACKORIGIN			; 4
       sta_val(i+5) and								// sta					; 5
       lda_stack(i+6) and							// lda :STACKORIGIN+STACKWIDTH		; 6
       sta_val(i+7) and								// sta					; 7
       (lda_stack(i+8) = false) then						//~lda :STACKORIGIN+STACKWIDTH		; 8
     if argMatch(i+3, i+4) and
        argMatch(i+2, i+6) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
 	 listing[p-2] := #9'lsr ' + copy(listing[p-2], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	listing[i] := '';

	exit(false);
       end;


     if
       lda_val(i+4) and								// lda					; 4
       add_sub_stack(i+5) and							// add|sub :STACKORIGIN			; 5
       sta_val(i+6) and								// sta					; 6
       (lda_stack(i+7) = false) and						//~lda :STACKORIGIN+STACKWIDTH		; 7
       (adc_sbc(i+8) = false) then						//~adc|sbc				; 8
     if argMatch(i+3, i+5) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
	 listing[p-2] := '';
 	 listing[p-1] := #9'lsr ' + copy(listing[p-1], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;

{
     if
       lda_stack(i+4) and							// lda :STACKORIGIN			; 4
       and_ora_eor_val(i+5) and							// and|ora|eor				; 5	~:STACKORIGIN
       sta_val(i+6) and								// sta					; 6
       lda_stack(i+7) then							// lda :STACKORIGIN+STACKWIDTH		; 7
     if argMatch(i+3, i+4) and
        argMatch(i+2, i+7) then
       begin

	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
 	 listing[p-2] := #9'lsr ' + copy(listing[p-2], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+1] := #9'lsr ' + copy(listing[i+1], 6, 256);

	listing[i]   := '';

	exit(false);
       end;
}

     if
       lda_stack(i+4) and							// lda :STACKORIGIN			; 4
       and_ora_eor_val(i+5) and							// and|ora|eor				; 5	~:STACKORIGIN
       sta_val(i+6) and								// sta					; 6
       (lda_stack(i+7) = false) and						//~lda :STACKORIGIN+STACKWIDTH		; 7
       (and_ora_eor(i+8) = false) then						//~and|ora|eor				; 8
     if argMatch(i+3, i+4) then
       begin
	p:=i-1;

	while (listing[p-3] = listing[i]) and (listing[p-2] = listing[i+1]) and (listing[p-1] = listing[i+2]) and (listing[p] = listing[i+3]) do begin
	 listing[p-3] := '';
	 listing[p-2] := '';
 	 listing[p-1] := #9'lsr ' + copy(listing[p-1], 6, 256);

	 dec(p, 4);
	end;

 	listing[i+2] := #9'lsr ' + copy(listing[i+2], 6, 256);

	listing[i]   := '';
	listing[i+1] := '';

	exit(false);
       end;

    end;	// if

end;		// function
