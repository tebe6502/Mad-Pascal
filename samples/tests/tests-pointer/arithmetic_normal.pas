uses crt;

var  p1,p2 : ^integer;
     L : integer;
begin
 writeln(longint(p1));
 writeln(longint(p2));

 P1 := @P1;
 P2 := @P2;

 writeln(longint(p1));
 writeln(longint(p2));


 L := integer(P1-P2);

//  P1 := P1-4;
//  P2 := P2+4;

//  writeln(l);

 repeat until keypressed;

end.
