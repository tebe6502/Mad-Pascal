
procedure opt_REG_Y;
var i, k: integer;
begin

// -------------------------------------------------------------------------- //
//				     REG Y.
// -------------------------------------------------------------------------- //

  Rebuild;

   for i := 0 to l - 1 do
    if ldy_val(i) {and (iny(i+1) = false) and (dey(i+1) = false)} then begin

     arg0:=GetString(i);

     if ldy_im_0(i) and lda(i+1) and spl(i+2) then begin
      arg0:=''; optyY:='';
     end else

     if arg0 = optyY then
       listing[i] := ''
     else begin

       if (optyY <> '') and (pos('#$', optyY) = 1) and (pos('#$', arg0) = 1) then begin					// #$xx ? #$xx

         k:=StrToInt(copy(arg0, 2, 256)) - StrToInt(copy(optyY, 2, 256));

 	 if k = 1 then listing[i] := #9'iny' else
	   if k = -1 then listing[i] := #9'dey';

       end;

       optyY := arg0;

     end;

    end else
// --------------------------------------------------------------------------
// 					INY
// --------------------------------------------------------------------------
     if iny(i) then begin

      if SKIP(i-1) then begin
       arg0:=''; optyY:='';
      end else

      if optyY <> '' then
       if (optyY[1] = '#') and (optyY[2] = '$') then
        optyY:='#' + HexByte( byte( StrToInt(copy(optyY,2,256)) + 1))						// #$xx
       else
        optyY:='+#$01'+optyY;											// +#$01

     end else
// --------------------------------------------------------------------------
// 					DEY
// --------------------------------------------------------------------------
     if dey(i) then begin

      if SKIP(i-1) then begin
       arg0:=''; optyY:='';
      end else

      if optyY <> '' then
       if (optyY[1] = '#') and (optyY[2] = '$') then
        optyY:='#' + HexByte( byte( StrToInt(copy(optyY,2,256)) - 1))						// #$xx
       else
        optyY:='-#$01'+optyY;											// -#$01

     end else
