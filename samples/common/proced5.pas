program Procedure_Calling_A_Procedure;
uses crt;

procedure One;
begin
   Writeln('This is procedure one');
end;

procedure Two;
begin
   One;
   Writeln('This is procedure two');
end;

procedure Three;
begin
   Two;
   Writeln('This is procedure three');
end;

begin  (* main program *)
   One;
   Writeln;
   Two;
   Writeln;
   Three;

   repeat until keypressed;
end. (* of main program *)


{ Result of execution

This is procedure one

This is procedure one
This is procedure two

This is procedure one
This is procedure two
This is procedure three

}
