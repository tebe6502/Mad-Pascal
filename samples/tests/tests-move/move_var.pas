
var
	i: byte;
	p: ^byte;

begin

p:=pointer($bc40);

for i:=0 to 39 do 
 p[i]:=ord('0')-32+i;
  
move(pointer($bc40), pointer($bc40+40), 40) ;

i:=1;

move(pointer($bc40+i), pointer($bc40), 39) ;

move(pointer($bc40+40), pointer($bc40+40+i), 39) ;


while true do;


end.