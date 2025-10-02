unit Memory;

interface

const
  MIN_MEMORY_ADDRESS = $0000;

const
  MAX_MEMORY_ADDRESS = $FFFF;

type
  TWordMemory = array [MIN_MEMORY_ADDRESS..MAX_MEMORY_ADDRESS] of Word;

procedure ClearWordMemory(var anArray: TWordMemory);

implementation

procedure ClearWordMemory(var anArray: TWordMemory);
var i: Integer;
begin
  for i := Low(anArray) to High(anArray) do
  begin
    anArray[i] := 0;
  end;
end;

end.
