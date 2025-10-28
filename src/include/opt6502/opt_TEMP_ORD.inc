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

    if ldy_1(0) and										// ldy #1			; 0	ord(byte = 0)
       (cmp(1) or lda(1)) and									// lda				; 1
       SKIP(2) and										// SKIP				; 2
       dey(3) and										// dey				; 3
       lab_a(4) and										//@				; 4
       tya(5) and										// tya				; 5
       sta_ecx(6) and										// sta :ecx			; 6
       lda(7) and										// lda				; 7
       sta_eax(8) and										// sta :eax			; 8
       IFDEF_MUL8(9) then									// IFDEF_MUL8			; 9
     begin
       TemporaryBuf[6] := #9'seq';

       TemporaryBuf[9]  := #9'lda #$00';
       TemporaryBuf[10] := #9'sta :eax+1';
       TemporaryBuf[11] := '~';
       TemporaryBuf[12] := '~';
       TemporaryBuf[13] := '~';
     end;


    if ldy_1(0) and										// ldy #1			; 0	ord(byte <= N)
       lda(1) and										// lda				; 1
       SKIP(2) and										// SKIP				; 2
       SKIP(3) and										// SKIP				; 3
       dey(4) and										// dey				; 4
       lab_a(5) and										//@				; 5
       tya(6) and										// tya				; 6
       sta_ecx(7) and										// sta :ecx			; 7
       lda(8) and										// lda				; 8
       sta_eax(9) and										// sta :eax			; 9
       IFDEF_MUL8(10) then									// IFDEF_MUL8			; 10
     begin
       TemporaryBuf[7] := #9'seq';

       TemporaryBuf[10]  := #9'lda #$00';
       TemporaryBuf[11] := #9'sta :eax+1';
       TemporaryBuf[12] := '~';
       TemporaryBuf[13] := '~';
       TemporaryBuf[14] := '~';
     end;


    if ldy_1(0) and										// ldy #1			; 0	ord(byte ? N)
       lda(1) and										// lda				; 1
       cmp(2) and										// cmp				; 2
       SKIP(3) and										// SKIP				; 3
       dey(4) and										// dey				; 4
       lab_a(5) and										//@				; 5
       tya(6) and										// tya				; 6
       sta_ecx(7) and										// sta :ecx			; 7
       lda(8) and										// lda				; 8
       sta_eax(9) and										// sta :eax			; 9
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
      ldy_1(1) and										// ldy #1			; 1
      lda_stack(2) and										// lda :STACKORIGIN		; 2
      cmp_im_0(3) and										// cmp #$00			; 3
      beq_a(4) and										// beq @+			; 4
      dey(5) and										// dey				; 5
      lab_a(6) and										//@				; 6
      tya(7) and										// tya				; 7
      sta_ecx(8) and										// sta :ecx			; 8
      lda(9) and										// lda				; 9
      sta_eax(10) and										// sta :eax			; 10
      IFDEF_MUL8(11) then									// IFDEF_MUL8			; 11
     if argMatch(0, 2) then
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
