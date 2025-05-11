unit CompilerTypes;

{$I Defines.inc}

interface

uses SysUtils, CommonTypes, Datatypes, FileIO, Tokens;

// ----------------------------------------------------------------------------


// Passes
  {$SCOPEDENUMS ON}
type
  TPass = (NONE, CALL_DETERMINATION, CODE_GENERATION);


// Parameter passing
type
  TParameterPassingMethod = (
    UNDEFINED,
    VALPASSING,   // By value, modifiable
    CONSTPASSING, // By const, unodifiable
    VARPASSING    // By reference, modifiable
    );




const

  // Identifier kind codes

  CONSTANT = TTokenKind.CONSTTOK;
  USERTYPE = TTokenKind.TYPETOK;
  VARIABLE = TTokenKind.VARTOK;
  //  PROC      = TTokenKind.PROCEDURETOK;
  //  FUNC      = TTokenKind.FUNCTIONTOK;
  LABELTYPE = TTokenKind.LABELTOK;
  UNITTYPE = TTokenKind.UNITTOK;

  ENUMTYPE = TTokenKind.ENUMTOK;

  // Compiler parameters

  MAXNAMELENGTH = 32;
  MAXTOKENNAMES = 200;
  MAXSTRLENGTH = 255;
  MAXFIELDS = 256;
  MAXTYPES = 1024;
  //  MAXTOKENS    = 32768;
  MAXPOSSTACK = 512;
  MAXIDENTS = 16384;
  MAXBLOCKS = 16384;  // Maximum number of blocks
  MAXPARAMS = 8;    // Maximum number of parameters for PROC, FUNC
  MAXVARS = 256;    // Maximum number of parameters for VAR
  MAXALLOWEDUNITS = 256;
  MAXDEFINES = 256;    // Max number of $DEFINEs

  CODEORIGIN = $100;
  DATAORIGIN = $8000;


  // Indirection levels

  ASVALUE = 0;
  ASPOINTER = 1;
  ASPOINTERTOPOINTER = 2;
  ASPOINTERTOARRAYORIGIN = 3;  // + GenerateIndexShift
  ASPOINTERTOARRAYORIGIN2 = 4;  // - GenerateIndexShift
  ASPOINTERTORECORD = 5;
  ASPOINTERTOARRAYRECORD = 6;
  ASSTRINGPOINTERTOARRAYORIGIN = 7;
  ASSTRINGPOINTER1TOARRAYORIGIN = 8;
  ASPOINTERTODEREFERENCE = 9;
  ASPOINTERTORECORDARRAYORIGIN = 10;
  ASARRAYORIGINOFPOINTERTORECORDARRAYORIGIN = 11;
  ASPOINTERTOARRAYRECORDTOSTRING = 12;

  ASCHAR = 6;  // GenerateWriteString
  ASBOOLEAN_ = 7;   // TODO Remove _, tempoary solution to prevent formatting
  ASREAL = 8;
  ASSHORTREAL = 9;
  ASHALFSINGLE = 10;
  ASSINGLE = 11;
  ASPCHAR = 12;

  fBlockRead_ParamType: array [1..3] of TTokenKind = (TTokenKind.UNTYPETOK, TTokenKind.WORDTOK, TTokenKind.POINTERTOK);


