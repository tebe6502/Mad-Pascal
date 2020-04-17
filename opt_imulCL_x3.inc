
// -----------------------------------------------------------------------------
// ===				imulCL 3				  === //
// -----------------------------------------------------------------------------

  if (listing[i] = #9'lda #$03') and							// lda #$03				; 0
     (pos('sta :e', listing[i+1]) > 0) and						// sta :e..				; 1
     lda(i+2) and (lda_stack(i+2) = false) and						// lda 					; 2
     (pos('sta :e', listing[i+3]) > 0) and				 		// sta :e..				; 3
     IFDEF_MUL8(i+4) then								// .ifdef fmulinit			; 4
      											// fmulu_8				; 5
       											// els					; 6
      											// imulCL				; 7
       											// eif					; 8
   begin


    if (listing[i+9] = #9'ldy :eax') then						// ldy :eax				; 9
     begin
      listing[i]   := '';
      listing[i+1] := '';

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+2], 6, 256);
      listing[i+5] := #9'tay';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


    if (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       add_sub(i+10) and								// add|sub				; 10
       tay(i+11) then									// tay					; 11
     begin
      listing[i]   := '';
      listing[i+1] := '';

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+2], 6, 256);
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      if listing[i+10] = #9'add #$01' then begin
       listing[i+10] := #9'tay';
       listing[i+11] := #9'iny';
      end else
      if listing[i+10] = #9'sub #$01' then begin
       listing[i+10] := #9'tay';
       listing[i+11] := #9'dey';
      end;

      Result:=false; Break;
     end;


    if (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       add_sub(i+10) and								// add|sub				; 10
       sta_stack(i+11) and								// sta :STACKORIGIN			; 11
       (listing[i+12] <> #9'lda :eax1+') then						//~lda :eax+1				; 12
     begin
      listing[i]   := '';
      listing[i+1] := '';

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+2], 6, 256);
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


     if	lda(i+9) and									// lda					; 9
	((listing[i+10] = #9'add :eax') or (listing[i+10] = #9'sub :eax')) and		// add|sub :eax				; 10
	sta(i+11) then									// sta					; 11
      begin

	if lda(i+12) and								// lda					; 12
	   ((listing[i+13] = #9'adc :eax+1') or (listing[i+13] = #9'sbc :eax+1')) then	// adc|sbc :eax+1			; 13
	begin
	 listing[i]   := #9'lda #$00';
	 listing[i+1] := #9'sta :eax+1';

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';

	 listing[i+5] := #9'add ' + copy(listing[i+2], 6, 256);
	 listing[i+6] := #9'sta :eax';
	 listing[i+7] := #9'scc';
	 listing[i+8] := #9'inc :eax+1';
	end else begin
	 listing[i]   := '';
	 listing[i+1] := '';

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'add ' + copy(listing[i+2], 6, 256);
	 listing[i+5] := #9'sta :eax';

	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	end;

	Result:=false; Break;
      end;

  end;		// MUL 3



    if	lda(i) and (lda_stack(i) = false) and						// lda					; 0
	(pos('sta :e', listing[i+1]) > 0) and						// sta :e..				; 1
	(listing[i+2] = #9'lda #$03') and 						// lda #$03				; 2
       	(pos('sta :e', listing[i+3]) > 0) and				 		// sta :e..				; 3
       	IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
      											// fmulu_8				; 5
       											// els					; 6
      											// imulCL				; 7
       											// eif					; 8

	lda(i+9) and									// lda					; 9
	((listing[i+10] = #9'add :eax') or (listing[i+10] = #9'sub :eax')) and		// add|sub :eax				; 10
	sta(i+11) then									// sta					; 11
     begin

	if lda(i+12) and								// lda					; 12
	   ((listing[i+13] = #9'adc :eax+1') or (listing[i+13] = #9'sbc :eax+1')) then	// adc|sbc :eax+1			; 13
	begin
	 listing[i+2] := listing[i];

	 listing[i]   := #9'lda #$00';
	 listing[i+1] := #9'sta :eax+1';

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';

	 listing[i+5] := #9'add ' + copy(listing[i+2], 6, 256);
	 listing[i+6] := #9'sta :eax';
	 listing[i+7] := #9'scc';
	 listing[i+8] := #9'inc :eax+1';
	end else begin
	 listing[i+1] := #9'asl @';
	 listing[i+2] := #9'add ' + copy(listing[i], 6, 256);
	 listing[i+3] := #9'sta :eax';

	 listing[i+4] := '';
	 listing[i+5] := '';
	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	end;

	Result:=false; Break;
     end;

