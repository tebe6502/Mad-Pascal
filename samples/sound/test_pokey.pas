uses crt, misc;

var
	a: char;
	y: byte;

	yes: Boolean;


procedure play(ch: byte);
var i: byte;
begin

 GotoXY(0,y);

 write('Channel #',ch and 3);

 if ch > 3 then
  write(' / second')
 else
  write(' / first');

 writeln(' POKEY  ') ;

 for i:=0 to 15 do begin
   pause(i);
   sound(ch, i*16, 14, 15);
 end;

 NoSound;

end;


begin

 write('Second POKEY ');

 yes:=DetectStereo;

 if not yes then write('not ');

 writeln('detected');

 writeln('Press 1-2-3-4 to play on first POKEY');

 if yes then writeln('Press 5-6-7-8 to play on second POKEY');

 writeln('Press 0 to exit');

 writeln;

 y:=WhereY;

 while true do begin

  a:=readkey;

  case a of
   '1': play(0);
   '2': play(1);
   '3': play(2);
   '4': play(3);

   '5': if yes then play(4);
   '6': if yes then play(5);
   '7': if yes then play(6);
   '8': if yes then play(7);

   '0': exit;
  end;

 end;

 repeat until keypressed;

end.


