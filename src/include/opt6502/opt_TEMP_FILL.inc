
// -----------------------------------------------------------------------------
// ===		     		      FILL.
// -----------------------------------------------------------------------------

procedure opt_TEMP_FILL;
var p: integer;
begin

 if (pos(#9'jsr SYSTEM.FILL', TemporaryBuf[10]) = 1) or

   ((pos(#9'.LOCAL +MAIN.SYSTEM.FILL', TemporaryBuf[10]) = 1) and
    (TemporaryBuf[11] = #9'm@INLINE') and
    (TemporaryBuf[12] = #9'.ENDL')) then begin


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.A+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[1]) = 1) and (pos('.A', TemporaryBuf[1]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.COUNT+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.COUNT', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       lda(8) and
       lda_im(0) and
       lda_im(2) and
       lda_im(4) and
       lda_im(6) then
       begin
{
	lda #					; 0		***
	sta SYSTEM.FILLCHAR.02D2.A		; 1
	lda #					; 2
	sta SYSTEM.FILLCHAR.02D2.A+1		; 3
	lda #					; 4
	sta SYSTEM.FILLCHAR.02D2.COUNT		; 5
	lda #					; 6
	sta SYSTEM.FILLCHAR.02D2.COUNT+1	; 7
	lda					; 8
	sta SYSTEM.FILLCHAR.02D2.VALUE		; 9
}
	q:=GetWORD(0, 2);		// dst
	k:=GetWORD(4, 6);		// len

	yes:=false;

	if (k = $200) or (k = $300) or (k = $400) or (k = $500) or (k = $600) or (k = $700) or (k = $800) then begin
	  TemporaryBuf[0] := TemporaryBuf[8];
	  TemporaryBuf[1] := #9'm@fill $' + IntToHex(q, 4) + ' ' + IntToStr(k div $80);

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
	if k <= 8 then begin
	  TemporaryBuf[0] := TemporaryBuf[8];
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
	  TemporaryBuf[0] := TemporaryBuf[8];
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
	  TemporaryBuf[0] := TemporaryBuf[8];
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


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[4]) = 1) and (pos('.A+1', TemporaryBuf[4]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[2]) = 1) and (pos('.A', TemporaryBuf[2]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[8]) = 1) and (pos('.COUNT+1', TemporaryBuf[8]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[6]) = 1) and (pos('.COUNT', TemporaryBuf[6]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       lda_im(1) and
       lda_im(3) and
       lda_im(5) and
       (TemporaryBuf[7] = #9'lda #$00') then
       begin
{						; 0		***
	lda #					; 1
	sta SYSTEM.FILLCHAR.02D2.A		; 2
	lda #					; 3
	sta SYSTEM.FILLCHAR.02D2.A+1		; 4
	lda #					; 5
	sta SYSTEM.FILLCHAR.02D2.COUNT		; 6
	lda #					; 7
	sta SYSTEM.FILLCHAR.02D2.COUNT+1	; 8
	sta SYSTEM.FILLCHAR.02D2.VALUE		; 9
}
	q:=GetWORD(1, 3);		// dst
	k:=GetWORD(5, 7);		// len

	yes:=false;

	if (k = $200) or (k = $300) or (k = $400) or (k = $500) or (k = $600) or (k = $700) or (k = $800) then begin
	  TemporaryBuf[0] := TemporaryBuf[7];
	  TemporaryBuf[1] := #9'm@fill $' + IntToHex(q, 4) + ' ' + IntToStr(k div $80);

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
	if k <= 8 then begin
	  TemporaryBuf[1] := TemporaryBuf[7];
	  TemporaryBuf[2] := #9':' + IntToStr(k) + ' sta $' + IntToHex(q, 4) + '+#';

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
	  TemporaryBuf[1] := TemporaryBuf[7];
	  TemporaryBuf[2] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[3] := #9'sta:rpl $' + IntToHex(q, 4) + ',y-';

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
	  TemporaryBuf[1] := TemporaryBuf[7];
	  TemporaryBuf[2] := #9'ldy #256-'+IntToStr(k);
	  TemporaryBuf[3] := #9'sta:rne $' + IntToHex(q, 4) + '+' + IntToStr(k) + '-256,y+';

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


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[4]) = 1) and (pos('.A+1', TemporaryBuf[4]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[2]) = 1) and (pos('.A', TemporaryBuf[2]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[8]) = 1) and (pos('.COUNT+1', TemporaryBuf[8]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[6]) = 1) and (pos('.COUNT', TemporaryBuf[6]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       (TemporaryBuf[7] = #9'lda #$00') and
       lda_im(5) and
       lda(1) and (lda_im(1) = false) and
       lda(3) then
       begin
{						; 0		***
	lda QBOARD				; 1
	sta SYSTEM.FILLCHAR.02D2.A		; 2
	lda QBOARD+1				; 3
	sta SYSTEM.FILLCHAR.02D2.A+1		; 4
	lda #$08				; 5
	sta SYSTEM.FILLCHAR.02D2.COUNT		; 6
	lda #$00				; 7
	sta SYSTEM.FILLCHAR.02D2.COUNT+1	; 8
	sta SYSTEM.FILLCHAR.02D2.VALUE		; 9
}
	k:=GetWORD(5, 7);		// len

	yes:=false;

	if k = 256 then begin
	  TemporaryBuf[2] := #9'sta :bp2';

	  TemporaryBuf[4] := #9'sta :bp2+1';
	  TemporaryBuf[5] := #9'ldy #$00';
	  TemporaryBuf[6] := #9'tya';
	  TemporaryBuf[7] := #9'sta:rne (:bp2),y+';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	end else
	if k <= 128 then begin
	  TemporaryBuf[2] := #9'sta :bp2';

	  TemporaryBuf[4] := #9'sta :bp2+1';
	  TemporaryBuf[5] := #9'lda #$00';
	  TemporaryBuf[6] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[7] := #9'sta:rpl (:bp2),y-';
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


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.A+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[1]) = 1) and (pos('.A', TemporaryBuf[1]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.COUNT+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.COUNT', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       lda_im(6) and
       lda_im(4) and
       lda(8) and
       lda(0) and (lda_im(0) = false) and
       lda(2) then
       begin
{
	lda					; 0		***
	sta SYSTEM.FILLBYTE.0058.A		; 1
	lda					; 2
	sta SYSTEM.FILLBYTE.0058.A+1		; 3
	lda #					; 4
	sta SYSTEM.FILLBYTE.0058.COUNT		; 5
	lda #					; 6
	sta SYSTEM.FILLBYTE.0058.COUNT+1	; 7
	lda					; 8
	sta SYSTEM.FILLBYTE.0058.VALUE		; 9
}
	k:=GetWORD(4, 6);		// len

	yes:=false;

	if k = 256 then begin
	  TemporaryBuf[1] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';
	  TemporaryBuf[4] := TemporaryBuf[8];
	  TemporaryBuf[5] := #9'ldy #$00';
	  TemporaryBuf[6] := #9'sta:rne (:bp2),y+';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	end else
	if k <= 128 then begin
	  TemporaryBuf[1] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';
	  TemporaryBuf[4] := TemporaryBuf[8];
	  TemporaryBuf[5] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[6] := #9'sta:rpl (:bp2),y-';
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


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.A+1', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.A', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.COUNT+1', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.COUNT', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[1]) = 1) and (pos('.VALUE', TemporaryBuf[1]) > 0) and
       lda_im(8) and
       lda_im(6) and
       lda(0) and
       lda(2) and (lda_im(2) = false) and
       lda(4) then
       begin
{
	lda					; 0		***
	sta SYSTEM.FILLBYTE.0058.VALUE		; 1
	lda					; 2
	sta SYSTEM.FILLBYTE.0058.A		; 3
	lda					; 4
	sta SYSTEM.FILLBYTE.0058.A+1		; 5
	lda #					; 6
	sta SYSTEM.FILLBYTE.0058.COUNT		; 7
	lda #					; 8
	sta SYSTEM.FILLBYTE.0058.COUNT+1	; 9
}
	k:=GetWORD(6, 8);		// len

	yes:=false;

	if k = 256 then begin
	  TemporaryBuf[3] := #9'sta :bp2';

	  TemporaryBuf[5] := #9'sta :bp2+1';
	  TemporaryBuf[6] := TemporaryBuf[0];
	  TemporaryBuf[7] := #9'ldy #$00';
	  TemporaryBuf[8] := #9'sta:rne (:bp2),y+';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  TemporaryBuf[0] := '~';
	  TemporaryBuf[1] := '~';

	  yes:=true;

	end else
	if k <= 128 then begin
	  TemporaryBuf[3] := #9'sta :bp2';

	  TemporaryBuf[5] := #9'sta :bp2+1';
	  TemporaryBuf[6] := TemporaryBuf[0];
	  TemporaryBuf[7] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[8] := #9'sta:rpl (:bp2),y-';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  TemporaryBuf[0] := '~';
	  TemporaryBuf[1] := '~';

	  yes:=true;

	 end;

        if yes and (TemporaryBuf[11] = #9'm@INLINE') then begin
	 TemporaryBuf[11] := '~';
	 TemporaryBuf[12] := '~';
	end;

       end;


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[2]) = 1) and (pos('.A+1', TemporaryBuf[2]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[4]) = 1) and (pos('.A', TemporaryBuf[4]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[8]) = 1) and (pos('.COUNT+1', TemporaryBuf[8]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[6]) = 1) and (pos('.COUNT', TemporaryBuf[6]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       lda_im(7) and
       lda_im(5) and
       lda(3) and (lda_im(3) = false) then
       begin
{						; 0		***
						; 1
	sta SYSTEM.FILLBYTE.0058.A+1		; 2
	lda					; 3
	sta SYSTEM.FILLBYTE.0058.A		; 4
	lda #					; 5
	sta SYSTEM.FILLBYTE.0058.COUNT		; 6
	lda #					; 7
	sta SYSTEM.FILLBYTE.0058.COUNT+1	; 8
	sta SYSTEM.FILLBYTE.0058.VALUE		; 9
}
	k:=GetWORD(5, 7);		// len

	yes:=false;

	if k = 256 then begin
	  TemporaryBuf[2] := #9'sta :bp2+1';

	  TemporaryBuf[4] := #9'sta :bp2';
	  TemporaryBuf[5] := TemporaryBuf[7];
	  TemporaryBuf[6] := #9'ldy #$00';
	  TemporaryBuf[7] := #9'sta:rne (:bp2),y+';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

	  yes:=true;

	end else
	if k <= 128 then begin
	  TemporaryBuf[2] := #9'sta :bp2+1';

	  TemporaryBuf[4] := #9'sta :bp2';
	  TemporaryBuf[5] := TemporaryBuf[7];
	  TemporaryBuf[6] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[7] := #9'sta:rpl (:bp2),y-';
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


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[8]) = 1) and (pos('.COUNT+1', TemporaryBuf[8]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[6]) = 1) and (pos('.COUNT', TemporaryBuf[6]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[4]) = 1) and (pos('.A+1', TemporaryBuf[4]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[1]) = 1) and (pos('.A', TemporaryBuf[1]) > 0) and
       lda(2) and
       (adc_sbc(3) or add_sub(3)) and
       (TemporaryBuf[7] = #9'lda #$00') and
       lda_im(5) then
       begin
{						; 0		***
	sta SYSTEM.FILLCHAR.009E.A		; 1
	lda					; 2
	add|sub|adc|sbc				; 3
	sta SYSTEM.FILLCHAR.009E.A+1		; 4
	lda #					; 5
	sta SYSTEM.FILLCHAR.009E.COUNT		; 6
	lda #					; 7
	sta SYSTEM.FILLCHAR.009E.COUNT+1	; 8
	sta SYSTEM.FILLCHAR.009E.VALUE		; 9
}
	k:=GetWORD(5, 7);		// len

	if k <= 128 then begin
	  TemporaryBuf[1] := #9'sta :bp2';

	  TemporaryBuf[4] := #9'sta :bp2+1';
	  TemporaryBuf[5] := #9'lda #$00';
	  TemporaryBuf[6] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[7] := #9'sta:rpl (:bp2),y-';

	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

          if (TemporaryBuf[11] = #9'm@INLINE') then begin
	   TemporaryBuf[11] := '~';
	   TemporaryBuf[12] := '~';
	  end;

	 end;

       end;


    if (pos(#9'sta SYSTEM.FILL', TemporaryBuf[7]) = 1) and (pos('.COUNT+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[5]) = 1) and (pos('.COUNT', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[9]) = 1) and (pos('.VALUE', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[3]) = 1) and (pos('.A+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.FILL', TemporaryBuf[0]) = 1) and (pos('.A', TemporaryBuf[0]) > 0) and
       lda(8) and
       lda(1) and
       (adc_sbc(2) or add_sub(2)) and
       lda_im(4) and
       lda_im(6) then
       begin
{
	sta SYSTEM.FILLCHAR.009E.A		; 0		***
	lda 					; 1
	add|sub|adc|sbc				; 2
	sta SYSTEM.FILLCHAR.009E.A+1		; 3
	lda #					; 4
	sta SYSTEM.FILLCHAR.009E.COUNT		; 5
	lda #					; 6
	sta SYSTEM.FILLCHAR.009E.COUNT+1	; 7
	lda 					; 8
	sta SYSTEM.FILLCHAR.009E.VALUE		; 9
}
	k:=GetWORD(4, 6);		// len

	if k <= 128 then begin
	  TemporaryBuf[0] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';

	  TemporaryBuf[4] := TemporaryBuf[8];
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

end;	// procedure
