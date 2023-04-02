program Scope_Of_Variables;
uses crt;

var Count : integer;
    Index : integer;

procedure Print_Some_Data;
var Count, More_Stuff : integer;
begin
   Count := 7;
   Writeln('In Print_Some_Data Count =',Count:5,
                                         '  Index =',Index:5);
end; (* of Print_Some_Data procedure *)

begin   (* Main program *)
   for Index := 1 to 3 do begin
      Count := Index;
      Writeln('In main program Count  =',Count:5,
                                          '  Index =',Index:5);
      Print_Some_Data;
      Writeln('In main program Count  =',Count:5,
                                          '  Index =',Index:5);
      Writeln;
   end; (* Count loop *)

   repeat until keypressed;

end. (* main program *)


{ Result of execution

In main program Count  =    1  Index =    1
In Print_Some_Data Count =    7  Index =    1
In main program Count  =    1  Index =    1

In main program Count  =    2  Index =    2
In Print_Some_Data Count =    7  Index =    2
In main program Count  =    2  Index =    2

In main program Count  =    3  Index =    3
In Print_Some_Data Count =    7  Index =    3
In main program Count  =    3  Index =    3

}