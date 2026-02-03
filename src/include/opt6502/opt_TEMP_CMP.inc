
// -----------------------------------------------------------------------------
// ===				      CMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_CMP;
var p: integer;
begin

   if lda(0) and									// lda I		; 0
      cmp(1) and									// cmp			; 1
      SKIP(2) and									// SKIP			; 2
      (TemporaryBuf[3] = '') and							//			; 3
      opti(4) and									//; optimize 		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      (TemporaryBuf[6] = TemporaryBuf[0]) and						// lda I		; 6
      (SKIP(7) = false) then
    begin
     TemporaryBuf[6] := '~';

     p:=7;

     while cmp(p) and								/// cmp			; 7
        SKIP(p+1) and								/// SKIP		; 8
        (TemporaryBuf[p+2] = TemporaryBuf[0]) and				/// lda I		; 9
        (SKIP(p+3) = false) do
       begin
	TemporaryBuf[p+2] := '~';

	inc(p, 3);
       end;

    end;


   if lda(0) and									// lda I		; 0
      cmp(1) and									// cmp			; 1
      SKIP(2) and									// SKIP			; 2
      (TemporaryBuf[3] = TemporaryBuf[0]) and						// lda I		; 3
      (SKIP(4) = false) then
    begin
     TemporaryBuf[3] := '~';

     p:=4;

     while cmp(p) and								/// cmp			; 4
        SKIP(p+1) and								/// SKIP		; 5
        (TemporaryBuf[p+2] = TemporaryBuf[0]) and				/// lda I		; 6
        (SKIP(p+3) = false) do
      begin
	TemporaryBuf[p+2] := '~';

	inc(p,3)
      end;

    end;


   if lda(0) and (TemporaryBuf[0] = TemporaryBuf[3]) and				// lda I		; 0
      cmp(1) and									// cmp			; 1
      SKIP(2) and									// SKIP			; 2
//      lda(3) and									// lda I		; 3
      (jeq(4) or jne(4)) then								// jeq|jne		; 4
    begin
     TemporaryBuf[3] := #9'cmp #$00';
    end;


   if lda(0) and									// lda W		; 0
      cmp(1) and									// cmp			; 1
      SKIP(2) and									// SKIP			; 2
      (TemporaryBuf[3] = '') and							//			; 3
      opti(4) and									//; optimize 		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      ldy(6) and									// ldy W		; 6
      lda(7) then									// lda 			; 7
    if argMatch(0, 6) then
    begin

     if (iy(0) = false) and (iy(1) = false) then begin
      TemporaryBuf[0] := #9'ldy ' + copy(TemporaryBuf[0], 6, 256);
      TemporaryBuf[1] := #9'cpy ' + copy(TemporaryBuf[1], 6, 256);

      TemporaryBuf[6] := '~';
     end else
      TemporaryBuf[6] := #9'tay';

    end;


   if lda(0) and									// lda W		; 0
      cmp(1) and									// cmp			; 1
      SKIP(2) and									// SKIP			; 2
      ldy(3) and									// ldy W		; 3
      lda(4) then									// lda 			; 4
    if argMatch(0, 3) then
    begin

     if (iy(0) = false) and (iy(1) = false) then begin
      TemporaryBuf[0] := #9'ldy ' + copy(TemporaryBuf[0], 6, 256);
      TemporaryBuf[1] := #9'cpy ' + copy(TemporaryBuf[1], 6, 256);

      TemporaryBuf[3] := '~';
     end else
      TemporaryBuf[3] := #9'tay';

    end;


    if sta_stack(0) and									// sta :STACKORIGIN	; 0	BOOL := BYTE > ?
       ldy_1(1) and 									// ldy #1		; 1
       lda_stack(2) and									// lda :STACKORIGIN	; 2
       cmp(3) and									// cmp			; 3
       bcs_a(4) and									// bcs @+		; 4
       dey(5) and									// dey			; 5
       lab_a(6) and									//@			; 6
       sty_stack(7) and									// sty :STACKORIGIN	; 7
       ldy(8) then									// ldy			; 8
     if argMatch(0, 2) then
     begin

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';

	TemporaryBuf[4] := #9'lda #$00';
	TemporaryBuf[5] := #9'rol @';
	TemporaryBuf[6] := #9'sta ' + copy(TemporaryBuf[7], 6, 256); 
	TemporaryBuf[7] := '~';

     end;


    if ldy_1(0) and 									// ldy #1		; 0	BOOL := BYTE > ?
       lda(1)and									// lda			; 1
       cmp(2) and									// cmp			; 2
       bcs_a(3) and									// bcs @+		; 3
       dey(4) and									// dey			; 4
       lab_a(5) and									//@			; 5
       tya(6) then									// tya			; 6
     begin

	TemporaryBuf[0] := '~';

	TemporaryBuf[3] := #9'lda #$00';
	TemporaryBuf[4] := #9'rol @';
	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';

     end;


   if sta_stack(0) and									// sta :STACKORIGIN	; 0
      ldy_1(1) and									// ldy #1		; 1
      lda_stack(2) and									// lda :STACKORIGIN	; 2
      (cmp(3) or and_ora_eor(3)) then							// cmp|and|ora|eor	; 3
    if argMatch(0, 2) then
    begin

      TemporaryBuf[0] := '~';

      TemporaryBuf[2] := '~';

    end;


end;	// procedure
