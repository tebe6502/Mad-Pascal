
function opt_STA_LDY(i: integer): Boolean;
var p: integer;
    tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				     LDY :STACKORIGIN
// ===				     LDA adr.|STA adr.|beq
// ===				     STA adr.
// -----------------------------------------------------------------------------

     if ldy_stack(i) and								// ldy :STACKORIGIN		; 0
	(lda_adr(i+1) or sta_adr(i+1) or beq(i+1) or sta_adr(i+2) or sta_adr(i+3)) then	// lda adr.|sta adr.|beq	; 1
      begin										//         |sta adr.		; 2
											//	   |sta adr.		; 3
	tmp:=#9'sta ' + copy(listing[i], 6, 256);

	for p:=i-1 downto 0 do
	 if (listing[p] = tmp) and (lda_stack(p-1) = false) then begin


	  if (p > 1) and
	     asl_a(p-2) and					// asl @			; p-2
	     rol_stack(p-1) then				// rol :STACKORIGIN+STACKWIDTH	; p-1
	     							// sta :STACKORIGIN		; p
	   if (copy(listing[p-1], 6, 256) <> copy(listing[p], 6, 256)) then
	   begin
	    listing[p-1] := '';

	    Result:=false; Break;
	   end;


	  if (p > 2) and
	     asl_a(p-3) and					// asl @			; p-3
	     rol_stack(p-2) and					// rol :STACKORIGIN+STACKWIDTH	; p-2
	     asl_a(p-1) then					// asl @			; p-1
	     							// sta :STACKORIGIN		; p
	   if (copy(listing[p-2], 6, 256) <> copy(listing[p], 6, 256)) then
	   begin
	    listing[p-2] := '';

	    Result:=false; Break;
	   end;


	  if (p > 3) and
	     asl_a(p-4) and					// asl @			; p-4
	     rol_stack(p-3) and					// rol :STACKORIGIN+STACKWIDTH	; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     asl_a(p-1) then					// asl @			; p-1
	     							// sta :STACKORIGIN		; p
	   if (copy(listing[p-3], 6, 256) <> copy(listing[p], 6, 256)) then
	   begin
	    listing[p-3] := '';

	    Result:=false; Break;
	   end;


	  if (p > 2) and
	     asl_a(p-3) and					// asl @			; p-3
	     rol_stack(p-2) and					// rol :STACKORIGIN+STACKWIDTH	; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
								//~lda				; p+1
             (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-2], 6, 256) <> copy(listing[p], 6, 256)) then
	   begin
	    listing[p-2] := '';

	    Result:=false; Break;
	   end;


	  if (p > 3) and
	     asl_stack(p-4) and					// asl :STACKORIGIN		; p-4
	     rol_stack(p-3) and					// rol :STACKORIGIN+STACKWIDTH	; p-3
	     lda_stack(p-2) and					// lda :STACKORIGIN		; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
								//~lda				; p+1
             (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-4], 6, 256) = copy(listing[p-2], 6, 256)) and
	      (copy(listing[p-2], 6, 256) = copy(listing[p], 6, 256)) then
	   begin
	    listing[p-3] := '';

	    Result:=false; Break;
	   end;


	  if (p > 7) and
	     add_sub(p-8) and					// add|sub			; p-8
	     sta_stack(p-7) and					// sta :STACKORIGIN		; p-7
	     lda_stack(p-6) and					// lda :STACKORIGIN+STACKWIDTH	; p-6
	     adc_sbc(p-5) and					// adc|sbc			; p-5
	     sta_stack (p-4) and				// lda :STACKORIGIN+STACKWIDTH	; p-4
	     asl_stack(p-3) and					// asl :STACKORIGIN		; p-3
	     lda_stack(p-2) and					// lda :STACKORIGIN		; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
								//~lda				; p+1
             (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-7], 6, 256) = copy(listing[p-3], 6, 256)) and
	      (copy(listing[p-3], 6, 256) = copy(listing[p-2], 6, 256)) and
	      (copy(listing[p-2], 6, 256) = copy(listing[p], 6, 256)) then
	   begin
	    listing[p-7] := '';
	    listing[p-6] := '';
	    listing[p-5] := '';
	    listing[p-4] := '';
	    listing[p-3] := '';

	    listing[p-2] := #9'asl @';

	    Result:=false; Break;
	   end;


	  if (p > 3) and
	     asl_a(p-4) and					// asl @			; p-4
	     rol_stack(p-3) and					// rol :STACKORIGIN+STACKWIDTH	; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     add_sub_val(p-1) and 				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
								//~lda				; p+1
             (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-3], 6, 256) <> copy(listing[p], 6, 256)) then
	    begin
	      listing[p-3] := '';

	      Result:=false; Break;
	    end;


	  if (p > 4) and
	     asl_a(p-5) and					// asl @			; p-5
	     rol_stack(p-4) and					// rol :STACKORIGIN+STACKWIDTH	; p-4
	     asl_a(p-3) and					// asl @			; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     add_sub_val(p-1) and 				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-4], 6, 256) <> copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-4] := '';

	      Result:=false; Break;
	    end;


	  if (p > 5) and
	     asl_stack(p-6) and					// asl :STACKORIGIN		; p-6
	     rol_a(p-5) and					// rol @			; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN+STACKWIDTH	; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-6], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-5] := '';
	      listing[p-4] := '';

	      Result:=false; Break;
	    end;


	  if (p > 7) and
	     add_sub(p-8) and					// add|sub			; p-8
	     sta_stack(p-7) and					// sta :STACKORIGIN		; p-7
	     lda_stack(p-6) and					// lda :STACKORIGIN+STACKWIDTH	; p-6
	     adc_sbc(p-5) and					// adc|sbc			; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN+STACKWIDTH	; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-7], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-6] := '';
	      listing[p-5] := '';
	      listing[p-4] := '';

	      Result:=false; Break;
	    end;


	  if (p > 7) and
	     asl_a(p-8) and					// asl @			; p-8
	     rol_stack(p-7) and					// rol :STACKORIGIN+STACKWIDTH	; p-7
	     add_sub_stack(p-6) and				// add|sub :STACKORIGIN		; p-6
	     asl_a(p-5) and					// asl @			; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN		; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-7], 6, 256) <> copy(listing[p], 6, 256)) and
	      (copy(listing[p-6], 6, 256) = copy(listing[p-4], 6, 256)) and
              (copy(listing[p-4], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-7] := '';

	      Result:=false; Break;
	    end;


	  if (p > 6) and
	     asl_a(p-7) and					// asl @			; p-7
	     rol_stack(p-6) and					// rol :STACKORIGIN+STACKWIDTH	; p-6
	     add_sub_stack(p-5) and				// add|sub :STACKORIGIN		; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN		; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-6], 6, 256) <> copy(listing[p], 6, 256)) and
	      (copy(listing[p-5], 6, 256) = copy(listing[p-4], 6, 256)) and
              (copy(listing[p-4], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-6] := '';

	      Result:=false; Break;
	    end;


	  if (p > 3) and
	     asl_a(p-4) and					// asl @			; p-4
	     rol_stack(p-3) and					// rol :STACKORIGIN+STACKWIDTH	; p-3
	     add_sub_val(p-2) and				// add|sub			; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-3], 6, 256) <> copy(listing[p-1], 6, 256)) then
 	    begin
	      listing[p-3] := '';

	      Result:=false; Break;
	    end;


	  if (p > 4) and
	     asl_a(p-5) and					// asl @			; p-5
	     rol_stack(p-4) and					// rol :STACKORIGIN+STACKWIDTH	; p-4
	     asl_a(p-3) and					// asl @			; p-3
	     add_sub_val(p-2) and				// add|sub			; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-4], 6, 256) <> copy(listing[p-1], 6, 256)) then
 	    begin
	      listing[p-4] := '';

	      Result:=false; Break;
	    end;


	  if (p > 5) and
	     asl_a(p-6) and					// asl @			; p-6
	     rol_stack(p-5) and					// rol :STACKORIGIN+STACKWIDTH	; p-5
	     asl_a(p-4) and					// asl @			; p-4
	     asl_a(p-3) and					// asl @			; p-3
	     add_sub_val(p-2) and 				// add|sub			; p-2
	     add_sub_val(p-1) and 				// add|sub			; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-5], 6, 256) <> copy(listing[p-1], 6, 256)) then
 	    begin
	      listing[p-5] := '';

	      Result:=false; Break;
	    end;


	  if (p > 7) and
	     asl_a(p-8) and					// asl @			; p-8
	     rol_stack(p-7) and					// rol :STACKORIGIN+STACKWIDTH	; p-7
	     asl_a(p-6) and					// asl @			; p-6
	     add_sub_stack(p-5) and				// add|sub :STACKORIGIN		; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN		; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-7], 6, 256) <> copy(listing[p], 6, 256)) and
	      (copy(listing[p-5], 6, 256) = copy(listing[p-4], 6, 256)) and
              (copy(listing[p-4], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-7] := '';

	      Result:=false; Break;
	    end;


	  if (p > 8) and
	     asl_a(p-9) and					// asl @			; p-9
	     rol_stack(p-8) and					// rol :STACKORIGIN+STACKWIDTH	; p-8
	     asl_a(p-7) and					// asl @			; p-7
	     asl_a(p-6) and					// asl @			; p-6
	     add_sub_stack(p-5) and				// add|sub :STACKORIGIN		; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN		; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-8], 6, 256) <> copy(listing[p], 6, 256)) and
	      (copy(listing[p-5], 6, 256) = copy(listing[p-4], 6, 256)) and
              (copy(listing[p-4], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-8] := '';

	      Result:=false; Break;
	    end;


	  if (p > 8) and
	     asl_a(p-9) and					// asl @			; p-9
	     rol_stack(p-8) and					// rol :STACKORIGIN+STACKWIDTH	; p-8
	     asl_a(p-7) and					// asl @			; p-7
	     add_sub_stack(p-6) and				// add|sub :STACKORIGIN		; p-6
	     asl_a(p-5) and					// asl @			; p-5
	     sta_stack(p-4) and					// sta :STACKORIGIN		; p-4
	     lda(p-3) and					// lda				; p-3
	     and_ora_eor(p-2) and				// and|ora|eor			; p-2
	     add_sub_stack(p-1) and				// add|sub :STACKORIGIN		; p-1
								// sta :STACKORIGIN		; p
								//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
           if (copy(listing[p-8], 6, 256) <> copy(listing[p], 6, 256)) and
	      (copy(listing[p-6], 6, 256) = copy(listing[p-4], 6, 256)) and
              (copy(listing[p-4], 6, 256) = copy(listing[p-1], 6, 256)) and
              (copy(listing[p-1], 6, 256) = copy(listing[p], 6, 256)) then
 	    begin
	      listing[p-8] := '';

	      Result:=false; Break;
	    end;


	  if (p > 1) and
	     add_sub(p-1) and					// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
	     lda(p+1) and					// lda				; p+1
	     adc_sbc(p+2) and					// adc|sbc			; p+2
	     sta_stack(p+3) and					// sta :STACKORIGIN+STACKWIDTH	; p+3
	     							//~lda				; p+4
	     (adc_sbc(p+5) = false) then			//~adc|sbc			; p+5
	   begin
	    listing[p+1] := '';
	    listing[p+2] := '';
	    listing[p+3] := '';

	    Result:=false; Break;
	   end;


	  if (p > 6) and
	     lda_stack(p-7) and					// lda :STACKORIGIN+STACKWIDTH	; p-7
             adc_sbc(p-6) and 					// adc|sbc			; p-6
             asl_stack(p-5) and					// asl :STACKORIGIN		; p-5
	     rol_a(p-4) and					// rol @			; p-4
	     sta_stack(p-3) and					// sta :STACKORIGIN+STACKWIDTH	; p-3
	     lda_stack(p-2) and					// lda :STACKORIGIN		; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
	     							//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-5], 6, 256) = copy(listing[p-2], 6, 256)) and
	      (copy(listing[p-2], 6, 256) = copy(listing[p], 6, 256)) then
	   begin
	    listing[p-6] := #9'sta #$00';

	    listing[p-4] := '';
	    listing[p-3] := '';

	    Result:=false; Break;
	   end;


	  if (p > 4) and
	     asl_a(p-5) and					// asl @			; p-5
	     rol_stack(p-4) and					// rol :STACKORIGIN+STACKWIDTH	; p-4
	     add_sub_stack(p-3) and				// add|sub :STACKORIGIN 	; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
	     							//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-3], 6, 256) = copy(listing[p], 6, 256)) and
	      (copy(listing[p-4], 6, 256) <> copy(listing[p-3], 6, 256)) then
	   begin
	    listing[p-4] := '';

	    Result:=false; Break;
	   end;


	  if (p > 4) and
	     asl_a(p-5) and					// asl @			; p-5
	     rol_stack(p-4) and					// rol :STACKORIGIN+STACKWIDTH	; p-4
	     add_sub_val(p-3) and				// add|sub		 	; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
	     							//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   begin
	    listing[p-4] := '';

	    Result:=false; Break;
	   end;


	  if (p > 5) and
	     asl_a(p-6) and					// asl @			; p-6
	     rol_stack(p-5) and					// rol :STACKORIGIN+STACKWIDTH	; p-5
	     asl_a(p-4) and					// asl @			; p-4
	     add_sub_stack(p-3) and				// add|sub :STACKORIGIN 	; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
	     							//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   if (copy(listing[p-3], 6, 256) = copy(listing[p], 6, 256)) and
	      (copy(listing[p-5], 6, 256) <> copy(listing[p-3], 6, 256)) then
	   begin
	    listing[p-5] := '';

	    Result:=false; Break;
	   end;


	  if (p > 5) and
	     asl_a(p-6) and					// asl @			; p-6
	     rol_stack(p-5) and					// rol :STACKORIGIN+STACKWIDTH	; p-5
	     asl_a(p-4) and					// asl @			; p-4
	     add_sub_val(p-3) and				// add|sub		 	; p-3
	     asl_a(p-2) and					// asl @			; p-2
	     add_sub_val(p-1) and				// add|sub			; p-1
	     							// sta :STACKORIGIN		; p
	     							//~lda				; p+1
	     (adc_sbc(p+2) = false) then			//~adc|sbc			; p+2
	   begin
	    listing[p-5] := '';

	    Result:=false; Break;
	   end;


	  Break;

	 end else
	  if (pos(copy(listing[i], 6, 256), listing[p]) > 0) or
	     lab_a(i) or (listing[i] = #9'eif') or
	     ((pos(#9'jsr ', listing[i]) = 1) and (pos(#9'jsr @', listing[i]) = 0)) then Break;

	if Result = false then exit(false);
      end;

end;		// function