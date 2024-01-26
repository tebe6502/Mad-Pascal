uses crt;

type

//	tprc = procedure();
	tprc = function (a: byte): byte;


var
	d: word;

	x,y: byte;

	tp: array [0..1] of tprc;

	kk, ex: tprc;



procedure prn;
begin

 writeln('ok');

end;




begin

 y:=2;

 ex:=@prn;


 kk:=ex;


 tp[y] := ex;


 kk(1);

 tp[y](3);
 
 repeat until keypressed;

end.