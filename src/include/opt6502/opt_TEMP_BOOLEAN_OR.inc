
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

 if ldy_1(0) and									// ldy #1		; 0
    lda(1) and										// lda			; 1
    cmp(2) and										// cmp			; 2
    branch(3) and									// beq|bne|bcc|bcs	; 3
    dey(4) and										// dey			; 4
    lab_a(5) and									//@			; 5
    sty_stack(6) then									// sty :STACKORIGIN	; 6
 begin

  p:=7;
  yes:=false;

  tmp := #9'ora ' + copy(TemporaryBuf[6], 6, 256);

  while (p < 512) and
        ldy_1(p) and									// ldy #1
        lda(p+1) and									// lda
        cmp(p+2) and									// cmp
        branch(p+3) and									// beq|bne|bcc|bcs
        dey(p+4) and									// dey
        lab_a(p+5) and									//@
        tya(p+6) and									// tya
//        (pos('ora :STACK', TemporaryBuf[p+7]) > 0) and				// ora :STACKORIGIN
        (TemporaryBuf[p+7] = tmp) and
        sta(p+8) do									// sta
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
