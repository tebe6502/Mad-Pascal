
uses crt;

var tmp: array [0..3] of byte;

procedure BubbleSort;
var i, temp, newn, n: byte;
begin

  n:=3;

  repeat
    newn := 0;
    for i := 1 to 3 do
      begin
        if tmp[ i - 1 ] > tmp[ i ] then
          begin
            temp := tmp[ i - 1 ];

	          tmp[ i - 1 ] := tmp[ i ];
	          tmp[ i ] := temp;

            newn := i ;
          end;
      end ;
    n := newn;
  until n = 0;

end;


begin

 tmp[0]:=50;
 tmp[1]:=11;
 tmp[2]:=44;
 tmp[3]:=20;

 BubbleSort;

 writeln(tmp[0]);
 writeln(tmp[1]);
 writeln(tmp[2]);
 writeln(tmp[3]);

 repeat until keypressed;

end.