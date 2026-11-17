
function opt_NOT(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      NOT.
// -----------------------------------------------------------------------------

    if lab_a(i+4) and									//@				; 4

       ldy_1(i) and									// ldy #1			; 0
       lda_val(i+1) and									// lda A			; 1	~:STACKORIGIN
       beq(i+2) and									// beq @+			; 2
       dey(i+3) and									// dey				; 3
//       lab_a(i+4) and									//@				; 4
       tya(i+5) and									// tya				; 5
       sta_a(i+6) then									// sta				; 6
     if argMatch(i+1, i+6) then
       begin
	listing[i+3] := #9'lda #$00';
	listing[i+4] := #9'cmp ' + GetARG(i+1);
	listing[i+5] := #9'rol @';

	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
       end;


end;		// function
