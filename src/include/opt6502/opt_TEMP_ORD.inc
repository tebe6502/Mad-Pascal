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

procedure opt_TEMP_ORD;
begin

    if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1			; 0	ord(byte = 0)
       (cmp(1) or lda(1)) and									// lda				; 1
       SKIP(2) and										// SKIP				; 2
       (TemporaryBuf[3] = #9'dey') and								// dey				; 3
       (TemporaryBuf[4] = '@') and								//@				; 4
       (TemporaryBuf[5] = #9'tya') and								// tya				; 5
       (TemporaryBuf[6] = #9'sta :ecx') and							// sta :ecx			; 6
       lda(7) and										// lda				; 7
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
       lda(1) and										// lda				; 1
       SKIP(2) and										// SKIP				; 2
       SKIP(3) and										// SKIP				; 3
       (TemporaryBuf[4] = #9'dey') and								// dey				; 4
       (TemporaryBuf[5] = '@') and								//@				; 5
       (TemporaryBuf[6] = #9'tya') and								// tya				; 6
       (TemporaryBuf[7] = #9'sta :ecx') and							// sta :ecx			; 7
       lda(8) and										// lda				; 8
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


    if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1			; 0	ord(byte ? N)
       lda(1) and										// lda				; 1
       cmp(2) and										// cmp				; 2
       SKIP(3) and										// SKIP				; 3
       (TemporaryBuf[4] = #9'dey') and								// dey				; 4
       (TemporaryBuf[5] = '@') and								//@				; 5
       (TemporaryBuf[6] = #9'tya') and								// tya				; 6
       (TemporaryBuf[7] = #9'sta :ecx') and							// sta :ecx			; 7
       lda(8) and										// lda				; 8
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


   if sta_stack(0) and										// sta :STACKORIGIN		; 0
      (TemporaryBuf[1] = #9'ldy #1') and							// ldy #1			; 1
      lda_stack(2) and										// lda :STACKORIGIN		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00			; 3
      (TemporaryBuf[4] = #9'beq @+') and							// beq @+			; 4
      (TemporaryBuf[5] = #9'dey') and								// dey				; 5
       (TemporaryBuf[6] = '@') and								//@				; 6
       (TemporaryBuf[7] = #9'tya') and								// tya				; 7
       (TemporaryBuf[8] = #9'sta :ecx') and							// sta :ecx			; 8
       lda(9) and										// lda				; 9
       (TemporaryBuf[10] = #9'sta :eax') and							// sta :eax			; 10
       IFDEF_MUL8(11) then									// IFDEF_MUL8			; 11
     if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[2], 6, 256)) then
      begin
	TemporaryBuf[0] := '~';

	TemporaryBuf[2] := '~';

        TemporaryBuf[8] := #9'seq';

        TemporaryBuf[11]  := #9'lda #$00';
        TemporaryBuf[12] := #9'sta :eax+1';
        TemporaryBuf[13] := '~';
        TemporaryBuf[14] := '~';
        TemporaryBuf[15] := '~';
      end;

end;	// procedure
