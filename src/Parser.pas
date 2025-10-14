unit Parser;

{$I Defines.inc}

interface

uses Common, CompilerTypes, Datatypes, Numbers, Tokens;

  // -----------------------------------------------------------------------------

function CompileType(i: TTokenIndex; out DataType: TDataType; out NumAllocElements: Cardinal;
  out AllocElementType: TDataType): TTokenIndex;

function CompileConstExpression(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDataType;
  const VarType: TDataType = TDataType.INTEGERTOK; const Err: Boolean = False; const War: Boolean = True): TTokenIndex;

function CompileConstTerm(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDataType): TTokenIndex;

procedure DefineIdent(const tokenIndex: TTokenIndex; Name: TIdentifierName; Kind: TTokenKind;
  DataType: TDataType; NumAllocElements: Cardinal; AllocElementType: TDataType; Data: Int64;
  IdType: TDataType = TDataType.IDENTTOK);

function DefineFunction(i: TTokenIndex; ForwardIdentIndex: TIdentIndex; out isForward, isInt, isInl, isOvr: Boolean;
  var IsNestedFunction: Boolean; out NestedFunctionResultType: TDataType;
  out NestedFunctionNumAllocElements: Cardinal; out NestedFunctionAllocElementType: TDataType): Integer;

function Elements(IdentIndex: TIdentIndex): Cardinal;

function GetIdentIndex(const S: TIdentifierName): TIdentIndex;

function GetSizeOf(i: TTokenIndex; ValType: TDataType): Int64;

function ObjectRecordSize(i: Cardinal): Integer;

function RecordSize(IdentIndex: TIdentIndex; field: String = ''): Integer;

procedure SaveToDataSegment(index: Integer; Value: Int64; valueDataType: TDataType);

// -----------------------------------------------------------------------------

implementation

uses SysUtils, Debugger, Messages, Utilities;

  // ----------------------------------------------------------------------------


function Elements(IdentIndex: Integer): Cardinal;
begin

  if (IdentifierAt(IdentIndex).DataType = TDataType.ENUMTOK) then
    Result := 0
  else

    if IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
      Result := IdentifierAt(IdentIndex).NumAllocElements_
    else
      if (IdentifierAt(IdentIndex).NumAllocElements_ = 0) or (IdentifierAt(IdentIndex).AllocElementType in
        [TDataType.PROCVARTOK]) then
        Result := IdentifierAt(IdentIndex).NumAllocElements
      else
        Result := IdentifierAt(IdentIndex).NumAllocElements * IdentifierAt(IdentIndex).NumAllocElements_;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetIdentIndex(const S: TIdentifierName): TIdentIndex;
var
  WithIndex: Integer;
  DotIndex: Integer;
  DotPrefix, DotSuffix: TIdentifierName;
  TempIdentIndex: TIdentIndex;
  TempIdentifier: TIdentifier;

  function UnitAllowedAccess(const identifier: TIdentifier; const SourceFile: TSourceFile): Boolean;
  begin

    Result := False;

    if identifier.IsSection then
      Result := SourceFile.IsAllowedUnitName(identifier.SourceFile.Name);
  end;


  function Search(const X: TString; const SourceFile: TSourceFile): TIdentIndex;
  var
    BlockStackIndex: Integer;
    blockIndex: TBlockIndex;
    IdentIndex: TIdentIndex;
    identifier: TIdentifier;
  begin

    Result := 0;

    // Search all nesting levels from the current one to the most outer one
    for BlockStackIndex := BlockStackTop downto 0 do
    begin
      blockIndex := BlockStack[BlockStackIndex];
      for IdentIndex := 1 to NumIdent do
      begin
        // identifier := IdentifierAt(IdentIndex);
        identifier := IdentifierList.GetIdentifierAtIndex(IdentIndex);
        if (X = identifier.Name) and (blockIndex = identifier.Block) then
          if (identifier.SourceFile.UnitIndex = SourceFile.UnitIndex)
            {or identifier.Section} or (identifier.SourceFile.UnitIndex = 1) or
            (identifier.SourceFile.Name = 'SYSTEM') or UnitAllowedAccess(identifier, SourceFile) then
          begin
            Result := IdentIndex;
            identifier.Pass := Pass;

            if (identifier.SourceFile.UnitIndex = SourceFile.UnitIndex) or
              (identifier.SourceFile.UnitIndex = 1)
            { or (identifier.SourceFile.NAME) = 'SYSTEM')} then exit;
          end;
      end;
    end;
  end;


  function SearchCurrenSourceFile(const X: TString; const SourceFile: TSourceFile): Integer;
  var
    BlockStackIndex: TBlockStackIndex;
    BlockIndex: TBlockIndex;
    IdentIndex: TIdentifierIndex;
    identifier: TIdentifier;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do
    begin
      blockIndex := BlockStack[BlockStackIndex];

      // Search all nesting levels from the current one to the most outer one
      for IdentIndex := 1 to NumIdent do
      begin
        identifier := IdentifierAt(IdentIndex);

        if (X = identifier.Name) and (blockIndex = identifier.Block) then
          if (identifier.SourceFile.UnitIndex = SourceFile.UnitIndex) or
            UnitAllowedAccess(identifier, SourceFile) then
          begin
            Result := IdentIndex;
            identifier.Pass := Pass;

            if (identifier.SourceFile.UnitIndex = SourceFile.UnitIndex) then exit;
          end;
      end;
    end;
  end;

begin

  if S = '' then exit(-1);

  // Check if it can be found in the current WITH context
  if High(WithName) > 0 then
    for WithIndex := 0 to High(WithName) do
    begin
      Result := Search(WithName[WithIndex] + '.' + S, ActiveSourceFile);

      if Result > 0 then exit;
    end;

  Result := Search(S, ActiveSourceFile);

  if (Result = 0) then
  begin
    DotIndex := pos('.', S);
    if (DotIndex > 0) then;
    begin
      // Potentially a reference to a unit/object
      dotPrefix := copy(S, 1, DotIndex - 1);
      dotSuffix := copy(S, DotIndex + 1, length(S));
      TempIdentIndex := Search(dotPrefix, ActiveSourceFile);

      //    writeln(S,',',IdentifierAt(TempIndex).Kind,' - ', IdentifierAt(TempIndex).DataType, ' / ',IdentifierAt(TempIndex).AllocElementType);

      if TempIdentIndex > 0 then
      begin
        TempIdentifier := IdentifierAt(TempIdentIndex);
        if (TempIdentifier.Kind = TTokenKind.UNITTOK) or (TempIdentifier.DataType = TDataType.ENUMTOK) then
          Result := SearchCurrenSourceFile(copy(S, pos('.', S) + 1, length(S)), TempIdentifier.SourceFile)
        else
          if TempIdentifier.DataType = TDataType.OBJECTTOK then
            Result := SearchCurrenSourceFile(GetTypeAtIndex(TempIdentifier.NumAllocElements).Field[0].Name +
              '.' + dotSuffix, TempIdentifier.SourceFile);
      {else
       if ( (TempIdentifier.DataType in Pointers) and (TempIdentifier.AllocElementType = RECORDTOK) ) then
  Result := TempIdentIndex;}

        //    writeln(S,' | ',copy(S, 1, pos('.', S)-1),',',TempIdentIndex,'/',Result,' | ',TempIdentifier.Kind,',',TempIdentifier.SourceFile.Name);
      end;
    end;
  end;

end;  //GetIdentIndex


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ObjectRecordSize(i: Cardinal): Integer;
var
  j: Integer;
  FieldType: TDataType;
begin

  Result := 0;

  if i > 0 then
  begin

    for j := 1 to GetTypeAtIndex(i).NumFields do
    begin

      FieldType := GetTypeAtIndex(i).Field[j].DataType;

      if FieldType <> TDataType.RECORDTOK then
        Inc(Result, GetDataSize(FieldType));

    end;

  end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function RecordSize(IdentIndex: Integer; field: String = ''): Integer;
var
  i, j: Integer;
  Name, base: TName;
  FieldType, AllocElementType: TDataType;
  NumAllocElements, NumAllocElements_: Cardinal;
  yes: Boolean;
begin

  // if IdentifierAt(IdentIndex).NumAllocElements_ > 0 then
  //  i := IdentifierAt(IdentIndex).NumAllocElements_
  // else
  i := IdentifierAt(IdentIndex).NumAllocElements and $FFFF;

  Result := 0;

  FieldType := TDataType.UNTYPETOK;

  yes := False;

  if i > 0 then
  begin

    for j := 1 to GetTypeAtIndex(i).NumFields do
    begin

      FieldType := GetTypeAtIndex(i).Field[j].DataType;
      NumAllocElements := GetTypeAtIndex(i).Field[j].NumAllocElements and $FFFF;
      NumAllocElements_ := GetTypeAtIndex(i).Field[j].NumAllocElements shr 16;
      AllocElementType := GetTypeAtIndex(i).Field[j].AllocElementType;

      if AllocElementType in [TDataType.FORWARDTYPE, TDataType.PROCVARTOK] then
      begin
        AllocElementType := TDataType.POINTERTOK;
        NumAllocElements := 0;
        NumAllocElements_ := 0;
      end;

      if FieldType = TDataType.ENUMTOK then FieldType := AllocElementType;

      if GetTypeAtIndex(i).Field[j].Name = field then
      begin
        yes := True;
        Break;
      end;

      if FieldType <> TDataType.RECORDTOK then
        if (FieldType in Pointers) and (NumAllocElements > 0) then
        begin
          if AllocElementType = TDataType.RECORDTOK then
          begin
            AllocElementType := TDataType.POINTERTOK;
            NumAllocElements := _TypeArray[i].Field[j].NumAllocElements shr 16;
            NumAllocElements_ := 0;
          end;
          if NumAllocElements_ > 0 then
            Inc(Result, NumAllocElements * NumAllocElements_ * GetDataSize(AllocElementType))
          else
            Inc(Result, NumAllocElements * GetDataSize(AllocElementType));
        end
        else
          Inc(Result, GetDataSize(FieldType));

    end;

  end
  else
  begin

    Name := IdentifierAt(IdentIndex).Name;

    base := copy(Name, 1, pos('.', Name) - 1);

    IdentIndex := GetIdentIndex(base);

    for i := 1 to GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).NumFields do
      if pos(Name, base + '.' + GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].Name) > 0 then
        if GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].DataType <> TDataType.RECORDTOK then
        begin

          FieldType := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].DataType;
          NumAllocElements := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].NumAllocElements
            and $ffff;
          NumAllocElements_ := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].NumAllocElements
            shr 16;
          AllocElementType := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].AllocElementType;

          if FieldType = TDataType.ENUMTOK then FieldType := AllocElementType;

          if GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].Name = field then
          begin
            yes := True;
            Break;
          end;

          if FieldType <> TDataType.RECORDTOK then
            if (FieldType in Pointers) and (NumAllocElements > 0) then
            begin

              if AllocElementType = TDataType.RECORDTOK then
              begin
                AllocElementType := TDataType.POINTERTOK;
                NumAllocElements := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[i].NumAllocElements
                  shr 16;
                NumAllocElements_ := 0;
              end;

              if NumAllocElements_ > 0 then
                Inc(Result, NumAllocElements * NumAllocElements_ * GetDataSize(AllocElementType))
              else
                Inc(Result, NumAllocElements * GetDataSize(AllocElementType));

            end
            else
              Inc(Result, GetDataSize(FieldType));

        end;

  end;


  if field <> '' then
    if not yes then
      Result := -1
    else
      Result := Result + Ord(FieldType) shl 16;    // type | offset

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

procedure SaveToDataSegment(index: Integer; Value: Int64; valueDataType: TDataType);
begin
  // LogTrace(Format('SaveToDataSegment(index=%d, value=%d, valueDataType=%d', [index, value, valueDataType]));

  if (index < 0) or (index > $FFFF) then
  begin
    writeln('SaveToDataSegment: Invalid segment index', index);
    RaiseHaltException(EHaltException.COMPILING_ABORTED);
  end;

  case valueDataType of

    TDataType.SHORTINTTOK, TDataType.BYTETOK, TDataType.CHARTOK, TDataType.BOOLEANTOK:
    begin
      _DataSegment[index] := Byte(Value);
    end;

    TDataType.SMALLINTTOK, TDataType.WORDTOK, TDataType.SHORTREALTOK, TDataType.POINTERTOK,
    TDataType.STRINGPOINTERTOK, TDataType.PCHARTOK:
    begin
      _DataSegment[index] := Byte(Value);
      _DataSegment[index + 1] := Byte(Value shr 8);
    end;

    TDataType.DATAORIGINOFFSET:
    begin
      _DataSegment[index] := Byte(Value) or $8000;
      _DataSegment[index + 1] := Byte(Value shr 8) or $4000;
    end;

    TDataType.CODEORIGINOFFSET:
    begin
      _DataSegment[index] := Byte(Value) or $2000;
      _DataSegment[index + 1] := Byte(Value shr 8) or $1000;
    end;

    TDataType.INTEGERTOK, TDataType.CARDINALTOK, TDataType.REALTOK:
    begin
      _DataSegment[index] := Byte(Value);
      _DataSegment[index + 1] := Byte(Value shr 8);
      _DataSegment[index + 2] := Byte(Value shr 16);
      _DataSegment[index + 3] := Byte(Value shr 24);
    end;

    TDataType.SINGLETOK: begin
      Value := CastToSingle(Value);

      _DataSegment[index] := Byte(Value);
      _DataSegment[index + 1] := Byte(Value shr 8);
      _DataSegment[index + 2] := Byte(Value shr 16);
      _DataSegment[index + 3] := Byte(Value shr 24);
    end;

    TDataType.HALFSINGLETOK: begin
      Value := CastToHalfSingle(Value);

      _DataSegment[index] := Byte(Value);
      _DataSegment[index + 1] := Byte(Value shr 8);
    end;

  end;

  DataSegmentUse := True;

