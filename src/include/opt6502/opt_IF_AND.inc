// -----------------------------------------------------------------------------
// ===			optymalizacja IF AND.				  === //
// -----------------------------------------------------------------------------

    if ldy_1(i) and										// ldy #1				; 0	AND -> JEQ
       lda(i+1) and										// lda					; 1
       cmp(i+2) and										// cmp					; 2
       SKIP(i+3) and										// SKIP					; 3
       dey(i+4) and										// dey					; 4
       lab_a(i+5) and										//@					; 5
       tya(i+6) and										// tya					; 6
       and_(i+7) and (and_stack(i+7) = false) and 						// and					; 7
       jeq(i+8) then										// jeq					; 8
     begin
      listing[i] := '';

      listing[i+4] := #9'jmp ' + copy(listing[i+8], 6, 256);

      listing[i+6] := '';
      listing[i+7] := #9'lda ' + copy(listing[i+7], 6, 256);

      Result:=false; Break;
     end;


    if ldy_1(i) and										// ldy #1				; 0	AND -> JEQ
       lda(i+1) and										// lda					; 1
       SKIP(i+2) and										// SKIP					; 2
       dey(i+3) and										// dey					; 3
       lab_a(i+4) and										//@					; 4
       tya(i+5) and										// tya					; 5
       and_(i+6) and (and_stack(i+6) = false) and						// and					; 6
       jeq(i+7) then										// jeq					; 7
     begin
      listing[i] := '';

      listing[i+3] := #9'jmp ' + copy(listing[i+7], 6, 256);

      listing[i+5] := '';
      listing[i+6] := #9'lda ' + copy(listing[i+6], 6, 256);

      Result:=false; Break;
     end;



    if lab_a(i) and										//@					; 0	AND :STACK -> JEQ
       tya(i+1) and										// tya					; 1
       and_stack(i+2) and									// and :STACKORIGIN			; 2
       jeq(i+3) then										// jeq					; 3
     begin

      tmp := copy(listing[i+2], 6, 256);
      yes := true;

      for p:=i-1 downto 0 do
       if ora_stack(p) or
          (sty_stack(p) and lab_a(p-1) and lda(p+1) and and_stack(p+2)) or
          (sty_stack(p) and lab_a(p-1) and lda_stack(p+1)) or
          (sty_stack(p) and lab_a(p-1) and ldy_1(p+1)) or
          (sty_stack(p) and lab_a(p-1) and (copy(listing[p], 6, 256) <> copy(listing[i+2], 6, 256))) or
          (tya(p) and (lab_a(p-1) = false) and (and_stack(p+1) = false)) then begin yes:=false; Break end;


      if yes then begin

//      for p:=0 to l-1 do writeln(listing[p]);
//      writeln('-------');

       for p:=i-1 downto 0 do begin

	if ldy_1(p) then listing[p] := '';					// ldy #1

	if (listing[p] = #9'sty ' + tmp) then listing[p] := '';			// sty :STACKORIGIN

	if (tya(p) = false) and							//~tya			; 0
	   (listing[p+1] = listing[i+2]) and					// and :STACKORIGIN	; 1
	   (listing[p+2] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; 2
	 begin
	   listing[p+1] := listing[i+3];
	   listing[p+2] := '';
	 end;

	if lab_a(p) and								//@			; p
	   tya(p+1) and								// tya			; p+1
   	   and_(p+2) and							// and			; p+2
	   (listing[p+3] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; p+3
	 begin

	  if (listing[p+2] = listing[i+2]) then begin
	   listing[p+1] := '';
	   listing[p+2] := '';
	   listing[p+3] := '';
	  end else begin
	   listing[p+1] := #9'lda ' + copy(listing[p+2], 6, 256);
	   listing[p+2] := listing[i+3];
	   listing[p+3] := '';
	  end;

	 end;

	if dey(p) and								// dey
	   lab_a(p+1)								//@
	then
	  listing[p] := #9'jmp ' + copy(listing[i+3], 6, 256);

       end;

       listing[i+1] := '';
       listing[i+2] := #9'lda ' + copy(listing[i+2], 6, 256);
//       listing[i+3] := '';

       for p:=i downto 0 do
        if pos(tmp, listing[p]) > 0 then begin
	 if (listing[p] = #9'sta ' + tmp) then listing[p] := listing[i+3];
	 Break;
	end;

	listing[i+3] := '';

       Result:=false; Break;
      end;

     end;
