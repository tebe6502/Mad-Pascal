// https://github.com/tebe6502/Mad-Pascal/issues/114

program HelloWorld;

uses crt;

begin
  writeln('Hello World');
  {$info Some info}
  {$warning Some warning}
  {$error Some error}
  readkey;
end.

