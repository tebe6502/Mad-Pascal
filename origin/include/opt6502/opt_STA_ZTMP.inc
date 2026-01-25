
function opt_STA_ZTMP(i: integer): Boolean;
var p: integer;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===				      ZTMP.
// -----------------------------------------------------------------------------

  if lda_a(i) and									// lda :ztmp9		; 0
     bpl_a(i+1) and									// bpl @+		; 1
     lda_a(i+2) and									// lda 			; 2
     sub(i+3) and									// sub 			; 3
     sta_eax_2(i+4) and									// sta :eax+2		; 4
     lda_a(i+5) and									// lda 			; 5
     sbc(i+6) and									// sbc			; 6
     sta_eax_3(i+7) and 								// sta :eax+3		; 7
     lab_a(i+8) then									//@			; 8
   begin


    if lda_eax(i+9) and 							// lda :eax		; 9
       sta_a(i+10) and 								// sta 			; 10
       lda_eax_1(i+11) and 							// lda :eax+1		; 11
       sta_a(i+12) and 								// sta 			; 12
       (EAX(i+13) = false) then							//~lda			; 13
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	exit(false);
     end;


    if mwy_bp2(i+9) and								// mwy BASE :bp2	; 9
       ldy_im_0(i+10) and 							// ldy #$00		; 10
       lda_eax(i+11) and 							// lda :eax		; 11
       add_sub(i+12) and bp2_y(i+12) and  			 		// add (:bp2),y		; 12
       iny(i+13) and								// iny			; 13
       sta_a(i+14) and 								// sta			; 14
       lda_eax_1(i+15) and 							// lda :eax+1		; 15
       adc_sbc(i+16) and bp2_y(i+16) and			 		// adc (:bp2),y		; 16
       sta_a(i+17) and 								// sta			; 17
       (lda_a(i+18) = false) then						//~lda			; 18
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	exit(false);
     end;


    if lda_a(i+9) and 								// lda			; 9
       (add_eax(i+10) or sub_eax(i+10)) and 					// add|sub :eax		; 10
       sta_a(i+11) and 								// sta			; 11
       lda_a(i+12) and 								// lda			; 12
       (adc_eax_1(i+13) or sbc_eax_1(i+13)) and					// adc|sbc :eax+1	; 13
       sta_a(i+14) and 								// sta			; 14
       (EAX(i+15) = false) and							//			; 15
       (adc_sbc(i+16) = false) then 						//~adc|sbc		; 16
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	exit(false);
     end;

   end;


