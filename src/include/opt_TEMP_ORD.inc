// -----------------------------------------------------------------------------
//				     ORD.
// -----------------------------------------------------------------------------
//
//  ze wzgledu na sekwencje
//
//  SEQ
//  LDA label
//
//  optymalizacja ORD(expression) mozliwa tylko w TemporaryBuf
//
// -----------------------------------------------------------------------------

    if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1			; 0	ord(byte = 0)
       ((pos('cmp ', TemporaryBuf[1]) > 0) or (pos('lda ', TemporaryBuf[1]) > 0)) and		// lda				; 1
       SKIP(2) and										// SKIP				; 2
       (TemporaryBuf[3] = #9'dey') and								// dey				; 3
       (TemporaryBuf[4] = '@') and								//@				; 4
       (TemporaryBuf[5] = #9'tya') and								// tya				; 5
       (TemporaryBuf[6] = #9'sta :ecx') and							// sta :ecx			; 6
       (pos('lda ', TemporaryBuf[7]) > 0) and							// lda				; 7
       (TemporaryBuf[8] = #9'sta :eax') and							// sta :eax			; 8
       IFDEF_MUL8(9) then									// IFDEF_MUL8			; 9
     begin
       TemporaryBuf[6] := #9'seq';

       TemporaryBuf[9]  := #9'lda #$00';
       TemporaryBuf[10] := #9'sta :eax+1';
       TemporaryBuf[11] := '~';
       TemporaryBuf[12] := '~';
       TemporaryBuf[13] := '~';
     end;


    if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1			; 0	ord(byte <= N)
       (pos('lda ', TemporaryBuf[1]) > 0) and							// lda				; 1
       SKIP(2) and										// SKIP				; 2
       SKIP(3) and										// SKIP				; 3
       (TemporaryBuf[4] = #9'dey') and								// dey				; 4
       (TemporaryBuf[5] = '@') and								//@				; 5
       (TemporaryBuf[6] = #9'tya') and								// tya				; 6
       (TemporaryBuf[7] = #9'sta :ecx') and							// sta :ecx			; 7
       (pos('lda ', TemporaryBuf[8]) > 0) and							// lda				; 8
       (TemporaryBuf[9] = #9'sta :eax') and							// sta :eax			; 9
       IFDEF_MUL8(10) then									// IFDEF_MUL8			; 10
     begin
       TemporaryBuf[7] := #9'seq';

       TemporaryBuf[10]  := #9'lda #$00';
       TemporaryBuf[11] := #9'sta :eax+1';
       TemporaryBuf[12] := '~';
       TemporaryBuf[13] := '~';
       TemporaryBuf[14] := '~';
     end;
