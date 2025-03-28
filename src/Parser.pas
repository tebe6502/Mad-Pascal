unit Parser;

{$I Defines.inc}

interface

uses Common, Numbers, Types;

// -----------------------------------------------------------------------------

function CompileType(i: TTokenIndex; out DataType: TDatatype; out NumAllocElements: Cardinal;
  out AllocElementType: TDatatype): TTokenIndex;

function CompileConstExpression(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDatatype;
  const VarType: TDatatype = INTEGERTOK; const Err: Boolean = False; const War: Boolean = True): TTokenIndex;

function CompileConstTerm(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDatatype): TTokenIndex;

procedure DefineIdent(const tokenIndex: TTokenIndex; Name: TIdentifierName; Kind: TTokenKind; DataType: TDataType;
  NumAllocElements: Cardinal; AllocElementType: TDataType; Data: Int64; IdType: TDataType = IDENTTOK);

function DefineFunction(i: TTokenIndex; ForwardIdentIndex: TIdentIndex;
  out isForward, isInt, isInl, isOvr: Boolean; var IsNestedFunction: Boolean;
  out NestedFunctionResultType: TDatatype; out NestedFunctionNumAllocElements: Cardinal;
  out NestedFunctionAllocElementType: Byte): Integer;

function Elements(IdentIndex: TIdentIndex): Cardinal;

function GetIdentIndex(S: TIdentifierName): TIdentIndex;

function GetSizeOf(i: TTokenIndex; ValType: TDatatype): Int64;

function ObjectRecordSize(i: Cardinal): Integer;

function RecordSize(IdentIndex: TIdentIndex; field: String = ''): Integer;

procedure SaveToDataSegment(ConstDataSize: Integer; ConstVal: Int64; ConstValType: Byte);

// -----------------------------------------------------------------------------

implementation

uses SysUtils, Messages, Utilities;

// ----------------------------------------------------------------------------


function Elements(IdentIndex: integer): cardinal;
begin

 if (Ident[IdentIndex].DataType = ENUMTYPE) then
  Result := 0
 else

   if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then
    Result := Ident[IdentIndex].NumAllocElements_
   else
   if (Ident[IdentIndex].NumAllocElements_ = 0) or (Ident[IdentIndex].AllocElementType in [PROCVARTOK]) then
    Result := Ident[IdentIndex].NumAllocElements
   else
    Result := Ident[IdentIndex].NumAllocElements * Ident[IdentIndex].NumAllocElements_;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetIdentIndex(S: TString): Integer;
var TempIndex: integer;

  function UnitAllowedAccess(IdentIndex, Index: integer): Boolean;
  var i: integer;
  begin

   Result := false;

   if Ident[IdentIndex].Section then
    for i := MAXALLOWEDUNITS downto 1 do
      if UnitName[Index].Allow[i] = UnitName[Ident[IdentIndex].UnitIndex].Name then exit(true);

  end;


  function Search(X: TString; UnitIndex: integer): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
    for IdentIndex := 1 to NumIdent do
      if (X = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
	if (Ident[IdentIndex].UnitIndex = UnitIndex) {or Ident[IdentIndex].Section} or (Ident[IdentIndex].UnitIndex = 1) or (UnitName[Ident[IdentIndex].UnitIndex].Name = 'SYSTEM') or UnitAllowedAccess(IdentIndex, UnitIndex) then begin
	  Result := IdentIndex;
	  Ident[IdentIndex].Pass := Pass;

	  if pos('.', X) > 0 then GetIdentIndex(copy(X, 1, pos('.', X)-1));

	  if (Ident[IdentIndex].UnitIndex = UnitIndex) or (Ident[IdentIndex].UnitIndex = 1){ or (UnitName[Ident[IdentIndex].UnitIndex].Name = 'SYSTEM')} then exit;
	end

  end;


  function SearchCurrentUnit(X: TString; UnitIndex: integer): integer;
  var IdentIndex, BlockStackIndex: Integer;
  begin

    Result := 0;

    for BlockStackIndex := BlockStackTop downto 0 do       // search all nesting levels from the current one to the most outer one
    for IdentIndex := 1 to NumIdent do
      if (X = Ident[IdentIndex].Name) and (BlockStack[BlockStackIndex] = Ident[IdentIndex].Block) then
	if (Ident[IdentIndex].UnitIndex = UnitIndex) or UnitAllowedAccess(IdentIndex, UnitIndex) then begin
	  Result := IdentIndex;
	  Ident[IdentIndex].Pass := Pass;

	  if pos('.', X) > 0 then GetIdentIndex(copy(X, 1, pos('.', X)-1));

	  if (Ident[IdentIndex].UnitIndex = UnitIndex) then exit;
	end

  end;



begin

  if S = '' then exit(-1);

  Result := Search(S, UnitNameIndex);

  if (Result = 0) and (pos('.', S) > 0) then begin   // potencjalnie odwolanie do unitu / obiektu

    TempIndex := Search(copy(S, 1, pos('.', S)-1), UnitNameIndex);

//    writeln(S,',',Ident[TempIndex].Kind,' - ', Ident[TempIndex].DataType, ' / ',Ident[TempIndex].AllocElementType);

    if TempIndex > 0 then
     if (Ident[TempIndex].Kind = UNITTYPE) or (Ident[TempIndex].DataType = ENUMTYPE) then
       Result := SearchCurrentUnit(copy(S, pos('.', S)+1, length(S)), Ident[TempIndex].UnitIndex)
     else
      if Ident[TempIndex].DataType = OBJECTTOK then
       Result := SearchCurrentUnit(TypeArray[Ident[TempIndex].NumAllocElements].Field[0].Name + copy(S, pos('.', S), length(S)), Ident[TempIndex].UnitIndex);
      {else
       if ( (Ident[TempIndex].DataType in Pointers) and (Ident[TempIndex].AllocElementType = RECORDTOK) ) then
	Result := TempIndex;}

//    writeln(S,' | ',copy(S, 1, pos('.', S)-1),',',TempIndex,'/',Result,' | ',Ident[TempIndex].Kind,',',UnitName[Ident[TempIndex].UnitIndex].Name);

  end;

end;	//GetIdent


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function ObjectRecordSize(i: cardinal): integer;
var j: integer;
    FieldType, AllocElementType: Byte;
    NumAllocElements: cardinal;
begin

 Result := 0;

 FieldType := 0;

 if i > 0 then begin

   for j := 1 to TypeArray[i].NumFields do begin

    FieldType := TypeArray[i].Field[j].DataType;
    
    // TODO: The two variables below are unused.
    NumAllocElements := TypeArray[i].Field[j].NumAllocElements;
    AllocElementType := TypeArray[i].Field[j].AllocElementType;

    if FieldType <> RECORDTOK then
     inc(Result, DataSize[FieldType]);

   end;

end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function RecordSize(IdentIndex: integer; field: string =''): integer;
var i, j: integer;
    name, base: TName;
    FieldType, AllocElementType: Byte;
    NumAllocElements: cardinal;
    yes: Boolean;
begin

// if Ident[IdentIndex].NumAllocElements_ > 0 then
//  i := Ident[IdentIndex].NumAllocElements_
// else
  i := Ident[IdentIndex].NumAllocElements;

 Result := 0;

 FieldType := 0;

 yes := false;

 if i > 0 then begin

   for j := 1 to TypeArray[i].NumFields do begin

    FieldType := TypeArray[i].Field[j].DataType;
    NumAllocElements := TypeArray[i].Field[j].NumAllocElements;
    AllocElementType :=  TypeArray[i].Field[j].AllocElementType;

    if AllocElementType in [FORWARDTYPE, PROCVARTOK] then begin
     AllocElementType := POINTERTOK;
     NumAllocElements := 0;
    end;

    if TypeArray[i].Field[j].Name = field then begin yes:=true; Break end;

    if FieldType <> RECORDTOK then
     if (FieldType in Pointers) and (NumAllocElements > 0) then
      inc(Result, NumAllocElements * DataSize[AllocElementType])
     else
      inc(Result, DataSize[FieldType]);

   end;

 end else begin

  name:=Ident[IdentIndex].Name;

  base:=copy(name, 1, pos('.', name)-1);

  IdentIndex := GetIdentIndex(base);

  for i := 1 to TypeArray[Ident[IdentIndex].NumAllocElements].NumFields do
   if pos(name, base+'.'+TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].Name) > 0 then
    if TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].DataType <> RECORDTOK then begin

     FieldType := TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].DataType;
     NumAllocElements := TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].NumAllocElements;
     AllocElementType := TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].AllocElementType;

     if TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].Name = field then begin yes:=true; Break end;

     if FieldType <> RECORDTOK then
      if (FieldType in Pointers) and (NumAllocElements > 0) then
       inc(Result, NumAllocElements * DataSize[AllocElementType])
      else
       inc(Result, DataSize[FieldType]);

    end;

 end;


 if field <> '' then
  if not yes then
   Result := -1
  else
   Result := Result + FieldType shl 16;		// type | offset

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveToDataSegment(ConstDataSize: integer; ConstVal: Int64; ConstValType: Byte);
begin

	if (ConstDataSize < 0) or (ConstDataSize > $FFFF) then
	begin writeln('SaveToDataSegment: ', ConstDataSize);
	      RaiseHaltException(THaltException.COMPILING_ABORTED);
	end;

	 case ConstValType of

	  SHORTINTTOK, BYTETOK, CHARTOK, BOOLEANTOK:
		       DataSegment[ConstDataSize] := byte(ConstVal);

	  SMALLINTTOK, WORDTOK, SHORTREALTOK, POINTERTOK, STRINGPOINTERTOK, PCHARTOK:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	   DATAORIGINOFFSET:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal) or $8000;
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8) or $4000;
		       end;

	   CODEORIGINOFFSET:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal) or $2000;
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8) or $1000;
		       end;

	   INTEGERTOK, CARDINALTOK, REALTOK:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
			DataSegment[ConstDataSize+2] := byte(ConstVal shr 16);
			DataSegment[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	    SINGLETOK: begin
			ConstVal:=CastToSingle(ConstVal);

			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
			DataSegment[ConstDataSize+2] := byte(ConstVal shr 16);
			DataSegment[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	HALFSINGLETOK: begin
			ConstVal:=CastToHalfSingle(ConstVal);

			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	 end;

 DataSegmentUse := true;

end;	//SaveToDataSegment


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function GetSizeOf(i: TTokenIndex; ValType: TDatatype): Int64;
var IdentIndex: integer;
begin

     IdentIndex := GetIdentIndex(Tok[i + 2].Name);

     case ValType of

	ENUMTYPE: Result := DataSize[Ident[IdentIndex].AllocElementType];

	RECORDTOK: if (Ident[IdentIndex].DataType = POINTERTOK) and (Tok[i + 3].Kind = CPARTOK) then
	             Result := DataSize[POINTERTOK]
		   else
		     Result := RecordSize(IdentIndex);

      POINTERTOK, STRINGPOINTERTOK:
		  begin

		    if Ident[IdentIndex].AllocElementType = RECORDTOK then begin

		     if Ident[IdentIndex].NumAllocElements_ > 0 then begin

		       if Tok[i + 3].Kind = OBRACKETTOK then
			Result := DataSize[POINTERTOK]
		       else
			Result := Ident[IdentIndex].NumAllocElements_ * 2

		     end else
		      if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then
		       Result := RecordSize(IdentIndex)
		      else
		       Result := DataSize[POINTERTOK];

		    end else
		     if Elements(IdentIndex) > 0 then
		       Result := integer(Elements(IdentIndex) * DataSize[Ident[IdentIndex].AllocElementType])
		     else
		       Result := DataSize[POINTERTOK];

		  end;

      else

	if ValType = UNTYPETOK then
	 Result := 0
	else
	 Result := DataSize[ValType]

     end;

end;	//GetSizeof


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstFactor(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDatatype): TTokenIndex;
var IdentIndex, j: Integer;
    Kind: TTokenKind;
    ArrayIndexType: TDatatype;
    ArrayIndex: Int64;

    function GetStaticValue(x: byte): Int64;
    begin

      Result := StaticStringData[Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_BASE + ArrayIndex * DataSize[ConstValType] + x];

    end;

begin

 ConstVal:=0;
 ConstValType:=0;
 Result := i;

 j:=0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 LOWTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in AllTypes {+ [STRINGTOK]} then begin

      ConstValType := Tok[i + 2].Kind;

      inc(i, 2);

     end else begin

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

     end;


     if ConstValType in Pointers then
      ConstVal := 0
     else
      ConstVal := LowBound(i, ConstValType);

     ConstValType := GetValueType(ConstVal);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 HIGHTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in AllTypes {+ [STRINGTOK]} then begin

      ConstValType := Tok[i + 2].Kind;

      inc(i, 2);

     end else begin

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

     end;

     if ConstValType in Pointers then begin
      IdentIndex := GetIdentIndex(Tok[i].Name);

      if Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK] then
       ConstVal := Ident[IdentIndex].NumAllocElements_ - 1
      else
      if Ident[IdentIndex].NumAllocElements > 0 then
       ConstVal := Ident[IdentIndex].NumAllocElements - 1
      else
       ConstVal := 0;

     end else
      ConstVal := HighBound(i, ConstValType);

     ConstValType := GetValueType(ConstVal);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 LENGTHTOK:
    begin
     CheckTok(i + 1, OPARTOK);

      ConstVal:=0;

      if Tok[i + 2].Kind = IDENTTOK then begin

	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

	if Ident[IdentIndex].Kind in [VARIABLE, CONSTANT] then begin

	  if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0)) then begin

	   if (Ident[IdentIndex].DataType = STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = CHARTOK) then begin

	   isError := true;
	   exit;

	   end else begin

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].AllocElementType );

	    if (Ident[IdentIndex].DataType = POINTERTOK) and (Ident[IdentIndex].AllocElementType in [RECORDTOK, OBJECTTOK]) then
	      ConstVal:=Ident[IdentIndex].NumAllocElements_
	    else
	      ConstVal:=Ident[IdentIndex].NumAllocElements;

	    ConstValType := GetValueType(ConstVal);
	   end;

	  end else
	   Error(i+2, TErrorCode.TypeMismatch);

	end else
	 Error(i + 2, TErrorCode.IdentifierExpected);

	inc(i, 2);
      end else
       Error(i + 2, TErrorCode.IdentifierExpected);

     CheckTok(i + 1, CPARTOK);

     Result:=i + 1;
    end;


 SIZEOFTOK:
    begin
     CheckTok(i + 1, OPARTOK);

     if Tok[i + 2].Kind in OrdinalTypes + RealTypes + [POINTERTOK] then begin

      ConstVal := DataSize[Tok[i + 2].Kind];
      ConstValType := BYTETOK;

      j:=i + 2;

     end else begin

      if Tok[i + 2].Kind <> IDENTTOK then
        Error(i + 2, TErrorCode.IdentifierExpected);

      j := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      ConstVal := GetSizeof(i, ConstValType);

      ConstValType := GetValueType(ConstVal);

     end;

     CheckTok(j + 1, CPARTOK);

     Result:=j + 1;
    end;


  LOTOK:
    begin

    CheckTok(i + 1, OPARTOK);

    OldConstValType:=0;

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

    if OldConstValType in [DATAORIGINOFFSET, CODEORIGINOFFSET] then
        Error(i, TMessage.Create(TErrorCode.InvalidVariableAddress, 'Can''t take the address of variable'));

    GetCommonConstType(i, INTEGERTOK, ConstValType);

    CheckTok(i + 1, CPARTOK);

    case ConstValType of
      INTEGERTOK, CARDINALTOK: ConstVal := ConstVal and $0000FFFF;
	 SMALLINTTOK, WORDTOK: ConstVal := ConstVal and $00FF;
	 SHORTINTTOK, BYTETOK: ConstVal := ConstVal and $0F;
    end;

    ConstValType := GetValueType(ConstVal);

    Result:=i + 1;
    end;


  HITOK:
    begin

    CheckTok(i + 1, OPARTOK);

    OldConstValType:=0;

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

    if OldConstValType in [DATAORIGINOFFSET, CODEORIGINOFFSET] then
        Error(i, TMessage.Create(TErrorCode.InvalidVariableAddress, 'Can''t take the address of variable'));

    GetCommonConstType(i, INTEGERTOK, ConstValType);

    CheckTok(i + 1, CPARTOK);

    case ConstValType of
      INTEGERTOK, CARDINALTOK: ConstVal := ConstVal shr 16;
	 SMALLINTTOK, WORDTOK: ConstVal := ConstVal shr 8;
	 SHORTINTTOK, BYTETOK: ConstVal := ConstVal shr 4;
    end;

    ConstValType := GetValueType(ConstVal);
    Result:=i + 1;
    end;


  INTTOK, FRACTOK:
    begin

      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      if not (ConstValType in RealTypes) then
	ErrorIncompatibleTypes(i, ConstValType, REALTOK);

      CheckTok(i + 1, CPARTOK);

      	case Kind of
	  INTTOK: ConstVal:=Trunc(ConstValType, ConstVal);
	 FRACTOK: ConstVal:=Frac(ConstValType, ConstVal);
	end;

 //     ConstValType := REALTOK;
      Result:=i + 1;
    end;


  ROUNDTOK, TRUNCTOK:
    begin

      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, REALTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

      ConstVal := integer(ConstVal);

      case Kind of
	ROUNDTOK: if ConstVal < 0 then
		   ConstVal := -( abs(ConstVal) shr 8 + ord( abs(ConstVal) and $ff > 127) )
		  else
		   ConstVal := ConstVal shr 8 + ord( abs(ConstVal) and $ff > 127);

	TRUNCTOK: if ConstVal < 0 then
		   ConstVal := -( abs(ConstVal) shr 8)
		  else
		   ConstVal := ConstVal shr 8;
      end;

      ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;


  ODDTOK:
    begin

