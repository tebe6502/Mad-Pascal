
// -----------------------------------------------------------------------------
// ===				   SYSTEM.PEEK.
// -----------------------------------------------------------------------------

function system_peek: Boolean;
var a1,a2: String;
var v1,v2: Integer;
var w: Word;
begin

	Result := false;

	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) then begin
          a1 := GetARG(0, x);
          a2 := GetARG(1, x);

	  listing[l]   := #9'ldy '+a2;
	  listing[l+1] := #9'sty :bp+1';
	  listing[l+2] := #9'ldy '+a1;
	  listing[l+3] := #9'lda (:bp),y';
	  listing[l+4] := #9'sta '+a1;

	  inc(l,5);
	end else begin

          a1 := GetARG(0, x);
          a2 := GetARG(1, x);
          v1 := GetVAL(a1);
          v2 := GetVAL(a2);
          if (v1 < 0) or (v1 > $FF)
          or (v2 < 0) or (v2 > $FF) then exit(true);

          w := (v2 shl 8) + v1;

	  listing[l]   := #9'lda ' + HexWord(w);
	  listing[l+1] := #9'sta ' + a1;

	  inc(l, 2);

	end;

end;


// -----------------------------------------------------------------------------
// ===				   SYSTEM.DPEEK.
// -----------------------------------------------------------------------------

function system_dpeek: Boolean;
var a1,a2: String;
var v1,v2: Integer;
var w: Word;
begin

	Result := false;

	t:='';

	if (GetVAL(GetARG(0, x, false)) < 0) or (GetVAL(GetARG(1, x, false)) < 0) then begin
          a1 := GetARG(0, x);
          a2 := GetARG(1, x);
	  listing[l]   := #9'lda '+a1;
	  listing[l+1] := #9'sta :bp2';
	  listing[l+2] := #9'lda '+a2;
	  listing[l+3] := #9'sta :bp2+1';
	  listing[l+4] := #9'ldy #$00';
	  listing[l+5] := #9'lda (:bp2),y';
	  listing[l+6] := #9'sta '+a1;
	  listing[l+7] := #9'iny';
	  listing[l+8] := #9'lda (:bp2),y';
	  listing[l+9] := #9'sta '+a2;

	  inc(l, 10);
	end else begin
          a1 := GetARG(0, x);
          a2 := GetARG(1, x);
          v1 := GetVAL(a1);
          v2 := GetVAL(a2);
          if (v1 < 0) or (v1 > $FF)
          or (v2 < 0) or (v2 > $FF) then exit(true);

	  w := (v2 shl 8) + v1;

	  listing[l]   := #9'lda ' + HexWord(w);
	  listing[l+1] := #9'sta ' + a1;
	  listing[l+2] := #9'lda ' + HexWord(w)+'+1';
	  listing[l+3] := #9'sta ' + a2;

	  inc(l, 4);
	end;

end;

