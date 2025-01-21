
// -----------------------------------------------------------------------------
// ===				      JMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_JMP;
var p: integer;
begin

   if sta(0) and									// sta A		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      jmp(2) and									// jmp l_xxxx		; 2
      lab_l(3) and									//l_xxxx		; 3
      (TemporaryBuf[4] = '') and							//			; 4
      (pos('; optimize ', TemporaryBuf[5]) > 0) and					//; optimize 		; 5
      (TemporaryBuf[6] = '') and							//			; 6
      lda(7) then									// lda A		; 7
    if (TemporaryBuf[3] = copy(TemporaryBuf[2], 6, 256)) and
       (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[7], 6, 256)) then
    begin
     TemporaryBuf[2] := '~';
     TemporaryBuf[3] := '~';

     TemporaryBuf[7] := '~';
    end;


    if jne_l(0) and									// jne l_xxxx		; 0
       (TemporaryBuf[1] = #9'jmp @exit') and						// jmp @exit		; 1
       (pos(TemporaryBuf[2], TemporaryBuf[0]) > 0) and					//l_xxxx		; 2
       (IFTMP(3) = false) then								//~lda IFTMP_		; 3
     begin
      TemporaryBuf[0] := #9'jeq @exit';
      TemporaryBuf[1] := '~';
     end;


    if (pos('lda #$', TemporaryBuf[0]) > 0) and (TemporaryBuf[0] <> #9'lda #$00') and	// lda #$01		; 0
       jeq_l(1) and									// jeq l_xxxx		; 1
       jmp(2) and									// jmp l_yyyy		; 2
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


    if (TemporaryBuf[0] = #9'jmp @exit') and						// jmp @exit		; 0
       (pos('jmp a_', TemporaryBuf[1]) > 0) then					// jmp a_		; 1
      begin
	TemporaryBuf[1] := '~';
      end;


    if (TemporaryBuf[0] = #9'jmp @+') and						// jmp @+		; 0
       jmp(1) and									// jmp l_		; 1
       (TemporaryBuf[2] = '@') then							//@			; 2
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       jmp(1) and									// jmp l_xxxx		; 1
       (TemporaryBuf[2] = copy(TemporaryBuf[1], 6, 256)) and				//l_xxxx		; 2
       (IFTMP(3) = false) then								//~lda IFTMP_		; 3
     begin
      TemporaryBuf[1] := '~';
      TemporaryBuf[2] := '~';
     end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       jmp(1) and									// jmp l_xxxx		; 1
       lab_l(2) and									//l_yyyy		; 2
       (TemporaryBuf[3] = copy(TemporaryBuf[1], 6, 256)) and				//l_xxxx		; 3
       (IFTMP(4) = false) then								//~lda IFTMP_		; 4
      begin
	TemporaryBuf[1] := '~';

	TemporaryBuf[3] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       (pos('jmp a_', TemporaryBuf[1]) > 0) and						// jmp a_xxxx		; 1
       lab_l(2) and									//l_yyyy		; 2
       (TemporaryBuf[3] = copy(TemporaryBuf[1], 6, 256)) then				//a_xxxx		; 3
      begin
	TemporaryBuf[1] := '~';
      end;


end;	// procedure
