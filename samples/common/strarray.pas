program Pure_Pascal_Strings;

uses crt;

type Long_String  = array[0..25] of char;
     String10     = array[0..10] of char;
     String12     = array[0..12] of char;

var  First_Name   : String10;
     Initial      : char;
     Last_Name    : String12;
     Full_Name    : Long_String;
     Index        : integer;

begin  (* main program *)
   First_Name := 'John      ';
   Initial := 'Q';
   Last_Name := 'Doe         ';
   Writeln(First_Name,Initial,Last_Name);

   for Index := 0 to 9 do
      Full_Name[Index] := First_Name[Index];

   Full_Name[10] := Initial;

   for Index := 0 to 11 do
      Full_Name[Index + 11] := Last_Name[Index];

   for Index := 23 to 24 do Full_Name[Index] := ' ';

   Writeln(Full_Name);

   repeat until keypressed;
end.  (* main program *)


{ Result of execution

John      QDoe
John      QDoe

}
