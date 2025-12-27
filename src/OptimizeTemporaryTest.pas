unit OptimizeTemporaryTest;

interface

procedure Test;

implementation

uses Asserts, CompilerTypes, CommonIO, OptimizeTemporary, FileIO, SysUtils;

function ReadTextFile(filePath: TFilePath): TStringArray;
var
  textFile: ITextFile;
  s: String;
  i: Integer;
begin
  textFile := TFileSystem.CreateTextFile;
  textFile.Assign(filePath);
  textFile.Reset;

  Result := nil;
  i := 0;
  s := '';
  while not textFile.EOF do
  begin
    textFile.ReadLn(s);
    SetLength(Result, i + 1);
    Result[i] := s;
    Inc(i);

  end;
end;

procedure AssertWriteOutEquals(const InputLines: TStringArray; const OutputLines: TStringArray);
var
  AsmBlockArray: TAsmBlockArray;
  ActualWriter: TStringArrayWriter;
  OptimizeTemporary: IOptimizeTemporary;
  i: Integer;
begin
  AsmBlockArray := Default(TAsmBlockArray);
  ActualWriter := TStringArrayWriter.Create;
  OptimizeTemporary := TOptimizeTemporary.Create;
  OptimizeTemporary.Initialize(AsmBlockArray, ActualWriter);
  for i := Low(InputLines) to High(InputLines) do
  begin
    OptimizeTemporary.WriteOut(InputLines[i]);
  end;
  OptimizeTemporary.Finalize;
  OptimizeTemporary := nil;

  AssertEquals(ActualWriter.GetLines(), outputLines);

end;

procedure Test;
var
  FilePathPrefix: TFilePath;
  InputLines: TStringArray;
  OutputLines: TStringArray;
begin
  FilePathPrefix := '..\src\include\opt6502\opt_TEMP_IFTMP';
  InputLines := ReadTextFile(FilePathPrefix + '-in.txt');
  OutputLines := ReadTextFile(FilePathPrefix + '-out.txt');
  AssertWriteOutEquals(InputLines, OutputLines);
end;

end.
