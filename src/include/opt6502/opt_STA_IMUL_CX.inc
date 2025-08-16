
{

*2
*4
*8
*10
*16
*256
*320

}

function opt_STA_IMUL_CX(i: integer): Boolean;
var tmp: string;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				imulCX					  === //
// -----------------------------------------------------------------------------

 if IFDEF_MUL16(i+8) then 								// .ifdef fmulinit			; 8
       											// fmulu_16				; 9
      											// els					; 10
       											// imulCX				; 11
     											// eif					; 12
 begin


    if lda(i) and (lda_im(i) = false) and						// lda 					; 0	CX -> CL
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda(i+2) and (lda_im(i+2) = false) and						// lda 					; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda_im(i+4) and									// lda #$				; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       sta_eax_1(i+7) then 								// sta :eax+1				; 7
     begin
      tmp := listing[i];

      listing[i]   := listing[i+4];
      listing[i+4] := tmp;

      tmp := listing[i+2];
      listing[i+2] := listing[i+6];
      listing[i+6] := tmp;

      exit(false);
     end;


    if lda(i) and 									// lda 					; 0	CX -> CL
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda(i+4) and									// lda 					; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       sta_eax_1(i+7) then 								// sta :eax+1				; 7
     begin
      listing[i+2] := '';
      listing[i+3] := '';

      listing[i+6] := '';
      listing[i+7] := '';

      listing[i+9]  := #9'fmulu_8';
      listing[i+11] := #9'imulCL';

      exit(false);
     end;


