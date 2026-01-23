unit CommonIO;

interface

uses SysUtils;

type

  TText = String;

  IWriter = interface
    procedure WriteLn(const aTextFile: TText);
  end;


type
  TTextFileWriter = class(TInterfacedObject, IWriter)
  public
    constructor Create(var aTextFile: Text);
    procedure WriteLn(const Text: TText);

  private
  var
    textFile: ^Text;
  end;

implementation



// ----------------------------------------------------------------------------
// Class TTextFileWriter
// ----------------------------------------------------------------------------

constructor TTextFileWriter.Create(var aTextFile: Text);
begin
  textFile := @aTextFile;
end;

procedure TTextFileWriter.WriteLn(const Text: TText);
begin
  System.WriteLn(textFile^, text);
end;


end.
