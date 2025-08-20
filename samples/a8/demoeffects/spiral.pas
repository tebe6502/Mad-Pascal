usec crt;


procedure SetupTables();
var i: byte;
begin

	for i:=0 to 255 do perlin[i]:=perlin[i] div 28;

end;


procedure PreCalculate();
var x,y,dx,dy,i,j: byte;
    k: word;
    int: smallint;
begin
	k:=0;

	for y:=0 to 25 do begin
		for x:=0 to 80 do begin
			dx:=abs(40-x);
			dx:=dx div 3;
		
			dy:=abs(12-y);
			int := dx*dx + dy*dy;
			int:=int div 7;
			i:=sqrt(int);
			i:=i+5;
		
			c1pos[k]:=64 div i;

			j:=atan2(40,x,24,y*2);

			l1pos[k]:=j div 5;
			
			inc(k);
		end;
	end;

end;



begin

 



end.