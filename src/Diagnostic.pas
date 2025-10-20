unit Diagnostic;

{$I Defines.inc}

interface

uses CompilerTypes;

procedure Diagnostics(ProgramUnit: TSourceFile);

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Common, Datatypes, FileIO, Tokens;

procedure Diagnostics(ProgramUnit: TSourceFile);
var
  i, CharIndex, ChildIndex: Integer;
  DiagFile: ITextFile;
  token: TToken;
  identifier: TIdentifier;
begin

  DiagFile := TFileSystem.CreateTextFile;
  DiagFile.Assign(ChangeFileExt(ProgramUnit.Name, '.txt'));
  DiagFile.Rewrite;

  DiagFile.WriteLn;
  DiagFile.WriteLn('Token list: ');
  DiagFile.WriteLn;
  // DiagFile.WriteLn('#' : 6, 'Unit': 30, 'Line': 6, 'Token': 30);
  DiagFile.Write('# ', 6).Write('Unit', 30).Write('Line', 6).Write('Token', 30).WriteLn;

  DiagFile.WriteLn;

  for i := 1 to NumTok do
  begin
    token := TokenAt(i);
    DiagFile.Write(i, 6).Write(token.GetSourceFileName, 30).Write(token.SourceLocation.Line,
      6).Write(token.GetSpelling, 30).WriteLn;
    if token.Kind = TTokenKind.INTNUMBERTOK then
      DiagFile.WriteLn(' = ', IntToStr(token.Value))
    else if token.Kind = TTokenKind.FRACNUMBERTOK then
        //    DiagFile.WriteLn(' = ', token.FracValue: 8: 4)
        DiagFile.WriteLn(' = ', FloatToStr(token.FracValue))
      else if token.Kind = TTokenKind.IDENTTOK then
          DiagFile.WriteLn(' = ', token.Name)
        else if token.Kind = TTokenKind.CHARLITERALTOK then
            DiagFile.WriteLn(' = ', Chr(token.Value))
          else if token.Kind = TTokenKind.STRINGLITERALTOK then
            begin
              DiagFile.Write(' = ');
              for CharIndex := 1 to token.StrLength do
                DiagFile.Write(StaticStringData[token.StrAddress - CODEORIGIN + (CharIndex - 1)], -1);
              DiagFile.WriteLn;
            end
            else
              DiagFile.WriteLn;
  end;// for

  DiagFile.WriteLn;
  DiagFile.WriteLn('Identifier list: ');
  DiagFile.WriteLn;
  DiagFile.Write('#', 6).Write('Block', 6).Write('Name', 30).Write('Kind', 15).Write(
    'Type', 15).Write('Items/Params', 15).Write('Value/Addr', 15).Write('Dead', 5).WriteLn;
  DiagFile.WriteLn;

  for i := 1 to NumIdent do
  begin
    identifier:=IdentifierAt(i);
    DiagFile.Write(i, 6).Write(identifier.BlockIndex, 6).Write(identifier.Name, 30).Write(
      GetTokenSpelling(identifier.Kind), 15);
    if identifier.DataType <> TDataType.UNTYPETOK then
    begin
      DiagFile.Write(InfoAboutDataType(identifier.DataType), 15);
    end
    else
    begin
      DiagFile.Write('N/A', 15);
    end;
    DiagFile.Write(identifier.NumAllocElements, 15).Write(IntToHex(identifier.Value, 8), 15);
    if (identifier.Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK,
      TTokenKind.DESTRUCTORTOK]) and not identifier.IsNotDead then DiagFile.Write('Yes', 5)
    else
      DiagFile.Write('', 5);
  end;

  DiagFile.WriteLn;
  DiagFile.WriteLn;
  DiagFile.WriteLn('Call graph: ');
  DiagFile.WriteLn;

  for i := 1 to NumBlocks do
  begin
    DiagFile.Write(i, 6).Write('  ---> ');
    for ChildIndex := 1 to CallGraph[i].NumChildren do
      DiagFile.Write(CallGraph[i].ChildBlock[ChildIndex], 5);
    DiagFile.WriteLn;
  end;

  DiagFile.WriteLn;
  DiagFile.Close;

end;


end.
