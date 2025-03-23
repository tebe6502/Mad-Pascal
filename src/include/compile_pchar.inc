
// -----------------------------------------------------------------------------
// ===				      PCHAR
// -----------------------------------------------------------------------------

	      case Tok[i + 2].Kind of

 // Character assignment to pointer  f:='a'

	CHARLITERALTOK:
		begin

		 Ident[IdentIndex].isInit := true;

		 StopOptimization;

		 case IndirectionLevel of
{
		     ASPOINTERTOPOINTER:
		     begin
		       asm65(#9'mwy ' + Ident[IdentIndex].Name + ' :bp2');
		       asm65(#9'ldy #$00');
		       asm65(#9'mva #$01 (:bp2),y');
		       asm65(#9'iny');
		       asm65(#9'mva #$' + IntToHex(Tok[i + 2].Value , 2) + ' (:bp2),y');
		     end;

		     ASPOINTERTOARRAYORIGIN:
		     begin
		       asm65(#9'mwy ' + Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'ldy :STACKORIGIN,x');
		       asm65(#9'mva #$' + IntToHex(Tok[i + 2].Value , 2) + ' (:bp2),y');

		       a65(__subBX);
		     end;
}
		     ASPOINTER:
		     begin

		       asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');
		       asm65(#9'ldy #$00');
		       asm65(#9'lda #$' + IntToHex(Tok[i + 2].Value , 2));
		       asm65(#9'sta (:bp2),y');
		       asm65(#9'tya');
		       asm65(#9'iny');
		       asm65(#9'sta (:bp2),y');

		     end;

		 end;		// case IndirectionLevel

		Result := i + 2;
		end;		// case CHARLITERALTOK

 // String assignment to pointer  f:='string'

	STRINGLITERALTOK:
		begin

		Ident[IdentIndex].isInit := true;

		StopOptimization;

		ResetOpty;

		svar := GetLocalName(IdentIndex);

		if Ident[IdentIndex].NumAllocElements in [0,1] then
		  NumCharacters := Tok[i + 2].StrLength
		else
		  NumCharacters := Min(Tok[i + 2].StrLength, Ident[IdentIndex].NumAllocElements - 1);

		 case IndirectionLevel of
{
		   ASPOINTERTOPOINTER:

		   if Tok[i + 2].StrLength = 0 then begin
		     asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
		     asm65(#9'ldy #$00');
		     asm65(#9'mva #$00 (:bp2),y');
		   end else
		    if pos('.', Ident[IdentIndex].Name) > 0 then begin

		     asm65(#9'mwa #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' @move.src');
		     asm65(#9'adw '+copy(Ident[IdentIndex].Name,1, pos('.', Ident[IdentIndex].Name)-1) + ' #' +Ident[IdentIndex].Name +'-DATAORIGIN @move.dst');
		     asm65(#9'mwa #'+IntToStr(Succ(NumCharacters))+' @move.cnt');
		     asm65(#9'jsr @move');

		    end else
		     asm65(#9'@move #CODEORIGIN+$'+IntToHex(Tok[i + 2].StrAddress - CODEORIGIN, 4)+' '+Ident[IdentIndex].Name+' #'+IntToStr(Succ(NumCharacters)));

		   ASPOINTERTOARRAYORIGIN:
		   GetCommonType(i + 1, CHARTOK, POINTERTOK);
}
		   ASPOINTER:
		   begin

		     if Tok[i + 2].StrLength = 0 then begin

		       asm65(#9'ldy ' + svar + '+1');
		       asm65(#9'sty :bp+1');
		       asm65(#9'ldy ' + svar);
		       asm65(#9'lda #$00');
		       asm65(#9'sta (:bp),y');

		     end else begin

		      asm65(#9'mwy ' + svar + ' :bp2');

		      if Ident[IdentIndex].DataType = POINTERTOK then
		       k := Tok[i + 2].StrAddress - CODEORIGIN + 1
		      else
		       k := Tok[i + 2].StrAddress - CODEORIGIN;

		       asm65(#9'lda <CODEORIGIN+$' + IntToHex(k, 4) );
		       asm65(#9'sta @move.src');
		       asm65(#9'lda >CODEORIGIN+$' + IntToHex(k, 4) );
		       asm65(#9'sta @move.src+1');

		       asm65(#9'@moveSTRING_P ' + svar);

		     end;

		   end;

		 end;		// case IndirectionLevel

		Result := i + 2;
		end;		// case STRINGLITERALTOK


	IDENTTOK:
		begin

		 Ident[IdentIndex].isInit := true;

		 //StopOptimization;

		 Result := CompileExpression(i + 2, ExpressionType, VarType);      // Right-hand side expression

//		 asm65;


 // Character assignment to pointer  var f:=c

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

		if ExpressionType = CHARTOK then begin

		 case IndirectionLevel of

		   ASPOINTER:
		     begin

		       asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');
		       asm65(#9'ldy #$00');
		       asm65(#9'lda :STACKORIGIN,x');
		       asm65(#9'sta (:bp2),y');
		       asm65(#9'tya');
		       asm65(#9'iny');
		       asm65(#9'sta (:bp2),y');

		      a65(TCode65.subBX);
		     end;
{
		   ASPOINTERTOPOINTER:
		     begin

		       asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
		       asm65(#9'ldy #$00');
		       asm65(#9'mva #$01 (:bp2),y');
		       asm65(#9'iny');
		       asm65(#9'mva :STACKORIGIN,x (:bp2),y');

		       a65(TCode65.subBX);
		     end;

		   ASPOINTERTOARRAYORIGIN:
		     begin

		      asm65(#9'mwy '+Ident[IdentIndex].Name+' :bp2');
		      asm65(#9'ldy :STACKORIGIN-1,x');
		      asm65(#9'lda :STACKORIGIN,x');
		      asm65(#9'sta (:bp2),y');

		      a65(TCode65.subBX);
		      a65(TCode65.subBX);
		     end;
}
		 else
		    GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex);

		 end;// case IndirectionLevel

		end else

 // String assignment to pointer  var f:=txt

		if ExpressionType in Pointers then begin

		  Ident[IdentIndex].isInit := true;

		  svar := GetLocalName(IdentIndex);

		  case IndirectionLevel of

		    ASPOINTER, ASPOINTERTOPOINTER:
		      begin

			asm65(#9'lda :STACKORIGIN,x');
			asm65(#9'sta @move.src');
			asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
			asm65(#9'sta @move.src+1');


		        if (ExpressionType = PCHARTOK) and (Ident[IdentIndex].DataType = STRINGPOINTERTOK) then
			 asm65(#9'@movePCHAR ' + svar + ' #' + IntToStr(Ident[IdentIndex].NumAllocElements-1))
			else
			if Ident[IdentIndex].DataType = POINTERTOK then
			 asm65(#9'@moveSTRING_P ' + svar)
			else
			 asm65(#9'@moveSTRING ' + svar + ' #' + IntToStr(Ident[IdentIndex].NumAllocElements-1));


			a65(TCode65.subBX);

			StopOptimization;

			ResetOpty;

		      end;

		  else
		   GenerateAssignment(IndirectionLevel, DataSize[VarType], IdentIndex);

		  end;// case IndirectionLevel


		end else
		 ErrorIncompatibleTypes(i, ExpressionType, VarType);

		end;


	      end; // case Tok[i + 2].Kind

