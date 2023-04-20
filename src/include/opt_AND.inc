
function opt_AND(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      AND.
// -----------------------------------------------------------------------------

    if lda_im_0(i) and										// lda #$00		; 0
       and_(i+1) and										// and			; 1
       sta_a(i+2) then										// sta 			; 2
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if lda_a(i) and (iy(i) = false) and								// lda 			; 0
       and_im_0(i+1) and									// and #$00		; 1
       sta_a(i+2) then										// sta 			; 2
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$00';

	exit(false);
     end;


    if lda_stack(i) and										// lda :STACKORIGIN	; 0
       and_im_0(i+1) and									// and #$00		; 1
       sta_stack(i+2) then									// sta :STACKORIGIN	; 2
     if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'lda #$00';

	exit(false);
     end;


    if lda_a(i) and										// lda 			; 0
       (listing[i+1] = #9'and #$FF') and							// and #$FF		; 1
       sta_a(i+2) then										// sta 			; 2
     begin

	if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then begin
	  listing[i] := '';
	  listing[i+2] := '';
        end;

	listing[i+1] := '';

	exit(false);
     end;


    if sta_stack(i) and										// sta :STACKORIGIN	; 0
       lda_a(i+1) and										// lda			; 1
       and_stack(i+2) then									// and :STACKORIGIN	; 2
      if (copy(listing[i], 6, 256) = copy(listing[i+2], 6, 256)) then
     begin
	listing[i]   := '';
	listing[i+1] := #9'and ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';
	exit(false);
     end;


    if ldy_im_0(i) and										// ldy #$00		; 0
       lda_bp2_y(i+1) and									// lda (:bp2),y		; 1
       and_im(i+2) and										// and #		; 2
       sta_a(i+3) and										// sta 			; 3
       iny(i+4) and										// iny			; 4
       lda_bp2_y(i+5) and									// lda (:bp2),y		; 5
       and_im(i+6) and										// and #		; 6
       sta_a(i+7) and										// sta 			; 7
       iny(i+8) and										// iny			; 8
       lda_bp2_y(i+9) and									// lda (:bp2),y		; 9
       and_im(i+10) and										// and #		; 10
       sta_a(i+11) and										// sta 			; 11
       iny(i+12) and										// iny			; 12
       lda_bp2_y(i+13) and									// lda (:bp2),y		; 13
       and_im(i+14) and										// and #		; 14
       sta_a(i+15) then										// sta 			; 15
     begin
	p := i + 12;

	while iny(p) and and_im_0(p + 2) do begin
	  listing[p] := '';
	  listing[p+1] := #9'lda #$00';
	  listing[p+2]:= '';

	  dec(p, 4);
	end;

	if ldy_im_0(p) and and_im_0(p+2) then begin
	  listing[p] := '';
	  listing[p+1] := #9'lda #$00';
	  listing[p+2]:= '';
	end;

	exit(false);
     end;

end;		// function