//      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, CARDINALTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

      ConstVal := ord(odd(ConstVal));

      ConstValType := BOOLEANTOK;

      Result:=i + 1;
    end;


  CHRTOK:
    begin

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, BYTETOK);

      if isError then Exit;

      GetCommonConstType(i, INTEGERTOK, ConstValType);

      CheckTok(i + 1, CPARTOK);

      ConstValType := CHARTOK;
      Result:=i + 1;
    end;


  ORDTOK:
    begin
      CheckTok(i + 1, OPARTOK);

      j := i + 2;

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, BYTETOK);

      if not(ConstValType in OrdinalTypes + [ENUMTYPE]) then
	Error(i, TErrorCode.OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, CPARTOK);

      if ConstValType in [CHARTOK, BOOLEANTOK, ENUMTOK] then
       ConstValType := BYTETOK;

      Result:=i + 1;
    end;


  PREDTOK, SUCCTOK:
    begin
      Kind := Tok[i].Kind;

      CheckTok(i + 1, OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if not(ConstValType in OrdinalTypes) then
	Error(i, TErrorCode.OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, CPARTOK);

      if Kind = PREDTOK then
       dec(ConstVal)
      else
       inc(ConstVal);

      if not (ConstValType in [CHARTOK, BOOLEANTOK]) then
       ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;


  IDENTTOK:
    begin
    IdentIndex := GetIdentIndex(Tok[i].Name);

    if IdentIndex > 0 then

	  if (Ident[IdentIndex].Kind = USERTYPE) and (Tok[i + 1].Kind = OPARTOK) then begin

		CheckTok(i + 1, OPARTOK);

		j := CompileConstExpression(i + 2, ConstVal, ConstValType);

		if isError then Exit;

		if not(ConstValType in AllTypes) then
		  Error(i, TErrorCode.TypeMismatch);


		if (Ident[GetIdentIndex(Tok[i].Name)].DataType in RealTypes) and (ConstValType in RealTypes) then begin
		// ok
		end else
          if Ident[GetIdentIndex(Tok[i].Name)].DataType in Pointers then
          begin
            Error(j, TMessage.Create(TErrorCode.IllegalTypeConversion, 'Illegal type conversion: "' +
              InfoAboutToken(ConstValType) + '" to "' + Tok[i].Name + '"'));
          end;

		ConstValType := Ident[GetIdentIndex(Tok[i].Name)].DataType;

		CheckTok(j + 1, CPARTOK);

		i := j + 1;

	  end else

      if not (Ident[IdentIndex].Kind in [CONSTANT, USERTYPE, ENUMTYPE]) then
      begin
          Error(i, TMessage.Create(TErrorCode.ConstantExpected, 'Constant expected but {0} found', Ident[IdentIndex].Name));
      end
      else
	if Tok[i + 1].Kind = OBRACKETTOK then					// Array element access
	  if  not (Ident[IdentIndex].DataType in Pointers) then
	    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
	  else
	    begin

	    j := CompileConstExpression(i + 2, ArrayIndex, ArrayIndexType);	// Array index

	    if isError then Exit;

	    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements-1 + ord(Ident[IdentIndex].DataType = STRINGPOINTERTOK)) then begin
	     isConst := false;
	     Error(i, TErrorCode.SubrangeBounds);
	    end;

	    CheckTok(j + 1, CBRACKETTOK);

	    if Tok[j + 2].Kind = OBRACKETTOK then begin isError:=true; exit end;