type

  // Here the prefixes are kept because otherwise the identifiers collide with the Pascal keywords.
  TModifierCode = (mInline, mStdCall, mPascal, mForward, mAssembler, mRegister, mInterrupt, mOverload, mKeep);
  TModifierBits = Word;

  TInterruptCode = (DLI, VBLD, VBLI, TIM1, TIM2, TIM4);

  TIOCode = (OpenRead, ReadRecord, Read, OpenWrite, Append, WriteRecord, Write, OpenReadWrite, FileMode, Close);
  TIOBits = Byte;

  TCode65 =
    (

    je, jne,
    //  jg, jge, jl, jle,
    putCHAR, putEOL,
    addBX, subBX, movaBX_Value,
    imulECX,
    //  notaBX, negaBX, notBOOLEAN,
    addAL_CL, addAX_CX, addEAX_ECX,
    shlAL_CL, shlAX_CL, shlEAX_CL,
    subAL_CL, subAX_CX, subEAX_ECX,
    cmpSTRING, cmpSTRING2CHAR, cmpCHAR2STRING,
    shrAL_CL, shrAX_CL, shrEAX_CL

    //  cmpINT, cmpEAX_ECX, cmpAX_CX, cmpSMALLINT, cmpSHORTINT,
    //  andEAX_ECX, andAX_CX, andAL_CL,
    //  orEAX_ECX, orAX_CX, orAL_CL,
    //  xorEAX_ECX, xorAX_CX xorAL_CL

    );

  TString = String;
  TName = String;


  TDefineIndex = TInteger; // 0 means not found
  TDefineParams = array [1..MAXPARAMS] of TString;

  TDefineName = TName;

  TDefine = record
    Name: TDefineName;
    Macro: String;
    Line: Integer;
    Param: TDefineParams;
  end;

  TParameterName = TName;

  TParam = record
    Name: TParameterName;
    DataType: TDataType;
    NumAllocElements: Cardinal;
    AllocElementType: TDataType;
    PassMethod: TParameterPassingMethod;
    i, i_: Integer;
  end;

  TParamList = array [1..MAXPARAMS] of TParam;


  TIdentifierName = String;

  TVariableList = array [1..MAXVARS] of TParam;
  TFieldName = TName;

  TFieldKind = (UNTYPETOK, OBJECTVARIABLE, RECORDVARIABLE);

  TField = record
    Name: TFieldName;
    Value: Int64;
    DataType: TDataType;
    NumAllocElements: Cardinal;
    AllocElementType: TDataType;
    Kind: TFieldKind;
  end;


  TType = record
    Block: Integer;
    NumFields: Integer;
    Size: Integer;
    Field: array [0..MAXFIELDS] of TField;
  end;

  TUnitName = TName;
  TUnitIndex = Smallint;

  TSourceFileType = (PROGRAM_FILE, UNIT_FILE, INCLUDE_FILE);

  TUnit = class
  public
    UnitIndex: TUnitIndex;
    SourceFileType: TSourceFileType;
    Name: TUnitName;
    Path: TFilePath;
    Units: Integer;
    AllowedUnitNames: array [1..MAXALLOWEDUNITS] of TUnitName;

    function IsRelevant: Boolean;

  end;

  TUnitList = class
  public


    constructor Create();
    destructor Free;

    function Size: Integer;
    function AddUnit(SourceFileType: TSourceFileType; Name: TUnitName; Path: TFilePath): TUnit;
    function GetUnit(const UnitIndex: TUnitIndex): TUnit;

    procedure ClearAllowedUnitNames;

  private
  const
    MAXUNITS = 2048;
  var
    Count: Integer;
    unitArray: array [1..MAXUNITS + MAXUNITS] of TUnit;
  end;

  IUnit = interface
    function Name: TUnitName;
    function Path: TFilePath;
  end;

  TTokenIndex = Integer;

  TToken = class
    TokenIndex: TTokenIndex;
    SourceCodeFile: TUnit;
    UnitIndex: TUnitIndex;
    Column: Smallint;
    Line: Integer;
    Kind: TTokenKind;
    // For Kind=IDENTTOK:
    Name: TIdentifierName;
    // For Kind=INTNUMBERTOK:
    Value: TInteger;
    // For Kind=FRACNUMBERTOK:
    FracValue: Single;
    // For Kind=STRINGLITERALTOK:
    StrAddress: Word;
    StrLength: Word;

    function GetSourceCodeFile: TUnit;
    function GetSpelling: TString;

  end;

  // A token list owns token instances.
  TTokenList = class
  public
  type TTokenArray = array of TToken;
  type TTokenArrayPointer = ^TTokenArray;
    constructor Create(const tokenArrayPointer: TTokenArrayPointer);
    destructor Free;

    function Size: Integer;
    procedure Clear;
    function AddToken(Kind: TTokenKind; SourceCodeFile: TUnit; Line, Column: Integer; Value: TInteger): TToken;
    procedure RemoveToken;

    function GetTokenSpellingAtIndex(const tokenIndex: TTokenIndex): TString;

  private

  var
    tokenArrayPointer: TTokenArrayPointer;

  end;

  TIdentifier = record
    Name: TIdentifierName;
    Value: Int64;      // Value for a constant, address for a variable, procedure or function
    Block: Integer;      // Index of a block in which the identifier is defined
    UnitIndex: Integer;
    Alias: TString;      // EXTERNAL alias 'libraries'
    Libraries: Integer;    // EXTERNAL alias 'libraries'
    DataType: TDataType;
    IdType: TTokenKind; // TODO Have TIdenfierType
    PassMethod: TParameterPassingMethod;
    Pass: TPass;

    NestedNumAllocElements: Cardinal;
    NestedAllocElementType: TDataType;
    NestedDataType: TDataType;

    NestedFunctionNumAllocElements: Cardinal;
    NestedFunctionAllocElementType: TDataType;
    isNestedFunction: Boolean;

    LoopVariable,
    isAbsolute,
    isInit,
    isUntype,
    isInitialized,
    Section: Boolean;

    Kind: TTokenKind;

    //  For kind=PROCEDURETOK, FUNCTIONTOK:
    NumParams: Word;
    Param: TParamList;
    ProcAsBlock: Integer;
    ObjectIndex: Integer;

    IsUnresolvedForward,
    updateResolvedForward,
    isOverload,
    isRegister,
    isInterrupt,
    isRecursion,
    isStdCall,
    isPascal,
    isInline,
    isAsm,
    isExternal,
    isKeep,
    isVolatile,
    isStriped,
    IsNotDead: Boolean;

    //  For kind=VARIABLE, USERTYPE:
    NumAllocElements, NumAllocElements_: Cardinal;
    AllocElementType: TDataType
  end;


  TCallGraphNode = record
    ChildBlock: array [1..MAXBLOCKS] of Integer;
    NumChildren: Word;
  end;


  TResource = record
    resStream: Boolean;
    resName, resType, resFile: TString;
    resValue: Integer;
    resFullName: String;
    resPar: array [1..MAXPARAMS] of TString;
  end;

  TCaseLabel = record
    left, right: Int64;
    equality: Boolean;
  end;

  TPosStack = record
    ptr: Word;
    brk, cnt: Boolean;
  end;

  TForLoop = record
    begin_value, end_value: Int64;
    begin_const, end_const: Boolean;
  end;

  TCaseLabelArray = array of TCaseLabel;


