unit Parser;

{$I Defines.inc}

interface

uses Common, Numbers, Types;

// -----------------------------------------------------------------------------

function CompileType(i: TTokenIndex; out DataType: TDatatype; out NumAllocElements: Cardinal;
  out AllocElementType: TDatatype): TTokenIndex;

function CompileConstExpression(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDatatype;
  const VarType: TDatatype = TDatatype.INTEGERTOK; const Err: Boolean = False; const War: Boolean = True): TTokenIndex;

function CompileConstTerm(i: TTokenIndex; out ConstVal: Int64; out ConstValType: TDatatype): TTokenIndex;

procedure DefineIdent(const tokenIndex: TTokenIndex; Name: TIdentifierName; Kind: TTokenKind; DataType: TDataType;
  NumAllocElements: Cardinal; AllocElementType: TDataType; Data: Int64; IdType: TDataType = TDatatype.IDENTTOK);

function DefineFunction(i: TTokenIndex; ForwardIdentIndex: TIdentIndex;
  out isForward, isInt, isInl, isOvr: Boolean; var IsNestedFunction: Boolean;
  out NestedFunctionResultType: TDatatype; out NestedFunctionNumAllocElements: Cardinal;
  out NestedFunctionAllocElementType: Byte): Integer;

function Elements(IdentIndex: TIdentIndex): Cardinal;

function GetIdentIndex(S: TIdentifierName): TIdentIndex;

function GetSizeOf(i: TTokenIndex; ValType: TDatatype): Int64;

function ObjectRecordSize(i: Cardinal): Integer;

function RecordSize(IdentIndex: TIdentIndex; field: String = ''): Integer;

procedure SaveToDataSegment(ConstDataSize: Integer; ConstVal: Int64; ConstValType: TDatatype);

// -----------------------------------------------------------------------------

implementation

uses SysUtils, Messages, Utilities;

// ----------------------------------------------------------------------------


function Elements(IdentIndex: integer): cardinal;
begin

 if (Ident[IdentIndex].DataType = TDatatype.ENUMTOK) then
  Result := 0
 else

   if Ident[IdentIndex].AllocElementType in [TDatatype.RECORDTOK, TDatatype.OBJECTTOK] then
    Result := Ident[IdentIndex].NumAllocElements_
   else
   if (Ident[IdentIndex].NumAllocElements_ = 0) or (Ident[IdentIndex].AllocElementType in [TDatatype.PROCVARTOK]) then
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
      if Ident[TempIndex].DataType = TDatatype.OBJECTTOK then
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
    FieldType, AllocElementType: TDatatype;
    NumAllocElements: cardinal;
begin

 Result := 0;

 FieldType := TDatatype.UNTYPETOK;

 if i > 0 then begin

   for j := 1 to TypeArray[i].NumFields do begin

    FieldType := TypeArray[i].Field[j].DataType;
    
    // TODO: The two variables below are unused.
    NumAllocElements := TypeArray[i].Field[j].NumAllocElements;
    AllocElementType := TypeArray[i].Field[j].AllocElementType;

    if FieldType <> TDatatype.RECORDTOK then
     inc(Result, GetDataSize(FieldType));

   end;

end;

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function RecordSize(IdentIndex: integer; field: string =''): integer;
var i, j: integer;
    name, base: TName;
    FieldType, AllocElementType: TDatatype;
    NumAllocElements: cardinal;
    yes: Boolean;
begin

// if Ident[IdentIndex].NumAllocElements_ > 0 then
//  i := Ident[IdentIndex].NumAllocElements_
// else
  i := Ident[IdentIndex].NumAllocElements;

 Result := 0;

 FieldType := TDatatype.UNTYPETOK;

 yes := false;

 if i > 0 then begin

   for j := 1 to TypeArray[i].NumFields do begin

    FieldType := TypeArray[i].Field[j].DataType;
    NumAllocElements := TypeArray[i].Field[j].NumAllocElements;
    AllocElementType :=  TypeArray[i].Field[j].AllocElementType;

    if AllocElementType in [TDatatype.FORWARDTYPE, TDatatype.PROCVARTOK] then begin
     AllocElementType := TDatatype.POINTERTOK;
     NumAllocElements := 0;
    end;

    if TypeArray[i].Field[j].Name = field then begin yes:=true; Break end;

    if FieldType <> TDatatype.RECORDTOK then
     if (FieldType in Pointers) and (NumAllocElements > 0) then
      inc(Result, NumAllocElements * GetDataSize(AllocElementType))
     else
      inc(Result, GetDataSize(FieldType));

   end;

 end else begin

  name:=Ident[IdentIndex].Name;

  base:=copy(name, 1, pos('.', name)-1);

  IdentIndex := GetIdentIndex(base);

  for i := 1 to TypeArray[Ident[IdentIndex].NumAllocElements].NumFields do
   if pos(name, base+'.'+TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].Name) > 0 then
    if TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].DataType <> TDatatype.RECORDTOK then begin

     FieldType := TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].DataType;
     NumAllocElements := TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].NumAllocElements;
     AllocElementType := TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].AllocElementType;

     if TypeArray[Ident[IdentIndex].NumAllocElements].Field[i].Name = field then begin yes:=true; Break end;

     if FieldType <> TDatatype.RECORDTOK then
      if (FieldType in Pointers) and (NumAllocElements > 0) then
       inc(Result, NumAllocElements * GetDataSize(AllocElementType))
      else
       inc(Result, GetDataSize(FieldType));

    end;

 end;


 if field <> '' then
  if not yes then
   Result := -1
  else
   Result := Result + Ord(FieldType) shl 16;		// type | offset

