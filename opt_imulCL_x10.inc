
// -----------------------------------------------------------------------------
// ===				imulCL 10				  === //
// -----------------------------------------------------------------------------

 if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
    (listing[i+1] = #9'sta :ecx') and 							// sta :ecx				; 1
    lda(i+2) and {(lda_stack(i+2) = false) and}						// lda 					; 2
    (listing[i+3] = #9'sta :eax') and 							// sta :eax				; 3
    IFDEF_MUL8(i+4) then 								// .ifdef fmulinit			; 4
     											// fmulu_8				; 5
       											// els					; 6
      											// imulCL				; 7
       											// eif					; 8
  begin


     if (listing[i+9] = #9'lda :eax') and 						// lda :eax		; 9
        add_sub(i+10) and								// add|sub		; 10
        tay(i+11) then 									// tay			; 11
      begin

	listing[i] := listing[i+2];

	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
	listing[i+4] := #9'asl @';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
      end;


     if lda(i+9) and			 						// lda			; 9
        ((listing[i+10] = #9'add #$01') or (listing[i+10] = #9'sub #$01')) and		// add|sub #$01		; 10
        ((listing[i+11] = #9'add :eax') or (listing[i+11] = #9'sub :eax')) and		// add|sub :eax		; 11
        tay(i+12) then 									// tay			; 12
      begin

	listing[i] := listing[i+2];

	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
	listing[i+4] := #9'asl @';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	if listing[i+11] = #9'add :eax' then
	 listing[i+9] := #9'add ' + copy(listing[i+9], 6, 256)
	else
	 listing[i+9] := #9'sub ' + copy(listing[i+9], 6, 256);

	if listing[i+10] = #9'add #$01' then
	 listing[i+11] := #9'iny'
	else
	 listing[i+11] := #9'dey';

	listing[i+10] := #9'tay';

	listing[i+12] := '';

	Result:=false; Break;
      end;


  end;
