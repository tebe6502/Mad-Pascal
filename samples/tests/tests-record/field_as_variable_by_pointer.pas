// https://github.com/tebe6502/Mad-Pascal/issues/94

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

procedure PrintPoint(var p: Point);
begin
  WriteLn(p.x, ' ', p.y);
end;

procedure PrintSegment(sp: SegmentPtr);
begin
  PrintPoint(sp^.a);
  PrintPoint(sp^.b);
end;

begin
  s.a.x := 1;  s.a.y := 2;
  s.b.x := 3;  s.b.y := 4;

  PrintSegment(@s);

  repeat until keypressed;
end.