// -----------------------------------------------------------------------------
// ===				imulCX 2				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$02') and							// lda #$02				; 0	* 2
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       sta_eax_1(i+7) then 								// sta :eax+1				; 7

     begin


       if lda_eax(i+13) and								// lda :eax		; 13
	  add_sub(i+14) and								// add|sub		; 14
	  sta(i+15) and									// sta			; 15
          lda_eax_1(i+16) and								// lda :eax+1		; 16
	  adc_sbc(i+17) and								// adc|sbc		; 17
          sta(i+18) and									// sta			; 18
	  (lda_eax_x(i+19) = false) then						//~lda :eax+2		; 19
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'sta :eax';

	 listing[i+6]  := '';
	 listing[i+7]  := '';
	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


       if ldy(i+13) and									// ldy			; 13
          lda_eax(i+14) and								// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          lda_eax_1(i+16) and								// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (lda_eax_x(i+18) = false) then						//~lda :eax+2		; 18
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'sta :eax';

	 listing[i+6]  := '';
	 listing[i+7]  := '';
	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


       if lda_eax(i+13) and								// lda :eax		; 13
	  sta(i+14) and									// sta			; 14
          lda_eax_1(i+15) and								// lda :eax+1		; 15
	  sta(i+16) and									// sta			; 16
          (lda_eax_x(i+17) = false) then						//~lda :eax+2		; 17
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'sta :eax';

	 listing[i+6]  := '';
	 listing[i+7]  := '';
	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;

     end;



    if sta_eax(i) and									// sta :eax				; 0	* 2
       lda(i+1) and									// lda					; 1
       adc_sbc(i+2) and									// adc|sbc				; 2
       sta_eax_1(i+3) and								// sta :eax+1				; 3
       (listing[i+4] = #9'lda #$02') and						// lda #$02				; 4
       sta_ecx(i+5) and 								// sta :ecx				; 5
       lda_im_0(i+6) and								// lda #$00				; 6
       sta_ecx_1(i+7) then		 						// sta :ecx+1				; 7

     begin


       if lda_eax(i+13) and								// lda :eax		; 13
	  sta(i+14) and									// sta			; 14
          lda_eax_1(i+15) and								// lda :eax+1		; 15
	  sta(i+16) and									// sta			; 16
          (lda_eax_x(i+17) = false) then						//~lda :eax+2		; 17
	begin

	 if (sta_stack(i+14) = false) and
	    (sta_stack(i+16) = false) then
	 begin
	  listing[i]   := listing[i+14];

	  listing[i+3] := listing[i+16];
	  listing[i+4] := #9'asl ' + copy(listing[i+14], 6, 256);
	  listing[i+5] := #9'rol ' + copy(listing[i+16], 6, 256);

	  listing[i+13] := '';
	  listing[i+14] := '';
	  listing[i+15] := '';
	  listing[i+16] := '';
	 end else begin
	  listing[i+4] := #9'asl :eax';
	  listing[i+5] := #9'rol :eax+1';
	 end;

	 listing[i+6]  := '';
	 listing[i+7]  := '';
	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 4				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$04') and							// lda #$04				; 0	* 4
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       sta_eax_1(i+7) then		 						// sta :eax+1				; 7
     begin


       if lda_eax(i+13) and								// lda :eax		; 13
	  sta(i+14) and									// sta			; 14
          lda_eax_1(i+15) and								// lda :eax+1		; 15
	  sta(i+16) and									// sta			; 16
          (lda_eax_x(i+17) = false) then						//~lda :eax+2		; 17
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol :eax+1';
	 listing[i+7] := #9'sta :eax';

	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


       if ldy(i+13) and									// ldy			; 13
          lda_eax(i+14) and								// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          lda_eax_1(i+16) and								// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (lda_eax_x(i+18) = false) then						//~lda :eax+2		; 18
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol :eax+1';
	 listing[i+7] := #9'sta :eax';

	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


     end;



    if sta_eax(i) and									// sta :eax				; 0	* 4
       lda(i+1) and									// lda					; 1
       adc_sbc(i+2) and									// adc|sbc				; 2
       sta_eax_1(i+3) and								// sta :eax+1				; 3
       (listing[i+4] = #9'lda #$04') and						// lda #$04				; 4
       sta_ecx(i+5) and			 						// sta :ecx				; 5
       lda_im_0(i+6) and								// lda #$00				; 6
       sta_ecx_1(i+7) then		 						// sta :ecx+1				; 7

     begin


       if lda_eax(i+13) and								// lda :eax		; 13
	  sta(i+14) and									// sta			; 14
          lda_eax_1(i+15) and								// lda :eax+1		; 15
	  sta(i+16) and									// sta			; 16
          (lda_eax_x(i+17) = false) then						//~lda :eax+2		; 17
	begin

	 if (sta_stack(i+14) = false) and
	    (sta_stack(i+16) = false) then
	 begin
	  listing[i]   := listing[i+14];

	  listing[i+3] := listing[i+16];
	  listing[i+4] := #9'asl ' + copy(listing[i+14], 6, 256);
	  listing[i+5] := #9'rol ' + copy(listing[i+16], 6, 256);
	  listing[i+6] := #9'asl ' + copy(listing[i+14], 6, 256);
	  listing[i+7] := #9'rol ' + copy(listing[i+16], 6, 256);

	  listing[i+13] := '';
	  listing[i+14] := '';
	  listing[i+15] := '';
	  listing[i+16] := '';
	 end else begin
	  listing[i+4] := #9'asl :eax';
	  listing[i+5] := #9'rol :eax+1';
	  listing[i+6] := #9'asl :eax';
	  listing[i+7] := #9'rol :eax+1';
	 end;

	 listing[i+8]  := '';
	 listing[i+9]  := '';
	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 8				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0	* 8
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       sta_eax(i+5) and			 						// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       sta_eax_1(i+7) then		 						// sta :eax+1				; 7
     begin


       if ldy(i+13) and									// ldy			; 13
          lda_eax(i+14) and								// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          lda_eax_1(i+16) and								// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (lda_eax_x(i+18) = false) then						//~lda :eax+2		; 18
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol :eax+1';
	 listing[i+7] := #9'asl @';
	 listing[i+8] := #9'rol :eax+1';
	 listing[i+9] := #9'sta :eax';

	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


       if lda(i+13) and									// lda			; 13
          (add_eax(i+14) or sub_eax(i+14)) and						// add|sub :eax		; 14
	  tay(i+15) and									// tay			; 15
          lda(i+16) and									// lda			; 16
	  (adc_eax_1(i+17) or sbc_eax_1(i+17)) and					// adc|sbc :eax+1	; 17
          sta_bp_1(i+18) then								// sta :bp+1		; 18
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol :eax+1';
	 listing[i+7] := #9'asl @';
	 listing[i+8] := #9'rol :eax+1';
	 listing[i+9] := #9'sta :eax';

	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


     end;



    if sta_eax(i) and									// sta :eax				; 0
       (lda(i+1) or tya(i+1)) and							// lda|tya				; 1
       adc_sbc(i+2) and									// adc|sbc				; 2
       sta_eax_1(i+3) and								// sta :eax+1				; 3
       (listing[i+4] = #9'lda #$08') and						// lda #$08				; 4
       sta_ecx(i+5) and 								// sta :ecx				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       sta_ecx_1(i+7) then		 						// sta :ecx+1				; 7
     begin


       if lda_eax(i+13) and								// lda :eax		; 13
	  sta(i+14) and									// sta			; 14
          lda_eax_1(i+15) and								// lda :eax+1		; 15
	  sta(i+16) and									// sta			; 16
          (lda_eax_x(i+17) = false) then						//~lda :eax+2		; 17
	begin
	 listing[i+3] := #9'asl :eax';
	 listing[i+4] := #9'rol @';
	 listing[i+5] := #9'asl :eax';
	 listing[i+6] := #9'rol @';
	 listing[i+7] := #9'asl :eax';
	 listing[i+8] := #9'rol @';
	 listing[i+9] := #9'sta :eax+1';

	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


       if lda(i+13) and									// lda			; 13
          (add_eax(i+14) or sub_eax(i+14)) and						// add|sub :eax		; 14
	  sta(i+15) and									// sta			; 15
	  lda(i+16) and									// lda			; 16
          (adc_eax_1(i+17) or sbc_eax_1(i+17)) and					// adc|sbc :eax+1	; 17
	  sta(i+18) and									// sta			; 18
											//			; 19
          (adc_sbc(i+20) = false) then							//~adc|sbc :eax+2	; 20
	begin
	 listing[i+3] := #9'asl :eax';
	 listing[i+4] := #9'rol @';
	 listing[i+5] := #9'asl :eax';
	 listing[i+6] := #9'rol @';
	 listing[i+7] := #9'asl :eax';
	 listing[i+8] := #9'rol @';
	 listing[i+9] := #9'sta :eax+1';

	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 10				  === //
// -----------------------------------------------------------------------------


    if lda_a(i) and									// lda					; 0	* 10 = WORD
       sta_eax(i+1) and 								// sta :eax				; 1
       lda_a(i+2) and									// lda					; 2
       sta_eax_1(i+3) and 								// sta :eax+1				; 3
       (listing[i+4] = #9'lda #$0A') and 						// lda #$0A				; 4
       sta_ecx(i+5) and			 						// sta :ecx				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       sta_ecx_1(i+7) and		 						// sta :ecx+1				; 7

       lda_eax(i+13) and
       sta(i+14) and
       lda_eax_1(i+15) and
       sta(i+16) and
       (lda_eax_x(i+17) = false) then
     begin
	listing[i+1] := listing[i+14];

	listing[i+3] := listing[i+16];
	listing[i+4] := #9'tay';
	listing[i+5] := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'asl @';
	listing[i+7] := #9'rol ' + copy(listing[i+3], 6, 256);
	listing[i+8] := #9'asl @';
	listing[i+9] := #9'rol ' + copy(listing[i+3], 6, 256);

	listing[i+10] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+11] := #9'sta ' + copy(listing[i+1], 6, 256);

	listing[i+12] := #9'tya';
	listing[i+13] := #9'adc ' + copy(listing[i+3], 6, 256);
	listing[i+14] := #9'asl ' + copy(listing[i+1], 6, 256);
	listing[i+15] := #9'rol @';
	listing[i+16] := #9'sta ' + copy(listing[i+3], 6, 256);

	exit(false);
     end;


    if lda_a(i) and									// lda					; 0	* 10 = WORD
       sta_ecx(i+1) and			 						// sta :ecx				; 1
       lda_a(i+2) and									// lda					; 2
       sta_ecx_1(i+3) and		 						// sta :ecx+1				; 3
       (listing[i+4] = #9'lda #$0A') and 						// lda #$0A				; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       sta_eax_1(i+7) and 								// sta :eax+1				; 7

       lda_eax(i+13) and
       sta(i+14) and
       lda_eax_1(i+15) and
       sta(i+16) and
       (lda_eax_x(i+17) = false) then
     begin
	listing[i+1] := listing[i+14];

	listing[i+3] := listing[i+16];
	listing[i+4] := #9'tay';
	listing[i+5] := #9'lda ' + copy(listing[i+1], 6, 256);
	listing[i+6] := #9'asl @';
	listing[i+7] := #9'rol ' + copy(listing[i+3], 6, 256);
	listing[i+8] := #9'asl @';
	listing[i+9] := #9'rol ' + copy(listing[i+3], 6, 256);

	listing[i+10] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+11] := #9'sta ' + copy(listing[i+1], 6, 256);

	listing[i+12] := #9'tya';
	listing[i+13] := #9'adc ' + copy(listing[i+3], 6, 256);
	listing[i+14] := #9'asl ' + copy(listing[i+1], 6, 256);
	listing[i+15] := #9'rol @';
	listing[i+16] := #9'sta ' + copy(listing[i+3], 6, 256);

	exit(false);
     end;


    if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0	* 10	BYTE
       sta_ecx(i+1) and			 						// sta :ecx				; 1
       lda_im_0(i+2) and 								// lda #$00				; 2
       sta_ecx_1(i+3) and		 						// sta :ecx+1				; 3
       lda(i+4) and {(lda_stack(i+4) = false) and}					// lda					; 4	~lda adr.
       sta_eax(i+5) and 								// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       sta_eax_1(i+7) then 								// sta :eax+1				; 7
     begin


      if lda_eax(i+13) and 								// lda :eax		; 13
         add_sub(i+14) and								// add|sub		; 14
         tay(i+15) then  								// tay			; 15
       begin
	listing[i]   := listing[i+4];
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
	listing[i+4] := #9'asl @';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';
	listing[i+13] := '';

	exit(false);
       end;


      if lda(i+13) and 									// lda 			; 13
         add_sub(i+14) and								// add|sub		; 14
         (add_eax(i+15) or sub_eax(i+15)) and						// add|sub :eax		; 15
         tay(i+16) then 								// tay			; 16
       begin
	 listing[i]   := listing[i+4];
	 listing[i+1] := #9'asl @';
	 listing[i+2] := #9'asl @';
	 listing[i+3] := #9'add ' + copy(listing[i], 6, 256);
	 listing[i+4] := #9'asl @';
	 listing[i+5] := #9'sta :eax';

	 listing[i+6] := '';
	 listing[i+7] := '';
	 listing[i+8] := '';
	 listing[i+9] := '';

	 listing[i+10] := '';
	 listing[i+11] := '';
	 listing[i+12] := '';

	 exit(false);
       end;

     end;

  end;


// -----------------------------------------------------------------------------


 if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0	* 10
    sta_ecx(i+1) and		 							// sta :ecx				; 1
    lda_im_0(i+2) and 									// lda #$00				; 2
    sta_ecx_1(i+3) and			 						// sta :ecx+1				; 3
    IFDEF_MUL16(i+4) then 								// .ifdef fmulinit			; 4
       											// fmulu_16				; 5
       				 							// els					; 6
       											// imulCX				; 7
       											// eif					; 8
  begin


     if lda_eax(i+9) and 								// lda :eax				; 9
        add_sub(i+10) and								// add|sub				; 10
        tay(i+11) then 									// tay					; 11
      begin

	if sta_eax_1(i-1) and
           (adc_im_0(i-2) or sbc_im_0(i-2)) and
	   lda_im_0(i-3) and
	   sta_eax(i-4) then
         begin
	  listing[i-1] := '';
	  listing[i-2] := '';
	  listing[i-3] := '';

	  listing[i] := '';
         end else
          listing[i]   := #9'lda :eax';

	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add :eax';
	listing[i+4] := #9'asl @';

	listing[i+5] := '';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';
	listing[i+9] := '';

	exit(false);
      end;


     if lda(i+9) and 									// lda 					; 9
        AND_ORA_EOR(i+10) and								// and|ora|eor				; 10
        (add_eax(i+11) or sub_eax(i+11)) and						// add|sub :eax				; 11
        (tay(i+12) or sta_stack(i+12)) then						// tay|sta :STACK			; 12
      begin
	listing[i]   := #9'lda :eax';
	listing[i+1] := #9'asl @';
	listing[i+2] := #9'asl @';
	listing[i+3] := #9'add :eax';
	listing[i+4] := #9'asl @';
	listing[i+5] := #9'sta :eax';
	listing[i+6] := '';
	listing[i+7] := '';
	listing[i+8] := '';

	exit(false);
      end;

  end;


// -----------------------------------------------------------------------------


  if ldy_im_0(i) and 									// ldy #$00				; 0
     lda(i+1) and 									// lda 					; 1	~lda adr.
     spl(i+2) and 									// spl					; 2
     dey(i+3) and 									// dey					; 3
     sta_eax(i+4) and		 							// sta :eax				; 4
     (listing[i+5] = #9'sty :eax+1') and 						// sty :eax+1				; 5
     (listing[i+6] = #9'lda #$0A') and 							// lda #$0A				; 6
     sta_ecx(i+7) and		 							// sta :ecx				; 7
     lda_im_0(i+8) and 									// lda #$00				; 8
     sta_ecx_1(i+9) and			 						// sta :ecx+1				; 9
     IFDEF_MUL16(i+10) then 								// .ifdef fmulinit			; 10
      											// fmulu_16				; 11
       											// els					; 12
       											// imulCX				; 13
       											// eif					; 14
   begin


    if lda(i+15) and 									// lda 					; 15	~lda adr.
       (add_eax(i+16) or sub_eax(i+16)) and						// add|sub :eax				; 16
       tay(i+17) then									// tay					; 17
     begin
      listing[i] := '';

      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'sta :eax';

      listing[i+7]  := '';
      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';

      if listing[i+16] = #9'add :eax' then
	listing[i+15] := #9'add ' + copy(listing[i+15], 6, 256)
      else
	listing[i+15] := #9'sub ' + copy(listing[i+15], 6, 256);

      listing[i+6] := '';
      listing[i+16] := '';

      exit(false);
     end;


    if lda(i+15) and 									// lda 					; 15
       add_sub(i+16) and								// add|sub				; 16
       (add_eax(i+17) or sub_eax(i+17)) and						// add|sub :eax				; 17
       (sta(i+18) or tay(i+18)) then							// sta|tay				; 18
     begin
      listing[i] := '';

      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'add ' + copy(listing[i+1], 6, 256);
      listing[i+5] := #9'asl @';
      listing[i+6] := #9'sta :eax';

      listing[i+7]  := '';
      listing[i+8]  := '';
      listing[i+9]  := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';
      listing[i+13] := '';
      listing[i+14] := '';

      if listing[i+17] = #9'add :eax' then
	listing[i+15] := #9'add ' + copy(listing[i+15], 6, 256)
      else
	listing[i+15] := #9'sub ' + copy(listing[i+15], 6, 256);

      listing[i+6] := '';
      listing[i+17] := '';

      exit(false);
     end;

   end;


// -----------------------------------------------------------------------------
// ===				imulCX 16				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$10') and							// lda #$10				; 0	* 16
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       sta_eax_1(i+7) then 								// sta :eax+1				; 7
     begin


       if ldy(i+13) and									// ldy			; 13
          lda_eax(i+14) and								// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          lda_eax_1(i+16) and								// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (lda_eax_x(i+18) = false) then						//~lda :eax+2		; 18
	begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol :eax+1';
	 listing[i+7] := #9'asl @';
	 listing[i+8] := #9'rol :eax+1';
	 listing[i+9] := #9'asl @';
	 listing[i+10] := #9'rol :eax+1';
	 listing[i+11] := #9'sta :eax';

	 listing[i+12] := '';

	 exit(false);
	end;


      if lda_eax(i+13) and								// lda :eax		; 13
	 add_sub(i+14) and								// add|sub		; 14
         sta(i+15) and									// sta			; 15
         lda_eax_1(i+16) and								// lda :eax+1		; 16
	 adc_sbc(i+17) and								// adc|sbc		; 17
         sta(i+18) and									// sta			; 18
         (lda_eax_x(i+19) = false) then							//~lda :eax+2		; 19
       begin
	 listing[i]   := listing[i+6];
	 listing[i+1] := listing[i+7];
	 listing[i+2] := listing[i+4];

	 listing[i+3] := #9'asl @';
	 listing[i+4] := #9'rol :eax+1';
	 listing[i+5] := #9'asl @';
	 listing[i+6] := #9'rol :eax+1';
	 listing[i+7] := #9'asl @';
	 listing[i+8] := #9'rol :eax+1';
	 listing[i+9] := #9'asl @';
	 listing[i+10] := #9'rol :eax+1';
	 listing[i+11] := #9'sta :eax';

	 listing[i+12] := '';

	exit(false);
       end;

     end;


// -----------------------------------------------------------------------------
// ===				imulCX 256				  === //
// -----------------------------------------------------------------------------

    if lda_im_0(i) and									// lda #$00				; 0	* 256
       sta_ecx(i+1) and									// sta :ecx				; 1
       (listing[i+2] = #9'lda #$01') and						// lda #$01				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda_a(i+4) and									// lda					; 4
       sta_eax(i+5) and			 						// sta :eax				; 5
       lda_a(i+6) and 									// lda 					; 6
       sta_eax_1(i+7) then		 						// sta :eax+1				; 7
    begin


      if lda_eax(i+13) and								// lda :eax		; 13
         sta(i+14) and									// sta			; 14
         lda_eax_1(i+15) and								// lda :eax+1		; 15
         sta(i+16) and									// sta			; 16
         (lda_eax_x(i+17) = false) then							//~lda :eax+2		; 17
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := listing[i+4];
	listing[i+4] := #9'lda #$00';

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


      if lda_eax_1(i+13) and								// lda :eax+1		; 13
         sta(i+14) and									// sta			; 14
         lda_eax(i+15) and								// lda :eax		; 15
         sta(i+16) and									// sta			; 16
         (lda_eax_x(i+17) = false) then							//~lda :eax+2		; 17
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := listing[i+4];
	listing[i+4] := #9'lda #$00';

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


      if lda_eax(i+13) and								// lda :eax		; 13
	 add_sub(i+14) and								// add|sub		; 14
         sta(i+15) and									// sta			; 15
         lda_eax_1(i+16) and								// lda :eax+1		; 16
	 adc_sbc(i+17) and								// adc|sbc		; 17
         sta(i+18) and									// sta			; 18
         (lda_eax_x(i+19) = false) then							//~lda :eax+2		; 19
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := listing[i+4];
	listing[i+4] := #9'lda #$00';

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;


      if lda(i+13) and									// lda			; 13
	 (add_eax(i+14) or sub_eax(i+14)) and						// add|sub :eax		; 14
         tay(i+15) and									// tay			; 15
	 lda(i+16) and									// lda			; 16
	 (adc_eax_1(i+17) or sbc_eax_1(i+17)) and					// adc|sbc :eax+1	; 17
         sta_bp_1(i+18) then								// sta :bp+1		; 18
       begin
	listing[i]   := '';
	listing[i+1] := '';
	listing[i+2] := '';
	listing[i+3] := '';

	listing[i+6] := listing[i+4];
	listing[i+4] := #9'lda #$00';

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10] := '';
	listing[i+11] := '';
	listing[i+12] := '';

	exit(false);
       end;

    end;		// *256


// -----------------------------------------------------------------------------


    if lda_a(i) and									// lda 					; 0	* 256
       sta_ecx(i+1) and									// sta :ecx				; 1
       lda_a(i+2) and									// lda 					; 2
       sta_ecx(i+3) and									// sta :ecx+1				; 3
       lda_im_0(i+4) and								// lda #$00				; 4
       sta_eax(i+5) and 								// sta :eax				; 5
       (listing[i+6] = #9'lda #$01') and 						// lda #$01				; 6
       sta_eax_1(i+7) and 								// sta :eax+1				; 7

       lda_eax(i+13) and								// lda :eax		; 13
       sta(i+14) and									// sta			; 14
       lda_eax_1(i+15) and								// lda :eax+1		; 15
       sta(i+16) and									// sta			; 16
       (lda_eax_x(i+17) = false) then							//~lda :eax+2		; 17
     begin
      listing[i+6] := listing[i];
      listing[i+4] := #9'lda #$00';

      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';

      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


    if lda(i) and									// lda 					; 0	* 256	~lda adr.
       sta_eax(i+1) and									// sta :eax				; 1
       lda_a(i+2) and									// lda 					; 2
       sta_eax_1(i+3) and								// sta :eax+1				; 3
       lda_im_0(i+4) and								// lda #$00				; 4
       sta_ecx(i+5) and			 						// sta :ecx				; 5
       (listing[i+6] = #9'lda #$01') and 						// lda #$01				; 6
       sta_ecx_1(i+7) and		 						// sta :ecx+1				; 7

       lda(i+13) and									// lda			; 13
       (add_eax(i+14) or sub_eax(i+14)) and						// add|sub :eax		; 14
       sta(i+15) and									// sta			; 15
       lda(i+16) and									// lda			; 16
       (adc_eax_1(i+17) or sbc_eax_1(i+17)) and						// adc|sbc :eax+1	; 17
       sta(i+18) and									// sta			; 18

       (adc_sbc(i+20) = false) then							//~adc|sbc		; 20
     begin
      listing[i+14] := '';	//#9'add #$00';

      listing[i+17] := #9'add ' + copy(listing[i], 6, 256);

      listing[i]   := '';
      listing[i+1] := '';
      listing[i+2] := '';
      listing[i+3] := '';
      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


// -----------------------------------------------------------------------------
// ===				imulCX 320				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$40') and							// lda #$40				; 0	* 320
       sta_ecx(i+1) and									// sta :ecx				; 1
       (listing[i+2] = #9'lda #$01') and						// lda #$01				; 2
       sta_ecx_1(i+3) and								// sta :ecx+1				; 3
       lda(i+4) and									// lda 					; 4
       sta_eax(i+5) and			 						// sta :eax				; 5
       lda(i+6) and 									// lda 					; 6
       sta_eax_1(i+7) then		 						// sta :eax+1				; 7
     begin
      listing[i]   := listing[i+4];
      listing[i+1] := listing[i+5];
      listing[i+2] := listing[i+6];
      listing[i+3] := listing[i+7];
      listing[i+4] := #9'jsr @mul320';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';
      listing[i+10] := '';
      listing[i+11] := '';
      listing[i+12] := '';

      exit(false);
     end;


// -----------------------------------------------------------------------------
// ===			imulCX (16x16) -> imulCX_AL (16x8)		  === //
// -----------------------------------------------------------------------------

  if (listing[i+11] = #9'imulCX') and							// imulCX				; 11

     (lda_im(i) = false) and								//~lda #				; 0
     sta_eax(i+1) and									// sta :eax				; 1
     lda_im_0(i+2) and									// lda #$00				; 2
     sta_eax_1(i+3) and									// sta :eax+1				; 3
     lda_a(i+4) and									// lda 					; 4
     sta_ecx(i+5) and						 			// sta :ecx				; 5
     lda_a(i+6) and									// lda					; 6
     sta_ecx_1(i+7) and							 		// sta :ecx+1				; 7
     IFDEF_MUL16(i+8) then								// .ifdef fmulinit			; 8
      											// fmulu_16				; 9
       											// els					; 10
      											// imulCX				; 11
       											// eif					; 12
   begin
    listing[i+11] := #9'imulCX_AL';

    exit(false);
   end;


  if (listing[i+11] = #9'imulCX') and							// imulCX				; 11

     lda_a(i) and									// lda					; 0
     sta_ecx(i+1) and									// sta :ecx				; 1
     lda_a(i+2) and									// lda					; 2
     sta_ecx_1(i+3) and									// sta :ecx+1				; 3
     lda_a(i+4) and (lda_im(i+4) = false) and						// lda 					; 4
     sta_eax(i+5) and						 			// sta :eax				; 5
     lda_im_0(i+6) and									// lda #$00				; 6
     sta_eax_1(i+7) and							 		// sta :eax+1				; 7
     IFDEF_MUL16(i+8) then								// .ifdef fmulinit			; 8
      											// fmulu_16				; 9
       											// els					; 10
      											// imulCX				; 11
       											// eif					; 12
   begin
    listing[i+11]:= #9'imulCX_AL';

    exit(false);
   end;


  if (listing[i+11] = #9'imulCX') and							// imulCX				; 11

     (lda_im(i) = false) and								//~lda #				; 0
     sta_ecx(i+1) and									// sta :ecx				; 1
     lda_im_0(i+2) and									// lda #$00				; 2
     sta_ecx_1(i+3) and									// sta :ecx+1				; 3
     lda_a(i+4) and									// lda 					; 4
     sta_eax(i+5) and						 			// sta :eax				; 5
     lda_a(i+6) and									// lda					; 6
     sta_eax_1(i+7) and							 		// sta :eax+1				; 7
     IFDEF_MUL16(i+8) then								// .ifdef fmulinit			; 8
      											// fmulu_16				; 9
       											// els					; 10
      											// imulCX				; 11
       											// eif					; 12
   begin
    listing[i+1] := #9'sta :eax';

    listing[i+3] := #9'sta :eax+1';

    listing[i+5] := #9'sta :ecx';

    listing[i+7] := #9'sta :ecx+1';

    listing[i+11]:= #9'imulCX_AL';

    exit(false);
   end;


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

  if sta_eax(i) and									// sta :eax				; 0
     lda_a(i+1) and									// lda					; 1
     sta_ecx(i+2) and									// sta :ecx				; 2
     lda_a(i+3) and									// lda 					; 3
     sta_ecx_1(i+4) and							 		// sta :ecx+1				; 4
     lda_a(i+5) and									// lda					; 5
     sta_eax_1(i+6) and							 		// sta :eax+1				; 6
     IFDEF_MUL16(i+7) then								// .ifdef fmulinit			; 7
      											// fmulu_16				; 8
       											// els					; 9
      											// imulCX				; 10
       											// eif					; 11
   begin
    listing_tmp[0] := listing[i];
    listing_tmp[1] := listing[i+5];
    listing_tmp[2] := listing[i+6];
    listing_tmp[3] := listing[i+1];
    listing_tmp[4] := listing[i+2];
    listing_tmp[5] := listing[i+3];
    listing_tmp[6] := listing[i+4];

    listing[i]   := listing_tmp[0];
    listing[i+1] := listing_tmp[1];
    listing[i+2] := listing_tmp[2];
    listing[i+3] := listing_tmp[3];
    listing[i+4] := listing_tmp[4];
    listing[i+5] := listing_tmp[5];
    listing[i+6] := listing_tmp[6];

    exit(false);
   end;

end;		// function