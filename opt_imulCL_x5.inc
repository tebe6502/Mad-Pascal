
// -----------------------------------------------------------------------------
// ===				imulCL 5				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'sta :eax') and							// sta :eax				; 0
       (listing[i+1] = #9'lda #$05') and						// lda #$05				; 1
       (listing[i+2] = #9'sta :ecx') and						// sta :ecx				; 2
       IFDEF_MUL8(i+3) and								// .ifdef fmulinit			; 3
       											// fmulu_8				; 4
       											// els					; 5
       											// imulCL				; 6
       											// eif					; 7
       lda(i+8) and									// lda					; 8
       ((listing[i+9] = #9'add :eax') or (listing[i+9] = #9'sub :eax')) and		// add|sub :eax				; 9
       sta(i+10) and									// sta					; 10
       lda(i+11) and									// lda					; 11
       (adc_im_0(i+12) or sbc_im_0(i+12)) then						// adc|sbc #$00				; 12
     begin

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'add :eax';
      listing[i+4] := #9'sta :eax';

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';

      Result:=false; Break;
     end;
