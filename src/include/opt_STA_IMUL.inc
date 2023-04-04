
function opt_STA_IMUL(i: integer): Boolean;
begin

    Result := true;

// -----------------------------------------------------------------------------
// ===					IMUL.
// -----------------------------------------------------------------------------

    if (listing[i] = #9'jsr @mul40') and						// jsr @mul40		; 0
       lda(i+1) and									// lda			; 1
       add_eax(i+2) then								// add :eax		; 2
      begin
        listing[i+1] := #9'add ' + copy(listing[i+1], 6, 256);
	listing[i+2] := '';

	exit(false);
      end;


    if (listing[i] = #9'jsr @mul40') and						// jsr @mul40		; 0
       lda_eax(i+1) and									// lda :eax		; 1
       add_sub(i+2) then								// add|sub		; 2
      begin
	listing[i+1] := '';

	exit(false);
      end;


    if lda_im_0(i) and									// lda #$00		; 0
       (listing[i+1] = #9'sta :eax+2') and						// sta :eax+2		; 1
       lda_im_0(i+2) and								// lda #$00		; 2
       (listing[i+3] = #9'sta :eax+3') and						// sta :eax+3		; 3
       lda_a(i+4) and									// lda #$80		; 4
       (listing[i+5] = #9'sta :ecx') and						// sta :ecx		; 5
       lda_a(i+6) and									// lda #$01		; 6
       (listing[i+7] = #9'sta :ecx+1') and						// sta :ecx+1		; 7
       lda_im_0(i+8) and								// lda #$00		; 8
       (listing[i+9] = #9'sta :ecx+2') and						// sta :ecx+2		; 9
       lda_im_0(i+10) and								// lda #$00		; 10
       (listing[i+11] = #9'sta :ecx+3') and						// sta :ecx+3		; 11
       (listing[i+12] = #9'jsr imulECX') then						// jsr imulECX		; 12
      begin
	listing[i]   := listing[i+4];
	listing[i+1] := listing[i+5];
	listing[i+2] := listing[i+6];
	listing[i+3] := listing[i+7];

	listing[i+4] := #9'.ifdef fmulinit';
	listing[i+5] := #9'fmulu_16';
	listing[i+6] := #9'els';
	listing[i+7] := #9'imulCX';
	listing[i+8] := #9'eif';

	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';

	exit(false);
      end;


    if sta_eax(i) and									// sta :eax		; 0
       lda_im_0(i+1) and								// lda #$00		; 1
       adc_sbc_im_0(i+2) and								// adc|sbc #$00		; 2
       sta_eax_1(i+3) and								// sta :eax+1		; 3
       lda_im_0(i+4) and								// lda #$00		; 4
       adc_sbc_im_0(i+5) and								// adc|sbc #$00		; 5
       (listing[i+6] = #9'sta :eax+2') and						// sta :eax+2		; 6
       lda_im_0(i+7) and								// lda #$01		; 7
       adc_sbc_im_0(i+8) and								// adc|sbc #$00		; 8
       (listing[i+9] = #9'sta :eax+3') and						// sta :eax+3		; 9
       lda(i+10) and									// lda 			; 10
       (listing[i+11] = #9'sta :ecx') and						// sta :ecx		; 11
       lda_im_0(i+12) and								// lda #$00		; 12
       (listing[i+13] = #9'sta :ecx+1') and						// sta :ecx+1		; 13
       (listing[i+14] = #9'sta :ecx+2') and						// sta :ecx+2		; 14
       (listing[i+15] = #9'sta :ecx+3') and						// sta :ecx+3		; 15
       (listing[i+16] = #9'jsr imulECX') then						// jsr imulECX		; 16
      begin
	listing[i+1] := listing[i+10];
	listing[i+2] := listing[i+11];

	listing[i+3] := #9'.ifdef fmulinit';
	listing[i+4] := #9'fmulu_8';
	listing[i+5] := #9'els';
	listing[i+6] := #9'imulCL';
	listing[i+7] := #9'eif';

	listing[i+8] := '';
	listing[i+9] := '';
	listing[i+10]:= '';
	listing[i+11]:= '';
	listing[i+12]:= '';
	listing[i+13]:= '';
	listing[i+14]:= '';
	listing[i+15]:= '';
	listing[i+16]:= '';

	exit(false);
      end;

end;		// function


{
    if sta_eax(i) and									// sta :eax		; 0
       lda_a(i+1) and									// lda			; 1
       (listing[i+2] = #9'sta :ecx') and						// sta :ecx		; 2
       lda_a(i+3) and									// lda			; 3
       (listing[i+4] = #9'sta :ecx+1') and						// sta :ecx+1		; 4
       lda_im_0(i+5) and								// lda #$00		; 5
       (listing[i+6] = #9'sta :ecx+2') and						// sta :ecx+2		; 6
       (listing[i+7] = #9'sta :ecx+3') and						// sta :ecx+3		; 7
       sta_eax_1(i+8) and								// sta :eax+1		; 8
       (listing[i+9] = #9'sta :eax+2') and						// sta :eax+2		; 9
       (listing[i+10] = #9'sta :eax+3') and						// sta :eax+3		; 10
       (listing[i+11] = #9'jsr imulECX') then						// jsr imulECX		; 11
      begin
	listing[i+6] := listing[i+4];
	listing[i+5] := listing[i+3];
	listing[i+4] := listing[i+2];
	listing[i+3] := listing[i+1];

	listing[i+1] := #9'lda #$00';
	listing[i+2] := #9'sta :eax+1';

	listing[i+7] := #9'.ifdef fmulinit';
	listing[i+8] := #9'fmulu_16';
	listing[i+9] := #9'els';
	listing[i+10] := #9'imulCX';
	listing[i+11] := #9'eif';

	exit(false);
      end;


    if (listing[i] = #9'sta :ecx') and							// sta :ecx		; 0
       lda_a(i+1) and									// lda			; 1
       (listing[i+2] = #9'sta :ecx+1') and						// sta :ecx+1		; 2
       lda_im_0(i+3) and								// lda #$00		; 3
       (listing[i+4] = #9'sta :ecx+2') and						// sta :ecx+2		; 4
       lda_im_0(i+5) and								// lda #$00		; 5
       (listing[i+6] = #9'sta :ecx+3') and						// sta :ecx+3		; 6
       lda_a(i+7) and									// lda			; 7
       sta_eax(i+8) and									// sta :eax		; 8
       lda_a(i+9) and									// lda			; 9
       sta_eax_1(i+10) and								// sta :eax+1		; 10
       lda_a(i+11) and									// lda			; 11
       (listing[i+12] = #9'sta :eax+2') and						// sta :eax+2		; 12
       lda_a(i+13) and									// lda			; 13
       (listing[i+14] = #9'sta :eax+3') and						// sta :eax+3		; 14
       (listing[i+15] = #9'jsr imulECX') then						// jsr imulECX		; 15
      begin
	listing[i+6] := listing[i+4];
	listing[i+5] := listing[i+3];
	listing[i+4] := listing[i+2];
	listing[i+3] := listing[i+1];

	listing[i+1] := #9'lda #$00';
	listing[i+2] := #9'sta :eax+1';

	listing[i+7] := #9'.ifdef fmulinit';
	listing[i+8] := #9'fmulu_16';
	listing[i+9] := #9'els';
	listing[i+10] := #9'imulCX';
	listing[i+11] := #9'eif';

	exit(false);
      end;



	lda B
	sta :ecx
	lda B+1
	sta :ecx+1
	lda #$00
	sta :ecx+2
	lda #$00
	sta :ecx+3
	lda _A
	sta :eax
	lda _A+1
	sta :eax+1
	lda _A+2
	sta :eax+2
	lda _A+3
	sta :eax+3
	jsr imulECX
}
