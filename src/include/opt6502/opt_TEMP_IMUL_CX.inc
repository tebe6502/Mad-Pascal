
// -----------------------------------------------------------------------------
//				     IMUL_CX.
// -----------------------------------------------------------------------------

procedure opt_TEMP_IMUL_CX;
begin


  if IFDEF_MUL16(8) then		     	 						// .ifdef @fmulinit	; 8
  begin												// @fmulu_16		; 9
      												// els			; 10
												// @imulCX		; 11
												// eif			; 12


    if mva(0) and										// mva .. X		; 0
       (TemporaryBuf[1] = #9'mva #$00 ' + GetARG(5)) and 					// mva #$00 X+1		; 1
       lda(2) and										// lda X		; 2
       sta_ecx(3) and										// sta :ecx		; 3
       sta_eax(4) and										// sta :eax		; 4
       lda(5) and										// lda X+1		; 5
       sta_ecx_1(6) and										// sta :ecx+1		; 6
       sta_eax_1(7) then									// sta :eax+1		; 7
      begin
	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';
	TemporaryBuf[7] := '~';

	TemporaryBuf[9] := #9'@fmulu_8';

	TemporaryBuf[11]:= #9'@imulCL';
       end;


   if  lda_im_0(0) and										// lda #$00		; 0
       sta(1) and										// sta X+1		; 1
       lda(2) and										// lda X		; 2
       sta_ecx(3) and										// sta :ecx		; 3
       sta_eax(4) and										// sta :eax		; 4
       lda(5) and										// lda X+1		; 5
       sta_ecx_1(6) and										// sta :ecx+1		; 6
       sta_eax_1(7) then									// sta :eax+1		; 7
     if argMatch(1, 5) then
      begin
	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';
	TemporaryBuf[7] := '~';

	TemporaryBuf[9] := #9'@fmulu_8';

	TemporaryBuf[11]:= #9'@imulCL';
       end;


// -----------------------------------------------------------------------------
//			imulCX (16x16) -> imulCX_AL (16x8)
// -----------------------------------------------------------------------------


  if lda(0) and (lda_eax(0) = false) and						// lda					; 0
     sta_ecx(1) and									// sta :ecx				; 1
     lda_im_0(2) and									// lda #$00				; 2
     sta_ecx_1(3) and									// sta :ecx+1				; 3
     (lda_im(4) = false) and								// lda 					; 4
     sta_eax(5) and						 			// sta :eax				; 5
     (lda_im(6) = false) and								// lda					; 6
     sta_eax_1(7) then						 			// sta :eax+1				; 7
   begin
    TemporaryBuf[1] := #9'sta :eax';

    TemporaryBuf[3] := #9'sta :eax+1';

    TemporaryBuf[5] := #9'sta :ecx';

    TemporaryBuf[7] := #9'sta :ecx+1';

    TemporaryBuf[11] := #9'@imulCX_AL';
   end;


  if (lda_im(0) = false) and								//~lda #				; 0
     sta_eax(1) and									// sta :eax				; 1
     lda_im_0(2) and									// lda #$00				; 2
     sta_eax_1(3) and									// sta :eax+1				; 3
     lda(4) and										// lda 					; 4
     sta_ecx(5) and						 			// sta :ecx				; 5
     lda(6) and										// lda					; 6
     sta_ecx_1(7) then						 			// sta :ecx+1				; 7
   begin
    TemporaryBuf[11] := #9'@imulCX_AL';
   end;


  if lda(0) and										// lda					; 0
     sta_ecx(1) and									// sta :ecx				; 1
     lda(2) and										// lda					; 2
     sta_ecx_1(3) and									// sta :ecx+1				; 3
     lda(4) and (lda_im(4) = false) and							// lda 					; 4
     sta_eax(5) and						 			// sta :eax				; 5
     lda_im_0(6) and									// lda #$00				; 6
     sta_eax_1(7) then						 			// sta :eax+1				; 7
   begin
    TemporaryBuf[11]:= #9'@imulCX_AL';
   end;


  if (lda_im(0) = false) and								//~lda #				; 0
     sta_ecx(1) and									// sta :ecx				; 1
     lda_im_0(2) and									// lda #$00				; 2
     sta_ecx_1(3) and									// sta :ecx+1				; 3
     lda(4) and										// lda 					; 4
     sta_eax(5) and						 			// sta :eax				; 5
     lda(6) and										// lda					; 6
     sta_eax_1(7) then						 			// sta :eax+1				; 7
   begin
    TemporaryBuf[1] := #9'sta :eax';

    TemporaryBuf[3] := #9'sta :eax+1';

    TemporaryBuf[5] := #9'sta :ecx';

    TemporaryBuf[7] := #9'sta :ecx+1';

    TemporaryBuf[11]:= #9'@imulCX_AL';
   end;


  end;


end;	// procedure
