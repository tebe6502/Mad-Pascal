// Written for TU Berlin
// Compiled with fpc

// http://rosettacode.org/wiki/Yin_and_yang#Pascal

Program yingyang;
Uses crt, Math;
const
 scale_x=1;
 scale_y=1;
 black='#';
 white='.';
 clear=' ';

function inCircle(centre_x:shortint;centre_y:shortint;radius:shortint;x:shortint;y:shortint):Boolean ;
begin
inCircle:=power(x-centre_x,2)+power(y-centre_y,2)<=power(radius,2);
end;

function bigCircle(radius:shortint;x:shortint;y:shortint):Boolean ;
begin
bigCircle:=inCircle(0,0,radius,x,y);
end;

function whiteSemiCircle(radius:shortint;x:shortint;y:shortint):Boolean ;
begin
whiteSemiCircle:=inCircle(0,radius div 2 ,radius div 2,x,y);
end;


function smallBlackCircle(radius:shortint;x:shortint;y:shortint):Boolean ;
begin
smallBlackCircle:=inCircle(0,radius div 2 ,radius div 6,x,y);
end;

function blackSemiCircle(radius:shortint;x:shortint;y:shortint):Boolean ;
begin
blackSemiCircle:=inCircle(0,-radius div 2 ,radius div 2,x,y);
end;

function smallWhiteCircle(radius:shortint;x:shortint;y:shortint):Boolean ;
begin
smallWhiteCircle:=inCircle(0,-radius div 2 ,radius div 6,x,y);
end;

var
radius,sy,sx,x,y: shortint;

begin
//write(#14);

//   writeln('Please type a radius:');
  // readln(radius);

  radius:=8;

   if radius<3 then begin writeln('A radius bigger than 3');halt end;
   sy:=round(radius*scale_y);

   while (sy>=-round(radius*scale_y)) do begin
      sx:=-round(radius*scale_x);

      while (sx<=round(radius*scale_x)) do begin
        x:=sx div scale_x;
        y:=sy div scale_y;

        if bigCircle(radius,x,y) then begin
                if (whiteSemiCircle(radius,x,y)) then if smallblackCircle(radius,x,y) then write(black) else write(white) else if blackSemiCircle(radius,x,y) then if smallWhiteCircle(radius,x,y) then write(white) else write(black) else if x>0 then write(white) else write(black);
                end
              else write(clear);
        sx:=sx+1
      end;

      writeln;
      sy:=sy-1;
   end;

 repeat until keypressed;


end.
