{ Test: Functions with one arguments.
  This program computes the sum 1+2+...+10 = 55. }
program bar;

uses crt;

var
  sum:integer;

function f_1(x:integer): integer;
  begin

  result:=0;

    if x<>0 then
       begin
         sum:=sum+x;
         f_1(x-1);
       end
    else
      f_1:=sum;

//  writeln(x,',',result);

  end;


begin
  sum:=0;

  writeln(f_1(10));

  repeat until keypressed;
end.
