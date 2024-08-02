
function opt_SHL_WORD: Boolean;
var k, m: integer;
begin
	Result:=false;

	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1][2] := '';
	s[x-1][3] := '';

        if k < 0 then begin

	 listing[l]   := #9'lda #$00';
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda #$00';
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);

	 inc(l, 4);

	 listing[l] := #9'lda ' + GetARG(1, x-1);
	 s[x-1][1]    := '';
	 listing[l+1] := #9'sta ' + GetARG(1, x-1);
	 listing[l+2] := #9'lda ' + GetARG(0, x-1);
	 s[x-1][0]    := '';

	 inc(l, 3);

	 listing[l] := #9'ldy ' + GetARG(0, x);
	 s[x][0]      := '';
	 listing[l+1] := #9'beq l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+2] := 'l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+3] := #9'asl @';
	 listing[l+4] := #9'rol ' + GetARG(1, x-1);
	 listing[l+5] := #9'rol ' + GetARG(2, x-1);
	 listing[l+6] := #9'rol ' + GetARG(3, x-1);

	 listing[l+7] := #9'dey';
	 listing[l+8] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+9] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+10] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 11);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

        end else

	if k = 16 then begin

	s[x-1][2] := '';
	s[x-1][3] := '';

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(2, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(3, x-1);

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta '+GetARG(0, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta '+GetARG(1, x-1);

	inc(l,8);

	end else
{
	if k = 15 then begin

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'lsr @';
	s[x-1][1] := '';
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'ror @';
	listing[l+4] := #9'sta ' + GetARG(1, x-1);

	inc(l, 5);

	s[x-1, 0] := #9'mva #$00';

	listing[l]   := #9'lda '+GetARG(0, x-1);
	listing[l+1] := #9'sta '+GetARG(0, x-1);
	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l,6);

	end else
}
	if k = 10 then begin

	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

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

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'sta ' + GetARG(0, x-1);

	 inc(l,14);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 11 then begin

	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

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

	 listing[l+7] := #9'asl @';
	 listing[l+8] := #9'rol ' + GetARG(1, x-1);
	 listing[l+9] := #9'rol ' + GetARG(2, x-1);

	 listing[l+10] := #9'asl @';
	 listing[l+11] := #9'rol ' + GetARG(1, x-1);
	 listing[l+12] := #9'rol ' + GetARG(2, x-1);

	 listing[l+13] := #9'asl @';
	 listing[l+14] := #9'rol ' + GetARG(1, x-1);
	 listing[l+15] := #9'rol ' + GetARG(2, x-1);

	 listing[l+16] := #9'sta ' + GetARG(0, x-1);

	 inc(l,17);

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(3, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(0, x-1);
	 listing[l+5] := #9'sta '+GetARG(1, x-1);

	 s[x-1, 0] := #9'mva #$00';

	 listing[l+6] := #9'lda '+GetARG(0, x-1);
	 listing[l+7] := #9'sta '+GetARG(0, x-1);

	 inc(l,8);

	end else

	if k = 31 then begin				// shl 31

	 listing[l]   := #9'lda ' + GetARG(0, x-1);
	 listing[l+1] := #9'lsr @';
	 s[x-1][3] := '';
	 listing[l+2] := #9'lda #$00';
	 listing[l+3] := #9'ror @';
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(2, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);

	 inc(l,6);
	end else

	if k = 8 then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(3, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda ' + GetARG(0, x-1);
	listing[l+5] := #9'sta ' + GetARG(1, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(0, x-1);

	inc(l, 8);

	end else begin

	if (k > 7) {or (k < 0)} then exit(true);

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda ' + GetARG(1, x-1);
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda #$00';

	inc(l, 5);

       for m := 0 to k - 1 do begin

	listing[l]   := #9'asl ' + GetARG(0, x-1);
	listing[l+1] := #9'rol ' + GetARG(1, x-1);
	listing[l+2] := #9'rol @';

	inc(l, 3);
       end;

       listing[l]   := #9'sta ' + GetARG(2, x-1);
       listing[l+1] := #9'lda ' + GetARG(0, x-1);
       listing[l+2] := #9'sta ' + GetARG(0, x-1);
       listing[l+3] := #9'lda ' + GetARG(1, x-1);
       listing[l+4] := #9'sta ' + GetARG(1, x-1);

       inc(l, 5);

       end;

end;
