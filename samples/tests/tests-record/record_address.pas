{

 10 11
 20 21

}

uses crt;

type
  Vector = packed record x, y: byte end;

  Segment = packed record  v1, v2: Vector end;

  VectorPtr = ^Vector;


var s: Segment;

procedure PutVector(v: VectorPtr; x, y: Byte);
begin
  v^.x := x;
  v^.y := y;
end;

begin
  PutVector(@s.v1, 10, 11);
  PutVector(@s.v2, 20, 21);

  WriteLn('v1: ', s.v1.x, ' ', s.v1.y);
  WriteLn('v2: ', s.v2.x, ' ', s.v2.y);

  repeat until keypressed;
end.
