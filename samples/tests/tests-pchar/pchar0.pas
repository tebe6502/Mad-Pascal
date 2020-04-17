Program three;
Var S : String;
P : PChar;
begin
S := 'This is a null-terminated string.'#0;
P := @S[1];
WriteLn (P);

while true do;
end.

