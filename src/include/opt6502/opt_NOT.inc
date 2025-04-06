
function opt_NOT(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      NOT.
// -----------------------------------------------------------------------------

    if ldy_1(i) and									// ldy #1		; 0
       lda_val(i+1) and									// lda A		; 1	~:STACKORIGIN
       beq(i+2) and									// beq @+		; 2
       dey(i+3) and									// dey			; 3
       lab_a(i+4) and									//@			; 4
       sty(i+5) and									// sty A		; 5
       (tya(i+6) = false) and (sty(i+6) = false) then					//~tya|sty		; 6
     if (copy(listing[i+1], 6, 256) = copy(listing[i+5], 6, 256)) then
       begin
	listing[i] := '';

	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := #9'eor #$01';
	listing[i+5] := #9'sta ' + copy(listing[i+5], 6, 256);

	exit(false);
       end;

end;		// function