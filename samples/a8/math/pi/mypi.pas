{*
* Program: MyPi.pas
* Leibniz formula for approximating pi in TurboPascal 3
*
* infinite series formula pi/4 = 1 - 1/3 + 1/5 - 1/7 + 1/9 ..... forever
*
* for the sake of simplification our code is pi = 4 - 4/3 + 4/5 - 4/7 ...
*
* The series approaches Pi from above and below, so our output is
* the average of the final 2 sums
*
*
https://github.com/RealMightyPEZ/TurboPascal
*
*}

uses crt;

var
  Sum,PrevSum,AvgSum  : Real;
  x                   : Real;
  Count               : Smallint;
  IsOdd               : Boolean;
  MaxIter             : Smallint;

begin
  x := 3;
  Sum := 4;
  IsOdd := True;
  Count := 0;
  MaxIter := 31000;

  ClrScr;
  Writeln('Begin Calculating Pi');

  repeat
    Count := Count + 1;
    PrevSum := Sum;
    if IsOdd then
      Sum := Sum - 4/x
    else
      Sum := Sum + 4/x;
    x := x + 2;

    IsOdd := (Not IsOdd);

    if (count = (MaxIter - 1)) then
      avgSum := (Sum + PrevSum) / 2;

  until (Count >= MaxIter);

  writeln(avgSum : 0 : 10);


  repeat until keypressed;

end.
