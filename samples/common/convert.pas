program Convert_From_Type_To_Type;

uses crt;

var Index,Count : integer;
    Error_Ind   : byte;
    Size,Cost   : single;
    Letter      : char;
    Name,
    Amount	: string[12];

begin
   Index := 65;
   Count := 66;
   Cost := 124.678;
   Amount := '12.4612';

   Letter := Chr(Index);       (* convert integer to char *)
   Size := Count;              (* convert integer to real *)

   Index := Round(Cost);       (* real to integer, rounded *)
   Count := Trunc(Cost);       (* real to integer, truncated *)

   Index := Ord(Letter);       (* convert char to integer *)
   Str(Count, Name);           (* integer to string of char *)

   Val(Amount,Size,Error_Ind); (* string to real  note that
                                  "Error_Ind" is used for
                                  returning an error code *)

   Writeln('Name is ',Name,' and Size is ',Size:10:4);

   repeat until keypressed;
end.


{ Result of execution

Name is 124 and Size is    12.4612

}
