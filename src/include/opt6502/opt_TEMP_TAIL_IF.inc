
// -----------------------------------------------------------------------------
// ===		      Common head/tail Sequence coalescing
// -----------------------------------------------------------------------------
//				IF THEN STATEMENT
// -----------------------------------------------------------------------------

procedure opt_TEMP_TAIL_IF;
var i, p, k: integer;
    yes: Boolean;
    lab, tmp: string;
begin

   if (
       (sta(20) or jsr(20)) and								// sta|jsr		; 20
       lab_l(21) and									//l_xxxx		; 21
       IFTMP(22) and									// lda IFTMP_xxxx	; 22
       jne_l(23)									// jne l_xxxx		; 23
       )

      or

      (
       (sta(19) or jsr(19)) and								// sta|jsr		; 19
       lab_l(20) and									//l_xxxx		; 20
       IFTMP(21) and									// lda IFTMP_xxxx	; 21
       (TemporaryBuf[22] = #9'beq *+5') and						// beq *+5		; 22
       jmp(23)										// jmp l_xxxx		; 23
       ) then
    begin

      lab:=copy(TemporaryBuf[23], 6, 256);			// l_xxxx

      yes:=false;

      for p:=24 to High(TemporaryBuf) do
	if TemporaryBuf[p] = lab then begin yes:=true; Break end;


      if yes then begin

       while lab_l(p-1) do begin				// l_xxxx
	tmp:=TemporaryBuf[p-1];					// l_yyyy
								// l_zzzz
	TemporaryBuf[p-1] := TemporaryBuf[p];
	TemporaryBuf[p] := tmp;

	dec(p);
       end;


       if (TemporaryBuf[22] = #9'beq *+5') then
         i:=19
       else
         i:=20;

{
writeln(p);

	for k:=0 to 19 do
	 writeln(TemporaryBuf[p-1-k]);

writeln('-------');
}


       if sta(i) or jsr(i) then begin

        for k:=0 to 19 do
         if (TemporaryBuf[i-k] = TemporaryBuf[p-1-k]) or
	    (lab_l(i-k) and lab_l(p-1-k)) or
	    (opti(i-k) and opti(p-1-k)) then
	 begin

 	  TemporaryBuf[i-k] := '~';

	  TemporaryBuf[p-k] := TemporaryBuf[p-1-k];
	  TemporaryBuf[p-1-k] := lab;

	 end else
	  exit;

       end;


      end;	// if yes

  end;


end;	// procedure
