
{

*2
*4
*8
*10
*16
*256
*320

}


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
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and (lda_im(i+2) = false) and						// lda 					; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda_im(i+4) and									// lda #$				; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin
      tmp := listing[i];

      listing[i]   := listing[i+4];
      listing[i+4] := tmp;

      tmp := listing[i+2];
      listing[i+2] := listing[i+6];
      listing[i+6] := tmp;

      Result:=false; Break;
     end;


    if lda(i) and 									// lda 					; 0	CX -> CL
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda 					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin
      listing[i+2] := '';
      listing[i+3] := '';

      listing[i+6] := '';
      listing[i+7] := '';

      listing[i+9]  := #9'fmulu_8';
      listing[i+11] := #9'imulCL';

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCX 2				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$02') and							// lda #$02				; 0	* 2
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7

     begin


       if (listing[i+13] = #9'lda :eax') and						// lda :eax		; 13
	  add_sub(i+14) and								// add|sub		; 14
	  sta(i+15) and									// sta			; 15
          (listing[i+16] = #9'lda :eax+1') and						// lda :eax+1		; 16
	  adc_sbc(i+17) and								// adc|sbc		; 17
          sta(i+18) and									// sta			; 18
	  (listing[i+19] <> #9'lda :eax+2') then					//~lda :eax+2		; 19
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

	 Result:=false; Break;
	end;


       if ldy(i+13) and									// ldy			; 13
          (listing[i+14] = #9'lda :eax') and						// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          (listing[i+16] = #9'lda :eax+1') and						// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (listing[i+18] <> #9'lda :eax+2') then					//~lda :eax+2		; 18
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

	 Result:=false; Break;
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 4				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$04') and							// lda #$04				; 0	* 4
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin


       if (listing[i+13] = #9'lda :eax') and						// lda :eax		; 13
	  sta(i+14) and									// sta			; 14
          (listing[i+15] = #9'lda :eax+1') and						// lda :eax+1		; 15
	  sta(i+16) and									// sta			; 16
          (listing[i+17] <> #9'lda :eax+2') then					//~lda :eax+2		; 17
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

	 Result:=false; Break;
	end;


       if ldy(i+13) and									// ldy			; 13
          (listing[i+14] = #9'lda :eax') and						// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          (listing[i+16] = #9'lda :eax+1') and						// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (listing[i+18] <> #9'lda :eax+2') then					//~lda :eax+2		; 18
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

	 Result:=false; Break;
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 8				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0	* 8
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin


       if ldy(i+13) and									// ldy			; 13
          (listing[i+14] = #9'lda :eax') and						// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          (listing[i+16] = #9'lda :eax+1') and						// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (listing[i+18] <> #9'lda :eax+2') then					//~lda :eax+2		; 18
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

	 Result:=false; Break;
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 10				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0	* 10	BYTE
       (listing[i+1] = #9'sta :ecx') and 						// sta :ecx				; 1
       lda_im_0(i+2) and 								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
       lda(i+4) and {(lda_stack(i+4) = false) and}					// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda_im_0(i+6) and 								// lda #$00				; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin


      if (listing[i+13] = #9'lda :eax') and 						// lda :eax		; 13
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

	Result:=false; Break;
       end;


      if lda(i+13) and 									// lda 			; 13
         add_sub(i+14) and								// add|sub		; 14
         ((listing[i+15] = #9'add :eax') or (listing[i+15] = #9'sub :eax')) and		// add|sub :eax		; 15
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

	 Result:=false; Break;
       end;

     end;

  end;


 if (listing[i] = #9'lda #$0A') and 							// lda #$0A				; 0	* 10
    (listing[i+1] = #9'sta :ecx') and 							// sta :ecx				; 1
    lda_im_0(i+2) and 									// lda #$00				; 2
    (listing[i+3] = #9'sta :ecx+1') and 						// sta :ecx+1				; 3
    IFDEF_MUL16(i+4) then 								// .ifdef fmulinit			; 4
       											// fmulu_16				; 5
       				 							// els					; 6
       											// imulCX				; 7
       											// eif					; 8
  begin


     if (listing[i+9] = #9'lda :eax') and 						// lda :eax				; 9
        add_sub(i+10) and								// add|sub				; 10
        tay(i+11) then 									// tay					; 11
      begin

	if (listing[i-1] = #9'sta :eax+1') and
           (adc_im_0(i-2) or sbc_im_0(i-2)) and
	   lda_im_0(i-3) and
	   (listing[i-4] = #9'sta :eax') then
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

	Result:=false; Break;
      end;


     if lda(i+9) and 									// lda 					; 9
        AND_ORA_EOR(i+10) and								// and|ora|eor				; 10
        ((listing[i+11] = #9'add :eax') or (listing[i+11] = #9'sub :eax')) and		// add|sub :eax				; 11
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

	Result:=false; Break;
      end;

  end;

// -----------------------------------------------------------------------------

  if ldy_im_0(i) and 									// ldy #$00				; 0
     lda(i+1) and 									// lda 					; 1
     spl(i+2) and 									// spl					; 2
     dey(i+3) and 									// dey					; 3
     (listing[i+4] = #9'sta :eax') and 							// sta :eax				; 4
     (listing[i+5] = #9'sty :eax+1') and 						// sty :eax+1				; 5
     (listing[i+6] = #9'lda #$0A') and 							// lda #$0A				; 6
     (listing[i+7] = #9'sta :ecx') and 							// sta :ecx				; 7
     lda_im_0(i+8) and 									// lda #$00				; 8
     (listing[i+9] = #9'sta :ecx+1') and 						// sta :ecx+1				; 9
     IFDEF_MUL16(i+10) then 								// .ifdef fmulinit			; 10
      											// fmulu_16				; 11
       											// els					; 12
       											// imulCX				; 13
       											// eif					; 14
   begin


    if lda(i+15) and 									// lda 					; 15
       ((listing[i+16] = #9'add :eax') or (listing[i+16] = #9'sub :eax')) and		// add|sub :eax				; 16
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

      Result:=false; Break;
     end;


    if lda(i+15) and 									// lda 					; 15
       add_sub(i+16) and								// add|sub				; 16
       ((listing[i+17] = #9'add :eax') or (listing[i+17] = #9'sub :eax')) and		// add|sub :eax				; 17
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

      Result:=false; Break;
     end;

   end;


// -----------------------------------------------------------------------------
// ===				imulCX 16				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$10') and							// lda #$10				; 0	* 16
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin


       if ldy(i+13) and									// ldy			; 13
          (listing[i+14] = #9'lda :eax') and						// lda :eax		; 14
	  sta(i+15) and									// sta			; 15
          (listing[i+16] = #9'lda :eax+1') and						// lda :eax+1		; 16
	  sta(i+17) and									// sta			; 17
          (listing[i+18] <> #9'lda :eax+2') then					//~lda :eax+2		; 18
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

	 Result:=false; Break;
	end;


     end;


// -----------------------------------------------------------------------------
// ===				imulCX 256				  === //
// -----------------------------------------------------------------------------

    if lda_im_0(i) and									// lda #$00				; 0	* 256
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$01') and						// lda #$01				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda 					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin


      if (listing[i+13] = #9'lda :eax') and						// lda :eax		; 13
         sta(i+14) and									// sta			; 14
         (listing[i+15] = #9'lda :eax+1') and						// lda :eax+1		; 15
         sta(i+16) and									// sta			; 16
         (listing[i+17] <> #9'lda :eax+2') then						//~lda :eax+2		; 17
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

	Result:=false; Break;
       end;


      if (listing[i+13] = #9'lda :eax') and						// lda :eax		; 13
	 add_sub(i+14) and								// add|sub		; 14
         sta(i+15) and									// sta			; 15
         (listing[i+16] = #9'lda :eax+1') and						// lda :eax+1		; 16
	 adc_sbc(i+17) and								// adc|sbc		; 17
         sta(i+18) and									// sta			; 18
         (listing[i+19] <> #9'lda :eax+2') then						//~lda :eax+2		; 19
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

	Result:=false; Break;
       end;


     end;


    if lda(i) and									// lda 					; 0	* 256
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and									// lda 					; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda_im_0(i+4) and								// lda #$00				; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       (listing[i+6] = #9'lda #$01') and 						// lda #$01				; 6
       (listing[i+7] = #9'sta :eax+1') and 						// sta :eax+1				; 7

       (listing[i+13] = #9'lda :eax') and						// lda :eax		; 13
       sta(i+14) and									// sta			; 14
       (listing[i+15] = #9'lda :eax+1') and						// lda :eax+1		; 15
       sta(i+16) and									// sta			; 16
       (listing[i+17] <> #9'lda :eax+2') then						//~lda :eax+2		; 17
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

      Result:=false; Break;
     end;


// -----------------------------------------------------------------------------
// ===				imulCX 320				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$40') and							// lda #$40				; 0	* 320
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       (listing[i+2] = #9'lda #$01') and						// lda #$01				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda 					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda 					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
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

      Result:=false; Break;
     end;
