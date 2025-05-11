unit Diagnostic;

{$I Defines.inc}

interface


// ----------------------------------------------------------------------------

procedure Diagnostics;

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Common, CompilerTypes, Datatypes, FileIO, Tokens;

// ----------------------------------------------------------------------------


procedure Diagnostics;
var
  i, CharIndex, ChildIndex: Integer;
  DiagFile: ITextFile;
begin

  DiagFile := TFileSystem.CreateTextFile;
  DiagFile.Assign(ChangeFileExt(GetUnit(1).Name, '.txt'));
  DiagFile.Rewrite;

  DiagFile.WriteLn;
  DiagFile.WriteLn('Token list: ');
  DiagFile.WriteLn;
  // DiagFile.WriteLn('#' : 6, 'Unit': 30, 'Line': 6, 'Token': 30);
  DiagFile.Write('# ', 6).Write('Unit', 30).Write('Line', 6).Write('Token', 30).WriteLn;

  DiagFile.WriteLn;

  for i := 1 to NumTok do
  begin
    // DiagFile.Write(i: 6, Tok[i].SourceCodeFile.UnitIndex) 30, Tok[i].Line: 6, GetSpelling(i): 30);
    DiagFile.Write(i, 6).Write(Tok[i].SourceCodeFile.Name, 30).Write(Tok[i].Line,
      6).Write(tokenList.GetTokenSpellingAtIndex(i), 30).WriteLn;
    if Tok[i].Kind = TTokenKind.INTNUMBERTOK then
      DiagFile.WriteLn(' = ', IntToStr(Tok[i].Value))
    else if Tok[i].Kind = TTokenKind.FRACNUMBERTOK then
      //    DiagFile.WriteLn(' = ', Tok[i].FracValue: 8: 4)
      DiagFile.WriteLn(' = ', FloatToStr(Tok[i].FracValue))
    else if Tok[i].Kind = TTokenKind.IDENTTOK then
      DiagFile.WriteLn(' = ', Tok[i].Name)
    else if Tok[i].Kind = TTokenKind.CHARLITERALTOK then
      DiagFile.WriteLn(' = ', Chr(Tok[i].Value))
    else if Tok[i].Kind = TTokenKind.STRINGLITERALTOK then
    begin
      DiagFile.Write(' = ');
      for CharIndex := 1 to Tok[i].StrLength do
        DiagFile.Write(StaticStringData[Tok[i].StrAddress - CODEORIGIN + (CharIndex - 1)], -1);
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
    DiagFile.Write(i, 6).Write(Ident[i].Block, 6).Write(Ident[i].Name, 30).Write(
      GetTokenSpelling(Ident[i].Kind), 15);
    if Ident[i].DataType <> TDataType.UNTYPETOK then DiagFile.Write(GetTokenSpelling(Ident[i].DataType), 15)
    else
      DiagFile.Write('N/A', 15);
    DiagFile.Write(Ident[i].NumAllocElements, 15).Write(IntToHex(Ident[i].Value, 8), 15);
    if (Ident[i].Kind in [TTokenKind.PROCEDURETOK, TTokenKind.FUNCTIONTOK, TTokenKind.CONSTRUCTORTOK,
      TTokenKind.DESTRUCTORTOK]) and not Ident[i].IsNotDead then DiagFile.Write('Yes', 5)
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
