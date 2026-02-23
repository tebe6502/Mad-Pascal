
// -----------------------------------------------------------------------------
// ===		     		      X.
// -----------------------------------------------------------------------------

procedure opt_TEMP_X;
begin

    if lda(0) and										// lda B				; 0
       sta(1) and										// sta					; 1
       lda(2) and										// lda B+1				; 2
       sta(3) and										// sta					; 3
       lda(4) and										// lda B+2				; 4
       sta(5) and										// sta					; 5
       lda(6) and										// lda B+3				; 6
       sta(7) and										// sta					; 7
       (TemporaryBuf[8] = '') and								// 					; 8
       opti(9) and										//; optimize				; 9
       (TemporaryBuf[10] = '') and								// 					; 10
       inx(11) and										// inx					; 11
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


    if dex(0) and										// dex			; 0
       dex(1) and										// dex			; 1
       (TemporaryBuf[2] = '') and								// 			; 2
       opti(3) and										//; optimize		; 3
       (TemporaryBuf[4] = '') and								// 			; 4
       inx(5) and										// inx			; 5
       inx(6) and										// inx			; 6
       (inx(7) = false) then									//~inx			; 7
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';

	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';
      end;


    if dex(0) and										// dex			; 0
       (TemporaryBuf[1] = '') and								// 			; 1
       opti(2) and										//; optimize		; 2
       (TemporaryBuf[3] = '') and								// 			; 3
       inx(4) and										// inx			; 4
       (inx(5) = false) then									//~inx			; 5
      begin
	TemporaryBuf[0] := '~';

	TemporaryBuf[4] := '~';
      end;


    if dex(0) and										// dex			; 0
       inx(1) then										// inx			; 1
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
      end;


    if inx(0) and										// inx			; 0
       dex(1) then										// dex			; 1
      begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
      end;

end;	// procedure
