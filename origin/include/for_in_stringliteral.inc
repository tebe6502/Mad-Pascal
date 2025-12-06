
// -----------------------------------------------------------------------------
// ===				FOR ch IN 'stringliteral'
// -----------------------------------------------------------------------------

	StartOptimization(j);

	k := Tok[j].StrLength;


	if k <> 0 then begin

	      asm65(#9'lda #-' + IntToStr(k));
   	      asm65(#9'sta l_' + IntToHex(CodeSize, 4) + '+1' );

	end;

	      GenerateRepeatUntilProlog;		// Save return address used by GenerateForToDoEpilog

	      SaveBreakAddress;

	      asm65('; --- ForToDoCondition');

	      StartOptimization(j);
	      ResetOpty;				// !!!


	if k <> 0 then begin

              asm65(#9'ldy #$00');

 	      asm65(#9'lda $' + IntToHex(Tok[j].StrAddress - CODEORIGIN + CODEORIGIN_BASE + 1,4) + '+' + IntToStr(k) + '-256,y' );
	      asm65(#9'sta ' + GetLocalName(IdentIndex));

	end else
	      asm65(#9'jmp l_' + IntToHex(CodePosStack[CodePosStackTop]+3, 4));


	      CheckTok(j + 1, DOTOK);

	      Inc(CodePosStackTop);
	      CodePosStack[CodePosStackTop] := CodeSize;

	      j := CompileStatement(j + 2);

	      asm65;
	      asm65('; --- ForToDoEpilog');

	      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

	if k <> 0 then begin

	      asm65(#9'inc l_' + IntToHex(CodePosStack[CodePosStackTop-1], 4) + '+1' );
	      asm65(#9'seq');

	end;

	      GenerateWhileDoEpilog;

	      RestoreBreakAddress;

	      Result := j;
