program strings;
var
  s,t,u,v: String;
begin
  s:='Hello world!';
  t:='Hello world!';
  u:='Hello worle!';
  v:='Hello worlc!';
  // write('length of s: ');
  // writeln(length(s));

  writeln('These comparisons are all true:');
  writeln(s=t);
  writeln(s<u);
  writeln(s>v);
  writeln(s<=t);
  writeln(s<=u);
  writeln(s>=v);
  writeln(s<>u);

  while true do;
end.
