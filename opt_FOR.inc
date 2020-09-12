(* -------------------------------------------------------------------------- *)
//				opty FOR.
(* -------------------------------------------------------------------------- *)

//  Rebuild;

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

      Rebuild;

      if l > 0 then begin

       if (l = 3) and					// BYTE
          lda(0) and
          (listing[1] = #9'cmp #$00') and
	  (pos('jcc l_', listing[2]) > 0 ) then
	begin
	 listing[0] := #9'#for:dec ' + copy(listing[0], 6, 256);
	 listing[1] := '';
	 listing[2] := '';
	end;


       if (l = 5) and
          lda(0) and
          cmp_im(1) and
	  (listing[2] = #9'bcc *+7') and
	  (listing[3] = #9'beq *+5') and
	  (pos('jmp l_', listing[4]) > 0 ) then
        begin
        k := GetBYTE(1) + 1;

        if k < $100 then begin

         if k = $80 then begin
 	  listing[1] := '';
 	  listing[2] := '';
 	  listing[3] := '';
 	  listing[4] := #9'jmi ' + copy(listing[4], 6, 256);
 	 end else begin
	  listing[1] := #9'cmp #$'+IntToHex(k and $ff, 2);
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
          lda(0) and
          (listing[1] = #9'cmp #$00') and
	  (listing[2] = #9'bne @+') and
          lda(3) and
          (listing[4] = #9'cmp #$00') and
          (listing[5] = '@') and
	  (pos('jcc l_', listing[6]) > 0 ) then
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
          lda(0) and (lda_im(0) = false) and
          sub_im(1) and
	  (listing[2] = #9'svc') and
          (listing[3] = #9'eor #$80') and
          (listing[4] = #9'bmi *+7') and
          (listing[5] = #9'beq *+5') and
	  (pos('jmp l_', listing[6]) > 0 ) then
	begin
        k := GetBYTE(1) + 1;

	 if k <> $80 then begin
	  listing[1] := #9'sub #$' + IntToHex(k and $ff, 2);

	  listing[4] := #9'asl @';
	  listing[5] := #9'jcc ' + copy(listing[6], 6, 256);
	  listing[6] := '';
	 end;

	end;


       if (l = 6) and					// SHORTINT - DOWN
          lda(0) and (lda_im(0) = false) and
          sub_im(1) and
	  (listing[2] = #9'svc') and
          (listing[3] = #9'eor #$80') and
          (listing[4] = #9'bpl *+5') and
	  (pos('jmp l_', listing[5]) > 0 ) then
	begin
	 listing[4] := #9'jmi ' + copy(listing[5], 6, 256);
	 listing[5] := '';
	end;


       if (l = 9) and					// WORD
          lda(0) and
          cmp_im(1) and
	  (listing[2] = #9'bne @+') and
          lda(3) and
          cmp_im(4) and
          (listing[5] = '@') and
	  (listing[6] = #9'bcc *+7') and
	  (listing[7] = #9'beq *+5') and
	  (pos('jmp l_', listing[8]) > 0 ) then
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


{
       if (l = 9) and					// WORD
          lda(0) and
          cmp_im(1) and
	  (listing[2] = #9'bne @+') and
          lda(3) and
          cmp_im(4) and
          (listing[5] = '@') and
	  (listing[6] = #9'bcc *+7') and
	  (listing[7] = #9'beq *+5') and
	  (pos('jmp l_', listing[8]) > 0 ) then
        begin

        k := GetBYTE(1) shl 8 + GetBYTE(4) + 1;

        if k < $10000 then begin

	 if k = $8000 then begin
	  listing[1] := '';
	  listing[2] := '';
	  listing[3] := '';
	  listing[4] := '';
	  listing[5] := '';
	  listing[6] := '';
	  listing[7] := '';
	  listing[8] := #9'jmi ' + copy(listing[8], 6, 256);
	 end else begin

          if byte(k shr 8) = 0 then
	   listing[1] := ''
	  else
	   listing[1] := #9'cmp #$' + IntToHex(byte(k shr 8), 2);

	  if k and $ff = 0 then begin
	   listing[2] := #9'sne';

	   listing[4] := '';
	   listing[5] := '';
	  end else
	   listing[4] := #9'cmp #$' + IntToHex(k and $ff, 2);

	  listing[6] := '';
 	  listing[7] := '';
  	  listing[8] := #9'jcs ' + copy(listing[8], 6, 256);

	 end;

        end else begin
	 listing[0] := '';
	 listing[1] := '';
	 listing[2] := '';
	 listing[3] := '';
	 listing[4] := '';
	 listing[5] := '';
	 listing[6] := '';
	 listing[7] := '';
	 listing[8] := '';
        end;

       end;
}

       if (l = 13) and
          lda(0) and
          (listing[1] = #9'cmp #$00') and
	  (listing[2] = #9'bne @+') and
          lda(3) and
          (listing[4] = #9'cmp #$00') and
	  (listing[5] = #9'bne @+') and
          lda(6) and
          (listing[7] = #9'cmp #$00') and
	  (listing[8] = #9'bne @+') and
          lda(9) and
          (listing[10] = #9'cmp #$00') and
          (listing[11] = '@') and
	  (pos('jcc l_', listing[12]) > 0 ) then
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
          lda(0) and
          (listing[1] = #9'cmp #$FF') and
	  (listing[2] = #9'bne @+') and
          lda(3) and
          (listing[4] = #9'cmp #$FF') and
	  (listing[5] = #9'bne @+') and
          lda(6) and
          (listing[7] = #9'cmp #$FF') and
	  (listing[8] = #9'bne @+') and
          lda(9) and
          (listing[10] = #9'cmp #$FF') and
          (listing[11] = '@') and
	  (listing[12] = #9'bcc *+7') and
	  (listing[13] = #9'beq *+5') and
	  (pos('jmp l_', listing[14]) > 0 ) then
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
          (listing[0] = #9'.LOCAL') and
	  lda(1) and (lda_im(1) = false) and
	  sub_im(2) and
          (listing[3] = #9'bne L4') and
	  lda(4) and (lda_im(4) = false) and
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
          (listing[16] = #9'.ENDL') and
          (listing[17] = #9'bmi *+7') and
          (listing[18] = #9'beq *+5') and
	  (pos('jmp l_', listing[19]) > 0 ) then
	begin
         k := GetBYTE(2) shl 8 + GetBYTE(5) + 1;

         if k <> $8000 then begin
	  listing[5] := #9'cmp #$' + IntToHex(k and $ff, 2);
	  listing[6] := listing[1];
	  listing[7] := #9'sbc #$' + IntToHex(byte(k shr 8), 2);
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
          (listing[0] = #9'.LOCAL') and
	  lda(1) and (lda_im(1) = false) and
	  sub_im(2) and
          (listing[3] = #9'bne L4') and
	  lda(4) and (lda_im(4) = false) and
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
          (listing[16] = #9'.ENDL') and
          (listing[17] = #9'bpl *+5') and
	  (pos('jmp l_', listing[18]) > 0 ) then
	begin
         k := GetBYTE(2) shl 8 + GetBYTE(5);

         if k <> $8000 then begin
	  listing[5] := #9'cmp #$' + IntToHex(k and $ff, 2);
	  listing[6] := listing[1];
	  listing[7] := #9'sbc #$' + IntToHex(byte(k shr 8), 2);
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
