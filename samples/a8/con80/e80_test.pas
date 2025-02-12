uses crt, graph, e80;

{$define romoff}

var i: byte;
    ch: char;

    s: string;

begin

 GotoXY(3, 7);

 writeln(screenwidth,',',screenheight);

 setcolor(1);
 moveto(46,157);
 lineto(300,23);

 GotoXY(70,23);

 for i:=0 to 3 do
   writeln(i);

 writeln(dpeek(88));

 setcolor(1);
 moveto(300,23);
 lineto(46,157);

 PutPixel(100,100);

 gotoXY(70,3);


 while true do begin

 //readln(s);

 ch:=readkey;
 write(ch);

 end;

 repeat until keypressed;

end.
