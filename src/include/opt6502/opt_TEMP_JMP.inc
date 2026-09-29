
// -----------------------------------------------------------------------------
// ===				      JMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_JMP;
begin

   if sta(0) and									// sta A		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      jmp_l(2) and									// jmp l_xxxx		; 2
      lab_l(3) and									//l_xxxx		; 3
      											//			; 4
      opti(5) and									//; optimize 		; 5
      											//			; 6
      lda(7) then									// lda A		; 7
    if (TemporaryBuf[3] = GetARG(2)) and
       argMatch(0, 7) then
    begin
     TemporaryBuf[2] := '~';
     TemporaryBuf[3] := '~';

     TemporaryBuf[7] := '~';
    end;


    if (SKIP(0) = FALSE) and								//~SKIP			; 0
       jne_l(1) and									// jne l_xxxx		; 1
       (jmp_b(2) or jmp_e(2)) and							// jmp b_|@exit		; 2
       (TemporaryBuf[3] = GetARG(1)) and						//l_xxxx		; 3
       (IFTMP(4) = false) then								//~lda IFTMP_		; 4
     begin
      TemporaryBuf[1] := #9'jeq ' + GetARG(2);
      TemporaryBuf[2] := '~';
     end;


    if (SKIP(0) = FALSE) and								//~SKIP			; 0
       jcs_l(1) and									// jcs l_xxxx		; 1
       (jmp_b(2) or jmp_e(2)) and							// jmp b_|@exit		; 2
       (TemporaryBuf[3] = GetARG(1)) and						//l_xxxx		; 3
       (IFTMP(4) = false) then								//~lda IFTMP_		; 4
     begin
      TemporaryBuf[1] := #9'jcc ' + GetARG(2);
      TemporaryBuf[2] := '~';
     end;


    if (pos('lda #$', TemporaryBuf[0]) > 0) and (lda_im_0(0) = false) and		// lda #$01		; 0
       jeq_l(1) and									// jeq l_xxxx		; 1
       jmp_l(2) and									// jmp l_yyyy		; 2
       (TemporaryBuf[3] = GetARG(1)) then						//l_xxxx		; 3
     begin
      TemporaryBuf[0] := '~';
      TemporaryBuf[1] := '~';
      TemporaryBuf[3] := '~';
     end;


    if jmp_e(0) and									// jmp @exit		; 0
       (TemporaryBuf[1] = '@exit') then							//@exit			; 1
     begin
      TemporaryBuf[0] := '~';
     end;


    if jmp_e(0) and									// jmp @exit		; 0
       (pos('jmp a_', TemporaryBuf[1]) > 0) then					// jmp a_		; 1
      begin
	TemporaryBuf[1] := '~';
      end;


    if jmp_a(0) and									// jmp @+		; 0
       jmp_l(1) and									// jmp l_		; 1
       lab_a(2) then									//@			; 2
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       jmp_l(1) and									// jmp l_xxxx		; 1
       (TemporaryBuf[2] = GetARG(1)) and						//l_xxxx		; 2
       (IFTMP(3) = false) then								//~lda IFTMP_		; 3
     begin
      TemporaryBuf[1] := '~';
      TemporaryBuf[2] := '~';
     end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       jmp_l(1) and									// jmp l_xxxx		; 1
       lab_l(2) and									//l_yyyy		; 2
       (TemporaryBuf[3] = GetARG(1)) and						//l_xxxx		; 3
       (IFTMP(4) = false) then								//~lda IFTMP_		; 4
      begin
	TemporaryBuf[1] := '~';

	TemporaryBuf[3] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       (pos('jmp a_', TemporaryBuf[1]) > 0) and						// jmp a_xxxx		; 1
       lab_l(2) and									//l_yyyy		; 2
       (TemporaryBuf[3] = GetARG(1)) then						//a_xxxx		; 3
      begin
	TemporaryBuf[1] := '~';
      end;


    if (SKIP(0) = false) and								//~SKIP			; 0
       (pos('jmp a_', TemporaryBuf[1]) > 0) and						// jmp a_xxxx		; 1
       (TemporaryBuf[2] = '~') and							//~			; 2
       lab_l(3) and									//l_yyyy		; 3
       (TemporaryBuf[4] = GetARG(1)) then						//a_xxxx		; 4
      begin
	TemporaryBuf[1] := '~';
      end;


end;	// procedure
