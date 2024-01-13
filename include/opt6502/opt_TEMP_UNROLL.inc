
// -----------------------------------------------------------------------------
// ===				      UNROLL.
// -----------------------------------------------------------------------------

procedure opt_TEMP_UNROLL;
var p: integer;


   function STA_ADR(i: integer): Boolean;
   begin
     Result :=  (pos(',y', TemporaryBuf[i]) > 0) and (pos(#9'sta adr.', TemporaryBuf[i]) = 1) or ((pos(#9'sta ', TemporaryBuf[i]) = 1) and (pos('.adr.', TemporaryBuf[i]) > 0));
   end;


begin

  if ((TemporaryBuf[3] = '+++unroll+++') or (TemporaryBuf[3] = '---unroll---'))	and	//+++unroll+++|---unroll---		; 3
     (pos('ldy #', TemporaryBuf[4]) > 0) and						// ldy #				; 4
     (pos('sty ', TemporaryBuf[5]) > 0) and						// sty I				; 5

     (pos('ldy ', TemporaryBuf[0]) > 0) and						// ldy I				; 0
     (pos('lda ', TemporaryBuf[1]) > 0) and						// lda					; 1
     sta_adr(2) then									// sta adr.TAB,y			; 2
   if (copy(TemporaryBuf[0], 6, 256) = copy(TemporaryBuf[5], 6, 256)) then
   begin
     if TemporaryBuf[3] = '+++unroll+++' then
      p:=GetBYTE(4) - 1
     else
      p:=GetBYTE(4) + 1;

     delete(TemporaryBuf[2], pos(',y', TemporaryBuf[2]), 2);
     TemporaryBuf[2] := TemporaryBuf[2] + '+$' + IntToHex(p, 2);

     TemporaryBuf[0] := '~';
   end;


  if ((TemporaryBuf[3] = '+++unroll+++') or (TemporaryBuf[3] = '---unroll---'))	and	//+++unroll+++|---unroll---		; 3
     (pos('ldy #', TemporaryBuf[4]) > 0) and						// ldy #				; 4
     (pos('sty ', TemporaryBuf[5]) > 0) and						// sty I				; 5

     (pos('lda ', TemporaryBuf[0]) > 0) and						// lda					; 0
     (pos('ldy ', TemporaryBuf[1]) > 0) and						// ldy I				; 1
     sta_adr(2) then									// sta adr.TAB,y			; 2
   if (copy(TemporaryBuf[1], 6, 256) = copy(TemporaryBuf[5], 6, 256)) then
   begin
     if TemporaryBuf[3] = '+++unroll+++' then
      p:=GetBYTE(4) - 1
     else
      p:=GetBYTE(4) + 1;

     delete(TemporaryBuf[2], pos(',y', TemporaryBuf[2]), 2);
     TemporaryBuf[2] := TemporaryBuf[2] + '+$' + IntToHex(p, 2);

     TemporaryBuf[1] := '~';
   end;


  if ((TemporaryBuf[5] = '+++unroll+++') or (TemporaryBuf[5] = '---unroll---'))	and	//+++unroll+++|---unroll---		; 5
     (pos('ldy #', TemporaryBuf[6]) > 0) and						// ldy #				; 6
     (pos('sty ', TemporaryBuf[7]) > 0) and						// sty I				; 7

     (pos('lda ', TemporaryBuf[0]) > 0) and						// lda					; 0
     ((pos('add ', TemporaryBuf[1]) > 0) or (pos('sub ', TemporaryBuf[1]) > 0)) and	// add|sub I				; 1
     (TemporaryBuf[2] = #9'tay') and							// tay					; 2
     (pos('lda ', TemporaryBuf[3]) > 0) and						// lda					; 3
     sta_adr(4) then									// sta adr.TAB,y			; 4
   if (copy(TemporaryBuf[1], 6, 256) = copy(TemporaryBuf[7], 6, 256)) then
   begin
     if TemporaryBuf[5] = '+++unroll+++' then
      p:=GetBYTE(6) - 1
     else
      p:=GetBYTE(6) + 1;

     delete(TemporaryBuf[4], pos(',y', TemporaryBuf[4]), 2);
     TemporaryBuf[4] := TemporaryBuf[4] + '+$' + IntToHex(p, 2) + ',y';

     TemporaryBuf[0] := #9'ldy ' + copy(TemporaryBuf[0], 6, 256);
     TemporaryBuf[1] := '~';
     TemporaryBuf[2] := '~';
   end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


  if (TemporaryBuf[0] = '---unroll---') or (TemporaryBuf[0] = '+++unroll+++') or (TemporaryBuf[0] = '===unroll===') then
   begin

    TemporaryBuf[0] := '~';

    if (pos('ldy #', TemporaryBuf[1]) > 0) and						// ldy #				; 1
       (pos('sty ', TemporaryBuf[2]) > 0) and						// sty I				; 2
       (pos('ldy ', TemporaryBuf[3]) > 0) and						// ldy I				; 3
       (pos('lda ', TemporaryBuf[4]) > 0) and						// lda					; 4
       sta_adr(5) and									// sta adr.TAB,y			; 5
       (TemporaryBuf[6] = '===unroll===') then						//===unroll===				; 6
     if (copy(TemporaryBuf[2], 6, 256) = copy(TemporaryBuf[3], 6, 256)) then
	begin
	 p:=GetBYTE(1);

	 delete(TemporaryBuf[5], pos(',y', TemporaryBuf[5]), 2);
	 TemporaryBuf[5] := TemporaryBuf[5] + '+$' + IntToHex(p, 2);

	 TemporaryBuf[1] := '~';
	 TemporaryBuf[2] := '~';
	 TemporaryBuf[3] := '~';
	 TemporaryBuf[4] := '~';
	end;


    if (pos('ldy #', TemporaryBuf[1]) > 0) and						// ldy #				; 1
       (pos('sty ', TemporaryBuf[2]) > 0) and						// sty I				; 2
       (pos('lda ', TemporaryBuf[3]) > 0) and						// lda					; 3
       (pos('ldy ', TemporaryBuf[4]) > 0) and						// ldy I				; 4
       sta_adr(5) and									// sta adr.TAB,y			; 5
       (TemporaryBuf[6] = '===unroll===') then						//===unroll===			; 6
     if (copy(TemporaryBuf[2], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
	begin
	 p:=GetBYTE(1);

	 delete(TemporaryBuf[5], pos(',y', TemporaryBuf[5]), 2);
	 TemporaryBuf[5] := TemporaryBuf[5] + '+$' + IntToHex(p, 2);

	 TemporaryBuf[1] := '~';
	 TemporaryBuf[2] := '~';
	 TemporaryBuf[3] := '~';
	 TemporaryBuf[4] := '~';
	end;


    if (pos('ldy #', TemporaryBuf[1]) > 0) and						// ldy #				; 1
       (pos('sty ', TemporaryBuf[2]) > 0) and						// sty I				; 2
       (pos('lda ', TemporaryBuf[3]) > 0) and						// lda					; 3
       ((pos('add ', TemporaryBuf[4]) > 0) or (pos('sub ', TemporaryBuf[4]) > 0)) and	// add|sub I				; 4
       (TemporaryBuf[5] = #9'tay') and							// tay					; 5
       (pos('lda ', TemporaryBuf[6]) > 0) and						// lda					; 6
       sta_adr(7) and									// sta adr.TAB,y			; 7
       (TemporaryBuf[8] = '===unroll===') then						//===unroll===				; 8
     if (copy(TemporaryBuf[2], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
	begin
	 p:=GetBYTE(1);

	 delete(TemporaryBuf[7], pos(',y', TemporaryBuf[7]), 2);
	 TemporaryBuf[7] := TemporaryBuf[7] + '+$' + IntToHex(p, 2) + ',y';

	 TemporaryBuf[1] := '~';
	 TemporaryBuf[2] := '~';
	 TemporaryBuf[3] := '~';
	 TemporaryBuf[4] := '~';
	 TemporaryBuf[5] := '~';
	 TemporaryBuf[6] := '~';
	end;

{

    if (pos('ldy #', TemporaryBuf[1]) > 0) and						// ldy #				; 1
       (pos('sty ', TemporaryBuf[2]) > 0) and						// sty I				; 2
       (pos('lda ', TemporaryBuf[3]) > 0) and						// lda A				; 3
       (pos('add ', TemporaryBuf[4]) > 0) and						// add I				; 4
       (TemporaryBuf[5] = #9'tay') and							// tay					; 5
       (pos('lda ', TemporaryBuf[6]) > 0) and						// lda A+1				; 6
       (pos('adc ', TemporaryBuf[7]) > 0) and						// adc I+1				; 7
       (TemporaryBuf[8] = #9'sta :bp+1') and						// sta :bp+1				; 8
       (pos('lda ', TemporaryBuf[9]) > 0) and						// lda					; 9
       (TemporaryBuf[10] = #9'sta (:bp),y') and						// sta (:bp),y				; 10
       (TemporaryBuf[11] = '===unroll===') then						//===unroll===-				; 11
     if (copy(TemporaryBuf[2], 6, 256) = copy(TemporaryBuf[4], 6, 256)) then
	begin
	 TemporaryBuf[4] := #9'add ' + copy(TemporaryBuf[1], 6, 256);

	 TemporaryBuf[7] := #9'adc #$00';

	 TemporaryBuf[1] := '~';
	 TemporaryBuf[2] := '~';
	end;
}


   end;	//---unroll---


end;		// function