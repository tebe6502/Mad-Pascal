
// -----------------------------------------------------------------------------
// ===		     		      TEMP.
// -----------------------------------------------------------------------------

procedure opt_TEMP_LDA;

type
   THit = array [0..127] of record
         	 	  value : smallint;
			  sta: string;
	    		end;

var p, a, i_hit, x, l: integer;

    hit: THit;


  procedure storeValue(v: byte);
  var k: integer;
  begin

    TemporaryBuf[l] := #9'lda #' + HexByte(v);
    inc(l);

    for k := 0 to i_hit-1 do
     if hit[k].value = v then begin
       TemporaryBuf[l] := hit[k].sta;

       hit[k].value := -1;

       inc(l);
     end;

  end;


begin


    if lda_im(0) and									// lda #		; 0
       sta(1) and									// sta			; 1
       lda_im(2) then									// lda #		; 2
      begin

	hit := Default(THit);

	p := 0;
	a := 0;
	i_hit := 0;

	l:=0;

	while (lda_im(p) or sta(p)) and (p < 128) do begin		// search and collect lda #;sta

	 if lda_im(p) then begin
	  a := GetBYTE(p);
	  if a < 0 then exit;
	 end;

	 if sta(p) then begin
	  hit[i_hit].value := a;
	  hit[i_hit].sta   := TemporaryBuf[p];

	  inc(i_hit);
	 end;

	 inc(p);
	end;

	while (sta(p-1) = false) do dec(p);


	for x := 0 to p-1 do TemporaryBuf[x] := '~';

        for x := 0 to i_hit-1 do
         if (hit[x].value >= 0) and (hit[x].value <> a) then storeValue( hit[x].value );

	storeValue(a);

      end;


end;	// procedure
