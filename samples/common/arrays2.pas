                                (* Chapter 6 - Program 2 *)
program Multiple_Arrays;

uses crt;

var Index,Count     : integer;
    Checkerboard    : array[0..8] of array[0..8] of integer;
    Value           : array[0..8, 0..8] of integer;

begin (* Main program *)
   for Index := 1 to 8 do begin  (* index loop *)
      for Count := 1 to 8 do begin
         Checkerboard[Index,Count] := Index + 3*Count;
         Value[Index,Count] := Index + 2*Checkerboard[Index,Count];
      end;
   end;  (* of index loop *)

   Writeln(' Output of checkerboard');
   Writeln;
   for Index := 1 to 8 do begin
      for Count := 1 to 8 do
         Write(Checkerboard[Index,Count],' ');
      Writeln;
   end;

   Value[3,5] := -1;  (* change some of the value matrix *)
   Value[3,6] := 3;
   Value[Value[3,6],7] := 2;  (* This is the same as writing
                                Value[3,7] := 2;            *)
   for Count := 1 to 3 do
      Writeln; (* Three blank lines *)
   Writeln('Output of value');
   Writeln;
   for Count := 1 to 8 do begin
      for Index := 1 to 8 do
         Write(Value[Count,Index],' ');
      Writeln;
   end;

   repeat until keypressed;

end. (* of main program *)


{ Result of execution

 Output of checkerboard

      4      7     10     13     16     19     22     25
      5      8     11     14     17     20     23     26
      6      9     12     15     18     21     24     27
      7     10     13     16     19     22     25     28
      8     11     14     17     20     23     26     29
      9     12     15     18     21     24     27     30
     10     13     16     19     22     25     28     31
     11     14     17     20     23     26     29     32



 Output of value

      9     15     21     27     33     39     45     51
     12     18     24     30     36     42     48     54
     15     21     27     33     -1      3      2     57
     18     24     30     36     42     48     54     60
     21     27     33     39     45     51     57     63
     24     30     36     42     48     54     60     66
     27     33     39     45     51     57     63     69
     30     36     42     48     54     60     66     72

}