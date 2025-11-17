unit CompilerTypes;

{$I Defines.inc}

interface

uses SysUtils, CommonTypes, DataTypes, FileIO, Tokens;

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
    NumAllocElements, NumAllocElements_: Cardinal;
    AllocElementType: TDataType;
    PassMethod: TParameterPassingMethod;
    i, i_: Integer;
  end;

  TParamList = array [1..MAXPARAMS] of TParam;

  TIdentifierName = String;

  TBlockStackIndex = Integer;
  TBlockIndex = Integer;

  TIdentifier = class;

  // ----------------------------------------------------------------------------
  // Class TBlock and related containers.
  // ----------------------------------------------------------------------------

  TBlock = class
  public
    BlockIndex: TBlockIndex;
    ParentBlock: TBlock;

    constructor Create(const ParentBlock: TBlock);
    destructor Free;
    procedure AddIdentifer(const identifier: TIdentifier);
    function NumIdentifiers: Integer;
    function GetIdentifierAtIndex(const index: Integer): TIdentifier;
    function GetIdentifier(const Name: TIdentifierName): TIdentifier;
  private
    NumIdentifiers_: Integer;
    IdentifierArray: array of TIdentifier;

  end;


  TBlockList = class
  public
    constructor Create;
    destructor Free;

    procedure Clear(const fromIndex: TBlockIndex = 0);
    function AddBlock(const ParentBlock: TBlock): TBlock;
    function Count: Integer;
    function GetBlockAtIndex(const blockIndex: TBlockIndex): TBlock;

  private

  type
    TBlockArray = array of TBlock;

  var
    Count_: Integer;
    Array_: TBlockArray;

  end;

  TBlockStack = class
  public

    constructor Create;
    destructor Free;

    procedure Clear;
    procedure Push(const block: TBlock);
    function Pop: TBlock;
    function Top: TBlock;
    function TopIndex: TBlockStackIndex;
    function GetBlockAtIndex(const blockStackIndex: TBlockStackIndex): TBlock;
    function ToString: String; override;

  private

  type
    TBlockArray = array of TBlock;
  var
    topIndex_: TBlockStackIndex;
    array_: TBlockArray;

  end;

  TBlockManager = class
  public

  var
    BlockList: TBlockList;
    BlockStack: TBlockStack;

    constructor Create;
    destructor Free;
    procedure Initialize;
    function AddBlock: TBlock;
    function AddAndPushBlock: TBlock;

  private
  var
    Block0: TBlock;
  end;


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

  TType = class
    TypeIndex: TTypeIndex;
    BlockIndex: TBlockIndex;
    Size: Integer;
    NumFields: Integer;
    Field: array [0..MAXFIELDS] of TField;
  end;

  TTypeList = class
  public


    constructor Create();
    destructor Free;

    function Size: Integer;
    // function AddType(BlockIndex: TBlockIndex): TType;
    function GetTypeAtIndex(const typeIndex: TTypeIndex): TType;

  const
    MAXTYPES = 1024;

  private
  var
    Count: Integer;
    TypeArray: array of TType;
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
    IdentifierIndex: TIdentifierIndex;

    SourceFile: TSourceFile;
    BlockIndex: TBlockIndex;  // Index of a block in which the identifier is defined
    Name: TIdentifierName;
    Value: Int64;             // Value for a constant, address for a variable, procedure or function

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

    ObjectIndex: TTypeIndex;

    isUnresolvedForward, updateResolvedForward, isOverload, isRegister, isInterrupt,
    isRecursion, isStdCall, isPascal, isInline, isAsm, isExternal, isKeep, isVolatile, isStriped, IsAlive: Boolean;

    //  For kind=VARIABLE, USERTYPE:
    NumAllocElements, NumAllocElements_: Cardinal;
    AllocElementType: TDataType;
    IsObjectVariable: Boolean;

    constructor Create;
    function CastKindToDataType: TDataType;