end;  //SaveToDataSegment


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetSizeOf(i: TTokenIndex; ValType: TDataType): Int64;
var
  IdentIndex: Integer;
begin

  IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

  case ValType of

    TDataType.ENUMTOK:
      Result := GetDataSize(IdentifierAt(IdentIndex).AllocElementType);

    TDataType.RECORDTOK:
      if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and (TokenAt(i + 3).Kind = TTokenKind.CPARTOK) then
        Result := GetDataSize(TDataType.POINTERTOK)
      else
        Result := RecordSize(IdentIndex);

    TDataType.POINTERTOK, TDataType.STRINGPOINTERTOK:
    begin

      if IdentifierAt(IdentIndex).AllocElementType = TDataType.RECORDTOK then
      begin

        if IdentifierAt(IdentIndex).NumAllocElements_ > 0 then
        begin

          if TokenAt(i + 3).Kind = TTokenKind.OBRACKETTOK then
            Result := GetDataSize(TDataType.POINTERTOK)
          else
            Result := IdentifierAt(IdentIndex).NumAllocElements_ * 2;

        end
        else
          if IdentifierAt(IdentIndex).PassMethod = TParameterPassingMethod.VARPASSING then
            Result := RecordSize(IdentIndex)
          else
            Result := GetDataSize(TDataType.POINTERTOK);

      end
      else
        if Elements(IdentIndex) > 0 then
          Result := Integer(Elements(IdentIndex) * GetDataSize(IdentifierAt(IdentIndex).AllocElementType))
        else
          Result := GetDataSize(TDataType.POINTERTOK);

    end;

    else

      if ValType = TDataType.UNTYPETOK then
        Result := 0
      else
        Result := GetDataSize(ValType)

  end;

end;  //GetSizeof


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstFactor(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDataType): TTokenIndex;
var
  IdentIndex: TIdentifierIndex;
  j: TTokenIndex;
  Kind: TTokenKind;
  ArrayIndexType: TDataType;
  ArrayIndex: Int64;

  function GetStaticValue(const x: Byte): Int64;
  begin

    Result := StaticStringData[IdentifierAt(IdentIndex).Value - CODEORIGIN - CODEORIGIN_BASE +
      ArrayIndex * GetDataSize(ConstValType) + x];

  end;

