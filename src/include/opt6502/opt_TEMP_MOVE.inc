
// -----------------------------------------------------------------------------
// ===		     		      MOVE.
// -----------------------------------------------------------------------------

procedure opt_TEMP_MOVE;
begin

if (pos(#9'jsr SYSTEM.MOVE.', TemporaryBuf[11]) = 1) or

   ((pos(#9'.LOCAL +MAIN.SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and
    (TemporaryBuf[12] = #9'm@INLINE') and
    (TemporaryBuf[13] = #9'.ENDL')) then begin


    if (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[2]) = 1) and (pos('.SOURCE+1', TemporaryBuf[2]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[1]) = 1) and (pos('.SOURCE', TemporaryBuf[1]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[6]) = 1) and (pos('.DEST+1', TemporaryBuf[6]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[4]) = 1) and (pos('.DEST', TemporaryBuf[4]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[10]) = 1) and (pos('.COUNT+1', TemporaryBuf[10]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[8]) = 1) and (pos('.COUNT', TemporaryBuf[8]) > 0) and
       lda_im(0) and
       lda_im(3) and
       lda_im(5) and
       lda_im(7) and
       lda_im(9) then
       begin
{
	lda #$80			; 0		***
	sta SYSTEM.MOVE.02D4.SOURCE	; 1
	sta SYSTEM.MOVE.02D4.SOURCE+1	; 2
	lda #$00			; 3
	sta SYSTEM.MOVE.02D4.DEST	; 4
	lda #$84			; 5
	sta SYSTEM.MOVE.02D4.DEST+1	; 6
	lda #$50			; 7
	sta SYSTEM.MOVE.02D4.COUNT	; 8
	lda #$00			; 9
	sta SYSTEM.MOVE.02D4.COUNT+1	; 10
}
	p:=GetWORD(0, 0);		// src
	q:=GetWORD(3, 5);		// dst
	k:=GetWORD(7, 9);		// len

	if (k>0) and (k<=256) and not( ((p>=q) and (p<q+k)) or ((p+k>q) and (p+k<=q+k)) ) then begin

	  if k <= 16 then begin

	   TemporaryBuf[10] := #9':' + IntToStr(k) + ' mva $' + IntToHex(p, 4) + '+# $' + IntToHex(q, 4) + '+#';
	   TemporaryBuf[11] := '';

	  end else
	  if k <= 128 then begin

	  TemporaryBuf[10] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[11] := #9'mva:rpl $' + IntToHex(p, 4) + ',y $' + IntToHex(q, 4) + ',y-';

	  end else begin

	  TemporaryBuf[10] := #9'ldy #256-'+IntToStr(k);
	  TemporaryBuf[11] := #9'mva:rne $' + IntToHex(p, 4) + '+' + IntToStr(k) + '-256,y $' +
	  				      IntToHex(q, 4) + '+' + IntToStr(k) + '-256,y+';
	  end;

	  TemporaryBuf[0] := '~';
	  TemporaryBuf[1] := '~';
	  TemporaryBuf[2] := '~';
	  TemporaryBuf[3] := '~';
	  TemporaryBuf[4] := '~';
	  TemporaryBuf[5] := '~';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';

          if (TemporaryBuf[12] = #9'm@INLINE') then begin
	   TemporaryBuf[12] := '~';
	   TemporaryBuf[13] := '~';
	  end;

	 end;

       end;

end;



 if (pos(#9'jsr SYSTEM.MOVE.', TemporaryBuf[12]) = 1) or

   ((pos(#9'.LOCAL +MAIN.SYSTEM.MOVE.', TemporaryBuf[12]) = 1) and
    (TemporaryBuf[13] = #9'm@INLINE') and
    (TemporaryBuf[14] = #9'.ENDL')) then begin

    if (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[1]) = 1) and (pos('.SOURCE', TemporaryBuf[1]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       lda_im(0) and
       lda_im(2) and
       lda_im(4) and
       lda_im(6) and
       lda_im(8) and
       lda_im(10) then
       begin
{
	lda #$43			; 0		***
	sta SYSTEM.MOVE.02D4.SOURCE	; 1
	lda #$00			; 2
	sta SYSTEM.MOVE.02D4.SOURCE+1	; 3
	lda #$20			; 4
	sta SYSTEM.MOVE.02D4.DEST	; 5
	lda #$00			; 6
	sta SYSTEM.MOVE.02D4.DEST+1	; 7
	lda #$05			; 8
	sta SYSTEM.MOVE.02D4.COUNT	; 9
	lda #$00			; 10
	sta SYSTEM.MOVE.02D4.COUNT+1	; 11
}
	p:=GetWORD(0, 2);		// src
	q:=GetWORD(4, 6);		// dst
	k:=GetWORD(8, 10);		// len

	if (k>0) and (k<=256) and not( ((p>=q) and (p<q+k)) or ((p+k>q) and (p+k<=q+k)) ) then begin

	  if k <= 16 then begin

	   TemporaryBuf[11] := #9':' + IntToStr(k) + ' mva $' + IntToHex(p, 4) + '+# $' + IntToHex(q, 4) + '+#';
	   TemporaryBuf[12] := '';

	  end else
	  if k <= 128 then begin

	  TemporaryBuf[11] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[12] := #9'mva:rpl $' + IntToHex(p, 4) + ',y $' + IntToHex(q, 4) + ',y-';

	  end else begin

	  TemporaryBuf[11] := #9'ldy #256-'+IntToStr(k);
	  TemporaryBuf[12] := #9'mva:rne $' + IntToHex(p, 4) + '+' + IntToStr(k) + '-256,y $' +
	  				      IntToHex(q, 4) + '+' + IntToStr(k) + '-256,y+';
	  end;

	  TemporaryBuf[0] := '~';
	  TemporaryBuf[1] := '~';
	  TemporaryBuf[2] := '~';
	  TemporaryBuf[3] := '~';
	  TemporaryBuf[4] := '~';
	  TemporaryBuf[5] := '~';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';

          if (TemporaryBuf[13] = #9'm@INLINE') then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	 end;

       end;


    if (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[1]) = 1) and (pos('.SOURCE', TemporaryBuf[1]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       (pos(#9'lda ', TemporaryBuf[0]) = 1) and (lda_im(0) = false) and
       (pos(#9'lda ', TemporaryBuf[2]) = 1) and (lda_im(2) = false) and
       lda_im(4) and
       lda_im(6) and
       lda_im(8) and
       lda_im(10) then
       begin
{
	lda DL_TITLE			; 0		***
	sta SYSTEM.MOVE.00A0.SOURCE	; 1
	lda DL_TITLE+1			; 2
	sta SYSTEM.MOVE.00A0.SOURCE+1	; 3
	lda #$00			; 4
	sta SYSTEM.MOVE.00A0.DEST	; 5
	lda #$AE			; 6
	sta SYSTEM.MOVE.00A0.DEST+1	; 7
	lda #$40			; 8
	sta SYSTEM.MOVE.00A0.COUNT	; 9
	lda #$00			; 10
	sta SYSTEM.MOVE.00A0.COUNT+1	; 11
}
	q:=GetWORD(4, 6);		// dst
	k:=GetWORD(8, 10);		// len

	if k <= 128 then begin

	  TemporaryBuf[1] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';
	  TemporaryBuf[4] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[5] := #9'mva:rpl (:bp2),y $' + IntToHex(q, 4) + ',y-';

	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if (TemporaryBuf[13] = #9'm@INLINE') then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;


    if (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[0]) = 1) and (pos('.SOURCE', TemporaryBuf[0]) > 0) and
       (TemporaryBuf[1] = #9'iny') and
       (TemporaryBuf[2] = #9'lda (:bp2),y') and
       lda_im(4) and
       lda_im(6) and
       lda_im(8) and
       lda_im(10) then
       begin
{
	sta SYSTEM.MOVE.00A0.SOURCE	; 0		***
	iny				; 1
	lda (:bp2),y			; 2
	sta SYSTEM.MOVE.00A0.SOURCE+1	; 3
	lda #$0C			; 4
	sta SYSTEM.MOVE.00A0.DEST	; 5
	lda #$CC			; 6
	sta SYSTEM.MOVE.00A0.DEST+1	; 7
	lda #$09			; 8
	sta SYSTEM.MOVE.00A0.COUNT	; 9
	lda #$00			; 10
	sta SYSTEM.MOVE.00A0.COUNT+1	; 11
}
	q:=GetWORD(4, 6);		// dst
	k:=GetWORD(8, 10);		// len

	if k <= 128 then begin

	  TemporaryBuf[0] := #9'sta :TMP';

	  TemporaryBuf[3] := #9'sta :TMP+1';
	  TemporaryBuf[4] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[5] := #9'mva:rpl (:TMP),y $' + IntToHex(q, 4) + ',y-';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if (TemporaryBuf[13] = #9'm@INLINE') then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;


    if (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.SOURCE+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.SOURCE', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.DEST+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[0]) = 1) and (pos('.DEST', TemporaryBuf[0]) > 0) and
       lda_im(4) and
       lda_im(6) and
       lda_im(8) and
       lda_im(10) then
       begin
{
	sta SYSTEM.MOVE.00A0.DEST	; 0		***
	lda DLTOP+1			; 1
	adc #$00			; 2
	sta SYSTEM.MOVE.00A0.DEST+1	; 3
	lda #$A4			; 4
	sta SYSTEM.MOVE.00A0.SOURCE	; 5
	lda #$20			; 6
	sta SYSTEM.MOVE.00A0.SOURCE+1	; 7
	lda #$0E			; 8
	sta SYSTEM.MOVE.00A0.COUNT	; 9
	lda #$00			; 10
	sta SYSTEM.MOVE.00A0.COUNT+1	; 11
}
	p:=GetWORD(4, 6);		// src
	k:=GetWORD(8, 10);		// len

	if k <= 128 then begin

	  TemporaryBuf[0] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';
	  TemporaryBuf[4] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[5] := #9'mva:rpl $' + IntToHex(p, 4) + ',y (:bp2),y-';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if (TemporaryBuf[13] = #9'm@INLINE') then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;


    if (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[0]) = 1) and (pos('.SOURCE', TemporaryBuf[0]) > 0) and
       lda_im(4) and
       lda_im(6) and
       lda_im(8) and
       lda_im(10) then
       begin
{
	sta SYSTEM.MOVE.00A0.SOURCE	; 0		***
	lda DLTOP+1			; 1
	adc #$00			; 2
	sta SYSTEM.MOVE.00A0.SOURCE+1	; 3
	lda #$00			; 4
	sta SYSTEM.MOVE.00A0.DEST	; 5
	lda #$CD			; 6
	sta SYSTEM.MOVE.00A0.DEST+1	; 7
	lda #$78			; 8
	sta SYSTEM.MOVE.00A0.COUNT	; 9
	lda #$00			; 10
	sta SYSTEM.MOVE.00A0.COUNT+1	; 11
}
	q:=GetWORD(4, 6);		// dst
	k:=GetWORD(8, 10);		// len

	if k <= 128 then begin

	  TemporaryBuf[0] := #9'sta :bp2';

	  TemporaryBuf[3] := #9'sta :bp2+1';
	  TemporaryBuf[4] := #9'ldy #$'+IntToHex(k-1, 2);
	  TemporaryBuf[5] := #9'mva:rpl (:bp2),y $' + IntToHex(q, 4) + ',y-';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if (TemporaryBuf[13] = #9'm@INLINE') then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;

end;

end;	// procedure
