
// -----------------------------------------------------------------------------
// ===				imulCX 10				  === //
// -----------------------------------------------------------------------------

 if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0
    (listing[i+1] = #9'sta :ecx') and 							// sta :ecx				; 1
    lda_im_0(i+2) and 									// lda #$00				; 2
    (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
    IFDEF_MUL16(i+4) then 								// .ifdef fmulinit			; 4
       											// fmulu_16				; 5
       				 							// els					; 6
       											// imulCX				; 7
       											// eif					; 8
  begin


     if (listing[i+9] = #9'lda :eax') and 						// lda :eax				; 9
        add_sub(i+10) and								// add|sub				; 10
        tay(i+11) then 									// tay					; 11
      begin

	if (listing[i-1] = #9'sta :eax+1') and
           (adc_im_0(i-2) or sbc_im_0(i-2)) and
	   lda_im_0(i-3) and
	   (listing[i-4] = #9'sta :eax') then
         begin
	  listing[i-1] := '';
	  listing[i-2] := '';
	  listing[i-3] := '';

	  listing[i] := '';
         end else
          listing[i]   := #9'lda :eax';

	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add :eax';
	listing[i+4] := #9'asl @';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	Result:=false; Break;
      end;


     if lda(i+9) and 									// lda 					; 9
        AND_ORA_EOR(i+10) and								// and|ora|eor				; 10
        ((listing[i+11] = #9'add :eax') or (listing[i+11] = #9'sub :eax')) and		// add|sub :eax				; 11
        (tay(i+12) or sta_stack(i+12)) then						// tay|sta :STACK			; 12
      begin
	listing[i]   := #9'lda :eax';
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add :eax';
	listing[i+4] := #9'asl @';
	listing[i+5] := #9'sta :eax';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	Result:=false; Break;
      end;

  end;

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


    if ldy_im_0(i) and 									// ldy #$00				; 0
       lda(i+1) and 									// lda 					; 1
       spl(i+2) and 									// spl					; 2
       dey(i+3) and 									// dey					; 3
       (listing[i+4] = #9'sta :eax') and 						// sta :eax				; 4
       (listing[i+5] = #9'sty :eax+1') and 						// sty :eax+1				; 5
       (listing[i+6] = #9'lda #$0A') and 						// lda #$0A				; 6
       (listing[i+7] = #9'sta :ecx') and 						// sta :ecx				; 7
       lda_im_0(i+8) and 								// lda #$00				; 8
       (listing[i+9] = #9'sta :ecx+1') and 						// sta :ecx+1				; 9
       IFDEF_MUL16(i+10) and 								// .ifdef fmulinit			; 10
      											// fmulu_16				; 11
       											// els					; 12
       											// imulCX				; 13
       											// eif					; 14
       lda(i+15) and 									// lda 					; 15
       ((listing[i+16] = #9'add :eax') or (listing[i+16] = #9'sub :eax')) and		// add|sub :eax				; 16
       tay(i+17) then									// tay					; 17
     begin
      listing[i] := '';

      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'sta :eax';

      listing[i+7]  := '';
      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';

      if listing[i+16] = #9'add :eax' then
	listing[i+15] := #9'add ' + copy(listing[i+15], 6, 256)
      else
	listing[i+15] := #9'sub ' + copy(listing[i+15], 6, 256);

      listing[i+6] := '';
      listing[i+16] := '';

      Result:=false; Break;
     end;


    if ldy_im_0(i) and 									// ldy #$00				; 0
       lda(i+1) and 									// lda 					; 1
       spl(i+2) and 									// spl					; 2
       dey(i+3) and 									// dey					; 3
       (listing[i+4] = #9'sta :eax') and 						// sta :eax				; 4
       (listing[i+5] = #9'sty :eax+1') and 						// sty :eax+1				; 5
       (listing[i+6] = #9'lda #$0A') and 						// lda #$0A				; 6
       (listing[i+7] = #9'sta :ecx') and 						// sta :ecx				; 7
       lda_im_0(i+8) and 								// lda #$00				; 8
       (listing[i+9] = #9'sta :ecx+1') and 						// sta :ecx+1				; 9
       IFDEF_MUL16(i+10) and 								// .ifdef fmulinit			; 10
      											// fmulu_16				; 11
       											// els					; 12
       											// imulCX				; 13
       											// eif					; 14
       lda(i+15) and 									// lda 					; 15
       add_sub(i+16) and								// add|sub				; 16
       ((listing[i+17] = #9'add :eax') or (listing[i+17] = #9'sub :eax')) and		// add|sub :eax				; 17
       (sta(i+18) or tay(i+18)) then							// sta|tay				; 18
     begin
      listing[i] := '';

      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'sta :eax';

      listing[i+7]  := '';
      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';

      if listing[i+17] = #9'add :eax' then
	listing[i+15] := #9'add ' + copy(listing[i+15], 6, 256)
      else
	listing[i+15] := #9'sub ' + copy(listing[i+15], 6, 256);

      listing[i+6] := '';
      listing[i+17] := '';

      Result:=false; Break;
     end;