begin

  ConstVal := 0;
  ConstValType := TDataType.UNTYPETOK;
  Result := i;

  j := 0;

  // WRITELN(TokenAt(i).line, ',', TokenAt(i).kind);

  case TokenAt(i).Kind of

    TTokenKind.LOWTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 2).Kind = IDENTTOK then
      begin

        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

        if IdentifierAt(IdentIndex).DataType = TDataType.SUBRANGETYPE then
        begin

          ConstVal := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[1].Value;
          ConstValType := TDataType.SUBRANGETYPE;

          Inc(i, 2);

        end;

      end
      else

        if TokenAt(i + 2).GetDataType in AllTypes {+ [TTokenKind.STRINGTOK]} then
        begin

          ConstValType := TokenAt(i + 2).GetDataType;

          Inc(i, 2);

        end
        else
        begin

          i := CompileConstExpression(i + 2, ConstVal, ConstValType);

          if isError then Exit;

        end;


      if ConstValType = TDataType.SUBRANGETYPE then

      else
        if ConstValType in Pointers then
          ConstVal := 0
        else
          ConstVal := LowBound(i, ConstValType);

      ConstValType := GetValueType(ConstVal);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Result := i + 1;
    end;


    TTokenKind.HIGHTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 2).Kind = IDENTTOK then
      begin

        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

        if IdentifierAt(IdentIndex).DataType = TDataType.SUBRANGETYPE then
        begin

          ConstVal := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[2].Value;
          ConstValType := TDataType.SUBRANGETYPE;

          Inc(i, 2);

        end;

      end
      else
        if TokenAt(i + 2).GetDataType in AllTypes {+ [TDataType.STRINGTOK]} then
        begin

          ConstValType := TokenAt(i + 2).GetDataType;

          Inc(i, 2);

        end
        else
        begin

          i := CompileConstExpression(i + 2, ConstVal, ConstValType);

          if isError then Exit;

        end;

      if ConstValType = TDataType.SUBRANGETYPE then

      else
        if ConstValType in Pointers then
        begin
          IdentIndex := GetIdentIndex(TokenAt(i).Name);

          if IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
            ConstVal := IdentifierAt(IdentIndex).NumAllocElements_ - 1
          else
            if IdentifierAt(IdentIndex).NumAllocElements > 0 then
              ConstVal := IdentifierAt(IdentIndex).NumAllocElements - 1
            else
              ConstVal := 0;

        end
        else
          ConstVal := HighBound(i, ConstValType);

      ConstValType := GetValueType(ConstVal);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Result := i + 1;
    end;


    TTokenKind.LENGTHTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      ConstVal := 0;

      if TokenAt(i + 2).Kind = TTokenKind.IDENTTOK then
      begin

        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

        if IdentIndex = 0 then
          Error(i + 2, TErrorCode.UnknownIdentifier);

        if IdentifierAt(IdentIndex).Kind in [TTokenKind.VARTOK, TTokenKind.CONSTTOK, TTokenKind.TYPETOK] then
        begin

          if (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) or
            ((IdentifierAt(IdentIndex).DataType in Pointers) and (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
          begin

            if (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) or
              (IdentifierAt(IdentIndex).AllocElementType = TDataType.CHARTOK) then
            begin

              _isError := True;
              exit;

            end
            else
            begin

              //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).NumAllocElements,'/',IdentifierAt(IdentIndex).NumAllocElements_,',',IdentifierAt(IdentIndex).AllocElementType );

              if (IdentifierAt(IdentIndex).DataType = TDataType.POINTERTOK) and
                (IdentifierAt(IdentIndex).AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
                ConstVal := IdentifierAt(IdentIndex).NumAllocElements_
              else
                ConstVal := IdentifierAt(IdentIndex).NumAllocElements;

              ConstValType := GetValueType(ConstVal);
            end;

          end
          else
            Error(i + 2, TErrorCode.TypeMismatch);

        end
        else
          Error(i + 2, TErrorCode.IdentifierExpected);

        Inc(i, 2);
      end
      else
        Error(i + 2, TErrorCode.IdentifierExpected);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      Result := i + 1;
    end;


    TTokenKind.SIZEOFTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      if TokenAt(i + 2).GetDataType in OrdinalTypes + RealTypes + [TDataType.POINTERTOK] then
      begin

        ConstVal := GetDataSize(TokenAt(i + 2).GetDataType);
        ConstValType := TDataType.BYTETOK;

        j := i + 2;

      end
      else
      begin

        if TokenAt(i + 2).Kind <> TTokenKind.IDENTTOK then
          Error(i + 2, TErrorCode.IdentifierExpected);

        j := CompileConstExpression(i + 2, ConstVal, ConstValType);

        if isError then Exit;

        ConstVal := GetSizeof(i, ConstValType);

        ConstValType := GetValueType(ConstVal);

      end;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      Result := j + 1;
    end;


    TTokenKind.LOTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      OldConstValType := TDataType.UNTYPETOK;

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      // TODO: But here OldConstValType=TDataType.UNTYPETOK always?
      if OldConstValType in [TDataType.DATAORIGINOFFSET, TDataType.CODEORIGINOFFSET] then
        Error(i, TMessage.Create(TErrorCode.InvalidVariableAddress, 'Can''t take the address of variable'));

      GetCommonConstType(i, TDataType.INTEGERTOK, ConstValType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      case ConstValType of
        TDataType.INTEGERTOK, TDataType.CARDINALTOK: ConstVal := ConstVal and $0000FFFF;
        TDataType.SMALLINTTOK, TDataType.WORDTOK: ConstVal := ConstVal and $00FF;
        TDataType.SHORTINTTOK, TDataType.BYTETOK: ConstVal := ConstVal and $0F;
      end;

      ConstValType := GetValueType(ConstVal);

      Result := i + 1;
    end;


    TTokenKind.HITOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      OldConstValType := TDataType.UNTYPETOK;

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      if OldConstValType in [TDataType.DATAORIGINOFFSET, TDataType.CODEORIGINOFFSET] then
        Error(i, TMessage.Create(TErrorCode.InvalidVariableAddress, 'Can''t take the address of variable'));

      GetCommonConstType(i, TDataType.INTEGERTOK, ConstValType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      case ConstValType of
        TDataType.INTEGERTOK, TDataType.CARDINALTOK: ConstVal := ConstVal shr 16;
        TDataType.SMALLINTTOK, TDataType.WORDTOK: ConstVal := ConstVal shr 8;
        TDataType.SHORTINTTOK, TDataType.BYTETOK: ConstVal := ConstVal shr 4;
      end;

      ConstValType := GetValueType(ConstVal);
      Result := i + 1;
    end;


    TTokenKind.INTTOK, TTokenKind.FRACTOK:
    begin

      Kind := TokenAt(i).Kind;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      if not (ConstValType in RealTypes) then
        ErrorIncompatibleTypes(i, ConstValType, TDataType.REALTOK);

      CheckTok(i + 1, TTokenKind.CPARTOK);



      case Kind of
        TTokenKind.INTTOK: ConstVal := Trunc(ConstValType, ConstVal);
        TTokenKind.FRACTOK: ConstVal := Frac(ConstValType, ConstVal);
      end;

      //     ConstValType := REALTOK;
      Result := i + 1;
    end;


    TTokenKind.ROUNDTOK, TTokenKind.TRUNCTOK:
    begin

      Kind := TokenAt(i).Kind;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, TDataType.REALTOK, ConstValType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      ConstVal := Integer(ConstVal);

      case Kind of
        TTokenKind.ROUNDTOK: if ConstVal < 0 then
            ConstVal := -(abs(ConstVal) shr 8 + Ord(abs(ConstVal) and $ff > 127))
          else
            ConstVal := ConstVal shr 8 + Ord(abs(ConstVal) and $ff > 127);

        TTokenKind.TRUNCTOK: if ConstVal < 0 then
            ConstVal := -(abs(ConstVal) shr 8)
          else
            ConstVal := ConstVal shr 8;
      end;

      ConstValType := GetValueType(ConstVal);

      Result := i + 1;
    end;


    TTokenKind.ODDTOK:
    begin

      //      Kind := TokenAt(i).Kind;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, TDataType.CARDINALTOK, ConstValType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      ConstVal := Ord(odd(ConstVal));

      ConstValType := TDataType.BOOLEANTOK;

      Result := i + 1;
    end;


    TTokenKind.CHRTOK:
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, TDataType.BYTETOK);

      if isError then Exit;

      GetCommonConstType(i, TDataType.INTEGERTOK, ConstValType);

      CheckTok(i + 1, TTokenKind.CPARTOK);

      ConstValType := TDataType.CHARTOK;
      Result := i + 1;
    end;


    TTokenKind.ORDTOK:
    begin
      CheckTok(i + 1, TTokenKind.OPARTOK);

      j := i + 2;

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, TDataType.BYTETOK);

      if not (ConstValType in OrdinalTypes + [TDataType.ENUMTOK]) then
        Error(i, TErrorCode.OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, TTokenKind.CPARTOK);

      if ConstValType in [TDataType.CHARTOK, TDataType.BOOLEANTOK, TDataType.ENUMTOK] then
        ConstValType := TDataType.BYTETOK;

      Result := i + 1;
    end;


    TTokenKind.PREDTOK, TTokenKind.SUCCTOK:
    begin
      Kind := TokenAt(i).Kind;

      CheckTok(i + 1, TTokenKind.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if not (ConstValType in OrdinalTypes) then
        Error(i, TErrorCode.OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, TTokenKind.CPARTOK);

      if Kind = TTokenKind.PREDTOK then
        Dec(ConstVal)
      else
        Inc(ConstVal);

      if not (ConstValType in [TDataType.CHARTOK, TDataType.BOOLEANTOK]) then
        ConstValType := GetValueType(ConstVal);

      Result := i + 1;
    end;


    TTokenKind.IDENTTOK:
    begin
      IdentIndex := GetIdentIndex(TokenAt(i).Name);

      if IdentIndex > 0 then

        if (IdentifierAt(IdentIndex).Kind = TTokenKind.TYPETOK) and (TokenAt(i + 1).Kind = TTokenKind.OPARTOK) then
        begin

          CheckTok(i + 1, TTokenKind.OPARTOK);

          j := CompileConstExpression(i + 2, ConstVal, ConstValType);

          if isError then Exit;

          if not (ConstValType in AllTypes) then
            Error(i, TErrorCode.TypeMismatch);


          if (IdentifierAt(IdentIndex).DataType in RealTypes) and (ConstValType in RealTypes) then
          begin
            // ok
          end
          else
            if IdentifierAt(IdentIndex).DataType in Pointers then
            begin
              Error(j, TMessage.Create(TErrorCode.IllegalTypeConversion, 'Illegal type conversion: "' +
                InfoAboutDataType(ConstValType) + '" to "' + TokenAt(i).Name + '"'));
            end;

          ConstValType := IdentifierAt(GetIdentIndex(TokenAt(i).Name)).DataType;
          if ConstValType = TDataType.ENUMTOK then ConstValType := IdentifierAt(IdentIndex).AllocElementType;

          CheckTok(j + 1, TTokenKind.CPARTOK);

          i := j + 1;

        end
        else

          if not (IdentifierAt(IdentIndex).Kind in [TTokenKind.CONSTTOK, TTokenKind.TYPETOK, TTokenKind.ENUMTOK]) then
          begin
            ErrorForIdentifier(i, TErrorCode.ConstantExpected, IdentIndex);
          end
          else
            if TokenAt(i + 1).Kind = TTokenKind.OBRACKETTOK then          // Array element access
              if not (IdentifierAt(IdentIndex).DataType in Pointers) then
                ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
              else
              begin

                j := CompileConstExpression(i + 2, ArrayIndex, ArrayIndexType);  // Array index

                if isError then Exit;

                if (ArrayIndex < 0) or (ArrayIndex > IdentifierAt(IdentIndex).NumAllocElements -
                  1 + Ord(IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK)) then
                begin
                  _isConst := False;
                  Error(i, TErrorCode.SubrangeBounds);
                end;

                CheckTok(j + 1, TTokenKind.CBRACKETTOK);

                if TokenAt(j + 2).Kind = TTokenKind.OBRACKETTOK then
                begin
                  _isError := True;
                  exit;
                end;

                //      InfoAboutArray(IdentIndex, true);

                ConstValType := IdentifierAt(IdentIndex).AllocElementType;

                case GetDataSize(ConstValType) of
                  1: ConstVal := GetStaticValue(0 + Ord(IdentifierAt(IdentIndex).idType = TDataType.PCHARTOK));
                  2: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8;
                  4: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8 + GetStaticValue(2) shl
                      16 + GetStaticValue(3) shl 24;
                end;

                if ConstValType in [TDataType.HALFSINGLETOK, TDataType.SINGLETOK] then ConstVal := ConstVal shl 32;

                i := j + 1;
              end
            else

            begin

              ConstValType := IdentifierAt(IdentIndex).DataType;

              if (ConstValType in Pointers) or (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) then
                ConstVal := IdentifierAt(IdentIndex).Value - CODEORIGIN
              else
                ConstVal := IdentifierAt(IdentIndex).Value;

              // Writeln(IdentifierAt(identindex).name,',',ConstValType,',',IdentifierAt(identindex).kind)

              if ConstValType = TDataType.ENUMTOK then
              begin
                CheckTok(i + 1, TTokenKind.OPARTOK);

                j := CompileConstExpression(i + 2, ConstVal, ConstValType);

                if isError then exit;

                CheckTok(j + 1, TTokenKind.CPARTOK);

                ConstValType := TokenAt(i).GetDataType;

                i := j + 1;
              end;

            end
      else
        Error(i, TErrorCode.UnknownIdentifier);

      Result := i;
    end;


    TTokenKind.ADDRESSTOK:
      if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
        Error(i + 1, TErrorCode.IdentifierExpected)
      else
      begin
        IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

        if IdentIndex > 0 then
        begin

          case IdentifierAt(IdentIndex).Kind of
            TTokenKind.CONSTTOK: if not ((IdentifierAt(IdentIndex).DataType in Pointers) and
                (IdentifierAt(IdentIndex).NumAllocElements > 0)) then
                Error(i + 1, TErrorCode.CantAdrConstantExp)
              else
                ConstVal := IdentifierAt(IdentIndex).Value - CODEORIGIN;

            TTokenKind.VARTOK: if IdentifierAt(IdentIndex).isAbsolute then
              begin        // wyjatek gdy ABSOLUTE

                if (abs(IdentifierAt(IdentIndex).Value) and $ff = 0) and
                  (Byte(abs(IdentifierAt(IdentIndex).Value shr 24) and $7f) in [1..127]) or
                  ((IdentifierAt(IdentIndex).DataType in Pointers) and
                  (IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
                  (IdentifierAt(IdentIndex).NumAllocElements in [0..1])) then
                begin

                  _isError := True;
                  exit(0);

                end
                else
                begin
                  ConstVal := IdentifierAt(IdentIndex).Value;

                  if ConstVal < 0 then
                  begin
                    _isError := True;
                    exit(0);
                  end;

                end;

              end
              else
              begin

                if isConst then
                begin
                  _isError := True;
                  exit;
                end;      // !!! koniecznie zamiast Error !!!

                ConstVal := IdentifierAt(IdentIndex).Value - DATAORIGIN;

                ConstValType := TDataType.DATAORIGINOFFSET;

                //  writeln(IdentifierAt(IdentIndex).name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,' / ',ConstVal);

                if (IdentifierAt(IdentIndex).DataType in Pointers) and          // zadziala tylko dla ABSOLUTE
                  (IdentifierAt(IdentIndex).NumAllocElements > 0) and (TokenAt(i + 2).Kind =
                  TTokenKind.OBRACKETTOK) then
                begin
                  j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);      // Array index [xx,

                  if isError then Exit;

                  CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

                  if TokenAt(j + 1).Kind = TTokenKind.COMMATOK then
                  begin
                    Inc(ConstVal, ArrayIndex * GetDataSize(IdentifierAt(IdentIndex).AllocElementType) *
                      IdentifierAt(IdentIndex).NumAllocElements_);

                    j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);    // Array index ,yy]

                    if isError then Exit;

                    CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

                    Inc(ConstVal, ArrayIndex * GetDataSize(IdentifierAt(IdentIndex).AllocElementType));
                  end
                  else
                    Inc(ConstVal, ArrayIndex * GetDataSize(IdentifierAt(IdentIndex).AllocElementType));

                  i := j;

                  CheckTok(i + 1, TTokenKind.CBRACKETTOK);
                end;
                Result := i + 1;

                exit;

              end;
            else

              Error(i + 1, TMessage.Create(TErrorCode.CantTakeAddressOfIdentifier,
                'Can''t take the address of ' + InfoAboutToken(IdentifierAt(IdentIndex).Kind)));

          end;

          if (IdentifierAt(IdentIndex).DataType in Pointers) and          // zadziala tylko dla ABSOLUTE
            (IdentifierAt(IdentIndex).NumAllocElements > 0) and (TokenAt(i + 2).Kind = TTokenKind.OBRACKETTOK) then
          begin
            j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);      // Array index [xx,

            if isError then Exit;

            CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

            if TokenAt(j + 1).Kind = TTokenKind.COMMATOK then
            begin
              Inc(ConstVal, ArrayIndex * GetDataSize(IdentifierAt(IdentIndex).AllocElementType) *
                IdentifierAt(IdentIndex).NumAllocElements_);

              j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);    // Array index ,yy]

              if isError then Exit;

              CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

              Inc(ConstVal, ArrayIndex * GetDataSize(IdentifierAt(IdentIndex).AllocElementType));
            end
            else
              Inc(ConstVal, ArrayIndex * GetDataSize(IdentifierAt(IdentIndex).AllocElementType));

            i := j;

            CheckTok(i + 1, TTokenKind.CBRACKETTOK);
          end;

          ConstValType := TDataType.POINTERTOK;

        end
        else
          Error(i + 1, TErrorCode.UnknownIdentifier);

        Result := i + 1;
      end;


    TTokenKind.INTNUMBERTOK:
    begin
      ConstVal := TokenAt(i).Value;
      ConstValType := GetValueType(ConstVal);

      Result := i;
    end;


    TTokenKind.FRACNUMBERTOK:
    begin
      ConstVal := FromSingle(TokenAt(i).FracValue);
      ConstValType := TDataType.REALTOK;

      Result := i;
    end;


    TTokenKind.STRINGLITERALTOK:
    begin
      ConstVal := TokenAt(i).StrAddress - CODEORIGIN + CODEORIGIN_BASE;
      ConstValType := TDataType.STRINGPOINTERTOK;

      Result := i;
    end;


    TTokenKind.CHARLITERALTOK:
    begin
      ConstVal := TokenAt(i).Value;
      ConstValType := TDataType.CHARTOK;

      Result := i;
    end;


    TTokenKind.OPARTOK:       // a whole expression in parentheses suspected
    begin
      j := CompileConstExpression(i + 1, ConstVal, ConstValType);

      if isError then Exit;

      CheckTok(j + 1, TTokenKind.CPARTOK);

      Result := j + 1;
    end;


    TTokenKind.NOTTOK:
    begin
      Result := CompileConstFactor(i + 1, ConstVal, ConstValType);

      if isError then Exit;

      if ConstValType = TDataType.BOOLEANTOK then
        ConstVal := Ord(not (ConstVal <> 0))

      else
      begin
        ConstVal := not ConstVal;
        ConstValType := GetValueType(ConstVal);
      end;

    end;


    TTokenKind.SHORTREALTOK, TTokenKind.REALTOK, TTokenKind.SINGLETOK, TTokenKind.HALFSINGLETOK:
      // Q8.8 ; Q24.8 ; SINGLE 32bit ; FLOAT16
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);

      j := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then exit;

      if not (ConstValType in RealTypes) then ConstVal := FromInt64(ConstVal);

      CheckTok(j + 1, TTokenKind.CPARTOK);

      ConstValType := TokenAt(i).GetDataType;

      Result := j + 1;

    end;


    TTokenKind.INTEGERTOK, TTokenKind.CARDINALTOK, TTokenKind.SMALLINTTOK, TTokenKind.WORDTOK,
    TTokenKind.CHARTOK, TTokenKind.PCHARTOK, TTokenKind.SHORTINTTOK, TTokenKind.BYTETOK,
    TTokenKind.BOOLEANTOK, TTokenKind.POINTERTOK, TTokenKind.STRINGPOINTERTOK:  // type conversion operations
    begin

      CheckTok(i + 1, TTokenKind.OPARTOK);


      if (TokenAt(i + 2).Kind = TTokenKind.IDENTTOK) and (IdentifierAt(GetIdentIndex(TokenAt(i + 2).Name)).Kind =
        TTokenKind.FUNCTIONTOK) then
        _isError := True
      else
        j := CompileConstExpression(i + 2, ConstVal, ConstValType);


      if isError then exit;


      if (ConstValType in Pointers) and (TokenAt(i + 2).Kind = TTokenKind.IDENTTOK) and
        (TokenAt(i + 3).Kind <> TTokenKind.OBRACKETTOK) then
      begin

        IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

        if (IdentifierAt(IdentIndex).DataType in Pointers) and
          ((IdentifierAt(IdentIndex).NumAllocElements > 0) and
          (IdentifierAt(IdentIndex).AllocElementType <> TDataType.RECORDTOK)) then
          if ((IdentifierAt(IdentIndex).AllocElementType <> TDataType.UNTYPETOK) and
            (IdentifierAt(IdentIndex).NumAllocElements in [0, 1])) or
            (IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK) then
          begin

          end
          else
            ErrorIdentifierIllegalTypeConversion(i + 2, IdentIndex, TokenAt(i).GetDataType);

      end;


      CheckTok(j + 1, TTokenKind.CPARTOK);

      if ConstValType in [TDataType.DATAORIGINOFFSET, TDataType.CODEORIGINOFFSET] then
        OldConstValType := ConstValType;

      ConstValType := TokenAt(i).GetDataType;

      Result := j + 1;
    end;


    else
      Error(i, TErrorCode.IdNumExpExpected);

  end;// case

