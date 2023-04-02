program Make_A_Fruit_Salad;
uses crt;

var Apple,Orange,Pear,Fruit : integer;

procedure Add_The_Fruit(Value1,Value2 : integer;  (* one-way *)
                       var Total      : integer;  (* two-way *)
                       Value3         : integer); (* one-way *)
begin
   Total := Value1 + Value2 + Value3;
end;

begin  (* main program *)
   Apple := 4;
   Orange := 5;
   Pear := 7;
   Add_The_Fruit(Apple,Orange,Fruit,Pear);
   Writeln('The fruit basket contains ',Fruit:3,' fruits');

   repeat until keypressed;
end.  (* of main program *)


{ Result of execution

The fruit basket contains  16 fruits

}
