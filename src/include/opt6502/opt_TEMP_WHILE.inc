
// -----------------------------------------------------------------------------
// ===		     		      WHILE.
// -----------------------------------------------------------------------------

procedure opt_TEMP_WHILE;
var p: integer;
begin

   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (pos('sta ', TemporaryBuf[0]) > 0) and						// sta K+1		; 0
											//			; 1
      (pos('jmp l_', TemporaryBuf[3]) > 0) and						// jmp l_00FA		; 3
      (pos('l_', TemporaryBuf[4]) = 1) then						//l_00FB		; 4
    begin

     for p:=5 to High(TemporaryBuf)-1 do
      if (TemporaryBuf[p] = TemporaryBuf[0]) and					// sta K+1		; p
         (pos('l_', TemporaryBuf[p+1]) = 1) and						//l_00FA		; p+1
	 (TemporaryBuf[p+1] = copy(TemporaryBuf[3], 6, 256)) then
       begin
	TemporaryBuf[p]   := TemporaryBuf[p+1];
	TemporaryBuf[p+1] := TemporaryBuf[0];

	TemporaryBuf[0] := '~';

	Break;
       end;

    end;


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (pos('sta ', TemporaryBuf[0]) > 0) and						// sta K		; 0
											//			; 1
      (pos('jmp l_', TemporaryBuf[3]) > 0) and						// jmp l_00FA		; 3
      (pos('l_', TemporaryBuf[4]) = 1) then						//l_00FB		; 4
    begin
     tmp := copy(TemporaryBuf[0], 6, 256);

     for p:=5 to High(TemporaryBuf)-6 do
      if (SKIP(p-1) = false) and							//~SKIP			; p-1
         ((pos('inc ', TemporaryBuf[p]) > 0) or (pos('dec ', TemporaryBuf[p]) > 0)) and	// inc|dec K		; p
         (TemporaryBuf[p+1] = copy(TemporaryBuf[3], 6, 256)) and			//l_00FA		; p+1
	 										//			; p+2
         (pos('; optimize OK', TemporaryBuf[p+3]) > 0) and				// optimize OK		; p+3
         (tmp = copy(TemporaryBuf[p], 6, 256)) and					//			; p+4
         (TemporaryBuf[p+5] = #9'lda ' + tmp) and					// lda K		; p+5
         (TemporaryBuf[p+6] = #9'jne ' + TemporaryBuf[4]) then				// jne l_00FB		; p+6
       begin
	TemporaryBuf[p+5] := '~';
	Break;
       end;

    end;


   if (TemporaryBuf[3] = '; --- WhileProlog') and					//; --- WhileProlog	; 3
      (pos('lda #', TemporaryBuf[0]) > 0) and (GetBYTE(0) < 128) and			// lda #		; 0
      (pos('sta ', TemporaryBuf[1]) > 0) and						// sta K		; 1
      (TemporaryBuf[2] = '') and							//			; 2
      (pos('jmp l_', TemporaryBuf[4]) > 0) and						// jmp l_00FA		; 4
      (pos('l_', TemporaryBuf[5]) = 1) then						//l_00FB		; 5
    begin

     tmp:=copy(TemporaryBuf[4], 6, 256);

     for p:=7 to High(TemporaryBuf)-6 do
      if TemporaryBuf[p] = tmp then begin

	if (SKIP(p-2) = false) and						//~SKIP			; p-2
	   (TemporaryBuf[p-1] = #9'dec ' + copy(TemporaryBuf[1], 6, 256)) and	// dec K		; p-1
										//			; p
	   (TemporaryBuf[p+1] = '') and						//			; p+1
           (pos('; optimize OK', TemporaryBuf[p+2]) > 0) and			//; optimize OK		; p+2
	   (TemporaryBuf[p+3] = '') and						//			; p+3
	   (TemporaryBuf[p+4] = #9'lda ' + copy(TemporaryBuf[p-1], 6, 256)) and	// lda K		; p+4
	   (TemporaryBuf[p+5] = #9'cmp #$FF') and				// cmp #$FF		; p+5
	   (pos('jne ', TemporaryBuf[p+6]) > 0) then 				// jne			; p+6
	  begin
	   TemporaryBuf[p+4] := '~';
	   TemporaryBuf[p+5] := '~';
	   TemporaryBuf[p+6] := #9'jpl ' + copy(TemporaryBuf[p+6], 6, 256);
	  end;

	Break;
      end;

    end;


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('jmp l_', TemporaryBuf[3]) > 0) and						// jmp l_00FA		; 3
      (pos('l_', TemporaryBuf[4]) = 1) and						//l_00FB		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      (pos('; optimize OK', TemporaryBuf[6]) > 0) and					//; optimize OK		; 6
      (TemporaryBuf[7] = '') and							//			; 7
      (pos('ldy #', TemporaryBuf[8]) > 0) then						// ldy #		; 8
    begin
      yes:=true;

      tmp:=copy(TemporaryBuf[3], 6, 256);

      for p:=9 to High(TemporaryBuf) do
       if TemporaryBuf[p] = tmp then begin

          if yes then begin
	   TemporaryBuf[1] := TemporaryBuf[8];

	   TemporaryBuf[8] := TemporaryBuf[7];
	   TemporaryBuf[7] := TemporaryBuf[6];
	   TemporaryBuf[6] := TemporaryBuf[5];
	   TemporaryBuf[5] := TemporaryBuf[4];
	   TemporaryBuf[4] := TemporaryBuf[3];
	   TemporaryBuf[3] := TemporaryBuf[2];
	   TemporaryBuf[2] := TemporaryBuf[1];
	   TemporaryBuf[1] := '';
	  end;

	 Break;
       end else
        if (pos('ldy ', TemporaryBuf[p]) > 0) or
           (pos('mwy ', TemporaryBuf[p]) > 0) or
           (pos('mvy ', TemporaryBuf[p]) > 0) or
           (pos('jsr ', TemporaryBuf[p]) > 0) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) or
           (TemporaryBuf[p] = #9'iny') or
           (TemporaryBuf[p] = #9'dey') or
           (TemporaryBuf[p] = #9'tya') or
           (TemporaryBuf[p] = #9'tay') then yes:=false;

     end;


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('jmp l_', TemporaryBuf[3]) > 0) and						// jmp l_00FA		; 3
      (pos('l_', TemporaryBuf[4]) = 1) and						//l_00FB		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      (pos('; optimize OK', TemporaryBuf[6]) > 0) and					//; optimize OK		; 6
      (TemporaryBuf[7] = '') and							//			; 7
      (pos('ldy #', TemporaryBuf[8]) = 0) then						//~ldy #		; 8
    begin
      yes:=true;

      tmp:=copy(TemporaryBuf[3], 6, 256);

      for p:=8 to High(TemporaryBuf)-5 do
       if (TemporaryBuf[p-1] = #9'dec ' + copy(TemporaryBuf[p+4], 6, 256)) and
          (TemporaryBuf[p] = tmp) and				//l_00FA		; +0
          (TemporaryBuf[p+1] = '') and				//			; +1
          (pos('; optimize OK', TemporaryBuf[p+2]) > 0) and	//; optimize OK		; +2
          (TemporaryBuf[p+3] = '') and				//			; +3
          (pos('lda ', TemporaryBuf[p+4]) > 0) and		// lda X		; +4
          (TemporaryBuf[p+5] = #9'jne ' + TemporaryBuf[4]) then	// jne l_		; +5
	 begin

          if yes then begin
	   TemporaryBuf[1] := TemporaryBuf[p+4];

	   TemporaryBuf[p+4] := TemporaryBuf[p+5];
	   TemporaryBuf[p+5] := '~';
	  end;

	 Break;
       end else
        if (pos('ldy ', TemporaryBuf[p]) > 0) or
           (pos('mwy ', TemporaryBuf[p]) > 0) or
           (pos('mvy ', TemporaryBuf[p]) > 0) or
           (pos('jsr ', TemporaryBuf[p]) > 0) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) or
           (TemporaryBuf[p] = #9'iny') or
           (TemporaryBuf[p] = #9'dey') or
           (TemporaryBuf[p] = #9'tya') or
           (TemporaryBuf[p] = #9'tay') then yes:=false;

     end;

end;	// procedure
