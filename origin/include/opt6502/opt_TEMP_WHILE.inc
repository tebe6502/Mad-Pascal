
// -----------------------------------------------------------------------------
// ===		     		      WHILE.
// -----------------------------------------------------------------------------

procedure opt_TEMP_WHILE;
var p: integer;
    tmp: string;
begin


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      sta(0) and									// sta K+1		; 0
											//			; 1
      jmp_l(3) and									// jmp l_00FA		; 3
      lab_l(4) then									//l_00FB		; 4
    begin

     for p:=5 to High(TemporaryBuf)-1 do
      if (TemporaryBuf[p] = TemporaryBuf[0]) and					// sta K+1		; p
         lab_l(p+1) and									//l_00FA		; p+1
	 (TemporaryBuf[p+1] = copy(TemporaryBuf[3], 6, 256)) then
       begin
	TemporaryBuf[p]   := TemporaryBuf[p+1];
	TemporaryBuf[p+1] := TemporaryBuf[0];

	TemporaryBuf[0] := '~';

	Break;
       end;

    end;


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      sta(0) and									// sta K		; 0
											//			; 1
      jmp_l(3) and									// jmp l_00FA		; 3
      lab_l(4) then									//l_00FB		; 4
    begin
     tmp := copy(TemporaryBuf[0], 6, 256);

     for p:=5 to High(TemporaryBuf)-6 do
      if (SKIP(p-1) = false) and							//~SKIP			; p-1
         (inc_(p) or dec_(p)) and							// inc|dec K		; p
         (TemporaryBuf[p+1] = copy(TemporaryBuf[3], 6, 256)) and			//l_00FA		; p+1
											//			; p+2
         opti(p+3) and									// optimize 		; p+3
         (tmp = copy(TemporaryBuf[p], 6, 256)) and					//			; p+4
         (TemporaryBuf[p+5] = #9'lda ' + tmp) and					// lda K		; p+5
         (TemporaryBuf[p+6] = #9'jne ' + TemporaryBuf[4]) then				// jne l_00FB		; p+6
       begin
	TemporaryBuf[p+5] := '~';
	Break;
       end;

    end;


   if (TemporaryBuf[3] = '; --- WhileProlog') and					//; --- WhileProlog	; 3
      lda_im(0) and (GetBYTE(0) < 128) and						// lda #		; 0
      sta(1) and									// sta K		; 1
      (TemporaryBuf[2] = '') and							//			; 2
      jmp_l(4) and									// jmp l_00FA		; 4
      lab_l(5) then									//l_00FB		; 5
    begin

     tmp:=copy(TemporaryBuf[4], 6, 256);

     for p:=7 to High(TemporaryBuf)-6 do
      if TemporaryBuf[p] = tmp then begin

	if (SKIP(p-2) = false) and						//~SKIP			; p-2
	   (TemporaryBuf[p-1] = #9'dec ' + copy(TemporaryBuf[1], 6, 256)) and	// dec K		; p-1
										//			; p
	   (TemporaryBuf[p+1] = '') and						//			; p+1
           opti(p+2) and							//; optimize 		; p+2
	   (TemporaryBuf[p+3] = '') and						//			; p+3
	   (TemporaryBuf[p+4] = #9'lda ' + copy(TemporaryBuf[p-1], 6, 256)) and	// lda K		; p+4
	   (TemporaryBuf[p+5] = #9'cmp #$FF') and				// cmp #$FF		; p+5
	   jne(p+6) then 							// jne			; p+6
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
      jmp_l(3) and									// jmp l_00FA		; 3
      lab_l(4) and									//l_00FB		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      opti(6) and									//; optimize 		; 6
      (TemporaryBuf[7] = '') and							//			; 7
      ldy_im(8) then									// ldy #		; 8
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
        if fail(p) then yes:=false;

     end;


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (TemporaryBuf[1] = '') and							//			; 1
      jmp_l(3) and									// jmp l_00FA		; 3
      lab_l(4) and									//l_00FB		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      opti(6) and									//; optimize 		; 6
      (TemporaryBuf[7] = '') and							//			; 7
      (ldy_im(8) = false) then								//~ldy #		; 8
    begin
      yes:=true;

      tmp:=copy(TemporaryBuf[3], 6, 256);

      for p:=8 to High(TemporaryBuf)-5 do
       if (TemporaryBuf[p-1] = #9'dec ' + copy(TemporaryBuf[p+4], 6, 256)) and
          (TemporaryBuf[p] = tmp) and						//l_00FA		; +0
          (TemporaryBuf[p+1] = '') and						//			; +1
          opti(p+2) and								//; optimize 		; +2
          (TemporaryBuf[p+3] = '') and						//			; +3
          lda(p+4) and								// lda X		; +4
          (TemporaryBuf[p+5] = #9'jne ' + TemporaryBuf[4]) then			// jne l_		; +5
	 begin

          if yes then begin
	   TemporaryBuf[1] := TemporaryBuf[p+4];

	   TemporaryBuf[p+4] := TemporaryBuf[p+5];
	   TemporaryBuf[p+5] := '~';
	  end;

	 Break;
       end else
        if fail(p) then yes:=false;

     end;

end;	// procedure
