
// -----------------------------------------------------------------------------
// ===				   SYSTEM.POKE.
// -----------------------------------------------------------------------------

function system_poke: Boolean;
var v1,v2: Integer;
var w: Word;
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
	  if (k < 0) or (k > $FF) then exit(true);

	  listing[l]   := #9'lda #' + HexByte(Byte(k));

          v1 := GetVAL(GetARG(0, x));
          v2 := GetVAL(GetARG(1, x));
       	  if (v1 < 0) or (v1 > $FF) then exit(true);
      	  if (v2 < 0) or (v2 > $FF) then exit(true);

	  w := (v2 shl 8) + v1;

	  listing[l+1] := #9'sta ' + HexWord(w);

	  inc(l, 2);
	end;

	dec(x, 2);

end;


// -----------------------------------------------------------------------------
// ===				   SYSTEM.DPOKE.
// -----------------------------------------------------------------------------

function system_dpoke: Boolean;
var v1,v2: Integer;
var w: Word;
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
	  if (k < 0) or (k>$FF) then exit(true);
	  listing[l]   := #9'lda #' + HexByte(Byte(k));

	  k := GetVAL(GetARG(1, x-1));
          if (k < 0) or (k>$FF) then exit(true);
	  listing[l+2] := #9'lda #' + HexByte(Byte(k));

	  v1 := GetVAL(GetARG(0, x));
          if (v1 < 0) or (v1>$FF) then exit(true);
          v2 :=  GetVAL(GetARG(1, x));
          if (v2 < 0) or (v2>$FF) then exit(true);

          w:= (v2 shl 8) + v1;
	  listing[l+1] := #9'sta ' + HexWord(w);
	  listing[l+3] := #9'sta ' + HexWord(w)+'+1';

	  inc(l, 4);
	end;

	dec(x, 2);

end;

