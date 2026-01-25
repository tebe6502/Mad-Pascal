unit Debugger;

interface

uses SysUtils, Common, CompilerTypes, DataTypes, Parser, Tokens;

type
  IDebugger = interface

    // Debugging unit "Compiler".
    procedure BeginPass(const pass: TPass);
    procedure CompileStatement(const tokenIndex: TTokenIndex; const isAsm: Boolean);
    procedure CompileExpression(const tokenIndex: TTokenIndex; const ValType: TDataType; const VarType: TDataType);
    procedure DefineIdent(const tokenIndex: TTokenIndex; const Name: TIdentifierName;
      const Kind: TTokenKind; const DataType: TDataType; const NumAllocElements: TNumAllocElements;
      const AllocElementType: TDataType; const Data: Int64; const IdType: TDataType);

    // Debugging unit "Optimize".
    procedure asm65(const a: String; const comment: String);
    procedure WriteOut(const a: String);

  end;

type
  TDebugger = class(TInterfacedObject, IDebugger)
  public
    constructor Create;


    procedure BeginPass(const pass: TPass);
    procedure CompileStatement(const tokenIndex: TTokenIndex; const isAsm: Boolean);
    procedure CompileExpression(const tokenIndex: TTokenIndex; const ValType: TDataType; const VarType: TDataType);
    procedure DefineIdent(const tokenIndex: TTokenIndex; const Name: TIdentifierName;
      const Kind: TTokenKind; const DataType: TDataType; const NumAllocElements: TNumAllocElements;
      const AllocElementType: TDataType; const Data: Int64; const IdType: TDataType);

    procedure asm65(const a: String; const comment: String);
    procedure WriteOut(const a: String);

  private
  var
    WriteOutLine: Integer;

    function isActive: Boolean;
    function TokenToStr(const tokenIndex: TTokenIndex): String;
    function TokenLocationToStr(const tokenIndex: TTokenIndex): String;
    procedure LogDebug(const message: String);
    procedure StopAtBreakPoint;
  end;


  // Currently global, because COmpiler, Parser,... share it.
var
  debugger: IDebugger;

implementation

constructor TDebugger.Create;
begin

end;

function TDebugger.isActive: Boolean;
begin
  Result := DiagMode;
end;

procedure TDebugger.LogDebug(const message: String);
begin
  LogTrace('Debug: ' + message);
end;

procedure TDebugger.StopAtBreakPoint;
begin

end;

function TDebugger.TokenToStr(const tokenIndex: TTokenIndex): String;
var
  token: TToken;
  lineString: String;
  identifierIndex: TIdentifierIndex;
begin
  token := TokenAt(tokenIndex);
  lineString := token.GetSpelling() + ' ' + token.Name;

  identifierIndex := GetIdentIndex(token.Name);
  if (identifierIndex > 0) then  lineString :=
      Format('%s: %s (identifierIndex=%d)', [lineString, InfoAboutDataType(IdentifierAt(identifierIndex).DataType),
      identifierIndex]);

  Result := Format('%d=%s', [tokenIndex, lineString]);

end;

function TDebugger.TokenLocationToStr(const tokenIndex: TTokenIndex): String;
var
  token: TToken;
begin
  token := TokenAt(tokenIndex);
  Result := SourceLocationToString(token.SourceLocation);
end;

procedure TDebugger.BeginPass(const pass: TPass);
begin
  LogDebug(Format('Pass %d', [Ord(pass)]));
end;

procedure TDebugger.CompileStatement(const tokenIndex: TTokenIndex; const isAsm: Boolean);
begin
  if isActive then
  begin
    LogDebug(Format('CompileStatement (tokenIndex: %s; isAsm: %s) in %s',
      [TokenToStr(tokenIndex), BoolToStr(isAsm, True), TokenLocationToStr(tokenIndex)]));
    if (tokenIndex = 9978) then
    begin
      StopAtBreakPoint;
    end;
  end;
end;

procedure TDebugger.CompileExpression(const tokenIndex: TTokenIndex; const ValType: TDataType;
  const VarType: TDataType);
begin
  if isActive then
  begin
    LogDebug(Format('CompileExpression(tokenIndex: %s; out ValType: %s; VarType: %s) in %s',
      [TokenToStr(tokenIndex), InfoAboutDataType(ValType), InfoAboutDataType(VarType),
      TokenLocationToStr(tokenIndex)]));
  end;
end;

procedure TDebugger.DefineIdent(const tokenIndex: TTokenIndex; const Name: TIdentifierName;
  const Kind: TTokenKind; const DataType: TDataType; const NumAllocElements: TNumAllocElements;
  const AllocElementType: TDataType; const Data: Int64; const IdType: TDataType);
begin
  if isActive then
  begin
    LogDebug(Format(
      'DefineIdent      (tokenIndex: %s; Name: %s; Kind: %s; DataType: %s; NumAllocElements: %d; AllocElementType: %s; Data: %X; IdType: %s) in %s',
      [TokenToStr(tokenIndex), Name, GetTokenSpelling(Kind), InfoAboutDataType(DataType),
      NumAllocElements, InfoAboutDataType(AllocElementType), Data, InfoAboutDataType(IdType),
      TokenLocationToStr(tokenIndex)]));
  end;
end;

procedure TDebugger.asm65(const a: String; const comment: String);
begin

  LogDebug(Format('asm65(''%s'',''%s''', [a, comment]));

  if pos('$BBA', a) > 0 then
  begin
    StopAtBreakPoint;
  end;

end;

procedure TDebugger.WriteOut(const a: String);
begin

  Inc(WriteOutLine);
  if isActive then
  begin
    // if (a<>'') then
    LogDebug(Format('WriteOut Line %d: ''%s''', [WriteOutLine, a]));
    if pos('lda #$FF', a) > 0 then
    begin
      StopAtBreakPoint;
    end;
  end;
end;

end.