end;

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure SaveToDataSegment(ConstDataSize: integer; ConstVal: Int64; ConstValType: TDatatype);
begin

	if (ConstDataSize < 0) or (ConstDataSize > $FFFF) then
	begin writeln('SaveToDataSegment: ', ConstDataSize);
	      RaiseHaltException(THaltException.COMPILING_ABORTED);
	end;

	 case ConstValType of

	  TDatatype.SHORTINTTOK, TDatatype.BYTETOK, TDatatype.CHARTOK, TDatatype.BOOLEANTOK:
		       DataSegment[ConstDataSize] := byte(ConstVal);

	  TDatatype.SMALLINTTOK, TDatatype.WORDTOK, TDatatype.SHORTREALTOK, TDatatype.POINTERTOK, TDatatype.STRINGPOINTERTOK, TDatatype.PCHARTOK:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
		       end;

	   TDatatype.DATAORIGINOFFSET:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal) or $8000;
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8) or $4000;
		       end;

	   TDatatype.CODEORIGINOFFSET:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal) or $2000;
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8) or $1000;
		       end;

	   TDatatype.INTEGERTOK, TDatatype.CARDINALTOK, TDatatype.REALTOK:
		       begin
			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
			DataSegment[ConstDataSize+2] := byte(ConstVal shr 16);
			DataSegment[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	    TDatatype.SINGLETOK: begin
			ConstVal:=CastToSingle(ConstVal);

			DataSegment[ConstDataSize]   := byte(ConstVal);
			DataSegment[ConstDataSize+1] := byte(ConstVal shr 8);
			DataSegment[ConstDataSize+2] := byte(ConstVal shr 16);
			DataSegment[ConstDataSize+3] := byte(ConstVal shr 24);
		       end;

	TDatatype.HALFSINGLETOK: begin
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

	ENUMTYPE:
                 Result := GetDataSize(Ident[IdentIndex].AllocElementType);

	TDatatype.RECORDTOK:
                    if (Ident[IdentIndex].DataType = TDataType.POINTERTOK) and (Tok[i + 3].Kind =  TDataType.CPARTOK) then
	             Result := GetDataSize(TDataType.POINTERTOK)
		   else
		     Result := RecordSize(IdentIndex);

      TDatatype.POINTERTOK, TDatatype.STRINGPOINTERTOK:
		  begin

		    if Ident[IdentIndex].AllocElementType =  TDataType.RECORDTOK then begin

		     if Ident[IdentIndex].NumAllocElements_ > 0 then begin

		       if Tok[i + 3].Kind =  TDataType.OBRACKETTOK then
			Result := GetDataSize( TDataType.POINTERTOK)
		       else
			Result := Ident[IdentIndex].NumAllocElements_ * 2

		     end else
		      if Ident[IdentIndex].PassMethod = TParameterPassingMethod.VARPASSING then
		       Result := RecordSize(IdentIndex)
		      else
		       Result := GetDataSize(TDataType.POINTERTOK);

		    end else
		     if Elements(IdentIndex) > 0 then
		       Result := integer(Elements(IdentIndex) * GetDataSize(Ident[IdentIndex].AllocElementType))
		     else
		       Result := GetDataSize(TDataType.POINTERTOK);

		  end;

      else

	if ValType = TDataType.UNTYPETOK
        then
	 Result := 0
	else
	 Result := GetDataSize(ValType)

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

      Result := StaticStringData[Ident[IdentIndex].Value - CODEORIGIN - CODEORIGIN_BASE + ArrayIndex * GetDataSize(ConstValType) + x];

    end;

begin

 ConstVal:=0;
 ConstValType:=TDatatype.UNTYPETOK;
 Result := i;

 j:=0;

// WRITELN(tok[i].line, ',', tok[i].kind);

case Tok[i].Kind of

 TTokenCode.LOWTOK:
    begin
     CheckTok(i + 1, TTokenCode.OPARTOK);

     if Tok[i + 2].Kind in AllTypes {+ [TTokenCode.STRINGTOK]} then begin

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

     CheckTok(i + 1, TTokenCode.CPARTOK);

     Result:=i + 1;
    end;


 TTokenCode.HIGHTOK:
    begin
     CheckTok(i + 1, TTokenCode.OPARTOK);

     if Tok[i + 2].Kind in AllTypes {+ [STRINGTOK]} then begin

      ConstValType := Tok[i + 2].Kind;

      inc(i, 2);

     end else begin

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

     end;

     if ConstValType in Pointers then begin
      IdentIndex := GetIdentIndex(Tok[i].Name);

      if Ident[IdentIndex].AllocElementType in [TTokenCode.RECORDTOK, TTokenCode.OBJECTTOK] then
       ConstVal := Ident[IdentIndex].NumAllocElements_ - 1
      else
      if Ident[IdentIndex].NumAllocElements > 0 then
       ConstVal := Ident[IdentIndex].NumAllocElements - 1
      else
       ConstVal := 0;

     end else
      ConstVal := HighBound(i, ConstValType);

     ConstValType := GetValueType(ConstVal);

     CheckTok(i + 1, TTokenCode.CPARTOK);

     Result:=i + 1;
    end;


 TTokenCode.LENGTHTOK:
    begin
     CheckTok(i + 1, TTokenCode.OPARTOK);

      ConstVal:=0;

      if Tok[i + 2].Kind = TTokenCode.IDENTTOK then begin

	IdentIndex := GetIdentIndex(Tok[i + 2].Name);

	if IdentIndex = 0 then
	 Error(i + 2, TErrorCode.UnknownIdentifier);

	if Ident[IdentIndex].Kind in [VARIABLE, CONSTANT] then begin

	  if (Ident[IdentIndex].DataType = TTokenCode.STRINGPOINTERTOK) or ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].NumAllocElements > 0)) then begin

	   if (Ident[IdentIndex].DataType = TTokenCode.STRINGPOINTERTOK) or (Ident[IdentIndex].AllocElementType = TTokenCode.CHARTOK) then begin

	   isError := true;
	   exit;

	   end else begin

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].NumAllocElements,'/',Ident[IdentIndex].NumAllocElements_,',',Ident[IdentIndex].AllocElementType );

	    if (Ident[IdentIndex].DataType = TTokenCode.POINTERTOK) and (Ident[IdentIndex].AllocElementType in [TTokenCode.RECORDTOK, TTokenCode.OBJECTTOK]) then
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

     CheckTok(i + 1, TTokenCode.CPARTOK);

     Result:=i + 1;
    end;


 TTokenCode.SIZEOFTOK:
    begin
     CheckTok(i + 1, TTokenCode.OPARTOK);

     if Tok[i + 2].Kind in OrdinalTypes + RealTypes + [TTokenCode.POINTERTOK] then begin

      ConstVal := GetDataSize(Tok[i + 2].Kind);
      ConstValType := TTokenCode.BYTETOK;

      j:=i + 2;

     end else begin

      if Tok[i + 2].Kind <> TTokenCode.IDENTTOK then
        Error(i + 2, TErrorCode.IdentifierExpected);

      j := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      ConstVal := GetSizeof(i, ConstValType);

      ConstValType := GetValueType(ConstVal);

     end;

     CheckTok(j + 1, TTokenCode.CPARTOK);

     Result:=j + 1;
    end;


  TTokenCode.LOTOK:
    begin

    CheckTok(i + 1, TTokenCode.OPARTOK);

    OldConstValType:=TDatatype.UNTYPETOK;

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

    // TODO: But here OldConstValType=TDatatype.UNTYPETOK always?
    if OldConstValType in [TTokenCode.DATAORIGINOFFSET, TTokenCode.CODEORIGINOFFSET] then
        Error(i, TMessage.Create(TErrorCode.InvalidVariableAddress, 'Can''t take the address of variable'));

    GetCommonConstType(i, TDatatype.INTEGERTOK, ConstValType);

    CheckTok(i + 1, TDatatype.CPARTOK);

    case ConstValType of
      TDatatype.INTEGERTOK, TDatatype.CARDINALTOK: ConstVal := ConstVal and $0000FFFF;
	 TDatatype.SMALLINTTOK, TDatatype.WORDTOK: ConstVal := ConstVal and $00FF;
	 TDatatype.SHORTINTTOK, TDatatype.BYTETOK: ConstVal := ConstVal and $0F;
    end;

    ConstValType := GetValueType(ConstVal);

    Result:=i + 1;
    end;


  TDatatype.HITOK:
    begin

    CheckTok(i + 1, TDatatype.OPARTOK);

    OldConstValType:=TDatatype.UNTYPETOK;

    i := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then Exit;

    if OldConstValType in [TDatatype.DATAORIGINOFFSET, TDatatype.CODEORIGINOFFSET] then
        Error(i, TMessage.Create(TErrorCode.InvalidVariableAddress, 'Can''t take the address of variable'));

    GetCommonConstType(i, TDatatype.INTEGERTOK, ConstValType);

    CheckTok(i + 1, TDatatype.CPARTOK);

    case ConstValType of
      TDatatype.INTEGERTOK, TDatatype.CARDINALTOK: ConstVal := ConstVal shr 16;
	 TDatatype.SMALLINTTOK, TDatatype.WORDTOK: ConstVal := ConstVal shr 8;
	 TDatatype.SHORTINTTOK, TDatatype.BYTETOK: ConstVal := ConstVal shr 4;
    end;

    ConstValType := GetValueType(ConstVal);
    Result:=i + 1;
    end;


  TDatatype.INTTOK, TDatatype.FRACTOK:
    begin

      Kind := Tok[i].Kind;

      CheckTok(i + 1, TDatatype.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      if not (ConstValType in RealTypes) then
	ErrorIncompatibleTypes(i, ConstValType, TDatatype.REALTOK);

      CheckTok(i + 1, TDatatype.CPARTOK);

      	case Kind of
	  TDatatype.INTTOK: ConstVal:=Trunc(ConstValType, ConstVal);
	 TDatatype.FRACTOK: ConstVal:=Frac(ConstValType, ConstVal);
	end;

 //     ConstValType := REALTOK;
      Result:=i + 1;
    end;


  TDatatype.ROUNDTOK, TDatatype.TRUNCTOK:
    begin

      Kind := Tok[i].Kind;

      CheckTok(i + 1, TDatatype.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, TDatatype.REALTOK, ConstValType);

      CheckTok(i + 1, TDatatype.CPARTOK);

      ConstVal := integer(ConstVal);

      case Kind of
	TDatatype.ROUNDTOK: if ConstVal < 0 then
		   ConstVal := -( abs(ConstVal) shr 8 + ord( abs(ConstVal) and $ff > 127) )
		  else
		   ConstVal := ConstVal shr 8 + ord( abs(ConstVal) and $ff > 127);

	TDatatype.TRUNCTOK: if ConstVal < 0 then
		   ConstVal := -( abs(ConstVal) shr 8)
		  else
		   ConstVal := ConstVal shr 8;
      end;

      ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;


  TDatatype.ODDTOK:
    begin

//      Kind := Tok[i].Kind;

      CheckTok(i + 1, TDatatype.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if isError then Exit;

      GetCommonConstType(i, TDatatype.CARDINALTOK, ConstValType);

      CheckTok(i + 1, TDatatype.CPARTOK);

      ConstVal := ord(odd(ConstVal));

      ConstValType := TDatatype.BOOLEANTOK;

      Result:=i + 1;
    end;


  TDatatype.CHRTOK:
    begin

      CheckTok(i + 1, TDatatype.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, TDatatype.BYTETOK);

      if isError then Exit;

      GetCommonConstType(i, TDatatype.INTEGERTOK, ConstValType);

      CheckTok(i + 1, TDatatype.CPARTOK);

      ConstValType := TDatatype.CHARTOK;
      Result:=i + 1;
    end;


  TDatatype.ORDTOK:
    begin
      CheckTok(i + 1, TDatatype.OPARTOK);

      j := i + 2;

      i := CompileConstExpression(i + 2, ConstVal, ConstValType, TDatatype.BYTETOK);

      if not(ConstValType in OrdinalTypes + [ENUMTYPE]) then
	Error(i, TErrorCode.OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, TDatatype.CPARTOK);

      if ConstValType in [TDatatype.CHARTOK, TDatatype.BOOLEANTOK, TDatatype.ENUMTOK] then
       ConstValType := TDatatype.BYTETOK;

      Result:=i + 1;
    end;


  TDatatype.PREDTOK, TDatatype.SUCCTOK:
    begin
      Kind := Tok[i].Kind;

      CheckTok(i + 1, TDatatype.OPARTOK);

      i := CompileConstExpression(i + 2, ConstVal, ConstValType);

      if not(ConstValType in OrdinalTypes) then
	Error(i, TErrorCode.OrdinalExpExpected);

      if isError then Exit;

      CheckTok(i + 1, TDatatype.CPARTOK);

      if Kind = TDatatype.PREDTOK then
       dec(ConstVal)
      else
       inc(ConstVal);

      if not (ConstValType in [TDatatype.CHARTOK, TDatatype.BOOLEANTOK]) then
       ConstValType := GetValueType(ConstVal);

      Result:=i + 1;
    end;


  TDatatype.IDENTTOK:
    begin
    IdentIndex := GetIdentIndex(Tok[i].Name);

    if IdentIndex > 0 then

	  if (Ident[IdentIndex].Kind = USERTYPE) and (Tok[i + 1].Kind = TDatatype.OPARTOK) then begin

		CheckTok(i + 1, TDatatype.OPARTOK);

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

		CheckTok(j + 1, TDatatype.CPARTOK);

		i := j + 1;

	  end else

      if not (Ident[IdentIndex].Kind in [CONSTANT, USERTYPE, ENUMTYPE]) then
      begin
          Error(i, TMessage.Create(TErrorCode.ConstantExpected, 'Constant expected but {0} found', Ident[IdentIndex].Name));
      end
      else
	if Tok[i + 1].Kind = TDatatype.OBRACKETTOK then					// Array element access
	  if  not (Ident[IdentIndex].DataType in Pointers) then
	    ErrorForIdentifier(i, TErrorCode.IncompatibleTypeOf, IdentIndex)
	  else
	    begin

	    j := CompileConstExpression(i + 2, ArrayIndex, ArrayIndexType);	// Array index

	    if isError then Exit;

	    if (ArrayIndex < 0) or (ArrayIndex > Ident[IdentIndex].NumAllocElements-1 + ord(Ident[IdentIndex].DataType = TDatatype.STRINGPOINTERTOK)) then begin
	     isConst := false;
	     Error(i, TErrorCode.SubrangeBounds);
	    end;

	    CheckTok(j + 1, TDatatype.CBRACKETTOK);

	    if Tok[j + 2].Kind = TDatatype.OBRACKETTOK then begin isError:=true; exit end;

//	    InfoAboutArray(IdentIndex, true);

	    ConstValType := Ident[IdentIndex].AllocElementType;

	    case GetDataSize(ConstValType) of
	     1: ConstVal := GetStaticValue(0 + ord(Ident[IdentIndex].idType = TDatatype.PCHARTOK));
	     2: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8;
	     4: ConstVal := GetStaticValue(0) + GetStaticValue(1) shl 8 + GetStaticValue(2) shl 16 + GetStaticValue(3) shl 24;
	    end;

	    if ConstValType in [TDatatype.HALFSINGLETOK, TDatatype.SINGLETOK] then ConstVal := ConstVal shl 32;

	    i := j + 1;
	    end else

	begin

	ConstValType := Ident[IdentIndex].DataType;

	if (ConstValType in Pointers) or (Ident[IdentIndex].DataType = TDatatype.STRINGPOINTERTOK) then
	 ConstVal := Ident[IdentIndex].Value - CODEORIGIN
	else
	 ConstVal := Ident[IdentIndex].Value;


	if ConstValType = ENUMTYPE then begin
	  CheckTok(i + 1, TTokenCode.OPARTOK);

	  j := CompileConstExpression(i + 2, ConstVal, ConstValType);

	  if isError then exit;

	  CheckTok(j + 1, TTokenCode.CPARTOK);

	  ConstValType := Tok[i].Kind;

	  i := j + 1;
	end;

	end
    else
      Error(i, TErrorCode.UnknownIdentifier);

    Result := i;
    end;


  TTokenCode.ADDRESSTOK:
    if Tok[i + 1].Kind <> TTokenCode.IDENTTOK then
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
		        ((Ident[IdentIndex].DataType in Pointers) and (Ident[IdentIndex].AllocElementType <> TDatatype.UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0..1])) then
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

			ConstValType := TDatatype.DATAORIGINOFFSET;

//	writeln(Ident[IdentIndex].name,',',Ident[IdentIndex].DataType,',',Ident[IdentIndex].AllocElementType,' / ',ConstVal);

	if (Ident[IdentIndex].DataType in Pointers) and					// zadziala tylko dla ABSOLUTE
	   (Ident[IdentIndex].NumAllocElements > 0) and
	   (Tok[i + 2].Kind = TTokenCode.OBRACKETTOK)  then
	   begin
		j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);			// Array index [xx,

		if isError then Exit;

		CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

		if Tok[j + 1].Kind = TTokenCode.COMMATOK then begin
    		 inc(ConstVal, ArrayIndex * GetDataSize(Ident[IdentIndex].AllocElementType) * Ident[IdentIndex].NumAllocElements_);

		 j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);		// Array index ,yy]

		 if isError then Exit;

		 CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

    		 inc(ConstVal, ArrayIndex * GetDataSize(Ident[IdentIndex].AllocElementType));
		end else
		 inc(ConstVal, ArrayIndex * GetDataSize(Ident[IdentIndex].AllocElementType));

		i := j;

		CheckTok(i + 1, TTokenCode.CBRACKETTOK);
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
	   (Tok[i + 2].Kind = TTokenCode.OBRACKETTOK)  then
	   begin
		j := CompileConstExpression(i + 3, ArrayIndex, ArrayIndexType);			// Array index [xx,

		if isError then Exit;

		CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

		if Tok[j + 1].Kind = TTokenCode.COMMATOK then begin
    		 inc(ConstVal, ArrayIndex * GetDataSize(Ident[IdentIndex].AllocElementType) * Ident[IdentIndex].NumAllocElements_);

		 j := CompileConstExpression(j + 2, ArrayIndex, ArrayIndexType);		// Array index ,yy]

		 if isError then Exit;

		 CheckArrayIndex(j, IdentIndex, ArrayIndex, ArrayIndexType);

    		 inc(ConstVal, ArrayIndex * GetDataSize(Ident[IdentIndex].AllocElementType));
		end else
		 inc(ConstVal, ArrayIndex * GetDataSize(Ident[IdentIndex].AllocElementType));

		i := j;

		CheckTok(i + 1, TTokenCode.CBRACKETTOK);
	   end;

	ConstValType := TTokenCode.POINTERTOK;

       end else
	Error(i + 1, TErrorCode.UnknownIdentifier);

    Result := i + 1;
    end;


  TTokenCode.INTNUMBERTOK:
    begin
     ConstVal := Tok[i].Value;
     ConstValType := GetValueType(ConstVal);

     Result := i;
    end;


  TTokenCode.FRACNUMBERTOK:
    begin
     ConstVal := FromSingle(Tok[i].FracValue);
     ConstValType := TTokenCode.REALTOK;

     Result := i;
    end;


  TTokenCode.STRINGLITERALTOK:
    begin
     ConstVal := Tok[i].StrAddress - CODEORIGIN + CODEORIGIN_BASE;
     ConstValType := TTokenCode.STRINGPOINTERTOK;

     Result := i;
    end;


  TTokenCode.CHARLITERALTOK:
    begin
     ConstVal := Tok[i].Value;
     ConstValType := TTokenCode.CHARTOK;

     Result := i;
    end;


  TTokenCode.OPARTOK:       // a whole expression in parentheses suspected
    begin
     j := CompileConstExpression(i + 1, ConstVal, ConstValType);

     if isError then Exit;

     CheckTok(j + 1, TTokenCode.CPARTOK);

     Result := j + 1;
    end;


  TTokenCode.NOTTOK:
    begin
    Result := CompileConstFactor(i + 1, ConstVal, ConstValType);

    if isError then Exit;

    if ConstValType = TTokenCode.BOOLEANTOK then
     ConstVal := ord(not (ConstVal <> 0) )

    else begin
     ConstVal := not ConstVal;
     ConstValType := GetValueType(ConstVal);
    end;

    end;


  TTokenCode.SHORTREALTOK, TTokenCode.REALTOK, TTokenCode.SINGLETOK, TTokenCode.HALFSINGLETOK:	// Q8.8 ; Q24.8 ; SINGLE 32bit ; FLOAT16
    begin

    CheckTok(i + 1, TTokenCode.OPARTOK);

    j := CompileConstExpression(i + 2, ConstVal, ConstValType);

    if isError then exit;

    if not(ConstValType in RealTypes) then ConstVal:=FromInt64(ConstVal);

    CheckTok(j + 1, TTokenCode.CPARTOK);

    ConstValType := Tok[i].Kind;

    Result := j + 1;

    end;


  TTokenCode.INTEGERTOK, TTokenCode.CARDINALTOK, TTokenCode.SMALLINTTOK, TTokenCode.WORDTOK, TTokenCode.CHARTOK, TTokenCode.PCHARTOK, TTokenCode.SHORTINTTOK, TTokenCode.BYTETOK, TTokenCode.BOOLEANTOK, TTokenCode.POINTERTOK, TTokenCode.STRINGPOINTERTOK:	// type conversion operations
    begin

    CheckTok(i + 1, TTokenCode.OPARTOK);


    if (Tok[i + 2].Kind = TTokenCode.IDENTTOK) and (Ident[GetIdentIndex(Tok[i + 2].Name)].Kind = TTokenCode.FUNCTIONTOK) then
     isError := TRUE
    else
     j := CompileConstExpression(i + 2, ConstVal, ConstValType);


    if isError then exit;


    if (ConstValType in Pointers) and (Tok[i + 2].Kind = TTokenCode.IDENTTOK) and (Tok[i + 3].Kind <> TTokenCode.OBRACKETTOK) then begin

      IdentIndex := GetIdentIndex(Tok[i + 2].Name);

      if (Ident[IdentIndex].DataType in Pointers) and ( (Ident[IdentIndex].NumAllocElements > 0) and (Ident[IdentIndex].AllocElementType <> TTokenCode.RECORDTOK) ) then
       if ((Ident[IdentIndex].AllocElementType <> TTokenCode.UNTYPETOK) and (Ident[IdentIndex].NumAllocElements in [0,1])) or (Ident[IdentIndex].DataType = TTokenCode.STRINGPOINTERTOK) then begin

       end else
	ErrorIdentifierIllegalTypeConversion(i + 2, IdentIndex, Tok[i].Kind);

    end;


    CheckTok(j + 1, TTokenCode.CPARTOK);

    if ConstValType in [TTokenCode.DATAORIGINOFFSET, TTokenCode.CODEORIGINOFFSET] then OldConstValType := ConstValType;

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
  RightConstValType: TDatatype;