//	    InfoAboutArray(IdentIndex, true);

	    ConstValType := Ident[IdentIndex].AllocElementType;

	    case DataSize[ConstValType] of
	     1: ConstVal := GetStaticValue(0 + ord(Ident[IdentIndex].idType = PCHARTOK));
	     2: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8;
	     4: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8 + GetStaticValue(2) shl 16 + GetStaticValue(3) shl 24;
	    end;

	    if ConstValType in [HALFSINGLETOK, SINGLETOK] then ConstVal := ConstVal shl 32;

	    i := j + 1;
	    end else

	begin

	ConstValType := Ident[IdentIndex].DataType;

	if (ConstValType in Pointers) or (Ident[IdentIndex].DataType = STRINGPOINTERTOK) then
	 ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	else
	 ConstVal := Ident[IdentIndex].Value;


	if ConstValType = ENUMTYPE then begin
	  CheckTok(i + 1, OPARTOK);

	  j := CompileConstExpression(i + 2, ConstVal, ConstValType);

	  if isError then exit;

	  CheckTok(j + 1, CPARTOK);

	  ConstValType := Tok[i].Kind;

	  i := j + 1;
	end;

	end
    else
      Error(i, TErrorCode.UnknownIdentifier);

    Result := i;
    end;


  ADDRESSTOK:
    if Tok[i + 1].Kind <> IDENTTOK then
      Error(i + 1, TErrorCode.IdentifierExpected)
    else begin
      IdentIndex := GetIdentIndex(Tok[i + 1].Name);

      if IdentIndex > 0 then begin

	case Ident[IdentIndex].Kind of
	  CONSTANT: if not( (Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0) ) then
	   	      Error(i + 1, TErrorCode.CantAdrConstantExp)
		    else
		      ConstVal := Ident[IdentIndex].Value - CODEORIGIN;

	  VARIABLE: if Ident[IdentIndex].isAbsolute then begin				// wyjatek gdy ABSOLUTE

		     if (Ident[IdentIndex].Value and $ff = 0) and (byte((Ident[IdentIndex].Value shr 24) and $7f) in [1..127]) or
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0..1])) then
		     begin

			isError := true;
			exit(0);

		     end else begin
	   	      ConstVal := Ident[IdentIndex].Value;

		      if ConstVal < 0 then begin
			isError := true;
			exit(0);
		      end;

		     end;


		    end else begin

		     if isConst then begin isError:=true; exit end;			// !!! koniecznie zamiast Error !!!

			ConstVal := Ident[IdentIndex].Value - DATAORIGIN;

			ConstValType := DATAORIGINOFFSET;

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,' / ',ConstVal);

	if (Ident[IdentIndex].DataType in Pointers) and					// zadziala tylko dla ABSOLUTE
	   (Ident[IdentIndex].NumAllocElements > 0) and
	   (Tok[i + 2].Kind = OBRACKETTOK)  then
	   begin
		j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);			// Array index [xx,

		if isError then Exit;

		CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

		if Tok[j + 1].Kind = COMMATOK then begin
    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType] * Ident[IdentIndex].NumAllocElements_);

		 j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);		// Array index ,yy]

		 if isError then Exit;

		 CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);
		end else
		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);

		i := j;

		CheckTok(i + 1, CBRACKETTOK);
	   end;
			Result := i + 1;

			exit;

		    end;
	else

              Error(i + 1, TMessage.Create(TErrorCode.CantTakeAddressOfIdentifier, 'Can''t take the address of ' +
                InfoAboutToken(Ident[IdentIndex].Kind)));

	end;

	if (Ident[IdentIndex].DataType in Pointers) and					// zadziala tylko dla ABSOLUTE
	   (Ident[IdentIndex].NumAllocElements > 0) and
	   (Tok[i + 2].Kind = OBRACKETTOK)  then
	   begin
		j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);			// Array index [xx,

		if isError then Exit;

		CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

		if Tok[j + 1].Kind = COMMATOK then begin
    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType] * Ident[IdentIndex].NumAllocElements_);

		 j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);		// Array index ,yy]

		 if isError then Exit;

		 CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

    		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);
		end else
		 inc(ConstVal, ArrayIndex * DataSize[Ident[IdentIndex].AllocElementType]);

		i := j;

		CheckTok(i + 1, CBRACKETTOK);
	   end;

	ConstValType := POINTERTOK;

       end else
	Error(i + 1, TErrorCode.UnknownIdentifier);

    Result := i + 1;
    end;


  INTNUMBERTOK:
    begin
     ConstVal := Tok[i].Value;
     ConstValType := GetValueType(ConstVal);

     Result := i;
    end;


  FRACNUMBERTOK:
    begin
     ConstVal := FromSingle(Tok[i].FracValue);
     ConstValType := REALTOK;

     Result := i;
    end;


  STRINGLITERALTOK:
    begin
     ConstVal := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
     ConstValType := STRINGPOINTERTOK;

     Result := i;
    end;


  CHARLITERALTOK:
    begin
     ConstVal := Tok[i].Value;
     ConstValType := CHARTOK;

     Result := i;
    end;


  OPARTOK:       // a whole expression in parentheses suspected
    begin
     j := CompileConstExpression(i + 1, ConstVal, ConstValType);

     if isError then Exit;

     CheckTok(j + 1, CPARTOK);

     Result := j + 1;
    end;


  NOTTOK:
    begin
    Result := CompileConstFactor(i + 1, ConstVal, ConstValType);

    if isError then Exit;

    if ConstValType = BOOLEANTOK then
     ConstVal := ord(not (ConstVal <> 0) )

    else begin
     ConstVal := not ConstVal;
     ConstValType := GetValueType(ConstVal);
    end;

    end;


  SHORTREALTOK, REALTOK, SINGLETOK, HALFSINGLETOK:			// Q8.8 ; Q24.8 ; SINGLE 32bit ; FLOAT16
    begin

    CheckTok(i + 1, OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    if not(ConstValType in RealTypes) then ConstVal:=FromInt64(ConstVal);

    CheckTok(j + 1, CPARTOK);

    ConstValType := Tok[i].Kind;

    Result := j + 1;

    end;


  INTEGERTOK, CARDINALTOK, SMALLINTTOK, WORDTOK, CHARTOK, PCHARTOK, SHORTINTTOK, BYTETOK, BOOLEANTOK, POINTERTOK, STRINGPOINTERTOK:	// type conversion operations
    begin

    CheckTok(i + 1, OPARTOK);


    if (Tok[i + 2].Kind = IDENTTOK) and (Ident[GetIdentIndex(Tok[i + 2].Name)].Kind = FUNCTIONTOK) then
     isError := TRUE
    else
     j := CompileConstExpression(i + 2, ConstVal, ConstValType);


    if isError then exit;


    if (ConstValType in Pointers) and (Tok[i + 2].Kind = IDENTTOK) and (Tok[i + 3].Kind <> OBRACKETTOK) then begin

      IdentIndex := GetIdentIndex(Tok[i + 2].Name);

      if (Ident[IdentIndex].DataType in Pointers) and ( (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> RECORDTOK) ) then
       if ((Ident[IdentIndex].AllocElementType <> UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0,1])) or (Ident[IdentIndex].DataType = STRINGPOINTERTOK) then begin

       end else
	ErrorIdentifierIllegalTypeConversion(i + 2, IdentIndex, Tok[i].Kind);

    end;


    CheckTok(j + 1, CPARTOK);

    if ConstValType in [DATAORIGINOFFSET, CODEORIGINOFFSET] then OldConstValType := ConstValType;

    ConstValType := Tok[i].Kind;

    Result := j + 1;
    end;


else
  Error(i, TErrorCode.IdNumExpExpected);

end;// case

end;	//CompileConstFactor


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstTerm(i: Integer; out ConstVal: Int64; out ConstValType: TDatatype): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
begin

ConstVal:=0;
ConstValType:=0;
Result:=i;

j := CompileConstFactor(i, ConstVal, ConstValType);

if isError then Exit;

while Tok[j + 1].Kind in [MULTOK, DIVTOK, MODTOK, IDIVTOK, SHLTOK, SHRTOK, ANDTOK] do
  begin

  k := CompileConstFactor(j + 2, RightConstVal, RightConstValType);

  if isError then Break;


  if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then begin
  RightConstVal:=FromInt64(RightConstVal);
   RightConstValType := ConstValType;
  end;

  if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then begin
   ConstVal:=FromInt64(ConstVal);
   ConstValType := RightConstValType;
  end;


  if (Tok[j + 1].Kind = DIVTOK) and (ConstValType in IntegerTypes) then begin
   ConstVal:=FromInt64(ConstVal);
   ConstValType := REALTOK;
  end;

  if (Tok[j + 1].Kind = DIVTOK) and (RightConstValType in IntegerTypes) then begin
   RightConstVal:=FromInt64(RightConstVal);
   RightConstValType := REALTOK;
  end;


  if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (RightConstValType in [SHORTREALTOK, REALTOK]) then
   RightConstValType := ConstValType;

  if (RightConstValType in [SINGLETOK, HALFSINGLETOK]) and (ConstValType in [SHORTREALTOK, REALTOK]) then
   ConstValType := RightConstValType;


  case Tok[j + 1].Kind of

    MULTOK:  ConstVal:=Multiply(ConstValType, ConstVal,RightConstVal);

    DIVTOK:  begin
               try
                 ConstVal:=Divide(ConstValType, ConstVal,RightConstVal);
               except On EDivByZero do
                 begin
                   isError := false;
		   isConst := false;
		   Error(i, TMessage.Create(TErrorCode.DivisionByZero, 'Division by zero'));
                 end;
               end;
             end;

    MODTOK:  ConstVal := ConstVal mod RightConstVal;
   IDIVTOK:  ConstVal := ConstVal div RightConstVal;
    SHLTOK:  ConstVal := ConstVal shl RightConstVal;
    SHRTOK:  ConstVal := ConstVal shr RightConstVal;
    ANDTOK:  ConstVal := ConstVal and RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes + [BOOLEANTOK]) then
   ConstValType := GetValueType(ConstVal);

  CheckOperator(i, Tok[j + 1].Kind, ConstValType, RightConstValType);

  j := k;
  end;

 Result := j;