// -----------------------------------------------------------------------------


    if (lda_ztmp(i+21) = false) and		 					//~lda :ztmp..				; 21

       IFDEF_MUL16(i+16) and			 					// .ifdef fmulinit			; 16
       											// fmulu_16				; 17
      											// els					; 18
       											// imulCX				; 19
											// eif					; 20

       //lda_a(i) and									// lda					; 0
       //add_sub(i+1) and								// add|sub				; 1
       sta_eax(i+2) and									// sta :eax				; 2
       (listing[i+3] = #9'sta :ztmp10') and						// sta :ztmp10				; 3
       lda_a(i+4) and									// lda					; 4
       adc_sbc(i+5) and									// adc|sbc				; 5
       sta_eax_1(i+6) and								// sta :eax+1				; 6
       (listing[i+7] = #9'sta :ztmp11') and						// sta :ztmp11				; 7
       lda_a(i+8) and									// lda					; 8
       add_sub(i+9) and									// add|sub				; 9
       sta_ecx(i+10) and								// sta :ecx				; 10
       (listing[i+11] = #9'sta :ztmp8') and						// sta :ztmp8				; 11
       lda_a(i+12) and									// lda					; 12
       adc_sbc(i+13) and								// adc|sbc				; 13
       sta_ecx_1(i+14) and								// sta :ecx+1				; 14
       (listing[i+15] = #9'sta :ztmp9') then						// sta :ztmp9				; 15
     begin
	listing[i+3]:= '';
	listing[i+7]:= '';
	listing[i+11]:= '';
	listing[i+15]:= '';

	exit(false);
     end;


    if (lda_ztmp(i+19) = false) and 							//~lda :ztmp..				; 19

       IFDEF_MUL16(i+14) and			 					// .ifdef fmulinit			; 14
       											// fmulu_16				; 15
      											// els					; 16
       											// imulCX				; 17
											// eif					; 18

       //lda_a(i) and									// lda					; 0
       //add_sub(i+1) and								// add|sub				; 1
       sta_ecx(i+2) and									// sta :ecx				; 2
       (listing[i+3] = #9'sta :ztmp8') and						// sta :ztmp8				; 3
       lda_a(i+4) and									// lda					; 4
       adc_sbc(i+5) and									// adc|sbc				; 5
       sta_ecx_1(i+6) and								// sta :ecx+1				; 6
       (listing[i+7] = #9'sta :ztmp9') and						// sta :ztmp9				; 7
       lda_a(i+8) and									// lda					; 8
       sta_eax(i+9) and									// sta :eax				; 9
       (listing[i+10] = #9'sta :ztmp10') and						// sta :ztmp10				; 10
       lda_a(i+11) and									// lda					; 11
       sta_eax_1(i+12) and								// sta :eax+1				; 12
       (listing[i+13] = #9'sta :ztmp11') then						// sta :ztmp11				; 13
     begin
	listing[i+3]:= '';
	listing[i+7]:= '';
	listing[i+10]:= '';
	listing[i+13]:= '';

	exit(false);
     end;


    if (lda_ztmp(i+19) = false) and		 					//~lda :ztmp..				; 19

       IFDEF_MUL16(i+14) and			 					// .ifdef fmulinit			; 14
       											// fmulu_16				; 15
      											// els					; 16
       											// imulCX				; 17
											// eif					; 18

       //lda_a(i) and									// lda					; 0
       //add_sub(i+1) and								// add|sub				; 1
       sta_eax(i+2) and									// sta :eax				; 2
       (listing[i+3] = #9'sta :ztmp10') and						// sta :ztmp10				; 3
       lda_a(i+4) and									// lda					; 4
       adc_sbc(i+5) and									// adc|sbc				; 5
       sta_eax_1(i+6) and								// sta :eax+1				; 6
       (listing[i+7] = #9'sta :ztmp11') and						// sta :ztmp11				; 7
       lda_a(i+8) and									// lda					; 8
       sta_ecx(i+9) and									// sta :ecx				; 9
       (listing[i+10] = #9'sta :ztmp8') and						// sta :ztmp8				; 10
       lda_a(i+11) and									// lda					; 11
       sta_ecx_1(i+12) and								// sta :ecx+1				; 12
       (listing[i+13] = #9'sta :ztmp9') then						// sta :ztmp9				; 13
     begin
	listing[i+3]:= '';
	listing[i+7]:= '';
	listing[i+10]:= '';
	listing[i+13]:= '';

	exit(false);
     end;


    if (lda_ztmp(i+17) = false) and		 					//~lda :ztmp..				; 17

       IFDEF_MUL16(i+12) and								// .ifdef fmulinit			; 12
      											// fmulu_16				; 13
       											// els					; 14
       											// imulCX				; 15
       											// eif					; 16

       //(lda_a(i) or tya(i)) and							// lda|tya				; 0
       (sta_eax(i+1) or sta_ecx(i+1)) and						// sta :eax|:ecx			; 1
       sta_ztmp(i+2) and								// sta :ztmp..				; 2
       lda_a(i+3) and									// lda					; 3
       (sta_eax_1(i+4) or sta_ecx_1(i+4)) and						// sta :eax+1|:ecx+1			; 4
       sta_ztmp(i+5) and			 					// sta :ztmp..				; 5
       lda_a(i+6) and 									// lda					; 6
       (sta_eax(i+7) or sta_ecx(i+7)) and		 				// sta :ecx|:eax			; 7
       sta_ztmp(i+8) and								// sta :ztmp..				; 8
       lda_a(i+9) and 									// lda					; 9
       (sta_eax_1(i+10) or sta_ecx_1(i+10)) and						// sta :ecx+1|:eax+1			; 10
       sta_ztmp(i+11) then			 					// sta :ztmp..				; 11
     begin
      listing[i+2]  := '';
      listing[i+5]  := '';
      listing[i+8]  := '';
      listing[i+11] := '';

      exit(false);
     end;


    if (lda_ztmp(i+16) = false) and 							//~lda :ztmp..				; 16

       IFDEF_MUL16(i+11) and								// .ifdef fmulinit			; 11
       											// fmulu_16				; 12
       											// els					; 13
       											// imulCX				; 14
       											// eif					; 15

       dey(i) and									// dey					; 0
       (sty_eax_1(i+1) or sty_ecx_1(i+1)) and						// sty :eax+1|:ecx+1			; 1
       sty_ztmp(i+2) and								// sty :ztmp..				; 2
       (sta_eax(i+3) or sta_ecx(i+3)) and						// sta :eax|:ecx			; 3
       sta_ztmp(i+4) and			 					// sta :ztmp..				; 4
       lda_a(i+5) and 									// lda					; 5
       (sta_eax(i+6) or sta_ecx(i+6)) and		 				// sta :ecx|:eax			; 6
       sta_ztmp(i+7) and								// sta :ztmp..				; 7
       lda_a(i+8) and 									// lda					; 8
       (sta_eax_1(i+9) or sta_ecx_1(i+9)) and						// sta :ecx+1|:eax+1			; 9
       sta_ztmp(i+10) then			 					// sta :ztmp..				; 10
     begin
      listing[i+2]  := '';
      listing[i+4]  := '';
      listing[i+7]  := '';
      listing[i+10] := '';

      exit(false);
     end;


    if (lda_ztmp(i+11) = false) and		 					//~lda :ztmp..				; 11

       IFDEF_MUL8(i+6) and								// .ifdef fmulinit			; 6
       											// fmulu_8				; 7
       											// els					; 8
       											// imulCL				; 9
       											// eif					; 10

       //(lda_a(i) or tya(i)) and							// lda|tya				; 0
       sta_ecx(i+1) and									// sta :ecx				; 1
       (listing[i+2] = #9'sta :ztmp8') and						// sta :ztmp8				; 2
       lda_a(i+3) and									// lda					; 3
       sta_eax(i+4) and									// sta :eax				; 4
       (listing[i+5] = #9'sta :ztmp10') then						// sta :ztmp10				; 5
     begin
      listing[i+2]  := '';
      listing[i+5]  := '';

      exit(false);
     end;


// -----------------------------------------------------------------------------


    if lda_eax_1(i+9) and 								// lda :eax+1				; 9

       lda_a(i) and									// lda :ztmp11				; 0
       bpl_a(i+1) and									// bpl @+				; 1
       lda_eax_2(i+2) and								// lda :eax+2 				; 2
       sub(i+3) and									// sub 					; 3
       sta_eax_2(i+4) and								// sta :eax+2				; 4
       lda_eax_3(i+5) and								// lda :eax+3 				; 5
       sbc(i+6) and									// sbc 					; 6
       sta_eax_3(i+7) and								// sta :eax+3				; 7
       lab_a(i+8) and									//@					; 8
//       lda_eax_1(i+9) and 								// lda :eax+1				; 9
       (sta_a(i+10) or lda_eax(i+11)) then						// sta|					; 10
					 						//    |lda :eax				; 11
     if (argMatch(i+4, i+11) = false) and
	(argMatch(i+7, i+11) = false) then
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';
	listing[i+6]:= '';
	listing[i+7]:= '';
	listing[i+8]:= '';

	exit(false);
     end;


    if (l = i + 8) and
       lda_a(i) and									// lda :ztmp				; 0
       bpl_a(i+1) and									// bpl @+				; 1
       lda_eax_1(i+2) and								// lda :eax+1 				; 2
       sub_ztmp(i+3) and								// sub :ztmp..				; 3
       sta_eax_1(i+4) and								// sta :eax+1				; 4
       lab_a(i+5) and									//@					; 5
       lda_eax(i+6) and 								// lda :eax				; 6
       sta_a(i+7) then									// sta					; 7
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	exit(false);
     end;


    if (l = i + 10) and
       lda_a(i) and									// lda :ztmp				; 0
       bpl_a(i+1) and									// bpl @+				; 1
       lda_eax_1(i+2) and								// lda :eax+1 				; 2
       sub_ztmp(i+3) and								// sub :ztmp..				; 3
       sta_eax_1(i+4) and								// sta :eax+1				; 4
       lab_a(i+5) and									//@					; 5
       lda_stack(i+6) and		 						// lda :STACKORIGIN			; 6
       (add_eax(i+7) or sub_eax(i+7)) and						// add|sub :eax 			; 7
       ldy(i+8) and									// ldy					; 8
       sta_a(i+9) then									// sta					; 9
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	exit(false);
     end;


    if (l = i + 10) and
       lda_a(i) and									// lda :ztmp				; 0
       bpl_a(i+1) and									// bpl @+				; 1
       lda_eax_1(i+2) and								// lda :eax+1 				; 2
       sub_ztmp(i+3) and								// sub :ztmp..				; 3
       sta_eax_1(i+4) and								// sta :eax+1				; 4
       lab_a(i+5) and									//@					; 5
       lda_eax(i+6) and			 						// lda :eax				; 6
       sta_a(i+7) and									// sta		 			; 7
       lda_eax_1(i+8) and								// lda :eax+1				; 8
       sta_a(i+9) then									// sta					; 9
     begin
	listing_tmp[0] := listing[i+8];
	listing_tmp[1] := listing[i+9];
	listing_tmp[2] := listing[i+6];
	listing_tmp[3] := listing[i+7];

	listing[i+6] := listing_tmp[0];
	listing[i+7] := listing_tmp[1];
	listing[i+8]:= listing_tmp[2];
	listing[i+9]:= listing_tmp[3];

	exit(false);
     end;


    if sta_eax_1(i+11) and 								// sta :eax+1				; 11

       sta_stack(i) and									// sta :STACKORIGIN+STACKWIDTH+10	; 0
       lda_a(i+1) and									// lda 					; 1
       sta_ecx(i+2) and									// sta :ecx				; 2
       sta_a(i+3) and									// sta :ztmp8				; 3
       lda_a(i+4) and									// lda					; 4
       sta_ecx_1(i+5) and		 						// sta :ecx+1				; 5
       sta_a(i+6) and 									// sta :ztmp9				; 6
       lda_stack(i+7) and 								// lda :STACKORIGIN+10			; 7
       sta_eax(i+8) and 								// sta :eax				; 8
       sta_a(i+9) and									// sta :ztmp10				; 9
       lda_stack(i+10) and 								// lda :STACKORIGIN+STACKWIDTH+10	; 10
//       sta_eax_1(i+11) and 								// sta :eax+1				; 11
       sta_a(i+12) then 								// sta :ztmp11				; 12
     if argMatch(i, i+10) then
     begin
      listing_tmp[0]  := listing[i+7];
      listing_tmp[1]  := listing[i+8];
      listing_tmp[2]  := listing[i+9];
      listing_tmp[3]  := listing[i+10];
      listing_tmp[4]  := listing[i+11];
      listing_tmp[5]  := listing[i+12];

      listing_tmp[6]  := listing[i+1];
      listing_tmp[7]  := listing[i+2];
      listing_tmp[8]  := listing[i+3];
      listing_tmp[9]  := listing[i+4];
      listing_tmp[10] := listing[i+5];
      listing_tmp[11] := listing[i+6];

      for p:=0 to 11 do listing[i+1+p] := listing_tmp[p];

      exit(false);
     end;


    if sta_eax_1(i+4) and								// sta :eax+1				; 4

       lda_a(i) and									// lda :ztmp8				; 0
       bpl_a(i+1) and									// bpl @+				; 1
       lda_a(i+2) and									// lda  				; 2
       sub(i+3) and									// sub 					; 3
//       sta_eax_1(i+4) and								// sta :eax+1				; 4
       lab_a(i+5) and									//@					; 5
       lda_stack(i+6) and 								// lda :STACKORIGIN			; 6
       (add_eax(i+7) or sub_eax(i+7)) and						// add|sub :eax				; 7
       sta_stack(i+8) and 								// sta :STACKORIGIN			; 8
       (EAX(i+9) = false) and								//					; 9
       (adc_sbc(i+10) = false) then							//~adc|sbc				; 10
     if (argMatch(i+4, i+7) = false) then
     begin
	listing[i]  := '';
	listing[i+1]:= '';
	listing[i+2]:= '';
	listing[i+3]:= '';
	listing[i+4]:= '';
	listing[i+5]:= '';

	exit(false);
     end;


    if sta_eax_1(i+18) and 								// sta :eax+1				; 18

       lda_a(i) and									// lda					; 0
       add_sub(i+1) and									// add|sub				; 1
       sta_stack(i+2) and								// sta :STACKORIGIN+9			; 2
       lda_a(i+3) and									// lda 					; 3
       adc_sbc(i+4) and									// adc|sbc				; 4
       sta_stack(i+5) and								// sta :STACKORIGIN+STACKWIDTH+9	; 5
       lda_a(i+6) and									// lda					; 6
       add_sub(i+7) and									// add|sub				; 7
       sta_ecx(i+8) and									// sta :ecx				; 8
       sta_a(i+9) and 									// sta					; 9
       lda_a(i+10) and 									// lda					; 10
       adc_sbc(i+11) and								// adc|sbc				; 11
       sta_ecx_1(i+12) and		 						// sta :ecx+1				; 12
       sta_a(i+13) and 									// sta					; 13
       lda_stack(i+14) and 								// lda :STACKORIGIN+9			; 14
       sta_eax(i+15) and 								// sta :eax				; 15
       sta_a(i+16) and 									// sta					; 16
       lda_stack(i+17) and 								// lda :STACKORIGIN+STACKWIDTH+9	; 17
//       sta_eax_1(i+18) and 								// sta :eax+1				; 18
       sta_a(i+19) then 								// sta					; 19
     if argMatch(i+2, i+14) and
	argMatch(i+5, i+17) then
     begin

      listing_tmp[0]  := listing[i];
      listing_tmp[1]  := listing[i+1];
      listing_tmp[2]  := listing[i+15];
      listing_tmp[3]  := listing[i+16];

      listing_tmp[4]  := listing[i+3];
      listing_tmp[5]  := listing[i+4];
      listing_tmp[6]  := listing[i+18];
      listing_tmp[7]  := listing[i+19];

      listing_tmp[8]  := listing[i+6];
      listing_tmp[9]  := listing[i+7];
      listing_tmp[10] := listing[i+8];
      listing_tmp[11] := listing[i+9];
      listing_tmp[12] := listing[i+10];
      listing_tmp[13] := listing[i+11];
      listing_tmp[14] := listing[i+12];
      listing_tmp[15] := listing[i+13];

      listing[i+16] := '';
      listing[i+17] := '';
      listing[i+18] := '';
      listing[i+19] := '';

      for p:=0 to 15 do listing[i+p] := listing_tmp[p];

      exit(false);
     end;

end;		// function