end;  //CompileConstFactor


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstTerm(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDataType): TTokenIndex;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: TDataType;
begin

  ConstVal := 0;
  ConstValType := TDataType.UNTILTOK;
  Result := i;

  j := CompileConstFactor(i, ConstVal, ConstValType);

  if isError then Exit;

  while TokenAt(j + 1).Kind in [TTokenKind.MULTOK, TTokenKind.DIVTOK, TTokenKind.MODTOK,
      TTokenKind.IDIVTOK, TTokenKind.SHLTOK, TTokenKind.SHRTOK, TTokenKind.ANDTOK] do
  begin

    k := CompileConstFactor(j + 2, RightConstVal, RightConstValType);

    if isError then Break;


    if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then
    begin
      RightConstVal := FromInt64(RightConstVal);
      RightConstValType := ConstValType;
    end;

    if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ConstValType := RightConstValType;
    end;


    if (TokenAt(j + 1).Kind = TTokenKind.DIVTOK) and (ConstValType in IntegerTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ConstValType := TDataType.REALTOK;
    end;

    if (TokenAt(j + 1).Kind = TTokenKind.DIVTOK) and (RightConstValType in IntegerTypes) then
    begin
      RightConstVal := FromInt64(RightConstVal);
      RightConstValType := TDataType.REALTOK;
    end;


    if (ConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
      (RightConstValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then
      RightConstValType := ConstValType;

    if (RightConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
      (ConstValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then
      ConstValType := RightConstValType;


    case TokenAt(j + 1).Kind of

      TTokenKind.MULTOK: ConstVal := Multiply(ConstValType, ConstVal, RightConstVal);

      TTokenKind.DIVTOK: begin
        try
          ConstVal := Divide(ConstValType, ConstVal, RightConstVal);
        except
          On EDivByZero do
          begin
            _isError := False;
            _isConst := False;
            Error(i, TMessage.Create(TErrorCode.DivisionByZero, 'Division by zero'));
          end;
        end;
      end;

      TTokenKind.MODTOK: ConstVal := ConstVal mod RightConstVal;
      TTokenKind.IDIVTOK: ConstVal := ConstVal div RightConstVal;
      TTokenKind.SHLTOK: ConstVal := ConstVal shl RightConstVal;
      TTokenKind.SHRTOK: ConstVal := ConstVal shr RightConstVal;
      TTokenKind.ANDTOK: ConstVal := ConstVal and RightConstVal;
    end;

    ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

    if not (ConstValType in RealTypes + [TDataType.BOOLEANTOK]) then
      ConstValType := GetValueType(ConstVal);

    CheckOperator(i, TokenAt(j + 1).Kind, ConstValType, RightConstValType);

    j := k;
  end;

  Result := j;
end;  //CompileConstTerm


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileSimpleConstExpression(const i: Integer; out ConstVal: Int64; out ConstValType: TDataType): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: TDataType;
begin

  ConstVal := 0;
  ConstValType := TDataType.UNTYPETOK;
  Result := i;

  if TokenAt(i).Kind in [TTokenKind.PLUSTOK, TTokenKind.MINUSTOK] then j := i + 1
  else
    j := i;
  j := CompileConstTerm(j, ConstVal, ConstValType);

  if isError then exit;


  if TokenAt(i).Kind = TTokenKind.MINUSTOK then
  begin

    ConstVal := Negate(ConstValType, ConstVal);

  end;


  while TokenAt(j + 1).Kind in [TTokenKind.PLUSTOK, TTokenKind.MINUSTOK, TTokenKind.ORTOK, TTokenKind.XORTOK] do
  begin

    k := CompileConstTerm(j + 2, RightConstVal, RightConstValType);

    if isError then Break;


    //  if (ConstValType = POINTERTOK) and (RightConstValType in IntegerTypes) then RightConstValType := ConstValType;


    if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then
    begin
      RightConstVal := FromInt64(RightConstVal);
      RightConstValType := ConstValType;
    end;

    if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then
    begin
      ConstVal := FromInt64(ConstVal);
      ConstValType := RightConstValType;
    end;

    if (ConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
      (RightConstValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then
      RightConstValType := ConstValType;

    if (RightConstValType in [TDataType.SINGLETOK, TDataType.HALFSINGLETOK]) and
      (ConstValType in [TDataType.SHORTREALTOK, TDataType.REALTOK]) then
      ConstValType := RightConstValType;


    case TokenAt(j + 1).Kind of
      TTokenKind.PLUSTOK: ConstVal := Add(ConstValType, ConstVal, RightConstVal);
      TTokenKind.MINUSTOK: ConstVal := Subtract(ConstValType, ConstVal, RightConstVal);
      TTokenKind.ORTOK: ConstVal := ConstVal or RightConstVal;
      TTokenKind.XORTOK: ConstVal := ConstVal xor RightConstVal;
    end;

    ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

    if not (ConstValType in RealTypes + [TDataType.BOOLEANTOK]) then
      ConstValType := GetValueType(ConstVal);

    CheckOperator(i, TokenAt(j + 1).Kind, ConstValType, RightConstValType);

    j := k;
  end;

  Result := j;
end;  //CompileSimpleConstExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstExpression(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDataType;
  const VarType: TDataType = TDataType.INTEGERTOK; const Err: Boolean = False; const War: Boolean = True): TTokenIndex;
var
  j: Integer;
  RightConstVal: Int64;
  RightConstValType: TDataType;
  Yes: Boolean;
begin

  ConstVal := 0;
  ConstValType := TDataType.UNTYPETOK;
  Result := i;

  i := CompileSimpleConstExpression(i, ConstVal, ConstValType);

  if isError then exit;

  if TokenAt(i + 1).Kind in [TTokenKind.EQTOK, TTokenKind.NETOK, TTokenKind.LTTOK, TTokenKind.LETOK,
    TTokenKind.GTTOK, TTokenKind.GETOK] then
  begin

    j := CompileSimpleConstExpression(i + 2, RightConstVal, RightConstValType);
    //  CheckOperator(i, TokenAt(j + 1].Kind, ConstValType);

    case TokenAt(i + 1).Kind of
      TTokenKind.EQTOK: Yes := ConstVal = RightConstVal;
      TTokenKind.NETOK: Yes := ConstVal <> RightConstVal;
      TTokenKind.LTTOK: Yes := ConstVal < RightConstVal;
      TTokenKind.LETOK: Yes := ConstVal <= RightConstVal;
      TTokenKind.GTTOK: Yes := ConstVal > RightConstVal;
      TTokenKind.GETOK: Yes := ConstVal >= RightConstVal;
      else
        yes := False;
    end;

    if Yes then ConstVal := $ff
    else
      ConstVal := 0;
    //  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

    ConstValType := TDataType.BOOLEANTOK;

    i := j;
  end;


  Result := i;

  if ConstValType in OrdinalTypes + Pointers then
    if VarType in OrdinalTypes + Pointers then
    begin

      case VarType of
        TDataType.SHORTINTTOK: Yes := (ConstVal < Low(Shortint)) or (ConstVal > High(Shortint));
        TDataType.SMALLINTTOK: Yes := (ConstVal < Low(Smallint)) or (ConstVal > High(Smallint));
        TDataType.INTEGERTOK: Yes := (ConstVal < Low(Integer)) or (ConstVal > High(Integer));
        else
          Yes := (abs(ConstVal) > $FFFFFFFF) or (GetDataSize(ConstValType) > GetDataSize(VarType)) or
            ((ConstValType in SignedOrdinalTypes) and (VarType in UnsignedOrdinalTypes));
      end;

      if Yes then
        if Err then
        begin
          _isConst := False;
          _isError := False;
          ErrorRangeCheckError(i, ConstVal, VarType);
        end
        else
          if War then
            if VarType <> TDataType.BOOLEANTOK then
              WarningForRangeCheckError(i, ConstVal, VarType);

    end;

end;  //CompileConstExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure DefineIdent(const tokenIndex: TTokenIndex; Name: TIdentifierName; Kind: TTokenKind;
  DataType: TDataType; NumAllocElements: TNumAllocElements; AllocElementType: TDataType;
  Data: Int64; IdType: TDataType = TDataType.IDENTTOK);
var
  identIndex: Integer;
  identifier: TIdentifier;
  NumAllocElements_: Cardinal;
begin

  Debugger.debugger.DefineIdent(tokenIndex, Name, Kind, DataType, NumAllocElements, AllocElementType, Data, IdType);

  identIndex := GetIdentIndex(Name);

  if (identIndex > 0) and (not (IdentifierAt(IdentIndex).Kind in [TTokenKind.PROCEDURETOK,
    TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK])) and
    (IdentifierAt(IdentIndex).Block = BlockStack[BlockStackTop]) and
    (IdentifierAt(IdentIndex).isOverload = False) and (IdentifierAt(identIndex).SourceFile.UnitIndex =
    ActiveSourceFile.UnitIndex) then
    Error(tokenIndex, TMessage.Create(TErrorCode.IdentifierAlreadyDefined, 'Identifier {0} is already defined', Name))
  else
  begin

    Inc(NumIdent_);
    identifier := IdentifierList.GetIdentifierAtIndex(NumIdent);

    // For debugging
    (*
    if Name = 'TABLEFULL' then
    begin
      Writeln('NumIdent=' + IntToStr(NumIdent) + ' tokenIndex=' + IntToStr(tokenIndex) +
        ' Name=' + Name + ' Kind=' + GetTokenKindName(Kind) + ' DataType=' + IntToStr(Ord(DataType)) +
        ' NumAllocElements=' + IntToStr(NumAllocElements) + ' AllocElementType=' + IntToStr(Ord(AllocElementType)));
    end;
    *)
    if NumIdent > MAXIDENTS then
    begin
      Error(NumTok, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, IDENT'));
    end;

    identifier.Name := Name;
    identifier.Kind := Kind;
    identifier.DataType := DataType;
    identifier.Block := BlockStack[BlockStackTop];
    identifier.NumParams := 0;
    identifier.isAbsolute := False;
    identifier.PassMethod := TParameterPassingMethod.VALPASSING;
    identifier.IsUnresolvedForward := False;

    identifier.IsSection := PublicSection;

    identifier.SourceFile := ActiveSourceFile;

    identifier.IdType := IdType;

    if (Kind = TTokenKind.VARTOK) and (Data <> 0) then
    begin
      identifier.isAbsolute := True;
      identifier.isInit := True;
    end;

    NumAllocElements_ := NumAllocElements shr 16;    // , yy]
    NumAllocElements := NumAllocElements and $FFFF;    // [xx,


    //   if name = 'CH_EOL' then writeln( identifier.Block ,',', identifier.unitindex, ',',  identifier.Section,',', identifier.idType);

    if Name <> 'RESULT' then
      if (NumIdent > NumPredefIdent + 1) and (ActiveSourceFile.UnitIndex = 1) and (pass = TPass.CODE_GENERATION) then
        if not ((identifier.Pass in [TPass.CALL_DETERMINATION, TPass.CODE_GENERATION]) or
          (identifier.IsNotDead)) then
          NoteForIdentifierNotUsed(tokenIndex, NumIdent);

    case Kind of

      TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.UNITTOK, TTokenKind.CONSTRUCTORTOK,
      TTokenKind.DESTRUCTORTOK:
      begin
        identifier.Value := CodeSize;      // Procedure entry point address
        //      identifier.Section := true;
      end;

      TTokenKind.VARTOK:
      begin

        if identifier.isAbsolute then
        begin
          identifier.Value := Data - 1;
        end
        else
        begin
          identifier.Value := DATAORIGIN + _VarDataSize;  // Variable address
        end;

        if not OutputDisabled then
        begin
          IncVarDataSize(tokenIndex, GetDataSize(DataType));
        end;

        identifier.NumAllocElements := NumAllocElements;  // Number of array elements (0 for single variable)
        identifier.NumAllocElements_ := NumAllocElements_;

        identifier.AllocElementType := AllocElementType;

        if not OutputDisabled then
        begin

          if (DataType = TDataType.POINTERTOK) and (AllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and
            (NumAllocElements_ = 0) then
            IncVarDataSize(tokenIndex, GetDataSize(TDataType.POINTERTOK))
          else

            if DataType in [TDataType.ENUMTOK] then
              IncVarDataSize(tokenIndex, 1)
            else
              if (DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) and (NumAllocElements > 0) then
                IncVarDataSize(tokenIndex, 0)
              else
                if (DataType in [TDataType.FILETOK, TDataType.TEXTFILETOK]) and (NumAllocElements > 0) then
                  IncVarDataSize(tokenIndex, 12)
                else
                begin

                  if (identifier.idType = TDataType.ARRAYTOK) and (identifier.isAbsolute = False) and
                    (Elements(NumIdent) = 1) then
                  begin
                    // Empty array [0..0] ; [0..0, 0..0] foes not require spaces
                  end
                  else
                    IncVarDataSize(tokenIndex, Integer(Elements(NumIdent) * GetDataSize(AllocElementType)));

                end;


          if NumAllocElements > 0 then IncVarDataSize(tokenIndex, -GetDataSize(DataType));

        end;

      end;

      TTokenKind.CONSTTOK, TTokenKind.ENUMTOK:
      begin
        identifier.Value := Data;        // Constant value

        if DataType in Pointers + [TDataType.ENUMTOK] then
        begin
          identifier.NumAllocElements := NumAllocElements;
          identifier.NumAllocElements_ := NumAllocElements_;

          identifier.AllocElementType := AllocElementType;
        end;

        identifier.isInit := True;
      end;

      TTokenKind.TYPETOK:
      begin
        identifier.NumAllocElements := NumAllocElements;
        identifier.NumAllocElements_ := NumAllocElements_;

        identifier.AllocElementType := AllocElementType;
      end;

      TTokenKind.LABELTOK:
      begin
        identifier.isInit := False;
      end;

    end;// case
  end;// else

end;  //DefineIdent


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function DeclareFunction(i: Integer; out ProcVarIndex: Cardinal): Integer;
var
  VarOfSameType: TVariableList;
  ListPassMethod: TParameterPassingMethod;
  NumVarOfSameType, VarOfSameTypeIndex, x: Integer;
  VarType, AllocElementType: TDataType;
  NumAllocElements: Cardinal;
  IsNestedFunction: Boolean;
  //     ConstVal: Int64;
begin

  //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
  VarOfSameType := Default(TVariableList);

  Inc(NumProc);

  if TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
  begin
    DefineIdent(i, '@FN' + IntToHex(NumProc, 4), TokenAt(i).Kind, TDataType.UNTYPETOK, 0, TDataType.UNTYPETOK, 0);
    IsNestedFunction := False;
  end
  else
  begin
    DefineIdent(i, '@FN' + IntToHex(NumProc, 4), TTokenKind.FUNCTIONTOK, TDataType.UNTYPETOK,
      0, TDataType.UNTYPETOK, 0);
    IsNestedFunction := True;
  end;

  NumVarOfSameType := 0;
  ProcVarIndex := NumProc;      // -> NumAllocElements_

  Dec(i);

  if (TokenAt(i + 2).Kind = TTokenKind.OPARTOK) and (TokenAt(i + 3).Kind = TTokenKind.CPARTOK) then Inc(i, 2);

  if TokenAt(i + 2).Kind = TTokenKind.OPARTOK then            // Formal parameter list found
  begin
    i := i + 2;
    repeat
      NumVarOfSameType := 0;

      ListPassMethod := TParameterPassingMethod.VALPASSING;

      if TokenAt(i + 1).Kind = TTokenKind.CONSTTOK then
      begin
        ListPassMethod := TParameterPassingMethod.CONSTPASSING;
        Inc(i);
      end
      else if TokenAt(i + 1).Kind = TTokenKind.VARTOK then
        begin
          ListPassMethod := TParameterPassingMethod.VARPASSING;
          Inc(i);
        end;

      repeat

        if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
          Error(i + 1, TMessage.Create(TErrorCode.FormalParameterNameExpected,
            'Formal parameter name expected but {0} found.', tokenList.GetTokenSpellingAtIndex(i + 1)))
        else
        begin

          for x := 1 to NumVarOfSameType do
            if VarOfSameType[x].Name = TokenAt(i + 1).Name then
              Error(i + 1, TMessage.Create(TErrorCode.IdentifierAlreadyDefined,
                'Identifier {0} is already defined.', TokenAt(i + 1).Name));

          Inc(NumVarOfSameType);
          VarOfSameType[NumVarOfSameType].Name := TokenAt(i + 1).Name;
        end;

        i := i + 2;
      until TokenAt(i).Kind <> TTokenKind.COMMATOK;


      VarType := TDataType.UNTYPETOK;
      NumAllocElements := 0;
      AllocElementType := TDataType.UNTYPETOK;

      if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING]) and
        (TokenAt(i).Kind <> TTokenKind.COLONTOK) then
      begin

        ListPassMethod := TParameterPassingMethod.VARPASSING;
        Dec(i);

      end
      else
      begin

        CheckTok(i, TTokenKind.COLONTOK);

        if TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK then        // ^type
          Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

        i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

        if (VarType = TDataType.FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
          Error(i, TMessage.Create(TErrorCode.FileParameterMustBeVAR, 'File parameters must be var parameters'));

      end;


      for VarOfSameTypeIndex := 1 to NumVarOfSameType do
      begin

        //      if NumAllocElements > 0 then
        //        Error(i, 'Structured parameters cannot be passed by value');

        Inc(IdentifierAt(NumIdent).NumParams);
        if IdentifierAt(NumIdent).NumParams > MAXPARAMS then
          ErrorForIdentifier(i, TErrorCode.TooManyParameters, NumIdent)
        else
        begin
          VarOfSameType[VarOfSameTypeIndex].DataType := VarType;

          IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].DataType := VarType;
          IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].Name :=
            VarOfSameType[VarOfSameTypeIndex].Name;
          IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].NumAllocElements := NumAllocElements;
          IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].AllocElementType := AllocElementType;
          IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].PassMethod := ListPassMethod;

        end;
      end;

      i := i + 1;
    until TokenAt(i).Kind <> TTokenKind.SEMICOLONTOK;

    CheckTok(i, TTokenKind.CPARTOK);

    i := i + 1;
  end// if TokenAt(i + 2).Kind = OPARTOR
  else
    i := i + 2;

  if IsNestedFunction then
  begin

    CheckTok(i, TTokenKind.COLONTOK);

    if TokenAt(i + 1).Kind = TTokenKind.ARRAYTOK then
      Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

    i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

    IdentifierAt(NumIdent).DataType := VarType;          // Result

    IdentifierAt(NumIdent).NestedFunctionNumAllocElements := NumAllocElements;
    IdentifierAt(NumIdent).NestedFunctionAllocElementType := AllocElementType;

    i := i + 1;
  end;// if IsNestedFunction


  IdentifierAt(NumIdent).isStdCall := True;
  IdentifierAt(NumIdent).IsNestedFunction := IsNestedFunction;

  Result := i;

end;  //DeclareFunction


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function DefineFunction(i: TTokenIndex; ForwardIdentIndex: TIdentIndex; out isForward, isInt, isInl, isOvr: Boolean;
  var IsNestedFunction: Boolean; out NestedFunctionResultType: TDataType;
  out NestedFunctionNumAllocElements: Cardinal; out NestedFunctionAllocElementType: TDataType): Integer;
var
  VarOfSameType: TVariableList;
  NumVarOfSameType, VarOfSameTypeIndex, x: Integer;
  ListPassMethod: TParameterPassingMethod;
  VarType, AllocElementType: TDataType;
  NumAllocElements: Cardinal;
begin

  //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
  VarOfSameType := Default(TVariableList);

  if ForwardIdentIndex = 0 then
  begin

    if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
      Error(i + 1, TMessage.Create(TErrorCode.ReservedWordUserAsIdentifier, 'Reserved word used as identifier'));

    if TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
    begin
      DefineIdent(i + 1, TokenAt(i + 1).Name, TokenAt(i).Kind, TDataType.UNTYPETOK, 0, TDataType.UNTYPETOK, 0);
      IsNestedFunction := False;
    end
    else
    begin
      DefineIdent(i + 1, TokenAt(i + 1).Name, TTokenKind.FUNCTIONTOK, TDataType.UNTYPETOK, 0, TDataType.UNTYPETOK, 0);
      IsNestedFunction := True;
    end;


    NumVarOfSameType := 0;

    if (TokenAt(i + 2).Kind = TTokenKind.OPARTOK) and (TokenAt(i + 3).Kind = TTokenKind.CPARTOK) then Inc(i, 2);

    if TokenAt(i + 2).Kind = TTokenKind.OPARTOK then            // Formal parameter list found
    begin
      i := i + 2;
      repeat
        NumVarOfSameType := 0;

        ListPassMethod := TParameterPassingMethod.VALPASSING;

        if TokenAt(i + 1).Kind = TTokenKind.CONSTTOK then
        begin
          ListPassMethod := TParameterPassingMethod.CONSTPASSING;
          Inc(i);
        end
        else if TokenAt(i + 1).Kind = TTokenKind.VARTOK then
          begin
            ListPassMethod := TParameterPassingMethod.VARPASSING;
            Inc(i);
          end;

        repeat

          if TokenAt(i + 1).Kind <> TTokenKind.IDENTTOK then
            Error(i + 1, TMessage.Create(TErrorCode.FormalParameterNameExpected,
              'Formal parameter name expected but {0} found.', tokenList.GetTokenSpellingAtIndex(i + 1)))
          else
          begin

            for x := 1 to NumVarOfSameType do
              if VarOfSameType[x].Name = TokenAt(i + 1).Name then
                Error(i + 1, TMessage.Create(TErrorCode.IdentifierAlreadyDefined,
                  'Identifier {0} is already defined.', TokenAt(i + 1).Name));

            Inc(NumVarOfSameType);
            VarOfSameType[NumVarOfSameType].Name := TokenAt(i + 1).Name;
          end;

          i := i + 2;
        until TokenAt(i).Kind <> TTokenKind.COMMATOK;


        VarType := TDataType.UNTYPETOK;
        NumAllocElements := 0;
        AllocElementType := TDataType.UNTYPETOK;

        if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING]) and
          (TokenAt(i).Kind <> TTokenKind.COLONTOK) then
        begin

          ListPassMethod := TParameterPassingMethod.VARPASSING;
          Dec(i);

        end
        else
        begin

          CheckTok(i, TTokenKind.COLONTOK);

          if TokenAt(i + 1).Kind = TTokenKind.DEREFERENCETOK then        // ^type
            Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

          i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

          if (VarType = TDataType.FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
            Error(i, TMessage.Create(TErrorCode.FileParameterMustBeVar, 'File parameters must be var parameters'));

        end;


        for VarOfSameTypeIndex := 1 to NumVarOfSameType do
        begin

          //      if NumAllocElements > 0 then
          //        Error(i, 'Structured parameters cannot be passed by value');

          Inc(IdentifierAt(NumIdent).NumParams);
          if IdentifierAt(NumIdent).NumParams > MAXPARAMS then
            ErrorForIdentifier(i, TErrorCode.TooManyParameters, NumIdent)
          else
          begin
            VarOfSameType[VarOfSameTypeIndex].DataType := VarType;

            IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].DataType := VarType;
            IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].Name :=
              VarOfSameType[VarOfSameTypeIndex].Name;
            IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].NumAllocElements := NumAllocElements;
            IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].AllocElementType := AllocElementType;
            IdentifierAt(NumIdent).Param[IdentifierAt(NumIdent).NumParams].PassMethod := ListPassMethod;

          end;
        end;

        i := i + 1;
      until TokenAt(i).Kind <> TTokenKind.SEMICOLONTOK;

      CheckTok(i, TTokenKind.CPARTOK);

      i := i + 1;
    end// if TokenAt(i + 2).Kind = TTokenKind.OPARTOR
    else
      i := i + 2;

    NestedFunctionResultType := TDataType.UNTYPETOK;
    NestedFunctionNumAllocElements := 0;
    NestedFunctionAllocElementType := TDataType.UNTYPETOK;

    if IsNestedFunction then
    begin

      CheckTok(i, TTokenKind.COLONTOK);

      if TokenAt(i + 1).Kind = TTokenKind.ARRAYTOK then
        Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

      i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

      NestedFunctionResultType := VarType;

      //  if TokenAt(i).Kind = PCHARTOK then NestedFunctionResultType := PCHARTOK;

      IdentifierAt(NumIdent).DataType := NestedFunctionResultType;      // Result

      NestedFunctionNumAllocElements := NumAllocElements;
      IdentifierAt(NumIdent).NestedFunctionNumAllocElements := NumAllocElements;

      NestedFunctionAllocElementType := AllocElementType;
      IdentifierAt(NumIdent).NestedFunctionAllocElementType := AllocElementType;

      IdentifierAt(NumIdent).isNestedFunction := True;

      i := i + 1;
    end;// if IsNestedFunction

    CheckTok(i, TTokenKind.SEMICOLONTOK);

  end; //if ForwardIdentIndex = 0


  isForward := False;
  isInt := False;
  isInl := False;
  isOvr := False;

  while TokenAt(i + 1).Kind in [TTokenKind.OVERLOADTOK, TTokenKind.ASSEMBLERTOK, TTokenKind.FORWARDTOK,
      TTokenKind.REGISTERTOK, TTokenKind.INTERRUPTTOK, TTokenKind.PASCALTOK, TTokenKind.STDCALLTOK,
      TTokenKind.INLINETOK, TTokenKind.EXTERNALTOK, TTokenKind.KEEPTOK] do
  begin

    case TokenAt(i + 1).Kind of

      TTokenKind.OVERLOADTOK: begin
        isOvr := True;
        IdentifierAt(NumIdent).isOverload := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.ASSEMBLERTOK: begin
        IdentifierAt(NumIdent).isAsm := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.FORWARDTOK: begin

        if INTERFACETOK_USE then
          if IsNestedFunction then
            Error(i, TMessage.Create(TErrorCode.FunctionDirectiveForwardNotAllowedInInterfaceSection,
              'Function directive ''FORWARD'' not allowed in interface section'))
          else
            Error(i, TMessage.Create(TErrorCode.ProcedureDirectiveForwardNotAllowedInInterfaceSection,
              'Procedure directive ''FORWARD'' not allowed in interface section'));

        isForward := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.REGISTERTOK: begin
        IdentifierAt(NumIdent).isRegister := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.STDCALLTOK: begin
        IdentifierAt(NumIdent).isStdCall := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.INLINETOK: begin
        isInl := True;
        IdentifierAt(NumIdent).isInline := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.INTERRUPTTOK: begin
        isInt := True;
        IdentifierAt(NumIdent).isInterrupt := True;
        IdentifierAt(NumIdent).IsNotDead := True;    // Always generate code for interrupt
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.PASCALTOK: begin
        IdentifierAt(NumIdent).isRecursion := True;
        IdentifierAt(NumIdent).isPascal := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.EXTERNALTOK: begin
        IdentifierAt(NumIdent).isExternal := True;
        isForward := True;
        Inc(i);

        IdentifierAt(NumIdent).Alias := '';
        IdentifierAt(NumIdent).Libraries := 0;

        if TokenAt(i + 1).Kind = TTokenKind.IDENTTOK then
        begin

          IdentifierAt(NumIdent).Alias := TokenAt(i + 1).Name;

          if TokenAt(i + 2).Kind = TTokenKind.STRINGLITERALTOK then
          begin
            IdentifierAt(NumIdent).Libraries := i + 2;

            Inc(i);
          end;

          Inc(i);

        end
        else
          if TokenAt(i + 1).Kind = TTokenKind.STRINGLITERALTOK then
          begin

            IdentifierAt(NumIdent).Alias := IdentifierAt(NumIdent).Name;
            IdentifierAt(NumIdent).Libraries := i + 1;

            Inc(i);
          end;

        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

      TTokenKind.KEEPTOK: begin
        IdentifierAt(NumIdent).isKeep := True;
        IdentifierAt(NumIdent).IsNotDead := True;
        Inc(i);
        CheckTok(i + 1, TTokenKind.SEMICOLONTOK);
      end;

    end;

    Inc(i);
  end;// while


  if IdentifierAt(NumIdent).isRegister and (IdentifierAt(NumIdent).isPascal or IdentifierAt(NumIdent).isRecursion) then
    Error(i, TMessage.Create(TErrorCode.CannotCombineRegisterWithPascal,
      'Calling convention directive "REGISTER" not applicable with "PASCAL"'));

  if IdentifierAt(NumIdent).isInline and (IdentifierAt(NumIdent).isPascal or IdentifierAt(NumIdent).isRecursion) then
    Error(i, TMessage.Create(TErrorCode.CannotCombineInlineWithPascal,
      'Calling convention directive "INLINE" not applicable with "PASCAL"'));

  if IdentifierAt(NumIdent).isInline and (IdentifierAt(NumIdent).isInterrupt) then
    Error(i, TMessage.Create(TErrorCode.CannotCombineInlineWithInterrupt,
      'Procedure directive "INLINE" cannot be used with "INTERRUPT"'));

  if IdentifierAt(NumIdent).isInline and (IdentifierAt(NumIdent).isExternal) then
    Error(i, TMessage.Create(TErrorCode.CannotCombineInlineWithExternal,
      'Procedure directive "INLINE" cannot be used with "EXTERNAL"'));

  //  if IdentifierAt(NumIdent).isInterrupt and (IdentifierAt(NumIdent).isAsm = false) then
  //    Note(i, 'Use assembler block instead pascal');

  Result := i;