end;	//CompileConstTerm


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileSimpleConstExpression(const i: Integer; out ConstVal: Int64; out ConstValType: Byte): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;

begin

ConstVal:=0;
ConstValType:=0;
Result:=i;

if Tok[i].Kind in [PLUSTOK, MINUSTOK] then j := i + 1 else j := i;
j := CompileConstTerm(j, ConstVal, ConstValType);

if isError then exit;


if Tok[i].Kind = MINUSTOK then begin

 ConstVal:=Negate(ConstValType, ConstVal);

end;


 while Tok[j + 1].Kind in [PLUSTOK, MINUSTOK, ORTOK, XORTOK] do begin

  k := CompileConstTerm(j + 2, RightConstVal, RightConstValType);

  if isError then Break;


//  if (ConstValType = POINTERTOK) and (RightConstValType in IntegerTypes) then RightConstValType := ConstValType;


  if (ConstValType in RealTypes) and (RightConstValType in IntegerTypes) then begin
   RightConstVal:=FromInt64(RightConstVal);
   RightConstValType := ConstValType;
  end;

  if (ConstValType in IntegerTypes) and (RightConstValType in RealTypes) then begin
   ConstVal:=FromInt64(ConstVal);
   ConstValType := RightConstValType;
  end;

  if (ConstValType in [SINGLETOK, HALFSINGLETOK]) and (RightConstValType in [SHORTREALTOK, REALTOK]) then
   RightConstValType := ConstValType;

  if (RightConstValType in [SINGLETOK, HALFSINGLETOK]) and (ConstValType in [SHORTREALTOK, REALTOK]) then
   ConstValType := RightConstValType;


  case Tok[j + 1].Kind of
    PLUSTOK:  ConstVal := Add( ConstValType, ConstVal, RightConstVal);

    MINUSTOK: ConstVal := Subtract( ConstValType, ConstVal, RightConstVal);

    ORTOK:    ConstVal := ConstVal or RightConstVal;
    XORTOK:   ConstVal := ConstVal xor RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes + [BOOLEANTOK]) then
   ConstValType := GetValueType(ConstVal);

  CheckOperator(i, Tok[j + 1].Kind, ConstValType, RightConstValType);

  j := k;
 end;

Result := j;
end;	//CompileSimpleConstExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstExpression(i: Integer; out ConstVal: Int64; out ConstValType: Byte; const VarType: Byte = INTEGERTOK; const Err: Boolean = false; const War: Boolean = True): Integer;
var
  j: Integer;
  RightConstVal: Int64;
  RightConstValType: Byte;
  Yes: Boolean;
begin

ConstVal:=0;
ConstValType:=0;
Result:=i;

i := CompileSimpleConstExpression(i, ConstVal, ConstValType);

if isError then exit;

if Tok[i + 1].Kind in [EQTOK, NETOK, LTTOK, LETOK, GTTOK, GETOK] then
  begin

  j := CompileSimpleConstExpression(i + 2, RightConstVal, RightConstValType);
//  CheckOperator(i, Tok[j + 1].Kind, ConstValType);

  case Tok[i + 1].Kind of
    EQTOK: Yes := ConstVal =  RightConstVal;
    NETOK: Yes := ConstVal <> RightConstVal;
    LTTOK: Yes := ConstVal <  RightConstVal;
    LETOK: Yes := ConstVal <= RightConstVal;
    GTTOK: Yes := ConstVal >  RightConstVal;
    GETOK: Yes := ConstVal >= RightConstVal;
  else
   yes := false;
  end;

  if Yes then ConstVal := $ff else ConstVal := 0;
//  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  ConstValType := BOOLEANTOK;

  i := j;
  end;


 Result := i;

 if ConstValType in OrdinalTypes + Pointers then
 if VarType in OrdinalTypes + Pointers then begin

  case VarType of
   SHORTINTTOK: Yes := (ConstVal < Low(shortint)) or (ConstVal > High(shortint));
   SMALLINTTOK: Yes := (ConstVal < Low(smallint)) or (ConstVal > High(smallint));
    INTEGERTOK: Yes := (ConstVal < Low(integer)) or (ConstVal > High(integer));
  else
   Yes := (abs(ConstVal) > $FFFFFFFF) or (DataSize[ConstValType] > DataSize[VarType]) or ((ConstValType in SignedOrdinalTypes) and (VarType in UnsignedOrdinalTypes));
  end;

 if Yes then
  if Err then begin
   isConst := false;
   isError := false;
   ErrorRangeCheckError(i, 0, ConstVal, VarType);
  end else
   if War then
   if VarType <> BOOLEANTOK then
    WarningForRangeCheckError(i, 0, ConstVal, VarType);

 end;

end;	//CompileConstExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure DefineIdent(const tokenIndex: TTokenIndex; Name: TIdentifierName; Kind: TTokenKind; DataType: TDataType;
  NumAllocElements: Cardinal; AllocElementType: TDataType; Data: Int64; IdType: TDataType = IDENTTOK);
var
  identIndex: Integer;
  NumAllocElements_ : Cardinal;
begin

identIndex := GetIdentIndex(Name);

if (i > 0) and (not (Ident[identIndex].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]))
           and (Ident[identIndex].Block = BlockStack[BlockStackTop])
           and (Ident[identIndex].isOverload = false)
           and (Ident[i].UnitIndex = UnitNameIndex) then
    Error(tokenIndex, TMessage.Create(TErrorCode.IdentifierAlreadyDefined, 'Identifier ' +
      Name + ' is already defined'))
else
  begin

  Inc(NumIdent);

  // For debugging
  // Writeln('NumIdent='+IntToStr(NumIdent)+' ErrTokenIndex='+IntToStr(ErrTokenIndex)+' Name='+name+' Kind='+IntToStr( Kind)+' DataType='+IntToStr( DataType)+' NumAllocElements='+IntToStr( NumAllocElements)+' AllocElementType='+IntToStr( AllocElementType));

  if NumIdent > High(Ident) then
    Error(NumTok, TMessage.Create(TErrorCode.OutOfResources,'Out of resources, IDENT'));

  Ident[NumIdent].Name := Name;
  Ident[NumIdent].Kind := Kind;
  Ident[NumIdent].DataType := DataType;
  Ident[NumIdent].Block := BlockStack[BlockStackTop];
  Ident[NumIdent].NumParams := 0;
  Ident[NumIdent].isAbsolute := false;
  Ident[NumIdent].PassMethod := TParameterPassingMethod.VALPASSING;
  Ident[NumIdent].IsUnresolvedForward := false;

  Ident[NumIdent].Section := PublicSection;

  Ident[NumIdent].UnitIndex := UnitNameIndex;

  Ident[NumIdent].IdType := IdType;

  if (Kind = VARIABLE) and (Data <> 0) then begin
   Ident[NumIdent].isAbsolute := true;
   Ident[NumIdent].isInit := true;
  end;

   NumAllocElements_ := NumAllocElements shr 16;		// , yy]
   NumAllocElements  := NumAllocElements and $FFFF;		// [xx,


//   if name = 'CH_EOL' then writeln( Ident[NumIdent].Block ,',', Ident[NumIdent].unitindex, ',',  Ident[NumIdent].Section,',', Ident[NumIdent].idType);

  if Name <> 'RESULT' then
   if (NumIdent > NumPredefIdent + 1) and (UnitNameIndex = 1) and (pass = TPass.CODE_GENERATION) then
     if not ( (Ident[NumIdent].Pass in [ TPass.CALL_DETERMINATION , TPass.CODE_GENERATION]) or (Ident[NumIdent].IsNotDead) ) then
      NoteForIdentifierNotUsed(tokenIndex, NumIdent);

  case Kind of

    PROCEDURETOK, FUNCTIONTOK, UNITTYPE, CONSTRUCTORTOK, DESTRUCTORTOK:
      begin
      Ident[NumIdent].Value := CodeSize;			// Procedure entry point address
