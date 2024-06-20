
	      StartOptimization(j);

              asm65(#9'lda #$00');
   	      asm65(#9'sta l_' + IntToHex(CodeSize, 4) + '+1' );

	      GenerateRepeatUntilProlog;		// Save return address used by GenerateForToDoEpilog

	      SaveBreakAddress;

	      asm65('; --- ForToDoCondition');

	      StartOptimization(j);
	      ResetOpty;				// !!!

	      asm65(#9'ldy #$00');

 	      asm65(#9'lda $' + IntToHex(Tok[j].StrAddress - CODEORIGIN + CODEORIGIN_BASE + 1,4) + ',y' );
	      asm65(#9'jeq l_' + IntToHex(CodePosStack[CodePosStackTop], 4));
	      asm65(#9'sta ' + GetLocalName(IdentIndex));

	      CheckTok(j + 1, DOTOK);

	      Inc(CodePosStackTop);
	      CodePosStack[CodePosStackTop] := CodeSize;

	      j := CompileStatement(j + 2);

	      asm65;
	      asm65('; --- ForToDoEpilog');

	      if BreakPosStack[BreakPosStackTop].cnt then asm65('c_'+IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

	      asm65(#9'inc l_' + IntToHex(CodePosStack[CodePosStackTop-1], 4) + '+1' );
	      asm65(#9'seq');
	      GenerateWhileDoEpilog;

	      RestoreBreakAddress;

	      Result := j;
