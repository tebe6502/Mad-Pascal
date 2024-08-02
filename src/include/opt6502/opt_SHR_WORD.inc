
procedure opt_SHR_WORD;
var m, k: integer;
begin

// -----------------------------------------------------------------------------
// ===				     SHR_WORD.
// -----------------------------------------------------------------------------

	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

      if k < 0 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);
	 listing[l+6] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 listing[l+7] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+8] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+10] := #9'lsr ' + GetARG(1, x-1);
	 listing[l+11] := #9'ror @';

	 listing[l+12] := #9'dey';
	 listing[l+13] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+14] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+15] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 16);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

     end else
     if k > 15 then begin

	s[x-1, 0] := #9'mva #$00';
	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(1, x-1);
	listing[l+3] := #9'sta '+GetARG(1, x-1);
	listing[l+4] := #9'lda '+GetARG(2, x-1);
	listing[l+5] := #9'sta '+GetARG(2, x-1);
	listing[l+6] := #9'lda '+GetARG(3, x-1);
	listing[l+7] := #9'sta '+GetARG(3, x-1);

	inc(l, 8);

     end else

     if k = 9 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+2] := #9'sta ' + GetARG(0, x-1);

	inc(l, 3);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 10 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+3] := #9'sta ' + GetARG(0, x-1);

	inc(l, 4);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 11 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+4] := #9'sta ' + GetARG(0, x-1);

	inc(l, 5);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 12 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+5] := #9'sta ' + GetARG(0, x-1);

	inc(l, 6);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 13 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	listing[l+5] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+6] := #9'sta ' + GetARG(0, x-1);

	inc(l, 7);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 14 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'lsr @';
	listing[l+2] := #9'lsr @';
	listing[l+3] := #9'lsr @';
	listing[l+4] := #9'lsr @';
	listing[l+5] := #9'lsr @';
	listing[l+6] := #9'lsr @';
	s[x-1][0] := '';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 15 then begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'asl @';
	s[x-1][0] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'rol @';
	listing[l+4] := #9'sta ' + GetARG(0, x-1);

	inc(l, 5);

	s[x-1, 1] := #9'mva #$00';
	s[x-1, 2] := #9'mva #$00';
	s[x-1, 3] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else

     if k = 8 then begin
	listing[l]   := #9'lda ' + GetARG(1, x-1);
	s[x-1][0] := '';
	listing[l+1] := #9'sta ' + GetARG(0, x-1);

	inc(l, 2);

	s[x-1, 1] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

     end else begin

	listing[l]   := #9'lda ' + GetARG(1, x-1);
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda ' + GetARG(0, x-1);

	inc(l, 3);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'lsr ' + GetARG(1, x-1);
	listing[l+1] := #9'ror @';

	inc(l, 2);
       end;

	listing[l]   := #9'sta ' + GetARG(0, x-1);
	listing[l+1] := #9'lda ' + GetARG(1, x-1);
	listing[l+2] := #9'sta ' + GetARG(1, x-1);

	inc(l, 3);

	listing[l]   := #9'lda '+GetARG(2, x-1);
	listing[l+1] := #9'sta '+GetARG(2, x-1);
	listing[l+2] := #9'lda '+GetARG(3, x-1);
	listing[l+3] := #9'sta '+GetARG(3, x-1);

	inc(l, 4);

     end;

end;
