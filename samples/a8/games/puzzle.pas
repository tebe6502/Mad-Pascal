
// Puzzle

uses crt, joystick, sysutils;

var	field: array [0..255] of byte;
	x, y, blank: byte;

	level: byte = 10;
	size: byte = 5;


procedure MoveCell(a: byte);
var idx: byte;
begin
	idx := y*size + x;

	case a of
		 joy_left: if x<size-1	then begin field[idx]:=field[idx+1]; field[idx+1]:=blank; inc(x) end;
		joy_right: if x>0	then begin field[idx]:=field[idx-1]; field[idx-1]:=blank; dec(x) end;
		   joy_up: if y<size-1	then begin field[idx]:=field[idx+size]; field[idx+size]:=blank; inc(y) end;
		 joy_down: if y>0	then begin field[idx]:=field[idx-size]; field[idx-size]:=blank; dec(y) end;
	end;
end;

	
procedure Initialize(cnt: word);
var i: word;
begin

 blank := (size div 2)*(size+1);

 for i:=0 to size*size-1 do field[i] := i;
  
 x:=blank mod size;
 y:=blank div size;

 for i:=0 to cnt do 
  case byte(random(4)) of
   0: MoveCell(joy_left);
   1: MoveCell(joy_right);
   2: MoveCell(joy_up);
   3: MoveCell(joy_down);
  end;

end;


procedure Display;
var i,j, idx: byte;
begin

 for j:=0 to size-1 do
  for i:=0 to size-1 do begin

  GotoXY(i shl 2+6, j shl 1+5);

   idx:=j*size+i;

   if field[idx] = blank then
    write('  ')
   else  
    write(field[idx]);

  end;


end;


function Check: Boolean;
var i: byte;
begin

 Result:=true;

 for i:=0 to size*size-1 do 
  if field[i] <> i then begin Result:=false; Break end;

end;


begin

 if ParamCount > 0 then begin
  size:=StrToInt(ParamStr(1));
  level:=StrToInt(ParamStr(2));

  if (size<2) or (size> 8) or (level<2) then begin
   writeln(#$9b'Usage:'#$9b,'PUZZLE size level');
   writeln('size = [2..8], level = [2..',High(level),']');
   halt;  
  end;
  
 end;


 ClrScr; CursorOff; Randomize;

 Initialize(level);

 Display;

 repeat
	Pause;

	MoveCell(joy_1);
	
	if joy_1 <> joy_none then Display;

	if Check then begin
		writeln(#$9b#$9b#$9b'Congratulations !');
		Break;
	end;
 
 until keypressed;

 CursorOn;
 writeln;

end.
