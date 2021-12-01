
{--------------------------------------}
{             T E T R I S              }
{--------------------------------------}
{slightly corrected by Valery Votintsev}
{--------------------------------------}
{ key A		LEFT		       }
{ key D		RIGHT		       }
{ key W		UP		       }
{ key S		DOWN		       }
{--------------------------------------}

program tetris;
uses
  crt;
var
  ss,nn,a,b,c,d,lin,rlin,x,y,pus: byte;
  st:array[0..12, 0..22] of byte;

{$IFDEF ATARI}
  scr: array [0..23, 0..39] of char absolute $bc40;
{$ELSE}
  scr: array [0..23, 0..39] of char absolute $0400;
{$ENDIF}


procedure k(x,y:byte);
var i,j: byte;
begin
 i:=x*2+12;
 j:=24-y;

 case ss of
  0: begin scr[j,i]:=#0; scr[j,i+1]:=#0 end;    // '  '
  1: begin scr[j,i]:=#59; scr[j,i+1]:=#61 end;  // '[]'
  2: begin scr[j,i]:=#128; scr[j,i+1]:=#128 end;// '  '*
 end;

 if (ss=3) and (st[x,y]>0) then pus:=1;
 if ss=4 then st[x,y]:=1;

end;


procedure fig(x,y,n,s:byte);
begin
 if s=3 then pus:=0;

 ss:=s;

 k(x,y);

 case n of
  1: begin k(x+1,y);k(x,y-1);k(x+1,y-1) end;
  2: begin k(x-1,y);k(x+1,y);k(x+2,y) end;
  3: begin k(x,y+1);k(x,y-1);k(x,y-2) end;
  4: begin k(x+1,y);k(x-1,y);k(x-1,y+1) end;
  5: begin k(x,y+1);k(x+1,y+1);k(x,y-1) end;
  6: begin k(x-1,y);k(x+1,y);k(x+1,y-1) end;
  7: begin k(x,y+1);k(x,y-1);k(x-1,y-1) end;
  8: begin k(x-1,y);k(x+1,y);k(x+1,y+1) end;
  9: begin k(x,y+1);k(x,y-1);k(x+1,y-1) end;
 10: begin k(x+1,y);k(x-1,y);k(x-1,y-1) end;
 11: begin k(x,y+1);k(x,y-1);k(x-1,y+1) end;
 12: begin k(x-1,y);k(x,y-1);k(x+1,y-1) end;
 13: begin k(x,y+1);k(x-1,y);k(x-1,y-1) end;
 14: begin k(x+1,y);k(x-1,y-1);k(x,y-1) end;
 15: begin k(x-1,y);k(x,y-1);k(x-1,y+1) end;
 16: begin k(x+1,y);k(x-1,y);k(x,y+1) end;
 17: begin k(x+1,y);k(x,y+1);k(x,y-1) end;
 18: begin k(x,y-1);k(x-1,y);k(x+1,y) end;
 19: begin k(x-1,y);k(x,y+1);k(x,y-1) end
end;

end;

procedure pov;
begin
 nn:=nn-1;

 case nn of
  15: nn:=19;
  13: nn:=15;
  11: nn:=13;
   7: nn:=11;
   3: nn:=7;
   1: nn:=3;
   0: nn:=1;
 end;

end;

procedure clrst;
begin
 for x:=1 to 12 do
  for y:=1 to 22 do
   if (x=1) or (x=12) or (y=1) then st[x,y]:=2 else st[x,y]:=0;
end;

procedure risvesst;
begin
 for x:=1 to 12 do
  for y:=1 to 22 do begin
    ss:=st[x,y];
    k(x,y);
  end;
end;

procedure dvig;
var
 i:byte;
 key:char;
begin
 for i:=1 to 10 do
  begin
  delay(d);
  key:=' ';
  if keypressed then key:=readkey;

  if (key='a') then
   begin
   fig(x-1,y,nn,3);
   if pus=0 then begin fig(x,y,nn,0); x:=x-1; fig(x,y,nn,1); end;
   end;
  if key='d' then
   begin
   fig(x+1,y,nn,3);
   if pus=0 then begin fig(x,y,nn,0); x:=x+1; fig(x,y,nn,1); end;
   end;
  if key='w' then
   begin
   pov; fig(x,y,nn,3); pov;pov;pov;
   if pus=0 then begin fig(x,y,nn,0); pov; fig(x,y,nn,1); end;
   end;
  if key='s' then d:=5;
  end;
end;



begin
 randomize;
 clrscr;
 clrst;
 risvesst;
 lin:=0;

 repeat

  nn:=1+random(18);
  x:=6;y:=20; fig(x,y,nn,3); d:=70-(lin*5);


  if pus=0 then
   begin
    repeat
     fig(x,y,nn,1);
     dvig;
     fig(x,y-1,nn,3);
     if pus=0 then begin fig(x,y,nn,0); y:=y-1; end;
    until pus=1;


    fig(x,y,nn,4);
    for y:=22 downto 2 do
     begin
      a:=0; for x:=2 to 11 do a:=a+st[x,y];
      if a=10 then
       begin
        for b:=y to 21 do for c:=2 to 11 do st[c,b]:=st[c,b+1];
        lin:=lin+1;
        gotoxy(2,2); writeln('Line: ',lin)
       end;
     end;
     risvesst;
     pus:=0;
   end;

 until pus=1;

end.

