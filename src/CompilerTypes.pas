unit CompilerTypes;

{$I Defines.inc}

interface

uses SysUtils, CommonTypes, Datatypes, FileIO, Tokens, Utilities;

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
type
  TIndirectionLevel = Byte;

const
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

  fBlockRead_ParamType: array [1..3] of TDataType = (TDataType.UNTYPETOK, TDataType.WORDTOK, TDataType.POINTERTOK);


type

  // Here the prefixes are kept because otherwise the identifiers collide with the Pascal keywords.
  TModifierCode = (mInline, mStdCall, mPascal, mForward, mAssembler, mRegister, mInterrupt, mOverload, mKeep);
  TModifierBits = Word;

  TInterruptCode = (DLI, VBLD, VBLI, TIM1, TIM2, TIM4);

  TIOCode = (OpenRead, ReadRecord, Read, OpenWrite, Append, WriteRecord, Write, OpenReadWrite, FileMode, Close);
  TIOBits = Byte;

  TCode65 =
    (

    // je, jne,
    // jg, jge, jl, jle,
    putCHAR, putEOL,
    addBX, subBX, movaBX_Value,
    imulECX,
    //  notaBX, negaBX, notBOOLEAN,
    addAL_CL, addAX_CX, addEAX_ECX,
    shlAL_CL, shlAX_CL, shlEAX_CL,
    subAL_CL, subAX_CX, subEAX_ECX,
    // cmpSTRING, cmpSTRING2CHAR, cmpCHAR2STRING,
    shrAL_CL, shrAX_CL, shrEAX_CL

    // cmpINT, cmpEAX_ECX, cmpAX_CX, cmpSMALLINT, cmpSHORTINT,
    // andEAX_ECX, andAX_CX, andAL_CL,
    // orEAX_ECX, orAX_CX, orAL_CL,
    // xorEAX_ECX, xorAX_CX xorAL_CL

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

  TBlockStackIndex = Integer;
  TBlockIndex = Integer;

  TBlock = class
  public
    BlockIndex: TBlockIndex;
    // TODO: Identifiers defined in this block
  end;

  TBlockStack = class
  public

    constructor Create;
    destructor Free;

    function Push: TBlock;
    function Pop: TBlock;
    function Top: TBlock;
  private
  type TBlockArray = array of TBlock;

  var
    blockArray: TBlockArray;
  var
    stackTopIndex: TBlockStackIndex;
  end;

  TIdentifierName = String;

  TVariableList = array [1..MAXVARS] of TParam;
  TFieldName = TName;

  TFieldKind = (UNTYPETOK, OBJECTVARIABLE, RECORDVARIABLE);

  // The lower 16 bits encode the size of the 1st array dimension.
  // The upper 16 bits encode the size of the 2nd array dimension.
  TNumAllocElements = Cardinal;

  TField = record
    Name: TFieldName;
    Value: Int64;
    DataType: TDataType;
    NumAllocElements: TNumAllocElements;
    AllocElementType: TDataType;
    Kind: TFieldKind;
    ObjectVariable: Boolean;
  end;


  TTypeIndex = Integer;

  TType = record
    BlockIndex: TBlockIndex;
    NumFields: Integer;
    Size: Integer;
    Field: array [0..MAXTYPES] of TField;
  end;

  TSourceFileName = TName;
  TSourceFileIndex = Smallint;

  TSourceFileType = (PROGRAM_FILE, UNIT_FILE, INCLUDE_FILE);

  TSourceFile = class
  public
    UnitIndex: TSourceFileIndex;
    SourceFileType: TSourceFileType;
    Name: TSourceFileName;
    Path: TFilePath;

    function IsRelevant: Boolean;

    procedure ClearAllowedUnitNames;
    function AddAllowedUnitName(const unitName: TSourceFileName): Boolean;
    function IsAllowedUnitName(const unitName: TSourceFileName): Boolean;

  private
    _Units: Integer;
    _AllowedUnitNames: array [1..MAXALLOWEDUNITS] of TSourceFileName;

  end;

  TSourceLocation = record
    SourceFile: TSourceFile;
    Line: Integer;
    Column: Integer;
  end;

  TSourceFileList = class
  public


    constructor Create();
    destructor Free;

    function Size: Integer;
    function AddUnit(SourceFileType: TSourceFileType; Name: TSourceFileName; Path: TFilePath): TSourceFile;
    function GetSourceFile(const SourceFileIndex: TSourceFileIndex): TSourceFile;

    procedure ClearAllowedUnitNames;

  private
  const
    MAXUNITS = 4096;
  var
    Count: Integer;
    SourceFileArray: array [1..MAXUNITS] of TSourceFile;
  end;

  TTokenIndex = Integer;

  TToken = class
    TokenIndex: TTokenIndex;
    SourceLocation: TSourceLocation;
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

    function GetSourceFile: TSourceFile;
    function GetSourceFileName: TSourceFileName;
    function GetSourceFileLineString: String;
    function GetSourceFileLocationString: String;

    // TODO: Check all IF statements of the for IF TokenAt(i).GetDataType = or in []
    // They should be rewritten as "HasDataDataType"
    function GetDataType: TDataType;

    function GetSpelling: TString;

  end;

  // A token list owns token instances.
  TTokenList = class
  public

    constructor Create;
    destructor Free;

    function Size: Integer;
    procedure Clear;
    function AddToken(Kind: TTokenKind; SourceFile: TSourceFile; Line, Column: Integer; Value: TInteger): TToken;
    procedure RemoveToken;
    function GetTokenAtIndex(const tokenIndex: TTokenIndex): TToken; inline;
    function GetTokenSpellingAtIndex(const tokenIndex: TTokenIndex): TString;

  private
  type TTokenArray = array of TToken;
  var
    tokenArray: TTokenArray;

  end;

  TIdentifierIndex = Integer;

  TIdentifier = class
    Name: TIdentifierName;
    Value: Int64;             // Value for a constant, address for a variable, procedure or function
    BlockIndex: TBlockIndex;  // Index of a block in which the identifier is defined
    SourceFile: TSourceFile;
    Alias: TString;           // EXTERNAL alias 'libraries'
    Libraries: Integer;       // EXTERNAL alias 'libraries'
    DataType: TDataType;
    IdType: TDataType;       // TODO Have TIdenfierType
    PassMethod: TParameterPassingMethod;
    Pass: TPass;

    NestedNumAllocElements: Cardinal;
    NestedAllocElementType: TDataType;
    NestedDataType: TDataType;

    NestedFunctionNumAllocElements: Cardinal;
    NestedFunctionAllocElementType: TDataType;
    IsNestedFunction: Boolean;

    IsLoopVariable, IsAbsolute, IsInit, IsUntype, IsInitialized, IsSection: Boolean;

    Kind: TTokenKind;

    //  For kind=PROCEDURETOK, FUNCTIONTOK:
    NumParams: Word;
    Param: TParamList;
    ProcAsBlockIndex: TBlockIndex;
    ObjectIndex: Integer;

    isUnresolvedForward, updateResolvedForward, isOverload, isRegister, isInterrupt,
    isRecursion, isStdCall, isPascal, isInline, isAsm, isExternal, isKeep, isVolatile,
    isStriped, IsNotDead: Boolean;

    //  For kind=VARIABLE, USERTYPE:
    NumAllocElements, NumAllocElements_: Cardinal;
    AllocElementType: TDataType;
    IsObjectVariable: Boolean;

    function CastKindToDataType: TDataType;
  end;

  // An identifier list owns identifier instances.
  TIdentifierList = class
  public

    constructor Create;
    destructor Free;

    function Size: Integer;
    procedure Clear;
    function AddIdentifier: TIdentifier;
    function GetIdentifierAtIndex(const identifierIndex: TIdentifierIndex): TIdentifier; inline;

    // The following type and array should be considered private.
    // The are only public for access in specially optimized prodedures.
  type TIdentifierArray = array of TIdentifier;
  var
    identifierArray: TIdentifierArray;

  end;

  TCallGraphNode = record
    ChildBlock: array [1..MAXBLOCKS] of TBlockIndex;
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

// ----------------------------------------------------------------------------
// Class TBlockStack
// ----------------------------------------------------------------------------


constructor TBlockStack.Create;
begin
  SetLength(blockArray, 0);
  stackTopIndex := 0;
end;

destructor TBlockStack.Free;
begin

end;

function TBlockStack.Push: TBlock;
begin
  // TODO
end;

function TBlockStack.Pop: TBlock;
begin
  // TODO
end;

function TBlockStack.Top: TBlock;
begin
  // TODO
end;

// ----------------------------------------------------------------------------
// Class TSourceFile
// ----------------------------------------------------------------------------
function TSourceFile.IsRelevant: Boolean;
begin
  Result := (Name <> '') and (SourceFileType in [TSourceFileType.PROGRAM_FILE, TSourceFileType.UNIT_FILE]);
end;

procedure TSourceFile.ClearAllowedUnitNames;
begin
  _Units := 0;
end;

function TSourceFile.AddAllowedUnitName(const unitName: TSourceFileName): Boolean;
begin

  if _Units < High(_AllowedUnitNames) then
  begin
    Inc(_Units);
    _AllowedUnitNames[_Units] := unitName;
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

function TSourceFile.IsAllowedUnitName(const unitName: TSourceFileName): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := _Units downto 1 do
    if _AllowedUnitNames[i] = unitName then exit(True);
end;

// ----------------------------------------------------------------------------
// Class TSourceFileList
// ----------------------------------------------------------------------------

constructor TSourceFileList.Create();
var
  i: Integer;
begin

  for i := Low(SourceFileArray) to High(SourceFileArray) do
  begin
    SourceFileArray[i] := TSourceFile.Create;
  end;
end;

destructor TSourceFileList.Free;
var
  i: Integer;
begin
  for i := Low(SourceFileArray) to High(SourceFileArray) do
  begin
    SourceFileArray[i].Free;
  end;
end;

function TSourceFileList.Size: Integer;
begin
  Result := Count;
end;


function TSourceFileList.AddUnit(SourceFileType: TSourceFileType; Name: TSourceFileName; Path: TFilePath): TSourceFile;
begin
  Assert(IsValidIdent(path) = False, 'Name ''' + Name + ''' is not a valid identifier.');
  Assert(Length(path) >= 0, 'Path not specified.');

  // Writeln('Adding unit ''' + Name + ''' with path ''' + path + '''.');

  Result := TSourceFile.Create;

  // if Count >= MAXSOURCEFILES then
  //    Error(Count, 'Out of resources, TOK');
  Inc(Count);

  Result.UnitIndex := Count;
  Result.SourceFileType := SourceFileType;
  Result.Name := Name;
  Result.Path := Path;

  SourceFileArray[Result.UnitIndex] := Result;
end;

function TSourceFileList.GetSourceFile(const SourceFileIndex: TSourceFileIndex): TSourceFile;
begin
  assert(SourceFileIndex >= Low(SourceFileArray));
  Result := SourceFileArray[SourceFileIndex];
end;

procedure TSourceFileList.ClearAllowedUnitNames;
var
  i: Integer;
begin
  for i := 1 to High(SourceFileArray) do SourceFileArray[i].ClearAllowedUnitNames;
end;



// ----------------------------------------------------------------------------
// Class TToken
// ----------------------------------------------------------------------------
function TToken.GetSourceFile: TSourceFile;
begin
  Result := SourceLocation.SourceFile;
end;

function TToken.GetSourceFileName: TSourceFileName;
begin
  Result := SourceLocation.SourceFile.Name;
end;

function TToken.GetSourceFileLineString: String;
begin
  Result := SourceLocation.SourceFile.Path + ' ( line ' + IntToStr(SourceLocation.Line) + ')';
end;

function TToken.GetSourceFileLocationString: String;
begin
  if SourceLocation.SourceFile <> nil then
  begin
    Result := SourceLocation.SourceFile.Path + ' ( line ' + IntToStr(SourceLocation.Line) +
      ', column ' + IntToStr(SourceLocation.Column) + ')';
  end;
end;

function TToken.GetDataType: TDataType;
begin
  Result := GetTokenDataType(kind);
end;

function TToken.GetSpelling: TString;
begin
  Result := GetHumanReadbleTokenSpelling(kind);
end;


// ----------------------------------------------------------------------------
// Class TTokenList
// ----------------------------------------------------------------------------

constructor TTokenList.Create;
begin
  tokenArray := nil;
  Clear;
end;

destructor TTokenList.Free;
begin
  Clear;
end;

function TTokenList.Size: Integer;
begin
  Result := High(tokenArray);
end;

procedure TTokenList.Clear;
var
  i: Integer;
begin
  if tokenArray <> nil then
  begin
    for i := Low(tokenArray) to High(tokenArray) do tokenArray[i].Free;
  end;

  // Valid token indexes start at 1. The token at index 0 is kept as UNTYPED token.
  SetLength(tokenArray, 1);
  tokenArray[0] := TToken.Create;
end;

function TTokenList.AddToken(Kind: TTokenKind; SourceFile: TSourceFile; Line, Column: Integer;
  Value: TInteger): TToken;
var
  i: Integer;
begin
  assert(SourceFile <> nil, 'No source code file specified');

  Result := TToken.Create;

  // if size >= MAXTOKENS then
  //    Error(NumTok, 'Out of resources, TOK');
  i := size + 1;

  Result.TokenIndex := i;
  Result.SourceLocation.SourceFile := SourceFile;
  // Result.UnitIndex:=SourceFile.UnitIndex;
  Result.Kind := Kind;
  Result.Value := Value;


  if i = 1 then
    Column := 1
  else
  begin

    if tokenArray[i - 1].SourceLocation.Line <> Line then
    //   Column := 1
    else
      Column := Column + tokenArray[i - 1].SourceLocation.Column;

  end;

  // if tokenArray[i- 1].Line <> Line then writeln;

  Result.SourceLocation.Line := Line;
  Result.SourceLocation.Column := Column;


  SetLength(tokenArray, i + 1);
  tokenArray[i] := Result;

  // WriteLn('Added token at index ' + IntToStr(i) + ': ' + GetTokenSpelling(kind));
end;

procedure TTokenList.RemoveToken;
var
  i: Integer;
begin
  i := size;
  tokenArray[i].Free;
  tokenArray[i] := nil;
  SetLength(tokenArray, i);

end;

function TTokenList.GetTokenAtIndex(const tokenIndex: TTokenIndex): TToken; inline;
begin
  {$IFDEF ASSERT_ARRAY_BOUNDARIES}
  if (tokenIndex < Low(tokenArray)) then
  begin
    Writeln('ERROR: Array index ', tokenIndex, ' is smaller than the lower bound ', Low(tokenArray));
    RaiseHaltException(EHaltException.COMPILING_ABORTED);
  end;

  if (tokenIndex > High(tokenArray)) then
  begin
    Writeln('ERROR: Array index ', tokenIndex, ' is greater than the upper bound ', High(tokenArray));
    RaiseHaltException(EHaltException.COMPILING_ABORTED);
  end;
  {$ENDIF}
  Result := tokenArray[tokenIndex];
end;

function TTokenList.GetTokenSpellingAtIndex(const tokenIndex: TTokenIndex): TString;
var
  kind: TTokenKind;
begin
  Result := '';
  if tokenIndex > Size then
    Result := 'no token'
  else
  begin
    kind := tokenArray[tokenIndex].Kind;
    GetHumanReadbleTokenSpelling(kind);
  end;
end;

// ----------------------------------------------------------------------------
// Class TIdentifier
// ----------------------------------------------------------------------------
function TIdentifier.CastKindToDataType: TDataType;
begin
  // TODO Check that this can really be converted to a data type.
  Result := GetTokenDataType(kind);
end;

// ----------------------------------------------------------------------------
// Class TIdentifierList
// ----------------------------------------------------------------------------

constructor TIdentifierList.Create;
begin
  identifierArray := nil;
  Clear;
end;

destructor TIdentifierList.Free;
begin
  Clear;
end;

function TIdentifierList.Size: Integer;
begin
  Result := High(identifierArray);
end;

procedure TIdentifierList.Clear;
var
  i: Integer;
begin
  if identifierArray <> nil then
  begin
    for i := Low(identifierArray) to High(identifierArray) do identifierArray[i].Free;
  end;

  // Valid identifier indexes start at 1. The identifier at index 0 is kept as UNTYPED identifier.
  SetLength(identifierArray, 1);
  identifierArray[0] := TIdentifier.Create;
end;

function TIdentifierList.AddIdentifier(): TIdentifier;
var
  i: Integer;
begin
  Result := TIdentifier.Create;

  // if size >= MAXIDENTS then
  //    Error(NumIdent, 'Out of resources, IDENT');
  i := size + 1;

  // Result.IdentifierIndex := i;

  SetLength(identifierArray, i + 1);
  identifierArray[i] := Result;
end;


function TIdentifierList.GetIdentifierAtIndex(const identifierIndex: TIdentifierIndex): TIdentifier; inline;
begin
  {$IFDEF ASSERT_ARRAY_BOUNDARIES}
  if (identifierIndex < Low(identifierArray)) then
  begin
    Writeln('ERROR: Array index ', identifierIndex, ' is smaller than the lower bound ', Low(identifierArray));
    RaiseHaltException(eHaltException.COMPILING_ABORTED);
  end;

  if (identifierIndex > High(identifierArray)) then
  begin
    Writeln('ERROR: Array index ', identifierIndex, ' is greater than the upper bound ', High(identifierArray));
    RaiseHaltException(EHaltException.COMPILING_ABORTED);
  end;
  {$ENDIF}
  Result := identifierArray[identifierIndex];
end;

// ----------------------------------------------------------------------------
// Global procedures and functions.
// ----------------------------------------------------------------------------

procedure SetModifierBit(const modifierCode: TModifierCode; var bits: TModifierBits);
begin
  bits := bits or (Word(1) shl Ord(modifierCode));
end;


function GetIOBits(const ioCode: TIOCode): TIOBits;
begin
  Result := $00;
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
