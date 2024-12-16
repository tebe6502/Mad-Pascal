
// -----------------------------------------------------------------------------
// ===				      JMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_JMP;
var p: integer;
begin


   if (pos('sta ', TemporaryBuf[0]) > 0) and						// sta A		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('jmp l_', TemporaryBuf[2]) > 0) and						// jmp l_xxxx		; 2
      (pos('l_', TemporaryBuf[3]) = 1) and						//l_xxxx		; 3
      (TemporaryBuf[4] = '') and							//			; 4
      (pos('; optimize ', TemporaryBuf[5]) > 0) and					//; optimize 		; 5
      (TemporaryBuf[6] = '') and							//			; 6
      (pos('lda ', TemporaryBuf[7]) > 0) then						// lda A		; 7
    if (TemporaryBuf[3] = copy(TemporaryBuf[2], 6, 256)) and
       (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[7], 6, 256)) then
    begin
     TemporaryBuf[2] := '~';
     TemporaryBuf[3] := '~';

     TemporaryBuf[7] := '~';
    end;


    if (pos('jne l_', TemporaryBuf[0]) > 0) and						// jne l_xxxx		; 0
       (TemporaryBuf[1] = #9'jmp @exit') and						// jmp @exit		; 1
       (pos(TemporaryBuf[2], TemporaryBuf[0]) > 0) and					//l_xxxx		; 2
       (pos('lda IFTMP_', TemporaryBuf[3]) = 0) then					//~lda IFTMP_		; 3
     begin
      TemporaryBuf[0] := #9'jeq @exit';
      TemporaryBuf[1] := '~';
     end;


    if (pos('lda #$', TemporaryBuf[0]) > 0) and (TemporaryBuf[0] <> #9'lda #$00') and	// lda #$01		; 0
       (pos('jeq l_', TemporaryBuf[1]) > 0) and						// jeq l_xxxx		; 1
       (pos('jmp l_', TemporaryBuf[2]) > 0) and						// jmp l_yyyy		; 2
       (pos(TemporaryBuf[3], TemporaryBuf[1]) > 0) then					//l_xxxx		; 3
     begin
      TemporaryBuf[0] := '~';
      TemporaryBuf[1] := '~';
      TemporaryBuf[3] := '~';
     end;


    if (TemporaryBuf[0] = #9'jmp @exit') and						// jmp @exit		; 0
       (TemporaryBuf[1] = '@exit') then							//@exit			; 1
     begin
      TemporaryBuf[0] := '~';
     end;


    if (TemporaryBuf[0] = #9'jmp @+') and						// jmp @+		; 0
       (pos('jmp l_', TemporaryBuf[1]) > 0) and						// jmp l_		; 1
       (TemporaryBuf[2] = '@') then							//@			; 2
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       (pos('jmp l_', TemporaryBuf[1]) > 0) and						// jmp l_xxxx		; 1
       (TemporaryBuf[2] = copy(TemporaryBuf[1], 6, 256)) and				//l_xxxx		; 2
       (pos('lda IFTMP_', TemporaryBuf[3]) = 0) then					//~lda IFTMP_		; 3
     begin
      TemporaryBuf[1] := '~';
      TemporaryBuf[2] := '~';
     end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       (pos('jmp l_', TemporaryBuf[1]) > 0) and						// jmp l_xxxx		; 1
       (pos('l_', TemporaryBuf[2]) = 1) and						//l_yyyy		; 2
       (TemporaryBuf[3] = copy(TemporaryBuf[1], 6, 256)) and				//l_xxxx		; 3
       (pos('lda IFTMP_', TemporaryBuf[4]) = 0) then					//~lda IFTMP_		; 4
      begin
	TemporaryBuf[1] := '~';

	TemporaryBuf[3] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       (pos('jmp a_', TemporaryBuf[1]) > 0) and						// jmp a_xxxx		; 1
       (pos('l_', TemporaryBuf[2]) = 1) and						//l_yyyy		; 2
       (TemporaryBuf[3] = copy(TemporaryBuf[1], 6, 256)) then				//a_xxxx		; 3
      begin
	TemporaryBuf[1] := '~';
      end;


end;	// procedure
