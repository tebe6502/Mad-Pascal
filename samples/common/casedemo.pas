program Demonstrate_Case;
uses crt;

var Count : byte;

begin  (* main program *)
   for Count := 0 to 8 do begin
      Write(Count:5);
         case Count of
           1 : Write(' One');    (* Note that these do not have *)
           2 : Write(' Two');    (* to be in consecutive order *)
           3 : Write(' Three');
           4 : Write(' Four');
           5 : Write(' Five');
         else Write(' This number is not in the allowable list');
         end; (* of case structure *)
      Writeln;
   end;  (* of Count loop *)

   repeat until keypressed;

end.  (* of main program *)


{ Result of execution

    0 This number is not in the allowable list
    1 One
    2 Two
    3 Three
    4 Four
    5 Five
    6 This number is not in the allowable list
    7 This number is not in the allowable list
    8 This number is not in the allowable list

}
