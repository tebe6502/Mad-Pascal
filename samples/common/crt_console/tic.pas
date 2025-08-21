program tic;

uses crt;

Var board: array [0..9] of smallint;
br: array [0..9] of string[3];
a,t,b,mov,turn: smallint;
yn : char;

procedure init;
begin
for a:=1 to 9 do begin
str(a,br[a]);
board[a]:=0
end;
turn:=1;
b:=0;
end;

procedure win;
begin
writeln('Player #',turn,' Wins!');
halt;
end;

procedure enit;
label l1;
begin
write('Sure you want to stop?');
readln(yn);
case yn of
'Y': halt;
'y': halt;
'n': goto l1;
'N': goto l1;
end;
l1: end;

procedure cats;
begin
writeln('CATS!!!');
halt;
end;

procedure checkitall;
begin
if board[1]=turn then if board[5]=turn then if board[9]=turn then win;
if board[7]=turn then if board[5]=turn then if board[3]=turn then win;
if board[3]=turn then if board[2]=turn then if board[1]=turn then win;
if board[4]=turn then if board[5]=turn then if board[6]=turn then win;
if board[7]=turn then if board[8]=turn then if board[9]=turn then win;
if board[1]=turn then if board[4]=turn then if board[7]=turn then win;
if board[2]=turn then if board[5]=turn then if board[8]=turn then win;
if board[3]=turn then if board[6]=turn then if board[9]=turn then win;
b:=0;
for t:=1 to 9 do begin
if board[t]>0 then b:=b+1;
if b=9 then cats;
end;
end;

procedure move;
label l1,l2;
begin
l2: write('Move to which Block?');
readln(mov);
if mov=0 then enit;
if mov>9 then goto l2;
if mov<1 then goto l2;
if board[mov]>0 then begin
writeln('Square already occupied!');
goto l2;
end;
b:=b+1;
if b=8 then cats;
if turn=1 then br[mov]:='X';
if turn=2 then br[mov]:='O';
turn:=turn+1;
if turn>2 then turn:=1;
board[mov]:=turn;
l1: (* Rem *)
end;


procedure writeboard;
label l1;
begin
l1: clrscr;
writeln(' ',br[1],' | ',br[2],' | ',br[3]);
writeln(' -----------');
writeln(' ',br[4],' | ',br[5],' | ',br[6]);
writeln(' -----------');
writeln(' ',br[7],' | ',br[8],' | ',br[9]);
writeln('');
checkitall;
writeln('Player #',turn);
move;
goto l1;
end;

begin
init;
writeboard;
end.
