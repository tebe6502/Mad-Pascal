{ Test the various relational operators.
  Expected: true, true }

program relational;
var
 x:boolean;
begin
 writeln( (1<2)  and (3>2)  and (3<>2)
      and (3>=2) and (2<=3) and (3=3));

 writeln( ('a'<'b')  and ('c'>'b')  and ('c'<>'b')
      and ('c'>='b') and ('a'<='b') and ('a'='a') );
      
 while true do;      
end.