begin

ConstVal:=0;
ConstValType:=TTokenCode.UNTILTOK;
Result:=i;

j := CompileConstFactor(i, ConstVal, ConstValType);

if isError then Exit;

while Tok[j + 1].Kind in [TTokenCode.MULTOK, TTokenCode.DIVTOK, TTokenCode.MODTOK, TTokenCode.IDIVTOK, TTokenCode.SHLTOK, TTokenCode.SHRTOK, TTokenCode.ANDTOK] do
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


  if (Tok[j + 1].Kind = TTokenCode.DIVTOK) and (ConstValType in IntegerTypes) then begin
   ConstVal:=FromInt64(ConstVal);
   ConstValType := TDatatype.REALTOK;
  end;

  if (Tok[j + 1].Kind = TTokenCode.DIVTOK) and (RightConstValType in IntegerTypes) then begin
   RightConstVal:=FromInt64(RightConstVal);
   RightConstValType := TDatatype.REALTOK;
  end;


  if (ConstValType in [TDatatype.SINGLETOK, TDatatype.HALFSINGLETOK]) and (RightConstValType in [TDatatype.SHORTREALTOK, TDatatype.REALTOK]) then
   RightConstValType := ConstValType;

  if (RightConstValType in [TDatatype.SINGLETOK, TDatatype.HALFSINGLETOK]) and (ConstValType in [TDatatype.SHORTREALTOK, TDatatype.REALTOK]) then
   ConstValType := RightConstValType;


  case Tok[j + 1].Kind of

    TTokenCode.MULTOK:  ConstVal:=Multiply(ConstValType, ConstVal,RightConstVal);

    TTokenCode.DIVTOK:  begin
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

    TTokenCode.MODTOK:  ConstVal := ConstVal mod RightConstVal;
   TTokenCode.IDIVTOK:  ConstVal := ConstVal div RightConstVal;
    TTokenCode.SHLTOK:  ConstVal := ConstVal shl RightConstVal;
    TTokenCode.SHRTOK:  ConstVal := ConstVal shr RightConstVal;
    TTokenCode.ANDTOK:  ConstVal := ConstVal and RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes + [TTokenCode.BOOLEANTOK]) then
   ConstValType := GetValueType(ConstVal);

  CheckOperator(i, Tok[j + 1].Kind, ConstValType, RightConstValType);

  j := k;
  end;

 Result := j;
