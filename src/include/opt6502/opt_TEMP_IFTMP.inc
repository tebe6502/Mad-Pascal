
// -----------------------------------------------------------------------------
// ===		     		      IFTMP.
// ===			Common head/tail Sequence coalescing
// -----------------------------------------------------------------------------

procedure opt_TEMP_IFTMP;
begin

   if (pos('l_', TemporaryBuf[0]) = 1) and						//l_xxxx		; 0
      (pos('lda IFTMP_', TemporaryBuf[1]) > 0) and					// lda IFTMP_xxxx	; 1
      (pos('jne l_', TemporaryBuf[2]) > 0) then						// jne l_xxxx		; 2
    begin
     TemporaryBuf[1] := TemporaryBuf[0];
     TemporaryBuf[0] := #9'jmp ' + copy(TemporaryBuf[2], 6, 256);

     TemporaryBuf[2] := TemporaryBuf[1];
     TemporaryBuf[1] := TemporaryBuf[0];
     TemporaryBuf[0] := '~';
    end;


   if (pos('l_', TemporaryBuf[1]) = 1) and						//l_xxxx		; 1
      (pos('lda IFTMP_', TemporaryBuf[2]) > 0) and					// lda IFTMP_xxxx	; 2
      (pos('beq *+5', TemporaryBuf[3]) > 0) and						// beq *+5		; 3
      (pos('jmp l_', TemporaryBuf[4]) > 0) then						// jmp l_xxxx		; 4
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
