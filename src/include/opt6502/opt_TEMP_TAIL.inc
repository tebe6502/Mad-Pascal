
// -----------------------------------------------------------------------------
// ===		  Common head/tail Sequence coalescing
// -----------------------------------------------------------------------------

procedure opt_TEMP_TAIL;
var i, p, k: integer;
    yes: Boolean;
    lab, tmp: string;
begin

   if (
       ((pos('sta ', TemporaryBuf[20]) > 0) or (pos('jsr ', TemporaryBuf[20]) > 0)) and	// sta|jsr		; 20
       (pos('l_', TemporaryBuf[21]) = 1) and						//l_xxxx		; 21
       (pos('lda IFTMP_', TemporaryBuf[22]) > 0) and					// lda IFTMP_xxxx	; 22
       (pos('jne l_', TemporaryBuf[23]) > 0)						// jne l_xxxx		; 23
       )

      or

      (
       ((pos('sta ', TemporaryBuf[19]) > 0) or (pos('jsr ', TemporaryBuf[19]) > 0)) and	// sta|jsr		; 19
       (pos('l_', TemporaryBuf[20]) = 1) and						//l_xxxx		; 20
       (pos('lda IFTMP_', TemporaryBuf[21]) > 0) and					// lda IFTMP_xxxx	; 21
       (pos('beq *+5', TemporaryBuf[22]) > 0) and					// beq *+5		; 22
       (pos('jmp l_', TemporaryBuf[23]) > 0)						// jmp l_xxxx		; 23
       ) then
    begin

      lab:=copy(TemporaryBuf[23], 6, 256);			// l_xxxx

      yes:=false;

      for p:=24 to High(TemporaryBuf) do
	if TemporaryBuf[p] = lab then begin yes:=true; Break end;


      if yes then begin

       while pos('l_', TemporaryBuf[p-1]) = 1 do begin		// l_xxxx
	tmp:=TemporaryBuf[p-1];					// l_yyyy
								// l_zzzz
	TemporaryBuf[p-1] := TemporaryBuf[p];
	TemporaryBuf[p] := tmp;

	dec(p);
       end;


       if (pos('beq *+5', TemporaryBuf[22]) > 0) then
         i:=19
       else
         i:=20;

{
writeln(p);

	for k:=0 to 19 do
	 writeln(TemporaryBuf[p-1-k]);

writeln('-------');
}


       if (pos('sta ', TemporaryBuf[i]) > 0) or (pos('jsr ', TemporaryBuf[i]) > 0) then begin

        for k:=0 to 19 do
         if TemporaryBuf[i-k] <> TemporaryBuf[p-1-k] then
	  exit
 	 else begin
 	  TemporaryBuf[i-k] := '~';

	  TemporaryBuf[p-k] := TemporaryBuf[p-1-k];
	  TemporaryBuf[p-1-k] := lab;

	 end;

	end;


      end;	// if yes

  end;


end;	// procedure
