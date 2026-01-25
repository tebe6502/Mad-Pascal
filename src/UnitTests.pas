unit UnitTests;

interface

procedure StartTest(const Name: String);
procedure FailTest(const message: String);
procedure EndTest(const Name: String);


implementation

procedure StartTest(const Name: String);
begin
  WriteLn('Unit Test ' + Name + ' started.');
end;

procedure FailTest(const message: String);
begin
  WriteLn('ERROR: ' + message);
end;


procedure EndTest(const Name: String);
begin
  WriteLn('Unit Test ' + Name + ' ended.');
end;

end.
