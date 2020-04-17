
{

*2
*4
*8
*10
*16
*256

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



    if (listing[i] = #9'lda #$08') and							// lda #$04				; 0	* 8
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


    if (listing[i] = #9'lda #$10') and							// lda #$04				; 0	* 16
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


{
    if (listing[i] = #9'lda #$04') and							// lda #$04				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda_im_0(i+2) and								// lda #$00				; 2
       (listing[i+3] = #9'sta :ecx+1') and						// sta :ecx+1				; 3
       lda(i+4) and									// lda					; 4
       (listing[i+5] = #9'sta :eax') and 						// sta :eax				; 5
       lda(i+6) and 									// lda					; 6
       (listing[i+7] = #9'sta :eax+1') then 						// sta :eax+1				; 7
     begin
      listing[i+5] := listing[i+4];

      listing[i] := #9'lda #$00';
      listing[i+1] := #9'sta :eax+2';
      listing[i+2] := #9'sta :eax+3';
      listing[i+3] := listing[i+6];
      listing[i+4] := listing[i+7];

      listing[i+6] := #9'asl @';
      listing[i+7] := #9'rol :eax+1';
      listing[i+8] := #9'rol :eax+2';
      listing[i+9] := #9'asl @';
      listing[i+10] := #9'rol :eax+1';
      listing[i+11] := #9'rol :eax+2';
      listing[i+12] := #9'sta :eax';

      Result:=false; Break;
     end;
}


  end;
