program Example_Function;

uses crt;

var Dogs,Cats,Feet : integer;

function Quad_Of_Sum(Number1,Number2 : integer) : integer;
begin
   Quad_Of_Sum := 4*(Number1 + Number2);
end;

begin  (* main program *)
   Dogs := 4;
   Cats := 3;
   Feet := Quad_Of_Sum(Dogs,Cats);
   Writeln(' There are a total of',Feet:3,' paws.');

   repeat until keypressed;

end.  (* of main program *)


{ Result of execution

 There are a total of 28 paws.

}
