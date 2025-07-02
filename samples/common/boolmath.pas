                                (* Chapter 3 - Program 6 *)
program Illustrate_What_Boolean_Math_Looks_Like;

   (* notice the program name, it can be up to 63 characters long.
      Variables can also be very long as we will see below *)

uses crt;

var A,B,C,D : boolean;
    A_Very_Big_Boolean_Name_Can_Be_Used : boolean;
    Junk,Who : integer;

begin
   Junk := 4;
   Who := 5;
   A := Junk = Who;    {since Junk is not equal to Who, A is false}
   B := Junk = (Who - 1);  {This is true}
   C := Junk < Who;        {This is true}
   D := Junk > 10;         {This is false}
   A_Very_Big_Boolean_Name_Can_Be_Used := A or B; {Since B is true,
                                                  the result is true}
   Writeln('result A is ',A);
   Writeln('result B is ',B);
   Writeln('result C is ',C);
   Writeln('result D is ',D:12); {This answer will be right justified
                                  in a 12 character field}
   Writeln('result A_Very_Big_Boolean_Name_Can_Be_Used is ',
                   A_Very_Big_Boolean_Name_Can_Be_Used);

                      (* Following are a few boolean expressions. *)
   A := B and C and D;
   A := B and C and not D;
   A := B or C or D;
   A := (B and C) or not (C and D);
   A := (Junk = Who - 1) or (Junk = Who);

   repeat until keypressed;
 end.

{ Result of execution

result A is FALSE
result B is TRUE
result C is TRUE
result D is        FALSE
result A_Very_Big_Boolean_Name_Can_Be_Used is TRUE

}
