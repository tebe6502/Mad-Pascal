
// -----------------------------------------------------------------------------
// ===		     		      IFTMP.
// ===			Common head/tail Sequence coalescing
// -----------------------------------------------------------------------------

procedure opt_TEMP_IFTMP;
begin

   if lab_l(0) and									//l_xxxx		; 0
      IFTMP(1) and									// lda IFTMP_xxxx	; 1
      jne_l(2) then									// jne l_xxxx		; 2
    begin
     TemporaryBuf[1] := TemporaryBuf[0];
     TemporaryBuf[0] := #9'jmp ' + copy(TemporaryBuf[2], 6, 256);

     TemporaryBuf[2] := TemporaryBuf[1];
     TemporaryBuf[1] := TemporaryBuf[0];
     TemporaryBuf[0] := '~';
    end;


   if lab_l(1) and									//l_xxxx		; 1
      IFTMP(2) and									// lda IFTMP_xxxx	; 2
      (TemporaryBuf[3] = #9'beq *+5') and						// beq *+5		; 3
      jmp_l(4) then									// jmp l_xxxx		; 4
    begin
     TemporaryBuf[2] := TemporaryBuf[1];
     TemporaryBuf[1] := #9'jmp ' + copy(TemporaryBuf[4], 6, 256);

     TemporaryBuf[3] := TemporaryBuf[2];
     TemporaryBuf[2] := TemporaryBuf[1];
     TemporaryBuf[1] := '~';
     TemporaryBuf[4] := '~';

     if (pos(#9'jmp ', TemporaryBuf[0]) = 1) and					// jmp			; 0
        (TemporaryBuf[1] = '~') and							//~			; 1
        (pos(#9'jmp ', TemporaryBuf[2]) = 1) then					// jmp			; 2
      begin
       TemporaryBuf[2] := '~';
      end;

    end;

end;	// procedure
