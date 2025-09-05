Program zigzag;

uses crt;
 
const
  size = 5;
var
  zzarray: array [0..size, 0..size] of smallint;
  element, i, j: smallint;
  direction: smallint;
  width, n: smallint;
 
begin
  i := 1;
  j := 1;
  direction := 1;
  for element := 0 to (size*size) - 1 do
  begin
    zzarray[i,j] := element;
    i := i + direction;
    j := j - direction;
    if (i = 0) then
      begin
        direction := -direction;
        i := 1;
        if (j > size) then
        begin
          j := size;
          i := 2;
        end;
      end
    else if (i > size) then
      begin
        direction := -direction;
        i := size;
        j := j + 2;
      end
    else if (j = 0) then
      begin
        direction := -direction;
        j := 1;
        if (i > size) then
        begin
          j := 2;
          i := size;
        end;
      end
    else if (j > size) then
      begin
        direction := -direction;
        j := size;
        i := i + 2;
      end;
  end;
 
  width := 2;
  n     := size;
  while (n > 0) do
  begin
    width := width + 1;
    n     := n div 10;
  end;
  for j := 1 to size do
  begin
    for i := 1 to size do
      write(hexStr(zzarray[i,j], 2),' ');
    writeln;
  end;
  
 
 repeat until keypressed;
 
  
end.
