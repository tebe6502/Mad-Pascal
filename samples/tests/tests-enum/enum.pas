{

 TRUE
 czwartek

}

uses crt;

 type
      TDay = (pon, wt, sr, czw, pt, sob, nied);

 var

	day2,day: TDay;


	//t: pointer = @s;

 begin

     day:=TDay(3);

     writeln(odd(ord(day)));

     case day of
      pon: writeln('poniedzialek');
      wt: writeln('wtorek');
      sr: writeln('sroda');
      czw: writeln('czwartek');
      pt: writeln('piatek');
      sob: writeln('sobota');
      nied: writeln('niedziela');
     end;

  repeat until keypressed;

end.
