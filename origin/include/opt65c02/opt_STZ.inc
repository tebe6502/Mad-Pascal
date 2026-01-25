
function opt_STZ(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      STZ
// -----------------------------------------------------------------------------

  if listing[i+1] <> #9'sta @PARAM?' then begin


    if lda_im_0(i) and										// lda #$00			; 0
       sta_val(i+1) and (iy(i+1) = false) and							// sta				; 1
       (lda_a(i+2) or jsr(i+2)) then								// lda|jsr			; 2
     begin
        listing[i]   := '';
        listing[i+1] := #9'stz ' + copy(listing[i+1], 6, 256);

	exit(false);
     end;


    if (l = i + 2) and
       lda_im_0(i) and										// lda :STACKORIGIN		; 0
       sta_val(i+1) and (iy(i+1) = false) then							// sta				; 1
     begin
        listing[i]   := '';
        listing[i+1] := #9'stz ' + copy(listing[i+1], 6, 256);

	exit(false);
     end;


   end;


end;		// function