end;  //DefineFunction


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileType(i: TTokenIndex; out DataType: TDataType; out NumAllocElements: Cardinal;
  out AllocElementType: TDataType): TTokenIndex;
var
  NestedNumAllocElements, NestedFunctionNumAllocElements: Cardinal;
  LowerBound, UpperBound, ConstVal, IdentIndex: Int64;
  NumFieldsInList, FieldInListIndex, RecType, k, j: Integer;
  NestedDataType, ExpressionType, NestedAllocElementType, NestedFunctionAllocElementType,
  NestedFunctionResultType: TDataType;
  FieldInListName: array [1..MAXFIELDS] of TField;
  ExitLoop, isForward, IsNestedFunction, isInt, isInl, isOvr: Boolean;
  Name: TString;


  function BoundaryType: TDataType;
  begin

    if (LowerBound < 0) or (UpperBound < 0) then
    begin

      if (LowerBound >= Low(Shortint)) and (UpperBound <= High(Shortint)) then Result := TDataType.SHORTINTTOK
      else
        if (LowerBound >= Low(Smallint)) and (UpperBound <= High(Smallint)) then Result := TDataType.SMALLINTTOK
        else
          Result := TDataType.INTEGERTOK;

    end
    else
    begin

      if (LowerBound >= Low(Byte)) and (UpperBound <= High(Byte)) then Result := TDataType.BYTETOK
      else
        if (LowerBound >= Low(Word)) and (UpperBound <= High(Word)) then Result := TDataType.WORDTOK
        else
          Result := TDataType.CARDINALTOK;

    end;

  end;


  procedure DeclareField(const Name: TName; FieldType: TDataType; NumAllocElements: Cardinal = 0;
    AllocElementType: TDataType = TDataType.UNTYPETOK; Data: Int64 = 0);
  var
    x: Integer;
  begin

    for x := 1 to GetTypeAtIndex(RecType).NumFields do
      if GetTypeAtIndex(RecType).Field[x].Name = Name then
        Error(i, TMessage.Create(TErrorCode.DuplicateIdentifier, 'Duplicate identifier ''{0}''.', Name));

    // Add new field
    Inc(_TypeArray[RecType].NumFields);

    x := GetTypeAtIndex(RecType).NumFields;

    if x >= MAXFIELDS then
      Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXFIELDS'));


    if FieldType = TDataType.DEREFERENCEARRAYTOK then
    begin
      FieldType := TDataType.POINTERTOK;
      AllocElementType := TDataType.UNTYPETOK;
      NumAllocElements := 0;
    end;


    // Add new field
    _TypeArray[RecType].Field[x].Name := Name;
    _TypeArray[RecType].Field[x].DataType := FieldType;
    _TypeArray[RecType].Field[x].Value := Data;
    _TypeArray[RecType].Field[x].AllocElementType := AllocElementType;
    _TypeArray[RecType].Field[x].NumAllocElements := NumAllocElements;


    //   writeln('>> ',Name,',',FieldType,',',AllocElementType,',',NumAllocElements);


    if FieldType = TDataType.ENUMTOK then FieldType := AllocElementType;


    if not (FieldType in [TDataType.RECORDTOK, TDataType.OBJECTTOK]) then
    begin

      if FieldType in Pointers then
      begin

        if AllocElementType = TDataType.RECORDTOK then
        begin
          AllocElementType := TDataType.POINTERTOK;
          NumAllocElements := NumAllocElements shr 16;
        end;

        if (FieldType = TDataType.POINTERTOK) and (AllocElementType = TDataType.FORWARDTYPE) then
          Inc(_TypeArray[RecType].Size, GetDataSize(TDataType.POINTERTOK))
        else
          if NumAllocElements shr 16 > 0 then
            Inc(_TypeArray[RecType].Size, (NumAllocElements shr 16) * (NumAllocElements and $FFFF) *
              GetDataSize(AllocElementType))
          else
            Inc(_TypeArray[RecType].Size, NumAllocElements * GetDataSize(AllocElementType));

      end
      else
        Inc(_TypeArray[RecType].Size, GetDataSize(FieldType));

    end
    else
      Inc(_TypeArray[RecType].Size, GetDataSize(FieldType));

    if pos('.', GetTypeAtIndex(RecType).Field[x].Name) > 0 then
      _TypeArray[RecType].Field[x].ObjectVariable := GetTypeAtIndex(RecType).Field[0].ObjectVariable
    else
      _TypeArray[RecType].Field[x].ObjectVariable := False;

  end;

