// -----------------------------------------------------------------------------
// ===				      BRANCH.
// -----------------------------------------------------------------------------

    if lda(i) and (listing[i+1] = #9'cmp #$80') and						// lda			; 0	>= 128
       (listing[i+2] = #9'bcs @+') and dey(i+3) then						// cmp #$80		; 1
     begin											// bcs @+		; 2
	listing[i+1] := #9'bmi @+';								// dey			; 3
	listing[i+2] := '';
	Result:=false; Break;
     end;


    if lda(i) and (listing[i+1] = #9'cmp #$80') and						// lda			; 0	< 128
       (listing[i+2] = #9'bcc @+') and dey(i+3) then						// cmp #$80		; 1
     begin											// bcc @+		; 2
	listing[i+1] := #9'bpl @+';								// dey			; 3
	listing[i+2] := '';
	Result:=false; Break;
     end;


    if lda(i) and (listing[i+1] = #9'cmp #$7F') and						// lda			; 0	> 127
       seq(i+2) and (listing[i+3] = #9'bcs @+') and						// cmp #$7F		; 1
       dey(i+4) then										// seq			; 2
     begin											// bcs @+		; 3
	listing[i+1] := #9'bmi @+';								// dey			; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false; Break;
     end;


    if lda(i) and (listing[i+1] = #9'cmp #$7F') and						// lda			; 0	<= 127
       (listing[i+2] = #9'bcc @+') and beq(i+3) and						// cmp #$7F		; 1
       dey(i+4) then										// bcc @+		; 2
     begin											// beq @+		; 3
	listing[i+1] := #9'bpl @+';								// dey			; 4
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false; Break;
     end;


    if lda(i) and										// lda			; 0	<= 127	FOR
       (listing[i+1] = #9'cmp #$7F') and							// cmp #$7F		; 1
       (listing[i+2] = #9'bcc *+7') and								// bcc *+7		; 2
       (listing[i+3] = #9'beq *+5') then							// beq *+5		; 3
     begin
	listing[i+1] := #9'bpl *+5';
	listing[i+2] := '';
	listing[i+3] := '';
	Result:=false; Break;
     end;


    if (jeq(i+5) or jne(i+5) or beq(i+5) or bne(i+5)) and					// jeq|jne|beq|bne	; 5
       (SKIP(i+6) = false) and (dey(i+6) = false) and

       lda(i) and										// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       cmp_im_0(i+1) and									// cmp #$00		; 1
       (beq(i+2) or bne(i+2)) and								// beq|bne		; 2
       lda(i+3) and										// lda			; 3
       lab_a(i+4) then										// @			; 4
     begin
	listing[i+1] := '';

	Result:=false; Break;
     end;


    if (jeq(i+3) or jne(i+3) or beq(i+3) or bne(i+3)) and					// jeq|jne|beq|bne	; 3
       (SKIP(i+4) = false) and (dey(i+4) = false) and

       lda_a(i) and										// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       cmp_im_0(i+1) and									// cmp #$00		; 1
       lab_a(i+2) then										// @			; 2	!!! to oznacza krotki test !!!
     begin
	listing[i+1] := '';
	Result:=false; Break;
     end;


     if lda_im_0(i) and										// lda #$00		; 0	!!! tylko dla <>0
        cmp_im_0(i+1) and									// cmp #$00		; 1
       	bne(i+2) and										// bne			; 2	!!! to oznacza krotki test !!!
	(listing[i+2] <> #9'bne L1') and (listing[i+5] <> #9'bne L1') then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
     end;


    if and_ora_eor(i) and 									// and|ora|eor		; 0
       (iy(i) = false) and									// ldy #1		; 1
       ldy_1(i+1) and										// cmp #$00		; 2
       cmp_im_0(i+2) and									// beq|bne		; 3
       (beq(i+3) or bne(i+3) ) then
     begin
	a := listing[i];
	listing[i]   := listing[i+1];
	listing[i+1] := a;
	listing[i+2] := '';
	Result:=false; Break;
     end;


    if lda(i) and										// lda			; 0
       and_ora_eor(i+1) and									// and|ora|eor		; 1
       bne(i+2) and										// bne			; 2
       lda_im_0(i+3) and									// lda #$00		; 3
       lab_a(i+4) and										// @			; 4
       (beq(i+5) or jeq(i+5)) then								// beq|jeq		; 5
     begin
	listing[i+3] := '';

	if SKIP(i-1) = false then begin
	 listing[i+2] := '';
	 listing[i+4] := '';
	end;

	Result:=false; Break;
     end;


    if (listing[i] = #9'and #$80') and								// and #$80		; 0
       (jeq(i+1) or jne(i+1)) then								// jeq|jne		; 1
     begin
	listing[i] := '';

	if jeq(i+1) then
	 listing[i+1] := #9'jpl ' + copy(listing[i+1], 6, 256)
	else
	 listing[i+1] := #9'jmi ' + copy(listing[i+1], 6, 256);

	Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       lda(i) and 										// lda			; 0
       (listing[i+1] = #9'and #$80') and							// and #$80		; 1
       (listing[i+2] = #9'cmp #$80') and							// cmp #$80		; 2
       bne(i+3) and										// bne			; 3
       lda_im_0(i+4) and									// lda #$00		; 4
       lab_a(i+5) and										//@			; 5
       (jeq(i+6) or jne(i+6)) then								// jeq|jne		; 6
     begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';

	if jeq(i+6) then
	 listing[i+6] := #9'jmi ' + copy(listing[i+6], 6, 256)
	else
	 listing[i+6] := #9'jpl ' + copy(listing[i+6], 6, 256);

	Result:=false; Break;
     end;


    if (listing[i] = #9'cmp #$80') and								// cmp #$80		; 0
       (jcc(i+1) or jcs(i+1)) then								// jcc|jcs		; 1
     begin
	listing[i] := '';

	if jcc(i+1) then
	 listing[i+1] := #9'jpl ' + copy(listing[i+1], 6, 256)
	else
	 listing[i+1] := #9'jmi ' + copy(listing[i+1], 6, 256);

	Result:=false; Break;
     end;


// -------------------------------------------------------------------------------------------


    if cmp(i) and										// cmp			; 0
       beq(i+1) and										// beq @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       lab_a(i+3) then										// @			; 3
     begin
       listing[i+1] := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false; Break;
     end;


    if cmp(i) and										// cmp			; 0
       (listing[i+1] = #9'bcc @+') and								// bcc @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       lab_a(i+3) then										// @			; 3
     begin
       listing[i+1] := #9'jcs ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false; Break;
     end;



    if //(listing[i] = #9'.ENDL') and								// .ENDL		; 0
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       beq(i+2) and										// beq @+		; 2
       (pos('jmp l_', listing[i+3]) > 0) and							// jmp l_		; 3
       lab_a(i+4) then										//@			; 4
      begin
       listing[i+2] := #9'jne ' + copy(listing[i+3], 6, 256);
       listing[i+3] := '';

       Result:=false; Break;
      end;


    if //(listing[i] = #9'.ENDL') and								//
       seq(i+1) and										// seq			; 1
       (listing[i+2] = #9'bpl @+') and								// bpl @+		; 2
       (pos('jmp l_', listing[i+3]) > 0) and							// jmp l_		; 3
       lab_a(i+4) then										//@			; 4
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+3], 6, 256);
       listing[i+2] := #9'jeq ' + copy(listing[i+3], 6, 256);

       listing[i+3] := '';
       listing[i+4] := '';

       Result:=false; Break;
      end;


    if seq(i) and										// seq			; 0
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq			; 5
      begin
       listing[i  ] := #9'jmi ' + copy(listing[i+5], 6, 256);
       listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if seq(i) and										// seq			; 0
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jne(i+5) then										// jne			; 5
      begin
       listing[i  ] := #9'smi';
       listing[i+1] := #9'jne ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq			; 5
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq			; 5
      begin
       listing[i+1] := #9'jpl ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       beq(i+1) and										// beq @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       (jeq(i+5) or jne(i+5)) then								// jeq|jne		; 5
      begin

       if jeq(i+5) then
        listing[i+1] := #9'jne ' + copy(listing[i+5], 6, 256)
       else
        listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256);

       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       bne(i+1) and										// bne @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       (jeq(i+5) or jne(i+5)) then								// jeq|jne l_		; 5
      begin
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if //(listing[i] = #9'.ENDL') and								//
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       beq(i+2) and										// beq @+		; 2
       dey(i+3) and										// dey			; 3
       lab_a(i+4) and										//@			; 4
       tya(i+5) and										// tya			; 5
       jne(i+6) then										// jne l_		; 6
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+6], 6, 256);
       listing[i+2] := #9'jeq ' + copy(listing[i+6], 6, 256);
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';
       listing[i+6] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if //(listing[i] = #9'.ENDL') and								//
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       beq(i+2) and										// beq @+		; 2
       dey(i+3) and										// dey			; 3
       lab_a(i+4) and										//@			; 4
       tya(i+5) and										// tya			; 5
       jeq(i+6) then										// jeq l_		; 6
      begin
       listing[i+2] := #9'jne ' + copy(listing[i+6], 6, 256);
       listing[i+3] := '';

       listing[i+5] := '';
       listing[i+6] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jne(i+5) then										// jne l_		; 5
      begin
       listing[i+1] := #9'jpl ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq l_		; 5
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
      end;


    if seq(i) and										// seq			; 0
       (listing[i+1] = #9'bcs @+') and								// bcs @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq l_		; 5
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+5], 6, 256);
       listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
     end;


    if seq(i) and										// seq			; 0
       (listing[i+1] = #9'bcs @+') and								// bcs @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jne(i+5) then										// jne l_		; 5
     begin
       listing[i]   := #9'beq @+';
       listing[i+1] := #9'jcs ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';

       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       dey(i+1) and										// dey			; 1
       lab_a(i+2) and										//@			; 2
       tya(i+3) and										// tya			; 3
       jne(i+4) then										// jne l_		; 4
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+4], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       dey(i+1) and										// dey			; 1
       lab_a(i+2) and										//@			; 2
       tya(i+3) and										// tya			; 3
       jeq(i+4) then										// jeq l_		; 4
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+4], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcs @+') and								// bcs @+		; 0
       dey(i+1) and										// dey			; 1
       lab_a(i+2) and										//@			; 2
       tya(i+3) and										// tya			; 3
       jeq(i+4) then										// jeq l_		; 4
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+4], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcs @+') and								// bcs @+		; 0
       dey(i+1) and										// dey			; 1
       lab_a(i+2) and										//@			; 2
       tya(i+3) and										// tya			; 3
       jne(i+4) then										// jne l_		; 4
     begin
      listing[i]   := #9'jcs ' + copy(listing[i+4], 6, 256);
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';

      for p:=i-1 downto 0 do
	if ldy_1(p) then begin listing[p]:=''; Break end;

      Result:=false; Break;
     end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bpl @+') and								// bpl @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false; Break;
      end;


    if (SKIP(i) = false) and									//
       (listing[i+1] = #9'bmi @+') and								// bmi @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
      begin
       listing[i+1] := #9'jpl ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false; Break;
      end;


    if (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       beq(i+1) and										// beq @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
      begin
       listing[i+1] := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';

       Result:=false; Break;
      end;


    if (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       beq(i+1) and										// beq @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jne(i+5) then 										// jne l_		; 5
     begin

      listing[i]   := #9'jcc ' + copy(listing[i+5], 6, 256);
      listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256);
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';

      for p:=i-1 downto 0 do
	if ldy_1(p) then begin listing[p]:=''; Break end;

      Result:=false; Break;
     end;


    if (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       beq(i+1) and										// beq @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then 										// jeq l_		; 5
     begin

      listing[i]   := #9'bcc @+';
      listing[i+1] := #9'jne ' + copy(listing[i+5], 6, 256);
      listing[i+2] := '@';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';

      for p:=i-1 downto 0 do
	if ldy_1(p) then begin listing[p]:=''; Break end;

      Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       bne(i) and										// bne @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jeq ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false; Break;
     end;


    if seq(i) and										// seq			; 0
       (listing[i+1] = #9'bcs @+') and								// bcs @+		; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+2], 6, 256);
       listing[i+1] := #9'jeq ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcs @+') and								// bcs @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcc @+') and								// bcc @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       beq(i) and										// beq @+		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       listing[i+2] := '';

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bne *+5') and								// bne *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jeq ' + copy(listing[i+1], 6, 256);

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'beq *+5') and								// beq *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jne ' + copy(listing[i+1], 6, 256);

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcs *+5') and								// bcs *+5		; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jcc ' + copy(listing[i+1], 6, 256);

       Result:=false; Break;
     end;


    if (SKIP(i-1) = false) and									//
       seq(i) and										// seq			; 0
       (pos('jmp l_', listing[i+1]) > 0) then							// jmp l_		; 1
      begin
       listing[i] := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       Result:=false; Break;
      end;


    if cmp_im_0(i) and										// cmp #$00		; 0
       (jeq(i+1) or jne(i+1)) then								// jeq|jne		; 1
      begin
       listing[i] := '';

       Result:=false; Break;
      end;


    if lda_im_0(i) and										// lda #$00		; 0
       jeq(i+1) then										// jeq			; 1
      begin
       listing[i] := '';
       listing[i+1] := #9'jmp ' + copy(listing[i+1], 6, 256);

       Result:=false; Break;
      end;


    if (lda_im(i) and (lda_im_0(i) = false)) and						// lda #		; 0
       jne(i+1) then										// jne			; 1
      begin
       listing[i] := '';
       listing[i+1] := #9'jmp ' + copy(listing[i+1], 6, 256);

       Result:=false; Break;
      end;


    if lda(i) and (lda_im(i) = false) and							// lda TMP		; 0
       cmp(i+1) and (cmp_im(i+1) = false) and							// cmp TMP		; 1
       (jne(i+2) or bne(i+2)) and								// jne|bne		; 2
       (SKIP(i+3) = false) then
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
      end;


    if lda(i) and										// lda TMP		; 0
       cmp(i+1) and										// cmp TMP		; 1
       (jeq(i+2) or jcs(i+2)) and								// jeq|jcs		; 2
       (SKIP(i+3) = false) then
     if (copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256)) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'jmp ' + copy(listing[i+2], 6, 256);

	Result:=false; Break;
      end;


    if lda(i) and										// lda A		; 0
       cmp(i+1) and										// cmp A		; 1
       jcc(i+2) and										// jcc			; 2
       jeq(i+3) then										// jeq			; 3
    if copy(listing[i], 6, 256) = copy(listing[i+1], 6, 256) then
     begin

      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := #9'jmp ' + copy(listing[i+3], 6, 256);

      Result:=false; Break;
     end;


    if ldy_1(i) and										// ldy #1		; 0
       dey(i+1) and										// dey			; 1
       tya(i+2) and										// tya			; 2
       (jne(i+3) or bne(i+3)) then								// jne|bne		; 3
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;


// -----------------------------------------------------------------------------


    if jcc(i) and										// jcc l_00C5w		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       Result:=false; Break;
     end;


    if jcs(i) and										// jcs l_00C5w		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       Result:=false; Break;
     end;


    if jne(i) and										// jne l_00C5w		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jeq ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       Result:=false; Break;
     end;


    if jeq(i) and										// jeq l_00C5w		; 0
       (pos('jmp l_', listing[i+1]) > 0) and							// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       Result:=false; Break;
     end;


    if (listing[i] = #9'jmp *+6') and								// jmp *+6			; 0
       (pos('@'#9'jmp l_', listing[i+1]) > 0) and						//@ jmp l_			; 1
       (pos('jmp l_', listing[i+2]) > 0) and							// jmp l_			; 2
       (pos('l_', listing[i+3]) = 1) then							//x_				; 3
     if (pos(listing[i+3], listing[i+1]) > 0) then
      begin
	listing[i]   := listing[i+2];
	listing[i+1] := '@';
	listing[i+2] := '';

	Result:=false; Break;
      end;


    if bcc(i) and										// bcc @+			; 0
       beq(i+1) and										// beq @+			; 1
       (listing[i+2] = #9'jmp *+6') and								// jmp *+6			; 2
       (pos('@'#9'jmp l_', listing[i+3]) > 0) and						//@ jmp l_			; 3
       (pos('jmp l_', listing[i+4]) = 0) then							//~jmp l_			; 4
      begin
	listing[i]   := #9'jcc ' + copy(listing[i+3], 7, 256);
	listing[i+1] := #9'jeq ' + copy(listing[i+3], 7, 256);

	listing[i+2] := '';
	listing[i+3] := '';

	Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       (beq(i) or bne(i)) and									// beq|bne @+			; 0
       (listing[i+1] = #9'jmp *+6') and								// jmp *+6			; 1
       (pos('@'#9'jmp l_', listing[i+2]) > 0) and						//@ jmp l_			; 2
       (pos('jmp l_', listing[i+3]) = 0) then							//~jmp l_			; 3
      begin
	if beq(i) then
	 listing[i]   := #9'jeq ' + copy(listing[i+2], 7, 256)
	else
	 listing[i]   := #9'jne ' + copy(listing[i+2], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       ((listing[i] = #9'bcs @+') or (listing[i] = #9'bcc @+')) and				// bcs|bcc @+			; 0
       (listing[i+1] = #9'jmp *+6') and								// jmp *+6			; 1
       (pos('@'#9'jmp l_', listing[i+2]) > 0) and						//@ jmp l_			; 2
       (pos('jmp l_', listing[i+3]) = 0) then							//~jmp l_			; 3
      begin
        if (listing[i] = #9'bcs @+') then
	 listing[i]   := #9'jcs ' + copy(listing[i+2], 7, 256)
        else
	 listing[i]   := #9'jcc ' + copy(listing[i+2], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
      end;


    if (SKIP(i-1) = false) and
       ((listing[i] = #9'bpl @+') or (listing[i] = #9'bmi @+')) and				// bpl|bmi @+			; 0
       (listing[i+1] = #9'jmp *+6') and								// jmp *+6			; 1
       (pos('@'#9'jmp l_', listing[i+2]) > 0) and						//@ jmp l_			; 2
       (pos('jmp l_', listing[i+3]) = 0) then							//~jmp l_			; 3
      begin
        if (listing[i] = #9'bpl @+') then
	 listing[i]   := #9'jpl ' + copy(listing[i+2], 7, 256)
        else
	 listing[i]   := #9'jmi ' + copy(listing[i+2], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	Result:=false; Break;
      end;
