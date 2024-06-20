
// -----------------------------------------------------------------------------
// ===				      CMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_CMP_0;
var p: integer;
begin


    if ((TemporaryBuf[2] = #9'cmp #$00') or (pos('lda ', TemporaryBuf[2]) > 0)) and		// lda|cmp #$00		; 2
       (pos('lda IFTMP_', TemporaryBuf[2]) = 0) and						//~lda IFTMP_
       (pos('jne l_', TemporaryBuf[3]) > 0) and							// jne l_		; 3
       (pos('l_ ', TemporaryBuf[4]) = 0) then							//~l_xxxx		; 4
     begin

      for p:=4 to High(TemporaryBuf) do
       if (pos('lda ', TemporaryBuf[p]) > 0) then begin

        if TemporaryBuf[p] = #9'lda #$00' then TemporaryBuf[p] := '~';

	Break;

       end else
        if (pos('#asm:', TemporaryBuf[p]) = 1) or
	   (pos('l_', TemporaryBuf[p]) = 1) or
           (pos('jsr ', TemporaryBuf[p]) > 0) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) or
           (TemporaryBuf[p] = #9'tya') then Break;

     end;


   if (pos('sta :STACK', TemporaryBuf[0]) > 0) and						// sta :STACKORIGIN	; 0
      (TemporaryBuf[1] = #9'ldy #1') and							// ldy #1		; 1
      (pos('lda :STACK', TemporaryBuf[2]) > 0) and						// lda :STACKORIGIN	; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      ((TemporaryBuf[4] = #9'beq @+') or (TemporaryBuf[4] = #9'bne @+')) and			// beq|bne		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = '@') and								//@			; 6
      ((TemporaryBuf[7] = #9'tya') or (pos('sty ', TemporaryBuf[7]) >0)) then			// tya|sty		; 7
     if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[2], 6, 256)) then
      begin
	TemporaryBuf[0] := '~';

	TemporaryBuf[2] := '~';
      end;


   if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
      (pos('lda ', TemporaryBuf[1]) > 0) and (pos('lda :STACK', TemporaryBuf[1]) = 0) and	// lda 			; 1
      (TemporaryBuf[2] = #9'cmp #$00') and							// cmp #$00		; 2
      ((TemporaryBuf[3] = #9'beq @+') or (TemporaryBuf[3] = #9'bne @+')) and			// beq|bne		; 3
      (TemporaryBuf[4] = #9'dey') and								// dey			; 4
      (TemporaryBuf[5] = '@') and								//@			; 5
      ((TemporaryBuf[6] = #9'tya') or (pos('sty ', TemporaryBuf[6]) >0)) then			// tya|sty		; 6
      begin
	TemporaryBuf[2] := '~';
      end;


   if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
      ((pos('and ', TemporaryBuf[1]) > 0) or							// and 			; 1
       (pos('ora ', TemporaryBuf[1]) > 0) or							// ora 			; 1
       (pos('eor ', TemporaryBuf[1]) > 0)) and							// eor 			; 1
      (TemporaryBuf[2] = #9'cmp #$00') and							// cmp #$00		; 2
      ((TemporaryBuf[3] = #9'beq @+') or (TemporaryBuf[3] = #9'bne @+')) and			// beq|bne		; 3
      (TemporaryBuf[4] = #9'dey') and								// dey			; 4
      (TemporaryBuf[5] = '@') and								//@			; 5
      ((TemporaryBuf[6] = #9'tya') or (pos('sty ', TemporaryBuf[6]) >0)) then			// tya|sty		; 6
      begin
	TemporaryBuf[2] := '~';
      end;


   if (TemporaryBuf[2] = #9'ldy #1') and							// ldy #1		; 2
      (pos('lda ', TemporaryBuf[3]) > 0) and							// lda 			; 3
      (TemporaryBuf[4] = #9'cmp #$00') and							// cmp #$00		; 4
      (TemporaryBuf[5] = #9'bne @+') and							// bne			; 5
      (pos('lda ', TemporaryBuf[6]) > 0) and							// lda 			; 6
      (TemporaryBuf[7] = #9'cmp #$00') and							// cmp #$00		; 7
      (TemporaryBuf[8] = '@') and								//@			; 8
      ((TemporaryBuf[9] = #9'beq @+') or (TemporaryBuf[9] = #9'bne @+')) and			// beq|bne		; 9
      (TemporaryBuf[10] = #9'dey') and								// dey			; 10
      (TemporaryBuf[11] = '@') and								//@			; 11
      ((TemporaryBuf[12] = #9'tya') or (pos('sty ', TemporaryBuf[12]) >0)) then			// tya|sty		; 12
      begin
	TemporaryBuf[4] := #9'ora ' + copy(TemporaryBuf[6], 6, 256);
	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';
	TemporaryBuf[7] := '~';
	TemporaryBuf[8] := '~';
      end;


   if (pos('lda ', TemporaryBuf[2]) > 0) and							// lda			; 2
      (pos('sta ', TemporaryBuf[3]) > 0) and							// sta			; 3
      (TemporaryBuf[4] = #9'cmp #$00') and							// cmp #$00		; 4
      ((TemporaryBuf[5] = #9'beq @+') or (TemporaryBuf[5] = #9'bne @+')) and			// beq|bne		; 5
      (pos('jmp l_', TemporaryBuf[6]) > 0) and							// sta			; 6
      (TemporaryBuf[7] = '@') then								//@			; 7
    begin
     TemporaryBuf[4] := '~';
    end;


   if (TemporaryBuf[2] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 6
      (pos('cmp ', TemporaryBuf[7]) > 0) and							// cmp			; 7
      (TemporaryBuf[8] = #9'bne @+') and							// bne @+		; 8
      (TemporaryBuf[9] = #9'dey') and								// dey			; 9
      (TemporaryBuf[10] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 10
      (pos('cmp ', TemporaryBuf[11]) > 0) and							// cmp			; 11
      (TemporaryBuf[12] = #9'bne @+') and							// bne @+		; 12
      (TemporaryBuf[13] = #9'dey') and								// dey			; 13
      (TemporaryBuf[14] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 14
      (pos('cmp ', TemporaryBuf[15]) > 0) and							// cmp			; 15
      (TemporaryBuf[16] = '@') and								//@			; 16
      ((pos('jeq ', TemporaryBuf[17]) > 0) or (pos('jne ', TemporaryBuf[17]) > 0)) and		// jeq|jne		; 17
      (SKIP(18) = false) then									//~SKIP			; 18
    begin
     TemporaryBuf[3] := '~';
    end;


   if (TemporaryBuf[2] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 6
      (pos('cmp ', TemporaryBuf[7]) > 0) and							// cmp			; 7
      (TemporaryBuf[8] = #9'bne @+') and							// bne @+		; 8
      (TemporaryBuf[9] = #9'dey') and								// dey			; 9
      (TemporaryBuf[10] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 10
      (pos('cmp ', TemporaryBuf[11]) > 0) and							// cmp			; 11
      (TemporaryBuf[12] = '@') and								//@			; 12
      ((pos('jeq ', TemporaryBuf[13]) > 0) or (pos('jne ', TemporaryBuf[13]) > 0)) and		// jeq|jne		; 13
      (SKIP(14) = false) then									//~SKIP			; 14
    begin
     TemporaryBuf[3] := '~';
    end;


   if (TemporaryBuf[2] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (TemporaryBuf[5] = #9'dey') and								// dey			; 5
      (TemporaryBuf[6] = #9'lda (:bp2),y') and							// lda (:bp2),y		; 6
      (pos('cmp ', TemporaryBuf[7]) > 0) and							// cmp			; 7
      (TemporaryBuf[8] = '@') and								//@			; 8
      ((pos('jeq ', TemporaryBuf[9]) > 0) or (pos('jne ', TemporaryBuf[9]) > 0)) and		// jeq|jne		; 9
      (SKIP(10) = false) then									//~SKIP			; 10
    begin
     TemporaryBuf[3] := '~';
    end;


   if (pos('lda ', TemporaryBuf[2]) > 0) and							// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (pos('lda ', TemporaryBuf[5]) > 0) and							// lda W		; 5
      (pos('cmp ', TemporaryBuf[6]) > 0) and							// cmp 			; 6
      (TemporaryBuf[7] = #9'bne @+') and							// bne @+		; 7
      (pos('lda ', TemporaryBuf[8]) > 0) and							// lda W		; 8
      (pos('cmp ', TemporaryBuf[9]) > 0) and							// cmp 			; 9
      (TemporaryBuf[10] = #9'bne @+') and							// bne @+		; 10
      (pos('lda ', TemporaryBuf[11]) > 0) and							// lda W		; 11
      (pos('cmp ', TemporaryBuf[12]) > 0) and							// cmp 			; 12
      (TemporaryBuf[13] = '@') and								//@			; 13
      ((pos('jeq ', TemporaryBuf[14]) > 0) or (pos('jne ', TemporaryBuf[14]) > 0)) and		// jeq|jne		; 14
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

	if (pos('jeq ', TemporaryBuf[14]) > 0) then begin
	 TemporaryBuf[13] := TemporaryBuf[14];
	 TemporaryBuf[14] := '@';
	end;

       end;

    end;


   if (pos('lda ', TemporaryBuf[2]) > 0) and							// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (pos('lda ', TemporaryBuf[5]) > 0) and							// lda W		; 5
      (TemporaryBuf[6] = #9'cmp #$00') and							// cmp #$00		; 6
      (TemporaryBuf[7] = #9'bne @+') and							// bne @+		; 7
      (pos('lda ', TemporaryBuf[8]) > 0) and							// lda W		; 8
      (TemporaryBuf[9] = #9'cmp #$00') and							// cmp #$00		; 9
      (TemporaryBuf[10] = #9'bne @+') and							// bne @+		; 10
      (pos('lda ', TemporaryBuf[11]) > 0) and							// lda W		; 11
      (TemporaryBuf[12] = #9'cmp #$00') and							// cmp #$00		; 12
      (TemporaryBuf[13] = '@') and								//@			; 13
      ((TemporaryBuf[14] = #9'beq @+') or (TemporaryBuf[14] = #9'bne @+')) and			// beq @+|bne @+	; 14
      (TemporaryBuf[15] = #9'dey') and								// dey			; 15
      (TemporaryBuf[16] = '@') and								//@			; 16
      ((TemporaryBuf[17] = #9'tya') or (pos('sty ', TemporaryBuf[17]) >0)) then			// tya|sty		; 17
    begin
     TemporaryBuf[3] := '~';

     TemporaryBuf[6] := '~';

     TemporaryBuf[9] := '~';

     TemporaryBuf[12] := '~';
    end;


    if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
       (pos('lda ', TemporaryBuf[1]) > 0) and							// lda W+1		; 1
       (TemporaryBuf[2] = #9'cmp #$00') and							// cmp #$00		; 2
       (TemporaryBuf[3] = #9'bne @+') and							// bne @+		; 3
       (pos('lda ', TemporaryBuf[4]) > 0) and							// lda W		; 4
       (pos('cmp ', TemporaryBuf[5]) > 0) and							// cmp			; 5
       (TemporaryBuf[6] = '@') and								//@			; 6
       (TemporaryBuf[7] = #9'bcs @+') and							// bcs @+		; 7
       (TemporaryBuf[8] = #9'dey') and								// dey			; 8
       (TemporaryBuf[9] = '@') and								//@			; 9
       ((TemporaryBuf[10] = #9'tya') or (pos('sty ', TemporaryBuf[10]) >0)) then		// tya|sty		; 10
      begin
       TemporaryBuf[2] := '~';

       TemporaryBuf[6] := '~';
      end;


   if (pos('lda ', TemporaryBuf[2]) > 0) and							// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (pos('lda ', TemporaryBuf[5]) > 0) and							// lda W		; 5
      (pos('cmp ', TemporaryBuf[6]) > 0) and							// cmp 			; 6
      (TemporaryBuf[7] = #9'bne @+') and							// bne @+		; 7
      (pos('lda ', TemporaryBuf[8]) > 0) and							// lda W		; 8
      (pos('cmp ', TemporaryBuf[9]) > 0) and							// cmp 			; 9
      (TemporaryBuf[10] = '@') and								//@			; 10
      ((pos('jeq ', TemporaryBuf[11]) > 0) or (pos('jne ', TemporaryBuf[11]) > 0)) and		// jeq|jne		; 11
      (SKIP(12) = false) then									//~SKIP			; 12
    begin
     TemporaryBuf[3] := '~';
    end;


   if (pos('lda ', TemporaryBuf[2]) > 0) and							// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = #9'bne @+') and							// bne @+		; 4
      (pos('lda ', TemporaryBuf[5]) > 0) and							// lda W		; 5
      (pos('cmp ', TemporaryBuf[6]) > 0) and							// cmp 			; 6
      (TemporaryBuf[7] = '@') and								//@			; 7
      ((pos('jeq ', TemporaryBuf[8]) > 0) or (pos('jne ', TemporaryBuf[8]) > 0)) and		// jeq|jne		; 8
      (SKIP(9) = false) then									//~SKIP			; 9
    begin
     TemporaryBuf[3] := '~';
    end;


   if (pos('lda ', TemporaryBuf[2]) > 0) and							// lda W		; 2
      (TemporaryBuf[3] = #9'cmp #$00') and							// cmp #$00		; 3
      (TemporaryBuf[4] = '@') and								//@			; 4
      ((pos('jeq ', TemporaryBuf[5]) > 0) or (pos('jne ', TemporaryBuf[5]) > 0)) and		// jeq|jne		; 5
      (SKIP(6) = false) then									//~SKIP			; 6
    begin
     TemporaryBuf[3] := '~';
    end;

end;	// procedure
