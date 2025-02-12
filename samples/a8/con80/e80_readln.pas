uses crt, graph, e80;

{$define romoff}

var i: byte;
    ch: char;

    s: string;

begin

 setcolor(1);
 moveto(46,157);
 lineto(300,23);

 GotoXY(70,23);

 for i:=0 to 3 do
   writeln(i);

 while true do begin

 readln(s);

 end;

 repeat until keypressed;

end.
