
// -----------------------------------------------------------------------------
// ===		     		      TEMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP;
var p: integer;
begin


   if lda(10) and									// lda			; 10
      cmp(11) and									// cmp			; 11
      jcc_l(12) and									// jcc			; 12	branch if C=0
      lda(13) and									// lda			; 13	C=1
      sub(14) then									// sub			; 14
    begin
	TemporaryBuf[14] := #9'sbc ' + copy(TemporaryBuf[14], 6, 256);
    end;


   if jcc_l(10) and									// jcc			; 10	branch if C=0
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=1
      sub(14) then									// sub			; 14
    begin
	TemporaryBuf[14] := #9'sbc ' + copy(TemporaryBuf[14], 6, 256);
    end;


   if jcc_l(10) and									// jcc			; 10	branch if C=0
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=1
      lda(14) and									// lda			; 14
      sub(15) then									// sub			; 15
    begin
	TemporaryBuf[15] := #9'sbc ' + copy(TemporaryBuf[15], 6, 256);
    end;


   if jcc_l(10) and									// jcc			; 10	branch if C=0
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=1
      ldy(14) and									// ldy			; 14
      lda(15) and									// lda			; 15
      sub(16) then									// sub			; 16
    begin
	TemporaryBuf[16] := #9'sbc ' + copy(TemporaryBuf[16], 6, 256);
    end;


   if jcs_l(10) and									// jcs			; 10	branch if C=1
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=0
      add(14) then									// add			; 14
    begin
	TemporaryBuf[14] := #9'adc ' + copy(TemporaryBuf[14], 6, 256);
    end;


   if jcs_l(10) and									// jcs			; 10	branch if C=1
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=0
      lda(14) and									// lda			; 14
      add(15) then									// add			; 15
    begin
	TemporaryBuf[15] := #9'adc ' + copy(TemporaryBuf[15], 6, 256);
    end;


   if jcs_l(10) and									// jcs			; 10	branch if C=1
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=0
      ldy(14) and									// ldy			; 14
      lda(15) and									// lda			; 15
      add(16) then									// add			; 16
    begin
	TemporaryBuf[16] := #9'adc ' + copy(TemporaryBuf[16], 6, 256);
    end;


