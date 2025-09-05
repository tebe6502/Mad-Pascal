program towers;

(* Towers:                          *)
(* A game written with CLSN Pascal  *)

(* Object:                          *)
(*   Move the six rings to another  *)
(*   peg.

(* Restrictions:                    *)
(*   1. Only one ring may be moved  *)
(*      at a time                   *)
(*   2. A larger ring may not be    *)
(*      placed on a smaller one     *)

(* Clue:
(*   The minimum number of moves    *)
(*   needed to complete the game    *)
(*   is 63.                         *)

uses crt;

const
  max_ring=6;

const
  ring_pic: array[0..max_ring] of string[15] =
            ('',
             '     -1-     ',
             '    --2--    ',
             '   ---3---   ',
             '  ----4----  ',
             ' -----5----- ',
             '------6------');

var
   post: array [0..3] of array[0..max_ring] of byte;
   quit: boolean;
  mvcnt: word;

procedure clear_line(y: byte);
begin
  gotoxy(1,y+1);
  ClrEol;
end;

function get_post: smallint;
var
  pn: byte;

begin
  repeat
    pn:=(ord(readkey) and $7F);

    quit:=(pn=27); pn:=pn-48;

  until {(pn in [1..3])} (pn=1) or (pn=2) or (pn=3) or quit;

  get_post:=pn;
end;

function top_ring_pos(pn: smallint): smallint;
var
  i: smallint;

begin
  i:=1;

  while (i<=max_ring) and (post[pn,i]=0) do
    inc(i);

  top_ring_pos:=i;
end;

procedure lift(pn,rf: smallint);
var
  tp: smallint;

begin
  tp:=top_ring_pos(pn);

  gotoxy(pred(pn)*13+1,13+tp);
  write('      |      ');

  gotoxy(pred(pn)*13+1,9);
  write(ring_pic[rf]);
end;

procedure drop(pn,rf: smallint);
var
  tp: smallint;

begin
  tp:=top_ring_pos(pn);

  clear_line(8);

  gotoxy(pred(pn)*13+1,12+tp);
  write(ring_pic[rf]);
end;

procedure end_game;
var
   i: byte;
  ch: char;

begin
  for i:=2 to 22 do
    clear_line(i);

  gotoxy(13, 8); write('CONGRATULATIONS');
  gotoxy(12,10); write('You completed the');
  gotoxy(12,11); write('game in ',mvcnt,' moves.');

  ch:=readkey;
end;

function win: boolean;
begin
  win:=(top_ring_pos(2)=1) or
       (top_ring_pos(3)=1);
end;

procedure make_move;
var
    pf,pt: smallint;
    rf,rt: smallint;
  tpf,tpt: smallint;
       ok: boolean;

begin
  clear_line(3);

  repeat
    gotoxy(3,4); write('Move top ring of what post: ');

    pf:=get_post;

    if quit then
      exit;

    write('''',pf);

    clear_line(4);

    tpf:=top_ring_pos(pf); rf:=post[pf,tpf];

    ok:=(tpf<=max_ring);

    if not ok then
      begin
        gotoxy(3,5);
        write('There are no rings there.');
      end;

  until ok;

  lift(pf,rf); post[pf,tpf]:=0;

  clear_line(3);

  repeat
    gotoxy(3,4); write('Move Ring #',rf,' to what post: ');

    pt:=get_post;

    if quit then
      exit;

    write('''',pt);

    clear_line(4);

    tpt:=top_ring_pos(pt); rt:=post[pt,tpt];

    ok:=(rf<rt) or (tpt>max_ring);

    if not ok then
      begin
        gotoxy(3,5);
        write('That move is invalid');
      end;

  until ok;

  drop(pt,rf); post[pt,tpt-1]:=rf;

  if (pf<>pt) then
    inc(mvcnt);
end;

procedure init_post;
var
  i,j: byte;

begin
  for i:=1 to 3 do
    for j:=1 to max_ring do
      case i of
        2,3: post[i,j]:=0;
          1: post[i,j]:=j;
      end;
end;

procedure init_screen;
var
  i,j: smallint;

begin
  clrscr;

  gotoxy(1,1); write(StringOfChar('-',40));

  gotoxy(13,1); write(' The Six Rings ');

  for i:=1 to 3 do
    begin
      gotoxy(pred(i)*13+7,7);
      write(i);
    end;

  for i:=1 to 3 do
    for j:=0 to max_ring do
      if (i=1) and (j<>0) then
        begin
          gotoxy(pred(i)*13+1,13+j);
          write(ring_pic[j]);
        end
      else
        begin
          gotoxy(pred(i)*13+7,13+j);
          write('|');
        end;

  gotoxy(1,20);
  write('______|____________|____________|______');
end;

begin

  init_post;
  init_screen;

  mvcnt:=0; quit:=false;

  repeat
    gotoxy(16,22); write('Moves: ',mvcnt);
    make_move;
  until win or quit;

  if win then
    end_game;

end.
