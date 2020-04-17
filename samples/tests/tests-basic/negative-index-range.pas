{ Test if signs in index-ranges work.
  Expected:  42}
program indexrange;
const
  min=10;
type
  negrange = -min..-1;
var
  a:array [-min..-1] of integer;
begin
  a[-4]:=42;
  writeln(a[-4]);
end.
