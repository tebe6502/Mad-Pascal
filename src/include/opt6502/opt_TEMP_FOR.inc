
// -----------------------------------------------------------------------------
//				     FOR.
// -----------------------------------------------------------------------------

procedure opt_TEMP_FOR;
var p: integer;
begin


    if //(TemporaryBuf[0] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 0
       inc_(1) and 									// inc W		; 1
       (TemporaryBuf[2] = #9'sne') and							// sne			; 2
       inc_(3) and									// inc W+1		; 3
       (TemporaryBuf[4] = #9'seq') and							// seq			; 4
       jmp(5) and									// jmp l_xxxx		; 5
       lab_l(6) then									//l_yyyy		; 6
     if (pos(TemporaryBuf[1], TemporaryBuf[3]) > 0) then
      begin
	TemporaryBuf[2] := #9'jne ' + copy(TemporaryBuf[5], 6, 256);
	TemporaryBuf[5] := #9'jne ' + copy(TemporaryBuf[5], 6, 256);

	TemporaryBuf[4] := '~';
      end;


    if //(TemporaryBuf[0] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 0
       dec_(1) and 									// dec W		; 1
       lda(2) and 									// lda W		; 2
       (TemporaryBuf[3] = #9'cmp #$FF') and						// cmp #$FF		; 3
       (TemporaryBuf[4] = #9'seq') and							// seq			; 4
       jmp(5) and									// jmp l_xxxx		; 5
       lab_l(6) then									//l_yyyy		; 6
     if (copy(TemporaryBuf[1], 6, 256) = copy(TemporaryBuf[2], 6, 256)) then
      begin
	TemporaryBuf[3] := TemporaryBuf[1];

	TemporaryBuf[1] := TemporaryBuf[2];
	TemporaryBuf[2] := #9'beq ' + TemporaryBuf[6];

 	TemporaryBuf[4] := '~';
      end;


    if //(TemporaryBuf[0] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 0
       lda(1) and 									// lda W		; 1
       (TemporaryBuf[2] = #9'bne @+') and 						// bne @+		; 2
       dec_(3) and 									// dec W+1		; 3
       (TemporaryBuf[4] = '@') and							//@			; 4
       dec_(5) and 									// dec W		; 5
       lda(6) and 									// lda W+1		; 6
       (TemporaryBuf[7] = #9'cmp #$FF') and						// cmp #$FF		; 7
       (TemporaryBuf[8] = #9'seq') and							// seq			; 8
       jmp(9) and									// jmp l_xxxx		; 9
       lab_l(10) then									//l_yyyy		; 10
     if (copy(TemporaryBuf[3], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then
      begin
	TemporaryBuf[7] := TemporaryBuf[5];

	TemporaryBuf[5] := TemporaryBuf[3];

	TemporaryBuf[3] := TemporaryBuf[6];
	TemporaryBuf[4] := #9'beq ' + TemporaryBuf[10];

	TemporaryBuf[6] := '@';

 	TemporaryBuf[8] := '~';
      end;


   if lda(0) and									// lda			; 0
      sta(1) and									// sta C		; 1
      (TemporaryBuf[2] = '') and							//			; 2
      lab_l(3) and									//l_2092		; 3
      (TemporaryBuf[4] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 4
      ldy(5) and									// ldy C		; 5
      lda(6) and									// lda 			; 6
      sta(7) and									// sta ( ),y		; 7
											//			; 8
      (TemporaryBuf[9] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 9
      inc_(10) and									// inc C 		; 10
      (TemporaryBuf[11] = #9'seq') and							// seq 			; 11
      (TemporaryBuf[12] = #9'jmp ' + TemporaryBuf[3]) and				// jmp l_2092		; 12
      lab_l(13) then									//l_			; 13
    if (copy(TemporaryBuf[1], 6, 256) = copy(TemporaryBuf[5], 6, 256)) and
       (copy(TemporaryBuf[5], 6, 256) = copy(TemporaryBuf[10], 6, 256)) then
     begin
	TemporaryBuf[0] := #9'ldy ' + copy(TemporaryBuf[0], 6, 256);
	TemporaryBuf[1] := '~';

	if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then
	 TemporaryBuf[1] := #9'tya'
	else
	 TemporaryBuf[1] := TemporaryBuf[6];

	TemporaryBuf[10] := #9'iny';
	TemporaryBuf[11] := #9'jne ' + copy(TemporaryBuf[12], 6, 256);
	TemporaryBuf[12] := TemporaryBuf[13];

	if lab_b(14) then begin
	 TemporaryBuf[13] := TemporaryBuf[14];
	 TemporaryBuf[14] := #9'sty ' + copy(TemporaryBuf[5], 6, 256);
	end else
	 TemporaryBuf[13] := #9'sty ' + copy(TemporaryBuf[5], 6, 256);

	if (copy(TemporaryBuf[5], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then begin
	 TemporaryBuf[5] := #9'tya';
	 TemporaryBuf[1] := '~';
	end else
	 TemporaryBuf[5] := '~';

	TemporaryBuf[6] := '~';
     end;


   if sta(0) and									// sta C		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      lab_l(2) and									//l_2092		; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 3
      ldy(4) and									// ldy C		; 4
      lda(5) and									// lda Result		; 5
      add_sub(6) and									// add|sub		; 6
      sta(7) and									// sta Result		; 7
      ((TemporaryBuf[8] = #9'scc') or (TemporaryBuf[8] = #9'scs')) and			// scc|scs		; 8
      (inc_(9) or dec_(9)) and								// inc|dec Result+1	; 9
											//			; 10
      (TemporaryBuf[11] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 11
      inc_(12) and									// inc C 		; 12
      (TemporaryBuf[13] = #9'seq') and							// seq 			; 13
      (TemporaryBuf[14] = #9'jmp ' + TemporaryBuf[2]) and				// jmp l_2092		; 14
      lab_l(15) then									//l_			; 15
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) and
       (copy(TemporaryBuf[4], 6, 256) = copy(TemporaryBuf[12], 6, 256)) then
     begin
	TemporaryBuf[0] := #9'tay';

	TemporaryBuf[12] := #9'iny';
	TemporaryBuf[13] := #9'jne ' + copy(TemporaryBuf[14], 6, 256);
	TemporaryBuf[14] := TemporaryBuf[15];

	if lab_b(16) then begin
	 TemporaryBuf[15] := TemporaryBuf[16];
	 TemporaryBuf[16] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);
	end else
	 TemporaryBuf[15] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);

	TemporaryBuf[4] := TemporaryBuf[5];
	TemporaryBuf[5] := TemporaryBuf[6];
	TemporaryBuf[6] := TemporaryBuf[7];
	TemporaryBuf[7] := TemporaryBuf[8];
	TemporaryBuf[8] := TemporaryBuf[9];
	TemporaryBuf[9] := TemporaryBuf[10];
	TemporaryBuf[10] := TemporaryBuf[11];
	TemporaryBuf[11] := TemporaryBuf[12];
	TemporaryBuf[12] := TemporaryBuf[13];
	TemporaryBuf[13] := TemporaryBuf[14];
	TemporaryBuf[14] := TemporaryBuf[15];
	TemporaryBuf[15] := TemporaryBuf[16];

        if copy(TemporaryBuf[4], 6, 256) = copy(TemporaryBuf[6], 6, 256) then begin
	TemporaryBuf[1] := TemporaryBuf[4];

	TemporaryBuf[15] := TemporaryBuf[6];

	TemporaryBuf[4] := '~';

	TemporaryBuf[6] := '~';
        end;

     end;


   if sta(0) and									// sta C		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      lab_l(2) and									//l_2092		; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 3
      ldy(4) and									// ldy C		; 4
      lda(5) and									// lda			; 5
      add_sub(6) and									// add|sub		; 6
      (TemporaryBuf[7] = #9'sta :bp+1') and						// sta :bp+1		; 7
      lda(8) and									// lda			; 8
      (TemporaryBuf[9] = #9'sta (:bp),y') and						// sta (:bp),y		; 9
											//			; 10
      (TemporaryBuf[11] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 11
      inc_(12) and									// inc C 		; 12
      (TemporaryBuf[13] = #9'seq') and							// seq 			; 13
      (TemporaryBuf[14] = #9'jmp ' + TemporaryBuf[2]) and				// jmp l_2092		; 14
      lab_l(15) then									//l_			; 15
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) and
       (copy(TemporaryBuf[4], 6, 256) = copy(TemporaryBuf[12], 6, 256)) then
     begin
	TemporaryBuf[0] := #9'tay';

	TemporaryBuf[12] := #9'iny';
	TemporaryBuf[13] := #9'jne ' + copy(TemporaryBuf[14], 6, 256);
	TemporaryBuf[14] := TemporaryBuf[15];

	if lab_b(16) then begin
	 TemporaryBuf[15] := TemporaryBuf[16];
	 TemporaryBuf[16] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);
	end else
	 TemporaryBuf[15] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);

	TemporaryBuf[4] := '~';
     end;


   if (TemporaryBuf[0] = '') and							//			; 0
      lab_l(1) and									//l_2092		; 1
      (TemporaryBuf[2] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 2
      (TemporaryBuf[3] = #9'ldy #$00') and						// ldy #$00		; 3
      lda(4) and									// lda Result		; 4
      add_sub(5) and									// add|sub (P),y	; 5
      sta(6) and									// sta Result		; 6
      ((TemporaryBuf[7] = #9'scc') or (TemporaryBuf[7] = #9'scs')) and			// scc|scs		; 7
      (inc_(8) or dec_(8)) and								// inc|dec Result+1	; 8
											//			; 9
      (TemporaryBuf[10] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 10
      inc_(11) and									// inc P 		; 11
      (TemporaryBuf[12] = #9'sne') and							// sne 			; 12
      inc_(13) and									// inc P+1 		; 13
      (TemporaryBuf[14] = #9'seq') and							// seq 			; 14
      (TemporaryBuf[15] = #9'jmp ' + TemporaryBuf[1]) and				// jmp l_2092		; 15
      lab_l(16) then									//l_			; 16
    if (copy(TemporaryBuf[5], 6, 256) = '('+copy(TemporaryBuf[11], 6, 256)+'),y') then
     begin
	TemporaryBuf[3] := TemporaryBuf[2];
	TemporaryBuf[2] := TemporaryBuf[1];
	TemporaryBuf[1] := #9'ldy #$00';

	TemporaryBuf[12] := #9'jne ' + copy(TemporaryBuf[15], 6, 256);

	TemporaryBuf[14] := #9'jne ' + copy(TemporaryBuf[15], 6, 256);
	TemporaryBuf[15] := TemporaryBuf[16];

	if lab_b(17) then begin
	 TemporaryBuf[16] := TemporaryBuf[17];
	 TemporaryBuf[17] := #9'sty ' + copy(TemporaryBuf[11], 6, 256);
	end else
	 TemporaryBuf[16] := #9'sty ' + copy(TemporaryBuf[11], 6, 256);

	TemporaryBuf[11] := #9'iny';

        if copy(TemporaryBuf[4], 6, 256) = copy(TemporaryBuf[6], 6, 256) then begin
	 TemporaryBuf[0] := TemporaryBuf[4];

	 TemporaryBuf[4] := TemporaryBuf[5];
	 TemporaryBuf[5] := TemporaryBuf[6];
	 TemporaryBuf[6] := TemporaryBuf[7];
	 TemporaryBuf[7] := TemporaryBuf[8];
	 TemporaryBuf[8] := TemporaryBuf[9];
	 TemporaryBuf[9] := TemporaryBuf[10];
	 TemporaryBuf[10] := TemporaryBuf[11];
	 TemporaryBuf[11] := TemporaryBuf[12];
	 TemporaryBuf[12] := TemporaryBuf[13];
	 TemporaryBuf[13] := TemporaryBuf[14];
	 TemporaryBuf[14] := TemporaryBuf[15];
	 TemporaryBuf[15] := TemporaryBuf[16];
	 TemporaryBuf[16] := TemporaryBuf[17];
	 TemporaryBuf[17] := TemporaryBuf[18];
        end;

     end;


   if sta(0) and									// sta C		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      lab_l(2) and									//l_2092		; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 3
      lda(4) and									// lda C		; 4
      cmp(5) and									// cmp 			; 5
      SKIP(6) and									// SKIP			; 6
      ldy(7) and									// ldy C		; 7
      lda(8) and									// lda 			; 8
      sta(9) and									// sta 			; 9
											//			; 10
      (TemporaryBuf[11] = '; --- ForToDoEpilog') and					//; --- ForToDoEpilog	; 11
      inc_(12) and									// inc C 		; 12
      (TemporaryBuf[13] = #9'seq') and							// seq 			; 13
      (TemporaryBuf[14] = #9'jmp ' + TemporaryBuf[2]) and				// jmp l_2092		; 14
      lab_l(15) then									//l_			; 15
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) and
       (copy(TemporaryBuf[4], 6, 256) = copy(TemporaryBuf[7], 6, 256)) and
       (copy(TemporaryBuf[7], 6, 256) = copy(TemporaryBuf[12], 6, 256)) then
     begin
	TemporaryBuf[0] := #9'tay';

	TemporaryBuf[4] := '~';
	TemporaryBuf[5] := #9'cpy ' + copy(TemporaryBuf[5], 6, 256);

	TemporaryBuf[12] := #9'iny';
	TemporaryBuf[13] := #9'jne ' + copy(TemporaryBuf[14], 6, 256);
	TemporaryBuf[14] := TemporaryBuf[15];

	if lab_b(16) then begin
	 TemporaryBuf[15] := TemporaryBuf[16];
	 TemporaryBuf[16] := #9'sty ' + copy(TemporaryBuf[7], 6, 256);
	end else
	 TemporaryBuf[15] := #9'sty ' + copy(TemporaryBuf[7], 6, 256);

	TemporaryBuf[7] := '~';
     end;


   if sta(0) and									// sta C		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      lab_l(2) and									//l_2092		; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 3
      lda(4) and									// lda C		; 4
      cmp(5) and									// cmp 			; 5
      SKIP(6) and									// SKIP			; 6
      (TemporaryBuf[7] = '') and							//			; 7
      (pos('; optimize ', TemporaryBuf[8]) > 0) and					//; optimize 		; 8
      (TemporaryBuf[9] = '') and							//			; 9
      lda(10) then									// lda			; 10
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
     begin

      for p:=11 to High(TemporaryBuf) do
       if (pos(TemporaryBuf[2], TemporaryBuf[p]) > 0) then begin

         if (TemporaryBuf[p-6] = #9'ldy ' + copy(TemporaryBuf[4], 6, 256)) and	// ldy C
            sta(p-5) and							// sta
            (TemporaryBuf[p-4] = '') and					//
   	    (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and			//; --- ForToDoEpilog
            (TemporaryBuf[p-2] = #9'inc ' + copy(TemporaryBuf[4], 6, 256)) and	// inc C
            (TemporaryBuf[p-1] = #9'seq') and					// seq
            (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) then			// jmp l_2092
	  begin
	   TemporaryBuf[0] := #9'tay';

	   TemporaryBuf[4] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);
	   TemporaryBuf[5] := #9'cpy ' + copy(TemporaryBuf[5], 6, 256);

	   TemporaryBuf[p-2] := #9'iny';
	   TemporaryBuf[p-1] := #9'jne ' + copy(TemporaryBuf[p], 6, 256);
	   TemporaryBuf[p]   := '~';
	  end;

	 Break;
       end;
     end;


   if sta(0) and									// sta C		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      lab_l(2) and									//l_2092		; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 3
      lda(4) and									// lda C		; 4
      cmp(5) and									// cmp 			; 5
      SKIP(6) and									// SKIP			; 6
      (TemporaryBuf[7] = '') and							//			; 7
      (pos('; optimize ', TemporaryBuf[8]) > 0) and					//; optimize 		; 8
      (TemporaryBuf[9] = '') and							//			; 9
      (TemporaryBuf[10] = #9'ldy ' + copy(TemporaryBuf[4], 6, 256)) then		// ldy C		; 10
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
     begin

      yes:=true;

      for p:=11 to High(TemporaryBuf) do
       if (pos(TemporaryBuf[2], TemporaryBuf[p]) > 0) then begin

         if yes and
	    (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and			//; --- ForToDoEpilog
            (TemporaryBuf[p-2] = #9'inc ' + copy(TemporaryBuf[4], 6, 256)) and	// inc C
            (TemporaryBuf[p-1] = #9'seq') and					// seq
            (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) and			// jmp l_2092
            (TemporaryBuf[p+1] = copy(TemporaryBuf[6], 6, 256)) then		//l_
	  begin
	   TemporaryBuf[0] := #9'tay';

	   if sta(11) then
	    TemporaryBuf[4] := #9'tya'
	   else begin
	    TemporaryBuf[4] := '~';
	    TemporaryBuf[5] := #9'cpy ' + copy(TemporaryBuf[5], 6, 256);
	   end;

	   TemporaryBuf[p-2] := #9'iny';
	   TemporaryBuf[p-1] := #9'jne ' + copy(TemporaryBuf[p], 6, 256);
	   TemporaryBuf[p]   := TemporaryBuf[p+1];

  	   if lab_b(p+2) then begin
	    TemporaryBuf[p+1] := TemporaryBuf[p+2];
	    TemporaryBuf[p+2] := #9'sty ' + copy(TemporaryBuf[10], 6, 256);
	   end else
	    TemporaryBuf[p+1] := #9'sty ' + copy(TemporaryBuf[10], 6, 256);

	   TemporaryBuf[10]  := '~';
	  end;

	 Break;
       end else
        if fail(p) or
           (TemporaryBuf[p] = #9'lda ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'add ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'sub ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'adc ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'sbc ' + copy(TemporaryBuf[4], 6, 256)) then yes:=false;

     end;


   if sta(0) and									// sta C		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      lab_l(2) and									//l_2092		; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 3
      (TemporaryBuf[4] = #9'ldy ' + copy(TemporaryBuf[0], 6, 256)) then			// ldy C		; 4
     begin

      yes:=true;

      for p:=5 to High(TemporaryBuf) do
       if (pos(TemporaryBuf[2], TemporaryBuf[p]) > 0) then begin

         if yes and
	    (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and			//; --- ForToDoEpilog
            (TemporaryBuf[p-2] = #9'inc ' + copy(TemporaryBuf[4], 6, 256)) and	// inc C
            (TemporaryBuf[p-1] = #9'seq') and					// seq
            (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) and			// jmp l_2092
            lab_l(p+1) then				//l_
	  begin
	   TemporaryBuf[0] := #9'tay';

	   TemporaryBuf[p-2] := #9'iny';
	   TemporaryBuf[p-1] := #9'jne ' + copy(TemporaryBuf[p], 6, 256);
	   TemporaryBuf[p]   := TemporaryBuf[p+1];

  	   if lab_b(p+2) then begin
	    TemporaryBuf[p+1] := TemporaryBuf[p+2];
	    TemporaryBuf[p+2] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);
	   end else
	    TemporaryBuf[p+1] := #9'sty ' + copy(TemporaryBuf[4], 6, 256);

	   TemporaryBuf[4]  := '~';
	  end;

	 Break;
       end else
        if fail(p) or
           (TemporaryBuf[p] = #9'lda ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'add ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'sub ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'adc ' + copy(TemporaryBuf[4], 6, 256)) or
           (TemporaryBuf[p] = #9'sbc ' + copy(TemporaryBuf[4], 6, 256)) then yes:=false;

     end;


   if lab_l(0) and									//l_2092		; 0
      (TemporaryBuf[1] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 1
      (lda(2) = false) and								// lda C		; 2
      (cmp(3) = false) then								// cmp 			; 3
     begin

      for p:=2 to High(TemporaryBuf) do
       if (pos(TemporaryBuf[0], TemporaryBuf[p]) > 0) then begin

	  if (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[0]) and
	     (TemporaryBuf[p-1] = #9'bmi *+5') and
	     dec_(p-2) and
	     (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and
	     (TemporaryBuf[p-4] = '') and
	     (inc_(p-5) or dec_(p-5)) and
	     ((TemporaryBuf[p-6] = #9'scc') or (TemporaryBuf[p-6] = #9'scs')) and
	     sta(p-7) and

	     (TemporaryBuf[p+2] = '') and
	     (pos('; optimize ', TemporaryBuf[p+3]) > 0) and
	     (TemporaryBuf[p+4] = '') and
	     lda(p+5) and
	     add_sub(p+6) and

	     (copy(TemporaryBuf[p+5], 6, 256) = copy(TemporaryBuf[p-7], 6, 256)) then
	   begin
	     TemporaryBuf[p+5] := '~';
	   end;

	 Break;
       end;

     end;


   if lab_l(0) and									//l_2092		; 0
      (TemporaryBuf[1] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 1
      lda(2) and (iy(2) = false) and							// lda C		; 2
      (TemporaryBuf[3] = #9'cmp #$40') and						// cmp #$40		; 3
      jcs_l(4) and									// jcs l_		; 4
      lda(5) then									// lda			; 5
     begin
      TemporaryBuf[2] := #9'bit ' + copy(TemporaryBuf[2], 6, 256);
      TemporaryBuf[3] := '~';
      TemporaryBuf[4] := #9'jvs ' + copy(TemporaryBuf[4], 6, 256);
     end;


   if lab_l(0) and									//l_2092		; 0
      (TemporaryBuf[1] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 1
      lda(2) and (iy(2) = false) and							// lda C		; 2
      (TemporaryBuf[3] = #9'cmp #$40') and						// cmp #$40		; 3
      jcs_l(4) and									// jcs l_		; 4
      (TemporaryBuf[5] ='') and								//			; 5
      (pos('; optimize ', TemporaryBuf[6]) > 0) and					//; optimize		; 6
      (TemporaryBuf[7] ='') and								//			; 7
      lda(8) then									// lda			; 8
     begin
      TemporaryBuf[2] := #9'bit ' + copy(TemporaryBuf[2], 6, 256);
      TemporaryBuf[3] := '~';
      TemporaryBuf[4] := #9'jvs ' + copy(TemporaryBuf[4], 6, 256);
     end;


   if lab_l(0) and									//l_2092		; 0
      (TemporaryBuf[1] = '; --- ForToDoCondition') and					//; --- ForToDoCondition; 1
      lda(2) and									// lda			; 2
      cmp(3) and									// cmp			; 3
      (TemporaryBuf[4] = #9'bcc @+') and						// bcc @+		; 4
      jne_l(5) and									// jne l_		; 5
      lda(6) and									// lda			; 6
      cmp(7) and									// cmp			; 7
      (TemporaryBuf[8] = #9'bcc @+') and						// bcc @+		; 8
      jne_l(9) and									// jne l_		; 9
      (TemporaryBuf[10] = '@') and							//@			; 10
      (TemporaryBuf[11] ='') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize		; 12
      (TemporaryBuf[13] ='') and							//			; 13
      lda(14) and									// lda			; 14
      add(15) then									// add			; 15
     begin
      TemporaryBuf[10] := #9'clc';
      TemporaryBuf[11] := '@';

      TemporaryBuf[15] := #9'adc ' + copy(TemporaryBuf[15], 6, 256);
     end;


end;	// procedure