{ !!!

   if (pos('jcs l_', TemporaryBuf[10]) > 0) and						// jcs			; 10	branch if C=1
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=0
      (TemporaryBuf[14] = #9'asl @') and						// asl @		; 14
      (pos('add ', TemporaryBuf[15]) > 0) then						// add			; 15
    begin
	TemporaryBuf[15] := #9'adc ' + copy(TemporaryBuf[15], 6, 256);
    end;


   if (pos('jcs l_', TemporaryBuf[10]) > 0) and						// jcs			; 10	branch if C=1
      (TemporaryBuf[11] = '') and							//			; 11
      (pos('; optimize ', TemporaryBuf[12]) > 0) and					//; optimize 		; 12
      (TemporaryBuf[13] = '') and							//			; 13	C=0
      (TemporaryBuf[14] = #9'asl @') and						// asl @		; 14
      (TemporaryBuf[15] = #9'asl @') and						// asl @		; 15
      (pos('add ', TemporaryBuf[16]) > 0) then						// add			; 16
    begin
	TemporaryBuf[16] := #9'adc ' + copy(TemporaryBuf[16], 6, 256);
    end;
}


   if (TemporaryBuf[10] = #9'scc') and							// scc			; 10	branch if C=0
      inc_(11) and									// inc			; 11
      (TemporaryBuf[12] = '') and							//			; 12
      (pos('; optimize ', TemporaryBuf[13]) > 0) and					//; optimize 		; 13
      (TemporaryBuf[14] = '') and							//			; 14	C=0
      add(15) then									// add			; 15
    begin
	TemporaryBuf[10] := #9'bcc @+';

	TemporaryBuf[12] := #9'clc';
	TemporaryBuf[13] := '@';

	TemporaryBuf[15] := #9'adc ' + copy(TemporaryBuf[15], 6, 256);
    end;


   if (TemporaryBuf[10] = #9'scs') and							// scs			; 10	branch if C=1
      dec_(11) and									// dec			; 11
      (TemporaryBuf[12] = '') and							//			; 12
      (pos('; optimize ', TemporaryBuf[13]) > 0) and					//; optimize 		; 13
      (TemporaryBuf[14] = '') and							//			; 14	C=1
      sub(15) then									// sub			; 15
    begin
	TemporaryBuf[10] := #9'bcs @+';

	TemporaryBuf[12] := #9'sec';
	TemporaryBuf[13] := '@';

	TemporaryBuf[15] := #9'sbc ' + copy(TemporaryBuf[15], 6, 256);
    end;


// -----------------------------------------------------------------------------


   if ldy(0) and									// ldy I		; 0
      sta(1) and									// sta			; 1
      (TemporaryBuf[2] = '') and							//			; 2
      (pos('; optimize ', TemporaryBuf[3]) > 0) and					//; optimize 		; 3
      (TemporaryBuf[4] = '') and							//			; 4
      lda(5) then									// lda I		; 5
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[5], 6, 256)) then
    begin
	TemporaryBuf[5] := #9'tya';
    end;


   if ldy(0) and									// ldy I		; 0
      lda(1) and									// lda			; 1
      sta(2) and									// sta			; 2
      (TemporaryBuf[3] = '') and							//			; 3
      (pos('; optimize ', TemporaryBuf[4]) > 0) and					//; optimize 		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      lda(6) then									// lda I		; 6
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then
    begin
	TemporaryBuf[6] := #9'tya';
    end;


   if ldy(0) and									// ldy I		; 0
      lda(1) and									// lda			; 1
      sta(2) and									// sta			; 2
      lda(3) then									// lda I		; 3
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[3], 6, 256)) then
    begin
	TemporaryBuf[3] := #9'tya';
    end;


    if (TemporaryBuf[0] = #9'lda #$00') and						// lda #$00		; 0
       sta_stack(1) and									// sta :STACKORIGIN	; 1
       (TemporaryBuf[2] = #9'iny') and							// iny			; 2
       lda_stack(3) and									// lda :STACKORIGIN	; 3
       (pos('ora ', TemporaryBuf[4]) > 0) and						// ora			; 4
       sta(5) then									// sta			; 5
     if (copy(TemporaryBuf[1], 6, 256) = copy(TemporaryBuf[3], 6, 256)) then
     begin
	TemporaryBuf[4] := #9'lda ' + copy(TemporaryBuf[4], 6, 256) ;

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';

	TemporaryBuf[3] := '~';
     end;


   if (pos('lsr ', TemporaryBuf[0]) > 0) and						// lsr I		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) and									// lda I		; 4
      (jne(5) or jeq(5)) then								// jne|jeq		; 5
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
    begin
	TemporaryBuf[4] := '~';
    end;


   if ldy(0) and									// ldy I		; 0
      sta(1) and									// sta			; 1
      inc_(2) and									// inc I		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      (pos('; optimize ', TemporaryBuf[4]) > 0) and					//; optimize 		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      lda(6) and									// lda I		; 6
      cmp(7) and									// cmp			; 7
      SKIP(8) then									// jne|jeq|... l_	; 8
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[2], 6, 256)) and
       (copy(TemporaryBuf[2], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then
    begin
     TemporaryBuf[2] := #9'iny';

     TemporaryBuf[6] := #9'sty ' + copy(TemporaryBuf[6], 6, 256);
     TemporaryBuf[7] := #9'cpy ' + copy(TemporaryBuf[7], 6, 256);

     if (SKIP(9) = false) and (pos(' l_', TemporaryBuf[8]) > 0) then begin

      tmp := copy(TemporaryBuf[8], 6, 256);
      p:=9;
      while (TemporaryBuf[p] <> tmp) and (p < High(TemporaryBuf)) do inc(p);

      if (TemporaryBuf[p] = tmp) and
         (pos('mva ', TemporaryBuf[p-1]) > 0) and							// mva ... I
         (TemporaryBuf[p-1] = #9'mva ' + GetString(p-1) + ' ' + copy(TemporaryBuf[6], 6, 256)) and	//l_
         (TemporaryBuf[p+1] = '') then
  	begin
	 TemporaryBuf[p+1] := TemporaryBuf[6];
	 TemporaryBuf[6] := '~';

	 TemporaryBuf[p-1] := #9'ldy ' + GetString(p-1);
	end;

     end;

    end;


    if (TemporaryBuf[0] = #9'and #$01') and						// and #$01		; 0
       jeq(1) and									// jeq			; 1
       ldy(2) and									// ldy			; 2
       lda(3) and									// lda			; 3
       (TemporaryBuf[4] = #9'add #$01') then						// add #$01		; 4
      begin
	TemporaryBuf[3]  := #9'add ' + copy(TemporaryBuf[3], 6, 256);
	TemporaryBuf[4] := '~';
      end;


    if inc_(0) and									// inc W		; 0
       (TemporaryBuf[1] = #9'sne') and							// sne			; 1
       inc_(2) and									// inc W+1		; 2
       (jmp(3) or jne(3)) and								// jmp|jne		; 3
       lab_l(4) then									//l_			; 4
       //(TemporaryBuf[5] = '; --- WhileDoEpilog') then					//; --- WhileDoEpilog	; 5
     if (pos(TemporaryBuf[0], TemporaryBuf[2]) > 0) then
      begin
	TemporaryBuf[1] := #9'jne ' + copy(TemporaryBuf[3], 6, 256);
      end;


    if ldy(0) and 									// ldy #$00		; 0
       lda(1) and									// lda #$00		; 1
       sta(2) then									// sta			; 2
     if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[1], 6, 256)) then
      begin
	TemporaryBuf[1] := #9'tya'
      end;


    if (TemporaryBuf[0] <> #9'sta #$00') and sta(0) and					// sta A		; 0
       lda(1) then									// lda A		; 1
     if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[1], 6, 256)) then
      begin

        if sta_stack(0) then begin
	  TemporaryBuf[0] := '~';
	  TemporaryBuf[1] := '~';
	end else
	  TemporaryBuf[1] := '~';

      end;


    if (TemporaryBuf[2] = #9'iny') and							// iny			; 2
       (TemporaryBuf[3] = #9'lda #$00') and						// lda #$00		; 3
       (pos('asl :STACK', TemporaryBuf[4]) > 0) then					// asl :STACKORIGIN	; 4
     begin
       TemporaryBuf[2] := '~';

       if (TemporaryBuf[1] = #9'iny') then begin
        TemporaryBuf[1] := '~';

        if (TemporaryBuf[0] = #9'iny') then TemporaryBuf[0] := '~';

       end;

     end;


    if sta_stack(0) and 								// sta :STACKORIGIN	; 0
       ((TemporaryBuf[1] = #9'iny') or (TemporaryBuf[1] = #9'dey')) and			// iny|dey		; 1
       lda_stack(2) and									// lda :STACKORIGIN	; 2
       (SKIP(3) = false) then
     if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[2], 6, 256)) then
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[2] := '~';
      end;


    if (TemporaryBuf[0] = #9'tay') and							// tay			; 0
       (TemporaryBuf[1] = #9'iny') and							// iny			; 1
       (TemporaryBuf[2] = #9'iny') then							// iny			; 2
     begin

       if (TemporaryBuf[3] = #9'iny') then begin					// iny			; 3
	TemporaryBuf[0] := #9'add #$03';

        TemporaryBuf[3] := '~';
       end else
	TemporaryBuf[0] := #9'add #$02';

       TemporaryBuf[1] := #9'tay';
       TemporaryBuf[2] := '~';
     end;


    if (TemporaryBuf[0] = #9'bcc *+7') and						// bcc *+7		; 0
       (TemporaryBuf[1] = #9'beq *+5') and						// beq *+5		; 1
       jmp(2) then									// jmp l_		; 2
      begin
       TemporaryBuf[0] := #9'scc';
       TemporaryBuf[1] := #9'jne ' + copy(TemporaryBuf[2], 6, 256);
       TemporaryBuf[2] := '~';
      end;


   if (SKIP(0) = false) and								// beq *+5		; 1
      (TemporaryBuf[1] = #9'beq *+5') and						// jmp l_xxxx		; 2
      jmp(2) then
    begin
     TemporaryBuf[1] := #9'jne ' + copy(TemporaryBuf[2], 6, 256);
     TemporaryBuf[2] := '~';
    end;


   if (SKIP(0) = false) and								// bmi *+5		; 1
      (TemporaryBuf[1] = #9'bmi *+5') and						// jmp l_xxxx		; 2
      jmp(2) then
    begin
     TemporaryBuf[1] := #9'jpl ' + copy(TemporaryBuf[2], 6, 256);
     TemporaryBuf[2] := '~';
    end;


   if (TemporaryBuf[0] = #9'seq') and							// seq			; 0
      jmp(1) then									// jmp l_		; 1
    begin
     TemporaryBuf[0]   := #9'jne ' + copy(TemporaryBuf[1], 6, 256);
     TemporaryBuf[1] := '~';
    end;


    if (TemporaryBuf[0] = #9'.ENDL') and						// .ENDL		; 0
       (TemporaryBuf[1] = #9'bmi *+7') and						// bmi *+7		; 1
       (TemporaryBuf[2] = #9'beq *+5') and						// beq *+5		; 2
       jmp(3) then									// jmp l_		; 3
      begin
       TemporaryBuf[1] := #9'smi';
       TemporaryBuf[2] := #9'jne ' + copy(TemporaryBuf[3], 6, 256);
       TemporaryBuf[3] := '~';
      end;


   if lab_l(0) and									//l_			; 0
      lda(1) and									// lda			; 1
      cmp(2) and									// cmp			; 2
      (TemporaryBuf[3] = #9'beq @+') and						// beq @+		; 3
      jmp(4) and 									// jmp l_xxxx		; 4
      (TemporaryBuf[5] = '@') then							//@			; 5
    begin
     TemporaryBuf[3] := #9'jne ' + copy(TemporaryBuf[4], 6, 256);
     TemporaryBuf[4] := '~';
     TemporaryBuf[5] := '~';
    end;


   if lab_l(0) and									//l_			; 0
      lda(1) and									// lda			; 1
      cmp(2) and									// cmp			; 2
      jne(3) and									// jne			; 3
      (TemporaryBuf[4] = '@') then							//@			; 4
    begin
     TemporaryBuf[4] := '~';
    end;


   if lab_l(0) and									//l_			; 0
      cmp(1) and									// cmp			; 1
      (TemporaryBuf[2] = #9'beq @+') and						// beq @+		; 2
      jmp(3) and 									// jmp l_xxxx		; 3
      (TemporaryBuf[4] = '@') then							//@			; 4
    begin
     TemporaryBuf[2] := #9'jne ' + copy(TemporaryBuf[3], 6, 256);
     TemporaryBuf[3] := '~';
     TemporaryBuf[4] := '~';
    end;


   if lab_l(0) and									//l_			; 0
      cmp(1) and									// cmp			; 1
      jne(2) and									// jne			; 2
      (TemporaryBuf[3] = '@') then							//@			; 3
    begin
     TemporaryBuf[3] := '~';
    end;


   if (SKIP(0) = false) and								//~SKIP			; 0
      (TemporaryBuf[1] = #9'beq @+') and						// beq @+		; 1
      jmp(2) and									// jmp l_xxxx		; 2
      (TemporaryBuf[3] = '@') then							//@			; 3
    begin
     TemporaryBuf[1] := #9'jne ' + copy(TemporaryBuf[2], 6, 256);
     TemporaryBuf[2] := '~';
    end;


   if lab_l(0) and									//l_			; 0
      lda(1) and									// adc			; 1
      (pos(#9'clc', TemporaryBuf[2]) = 1) and						// clc			; 2
      (pos('adc ', TemporaryBuf[3]) > 0) and						// adc			; 3
      (pos('adc ', TemporaryBuf[4]) > 0) and						// adc			; 4
      (TemporaryBuf[5] = #9'bcs @+') and						// bcs @+		; 5
      jmp(6) and 									// jmp l_xxxx		; 6
      (TemporaryBuf[7] = '@') then							//@			; 7
    begin
     TemporaryBuf[5] := #9'jcc ' + copy(TemporaryBuf[6], 6, 256);
     TemporaryBuf[6] := '~';
     TemporaryBuf[7] := '~';
    end;


   if lab_l(0) and									//l_			; 0
      (pos(#9'clc', TemporaryBuf[1]) = 1) and						// clc			; 1
      (pos('adc ', TemporaryBuf[2]) > 0) and						// adc			; 2
      (pos('adc ', TemporaryBuf[3]) > 0) and						// adc			; 3
      (TemporaryBuf[4] = #9'bcs @+') and						// bcs @+		; 4
      jmp(5) and 									// jmp l_xxxx		; 5
      (TemporaryBuf[6] = '@') then							//@			; 6
    begin
     TemporaryBuf[4] := #9'jcc ' + copy(TemporaryBuf[5], 6, 256);
     TemporaryBuf[5] := '~';
     TemporaryBuf[6] := '~';
    end;


   if (SKIP(0) = false) and								//~SKIP			; 0
      (TemporaryBuf[1] = #9'bcs @+') and						// bcs @+		; 1
      jmp(2) and									// jmp l_xxxx		; 2
      (TemporaryBuf[3] = '@') then							//@			; 3
    begin
     TemporaryBuf[1] := #9'jcc ' + copy(TemporaryBuf[2], 6, 256);
     TemporaryBuf[2] := '~';
    end;


   if (SKIP(0) = false) and								//~SKIP			; 0
      (TemporaryBuf[1] = #9'bcc @+') and						// bcc @+		; 1
      jmp(2) and									// jmp l_xxxx		; 2
      (TemporaryBuf[3] = '@') then							//@			; 3
    begin
     TemporaryBuf[1] := #9'jcs ' + copy(TemporaryBuf[2], 6, 256);
     TemporaryBuf[2] := '~';
    end;


   if lda(0) and									// lda N		; 0
      SKIP(1) and									// SKIP			; 1
      (TemporaryBuf[2] = '') and							//			; 2
      (pos('; optimize ', TemporaryBuf[3]) > 0) and					//; optimize 		; 3
      (TemporaryBuf[4] = '') and							//			; 4
      (TemporaryBuf[5] = #9'lda #$00') and						// lda #$00		; 5
      sub(6) and									// sub N		; 6
      sta(7) then									// sta N		; 7
//      lab_l(8) then									//l_00DB		; 8
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[6], 6, 256)) and
       (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[7], 6, 256)) and
       (copy(TemporaryBuf[1], 6, 256) = TemporaryBuf[8]) then
    begin
     TemporaryBuf[5] := #9'eor #$FF';
     TemporaryBuf[6] := #9'add #$01';

     if TemporaryBuf[12] = TemporaryBuf[0] then TemporaryBuf[12] := '~';
    end;


   if lda(0) and									// lda N		; 0
      SKIP(1) and									// SKIP			; 1
      (TemporaryBuf[2] = '') and							//			; 2
      (pos('; optimize ', TemporaryBuf[3]) > 0) and					//; optimize 		; 3
      (TemporaryBuf[4] = '') and							//			; 4
      (TemporaryBuf[5] = TemporaryBuf[0]) then						// lda N		; 5
    begin
     TemporaryBuf[5] := '~';
    end;


   if sty(0) and									// sty N		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) and									// lda 			; 4
      (TemporaryBuf[5] = #9'sta ' + copy(TemporaryBuf[0], 6, 256)) then			// sta N		; 5
    begin
     TemporaryBuf[0] := '~';
    end;


   if (pos('mva #', TemporaryBuf[0]) > 0) and						// mva #$xx		; 0
      (pos('mva #', TemporaryBuf[1]) > 0) and						// mva #$xx		; 1
      (pos('mva #', TemporaryBuf[2]) > 0) then						// mva #$xx		; 2
    if (copy(TemporaryBuf[0], 6, 4) = copy(TemporaryBuf[1], 6, 4)) and
       (copy(TemporaryBuf[1], 6, 4) = copy(TemporaryBuf[2], 6, 4)) then
     begin

      if (pos('mva #', TemporaryBuf[3]) > 0) then begin					// mva #$yy		; 3

       if (copy(TemporaryBuf[1], 6, 4) = copy(TemporaryBuf[3], 6, 4)) then
         TemporaryBuf[3] := #9'sta' + copy(TemporaryBuf[3], 10, 256);

      end;

      TemporaryBuf[1] := #9'sta' + copy(TemporaryBuf[1], 10, 256);
      TemporaryBuf[2] := #9'sta' + copy(TemporaryBuf[2], 10, 256);

     end;


   if (pos('mva #', TemporaryBuf[0]) > 0) and						// mva #$xx		; 0
      (pos('mva #', TemporaryBuf[1]) > 0) then						// mva #$xx		; 1
    if (copy(TemporaryBuf[0], 6, 4) = copy(TemporaryBuf[1], 6, 4)) then
     begin

      if (pos('mva #', TemporaryBuf[2]) > 0) then begin					// mva #$yy		; 2

       if (copy(TemporaryBuf[1], 6, 4) = copy(TemporaryBuf[2], 6, 4)) then
         TemporaryBuf[2] := #9'sta' + copy(TemporaryBuf[2], 10, 256);

      end;

      TemporaryBuf[1] := #9'sta' + copy(TemporaryBuf[1], 10, 256);

     end;


   if (pos('mva ', TemporaryBuf[0]) > 0) and						// mva RNDNUMBER N	; 0
      (pos('mva ', TemporaryBuf[1]) > 0) and						// mva RNDNUMBER N+1	; 1
      (TemporaryBuf[2] = '') and							//			; 2
      (pos('; optimize ', TemporaryBuf[3]) > 0) and					//; optimize 		; 3
      (TemporaryBuf[4] = '') and							//			; 4
      lda(5) then									// lda N		; 5
    if pos(copy(TemporaryBuf[5], 5, 256), TemporaryBuf[0]) > 6 then
    begin
     tmp:=TemporaryBuf[0];
     p:=length(tmp);

     while tmp[p] <> ' ' do dec(p);

     tmp := copy(tmp, p+1, 256);

     if copy(TemporaryBuf[5], 6, 256) = tmp then begin
      TemporaryBuf[5] := '~';

      tmp:=TemporaryBuf[0];
      TemporaryBuf[0]:=TemporaryBuf[1];
      TemporaryBuf[1]:=tmp;
     end;

    end;


   if (pos('mva ', TemporaryBuf[0]) > 0) and						// mva RNDNUMBER N	; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) then									// lda N		; 4
    if pos(copy(TemporaryBuf[4], 5, 256), TemporaryBuf[0]) > 6 then
    begin
     tmp:=TemporaryBuf[0];
     p:=length(tmp);

     while tmp[p] <> ' ' do dec(p);

     tmp := copy(tmp, p+1, 256);

     if copy(TemporaryBuf[4], 6, 256) = tmp then TemporaryBuf[4] := '~'
    end;


   if (TemporaryBuf[0] = #9'tya') and							// tya			; 0
      (TemporaryBuf[1] = #9'adc #$00') and						// adc #$00		; 1
      sta(2) and									// sta			; 2
      (sta_stack(2) = false) then
    begin
     TemporaryBuf[0] := #9'scc';
     TemporaryBuf[1] := #9'iny';
     TemporaryBuf[2] := #9'sty ' + copy(TemporaryBuf[2], 6, 256);
    end;


   if sta(0) and									// sta PRIME		; 0
      (TemporaryBuf[1] = #9'scc') and							// scc			; 1
      inc_(2) and									// inc PRIME+1		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      (pos('; optimize ', TemporaryBuf[4]) > 0) and					//; optimize 		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      lda(6) then									// lda PRIME		; 6
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then
    begin
     TemporaryBuf[6] := '~';
    end;


   if sta(0) and									// sta PRIME		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) then									// lda PRIME		; 4
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
    begin
     TemporaryBuf[4] := '~';
    end;


   if sta(0) and									// sta K		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      ldy(4) then									// ldy K		; 4
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
    begin

     if sty(5) then begin
      TemporaryBuf[4] := '~';
      TemporaryBuf[5] := #9'sta ' + copy(TemporaryBuf[5], 6, 256);
     end else
      TemporaryBuf[4] := #9'tay';

    end;


   if inc_(0) and									// inc I		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) and									// lda I		; 4
      (jeq(5) or jne(5)) then								// jeq|jne		; 5
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
    begin
     TemporaryBuf[4] := '~';
    end;


   if dec_(0) and									// dec I		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) and									// lda I		; 4
      jne(5) then									// jne			; 5
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
    begin
     TemporaryBuf[4] := '~';
    end;


   if sta(0) and									// sta W		; 0
      lda(1) and									// lda			; 1
      sta(2) and									// sta W+1		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      (pos('; optimize ', TemporaryBuf[4]) > 0) and					//; optimize 		; 4
      (TemporaryBuf[5] = '') and							//			; 5
      (pos('mwy ', TemporaryBuf[6]) > 0) and (pos(' :bp2', TemporaryBuf[6]) > 0) then	// mwy W :bp2		; 6
    if (pos(TemporaryBuf[0], TemporaryBuf[2]) > 0) and
       (#9'mwy ' + copy(TemporaryBuf[0], 6, 256) + ' :bp2' = TemporaryBuf[6]) then
    begin
     TemporaryBuf[6] := '~';
     TemporaryBuf[5] := TemporaryBuf[4];
     TemporaryBuf[4] := TemporaryBuf[3];
     TemporaryBuf[3] := TemporaryBuf[2];
     TemporaryBuf[2] := TemporaryBuf[1];

     TemporaryBuf[1] := #9'sta :bp2';

     TemporaryBuf[4] := #9'sta :bp2+1';
    end;


   if (TemporaryBuf[0] = #9'imulCL') and						// imulCL		; 0
      (TemporaryBuf[1] = #9'eif') and							// eif			; 1
      (TemporaryBuf[2] = #9'lda :eax') and						// lda :eax		; 2
      sta(3) and									// sta Y		; 3
      (TemporaryBuf[4] = #9'lda :eax+1') and						// lda :eax+1		; 4
      sta(5) and									// sta Y+1		; 5
      (TemporaryBuf[6] = '') and							//			; 6
      (pos('; optimize ', TemporaryBuf[7]) > 0) and					//; optimize 		; 7
      (TemporaryBuf[8] = '') then							//			; 8
    begin
     TemporaryBuf[4] := TemporaryBuf[2];

     TemporaryBuf[2] := TemporaryBuf[5];

     TemporaryBuf[5] := TemporaryBuf[3];
     TemporaryBuf[3] := '~';

     if lda(9) and									// lda			; 9
        add(10) and									// add Y		; 10
	(copy(TemporaryBuf[5], 6, 256) = copy(TemporaryBuf[10], 6, 256)) then
      begin
       TemporaryBuf[10] := '~';
       TemporaryBuf[9] := #9'add ' + copy(TemporaryBuf[9], 6, 256);
      end;

    end;


   if lab_l(0) and									//l_00FB		; 0
      (TemporaryBuf[1] = '') and							//			; 1
      (pos('; optimize ', TemporaryBuf[2]) > 0) and					//; optimize 		; 2
      (TemporaryBuf[3] = '') and							//			; 3
      lda(4) and									// lda K+1		; 4
      SKIP(5) and									// SKIP			; 5
      (TemporaryBuf[6] = '') and							//			; 6
      (pos('; optimize ', TemporaryBuf[7]) > 0) and					//; optimize 		; 7
      (TemporaryBuf[8] = '') and							// 			; 8
      lda(9) and									// lda K		; 9
      add_sub(10) and									// add|sub		; 10
      sta(11) and									// sta			; 11
      (TemporaryBuf[12] = TemporaryBuf[4]) then						// lda K+1		; 12
    begin
	TemporaryBuf[4] := #9'ldy ' + copy(TemporaryBuf[4], 6, 256);

	TemporaryBuf[12] := #9'tya';
    end;


   if lda(0) and									// lda K+1		; 0
      SKIP(1) and									// SKIP			; 1
      (TemporaryBuf[2] = '') and							//			; 2
      (pos('; optimize ', TemporaryBuf[3]) > 0) and					//; optimize 		; 3
      (TemporaryBuf[4] = '') and							// 			; 4
      lda(5) and									// lda 			; 5
      ldy(6) then									// ldy K+1		; 6
    if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[6], 6, 256)) then
      begin
	TemporaryBuf[0] := TemporaryBuf[6];

	TemporaryBuf[6] := '~';
      end;


    if lda(0) and									// lda N+1		; 0
       sta_stack(1) and									// sta :STACKORIGIN+9	; 1
       lda(2) and									// lda N		; 2
       (TemporaryBuf[3] = #9'asl @') and						// asl @		; 3
       (pos('rol :STACK', TemporaryBuf[4]) > 0) and					// rol :STACKORIGIN+9	; 4
       sta(5) and									// sta K		; 5
       lda_stack(6) and									// lda :STACKORIGIN+9	; 6
       sta(7) and (iy(7) = false) and							// sta K+1		; 7
       (TemporaryBuf[9] <> '; --- WhileProlog') then
     if (copy(TemporaryBuf[1], 6, 256) = copy(TemporaryBuf[4], 6, 256)) and
	(copy(TemporaryBuf[4], 6, 256) = copy(TemporaryBuf[6], 6, 256)) and
	(pos(TemporaryBuf[5], TemporaryBuf[7]) > 0) then
       begin
	TemporaryBuf[1] := TemporaryBuf[7];

	TemporaryBuf[4] := #9'rol ' + copy(TemporaryBuf[7], 6, 256);

	TemporaryBuf[6] := '~';
	TemporaryBuf[7] := '~';
       end;


    if lda(0) and (TemporaryBuf[0] = TemporaryBuf[4]) and				// lda A		; 0
       (TemporaryBuf[1] = #9'sta :ecx') and						// sta :ecx		; 1
       lda(2) and (TemporaryBuf[2] = TemporaryBuf[6]) and				// lda A+1		; 2
       (TemporaryBuf[3] = #9'sta :ecx+1') and						// sta :ecx+1		; 3
//       lda(4) and									// lda A		; 4
       (TemporaryBuf[5] = #9'sta :eax') and						// sta :eax		; 5
//       lda(6) and									// lda A+1		; 6
       (TemporaryBuf[7] = #9'sta :eax+1') then						// sta :eax+1		; 7
      begin
   	TemporaryBuf[6] := #9'sta :ecx+1';
	TemporaryBuf[5] := TemporaryBuf[2];
	TemporaryBuf[4] := #9'sta :eax';
	TemporaryBuf[3] := #9'sta :ecx';
	TemporaryBuf[2] := TemporaryBuf[0];
	TemporaryBuf[1] := '~';
	TemporaryBuf[0] := '~';
      end;

end;	// procedure
