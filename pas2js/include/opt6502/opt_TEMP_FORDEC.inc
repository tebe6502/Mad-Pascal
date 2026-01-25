// -----------------------------------------------------------------------------
//				     FORDEC.
// -----------------------------------------------------------------------------

procedure opt_TEMP_FORDEC;
var p: integer;
    arg: string;
begin

   if (TemporaryBuf[5] = #9'#for') and							// #for				; 5	for i:=N downto 0
      (pos('#for:dec', TemporaryBuf[4]) > 0) and					// #for:dec I			; 4

      (sta(0) or sty(0) or (pos('stz ', TemporaryBuf[0]) > 0)) and			// sta|sty|stz I		; 0
      (TemporaryBuf[1] = '') and							//				; 1
      lab_l(2) and									//l_00FB			; 2
      (TemporaryBuf[3] = '; --- ForToDoCondition') then					//; --- ForToDoCondition	; 3
    begin

     yes:=true;

     arg:=copy(TemporaryBuf[0], 6, 256);


     for p:=6 to High(TemporaryBuf) do
      if pos(TemporaryBuf[2], TemporaryBuf[p]) > 0 then begin

        if (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) and			//; --- ForToDoEpilog	// p-5
	   (TemporaryBuf[p-5] = '; --- ForToDoEpilog') and			// dec I		// p-4
	   (pos('dec ', TemporaryBuf[p-4]) > 0) and				// lda I		// p-3
	   (TemporaryBuf[p-1] = #9'seq') and					// cmp #$FF		// p-2
	   (TemporaryBuf[p-2] = #9'cmp #$FF') then				// seq			// p-1
	   begin								// jmp l_00FB		// p
 	    TemporaryBuf[4] := TemporaryBuf[p-4];

	    TemporaryBuf[p-4] := '~';

	    TemporaryBuf[p-2] := '~';
	    TemporaryBuf[p-1] := '~';

     	    TemporaryBuf[p] := #9'jne ' + TemporaryBuf[2];

	    TemporaryBuf[1] := #9'jmp ' + TemporaryBuf[2] + 'f';

	    TemporaryBuf[5] := TemporaryBuf[2] + 'f';

	    yes:=false;
	   end;

	Break;
       end;


     if yes then begin
      TemporaryBuf[4] := '~';
      TemporaryBuf[5] := '~';
     end;


     if yes and (TemporaryBuf[6] = #9'ldy ' + arg) and (TemporaryBuf[7] = #9'lda ' + arg) then
      for p:=8 to High(TemporaryBuf) do
       if pos(TemporaryBuf[2], TemporaryBuf[p]) > 0 then begin

        if yes and
	   (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) and			// jmp l_00FB		// p
	   (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and			// ; --- ForToDoEpilog	// p-3
	   (TemporaryBuf[p-2] = #9'dec ' + arg) and	// dec I		// p-2
	   (TemporaryBuf[p-1] = #9'bmi *+5') and				// bmi *+5		// p-1
           lab_l(p+1) then							//l_			// p+1
	  begin
	   TemporaryBuf[p-2] := #9'dey';
	   TemporaryBuf[p-1] := #9'jpl ' + copy(TemporaryBuf[p], 6, 256);

  	   if lab_b(p+2) then begin
	    TemporaryBuf[p] := '~';//TemporaryBuf[p+1];
	    TemporaryBuf[p+1] := TemporaryBuf[p+2];
	    TemporaryBuf[p+2] := #9'sty ' + arg;
	   end else begin
	    TemporaryBuf[p] := '~';//TemporaryBuf[p+1];
	    TemporaryBuf[p+1] := #9'sty ' + arg;
	   end;

	   TemporaryBuf[0] := #9'tay';

	   TemporaryBuf[6] := '~';
	   TemporaryBuf[7] := #9'tya';

	   yes:=false;
	  end;

	 Break;
       end else
        if ( (p-3 >= 8) and (copy(TemporaryBuf[p-3], 6, 256) = arg) ) or fail(p) then yes:=false;
{
	   ldy(p) or
	   jsr(p) or
           iny(p) or
           dey(p) or
           tay(p) or
	   mwy(p) or
	   mvy(p) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) then yes:=false;
}

     if yes and (TemporaryBuf[6] = #9'ldy ' + arg) then
      for p:=7 to High(TemporaryBuf) do
       if pos(TemporaryBuf[2], TemporaryBuf[p]) > 0 then begin

        if yes and
	   (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) and			// jmp l_00FB		// p
	   (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and			// ; --- ForToDoEpilog	// p-3
	   (TemporaryBuf[p-2] = #9'dec ' + arg) and	// dec I		// p-2
	   (TemporaryBuf[p-1] = #9'bmi *+5') and				// bmi *+5		// p-1
           lab_l(p+1) then							//l_			// p+1
	  begin
	   TemporaryBuf[p-2] := #9'dey';
	   TemporaryBuf[p-1] := #9'jpl ' + copy(TemporaryBuf[p], 6, 256);

  	   if lab_b(p+2) then begin
	    TemporaryBuf[p] := '~';//TemporaryBuf[p+1];
	    TemporaryBuf[p+1] := TemporaryBuf[p+2];
	    TemporaryBuf[p+2] := #9'sty ' + arg;
	   end else begin
	    TemporaryBuf[p] := '~';//TemporaryBuf[p+1];
	    TemporaryBuf[p+1] := #9'sty ' + arg;
	   end;

	   TemporaryBuf[0] := #9'tay';

	   TemporaryBuf[6] := '~';
	   yes:=false;
	  end;

	 Break;
       end else
        if ( (p-3 >= 7) and (copy(TemporaryBuf[p-3], 6, 256) = arg) ) or fail(p) then yes:=false;
{
	   ldy(p) or
	   jsr(p) or
           iny(p) or
           dey(p) or
           tay(p) or
	   mwy(p) or
	   mvy(p) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) then yes:=false;
}

     if yes and (TemporaryBuf[8] = #9'ldy ' + arg) then
      for p:=9 to High(TemporaryBuf) do
       if pos(TemporaryBuf[2], TemporaryBuf[p]) > 0 then begin

        if yes and
           lda(6) and									// lda		; 6
           ((pos('and #', TemporaryBuf[7]) > 0) or					// and		; 7
            (pos('ora #', TemporaryBuf[7]) > 0) or					// ora
            (pos('eor #', TemporaryBuf[7]) > 0)) and					// eor

	   (TemporaryBuf[p] = #9'jmp ' + TemporaryBuf[2]) and			// jmp l_00FB		// p
	   (TemporaryBuf[p-3] = '; --- ForToDoEpilog') and			// ; --- ForToDoEpilog	// p-3
	   (TemporaryBuf[p-2] = #9'dec ' + arg) and	// dec I		// p-2
	   (TemporaryBuf[p-1] = #9'bmi *+5') and				// bmi *+5		// p-1
           lab_l(p+1) then							//l_			// p+1
	  begin
	   TemporaryBuf[p-2] := #9'dey';
	   TemporaryBuf[p-1] := #9'jpl ' + copy(TemporaryBuf[p], 6, 256);

  	   if lab_b(p+2) then begin
	    TemporaryBuf[p] := '~';//TemporaryBuf[p+1];
	    TemporaryBuf[p+1] := TemporaryBuf[p+2];
	    TemporaryBuf[p+2] := #9'sty ' + arg;
	   end else begin
	    TemporaryBuf[p] := '~';//TemporaryBuf[p+1];
	    TemporaryBuf[p+1] := #9'sty ' + arg;
	   end;

	   if copy(TemporaryBuf[6], 6, 256) = arg then TemporaryBuf[6] := #9'tya';

	   TemporaryBuf[0] := #9'tay';

	   TemporaryBuf[8] := '~';
	   yes:=false;
	  end;

	 Break;
       end else
        if ( (p-3 >= 9) and (copy(TemporaryBuf[p-3], 6, 256) = arg) ) or fail(p) then yes:=false;
{
	   ldy(p) or
	   jsr(p) or
           iny(p) or
           dey(p) or
           tay(p) or
	   mwy(p) or
	   mvy(p) or
           (pos(#9'.if', TemporaryBuf[p]) > 0) or
           (pos(#9'.LOCAL ', TemporaryBuf[p]) > 0) or
           (pos(#9'@print', TemporaryBuf[p]) > 0) then yes:=false;
}
    end;

end;	// procedure