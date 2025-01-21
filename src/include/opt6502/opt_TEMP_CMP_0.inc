
// -----------------------------------------------------------------------------
// ===				      CMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_CMP_0;
var p: integer;
begin


    if ((TemporaryBuf[2] = #9'cmp #$00') or lda(2)) and (IFTMP(2) = false) and			// lda|cmp #$00		; 2	~lda IFTMP_
       jne_l(3) and										// jne l_		; 3
       (lab_l(4) = false) then									//~l_xxxx		; 4
     begin

      for p:=4 to High(TemporaryBuf) do
       if lda(p) then begin

        if TemporaryBuf[p] = #9'lda #$00' then TemporaryBuf[p] := '~';

	Break;

       end else
        if (pos('#asm:', TemporaryBuf[p]) = 1) or
	   lab_l(p) or
           jsr(p) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) or
           (TemporaryBuf[p] = #9'tya') then Break;

     end;


   if sta_stack(0) and										// sta :STACKORIGIN	; 0
      (TemporaryBuf[1] = #9'ldy #1') and							// ldy #1		; 1
      lda_stack(2) and										// lda :STACKORIGIN	; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      ((TemporaryBuf[4] = #9'beq @+') or (TemporaryBuf[4] = #9'bne @+')) and			// beq|bne		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = '@') and								//@			; 6
      ((TemporaryBuf[7] = #9'tya') or sty(7)) then						// tya|sty		; 7
     if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[2], 6, 256)) then
      begin
	TemporaryBuf[0] := '~';

	TemporaryBuf[2] := '~';
      end;


   if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
      lda(1) and (lda_stack(1) = false) and							// lda 			; 1
      (TemporaryBuf[2] = #9'cmp #$00') and							// cmp #$00		; 2
      ((TemporaryBuf[3] = #9'beq @+') or (TemporaryBuf[3] = #9'bne @+')) and			// beq|bne		; 3
      (TemporaryBuf[4] = #9'dey') and								// dey			; 4
      (TemporaryBuf[5] = '@') and								//@			; 5
      ((TemporaryBuf[6] = #9'tya') or sty(6)) then						// tya|sty		; 6
      begin
	TemporaryBuf[2] := '~';
      end;


   if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
      and_ora_eor(1) and									// and|orq|eor		; 1
      (TemporaryBuf[2] = #9'cmp #$00') and							// cmp #$00		; 2
      ((TemporaryBuf[3] = #9'beq @+') or (TemporaryBuf[3] = #9'bne @+')) and			// beq|bne		; 3
      (TemporaryBuf[4] = #9'dey') and								// dey			; 4
      (TemporaryBuf[5] = '@') and								//@			; 5
      ((TemporaryBuf[6] = #9'tya') or sty(6)) then						// tya|sty		; 6
      begin
	TemporaryBuf[2] := '~';
      end;


   if (TemporaryBuf[2] = #9'ldy #1') and							// ldy #1		; 2
      lda(3) and										// lda 			; 3
      (TemporaryBuf[4] = #9'cmp #$00') and							// cmp #$00		; 4
      (TemporaryBuf[5] = #9'bne @+') and							// bne			; 5
      lda(6) and										// lda 			; 6
      (TemporaryBuf[7] = #9'cmp #$00') and							// cmp #$00		; 7
      (TemporaryBuf[8] = '@') and								//@			; 8
      ((TemporaryBuf[9] = #9'beq @+') or (TemporaryBuf[9] = #9'bne @+')) and			// beq|bne		; 9
      (TemporaryBuf[10] = #9'dey') and								// dey			; 10
      (TemporaryBuf[11] = '@') and								//@			; 11
      ((TemporaryBuf[12] = #9'tya') or sty(12)) then						// tya|sty		; 12
      begin
	TemporaryBuf[4] := #9'ora ' + copy(TemporaryBuf[6], 6, 256);
	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';
	TemporaryBuf[7] := '~';
	TemporaryBuf[8] := '~';
      end;


   if lda(2) and										// lda			; 2
      sta(3) and										// sta			; 3
      (TemporaryBuf[4] = #9'cmp #$00') and							// cmp #$00		; 4
      ((TemporaryBuf[5] = #9'beq @+') or (TemporaryBuf[5] = #9'bne @+')) and			// beq|bne		; 5
      jmp(6) and										// sta			; 6
      (TemporaryBuf[7] = '@') then								//@			; 7
    begin
     TemporaryBuf[4] := '~';
    end;


   if (TemporaryBuf[2] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 6
      cmp(7) and										// cmp			; 7
      (TemporaryBuf[8] = #9'bne @+') and							// bne @+		; 8
      (TemporaryBuf[9] = #9'dey') and								// dey			; 9
      (TemporaryBuf[10] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 10
      cmp(11) and										// cmp			; 11
      (TemporaryBuf[12] = #9'bne @+') and							// bne @+		; 12
      (TemporaryBuf[13] = #9'dey') and								// dey			; 13
      (TemporaryBuf[14] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 14
      cmp(15) and										// cmp			; 15
      (TemporaryBuf[16] = '@') and								//@			; 16
      (jeq(17) or jne(17)) and									// jeq|jne		; 17
      (SKIP(18) = false) then									//~SKIP			; 18
    begin
     TemporaryBuf[3] := '~';
    end;


   if (TemporaryBuf[2] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 6
      cmp(7) and										// cmp			; 7
      (TemporaryBuf[8] = #9'bne @+') and							// bne @+		; 8
      (TemporaryBuf[9] = #9'dey') and								// dey			; 9
      (TemporaryBuf[10] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 10
      cmp(11) and										// cmp			; 11
      (TemporaryBuf[12] = '@') and								//@			; 12
      (jeq(13) or jne(13)) and									// jeq|jne		; 13
      (SKIP(14) = false) then									//~SKIP			; 14
    begin
     TemporaryBuf[3] := '~';
    end;


   if (TemporaryBuf[2] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 6
      cmp(7) and										// cmp			; 7
      (TemporaryBuf[8] = '@') and								//@			; 8
      (jeq(9) or jne(9)) and									// jeq|jne		; 9
      (SKIP(10) = false) then									//~SKIP			; 10
    begin
     TemporaryBuf[3] := '~';
    end;


   if lda(2) and										// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      lda(5) and										// lda W		; 5
      cmp(6) and										// cmp 			; 6
      (TemporaryBuf[7] = #9'bne @+') and							// bne @+		; 7
      lda(8) and										// lda W		; 8
      cmp(9) and										// cmp 			; 9
      (TemporaryBuf[10] = #9'bne @+') and							// bne @+		; 10
      lda(11) and										// lda W		; 11
      cmp(12) and										// cmp 			; 12
      (TemporaryBuf[13] = '@') and								//@			; 13
      (jeq(14) or jne(14)) and									// jeq|jne		; 14
      (SKIP(15) = false) then									//~SKIP			; 15
    begin
     TemporaryBuf[3] := '~';

     if (TemporaryBuf[6] = #9'cmp #$00') and
        (TemporaryBuf[9] = #9'cmp #$00') and
        (TemporaryBuf[12] = #9'cmp #$00') then
       begin
	TemporaryBuf[6] := '~';
	TemporaryBuf[9] := '~';
	TemporaryBuf[12] := '~';

	if jeq(14) then begin
	 TemporaryBuf[13] := TemporaryBuf[14];
	 TemporaryBuf[14] := '@';
	end;

       end;

    end;


   if lda(2) and										// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      lda(5) and										// lda W		; 5
      (TemporaryBuf[6] = #9'cmp #$00') and							// cmp #$00		; 6
      (TemporaryBuf[7] = #9'bne @+') and							// bne @+		; 7
      lda(8) and										// lda W		; 8
      (TemporaryBuf[9] = #9'cmp #$00') and							// cmp #$00		; 9
      (TemporaryBuf[10] = #9'bne @+') and							// bne @+		; 10
      lda(11) and										// lda W		; 11
      (TemporaryBuf[12] = #9'cmp #$00') and							// cmp #$00		; 12
      (TemporaryBuf[13] = '@') and								//@			; 13
      ((TemporaryBuf[14] = #9'beq @+') or (TemporaryBuf[14] = #9'bne @+')) and			// beq @+|bne @+	; 14
      (TemporaryBuf[15] = #9'dey') and								// dey			; 15
      (TemporaryBuf[16] = '@') and								//@			; 16
      ((TemporaryBuf[17] = #9'tya') or sty(17)) then						// tya|sty		; 17
    begin
     TemporaryBuf[3] := '~';

     TemporaryBuf[6] := '~';

     TemporaryBuf[9] := '~';

     TemporaryBuf[12] := '~';
    end;


    if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
       lda(1) and										// lda W+1		; 1
       (TemporaryBuf[2] = #9'cmp #$00') and							// cmp #$00		; 2
       (TemporaryBuf[3] = #9'bne @+') and							// bne @+		; 3
       lda(4) and										// lda W		; 4
       cmp(5) and										// cmp			; 5
       (TemporaryBuf[6] = '@') and								//@			; 6
       (TemporaryBuf[7] = #9'bcs @+') and							// bcs @+		; 7
       (TemporaryBuf[8] = #9'dey') and								// dey			; 8
       (TemporaryBuf[9] = '@') and								//@			; 9
       ((TemporaryBuf[10] = #9'tya') or sty(10)) then						// tya|sty		; 10
      begin
       TemporaryBuf[2] := '~';

       TemporaryBuf[6] := '~';
      end;


   if lda(2) and										// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      lda(5) and										// lda W		; 5
      cmp(6) and										// cmp 			; 6
      (TemporaryBuf[7] = #9'bne @+') and							// bne @+		; 7
      lda(8) and										// lda W		; 8
      cmp(9) and										// cmp 			; 9
      (TemporaryBuf[10] = '@') and								//@			; 10
      (jeq(11) or jne(11)) and									// jeq|jne		; 11
      (SKIP(12) = false) then									//~SKIP			; 12
    begin
     TemporaryBuf[3] := '~';
    end;


   if lda(2) and										// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      lda(5) and										// lda W		; 5
      cmp(6) and										// cmp 			; 6
      (TemporaryBuf[7] = '@') and								//@			; 7
      (jeq(8) or jne(8)) and									// jeq|jne		; 8
      (SKIP(9) = false) then									//~SKIP			; 9
    begin
     TemporaryBuf[3] := '~';
    end;


   if lda(2) and										// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = '@') and								//@			; 4
      (jeq(5) or jne(5)) and									// jeq|jne		; 5
      (SKIP(6) = false) then									//~SKIP			; 6
    begin
     TemporaryBuf[3] := '~';
    end;

end;	// procedure
