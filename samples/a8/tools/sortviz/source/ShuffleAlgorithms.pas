unit ShuffleAlgorithms;

interface

procedure FillAscending;
procedure FillDescending;
procedure FillPyramid;
procedure FillInterlaced;
procedure KnuthShuffle;
procedure FillAscendingWithShuffle;
procedure SplashScreenShuffle;

implementation

uses ArrayAccess, Core, Operation;

procedure FillAscending;
var
  i: Byte;
begin
  for i := 0 to MAX_INDEX do
  begin
    SetValue(i, i);
  end;
end;

procedure FillDescending;
var
  i: Byte;
begin
  for i := 0 to MAX_INDEX do
  begin
    SetValue(i, MAX_INDEX - i);
  end;
end;

procedure FillPyramid;
var
  i: Byte;
  mid: Byte;
begin
  mid := MAX_INDEX shr 1;
  
  for i := 0 to mid do
  begin
    SetValue(i, i shl 1);
  end;
  
  for i := mid + 1 to MAX_INDEX do
  begin
    SetValue(i, Byte(MAX_INDEX - (i - mid - 1) shl 1))
  end;
end;

procedure FillInterlaced;
var
  i, min, max: Byte;
begin
  min := 0;
  max := MAX_INDEX;
  for i := 0 to MAX_INDEX do
  begin
    if i and 1 = 0 then
    begin
      SetValue(i, min);
      Inc(min);
    end
    else begin
      SetValue(i, max);
      Dec(max);
    end;
  end;
end;

procedure KnuthShuffle;
var
  i, j: Byte;
begin
  for i := 0 to MAX_INDEX - 1 do
  begin
    if aborted then Exit;
    j := Random(Byte(MAX_INDEX - i)) + i + 1;
    SwapValues(i, j);
  end;
end;

procedure LocalShuffle;
const
  MAX_DISTANCE = 5;
var
  i, j, dist: Byte;
begin
  for i := 0 to MAX_INDEX - 1 do
  begin
    if aborted then Exit;
    dist := Random(MAX_DISTANCE) + 1;
    if i + dist > MAX_INDEX then
    begin
      dist := MAX_INDEX - i - 1;
    end;
    j := i + dist;
    SwapValues(i, j);
  end;
end;

procedure FillAscendingWithShuffle;
begin
  FillAscending;
  LocalShuffle;
end;

procedure SplashScreenShuffle;
const
  MAX_LINE = SPLASH_LINES - 1;
var
  i, j: Byte;
begin
  for i := 0 to MAX_INDEX do
  begin
    SetValueSilent(i, i);
  end;
  
  for i := 0 to MAX_LINE - 1 do
  begin
    if aborted then Exit;
    j := Random(Byte(MAX_LINE - i)) + i + 1;
    SwapValuesSilent(i, j);
  end;
end;

end.