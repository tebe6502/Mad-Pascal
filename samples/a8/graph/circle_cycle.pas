uses crt, graph;

var
	i, v, r: byte;

begin

 InitGraph(10);

 FOR I:=0 TO 7 do begin
  V:=2+(2*(7-I)*ord(I>2)+2*I*ord(I<3))+(I*32);
  palette[i+1]:=v;
 END;

 FOR I:=0 TO 140 do begin
  SetColor(1+(I DIV 8 MOD 8));
  R:=32+i;
  Ellipse(40,96,round(R/3.5),R);
 END;

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
  palette[1]:=i + $10;
{$else}
  i:=palette[1];

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