//      Ident[NumIdent].Section := true;
      end;

    VARIABLE:
      begin

      if Ident[NumIdent].isAbsolute then
       Ident[NumIdent].Value := Data - 1
      else
       Ident[NumIdent].Value := DATAORIGIN + VarDataSize;	// Variable address

      if not OutputDisabled then
	VarDataSize := VarDataSize + DataSize[DataType];

      Ident[NumIdent].NumAllocElements := NumAllocElements;	// Number of array elements (0 for single variable)
      Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

      Ident[NumIdent].AllocElementType := AllocElementType;

      if not OutputDisabled then begin

       if (DataType = POINTERTOK) and (AllocElementType in [RECORDTOK, OBJECTTOK]) and (NumAllocElements_ = 0) then
        inc(VarDataSize, DataSize[POINTERTOK])
       else

       if DataType in [ENUMTYPE] then
        inc(VarDataSize)
       else
       if (DataType in [RECORDTOK, OBJECTTOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 0
       else
       if (DataType in [FILETOK, TEXTFILETOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 12
       else begin

        if (Ident[NumIdent].idType = ARRAYTOK) and (Ident[NumIdent].isAbsolute = false) and (Elements(NumIdent) = 1) then	// [0..0] ; [0..0, 0..0]

	else
          if ( Low(DataSize) <= AllocElementType ) and  ( AllocElementType <= High(DataSize) ) then
          begin
 	    VarDataSize := VarDataSize + integer(Elements(NumIdent) * DataSize[AllocElementType]);
          end;

       end;


       if NumAllocElements > 0 then dec(VarDataSize, DataSize[DataType]);

      end;

      end;

    CONSTANT, ENUMTYPE:
      begin
      Ident[NumIdent].Value := Data;				// Constant value

      if DataType in Pointers + [ENUMTOK] then begin
       Ident[NumIdent].NumAllocElements := NumAllocElements;
       Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

       Ident[NumIdent].AllocElementType := AllocElementType;
      end;

      Ident[NumIdent].isInit := true;
      end;

    USERTYPE:
      begin
       Ident[NumIdent].NumAllocElements := NumAllocElements;
       Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

       Ident[NumIdent].AllocElementType := AllocElementType;
      end;

    LABELTYPE:
      begin
       Ident[NumIdent].isInit := false;
      end;

  end;// case
  end;// else

end;	//DefineIdent


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function DeclareFunction(i: integer; out ProcVarIndex: cardinal): integer;
var  VarOfSameType: TVariableList;
     NumVarOfSameType, VarOfSameTypeIndex, x: Integer;
     ListPassMethod: TParameterPassingMethod;
     VarType, AllocElementType: Byte;
     NumAllocElements: cardinal;
     IsNestedFunction: Boolean;
//     ConstVal: Int64;

begin

      //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
      VarOfSameType:=Default(TVariableList);

      inc(NumProc);

      if Tok[i].Kind in [PROCEDURETOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
	begin
	DefineIdent(i, '@FN' + IntToHex(NumProc, 4), Tok[i].Kind, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i, '@FN' + IntToHex(NumProc, 4), FUNCTIONTOK, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;

      NumVarOfSameType := 0;
      ProcVarIndex := NumProc;			// -> NumAllocElements_

      dec(i);

      if (Tok[i + 2].Kind = OPARTOK) and (Tok[i + 3].Kind = CPARTOK) then inc(i, 2);

      if Tok[i + 2].Kind = OPARTOK then						// Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := TParameterPassingMethod.VALPASSING;

	  if Tok[i + 1].Kind = CONSTTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = VARTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> IDENTTOK then
          Error(i + 1, TMessage.Create(TErrorCode.FormalParameterNameExpected,
            'Formal parameter name expected but {0} found.', GetSpelling(i + 1)))
	    else
	      begin

		for x := 1 to NumVarOfSameType do
		 if VarOfSameType[x].Name = Tok[i + 1].Name then
              Error(i + 1, TMessage.Create(TErrorCode.IdentifierAlreadyDefined,
                'Identifier {0}is already defined.', Tok[i + 1].Name));

	        Inc(NumVarOfSameType);
	        VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name;
	      end;

	    i := i + 2;
	    until Tok[i].Kind <> COMMATOK;


	  VarType := 0;								// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING])  and (Tok[i].Kind <> COLONTOK) then begin

	   ListPassMethod := TParameterPassingMethod.VARPASSING;
	   dec(i);

	  end else begin

	   CheckTok(i, COLONTOK);

	   if Tok[i + 1].Kind = DEREFERENCETOK then				// ^type
          Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
	     Error(i, TMessage.Create(TErrorCode.FileParameterMustBeVAR, 'File parameters must be var parameters'));

	  end;


	  for VarOfSameTypeIndex := 1 to NumVarOfSameType do
	    begin

//	    if NumAllocElements > 0 then
//	      Error(i, 'Structured parameters cannot be passed by value');

	    Inc(Ident[NumIdent].NumParams);
	    if Ident[NumIdent].NumParams > MAXPARAMS then
	      ErrorForIdentifier(i, TErrorCode.TooManyParameters, NumIdent)
	    else
	      begin
	      VarOfSameType[VarOfSameTypeIndex].DataType			:= VarType;

	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].DataType		:= VarType;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].Name		:= VarOfSameType[VarOfSameTypeIndex].Name;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].NumAllocElements := NumAllocElements;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].AllocElementType := AllocElementType;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].PassMethod       := ListPassMethod;

	      end;
	    end;

	  i := i + 1;
	until Tok[i].Kind <> SEMICOLONTOK;

	CheckTok(i, CPARTOK);

	i := i + 1;
	end// if Tok[i + 2].Kind = OPARTOR
      else
	i := i + 2;

      if IsNestedFunction then
	begin

	CheckTok(i, COLONTOK);

	if Tok[i + 1].Kind = ARRAYTOK then
      Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

	i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	Ident[NumIdent].DataType := VarType;					// Result
	Ident[NumIdent].NestedFunctionNumAllocElements := NumAllocElements;
	Ident[NumIdent].NestedFunctionAllocElementType := AllocElementType;

	i := i + 1;
	end;// if IsNestedFunction


    Ident[NumIdent].isStdCall := true;
    Ident[NumIdent].IsNestedFunction := IsNestedFunction;

    Result := i;

end;	//DeclareFunction


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function DefineFunction(i, ForwardIdentIndex: integer; out isForward, isInt, isInl, isOvr: Boolean; var IsNestedFunction: Boolean; out NestedFunctionResultType: Byte; out NestedFunctionNumAllocElements: cardinal; out NestedFunctionAllocElementType: Byte): integer;
var  VarOfSameType: TVariableList;
     NumVarOfSameType, VarOfSameTypeIndex, x: Integer;
     ListPassMethod: TParameterPassingMethod;
     VarType, AllocElementType: Byte;
     NumAllocElements: cardinal;
begin

    //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
    VarOfSameType:=Default(TVariableList);

    if ForwardIdentIndex = 0 then begin

      if Tok[i + 1].Kind <> IDENTTOK then
	Error(i + 1, TMessage.Create(TErrorCode.ReservedWordUserAsIdentifier, 'Reserved word used as identifier'));

      if Tok[i].Kind in [PROCEDURETOK, CONSTRUCTORTOK, DESTRUCTORTOK] then
	begin
	DefineIdent(i + 1, Tok[i + 1].Name, Tok[i].Kind, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i + 1, Tok[i + 1].Name, FUNCTIONTOK, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;


      NumVarOfSameType := 0;

      if (Tok[i + 2].Kind = OPARTOK) and (Tok[i + 3].Kind = CPARTOK) then inc(i, 2);

      if Tok[i + 2].Kind = OPARTOK then						// Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := TParameterPassingMethod.VALPASSING;

	  if Tok[i + 1].Kind = CONSTTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = VARTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> IDENTTOK then
            Error(i + 1, TMessage.Create(TErrorCode.FormalParameterNameExpected,
              'Formal parameter name expected but {0} found.', GetSpelling(i + 1)))
	    else
	      begin

		for x := 1 to NumVarOfSameType do
		 if VarOfSameType[x].Name = Tok[i + 1].Name then
		   Error(i + 1, TMessage.Create(TErrorCode.IdentifierAlreadyDefined, 'Identifier {0} is already defined.',Tok[i + 1].Name));

	        Inc(NumVarOfSameType);
	        VarOfSameType[NumVarOfSameType].Name := Tok[i + 1].Name;
	      end;

	    i := i + 2;
	    until Tok[i].Kind <> COMMATOK;


	  VarType := 0;								// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING])  and (Tok[i].Kind <> COLONTOK) then begin

	   ListPassMethod := TParameterPassingMethod.VARPASSING;
	   dec(i);

	  end else begin

	   CheckTok(i, COLONTOK);

	   if Tok[i + 1].Kind = DEREFERENCETOK then				// ^type
	     Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
            Error(i, TMessage.Create(TErrorCode.FileParameterMustBeVar, 'File parameters must be var parameters'));

	  end;


	  for VarOfSameTypeIndex := 1 to NumVarOfSameType do
	    begin

//	    if NumAllocElements > 0 then
//	      Error(i, 'Structured parameters cannot be passed by value');

	    Inc(Ident[NumIdent].NumParams);
	    if Ident[NumIdent].NumParams > MAXPARAMS then
	      ErrorForIdentifier(i, TErrorCode.TooManyParameters, NumIdent)
	    else
	      begin
	      VarOfSameType[VarOfSameTypeIndex].DataType			:= VarType;

	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].DataType		:= VarType;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].Name		:= VarOfSameType[VarOfSameTypeIndex].Name;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].NumAllocElements := NumAllocElements;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].AllocElementType := AllocElementType;
	      Ident[NumIdent].Param[Ident[NumIdent].NumParams].PassMethod       := ListPassMethod;

	      end;
	    end;

	  i := i + 1;
	until Tok[i].Kind <> SEMICOLONTOK;

	CheckTok(i, CPARTOK);

	i := i + 1;
	end// if Tok[i + 2].Kind = OPARTOR
      else
	i := i + 2;

      NestedFunctionResultType := 0;
      NestedFunctionNumAllocElements := 0;
      NestedFunctionAllocElementType := 0;

      if IsNestedFunction then
	begin

	CheckTok(i, COLONTOK);

	if Tok[i + 1].Kind = ARRAYTOK then
	 Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

	i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	NestedFunctionResultType := VarType;

