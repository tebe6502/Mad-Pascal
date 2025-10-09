  // -----------------------------------------------------------------------------
  // ===              PCHAR
  // -----------------------------------------------------------------------------

  case TokenAt(i + 2).Kind of

    // Character assignment to pointer  f:='a'

    TTokenKind.CHARLITERALTOK:
    begin

      IdentifierAt(IdentIndex).isInit := True;

      StopOptimization;

      case IndirectionLevel of
{
         ASPOINTERTOPOINTER:
         begin
           asm65(#9'mwy ' + IdentifierAt(IdentIndex).Name + ' :bp2');
           asm65(#9'ldy #$00');
           asm65(#9'mva #$01 (:bp2),y');
           asm65(#9'iny');
           asm65(#9'mva #$' + IntToHex(TokenAt(i + 2).Value , 2) + ' (:bp2),y');
         end;

         ASPOINTERTOARRAYORIGIN:
         begin
           asm65(#9'mwy ' + IdentifierAt(IdentIndex).Name+' :bp2');
           asm65(#9'ldy :STACKORIGIN,x');
           asm65(#9'mva #$' + IntToHex(TokenAt(i + 2).Value , 2) + ' (:bp2),y');

           a65(__subBX);
         end;
}
        ASPOINTER:
        begin

          asm65(#9'mwy ' + GetLocalName(IdentIndex) + ' :bp2');
          asm65(#9'ldy #$00');
          asm65(#9'lda #$' + IntToHex(TokenAt(i + 2).Value, 2));
          asm65(#9'sta (:bp2),y');
          asm65(#9'tya');
          asm65(#9'iny');
          asm65(#9'sta (:bp2),y');

        end;

      end;    // case IndirectionLevel

      Result := i + 2;
    end;    // case TTokenKind.CHARLITERALTOK

    // String assignment to pointer  f:='string'

    TTokenKind.STRINGLITERALTOK:
    begin

      IdentifierAt(IdentIndex).isInit := True;

      StopOptimization;

      ResetOpty;

      svar := GetLocalName(IdentIndex);

      if IdentifierAt(IdentIndex).NumAllocElements in [0, 1] then
        NumCharacters := TokenAt(i + 2).StrLength
      else
        NumCharacters := Min(TokenAt(i + 2).StrLength, IdentifierAt(IdentIndex).NumAllocElements - 1);

      case IndirectionLevel of
{
       ASPOINTERTOPOINTER:

       if TokenAt(i + 2).StrLength = 0 then begin
         asm65(#9'mwy '+IdentifierAt(IdentIndex).Name+' :bp2');
         asm65(#9'ldy #$00');
         asm65(#9'mva #$00 (:bp2),y');
       end else
        if pos('.', IdentifierAt(IdentIndex).Name) > 0 then begin

         asm65(#9'mwa #CODEORIGIN+$'+IntToHex(TokenAt(i + 2).StrAddress - CODEORIGIN, 4)+' @move.src');
         asm65(#9'adw '+copy(IdentifierAt(IdentIndex).Name,1, pos('.', IdentifierAt(IdentIndex).Name)-1) + ' #' +IdentifierAt(IdentIndex).Name +'-DATAORIGIN @move.dst');
         asm65(#9'mwa #'+IntToStr(Succ(NumCharacters))+' @move.cnt');
         asm65(#9'jsr @move');

        end else
         asm65(#9'@move #CODEORIGIN+$'+IntToHex(TokenAt(i + 2).StrAddress - CODEORIGIN, 4)+' '+IdentifierAt(IdentIndex).Name+' #'+IntToStr(Succ(NumCharacters)));

       ASPOINTERTOARRAYORIGIN:
       GetCommonType(i + 1, CHARTOK, TTokenKind.POINTERTOK);
}
        ASPOINTER:
        begin

          if TokenAt(i + 2).StrLength = 0 then
          begin

            asm65(#9'ldy ' + svar + '+1');
            asm65(#9'sty :bp+1');
            asm65(#9'ldy ' + svar);
            asm65(#9'lda #$00');
            asm65(#9'sta (:bp),y');

          end
          else
          begin

            asm65(#9'mwy ' + svar + ' :bp2');

            if IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK then
              k := TokenAt(i + 2).StrAddress - CODEORIGIN + 1
            else
              k := TokenAt(i + 2).StrAddress - CODEORIGIN;

            asm65(#9'lda <CODEORIGIN+$' + IntToHex(k, 4));
            asm65(#9'sta @move.src');
            asm65(#9'lda >CODEORIGIN+$' + IntToHex(k, 4));
            asm65(#9'sta @move.src+1');

            asm65(#9'@moveSTRING_P ' + svar);

          end;

        end;

      end;    // case IndirectionLevel

      Result := i + 2;
    end;    // case TTokenKind.STRINGLITERALTOK


    TTokenKind.IDENTTOK:
    begin

      IdentifierAt(IdentIndex).isInit := True;

      //StopOptimization;

      Result := CompileExpression(i + 2, ExpressionType, VarType);      // Right-hand side expression

      //     asm65;


      // Character assignment to pointer  var f:=c

      //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).PassMethod,' | ',VarType,',',ExpressionType,',',IndirectionLevel);

      if ExpressionType = TDataType.CHARTOK then
      begin

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

           asm65(#9'mwy '+IdentifierAt(IdentIndex).Name+' :bp2');
           asm65(#9'ldy #$00');
           asm65(#9'mva #$01 (:bp2),y');
           asm65(#9'iny');
           asm65(#9'mva :STACKORIGIN,x (:bp2),y');

           a65(TCode65.subBX);
         end;

       ASPOINTERTOARRAYORIGIN:
         begin

          asm65(#9'mwy '+IdentifierAt(IdentIndex).Name+' :bp2');
          asm65(#9'ldy :STACKORIGIN-1,x');
          asm65(#9'lda :STACKORIGIN,x');
          asm65(#9'sta (:bp2),y');

          a65(TCode65.subBX);
          a65(TCode65.subBX);
         end;
}
          else
            GenerateAssignment(IndirectionLevel, GetDataSize(VarType), IdentIndex);

        end;// case IndirectionLevel

      end
      else

      // String assignment to pointer  var f:=txt

      if ExpressionType in Pointers then
      begin

        IdentifierAt(IdentIndex).isInit := True;

        svar := GetLocalName(IdentIndex);

        case IndirectionLevel of

          ASPOINTER, ASPOINTERTOPOINTER:
          begin

            asm65(#9'lda :STACKORIGIN,x');
            asm65(#9'sta @move.src');
            asm65(#9'lda :STACKORIGIN+STACKWIDTH,x');
            asm65(#9'sta @move.src+1');


            if (ExpressionType = TDataType.PCHARTOK) and (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) then
              asm65(#9'@movePCHAR ' + svar + ' #' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1))
            else
            if IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK then
              asm65(#9'@moveSTRING_P ' + svar)
            else
              asm65(#9'@moveSTRING ' + svar + ' #' + IntToStr(IdentifierAt(IdentIndex).NumAllocElements - 1));


            a65(TCode65.subBX);

            StopOptimization;

            ResetOpty;

          end;

          else
            GenerateAssignment(IndirectionLevel, GetDataSize(VarType), IdentIndex);

        end;// case IndirectionLevel

      end
      else
        ErrorIncompatibleTypes(i, ExpressionType, VarType);

    end;

  end; // case TokenAt(i + 2).Kind