(**
    function GetIdentResult: TIdentifierIndex;
**)
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

  TCallGraphNode = class

  public
    constructor Create;
    procedure AddChild(const blockIndex: TBlockIndex);
    function NumChildren: Word;
    function GetChild(Index: Word): TBlockIndex;
  private
    NumChildren_: Word;
    ChildBlockArray: array of TBlockIndex;

  end;


  // For dead code elimination
  TCallGraph = class

  public

    constructor Create;
    destructor Free;

    procedure AddChild(const ParentBlock, ChildBlock: TBlockIndex);
    function GetCallGraphNode(blockIndex: TBlockIndex): TCallGraphNode;

    // Mark all identifiers in the identifier list from 1...NumIdent as alive, if the are (in)directly called by the root identifier.
    procedure MarkAlive(const IdentfierList: TIdentifierList; const NumIdent: Integer;
      const rootIdentifierIndex: TIdentifierIndex);

  private
    CallGraphNodeArray: array [1..MAXBLOCKS] of TCallGraphNode;
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
// Class TBlock
// ----------------------------------------------------------------------------

constructor TBlock.Create(const ParentBlock: TBlock);
begin
  Self.ParentBlock := parentBlock;
  NumIdentifiers_ := 0;
  IdentifierArray := nil;
end;

destructor TBlock.Free;
begin
  IdentifierArray := nil;
  NumIdentifiers_ := 0;
end;

procedure TBlock.AddIdentifer(const identifier: TIdentifier);
var
  //  otherIdentifier: TIdentifier;
  capacity: Integer;
begin
  // TODO: Why can the same identifier be there in a block multiple times?
  //  otherIdentifier := GetIdentifier(identifier.Name);
  //  assert(otherIdentifier = nil);

  capacity := Length(IdentifierArray);
  if capacity = 0 then SetLength(IdentifierArray, 10)
  else if NumIdentifiers_ = capacity then SetLength(IdentifierArray, 2 * capacity);
  IdentifierArray[NumIdentifiers_] := identifier;
  Inc(NumIdentifiers_);
end;


function TBlock.NumIdentifiers: Integer;
begin
  Result := NumIdentifiers_;
end;

function TBlock.GetIdentifierAtIndex(const index: Integer): TIdentifier;
begin
  Result := IdentifierArray[index - 1];
end;


// TODO Use map, provided the identifier name is unique inside one block
function TBlock.GetIdentifier(const Name: TIdentifierName): TIdentifier;
var
  index: Integer;
  identifier: TIdentifier;
begin
  for index := 0 to NumIdentifiers_ - 1 do
  begin
    identifier := IdentifierArray[index];
    if identifier.Name = Name then exit(identifier);
  end;
  Result := nil;
end;

// ----------------------------------------------------------------------------
// Class TBlockList
// ----------------------------------------------------------------------------
constructor TBlockList.Create;
begin
  Count_ := -1;
  Array_ := nil;
end;

destructor TBlockList.Free;
begin
  Clear;
end;

procedure TBlockList.Clear(const fromIndex: TBlockIndex = 0);
var
  i: Integer;
begin
  if array_ <> nil then
  begin
    for i := fromIndex to Count_ do FreeAndNil(Array_[i]);
    if (fromIndex = 0) then Array_ := nil;
    Count_ := fromIndex - 1;
  end;
end;

function TBlockList.AddBlock(const ParentBlock: TBlock): TBlock;
var
  Capacity: Integer;
begin
  Inc(Count_);
  Capacity := Length(Array_);
  if capacity = 0 then SetLength(Array_, 256)
  else if Count_ = capacity then SetLength(Array_, 2 * capacity);
  Result := TBlock.Create(ParentBlock);
  Result.BlockIndex := Count_;
  Array_[Count_] := Result;

end;

function TBlockList.Count: Integer;
begin
  Result := Count_;
end;


function TBlockList.GetBlockAtIndex(const blockIndex: TBlockIndex): TBlock;
begin
  assert((blockIndex >= 0) and (blockIndex <= Count_));
  Result := Array_[blockIndex];
end;


// ----------------------------------------------------------------------------
// Class TBlockStack
// ----------------------------------------------------------------------------

constructor TBlockStack.Create;
begin
  Clear;
