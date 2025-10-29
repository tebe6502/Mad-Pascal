// -----------------------------------------------------------------------------
// ===				      WHILE OR.
// -----------------------------------------------------------------------------

    if lab_a(i) and										//@					; 0	ORA :STACK -> JNE
       tya(i+1) and										// tya					; 1
       ora_stack(i+2) and									// ora :STACKORIGIN			; 2
       jne(i+3) then										// jne l_				; 3	WHILE
     begin


      if test_AND(i) then begin

       tmp := copy(listing[i+2], 6, 256);

       for p := i-1 downto 0 do begin

	if ldy_1(p) then listing[p] := '';					// ldy #1

	if (listing[p] = #9'sty ' + tmp) then listing[p] := '';			// sty :STACKORIGIN

	if (tya(p) = false) and							//~tya			; 0
	   (listing[p+1] = listing[i+2]) and					// ora :STACKORIGIN	; 1
	   (listing[p+2] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; 2
	 begin
	   listing[p+1] := #9'jne ' + copy(listing[i+3], 6, 256);
	   listing[p+2] := '';
	 end;

	if lab_a(p) and								//@			; p
	   tya(p+1) and								// tya			; p+1
   	   ora(p+2) and								// ora			; p+2
	   (listing[p+3] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; p+3
	 begin

	  if (listing[p+2] = listing[i+2]) then begin
	   listing[p+1] := '';
	   listing[p+2] := '';
	   listing[p+3] := '';
	  end else begin
	   listing[p+1] := #9'lda ' + copy(listing[p+2], 6, 256);
	   listing[p+2] := #9'jne ' + copy(listing[i+3], 6, 256);
	   listing[p+3] := '';
	  end;

	 end;

	if dey(p) and								// dey
	   lab_a(p+1) then 							//@
	begin
	 listing[p]   := #9'jmp *+6';
	 listing[p+1] := '@'#9'jmp ' + copy(listing[i+3], 6, 256);
	end;

       end;

       listing[i+1] := '';
       listing[i+2] := '';
//       listing[i+3] := '';

       for p:=i downto 1 do
        if (pos(tmp, listing[p]) > 0) and (add_sub(p-1) = false) and (adc_sbc(p-1) = false) and (lda_a(p-1) = false) then begin
	 if (listing[p] = #9'sta ' + tmp) then listing[p] := #9'jne ' + copy(listing[i+3], 6, 256);
	 Break;
	end;

	listing[i+3] := '';

       Result:=false; Break;
      end;

     end;
