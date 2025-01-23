
// -----------------------------------------------------------------------------
// ===		      Common head/tail Sequence coalescing
// -----------------------------------------------------------------------------
//				IF THEN STATEMENT
// -----------------------------------------------------------------------------

procedure opt_TEMP_TAIL_IF;
const
    ofs = 80;

var i, p, k: integer;
    yes: Boolean;
    lab, tmp: string;
begin

   if (
       (sta(ofs+20) or jsr(ofs+20)) and							// sta|jsr		; 20
       lab_l(ofs+21) and								//l_xxxx		; 21
       IFTMP(ofs+22) and								// lda IFTMP_xxxx	; 22
       jne_l(ofs+23)									// jne l_xxxx		; 23
       )

      or

      (
       (sta(ofs+19) or jsr(ofs+19)) and							// sta|jsr		; 19
       lab_l(ofs+20) and								//l_xxxx		; 20
       IFTMP(ofs+21) and								// lda IFTMP_xxxx	; 21
       (TemporaryBuf[ofs+22] = #9'beq *+5') and						// beq *+5		; 22
       jmp(ofs+23)									// jmp l_xxxx		; 23
       ) then
    begin

      lab:=copy(TemporaryBuf[ofs+23], 6, 256);			// l_xxxx

      yes:=false;

      for p:=ofs+24 to High(TemporaryBuf) do
	if TemporaryBuf[p] = lab then begin yes:=true; Break end;


      if yes then begin

       while lab_l(p-1) do begin				// l_xxxx
	tmp:=TemporaryBuf[p-1];					// l_yyyy
								// l_zzzz
	TemporaryBuf[p-1] := TemporaryBuf[p];
	TemporaryBuf[p] := tmp;

	dec(p);
       end;


       if (TemporaryBuf[ofs+22] = #9'beq *+5') then
         i:=ofs+19
       else
         i:=ofs+20;


       if sta(i) or jsr(i) then begin

        for k:=0 to ofs+19 do
         if (TemporaryBuf[i-k] = TemporaryBuf[p-k-1]) or
	    (lab_l(i-k) and lab_l(p-k-1)) or
	    (opti(i-k) and opti(p-k-1)) then
	 begin

	  if lab_a(i-k) then
	   if (TemporaryBuf[i-k-1] <> TemporaryBuf[p-k-2]) or (TemporaryBuf[i-k-2] <> TemporaryBuf[p-k-3]) then exit;

 	  if (TemporaryBuf[i-k] = TemporaryBuf[p-k-1]) then TemporaryBuf[i-k] := '~';

	  TemporaryBuf[p-k] := TemporaryBuf[p-k-1];
	  TemporaryBuf[p-k-1] := lab;

	 end else
	  exit;

       end;


      end;	// if yes

  end;


end;	// procedure