end;

destructor TBlockStack.Free;
begin
  Clear;
end;

procedure TBlockStack.Clear;
begin
  topIndex_ := -1;
  SetLength(array_, 10);
end;

procedure TBlockStack.Push(const block: TBlock);
var
  Capacity: Integer;
begin
  Inc(topIndex_);
  Capacity := Length(array_); // Never 0
  if topIndex_ = Capacity then SetLength(array_, Capacity * 2);
  array_[topIndex_] := block;

  //if     block.BlockIndex=134 then
  //WriteLn(' TBlockStack.Push: ', block.BlockIndex, ' topIndex=', topIndex_);
end;

function TBlockStack.Pop: TBlock;
begin
  assert(topIndex_ >= 0);
  Result := array_[topIndex_];
  Dec(topIndex_);
  // WriteLn(' TBlockStack.Pop: ', Result.BlockIndex, ' topIndex=', topIndex_);
end;

function TBlockStack.GetBlockAtIndex(const blockStackIndex: TBlockStackIndex): TBlock;
begin
  Result := array_[blockStackIndex];
end;

function TBlockStack.TopIndex: TBlockStackIndex;
begin
  Result := topIndex_;
end;

function TBlockStack.Top: TBlock;
begin
  Result := array_[topIndex];
end;


function TBlockStack.ToString: String;
var
  i: TBlockStackIndex;
begin
  Result := '/';
  for i := 0 to topIndex_ do Result := Result + IntToStr(GetBlockAtIndex(i).BlockIndex) + '/';
end;


// ----------------------------------------------------------------------------
// Class TBlockManager
// ----------------------------------------------------------------------------

constructor TBlockManager.Create;
begin
  BlockList := TBlockList.Create;
  BlockStack := TBlockStack.Create;
  Block0 := BlockList.AddBlock(nil);
end;


destructor TBlockManager.Free;
begin
  BlockStack.Free;
  BlockList.Free;
end;


procedure TBlockManager.Initialize;
begin
  BlockStack.Clear;
  BlockList.Clear(1);
  BlockStack.Push(block0);
end;

function TBlockManager.AddBlock: TBlock;
begin
  Result := BlockList.AddBlock(BlockStack.Top);
end;

function TBlockManager.AddAndPushBlock: TBlock;
begin
  Result := AddBlock();
  BlockStack.Push(Result);
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
constructor TIdentifier.Create;
begin

end;

function TIdentifier.CastKindToDataType: TDataType;
begin
  // TODO Check that this can really be converted to a data type.
  Result := GetTokenDataType(kind);
end;

(**
function TIdentifier.GetIdentResult: TIdentIndex;
var
  IdentIndex: Integer;
begin

  Result := 0;

  for IdentIndex := 1 to NumIdent do
    if (IdentifierAt(IdentIndex).BlockIndex = ProcAsBlock) and (IdentifierAt(IdentIndex).Name = 'RESULT') then
      exit(IdentIndex);

end;
**)

// ----------------------------------------------------------------------------
// Class TIdentifierList
// ----------------------------------------------------------------------------

constructor TIdentifierList.Create;
begin
  IdentifierArray := nil;
  Clear;
end;

destructor TIdentifierList.Free;
begin
  Clear;
end;

function TIdentifierList.Size: Integer;
begin
  Result := High(IdentifierArray);
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
// Class TTypeList
// ----------------------------------------------------------------------------

constructor TTypeList.Create();
var
  i: Integer;
begin
  TypeArray := nil;
  SetLength(TypeArray, MAXTYPES);
  for i := Low(TypeArray) to High(TypeArray) do
  begin
    TypeArray[i] := TType.Create;
    TypeArray[i].TypeIndex := i;
  end;
end;

destructor TTypeList.Free;
var
  i: Integer;
begin
  if TypeArray <> nil then
  begin
    for i := Low(TypeArray) to High(TypeArray) do TypeArray[i].Free;
  end;

end;

function TTypeList.Size: Integer;
begin
  Result := High(TypeArray);
end;

