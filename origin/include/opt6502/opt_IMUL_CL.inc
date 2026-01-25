
(*

	main function implementing optimization of (u8 * u8 = u16) multiplication

*)


function imulCL_opt: Boolean;
 (*	in:

	lda var		; 0
	sta ecx		; 1
	lda #		; 2
	sta eax		; 3

	IFDEF_MUL8	; 4
 *)
 var tmp: string;
 begin

   Result:=true;					// value TRUE, optimization has not been performed
							// value FALSE, optimization has been performed

   if //(l = 9) and
      IFDEF_MUL8(m+4) then								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       						 					// imulCL				; 7
       											// eif					; 8
   begin


     if sta_eax(m+1) and				// establishing the correct order of the registers 1: ECX, 2: EAX
        sta_ecx(m+3) then
     begin
	listing[m+1] := #9'sta :ecx';

	listing[m+3] := #9'sta :eax';
     end;


     if lda_im(m) and					// determining the correct order of addressing mode
        lda_a(m+2) and (lda_im(m+2) = false) then
     begin
	tmp := listing[m+2];

	listing[m+2] := listing[m];

	listing[m] := tmp;
     end;



   if (m > 1) and lda_stack(m) then			// we are trying to get rid of the parameter on the stack

    if sta_stack(m-1) and argMatch(m, m-1) and
       lda_val(m-2) and (lda_im(m-2) = false) then

      begin
       listing[m] := listing[m-2];

       listing[m-2] := '';
       listing[m-1] := '';
      end;


// --------------------------------------------------------------------------


    if lda_im(m+2) then
      k:=GetBYTE(m+2)
    else
      k:=-1;


    if (k in [0, 1, 2, 4, 8, 16, 32]) and						// lda #				; 2

       (lda_im(m) = false) and								// lda var				; 0
       sta_ecx(m+1) and									// sta :ecx				; 1

       sta_eax(m+3) then								// sta :eax				; 3
     begin

       	s[x-1][1] := #9'lda #$00';
       	s[x-1][2] := '';
      	s[x-1][3] := '';

       	l := m;				// restore L

	if lda_val(l) then
	 s[x-1][0] := listing[l]
	else begin
	 s[x-1][0] := '';

	 listing[l+1] := #9'sta ' + GetARG(0, x-1);
	 inc(l,2);
	end;


       	case k of
	   2: index(1, x-1, false);
	   4: index(2, x-1, false);
	   8: index(3, x-1, false);
	  16: index(4, x-1, false);
	  32: index(5, x-1, false);
       	end;


       	if k in [0,1] then begin

	  if k=0 then listing[l] := #9'lda #$00';

	  s[x-1][0] := '';
	  s[x-1][1] := '';

	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda #$00';
	  listing[l+3] := #9'sta :eax+1';

	  inc(l, 4);

       	end else begin

	  listing[l]   := #9'lda ' + GetARG(0, x-1);
	  listing[l+1] := #9'sta :eax';
	  listing[l+2] := #9'lda ' + GetARG(1, x-1);
	  listing[l+3] := #9'sta :eax+1';

	  inc(l, 4);

       	end;

      exit(false);
     end;


