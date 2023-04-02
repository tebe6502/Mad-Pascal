program Loops_And_Ifs;

uses crt;

var Count,Index : integer;

begin (* Main program *)
   for Count := 1 to 10 do begin (* Main loop *)
      if Count < 6 then
         Writeln('The loop counter is up to ',Count:4);
      if Count = 8 then begin
         for Index := 8 to 12 do begin (* Internal loop *)
            Write('The internal loop index is ',Index:4);
            Write(' and the main count is ',Count:4);
            Writeln;
         end; (* Internal loop *)
      end; (* if Count = 8 condition *)
   end; (* Main loop *)

   repeat until keypressed;

end.  (* Main program *)


{ Result of execution

The loop counter is up to    1
The loop counter is up to    2
The loop counter is up to    3
The loop counter is up to    4
The loop counter is up to    5
The internal loop index is    8 and the main count is    8
The internal loop index is    9 and the main count is    8
The internal loop index is   10 and the main count is    8
The internal loop index is   11 and the main count is    8
The internal loop index is   12 and the main count is    8

}
