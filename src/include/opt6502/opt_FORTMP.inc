
function opt_FORTMP(i: integer): Boolean;
var tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				     FORTMP.
// -----------------------------------------------------------------------------

    if (pos('sta @FORTMP_', listing[i+1]) > 0) and			// change to MVA so that OPTYFOR optimization works
       lda_im(i) then
    begin
     listing[i+1] := #9'mva ' + copy(listing[i], 6, 4) + ' ' +  copy(listing[i+1], 6, 256);
     listing[i] := '';

     exit(false);
    end;


    if (pos('sta @FORTMP_', listing[i+1]) > 0) and			// change to MVA so that OPTYFOR optimization works
       lda_adr(i) and (iy(i) = false) then
    begin
     listing[i+1] := #9'mva ' + copy(listing[i], 6, 256) + ' ' +  copy(listing[i+1], 6, 256);
     listing[i] := '';

     exit(false);
    end;


  if pos('@FORTMP_', listing[i]) = 0 then begin				// !!! @FORTMP_ bez optymalizacji !!!

    if mva_im(i) and mva_im(i+1) and 								// mva #$xx	; 0
       mva_im(i+2) and mva_im(i+3) and								// mva #$xx	; 1
       (sta(i+4) = false) then									// mva #$xx	; 2
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and 				// mva #$xx	; 3
	(copy(listing[i+1], 6, 4) = copy(listing[i+2], 6, 4)) and
	(copy(listing[i+2], 6, 4) = copy(listing[i+3], 6, 4)) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);
       listing[i+3] := #9'sta' + copy(listing[i+3], 10, 256);

       exit(false);
     end;


    if mva_im(i) and mva_im(i+1) and								// mva #$xx	; 0
       mva_im(i+2) and mva_im(i+3) and								// mva #$yy	; 1
       (sta(i+4) = false) then									// mva #$zz	; 2
     if (copy(listing[i], 6, 4) = copy(listing[i+3], 6, 4)) and					// mva #$xx	; 3
	(copy(listing[i], 6, 4) <> copy(listing[i+1], 6, 4)) and
	(copy(listing[i+1], 6, 4) <> copy(listing[i+2], 6, 4)) and
	(copy(listing[i+2], 6, 4) <> copy(listing[i+3], 6, 4)) then begin

       tmp := listing[i];

       listing[i]   := listing[i+1];
       listing[i+1] := listing[i+2];
       listing[i+2] := tmp;

       listing[i+3] := #9'sta' + copy(listing[i+3], 10, 256);

       exit(false);
     end;


    if mva_im(i) and mva_im(i+1) and 								// mva #$xx	; 0
       mva_im(i+2) and (sta(i+3) = false) then							// mva #$xx	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4)) and 				// mva #$xx	; 2
	(copy(listing[i+1], 6, 4) = copy(listing[i+2], 6, 4)) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);
       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);

       exit(false);
     end;


    if mva_im(i) and mva_im(i+1) and								// mva #$xx	; 0
       mva_im(i+2) and (sta(i+3) = false) then							// mva #$yy	; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4)) and					// mva #$xx	; 2
	(copy(listing[i], 6, 4) <> copy(listing[i+1], 6, 4)) then begin

       tmp := listing[i];

       listing[i]   := listing[i+1];
       listing[i+1] := tmp;

       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);

       exit(false);
     end;


    if mva_im(i) and sta(i+1) and								// mva #$xx	; 0
       mva_im(i+2) and (sta(i+3) = false) then							// sta		; 1
     if (copy(listing[i], 6, 4) = copy(listing[i+2], 6, 4)) then begin				// mva #$xx	; 2

       listing[i+2] := #9'sta' + copy(listing[i+2], 10, 256);

       exit(false);
     end;


    if mva_im(i) and mva_im(i+1) and								// mva #$xx	; 0
       (sta(i+2) = false) then									// mva #$xx	; 1
     if copy(listing[i], 6, 4) = copy(listing[i+1], 6, 4) then begin

       listing[i+1] := #9'sta' + copy(listing[i+1], 10, 256);

       exit(false);
     end;


  end;  // @FORTMP_

end;		// function
