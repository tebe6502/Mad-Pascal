
// -----------------------------------------------------------------------------
// ===				   SYSTEM.POKE.
// -----------------------------------------------------------------------------

function system_poke: Boolean;
begin

	Result := false;

	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(0, x-1, false)) < 0) or (GetVAL(GetARG(1, x-1, false)) < 0) then begin

	  listing[l]   := #9'ldy '+GetARG(1, x);
	  listing[l+1] := #9'sty :bp+1';
	  listing[l+2] := #9'ldy '+GetARG(0, x);
	  listing[l+3] := #9'lda '+GetARG(0, x-1);
	  listing[l+4] := #9'sta (:bp),y';

	  inc(l,5);
	end else begin

	  k := GetVAL(GetARG(0, x-1));
	  if (k > $FFFF) or (k < 0) then exit(true);

	  listing[l]   := #9'lda #' + HexByte(Byte(k));

	  k := GetVAL(GetARG(0, x)) + GetVAL(GetARG(1, x)) shl 8;
	  if (k > $FFFF) or (k < 0) then exit(true);

	  listing[l+1] := #9'sta ' + HexWord(Word(k));

	  inc(l, 2);
	end;

	dec(x, 2);

end;


// -----------------------------------------------------------------------------
// ===				   SYSTEM.DPOKE.
// -----------------------------------------------------------------------------

function system_dpoke: Boolean;
begin

	Result := false;

	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) or (GetVAL(GetARG(0, x-1, false)) < 0) or (GetVAL(GetARG(1, x-1, false)) < 0) then begin

	  listing[l]   := #9'lda '+GetARG(0, x);
	  listing[l+1] := #9'sta :bp2';
	  listing[l+2] := #9'lda '+GetARG(1, x);
	  listing[l+3] := #9'sta :bp2+1';
	  listing[l+4] := #9'ldy #$00';
	  listing[l+5] := #9'lda '+GetARG(0, x-1);
	  listing[l+6] := #9'sta (:bp2),y';
	  listing[l+7] := #9'iny';
	  listing[l+8] := #9'lda '+GetARG(1, x-1);
	  listing[l+9] := #9'sta (:bp2),y';

	  inc(l,10);
	end else begin

	  k := GetVAL(GetARG(0, x-1));
	  if (k > $FFFF) or (k < 0) then exit(true);
	  listing[l]   := #9'lda #' + HexByte(Byte(k));

	  k := GetVAL(GetARG(1, x-1));
	  if (k > $FFFF) or (k < 0) then exit(true);
	  listing[l+2] := #9'lda #' + HexByte(Byte(k));

	  k := GetVAL(GetARG(0, x)) + GetVAL(GetARG(1, x)) shl 8;
	  if (k > $FFFF) or (k < 0) then exit(true);

	  listing[l+1] := #9'sta ' + HexWord(Word(k));
	  listing[l+3] := #9'sta ' + HexWord(Word(k))+'+1';

	  inc(l, 4);
	end;

	dec(x, 2);

end;