end;	//CompileConstTerm


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileSimpleConstExpression(const i: Integer; out ConstVal: Int64; out ConstValType: TDatatype): Integer;
var
  j, k: Integer;
  RightConstVal: Int64;
  RightConstValType: TDatatype;

begin

ConstVal:=0;
ConstValType:=TDatatype.UNTYPETOK;
Result:=i;

if Tok[i].Kind in [TTokenCode.PLUSTOK, TTokenCode.MINUSTOK] then j := i + 1 else j := i;
j := CompileConstTerm(j, ConstVal, ConstValType);

if isError then exit;


if Tok[i].Kind = TTokenCode.MINUSTOK then begin

 ConstVal:=Negate(ConstValType, ConstVal);

end;


 while Tok[j + 1].Kind in [TTokenCode.PLUSTOK, TTokenCode.MINUSTOK, TTokenCode.ORTOK, TTokenCode.XORTOK] do begin

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

  if (ConstValType in [TDatatype.SINGLETOK, TDatatype.HALFSINGLETOK]) and (RightConstValType in [TDatatype.SHORTREALTOK, TDatatype.REALTOK]) then
   RightConstValType := ConstValType;

  if (RightConstValType in [TDatatype.SINGLETOK, TDatatype.HALFSINGLETOK]) and (ConstValType in [TDatatype.SHORTREALTOK, TDatatype.REALTOK]) then
   ConstValType := RightConstValType;


  case Tok[j + 1].Kind of
    TTokenCode.PLUSTOK:  ConstVal := Add( ConstValType, ConstVal, RightConstVal);
    TTokenCode.MINUSTOK: ConstVal := Subtract( ConstValType, ConstVal, RightConstVal);
    TTokenCode.ORTOK:    ConstVal := ConstVal or RightConstVal;
    TTokenCode.XORTOK:   ConstVal := ConstVal xor RightConstVal;
  end;

  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  if not(ConstValType in RealTypes + [TTokenCode.BOOLEANTOK]) then
   ConstValType := GetValueType(ConstVal);

  CheckOperator(i, Tok[j + 1].Kind, ConstValType, RightConstValType);

  j := k;
 end;

