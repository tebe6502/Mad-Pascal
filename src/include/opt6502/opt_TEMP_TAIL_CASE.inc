
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

   i := 100;
   p := 0;

   if pos1(#9'jmp a_', i) then				// jmp a_xxxx
    begin

      if lab_s(i+1) then TemporaryBuf[i+1]:= '~';

      tmp:=TemporaryBuf[i];				// jmp a_xxxx
      lab:=GetARG(i);					// a_xxxx

      yes:=false;

      for p:=i+1 to High(TemporaryBuf)-1 do
       if (TemporaryBuf[p] = tmp) and			// jmp a_xxxx
          lab_s(p+1) then				//s_xxxx
	begin
	  yes:=true;
	  Break;
	end;

      yes := yes and (not (lab_a(i-3) and tya(i-2) and sta(i-1)));

      if yes then
      if (sta(p-1) or jsr(p-1)) and
         cmpBuf(i-1, p-1) and
         cmpBuf(i-2, p-2) then
      begin

	lab := TemporaryBuf[p+1];			//s_xxxx

	TemporaryBuf[i] := #9'jmp ' + lab;

	TemporaryBuf[p] := lab;
	TemporaryBuf[p+1] := tmp;

        for k:=1 to i-1 do
         if cmpBuf(i-k, p-k) or
	    (lab_l(i-k) and lab_l(p-k)) or
	    (opti_(i-k) and opti_(p-k)) then
	 begin

	  if eif(i-k) then exit;

	  if lab_a(i-k) then
	   if (cmpBuf(i-k-1, p-k-1) = false) or (cmpBuf(i-k-2, p-k-2) = false) then exit;

	  if cmpBuf(i-k, p-k) then TemporaryBuf[i-k] := '~';

	  tmp := TemporaryBuf[p-k];

	  TemporaryBuf[p-k] := TemporaryBuf[p-k+1];
	  TemporaryBuf[p-k+1] := tmp;

	 end else
	  exit;

      end;	// if yes

  end;

end;	// procedure
