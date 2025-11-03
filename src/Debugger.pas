unit Debugger;

interface

uses SysUtils, Common, CompilerTypes, DataTypes, Parser, Tokens;

type
  IDebugger = interface
    procedure CompileStatement(const tokenIndex: TTokenIndex; const isAsm: Boolean);
    procedure CompileExpression(const tokenIndex: TTokenIndex; const ValType: TDataType; const VarType: TDataType);
    procedure DefineIdent(const tokenIndex: TTokenIndex; const Name: TIdentifierName;
      const Kind: TTokenKind; const DataType: TDataType; const NumAllocElements: TNumAllocElements;
      const AllocElementType: TDataType; const Data: Int64; const IdType: TDataType);
  end;

type
  TDebugger = class(TInterfacedObject, IDebugger)
  public
    constructor Create;
    procedure CompileStatement(const tokenIndex: TTokenIndex; const isAsm: Boolean);
    procedure CompileExpression(const tokenIndex: TTokenIndex; const ValType: TDataType; const VarType: TDataType);
    procedure DefineIdent(const tokenIndex: TTokenIndex; const Name: TIdentifierName;
      const Kind: TTokenKind; const DataType: TDataType; const NumAllocElements: TNumAllocElements;
      const AllocElementType: TDataType; const Data: Int64; const IdType: TDataType);

  private
    function isActive: Boolean;
    function TokenToStr(const tokenIndex: TTokenIndex): String;
    function TokenLocationToStr(const tokenIndex: TTokenIndex): String;
    procedure LogDebug(const message: String);
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
  Result:=DiagMode;
end;

procedure TDebugger.LogDebug(const message: String);
begin
  LogTrace('Debug: ' + message);
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
  Result := Format('%s (line %d, column %d)', [token.SourceLocation.SourceFile.Path,
    token.SourceLocation.Line, token.SourceLocation.Column]);
end;

procedure TDebugger.CompileStatement(const tokenIndex: TTokenIndex; const isAsm: Boolean);
begin
  if isActive then
  begin
    LogDebug(Format('CompileStatement (tokenIndex: %s; isAsm: %s) in %s',
      [TokenToStr(tokenIndex), BoolToStr(isAsm, True), TokenLocationToStr(tokenIndex)]));
  end;
end;

procedure TDebugger.CompileExpression(const tokenIndex: TTokenIndex; const ValType: TDataType;
  const VarType: TDataType);
begin
  if isActive then
  begin
    LogDebug(Format('CompileExpression(tokenIndex: %s; out ValType: %s; VarType: %s) in %s',
      [TokenToStr(tokenIndex), InfoAboutDataType(ValType), InfoAboutDataType(VarType), TokenLocationToStr(tokenIndex)]));
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

end.
