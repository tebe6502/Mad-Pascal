uses crt, graph;

//{$define forward}

var
	i, x, y: byte;

begin

 InitGraph(10);

 FOR I:=0 TO 7 do palette[i+1]:=14-i*2;

 FOR Y:=0 TO 95 do begin
  SetColor(Y DIV 12+1);
  X:=round(Y/2.4);

  MoveTo(x,y); LineTo(79-X,Y); LineTo(79-X,191-Y); LineTo(X,191-Y); LineTo(X,Y);

 end;


 repeat

  delay(64);

{$ifdef forward}
  i:=palette[8];

  palette[8]:=palette[7];
  palette[7]:=palette[6];
  palette[6]:=palette[5];
  palette[5]:=palette[4];
  palette[4]:=palette[3];
  palette[3]:=palette[2];
  palette[2]:=palette[1];
  palette[1]:=palette[0];
  palette[0]:=i + $10;

{$else}
  i:=palette[0];

  palette[0]:=palette[1];
  palette[1]:=palette[2];
  palette[2]:=palette[3];
  palette[3]:=palette[4];
  palette[4]:=palette[5];
  palette[5]:=palette[6];
  palette[6]:=palette[7];
  palette[7]:=palette[8];
  palette[8]:=i + $10
{$endif}

 until keypressed;

end.
