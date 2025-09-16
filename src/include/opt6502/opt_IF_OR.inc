// -----------------------------------------------------------------------------
// ===			optymalizacja IF OR.				  === //
// -----------------------------------------------------------------------------

    if ldy_1(i) and										// ldy #1				; 0	ORA -> JEQ
       lda(i+1) and										// lda					; 1
       cmp(i+2) and										// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       tya(i+6) and										// tya					; 6
       (ora_stack(i+7) = false) and ora(i+7) and						// ora					; 7
       jeq(i+8) then										// jeq					; 8
     begin
      listing[i] := '';

      listing[i+4] := #9'jmp *+6';
      listing[i+5] := '@'#9'jmp ' + copy(listing[i+8], 6, 256) + 'x';

      listing[i+6] := #9'lda:sne ' + copy(listing[i+7], 6, 256);
      listing[i+7] := #9'jmp ' + copy(listing[i+8], 6, 256);
      listing[i+8] := copy(listing[i+8], 6, 256) + 'x';

      Result:=false; Break;
     end;


    if ldy_1(i) and										// ldy #1				; 0	ORA -> JEQ
       lda(i+1) and										// lda					; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       tya(i+5) and										// tya					; 5
       (ora_stack(i+6) = false) and ora(i+6) and						// ora					; 6
       jeq(i+7) then										// jeq					; 7
     begin
      listing[i] := '';

      listing[i+3] := #9'jmp *+6';
      listing[i+4] := '@'#9'jmp ' + copy(listing[i+7], 6, 256) + 'x';

      listing[i+5] := #9'lda:sne ' + copy(listing[i+6], 6, 256);
      listing[i+6] := #9'jmp ' + copy(listing[i+7], 6, 256);
      listing[i+7] := copy(listing[i+7], 6, 256) + 'x';

      Result:=false; Break;
     end;


    if ldy_1(i) and										// ldy #1				; 0	ORA -> JEQ
       (listing[i+1] = #9'and #$01') and							// and #$01				; 1
       beq(i+2) and										// beq @+				; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       tya(i+5) and										// tya					; 5
       (ora_stack(i+6) = false) and ora(i+6) and						// ora A				; 6
       jeq(i+7) then										// jeq					; 7
     begin
      listing[i] := '';

      listing[i+2] := #9'eor #$01';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';

      Result:=false; Break;
     end;


    if lab_a(i) and										//@					; 0	ORA :STACK -> JEQ
       tya(i+1) and										// tya					; 1
       ora_stack(i+2) and									// ora :STACKORIGIN			; 2
       jeq(i+3) then										// jeq l_				; 3
     begin

// for p:=0 to l-1 do writeln(listing[p]);
// writeln('--------------------');

      tmp := copy(listing[i+2], 6, 256);
      yes := true;

      for p:=i-1 downto 0 do
       if and_stack(p) or local(p) or
          (sty_stack(p) and lab_a(p-1) and lda(p+1) and ora_stack(p+2)) or
          (sty_stack(p) and lab_a(p-1) and lda_stack(p+1)) or
          (sty_stack(p) and lab_a(p-1) and ldy_1(p+1) and lda_stack(p+2) and argMatch(p, p+2)) or
          (sty_stack(p) and lab_a(p-1) and (argMatch(p, i+2) = false)) or
          (tya(p) and (lab_a(p-1) = false) and (ora_stack(p+1) = false)) then begin yes:=false; Break end;

      if yes then begin

       for p:=i-1 downto 0 do begin

	if ldy_1(p) then listing[p] := '';					// ldy #1

	if (listing[p] = #9'sty ' + tmp) then listing[p] := '';			// sty :STACKORIGIN

	if (tya(p) = false) and							//~tya			; 0
	   (listing[p+1] = listing[i+2]) and					// ora :STACKORIGIN	; 1
	   (listing[p+2] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; 2
	 begin
	   listing[p+1] := #9'jne ' + copy(listing[i+3], 6, 256) + 'x';
	   listing[p+2] := '';
	 end;

	if lab_a(p) and								//@			; p
	   tya(p+1) and								// tya			; p+1
   	   (pos('ora ', listing[p+2]) > 0) and					// ora			; p+2
	   (listing[p+3] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; p+3
	 begin

	  if (listing[p+2] = listing[i+2]) then begin
	   listing[p+1] := '';
	   listing[p+2] := '';
	   listing[p+3] := '';
	  end else begin
	   listing[p+1] := #9'lda ' + copy(listing[p+2], 6, 256);
	   listing[p+2] := #9'jne ' + copy(listing[i+3], 6, 256) + 'x';
	   listing[p+3] := '';
	  end;

	 end;

	if dey(p) and								// dey
	   lab_a(p+1) then							//@
	begin
	 listing[p] := #9'jmp *+6';
	 listing[p+1] := '@'#9'jmp ' + copy(listing[i+3], 6, 256) + 'x';
	end;

       end;

       listing[i+1] := #9'jmp ' + copy(listing[i+3], 6, 256);
       listing[i+2] := copy(listing[i+3], 6, 256) + 'x';
//       listing[i+3] := '';

       for p:=i downto 1 do
        if (pos(tmp, listing[p]) > 0) and (add_sub(p-1) = false) and (adc_sbc(p-1) = false) and (lda_a(p-1) = false) then begin
	 if (listing[p] = #9'sta ' + tmp) then listing[p] := #9'jne ' + copy(listing[i+3], 6, 256) + 'x';
	 Break;
	end;

	listing[i+3] := '';

       Result:=false; Break;
      end;

     end;
