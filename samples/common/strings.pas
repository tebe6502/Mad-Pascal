program TURBO_Pascal_Strings;

uses
  crt;

var
  First_Name: String[10];
  Initial: Char;
  Last_Name: String[12];
  Full_Name: String[25];

begin  (* main program *)
  First_Name := 'John';
  Initial := 'Q';
  Last_Name := 'Doe';
  Writeln(First_Name, Initial, Last_Name);
  // The operator "+" is currently not supported in Mad-Pascal between "string" and "char".
  // Full_Name := First_Name + ' ' + Initial + ' ' + Last_Name;
  Full_Name := Concat(Concat(Concat(Concat(First_Name, ' '), Initial), ' '), Last_Name);
  Writeln(Full_Name);

  repeat
  until keypressed;
end.  (* main program *)
{ Result of execution

JohnQDoe
John Q Doe

}
