
uses crt, sysutils;

var
 select: char;
 a,b: string[15];
 x,y: real;


begin

repeat

 writeln(eol, 'Select:',eol);

 writeln('a. SUM');
 writeln('b. SUB');
 writeln('c. MUL');
 writeln('d. DIV');
 writeln(eol,'x. exit');

 write(eol,'?'); readln(select);
 
 select:=upCase(select);
 
 if select = 'X' then break;
 
 writeln;

 if (select>='A') and (select<='D') then begin
 
  Write('Value X>'); readln(a);
  Write('Value Y>'); readln(b);
  
  x:=StrToFloat(a);
  y:=StrToFloat(b);
  
  writeln;

  case select of
   'A': writeln('SUM ',x,' + ',y,' = ', x+y);
   'B': writeln('SUB ',x,' - ',y,' = ', x-y);
   'C': writeln('MUL ',x,' * ',y,' = ', x*y)
  else
     writeln('DIV ',x,' / ',y,' = ', x / y)
  end;
 
 end;

until false;

end.
