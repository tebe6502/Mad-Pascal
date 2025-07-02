{ This test demonstrates nested functions.
  The expected result is 7.
  Original examples from Wikipedia.}

program nested;
type
  int_=integer;

function E(x: int_): int_;

  function F(y: int_): int_;
    begin
    F := x + y
    end;

  begin
  Result := F(3) + F(2)
  end;

begin
  writeln(E(1));

  while true do;
end.