//	if Tok[i].Kind = PCHARTOK then NestedFunctionResultType := PCHARTOK;

	Ident[NumIdent].DataType := NestedFunctionResultType;			// Result

	NestedFunctionNumAllocElements := NumAllocElements;
	Ident[NumIdent].NestedFunctionNumAllocElements := NumAllocElements;

	NestedFunctionAllocElementType := AllocElementType;
	Ident[NumIdent].NestedFunctionAllocElementType := AllocElementType;

	Ident[NumIdent].isNestedFunction := true;

	i := i + 1;
	end;// if IsNestedFunction

    CheckTok(i, SEMICOLONTOK);

    end; //if ForwardIdentIndex = 0


    isForward := false;
    isInt := false;
    isInl := false;
    isOvr := false;

	while Tok[i + 1].Kind in [OVERLOADTOK, ASSEMBLERTOK, FORWARDTOK, REGISTERTOK, INTERRUPTTOK, PASCALTOK, STDCALLTOK, INLINETOK, EXTERNALTOK, KEEPTOK] do begin

	  case Tok[i + 1].Kind of

	    OVERLOADTOK: begin
	       		   isOvr := true;
			   Ident[NumIdent].isOverload := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   ASSEMBLERTOK: begin
			   Ident[NumIdent].isAsm := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	     FORWARDTOK: begin

			   if INTERFACETOK_USE then
			    if IsNestedFunction then
			     Error(i, TMessage.Create(TErrorCode.FunctionDirectiveForwardNotAllowedInInterfaceSection, 'Function directive ''FORWARD'' not allowed in interface section'))
			    else
			     Error(i, TMessage.Create(TErrorCode.ProcedureDirectiveForwardNotAllowedInInterfaceSection, 'Procedure directive ''FORWARD'' not allowed in interface section'));

			   isForward := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	    REGISTERTOK: begin
			   Ident[NumIdent].isRegister := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	     STDCALLTOK: begin
			   Ident[NumIdent].isStdCall := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	     INLINETOK: begin
	                   isInl := true;
			   Ident[NumIdent].isInline := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	   INTERRUPTTOK: begin
			   isInt := true;
			   Ident[NumIdent].isInterrupt := true;
			   Ident[NumIdent].IsNotDead := true;		// zawsze wygeneruj kod dla przerwania
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	      PASCALTOK: begin
			   Ident[NumIdent].isRecursion := true;
			   Ident[NumIdent].isPascal := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	    EXTERNALTOK: begin
			   Ident[NumIdent].isExternal := true;
			   isForward := true;
			   inc(i);

			   Ident[NumIdent].Alias := '';
			   Ident[NumIdent].Libraries := 0;

			   if Tok[i + 1].Kind = IDENTTOK then begin

			    Ident[NumIdent].Alias := Tok[i + 1].Name;

			    if Tok[i + 2].Kind = STRINGLITERALTOK then begin
			      Ident[NumIdent].Libraries := i + 2;

			      inc(i);
			    end;

			    inc(i);

			   end else
			   if Tok[i + 1].Kind = STRINGLITERALTOK then begin

			     Ident[NumIdent].Alias := Ident[NumIdent].Name;
			     Ident[NumIdent].Libraries := i + 1;

			     inc(i);
			   end;

			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

                 KEEPTOK: begin
			   Ident[NumIdent].isKeep := true;
			   Ident[NumIdent].IsNotDead := true;
			   inc(i);
			   CheckTok(i + 1, SEMICOLONTOK);
			 end;

	  end;

	  inc(i);
	end;// while


  if Ident[NumIdent].isRegister and (Ident[NumIdent].isPascal or Ident[NumIdent].isRecursion) then
   Error(i, TMessage.Create(TErrorCode.CannotCombineRegisterWithPascal, 'Calling convention directive "REGISTER" not applicable with "PASCAL"'));

  if Ident[NumIdent].isInline and (Ident[NumIdent].isPascal or Ident[NumIdent].isRecursion)  then
   Error(i, TMessage.Create(TErrorCode.CannotCombineInlineWithPascal, 'Calling convention directive "INLINE" not applicable with "PASCAL"'));

  if Ident[NumIdent].isInline and (Ident[NumIdent].isInterrupt) then
   Error(i, TMessage.Create(TErrorCode.CannotCombineInlineWithInterrupt, 'Procedure directive "INLINE" cannot be used with "INTERRUPT"'));

  if Ident[NumIdent].isInline and (Ident[NumIdent].isExternal) then
   Error(i, TMessage.Create(TErrorCode.CannotCombineInlineWithExternal,'Procedure directive "INLINE" cannot be used with "EXTERNAL"'));

//  if Ident[NumIdent].isInterrupt and (Ident[NumIdent].isAsm = false) then
//    Note(i, 'Use assembler block instead pascal');

 Result := i;

end;	//DefineFunction


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileType(i: TTokenIndex; out DataType: TDatatype; out NumAllocElements: cardinal; out AllocElementType: Byte): TTokenIndex;
var
  NestedNumAllocElements, NestedFunctionNumAllocElements: cardinal;
  LowerBound, UpperBound, ConstVal, IdentIndex: Int64;
  NumFieldsInList, FieldInListIndex, RecType, k, j: integer;
  NestedDataType, ExpressionType, NestedAllocElementType, NestedFunctionAllocElementType, NestedFunctionResultType: Byte;
  FieldInListName: array [1..MAXFIELDS] of TField;
  ExitLoop, isForward, IsNestedFunction, isInt, isInl, isOvr: Boolean;
  Name: TString;


  function BoundaryType: Byte;
  begin

    if (LowerBound < 0) or (UpperBound < 0) then begin

     if (LowerBound >= Low(shortint)) and (UpperBound <= High(shortint)) then Result := SHORTINTTOK else
      if (LowerBound >= Low(smallint)) and (UpperBound <= High(smallint)) then Result := SMALLINTTOK else
	Result := INTEGERTOK;

    end else begin

     if (LowerBound >= Low(byte)) and (UpperBound <= High(byte)) then Result := BYTETOK else
      if (LowerBound >= Low(word)) and (UpperBound <= High(word)) then Result := WORDTOK else
	Result := CARDINALTOK;

    end;

  end;


  procedure DeclareField(const Name: TName; FieldType: Byte; NumAllocElements: cardinal = 0; AllocElementType: Byte = 0; Data: Int64 = 0);
  var x: Integer;
  begin

   for x := 1 to TypeArray[RecType].NumFields do
     if TypeArray[RecType].Field[x].Name = Name then
       Error(i, TMessage.Create(TErrorCode.DuplicateIdentifier, 'Duplicate identifier ''{0}''.', Name ));

   // Add new field
   Inc(TypeArray[RecType].NumFields);

   x:=TypeArray[RecType].NumFields;

   if x >= MAXFIELDS then
      Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXFIELDS'));


   if FieldType = DEREFERENCEARRAYTOK then begin
    FieldType := POINTERTOK;
    AllocElementType := 0;
    NumAllocElements := 0;
   end;


   // Add new field
   TypeArray[RecType].Field[x].Name := Name;
   TypeArray[RecType].Field[x].DataType := FieldType;
   TypeArray[RecType].Field[x].Value := Data;
   TypeArray[RecType].Field[x].AllocElementType := AllocElementType;
   TypeArray[RecType].Field[x].NumAllocElements := NumAllocElements;


//   writeln('>> ',Name,',',FieldType,',',AllocElementType,',',NumAllocElements);


   if not (FieldType in [RECORDTOK, OBJECTTOK]) then begin

    if FieldType in Pointers then begin

     if (FieldType = POINTERTOK) and (AllocElementType = FORWARDTYPE) then
      inc(TypeArray[RecType].Size, DataSize[POINTERTOK])
     else
     if NumAllocElements shr 16 > 0 then
      inc(TypeArray[RecType].Size, (NumAllocElements shr 16) * (NumAllocElements and $FFFF) * DataSize[AllocElementType])
     else
      inc(TypeArray[RecType].Size, NumAllocElements * DataSize[AllocElementType]);

    end else
     inc(TypeArray[RecType].Size, DataSize[FieldType]);

   end else
    inc(TypeArray[RecType].Size, DataSize[FieldType]);

   TypeArray[RecType].Field[x].Kind := 0;

  end;


begin

NumAllocElements := 0;

// -----------------------------------------------------------------------------
//				PROCEDURE, FUNCTION
// -----------------------------------------------------------------------------

if Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK] then begin		// PROCEDURE, FUNCTION

  DataType := POINTERTOK;
  AllocElementType := PROCVARTOK;

  i := DeclareFunction(i, NestedNumAllocElements);

  NumAllocElements := NestedNumAllocElements shl 16;	// NumAllocElements = NumProc shl 16

  Result := i - 1;

end else

// -----------------------------------------------------------------------------
//				^TYPE
// -----------------------------------------------------------------------------

if Tok[i].Kind = DEREFERENCETOK then begin				// ^type

 DataType := POINTERTOK;

 if Tok[i + 1].Kind = STRINGTOK then begin				// ^string
  NumAllocElements := 0;
  AllocElementType := CHARTOK;
  DataType := STRINGPOINTERTOK;
 end else
 if Tok[i + 1].Kind = IDENTTOK then begin

  IdentIndex := GetIdentIndex(Tok[i + 1].Name);

  if IdentIndex = 0 then begin

   NumAllocElements  := i + 1;
   AllocElementType  := FORWARDTYPE;

  end else

  if (IdentIndex > 0) and (Ident[IdentIndex].DataType in [RECORDTOK, OBJECTTOK] + Pointers) then begin
    NumAllocElements := Ident[IdentIndex].NumAllocElements;

//	writeln(Ident[IdentIndex].Name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,',',Ident[IdentIndex].NumAllocElements,',',Ident[IdentIndex].NumAllocElements_ shl 16 );

{
    if Ident[IdentIndex].DataType in Pointers then begin
     AllocElementType := Ident[IdentIndex].AllocElementType;

     if Ident[IdentIndex].NumAllocElements_ > 0 then		// wymuszamy dostep przez wskaznik
      NumAllocElements := 1 or (1 shl 16)			// [0..0, 0..0]
     else
      NumAllocElements := 1;					// [0..0]
}

    if Ident[IdentIndex].DataType in Pointers then begin

     if Ident[IdentIndex].DataType = STRINGPOINTERTOK then begin
       NumAllocElements := 0;
       AllocElementType := CHARTOK;
       DataType := STRINGPOINTERTOK;
     end else begin
       NumAllocElements := Ident[IdentIndex].NumAllocElements or (Ident[IdentIndex].NumAllocElements_ shl 16);
       AllocElementType := Ident[IdentIndex].AllocElementType;
       DataType := DEREFERENCEARRAYTOK;
     end;

    end else begin
     NumAllocElements := Ident[IdentIndex].NumAllocElements or (Ident[IdentIndex].NumAllocElements_ shl 16);
     AllocElementType := Ident[IdentIndex].DataType;
    end;

  end;


//  writeln('= ', NumAllocElements and $FFFF,',',NumAllocElements shr 16,' | ',DataType,',',AllocElementType);

 end else begin

  if not (Tok[i + 1].Kind in OrdinalTypes + RealTypes + [POINTERTOK]) then
   Error(i + 1, TErrorCode.IdentifierExpected);

  NumAllocElements := 0;
  AllocElementType := Tok[i + 1].Kind;

 end;

  Result := i + 1;

end else

// -----------------------------------------------------------------------------
//				ENUM
// -----------------------------------------------------------------------------

if Tok[i].Kind = OPARTOK then begin					// enumerated

    Name := Tok[i-2].Name;

    inc(NumTypes);
    RecType := NumTypes;

    if NumTypes > MAXTYPES then
      Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

    inc(i);

    TypeArray[RecType].Field[0].Name := Name;
    TypeArray[RecType].NumFields := 0;

    ConstVal := 0;
    LowerBound := 0;
    UpperBound := 0;
    NumFieldsInList := 0;

    repeat
      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name;

      inc(i);

      if Tok[i].Kind in [ASSIGNTOK, EQTOK] then begin

	i := CompileConstExpression(i + 1, ConstVal, ExpressionType);