Result := j;
end;	//CompileSimpleConstExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


function CompileConstExpression(i: Integer; out ConstVal: Int64; out ConstValType: TDatatype; const VarType: TDatatype = TDatatype.INTEGERTOK; const Err: Boolean = false; const War: Boolean = True): Integer;
var
  j: Integer;
  RightConstVal: Int64;
  RightConstValType: TDatatype;
  Yes: Boolean;
begin

ConstVal:=0;
ConstValType:=TDatatype.UNTYPETOK;
Result:=i;

i := CompileSimpleConstExpression(i, ConstVal, ConstValType);

if isError then exit;

if Tok[i + 1].Kind in [TTokenCode.EQTOK, TTokenCode.NETOK, TTokenCode.LTTOK, TTokenCode.LETOK, TTokenCode.GTTOK, TTokenCode.GETOK] then
  begin

  j := CompileSimpleConstExpression(i + 2, RightConstVal, RightConstValType);
//  CheckOperator(i, Tok[j + 1].Kind, ConstValType);

  case Tok[i + 1].Kind of
    TTokenCode.EQTOK: Yes := ConstVal =  RightConstVal;
    TTokenCode.NETOK: Yes := ConstVal <> RightConstVal;
    TTokenCode.LTTOK: Yes := ConstVal <  RightConstVal;
    TTokenCode.LETOK: Yes := ConstVal <= RightConstVal;
    TTokenCode.GTTOK: Yes := ConstVal >  RightConstVal;
    TTokenCode.GETOK: Yes := ConstVal >= RightConstVal;
  else
   yes := false;
  end;

  if Yes then ConstVal := $ff else ConstVal := 0;
