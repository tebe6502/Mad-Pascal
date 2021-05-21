// https://github.com/mnaberez/py65
// py65mon -l test.bin -g 1000

const
  text = 'Test Mad Pascal on Py65';

var
  i   : byte;
  out : char absolute $f001;

begin
  for i := 1 to length(text) do out := text[i];
end.
