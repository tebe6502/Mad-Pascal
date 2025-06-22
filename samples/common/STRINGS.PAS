program TURBO_Pascal_Strings;

uses crt;

var First_Name   : string[10];
    Initial      : char;
    Last_Name    : string[12];
    Full_Name    : string[25];

begin  (* main program *)
   First_Name := 'John';
   Initial := 'Q';
   Last_Name := 'Doe';
   Writeln(First_Name,Initial,Last_Name);
   // The operator "+" is currently not supported in Mad-Pascal between "string" and "char".
   // Full_Name := First_Name + ' ' + Initial + ' ' + Last_Name;
   Full_Name := Concat(First_Name, Initial, Last_Name);
   Writeln(Full_Name);

   repeat until keypressed;
end.  (* main program *)




{ Result of execution

JohnQDoe
John Q Doe

}
