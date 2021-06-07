
// -----------------------------------------------------------------------------
// ===		     optymalizacja FILL.		  	  	  === //
// -----------------------------------------------------------------------------

 if (pos(#9'jsr SYSTEM.FILL', TemporaryBuf[10]) = 1) or

   ((pos(#9'.local +MAIN.SYSTEM.FILL', TemporaryBuf[10]) = 1) and
    (TemporaryBuf[11] = #9'm@INLINE') and
    (TemporaryBuf[12] = #9'.endl')) then begin


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.A+1', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.A', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.COUNT+1', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.COUNT', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[1]) = 1) and (pos('.VALUE', TemporaryBuf[1]) > 0) and
       (pos(#9'lda ', TemporaryBuf[0]) = 1) and
       (pos(#9'lda #', TemporaryBuf[2]) = 1) and
       (pos(#9'lda #', TemporaryBuf[4]) = 1) and
       (pos(#9'lda #', TemporaryBuf[6]) = 1) and
       (pos(#9'lda #', TemporaryBuf[8]) = 1) then
       begin
{
	lda					; 0
	sta SYSTEM.FILLCHAR_02B3.VALUE		; 1
	lda #$08				; 2
	sta SYSTEM.FILLCHAR_02B3.COUNT		; 3
	lda #$00				; 4
	sta SYSTEM.FILLCHAR_02B3.COUNT+1	; 5
	lda #$F0				; 6
	sta SYSTEM.FILLCHAR_02B3.A		; 7
	lda #$87				; 8
	sta SYSTEM.FILLCHAR_02B3.A+1		; 9
}
	q:=GetWORD(6, 8);		// dst
	k:=GetWORD(2, 4);		// len

	yes:=false;

	if k < 6 then begin
	  TemporaryBuf[1] := #9':' + IntToStr(k) + ' sta $' + IntToHex(q, 4) + '+#';

	  TemporaryBuf[2] := '~';
	  TemporaryBuf[3] := '~';
	  TemporaryBuf[4] := '~';
	  TemporaryBuf[5] := '~';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	end else
	if k <= 128 then begin
	  TemporaryBuf[1] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[2] := #9'sta:rpl $' + IntToHex(q, 4) + ',y-';

	  TemporaryBuf[3] := '~';
	  TemporaryBuf[4] := '~';
	  TemporaryBuf[5] := '~';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	end else
	if k <= 256 then begin
	  TemporaryBuf[1] := #9'ldy #256-'+IntToStr(k);
	  TemporaryBuf[2] := #9'sta:rne $' + IntToHex(q, 4) + '+' + IntToStr(k) + '-256,y+';

	  TemporaryBuf[3] := '~';
	  TemporaryBuf[4] := '~';
	  TemporaryBuf[5] := '~';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	 end;

         if yes and (TemporaryBuf[11] = #9'm@INLINE') then begin
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';
	 end;

       end;


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.A+1', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.A', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.COUNT+1', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.COUNT', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[1]) = 1) and (pos('.VALUE', TemporaryBuf[1]) > 0) and
       (pos(#9'lda ', TemporaryBuf[0]) = 1) and
       (pos(#9'lda #', TemporaryBuf[2]) = 1) and
       (pos(#9'lda #', TemporaryBuf[4]) = 1) and
       (pos(#9'lda ', TemporaryBuf[6]) = 1) and (pos(#9'lda #', TemporaryBuf[6]) = 0) and
       (pos(#9'lda ', TemporaryBuf[8]) = 1) then
       begin
{
	lda #$00				; 0
	sta SYSTEM.FILLBYTE_051A.VALUE		; 1
	lda #$15				; 2
	sta SYSTEM.FILLBYTE_051A.COUNT		; 3
	lda #$00				; 4
	sta SYSTEM.FILLBYTE_051A.COUNT+1	; 5
	lda A					; 6
	sta SYSTEM.FILLBYTE_051A.A		; 7
	lda A+1					; 8
	sta SYSTEM.FILLBYTE_051A.A+1		; 9
}
	k:=GetWORD(2, 4);		// len

	yes:=false;

	if k = 256 then begin
	  TemporaryBuf[7] := #9'sta :bp2';

	  TemporaryBuf[9] := #9'sta :bp2+1';

	  TemporaryBuf[1] := TemporaryBuf[6];
	  TemporaryBuf[2] := TemporaryBuf[7];
	  TemporaryBuf[3] := TemporaryBuf[8];
	  TemporaryBuf[4] := TemporaryBuf[9];

	  TemporaryBuf[5] := TemporaryBuf[0];

	  TemporaryBuf[6] := #9'ldy #$00';
	  TemporaryBuf[7] := #9'sta:rne (:bp2),y+';

	  TemporaryBuf[0] := '~';

	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	end else
	if k <= 128 then begin
	  TemporaryBuf[7] := #9'sta :bp2';

	  TemporaryBuf[9] := #9'sta :bp2+1';

	  TemporaryBuf[1] := TemporaryBuf[6];
	  TemporaryBuf[2] := TemporaryBuf[7];
	  TemporaryBuf[3] := TemporaryBuf[8];
	  TemporaryBuf[4] := TemporaryBuf[9];

	  TemporaryBuf[5] := TemporaryBuf[0];

	  TemporaryBuf[6] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[7] := #9'sta:rpl (:bp2),y-';

	  TemporaryBuf[0] := '~';

	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	 end;

         if yes and (TemporaryBuf[11] = #9'm@INLINE') then begin
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';
	 end;

       end;


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.A+1', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.A', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.COUNT+1', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.COUNT', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[2]) = 1) and (pos('.VALUE', TemporaryBuf[2]) > 0) and
       (TemporaryBuf[1] = #9'lda #$00') and
       (TemporaryBuf[4] = #9'lda #$01') and
       (pos(#9'lda ', TemporaryBuf[6]) = 1) and (pos(#9'lda #', TemporaryBuf[6]) = 0) and
       (pos(#9'lda ', TemporaryBuf[8]) = 1) then
       begin
{
						; 0
	lda #$00				; 1
	sta SYSTEM.FILLBYTE_051A.VALUE		; 2
	sta SYSTEM.FILLBYTE_051A.COUNT		; 3
	lda #$01				; 4
	sta SYSTEM.FILLBYTE_051A.COUNT+1	; 5
	lda A					; 6
	sta SYSTEM.FILLBYTE_051A.A		; 7
	lda A+1					; 8
	sta SYSTEM.FILLBYTE_051A.A+1		; 9
}
	TemporaryBuf[7] := #9'sta :bp2';
	TemporaryBuf[9] := #9'sta :bp2+1';

	TemporaryBuf[1] := TemporaryBuf[6];
	TemporaryBuf[2] := TemporaryBuf[7];
	TemporaryBuf[3] := TemporaryBuf[8];
	TemporaryBuf[4] := TemporaryBuf[9];

	TemporaryBuf[5] := #9'ldy #$00';
	TemporaryBuf[6] := #9'tya';
	TemporaryBuf[7] := #9'sta:rne (:bp2),y+';

	TemporaryBuf[8] := '~';
	TemporaryBuf[9] := '~';
	TemporaryBuf[10] := '~';

        if (TemporaryBuf[11] = #9'm@INLINE') then begin
	 TemporaryBuf[11] := '~';
	 TemporaryBuf[12] := '~';
	end;

       end;


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.COUNT+1', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.COUNT', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.VALUE', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.A+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[0]) = 1) and (pos('.A', TemporaryBuf[0]) > 0) and
       (pos(#9'lda ', TemporaryBuf[1]) = 1) and
       ((pos(#9'adc ', TemporaryBuf[2]) = 1) or (pos(#9'sbc ', TemporaryBuf[2]) = 1) or (pos(#9'add ', TemporaryBuf[2]) = 1) or (pos(#9'sub ', TemporaryBuf[2]) = 1)) and
       (pos(#9'lda ', TemporaryBuf[4]) = 1) and
       (pos(#9'lda #', TemporaryBuf[6]) = 1) and
       (pos(#9'lda #', TemporaryBuf[8]) = 1) then
       begin
{
	sta SYSTEM.FILLCHAR_009F.A		; 0
	lda #$C2				; 1
	add|sub|adc|sbc				; 2
	sta SYSTEM.FILLCHAR_009F.A+1		; 3
	lda 					; 4
	sta SYSTEM.FILLCHAR_009F.VALUE		; 5
	lda #$80				; 6
	sta SYSTEM.FILLCHAR_009F.COUNT		; 7
	lda #$00				; 8
	sta SYSTEM.FILLCHAR_009F.COUNT+1	; 9
}
	k:=GetWORD(6, 8);		// len

	if k <= 128 then begin
	  TemporaryBuf[0] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';

	  TemporaryBuf[5] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[6] := #9'sta:rpl (:bp2),y-';

	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

          if (TemporaryBuf[11] = #9'm@INLINE') then begin
	   TemporaryBuf[11] := '~';
	   TemporaryBuf[12] := '~';
	  end;

	 end;

       end;

 end;
