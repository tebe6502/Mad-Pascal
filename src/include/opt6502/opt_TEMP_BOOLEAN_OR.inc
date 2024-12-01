
// -----------------------------------------------------------------------------
// ===				      BOOL OR.
// -----------------------------------------------------------------------------

procedure opt_TEMP_BOOLEAN_OR;
var i, p: integer;
    yes: Boolean;
    tmp: string;


  function branch(i: integer): Boolean;
  begin

   Result :=
  	(TemporaryBuf[i] = #9'bne @+') or (TemporaryBuf[i] = #9'beq @+') or
  	(TemporaryBuf[i] = #9'bcc @+') or (TemporaryBuf[i] = #9'bcs @+');
  end;


  function branch_swap(i: integer): string;
  begin
	Result:='';

	if TemporaryBuf[i] = #9'beq @+' then Result := #9'sne' else
	if TemporaryBuf[i] = #9'bne @+' then Result := #9'seq' else
	if TemporaryBuf[i] = #9'bcc @+' then Result := #9'scs' else
	if TemporaryBuf[i] = #9'bcs @+' then Result := #9'scc';

  end;


begin

 if (TemporaryBuf[0] = #9'ldy #1') and							// ldy #1		; 0
    (pos('lda ', TemporaryBuf[1]) > 0) and						// lda			; 1
    (pos('cmp ', TemporaryBuf[2]) > 0) and						// cmp			; 2
    branch(3) and									// beq|bne|bcc|bcs	; 3
    (TemporaryBuf[4] = #9'dey') and							// dey			; 4
    (TemporaryBuf[5] = '@') and								//@			; 5
    (pos('sty :STACK', TemporaryBuf[6]) > 0) then					// sty :STACKORIGIN	; 6
 begin

  p:=7;
  yes:=false;

  while (p < 512) and
        (TemporaryBuf[p] = #9'ldy #1') and						// ldy #1
        (pos('lda ', TemporaryBuf[p+1]) > 0) and					// lda
        (pos('cmp ', TemporaryBuf[p+2]) > 0) and					// cmp
        branch(p+3) and									// beq|bne|bcc|bcs
        (TemporaryBuf[p+4] = #9'dey') and						// dey
        (TemporaryBuf[p+5] = '@') and							//@
        (TemporaryBuf[p+6] = #9'tya') and						// tya
        (pos('ora :STACK', TemporaryBuf[p+7]) > 0) and					// ora :STACKORIGIN
        (pos('sta ', TemporaryBuf[p+8]) > 0) do						// sta
     begin

	inc(p, 9);
	yes:=true;

     end;


     if yes then begin

	i:=p-1;
	tmp := TemporaryBuf[p-1];

	TemporaryBuf[0] := '~';
	TemporaryBuf[3] := branch_swap(3);
	TemporaryBuf[4] := #9'jmp @+';
	TemporaryBuf[5] := '~';
	TemporaryBuf[6] := '~';

	dec(p, 9);

	while p >= 7 do begin
	  TemporaryBuf[p] := '~';

	  TemporaryBuf[p+3] := branch_swap(p+3);
	  TemporaryBuf[p+4] := #9'jmp @+';
	  TemporaryBuf[p+5] := '~';
	  TemporaryBuf[p+6] := '~';
	  TemporaryBuf[p+7] := '~';
	  TemporaryBuf[p+8] := '~';

	  dec(p, 9);
	end;

	TemporaryBuf[i-2] := #9'lda:seq #$00';
	TemporaryBuf[i-1] := '@'#9'lda #$01';
	TemporaryBuf[i] := tmp;

     end;


 end;


end;	// procedure
