
// -----------------------------------------------------------------------------
//				     IMUL_CX.
// -----------------------------------------------------------------------------

procedure opt_TEMP_IMUL_CX;
begin

    if IFDEF_MUL16(8) and			     	 					// .ifdef @fmulinit	; 8
      												// @fmulu_16		; 9
      												// els			; 10
												// @imulCX		; 11
												// eif			; 12

       mva(0) and										// mva .. X		; 0
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


    if IFDEF_MUL16(8) and			     	 					// .ifdef @fmulinit	; 8
      												// @fmulu_16		; 9
      												// els			; 10
												// @imulCX		; 11
												// eif			; 12

       lda_im_0(0) and										// lda #$00		; 0
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




{

// -----------------------------------------------------------------------------
// ===			imulCX (16x16) -> imulCX_AL (16x8)		  === //
// -----------------------------------------------------------------------------


  if lda_a(i) and (lda_eax(i) = false) and						// lda					; 0
     sta_ecx(i+1) and									// sta :ecx				; 1
     lda_im_0(i+2) and									// lda #$00				; 2
     sta_ecx_1(i+3) and									// sta :ecx+1				; 3
     (lda_im(i+4) = false) and								// lda 					; 4
     sta_eax(i+5) and						 			// sta :eax				; 5
     (lda_im(i+6) = false) and								// lda					; 6
     sta_eax_1(i+7) then						 		// sta :eax+1				; 7
   begin
    listing[i+1] := #9'sta :eax';

    listing[i+3] := #9'sta :eax+1';

    listing[i+5] := #9'sta :ecx';

    listing[i+7] := #9'sta :ecx+1';

    listing[i+11] := #9'@imulCX_AL';

    exit(false);
   end;


  if (lda_im(i) = false) and								//~lda #				; 0
     sta_eax(i+1) and									// sta :eax				; 1
     lda_im_0(i+2) and									// lda #$00				; 2
     sta_eax_1(i+3) and									// sta :eax+1				; 3
     lda_a(i+4) and									// lda 					; 4
     sta_ecx(i+5) and						 			// sta :ecx				; 5
     lda_a(i+6) and									// lda					; 6
     sta_ecx_1(i+7) then						 		// sta :ecx+1				; 7
   begin
    listing[i+11] := #9'@imulCX_AL';

    exit(false);
   end;


  if lda_a(i) and									// lda					; 0
     sta_ecx(i+1) and									// sta :ecx				; 1
     lda_a(i+2) and									// lda					; 2
     sta_ecx_1(i+3) and									// sta :ecx+1				; 3
     lda_a(i+4) and (lda_im(i+4) = false) and						// lda 					; 4
     sta_eax(i+5) and						 			// sta :eax				; 5
     lda_im_0(i+6) and									// lda #$00				; 6
     sta_eax_1(i+7) then						 		// sta :eax+1				; 7
   begin
    listing[i+11]:= #9'@imulCX_AL';

    exit(false);
   end;


  if (lda_im(i) = false) and								//~lda #				; 0
     sta_ecx(i+1) and									// sta :ecx				; 1
     lda_im_0(i+2) and									// lda #$00				; 2
     sta_ecx_1(i+3) and									// sta :ecx+1				; 3
     lda_a(i+4) and									// lda 					; 4
     sta_eax(i+5) and						 			// sta :eax				; 5
     lda_a(i+6) and									// lda					; 6
     sta_eax_1(i+7) then						 		// sta :eax+1				; 7
   begin
    listing[i+1] := #9'sta :eax';

    listing[i+3] := #9'sta :eax+1';

    listing[i+5] := #9'sta :ecx';

    listing[i+7] := #9'sta :ecx+1';

    listing[i+11]:= #9'@imulCX_AL';

    exit(false);
   end;
}




end;	// procedure
