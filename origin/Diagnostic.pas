unit Diagnostic;

interface

{$i Defines.inc}

// ----------------------------------------------------------------------------

procedure Diagnostics;

// ----------------------------------------------------------------------------

implementation

uses SysUtils, Common, DataTypes, Tokens;

// ----------------------------------------------------------------------------


procedure Diagnostics;
var
  i, CharIndex, ChildIndex: Integer;
  DiagFile: textfile;
begin

  AssignFile(DiagFile, ChangeFileExt(UnitName[1].Name, '.txt'));
  Rewrite(DiagFile);

  WriteLn(DiagFile);
  WriteLn(DiagFile, 'Token list: ');
  WriteLn(DiagFile);
  WriteLn(DiagFile, '#': 6, 'Unit': 30, 'Line': 6, 'Token': 30);
  WriteLn(DiagFile);

  for i := 1 to NumTok do
  begin
    Write(DiagFile, i: 6, UnitName[TokenAt(i).UnitIndex].Name: 30, TokenAt(i).Line: 6, GetTokenSpelling(TokenAt(i).Kind): 30);
    if TokenAt(i).Kind = INTNUMBERTOK then
      WriteLn(DiagFile, ' = ', TokenAt(i).Value)
    else if TokenAt(i).Kind = FRACNUMBERTOK then
        WriteLn(DiagFile, ' = ', TokenAt(i).FracValue: 8: 4)
      else if TokenAt(i).Kind = IDENTTOK then
          WriteLn(DiagFile, ' = ', TokenAt(i).Name^)
        else if TokenAt(i).Kind = CHARLITERALTOK then
            WriteLn(DiagFile, ' = ', Chr(TokenAt(i).Value))
          else if TokenAt(i).Kind = STRINGLITERALTOK then
            begin
              Write(DiagFile, ' = ');
              for CharIndex := 1 to TokenAt(i).StrLength do
                Write(DiagFile, StaticStringData[TokenAt(i).StrAddress - CODEORIGIN + (CharIndex - 1)]);
              WriteLn(DiagFile);
            end
            else
              WriteLn(DiagFile);
  end;// for

  WriteLn(DiagFile);
  WriteLn(DiagFile, 'Identifier list: ');
  WriteLn(DiagFile);
  WriteLn(DiagFile, '#': 6, 'Block': 6, 'Name': 30, 'Kind': 15, 'Type': 15, 'Items/Params': 15,
    'Value/Addr': 15, 'Dead': 5);
  WriteLn(DiagFile);

  for i := 1 to NumIdent do
  begin
    Write(DiagFile, i: 6, Ident[i].Block: 6, Ident[i].Name: 30, GetTokenSpelling(Ident[i].Kind): 15);
    if Ident[i].DataType <> TDataType.UNTYPETOK then Write(DiagFile, GetTokenSpelling(Ident[i].DataType): 15)
    else
      Write(DiagFile, 'N/A': 15);
    Write(DiagFile, Ident[i].NumAllocElements: 15, IntToHex(Ident[i].Value, 8): 15);
    if (Ident[i].Kind in [PROCEDURETOK, FUNCTIONTOK, CONSTRUCTORTOK, DESTRUCTORTOK]) and not Ident[i].IsNotDead then
      WriteLn(DiagFile, 'Yes': 5)
    else
      WriteLn(DiagFile, '': 5);
  end;

  WriteLn(DiagFile);
  WriteLn(DiagFile, 'Call graph: ');
  WriteLn(DiagFile);

  for i := 1 to NumBlocks do
  begin
    Write(DiagFile, i: 6, '  ---> ');
    for ChildIndex := 1 to CallGraph[i].NumChildren do
      Write(DiagFile, CallGraph[i].ChildBlock[ChildIndex]: 5);
    WriteLn(DiagFile);
  end;

  WriteLn(DiagFile);
  CloseFile(DiagFile);

end;


// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


end.
