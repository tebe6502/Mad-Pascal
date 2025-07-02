program First_Pointer_Example;
uses crt;

type Int_Point = ^Integer;

var Index         : Integer;
    Where         : ^Integer;
    Who           : ^Integer;
    Pt1, Pt2, Pt3 : Int_Point;

begin
   Index := 17;
   Where := @Index;
   Who := @Index;
   Writeln('The values are   ',Index:5,Where^:5,Who^:5);

   Where^ := 23;
   Writeln('The values are   ',Index:5,Where^:5,Who^:5);

   Pt1 := @Index;
   Pt2 := Pt1;
   Pt3 := Pt2;
   Pt2^ := 15;
   Writeln('The Pt values are',Pt1^:5,Pt2^:5,Pt3^:5);

   repeat until keypressed;
end.


{ Result of execution

The values are      17   17   17
The values are      23   23   23
The Pt values are   15   15   15

}