
// -----------------------------------------------------------------------------
// ===		     		      X.
// -----------------------------------------------------------------------------

procedure opt_TEMP_X;
begin

    if (pos('mva :STACKORIGIN,x', TemporaryBuf[0]) > 0) and					// mva :STACKORIGIN			; 0
       (pos('mva :STACKORIGIN+STACKWIDTH,x', TemporaryBuf[1]) > 0) and				// mva :STACKORIGIN+STACKWIDTH		; 1
       (pos('mva :STACKORIGIN+STACKWIDTH*2,x', TemporaryBuf[2]) > 0) and			// mva :STACKORIGIN+STACKWIDTH*2	; 2
       (pos('mva :STACKORIGIN+STACKWIDTH*3,x', TemporaryBuf[3]) > 0) and			// mva :STACKORIGIN+STACKWIDTH*3	; 3
       (TemporaryBuf[4] = #9'dex') and								// dex					; 4
       (TemporaryBuf[5] = '') and								// 					; 5
       opti(6) and										//; optimize				; 6
       (TemporaryBuf[7] = '') and								// 					; 7
       (TemporaryBuf[8] = #9'inx') and								// inx					; 8
       ((pos('mva ', TemporaryBuf[9]) > 0) and (pos('mva :STACK', TemporaryBuf[9]) = 0)) and	// mva ... :STACKORIGIN			; 9
       ((pos('mva ', TemporaryBuf[10]) > 0) and (pos('mva :STACK', TemporaryBuf[10]) = 0)) and	// mva ... :STACKORIGIN+STACKWIDTH	; 10
       ((pos('mva ', TemporaryBuf[11]) > 0) and (pos('mva :STACK', TemporaryBuf[11]) = 0)) and	// mva ... :STACKORIGIN+STACKWIDTH*2	; 11
       ((pos('mva ', TemporaryBuf[12]) > 0) and (pos('mva :STACK', TemporaryBuf[12]) = 0)) then	// mva ... :STACKORIGIN+STACKWIDTH*3	; 12
     if (pos(':STACKORIGIN,x', TemporaryBuf[9]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', TemporaryBuf[10]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*2,x', TemporaryBuf[11]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH*3,x', TemporaryBuf[12]) > 0) and
	(TemporaryBuf[0] = #9'mva :STACKORIGIN,x ' + GetString(9)) and
	(TemporaryBuf[1] = #9'mva :STACKORIGIN+STACKWIDTH,x ' + GetString(10)) and
	(TemporaryBuf[2] = #9'mva :STACKORIGIN+STACKWIDTH*2,x ' + GetString(11)) and
	(TemporaryBuf[3] = #9'mva :STACKORIGIN+STACKWIDTH*3,x ' + GetString(12)) then
       begin
	TemporaryBuf[4] := '~';

	TemporaryBuf[8] := '~';
	TemporaryBuf[9] := '~';
	TemporaryBuf[10] := '~';
	TemporaryBuf[11] := '~';
	TemporaryBuf[12] := '~';
       end;


    if (pos('lda ', TemporaryBuf[0]) > 0) and							// lda B				; 0
       (pos('sta ', TemporaryBuf[1]) > 0) and							// sta					; 1
       (pos('lda ', TemporaryBuf[2]) > 0) and							// lda B+1				; 2
       (pos('sta ', TemporaryBuf[3]) > 0) and							// sta					; 3
       (pos('lda ', TemporaryBuf[4]) > 0) and							// lda B+2				; 4
       (pos('sta ', TemporaryBuf[5]) > 0) and							// sta					; 5
       (pos('lda ', TemporaryBuf[6]) > 0) and							// lda B+3				; 6
       (pos('sta ', TemporaryBuf[7]) > 0) and							// sta					; 7
       (TemporaryBuf[8] = '') and								// 					; 8
       opti(9) and										//; optimize				; 9
       (TemporaryBuf[10] = '') and								// 					; 10
       (TemporaryBuf[11] = #9'inx') and								// inx					; 11
       (TemporaryBuf[12] = #9'mva ' + GetString(0) + ' :STACKORIGIN,x') and			// mva B :STACKORIGIN,x			; 12
       (TemporaryBuf[13] = #9'mva ' + GetString(2) + ' :STACKORIGIN+STACKWIDTH,x') and		// mva B+1 :STACKORIGIN+STACKWIDTH,x	; 13
       (TemporaryBuf[14] = #9'mva ' + GetString(4) + ' :STACKORIGIN+STACKWIDTH*2,x') and	// mva B+2 :STACKORIGIN+STACKWIDTH*2,x	; 14
       (TemporaryBuf[15] = #9'mva ' + GetString(6) + ' :STACKORIGIN+STACKWIDTH*3,x') then	// mva B+3 :STACKORIGIN+STACKWIDTH*3,x	; 15
       begin
	TemporaryBuf[10] := TemporaryBuf[9];
	TemporaryBuf[9] := '';

	TemporaryBuf[8] := TemporaryBuf[7];
	TemporaryBuf[7] := TemporaryBuf[6];
	TemporaryBuf[6] := TemporaryBuf[5];
	TemporaryBuf[5] := TemporaryBuf[4];
	TemporaryBuf[4] := TemporaryBuf[3];
	TemporaryBuf[3] := TemporaryBuf[2];
	TemporaryBuf[2] := TemporaryBuf[1];
	TemporaryBuf[1] := TemporaryBuf[0];

	TemporaryBuf[0] := TemporaryBuf[11];
	TemporaryBuf[1] := TemporaryBuf[12];
	TemporaryBuf[3] := TemporaryBuf[13];
	TemporaryBuf[5] := TemporaryBuf[14];
	TemporaryBuf[7] := TemporaryBuf[15];

	TemporaryBuf[11] := '';

	TemporaryBuf[12] := '~';
	TemporaryBuf[13] := '~';
	TemporaryBuf[14] := '~';
	TemporaryBuf[15] := '~';
       end;


    if (pos('mva :STACKORIGIN,x', TemporaryBuf[0]) > 0) and					// mva :STACKORIGIN			; 0
       (pos('mva :STACKORIGIN+STACKWIDTH,x', TemporaryBuf[1]) > 0) and				// mva :STACKORIGIN+STACKWIDTH		; 1
       (TemporaryBuf[2] = #9'dex') and								// dex					; 2
       (TemporaryBuf[3] = '') and								// 					; 3
       opti(4) and										//; optimize				; 4
       (TemporaryBuf[5] = '') and								// 					; 5
       (TemporaryBuf[6] = #9'inx') and								// inx					; 6
       ((pos('mva ', TemporaryBuf[7]) > 0) and (pos('mva :STACK', TemporaryBuf[7]) = 0)) and	// mva ... :STACKORIGIN			; 7
       ((pos('mva ', TemporaryBuf[8]) > 0) and (pos('mva :STACK', TemporaryBuf[8]) = 0)) then	// mva ... :STACKORIGIN+STACKWIDTH	; 8
     if (pos(':STACKORIGIN,x', TemporaryBuf[7]) > 0) and
        (pos(':STACKORIGIN+STACKWIDTH,x', TemporaryBuf[8]) > 0) and
	(TemporaryBuf[0] = #9'mva :STACKORIGIN,x ' + GetString(7)) and
	(TemporaryBuf[1] = #9'mva :STACKORIGIN+STACKWIDTH,x ' + GetString(8)) then
       begin
	TemporaryBuf[2] := '~';

	TemporaryBuf[6] := '~';
	TemporaryBuf[7] := '~';
	TemporaryBuf[8] := '~';
       end;


    if (TemporaryBuf[0] = #9'dex') and							// dex			; 0
       (TemporaryBuf[1] = #9'dex') and							// dex			; 1
       (TemporaryBuf[2] = '') and							// 			; 2
       opti(3) and									//; optimize		; 3
       (TemporaryBuf[4] = '') and							// 			; 4
       (TemporaryBuf[5] = #9'inx') and							// inx			; 5
       (TemporaryBuf[6] = #9'inx') and							// inx			; 6
       (TemporaryBuf[7] <> #9'inx') then						//~inx			; 7
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';

	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';
      end;


    if (TemporaryBuf[0] = #9'dex') and							// dex			; 0
       (TemporaryBuf[1] = '') and							// 			; 1
       opti(2) and									//; optimize		; 2
       (TemporaryBuf[3] = '') and							// 			; 3
       (TemporaryBuf[4] = #9'inx') and							// inx			; 4
       (TemporaryBuf[5] <> #9'inx') then						//~inx			; 5
      begin
	TemporaryBuf[0] := '~';

	TemporaryBuf[4] := '~';
      end;


    if (TemporaryBuf[0] = #9'dex') and							// dex			; 0
       (TemporaryBuf[1] = #9'inx') then							// inx			; 1
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
      end;


    if (TemporaryBuf[0] = #9'inx') and							// inx			; 0
       (TemporaryBuf[1] = #9'dex') then							// dex			; 1
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
      end;

end;	// procedure
