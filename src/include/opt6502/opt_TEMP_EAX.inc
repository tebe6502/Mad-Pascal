
// -----------------------------------------------------------------------------
// ===					EAX.
// -----------------------------------------------------------------------------

procedure opt_TEMP_EAX;
begin


  if lda_eax_1(0) and
     (TemporaryBuf[1] = #9'add #$01') and
     (TemporaryBuf[2] = #9'sta @REAL_MUL.A+1') and
     lda_eax_2(3) and
     adc_im_0(4) and
     (TemporaryBuf[5] = #9'sta @REAL_MUL.A+2') and
     lda_eax_3(6) and
     adc_im_0(7) and
     (TemporaryBuf[8] = #9'sta @REAL_MUL.A+3') then
  begin
   TemporaryBuf[0] := #9'inl @REAL_MUL.A+1';
   TemporaryBuf[1] := '~';
   TemporaryBuf[2] := '~';
   TemporaryBuf[3] := '~';
   TemporaryBuf[4] := '~';
   TemporaryBuf[5] := '~';
   TemporaryBuf[6] := '~';
   TemporaryBuf[7] := '~';
   TemporaryBuf[8] := '~';
  end;


  if sta(1) and
     (sta(2) = false) then
  begin

    if (TemporaryBuf[0] = #9'lda :eax') and						// lda :eax				; 0
//       (sta(2) = false) and

       ((TemporaryBuf[1] = #9'sta @BYTE.MOD.A') or					// sta @BYTE.MOD.A			; 1
        (TemporaryBuf[1] = #9'sta @WORD.MOD.A') or					// sta @WORD.MOD.A			; 1
        (TemporaryBuf[1] = #9'sta @CARDINAL.MOD.A') or					// sta @CARDINAL.MOD.A			; 1
        (TemporaryBuf[1] = #9'sta @SHORTINT.MOD.A') or					// sta @SHORTINT.MOD.A			; 1
        (TemporaryBuf[1] = #9'sta @SMALLINT.MOD.A') or					// sta @SMALLINT.MOD.A			; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.MOD.A') or					// sta @INTEGER.MOD.A			; 1

        (TemporaryBuf[1] = #9'sta @BYTE.DIV.A') or					// sta @BYTE.DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @WORD.DIV.A') or					// sta @WORD.DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @CARDINAL.DIV.A') or					// sta @CARDINAL.DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @SHORTINT.DIV.A') or					// sta @SHORTINT.DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @SMALLINT.DIV.A') or					// sta @SMALLINT.DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.DIV.A') or					// sta @INTEGER.DIV.A			; 1

        (TemporaryBuf[1] = #9'sta @SHORTREAL_DIV.A') or					// sta @SHORTREAL_DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @REAL_DIV.A') or					// sta @REAL_DIV.A			; 1
        (TemporaryBuf[1] = #9'sta @SHORTREAL_MUL.A') or					// sta @SHORTREAL_MUL.A			; 1
        (TemporaryBuf[1] = #9'sta @REAL_MUL.A') or					// sta @REAL_MUL.A			; 1
        (TemporaryBuf[1] = #9'sta @REAL_FRAC.A') or					// sta @REAL_FRAC.A			; 1
        (TemporaryBuf[1] = #9'sta @REAL_ROUND.A') or					// sta @REAL_ROUND.A			; 1
        (TemporaryBuf[1] = #9'sta @REAL_TRUNC.A') or					// sta @REAL_TRUNC.A			; 1
        (TemporaryBuf[1] = #9'sta @SHORTREAL_FRAC.A') or				// sta @SHORTREAL_FRAC.A		; 1
        (TemporaryBuf[1] = #9'sta @SHORTREAL_TRUNC.A') or				// sta @SHORTREAL_TRUNC.A		; 1

	(TemporaryBuf[1] = #9'sta @F16_I2F.SV')) then					// sta @F16_I2F.SV			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+1') and						// lda :eax+1				; 0
//       (sta(2) = false) and

       ((TemporaryBuf[1] = #9'sta @WORD.MOD.A+1') or					// sta @WORD.MOD.A+1			; 1
        (TemporaryBuf[1] = #9'sta @CARDINAL.MOD.A+1') or				// sta @CARDINAL.MOD.A+1		; 1
        (TemporaryBuf[1] = #9'sta @SMALLINT.MOD.A+1') or				// sta @SMALLINT.MOD.A+1		; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.MOD.A+1') or					// sta @INTEGER.MOD.A+1			; 1

        (TemporaryBuf[1] = #9'sta @WORD.DIV.A+1') or					// sta @WORD.DIV.A+1			; 1
        (TemporaryBuf[1] = #9'sta @CARDINAL.DIV.A+1') or				// sta @CARDINAL.DIV.A+1		; 1
        (TemporaryBuf[1] = #9'sta @SMALLINT.DIV.A+1') or				// sta @SMALLINT.DIV.A+1		; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.DIV.A+1') or					// sta @INTEGER.DIV.A+1			; 1

        (TemporaryBuf[1] = #9'sta @SHORTREAL_DIV.A+1') or				// sta @SHORTREAL_DIV.A+1		; 1
        (TemporaryBuf[1] = #9'sta @REAL_DIV.A+1') or					// sta @REAL_DIV.A+1			; 1
        (TemporaryBuf[1] = #9'sta @SHORTREAL_MUL.A+1') or				// sta @SHORTREAL_MUL.A+1		; 1
        (TemporaryBuf[1] = #9'sta @REAL_MUL.A+1') or					// sta @REAL_MUL.A+1			; 1
        (TemporaryBuf[1] = #9'sta @REAL_FRAC.A+1') or					// sta @REAL_FRAC.A+1			; 1
        (TemporaryBuf[1] = #9'sta @REAL_ROUND.A+1') or					// sta @REAL_ROUND.A+1			; 1
        (TemporaryBuf[1] = #9'sta @REAL_TRUNC.A+1') or					// sta @REAL_TRUNC.A+1			; 1
        (TemporaryBuf[1] = #9'sta @SHORTREAL_FRAC.A+1') or				// sta @SHORTREAL_FRAC.A+1		; 1
        (TemporaryBuf[1] = #9'sta @SHORTREAL_TRUNC.A+1') or				// sta @SHORTREAL_TRUNC.A+1		; 1

	(TemporaryBuf[1] = #9'sta @F16_I2F.SV+1')) then					// sta @F16_I2F.SV+1			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+2') and						// lda :eax+2				; 0
//       (sta(2) = false) and

       ((TemporaryBuf[1] = #9'sta @CARDINAL.MOD.A+2') or				// sta @CARDINAL.MOD.A+2		; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.MOD.A+2') or					// sta @INTEGER.MOD.A+2			; 1

        (TemporaryBuf[1] = #9'sta @CARDINAL.DIV.A+2') or				// sta @CARDINAL.DIV.A+2		; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.DIV.A+2') or					// sta @INTEGER.DIV.A+2			; 1

        (TemporaryBuf[1] = #9'sta @REAL_DIV.A+2') or					// sta @REAL_DIV.A+2			; 1
        (TemporaryBuf[1] = #9'sta @REAL_MUL.A+2') or					// sta @REAL_MUL.A+2			; 1
        (TemporaryBuf[1] = #9'sta @REAL_FRAC.A+2') or					// sta @REAL_FRAC.A+2			; 1
        (TemporaryBuf[1] = #9'sta @REAL_ROUND.A+2') or					// sta @REAL_ROUND.A+2			; 1
        (TemporaryBuf[1] = #9'sta @REAL_TRUNC.A+2') or					// sta @REAL_TRUNC.A+2			; 1

	(TemporaryBuf[1] = #9'sta @F16_I2F.SV+2')) then					// sta @F16_I2F.SV+2			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+3') and						// lda :eax+3				; 0
//       (sta(2) = false) and

       ((TemporaryBuf[1] = #9'sta @CARDINAL.MOD.A+3') or				// sta @CARDINAL.MOD.A+3		; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.MOD.A+3') or					// sta @INTEGER.MOD.A+3			; 1

        (TemporaryBuf[1] = #9'sta @CARDINAL.DIV.A+3') or				// sta @CARDINAL.DIV.A+3		; 1
        (TemporaryBuf[1] = #9'sta @INTEGER.DIV.A+3') or					// sta @INTEGER.DIV.A+3			; 1

        (TemporaryBuf[1] = #9'sta @REAL_DIV.A+3') or					// sta @REAL_DIV.A+3			; 1
        (TemporaryBuf[1] = #9'sta @REAL_MUL.A+3') or					// sta @REAL_MUL.A+3			; 1
        (TemporaryBuf[1] = #9'sta @REAL_FRAC.A+3') or					// sta @REAL_FRAC.A+3			; 1
        (TemporaryBuf[1] = #9'sta @REAL_ROUND.A+3') or					// sta @REAL_ROUND.A+3			; 1
        (TemporaryBuf[1] = #9'sta @REAL_TRUNC.A+3') or					// sta @REAL_TRUNC.A+3			; 1

	(TemporaryBuf[1] = #9'sta @F16_I2F.SV+3')) then					// sta @F16_I2F.SV+3			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;

  end;


// -----------------------------------------------------------------------------


  if sta(1) and
     sta(2) then
  begin

    if (TemporaryBuf[0] = #9'lda :eax') and						// lda :eax				; 0
//       sta(1) and									// sta					; 1

       ((TemporaryBuf[2] = #9'sta @BYTE.MOD.A') or					// sta @BYTE.MOD.A			; 2
        (TemporaryBuf[2] = #9'sta @WORD.MOD.A') or					// sta @WORD.MOD.A			; 2
        (TemporaryBuf[2] = #9'sta @CARDINAL.MOD.A') or					// sta @CARDINAL.MOD.A			; 2
        (TemporaryBuf[2] = #9'sta @SHORTINT.MOD.A') or					// sta @SHORTINT.MOD.A			; 2
        (TemporaryBuf[2] = #9'sta @SMALLINT.MOD.A') or					// sta @SMALLINT.MOD.A			; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.MOD.A') or					// sta @INTEGER.MOD.A			; 2

        (TemporaryBuf[2] = #9'sta @BYTE.DIV.A') or					// sta @BYTE.DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @WORD.DIV.A') or					// sta @WORD.DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @CARDINAL.DIV.A') or					// sta @CARDINAL.DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @SHORTINT.DIV.A') or					// sta @SHORTINT.DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @SMALLINT.DIV.A') or					// sta @SMALLINT.DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.DIV.A') or					// sta @INTEGER.DIV.A			; 2

        (TemporaryBuf[2] = #9'sta @SHORTREAL_DIV.A') or					// sta @SHORTREAL_DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @REAL_DIV.A') or					// sta @REAL_DIV.A			; 2
        (TemporaryBuf[2] = #9'sta @SHORTREAL_MUL.A') or					// sta @SHORTREAL_MUL.A			; 2
        (TemporaryBuf[2] = #9'sta @REAL_MUL.A') or					// sta @REAL_MUL.A			; 2
        (TemporaryBuf[2] = #9'sta @REAL_FRAC.A') or					// sta @REAL_FRAC.A			; 2
        (TemporaryBuf[2] = #9'sta @REAL_ROUND.A') or					// sta @REAL_ROUND.A			; 2
        (TemporaryBuf[2] = #9'sta @REAL_TRUNC.A') or					// sta @REAL_TRUNC.A			; 2
        (TemporaryBuf[2] = #9'sta @SHORTREAL_FRAC.A') or				// sta @SHORTREAL_FRAC.A		; 2
        (TemporaryBuf[2] = #9'sta @SHORTREAL_TRUNC.A') or				// sta @SHORTREAL_TRUNC.A		; 2

	(TemporaryBuf[2] = #9'sta @F16_I2F.SV')) then					// sta @F16_I2F.SV			; 2
       begin
	TemporaryBuf[2] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+1') and						// lda :eax+1				; 0
//       sta(1) and									// sta					; 1

       ((TemporaryBuf[2] = #9'sta @WORD.MOD.A+1') or					// sta @WORD.MOD.A+1			; 2
        (TemporaryBuf[2] = #9'sta @CARDINAL.MOD.A+1') or				// sta @CARDINAL.MOD.A+1		; 2
        (TemporaryBuf[2] = #9'sta @SMALLINT.MOD.A+1') or				// sta @SMALLINT.MOD.A+1		; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.MOD.A+1') or					// sta @INTEGER.MOD.A+1			; 2

        (TemporaryBuf[2] = #9'sta @WORD.DIV.A+1') or					// sta @WORD.DIV.A+1			; 2
        (TemporaryBuf[2] = #9'sta @CARDINAL.DIV.A+1') or				// sta @CARDINAL.DIV.A+1		; 2
        (TemporaryBuf[2] = #9'sta @SMALLINT.DIV.A+1') or				// sta @SMALLINT.DIV.A+1		; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.DIV.A+1') or					// sta @INTEGER.DIV.A+1			; 2

        (TemporaryBuf[2] = #9'sta @SHORTREAL_DIV.A+1') or				// sta @SHORTREAL_DIV.A+1		; 2
        (TemporaryBuf[2] = #9'sta @REAL_DIV.A+1') or					// sta @REAL_DIV.A+1			; 2
        (TemporaryBuf[2] = #9'sta @SHORTREAL_MUL.A+1') or				// sta @SHORTREAL_MUL.A+1		; 2
        (TemporaryBuf[2] = #9'sta @REAL_MUL.A+1') or					// sta @REAL_MUL.A+1			; 2
        (TemporaryBuf[2] = #9'sta @REAL_FRAC.A+1') or					// sta @REAL_FRAC.A+1			; 2
        (TemporaryBuf[2] = #9'sta @REAL_ROUND.A+1') or					// sta @REAL_ROUND.A+1			; 2
        (TemporaryBuf[2] = #9'sta @REAL_TRUNC.A+1') or					// sta @REAL_TRUNC.A+1			; 2
        (TemporaryBuf[2] = #9'sta @SHORTREAL_FRAC.A+1') or				// sta @SHORTREAL_FRAC.A+1		; 2
        (TemporaryBuf[2] = #9'sta @SHORTREAL_TRUNC.A+1') or				// sta @SHORTREAL_TRUNC.A+1		; 2

	(TemporaryBuf[2] = #9'sta @F16_I2F.SV+1')) then					// sta @F16_I2F.SV+1			; 2
       begin
	TemporaryBuf[2] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+2') and						// lda :eax+2				; 0
//       sta(1) and									// sta					; 1

       ((TemporaryBuf[2] = #9'sta @CARDINAL.MOD.A+2') or				// sta @CARDINAL.MOD.A+2		; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.MOD.A+2') or					// sta @INTEGER.MOD.A+2			; 2

        (TemporaryBuf[2] = #9'sta @CARDINAL.DIV.A+2') or				// sta @CARDINAL.DIV.A+2		; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.DIV.A+2') or					// sta @INTEGER.DIV.A+2			; 2

        (TemporaryBuf[2] = #9'sta @REAL_DIV.A+2') or					// sta @REAL_DIV.A+2			; 2
        (TemporaryBuf[2] = #9'sta @REAL_MUL.A+2') or					// sta @REAL_MUL.A+2			; 2
        (TemporaryBuf[2] = #9'sta @REAL_FRAC.A+2') or					// sta @REAL_FRAC.A+2			; 2
        (TemporaryBuf[2] = #9'sta @REAL_ROUND.A+2') or					// sta @REAL_ROUND.A+2			; 2
        (TemporaryBuf[2] = #9'sta @REAL_TRUNC.A+2') or					// sta @REAL_TRUNC.A+2			; 2

	(TemporaryBuf[2] = #9'sta @F16_I2F.SV+2')) then					// sta @F16_I2F.SV+2			; 2
       begin
	TemporaryBuf[2] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+3') and						// lda :eax+3				; 0
//       sta(1) and									// sta					; 1

       ((TemporaryBuf[2] = #9'sta @CARDINAL.MOD.A+3') or				// sta @CARDINAL.MOD.A+3		; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.MOD.A+3') or					// sta @INTEGER.MOD.A+3			; 2

        (TemporaryBuf[2] = #9'sta @CARDINAL.DIV.A+3') or				// sta @CARDINAL.DIV.A+3		; 2
        (TemporaryBuf[2] = #9'sta @INTEGER.DIV.A+3') or					// sta @INTEGER.DIV.A+3			; 2

        (TemporaryBuf[2] = #9'sta @REAL_DIV.A+3') or					// sta @REAL_DIV.A+3			; 2
        (TemporaryBuf[2] = #9'sta @REAL_MUL.A+3') or					// sta @REAL_MUL.A+3			; 2
        (TemporaryBuf[2] = #9'sta @REAL_FRAC.A+3') or					// sta @REAL_FRAC.A+3			; 2
        (TemporaryBuf[2] = #9'sta @REAL_ROUND.A+3') or					// sta @REAL_ROUND.A+3			; 2
        (TemporaryBuf[2] = #9'sta @REAL_TRUNC.A+3') or					// sta @REAL_TRUNC.A+3			; 2

	(TemporaryBuf[2] = #9'sta @F16_I2F.SV+3')) then					// sta @F16_I2F.SV+3			; 2
       begin
	TemporaryBuf[2] := '~';
       end;

  end;


end;	// procedure
