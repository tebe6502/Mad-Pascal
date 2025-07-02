program Example_Of_Types;

uses crt;

type Array_Def  = array[0..25] of integer;
     Char_Def   = array[0..27] of char;
     Real_Array = array[0..42] of real;
     Dog_Food   = array[0..6] of boolean;
     Airplane   = array[0..12] of Dog_Food;
     Boat       = array[0..12, 0..6] of boolean;

var Index,Counter      : integer;
    Stuff              : Array_Def;
    Stuff2             : Array_Def;
    Puppies            : Airplane;
    Kitties            : Boat;

begin  (* main program *)
   for Index := 0 to 12 do
      for Counter := 0 to 6 do begin
         Puppies[Index,Counter] := TRUE;
         Kitties[Index,Counter] := Puppies[Index,Counter];
      end;
   Writeln(Puppies[2,3]:7, Kitties[12,5]:7, Puppies[1,1]:7);

   repeat until keypressed;

end.  (* of main program *)


{ Result of execution

   TRUE   TRUE   TRUE

}