begin

  NumAllocElements := 0;

  // -----------------------------------------------------------------------------
  //        PROCEDURE, FUNCTION
  // -----------------------------------------------------------------------------

  if TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK] then
  begin    // PROCEDURE, FUNCTION

    DataType := TDataType.POINTERTOK;
    AllocElementType := TDataType.PROCVARTOK;

    i := DeclareFunction(i, NestedNumAllocElements);

    NumAllocElements := NestedNumAllocElements shl 16;  // NumAllocElements = NumProc shl 16

    Result := i - 1;

  end
  else

  // -----------------------------------------------------------------------------
  //        ^TYPE
  // -----------------------------------------------------------------------------

    if TokenAt(i).Kind = TTokenKind.DEREFERENCETOK then
    begin        // ^type

      DataType := TDataType.POINTERTOK;

      if TokenAt(i + 1).Kind = TTokenKind.STRINGTOK then
      begin        // ^string
        NumAllocElements := 0;
        AllocElementType := TDataType.CHARTOK;
        DataType := TDataType.STRINGPOINTERTOK;
      end
      else
        if TokenAt(i + 1).Kind = TTokenKind.IDENTTOK then
        begin

          IdentIndex := GetIdentIndex(TokenAt(i + 1).Name);

          if IdentIndex = 0 then
          begin

            NumAllocElements := i + 1;
            AllocElementType := TDataType.FORWARDTYPE;

          end
          else

            if (IdentIndex > 0) and (IdentifierAt(IdentIndex).DataType in
              [TDataType.RECORDTOK, TDataType.OBJECTTOK] + Pointers) then
            begin
              NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements;

              //  writeln(IdentifierAt(IdentIndex).Name,',',IdentifierAt(IdentIndex).DataType,',',IdentifierAt(IdentIndex).AllocElementType,',',IdentifierAt(IdentIndex).NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_ shl 16 );

