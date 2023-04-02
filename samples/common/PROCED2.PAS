program Another_Procedure_Example;
uses crt;

var Count : integer;
    Index : integer;

procedure Print_Data_Out(Puppy : integer);
begin
   Writeln('This is the print routine',Puppy:5);
   Puppy := 12;
end;

procedure Print_And_Modify(var Cat : integer);
begin
   Writeln('This is the print and modify routine',Cat:5);
   Cat := 35;
end;

begin  (* main program *)
   for Count := 1 to 3 do begin
      Index := Count;
      Print_Data_Out(Index);
      Writeln('Back from the print routine, Index =',Index:5);
      Print_And_Modify(Index);
      Writeln('Back from the modify routine, Index =',Index:5);
      Print_Data_Out(Index);
      Writeln('Back from print again and the Index =',Index:5);
      Writeln;  (* This is just for formatting *)
   end;

   repeat until keypressed;

end.  (* of main program *)


{ Result of execution

This is the print routine    1
Back from the print routine, Index =    1
This is the print and modify routine    1
Back from the modify routine, Index =   35
This is the print routine   35
Back from print again and the Index =   35

This is the print routine    2
Back from the print routine, Index =    2
This is the print and modify routine    2
Back from the modify routine, Index =   35
This is the print routine   35
Back from print again and the Index =   35

This is the print routine    3
Back from the print routine, Index =    3
This is the print and modify routine    3
Back from the modify routine, Index =   35
This is the print routine   35
Back from print again and the Index =   35

}
