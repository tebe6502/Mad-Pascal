
// -----------------------------------------------------------------------------
// ===		      Common head/tail Sequence coalescing
// -----------------------------------------------------------------------------
//				CASE STATEMENT
// -----------------------------------------------------------------------------

procedure opt_TEMP_TAIL_CASE;
var i, p, k: integer;
    yes: Boolean;
    lab, tmp: string;
begin

   i:=100;

   if (pos(#9'jmp a_', TemporaryBuf[i]) > 0) then			// jmp a_xxxx
    begin

      if lab_s(i+1) then TemporaryBuf[i+1]:= '~';

      tmp:=TemporaryBuf[i];			// jmp a_xxxx
      lab:=copy(tmp, 6, 256);			// a_xxxx

      yes:=false;

      for p:=i+1 to High(TemporaryBuf) do
       if (TemporaryBuf[p] = tmp) and		// jmp a_xxxx
          lab_s(p+1) then			//s_xxxx
	begin
	  yes:=true;
	  Break;
	end;


      if yes then
       if (TemporaryBuf[i-1] = TemporaryBuf[p-1]) and (sta(p-1) or jsr(p-1)) then begin

	lab:=TemporaryBuf[p+1];			//s_xxxx

	TemporaryBuf[i] := #9'jmp ' + lab;

	TemporaryBuf[p] := lab;
	TemporaryBuf[p+1] := tmp;

        for k:=1 to i-1 do
         if (TemporaryBuf[i-k] = TemporaryBuf[p-k]) or
	    (lab_l(i-k) and lab_l(p-k)) or
	    (opti(i-k) and opti(p-k)) then
	 begin

	  if (TemporaryBuf[i-k] = TemporaryBuf[p-k]) then TemporaryBuf[i-k] := '~';

	  tmp := TemporaryBuf[p-k];

	  TemporaryBuf[p-k] := TemporaryBuf[p-k+1];
	  TemporaryBuf[p-k+1] := tmp;

	 end else
	  exit;

      end;	// if yes

  end;

end;	// procedure
