// -----------------------------------------------------------------------------
// ===				      BOOL AND.
// -----------------------------------------------------------------------------

    if lab_a(i) and										//@					; 0	AND :STACK -> STA
       tya(i+1) and										// tya					; 1
       and_stack(i+2) and									// and :STACKORIGIN			; 2
       (sta_val(i+3) or (ldy(i+3) and sta_adr(i+4))) then					// sta|ldy				; 3
     begin   											//    |sta adr.				; 4

      tmp := copy(listing[i+2], 6, 256);
      yes := true;

      for p:=i-1 downto 1 do
       if ora_stack(p) or
          (sty_stack(p) and lab_a(p-1) and lda(p+1) and and_stack(p+2)) or
          (sty_stack(p) and lab_a(p-1) and lda_stack(p+1)) or
          (sty_stack(p) and lab_a(p-1) and ldy_1(p+1) and lda_stack(p+2) and (copy(listing[p], 6, 256) = copy(listing[p+2], 6, 256))) or
          (sty_stack(p) and lab_a(p-1) and (copy(listing[p], 6, 256) <> copy(listing[i+2], 6, 256))) or
          (tya(p) and (lab_a(p-1) = false) and (and_stack(p+1) = false)) then begin yes:=false; Break end;

      if yes then begin

       for p:=i-1 downto 0 do begin

	if ldy_1(p) then listing[p] := '';					// ldy #1

	if (listing[p] = #9'sty ' + tmp) then listing[p] := '';			// sty :STACKORIGIN

	if (tya(p) = false) and							//~tya			; 0
	   (listing[p+1] = listing[i+2]) and					// and :STACKORIGIN	; 1
	   (listing[p+2] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; 2
	 begin
	   listing[p+1]   := #9'jeq l_' + IntToHex(CodeSize, 4) + 's';
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
	   listing[p+2] := #9'jeq l_' + IntToHex(CodeSize, 4) + 's';
	   listing[p+3] := '';
	  end;

	 end;

	if dey(p) and								// dey
	   lab_a(p+1) 								//@
	then
	  listing[p] := #9'jmp l_' + IntToHex(CodeSize, 4) + 's';

       end;

       listing[i+1] := #9'lda:sne #$01';
       listing[i+2] := 'l_' + IntToHex(CodeSize, 4) + 's'#9'lda #$00';

       Result:=false; Break;
      end;

     end;