// --------------------------------------------------------------------------


  if (k in [3, 5, 6, 7, 10, 24, 40, 64, 96, 128, 255]) and				// lda #				; 2

     (lda_im(m) = false) and								// lda var				; 0
     sta_ecx(m+1) and									// sta :ecx				; 1

     sta_eax(m+3) then									// sta :eax				; 3
  begin


   case k of

    3: begin

	s[x-1][1] := #9'lda #$00';

	if lda_val(m) then
	 s[x-1][0] := #9'lda #$00'
	else
	 s[x-1][0] := '';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda ' + GetARG(1, x-1);
	listing[m+3] := #9'sta ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+4] := listing[m]
	else
	 listing[m+4] := #9'lda ' + GetARG(0, x-1);

	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+7] := #9'add ' + copy(listing[m], 6, 256)
	else
	 listing[m+7] := #9'add ' + GetARG(0, x-1);

	listing[m+8] := #9'sta ' + GetARG(0, x-1);
	listing[m+9] := #9'lda ' + GetARG(1, x-1);
	listing[m+10]:= #9'adc #$00';
	listing[m+11]:= #9'sta ' + GetARG(1, x-1);

	listing[m+12]:= #9'lda ' + GetARG(0, x-1);		// this redundant record is important to make other optimizations work
	listing[m+13]:= #9'sta :eax';				// writing to the :EAX register will be eliminated
	listing[m+14]:= #9'lda ' + GetARG(1, x-1);
	listing[m+15]:= #9'sta :eax+1';

	l := m + 16;
	exit(false);

       end;


    5: begin

       	s[x-1][1] := #9'lda #$00';

	if lda_val(m) then
	 s[x-1][0] := #9'lda #$00'
	else
	 s[x-1][0] := '';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda ' + GetARG(1, x-1);
	listing[m+3] := #9'sta ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+4] := listing[m]
	else
	 listing[m+4] := #9'lda ' + GetARG(0, x-1);

	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol ' + GetARG(1, x-1);
	listing[m+7] := #9'asl @';
	listing[m+8] := #9'rol ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+9] := #9'add ' + copy(listing[m], 6, 256)
	else
	 listing[m+9] := #9'add ' + GetARG(0, x-1);

	listing[m+10]:= #9'sta ' + GetARG(0, x-1);
	listing[m+11]:= #9'lda ' + GetARG(1, x-1);
	listing[m+12]:= #9'adc #$00';
	listing[m+13]:= #9'sta ' + GetARG(1, x-1);

	listing[m+14]:= #9'lda ' + GetARG(0, x-1);
	listing[m+15]:= #9'sta :eax';
	listing[m+16]:= #9'lda ' + GetARG(1, x-1);
	listing[m+17]:= #9'sta :eax+1';

	l := m + 18;
	exit(false);

       end;


    6: begin

       	s[x-1][1] := #9'lda #$00';

	if lda_val(m) then
	 s[x-1][0] := #9'lda #$00'
	else
	 s[x-1][0] := '';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda ' + GetARG(1, x-1);
	listing[m+3] := #9'sta ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+4] := listing[m]
	else
	 listing[m+4] := #9'lda ' + GetARG(0, x-1);

	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol ' + GetARG(1, x-1);
	listing[m+7] := #9'sta ' + GetARG(0, x-1);

	listing[m+8] := #9'ldy ' + GetARG(1, x-1);

	listing[m+9] := #9'asl @';
	listing[m+10]:= #9'rol ' + GetARG(1, x-1);

	listing[m+11]:= #9'add ' + GetARG(0, x-1);
	listing[m+12]:= #9'sta ' + GetARG(0, x-1);
	listing[m+13]:= #9'tya';
	listing[m+14]:= #9'adc ' + GetARG(1, x-1);
	listing[m+15]:= #9'sta ' + GetARG(1, x-1);

	listing[m+16]:= #9'lda ' + GetARG(0, x-1);
	listing[m+17]:= #9'sta :eax';
	listing[m+18]:= #9'lda ' + GetARG(1, x-1);
	listing[m+19]:= #9'sta :eax+1';

	l := m + 20;
	exit(false);

       end;


    7: begin

	s[x-1][1] := #9'lda #$00';

	if lda_val(m) then
	 s[x-1][0] := #9'lda #$00'
	else
	 s[x-1][0] := '';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda ' + GetARG(1, x-1);
	listing[m+3] := #9'sta ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+4] := listing[m]
	else
	 listing[m+4] := #9'lda ' + GetARG(0, x-1);

	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol ' + GetARG(1, x-1);
	listing[m+7] := #9'asl @';
	listing[m+8] := #9'rol ' + GetARG(1, x-1);
	listing[m+9] := #9'asl @';
	listing[m+10]:= #9'rol ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+11] := #9'sub ' + copy(listing[m], 6, 256)
	else
	 listing[m+11] := #9'sub ' + GetARG(0, x-1);

	listing[m+12] := #9'sta ' + GetARG(0, x-1);
	listing[m+13] := #9'lda ' + GetARG(1, x-1);
	listing[m+14] := #9'sbc #$00';
	listing[m+15] := #9'sta ' + GetARG(1, x-1);

	listing[m+16]:= #9'lda ' + GetARG(0, x-1);
	listing[m+17]:= #9'sta :eax';
	listing[m+18]:= #9'lda ' + GetARG(1, x-1);
	listing[m+19]:= #9'sta :eax+1';

	l := m + 20;
	exit(false);

       end;


   10: begin

	s[x-1][0] := '';
       	s[x-1][1] := #9'lda #$00';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda ' + GetARG(1, x-1);
	listing[m+3] := #9'sta ' + GetARG(1, x-1);

	listing[m+4] := #9'lda ' + GetARG(0, x-1);
	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol ' + GetARG(1, x-1);
	listing[m+7] := #9'asl @';
	listing[m+8] := #9'rol ' + GetARG(1, x-1);

	listing[m+9] := #9'add ' + GetARG(0, x-1);
	listing[m+10]:= #9'sta ' + GetARG(0, x-1);
	listing[m+11]:= #9'lda ' + GetARG(1, x-1);
	listing[m+12]:= #9'adc #$00';
	listing[m+13]:= #9'sta ' + GetARG(1, x-1);

	listing[m+14]:= #9'asl ' + GetARG(0, x-1);
	listing[m+15]:= #9'rol ' + GetARG(1, x-1);

	listing[m+16]:= #9'lda ' + GetARG(0, x-1);
	listing[m+17]:= #9'sta :eax';
	listing[m+18]:= #9'lda ' + GetARG(1, x-1);
	listing[m+19]:= #9'sta :eax+1';

	l := m + 20;
	exit(false);

       end;


   24: begin

       	s[x-1][1] := #9'lda #$00';

	if lda_val(m) then
	 s[x-1][0] := #9'lda #$00'
	else
	 s[x-1][0] := '';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda ' + GetARG(1, x-1);
	listing[m+3] := #9'sta ' + GetARG(1, x-1);

	if lda_val(m) then
	 listing[m+4] := listing[m]
	else
	 listing[m+4] := #9'lda ' + GetARG(0, x-1);

	listing[m+5] := #9'asl @';
	listing[m+6] := #9'rol ' + GetARG(1, x-1);
	listing[m+7] := #9'asl @';
	listing[m+8] := #9'rol ' + GetARG(1, x-1);
	listing[m+9] := #9'asl @';
	listing[m+10]:= #9'rol ' + GetARG(1, x-1);

	listing[m+11]:= #9'sta ' + GetARG(0, x-1);
	listing[m+12]:= #9'ldy ' + GetARG(1, x-1);

	listing[m+13]:= #9'asl @';
	listing[m+14]:= #9'rol ' + GetARG(1, x-1);

	listing[m+15]:= #9'add ' + GetARG(0, x-1);
	listing[m+16]:= #9'sta ' + GetARG(0, x-1);
	listing[m+17]:= #9'tya';
	listing[m+18]:= #9'adc ' + GetARG(1, x-1);
	listing[m+19]:= #9'sta ' + GetARG(1, x-1);

	listing[m+20]:= #9'lda ' + GetARG(0, x-1);
	listing[m+21]:= #9'sta :eax';
	listing[m+22]:= #9'lda ' + GetARG(1, x-1);
	listing[m+23]:= #9'sta :eax+1';

	l := m + 24;
	exit(false);

       end;


   40: begin

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[m+1] := #9'jsr @mul40';

	l := m + 2;
	exit(false);

       end;


   64: begin

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[m+1] := #9'sta ' + GetARG(1, x-1);
	listing[m+2] := #9'lda #$00';
	listing[m+3] := #9'lsr ' + GetARG(1, x-1);
	listing[m+4] := #9'ror @';
	listing[m+5] := #9'lsr ' + GetARG(1, x-1);
	listing[m+6] := #9'ror @';
	listing[m+7] := #9'sta ' + GetARG(0, x-1);

	listing[m+8] := #9'lda ' + GetARG(0, x-1);
	listing[m+9] := #9'sta :eax';
	listing[m+10]:= #9'lda ' + GetARG(1, x-1);
	listing[m+11]:= #9'sta :eax+1';

	l := m + 12;
	exit(false);

       end;


   96: begin

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[m+1] := #9'jsr @mul96';

	l := m + 2;
	exit(false);

       end;


  128: begin

	s[x-1][0] := '';
	s[x-1][1] := '';

	listing[m+1] := #9'sta ' + GetARG(1, x-1);
	listing[m+2] := #9'lda #$00';
	listing[m+3] := #9'lsr ' + GetARG(1, x-1);
	listing[m+4] := #9'ror @';
	listing[m+5] := #9'sta ' + GetARG(0, x-1);

	listing[m+6] := #9'lda ' + GetARG(0, x-1);
	listing[m+7] := #9'sta :eax';
	listing[m+8] := #9'lda ' + GetARG(1, x-1);
	listing[m+9] := #9'sta :eax+1';

	l := m + 10;
	exit(false);

       end;


  255: begin

	s[x-1][0] := '';
	s[x-1][1] := '';

	if lda_val(m) then
	 s[x-1][0] := #9'lda #$00'
	else
	 s[x-1][0] := '';

	listing[m+1] := #9'sta ' + GetARG(0, x-1);

	listing[m+2] := #9'lda #$00';

	if lda_val(m) then
	 listing[m+3] := #9'sub ' + copy(listing[m], 6, 256)
	else
	 listing[m+3] := #9'sub ' + GetARG(0, x-1);

	listing[m+4] := #9'sta ' + GetARG(0, x-1);

	if lda_val(m) then
	 listing[m+5] := #9'lda ' + copy(listing[m], 6, 256)
	else
	 listing[m+5] := #9'lda ' + GetARG(0, x-1);

	listing[m+6] := #9'sbc #$00';
	listing[m+7] := #9'sta ' + GetARG(1, x-1);

	listing[m+8] := #9'lda ' + GetARG(0, x-1);
	listing[m+9] := #9'sta :eax';
	listing[m+10]:= #9'lda ' + GetARG(1, x-1);
	listing[m+11]:= #9'sta :eax+1';

	l := m + 12;
	exit(false);

       end;


   end;	// case k of

  end;	//


 end;		// if (l = 9) and

end;
