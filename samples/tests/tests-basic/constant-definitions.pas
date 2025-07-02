{ Tests constant definitions 
  Expected result: Prints 1,2,3 }
{ Note: The MiniPascal grammar only allows
        integer constant definitions. }
program constdef;
const
  x=1; y=2; z=3;
begin
  writeln(x,y,z);
  
  while true do;
end.
