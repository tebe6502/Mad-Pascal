
// -----------------------------------------------------------------------------
//				     IMUL_CX.
// -----------------------------------------------------------------------------

procedure opt_TEMP_IMUL_CX;
begin

    if IFDEF_MUL16(8) and			     	 					// .ifdef fmulinit	; 8
      												// fmulu_16		; 9
      												// els			; 10
												// imulCX		; 11
												// eif			; 12

       (pos('mva ', TemporaryBuf[0]) > 0) and (pos('mva :STACK', TemporaryBuf[0]) = 0) and	// mva .. X		; 0
       (TemporaryBuf[1] = #9'mva #$00 ' + copy(TemporaryBuf[5], 6, 256)) and 			// mva #$00 X+1		; 1
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

	TemporaryBuf[9] := #9'fmulu_8';

	TemporaryBuf[11]:= #9'imulCL';
       end;


    if IFDEF_MUL16(8) and			     	 					// .ifdef fmulinit	; 8
      												// fmulu_16		; 9
      												// els			; 10
												// imulCX		; 11
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

	TemporaryBuf[9] := #9'fmulu_8';

	TemporaryBuf[11]:= #9'imulCL';
       end;

end;	// procedure