{
    if IdentifierAt(IdentIndex).DataType in Pointers then begin
     AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

     if IdentifierAt(IdentIndex).NumAllocElements_ > 0 then    // wymuszamy dostep przez wskaznik
      NumAllocElements := 1 or (1 shl 16)      // [0..0, 0..0]
     else
      NumAllocElements := 1;          // [0..0]
}

              if IdentifierAt(IdentIndex).DataType in Pointers then
              begin

                if IdentifierAt(IdentIndex).DataType = TDataType.STRINGPOINTERTOK then
                begin
                  NumAllocElements := 0;
                  AllocElementType := TDataType.CHARTOK;
                  DataType := TDataType.STRINGPOINTERTOK;
                end
                else
                begin
                  NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements or
                    (IdentifierAt(IdentIndex).NumAllocElements_ shl 16);
                  AllocElementType := IdentifierAt(IdentIndex).AllocElementType;
                  DataType := TDataType.DEREFERENCEARRAYTOK;
                end;

              end
              else
              begin
                NumAllocElements := IdentifierAt(IdentIndex).NumAllocElements or
                  (IdentifierAt(IdentIndex).NumAllocElements_ shl 16);
                AllocElementType := IdentifierAt(IdentIndex).DataType;
              end;

            end;


          //  writeln('= ', NumAllocElements and $FFFF,',',NumAllocElements shr 16,' | ',DataType,',',AllocElementType);

        end
        else
        begin

          if not (TokenAt(i + 1).GetDataType in OrdinalTypes + RealTypes + [TDataType.POINTERTOK]) then
            Error(i + 1, TErrorCode.IdentifierExpected);

          NumAllocElements := 0;
          AllocElementType := TokenAt(i + 1).GetDataType;

        end;

      Result := i + 1;

    end
    else

    // -----------------------------------------------------------------------------
    //        ENUM
    // -----------------------------------------------------------------------------

      if TokenAt(i).Kind = TTokenKind.OPARTOK then
      begin          // enumerated

        Name := TokenAt(i - 2).Name;

        Inc(NumTypes);
        RecType := NumTypes;

        if NumTypes > MAXTYPES then
          Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

        Inc(i);

        _TypeArray[RecType].Field[0].Name := Name;
        _TypeArray[RecType].NumFields := 0;

        ConstVal := 0;
        LowerBound := 0;
        UpperBound := 0;
        NumFieldsInList := 0;

        repeat
          CheckTok(i, TTokenKind.IDENTTOK);

          Inc(NumFieldsInList);
          FieldInListName[NumFieldsInList].Name := TokenAt(i).Name;

          Inc(i);

          if TokenAt(i).Kind in [TTokenKind.ASSIGNTOK, TTokenKind.EQTOK] then
          begin

            i := CompileConstExpression(i + 1, ConstVal, ExpressionType);
            //  GetCommonType(i, ConstValType, SelectorType);

            Inc(i);
          end;

          FieldInListName[NumFieldsInList].Value := ConstVal;

          if NumFieldsInList = 1 then
          begin

            LowerBound := ConstVal;
            UpperBound := ConstVal;

          end
          else
          begin

            if ConstVal < LowerBound then LowerBound := ConstVal;
            if ConstVal > UpperBound then UpperBound := ConstVal;

            if FieldInListName[NumFieldsInList].Value < FieldInListName[NumFieldsInList - 1].Value then
              Note(i, 'Values in enumeration types have to be ascending');

          end;

          Inc(ConstVal);

          if TokenAt(i).Kind = TTokenKind.COMMATOK then Inc(i);

        until TokenAt(i).Kind = TTokenKind.CPARTOK;

        DataType := BoundaryType;

        for FieldInListIndex := 1 to NumFieldsInList do
        begin
          DefineIdent(i, FieldInListName[FieldInListIndex].Name, TTokenKind.ENUMTOK, DataType, 0,
            TDataType.UNTYPETOK, FieldInListName[FieldInListIndex].Value);
{
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, CONSTANT, POINTERTOK, length(FieldInListName[FieldInListIndex].Name)+1, CHARTOK, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE , IDENTTOK);

      StaticStringData[NumStaticStrChars] := length(FieldInListName[FieldInListIndex].Name);

      for k:=1 to length(FieldInListName[FieldInListIndex].Name) do
       StaticStringData[NumStaticStrChars + k] := ord(FieldInListName[FieldInListIndex].Name[k]);

      inc(NumStaticStrChars, length(FieldInListName[FieldInListIndex].Name) + 1);
}
          IdentifierAt(NumIdent).NumAllocElements := RecType;
          IdentifierAt(NumIdent).Pass := TPass.CALL_DETERMINATION;

          DeclareField(FieldInListName[FieldInListIndex].Name, DataType, 0, TDataType.UNTYPETOK,
            FieldInListName[FieldInListIndex].Value);
        end;

        _TypeArray[RecType].Block := BlockStack[BlockStackTop];

        AllocElementType := DataType;

        DataType := TDataType.ENUMTOK;
        NumAllocElements := RecType;      // indeks do tablicy Types

        Result := i;

        //    writeln('>',lowerbound,',',upperbound);

      end
      else

      // -----------------------------------------------------------------------------
      //        TEXTFILE
      // -----------------------------------------------------------------------------

        if TokenAt(i).Kind = TTokenKind.TEXTFILETOK then
        begin          // TextFile

          AllocElementType := TDataType.BYTETOK;
          NumAllocElements := 1;

          DataType := TDataType.TEXTFILETOK;
          Result := i;

        end
        else

        // -----------------------------------------------------------------------------
        //        FILE
        // -----------------------------------------------------------------------------

          if TokenAt(i).Kind = TTokenKind.FILETOK then
          begin          // File

            if TokenAt(i + 1).Kind = TTokenKind.OFTOK then
              i := CompileType(i + 2, DataType, NumAllocElements, AllocElementType)
            else
            begin
              AllocElementType := TDataType.UNTYPETOK;//BYTETOK?
              NumAllocElements := 128;
            end;

            DataType := TDataType.FILETOK;
            Result := i;

          end
          else

          // -----------------------------------------------------------------------------
          //        SET OF
          // -----------------------------------------------------------------------------

            if TokenAt(i).Kind = TTokenKind.SETTOK then
            begin          // Set Of

              CheckTok(i + 1, TTokenKind.OFTOK);

              if not (TokenAt(i + 2).Kind in [TTokenKind.CHARTOK, TTokenKind.BYTETOK]) then
                Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeDeclarationOfSetElements,
                  'Illegal type declaration of set elements'));

              DataType := TDataType.POINTERTOK;
              NumAllocElements := 32;
              AllocElementType := TokenAt(i + 2).GetDataType;

              Result := i + 2;

            end
            else

            // -----------------------------------------------------------------------------
            //        OBJECT
            // -----------------------------------------------------------------------------

              if TokenAt(i).Kind = TTokenKind.OBJECTTOK then          // Object
              begin

                Name := TokenAt(i - 2).Name;

                Inc(NumTypes);
                RecType := NumTypes;

                if NumTypes > MAXTYPES then
                  Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

                Inc(i);

                _TypeArray[RecType].NumFields := 0;
                _TypeArray[RecType].Field[0].Name := Name;
                _TypeArray[RecType].Field[0].ObjectVariable := True;

                if (TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
                  TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) then
                begin

                  while TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
                      TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] do
                  begin

                    IsNestedFunction := (TokenAt(i).Kind = TTokenKind.FUNCTIONTOK);

                    k := i;

                    i := DefineFunction(i, 0, isForward, isInt, isInl, isOvr, IsNestedFunction,
                      NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

                    Inc(NumBlocks);
                    IdentifierAt(NumIdent).ProcAsBlock := NumBlocks;

                    IdentifierAt(NumIdent).IsUnresolvedForward := True;

                    IdentifierAt(NumIdent).ObjectIndex := RecType;
                    IdentifierAt(NumIdent).Name := Name + '.' + TokenAt(k + 1).Name;

                    CheckTok(i, TTokenKind.SEMICOLONTOK);

                    Inc(i);
                  end;

                  if (TokenAt(i).Kind in [TTokenKind.IDENTTOK]) then
                    Error(i, TMessage.Create(TErrorCode.FieldAfterMethodOrProperty,
                      'Fields cannot appear after a method or property definition'));

                end
                else

                  repeat
                    NumFieldsInList := 0;

                    repeat

                      if (TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
                        TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK]) then
                        Error(i, TMessage.Create(TErrorCode.FieldAfterMethodOrProperty,
                          'Fields cannot appear after a method or property definition'));

                      CheckTok(i, TTokenKind.IDENTTOK);

                      Inc(NumFieldsInList);
                      FieldInListName[NumFieldsInList].Name := TokenAt(i).Name;

                      Inc(i);

                      ExitLoop := False;

                      if TokenAt(i).Kind = TTokenKind.COMMATOK then
                        Inc(i)
                      else
                        ExitLoop := True;

                    until ExitLoop;

                    CheckTok(i, TTokenKind.COLONTOK);

                    j := i + 1;

                    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

                    if TokenAt(j).Kind = TTokenKind.ARRAYTOK then
                      i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


                    for FieldInListIndex := 1 to NumFieldsInList do
                    begin              // issue #92 fixed
                      DeclareField(FieldInListName[FieldInListIndex].Name, DataType,
                        NumAllocElements, AllocElementType);

                      if DataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                        //      for FieldInListIndex := 1 to NumFieldsInList do                //
                        for k := 1 to GetTypeAtIndex(NumAllocElements).NumFields do
                        begin
                          DeclareField(FieldInListName[FieldInListIndex].Name + '.' +
                            GetTypeAtIndex(NumAllocElements).Field[k].Name,
                            GetTypeAtIndex(NumAllocElements).Field[k].DataType,
                            GetTypeAtIndex(NumAllocElements).Field[k].NumAllocElements,
                            GetTypeAtIndex(NumAllocElements).Field[k].AllocElementType
                            );

                          //          if DataType = OBJECTTOK then
                          //      Types[RecType].Field[ Types[RecType].NumFields ].ObjectVariable := true;

                          //  writeln('>> ',FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name,',', Types[NumAllocElements].Field[k].NumAllocElements,',',Types[RecType].Field[ Types[RecType].NumFields ].ObjectVariable);
                        end;

                    end;


                    ExitLoop := False;
                    if TokenAt(i + 1).Kind <> TTokenKind.SEMICOLONTOK then
                    begin
                      Inc(i);
                      ExitLoop := True;
                    end
                    else
                    begin
                      Inc(i, 2);

                      if TokenAt(i).Kind = TTokenKind.ENDTOK then ExitLoop := True
                      else
                        if TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
                          TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] then
                        begin

                          while TokenAt(i).Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK,
                              TTokenKind.CONSTRUCTORTOK, TTokenKind.DESTRUCTORTOK] do
                          begin

                            IsNestedFunction := (TokenAt(i).Kind = TTokenKind.FUNCTIONTOK);

                            k := i;

                            i := DefineFunction(i, 0, isForward, isInt, isInl, isOvr,
                              IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements,
                              NestedFunctionAllocElementType);

                            Inc(NumBlocks);
                            IdentifierAt(NumIdent).ProcAsBlock := NumBlocks;

                            IdentifierAt(NumIdent).IsUnresolvedForward := True;

                            IdentifierAt(NumIdent).ObjectIndex := RecType;
                            IdentifierAt(NumIdent).Name := Name + '.' + TokenAt(k + 1).Name;

                            CheckTok(i, TTokenKind.SEMICOLONTOK);

                            Inc(i);
                          end;

                          ExitLoop := True;
                        end;

                    end;

                  until ExitLoop;

                CheckTok(i, TTokenKind.ENDTOK);

                _TypeArray[RecType].Block := BlockStack[BlockStackTop];

                DataType := TDataType.OBJECTTOK;
                NumAllocElements := RecType;      // Index to the Types array
                AllocElementType := TDataType.UNTYPETOK;

                Result := i;
              end
              else// if OBJECTTOK

              // -----------------------------------------------------------------------------
              //        RECORD
              // -----------------------------------------------------------------------------

                if (TokenAt(i).Kind = TTokenKind.RECORDTOK) or
                  ((TokenAt(i).Kind = TTokenKind.PACKEDTOK) and (TokenAt(i + 1).Kind = TTokenKind.RECORDTOK)) then
                  // Record
                begin

                  Name := TokenAt(i - 2).Name;

                  if TokenAt(i).Kind = TTokenKind.PACKEDTOK then Inc(i);

                  Inc(NumTypes);
                  RecType := NumTypes;

                  if NumTypes > MAXTYPES then
                    Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

                  Inc(i);

                  _TypeArray[RecType].Size := 0;
                  _TypeArray[RecType].NumFields := 0;
                  _TypeArray[RecType].Field[0].Name := Name;

                  repeat
                    NumFieldsInList := 0;
                    repeat
                      CheckTok(i, TTokenKind.IDENTTOK);

                      Inc(NumFieldsInList);
                      FieldInListName[NumFieldsInList].Name := TokenAt(i).Name;

                      Inc(i);

                      ExitLoop := False;

                      if TokenAt(i).Kind = TTokenKind.COMMATOK then
                        Inc(i)
                      else
                        ExitLoop := True;

                    until ExitLoop;

                    CheckTok(i, TTokenKind.COLONTOK);

                    j := i + 1;

                    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

                    if TokenAt(j).Kind = TTokenKind.ARRAYTOK then
                      i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


                    //NumAllocElements:=0;    // ??? arrays not allowed, only pointers ???

                    for FieldInListIndex := 1 to NumFieldsInList do
                    begin                // issue #92 fixed
                      DeclareField(FieldInListName[FieldInListIndex].Name, DataType,
                        NumAllocElements, AllocElementType);

                      if DataType = TDataType.RECORDTOK then
                        //for FieldInListIndex := 1 to NumFieldsInList do                //
                        for k := 1 to GetTypeAtIndex(NumAllocElements).NumFields do
                          DeclareField(FieldInListName[FieldInListIndex].Name + '.' +
                            GetTypeAtIndex(NumAllocElements).Field[k].Name,
                            GetTypeAtIndex(NumAllocElements).Field[k].DataType,
                            GetTypeAtIndex(NumAllocElements).Field[k].NumAllocElements,
                            GetTypeAtIndex(NumAllocElements).Field[k].AllocElementType);

                    end;

                    ExitLoop := False;
                    if TokenAt(i + 1).Kind <> TTokenKind.SEMICOLONTOK then
                    begin
                      Inc(i);
                      ExitLoop := True;
                    end
                    else
                    begin
                      Inc(i, 2);
                      if TokenAt(i).Kind = TTokenKind.ENDTOK then ExitLoop := True;
                    end

                  until ExitLoop;

                  CheckTok(i, TTokenKind.ENDTOK);

                  _TypeArray[RecType].Block := BlockStack[BlockStackTop];

                  DataType := TDataType.RECORDTOK;
                  NumAllocElements := RecType;      // index to the Types array
                  AllocElementType := TDataType.UNTYPETOK;

                  if GetTypeAtIndex(RecType).Size > 256 then
                    Error(i, TMessage.Create(TErrorCode.RecordSizeExceedsLimit,
                      'Record size {0} exceeds the 256 bytes limit.', IntToStr(GetTypeAtIndex(RecType).Size)));

                  Result := i;
                end
                else// if RECORDTOK

                // -----------------------------------------------------------------------------
                //        PCHAR
                // -----------------------------------------------------------------------------

                  if TokenAt(i).Kind = TTokenKind.PCHARTOK then            // PChar
                  begin

                    DataType := TDataType.POINTERTOK;
                    AllocElementType := TDataType.CHARTOK;

                    NumAllocElements := 0;

                    Result := i;
                  end
                  else // Pchar

                  // -----------------------------------------------------------------------------
                  //        STRING
                  // -----------------------------------------------------------------------------

                    if TokenAt(i).Kind = TTokenKind.STRINGTOK then          // String
                    begin
                      DataType := TDataType.STRINGPOINTERTOK;
                      AllocElementType := TDataType.CHARTOK;

                      if TokenAt(i + 1).Kind <> TTokenKind.OBRACKETTOK then
                      begin

                        UpperBound := 255;         // default string[255]

                        Result := i;

                      end
                      else
                      begin
                        //   Error(i + 1, '[ expected but ' + GetSpelling(i + 1) + ' found');

                        i := CompileConstExpression(i + 2, UpperBound, ExpressionType);

                        if (UpperBound < 1) or (UpperBound > 255) then
                          Error(i, TMessage.Create(TErrorCode.StringLengthNotInRange,
                            'String length must be a value from 1 to 255'));

                        CheckTok(i + 1, TTokenKind.CBRACKETTOK);

                        Result := i + 1;
                      end;

                      NumAllocElements := UpperBound + 1;

                      if UpperBound > 255 then
                        Error(i, TErrorCode.SubrangeBounds);

                    end// if STRINGTOK
                    else


                    // -----------------------------------------------------------------------------
                    // this place is for new types
                    // -----------------------------------------------------------------------------




                    // -----------------------------------------------------------------------------
                    //      OrdinalTypes + RealTypes + Pointers
                    // -----------------------------------------------------------------------------

                      if TokenAt(i).GetDataType in AllTypes then
                      begin
                        DataType := TokenAt(i).GetDataType;
                        NumAllocElements := 0;
                        AllocElementType := TDataType.UNTYPETOK;

                        Result := i;
                      end
                      else

                      // -----------------------------------------------------------------------------
                      //          ARRAY
                      // -----------------------------------------------------------------------------

                        if (TokenAt(i).Kind = TTokenKind.ARRAYTOK) or
                          ((TokenAt(i).Kind = TTokenKind.PACKEDTOK) and (TokenAt(i + 1).Kind =
                          TTokenKind.ARRAYTOK)) then
                          // Array
                        begin
                          DataType := TDataType.POINTERTOK;

                          if TokenAt(i).Kind = TTokenKind.PACKEDTOK then Inc(i);

                          CheckTok(i + 1, TTokenKind.OBRACKETTOK);

                          if (TokenAt(i + 2).Kind = TTokenKind.IDENTTOK) and
                            (IdentifierAt(GetIdentIndex(TokenAt(i + 2).Name)).Kind = TTokenKind.TYPETOK) then
                          begin

                            IdentIndex := GetIdentIndex(TokenAt(i + 2).Name);

                            if IdentIndex = 0 then
                              Error(i, TErrorCode.UnknownIdentifier);

                            Inc(i, 2);

                            if IdentifierAt(IdentIndex).DataType = TDataType.SUBRANGETYPE then
                            begin

                              LowerBound := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[1].Value;
                              UpperBound := GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[2].Value;

                              if LowerBound <> 0 then
                                Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotZero,
                                  'Array lower bound is not zero.'));

                              if UpperBound > High(Word) then
                                Error(i, TErrorCode.HighLimit);

                              NumAllocElements := UpperBound - LowerBound + 1;

                            end
                            else
                              if IdentifierAt(IdentIndex).DataType = TDataType.BYTETOK then
                              begin
                                LowerBound := 0;
                                UpperBound := 255;

                                NumAllocElements := 256;
                              end
                              else
                                Error(i, TMessage.Create(TErrorCode.InvalidTypeDefinition,
                                  'Invalid type definition.'));

                          end
                          else

                            if TokenAt(i + 2).GetDataType in AllTypes + StringTypes then
                            begin

                              if TokenAt(i + 2).Kind = TTokenKind.BYTETOK then
                              begin
                                LowerBound := 0;
                                UpperBound := 255;

                                NumAllocElements := 256;
                              end
                              else
                                Error(i, TMessage.Create(TErrorCode.InvalidTypeDefinition,
                                  'Invalid type definition.'));

                              Inc(i, 2);

                            end
                            else
                            begin

                              i := CompileConstExpression(i + 2, LowerBound, ExpressionType);
                              if not (ExpressionType in IntegerTypes) then
                                Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotInteger,
                                  'Array lower bound must be an integer value.'));

                              if LowerBound <> 0 then
                                Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotZero,
                                  'Array lower bound is not zero.'));

                              CheckTok(i + 1, TTokenKind.RANGETOK);

                              i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
                              if not (ExpressionType in IntegerTypes) then
                                Error(i, TMessage.Create(TErrorCode.ArrayUpperBoundNotInteger,
                                  'Array upper bound must be integer value.'));

                              if UpperBound < 0 then
                                Error(i, TErrorCode.UpperBoundOfRange);

                              if UpperBound > High(Word) then
                                Error(i, TErrorCode.HighLimit);

                              NumAllocElements := UpperBound - LowerBound + 1;

                              if TokenAt(i + 1).Kind = TTokenKind.COMMATOK then
                              begin        // [0..x, 0..y]

                                i := CompileConstExpression(i + 2, LowerBound, ExpressionType);
                                if not (ExpressionType in IntegerTypes) then
                                  Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotInteger,
                                    'Array lower bound must be an integer value.'));

                                if LowerBound <> 0 then
                                  Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotZero,
                                    'Array lower bound is not zero.'));

                                CheckTok(i + 1, TTokenKind.RANGETOK);

                                i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
                                if not (ExpressionType in IntegerTypes) then
                                  Error(i, TMessage.Create(TErrorCode.ArrayUpperBoundNotInteger,
                                    'Array upper bound must be an integer value.'));

                                if UpperBound < 0 then
                                  Error(i, TErrorCode.UpperBoundOfRange);

                                if UpperBound > High(Word) then
                                  Error(i, TErrorCode.HighLimit);

                                NumAllocElements := NumAllocElements or (UpperBound - LowerBound + 1) shl 16;

                              end;

                            end;  // if TokenAt(i + 2).Kind in AllTypes + StringTypes

                          CheckTok(i + 1, TTokenKind.CBRACKETTOK);
                          CheckTok(i + 2, TTokenKind.OFTOK);


                          if TokenAt(i + 3).GetDataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                            Error(i, TMessage.Create(TErrorCode.InvalidArrayOfPointers,
                              'Only arrays of ^{0} are supported.', InfoAboutToken(TokenAt(i + 3).Kind)));


                          if TokenAt(i + 3).Kind = TTokenKind.ARRAYTOK then
                          begin
                            i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);
                            Result := i;
                          end
                          else
                          begin
                            Result := i;
                            i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);
                          end;


                          if NestedDataType = TDataType.SUBRANGETYPE then
                          begin
                            NestedDataType := GetTypeAtIndex(NestedNumAllocElements).Field[0].AllocElementType;
                            NestedNumAllocElements := 0;
                            NestedAllocElementType := TDataType.UNTYPETOK;
                          end;


                          // TODO: Have Constant for 40960
                          if (NumAllocElements shr 16) * (NumAllocElements and $FFFF) *
                            GetDataSize(NestedDataType) > 40960 - 1 then
                            Error(i, TMessage.Create(TErrorCode.ArraySizeExceedsRAMSize,
                              'Array [0..{0}, 0..{1} size exceeds the available RAM', IntToStr(
                              (NumAllocElements and $FFFF) - 1), IntToStr((NumAllocElements shr 16) - 1)));


                          // sick3
                          // writeln('>',NestedDataType,',',NestedAllocElementType,',',TokenAt(i).kind,',',hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));

                          //  if NestedAllocElementType = PROCVARTOK then
                          //      Error(i, InfoAboutToken(NestedAllocElementType)+' arrays are not supported');


                          if NestedNumAllocElements > 0 then
                            //    Error(i, 'Multidimensional arrays are not supported');
                            if NestedDataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK, TDataType.ENUMTOK] then
                            begin // !!! dla RECORD, OBJECT tablice nie zadzialaja !!!

                              if NumAllocElements shr 16 > 0 then
                                Error(i, TMessage.Create(TErrorCode.MultiDimensionalArrayOfTypeNotSupported,
                                  'Multidimensional arrays of element type {0} are not supported.',
                                  InfoAboutDataType(NestedDataType)));

                              //    if NestedDataType = RECORDTOK then
                              //    else
                              if NestedDataType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                                Error(i, TMessage.Create(TErrorCode.OnlyArrayOfTypeSupported,
                                  'Only Array [0..{0}] of ^{1} supported', IntToStr(NumAllocElements - 1),
                                  InfoAboutDataType(NestedDataType)))
                              else
                                Error(i, TMessage.Create(TErrorCode.ArrayOfTypeNotSupported,
                                  'Arrays of type {0} are not supported.', InfoAboutDataType(NestedDataType)));

                              //    NumAllocElements := NestedNumAllocElements;
                              //    NestedAllocElementType := NestedDataType;
                              //    NestedDataType := POINTERTOK;

                              //    NestedDataType := NestedAllocElementType;
                              NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

                            end
                            else
                              if not (NestedDataType in [TDataType.STRINGPOINTERTOK,
                                TDataType.RECORDTOK, TDataType.OBJECTTOK{, TDataType.PCHARTOK}]) and
                                (TokenAt(i).Kind <> TTokenKind.PCHARTOK) then
                              begin

                                if (NestedAllocElementType in [TDataType.RECORDTOK,
                                  TDataType.OBJECTTOK, TDataType.PROCVARTOK]) and (NumAllocElements shr 16 > 0) then
                                  Error(i, TMessage.Create(TErrorCode.MultiDimensionalArrayOfTypeNotSupported,
                                    'Multidimensional arrays of element type {0} are not supported.',
                                    InfoAboutDataType(NestedAllocElementType)));

                                NestedDataType := NestedAllocElementType;

                                if NestedAllocElementType = TDataType.PROCVARTOK then
                                  NumAllocElements := NumAllocElements or NestedNumAllocElements
                                else
                                  if NestedAllocElementType in [TDataType.RECORDTOK, TDataType.OBJECTTOK] then
                                    NumAllocElements :=
                                      NestedNumAllocElements or (NumAllocElements shl 16)
                                  // array [..] of ^record|^object
                                  else
                                    NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

                              end;

                          AllocElementType := NestedDataType;

                          //  Result := i;
                        end // if ARRAYTOK
                        else

                        // -----------------------------------------------------------------------------
                        //           USERTYPE
                        // -----------------------------------------------------------------------------

                          if (TokenAt(i).Kind = TTokenKind.IDENTTOK) and
                            (IdentifierAt(GetIdentIndex(TokenAt(i).Name)).Kind = TTokenKind.TYPETOK) then
                          begin
                            IdentIndex := GetIdentIndex(TokenAt(i).Name);

                            if IdentIndex = 0 then
                              Error(i, TErrorCode.UnknownIdentifier);

                            if IdentifierAt(IdentIndex).Kind <> TTokenKind.TYPETOK then
                              Error(i, TMessage.Create(TErrorCode.TypeIdentifierExpected,
                                'Type identifier expected but {0} found', TokenAt(i).Name));

                            DataType := IdentifierAt(IdentIndex).DataType;

                            if DataType = TDataType.SUBRANGETYPE then
                            begin

                              DataType :=
                                GetTypeAtIndex(IdentifierAt(IdentIndex).NumAllocElements).Field[0].AllocElementType;
                              NumAllocElements := 0;
                              AllocElementType := TDataType.UNTYPETOK;

                            end
                            else
                            begin

                              NumAllocElements :=
                                IdentifierAt(IdentIndex).NumAllocElements or
                                (IdentifierAt(IdentIndex).NumAllocElements_ shl 16);
                              AllocElementType := IdentifierAt(IdentIndex).AllocElementType;

                            end;

                            //  writeln('> ',IdentifierAt(IdentIndex).Name,',',DataType,',',AllocElementType,',',NumAllocElements,',',IdentifierAt(IdentIndex).NumAllocElements_);

                            Result := i;
                          end // if IDENTTOK
                          else
                          begin

                            Name := TokenAt(i - 2).Name;

                            i := CompileConstExpression(i, ConstVal, ExpressionType);
                            LowerBound := ConstVal;

                            CheckTok(i + 1, TTokenKind.RANGETOK);

                            i := CompileConstExpression(i + 2, ConstVal, ExpressionType);
                            UpperBound := ConstVal;

                            if UpperBound < LowerBound then
                              Error(i, TErrorCode.UpperBoundOfRange);

                            // Error(i, 'Error in type definition');


                            Inc(NumTypes);
                            RecType := NumTypes;

                            if NumTypes > MAXTYPES then
                              Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

                            _TypeArray[RecType].NumFields := 2;
                            _TypeArray[RecType].Field[0].AllocElementType := BoundaryType;
                            _TypeArray[RecType].Field[0].Name := Name;

                            _TypeArray[RecType].Field[1].Value := LowerBound;
                            _TypeArray[RecType].Field[2].Value := UpperBound;

                            _TypeArray[RecType].Block := BlockStack[BlockStackTop];

                            DataType := TDataType.SUBRANGETYPE;
                            NumAllocElements := RecType;      // index to the Types array
                            AllocElementType := TDataType.UNTYPETOK;

                            Result := i;

                          end;

end;  //CompileType


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


end.
