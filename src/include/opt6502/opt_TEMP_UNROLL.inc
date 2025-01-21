
// -----------------------------------------------------------------------------
// ===				      UNROLL.
// -----------------------------------------------------------------------------

procedure opt_TEMP_UNROLL;
var p: integer;
begin

  if ((TemporaryBuf[3] = '+++unroll+++') or (TemporaryBuf[3] = '---unroll---'))	and	//+++unroll+++|---unroll---		; 3
     (pos('ldy #', TemporaryBuf[4]) > 0) and						// ldy #				; 4
     sty(5) and										// sty I				; 5

     ldy(0) and										// ldy I				; 0
     lda(1) and										// lda					; 1
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
     sty(5) and										// sty I				; 5

     lda(0) and										// lda					; 0
     ldy(1) and										// ldy I				; 1
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
     sty(7) and										// sty I				; 7

     lda(0) and										// lda					; 0
     add_sub(1) and									// add|sub I				; 1
     (TemporaryBuf[2] = #9'tay') and							// tay					; 2
     lda(3) and										// lda					; 3
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
       sty(2) and									// sty I				; 2
       ldy(3) and									// ldy I				; 3
       lda(4) and									// lda					; 4
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
       sty(2) and									// sty I				; 2
       lda(3) and									// lda					; 3
       ldy(4) and									// ldy I				; 4
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
       sty(2) and									// sty I				; 2
       lda(3) and									// lda					; 3
       add_sub(4) and									// add|sub I				; 4
       (TemporaryBuf[5] = #9'tay') and							// tay					; 5
       lda(6) and									// lda					; 6
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
       sty(2) and									// sty I				; 2
       lda(3) and									// lda A				; 3
       (pos('add ', TemporaryBuf[4]) > 0) and						// add I				; 4
       (TemporaryBuf[5] = #9'tay') and							// tay					; 5
       lda(6) and									// lda A+1				; 6
       (pos('adc ', TemporaryBuf[7]) > 0) and						// adc I+1				; 7
       (TemporaryBuf[8] = #9'sta :bp+1') and						// sta :bp+1				; 8
       lda(9) and									// lda					; 9
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
