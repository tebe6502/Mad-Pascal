  // -----------------------------------------------------------------------------
  // ===          FOR ch IN ident
  // -----------------------------------------------------------------------------

  if TokenAt(j).Kind <> TTokenKind.IDENTTOK then
    Error(j, TErrorCode.IdentifierExpected);

  IdentTemp := GetIdentIndex(TokenAt(j).Name);

  ActualParamType := IdentifierAt(IdentTemp).DataType;
  VarType := IdentifierAt(IdentTemp).AllocElementType;

  k := Elements(IdentTemp);

  if k * GetDataSize(VarType) > 256 then
    Error(j, 'only arrays with a maximum of 256 bytes');

  // writeln(ActualParamType,',', VarType,',',IdentifierAt(IdentTemp).NumAllocElements,',',IdentifierAt(IdentTemp).NumAllocElements_,' | ',IdentifierAt(IdentTemp).IdType);

  if (ActualParamType <> TDataType.STRINGPOINTERTOK) and not (IdentifierAt(IdentTemp).IdType in
    [TDataType.ARRAYTOK, TDataType.STRINGTOK, TDataType.STRINGLITERALTOK]) then
    Error(j, 'for-in statement cannot operate on collection type ''' + InfoAboutDataType(ActualParamType) + '''');

  if (VarType in [TDataType.RECORDTOK]) and (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) then
  // ok
  else
    GetCommonType(i, IdentifierAt(IdentIndex).DataType, VarType);

  StartOptimization(j);

  if ActualParamType = TDataType.STRINGPOINTERTOK then
    asm65(#9'lda #$00')
  else
    asm65(#9'lda #-' + IntToStr(k));


  asm65(#9'sta l_' + IntToHex(CodeSize, 4) + '+1');


  GenerateRepeatUntilProlog;    // Save return address used by GenerateForToDoEpilog

  SaveBreakAddress;

  asm65('; --- ForToDoCondition');

  StartOptimization(j);
  ResetOpty;        // !!!


  if ActualParamType = TDataType.STRINGPOINTERTOK then
  begin

    asm65(#9'ldy #$00');
    asm65(#9'cpy adr.' + GetLocalName(IdentTemp));
    asm65(#9'jeq l_' + IntToHex(CodePosStack[CodePosStackTop] + 3, 4));

    asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+1,y');
    asm65(#9'sta ' + GetLocalName(IdentIndex));

  end
  else
  begin

    case GetDataSize(VarType) of

      1: begin
        asm65(#9'ldy #$00');

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex));
      end;

      2: begin
        asm65(#9'lda #$00');
        asm65(#9'asl @');
        asm65(#9'tay');

        k := k * 2;

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex));

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256+1,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex) + '+1');
      end;

      4: begin
        asm65(#9'lda #$00');
        asm65(#9'asl @');
        asm65(#9'asl @');
        asm65(#9'tay');

        k := k * 4;

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex));

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256+1,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex) + '+1');

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256+2,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex) + '+2');

        asm65(#9'lda adr.' + GetLocalName(IdentTemp) + '+' + IntToStr(k) + '-256+3,y');
        asm65(#9'sta ' + GetLocalName(IdentIndex) + '+3');
      end;

    end;

  end;


  CheckTok(j + 1, TTokenKind.DOTOK);


  Inc(CodePosStackTop);
  CodePosStack[CodePosStackTop] := CodeSize;

  j := CompileStatement(j + 2);

  asm65;
  asm65('; --- ForToDoEpilog');

  if BreakPosStack[BreakPosStackTop].cnt then asm65('c_' + IntToHex(BreakPosStack[BreakPosStackTop].ptr, 4));

  asm65(#9'inc l_' + IntToHex(CodePosStack[CodePosStackTop - 1], 4) + '+1');
  asm65(#9'seq');
  GenerateWhileDoEpilog;

  RestoreBreakAddress;

  Result := j;

