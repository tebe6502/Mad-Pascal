
function opt_CMP_BRANCH(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      BRANCH.
// -----------------------------------------------------------------------------

    if lda(i) and										// lda			; 0	>= 128
       (listing[i+1] = #9'cmp #$80') and							// cmp #$80		; 1
       bcs_a(i+2) and										// bcs @+		; 2
       dey(i+3) then										// dey			; 3
     begin
	listing[i+1] := #9'bmi @+';
	listing[i+2] := '';

	exit(false);
     end;


    if lda(i) and										// lda			; 0	< 128
       (listing[i+1] = #9'cmp #$80') and							// cmp #$80		; 1
       bcc_a(i+2) and										// bcc @+		; 2
       dey(i+3) then										// dey			; 3
     begin
	listing[i+1] := #9'bpl @+';
	listing[i+2] := '';

	exit(false);
     end;


    if lda(i) and										// lda			; 0	> 127
       (listing[i+1] = #9'cmp #$7F') and							// cmp #$7F		; 1
       seq(i+2) and										// seq			; 2
       bcs_a(i+3) and										// bcs @+		; 3
       dey(i+4) then										// dey			; 4
     begin
	listing[i+1] := #9'bmi @+';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if lda(i) and										// lda			; 0	<= 127
       (listing[i+1] = #9'cmp #$7F') and							// cmp #$7F		; 1
       bcc_a(i+2) and										// bcc @+		; 2
       beq(i+3) and										// beq @+		; 3
       dey(i+4) then										// dey			; 4
     begin
	listing[i+1] := #9'bpl @+';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if lda(i) and										// lda			; 0	<= 127	FOR
       (listing[i+1] = #9'cmp #$7F') and							// cmp #$7F		; 1
       (listing[i+2] = #9'bcc *+7') and								// bcc *+7		; 2
       (listing[i+3] = #9'beq *+5') then							// beq *+5		; 3
     begin
	listing[i+1] := #9'bpl *+5';
	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
     end;


    if (jeq(i+5) or jne(i+5) or beq(i+5) or bne(i+5)) and					// jeq|jne|beq|bne	; 5
       (SKIP(i+6) = false) and (dey(i+6) = false) and						//~SKIP|dey		; 6

       (SKIP(i-1) = false) and
       lda_a(i) and (lda_bp2_y(i) = false) and							// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       cmp_im_0(i+1) and									// cmp #$00		; 1
       (beq(i+2) or bne(i+2)) and								// beq|bne		; 2
       lda_a(i+3) and										// lda			; 3
       lab_a(i+4) then										// @			; 4
     begin
	listing[i+1] := '';

	exit(false);
     end;


    if (jeq(i+3) or jne(i+3) or beq(i+3) or bne(i+3)) and					// jeq|jne|beq|bne	; 3
       (SKIP(i+4) = false) and (dey(i+4) = false) and						//~SKIP|dey		; 4

       (SKIP(i-1) = false) and
       lda_a(i) and (lda_bp2_y(i) = false) and							// lda			; 0	!!! tylko dla <>0 lub =0 !!!  beq|bne !!!
       cmp_im_0(i+1) and									// cmp #$00		; 1
       lab_a(i+2) then										// @			; 2	!!! to oznacza krotki test !!!
     begin
	listing[i+1] := '';

	exit(false);
     end;


     if lda_im_0(i) and										// lda #$00		; 0	!!! tylko dla <>0
        cmp_im_0(i+1) and									// cmp #$00		; 1
       	bne(i+2) and										// bne			; 2	!!! to oznacza krotki test !!!
	(listing[i+2] <> #9'bne L1') and (listing[i+5] <> #9'bne L1') then
     begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
     end;


     if cmp_im_0(i) and										// cmp #$00		; 0	!!! C = 1
       	jcc(i+1) and										// jcc			; 1	!!! JCC nigdy nie wystapi
	(jeq(i+2) or jne(i+2)) then								// jeq|jne		; 2
     begin
	listing[i+1] := '';

	exit(false);
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

	exit(false);
     end;


    if (listing[i] = #9'and #$80') and								// and #$80		; 0
       (jeq(i+1) or jne(i+1)) then								// jeq|jne		; 1
     begin
	listing[i] := '';

	if jeq(i+1) then
	 listing[i+1] := #9'jpl ' + copy(listing[i+1], 6, 256)
	else
	 listing[i+1] := #9'jmi ' + copy(listing[i+1], 6, 256);

	exit(false);
     end;


    if (SKIP(i-1) = false) and
       lda_a(i) and 										// lda			; 0
       (listing[i+1] = #9'and #$80') and							// and #$80		; 1
       ldy_1(i+2) and										// ldy #1		; 2
       ora_im_0(i+3) and									// ora #$00		; 3
       sne(i+4) and										// sne			; 4
       dey(i+5) and										// dey			; 5
       tya(i+6) and										// tya			; 6
       jeq(i+7) and										// jeq			; 7
       (SKIP(i+8) = false) then									//~SKIP			; 8
     begin
	listing[i+1] := #9'jpl ' + copy(listing[i+7], 6, 256);
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';

	exit(false);
     end;


    if (SKIP(i-1) = false) and
       lda(i) and 										// lda			; 0
       (listing[i+1] = #9'and #$80') and							// and #$80		; 1
       (listing[i+2] = #9'cmp #$80') and							// cmp #$80		; 2
       bne(i+3) and										// bne			; 3
       lda_im_0(i+4) and									// lda #$00		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
       lab_a(i+6) and										//@			; 6
       (jeq(i+7) or jne(i+7)) then								// jeq|jne		; 7
     begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	if jeq(i+7) then
	 listing[i+7] := #9'jmi ' + copy(listing[i+7], 6, 256)
	else
	 listing[i+7] := #9'jpl ' + copy(listing[i+7], 6, 256);

	exit(false);
     end;


    if (SKIP(i-1) = false) and
       lda(i) and 										// lda			; 0
       (listing[i+1] = #9'and #$80') and							// and #$80		; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       bne(i+3) and										// bne			; 3
       lda_im_0(i+4) and									// lda #$00		; 4
       cmp_im_0(i+5) and									// cmp #$00		; 5
       lab_a(i+6) and										//@			; 6
       (jeq(i+7) or jne(i+7)) then								// jeq|jne		; 7
     begin
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';
	listing[i+4] := '';
	listing[i+5] := '';
	listing[i+6] := '';

	if jeq(i+7) then
	 listing[i+7] := #9'jpl ' + copy(listing[i+7], 6, 256)
	else
	 listing[i+7] := #9'jmi ' + copy(listing[i+7], 6, 256);

	exit(false);
     end;


    if (listing[i] = #9'cmp #$80') and								// cmp #$80		; 0
       (jcc(i+1) or jcs(i+1)) then								// jcc|jcs		; 1
     begin
	listing[i] := '';

	if jcc(i+1) then
	 listing[i+1] := #9'jpl ' + copy(listing[i+1], 6, 256)
	else
	 listing[i+1] := #9'jmi ' + copy(listing[i+1], 6, 256);

	exit(false);
     end;


    if bne_a(i) and										// bne @+		; 0
       lda_a(i+1) and										// lda			; 1
       cmp_im_0(i+2) and									// cmp #$00		; 2
       lab_a(i+3) and										//@			; 3
       jcs(i+4) and										// jcs _lxxxx		; 4
       (SKIP(i+5) = false) then									//~SKIP			; 5
      begin
       listing[i]   := '';
       listing[i+1] := '';
       listing[i+2] := '';

       exit(false);
      end;


// -------------------------------------------------------------------------------------------

    if (ENDL(i-1) = false) and
       smi(i) and										// smi			; 0
       bne_a(i+1) and										// bne @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq			; 5
      begin
       listing[i]   := #9'jmi ' + copy(listing[i+5], 6, 256);
       listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (ENDL(i-1) = false) and
       seq(i) and										// seq			; 0
       bpl_a(i+1) and										// bpl @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jeq(i+5) then										// jeq			; 5
      begin
       listing[i]   := #9'jmi ' + copy(listing[i+5], 6, 256);
       listing[i+1] := #9'jeq ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (ENDL(i-1) = false) and
       seq(i) and										// seq			; 0
       bpl_a(i+1) and										// bpl @+		; 1
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

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
       bpl_a(i+1) and										// bpl @+		; 1
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

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
       bmi_a(i+1) and										// bmi @+		; 1
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

       exit(false);
      end;


    if (SKIP(i) = false) and 									//~SKIP			; 0		integer <= 0
       bmi_a(i+1) and										// bmi @+		; 1
       ora(i+2) and										// ora			; 2
       ora(i+3) and										// ora			; 3
       ora(i+4) and										// ora			; 4
       seq(i+5) and										// seq			; 5
       dey(i+6) and										// dey			; 6
       lab_a(i+7) and										//@			; 7
       tya(i+8) and										// tya			; 8
       jeq(i+9) and										// jeq			; 9
       (SKIP(i+10) = false) then								//~SKIP			; 10
      begin
       	listing[i+5] := #9'jne ' + copy(listing[i+9], 6, 256);

       	listing[i+6] := '';

       	listing[i+8] := '';
       	listing[i+9] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (SKIP(i) = false) and 									//~SKIP			; 0		while integer > 0
       bmi_a(i+1) and										// bmi @+		; 1
       ora(i+2) and										// ora			; 2
       ora(i+3) and										// ora			; 3
       ora(i+4) and										// ora			; 4
       sne(i+5) and										// sne			; 5
       lab_a(i+6) and										//@			; 6
       dey(i+7) and										// dey			; 7
       lab_a(i+8) and										//@			; 8
       tya(i+9) and										// tya			; 9
       jne(i+10) and										// jne			; 10
       (SKIP(i+11) = false) then								//~SKIP			; 11
      begin
       	listing[i+5] := listing[i+10];

       	listing[i+7] := '';
       	listing[i+8] := '';
       	listing[i+9] := '';
       	listing[i+10] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (SKIP(i) = false) and 									//~SKIP			; 0		integer > 0
       bmi_a(i+1) and										// bmi @+		; 1
       ora(i+2) and										// ora			; 2
       ora(i+3) and										// ora			; 3
       ora(i+4) and										// ora			; 4
       sne(i+5) and										// sne			; 5
       lab_a(i+6) and										//@			; 6
       dey(i+7) and										// dey			; 7
       lab_a(i+8) and										//@			; 8
       tya(i+9) and										// tya			; 9
       jeq(i+10) and										// jeq			; 10
       (SKIP(i+11) = false) then								//~SKIP			; 11
      begin
       	listing[i+1] := #9'jmi ' + copy(listing[i+10], 6, 256);

       	listing[i+5] := listing[i+10];

       	listing[i+6] := '';
       	listing[i+7] := '';
       	listing[i+8] := '';
       	listing[i+9] := '';
       	listing[i+10] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (SKIP(i) = false) and 									//~SKIP			; 0
       bmi_a(i+1) and										// bmi @+		; 1
       ora(i+2) and										// ora			; 2
       seq(i+3) and										// seq			; 3
       dey(i+4) and										// dey			; 4
       lab_a(i+5) and										//@			; 5
       tya(i+6) and										// tya			; 6
       jeq(i+7) and										// jeq			; 7
       (SKIP(i+8) = false) then									//~SKIP			; 8
      begin
       	listing[i+3] := #9'jne ' + copy(listing[i+7], 6, 256);

       	listing[i+4] := '';

       	listing[i+6] := '';
       	listing[i+7] := '';

	for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
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

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
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

       exit(false);
      end;


    if (ENDL(i) = false) and									//~.ENDL		; 0
       bmi_a(i+1) and										// bmi @+		; 1
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

       exit(false);
      end;


    if (ENDL(i) = false) and									//~.ENDL		; 0
       bmi_a(i+1) and										// bmi @+		; 1
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

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
       bmi_a(i+1) and										// bmi @+		; 1
       dey(i+2) and										// dey			; 2
       lab_a(i+3) and										//@			; 3
       tya(i+4) and										// tya			; 4
       jne(i+5) then										// jne l_		; 5
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+5], 6, 256);
       listing[i+2] := '';
       listing[i+3] := '';
       listing[i+4] := '';
       listing[i+5] := '';

       for p:=i-1 downto 0 do
	 if ldy_1(p) then begin listing[p]:=''; Break end;

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
       bpl_a(i+1) and										// bpl @+		; 1
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

       exit(false);
      end;


    if (SKIP(i) = false) and (ENDL(i) = false) and						//~SKIP|.ENDL		; 0
       bpl_a(i+1) and										// bpl @+		; 1
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

       exit(false);
      end;


    if (ENDL(i-1) = false) and
       seq(i) and										// seq			; 0
       bcs_a(i+1) and										// bcs @+		; 1
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

       exit(false);
     end;


    if (ENDL(i-1) = false) and
       seq(i) and										// seq			; 0
       bcs_a(i+1) and										// bcs @+		; 1
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

       exit(false);
     end;


    if (SKIP(i-1) = false) and (ENDL(i-1) = false) and
       bcc_a(i) and										// bcc @+		; 0
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

       exit(false);
     end;


    if (SKIP(i-1) = false) and (ENDL(i-1) = false) and
       bcc_a(i) and										// bcc @+		; 0
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

       exit(false);
     end;


    if (SKIP(i-1) = false) and (ENDL(i-1) = false) and
       bcs_a(i) and										// bcs @+		; 0
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

       exit(false);
     end;


    if (SKIP(i-1) = false) and (ENDL(i-1) = false) and
       bcs_a(i) and										// bcs @+		; 0
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

      exit(false);
     end;


    if (ENDL(i-1) = false) and
       bcc_a(i) and										// bcc @+		; 0
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

      exit(false);
     end;


    if (ENDL(i-1) = false) and
       bcc_a(i) and										// bcc @+		; 0
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

      exit(false);
     end;


// -------------------------------------------------------------------------------------------


    if (SKIP(i-1) = false) and
       cmp(i) and										// cmp			; 0
       beq(i+1) and										// beq @+		; 1
       jmp(i+2) and										// jmp l_		; 2
       lab_a(i+3) then										// @			; 3
     begin
       listing[i+1] := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       //listing[i+3] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       cmp(i) and										// cmp			; 0
       bcc_a(i+1) and										// bcc @+		; 1
       jmp(i+2) and										// jmp l_		; 2
       lab_a(i+3) then										// @			; 3
     begin
       listing[i+1] := #9'jcs ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       //listing[i+3] := '';

       exit(false);
     end;


    if //(listing[i] = #9'.ENDL') and								//
       bmi_a(i+1) and										// bmi @+		; 1
       beq(i+2) and										// beq @+		; 2
       jmp(i+3) and										// jmp l_		; 3
       lab_a(i+4) then										//@			; 4
      begin
       listing[i+2] := #9'jne ' + copy(listing[i+3], 6, 256);
       listing[i+3] := '';

       exit(false);
      end;


    if //(listing[i] = #9'.ENDL') and								//
       seq(i+1) and										// seq			; 1
       bpl_a(i+2) and										// bpl @+		; 2
       jmp(i+3) and										// jmp l_		; 3
       lab_a(i+4) then										//@			; 4
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+3], 6, 256);
       listing[i+2] := #9'jeq ' + copy(listing[i+3], 6, 256);
       listing[i+3] := '';
//       listing[i+4] := '';

       exit(false);
      end;


    if (SKIP(i) = false) and									//
       bpl_a(i+1) and										// bpl @+		; 1
       jmp(i+2) and										// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
      begin
       listing[i+1] := #9'jmi ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       //listing[i+3] := '';

       exit(false);
      end;


    if (SKIP(i) = false) and									//
       bmi_a(i+1) and										// bmi @+		; 1
       jmp(i+2) and										// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
      begin
       listing[i+1] := #9'jpl ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       //listing[i+3] := '';

       exit(false);
      end;


    if bcc_a(i) and										// bcc @+		; 0
       beq(i+1) and										// beq @+		; 1
       jmp(i+2) and										// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
      begin
       listing[i+1] := #9'jne ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';

       exit(false);
      end;


    if (SKIP(i-1) = false) and
       bne(i) and										// bne @+		; 0
       jmp(i+1) and										// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jeq ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       //listing[i+2] := '';

       exit(false);
     end;


    if seq(i) and										// seq			; 0
       bcs_a(i+1) and										// bcs @+		; 1
       jmp(i+2) and										// jmp l_		; 2
       lab_a(i+3) then										//@			; 3
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+2], 6, 256);
       listing[i+1] := #9'jeq ' + copy(listing[i+2], 6, 256);
       listing[i+2] := '';
       //listing[i+3] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       bcs_a(i) and										// bcs @+		; 0
       jmp(i+1) and										// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       //listing[i+2] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       bcc_a(i) and										// bcc @+		; 0
       jmp(i+1) and										// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       //listing[i+2] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       beq(i) and										// beq @+		; 0
       jmp(i+1) and										// jmp l_		; 1
       lab_a(i+2) then										//@			; 2
     begin
       listing[i]   := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';
       //listing[i+2] := '';

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bne *+5') and								// bne *+5		; 0
       jmp(i+1) then										// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jeq ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'beq *+5') and								// beq *+5		; 0
       jmp(i+1) then										// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jne ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if (SKIP(i-1) = false) and
       (listing[i] = #9'bcs *+5') and								// bcs *+5		; 0
       jmp(i+1) then										// jmp l_		; 1
     begin
       listing[i]   := '';
       listing[i+1] := #9'jcc ' + copy(listing[i+1], 6, 256);

       exit(false);
     end;


    if (SKIP(i-1) = false) and									//
       seq(i) and										// seq			; 0
       jmp(i+1) then										// jmp l_		; 1
      begin
       listing[i] := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       exit(false);
      end;


    if cmp_im_0(i) and										// cmp #$00		; 0
       (jeq(i+1) or jne(i+1)) then								// jeq|jne		; 1
      begin
       listing[i] := '';

       exit(false);
      end;


    if lda_im_0(i) and										// lda #$00		; 0
       jeq(i+1) then										// jeq			; 1
      begin
       listing[i] := '';
       listing[i+1] := #9'jmp ' + copy(listing[i+1], 6, 256);

       exit(false);
      end;


    if (lda_im(i) and (lda_im_0(i) = false)) and						// lda #		; 0
       jne(i+1) then										// jne			; 1
      begin
       listing[i] := '';
       listing[i+1] := #9'jmp ' + copy(listing[i+1], 6, 256);

       exit(false);
      end;


    if lda(i) and (lda_im(i) = false) and							// lda TMP		; 0
       cmp(i+1) and (cmp_im(i+1) = false) and							// cmp TMP		; 1
       (jne(i+2) or bne(i+2)) and								// jne|bne		; 2
       (SKIP(i+3) = false) then
     if argMatch(i, i+1) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if lda(i) and										// lda TMP		; 0
       cmp(i+1) and										// cmp TMP		; 1
       (jeq(i+2) or jcs(i+2)) and								// jeq|jcs		; 2
       (SKIP(i+3) = false) then
     if argMatch(i, i+1) then
      begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := #9'jmp ' + copy(listing[i+2], 6, 256);

	exit(false);
      end;


    if lda(i) and										// lda A		; 0
       cmp(i+1) and										// cmp A		; 1
       jcc(i+2) and										// jcc			; 2
       jeq(i+3) then										// jeq			; 3
    if argMatch(i, i+1) then
     begin

      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := #9'jmp ' + copy(listing[i+3], 6, 256);

      exit(false);
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

	exit(false);
      end;


// -----------------------------------------------------------------------------


    if jcc(i) and										// jcc l_00C5w		; 0
       jmp(i+1) and										// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jcs ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;


    if jcs(i) and										// jcs l_00C5w		; 0
       jmp(i+1) and										// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jcc ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;


    if jne(i) and										// jne l_00C5w		; 0
       jmp(i+1) and										// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jeq ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;


    if jeq(i) and										// jeq l_00C5w		; 0
       jmp(i+1) and										// jmp l_		; 1
       (listing[i+2] = copy(listing[i], 6, 256)) then						//l_00C5w		; 2
     begin
       listing[i]   := #9'jne ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;


    if (listing[i] = #9'jmp *+6') and								// jmp *+6			; 0
       (pos('@'#9'jmp l_', listing[i+1]) > 0) and						//@ jmp l_			; 1
       jmp(i+2) and										// jmp l_			; 2
       lab_l(i+3) then										//l_				; 3
     if (pos(listing[i+3], listing[i+1]) > 0) then
      begin
	listing[i]   := listing[i+2];
	listing[i+1] := '@';
	listing[i+2] := '';

	exit(false);
      end;


    if bcc_a(i) and										// bcc @+			; 0
       beq_a(i+1) and										// beq @+			; 1
       (listing[i+2] = #9'jmp *+6') and								// jmp *+6			; 2
       (pos('@'#9'jmp l_', listing[i+3]) > 0) and						//@ jmp l_			; 3
       (jmp(i+4) = false) then									//~jmp l_			; 4
      begin
	listing[i]   := #9'jcc ' + copy(listing[i+3], 7, 256);
	listing[i+1] := #9'jeq ' + copy(listing[i+3], 7, 256);

	listing[i+2] := '';
	listing[i+3] := '';

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       (beq_a(i) or bne_a(i)) and								// beq|bne @+			; 0
       (listing[i+1] = #9'jmp *+6') and								// jmp *+6			; 1
       (pos('@'#9'jmp l_', listing[i+2]) > 0) and						//@ jmp l_			; 2
       (jmp(i+3) = false) then									//~jmp l_			; 3
      begin
	if beq(i) then
	 listing[i]   := #9'jeq ' + copy(listing[i+2], 7, 256)
	else
	 listing[i]   := #9'jne ' + copy(listing[i+2], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       (bcs_a(i) or bcc_a(i)) and								// bcs|bcc @+			; 0
       (listing[i+1] = #9'jmp *+6') and								// jmp *+6			; 1
       (pos('@'#9'jmp l_', listing[i+2]) > 0) and						//@ jmp l_			; 2
       (jmp(i+3) = false) then									//~jmp l_			; 3
      begin
        if bcs_a(i) then
	 listing[i]   := #9'jcs ' + copy(listing[i+2], 7, 256)
        else
	 listing[i]   := #9'jcc ' + copy(listing[i+2], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if (SKIP(i-1) = false) and
       (bpl_a(i) or bmi_a(i)) and								// bpl|bmi @+			; 0
       (listing[i+1] = #9'jmp *+6') and								// jmp *+6			; 1
       (pos('@'#9'jmp l_', listing[i+2]) > 0) and						//@ jmp l_			; 2
       (jmp(i+3) = false) then									//~jmp l_			; 3
      begin
        if bpl_a(i) then
	 listing[i]   := #9'jpl ' + copy(listing[i+2], 7, 256)
        else
	 listing[i]   := #9'jmi ' + copy(listing[i+2], 7, 256);

	listing[i+1] := '';
	listing[i+2] := '';

	exit(false);
      end;


    if ldy_1(i) and										// ldy #1			; 0
       (pos(#9'jne l_', listing[i+1]) > 0) then							// jne l_			; 1
     begin
       listing[i]   := #9'jmp ' + copy(listing[i+1], 6, 256);
       listing[i+1] := '';

       exit(false);
     end;

end;		// function
