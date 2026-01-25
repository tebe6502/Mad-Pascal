
function opt_SHR_BYTE: Boolean;
var m, k: integer;
begin

// -----------------------------------------------------------------------------
// ===				    SHR_BYTE.
// -----------------------------------------------------------------------------

	t:='';

	k := GetVAL(GetARG(0, x));

	if k < 0 then exit(true);

	Result:=false;


	if k > 7 then begin

	 s[x-1, 0] := #9'mva #$00';
	 s[x-1, 1] := #9'mva #$00';
	 s[x-1, 2] := #9'mva #$00';
	 s[x-1, 3] := #9'mva #$00';

	 listing[l]   := #9'lda '+GetARG(0, x-1);
	 listing[l+1] := #9'sta '+GetARG(0, x-1);
	 listing[l+2] := #9'lda '+GetARG(1, x-1);
	 listing[l+3] := #9'sta '+GetARG(1, x-1);
	 listing[l+4] := #9'lda '+GetARG(2, x-1);
	 listing[l+5] := #9'sta '+GetARG(2, x-1);
	 listing[l+6] := #9'lda '+GetARG(3, x-1);
	 listing[l+7] := #9'sta '+GetARG(3, x-1);

	 inc(l, 8);

	end else begin

	 listing[l] := #9'lda ' + GetARG(0, x-1);
	 inc(l);

	 for m := 0 to k - 1 do begin
	  listing[l] := #9'lsr @';
	  inc(l);
	 end;

	 listing[l] := #9'sta '+GetARG(0, x-1);
	 inc(l);
{
	s[x-1, 1] := '';//#9'mva #$00';
	s[x-1, 2] := '';//#9'mva #$00';
	s[x-1, 3] := '';//#9'mva #$00';

	listing[l]   := #9'lda '+GetARG(1, x-1);
	listing[l+1] := #9'sta '+GetARG(1, x-1);

	listing[l+2] := #9'lda '+GetARG(2, x-1);
	listing[l+3] := #9'sta '+GetARG(2, x-1);
	listing[l+4] := #9'lda '+GetARG(3, x-1);
	listing[l+5] := #9'sta '+GetARG(3, x-1);

	inc(l, 2);
}
	end;

end;
