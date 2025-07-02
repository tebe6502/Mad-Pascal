{
 1 2
 3 4
}

uses crt;

type
  Point = record x, y: Byte end;
  Segment = record a, b: Point end;
  SegmentPtr = ^Segment;

var s: Segment;

procedure DoSomething(sp: SegmentPtr);
var a, b: Point;
begin
  // (1)
//  a := sp^.a;
//  b := sp^.b;

  // (2)
   a := sp.a;
   b := sp.b;

  WriteLn(a.x, ' ', a.y);
  WriteLn(b.x, ' ', b.y);
end;

begin
  s.a.x := 1;  s.a.y := 2;
  s.b.x := 3;  s.b.y := 4;

  DoSomething(@s);

  ReadKey();
end.
