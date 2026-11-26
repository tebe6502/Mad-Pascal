
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
    tmp: string;
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


    if mva_im(0) and									// mva #		; 0
       lda_im(1) and									// lda #		; 1
       sta(2) then									// sta			; 2
      if getString(0) = GetARG(1) then
      begin

	TemporaryBuf[1] := '~';

      end;


    if lda_im(0) and cmpBUF(0, 4) and							// lda #		; 0
       sta(1) and (sta_stack(1)	= false) and						// sta			; 1
       lda(2) and (lda_im(2) = false) and						// lda			; 2
       sta(3) and (sta_stack(3)	= false) and						// sta			; 3
//       lda_im(4) and									// lda #		; 4
       sta(5) and (sta_stack(5) = false) then						// sta			; 5
      begin

	tmp := TemporaryBuf[1];

	TemporaryBuf[0] := TemporaryBuf[2];
	TemporaryBuf[1] := TemporaryBuf[3];
	TemporaryBuf[2] := TemporaryBuf[4];
	TemporaryBuf[3] := TemporaryBuf[5];

	TemporaryBuf[4] := TemporaryBuf[2];
	TemporaryBuf[5] := tmp;

      end;


end;	// procedure
