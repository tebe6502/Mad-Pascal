
// -----------------------------------------------------------------------------
// ===		     		      MOVE.
// -----------------------------------------------------------------------------
//
// !!! the order of tests matters !!!
//
// first _1: SOURCE_1, DEST_1, COUNT_1
// second: SOURCE, DEST, COUNT
//

procedure opt_TEMP_MOVE;


  function LOCAL_SYSTEM_MOVE(i: byte): Boolean;
  begin
    Result := (pos(#9'.LOCAL +MAIN.SYSTEM.MOVE.', TemporaryBuf[i]) = 1)
  end;

  function JSR_SYSTEM_MOVE(i: byte): Boolean;
  begin
    Result := (pos(#9'jsr SYSTEM.MOVE.', TemporaryBuf[i]) = 1)
  end;

  function STA_SYSTEM_MOVE(i: byte): Boolean;
  begin
    Result := (pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[i]) = 1)
  end;

  function SOURCE(i: byte): Boolean;
  begin
    Result := STA_SYSTEM_MOVE(i) and (pos('.SOURCE', TemporaryBuf[i]) > 0)
  end;

  function SOURCE_1(i: byte): Boolean;
  begin
    Result := STA_SYSTEM_MOVE(i) and (pos('.SOURCE+1', TemporaryBuf[i]) > 0)
  end;

  function DEST(i: byte): Boolean;
  begin
    Result := STA_SYSTEM_MOVE(i) and (pos('.DEST', TemporaryBuf[i]) > 0)
  end;

  function DEST_1(i: byte): Boolean;
  begin
    Result := STA_SYSTEM_MOVE(i) and (pos('.DEST+1', TemporaryBuf[i]) > 0)
  end;

  function COUNT(i: byte): Boolean;
  begin
    Result := STA_SYSTEM_MOVE(i) and (pos('.COUNT', TemporaryBuf[i]) > 0)
  end;

  function COUNT_1(i: byte): Boolean;
  begin
    Result := STA_SYSTEM_MOVE(i) and (pos('.COUNT+1', TemporaryBuf[i]) > 0)
  end;


begin


// -----------------------------------------------------------------------------


    if (pos('@move ":bp2" ', TemporaryBuf[4]) > 1) and					// @move ":bp2"				; 4

       lda(0) and									// lda A				; 0
       sta_bp2(1) and									// sta :bp2				; 1
       (TemporaryBuf[2] = TemporaryBuf[0] + '+1') and					// lda A+1				; 2
       sta_bp2_1(3) then								// sta :bp2+1				; 3
       begin
	TemporaryBuf[4] := #9'@move ' + GetSTRING(0) + ' ' +  copy(TemporaryBuf[4], 15, 256);

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
	TemporaryBuf[3] := '~';
       end;


    if (pos('mva:rpl (:bp2),y ', TemporaryBuf[5]) > 1) and				// mva:rpl (:bp2),y			; 5

       lda_im(0) and									// lda #				; 0
       sta_bp2(1) and									// sta :bp2				; 1
       lda_im(2) and									// lda #				; 2
       sta_bp2_1(3) and									// sta :bp2+1				; 3
       ldy_im(4) then									// ldy #				; 4
       begin
	p := GetWORD(0, 2);

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
	TemporaryBuf[3] := '~';

	TemporaryBuf[5] := #9'mva:rpl ' + HexWord(p) + ',y ' +  copy(TemporaryBuf[5], 19, 256);
       end;


    if (pos('mva:rne (:bp2),y ', TemporaryBuf[5]) > 1) and				// mva:rne (:bp2),y			; 5

       lda_im(0) and									// lda #				; 0
       sta_bp2(1) and									// sta :bp2				; 1
       lda_im(2) and									// lda #				; 2
       sta_bp2_1(3) and									// sta :bp2+1				; 3
       ldy_im(4) then									// ldy #				; 4
       begin
	p := GetWORD(0, 2);

	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
	TemporaryBuf[2] := '~';
	TemporaryBuf[3] := '~';

	TemporaryBuf[5] := #9'mva:rne ' + HexWord(p) + ',y ' +  copy(TemporaryBuf[5], 19, 256);
       end;


// -----------------------------------------------------------------------------


    if (TemporaryBuf[0] = #9'lda :STACKORIGIN,x') and					// lda :STACKORIGIN,x			; 0
       sta(1) and									// sta F				; 1
       (TemporaryBuf[2] = #9'lda :STACKORIGIN+STACKWIDTH,x') and			// lda :STACKORIGIN+STACKWIDTH,x	; 2
       sta(3) and									// sta F+1				; 3
       dex(4) and									// dex					; 2
       (TemporaryBuf[5] = ':move') then							//:move					; 3
       begin

	tmp := TemporaryBuf[6];
	p := StrToInt(TemporaryBuf[7]);

	if p = 256 then begin
	 TemporaryBuf[1] := #9'sta :bp2';
	 TemporaryBuf[3] := #9'sta :bp2+1';

     	 TemporaryBuf[4] := #9'ldy #$00';
     	 TemporaryBuf[5] := #9'mva:rne (:bp2),y adr.' + tmp + ',y+';
    	end else
    	if p <= 128 then begin
	 TemporaryBuf[1] := #9'sta :bp2';
	 TemporaryBuf[3] := #9'sta :bp2+1';

	 TemporaryBuf[4] := #9'ldy #' + HexByte(p-1);
     	 TemporaryBuf[5] := #9'mva:rpl (:bp2),y adr.' + tmp + ',y-';
    	end else begin
     	 TemporaryBuf[4] := #9'@move ' + tmp + ' #adr.' + tmp + ' #' + Hex(p,2);
     	 TemporaryBuf[5] := '~';
	end;

     	TemporaryBuf[6] := '~';//' #9'mwa #adr.'+tmp+' '+tmp;
     	TemporaryBuf[7] := #9'dex';
       end;


// -----------------------------------------------------------------------------


if JSR_SYSTEM_MOVE(11) or (LOCAL_SYSTEM_MOVE(11) and mINLINE(12) and ENDL(13)) then
   begin

    if SOURCE_1(2) and
       SOURCE(1) and
       DEST_1(6) and
       DEST(4) and
       COUNT_1(10) and
       COUNT(8) and

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

	if (k > 0) and (k <= 256) and not( ((p >= q) and (p < q+k)) or ((p+k > q) and (p+k <= q+k)) ) then begin

	  if k <= 16 then begin

	   TemporaryBuf[10] := #9':' + IntToStr(k) + ' mva ' + Hex(p, 4) + '+# ' + Hex(q, 4) + '+#';
	   TemporaryBuf[11] := '';

	  end else
	  if k <= 128 then begin

	  TemporaryBuf[10] := #9'ldy #' + HexByte(k-1);
	  TemporaryBuf[11] := #9'mva:rpl ' + Hex(p, 4) + ',y ' + Hex(q, 4) + ',y-';

	  end else begin

	  TemporaryBuf[10] := #9'ldy #256-'+IntToStr(k);
	  TemporaryBuf[11] := #9'mva:rne ' + Hex(p, 4) + '+' + IntToStr(k) + '-256,y ' + Hex(q, 4) + '+' + IntToStr(k) + '-256,y+';
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

          if mINLINE(12) then begin
	   TemporaryBuf[12] := '~';
	   TemporaryBuf[13] := '~';
	  end;

	 end;

       end;

end;


 if JSR_SYSTEM_MOVE(12) or (LOCAL_SYSTEM_MOVE(12) and mINLINE(13) and ENDL(14)) then
   begin

    if SOURCE_1(3) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       SOURCE(1) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[1]) = 1) and (pos('.SOURCE', TemporaryBuf[1]) > 0) and
       DEST_1(7) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       DEST(5) and     //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       COUNT_1(11) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       COUNT(9) and    //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and

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

	    TemporaryBuf[11] := #9':' + IntToStr(k) + ' mva ' + Hex(p, 4) + '+# ' + Hex(q, 4) + '+#';
	    TemporaryBuf[12] := '';

	  end else
	  if k <= 128 then begin

	    TemporaryBuf[11] := #9'ldy #' + HexByte(k-1);
	    TemporaryBuf[12] := #9'mva:rpl ' + Hex(p, 4) + ',y ' + Hex(q, 4) + ',y-';

	  end else begin

	    TemporaryBuf[11] := #9'ldy #256-'+IntToStr(k);
	    TemporaryBuf[12] := #9'mva:rne ' + Hex(p, 4) + '+' + IntToStr(k) + '-256,y ' + Hex(q, 4) + '+' + IntToStr(k) + '-256,y+';

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

          if mINLINE(13) then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	 end;

       end;


    if SOURCE_1(3) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       SOURCE(1) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[1]) = 1) and (pos('.SOURCE', TemporaryBuf[1]) > 0) and
       DEST_1(7) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       DEST(5) and     //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       COUNT_1(11) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       COUNT(9) and    //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and

       lda(0) and (lda_im(0) = false) and
       lda(2) and (lda_im(2) = false) and
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
	  TemporaryBuf[4] := #9'ldy #' + HexByte(k-1);
	  TemporaryBuf[5] := #9'mva:rpl (:bp2),y ' + Hex(q, 4) + ',y-';

	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if mINLINE(13) then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;


    if DEST_1(7) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       DEST(5) and     //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       COUNT_1(11) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       COUNT(9) and    //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       SOURCE_1(3) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       SOURCE(0) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[0]) = 1) and (pos('.SOURCE', TemporaryBuf[0]) > 0) and

       iny(1) and
       lda_bp2_y(2) and
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
	  TemporaryBuf[4] := #9'ldy #' + HexByte(k-1);
	  TemporaryBuf[5] := #9'mva:rpl (:TMP),y ' + Hex(q, 4) + ',y-';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if mINLINE(13) then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;


    if SOURCE_1(7) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.SOURCE+1', TemporaryBuf[7]) > 0) and
       SOURCE(5) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.SOURCE', TemporaryBuf[5]) > 0) and
       COUNT_1(11) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       COUNT(9) and    //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       DEST_1(3) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.DEST+1', TemporaryBuf[3]) > 0) and
       DEST(0) and     //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[0]) = 1) and (pos('.DEST', TemporaryBuf[0]) > 0) and

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
	  TemporaryBuf[4] := #9'ldy #' + HexByte(k-1);
	  TemporaryBuf[5] := #9'mva:rpl ' + Hex(p, 4) + ',y (:bp2),y-';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if mINLINE(13) then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;


    if DEST_1(7) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[7]) = 1) and (pos('.DEST+1', TemporaryBuf[7]) > 0) and
       DEST(5) and     //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[5]) = 1) and (pos('.DEST', TemporaryBuf[5]) > 0) and
       COUNT_1(11) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[11]) = 1) and (pos('.COUNT+1', TemporaryBuf[11]) > 0) and
       COUNT(9) and    //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[9]) = 1) and (pos('.COUNT', TemporaryBuf[9]) > 0) and
       SOURCE_1(3) and //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[3]) = 1) and (pos('.SOURCE+1', TemporaryBuf[3]) > 0) and
       SOURCE(0) and   //(pos(#9'sta SYSTEM.MOVE.', TemporaryBuf[0]) = 1) and (pos('.SOURCE', TemporaryBuf[0]) > 0) and

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
	  TemporaryBuf[4] := #9'ldy #' + HexByte(k-1);
	  TemporaryBuf[5] := #9'mva:rpl (:bp2),y ' + Hex(q, 4) + ',y-';
	  TemporaryBuf[6] := '~';
	  TemporaryBuf[7] := '~';
	  TemporaryBuf[8] := '~';
	  TemporaryBuf[9] := '~';
	  TemporaryBuf[10] := '~';
	  TemporaryBuf[11] := '~';
	  TemporaryBuf[12] := '~';

          if mINLINE(13) then begin
	   TemporaryBuf[13] := '~';
	   TemporaryBuf[14] := '~';
	  end;

	end;

       end;

end;

end;	// procedure
