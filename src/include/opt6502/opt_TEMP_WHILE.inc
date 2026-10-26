
// -----------------------------------------------------------------------------
// ===		     		      WHILE.
// -----------------------------------------------------------------------------

procedure opt_TEMP_WHILE;
var i, p: integer;
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
	 (TemporaryBuf[p+1] = GetARG(3)) then
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
     tmp := GetARG(0);

     for p:=5 to High(TemporaryBuf)-6 do
      if (SKIP(p-1) = false) and							//~SKIP			; p-1
         (inc_(p) or dec_(p)) and							// inc|dec K		; p
         (TemporaryBuf[p+1] = GetARG(3)) and						//l_00FA		; p+1
											//			; p+2
         opti(p+3) and									// optimize 		; p+3
         (tmp = GetARG(p)) and								//			; p+4
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

     tmp:=GetARG(4);

     for p:=7 to High(TemporaryBuf)-6 do
      if TemporaryBuf[p] = tmp then begin

	if (SKIP(p-2) = false) and						//~SKIP			; p-2
	   (TemporaryBuf[p-1] = #9'dec ' + GetARG(1)) and			// dec K		; p-1
										//			; p
	   									//			; p+1
           opti(p+2) and							//; optimize 		; p+2
	   									//			; p+3
	   (TemporaryBuf[p+4] = #9'lda ' + GetARG(p-1)) and			// lda K		; p+4
	   (TemporaryBuf[p+5] = #9'cmp #$FF') and				// cmp #$FF		; p+5
	   jne(p+6) then 							// jne			; p+6
	  begin
	   TemporaryBuf[p+4] := '~';
	   TemporaryBuf[p+5] := '~';
	   TemporaryBuf[p+6] := #9'jpl ' + GetARG(p+6);
	  end;

	Break;
      end;

    end;


   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (TemporaryBuf[1] = '') and							//			; 1
      jmp_l(3) and									// jmp l_00FA		; 3
      lab_l(4) and									//l_00FB		; 4
      											//			; 5
      opti(6) and									//; optimize 		; 6
      											//			; 7
      ldy_im(8) then									// ldy #		; 8
    begin
      yes:=true;

      tmp:=GetARG(3);

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
      											//			; 5
      opti(6) and									//; optimize 		; 6
      											//			; 7
      (ldy_im(8) = false) then								//~ldy #		; 8
    begin
      yes:=true;

      tmp:=GetARG(3);

      for p:=8 to High(TemporaryBuf)-5 do
       if (TemporaryBuf[p-1] = #9'dec ' + GetARG(p+4)) and
          (TemporaryBuf[p] = tmp) and						//l_00FA		; +0
          									//			; +1
          opti(p+2) and								//; optimize 		; +2
          									//			; +3
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



   if (TemporaryBuf[2] = '; --- WhileProlog') and					//; --- WhileProlog	; 2
      (TemporaryBuf[1] = '') and							//			; 1
      jmp_l(3) and									// jmp l_00FA		; 3
      lab_l(4) and									//l_00FB		; 4
      											//			; 5
      opti(6) then									//; optimize 		; 6
      											//			; 7
    begin
      yes:=false;

      tmp := GetARG(3);

      i:=0;

      for p:=8 to High(TemporaryBuf)-5 do
       if (TemporaryBuf[p] = tmp) then						//l_00FA		; +0
	 begin

	  if p + 32 > High(TemporaryBuf)-5 then Break;

	  for i := p + 32 downto p do
	   if (length(TemporaryBuf[i]) = 11) and (pos(TemporaryBuf[4], TemporaryBuf[i]) = 6) then begin

//writeln(TemporaryBuf[4],',',TemporaryBuf[i],',',pos(TemporaryBuf[4], TemporaryBuf[i]));


	    if opti(i-4) and					// ; optimize	; -4
	       lda(i-2) and 					// lda		; -2	*
	       cmp(i-1) then begin yes := true; Break end;	// cmp		; -1


	    if opti(i-6) and					// ; optimize	; -6
	       lda(i-4) and 					// lda		; -4
	       bne_a(i-3) and 					// bne @+	; -3
	       lda(i-2) and 					// lda		; -2	*
	       cmp(i-1) then begin yes := true; Break end; 	// cmp		; -1


	    if opti(i-6) and					// ; optimize	; -6
	       lda(i-4) and 					// lda		; -4
	       jmi(i-3) and 					// jmi		; -3
	       lda(i-2) and 					// lda		; -2	*
	       cmp(i-1) and 					// cmp		; -1
	       (argMatch(i-3, i) = false) then begin yes := true; Break end;
	    {else
	    begin

		writeln(TemporaryBuf[i-7]);
		writeln(TemporaryBuf[i-6]);
		writeln(TemporaryBuf[i-5]);
		writeln(TemporaryBuf[i-4]);
		writeln(TemporaryBuf[i-3]);
		writeln(TemporaryBuf[i-2]);
		writeln(TemporaryBuf[i-1]);
		writeln(TemporaryBuf[i]);
		writeln('----------');

	    end;
}

	    Break;
	   end;


	  if yes then begin


            if lda(8) and				// lda			; 8
	       add(9) then				// add			; 9
	      if argMatch(i-2, 9) and
	         (argMatch(i-2, 8) = false) then
	      begin

	       if jcc(i) then
	         TemporaryBuf[9] := #9'adc ' + getARG(8)
	       else
	         TemporaryBuf[9] := #9'add ' + getARG(8);

	       TemporaryBuf[8] := '~';

	       Break;
	      end;


            if ldy(8) and				// ldy			; 8
	       lda(9) and				// lda			; 9
	       add(10) then				// add			; 10
	      if argMatch(i-2, 10) and
	         (argMatch(i-2, 9) = false) then
	      begin

	       if jcc(i) then
	         TemporaryBuf[10] := #9'adc ' + getARG(9)
	       else
	         TemporaryBuf[10] := #9'add ' + getARG(9);

               TemporaryBuf[9] := TemporaryBuf[8];
	       TemporaryBuf[8] := '~';

	       Break;
	      end;
	      

	  end;


	  Break;
	 end;

     end;



end;	// procedure
