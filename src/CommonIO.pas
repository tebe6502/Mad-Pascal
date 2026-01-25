unit CommonIO;

interface

uses FileIO, SysUtils;

type

  TText = String;

  IReader = interface
    function ReadLn(var Text: TText): Boolean;
  end;

  IWriter = interface
    procedure WriteLn(const Text: TText);
  end;


type

  TFileReader = class(TInterfacedObject, IReader)

  public
    constructor Create(const textFile: ITextFile);

    function ReadLn(var Text: TText): Boolean;

  private
  var
    TextFile: ITextFile;
  end;

  TFileWriter = class(TInterfacedObject, IWriter)

  public
    constructor Create(const textFile: ITextFile);

    procedure WriteLn(const Text: TText);

  private
  var
    TextFile: ITextFile;
  end;

type
  TStringArrayWriter = class(TInterfacedObject, IWriter)
  public
    procedure WriteLn(const Text: TText);

    function GetLines: TStringArray;

  private
  var
    lineArray: TStringArray;
  end;

implementation

// ----------------------------------------------------------------------------
// Class TFileReader
// ----------------------------------------------------------------------------

constructor TFileReader.Create(const textFile: ITextFile);
begin
  Self.TextFile := TextFile;
end;


function TFileReader.ReadLn(var Text: TText): Boolean;
begin
  Result := True;
  try
    TextFile.ReadLn(Text);
  except
    on e: EInOutError do
    begin
      Text := '';
      Result := False;

    end;

  end;

end;

// ----------------------------------------------------------------------------
// Class TFileWriter
// ----------------------------------------------------------------------------

constructor TFileWriter.Create(const textFile: ITextFile);
begin
  Self.TextFile := TextFile;
end;


procedure TFileWriter.WriteLn(const Text: TText);
begin
  TextFile.WriteLn(Text);
end;



// ----------------------------------------------------------------------------
// Class TStringArrayWriter
// ----------------------------------------------------------------------------

procedure TStringArrayWriter.WriteLn(const Text: TText);
var
  l: Integer;
begin
  l := High(lineArray) + 1;
  SetLength(lineArray, l + 1);
  lineArray[l] := Text;
end;

function TStringArrayWriter.GetLines: TStringArray;
begin
  Result := lineArray;
end;

end.
