// -----------------------------------------------------------------------------
// ===				      BOOL OR.
// -----------------------------------------------------------------------------

    if lab_a(i) and										//@					; 0	ORA :STACK -> STA
       tya(i+1) and										// tya					; 1
       ora_stack(i+2) and									// ora :STACKORIGIN			; 2
       sta_val(i+3) then									// sta 					; 3
     begin

      tmp := copy(listing[i+2], 6, 256);
      yes := true;

      for p:=i-1 downto 1 do
       if and_stack(p) or
          (sty_stack(p) and lab_a(p-1) and lda(p+1) and ora_stack(p+2)) or
          (sty_stack(p) and lab_a(p-1) and lda_stack(p+1)) or
          (sty_stack(p) and lab_a(p-1) and ldy_1(p+1) and lda_stack(p+2) and argMatch(p, p+2)) or
          (sty_stack(p) and lab_a(p-1) and (argMatch(p, i+2) = false)) or
          (tya(p) and (lab_a(p-1) = false) and (ora_stack(p+1) = false)) then begin yes:=false; Break end;

      if yes then begin


//      for p:=0 to l-1 do writeln(listing[p]);
//      writeln('-------');


       for p:=i-1 downto 0 do begin

	if ldy_1(p) then listing[p] := '';					// ldy #1

	if (listing[p] = #9'sty ' + tmp) then listing[p] := '';			// sty :STACKORIGIN

	if (tya(p) = false) and							//~tya			; 0
	   (listing[p+1] = listing[i+2]) and					// ora :STACKORIGIN	; 1
	   (listing[p+2] = #9'sta ' + tmp) then					// sta :STACKORIGIN	; 2
	 begin
	   listing[p+1]   := #9'jne l1_' + IntToHex(CodeSize, 4) + 's';
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
	   listing[p+2] := #9'jne l_' + IntToHex(CodeSize, 4) + 's';
	   listing[p+3] := '';
	  end;

	 end;

	if dey(p) and								// dey
	   lab_a(p+1) 								//@
	then begin
	  listing[p] := #9'jmp *+6';

	  listing[p+1] := '@\'#9'jmp l_' + IntToHex(CodeSize, 4) + 's';
	end;

       end;

       listing[i+1] := #9'lda:seq #$00';
       listing[i+2] := 'l_' + IntToHex(CodeSize, 4) + 's'#9'lda #$01';


//      for p:=0 to l-1 do writeln(listing[p]);
//      writeln('-------');


       Result:=false; Break;
      end;

     end;