type
  TIdentIndex = Integer;
  TArrayIndex = Integer;

// ----------------------------------------------------------------------------
// Map modifier codes to the bits in the method status.
// ----------------------------------------------------------------------------
procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);

// ----------------------------------------------------------------------------
// Map I/O codes to the bits in the CIO block.
// ----------------------------------------------------------------------------
function GetIOBits(const ioCode: TIOCode): TIOBits;

implementation

function TToken.GetSourceCodeFile: TUnit;
begin
  Result := SourceCodeFile;
end;

function TToken.GetSpelling: TString;
begin
  Result := GetHumanReadbleTokenSpelling(kind);
end;


constructor TTokenList.Create(const tokenArrayPointer: TTokenArrayPointer);
begin
  self.tokenArrayPointer := tokenArrayPointer;
  Clear;
end;

destructor TTokenList.Free;
begin
  Clear;
end;

function TTokenList.Size: Integer;
begin
  Result := High(tokenArrayPointer^);
end;

procedure TTokenList.Clear;
var
  i: Integer;
begin
  for i := Low(tokenArrayPointer^) to High(tokenArrayPointer^) do tokenArrayPointer^[i].Free;

  // Valid token indexes start at 1. The token at index 0 is kept as UNTYPED token.
  SetLength(tokenArrayPointer^, 1);
  tokenArrayPointer^[0] := TToken.Create;
end;

function TTokenList.AddToken(Kind: TTokenKind; SourceCodeFile: TUnit; Line, Column: Integer; Value: TInteger): TToken;
var
  i: Integer;
begin
  assert(SourceCodeFile <> nil, 'No source code file specified');

  Result := TToken.Create;

  // if NumTok > MAXTOKENS then
  //    Error(NumTok, 'Out of resources, TOK');
  i := size + 1;

  Result.TokenIndex := i;
  Result.SourceCodeFile := SourceCodeFile;
  Result.UnitIndex:=SourceCodeFile.UnitIndex;
  Result.Kind := Kind;
  Result.Value := Value;


  if i = 1 then
    Column := 1
  else
  begin

    if tokenArrayPointer^[i - 1].Line <> Line then
    //   Column := 1
    else
      Column := Column + tokenArrayPointer^[i - 1].Column;

  end;

  // if Tok[i- 1].Line <> Line then writeln;

  Result.Line := Line;
  Result.Column := Column;


  SetLength(tokenArrayPointer^, i + 1);
  tokenArrayPointer^[i] := Result;

  // WriteLn('Added token at index ' + IntToStr(i) + ': ' + GetTokenSpelling(kind));
