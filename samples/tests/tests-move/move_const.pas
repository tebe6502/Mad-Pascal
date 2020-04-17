
var
	i: byte;
	p: ^byte;

begin

p:=pointer($bc40);

for i:=0 to 39 do 
 p[i]:=ord('0')-32+i;
  
move(pointer($bc40), pointer($bc40+40), 40) ;

move(pointer($bc40+1), pointer($bc40), 39) ;

move(pointer($bc40+40), pointer($bc40+41), 39) ;


while true do;


end.