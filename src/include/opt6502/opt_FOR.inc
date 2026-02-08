
procedure opt_FOR;
var i, k: integer;
begin

// -----------------------------------------------------------------------------
// ===		     		      FOR.
// -----------------------------------------------------------------------------

//   Rebuild;

   found := false;

   for i := 0 to l - 1 do
    if (pos('@FORTMP_', listing[i]) > 0) then		// licznik petli FOR nie moze byc modyfikowany podczas jej dzialania
     if mva_im(i) then begin				// !!! tylko MVA_IM !!!

      found := true;

      if pos('+3', listing[i]) > 0 then optyFOR3 := listing[i] else
      if pos('+2', listing[i]) > 0 then optyFOR2 := listing[i] else
      if pos('+1', listing[i]) > 0 then optyFOR1 := listing[i] else
      					optyFOR0 := listing[i];

      listing[i] := '';
     end else
     if cmp(i) or sub(i) or sbc(i) then begin

      found := true;

      if cmp(i) then arg0 := #9'cmp ';
      if sub(i) then arg0 := #9'sub ';
      if sbc(i) then arg0 := #9'sbc ';

      if pos('+3', listing[i]) > 0 then begin
       if pos(copy(listing[i], 6, 256), optyFOR3) > 0 then listing[i] := arg0 + GetString(optyFOR3);
      end else
      if pos('+2', listing[i]) > 0 then begin
       if pos(copy(listing[i], 6, 256), optyFOR2) > 0 then listing[i] := arg0 + GetString(optyFOR2);
      end else
      if pos('+1', listing[i]) > 0 then begin
       if pos(copy(listing[i], 6, 256), optyFOR1) > 0 then listing[i] := arg0 + GetString(optyFOR1);
      end else
       if pos(copy(listing[i], 6, 256), optyFOR0) > 0 then listing[i] := arg0 + GetString(optyFOR0);

     end;


     if found then begin

      Rebuild('opt_FOR');

      if l > 0 then begin

       if (l = 3) and					// BYTE
          lda_a(0) and
          cmp_im_0(1) and
	  (pos(#9'jcc l_', listing[2]) > 0 ) then
	begin
	 listing[0] := #9'#for:dec ' + copy(listing[0], 6, 256);
	 listing[1] := #9'#for';
	 listing[2] := '';
	end;


       if (l = 5) and					// BYTE zamien miejscami
          lda_a(0) and
          cmp(1) and (cmp_im(1) = false) and
	  (listing[2] = #9'bcc *+7') and
	  (listing[3] = #9'beq *+5') and
	  jmp_l(4) then
        begin
	 listing[2] := #9'lda ' + copy(listing[1], 6, 256);
	 listing[3] := #9'cmp ' + copy(listing[0], 6, 256);
	 listing[4] := #9'jcc ' + copy(listing[4], 6, 256);

	 listing[0] := '';
	 listing[1] := '';
        end;


       if (l = 5) and					// BYTE #
          lda_a(0) and
          cmp_im(1) and
	  (listing[2] = #9'bcc *+7') and
	  (listing[3] = #9'beq *+5') and
	  jmp_l(4) then
        begin
        k := GetBYTE(1) + 1;

        if k < $100 then begin

         if k = $80 then begin
 	  listing[1] := '';
 	  listing[2] := '';
 	  listing[3] := '';
 	  listing[4] := #9'jmi ' + copy(listing[4], 6, 256);
 	 end else begin
	  listing[1] := #9'cmp #' + HexByte(byte(k));
	  listing[2] := '';
	  listing[3] := '';
	  listing[4] := #9'jcs ' + copy(listing[4], 6, 256);
 	 end;

        end else begin
	 listing[0] := '';
	 listing[1] := '';
	 listing[2] := '';
	 listing[3] := '';
	 listing[4] := '';
	end;

       end;


       if (l = 7) and
          lda_a(0) and
          cmp_im_0(1) and
	  bne_a(2) and
          lda_a(3) and
          cmp_im_0(4) and
          lab_a(5) and
	  (pos(#9'jcc l_', listing[6]) > 0 ) then
	begin
	 listing[0] := '';
	 listing[1] := '';
	 listing[2] := '';
	 listing[3] := '';
	 listing[4] := '';
	 listing[5] := '';
	 listing[6] := '';
	end;


       if (l = 7) and					// SHORTINT - UP
          lda_a(0) and (lda_im(0) = false) and
          sub_im(1) and
	  svc(2) and
          (listing[3] = #9'eor #$80') and
          (listing[4] = #9'bmi *+7') and
          (listing[5] = #9'beq *+5') and
	  jmp_l(6) then
	begin
        k := GetBYTE(1) + 1;

	 if k <> $80 then begin
	  listing[1] := #9'sub #' + HexByte(byte(k));

	  listing[4] := #9'asl @';
	  listing[5] := #9'jcc ' + copy(listing[6], 6, 256);
	  listing[6] := '';
	 end;

	end;


       if (l = 6) and					// SHORTINT - DOWN
          lda_a(0) and (lda_im(0) = false) and
          sub_im(1) and
	  svc(2) and
          (listing[3] = #9'eor #$80') and
          (listing[4] = #9'bpl *+5') and
	  jmp_l(5) then
	begin
	 listing[4] := #9'jmi ' + copy(listing[5], 6, 256);
	 listing[5] := '';
	end;


       if (l = 9) and					// WORD #
          lda_a(0) and
          cmp_im(1) and
	  bne_a(2) and
          lda_a(3) and
          cmp_im(4) and
          lab_a(5) and
	  (listing[6] = #9'bcc *+7') and
	  (listing[7] = #9'beq *+5') and
	  jmp_l(8) then
        begin

        k := GetBYTE(1) shl 8 + GetBYTE(4);

	if k = $FFFF then begin
	 listing[0] := '';
	 listing[1] := '';
	 listing[2] := '';
	 listing[3] := '';
	 listing[4] := '';
	 listing[5] := '';
	 listing[6] := '';
	 listing[7] := '';
	 listing[8] := '';
	end else begin
	 listing[5] := listing[4];
	 listing[4] := listing[3];
	 listing[3] := #9'jne ' + copy(listing[8], 6, 256);
	 listing[2] := #9'bcc @+';

	 listing[6] := #9'bcc @+';
	 listing[7] := listing[3];
	 listing[8] := '@';
	end;

        end;


       if (l = 9) and					// WORD zamien miejscami
          lda_a(0) and
          cmp(1) and (cmp_im(1) = false) and
	  bne_a(2) and
          lda_a(3) and
          cmp(4) and (cmp_im(4) = false) and
          lab_a(5) and
	  (listing[6] = #9'bcc *+7') and
	  (listing[7] = #9'beq *+5') and
	  jmp_l(8) then
        begin
	 listing[7] := '@';
	 listing[8] := #9'jcc ' + copy(listing[8], 6, 256);

	 listing[5] := #9'lda ' + copy(listing[4], 6, 256);
	 listing[6] := #9'cmp ' + copy(listing[3], 6, 256);

	 listing[4] := #9'bne @+';

	 listing[2] := #9'lda ' + copy(listing[1], 6, 256);
	 listing[3] := #9'cmp ' + copy(listing[0], 6, 256);

	 listing[0] := '';
	 listing[1] := '';
        end;


       if (l = 15) and					// CARDINAL zamien miejscami
          lda_a(0) and
          cmp(1) and (cmp_im(1) = false) and
	  bne_a(2) and
          lda_a(3) and
          cmp(4) and (cmp_im(4) = false) and
	  bne_a(5) and
          lda_a(6) and
          cmp(7) and (cmp_im(7) = false) and
	  bne_a(8) and
          lda_a(9) and
          cmp(10) and (cmp_im(10) = false) and
          lab_a(11) and
	  (listing[12] = #9'bcc *+7') and
	  (listing[13] = #9'beq *+5') and
	  jmp_l(14) then
	begin
	 listing[13] := '@';
	 listing[14] := #9'jcc ' + copy(listing[14], 6, 256);

	 listing[11] := #9'lda ' + copy(listing[10], 6, 256);
	 listing[12] := #9'cmp ' + copy(listing[9], 6, 256);

	 listing[8] := #9'lda ' + copy(listing[7], 6, 256);
	 listing[9] := #9'cmp ' + copy(listing[6], 6, 256);
	 listing[10] := #9'bne @+';

	 listing[5] := #9'lda ' + copy(listing[4], 6, 256);
	 listing[6] := #9'cmp ' + copy(listing[3], 6, 256);
	 listing[7] := #9'bne @+';

	 listing[2] := #9'lda ' + copy(listing[1], 6, 256);
	 listing[3] := #9'cmp ' + copy(listing[0], 6, 256);
	 listing[4] := #9'bne @+';

	 listing[0] := '';
	 listing[1] := '';
	end;


       if (l = 13) and
          lda_a(0) and
          cmp_im_0(1) and
	  bne_a(2) and
          lda_a(3) and
          cmp_im_0(4) and
	  bne_a(5) and
          lda_a(6) and
          cmp_im_0(7) and
	  bne_a(8) and
          lda_a(9) and
          cmp_im_0(10) and
          lab_a(11) and
	  (pos(#9'jcc l_', listing[12]) > 0 ) then
	begin
	 listing[0] := '';
	 listing[1] := '';
	 listing[2] := '';
	 listing[3] := '';
	 listing[4] := '';
	 listing[5] := '';
	 listing[6] := '';
	 listing[7] := '';
	 listing[8] := '';
	 listing[9] := '';
	 listing[10] := '';
	 listing[11] := '';
	 listing[12] := '';
	end;


       if (l = 15) and
          lda_a(0) and
          (listing[1] = #9'cmp #$FF') and
	  bne_a(2) and
          lda_a(3) and
          (listing[4] = #9'cmp #$FF') and
	  bne_a(5) and
          lda_a(6) and
          (listing[7] = #9'cmp #$FF') and
	  bne_a(8) and
          lda_a(9) and
          (listing[10] = #9'cmp #$FF') and
          lab_a(11) and
	  (listing[12] = #9'bcc *+7') and
	  (listing[13] = #9'beq *+5') and
	  jmp_l(14) then
	begin
	 listing[0] := '';
	 listing[1] := '';
	 listing[2] := '';
	 listing[3] := '';
	 listing[4] := '';
	 listing[5] := '';
	 listing[6] := '';
	 listing[7] := '';
	 listing[8] := '';
	 listing[9] := '';
	 listing[10] := '';
	 listing[11] := '';
	 listing[12] := '';
	 listing[13] := '';
	 listing[14] := '';
	end;


       if (l = 20) and				// SMALLINT - UP
          LOCAL(0) and
	  lda_a(1) and (lda_im(1) = false) and
	  sub_im(2) and
          (listing[3] = #9'bne L4') and
	  lda_a(4) and (lda_im(4) = false) and
	  cmp_im(5) and
          (listing[6] = 'L1'#9'beq L5') and
          (listing[7] = #9'bcs L3') and
          (listing[8] = #9'lda #$FF') and
          (listing[9] = #9'bne L5') and
          (listing[10] = 'L3'#9'lda #$01') and
          (listing[11] = #9'bne L5') and
          (listing[12] = 'L4'#9'bvc L5') and
          (listing[13] = #9'eor #$FF') and
          (listing[14] = #9'ora #$01') and
          (listing[15] = 'L5') and
          ENDL(16) and
          (listing[17] = #9'bmi *+7') and
          (listing[18] = #9'beq *+5') and
	  jmp_l(19) then
	begin
         k := GetBYTE(2) shl 8 + GetBYTE(5) + 1;

         if k <> $8000 then begin
	  listing[5] := #9'cmp #' + HexByte(byte(k));
	  listing[6] := listing[1];
	  listing[7] := #9'sbc #' + HexByte(byte(k shr 8));
	  listing[8] := #9'svc';
	  listing[9] := #9'eor #$80';
	  listing[10] := #9'asl @';
	  listing[11] := #9'jcc ' + copy(listing[19], 6, 256);
	  listing[12] := '';
	  listing[13] := '';
	  listing[14] := '';
	  listing[15] := '';
	  listing[16] := '';
	  listing[17] := '';
	  listing[18] := '';
	  listing[19] := '';

	  listing[0] := '';
	  listing[1] := '';
	  listing[2] := '';
	  listing[3] := '';
	 end;

	end;


       if (l = 19) and				// SMALLINT - DOWN
          LOCAL(0) and
	  lda_a(1) and (lda_im(1) = false) and
	  sub_im(2) and
          (listing[3] = #9'bne L4') and
	  lda_a(4) and (lda_im(4) = false) and
	  cmp_im(5) and
          (listing[6] = 'L1'#9'beq L5') and
          (listing[7] = #9'bcs L3') and
          (listing[8] = #9'lda #$FF') and
          (listing[9] = #9'bne L5') and
          (listing[10] = 'L3'#9'lda #$01') and
          (listing[11] = #9'bne L5') and
          (listing[12] = 'L4'#9'bvc L5') and
          (listing[13] = #9'eor #$FF') and
          (listing[14] = #9'ora #$01') and
          (listing[15] = 'L5') and
          ENDL(16) and
          (listing[17] = #9'bpl *+5') and
	  jmp_l(18) then
	begin
         k := GetBYTE(2) shl 8 + GetBYTE(5);

         if k <> $8000 then begin
	  listing[5] := #9'cmp #' + HexByte(byte(k));
	  listing[6] := listing[1];
	  listing[7] := #9'sbc #' + HexByte(byte(k shr 8));
	  listing[8] := #9'svc';
	  listing[9] := #9'eor #$80';
	  listing[10] := #9'jmi ' + copy(listing[18], 6, 256);
	  listing[11] := '';
	  listing[12] := '';
	  listing[13] := '';
	  listing[14] := '';
	  listing[15] := '';
	  listing[16] := '';
	  listing[17] := '';
	  listing[18] := '';

	  listing[0] := '';
	  listing[1] := '';
	  listing[2] := '';
	  listing[3] := '';
	 end;

	end;

      end;

     end;


end;		// procedure