function TTypeList.GetTypeAtIndex(const TypeIndex: TTypeIndex): TType;
begin
  {$IFDEF DEBUG}
  if (typeIndex<Low(TypeArray)) or (typeIndex>High(TypeArray)) then
  begin
    Writeln('ERROR: typeIndex=',typeIndex);
    Exit(Default(TType));
  end;
  {$ENDIF}

  Result := TypeArray[TypeIndex];
end;


// ----------------------------------------------------------------------------
// Class TCallGraphNode
// ----------------------------------------------------------------------------

constructor TCallGraphNode.Create;
begin
  NumChildren_ := 0;
  ChildBlockArray := nil;
end;

procedure TCallGraphNode.AddChild(const blockIndex: TBlockIndex);
var
  Capacity: Integer;
begin
  Capacity := Length(ChildBlockArray);
  if Capacity = 0 then SetLength(ChildBlockArray, 10)
  else if NumChildren_ = Capacity then SetLength(ChildBlockArray, 2 * capacity);
  ChildBlockArray[NumChildren_] := blockIndex;
  Inc(NumChildren_);
end;

function TCallGraphNode.NumChildren: Word;
begin
  Result := NumChildren_;
end;

function TCallGraphNode.GetChild(Index: Word): TBlockIndex;
begin
  Result := ChildBlockArray[Index - 1];
end;

// ----------------------------------------------------------------------------
// Class TCallGraph
// ----------------------------------------------------------------------------

constructor TCallGraph.Create;
var
  i: TBlockIndex;
begin
  for i := 1 to MAXBLOCKS do CallGraphNodeArray[i] := TCallGraphNode.Create;
end;

destructor TCallGraph.Free;
var
  i: TBlockIndex;
begin

  for i := 1 to MAXBLOCKS do
  begin
    FreeAndNil(CallGraphNodeArray[i]);
  end;
end;

procedure TCallGraph.AddChild(const ParentBlock, ChildBlock: TBlockIndex);
begin

  if ParentBlock <> ChildBlock then
  begin
    CallGraphNodeArray[ParentBlock].AddChild(ChildBlock);
  end;

end;

function TCallGraph.GetCallGraphNode(blockIndex: TBlockIndex): TCallGraphNode;
begin
  Result := CallGraphNodeArray[blockIndex];
end;

procedure TCallGraph.MarkAlive(const IdentfierList: TIdentifierList; const NumIdent: Integer;
  const rootIdentifierIndex: TIdentifierIndex);
type
  TBooleanArray = array [1..MAXBLOCKS] of Boolean;
var
  ProcAsBlock: TBooleanArray;

  procedure MarkNotDead(const Identifier: TIdentifier);
  var
    ProcAsBlockIndex: TBlockIndex;
    CallGraphNode: TCallGraphNode;
    ChildIndex: Word;
    ChildIdentIndex: TIdentIndex;
    ChildIdentifier: TIdentifier;
  begin

    Identifier.IsAlive := True;

    ProcAsBlockIndex := Identifier.ProcAsBlockIndex;

    if (ProcAsBlockIndex > 0) and (ProcAsBlock[ProcAsBlockIndex] = False) then
    begin
      CallGraphNode := CallGraphNodeArray[ProcAsBlockIndex];
      if (CallGraphNode.NumChildren > 0) then
      begin

        ProcAsBlock[ProcAsBlockIndex] := True;

        for ChildIndex := 1 to CallGraphNode.NumChildren do
          for ChildIdentIndex := 1 to NumIdent do
          begin
            ChildIdentifier := IdentfierList.GetIdentifierAtIndex(ChildIdentIndex);
            if { (ChildIdentifier.ProcAsBlockIndex > 0) and  } (ChildIdentifier.ProcAsBlockIndex =
              CallGraphNode.GetChild(ChildIndex)) then
            begin
              MarkNotDead(ChildIdentifier);
            end;
          end;

      end;
    end;

  end;

begin

  ProcAsBlock := Default(TBooleanArray);

  // Perform dead code elimination
  MarkNotDead(IdentfierList.GetIdentifierAtIndex(rootIdentifierIndex));

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
