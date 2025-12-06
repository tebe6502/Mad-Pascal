
// -----------------------------------------------------------------------------
// ===				      JMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_ZTMP;
begin


   if (TemporaryBuf[0] = #9'lda :ztmp10') and						// lda :ztmp10		; 0
      bpl_a(1) and									// bpl @+		; 1
      lda_eax_1(2) and									// lda :eax+1		; 2
      (TemporaryBuf[3] = #9'sub :ztmp8') and						// sub :ztmp8		; 3
      sta_eax_1(4) and									// sta :eax+1		; 4
      lab_a(5) and									//@			; 5
      (TemporaryBuf[6] = #9'lda :ztmp8') and						// lda :ztmp8		; 6
      bpl_a(7) and									// bpl @+		; 7
      lda_eax_1(8) and									// lda :eax+1		; 8
      (TemporaryBuf[9] = #9'sub :ztmp10') and						// sub :ztmp8		; 9
      sta_eax_1(10) and									// sta :eax+1		; 10
      lab_a(11) then									//@			; 11
    begin
//     TemporaryBuf[0] := #9'lda :eax+1';

     TemporaryBuf[0] := '~';
     TemporaryBuf[1] := '~';
     TemporaryBuf[2] := #9'bit :ztmp10';
     TemporaryBuf[3] := #9'bpl @+';
     TemporaryBuf[4] := #9'sub :ztmp8';
     TemporaryBuf[5] := '@';
     TemporaryBuf[6] := #9'bit :ztmp8';
     TemporaryBuf[7] := #9'bpl @+';
     TemporaryBuf[8] := #9'sub :ztmp10';
     TemporaryBuf[9] := '@';

     TemporaryBuf[11] := '~';

     if lda_eax_1(12) then begin					/// lda :eax+1		; 12
      TemporaryBuf[10] := '~';

      TemporaryBuf[12] := '~';
     end else
      TemporaryBuf[10] := #9'sta :eax+1';

    end;


end;	// procedure