end;

procedure TTokenList.RemoveToken;
var
  i: Integer;
begin
  i := size;
  tokenArrayPointer^[i].Free;
  tokenArrayPointer^[i] := nil;
  SetLength(tokenArrayPointer^, i);

end;


function TTokenList.GetTokenSpellingAtIndex(const tokenIndex: TTokenIndex): TString;
var
  kind: TTokenKind;
begin
  if tokenIndex > Size then
    Result := 'no token'
  else
  begin
    kind := tokenArrayPointer^[tokenIndex].Kind;
    GetHumanReadbleTokenSpelling(kind);
  end;
end;

function TUnit.IsRelevant: Boolean;
begin
  Result := (Name <> '') and (SourceFileType in [TSourceFileType.PROGRAM_FILE, TSourceFileType.UNIT_FILE]);
end;

constructor TUnitList.Create();
var
  i: Integer;
begin

  for i := 1 to MAXUNITS + MAXUNITS do
  begin
    UnitArray[i] := TUnit.Create;
  end;
end;

destructor TUnitList.Free;
var
  i: Integer;
begin
  for i := 1 to MAXUNITS + MAXUNITS do
  begin
    UnitArray[i].Free;
  end;
end;

function TUnitList.Size: Integer;
begin
  Result := Count;
end;


function isIdentifierNameValid(const identifier: TIdentifierName): Boolean;
const
  ALLOWED_START_CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_';
const
  ALLOWED_CHARACTERS = ALLOWED_START_CHARACTERS + '0123456789';
var
  i: Integer;
begin
  if Length(identifier) > 0 then
    if pos(identifier[1], ALLOWED_START_CHARACTERS) > 0 then
    begin
      Result := True;
      for i := 2 to Length(identifier) do
      begin
        if pos(identifier[i], ALLOWED_CHARACTERS) > 0 then
        begin
          Result := False;
          exit;
        end;
      end;

    end;

end;

function TUnitList.AddUnit(SourceFileType: TSourceFileType; Name: TUnitName; Path: TFilePath): TUnit;

begin
  Assert(IsValidIdent(path) = False, 'Name ''' + Name + ''' is not a valid identifier.');
  Assert(Length(path) >= 0, 'Path not specified.');

  // Writeln('Adding unit ''' + Name + ''' with path ''' + path + '''.');

  Result := TUnit.Create;

  // if NumTok > MAXUnitS then
  //    Error(NumTok, 'Out of resources, TOK');
  Inc(Count);

  Result.UnitIndex := Count;
  Result.SourceFileType := SourceFileType;
  Result.Name := Name;
  Result.Path := Path;

  unitArray[Count] := Result;

  // WriteLn('Added Unit at index ' + IntToStr(i) + ': ' + );
end;

function TUnitList.GetUnit(const UnitIndex: TUnitIndex): TUnit;
begin
  assert(UnitIndex >= Low(UnitArray));
  Result := UnitArray[UnitIndex];
end;

procedure TUnitList.ClearAllowedUnitNames;
var
  i: Integer;
begin
  for i := 1 to High(UnitArray) do UnitArray[i].Units := 0;
end;

procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);
begin
  bits := bits or (Word(1) shl Ord(modifierCode));
end;


function GetIOBits(const ioCode: TIOCode): TIOBits;
begin
  case ioCode of
    TIOCode.OpenRead: Result := $04;
    TIOCode.ReadRecord: Result := $05;
    TIOCode.Read: Result := $07;
    TIOCode.OpenWrite: Result := $08;
    TIOCode.Append: Result := $09;
    TIOCode.WriteRecord: Result := $09;
    TIOCode.Write: Result := $0b;
    TIOCode.OpenReadWrite: Result := $0c;
    TIOCode.FileMode: Result := $f0;
    TIOCode.Close: Result := $ff;
    else
      Assert(False, 'Invalid ioCode.');
  end;
end;

end.
