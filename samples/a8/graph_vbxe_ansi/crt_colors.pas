uses crt, vbxe;


begin

 clrscr;

 writeln;

 TextColor(black);  writeln('BLACK');
 TextColor(white);  writeln('WHITE');
 TextColor(red);  writeln('RED');
 TextColor(cyan);  writeln('CYAN');
 TextColor(purple);  writeln('PURPLE');
 TextColor(green);  writeln('GREEN');
 TextColor(blue);  writeln('BLUE');
 TextColor(yellow);  writeln('YELLOW');
 TextColor(orange);  writeln('ORANGE');
 TextColor(brown);  writeln('BROWN');
 TextColor(light_red);  writeln('LIGHT_RED');
 TextColor(dark_grey);  writeln('DARK_GREY');
 TextColor(grey);  writeln('GREY');
 TextColor(light_green);  writeln('LIGHT_GREEN');
 TextColor(light_blue);  writeln('LIGHT_BLUE');
 TextColor(light_grey);  writeln('LIGHT_GREY');

 writeln;

 TextColor(White);
 TextBackground(Blue);

 writeln('test A B C D E F');

 writeln(0);
 writeln(1);
 writeln(2);
 writeln(3);

 TextColor(Yellow);

 writeln('a');
 writeln('b');

 TextColor(Black);

 GotoXY(33,23); write('0123456789');

 repeat until keypressed;

end.
