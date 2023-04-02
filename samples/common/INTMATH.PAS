program Integer_Math_Demo;
uses crt;

var A,B,C,D : integer;
    E       : real;

begin
   A := 9;                   (* Simple assignment *)
   B := A + 4;               (* simple addition *)
   C := A + B;               (* simple addition *)
   D := 4*A*B;               (* multiplication *)
   E := A/B;                 (* integer division with the result
                                expressed as a real number *)
   D := B div A;             (* integer division with the result
                                expressed as a truncated integer
                                number *)
   D := B mod A;             (* d is the remainder of the division,
                                in this case d = 4 *)
   D := (A + B) div (B + 7); (* composite math statement *)

  (* It will be up to you to print out some of these values *)

end.


{ Result of execution

(There is no output from this program)

}