//	GetCommonType(i, ConstValType, SelectorType);

	inc(i);
      end;

      FieldInListName[NumFieldsInList].Value := ConstVal;

      if NumFieldsInList = 1 then begin

       LowerBound := ConstVal;
       UpperBound := ConstVal;

      end else begin

       if ConstVal < LowerBound then LowerBound := ConstVal;
       if ConstVal > UpperBound then UpperBound := ConstVal;

       if FieldInListName[NumFieldsInList].Value < FieldInListName[NumFieldsInList - 1].Value then
	 Note(i, 'Values in enumeration types have to be ascending');

      end;

      inc(ConstVal);

      if Tok[i].Kind = COMMATOK then inc(i);

    until Tok[i].Kind = CPARTOK;

    DataType := BoundaryType;

    for FieldInListIndex := 1 to NumFieldsInList do begin
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, ENUMTYPE, DataType, 0, 0, FieldInListName[FieldInListIndex].Value);
{
      DefineIdent(i, FieldInListName[FieldInListIndex].Name, CONSTANT, POINTERTOK, length(FieldInListName[FieldInListIndex].Name)+1, CHARTOK, NumStaticStrChars + CODEORIGIN + CODEORIGIN_BASE , IDENTTOK);

      StaticStringData[NumStaticStrChars] := length(FieldInListName[FieldInListIndex].Name);

      for k:=1 to length(FieldInListName[FieldInListIndex].Name) do
       StaticStringData[NumStaticStrChars + k] := ord(FieldInListName[FieldInListIndex].Name[k]);

      inc(NumStaticStrChars, length(FieldInListName[FieldInListIndex].Name) + 1);
}
      Ident[NumIdent].NumAllocElements := RecType;
      Ident[NumIdent].Pass :=  TPass.CALL_DETERMINATION;

      DeclareField(FieldInListName[FieldInListIndex].Name, DataType, 0, 0, FieldInListName[FieldInListIndex].Value);
    end;

    TypeArray[RecType].Block := BlockStack[BlockStackTop];

    AllocElementType := DataType;

    DataType := ENUMTYPE;
    NumAllocElements := RecType;      // indeks do tablicy Types

    Result := i;

//    writeln('>',lowerbound,',',upperbound);

end else

// -----------------------------------------------------------------------------
//				TEXTFILE
// -----------------------------------------------------------------------------

if Tok[i].Kind = TEXTFILETOK then begin					// TextFile

 AllocElementType := BYTETOK;
 NumAllocElements := 1;

 DataType := TEXTFILETOK;
 Result := i;

end else

// -----------------------------------------------------------------------------
//				FILE
// -----------------------------------------------------------------------------

if Tok[i].Kind = FILETOK then begin					// File

 if Tok[i + 1].Kind = OFTOK then
  i := CompileType(i + 2, DataType, NumAllocElements, AllocElementType)
 else begin
  AllocElementType := 0;//BYTETOK;
  NumAllocElements := 128;
 end;

 DataType := FILETOK;
 Result := i;

end else

// -----------------------------------------------------------------------------
//				SET OF
// -----------------------------------------------------------------------------

if Tok[i].Kind = SETTOK then begin					// Set Of

 CheckTok(i + 1, OFTOK);

 if not (Tok[i + 2].Kind in [CHARTOK, BYTETOK]) then
      Error(i + 2, TMessage.Create(TErrorCode.IllegalTypeDeclarationOfSetElements,
        'Illegal type declaration of set elements'));

 DataType := POINTERTOK;
 NumAllocElements := 32;
 AllocElementType := Tok[i + 2].Kind;

 Result := i + 2;

end else

// -----------------------------------------------------------------------------
//				OBJECT
// -----------------------------------------------------------------------------

  if Tok[i].Kind = OBJECTTOK then					// Object
  begin

  Name := Tok[i-2].Name;

  inc(NumTypes);
  RecType := NumTypes;

  if NumTypes > MAXTYPES then
      Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

  inc(i);

  TypeArray[RecType].NumFields := 0;
  TypeArray[RecType].Field[0].Name := Name;

    if (Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);

	  k := i;

	  i := DefineFunction(i, 0, isForward, isInt, isInl, isOvr, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	  Inc(NumBlocks);
	  Ident[NumIdent].ProcAsBlock := NumBlocks;

	  Ident[NumIdent].IsUnresolvedForward := TRUE;

	  Ident[NumIdent].ObjectIndex := RecType;
	  Ident[NumIdent].Name := Name + '.' + Tok[k + 1].Name;

     	  CheckTok(i, SEMICOLONTOK);

     	  inc(i);
    	end;

      if (Tok[i].Kind in [IDENTTOK]) then
        Error(i, TMessage.Create(TErrorCode.FieldAfterMethodOrProperty,
          'Fields cannot appear after a method or property definition'));

    end else

  repeat
    NumFieldsInList := 0;

    repeat

      if (Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) then
            Error(i, TMessage.Create(TErrorCode.FieldAfterMethodOrProperty,
              'Fields cannot appear after a method or property definition'));

      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name;

      inc(i);

      ExitLoop := FALSE;

      if Tok[i].Kind = COMMATOK then
	 inc(i)
      else
	ExitLoop := TRUE;

    until ExitLoop;

    CheckTok(i, COLONTOK);

    j := i + 1;

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    if Tok[j].Kind = ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


    for FieldInListIndex := 1 to NumFieldsInList do begin							// issue #92 fixed
      DeclareField(FieldInListName[FieldInListIndex].Name, DataType, NumAllocElements, AllocElementType);	//
														//
      if DataType in [RECORDTOK, OBJECTTOK] then								//
//      for FieldInListIndex := 1 to NumFieldsInList do								//
         for k := 1 to TypeArray[NumAllocElements].NumFields do begin						//
	  DeclareField(FieldInListName[FieldInListIndex].Name + '.' + TypeArray[NumAllocElements].Field[k].Name,	//
		     TypeArray[NumAllocElements].Field[k].DataType,							//
		     TypeArray[NumAllocElements].Field[k].NumAllocElements,						//
		     TypeArray[NumAllocElements].Field[k].AllocElementType						//
		     );												//

	  TypeArray[RecType].Field[ TypeArray[RecType].NumFields ].Kind := OBJECTVARIABLE;

//	writeln('>> ',FieldInListName[FieldInListIndex].Name + '.' + Types[NumAllocElements].Field[k].Name,',', Types[NumAllocElements].Field[k].NumAllocElements);
         end;

     end;


    ExitLoop := FALSE;
    if Tok[i + 1].Kind <> SEMICOLONTOK then begin
      inc(i);
      ExitLoop := TRUE
    end else
      begin
      inc(i, 2);

      if Tok[i].Kind = ENDTOK then ExitLoop := TRUE else
       if Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = FUNCTIONTOK);

	  k := i;

	  i := DefineFunction(i, 0, isForward, isInt, isInl, isOvr, IsNestedFunction, NestedFunctionResultType, NestedFunctionNumAllocElements, NestedFunctionAllocElementType);

	  Inc(NumBlocks);
	  Ident[NumIdent].ProcAsBlock := NumBlocks;

	  Ident[NumIdent].IsUnresolvedForward := TRUE;

	  Ident[NumIdent].ObjectIndex := RecType;
	  Ident[NumIdent].Name := Name + '.' + Tok[k + 1].Name;

     	  CheckTok(i, SEMICOLONTOK);

     	  inc(i);
    	end;

	ExitLoop := TRUE;
       end;

      end;

  until ExitLoop;

  CheckTok(i, ENDTOK);

  TypeArray[RecType].Block := BlockStack[BlockStackTop];

  DataType := OBJECTTOK;
  NumAllocElements := RecType;      // indeks do tablicy Types
  AllocElementType := 0;

  Result := i;
end else// if OBJECTTOK

// -----------------------------------------------------------------------------
//				RECORD
// -----------------------------------------------------------------------------

  if (Tok[i].Kind = RECORDTOK) or ((Tok[i].Kind = PACKEDTOK) and (Tok[i+1].Kind = RECORDTOK)) then		// Record
  begin

  Name := Tok[i-2].Name;

  if Tok[i].Kind = PACKEDTOK then inc(i);

  inc(NumTypes);
  RecType := NumTypes;

  if NumTypes > MAXTYPES then
      Error(i, TMessage.Create(TErrorCode.OutOfResources, 'Out of resources, MAXTYPES'));

  inc(i);

  TypeArray[RecType].Size := 0;
  TypeArray[RecType].NumFields := 0;
  TypeArray[RecType].Field[0].Name := Name;

  repeat
    NumFieldsInList := 0;
    repeat
      CheckTok(i, IDENTTOK);

      Inc(NumFieldsInList);
      FieldInListName[NumFieldsInList].Name := Tok[i].Name;

      inc(i);

      ExitLoop := FALSE;

      if Tok[i].Kind = COMMATOK then
	inc(i)
      else
	ExitLoop := TRUE;

    until ExitLoop;

    CheckTok(i, COLONTOK);

    j := i + 1;

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    if Tok[j].Kind = ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


    //NumAllocElements:=0;		// ??? arrays not allowed, only pointers ???

    for FieldInListIndex := 1 to NumFieldsInList do begin								// issue #92 fixed
      DeclareField(FieldInListName[FieldInListIndex].Name, DataType, NumAllocElements, AllocElementType);		//
															//
      if DataType = RECORDTOK then											//
        //for FieldInListIndex := 1 to NumFieldsInList do								//
        for k := 1 to TypeArray[NumAllocElements].NumFields do								//
 	  DeclareField(FieldInListName[FieldInListIndex].Name + '.' + TypeArray[NumAllocElements].Field[k].Name, 		//
	               TypeArray[NumAllocElements].Field[k].DataType, 							//
		       TypeArray[NumAllocElements].Field[k].NumAllocElements, 						//
		       TypeArray[NumAllocElements].Field[k].AllocElementType);						//

    end;

    ExitLoop := FALSE;
    if Tok[i + 1].Kind <> SEMICOLONTOK then begin
      inc(i);
      ExitLoop := TRUE
    end else
      begin
      inc(i, 2);
      if Tok[i].Kind = ENDTOK then ExitLoop := TRUE;
      end

  until ExitLoop;

  CheckTok(i, ENDTOK);

  TypeArray[RecType].Block := BlockStack[BlockStackTop];

  DataType := RECORDTOK;
  NumAllocElements := RecType;			// indeks do tablicy Types
  AllocElementType := 0;

  if TypeArray[RecType].Size >= 256 then
      Error(i, TMessage.Create(TErrorCode.RecordSizeExceedsLimit, 'Record size {0} exceeds the 256 bytes limit.',
        IntToStr(TypeArray[RecType].Size)));

  Result := i;
