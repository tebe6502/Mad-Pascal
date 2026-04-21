
// -----------------------------------------------------------------------------
// ===	         Excluding the 'ldy #' register from the FOR loop
// -----------------------------------------------------------------------------

procedure opt_TEMP_FOR_REGY;
var p: integer;
    tmp: string;
begin

    if (sta(0) or sty(0)) and								// sta|sty			; 0
       (TemporaryBuf[1] = '') and							//				; 1
       lab_l(2) and									//l_xxxx			; 2
       (TemporaryBuf[3] = '; --- ForToDoCondition') then				//; --- ForToDoCondition	; 3
     begin

      tmp := '';				// szukamy pierwszego 'ldy #'
      for p:=4 to High(TemporaryBuf) do

       if (lab_l(p+1) and (pos(TemporaryBuf[2], TemporaryBuf[p]) > 0)) then Break else

       if ldy_im(p) then begin

         if tmp = '' then			// wszystkie wystapienia 'ldy #' powinny być identyczne
	  tmp := TemporaryBuf[p]
	 else
	  if tmp <> TemporaryBuf[p] then begin tmp := ''; Break end;

       end else
        if fail(p) then begin tmp := ''; Break end;


       if tmp <> '' then begin			// usuwamy 'ldy #'
	 TemporaryBuf[1] := tmp;

         for p:=4 to High(TemporaryBuf) do
          if lab_l(p+1) and (pos(TemporaryBuf[2], TemporaryBuf[p]) > 0) then Break else
	   if ldy_im(p) then TemporaryBuf[p] := '~';

       end;

     end;

end;	// procedure
