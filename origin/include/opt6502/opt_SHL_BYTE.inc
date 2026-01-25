
procedure opt_SHL_BYTE;
var k,m: integer;
begin

	t:='';

	k := GetVAL(GetARG(0, x, false));

	s[x-1][1] := '';				// !!! bez tego nie zadziala gdy 'lda adr.' !!!
	s[x-1][2] := '';
	s[x-1][3] := '';

	inc(l, 2);


	if k > 31 then begin

	s[x-1][0] := '';

	listing[l]   := #9'lda #$00';			// shl 32..
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(1, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(2, x-1);
	listing[l+6] := #9'lda #$00';
	listing[l+7] := #9'sta ' + GetARG(3, x-1);

	inc(l, 8);

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

	if k = 10 then begin

	 s[x-1][1] := #9'mva #$00';
	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2]   := #9'lda ' + GetARG(2, x-1);
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

	 s[x-1][1] := #9'mva #$00';
	 s[x-1][2] := #9'mva #$00';
	 s[x-1][3] := #9'mva #$00';

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2]   := #9'lda ' + GetARG(2, x-1);
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

	if k in [12..15] then begin			// shl 14 -> (shl 16) shr 2

	k:=16-k;

	listing[l]   := #9'lda #$00';			// shl 16
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
	listing[l+6] := #9'lda ' + GetARG(0, x-1);
	listing[l+7] := #9'sta ' + GetARG(2, x-1);
	listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

	inc(l, 10);

	  for m := 0 to k-1 do begin			// shr 2

	    listing[l]   := #9'lsr ' + GetARG(2, x-1);
	    listing[l+1] := #9'ror @';

	    inc(l, 2);
	  end;

	  listing[l]   := #9'sta ' + GetARG(1, x-1);
	  listing[l+1] := #9'lda ' + GetARG(2, x-1);
	  listing[l+2] := #9'sta ' + GetARG(2, x-1);

          s[x-1][3] := #9'mva #$00';

          listing[l+3] := #9'lda ' + GetARG(3, x-1);
          listing[l+4] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 5);

	end else

	if k in [8,16,24] then begin

	listing[l]   := #9'lda #$00';
	listing[l+1] := #9'sta ' + GetARG(1, x-1);
	listing[l+2] := #9'lda #$00';
	listing[l+3] := #9'sta ' + GetARG(2, x-1);
	listing[l+4] := #9'lda #$00';
	listing[l+5] := #9'sta ' + GetARG(3, x-1);
	listing[l+6] := #9'lda ' + GetARG(0, x-1);

	 case k of
	  8: listing[l+7] := #9'sta ' + GetARG(1, x-1);
	 16: listing[l+7] := #9'sta ' + GetARG(2, x-1);
	 24: listing[l+7] := #9'sta ' + GetARG(3, x-1);
	 end;

	listing[l+8] := #9'lda #$00';
	listing[l+9] := #9'sta ' + GetARG(0, x-1);

	inc(l, 10);

	end else begin

	if (k > 7) or (k < 0) then begin

	 listing[l]   := #9'lda #$00';
	 s[x-1][3]    := '';
	 listing[l+1] := #9'sta ' + GetARG(3, x-1);
	 listing[l+2] := #9'lda #$00';
	 s[x-1][2]    := '';
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'lda #$00';
	 s[x-1][1]    := '';
	 listing[l+5] := #9'sta ' + GetARG(1, x-1);

	 inc(l, 6);

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
	 s[x-1][2] := '';
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 s[x-1][3] := '';
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

       end else begin

	s[x-1][2] := #9'mva #$00';
	s[x-1][3] := #9'mva #$00';

	listing[l]   := #9'lda ' + GetARG(0, x-1);
	listing[l+1] := #9'sta ' + GetARG(0, x-1);
	listing[l+2] := #9'lda #$00';

	inc(l, 3);

        for m := 0 to k - 1 do begin

	 listing[l]   := #9'asl ' + GetARG(0, x-1);
	 listing[l+1] := #9'rol @';

	 inc(l, 2);
        end;

        listing[l]   := #9'sta ' + GetARG(1, x-1);
        listing[l+1] := #9'lda ' + GetARG(0, x-1);
        listing[l+2] := #9'sta ' + GetARG(0, x-1);

        inc(l, 3);

       end;

      end;

end;