end else// if RECORDTOK

// -----------------------------------------------------------------------------
//				PCHAR
// -----------------------------------------------------------------------------

if Tok[i].Kind = PCHARTOK then						// PChar
  begin

  DataType := POINTERTOK;
  AllocElementType := CHARTOK;

  NumAllocElements := 0;

  Result:=i;
 end else // Pchar

// -----------------------------------------------------------------------------
//				STRING
// -----------------------------------------------------------------------------

 if Tok[i].Kind = STRINGTOK then					// String
  begin
  DataType := STRINGPOINTERTOK;
  AllocElementType := CHARTOK;

  if Tok[i + 1].Kind <> OBRACKETTOK then begin

   UpperBound:=255;				 // default string[255]

   Result:=i;

  end  else begin
 //   Error(i + 1, '[ expected but ' + GetSpelling(i + 1) + ' found');

  i := CompileConstExpression(i + 2, UpperBound, ExpressionType);

  if (UpperBound < 1) or (UpperBound > 255) then
        Error(i, TMessage.Create(TErrorCode.StringLengthNotInRange, 'String length must be a value from 1 to 255'));

  CheckTok(i + 1, CBRACKETTOK);

  Result := i + 1;
  end;

  NumAllocElements := UpperBound + 1;

  if UpperBound>255 then
   Error(i, TErrorCode.SubrangeBounds);

  end// if STRINGTOK
else




// -----------------------------------------------------------------------------
// this place is for new types
// -----------------------------------------------------------------------------







// -----------------------------------------------------------------------------
//			OrdinalTypes + RealTypes + Pointers
// -----------------------------------------------------------------------------

if Tok[i].Kind in AllTypes then
  begin
  DataType := Tok[i].Kind;
  NumAllocElements := 0;
  AllocElementType := 0;

  Result := i;
 end else

// -----------------------------------------------------------------------------
//					ARRAY
// -----------------------------------------------------------------------------

 if (Tok[i].Kind = ARRAYTOK) or ((Tok[i].Kind = PACKEDTOK) and (Tok[i + 1].Kind = ARRAYTOK))  then		// Array
  begin
  DataType := POINTERTOK;

  if Tok[i].Kind = PACKEDTOK then inc(i);

  CheckTok(i + 1, OBRACKETTOK);

  if Tok[i + 2].Kind in AllTypes + StringTypes then begin

   if Tok[i + 2].Kind = BYTETOK then begin
    LowerBound := 0;
    UpperBound := 255;

    NumAllocElements := 256;
   end else
    Error(i, TMessage.Create(TErrorCode.InvalidTypeDefinition, 'Invalid type definition.'));

   inc(i, 2);

  end else begin

  i := CompileConstExpression(i + 2, LowerBound, ExpressionType);
  if not(ExpressionType in IntegerTypes) then
    Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotInteger, 'Array lower bound must be an integer value'));

  if LowerBound <> 0 then
    Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotZero, 'Array lower bound is not zero'));

  CheckTok(i + 1, RANGETOK);

  i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
  if not(ExpressionType in IntegerTypes) then
    Error(i, TMessage.Create(TErrorCode.ArrayUpperBoundNotInteger, 'Array upper bound must be integer'));

  if UpperBound < 0 then
    Error(i, TErrorCode.UpperBoundOfRange);

  if UpperBound > High(word) then
    Error(i, TErrorCode.HighLimit);

  NumAllocElements := UpperBound - LowerBound + 1;

  if Tok[i + 1].Kind = COMMATOK then begin				// [0..x, 0..y]

    i := CompileConstExpression(i + 2, LowerBound, ExpressionType);
    if not(ExpressionType in IntegerTypes) then
      Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotInteger,'Array lower bound must be integer'));

    if LowerBound <> 0 then
      Error(i, TMessage.Create(TErrorCode.ArrayLowerBoundNotZero,'Array lower bound is not zero'));

    CheckTok(i + 1, RANGETOK);

    i := CompileConstExpression(i + 2, UpperBound, ExpressionType);
    if not(ExpressionType in IntegerTypes) then
      Error(i, TMessage.Create(TErrorCode.ArrayUpperBoundNotInteger, 'Array upper bound must be integer'));

    if UpperBound < 0 then
      Error(i, TErrorCode.UpperBoundOfRange);

    if UpperBound > High(word) then
      Error(i, TErrorCode.HighLimit);

    NumAllocElements := NumAllocElements or (UpperBound - LowerBound + 1) shl 16;

  end;

  end;	// if Tok[i + 2].Kind in AllTypes + StringTypes

  CheckTok(i + 1, CBRACKETTOK);
  CheckTok(i + 2, OFTOK);


  if Tok[i + 3].Kind in [RECORDTOK, OBJECTTOK] then
      Error(i, TMessage.Create(TErrorCode.InvalidArrayOfPointers,
        'Only arrays of ^{0} are supported.', InfoAboutToken(Tok[i + 3].Kind)));


  if Tok[i + 3].Kind = ARRAYTOK then begin
    i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);
    Result := i;
  end else begin
    Result := i;
    i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);
  end;

  // TODO: Have Constant for 40960
  if (NumAllocElements shr 16) * (NumAllocElements and $FFFF) * DataSize[NestedDataType] > 40960-1 then
    Error(i, TMessage.Create(TErrorCode.ArraySizeExceedsRAMSize, 'Array [0..{0}, 0..{1} size exceeds the available RAM', IntToStr((NumAllocElements and $FFFF)-1), IntToStr((NumAllocElements shr 16)-1)));


// sick3
// writeln('>',NestedDataType,',',NestedAllocElementType,',',Tok[i].kind,',',hexStr(NestedNumAllocElements,8),',',hexStr(NumAllocElements,8));

//  if NestedAllocElementType = PROCVARTOK then
//      Error(i, InfoAboutToken(NestedAllocElementType)+' arrays are not supported');


  if NestedNumAllocElements > 0 then
//    Error(i, 'Multidimensional arrays are not supported');
   if NestedDataType in [RECORDTOK, OBJECTTOK, ENUMTOK] then begin			// !!! dla RECORD, OBJECT tablice nie zadzialaja !!!

    if NumAllocElements shr 16 > 0 then
          Error(i, TMessage.Create(TErrorCode.MultiDimensionalArrayOfTypeNotSupported,
            'Multidimensional arrays of element type {0} are not supported.', InfoAboutToken(NestedDataType)));

//    if NestedDataType = RECORDTOK then
//    else
    if NestedDataType in [RECORDTOK, OBJECTTOK] then
          Error(i, TMessage.Create(TErrorCode.OnlyArrayOfTypeSupported, 'Only Array [0..{0}] of ^{1} supported',
            IntToStr(NumAllocElements - 1), InfoAboutToken(NestedDataType)))
    else
          Error(i, TMessage.Create(TErrorCode.ArrayOfTypeNotSupported, 'Arrays of type {0} are not supported.',
            InfoAboutToken(NestedDataType)));

//    NumAllocElements := NestedNumAllocElements;
//    NestedAllocElementType := NestedDataType;
//    NestedDataType := POINTERTOK;

//    NestedDataType := NestedAllocElementType;
    NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

   end else
   if not (NestedDataType in [STRINGPOINTERTOK, RECORDTOK, OBJECTTOK{, PCHARTOK}]) and (Tok[i].Kind <> PCHARTOK) then begin

     if (NestedAllocElementType in [RECORDTOK, OBJECTTOK, PROCVARTOK]) and (NumAllocElements shr 16 > 0) then
          Error(i, TMessage.Create(TErrorCode.MultiDimensionalArrayOfTypeNotSupported,
            'Multidimensional arrays of element type {0} are not supported.', InfoAboutToken(NestedAllocElementType)));

     NestedDataType := NestedAllocElementType;

     if NestedAllocElementType = PROCVARTOK then
      NumAllocElements := NumAllocElements or NestedNumAllocElements
     else
      if NestedAllocElementType in [RECORDTOK, OBJECTTOK] then
       NumAllocElements := NestedNumAllocElements or (NumAllocElements shl 16)			// array [..] of ^record|^object
      else
       NumAllocElements := NumAllocElements or (NestedNumAllocElements shl 16);

   end;

  AllocElementType :=  NestedDataType;

//  Result := i;
  end // if ARRAYTOK
else

// -----------------------------------------------------------------------------
//				   USERTYPE
// -----------------------------------------------------------------------------

 if (Tok[i].Kind = IDENTTOK) and (Ident[GetIdentIndex(Tok[i].Name)].Kind = USERTYPE) then
  begin
  IdentIndex := GetIdentIndex(Tok[i].Name);

  if IdentIndex = 0 then
    Error(i, TErrorCode.UnknownIdentifier);

  if Ident[IdentIndex].Kind <> USERTYPE then
      Error(i, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected but {0} found',
        Tok[i].Name));

  DataType := Ident[IdentIndex].DataType;
  NumAllocElements := Ident[IdentIndex].NumAllocElements or (Ident[IdentIndex].NumAllocElements_ shl 16);
  AllocElementType := Ident[IdentIndex].AllocElementType;

//	writeln('> ',Ident[IdentIndex].Name,',',DataType,',',AllocElementType,',',NumAllocElements,',',Ident[IdentIndex].NumAllocElements_);

  Result := i;
  end // if IDENTTOK
else begin

   i := CompileConstExpression(i, ConstVal, ExpressionType);
   LowerBound:=ConstVal;

   CheckTok(i+1, RANGETOK);

   i := CompileConstExpression(i+2, ConstVal, ExpressionType);
   UpperBound:=ConstVal;

   if UpperBound < LowerBound then
     Error(i, TErrorCode.UpperBoundOfRange);

 // Error(i, 'Error in type definition');

  DataType := BoundaryType;
  NumAllocElements := 0;
  AllocElementType := 0;
  Result := i;

end;

end;	//CompileType


// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


end.
