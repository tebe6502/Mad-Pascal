
{

*3
*5
*8
*10
*16
*40
*64
*128
*255

}


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


// -----------------------------------------------------------------------------
// ===				imulCL 5				  === //
// -----------------------------------------------------------------------------

    if lda(i) and (lda_stack(i) = false) and						// lda 					; 0
       (listing[i+1] = #9'sta :eax') and						// sta :eax				; 1
       (listing[i+2] = #9'lda #$05') and						// lda #$05				; 2
       (listing[i+3] = #9'sta :ecx') and						// sta :ecx				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       lda(i+9) and									// lda					; 9
       ((listing[i+10] = #9'add :eax') or (listing[i+10] = #9'sub :eax')) and		// add|sub :eax				; 10
       sta(i+11) and									// sta					; 11
       lda(i+12) and									// lda					; 12
       (adc_im_0(i+13) or sbc_im_0(i+13)) then						// adc|sbc #$00				; 13
     begin

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
      listing[i+4] := #9'sta :eax';

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';

      Result:=false; Break;
     end;


    if (lda(i) = false) and								//~lda 					; 0
       (listing[i+1] = #9'sta :eax') and						// sta :eax				; 1
       (listing[i+2] = #9'lda #$05') and						// lda #$05				; 2
       (listing[i+3] = #9'sta :ecx') and						// sta :ecx				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       sta(i+10) and									// sta					; 10
       (listing[i+11] <> #9'lda :eax+1') then						// ~lda :eax+1				; 11
     begin

      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add :eax';
      listing[i+5] := #9'sta :eax';

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';

      Result:=false; Break;
     end;


    if lda(i) and (lda_stack(i) = false) and						// lda 					; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$05') and						// lda #$05				; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       add_sub(i+10) and								// add|sub				; 10
       and_ora_eor(i+11) and								// and_ora_eor				; 11
       sta(i+12) then									// sta					; 12
     begin

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';

      if listing[i+10] = #9'add #$01' then begin

       listing[i+3] := #9'sec';
       listing[i+4] := #9'adc ' + copy(listing[i], 6, 256);

       listing[i+9] := '';
       listing[i+10]:= '';
      end else begin
       listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
       listing[i+4] := #9'sta :eax';
      end;

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';

      Result:=false; Break;
     end;


    if (listing[i] = #9'lda #$05') and							// lda #$05				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       sta(i+10) and									// sta					; 10
       (listing[i+11] <> #9'lda :eax+1') then						// ~lda :eax+1				; 11
     begin
      listing[i]   := '';
      listing[i+1] := '';

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'asl @';
      listing[i+5] := #9'add ' + copy(listing[i+2], 6, 256);
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


    if (listing[i] = #9'lda #$05') and							// lda #$05				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       add_sub(i+10) and								// add					; 10
       tay(i+11) and									// tay					; 11
       (listing[i+12] <> #9'lda :eax+1') then						// ~lda :eax+1				; 12
     begin
      listing[i]   := '';
      listing[i+1] := '';

      listing[i+3] := #9'asl @';
      listing[i+4] := #9'asl @';
      listing[i+5] := #9'add ' + copy(listing[i+2], 6, 256);
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


    if lda(i) and (lda_stack(i) = false) and						// lda 					; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$05') and						// lda #$05				; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       sta(i+10) and									// sta					; 10
       (listing[i+11] <> #9'lda :eax+1') then						// ~lda :eax+1				; 11
     begin

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCL 7				  === //
// -----------------------------------------------------------------------------

    if lda(i) and (lda_stack(i) = false) and						// lda 					; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$07') and						// lda #$07				; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       and_ora_eor(i+10) and								// and|ora|eor				; 10
       sta(i+11) and									// sta					; 11
       (listing[i+12] <> #9'lda :eax+1') then						// ~lda :eax+1				; 12
     begin
      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'sub ' + copy(listing[i], 6, 256);
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


    if (listing[i] = #9'lda #$07') and							// lda #$07				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       and_ora_eor(i+10) and								// and|ora|eor				; 10
       sta(i+11) and									// sta					; 11
       (listing[i+12] <> #9'lda :eax+1') then						// ~lda :eax+1				; 12
     begin
      listing[i] := listing[i+2];
      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'sub ' + copy(listing[i], 6, 256);
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCL 8				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'ldy :eax') then						// ldy :eax				; 9
     begin

      listing[i]   := listing[i+2];

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'tay';

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and 								// .ifdef fmulinit			; 4
      											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       add_sub(i+10) and								// add|sub				; 10
       tay(i+11) then									// tay					; 11
     begin

      listing[i]   := listing[i+2];

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';

      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCL 10				  === //
// -----------------------------------------------------------------------------

 if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
    (listing[i+1] = #9'sta :ecx') and 							// sta :ecx				; 1
    lda(i+2) and (lda_stack(i+2) = false) and						// lda 					; 2
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


// -----------------------------------------------------------------------------
// ===				imulCL 16				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$10') and							// lda #$10				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       sta(i+10) and									// sta					; 10
       (lda(i+11) = false) then								//~lda					; 11
     begin
      listing[i] := listing[i+2];

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'asl @';
      listing[i+5] := #9'sta :eax';

      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCL 40				  === //
// -----------------------------------------------------------------------------

    if (listing[i]  = #9'lda #$28') and							// lda #$28				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) then								// .ifdef fmulinit			; 4
     											// fmulu_8				; 5
      											// els					; 6
      											// imulCL				; 7
       		 									// eif					; 8
       begin
	listing[i]   := listing[i+2];
	listing[i+1] := #9'jsr @mul40';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false;
       end;


    if (listing[i] = #9'sta :ecx') and							// sta :ecx				; 0
       (listing[i+1] = #9'lda #$28') and						// lda #$28				; 1
       (listing[i+2] = #9'sta :eax') and						// sta :eax				; 2
       IFDEF_MUL8(i+3) then								// .ifdef fmulinit			; 3
     											// fmulu_8				; 4
      											// els					; 5
      											// imulCL				; 6
       		 									// eif					; 7
       begin
	listing[i] := #9'jsr @mul40';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
       end;


    if (listing[i]  = #9'sta :eax') and							// sta :eax				; 0
       (listing[i+1] = #9'lda #$28') and						// lda #$28				; 1
       (listing[i+2] = #9'sta :ecx') and						// sta :ecx				; 2
       IFDEF_MUL8(i+3) then								// .ifdef fmulinit			; 3
     											// fmulu_8				; 4
      											// els					; 5
      											// imulCL				; 6
       		 									// eif					; 7
       begin
	listing[i]   := #9'jsr @mul40';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	Result:=false;
       end;


// -----------------------------------------------------------------------------
// ===				imulCL 64				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$40') and							// lda #$40				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) then								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
     begin
      listing[i] := listing[i+2];
      listing[i+1] := #9'sta :eax+1';
      listing[i+2] := #9'lda #$00';
      listing[i+3] := #9'lsr :eax+1';
      listing[i+4] := #9'ror @';
      listing[i+5] := #9'lsr :eax+1';
      listing[i+6] := #9'ror @';
      listing[i+7] := #9'sta :eax';
      listing[i+8] := '';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCL 128				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$80') and							// lda #$80				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_stack(i+2) = false) and					// lda					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) then								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
     begin
      listing[i] := listing[i+2];
      listing[i+1] := #9'sta :eax+1';
      listing[i+2] := #9'lda #$00';
      listing[i+3] := #9'lsr :eax+1';
      listing[i+4] := #9'ror @';
      listing[i+5] := #9'sta :eax';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCL 255				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$FF') and							// lda #$FF				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (lda_im(i+2) = false) and (lda_stack(i+2) = false) and				// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :ecx				; 3
       IFDEF_MUL8(i+4) then								// .ifdef fmulinit			; 4
     											// fmulu_8				; 5
      											// els					; 6
      											// imulCL				; 7
       		 									// eif					; 8
       begin

	listing[i]   := #9'lda #$00';
	listing[i+1] := #9'sub ' + copy(listing[i+2], 6, 256);
	listing[i+2] := #9'sta :eax';
	listing[i+3] := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+4] := #9'sbc #$00';
	listing[i+5] := #9'sta :eax+1';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false; Break;
       end;


    if lda(i) and									// lda					; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$FF') and						// lda #$FF				; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) then								// .ifdef fmulinit			; 4
     											// fmulu_8				; 5
      											// els					; 6
      											// imulCL				; 7
       		 									// eif					; 8
       begin
	listing[i+1]   := #9'lda #$00';
	listing[i+2] := #9'sub ' + copy(listing[i], 6, 256);
	listing[i+3] := #9'sta :eax';
	listing[i+4] := #9'lda ' + copy(listing[i], 6, 256);
	listing[i+5] := #9'sbc #$00';
	listing[i+6] := #9'sta :eax+1';
	listing[i+7] := '';
	listing[i+8] := '';

	listing[i] := '';

	Result:=false; Break;
       end;


