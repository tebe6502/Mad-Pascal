unit CommonIO;

interface

uses FileIO;

type
  IWriter = interface
    procedure Write(const Text: String);
    procedure WriteLn(const Text: String);
  end;


type
  TFileWriter = class(TInterfacedObject, IWriter)

  public
    constructor Create(const textFile: ITextFile);

    procedure Write(const Text: String);
    procedure WriteLn(const Text: String);

  private
  var
    TextFile: ITextFile;
  end;

implementation

constructor TFileWriter.Create(const textFile: ITextFile);
begin
  Self.TextFile := TextFile;
end;


procedure TFileWriter.Write(const Text: String);
begin
  TextFile.Write(Text);
end;

procedure TFileWriter.WriteLn(const Text: String);
begin
  TextFile.WriteLn(Text);
end;

end.
