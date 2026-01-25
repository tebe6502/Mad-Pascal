
procedure opt_SHR_CARD;
var m, k: integer;
begin

// -----------------------------------------------------------------------------
// ===				    SHR_CARDINAL.
// -----------------------------------------------------------------------------

	t:='';

	k := GetVAL(GetARG(0, x, false));

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
	 listing[l+10] := #9'lsr ' + GetARG(3, x-1);
	 listing[l+11] := #9'ror ' + GetARG(2, x-1);
	 listing[l+12] := #9'ror ' + GetARG(1, x-1);
	 listing[l+13] := #9'ror @';

	 listing[l+14] := #9'dey';
	 listing[l+15] := #9'bne l_' + IntToHex(ShrShlCnt, 4) + '_b';
	 listing[l+16] := 'l_' + IntToHex(ShrShlCnt, 4) + '_e';

	 listing[l+17] := #9'sta ' + GetARG(0, x-1);

	 inc(l, 18);

	 listing[l] := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(1, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(2, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(3, x-1);

	 inc(l, 6);

	 inc(ShrShlCnt);

	end else
	if k = 13 then begin

	 listing[l]   := #9'lda ' + GetARG(1, x-1);
	 s[x-1][0]    := '';
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'lda ' + GetARG(2, x-1);
	 s[x-1][1]    := '';
	 listing[l+3] := #9'sta ' + GetARG(1, x-1);
	 listing[l+4] := #9'lda ' + GetARG(3, x-1);
	 s[x-1][2]    := '';
	 listing[l+5] := #9'sta ' + GetARG(2, x-1);

	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta ' + GetARG(3, x-1);

	 listing[l+8] := #9'asl ' + GetARG(0, x-1);
	 listing[l+9] := #9'rol ' + GetARG(1, x-1);
	 listing[l+10] := #9'rol ' + GetARG(2, x-1);
	 listing[l+11] := #9'rol ' + GetARG(3, x-1);

	 listing[l+12] := #9'asl ' + GetARG(0, x-1);
	 listing[l+13] := #9'rol ' + GetARG(1, x-1);
	 listing[l+14] := #9'rol ' + GetARG(2, x-1);
	 listing[l+15] := #9'rol ' + GetARG(3, x-1);

	 listing[l+16] := #9'asl ' + GetARG(0, x-1);
	 listing[l+17] := #9'rol ' + GetARG(1, x-1);
	 listing[l+18] := #9'rol ' + GetARG(2, x-1);
	 listing[l+19] := #9'rol ' + GetARG(3, x-1);

	 inc(l, 20);
{
	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';
}
	 listing[l]   := #9'lda '+GetARG(1, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(2, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(3, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);
	 listing[l+6] := #9'lda #$00';
	 listing[l+7] := #9'sta '+GetARG(3, x-1);

	 inc(l, 8);

	end else
	if k = 23 then begin

	 listing[l]   := #9'lda ' + GetARG(2, x-1);		// bit7 -> C
	 listing[l+1] := #9'asl @';
	 s[x-1][0] := '';
	 listing[l+2] := #9'lda ' + GetARG(3, x-1);
	 listing[l+3] := #9'rol @';
	 listing[l+4] := #9'sta ' + GetARG(0, x-1);

	 s[x-1][1] := '';
	 listing[l+5] := #9'lda #$00';
	 listing[l+6] := #9'rol @';
	 listing[l+7] := #9'sta ' + GetARG(1, x-1);

	 inc(l, 8);

	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(2, x-1);
	 listing[l+1] := #9'sta '+GetARG(2, x-1);
	 listing[l+2] := #9'lda '+GetARG(3, x-1);
	 listing[l+3] := #9'sta '+GetARG(3, x-1);

	 inc(l, 4);

	end else
	if k = 27 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
	 s[x-1, 0] := '';
	 listing[l+1] := #9'lsr @';
	 listing[l+2] := #9'lsr @';
	 listing[l+3] := #9'lsr @';
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

	 inc(l, 6);

	end else
	if k = 31 then begin

	 listing[l]   := #9'lda ' + GetARG(3, x-1);
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

	end else begin

	m := k div 8;
	k := k mod 8;

	if m > 3 then begin

	 k:=0;

	 listing[l]   := #9'lda #$00';
	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 listing[l+2] := #9'sta ' + GetARG(1, x-1);
	 listing[l+3] := #9'sta ' + GetARG(2, x-1);
	 listing[l+4] := #9'sta ' + GetARG(3, x-1);

	 inc(l, 5);
	end else
	 case m of
	   1: begin
	       listing[l]   := #9'lda ' + GetARG(1, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       listing[l+2]   := #9'lda ' + GetARG(2, x-1);
	       s[x-1][1] := '';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);

	       listing[l+4]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][2] := '';
	       listing[l+5] := #9'sta ' + GetARG(2, x-1);

	       listing[l+6] := #9'lda #$00';
	       listing[l+7] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 8);
	      end;

	   2: begin
	       listing[l]   := #9'lda ' + GetARG(2, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       listing[l+2]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][1] := '';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);

	       listing[l+4] := #9'lda #$00';
	       listing[l+5] := #9'sta ' + GetARG(2, x-1);
	       listing[l+6] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 7);
	      end;

	   3: begin
	       listing[l]   := #9'lda ' + GetARG(3, x-1);
	       s[x-1][0] := '';
	       listing[l+1] := #9'sta ' + GetARG(0, x-1);

	       s[x-1][1] := '';
	       s[x-1][2] := '';
	       s[x-1][3] := '';

	       listing[l+2] := #9'lda #$00';
	       listing[l+3] := #9'sta ' + GetARG(1, x-1);
	       listing[l+4] := #9'sta ' + GetARG(2, x-1);
	       listing[l+5] := #9'sta ' + GetARG(3, x-1);

	       inc(l, 6);
	      end;

	   end;

	if k > 0 then begin

	  if m = 0 then begin

	   listing[l]   := #9'lda ' + GetARG(0, x-1);
	   listing[l+1] := #9'sta ' + GetARG(0, x-1);
	   listing[l+2] := #9'lda ' + GetARG(1, x-1);
	   listing[l+3] := #9'sta ' + GetARG(1, x-1);
	   listing[l+4] := #9'lda ' + GetARG(2, x-1);
	   listing[l+5] := #9'sta ' + GetARG(2, x-1);
	   listing[l+6] := #9'lda ' + GetARG(3, x-1);
	   listing[l+7] := #9'sta ' + GetARG(3, x-1);

	   inc(l, 8);
	  end;

	  for m := 0 to k - 1 do begin

	    listing[l]   := #9'lsr ' + GetARG(3, x-1);
	    listing[l+1] := #9'ror ' + GetARG(2, x-1);
	    listing[l+2] := #9'ror ' + GetARG(1, x-1);
	    listing[l+3] := #9'ror ' + GetARG(0, x-1);

	    inc(l, 4);
	  end;

	  listing[l]   := #9'lda ' + GetARG(0, x-1);
	  listing[l+1] := #9'sta ' + GetARG(0, x-1);
	  listing[l+2] := #9'lda ' + GetARG(1, x-1);
	  listing[l+3] := #9'sta ' + GetARG(1, x-1);
	  listing[l+4] := #9'lda ' + GetARG(2, x-1);
	  listing[l+5] := #9'sta ' + GetARG(2, x-1);
	  listing[l+6] := #9'lda ' + GetARG(3, x-1);
	  listing[l+7] := #9'sta ' + GetARG(3, x-1);

	  inc(l, 8);
	end;

	end;	// if k = 31

end;
