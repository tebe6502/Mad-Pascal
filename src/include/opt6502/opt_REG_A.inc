
procedure opt_REG_A;
var i, k: integer;
begin

// -------------------------------------------------------------------------- //
//				      REG A.
// -------------------------------------------------------------------------- //

   Rebuild('opt_REG_A');;

   for i := 0 to l - 1 do
    if mva_im(i) or
       (mva(i) and (mva_adr(i) = false) and (STACK(i) = false) and (iy(i) = false)) or
       (lda_val(i) and (iy(i) = false)) then
    begin

     arg0 := GetString(i);

     if SKIP(i+1) or
        ((i > 0) and (LOCAL(i-1) or (SKIP(i-1) and lda_im(i)))) then

//     else					// !!! nie zadziala poprawnie gdy jednoczesnie A i Y wystapia w tym samym bloku kodu
//     if (arg0 = optyY) and sta_a(i+1) then
//      listing[i] := #9'tya'
     else
     if (arg0 = optyA) then
//      if mva_im(i) then
//       listing[i] := #9'sta ' + copy(listing[i], pos('mva #', listing[i]) + 9, 256)
//      else
      if mva(i) then
       listing[i] := #9'sta ' + GetStringLast(i)
      else
       listing[i] := '';

     SetOptyA(arg0);

    end else
     if (mva(i) and (iy(i)=false)) then begin

      if mva_stack(i) then
       arg0 := ''
      else begin
       arg0 := listing[i];
       k := length(listing[i]);

       while arg0[k] <> ' ' do dec(k);

       arg0 := copy(arg0, k+1, 256);
      end;

      SetOptyA(arg0);

     end else
     if tya(i) or and_ora_eor(i) or add_sub(i) or adc_sbc(i) or asl(i) or lsr(i) or rol(i) or ror(i) then begin

       if sta_a(i+1) and (iy(i+1) = false) then
        arg0 := GetString(i+1)
       else
        arg0 := '';

       SetOptyA(arg0);

     end else
     if ((optyA <> '') and sty(i) and (listing[i] = #9'sty ' + optyA)) or
        lda_a(i) or mva(i) or mwa(i) or tya(i) or lab_a(i) or jsr(i) or
        lab_l(i) or lab_b(i) or lab_c(i) or //SKIP(i) or
	_for(i) or _if(i) then begin arg0 := ''; SetOptyA('') end;


end;		// procedure
