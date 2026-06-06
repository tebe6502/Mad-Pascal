unit ScannerTypes;

interface

uses Targets;

type
  ITextBuffer = interface
    procedure Clear;
    function Length: Integer;
    function GetString: String;
    function GetUpperCaseString: String;

    procedure Append(const c: Char);
    function CharAt(const position: Integer): Char;

    function EndsWith(const c: Char): Boolean;
    procedure DeleteLastChar();

    procedure ToInverse(const startPosition: Integer);
    procedure ToInternal(const startPosition: Integer);
  end;


type
  TTextBuffer = class(TInterfacedObject, ITextBuffer)
    constructor Create(const TargetID: TTargetID);
    procedure Clear;
    function Length: Integer;
    function GetString: String;
    function GetUpperCaseString: String;

    procedure Append(const c: Char);
    function CharAt(const position: Integer): Char;

    function EndsWith(const c: Char): Boolean;
    procedure DeleteLastChar();

    procedure ToInverse(const startPosition: Integer);
    procedure ToInternal(const startPosition: Integer);
  private
  var
    TargetID: TTargetID;
    TextBuffer_: String;

  end;

implementation

uses SysUtils;

constructor TTextBuffer.Create(const TargetID: TTargetID);
begin
  Self.TargetID := TargetID;
end;

procedure TTextBuffer.Clear;
begin
  TextBuffer_ := '';
end;

function TTextBuffer.Length: Integer;
begin
  Result := System.Length(TextBuffer_);
end;

function TTextBuffer.GetString: String;
begin
  Result := TextBuffer_;
end;

function TTextBuffer.GetUpperCaseString: String;
begin
  Result := AnsiUpperCase(TextBuffer_);
end;

procedure TTextBuffer.Append(const c: Char);
begin
  TextBuffer_ := TextBuffer_ + C;
end;

function TTextBuffer.CharAt(const Position: Integer): Char;
begin
  Result := TextBuffer_[Position];
end;

function TTextBuffer.EndsWith(const c: Char): Boolean;
begin
  Result := (TextBuffer_[System.Length(TextBuffer_)] = c);
end;

procedure TTextBuffer.DeleteLastChar();
begin
  SetLength(TextBuffer_, System.Length(TextBuffer_) - 1);
end;


procedure TTextBuffer.ToInverse(const startPosition: Integer);
begin
  Targets.ConvertStringToInverse(targetID, TextBuffer_, startPosition);
end;


procedure TTextBuffer.ToInternal(const startPosition: Integer);
begin
  Targets.ConvertStringToInternal(targetID, TextBuffer_, startPosition);
end;

end.
