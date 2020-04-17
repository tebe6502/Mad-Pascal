
// -----------------------------------------------------------------------------
// ===				imulCL 8				  === //
// -----------------------------------------------------------------------------

    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and									// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and								// .ifdef fmulinit			; 4
       											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'ldy :eax') then						// ldy :eax				; 9
     begin

      listing[i]   := listing[i+2];

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';
      listing[i+4] := #9'tay';

      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;


    if (listing[i] = #9'lda #$08') and							// lda #$08				; 0
       (listing[i+1] = #9'sta :ecx') and						// sta :ecx				; 1
       lda(i+2) and									// lda 					; 2
       (listing[i+3] = #9'sta :eax') and						// sta :eax				; 3
       IFDEF_MUL8(i+4) and 								// .ifdef fmulinit			; 4
      											// fmulu_8				; 5
       											// els					; 6
       											// imulCL				; 7
       											// eif					; 8
       (listing[i+9] = #9'lda :eax') and						// lda :eax				; 9
       add_sub(i+10) and								// add|sub				; 10
       tay(i+11) then									// tay					; 11
     begin

      listing[i]   := listing[i+2];

      listing[i+1] := #9'asl @';
      listing[i+2] := #9'asl @';
      listing[i+3] := #9'asl @';

      listing[i+4] := '';
      listing[i+5] := '';
      listing[i+6] := '';
      listing[i+7] := '';
      listing[i+8] := '';
      listing[i+9] := '';

      Result:=false; Break;
     end;

