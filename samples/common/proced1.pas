program First_Procedure_Call;
uses crt;

var  Count  : integer;

procedure Write_A_Header;
begin
   Writeln('This is the header');
end;

procedure Write_A_Message;
begin
   Writeln('This is the message and the count is',Count:4);
end;

procedure Write_An_Ending;
begin
   Writeln('This is the ending message');
end;

begin  (* main program *)
   Write_A_Header;
   for Count := 1 to 8 do
      Write_A_Message;
   Write_An_Ending;

   repeat until keypressed;
end.  (* of main program *)


{ Result of execution

This is the header
This is the message and the count is   1
This is the message and the count is   2
This is the message and the count is   3
This is the message and the count is   4
This is the message and the count is   5
This is the message and the count is   6
This is the message and the count is   7
This is the message and the count is   8
This is the ending message

}