// --------------------------------------------------------------------------
// 					TAY
// --------------------------------------------------------------------------
     if tay(i) then begin

      if (i>1) and
         ( (add_sub_val(i-1) and (adc_sbc(i+2) = false) and lda_val(i-2) and (iy(i-2) = false)) or
           (asl_a(i-1) and lda_val(i-2) and (iy(i-2) = false)) or

           ((i > 2) and asl_a(i-1) and asl_a(i-2) and lda_val(i-3) and (iy(i-3) = false)) or
           ((i > 3) and asl_a(i-1) and asl_a(i-2) and asl_a(i-3) and lda_val(i-4) and (iy(i-4) = false)) or

           ((i > 2) and add(i-1) and asl_a(i-2) and lda_val(i-3) and argMatch(i-1, i-3) and (iy(i-3) = false)) or

           ((i > 5) and add(i-1) and asl_a(i-2) and add(i-3) and asl_a(i-4) and asl_a(i-5) and lda_val(i-6) and argMatch(i-3, i-6) and (iy(i-6) = false)) )

      then begin

       if add_im(i-1) and lda_a(i-2) then arg0 := '+' + copy(listing[i-1], 6, 256) + GetString(i-2);			// +#$00Label
       if sub_im(i-1) and lda_a(i-2) then arg0 := '-' + copy(listing[i-1], 6, 256) + GetString(i-2);			// -#$00Label


       if add(i-1) and (add_im(i-1) = false) and lda_a(i-2) then							// *+$01Label|Label
        if GetString(i-1) >= GetString(i-2) then
         arg0 := '*+$01' + GetString(i-1) + '|' + GetString(i-2)
	else
         arg0 := '*+$01' + GetString(i-2) + '|' + GetString(i-1);

       if sub(i-1) and (sub_im(i-1) = false) and lda_a(i-2) then							// *-$01Label|Label
        if GetString(i-1) >= GetString(i-2) then
         arg0 := '*-$01' + GetString(i-1) + '|' + GetString(i-2)
	else
         arg0 := '*-$01' + GetString(i-2) + '|' + GetString(i-1);


       if asl_a(i-1) and lda_a(i-2) then arg0 := '*#$02' + GetString(i-2);						// *#$02Label

       if (i > 2) and asl_a(i-1) and asl_a(i-2) and lda_a(i-3) then arg0 := '*#$04' + GetString(i-3);			// *#$04Label
       if (i > 3) and asl_a(i-1) and asl_a(i-2) and asl_a(i-3) and lda_a(i-4) then arg0 := '*#$08' + GetString(i-4);	// *#$08Label

       if (i > 2) and add(i-1) and asl_a(i-2) and lda_a(i-3) then arg0 := '*#$03' + GetString(i-3);			// *#$03Label

       if (i > 5) and add(i-1) and asl_a(i-2) and add(i-3) and asl_a(i-4) and asl_a(i-5) and lda_a(i-6) then arg0 := '*#$0A' + GetString(i-6)+'+'+GetString(i-1);	// *#$0ALabel1+Label2


       if arg0 = optyY then begin

        if (i > 5) and add(i-1) and asl_a(i-2) and add(i-3) and asl_a(i-4) and asl_a(i-5) and lda_a(i-6) then begin
         listing[i-6] := '';
         listing[i-5] := '';
         listing[i-4] := '';
         listing[i-3] := '';
         listing[i-2] := '';
         listing[i-1] := '';
         listing[i]   := '';
	end else
        if (i > 3) and asl_a(i-1) and asl_a(i-2) and asl_a(i-3) and lda_a(i-4) then begin
         listing[i-4] := '';
         listing[i-3] := '';
         listing[i-2] := '';
         listing[i-1] := '';
         listing[i]   := '';
	end else
        if (i > 2) and add(i-1) and asl_a(i-2) and lda_a(i-3) then begin
         listing[i-3] := '';
         listing[i-2] := '';
         listing[i-1] := '';
         listing[i]   := '';
	end else
        if (i > 2) and asl_a(i-1) and asl_a(i-2) and lda_a(i-3) then begin
         listing[i-3] := '';
         listing[i-2] := '';
         listing[i-1] := '';
         listing[i]   := '';
	end else begin
         listing[i-2] := '';
         listing[i-1] := '';
         listing[i]   := '';
	end;

       end else
	if (optyY <> '') and (arg0[1] = '+') and (optyY[1] = '+') then begin
	  k:=StrToInt(copy(arg0, 3, 3)) - StrToInt(copy(optyY, 3, 3));

	  if k = 1 then begin
	   listing[i-2] := '';
	   listing[i-1] := '';
	   listing[i]   := #9'iny';

	   if lda_a(i+1) and adc_im_0(i+2) and sta_a(i+3) then begin
	    listing[i+1] := '';
	    listing[i+2] := '';
	    listing[i+3] := '';
	   end;

	  end else
	  if k = -1 then begin
	   listing[i-2] := '';
	   listing[i-1] := '';
	   listing[i]   := #9'dey';

	   if lda_a(i+1) and adc_im_0(i+2) and sta_a(i+3) then begin
	    listing[i+1] := '';
	    listing[i+2] := '';
	    listing[i+3] := '';
	   end;

	  end;

//	writeln(optyY,' | ',StrToInt(copy(optyY, 3, 3)),' : ',arg0,' | ', StrToInt(copy(arg0, 3, 3)),' = ',k);

        end else
	if (optyY <> '') and (arg0[1] = '-') and (optyY[1] = '-') then begin
	  k:=StrToInt(copy(arg0, 3, 3)) - StrToInt(copy(optyY, 3, 3));

	  if k = 1 then begin
	   listing[i-2] := '';
	   listing[i-1] := '';
	   listing[i]   := #9'dey';

	   if lda_a(i+1) and adc_im_0(i+2) and sta_a(i+3) then begin
	    listing[i+1] := '';
	    listing[i+2] := '';
	    listing[i+3] := '';
	   end;

	  end else
	  if k = -1 then begin
	   listing[i-2] := '';
	   listing[i-1] := '';
	   listing[i]   := #9'iny';

	   if lda_a(i+1) and adc_im_0(i+2) and sta_a(i+3) then begin
	    listing[i+1] := '';
	    listing[i+2] := '';
	    listing[i+3] := '';
	   end;

	  end;

//	writeln(optyY,' | ',StrToInt(copy(optyY, 3, 3)),' : ',arg0,' | ', StrToInt(copy(arg0, 3, 3)),' = ',k);

        end;

       optyY := arg0;

      end else begin
       arg0 := ''; optyY := '';
      end;

     end else

     if LabelIsUsed(i) or iny(i) or dey(i) or tay(i) or ldy_stack(i) or mvy(i) or mwy(i) or jsr(i) or
        (pos(',y-', listing[i]) > 0) or (pos(',y+', listing[i]) > 0) or ((optyA <> '') and (optyA = optyY)) or
        {(listing[i] = '@') or} lab_l(i) or lab_b(i) or lab_c(i) or
	_for(i) or _if(i) then begin arg0 := ''; optyY := '' end;


end;		// procedure
