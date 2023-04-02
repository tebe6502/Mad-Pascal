program A_Bigger_Case_Example;

uses crt;

var Count : byte;
    Index : byte;

begin  (* main program *)
   for Count := 1 to 10 do begin
      Write(Count:5);
         case Count of
           7..9  : Write(' Big Number');
           2,4,6 : begin Write(' Small');
                         Write(' even');
                         Write(' number.');
                   end;
           3 : for Index := 1 to 3 do Write(' Boo');
           1 : if TRUE then begin Write(' TRUE is True,');
                                  Write(' and this is dumb.');
                            end;
         else Write(' This number is not in the allowable list');
         end; (* of case structure *)
      Writeln;
   end;  (* of Count loop *)

   repeat until keypressed;

end.  (* of main program *)


{ Result of execution

   1 TRUE is true, and this is dumb.
   2 Small even number.
   3 Boo Boo Boo
   4 Small even number.
   5 This number is not in the allowable list
   6 Small even number.
   7 Big number
   8 Big number
   9 Big number
  10 This number is not in the allowable list

}
