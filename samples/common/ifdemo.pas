program Demonstrate_Conditional_Branching;
uses crt;

var One,Two,Three  : integer;

begin  (* main program *)
   One := 1;           (* these are to have some numbers *)
   Two := 2;           (* to use for illustrations *)
   Three := 3;

   if Three = (One + Two) then        (* Example 1 *)
      Writeln('three is equal to one plus two');

   if Three = 3 then begin            (* Example 2 *)
      Write('three is ');
      Write('equal to ');
      Write('one plus two');
      Writeln;
   end;

   if Two = 2 then                    (* Example 3 *)
      Writeln('two is equal to 2 as expected')
   else
      Writeln('two is not equal to 2... rather strange');

   if Two = 2 then                    (* Example 4 *)
      if One = 1 then
         Writeln('one is equal to one')
      else
         Writeln('one is not equal to one')
   else
      if Three = 3 then
         Writeln('three is equal to three')
      else
         Writeln('three is not equal to three');

   repeat until keypressed;
end.  (* main program *)


{ Result of execution

three is equal to one plus two
three is equal to one plus two
two is equal to 2 as expected
one is equal to one

}