//  ConstValType := GetCommonType(j + 1, ConstValType, RightConstValType);

  ConstValType := TTokenCode.BOOLEANTOK;

  i := j;
  end;


 Result := i;

 if ConstValType in OrdinalTypes + Pointers then
 if VarType in OrdinalTypes + Pointers then begin

  case VarType of
   TDatatype.SHORTINTTOK: Yes := (ConstVal < Low(shortint)) or (ConstVal > High(shortint));
   TDatatype.SMALLINTTOK: Yes := (ConstVal < Low(smallint)) or (ConstVal > High(smallint));
   TDatatype. INTEGERTOK: Yes := (ConstVal < Low(integer)) or (ConstVal > High(integer));
  else
   Yes := (abs(ConstVal) > $FFFFFFFF) or (GetDataSize(ConstValType) > GetDataSize(VarType))
      or ((ConstValType in SignedOrdinalTypes) and (VarType in UnsignedOrdinalTypes));
  end;

 if Yes then
  if Err then begin
   isConst := false;
   isError := false;
   ErrorRangeCheckError(i, ConstVal, VarType);
  end else
   if War then
   if VarType <> TDatatype.BOOLEANTOK then
    WarningForRangeCheckError(i, ConstVal, VarType);

 end;

end;	//CompileConstExpression


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


procedure DefineIdent(const tokenIndex: TTokenIndex; Name: TIdentifierName; Kind: TTokenKind; DataType: TDataType;
  NumAllocElements: Cardinal; AllocElementType: TDataType; Data: Int64; IdType: TDataType = TDatatype.IDENTTOK);
var
  identIndex: Integer;
  NumAllocElements_ : Cardinal;
begin

identIndex := GetIdentIndex(Name);

