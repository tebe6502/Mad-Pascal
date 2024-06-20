
// -----------------------------------------------------------------------------
// ===					EAX.
// -----------------------------------------------------------------------------

procedure opt_TEMP_EAX;
begin

    if (TemporaryBuf[0] = #9'lda :eax') and						// lda :eax				; 0

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
        (TemporaryBuf[1] = #9'sta @SHORTREAL_TRUNC.A') or				// sta @SHORTREAL_TRUNC.A		; 1

	(TemporaryBuf[1] = #9'sta @F16_I2F.SV')) then					// sta @F16_I2F.SV			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+1') and						// lda :eax+1				; 0

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
        (TemporaryBuf[1] = #9'sta @SHORTREAL_TRUNC.A+1') or				// sta @SHORTREAL_TRUNC.A+1		; 1

	(TemporaryBuf[1] = #9'sta @F16_I2F.SV+1')) then					// sta @F16_I2F.SV+1			; 1
       begin
	TemporaryBuf[0] := '~';
	TemporaryBuf[1] := '~';
       end;


    if (TemporaryBuf[0] = #9'lda :eax+2') and						// lda :eax+2				; 0

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

end;	// procedure
