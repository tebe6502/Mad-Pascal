unit CompilerTypes;

{$I Defines.inc}

interface

uses SysUtils, CommonTypes, Datatypes, Tokens;

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
  MAXUNITS = 2048;
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

  TToken = record
    UnitIndex, Column: Smallint;
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

  TUnitName = TName;

  TUnit = record
    Name: TUnitName;
    Path: String;
    Units: Integer;
    Allow: array [1..MAXALLOWEDUNITS] of TString;
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
  TTokenIndex = Integer;
  TIdentIndex = Integer;
  TArrayIndex = Integer;

implementation

end.