if (i > 0) and (not (Ident[identIndex].Kind in [TTokenCode.PROCEDURETOK, TTokenCode.FUNCTIONTOK, TTokenCode.CONSTRUCTORTOK, TTokenCode.DESTRUCTORTOK]))
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

    TTokenCode.PROCEDURETOK, TTokenCode.FUNCTIONTOK, TTokenCode.UNITTOK, TTokenCode.CONSTRUCTORTOK, TTokenCode.DESTRUCTORTOK:
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
	VarDataSize := VarDataSize + GetDataSize(DataType);

      Ident[NumIdent].NumAllocElements := NumAllocElements;	// Number of array elements (0 for single variable)
      Ident[NumIdent].NumAllocElements_ := NumAllocElements_;

      Ident[NumIdent].AllocElementType := AllocElementType;

      if not OutputDisabled then begin

       if (DataType = TDatatype.POINTERTOK) and (AllocElementType in [TDatatype.RECORDTOK, TDatatype.OBJECTTOK]) and (NumAllocElements_ = 0) then
        inc(VarDataSize, GetDataSize(TDatatype.POINTERTOK))
       else

       if DataType in [ENUMTYPE] then
        inc(VarDataSize)
       else
       if (DataType in [TDatatype.RECORDTOK, TDatatype.OBJECTTOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 0
       else
       if (DataType in [TDatatype.FILETOK, TDatatype.TEXTFILETOK]) and (NumAllocElements > 0) then
	VarDataSize := VarDataSize + 12
       else begin

        if (Ident[NumIdent].idType = TDatatype.ARRAYTOK) and (Ident[NumIdent].isAbsolute = false) and (Elements(NumIdent) = 1) then	// [0..0] ; [0..0, 0..0]

	else
          if ( Low(_DataSize) <= Ord(AllocElementType) ) and  ( Ord(AllocElementType) <= High(_DataSize) ) then
          begin
 	    VarDataSize := VarDataSize + integer(Elements(NumIdent) * GetDataSize(AllocElementType));
          end;

       end;


       if NumAllocElements > 0 then dec(VarDataSize, GetDataSize(DataType));

      end;

      end;

    CONSTANT, ENUMTYPE:
      begin
      Ident[NumIdent].Value := Data;				// Constant value

      if DataType in Pointers + [TDatatype.ENUMTOK] then begin
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

      if Tok[i].Kind in [TTokenCode.PROCEDURETOK, TTokenCode.CONSTRUCTORTOK, TTokenCode.DESTRUCTORTOK] then
	begin
	DefineIdent(i, '@FN' + IntToHex(NumProc, 4), Tok[i].Kind, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i, '@FN' + IntToHex(NumProc, 4), TTokenCode.FUNCTIONTOK, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;

      NumVarOfSameType := 0;
      ProcVarIndex := NumProc;			// -> NumAllocElements_

      dec(i);

      if (Tok[i + 2].Kind = TTokenCode.OPARTOK) and (Tok[i + 3].Kind = TTokenCode.CPARTOK) then inc(i, 2);

      if Tok[i + 2].Kind = TTokenCode.OPARTOK then						// Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := TParameterPassingMethod.VALPASSING;

	  if Tok[i + 1].Kind = TTokenCode.CONSTTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = TTokenCode.VARTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> TTokenCode.IDENTTOK then
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
	    until Tok[i].Kind <> TTokenCode.COMMATOK;


	  VarType := 0;								// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING])  and (Tok[i].Kind <> TTokenCode.COLONTOK) then begin

	   ListPassMethod := TParameterPassingMethod.VARPASSING;
	   dec(i);

	  end else begin

	   CheckTok(i, TTokenCode.COLONTOK);

	   if Tok[i + 1].Kind = TTokenCode.DEREFERENCETOK then				// ^type
          Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = TTokenCode.FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
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
	until Tok[i].Kind <> TTokenCode.SEMICOLONTOK;

	CheckTok(i, TTokenCode.CPARTOK);

	i := i + 1;
	end// if Tok[i + 2].Kind = OPARTOR
      else
	i := i + 2;

      if IsNestedFunction then
	begin

	CheckTok(i, TTokenCode.COLONTOK);

	if Tok[i + 1].Kind = TTokenCode.ARRAYTOK then
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
     VarType, AllocElementType: TDatatype;
     NumAllocElements: cardinal;
begin

    //FillChar(VarOfSameType, sizeof(VarOfSameType), 0);
    VarOfSameType:=Default(TVariableList);

    if ForwardIdentIndex = 0 then begin

      if Tok[i + 1].Kind <> TTokenCode.IDENTTOK then
	Error(i + 1, TMessage.Create(TErrorCode.ReservedWordUserAsIdentifier, 'Reserved word used as identifier'));

      if Tok[i].Kind in [TTokenCode.PROCEDURETOK, TTokenCode.CONSTRUCTORTOK, TTokenCode.DESTRUCTORTOK] then
	begin
	DefineIdent(i + 1, Tok[i + 1].Name, Tok[i].Kind, 0, 0, 0, 0);
	IsNestedFunction := FALSE;
	end
      else
	begin
	DefineIdent(i + 1, Tok[i + 1].Name, TTokenCode.FUNCTIONTOK, 0, 0, 0, 0);
	IsNestedFunction := TRUE;
	end;


      NumVarOfSameType := 0;

      if (Tok[i + 2].Kind = TTokenCode.OPARTOK) and (Tok[i + 3].Kind = TTokenCode.CPARTOK) then inc(i, 2);

      if Tok[i + 2].Kind = TTokenCode.OPARTOK then						// Formal parameter list found
	begin
	i := i + 2;
	repeat
	  NumVarOfSameType := 0;

	  ListPassMethod := TParameterPassingMethod.VALPASSING;

	  if Tok[i + 1].Kind = TTokenCode.CONSTTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.CONSTPASSING;
	    inc(i);
	    end
	  else if Tok[i + 1].Kind = TTokenCode.VARTOK then
	    begin
	    ListPassMethod := TParameterPassingMethod.VARPASSING;
	    inc(i);
	    end;

	    repeat

	    if Tok[i + 1].Kind <> TTokenCode.IDENTTOK then
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
	    until Tok[i].Kind <> TTokenCode.COMMATOK;


	  VarType := 0;								// UNTYPED
	  NumAllocElements := 0;
	  AllocElementType := 0;

	  if (ListPassMethod in [TParameterPassingMethod.CONSTPASSING, TParameterPassingMethod.VARPASSING])  and (Tok[i].Kind <> TTokenCode.COLONTOK) then begin

	   ListPassMethod := TParameterPassingMethod.VARPASSING;
	   dec(i);

	  end else begin

	   CheckTok(i, TTokenCode.COLONTOK);

	   if Tok[i + 1].Kind = TTokenCode.DEREFERENCETOK then				// ^type
	     Error(i + 1, TMessage.Create(TErrorCode.TypeIdentifierExpected, 'Type identifier expected'));

	   i := CompileType(i + 1, VarType, NumAllocElements, AllocElementType);

	   if (VarType = TTokenCode.FILETOK) and (ListPassMethod <> TParameterPassingMethod.VARPASSING) then
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
	until Tok[i].Kind <> TTokenCode.SEMICOLONTOK;

	CheckTok(i, CPARTOK);

	i := i + 1;
	end// if Tok[i + 2].Kind = TTokenCode.OPARTOR
      else
	i := i + 2;

      NestedFunctionResultType := 0;
      NestedFunctionNumAllocElements := 0;
      NestedFunctionAllocElementType := 0;

      if IsNestedFunction then
	begin

	CheckTok(i, TTokenCode.COLONTOK);

	if Tok[i + 1].Kind = TTokenCode.ARRAYTOK then
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

    CheckTok(i, TTokenCode.SEMICOLONTOK);

    end; //if ForwardIdentIndex = 0


    isForward := false;
    isInt := false;
    isInl := false;
    isOvr := false;

  while Tok[i + 1].Kind in [TTokenCode.OVERLOADTOK, TTokenCode.ASSEMBLERTOK, TTokenCode.FORWARDTOK,
      TTokenCode.REGISTERTOK, TTokenCode.INTERRUPTTOK, TTokenCode.PASCALTOK, TTokenCode.STDCALLTOK,
      TTokenCode.INLINETOK, TTokenCode.EXTERNALTOK, TTokenCode.KEEPTOK] do
  begin

	  case Tok[i + 1].Kind of

	    TTokenCode.OVERLOADTOK: begin
	       		   isOvr := true;
			   Ident[NumIdent].isOverload := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	   TTokenCode.ASSEMBLERTOK: begin
			   Ident[NumIdent].isAsm := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	     TTokenCode.FORWARDTOK: begin

			   if INTERFACETOK_USE then
			    if IsNestedFunction then
			     Error(i, TMessage.Create(TErrorCode.FunctionDirectiveForwardNotAllowedInInterfaceSection, 'Function directive ''FORWARD'' not allowed in interface section'))
			    else
			     Error(i, TMessage.Create(TErrorCode.ProcedureDirectiveForwardNotAllowedInInterfaceSection, 'Procedure directive ''FORWARD'' not allowed in interface section'));

			   isForward := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	    TTokenCode.REGISTERTOK: begin
			   Ident[NumIdent].isRegister := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	     TTokenCode.STDCALLTOK: begin
			   Ident[NumIdent].isStdCall := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	     TTokenCode.INLINETOK: begin
	                   isInl := true;
			   Ident[NumIdent].isInline := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	   TTokenCode.INTERRUPTTOK: begin
			   isInt := true;
			   Ident[NumIdent].isInterrupt := true;
			   Ident[NumIdent].IsNotDead := true;		// Always generate code for interrupt
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	      TTokenCode.PASCALTOK: begin
			   Ident[NumIdent].isRecursion := true;
			   Ident[NumIdent].isPascal := true;
			   inc(i);
			   CheckTok(i + 1, TTokenCode.SEMICOLONTOK);
			 end;

	    EXTERNALTOK: begin
			   Ident[NumIdent].isExternal := true;
			   isForward := true;
			   inc(i);

			   Ident[NumIdent].Alias := '';
			   Ident[NumIdent].Libraries := 0;

			   if Tok[i + 1].Kind = TTokenCode.IDENTTOK then begin

			    Ident[NumIdent].Alias := Tok[i + 1].Name;

			    if Tok[i + 2].Kind = TTokenCode. STRINGLITERALTOK then begin
			      Ident[NumIdent].Libraries := i + 2;

			      inc(i);
			    end;

			    inc(i);

			   end else
			   if Tok[i + 1].Kind = TTokenCode. STRINGLITERALTOK then begin

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


  function BoundaryType: TDatatype;
  begin

    if (LowerBound < 0) or (UpperBound < 0) then begin

     if (LowerBound >= Low(shortint)) and (UpperBound <= High(shortint)) then Result := TDatatype.SHORTINTTOK else
      if (LowerBound >= Low(smallint)) and (UpperBound <= High(smallint)) then Result := TDatatype.SMALLINTTOK else
	Result := TDatatype.INTEGERTOK;

    end else begin

     if (LowerBound >= Low(byte)) and (UpperBound <= High(byte)) then Result := TDatatype.BYTETOK else
      if (LowerBound >= Low(word)) and (UpperBound <= High(word)) then Result := TDatatype.WORDTOK else
	Result := TDatatype.CARDINALTOK;

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


   if FieldType = TDatatype.DEREFERENCEARRAYTOK then begin
    FieldType := TDatatype.POINTERTOK;
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

if Tok[i].Kind = TTokenCode. DEREFERENCETOK then begin				// ^type

 DataType := POINTERTOK;

 if Tok[i + 1].Kind = TTokenCode. STRINGTOK then begin				// ^string
  NumAllocElements := 0;
  AllocElementType := CHARTOK;
  DataType := STRINGPOINTERTOK;
 end else
 if Tok[i + 1].Kind = TTokenCode. IDENTTOK then begin

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

if Tok[i].Kind = TTokenCode. OPARTOK then begin					// enumerated

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

      if Tok[i].Kind = TTokenCode. COMMATOK then inc(i);

    until Tok[i].Kind = TTokenCode. CPARTOK;

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

if Tok[i].Kind = TTokenCode. TEXTFILETOK then begin					// TextFile

 AllocElementType := BYTETOK;
 NumAllocElements := 1;

 DataType := TEXTFILETOK;
 Result := i;

end else

// -----------------------------------------------------------------------------
//				FILE
// -----------------------------------------------------------------------------

if Tok[i].Kind = TTokenCode. FILETOK then begin					// File

 if Tok[i + 1].Kind = TTokenCode. OFTOK then
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

if Tok[i].Kind = TTokenCode. SETTOK then begin					// Set Of

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

  if Tok[i].Kind = TTokenCode. OBJECTTOK then					// Object
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

	  IsNestedFunction := (Tok[i].Kind = TTokenCode. FUNCTIONTOK);

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

      if Tok[i].Kind = TTokenCode. COMMATOK then
	 inc(i)
      else
	ExitLoop := TRUE;

    until ExitLoop;

    CheckTok(i, COLONTOK);

    j := i + 1;

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    if Tok[j].Kind = TTokenCode. ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


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

      if Tok[i].Kind = TTokenCode. ENDTOK then ExitLoop := TRUE else
       if Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] then begin

    	while Tok[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK] do begin

	  IsNestedFunction := (Tok[i].Kind = TTokenCode. FUNCTIONTOK);

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

  if (Tok[i].Kind = TTokenCode. RECORDTOK) or ((Tok[i].Kind = TTokenCode. PACKEDTOK) and (Tok[i+1].Kind = TTokenCode. RECORDTOK)) then		// Record
  begin

  Name := Tok[i-2].Name;

  if Tok[i].Kind = TTokenCode. PACKEDTOK then inc(i);

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

      if Tok[i].Kind = TTokenCode. COMMATOK then
	inc(i)
      else
	ExitLoop := TRUE;

    until ExitLoop;

    CheckTok(i, COLONTOK);

    j := i + 1;

    i := CompileType(i + 1, DataType, NumAllocElements, AllocElementType);

    if Tok[j].Kind = TTokenCode. ARRAYTOK then i := CompileType(i + 3, NestedDataType, NestedNumAllocElements, NestedAllocElementType);


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
      if Tok[i].Kind = TTokenCode. ENDTOK then ExitLoop := TRUE;
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

if Tok[i].Kind = TTokenCode. PCHARTOK then						// PChar
  begin

  DataType := POINTERTOK;
  AllocElementType := CHARTOK;

  NumAllocElements := 0;

  Result:=i;
 end else // Pchar

// -----------------------------------------------------------------------------
//				STRING
// -----------------------------------------------------------------------------

 if Tok[i].Kind = TTokenCode. STRINGTOK then					// String
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

 if (Tok[i].Kind = TTokenCode. ARRAYTOK) or ((Tok[i].Kind = TTokenCode. PACKEDTOK) and (Tok[i + 1].Kind = TTokenCode. ARRAYTOK))  then		// Array
  begin
  DataType := POINTERTOK;

  if Tok[i].Kind = TTokenCode. PACKEDTOK then inc(i);

  CheckTok(i + 1, OBRACKETTOK);

  if Tok[i + 2].Kind in AllTypes + StringTypes then begin

   if Tok[i + 2].Kind = TTokenCode. BYTETOK then begin
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

  if Tok[i + 1].Kind = TTokenCode. COMMATOK then begin				// [0..x, 0..y]

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


  if Tok[i + 3].Kind = TTokenCode. ARRAYTOK then begin
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

 if (Tok[i].Kind = TTokenCode. IDENTTOK) and (Ident[GetIdentIndex(Tok[i].Name)].Kind = TTokenCode. USERTYPE) then
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
