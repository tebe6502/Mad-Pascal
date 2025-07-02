program Example_Of_Constants;

const  Max_Size = 12; (* Pascal assumes this is a byte type, but it
                         can be used as an integer also *)
       Index_Start   : integer = 49; (* This is a typed constant *)
       Check_It_Out  : boolean = TRUE; (* Another typed constant *)

type Bigarray  = array[0..Max_Size] of integer;
     Chararray = array[0..Max_Size] of char;

var  Airplane   : Bigarray;
     Seaplane   : Bigarray;
     Helicopter : Bigarray;
     Cows       : Chararray;
     Horses     : Chararray;
     Index      : integer;

begin  (* main program *)
   for Index := 1 to Max_Size do begin
      Airplane[Index] := Index*2;
      Seaplane[Index] := Index*3 + 7;
      Helicopter[Max_Size - Index + 1] := Index + Airplane[Index];
      Horses[Index] := 'X';
      Cows[Index] := 'R';
   end;
end.  (* of main program *)


{ Result of execution

(There is no output from this program)

}
