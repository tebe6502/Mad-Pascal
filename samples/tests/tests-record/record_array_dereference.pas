{

95.0000,118.0000
118.0000
118.0000
95.0000

}

uses crt;

Type
	Triangle =
   	Record
      	X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3 : Real;
         Color : Byte;
      End;

VAR
    
 i, j, n: byte;
 
 Tris: array [0..100] of ^Triangle;
 
 t_m_p: Triangle;
 
 pt: ^Triangle;
 

 
procedure test(var aui, bui: real);
begin

 aui:=95;
 bui:=118;

end;



begin

n:=10;

 Tris[10] := GetMem(sizeof(Triangle));
 Tris[11] := GetMem(sizeof(Triangle));
 
 pt:=tris[11];


 test(Tris[n].x1, Tris[n+1].x1);

 t_m_p := Tris[n+1]^;
 
 writeln(Tris[10].x1:4:4,',',Tris[11].x1:4:4);

 writeln(t_m_p.x1:4:4);

 Tris[n+1]^ := Tris[n]^;


 Tris[n]^ := t_m_p;
 writeln(tris[n].x1:4:4);

 
 Tris[n+1]^ := pt^;
 writeln(Tris[11].x1:4:4);


repeat until keypressed;

end.

